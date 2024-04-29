--------------------------------------------------------
--  DDL for Package IGS_TR_TSTP_GRP_LMT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_TR_TSTP_GRP_LMT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSTI14S.pls 115.1 2002/11/29 04:17:41 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tracking_type                     IN     VARCHAR2,
    x_step_group_id                     IN     NUMBER,
    x_step_group_limit                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_tracking_type                     IN     VARCHAR2,
    x_step_group_id                     IN     NUMBER,
    x_step_group_limit                  IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_tracking_type                     IN     VARCHAR2,
    x_step_group_id                     IN     NUMBER,
    x_step_group_limit                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_tracking_type                     IN     VARCHAR2,
    x_step_group_id                     IN     NUMBER,
    x_step_group_limit                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_tracking_type                     IN     VARCHAR2,
    x_step_group_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_tracking_type                     IN     VARCHAR2    DEFAULT NULL,
    x_step_group_id                     IN     NUMBER      DEFAULT NULL,
    x_step_group_limit                  IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_tr_tstp_grp_lmt_pkg;

 

/
