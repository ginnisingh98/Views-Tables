--------------------------------------------------------
--  DDL for Package IGS_PE_EV_FORM_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_PE_EV_FORM_STAT_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSNIA6S.pls 120.0 2005/06/01 18:22:06 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ev_form_stat_id                   IN OUT NOCOPY NUMBER,
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_end_program_reason                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_ev_form_stat_id                   IN     NUMBER,
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_end_program_reason                IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_ev_form_stat_id                   IN     NUMBER,
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_end_program_reason                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ev_form_stat_id                   IN OUT NOCOPY NUMBER,
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2,
    x_prgm_start_date                   IN     DATE,
    x_prgm_end_date                     IN     DATE,
    x_remarks                           IN     VARCHAR2,
    x_termination_reason                IN     VARCHAR2,
    x_end_program_reason                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2,
  x_mode IN VARCHAR2 DEFAULT 'R'
  );

  FUNCTION get_pk_for_validation (
    x_ev_form_stat_id                   IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_ev_form_id                        IN     NUMBER,
    x_action_date                       IN     DATE,
    x_action_type                       IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_pe_ev_form (
    x_ev_form_id                        IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ev_form_stat_id                   IN     NUMBER      DEFAULT NULL,
    x_ev_form_id                        IN     NUMBER      DEFAULT NULL,
    x_action_date                       IN     DATE        DEFAULT NULL,
    x_action_type                       IN     VARCHAR2    DEFAULT NULL,
    x_prgm_start_date                   IN     DATE        DEFAULT NULL,
    x_prgm_end_date                     IN     DATE        DEFAULT NULL,
    x_remarks                           IN     VARCHAR2    DEFAULT NULL,
    x_termination_reason                IN     VARCHAR2    DEFAULT NULL,
    x_end_program_reason                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_pe_ev_form_stat_pkg;

 

/
