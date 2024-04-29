--------------------------------------------------------
--  DDL for Package Body IGS_EN_SPL_PERM_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SPL_PERM_H_PKG" AS
/* $Header: IGSEI54B.pls 115.4 2002/11/28 23:45:56 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_spl_perm_h%ROWTYPE;
  new_references igs_en_spl_perm_h%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_spl_perm_request_h_id             IN     NUMBER      DEFAULT NULL,
    x_spl_perm_request_id               IN     NUMBER      DEFAULT NULL,
    x_date_submission                   IN     DATE        DEFAULT NULL,
    x_audit_the_course                  IN     VARCHAR2    DEFAULT NULL,
    x_approval_status                   IN     VARCHAR2    DEFAULT NULL,
    x_reason_for_request                IN     VARCHAR2    DEFAULT NULL,
    x_instructor_more_info              IN     VARCHAR2    DEFAULT NULL,
    x_instructor_deny_info              IN     VARCHAR2    DEFAULT NULL,
    x_student_more_info                 IN     VARCHAR2    DEFAULT NULL,
    x_transaction_type                  IN     VARCHAR2    DEFAULT NULL,
    x_hist_start_dt                     IN     DATE        DEFAULT NULL,
    x_hist_end_dt                       IN     DATE        DEFAULT NULL,
    x_hist_who                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_SPL_PERM_H
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
    new_references.spl_perm_request_h_id             := x_spl_perm_request_h_id;
    new_references.spl_perm_request_id               := x_spl_perm_request_id;
    new_references.date_submission                   := x_date_submission;
    new_references.audit_the_course                  := x_audit_the_course;
    new_references.approval_status                   := x_approval_status;
    new_references.reason_for_request                := x_reason_for_request;
    new_references.instructor_more_info              := x_instructor_more_info;
    new_references.instructor_deny_info              := x_instructor_deny_info;
    new_references.student_more_info                 := x_student_more_info;
    new_references.transaction_type                  := x_transaction_type;
    new_references.hist_start_dt                     := x_hist_start_dt;
    new_references.hist_end_dt                       := x_hist_end_dt;
    new_references.hist_who                          := x_hist_who;

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


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.spl_perm_request_id = new_references.spl_perm_request_id)) OR
        ((new_references.spl_perm_request_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_spl_perm_pkg.get_pk_for_validation (
                new_references.spl_perm_request_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

   IF (((old_references.transaction_type =
           new_references.transaction_type)) OR
        ((new_references.transaction_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation ('SPL_PERM_TRANSCTION_TYPE',
         new_references.transaction_type) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception;
      END IF;
    END IF;


  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_spl_perm_request_h_id             IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spl_perm_h
      WHERE    spl_perm_request_h_id = x_spl_perm_request_h_id
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


  PROCEDURE get_fk_igs_en_spl_perm (
    x_spl_perm_request_id               IN     NUMBER
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_spl_perm_h
      WHERE   ((spl_perm_request_id = x_spl_perm_request_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_SPH_SPLP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_en_spl_perm;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_spl_perm_request_h_id             IN     NUMBER      DEFAULT NULL,
    x_spl_perm_request_id               IN     NUMBER      DEFAULT NULL,
    x_date_submission                   IN     DATE        DEFAULT NULL,
    x_audit_the_course                  IN     VARCHAR2    DEFAULT NULL,
    x_approval_status                   IN     VARCHAR2    DEFAULT NULL,
    x_reason_for_request                IN     VARCHAR2    DEFAULT NULL,
    x_instructor_more_info              IN     VARCHAR2    DEFAULT NULL,
    x_instructor_deny_info              IN     VARCHAR2    DEFAULT NULL,
    x_student_more_info                 IN     VARCHAR2    DEFAULT NULL,
    x_transaction_type                  IN     VARCHAR2    DEFAULT NULL,
    x_hist_start_dt                     IN     DATE        DEFAULT NULL,
    x_hist_end_dt                       IN     DATE        DEFAULT NULL,
    x_hist_who                          IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
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
      x_spl_perm_request_h_id,
      x_spl_perm_request_id,
      x_date_submission,
      x_audit_the_course,
      x_approval_status,
      x_reason_for_request,
      x_instructor_more_info,
      x_instructor_deny_info,
      x_student_more_info,
      x_transaction_type,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.spl_perm_request_h_id
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.spl_perm_request_h_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_spl_perm_request_h_id             IN OUT NOCOPY NUMBER,
    x_spl_perm_request_id               IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_en_spl_perm_h
      WHERE    spl_perm_request_h_id             = x_spl_perm_request_h_id;

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

    SELECT    igs_en_spl_perm_h_s.NEXTVAL
    INTO      x_spl_perm_request_h_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_spl_perm_request_h_id             => x_spl_perm_request_h_id,
      x_spl_perm_request_id               => x_spl_perm_request_id,
      x_date_submission                   => x_date_submission,
      x_audit_the_course                  => x_audit_the_course,
      x_approval_status                   => x_approval_status,
      x_reason_for_request                => x_reason_for_request,
      x_instructor_more_info              => x_instructor_more_info,
      x_instructor_deny_info              => x_instructor_deny_info,
      x_student_more_info                 => x_student_more_info,
      x_transaction_type                  => x_transaction_type,
      x_hist_start_dt                     => x_hist_start_dt,
      x_hist_end_dt                       => x_hist_end_dt,
      x_hist_who                          => x_hist_who,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_spl_perm_h (
      spl_perm_request_h_id,
      spl_perm_request_id,
      date_submission,
      audit_the_course,
      approval_status,
      reason_for_request,
      instructor_more_info,
      instructor_deny_info,
      student_more_info,
      transaction_type,
      hist_start_dt,
      hist_end_dt,
      hist_who,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.spl_perm_request_h_id,
      new_references.spl_perm_request_id,
      new_references.date_submission,
      new_references.audit_the_course,
      new_references.approval_status,
      new_references.reason_for_request,
      new_references.instructor_more_info,
      new_references.instructor_deny_info,
      new_references.student_more_info,
      new_references.transaction_type,
      new_references.hist_start_dt,
      new_references.hist_end_dt,
      new_references.hist_who,
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

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_spl_perm_request_h_id             IN     NUMBER,
    x_spl_perm_request_id               IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        spl_perm_request_id,
        date_submission,
        audit_the_course,
        approval_status,
        reason_for_request,
        instructor_more_info,
        instructor_deny_info,
        student_more_info,
        transaction_type,
        hist_start_dt,
        hist_end_dt,
        hist_who
      FROM  igs_en_spl_perm_h
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
        (tlinfo.spl_perm_request_id = x_spl_perm_request_id)
        AND (tlinfo.date_submission = x_date_submission)
        AND ((tlinfo.audit_the_course = x_audit_the_course) OR ((tlinfo.audit_the_course IS NULL) AND (X_audit_the_course IS NULL)))
        AND (tlinfo.approval_status = x_approval_status)
        AND (tlinfo.reason_for_request = x_reason_for_request)
        AND ((tlinfo.instructor_more_info = x_instructor_more_info) OR ((tlinfo.instructor_more_info IS NULL) AND (X_instructor_more_info IS NULL)))
        AND ((tlinfo.instructor_deny_info = x_instructor_deny_info) OR ((tlinfo.instructor_deny_info IS NULL) AND (X_instructor_deny_info IS NULL)))
        AND ((tlinfo.student_more_info = x_student_more_info) OR ((tlinfo.student_more_info IS NULL) AND (X_student_more_info IS NULL)))
        AND ((tlinfo.transaction_type = x_transaction_type) OR ((tlinfo.transaction_type IS NULL) AND (X_transaction_type IS NULL)))
        AND (tlinfo.hist_start_dt = x_hist_start_dt)
        AND (tlinfo.hist_end_dt = x_hist_end_dt)
        AND (tlinfo.hist_who = x_hist_who)
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
    x_spl_perm_request_h_id             IN     NUMBER,
    x_spl_perm_request_id               IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
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
      x_spl_perm_request_h_id             => x_spl_perm_request_h_id,
      x_spl_perm_request_id               => x_spl_perm_request_id,
      x_date_submission                   => x_date_submission,
      x_audit_the_course                  => x_audit_the_course,
      x_approval_status                   => x_approval_status,
      x_reason_for_request                => x_reason_for_request,
      x_instructor_more_info              => x_instructor_more_info,
      x_instructor_deny_info              => x_instructor_deny_info,
      x_student_more_info                 => x_student_more_info,
      x_transaction_type                  => x_transaction_type,
      x_hist_start_dt                     => x_hist_start_dt,
      x_hist_end_dt                       => x_hist_end_dt,
      x_hist_who                          => x_hist_who,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_spl_perm_h
      SET
        spl_perm_request_id               = new_references.spl_perm_request_id,
        date_submission                   = new_references.date_submission,
        audit_the_course                  = new_references.audit_the_course,
        approval_status                   = new_references.approval_status,
        reason_for_request                = new_references.reason_for_request,
        instructor_more_info              = new_references.instructor_more_info,
        instructor_deny_info              = new_references.instructor_deny_info,
        student_more_info                 = new_references.student_more_info,
        transaction_type                  = new_references.transaction_type,
        hist_start_dt                     = new_references.hist_start_dt,
        hist_end_dt                       = new_references.hist_end_dt,
        hist_who                          = new_references.hist_who,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_spl_perm_request_h_id             IN OUT NOCOPY NUMBER,
    x_spl_perm_request_id               IN     NUMBER,
    x_date_submission                   IN     DATE,
    x_audit_the_course                  IN     VARCHAR2,
    x_approval_status                   IN     VARCHAR2,
    x_reason_for_request                IN     VARCHAR2,
    x_instructor_more_info              IN     VARCHAR2,
    x_instructor_deny_info              IN     VARCHAR2,
    x_student_more_info                 IN     VARCHAR2,
    x_transaction_type                  IN     VARCHAR2,
    x_hist_start_dt                     IN     DATE,
    x_hist_end_dt                       IN     DATE,
    x_hist_who                          IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_spl_perm_h
      WHERE    spl_perm_request_h_id             = x_spl_perm_request_h_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_spl_perm_request_h_id,
        x_spl_perm_request_id,
        x_date_submission,
        x_audit_the_course,
        x_approval_status,
        x_reason_for_request,
        x_instructor_more_info,
        x_instructor_deny_info,
        x_student_more_info,
        x_transaction_type,
        x_hist_start_dt,
        x_hist_end_dt,
        x_hist_who,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_spl_perm_request_h_id,
      x_spl_perm_request_id,
      x_date_submission,
      x_audit_the_course,
      x_approval_status,
      x_reason_for_request,
      x_instructor_more_info,
      x_instructor_deny_info,
      x_student_more_info,
      x_transaction_type,
      x_hist_start_dt,
      x_hist_end_dt,
      x_hist_who,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : pradhakr
  ||  Created On : 29-JUN-2001
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

    DELETE FROM igs_en_spl_perm_h
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_spl_perm_h_pkg;

/
