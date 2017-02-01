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
require "pathname"
require "digest"
require "rjb"
require "rjb-loader"


module Beardley

  class << self
    attr_accessor :config, :exporters

    # Changes the level of verbosity
    def with_warnings(flag = nil)
      old_verbose, $VERBOSE = $VERBOSE, flag
      yield
    ensure
      $VERBOSE = old_verbose
    end

  end

  # Default report params
  self.config = {
    report_params: {}
  }
  self.exporters = {
    odt: 'net.sf.jasperreports.engine.export.oasis.JROdtExporter',
    ods: 'net.sf.jasperreports.engine.export.oasis.JROdsExporter',
    csv: 'net.sf.jasperreports.engine.export.JRCsvExporter',
    docx: 'net.sf.jasperreports.engine.export.ooxml.JRDocxExporter',
    xlsx: 'net.sf.jasperreports.engine.export.ooxml.JRXlsxExporter'
  }

  RjbLoader.before_load do |config|
    Dir[Pathname.new(__FILE__).dirname.join("..", "vendor", "java", "*.jar")].each do |path|
      config.classpath << File::PATH_SEPARATOR + File.expand_path(path)
    end
  end

  RjbLoader.after_load do |config|
    _Locale = Rjb::import('java.util.Locale')
    Beardley.config[:report_params]["REPORT_LOCALE"]    = _Locale.new('en', 'US')
    Beardley.config[:report_params]["XML_LOCALE"]       = _Locale.new('en', 'US')
    Beardley.config[:report_params]["XML_DATE_PATTERN"] = "yyyy-MM-dd'T'HH:mm:ss"
    Beardley.config[:report_params]["XML_NUMBER_PATTERN"] = '###0.00'
  end

  autoload :Report, 'beardley/report'

end
