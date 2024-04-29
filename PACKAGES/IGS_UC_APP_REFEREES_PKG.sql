--------------------------------------------------------
--  DDL for Package IGS_UC_APP_REFEREES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGS_UC_APP_REFEREES_PKG" AUTHID CURRENT_USER AS
/* $Header: IGSXI52S.pls 120.1 2005/07/31 17:57:16 appldev noship $ */

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_referee_name                      IN     VARCHAR2,
    x_referee_post                      IN     VARCHAR2,
    x_estab_name                        IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_statement                         IN     CLOB,
    x_predicted_grades                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_referee_name                      IN     VARCHAR2,
    x_referee_post                      IN     VARCHAR2,
    x_estab_name                        IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_statement                         IN     CLOB,
    x_predicted_grades                  IN     VARCHAR2
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_referee_name                      IN     VARCHAR2,
    x_referee_post                      IN     VARCHAR2,
    x_estab_name                        IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_statement                         IN     CLOB,
    x_predicted_grades                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_no                            IN     NUMBER,
    x_referee_name                      IN     VARCHAR2,
    x_referee_post                      IN     VARCHAR2,
    x_estab_name                        IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_telephone                         IN     VARCHAR2,
    x_fax                               IN     VARCHAR2,
    x_email                             IN     VARCHAR2,
    x_statement                         IN     CLOB,
    x_predicted_grades                  IN     VARCHAR2,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_uk_for_validation (
    x_app_no                            IN     NUMBER,
    x_referee_name                      IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_ufk_igs_uc_applicants (
    x_app_no                            IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_app_no                            IN     NUMBER      DEFAULT NULL,
    x_referee_name                      IN     VARCHAR2    DEFAULT NULL,
    x_referee_post                      IN     VARCHAR2    DEFAULT NULL,
    x_estab_name                        IN     VARCHAR2    DEFAULT NULL,
    x_address1                          IN     VARCHAR2    DEFAULT NULL,
    x_address2                          IN     VARCHAR2    DEFAULT NULL,
    x_address3                          IN     VARCHAR2    DEFAULT NULL,
    x_address4                          IN     VARCHAR2    DEFAULT NULL,
    x_telephone                         IN     VARCHAR2    DEFAULT NULL,
    x_fax                               IN     VARCHAR2    DEFAULT NULL,
    x_email                             IN     VARCHAR2    DEFAULT NULL,
    x_statement                         IN     CLOB        DEFAULT NULL,
    x_predicted_grades                  IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igs_uc_app_referees_pkg;

 

/
