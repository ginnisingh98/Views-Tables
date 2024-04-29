--------------------------------------------------------
--  DDL for Package IGF_GR_ELEC_STAT_DET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_GR_ELEC_STAT_DET_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFGI10S.pls 115.3 2002/11/28 14:17:40 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_esd_id                            IN OUT NOCOPY NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_db_cr_flag                        IN     VARCHAR2,
    x_adj_amt                           IN     NUMBER,
    x_gaps_process_date                 IN     DATE,
    x_adj_batch_id                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_esd_id                            IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_db_cr_flag                        IN     VARCHAR2,
    x_adj_amt                           IN     NUMBER,
    x_gaps_process_date                 IN     DATE,
    x_adj_batch_id                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_esd_id                            IN     NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_db_cr_flag                        IN     VARCHAR2,
    x_adj_amt                           IN     NUMBER,
    x_gaps_process_date                 IN     DATE,
    x_adj_batch_id                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_esd_id                            IN OUT NOCOPY NUMBER,
    x_rep_pell_id                       IN     VARCHAR2,
    x_duns_id                           IN     VARCHAR2,
    x_gaps_award_num                    IN     VARCHAR2,
    x_transaction_date                  IN     DATE,
    x_db_cr_flag                        IN     VARCHAR2,
    x_adj_amt                           IN     NUMBER,
    x_gaps_process_date                 IN     DATE,
    x_adj_batch_id                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_esd_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_esd_id                            IN     NUMBER      DEFAULT NULL,
    x_rep_pell_id                       IN     VARCHAR2    DEFAULT NULL,
    x_duns_id                           IN     VARCHAR2    DEFAULT NULL,
    x_gaps_award_num                    IN     VARCHAR2    DEFAULT NULL,
    x_transaction_date                  IN     DATE        DEFAULT NULL,
    x_db_cr_flag                        IN     VARCHAR2    DEFAULT NULL,
    x_adj_amt                           IN     NUMBER      DEFAULT NULL,
    x_gaps_process_date                 IN     DATE        DEFAULT NULL,
    x_adj_batch_id                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_gr_elec_stat_det_pkg;

 

/
