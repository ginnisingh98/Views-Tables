--------------------------------------------------------
--  DDL for Package PAY_IE_P35_XML_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IE_P35_XML_PKG" AUTHID CURRENT_USER AS
/* $Header: pyiep35p.pkh 120.0.12010000.1 2008/07/27 22:50:20 appldev ship $ */
TYPE XMLRec IS RECORD(
xmlString VARCHAR2(6000)
);
TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;
vCtr NUMBER;
PROCEDURE WritetoCLOB (p_xfdf_string out nocopy clob);
PROCEDURE populate_p35_rep
	  (p_bg_id IN NUMBER
	   ,p_emp_no IN VARCHAR2
	   ,p_payroll        IN NUMBER
   	   ,p_assignment_set        IN NUMBER
	   ,p_end_date IN VARCHAR2
	   ,p_weeks IN VARCHAR2
	   ,p_template_name IN VARCHAR2
       ,p_xml         OUT NOCOPY CLOB
	   );
PROCEDURE populate_plsql_table
	  (p_bg_id IN NUMBER
	   ,p_emp_no IN VARCHAR2
	   ,p_payroll        IN NUMBER
   	   ,p_assignment_set        IN NUMBER
	   ,p_end_date IN VARCHAR2
   	   ,p_weeks IN VARCHAR2);
FUNCTION get_start_date
      RETURN DATE;
FUNCTION get_end_date
      RETURN DATE;
END PAY_IE_P35_XML_PKG;

/
