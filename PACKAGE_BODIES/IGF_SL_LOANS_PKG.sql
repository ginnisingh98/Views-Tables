--------------------------------------------------------
--  DDL for Package Body IGF_SL_LOANS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SL_LOANS_PKG" AS
/* $Header: IGFLI09B.pls 120.3 2006/08/03 12:36:04 tsailaja noship $ */

  l_rowid        VARCHAR2(25);
  old_references igf_sl_loans_all%ROWTYPE;
  new_references igf_sl_loans_all%ROWTYPE;
  g_v_called_from VARCHAR2(30);

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_loan_id                           IN     NUMBER   ,
    x_award_id                          IN     NUMBER   ,
    x_seq_num                           IN     NUMBER   ,
    x_loan_number                       IN     VARCHAR2 ,
    x_loan_per_begin_date               IN     DATE     ,
    x_loan_per_end_date                 IN     DATE     ,
    x_loan_status                       IN     VARCHAR2 ,
    x_loan_status_date                  IN     DATE     ,
    x_loan_chg_status                   IN     VARCHAR2 ,
    x_loan_chg_status_date              IN     DATE     ,
    x_active                            IN     VARCHAR2 ,
    x_active_date                       IN     DATE     ,
    x_borw_detrm_code                   IN     VARCHAR2 ,
--    x_loan_status_desc                  IN     VARCHAR2 ,
--    x_loan_chg_status_desc              IN     VARCHAR2 ,
    x_legacy_record_flag                IN     VARCHAR2   ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER    ,
    x_external_loan_id_txt              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_SL_LOANS_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;

    -- Populate New Values.
    new_references.loan_id                           := x_loan_id;
    new_references.award_id                          := x_award_id;
    new_references.seq_num                           := x_seq_num;
    new_references.loan_number                       := x_loan_number;
    new_references.loan_per_begin_date               := x_loan_per_begin_date;
    new_references.loan_per_end_date                 := x_loan_per_end_date;
    new_references.loan_status                       := x_loan_status;
    new_references.loan_status_date                  := x_loan_status_date;
    new_references.loan_chg_status                   := x_loan_chg_status;
    new_references.loan_chg_status_date              := x_loan_chg_status_date;
    new_references.active                            := x_active;
    new_references.active_date                       := x_active_date;
    new_references.borw_detrm_code                   := x_borw_detrm_code;
    new_references.legacy_record_flag                := x_legacy_record_flag;
