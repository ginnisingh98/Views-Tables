--------------------------------------------------------
--  DDL for Package PAY_NL_IZA_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_NL_IZA_REPORT" AUTHID CURRENT_USER AS
/* $Header: paynliza.pkh 120.0 2005/05/29 02:40:44 appldev noship $ */



/*Procedure to fetch necessary data for the report.
  This procedure then calls procedure WritetoCLOB to write the contents of the XML file as a CLOB*/

/*-------------------------------------------------------------------------------
|Name           : populate_iza_report_data                                      |
|Type		: Procedure						        |
|Description    : Procedure to generate the Annual Tax Statement Report         |
------------------------------------------------------------------------------*/


PROCEDURE populate_iza_report_data(p_bg_id IN NUMBER,
                                   p_bg_name IN VARCHAR2,
                                   p_eff_date IN VARCHAR2,
                                   p_org_struct_id IN NUMBER,
                                   p_org_struct IN VARCHAR2,
                                   p_process_month IN VARCHAR2,
				   p_employer_id IN NUMBER,
                                   p_employer IN VARCHAR2,
                                   p_xfdf_blob OUT NOCOPY BLOB);

PROCEDURE record_4712(p_file_id NUMBER);

END PAY_NL_IZA_REPORT;

 

/
