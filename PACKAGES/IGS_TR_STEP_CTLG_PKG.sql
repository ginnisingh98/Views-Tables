--------------------------------------------------------
--  DDL for Package IGS_TR_STEP_CTLG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_STEP_CTLG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSTI13S.pls 115.6 2003/05/09 05:04:22 pkpatel ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_step_catalog_id                   IN OUT NOCOPY NUMBER,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_action_days                       IN     NUMBER,
    x_s_tracking_step_type              IN     VARCHAR2,
    x_publish_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_step_catalog_id                   IN     NUMBER,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_action_days                       IN     NUMBER,
    x_s_tracking_step_type              IN     VARCHAR2,
    x_publish_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_step_catalog_id                   IN     NUMBER,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_action_days                       IN     NUMBER,
    x_s_tracking_step_type              IN     VARCHAR2,
    x_publish_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_step_catalog_id                   IN OUT NOCOPY NUMBER,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_action_days                       IN     NUMBER,
    x_s_tracking_step_type              IN     VARCHAR2,
    x_publish_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_step_catalog_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_step_catalog_cd                   IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_step_catalog_id                   IN     NUMBER      DEFAULT NULL,
    x_step_catalog_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_action_days                       IN     NUMBER      DEFAULT NULL,
    x_s_tracking_step_type              IN     VARCHAR2    DEFAULT NULL,
    x_publish_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_tr_step_ctlg_pkg;

 

/