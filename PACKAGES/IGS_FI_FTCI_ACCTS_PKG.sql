--------------------------------------------------------
--  DDL for Package IGS_FI_FTCI_ACCTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_FTCI_ACCTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSID0S.pls 120.2 2005/07/05 02:48:44 appldev ship $ */

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acct_id                           IN OUT NOCOPY NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_natural_account_segment           IN     VARCHAR2,
    x_rev_account_cd                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_version_number               IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_residency_status_cd               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_unit_level                        IN     VARCHAR2    DEFAULT NULL,
    x_unit_type_id                      IN     NUMBER      DEFAULT NULL,
    x_unit_mode                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_class                        IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_acct_id                           IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_order_sequence                    IN     NUMBER      DEFAULT NULL,
    x_natural_account_segment           IN     VARCHAR2    DEFAULT NULL,
    x_rev_account_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type                   IN     VARCHAR2    DEFAULT NULL,
    x_attendance_mode                   IN     VARCHAR2    DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_crs_version_number                IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_unit_version_number               IN     NUMBER      DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_residency_status_cd               IN     VARCHAR2    DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_unit_level                        IN     VARCHAR2    DEFAULT NULL,
    x_unit_type_id                      IN     NUMBER      DEFAULT NULL,
    x_unit_mode                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_class                        IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row ( x_rowid        IN     VARCHAR2);

  PROCEDURE get_fk_igs_ad_location (
    x_location_cd                       IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_en_atd_mode (
    x_attendance_mode                   IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_en_atd_type (
    x_attendance_type                   IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_fi_acc (
    x_account_cd                        IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_fi_f_typ_ca_inst (
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER
  );

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_unit_ver (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE get_fk_igs_as_unit_mode (
    x_unit_mode                         IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (x_acct_id  IN     NUMBER) RETURN BOOLEAN;

  FUNCTION get_uk1_for_validation (
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk2_for_validation (
    x_fee_type                IN     VARCHAR2,
    x_fee_cal_type            IN     VARCHAR2,
    x_fee_ci_sequence_number  IN     NUMBER,
    x_location_cd             IN     VARCHAR2,
    x_attendance_type         IN     VARCHAR2,
    x_attendance_mode         IN     VARCHAR2,
    x_course_cd               IN     VARCHAR2,
    x_crs_version_number      IN     NUMBER,
    x_unit_cd                 IN     VARCHAR2,
    x_unit_version_number     IN     NUMBER,
    x_org_unit_cd             IN     VARCHAR2,
    x_residency_status_cd     IN     VARCHAR2,
    x_uoo_id                  IN     NUMBER,
    x_unit_level              IN     VARCHAR2   DEFAULT NULL,
    x_unit_type_id            IN     NUMBER     DEFAULT NULL,
    x_unit_mode               IN     VARCHAR2   DEFAULT NULL,
    x_unit_class              IN     VARCHAR2   DEFAULT NULL
  )RETURN BOOLEAN;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acct_id                           IN OUT NOCOPY NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_natural_account_segment           IN     VARCHAR2,
    x_rev_account_cd                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_version_number               IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_residency_status_cd               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_unit_level                        IN     VARCHAR2    DEFAULT NULL,
    x_unit_type_id                      IN     NUMBER      DEFAULT NULL,
    x_unit_mode                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_class                        IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_acct_id                           IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_natural_account_segment           IN     VARCHAR2,
    x_rev_account_cd                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_version_number               IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_residency_status_cd               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_level                        IN     VARCHAR2   DEFAULT NULL,
    x_unit_type_id                      IN     NUMBER     DEFAULT NULL,
    x_unit_mode                         IN     VARCHAR2   DEFAULT NULL,
    x_unit_class                        IN     VARCHAR2   DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_acct_id                           IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_natural_account_segment           IN     VARCHAR2,
    x_rev_account_cd                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_attendance_mode                   IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_unit_version_number               IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_residency_status_cd               IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_unit_level                        IN     VARCHAR2    DEFAULT NULL,
    x_unit_type_id                      IN     NUMBER      DEFAULT NULL,
    x_unit_mode                         IN     VARCHAR2    DEFAULT NULL,
    x_unit_class                        IN     VARCHAR2    DEFAULT NULL
  );

END igs_fi_ftci_accts_pkg;

 

/
