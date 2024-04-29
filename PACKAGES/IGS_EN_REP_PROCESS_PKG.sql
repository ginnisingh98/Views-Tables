--------------------------------------------------------
--  DDL for Package IGS_EN_REP_PROCESS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_EN_REP_PROCESS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSEI60S.pls 115.4 2002/11/28 23:47:08 nsidana noship $ */
--who        when            what
-- ============================================================================


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_repeat_process_id                 IN OUT NOCOPY NUMBER,
    x_org_unit_id                       IN     NUMBER,
    x_include_adv_standing_units        IN     VARCHAR2,
    x_max_repeats_for_credit            IN     NUMBER,
    x_max_repeats_for_funding           IN     NUMBER,
    x_use_most_recent_unit_attempt      IN     VARCHAR2,
    x_use_best_grade_attempt            IN     VARCHAR2,
    x_external_formula                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_repeat_process_id                 IN     NUMBER,
    x_org_unit_id                       IN     NUMBER,
    x_include_adv_standing_units        IN     VARCHAR2,
    x_max_repeats_for_credit            IN     NUMBER,
    x_max_repeats_for_funding           IN     NUMBER,
    x_use_most_recent_unit_attempt      IN     VARCHAR2,
    x_use_best_grade_attempt            IN     VARCHAR2,
    x_external_formula                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_repeat_process_id                 IN     NUMBER,
    x_org_unit_id                       IN     NUMBER,
    x_include_adv_standing_units        IN     VARCHAR2,
    x_max_repeats_for_credit            IN     NUMBER,
    x_max_repeats_for_funding           IN     NUMBER,
    x_use_most_recent_unit_attempt      IN     VARCHAR2,
    x_use_best_grade_attempt            IN     VARCHAR2,
    x_external_formula                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_repeat_process_id                 IN OUT NOCOPY NUMBER,
    x_org_unit_id                       IN     NUMBER,
    x_include_adv_standing_units        IN     VARCHAR2,
    x_max_repeats_for_credit            IN     NUMBER,
    x_max_repeats_for_funding           IN     NUMBER,
    x_use_most_recent_unit_attempt      IN     VARCHAR2,
    x_use_best_grade_attempt            IN     VARCHAR2,
    x_external_formula                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_repeat_process_id                 IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_org_unit_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_repeat_process_id                 IN     NUMBER      DEFAULT NULL,
    x_org_unit_id                       IN     NUMBER      DEFAULT NULL,
    x_include_adv_standing_units        IN     VARCHAR2    DEFAULT NULL,
    x_max_repeats_for_credit            IN     NUMBER      DEFAULT NULL,
    x_max_repeats_for_funding           IN     NUMBER      DEFAULT NULL,
    x_use_most_recent_unit_attempt      IN     VARCHAR2    DEFAULT NULL,
    x_use_best_grade_attempt            IN     VARCHAR2    DEFAULT NULL,
    x_external_formula                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_en_rep_process_pkg;

 

/
