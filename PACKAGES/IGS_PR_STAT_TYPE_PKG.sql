--------------------------------------------------------
--  DDL for Package IGS_PR_STAT_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_STAT_TYPE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI32S.pls 115.4 2002/11/29 03:22:50 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_derivation                        IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_derivation                        IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_derivation                        IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_stat_type                         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_derivation                        IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_stat_type                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_stat_type                         IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_derivation                        IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_stat_type_pkg;

 

/
