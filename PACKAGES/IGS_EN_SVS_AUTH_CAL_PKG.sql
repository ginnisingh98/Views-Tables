--------------------------------------------------------
--  DDL for Package IGS_EN_SVS_AUTH_CAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SVS_AUTH_CAL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI82S.pls 120.0 2006/05/02 01:43:01 amuthu noship $ */

  g_s_last_ovr_step VARCHAR2(30) DEFAULT NULL;
  g_s_last_step_limit NUMBER DEFAULT NULL;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_sevis_auth_id                     IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_svs_auth (
    x_sevis_auth_id                     IN     NUMBER
  );

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sevis_auth_id                     IN     NUMBER      DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_svs_auth_cal_pkg;

 

/
