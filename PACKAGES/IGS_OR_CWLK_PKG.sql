--------------------------------------------------------
--  DDL for Package IGS_OR_CWLK_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_CWLK_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOI26S.pls 115.4 2002/11/29 01:43:25 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_crosswalk_id                      IN OUT NOCOPY NUMBER,
    x_institution_code                  IN     VARCHAR2,
    x_institution_name                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_crosswalk_id                      IN     NUMBER,
    x_institution_code                  IN     VARCHAR2,
    x_institution_name                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_crosswalk_id                      IN     NUMBER,
    x_institution_code                  IN     VARCHAR2,
    x_institution_name                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_crosswalk_id                      IN OUT NOCOPY NUMBER,
    x_institution_code                  IN     VARCHAR2,
    x_institution_name                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_crosswalk_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_crosswalk_id                      IN     NUMBER      DEFAULT NULL,
    x_institution_code                  IN     VARCHAR2    DEFAULT NULL,
    x_institution_name                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_or_cwlk_pkg;

 

/
