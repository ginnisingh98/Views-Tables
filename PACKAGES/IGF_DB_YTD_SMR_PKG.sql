--------------------------------------------------------
--  DDL for Package IGF_DB_YTD_SMR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_DB_YTD_SMR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFDI10S.pls 115.3 2003/02/26 03:51:37 smvk noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ytds_id                           IN OUT NOCOPY NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_disb_smr_type                     IN     VARCHAR2,
    x_bkd_gross                         IN     NUMBER,
    x_bkd_fee                           IN     NUMBER,
    x_bkd_int_rebate                    IN     NUMBER,
    x_bkd_net                           IN     NUMBER,
    x_unbkd_gross                       IN     NUMBER,
    x_unbkd_fee                         IN     NUMBER,
    x_unbkd_int_rebate                  IN     NUMBER,
    x_unbkd_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2 DEFAULT NULL,
    x_state_code                        IN     VARCHAR2 DEFAULT NULL,
    x_rec_count                         IN     NUMBER   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ytds_id                           IN     NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_disb_smr_type                     IN     VARCHAR2,
    x_bkd_gross                         IN     NUMBER,
    x_bkd_fee                           IN     NUMBER,
    x_bkd_int_rebate                    IN     NUMBER,
    x_bkd_net                           IN     NUMBER,
    x_unbkd_gross                       IN     NUMBER,
    x_unbkd_fee                         IN     NUMBER,
    x_unbkd_int_rebate                  IN     NUMBER,
    x_unbkd_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2 DEFAULT NULL,
    x_state_code                        IN     VARCHAR2 DEFAULT NULL,
    x_rec_count                         IN     NUMBER   DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ytds_id                           IN     NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_disb_smr_type                     IN     VARCHAR2,
    x_bkd_gross                         IN     NUMBER,
    x_bkd_fee                           IN     NUMBER,
    x_bkd_int_rebate                    IN     NUMBER,
    x_bkd_net                           IN     NUMBER,
    x_unbkd_gross                       IN     NUMBER,
    x_unbkd_fee                         IN     NUMBER,
    x_unbkd_int_rebate                  IN     NUMBER,
    x_unbkd_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2 DEFAULT NULL,
    x_state_code                        IN     VARCHAR2 DEFAULT NULL,
    x_rec_count                         IN     NUMBER   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ytds_id                           IN OUT NOCOPY NUMBER,
    x_dl_version                        IN     VARCHAR2,
    x_record_type                       IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_school_code                       IN     VARCHAR2,
    x_stat_end_dt                       IN     DATE,
    x_process_dt                        IN     DATE,
    x_disb_smr_type                     IN     VARCHAR2,
    x_bkd_gross                         IN     NUMBER,
    x_bkd_fee                           IN     NUMBER,
    x_bkd_int_rebate                    IN     NUMBER,
    x_bkd_net                           IN     NUMBER,
    x_unbkd_gross                       IN     NUMBER,
    x_unbkd_fee                         IN     NUMBER,
    x_unbkd_int_rebate                  IN     NUMBER,
    x_unbkd_net                         IN     NUMBER,
    x_region_code                       IN     VARCHAR2 DEFAULT NULL,
    x_state_code                        IN     VARCHAR2 DEFAULT NULL,
    x_rec_count                         IN     NUMBER   DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_ytds_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ytds_id                           IN     NUMBER      DEFAULT NULL,
    x_dl_version                        IN     VARCHAR2    DEFAULT NULL,
    x_record_type                       IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_school_code                       IN     VARCHAR2    DEFAULT NULL,
    x_stat_end_dt                       IN     DATE        DEFAULT NULL,
    x_process_dt                        IN     DATE        DEFAULT NULL,
    x_disb_smr_type                     IN     VARCHAR2    DEFAULT NULL,
    x_bkd_gross                         IN     NUMBER      DEFAULT NULL,
    x_bkd_fee                           IN     NUMBER      DEFAULT NULL,
    x_bkd_int_rebate                    IN     NUMBER      DEFAULT NULL,
    x_bkd_net                           IN     NUMBER      DEFAULT NULL,
    x_unbkd_gross                       IN     NUMBER      DEFAULT NULL,
    x_unbkd_fee                         IN     NUMBER      DEFAULT NULL,
    x_unbkd_int_rebate                  IN     NUMBER      DEFAULT NULL,
    x_unbkd_net                         IN     NUMBER      DEFAULT NULL,
    x_region_code                       IN     VARCHAR2    DEFAULT NULL,
    x_state_code                        IN     VARCHAR2    DEFAULT NULL,
    x_rec_count                         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_db_ytd_smr_pkg;

 

/
