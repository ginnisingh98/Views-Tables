--------------------------------------------------------
--  DDL for Package IGS_DA_FTR_VAL_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_FTR_VAL_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSKI48S.pls 115.0 2003/04/15 09:20:05 ddey noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_feature_code                      IN OUT NOCOPY VARCHAR2,
    x_feature_val_type                  IN     VARCHAR2,
    x_configure_checked                 IN     VARCHAR2,
    x_third_party_ftr_code              IN     VARCHAR2,
    x_allow_disp_chk_flag               IN     VARCHAR2,
    x_single_allowed                    IN     VARCHAR2,
    x_batch_allowed                     IN     VARCHAR2,
    x_transfer_evaluation_ind           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_feature_code                      IN     VARCHAR2,
    x_feature_val_type                  IN     VARCHAR2,
    x_configure_checked                 IN     VARCHAR2,
    x_third_party_ftr_code              IN     VARCHAR2,
    x_allow_disp_chk_flag               IN     VARCHAR2,
    x_single_allowed                    IN     VARCHAR2,
    x_batch_allowed                     IN     VARCHAR2,
    x_transfer_evaluation_ind           IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_feature_code                      IN     VARCHAR2,
    x_feature_val_type                  IN     VARCHAR2,
    x_configure_checked                 IN     VARCHAR2,
    x_third_party_ftr_code              IN     VARCHAR2,
    x_allow_disp_chk_flag               IN     VARCHAR2,
    x_single_allowed                    IN     VARCHAR2,
    x_batch_allowed                     IN     VARCHAR2,
    x_transfer_evaluation_ind           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_feature_code                      IN OUT NOCOPY VARCHAR2,
    x_feature_val_type                  IN     VARCHAR2,
    x_configure_checked                 IN     VARCHAR2,
    x_third_party_ftr_code              IN     VARCHAR2,
    x_allow_disp_chk_flag               IN     VARCHAR2,
    x_single_allowed                    IN     VARCHAR2,
    x_batch_allowed                     IN     VARCHAR2,
    x_transfer_evaluation_ind           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_feature_code                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_feature_code                      IN     VARCHAR2    DEFAULT NULL,
    x_feature_val_type                  IN     VARCHAR2    DEFAULT NULL,
    x_configure_checked                 IN     VARCHAR2    DEFAULT NULL,
    x_third_party_ftr_code              IN     VARCHAR2    DEFAULT NULL,
    x_allow_disp_chk_flag               IN     VARCHAR2    DEFAULT NULL,
    x_single_allowed                    IN     VARCHAR2    DEFAULT NULL,
    x_batch_allowed                     IN     VARCHAR2    DEFAULT NULL,
    x_transfer_evaluation_ind           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_da_ftr_val_map_pkg;

 

/
