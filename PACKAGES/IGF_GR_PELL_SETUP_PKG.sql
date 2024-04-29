--------------------------------------------------------
--  DDL for Package IGF_GR_PELL_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_PELL_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI02S.pls 120.1 2006/04/18 04:43:38 akomurav noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pell_seq_id                       IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_pell_profile                      IN     VARCHAR2  DEFAULT NULL,
    x_branch_campus                     IN     VARCHAR2,
    x_attend_campus_id                  IN     VARCHAR2,
    x_use_census_dts                    IN     VARCHAR2  DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2  DEFAULT NULL,
    x_academic_cal                      IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_alt_coa_limit                     IN     NUMBER,
    x_efc_max                           IN     NUMBER  DEFAULT NULL,
    x_pell_alt_exp_max                  IN     NUMBER  DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_course_cd                         IN     VARCHAR2   DEFAULT NULL,
    x_version_number                    IN     NUMBER     DEFAULT NULL,
    x_payment_periods_num               IN     NUMBER     DEFAULT NULL,
    x_enr_before_ts_code                IN     VARCHAR2   DEFAULT NULL,
    x_enr_in_mt_code                    IN     VARCHAR2   DEFAULT NULL,
    x_enr_after_tc_code                 IN     VARCHAR2   DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_response_option_code              IN     VARCHAR2   DEFAULT NULL,
    x_term_start_offset_num             IN     NUMBER     DEFAULT 0

  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_pell_seq_id                       IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_pell_profile                      IN     VARCHAR2  DEFAULT NULL,
    x_branch_campus                     IN     VARCHAR2,
    x_attend_campus_id                  IN     VARCHAR2,
    x_use_census_dts                    IN     VARCHAR2  DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2  DEFAULT NULL,
    x_academic_cal                      IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_alt_coa_limit                     IN     NUMBER,
    x_efc_max                           IN     NUMBER  DEFAULT NULL,
    x_pell_alt_exp_max                  IN     NUMBER  DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2   DEFAULT NULL,
    x_version_number                    IN     NUMBER     DEFAULT NULL,
    x_payment_periods_num               IN     NUMBER     DEFAULT NULL,
    x_enr_before_ts_code                IN     VARCHAR2   DEFAULT NULL,
    x_enr_in_mt_code                    IN     VARCHAR2   DEFAULT NULL,
    x_enr_after_tc_code                 IN     VARCHAR2   DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_response_option_code              IN     VARCHAR2   DEFAULT NULL,
    x_term_start_offset_num             IN     NUMBER     DEFAULT 0

  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_pell_seq_id                       IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_pell_profile                      IN     VARCHAR2  DEFAULT NULL,
    x_branch_campus                     IN     VARCHAR2,
    x_attend_campus_id                  IN     VARCHAR2,
    x_use_census_dts                    IN     VARCHAR2  DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2  DEFAULT NULL,
    x_academic_cal                      IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_alt_coa_limit                     IN     NUMBER,
    x_efc_max                           IN     NUMBER  DEFAULT NULL,
    x_pell_alt_exp_max                  IN     NUMBER  DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_course_cd                         IN     VARCHAR2   DEFAULT NULL,
    x_version_number                    IN     NUMBER     DEFAULT NULL,
    x_payment_periods_num               IN     NUMBER     DEFAULT NULL,
    x_enr_before_ts_code                IN     VARCHAR2   DEFAULT NULL,
    x_enr_in_mt_code                    IN     VARCHAR2   DEFAULT NULL,
    x_enr_after_tc_code                 IN     VARCHAR2   DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_response_option_code              IN     VARCHAR2   DEFAULT NULL,
    x_term_start_offset_num             IN     NUMBER     DEFAULT 0
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pell_seq_id                       IN OUT NOCOPY NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_pell_profile                      IN     VARCHAR2  DEFAULT NULL,
    x_branch_campus                     IN     VARCHAR2,
    x_attend_campus_id                  IN     VARCHAR2,
    x_use_census_dts                    IN     VARCHAR2  DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_low_tution_fee                    IN     VARCHAR2  DEFAULT NULL,
    x_academic_cal                      IN     VARCHAR2,
    x_payment_method                    IN     VARCHAR2,
    x_wk_inst_time_calc_pymt            IN     NUMBER,
    x_wk_int_time_prg_def_yr            IN     NUMBER,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER,
    x_cr_clk_hrs_acad_yr                IN     NUMBER,
    x_alt_coa_limit                     IN     NUMBER,
    x_efc_max                           IN     NUMBER  DEFAULT NULL,
    x_pell_alt_exp_max                  IN     NUMBER  DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_course_cd                         IN     VARCHAR2   DEFAULT NULL,
    x_version_number                    IN     NUMBER     DEFAULT NULL,
    x_payment_periods_num               IN     NUMBER     DEFAULT NULL,
    x_enr_before_ts_code                IN     VARCHAR2   DEFAULT NULL,
    x_enr_in_mt_code                    IN     VARCHAR2   DEFAULT NULL,
    x_enr_after_tc_code                 IN     VARCHAR2   DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2   DEFAULT NULL,
    x_response_option_code              IN     VARCHAR2   DEFAULT NULL,
    x_term_start_offset_num             IN     NUMBER     DEFAULT 0
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_pell_seq_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk2_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_rep_entity_id_txt                 IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE get_fk_igf_gr_report_pell (
    x_rep_pell_cd                       IN     VARCHAR2
  );

  PROCEDURE get_fk_igf_gr_report_ent (
    x_rep_entity_id_txt                 IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_pell_seq_id                       IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_rep_pell_id                       IN     VARCHAR2    DEFAULT NULL,
    x_pell_profile                      IN     VARCHAR2    DEFAULT NULL,
    x_branch_campus                     IN     VARCHAR2    DEFAULT NULL,
    x_attend_campus_id                  IN     VARCHAR2    DEFAULT NULL,
    x_use_census_dts                    IN     VARCHAR2    DEFAULT NULL,
    x_funding_method                    IN     VARCHAR2    DEFAULT NULL,
    x_inst_cross_ref_code               IN     VARCHAR2    DEFAULT NULL,
    x_low_tution_fee                    IN     VARCHAR2    DEFAULT NULL,
    x_academic_cal                      IN     VARCHAR2    DEFAULT NULL,
    x_payment_method                    IN     VARCHAR2    DEFAULT NULL,
    x_wk_inst_time_calc_pymt            IN     NUMBER      DEFAULT NULL,
    x_wk_int_time_prg_def_yr            IN     NUMBER      DEFAULT NULL,
    x_cr_clk_hrs_prds_sch_yr            IN     NUMBER      DEFAULT NULL,
    x_cr_clk_hrs_acad_yr                IN     NUMBER      DEFAULT NULL,
    x_alt_coa_limit                     IN     NUMBER      DEFAULT NULL,
    x_efc_max                           IN     NUMBER      DEFAULT NULL,
    x_pell_alt_exp_max                  IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_payment_periods_num               IN     NUMBER      DEFAULT NULL,
    x_enr_before_ts_code                IN     VARCHAR2    DEFAULT NULL,
    x_enr_in_mt_code                    IN     VARCHAR2    DEFAULT NULL,
    x_enr_after_tc_code                 IN     VARCHAR2    DEFAULT NULL,
    x_rep_entity_id_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_response_option_code              IN     VARCHAR2    DEFAULT NULL,
    x_term_start_offset_num             IN     NUMBER     DEFAULT 0

    );

END igf_gr_pell_setup_pkg;

 

/
