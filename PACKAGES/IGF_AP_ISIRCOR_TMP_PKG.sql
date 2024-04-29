--------------------------------------------------------
--  DDL for Package IGF_AP_ISIRCOR_TMP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_ISIRCOR_TMP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI74S.pls 115.1 2002/11/28 14:06:46 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ict_id                            IN OUT NOCOPY VARCHAR2,
    x_corr_text                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action 				IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ict_id                            IN     VARCHAR2    DEFAULT NULL,
    x_corr_text                         IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_ap_isircor_tmp_pkg;

 

/
