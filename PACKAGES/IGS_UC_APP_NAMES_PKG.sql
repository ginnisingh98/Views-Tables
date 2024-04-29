--------------------------------------------------------
--  DDL for Package IGS_UC_APP_NAMES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_APP_NAMES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI49S.pls 120.0 2005/06/01 19:18:09 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_fore_names                        IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_fore_names                        IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_fore_names                        IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_fore_names                        IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_sent_to_oss_flag                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_uk_for_validation (
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_uc_applicants (
    x_app_no                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_check_digit                       IN     NUMBER      DEFAULT NULL,
    x_name_change_date                  IN     DATE        DEFAULT NULL,
    x_title                             IN     VARCHAR2    DEFAULT NULL,
    x_fore_names                        IN     VARCHAR2    DEFAULT NULL,
    x_surname                           IN     VARCHAR2    DEFAULT NULL,
    x_birth_date                        IN     DATE        DEFAULT NULL,
    x_sex                               IN     VARCHAR2    DEFAULT NULL,
    x_sent_to_oss_flag                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_app_names_pkg;

 

/
