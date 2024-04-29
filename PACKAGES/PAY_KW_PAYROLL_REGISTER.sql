--------------------------------------------------------
--  DDL for Package PAY_KW_PAYROLL_REGISTER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KW_PAYROLL_REGISTER" AUTHID CURRENT_USER AS
/* $Header: pykwpyrg.pkh 120.0.12010000.1 2008/07/27 23:07:51 appldev ship $ */


----------------------------------------------------------
TYPE XMLRec IS RECORD(
TagName VARCHAR2(240),
TagValue VARCHAR2(240));
TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;
vXMLTable_summary tXMLTable;
vCtr NUMBER;
vCtr_summary NUMBER;
-----------------------------------------------------------
/*PROCEDURE GET_PAYROLL_REGISTER_DATA (    p_organization_id IN number,
				                                    p_org_structure_version_id IN number,
				                                    p_payroll_id IN number,
									      p_effective_char_date IN varchar2,
										p_sort_order1 IN varchar2,
										p_sort_order2 In varchar2,
										p_sort_order3 IN varchar2,
                                       p_output_fname OUT NOCOPY VARCHAR2);*/
-----------------------------------------------------------
PROCEDURE GET_PAYROLL_REGISTER_DATA (    p_report IN varchar2,p_organization_id IN number,
				                                    p_org_structure_version_id IN number,
				                                    p_payroll_id IN number,
									p_effective_char_date IN varchar2,
										p_sort_order1 IN varchar2,
										p_sort_order2 In varchar2,
										p_sort_order3 IN varchar2,
                                       l_xfdf_blob OUT NOCOPY blob);
----------------------------------------------------------------
Procedure fetch_pdf_blob
	(p_report in varchar2,p_pdf_blob OUT NOCOPY blob);
-----------------------------------------------------------
/*
PROCEDURE WritetoXML( p_output_fname out nocopy varchar2);
PROCEDURE WriteXMLvalues(p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2);
*/
---------------------------------------------------------
Procedure  clob_to_blob(p_clob clob,
                          p_blob IN OUT NOCOPY Blob);
PROCEDURE WritetoCLOB (p_report in varchar2,
        p_xfdf_blob out nocopy blob);
--
 FUNCTION get_lookup_meaning
    (p_lookup_type VARCHAR2
    ,p_lookup_code VARCHAR2) RETURN VARCHAR2;
--
END PAY_KW_PAYROLL_REGISTER ;

/
