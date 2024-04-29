--------------------------------------------------------
--  DDL for Package IGF_SL_DL_LOR_CRRESP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_LOR_CRRESP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI15S.pls 115.4 2003/02/20 15:39:55 sjadhav ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lor_resp_num                      IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_status                            IN     VARCHAR2,
    x_endorser_amount                   IN     NUMBER     DEFAULT NULL,
    x_mpn_status                        IN     VARCHAR2   DEFAULT NULL,
    x_mpn_id                            IN     VARCHAR2   DEFAULT NULL,
    x_mpn_type                          IN     VARCHAR2   DEFAULT NULL,
    x_mpn_indicator                     IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2   DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lor_resp_num                      IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_status                            IN     VARCHAR2,
    x_endorser_amount                   IN     NUMBER     DEFAULT NULL,
    x_mpn_status                        IN     VARCHAR2   DEFAULT NULL,
    x_mpn_id                            IN     VARCHAR2   DEFAULT NULL,
    x_mpn_type                          IN     VARCHAR2   DEFAULT NULL,
    x_mpn_indicator                     IN     VARCHAR2   DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_lor_resp_num                      IN     NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_status                            IN     VARCHAR2,
    x_endorser_amount                   IN     NUMBER     DEFAULT NULL,
    x_mpn_status                        IN     VARCHAR2   DEFAULT NULL,
    x_mpn_id                            IN     VARCHAR2   DEFAULT NULL,
    x_mpn_type                          IN     VARCHAR2   DEFAULT NULL,
    x_mpn_indicator                     IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2   DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lor_resp_num                      IN OUT NOCOPY NUMBER,
    x_dbth_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_credit_override                   IN     VARCHAR2,
    x_credit_decision_date              IN     DATE,
    x_status                            IN     VARCHAR2,
    x_endorser_amount                   IN     NUMBER     DEFAULT NULL,
    x_mpn_status                        IN     VARCHAR2   DEFAULT NULL,
    x_mpn_id                            IN     VARCHAR2   DEFAULT NULL,
    x_mpn_type                          IN     VARCHAR2   DEFAULT NULL,
    x_mpn_indicator                     IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2   DEFAULT 'R'
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
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_credit_override                   IN     VARCHAR2    DEFAULT NULL,
    x_credit_decision_date              IN     DATE        DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_endorser_amount                   IN     NUMBER      DEFAULT NULL,
    x_mpn_status                        IN     VARCHAR2    DEFAULT NULL,
    x_mpn_id                            IN     VARCHAR2    DEFAULT NULL,
    x_mpn_type                          IN     VARCHAR2    DEFAULT NULL,
    x_mpn_indicator                     IN     VARCHAR2    DEFAULT NULL
  );

END igf_sl_dl_lor_crresp_pkg;

 

/
