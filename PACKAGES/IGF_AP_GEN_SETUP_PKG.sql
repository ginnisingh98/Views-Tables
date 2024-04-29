--------------------------------------------------------
--  DDL for Package IGF_AP_GEN_SETUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_GEN_SETUP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI36S.pls 120.1 2005/09/08 14:30:39 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_genst_id                          IN OUT NOCOPY NUMBER,
    x_ssn_required                      IN     VARCHAR2,
    x_auto_na_complete                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_genst_id                          IN     NUMBER,
    x_ssn_required                      IN     VARCHAR2,
    x_auto_na_complete                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_genst_id                          IN     NUMBER,
    x_ssn_required                      IN     VARCHAR2,
    x_auto_na_complete                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_genst_id                          IN OUT NOCOPY NUMBER,
    x_ssn_required                      IN     VARCHAR2,
    x_auto_na_complete                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_genst_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_genst_id                          IN     NUMBER      DEFAULT NULL,
    x_ssn_required                      IN     VARCHAR2    DEFAULT NULL,
    x_auto_na_complete                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_gen_setup_pkg;

 

/
