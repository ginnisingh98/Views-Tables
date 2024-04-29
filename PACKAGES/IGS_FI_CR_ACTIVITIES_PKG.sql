--------------------------------------------------------
--  DDL for Package IGS_FI_CR_ACTIVITIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_CR_ACTIVITIES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI87S.pls 115.9 2003/02/17 09:00:36 pathipat ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_credit_activity_id                IN OUT NOCOPY NUMBER,
    x_credit_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_amount                            IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_gl_date                           IN     DATE        DEFAULT NULL,
    x_gl_posted_date                    IN     DATE        DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_credit_activity_id                IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_amount                            IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_posting_id                        IN     NUMBER,
    x_gl_date                           IN     DATE        DEFAULT NULL,
    x_gl_posted_date                    IN     DATE        DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_credit_activity_id                IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_amount                            IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_gl_date                           IN     DATE        DEFAULT NULL,
    x_gl_posted_date                    IN     DATE        DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_credit_activity_id                IN OUT NOCOPY NUMBER,
    x_credit_id                         IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_amount                            IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_bill_number                       IN     VARCHAR2,
    x_bill_date                         IN     DATE,
    x_posting_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_gl_date                           IN     DATE        DEFAULT NULL,
    x_gl_posted_date                    IN     DATE        DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_credit_activity_id                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_bill (
    x_bill_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_credits_all (
    x_credit_id                         IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_posting_int_all (
    x_posting_id                        IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_credit_activity_id                IN     NUMBER      DEFAULT NULL,
    x_credit_id                         IN     NUMBER      DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_transaction_date                  IN     DATE        DEFAULT NULL,
    x_amount                            IN     NUMBER      DEFAULT NULL,
    x_dr_account_cd                     IN     VARCHAR2    DEFAULT NULL,
    x_cr_account_cd                     IN     VARCHAR2    DEFAULT NULL,
    x_dr_gl_ccid                        IN     NUMBER      DEFAULT NULL,
    x_cr_gl_ccid                        IN     NUMBER      DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_bill_number                       IN     VARCHAR2    DEFAULT NULL,
    x_bill_date                         IN     DATE        DEFAULT NULL,
    x_posting_id                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_gl_date                           IN     DATE        DEFAULT NULL,
    x_gl_posted_date                    IN     DATE        DEFAULT NULL,
    x_posting_control_id                IN     NUMBER      DEFAULT NULL
  );

END igs_fi_cr_activities_pkg;

 

/
