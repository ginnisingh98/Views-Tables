--------------------------------------------------------
--  DDL for Package IGS_FI_GEN_008
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_GEN_008" AUTHID CURRENT_USER AS
/* $Header: IGSFI88S.pls 120.3 2006/05/16 22:58:52 abshriva ship $ */
/***********************************************************************************************

  Created By     :  shtatiko
  Date Created By:  25-AUG-2003 (Created as part of Enh# 3045007, Payment Plans)
  Purpose        :  This package contains number of generic procedures called from various places
                    for Payment Plans Funtionality.


  Known limitations,enhancements,remarks:
  Change History
  Who           When            What
  abshriva      17-May-2006     Bug 5113295 - Added function chk_unit_prg_transfer
  uudayapr      8-Oct-2005       BUG 4660773 Added the Function mask_card_number for masking the CC Number
  agairola      27-Sep-2005     Bug # 4625955 Added new PLSQL procedure chk_spa_rec_exists
  svuppala      16-May-2005     Bug # 4226849 Added New PLSQL function which will return the latest standard
                                balance of the student for the personid provided as input to it.
  bannamal      14-Apr-2004     Bug#4297359 ER Registration fee issue.
                                Added the parameter p_v_nonzero_billable_cp_flag to the function
                                get_complete_withdr_ret_amt.
  pathipat      03-Sep-2004     Enh 3880438 - Retention Enhancements
                                Added new functions.
  rmaddipa      26-Jul-2004     Enh#3787816  Added  chk_chg_adj as part of Manual Reversal Build
  uudayapr       20-oct-2003     Enh#3117341 Added get_invoice_number fuction as a part of
                                audit and special Fees Build.
  shtatiko      25-AUG-2003     Enh# 3045007, Created this package.
***********************************************************************************************/

  -- Procedure to get Payment Plan Details
  PROCEDURE get_plan_details( p_n_person_id IN NUMBER,           /* Person Id */
                              p_n_act_plan_id OUT NOCOPY NUMBER,        /* Active Payment Plan Id */
                              p_v_act_plan_name OUT NOCOPY VARCHAR2     /* Active Payment Plan Name */
                            );

  -- Fuction to get Balance Amount for a given Payment Plan as of given date.
  FUNCTION get_plan_balance( p_n_act_plan_id IN NUMBER,                     /* Active Payment Plan Id */
                             p_d_effective_date IN DATE DEFAULT NULL        /* Effective Date */
                           ) RETURN NUMBER;

  -- Fucntion to check whether a give Payment Plan is active or not.
  FUNCTION chk_active_pay_plan( p_n_person_id IN NUMBER ) RETURN VARCHAR2;

  -- Function to get First Installment Date.
  FUNCTION get_start_date ( p_d_start_date IN DATE,                         /* Start Date */
                            p_n_due_day IN NUMBER DEFAULT NULL,             /* Due Day, if set in the Payment Plan Template */
                            p_v_last_day IN VARCHAR2,                       /* Last Day of the month, if set in the Payment Plan Template */
                            p_n_offset_days IN NUMBER DEFAULT NULL          /* Offset Days as specified in the Payment Plan Template */
                          ) RETURN DATE;

  -- Function that return Party Number for a given Party Id
  FUNCTION get_party_number ( p_n_party_id IN NUMBER ) RETURN VARCHAR2;

  --function for getting the charge number for the invoice id
  FUNCTION get_invoice_number ( p_n_invoice_id IN PLS_INTEGER ) RETURN VARCHAR2;

  --Procedure for checking whether a charge is declared or reversed
  PROCEDURE chk_chg_adj( p_n_person_id     IN  hz_parties.party_id%TYPE,
                         p_v_location_cd   IN  igs_fi_fee_as_items.location_cd%TYPE,
                         p_v_course_cd     IN  igs_ps_ver.course_cd%TYPE,
                         p_v_fee_cal_type  IN  igs_fi_f_typ_ca_inst.fee_cal_type%TYPE,
                         p_v_fee_cat       IN  igs_fi_fee_as_items.fee_cat%TYPE,
                         p_n_fee_ci_sequence_number IN igs_fi_f_typ_ca_inst.fee_ci_sequence_number%TYPE,
                         p_v_fee_type      IN  igs_fi_fee_type.fee_type%TYPE,
                         p_n_uoo_id        IN  igs_ps_unit_ofr_opt.uoo_id%TYPE,
                         p_v_transaction_type IN igs_fi_inv_int_all.transaction_type%TYPE,
                         p_n_invoice_id    IN  igs_fi_inv_int_all.invoice_id%TYPE,
                         p_v_invoice_num   OUT NOCOPY  igs_fi_inv_int_all.invoice_number%TYPE,
                         p_b_chg_decl_rev  OUT NOCOPY BOOLEAN
                        );

  -- Procedure to obtain values of columns retention_level_code and complete_ret_flag from table igs_fi_f_typ_ca_inst
  -- to be used in determing Retention Amount.
  PROCEDURE get_retention_params( p_v_fee_cal_type            IN igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                                  p_n_fee_ci_sequence_number  IN igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE,
                                  p_v_fee_type                IN igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                                  p_v_ret_level               OUT NOCOPY igs_fi_f_typ_ca_inst_all.retention_level_code%TYPE,
                                  p_v_complete_withdr_ret     OUT NOCOPY igs_fi_f_typ_ca_inst_all.complete_ret_flag%TYPE);

  -- Function to determine the Retention Amount when the Retention Level is set to Teaching Period
  FUNCTION get_teach_retention( p_v_fee_cal_type             IN igs_fi_tp_ret_schd.fee_cal_type%TYPE,
                                p_n_fee_ci_sequence_number   IN igs_fi_tp_ret_schd.fee_ci_sequence_number%TYPE,
                                p_v_fee_type                 IN igs_fi_tp_ret_schd.fee_type%TYPE,
                                p_v_teach_cal_type           IN igs_fi_tp_ret_schd.teach_cal_type%TYPE,
                                p_n_teach_ci_sequence_number IN igs_fi_tp_ret_schd.teach_ci_sequence_number%TYPE,
                                p_d_effective_date           IN DATE,
                                p_n_diff_amount              IN NUMBER) RETURN NUMBER;

  -- Function to determine the Retention Amount when the Retention Level is set to Fee Period
  FUNCTION get_fee_retention_amount(p_v_fee_cat                IN igs_fi_fee_ret_schd.fee_cat%TYPE,
                                    p_v_fee_cal_type           IN igs_fi_fee_ret_schd.fee_cal_type%TYPE,
                                    p_n_fee_ci_sequence_number IN igs_fi_fee_ret_schd.fee_ci_sequence_number%TYPE,
                                    p_v_fee_type               IN igs_fi_fee_ret_schd.fee_type%TYPE,
                                    p_n_diff_amount            IN NUMBER) RETURN NUMBER;


  -- Function to determine the Retention Amount when the Complete Withdrawal Retention Checkbox is checked for the FTCI
  FUNCTION get_complete_withdr_ret_amt( p_n_person_id                IN igs_en_su_attempt.person_id%TYPE,
                                        p_v_course_cd                IN igs_en_su_attempt.course_cd%TYPE,
                                        p_v_load_cal_type            IN igs_ca_inst.cal_type%TYPE,
                                        p_n_load_ci_sequence_number  IN igs_ca_inst.sequence_number%TYPE,
                                        p_n_diff_amount              IN NUMBER,
                                        p_v_fee_type                 IN igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                                        p_v_nonzero_billable_cp_flag  IN igs_fi_f_typ_ca_inst_all.nonzero_billable_cp_flag%TYPE ) RETURN NUMBER;

  -- Function to determine the Retention Amount for a Non-Standard Unit Section
  FUNCTION get_ns_usec_retention(p_n_uoo_id            IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                                 p_v_fee_type          IN igs_fi_fee_type.fee_type%TYPE,
                                 p_d_effective_date    IN DATE,
                                 p_n_diff_amount       IN NUMBER) RETURN NUMBER;

  -- Function to determine the Retention Amount for Special Fees
  FUNCTION get_special_retention_amt(p_n_uoo_id                  IN igs_ps_unit_ofr_opt_all.uoo_id%TYPE,
                                     p_v_fee_cal_type            IN igs_fi_f_typ_ca_inst_all.fee_cal_type%TYPE,
                                     p_n_fee_ci_sequence_number  IN igs_fi_f_typ_ca_inst_all.fee_ci_sequence_number%TYPE,
                                     p_v_fee_type                IN igs_fi_f_typ_ca_inst_all.fee_type%TYPE,
                                     p_d_effective_date          IN DATE,
                                     p_n_diff_amount             IN NUMBER) RETURN NUMBER;

   -- function to return the latest standard balance of the student for the personid provided
   FUNCTION get_std_balance(p_partyid  IN igs_fi_balances.party_id%TYPE) RETURN NUMBER;

-- Procedure for checking if Term Record exists
   PROCEDURE chk_spa_rec_exists(p_n_person_id      IN  igs_en_stdnt_ps_att.person_id%TYPE,
                                p_v_course_cd      IN  igs_en_stdnt_ps_att.course_cd%TYPE,
		                p_v_load_cal_type  IN  igs_ca_inst.cal_type%TYPE,
			        p_n_load_ci_seq    IN  igs_ca_inst.sequence_number%TYPE,
			        p_v_fee_cat        IN  igs_fi_fee_cat.fee_cat%TYPE,
				p_v_status         OUT NOCOPY VARCHAR2,
				p_v_message        OUT NOCOPY VARCHAR2);

--Function for masking the Credit Card Number
  FUNCTION mask_card_number( p_credit_card IN VARCHAR2 )  RETURN VARCHAR2;

  -- Function to check if the Unit in context has been part of a Program Transfer or not.
  -- Returns Y or N
  FUNCTION chk_unit_prg_transfer(p_v_disc_reason_code  IN igs_en_dcnt_reasoncd.discontinuation_reason_cd%TYPE) RETURN VARCHAR2;

END igs_fi_gen_008;

 

/
