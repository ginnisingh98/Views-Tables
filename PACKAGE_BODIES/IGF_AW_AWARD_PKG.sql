--------------------------------------------------------
--  DDL for Package Body IGF_AW_AWARD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_AWARD_PKG" AS
/* $Header: IGFWI22B.pls 120.5 2006/08/03 12:14:46 tsailaja ship $ */
/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, CalIFornia, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_AW_AWARD_PKG
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
 | based on the primary key, and updates the row IF it exists,           |
 | or inserts the row IF it doesn't already exist.                       |
 |                                                                       |
 | This module is called by AutoInstall (afplss.drv) on install and      |
 | upgrade.  The WHENEVER SQLERROR and EXIT (at bottom) are required.    |
 |                                                                       |
 | HISTORY                                                               |
 |-----------------------------------------------------------------------|
 |tsailaja  03-Aug-2006  Bug #5337555                                    |
 |                       Included 'GPLUSFL' fund code.                   |
 |                      so that any change to GPLUSFL awards gets logged |
 | bvisvana 24-May-2005 FA 157 - Bug # 4382371                           |
 |                      Award History changes. Added procedures          |
 |				              set_award_source_change,                         |
 |                      update_award_history,check_award_history         |
 |				              isChangeIn_AwardAttribute		                     |
 |-----------------------------------------------------------------------|
 | smadathi 13-Oct-2004  Bug 3416936  ModIFied as per the TD             |
 |                       Added AfterRowInsertUpdateDelete1 and after_dml |
 |                       procedures                                      |
 |-----------------------------------------------------------------------|
 | bannamal 28-Sep-2004  Bug 3416863 - FA149 COD XML                     |
 |                       Added check child existance for igf_gr_cod_dtls |
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
 |                       ModIFied igf_aw_gen.update_fmast call for       |
 |                       INSERT routine                                  |
 |-----------------------------------------------------------------------|
 | bkkumar  04-jun-2003  Bug 2858504 Added  award_ number _txt and       |
 |                       legacy_ record_flagin the tbh calls             |
 |-----------------------------------------------------------------------|
 | adhawan  25-oct-2002  Bug 2613546. Added alt_pell_schedule in the     |
 |                       table handler calls gscc warnings fixed         |
 *=======================================================================*/

  l_rowid VARCHAR2(25);
  old_references igf_aw_award_all%ROWTYPE;
  new_references igf_aw_award_all%ROWTYPE;
  g_v_called_from VARCHAR2(30);
  -- FA 157 - Global variables for Award change Source and Award history transaction id
  g_award_change_source igf_aw_award_level_hist.AWARD_CHANGE_SOURCE_CODE%TYPE := 'CONCURRENT_PROCESS';
  g_award_hist_tran_id igf_aw_award_level_hist.AWARD_HIST_TRAN_ID%TYPE;


  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
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
    x_alt_pell_schedule                 IN     VARCHAR2,
    x_award_number_txt                  IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2,
    x_app_trans_num_txt                 IN     VARCHAR2,
    x_awd_proc_status_code              IN     VARCHAR2,
    x_notification_status_code		      IN     VARCHAR2,
    x_notification_status_date		      IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  veramach        1-NOV-2003      #3160568 Added adplans_id to the procedure signature
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_AWARD_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.award_id                          := x_award_id;
    new_references.fund_id                           := x_fund_id;
    new_references.base_id                           := x_base_id;
    new_references.offered_amt                       := x_offered_amt;
    new_references.accepted_amt                      := x_accepted_amt;
    new_references.paid_amt                          := x_paid_amt;
    new_references.packaging_type                    := x_packaging_type;
    new_references.batch_id                          := x_batch_id;
    new_references.manual_update                     := x_manual_update;
    new_references.rules_override                    := x_rules_override;
    new_references.award_date                        := x_award_date;
    new_references.award_status                      := x_award_status;
    new_references.attribute_category                := x_attribute_category;
    new_references.attribute1                        := x_attribute1;
    new_references.attribute2                        := x_attribute2;
    new_references.attribute3                        := x_attribute3;
    new_references.attribute4                        := x_attribute4;
    new_references.attribute5                        := x_attribute5;
    new_references.attribute6                        := x_attribute6;
    new_references.attribute7                        := x_attribute7;
    new_references.attribute8                        := x_attribute8;
    new_references.attribute9                        := x_attribute9;
    new_references.attribute10                       := x_attribute10;
    new_references.attribute11                       := x_attribute11;
    new_references.attribute12                       := x_attribute12;
    new_references.attribute13                       := x_attribute13;
    new_references.attribute14                       := x_attribute14;
    new_references.attribute15                       := x_attribute15;
    new_references.attribute16                       := x_attribute16;
    new_references.attribute17                       := x_attribute17;
    new_references.attribute18                       := x_attribute18;
    new_references.attribute19                       := x_attribute19;
    new_references.attribute20                       := x_attribute20;
    new_references.rvsn_id                           := x_rvsn_id;
    new_references.alt_pell_schedule                 := x_alt_pell_schedule;
    new_references.award_number_txt                  := x_award_number_txt;
    new_references.legacy_record_flag                := x_legacy_record_flag;
    new_references.adplans_id                        := x_adplans_id;
    new_references.lock_award_flag                   := x_lock_award_flag;
    new_references.app_trans_num_txt                 := x_app_trans_num_txt;
    new_references.awd_proc_status_code              := x_awd_proc_status_code;
    new_references.notification_status_code          := x_notification_status_code;
    new_references.notification_status_date          := x_notification_status_date;
    new_references.publish_in_ss_flag                := x_publish_in_ss_flag;


    IF (p_action = 'UPDATE') THEN
      new_references.creation_date                   := old_references.creation_date;
      new_references.created_by                      := old_references.created_by;
    ELSE
      new_references.creation_date                   := x_creation_date;
      new_references.created_by                      := x_created_by;
    END IF;

    new_references.last_update_date                  := x_last_update_date;
    new_references.last_updated_by                   := x_last_updated_by;
    new_references.last_update_login                 := x_last_update_login;

  END set_column_values;

  PROCEDURE AfterRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating  IN BOOLEAN ,
    p_deleting  IN BOOLEAN
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By : Sanil Madathil
  ||  Created On : 13-Oct-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  tsailaja      03/08/2006     Bug #5337555 FA 163 Include 'GPLUSFL' fund code.
  --------------------------------------------------------------------*/
   CURSOR c_sl_clchsn_dtls (
     cp_n_award_id igf_aw_award_all.award_id%TYPE
   ) IS
   SELECT chdt.ROWID row_id,chdt.*
   FROM   igf_sl_clchsn_dtls chdt
   WHERE  chdt.award_id = cp_n_award_id
   AND    chdt.status_code IN ('R','N','D')
   AND    chdt.response_status_code IS NULL
   AND    chdt.cl_version_code = 'RELEASE-4';

   rec_c_sl_clchsn_dtls c_sl_clchsn_dtls%ROWTYPE;

    l_v_fed_fund_code  igf_aw_fund_cat_all.fed_fund_code%TYPE;
    l_v_message_name   fnd_new_messages.message_name%TYPE;
    l_b_return_status  BOOLEAN;
  BEGIN
    IF p_updating THEN
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'inside AfterRowInsertUpdateDelete1 ' );
      END IF;
      l_v_fed_fund_code := igf_sl_gen.get_fed_fund_code (p_n_award_id     => new_references.award_id,
                                                         p_v_message_name => l_v_message_name
                                                         );
      IF l_v_message_name IS NOT NULL THEN
        fnd_message.set_name ('IGS',l_v_message_name);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'fund code       = '||l_v_fed_fund_code );
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'g_v_called_from = '||g_v_called_from );
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'old_references.award_status = '||old_references.award_status );
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'new_references.award_status = '||new_references.award_status );
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'old_references.accepted_amt = '||old_references.accepted_amt );
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'new_references.accepted_amt = '||new_references.accepted_amt );
      END IF;
	  -- tsailaja -FA 163  -Bug 5337555
      IF l_v_fed_fund_code NOT IN ('FLS','FLU','FLP','ALT','GPLUSFL') THEN
        RETURN;
      END IF;
      IF g_v_called_from NOT IN ('IGFAW016','IGFAW038') THEN
        RETURN;
      END IF;
      IF ((new_references.award_status <> old_references.award_status) AND
          new_references.award_status = 'CANCELLED' AND
          new_references.accepted_amt = 0 AND
          g_v_called_from = 'IGFAW016' ) THEN
        -- delete all the change records created for this award id
        FOR rec_c_sl_clchsn_dtls IN  c_sl_clchsn_dtls (cp_n_award_id     => new_references.award_id)
        LOOP
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'rec_c_sl_clchsn_dtls.clchgsnd_id              : '||rec_c_sl_clchsn_dtls.clchgsnd_id );
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'rec_c_sl_clchsn_dtls.loan_number_txt          : '||rec_c_sl_clchsn_dtls.loan_number_txt );
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'rec_c_sl_clchsn_dtls.change_field_code        : '||rec_c_sl_clchsn_dtls.change_field_code );
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'rec_c_sl_clchsn_dtls.change_record_type_txt   : '||rec_c_sl_clchsn_dtls.change_record_type_txt );
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'rec_c_sl_clchsn_dtls.change_code_txt          : '||rec_c_sl_clchsn_dtls.change_code_txt );
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'rec_c_sl_clchsn_dtls.status_code              : '||rec_c_sl_clchsn_dtls.status_code );
          END IF;
          igf_sl_clchsn_dtls_pkg.delete_row(x_rowid =>  rec_c_sl_clchsn_dtls.row_id);
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'Change Send Record deleted successfully  ');
          END IF;
        END LOOP;
      END IF;
      IF ((new_references.award_status <> old_references.award_status) AND
          new_references.award_status = 'CANCELLED' AND
          new_references.accepted_amt = 0)
      THEN
        -- invoke the procedure to create loan cancellation change record in igf_sl_clchsn_dtls table
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'Loan Cancellation. ' );
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'invoking igf_sl_cl_create_chg.create_awd_chg_rec. ' );
        END IF;
        igf_sl_cl_create_chg.create_awd_chg_rec
        (
          p_n_award_id      => new_references.award_id,
          p_n_old_amount    => old_references.accepted_amt ,
          p_n_new_amount    => 0,
          p_v_chg_type      =>'LC',
          p_b_return_status => l_b_return_status,
          p_v_message_name  => l_v_message_name
        );
        -- IF the above call out returns false and error message is returned,
        -- add the message to the error stack and error message test should be displayed
        -- in the calling form
        IF (NOT (l_b_return_status) AND l_v_message_name IS NOT NULL )
        THEN
          -- substring of the out bound parameter l_v_message_name is carried
          -- out since it can expect either IGS OR IGF message
          fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'Call to igf_sl_cl_create_chg.create_awd_chg_rec returned error '|| l_v_message_name);
          END IF;
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;
      END IF;
      -- invoke the procedure to create reinstatement change record in igf_sl_clchsn_dtls table
      IF ((old_references.accepted_amt <> new_references.accepted_amt) AND
          new_references.award_status = 'ACCEPTED') THEN
        IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'Loan reinstatement/loan increase. ' );
          fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'invoking igf_sl_cl_create_chg.create_awd_chg_rec. ' );
        END IF;
        igf_sl_cl_create_chg.create_awd_chg_rec
        (
          p_n_award_id      => new_references.award_id,
          p_n_old_amount    => old_references.accepted_amt ,
          p_n_new_amount    => new_references.accepted_amt,
          p_v_chg_type      =>'RIDC',
          p_b_return_status => l_b_return_status,
          p_v_message_name  => l_v_message_name
        );
        -- IF the above call out returns false and error message is returned,
        -- add the message to the error stack and error message test should be displayed
        -- in the calling form
        IF (NOT (l_b_return_status) AND l_v_message_name IS NOT NULL )
        THEN
          -- substring of the out bound parameter l_v_message_name is carried
          -- out since it can expect either IGS OR IGF message
          fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
          igs_ge_msg_stack.add;
          IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
            fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.AfterRowInsertUpdateDelete1 ', 'Call to igf_sl_cl_create_chg.create_awd_chg_rec returned error '|| l_v_message_name);
          END IF;
          app_exception.raise_exception;
        END IF;
      END IF;
    END IF;
