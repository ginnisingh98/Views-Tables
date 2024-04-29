--------------------------------------------------------
--  DDL for Package IGF_AP_FA_ANT_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_FA_ANT_DATA_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI76S.pls 120.0 2005/06/01 15:36:48 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_months_enrolled_num               IN     NUMBER,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_months_enrolled_num               IN     NUMBER,
    x_credit_points_num                 IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_months_enrolled_num               IN     NUMBER,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_program_type                      IN     VARCHAR2,
    x_program_location_cd               IN     VARCHAR2,
    x_program_cd                        IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_residency_status_code             IN     VARCHAR2,
    x_housing_status_code               IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_months_enrolled_num               IN     NUMBER,
    x_credit_points_num                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_program_type                      IN     VARCHAR2    DEFAULT NULL,
    x_program_location_cd               IN     VARCHAR2    DEFAULT NULL,
    x_program_cd                        IN     VARCHAR2    DEFAULT NULL,
    x_class_standing                    IN     VARCHAR2    DEFAULT NULL,
    x_residency_status_code             IN     VARCHAR2    DEFAULT NULL,
    x_housing_status_code               IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type                   IN     VARCHAR2    DEFAULT NULL,
    x_attendance_mode                   IN     VARCHAR2    DEFAULT NULL,
    x_months_enrolled_num               IN     NUMBER      DEFAULT NULL,
    x_credit_points_num                 IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_fa_ant_data_pkg;

 

/
