--------------------------------------------------------
--  DDL for Package Body IGF_AP_NSLDS_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_NSLDS_DATA_PKG" AS
/* $Header: IGFAI10B.pls 120.0 2005/06/02 15:55:35 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_ap_nslds_data_all%ROWTYPE;
  new_references igf_ap_nslds_data_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_nslds_id                          IN     NUMBER  ,
    x_isir_id                           IN     NUMBER  ,
    x_base_id                           IN     NUMBER  ,
    x_nslds_transaction_num             IN     NUMBER  ,
    x_nslds_database_results_f          IN     VARCHAR2,
    x_nslds_f                           IN     VARCHAR2,
    x_nslds_pell_overpay_f              IN     VARCHAR2,
    x_nslds_pell_overpay_contact        IN     VARCHAR2,
    x_nslds_seog_overpay_f              IN     VARCHAR2,
    x_nslds_seog_overpay_contact        IN     VARCHAR2,
    x_nslds_perkins_overpay_f           IN     VARCHAR2,
    x_nslds_perkins_overpay_cntct       IN     VARCHAR2,
    x_nslds_defaulted_loan_f            IN     VARCHAR2,
    x_nslds_dischged_loan_chng_f        IN     VARCHAR2,
    x_nslds_satis_repay_f               IN     VARCHAR2,
    x_nslds_act_bankruptcy_f            IN     VARCHAR2,
    x_nslds_agg_subsz_out_prin_bal      IN     NUMBER  ,
    x_nslds_agg_unsbz_out_prin_bal      IN     NUMBER  ,
    x_nslds_agg_comb_out_prin_bal       IN     NUMBER  ,
    x_nslds_agg_cons_out_prin_bal       IN     NUMBER  ,
    x_nslds_agg_subsz_pend_dismt        IN     NUMBER  ,
    x_nslds_agg_unsbz_pend_dismt        IN     NUMBER  ,
    x_nslds_agg_comb_pend_dismt         IN     NUMBER  ,
    x_nslds_agg_subsz_total             IN     NUMBER  ,
    x_nslds_agg_unsbz_total             IN     NUMBER  ,
    x_nslds_agg_comb_total              IN     NUMBER  ,
    x_nslds_agg_consd_total             IN     NUMBER  ,
    x_nslds_perkins_out_bal             IN     NUMBER  ,
    x_nslds_perkins_cur_yr_dismnt       IN     NUMBER  ,
    x_nslds_default_loan_chng_f         IN     VARCHAR2,
    x_nslds_discharged_loan_f           IN     VARCHAR2,
    x_nslds_satis_repay_chng_f          IN     VARCHAR2,
    x_nslds_act_bnkrupt_chng_f          IN     VARCHAR2,
    x_nslds_overpay_chng_f              IN     VARCHAR2,
    x_nslds_agg_loan_chng_f             IN     VARCHAR2,
    x_nslds_perkins_loan_chng_f         IN     VARCHAR2,
    x_nslds_pell_paymnt_chng_f          IN     VARCHAR2,
    x_nslds_addtnl_pell_f               IN     VARCHAR2,
    x_nslds_addtnl_loan_f               IN     VARCHAR2,
    x_direct_loan_mas_prom_nt_f         IN     VARCHAR2,
    x_nslds_pell_seq_num_1              IN     NUMBER  ,
    x_nslds_pell_verify_f_1             IN     VARCHAR2,
    x_nslds_pell_efc_1                  IN     NUMBER  ,
    x_nslds_pell_school_code_1          IN     NUMBER  ,
    x_nslds_pell_transcn_num_1          IN     NUMBER  ,
    x_nslds_pell_last_updt_dt_1         IN     DATE    ,
    x_nslds_pell_scheduled_amt_1        IN     NUMBER  ,
    x_nslds_pell_amt_paid_todt_1        IN     NUMBER  ,
    x_nslds_pell_remng_amt_1            IN     NUMBER  ,
    x_nslds_pell_pc_schd_awd_us_1       IN     NUMBER  ,
    x_nslds_pell_award_amt_1            IN     NUMBER  ,
    x_nslds_pell_seq_num_2              IN     NUMBER  ,
    x_nslds_pell_verify_f_2             IN     VARCHAR2,
    x_nslds_pell_efc_2                  IN     NUMBER  ,
    x_nslds_pell_school_code_2          IN     NUMBER  ,
    x_nslds_pell_transcn_num_2          IN     NUMBER  ,
    x_nslds_pell_last_updt_dt_2         IN     DATE    ,
    x_nslds_pell_scheduled_amt_2        IN     NUMBER  ,
    x_nslds_pell_amt_paid_todt_2        IN     NUMBER  ,
    x_nslds_pell_remng_amt_2            IN     NUMBER  ,
    x_nslds_pell_pc_schd_awd_us_2       IN     NUMBER  ,
    x_nslds_pell_award_amt_2            IN     NUMBER  ,
    x_nslds_pell_seq_num_3              IN     NUMBER  ,
    x_nslds_pell_verify_f_3             IN     VARCHAR2,
    x_nslds_pell_efc_3                  IN     NUMBER  ,
    x_nslds_pell_school_code_3          IN     NUMBER  ,
    x_nslds_pell_transcn_num_3          IN     NUMBER  ,
    x_nslds_pell_last_updt_dt_3         IN     DATE    ,
    x_nslds_pell_scheduled_amt_3        IN     NUMBER  ,
    x_nslds_pell_amt_paid_todt_3        IN     NUMBER  ,
    x_nslds_pell_remng_amt_3            IN     NUMBER  ,
    x_nslds_pell_pc_schd_awd_us_3       IN     NUMBER  ,
    x_nslds_pell_award_amt_3            IN     NUMBER  ,
    x_nslds_loan_seq_num_1              IN     NUMBER  ,
    x_nslds_loan_type_code_1            IN     VARCHAR2,
    x_nslds_loan_chng_f_1               IN     VARCHAR2,
    x_nslds_loan_prog_code_1            IN     VARCHAR2,
    x_nslds_loan_net_amnt_1             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_1          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_1          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_1           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_1        IN     DATE    ,
    x_nslds_loan_begin_dt_1             IN     DATE    ,
    x_nslds_loan_end_dt_1               IN     DATE    ,
    x_nslds_loan_ga_code_1              IN     VARCHAR2,
    x_nslds_loan_cont_type_1            IN     VARCHAR2,
    x_nslds_loan_schol_code_1           IN     VARCHAR2,
    x_nslds_loan_cont_code_1            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_1            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_1       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_1        IN     VARCHAR2,
    x_nslds_loan_seq_num_2              IN     NUMBER  ,
    x_nslds_loan_type_code_2            IN     VARCHAR2,
    x_nslds_loan_chng_f_2               IN     VARCHAR2,
    x_nslds_loan_prog_code_2            IN     VARCHAR2,
    x_nslds_loan_net_amnt_2             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_2          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_2          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_2           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_2        IN     DATE    ,
    x_nslds_loan_begin_dt_2             IN     DATE    ,
    x_nslds_loan_end_dt_2               IN     DATE    ,
    x_nslds_loan_ga_code_2              IN     VARCHAR2,
    x_nslds_loan_cont_type_2            IN     VARCHAR2,
    x_nslds_loan_schol_code_2           IN     VARCHAR2,
    x_nslds_loan_cont_code_2            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_2            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_2       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_2        IN     VARCHAR2,
    x_nslds_loan_seq_num_3              IN     NUMBER  ,
    x_nslds_loan_type_code_3            IN     VARCHAR2,
    x_nslds_loan_chng_f_3               IN     VARCHAR2,
    x_nslds_loan_prog_code_3            IN     VARCHAR2,
    x_nslds_loan_net_amnt_3             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_3          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_3          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_3           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_3        IN     DATE    ,
    x_nslds_loan_begin_dt_3             IN     DATE    ,
    x_nslds_loan_end_dt_3               IN     DATE    ,
    x_nslds_loan_ga_code_3              IN     VARCHAR2,
    x_nslds_loan_cont_type_3            IN     VARCHAR2,
    x_nslds_loan_schol_code_3           IN     VARCHAR2,
    x_nslds_loan_cont_code_3            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_3            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_3       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_3        IN     VARCHAR2,
    x_nslds_loan_seq_num_4              IN     NUMBER  ,
    x_nslds_loan_type_code_4            IN     VARCHAR2,
    x_nslds_loan_chng_f_4               IN     VARCHAR2,
    x_nslds_loan_prog_code_4            IN     VARCHAR2,
    x_nslds_loan_net_amnt_4             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_4          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_4          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_4           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_4        IN     DATE    ,
    x_nslds_loan_begin_dt_4             IN     DATE    ,
    x_nslds_loan_end_dt_4               IN     DATE    ,
    x_nslds_loan_ga_code_4              IN     VARCHAR2,
    x_nslds_loan_cont_type_4            IN     VARCHAR2,
    x_nslds_loan_schol_code_4           IN     VARCHAR2,
    x_nslds_loan_cont_code_4            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_4            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_4       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_4        IN     VARCHAR2,
    x_nslds_loan_seq_num_5              IN     NUMBER  ,
    x_nslds_loan_type_code_5            IN     VARCHAR2,
    x_nslds_loan_chng_f_5               IN     VARCHAR2,
    x_nslds_loan_prog_code_5            IN     VARCHAR2,
    x_nslds_loan_net_amnt_5             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_5          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_5          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_5           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_5        IN     DATE    ,
    x_nslds_loan_begin_dt_5             IN     DATE    ,
    x_nslds_loan_end_dt_5               IN     DATE    ,
    x_nslds_loan_ga_code_5              IN     VARCHAR2,
    x_nslds_loan_cont_type_5            IN     VARCHAR2,
    x_nslds_loan_schol_code_5           IN     VARCHAR2,
    x_nslds_loan_cont_code_5            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_5            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_5       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_5        IN     VARCHAR2,
    x_nslds_loan_seq_num_6              IN     NUMBER  ,
    x_nslds_loan_type_code_6            IN     VARCHAR2,
    x_nslds_loan_chng_f_6               IN     VARCHAR2,
    x_nslds_loan_prog_code_6            IN     VARCHAR2,
    x_nslds_loan_net_amnt_6             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_6          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_6          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_6           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_6        IN     DATE    ,
    x_nslds_loan_begin_dt_6             IN     DATE    ,
    x_nslds_loan_end_dt_6               IN     DATE    ,
    x_nslds_loan_ga_code_6              IN     VARCHAR2,
    x_nslds_loan_cont_type_6            IN     VARCHAR2,
    x_nslds_loan_schol_code_6           IN     VARCHAR2,
    x_nslds_loan_cont_code_6            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_6            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_6       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_6        IN     VARCHAR2,
    x_nslds_loan_last_d_amt_1           IN     NUMBER  ,
    x_nslds_loan_last_d_date_1          IN     DATE    ,
    x_nslds_loan_last_d_amt_2           IN     NUMBER  ,
    x_nslds_loan_last_d_date_2          IN     DATE    ,
    x_nslds_loan_last_d_amt_3           IN     NUMBER  ,
    x_nslds_loan_last_d_date_3          IN     DATE    ,
    x_nslds_loan_last_d_amt_4           IN     NUMBER  ,
    x_nslds_loan_last_d_date_4          IN     DATE    ,
    x_nslds_loan_last_d_amt_5           IN     NUMBER  ,
    x_nslds_loan_last_d_date_5          IN     DATE    ,
    x_nslds_loan_last_d_amt_6           IN     NUMBER  ,
    x_nslds_loan_last_d_date_6          IN     DATE    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_dlp_master_prom_note_flag         IN     VARCHAR2,
    x_subsidized_loan_limit_type        IN     VARCHAR2,
    x_combined_loan_limit_type          IN     VARCHAR2,
    x_transaction_num_txt               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 06-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_NSLDS_DATA_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.nslds_id                          := x_nslds_id;
    new_references.isir_id                           := x_isir_id;
    new_references.base_id                           := x_base_id;
    new_references.nslds_transaction_num             := x_nslds_transaction_num;
    new_references.nslds_database_results_f          := x_nslds_database_results_f;
    new_references.nslds_f                           := x_nslds_f;
    new_references.nslds_pell_overpay_f              := x_nslds_pell_overpay_f;
    new_references.nslds_pell_overpay_contact        := x_nslds_pell_overpay_contact;
    new_references.nslds_seog_overpay_f              := x_nslds_seog_overpay_f;
    new_references.nslds_seog_overpay_contact        := x_nslds_seog_overpay_contact;
    new_references.nslds_perkins_overpay_f           := x_nslds_perkins_overpay_f;
    new_references.nslds_perkins_overpay_cntct       := x_nslds_perkins_overpay_cntct;
    new_references.nslds_defaulted_loan_f            := x_nslds_defaulted_loan_f;
    new_references.nslds_dischged_loan_chng_f        := x_nslds_dischged_loan_chng_f;
    new_references.nslds_satis_repay_f               := x_nslds_satis_repay_f;
    new_references.nslds_act_bankruptcy_f            := x_nslds_act_bankruptcy_f;
    new_references.nslds_agg_subsz_out_prin_bal      := x_nslds_agg_subsz_out_prin_bal;
    new_references.nslds_agg_unsbz_out_prin_bal      := x_nslds_agg_unsbz_out_prin_bal;
    new_references.nslds_agg_comb_out_prin_bal       := x_nslds_agg_comb_out_prin_bal;
    new_references.nslds_agg_cons_out_prin_bal       := x_nslds_agg_cons_out_prin_bal;
    new_references.nslds_agg_subsz_pend_dismt        := x_nslds_agg_subsz_pend_dismt;
    new_references.nslds_agg_unsbz_pend_dismt        := x_nslds_agg_unsbz_pend_dismt;
    new_references.nslds_agg_comb_pend_dismt         := x_nslds_agg_comb_pend_dismt;
    new_references.nslds_agg_subsz_total             := x_nslds_agg_subsz_total;
    new_references.nslds_agg_unsbz_total             := x_nslds_agg_unsbz_total;
    new_references.nslds_agg_comb_total              := x_nslds_agg_comb_total;
    new_references.nslds_agg_consd_total             := x_nslds_agg_consd_total;
    new_references.nslds_perkins_out_bal             := x_nslds_perkins_out_bal;
    new_references.nslds_perkins_cur_yr_dismnt       := x_nslds_perkins_cur_yr_dismnt;
    new_references.nslds_default_loan_chng_f         := x_nslds_default_loan_chng_f;
    new_references.nslds_discharged_loan_f           := x_nslds_discharged_loan_f;
    new_references.nslds_satis_repay_chng_f          := x_nslds_satis_repay_chng_f;
    new_references.nslds_act_bnkrupt_chng_f          := x_nslds_act_bnkrupt_chng_f;
    new_references.nslds_overpay_chng_f              := x_nslds_overpay_chng_f;
    new_references.nslds_agg_loan_chng_f             := x_nslds_agg_loan_chng_f;
    new_references.nslds_perkins_loan_chng_f         := x_nslds_perkins_loan_chng_f;
    new_references.nslds_pell_paymnt_chng_f          := x_nslds_pell_paymnt_chng_f;
    new_references.nslds_addtnl_pell_f               := x_nslds_addtnl_pell_f;
    new_references.nslds_addtnl_loan_f               := x_nslds_addtnl_loan_f;
    new_references.direct_loan_mas_prom_nt_f         := x_direct_loan_mas_prom_nt_f;
    new_references.nslds_pell_seq_num_1              := x_nslds_pell_seq_num_1;
    new_references.nslds_pell_verify_f_1             := x_nslds_pell_verify_f_1;
    new_references.nslds_pell_efc_1                  := x_nslds_pell_efc_1;
    new_references.nslds_pell_school_code_1          := x_nslds_pell_school_code_1;
    new_references.nslds_pell_transcn_num_1          := x_nslds_pell_transcn_num_1;
    new_references.nslds_pell_last_updt_dt_1         := x_nslds_pell_last_updt_dt_1;
    new_references.nslds_pell_scheduled_amt_1        := x_nslds_pell_scheduled_amt_1;
    new_references.nslds_pell_amt_paid_todt_1        := x_nslds_pell_amt_paid_todt_1;
    new_references.nslds_pell_remng_amt_1            := x_nslds_pell_remng_amt_1;
    new_references.nslds_pell_pc_schd_awd_us_1       := x_nslds_pell_pc_schd_awd_us_1;
    new_references.nslds_pell_award_amt_1            := x_nslds_pell_award_amt_1;
    new_references.nslds_pell_seq_num_2              := x_nslds_pell_seq_num_2;
    new_references.nslds_pell_verify_f_2             := x_nslds_pell_verify_f_2;
    new_references.nslds_pell_efc_2                  := x_nslds_pell_efc_2;
    new_references.nslds_pell_school_code_2          := x_nslds_pell_school_code_2;
    new_references.nslds_pell_transcn_num_2          := x_nslds_pell_transcn_num_2;
    new_references.nslds_pell_last_updt_dt_2         := x_nslds_pell_last_updt_dt_2;
    new_references.nslds_pell_scheduled_amt_2        := x_nslds_pell_scheduled_amt_2;
    new_references.nslds_pell_amt_paid_todt_2        := x_nslds_pell_amt_paid_todt_2;
    new_references.nslds_pell_remng_amt_2            := x_nslds_pell_remng_amt_2;
    new_references.nslds_pell_pc_schd_awd_us_2       := x_nslds_pell_pc_schd_awd_us_2;
    new_references.nslds_pell_award_amt_2            := x_nslds_pell_award_amt_2;
    new_references.nslds_pell_seq_num_3              := x_nslds_pell_seq_num_3;
    new_references.nslds_pell_verify_f_3             := x_nslds_pell_verify_f_3;
    new_references.nslds_pell_efc_3                  := x_nslds_pell_efc_3;
    new_references.nslds_pell_school_code_3          := x_nslds_pell_school_code_3;
    new_references.nslds_pell_transcn_num_3          := x_nslds_pell_transcn_num_3;
    new_references.nslds_pell_last_updt_dt_3         := x_nslds_pell_last_updt_dt_3;
    new_references.nslds_pell_scheduled_amt_3        := x_nslds_pell_scheduled_amt_3;
    new_references.nslds_pell_amt_paid_todt_3        := x_nslds_pell_amt_paid_todt_3;
    new_references.nslds_pell_remng_amt_3            := x_nslds_pell_remng_amt_3;
    new_references.nslds_pell_pc_schd_awd_us_3       := x_nslds_pell_pc_schd_awd_us_3;
    new_references.nslds_pell_award_amt_3            := x_nslds_pell_award_amt_3;
    new_references.nslds_loan_seq_num_1              := x_nslds_loan_seq_num_1;
    new_references.nslds_loan_type_code_1            := x_nslds_loan_type_code_1;
    new_references.nslds_loan_chng_f_1               := x_nslds_loan_chng_f_1;
    new_references.nslds_loan_prog_code_1            := x_nslds_loan_prog_code_1;
    new_references.nslds_loan_net_amnt_1             := x_nslds_loan_net_amnt_1;
    new_references.nslds_loan_cur_st_code_1          := x_nslds_loan_cur_st_code_1;
    new_references.nslds_loan_cur_st_date_1          := x_nslds_loan_cur_st_date_1;
    new_references.nslds_loan_agg_pr_bal_1           := x_nslds_loan_agg_pr_bal_1;
    new_references.nslds_loan_out_pr_bal_dt_1        := x_nslds_loan_out_pr_bal_dt_1;
    new_references.nslds_loan_begin_dt_1             := x_nslds_loan_begin_dt_1;
    new_references.nslds_loan_end_dt_1               := x_nslds_loan_end_dt_1;
    new_references.nslds_loan_ga_code_1              := x_nslds_loan_ga_code_1;
    new_references.nslds_loan_cont_type_1            := x_nslds_loan_cont_type_1;
    new_references.nslds_loan_schol_code_1           := x_nslds_loan_schol_code_1;
    new_references.nslds_loan_cont_code_1            := x_nslds_loan_cont_code_1;
    new_references.nslds_loan_grade_lvl_1            := x_nslds_loan_grade_lvl_1;
    new_references.nslds_loan_xtr_unsbz_ln_f_1       := x_nslds_loan_xtr_unsbz_ln_f_1;
    new_references.nslds_loan_capital_int_f_1        := x_nslds_loan_capital_int_f_1;
    new_references.nslds_loan_seq_num_2              := x_nslds_loan_seq_num_2;
    new_references.nslds_loan_type_code_2            := x_nslds_loan_type_code_2;
    new_references.nslds_loan_chng_f_2               := x_nslds_loan_chng_f_2;
    new_references.nslds_loan_prog_code_2            := x_nslds_loan_prog_code_2;
    new_references.nslds_loan_net_amnt_2             := x_nslds_loan_net_amnt_2;
    new_references.nslds_loan_cur_st_code_2          := x_nslds_loan_cur_st_code_2;
    new_references.nslds_loan_cur_st_date_2          := x_nslds_loan_cur_st_date_2;
    new_references.nslds_loan_agg_pr_bal_2           := x_nslds_loan_agg_pr_bal_2;
    new_references.nslds_loan_out_pr_bal_dt_2        := x_nslds_loan_out_pr_bal_dt_2;
    new_references.nslds_loan_begin_dt_2             := x_nslds_loan_begin_dt_2;
    new_references.nslds_loan_end_dt_2               := x_nslds_loan_end_dt_2;
    new_references.nslds_loan_ga_code_2              := x_nslds_loan_ga_code_2;
    new_references.nslds_loan_cont_type_2            := x_nslds_loan_cont_type_2;
    new_references.nslds_loan_schol_code_2           := x_nslds_loan_schol_code_2;
    new_references.nslds_loan_cont_code_2            := x_nslds_loan_cont_code_2;
    new_references.nslds_loan_grade_lvl_2            := x_nslds_loan_grade_lvl_2;
    new_references.nslds_loan_xtr_unsbz_ln_f_2       := x_nslds_loan_xtr_unsbz_ln_f_2;
    new_references.nslds_loan_capital_int_f_2        := x_nslds_loan_capital_int_f_2;
    new_references.nslds_loan_seq_num_3              := x_nslds_loan_seq_num_3;
    new_references.nslds_loan_type_code_3            := x_nslds_loan_type_code_3;
    new_references.nslds_loan_chng_f_3               := x_nslds_loan_chng_f_3;
    new_references.nslds_loan_prog_code_3            := x_nslds_loan_prog_code_3;
    new_references.nslds_loan_net_amnt_3             := x_nslds_loan_net_amnt_3;
    new_references.nslds_loan_cur_st_code_3          := x_nslds_loan_cur_st_code_3;
    new_references.nslds_loan_cur_st_date_3          := x_nslds_loan_cur_st_date_3;
    new_references.nslds_loan_agg_pr_bal_3           := x_nslds_loan_agg_pr_bal_3;
    new_references.nslds_loan_out_pr_bal_dt_3        := x_nslds_loan_out_pr_bal_dt_3;
    new_references.nslds_loan_begin_dt_3             := x_nslds_loan_begin_dt_3;
    new_references.nslds_loan_end_dt_3               := x_nslds_loan_end_dt_3;
    new_references.nslds_loan_ga_code_3              := x_nslds_loan_ga_code_3;
    new_references.nslds_loan_cont_type_3            := x_nslds_loan_cont_type_3;
    new_references.nslds_loan_schol_code_3           := x_nslds_loan_schol_code_3;
    new_references.nslds_loan_cont_code_3            := x_nslds_loan_cont_code_3;
    new_references.nslds_loan_grade_lvl_3            := x_nslds_loan_grade_lvl_3;
    new_references.nslds_loan_xtr_unsbz_ln_f_3       := x_nslds_loan_xtr_unsbz_ln_f_3;
    new_references.nslds_loan_capital_int_f_3        := x_nslds_loan_capital_int_f_3;
    new_references.nslds_loan_seq_num_4              := x_nslds_loan_seq_num_4;
    new_references.nslds_loan_type_code_4            := x_nslds_loan_type_code_4;
    new_references.nslds_loan_chng_f_4               := x_nslds_loan_chng_f_4;
    new_references.nslds_loan_prog_code_4            := x_nslds_loan_prog_code_4;
    new_references.nslds_loan_net_amnt_4             := x_nslds_loan_net_amnt_4;
    new_references.nslds_loan_cur_st_code_4          := x_nslds_loan_cur_st_code_4;
    new_references.nslds_loan_cur_st_date_4          := x_nslds_loan_cur_st_date_4;
    new_references.nslds_loan_agg_pr_bal_4           := x_nslds_loan_agg_pr_bal_4;
    new_references.nslds_loan_out_pr_bal_dt_4        := x_nslds_loan_out_pr_bal_dt_4;
    new_references.nslds_loan_begin_dt_4             := x_nslds_loan_begin_dt_4;
    new_references.nslds_loan_end_dt_4               := x_nslds_loan_end_dt_4;
    new_references.nslds_loan_ga_code_4              := x_nslds_loan_ga_code_4;
    new_references.nslds_loan_cont_type_4            := x_nslds_loan_cont_type_4;
    new_references.nslds_loan_schol_code_4           := x_nslds_loan_schol_code_4;
    new_references.nslds_loan_cont_code_4            := x_nslds_loan_cont_code_4;
    new_references.nslds_loan_grade_lvl_4            := x_nslds_loan_grade_lvl_4;
    new_references.nslds_loan_xtr_unsbz_ln_f_4       := x_nslds_loan_xtr_unsbz_ln_f_4;
    new_references.nslds_loan_capital_int_f_4        := x_nslds_loan_capital_int_f_4;
    new_references.nslds_loan_seq_num_5              := x_nslds_loan_seq_num_5;
    new_references.nslds_loan_type_code_5            := x_nslds_loan_type_code_5;
    new_references.nslds_loan_chng_f_5               := x_nslds_loan_chng_f_5;
    new_references.nslds_loan_prog_code_5            := x_nslds_loan_prog_code_5;
    new_references.nslds_loan_net_amnt_5             := x_nslds_loan_net_amnt_5;
    new_references.nslds_loan_cur_st_code_5          := x_nslds_loan_cur_st_code_5;
    new_references.nslds_loan_cur_st_date_5          := x_nslds_loan_cur_st_date_5;
    new_references.nslds_loan_agg_pr_bal_5           := x_nslds_loan_agg_pr_bal_5;
    new_references.nslds_loan_out_pr_bal_dt_5        := x_nslds_loan_out_pr_bal_dt_5;
    new_references.nslds_loan_begin_dt_5             := x_nslds_loan_begin_dt_5;
    new_references.nslds_loan_end_dt_5               := x_nslds_loan_end_dt_5;
    new_references.nslds_loan_ga_code_5              := x_nslds_loan_ga_code_5;
    new_references.nslds_loan_cont_type_5            := x_nslds_loan_cont_type_5;
    new_references.nslds_loan_schol_code_5           := x_nslds_loan_schol_code_5;
    new_references.nslds_loan_cont_code_5            := x_nslds_loan_cont_code_5;
    new_references.nslds_loan_grade_lvl_5            := x_nslds_loan_grade_lvl_5;
    new_references.nslds_loan_xtr_unsbz_ln_f_5       := x_nslds_loan_xtr_unsbz_ln_f_5;
    new_references.nslds_loan_capital_int_f_5        := x_nslds_loan_capital_int_f_5;
    new_references.nslds_loan_seq_num_6              := x_nslds_loan_seq_num_6;
    new_references.nslds_loan_type_code_6            := x_nslds_loan_type_code_6;
    new_references.nslds_loan_chng_f_6               := x_nslds_loan_chng_f_6;
    new_references.nslds_loan_prog_code_6            := x_nslds_loan_prog_code_6;
    new_references.nslds_loan_net_amnt_6             := x_nslds_loan_net_amnt_6;
    new_references.nslds_loan_cur_st_code_6          := x_nslds_loan_cur_st_code_6;
    new_references.nslds_loan_cur_st_date_6          := x_nslds_loan_cur_st_date_6;
    new_references.nslds_loan_agg_pr_bal_6           := x_nslds_loan_agg_pr_bal_6;
    new_references.nslds_loan_out_pr_bal_dt_6        := x_nslds_loan_out_pr_bal_dt_6;
    new_references.nslds_loan_begin_dt_6             := x_nslds_loan_begin_dt_6;
    new_references.nslds_loan_end_dt_6               := x_nslds_loan_end_dt_6;
    new_references.nslds_loan_ga_code_6              := x_nslds_loan_ga_code_6;
    new_references.nslds_loan_cont_type_6            := x_nslds_loan_cont_type_6;
    new_references.nslds_loan_schol_code_6           := x_nslds_loan_schol_code_6;
    new_references.nslds_loan_cont_code_6            := x_nslds_loan_cont_code_6;
    new_references.nslds_loan_grade_lvl_6            := x_nslds_loan_grade_lvl_6;
    new_references.nslds_loan_xtr_unsbz_ln_f_6       := x_nslds_loan_xtr_unsbz_ln_f_6;
    new_references.nslds_loan_capital_int_f_6        := x_nslds_loan_capital_int_f_6;
    new_references.nslds_loan_last_d_amt_1	         := x_nslds_loan_last_d_amt_1;
    new_references.nslds_loan_last_d_date_1	         := x_nslds_loan_last_d_date_1;
    new_references.nslds_loan_last_d_amt_2	         := x_nslds_loan_last_d_amt_2;
    new_references.nslds_loan_last_d_date_2	         := x_nslds_loan_last_d_date_2;
    new_references.nslds_loan_last_d_amt_3	         := x_nslds_loan_last_d_amt_3;
    new_references.nslds_loan_last_d_date_3	         := x_nslds_loan_last_d_date_3;
    new_references.nslds_loan_last_d_amt_4	         := x_nslds_loan_last_d_amt_4;
    new_references.nslds_loan_last_d_date_4	         := x_nslds_loan_last_d_date_4;
    new_references.nslds_loan_last_d_amt_5	         := x_nslds_loan_last_d_amt_5;
    new_references.nslds_loan_last_d_date_5	         := x_nslds_loan_last_d_date_5;
    new_references.nslds_loan_last_d_amt_6	         := x_nslds_loan_last_d_amt_6;
    new_references.nslds_loan_last_d_date_6	         := x_nslds_loan_last_d_date_6;
    new_references.dlp_master_prom_note_flag         := x_dlp_master_prom_note_flag;
    new_references.subsidized_loan_limit_type        := x_subsidized_loan_limit_type;
    new_references.combined_loan_limit_type          := x_combined_loan_limit_type;
    new_references.transaction_num_txt               := x_transaction_num_txt;

    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : rasingh
  ||  Created On : 06-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.isir_id = new_references.isir_id)) OR
        ((new_references.isir_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_isir_matched_pkg.get_pk_for_validation (
                new_references.isir_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_nslds_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rasingh
  ||  Created On : 06-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_nslds_data_all
      WHERE    nslds_id = x_nslds_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_pk_for_validation;


  PROCEDURE get_fk_igf_ap_isir_matched (
    x_isir_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 06-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_nslds_data_all
      WHERE   ((isir_id = x_isir_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGF_AP_NSLDS_ISIR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_isir_matched;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_nslds_id                          IN     NUMBER  ,
    x_isir_id                           IN     NUMBER  ,
    x_base_id                           IN     NUMBER  ,
    x_nslds_transaction_num             IN     NUMBER  ,
    x_nslds_database_results_f          IN     VARCHAR2,
    x_nslds_f                           IN     VARCHAR2,
    x_nslds_pell_overpay_f              IN     VARCHAR2,
    x_nslds_pell_overpay_contact        IN     VARCHAR2,
    x_nslds_seog_overpay_f              IN     VARCHAR2,
    x_nslds_seog_overpay_contact        IN     VARCHAR2,
    x_nslds_perkins_overpay_f           IN     VARCHAR2,
    x_nslds_perkins_overpay_cntct       IN     VARCHAR2,
    x_nslds_defaulted_loan_f            IN     VARCHAR2,
    x_nslds_dischged_loan_chng_f        IN     VARCHAR2,
    x_nslds_satis_repay_f               IN     VARCHAR2,
    x_nslds_act_bankruptcy_f            IN     VARCHAR2,
    x_nslds_agg_subsz_out_prin_bal      IN     NUMBER  ,
    x_nslds_agg_unsbz_out_prin_bal      IN     NUMBER  ,
    x_nslds_agg_comb_out_prin_bal       IN     NUMBER  ,
    x_nslds_agg_cons_out_prin_bal       IN     NUMBER  ,
    x_nslds_agg_subsz_pend_dismt        IN     NUMBER  ,
    x_nslds_agg_unsbz_pend_dismt        IN     NUMBER  ,
    x_nslds_agg_comb_pend_dismt         IN     NUMBER  ,
    x_nslds_agg_subsz_total             IN     NUMBER  ,
    x_nslds_agg_unsbz_total             IN     NUMBER  ,
    x_nslds_agg_comb_total              IN     NUMBER  ,
    x_nslds_agg_consd_total             IN     NUMBER  ,
    x_nslds_perkins_out_bal             IN     NUMBER  ,
    x_nslds_perkins_cur_yr_dismnt       IN     NUMBER  ,
    x_nslds_default_loan_chng_f         IN     VARCHAR2,
    x_nslds_discharged_loan_f           IN     VARCHAR2,
    x_nslds_satis_repay_chng_f          IN     VARCHAR2,
    x_nslds_act_bnkrupt_chng_f          IN     VARCHAR2,
    x_nslds_overpay_chng_f              IN     VARCHAR2,
    x_nslds_agg_loan_chng_f             IN     VARCHAR2,
    x_nslds_perkins_loan_chng_f         IN     VARCHAR2,
    x_nslds_pell_paymnt_chng_f          IN     VARCHAR2,
    x_nslds_addtnl_pell_f               IN     VARCHAR2,
    x_nslds_addtnl_loan_f               IN     VARCHAR2,
    x_direct_loan_mas_prom_nt_f         IN     VARCHAR2,
    x_nslds_pell_seq_num_1              IN     NUMBER  ,
    x_nslds_pell_verify_f_1             IN     VARCHAR2,
    x_nslds_pell_efc_1                  IN     NUMBER  ,
    x_nslds_pell_school_code_1          IN     NUMBER  ,
    x_nslds_pell_transcn_num_1          IN     NUMBER  ,
    x_nslds_pell_last_updt_dt_1         IN     DATE    ,
    x_nslds_pell_scheduled_amt_1        IN     NUMBER  ,
    x_nslds_pell_amt_paid_todt_1        IN     NUMBER  ,
    x_nslds_pell_remng_amt_1            IN     NUMBER  ,
    x_nslds_pell_pc_schd_awd_us_1       IN     NUMBER  ,
    x_nslds_pell_award_amt_1            IN     NUMBER  ,
    x_nslds_pell_seq_num_2              IN     NUMBER  ,
    x_nslds_pell_verify_f_2             IN     VARCHAR2,
    x_nslds_pell_efc_2                  IN     NUMBER  ,
    x_nslds_pell_school_code_2          IN     NUMBER  ,
    x_nslds_pell_transcn_num_2          IN     NUMBER  ,
    x_nslds_pell_last_updt_dt_2         IN     DATE    ,
    x_nslds_pell_scheduled_amt_2        IN     NUMBER  ,
    x_nslds_pell_amt_paid_todt_2        IN     NUMBER  ,
    x_nslds_pell_remng_amt_2            IN     NUMBER  ,
    x_nslds_pell_pc_schd_awd_us_2       IN     NUMBER  ,
    x_nslds_pell_award_amt_2            IN     NUMBER  ,
    x_nslds_pell_seq_num_3              IN     NUMBER  ,
    x_nslds_pell_verify_f_3             IN     VARCHAR2,
    x_nslds_pell_efc_3                  IN     NUMBER  ,
    x_nslds_pell_school_code_3          IN     NUMBER  ,
    x_nslds_pell_transcn_num_3          IN     NUMBER  ,
    x_nslds_pell_last_updt_dt_3         IN     DATE    ,
    x_nslds_pell_scheduled_amt_3        IN     NUMBER  ,
    x_nslds_pell_amt_paid_todt_3        IN     NUMBER  ,
    x_nslds_pell_remng_amt_3            IN     NUMBER  ,
    x_nslds_pell_pc_schd_awd_us_3       IN     NUMBER  ,
    x_nslds_pell_award_amt_3            IN     NUMBER  ,
    x_nslds_loan_seq_num_1              IN     NUMBER  ,
    x_nslds_loan_type_code_1            IN     VARCHAR2,
    x_nslds_loan_chng_f_1               IN     VARCHAR2,
    x_nslds_loan_prog_code_1            IN     VARCHAR2,
    x_nslds_loan_net_amnt_1             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_1          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_1          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_1           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_1        IN     DATE    ,
    x_nslds_loan_begin_dt_1             IN     DATE    ,
    x_nslds_loan_end_dt_1               IN     DATE    ,
    x_nslds_loan_ga_code_1              IN     VARCHAR2,
    x_nslds_loan_cont_type_1            IN     VARCHAR2,
    x_nslds_loan_schol_code_1           IN     VARCHAR2,
    x_nslds_loan_cont_code_1            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_1            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_1       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_1        IN     VARCHAR2,
    x_nslds_loan_seq_num_2              IN     NUMBER  ,
    x_nslds_loan_type_code_2            IN     VARCHAR2,
    x_nslds_loan_chng_f_2               IN     VARCHAR2,
    x_nslds_loan_prog_code_2            IN     VARCHAR2,
    x_nslds_loan_net_amnt_2             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_2          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_2          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_2           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_2        IN     DATE    ,
    x_nslds_loan_begin_dt_2             IN     DATE    ,
    x_nslds_loan_end_dt_2               IN     DATE    ,
    x_nslds_loan_ga_code_2              IN     VARCHAR2,
    x_nslds_loan_cont_type_2            IN     VARCHAR2,
    x_nslds_loan_schol_code_2           IN     VARCHAR2,
    x_nslds_loan_cont_code_2            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_2            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_2       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_2        IN     VARCHAR2,
    x_nslds_loan_seq_num_3              IN     NUMBER  ,
    x_nslds_loan_type_code_3            IN     VARCHAR2,
    x_nslds_loan_chng_f_3               IN     VARCHAR2,
    x_nslds_loan_prog_code_3            IN     VARCHAR2,
    x_nslds_loan_net_amnt_3             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_3          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_3          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_3           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_3        IN     DATE    ,
    x_nslds_loan_begin_dt_3             IN     DATE    ,
    x_nslds_loan_end_dt_3               IN     DATE    ,
    x_nslds_loan_ga_code_3              IN     VARCHAR2,
    x_nslds_loan_cont_type_3            IN     VARCHAR2,
    x_nslds_loan_schol_code_3           IN     VARCHAR2,
    x_nslds_loan_cont_code_3            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_3            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_3       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_3        IN     VARCHAR2,
    x_nslds_loan_seq_num_4              IN     NUMBER  ,
    x_nslds_loan_type_code_4            IN     VARCHAR2,
    x_nslds_loan_chng_f_4               IN     VARCHAR2,
    x_nslds_loan_prog_code_4            IN     VARCHAR2,
    x_nslds_loan_net_amnt_4             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_4          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_4          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_4           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_4        IN     DATE    ,
    x_nslds_loan_begin_dt_4             IN     DATE    ,
    x_nslds_loan_end_dt_4               IN     DATE    ,
    x_nslds_loan_ga_code_4              IN     VARCHAR2,
    x_nslds_loan_cont_type_4            IN     VARCHAR2,
    x_nslds_loan_schol_code_4           IN     VARCHAR2,
    x_nslds_loan_cont_code_4            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_4            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_4       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_4        IN     VARCHAR2,
    x_nslds_loan_seq_num_5              IN     NUMBER  ,
    x_nslds_loan_type_code_5            IN     VARCHAR2,
    x_nslds_loan_chng_f_5               IN     VARCHAR2,
    x_nslds_loan_prog_code_5            IN     VARCHAR2,
    x_nslds_loan_net_amnt_5             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_5          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_5          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_5           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_5        IN     DATE    ,
    x_nslds_loan_begin_dt_5             IN     DATE    ,
    x_nslds_loan_end_dt_5               IN     DATE    ,
    x_nslds_loan_ga_code_5              IN     VARCHAR2,
    x_nslds_loan_cont_type_5            IN     VARCHAR2,
    x_nslds_loan_schol_code_5           IN     VARCHAR2,
    x_nslds_loan_cont_code_5            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_5            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_5       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_5        IN     VARCHAR2,
    x_nslds_loan_seq_num_6              IN     NUMBER  ,
    x_nslds_loan_type_code_6            IN     VARCHAR2,
    x_nslds_loan_chng_f_6               IN     VARCHAR2,
    x_nslds_loan_prog_code_6            IN     VARCHAR2,
    x_nslds_loan_net_amnt_6             IN     NUMBER  ,
    x_nslds_loan_cur_st_code_6          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_6          IN     DATE    ,
    x_nslds_loan_agg_pr_bal_6           IN     NUMBER  ,
    x_nslds_loan_out_pr_bal_dt_6        IN     DATE    ,
    x_nslds_loan_begin_dt_6             IN     DATE    ,
    x_nslds_loan_end_dt_6               IN     DATE    ,
    x_nslds_loan_ga_code_6              IN     VARCHAR2,
    x_nslds_loan_cont_type_6            IN     VARCHAR2,
    x_nslds_loan_schol_code_6           IN     VARCHAR2,
    x_nslds_loan_cont_code_6            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_6            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_6       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_6        IN     VARCHAR2,
    x_nslds_loan_last_d_amt_1           IN     NUMBER  ,
    x_nslds_loan_last_d_date_1          IN     DATE    ,
    x_nslds_loan_last_d_amt_2           IN     NUMBER  ,
    x_nslds_loan_last_d_date_2          IN     DATE    ,
    x_nslds_loan_last_d_amt_3           IN     NUMBER  ,
    x_nslds_loan_last_d_date_3          IN     DATE    ,
    x_nslds_loan_last_d_amt_4           IN     NUMBER  ,
    x_nslds_loan_last_d_date_4          IN     DATE    ,
    x_nslds_loan_last_d_amt_5           IN     NUMBER  ,
    x_nslds_loan_last_d_date_5          IN     DATE    ,
    x_nslds_loan_last_d_amt_6           IN     NUMBER  ,
    x_nslds_loan_last_d_date_6          IN     DATE    ,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_dlp_master_prom_note_flag         IN     VARCHAR2,
    x_subsidized_loan_limit_type        IN     VARCHAR2,
    x_combined_loan_limit_type          IN     VARCHAR2,
    x_transaction_num_txt               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 06-DEC-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_nslds_id,
      x_isir_id,
      x_base_id,
      x_nslds_transaction_num,
      x_nslds_database_results_f,
      x_nslds_f,
      x_nslds_pell_overpay_f,
      x_nslds_pell_overpay_contact,
      x_nslds_seog_overpay_f,
      x_nslds_seog_overpay_contact,
      x_nslds_perkins_overpay_f,
      x_nslds_perkins_overpay_cntct,
      x_nslds_defaulted_loan_f,
      x_nslds_dischged_loan_chng_f,
      x_nslds_satis_repay_f,
      x_nslds_act_bankruptcy_f,
      x_nslds_agg_subsz_out_prin_bal,
      x_nslds_agg_unsbz_out_prin_bal,
      x_nslds_agg_comb_out_prin_bal,
      x_nslds_agg_cons_out_prin_bal,
      x_nslds_agg_subsz_pend_dismt,
      x_nslds_agg_unsbz_pend_dismt,
      x_nslds_agg_comb_pend_dismt,
      x_nslds_agg_subsz_total,
      x_nslds_agg_unsbz_total,
      x_nslds_agg_comb_total,
      x_nslds_agg_consd_total,
      x_nslds_perkins_out_bal,
      x_nslds_perkins_cur_yr_dismnt,
      x_nslds_default_loan_chng_f,
      x_nslds_discharged_loan_f,
      x_nslds_satis_repay_chng_f,
      x_nslds_act_bnkrupt_chng_f,
      x_nslds_overpay_chng_f,
      x_nslds_agg_loan_chng_f,
      x_nslds_perkins_loan_chng_f,
      x_nslds_pell_paymnt_chng_f,
      x_nslds_addtnl_pell_f,
      x_nslds_addtnl_loan_f,
      x_direct_loan_mas_prom_nt_f,
      x_nslds_pell_seq_num_1,
      x_nslds_pell_verify_f_1,
      x_nslds_pell_efc_1,
      x_nslds_pell_school_code_1,
      x_nslds_pell_transcn_num_1,
      x_nslds_pell_last_updt_dt_1,
      x_nslds_pell_scheduled_amt_1,
      x_nslds_pell_amt_paid_todt_1,
      x_nslds_pell_remng_amt_1,
      x_nslds_pell_pc_schd_awd_us_1,
      x_nslds_pell_award_amt_1,
      x_nslds_pell_seq_num_2,
      x_nslds_pell_verify_f_2,
      x_nslds_pell_efc_2,
      x_nslds_pell_school_code_2,
      x_nslds_pell_transcn_num_2,
      x_nslds_pell_last_updt_dt_2,
      x_nslds_pell_scheduled_amt_2,
      x_nslds_pell_amt_paid_todt_2,
      x_nslds_pell_remng_amt_2,
      x_nslds_pell_pc_schd_awd_us_2,
      x_nslds_pell_award_amt_2,
      x_nslds_pell_seq_num_3,
      x_nslds_pell_verify_f_3,
      x_nslds_pell_efc_3,
      x_nslds_pell_school_code_3,
      x_nslds_pell_transcn_num_3,
      x_nslds_pell_last_updt_dt_3,
      x_nslds_pell_scheduled_amt_3,
      x_nslds_pell_amt_paid_todt_3,
      x_nslds_pell_remng_amt_3,
      x_nslds_pell_pc_schd_awd_us_3,
      x_nslds_pell_award_amt_3,
      x_nslds_loan_seq_num_1,
      x_nslds_loan_type_code_1,
      x_nslds_loan_chng_f_1,
      x_nslds_loan_prog_code_1,
      x_nslds_loan_net_amnt_1,
      x_nslds_loan_cur_st_code_1,
      x_nslds_loan_cur_st_date_1,
      x_nslds_loan_agg_pr_bal_1,
      x_nslds_loan_out_pr_bal_dt_1,
      x_nslds_loan_begin_dt_1,
      x_nslds_loan_end_dt_1,
      x_nslds_loan_ga_code_1,
      x_nslds_loan_cont_type_1,
      x_nslds_loan_schol_code_1,
      x_nslds_loan_cont_code_1,
      x_nslds_loan_grade_lvl_1,
      x_nslds_loan_xtr_unsbz_ln_f_1,
      x_nslds_loan_capital_int_f_1,
      x_nslds_loan_seq_num_2,
      x_nslds_loan_type_code_2,
      x_nslds_loan_chng_f_2,
      x_nslds_loan_prog_code_2,
      x_nslds_loan_net_amnt_2,
      x_nslds_loan_cur_st_code_2,
      x_nslds_loan_cur_st_date_2,
      x_nslds_loan_agg_pr_bal_2,
      x_nslds_loan_out_pr_bal_dt_2,
      x_nslds_loan_begin_dt_2,
      x_nslds_loan_end_dt_2,
      x_nslds_loan_ga_code_2,
      x_nslds_loan_cont_type_2,
      x_nslds_loan_schol_code_2,
      x_nslds_loan_cont_code_2,
      x_nslds_loan_grade_lvl_2,
      x_nslds_loan_xtr_unsbz_ln_f_2,
      x_nslds_loan_capital_int_f_2,
      x_nslds_loan_seq_num_3,
      x_nslds_loan_type_code_3,
      x_nslds_loan_chng_f_3,
      x_nslds_loan_prog_code_3,
      x_nslds_loan_net_amnt_3,
      x_nslds_loan_cur_st_code_3,
      x_nslds_loan_cur_st_date_3,
      x_nslds_loan_agg_pr_bal_3,
      x_nslds_loan_out_pr_bal_dt_3,
      x_nslds_loan_begin_dt_3,
      x_nslds_loan_end_dt_3,
      x_nslds_loan_ga_code_3,
      x_nslds_loan_cont_type_3,
      x_nslds_loan_schol_code_3,
      x_nslds_loan_cont_code_3,
      x_nslds_loan_grade_lvl_3,
      x_nslds_loan_xtr_unsbz_ln_f_3,
      x_nslds_loan_capital_int_f_3,
      x_nslds_loan_seq_num_4,
      x_nslds_loan_type_code_4,
      x_nslds_loan_chng_f_4,
      x_nslds_loan_prog_code_4,
      x_nslds_loan_net_amnt_4,
      x_nslds_loan_cur_st_code_4,
      x_nslds_loan_cur_st_date_4,
      x_nslds_loan_agg_pr_bal_4,
      x_nslds_loan_out_pr_bal_dt_4,
      x_nslds_loan_begin_dt_4,
      x_nslds_loan_end_dt_4,
      x_nslds_loan_ga_code_4,
      x_nslds_loan_cont_type_4,
      x_nslds_loan_schol_code_4,
      x_nslds_loan_cont_code_4,
      x_nslds_loan_grade_lvl_4,
      x_nslds_loan_xtr_unsbz_ln_f_4,
      x_nslds_loan_capital_int_f_4,
      x_nslds_loan_seq_num_5,
      x_nslds_loan_type_code_5,
      x_nslds_loan_chng_f_5,
      x_nslds_loan_prog_code_5,
      x_nslds_loan_net_amnt_5,
      x_nslds_loan_cur_st_code_5,
      x_nslds_loan_cur_st_date_5,
      x_nslds_loan_agg_pr_bal_5,
      x_nslds_loan_out_pr_bal_dt_5,
      x_nslds_loan_begin_dt_5,
      x_nslds_loan_end_dt_5,
      x_nslds_loan_ga_code_5,
      x_nslds_loan_cont_type_5,
      x_nslds_loan_schol_code_5,
      x_nslds_loan_cont_code_5,
      x_nslds_loan_grade_lvl_5,
      x_nslds_loan_xtr_unsbz_ln_f_5,
      x_nslds_loan_capital_int_f_5,
      x_nslds_loan_seq_num_6,
      x_nslds_loan_type_code_6,
      x_nslds_loan_chng_f_6,
      x_nslds_loan_prog_code_6,
      x_nslds_loan_net_amnt_6,
      x_nslds_loan_cur_st_code_6,
      x_nslds_loan_cur_st_date_6,
      x_nslds_loan_agg_pr_bal_6,
      x_nslds_loan_out_pr_bal_dt_6,
      x_nslds_loan_begin_dt_6,
      x_nslds_loan_end_dt_6,
      x_nslds_loan_ga_code_6,
      x_nslds_loan_cont_type_6,
      x_nslds_loan_schol_code_6,
      x_nslds_loan_cont_code_6,
      x_nslds_loan_grade_lvl_6,
      x_nslds_loan_xtr_unsbz_ln_f_6,
      x_nslds_loan_capital_int_f_6,
      x_nslds_loan_last_d_amt_1,
      x_nslds_loan_last_d_date_1,
      x_nslds_loan_last_d_amt_2,
      x_nslds_loan_last_d_date_2,
      x_nslds_loan_last_d_amt_3,
      x_nslds_loan_last_d_date_3,
      x_nslds_loan_last_d_amt_4,
      x_nslds_loan_last_d_date_4,
      x_nslds_loan_last_d_amt_5,
      x_nslds_loan_last_d_date_5,
      x_nslds_loan_last_d_amt_6,
      x_nslds_loan_last_d_date_6,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_dlp_master_prom_note_flag,
      x_subsidized_loan_limit_type,
      x_combined_loan_limit_type,
      x_transaction_num_txt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.nslds_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.nslds_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT  NOCOPY VARCHAR2,
    x_nslds_id                          IN OUT  NOCOPY NUMBER,
    x_isir_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_nslds_transaction_num             IN     NUMBER,
    x_nslds_database_results_f          IN     VARCHAR2,
    x_nslds_f                           IN     VARCHAR2,
    x_nslds_pell_overpay_f              IN     VARCHAR2,
    x_nslds_pell_overpay_contact        IN     VARCHAR2,
    x_nslds_seog_overpay_f              IN     VARCHAR2,
    x_nslds_seog_overpay_contact        IN     VARCHAR2,
    x_nslds_perkins_overpay_f           IN     VARCHAR2,
    x_nslds_perkins_overpay_cntct       IN     VARCHAR2,
    x_nslds_defaulted_loan_f            IN     VARCHAR2,
    x_nslds_dischged_loan_chng_f        IN     VARCHAR2,
    x_nslds_satis_repay_f               IN     VARCHAR2,
    x_nslds_act_bankruptcy_f            IN     VARCHAR2,
    x_nslds_agg_subsz_out_prin_bal      IN     NUMBER,
    x_nslds_agg_unsbz_out_prin_bal      IN     NUMBER,
    x_nslds_agg_comb_out_prin_bal       IN     NUMBER,
    x_nslds_agg_cons_out_prin_bal       IN     NUMBER,
    x_nslds_agg_subsz_pend_dismt        IN     NUMBER,
    x_nslds_agg_unsbz_pend_dismt        IN     NUMBER,
    x_nslds_agg_comb_pend_dismt         IN     NUMBER,
    x_nslds_agg_subsz_total             IN     NUMBER,
    x_nslds_agg_unsbz_total             IN     NUMBER,
    x_nslds_agg_comb_total              IN     NUMBER,
    x_nslds_agg_consd_total             IN     NUMBER,
    x_nslds_perkins_out_bal             IN     NUMBER,
    x_nslds_perkins_cur_yr_dismnt       IN     NUMBER,
    x_nslds_default_loan_chng_f         IN     VARCHAR2,
    x_nslds_discharged_loan_f           IN     VARCHAR2,
    x_nslds_satis_repay_chng_f          IN     VARCHAR2,
    x_nslds_act_bnkrupt_chng_f          IN     VARCHAR2,
    x_nslds_overpay_chng_f              IN     VARCHAR2,
    x_nslds_agg_loan_chng_f             IN     VARCHAR2,
    x_nslds_perkins_loan_chng_f         IN     VARCHAR2,
    x_nslds_pell_paymnt_chng_f          IN     VARCHAR2,
    x_nslds_addtnl_pell_f               IN     VARCHAR2,
    x_nslds_addtnl_loan_f               IN     VARCHAR2,
    x_direct_loan_mas_prom_nt_f         IN     VARCHAR2,
    x_nslds_pell_seq_num_1              IN     NUMBER,
    x_nslds_pell_verify_f_1             IN     VARCHAR2,
    x_nslds_pell_efc_1                  IN     NUMBER,
    x_nslds_pell_school_code_1          IN     NUMBER,
    x_nslds_pell_transcn_num_1          IN     NUMBER,
    x_nslds_pell_last_updt_dt_1         IN     DATE,
    x_nslds_pell_scheduled_amt_1        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_1        IN     NUMBER,
    x_nslds_pell_remng_amt_1            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_1       IN     NUMBER,
    x_nslds_pell_award_amt_1            IN     NUMBER,
    x_nslds_pell_seq_num_2              IN     NUMBER,
    x_nslds_pell_verify_f_2             IN     VARCHAR2,
    x_nslds_pell_efc_2                  IN     NUMBER,
    x_nslds_pell_school_code_2          IN     NUMBER,
    x_nslds_pell_transcn_num_2          IN     NUMBER,
    x_nslds_pell_last_updt_dt_2         IN     DATE,
    x_nslds_pell_scheduled_amt_2        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_2        IN     NUMBER,
    x_nslds_pell_remng_amt_2            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_2       IN     NUMBER,
    x_nslds_pell_award_amt_2            IN     NUMBER,
    x_nslds_pell_seq_num_3              IN     NUMBER,
    x_nslds_pell_verify_f_3             IN     VARCHAR2,
    x_nslds_pell_efc_3                  IN     NUMBER,
    x_nslds_pell_school_code_3          IN     NUMBER,
    x_nslds_pell_transcn_num_3          IN     NUMBER,
    x_nslds_pell_last_updt_dt_3         IN     DATE,
    x_nslds_pell_scheduled_amt_3        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_3        IN     NUMBER,
    x_nslds_pell_remng_amt_3            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_3       IN     NUMBER,
    x_nslds_pell_award_amt_3            IN     NUMBER,
    x_nslds_loan_seq_num_1              IN     NUMBER,
    x_nslds_loan_type_code_1            IN     VARCHAR2,
    x_nslds_loan_chng_f_1               IN     VARCHAR2,
    x_nslds_loan_prog_code_1            IN     VARCHAR2,
    x_nslds_loan_net_amnt_1             IN     NUMBER,
    x_nslds_loan_cur_st_code_1          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_1          IN     DATE,
    x_nslds_loan_agg_pr_bal_1           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_1        IN     DATE,
    x_nslds_loan_begin_dt_1             IN     DATE,
    x_nslds_loan_end_dt_1               IN     DATE,
    x_nslds_loan_ga_code_1              IN     VARCHAR2,
    x_nslds_loan_cont_type_1            IN     VARCHAR2,
    x_nslds_loan_schol_code_1           IN     VARCHAR2,
    x_nslds_loan_cont_code_1            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_1            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_1       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_1        IN     VARCHAR2,
    x_nslds_loan_seq_num_2              IN     NUMBER,
    x_nslds_loan_type_code_2            IN     VARCHAR2,
    x_nslds_loan_chng_f_2               IN     VARCHAR2,
    x_nslds_loan_prog_code_2            IN     VARCHAR2,
    x_nslds_loan_net_amnt_2             IN     NUMBER,
    x_nslds_loan_cur_st_code_2          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_2          IN     DATE,
    x_nslds_loan_agg_pr_bal_2           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_2        IN     DATE,
    x_nslds_loan_begin_dt_2             IN     DATE,
    x_nslds_loan_end_dt_2               IN     DATE,
    x_nslds_loan_ga_code_2              IN     VARCHAR2,
    x_nslds_loan_cont_type_2            IN     VARCHAR2,
    x_nslds_loan_schol_code_2           IN     VARCHAR2,
    x_nslds_loan_cont_code_2            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_2            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_2       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_2        IN     VARCHAR2,
    x_nslds_loan_seq_num_3              IN     NUMBER,
    x_nslds_loan_type_code_3            IN     VARCHAR2,
    x_nslds_loan_chng_f_3               IN     VARCHAR2,
    x_nslds_loan_prog_code_3            IN     VARCHAR2,
    x_nslds_loan_net_amnt_3             IN     NUMBER,
    x_nslds_loan_cur_st_code_3          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_3          IN     DATE,
    x_nslds_loan_agg_pr_bal_3           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_3        IN     DATE,
    x_nslds_loan_begin_dt_3             IN     DATE,
    x_nslds_loan_end_dt_3               IN     DATE,
    x_nslds_loan_ga_code_3              IN     VARCHAR2,
    x_nslds_loan_cont_type_3            IN     VARCHAR2,
    x_nslds_loan_schol_code_3           IN     VARCHAR2,
    x_nslds_loan_cont_code_3            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_3            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_3       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_3        IN     VARCHAR2,
    x_nslds_loan_seq_num_4              IN     NUMBER,
    x_nslds_loan_type_code_4            IN     VARCHAR2,
    x_nslds_loan_chng_f_4               IN     VARCHAR2,
    x_nslds_loan_prog_code_4            IN     VARCHAR2,
    x_nslds_loan_net_amnt_4             IN     NUMBER,
    x_nslds_loan_cur_st_code_4          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_4          IN     DATE,
    x_nslds_loan_agg_pr_bal_4           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_4        IN     DATE,
    x_nslds_loan_begin_dt_4             IN     DATE,
    x_nslds_loan_end_dt_4               IN     DATE,
    x_nslds_loan_ga_code_4              IN     VARCHAR2,
    x_nslds_loan_cont_type_4            IN     VARCHAR2,
    x_nslds_loan_schol_code_4           IN     VARCHAR2,
    x_nslds_loan_cont_code_4            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_4            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_4       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_4        IN     VARCHAR2,
    x_nslds_loan_seq_num_5              IN     NUMBER,
    x_nslds_loan_type_code_5            IN     VARCHAR2,
    x_nslds_loan_chng_f_5               IN     VARCHAR2,
    x_nslds_loan_prog_code_5            IN     VARCHAR2,
    x_nslds_loan_net_amnt_5             IN     NUMBER,
    x_nslds_loan_cur_st_code_5          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_5          IN     DATE,
    x_nslds_loan_agg_pr_bal_5           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_5        IN     DATE,
    x_nslds_loan_begin_dt_5             IN     DATE,
    x_nslds_loan_end_dt_5               IN     DATE,
    x_nslds_loan_ga_code_5              IN     VARCHAR2,
    x_nslds_loan_cont_type_5            IN     VARCHAR2,
    x_nslds_loan_schol_code_5           IN     VARCHAR2,
    x_nslds_loan_cont_code_5            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_5            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_5       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_5        IN     VARCHAR2,
    x_nslds_loan_seq_num_6              IN     NUMBER,
    x_nslds_loan_type_code_6            IN     VARCHAR2,
    x_nslds_loan_chng_f_6               IN     VARCHAR2,
    x_nslds_loan_prog_code_6            IN     VARCHAR2,
    x_nslds_loan_net_amnt_6             IN     NUMBER,
    x_nslds_loan_cur_st_code_6          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_6          IN     DATE,
    x_nslds_loan_agg_pr_bal_6           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_6        IN     DATE,
    x_nslds_loan_begin_dt_6             IN     DATE,
    x_nslds_loan_end_dt_6               IN     DATE,
    x_nslds_loan_ga_code_6              IN     VARCHAR2,
    x_nslds_loan_cont_type_6            IN     VARCHAR2,
    x_nslds_loan_schol_code_6           IN     VARCHAR2,
    x_nslds_loan_cont_code_6            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_6            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_6       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_6        IN     VARCHAR2,
    x_nslds_loan_last_d_amt_1           IN     NUMBER  ,
    x_nslds_loan_last_d_date_1          IN     DATE    ,
    x_nslds_loan_last_d_amt_2           IN     NUMBER  ,
    x_nslds_loan_last_d_date_2          IN     DATE    ,
    x_nslds_loan_last_d_amt_3           IN     NUMBER  ,
    x_nslds_loan_last_d_date_3          IN     DATE    ,
    x_nslds_loan_last_d_amt_4           IN     NUMBER  ,
    x_nslds_loan_last_d_date_4          IN     DATE    ,
    x_nslds_loan_last_d_amt_5           IN     NUMBER  ,
    x_nslds_loan_last_d_date_5          IN     DATE    ,
    x_nslds_loan_last_d_amt_6           IN     NUMBER  ,
    x_nslds_loan_last_d_date_6          IN     DATE    ,
    x_dlp_master_prom_note_flag         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_subsidized_loan_limit_type        IN     VARCHAR2,
    x_combined_loan_limit_type          IN     VARCHAR2,
    x_transaction_num_txt               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 06-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_nslds_data_all
      WHERE    nslds_id                          = x_nslds_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id			 igf_ap_nslds_data_all.org_id%TYPE := igf_aw_gen.get_org_id;

  BEGIN

    SELECT igf_ap_nslds_data_s.nextval INTO x_nslds_id
      FROM dual;


    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_nslds_id                          => x_nslds_id,
      x_isir_id                           => x_isir_id,
      x_base_id                           => x_base_id,
      x_nslds_transaction_num             => x_nslds_transaction_num,
      x_nslds_database_results_f          => x_nslds_database_results_f,
      x_nslds_f                           => x_nslds_f,
      x_nslds_pell_overpay_f              => x_nslds_pell_overpay_f,
      x_nslds_pell_overpay_contact        => x_nslds_pell_overpay_contact,
      x_nslds_seog_overpay_f              => x_nslds_seog_overpay_f,
      x_nslds_seog_overpay_contact        => x_nslds_seog_overpay_contact,
      x_nslds_perkins_overpay_f           => x_nslds_perkins_overpay_f,
      x_nslds_perkins_overpay_cntct       => x_nslds_perkins_overpay_cntct,
      x_nslds_defaulted_loan_f            => x_nslds_defaulted_loan_f,
      x_nslds_dischged_loan_chng_f        => x_nslds_dischged_loan_chng_f,
      x_nslds_satis_repay_f               => x_nslds_satis_repay_f,
      x_nslds_act_bankruptcy_f            => x_nslds_act_bankruptcy_f,
      x_nslds_agg_subsz_out_prin_bal      => x_nslds_agg_subsz_out_prin_bal,
      x_nslds_agg_unsbz_out_prin_bal      => x_nslds_agg_unsbz_out_prin_bal,
      x_nslds_agg_comb_out_prin_bal       => x_nslds_agg_comb_out_prin_bal,
      x_nslds_agg_cons_out_prin_bal       => x_nslds_agg_cons_out_prin_bal,
      x_nslds_agg_subsz_pend_dismt        => x_nslds_agg_subsz_pend_dismt,
      x_nslds_agg_unsbz_pend_dismt        => x_nslds_agg_unsbz_pend_dismt,
      x_nslds_agg_comb_pend_dismt         => x_nslds_agg_comb_pend_dismt,
      x_nslds_agg_subsz_total             => x_nslds_agg_subsz_total,
      x_nslds_agg_unsbz_total             => x_nslds_agg_unsbz_total,
      x_nslds_agg_comb_total              => x_nslds_agg_comb_total,
      x_nslds_agg_consd_total             => x_nslds_agg_consd_total,
      x_nslds_perkins_out_bal             => x_nslds_perkins_out_bal,
      x_nslds_perkins_cur_yr_dismnt       => x_nslds_perkins_cur_yr_dismnt,
      x_nslds_default_loan_chng_f         => x_nslds_default_loan_chng_f,
      x_nslds_discharged_loan_f           => x_nslds_discharged_loan_f,
      x_nslds_satis_repay_chng_f          => x_nslds_satis_repay_chng_f,
      x_nslds_act_bnkrupt_chng_f          => x_nslds_act_bnkrupt_chng_f,
      x_nslds_overpay_chng_f              => x_nslds_overpay_chng_f,
      x_nslds_agg_loan_chng_f             => x_nslds_agg_loan_chng_f,
      x_nslds_perkins_loan_chng_f         => x_nslds_perkins_loan_chng_f,
      x_nslds_pell_paymnt_chng_f          => x_nslds_pell_paymnt_chng_f,
      x_nslds_addtnl_pell_f               => x_nslds_addtnl_pell_f,
      x_nslds_addtnl_loan_f               => x_nslds_addtnl_loan_f,
      x_direct_loan_mas_prom_nt_f         => x_direct_loan_mas_prom_nt_f,
      x_nslds_pell_seq_num_1              => x_nslds_pell_seq_num_1,
      x_nslds_pell_verify_f_1             => x_nslds_pell_verify_f_1,
      x_nslds_pell_efc_1                  => x_nslds_pell_efc_1,
      x_nslds_pell_school_code_1          => x_nslds_pell_school_code_1,
      x_nslds_pell_transcn_num_1          => x_nslds_pell_transcn_num_1,
      x_nslds_pell_last_updt_dt_1         => x_nslds_pell_last_updt_dt_1,
      x_nslds_pell_scheduled_amt_1        => x_nslds_pell_scheduled_amt_1,
      x_nslds_pell_amt_paid_todt_1        => x_nslds_pell_amt_paid_todt_1,
      x_nslds_pell_remng_amt_1            => x_nslds_pell_remng_amt_1,
      x_nslds_pell_pc_schd_awd_us_1       => x_nslds_pell_pc_schd_awd_us_1,
      x_nslds_pell_award_amt_1            => x_nslds_pell_award_amt_1,
      x_nslds_pell_seq_num_2              => x_nslds_pell_seq_num_2,
      x_nslds_pell_verify_f_2             => x_nslds_pell_verify_f_2,
      x_nslds_pell_efc_2                  => x_nslds_pell_efc_2,
      x_nslds_pell_school_code_2          => x_nslds_pell_school_code_2,
      x_nslds_pell_transcn_num_2          => x_nslds_pell_transcn_num_2,
      x_nslds_pell_last_updt_dt_2         => x_nslds_pell_last_updt_dt_2,
      x_nslds_pell_scheduled_amt_2        => x_nslds_pell_scheduled_amt_2,
      x_nslds_pell_amt_paid_todt_2        => x_nslds_pell_amt_paid_todt_2,
      x_nslds_pell_remng_amt_2            => x_nslds_pell_remng_amt_2,
      x_nslds_pell_pc_schd_awd_us_2       => x_nslds_pell_pc_schd_awd_us_2,
      x_nslds_pell_award_amt_2            => x_nslds_pell_award_amt_2,
      x_nslds_pell_seq_num_3              => x_nslds_pell_seq_num_3,
      x_nslds_pell_verify_f_3             => x_nslds_pell_verify_f_3,
      x_nslds_pell_efc_3                  => x_nslds_pell_efc_3,
      x_nslds_pell_school_code_3          => x_nslds_pell_school_code_3,
      x_nslds_pell_transcn_num_3          => x_nslds_pell_transcn_num_3,
      x_nslds_pell_last_updt_dt_3         => x_nslds_pell_last_updt_dt_3,
      x_nslds_pell_scheduled_amt_3        => x_nslds_pell_scheduled_amt_3,
      x_nslds_pell_amt_paid_todt_3        => x_nslds_pell_amt_paid_todt_3,
      x_nslds_pell_remng_amt_3            => x_nslds_pell_remng_amt_3,
      x_nslds_pell_pc_schd_awd_us_3       => x_nslds_pell_pc_schd_awd_us_3,
      x_nslds_pell_award_amt_3            => x_nslds_pell_award_amt_3,
      x_nslds_loan_seq_num_1              => x_nslds_loan_seq_num_1,
      x_nslds_loan_type_code_1            => x_nslds_loan_type_code_1,
      x_nslds_loan_chng_f_1               => x_nslds_loan_chng_f_1,
      x_nslds_loan_prog_code_1            => x_nslds_loan_prog_code_1,
      x_nslds_loan_net_amnt_1             => x_nslds_loan_net_amnt_1,
      x_nslds_loan_cur_st_code_1          => x_nslds_loan_cur_st_code_1,
      x_nslds_loan_cur_st_date_1          => x_nslds_loan_cur_st_date_1,
      x_nslds_loan_agg_pr_bal_1           => x_nslds_loan_agg_pr_bal_1,
      x_nslds_loan_out_pr_bal_dt_1        => x_nslds_loan_out_pr_bal_dt_1,
      x_nslds_loan_begin_dt_1             => x_nslds_loan_begin_dt_1,
      x_nslds_loan_end_dt_1               => x_nslds_loan_end_dt_1,
      x_nslds_loan_ga_code_1              => x_nslds_loan_ga_code_1,
      x_nslds_loan_cont_type_1            => x_nslds_loan_cont_type_1,
      x_nslds_loan_schol_code_1           => x_nslds_loan_schol_code_1,
      x_nslds_loan_cont_code_1            => x_nslds_loan_cont_code_1,
      x_nslds_loan_grade_lvl_1            => x_nslds_loan_grade_lvl_1,
      x_nslds_loan_xtr_unsbz_ln_f_1       => x_nslds_loan_xtr_unsbz_ln_f_1,
      x_nslds_loan_capital_int_f_1        => x_nslds_loan_capital_int_f_1,
      x_nslds_loan_seq_num_2              => x_nslds_loan_seq_num_2,
      x_nslds_loan_type_code_2            => x_nslds_loan_type_code_2,
      x_nslds_loan_chng_f_2               => x_nslds_loan_chng_f_2,
      x_nslds_loan_prog_code_2            => x_nslds_loan_prog_code_2,
      x_nslds_loan_net_amnt_2             => x_nslds_loan_net_amnt_2,
      x_nslds_loan_cur_st_code_2          => x_nslds_loan_cur_st_code_2,
      x_nslds_loan_cur_st_date_2          => x_nslds_loan_cur_st_date_2,
      x_nslds_loan_agg_pr_bal_2           => x_nslds_loan_agg_pr_bal_2,
      x_nslds_loan_out_pr_bal_dt_2        => x_nslds_loan_out_pr_bal_dt_2,
      x_nslds_loan_begin_dt_2             => x_nslds_loan_begin_dt_2,
      x_nslds_loan_end_dt_2               => x_nslds_loan_end_dt_2,
      x_nslds_loan_ga_code_2              => x_nslds_loan_ga_code_2,
      x_nslds_loan_cont_type_2            => x_nslds_loan_cont_type_2,
      x_nslds_loan_schol_code_2           => x_nslds_loan_schol_code_2,
      x_nslds_loan_cont_code_2            => x_nslds_loan_cont_code_2,
      x_nslds_loan_grade_lvl_2            => x_nslds_loan_grade_lvl_2,
      x_nslds_loan_xtr_unsbz_ln_f_2       => x_nslds_loan_xtr_unsbz_ln_f_2,
      x_nslds_loan_capital_int_f_2        => x_nslds_loan_capital_int_f_2,
      x_nslds_loan_seq_num_3              => x_nslds_loan_seq_num_3,
      x_nslds_loan_type_code_3            => x_nslds_loan_type_code_3,
      x_nslds_loan_chng_f_3               => x_nslds_loan_chng_f_3,
      x_nslds_loan_prog_code_3            => x_nslds_loan_prog_code_3,
      x_nslds_loan_net_amnt_3             => x_nslds_loan_net_amnt_3,
      x_nslds_loan_cur_st_code_3          => x_nslds_loan_cur_st_code_3,
      x_nslds_loan_cur_st_date_3          => x_nslds_loan_cur_st_date_3,
      x_nslds_loan_agg_pr_bal_3           => x_nslds_loan_agg_pr_bal_3,
      x_nslds_loan_out_pr_bal_dt_3        => x_nslds_loan_out_pr_bal_dt_3,
      x_nslds_loan_begin_dt_3             => x_nslds_loan_begin_dt_3,
      x_nslds_loan_end_dt_3               => x_nslds_loan_end_dt_3,
      x_nslds_loan_ga_code_3              => x_nslds_loan_ga_code_3,
      x_nslds_loan_cont_type_3            => x_nslds_loan_cont_type_3,
      x_nslds_loan_schol_code_3           => x_nslds_loan_schol_code_3,
      x_nslds_loan_cont_code_3            => x_nslds_loan_cont_code_3,
      x_nslds_loan_grade_lvl_3            => x_nslds_loan_grade_lvl_3,
      x_nslds_loan_xtr_unsbz_ln_f_3       => x_nslds_loan_xtr_unsbz_ln_f_3,
      x_nslds_loan_capital_int_f_3        => x_nslds_loan_capital_int_f_3,
      x_nslds_loan_seq_num_4              => x_nslds_loan_seq_num_4,
      x_nslds_loan_type_code_4            => x_nslds_loan_type_code_4,
      x_nslds_loan_chng_f_4               => x_nslds_loan_chng_f_4,
      x_nslds_loan_prog_code_4            => x_nslds_loan_prog_code_4,
      x_nslds_loan_net_amnt_4             => x_nslds_loan_net_amnt_4,
      x_nslds_loan_cur_st_code_4          => x_nslds_loan_cur_st_code_4,
      x_nslds_loan_cur_st_date_4          => x_nslds_loan_cur_st_date_4,
      x_nslds_loan_agg_pr_bal_4           => x_nslds_loan_agg_pr_bal_4,
      x_nslds_loan_out_pr_bal_dt_4        => x_nslds_loan_out_pr_bal_dt_4,
      x_nslds_loan_begin_dt_4             => x_nslds_loan_begin_dt_4,
      x_nslds_loan_end_dt_4               => x_nslds_loan_end_dt_4,
      x_nslds_loan_ga_code_4              => x_nslds_loan_ga_code_4,
      x_nslds_loan_cont_type_4            => x_nslds_loan_cont_type_4,
      x_nslds_loan_schol_code_4           => x_nslds_loan_schol_code_4,
      x_nslds_loan_cont_code_4            => x_nslds_loan_cont_code_4,
      x_nslds_loan_grade_lvl_4            => x_nslds_loan_grade_lvl_4,
      x_nslds_loan_xtr_unsbz_ln_f_4       => x_nslds_loan_xtr_unsbz_ln_f_4,
      x_nslds_loan_capital_int_f_4        => x_nslds_loan_capital_int_f_4,
      x_nslds_loan_seq_num_5              => x_nslds_loan_seq_num_5,
      x_nslds_loan_type_code_5            => x_nslds_loan_type_code_5,
      x_nslds_loan_chng_f_5               => x_nslds_loan_chng_f_5,
      x_nslds_loan_prog_code_5            => x_nslds_loan_prog_code_5,
      x_nslds_loan_net_amnt_5             => x_nslds_loan_net_amnt_5,
      x_nslds_loan_cur_st_code_5          => x_nslds_loan_cur_st_code_5,
      x_nslds_loan_cur_st_date_5          => x_nslds_loan_cur_st_date_5,
      x_nslds_loan_agg_pr_bal_5           => x_nslds_loan_agg_pr_bal_5,
      x_nslds_loan_out_pr_bal_dt_5        => x_nslds_loan_out_pr_bal_dt_5,
      x_nslds_loan_begin_dt_5             => x_nslds_loan_begin_dt_5,
      x_nslds_loan_end_dt_5               => x_nslds_loan_end_dt_5,
      x_nslds_loan_ga_code_5              => x_nslds_loan_ga_code_5,
      x_nslds_loan_cont_type_5            => x_nslds_loan_cont_type_5,
      x_nslds_loan_schol_code_5           => x_nslds_loan_schol_code_5,
      x_nslds_loan_cont_code_5            => x_nslds_loan_cont_code_5,
      x_nslds_loan_grade_lvl_5            => x_nslds_loan_grade_lvl_5,
      x_nslds_loan_xtr_unsbz_ln_f_5       => x_nslds_loan_xtr_unsbz_ln_f_5,
      x_nslds_loan_capital_int_f_5        => x_nslds_loan_capital_int_f_5,
      x_nslds_loan_seq_num_6              => x_nslds_loan_seq_num_6,
      x_nslds_loan_type_code_6            => x_nslds_loan_type_code_6,
      x_nslds_loan_chng_f_6               => x_nslds_loan_chng_f_6,
      x_nslds_loan_prog_code_6            => x_nslds_loan_prog_code_6,
      x_nslds_loan_net_amnt_6             => x_nslds_loan_net_amnt_6,
      x_nslds_loan_cur_st_code_6          => x_nslds_loan_cur_st_code_6,
      x_nslds_loan_cur_st_date_6          => x_nslds_loan_cur_st_date_6,
      x_nslds_loan_agg_pr_bal_6           => x_nslds_loan_agg_pr_bal_6,
      x_nslds_loan_out_pr_bal_dt_6        => x_nslds_loan_out_pr_bal_dt_6,
      x_nslds_loan_begin_dt_6             => x_nslds_loan_begin_dt_6,
      x_nslds_loan_end_dt_6               => x_nslds_loan_end_dt_6,
      x_nslds_loan_ga_code_6              => x_nslds_loan_ga_code_6,
      x_nslds_loan_cont_type_6            => x_nslds_loan_cont_type_6,
      x_nslds_loan_schol_code_6           => x_nslds_loan_schol_code_6,
      x_nslds_loan_cont_code_6            => x_nslds_loan_cont_code_6,
      x_nslds_loan_grade_lvl_6            => x_nslds_loan_grade_lvl_6,
      x_nslds_loan_xtr_unsbz_ln_f_6       => x_nslds_loan_xtr_unsbz_ln_f_6,
      x_nslds_loan_capital_int_f_6        => x_nslds_loan_capital_int_f_6,
      x_nslds_loan_last_d_amt_1           => x_nslds_loan_last_d_amt_1,
      x_nslds_loan_last_d_date_1	        => x_nslds_loan_last_d_date_1,
      x_nslds_loan_last_d_amt_2		        => x_nslds_loan_last_d_amt_2,
      x_nslds_loan_last_d_date_2	        => x_nslds_loan_last_d_date_2,
      x_nslds_loan_last_d_amt_3		        => x_nslds_loan_last_d_amt_3,
      x_nslds_loan_last_d_date_3	        => x_nslds_loan_last_d_date_3,
      x_nslds_loan_last_d_amt_4		        => x_nslds_loan_last_d_amt_4,
      x_nslds_loan_last_d_date_4	        => x_nslds_loan_last_d_date_4,
      x_nslds_loan_last_d_amt_5		        => x_nslds_loan_last_d_amt_5,
      x_nslds_loan_last_d_date_5	        => x_nslds_loan_last_d_date_5,
      x_nslds_loan_last_d_amt_6		        => x_nslds_loan_last_d_amt_6,
      x_nslds_loan_last_d_date_6	        => x_nslds_loan_last_d_date_6,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_dlp_master_prom_note_flag         => x_dlp_master_prom_note_flag,
      x_subsidized_loan_limit_type        => x_subsidized_loan_limit_type,
      x_combined_loan_limit_type          => x_combined_loan_limit_type,
      x_transaction_num_txt               => x_transaction_num_txt
    );

    INSERT INTO igf_ap_nslds_data_all (
      nslds_id,
      isir_id,
      base_id,
      nslds_transaction_num,
      nslds_database_results_f,
      nslds_f,
      nslds_pell_overpay_f,
      nslds_pell_overpay_contact,
      nslds_seog_overpay_f,
      nslds_seog_overpay_contact,
      nslds_perkins_overpay_f,
      nslds_perkins_overpay_cntct,
      nslds_defaulted_loan_f,
      nslds_dischged_loan_chng_f,
      nslds_satis_repay_f,
      nslds_act_bankruptcy_f,
      nslds_agg_subsz_out_prin_bal,
      nslds_agg_unsbz_out_prin_bal,
      nslds_agg_comb_out_prin_bal,
      nslds_agg_cons_out_prin_bal,
      nslds_agg_subsz_pend_dismt,
      nslds_agg_unsbz_pend_dismt,
      nslds_agg_comb_pend_dismt,
      nslds_agg_subsz_total,
      nslds_agg_unsbz_total,
      nslds_agg_comb_total,
      nslds_agg_consd_total,
      nslds_perkins_out_bal,
      nslds_perkins_cur_yr_dismnt,
      nslds_default_loan_chng_f,
      nslds_discharged_loan_f,
      nslds_satis_repay_chng_f,
      nslds_act_bnkrupt_chng_f,
      nslds_overpay_chng_f,
      nslds_agg_loan_chng_f,
      nslds_perkins_loan_chng_f,
      nslds_pell_paymnt_chng_f,
      nslds_addtnl_pell_f,
      nslds_addtnl_loan_f,
      direct_loan_mas_prom_nt_f,
      nslds_pell_seq_num_1,
      nslds_pell_verify_f_1,
      nslds_pell_efc_1,
      nslds_pell_school_code_1,
      nslds_pell_transcn_num_1,
      nslds_pell_last_updt_dt_1,
      nslds_pell_scheduled_amt_1,
      nslds_pell_amt_paid_todt_1,
      nslds_pell_remng_amt_1,
      nslds_pell_pc_schd_awd_us_1,
      nslds_pell_award_amt_1,
      nslds_pell_seq_num_2,
      nslds_pell_verify_f_2,
      nslds_pell_efc_2,
      nslds_pell_school_code_2,
      nslds_pell_transcn_num_2,
      nslds_pell_last_updt_dt_2,
      nslds_pell_scheduled_amt_2,
      nslds_pell_amt_paid_todt_2,
      nslds_pell_remng_amt_2,
      nslds_pell_pc_schd_awd_us_2,
      nslds_pell_award_amt_2,
      nslds_pell_seq_num_3,
      nslds_pell_verify_f_3,
      nslds_pell_efc_3,
      nslds_pell_school_code_3,
      nslds_pell_transcn_num_3,
      nslds_pell_last_updt_dt_3,
      nslds_pell_scheduled_amt_3,
      nslds_pell_amt_paid_todt_3,
      nslds_pell_remng_amt_3,
      nslds_pell_pc_schd_awd_us_3,
      nslds_pell_award_amt_3,
      nslds_loan_seq_num_1,
      nslds_loan_type_code_1,
      nslds_loan_chng_f_1,
      nslds_loan_prog_code_1,
      nslds_loan_net_amnt_1,
      nslds_loan_cur_st_code_1,
      nslds_loan_cur_st_date_1,
      nslds_loan_agg_pr_bal_1,
      nslds_loan_out_pr_bal_dt_1,
      nslds_loan_begin_dt_1,
      nslds_loan_end_dt_1,
      nslds_loan_ga_code_1,
      nslds_loan_cont_type_1,
      nslds_loan_schol_code_1,
      nslds_loan_cont_code_1,
      nslds_loan_grade_lvl_1,
      nslds_loan_xtr_unsbz_ln_f_1,
      nslds_loan_capital_int_f_1,
      nslds_loan_seq_num_2,
      nslds_loan_type_code_2,
      nslds_loan_chng_f_2,
      nslds_loan_prog_code_2,
      nslds_loan_net_amnt_2,
      nslds_loan_cur_st_code_2,
      nslds_loan_cur_st_date_2,
      nslds_loan_agg_pr_bal_2,
      nslds_loan_out_pr_bal_dt_2,
      nslds_loan_begin_dt_2,
      nslds_loan_end_dt_2,
      nslds_loan_ga_code_2,
      nslds_loan_cont_type_2,
      nslds_loan_schol_code_2,
      nslds_loan_cont_code_2,
      nslds_loan_grade_lvl_2,
      nslds_loan_xtr_unsbz_ln_f_2,
      nslds_loan_capital_int_f_2,
      nslds_loan_seq_num_3,
      nslds_loan_type_code_3,
      nslds_loan_chng_f_3,
      nslds_loan_prog_code_3,
      nslds_loan_net_amnt_3,
      nslds_loan_cur_st_code_3,
      nslds_loan_cur_st_date_3,
      nslds_loan_agg_pr_bal_3,
      nslds_loan_out_pr_bal_dt_3,
      nslds_loan_begin_dt_3,
      nslds_loan_end_dt_3,
      nslds_loan_ga_code_3,
      nslds_loan_cont_type_3,
      nslds_loan_schol_code_3,
      nslds_loan_cont_code_3,
      nslds_loan_grade_lvl_3,
      nslds_loan_xtr_unsbz_ln_f_3,
      nslds_loan_capital_int_f_3,
      nslds_loan_seq_num_4,
      nslds_loan_type_code_4,
      nslds_loan_chng_f_4,
      nslds_loan_prog_code_4,
      nslds_loan_net_amnt_4,
      nslds_loan_cur_st_code_4,
      nslds_loan_cur_st_date_4,
      nslds_loan_agg_pr_bal_4,
      nslds_loan_out_pr_bal_dt_4,
      nslds_loan_begin_dt_4,
      nslds_loan_end_dt_4,
      nslds_loan_ga_code_4,
      nslds_loan_cont_type_4,
      nslds_loan_schol_code_4,
      nslds_loan_cont_code_4,
      nslds_loan_grade_lvl_4,
      nslds_loan_xtr_unsbz_ln_f_4,
      nslds_loan_capital_int_f_4,
      nslds_loan_seq_num_5,
      nslds_loan_type_code_5,
      nslds_loan_chng_f_5,
      nslds_loan_prog_code_5,
      nslds_loan_net_amnt_5,
      nslds_loan_cur_st_code_5,
      nslds_loan_cur_st_date_5,
      nslds_loan_agg_pr_bal_5,
      nslds_loan_out_pr_bal_dt_5,
      nslds_loan_begin_dt_5,
      nslds_loan_end_dt_5,
      nslds_loan_ga_code_5,
      nslds_loan_cont_type_5,
      nslds_loan_schol_code_5,
      nslds_loan_cont_code_5,
      nslds_loan_grade_lvl_5,
      nslds_loan_xtr_unsbz_ln_f_5,
      nslds_loan_capital_int_f_5,
      nslds_loan_seq_num_6,
      nslds_loan_type_code_6,
      nslds_loan_chng_f_6,
      nslds_loan_prog_code_6,
      nslds_loan_net_amnt_6,
      nslds_loan_cur_st_code_6,
      nslds_loan_cur_st_date_6,
      nslds_loan_agg_pr_bal_6,
      nslds_loan_out_pr_bal_dt_6,
      nslds_loan_begin_dt_6,
      nslds_loan_end_dt_6,
      nslds_loan_ga_code_6,
      nslds_loan_cont_type_6,
      nslds_loan_schol_code_6,
      nslds_loan_cont_code_6,
      nslds_loan_grade_lvl_6,
      nslds_loan_xtr_unsbz_ln_f_6,
      nslds_loan_capital_int_f_6,
      nslds_loan_last_d_amt_1,
      nslds_loan_last_d_date_1,
      nslds_loan_last_d_amt_2,
      nslds_loan_last_d_date_2,
      nslds_loan_last_d_amt_3,
      nslds_loan_last_d_date_3,
      nslds_loan_last_d_amt_4,
      nslds_loan_last_d_date_4,
      nslds_loan_last_d_amt_5,
      nslds_loan_last_d_date_5,
      nslds_loan_last_d_amt_6,
      nslds_loan_last_d_date_6,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      org_id,
      dlp_master_prom_note_flag,
      subsidized_loan_limit_type,
      combined_loan_limit_type,
      transaction_num_txt
    ) VALUES (
      new_references.nslds_id,
      new_references.isir_id,
      new_references.base_id,
      new_references.nslds_transaction_num,
      new_references.nslds_database_results_f,
      new_references.nslds_f,
      new_references.nslds_pell_overpay_f,
      new_references.nslds_pell_overpay_contact,
      new_references.nslds_seog_overpay_f,
      new_references.nslds_seog_overpay_contact,
      new_references.nslds_perkins_overpay_f,
      new_references.nslds_perkins_overpay_cntct,
      new_references.nslds_defaulted_loan_f,
      new_references.nslds_dischged_loan_chng_f,
      new_references.nslds_satis_repay_f,
      new_references.nslds_act_bankruptcy_f,
      new_references.nslds_agg_subsz_out_prin_bal,
      new_references.nslds_agg_unsbz_out_prin_bal,
      new_references.nslds_agg_comb_out_prin_bal,
      new_references.nslds_agg_cons_out_prin_bal,
      new_references.nslds_agg_subsz_pend_dismt,
      new_references.nslds_agg_unsbz_pend_dismt,
      new_references.nslds_agg_comb_pend_dismt,
      new_references.nslds_agg_subsz_total,
      new_references.nslds_agg_unsbz_total,
      new_references.nslds_agg_comb_total,
      new_references.nslds_agg_consd_total,
      new_references.nslds_perkins_out_bal,
      new_references.nslds_perkins_cur_yr_dismnt,
      new_references.nslds_default_loan_chng_f,
      new_references.nslds_discharged_loan_f,
      new_references.nslds_satis_repay_chng_f,
      new_references.nslds_act_bnkrupt_chng_f,
      new_references.nslds_overpay_chng_f,
      new_references.nslds_agg_loan_chng_f,
      new_references.nslds_perkins_loan_chng_f,
      new_references.nslds_pell_paymnt_chng_f,
      new_references.nslds_addtnl_pell_f,
      new_references.nslds_addtnl_loan_f,
      new_references.direct_loan_mas_prom_nt_f,
      new_references.nslds_pell_seq_num_1,
      new_references.nslds_pell_verify_f_1,
      new_references.nslds_pell_efc_1,
      new_references.nslds_pell_school_code_1,
      new_references.nslds_pell_transcn_num_1,
      new_references.nslds_pell_last_updt_dt_1,
      new_references.nslds_pell_scheduled_amt_1,
      new_references.nslds_pell_amt_paid_todt_1,
      new_references.nslds_pell_remng_amt_1,
      new_references.nslds_pell_pc_schd_awd_us_1,
      new_references.nslds_pell_award_amt_1,
      new_references.nslds_pell_seq_num_2,
      new_references.nslds_pell_verify_f_2,
      new_references.nslds_pell_efc_2,
      new_references.nslds_pell_school_code_2,
      new_references.nslds_pell_transcn_num_2,
      new_references.nslds_pell_last_updt_dt_2,
      new_references.nslds_pell_scheduled_amt_2,
      new_references.nslds_pell_amt_paid_todt_2,
      new_references.nslds_pell_remng_amt_2,
      new_references.nslds_pell_pc_schd_awd_us_2,
      new_references.nslds_pell_award_amt_2,
      new_references.nslds_pell_seq_num_3,
      new_references.nslds_pell_verify_f_3,
      new_references.nslds_pell_efc_3,
      new_references.nslds_pell_school_code_3,
      new_references.nslds_pell_transcn_num_3,
      new_references.nslds_pell_last_updt_dt_3,
      new_references.nslds_pell_scheduled_amt_3,
      new_references.nslds_pell_amt_paid_todt_3,
      new_references.nslds_pell_remng_amt_3,
      new_references.nslds_pell_pc_schd_awd_us_3,
      new_references.nslds_pell_award_amt_3,
      new_references.nslds_loan_seq_num_1,
      new_references.nslds_loan_type_code_1,
      new_references.nslds_loan_chng_f_1,
      new_references.nslds_loan_prog_code_1,
      new_references.nslds_loan_net_amnt_1,
      new_references.nslds_loan_cur_st_code_1,
      new_references.nslds_loan_cur_st_date_1,
      new_references.nslds_loan_agg_pr_bal_1,
      new_references.nslds_loan_out_pr_bal_dt_1,
      new_references.nslds_loan_begin_dt_1,
      new_references.nslds_loan_end_dt_1,
      new_references.nslds_loan_ga_code_1,
      new_references.nslds_loan_cont_type_1,
      new_references.nslds_loan_schol_code_1,
      new_references.nslds_loan_cont_code_1,
      new_references.nslds_loan_grade_lvl_1,
      new_references.nslds_loan_xtr_unsbz_ln_f_1,
      new_references.nslds_loan_capital_int_f_1,
      new_references.nslds_loan_seq_num_2,
      new_references.nslds_loan_type_code_2,
      new_references.nslds_loan_chng_f_2,
      new_references.nslds_loan_prog_code_2,
      new_references.nslds_loan_net_amnt_2,
      new_references.nslds_loan_cur_st_code_2,
      new_references.nslds_loan_cur_st_date_2,
      new_references.nslds_loan_agg_pr_bal_2,
      new_references.nslds_loan_out_pr_bal_dt_2,
      new_references.nslds_loan_begin_dt_2,
      new_references.nslds_loan_end_dt_2,
      new_references.nslds_loan_ga_code_2,
      new_references.nslds_loan_cont_type_2,
      new_references.nslds_loan_schol_code_2,
      new_references.nslds_loan_cont_code_2,
      new_references.nslds_loan_grade_lvl_2,
      new_references.nslds_loan_xtr_unsbz_ln_f_2,
      new_references.nslds_loan_capital_int_f_2,
      new_references.nslds_loan_seq_num_3,
      new_references.nslds_loan_type_code_3,
      new_references.nslds_loan_chng_f_3,
      new_references.nslds_loan_prog_code_3,
      new_references.nslds_loan_net_amnt_3,
      new_references.nslds_loan_cur_st_code_3,
      new_references.nslds_loan_cur_st_date_3,
      new_references.nslds_loan_agg_pr_bal_3,
      new_references.nslds_loan_out_pr_bal_dt_3,
      new_references.nslds_loan_begin_dt_3,
      new_references.nslds_loan_end_dt_3,
      new_references.nslds_loan_ga_code_3,
      new_references.nslds_loan_cont_type_3,
      new_references.nslds_loan_schol_code_3,
      new_references.nslds_loan_cont_code_3,
      new_references.nslds_loan_grade_lvl_3,
      new_references.nslds_loan_xtr_unsbz_ln_f_3,
      new_references.nslds_loan_capital_int_f_3,
      new_references.nslds_loan_seq_num_4,
      new_references.nslds_loan_type_code_4,
      new_references.nslds_loan_chng_f_4,
      new_references.nslds_loan_prog_code_4,
      new_references.nslds_loan_net_amnt_4,
      new_references.nslds_loan_cur_st_code_4,
      new_references.nslds_loan_cur_st_date_4,
      new_references.nslds_loan_agg_pr_bal_4,
      new_references.nslds_loan_out_pr_bal_dt_4,
      new_references.nslds_loan_begin_dt_4,
      new_references.nslds_loan_end_dt_4,
      new_references.nslds_loan_ga_code_4,
      new_references.nslds_loan_cont_type_4,
      new_references.nslds_loan_schol_code_4,
      new_references.nslds_loan_cont_code_4,
      new_references.nslds_loan_grade_lvl_4,
      new_references.nslds_loan_xtr_unsbz_ln_f_4,
      new_references.nslds_loan_capital_int_f_4,
      new_references.nslds_loan_seq_num_5,
      new_references.nslds_loan_type_code_5,
      new_references.nslds_loan_chng_f_5,
      new_references.nslds_loan_prog_code_5,
      new_references.nslds_loan_net_amnt_5,
      new_references.nslds_loan_cur_st_code_5,
      new_references.nslds_loan_cur_st_date_5,
      new_references.nslds_loan_agg_pr_bal_5,
      new_references.nslds_loan_out_pr_bal_dt_5,
      new_references.nslds_loan_begin_dt_5,
      new_references.nslds_loan_end_dt_5,
      new_references.nslds_loan_ga_code_5,
      new_references.nslds_loan_cont_type_5,
      new_references.nslds_loan_schol_code_5,
      new_references.nslds_loan_cont_code_5,
      new_references.nslds_loan_grade_lvl_5,
      new_references.nslds_loan_xtr_unsbz_ln_f_5,
      new_references.nslds_loan_capital_int_f_5,
      new_references.nslds_loan_seq_num_6,
      new_references.nslds_loan_type_code_6,
      new_references.nslds_loan_chng_f_6,
      new_references.nslds_loan_prog_code_6,
      new_references.nslds_loan_net_amnt_6,
      new_references.nslds_loan_cur_st_code_6,
      new_references.nslds_loan_cur_st_date_6,
      new_references.nslds_loan_agg_pr_bal_6,
      new_references.nslds_loan_out_pr_bal_dt_6,
      new_references.nslds_loan_begin_dt_6,
      new_references.nslds_loan_end_dt_6,
      new_references.nslds_loan_ga_code_6,
      new_references.nslds_loan_cont_type_6,
      new_references.nslds_loan_schol_code_6,
      new_references.nslds_loan_cont_code_6,
      new_references.nslds_loan_grade_lvl_6,
      new_references.nslds_loan_xtr_unsbz_ln_f_6,
      new_references.nslds_loan_capital_int_f_6,
      new_references.nslds_loan_last_d_amt_1,
      new_references.nslds_loan_last_d_date_1,
      new_references.nslds_loan_last_d_amt_2,
      new_references.nslds_loan_last_d_date_2,
      new_references.nslds_loan_last_d_amt_3,
      new_references.nslds_loan_last_d_date_3,
      new_references.nslds_loan_last_d_amt_4,
      new_references.nslds_loan_last_d_date_4,
      new_references.nslds_loan_last_d_amt_5,
      new_references.nslds_loan_last_d_date_5,
      new_references.nslds_loan_last_d_amt_6,
      new_references.nslds_loan_last_d_date_6,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      l_org_id,
      new_references.dlp_master_prom_note_flag,
      new_references.subsidized_loan_limit_type,
      new_references.combined_loan_limit_type,
      new_references.transaction_num_txt
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_nslds_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_nslds_transaction_num             IN     NUMBER,
    x_nslds_database_results_f          IN     VARCHAR2,
    x_nslds_f                           IN     VARCHAR2,
    x_nslds_pell_overpay_f              IN     VARCHAR2,
    x_nslds_pell_overpay_contact        IN     VARCHAR2,
    x_nslds_seog_overpay_f              IN     VARCHAR2,
    x_nslds_seog_overpay_contact        IN     VARCHAR2,
    x_nslds_perkins_overpay_f           IN     VARCHAR2,
    x_nslds_perkins_overpay_cntct       IN     VARCHAR2,
    x_nslds_defaulted_loan_f            IN     VARCHAR2,
    x_nslds_dischged_loan_chng_f        IN     VARCHAR2,
    x_nslds_satis_repay_f               IN     VARCHAR2,
    x_nslds_act_bankruptcy_f            IN     VARCHAR2,
    x_nslds_agg_subsz_out_prin_bal      IN     NUMBER,
    x_nslds_agg_unsbz_out_prin_bal      IN     NUMBER,
    x_nslds_agg_comb_out_prin_bal       IN     NUMBER,
    x_nslds_agg_cons_out_prin_bal       IN     NUMBER,
    x_nslds_agg_subsz_pend_dismt        IN     NUMBER,
    x_nslds_agg_unsbz_pend_dismt        IN     NUMBER,
    x_nslds_agg_comb_pend_dismt         IN     NUMBER,
    x_nslds_agg_subsz_total             IN     NUMBER,
    x_nslds_agg_unsbz_total             IN     NUMBER,
    x_nslds_agg_comb_total              IN     NUMBER,
    x_nslds_agg_consd_total             IN     NUMBER,
    x_nslds_perkins_out_bal             IN     NUMBER,
    x_nslds_perkins_cur_yr_dismnt       IN     NUMBER,
    x_nslds_default_loan_chng_f         IN     VARCHAR2,
    x_nslds_discharged_loan_f           IN     VARCHAR2,
    x_nslds_satis_repay_chng_f          IN     VARCHAR2,
    x_nslds_act_bnkrupt_chng_f          IN     VARCHAR2,
    x_nslds_overpay_chng_f              IN     VARCHAR2,
    x_nslds_agg_loan_chng_f             IN     VARCHAR2,
    x_nslds_perkins_loan_chng_f         IN     VARCHAR2,
    x_nslds_pell_paymnt_chng_f          IN     VARCHAR2,
    x_nslds_addtnl_pell_f               IN     VARCHAR2,
    x_nslds_addtnl_loan_f               IN     VARCHAR2,
    x_direct_loan_mas_prom_nt_f         IN     VARCHAR2,
    x_nslds_pell_seq_num_1              IN     NUMBER,
    x_nslds_pell_verify_f_1             IN     VARCHAR2,
    x_nslds_pell_efc_1                  IN     NUMBER,
    x_nslds_pell_school_code_1          IN     NUMBER,
    x_nslds_pell_transcn_num_1          IN     NUMBER,
    x_nslds_pell_last_updt_dt_1         IN     DATE,
    x_nslds_pell_scheduled_amt_1        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_1        IN     NUMBER,
    x_nslds_pell_remng_amt_1            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_1       IN     NUMBER,
    x_nslds_pell_award_amt_1            IN     NUMBER,
    x_nslds_pell_seq_num_2              IN     NUMBER,
    x_nslds_pell_verify_f_2             IN     VARCHAR2,
    x_nslds_pell_efc_2                  IN     NUMBER,
    x_nslds_pell_school_code_2          IN     NUMBER,
    x_nslds_pell_transcn_num_2          IN     NUMBER,
    x_nslds_pell_last_updt_dt_2         IN     DATE,
    x_nslds_pell_scheduled_amt_2        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_2        IN     NUMBER,
    x_nslds_pell_remng_amt_2            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_2       IN     NUMBER,
    x_nslds_pell_award_amt_2            IN     NUMBER,
    x_nslds_pell_seq_num_3              IN     NUMBER,
    x_nslds_pell_verify_f_3             IN     VARCHAR2,
    x_nslds_pell_efc_3                  IN     NUMBER,
    x_nslds_pell_school_code_3          IN     NUMBER,
    x_nslds_pell_transcn_num_3          IN     NUMBER,
    x_nslds_pell_last_updt_dt_3         IN     DATE,
    x_nslds_pell_scheduled_amt_3        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_3        IN     NUMBER,
    x_nslds_pell_remng_amt_3            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_3       IN     NUMBER,
    x_nslds_pell_award_amt_3            IN     NUMBER,
    x_nslds_loan_seq_num_1              IN     NUMBER,
    x_nslds_loan_type_code_1            IN     VARCHAR2,
    x_nslds_loan_chng_f_1               IN     VARCHAR2,
    x_nslds_loan_prog_code_1            IN     VARCHAR2,
    x_nslds_loan_net_amnt_1             IN     NUMBER,
    x_nslds_loan_cur_st_code_1          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_1          IN     DATE,
    x_nslds_loan_agg_pr_bal_1           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_1        IN     DATE,
    x_nslds_loan_begin_dt_1             IN     DATE,
    x_nslds_loan_end_dt_1               IN     DATE,
    x_nslds_loan_ga_code_1              IN     VARCHAR2,
    x_nslds_loan_cont_type_1            IN     VARCHAR2,
    x_nslds_loan_schol_code_1           IN     VARCHAR2,
    x_nslds_loan_cont_code_1            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_1            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_1       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_1        IN     VARCHAR2,
    x_nslds_loan_seq_num_2              IN     NUMBER,
    x_nslds_loan_type_code_2            IN     VARCHAR2,
    x_nslds_loan_chng_f_2               IN     VARCHAR2,
    x_nslds_loan_prog_code_2            IN     VARCHAR2,
    x_nslds_loan_net_amnt_2             IN     NUMBER,
    x_nslds_loan_cur_st_code_2          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_2          IN     DATE,
    x_nslds_loan_agg_pr_bal_2           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_2        IN     DATE,
    x_nslds_loan_begin_dt_2             IN     DATE,
    x_nslds_loan_end_dt_2               IN     DATE,
    x_nslds_loan_ga_code_2              IN     VARCHAR2,
    x_nslds_loan_cont_type_2            IN     VARCHAR2,
    x_nslds_loan_schol_code_2           IN     VARCHAR2,
    x_nslds_loan_cont_code_2            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_2            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_2       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_2        IN     VARCHAR2,
    x_nslds_loan_seq_num_3              IN     NUMBER,
    x_nslds_loan_type_code_3            IN     VARCHAR2,
    x_nslds_loan_chng_f_3               IN     VARCHAR2,
    x_nslds_loan_prog_code_3            IN     VARCHAR2,
    x_nslds_loan_net_amnt_3             IN     NUMBER,
    x_nslds_loan_cur_st_code_3          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_3          IN     DATE,
    x_nslds_loan_agg_pr_bal_3           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_3        IN     DATE,
    x_nslds_loan_begin_dt_3             IN     DATE,
    x_nslds_loan_end_dt_3               IN     DATE,
    x_nslds_loan_ga_code_3              IN     VARCHAR2,
    x_nslds_loan_cont_type_3            IN     VARCHAR2,
    x_nslds_loan_schol_code_3           IN     VARCHAR2,
    x_nslds_loan_cont_code_3            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_3            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_3       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_3        IN     VARCHAR2,
    x_nslds_loan_seq_num_4              IN     NUMBER,
    x_nslds_loan_type_code_4            IN     VARCHAR2,
    x_nslds_loan_chng_f_4               IN     VARCHAR2,
    x_nslds_loan_prog_code_4            IN     VARCHAR2,
    x_nslds_loan_net_amnt_4             IN     NUMBER,
    x_nslds_loan_cur_st_code_4          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_4          IN     DATE,
    x_nslds_loan_agg_pr_bal_4           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_4        IN     DATE,
    x_nslds_loan_begin_dt_4             IN     DATE,
    x_nslds_loan_end_dt_4               IN     DATE,
    x_nslds_loan_ga_code_4              IN     VARCHAR2,
    x_nslds_loan_cont_type_4            IN     VARCHAR2,
    x_nslds_loan_schol_code_4           IN     VARCHAR2,
    x_nslds_loan_cont_code_4            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_4            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_4       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_4        IN     VARCHAR2,
    x_nslds_loan_seq_num_5              IN     NUMBER,
    x_nslds_loan_type_code_5            IN     VARCHAR2,
    x_nslds_loan_chng_f_5               IN     VARCHAR2,
    x_nslds_loan_prog_code_5            IN     VARCHAR2,
    x_nslds_loan_net_amnt_5             IN     NUMBER,
    x_nslds_loan_cur_st_code_5          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_5          IN     DATE,
    x_nslds_loan_agg_pr_bal_5           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_5        IN     DATE,
    x_nslds_loan_begin_dt_5             IN     DATE,
    x_nslds_loan_end_dt_5               IN     DATE,
    x_nslds_loan_ga_code_5              IN     VARCHAR2,
    x_nslds_loan_cont_type_5            IN     VARCHAR2,
    x_nslds_loan_schol_code_5           IN     VARCHAR2,
    x_nslds_loan_cont_code_5            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_5            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_5       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_5        IN     VARCHAR2,
    x_nslds_loan_seq_num_6              IN     NUMBER,
    x_nslds_loan_type_code_6            IN     VARCHAR2,
    x_nslds_loan_chng_f_6               IN     VARCHAR2,
    x_nslds_loan_prog_code_6            IN     VARCHAR2,
    x_nslds_loan_net_amnt_6             IN     NUMBER,
    x_nslds_loan_cur_st_code_6          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_6          IN     DATE,
    x_nslds_loan_agg_pr_bal_6           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_6        IN     DATE,
    x_nslds_loan_begin_dt_6             IN     DATE,
    x_nslds_loan_end_dt_6               IN     DATE,
    x_nslds_loan_ga_code_6              IN     VARCHAR2,
    x_nslds_loan_cont_type_6            IN     VARCHAR2,
    x_nslds_loan_schol_code_6           IN     VARCHAR2,
    x_nslds_loan_cont_code_6            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_6            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_6       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_6        IN     VARCHAR2,
    x_nslds_loan_last_d_amt_1           IN     NUMBER  ,
    x_nslds_loan_last_d_date_1          IN     DATE    ,
    x_nslds_loan_last_d_amt_2           IN     NUMBER  ,
    x_nslds_loan_last_d_date_2          IN     DATE    ,
    x_nslds_loan_last_d_amt_3           IN     NUMBER  ,
    x_nslds_loan_last_d_date_3          IN     DATE    ,
    x_nslds_loan_last_d_amt_4           IN     NUMBER  ,
    x_nslds_loan_last_d_date_4          IN     DATE    ,
    x_nslds_loan_last_d_amt_5           IN     NUMBER  ,
    x_nslds_loan_last_d_date_5          IN     DATE    ,
    x_nslds_loan_last_d_amt_6           IN     NUMBER  ,
    x_nslds_loan_last_d_date_6          IN     DATE    ,
    x_dlp_master_prom_note_flag         IN     VARCHAR2,
    x_subsidized_loan_limit_type        IN     VARCHAR2,
    x_combined_loan_limit_type          IN     VARCHAR2,
    x_transaction_num_txt               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 06-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        isir_id,
        base_id,
        nslds_transaction_num,
        nslds_database_results_f,
        nslds_f,
        nslds_pell_overpay_f,
        nslds_pell_overpay_contact,
        nslds_seog_overpay_f,
        nslds_seog_overpay_contact,
        nslds_perkins_overpay_f,
        nslds_perkins_overpay_cntct,
        nslds_defaulted_loan_f,
        nslds_dischged_loan_chng_f,
        nslds_satis_repay_f,
        nslds_act_bankruptcy_f,
        nslds_agg_subsz_out_prin_bal,
        nslds_agg_unsbz_out_prin_bal,
        nslds_agg_comb_out_prin_bal,
        nslds_agg_cons_out_prin_bal,
        nslds_agg_subsz_pend_dismt,
        nslds_agg_unsbz_pend_dismt,
        nslds_agg_comb_pend_dismt,
        nslds_agg_subsz_total,
        nslds_agg_unsbz_total,
        nslds_agg_comb_total,
        nslds_agg_consd_total,
        nslds_perkins_out_bal,
        nslds_perkins_cur_yr_dismnt,
        nslds_default_loan_chng_f,
        nslds_discharged_loan_f,
        nslds_satis_repay_chng_f,
        nslds_act_bnkrupt_chng_f,
        nslds_overpay_chng_f,
        nslds_agg_loan_chng_f,
        nslds_perkins_loan_chng_f,
        nslds_pell_paymnt_chng_f,
        nslds_addtnl_pell_f,
        nslds_addtnl_loan_f,
        direct_loan_mas_prom_nt_f,
        nslds_pell_seq_num_1,
        nslds_pell_verify_f_1,
        nslds_pell_efc_1,
        nslds_pell_school_code_1,
        nslds_pell_transcn_num_1,
        nslds_pell_last_updt_dt_1,
        nslds_pell_scheduled_amt_1,
        nslds_pell_amt_paid_todt_1,
        nslds_pell_remng_amt_1,
        nslds_pell_pc_schd_awd_us_1,
        nslds_pell_award_amt_1,
        nslds_pell_seq_num_2,
        nslds_pell_verify_f_2,
        nslds_pell_efc_2,
        nslds_pell_school_code_2,
        nslds_pell_transcn_num_2,
        nslds_pell_last_updt_dt_2,
        nslds_pell_scheduled_amt_2,
        nslds_pell_amt_paid_todt_2,
        nslds_pell_remng_amt_2,
        nslds_pell_pc_schd_awd_us_2,
        nslds_pell_award_amt_2,
        nslds_pell_seq_num_3,
        nslds_pell_verify_f_3,
        nslds_pell_efc_3,
        nslds_pell_school_code_3,
        nslds_pell_transcn_num_3,
        nslds_pell_last_updt_dt_3,
        nslds_pell_scheduled_amt_3,
        nslds_pell_amt_paid_todt_3,
        nslds_pell_remng_amt_3,
        nslds_pell_pc_schd_awd_us_3,
        nslds_pell_award_amt_3,
        nslds_loan_seq_num_1,
        nslds_loan_type_code_1,
        nslds_loan_chng_f_1,
        nslds_loan_prog_code_1,
        nslds_loan_net_amnt_1,
        nslds_loan_cur_st_code_1,
        nslds_loan_cur_st_date_1,
        nslds_loan_agg_pr_bal_1,
        nslds_loan_out_pr_bal_dt_1,
        nslds_loan_begin_dt_1,
        nslds_loan_end_dt_1,
        nslds_loan_ga_code_1,
        nslds_loan_cont_type_1,
        nslds_loan_schol_code_1,
        nslds_loan_cont_code_1,
        nslds_loan_grade_lvl_1,
        nslds_loan_xtr_unsbz_ln_f_1,
        nslds_loan_capital_int_f_1,
        nslds_loan_seq_num_2,
        nslds_loan_type_code_2,
        nslds_loan_chng_f_2,
        nslds_loan_prog_code_2,
        nslds_loan_net_amnt_2,
        nslds_loan_cur_st_code_2,
        nslds_loan_cur_st_date_2,
        nslds_loan_agg_pr_bal_2,
        nslds_loan_out_pr_bal_dt_2,
        nslds_loan_begin_dt_2,
        nslds_loan_end_dt_2,
        nslds_loan_ga_code_2,
        nslds_loan_cont_type_2,
        nslds_loan_schol_code_2,
        nslds_loan_cont_code_2,
        nslds_loan_grade_lvl_2,
        nslds_loan_xtr_unsbz_ln_f_2,
        nslds_loan_capital_int_f_2,
        nslds_loan_seq_num_3,
        nslds_loan_type_code_3,
        nslds_loan_chng_f_3,
        nslds_loan_prog_code_3,
        nslds_loan_net_amnt_3,
        nslds_loan_cur_st_code_3,
        nslds_loan_cur_st_date_3,
        nslds_loan_agg_pr_bal_3,
        nslds_loan_out_pr_bal_dt_3,
        nslds_loan_begin_dt_3,
        nslds_loan_end_dt_3,
        nslds_loan_ga_code_3,
        nslds_loan_cont_type_3,
        nslds_loan_schol_code_3,
        nslds_loan_cont_code_3,
        nslds_loan_grade_lvl_3,
        nslds_loan_xtr_unsbz_ln_f_3,
        nslds_loan_capital_int_f_3,
        nslds_loan_seq_num_4,
        nslds_loan_type_code_4,
        nslds_loan_chng_f_4,
        nslds_loan_prog_code_4,
        nslds_loan_net_amnt_4,
        nslds_loan_cur_st_code_4,
        nslds_loan_cur_st_date_4,
        nslds_loan_agg_pr_bal_4,
        nslds_loan_out_pr_bal_dt_4,
        nslds_loan_begin_dt_4,
        nslds_loan_end_dt_4,
        nslds_loan_ga_code_4,
        nslds_loan_cont_type_4,
        nslds_loan_schol_code_4,
        nslds_loan_cont_code_4,
        nslds_loan_grade_lvl_4,
        nslds_loan_xtr_unsbz_ln_f_4,
        nslds_loan_capital_int_f_4,
        nslds_loan_seq_num_5,
        nslds_loan_type_code_5,
        nslds_loan_chng_f_5,
        nslds_loan_prog_code_5,
        nslds_loan_net_amnt_5,
        nslds_loan_cur_st_code_5,
        nslds_loan_cur_st_date_5,
        nslds_loan_agg_pr_bal_5,
        nslds_loan_out_pr_bal_dt_5,
        nslds_loan_begin_dt_5,
        nslds_loan_end_dt_5,
        nslds_loan_ga_code_5,
        nslds_loan_cont_type_5,
        nslds_loan_schol_code_5,
        nslds_loan_cont_code_5,
        nslds_loan_grade_lvl_5,
        nslds_loan_xtr_unsbz_ln_f_5,
        nslds_loan_capital_int_f_5,
        nslds_loan_seq_num_6,
        nslds_loan_type_code_6,
        nslds_loan_chng_f_6,
        nslds_loan_prog_code_6,
        nslds_loan_net_amnt_6,
        nslds_loan_cur_st_code_6,
        nslds_loan_cur_st_date_6,
        nslds_loan_agg_pr_bal_6,
        nslds_loan_out_pr_bal_dt_6,
        nslds_loan_begin_dt_6,
        nslds_loan_end_dt_6,
        nslds_loan_ga_code_6,
        nslds_loan_cont_type_6,
        nslds_loan_schol_code_6,
        nslds_loan_cont_code_6,
        nslds_loan_grade_lvl_6,
        nslds_loan_xtr_unsbz_ln_f_6,
        nslds_loan_capital_int_f_6,
        nslds_loan_last_d_amt_1,
        nslds_loan_last_d_date_1,
        nslds_loan_last_d_amt_2,
        nslds_loan_last_d_date_2,
        nslds_loan_last_d_amt_3,
        nslds_loan_last_d_date_3,
        nslds_loan_last_d_amt_4,
        nslds_loan_last_d_date_4,
        nslds_loan_last_d_amt_5,
        nslds_loan_last_d_date_5,
        nslds_loan_last_d_amt_6,
        nslds_loan_last_d_date_6,
        org_id,
        dlp_master_prom_note_flag,
        subsidized_loan_limit_type,
        combined_loan_limit_type,
        transaction_num_txt
      FROM  igf_ap_nslds_data_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;
  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.isir_id = x_isir_id)
        AND ((tlinfo.base_id = x_base_id) OR ((tlinfo.base_id IS NULL) AND (X_base_id IS NULL)))
        AND ((tlinfo.nslds_transaction_num = x_nslds_transaction_num) OR ((tlinfo.nslds_transaction_num IS NULL) AND (X_nslds_transaction_num IS NULL)))
        AND ((tlinfo.nslds_database_results_f = x_nslds_database_results_f) OR ((tlinfo.nslds_database_results_f IS NULL) AND (X_nslds_database_results_f IS NULL)))
        AND ((tlinfo.nslds_f = x_nslds_f) OR ((tlinfo.nslds_f IS NULL) AND (X_nslds_f IS NULL)))
        AND ((tlinfo.nslds_pell_overpay_f = x_nslds_pell_overpay_f) OR ((tlinfo.nslds_pell_overpay_f IS NULL) AND (X_nslds_pell_overpay_f IS NULL)))
        AND ((tlinfo.nslds_pell_overpay_contact = x_nslds_pell_overpay_contact) OR ((tlinfo.nslds_pell_overpay_contact IS NULL) AND (X_nslds_pell_overpay_contact IS NULL)))
        AND ((tlinfo.nslds_seog_overpay_f = x_nslds_seog_overpay_f) OR ((tlinfo.nslds_seog_overpay_f IS NULL) AND (X_nslds_seog_overpay_f IS NULL)))
        AND ((tlinfo.nslds_seog_overpay_contact = x_nslds_seog_overpay_contact) OR ((tlinfo.nslds_seog_overpay_contact IS NULL) AND (X_nslds_seog_overpay_contact IS NULL)))
        AND ((tlinfo.nslds_perkins_overpay_f = x_nslds_perkins_overpay_f) OR ((tlinfo.nslds_perkins_overpay_f IS NULL) AND (X_nslds_perkins_overpay_f IS NULL)))
        AND ((tlinfo.nslds_perkins_overpay_cntct = x_nslds_perkins_overpay_cntct) OR ((tlinfo.nslds_perkins_overpay_cntct IS NULL) AND (X_nslds_perkins_overpay_cntct IS NULL)))
        AND ((tlinfo.nslds_defaulted_loan_f = x_nslds_defaulted_loan_f) OR ((tlinfo.nslds_defaulted_loan_f IS NULL) AND (X_nslds_defaulted_loan_f IS NULL)))
        AND ((tlinfo.nslds_dischged_loan_chng_f = x_nslds_dischged_loan_chng_f) OR ((tlinfo.nslds_dischged_loan_chng_f IS NULL) AND (X_nslds_dischged_loan_chng_f IS NULL)))
        AND ((tlinfo.nslds_satis_repay_f = x_nslds_satis_repay_f) OR ((tlinfo.nslds_satis_repay_f IS NULL) AND (X_nslds_satis_repay_f IS NULL)))
        AND ((tlinfo.nslds_act_bankruptcy_f = x_nslds_act_bankruptcy_f) OR ((tlinfo.nslds_act_bankruptcy_f IS NULL) AND (X_nslds_act_bankruptcy_f IS NULL)))
        AND ((tlinfo.nslds_agg_subsz_out_prin_bal = x_nslds_agg_subsz_out_prin_bal) OR ((tlinfo.nslds_agg_subsz_out_prin_bal IS NULL) AND (X_nslds_agg_subsz_out_prin_bal IS NULL)))
        AND ((tlinfo.nslds_agg_unsbz_out_prin_bal = x_nslds_agg_unsbz_out_prin_bal) OR ((tlinfo.nslds_agg_unsbz_out_prin_bal IS NULL) AND (X_nslds_agg_unsbz_out_prin_bal IS NULL)))
        AND ((tlinfo.nslds_agg_comb_out_prin_bal = x_nslds_agg_comb_out_prin_bal) OR ((tlinfo.nslds_agg_comb_out_prin_bal IS NULL) AND (X_nslds_agg_comb_out_prin_bal IS NULL)))
        AND ((tlinfo.nslds_agg_cons_out_prin_bal = x_nslds_agg_cons_out_prin_bal) OR ((tlinfo.nslds_agg_cons_out_prin_bal IS NULL) AND (X_nslds_agg_cons_out_prin_bal IS NULL)))
        AND ((tlinfo.nslds_agg_subsz_pend_dismt = x_nslds_agg_subsz_pend_dismt) OR ((tlinfo.nslds_agg_subsz_pend_dismt IS NULL) AND (X_nslds_agg_subsz_pend_dismt IS NULL)))
        AND ((tlinfo.nslds_agg_unsbz_pend_dismt = x_nslds_agg_unsbz_pend_dismt) OR ((tlinfo.nslds_agg_unsbz_pend_dismt IS NULL) AND (X_nslds_agg_unsbz_pend_dismt IS NULL)))
        AND ((tlinfo.nslds_agg_comb_pend_dismt = x_nslds_agg_comb_pend_dismt) OR ((tlinfo.nslds_agg_comb_pend_dismt IS NULL) AND (X_nslds_agg_comb_pend_dismt IS NULL)))
        AND ((tlinfo.nslds_agg_subsz_total = x_nslds_agg_subsz_total) OR ((tlinfo.nslds_agg_subsz_total IS NULL) AND (X_nslds_agg_subsz_total IS NULL)))
        AND ((tlinfo.nslds_agg_unsbz_total = x_nslds_agg_unsbz_total) OR ((tlinfo.nslds_agg_unsbz_total IS NULL) AND (X_nslds_agg_unsbz_total IS NULL)))
        AND ((tlinfo.nslds_agg_comb_total = x_nslds_agg_comb_total) OR ((tlinfo.nslds_agg_comb_total IS NULL) AND (X_nslds_agg_comb_total IS NULL)))
        AND ((tlinfo.nslds_agg_consd_total = x_nslds_agg_consd_total) OR ((tlinfo.nslds_agg_consd_total IS NULL) AND (X_nslds_agg_consd_total IS NULL)))
        AND ((tlinfo.nslds_perkins_out_bal = x_nslds_perkins_out_bal) OR ((tlinfo.nslds_perkins_out_bal IS NULL) AND (X_nslds_perkins_out_bal IS NULL)))
        AND ((tlinfo.nslds_perkins_cur_yr_dismnt = x_nslds_perkins_cur_yr_dismnt) OR ((tlinfo.nslds_perkins_cur_yr_dismnt IS NULL) AND (X_nslds_perkins_cur_yr_dismnt IS NULL)))
        AND ((tlinfo.nslds_default_loan_chng_f = x_nslds_default_loan_chng_f) OR ((tlinfo.nslds_default_loan_chng_f IS NULL) AND (X_nslds_default_loan_chng_f IS NULL)))
        AND ((tlinfo.nslds_discharged_loan_f = x_nslds_discharged_loan_f) OR ((tlinfo.nslds_discharged_loan_f IS NULL) AND (X_nslds_discharged_loan_f IS NULL)))
        AND ((tlinfo.nslds_satis_repay_chng_f = x_nslds_satis_repay_chng_f) OR ((tlinfo.nslds_satis_repay_chng_f IS NULL) AND (X_nslds_satis_repay_chng_f IS NULL)))
        AND ((tlinfo.nslds_act_bnkrupt_chng_f = x_nslds_act_bnkrupt_chng_f) OR ((tlinfo.nslds_act_bnkrupt_chng_f IS NULL) AND (X_nslds_act_bnkrupt_chng_f IS NULL)))
        AND ((tlinfo.nslds_overpay_chng_f = x_nslds_overpay_chng_f) OR ((tlinfo.nslds_overpay_chng_f IS NULL) AND (X_nslds_overpay_chng_f IS NULL)))
        AND ((tlinfo.nslds_agg_loan_chng_f = x_nslds_agg_loan_chng_f) OR ((tlinfo.nslds_agg_loan_chng_f IS NULL) AND (X_nslds_agg_loan_chng_f IS NULL)))
        AND ((tlinfo.nslds_perkins_loan_chng_f = x_nslds_perkins_loan_chng_f) OR ((tlinfo.nslds_perkins_loan_chng_f IS NULL) AND (X_nslds_perkins_loan_chng_f IS NULL)))
        AND ((tlinfo.nslds_pell_paymnt_chng_f = x_nslds_pell_paymnt_chng_f) OR ((tlinfo.nslds_pell_paymnt_chng_f IS NULL) AND (X_nslds_pell_paymnt_chng_f IS NULL)))
        AND ((tlinfo.nslds_addtnl_pell_f = x_nslds_addtnl_pell_f) OR ((tlinfo.nslds_addtnl_pell_f IS NULL) AND (X_nslds_addtnl_pell_f IS NULL)))
        AND ((tlinfo.nslds_addtnl_loan_f = x_nslds_addtnl_loan_f) OR ((tlinfo.nslds_addtnl_loan_f IS NULL) AND (X_nslds_addtnl_loan_f IS NULL)))
        AND ((tlinfo.direct_loan_mas_prom_nt_f = x_direct_loan_mas_prom_nt_f) OR ((tlinfo.direct_loan_mas_prom_nt_f IS NULL) AND (X_direct_loan_mas_prom_nt_f IS NULL)))
        AND ((tlinfo.nslds_pell_seq_num_1 = x_nslds_pell_seq_num_1) OR ((tlinfo.nslds_pell_seq_num_1 IS NULL) AND (X_nslds_pell_seq_num_1 IS NULL)))
        AND ((tlinfo.nslds_pell_verify_f_1 = x_nslds_pell_verify_f_1) OR ((tlinfo.nslds_pell_verify_f_1 IS NULL) AND (X_nslds_pell_verify_f_1 IS NULL)))
        AND ((tlinfo.nslds_pell_efc_1 = x_nslds_pell_efc_1) OR ((tlinfo.nslds_pell_efc_1 IS NULL) AND (X_nslds_pell_efc_1 IS NULL)))
        AND ((tlinfo.nslds_pell_school_code_1 = x_nslds_pell_school_code_1) OR ((tlinfo.nslds_pell_school_code_1 IS NULL) AND (X_nslds_pell_school_code_1 IS NULL)))
        AND ((tlinfo.nslds_pell_transcn_num_1 = x_nslds_pell_transcn_num_1) OR ((tlinfo.nslds_pell_transcn_num_1 IS NULL) AND (X_nslds_pell_transcn_num_1 IS NULL)))
        AND ((tlinfo.nslds_pell_last_updt_dt_1 = x_nslds_pell_last_updt_dt_1) OR ((tlinfo.nslds_pell_last_updt_dt_1 IS NULL) AND (X_nslds_pell_last_updt_dt_1 IS NULL)))
        AND ((tlinfo.nslds_pell_scheduled_amt_1 = x_nslds_pell_scheduled_amt_1) OR ((tlinfo.nslds_pell_scheduled_amt_1 IS NULL) AND (X_nslds_pell_scheduled_amt_1 IS NULL)))
        AND ((tlinfo.nslds_pell_amt_paid_todt_1 = x_nslds_pell_amt_paid_todt_1) OR ((tlinfo.nslds_pell_amt_paid_todt_1 IS NULL) AND (X_nslds_pell_amt_paid_todt_1 IS NULL)))
        AND ((tlinfo.nslds_pell_remng_amt_1 = x_nslds_pell_remng_amt_1) OR ((tlinfo.nslds_pell_remng_amt_1 IS NULL) AND (X_nslds_pell_remng_amt_1 IS NULL)))
        AND ((tlinfo.nslds_pell_pc_schd_awd_us_1 = x_nslds_pell_pc_schd_awd_us_1) OR ((tlinfo.nslds_pell_pc_schd_awd_us_1 IS NULL) AND (X_nslds_pell_pc_schd_awd_us_1 IS NULL)))
        AND ((tlinfo.nslds_pell_award_amt_1 = x_nslds_pell_award_amt_1) OR ((tlinfo.nslds_pell_award_amt_1 IS NULL) AND (X_nslds_pell_award_amt_1 IS NULL)))
        AND ((tlinfo.nslds_pell_seq_num_2 = x_nslds_pell_seq_num_2) OR ((tlinfo.nslds_pell_seq_num_2 IS NULL) AND (X_nslds_pell_seq_num_2 IS NULL)))
        AND ((tlinfo.nslds_pell_verify_f_2 = x_nslds_pell_verify_f_2) OR ((tlinfo.nslds_pell_verify_f_2 IS NULL) AND (X_nslds_pell_verify_f_2 IS NULL)))
        AND ((tlinfo.nslds_pell_efc_2 = x_nslds_pell_efc_2) OR ((tlinfo.nslds_pell_efc_2 IS NULL) AND (X_nslds_pell_efc_2 IS NULL)))
        AND ((tlinfo.nslds_pell_school_code_2 = x_nslds_pell_school_code_2) OR ((tlinfo.nslds_pell_school_code_2 IS NULL) AND (X_nslds_pell_school_code_2 IS NULL)))
        AND ((tlinfo.nslds_pell_transcn_num_2 = x_nslds_pell_transcn_num_2) OR ((tlinfo.nslds_pell_transcn_num_2 IS NULL) AND (X_nslds_pell_transcn_num_2 IS NULL)))
        AND ((tlinfo.nslds_pell_last_updt_dt_2 = x_nslds_pell_last_updt_dt_2) OR ((tlinfo.nslds_pell_last_updt_dt_2 IS NULL) AND (X_nslds_pell_last_updt_dt_2 IS NULL)))
        AND ((tlinfo.nslds_pell_scheduled_amt_2 = x_nslds_pell_scheduled_amt_2) OR ((tlinfo.nslds_pell_scheduled_amt_2 IS NULL) AND (X_nslds_pell_scheduled_amt_2 IS NULL)))
        AND ((tlinfo.nslds_pell_amt_paid_todt_2 = x_nslds_pell_amt_paid_todt_2) OR ((tlinfo.nslds_pell_amt_paid_todt_2 IS NULL) AND (X_nslds_pell_amt_paid_todt_2 IS NULL)))
        AND ((tlinfo.nslds_pell_remng_amt_2 = x_nslds_pell_remng_amt_2) OR ((tlinfo.nslds_pell_remng_amt_2 IS NULL) AND (X_nslds_pell_remng_amt_2 IS NULL)))
        AND ((tlinfo.nslds_pell_pc_schd_awd_us_2 = x_nslds_pell_pc_schd_awd_us_2) OR ((tlinfo.nslds_pell_pc_schd_awd_us_2 IS NULL) AND (X_nslds_pell_pc_schd_awd_us_2 IS NULL)))
        AND ((tlinfo.nslds_pell_award_amt_2 = x_nslds_pell_award_amt_2) OR ((tlinfo.nslds_pell_award_amt_2 IS NULL) AND (X_nslds_pell_award_amt_2 IS NULL)))
        AND ((tlinfo.nslds_pell_seq_num_3 = x_nslds_pell_seq_num_3) OR ((tlinfo.nslds_pell_seq_num_3 IS NULL) AND (X_nslds_pell_seq_num_3 IS NULL)))
        AND ((tlinfo.nslds_pell_verify_f_3 = x_nslds_pell_verify_f_3) OR ((tlinfo.nslds_pell_verify_f_3 IS NULL) AND (X_nslds_pell_verify_f_3 IS NULL)))
        AND ((tlinfo.nslds_pell_efc_3 = x_nslds_pell_efc_3) OR ((tlinfo.nslds_pell_efc_3 IS NULL) AND (X_nslds_pell_efc_3 IS NULL)))
        AND ((tlinfo.nslds_pell_school_code_3 = x_nslds_pell_school_code_3) OR ((tlinfo.nslds_pell_school_code_3 IS NULL) AND (X_nslds_pell_school_code_3 IS NULL)))
        AND ((tlinfo.nslds_pell_transcn_num_3 = x_nslds_pell_transcn_num_3) OR ((tlinfo.nslds_pell_transcn_num_3 IS NULL) AND (X_nslds_pell_transcn_num_3 IS NULL)))
        AND ((tlinfo.nslds_pell_last_updt_dt_3 = x_nslds_pell_last_updt_dt_3) OR ((tlinfo.nslds_pell_last_updt_dt_3 IS NULL) AND (X_nslds_pell_last_updt_dt_3 IS NULL)))
        AND ((tlinfo.nslds_pell_scheduled_amt_3 = x_nslds_pell_scheduled_amt_3) OR ((tlinfo.nslds_pell_scheduled_amt_3 IS NULL) AND (X_nslds_pell_scheduled_amt_3 IS NULL)))
        AND ((tlinfo.nslds_pell_amt_paid_todt_3 = x_nslds_pell_amt_paid_todt_3) OR ((tlinfo.nslds_pell_amt_paid_todt_3 IS NULL) AND (X_nslds_pell_amt_paid_todt_3 IS NULL)))
        AND ((tlinfo.nslds_pell_remng_amt_3 = x_nslds_pell_remng_amt_3) OR ((tlinfo.nslds_pell_remng_amt_3 IS NULL) AND (X_nslds_pell_remng_amt_3 IS NULL)))
        AND ((tlinfo.nslds_pell_pc_schd_awd_us_3 = x_nslds_pell_pc_schd_awd_us_3) OR ((tlinfo.nslds_pell_pc_schd_awd_us_3 IS NULL) AND (X_nslds_pell_pc_schd_awd_us_3 IS NULL)))
        AND ((tlinfo.nslds_pell_award_amt_3 = x_nslds_pell_award_amt_3) OR ((tlinfo.nslds_pell_award_amt_3 IS NULL) AND (X_nslds_pell_award_amt_3 IS NULL)))
        AND ((tlinfo.nslds_loan_seq_num_1 = x_nslds_loan_seq_num_1) OR ((tlinfo.nslds_loan_seq_num_1 IS NULL) AND (X_nslds_loan_seq_num_1 IS NULL)))
        AND ((tlinfo.nslds_loan_type_code_1 = x_nslds_loan_type_code_1) OR ((tlinfo.nslds_loan_type_code_1 IS NULL) AND (X_nslds_loan_type_code_1 IS NULL)))
        AND ((tlinfo.nslds_loan_chng_f_1 = x_nslds_loan_chng_f_1) OR ((tlinfo.nslds_loan_chng_f_1 IS NULL) AND (X_nslds_loan_chng_f_1 IS NULL)))
        AND ((tlinfo.nslds_loan_prog_code_1 = x_nslds_loan_prog_code_1) OR ((tlinfo.nslds_loan_prog_code_1 IS NULL) AND (X_nslds_loan_prog_code_1 IS NULL)))
        AND ((tlinfo.nslds_loan_net_amnt_1 = x_nslds_loan_net_amnt_1) OR ((tlinfo.nslds_loan_net_amnt_1 IS NULL) AND (X_nslds_loan_net_amnt_1 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_code_1 = x_nslds_loan_cur_st_code_1) OR ((tlinfo.nslds_loan_cur_st_code_1 IS NULL) AND (X_nslds_loan_cur_st_code_1 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_date_1 = x_nslds_loan_cur_st_date_1) OR ((tlinfo.nslds_loan_cur_st_date_1 IS NULL) AND (X_nslds_loan_cur_st_date_1 IS NULL)))
        AND ((tlinfo.nslds_loan_agg_pr_bal_1 = x_nslds_loan_agg_pr_bal_1) OR ((tlinfo.nslds_loan_agg_pr_bal_1 IS NULL) AND (X_nslds_loan_agg_pr_bal_1 IS NULL)))
        AND ((tlinfo.nslds_loan_out_pr_bal_dt_1 = x_nslds_loan_out_pr_bal_dt_1) OR ((tlinfo.nslds_loan_out_pr_bal_dt_1 IS NULL) AND (X_nslds_loan_out_pr_bal_dt_1 IS NULL)))
        AND ((tlinfo.nslds_loan_begin_dt_1 = x_nslds_loan_begin_dt_1) OR ((tlinfo.nslds_loan_begin_dt_1 IS NULL) AND (X_nslds_loan_begin_dt_1 IS NULL)))
        AND ((tlinfo.nslds_loan_end_dt_1 = x_nslds_loan_end_dt_1) OR ((tlinfo.nslds_loan_end_dt_1 IS NULL) AND (X_nslds_loan_end_dt_1 IS NULL)))
        AND ((tlinfo.nslds_loan_ga_code_1 = x_nslds_loan_ga_code_1) OR ((tlinfo.nslds_loan_ga_code_1 IS NULL) AND (X_nslds_loan_ga_code_1 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_type_1 = x_nslds_loan_cont_type_1) OR ((tlinfo.nslds_loan_cont_type_1 IS NULL) AND (X_nslds_loan_cont_type_1 IS NULL)))
        AND ((tlinfo.nslds_loan_schol_code_1 = x_nslds_loan_schol_code_1) OR ((tlinfo.nslds_loan_schol_code_1 IS NULL) AND (X_nslds_loan_schol_code_1 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_code_1 = x_nslds_loan_cont_code_1) OR ((tlinfo.nslds_loan_cont_code_1 IS NULL) AND (X_nslds_loan_cont_code_1 IS NULL)))
        AND ((tlinfo.nslds_loan_grade_lvl_1 = x_nslds_loan_grade_lvl_1) OR ((tlinfo.nslds_loan_grade_lvl_1 IS NULL) AND (X_nslds_loan_grade_lvl_1 IS NULL)))
        AND ((tlinfo.nslds_loan_xtr_unsbz_ln_f_1 = x_nslds_loan_xtr_unsbz_ln_f_1) OR ((tlinfo.nslds_loan_xtr_unsbz_ln_f_1 IS NULL) AND (X_nslds_loan_xtr_unsbz_ln_f_1 IS NULL)))
        AND ((tlinfo.nslds_loan_capital_int_f_1 = x_nslds_loan_capital_int_f_1) OR ((tlinfo.nslds_loan_capital_int_f_1 IS NULL) AND (X_nslds_loan_capital_int_f_1 IS NULL)))
        AND ((tlinfo.nslds_loan_seq_num_2 = x_nslds_loan_seq_num_2) OR ((tlinfo.nslds_loan_seq_num_2 IS NULL) AND (X_nslds_loan_seq_num_2 IS NULL)))
        AND ((tlinfo.nslds_loan_type_code_2 = x_nslds_loan_type_code_2) OR ((tlinfo.nslds_loan_type_code_2 IS NULL) AND (X_nslds_loan_type_code_2 IS NULL)))
        AND ((tlinfo.nslds_loan_chng_f_2 = x_nslds_loan_chng_f_2) OR ((tlinfo.nslds_loan_chng_f_2 IS NULL) AND (X_nslds_loan_chng_f_2 IS NULL)))
        AND ((tlinfo.nslds_loan_prog_code_2 = x_nslds_loan_prog_code_2) OR ((tlinfo.nslds_loan_prog_code_2 IS NULL) AND (X_nslds_loan_prog_code_2 IS NULL)))
        AND ((tlinfo.nslds_loan_net_amnt_2 = x_nslds_loan_net_amnt_2) OR ((tlinfo.nslds_loan_net_amnt_2 IS NULL) AND (X_nslds_loan_net_amnt_2 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_code_2 = x_nslds_loan_cur_st_code_2) OR ((tlinfo.nslds_loan_cur_st_code_2 IS NULL) AND (X_nslds_loan_cur_st_code_2 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_date_2 = x_nslds_loan_cur_st_date_2) OR ((tlinfo.nslds_loan_cur_st_date_2 IS NULL) AND (X_nslds_loan_cur_st_date_2 IS NULL)))
        AND ((tlinfo.nslds_loan_agg_pr_bal_2 = x_nslds_loan_agg_pr_bal_2) OR ((tlinfo.nslds_loan_agg_pr_bal_2 IS NULL) AND (X_nslds_loan_agg_pr_bal_2 IS NULL)))
        AND ((tlinfo.nslds_loan_out_pr_bal_dt_2 = x_nslds_loan_out_pr_bal_dt_2) OR ((tlinfo.nslds_loan_out_pr_bal_dt_2 IS NULL) AND (X_nslds_loan_out_pr_bal_dt_2 IS NULL)))
        AND ((tlinfo.nslds_loan_begin_dt_2 = x_nslds_loan_begin_dt_2) OR ((tlinfo.nslds_loan_begin_dt_2 IS NULL) AND (X_nslds_loan_begin_dt_2 IS NULL)))
        AND ((tlinfo.nslds_loan_end_dt_2 = x_nslds_loan_end_dt_2) OR ((tlinfo.nslds_loan_end_dt_2 IS NULL) AND (X_nslds_loan_end_dt_2 IS NULL)))
        AND ((tlinfo.nslds_loan_ga_code_2 = x_nslds_loan_ga_code_2) OR ((tlinfo.nslds_loan_ga_code_2 IS NULL) AND (X_nslds_loan_ga_code_2 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_type_2 = x_nslds_loan_cont_type_2) OR ((tlinfo.nslds_loan_cont_type_2 IS NULL) AND (X_nslds_loan_cont_type_2 IS NULL)))
        AND ((tlinfo.nslds_loan_schol_code_2 = x_nslds_loan_schol_code_2) OR ((tlinfo.nslds_loan_schol_code_2 IS NULL) AND (X_nslds_loan_schol_code_2 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_code_2 = x_nslds_loan_cont_code_2) OR ((tlinfo.nslds_loan_cont_code_2 IS NULL) AND (X_nslds_loan_cont_code_2 IS NULL)))
        AND ((tlinfo.nslds_loan_grade_lvl_2 = x_nslds_loan_grade_lvl_2) OR ((tlinfo.nslds_loan_grade_lvl_2 IS NULL) AND (X_nslds_loan_grade_lvl_2 IS NULL)))
        AND ((tlinfo.nslds_loan_xtr_unsbz_ln_f_2 = x_nslds_loan_xtr_unsbz_ln_f_2) OR ((tlinfo.nslds_loan_xtr_unsbz_ln_f_2 IS NULL) AND (X_nslds_loan_xtr_unsbz_ln_f_2 IS NULL)))
        AND ((tlinfo.nslds_loan_capital_int_f_2 = x_nslds_loan_capital_int_f_2) OR ((tlinfo.nslds_loan_capital_int_f_2 IS NULL) AND (X_nslds_loan_capital_int_f_2 IS NULL)))
        AND ((tlinfo.nslds_loan_seq_num_3 = x_nslds_loan_seq_num_3) OR ((tlinfo.nslds_loan_seq_num_3 IS NULL) AND (X_nslds_loan_seq_num_3 IS NULL)))
        AND ((tlinfo.nslds_loan_type_code_3 = x_nslds_loan_type_code_3) OR ((tlinfo.nslds_loan_type_code_3 IS NULL) AND (X_nslds_loan_type_code_3 IS NULL)))
        AND ((tlinfo.nslds_loan_chng_f_3 = x_nslds_loan_chng_f_3) OR ((tlinfo.nslds_loan_chng_f_3 IS NULL) AND (X_nslds_loan_chng_f_3 IS NULL)))
        AND ((tlinfo.nslds_loan_prog_code_3 = x_nslds_loan_prog_code_3) OR ((tlinfo.nslds_loan_prog_code_3 IS NULL) AND (X_nslds_loan_prog_code_3 IS NULL)))
        AND ((tlinfo.nslds_loan_net_amnt_3 = x_nslds_loan_net_amnt_3) OR ((tlinfo.nslds_loan_net_amnt_3 IS NULL) AND (X_nslds_loan_net_amnt_3 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_code_3 = x_nslds_loan_cur_st_code_3) OR ((tlinfo.nslds_loan_cur_st_code_3 IS NULL) AND (X_nslds_loan_cur_st_code_3 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_date_3 = x_nslds_loan_cur_st_date_3) OR ((tlinfo.nslds_loan_cur_st_date_3 IS NULL) AND (X_nslds_loan_cur_st_date_3 IS NULL)))
        AND ((tlinfo.nslds_loan_agg_pr_bal_3 = x_nslds_loan_agg_pr_bal_3) OR ((tlinfo.nslds_loan_agg_pr_bal_3 IS NULL) AND (X_nslds_loan_agg_pr_bal_3 IS NULL)))
        AND ((tlinfo.nslds_loan_out_pr_bal_dt_3 = x_nslds_loan_out_pr_bal_dt_3) OR ((tlinfo.nslds_loan_out_pr_bal_dt_3 IS NULL) AND (X_nslds_loan_out_pr_bal_dt_3 IS NULL)))
        AND ((tlinfo.nslds_loan_begin_dt_3 = x_nslds_loan_begin_dt_3) OR ((tlinfo.nslds_loan_begin_dt_3 IS NULL) AND (X_nslds_loan_begin_dt_3 IS NULL)))
        AND ((tlinfo.nslds_loan_end_dt_3 = x_nslds_loan_end_dt_3) OR ((tlinfo.nslds_loan_end_dt_3 IS NULL) AND (X_nslds_loan_end_dt_3 IS NULL)))
        AND ((tlinfo.nslds_loan_ga_code_3 = x_nslds_loan_ga_code_3) OR ((tlinfo.nslds_loan_ga_code_3 IS NULL) AND (X_nslds_loan_ga_code_3 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_type_3 = x_nslds_loan_cont_type_3) OR ((tlinfo.nslds_loan_cont_type_3 IS NULL) AND (X_nslds_loan_cont_type_3 IS NULL)))
        AND ((tlinfo.nslds_loan_schol_code_3 = x_nslds_loan_schol_code_3) OR ((tlinfo.nslds_loan_schol_code_3 IS NULL) AND (X_nslds_loan_schol_code_3 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_code_3 = x_nslds_loan_cont_code_3) OR ((tlinfo.nslds_loan_cont_code_3 IS NULL) AND (X_nslds_loan_cont_code_3 IS NULL)))
        AND ((tlinfo.nslds_loan_grade_lvl_3 = x_nslds_loan_grade_lvl_3) OR ((tlinfo.nslds_loan_grade_lvl_3 IS NULL) AND (X_nslds_loan_grade_lvl_3 IS NULL)))
        AND ((tlinfo.nslds_loan_xtr_unsbz_ln_f_3 = x_nslds_loan_xtr_unsbz_ln_f_3) OR ((tlinfo.nslds_loan_xtr_unsbz_ln_f_3 IS NULL) AND (X_nslds_loan_xtr_unsbz_ln_f_3 IS NULL)))
        AND ((tlinfo.nslds_loan_capital_int_f_3 = x_nslds_loan_capital_int_f_3) OR ((tlinfo.nslds_loan_capital_int_f_3 IS NULL) AND (X_nslds_loan_capital_int_f_3 IS NULL)))
        AND ((tlinfo.nslds_loan_seq_num_4 = x_nslds_loan_seq_num_4) OR ((tlinfo.nslds_loan_seq_num_4 IS NULL) AND (X_nslds_loan_seq_num_4 IS NULL)))
        AND ((tlinfo.nslds_loan_type_code_4 = x_nslds_loan_type_code_4) OR ((tlinfo.nslds_loan_type_code_4 IS NULL) AND (X_nslds_loan_type_code_4 IS NULL)))
        AND ((tlinfo.nslds_loan_chng_f_4 = x_nslds_loan_chng_f_4) OR ((tlinfo.nslds_loan_chng_f_4 IS NULL) AND (X_nslds_loan_chng_f_4 IS NULL)))
        AND ((tlinfo.nslds_loan_prog_code_4 = x_nslds_loan_prog_code_4) OR ((tlinfo.nslds_loan_prog_code_4 IS NULL) AND (X_nslds_loan_prog_code_4 IS NULL)))
        AND ((tlinfo.nslds_loan_net_amnt_4 = x_nslds_loan_net_amnt_4) OR ((tlinfo.nslds_loan_net_amnt_4 IS NULL) AND (X_nslds_loan_net_amnt_4 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_code_4 = x_nslds_loan_cur_st_code_4) OR ((tlinfo.nslds_loan_cur_st_code_4 IS NULL) AND (X_nslds_loan_cur_st_code_4 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_date_4 = x_nslds_loan_cur_st_date_4) OR ((tlinfo.nslds_loan_cur_st_date_4 IS NULL) AND (X_nslds_loan_cur_st_date_4 IS NULL)))
        AND ((tlinfo.nslds_loan_agg_pr_bal_4 = x_nslds_loan_agg_pr_bal_4) OR ((tlinfo.nslds_loan_agg_pr_bal_4 IS NULL) AND (X_nslds_loan_agg_pr_bal_4 IS NULL)))
        AND ((tlinfo.nslds_loan_out_pr_bal_dt_4 = x_nslds_loan_out_pr_bal_dt_4) OR ((tlinfo.nslds_loan_out_pr_bal_dt_4 IS NULL) AND (X_nslds_loan_out_pr_bal_dt_4 IS NULL)))
        AND ((tlinfo.nslds_loan_begin_dt_4 = x_nslds_loan_begin_dt_4) OR ((tlinfo.nslds_loan_begin_dt_4 IS NULL) AND (X_nslds_loan_begin_dt_4 IS NULL)))
        AND ((tlinfo.nslds_loan_end_dt_4 = x_nslds_loan_end_dt_4) OR ((tlinfo.nslds_loan_end_dt_4 IS NULL) AND (X_nslds_loan_end_dt_4 IS NULL)))
        AND ((tlinfo.nslds_loan_ga_code_4 = x_nslds_loan_ga_code_4) OR ((tlinfo.nslds_loan_ga_code_4 IS NULL) AND (X_nslds_loan_ga_code_4 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_type_4 = x_nslds_loan_cont_type_4) OR ((tlinfo.nslds_loan_cont_type_4 IS NULL) AND (X_nslds_loan_cont_type_4 IS NULL)))
        AND ((tlinfo.nslds_loan_schol_code_4 = x_nslds_loan_schol_code_4) OR ((tlinfo.nslds_loan_schol_code_4 IS NULL) AND (X_nslds_loan_schol_code_4 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_code_4 = x_nslds_loan_cont_code_4) OR ((tlinfo.nslds_loan_cont_code_4 IS NULL) AND (X_nslds_loan_cont_code_4 IS NULL)))
        AND ((tlinfo.nslds_loan_grade_lvl_4 = x_nslds_loan_grade_lvl_4) OR ((tlinfo.nslds_loan_grade_lvl_4 IS NULL) AND (X_nslds_loan_grade_lvl_4 IS NULL)))
        AND ((tlinfo.nslds_loan_xtr_unsbz_ln_f_4 = x_nslds_loan_xtr_unsbz_ln_f_4) OR ((tlinfo.nslds_loan_xtr_unsbz_ln_f_4 IS NULL) AND (X_nslds_loan_xtr_unsbz_ln_f_4 IS NULL)))
        AND ((tlinfo.nslds_loan_capital_int_f_4 = x_nslds_loan_capital_int_f_4) OR ((tlinfo.nslds_loan_capital_int_f_4 IS NULL) AND (X_nslds_loan_capital_int_f_4 IS NULL)))
        AND ((tlinfo.nslds_loan_seq_num_5 = x_nslds_loan_seq_num_5) OR ((tlinfo.nslds_loan_seq_num_5 IS NULL) AND (X_nslds_loan_seq_num_5 IS NULL)))
        AND ((tlinfo.nslds_loan_type_code_5 = x_nslds_loan_type_code_5) OR ((tlinfo.nslds_loan_type_code_5 IS NULL) AND (X_nslds_loan_type_code_5 IS NULL)))
        AND ((tlinfo.nslds_loan_chng_f_5 = x_nslds_loan_chng_f_5) OR ((tlinfo.nslds_loan_chng_f_5 IS NULL) AND (X_nslds_loan_chng_f_5 IS NULL)))
        AND ((tlinfo.nslds_loan_prog_code_5 = x_nslds_loan_prog_code_5) OR ((tlinfo.nslds_loan_prog_code_5 IS NULL) AND (X_nslds_loan_prog_code_5 IS NULL)))
        AND ((tlinfo.nslds_loan_net_amnt_5 = x_nslds_loan_net_amnt_5) OR ((tlinfo.nslds_loan_net_amnt_5 IS NULL) AND (X_nslds_loan_net_amnt_5 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_code_5 = x_nslds_loan_cur_st_code_5) OR ((tlinfo.nslds_loan_cur_st_code_5 IS NULL) AND (X_nslds_loan_cur_st_code_5 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_date_5 = x_nslds_loan_cur_st_date_5) OR ((tlinfo.nslds_loan_cur_st_date_5 IS NULL) AND (X_nslds_loan_cur_st_date_5 IS NULL)))
        AND ((tlinfo.nslds_loan_agg_pr_bal_5 = x_nslds_loan_agg_pr_bal_5) OR ((tlinfo.nslds_loan_agg_pr_bal_5 IS NULL) AND (X_nslds_loan_agg_pr_bal_5 IS NULL)))
        AND ((tlinfo.nslds_loan_out_pr_bal_dt_5 = x_nslds_loan_out_pr_bal_dt_5) OR ((tlinfo.nslds_loan_out_pr_bal_dt_5 IS NULL) AND (X_nslds_loan_out_pr_bal_dt_5 IS NULL)))
        AND ((tlinfo.nslds_loan_begin_dt_5 = x_nslds_loan_begin_dt_5) OR ((tlinfo.nslds_loan_begin_dt_5 IS NULL) AND (X_nslds_loan_begin_dt_5 IS NULL)))
        AND ((tlinfo.nslds_loan_end_dt_5 = x_nslds_loan_end_dt_5) OR ((tlinfo.nslds_loan_end_dt_5 IS NULL) AND (X_nslds_loan_end_dt_5 IS NULL)))
        AND ((tlinfo.nslds_loan_ga_code_5 = x_nslds_loan_ga_code_5) OR ((tlinfo.nslds_loan_ga_code_5 IS NULL) AND (X_nslds_loan_ga_code_5 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_type_5 = x_nslds_loan_cont_type_5) OR ((tlinfo.nslds_loan_cont_type_5 IS NULL) AND (X_nslds_loan_cont_type_5 IS NULL)))
        AND ((tlinfo.nslds_loan_schol_code_5 = x_nslds_loan_schol_code_5) OR ((tlinfo.nslds_loan_schol_code_5 IS NULL) AND (X_nslds_loan_schol_code_5 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_code_5 = x_nslds_loan_cont_code_5) OR ((tlinfo.nslds_loan_cont_code_5 IS NULL) AND (X_nslds_loan_cont_code_5 IS NULL)))
        AND ((tlinfo.nslds_loan_grade_lvl_5 = x_nslds_loan_grade_lvl_5) OR ((tlinfo.nslds_loan_grade_lvl_5 IS NULL) AND (X_nslds_loan_grade_lvl_5 IS NULL)))
        AND ((tlinfo.nslds_loan_xtr_unsbz_ln_f_5 = x_nslds_loan_xtr_unsbz_ln_f_5) OR ((tlinfo.nslds_loan_xtr_unsbz_ln_f_5 IS NULL) AND (X_nslds_loan_xtr_unsbz_ln_f_5 IS NULL)))
        AND ((tlinfo.nslds_loan_capital_int_f_5 = x_nslds_loan_capital_int_f_5) OR ((tlinfo.nslds_loan_capital_int_f_5 IS NULL) AND (X_nslds_loan_capital_int_f_5 IS NULL)))
        AND ((tlinfo.nslds_loan_seq_num_6 = x_nslds_loan_seq_num_6) OR ((tlinfo.nslds_loan_seq_num_6 IS NULL) AND (X_nslds_loan_seq_num_6 IS NULL)))
        AND ((tlinfo.nslds_loan_type_code_6 = x_nslds_loan_type_code_6) OR ((tlinfo.nslds_loan_type_code_6 IS NULL) AND (X_nslds_loan_type_code_6 IS NULL)))
        AND ((tlinfo.nslds_loan_chng_f_6 = x_nslds_loan_chng_f_6) OR ((tlinfo.nslds_loan_chng_f_6 IS NULL) AND (X_nslds_loan_chng_f_6 IS NULL)))
        AND ((tlinfo.nslds_loan_prog_code_6 = x_nslds_loan_prog_code_6) OR ((tlinfo.nslds_loan_prog_code_6 IS NULL) AND (X_nslds_loan_prog_code_6 IS NULL)))
        AND ((tlinfo.nslds_loan_net_amnt_6 = x_nslds_loan_net_amnt_6) OR ((tlinfo.nslds_loan_net_amnt_6 IS NULL) AND (X_nslds_loan_net_amnt_6 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_code_6 = x_nslds_loan_cur_st_code_6) OR ((tlinfo.nslds_loan_cur_st_code_6 IS NULL) AND (X_nslds_loan_cur_st_code_6 IS NULL)))
        AND ((tlinfo.nslds_loan_cur_st_date_6 = x_nslds_loan_cur_st_date_6) OR ((tlinfo.nslds_loan_cur_st_date_6 IS NULL) AND (X_nslds_loan_cur_st_date_6 IS NULL)))
        AND ((tlinfo.nslds_loan_agg_pr_bal_6 = x_nslds_loan_agg_pr_bal_6) OR ((tlinfo.nslds_loan_agg_pr_bal_6 IS NULL) AND (X_nslds_loan_agg_pr_bal_6 IS NULL)))
        AND ((tlinfo.nslds_loan_out_pr_bal_dt_6 = x_nslds_loan_out_pr_bal_dt_6) OR ((tlinfo.nslds_loan_out_pr_bal_dt_6 IS NULL) AND (X_nslds_loan_out_pr_bal_dt_6 IS NULL)))
        AND ((tlinfo.nslds_loan_begin_dt_6 = x_nslds_loan_begin_dt_6) OR ((tlinfo.nslds_loan_begin_dt_6 IS NULL) AND (X_nslds_loan_begin_dt_6 IS NULL)))
        AND ((tlinfo.nslds_loan_end_dt_6 = x_nslds_loan_end_dt_6) OR ((tlinfo.nslds_loan_end_dt_6 IS NULL) AND (X_nslds_loan_end_dt_6 IS NULL)))
        AND ((tlinfo.nslds_loan_ga_code_6 = x_nslds_loan_ga_code_6) OR ((tlinfo.nslds_loan_ga_code_6 IS NULL) AND (X_nslds_loan_ga_code_6 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_type_6 = x_nslds_loan_cont_type_6) OR ((tlinfo.nslds_loan_cont_type_6 IS NULL) AND (X_nslds_loan_cont_type_6 IS NULL)))
        AND ((tlinfo.nslds_loan_schol_code_6 = x_nslds_loan_schol_code_6) OR ((tlinfo.nslds_loan_schol_code_6 IS NULL) AND (X_nslds_loan_schol_code_6 IS NULL)))
        AND ((tlinfo.nslds_loan_cont_code_6 = x_nslds_loan_cont_code_6) OR ((tlinfo.nslds_loan_cont_code_6 IS NULL) AND (X_nslds_loan_cont_code_6 IS NULL)))
        AND ((tlinfo.nslds_loan_grade_lvl_6 = x_nslds_loan_grade_lvl_6) OR ((tlinfo.nslds_loan_grade_lvl_6 IS NULL) AND (X_nslds_loan_grade_lvl_6 IS NULL)))
        AND ((tlinfo.nslds_loan_xtr_unsbz_ln_f_6 = x_nslds_loan_xtr_unsbz_ln_f_6) OR ((tlinfo.nslds_loan_xtr_unsbz_ln_f_6 IS NULL) AND (X_nslds_loan_xtr_unsbz_ln_f_6 IS NULL)))
        AND ((tlinfo.nslds_loan_capital_int_f_6 = x_nslds_loan_capital_int_f_6) OR ((tlinfo.nslds_loan_capital_int_f_6 IS NULL) AND (X_nslds_loan_capital_int_f_6 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_amt_1 = x_nslds_loan_last_d_amt_1) OR ((tlinfo.nslds_loan_last_d_amt_1 IS NULL) AND (x_nslds_loan_last_d_amt_1 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_date_1 = x_nslds_loan_last_d_date_1) OR ((tlinfo.nslds_loan_last_d_date_1 IS NULL) AND (x_nslds_loan_last_d_date_1 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_amt_2 = x_nslds_loan_last_d_amt_2) OR ((tlinfo.nslds_loan_last_d_amt_2 IS NULL) AND (x_nslds_loan_last_d_amt_2 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_date_2 = x_nslds_loan_last_d_date_2) OR ((tlinfo.nslds_loan_last_d_date_2 IS NULL) AND (x_nslds_loan_last_d_date_2 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_amt_3 = x_nslds_loan_last_d_amt_3 ) OR ((tlinfo.nslds_loan_last_d_amt_3 IS NULL) AND (x_nslds_loan_last_d_amt_3 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_date_3 = x_nslds_loan_last_d_date_3) OR ((tlinfo.nslds_loan_last_d_date_3 IS NULL) AND (x_nslds_loan_last_d_date_3 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_amt_4 = x_nslds_loan_last_d_amt_4 ) OR ((tlinfo.nslds_loan_last_d_amt_4 IS NULL) AND (x_nslds_loan_last_d_amt_4 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_date_4 = x_nslds_loan_last_d_date_4) OR ((tlinfo.nslds_loan_last_d_date_4 IS NULL) AND (x_nslds_loan_last_d_date_4 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_amt_5 = x_nslds_loan_last_d_amt_5) OR ((tlinfo.nslds_loan_last_d_amt_5 IS NULL) AND (x_nslds_loan_last_d_amt_5 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_date_5 = x_nslds_loan_last_d_date_5 ) OR ((tlinfo.nslds_loan_last_d_date_5 IS NULL) AND (x_nslds_loan_last_d_date_5 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_amt_6 = x_nslds_loan_last_d_amt_6 ) OR ((tlinfo.nslds_loan_last_d_amt_6 IS NULL) AND (x_nslds_loan_last_d_amt_6 IS NULL)))
        AND ((tlinfo.nslds_loan_last_d_date_6 = x_nslds_loan_last_d_date_6 )OR ((tlinfo.nslds_loan_last_d_date_6 IS NULL) AND (x_nslds_loan_last_d_date_6 IS NULL)))
        AND ((tlinfo.dlp_master_prom_note_flag = x_dlp_master_prom_note_flag )OR ((tlinfo.dlp_master_prom_note_flag IS NULL) AND (x_dlp_master_prom_note_flag IS NULL)))
        AND ((tlinfo.subsidized_loan_limit_type = x_subsidized_loan_limit_type )OR ((tlinfo.subsidized_loan_limit_type IS NULL) AND (x_subsidized_loan_limit_type IS NULL)))
        AND ((tlinfo.combined_loan_limit_type = x_combined_loan_limit_type )OR ((tlinfo.combined_loan_limit_type IS NULL) AND (x_combined_loan_limit_type IS NULL)))
        AND ((tlinfo.transaction_num_txt = x_transaction_num_txt )OR ((tlinfo.transaction_num_txt IS NULL) AND (x_transaction_num_txt IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_nslds_id                          IN     NUMBER,
    x_isir_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_nslds_transaction_num             IN     NUMBER,
    x_nslds_database_results_f          IN     VARCHAR2,
    x_nslds_f                           IN     VARCHAR2,
    x_nslds_pell_overpay_f              IN     VARCHAR2,
    x_nslds_pell_overpay_contact        IN     VARCHAR2,
    x_nslds_seog_overpay_f              IN     VARCHAR2,
    x_nslds_seog_overpay_contact        IN     VARCHAR2,
    x_nslds_perkins_overpay_f           IN     VARCHAR2,
    x_nslds_perkins_overpay_cntct       IN     VARCHAR2,
    x_nslds_defaulted_loan_f            IN     VARCHAR2,
    x_nslds_dischged_loan_chng_f        IN     VARCHAR2,
    x_nslds_satis_repay_f               IN     VARCHAR2,
    x_nslds_act_bankruptcy_f            IN     VARCHAR2,
    x_nslds_agg_subsz_out_prin_bal      IN     NUMBER,
    x_nslds_agg_unsbz_out_prin_bal      IN     NUMBER,
    x_nslds_agg_comb_out_prin_bal       IN     NUMBER,
    x_nslds_agg_cons_out_prin_bal       IN     NUMBER,
    x_nslds_agg_subsz_pend_dismt        IN     NUMBER,
    x_nslds_agg_unsbz_pend_dismt        IN     NUMBER,
    x_nslds_agg_comb_pend_dismt         IN     NUMBER,
    x_nslds_agg_subsz_total             IN     NUMBER,
    x_nslds_agg_unsbz_total             IN     NUMBER,
    x_nslds_agg_comb_total              IN     NUMBER,
    x_nslds_agg_consd_total             IN     NUMBER,
    x_nslds_perkins_out_bal             IN     NUMBER,
    x_nslds_perkins_cur_yr_dismnt       IN     NUMBER,
    x_nslds_default_loan_chng_f         IN     VARCHAR2,
    x_nslds_discharged_loan_f           IN     VARCHAR2,
    x_nslds_satis_repay_chng_f          IN     VARCHAR2,
    x_nslds_act_bnkrupt_chng_f          IN     VARCHAR2,
    x_nslds_overpay_chng_f              IN     VARCHAR2,
    x_nslds_agg_loan_chng_f             IN     VARCHAR2,
    x_nslds_perkins_loan_chng_f         IN     VARCHAR2,
    x_nslds_pell_paymnt_chng_f          IN     VARCHAR2,
    x_nslds_addtnl_pell_f               IN     VARCHAR2,
    x_nslds_addtnl_loan_f               IN     VARCHAR2,
    x_direct_loan_mas_prom_nt_f         IN     VARCHAR2,
    x_nslds_pell_seq_num_1              IN     NUMBER,
    x_nslds_pell_verify_f_1             IN     VARCHAR2,
    x_nslds_pell_efc_1                  IN     NUMBER,
    x_nslds_pell_school_code_1          IN     NUMBER,
    x_nslds_pell_transcn_num_1          IN     NUMBER,
    x_nslds_pell_last_updt_dt_1         IN     DATE,
    x_nslds_pell_scheduled_amt_1        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_1        IN     NUMBER,
    x_nslds_pell_remng_amt_1            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_1       IN     NUMBER,
    x_nslds_pell_award_amt_1            IN     NUMBER,
    x_nslds_pell_seq_num_2              IN     NUMBER,
    x_nslds_pell_verify_f_2             IN     VARCHAR2,
    x_nslds_pell_efc_2                  IN     NUMBER,
    x_nslds_pell_school_code_2          IN     NUMBER,
    x_nslds_pell_transcn_num_2          IN     NUMBER,
    x_nslds_pell_last_updt_dt_2         IN     DATE,
    x_nslds_pell_scheduled_amt_2        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_2        IN     NUMBER,
    x_nslds_pell_remng_amt_2            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_2       IN     NUMBER,
    x_nslds_pell_award_amt_2            IN     NUMBER,
    x_nslds_pell_seq_num_3              IN     NUMBER,
    x_nslds_pell_verify_f_3             IN     VARCHAR2,
    x_nslds_pell_efc_3                  IN     NUMBER,
    x_nslds_pell_school_code_3          IN     NUMBER,
    x_nslds_pell_transcn_num_3          IN     NUMBER,
    x_nslds_pell_last_updt_dt_3         IN     DATE,
    x_nslds_pell_scheduled_amt_3        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_3        IN     NUMBER,
    x_nslds_pell_remng_amt_3            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_3       IN     NUMBER,
    x_nslds_pell_award_amt_3            IN     NUMBER,
    x_nslds_loan_seq_num_1              IN     NUMBER,
    x_nslds_loan_type_code_1            IN     VARCHAR2,
    x_nslds_loan_chng_f_1               IN     VARCHAR2,
    x_nslds_loan_prog_code_1            IN     VARCHAR2,
    x_nslds_loan_net_amnt_1             IN     NUMBER,
    x_nslds_loan_cur_st_code_1          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_1          IN     DATE,
    x_nslds_loan_agg_pr_bal_1           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_1        IN     DATE,
    x_nslds_loan_begin_dt_1             IN     DATE,
    x_nslds_loan_end_dt_1               IN     DATE,
    x_nslds_loan_ga_code_1              IN     VARCHAR2,
    x_nslds_loan_cont_type_1            IN     VARCHAR2,
    x_nslds_loan_schol_code_1           IN     VARCHAR2,
    x_nslds_loan_cont_code_1            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_1            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_1       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_1        IN     VARCHAR2,
    x_nslds_loan_seq_num_2              IN     NUMBER,
    x_nslds_loan_type_code_2            IN     VARCHAR2,
    x_nslds_loan_chng_f_2               IN     VARCHAR2,
    x_nslds_loan_prog_code_2            IN     VARCHAR2,
    x_nslds_loan_net_amnt_2             IN     NUMBER,
    x_nslds_loan_cur_st_code_2          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_2          IN     DATE,
    x_nslds_loan_agg_pr_bal_2           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_2        IN     DATE,
    x_nslds_loan_begin_dt_2             IN     DATE,
    x_nslds_loan_end_dt_2               IN     DATE,
    x_nslds_loan_ga_code_2              IN     VARCHAR2,
    x_nslds_loan_cont_type_2            IN     VARCHAR2,
    x_nslds_loan_schol_code_2           IN     VARCHAR2,
    x_nslds_loan_cont_code_2            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_2            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_2       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_2        IN     VARCHAR2,
    x_nslds_loan_seq_num_3              IN     NUMBER,
    x_nslds_loan_type_code_3            IN     VARCHAR2,
    x_nslds_loan_chng_f_3               IN     VARCHAR2,
    x_nslds_loan_prog_code_3            IN     VARCHAR2,
    x_nslds_loan_net_amnt_3             IN     NUMBER,
    x_nslds_loan_cur_st_code_3          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_3          IN     DATE,
    x_nslds_loan_agg_pr_bal_3           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_3        IN     DATE,
    x_nslds_loan_begin_dt_3             IN     DATE,
    x_nslds_loan_end_dt_3               IN     DATE,
    x_nslds_loan_ga_code_3              IN     VARCHAR2,
    x_nslds_loan_cont_type_3            IN     VARCHAR2,
    x_nslds_loan_schol_code_3           IN     VARCHAR2,
    x_nslds_loan_cont_code_3            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_3            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_3       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_3        IN     VARCHAR2,
    x_nslds_loan_seq_num_4              IN     NUMBER,
    x_nslds_loan_type_code_4            IN     VARCHAR2,
    x_nslds_loan_chng_f_4               IN     VARCHAR2,
    x_nslds_loan_prog_code_4            IN     VARCHAR2,
    x_nslds_loan_net_amnt_4             IN     NUMBER,
    x_nslds_loan_cur_st_code_4          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_4          IN     DATE,
    x_nslds_loan_agg_pr_bal_4           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_4        IN     DATE,
    x_nslds_loan_begin_dt_4             IN     DATE,
    x_nslds_loan_end_dt_4               IN     DATE,
    x_nslds_loan_ga_code_4              IN     VARCHAR2,
    x_nslds_loan_cont_type_4            IN     VARCHAR2,
    x_nslds_loan_schol_code_4           IN     VARCHAR2,
    x_nslds_loan_cont_code_4            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_4            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_4       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_4        IN     VARCHAR2,
    x_nslds_loan_seq_num_5              IN     NUMBER,
    x_nslds_loan_type_code_5            IN     VARCHAR2,
    x_nslds_loan_chng_f_5               IN     VARCHAR2,
    x_nslds_loan_prog_code_5            IN     VARCHAR2,
    x_nslds_loan_net_amnt_5             IN     NUMBER,
    x_nslds_loan_cur_st_code_5          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_5          IN     DATE,
    x_nslds_loan_agg_pr_bal_5           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_5        IN     DATE,
    x_nslds_loan_begin_dt_5             IN     DATE,
    x_nslds_loan_end_dt_5               IN     DATE,
    x_nslds_loan_ga_code_5              IN     VARCHAR2,
    x_nslds_loan_cont_type_5            IN     VARCHAR2,
    x_nslds_loan_schol_code_5           IN     VARCHAR2,
    x_nslds_loan_cont_code_5            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_5            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_5       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_5        IN     VARCHAR2,
    x_nslds_loan_seq_num_6              IN     NUMBER,
    x_nslds_loan_type_code_6            IN     VARCHAR2,
    x_nslds_loan_chng_f_6               IN     VARCHAR2,
    x_nslds_loan_prog_code_6            IN     VARCHAR2,
    x_nslds_loan_net_amnt_6             IN     NUMBER,
    x_nslds_loan_cur_st_code_6          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_6          IN     DATE,
    x_nslds_loan_agg_pr_bal_6           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_6        IN     DATE,
    x_nslds_loan_begin_dt_6             IN     DATE,
    x_nslds_loan_end_dt_6               IN     DATE,
    x_nslds_loan_ga_code_6              IN     VARCHAR2,
    x_nslds_loan_cont_type_6            IN     VARCHAR2,
    x_nslds_loan_schol_code_6           IN     VARCHAR2,
    x_nslds_loan_cont_code_6            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_6            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_6       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_6        IN     VARCHAR2,
    x_nslds_loan_last_d_amt_1           IN     NUMBER  ,
    x_nslds_loan_last_d_date_1          IN     DATE    ,
    x_nslds_loan_last_d_amt_2           IN     NUMBER  ,
    x_nslds_loan_last_d_date_2          IN     DATE    ,
    x_nslds_loan_last_d_amt_3           IN     NUMBER  ,
    x_nslds_loan_last_d_date_3          IN     DATE    ,
    x_nslds_loan_last_d_amt_4           IN     NUMBER  ,
    x_nslds_loan_last_d_date_4          IN     DATE    ,
    x_nslds_loan_last_d_amt_5           IN     NUMBER  ,
    x_nslds_loan_last_d_date_5          IN     DATE    ,
    x_nslds_loan_last_d_amt_6           IN     NUMBER  ,
    x_nslds_loan_last_d_date_6          IN     DATE    ,
    x_dlp_master_prom_note_flag         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_subsidized_loan_limit_type        IN     VARCHAR2,
    x_combined_loan_limit_type          IN     VARCHAR2,
    x_transaction_num_txt               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 06-DEC-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_nslds_id                          => x_nslds_id,
      x_isir_id                           => x_isir_id,
      x_base_id                           => x_base_id,
      x_nslds_transaction_num             => x_nslds_transaction_num,
      x_nslds_database_results_f          => x_nslds_database_results_f,
      x_nslds_f                           => x_nslds_f,
      x_nslds_pell_overpay_f              => x_nslds_pell_overpay_f,
      x_nslds_pell_overpay_contact        => x_nslds_pell_overpay_contact,
      x_nslds_seog_overpay_f              => x_nslds_seog_overpay_f,
      x_nslds_seog_overpay_contact        => x_nslds_seog_overpay_contact,
      x_nslds_perkins_overpay_f           => x_nslds_perkins_overpay_f,
      x_nslds_perkins_overpay_cntct       => x_nslds_perkins_overpay_cntct,
      x_nslds_defaulted_loan_f            => x_nslds_defaulted_loan_f,
      x_nslds_dischged_loan_chng_f        => x_nslds_dischged_loan_chng_f,
      x_nslds_satis_repay_f               => x_nslds_satis_repay_f,
      x_nslds_act_bankruptcy_f            => x_nslds_act_bankruptcy_f,
      x_nslds_agg_subsz_out_prin_bal      => x_nslds_agg_subsz_out_prin_bal,
      x_nslds_agg_unsbz_out_prin_bal      => x_nslds_agg_unsbz_out_prin_bal,
      x_nslds_agg_comb_out_prin_bal       => x_nslds_agg_comb_out_prin_bal,
      x_nslds_agg_cons_out_prin_bal       => x_nslds_agg_cons_out_prin_bal,
      x_nslds_agg_subsz_pend_dismt        => x_nslds_agg_subsz_pend_dismt,
      x_nslds_agg_unsbz_pend_dismt        => x_nslds_agg_unsbz_pend_dismt,
      x_nslds_agg_comb_pend_dismt         => x_nslds_agg_comb_pend_dismt,
      x_nslds_agg_subsz_total             => x_nslds_agg_subsz_total,
      x_nslds_agg_unsbz_total             => x_nslds_agg_unsbz_total,
      x_nslds_agg_comb_total              => x_nslds_agg_comb_total,
      x_nslds_agg_consd_total             => x_nslds_agg_consd_total,
      x_nslds_perkins_out_bal             => x_nslds_perkins_out_bal,
      x_nslds_perkins_cur_yr_dismnt       => x_nslds_perkins_cur_yr_dismnt,
      x_nslds_default_loan_chng_f         => x_nslds_default_loan_chng_f,
      x_nslds_discharged_loan_f           => x_nslds_discharged_loan_f,
      x_nslds_satis_repay_chng_f          => x_nslds_satis_repay_chng_f,
      x_nslds_act_bnkrupt_chng_f          => x_nslds_act_bnkrupt_chng_f,
      x_nslds_overpay_chng_f              => x_nslds_overpay_chng_f,
      x_nslds_agg_loan_chng_f             => x_nslds_agg_loan_chng_f,
      x_nslds_perkins_loan_chng_f         => x_nslds_perkins_loan_chng_f,
      x_nslds_pell_paymnt_chng_f          => x_nslds_pell_paymnt_chng_f,
      x_nslds_addtnl_pell_f               => x_nslds_addtnl_pell_f,
      x_nslds_addtnl_loan_f               => x_nslds_addtnl_loan_f,
      x_direct_loan_mas_prom_nt_f         => x_direct_loan_mas_prom_nt_f,
      x_nslds_pell_seq_num_1              => x_nslds_pell_seq_num_1,
      x_nslds_pell_verify_f_1             => x_nslds_pell_verify_f_1,
      x_nslds_pell_efc_1                  => x_nslds_pell_efc_1,
      x_nslds_pell_school_code_1          => x_nslds_pell_school_code_1,
      x_nslds_pell_transcn_num_1          => x_nslds_pell_transcn_num_1,
      x_nslds_pell_last_updt_dt_1         => x_nslds_pell_last_updt_dt_1,
      x_nslds_pell_scheduled_amt_1        => x_nslds_pell_scheduled_amt_1,
      x_nslds_pell_amt_paid_todt_1        => x_nslds_pell_amt_paid_todt_1,
      x_nslds_pell_remng_amt_1            => x_nslds_pell_remng_amt_1,
      x_nslds_pell_pc_schd_awd_us_1       => x_nslds_pell_pc_schd_awd_us_1,
      x_nslds_pell_award_amt_1            => x_nslds_pell_award_amt_1,
      x_nslds_pell_seq_num_2              => x_nslds_pell_seq_num_2,
      x_nslds_pell_verify_f_2             => x_nslds_pell_verify_f_2,
      x_nslds_pell_efc_2                  => x_nslds_pell_efc_2,
      x_nslds_pell_school_code_2          => x_nslds_pell_school_code_2,
      x_nslds_pell_transcn_num_2          => x_nslds_pell_transcn_num_2,
      x_nslds_pell_last_updt_dt_2         => x_nslds_pell_last_updt_dt_2,
      x_nslds_pell_scheduled_amt_2        => x_nslds_pell_scheduled_amt_2,
      x_nslds_pell_amt_paid_todt_2        => x_nslds_pell_amt_paid_todt_2,
      x_nslds_pell_remng_amt_2            => x_nslds_pell_remng_amt_2,
      x_nslds_pell_pc_schd_awd_us_2       => x_nslds_pell_pc_schd_awd_us_2,
      x_nslds_pell_award_amt_2            => x_nslds_pell_award_amt_2,
      x_nslds_pell_seq_num_3              => x_nslds_pell_seq_num_3,
      x_nslds_pell_verify_f_3             => x_nslds_pell_verify_f_3,
      x_nslds_pell_efc_3                  => x_nslds_pell_efc_3,
      x_nslds_pell_school_code_3          => x_nslds_pell_school_code_3,
      x_nslds_pell_transcn_num_3          => x_nslds_pell_transcn_num_3,
      x_nslds_pell_last_updt_dt_3         => x_nslds_pell_last_updt_dt_3,
      x_nslds_pell_scheduled_amt_3        => x_nslds_pell_scheduled_amt_3,
      x_nslds_pell_amt_paid_todt_3        => x_nslds_pell_amt_paid_todt_3,
      x_nslds_pell_remng_amt_3            => x_nslds_pell_remng_amt_3,
      x_nslds_pell_pc_schd_awd_us_3       => x_nslds_pell_pc_schd_awd_us_3,
      x_nslds_pell_award_amt_3            => x_nslds_pell_award_amt_3,
      x_nslds_loan_seq_num_1              => x_nslds_loan_seq_num_1,
      x_nslds_loan_type_code_1            => x_nslds_loan_type_code_1,
      x_nslds_loan_chng_f_1               => x_nslds_loan_chng_f_1,
      x_nslds_loan_prog_code_1            => x_nslds_loan_prog_code_1,
      x_nslds_loan_net_amnt_1             => x_nslds_loan_net_amnt_1,
      x_nslds_loan_cur_st_code_1          => x_nslds_loan_cur_st_code_1,
      x_nslds_loan_cur_st_date_1          => x_nslds_loan_cur_st_date_1,
      x_nslds_loan_agg_pr_bal_1           => x_nslds_loan_agg_pr_bal_1,
      x_nslds_loan_out_pr_bal_dt_1        => x_nslds_loan_out_pr_bal_dt_1,
      x_nslds_loan_begin_dt_1             => x_nslds_loan_begin_dt_1,
      x_nslds_loan_end_dt_1               => x_nslds_loan_end_dt_1,
      x_nslds_loan_ga_code_1              => x_nslds_loan_ga_code_1,
      x_nslds_loan_cont_type_1            => x_nslds_loan_cont_type_1,
      x_nslds_loan_schol_code_1           => x_nslds_loan_schol_code_1,
      x_nslds_loan_cont_code_1            => x_nslds_loan_cont_code_1,
      x_nslds_loan_grade_lvl_1            => x_nslds_loan_grade_lvl_1,
      x_nslds_loan_xtr_unsbz_ln_f_1       => x_nslds_loan_xtr_unsbz_ln_f_1,
      x_nslds_loan_capital_int_f_1        => x_nslds_loan_capital_int_f_1,
      x_nslds_loan_seq_num_2              => x_nslds_loan_seq_num_2,
      x_nslds_loan_type_code_2            => x_nslds_loan_type_code_2,
      x_nslds_loan_chng_f_2               => x_nslds_loan_chng_f_2,
      x_nslds_loan_prog_code_2            => x_nslds_loan_prog_code_2,
      x_nslds_loan_net_amnt_2             => x_nslds_loan_net_amnt_2,
      x_nslds_loan_cur_st_code_2          => x_nslds_loan_cur_st_code_2,
      x_nslds_loan_cur_st_date_2          => x_nslds_loan_cur_st_date_2,
      x_nslds_loan_agg_pr_bal_2           => x_nslds_loan_agg_pr_bal_2,
      x_nslds_loan_out_pr_bal_dt_2        => x_nslds_loan_out_pr_bal_dt_2,
      x_nslds_loan_begin_dt_2             => x_nslds_loan_begin_dt_2,
      x_nslds_loan_end_dt_2               => x_nslds_loan_end_dt_2,
      x_nslds_loan_ga_code_2              => x_nslds_loan_ga_code_2,
      x_nslds_loan_cont_type_2            => x_nslds_loan_cont_type_2,
      x_nslds_loan_schol_code_2           => x_nslds_loan_schol_code_2,
      x_nslds_loan_cont_code_2            => x_nslds_loan_cont_code_2,
      x_nslds_loan_grade_lvl_2            => x_nslds_loan_grade_lvl_2,
      x_nslds_loan_xtr_unsbz_ln_f_2       => x_nslds_loan_xtr_unsbz_ln_f_2,
      x_nslds_loan_capital_int_f_2        => x_nslds_loan_capital_int_f_2,
      x_nslds_loan_seq_num_3              => x_nslds_loan_seq_num_3,
      x_nslds_loan_type_code_3            => x_nslds_loan_type_code_3,
      x_nslds_loan_chng_f_3               => x_nslds_loan_chng_f_3,
      x_nslds_loan_prog_code_3            => x_nslds_loan_prog_code_3,
      x_nslds_loan_net_amnt_3             => x_nslds_loan_net_amnt_3,
      x_nslds_loan_cur_st_code_3          => x_nslds_loan_cur_st_code_3,
      x_nslds_loan_cur_st_date_3          => x_nslds_loan_cur_st_date_3,
      x_nslds_loan_agg_pr_bal_3           => x_nslds_loan_agg_pr_bal_3,
      x_nslds_loan_out_pr_bal_dt_3        => x_nslds_loan_out_pr_bal_dt_3,
      x_nslds_loan_begin_dt_3             => x_nslds_loan_begin_dt_3,
      x_nslds_loan_end_dt_3               => x_nslds_loan_end_dt_3,
      x_nslds_loan_ga_code_3              => x_nslds_loan_ga_code_3,
      x_nslds_loan_cont_type_3            => x_nslds_loan_cont_type_3,
      x_nslds_loan_schol_code_3           => x_nslds_loan_schol_code_3,
      x_nslds_loan_cont_code_3            => x_nslds_loan_cont_code_3,
      x_nslds_loan_grade_lvl_3            => x_nslds_loan_grade_lvl_3,
      x_nslds_loan_xtr_unsbz_ln_f_3       => x_nslds_loan_xtr_unsbz_ln_f_3,
      x_nslds_loan_capital_int_f_3        => x_nslds_loan_capital_int_f_3,
      x_nslds_loan_seq_num_4              => x_nslds_loan_seq_num_4,
      x_nslds_loan_type_code_4            => x_nslds_loan_type_code_4,
      x_nslds_loan_chng_f_4               => x_nslds_loan_chng_f_4,
      x_nslds_loan_prog_code_4            => x_nslds_loan_prog_code_4,
      x_nslds_loan_net_amnt_4             => x_nslds_loan_net_amnt_4,
      x_nslds_loan_cur_st_code_4          => x_nslds_loan_cur_st_code_4,
      x_nslds_loan_cur_st_date_4          => x_nslds_loan_cur_st_date_4,
      x_nslds_loan_agg_pr_bal_4           => x_nslds_loan_agg_pr_bal_4,
      x_nslds_loan_out_pr_bal_dt_4        => x_nslds_loan_out_pr_bal_dt_4,
      x_nslds_loan_begin_dt_4             => x_nslds_loan_begin_dt_4,
      x_nslds_loan_end_dt_4               => x_nslds_loan_end_dt_4,
      x_nslds_loan_ga_code_4              => x_nslds_loan_ga_code_4,
      x_nslds_loan_cont_type_4            => x_nslds_loan_cont_type_4,
      x_nslds_loan_schol_code_4           => x_nslds_loan_schol_code_4,
      x_nslds_loan_cont_code_4            => x_nslds_loan_cont_code_4,
      x_nslds_loan_grade_lvl_4            => x_nslds_loan_grade_lvl_4,
      x_nslds_loan_xtr_unsbz_ln_f_4       => x_nslds_loan_xtr_unsbz_ln_f_4,
      x_nslds_loan_capital_int_f_4        => x_nslds_loan_capital_int_f_4,
      x_nslds_loan_seq_num_5              => x_nslds_loan_seq_num_5,
      x_nslds_loan_type_code_5            => x_nslds_loan_type_code_5,
      x_nslds_loan_chng_f_5               => x_nslds_loan_chng_f_5,
      x_nslds_loan_prog_code_5            => x_nslds_loan_prog_code_5,
      x_nslds_loan_net_amnt_5             => x_nslds_loan_net_amnt_5,
      x_nslds_loan_cur_st_code_5          => x_nslds_loan_cur_st_code_5,
      x_nslds_loan_cur_st_date_5          => x_nslds_loan_cur_st_date_5,
      x_nslds_loan_agg_pr_bal_5           => x_nslds_loan_agg_pr_bal_5,
      x_nslds_loan_out_pr_bal_dt_5        => x_nslds_loan_out_pr_bal_dt_5,
      x_nslds_loan_begin_dt_5             => x_nslds_loan_begin_dt_5,
      x_nslds_loan_end_dt_5               => x_nslds_loan_end_dt_5,
      x_nslds_loan_ga_code_5              => x_nslds_loan_ga_code_5,
      x_nslds_loan_cont_type_5            => x_nslds_loan_cont_type_5,
      x_nslds_loan_schol_code_5           => x_nslds_loan_schol_code_5,
      x_nslds_loan_cont_code_5            => x_nslds_loan_cont_code_5,
      x_nslds_loan_grade_lvl_5            => x_nslds_loan_grade_lvl_5,
      x_nslds_loan_xtr_unsbz_ln_f_5       => x_nslds_loan_xtr_unsbz_ln_f_5,
      x_nslds_loan_capital_int_f_5        => x_nslds_loan_capital_int_f_5,
      x_nslds_loan_seq_num_6              => x_nslds_loan_seq_num_6,
      x_nslds_loan_type_code_6            => x_nslds_loan_type_code_6,
      x_nslds_loan_chng_f_6               => x_nslds_loan_chng_f_6,
      x_nslds_loan_prog_code_6            => x_nslds_loan_prog_code_6,
      x_nslds_loan_net_amnt_6             => x_nslds_loan_net_amnt_6,
      x_nslds_loan_cur_st_code_6          => x_nslds_loan_cur_st_code_6,
      x_nslds_loan_cur_st_date_6          => x_nslds_loan_cur_st_date_6,
      x_nslds_loan_agg_pr_bal_6           => x_nslds_loan_agg_pr_bal_6,
      x_nslds_loan_out_pr_bal_dt_6        => x_nslds_loan_out_pr_bal_dt_6,
      x_nslds_loan_begin_dt_6             => x_nslds_loan_begin_dt_6,
      x_nslds_loan_end_dt_6               => x_nslds_loan_end_dt_6,
      x_nslds_loan_ga_code_6              => x_nslds_loan_ga_code_6,
      x_nslds_loan_cont_type_6            => x_nslds_loan_cont_type_6,
      x_nslds_loan_schol_code_6           => x_nslds_loan_schol_code_6,
      x_nslds_loan_cont_code_6            => x_nslds_loan_cont_code_6,
      x_nslds_loan_grade_lvl_6            => x_nslds_loan_grade_lvl_6,
      x_nslds_loan_xtr_unsbz_ln_f_6       => x_nslds_loan_xtr_unsbz_ln_f_6,
      x_nslds_loan_capital_int_f_6        => x_nslds_loan_capital_int_f_6,
      x_nslds_loan_last_d_amt_1           => x_nslds_loan_last_d_amt_1,
      x_nslds_loan_last_d_date_1          => x_nslds_loan_last_d_date_1,
      x_nslds_loan_last_d_amt_2           => x_nslds_loan_last_d_amt_2,
      x_nslds_loan_last_d_date_2          => x_nslds_loan_last_d_date_2,
      x_nslds_loan_last_d_amt_3           => x_nslds_loan_last_d_amt_3,
      x_nslds_loan_last_d_date_3          => x_nslds_loan_last_d_date_3,
      x_nslds_loan_last_d_amt_4           => x_nslds_loan_last_d_amt_4,
      x_nslds_loan_last_d_date_4          => x_nslds_loan_last_d_date_4,
      x_nslds_loan_last_d_amt_5           => x_nslds_loan_last_d_amt_5,
      x_nslds_loan_last_d_date_5          => x_nslds_loan_last_d_date_5,
      x_nslds_loan_last_d_amt_6           => x_nslds_loan_last_d_amt_6,
      x_nslds_loan_last_d_date_6          => x_nslds_loan_last_d_date_6,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_dlp_master_prom_note_flag         => x_dlp_master_prom_note_flag,
      x_subsidized_loan_limit_type        => x_subsidized_loan_limit_type,
      x_combined_loan_limit_type          => x_combined_loan_limit_type,
      x_transaction_num_txt               => x_transaction_num_txt
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igf_ap_nslds_data_all
      SET
        isir_id                           = new_references.isir_id,
        base_id                           = new_references.base_id,
        nslds_transaction_num             = new_references.nslds_transaction_num,
        nslds_database_results_f          = new_references.nslds_database_results_f,
        nslds_f                           = new_references.nslds_f,
        nslds_pell_overpay_f              = new_references.nslds_pell_overpay_f,
        nslds_pell_overpay_contact        = new_references.nslds_pell_overpay_contact,
        nslds_seog_overpay_f              = new_references.nslds_seog_overpay_f,
        nslds_seog_overpay_contact        = new_references.nslds_seog_overpay_contact,
        nslds_perkins_overpay_f           = new_references.nslds_perkins_overpay_f,
        nslds_perkins_overpay_cntct       = new_references.nslds_perkins_overpay_cntct,
        nslds_defaulted_loan_f            = new_references.nslds_defaulted_loan_f,
        nslds_dischged_loan_chng_f        = new_references.nslds_dischged_loan_chng_f,
        nslds_satis_repay_f               = new_references.nslds_satis_repay_f,
        nslds_act_bankruptcy_f            = new_references.nslds_act_bankruptcy_f,
        nslds_agg_subsz_out_prin_bal      = new_references.nslds_agg_subsz_out_prin_bal,
        nslds_agg_unsbz_out_prin_bal      = new_references.nslds_agg_unsbz_out_prin_bal,
        nslds_agg_comb_out_prin_bal       = new_references.nslds_agg_comb_out_prin_bal,
        nslds_agg_cons_out_prin_bal       = new_references.nslds_agg_cons_out_prin_bal,
        nslds_agg_subsz_pend_dismt        = new_references.nslds_agg_subsz_pend_dismt,
        nslds_agg_unsbz_pend_dismt        = new_references.nslds_agg_unsbz_pend_dismt,
        nslds_agg_comb_pend_dismt         = new_references.nslds_agg_comb_pend_dismt,
        nslds_agg_subsz_total             = new_references.nslds_agg_subsz_total,
        nslds_agg_unsbz_total             = new_references.nslds_agg_unsbz_total,
        nslds_agg_comb_total              = new_references.nslds_agg_comb_total,
        nslds_agg_consd_total             = new_references.nslds_agg_consd_total,
        nslds_perkins_out_bal             = new_references.nslds_perkins_out_bal,
        nslds_perkins_cur_yr_dismnt       = new_references.nslds_perkins_cur_yr_dismnt,
        nslds_default_loan_chng_f         = new_references.nslds_default_loan_chng_f,
        nslds_discharged_loan_f           = new_references.nslds_discharged_loan_f,
        nslds_satis_repay_chng_f          = new_references.nslds_satis_repay_chng_f,
        nslds_act_bnkrupt_chng_f          = new_references.nslds_act_bnkrupt_chng_f,
        nslds_overpay_chng_f              = new_references.nslds_overpay_chng_f,
        nslds_agg_loan_chng_f             = new_references.nslds_agg_loan_chng_f,
        nslds_perkins_loan_chng_f         = new_references.nslds_perkins_loan_chng_f,
        nslds_pell_paymnt_chng_f          = new_references.nslds_pell_paymnt_chng_f,
        nslds_addtnl_pell_f               = new_references.nslds_addtnl_pell_f,
        nslds_addtnl_loan_f               = new_references.nslds_addtnl_loan_f,
        direct_loan_mas_prom_nt_f         = new_references.direct_loan_mas_prom_nt_f,
        nslds_pell_seq_num_1              = new_references.nslds_pell_seq_num_1,
        nslds_pell_verify_f_1             = new_references.nslds_pell_verify_f_1,
        nslds_pell_efc_1                  = new_references.nslds_pell_efc_1,
        nslds_pell_school_code_1          = new_references.nslds_pell_school_code_1,
        nslds_pell_transcn_num_1          = new_references.nslds_pell_transcn_num_1,
        nslds_pell_last_updt_dt_1         = new_references.nslds_pell_last_updt_dt_1,
        nslds_pell_scheduled_amt_1        = new_references.nslds_pell_scheduled_amt_1,
        nslds_pell_amt_paid_todt_1        = new_references.nslds_pell_amt_paid_todt_1,
        nslds_pell_remng_amt_1            = new_references.nslds_pell_remng_amt_1,
        nslds_pell_pc_schd_awd_us_1       = new_references.nslds_pell_pc_schd_awd_us_1,
        nslds_pell_award_amt_1            = new_references.nslds_pell_award_amt_1,
        nslds_pell_seq_num_2              = new_references.nslds_pell_seq_num_2,
        nslds_pell_verify_f_2             = new_references.nslds_pell_verify_f_2,
        nslds_pell_efc_2                  = new_references.nslds_pell_efc_2,
        nslds_pell_school_code_2          = new_references.nslds_pell_school_code_2,
        nslds_pell_transcn_num_2          = new_references.nslds_pell_transcn_num_2,
        nslds_pell_last_updt_dt_2         = new_references.nslds_pell_last_updt_dt_2,
        nslds_pell_scheduled_amt_2        = new_references.nslds_pell_scheduled_amt_2,
        nslds_pell_amt_paid_todt_2        = new_references.nslds_pell_amt_paid_todt_2,
        nslds_pell_remng_amt_2            = new_references.nslds_pell_remng_amt_2,
        nslds_pell_pc_schd_awd_us_2       = new_references.nslds_pell_pc_schd_awd_us_2,
        nslds_pell_award_amt_2            = new_references.nslds_pell_award_amt_2,
        nslds_pell_seq_num_3              = new_references.nslds_pell_seq_num_3,
        nslds_pell_verify_f_3             = new_references.nslds_pell_verify_f_3,
        nslds_pell_efc_3                  = new_references.nslds_pell_efc_3,
        nslds_pell_school_code_3          = new_references.nslds_pell_school_code_3,
        nslds_pell_transcn_num_3          = new_references.nslds_pell_transcn_num_3,
        nslds_pell_last_updt_dt_3         = new_references.nslds_pell_last_updt_dt_3,
        nslds_pell_scheduled_amt_3        = new_references.nslds_pell_scheduled_amt_3,
        nslds_pell_amt_paid_todt_3        = new_references.nslds_pell_amt_paid_todt_3,
        nslds_pell_remng_amt_3            = new_references.nslds_pell_remng_amt_3,
        nslds_pell_pc_schd_awd_us_3       = new_references.nslds_pell_pc_schd_awd_us_3,
        nslds_pell_award_amt_3            = new_references.nslds_pell_award_amt_3,
        nslds_loan_seq_num_1              = new_references.nslds_loan_seq_num_1,
        nslds_loan_type_code_1            = new_references.nslds_loan_type_code_1,
        nslds_loan_chng_f_1               = new_references.nslds_loan_chng_f_1,
        nslds_loan_prog_code_1            = new_references.nslds_loan_prog_code_1,
        nslds_loan_net_amnt_1             = new_references.nslds_loan_net_amnt_1,
        nslds_loan_cur_st_code_1          = new_references.nslds_loan_cur_st_code_1,
        nslds_loan_cur_st_date_1          = new_references.nslds_loan_cur_st_date_1,
        nslds_loan_agg_pr_bal_1           = new_references.nslds_loan_agg_pr_bal_1,
        nslds_loan_out_pr_bal_dt_1        = new_references.nslds_loan_out_pr_bal_dt_1,
        nslds_loan_begin_dt_1             = new_references.nslds_loan_begin_dt_1,
        nslds_loan_end_dt_1               = new_references.nslds_loan_end_dt_1,
        nslds_loan_ga_code_1              = new_references.nslds_loan_ga_code_1,
        nslds_loan_cont_type_1            = new_references.nslds_loan_cont_type_1,
        nslds_loan_schol_code_1           = new_references.nslds_loan_schol_code_1,
        nslds_loan_cont_code_1            = new_references.nslds_loan_cont_code_1,
        nslds_loan_grade_lvl_1            = new_references.nslds_loan_grade_lvl_1,
        nslds_loan_xtr_unsbz_ln_f_1       = new_references.nslds_loan_xtr_unsbz_ln_f_1,
        nslds_loan_capital_int_f_1        = new_references.nslds_loan_capital_int_f_1,
        nslds_loan_seq_num_2              = new_references.nslds_loan_seq_num_2,
        nslds_loan_type_code_2            = new_references.nslds_loan_type_code_2,
        nslds_loan_chng_f_2               = new_references.nslds_loan_chng_f_2,
        nslds_loan_prog_code_2            = new_references.nslds_loan_prog_code_2,
        nslds_loan_net_amnt_2             = new_references.nslds_loan_net_amnt_2,
        nslds_loan_cur_st_code_2          = new_references.nslds_loan_cur_st_code_2,
        nslds_loan_cur_st_date_2          = new_references.nslds_loan_cur_st_date_2,
        nslds_loan_agg_pr_bal_2           = new_references.nslds_loan_agg_pr_bal_2,
        nslds_loan_out_pr_bal_dt_2        = new_references.nslds_loan_out_pr_bal_dt_2,
        nslds_loan_begin_dt_2             = new_references.nslds_loan_begin_dt_2,
        nslds_loan_end_dt_2               = new_references.nslds_loan_end_dt_2,
        nslds_loan_ga_code_2              = new_references.nslds_loan_ga_code_2,
        nslds_loan_cont_type_2            = new_references.nslds_loan_cont_type_2,
        nslds_loan_schol_code_2           = new_references.nslds_loan_schol_code_2,
        nslds_loan_cont_code_2            = new_references.nslds_loan_cont_code_2,
        nslds_loan_grade_lvl_2            = new_references.nslds_loan_grade_lvl_2,
        nslds_loan_xtr_unsbz_ln_f_2       = new_references.nslds_loan_xtr_unsbz_ln_f_2,
        nslds_loan_capital_int_f_2        = new_references.nslds_loan_capital_int_f_2,
        nslds_loan_seq_num_3              = new_references.nslds_loan_seq_num_3,
        nslds_loan_type_code_3            = new_references.nslds_loan_type_code_3,
        nslds_loan_chng_f_3               = new_references.nslds_loan_chng_f_3,
        nslds_loan_prog_code_3            = new_references.nslds_loan_prog_code_3,
        nslds_loan_net_amnt_3             = new_references.nslds_loan_net_amnt_3,
        nslds_loan_cur_st_code_3          = new_references.nslds_loan_cur_st_code_3,
        nslds_loan_cur_st_date_3          = new_references.nslds_loan_cur_st_date_3,
        nslds_loan_agg_pr_bal_3           = new_references.nslds_loan_agg_pr_bal_3,
        nslds_loan_out_pr_bal_dt_3        = new_references.nslds_loan_out_pr_bal_dt_3,
        nslds_loan_begin_dt_3             = new_references.nslds_loan_begin_dt_3,
        nslds_loan_end_dt_3               = new_references.nslds_loan_end_dt_3,
        nslds_loan_ga_code_3              = new_references.nslds_loan_ga_code_3,
        nslds_loan_cont_type_3            = new_references.nslds_loan_cont_type_3,
        nslds_loan_schol_code_3           = new_references.nslds_loan_schol_code_3,
        nslds_loan_cont_code_3            = new_references.nslds_loan_cont_code_3,
        nslds_loan_grade_lvl_3            = new_references.nslds_loan_grade_lvl_3,
        nslds_loan_xtr_unsbz_ln_f_3       = new_references.nslds_loan_xtr_unsbz_ln_f_3,
        nslds_loan_capital_int_f_3        = new_references.nslds_loan_capital_int_f_3,
        nslds_loan_seq_num_4              = new_references.nslds_loan_seq_num_4,
        nslds_loan_type_code_4            = new_references.nslds_loan_type_code_4,
        nslds_loan_chng_f_4               = new_references.nslds_loan_chng_f_4,
        nslds_loan_prog_code_4            = new_references.nslds_loan_prog_code_4,
        nslds_loan_net_amnt_4             = new_references.nslds_loan_net_amnt_4,
        nslds_loan_cur_st_code_4          = new_references.nslds_loan_cur_st_code_4,
        nslds_loan_cur_st_date_4          = new_references.nslds_loan_cur_st_date_4,
        nslds_loan_agg_pr_bal_4           = new_references.nslds_loan_agg_pr_bal_4,
        nslds_loan_out_pr_bal_dt_4        = new_references.nslds_loan_out_pr_bal_dt_4,
        nslds_loan_begin_dt_4             = new_references.nslds_loan_begin_dt_4,
        nslds_loan_end_dt_4               = new_references.nslds_loan_end_dt_4,
        nslds_loan_ga_code_4              = new_references.nslds_loan_ga_code_4,
        nslds_loan_cont_type_4            = new_references.nslds_loan_cont_type_4,
        nslds_loan_schol_code_4           = new_references.nslds_loan_schol_code_4,
        nslds_loan_cont_code_4            = new_references.nslds_loan_cont_code_4,
        nslds_loan_grade_lvl_4            = new_references.nslds_loan_grade_lvl_4,
        nslds_loan_xtr_unsbz_ln_f_4       = new_references.nslds_loan_xtr_unsbz_ln_f_4,
        nslds_loan_capital_int_f_4        = new_references.nslds_loan_capital_int_f_4,
        nslds_loan_seq_num_5              = new_references.nslds_loan_seq_num_5,
        nslds_loan_type_code_5            = new_references.nslds_loan_type_code_5,
        nslds_loan_chng_f_5               = new_references.nslds_loan_chng_f_5,
        nslds_loan_prog_code_5            = new_references.nslds_loan_prog_code_5,
        nslds_loan_net_amnt_5             = new_references.nslds_loan_net_amnt_5,
        nslds_loan_cur_st_code_5          = new_references.nslds_loan_cur_st_code_5,
        nslds_loan_cur_st_date_5          = new_references.nslds_loan_cur_st_date_5,
        nslds_loan_agg_pr_bal_5           = new_references.nslds_loan_agg_pr_bal_5,
        nslds_loan_out_pr_bal_dt_5        = new_references.nslds_loan_out_pr_bal_dt_5,
        nslds_loan_begin_dt_5             = new_references.nslds_loan_begin_dt_5,
        nslds_loan_end_dt_5               = new_references.nslds_loan_end_dt_5,
        nslds_loan_ga_code_5              = new_references.nslds_loan_ga_code_5,
        nslds_loan_cont_type_5            = new_references.nslds_loan_cont_type_5,
        nslds_loan_schol_code_5           = new_references.nslds_loan_schol_code_5,
        nslds_loan_cont_code_5            = new_references.nslds_loan_cont_code_5,
        nslds_loan_grade_lvl_5            = new_references.nslds_loan_grade_lvl_5,
        nslds_loan_xtr_unsbz_ln_f_5       = new_references.nslds_loan_xtr_unsbz_ln_f_5,
        nslds_loan_capital_int_f_5        = new_references.nslds_loan_capital_int_f_5,
        nslds_loan_seq_num_6              = new_references.nslds_loan_seq_num_6,
        nslds_loan_type_code_6            = new_references.nslds_loan_type_code_6,
        nslds_loan_chng_f_6               = new_references.nslds_loan_chng_f_6,
        nslds_loan_prog_code_6            = new_references.nslds_loan_prog_code_6,
        nslds_loan_net_amnt_6             = new_references.nslds_loan_net_amnt_6,
        nslds_loan_cur_st_code_6          = new_references.nslds_loan_cur_st_code_6,
        nslds_loan_cur_st_date_6          = new_references.nslds_loan_cur_st_date_6,
        nslds_loan_agg_pr_bal_6           = new_references.nslds_loan_agg_pr_bal_6,
        nslds_loan_out_pr_bal_dt_6        = new_references.nslds_loan_out_pr_bal_dt_6,
        nslds_loan_begin_dt_6             = new_references.nslds_loan_begin_dt_6,
        nslds_loan_end_dt_6               = new_references.nslds_loan_end_dt_6,
        nslds_loan_ga_code_6              = new_references.nslds_loan_ga_code_6,
        nslds_loan_cont_type_6            = new_references.nslds_loan_cont_type_6,
        nslds_loan_schol_code_6           = new_references.nslds_loan_schol_code_6,
        nslds_loan_cont_code_6            = new_references.nslds_loan_cont_code_6,
        nslds_loan_grade_lvl_6            = new_references.nslds_loan_grade_lvl_6,
        nslds_loan_xtr_unsbz_ln_f_6       = new_references.nslds_loan_xtr_unsbz_ln_f_6,
        nslds_loan_capital_int_f_6        = new_references.nslds_loan_capital_int_f_6,
        nslds_loan_last_d_amt_1	          = new_references.nslds_loan_last_d_amt_1,
        nslds_loan_last_d_date_1          = new_references.nslds_loan_last_d_date_1,
        nslds_loan_last_d_amt_2	          = new_references.nslds_loan_last_d_amt_2,
        nslds_loan_last_d_date_2          = new_references.nslds_loan_last_d_date_2,
        nslds_loan_last_d_amt_3	          = new_references.nslds_loan_last_d_amt_3,
        nslds_loan_last_d_date_3          = new_references.nslds_loan_last_d_date_3,
        nslds_loan_last_d_amt_4	          = new_references.nslds_loan_last_d_amt_4,
        nslds_loan_last_d_date_4          = new_references.nslds_loan_last_d_date_4,
        nslds_loan_last_d_amt_5	          = new_references.nslds_loan_last_d_amt_5,
        nslds_loan_last_d_date_5          = new_references.nslds_loan_last_d_date_5,
        nslds_loan_last_d_amt_6	          = new_references.nslds_loan_last_d_amt_6,
        nslds_loan_last_d_date_6          = new_references.nslds_loan_last_d_date_6,
        dlp_master_prom_note_flag         = new_references.dlp_master_prom_note_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        subsidized_loan_limit_type        = x_subsidized_loan_limit_type,
        combined_loan_limit_type          = x_combined_loan_limit_type,
        transaction_num_txt               = x_transaction_num_txt
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT  NOCOPY VARCHAR2,
    x_nslds_id                          IN OUT  NOCOPY NUMBER,
    x_isir_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_nslds_transaction_num             IN     NUMBER,
    x_nslds_database_results_f          IN     VARCHAR2,
    x_nslds_f                           IN     VARCHAR2,
    x_nslds_pell_overpay_f              IN     VARCHAR2,
    x_nslds_pell_overpay_contact        IN     VARCHAR2,
    x_nslds_seog_overpay_f              IN     VARCHAR2,
    x_nslds_seog_overpay_contact        IN     VARCHAR2,
    x_nslds_perkins_overpay_f           IN     VARCHAR2,
    x_nslds_perkins_overpay_cntct       IN     VARCHAR2,
    x_nslds_defaulted_loan_f            IN     VARCHAR2,
    x_nslds_dischged_loan_chng_f        IN     VARCHAR2,
    x_nslds_satis_repay_f               IN     VARCHAR2,
    x_nslds_act_bankruptcy_f            IN     VARCHAR2,
    x_nslds_agg_subsz_out_prin_bal      IN     NUMBER,
    x_nslds_agg_unsbz_out_prin_bal      IN     NUMBER,
    x_nslds_agg_comb_out_prin_bal       IN     NUMBER,
    x_nslds_agg_cons_out_prin_bal       IN     NUMBER,
    x_nslds_agg_subsz_pend_dismt        IN     NUMBER,
    x_nslds_agg_unsbz_pend_dismt        IN     NUMBER,
    x_nslds_agg_comb_pend_dismt         IN     NUMBER,
    x_nslds_agg_subsz_total             IN     NUMBER,
    x_nslds_agg_unsbz_total             IN     NUMBER,
    x_nslds_agg_comb_total              IN     NUMBER,
    x_nslds_agg_consd_total             IN     NUMBER,
    x_nslds_perkins_out_bal             IN     NUMBER,
    x_nslds_perkins_cur_yr_dismnt       IN     NUMBER,
    x_nslds_default_loan_chng_f         IN     VARCHAR2,
    x_nslds_discharged_loan_f           IN     VARCHAR2,
    x_nslds_satis_repay_chng_f          IN     VARCHAR2,
    x_nslds_act_bnkrupt_chng_f          IN     VARCHAR2,
    x_nslds_overpay_chng_f              IN     VARCHAR2,
    x_nslds_agg_loan_chng_f             IN     VARCHAR2,
    x_nslds_perkins_loan_chng_f         IN     VARCHAR2,
    x_nslds_pell_paymnt_chng_f          IN     VARCHAR2,
    x_nslds_addtnl_pell_f               IN     VARCHAR2,
    x_nslds_addtnl_loan_f               IN     VARCHAR2,
    x_direct_loan_mas_prom_nt_f         IN     VARCHAR2,
    x_nslds_pell_seq_num_1              IN     NUMBER,
    x_nslds_pell_verify_f_1             IN     VARCHAR2,
    x_nslds_pell_efc_1                  IN     NUMBER,
    x_nslds_pell_school_code_1          IN     NUMBER,
    x_nslds_pell_transcn_num_1          IN     NUMBER,
    x_nslds_pell_last_updt_dt_1         IN     DATE,
    x_nslds_pell_scheduled_amt_1        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_1        IN     NUMBER,
    x_nslds_pell_remng_amt_1            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_1       IN     NUMBER,
    x_nslds_pell_award_amt_1            IN     NUMBER,
    x_nslds_pell_seq_num_2              IN     NUMBER,
    x_nslds_pell_verify_f_2             IN     VARCHAR2,
    x_nslds_pell_efc_2                  IN     NUMBER,
    x_nslds_pell_school_code_2          IN     NUMBER,
    x_nslds_pell_transcn_num_2          IN     NUMBER,
    x_nslds_pell_last_updt_dt_2         IN     DATE,
    x_nslds_pell_scheduled_amt_2        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_2        IN     NUMBER,
    x_nslds_pell_remng_amt_2            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_2       IN     NUMBER,
    x_nslds_pell_award_amt_2            IN     NUMBER,
    x_nslds_pell_seq_num_3              IN     NUMBER,
    x_nslds_pell_verify_f_3             IN     VARCHAR2,
    x_nslds_pell_efc_3                  IN     NUMBER,
    x_nslds_pell_school_code_3          IN     NUMBER,
    x_nslds_pell_transcn_num_3          IN     NUMBER,
    x_nslds_pell_last_updt_dt_3         IN     DATE,
    x_nslds_pell_scheduled_amt_3        IN     NUMBER,
    x_nslds_pell_amt_paid_todt_3        IN     NUMBER,
    x_nslds_pell_remng_amt_3            IN     NUMBER,
    x_nslds_pell_pc_schd_awd_us_3       IN     NUMBER,
    x_nslds_pell_award_amt_3            IN     NUMBER,
    x_nslds_loan_seq_num_1              IN     NUMBER,
    x_nslds_loan_type_code_1            IN     VARCHAR2,
    x_nslds_loan_chng_f_1               IN     VARCHAR2,
    x_nslds_loan_prog_code_1            IN     VARCHAR2,
    x_nslds_loan_net_amnt_1             IN     NUMBER,
    x_nslds_loan_cur_st_code_1          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_1          IN     DATE,
    x_nslds_loan_agg_pr_bal_1           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_1        IN     DATE,
    x_nslds_loan_begin_dt_1             IN     DATE,
    x_nslds_loan_end_dt_1               IN     DATE,
    x_nslds_loan_ga_code_1              IN     VARCHAR2,
    x_nslds_loan_cont_type_1            IN     VARCHAR2,
    x_nslds_loan_schol_code_1           IN     VARCHAR2,
    x_nslds_loan_cont_code_1            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_1            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_1       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_1        IN     VARCHAR2,
    x_nslds_loan_seq_num_2              IN     NUMBER,
    x_nslds_loan_type_code_2            IN     VARCHAR2,
    x_nslds_loan_chng_f_2               IN     VARCHAR2,
    x_nslds_loan_prog_code_2            IN     VARCHAR2,
    x_nslds_loan_net_amnt_2             IN     NUMBER,
    x_nslds_loan_cur_st_code_2          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_2          IN     DATE,
    x_nslds_loan_agg_pr_bal_2           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_2        IN     DATE,
    x_nslds_loan_begin_dt_2             IN     DATE,
    x_nslds_loan_end_dt_2               IN     DATE,
    x_nslds_loan_ga_code_2              IN     VARCHAR2,
    x_nslds_loan_cont_type_2            IN     VARCHAR2,
    x_nslds_loan_schol_code_2           IN     VARCHAR2,
    x_nslds_loan_cont_code_2            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_2            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_2       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_2        IN     VARCHAR2,
    x_nslds_loan_seq_num_3              IN     NUMBER,
    x_nslds_loan_type_code_3            IN     VARCHAR2,
    x_nslds_loan_chng_f_3               IN     VARCHAR2,
    x_nslds_loan_prog_code_3            IN     VARCHAR2,
    x_nslds_loan_net_amnt_3             IN     NUMBER,
    x_nslds_loan_cur_st_code_3          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_3          IN     DATE,
    x_nslds_loan_agg_pr_bal_3           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_3        IN     DATE,
    x_nslds_loan_begin_dt_3             IN     DATE,
    x_nslds_loan_end_dt_3               IN     DATE,
    x_nslds_loan_ga_code_3              IN     VARCHAR2,
    x_nslds_loan_cont_type_3            IN     VARCHAR2,
    x_nslds_loan_schol_code_3           IN     VARCHAR2,
    x_nslds_loan_cont_code_3            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_3            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_3       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_3        IN     VARCHAR2,
    x_nslds_loan_seq_num_4              IN     NUMBER,
    x_nslds_loan_type_code_4            IN     VARCHAR2,
    x_nslds_loan_chng_f_4               IN     VARCHAR2,
    x_nslds_loan_prog_code_4            IN     VARCHAR2,
    x_nslds_loan_net_amnt_4             IN     NUMBER,
    x_nslds_loan_cur_st_code_4          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_4          IN     DATE,
    x_nslds_loan_agg_pr_bal_4           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_4        IN     DATE,
    x_nslds_loan_begin_dt_4             IN     DATE,
    x_nslds_loan_end_dt_4               IN     DATE,
    x_nslds_loan_ga_code_4              IN     VARCHAR2,
    x_nslds_loan_cont_type_4            IN     VARCHAR2,
    x_nslds_loan_schol_code_4           IN     VARCHAR2,
    x_nslds_loan_cont_code_4            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_4            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_4       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_4        IN     VARCHAR2,
    x_nslds_loan_seq_num_5              IN     NUMBER,
    x_nslds_loan_type_code_5            IN     VARCHAR2,
    x_nslds_loan_chng_f_5               IN     VARCHAR2,
    x_nslds_loan_prog_code_5            IN     VARCHAR2,
    x_nslds_loan_net_amnt_5             IN     NUMBER,
    x_nslds_loan_cur_st_code_5          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_5          IN     DATE,
    x_nslds_loan_agg_pr_bal_5           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_5        IN     DATE,
    x_nslds_loan_begin_dt_5             IN     DATE,
    x_nslds_loan_end_dt_5               IN     DATE,
    x_nslds_loan_ga_code_5              IN     VARCHAR2,
    x_nslds_loan_cont_type_5            IN     VARCHAR2,
    x_nslds_loan_schol_code_5           IN     VARCHAR2,
    x_nslds_loan_cont_code_5            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_5            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_5       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_5        IN     VARCHAR2,
    x_nslds_loan_seq_num_6              IN     NUMBER,
    x_nslds_loan_type_code_6            IN     VARCHAR2,
    x_nslds_loan_chng_f_6               IN     VARCHAR2,
    x_nslds_loan_prog_code_6            IN     VARCHAR2,
    x_nslds_loan_net_amnt_6             IN     NUMBER,
    x_nslds_loan_cur_st_code_6          IN     VARCHAR2,
    x_nslds_loan_cur_st_date_6          IN     DATE,
    x_nslds_loan_agg_pr_bal_6           IN     NUMBER,
    x_nslds_loan_out_pr_bal_dt_6        IN     DATE,
    x_nslds_loan_begin_dt_6             IN     DATE,
    x_nslds_loan_end_dt_6               IN     DATE,
    x_nslds_loan_ga_code_6              IN     VARCHAR2,
    x_nslds_loan_cont_type_6            IN     VARCHAR2,
    x_nslds_loan_schol_code_6           IN     VARCHAR2,
    x_nslds_loan_cont_code_6            IN     VARCHAR2,
    x_nslds_loan_grade_lvl_6            IN     VARCHAR2,
    x_nslds_loan_xtr_unsbz_ln_f_6       IN     VARCHAR2,
    x_nslds_loan_capital_int_f_6        IN     VARCHAR2,
    x_nslds_loan_last_d_amt_1           IN     NUMBER  ,
    x_nslds_loan_last_d_date_1          IN     DATE    ,
    x_nslds_loan_last_d_amt_2           IN     NUMBER  ,
    x_nslds_loan_last_d_date_2          IN     DATE    ,
    x_nslds_loan_last_d_amt_3           IN     NUMBER  ,
    x_nslds_loan_last_d_date_3          IN     DATE    ,
    x_nslds_loan_last_d_amt_4           IN     NUMBER  ,
    x_nslds_loan_last_d_date_4          IN     DATE    ,
    x_nslds_loan_last_d_amt_5           IN     NUMBER  ,
    x_nslds_loan_last_d_date_5          IN     DATE    ,
    x_nslds_loan_last_d_amt_6           IN     NUMBER  ,
    x_nslds_loan_last_d_date_6          IN     DATE    ,
    x_dlp_master_prom_note_flag         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_subsidized_loan_limit_type        IN     VARCHAR2,
    x_combined_loan_limit_type          IN     VARCHAR2,
    x_transaction_num_txt               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 06-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_nslds_data_all
      WHERE    nslds_id                          = x_nslds_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_nslds_id,
        x_isir_id,
        x_base_id,
        x_nslds_transaction_num,
        x_nslds_database_results_f,
        x_nslds_f,
        x_nslds_pell_overpay_f,
        x_nslds_pell_overpay_contact,
        x_nslds_seog_overpay_f,
        x_nslds_seog_overpay_contact,
        x_nslds_perkins_overpay_f,
        x_nslds_perkins_overpay_cntct,
        x_nslds_defaulted_loan_f,
        x_nslds_dischged_loan_chng_f,
        x_nslds_satis_repay_f,
        x_nslds_act_bankruptcy_f,
        x_nslds_agg_subsz_out_prin_bal,
        x_nslds_agg_unsbz_out_prin_bal,
        x_nslds_agg_comb_out_prin_bal,
        x_nslds_agg_cons_out_prin_bal,
        x_nslds_agg_subsz_pend_dismt,
        x_nslds_agg_unsbz_pend_dismt,
        x_nslds_agg_comb_pend_dismt,
        x_nslds_agg_subsz_total,
        x_nslds_agg_unsbz_total,
        x_nslds_agg_comb_total,
        x_nslds_agg_consd_total,
        x_nslds_perkins_out_bal,
        x_nslds_perkins_cur_yr_dismnt,
        x_nslds_default_loan_chng_f,
        x_nslds_discharged_loan_f,
        x_nslds_satis_repay_chng_f,
        x_nslds_act_bnkrupt_chng_f,
        x_nslds_overpay_chng_f,
        x_nslds_agg_loan_chng_f,
        x_nslds_perkins_loan_chng_f,
        x_nslds_pell_paymnt_chng_f,
        x_nslds_addtnl_pell_f,
        x_nslds_addtnl_loan_f,
        x_direct_loan_mas_prom_nt_f,
        x_nslds_pell_seq_num_1,
        x_nslds_pell_verify_f_1,
        x_nslds_pell_efc_1,
        x_nslds_pell_school_code_1,
        x_nslds_pell_transcn_num_1,
        x_nslds_pell_last_updt_dt_1,
        x_nslds_pell_scheduled_amt_1,
        x_nslds_pell_amt_paid_todt_1,
        x_nslds_pell_remng_amt_1,
        x_nslds_pell_pc_schd_awd_us_1,
        x_nslds_pell_award_amt_1,
        x_nslds_pell_seq_num_2,
        x_nslds_pell_verify_f_2,
        x_nslds_pell_efc_2,
        x_nslds_pell_school_code_2,
        x_nslds_pell_transcn_num_2,
        x_nslds_pell_last_updt_dt_2,
        x_nslds_pell_scheduled_amt_2,
        x_nslds_pell_amt_paid_todt_2,
        x_nslds_pell_remng_amt_2,
        x_nslds_pell_pc_schd_awd_us_2,
        x_nslds_pell_award_amt_2,
        x_nslds_pell_seq_num_3,
        x_nslds_pell_verify_f_3,
        x_nslds_pell_efc_3,
        x_nslds_pell_school_code_3,
        x_nslds_pell_transcn_num_3,
        x_nslds_pell_last_updt_dt_3,
        x_nslds_pell_scheduled_amt_3,
        x_nslds_pell_amt_paid_todt_3,
        x_nslds_pell_remng_amt_3,
        x_nslds_pell_pc_schd_awd_us_3,
        x_nslds_pell_award_amt_3,
        x_nslds_loan_seq_num_1,
        x_nslds_loan_type_code_1,
        x_nslds_loan_chng_f_1,
        x_nslds_loan_prog_code_1,
        x_nslds_loan_net_amnt_1,
        x_nslds_loan_cur_st_code_1,
        x_nslds_loan_cur_st_date_1,
        x_nslds_loan_agg_pr_bal_1,
        x_nslds_loan_out_pr_bal_dt_1,
        x_nslds_loan_begin_dt_1,
        x_nslds_loan_end_dt_1,
        x_nslds_loan_ga_code_1,
        x_nslds_loan_cont_type_1,
        x_nslds_loan_schol_code_1,
        x_nslds_loan_cont_code_1,
        x_nslds_loan_grade_lvl_1,
        x_nslds_loan_xtr_unsbz_ln_f_1,
        x_nslds_loan_capital_int_f_1,
        x_nslds_loan_seq_num_2,
        x_nslds_loan_type_code_2,
        x_nslds_loan_chng_f_2,
        x_nslds_loan_prog_code_2,
        x_nslds_loan_net_amnt_2,
        x_nslds_loan_cur_st_code_2,
        x_nslds_loan_cur_st_date_2,
        x_nslds_loan_agg_pr_bal_2,
        x_nslds_loan_out_pr_bal_dt_2,
        x_nslds_loan_begin_dt_2,
        x_nslds_loan_end_dt_2,
        x_nslds_loan_ga_code_2,
        x_nslds_loan_cont_type_2,
        x_nslds_loan_schol_code_2,
        x_nslds_loan_cont_code_2,
        x_nslds_loan_grade_lvl_2,
        x_nslds_loan_xtr_unsbz_ln_f_2,
        x_nslds_loan_capital_int_f_2,
        x_nslds_loan_seq_num_3,
        x_nslds_loan_type_code_3,
        x_nslds_loan_chng_f_3,
        x_nslds_loan_prog_code_3,
        x_nslds_loan_net_amnt_3,
        x_nslds_loan_cur_st_code_3,
        x_nslds_loan_cur_st_date_3,
        x_nslds_loan_agg_pr_bal_3,
        x_nslds_loan_out_pr_bal_dt_3,
        x_nslds_loan_begin_dt_3,
        x_nslds_loan_end_dt_3,
        x_nslds_loan_ga_code_3,
        x_nslds_loan_cont_type_3,
        x_nslds_loan_schol_code_3,
        x_nslds_loan_cont_code_3,
        x_nslds_loan_grade_lvl_3,
        x_nslds_loan_xtr_unsbz_ln_f_3,
        x_nslds_loan_capital_int_f_3,
        x_nslds_loan_seq_num_4,
        x_nslds_loan_type_code_4,
        x_nslds_loan_chng_f_4,
        x_nslds_loan_prog_code_4,
        x_nslds_loan_net_amnt_4,
        x_nslds_loan_cur_st_code_4,
        x_nslds_loan_cur_st_date_4,
        x_nslds_loan_agg_pr_bal_4,
        x_nslds_loan_out_pr_bal_dt_4,
        x_nslds_loan_begin_dt_4,
        x_nslds_loan_end_dt_4,
        x_nslds_loan_ga_code_4,
        x_nslds_loan_cont_type_4,
        x_nslds_loan_schol_code_4,
        x_nslds_loan_cont_code_4,
        x_nslds_loan_grade_lvl_4,
        x_nslds_loan_xtr_unsbz_ln_f_4,
        x_nslds_loan_capital_int_f_4,
        x_nslds_loan_seq_num_5,
        x_nslds_loan_type_code_5,
        x_nslds_loan_chng_f_5,
        x_nslds_loan_prog_code_5,
        x_nslds_loan_net_amnt_5,
        x_nslds_loan_cur_st_code_5,
        x_nslds_loan_cur_st_date_5,
        x_nslds_loan_agg_pr_bal_5,
        x_nslds_loan_out_pr_bal_dt_5,
        x_nslds_loan_begin_dt_5,
        x_nslds_loan_end_dt_5,
        x_nslds_loan_ga_code_5,
        x_nslds_loan_cont_type_5,
        x_nslds_loan_schol_code_5,
        x_nslds_loan_cont_code_5,
        x_nslds_loan_grade_lvl_5,
        x_nslds_loan_xtr_unsbz_ln_f_5,
        x_nslds_loan_capital_int_f_5,
        x_nslds_loan_seq_num_6,
        x_nslds_loan_type_code_6,
        x_nslds_loan_chng_f_6,
        x_nslds_loan_prog_code_6,
        x_nslds_loan_net_amnt_6,
        x_nslds_loan_cur_st_code_6,
        x_nslds_loan_cur_st_date_6,
        x_nslds_loan_agg_pr_bal_6,
        x_nslds_loan_out_pr_bal_dt_6,
        x_nslds_loan_begin_dt_6,
        x_nslds_loan_end_dt_6,
        x_nslds_loan_ga_code_6,
        x_nslds_loan_cont_type_6,
        x_nslds_loan_schol_code_6,
        x_nslds_loan_cont_code_6,
        x_nslds_loan_grade_lvl_6,
        x_nslds_loan_xtr_unsbz_ln_f_6,
        x_nslds_loan_capital_int_f_6,
        x_nslds_loan_last_d_amt_1,
        x_nslds_loan_last_d_date_1,
        x_nslds_loan_last_d_amt_2,
        x_nslds_loan_last_d_date_2,
        x_nslds_loan_last_d_amt_3,
        x_nslds_loan_last_d_date_3,
        x_nslds_loan_last_d_amt_4,
        x_nslds_loan_last_d_date_4,
        x_nslds_loan_last_d_amt_5,
        x_nslds_loan_last_d_date_5,
        x_nslds_loan_last_d_amt_6,
        x_nslds_loan_last_d_date_6,
        x_dlp_master_prom_note_flag,
        x_mode,
        x_subsidized_loan_limit_type,
        x_combined_loan_limit_type,
        x_transaction_num_txt
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_nslds_id,
      x_isir_id,
      x_base_id,
      x_nslds_transaction_num,
      x_nslds_database_results_f,
      x_nslds_f,
      x_nslds_pell_overpay_f,
      x_nslds_pell_overpay_contact,
      x_nslds_seog_overpay_f,
      x_nslds_seog_overpay_contact,
      x_nslds_perkins_overpay_f,
      x_nslds_perkins_overpay_cntct,
      x_nslds_defaulted_loan_f,
      x_nslds_dischged_loan_chng_f,
      x_nslds_satis_repay_f,
      x_nslds_act_bankruptcy_f,
      x_nslds_agg_subsz_out_prin_bal,
      x_nslds_agg_unsbz_out_prin_bal,
      x_nslds_agg_comb_out_prin_bal,
      x_nslds_agg_cons_out_prin_bal,
      x_nslds_agg_subsz_pend_dismt,
      x_nslds_agg_unsbz_pend_dismt,
      x_nslds_agg_comb_pend_dismt,
      x_nslds_agg_subsz_total,
      x_nslds_agg_unsbz_total,
      x_nslds_agg_comb_total,
      x_nslds_agg_consd_total,
      x_nslds_perkins_out_bal,
      x_nslds_perkins_cur_yr_dismnt,
      x_nslds_default_loan_chng_f,
      x_nslds_discharged_loan_f,
      x_nslds_satis_repay_chng_f,
      x_nslds_act_bnkrupt_chng_f,
      x_nslds_overpay_chng_f,
      x_nslds_agg_loan_chng_f,
      x_nslds_perkins_loan_chng_f,
      x_nslds_pell_paymnt_chng_f,
      x_nslds_addtnl_pell_f,
      x_nslds_addtnl_loan_f,
      x_direct_loan_mas_prom_nt_f,
      x_nslds_pell_seq_num_1,
      x_nslds_pell_verify_f_1,
      x_nslds_pell_efc_1,
      x_nslds_pell_school_code_1,
      x_nslds_pell_transcn_num_1,
      x_nslds_pell_last_updt_dt_1,
      x_nslds_pell_scheduled_amt_1,
      x_nslds_pell_amt_paid_todt_1,
      x_nslds_pell_remng_amt_1,
      x_nslds_pell_pc_schd_awd_us_1,
      x_nslds_pell_award_amt_1,
      x_nslds_pell_seq_num_2,
      x_nslds_pell_verify_f_2,
      x_nslds_pell_efc_2,
      x_nslds_pell_school_code_2,
      x_nslds_pell_transcn_num_2,
      x_nslds_pell_last_updt_dt_2,
      x_nslds_pell_scheduled_amt_2,
      x_nslds_pell_amt_paid_todt_2,
      x_nslds_pell_remng_amt_2,
      x_nslds_pell_pc_schd_awd_us_2,
      x_nslds_pell_award_amt_2,
      x_nslds_pell_seq_num_3,
      x_nslds_pell_verify_f_3,
      x_nslds_pell_efc_3,
      x_nslds_pell_school_code_3,
      x_nslds_pell_transcn_num_3,
      x_nslds_pell_last_updt_dt_3,
      x_nslds_pell_scheduled_amt_3,
      x_nslds_pell_amt_paid_todt_3,
      x_nslds_pell_remng_amt_3,
      x_nslds_pell_pc_schd_awd_us_3,
      x_nslds_pell_award_amt_3,
      x_nslds_loan_seq_num_1,
      x_nslds_loan_type_code_1,
      x_nslds_loan_chng_f_1,
      x_nslds_loan_prog_code_1,
      x_nslds_loan_net_amnt_1,
      x_nslds_loan_cur_st_code_1,
      x_nslds_loan_cur_st_date_1,
      x_nslds_loan_agg_pr_bal_1,
      x_nslds_loan_out_pr_bal_dt_1,
      x_nslds_loan_begin_dt_1,
      x_nslds_loan_end_dt_1,
      x_nslds_loan_ga_code_1,
      x_nslds_loan_cont_type_1,
      x_nslds_loan_schol_code_1,
      x_nslds_loan_cont_code_1,
      x_nslds_loan_grade_lvl_1,
      x_nslds_loan_xtr_unsbz_ln_f_1,
      x_nslds_loan_capital_int_f_1,
      x_nslds_loan_seq_num_2,
      x_nslds_loan_type_code_2,
      x_nslds_loan_chng_f_2,
      x_nslds_loan_prog_code_2,
      x_nslds_loan_net_amnt_2,
      x_nslds_loan_cur_st_code_2,
      x_nslds_loan_cur_st_date_2,
      x_nslds_loan_agg_pr_bal_2,
      x_nslds_loan_out_pr_bal_dt_2,
      x_nslds_loan_begin_dt_2,
      x_nslds_loan_end_dt_2,
      x_nslds_loan_ga_code_2,
      x_nslds_loan_cont_type_2,
      x_nslds_loan_schol_code_2,
      x_nslds_loan_cont_code_2,
      x_nslds_loan_grade_lvl_2,
      x_nslds_loan_xtr_unsbz_ln_f_2,
      x_nslds_loan_capital_int_f_2,
      x_nslds_loan_seq_num_3,
      x_nslds_loan_type_code_3,
      x_nslds_loan_chng_f_3,
      x_nslds_loan_prog_code_3,
      x_nslds_loan_net_amnt_3,
      x_nslds_loan_cur_st_code_3,
      x_nslds_loan_cur_st_date_3,
      x_nslds_loan_agg_pr_bal_3,
      x_nslds_loan_out_pr_bal_dt_3,
      x_nslds_loan_begin_dt_3,
      x_nslds_loan_end_dt_3,
      x_nslds_loan_ga_code_3,
      x_nslds_loan_cont_type_3,
      x_nslds_loan_schol_code_3,
      x_nslds_loan_cont_code_3,
      x_nslds_loan_grade_lvl_3,
      x_nslds_loan_xtr_unsbz_ln_f_3,
      x_nslds_loan_capital_int_f_3,
      x_nslds_loan_seq_num_4,
      x_nslds_loan_type_code_4,
      x_nslds_loan_chng_f_4,
      x_nslds_loan_prog_code_4,
      x_nslds_loan_net_amnt_4,
      x_nslds_loan_cur_st_code_4,
      x_nslds_loan_cur_st_date_4,
      x_nslds_loan_agg_pr_bal_4,
      x_nslds_loan_out_pr_bal_dt_4,
      x_nslds_loan_begin_dt_4,
      x_nslds_loan_end_dt_4,
      x_nslds_loan_ga_code_4,
      x_nslds_loan_cont_type_4,
      x_nslds_loan_schol_code_4,
      x_nslds_loan_cont_code_4,
      x_nslds_loan_grade_lvl_4,
      x_nslds_loan_xtr_unsbz_ln_f_4,
      x_nslds_loan_capital_int_f_4,
      x_nslds_loan_seq_num_5,
      x_nslds_loan_type_code_5,
      x_nslds_loan_chng_f_5,
      x_nslds_loan_prog_code_5,
      x_nslds_loan_net_amnt_5,
      x_nslds_loan_cur_st_code_5,
      x_nslds_loan_cur_st_date_5,
      x_nslds_loan_agg_pr_bal_5,
      x_nslds_loan_out_pr_bal_dt_5,
      x_nslds_loan_begin_dt_5,
      x_nslds_loan_end_dt_5,
      x_nslds_loan_ga_code_5,
      x_nslds_loan_cont_type_5,
      x_nslds_loan_schol_code_5,
      x_nslds_loan_cont_code_5,
      x_nslds_loan_grade_lvl_5,
      x_nslds_loan_xtr_unsbz_ln_f_5,
      x_nslds_loan_capital_int_f_5,
      x_nslds_loan_seq_num_6,
      x_nslds_loan_type_code_6,
      x_nslds_loan_chng_f_6,
      x_nslds_loan_prog_code_6,
      x_nslds_loan_net_amnt_6,
      x_nslds_loan_cur_st_code_6,
      x_nslds_loan_cur_st_date_6,
      x_nslds_loan_agg_pr_bal_6,
      x_nslds_loan_out_pr_bal_dt_6,
      x_nslds_loan_begin_dt_6,
      x_nslds_loan_end_dt_6,
      x_nslds_loan_ga_code_6,
      x_nslds_loan_cont_type_6,
      x_nslds_loan_schol_code_6,
      x_nslds_loan_cont_code_6,
      x_nslds_loan_grade_lvl_6,
      x_nslds_loan_xtr_unsbz_ln_f_6,
      x_nslds_loan_capital_int_f_6,
      x_nslds_loan_last_d_amt_1,
      x_nslds_loan_last_d_date_1,
      x_nslds_loan_last_d_amt_2,
      x_nslds_loan_last_d_date_2,
      x_nslds_loan_last_d_amt_3,
      x_nslds_loan_last_d_date_3,
      x_nslds_loan_last_d_amt_4,
      x_nslds_loan_last_d_date_4,
      x_nslds_loan_last_d_amt_5,
      x_nslds_loan_last_d_date_5,
      x_nslds_loan_last_d_amt_6,
      x_nslds_loan_last_d_date_6,
      x_dlp_master_prom_note_flag,
      x_mode,
      x_subsidized_loan_limit_type,
      x_combined_loan_limit_type,
      x_transaction_num_txt
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rasingh
  ||  Created On : 06-DEC-2000
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igf_ap_nslds_data_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_nslds_data_pkg;

/
