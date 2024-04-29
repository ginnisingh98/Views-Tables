--------------------------------------------------------
--  DDL for Package IGF_SL_AWD_DISB_LOC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_AWD_DISB_LOC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI24S.pls 120.0 2005/06/01 15:31:21 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_disb_gross_amt                    IN     NUMBER,
    x_fee_1                             IN     NUMBER,
    x_fee_2                             IN     NUMBER,
    x_disb_net_amt                      IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_hold_rel_ind                      IN     VARCHAR2,
    x_fee_paid_1                        IN     NUMBER,
    x_fee_paid_2                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_award (
    x_award_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_num                          IN     NUMBER      DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_fee_1                             IN     NUMBER      DEFAULT NULL,
    x_fee_2                             IN     NUMBER      DEFAULT NULL,
    x_disb_net_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_hold_rel_ind                      IN     VARCHAR2    DEFAULT NULL,
    x_fee_paid_1                        IN     NUMBER      DEFAULT NULL,
    x_fee_paid_2                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE after_dml( p_action  IN VARCHAR2
            ) ;


END igf_sl_awd_disb_loc_pkg;

 

/
