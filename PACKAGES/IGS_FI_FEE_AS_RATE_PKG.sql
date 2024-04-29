--------------------------------------------------------
--  DDL for Package IGS_FI_FEE_AS_RATE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_FEE_AS_RATE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI68S.pls 120.1 2005/06/05 20:10:14 appldev  $*/

PROCEDURE insert_row (
  x_rowid                       IN OUT NOCOPY VARCHAR2,
  x_far_id                      IN OUT NOCOPY NUMBER,
  x_fee_type                    IN VARCHAR2,
  x_fee_cal_type                IN VARCHAR2,
  x_fee_ci_sequence_number      IN NUMBER,
  x_s_relation_type             IN VARCHAR2,
  x_rate_number                 IN NUMBER,
  x_fee_cat                     IN VARCHAR2,
  x_location_cd                 IN VARCHAR2,
  x_attendance_type             IN VARCHAR2,
  x_attendance_mode             IN VARCHAR2,
  x_order_of_precedence         IN NUMBER,
  x_govt_hecs_payment_option    IN VARCHAR2,
  x_govt_hecs_cntrbtn_band      IN NUMBER,
  x_chg_rate                    IN NUMBER,
  x_logical_delete_dt           IN DATE,
  x_residency_status_cd         IN VARCHAR2 DEFAULT NULL,
  x_course_cd                   IN VARCHAR2 DEFAULT NULL,
  x_version_number              IN NUMBER   DEFAULT NULL,
  x_org_party_id                IN NUMBER   DEFAULT NULL,
  x_class_standing              IN VARCHAR2 DEFAULT NULL,
  x_mode                        IN VARCHAR2 DEFAULT 'R',
  x_unit_set_cd                 IN VARCHAR2 DEFAULT NULL,
  x_us_version_number           IN NUMBER   DEFAULT NULL,
  x_unit_cd                     IN VARCHAR2 DEFAULT NULL,
  x_unit_version_number         IN NUMBER   DEFAULT NULL,
  x_unit_level                  IN VARCHAR2 DEFAULT NULL,
  x_unit_type_id                IN NUMBER   DEFAULT NULL,
  x_unit_class                  IN VARCHAR2 DEFAULT NULL,
  x_unit_mode                   IN VARCHAR2 DEFAULT NULL

  );

PROCEDURE lock_row (
  x_rowid                       IN VARCHAR2,
  x_far_id                      IN NUMBER,
  x_fee_type                    IN VARCHAR2,
  x_fee_cal_type                IN VARCHAR2,
  x_fee_ci_sequence_number      IN NUMBER,
  x_s_relation_type             IN VARCHAR2,
  x_rate_number                 IN NUMBER,
  x_fee_cat                     IN VARCHAR2,
  x_location_cd                 IN VARCHAR2,
  x_attendance_type             IN VARCHAR2,
  x_attendance_mode             IN VARCHAR2,
  x_order_of_precedence         IN NUMBER,
  x_govt_hecs_payment_option    IN VARCHAR2,
  x_govt_hecs_cntrbtn_band      IN NUMBER,
  x_chg_rate                    IN NUMBER,
  x_logical_delete_dt           IN DATE,
  x_residency_status_cd         IN VARCHAR2 DEFAULT NULL,
  x_course_cd                   IN VARCHAR2 DEFAULT NULL,
  x_version_number              IN NUMBER   DEFAULT NULL,
  x_org_party_id                IN NUMBER   DEFAULT NULL,
  x_class_standing              IN VARCHAR2 DEFAULT NULL,
  x_unit_set_cd                 IN VARCHAR2 DEFAULT NULL,
  x_us_version_number           IN NUMBER   DEFAULT NULL,
  x_unit_cd                     IN VARCHAR2 DEFAULT NULL,
  x_unit_version_number         IN NUMBER   DEFAULT NULL,
  x_unit_level                  IN VARCHAR2 DEFAULT NULL,
  x_unit_type_id                IN NUMBER   DEFAULT NULL,
  x_unit_class                  IN VARCHAR2 DEFAULT NULL,
  x_unit_mode                   IN VARCHAR2 DEFAULT NULL

);

