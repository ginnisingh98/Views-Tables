--------------------------------------------------------
--  DDL for Package IGF_SL_LENDER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_LENDER_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI01S.pls 115.6 2003/09/10 05:06:57 veramach ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_lender_id                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_duns_lender_id                    IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_lender_id                         IN     VARCHAR2
  ) RETURN BOOLEAN;

    FUNCTION get_uk_for_validation (
    x_party_id                           IN     NUMBER
  ) RETURN BOOLEAN;
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 3-SEP-2003
  --
  --Purpose:
  --   Check uniqueness of all unique key fields
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_lender_id                         IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_duns_lender_id                    IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_enabled                           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_lender_pkg;

 

/
