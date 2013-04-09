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

require "beardley/version"
require "beardley/core"
require "beardley/groovy"
require "beardley/barcode"
require "pathname"
require "digest"
require "rjb"


module Beardley

  class << self
    attr_accessor :config

    # Changes the level of verbosity
    def with_warnings(flag = nil)
      old_verbose, $VERBOSE = $VERBOSE, flag
      yield
    ensure
      $VERBOSE = old_verbose
    end
    
  end

  Rjb::load((["."] + Beardley::Core.classpath + Beardley::Groovy.classpath + Beardley::Barcode.classpath).join(File::PATH_SEPARATOR), ['-Djava.awt.headless=true','-Xms128M', '-Xmx256M'])

  Locale                      = Rjb::import('java.util.Locale')

  JRException                 = Rjb::import('net.sf.jasperreports.engine.JRException')
  JRExporterParameter         = Rjb::import('net.sf.jasperreports.engine.JRExporterParameter')
  JRXmlUtils                  = Rjb::import('net.sf.jasperreports.engine.util.JRXmlUtils')
  JRXPathQueryExecuterFactory = with_warnings { Rjb::import('net.sf.jasperreports.engine.query.JRXPathQueryExecuterFactory') }
  JREmptyDataSource           = Rjb::import('net.sf.jasperreports.engine.JREmptyDataSource')
  JROdtExporter               = Rjb::import('net.sf.jasperreports.engine.export.oasis.JROdtExporter')
  JROdsExporter               = Rjb::import('net.sf.jasperreports.engine.export.oasis.JROdsExporter')
  JRDocxExporter              = Rjb::import('net.sf.jasperreports.engine.export.ooxml.JRDocxExporter')
  JRXlsxExporter              = Rjb::import('net.sf.jasperreports.engine.export.ooxml.JRXlsxExporter')

  JasperCompileManager        = Rjb::import('net.sf.jasperreports.engine.JasperCompileManager')
  JasperExportManager         = Rjb::import('net.sf.jasperreports.engine.JasperExportManager')
  JasperFillManager           = Rjb::import('net.sf.jasperreports.engine.JasperFillManager')
  JasperPrint                 = Rjb::import('net.sf.jasperreports.engine.JasperPrint')

  InputSource                 = Rjb::import('org.xml.sax.InputSource')
  StringReader                = Rjb::import('java.io.StringReader')
  HashMap                     = Rjb::import('java.util.HashMap')
  ByteArrayInputStream        = Rjb::import('java.io.ByteArrayInputStream')
  JavaString                  = Rjb::import('java.lang.String')
  JFreeChart                  = Rjb::import('org.jfree.chart.JFreeChart')
  JavaStringBuffer            = Rjb::import('java.lang.StringBuffer')

  # Default report params
  self.config = {
    :report_params => {
      "REPORT_LOCALE"    => Locale.new('en', 'US'),
      "XML_LOCALE"       => Locale.new('en', 'US'),
      "XML_DATE_PATTERN" => 'yyyy-MM-dd'
    }
  }

  autoload :Report, 'beardley/report'
end
