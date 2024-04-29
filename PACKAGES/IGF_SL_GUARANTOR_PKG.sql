--------------------------------------------------------
--  DDL for Package IGF_SL_GUARANTOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SL_GUARANTOR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFLI03S.pls 115.5 2003/09/10 05:01:25 veramach ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_guarantor_id                      IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_duns_guarnt_id                    IN     VARCHAR2,
    x_party_id                          IN     NUMBER,
    x_enabled                           IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_guarantor_id                      IN     VARCHAR2
  ) RETURN BOOLEAN;

    FUNCTION get_uk_for_validation (
    x_party_id                           IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_guarantor_id                      IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_duns_guarnt_id                    IN     VARCHAR2    DEFAULT NULL,
    x_party_id                          IN     NUMBER      DEFAULT NULL,
    x_enabled                           IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_sl_guarantor_pkg;

 

/
