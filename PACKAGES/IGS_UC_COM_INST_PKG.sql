--------------------------------------------------------
--  DDL for Package IGS_UC_COM_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_COM_INST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI09S.pls 115.4 2003/06/11 10:30:48 smaddali noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst                              IN OUT NOCOPY VARCHAR2,
    x_inst_code                         IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_ucas                              IN     VARCHAR2,
    x_gttr                              IN     VARCHAR2,
    x_swas                              IN     VARCHAR2,
    x_nmas                              IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_inst                              IN     VARCHAR2,
    x_inst_code                         IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_ucas                              IN     VARCHAR2,
    x_gttr                              IN     VARCHAR2,
    x_swas                              IN     VARCHAR2,
    x_nmas                              IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_inst                              IN     VARCHAR2,
    x_inst_code                         IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_ucas                              IN     VARCHAR2,
    x_gttr                              IN     VARCHAR2,
    x_swas                              IN     VARCHAR2,
    x_nmas                              IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst                              IN OUT NOCOPY VARCHAR2,
    x_inst_code                         IN     VARCHAR2,
    x_inst_name                         IN     VARCHAR2,
    x_ucas                              IN     VARCHAR2,
    x_gttr                              IN     VARCHAR2,
    x_swas                              IN     VARCHAR2,
    x_nmas                              IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_inst                              IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inst                              IN     VARCHAR2    DEFAULT NULL,
    x_inst_code                         IN     VARCHAR2    DEFAULT NULL,
    x_inst_name                         IN     VARCHAR2    DEFAULT NULL,
    x_ucas                              IN     VARCHAR2    DEFAULT NULL,
    x_gttr                              IN     VARCHAR2    DEFAULT NULL,
    x_swas                              IN     VARCHAR2    DEFAULT NULL,
    x_nmas                              IN     VARCHAR2    DEFAULT NULL,
    x_imported                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_com_inst_pkg;

 

/
