--------------------------------------------------------
--  DDL for Package IGF_AP_TD_ITEM_INST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AP_TD_ITEM_INST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFAI15S.pls 120.1 2005/08/03 03:14:10 appldev ship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_AP_TD_ITEM_INST_PKG
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
 | HISTORY:                                                              |
 | Who        When             What                                      |
 | masehgal   28-Apr-2002      # 2303509  Added get uk for validation    |
 | bkkumar    04-jun-2003      Added legacy_ record_flag in the tbh calls|
 |                             #2858504                                  |
 *=======================================================================*/

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_add_date                          IN     DATE,
    x_corsp_date                        IN     DATE,
    x_corsp_count                       IN     NUMBER,
    x_inactive_flag                     IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_clprl_id                          IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_add_date                          IN     DATE,
    x_corsp_date                        IN     DATE,
    x_corsp_count                       IN     NUMBER,
    x_inactive_flag                     IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_clprl_id                          IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_add_date                          IN     DATE,
    x_corsp_date                        IN     DATE,
    x_corsp_count                       IN     NUMBER,
    x_inactive_flag                     IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_clprl_id                          IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER,
    x_status                            IN     VARCHAR2,
    x_status_date                       IN     DATE,
    x_add_date                          IN     DATE,
    x_corsp_date                        IN     DATE,
    x_corsp_count                       IN     NUMBER,
    x_inactive_flag                     IN     VARCHAR2,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R' ,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_clprl_id                          IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_base_id                           IN     NUMBER,
    x_item_sequence_number              IN     NUMBER
  ) RETURN BOOLEAN;


  -- # 2303509  Added Check for Uniqueness
  FUNCTION get_uk_for_validation (
    x_base_id                           IN     NUMBER,
    x_item_sequence_number               IN     NUMBER
  ) RETURN BOOLEAN;


  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_ap_td_item_mst (
    x_todo_number              IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_item_sequence_number              IN     NUMBER      DEFAULT NULL,
    x_status                            IN     VARCHAR2    DEFAULT NULL,
    x_status_date                       IN     DATE        DEFAULT NULL,
    x_add_date                          IN     DATE        DEFAULT NULL,
    x_corsp_date                        IN     DATE        DEFAULT NULL,
    x_corsp_count                       IN     NUMBER      DEFAULT NULL,
    x_inactive_flag                     IN     VARCHAR2    DEFAULT NULL,
    x_freq_attempt                      IN     NUMBER      DEFAULT NULL,
    x_max_attempt                       IN     NUMBER      DEFAULT NULL,
    x_required_for_application          IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_clprl_id                          IN     NUMBER      DEFAULT NULL
  );

  PROCEDURE after_dml(
                      p_action  IN VARCHAR2
                     );


END igf_ap_td_item_inst_pkg;

 

/
