--------------------------------------------------------
--  DDL for Package IGF_AW_AWD_DISB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_AWD_DISB_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI24S.pls 120.1 2006/08/07 08:10:53 veramach noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_trans_type                        IN     VARCHAR2,
    x_elig_status                       IN     VARCHAR2,
    x_elig_status_date                  IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_manual_hold_ind                   IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_late_disb_ind                     IN     VARCHAR2,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_fund_release_date                 IN     DATE,
    x_fund_status                       IN     VARCHAR2,
    x_fund_status_date                  IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_cheque_number                     IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_disb_paid_amt                     IN     NUMBER,
    x_rvsn_id                           IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_force_disb                        IN     VARCHAR2,
    x_min_credit_pts                    IN     NUMBER,
    x_disb_exp_dt                       IN     DATE,
    x_verf_enfr_dt                      IN     DATE,
    x_fee_class                         IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2  DEFAULT 'R',
    x_attendance_type_code              IN     VARCHAR2  DEFAULT NULL,
    x_base_attendance_type_code         IN     VARCHAR2  DEFAULT NULL,
    x_payment_prd_st_date               IN     DATE      DEFAULT NULL,
    x_change_type_code                  IN     VARCHAR2  DEFAULT NULL,
    x_fund_return_mthd_code             IN     VARCHAR2  DEFAULT NULL,
    x_called_from                       IN     VARCHAR2  DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2  DEFAULT NULL

  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_trans_type                        IN     VARCHAR2,
    x_elig_status                       IN     VARCHAR2,
    x_elig_status_date                  IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_manual_hold_ind                   IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_late_disb_ind                     IN     VARCHAR2,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_fund_release_date                 IN     DATE,
    x_fund_status                       IN     VARCHAR2,
    x_fund_status_date                  IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_cheque_number                     IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_disb_paid_amt                     IN     NUMBER,
    x_rvsn_id                           IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_force_disb                        IN     VARCHAR2,
    x_min_credit_pts                    IN     NUMBER,
    x_disb_exp_dt                       IN     DATE,
    x_verf_enfr_dt                      IN     DATE,
    x_fee_class                         IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_attendance_type_code              IN     VARCHAR2  DEFAULT NULL,
    x_base_attendance_type_code         IN     VARCHAR2  DEFAULT NULL,
    x_payment_prd_st_date               IN     DATE      DEFAULT NULL,
    x_change_type_code                  IN     VARCHAR2  DEFAULT NULL,
    x_fund_return_mthd_code             IN     VARCHAR2  DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2  DEFAULT NULL

  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_trans_type                        IN     VARCHAR2,
    x_elig_status                       IN     VARCHAR2,
    x_elig_status_date                  IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_manual_hold_ind                   IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_late_disb_ind                     IN     VARCHAR2,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_fund_release_date                 IN     DATE,
    x_fund_status                       IN     VARCHAR2,
    x_fund_status_date                  IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_cheque_number                     IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_disb_paid_amt                     IN     NUMBER,
    x_rvsn_id                           IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_force_disb                        IN     VARCHAR2,
    x_min_credit_pts                    IN     NUMBER,
    x_disb_exp_dt                       IN     DATE,
    x_verf_enfr_dt                      IN     DATE,
    x_fee_class                         IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2  DEFAULT 'R',
    x_attendance_type_code              IN     VARCHAR2  DEFAULT NULL,
    x_base_attendance_type_code         IN     VARCHAR2  DEFAULT NULL,
    x_payment_prd_st_date               IN     DATE      DEFAULT NULL,
    x_change_type_code                  IN     VARCHAR2  DEFAULT NULL,
    x_fund_return_mthd_code             IN     VARCHAR2  DEFAULT NULL,
    x_called_from                       IN     VARCHAR2  DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2  DEFAULT NULL

  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_trans_type                        IN     VARCHAR2,
    x_elig_status                       IN     VARCHAR2,
    x_elig_status_date                  IN     DATE,
    x_affirm_flag                       IN     VARCHAR2,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_manual_hold_ind                   IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_disb_status_date                  IN     DATE,
    x_late_disb_ind                     IN     VARCHAR2,
    x_fund_dist_mthd                    IN     VARCHAR2,
    x_prev_reported_ind                 IN     VARCHAR2,
    x_fund_release_date                 IN     DATE,
    x_fund_status                       IN     VARCHAR2,
    x_fund_status_date                  IN     DATE,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_cheque_number                     IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_disb_accepted_amt                 IN     NUMBER,
    x_disb_paid_amt                     IN     NUMBER,
    x_rvsn_id                           IN     NUMBER,
    x_int_rebate_amt                    IN     NUMBER,
    x_force_disb                        IN     VARCHAR2,
    x_min_credit_pts                    IN     NUMBER,
    x_disb_exp_dt                       IN     DATE,
    x_verf_enfr_dt                      IN     DATE,
    x_fee_class                         IN     VARCHAR2,
    x_show_on_bill                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2  DEFAULT 'R',
    x_attendance_type_code              IN     VARCHAR2  DEFAULT NULL,
    x_base_attendance_type_code         IN     VARCHAR2  DEFAULT NULL,
    x_payment_prd_st_date               IN     DATE      DEFAULT NULL,
    x_change_type_code                  IN     VARCHAR2  DEFAULT NULL,
    x_fund_return_mthd_code             IN     VARCHAR2  DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2  DEFAULT NULL

    );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
    x_called_from                       IN     VARCHAR2  DEFAULT NULL
  );

  FUNCTION get_pk_for_validation (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_award (
    x_award_id                          IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_awd_rvsn_rsn (
    x_rvsn_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igs_lookups_view (
    x_fee_class                          IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_tp_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_tp_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_fee_1                             IN     NUMBER      DEFAULT NULL,
    x_fee_2                             IN     NUMBER      DEFAULT NULL,
    x_disb_net_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_trans_type                        IN     VARCHAR2    DEFAULT NULL,
    x_elig_status                       IN     VARCHAR2    DEFAULT NULL,
    x_elig_status_date                  IN     DATE        DEFAULT NULL,
    x_affirm_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_manual_hold_ind                   IN     VARCHAR2    DEFAULT NULL,
    x_disb_status                       IN     VARCHAR2    DEFAULT NULL,
    x_disb_status_date                  IN     DATE        DEFAULT NULL,
    x_late_disb_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_fund_dist_mthd                    IN     VARCHAR2    DEFAULT NULL,
    x_prev_reported_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_fund_release_date                 IN     DATE        DEFAULT NULL,
    x_fund_status                       IN     VARCHAR2    DEFAULT NULL,
    x_fund_status_date                  IN     DATE        DEFAULT NULL,
    x_fee_paid_1                        IN     NUMBER      DEFAULT NULL,
    x_fee_paid_2                        IN     NUMBER      DEFAULT NULL,
    x_cheque_number                     IN     VARCHAR2    DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_disb_accepted_amt                 IN     NUMBER      DEFAULT NULL,
    x_disb_paid_amt                     IN     NUMBER      DEFAULT NULL,
    x_rvsn_id                           IN     NUMBER      DEFAULT NULL,
    x_int_rebate_amt                    IN     NUMBER      DEFAULT NULL,
    x_force_disb                        IN     VARCHAR2    DEFAULT NULL,
    x_min_credit_pts                    IN     NUMBER      DEFAULT NULL,
    x_disb_exp_dt                       IN     DATE        DEFAULT NULL,
    x_verf_enfr_dt                      IN     DATE        DEFAULT NULL,
    x_fee_class                         IN     VARCHAR2    DEFAULT NULL,
    x_show_on_bill                      IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type_code              IN     VARCHAR2    DEFAULT NULL,
    x_base_attendance_type_code         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_payment_prd_st_date               IN     DATE        DEFAULT NULL,
    x_change_type_code                  IN     VARCHAR2    DEFAULT NULL,
    x_fund_return_mthd_code             IN     VARCHAR2    DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2    DEFAULT NULL

  );

END igf_aw_awd_disb_pkg;

 

/
