--------------------------------------------------------
--  DDL for Package PAY_XML_GEN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_XML_GEN_PKG" AUTHID CURRENT_USER AS
/* $Header: pyxmlgen.pkh 120.0.12000000.1 2007/01/18 03:24:18 appldev noship $ */

Procedure exec_report_map_function (
p_func_name in varchar2,
p_parameters in varchar2,
p_tempfile_name in varchar2,
p_xml_data out nocopy CLOB
);

Procedure exec_report_map_function (
p_func_name in varchar2,
p_parameters in varchar2,
p_tempfile_name in varchar2,
p_xml_data out nocopy BLOB
);

END PAY_XML_GEN_PKG;

 

/
