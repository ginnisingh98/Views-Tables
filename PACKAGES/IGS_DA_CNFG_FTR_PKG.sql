--------------------------------------------------------
--  DDL for Package IGS_DA_CNFG_FTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_CNFG_FTR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSKI44S.pls 115.0 2003/04/15 09:12:00 ddey noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_configure_flag                    IN     VARCHAR2,
    x_display_flag                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_force_value_flag                  IN     VARCHAR2,
    x_default_value_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_configure_flag                    IN     VARCHAR2,
    x_display_flag                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_force_value_flag                  IN     VARCHAR2,
    x_default_value_flag                IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_configure_flag                    IN     VARCHAR2,
    x_display_flag                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_force_value_flag                  IN     VARCHAR2,
    x_default_value_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2,
    x_configure_flag                    IN     VARCHAR2,
    x_display_flag                      IN     VARCHAR2,
    x_feature_value                     IN     VARCHAR2,
    x_force_value_flag                  IN     VARCHAR2,
    x_default_value_flag                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_request_type_id                   IN     NUMBER,
    x_feature_code                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_da_cnfg_req_typ (
    x_request_type_id                   IN     NUMBER
  );

  PROCEDURE get_fk_igs_da_ftr_val_map (
    x_feature_code                      IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_request_type_id                   IN     NUMBER      DEFAULT NULL,
    x_feature_code                      IN     VARCHAR2    DEFAULT NULL,
    x_configure_flag                    IN     VARCHAR2    DEFAULT NULL,
    x_display_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_feature_value                     IN     VARCHAR2    DEFAULT NULL,
    x_force_value_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_default_value_flag                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_da_cnfg_ftr_pkg;

 

/