PROCEDURE update_row(
  x_rowid                       IN VARCHAR2,
  x_far_id                      IN NUMBER,
  x_fee_type                    IN VARCHAR2,
  x_fee_cal_type                IN VARCHAR2,
  x_fee_ci_sequence_number      IN NUMBER,
  x_s_relation_type             IN VARCHAR2,
  x_rate_number                 IN NUMBER,
  x_fee_cat                     IN VARCHAR2,
  x_location_cd                 IN VARCHAR2,
  x_attendance_type             IN VARCHAR2,
  x_attendance_mode             IN VARCHAR2,
  x_order_of_precedence         IN NUMBER,
  x_govt_hecs_payment_option    IN VARCHAR2,
  x_govt_hecs_cntrbtn_band      IN NUMBER,
  x_chg_rate                    IN NUMBER,
  x_logical_delete_dt           IN DATE,
  x_residency_status_cd         IN VARCHAR2 DEFAULT NULL,
  x_course_cd                   IN VARCHAR2 DEFAULT NULL,
  x_version_number              IN NUMBER   DEFAULT NULL,
  x_org_party_id                IN NUMBER   DEFAULT NULL,
  x_class_standing              IN VARCHAR2 DEFAULT NULL,
  x_mode                        IN VARCHAR2 DEFAULT 'R',
  x_unit_set_cd                 IN VARCHAR2 DEFAULT NULL,
  x_us_version_number           IN NUMBER   DEFAULT NULL,
  x_unit_cd                     IN VARCHAR2 DEFAULT NULL,
  x_unit_version_number         IN NUMBER   DEFAULT NULL,
  x_unit_level                  IN VARCHAR2 DEFAULT NULL,
  x_unit_type_id                IN NUMBER   DEFAULT NULL,
  x_unit_class                  IN VARCHAR2 DEFAULT NULL,
  x_unit_mode                   IN VARCHAR2 DEFAULT NULL

  );

PROCEDURE add_row(
  x_rowid                       IN OUT NOCOPY VARCHAR2,
  x_far_id                      IN OUT NOCOPY NUMBER,
  x_fee_type                    IN VARCHAR2,
  x_fee_cal_type                IN VARCHAR2,
  x_fee_ci_sequence_number      IN NUMBER,
  x_s_relation_type             IN VARCHAR2,
  x_rate_number                 IN NUMBER,
  x_fee_cat                     IN VARCHAR2,
  x_location_cd                 IN VARCHAR2,
  x_attendance_type             IN VARCHAR2,
  x_attendance_mode             IN VARCHAR2,
  x_order_of_precedence         IN NUMBER,
  x_govt_hecs_payment_option    IN VARCHAR2,
  x_govt_hecs_cntrbtn_band      IN NUMBER,
  x_chg_rate                    IN NUMBER,
  x_logical_delete_dt           IN DATE,
  x_residency_status_cd         IN VARCHAR2 DEFAULT NULL,
  x_course_cd                   IN VARCHAR2 DEFAULT NULL,
  x_version_number              IN NUMBER   DEFAULT NULL,
  x_org_party_id                IN NUMBER   DEFAULT NULL,
  x_class_standing              IN VARCHAR2 DEFAULT NULL,
  x_mode                        IN VARCHAR2 DEFAULT 'R',
  x_unit_set_cd                 IN VARCHAR2 DEFAULT NULL,
  x_us_version_number           IN NUMBER   DEFAULT NULL,
  x_unit_cd                     IN VARCHAR2 DEFAULT NULL,
  x_unit_version_number         IN NUMBER   DEFAULT NULL,
  x_unit_level                  IN VARCHAR2 DEFAULT NULL,
  x_unit_type_id                IN NUMBER   DEFAULT NULL,
  x_unit_class                  IN VARCHAR2 DEFAULT NULL,
  x_unit_mode                   IN VARCHAR2 DEFAULT NULL

  );

PROCEDURE delete_row (
  x_rowid        IN VARCHAR2
);

PROCEDURE Check_Constraints (
    column_name  IN  VARCHAR2 DEFAULT NULL,
    column_value IN  VARCHAR2 DEFAULT NULL
  );

FUNCTION get_pk_for_validation (
    x_FAR_ID NUMBER
  ) RETURN BOOLEAN;

FUNCTION get_uk1_for_validation (
    x_fee_type               IN VARCHAR2,
    x_fee_cal_type           IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_rate_number            IN NUMBER,
    x_fee_cat                IN VARCHAR2
  ) RETURN BOOLEAN;

