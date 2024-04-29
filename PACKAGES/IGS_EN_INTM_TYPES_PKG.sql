--------------------------------------------------------
--  DDL for Package IGS_EN_INTM_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_INTM_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI56S.pls 115.5 2003/02/20 09:10:02 kkillams noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_intermission_type                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_appr_reqd_ind                     IN     VARCHAR2,
    x_study_antr_inst_ind               IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_intermission_type                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_appr_reqd_ind                     IN     VARCHAR2,
    x_study_antr_inst_ind               IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_intermission_type                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_appr_reqd_ind                     IN     VARCHAR2,
    x_study_antr_inst_ind               IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_intermission_type                 IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_appr_reqd_ind                     IN     VARCHAR2,
    x_study_antr_inst_ind               IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION get_uk_for_validation (
    x_intermission_type                 IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_intermission_type                 IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_appr_reqd_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_study_antr_inst_ind               IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_intm_types_pkg;

 

/
