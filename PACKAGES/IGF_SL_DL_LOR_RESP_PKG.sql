--------------------------------------------------------
--  DDL for Package IGF_SL_DL_LOR_RESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_LOR_RESP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI14S.pls 115.4 2002/11/28 14:24:45 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lor_resp_num                      IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_orig_batch_id                     IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_orig_ack_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_reject_reasons               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_loan_amount_accepted              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_elec_mpn_ind                      IN     VARCHAR2
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lor_resp_num                      IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_orig_batch_id                     IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_orig_ack_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_reject_reasons               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_loan_amount_accepted              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_elec_mpn_ind                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_lor_resp_num                      IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_orig_batch_id                     IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_orig_ack_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_reject_reasons               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_loan_amount_accepted              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_elec_mpn_ind                      IN     VARCHAR2
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lor_resp_num                      IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_orig_batch_id                     IN     VARCHAR2,
    x_loan_number                       IN     VARCHAR2,
    x_orig_ack_date                     IN     DATE,
    x_orig_status_flag                  IN     VARCHAR2,
    x_orig_reject_reasons               IN     VARCHAR2,
    x_pnote_status                      IN     VARCHAR2,
    x_pnote_id                          IN     VARCHAR2,
    x_pnote_accept_amt                  IN     NUMBER,
    x_loan_amount_accepted              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_elec_mpn_ind                      IN     VARCHAR2
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_lor_resp_num                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sl_dl_batch (
    x_dbth_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_lor_resp_num                      IN     NUMBER      DEFAULT NULL,
    x_dbth_id                           IN     NUMBER      DEFAULT NULL,
    x_orig_batch_id                     IN     VARCHAR2    DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_orig_ack_date                     IN     DATE        DEFAULT NULL,
    x_orig_status_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_orig_reject_reasons               IN     VARCHAR2    DEFAULT NULL,
    x_pnote_status                      IN     VARCHAR2    DEFAULT NULL,
    x_pnote_id                          IN     VARCHAR2    DEFAULT NULL,
    x_pnote_accept_amt                  IN     NUMBER      DEFAULT NULL,
    x_loan_amount_accepted              IN     NUMBER      DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_elec_mpn_ind                      IN     VARCHAR2    DEFAULT NULL
  );

END igf_sl_dl_lor_resp_pkg;

 

/
