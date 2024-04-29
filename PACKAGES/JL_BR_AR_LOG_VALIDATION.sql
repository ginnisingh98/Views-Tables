--------------------------------------------------------
--  DDL for Package JL_BR_AR_LOG_VALIDATION
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_BR_AR_LOG_VALIDATION" AUTHID CURRENT_USER AS
/*$Header: jlbrrvls.pls 120.5.12010000.2 2009/04/06 05:38:33 gkumares ship $*/

PROCEDURE logical_validation (
  p_file_control              IN     jl_br_ar_ret_interface_all.file_control%TYPE,
  p_ent_seq_num               IN      jl_br_ar_ret_interface_all.ENTRY_SEQUENTIAL_NUMBER%TYPE, -- Bug#8331293
  p_called_from               IN     VARCHAR2, -- Bug#8331293
  p_bank_number               IN     jl_br_ar_ret_interface_all.bank_number%TYPE,
  p_company_code              IN     jl_br_ar_ret_interface_all.company_code%TYPE,
  p_inscription_number        IN     jl_br_ar_ret_interface_all.inscription_number%TYPE,
  p_bank_occurrence_code      IN     jl_br_ar_ret_interface_all.bank_occurrence_code%TYPE,
  p_occurrence_date           IN     jl_br_ar_ret_interface_all.occurrence_date%TYPE,
  p_company_use               IN     jl_br_ar_ret_interface_all.company_use%TYPE,
  p_your_number               IN     jl_br_ar_ret_interface_all.your_number%TYPE,
  p_customer_name             IN     jl_br_ar_ret_interface_all.customer_name%TYPE,
  p_trade_note_amount         IN     jl_br_ar_ret_interface_all.trade_note_amount%TYPE,
  p_credit_amount             IN     jl_br_ar_ret_interface_all.credit_amount%TYPE,
  p_interest_amount_received  IN     jl_br_ar_ret_interface_all.interest_amount_received%TYPE,
  p_discount_amount           IN     jl_br_ar_ret_interface_all.discount_amount%TYPE,
  p_abatement_amount          IN     jl_br_ar_ret_interface_all.abatement_amount%TYPE,
  p_bank_party_id                OUT NOCOPY NUMBER,
  p_error_code                IN OUT NOCOPY VARCHAR2 );

END JL_BR_AR_LOG_VALIDATION;

/
