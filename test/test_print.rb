# encoding: utf-8
require 'helper'

class TestPrint < Test::Unit::TestCase

  def test_print_of_a_xml_string
    report = Beardley::Report.new('<?xml version="1.0" encoding="UTF-8"?>
<jasperReport xmlns="http://jasperreports.sourceforge.net/jasperreports" xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance" xsi:schemaLocation="http://jasperreports.sourceforge.net/jasperreports http://jasperreports.sourceforge.net/xsd/jasperreport.xsd" name="show" language="groovy" pageWidth="595" pageHeight="842" columnWidth="555" leftMargin="20" rightMargin="20" topMargin="20" bottomMargin="20" uuid="9c1f11b7-03dd-4803-9e1b-41b87b9d23c0"/>')
    assert_equal Pathname, report.source_file.class
    assert_equal Pathname, report.object_file.class
    report.to_pdf
    report.to_odt
    report.to_docx
  end

  def test_print_of_empty_report
    empty = Pathname.new(__FILE__).dirname.join("fixtures", "empty.jrxml")
    assert empty.exist?
    report = Beardley::Report.new(empty)
    assert_equal Pathname, report.source_file.class
    assert_equal Pathname, report.object_file.class
    report.to_pdf
    report.to_odt
    report.to_docx                                  
  end

  def test_print_of_barcode_report
    barcode = Pathname.new(__FILE__).dirname.join("fixtures", "barcode.jrxml")
    assert barcode.exist?
    report = Beardley::Report.new(barcode)
    assert_equal Pathname, report.source_file.class
    assert_equal Pathname, report.object_file.class
    report.to_pdf
    report.to_odt
    report.to_docx                                  
  end

end
