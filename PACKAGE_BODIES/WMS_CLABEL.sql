--------------------------------------------------------
--  DDL for Package Body WMS_CLABEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_CLABEL" AS
/* $Header: WMSCLBLB.pls 115.0 2000/07/07 15:47:06 pkm ship        $ */

XML_HEADER1   CONSTANT VARCHAR2(100) := '<?xml version="1.0" standalone="no"?>';
XML_HEADER2   CONSTANT VARCHAR2(100) := '<!DOCTYPE labels SYSTEM "label.dtd">';
separator     CONSTANT VARCHAR2(2) := '::';

defaultLabelName VARCHAR2(50);
defaultPrinterName VARCHAR2(40);
defaultNoCopies  NUMBER;

labelName    VARCHAR2(50);
printerName  VARCHAR2(40);
noCopies     NUMBER;

xmlfh  UTL_FILE.FILE_TYPE := NULL;

header VARIABLES_TYPE;
line   VARIABLES_TYPE;

PROCEDURE clearHeader
IS
BEGIN
  header.delete;
END clearHeader;

PROCEDURE setHeader(p_header IN VARIABLES_TYPE)
IS
BEGIN
  header := p_header;
END setHeader;

PROCEDURE clearLine
IS
BEGIN
  line.delete;
END clearLine;

PROCEDURE setLine(p_line IN VARIABLES_TYPE)
IS
BEGIN
  line := p_line;
END setLine;

PROCEDURE setDefaultLabelInfo(p_defaultLabelName IN VARCHAR2,
                              p_defaultPrinterName IN VARCHAR2,
                              p_defaultNoCopies IN NUMBER)
IS
BEGIN
  defaultLabelName := p_defaultLabelName;
  defaultPrinterName := p_defaultPrinterName;
  defaultNoCopies := p_defaultNoCopies;
END setDefaultLabelInfo;

PROCEDURE setLabelInfo(p_labelName IN VARCHAR2,
                       p_printerName IN VARCHAR2,
                       p_noCopies  IN NUMBER)
IS
BEGIN
  labelName := p_labelName;
  printerName := p_printerName;
  noCopies := p_noCopies;
END setLabelInfo;

PROCEDURE setHeaderVariable(p_var_name IN VARCHAR2,
                            p_var_value IN VARCHAR2)
IS
 l_var_val_pair       VARCHAR2(4000);
BEGIN
 l_var_val_pair := p_var_name||separator||p_var_value;
 header(header.count+1) := l_var_val_pair;
END setHeaderVariable;

PROCEDURE setLineVariable(p_var_name IN VARCHAR2,
                            p_var_value IN VARCHAR2)
IS
 l_var_val_pair       VARCHAR2(4000);
BEGIN
 l_var_val_pair := p_var_name||separator||p_var_value;
 line(line.count+1) := l_var_val_pair;
END setLineVariable;

PROCEDURE openLabelFile(p_dir IN VARCHAR2,p_file IN VARCHAR2)
IS
 l_labels      VARCHAR2(200) := '<labels';
BEGIN
  xmlfh := utl_file.fopen(p_dir,p_file,'w');
  utl_file.put_line(xmlfh,XML_HEADER1);
  utl_file.put_line(xmlfh,XML_HEADER2);

  if defaultLabelName IS NOT NULL then
    l_labels := l_labels||' defaultLabelName="'||defaultLabelName||'"';
  end if;
  if defaultPrinterName IS NOT NULL then
    l_labels := l_labels||' defaultPrinterName="'||defaultPrinterName||'"';
  end if;
  if defaultNoCopies IS NOT NULL then
    l_labels := l_labels||' defaultNoCopies="'||defaultNoCopies||'"';
  end if;

  l_labels := l_labels||'>';
  utl_file.put_line(xmlfh,l_labels);
EXCEPTION
  WHEN UTL_FILE.INVALID_PATH THEN
    null;
  WHEN OTHERS THEN
    null;
END openLabelFile;

PROCEDURE writeVariables(variables IN VARIABLES_TYPE)
IS
  l_var_value_pair VARCHAR2(4000);
  l_var_name       VARCHAR2(50);
  l_var_value      VARCHAR2(4000);
BEGIN
  for i in 1..variables.last loop
    l_var_value_pair := variables(i);
    l_var_name := substr(l_var_value_pair,1,
                         instr(l_var_value_pair,separator)-1);
    l_var_value := substr(l_var_value_pair,
                          instr(l_var_value_pair,separator)+length(separator));
    utl_file.put_line(xmlfh,'<variable name="'||l_var_name||'">'||
                       l_var_value||'</variable>');
  end loop;
END writeVariables;

PROCEDURE writeLabel(p_print_header IN NUMBER DEFAULT PRINT_WITH_HEADER)
IS
  l_label     VARCHAR2(200) := '<label';
BEGIN
  if labelName IS NOT NULL then
    l_label := l_label||' labelName="'||labelName||'"';
  end if;
  if printerName IS NOT NULL then
    l_label := l_label||' printerName="'||printerName||'"';
  end if;
  if noCopies IS NOT NULL then
    l_label := l_label||' noCopies="'||noCopies||'"';
  end if;
  l_label := l_label||'>';
  utl_file.put_line(xmlfh,l_label);

  if(p_print_header = PRINT_WITH_HEADER) then
    writeVariables(header);
  end if;
  writeVariables(line);

  utl_file.put_line(xmlfh,'</label>');
END writeLabel;

PROCEDURE closeLabelFile
IS
BEGIN
  utl_file.put_line(xmlfh,'</labels>');
  utl_file.fclose(xmlfh);
EXCEPTION
  WHEN OTHERS THEN
    null;
END closeLabelFile;

END WMS_CLABEL;

/
