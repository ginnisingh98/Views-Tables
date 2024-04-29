--------------------------------------------------------
--  DDL for Package PAY_SA_TRAN_IDENTIFIERS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PAY_SA_TRAN_IDENTIFIERS" AUTHID CURRENT_USER AS
/* $Header: pysatran.pkh 120.0.12010000.1 2009/07/23 07:05:05 bkeshary noship $ */



   --------------------------------------------------------------------------
  --                                                                      --
  -- Name           : GET_EFT_RECON_DATA                       --
  -- Type           : FUNCTION                                            --
  -- Access         : Public                                              --
  -- Description    : Function to identify the batch transaction          --
  --                  identifiers for reconciliation                                        --
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
  -- 12.0  17-Jul-2009    bkeshary  Initial Version                       --
  --------------------------------------------------------------------------
 FUNCTION get_eft_recon_data(p_effective_date	DATE,
					           p_identifier_name VARCHAR2,
					           p_payroll_action_id		NUMBER,
					           p_payment_type_id		NUMBER,
					           p_org_payment_method_id	NUMBER,
					           p_personal_payment_method_id	NUMBER,
					           p_assignment_action_id	NUMBER,
					           p_pre_payment_id		NUMBER,
					           p_delimiter_string   	VARCHAR2) RETURN VARCHAR2;
 END pay_sa_tran_identifiers;

/
