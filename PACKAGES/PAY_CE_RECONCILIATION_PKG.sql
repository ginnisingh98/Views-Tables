--------------------------------------------------------
--  DDL for Package PAY_CE_RECONCILIATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_CE_RECONCILIATION_PKG" AUTHID CURRENT_USER as
/* $Header: pycerecn.pkh 120.0 2005/05/29 03:57:50 appldev noship $ */

-- name
--   reconcile_payment
--
-- description
--   called from Oracle Cash Management to reconcile payments
--   from Oracle Payroll
--
-- parameters
--   p_payment_id         payment identifier to reconcile (assignment_action_id)
--   p_cleared_date       clearing date from bank statement
--   p_trx_amount         transaction amount (actual amount of payment)
--   p_trx_type           transaction type (PAYMENT or STOP)
--   p_last_updated_by    standard who column
--   p_last_update_login  standard who column
--   p_created_by         standard who column

procedure reconcile_payment(p_payment_id          number,
                            p_cleared_date        date,
                            p_trx_amount          number,
			    p_trx_type            varchar2,
                            p_last_updated_by     number,
                            p_last_update_login   number,
                            p_created_by          number);

-- name
--   update_reconciled_payment
--
-- description
--   marks payment as reconciled by insertion into pay_ce_reconciled_payments
--
-- parameters
--   p_payment_id         payment identifier to reconcile (assignment_action_id)
--   p_trx_amount         transaction amount (actual amount of payment)
--   p_base_trx_amount    transaction amount in bank base currency
--   p_trx_type           transaction type (PAYMENT or STOP)
--                        to previously reconciled payment
--   p_cleared_date       clearing date from bank statement
--   p_payment_status     ('C' or 'E') to indicate cleared (reconciled) or error

procedure update_reconciled_payment(p_payment_id      number,
                                    p_trx_amount      number,
				    p_base_trx_amount number,
				    p_trx_type        varchar2,
                                    p_cleared_date    date,
                                    p_payment_status  varchar2);


-- name
--   reverse_reconcile
--
-- description
--   unreconciles a previously reconciled payment
--
-- parameters
--   p_payment_id  payment identifier to unreconcile (assignment_action_id)

procedure reverse_reconcile(p_payment_id number);


-- name
--   payment_reconciled
--
-- description
--   returns true if specified payment has been reconciled
--
-- parameters
--   p_payment_id  payment identfier (assignment_action_id)

function payment_reconciled(p_payment_id number) return boolean;

-- name
--   payment_transaction_info
--
-- description
--   returns the value associated with the identifier
--
-- parameters
--   p_effective_date             - Effective date of the payroll action.
--   p_identifier_name            - Identifier's name
--   p_payroll_action_id          - Payroll action identifier
--   p_payment_type_id            - Payment type identifier
--   p_org_payment_method_id      - Organization payment method identifier
--   p_personal_payment_method_id - Personal Payment method identifier
--   p_assignment_action_id       - Assignment Action identifier for the mag tape process
--   p_pre_payment_id             - Pre Payment identifier
--   p_delimeter_string           - Delimiter string to be used for concatenated identifier.

function payment_transaction_info(p_effective_date   date,
                                  p_identifier_name   varchar2,
                                  p_payroll_action_id  number,
                                  p_payment_type_id   number,
                                  p_org_payment_method_id number,
                                  p_personal_payment_method_id  number,
                                  p_assignment_action_id number,
                                  p_pre_payment_id   number,
                                  p_delimiter_string  varchar2  default '/') return varchar2;

function payinfo(p_identifier varchar2,
                 p_assignment_action_id number)
return varchar2;
--
end pay_ce_reconciliation_pkg;

 

/
