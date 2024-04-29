--------------------------------------------------------
--  DDL for Package IGF_AW_TARGET_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_TARGET_GRP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI07S.pls 115.14 2003/11/10 12:33:54 veramach ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_cd                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_max_grant_amt                     IN     NUMBER,
    x_max_grant_perct                   IN     NUMBER,
    x_max_grant_perct_fact              IN     VARCHAR2,
    x_max_loan_amt                      IN     NUMBER,
    x_max_loan_perct                    IN     NUMBER,
    x_max_loan_perct_fact               IN     VARCHAR2,
    x_max_work_amt                      IN     NUMBER,
    x_max_work_perct                    IN     NUMBER,
    x_max_work_perct_fact               IN     VARCHAR2,
    x_max_shelp_amt                     IN     NUMBER,
    x_max_shelp_perct                   IN     NUMBER,
    x_max_shelp_perct_fact              IN     VARCHAR2,
    x_max_gap_amt                       IN     NUMBER,
    x_max_gap_perct                     IN     NUMBER,
    x_max_gap_perct_fact                IN     VARCHAR2,
    x_use_fixed_costs                   IN     VARCHAR2,
    x_max_aid_pkg                       IN     NUMBER,
    x_max_gift_amt                      IN     NUMBER   DEFAULT NULL,
    x_max_gift_perct                    IN     NUMBER   DEFAULT NULL,
    x_max_gift_perct_fact               IN     VARCHAR2 DEFAULT NULL,
    x_max_schlrshp_amt                  IN     NUMBER   DEFAULT NULL,
    x_max_schlrshp_perct                IN     NUMBER   DEFAULT NULL,
    x_max_schlrshp_perct_fact           IN     VARCHAR2 DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2 DEFAULT NULL,
    x_sequence_number                   IN     NUMBER   DEFAULT NULL,
    x_rule_order                        IN     NUMBER      DEFAULT NULL,
    x_s_rule_call_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_rul_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_active                            IN     VARCHAR2,
    x_tgrp_id                           IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_adplans_id                        IN     NUMBER  DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_group_cd                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_max_grant_amt                     IN     NUMBER,
    x_max_grant_perct                   IN     NUMBER,
    x_max_grant_perct_fact              IN     VARCHAR2,
    x_max_loan_amt                      IN     NUMBER,
    x_max_loan_perct                    IN     NUMBER,
    x_max_loan_perct_fact               IN     VARCHAR2,
    x_max_work_amt                      IN     NUMBER,
    x_max_work_perct                    IN     NUMBER,
    x_max_work_perct_fact               IN     VARCHAR2,
    x_max_shelp_amt                     IN     NUMBER,
    x_max_shelp_perct                   IN     NUMBER,
    x_max_shelp_perct_fact              IN     VARCHAR2,
    x_max_gap_amt                       IN     NUMBER,
    x_max_gap_perct                     IN     NUMBER,
    x_max_gap_perct_fact                IN     VARCHAR2,
    x_use_fixed_costs                   IN     VARCHAR2,
    x_max_aid_pkg                       IN     NUMBER,
    x_max_gift_amt                      IN     NUMBER   DEFAULT NULL,
    x_max_gift_perct                    IN     NUMBER   DEFAULT NULL,
    x_max_gift_perct_fact               IN     VARCHAR2 DEFAULT NULL,
    x_max_schlrshp_amt                  IN     NUMBER   DEFAULT NULL,
    x_max_schlrshp_perct                IN     NUMBER   DEFAULT NULL,
    x_max_schlrshp_perct_fact           IN     VARCHAR2 DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2 DEFAULT NULL,
    x_sequence_number                   IN     NUMBER   DEFAULT NULL,
    x_rule_order                        IN     NUMBER      DEFAULT NULL,
    x_s_rule_call_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_rul_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_active                            IN     VARCHAR2,
    x_tgrp_id                           IN     NUMBER,
    x_adplans_id                        IN     NUMBER  DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_group_cd                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_max_grant_amt                     IN     NUMBER,
    x_max_grant_perct                   IN     NUMBER,
    x_max_grant_perct_fact              IN     VARCHAR2,
    x_max_loan_amt                      IN     NUMBER,
    x_max_loan_perct                    IN     NUMBER,
    x_max_loan_perct_fact               IN     VARCHAR2,
    x_max_work_amt                      IN     NUMBER,
    x_max_work_perct                    IN     NUMBER,
    x_max_work_perct_fact               IN     VARCHAR2,
    x_max_shelp_amt                     IN     NUMBER,
    x_max_shelp_perct                   IN     NUMBER,
    x_max_shelp_perct_fact              IN     VARCHAR2,
    x_max_gap_amt                       IN     NUMBER,
    x_max_gap_perct                     IN     NUMBER,
    x_max_gap_perct_fact                IN     VARCHAR2,
    x_use_fixed_costs                   IN     VARCHAR2,
    x_max_aid_pkg                       IN     NUMBER,
    x_max_gift_amt                      IN     NUMBER   DEFAULT NULL,
    x_max_gift_perct                    IN     NUMBER   DEFAULT NULL,
    x_max_gift_perct_fact               IN     VARCHAR2 DEFAULT NULL,
    x_max_schlrshp_amt                  IN     NUMBER   DEFAULT NULL,
    x_max_schlrshp_perct                IN     NUMBER   DEFAULT NULL,
    x_max_schlrshp_perct_fact           IN     VARCHAR2 DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2 DEFAULT NULL,
    x_sequence_number                   IN     NUMBER DEFAULT NULL,
    x_rule_order                        IN     NUMBER      DEFAULT NULL,
    x_s_rule_call_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_rul_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_active                            IN     VARCHAR2,
    x_tgrp_id                           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_adplans_id                        IN     NUMBER  DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_group_cd                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_max_grant_amt                     IN     NUMBER,
    x_max_grant_perct                   IN     NUMBER,
    x_max_grant_perct_fact              IN     VARCHAR2,
    x_max_loan_amt                      IN     NUMBER,
    x_max_loan_perct                    IN     NUMBER,
    x_max_loan_perct_fact               IN     VARCHAR2,
    x_max_work_amt                      IN     NUMBER,
    x_max_work_perct                    IN     NUMBER,
    x_max_work_perct_fact               IN     VARCHAR2,
    x_max_shelp_amt                     IN     NUMBER,
    x_max_shelp_perct                   IN     NUMBER,
    x_max_shelp_perct_fact              IN     VARCHAR2,
    x_max_gap_amt                       IN     NUMBER,
    x_max_gap_perct                     IN     NUMBER,
    x_max_gap_perct_fact                IN     VARCHAR2,
    x_use_fixed_costs                   IN     VARCHAR2,
    x_max_aid_pkg                       IN     NUMBER,
    x_max_gift_amt                      IN     NUMBER   DEFAULT NULL,
    x_max_gift_perct                    IN     NUMBER   DEFAULT NULL,
    x_max_gift_perct_fact               IN     VARCHAR2 DEFAULT NULL,
    x_max_schlrshp_amt                  IN     NUMBER   DEFAULT NULL,
    x_max_schlrshp_perct                IN     NUMBER   DEFAULT NULL,
    x_max_schlrshp_perct_fact           IN     VARCHAR2 DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2 DEFAULT NULL,
    x_sequence_number                   IN     NUMBER   DEFAULT NULL,
    x_rule_order                        IN     NUMBER      DEFAULT NULL,
    x_s_rule_call_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_rul_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_active                            IN     VARCHAR2,
    x_tgrp_id                           IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_adplans_id                        IN     NUMBER  DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tgrp_id                           IN     NUMBER
  ) RETURN BOOLEAN;



  FUNCTION get_uk_for_validation (
    x_group_cd                          IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_org_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_awd_dist_plans(
                                         x_adplans_id IN NUMBER
                                        );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_group_cd                          IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_max_grant_amt                     IN     NUMBER      DEFAULT NULL,
    x_max_grant_perct                   IN     NUMBER      DEFAULT NULL,
    x_max_grant_perct_fact              IN     VARCHAR2    DEFAULT NULL,
    x_max_loan_amt                      IN     NUMBER      DEFAULT NULL,
    x_max_loan_perct                    IN     NUMBER      DEFAULT NULL,
    x_max_loan_perct_fact               IN     VARCHAR2    DEFAULT NULL,
    x_max_work_amt                      IN     NUMBER      DEFAULT NULL,
    x_max_work_perct                    IN     NUMBER      DEFAULT NULL,
    x_max_work_perct_fact               IN     VARCHAR2    DEFAULT NULL,
    x_max_shelp_amt                     IN     NUMBER      DEFAULT NULL,
    x_max_shelp_perct                   IN     NUMBER      DEFAULT NULL,
    x_max_shelp_perct_fact              IN     VARCHAR2    DEFAULT NULL,
    x_max_gap_amt                       IN     NUMBER      DEFAULT NULL,
    x_max_gap_perct                     IN     NUMBER      DEFAULT NULL,
    x_max_gap_perct_fact                IN     VARCHAR2    DEFAULT NULL,
    x_use_fixed_costs                   IN     VARCHAR2    DEFAULT NULL,
    x_max_aid_pkg                       IN     NUMBER      DEFAULT NULL,
    x_max_gift_amt                      IN     NUMBER      DEFAULT NULL,
    x_max_gift_perct                    IN     NUMBER      DEFAULT NULL,
    x_max_gift_perct_fact               IN     VARCHAR2    DEFAULT NULL,
    x_max_schlrshp_amt                  IN     NUMBER      DEFAULT NULL,
    x_max_schlrshp_perct                IN     NUMBER      DEFAULT NULL,
    x_max_schlrshp_perct_fact           IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2 DEFAULT NULL,
    x_sequence_number                   IN     NUMBER   DEFAULT NULL,
    x_rule_order                        IN     NUMBER      DEFAULT NULL,
    x_s_rule_call_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_rul_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_active                            IN     VARCHAR2    DEFAULT NULL,
    x_tgrp_id                           IN     NUMBER      DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_target_grp_pkg;

 

/
