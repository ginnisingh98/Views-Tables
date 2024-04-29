--------------------------------------------------------
--  DDL for Package PAY_SA_GOSI_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SA_GOSI_REPORTS" AUTHID CURRENT_USER AS
/* $Header: pysagosi.pkh 120.0.12000000.1 2007/01/18 01:14:36 appldev noship $ */
--
TYPE XMLRec IS RECORD(
TagName VARCHAR2(240),
TagValue VARCHAR2(240));
TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
vXMLTable tXMLTable;
vCtr NUMBER;
TYPE r_temp IS RECORD(
complaint_id NUMBER(15));
TYPE t_temp IS TABLE OF r_temp INDEX BY BINARY_INTEGER;
v_temp t_temp;
--PROCEDURE run_report
-- Procedure to Populate Saudi Workers Movement Data
procedure populate_workers_movement
	(   p_request_id               in  number,
	    p_report                   in  varchar2,
	    p_business_group_id        in  number,
	    p_org_structure_version_id in  number DEFAULT NULL,
	    p_organisation_id          in  number,
	    p_form_type		in	varchar2  DEFAULT NULL,
	    p_effective_date	in	varchar2,
	    p_assignment_id	in	number    DEFAULT NULL,
	    p_assignment_set_id in      number    DEFAULT NULL,
	    l_xfdf_blob OUT NOCOPY BLOB);
-- Procedure to populate Monthly Contributions
procedure populate_monthly_contributions
  (p_request_id                number
   ,p_report                   varchar2
   ,p_business_group_id        number
   ,p_org_structure_version_id number default null
   ,p_organisation_id          number
   ,p_effective_month          varchar2
   ,p_effective_year           varchar2
   ,p_arrears                  number default 0
   ,p_penalty_charge           number default 0
   ,p_discount                 number default 0
   ,p_payment_method           varchar2 default null
   ,l_xfdf_blob OUT NOCOPY BLOB);-- Procedure to populate New and Terminated Workers
PROCEDURE populate_new_and_term_wrks
  (p_request_id                number
   ,p_report                   varchar2
   ,p_business_group_id        number
   ,p_org_structure_version_id number DEFAULT NULL
   ,p_organisation_id          number
   ,p_effective_month          varchar2
   ,p_effective_year           varchar2
  ,l_xfdf_blob OUT NOCOPY BLOB);-- Procedure to Write into XML file
/*PROCEDURE WritetoXML(
         p_request_id in number,
 p_report in varchar2,
 p_output_fname out nocopy varchar2);*/
--Procedure Sum
PROCEDURE populate_sum(
           p_request_id IN NUMBER
          ,p_from_date   IN varchar2
          ,p_to_date     IN varchar2
          ,p_output_fname OUT NOCOPY VARCHAR2);
/*PROCEDURE WriteXMLvalues(p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2);*/
PROCEDURE clob_to_blob (p_clob clob,
                        p_blob IN OUT NOCOPY Blob);
PROCEDURE WritetoCLOB (p_xfdf_blob out nocopy blob);



PROCEDURE fetch_pdf_blob (p_report in varchar2, p_pdf_blob OUT NOCOPY BLOB);
END PAY_SA_GOSI_REPORTS;

 

/