--    new_references.loan_status_desc                  := x_loan_status_desc ;
--    new_references.loan_chg_status_desc              := x_loan_chg_status_desc ;

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
    new_references.external_loan_id_txt              := x_external_loan_id_txt;
  END set_column_values;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
  BEGIN

    IF ( get_uk_for_validation ( new_references.loan_number )) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF ( get_uk2_for_validation ( new_references.award_id ) ) THEN
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
  BEGIN

    IF (((old_references.award_id = new_references.award_id)) OR
        ((new_references.award_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_award_pkg.get_pk_for_validation ( new_references.award_id ) THEN
      FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF (((old_references.borw_detrm_code = new_references.borw_detrm_code)) OR
        ((new_references.borw_detrm_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation( 'IGS_FI_BORW_DETRM', new_references.borw_detrm_code ) THEN
      FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi        14-OCT-2004     Enh. Bug 3416936. Added call to
  ||                                  igf_sl_clchsn_dtls_pkg.get_ufk_igf_sl_loans.
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
  BEGIN

    igf_sl_alt_borw_pkg.get_fk_igf_sl_loans ( old_references.loan_id );

    igf_sl_dl_manifest_pkg.get_fk_igf_sl_loans ( old_references.loan_id );

    igf_sl_dl_pnote_p_p_pkg.get_fk_igf_sl_loans ( old_references.loan_id );

    igf_sl_dl_pnote_s_p_pkg.get_fk_igf_sl_loans ( old_references.loan_id );

    igf_sl_lor_pkg.get_fk_igf_sl_loans ( old_references.loan_id );

    igf_sl_clchsn_dtls_pkg.get_ufk_igf_sl_loans(x_loan_number => old_references.loan_number);

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_loan_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
    CURSOR cur_rowid IS
       SELECT  rowid
       FROM    igf_sl_loans_all
       WHERE   loan_id = x_loan_id
       FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%ROWTYPE;

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


  FUNCTION get_uk_for_validation ( x_loan_number    IN     VARCHAR2 )
           RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
    CURSOR cur_rowid IS
       SELECT rowid
       FROM   igf_sl_loans_all
       WHERE  loan_number = x_loan_number
       AND    ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
       CLOSE cur_rowid;
       RETURN (true);
    ELSE
       CLOSE cur_rowid;
       RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  FUNCTION get_uk2_for_validation (
    x_award_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
    CURSOR cur_rowid IS
       SELECT rowid
       FROM   igf_sl_loans_all
       WHERE  award_id = x_award_id
       AND    ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
       CLOSE cur_rowid;
       RETURN (true);
    ELSE
       CLOSE cur_rowid;
       RETURN(FALSE);
    END IF;

  END get_uk2_for_validation ;


  PROCEDURE get_fk_igf_aw_award ( x_award_id     IN     NUMBER ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
    CURSOR cur_rowid IS
       SELECT rowid
       FROM   igf_sl_loans_all
       WHERE  ((award_id = x_award_id));

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      FND_MESSAGE.SET_NAME ('IGF', 'IGF_SL_LAR_AWD_FK');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_award;


  PROCEDURE AfterRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating  IN BOOLEAN ,
    p_deleting  IN BOOLEAN
    ) AS
   /*-----------------------------------------------------------------
  ||  Created By : Sanil Madathil
  ||  Created On : 14-Oct-2004
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  rajagupt        02-Mar-2006     FA 161 and FA 162 - Whenever the loan / loan change status goes to 'Ready to Send'
  ||                                  all the disbursements which are in 'Sent' status should move to 'Ready to Send'
  ||                                  FA 161 - Bug 5006587 - Also Update mode triggers loan updation, so it is necessary to include in g_v_called_from
  ||                                  g_v_called_from IN ('IGFSL005','UPDATE_MODE') is needed so that change records are created from both the form and update mode
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
 -- Cursor to pick All disb change records in SENT status.
        CURSOR cur_sent_disb_chg_records(cp_award_id igf_aw_db_chg_dtls.award_id%TYPE) IS
      SELECT  dbchgdtls.ROWID,  dbchgdtls.*
        FROM  IGF_AW_DB_CHG_DTLS dbchgdtls
       WHERE  dbchgdtls.award_id = cp_award_id
        AND   dbchgdtls.disb_status = 'S';

    -- bvisvana - FA 161 - Bug 5091652..Cursor to pick all the change records for the loan
    CURSOR cur_loan_chg_records(cp_award_id igf_sl_clchsn_dtls.award_id%TYPE) IS
      SELECT loan_chg_dtls.ROWID, loan_chg_dtls.*
        FROM igf_sl_clchsn_dtls loan_chg_dtls
      WHERE loan_chg_dtls.award_id = cp_award_id;

    l_v_fed_fund_code  igf_aw_fund_cat_all.fed_fund_code%TYPE;
    l_v_message_name   fnd_new_messages.message_name%TYPE;
    l_b_return_status  BOOLEAN;
  BEGIN
    IF p_updating THEN
      l_v_fed_fund_code := igf_sl_gen.get_fed_fund_code (p_n_award_id     => new_references.award_id,
                                                         p_v_message_name => l_v_message_name
                                                         );
      IF l_v_message_name IS NOT NULL THEN
        fnd_message.set_name ('IGS',l_v_message_name);
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      -- bvisvana - FA 161 - Bug 5091643 and 5006587
	   --tsailaja  - FA 163 --Bug 5337555
      IF l_v_fed_fund_code IN ('FLS','FLU','FLP','ALT','GPLUSFL') THEN
        IF g_v_called_from IN ('IGFSL005','UPDATE_MODE') THEN
          IF ((new_references.loan_per_begin_date <> old_references.loan_per_begin_date) OR
              (new_references.loan_per_end_date   <> old_references.loan_per_end_date))
          THEN
            -- invoke the procedure to create change record in igf_sl_clchsn_dtls table
            igf_sl_cl_create_chg.create_loan_chg_rec
            (
              p_new_loan_rec    => new_references,
              p_b_return_status => l_b_return_status,
              p_v_message_name  => l_v_message_name
            );
            -- if the above call out returns false and error message is returned,
            -- add the message to the error stack and error message text should be displayed
            -- in the calling form
            IF (NOT (l_b_return_status) AND l_v_message_name IS NOT NULL )
            THEN
              -- substring of the out bound parameter l_v_message_name is carried
              -- out since it can expect either IGS OR IGF message
              fnd_message.set_name(SUBSTR(l_v_message_name,1,3),l_v_message_name);
              igf_sl_cl_chg_prc.parse_tokens(
                p_t_message_tokens => igf_sl_cl_chg_prc.g_message_tokens);

              igs_ge_msg_stack.add;
              app_exception.raise_exception;
            END IF;
          END IF;
        END IF;
      END IF;
	  -- tsailaja -FA 163  Bug 5337555
   -- FA 161 and FA 162 Changes
      -- FA 161 Bug 5006587 - Included UPDATE_MODE in g_v_called_from
      IF ((l_v_fed_fund_code IN ('DLS','DLU','DLP') AND g_v_called_from IN ('IGFSL005')) OR
         (l_v_fed_fund_code IN ('FLS','FLU','FLP','ALT','GPLUSFL') AND g_v_called_from IN ('IGFSL005','UPDATE_MODE')))
      THEN
          -- If either loan status or loan change status CHANGED to "Ready to Send"
          -- then update all disbursement change records in "Sent" status to "Ready to Send"
          IF (new_references.loan_status = 'G' AND old_references.loan_status <> 'G') OR
             (NVL(new_references.loan_chg_status, '*') = 'G' AND NVL(old_references.loan_chg_status,'*') <> 'G')
          THEN
            -- update disbursement change records(which are in "Sent" ONLY) status to "Ready to Send"
            FOR rec IN cur_sent_disb_chg_records(new_references.award_id) LOOP
              igf_aw_db_chg_dtls_pkg.update_row (
                x_rowid                 => rec.ROWID,
                x_award_id              => rec.award_id,
                x_disb_num              => rec.disb_num,
                x_disb_seq_num          => rec.disb_seq_num,
                x_disb_accepted_amt     => rec.disb_accepted_amt,
                x_orig_fee_amt          => rec.orig_fee_amt,
                x_disb_net_amt          => rec.disb_net_amt,
                x_disb_date             => rec.disb_date,
                x_disb_activity         => rec.disb_activity,
                x_disb_status           => 'G',
                x_disb_status_date      => TRUNC(SYSDATE),
                x_disb_rel_flag         => rec.disb_rel_flag,
                x_first_disb_flag       => rec.first_disb_flag,
                x_interest_rebate_amt   => rec.interest_rebate_amt,
                x_disb_conf_flag        => rec.disb_conf_flag,
                x_pymnt_prd_start_date  => rec.pymnt_prd_start_date,
                x_note_message          => rec.note_message,
                x_batch_id_txt          => rec.batch_id_txt,
                x_ack_date              => rec.ack_date,
                x_booking_id_txt        => rec.booking_id_txt,
                x_booking_date          => rec.booking_date,
                x_mode                  => 'R'
              );
            END LOOP;
			-- tsailaja -FA 163  Bug 5337555
            -- bvisvana - Bug 5091652
            -- If either loan status or loan change status CHANGED to "Ready to Send"
            -- then update all change change records in "Sent" status to "Ready to Send".Change records apply only for FFELP
            IF (l_v_fed_fund_code IN ('FLS','FLU','FLP','ALT','GPLUSFL') AND g_v_called_from IN ('IGFSL005','UPDATE_MODE')) THEN
              FOR rec_c_igf_sl_clchsn_dtls IN cur_loan_chg_records(new_references.award_id) LOOP
                igf_sl_clchsn_dtls_pkg.update_row (
                  x_rowid                      => rec_c_igf_sl_clchsn_dtls.ROWID                      ,
                  x_clchgsnd_id                => rec_c_igf_sl_clchsn_dtls.clchgsnd_id                ,
                  x_award_id                   => rec_c_igf_sl_clchsn_dtls.award_id                   ,
                  x_loan_number_txt            => rec_c_igf_sl_clchsn_dtls.loan_number_txt            ,
                  x_cl_version_code            => rec_c_igf_sl_clchsn_dtls.cl_version_code            ,
                  x_change_field_code          => rec_c_igf_sl_clchsn_dtls.change_field_code          ,
                  x_change_record_type_txt     => rec_c_igf_sl_clchsn_dtls.change_record_type_txt     ,
                  x_change_code_txt            => rec_c_igf_sl_clchsn_dtls.change_code_txt            ,
                  x_status_code                => 'R'                                                 ,
                  x_status_date                => rec_c_igf_sl_clchsn_dtls.status_date                ,
                  x_response_status_code       => rec_c_igf_sl_clchsn_dtls.response_status_code       ,
                  x_old_value_txt              => rec_c_igf_sl_clchsn_dtls.old_value_txt              ,
                  x_new_value_txt              => rec_c_igf_sl_clchsn_dtls.new_value_txt              ,
                  x_old_date                   => rec_c_igf_sl_clchsn_dtls.old_date                   ,
                  x_new_date                   =>  rec_c_igf_sl_clchsn_dtls.new_date                  ,
                  x_old_amt                    => rec_c_igf_sl_clchsn_dtls.old_amt                    ,
                  x_new_amt                    => rec_c_igf_sl_clchsn_dtls.new_amt                    ,
                  x_disbursement_number        => rec_c_igf_sl_clchsn_dtls.disbursement_number        ,
                  x_disbursement_date          => rec_c_igf_sl_clchsn_dtls.disbursement_date          ,
                  x_change_issue_code          => rec_c_igf_sl_clchsn_dtls.change_issue_code          ,
                  x_disbursement_cancel_date   => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_date   ,
                  x_disbursement_cancel_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_cancel_amt    ,
                  x_disbursement_revised_amt   => rec_c_igf_sl_clchsn_dtls.disbursement_revised_amt   ,
                  x_disbursement_revised_date  => rec_c_igf_sl_clchsn_dtls.disbursement_revised_date  ,
                  x_disbursement_reissue_code  => rec_c_igf_sl_clchsn_dtls.disbursement_reissue_code  ,
                  x_disbursement_reinst_code   => rec_c_igf_sl_clchsn_dtls.disbursement_reinst_code   ,
                  x_disbursement_return_amt    => rec_c_igf_sl_clchsn_dtls.disbursement_return_amt    ,
                  x_disbursement_return_date   => rec_c_igf_sl_clchsn_dtls.disbursement_return_date   ,
                  x_disbursement_return_code   => rec_c_igf_sl_clchsn_dtls.disbursement_return_code   ,
                  x_post_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_amt  ,
                  x_post_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_date ,
                  x_post_with_disb_return_code => rec_c_igf_sl_clchsn_dtls.post_with_disb_return_code ,
                  x_prev_with_disb_return_amt  => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_amt  ,
                  x_prev_with_disb_return_date => rec_c_igf_sl_clchsn_dtls.prev_with_disb_return_date ,
                  x_school_use_txt             => rec_c_igf_sl_clchsn_dtls.school_use_txt             ,
                  x_lender_use_txt             => rec_c_igf_sl_clchsn_dtls.lender_use_txt             ,
                  x_guarantor_use_txt          => rec_c_igf_sl_clchsn_dtls.guarantor_use_txt          ,
                  x_validation_edit_txt        => NULL                                                ,
                  x_send_record_txt            => rec_c_igf_sl_clchsn_dtls.send_record_txt            ,
                  x_mode                       => 'R'
                );
              END LOOP;  -- end of "FOR rec_c_igf_sl_clchsn_dtls"  ....
            END IF; -- end of "IF (l_v_fed_fund_code IN" ....
      END IF;
      END IF; -- IF DLP OR DLU or DLS OR FLS or FLP ......
    END IF; -- IF p_updating
  END AfterRowInsertUpdateDelete1;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2 ,
    x_rowid                             IN     VARCHAR2 ,
    x_loan_id                           IN     NUMBER   ,
    x_award_id                          IN     NUMBER   ,
    x_seq_num                           IN     NUMBER   ,
    x_loan_number                       IN     VARCHAR2 ,
    x_loan_per_begin_date               IN     DATE     ,
    x_loan_per_end_date                 IN     DATE     ,
    x_loan_status                       IN     VARCHAR2 ,
    x_loan_status_date                  IN     DATE     ,
    x_loan_chg_status                   IN     VARCHAR2 ,
    x_loan_chg_status_date              IN     DATE     ,
    x_active                            IN     VARCHAR2 ,
    x_active_date                       IN     DATE     ,
    x_borw_detrm_code                   IN     VARCHAR2 ,
    x_legacy_record_flag                IN     VARCHAR2 ,
    x_creation_date                     IN     DATE     ,
    x_created_by                        IN     NUMBER   ,
    x_last_update_date                  IN     DATE     ,
    x_last_updated_by                   IN     NUMBER   ,
    x_last_update_login                 IN     NUMBER   ,
    x_external_loan_id_txt              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_loan_id,
      x_award_id,
      x_seq_num,
      x_loan_number,
      x_loan_per_begin_date,
      x_loan_per_end_date,
      x_loan_status,
      x_loan_status_date,
      x_loan_chg_status,
      x_loan_chg_status_date,
      x_active,
      x_active_date,
      x_borw_detrm_code,
      x_legacy_record_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_external_loan_id_txt
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( new_references.loan_id ) ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation ( new_references.loan_id ) ) THEN
        FND_MESSAGE.SET_NAME('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;

  PROCEDURE after_dml (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
   /*-----------------------------------------------------------------
  ||  Created By : Sanil Madathil
  ||  Created On : 14 October 2004
  ||  Purpose : Invoke the proceduers related to after update
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  --------------------------------------------------------------------*/
  BEGIN
    l_rowid := x_rowid;
    l_rowid := NULL;
    IF (p_action = 'UPDATE') THEN
     -- Call all the procedures related to After Update.
      AfterRowInsertUpdateDelete1
      (
        p_inserting => FALSE,
        p_updating  => TRUE ,
        p_deleting  => FALSE
      );
    END IF;
  END after_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_loan_id                           IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_seq_num                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_borw_detrm_code                   IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2 ,
    x_legacy_record_flag                IN     VARCHAR2 ,
    x_external_loan_id_txt              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
    CURSOR c IS
       SELECT   rowid
       FROM     igf_sl_loans_all
       WHERE    loan_id = x_loan_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;
    l_org_id                                igf_sl_loans_all.org_id%TYPE := igf_aw_gen.get_org_id;

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
      FND_MESSAGE.SET_NAME ('FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    SELECT igf_sl_loans_s.nextval INTO x_loan_id FROM DUAL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_loan_id                           => x_loan_id,
      x_award_id                          => x_award_id,
      x_seq_num                           => x_seq_num,
      x_loan_number                       => x_loan_number,
      x_loan_per_begin_date               => x_loan_per_begin_date,
      x_loan_per_end_date                 => x_loan_per_end_date,
      x_loan_status                       => x_loan_status,
      x_loan_status_date                  => x_loan_status_date,
      x_loan_chg_status                   => x_loan_chg_status,
      x_loan_chg_status_date              => x_loan_chg_status_date,
      x_active                            => x_active,
      x_active_date                       => x_active_date,
      x_borw_detrm_code                   => x_borw_detrm_code,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_external_loan_id_txt              => x_external_loan_id_txt
    );

    INSERT INTO igf_sl_loans_all(
      loan_id,
      award_id,
      seq_num,
      loan_number,
      loan_per_begin_date,
      loan_per_end_date,
      loan_status,
      loan_status_date,
      loan_chg_status,
      loan_chg_status_date,
      active,
      active_date,
      borw_detrm_code,
      legacy_record_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date ,
      org_id,
      external_loan_id_txt
    ) VALUES (
      new_references.loan_id,
      new_references.award_id,
      new_references.seq_num,
      new_references.loan_number,
      new_references.loan_per_begin_date,
      new_references.loan_per_end_date,
      new_references.loan_status,
      new_references.loan_status_date,
      new_references.loan_chg_status,
      new_references.loan_chg_status_date,
      new_references.active,
      new_references.active_date,
      new_references.borw_detrm_code,
      new_references.legacy_record_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date,
      l_org_id ,
      new_references.external_loan_id_txt
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
       CLOSE c;
       RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_loan_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_seq_num                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_borw_detrm_code                   IN     VARCHAR2,
    x_legacy_record_flag                IN     VARCHAR2,
    x_external_loan_id_txt              IN     VARCHAR2
    ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  mnade           21-Jan-2005     Bug 4124891 Added TRUNC in date comparison.
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
    CURSOR c1 IS
      SELECT award_id,
             seq_num,
             loan_number,
             loan_per_begin_date,
             loan_per_end_date,
             loan_status,
             loan_status_date,
             loan_chg_status,
             loan_chg_status_date,
             active,
             active_date,
             borw_detrm_code,
             legacy_record_flag,
             org_id,
             external_loan_id_txt
      FROM   igf_sl_loans_all
      WHERE  rowid = x_rowid
      FOR UPDATE NOWAIT;

    tlinfo c1%ROWTYPE;

  BEGIN

    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%notfound) THEN
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      CLOSE c1;
      APP_EXCEPTION.RAISE_EXCEPTION;
      RETURN;
    END IF;
    CLOSE c1;

    IF (
        (tlinfo.award_id = x_award_id)
        AND ((tlinfo.seq_num = x_seq_num) OR ((tlinfo.seq_num IS NULL) AND (X_seq_num IS NULL)))
        AND ((tlinfo.loan_number = x_loan_number) OR ((tlinfo.loan_number IS NULL) AND (X_loan_number IS NULL)))
        AND (TRUNC(tlinfo.loan_per_begin_date) = TRUNC(x_loan_per_begin_date))
        AND (TRUNC(tlinfo.loan_per_end_date) = TRUNC(x_loan_per_end_date))
        AND (tlinfo.loan_status = x_loan_status)
        AND ((TRUNC(tlinfo.loan_status_date) = TRUNC(x_loan_status_date)) OR ((tlinfo.loan_status_date IS NULL) AND (X_loan_status_date IS NULL)))
        AND ((tlinfo.loan_chg_status = x_loan_chg_status) OR ((tlinfo.loan_chg_status IS NULL) AND (X_loan_chg_status IS NULL)))
        AND ((TRUNC(tlinfo.loan_chg_status_date) = TRUNC(x_loan_chg_status_date)) OR ((tlinfo.loan_chg_status_date IS NULL) AND (X_loan_chg_status_date IS NULL)))
        AND (tlinfo.active = x_active)
        AND (TRUNC(tlinfo.active_date) = TRUNC(x_active_date))
        AND ((tlinfo.borw_detrm_code = x_borw_detrm_code) OR
             ((tlinfo.borw_detrm_code IS NULL) AND (x_borw_detrm_code IS NULL)))
        AND ((tlinfo.legacy_record_flag = x_legacy_record_flag) OR
             ((tlinfo.legacy_record_flag IS NULL) AND (x_legacy_record_flag IS NULL)))
       AND ((tlinfo.external_loan_id_txt = x_external_loan_id_txt) OR ((tlinfo.external_loan_id_txt IS NULL) AND (x_external_loan_id_txt IS NULL)))
       ) THEN
      NULL;
    ELSE
      FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_loan_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_seq_num                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_borw_detrm_code                   IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2 ,
    x_legacy_record_flag                IN     VARCHAR2 ,
    x_external_loan_id_txt              IN     VARCHAR2 ,
    x_called_from                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
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
      FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
      APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_loan_id                           => x_loan_id,
      x_award_id                          => x_award_id,
      x_seq_num                           => x_seq_num,
      x_loan_number                       => x_loan_number,
      x_loan_per_begin_date               => x_loan_per_begin_date,
      x_loan_per_end_date                 => x_loan_per_end_date,
      x_loan_status                       => x_loan_status,
      x_loan_status_date                  => x_loan_status_date,
      x_loan_chg_status                   => x_loan_chg_status,
      x_loan_chg_status_date              => x_loan_chg_status_date,
      x_active                            => x_active,
      x_active_date                       => x_active_date,
      x_borw_detrm_code                   => x_borw_detrm_code,
      x_legacy_record_flag                => x_legacy_record_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_external_loan_id_txt              => x_external_loan_id_txt
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

    UPDATE igf_sl_loans_all
      SET
        award_id                          = new_references.award_id,
        seq_num                           = new_references.seq_num,
        loan_number                       = new_references.loan_number,
        loan_per_begin_date               = new_references.loan_per_begin_date,
        loan_per_end_date                 = new_references.loan_per_end_date,
        loan_status                       = new_references.loan_status,
        loan_status_date                  = new_references.loan_status_date,
        loan_chg_status                   = new_references.loan_chg_status,
        loan_chg_status_date              = new_references.loan_chg_status_date,
        active                            = new_references.active,
        active_date                       = new_references.active_date,
        borw_detrm_code                   = new_references.borw_detrm_code,
        legacy_record_flag                = new_references.legacy_record_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date,
        external_loan_id_txt              = new_references.external_loan_id_txt
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
    g_v_called_from := x_called_from;
    after_dml(
            p_action =>'UPDATE',
            x_rowid => x_rowid
          );

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_loan_id                           IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_seq_num                           IN     NUMBER,
    x_loan_number                       IN     VARCHAR2,
    x_loan_per_begin_date               IN     DATE,
    x_loan_per_end_date                 IN     DATE,
    x_loan_status                       IN     VARCHAR2,
    x_loan_status_date                  IN     DATE,
    x_loan_chg_status                   IN     VARCHAR2,
    x_loan_chg_status_date              IN     DATE,
    x_active                            IN     VARCHAR2,
    x_active_date                       IN     DATE,
    x_borw_detrm_code                   IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2 ,
    x_legacy_record_flag                IN     VARCHAR2,
    x_external_loan_id_txt              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  smadathi        14-oct-2004     Bug 3416936.Added new column as per TD.
  ||  agairola        15-Mar-2002     Added the code for the new column
  ||                                  for the Borrower Determination
  */
    CURSOR c1 IS
       SELECT rowid
       FROM   igf_sl_loans_all
       WHERE  loan_id  = x_loan_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
       CLOSE c1;

      insert_row (
        x_rowid,
        x_loan_id,
        x_award_id,
        x_seq_num,
        x_loan_number,
        x_loan_per_begin_date,
        x_loan_per_end_date,
        x_loan_status,
        x_loan_status_date,
        x_loan_chg_status,
        x_loan_chg_status_date,
        x_active,
        x_active_date,
        x_borw_detrm_code,
        x_mode ,
        x_legacy_record_flag,
        x_external_loan_id_txt
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_loan_id,
      x_award_id,
      x_seq_num,
      x_loan_number,
      x_loan_per_begin_date,
      x_loan_per_end_date,
      x_loan_status,
      x_loan_status_date,
      x_loan_chg_status,
      x_loan_chg_status_date,
      x_active,
      x_active_date,
      x_borw_detrm_code,
      x_mode ,
      x_legacy_record_flag,
      x_external_loan_id_txt
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : venagara
  ||  Created On : 02-DEC-2000
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    before_dml ( p_action => 'DELETE', x_rowid => x_rowid );

    DELETE FROM igf_sl_loans_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
       RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sl_loans_pkg;

/
