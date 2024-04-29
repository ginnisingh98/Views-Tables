--------------------------------------------------------
--  DDL for Package WMS_CLABEL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WMS_CLABEL" AUTHID CURRENT_USER AS
/* $Header: WMSCLBLS.pls 115.0 2000/07/07 15:47:11 pkm ship        $ */

  TYPE variables_type IS TABLE OF VARCHAR2(512) INDEX BY BINARY_INTEGER;

  PRINT_WITH_HEADER      CONSTANT NUMBER := 1;
  PRINT_WITHOUT_HEADER   CONSTANT NUMBER := 2;

  PROCEDURE clearHeader;

  PROCEDURE setHeader(p_header IN VARIABLES_TYPE);

  PROCEDURE clearLine;

  PROCEDURE setLine(p_line IN VARIABLES_TYPE);

  PROCEDURE setDefaultLabelInfo(p_defaultLabelName IN VARCHAR2,
                                p_defaultPrinterName IN VARCHAR2,
                                p_defaultNoCopies  IN NUMBER);

  PROCEDURE setLabelInfo(p_labelName IN VARCHAR2,
                         p_PrinterName IN VARCHAR2,
                         p_NoCopies  IN NUMBER);

  PROCEDURE setHeaderVariable(p_var_name IN VARCHAR2,
                              p_var_value IN VARCHAR2);

  PROCEDURE setLineVariable(p_var_name IN VARCHAR2,
                            p_var_value IN VARCHAR2);

  PROCEDURE openLabelFile(p_dir IN VARCHAR2,p_file IN VARCHAR2);

  PROCEDURE writeLabel(p_print_header IN NUMBER DEFAULT PRINT_WITH_HEADER);

  PROCEDURE closeLabelFile;

END WMS_CLABEL;

 

/
