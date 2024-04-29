--------------------------------------------------------
--  DDL for Package IGF_AW_FUND_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_FUND_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI03S.pls 115.6 2002/11/28 14:37:04 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_ft_id                             IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_ft_id                             IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_ft_id                             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_active                            IN     VARCHAR2,
    x_ft_id                             IN OUT NOCOPY NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ft_id                             IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_fund_type                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fund_type                         IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_active                            IN     VARCHAR2    DEFAULT NULL,
    x_ft_id                             IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_fund_type_pkg;

 

/
