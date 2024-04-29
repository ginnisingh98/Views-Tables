--------------------------------------------------------
--  DDL for Package IGF_AW_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_ITEM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI02S.pls 115.8 2003/12/05 16:06:40 ugummall ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_item_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_item_category_code                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_item_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_item_category_code                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_item_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_item_category_code                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_item_code                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_item_category_code                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_item_code                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_item_code                         IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_active                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_item_category_code                IN     VARCHAR2    DEFAULT NULL
  );

END igf_aw_item_pkg;

 

/
