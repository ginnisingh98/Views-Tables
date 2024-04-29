--------------------------------------------------------
--  DDL for Package IGF_SL_PNOTE_STAT_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_PNOTE_STAT_H_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI28S.pls 115.4 2002/11/28 14:27:58 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dlpnh_id                          IN OUT NOCOPY NUMBER,
    x_loan_id                           IN     NUMBER,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_dlpnh_id                          IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_dlpnh_id                          IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dlpnh_id                          IN OUT NOCOPY NUMBER,
    x_loan_id                           IN     NUMBER,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_status_date                 IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dlpnh_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igf_sl_lor (
    x_loan_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dlpnh_id                          IN     NUMBER      DEFAULT NULL,
    x_loan_id                           IN     NUMBER      DEFAULT NULL,
    x_pnote_status                      IN     VARCHAR2    DEFAULT NULL,
    x_pnote_status_date                 IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_pnote_stat_h_pkg;

 

/
