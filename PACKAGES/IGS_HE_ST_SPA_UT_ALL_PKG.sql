--------------------------------------------------------
--  DDL for Package IGS_HE_ST_SPA_UT_ALL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_ST_SPA_UT_ALL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI23S.pls 115.2 2002/11/29 04:40:59 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_spau_id                   IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_qualification_level               IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hesa_st_spau_id                   IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_qualification_level               IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hesa_st_spau_id                   IN     NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_qualification_level               IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hesa_st_spau_id                   IN OUT NOCOPY NUMBER,
    x_org_id                            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_qualification_level               IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_hesa_st_spau_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_qualification_level               IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_he_st_spa_all (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hesa_st_spau_id                   IN     NUMBER      DEFAULT NULL,
    x_org_id                            IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_qualification_level               IN     VARCHAR2    DEFAULT NULL,
    x_number_of_qual                    IN     NUMBER      DEFAULT NULL,
    x_tariff_score                      IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_st_spa_ut_all_pkg;

 

/
