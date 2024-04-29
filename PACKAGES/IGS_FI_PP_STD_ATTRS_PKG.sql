--------------------------------------------------------
--  DDL for Package IGS_FI_PP_STD_ATTRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PP_STD_ATTRS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIE0S.pls 115.0 2003/08/26 07:08:51 smvk noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_student_plan_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_plan_status_code                  IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_notes                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
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
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_plan_status_code                  IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_notes                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
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
    x_attribute20                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_plan_status_code                  IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_notes                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
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
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_student_plan_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_plan_status_code                  IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_notes                             IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
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
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_student_plan_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_start_date                   IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_student_plan_id                   IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_payment_plan_name                 IN     VARCHAR2    DEFAULT NULL,
    x_plan_start_date                   IN     DATE        DEFAULT NULL,
    x_plan_end_date                     IN     DATE        DEFAULT NULL,
    x_plan_status_code                  IN     VARCHAR2    DEFAULT NULL,
    x_processing_fee_amt                IN     NUMBER      DEFAULT NULL,
    x_processing_fee_type               IN     VARCHAR2    DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_notes                             IN     VARCHAR2    DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
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
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_pp_std_attrs_pkg;

 

/
