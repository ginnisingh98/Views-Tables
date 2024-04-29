--------------------------------------------------------
--  DDL for Package IGS_FI_IMP_CHGS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_IMP_CHGS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSI84S.pls 115.8 2003/02/12 09:53:48 pathipat ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_import_charges_id                 IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_import_charges_id                 IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_import_charges_id                 IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_import_charges_id                 IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_import_charges_id                 IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_transaction_type                  IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_transaction_type IN VARCHAR2
  );

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_import_charges_id                 IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_transaction_type                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_imp_chgs_pkg;

 

/
