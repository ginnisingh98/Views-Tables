--------------------------------------------------------
--  DDL for Package IGF_AW_AWARD_T_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_AWARD_T_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI26S.pls 120.0 2005/06/01 14:15:40 appldev noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_AW_AWARD_T_PKG
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
 | WHO                  WHEN             WHAT                            |
 | veramach             12-Oct-2004      FA 152 Added award_id,          |
 |                                       lock_award_flag                 |
 | veramach             03-DEC-2003      FA 131 Added app_trans_num_txt  |
 | veramach             21-NOV-2003      FA 125 Added adplans_id to tbh  |
 *=======================================================================*/

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_process_id                        IN     NUMBER,
    x_sl_number                         IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_need_reduction_amt                IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_temp_num_val1                     IN     NUMBER,
    x_temp_num_val2                     IN     NUMBER,
    x_temp_char_val1                    IN     VARCHAR2,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_temp_val3_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_val4_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_char2_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_temp_char3_txt                    IN     VARCHAR2    DEFAULT NULL

  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_process_id                        IN     NUMBER,
    x_sl_number                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_need_reduction_amt                IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_temp_num_val1                     IN     NUMBER,
    x_temp_num_val2                     IN     NUMBER,
    x_temp_char_val1                    IN     VARCHAR2,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_temp_val3_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_val4_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_char2_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_temp_char3_txt                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_process_id                        IN     NUMBER,
    x_sl_number                         IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_need_reduction_amt                IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_temp_num_val1                     IN     NUMBER,
    x_temp_num_val2                     IN     NUMBER,
    x_temp_char_val1                    IN     VARCHAR2,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_temp_val3_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_val4_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_char2_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_temp_char3_txt                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_process_id                        IN     NUMBER,
    x_sl_number                         IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_need_reduction_amt                IN     NUMBER,
    x_flag                              IN     VARCHAR2,
    x_temp_num_val1                     IN     NUMBER,
    x_temp_num_val2                     IN     NUMBER,
    x_temp_char_val1                    IN     VARCHAR2,
    x_tp_cal_type                       IN     VARCHAR2,
    x_tp_sequence_number                IN     NUMBER,
    x_ld_cal_type                       IN     VARCHAR2,
    x_ld_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_temp_val3_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_val4_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_char2_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_temp_char3_txt                    IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_process_id                        IN     NUMBER,
    x_sl_number                         IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_process_id                        IN     NUMBER      DEFAULT NULL,
    x_sl_number                         IN     NUMBER      DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_offered_amt                       IN     NUMBER      DEFAULT NULL,
    x_accepted_amt                      IN     NUMBER      DEFAULT NULL,
    x_paid_amt                          IN     NUMBER      DEFAULT NULL,
    x_need_reduction_amt                IN     NUMBER      DEFAULT NULL,
    x_flag                              IN     VARCHAR2    DEFAULT NULL,
    x_temp_num_val1                     IN     NUMBER      DEFAULT NULL,
    x_temp_num_val2                     IN     NUMBER      DEFAULT NULL,
    x_temp_char_val1                    IN     VARCHAR2    DEFAULT NULL,
    x_tp_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_tp_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_ld_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ld_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_temp_val3_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_val4_num                     IN     NUMBER      DEFAULT NULL,
    x_temp_char2_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_temp_char3_txt                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  );

END igf_aw_award_t_pkg;

 

/
