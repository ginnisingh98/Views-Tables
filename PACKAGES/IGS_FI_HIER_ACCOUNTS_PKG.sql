--------------------------------------------------------
--  DDL for Package IGS_FI_HIER_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_HIER_ACCOUNTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIA8S.pls 115.4 2003/03/11 12:54:37 smadathi ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acct_hier_id                      IN OUT NOCOPY NUMBER,
    x_name                              IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_default_flag                      IN     VARCHAR2,
    x_zero_fill_flag                    IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_acct_hier_id                      IN     NUMBER,
    x_name                              IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_default_flag                      IN     VARCHAR2,
    x_zero_fill_flag                    IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_acct_hier_id                      IN     NUMBER,
    x_name                              IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_default_flag                      IN     VARCHAR2,
    x_zero_fill_flag                    IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_acct_hier_id                      IN OUT NOCOPY NUMBER,
    x_name                              IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_default_flag                      IN     VARCHAR2,
    x_zero_fill_flag                    IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_acct_hier_id                      IN     NUMBER
  ) RETURN BOOLEAN;

   FUNCTION get_uk_for_validation (
     x_name                             IN      VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_acct_hier_id                      IN     NUMBER      DEFAULT NULL,
    x_name                              IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_default_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_zero_fill_flag                    IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_hier_accounts_pkg;

 

/
