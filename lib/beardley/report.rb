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
        @source_file = report if report.extname.downcase == ".jrxml"
        @object_file = report if report.extname.downcase == ".jasper"
      elsif report.is_a?(String)
        hash = Digest::SHA256.hexdigest(report)
        @source_file = Pathname.new(options[:tmp_dir] || "/tmp").join("report-" + hash + '.jrxml')
        File.open(@source_file, 'wb') do |f|
          f.write(report)
        end
      end
      @object_file ||= @source_file.dirname.join(@source_file.basename.to_s + ".jasper")
      raise ArgumentError.new("An object must be given at least") unless @object_file.is_a?(Pathname)
    end

    # Export report to PDF with given datasource
    def to_pdf(*args)
      options = extract_options!(args)
      datasource = args[0]
      return JasperExportManager._invoke('exportReportToPdf', 'Lnet.sf.jasperreports.engine.JasperPrint;', prepare(datasource))
    end

    # Export report to ODT with given datasource
    def to_odt(*args)
      return to(:odt, *args)
    end

    # Export report to DOCX with given datasource
    def to_docx(*args)
      return to(:docx, *args)
    end

    private

    # Generic method to export to some format like ODT and DOCX
    def to(format, *args)
      options = extract_options!(args)
      datasource = args[0]
      file = Tempfile.new("to_#{format}")
      exporter = Beardley.const_get("JR#{format.to_s.capitalize}Exporter").new
      exporter.setParameter(JRExporterParameter.JASPER_PRINT, prepare(datasource))
      exporter.setParameter(JRExporterParameter.OUTPUT_FILE_NAME, file.path.to_s)
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
        JasperCompileManager.compileReportToFile(@source_file.to_s, @object_file.to_s)
      end
      load_datasource(datasource)
    end

    # Load parsed XML datasource with java component
    def load_datasource(datasource = nil)
      # Converting default report params to java HashMap
      jasper_params = HashMap.new
      Beardley.config[:report_params].each do |k,v|
        jasper_params.put(k, v)
      end
      
      # Convert the ruby parameters' hash to a java HashMap, but keeps it as
      # default when they already represent a JRB entity.
      # Pay attention that, for now, all other parameters are converted to string!
      @parameters.each do |key, value|
        jasper_params.put(JavaString.new(key.to_s), parameter_value_of(value))
      end

      jasper_print = nil

      # Fill the report
      if datasource
        input_source = InputSource.new
        input_source.setCharacterStream(StringReader.new(datasource.to_s))
        data_document = JRXmlUtils._invoke('parse', 'Lorg.xml.sax.InputSource;', input_source)
        
        jasper_params.put(JRXPathQueryExecuterFactory.PARAMETER_XML_DATA_DOCUMENT, data_document)
        jasper_print = JasperFillManager.fillReport(@object_file.to_s, jasper_params)
      else
        jasper_print = JasperFillManager.fillReport(@object_file.to_s, jasper_params, JREmptyDataSource.new)
      end
      return jasper_print
    end

    # Returns the value without conversion when it's converted to Java Types.
    # When isn't a Rjb class, returns a Java String of it.
    def parameter_value_of(param)
      # Using Rjb::import('java.util.HashMap').new, it returns an instance of
      # Rjb::Rjb_JavaProxy, so the Rjb_JavaProxy parent is the Rjb module itself.
      if param.class.parent == Rjb
        param
      else
        JavaString.new(param.to_s)
      end
    end

  end

end