FUNCTION get_uk2_for_validation (
    x_fee_type               IN VARCHAR2,
    x_fee_cal_type           IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_s_relation_type        IN VARCHAR2,
    x_rate_number            IN NUMBER,
    x_fee_cat                IN VARCHAR2
  ) RETURN BOOLEAN;

PROCEDURE before_dml (
    p_action                    IN VARCHAR2,
    x_rowid                     IN VARCHAR2 DEFAULT NULL,
    x_far_id                    IN NUMBER   DEFAULT NULL,
    x_fee_type                  IN VARCHAR2 DEFAULT NULL,
    x_fee_cal_type              IN VARCHAR2 DEFAULT NULL,
    x_fee_ci_sequence_number    IN NUMBER   DEFAULT NULL,
    x_s_relation_type           IN VARCHAR2 DEFAULT NULL,
    x_rate_number               IN NUMBER   DEFAULT NULL,
    x_fee_cat                   IN VARCHAR2 DEFAULT NULL,
    x_location_cd               IN VARCHAR2 DEFAULT NULL,
    x_attendance_type           IN VARCHAR2 DEFAULT NULL,
    x_attendance_mode           IN VARCHAR2 DEFAULT NULL,
    x_order_of_precedence       IN NUMBER   DEFAULT NULL,
    x_govt_hecs_payment_option  IN VARCHAR2 DEFAULT NULL,
    x_govt_hecs_cntrbtn_band    IN NUMBER   DEFAULT NULL,
    x_chg_rate                  IN NUMBER   DEFAULT NULL,
    x_logical_delete_dt         IN DATE     DEFAULT NULL,
    x_residency_status_cd       IN VARCHAR2 DEFAULT NULL,
    x_course_cd                 IN VARCHAR2 DEFAULT NULL,
    x_version_number            IN NUMBER   DEFAULT NULL,
    x_org_party_id              IN NUMBER   DEFAULT NULL,
    x_class_standing            IN VARCHAR2 DEFAULT NULL,
    x_creation_date             IN DATE     DEFAULT NULL,
    x_created_by                IN NUMBER   DEFAULT NULL,
    x_last_update_date          IN DATE     DEFAULT NULL,
    x_last_updated_by           IN NUMBER   DEFAULT NULL,
    x_last_update_login         IN NUMBER   DEFAULT NULL,
    x_unit_set_cd               IN VARCHAR2 DEFAULT NULL,
    x_us_version_number         IN NUMBER   DEFAULT NULL,
    x_unit_cd                   IN VARCHAR2 DEFAULT NULL,
    x_unit_version_number       IN NUMBER   DEFAULT NULL,
    x_unit_level                IN VARCHAR2 DEFAULT NULL,
    x_unit_type_id              IN NUMBER   DEFAULT NULL,
    x_unit_class                IN VARCHAR2 DEFAULT NULL,
    x_unit_mode                 IN VARCHAR2 DEFAULT NULL

  );

PROCEDURE get_fk_igs_as_unit_mode (
         x_unit_mode IN VARCHAR2
         );

PROCEDURE get_fk_igs_en_atd_mode (
    x_attendance_mode IN VARCHAR2
    );

PROCEDURE get_fk_igs_en_atd_type (
    x_attendance_type IN VARCHAR2
    );

PROCEDURE get_fk_igs_fi_govt_hec_cntb (
    x_govt_hecs_cntrbtn_band IN NUMBER
    );

PROCEDURE get_fk_igs_fi_gov_hec_pa_op (
    x_govt_hecs_payment_option IN VARCHAR2
    );

PROCEDURE get_fk_igs_ad_location (
    x_location_cd IN VARCHAR2
    );

 -- Added by Nishikant to include the following two procedures for enhancement bug#1851586
PROCEDURE get_fk_igs_ps_ver (
    x_course_cd     IN VARCHAR2,
    x_version_number   IN NUMBER
    );

PROCEDURE get_ufk_igs_pr_class_std (
    x_class_standing IN VARCHAR2
    );

PROCEDURE get_fk_igs_en_unit_set_all(
    x_unit_set_cd         IN VARCHAR2,
    x_us_version_number   IN NUMBER
    );

END igs_fi_fee_as_rate_pkg;

 

/
