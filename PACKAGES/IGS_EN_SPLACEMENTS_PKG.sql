--------------------------------------------------------
--  DDL for Package IGS_EN_SPLACEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPLACEMENTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI73S.pls 120.0 2005/06/01 20:16:00 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_splacement_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_placement_type_code               IN     VARCHAR2,
    x_specialty_code                    IN     VARCHAR2,
    x_compensation_flag                 IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_splacement_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_placement_type_code               IN     VARCHAR2,
    x_specialty_code                    IN     VARCHAR2,
    x_compensation_flag                 IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_notes                             IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_splacement_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_placement_type_code               IN     VARCHAR2,
    x_specialty_code                    IN     VARCHAR2,
    x_compensation_flag                 IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_splacement_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_category_code                     IN     VARCHAR2,
    x_placement_type_code               IN     VARCHAR2,
    x_specialty_code                    IN     VARCHAR2,
    x_compensation_flag                 IN     VARCHAR2,
    x_attendance_type                   IN     VARCHAR2,
    x_location                          IN     VARCHAR2,
    x_notes                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_splacement_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk2_for_validation (
    x_person_id                         IN     NUMBER,
    x_institution_code                  IN     VARCHAR2,
    x_title                             IN     VARCHAR2,
    x_start_date                        IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_splacement_id                     IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_institution_code                  IN     VARCHAR2    DEFAULT NULL,
    x_title                             IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_category_code                     IN     VARCHAR2    DEFAULT NULL,
    x_placement_type_code               IN     VARCHAR2    DEFAULT NULL,
    x_specialty_code                    IN     VARCHAR2    DEFAULT NULL,
    x_compensation_flag                 IN     VARCHAR2    DEFAULT NULL,
    x_attendance_type                   IN     VARCHAR2    DEFAULT NULL,
    x_location                          IN     VARCHAR2    DEFAULT NULL,
    x_notes                             IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_splacements_pkg;

 

/
