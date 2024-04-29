--------------------------------------------------------
--  DDL for Package IGF_GR_ELEC_STAT_SUM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_ELEC_STAT_SUM_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI11S.pls 115.3 2002/11/28 14:17:57 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ess_id                            IN OUT NOCOPY NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_acct_schedule_number              IN     VARCHAR2,
    x_acct_schedule_date                IN     DATE,
    x_prev_obligation_amt               IN     NUMBER,
    x_obligation_adj_amt                IN     NUMBER,
    x_curr_obligation_amt               IN     NUMBER,
    x_prev_obligation_pymt_amt          IN     NUMBER,
    x_obligation_pymt_adj_amt           IN     NUMBER,
    x_curr_obligation_pymt_amt          IN     NUMBER,
    x_ytd_total_recp                    IN     NUMBER,
    x_ytd_accepted_disb_amt             IN     NUMBER,
    x_ytd_posted_disb_amt               IN     NUMBER,
    x_ytd_admin_cost_allowance          IN     NUMBER,
    x_caps_drwn_dn_pymts                IN     NUMBER,
    x_gaps_last_date                    IN     DATE,
    x_last_pymt_number                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ess_id                            IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_acct_schedule_number              IN     VARCHAR2,
    x_acct_schedule_date                IN     DATE,
    x_prev_obligation_amt               IN     NUMBER,
    x_obligation_adj_amt                IN     NUMBER,
    x_curr_obligation_amt               IN     NUMBER,
    x_prev_obligation_pymt_amt          IN     NUMBER,
    x_obligation_pymt_adj_amt           IN     NUMBER,
    x_curr_obligation_pymt_amt          IN     NUMBER,
    x_ytd_total_recp                    IN     NUMBER,
    x_ytd_accepted_disb_amt             IN     NUMBER,
    x_ytd_posted_disb_amt               IN     NUMBER,
    x_ytd_admin_cost_allowance          IN     NUMBER,
    x_caps_drwn_dn_pymts                IN     NUMBER,
    x_gaps_last_date                    IN     DATE,
    x_last_pymt_number                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ess_id                            IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_acct_schedule_number              IN     VARCHAR2,
    x_acct_schedule_date                IN     DATE,
    x_prev_obligation_amt               IN     NUMBER,
    x_obligation_adj_amt                IN     NUMBER,
    x_curr_obligation_amt               IN     NUMBER,
    x_prev_obligation_pymt_amt          IN     NUMBER,
    x_obligation_pymt_adj_amt           IN     NUMBER,
    x_curr_obligation_pymt_amt          IN     NUMBER,
    x_ytd_total_recp                    IN     NUMBER,
    x_ytd_accepted_disb_amt             IN     NUMBER,
    x_ytd_posted_disb_amt               IN     NUMBER,
    x_ytd_admin_cost_allowance          IN     NUMBER,
    x_caps_drwn_dn_pymts                IN     NUMBER,
    x_gaps_last_date                    IN     DATE,
    x_last_pymt_number                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ess_id                            IN OUT NOCOPY NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_acct_schedule_number              IN     VARCHAR2,
    x_acct_schedule_date                IN     DATE,
    x_prev_obligation_amt               IN     NUMBER,
    x_obligation_adj_amt                IN     NUMBER,
    x_curr_obligation_amt               IN     NUMBER,
    x_prev_obligation_pymt_amt          IN     NUMBER,
    x_obligation_pymt_adj_amt           IN     NUMBER,
    x_curr_obligation_pymt_amt          IN     NUMBER,
    x_ytd_total_recp                    IN     NUMBER,
    x_ytd_accepted_disb_amt             IN     NUMBER,
    x_ytd_posted_disb_amt               IN     NUMBER,
    x_ytd_admin_cost_allowance          IN     NUMBER,
    x_caps_drwn_dn_pymts                IN     NUMBER,
    x_gaps_last_date                    IN     DATE,
    x_last_pymt_number                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ess_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ess_id                            IN     NUMBER      DEFAULT NULL,
    x_rep_pell_id                       IN     VARCHAR2    DEFAULT NULL,
    x_duns_id                           IN     VARCHAR2    DEFAULT NULL,
    x_gaps_award_num                    IN     VARCHAR2    DEFAULT NULL,
    x_acct_schedule_number              IN     VARCHAR2    DEFAULT NULL,
    x_acct_schedule_date                IN     DATE        DEFAULT NULL,
    x_prev_obligation_amt               IN     NUMBER      DEFAULT NULL,
    x_obligation_adj_amt                IN     NUMBER      DEFAULT NULL,
    x_curr_obligation_amt               IN     NUMBER      DEFAULT NULL,
    x_prev_obligation_pymt_amt          IN     NUMBER      DEFAULT NULL,
    x_obligation_pymt_adj_amt           IN     NUMBER      DEFAULT NULL,
    x_curr_obligation_pymt_amt          IN     NUMBER      DEFAULT NULL,
    x_ytd_total_recp                    IN     NUMBER      DEFAULT NULL,
    x_ytd_accepted_disb_amt             IN     NUMBER      DEFAULT NULL,
    x_ytd_posted_disb_amt               IN     NUMBER      DEFAULT NULL,
    x_ytd_admin_cost_allowance          IN     NUMBER      DEFAULT NULL,
    x_caps_drwn_dn_pymts                IN     NUMBER      DEFAULT NULL,
    x_gaps_last_date                    IN     DATE        DEFAULT NULL,
    x_last_pymt_number                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_gr_elec_stat_sum_pkg;

 

/
