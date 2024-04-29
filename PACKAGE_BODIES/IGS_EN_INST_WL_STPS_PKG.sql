--------------------------------------------------------
--  DDL for Package Body IGS_EN_INST_WL_STPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_INST_WL_STPS_PKG" AS
/* $Header: IGSEI71B.pls 115.1 2003/09/18 03:47:45 svanukur noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_inst_wl_stps%ROWTYPE;
  new_references igs_en_inst_wl_stps%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_inst_wlst_setup_id                IN     NUMBER,
    x_waitlist_allowed_flag             IN     VARCHAR2,
    x_time_confl_alwd_wlst_flag         IN     VARCHAR2,
    x_simultaneous_wlst_alwd_flag       IN     VARCHAR2,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2,
    x_include_waitlist_cp_flag          IN     VARCHAR2,
    x_max_waitlists_student_num         IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Svanukur
  ||  Created On : 26-AUG-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_inst_wl_stps
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
    new_references.inst_wlst_setup_id                := x_inst_wlst_setup_id;
    new_references.waitlist_allowed_flag             := x_waitlist_allowed_flag;
    new_references.time_confl_alwd_wlst_flag    := x_time_confl_alwd_wlst_flag;
    new_references.simultaneous_wlst_alwd_flag    := x_simultaneous_wlst_alwd_flag;
    new_references.auto_enroll_waitlist_flag         := x_auto_enroll_waitlist_flag;
    new_references.include_waitlist_cp_flag          := x_include_waitlist_cp_flag;
    new_references.max_waitlists_student_num         := x_max_waitlists_student_num;

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

FUNCTION Get_PK_For_Validation (
     x_inst_wlst_setup_id IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_INST_WL_STPS
      WHERE    inst_wlst_setup_id =  x_inst_wlst_setup_id
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
	return(TRUE);
    else
	Close cur_rowid;
      Return(FALSE);
    END IF;
  END Get_PK_For_Validation;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_inst_wlst_setup_id                IN     NUMBER,
    x_waitlist_allowed_flag             IN     VARCHAR2,
    x_time_confl_alwd_wlst_flag    IN     VARCHAR2,
    x_simultaneous_wlst_alwd_flag    IN     VARCHAR2,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2,
    x_include_waitlist_cp_flag          IN     VARCHAR2,
    x_max_waitlists_student_num         IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Svanukur
  ||  Created On : 26-AUG-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
 CURSOR cur_no_recs IS
 SELECT count(ROWID)
 FROM IGS_EN_INST_WL_STPS;

 v_no_recs NUMBER(1);
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_inst_wlst_setup_id,
      x_waitlist_allowed_flag,
      x_time_confl_alwd_wlst_flag,
      x_simultaneous_wlst_alwd_flag,
      x_auto_enroll_waitlist_flag,
      x_include_waitlist_cp_flag,
      x_max_waitlists_student_num,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
       OPEN cur_no_recs;
       FETCH cur_no_recs INTO v_no_recs;
       CLOSE cur_no_recs;

       IF v_no_recs >1 THEN
           fnd_message.set_name ('FND', 'IGS_EN_WLST_ONLY_ONE_REC');
           igs_ge_msg_stack.add;
           app_exception.raise_exception;
       END IF;
      IF  get_pk_for_validation(new_references.inst_wlst_setup_id ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF get_pk_for_validation (new_references.inst_wlst_setup_id )
          THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

    IF p_action IN ('VALIDATE_INSERT', 'VALIDATE_UPDATE', 'VALIDATE_DELETE') THEN
      l_rowid := NULL;
    END IF;

  END before_dml;

 PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : svanukur
  Date Created on : 29-AUG-2003
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst_wlst_setup_id                IN OUT NOCOPY   NUMBER,
    x_waitlist_allowed_flag             IN     VARCHAR2,
    x_time_confl_alwd_wlst_flag    IN     VARCHAR2,
    x_simultaneous_wlst_alwd_flag    IN     VARCHAR2,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2,
    x_include_waitlist_cp_flag          IN     VARCHAR2,
    x_max_waitlists_student_num         IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Svanukur
  ||  Created On : 26-AUG-2003
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_INST_WL_STPS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_inst_wlst_setup_id                => x_inst_wlst_setup_id,
      x_waitlist_allowed_flag             => x_waitlist_allowed_flag,
      x_time_confl_alwd_wlst_flag    => x_time_confl_alwd_wlst_flag,
      x_simultaneous_wlst_alwd_flag    => x_simultaneous_wlst_alwd_flag,
      x_auto_enroll_waitlist_flag         => x_auto_enroll_waitlist_flag,
      x_include_waitlist_cp_flag          => x_include_waitlist_cp_flag,
      x_max_waitlists_student_num         => x_max_waitlists_student_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );


    INSERT INTO igs_en_inst_wl_stps (
      inst_wlst_setup_id,
      waitlist_allowed_flag,
      time_confl_alwd_wlst_flag,
      simultaneous_wlst_alwd_flag,
      auto_enroll_waitlist_flag,
      include_waitlist_cp_flag,
      max_waitlists_student_num,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      1,
      new_references.waitlist_allowed_flag,
      new_references.time_confl_alwd_wlst_flag,
      new_references.simultaneous_wlst_alwd_flag,
      new_references.auto_enroll_waitlist_flag,
      new_references.include_waitlist_cp_flag,
      new_references.max_waitlists_student_num,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, inst_wlst_setup_id INTO x_rowid,x_inst_wlst_setup_id;

    l_rowid := NULL;

After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_inst_wlst_setup_id                IN     NUMBER,
    x_waitlist_allowed_flag             IN     VARCHAR2,
    x_time_confl_alwd_wlst_flag    IN     VARCHAR2,
    x_simultaneous_wlst_alwd_flag    IN     VARCHAR2,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2,
    x_include_waitlist_cp_flag          IN     VARCHAR2,
    x_max_waitlists_student_num         IN     NUMBER
  ) AS
  /*
  ||  Created By : Svanukur
  ||  Created On : 26-AUG-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        inst_wlst_setup_id,
        waitlist_allowed_flag,
        time_confl_alwd_wlst_flag,
        simultaneous_wlst_alwd_flag,
        auto_enroll_waitlist_flag,
        include_waitlist_cp_flag,
        max_waitlists_student_num
      FROM  igs_en_inst_wl_stps
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
        (tlinfo.inst_wlst_setup_id = x_inst_wlst_setup_id)
        AND (tlinfo.waitlist_allowed_flag = x_waitlist_allowed_flag)
        AND (tlinfo.time_confl_alwd_wlst_flag = x_time_confl_alwd_wlst_flag)
        AND (tlinfo.simultaneous_wlst_alwd_flag = x_simultaneous_wlst_alwd_flag)
        AND (tlinfo.auto_enroll_waitlist_flag = x_auto_enroll_waitlist_flag)
        AND (tlinfo.include_waitlist_cp_flag = x_include_waitlist_cp_flag)
        AND ((tlinfo.max_waitlists_student_num = x_max_waitlists_student_num) OR ((tlinfo.max_waitlists_student_num IS NULL) AND (X_max_waitlists_student_num IS NULL)))
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
    x_inst_wlst_setup_id                IN     NUMBER,
    x_waitlist_allowed_flag             IN     VARCHAR2,
    x_time_confl_alwd_wlst_flag         IN     VARCHAR2,
    x_simultaneous_wlst_alwd_flag       IN     VARCHAR2,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2,
    x_include_waitlist_cp_flag          IN     VARCHAR2,
    x_max_waitlists_student_num         IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Svanukur
  ||  Created On : 26-AUG-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_INST_WL_STPS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_inst_wlst_setup_id                => x_inst_wlst_setup_id,
      x_waitlist_allowed_flag             => x_waitlist_allowed_flag,
      x_time_confl_alwd_wlst_flag    => x_time_confl_alwd_wlst_flag,
      x_simultaneous_wlst_alwd_flag    => x_simultaneous_wlst_alwd_flag,
      x_auto_enroll_waitlist_flag         => x_auto_enroll_waitlist_flag,
      x_include_waitlist_cp_flag          => x_include_waitlist_cp_flag,
      x_max_waitlists_student_num         => x_max_waitlists_student_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_en_inst_wl_stps
      SET
        waitlist_allowed_flag             = new_references.waitlist_allowed_flag,
        time_confl_alwd_wlst_flag    = new_references.time_confl_alwd_wlst_flag,
        simultaneous_wlst_alwd_flag    = new_references.simultaneous_wlst_alwd_flag,
        auto_enroll_waitlist_flag         = new_references.auto_enroll_waitlist_flag,
        include_waitlist_cp_flag          = new_references.include_waitlist_cp_flag,
        max_waitlists_student_num         = new_references.max_waitlists_student_num,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst_wlst_setup_id                IN OUT NOCOPY   NUMBER,
    x_waitlist_allowed_flag             IN     VARCHAR2,
    x_time_confl_alwd_wlst_flag         IN     VARCHAR2,
    x_simultaneous_wlst_alwd_flag       IN     VARCHAR2,
    x_auto_enroll_waitlist_flag         IN     VARCHAR2,
    x_include_waitlist_cp_flag          IN     VARCHAR2,
    x_max_waitlists_student_num         IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Svanukur
  ||  Created On : 26-AUG-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_inst_wl_stps
      WHERE    inst_wlst_setup_id= x_inst_wlst_setup_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_inst_wlst_setup_id,
        x_waitlist_allowed_flag,
        x_time_confl_alwd_wlst_flag,
        x_simultaneous_wlst_alwd_flag,
        x_auto_enroll_waitlist_flag,
        x_include_waitlist_cp_flag,
        x_max_waitlists_student_num,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_inst_wlst_setup_id,
      x_waitlist_allowed_flag,
      x_time_confl_alwd_wlst_flag,
      x_simultaneous_wlst_alwd_flag,
      x_auto_enroll_waitlist_flag,
      x_include_waitlist_cp_flag,
      x_max_waitlists_student_num,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Svanukur
  ||  Created On : 26-AUG-2003
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

    DELETE FROM igs_en_inst_wl_stps
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END delete_row;


END igs_en_inst_wl_stps_pkg;

/
