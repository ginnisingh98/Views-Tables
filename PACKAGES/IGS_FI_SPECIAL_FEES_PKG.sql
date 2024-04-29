--------------------------------------------------------
--  DDL for Package IGS_FI_SPECIAL_FEES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_SPECIAL_FEES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIE5S.pls 115.1 2003/10/27 05:31:35 pathipat noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_special_fee_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_amt                           IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_s_transaction_type_code           IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_special_fee_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_amt                           IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_s_transaction_type_code           IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_special_fee_id                    IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_amt                           IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_s_transaction_type_code           IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_special_fee_id                    IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_fee_amt                           IN     NUMBER,
    x_transaction_date                  IN     DATE,
    x_s_transaction_type_code           IN     VARCHAR2,
    x_invoice_id                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_special_fee_id       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_usec_sp_fees (
    x_uoo_id      IN  NUMBER,
    x_fee_type    IN  VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_special_fee_id                    IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_fee_amt                           IN     NUMBER      DEFAULT NULL,
    x_transaction_date                  IN     DATE        DEFAULT NULL,
    x_s_transaction_type_code           IN     VARCHAR2    DEFAULT NULL,
    x_invoice_id                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_special_fees_pkg;

 

/
