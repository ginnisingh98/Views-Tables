--------------------------------------------------------
--  DDL for Package IGS_PR_CS_SCHDL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_CS_SCHDL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI30S.pls 115.6 2003/06/05 13:06:24 sarakshi ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_pr_cs_schdl_id                IN OUT NOCOPY NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_consider_changes                  IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_pr_cs_schdl_id                IN     NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_consider_changes                  IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_igs_pr_cs_schdl_id                IN     NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_consider_changes                  IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_igs_pr_cs_schdl_id                IN OUT NOCOPY NUMBER,
    x_course_type                       IN     VARCHAR2,
    x_consider_changes                  IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_igs_pr_cs_schdl_id                IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_start_dt                          IN     DATE,
    x_course_type                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_igs_pr_cs_schdl_id                IN     NUMBER      DEFAULT NULL,
    x_course_type                       IN     VARCHAR2    DEFAULT NULL,
    x_consider_changes                  IN     VARCHAR2    DEFAULT NULL,
    x_start_dt                          IN     DATE        DEFAULT NULL,
    x_end_dt                            IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_cs_schdl_pkg;

 

/
