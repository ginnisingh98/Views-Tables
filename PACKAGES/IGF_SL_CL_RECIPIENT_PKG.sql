--------------------------------------------------------
--  DDL for Package IGF_SL_CL_RECIPIENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_CL_RECIPIENT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI06S.pls 120.1 2006/04/19 08:11:58 bvisvana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rcpt_id                           IN OUT NOCOPY NUMBER,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_relationship_cd_desc              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_preferred_flag                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_rcpt_id                           IN     NUMBER,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_relationship_cd_desc              IN     VARCHAR2,
    x_preferred_flag                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_rcpt_id                           IN     NUMBER,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_relationship_cd_desc              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_preferred_flag                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_rcpt_id                           IN OUT NOCOPY NUMBER,
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recipient_type                    IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_enabled                           IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2,
    x_relationship_cd_desc              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_preferred_flag                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_rcpt_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_recipient_id                      IN     VARCHAR2,
    x_recip_non_ed_brc_id               IN     VARCHAR2,
    x_relationship_cd                   IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk1_for_validation (
    x_relationship_cd                   IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igf_sl_lender (
    x_lender_id                         IN     VARCHAR2
  );

  PROCEDURE get_fk_igf_sl_lender_brc (
    x_lender_id                         IN     VARCHAR2,
    x_lend_non_ed_brc_id                IN     VARCHAR2
  );

  PROCEDURE get_fk_igf_sl_guarantor (
    x_guarantor_id                      IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_rcpt_id                           IN     NUMBER      DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2    DEFAULT NULL,
    x_lend_non_ed_brc_id                IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recipient_id                      IN     VARCHAR2    DEFAULT NULL,
    x_recipient_type                    IN     VARCHAR2    DEFAULT NULL,
    x_recip_non_ed_brc_id               IN     VARCHAR2    DEFAULT NULL,
    x_enabled                           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_relationship_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_relationship_cd_desc              IN     VARCHAR2    DEFAULT NULL,
    x_preferred_flag                    IN     VARCHAR2    DEFAULT NULL
  );

END igf_sl_cl_recipient_pkg;

 

/
