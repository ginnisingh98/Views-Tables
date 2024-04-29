--------------------------------------------------------
--  DDL for Package IGS_UC_JNT_ADM_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_JNT_ADM_INST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI40S.pls 115.2 2002/11/29 04:56:23 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_child_inst                        IN     VARCHAR2,
    x_parent_inst1                      IN     VARCHAR2,
    x_parent_inst2                      IN     VARCHAR2,
    x_parent_inst3                      IN     VARCHAR2,
    x_parent_inst4                      IN     VARCHAR2,
    x_parent_inst5                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_child_inst                        IN     VARCHAR2,
    x_parent_inst1                      IN     VARCHAR2,
    x_parent_inst2                      IN     VARCHAR2,
    x_parent_inst3                      IN     VARCHAR2,
    x_parent_inst4                      IN     VARCHAR2,
    x_parent_inst5                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_child_inst                        IN     VARCHAR2,
    x_parent_inst1                      IN     VARCHAR2,
    x_parent_inst2                      IN     VARCHAR2,
    x_parent_inst3                      IN     VARCHAR2,
    x_parent_inst4                      IN     VARCHAR2,
    x_parent_inst5                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_child_inst                        IN     VARCHAR2,
    x_parent_inst1                      IN     VARCHAR2,
    x_parent_inst2                      IN     VARCHAR2,
    x_parent_inst3                      IN     VARCHAR2,
    x_parent_inst4                      IN     VARCHAR2,
    x_parent_inst5                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_child_inst                        IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_child_inst                        IN     VARCHAR2    DEFAULT NULL,
    x_parent_inst1                      IN     VARCHAR2    DEFAULT NULL,
    x_parent_inst2                      IN     VARCHAR2    DEFAULT NULL,
    x_parent_inst3                      IN     VARCHAR2    DEFAULT NULL,
    x_parent_inst4                      IN     VARCHAR2    DEFAULT NULL,
    x_parent_inst5                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_jnt_adm_inst_pkg;

 

/
