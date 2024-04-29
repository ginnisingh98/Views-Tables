--------------------------------------------------------
--  DDL for Package AP_WEB_CC_VALIDATIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_WEB_CC_VALIDATIONS_PKG" AUTHID CURRENT_USER as
/* $Header: apwccvls.pls 120.4.12010000.4 2010/04/07 12:26:46 meesubra ship $ */

  ----------------------------------------------------------------
  -- This package has four sets of procedures/functions
  -- 1) Define the "set" of transaction records to process
  -- 2) Defaulting/Conversion routines
  -- 3) Validation routines
  -- 4) Utility routines
  --
  -- (1) "Set" routines
  -- Of these, 1-3 work together. The "set" (1) routines are used to define the
  -- set of credit card transaction records to process for steps (2) and (3).
  -- These functions include:
  --   o set_all_row_set
  --   o set_row_set
  --
  -- (2) Defaulting/Conversion routines
  -- These routines are used to default or convert values for the credit card
  -- transaction records. They include the following functions:
  --   o default_org_id
  --   o set_request_id
  --   o default_folio_type
  --   o default_country_code
  --   o default_payment_flag
  --   o convert_currency_code
  --   o get_locations
  --   o default_merchant_name
  --
  -- (3) Validation routines
  -- This performs individual validation checks. Each function is responsible
  -- validating one piece of information.
  -- They include the following functions:
  --   o duplicate_trx
  --   o invalid_billed_amount
  --   o invalid_billed_currency_code
  --   o invalid_billed_date
  --   o invalid_card_number
  --   o invalid_merchant_name
  --   o invalid_posted_currency_code
  --   o invalid_trx_amount
  --   o invalid_trx_date
  --   o check_employee_termination
  --   o valid_trx
  --   o invalid_sic_code
  --  (valid_trx is a special one and this routine must be the last routine to
  --   be called from (2) and (3)).
  --
  -- NOTE: All routines in (2) and (3) take a parameter - p_valid_only. If you
  --       pass true for this value, it will only perform the operation on
  --       the subset of records that have not yet failed any validation errors.
  -- NOTE2: Routines in (1) return the number of rows in the set.
  --        Routines in (2) return the number of rows that they defaulted/converted
  --        Routines in (3) return the number of rows that failed validation
  --
  -- (4) Utility routines
  -- These functions include:
  --    o get_min_date
  --    o assign_employee
  ------------------------------------------------------------------------------

  --------------------------------- (1) ----------------------------------------
  -- Sets the context to all credit card transactions.
  -- (This should probably used sparingly since it really chooses everything
  --  - even across orgs)
  function set_all_row_set return number;
  -- Sets the context to the following criteria
  -- (start/end dates are on the transaction date)
  function set_row_set(p_request_id in number,
                       p_card_program_id in number,
                       p_start_date in date,
                       p_end_date in date) return number;
  -- Sets the context to one specific transaction
  function set_row_set(p_trx_id in number) return number;

  --------------------------------- (2) ----------------------------------------
  -- Default org_id - based on card program
  function default_org_id(p_valid_only in boolean) return number;
  --function set_request_id(p_request_id in number, p_valid_only in boolean) return number;
  function set_request_id(p_request_id in number) return number;
  function set_validate_request_id(p_request_id in number) return number;
  -- Default folio type using folio type mapping rules
  function default_folio_type(p_valid_only in boolean) return number;
  -- Default Detail folio type using Detail folio type mapping rules
  function default_detail_folio_type(p_valid_only in boolean) return number;
  -- Default eLocation country code using elocation mapping rules
  function default_country_code(p_valid_only in boolean) return number;
  -- Assign payment flags (based on card specific info)
  function default_payment_flag(p_valid_only in boolean) return number;
  -- Convert numeric currency codes into FND currency codes
  function convert_currency_code(p_valid_only in boolean) return number;
  -- eLocation integration
  function get_locations(p_valid_only in boolean) return number;
  -- Stamp CC Transactions with Payment Scenario of Card Program
  function set_payment_scenario(p_valid_only in boolean) return number;

  --------------------------------- (3) ----------------------------------------
  -- Check for duplication transactions (card program, card number, reference number)
  function duplicate_trx(p_valid_only in boolean) return number;
  -- Check for non-zero, non-null billed amount
  function invalid_billed_amount(p_valid_only in boolean) return number;
  -- Check for valid billed currency code
  function invalid_billed_currency_code(p_valid_only in boolean) return number;
  -- Check for non-null billed date
  function invalid_billed_date(p_valid_only in boolean) return number;
  -- Check for inactive card number
  function inactive_card_number(p_valid_only in boolean) return number;
  -- Check for existing card number
  function invalid_card_number(p_valid_only in boolean) return number;
  -- Check for non-null merchant name
  function invalid_merchant_name(p_valid_only in boolean) return number;
  -- Check for valid posted currency code
  function invalid_posted_currency_code(p_valid_only in boolean) return number;
  -- Check for non-zero, non-null transaction amount
  function invalid_trx_amount(p_valid_only in boolean) return number;
  -- Check for non-null transaction date
  function invalid_trx_date(p_valid_only in boolean) return number;
  -- Check for transaction date after termination date
  function check_employee_termination(p_valid_only in boolean) return number;

  -- Marks the rows that are still valid as valid, and returns the number of
  -- rows that are still valid
  function valid_trx return number;

  -- sic_code is required if transaction_type code is 10,11,20,22,80
  -- sic_code Must be equal to 6010, 6011, 6012, 6050 or 6051 if the
  -- transaction type code is 20,22,80
  -- The validation is required for Visa VCF 4.0 Format
  function invalid_sic_code(p_valid_only in boolean) return number;
  --------------------------------- (4) ----------------------------------------
  -- Returns the lesser of date1 and date2. Null values are considered to
  -- be a date in the infinite future.
  function get_min_date(date1 in date, date2 in date) return date;
  -- Assign the employee to the card and activate it.
  procedure assign_employee(p_card_id in number, p_employee_id in number, p_full_name in varchar2);
  procedure assign_employee(p_card_id in number, p_employee_id in number);
  -- Check to see if a unique candidate exists for the card.
  -- If one exists, assign the employee to the card and activate it.


  function validate_trx_detail_amount return number;


  --------------------------------- (2) ----------------------------------------
  -- Default merchant name for AMEX for trxn types 01,02,03,06,09,10,11,12
  -- based on card program
  function default_merchant_name(p_valid_only in boolean) return number;

  function delete_invalid_rows(p_valid_only in boolean, card_program_id in number ) return number;

  function duplicate_global_trx(p_valid_only in boolean) return NUMBER;
END ap_web_cc_validations_pkg;

/
