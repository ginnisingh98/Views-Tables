--------------------------------------------------------
--  DDL for Package IGS_FI_FAI_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_FAI_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIF5S.pls 120.0 2005/09/09 19:22:07 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fee_as_item_dtl_id                IN OUT NOCOPY NUMBER,
    x_fee_ass_item_id                   IN     NUMBER,
    x_fee_cat                           IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_attempt_status               IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_chg_elements                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fee_as_item_dtl_id                IN     NUMBER,
    x_fee_ass_item_id                   IN     NUMBER,
    x_fee_cat                           IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_attempt_status               IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_chg_elements                      IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fee_as_item_dtl_id                IN     NUMBER,
    x_fee_ass_item_id                   IN     NUMBER,
    x_fee_cat                           IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_attempt_status               IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_chg_elements                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fee_as_item_dtl_id                IN OUT NOCOPY NUMBER,
    x_fee_ass_item_id                   IN     NUMBER,
    x_fee_cat                           IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crs_version_number                IN     NUMBER,
    x_unit_attempt_status               IN     VARCHAR2,
    x_org_unit_cd                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_location_cd                       IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_us_version_number                 IN     NUMBER,
    x_chg_elements                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_fee_as_item_dtl_id                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fee_as_item_dtl_id                IN     NUMBER      DEFAULT NULL,
    x_fee_ass_item_id                   IN     NUMBER      DEFAULT NULL,
    x_fee_cat                           IN     VARCHAR2    DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_crs_version_number                IN     NUMBER      DEFAULT NULL,
    x_unit_attempt_status               IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_class_standing                    IN     VARCHAR2    DEFAULT NULL,
    x_location_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_unit_set_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_us_version_number                 IN     NUMBER      DEFAULT NULL,
    x_chg_elements                      IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_fai_dtls_pkg;

 

/
