--------------------------------------------------------
--  DDL for Package Body IGS_AD_HZ_EMP_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_HZ_EMP_DTL_PKG" AS
/* $Header: IGSAIB8B.pls 120.1 2005/06/28 04:30:42 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_hz_emp_dtl%ROWTYPE;
  new_references igs_ad_hz_emp_dtl%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hz_emp_dtl_id                     IN     NUMBER      DEFAULT NULL,
    x_employment_history_id             IN     NUMBER      DEFAULT NULL,
    x_type_of_employment                IN     VARCHAR2    DEFAULT NULL,
    x_fracion_of_employment             IN     NUMBER      DEFAULT NULL,
    x_tenure_of_employment              IN     VARCHAR2    DEFAULT NULL,
    x_occupational_title_code           IN     VARCHAR2    DEFAULT NULL,
    x_weekly_work_hours                 IN     NUMBER      DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_HZ_EMP_DTL
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
    new_references.hz_emp_dtl_id                     := x_hz_emp_dtl_id;
    new_references.employment_history_id             := x_employment_history_id;
    new_references.type_of_employment                := x_type_of_employment;
    new_references.fracion_of_employment             := x_fracion_of_employment;
    new_references.tenure_of_employment              := x_tenure_of_employment;
    new_references.occupational_title_code           := x_occupational_title_code;
    new_references.weekly_work_hours                 := x_weekly_work_hours;
    new_references.comments                          := x_comments;

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
CURSOR cur_rowid IS
         SELECT   rowid
         FROM     hz_employment_history
         WHERE    employment_history_id = new_references.employment_history_id ;
       lv_rowid cur_rowid%RowType;
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.employment_history_id = new_references.employment_history_id)) OR
        ((new_references.employment_history_id IS NULL))) THEN
      NULL;
    ELSE
    Open cur_rowid;
       Fetch cur_rowid INTO lv_rowid;
       IF (cur_rowid%NOTFOUND) THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
       END IF;
     Close cur_rowid;
    END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_hz_emp_dtl_id            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_hz_emp_dtl
      WHERE    hz_emp_dtl_id = x_hz_emp_dtl_id
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

  PROCEDURE get_fk_hz_employment_history (
    x_employment_history_id                       IN     NUMBER
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_hz_emp_dtl
      WHERE   ((employment_history_id = x_employment_history_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_employment_history;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hz_emp_dtl_id                     IN     NUMBER      DEFAULT NULL,
    x_employment_history_id             IN     NUMBER      DEFAULT NULL,
    x_type_of_employment                IN     VARCHAR2    DEFAULT NULL,
    x_fracion_of_employment             IN     NUMBER      DEFAULT NULL,
    x_tenure_of_employment              IN     VARCHAR2    DEFAULT NULL,
    x_occupational_title_code           IN     VARCHAR2    DEFAULT NULL,
    x_weekly_work_hours                 IN     NUMBER      DEFAULT NULL,
    x_comments                          IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
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
      x_hz_emp_dtl_id,
      x_employment_history_id,
      x_type_of_employment,
      x_fracion_of_employment,
      x_tenure_of_employment,
      x_occupational_title_code,
      x_weekly_work_hours,
      x_comments,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
		new_references.hz_emp_dtl_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
     -- check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
	null;
     -- Call all the procedures related to Before Delete.
     -- check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
		new_references.hz_emp_dtl_id
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
    x_hz_emp_dtl_id                     IN OUT NOCOPY NUMBER,
    x_employment_history_id             IN     NUMBER,
    x_type_of_employment                IN     VARCHAR2 DEFAULT NULL,
    x_fracion_of_employment             IN     NUMBER DEFAULT NULL,
    x_tenure_of_employment              IN     VARCHAR2 DEFAULT NULL,
    x_occupational_title_code           IN     VARCHAR2,
    x_weekly_work_hours                 IN     NUMBER DEFAULT NULL,
    x_comments                          IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_hz_emp_dtl
      WHERE   hz_emp_dtl_id	= x_hz_emp_dtl_id ;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

  BEGIN

    x_last_update_date := SYSDATE;
    IF (x_mode = 'I') THEN
      x_last_updated_by := 1;
      x_last_update_login := 0;
    ELSIF (X_MODE IN ('R', 'S')) THEN
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

    X_HZ_EMP_DTL_ID := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_hz_emp_dtl_id                     => x_hz_emp_dtl_id,
      x_employment_history_id             => x_employment_history_id,
      x_type_of_employment                => x_type_of_employment,
      x_fracion_of_employment             => x_fracion_of_employment,
      x_tenure_of_employment              => x_tenure_of_employment,
      x_occupational_title_code           => x_occupational_title_code,
      x_weekly_work_hours                 => x_weekly_work_hours,
      x_comments                          => x_comments,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_ad_hz_emp_dtl (
      hz_emp_dtl_id,
      employment_history_id,
      type_of_employment,
      fracion_of_employment,
      tenure_of_employment,
      occupational_title_code,
      weekly_work_hours,
      comments,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      IGS_AD_HZ_EMP_DTL_S.NEXTVAL,
      new_references.employment_history_id,
      new_references.type_of_employment,
      new_references.fracion_of_employment,
      new_references.tenure_of_employment,
      new_references.occupational_title_code,
      new_references.weekly_work_hours,
      new_references.comments,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    )RETURNING HZ_EMP_DTL_ID INTO X_HZ_EMP_DTL_ID;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_hz_emp_dtl_id                     IN     NUMBER,
    x_employment_history_id             IN     NUMBER,
    x_type_of_employment                IN     VARCHAR2 DEFAULT NULL,
    x_fracion_of_employment             IN     NUMBER DEFAULT NULL,
    x_tenure_of_employment              IN     VARCHAR2 DEFAULT NULL,
    x_occupational_title_code           IN     VARCHAR2,
    x_weekly_work_hours                 IN     NUMBER DEFAULT NULL,
    x_comments                          IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        hz_emp_dtl_id,
        employment_history_id,
     --   type_of_employment,
     --   fracion_of_employment,
     --   tenure_of_employment,
        occupational_title_code
     --   weekly_work_hours,
     --   comments
      FROM  igs_ad_hz_emp_dtl
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
        (tlinfo.hz_emp_dtl_id = x_hz_emp_dtl_id)
        AND (tlinfo.employment_history_id = x_employment_history_id)
        AND ((tlinfo.occupational_title_code = x_occupational_title_code) OR ((tlinfo.occupational_title_code IS NULL) AND (X_occupational_title_code IS NULL)))
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
    x_hz_emp_dtl_id                     IN     NUMBER,
    x_employment_history_id             IN     NUMBER,
    x_type_of_employment                IN     VARCHAR2 DEFAULT NULL,
    x_fracion_of_employment             IN     NUMBER DEFAULT NULL,
    x_tenure_of_employment              IN     VARCHAR2 DEFAULT NULL,
    x_occupational_title_code           IN     VARCHAR2,
    x_weekly_work_hours                 IN     NUMBER DEFAULT NULL,
    x_comments                          IN     VARCHAR2 DEFAULT NULL,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
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
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      x_hz_emp_dtl_id                     => x_hz_emp_dtl_id,
      x_employment_history_id             => x_employment_history_id,
      x_type_of_employment                => x_type_of_employment,
      x_fracion_of_employment             => x_fracion_of_employment,
      x_tenure_of_employment              => x_tenure_of_employment,
      x_occupational_title_code           => x_occupational_title_code,
      x_weekly_work_hours                 => x_weekly_work_hours,
      x_comments                          => x_comments,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_ad_hz_emp_dtl
      SET
        hz_emp_dtl_id                     = new_references.hz_emp_dtl_id,
        employment_history_id             = new_references.employment_history_id,
        type_of_employment                = new_references.type_of_employment,
        fracion_of_employment             = new_references.fracion_of_employment,
        tenure_of_employment              = new_references.tenure_of_employment,
        occupational_title_code           = new_references.occupational_title_code,
        weekly_work_hours                 = new_references.weekly_work_hours,
        comments                          = new_references.comments,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;



EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;
 END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_hz_emp_dtl_id                     IN OUT NOCOPY NUMBER,
    x_employment_history_id             IN     NUMBER,
    x_type_of_employment                IN     VARCHAR2,
    x_fracion_of_employment             IN     NUMBER,
    x_tenure_of_employment              IN     VARCHAR2,
    x_occupational_title_code           IN     VARCHAR2,
    x_weekly_work_hours                 IN     NUMBER,
    x_comments                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_hz_emp_dtl
      WHERE    hz_emp_dtl_id	= x_hz_emp_dtl_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_hz_emp_dtl_id,
        x_employment_history_id,
        x_type_of_employment,
        x_fracion_of_employment,
        x_tenure_of_employment,
        x_occupational_title_code,
        x_weekly_work_hours,
        x_comments,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_hz_emp_dtl_id,
      x_employment_history_id,
      x_type_of_employment,
      x_fracion_of_employment,
      x_tenure_of_employment,
      x_occupational_title_code,
      x_weekly_work_hours,
      x_comments,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : RAMESH.SRINIVASAN@ORACLE.COM
  ||  Created On : 29-AUG-2000
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  gmaheswa       7-Nov-2003      Bug 3223043 HZ.K Impact changes
  ||                                 commented code in the delete logic.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

  /*  before_dml (
      p_action => 'DELETE',
      x_rowid => x_rowid
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_ad_hz_emp_dtl
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

*/
  null;
  END delete_row;


END igs_ad_hz_emp_dtl_pkg;

/
