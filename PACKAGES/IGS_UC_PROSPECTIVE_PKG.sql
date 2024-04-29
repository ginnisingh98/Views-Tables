--------------------------------------------------------
--  DDL for Package IGS_UC_PROSPECTIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_PROSPECTIVE_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI23S.pls 115.4 2002/11/29 04:51:22 nsidana noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_prospective_id                    IN OUT NOCOPY NUMBER,
    x_app_no                            IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_forenames                         IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_index_surname                     IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_withdrawn                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_prospective_id                    IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_forenames                         IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_index_surname                     IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_withdrawn                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_prospective_id                    IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_forenames                         IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_index_surname                     IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_withdrawn                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_prospective_id                    IN OUT NOCOPY NUMBER,
    x_app_no                            IN     NUMBER,
    x_datetimestamp                     IN     DATE,
    x_check_digit                       IN     NUMBER,
    x_name_change_date                  IN     DATE,
    x_title                             IN     VARCHAR2,
    x_forenames                         IN     VARCHAR2,
    x_surname                           IN     VARCHAR2,
    x_index_surname                     IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_withdrawn                         IN     VARCHAR2,
    x_status                            IN     VARCHAR2,
    x_birth_date                        IN     DATE,
    x_sex                               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_prospective_id                    IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk_for_validation (
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_prospective_id                    IN     NUMBER      DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_datetimestamp                     IN     DATE        DEFAULT NULL,
    x_check_digit                       IN     NUMBER      DEFAULT NULL,
    x_name_change_date                  IN     DATE        DEFAULT NULL,
    x_title                             IN     VARCHAR2    DEFAULT NULL,
    x_forenames                         IN     VARCHAR2    DEFAULT NULL,
    x_surname                           IN     VARCHAR2    DEFAULT NULL,
    x_index_surname                     IN     VARCHAR2    DEFAULT NULL,
    x_cancelled                         IN     VARCHAR2    DEFAULT NULL,
    x_withdrawn                         IN     VARCHAR2    DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_birth_date                        IN     DATE        DEFAULT NULL,
    x_sex                               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_prospective_pkg;

 

/
