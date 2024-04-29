--------------------------------------------------------
--  DDL for Package IGS_FI_HOLD_PLAN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_HOLD_PLAN_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSIA6S.pls 115.12 2003/09/12 09:30:43 vvutukur ship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_plan_desc                    IN     VARCHAR2,
    x_hold_plan_level                   IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_threshold_amount                  IN     NUMBER,
    x_threshold_percent                 IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_offset_days                       IN     NUMBER      DEFAULT NULL,
    x_payment_plan_threshold_amt        IN     NUMBER      DEFAULT NULL,
    x_payment_plan_threshold_pcent      IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_plan_desc                    IN     VARCHAR2,
    x_hold_plan_level                   IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_threshold_amount                  IN     NUMBER,
    x_threshold_percent                 IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_offset_days                       IN     NUMBER      DEFAULT NULL,
    x_payment_plan_threshold_amt        IN     NUMBER      DEFAULT NULL,
    x_payment_plan_threshold_pcent      IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_plan_desc                    IN     VARCHAR2,
    x_hold_plan_level                   IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_threshold_amount                  IN     NUMBER,
    x_threshold_percent                 IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_offset_days                       IN     NUMBER      DEFAULT NULL,
    x_payment_plan_threshold_amt        IN     NUMBER      DEFAULT NULL,
    x_payment_plan_threshold_pcent      IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hold_plan_name                    IN     VARCHAR2,
    x_hold_plan_desc                    IN     VARCHAR2,
    x_hold_plan_level                   IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_threshold_amount                  IN     NUMBER,
    x_threshold_percent                 IN     NUMBER,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_offset_days                       IN     NUMBER      DEFAULT NULL,
    x_payment_plan_threshold_amt        IN     NUMBER      DEFAULT NULL,
    x_payment_plan_threshold_pcent      IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_hold_plan_name                    IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_encmb_type (
    x_encumbrance_type                  IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hold_plan_name                    IN     VARCHAR2    DEFAULT NULL,
    x_hold_plan_desc                    IN     VARCHAR2    DEFAULT NULL,
    x_hold_plan_level                   IN     VARCHAR2    DEFAULT NULL,
    x_hold_type                         IN     VARCHAR2    DEFAULT NULL,
    x_threshold_amount                  IN     NUMBER      DEFAULT NULL,
    x_threshold_percent                 IN     NUMBER      DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_fee_type                          IN     VARCHAR2    DEFAULT NULL,
    x_offset_days                       IN     NUMBER      DEFAULT NULL,
    x_payment_plan_threshold_amt        IN     NUMBER      DEFAULT NULL,
    x_payment_plan_threshold_pcent      IN     NUMBER      DEFAULT NULL
  );

END igs_fi_hold_plan_pkg;

 

/
