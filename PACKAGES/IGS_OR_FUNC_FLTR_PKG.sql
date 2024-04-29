--------------------------------------------------------
--  DDL for Package IGS_OR_FUNC_FLTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_OR_FUNC_FLTR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSOI33S.pls 115.2 2002/11/29 01:45:22 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_func_fltr_id                      IN OUT NOCOPY VARCHAR2,
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2,
    x_attr_val_desc                     IN     VARCHAR2,
    x_inst_org_val                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_func_fltr_id                      IN     VARCHAR2,
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2,
    x_attr_val_desc                     IN     VARCHAR2,
    x_inst_org_val                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_func_fltr_id                      IN     VARCHAR2,
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2,
    x_attr_val_desc                     IN     VARCHAR2,
    x_inst_org_val                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_func_fltr_id                      IN OUT NOCOPY VARCHAR2,
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2,
    x_attr_val_desc                     IN     VARCHAR2,
    x_inst_org_val                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_func_fltr_id                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_func_fltr_id                      IN     VARCHAR2    DEFAULT NULL,
    x_func_code                         IN     VARCHAR2    DEFAULT NULL,
    x_attr_type                         IN     VARCHAR2    DEFAULT NULL,
    x_attr_val                          IN     VARCHAR2    DEFAULT NULL,
    x_attr_val_desc                     IN     VARCHAR2    DEFAULT NULL,
    x_inst_org_val                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_or_func_fltr_pkg;

 

/
