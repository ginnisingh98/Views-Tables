--------------------------------------------------------
--  DDL for Package PAY_KW_ANNUAL_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KW_ANNUAL_REPORTS" AUTHID CURRENT_USER AS
/* $Header: pykwyear.pkh 120.1.12010000.2 2012/11/05 10:11:57 bkeshary ship $ */
  PROCEDURE report55
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );

    --------------------------------------------------------------------------

  PROCEDURE report56
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,p_assignment_id	       NUMBER DEFAULT NULL
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );

    --------------------------------------------------------------------------

  PROCEDURE report103
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,p_employee_id	       NUMBER DEFAULT NULL
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );

  PROCEDURE clob_to_blob
    (p_clob clob
    ,p_blob IN OUT NOCOPY Blob);

  PROCEDURE WritetoCLOB
    (p_xfdf_blob OUT NOCOPY BLOB);

  PROCEDURE fetch_pdf_blob
    (p_report    IN  VARCHAR2,
     p_effective_month varchar2,
     p_effective_year varchar2,
    p_pdf_blob  OUT NOCOPY BLOB);

    --
  FUNCTION get_lookup_meaning
    (p_lookup_type VARCHAR2
    ,p_lookup_code VARCHAR2) RETURN VARCHAR2;
	--


  TYPE XMLRec IS RECORD
    (TagName VARCHAR2(240)
    ,TagValue VARCHAR2(240));

  TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
  vXMLTable tXMLTable;
  vCtr NUMBER;

PROCEDURE WritetoXML(
         p_request_id in number,
 p_report in varchar2,
 p_output_fname out nocopy varchar2);

PROCEDURE WriteXMLvalues(p_l_fp utl_file.file_type,p_tagname IN VARCHAR2, p_value IN VARCHAR2);


END pay_kw_annual_reports;

/
