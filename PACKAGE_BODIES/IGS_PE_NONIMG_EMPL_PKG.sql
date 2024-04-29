--------------------------------------------------------
--  DDL for Package Body IGS_PE_NONIMG_EMPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_NONIMG_EMPL_PKG" AS
/* $Header: IGSNIA8B.pls 120.2 2006/02/17 06:57:01 gmaheswa ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_nonimg_empl%ROWTYPE;
  new_references igs_pe_nonimg_empl%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_nonimg_empl_id                    IN     NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_empl_type                         IN     VARCHAR2,
    x_recommend_empl                    IN     VARCHAR2,
    x_rescind_empl                      IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_empl_start_date                   IN     DATE,
    x_empl_end_date                     IN     DATE,
    x_course_relevance                  IN     VARCHAR2,
    x_empl_time                         IN     VARCHAR2,
    x_empl_party_id                     IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER ,
    x_action_code			IN     VARCHAR2,
    x_print_flag			IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_nonimg_empl
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
    new_references.nonimg_empl_id                    := x_nonimg_empl_id;
    new_references.nonimg_form_id                    := x_nonimg_form_id;
    new_references.empl_type                         := x_empl_type;
    new_references.recommend_empl                    := x_recommend_empl;
    new_references.rescind_empl                      := x_rescind_empl;
    new_references.remarks                           := x_remarks;
    new_references.empl_start_date                   := x_empl_start_date;
    new_references.empl_end_date                     := x_empl_end_date;
    new_references.course_relevance                  := x_course_relevance;
    new_references.empl_time                         := x_empl_time;
    new_references.empl_party_id                     := x_empl_party_id;

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
    new_references.action_code			     := x_action_code;
    new_references.print_flag			     := x_print_flag;
  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.nonimg_form_id = new_references.nonimg_form_id)) OR
        ((new_references.nonimg_form_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_nonimg_form_pkg.get_pk_for_validation ( new_references.nonimg_form_id ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation ( x_nonimg_empl_id    IN     NUMBER   ) RETURN BOOLEAN AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_nonimg_empl
      WHERE    nonimg_empl_id = x_nonimg_empl_id
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


  PROCEDURE get_fk_igs_pe_nonimg_form (
    x_nonimg_form_id                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_nonimg_empl
      WHERE   ((nonimg_form_id = x_nonimg_form_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_PENEM_PENIF_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_nonimg_form;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_nonimg_empl_id                    IN     NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_empl_type                         IN     VARCHAR2,
    x_recommend_empl                    IN     VARCHAR2,
    x_rescind_empl                      IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_empl_start_date                   IN     DATE,
    x_empl_end_date                     IN     DATE,
    x_course_relevance                  IN     VARCHAR2,
    x_empl_time                         IN     VARCHAR2,
    x_empl_party_id                     IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_action_code			IN     VARCHAR2,
    x_print_flag			IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
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
      x_nonimg_empl_id,
      x_nonimg_form_id,
      x_empl_type,
      x_recommend_empl,
      x_rescind_empl,
      x_remarks,
      x_empl_start_date,
      x_empl_end_date,
      x_course_relevance,
      x_empl_time,
      x_empl_party_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_action_code,
      x_print_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation( new_references.nonimg_empl_id ) ) THEN
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
      IF ( get_pk_for_validation ( new_references.nonimg_empl_id ) ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_nonimg_empl_id                    IN OUT NOCOPY NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_empl_type                         IN     VARCHAR2,
    x_recommend_empl                    IN     VARCHAR2,
    x_rescind_empl                      IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_empl_start_date                   IN     DATE,
    x_empl_end_date                     IN     DATE,
    x_course_relevance                  IN     VARCHAR2,
    x_empl_time                         IN     VARCHAR2,
    x_empl_party_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_action_code			IN     VARCHAR2,
    x_print_flag			IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
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

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_nonimg_empl_id                    => x_nonimg_empl_id,
      x_nonimg_form_id                    => x_nonimg_form_id,
      x_empl_type                         => x_empl_type,
      x_recommend_empl                    => x_recommend_empl,
      x_rescind_empl                      => x_rescind_empl,
      x_remarks                           => x_remarks,
      x_empl_start_date                   => x_empl_start_date,
      x_empl_end_date                     => x_empl_end_date,
      x_course_relevance                  => x_course_relevance,
      x_empl_time                         => x_empl_time,
      x_empl_party_id                     => x_empl_party_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_action_code			  => x_action_code,
      x_print_flag			  => x_print_flag
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_nonimg_empl (
      nonimg_empl_id,
      nonimg_form_id,
      empl_type,
      recommend_empl,
      rescind_empl,
      remarks,
      empl_start_date,
      empl_end_date,
      course_relevance,
      empl_time,
      empl_party_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      action_code,
      print_flag
    ) VALUES (
      igs_pe_nonimg_empl_s.NEXTVAL,
      new_references.nonimg_form_id,
      new_references.empl_type,
      new_references.recommend_empl,
      new_references.rescind_empl,
      new_references.remarks,
      new_references.empl_start_date,
      new_references.empl_end_date,
      new_references.course_relevance,
      new_references.empl_time,
      new_references.empl_party_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.action_code,
      new_references.print_flag
    ) RETURNING ROWID, nonimg_empl_id INTO x_rowid, x_nonimg_empl_id;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;



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
    x_nonimg_empl_id                    IN     NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_empl_type                         IN     VARCHAR2,
    x_recommend_empl                    IN     VARCHAR2,
    x_rescind_empl                      IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_empl_start_date                   IN     DATE,
    x_empl_end_date                     IN     DATE,
    x_course_relevance                  IN     VARCHAR2,
    x_empl_time                         IN     VARCHAR2,
    x_empl_party_id                     IN     NUMBER,
    x_action_code			IN     VARCHAR2,
    x_print_flag			IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        nonimg_form_id,
        empl_type,
        recommend_empl,
        rescind_empl,
        remarks,
        empl_start_date,
        empl_end_date,
        course_relevance,
        empl_time,
        empl_party_id,
	action_code,
	print_flag
      FROM  igs_pe_nonimg_empl
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
        (tlinfo.nonimg_form_id = x_nonimg_form_id)
        AND (tlinfo.empl_type = x_empl_type)
        AND ((tlinfo.recommend_empl = x_recommend_empl) OR ((tlinfo.recommend_empl IS NULL) AND (X_recommend_empl IS NULL)))
        AND ((tlinfo.rescind_empl = x_rescind_empl) OR ((tlinfo.rescind_empl IS NULL) AND (X_rescind_empl IS NULL)))
        AND ((tlinfo.remarks = x_remarks) OR ((tlinfo.remarks IS NULL) AND (X_remarks IS NULL)))
        AND ((tlinfo.empl_start_date = x_empl_start_date) OR ((tlinfo.empl_start_date IS NULL) AND (X_empl_start_date IS NULL)))
        AND ((tlinfo.empl_end_date = x_empl_end_date) OR ((tlinfo.empl_end_date IS NULL) AND (X_empl_end_date IS NULL)))
        AND ((tlinfo.course_relevance = x_course_relevance) OR ((tlinfo.course_relevance IS NULL) AND (X_course_relevance IS NULL)))
        AND ((tlinfo.empl_time = x_empl_time) OR ((tlinfo.empl_time IS NULL) AND (X_empl_time IS NULL)))
        AND ((tlinfo.empl_party_id = x_empl_party_id) OR ((tlinfo.empl_party_id IS NULL) AND (X_empl_party_id IS NULL)))
        AND ((tlinfo.action_code = x_action_code) OR ((tlinfo.action_code IS NULL) AND (X_action_code IS NULL)))
	--AND ((tlinfo.print_flag = x_print_flag) OR ((tlinfo.print_flag IS NULL) AND (X_print_flag IS NULL)))  uncomment
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
    x_nonimg_empl_id                    IN     NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_empl_type                         IN     VARCHAR2,
    x_recommend_empl                    IN     VARCHAR2,
    x_rescind_empl                      IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_empl_start_date                   IN     DATE,
    x_empl_end_date                     IN     DATE,
    x_course_relevance                  IN     VARCHAR2,
    x_empl_time                         IN     VARCHAR2,
    x_empl_party_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2 ,
    x_action_code			IN     VARCHAR2,
    x_print_flag			IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
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
      x_nonimg_empl_id                    => x_nonimg_empl_id,
      x_nonimg_form_id                    => x_nonimg_form_id,
      x_empl_type                         => x_empl_type,
      x_recommend_empl                    => x_recommend_empl,
      x_rescind_empl                      => x_rescind_empl,
      x_remarks                           => x_remarks,
      x_empl_start_date                   => x_empl_start_date,
      x_empl_end_date                     => x_empl_end_date,
      x_course_relevance                  => x_course_relevance,
      x_empl_time                         => x_empl_time,
      x_empl_party_id                     => x_empl_party_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_action_code			  => x_action_code,
      x_print_flag			  => x_print_flag
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_nonimg_empl
      SET
        nonimg_form_id                    = new_references.nonimg_form_id,
        empl_type                         = new_references.empl_type,
        recommend_empl                    = new_references.recommend_empl,
        rescind_empl                      = new_references.rescind_empl,
        remarks                           = new_references.remarks,
        empl_start_date                   = new_references.empl_start_date,
        empl_end_date                     = new_references.empl_end_date,
        course_relevance                  = new_references.course_relevance,
        empl_time                         = new_references.empl_time,
        empl_party_id                     = new_references.empl_party_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
	action_code			  = x_action_code,
	print_flag			  = x_print_flag
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
    x_nonimg_empl_id                    IN OUT NOCOPY NUMBER,
    x_nonimg_form_id                    IN     NUMBER,
    x_empl_type                         IN     VARCHAR2,
    x_recommend_empl                    IN     VARCHAR2,
    x_rescind_empl                      IN     VARCHAR2,
    x_remarks                           IN     VARCHAR2,
    x_empl_start_date                   IN     DATE,
    x_empl_end_date                     IN     DATE,
    x_course_relevance                  IN     VARCHAR2,
    x_empl_time                         IN     VARCHAR2,
    x_empl_party_id                     IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_action_code			IN     VARCHAR2,
    x_print_flag			IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_nonimg_empl
      WHERE    nonimg_empl_id                    = x_nonimg_empl_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_nonimg_empl_id,
        x_nonimg_form_id,
        x_empl_type,
        x_recommend_empl,
        x_rescind_empl,
        x_remarks,
        x_empl_start_date,
        x_empl_end_date,
        x_course_relevance,
        x_empl_time,
        x_empl_party_id,
        x_mode ,
	x_action_code,
	x_print_flag
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_nonimg_empl_id,
      x_nonimg_form_id,
      x_empl_type,
      x_recommend_empl,
      x_rescind_empl,
      x_remarks,
      x_empl_start_date,
      x_empl_end_date,
      x_course_relevance,
      x_empl_time,
      x_empl_party_id,
      x_mode ,
      x_action_code,
      x_print_flag
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : Simran.Sawhney@oracle.com
  ||  Created On : 28-NOV-2002
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

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 DELETE FROM igs_pe_nonimg_empl
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


  END delete_row;


END igs_pe_nonimg_empl_pkg;

/
