--------------------------------------------------------
--  DDL for Package Body IGS_HE_SUBMSN_RETURN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_SUBMSN_RETURN_PKG" AS
/* $Header: IGSWI11B.pls 115.8 2004/01/12 09:53:43 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_submsn_return%ROWTYPE;
  new_references igs_he_submsn_return%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_sub_rtn_id                        IN     NUMBER      ,
    x_submission_name                   IN     VARCHAR2    ,
    x_user_return_subclass              IN     VARCHAR2    ,
    x_return_name                       IN     VARCHAR2    ,
    x_lrr_start_date                    IN     DATE        ,
    x_lrr_end_date                      IN     DATE        ,
    x_record_id                         IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_SUBMSN_RETURN
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
    new_references.sub_rtn_id                        := x_sub_rtn_id;
    new_references.submission_name                   := x_submission_name;
    new_references.user_return_subclass              := x_user_return_subclass;
    new_references.return_name                       := x_return_name;
    new_references.lrr_start_date                    := x_lrr_start_date;
    new_references.lrr_end_date                      := x_lrr_end_date;
    new_references.record_id                         := x_record_id;

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
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.submission_name = new_references.submission_name)) OR
        ((new_references.submission_name IS NULL))) THEN
      NULL;
    ELSIF NOT igs_he_submsn_header_pkg.get_pk_for_validation (
                new_references.submission_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.user_return_subclass = new_references.user_return_subclass)) OR
        ((new_references.user_return_subclass IS NULL))) THEN
      NULL;
    ELSIF NOT igs_he_usr_rtn_clas_pkg.get_pk_for_validation (
                new_references.user_return_subclass
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_he_ext_run_dtls_pkg.get_fk_igs_he_submsn_return (
      old_references.submission_name,
      old_references.user_return_subclass,
      old_references.return_name
    );

    igs_he_sub_rtn_cal_pkg.get_fk_igs_he_submsn_return (
      old_references.submission_name,
      old_references.user_return_subclass,
      old_references.return_name
    );

  END check_child_existance;


PROCEDURE check_duplicate_dlhe_return AS
  /*
  ||  Created By : dsridhar
  ||  Created On : 05-MAY-2003
  ||  Purpose : Checks for the existance of DLHE returns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  || smaddali 9-jan-04 added condition to check rowid also, bug#2966258
  */
      --cursor to check for the existence of the submission return record  for 'DLHE' system return class
      CURSOR cur_check_record_exist (cp_submission_name igs_he_submsn_return.submission_name%type)
      IS
      SELECT hsr.rowid
      FROM IGS_HE_SUBMSN_RETURN hsr, IGS_HE_USR_RTN_CLAS hurc
      WHERE hsr.submission_name = cp_submission_name AND
           hsr.user_return_subclass = hurc.user_return_subclass AND
           hurc.system_return_class_type = 'DLHE' ;
      --variable to find if the submission record exists
      l_check_record_exist cur_check_record_exist%ROWTYPE;

      --cursor to obtain the system return class type based on the user return type
      CURSOR cur_system_return_class (cp_user_return_class igs_he_submsn_return.user_return_subclass%type)
      IS
      SELECT hsr.system_return_class_type
      FROM IGS_HE_USR_RTN_CLAS hsr
      WHERE  hsr.user_return_subclass = cp_user_return_class;
      --variable to find if the submission record exists
      l_sys_return_subclass igs_he_usr_rtn_clas.system_return_class_type%TYPE;

   BEGIN
        OPEN cur_system_return_class(new_references.user_return_subclass);
	FETCH cur_system_return_class INTO l_sys_return_subclass;
        CLOSE cur_system_return_class;

	IF l_sys_return_subclass = 'DLHE' THEN
           OPEN cur_check_record_exist(new_references.submission_name);
           FETCH cur_check_record_exist into l_check_record_exist;
           -- smaddali added condition to compare rowid because it is throwing
           -- this error if the same dlhe record is updated, bug#2966258
           IF cur_check_record_exist%FOUND AND
              (l_rowid IS NULL OR l_check_record_exist.rowid <> l_rowid)  THEN
               CLOSE cur_check_record_exist;
               fnd_message.set_name('IGS','IGS_HE_DLHE_SUBRTN_EXIST');
       	       igs_ge_msg_stack.add;
     	       app_exception.raise_exception;
	   END IF ;
	   CLOSE cur_check_record_exist;
        END IF;

  END check_duplicate_dlhe_return;

  FUNCTION get_pk_for_validation (
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_submsn_return
      WHERE    submission_name = x_submission_name
      AND      user_return_subclass = x_user_return_subclass
      AND      return_name = x_return_name
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


  PROCEDURE get_fk_igs_he_submsn_header (
    x_submission_name                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_submsn_return
      WHERE   ((submission_name = x_submission_name));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HESBRET_HESBHDR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_he_submsn_header;


  PROCEDURE get_fk_igs_he_usr_rtn_clas (
    x_user_return_subclass              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_submsn_return
      WHERE   ((user_return_subclass = x_user_return_subclass));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HESBRET_HEURCD_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_he_usr_rtn_clas;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_sub_rtn_id                        IN     NUMBER      ,
    x_submission_name                   IN     VARCHAR2    ,
    x_user_return_subclass              IN     VARCHAR2    ,
    x_return_name                       IN     VARCHAR2    ,
    x_lrr_start_date                    IN     DATE        ,
    x_lrr_end_date                      IN     DATE        ,
    x_record_id                         IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
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
      x_sub_rtn_id,
      x_submission_name,
      x_user_return_subclass,
      x_return_name,
      x_lrr_start_date,
      x_lrr_end_date,
      x_record_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.submission_name,
             new_references.user_return_subclass,
             new_references.return_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
      check_duplicate_dlhe_return;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
      check_duplicate_dlhe_return;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.submission_name,
             new_references.user_return_subclass,
             new_references.return_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_duplicate_dlhe_return;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sub_rtn_id                        IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_lrr_start_date                    IN     DATE,
    x_lrr_end_date                      IN     DATE,
    x_record_id                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_submsn_return
      WHERE    submission_name                   = x_submission_name
      AND      user_return_subclass              = x_user_return_subclass
      AND      return_name                       = x_return_name;

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

    SELECT    igs_he_submsn_return_s.NEXTVAL
    INTO      x_sub_rtn_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sub_rtn_id                        => x_sub_rtn_id,
      x_submission_name                   => x_submission_name,
      x_user_return_subclass              => x_user_return_subclass,
      x_return_name                       => x_return_name,
      x_lrr_start_date                    => x_lrr_start_date,
      x_lrr_end_date                      => x_lrr_end_date,
      x_record_id                         => x_record_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_submsn_return (
      sub_rtn_id,
      submission_name,
      user_return_subclass,
      return_name,
      lrr_start_date,
      lrr_end_date,
      record_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.sub_rtn_id,
      new_references.submission_name,
      new_references.user_return_subclass,
      new_references.return_name,
      new_references.lrr_start_date,
      new_references.lrr_end_date,
      new_references.record_id,
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
    x_sub_rtn_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_lrr_start_date                    IN     DATE,
    x_lrr_end_date                      IN     DATE,
    x_record_id                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        sub_rtn_id,
        lrr_start_date,
        lrr_end_date,
        record_id
      FROM  igs_he_submsn_return
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
        (tlinfo.sub_rtn_id = x_sub_rtn_id)
        AND ((tlinfo.lrr_start_date = x_lrr_start_date) OR ((tlinfo.lrr_start_date IS NULL) AND (X_lrr_start_date IS NULL)))
        AND ((tlinfo.lrr_end_date = x_lrr_end_date) OR ((tlinfo.lrr_end_date IS NULL) AND (X_lrr_end_date IS NULL)))
        AND (tlinfo.record_id = x_record_id)
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
    x_sub_rtn_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_lrr_start_date                    IN     DATE,
    x_lrr_end_date                      IN     DATE,
    x_record_id                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
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
      x_sub_rtn_id                        => x_sub_rtn_id,
      x_submission_name                   => x_submission_name,
      x_user_return_subclass              => x_user_return_subclass,
      x_return_name                       => x_return_name,
      x_lrr_start_date                    => x_lrr_start_date,
      x_lrr_end_date                      => x_lrr_end_date,
      x_record_id                         => x_record_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_submsn_return
      SET
        sub_rtn_id                        = new_references.sub_rtn_id,
        lrr_start_date                    = new_references.lrr_start_date,
        lrr_end_date                      = new_references.lrr_end_date,
        record_id                         = new_references.record_id,
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
    x_sub_rtn_id                        IN OUT NOCOPY NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_lrr_start_date                    IN     DATE,
    x_lrr_end_date                      IN     DATE,
    x_record_id                         IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_submsn_return
      WHERE    submission_name                   = x_submission_name
      AND      user_return_subclass              = x_user_return_subclass
      AND      return_name                       = x_return_name;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sub_rtn_id,
        x_submission_name,
        x_user_return_subclass,
        x_return_name,
        x_lrr_start_date,
        x_lrr_end_date,
        x_record_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sub_rtn_id,
      x_submission_name,
      x_user_return_subclass,
      x_return_name,
      x_lrr_start_date,
      x_lrr_end_date,
      x_record_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 04-JUL-2001
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

    DELETE FROM igs_he_submsn_return
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_submsn_return_pkg;

/
