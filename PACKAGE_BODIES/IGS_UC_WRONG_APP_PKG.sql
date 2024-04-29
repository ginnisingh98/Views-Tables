--------------------------------------------------------
--  DDL for Package Body IGS_UC_WRONG_APP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_WRONG_APP_PKG" AS
/* $Header: IGSXI34B.pls 115.8 2003/07/30 10:41:04 ayedubat noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_wrong_app%ROWTYPE;
  new_references igs_uc_wrong_app%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_wrong_app_id                      IN     NUMBER  ,
    x_app_no                            IN     NUMBER  ,
    x_miscoded                          IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_cancel_date                       IN     DATE    ,
    x_remark                            IN     VARCHAR2,
    x_expunge                           IN     VARCHAR2,
    x_batch_id                          IN     NUMBER  ,
    x_expunged                          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_joint_admission_ind               IN     VARCHAR2,
    x_choice1_lost                      IN     VARCHAR2,
    x_choice2_lost                      IN     VARCHAR2,
    x_choice3_lost                      IN     VARCHAR2,
    x_choice4_lost                      IN     VARCHAR2,
    x_choice5_lost                      IN     VARCHAR2,
    x_choice6_lost                      IN     VARCHAR2,
    x_choice7_lost                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_WRONG_APP
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
    new_references.wrong_app_id     := x_wrong_app_id;
    new_references.app_no           := x_app_no;
    new_references.miscoded         := x_miscoded;
    new_references.cancelled        := x_cancelled;
    new_references.cancel_date      := x_cancel_date;
    new_references.remark           := x_remark;
    new_references.expunge          := x_expunge;
    new_references.batch_id         := x_batch_id;
    new_references.expunged         := x_expunged;
    new_references.joint_admission_ind  := x_joint_admission_ind;
    new_references.choice1_lost       := x_choice1_lost ;
    new_references.choice2_lost       := x_choice2_lost ;
    new_references.choice3_lost       := x_choice3_lost ;
    new_references.choice4_lost       := x_choice4_lost ;
    new_references.choice5_lost       := x_choice5_lost ;
    new_references.choice6_lost       := x_choice6_lost ;
    new_references.choice7_lost       := x_choice7_lost ;

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
    new_references.joint_admission_ind               := x_joint_admission_ind ;

  END set_column_values;


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.wrong_app_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  FUNCTION get_pk_for_validation (
    x_app_no                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_wrong_app
      WHERE    app_no = x_app_no ;

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


  FUNCTION get_uk_for_validation (
    x_wrong_app_id                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_wrong_app
      WHERE    wrong_app_id = x_wrong_app_id
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_wrong_app_id                      IN     NUMBER  ,
    x_app_no                            IN     NUMBER  ,
    x_miscoded                          IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_cancel_date                       IN     DATE    ,
    x_remark                            IN     VARCHAR2,
    x_expunge                           IN     VARCHAR2,
    x_batch_id                          IN     NUMBER  ,
    x_expunged                          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_joint_admission_ind               IN     VARCHAR2,
    x_choice1_lost                      IN     VARCHAR2,
    x_choice2_lost                      IN     VARCHAR2,
    x_choice3_lost                      IN     VARCHAR2,
    x_choice4_lost                      IN     VARCHAR2,
    x_choice5_lost                      IN     VARCHAR2,
    x_choice6_lost                      IN     VARCHAR2,
    x_choice7_lost                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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
      x_wrong_app_id,
      x_app_no,
      x_miscoded,
      x_cancelled,
      x_cancel_date,
      x_remark,
      x_expunge,
      x_batch_id,
      x_expunged,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_joint_admission_ind,
      x_choice1_lost     ,
      x_choice2_lost     ,
      x_choice3_lost     ,
      x_choice4_lost     ,
      x_choice5_lost     ,
      x_choice6_lost     ,
      x_choice7_lost
      );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.app_no
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.app_no
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_wrong_app_id                      IN OUT NOCOPY NUMBER,
    x_app_no                            IN OUT NOCOPY NUMBER,
    x_miscoded                          IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_cancel_date                       IN     DATE,
    x_remark                            IN     VARCHAR2,
    x_expunge                           IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_expunged                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2,
    x_choice1_lost                      IN     VARCHAR2,
    x_choice2_lost                      IN     VARCHAR2,
    x_choice3_lost                      IN     VARCHAR2,
    x_choice4_lost                      IN     VARCHAR2,
    x_choice5_lost                      IN     VARCHAR2,
    x_choice6_lost                      IN     VARCHAR2,
    x_choice7_lost                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_wrong_app
      WHERE    app_no                            = x_app_no;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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

    SELECT    igs_uc_wrong_app_s.NEXTVAL
    INTO      x_wrong_app_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_wrong_app_id                      => x_wrong_app_id,
      x_app_no                            => x_app_no,
      x_miscoded                          => x_miscoded,
      x_cancelled                         => x_cancelled,
      x_cancel_date                       => x_cancel_date,
      x_remark                            => x_remark,
      x_expunge                           => x_expunge,
      x_batch_id                          => x_batch_id,
      x_expunged                          => x_expunged,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_joint_admission_ind               => x_joint_admission_ind,
      x_choice1_lost                      => x_choice1_lost ,
      x_choice2_lost                      => x_choice2_lost ,
      x_choice3_lost                      => x_choice3_lost ,
      x_choice4_lost                      => x_choice4_lost ,
      x_choice5_lost                      => x_choice5_lost ,
      x_choice6_lost                      => x_choice6_lost ,
      x_choice7_lost                      => x_choice7_lost
      );

    INSERT INTO igs_uc_wrong_app (
      wrong_app_id,
      app_no,
      miscoded,
      cancelled,
      cancel_date,
      remark,
      expunge,
      batch_id,
      expunged,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      joint_admission_ind,
      choice1_lost     ,
      choice2_lost     ,
      choice3_lost     ,
      choice4_lost     ,
      choice5_lost     ,
      choice6_lost     ,
      choice7_lost
    ) VALUES (
      new_references.wrong_app_id,
      new_references.app_no,
      new_references.miscoded,
      new_references.cancelled,
      new_references.cancel_date,
      new_references.remark,
      new_references.expunge,
      new_references.batch_id,
      new_references.expunged,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.joint_admission_ind,
      new_references.choice1_lost     ,
      new_references.choice2_lost     ,
      new_references.choice3_lost     ,
      new_references.choice4_lost     ,
      new_references.choice5_lost     ,
      new_references.choice6_lost     ,
      new_references.choice7_lost
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
    x_wrong_app_id                      IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_miscoded                          IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_cancel_date                       IN     DATE,
    x_remark                            IN     VARCHAR2,
    x_expunge                           IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_expunged                          IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2,
    x_choice1_lost                      IN     VARCHAR2,
    x_choice2_lost                      IN     VARCHAR2,
    x_choice3_lost                      IN     VARCHAR2,
    x_choice4_lost                      IN     VARCHAR2,
    x_choice5_lost                      IN     VARCHAR2,
    x_choice6_lost                      IN     VARCHAR2,
    x_choice7_lost                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        wrong_app_id,
        miscoded,
        cancelled,
        cancel_date,
        remark,
        expunge,
        batch_id,
        expunged,
        joint_admission_ind  ,
        choice1_lost       ,
        choice2_lost       ,
        choice3_lost       ,
        choice4_lost       ,
        choice5_lost       ,
        choice6_lost       ,
        choice7_lost
      FROM  igs_uc_wrong_app
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
        (tlinfo.wrong_app_id = x_wrong_app_id)
        AND (tlinfo.miscoded = x_miscoded)
        AND (tlinfo.cancelled = x_cancelled)
        AND ((tlinfo.cancel_date = x_cancel_date) OR ((tlinfo.cancel_date IS NULL) AND (X_cancel_date IS NULL)))
        AND ((tlinfo.remark = x_remark) OR ((tlinfo.remark IS NULL) AND (X_remark IS NULL)))
        AND (tlinfo.expunge = x_expunge)
        AND ((tlinfo.batch_id = x_batch_id) OR ((tlinfo.batch_id IS NULL) AND (X_batch_id IS NULL)))
        AND (tlinfo.expunged = x_expunged)
        AND ((tlinfo.joint_admission_ind = x_joint_admission_ind) OR ((tlinfo.joint_admission_ind IS NULL) AND (x_joint_admission_ind IS NULL)))
        AND ((tlinfo.choice1_lost = x_choice1_lost) OR ((tlinfo.choice1_lost IS NULL) AND (x_choice1_lost IS NULL)))
        AND ((tlinfo.choice2_lost = x_choice2_lost) OR ((tlinfo.choice2_lost IS NULL) AND (x_choice2_lost IS NULL)))
        AND ((tlinfo.choice3_lost = x_choice3_lost) OR ((tlinfo.choice3_lost IS NULL) AND (x_choice3_lost IS NULL)))
        AND ((tlinfo.choice4_lost = x_choice4_lost) OR ((tlinfo.choice4_lost IS NULL) AND (x_choice4_lost IS NULL)))
        AND ((tlinfo.choice5_lost = x_choice5_lost) OR ((tlinfo.choice5_lost IS NULL) AND (x_choice5_lost IS NULL)))
        AND ((tlinfo.choice6_lost = x_choice6_lost) OR ((tlinfo.choice6_lost IS NULL) AND (x_choice6_lost IS NULL)))
        AND ((tlinfo.choice7_lost = x_choice7_lost) OR ((tlinfo.choice7_lost IS NULL) AND (x_choice7_lost IS NULL)))
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
    x_wrong_app_id                      IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_miscoded                          IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_cancel_date                       IN     DATE,
    x_remark                            IN     VARCHAR2,
    x_expunge                           IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_expunged                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2,
    x_choice1_lost                      IN     VARCHAR2,
    x_choice2_lost                      IN     VARCHAR2,
    x_choice3_lost                      IN     VARCHAR2,
    x_choice4_lost                      IN     VARCHAR2,
    x_choice5_lost                      IN     VARCHAR2,
    x_choice6_lost                      IN     VARCHAR2,
    x_choice7_lost                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

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
      x_wrong_app_id                      => x_wrong_app_id,
      x_app_no                            => x_app_no,
      x_miscoded                          => x_miscoded,
      x_cancelled                         => x_cancelled,
      x_cancel_date                       => x_cancel_date,
      x_remark                            => x_remark,
      x_expunge                           => x_expunge,
      x_batch_id                          => x_batch_id,
      x_expunged                          => x_expunged,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_joint_admission_ind               => x_joint_admission_ind,
      x_choice1_lost                      => x_choice1_lost ,
      x_choice2_lost                      => x_choice2_lost ,
      x_choice3_lost                      => x_choice3_lost ,
      x_choice4_lost                      => x_choice4_lost ,
      x_choice5_lost                      => x_choice5_lost ,
      x_choice6_lost                      => x_choice6_lost ,
      x_choice7_lost                      => x_choice7_lost
     );

    UPDATE igs_uc_wrong_app
      SET
        wrong_app_id                      = new_references.wrong_app_id,
        miscoded                          = new_references.miscoded,
        cancelled                         = new_references.cancelled,
        cancel_date                       = new_references.cancel_date,
        remark                            = new_references.remark,
        expunge                           = new_references.expunge,
        batch_id                          = new_references.batch_id,
        expunged                          = new_references.expunged,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
    	  joint_admission_ind               = x_joint_admission_ind,
        choice1_lost                      = x_choice1_lost ,
        choice2_lost                      = x_choice2_lost ,
        choice3_lost                      = x_choice3_lost ,
        choice4_lost                      = x_choice4_lost ,
        choice5_lost                      = x_choice5_lost ,
        choice6_lost                      = x_choice6_lost ,
        choice7_lost                      = x_choice7_lost
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_wrong_app_id                      IN OUT NOCOPY NUMBER,
    x_app_no                            IN OUT NOCOPY NUMBER,
    x_miscoded                          IN     VARCHAR2,
    x_cancelled                         IN     VARCHAR2,
    x_cancel_date                       IN     DATE,
    x_remark                            IN     VARCHAR2,
    x_expunge                           IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_expunged                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_joint_admission_ind               IN     VARCHAR2,
    x_choice1_lost                      IN     VARCHAR2,
    x_choice2_lost                      IN     VARCHAR2,
    x_choice3_lost                      IN     VARCHAR2,
    x_choice4_lost                      IN     VARCHAR2,
    x_choice5_lost                      IN     VARCHAR2,
    x_choice6_lost                      IN     VARCHAR2,
    x_choice7_lost                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_wrong_app
      WHERE    app_no    = x_app_no;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_wrong_app_id,
        x_app_no,
        x_miscoded,
        x_cancelled,
        x_cancel_date,
        x_remark,
        x_expunge,
        x_batch_id,
        x_expunged,
        x_mode,
        x_joint_admission_ind,
        x_choice1_lost     ,
        x_choice2_lost     ,
        x_choice3_lost     ,
        x_choice4_lost     ,
        x_choice5_lost     ,
        x_choice6_lost     ,
        x_choice7_lost
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_wrong_app_id,
      x_app_no,
      x_miscoded,
      x_cancelled,
      x_cancel_date,
      x_remark,
      x_expunge,
      x_batch_id,
      x_expunged,
      x_mode,
      x_joint_admission_ind,
      x_choice1_lost     ,
      x_choice2_lost     ,
      x_choice3_lost     ,
      x_choice4_lost     ,
      x_choice5_lost     ,
      x_choice6_lost     ,
      x_choice7_lost
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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

    DELETE FROM igs_uc_wrong_app
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_wrong_app_pkg;

/
