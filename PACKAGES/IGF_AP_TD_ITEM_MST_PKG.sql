--------------------------------------------------------
--  DDL for Package IGF_AP_TD_ITEM_MST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_TD_ITEM_MST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI37S.pls 120.1 2005/08/02 00:18:01 appldev ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_AP_TD_ITEM_MST_PKG
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
 | gvarapra         13-sep-2004     FA138 - ISIR Enhancements            |
 |                                 added new cloumn system_todo_type_code|
 *=======================================================================*/

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_todo_number                       IN OUT NOCOPY NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_corsp_mesg                        IN     VARCHAR2,
    x_career_item                       IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_system_todo_type_code             IN     VARCHAR2    DEFAULT NULL,
    x_application_code                  IN     VARCHAR2    DEFAULT NULL,
    x_display_in_ss_flag                IN     VARCHAR2    DEFAULT NULL,
    x_ss_instruction_txt                IN     VARCHAR2    DEFAULT NULL,
    x_allow_attachment_flag             IN     VARCHAR2    DEFAULT NULL,
    x_document_url_txt                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_todo_number                       IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_corsp_mesg                        IN     VARCHAR2,
    x_career_item                       IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_system_todo_type_code             IN     VARCHAR2    DEFAULT NULL,
    x_application_code                  IN     VARCHAR2    DEFAULT NULL,
    x_display_in_ss_flag                IN     VARCHAR2    DEFAULT NULL,
    x_ss_instruction_txt                IN     VARCHAR2    DEFAULT NULL,
    x_allow_attachment_flag             IN     VARCHAR2    DEFAULT NULL,
    x_document_url_txt                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_todo_number                       IN     NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_corsp_mesg                        IN     VARCHAR2,
    x_career_item                       IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_system_todo_type_code             IN     VARCHAR2    DEFAULT NULL,
    x_application_code                  IN     VARCHAR2    DEFAULT NULL,
    x_display_in_ss_flag                IN     VARCHAR2    DEFAULT NULL,
    x_ss_instruction_txt                IN     VARCHAR2    DEFAULT NULL,
    x_allow_attachment_flag             IN     VARCHAR2    DEFAULT NULL,
    x_document_url_txt                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_todo_number                       IN OUT NOCOPY NUMBER,
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_corsp_mesg                        IN     VARCHAR2,
    x_career_item                       IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_system_todo_type_code             IN     VARCHAR2    DEFAULT NULL,
    x_application_code                  IN     VARCHAR2    DEFAULT NULL,
    x_display_in_ss_flag                IN     VARCHAR2    DEFAULT NULL,
    x_ss_instruction_txt                IN     VARCHAR2    DEFAULT NULL,
    x_allow_attachment_flag             IN     VARCHAR2    DEFAULT NULL,
    x_document_url_txt                  IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_todo_number                       IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_ap_appl_setup(
    x_ci_cal_type          IN     VARCHAR2,
    x_ci_sequence_number   IN     NUMBER,
    x_application_code     IN     VARCHAR2
  );

  FUNCTION get_uk_for_validation (
    x_item_code                         IN     VARCHAR2,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_org_id                            IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_todo_number                       IN     NUMBER      DEFAULT NULL,
    x_item_code                         IN     VARCHAR2    DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_corsp_mesg                        IN     VARCHAR2    DEFAULT NULL,
    x_career_item                       IN     VARCHAR2    DEFAULT NULL,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_system_todo_type_code             IN     VARCHAR2    DEFAULT NULL,
    x_application_code                  IN     VARCHAR2    DEFAULT NULL,
    x_display_in_ss_flag                IN     VARCHAR2    DEFAULT NULL,
    x_ss_instruction_txt                IN     VARCHAR2    DEFAULT NULL,
    x_allow_attachment_flag             IN     VARCHAR2    DEFAULT NULL,
    x_document_url_txt                  IN     VARCHAR2    DEFAULT NULL
  );

END igf_ap_td_item_mst_pkg;

 

/
