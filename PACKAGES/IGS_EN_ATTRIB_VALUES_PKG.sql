--------------------------------------------------------
--  DDL for Package IGS_EN_ATTRIB_VALUES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_ATTRIB_VALUES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI64S.pls 115.1 2002/11/28 23:48:17 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_obj_type_id                       IN     NUMBER,
    x_obj_id                            IN     NUMBER,
    x_attrib_id                         IN     NUMBER,
    x_version                           IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_obj_type_id                       IN     NUMBER,
    x_obj_id                            IN     NUMBER,
    x_attrib_id                         IN     NUMBER,
    x_version                           IN     NUMBER,
    x_value                             IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_obj_type_id                       IN     NUMBER,
    x_obj_id                            IN     NUMBER,
    x_attrib_id                         IN     NUMBER,
    x_version                           IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_obj_type_id                       IN     NUMBER,
    x_obj_id                            IN     NUMBER,
    x_attrib_id                         IN     NUMBER,
    x_version                           IN     NUMBER,
    x_value                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_obj_type_id                       IN     NUMBER,
    x_obj_id                            IN     NUMBER,
    x_attrib_id                         IN     NUMBER,
    x_version                           IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_obj_type_id                       IN     NUMBER      DEFAULT NULL,
    x_obj_id                            IN     NUMBER      DEFAULT NULL,
    x_attrib_id                         IN     NUMBER      DEFAULT NULL,
    x_version                           IN     NUMBER      DEFAULT NULL,
    x_value                             IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END IGS_EN_ATTRIB_VALUES_pkg;

 

/
