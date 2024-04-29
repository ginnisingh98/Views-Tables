--------------------------------------------------------
--  DDL for Package IGF_AW_AWD_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_AWD_HIST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI69S.pls 120.0 2005/06/01 14:37:50 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_awdh_id                           IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_tran_date                         IN     DATE,
    x_operation_txt                     IN     VARCHAR2,
    x_offered_amt_num                   IN     NUMBER,
    x_off_adj_num                       IN     NUMBER,
    x_accepted_amt_num                  IN     NUMBER,
    x_acc_adj_num                       IN     NUMBER,
    x_paid_amt_num                      IN     NUMBER,
    x_paid_adj_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_awdh_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_tran_date                         IN     DATE,
    x_operation_txt                     IN     VARCHAR2,
    x_offered_amt_num                   IN     NUMBER,
    x_off_adj_num                       IN     NUMBER,
    x_accepted_amt_num                  IN     NUMBER,
    x_acc_adj_num                       IN     NUMBER,
    x_paid_amt_num                      IN     NUMBER,
    x_paid_adj_num                      IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_awdh_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_tran_date                         IN     DATE,
    x_operation_txt                     IN     VARCHAR2,
    x_offered_amt_num                   IN     NUMBER,
    x_off_adj_num                       IN     NUMBER,
    x_accepted_amt_num                  IN     NUMBER,
    x_acc_adj_num                       IN     NUMBER,
    x_paid_amt_num                      IN     NUMBER,
    x_paid_adj_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_awdh_id                           IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_tran_date                         IN     DATE,
    x_operation_txt                     IN     VARCHAR2,
    x_offered_amt_num                   IN     NUMBER,
    x_off_adj_num                       IN     NUMBER,
    x_accepted_amt_num                  IN     NUMBER,
    x_acc_adj_num                       IN     NUMBER,
    x_paid_amt_num                      IN     NUMBER,
    x_paid_adj_num                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_awdh_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_awdh_id                           IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_tran_date                         IN     DATE        DEFAULT NULL,
    x_operation_txt                     IN     VARCHAR2    DEFAULT NULL,
    x_offered_amt_num                   IN     NUMBER      DEFAULT NULL,
    x_off_adj_num                       IN     NUMBER      DEFAULT NULL,
    x_accepted_amt_num                  IN     NUMBER      DEFAULT NULL,
    x_acc_adj_num                       IN     NUMBER      DEFAULT NULL,
    x_paid_amt_num                      IN     NUMBER      DEFAULT NULL,
    x_paid_adj_num                      IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_awd_hist_pkg;

 

/
