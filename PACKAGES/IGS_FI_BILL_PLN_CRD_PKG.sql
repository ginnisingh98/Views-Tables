--------------------------------------------------------
--  DDL for Package IGS_FI_BILL_PLN_CRD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_BILL_PLN_CRD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIC4S.pls 115.2 2002/11/29 04:07:03 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_pln_credit_date                   IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_pln_credit_amount                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_bill_desc                         IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_pln_credit_date                   IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_pln_credit_amount                 IN     NUMBER,
    x_bill_desc                         IN     VARCHAR2 DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_pln_credit_date                   IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_pln_credit_amount                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_bill_desc                         IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_bill_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_pln_credit_date                   IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_fee_cal_type                      IN     VARCHAR2,
    x_fee_ci_sequence_number            IN     NUMBER,
    x_pln_credit_amount                 IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_bill_desc                         IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_bill_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_bill (
    x_bill_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_fund_mast (
    x_fund_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_awd_disb (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_pln_credit_date                   IN     DATE        DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_fee_cal_type                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_ci_sequence_number            IN     NUMBER      DEFAULT NULL,
    x_pln_credit_amount                 IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_bill_desc                         IN     VARCHAR2    DEFAULT NULL
  );

END igs_fi_bill_pln_crd_pkg;

 

/
