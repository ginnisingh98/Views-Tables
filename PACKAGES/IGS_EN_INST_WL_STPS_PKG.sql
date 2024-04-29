--------------------------------------------------------
--  DDL for Package IGS_EN_INST_WL_STPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_INST_WL_STPS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI71S.pls 115.0 2003/09/02 08:50:53 svanukur noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst_wlst_setup_id                IN OUT NOCOPY   NUMBER,
    x_waitlist_allowed_flag             IN     VARCHAR2,
    x_time_confl_alwd_wlst_flag         IN     VARCHAR2,
    x_simultaneous_wlst_alwd_flag       IN     VARCHAR2,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2,
    x_include_waitlist_cp_flag          IN     VARCHAR2,
    x_max_waitlists_student_num         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_inst_wlst_setup_id                IN     NUMBER,
    x_waitlist_allowed_flag             IN     VARCHAR2,
    x_time_confl_alwd_wlst_flag         IN     VARCHAR2,
    x_simultaneous_wlst_alwd_flag       IN     VARCHAR2,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2,
    x_include_waitlist_cp_flag          IN     VARCHAR2,
    x_max_waitlists_student_num         IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_inst_wlst_setup_id                IN     NUMBER,
    x_waitlist_allowed_flag             IN     VARCHAR2,
    x_time_confl_alwd_wlst_flag         IN     VARCHAR2,
    x_simultaneous_wlst_alwd_flag       IN     VARCHAR2,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2,
    x_include_waitlist_cp_flag          IN     VARCHAR2,
    x_max_waitlists_student_num         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst_wlst_setup_id                IN OUT NOCOPY   NUMBER,
    x_waitlist_allowed_flag             IN     VARCHAR2,
    x_time_confl_alwd_wlst_flag         IN     VARCHAR2,
    x_simultaneous_wlst_alwd_flag       IN     VARCHAR2,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2,
    x_include_waitlist_cp_flag          IN     VARCHAR2,
    x_max_waitlists_student_num         IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION Get_PK_For_Validation (
     x_inst_wlst_setup_id IN NUMBER
    ) RETURN BOOLEAN;
  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inst_wlst_setup_id                IN     NUMBER      DEFAULT NULL,
    x_waitlist_allowed_flag             IN     VARCHAR2    DEFAULT NULL,
    x_time_confl_alwd_wlst_flag         IN     VARCHAR2    DEFAULT NULL,
    x_simultaneous_wlst_alwd_flag       IN     VARCHAR2    DEFAULT NULL,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2    DEFAULT NULL,
    x_include_waitlist_cp_flag          IN     VARCHAR2    DEFAULT NULL,
    x_max_waitlists_student_num         IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_inst_wl_stps_pkg;

 

/
