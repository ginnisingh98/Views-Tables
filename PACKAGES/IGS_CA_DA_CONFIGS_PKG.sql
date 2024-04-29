--------------------------------------------------------
--  DDL for Package IGS_CA_DA_CONFIGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_CA_DA_CONFIGS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSCI18S.pls 120.1 2005/08/11 05:44:53 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sys_date_type                     IN OUT NOCOPY VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_owner_module_code                 IN     VARCHAR2,
    x_validation_proc                   IN     VARCHAR2,
    x_one_per_cal_flag                  IN     VARCHAR2,
    x_res_cal_cat1                      IN     VARCHAR2,
    x_res_cal_cat2                      IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sys_date_type                     IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_owner_module_code                 IN     VARCHAR2,
    x_validation_proc                   IN     VARCHAR2,
    x_one_per_cal_flag                  IN     VARCHAR2,
    x_res_cal_cat1                      IN     VARCHAR2,
    x_res_cal_cat2                      IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sys_date_type                     IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_owner_module_code                 IN     VARCHAR2,
    x_validation_proc                   IN     VARCHAR2,
    x_one_per_cal_flag                  IN     VARCHAR2,
    x_res_cal_cat1                      IN     VARCHAR2,
    x_res_cal_cat2                      IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sys_date_type                     IN OUT NOCOPY VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_owner_module_code                 IN     VARCHAR2,
    x_validation_proc                   IN     VARCHAR2,
    x_one_per_cal_flag                  IN     VARCHAR2,
    x_res_cal_cat1                      IN     VARCHAR2,
    x_res_cal_cat2                      IN     VARCHAR2,
    x_date_alias                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_sys_date_type                     IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sys_date_type                     IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_owner_module_code                 IN     VARCHAR2    DEFAULT NULL,
    x_validation_proc                   IN     VARCHAR2    DEFAULT NULL,
    x_one_per_cal_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_res_cal_cat1                      IN     VARCHAR2    DEFAULT NULL,
    x_res_cal_cat2                      IN     VARCHAR2    DEFAULT NULL,
    x_date_alias                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ca_da_configs_pkg;

 

/
