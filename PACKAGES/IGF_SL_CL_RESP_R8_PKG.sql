--------------------------------------------------------
--  DDL for Package IGF_SL_CL_RESP_R8_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_RESP_R8_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI23S.pls 120.1 2006/08/08 06:26:37 akomurav noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clrp1_id                          IN     NUMBER,
    x_clrp8_id                          IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_gross_amt                    IN     NUMBER,
    x_orig_fee                          IN     NUMBER,
    x_guarantee_fee                     IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_disb_hold_rel_ind                 IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_guarnt_fee_paid                   IN     NUMBER,
    x_orig_fee_paid                     IN     NUMBER,
    x_resp_record_status                IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2    DEFAULT NULL,
    x_layout_version_code_txt           IN     VARCHAR2    DEFAULT NULL,
    x_record_code_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_direct_to_borr_flag               IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_clrp1_id                          IN     NUMBER,
    x_clrp8_id                          IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_gross_amt                    IN     NUMBER,
    x_orig_fee                          IN     NUMBER,
    x_guarantee_fee                     IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_disb_hold_rel_ind                 IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_guarnt_fee_paid                   IN     NUMBER,
    x_orig_fee_paid                     IN     NUMBER,
    x_resp_record_status                IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2    DEFAULT NULL,
    x_layout_version_code_txt           IN     VARCHAR2    DEFAULT NULL,
    x_record_code_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_clrp1_id                          IN     NUMBER,
    x_clrp8_id                          IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_gross_amt                    IN     NUMBER,
    x_orig_fee                          IN     NUMBER,
    x_guarantee_fee                     IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_disb_hold_rel_ind                 IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_guarnt_fee_paid                   IN     NUMBER,
    x_orig_fee_paid                     IN     NUMBER,
    x_resp_record_status                IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2    DEFAULT NULL,
    x_layout_version_code_txt           IN     VARCHAR2    DEFAULT NULL,
    x_record_code_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_direct_to_borr_flag               IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clrp1_id                          IN     NUMBER,
    x_clrp8_id                          IN     NUMBER,
    x_disb_date                         IN     DATE,
    x_disb_gross_amt                    IN     NUMBER,
    x_orig_fee                          IN     NUMBER,
    x_guarantee_fee                     IN     NUMBER,
    x_net_disb_amt                      IN     NUMBER,
    x_disb_hold_rel_ind                 IN     VARCHAR2,
    x_disb_status                       IN     VARCHAR2,
    x_guarnt_fee_paid                   IN     NUMBER,
    x_orig_fee_paid                     IN     NUMBER,
    x_resp_record_status                IN     VARCHAR2,
    x_layout_owner_code_txt             IN     VARCHAR2    DEFAULT NULL,
    x_layout_version_code_txt           IN     VARCHAR2    DEFAULT NULL,
    x_record_code_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_direct_to_borr_flag               IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_clrp1_id                          IN     NUMBER,
    x_clrp8_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sl_cl_resp_r1 (
    x_clrp1_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_clrp1_id                          IN     NUMBER      DEFAULT NULL,
    x_clrp8_id                          IN     NUMBER      DEFAULT NULL,
    x_disb_date                         IN     DATE        DEFAULT NULL,
    x_disb_gross_amt                    IN     NUMBER      DEFAULT NULL,
    x_orig_fee                          IN     NUMBER      DEFAULT NULL,
    x_guarantee_fee                     IN     NUMBER      DEFAULT NULL,
    x_net_disb_amt                      IN     NUMBER      DEFAULT NULL,
    x_disb_hold_rel_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_disb_status                       IN     VARCHAR2    DEFAULT NULL,
    x_guarnt_fee_paid                   IN     NUMBER      DEFAULT NULL,
    x_orig_fee_paid                     IN     NUMBER      DEFAULT NULL,
    x_resp_record_status                IN     VARCHAR2    DEFAULT NULL,
    x_layout_owner_code_txt             IN     VARCHAR2    DEFAULT NULL,
    x_layout_version_code_txt           IN     VARCHAR2    DEFAULT NULL,
    x_record_code_txt                   IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_direct_to_borr_flag               IN     VARCHAR2    DEFAULT NULL
  );

END igf_sl_cl_resp_r8_pkg;

 

/
