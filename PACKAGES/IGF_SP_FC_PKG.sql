--------------------------------------------------------
--  DDL for Package IGF_SP_FC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SP_FC_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFPI01S.pls 115.1 2002/11/28 14:29:31 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fee_cls_id                        IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_fee_class                         IN     VARCHAR2,
    x_fee_percent                       IN     NUMBER,
    x_max_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fee_cls_id                        IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_fee_class                         IN     VARCHAR2,
    x_fee_percent                       IN     NUMBER,
    x_max_amount                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fee_cls_id                        IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_fee_class                         IN     VARCHAR2,
    x_fee_percent                       IN     NUMBER,
    x_max_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fee_cls_id                        IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_fee_class                         IN     VARCHAR2,
    x_fee_percent                       IN     NUMBER,
    x_max_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_fee_cls_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_fund_id                           IN     NUMBER,
    x_fee_class                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_fund_mast (
    x_fund_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igs_lookups_view (
    x_fee_class                           IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fee_cls_id                        IN     NUMBER      DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_fee_class                         IN     VARCHAR2    DEFAULT NULL,
    x_fee_percent                       IN     NUMBER      DEFAULT NULL,
    x_max_amount                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sp_fc_pkg;

 

/
