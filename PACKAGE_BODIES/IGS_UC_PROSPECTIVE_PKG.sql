--------------------------------------------------------
--  DDL for Package Body IGS_UC_PROSPECTIVE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_PROSPECTIVE_PKG" AS
/* $Header: IGSXI23B.pls 115.4 2002/11/29 04:51:15 nsidana noship $ */

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_prospective_id                    IN     NUMBER      ,
    x_app_no                            IN     NUMBER      ,
    x_datetimestamp                     IN     DATE        ,
    x_check_digit                       IN     NUMBER      ,
    x_name_change_date                  IN     DATE        ,
    x_title                             IN     VARCHAR2    ,
    x_forenames                         IN     VARCHAR2    ,
    x_surname                           IN     VARCHAR2    ,
    x_index_surname                     IN     VARCHAR2    ,
    x_cancelled                         IN     VARCHAR2    ,
    x_withdrawn                         IN     VARCHAR2    ,
    x_status                            IN     VARCHAR2    ,
    x_birth_date                        IN     DATE        ,
    x_sex                               IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS

  BEGIN
     NULL;
  END set_column_values;


  PROCEDURE check_uniqueness AS
  BEGIN
     NULL;
  END check_uniqueness;


  FUNCTION get_pk_for_validation (
    x_prospective_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  BEGIN
     NULL;
  END get_pk_for_validation;


  FUNCTION get_uk_for_validation (
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN AS
  BEGIN
     NULL;
  END get_uk_for_validation ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_prospective_id                    IN     NUMBER      ,
    x_app_no                            IN     NUMBER      ,
    x_datetimestamp                     IN     DATE        ,
    x_check_digit                       IN     NUMBER      ,
    x_name_change_date                  IN     DATE        ,
    x_title                             IN     VARCHAR2    ,
    x_forenames                         IN     VARCHAR2    ,
    x_surname                           IN     VARCHAR2    ,
    x_index_surname                     IN     VARCHAR2    ,
    x_cancelled                         IN     VARCHAR2    ,
    x_withdrawn                         IN     VARCHAR2    ,
    x_status                            IN     VARCHAR2    ,
    x_birth_date                        IN     DATE        ,
    x_sex                               IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  BEGIN
     NULL;
  END before_dml;


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
    x_mode                              IN     VARCHAR2
  ) AS
  BEGIN
     NULL;
  END insert_row;


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
  ) AS
  BEGIN
     NULL;
  END lock_row;


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
    x_mode                              IN     VARCHAR2
  ) AS
  BEGIN
     NULL;
  END update_row;


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
    x_mode                              IN     VARCHAR2
  ) AS
  BEGIN
     NULL;
  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  BEGIN
     NULL;
  END delete_row;


END igs_uc_prospective_pkg;

/
