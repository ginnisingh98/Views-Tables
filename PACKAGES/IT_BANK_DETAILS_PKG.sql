--------------------------------------------------------
--  DDL for Package IT_BANK_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IT_BANK_DETAILS_PKG" AUTHID CURRENT_USER AS
 -- $Header: peitbank.pkh 120.1 2007/12/13 12:42:39 rbabla ship $
 --
 --
 -- Validates the bank account number.
 --
 -- The format is as follows CIN-ABI-CAB-Acc where
 --
 -- CIN = check digit
 -- ABI = 5 digits representing the bank
 -- CAB = 5 digits representing the branch
 -- Acc = up to 12 characters representing the account no
 -- Validate IBAN account number too
 FUNCTION validate_account_number
 (p_account_number IN VARCHAR2,
  p_is_iban_acc IN VARCHAR2) RETURN NUMBER;
END it_bank_details_pkg;

/
