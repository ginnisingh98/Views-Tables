--------------------------------------------------------
--  DDL for Package IGF_AW_AWD_FRML_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_AWD_FRML_DET_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI13S.pls 120.0 2005/06/01 14:04:47 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_seq_no                            IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_replace_fc                        IN     VARCHAR2,
    x_pe_group_id                       IN     NUMBER      DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_seq_no                            IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_replace_fc                        IN     VARCHAR2,
    x_pe_group_id                       IN     NUMBER      DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_seq_no                            IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_replace_fc                        IN     VARCHAR2,
    x_pe_group_id                       IN     NUMBER      DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_seq_no                            IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_min_award_amt                     IN     NUMBER,
    x_max_award_amt                     IN     NUMBER,
    x_replace_fc                        IN     VARCHAR2,
    x_pe_group_id                       IN     NUMBER      DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_seq_no                            IN     NUMBER
  ) RETURN BOOLEAN;

   PROCEDURE get_ufk_igf_aw_target_grp (
    x_formula_code                      IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
    );

  PROCEDURE get_fk_igf_aw_fund_mast (
    x_fund_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_awd_dist_plans(
                                         x_adplans_id IN NUMBER
                                        );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_formula_code                      IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_seq_no                            IN     NUMBER      DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_min_award_amt                     IN     NUMBER      DEFAULT NULL,
    x_max_award_amt                     IN     NUMBER      DEFAULT NULL,
    x_replace_fc                        IN     VARCHAR2    DEFAULT NULL,
    x_pe_group_id                       IN     NUMBER      DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_awd_frml_det_pkg;

 

/
