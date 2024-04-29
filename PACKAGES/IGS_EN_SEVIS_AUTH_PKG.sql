--------------------------------------------------------
--  DDL for Package IGS_EN_SEVIS_AUTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SEVIS_AUTH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI66S.pls 115.2 2002/11/28 23:48:47 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sevis_authorization_cd            IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_elgb_override_id                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sevis_authorization_cd            IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_elgb_override_id                  IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sevis_authorization_cd            IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_elgb_override_id                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sevis_authorization_cd            IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_elgb_override_id                  IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_elgb_override_id                  IN     NUMBER,
    x_sevis_authorization_cd            IN     VARCHAR2,
    x_start_dt                          IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_elgb_ovr (
    x_elgb_override_id                  IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sevis_authorization_cd            IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_end_dt                            IN     DATE        DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_elgb_override_id                  IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_sevis_auth_pkg;

 

/
