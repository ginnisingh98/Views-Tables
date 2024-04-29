--------------------------------------------------------
--  DDL for Package IGF_AW_COA_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_COA_HIST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI68S.pls 120.0 2005/06/02 15:52:09 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_coah_id                           IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_tran_date                         IN     DATE,
    x_item_code                         IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_operation_txt                     IN     VARCHAR2,
    x_old_value                         IN     NUMBER,
    x_new_value                         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_coah_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_tran_date                         IN     DATE,
    x_item_code                         IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_operation_txt                     IN     VARCHAR2,
    x_old_value                         IN     NUMBER,
    x_new_value                         IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_coah_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_tran_date                         IN     DATE,
    x_item_code                         IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_operation_txt                     IN     VARCHAR2,
    x_old_value                         IN     NUMBER,
    x_new_value                         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_coah_id                           IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_tran_date                         IN     DATE,
    x_item_code                         IN     VARCHAR2,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_operation_txt                     IN     VARCHAR2,
    x_old_value                         IN     NUMBER,
    x_new_value                         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_coah_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_coah_id                           IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_tran_date                         IN     DATE        DEFAULT NULL,
    x_item_code                         IN     VARCHAR2    DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_operation_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_old_value                         IN     NUMBER      DEFAULT NULL,
    x_new_value                         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_coa_hist_pkg;

 

/
