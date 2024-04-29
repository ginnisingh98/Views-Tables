--------------------------------------------------------
--  DDL for Package IGP_AC_ACCOUNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGP_AC_ACCOUNTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPADBS.pls 120.0 2005/06/02 00:41:51 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_account_id                        IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_user_id                           IN     NUMBER,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_account_id                        IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_user_id                           IN     NUMBER,
    x_object_version_number             IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_account_id                        IN     NUMBER,
    x_party_id                          IN     NUMBER,
    x_user_id                           IN     NUMBER,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_account_id                        IN OUT NOCOPY NUMBER,
    x_party_id                          IN     NUMBER,
    x_user_id                           IN     NUMBER,
    x_object_version_number             IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_account_id                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_account_id                        IN     NUMBER      DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_user_id                           IN     NUMBER      DEFAULT NULL,
    x_object_version_number             IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igp_ac_accounts_pkg;

 

/
