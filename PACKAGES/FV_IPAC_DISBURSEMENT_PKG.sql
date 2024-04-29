--------------------------------------------------------
--  DDL for Package FV_IPAC_DISBURSEMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FV_IPAC_DISBURSEMENT_PKG" AUTHID CURRENT_USER AS
/* $Header: FVIPDISS.pls 120.9 2006/02/24 03:54:33 bnarang ship $*/

  PROCEDURE main
  (
    p_errbuf               OUT NOCOPY VARCHAR2,
    p_retcode              OUT NOCOPY NUMBER,
    p_data_file_name       IN  VARCHAR2,
    p_agency_location_code IN  VARCHAR2,
    p_payment_bank_acct_id IN  NUMBER,
    p_payment_profile_id        IN  NUMBER,
    p_payment_document_id       IN  NUMBER
  );
  PROCEDURE upd_ia_main
  (
    errbuf OUT NOCOPY VARCHAR2,
    retcode OUT NOCOPY VARCHAR2,
    invoice_creation_date_low VARCHAR2 ,
    invoice_creation_date_high VARCHAR2
  );
END fv_ipac_disbursement_pkg;

 

/
