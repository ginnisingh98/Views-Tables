--------------------------------------------------------
--  DDL for Package IGS_EN_NSU_DLSTP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_NSU_DLSTP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI48S.pls 120.0 2005/06/01 23:18:10 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_non_std_usec_dls_id               IN OUT NOCOPY NUMBER,
    x_function_name                     IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_incl_wkend_duration_flag          IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_function_name                     IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_incl_wkend_duration_flag          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_dls_id               IN     NUMBER,
    x_function_name                     IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_incl_wkend_duration_flag          IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_non_std_usec_dls_id               IN OUT NOCOPY NUMBER,
    x_function_name                     IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_offset_dt_code                    IN     VARCHAR2,
    x_offset_duration                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'  ,
    x_incl_wkend_duration_flag          IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_non_std_usec_dls_id               IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_function_name                     IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_org_unit_code                     IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE Check_Constraints(
                                Column_Name     IN      VARCHAR2        DEFAULT NULL,
                                Column_Value    IN      VARCHAR2        DEFAULT NULL);

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_non_std_usec_dls_id               IN     NUMBER      DEFAULT NULL,
    x_function_name                     IN     VARCHAR2    DEFAULT NULL,
    x_definition_code                   IN     VARCHAR2    DEFAULT NULL,
    x_org_unit_code                     IN     VARCHAR2    DEFAULT NULL,
    x_formula_method                    IN     VARCHAR2    DEFAULT NULL,
    x_round_method                      IN     VARCHAR2    DEFAULT NULL,
    x_offset_dt_code                    IN     VARCHAR2    DEFAULT NULL,
    x_offset_duration                   IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_incl_wkend_duration_flag          IN     VARCHAR2    DEFAULT NULL
  );

END igs_en_nsu_dlstp_pkg;

 

/
