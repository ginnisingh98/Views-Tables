--------------------------------------------------------
--  DDL for Package IGS_HE_SUB_RTN_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_HE_SUB_RTN_QUAL_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSWI37S.pls 115.0 2003/04/29 09:11:48 pmarada noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_qual_period_desc                  IN     VARCHAR2,
    x_qual_period_type                  IN     VARCHAR2,
    x_qual_period_start_date            IN     DATE,
    x_qual_period_end_date              IN     DATE,
    x_census_date                       IN     DATE,
    x_survey_start_date                 IN     DATE,
    x_survey_end_date                   IN     DATE,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_qual_period_desc                  IN     VARCHAR2,
    x_qual_period_type                  IN     VARCHAR2,
    x_qual_period_start_date            IN     DATE,
    x_qual_period_end_date              IN     DATE,
    x_census_date                       IN     DATE,
    x_survey_start_date                 IN     DATE,
    x_survey_end_date                   IN     DATE,
    x_closed_ind                        IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_qual_period_desc                  IN     VARCHAR2,
    x_qual_period_type                  IN     VARCHAR2,
    x_qual_period_start_date            IN     DATE,
    x_qual_period_end_date              IN     DATE,
    x_census_date                       IN     DATE,
    x_survey_start_date                 IN     DATE,
    x_survey_end_date                   IN     DATE,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_qual_period_desc                  IN     VARCHAR2,
    x_qual_period_type                  IN     VARCHAR2,
    x_qual_period_start_date            IN     DATE,
    x_qual_period_end_date              IN     DATE,
    x_census_date                       IN     DATE,
    x_survey_start_date                 IN     DATE,
    x_survey_end_date                   IN     DATE,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igs_he_submsn_return (
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_submission_name                   IN     VARCHAR2    DEFAULT NULL,
    x_user_return_subclass              IN     VARCHAR2    DEFAULT NULL,
    x_return_name                       IN     VARCHAR2    DEFAULT NULL,
    x_qual_period_code                  IN     VARCHAR2    DEFAULT NULL,
    x_qual_period_desc                  IN     VARCHAR2    DEFAULT NULL,
    x_qual_period_type                  IN     VARCHAR2    DEFAULT NULL,
    x_qual_period_start_date            IN     DATE        DEFAULT NULL,
    x_qual_period_end_date              IN     DATE        DEFAULT NULL,
    x_census_date                       IN     DATE        DEFAULT NULL,
    x_survey_start_date                 IN     DATE        DEFAULT NULL,
    x_survey_end_date                   IN     DATE        DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_he_sub_rtn_qual_pkg;

 

/
