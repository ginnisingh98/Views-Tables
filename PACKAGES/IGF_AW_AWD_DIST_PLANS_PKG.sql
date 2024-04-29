--------------------------------------------------------
--  DDL for Package IGF_AW_AWD_DIST_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_AWD_DIST_PLANS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI59S.pls 115.1 2003/11/21 06:38:52 veramach noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adplans_id                        IN OUT NOCOPY NUMBER,
    x_awd_dist_plan_cd                  IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_dist_plan_method_code             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_awd_dist_plan_cd                  IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_dist_plan_method_code             IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_awd_dist_plan_cd                  IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_dist_plan_method_code             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_adplans_id                        IN OUT NOCOPY NUMBER,
    x_awd_dist_plan_cd                  IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2,
    x_active_flag                       IN     VARCHAR2,
    x_dist_plan_method_code             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  FUNCTION get_pk_for_validation (
    x_adplans_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation(
                                  x_awd_dist_plan_cd  IN VARCHAR2,
                                  x_cal_type          IN VARCHAR2,
                                  x_sequence_number   IN NUMBER
                                ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_awd_dist_plan_cd                  IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_sequence_number                   IN     NUMBER      DEFAULT NULL,
    x_awd_dist_plan_cd_desc             IN     VARCHAR2    DEFAULT NULL,
    x_active_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_dist_plan_method_code             IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_awd_dist_plans_pkg;

 

/
