--------------------------------------------------------
--  DDL for Package IGS_PS_USO_CM_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PS_USO_CM_GRP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSPI2NS.pls 115.4 2002/11/29 02:18:27 nsidana ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_class_meet_group_id               IN OUT NOCOPY NUMBER,
    x_class_meet_group_name             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_max_ovr_group                     IN     NUMBER DEFAULT NULL,
    x_max_enr_group                     IN     NUMBER DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_class_meet_group_id               IN     NUMBER,
    x_class_meet_group_name             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                   IN     NUMBER,
    x_max_ovr_group                     IN     NUMBER DEFAULT NULL,
    x_max_enr_group                     IN     NUMBER DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_class_meet_group_id               IN     NUMBER,
    x_class_meet_group_name             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_max_ovr_group                     IN     NUMBER DEFAULT NULL,
    x_max_enr_group                     IN     NUMBER DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_class_meet_group_id               IN OUT NOCOPY NUMBER,
    x_class_meet_group_name             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                   IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_max_ovr_group                     IN     NUMBER DEFAULT NULL,
    x_max_enr_group                     IN     NUMBER DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_class_meet_group_id               IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_class_meet_group_name             IN     VARCHAR2,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                   IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_class_meet_group_id               IN     NUMBER      DEFAULT NULL,
    x_class_meet_group_name             IN     VARCHAR2    DEFAULT NULL,
    x_cal_type                          IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_max_ovr_group                     IN     NUMBER DEFAULT NULL,
    x_max_enr_group                     IN     NUMBER DEFAULT NULL
  );

END igs_ps_uso_cm_grp_pkg;

 

/
