--------------------------------------------------------
--  DDL for Package IGF_AW_AWARD_LEVEL_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_AWARD_LEVEL_HIST_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI72S.pls 120.0 2005/09/09 17:11:18 appldev noship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_AW_AWARD_LEVEL_HIST_PKG
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
 *=======================================================================*/

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2,
    x_award_change_source_code          IN     VARCHAR2,
    x_old_offered_amt                   IN     NUMBER,
    x_new_offered_amt                   IN     NUMBER,
    x_old_accepted_amt                  IN     NUMBER,
    x_new_accepted_amt                  IN     NUMBER,
    x_old_paid_amt                      IN     NUMBER,
    x_new_paid_amt                      IN     NUMBER,
    x_old_lock_award_flag               IN     VARCHAR2,
    x_new_lock_award_flag               IN     VARCHAR2,
    x_old_award_status_code             IN     VARCHAR2,
    x_new_award_status_code             IN     VARCHAR2,
    x_old_adplans_id                    IN     NUMBER,
    x_new_adplans_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2,
    x_award_change_source_code          IN     VARCHAR2,
    x_old_offered_amt                   IN     NUMBER,
    x_new_offered_amt                   IN     NUMBER,
    x_old_accepted_amt                  IN     NUMBER,
    x_new_accepted_amt                  IN     NUMBER,
    x_old_paid_amt                      IN     NUMBER,
    x_new_paid_amt                      IN     NUMBER,
    x_old_lock_award_flag               IN     VARCHAR2,
    x_new_lock_award_flag               IN     VARCHAR2,
    x_old_award_status_code             IN     VARCHAR2,
    x_new_award_status_code             IN     VARCHAR2,
    x_old_adplans_id                    IN     NUMBER,
    x_new_adplans_id                    IN     NUMBER
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2,
    x_award_change_source_code          IN     VARCHAR2,
    x_old_offered_amt                   IN     NUMBER,
    x_new_offered_amt                   IN     NUMBER,
    x_old_accepted_amt                  IN     NUMBER,
    x_new_accepted_amt                  IN     NUMBER,
    x_old_paid_amt                      IN     NUMBER,
    x_new_paid_amt                      IN     NUMBER,
    x_old_lock_award_flag               IN     VARCHAR2,
    x_new_lock_award_flag               IN     VARCHAR2,
    x_old_award_status_code             IN     VARCHAR2,
    x_new_award_status_code             IN     VARCHAR2,
    x_old_adplans_id                    IN     NUMBER,
    x_new_adplans_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2,
    x_award_change_source_code          IN     VARCHAR2,
    x_old_offered_amt                   IN     NUMBER,
    x_new_offered_amt                   IN     NUMBER,
    x_old_accepted_amt                  IN     NUMBER,
    x_new_accepted_amt                  IN     NUMBER,
    x_old_paid_amt                      IN     NUMBER,
    x_new_paid_amt                      IN     NUMBER,
    x_old_lock_award_flag               IN     VARCHAR2,
    x_new_lock_award_flag               IN     VARCHAR2,
    x_old_award_status_code             IN     VARCHAR2,
    x_new_award_status_code             IN     VARCHAR2,
    x_old_adplans_id                    IN     NUMBER,
    x_new_adplans_id                    IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R'
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_award_id                          IN     NUMBER,
    x_award_hist_tran_id                IN     NUMBER,
    x_award_attrib_code                 IN     VARCHAR2
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_awd_dist_plans (
    x_adplans_id                        IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_award (
    x_award_id                          IN     NUMBER
  );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_award_hist_tran_id                IN     NUMBER      DEFAULT NULL,
    x_award_attrib_code                 IN     VARCHAR2    DEFAULT NULL,
    x_award_change_source_code          IN     VARCHAR2    DEFAULT NULL,
    x_old_offered_amt                   IN     NUMBER      DEFAULT NULL,
    x_new_offered_amt                   IN     NUMBER      DEFAULT NULL,
    x_old_accepted_amt                  IN     NUMBER      DEFAULT NULL,
    x_new_accepted_amt                  IN     NUMBER      DEFAULT NULL,
    x_old_paid_amt                      IN     NUMBER      DEFAULT NULL,
    x_new_paid_amt                      IN     NUMBER      DEFAULT NULL,
    x_old_lock_award_flag               IN     VARCHAR2    DEFAULT NULL,
    x_new_lock_award_flag               IN     VARCHAR2    DEFAULT NULL,
    x_old_award_status_code             IN     VARCHAR2    DEFAULT NULL,
    x_new_award_status_code             IN     VARCHAR2    DEFAULT NULL,
    x_old_adplans_id                    IN     NUMBER      DEFAULT NULL,
    x_new_adplans_id                    IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_award_level_hist_pkg;

 

/
