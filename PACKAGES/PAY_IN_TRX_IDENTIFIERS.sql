--------------------------------------------------------
--  DDL for Package PAY_IN_TRX_IDENTIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_IN_TRX_IDENTIFIERS" AUTHID CURRENT_USER AS
/* $Header: pyintrx.pkh 120.0.12010000.2 2009/07/29 07:35:05 rsaharay noship $ */

  --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : BATCH_TRANSACTION_IDENTIFIERS                       --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : Function to identify the batch transaction          --
  --                  identifiers                                         --
  --                                                                      --
  -- Parameters     :                                                     --
  --             IN : p_effective_date              DATE                  --
  --                  p_identifier_name             VARCHAR2              --
  --                  p_payroll_action_id           NUMBER                --
  --                  p_payment_type_id             NUMBER                --
  --                  p_org_payment_method_id       NUMBER                --
  --                  p_personal_payment_method_id  NUMBER                --
  --                  p_assignment_action_id        NUMBER                --
  --                  p_pre_payment_id              NUMBER                --
  --                  p_delimiter_string            VARCHAR2              --
  --                                                                      --
  --            OUT : N/A                                                 --
  --                                                                      --
  -- Change History :                                                     --
  --------------------------------------------------------------------------
  -- Rev#  Date           Userid    Description                           --
  --------------------------------------------------------------------------
  -- 12.0  01-Jun-2009    rsaharay  Initial Version                       --
  --------------------------------------------------------------------------

  FUNCTION batch_transaction_identifiers
	(
	  p_effective_date              DATE
	, p_identifier_name             VARCHAR2
	, p_payroll_action_id           NUMBER
	, p_payment_type_id             NUMBER
	, p_org_payment_method_id       NUMBER
	, p_personal_payment_method_id  NUMBER
	, p_assignment_action_id        NUMBER
	, p_pre_payment_id              NUMBER
	, p_delimiter_string            VARCHAR2
	)
	RETURN VARCHAR2 ;
  --
  END pay_in_trx_identifiers;

/
