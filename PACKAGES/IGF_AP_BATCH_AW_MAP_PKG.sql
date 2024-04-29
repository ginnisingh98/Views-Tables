--------------------------------------------------------
--  DDL for Package IGF_AP_BATCH_AW_MAP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_BATCH_AW_MAP_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI22S.pls 120.1 2005/07/12 08:23:23 appldev ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_AP_BATCH_AW_MAP_PKG
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
 |                                                                       |
 | bannamal      29-Sep-2004  3416863 cod xml changes for pell and       |
 |                            direct loan. added two new columns         |
 | cdcruz        02-Jun-2003  #2858504  Legacy Part 1 FA118.1            |
 |                            Added new col award_year_status_code per the
 |                            TD                                         |
 | masehgal      17-Oct-2002  # 2613546  FA 105_108 Multiple Award Years |
 |                            Added unique check on system award year    |
 |                            Added  new column :                        |
 |                            sys_award_year                             |
 | brajendr      04-Jul-2002  Bug # 2436484 - FACR009 Calendar Relations |
 |                            Following columns are obsoleted. Signature |
 |                            of PKG is retained and all the references  |
 |                            are removed                                |
 |                              ci_sequence_number_acad                  |
 |                              ci_cal_type_acad                         |
 |                              ci_cal_type_adm                          |
 |                              ci_sequence_number_adm                   |
 |                                                                       |
 *=======================================================================*/

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_year                        IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number_acad           IN     NUMBER     DEFAULT NULL,
    x_ci_cal_type_acad                  IN     VARCHAR2   DEFAULT NULL,
    x_ci_cal_type_adm                   IN     VARCHAR2   DEFAULT NULL,
    x_ci_sequence_number_adm            IN     NUMBER     DEFAULT NULL,
    x_bam_id                            IN OUT NOCOPY NUMBER,
    x_css_academic_year                 IN     NUMBER,
    x_efc_frml                          IN     VARCHAR2,
    x_num_days_divisor                  IN     NUMBER,
    x_roundoff_fact                     IN     VARCHAR2,
    x_efc_dob                           IN     DATE,
    x_dl_code                           IN     VARCHAR2   DEFAULT NULL,
    x_ffel_code                         IN     VARCHAR2   DEFAULT NULL,
    x_pell_code                         IN     VARCHAR2   DEFAULT NULL,
    x_isir_code                         IN     VARCHAR2   DEFAULT NULL,
    x_profile_code                      IN     VARCHAR2   DEFAULT NULL,
    x_tolerance_limit                   IN     NUMBER     DEFAULT NULL,
    x_sys_award_year                    IN     VARCHAR2   DEFAULT NULL,
    x_award_year_status_code            IN     VARCHAR2   DEFAULT NULL,
    x_pell_participant_code             IN     VARCHAR2   DEFAULT NULL,
    x_dl_participant_code               IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2   DEFAULT 'R',
    x_publish_in_ss_flag                IN     VARCHAR2    DEFAULT NULL
      );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_year                        IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number_acad           IN     NUMBER     DEFAULT NULL,
    x_ci_cal_type_acad                  IN     VARCHAR2   DEFAULT NULL,
    x_ci_cal_type_adm                   IN     VARCHAR2   DEFAULT NULL,
    x_ci_sequence_number_adm            IN     NUMBER     DEFAULT NULL,
    x_bam_id                            IN     NUMBER,
    x_css_academic_year                 IN     NUMBER,
    x_efc_frml                          IN     VARCHAR2,
    x_num_days_divisor                  IN     NUMBER,
    x_roundoff_fact                     IN     VARCHAR2,
    x_efc_dob                           IN     DATE,
    x_dl_code                           IN     VARCHAR2   DEFAULT NULL,
    x_ffel_code                         IN     VARCHAR2   DEFAULT NULL,
    x_pell_code                         IN     VARCHAR2   DEFAULT NULL,
    x_isir_code                         IN     VARCHAR2   DEFAULT NULL,
    x_profile_code                      IN     VARCHAR2   DEFAULT NULL,
    x_tolerance_limit                   IN     NUMBER     DEFAULT NULL,
    x_sys_award_year                    IN     VARCHAR2   DEFAULT NULL,
    x_award_year_status_code            IN     VARCHAR2   DEFAULT NULL,
    x_pell_participant_code             IN     VARCHAR2   DEFAULT NULL,
    x_dl_participant_code               IN     VARCHAR2   DEFAULT NULL,
    x_publish_in_ss_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_year                        IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number_acad           IN     NUMBER     DEFAULT NULL,
    x_ci_cal_type_acad                  IN     VARCHAR2   DEFAULT NULL,
    x_ci_cal_type_adm                   IN     VARCHAR2   DEFAULT NULL,
    x_ci_sequence_number_adm            IN     NUMBER     DEFAULT NULL,
    x_bam_id                            IN     NUMBER,
    x_css_academic_year                 IN     NUMBER,
    x_efc_frml                          IN     VARCHAR2,
    x_num_days_divisor                  IN     NUMBER,
    x_roundoff_fact                     IN     VARCHAR2,
    x_efc_dob                           IN     DATE,
    x_dl_code                           IN     VARCHAR2   DEFAULT NULL,
    x_ffel_code                         IN     VARCHAR2   DEFAULT NULL,
    x_pell_code                         IN     VARCHAR2   DEFAULT NULL,
    x_isir_code                         IN     VARCHAR2   DEFAULT NULL,
    x_profile_code                      IN     VARCHAR2   DEFAULT NULL,
    x_tolerance_limit                   IN     NUMBER     DEFAULT NULL,
    x_sys_award_year                    IN     VARCHAR2   DEFAULT NULL,
    x_award_year_status_code            IN     VARCHAR2   DEFAULT NULL,
    x_pell_participant_code             IN     VARCHAR2   DEFAULT NULL,
    x_dl_participant_code               IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2   DEFAULT 'R',
    x_publish_in_ss_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_year                        IN     NUMBER,
    x_ci_sequence_number                IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number_acad           IN     NUMBER     DEFAULT NULL,
    x_ci_cal_type_acad                  IN     VARCHAR2   DEFAULT NULL,
    x_ci_cal_type_adm                   IN     VARCHAR2   DEFAULT NULL,
    x_ci_sequence_number_adm            IN     NUMBER     DEFAULT NULL,
    x_bam_id                            IN OUT NOCOPY NUMBER,
    x_css_academic_year                 IN     NUMBER,
    x_efc_frml                          IN     VARCHAR2,
    x_num_days_divisor                  IN     NUMBER,
    x_roundoff_fact                     IN     VARCHAR2,
    x_efc_dob                           IN     DATE,
    x_dl_code                           IN     VARCHAR2   DEFAULT NULL,
    x_ffel_code                         IN     VARCHAR2   DEFAULT NULL,
    x_pell_code                         IN     VARCHAR2   DEFAULT NULL,
    x_isir_code                         IN     VARCHAR2   DEFAULT NULL,
    x_profile_code                      IN     VARCHAR2   DEFAULT NULL,
    x_tolerance_limit                   IN     NUMBER     DEFAULT NULL,
    x_sys_award_year                    IN     VARCHAR2   DEFAULT NULL,
    x_award_year_status_code            IN     VARCHAR2   DEFAULT NULL,
    x_pell_participant_code             IN     VARCHAR2   DEFAULT NULL,
    x_dl_participant_code               IN     VARCHAR2   DEFAULT NULL,
    x_mode                              IN     VARCHAR2   DEFAULT 'R',
    x_publish_in_ss_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_bam_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk2_for_validation (
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN;

  FUNCTION get_uk6_for_validation (
    x_sys_award_year                    IN     VARCHAR2
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igs_ca_inst (
    x_cal_type                          IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_batch_year                        IN     NUMBER      DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number_acad           IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type_acad                  IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type_adm                   IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number_adm            IN     NUMBER      DEFAULT NULL,
    x_bam_id                            IN     NUMBER      DEFAULT NULL,
    x_css_academic_year                 IN     NUMBER      DEFAULT NULL,
    x_efc_frml                          IN     VARCHAR2    DEFAULT NULL,
    x_num_days_divisor                  IN     NUMBER      DEFAULT NULL,
    x_roundoff_fact                     IN     VARCHAR2    DEFAULT NULL,
    x_efc_dob                           IN     DATE        DEFAULT NULL,
    x_dl_code                           IN     VARCHAR2    DEFAULT NULL,
    x_ffel_code                         IN     VARCHAR2    DEFAULT NULL,
    x_pell_code                         IN     VARCHAR2    DEFAULT NULL,
    x_isir_code                         IN     VARCHAR2    DEFAULT NULL,
    x_profile_code                      IN     VARCHAR2    DEFAULT NULL,
    x_tolerance_limit                   IN     NUMBER      DEFAULT NULL,
    x_sys_award_year                    IN     VARCHAR2    DEFAULT NULL,
    x_award_year_status_code            IN     VARCHAR2    DEFAULT NULL,
    x_pell_participant_code             IN     VARCHAR2    DEFAULT NULL,
    x_dl_participant_code               IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_publish_in_ss_flag                IN     VARCHAR2    DEFAULT NULL
  );

END igf_ap_batch_aw_map_pkg;

 

/
