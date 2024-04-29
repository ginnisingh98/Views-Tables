--------------------------------------------------------
--  DDL for Package IGF_AW_FRLOG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_FRLOG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI29S.pls 115.4 2002/11/28 14:40:41 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_frlog_id                          IN OUT NOCOPY NUMBER,
    x_frol_id                           IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_rollover_fund_id                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_frlog_id                          IN     NUMBER,
    x_frol_id                           IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_rollover_fund_id                  IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_frlog_id                          IN     NUMBER,
    x_frol_id                           IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_rollover_fund_id                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_frlog_id                          IN OUT NOCOPY NUMBER,
    x_frol_id                           IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_rollover_fund_id                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_frlog_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_fund_rollover (
    x_frol_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_fund_mast (
    x_fund_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_frlog_id                          IN     NUMBER      DEFAULT NULL,
    x_frol_id                           IN     NUMBER      DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_rollover_fund_id                  IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_frlog_pkg;

 

/
