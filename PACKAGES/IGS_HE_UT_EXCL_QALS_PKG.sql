--------------------------------------------------------
--  DDL for Package IGS_HE_UT_EXCL_QALS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_UT_EXCL_QALS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI41S.pls 115.0 2003/09/02 13:20:08 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_excl_qual_id                      IN OUT NOCOPY NUMBER,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_excl_qual_id                      IN     NUMBER,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_excl_qual_id                      IN     NUMBER,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_excl_qual_id                      IN OUT NOCOPY NUMBER,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_award_cd                          IN     VARCHAR2,
    x_field_of_study                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_excl_qual_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_ut_calc_type (
    x_tariff_calc_type_cd               IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_excl_qual_id                      IN     NUMBER      DEFAULT NULL,
    x_tariff_calc_type_cd               IN     VARCHAR2    DEFAULT NULL,
    x_award_cd                          IN     VARCHAR2    DEFAULT NULL,
    x_field_of_study                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_ut_excl_qals_pkg;

 

/
