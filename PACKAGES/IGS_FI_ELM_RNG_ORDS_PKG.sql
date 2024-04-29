--------------------------------------------------------
--  DDL for Package IGS_FI_ELM_RNG_ORDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_ELM_RNG_ORDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIF3S.pls 120.0 2005/09/09 18:44:06 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_elm_rng_order_name                IN     VARCHAR2,
    x_elm_rng_order_desc                IN     VARCHAR2,
    x_elm_rng_order_attr_code           IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_elm_rng_order_name                IN     VARCHAR2,
    x_elm_rng_order_desc                IN     VARCHAR2,
    x_elm_rng_order_attr_code           IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_elm_rng_order_name                IN     VARCHAR2,
    x_elm_rng_order_desc                IN     VARCHAR2,
    x_elm_rng_order_attr_code           IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_elm_rng_order_name                IN     VARCHAR2,
    x_elm_rng_order_desc                IN     VARCHAR2,
    x_elm_rng_order_attr_code           IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_elm_rng_order_name                IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_elm_rng_order_name                IN     VARCHAR2    DEFAULT NULL,
    x_elm_rng_order_desc                IN     VARCHAR2    DEFAULT NULL,
    x_elm_rng_order_attr_code           IN     VARCHAR2    DEFAULT NULL,
    x_closed_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_elm_rng_ords_pkg;

 

/