END AfterRowInsertUpdateDelete1;

  PROCEDURE AfterRowInsertUpdateDelete2(
    p_inserting IN BOOLEAN ,
    p_updating  IN BOOLEAN ,
    p_deleting  IN BOOLEAN
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By : veramach
  ||  Created On : 16-Nov-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
  lv_rowid  ROWID;
  l_awdh_id igf_aw_awd_hist.awdh_id%TYPE;

  BEGIN
    IF p_updating THEN
      lv_rowid  := NULL;
      l_awdh_id := NULL;
      igf_aw_awd_hist_pkg.insert_row(
                                     x_rowid             => lv_rowid,
                                     x_awdh_id           => l_awdh_id,
                                     x_award_id          => new_references.award_id,
                                     x_tran_date         => SYSDATE,
                                     x_operation_txt     => 'UPDATE',
                                     x_offered_amt_num   => old_references.offered_amt,
                                     x_off_adj_num       => (new_references.offered_amt - old_references.offered_amt),
                                     x_accepted_amt_num  => old_references.accepted_amt,
                                     x_acc_adj_num       => (new_references.accepted_amt - old_references.accepted_amt),
                                     x_paid_amt_num      => old_references.paid_amt,
                                     x_paid_adj_num      => (new_references.paid_amt - old_references.paid_amt),
                                     x_mode              => 'R'
                                    );
    END IF;
  END AfterRowInsertUpdateDelete2;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  veramach        05-Jul-2004     bug 3682032 ModIFied chech_parent_existance
  ||                                  so that the procedure tries to acquire lock on the fund record
  ||                                  before throwing an error message
  ||  veramach        10-NOV-2003     FA 125 Multiple Distr methods
  ||                                  Added adplans_id as a foreign key
  */
  x_lock          BOOLEAN := FALSE;
  BEGIN

    IF (((old_references.rvsn_id = new_references.rvsn_id)) OR
        ((new_references.rvsn_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_awd_rvsn_rsn_pkg.get_pk_for_validation (
                new_references.rvsn_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.fund_id = new_references.fund_id)) OR ((new_references.fund_id IS NULL))) THEN
      FOR i IN 1..200 LOOP
        BEGIN
          x_lock := igf_aw_fund_mast_pkg.get_pk_for_validation (new_references.fund_id);
        EXCEPTION
          WHEN others THEN
            x_lock := FALSE;
        END;

        IF x_lock THEN
          EXIT;
        ELSE
          DBMS_LOCK.SLEEP(0.1);
        END IF;
      END LOOP;

      IF NOT x_lock THEN
        fnd_message.set_name ('IGF', 'IGF_AW_FUND_LOCK_ERR');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSE

      FOR i IN 1..200 LOOP
        BEGIN
          x_lock := igf_aw_fund_mast_pkg.get_pk_for_validation (new_references.fund_id);
        EXCEPTION
          WHEN others THEN
            x_lock := FALSE;
        END;

        IF x_lock THEN
          EXIT;
        ELSE
          DBMS_LOCK.SLEEP(0.1);
        END IF;
      END LOOP;

      IF NOT x_lock THEN
        fnd_message.set_name ('IGF', 'IGF_AW_FUND_LOCK_ERR');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF (((old_references.base_id = new_references.base_id)) OR
        ((new_references.base_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_fa_base_rec_pkg.get_pk_for_validation (
                new_references.base_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.adplans_id = new_references.adplans_id)) OR
        ((new_references.adplans_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_awd_dist_plans_pkg.get_pk_for_validation (
                new_references.adplans_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pssahni         21-Oct-2004     Added check child for IGF_GR_COD_HISTORY
  ||  bannamal        28-Sep-2004     Bug # 3416863 FA149 COD XML
  ||                                  Added check child for igf_gr_cod_dtls
  ||  brajendr        21-Jul-2003     Bug # 2991359 Legacy Part II
  ||                                  Added check child for igf_gr_rfms
  ||  (reverse chronological order - newest change first)
  */
  BEGIN


    igf_aw_awd_disb_pkg.get_fk_igf_aw_award (
      old_references.award_id
    );


    igf_sl_awd_disb_loc_pkg.get_fk_igf_aw_award (
      old_references.award_id
    );

    igf_sl_loans_pkg.get_fk_igf_aw_award (
      old_references.award_id
    );

    igf_gr_rfms_pkg.get_fk_igf_aw_award (
      old_references.award_id
    );

    igf_gr_cod_dtls_pkg.get_fk_igf_aw_award(
      old_references.award_id
    );

    igf_sl_lor_loc_pkg.get_fk_igf_aw_award(
      old_references.award_id
    );

    igf_aw_db_chg_dtls_pkg.get_fk_igf_aw_award(
      old_references.award_id
    );

    igf_aw_db_cod_dtls_pkg.get_fk_igf_aw_award(
      old_references.award_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_award_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_award_all
      WHERE    award_id = x_award_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN(TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_pk_for_validation;


  PROCEDURE get_fk_igf_aw_awd_rvsn_rsn (
    x_rvsn_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : prchandr
  ||  Created On : 01-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_award_all
      WHERE   ((rvsn_id = x_rvsn_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_RVSN_AWD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_awd_rvsn_rsn;


  PROCEDURE get_fk_igf_aw_fund_mast (
    x_fund_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_award_all
      WHERE   ((fund_id = x_fund_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_AWD_FMAST_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_fund_mast;


  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_award_all
      WHERE   ((base_id = x_base_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_AWD_FA_DETAIL_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_fa_base_rec;

  PROCEDURE get_fk_igf_aw_awd_dist_plans(
                                         x_adplans_id      IN NUMBER
                                        ) AS
  ------------------------------------------------------------------
  --Created by  : veramach, Oracle India
  --Date created: 10-NOV-2003
  --
  --Purpose:
  --
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  -------------------------------------------------------------------

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_award_all
      WHERE   ((adplans_id = x_adplans_id));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_AWD_ADPLANS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END get_fk_igf_aw_awd_dist_plans;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_award_id                          IN     NUMBER      ,
    x_fund_id                           IN     NUMBER      ,
    x_base_id                           IN     NUMBER      ,
    x_offered_amt                       IN     NUMBER      ,
    x_accepted_amt                      IN     NUMBER      ,
    x_paid_amt                          IN     NUMBER      ,
    x_packaging_type                    IN     VARCHAR2    ,
    x_batch_id                          IN     VARCHAR2    ,
    x_manual_update                     IN     VARCHAR2    ,
    x_rules_override                    IN     VARCHAR2    ,
    x_award_date                        IN     DATE        ,
    x_award_status                      IN     VARCHAR2    ,
    x_attribute_category                IN     VARCHAR2    ,
    x_attribute1                        IN     VARCHAR2    ,
    x_attribute2                        IN     VARCHAR2    ,
    x_attribute3                        IN     VARCHAR2    ,
    x_attribute4                        IN     VARCHAR2    ,
    x_attribute5                        IN     VARCHAR2    ,
    x_attribute6                        IN     VARCHAR2    ,
    x_attribute7                        IN     VARCHAR2    ,
    x_attribute8                        IN     VARCHAR2    ,
    x_attribute9                        IN     VARCHAR2    ,
    x_attribute10                       IN     VARCHAR2    ,
    x_attribute11                       IN     VARCHAR2    ,
    x_attribute12                       IN     VARCHAR2    ,
    x_attribute13                       IN     VARCHAR2    ,
    x_attribute14                       IN     VARCHAR2    ,
    x_attribute15                       IN     VARCHAR2    ,
    x_attribute16                       IN     VARCHAR2    ,
    x_attribute17                       IN     VARCHAR2    ,
    x_attribute18                       IN     VARCHAR2    ,
    x_attribute19                       IN     VARCHAR2    ,
    x_attribute20                       IN     VARCHAR2    ,
    x_rvsn_id                           IN     NUMBER      ,
    x_alt_pell_schedule                 IN     VARCHAR2    ,
    x_award_number_txt                  IN     VARCHAR2    ,
    x_legacy_record_flag                IN     VARCHAR2    ,
    x_adplans_id                        IN     NUMBER      ,
    x_lock_award_flag                   IN     VARCHAR2    ,
    x_app_trans_num_txt                 IN     VARCHAR2    ,
    x_awd_proc_status_code              IN     VARCHAR2    ,
    x_notification_status_code		      IN     VARCHAR2	   ,
    x_notification_status_date		      IN     DATE	       ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  veramach        1-NOV-2003      #3160568 Added adplans_id in the procedure signature
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_award_id,
      x_fund_id,
      x_base_id,
      x_offered_amt,
      x_accepted_amt,
      x_paid_amt,
      x_packaging_type,
      x_batch_id,
      x_manual_update,
      x_rules_override,
      x_award_date,
      x_award_status,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_rvsn_id,
      x_alt_pell_schedule,
      x_award_number_txt,
      x_legacy_record_flag,
      x_adplans_id,
      x_lock_award_flag,
      x_app_trans_num_txt,
      x_awd_proc_status_code,
      x_notification_status_code,
      x_notification_status_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_publish_in_ss_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.award_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.award_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;

  /*
  Created By : bvisvana
  Created On : 24-May-2005
  Purpose : Identifies whether the award attribute is changed or not.
  Known limitations, enhancements or remarks :
  Change History :
  Who             When            What
  -------------------------------------
  bvisvana        18-Oct-2005     Bug # 4635941 - NVL check for amount field are done against 0 instead of -1
  -------------------------------------
  (reverse chronological order - newest change first)
  */

   FUNCTION isChangeIn_AwardAttribute(p_award_atrr_code IN IGF_AW_AWARD_LEVEL_HIST.AWARD_ATTRIB_CODE%TYPE)
   return BOOLEAN
   AS
   l_changed BOOLEAN := FALSE;
   BEGIN
      -- For offered amount change
      IF (p_award_atrr_code = 'IGF_AW_AMOUNT_OFFERED') THEN
        IF(NVL(old_references.OFFERED_AMT,0) <> NVL(new_references.OFFERED_AMT,0)) THEN
          l_changed := TRUE;
        END IF;
      END IF;
      -- For Accepted amount change
      IF (p_award_atrr_code = 'IGF_AW_AMOUNT_ACCEPTED') THEN
        IF (NVL(old_references.ACCEPTED_AMT,0) <> NVL(new_references.ACCEPTED_AMT,0)) THEN
          l_changed := TRUE;
        END IF;
      END IF;
      -- For Paid amount change
      IF (p_award_atrr_code = 'IGF_AW_AMOUNT_PAID') THEN
        IF (NVL(old_references.PAID_AMT ,0) <> NVL(new_references.PAID_AMT ,0)) THEN
          l_changed := TRUE;
        END IF;
      END IF;
      -- For Award Status change
      IF (p_award_atrr_code = 'IGF_AW_AWARD_STATUS') THEN
        IF (NVL(old_references.AWARD_STATUS ,'*') <> NVL(new_references.AWARD_STATUS,'*')) THEN
          l_changed := TRUE;
        END IF;
      END IF;
      -- For Award Distribution plan change
      IF (p_award_atrr_code = 'IGF_AW_DIST_PLAN') THEN
        IF (NVL(old_references.ADPLANS_ID ,-1) <> NVL(new_references.ADPLANS_ID,-1)) THEN
          l_changed := TRUE;
        END IF;
      END IF;
      -- For lock award change
      IF (p_award_atrr_code = 'IGF_AW_LOCK_STATUS') THEN
        IF (NVL(old_references.LOCK_AWARD_FLAG ,'*') <> NVL(new_references.LOCK_AWARD_FLAG,'*')) THEN
          l_changed := TRUE;
        END IF;
      END IF;

      RETURN l_changed;
    END isChangeIn_AwardAttribute;

  /*
  Created By : bvisvana
  Created On : 24-May-2005
  Purpose : Updates the award history for an given combination of award id,transaction id and attribute type
  Known limitations, enhancements or remarks :
  Change History :
  Who             When            What
  -------------------------------------
   -------------------------------------
  (reverse chronological order - newest change first)
  */

  PROCEDURE update_award_history AS

   CURSOR c_lookup_attribute is
    SELECT lookup_code from igf_lookups_view
    WHERE lookup_type = 'IGF_AW_AWARD_ATTRIBUTES';

   l_award_atrr_code IGF_AW_AWARD_LEVEL_HIST.AWARD_ATTRIB_CODE%TYPE;
   l_awd_attr_changed	BOOLEAN := FALSE;
   l_row_id VARCHAR2(30) ;

   BEGIN
      -- update for the 6 attributes IF any change
      l_row_id := null;
      open c_lookup_attribute;
      LOOP
        l_awd_attr_changed := FALSE;
        FETCH c_lookup_attribute INTO l_award_atrr_code;
        EXIT WHEN c_lookup_attribute%NOTFOUND;
      l_awd_attr_changed := isChangeIn_AwardAttribute(l_award_atrr_code);
      l_row_id := null;
      /* If award attributes Change, then insert / update */
      IF (l_awd_attr_changed) THEN
        igf_aw_award_level_hist_pkg.add_row
        (
            x_rowid                     => l_row_id,
            x_award_id                  => old_references.AWARD_ID,
            x_award_hist_tran_id        => g_award_hist_tran_id,
            x_award_attrib_code         => l_award_atrr_code,
            x_award_change_source_code  => g_award_change_source,
            x_old_offered_amt           => old_references.OFFERED_AMT,
            x_new_offered_amt           => new_references.OFFERED_AMT,
            x_old_accepted_amt          => old_references.ACCEPTED_AMT,
            x_new_accepted_amt          => new_references.ACCEPTED_AMT,
            x_old_paid_amt              => old_references.PAID_AMT,
            x_new_paid_amt              => new_references.PAID_AMT,
            x_old_lock_award_flag       => old_references.LOCK_AWARD_FLAG,
            x_new_lock_award_flag       => new_references.LOCK_AWARD_FLAG,
            x_old_award_status_code     => old_references.AWARD_STATUS,
            x_new_award_status_code     => new_references.AWARD_STATUS,
            x_old_adplans_id            => old_references.ADPLANS_ID,
            x_new_adplans_id            => new_references.ADPLANS_ID,
            x_mode                      => 'R'
        );
      END IF;
      END LOOP;
      CLOSE c_lookup_attribute;
      EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','igf_aw_award_pkg.update_award_history' || SQLERRM);
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
   END update_award_history;


  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
   /*-----------------------------------------------------------------
  ||  Created By : Sanil Madathil
  ||  Created On : 13 October 2004
  ||  Purpose : Invoke the proceduers related to after update
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
  BEGIN
    l_rowid := NULL;
    IF (p_action = 'UPDATE') THEN
     -- Call all the procedures related to After Update.
      IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
        fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.after_dml ', 'before call to AfterRowInsertUpdateDelete1 ' );
      END IF;
      AfterRowInsertUpdateDelete1
      (
        p_inserting => FALSE,
        p_updating  => TRUE ,
        p_deleting  => FALSE
      );

      --R4 - FA 157 Award Level History
      update_award_history;

      IF NVL(old_references.offered_amt,-1) <> NVL(new_references.offered_amt,-1) OR
         NVL(old_references.accepted_amt,-1) <> NVL(new_references.accepted_amt,-1) OR
         NVL(old_references.paid_amt,-1) <> NVL(new_references.paid_amt,-1) THEN
        AfterRowInsertUpdateDelete2(
                                    p_inserting => FALSE,
                                    p_updating  => TRUE ,
                                    p_deleting  => FALSE
                                   );
      END IF;
    END IF;
  END after_dml;



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
    x_alt_pell_schedule                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_award_number_txt                  IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2,
    x_app_trans_num_txt                 IN     VARCHAR2,
    x_awd_proc_status_code              IN     VARCHAR2,
    x_notification_status_code		      IN     VARCHAR2,
    x_notification_status_date		      IN     DATE,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  veramach        1-NOV-2003      #3160568 Added adplans_id in the procedure signature
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_award_all
      WHERE    award_id                          = x_award_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id           igf_aw_award_all.org_id%TYPE  DEFAULT igf_aw_gen.get_org_id;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF (x_last_updated_by IS NULL) THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT igf_aw_award_s.nextval INTO x_award_id FROM dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_award_id                          => x_award_id,
      x_fund_id                           => x_fund_id,
      x_base_id                           => x_base_id,
      x_offered_amt                       => x_offered_amt,
      x_accepted_amt                      => x_accepted_amt,
      x_paid_amt                          => x_paid_amt,
      x_packaging_type                    => x_packaging_type,
      x_batch_id                          => x_batch_id,
      x_manual_update                     => x_manual_update,
      x_rules_override                    => x_rules_override,
      x_award_date                        => x_award_date,
      x_award_status                      => x_award_status,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_rvsn_id                           => x_rvsn_id,
      x_alt_pell_schedule                 => x_alt_pell_schedule,
      x_award_number_txt                  => x_award_number_txt,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_adplans_id                        => x_adplans_id,
      x_lock_award_flag                   => x_lock_award_flag,
      x_app_trans_num_txt                 => x_app_trans_num_txt,
      x_awd_proc_status_code              => x_awd_proc_status_code,
      x_notification_status_code	        => x_notification_status_code,
      x_notification_status_date          => x_notification_status_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_publish_in_ss_flag                => x_publish_in_ss_flag
    );

    INSERT INTO igf_aw_award_all (
      award_id,
      fund_id,
      base_id,
      offered_amt,
      accepted_amt,
      paid_amt,
      packaging_type,
      batch_id,
      manual_update,
      rules_override,
      award_date,
      award_status,
      attribute_category,
      attribute1,
      attribute2,
      attribute3,
      attribute4,
      attribute5,
      attribute6,
      attribute7,
      attribute8,
      attribute9,
      attribute10,
      attribute11,
      attribute12,
      attribute13,
      attribute14,
      attribute15,
      attribute16,
      attribute17,
      attribute18,
      attribute19,
      attribute20,
      rvsn_id,
      alt_pell_schedule,
      award_number_txt,
      legacy_record_flag,
      adplans_id,
      lock_award_flag,
      app_trans_num_txt,
      awd_proc_status_code,
      notification_status_code,
      notification_status_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date,
      org_id,
      publish_in_ss_flag
    ) VALUES (
      new_references.award_id,
      new_references.fund_id,
      new_references.base_id,
      new_references.offered_amt,
      new_references.accepted_amt,
      new_references.paid_amt,
      new_references.packaging_type,
      new_references.batch_id,
      new_references.manual_update,
      new_references.rules_override,
      new_references.award_date,
      new_references.award_status,
      new_references.attribute_category,
      new_references.attribute1,
      new_references.attribute2,
      new_references.attribute3,
      new_references.attribute4,
      new_references.attribute5,
      new_references.attribute6,
      new_references.attribute7,
      new_references.attribute8,
      new_references.attribute9,
      new_references.attribute10,
      new_references.attribute11,
      new_references.attribute12,
      new_references.attribute13,
      new_references.attribute14,
      new_references.attribute15,
      new_references.attribute16,
      new_references.attribute17,
      new_references.attribute18,
      new_references.attribute19,
      new_references.attribute20,
      new_references.rvsn_id,
      new_references.alt_pell_schedule,
      new_references.award_number_txt,
      new_references.legacy_record_flag,
      new_references.adplans_id,
      new_references.lock_award_flag,
      new_references.app_trans_num_txt,
      new_references.awd_proc_status_code,
      new_references.notification_status_code,
      new_references.notification_status_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date ,
      l_org_id,
      new_references.publish_in_ss_flag
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

    /* Update Fund Master */
--
-- Bug 3029739
-- As the variable old_referecnes is a package
-- variable it is retaining the old value
-- For insert routine, we need not have this value so it
-- is being replaced with new_ref
-- This is done so that the following routine would
-- correctly update fund manager totals
--
    igf_aw_gen.update_fmast( new_references,
                             new_references,
                             'INSERT'
                           ) ;
    EXCEPTION
      WHEN OTHERS THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_UNHANDLED_EXP');
        FND_MESSAGE.SET_TOKEN('NAME','igf_aw_award_pkg.insert_row' || SQLERRM);
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
  END insert_row;


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
    x_rvsn_id                           IN     NUMBER,
    x_alt_pell_schedule                 IN     VARCHAR2,
    x_award_number_txt                  IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2,
    x_app_trans_num_txt                 IN     VARCHAR2,
    x_awd_proc_status_code              IN     VARCHAR2,
    x_notification_status_code		      IN     VARCHAR2,
    x_notification_status_date		      IN     DATE,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  veramach        1-NOV-2003      #3160568 Added adplans_id in the procedure signature
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        fund_id,
        base_id,
        offered_amt,
        accepted_amt,
        paid_amt,
        packaging_type,
        batch_id,
        manual_update,
        rules_override,
        award_date,
        award_status,
        attribute_category,
        attribute1,
        attribute2,
        attribute3,
        attribute4,
        attribute5,
        attribute6,
        attribute7,
        attribute8,
        attribute9,
        attribute10,
        attribute11,
        attribute12,
        attribute13,
        attribute14,
        attribute15,
        attribute16,
        attribute17,
        attribute18,
        attribute19,
        attribute20,
        rvsn_id,
        alt_pell_schedule,
        award_number_txt,
        legacy_record_flag,
        adplans_id,
        lock_award_flag,
        app_trans_num_txt,
        awd_proc_status_code,
      	notification_status_code,
        notification_status_date,
        publish_in_ss_flag
      FROM  igf_aw_award_all
      WHERE rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.fund_id = x_fund_id)
        AND (tlinfo.base_id = x_base_id)
        AND ((tlinfo.offered_amt = x_offered_amt) OR ((tlinfo.offered_amt IS NULL) AND (X_offered_amt IS NULL)))
        AND ((tlinfo.accepted_amt = x_accepted_amt) OR ((tlinfo.accepted_amt IS NULL) AND (X_accepted_amt IS NULL)))
        AND ((tlinfo.paid_amt = x_paid_amt) OR ((tlinfo.paid_amt IS NULL) AND (X_paid_amt IS NULL)))
        AND ((tlinfo.packaging_type = x_packaging_type) OR ((tlinfo.packaging_type IS NULL) AND (X_packaging_type IS NULL)))
        AND ((tlinfo.batch_id = x_batch_id) OR ((tlinfo.batch_id IS NULL) AND (X_batch_id IS NULL)))
        AND ((tlinfo.manual_update = x_manual_update) OR ((tlinfo.manual_update IS NULL) AND (X_manual_update IS NULL)))
        AND ((tlinfo.rules_override = x_rules_override) OR ((tlinfo.rules_override IS NULL) AND (X_rules_override IS NULL)))
        AND ((tlinfo.award_date = x_award_date) OR ((tlinfo.award_date IS NULL) AND (X_award_date IS NULL)))
        AND ((tlinfo.award_status = x_award_status) OR ((tlinfo.award_status IS NULL) AND (X_award_status IS NULL)))
        AND ((tlinfo.attribute_category = x_attribute_category) OR ((tlinfo.attribute_category IS NULL) AND (X_attribute_category IS NULL)))
        AND ((tlinfo.attribute1 = x_attribute1) OR ((tlinfo.attribute1 IS NULL) AND (X_attribute1 IS NULL)))
        AND ((tlinfo.attribute2 = x_attribute2) OR ((tlinfo.attribute2 IS NULL) AND (X_attribute2 IS NULL)))
        AND ((tlinfo.attribute3 = x_attribute3) OR ((tlinfo.attribute3 IS NULL) AND (X_attribute3 IS NULL)))
        AND ((tlinfo.attribute4 = x_attribute4) OR ((tlinfo.attribute4 IS NULL) AND (X_attribute4 IS NULL)))
        AND ((tlinfo.attribute5 = x_attribute5) OR ((tlinfo.attribute5 IS NULL) AND (X_attribute5 IS NULL)))
        AND ((tlinfo.attribute6 = x_attribute6) OR ((tlinfo.attribute6 IS NULL) AND (X_attribute6 IS NULL)))
        AND ((tlinfo.attribute7 = x_attribute7) OR ((tlinfo.attribute7 IS NULL) AND (X_attribute7 IS NULL)))
        AND ((tlinfo.attribute8 = x_attribute8) OR ((tlinfo.attribute8 IS NULL) AND (X_attribute8 IS NULL)))
        AND ((tlinfo.attribute9 = x_attribute9) OR ((tlinfo.attribute9 IS NULL) AND (X_attribute9 IS NULL)))
        AND ((tlinfo.attribute10 = x_attribute10) OR ((tlinfo.attribute10 IS NULL) AND (X_attribute10 IS NULL)))
        AND ((tlinfo.attribute11 = x_attribute11) OR ((tlinfo.attribute11 IS NULL) AND (X_attribute11 IS NULL)))
        AND ((tlinfo.attribute12 = x_attribute12) OR ((tlinfo.attribute12 IS NULL) AND (X_attribute12 IS NULL)))
        AND ((tlinfo.attribute13 = x_attribute13) OR ((tlinfo.attribute13 IS NULL) AND (X_attribute13 IS NULL)))
        AND ((tlinfo.attribute14 = x_attribute14) OR ((tlinfo.attribute14 IS NULL) AND (X_attribute14 IS NULL)))
        AND ((tlinfo.attribute15 = x_attribute15) OR ((tlinfo.attribute15 IS NULL) AND (X_attribute15 IS NULL)))
        AND ((tlinfo.attribute16 = x_attribute16) OR ((tlinfo.attribute16 IS NULL) AND (X_attribute16 IS NULL)))
        AND ((tlinfo.attribute17 = x_attribute17) OR ((tlinfo.attribute17 IS NULL) AND (X_attribute17 IS NULL)))
        AND ((tlinfo.attribute18 = x_attribute18) OR ((tlinfo.attribute18 IS NULL) AND (X_attribute18 IS NULL)))
        AND ((tlinfo.attribute19 = x_attribute19) OR ((tlinfo.attribute19 IS NULL) AND (X_attribute19 IS NULL)))
        AND ((tlinfo.attribute20 = x_attribute20) OR ((tlinfo.attribute20 IS NULL) AND (X_attribute20 IS NULL)))
        AND ((tlinfo.rvsn_id = x_rvsn_id) OR ((tlinfo.rvsn_id IS NULL) AND (x_rvsn_id IS NULL)))
        AND ((tlinfo.alt_pell_schedule = x_alt_pell_schedule) OR ((tlinfo.alt_pell_schedule IS NULL) AND (x_alt_pell_schedule IS NULL)))
        AND ((tlinfo.award_number_txt = x_award_number_txt) OR ((tlinfo.award_number_txt IS NULL) AND (x_award_number_txt IS NULL)))
        AND ((tlinfo.legacy_record_flag = x_legacy_record_flag) OR ((tlinfo.legacy_record_flag IS NULL) AND (x_legacy_record_flag IS NULL)))
        AND ((tlinfo.adplans_id = x_adplans_id) OR ((tlinfo.adplans_id IS NULL) AND (x_adplans_id IS NULL)))
        AND ((tlinfo.lock_award_flag = x_lock_award_flag) OR ((tlinfo.lock_award_flag IS NULL ) AND (x_lock_award_flag IS NULL)))
        AND ((tlinfo.app_trans_num_txt = x_app_trans_num_txt) OR ((tlinfo.app_trans_num_txt IS NULL ) AND (x_app_trans_num_txt IS NULL)))
        AND ((tlinfo.awd_proc_status_code = x_awd_proc_status_code) OR ((tlinfo.awd_proc_status_code IS NULL ) AND (x_awd_proc_status_code IS NULL)))
        AND ((tlinfo.notification_status_code= x_notification_status_code) OR ((tlinfo.notification_status_code IS NULL ) AND (x_notification_status_code IS NULL)))
        AND ((tlinfo.notification_status_date= x_notification_status_date) OR ((tlinfo.notification_status_date IS NULL ) AND (x_notification_status_date IS NULL)))
        AND ((tlinfo.publish_in_ss_flag = x_publish_in_ss_flag) OR ((tlinfo.publish_in_ss_flag IS NULL ) AND (x_publish_in_ss_flag IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;

  /*
  Created By : bvisvana
  Created On : 24-May-2005
  Purpose : Checks the award history for a given award id.
    If award history record does not exists, then it create a record history
  Known limitations, enhancements or remarks :
  Change History :
  Who             When            What
  -------------------------------------
   -------------------------------------
  (reverse chronological order - newest change first)
  */

  PROCEDURE check_award_history
  AS
    CURSOR c_lookup_attribute is
      SELECT lookup_code from igf_lookups_view
        WHERE lookup_type = 'IGF_AW_AWARD_ATTRIBUTES';

   l_award_atrr_code IGF_AW_AWARD_LEVEL_HIST.AWARD_ATTRIB_CODE%TYPE;
   l_row_id VARCHAR2(30) ;

   BEGIN
    IF g_award_hist_tran_id IS NULL THEN
      SELECT IGF_AW_AWARD_LEVEL_HIST_S.NEXTVAL INTO g_award_hist_tran_id from dual;
    END IF;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.check_award_history ', 'Transaction Id = '||g_award_hist_tran_id );
    END IF;
   END check_award_history;


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
    x_alt_pell_schedule                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_award_number_txt                  IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2,
    x_app_trans_num_txt                 IN     VARCHAR2,
    x_awd_proc_status_code              IN     VARCHAR2,
    x_notification_status_code          IN     VARCHAR2,
    x_notification_status_date          IN     DATE,
    x_called_from                       IN     VARCHAR2,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  veramach        1-NOV-2003      #3160568 Added adplans_id in the procedure signature
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

  BEGIN
    x_last_update_date := SYSDATE;
    IF (X_MODE = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (x_mode = 'R') THEN
      x_last_updated_by := fnd_global.user_id;
      IF x_last_updated_by IS NULL THEN
        x_last_updated_by := -1;
      END IF;
      x_last_update_login := fnd_global.login_id;
      IF (x_last_update_login IS NULL) THEN
        x_last_update_login := -1;
      END IF;
    ELSE
      fnd_message.set_name( 'FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_award_id                          => x_award_id,
      x_fund_id                           => x_fund_id,
      x_base_id                           => x_base_id,
      x_offered_amt                       => x_offered_amt,
      x_accepted_amt                      => x_accepted_amt,
      x_paid_amt                          => x_paid_amt,
      x_packaging_type                    => x_packaging_type,
      x_batch_id                          => x_batch_id,
      x_manual_update                     => x_manual_update,
      x_rules_override                    => x_rules_override,
      x_award_date                        => x_award_date,
      x_award_status                      => x_award_status,
      x_attribute_category                => x_attribute_category,
      x_attribute1                        => x_attribute1,
      x_attribute2                        => x_attribute2,
      x_attribute3                        => x_attribute3,
      x_attribute4                        => x_attribute4,
      x_attribute5                        => x_attribute5,
      x_attribute6                        => x_attribute6,
      x_attribute7                        => x_attribute7,
      x_attribute8                        => x_attribute8,
      x_attribute9                        => x_attribute9,
      x_attribute10                       => x_attribute10,
      x_attribute11                       => x_attribute11,
      x_attribute12                       => x_attribute12,
      x_attribute13                       => x_attribute13,
      x_attribute14                       => x_attribute14,
      x_attribute15                       => x_attribute15,
      x_attribute16                       => x_attribute16,
      x_attribute17                       => x_attribute17,
      x_attribute18                       => x_attribute18,
      x_attribute19                       => x_attribute19,
      x_attribute20                       => x_attribute20,
      x_rvsn_id                           => x_rvsn_id,
      x_alt_pell_schedule                 => x_alt_pell_schedule,
      x_award_number_txt                  => x_award_number_txt,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_adplans_id                        => x_adplans_id,
      x_lock_award_flag                   => x_lock_award_flag,
      x_app_trans_num_txt                 => x_app_trans_num_txt,
      x_awd_proc_status_code              => x_awd_proc_status_code,
      x_notification_status_code          => x_notification_status_code,
      x_notification_status_date          => x_notification_status_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_publish_in_ss_flag                => x_publish_in_ss_flag
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    -- R4 - Award History FA 157
    check_award_history;

    UPDATE igf_aw_award_all
      SET
        fund_id                           = new_references.fund_id,
        base_id                           = new_references.base_id,
        offered_amt                       = new_references.offered_amt,
        accepted_amt                      = new_references.accepted_amt,
        paid_amt                          = new_references.paid_amt,
        packaging_type                    = new_references.packaging_type,
        batch_id                          = new_references.batch_id,
        manual_update                     = new_references.manual_update,
        rules_override                    = new_references.rules_override,
        award_date                        = new_references.award_date,
        award_status                      = new_references.award_status,
        attribute_category                = new_references.attribute_category,
        attribute1                        = new_references.attribute1,
        attribute2                        = new_references.attribute2,
        attribute3                        = new_references.attribute3,
        attribute4                        = new_references.attribute4,
        attribute5                        = new_references.attribute5,
        attribute6                        = new_references.attribute6,
        attribute7                        = new_references.attribute7,
        attribute8                        = new_references.attribute8,
        attribute9                        = new_references.attribute9,
        attribute10                       = new_references.attribute10,
        attribute11                       = new_references.attribute11,
        attribute12                       = new_references.attribute12,
        attribute13                       = new_references.attribute13,
        attribute14                       = new_references.attribute14,
        attribute15                       = new_references.attribute15,
        attribute16                       = new_references.attribute16,
        attribute17                       = new_references.attribute17,
        attribute18                       = new_references.attribute18,
        attribute19                       = new_references.attribute19,
        attribute20                       = new_references.attribute20,
        rvsn_id                           = new_references.rvsn_id,
        alt_pell_schedule                 = new_references.alt_pell_schedule,
        award_number_txt                  = new_references.award_number_txt,
        legacy_record_flag                = new_references.legacy_record_flag,
        adplans_id                        = new_references.adplans_id,
        lock_award_flag                   = new_references.lock_award_flag,
        app_trans_num_txt                 = new_references.app_trans_num_txt,
        awd_proc_status_code              = new_references.awd_proc_status_code,
        notification_status_code	        = new_references.notification_status_code,
        notification_status_date	        = new_references.notification_status_date,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        publish_in_ss_flag                = new_references.publish_in_ss_flag
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    -- Update the Fund Master
    igf_aw_gen.update_fmast( old_references,
                               new_references,
                               'UPDATE'
                               );
    g_v_called_from := x_called_from;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.update_row ', 'g_v_called_from '||g_v_called_from );
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.update_row ', 'before invoking after_dml ' );
    END IF;
    after_dml(
            p_action =>'UPDATE',
            x_rowid => x_rowid
          );
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.update_row ', 'after invoking after_dml ' );
    END IF;
    g_v_called_from := NULL;
  END update_row;


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
    x_alt_pell_schedule                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_award_number_txt                  IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_adplans_id                        IN     NUMBER,
    x_lock_award_flag                   IN     VARCHAR2,
    x_app_trans_num_txt                 IN     VARCHAR2,
    x_awd_proc_status_code              IN     VARCHAR2,
    x_notification_status_code		      IN     VARCHAR2,
    x_notification_status_date		      IN     DATE,
    x_publish_in_ss_flag                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Adds a row IF there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  veramach        1-NOV-2003      #3160568 Added adplans_id in the procedure call
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_award_all
      WHERE    award_id                          = x_award_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_award_id,
        x_fund_id,
        x_base_id,
        x_offered_amt,
        x_accepted_amt,
        x_paid_amt,
        x_packaging_type,
        x_batch_id,
        x_manual_update,
        x_rules_override,
        x_award_date,
        x_award_status,
        x_attribute_category,
        x_attribute1,
        x_attribute2,
        x_attribute3,
        x_attribute4,
        x_attribute5,
        x_attribute6,
        x_attribute7,
        x_attribute8,
        x_attribute9,
        x_attribute10,
        x_attribute11,
        x_attribute12,
        x_attribute13,
        x_attribute14,
        x_attribute15,
        x_attribute16,
        x_attribute17,
        x_attribute18,
        x_attribute19,
        x_attribute20,
        x_rvsn_id,
        x_alt_pell_schedule,
        x_mode,
        x_award_number_txt,
        x_legacy_record_flag,
        x_adplans_id,
        x_lock_award_flag,
        x_app_trans_num_txt,
        x_awd_proc_status_code,
        x_notification_status_code,
        x_notification_status_date,
        x_publish_in_ss_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_award_id,
      x_fund_id,
      x_base_id,
      x_offered_amt,
      x_accepted_amt,
      x_paid_amt,
      x_packaging_type,
      x_batch_id,
      x_manual_update,
      x_rules_override,
      x_award_date,
      x_award_status,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_rvsn_id,
      x_alt_pell_schedule,
      x_mode,
      x_award_number_txt,
      x_legacy_record_flag,
      x_adplans_id,
      x_lock_award_flag,
      x_app_trans_num_txt,
      x_awd_proc_status_code,
      x_notification_status_code,
      x_notification_status_date,
      x_publish_in_ss_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : avenkatr
  ||  Created On : 06-DEC-2000
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

    DELETE FROM igf_aw_award_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    -- Update Fund Master
    igf_aw_gen.update_fmast( old_references,
                               new_references,
                               'DELETE'
                               ) ;

  END delete_row;


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

  PROCEDURE set_award_change_source (
    p_award_change_source  IN igf_aw_award_level_hist.AWARD_CHANGE_SOURCE_CODE%TYPE
  ) AS
  BEGIN
    g_award_change_source := p_award_change_source ;
    IF (fnd_log.level_statement >= fnd_log.g_current_runtime_level) THEN
      fnd_log.string( fnd_log.level_statement, 'igf.plsql.igf_aw_award_pkg.set_award_change_source ', 'g_award_source_change= '||g_award_change_source);
    END IF;
   END set_award_change_source;

  /*
  Created By : bvisvana
  Created On : 15-June-2005
  Purpose : Reset the Award History Transaction
  Known limitations, enhancements or remarks :
  Change History :
  Who             When            What
  -------------------------------------
  -------------------------------------
  (reverse chronological order - newest change first)
  */
  PROCEDURE reset_awd_hist_trans_id AS
  BEGIN
    g_award_hist_tran_id := NULL;
  END reset_awd_hist_trans_id;

END igf_aw_award_pkg;

/
