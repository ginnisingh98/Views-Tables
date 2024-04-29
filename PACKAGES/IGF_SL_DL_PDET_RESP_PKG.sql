--------------------------------------------------------
--  DDL for Package IGF_SL_DL_PDET_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_PDET_RESP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI27S.pls 115.4 2002/11/28 14:27:46 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dlpnr_id                          IN     NUMBER,
    x_dlpdr_id                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_dlpnr_id                          IN     NUMBER,
    x_dlpdr_id                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_dlpnr_id                          IN     NUMBER,
    x_dlpdr_id                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dlpnr_id                          IN     NUMBER,
    x_dlpdr_id                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dlpnr_id                          IN     NUMBER,
    x_dlpdr_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sl_dl_pnote_resp (
    x_dlpnr_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dlpnr_id                          IN     NUMBER      DEFAULT NULL,
    x_dlpdr_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_dl_pdet_resp_pkg;

 

/
