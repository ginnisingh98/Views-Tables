--------------------------------------------------------
--  DDL for Package PAY_NL_ATS_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_ATS_REPORT" AUTHID CURRENT_USER AS
/* $Header: paynlats.pkh 120.0.12000000.3 2007/08/31 05:28:43 rsahai noship $ */

TYPE UserBalValRec IS RECORD(
BalValue NUMBER,
TagName VARCHAR2(1000));

TYPE tUserBalValTable IS TABLE OF UserBalValRec INDEX BY BINARY_INTEGER;
vUserBalVal tUserBalValTable;

/*Procedure to fetch necessary data for the report.
  This procedure then calls procedure WritetoCLOB to write the contents of the XML file as a CLOB*/

/*-------------------------------------------------------------------------------
|Name           : populate_ats_report_data                                      |
|Type		: Procedure						        |
|Description    : Procedure to generate the Annual Tax Statement Report         |
------------------------------------------------------------------------------*/


PROCEDURE populate_ats_report_data(p_person_id IN NUMBER,
				   p_year      IN VARCHAR2,
				   p_bg_id     IN NUMBER,
				   p_employer_id IN NUMBER,
				   p_agg_flag IN VARCHAR2,
				   p_xfdf_blob OUT NOCOPY BLOB);

-- new procedure with CLOB as out parameter
procedure populate_ats_report_data_new
				(p_person_id IN NUMBER,
				 p_year      IN VARCHAR2,
				 p_bg_id     IN NUMBER,
				 p_employer_id IN NUMBER,
				 p_agg_flag IN VARCHAR2,
				 p_aggregate_multi_assign IN VARCHAR2,
				 p_employee_name IN VARCHAR2,
				 p_top_hr_organization_name IN VARCHAR2,
				 p_eff_date IN VARCHAR2,
				 p_template_format IN VARCHAR2,
				 p_template_name IN VARCHAR2,
				 p_xml OUT NOCOPY CLOB);

PROCEDURE record_4712(p_file_id NUMBER);

/*-----------------------------------------------------------------------------
|Name       : populate_UserBalVal				               |
|Type       : Procedure							       |
|Description: Procedure which populates pl/sql table with user defined balance |
|             values and tag names                                             |
-------------------------------------------------------------------------------*/

PROCEDURE populate_UserBalVal(p_User_Bal_String VARCHAR2, p_agg_flag VARCHAR2);

/*-----------------------------------------------------------------------------
|Name       : get_Address_Style					               |
|Type       : Function							       |
|Description: Function that returns the address style of the address record of |
|             a person at a given date                                         |
-------------------------------------------------------------------------------*/

FUNCTION get_Address_Style(p_person_id NUMBER, p_effective_date DATE) RETURN VARCHAR2;

/*-----------------------------------------------------------------------------
|Name       : get_Post_Code					               |
|Type       : Function							       |
|Description: Function that returns the postal code of the address record of   |
|             a person at a given date                                         |
-------------------------------------------------------------------------------*/

FUNCTION get_Post_Code(p_person_id NUMBER, p_effective_date DATE) RETURN VARCHAR2;


END PAY_NL_ATS_REPORT;

 

/
