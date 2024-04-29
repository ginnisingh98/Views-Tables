--------------------------------------------------------
--  DDL for Package PER_NL_BANK_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PER_NL_BANK_DETAILS_PKG" AUTHID CURRENT_USER AS
-- $Header: penlbank.pkh 120.0.12010000.2 2009/11/27 09:48:40 dchindar ship $
--
-- Validate the bank account number
--
FUNCTION validate_account_number
(accno IN VARCHAR2) RETURN NUMBER;

 FUNCTION validate_account_entered
(p_acc_no        IN VARCHAR2,
 p_is_iban_acc   IN varchar2 ) RETURN NUMBER;

end per_nl_bank_details_pkg;


/
