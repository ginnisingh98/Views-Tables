--------------------------------------------------------
--  DDL for Package IGF_GR_YTD_DISB_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_YTD_DISB_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI14S.pls 120.1 2006/04/06 06:09:21 veramach noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ytdds_id                          IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_accpt_amt                    IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_pymt_prd_start_dt                 IN     DATE,
    x_disb_batch_id                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
 	  x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
 	  x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
 	  x_student_name                      IN     VARCHAR2    DEFAULT NULL,
 	  x_current_ssn_txt                   IN     VARCHAR2    DEFAULT NULL,
 	  x_student_birth_date                IN     DATE        DEFAULT NULL,
 	  x_disb_process_date                 IN     DATE        DEFAULT NULL,
 	  x_routing_id_txt                    IN     VARCHAR2    DEFAULT NULL,
 	  x_fin_award_year_num                IN     NUMBER      DEFAULT NULL,
 	  x_attend_entity_id_txt              IN     VARCHAR2    DEFAULT NULL,
 	  x_disb_seq_num                      IN     NUMBER      DEFAULT NULL,
 	  x_disb_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
 	  x_prev_disb_seq_num                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ytdds_id                          IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_accpt_amt                    IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_pymt_prd_start_dt                 IN     DATE,
    x_disb_batch_id                     IN     VARCHAR2,
 	  x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
 	  x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
 	  x_student_name                      IN     VARCHAR2    DEFAULT NULL,
 	  x_current_ssn_txt                   IN     VARCHAR2    DEFAULT NULL,
 	  x_student_birth_date                IN     DATE        DEFAULT NULL,
 	  x_disb_process_date                 IN     DATE        DEFAULT NULL,
 	  x_routing_id_txt                    IN     VARCHAR2    DEFAULT NULL,
 	  x_fin_award_year_num                IN     NUMBER      DEFAULT NULL,
 	  x_attend_entity_id_txt              IN     VARCHAR2    DEFAULT NULL,
 	  x_disb_seq_num                      IN     NUMBER      DEFAULT NULL,
 	  x_disb_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
 	  x_prev_disb_seq_num                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ytdds_id                          IN     NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_accpt_amt                    IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_pymt_prd_start_dt                 IN     DATE,
    x_disb_batch_id                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
	  x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
 	  x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
 	  x_student_name                      IN     VARCHAR2    DEFAULT NULL,
 	  x_current_ssn_txt                   IN     VARCHAR2    DEFAULT NULL,
 	  x_student_birth_date                IN     DATE        DEFAULT NULL,
 	  x_disb_process_date                 IN     DATE        DEFAULT NULL,
 	  x_routing_id_txt                    IN     VARCHAR2    DEFAULT NULL,
 	  x_fin_award_year_num                IN     NUMBER      DEFAULT NULL,
 	  x_attend_entity_id_txt              IN     VARCHAR2    DEFAULT NULL,
 	  x_disb_seq_num                      IN     NUMBER      DEFAULT NULL,
 	  x_disb_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
 	  x_prev_disb_seq_num                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ytdds_id                          IN OUT NOCOPY NUMBER,
    x_origination_id                    IN     VARCHAR2,
    x_inst_cross_ref_code               IN     VARCHAR2,
    x_action_code                       IN     VARCHAR2,
    x_disb_ref_num                      IN     VARCHAR2,
    x_disb_accpt_amt                    IN     NUMBER,
    x_db_cr_flag                        IN     VARCHAR2,
    x_disb_dt                           IN     DATE,
    x_pymt_prd_start_dt                 IN     DATE,
    x_disb_batch_id                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
 	  x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
 	  x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
 	  x_student_name                      IN     VARCHAR2    DEFAULT NULL,
 	  x_current_ssn_txt                   IN     VARCHAR2    DEFAULT NULL,
 	  x_student_birth_date                IN     DATE        DEFAULT NULL,
 	  x_disb_process_date                 IN     DATE        DEFAULT NULL,
 	  x_routing_id_txt                    IN     VARCHAR2    DEFAULT NULL,
 	  x_fin_award_year_num                IN     NUMBER      DEFAULT NULL,
 	  x_attend_entity_id_txt              IN     VARCHAR2    DEFAULT NULL,
 	  x_disb_seq_num                      IN     NUMBER      DEFAULT NULL,
 	  x_disb_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
 	  x_prev_disb_seq_num                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ytdds_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ytdds_id                          IN     NUMBER      DEFAULT NULL,
    x_origination_id                    IN     VARCHAR2    DEFAULT NULL,
    x_inst_cross_ref_code               IN     VARCHAR2    DEFAULT NULL,
    x_action_code                       IN     VARCHAR2    DEFAULT NULL,
    x_disb_ref_num                      IN     VARCHAR2    DEFAULT NULL,
    x_disb_accpt_amt                    IN     NUMBER      DEFAULT NULL,
    x_db_cr_flag                        IN     VARCHAR2    DEFAULT NULL,
    x_disb_dt                           IN     DATE        DEFAULT NULL,
    x_pymt_prd_start_dt                 IN     DATE        DEFAULT NULL,
    x_disb_batch_id                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
 	  x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
 	  x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
 	  x_student_name                      IN     VARCHAR2    DEFAULT NULL,
 	  x_current_ssn_txt                   IN     VARCHAR2    DEFAULT NULL,
 	  x_student_birth_date                IN     DATE        DEFAULT NULL,
 	  x_disb_process_date                 IN     DATE        DEFAULT NULL,
 	  x_routing_id_txt                    IN     VARCHAR2    DEFAULT NULL,
 	  x_fin_award_year_num                IN     NUMBER      DEFAULT NULL,
 	  x_attend_entity_id_txt              IN     VARCHAR2    DEFAULT NULL,
 	  x_disb_seq_num                      IN     NUMBER      DEFAULT NULL,
 	  x_disb_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
 	  x_prev_disb_seq_num                 IN     NUMBER      DEFAULT NULL
  );

END igf_gr_ytd_disb_pkg;

 

/
