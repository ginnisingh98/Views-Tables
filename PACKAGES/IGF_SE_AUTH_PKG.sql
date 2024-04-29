--------------------------------------------------------
--  DDL for Package IGF_SE_AUTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_SE_AUTH_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFSI04S.pls 120.0 2005/06/01 15:37:51 appldev noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_SE_AUTH_PKG
 |                                                                       |
 | NOTES                                                                 |
 |                                                                       |
 | This package has a flag on the end of some of the procedures called   |
 | X_MODE. Pass either 'R' for runtime, or 'I' for Install-time.         |
 | This will control how the who columns are filled in; If you are       |
 | running in runtime mode, they are taken from the profiles, whereas in |
 | install-time mode they get defaulted with special values to indicate  |
 | that they were inserted by datamerge.                                 |
 |                                                                       |
 | The ADD_ROW routine will see whether a row exists by selecting        |
 | based on the primary key, and updates the row if it exists,           |
 | or inserts the row if it doesn't already exist.                       |
 |                                                                       |
 | This module is called by AutoInstall (afplss.drv) on install and      |
 | upgrade.  The WHENEVER SQLERROR and EXIT (at bottom) are required.    |
 |                                                                       |
 | HISTORY                                                               |
 |veramach    July 2004     Obsoleted min_hr_rate,max_hr_rate,           |
 |                          govt_share_perct,ld_cal_type,                |
 |                          ld_sequence_number                           |
 |                          Added award_id,authorization_date,           |
 |                          notification_date                            |
 *=======================================================================*/

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sequence_no                       IN OUT NOCOPY NUMBER,
    x_auth_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_first_name                        IN     VARCHAR2,
    x_last_name                         IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_ssn_no                            IN     VARCHAR2,
    x_marital_status                    IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_visa_category                     IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_expiry_dt                    IN     DATE,
    x_entry_date                        IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_accepted_amnt                     IN     NUMBER,
    x_aw_cal_type                       IN     VARCHAR2,
    x_aw_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_authorization_date                IN     DATE        DEFAULT NULL,
    x_notification_date                 IN     DATE        DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_auth_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_first_name                        IN     VARCHAR2,
    x_last_name                         IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_ssn_no                            IN     VARCHAR2,
    x_marital_status                    IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_visa_category                     IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_expiry_dt                    IN     DATE,
    x_entry_date                        IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_accepted_amnt                     IN     NUMBER,
    x_aw_cal_type                       IN     VARCHAR2,
    x_aw_sequence_number                IN     NUMBER,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_authorization_date                IN     DATE        DEFAULT NULL,
    x_notification_date                 IN     DATE        DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_auth_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_first_name                        IN     VARCHAR2,
    x_last_name                         IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_ssn_no                            IN     VARCHAR2,
    x_marital_status                    IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_visa_category                     IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_expiry_dt                    IN     DATE,
    x_entry_date                        IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_accepted_amnt                     IN     NUMBER,
    x_aw_cal_type                       IN     VARCHAR2,
    x_aw_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_authorization_date                IN     DATE        DEFAULT NULL,
    x_notification_date                 IN     DATE        DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sequence_no                       IN OUT NOCOPY NUMBER,
    x_auth_id                           IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_person_id                         IN     NUMBER,
    x_first_name                        IN     VARCHAR2,
    x_last_name                         IN     VARCHAR2,
    x_address1                          IN     VARCHAR2,
    x_address2                          IN     VARCHAR2,
    x_address3                          IN     VARCHAR2,
    x_address4                          IN     VARCHAR2,
    x_city                              IN     VARCHAR2,
    x_state                             IN     VARCHAR2,
    x_province                          IN     VARCHAR2,
    x_county                            IN     VARCHAR2,
    x_country                           IN     VARCHAR2,
    x_sex                               IN     VARCHAR2,
    x_birth_dt                          IN     DATE,
    x_ssn_no                            IN     VARCHAR2,
    x_marital_status                    IN     VARCHAR2,
    x_visa_type                         IN     VARCHAR2,
    x_visa_category                     IN     VARCHAR2,
    x_visa_number                       IN     VARCHAR2,
    x_visa_expiry_dt                    IN     DATE,
    x_entry_date                        IN     DATE,
    x_fund_id                           IN     NUMBER,
    x_threshold_perct                   IN     NUMBER,
    x_threshold_value                   IN     NUMBER,
    x_accepted_amnt                     IN     NUMBER,
    x_aw_cal_type                       IN     VARCHAR2,
    x_aw_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_authorization_date                IN     DATE        DEFAULT NULL,
    x_notification_date                 IN     DATE        DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  PROCEDURE check_constraints (
    column_name                         IN     VARCHAR2    DEFAULT NULL,
    column_value                        IN     VARCHAR2    DEFAULT NULL
  );

  FUNCTION get_pk_for_validation (
    x_sequence_no                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_sequence_no                       IN     NUMBER      DEFAULT NULL,
    x_auth_id                           IN     NUMBER      DEFAULT NULL,
    x_flag                              IN     VARCHAR2    DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_first_name                        IN     VARCHAR2    DEFAULT NULL,
    x_last_name                         IN     VARCHAR2    DEFAULT NULL,
    x_address1                          IN     VARCHAR2    DEFAULT NULL,
    x_address2                          IN     VARCHAR2    DEFAULT NULL,
    x_address3                          IN     VARCHAR2    DEFAULT NULL,
    x_address4                          IN     VARCHAR2    DEFAULT NULL,
    x_city                              IN     VARCHAR2    DEFAULT NULL,
    x_state                             IN     VARCHAR2    DEFAULT NULL,
    x_province                          IN     VARCHAR2    DEFAULT NULL,
    x_county                            IN     VARCHAR2    DEFAULT NULL,
    x_country                           IN     VARCHAR2    DEFAULT NULL,
    x_sex                               IN     VARCHAR2    DEFAULT NULL,
    x_birth_dt                          IN     DATE        DEFAULT NULL,
    x_ssn_no                            IN     VARCHAR2    DEFAULT NULL,
    x_marital_status                    IN     VARCHAR2    DEFAULT NULL,
    x_visa_type                         IN     VARCHAR2    DEFAULT NULL,
    x_visa_category                     IN     VARCHAR2    DEFAULT NULL,
    x_visa_number                       IN     VARCHAR2    DEFAULT NULL,
    x_visa_expiry_dt                    IN     DATE        DEFAULT NULL,
    x_entry_date                        IN     DATE        DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_threshold_perct                   IN     NUMBER      DEFAULT NULL,
    x_threshold_value                   IN     NUMBER      DEFAULT NULL,
    x_accepted_amnt                     IN     NUMBER      DEFAULT NULL,
    x_aw_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_aw_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_authorization_date                IN     DATE        DEFAULT NULL,
    x_notification_date                 IN     DATE        DEFAULT NULL
  );

END igf_se_auth_pkg;

 

/
