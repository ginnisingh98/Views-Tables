--------------------------------------------------------
--  DDL for Package IGS_EN_SPLACE_SUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_SPLACE_SUPS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI74S.pls 115.0 2003/11/04 07:11:39 rvangala noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_splacement_id                     IN     NUMBER,
    x_supervisor_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_splacement_id                     IN     NUMBER,
    x_supervisor_id                     IN     NUMBER
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_splacement_id                     IN     NUMBER,
    x_supervisor_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_splacement_id                     IN     NUMBER      DEFAULT NULL,
    x_supervisor_id                     IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_splace_sups_pkg;

 

/
