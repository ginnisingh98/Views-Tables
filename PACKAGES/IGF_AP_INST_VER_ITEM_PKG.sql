--------------------------------------------------------
--  DDL for Package IGF_AP_INST_VER_ITEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_INST_VER_ITEM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI05S.pls 115.8 2003/10/17 05:40:17 rasahoo ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_udf_vern_item_seq_num             IN     NUMBER,
    x_item_value                        IN     VARCHAR2,
    x_waive_flag                        IN     VARCHAR2,
    x_isir_map_col                      IN     VARCHAR2 DEFAULT NULL,
    x_incl_in_tolerance                 IN     VARCHAR2 DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2 DEFAULT NULL,
    x_use_blank_flag                    IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_udf_vern_item_seq_num             IN     NUMBER,
    x_item_value                        IN     VARCHAR2,
    x_waive_flag                        IN     VARCHAR2,
    x_isir_map_col                      IN     VARCHAR2 DEFAULT NULL,
    x_incl_in_tolerance                 IN     VARCHAR2 DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2 DEFAULT NULL,
    x_use_blank_flag                    IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_udf_vern_item_seq_num             IN     NUMBER,
    x_item_value                        IN     VARCHAR2,
    x_waive_flag                        IN     VARCHAR2,
    x_isir_map_col                      IN     VARCHAR2 DEFAULT NULL,
    x_incl_in_tolerance                 IN     VARCHAR2 DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2 DEFAULT NULL,
    x_use_blank_flag                    IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_udf_vern_item_seq_num             IN     NUMBER,
    x_item_value                        IN     VARCHAR2,
    x_waive_flag                        IN     VARCHAR2,
    x_isir_map_col                      IN     VARCHAR2 DEFAULT NULL,
    x_incl_in_tolerance                 IN     VARCHAR2 DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2 DEFAULT NULL,
    x_use_blank_flag                    IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_isir_map_col                      IN     VARCHAR2,
    x_base_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2 DEFAULT NULL,
    x_rowid                             IN     VARCHAR2 DEFAULT NULL,
    x_base_id                           IN     NUMBER  DEFAULT NULL,
    x_udf_vern_item_seq_num             IN     NUMBER  DEFAULT NULL,
    x_item_value                        IN     VARCHAR2  DEFAULT NULL,
    x_waive_flag                        IN     VARCHAR2  DEFAULT NULL,
    x_isir_map_col                      IN     VARCHAR2  DEFAULT NULL,
    x_incl_in_tolerance                 IN     VARCHAR2  DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2 DEFAULT NULL,
    x_use_blank_flag                    IN     VARCHAR2 DEFAULT NULL,
    x_creation_date                     IN     DATE  DEFAULT NULL,
    x_created_by                        IN     NUMBER  DEFAULT NULL,
    x_last_update_date                  IN     DATE  DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER  DEFAULT NULL,
    x_last_update_login                 IN     NUMBER  DEFAULT NULL
  );

END igf_ap_inst_ver_item_pkg;

 

/
