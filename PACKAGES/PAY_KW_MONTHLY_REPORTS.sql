--------------------------------------------------------
--  DDL for Package PAY_KW_MONTHLY_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KW_MONTHLY_REPORTS" AUTHID CURRENT_USER AS
/* $Header: pykwmonr.pkh 120.1.12010000.4 2013/09/25 10:39:09 dakhuran ship $ */
   PROCEDURE report166
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,p_arrears                 NUMBER DEFAULT 0
    ,p_arrears2                NUMBER DEFAULT 0  /* changes in 166 - Aug 2012 */
    ,p_arrears3                NUMBER DEFAULT 0
    ,p_arrears6                NUMBER DEFAULT 0 /*Bug 17495527 (Kuwait Report 166)  changes */
    ,p_not_in_rep_167          NUMBER DEFAULT 0
    ,p_add_supp_insu_1997      NUMBER DEFAULT 0
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );

  PROCEDURE report167
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );
    --,p_output_fname OUT NOCOPY VARCHAR2);

  PROCEDURE report167_2006
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );

  PROCEDURE report168
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );
  PROCEDURE clob_to_blob
    (p_clob clob
    ,p_blob IN OUT NOCOPY Blob);
  PROCEDURE WritetoCLOB
    (p_xfdf_blob OUT NOCOPY BLOB);
  PROCEDURE fetch_pdf_blob
    (p_report    IN  VARCHAR2
    ,p_effective_month     IN  VARCHAR2
    ,p_effective_year      IN  VARCHAR2
    ,p_pdf_blob  OUT NOCOPY BLOB);
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


END pay_kw_monthly_reports;

/
