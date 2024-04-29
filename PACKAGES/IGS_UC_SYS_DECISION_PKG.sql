--------------------------------------------------------
--  DDL for Package IGS_UC_SYS_DECISION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_SYS_DECISION_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI44S.pls 115.5 2003/12/07 15:13:56 pmarada noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_s_adm_outcome_status              IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_decision_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_s_adm_outcome_status              IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_decision_type                     IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_s_adm_outcome_status              IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_decision_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_s_adm_outcome_status              IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_decision_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );



  FUNCTION get_pk_for_validation (
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_system_code                       IN     VARCHAR2    DEFAULT NULL,
    x_decision_code                     IN     VARCHAR2    DEFAULT NULL,
    x_s_adm_outcome_status              IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL ,
    x_decision_type                     IN     VARCHAR2    DEFAULT NULL
  );

END igs_uc_sys_decision_pkg;

 

/
