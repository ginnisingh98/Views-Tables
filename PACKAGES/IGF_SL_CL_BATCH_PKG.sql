--------------------------------------------------------
--  DDL for Package IGF_SL_CL_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_BATCH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI21S.pls 120.0 2005/06/01 15:00:33 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cbth_id                           IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_file_creation_date                IN     DATE,
    x_file_trans_date                   IN     DATE,
    x_file_ident_code                   IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_source_id                         IN     VARCHAR2,
    x_source_non_ed_brc_id              IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_record_count_num                  IN     NUMBER DEFAULT NULL,
    x_total_net_disb_amt                IN     NUMBER DEFAULT NULL,
    x_total_net_eft_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_non_eft_amt             IN     NUMBER DEFAULT NULL,
    x_total_reissue_amt                 IN     NUMBER DEFAULT NULL,
    x_total_cancel_amt                  IN     NUMBER DEFAULT NULL,
    x_total_deficit_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_cancel_amt              IN     NUMBER DEFAULT NULL,
    x_total_net_out_cancel_amt          IN     NUMBER DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cbth_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_file_creation_date                IN     DATE,
    x_file_trans_date                   IN     DATE,
    x_file_ident_code                   IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_source_id                         IN     VARCHAR2,
    x_source_non_ed_brc_id              IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_record_count_num                  IN     NUMBER,
    x_total_net_disb_amt                IN     NUMBER,
    x_total_net_eft_amt                 IN     NUMBER,
    x_total_net_non_eft_amt             IN     NUMBER,
    x_total_reissue_amt                 IN     NUMBER,
    x_total_cancel_amt                  IN     NUMBER,
    x_total_deficit_amt                 IN     NUMBER,
    x_total_net_cancel_amt              IN     NUMBER,
    x_total_net_out_cancel_amt          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_cbth_id                           IN     NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_file_creation_date                IN     DATE,
    x_file_trans_date                   IN     DATE,
    x_file_ident_code                   IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_source_id                         IN     VARCHAR2,
    x_source_non_ed_brc_id              IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_record_count_num                  IN     NUMBER DEFAULT NULL,
    x_total_net_disb_amt                IN     NUMBER DEFAULT NULL,
    x_total_net_eft_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_non_eft_amt             IN     NUMBER DEFAULT NULL,
    x_total_reissue_amt                 IN     NUMBER DEFAULT NULL,
    x_total_cancel_amt                  IN     NUMBER DEFAULT NULL,
    x_total_deficit_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_cancel_amt              IN     NUMBER DEFAULT NULL,
    x_total_net_out_cancel_amt          IN     NUMBER DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cbth_id                           IN OUT NOCOPY NUMBER,
    x_batch_id                          IN     VARCHAR2,
    x_file_creation_date                IN     DATE,
    x_file_trans_date                   IN     DATE,
    x_file_ident_code                   IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_source_id                         IN     VARCHAR2,
    x_source_non_ed_brc_id              IN     VARCHAR2,
    x_send_resp                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_record_count_num                  IN     NUMBER DEFAULT NULL,
    x_total_net_disb_amt                IN     NUMBER DEFAULT NULL,
    x_total_net_eft_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_non_eft_amt             IN     NUMBER DEFAULT NULL,
    x_total_reissue_amt                 IN     NUMBER DEFAULT NULL,
    x_total_cancel_amt                  IN     NUMBER DEFAULT NULL,
    x_total_deficit_amt                 IN     NUMBER DEFAULT NULL,
    x_total_net_cancel_amt              IN     NUMBER DEFAULT NULL,
    x_total_net_out_cancel_amt          IN     NUMBER DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_cbth_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_cbth_id                           IN     NUMBER      DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_file_creation_date                IN     DATE        DEFAULT NULL,
    x_file_trans_date                   IN     DATE        DEFAULT NULL,
    x_file_ident_code                   IN     VARCHAR2    DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2    DEFAULT NULL,
    x_source_id                         IN     VARCHAR2    DEFAULT NULL,
    x_source_non_ed_brc_id              IN     VARCHAR2    DEFAULT NULL,
    x_send_resp                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_record_count_num                  IN     NUMBER      DEFAULT NULL,
    x_total_net_disb_amt                IN     NUMBER      DEFAULT NULL,
    x_total_net_eft_amt                 IN     NUMBER      DEFAULT NULL,
    x_total_net_non_eft_amt             IN     NUMBER      DEFAULT NULL,
    x_total_reissue_amt                 IN     NUMBER      DEFAULT NULL,
    x_total_cancel_amt                  IN     NUMBER      DEFAULT NULL,
    x_total_deficit_amt                 IN     NUMBER      DEFAULT NULL,
    x_total_net_cancel_amt              IN     NUMBER      DEFAULT NULL,
    x_total_net_out_cancel_amt          IN     NUMBER      DEFAULT NULL
  );

END igf_sl_cl_batch_pkg;

 

/
