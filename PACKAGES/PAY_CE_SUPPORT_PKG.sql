--------------------------------------------------------
--  DDL for Package PAY_CE_SUPPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CE_SUPPORT_PKG" AUTHID CURRENT_USER as
/* $Header: pyceinsp.pkh 115.4 2002/03/08 10:48:54 pkm ship     $ */

--  name
--    bank_segment_value
--
--  description
--    returns value of bank flexfield segment based on segment name
--    and legislation code.
--
--  parameters
--    p_external_account_id   bank account id. primary key
--                            of table pay_external_accounts
--    p_lookup_type           name of bank flexfield segment (e.g. 'BANK_NAME')
--    p_legislation_code      two letter legislation code ('US', 'GB' etc.)

function bank_segment_value(
  p_external_account_id in number,
  p_lookup_type         in varchar2,
  p_legislation_code    in varchar2) return varchar2;

pragma restrict_references(bank_segment_value, wnds);


-- name
--   pay_and_ce_licensed
--
-- description
--   returns true if both ce and pay are licensed on the
--   database.
--
-- parameters
--   none

function pay_and_ce_licensed return boolean;


-- name
--   session_date
--
-- description
--   returns effective date of current session
--
-- parameters
--   none

function session_date return date;

pragma restrict_references(session_date, wnds, wnps);


-- name
--   payment_status
--
-- description
--   returns status of specified payment (reconciled, errored, etc.)
--
-- parameters
--   p_payment_id  payment identifier (assignment_action_id)

function payment_status(p_payment_id in number) return varchar2;

function lookup_meaning(p_meaning in varchar2, p_code in varchar2) return varchar2;


end pay_ce_support_pkg;

 

/
