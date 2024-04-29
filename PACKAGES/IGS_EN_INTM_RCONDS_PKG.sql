--------------------------------------------------------
--  DDL for Package IGS_EN_INTM_RCONDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_INTM_RCONDS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI80S.pls 120.0 2006/04/10 04:55:08 bdeviset noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_return_condition                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_flag                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_return_condition                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_flag                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_return_condition                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_flag                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_return_condition                          IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_flag                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_return_condition                          IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_flag                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

 FUNCTION get_pk_for_validation (
    x_return_condition                          IN     VARCHAR2
  ) RETURN BOOLEAN;

END igs_en_intm_rconds_pkg;

 

/
