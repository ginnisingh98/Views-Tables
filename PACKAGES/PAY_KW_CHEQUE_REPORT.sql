--------------------------------------------------------
--  DDL for Package PAY_KW_CHEQUE_REPORT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_KW_CHEQUE_REPORT" AUTHID CURRENT_USER AS
/* $Header: pykwchqr.pkh 120.0.12000000.1 2007/02/21 11:21:43 spendhar noship $ */

  PROCEDURE CHEQUE_LISTING
    (p_request_id              NUMBER
    ,p_report                  VARCHAR2
    ,p_business_group_id       NUMBER
    ,p_pact_id                 NUMBER
    ,p_sort	               VARCHAR2
    ,l_xfdf_blob               OUT NOCOPY BLOB
    );
    --

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
END pay_kw_cheque_report;

 

/
