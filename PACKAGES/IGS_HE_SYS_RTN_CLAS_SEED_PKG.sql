--------------------------------------------------------
--  DDL for Package IGS_HE_SYS_RTN_CLAS_SEED_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_SYS_RTN_CLAS_SEED_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI29S.pls 115.1 2002/11/29 04:42:51 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_return_class_type          IN OUT NOCOPY VARCHAR2,
    x_system_return_class_recid         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_system_return_class_type          IN     VARCHAR2,
    x_system_return_class_recid         IN     VARCHAR2,
    x_description                       IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_system_return_class_type          IN     VARCHAR2,
    x_system_return_class_recid         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_return_class_type          IN OUT NOCOPY VARCHAR2,
    x_system_return_class_recid         IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_system_return_class_type          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_system_return_class_type          IN     VARCHAR2    DEFAULT NULL,
    x_system_return_class_recid         IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_sys_rtn_clas_seed_pkg;

 

/
