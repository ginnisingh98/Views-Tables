--------------------------------------------------------
--  DDL for Package IGS_AS_SERVIC_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AS_SERVIC_PLAN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSDI74S.pls 115.2 2002/11/28 23:30:21 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_plan_id                           IN OUT NOCOPY NUMBER,
    x_plan_type                         IN     VARCHAR2,
    x_unlimited_ind                     IN     VARCHAR2,
    x_quantity_limit                    IN     NUMBER,
    x_period_of_plan                    IN     VARCHAR2,
    x_total_periods_covered             IN     NUMBER,
    x_fee_amount                        IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_plan_id                           IN     NUMBER,
    x_plan_type                         IN     VARCHAR2,
    x_unlimited_ind                     IN     VARCHAR2,
    x_quantity_limit                    IN     NUMBER,
    x_period_of_plan                    IN     VARCHAR2,
    x_total_periods_covered             IN     NUMBER,
    x_fee_amount                        IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_plan_id                           IN     NUMBER,
    x_plan_type                         IN     VARCHAR2,
    x_unlimited_ind                     IN     VARCHAR2,
    x_quantity_limit                    IN     NUMBER,
    x_period_of_plan                    IN     VARCHAR2,
    x_total_periods_covered             IN     NUMBER,
    x_fee_amount                        IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_plan_id                           IN OUT NOCOPY NUMBER,
    x_plan_type                         IN     VARCHAR2,
    x_unlimited_ind                     IN     VARCHAR2,
    x_quantity_limit                    IN     NUMBER,
    x_period_of_plan                    IN     VARCHAR2,
    x_total_periods_covered             IN     NUMBER,
    x_fee_amount                        IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_plan_id                           IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_plan_type                         IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_plan_id                           IN     NUMBER      DEFAULT NULL,
    x_plan_type                         IN     VARCHAR2    DEFAULT NULL,
    x_unlimited_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_quantity_limit                    IN     NUMBER      DEFAULT NULL,
    x_period_of_plan                    IN     VARCHAR2    DEFAULT NULL,
    x_total_periods_covered             IN     NUMBER      DEFAULT NULL,
    x_fee_amount                        IN     NUMBER      DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_as_servic_plan_pkg;

 

/
