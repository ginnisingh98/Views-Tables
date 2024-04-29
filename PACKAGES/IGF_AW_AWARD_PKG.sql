--------------------------------------------------------
--  DDL for Package IGF_AW_AWARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGF_AW_AWARD_PKG" AUTHID CURRENT_USER AS
/* $Header: IGFWI22S.pls 120.3 2005/06/30 07:20:41 appldev ship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL spec for package: IGF_AW_AWARD_PKG                        |
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
 |-----------------------------------------------------------------------|
 | bvisvana  24-May-2005  FA 157 - Award History changes. Added procedure|
 |				                         set_award_source_change		           |
 |-----------------------------------------------------------------------|
 | smadathi  13-Oct-2004   Bug 3416936                                   |
 |                         Modified the call to update row               |
 |-----------------------------------------------------------------------|
 | sjadhav  1-Dec-2003   Bug 3252832 - FA 131 Build                      |
 |                       Added two new columns for this build            |
 |-----------------------------------------------------------------------|
 | veramach 1-NOV-2003   #3160568 Added adplans_id in the tbh calls      |
 |-----------------------------------------------------------------------|
 | brajendr 21-Jul-2003  Bug 2991359                                     |
 |                       Added check child existance for igf_gr_rfms     |
 |-----------------------------------------------------------------------|
 | sjadhav  03-Jul-2003  Bug 3029739                                     |
 |                       Modified igf_aw_gen.update_fmast call for       |
 |                       INSERT routine                                  |
 |-----------------------------------------------------------------------|
 | bkkumar  04-jun-2003  Bug 2858504 Added  award_ number _txt and       |
 |                       legacy_ record_flagin the tbh calls             |
 |-----------------------------------------------------------------------|
 | adhawan  25-oct-2002  Bug 2613546. Added alt_pell_schedule in the     |
 |                       table handler calls gscc warnings fixed         |
 *=======================================================================*/



  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_packaging_type                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_manual_update                     IN     VARCHAR2,
    x_rules_override                    IN     VARCHAR2,
    x_award_date                        IN     DATE,
    x_award_status                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_rvsn_id                           IN     NUMBER,
    x_alt_pell_schedule                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_award_number_txt                  IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_awd_proc_status_code              IN     VARCHAR2    DEFAULT NULL,
    x_notification_status_code		      IN     VARCHAR2    DEFAULT NULL,
    x_notification_status_date		      IN     DATE        DEFAULT NULL,
    x_publish_in_ss_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_packaging_type                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_manual_update                     IN     VARCHAR2,
    x_rules_override                    IN     VARCHAR2,
    x_award_date                        IN     DATE,
    x_award_status                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_rvsn_id                           IN     NUMBER ,
    x_alt_pell_schedule                 IN     VARCHAR2    DEFAULT NULL,
    x_award_number_txt                  IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_awd_proc_status_code              IN     VARCHAR2    DEFAULT NULL,
    x_notification_status_code		      IN     VARCHAR2    DEFAULT NULL,
    x_notification_status_date		      IN     DATE        DEFAULT NULL,
    x_publish_in_ss_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_award_id                          IN     NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_packaging_type                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_manual_update                     IN     VARCHAR2,
    x_rules_override                    IN     VARCHAR2,
    x_award_date                        IN     DATE,
    x_award_status                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_rvsn_id                           IN     NUMBER,
    x_alt_pell_schedule                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_award_number_txt                  IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_awd_proc_status_code              IN     VARCHAR2    DEFAULT NULL,
    x_notification_status_code		      IN     VARCHAR2    DEFAULT NULL,
    x_notification_status_date		      IN     DATE        DEFAULT NULL,
    x_called_from                       IN     VARCHAR2    DEFAULT NULL,
    x_publish_in_ss_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_award_id                          IN OUT NOCOPY NUMBER,
    x_fund_id                           IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_offered_amt                       IN     NUMBER,
    x_accepted_amt                      IN     NUMBER,
    x_paid_amt                          IN     NUMBER,
    x_packaging_type                    IN     VARCHAR2,
    x_batch_id                          IN     VARCHAR2,
    x_manual_update                     IN     VARCHAR2,
    x_rules_override                    IN     VARCHAR2,
    x_award_date                        IN     DATE,
    x_award_status                      IN     VARCHAR2,
    x_attribute_category                IN     VARCHAR2,
    x_attribute1                        IN     VARCHAR2,
    x_attribute2                        IN     VARCHAR2,
    x_attribute3                        IN     VARCHAR2,
    x_attribute4                        IN     VARCHAR2,
    x_attribute5                        IN     VARCHAR2,
    x_attribute6                        IN     VARCHAR2,
    x_attribute7                        IN     VARCHAR2,
    x_attribute8                        IN     VARCHAR2,
    x_attribute9                        IN     VARCHAR2,
    x_attribute10                       IN     VARCHAR2,
    x_attribute11                       IN     VARCHAR2,
    x_attribute12                       IN     VARCHAR2,
    x_attribute13                       IN     VARCHAR2,
    x_attribute14                       IN     VARCHAR2,
    x_attribute15                       IN     VARCHAR2,
    x_attribute16                       IN     VARCHAR2,
    x_attribute17                       IN     VARCHAR2,
    x_attribute18                       IN     VARCHAR2,
    x_attribute19                       IN     VARCHAR2,
    x_attribute20                       IN     VARCHAR2,
    x_rvsn_id                           IN     NUMBER,
    x_alt_pell_schedule                 IN     VARCHAR2    DEFAULT NULL,
    x_mode                              IN     VARCHAR2    DEFAULT 'R',
    x_award_number_txt                  IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_awd_proc_status_code              IN     VARCHAR2    DEFAULT NULL,
    x_notification_status_code		      IN     VARCHAR2    DEFAULT NULL,
    x_notification_status_date		      IN     DATE        DEFAULT NULL,
    x_publish_in_ss_flag                IN     VARCHAR2    DEFAULT NULL
  );

  PROCEDURE delete_row (
    x_rowid                             IN     VARCHAR2
  );

  FUNCTION get_pk_for_validation (
    x_award_id                          IN     NUMBER
  ) RETURN BOOLEAN;

  PROCEDURE get_fk_igf_aw_awd_rvsn_rsn (
    x_rvsn_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_fund_mast (
    x_fund_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  );

  PROCEDURE get_fk_igf_aw_awd_dist_plans(
                                         x_adplans_id      IN NUMBER
                                        );

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_award_id                          IN     NUMBER      DEFAULT NULL,
    x_fund_id                           IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_offered_amt                       IN     NUMBER      DEFAULT NULL,
    x_accepted_amt                      IN     NUMBER      DEFAULT NULL,
    x_paid_amt                          IN     NUMBER      DEFAULT NULL,
    x_packaging_type                    IN     VARCHAR2    DEFAULT NULL,
    x_batch_id                          IN     VARCHAR2    DEFAULT NULL,
    x_manual_update                     IN     VARCHAR2    DEFAULT NULL,
    x_rules_override                    IN     VARCHAR2    DEFAULT NULL,
    x_award_date                        IN     DATE        DEFAULT NULL,
    x_award_status                      IN     VARCHAR2    DEFAULT NULL,
    x_attribute_category                IN     VARCHAR2    DEFAULT NULL,
    x_attribute1                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute2                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute3                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute4                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute5                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute6                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute7                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute8                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute9                        IN     VARCHAR2    DEFAULT NULL,
    x_attribute10                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute11                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute12                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute13                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute14                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute15                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute16                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute17                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute18                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute19                       IN     VARCHAR2    DEFAULT NULL,
    x_attribute20                       IN     VARCHAR2    DEFAULT NULL,
    x_rvsn_id                           IN     NUMBER      DEFAULT NULL,
    x_alt_pell_schedule                 IN     VARCHAR2    DEFAULT NULL,
    x_award_number_txt                  IN     VARCHAR2    DEFAULT NULL,
    x_legacy_record_flag                IN     VARCHAR2    DEFAULT NULL,
    x_adplans_id                        IN     NUMBER      DEFAULT NULL,
    x_lock_award_flag                   IN     VARCHAR2    DEFAULT NULL,
    x_app_trans_num_txt                 IN     VARCHAR2    DEFAULT NULL,
    x_awd_proc_status_code              IN     VARCHAR2    DEFAULT NULL,
    x_notification_status_code		      IN     VARCHAR2	   DEFAULT NULL,
    x_notification_status_date		      IN     DATE	       DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_publish_in_ss_flag                IN     VARCHAR2    DEFAULT NULL
  );


  /*
  Created By : bvisvana
  Created On : 24-May-2005
  Purpose : Sets the award change source
  Known limitations, enhancements or remarks :
  Change History :
  Who             When            What
  -------------------------------------
  -------------------------------------
  (reverse chronological order - newest change first)
  */
  PROCEDURE set_award_change_source(
                                         p_award_change_source  IN igf_aw_award_level_hist.AWARD_CHANGE_SOURCE_CODE%TYPE
                                   );

  /*
  Created By : bvisvana
  Created On : 15-Jun-2005
  Purpose : Reset the Award History Transaction Id
  Known limitations, enhancements or remarks :
  Change History :
  Who             When            What
  -------------------------------------
  -------------------------------------
  (reverse chronological order - newest change first)
  */
  PROCEDURE reset_awd_hist_trans_id;


END igf_aw_award_pkg;

 

/
