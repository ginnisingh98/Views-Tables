--------------------------------------------------------
--  DDL for Package IGF_SP_STD_UNIT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SP_STD_UNIT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFPI07S.pls 115.1 2002/11/28 14:30:57 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fee_cls_unit_id                   IN OUT NOCOPY NUMBER,
    x_fee_cls_prg_id                    IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_max_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_fee_cls_unit_id                   IN     NUMBER,
    x_fee_cls_prg_id                    IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_max_amount                        IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_fee_cls_unit_id                   IN     NUMBER,
    x_fee_cls_prg_id                    IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_max_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fee_cls_unit_id                   IN OUT NOCOPY NUMBER,
    x_fee_cls_prg_id                    IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_max_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_fee_cls_unit_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_unit_cd                           IN     VARCHAR2,
    x_fee_cls_prg_id                    IN     NUMBER,
    x_version_number                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_sp_std_prg (
    x_fee_cls_prg_id                    IN     NUMBER
  );

  PROCEDURE get_fk_igs_ps_unit_ver (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fee_cls_unit_id                   IN     NUMBER      DEFAULT NULL,
    x_fee_cls_prg_id                    IN     NUMBER      DEFAULT NULL,
    x_unit_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_max_amount                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sp_std_unit_pkg;

 

/
