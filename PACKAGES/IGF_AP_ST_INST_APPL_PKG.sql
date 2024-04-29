--------------------------------------------------------
--  DDL for Package IGF_AP_ST_INST_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_ST_INST_APPL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI12S.pls 120.1 2005/08/16 23:07:16 appldev ship $ */
/*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Table Handler package for igf_ap_st_inst_appl table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst_app_id                       IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_question_id                       IN     NUMBER,
    x_question_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_application_code                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_inst_app_id                       IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_question_id                       IN     NUMBER,
    x_question_value                    IN     VARCHAR2,
    x_application_code                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_inst_app_id                       IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_question_id                       IN     NUMBER,
    x_question_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_application_code                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst_app_id                       IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_question_id                       IN     NUMBER,
    x_question_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_application_code                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_inst_app_id                       IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_base_id                           IN     NUMBER,
    x_question_id                       IN     NUMBER,
    x_application_code                  IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_ap_appl_setup (
    x_question_id                       IN     NUMBER
  );

  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_ap_appl_status (
 	    x_base_id                           IN     NUMBER,
 	    x_application_code                  IN     VARCHAR2
 	  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inst_app_id                       IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_question_id                       IN     NUMBER      DEFAULT NULL,
    x_question_value                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_application_code                  IN     VARCHAR2    DEFAULT NULL
  );

END igf_ap_st_inst_appl_pkg;

 

/
