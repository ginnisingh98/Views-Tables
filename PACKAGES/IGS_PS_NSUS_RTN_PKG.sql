--------------------------------------------------------
--  DDL for Package IGS_PS_NSUS_RTN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_NSUS_RTN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI3NS.pls 120.0 2005/06/01 19:37:22 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_non_std_usec_rtn_id               IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_incl_wkend_duration_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_incl_wkend_duration_flag          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_incl_wkend_duration_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_non_std_usec_rtn_id               IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_incl_wkend_duration_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_non_std_usec_rtn_id               IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE Check_Constraints(
                                Column_Name     IN      VARCHAR2        DEFAULT NULL,
                                Column_Value    IN      VARCHAR2        DEFAULT NULL);

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_non_std_usec_rtn_id               IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_definition_code                   IN     VARCHAR2    DEFAULT NULL,
    x_formula_method                    IN     VARCHAR2    DEFAULT NULL,
    x_round_method                      IN     VARCHAR2    DEFAULT NULL,
    x_incl_wkend_duration_flag          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_nsus_rtn_pkg;

 

/
