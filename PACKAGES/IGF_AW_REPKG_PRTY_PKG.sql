--------------------------------------------------------
--  DDL for Package IGF_AW_REPKG_PRTY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_REPKG_PRTY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI66S.pls 120.0 2005/06/01 14:02:38 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_order_num                    IN OUT NOCOPY NUMBER,
    x_sys_fund_type_code                IN     VARCHAR2,
    x_fund_source_code                  IN     VARCHAR2,
    x_sys_fund_code                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_order_num                    IN     NUMBER,
    x_sys_fund_type_code                IN     VARCHAR2,
    x_fund_source_code                  IN     VARCHAR2,
    x_sys_fund_code                     IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fund_order_num                    IN     NUMBER,
    x_sys_fund_type_code                IN     VARCHAR2,
    x_fund_source_code                  IN     VARCHAR2,
    x_sys_fund_code                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fund_order_num                    IN OUT NOCOPY NUMBER,
    x_sys_fund_type_code                IN     VARCHAR2,
    x_fund_source_code                  IN     VARCHAR2,
    x_sys_fund_code                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_fund_order_num                    IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_sys_fund_type_code                IN     VARCHAR2,
    x_fund_source_code                  IN     VARCHAR2,
    x_sys_fund_code                     IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fund_order_num                    IN     NUMBER      DEFAULT NULL,
    x_sys_fund_type_code                IN     VARCHAR2    DEFAULT NULL,
    x_fund_source_code                  IN     VARCHAR2    DEFAULT NULL,
    x_sys_fund_code                     IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_repkg_prty_pkg;

 

/
