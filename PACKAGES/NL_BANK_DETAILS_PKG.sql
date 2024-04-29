--------------------------------------------------------
--  DDL for Package NL_BANK_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."NL_BANK_DETAILS_PKG" AUTHID CURRENT_USER AS
-- $Header: penlbank.pkh 115.3 2001/12/10 05:25:03 pkm ship        $
--
-- Validate the bank account number
--
FUNCTION validate_account_number
(accno IN VARCHAR2) RETURN NUMBER;

end nl_bank_details_pkg;


 

/
