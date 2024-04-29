--------------------------------------------------------
--  DDL for Package IGI_EXP_NUM_SCHEMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_EXP_NUM_SCHEMES_PKG" AUTHID CURRENT_USER AS
/* $Header: igiexcs.pls 120.4.12000000.1 2007/09/13 04:24:08 mbremkum ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_num_scheme_id                     IN OUT NOCOPY NUMBER,
    x_numbering_type                    IN     VARCHAR2,
    x_numbering_class                   IN     VARCHAR2,
    x_du_tu_type_id                     IN     VARCHAR2,
    x_prefix                            IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_fiscal_year                       IN     VARCHAR2,
    x_next_seq_val                      IN     VARCHAR2,
    x_org_id                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_num_scheme_id                     IN     NUMBER,
    x_numbering_type                    IN     VARCHAR2,
    x_numbering_class                   IN     VARCHAR2,
    x_du_tu_type_id                     IN     VARCHAR2,
    x_prefix                            IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_fiscal_year                       IN     VARCHAR2,
    x_next_seq_val                      IN     VARCHAR2,
    x_org_id                            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_num_scheme_id                     IN     NUMBER,
    x_numbering_type                    IN     VARCHAR2,
    x_numbering_class                   IN     VARCHAR2,
    x_du_tu_type_id                     IN     VARCHAR2,
    x_prefix                            IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_fiscal_year                       IN     VARCHAR2,
    x_next_seq_val                      IN     VARCHAR2,
    x_org_id                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_num_scheme_id                     IN OUT NOCOPY NUMBER,
    x_numbering_type                    IN     VARCHAR2,
    x_numbering_class                   IN     VARCHAR2,
    x_du_tu_type_id                     IN     VARCHAR2,
    x_prefix                            IN     VARCHAR2,
    x_suffix                            IN     VARCHAR2,
    x_fiscal_year                       IN     VARCHAR2,
    x_next_seq_val                      IN     VARCHAR2,
    x_org_id                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_num_scheme_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_num_scheme_id                     IN     NUMBER      DEFAULT NULL,
    x_numbering_type                    IN     VARCHAR2    DEFAULT NULL,
    x_numbering_class                   IN     VARCHAR2    DEFAULT NULL,
    x_du_tu_type_id                     IN     VARCHAR2    DEFAULT NULL,
    x_prefix                            IN     VARCHAR2    DEFAULT NULL,
    x_suffix                            IN     VARCHAR2    DEFAULT NULL,
    x_fiscal_year                       IN     VARCHAR2    DEFAULT NULL,
    x_next_seq_val                      IN     VARCHAR2    DEFAULT NULL,
    x_org_id                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igi_exp_num_schemes_pkg;

 

/
