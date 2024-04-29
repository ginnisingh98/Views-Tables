--------------------------------------------------------
--  DDL for Package IGF_SL_DL_CHG_SEND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_CHG_SEND_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI17S.pls 115.3 2002/11/28 14:25:25 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_chg_num                           IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_new_value                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_chg_num                           IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_new_value                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_chg_num                           IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_new_value                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_chg_num                           IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_chg_code                          IN     VARCHAR2,
    x_new_value                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_chg_num                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sl_dl_batch (
    x_dbth_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_chg_num                           IN     NUMBER      DEFAULT NULL,
    x_dbth_id                           IN     NUMBER      DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_chg_code                          IN     VARCHAR2    DEFAULT NULL,
    x_new_value                         IN     VARCHAR2    DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_dl_chg_send_pkg;

 

/
