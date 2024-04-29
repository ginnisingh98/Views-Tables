--------------------------------------------------------
--  DDL for Package IGF_SL_DISB_LOC_HISTORY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_DISB_LOC_HISTORY_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI42S.pls 120.0 2005/06/01 15:10:31 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lodisbh_id                        IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_gross_amt            IN     NUMBER,
    x_origination_fee_amt               IN     NUMBER,
    x_guarantee_fee_amt                 IN     NUMBER,
    x_origination_fee_paid_amt          IN     NUMBER,
    x_guarantee_fee_paid_amt            IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_disbursement_hold_rel_ind         IN     VARCHAR2,
    x_disbursement_net_amt              IN     NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lodisbh_id                        IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_gross_amt            IN     NUMBER,
    x_origination_fee_amt               IN     NUMBER,
    x_guarantee_fee_amt                 IN     NUMBER,
    x_origination_fee_paid_amt          IN     NUMBER,
    x_guarantee_fee_paid_amt            IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_disbursement_hold_rel_ind         IN     VARCHAR2,
    x_disbursement_net_amt              IN     NUMBER,
    x_source_txt                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_lodisbh_id                        IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_gross_amt            IN     NUMBER,
    x_origination_fee_amt               IN     NUMBER,
    x_guarantee_fee_amt                 IN     NUMBER,
    x_origination_fee_paid_amt          IN     NUMBER,
    x_guarantee_fee_paid_amt            IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_disbursement_hold_rel_ind         IN     VARCHAR2,
    x_disbursement_net_amt              IN     NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lodisbh_id                        IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_disbursement_number               IN     NUMBER,
    x_disbursement_gross_amt            IN     NUMBER,
    x_origination_fee_amt               IN     NUMBER,
    x_guarantee_fee_amt                 IN     NUMBER,
    x_origination_fee_paid_amt          IN     NUMBER,
    x_guarantee_fee_paid_amt            IN     NUMBER,
    x_disbursement_date                 IN     DATE,
    x_disbursement_hold_rel_ind         IN     VARCHAR2,
    x_disbursement_net_amt              IN     NUMBER,
    x_source_txt                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

   FUNCTION get_pk_for_validation (
    x_lodisbh_id                          IN     NUMBER
    ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_lodisbh_id                        IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disbursement_number               IN     NUMBER      DEFAULT NULL,
    x_disbursement_gross_amt            IN     NUMBER      DEFAULT NULL,
    x_origination_fee_amt               IN     NUMBER      DEFAULT NULL,
    x_guarantee_fee_amt                 IN     NUMBER      DEFAULT NULL,
    x_origination_fee_paid_amt          IN     NUMBER      DEFAULT NULL,
    x_guarantee_fee_paid_amt            IN     NUMBER      DEFAULT NULL,
    x_disbursement_date                 IN     DATE        DEFAULT NULL,
    x_disbursement_hold_rel_ind         IN     VARCHAR2    DEFAULT NULL,
    x_disbursement_net_amt              IN     NUMBER      DEFAULT NULL,
    x_source_txt                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_disb_loc_history_pkg;

 

/
