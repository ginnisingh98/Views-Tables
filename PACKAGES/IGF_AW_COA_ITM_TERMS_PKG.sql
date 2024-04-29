--------------------------------------------------------
--  DDL for Package IGF_AW_COA_ITM_TERMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_COA_ITM_TERMS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI58S.pls 120.0 2005/06/01 14:14:10 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_lock_flag                          IN     VARCHAR2    DEFAULT  NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_lock_flag                          IN     VARCHAR2    DEFAULT  NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_lock_flag                          IN     VARCHAR2    DEFAULT  NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_amount                            IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_lock_flag                          IN     VARCHAR2    DEFAULT  NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_base_id                           IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_item_code                         IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igf_aw_coa_items (
    x_base_id                           IN     NUMBER,
    x_item_code                         IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_item_code                         IN     VARCHAR2    DEFAULT NULL,
    x_amount                            IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_lock_flag                          IN     VARCHAR2    DEFAULT NULL
  );

END igf_aw_coa_itm_terms_pkg;

 

/
