--------------------------------------------------------
--  DDL for Package IGS_FI_LB_OVFL_ERRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_LB_OVFL_ERRS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSID6S.pls 115.0 2003/06/19 06:34:22 agairola noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_receipt_overflow_error_id         IN OUT NOCOPY NUMBER,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_charge_cd1                        IN     VARCHAR2,
    x_charge_cd2                        IN     VARCHAR2,
    x_charge_cd3                        IN     VARCHAR2,
    x_charge_cd4                        IN     VARCHAR2,
    x_charge_cd5                        IN     VARCHAR2,
    x_charge_cd6                        IN     VARCHAR2,
    x_charge_cd7                        IN     VARCHAR2,
    x_charge_cd8                        IN     VARCHAR2,
    x_applied_amt1                      IN     NUMBER,
    x_applied_amt2                      IN     NUMBER,
    x_applied_amt3                      IN     NUMBER,
    x_applied_amt4                      IN     NUMBER,
    x_applied_amt5                      IN     NUMBER,
    x_applied_amt6                      IN     NUMBER,
    x_applied_amt7                      IN     NUMBER,
    x_applied_amt8                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_receipt_overflow_error_id         IN     NUMBER,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_charge_cd1                        IN     VARCHAR2,
    x_charge_cd2                        IN     VARCHAR2,
    x_charge_cd3                        IN     VARCHAR2,
    x_charge_cd4                        IN     VARCHAR2,
    x_charge_cd5                        IN     VARCHAR2,
    x_charge_cd6                        IN     VARCHAR2,
    x_charge_cd7                        IN     VARCHAR2,
    x_charge_cd8                        IN     VARCHAR2,
    x_applied_amt1                      IN     NUMBER,
    x_applied_amt2                      IN     NUMBER,
    x_applied_amt3                      IN     NUMBER,
    x_applied_amt4                      IN     NUMBER,
    x_applied_amt5                      IN     NUMBER,
    x_applied_amt6                      IN     NUMBER,
    x_applied_amt7                      IN     NUMBER,
    x_applied_amt8                      IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_receipt_overflow_error_id         IN     NUMBER,
    x_lockbox_receipt_error_id          IN     NUMBER,
    x_charge_cd1                        IN     VARCHAR2,
    x_charge_cd2                        IN     VARCHAR2,
    x_charge_cd3                        IN     VARCHAR2,
    x_charge_cd4                        IN     VARCHAR2,
    x_charge_cd5                        IN     VARCHAR2,
    x_charge_cd6                        IN     VARCHAR2,
    x_charge_cd7                        IN     VARCHAR2,
    x_charge_cd8                        IN     VARCHAR2,
    x_applied_amt1                      IN     NUMBER,
    x_applied_amt2                      IN     NUMBER,
    x_applied_amt3                      IN     NUMBER,
    x_applied_amt4                      IN     NUMBER,
    x_applied_amt5                      IN     NUMBER,
    x_applied_amt6                      IN     NUMBER,
    x_applied_amt7                      IN     NUMBER,
    x_applied_amt8                      IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_receipt_overflow_error_id         IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_fi_lb_rect_errs (
    x_lockbox_receipt_error_id          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_receipt_overflow_error_id         IN     NUMBER      DEFAULT NULL,
    x_lockbox_receipt_error_id          IN     NUMBER      DEFAULT NULL,
    x_charge_cd1                        IN     VARCHAR2    DEFAULT NULL,
    x_charge_cd2                        IN     VARCHAR2    DEFAULT NULL,
    x_charge_cd3                        IN     VARCHAR2    DEFAULT NULL,
    x_charge_cd4                        IN     VARCHAR2    DEFAULT NULL,
    x_charge_cd5                        IN     VARCHAR2    DEFAULT NULL,
    x_charge_cd6                        IN     VARCHAR2    DEFAULT NULL,
    x_charge_cd7                        IN     VARCHAR2    DEFAULT NULL,
    x_charge_cd8                        IN     VARCHAR2    DEFAULT NULL,
    x_applied_amt1                      IN     NUMBER      DEFAULT NULL,
    x_applied_amt2                      IN     NUMBER      DEFAULT NULL,
    x_applied_amt3                      IN     NUMBER      DEFAULT NULL,
    x_applied_amt4                      IN     NUMBER      DEFAULT NULL,
    x_applied_amt5                      IN     NUMBER      DEFAULT NULL,
    x_applied_amt6                      IN     NUMBER      DEFAULT NULL,
    x_applied_amt7                      IN     NUMBER      DEFAULT NULL,
    x_applied_amt8                      IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_lb_ovfl_errs_pkg;

 

/
