--------------------------------------------------------
--  DDL for Package IGS_AD_RVGR_EVALTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_AD_RVGR_EVALTR_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSAIF6S.pls 115.5 2002/12/23 11:38:12 rghosh noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_revgr_evaluator_id                IN OUT NOCOPY NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_evaluation_sequence               IN     NUMBER,
    x_program_approver_ind              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_revgr_evaluator_id                IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_evaluation_sequence               IN     NUMBER,
    x_program_approver_ind              IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_revgr_evaluator_id                IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_evaluation_sequence               IN     NUMBER,
    x_program_approver_ind              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_revgr_evaluator_id                IN OUT NOCOPY NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_evaluation_sequence               IN     NUMBER,
    x_program_approver_ind              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_revgr_evaluator_id                IN     NUMBER
 ) RETURN BOOLEAN;

 FUNCTION get_uk_for_validation (
   x_appl_revprof_revgr_id                IN     NUMBER,
   x_person_id                            IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_hz_parties (
    x_person_id                IN     NUMBER
  );

  PROCEDURE get_fk_igs_ad_apl_rprf_rgr (
    x_appl_revprof_revgr_id             IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_revgr_evaluator_id                IN     NUMBER      DEFAULT NULL,
    x_appl_revprof_revgr_id             IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_person_number                     IN     VARCHAR2    DEFAULT NULL,
    x_evaluation_sequence               IN     NUMBER      DEFAULT NULL,
    x_program_approver_ind              IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_ad_rvgr_evaltr_pkg;

 

/
