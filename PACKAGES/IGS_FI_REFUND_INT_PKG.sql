--------------------------------------------------------
--  DDL for Package IGS_FI_REFUND_INT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_REFUND_INT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIC3S.pls 115.4 2003/02/12 11:48:52 pathipat noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_refund_id                         IN     NUMBER,
    x_voucher_date                      IN     DATE,
    x_person_id                         IN     NUMBER,
    x_pay_person_id                     IN     NUMBER,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_refund_amount                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_source_refund_id                  IN     NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_reason                            IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_gl_date                           IN     DATE        DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_refund_id                         IN     NUMBER,
    x_voucher_date                      IN     DATE,
    x_person_id                         IN     NUMBER,
    x_pay_person_id                     IN     NUMBER,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_refund_amount                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_source_refund_id                  IN     NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_reason                            IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_gl_date                           IN     DATE        DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_refund_id                         IN     NUMBER,
    x_voucher_date                      IN     DATE,
    x_person_id                         IN     NUMBER,
    x_pay_person_id                     IN     NUMBER,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_refund_amount                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_source_refund_id                  IN     NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_reason                            IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_gl_date                           IN     DATE        DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_refund_id                         IN NUMBER,
    x_voucher_date                      IN     DATE,
    x_person_id                         IN     NUMBER,
    x_pay_person_id                     IN     NUMBER,
    x_dr_gl_ccid                        IN     NUMBER,
    x_cr_gl_ccid                        IN     NUMBER,
    x_dr_account_cd                     IN     VARCHAR2,
    x_cr_account_cd                     IN     VARCHAR2,
    x_refund_amount                     IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_source_refund_id                  IN     NUMBER,
    x_invoice_id                        IN     NUMBER,
    x_reason                            IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_gl_date                           IN     DATE        DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_refund_id                         IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_refunds (
    x_refund_id                         IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_inv_int (
    x_invoice_id                        IN     NUMBER
  );

  PROCEDURE get_fk_igs_fi_refund_int (
    x_refund_id                         IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_refund_id                         IN     NUMBER      DEFAULT NULL,
    x_voucher_date                      IN     DATE        DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_pay_person_id                     IN     NUMBER      DEFAULT NULL,
    x_dr_gl_ccid                        IN     NUMBER      DEFAULT NULL,
    x_cr_gl_ccid                        IN     NUMBER      DEFAULT NULL,
    x_dr_account_cd                     IN     VARCHAR2    DEFAULT NULL,
    x_cr_account_cd                     IN     VARCHAR2    DEFAULT NULL,
    x_refund_amount                     IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_source_refund_id                  IN     NUMBER      DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_reason                            IN     VARCHAR2    DEFAULT NULL,
    x_attribute_category                IN     VARCHAR2    DEFAULT NULL,
    x_attribute1                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute2                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute3                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute4                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute5                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute6                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute7                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute8                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute9                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute10                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute11                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute12                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute13                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute14                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute15                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute16                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute17                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute18                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute19                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute20                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_gl_date                           IN     DATE        DEFAULT NULL
  );

END igs_fi_refund_int_pkg;

 

/
