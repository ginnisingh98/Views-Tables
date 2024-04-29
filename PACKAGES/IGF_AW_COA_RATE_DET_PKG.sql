--------------------------------------------------------
--  DDL for Package IGF_AW_COA_RATE_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_COA_RATE_DET_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI70S.pls 120.0 2005/06/02 15:44:07 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER,
    x_pid_group_cd                      IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mult_factor_code                  IN     VARCHAR2,
    x_mult_amount_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER,
    x_pid_group_cd                      IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mult_factor_code                  IN     VARCHAR2,
    x_mult_amount_num                   IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER,
    x_pid_group_cd                      IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mult_factor_code                  IN     VARCHAR2,
    x_mult_amount_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER,
    x_pid_group_cd                      IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mult_factor_code                  IN     VARCHAR2,
    x_mult_amount_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_item_code                         IN     VARCHAR2    DEFAULT NULL,
    x_rate_order_num                    IN     NUMBER      DEFAULT NULL,
    x_pid_group_cd                      IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_program_type                      IN     VARCHAR2    DEFAULT NULL,
    x_program_location_cd               IN     VARCHAR2    DEFAULT NULL,
    x_program_cd                        IN     VARCHAR2    DEFAULT NULL,
    x_class_standing                    IN     VARCHAR2    DEFAULT NULL,
    x_residency_status_code             IN     VARCHAR2    DEFAULT NULL,
    x_housing_status_code               IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type                   IN     VARCHAR2    DEFAULT NULL,
    x_attendance_mode                   IN     VARCHAR2    DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_mult_factor_code                  IN     VARCHAR2    DEFAULT NULL,
    x_mult_amount_num                   IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  FUNCTION get_pk_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_rate_order_num                    IN     NUMBER
  ) RETURN BOOLEAN;

END igf_aw_coa_rate_det_pkg;

 

/
