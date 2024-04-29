--------------------------------------------------------
--  DDL for Package IGS_HE_UT_CALC_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_UT_CALC_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI33S.pls 120.0 2005/06/01 17:29:26 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_calc_type_desc             IN     VARCHAR2,
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_report_all_hierarchy_flag         IN     VARCHAR2  DEFAULT 'Y',
    x_mode                              IN     VARCHAR2  DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_calc_type_desc             IN     VARCHAR2,
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_report_all_hierarchy_flag         IN     VARCHAR2  DEFAULT 'Y'
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_calc_type_desc             IN     VARCHAR2,
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_report_all_hierarchy_flag         IN     VARCHAR2  DEFAULT 'Y',
    x_mode                              IN     VARCHAR2  DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_tariff_calc_type_desc             IN     VARCHAR2,
    x_external_calc_ind                 IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_report_all_hierarchy_flag         IN     VARCHAR2  DEFAULT 'Y',
    x_mode                              IN     VARCHAR2  DEFAULT 'R'
  );


  FUNCTION get_pk_for_validation (
    x_tariff_calc_type_cd               IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_tariff_calc_type_cd               IN     VARCHAR2    DEFAULT NULL,
    x_tariff_calc_type_desc             IN     VARCHAR2    DEFAULT NULL,
    x_external_calc_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_report_all_hierarchy_flag         IN     VARCHAR2    DEFAULT 'Y'
  );

END igs_he_ut_calc_type_pkg;

 

/
