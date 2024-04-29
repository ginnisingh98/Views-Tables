--------------------------------------------------------
--  DDL for Package IGS_PE_PER_TYPE_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_PER_TYPE_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIA4S.pls 115.2 2002/11/29 01:39:05 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_type_code                  IN     VARCHAR2,
    x_system_type                       IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_person_type_code                  IN     VARCHAR2,
    x_system_type                       IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_person_type_code                  IN     VARCHAR2,
    x_system_type                       IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_person_type_code                  IN     VARCHAR2,
    x_system_type                       IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_person_type_code                  IN     VARCHAR2,
    x_per_person_type_id                IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_person_type_code                  IN     VARCHAR2    DEFAULT NULL,
    x_system_type                       IN     VARCHAR2    DEFAULT NULL,
    x_per_person_type_id                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_per_type_map_pkg;

 

/
