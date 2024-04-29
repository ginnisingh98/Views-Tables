--------------------------------------------------------
--  DDL for Package IGS_EN_SVS_AUTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SVS_AUTH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI66S.pls 120.1 2006/05/02 01:41:32 amuthu noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_sevis_auth_id                     IN OUT NOCOPY NUMBER,
    x_sevis_authorization_no            IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_cancel_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_sevis_authorization_no            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cancel_flag                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_sevis_authorization_no            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cancel_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_sevis_auth_id                     IN OUT NOCOPY NUMBER,
    x_sevis_authorization_no            IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_cancel_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_sevis_auth_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_person_id                         IN     NUMBER,
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sevis_authorization_code          IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_end_dt                            IN     DATE        DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_sevis_auth_id                     IN     NUMBER      DEFAULT NULL,
    x_sevis_authorization_no            IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_cancel_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_svs_auth_pkg;

 

/
