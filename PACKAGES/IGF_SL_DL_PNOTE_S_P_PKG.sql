--------------------------------------------------------
--  DDL for Package IGF_SL_DL_PNOTE_S_P_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DL_PNOTE_S_P_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI29S.pls 115.4 2002/11/28 14:28:11 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pnsp_id                           IN OUT NOCOPY NUMBER,
    x_batch_seq_num                     IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_s_ssn                             IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_phone                           IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_pnsp_id                           IN     NUMBER,
    x_batch_seq_num                     IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_s_ssn                             IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_phone                           IN     VARCHAR2,
    x_status                            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_pnsp_id                           IN     NUMBER,
    x_batch_seq_num                     IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_s_ssn                             IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_phone                           IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_pnsp_id                           IN OUT NOCOPY NUMBER,
    x_batch_seq_num                     IN     NUMBER,
    x_loan_id                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_s_ssn                             IN     VARCHAR2,
    x_s_first_name                      IN     VARCHAR2,
    x_s_last_name                       IN     VARCHAR2,
    x_s_middle_name                     IN     VARCHAR2,
    x_s_date_of_birth                   IN     DATE,
    x_s_license_num                     IN     VARCHAR2,
    x_s_license_state                   IN     VARCHAR2,
    x_s_permt_addr1                     IN     VARCHAR2,
    x_s_permt_addr2                     IN     VARCHAR2,
    x_s_permt_city                      IN     VARCHAR2,
    x_s_permt_state                     IN     VARCHAR2,
    x_s_permt_zip                       IN     VARCHAR2,
    x_s_email_addr                      IN     VARCHAR2,
    x_s_phone                           IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_pnsp_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sl_loans (
    x_loan_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_pnsp_id                           IN     NUMBER      DEFAULT NULL,
    x_batch_seq_num                     IN     NUMBER      DEFAULT NULL,
    x_loan_id                           IN     NUMBER      DEFAULT NULL,
    x_loan_number                       IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_s_ssn                             IN     VARCHAR2    DEFAULT NULL,
    x_s_first_name                      IN     VARCHAR2    DEFAULT NULL,
    x_s_last_name                       IN     VARCHAR2    DEFAULT NULL,
    x_s_middle_name                     IN     VARCHAR2    DEFAULT NULL,
    x_s_date_of_birth                   IN     DATE        DEFAULT NULL,
    x_s_license_num                     IN     VARCHAR2    DEFAULT NULL,
    x_s_license_state                   IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_addr1                     IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_addr2                     IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_city                      IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_state                     IN     VARCHAR2    DEFAULT NULL,
    x_s_permt_zip                       IN     VARCHAR2    DEFAULT NULL,
    x_s_email_addr                      IN     VARCHAR2    DEFAULT NULL,
    x_s_phone                           IN     VARCHAR2    DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_dl_pnote_s_p_pkg;

 

/
