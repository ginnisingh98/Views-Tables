--------------------------------------------------------
--  DDL for Package IGF_AW_FI_INC_LEVEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_FI_INC_LEVEL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI42S.pls 115.4 2002/11/28 14:42:32 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_category_id                       IN     NUMBER,
    x_range_id                          IN OUT NOCOPY NUMBER,
    x_minvalue                          IN     NUMBER,
    x_maxvalue                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_category_id                       IN     NUMBER,
    x_range_id                          IN     NUMBER,
    x_minvalue                          IN     NUMBER,
    x_maxvalue                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_category_id                       IN     NUMBER,
    x_range_id                          IN     NUMBER,
    x_minvalue                          IN     NUMBER,
    x_maxvalue                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_category_id                       IN     NUMBER,
    x_range_id                          IN OUT NOCOPY NUMBER,
    x_minvalue                          IN     NUMBER,
    x_maxvalue                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_range_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_category_id                       IN     NUMBER,
    x_minvalue                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_fisap_repset (
    x_category_id                       IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_category_id                       IN     NUMBER      DEFAULT NULL,
    x_range_id                          IN     NUMBER      DEFAULT NULL,
    x_minvalue                          IN     NUMBER      DEFAULT NULL,
    x_maxvalue                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_fi_inc_level_pkg;

 

/
