--------------------------------------------------------
--  DDL for Package IGS_FI_ER_ORD_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_ER_ORD_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIF4S.pls 120.0 2005/09/09 19:23:41 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_order_id                          IN OUT NOCOPY NUMBER,
    x_elm_rng_order_name                IN     VARCHAR2,
    x_order_num                         IN     NUMBER,
    x_order_attr_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_order_id                          IN     NUMBER,
    x_elm_rng_order_name                IN     VARCHAR2,
    x_order_num                         IN     NUMBER,
    x_order_attr_value                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_order_id                          IN     NUMBER,
    x_elm_rng_order_name                IN     VARCHAR2,
    x_order_num                         IN     NUMBER,
    x_order_attr_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_order_id                          IN OUT NOCOPY NUMBER,
    x_elm_rng_order_name                IN     VARCHAR2,
    x_order_num                         IN     NUMBER,
    x_order_attr_value                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_order_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_order_num                         IN     NUMBER,
    x_elm_rng_order_name                IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk2_for_validation (
    x_elm_rng_order_name                IN     VARCHAR2,
    x_order_attr_value                  IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_elm_rng_ords (
    x_elm_rng_order_name                IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_order_id                          IN     NUMBER      DEFAULT NULL,
    x_elm_rng_order_name                IN     VARCHAR2    DEFAULT NULL,
    x_order_num                         IN     NUMBER      DEFAULT NULL,
    x_order_attr_value                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_er_ord_dtls_pkg;

 

/
