--------------------------------------------------------
--  DDL for Package HR_PAYMENTS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_PAYMENTS" AUTHID CURRENT_USER as
/* $Header: pypaymnt.pkh 115.0 99/07/17 06:20:48 porting ship $ */
/*
 * ---------------------------------------------------------------------------
   Copyright (c) Oracle Corporation (UK) Ltd 1992.
   All Rights Reserved.
  --
  --
  PRODUCT
    Oracle*Payroll
  NAME
    hr_payments     (hrppm.pkh)
  NOTES
    Pre-payments validation procedures. Deals with DDL on:
    PAY_PAYMENT_TYPES
    PAY_ORG_PAYMENT_METHODS
    PAY_ORG_PAY_METHOD_USAGES
    PAY_PERSONAL_PAYMENT_METHODS
  PROCEDURES
    ppt_brui
  MODIFIED

    amcinnes          14-JUN-1993  Changes for change to PPT that whoever
                                   changed it should have done.
    amcinnes          20-DEC-1992  Added all other payments procedures
    amcinnes          16-NOV-1992  Created with ppt_brui
    rneale	      20-JUN-1994  Added match_currency.
    nbristow          24-OCT-1994  Added Header line
  --
 * ---------------------------------------------------------------------------
 */
--
procedure ppt_brui(allow_as_default in varchar2,
                   category in varchar2,
                   pre_validation_required in varchar2,
                   validation_days in number,
                   validation_value in varchar2);
--
procedure match_currency(type in varchar2,
                         opm_currency in varchar2,
                         def_balance in varchar2);
--
function check_account(account in varchar2, type in varchar2)
         return boolean;
--
function check_currency(type in varchar2, opm_currency in varchar2)
         return boolean;
--
function gen_balance(leg_code in varchar2)
         return number;
--
function check_prepay(opm_id in number, val_start_date in varchar2)
         return boolean;
--
function check_ppm(val_start_date in varchar2, opm_id in varchar2)
         return boolean;
--
function check_default(opm_id in varchar2, val_start_date in varchar2)
         return boolean;
--
--
function check_amt(percent in varchar2, amount in varchar2) return boolean;
--
function mt_checks(opm_id in varchar2,
                   val_start_date in varchar2,
                   account_id in varchar2) return boolean;
--
function unique_priority(in_priority in varchar2,
                         val_start_date in varchar2,
                         val_end_date in varchar2,
                         assignment in varchar2) return boolean;
--
function check_pp(ppm_id in varchar2,
                  val_start_date in varchar2) return boolean;
--
end hr_payments;

 

/
