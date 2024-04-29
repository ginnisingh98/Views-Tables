--------------------------------------------------------
--  DDL for Package IGS_FI_PP_INSTLMNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PP_INSTLMNTS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIE1S.pls 115.0 2003/08/26 07:10:54 smvk noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_installment_id                    IN OUT NOCOPY NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_installment_line_num              IN     NUMBER,
    x_due_day                           IN     NUMBER,
    x_due_month_code                    IN     VARCHAR2,
    x_due_year                          IN     NUMBER,
    x_due_date                          IN     DATE,
    x_installment_amt                   IN     NUMBER,
    x_due_amt                           IN     NUMBER,
    x_penalty_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_installment_id                    IN     NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_installment_line_num              IN     NUMBER,
    x_due_day                           IN     NUMBER,
    x_due_month_code                    IN     VARCHAR2,
    x_due_year                          IN     NUMBER,
    x_due_date                          IN     DATE,
    x_installment_amt                   IN     NUMBER,
    x_due_amt                           IN     NUMBER,
    x_penalty_flag                      IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_installment_id                    IN     NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_installment_line_num              IN     NUMBER,
    x_due_day                           IN     NUMBER,
    x_due_month_code                    IN     VARCHAR2,
    x_due_year                          IN     NUMBER,
    x_due_date                          IN     DATE,
    x_installment_amt                   IN     NUMBER,
    x_due_amt                           IN     NUMBER,
    x_penalty_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_installment_id                    IN OUT NOCOPY NUMBER,
    x_student_plan_id                   IN     NUMBER,
    x_installment_line_num              IN     NUMBER,
    x_due_day                           IN     NUMBER,
    x_due_month_code                    IN     VARCHAR2,
    x_due_year                          IN     NUMBER,
    x_due_date                          IN     DATE,
    x_installment_amt                   IN     NUMBER,
    x_due_amt                           IN     NUMBER,
    x_penalty_flag                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_installment_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_student_plan_id                   IN     NUMBER,
    x_installment_line_num              IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk2_for_validation (
    x_student_plan_id                   IN     NUMBER,
    x_due_date                          IN     DATE
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_pp_std_attrs (
    x_student_plan_id                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_installment_id                    IN     NUMBER      DEFAULT NULL,
    x_student_plan_id                   IN     NUMBER      DEFAULT NULL,
    x_installment_line_num              IN     NUMBER      DEFAULT NULL,
    x_due_day                           IN     NUMBER      DEFAULT NULL,
    x_due_month_code                    IN     VARCHAR2    DEFAULT NULL,
    x_due_year                          IN     NUMBER      DEFAULT NULL,
    x_due_date                          IN     DATE        DEFAULT NULL,
    x_installment_amt                   IN     NUMBER      DEFAULT NULL,
    x_due_amt                           IN     NUMBER      DEFAULT NULL,
    x_penalty_flag                      IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_pp_instlmnts_pkg;

 

/
