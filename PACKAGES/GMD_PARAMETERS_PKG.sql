--------------------------------------------------------
--  DDL for Package GMD_PARAMETERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_PARAMETERS_PKG" AUTHID CURRENT_USER AS
/* $Header: GMDPARMS.pls 120.1 2005/06/02 23:08:57 appldev  $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY	VARCHAR2,
    x_parameter_id                      IN OUT NOCOPY	NUMBER,
    x_orgn_code                         IN		VARCHAR2,
    x_recipe_status                     IN		VARCHAR2,
    x_validity_rule_status              IN		VARCHAR2,
    x_formula_status                    IN		VARCHAR2,
    x_routing_status                    IN		VARCHAR2,
    x_operation_status                  IN		VARCHAR2,
    x_mode                              IN		VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_parameter_id                      IN     NUMBER,
    x_orgn_code                         IN     VARCHAR2,
    x_recipe_status                     IN     VARCHAR2,
    x_validity_rule_status              IN     VARCHAR2,
    x_formula_status                    IN     VARCHAR2,
    x_routing_status                    IN     VARCHAR2,
    x_operation_status                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_parameter_id                      IN     NUMBER,
    x_orgn_code                         IN     VARCHAR2,
    x_recipe_status                     IN     VARCHAR2,
    x_validity_rule_status              IN     VARCHAR2,
    x_formula_status                    IN     VARCHAR2,
    x_routing_status                    IN     VARCHAR2,
    x_operation_status                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY	VARCHAR2,
    x_parameter_id                      IN OUT NOCOPY	NUMBER,
    x_orgn_code                         IN		VARCHAR2,
    x_recipe_status                     IN		VARCHAR2,
    x_validity_rule_status              IN		VARCHAR2,
    x_formula_status                    IN		VARCHAR2,
    x_routing_status                    IN		VARCHAR2,
    x_operation_status                  IN		VARCHAR2,
    x_mode                              IN		VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_parameter_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_parameter_id                      IN     NUMBER      DEFAULT NULL,
    x_orgn_code                         IN     VARCHAR2    DEFAULT NULL,
    x_recipe_status                     IN     VARCHAR2    DEFAULT NULL,
    x_validity_rule_status              IN     VARCHAR2    DEFAULT NULL,
    x_formula_status                    IN     VARCHAR2    DEFAULT NULL,
    x_routing_status                    IN     VARCHAR2    DEFAULT NULL,
    x_operation_status                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END gmd_parameters_pkg;

 

/
