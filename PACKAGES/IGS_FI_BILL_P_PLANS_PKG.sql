--------------------------------------------------------
--  DDL for Package IGS_FI_BILL_P_PLANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_BILL_P_PLANS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIE3S.pls 115.0 2003/08/26 07:19:47 smvk noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER,
    x_plan_start_date                   IN     DATE,
    x_plan_end_date                     IN     DATE,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_student_plan_id                   IN     NUMBER,
    x_bill_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_pp_std_attrs (
    x_student_plan_id                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_student_plan_id                   IN     NUMBER      DEFAULT NULL,
    x_bill_id                           IN     NUMBER      DEFAULT NULL,
    x_plan_start_date                   IN     DATE        DEFAULT NULL,
    x_plan_end_date                     IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_bill_p_plans_pkg;

 

/
