--------------------------------------------------------
--  DDL for Package IGS_UC_COND_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_COND_DETAILS_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI13S.pls 115.5 2002/12/17 07:00:51 rbezawad noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_condition_line                    IN     NUMBER,
    x_abbreviation                      IN     VARCHAR2,
    x_grade_mark                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_condition_text                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_condition_line                    IN     NUMBER,
    x_abbreviation                      IN     VARCHAR2,
    x_grade_mark                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_condition_text                    IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_condition_line                    IN     NUMBER,
    x_abbreviation                      IN     VARCHAR2,
    x_grade_mark                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_condition_text                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_condition_line                    IN     NUMBER,
    x_abbreviation                      IN     VARCHAR2,
    x_grade_mark                        IN     VARCHAR2,
    x_points                            IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_condition_text                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2,
    x_condition_line                    IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_uc_offer_conds (
    x_condition_category                IN     VARCHAR2,
    x_condition_name                    IN     VARCHAR2
  );

  PROCEDURE get_fk_igs_uc_ref_off_abrv (
    x_abbreviation     IN VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_condition_category                IN     VARCHAR2    DEFAULT NULL,
    x_condition_name                    IN     VARCHAR2    DEFAULT NULL,
    x_condition_line                    IN     NUMBER      DEFAULT NULL,
    x_abbreviation                      IN     VARCHAR2    DEFAULT NULL,
    x_grade_mark                        IN     VARCHAR2    DEFAULT NULL,
    x_points                            IN     VARCHAR2    DEFAULT NULL,
    x_subject                           IN     VARCHAR2    DEFAULT NULL,
    x_condition_text                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_cond_details_pkg;

 

/
