--------------------------------------------------------
--  DDL for Package IGS_UC_HRC_TIMSTMPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_HRC_TIMSTMPS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI48S.pls 120.0 2005/06/01 23:48:59 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_view_name                         IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_timestamp                         IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_view_name                         IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_timestamp                         IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_view_name                         IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_timestamp                         IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_view_name                         IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER,
    x_timestamp                         IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_view_name                         IN     VARCHAR2,
    x_ucas_cycle                        IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_view_name                         IN     VARCHAR2    DEFAULT NULL,
    x_ucas_cycle                        IN     NUMBER      DEFAULT NULL,
    x_timestamp                         IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_hrc_timstmps_pkg;

 

/
