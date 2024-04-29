--------------------------------------------------------
--  DDL for Package IGS_PS_USO_CLAS_MEET_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USO_CLAS_MEET_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2MS.pls 115.4 2002/11/29 02:18:11 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_class_meet_id                     IN OUT NOCOPY NUMBER,
    x_class_meet_group_id               IN     NUMBER,
    x_host                              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_uoo_id                            IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_class_meet_id                     IN     NUMBER,
    x_class_meet_group_id               IN     NUMBER,
    x_host                              IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_class_meet_id                     IN     NUMBER,
    x_class_meet_group_id               IN     NUMBER,
    x_host                              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_uoo_id                            IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_class_meet_id                     IN OUT NOCOPY NUMBER,
    x_class_meet_group_id               IN     NUMBER,
    x_host                              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_class_meet_id                     IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_uoo_id     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ps_uso_cm_grp (
    x_class_meet_group_id               IN     NUMBER
  );

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt(
    x_uoo_id                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_class_meet_id                     IN     NUMBER      DEFAULT NULL,
    x_class_meet_group_id               IN     NUMBER      DEFAULT NULL,
    x_host                              IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_uoo_id                            IN     NUMBER      DEFAULT NULL
  );

END igs_ps_uso_clas_meet_pkg;

 

/
