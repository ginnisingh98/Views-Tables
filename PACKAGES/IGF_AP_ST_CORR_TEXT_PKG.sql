--------------------------------------------------------
--  DDL for Package IGF_AP_ST_CORR_TEXT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_ST_CORR_TEXT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI39S.pls 115.3 2002/11/28 14:00:07 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_corsp_id                          IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_custom_text                       IN     VARCHAR2,
    x_run_date                          IN     DATE,
    x_active                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_corsp_id                          IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_custom_text                       IN     VARCHAR2,
    x_run_date                          IN     DATE,
    x_active                            IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_corsp_id                          IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_custom_text                       IN     VARCHAR2,
    x_run_date                          IN     DATE,
    x_active                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_corsp_id                          IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_custom_text                       IN     VARCHAR2,
    x_run_date                          IN     DATE,
    x_active                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_corsp_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_ap_fa_base_rec_all (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_corsp_id                          IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_custom_text                       IN     VARCHAR2    DEFAULT NULL,
    x_run_date                          IN     DATE        DEFAULT NULL,
    x_active                            IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_st_corr_text_pkg;

 

/
