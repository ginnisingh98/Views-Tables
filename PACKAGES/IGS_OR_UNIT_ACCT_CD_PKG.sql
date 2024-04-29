--------------------------------------------------------
--  DDL for Package IGS_OR_UNIT_ACCT_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_UNIT_ACCT_CD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOI31S.pls 115.5 2003/02/17 05:38:54 pathipat noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_account_cd_id                 IN OUT NOCOPY NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_rev_account_cd                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_org_account_cd_id                 IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_rev_account_cd                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_org_account_cd_id                 IN     NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_rev_account_cd                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_org_account_cd_id                 IN OUT NOCOPY NUMBER,
    x_org_unit_cd                       IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_rev_account_cd                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_org_account_cd_id                 IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_org_account_cd_id                 IN     NUMBER      DEFAULT NULL,
    x_org_unit_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_rev_account_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_or_unit_acct_cd_pkg;

 

/
