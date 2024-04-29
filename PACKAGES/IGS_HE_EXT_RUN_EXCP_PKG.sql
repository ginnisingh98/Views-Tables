--------------------------------------------------------
--  DDL for Package IGS_HE_EXT_RUN_EXCP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_EXT_RUN_EXCP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI27S.pls 115.3 2002/11/29 04:42:17 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ext_exception_id                  IN OUT NOCOPY NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_exception_reason                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ext_exception_id                  IN     NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_exception_reason                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ext_exception_id                  IN     NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_exception_reason                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ext_exception_id                  IN OUT NOCOPY NUMBER,
    x_extract_run_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_course_cd                         IN     VARCHAR2,
    x_crv_version_number                IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_uv_version_number                 IN     NUMBER,
    x_line_number                       IN     NUMBER,
    x_field_number                      IN     NUMBER,
    x_exception_reason                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ext_exception_id                  IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ext_exception_id                  IN     NUMBER      DEFAULT NULL,
    x_extract_run_id                    IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_person_number                     IN     VARCHAR2    DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_crv_version_number                IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_uv_version_number                 IN     NUMBER      DEFAULT NULL,
    x_line_number                       IN     NUMBER      DEFAULT NULL,
    x_field_number                      IN     NUMBER      DEFAULT NULL,
    x_exception_reason                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_ext_run_excp_pkg;

 

/
