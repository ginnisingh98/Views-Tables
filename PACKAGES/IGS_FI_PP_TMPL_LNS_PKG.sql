--------------------------------------------------------
--  DDL for Package IGS_FI_PP_TMPL_LNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_FI_PP_TMPL_LNS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSSID9S.pls 115.0 2003/08/26 07:05:39 smvk noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_plan_line_id                      IN OUT NOCOPY NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER,
    x_plan_percent                      IN     NUMBER,
    x_plan_amt                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_plan_line_id                      IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER,
    x_plan_percent                      IN     NUMBER,
    x_plan_amt                          IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_plan_line_id                      IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER,
    x_plan_percent                      IN     NUMBER,
    x_plan_amt                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_plan_line_id                      IN OUT NOCOPY NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER,
    x_plan_percent                      IN     NUMBER,
    x_plan_amt                          IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_plan_line_id                      IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_plan_line_id                      IN     NUMBER      DEFAULT NULL,
    x_payment_plan_name                 IN     VARCHAR2    DEFAULT NULL,
    x_plan_line_num                     IN     NUMBER      DEFAULT NULL,
    x_plan_percent                      IN     NUMBER      DEFAULT NULL,
    x_plan_amt                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_fi_pp_tmpl_lns_pkg;

 

/
