--------------------------------------------------------
--  DDL for Package Body IGF_DB_DISB_HOLDS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_DB_DISB_HOLDS_PKG" AS
/* $Header: IGFDI09B.pls 120.1 2006/08/10 15:42:17 museshad noship $ */

/*=======================================================================+
 |  Copyright (c) 1994, 1996 Oracle Corp. Redwood Shores, California, USA|
 |                            All rights reserved.                       |
 +=======================================================================+
 |                                                                       |
 | DESCRIPTION                                                           |
 |      PL/SQL body for package: IGF_DB_DISB_HOLDS_PKG
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
 | museshad      10-Aug-2006     5337555. Build FA 163.TBH Impact changes|
 | veramach      July 2004       FA 151 HR integration (bug # 3709292)   |
 |                               Impact of obsoleting columns from       |
 |                               igf_aw_awd_disb_pkg                     |
 | Bug No :- 2154941                                                     |
 | Desc   :- Disbursement and Sponsership Build for Jul 2002  FACCR004   |
 | WHO       WHEN           WHAT

--
-- Bug ID    2544864
-- sjadhav   Oct.07.2002  Gscc fix of removing the Default Keyword
--

 --
 -- Bug 2255279
 -- sjadhav, set elig_status = 'O' [ OVERAWARD ]
 -- and elig_status_date = systdate in case of a overaward hold
 --

 | mesriniv  31-JAN-2002   Made the call to check uniqueness in
 |                         update only when the new and old values are diff
 | mesriniv  8-JAN-2002     Created this Table Handler
 |                          Added a procedure check_uniqueness for Business
 |                          whenever record is inserted or updated
 |                          from form or package                         |
 *=======================================================================*/

  l_rowid VARCHAR2(25);
  old_references igf_db_disb_holds_all%ROWTYPE;
  new_references igf_db_disb_holds_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_hold_id                           IN     NUMBER  ,
    x_award_id                          IN     NUMBER  ,
    x_disb_num                          IN     NUMBER  ,
    x_hold                              IN     VARCHAR2,
    x_hold_date                         IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_release_date                      IN     DATE    ,
    x_release_flag                      IN     VARCHAR2,
    x_release_reason                    IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_db_disb_holds_all
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
    new_references.hold_id                           := x_hold_id;
    new_references.award_id                          := x_award_id;
    new_references.disb_num                          := x_disb_num;
    new_references.hold                              := x_hold;
    new_references.hold_date                         := x_hold_date;
    new_references.hold_type                         := x_hold_type;
    new_references.release_date                      := x_release_date;
    new_references.release_flag                      := x_release_flag;
    new_references.release_reason                    := x_release_reason;

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

  PROCEDURE check_uniqueness(x_award_id NUMBER ,x_disb_num NUMBER,x_hold VARCHAR2) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 05-JAN-2002
  ||  Purpose : Handles the Unique Constraint logic.Please note that
  ||            this table does not have unique constraints defined
  ||            but a specific validation has been added
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */


   --Cursor to find if there is already a Hold existing of the same as the one being inserted
     --and for which the release flg is N
     CURSOR cur_get_hold IS
       SELECT COUNT(HOLD_ID)
       FROM   igf_db_disb_holds
       WHERE  award_id = x_award_id
       AND    disb_num = x_disb_num
       AND    hold     = x_hold
       AND    release_flag ='N'
       AND    ROWNUM       <= 1;

       l_count     NUMBER(1);

  BEGIN



      l_count:=0;
    --Fetch the count of the DIsbursment Hold
      OPEN cur_get_hold;
      FETCH cur_get_hold INTO l_count;
      CLOSE cur_get_hold;


      --Even if one Hold of same kind exists then we need to stop from Inserting
      --a duplicate one
      IF (NVL(l_count,0) = 1) THEN

          fnd_message.set_name('IGF','IGF_DB_HOLD_EXISTS');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
      END IF;


  END check_uniqueness;



  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.award_id = new_references.award_id) AND
         (old_references.disb_num = new_references.disb_num)) OR
        ((new_references.award_id IS NULL) OR
         (new_references.disb_num IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_awd_disb_pkg.get_pk_for_validation (
                new_references.award_id,
                new_references.disb_num
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_hold_id                           IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_db_disb_holds_all
      WHERE    hold_id = x_hold_id
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


  PROCEDURE get_fk_igf_aw_awd_disb (
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_db_disb_holds_all
      WHERE   ((award_id = x_award_id) AND
               (disb_num = x_disb_num));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_DB_HOLD_ADISB_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_awd_disb;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_hold_id                           IN     NUMBER  ,
    x_award_id                          IN     NUMBER  ,
    x_disb_num                          IN     NUMBER  ,
    x_hold                              IN     VARCHAR2,
    x_hold_date                         IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_release_date                      IN     DATE    ,
    x_release_flag                      IN     VARCHAR2,
    x_release_reason                    IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_hold_id,
      x_award_id,
      x_disb_num,
      x_hold,
      x_hold_date,
      x_hold_type,
      x_release_date,
      x_release_flag,
      x_release_reason,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.hold_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
     --Call this Check Uniqueness only for a release flag of N
      IF x_release_flag='N' THEN
      check_uniqueness(x_award_id,x_disb_num,x_hold);
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
       --Call this Check Uniqueness only for a release flag of N
      IF x_release_flag='N'  AND new_references.hold <> old_references.hold THEN
      check_uniqueness(x_award_id,x_disb_num,x_hold);
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.hold_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      --Call this Check Uniqueness only for a release flag of N
       IF x_release_flag='N' THEN
      check_uniqueness(x_award_id,x_disb_num,x_hold);
      END IF;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
     --Call this Check Uniqueness only for a release flag of N
      IF x_release_flag='N' AND new_references.hold <> old_references.hold THEN
      check_uniqueness(x_award_id,x_disb_num,x_hold);
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hold_id                           IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_hold                              IN     VARCHAR2,
    x_hold_date                         IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_release_date                      IN     DATE,
    x_release_flag                      IN     VARCHAR2,
    x_release_reason                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_db_disb_holds_all
      WHERE    hold_id                           = x_hold_id;

    --Cursor to get the Disbursment to Update the Manual Hold Ind
     CURSOR cur_get_manualHold IS
     SELECT   *
     FROM   igf_aw_awd_disb
     WHERE  award_id  =x_award_id
     AND    disb_num  =x_disb_num
     FOR    UPDATE OF manual_hold_ind NOWAIT;



    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_disb_rec                   igf_aw_awd_disb%ROWTYPE;

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
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igf_db_disb_holds_s.NEXTVAL
    INTO      x_hold_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;



    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_hold_id                           => x_hold_id,
      x_award_id                          => x_award_id,
      x_disb_num                          => x_disb_num,
      x_hold                              => x_hold,
      x_hold_date                         => x_hold_date,
      x_hold_type                         => x_hold_type,
      x_release_date                      => x_release_date,
      x_release_flag                      => x_release_flag,
      x_release_reason                    => x_release_reason,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_db_disb_holds_all (
      hold_id,
      award_id,
      disb_num,
      hold,
      hold_date,
      hold_type,
      release_date,
      release_flag,
      release_reason,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.hold_id,
      new_references.award_id,
      new_references.disb_num,
      new_references.hold,
      new_references.hold_date,
      new_references.hold_type,
      new_references.release_date,
      new_references.release_flag,
      new_references.release_reason,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;

    --Update the Manual Hold Indicator as 'Y' anytime a New MANUAL Hold is Inserted by the User
    --Through the FORM IGFDB002.fmx
    l_disb_rec :=NULL;
    IF  new_references.hold_type in ('MANUAL','SYSTEM') THEN

       --Fetch the Cursor Record
          OPEN cur_get_ManualHold;
          FETCH cur_get_ManualHold INTO  l_disb_rec;
          CLOSE cur_get_ManualHold;

         IF new_references.hold = 'OVERAWARD' THEN
                l_disb_rec.elig_status      := 'O';
                l_disb_rec.elig_status_date := TRUNC(SYSDATE);
         END IF;

       --Call the Update row the Award Disbursement Table
      igf_aw_awd_disb_pkg.update_row(
                                    x_rowid                     =>    l_disb_rec.row_id,
                                    x_award_id                  =>    l_disb_rec.award_id,
                                    x_disb_num                  =>    l_disb_rec.disb_num,
                                    x_tp_cal_type               =>    l_disb_rec.tp_cal_type,
                                    x_tp_sequence_number        =>    l_disb_rec.tp_sequence_number,
                                    x_disb_gross_amt            =>    l_disb_rec.disb_gross_amt,
                                    x_fee_1                     =>    l_disb_rec.fee_1,
                                    x_fee_2                     =>    l_disb_rec.fee_2,
                                    x_disb_net_amt              =>    l_disb_rec.disb_net_amt,
                                    x_disb_date                 =>    l_disb_rec.disb_date,
                                    x_trans_type                =>    l_disb_rec.trans_type,
                                    x_elig_status               =>    l_disb_rec.elig_status,
                                    x_elig_status_date          =>    l_disb_rec.elig_status_date,
                                    x_affirm_flag               =>    l_disb_rec.affirm_flag,
                                    x_hold_rel_ind              =>     l_disb_rec.hold_rel_ind,
                                    x_manual_hold_ind           =>    'Y',
                                    x_disb_status               =>    l_disb_rec.disb_status,
                                    x_disb_status_date          =>    l_disb_rec.disb_status_date,
                                    x_late_disb_ind             =>    l_disb_rec.late_disb_ind,
                                    x_fund_dist_mthd            =>    l_disb_rec.fund_dist_mthd,
                                    x_prev_reported_ind         =>    l_disb_rec.prev_reported_ind,
                                    x_fund_release_date         =>    l_disb_rec.fund_release_date,
                                    x_fund_status               =>    l_disb_rec.fund_status,
                                    x_fund_status_date          =>    l_disb_rec.fund_status_date,
                                    x_fee_paid_1                =>    l_disb_rec.fee_paid_1,
                                    x_fee_paid_2                =>    l_disb_rec. fee_paid_2,
                                    x_cheque_number             =>    l_disb_rec.cheque_number,
                                    x_ld_cal_type               =>    l_disb_rec.ld_cal_type,
                                    x_ld_sequence_number        =>    l_disb_rec.ld_sequence_number,
                                    x_disb_accepted_amt         =>    l_disb_rec.disb_accepted_amt,
                                    x_disb_paid_amt             =>    l_disb_rec.disb_paid_amt,
                                    x_rvsn_id                   =>    l_disb_rec.rvsn_id,
                                    x_int_rebate_amt            =>    l_disb_rec.int_rebate_amt,
                                    x_force_disb                =>    l_disb_rec.force_disb,
                                    x_min_credit_pts            =>    l_disb_rec.min_credit_pts,
                                    x_disb_exp_dt               =>    l_disb_rec.disb_exp_dt,
                                    x_verf_enfr_dt              =>    l_disb_rec.verf_enfr_dt,
                                    x_fee_class                 =>    l_disb_rec. fee_class,
                                    x_show_on_bill              =>    l_disb_rec.show_on_bill,
                                    x_attendance_type_code      =>    l_disb_rec.attendance_type_code,
                                    x_base_attendance_type_code =>    l_disb_rec.base_attendance_type_code,
                                    x_payment_prd_st_date       =>    l_disb_rec.payment_prd_st_date,
                                    x_change_type_code          =>    l_disb_rec.change_type_code,
                                    x_fund_return_mthd_code     =>    l_disb_rec.fund_return_mthd_code,
                                    x_direct_to_borr_flag       =>    l_disb_rec.direct_to_borr_flag,
                                    x_mode                      =>    'R');

     END IF; --check for Manual Hold


  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hold_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_hold                              IN     VARCHAR2,
    x_hold_date                         IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_release_date                      IN     DATE,
    x_release_flag                      IN     VARCHAR2,
    x_release_reason                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        award_id,
        disb_num,
        hold,
        hold_date,
        hold_type,
        release_date,
        release_flag,
        release_reason
      FROM  igf_db_disb_holds_all
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
        (tlinfo.award_id = x_award_id)
        AND (tlinfo.disb_num = x_disb_num)
        AND (tlinfo.hold = x_hold)
        AND (tlinfo.hold_date = x_hold_date)
        AND (tlinfo.hold_type = x_hold_type)
        AND ((tlinfo.release_date = x_release_date) OR ((tlinfo.release_date IS NULL) AND (X_release_date IS NULL)))
        AND ((tlinfo.release_flag = x_release_flag) OR ((tlinfo.release_flag IS NULL) AND (X_release_flag IS NULL)))
        AND ((tlinfo.release_reason = x_release_reason) OR ((tlinfo.release_reason IS NULL) AND (X_release_reason IS NULL)))
       ) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    RETURN;

  END lock_row;


  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_hold_id                           IN     NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_hold                              IN     VARCHAR2,
    x_hold_date                         IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_release_date                      IN     DATE,
    x_release_flag                      IN     VARCHAR2,
    x_release_reason                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    l_hold_id                    igf_db_disb_holds.hold_id%TYPE;
    l_disb_rec                   igf_aw_awd_disb%ROWTYPE;

    --Cursor to check if all the Holds has been released for the disbursement
    CURSOR cur_get_Holds IS
    SELECT hold_id
    FROM   igf_db_disb_holds
    WHERE  disb_num =x_disb_num
    AND    award_id = x_award_id
    AND    release_flag ='N';


    --Cursor to fetch the Disbursement
    CURSOR cur_get_disb IS
    SELECT * FROM igf_aw_awd_disb
    WHERE  award_id=x_award_id
    AND    disb_num =x_disb_num
    FOR    UPDATE OF disb_num NOWAIT;


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
      x_hold_id                           => x_hold_id,
      x_award_id                          => x_award_id,
      x_disb_num                          => x_disb_num,
      x_hold                              => x_hold,
      x_hold_date                         => x_hold_date,
      x_hold_type                         => x_hold_type,
      x_release_date                      => x_release_date,
      x_release_flag                      => x_release_flag,
      x_release_reason                    => x_release_reason,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_db_disb_holds_all
      SET
        award_id                          = new_references.award_id,
        disb_num                          = new_references.disb_num,
        hold                              = new_references.hold,
        hold_date                         = new_references.hold_date,
        hold_type                         = new_references.hold_type,
        release_date                      = new_references.release_date,
        release_flag                      = new_references.release_flag,
        release_reason                    = new_references.release_reason,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

     --Whenever the Rlease Flag is Set To N from anywhere ,we need to check if all the Holds have been
    --released.If all the Holds are released then we need to Update the Release Hold Ind and the
    --Manual Hold Ind for the disbursement in the award disbursements as Y.
    --To indicate that there are no Holds for this Disbursement

    --Do this only when a release is made
    IF ( new_references.release_flag ='Y' ) THEN

    --Check if all the Holds have been released.
    --Even if there is one Hold then do not Update the Disbursement Table.
    --Only if not found do we update the disbursement table
    --To indicate that all the Holds for this disbursement are released

       OPEN cur_get_holds;
       FETCH cur_get_holds INTO l_hold_id;
       IF cur_get_holds%NOTFOUND THEN

    --Fetch the Cursor Record
          OPEN cur_get_disb ;
            FETCH cur_get_disb INTO  l_disb_rec;
          CLOSE cur_get_disb;

       --Call the Update row the Award Disbursement Table
       igf_aw_awd_disb_pkg.update_row(
                                        x_rowid                     =>    l_disb_rec.row_id,
                                        x_award_id                  =>    l_disb_rec.award_id,
                                        x_disb_num                  =>    l_disb_rec.disb_num,
                                        x_tp_cal_type               =>    l_disb_rec.tp_cal_type,
                                        x_tp_sequence_number        =>    l_disb_rec.tp_sequence_number,
                                        x_disb_gross_amt            =>    l_disb_rec.disb_gross_amt,
                                        x_fee_1                     =>    l_disb_rec.fee_1,
                                        x_fee_2                     =>    l_disb_rec.fee_2,
                                        x_disb_net_amt              =>    l_disb_rec.disb_net_amt,
                                        x_disb_date                 =>    l_disb_rec.disb_date,
                                        x_trans_type                =>    l_disb_rec.trans_type,
                                        x_elig_status               =>    l_disb_rec.elig_status,
                                        x_elig_status_date          =>    l_disb_rec.elig_status_date,
                                        x_affirm_flag               =>    l_disb_rec.affirm_flag,
                                        x_hold_rel_ind              =>    l_disb_rec.hold_rel_ind,
                                        x_manual_hold_ind           =>    'N',
                                        x_disb_status               =>    l_disb_rec.disb_status,
                                        x_disb_status_date          =>    l_disb_rec.disb_status_date,
                                        x_late_disb_ind             =>    l_disb_rec.late_disb_ind,
                                        x_fund_dist_mthd            =>    l_disb_rec.fund_dist_mthd,
                                        x_prev_reported_ind         =>    l_disb_rec.prev_reported_ind,
                                        x_fund_release_date         =>    l_disb_rec.fund_release_date,
                                        x_fund_status               =>    l_disb_rec.fund_status,
                                        x_fund_status_date          =>    l_disb_rec.fund_status_date,
                                        x_fee_paid_1                =>    l_disb_rec.fee_paid_1,
                                        x_fee_paid_2                =>    l_disb_rec. fee_paid_2,
                                        x_cheque_number             =>    l_disb_rec.cheque_number,
                                        x_ld_cal_type               =>    l_disb_rec.ld_cal_type,
                                        x_ld_sequence_number        =>    l_disb_rec.ld_sequence_number,
                                        x_disb_accepted_amt         =>    l_disb_rec.disb_accepted_amt,
                                        x_disb_paid_amt             =>    l_disb_rec.disb_paid_amt,
                                        x_rvsn_id                   =>    l_disb_rec.rvsn_id,
                                        x_int_rebate_amt            =>    l_disb_rec.int_rebate_amt,
                                        x_force_disb                =>    l_disb_rec.force_disb,
                                        x_min_credit_pts            =>    l_disb_rec.min_credit_pts,
                                        x_disb_exp_dt               =>    l_disb_rec.disb_exp_dt,
                                        x_verf_enfr_dt              =>    l_disb_rec.verf_enfr_dt,
                                        x_fee_class                 =>    l_disb_rec. fee_class,
                                        x_show_on_bill              =>    l_disb_rec.show_on_bill,
                                        x_attendance_type_code      =>    l_disb_rec.attendance_type_code,
                                        x_base_attendance_type_code =>    l_disb_rec.base_attendance_type_code,
                                        x_payment_prd_st_date       =>    l_disb_rec.payment_prd_st_date,
                                        x_change_type_code          =>    l_disb_rec.change_type_code,
                                        x_fund_return_mthd_code     =>    l_disb_rec.fund_return_mthd_code,
                                        x_direct_to_borr_flag       =>    l_disb_rec.direct_to_borr_flag,
                                        x_mode                      =>    'R'
                                    );



     CLOSE  cur_get_holds;
     END IF; --End of cursor found check
     END IF; --end of check if a hold is released


  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hold_id                           IN OUT NOCOPY NUMBER,
    x_award_id                          IN     NUMBER,
    x_disb_num                          IN     NUMBER,
    x_hold                              IN     VARCHAR2,
    x_hold_date                         IN     VARCHAR2,
    x_hold_type                         IN     VARCHAR2,
    x_release_date                      IN     DATE,
    x_release_flag                      IN     VARCHAR2,
    x_release_reason                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_db_disb_holds_all
      WHERE    hold_id                           = x_hold_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_hold_id,
        x_award_id,
        x_disb_num,
        x_hold,
        x_hold_date,
        x_hold_type,
        x_release_date,
        x_release_flag,
        x_release_reason,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_hold_id,
      x_award_id,
      x_disb_num,
      x_hold,
      x_hold_date,
      x_hold_type,
      x_release_date,
      x_release_flag,
      x_release_reason,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : mesriniv
  ||  Created On : 08-JAN-2002
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

    DELETE FROM igf_db_disb_holds_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_db_disb_holds_pkg;

/
