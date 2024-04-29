--------------------------------------------------------
--  DDL for Package IGS_FI_PP_TEMPLATES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PP_TEMPLATES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSID8S.pls 115.0 2003/08/26 06:55:02 smvk noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_payment_plan_name                 IN     VARCHAR2,
    x_payment_plan_desc                 IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_installment_period_code           IN     VARCHAR2,
    x_due_day_of_month                  IN     NUMBER,
    x_due_end_of_month_flag             IN     VARCHAR2,
    x_due_cutoff_day                    IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_installment_method_flag           IN     VARCHAR2,
    x_base_amt                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_payment_plan_name                 IN     VARCHAR2,
    x_payment_plan_desc                 IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_installment_period_code           IN     VARCHAR2,
    x_due_day_of_month                  IN     NUMBER,
    x_due_end_of_month_flag             IN     VARCHAR2,
    x_due_cutoff_day                    IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_installment_method_flag           IN     VARCHAR2,
    x_base_amt                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_payment_plan_name                 IN     VARCHAR2,
    x_payment_plan_desc                 IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_installment_period_code           IN     VARCHAR2,
    x_due_day_of_month                  IN     NUMBER,
    x_due_end_of_month_flag             IN     VARCHAR2,
    x_due_cutoff_day                    IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_installment_method_flag           IN     VARCHAR2,
    x_base_amt                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_payment_plan_name                 IN     VARCHAR2,
    x_payment_plan_desc                 IN     VARCHAR2,
    x_closed_flag                       IN     VARCHAR2,
    x_installment_period_code           IN     VARCHAR2,
    x_due_day_of_month                  IN     NUMBER,
    x_due_end_of_month_flag             IN     VARCHAR2,
    x_due_cutoff_day                    IN     NUMBER,
    x_processing_fee_type               IN     VARCHAR2,
    x_processing_fee_amt                IN     NUMBER,
    x_installment_method_flag           IN     VARCHAR2,
    x_base_amt                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_payment_plan_name                 IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_payment_plan_name                 IN     VARCHAR2    DEFAULT NULL,
    x_payment_plan_desc                 IN     VARCHAR2    DEFAULT NULL,
    x_closed_flag                       IN     VARCHAR2    DEFAULT NULL,
    x_installment_period_code           IN     VARCHAR2    DEFAULT NULL,
    x_due_day_of_month                  IN     NUMBER      DEFAULT NULL,
    x_due_end_of_month_flag             IN     VARCHAR2    DEFAULT NULL,
    x_due_cutoff_day                    IN     NUMBER      DEFAULT NULL,
    x_processing_fee_type               IN     VARCHAR2    DEFAULT NULL,
    x_processing_fee_amt                IN     NUMBER      DEFAULT NULL,
    x_installment_method_flag           IN     VARCHAR2    DEFAULT NULL,
    x_base_amt                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_pp_templates_pkg;

 

/
