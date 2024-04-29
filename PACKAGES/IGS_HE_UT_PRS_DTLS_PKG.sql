--------------------------------------------------------
--  DDL for Package IGS_HE_UT_PRS_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_UT_PRS_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI40S.pls 120.1 2005/06/09 23:44:23 appldev  $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_award_cd                          IN     VARCHAR2,
    x_number_of_qual                    IN     NUMBER,
    x_tariff_score                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_award_cd                          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_ut_prs_calcs(
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_person_id                         IN     NUMBER
   );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_tariff_calc_type_cd               IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_award_cd                          IN     VARCHAR2    DEFAULT NULL,
    x_number_of_qual                    IN     NUMBER      DEFAULT NULL,
    x_tariff_score                      IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_ut_prs_dtls_pkg;

 

/
