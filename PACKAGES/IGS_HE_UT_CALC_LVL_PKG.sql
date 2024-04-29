--------------------------------------------------------
--  DDL for Package IGS_HE_UT_CALC_LVL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_UT_CALC_LVL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI34S.pls 115.0 2003/02/14 15:58:40 bayadav noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_level_cd                   IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_level_cd                   IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_level_cd                   IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_level_cd                   IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );



  FUNCTION get_pk_for_validation (
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_level_cd                   IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_tariff_calc_type_cd               IN     VARCHAR2    DEFAULT NULL,
    x_tariff_level_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_ut_calc_lvl_pkg;

 

/
