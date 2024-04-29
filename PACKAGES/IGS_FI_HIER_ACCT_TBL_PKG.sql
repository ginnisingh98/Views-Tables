--------------------------------------------------------
--  DDL for Package IGS_FI_HIER_ACCT_TBL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_HIER_ACCT_TBL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIA9S.pls 115.4 2002/11/29 04:03:15 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acct_tbl_id                       IN OUT NOCOPY NUMBER,
    x_acct_hier_id                      IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_entity_type_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_acct_tbl_id                       IN     NUMBER,
    x_acct_hier_id                      IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_entity_type_code                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_acct_tbl_id                       IN     NUMBER,
    x_acct_hier_id                      IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_entity_type_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acct_tbl_id                       IN OUT NOCOPY NUMBER,
    x_acct_hier_id                      IN     NUMBER,
    x_order_sequence                    IN     NUMBER,
    x_entity_type_code                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_acct_tbl_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_hier_accounts (
    x_acct_hier_id                      IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_acct_tbl_id                       IN     NUMBER      DEFAULT NULL,
    x_acct_hier_id                      IN     NUMBER      DEFAULT NULL,
    x_order_sequence                    IN     NUMBER      DEFAULT NULL,
    x_entity_type_code                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_hier_acct_tbl_pkg;

 

/
