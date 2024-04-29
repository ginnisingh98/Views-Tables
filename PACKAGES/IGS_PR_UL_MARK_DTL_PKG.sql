--------------------------------------------------------
--  DDL for Package IGS_PR_UL_MARK_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PR_UL_MARK_DTL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSQI47S.pls 115.0 2003/11/07 11:00:59 ijeddy noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_total_credits                     IN     NUMBER,
    x_required_flag                     IN     VARCHAR2,
    x_priority_num                      IN     NUMBER,
    x_unit_selection_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_total_credits                     IN     NUMBER,
    x_required_flag                     IN     VARCHAR2,
    x_priority_num                      IN     NUMBER,
    x_unit_selection_code               IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_total_credits                     IN     NUMBER,
    x_required_flag                     IN     VARCHAR2,
    x_priority_num                      IN     NUMBER,
    x_unit_selection_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_total_credits                     IN     NUMBER,
    x_required_flag                     IN     VARCHAR2,
    x_priority_num                      IN     NUMBER,
    x_unit_selection_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pr_ul_mark_cnfg (
    x_mark_config_id                    IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_mark_config_id                    IN     NUMBER      DEFAULT NULL,
    x_core_indicator_code               IN     VARCHAR2    DEFAULT NULL,
    x_total_credits                     IN     NUMBER      DEFAULT NULL,
    x_required_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_priority_num                      IN     NUMBER      DEFAULT NULL,
    x_unit_selection_code               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pr_ul_mark_dtl_pkg;

 

/
