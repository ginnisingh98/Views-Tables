--------------------------------------------------------
--  DDL for Package IGS_PS_UNIT_X_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_UNIT_X_GRP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2IS.pls 115.6 2002/11/29 02:17:02 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_x_listed_group_id            IN OUT NOCOPY NUMBER,
    x_unit_x_listed_group_name          IN     VARCHAR2,
    x_location_inheritance              IN     VARCHAR2,
    x_max_enr_group			IN     NUMBER DEFAULT NULL,
    x_max_ovr_group			IN     NUMBER DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_x_listed_group_id            IN     NUMBER,
    x_unit_x_listed_group_name          IN     VARCHAR2,
    x_location_inheritance              IN     VARCHAR2,
    x_max_enr_group			IN     NUMBER DEFAULT NULL,
    x_max_ovr_group			IN     NUMBER DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_x_listed_group_id            IN     NUMBER,
    x_unit_x_listed_group_name          IN     VARCHAR2,
    x_location_inheritance              IN     VARCHAR2,
    x_max_enr_group			IN     NUMBER  DEFAULT NULL,
    x_max_ovr_group			IN     NUMBER  DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_x_listed_group_id            IN OUT NOCOPY NUMBER,
    x_unit_x_listed_group_name          IN     VARCHAR2,
    x_location_inheritance              IN     VARCHAR2,
    x_max_enr_group			IN     NUMBER DEFAULT NULL,
    x_max_ovr_group			IN     NUMBER DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_unit_x_listed_group_id            IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_unit_x_listed_group_name          IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_unit_x_listed_group_id            IN     NUMBER      DEFAULT NULL,
    x_unit_x_listed_group_name          IN     VARCHAR2    DEFAULT NULL,
    x_location_inheritance              IN     VARCHAR2    DEFAULT NULL,
    x_max_enr_group			IN     NUMBER	   DEFAULT NULL,
    x_max_ovr_group			IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ps_unit_x_grp_pkg;

 

/
