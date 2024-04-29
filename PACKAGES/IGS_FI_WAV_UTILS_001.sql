--------------------------------------------------------
--  DDL for Package IGS_FI_WAV_UTILS_001
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_WAV_UTILS_001" AUTHID CURRENT_USER AS
/* $Header: IGSFI95S.pls 120.0 2005/09/09 20:20:45 appldev noship $ */

  /******************************************************************
   Created By      :   Anji Yedubati
   Date Created By :   05-JUL-2005
   Purpose         :   Waiver Utility Package for the generic routines,
                       get_eligible_waiver_amt and apply_waivers, which are
                       required for waiver processing
                       Created as part of FI234 - Tuition Waivers enh. Bug # 3392095

   Known limitations,enhancements,remarks:

   Change History

   WHO         WHEN          WHAT
   pathipat    16-Aug-2005   Enh 3392095 - Tuition Waivers Enh
                             Added procedure create_ss_waiver_transactions
  ***************************************************************** */

  PROCEDURE get_eligible_waiver_amt(
    p_n_person_id          IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type       IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number  IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name        IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_target_fee_type    IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_v_waiver_method_code IN  igs_fi_waiver_pgms.waiver_method_code%TYPE,
    p_v_waiver_mode_code   IN  igs_fi_waiver_pgms.waiver_mode_code%TYPE,
    p_n_source_invoice_id  IN  igs_fi_inv_int_all.invoice_id%TYPE,
    x_return_status        OUT NOCOPY VARCHAR2,
    x_eligible_amount      OUT NOCOPY NUMBER );

  PROCEDURE apply_waivers(
    p_n_person_id          IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type       IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number  IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name        IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_target_fee_type    IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_v_adj_fee_type       IN  igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_v_waiver_method_code IN  igs_fi_waiver_pgms.waiver_method_code%TYPE,
    p_v_waiver_mode_code   IN  igs_fi_waiver_pgms.waiver_mode_code%TYPE,
    p_n_source_credit_id   IN  igs_fi_credits_all.credit_id%TYPE,
    p_n_source_invoice_id  IN  igs_fi_inv_int_all.invoice_id%TYPE,
    p_v_currency_cd        IN  igs_fi_inv_int_all.currency_cd%TYPE,
    p_d_gl_date            IN  igs_fi_invln_int.gl_date%TYPE,
    x_return_status        OUT NOCOPY VARCHAR2 );

  PROCEDURE create_ss_waiver_transactions(
    p_n_person_id          IN  igs_pe_person_base_v.person_id%TYPE,
    p_v_fee_cal_type       IN  igs_fi_waiver_pgms.fee_cal_type%TYPE,
    p_n_fee_ci_seq_number  IN  igs_fi_waiver_pgms.fee_ci_sequence_number%TYPE,
    p_v_waiver_name        IN  igs_fi_waiver_pgms.waiver_name%TYPE,
    p_v_target_fee_type    IN  igs_fi_waiver_pgms.target_fee_type%TYPE,
    p_v_adj_fee_type       IN  igs_fi_waiver_pgms.adjustment_fee_type%TYPE,
    p_n_credit_type_id     IN  igs_fi_waiver_pgms.credit_type_id%TYPE,
    p_v_waiver_method_code IN  igs_fi_waiver_pgms.waiver_method_code%TYPE,
    p_v_waiver_mode_code   IN  igs_fi_waiver_pgms.waiver_mode_code%TYPE,
    p_n_source_invoice_id  IN  igs_fi_inv_int_all.invoice_id%TYPE,
    p_n_waiver_amount      IN  igs_fi_credits_all.amount%TYPE,
    p_v_currency_cd        IN  igs_fi_inv_int_all.currency_cd%TYPE,
    p_d_gl_date            IN  igs_fi_invln_int_all.gl_date%TYPE,
    x_return_status        OUT NOCOPY VARCHAR2);

END igs_fi_wav_utils_001;

 

/
