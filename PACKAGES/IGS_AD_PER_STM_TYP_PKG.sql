--------------------------------------------------------
--  DDL for Package IGS_AD_PER_STM_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PER_STM_TYP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIG1S.pls 115.7 2003/10/30 13:17:53 akadam noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_persl_stat_type                   IN     VARCHAR2,
    x_persl_stat_type_desc              IN     VARCHAR2,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_persl_stat_type                   IN     VARCHAR2,
    x_persl_stat_type_desc              IN     VARCHAR2,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_persl_stat_type                   IN     VARCHAR2,
    x_persl_stat_type_desc              IN     VARCHAR2,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_persl_stat_type                   IN     VARCHAR2,
    x_persl_stat_type_desc              IN     VARCHAR2,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_persl_stat_type                   IN     VARCHAR2 ,
    x_closed_ind                        IN VARCHAR2 DEFAULT NULL
  ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_persl_stat_type                   IN     VARCHAR2    DEFAULT NULL,
    x_persl_stat_type_desc              IN     VARCHAR2    DEFAULT NULL,
    x_step_catalog_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_per_stm_typ_pkg;

 

/
