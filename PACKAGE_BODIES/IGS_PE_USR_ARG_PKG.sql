--------------------------------------------------------
--  DDL for Package Body IGS_PE_USR_ARG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_USR_ARG_PKG" AS
/* $Header: IGSNI82B.pls 120.3 2006/01/18 23:23:45 skpandey ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_usr_arg_all%ROWTYPE;
  new_references igs_pe_usr_arg_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_usr_act_re_gs_id                  IN     NUMBER      DEFAULT NULL,
    x_person_type                       IN     VARCHAR2    DEFAULT NULL,
    x_record_open_dt_alias              IN     VARCHAR2    DEFAULT NULL,
    x_record_cutoff_dt_alias            IN     VARCHAR2    DEFAULT NULL,
    x_grad_sch_dt_alias                 IN     VARCHAR2    DEFAULT NULL,
    x_upd_audit_dt_alias                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_USR_ARG_ALL
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
    new_references.usr_act_re_gs_id                  := x_usr_act_re_gs_id;
    new_references.person_type                       := x_person_type;
    new_references.record_open_dt_alias              := x_record_open_dt_alias;
    new_references.record_cutoff_dt_alias            := x_record_cutoff_dt_alias;
    new_references.grad_sch_dt_alias                 := x_grad_sch_dt_alias;
    new_references.upd_audit_dt_alias                := x_upd_audit_dt_alias;

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


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_type
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_type = new_references.person_type)) OR
        ((new_references.person_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_types_pkg.get_pk_for_validation (
                new_references.person_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.record_open_dt_alias = new_references.record_open_dt_alias)) OR
        ((new_references.record_open_dt_alias IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_da_pkg.get_pk_for_validation (
                new_references.record_open_dt_alias
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.record_cutoff_dt_alias = new_references.record_cutoff_dt_alias)) OR
        ((new_references.record_cutoff_dt_alias IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_da_pkg.get_pk_for_validation (
                new_references.record_cutoff_dt_alias
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.grad_sch_dt_alias = new_references.grad_sch_dt_alias)) OR
        ((new_references.grad_sch_dt_alias IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_da_pkg.get_pk_for_validation (
                new_references.grad_sch_dt_alias
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.upd_audit_dt_alias = new_references.upd_audit_dt_alias)) OR
        ((new_references.upd_audit_dt_alias IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ca_da_pkg.get_pk_for_validation (
                new_references.upd_audit_dt_alias
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_usr_act_re_gs_id                  IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_usr_arg_all
      WHERE    usr_act_re_gs_id = x_usr_act_re_gs_id
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


  FUNCTION get_uk_for_validation (
    x_person_type                       IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || skpandey         13-JAN-2006     Bug#4937960:
  ||                                  Changed cur_rowid cursor definition to optimize query
  || ayedubat         25/6/2001       changed the row_id from rowid in CURSOR.
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_usr_arg_all
      WHERE    person_type = x_person_type
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


  PROCEDURE get_fk_igs_pe_person_types (
    x_person_type_code                  IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_usr_arg_all
      WHERE   ((person_type = x_person_type_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_UARGV_PTY_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_person_types;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_usr_act_re_gs_id                  IN     NUMBER      DEFAULT NULL,
    x_person_type                       IN     VARCHAR2    DEFAULT NULL,
    x_record_open_dt_alias              IN     VARCHAR2    DEFAULT NULL,
    x_record_cutoff_dt_alias            IN     VARCHAR2    DEFAULT NULL,
    x_grad_sch_dt_alias                 IN     VARCHAR2    DEFAULT NULL,
    x_upd_audit_dt_alias                IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
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
      x_usr_act_re_gs_id,
      x_person_type,
      x_record_open_dt_alias,
      x_record_cutoff_dt_alias,
      x_grad_sch_dt_alias,
      x_upd_audit_dt_alias,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.usr_act_re_gs_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.usr_act_re_gs_id
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
    x_usr_act_re_gs_id                  IN OUT NOCOPY NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_record_open_dt_alias              IN     VARCHAR2,
    x_record_cutoff_dt_alias            IN     VARCHAR2,
    x_grad_sch_dt_alias                 IN     VARCHAR2,
    x_upd_audit_dt_alias                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pe_usr_arg_all
      WHERE    usr_act_re_gs_id                  = x_usr_act_re_gs_id;

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

    SELECT    igs_pe_usr_arg_all_s.NEXTVAL
    INTO      x_usr_act_re_gs_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_usr_act_re_gs_id                  => x_usr_act_re_gs_id,
      x_person_type                       => x_person_type,
      x_record_open_dt_alias              => x_record_open_dt_alias,
      x_record_cutoff_dt_alias            => x_record_cutoff_dt_alias,
      x_grad_sch_dt_alias                 => x_grad_sch_dt_alias,
      x_upd_audit_dt_alias                => x_upd_audit_dt_alias,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );


    INSERT INTO igs_pe_usr_arg_all (
      usr_act_re_gs_id,
      person_type,
      record_open_dt_alias,
      record_cutoff_dt_alias,
      grad_sch_dt_alias,
      upd_audit_dt_alias,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.usr_act_re_gs_id,
      new_references.person_type,
      new_references.record_open_dt_alias,
      new_references.record_cutoff_dt_alias,
      new_references.grad_sch_dt_alias,
      new_references.upd_audit_dt_alias,
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

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_usr_act_re_gs_id                  IN     NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_record_open_dt_alias              IN     VARCHAR2,
    x_record_cutoff_dt_alias            IN     VARCHAR2,
    x_grad_sch_dt_alias                 IN     VARCHAR2,
    x_upd_audit_dt_alias                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||ayedubat      25/6/2001     In the cursor select statement ,view igs_pe_usr_arg
  ||                            is changed to base table,igs_pe_usr_arg_all
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_type,
        record_open_dt_alias,
        record_cutoff_dt_alias,
        grad_sch_dt_alias,
        upd_audit_dt_alias
      FROM  igs_pe_usr_arg_all
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
        (tlinfo.person_type = x_person_type)
        AND ((tlinfo.record_open_dt_alias = x_record_open_dt_alias) OR ((tlinfo.record_open_dt_alias IS NULL) AND (X_record_open_dt_alias IS NULL)))
        AND ((tlinfo.record_cutoff_dt_alias = x_record_cutoff_dt_alias) OR ((tlinfo.record_cutoff_dt_alias IS NULL) AND (X_record_cutoff_dt_alias IS NULL)))
        AND ((tlinfo.grad_sch_dt_alias = x_grad_sch_dt_alias) OR ((tlinfo.grad_sch_dt_alias IS NULL) AND (X_grad_sch_dt_alias IS NULL)))
        AND ((tlinfo.upd_audit_dt_alias = x_upd_audit_dt_alias) OR ((tlinfo.upd_audit_dt_alias IS NULL) AND (X_upd_audit_dt_alias IS NULL)))
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
    x_usr_act_re_gs_id                  IN     NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_record_open_dt_alias              IN     VARCHAR2,
    x_record_cutoff_dt_alias            IN     VARCHAR2,
    x_grad_sch_dt_alias                 IN     VARCHAR2,
    x_upd_audit_dt_alias                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
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
      x_usr_act_re_gs_id                  => x_usr_act_re_gs_id,
      x_person_type                       => x_person_type,
      x_record_open_dt_alias              => x_record_open_dt_alias,
      x_record_cutoff_dt_alias            => x_record_cutoff_dt_alias,
      x_grad_sch_dt_alias                 => x_grad_sch_dt_alias,
      x_upd_audit_dt_alias                => x_upd_audit_dt_alias,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_pe_usr_arg_all
      SET
        person_type                       = new_references.person_type,
        record_open_dt_alias              = new_references.record_open_dt_alias,
        record_cutoff_dt_alias            = new_references.record_cutoff_dt_alias,
        grad_sch_dt_alias                 = new_references.grad_sch_dt_alias,
        upd_audit_dt_alias                 = new_references.upd_audit_dt_alias,
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
    x_usr_act_re_gs_id                  IN OUT NOCOPY NUMBER,
    x_person_type                       IN     VARCHAR2,
    x_record_open_dt_alias              IN     VARCHAR2,
    x_record_cutoff_dt_alias            IN     VARCHAR2,
    x_grad_sch_dt_alias                 IN     VARCHAR2,
    x_upd_audit_dt_alias                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_usr_arg_all
      WHERE    usr_act_re_gs_id                  = x_usr_act_re_gs_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_usr_act_re_gs_id,
        x_person_type,
        x_record_open_dt_alias,
        x_record_cutoff_dt_alias,
        x_grad_sch_dt_alias,
        x_upd_audit_dt_alias,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_usr_act_re_gs_id,
      x_person_type,
      x_record_open_dt_alias,
      x_record_cutoff_dt_alias,
      x_grad_sch_dt_alias,
      x_upd_audit_dt_alias,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Bhawani.Devarakonda@Oracle.com
  ||  Created On : 30-MAR-2001
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

    DELETE FROM igs_pe_usr_arg_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pe_usr_arg_pkg;

/
