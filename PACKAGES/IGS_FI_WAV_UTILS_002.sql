--------------------------------------------------------
--  DDL for Package IGS_FI_WAV_UTILS_002
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_WAV_UTILS_002" AUTHID CURRENT_USER AS
/* $Header: IGSFI97S.pls 120.2 2005/10/31 10:27:48 appldev noship $ */
/************************************************************************
  Created By :  Umesh Udayaprakash
  Date Created By :  7/4/2005
  Purpose :  Generic util Pacakge for Waiver Functionality
            Created as part of FI234 - Tuition Waivers enh. Bug # 3392095
  Known limitations,enhancements,remarks:
  Change History
  Who                 When                What
 smadathi             28-Oct-2005   Bug 4704177: Enhancement for Tuition Waiver
                                    CCR. Added function to check for the Error Account = 'Y'

*************************************************************************/

  PROCEDURE call_charges_api( p_n_person_id         IN  hz_parties.party_id%TYPE,
                              p_v_fee_cal_type      IN  igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                              p_n_fee_ci_seq_number IN  igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                              p_v_waiver_name       IN  igs_fi_waiver_pgms.waiver_name%TYPE,
                              p_v_adj_fee_type      IN  igs_fi_fee_type.fee_type%TYPE,
                              p_v_currency_cd       IN  igs_fi_control.currency_cd%TYPE,
                              p_n_waiver_amt        IN  igs_fi_inv_int_all.invoice_amount%TYPE,
                              p_d_gl_date           IN  igs_fi_invln_int.gl_date%TYPE,
                              p_n_invoice_id        OUT NOCOPY igs_fi_inv_int.invoice_id%TYPE,
                              x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE call_credits_api(p_n_person_id         IN hz_parties.party_id%TYPE,
                             p_v_fee_cal_type      IN igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                             p_n_fee_ci_seq_number IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                             p_v_waiver_name       IN igs_fi_waiver_pgms.waiver_name%TYPE,
                             p_n_credit_type_id    IN igs_fi_credits.credit_id%TYPE,
                             p_v_currency_cd       IN igs_fi_control.currency_cd%TYPE,
                             p_n_waiver_amt        IN NUMBER,
                             p_d_gl_date           IN igs_fi_invln_int.gl_date%TYPE,
                             p_n_credit_id         OUT NOCOPY NUMBER,
                             x_return_status       OUT NOCOPY VARCHAR2);

  PROCEDURE reverse_waiver(p_n_source_credit_id  IN igs_fi_applications.credit_id%TYPE,
                           p_v_reversal_reason   IN igs_lookup_values.lookup_code%TYPE,
                           p_v_reversal_comments IN igs_fi_credits_all.reversal_comments%TYPE,
                           p_d_reversal_gl_date  IN DATE,
                           p_v_return_status     OUT NOCOPY VARCHAR2,
                           p_v_message_name      OUT NOCOPY VARCHAR2);


  FUNCTION get_waiver_reversal_amount(p_n_source_credit_id IN igs_fi_applications.credit_id%TYPE) RETURN NUMBER;

  FUNCTION check_stdnt_wav_assignment(p_n_person_id         IN hz_parties.party_id%TYPE,
                                      p_v_fee_type          IN igs_fi_f_typ_ca_inst.fee_type%TYPE,
                                      p_v_fee_cal_type      IN igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                                      p_n_fee_ci_seq_number IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE) RETURN BOOLEAN;

  PROCEDURE roll_over_wav_assign(p_rollover_rowid                IN VARCHAR2,
                                 p_v_stud_rollover_flag          IN VARCHAR2,
                                 p_n_dest_fee_ci_seq_number      IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                                 p_v_rollover_status             OUT NOCOPY VARCHAR2);

  PROCEDURE update_wav_assign_status(   p_v_fee_cal_type       IN  VARCHAR2,
                                        p_n_fee_ci_seq_number  IN  NUMBER,
                                        p_v_waiver_name        IN  VARCHAR2,
                                        p_v_new_status         IN  VARCHAR2,
                                        x_return_status        OUT NOCOPY VARCHAR2);

  FUNCTION check_chg_error_account  ( p_n_person_id         IN  hz_parties.party_id%TYPE,
                                      p_v_fee_type          IN  igs_fi_fee_type_all.fee_type%TYPE,
                                      p_v_fee_cal_type      IN  igs_ca_inst_all.cal_type%TYPE,
                                      p_n_fee_ci_seq_number IN  igs_ca_inst_all.sequence_number%TYPE
                                    ) RETURN NUMBER;



END igs_fi_wav_utils_002;

 

/
