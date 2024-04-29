--------------------------------------------------------
--  DDL for Package IGS_FI_PP_INS_APPLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PP_INS_APPLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIE2S.pls 115.1 2003/09/16 12:25:07 smvk noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_installment_application_id        IN OUT NOCOPY NUMBER,
    x_application_type_code             IN     VARCHAR2,
    x_installment_id                    IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_applied_amt                       IN     NUMBER,
    x_transaction_date                    IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_installment_application_id        IN     NUMBER,
    x_application_type_code             IN     VARCHAR2,
    x_installment_id                    IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_applied_amt                       IN     NUMBER,
    x_transaction_date                    IN     DATE,
    x_link_application_id               IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_installment_application_id        IN     NUMBER,
    x_application_type_code             IN     VARCHAR2,
    x_installment_id                    IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_applied_amt                       IN     NUMBER,
    x_transaction_date                    IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_installment_application_id        IN OUT NOCOPY NUMBER,
    x_application_type_code             IN     VARCHAR2,
    x_installment_id                    IN     NUMBER,
    x_credit_id                         IN     NUMBER,
    x_credit_activity_id                IN     NUMBER,
    x_applied_amt                       IN     NUMBER,
    x_transaction_date                    IN     DATE,
    x_link_application_id               IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_installment_application_id        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_pp_instlmnts (
    x_installment_id                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_installment_application_id        IN     NUMBER      DEFAULT NULL,
    x_application_type_code             IN     VARCHAR2    DEFAULT NULL,
    x_installment_id                    IN     NUMBER      DEFAULT NULL,
    x_credit_id                         IN     NUMBER      DEFAULT NULL,
    x_credit_activity_id                IN     NUMBER      DEFAULT NULL,
    x_applied_amt                       IN     NUMBER      DEFAULT NULL,
    x_transaction_date                    IN     DATE        DEFAULT NULL,
    x_link_application_id               IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_pp_ins_appls_pkg;

 

/
