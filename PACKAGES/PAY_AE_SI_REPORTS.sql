--------------------------------------------------------
--  DDL for Package PAY_AE_SI_REPORTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_AE_SI_REPORTS" AUTHID CURRENT_USER AS
/* $Header: pyaesirp.pkh 120.1.12000000.1 2007/01/17 15:24:42 appldev noship $ */
  PROCEDURE FORM1
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );
    --
  PROCEDURE FORM2
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );

  PROCEDURE FORM6
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );
    --
  PROCEDURE FORM7
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );
    --
  PROCEDURE MCP
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_employer_id             NUMBER
    ,p_effective_month         VARCHAR2
    ,p_effective_year          VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );
    --
  PROCEDURE MCF
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
    --
  PROCEDURE WritetoCLOB
    (p_xfdf_blob OUT NOCOPY BLOB);
    --
  PROCEDURE fetch_pdf_blob
    (p_report    IN  VARCHAR2
    ,p_pdf_blob  OUT NOCOPY BLOB);
    --
  FUNCTION get_lookup_meaning
    (p_lookup_type VARCHAR2
    ,p_lookup_code VARCHAR2) RETURN VARCHAR2;
	--
  TYPE XMLRec IS RECORD
    (TagName VARCHAR2(240)
    ,TagValue VARCHAR2(240));
    --
  TYPE tXMLTable IS TABLE OF XMLRec INDEX BY BINARY_INTEGER;
  vXMLTable tXMLTable;
  vCtr NUMBER;
  --
END pay_ae_SI_reports;

 

/
