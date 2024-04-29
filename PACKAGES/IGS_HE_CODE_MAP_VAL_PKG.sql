--------------------------------------------------------
--  DDL for Package IGS_HE_CODE_MAP_VAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_CODE_MAP_VAL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI03S.pls 115.5 2002/11/29 04:34:57 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN OUT NOCOPY NUMBER,
    x_map_description                   IN     VARCHAR2,
    x_map1                              IN     VARCHAR2,
    x_map2                              IN     VARCHAR2,
    x_map3                              IN     VARCHAR2,
    x_map4                              IN     VARCHAR2,
    x_map5                              IN     VARCHAR2,
    x_map6                              IN     VARCHAR2,
    x_map7                              IN     VARCHAR2,
    x_map8                              IN     VARCHAR2,
    x_map9                              IN     VARCHAR2,
    x_map10                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER,
    x_map_description                   IN     VARCHAR2,
    x_map1                              IN     VARCHAR2,
    x_map2                              IN     VARCHAR2,
    x_map3                              IN     VARCHAR2,
    x_map4                              IN     VARCHAR2,
    x_map5                              IN     VARCHAR2,
    x_map6                              IN     VARCHAR2,
    x_map7                              IN     VARCHAR2,
    x_map8                              IN     VARCHAR2,
    x_map9                              IN     VARCHAR2,
    x_map10                             IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN     NUMBER,
    x_map_description                   IN     VARCHAR2,
    x_map1                              IN     VARCHAR2,
    x_map2                              IN     VARCHAR2,
    x_map3                              IN     VARCHAR2,
    x_map4                              IN     VARCHAR2,
    x_map5                              IN     VARCHAR2,
    x_map6                              IN     VARCHAR2,
    x_map7                              IN     VARCHAR2,
    x_map8                              IN     VARCHAR2,
    x_map9                              IN     VARCHAR2,
    x_map10                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_association_code                  IN     VARCHAR2,
    x_sequence                          IN OUT NOCOPY NUMBER,
    x_map_description                   IN     VARCHAR2,
    x_map1                              IN     VARCHAR2,
    x_map2                              IN     VARCHAR2,
    x_map3                              IN     VARCHAR2,
    x_map4                              IN     VARCHAR2,
    x_map5                              IN     VARCHAR2,
    x_map6                              IN     VARCHAR2,
    x_map7                              IN     VARCHAR2,
    x_map8                              IN     VARCHAR2,
    x_map9                              IN     VARCHAR2,
    x_map10                             IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_sequence                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_code_assoc (
    x_association_code                  IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_association_code                  IN     VARCHAR2    DEFAULT NULL,
    x_sequence                          IN     NUMBER      DEFAULT NULL,
    x_map_description                   IN     VARCHAR2    DEFAULT NULL,
    x_map1                              IN     VARCHAR2    DEFAULT NULL,
    x_map2                              IN     VARCHAR2    DEFAULT NULL,
    x_map3                              IN     VARCHAR2    DEFAULT NULL,
    x_map4                              IN     VARCHAR2    DEFAULT NULL,
    x_map5                              IN     VARCHAR2    DEFAULT NULL,
    x_map6                              IN     VARCHAR2    DEFAULT NULL,
    x_map7                              IN     VARCHAR2    DEFAULT NULL,
    x_map8                              IN     VARCHAR2    DEFAULT NULL,
    x_map9                              IN     VARCHAR2    DEFAULT NULL,
    x_map10                             IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

  --smaddali added new function bug 2409543
  FUNCTION get_uk_for_validation (
    x_association_code                  IN     VARCHAR2,
    x_map1                              IN     VARCHAR2,
    x_map2                              IN     VARCHAR2,
    x_map3                              IN     VARCHAR2,
    x_map4                              IN     VARCHAR2,
    x_map5                              IN     VARCHAR2,
    x_map6                              IN     VARCHAR2,
    x_map7                              IN     VARCHAR2,
    x_map8                              IN     VARCHAR2,
    x_map9                              IN     VARCHAR2,
    x_map10                             IN     VARCHAR2
  ) RETURN BOOLEAN;

END igs_he_code_map_val_pkg;

 

/
