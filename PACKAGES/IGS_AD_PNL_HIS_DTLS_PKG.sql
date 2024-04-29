--------------------------------------------------------
--  DDL for Package IGS_AD_PNL_HIS_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_PNL_HIS_DTLS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIH4S.pls 115.1 2003/06/20 18:39:22 nsinha noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE,
    x_final_decision_code              IN     VARCHAR2,
    x_final_decision_type              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE,
    x_final_decision_code              IN     VARCHAR2,
    x_final_decision_type              IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE,
    x_final_decision_code              IN     VARCHAR2,
    x_final_decision_type              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE,
    x_final_decision_code              IN     VARCHAR2,
    x_final_decision_type              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ad_panel_dtls (
    x_panel_dtls_id                     IN     NUMBER
  );

  PROCEDURE get_ufk_igs_ad_code_classes (
    x_name                              IN     VARCHAR2,
    x_class                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_panel_dtls_id                     IN     NUMBER      DEFAULT NULL,
    x_history_date                      IN     DATE        DEFAULT NULL,
    x_final_decision_code              IN     VARCHAR2    DEFAULT NULL,
    x_final_decision_type              IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_pnl_his_dtls_pkg;

 

/
