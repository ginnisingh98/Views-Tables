--------------------------------------------------------
--  DDL for Package IGS_FI_POSTING_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_POSTING_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIA1S.pls 115.11 2003/02/17 09:12:52 pathipat ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_posting_id                        IN OUT NOCOPY NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_accounting_date                   IN     DATE,
    x_transaction_date                  IN     DATE,
    x_currency_cd                       IN     VARCHAR2,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_amount                            IN     NUMBER,
    x_source_transaction_id             IN     NUMBER,
    x_source_transaction_type           IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_orig_appl_fee_ref                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_posting_id                        IN     NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_accounting_date                   IN     DATE,
    x_transaction_date                  IN     DATE,
    x_currency_cd                       IN     VARCHAR2,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_amount                            IN     NUMBER,
    x_source_transaction_id             IN     NUMBER,
    x_source_transaction_type           IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_orig_appl_fee_ref                 IN     VARCHAR2    DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_posting_id                        IN     NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_accounting_date                   IN     DATE,
    x_transaction_date                  IN     DATE,
    x_currency_cd                       IN     VARCHAR2,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_amount                            IN     NUMBER,
    x_source_transaction_id             IN     NUMBER,
    x_source_transaction_type           IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_orig_appl_fee_ref                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_posting_id                        IN OUT NOCOPY NUMBER,
    x_batch_name                        IN     VARCHAR2,
    x_accounting_date                   IN     DATE,
    x_transaction_date                  IN     DATE,
    x_currency_cd                       IN     VARCHAR2,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_code_ccid                   IN     NUMBER,
    x_cr_gl_code_ccid                   IN     NUMBER,
    x_amount                            IN     NUMBER,
    x_source_transaction_id             IN     NUMBER,
    x_source_transaction_type           IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_orig_appl_fee_ref                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_posting_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_posting_id                        IN     NUMBER      DEFAULT NULL,
    x_batch_name                        IN     VARCHAR2    DEFAULT NULL,
    x_accounting_date                   IN     DATE        DEFAULT NULL,
    x_transaction_date                  IN     DATE        DEFAULT NULL,
    x_currency_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_dr_account_cd                     IN     VARCHAR2    DEFAULT NULL,
    x_cr_account_cd                     IN     VARCHAR2    DEFAULT NULL,
    x_dr_gl_code_ccid                   IN     NUMBER      DEFAULT NULL,
    x_cr_gl_code_ccid                   IN     NUMBER      DEFAULT NULL,
    x_amount                            IN     NUMBER      DEFAULT NULL,
    x_source_transaction_id             IN     NUMBER      DEFAULT NULL,
    x_source_transaction_type           IN     VARCHAR2    DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_orig_appl_fee_ref                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

END igs_fi_posting_int_pkg;

 

/
