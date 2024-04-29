--------------------------------------------------------
--  DDL for Package IGR_I_PKGITM_ASSIGN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGR_I_PKGITM_ASSIGN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSRH20S.pls 120.0 2005/06/01 14:40:33 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pkg_item_assign_id                IN OUT NOCOPY NUMBER,
    x_product_category_id               IN     NUMBER,
    x_product_category_set_id           IN     NUMBER,
    x_package_item_id                   IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_pkg_item_assign_id                IN     NUMBER,
    x_product_category_id               IN     NUMBER,
    x_product_category_set_id           IN     NUMBER,
    x_package_item_id                   IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_pkg_item_assign_id                IN     NUMBER,
    x_product_category_id               IN     NUMBER,
    x_product_category_set_id           IN     NUMBER,
    x_package_item_id                   IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pkg_item_assign_id                IN OUT NOCOPY NUMBER,
    x_product_category_id               IN     NUMBER,
    x_product_category_set_id           IN     NUMBER,
    x_package_item_id                   IN     NUMBER,
    x_enabled_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_pkg_item_assign_id                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igr_i_pkg_item (
    x_package_item_id                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_pkg_item_assign_id                IN     NUMBER      DEFAULT NULL,
    x_product_category_id               IN     NUMBER      DEFAULT NULL,
    x_product_category_set_id           IN     NUMBER      DEFAULT NULL,
    x_package_item_id                   IN     NUMBER      DEFAULT NULL,
    x_enabled_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END IGR_I_PKGITM_ASSIGN_PKG;

 

/
