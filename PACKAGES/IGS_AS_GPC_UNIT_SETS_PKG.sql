--------------------------------------------------------
--  DDL for Package IGS_AS_GPC_UNIT_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_GPC_UNIT_SETS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI54S.pls 115.3 2002/11/28 23:24:23 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_gpc_unit_set_id                   IN OUT NOCOPY NUMBER,
    x_grading_period_cd                 IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_unit_set_version_number           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_gpc_unit_set_id                   IN     NUMBER,
    x_grading_period_cd                 IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_unit_set_version_number           IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_gpc_unit_set_id                   IN     NUMBER,
    x_grading_period_cd                 IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_unit_set_version_number           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_gpc_unit_set_id                   IN OUT NOCOPY NUMBER,
    x_grading_period_cd                 IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_unit_set_version_number           IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_gpc_unit_set_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_unit_set_cd                       IN     VARCHAR2,
    x_grading_period_cd                 IN     VARCHAR2,
    x_unit_set_version_number           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_en_unit_set (
    x_unit_set_cd                       IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_gpc_unit_set_id                   IN     NUMBER      DEFAULT NULL,
    x_grading_period_cd                 IN     VARCHAR2    DEFAULT NULL,
    x_unit_set_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_unit_set_version_number           IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_gpc_unit_sets_pkg;

 

/
