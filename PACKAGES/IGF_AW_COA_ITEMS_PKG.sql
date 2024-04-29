--------------------------------------------------------
--  DDL for Package IGF_AW_COA_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_COA_ITEMS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI57S.pls 120.0 2005/06/02 15:52:08 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_pell_coa_amount                   IN     NUMBER,
    x_alt_pell_amount                   IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2     DEFAULT NULL,
    x_mode                              IN     VARCHAR2     DEFAULT 'R',
    x_lock_flag                          IN     VARCHAR2     DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_pell_coa_amount                   IN     NUMBER,
    x_alt_pell_amount                   IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2     DEFAULT NULL,
    x_lock_flag                          IN     VARCHAR2     DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_pell_coa_amount                   IN     NUMBER,
    x_alt_pell_amount                   IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2     DEFAULT NULL,
    x_mode                              IN     VARCHAR2     DEFAULT 'R',
    x_lock_flag                          IN     VARCHAR2     DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_pell_coa_amount                   IN     NUMBER,
    x_alt_pell_amount                   IN     NUMBER,
    x_fixed_cost                        IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2     DEFAULT NULL,
    x_mode                              IN     VARCHAR2     DEFAULT 'R',
    x_lock_flag                          IN     VARCHAR2     DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_item (
    x_item_code                         IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_item_code                         IN     VARCHAR2    DEFAULT NULL,
    x_amount                            IN     NUMBER      DEFAULT NULL,
    x_pell_coa_amount                   IN     NUMBER      DEFAULT NULL,
    x_alt_pell_amount                   IN     NUMBER      DEFAULT NULL,
    x_fixed_cost                        IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_lock_flag                          IN     VARCHAR2    DEFAULT NULL
  );

END igf_aw_coa_items_pkg;

 

/
