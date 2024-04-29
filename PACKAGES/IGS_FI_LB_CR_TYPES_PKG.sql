--------------------------------------------------------
--  DDL for Package IGS_FI_LB_CR_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_LB_CR_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSID2S.pls 115.1 2003/06/20 09:39:52 shtatiko noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_bank_cd                           IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_bank_cd                           IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_bank_cd                           IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lockbox_name                      IN     VARCHAR2,
    x_bank_cd                           IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_lockbox_name                      IN     VARCHAR2,
    x_bank_cd                           IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_lockbox_name                      IN     VARCHAR2,
    x_credit_type_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  -- Removed get_fk_igs_fi_lockboxes as Deletion on IGS_FI_LOCBOXES table
  -- Removed get_fk_igs_fi_cr_types_all as deletion is not allowed on IGS_FI_CR_TYPES_ALL table.

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_lockbox_name                      IN     VARCHAR2    DEFAULT NULL,
    x_bank_cd                           IN     VARCHAR2    DEFAULT NULL,
    x_credit_type_id                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_lb_cr_types_pkg;

 

/
