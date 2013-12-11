#
# Copyright (C) 2012 Marlus Saraiva, Rodrigo Maia
# Copyright (C) 2013 Brice Texier
#
# Permission is hereby granted, free of charge, to any person obtaining
# a copy of this software and associated documentation files (the
# "Software"), to deal in the Software without restriction, including
# without limitation the rights to use, copy, modify, merge, publish,
# distribute, sublicense, and/or sell copies of the Software, and to
# permit persons to whom the Software is furnished to do so, subject to
# the following conditions:
#
# The above copyright notice and this permission notice shall be
# included in all copies or substantial portions of the Software.
#
# THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
# EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
# MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
# NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE
# LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION
# OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION
# WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

module Beardley

  # This class permit to produce reports in PDF, ODT and DOCX using Jasper
  class Report
    attr_reader :source_file, :object_file
    
    # Constructor for a report generator
    def initialize(report, options = {})
      @parameters = options.delete(:report) || {}
      @source_file, @object_file = nil, nil
      if report.is_a?(Pathname)
        @source_file = report if report.extname.downcase == ".jrxml" or report.extname.downcase == ".xml"
        @object_file = report if report.extname.downcase == ".jasper"
      elsif report.is_a?(String)
        hash = Digest::SHA256.hexdigest(report)
        @source_file = Pathname.new(options[:tmp_dir] || "/tmp").join("report-" + hash + '.jrxml')
        File.open(@source_file, 'wb') do |f|
          f.write(report)
        end
      end
      @object_file ||= @source_file.dirname.join(@source_file.basename.to_s + ".jasper")
      unless @object_file.is_a?(Pathname)
        raise ArgumentError, "An object must be given at least"
      end
    end

    # Export report to PDF with given datasource
    def to_pdf(*args)
      options = extract_options!(args)
      datasource = args[0]
      _JasperPrint                 = Rjb::import('net.sf.jasperreports.engine.JasperPrint')
      _JasperExportManager         = Rjb::import('net.sf.jasperreports.engine.JasperExportManager')
      return _JasperExportManager._invoke('exportReportToPdf', 'Lnet.sf.jasperreports.engine.JasperPrint;', prepare(datasource))
    end

    # Export report to ODT with given datasource
    def to_odt(*args)
      return to(:odt, *args)
    end

    # Export report to ODS with given datasource
    def to_ods(*args)
      return to(:ods, *args)
    end

    # Export report to CSV with given datasource
    def to_csv(*args)
      return to(:csv, *args)
    end

    # Export report to DOCX with given datasource
    def to_docx(*args)
      return to(:docx, *args)
    end

    # Export report to XLSX with given datasource
    def to_xlsx(*args)
      return to(:xlsx, *args)
    end

    # XLS and RTF are not suitable anymore
    # NOTE: JasperReports can not produce DOC files

    private

    # Generic method to export to some format like ODT and DOCX
    def to(format, *args)
      options = extract_options!(args)
      datasource = args[0]
      file = Tempfile.new("to_#{format}")
      exporter = Beardley.with_warnings { Rjb::import(Beardley.exporters[format]) }.new
      _JRExporterParameter = Rjb::import('net.sf.jasperreports.engine.JRExporterParameter')
      exporter.setParameter(_JRExporterParameter.JASPER_PRINT, prepare(datasource))
      exporter.setParameter(_JRExporterParameter.OUTPUT_FILE_NAME, file.path.to_s)
      exporter.exportReport
      file.rewind
      report = file.read
      file.close(true)
      return report
    end

    # Extract options from a list of arguments
    def extract_options!(args)
      return (args[-1].is_a?(Hash) ? args.delete_at(-1) : {})
    end

    # Create object file if not exist and load datasource
    def prepare(datasource = nil)
      # Compile it, if needed
      if @source_file && ((!@object_file.exist? && @source_file.exist?) || (@source_file.exist? && @source_file.mtime > @object_file.mtime))
        _JasperCompileManager = Rjb::import('net.sf.jasperreports.engine.JasperCompileManager')
        _JasperCompileManager.compileReportToFile(@source_file.to_s, @object_file.to_s)
      end
      load_datasource(datasource)
    end


    # Build the default parameters Hash for printing
    def prepare_params
      _HashMap    = Rjb::import('java.util.HashMap')
      _JavaString = Rjb::import('java.lang.String')

      # Converting default report params to java HashMap
      params = _HashMap.new
      Beardley.config[:report_params].each do |k,v|
        params.put(k, v)
      end
      
      # Convert the ruby parameters' hash to a java HashMap, but keeps it as
      # default when they already represent a JRB entity.
      # Pay attention that, for now, all other parameters are converted to string!
      @parameters.each do |key, value|
        params.put(_JavaString.new(key.to_s), parameter_value_of(value))
      end
      
      return params
    end

    # Load parseable XML datasource with java component
    def load_datasource(datasource = nil)
      jasper_params = prepare_params

      # Parse and load XML as datasource 
      if datasource
        _InputSource                 = Rjb::import('org.xml.sax.InputSource')
        _StringReader                = Rjb::import('java.io.StringReader')
        _JRXmlUtils                  = Rjb::import('net.sf.jasperreports.engine.util.JRXmlUtils')
        _JRXPathQueryExecuterFactory = Beardley.with_warnings { Rjb::import('net.sf.jasperreports.engine.query.JRXPathQueryExecuterFactory') }
        input_source = _InputSource.new
        input_source.setCharacterStream(_StringReader.new(datasource.to_s))
        data_document = Beardley.with_warnings do
          _JRXmlUtils._invoke('parse', 'Lorg.xml.sax.InputSource;', input_source)
        end
        jasper_params.put(_JRXPathQueryExecuterFactory.PARAMETER_XML_DATA_DOCUMENT, data_document)
      end

      # Build JasperPrint
      return fill_report(jasper_params, datasource)
    end


    # Fill the report with valid method depending on datasource
    def fill_report(params, datasource = nil)
      _JasperFillManager           = Rjb::import('net.sf.jasperreports.engine.JasperFillManager')
      if datasource
        return _JasperFillManager.fillReport(@object_file.to_s, params)
      else
        _JREmptyDataSource           = Rjb::import('net.sf.jasperreports.engine.JREmptyDataSource')
        return _JasperFillManager.fillReport(@object_file.to_s, params, _JREmptyDataSource.new)
      end
    end
    

    # Returns the value without conversion when it's converted to Java Types.
    # When isn't a Rjb class, returns a Java String of it.
    def parameter_value_of(param)
      # Using Rjb::import('java.util.HashMap').new, it returns an instance of
      # Rjb::Rjb_JavaProxy, so the Rjb_JavaProxy parent is the Rjb module itself.
      if param.class.parent == Rjb
        param
      else
        Rjb::import('java.lang.String').new(param.to_s)
      end
    end

  end

end
