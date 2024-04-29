--------------------------------------------------------
--  DDL for Package IGF_SL_DL_PNOTE_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_PNOTE_RESP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI26S.pls 115.5 2002/11/28 14:27:34 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dlpnr_id                          IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_rej_codes                   IN     VARCHAR2,
    x_mpn_ind                           IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_elec_mpn_ind                      IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_dlpnr_id                          IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_rej_codes                   IN     VARCHAR2,
    x_mpn_ind                           IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_elec_mpn_ind                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_dlpnr_id                          IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_rej_codes                   IN     VARCHAR2,
    x_mpn_ind                           IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_elec_mpn_ind                      IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_dlpnr_id                          IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_pnote_ack_date                    IN     DATE,
    x_pnote_batch_id                    IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_rej_codes                   IN     VARCHAR2,
    x_mpn_ind                           IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_elec_mpn_ind                      IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_dlpnr_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sl_dl_batch (
    x_dbth_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_dlpnr_id                          IN     NUMBER      DEFAULT NULL,
    x_dbth_id                           IN     NUMBER      DEFAULT NULL,
    x_pnote_ack_date                    IN     DATE        DEFAULT NULL,
    x_pnote_batch_id                    IN     VARCHAR2    DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_pnote_status                      IN     VARCHAR2    DEFAULT NULL,
    x_pnote_rej_codes                   IN     VARCHAR2    DEFAULT NULL,
    x_mpn_ind                           IN     VARCHAR2    DEFAULT NULL,
    x_pnote_accept_amt                  IN     NUMBER      DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_elec_mpn_ind                      IN     VARCHAR2    DEFAULT NULL
  );

END igf_sl_dl_pnote_resp_pkg;

 

/
