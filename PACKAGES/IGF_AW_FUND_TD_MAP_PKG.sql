--------------------------------------------------------
--  DDL for Package IGF_AW_FUND_TD_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_FUND_TD_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI50S.pls 115.2 2002/11/28 11:23:40 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ftodo_id                          IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ftodo_id                          IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ftodo_id                          IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ftodo_id                          IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ftodo_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_fund_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_fund_mast (
    x_fund_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_ap_td_item_mst (
    x_todo_number              IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ftodo_id                          IN     NUMBER      DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_item_sequence_number              IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_fund_td_map_pkg;

 

/
