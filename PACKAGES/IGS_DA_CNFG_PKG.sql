--------------------------------------------------------
--  DDL for Package IGS_DA_CNFG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_DA_CNFG_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSKI45S.pls 115.0 2003/04/15 09:17:45 ddey noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_responsibility_name               IN     VARCHAR2,
    x_access_level                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_responsibility_name               IN     VARCHAR2,
    x_access_level                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_responsibility_name               IN     VARCHAR2,
    x_access_level                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_request_type_id                   IN     NUMBER,
    x_responsibility_name               IN     VARCHAR2,
    x_access_level                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_request_type_id                   IN     NUMBER,
    x_responsibility_name               IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_da_cnfg_req_typ (
    x_request_type_id                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_request_type_id                   IN     NUMBER      DEFAULT NULL,
    x_responsibility_name               IN     VARCHAR2    DEFAULT NULL,
    x_access_level                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_da_cnfg_pkg;

 

/
