--------------------------------------------------------
--  DDL for Package Body IGS_OR_FUNC_FLTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_FUNC_FLTR_PKG" AS
/* $Header: IGSOI33B.pls 115.2 2002/11/29 01:45:13 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_or_func_fltr%ROWTYPE;
  new_references igs_or_func_fltr%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_func_fltr_id                      IN     VARCHAR2,
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2,
    x_attr_val_desc                     IN     VARCHAR2,
    x_inst_org_val                      IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 23-OCT-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_or_func_fltr
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
    new_references.func_fltr_id                      := x_func_fltr_id;
    new_references.func_code                         := x_func_code;
    new_references.attr_type                         := x_attr_type;
    new_references.attr_val                          := x_attr_val;
    new_references.attr_val_desc                     := x_attr_val_desc;
    new_references.inst_org_val                      := x_inst_org_val;

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
  ||  Created By : prabhat.patel
  ||  Created On : 23-OCT-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.func_code,
           new_references.attr_type,
           new_references.attr_val
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 09-OCT-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR func_code_cur IS
	SELECT 'X'
	FROM   igs_lookup_values
	WHERE  lookup_type = 'OR_FTR_FUNC_NAME' AND
	       lookup_code = new_references.func_code;

    CURSOR attr_type_cur IS
	SELECT 'X'
	FROM   igs_lookup_values
	WHERE  lookup_type = 'OR_FTR_ATTR_TYPE' AND
	       lookup_code = new_references.attr_type;

    l_exists  VARCHAR2(1);
  BEGIN

    IF (((old_references.func_code = new_references.func_code)) OR
        ((new_references.func_code IS NULL))) THEN
      NULL;
    ELSE
	  OPEN func_code_cur;
	  FETCH func_code_cur INTO l_exists;
	    IF func_code_cur%NOTFOUND THEN
		   CLOSE func_code_cur;
           FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
	  CLOSE func_code_cur;
    END IF;

    IF (((old_references.attr_type = new_references.attr_type)) OR
        ((new_references.attr_type IS NULL))) THEN
      NULL;
    ELSE
	  OPEN attr_type_cur;
	  FETCH attr_type_cur INTO l_exists;
	    IF attr_type_cur%NOTFOUND THEN
		   CLOSE attr_type_cur;
           FND_MESSAGE.SET_NAME ('FND', 'FORM_RECORD_DELETED');
           IGS_GE_MSG_STACK.ADD;
           APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
	  CLOSE attr_type_cur;
	END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_func_fltr_id                      IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 23-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_func_fltr
      WHERE    func_fltr_id = x_func_fltr_id
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
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 23-OCT-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_or_func_fltr
      WHERE    func_code = x_func_code
      AND      attr_type = x_attr_type
      AND      attr_val = x_attr_val
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

  PROCEDURE BeforeRowInsertUpdate(
     p_inserting IN BOOLEAN,
     p_updating IN BOOLEAN,
     p_deleting IN BOOLEAN
    ) AS

    CURSOR attr_type_cur IS
	SELECT COUNT(DISTINCT attr_type)
	FROM   igs_or_func_fltr
    WHERE  func_code = new_references.func_code;

	l_count NUMBER(2);

  BEGIN
         -- Validate that start date is not less than the current date.
    IF (p_inserting) THEN
      OPEN attr_type_cur;
      FETCH attr_type_cur INTO l_count;
	  CLOSE attr_type_cur;

	  IF l_count > 1 THEN
        FND_MESSAGE.SET_NAME ('IGS', 'IGS_OR_SINGLE_ATTR_TYPE');
        IGS_GE_MSG_STACK.ADD;
        APP_EXCEPTION.RAISE_EXCEPTION;
	  END IF;

    END IF;

  END BeforeRowInsertUpdate;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_func_fltr_id                      IN     VARCHAR2,
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2,
    x_attr_val_desc                     IN     VARCHAR2,
    x_inst_org_val                      IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 23-OCT-2002
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
      x_func_fltr_id,
      x_func_code,
      x_attr_type,
      x_attr_val,
      x_attr_val_desc,
      x_inst_org_val,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
	  -- Call all the procedures related to Before Insert.

		  beforerowinsertupdate(
           p_inserting => TRUE,
           p_updating  => FALSE,
           p_deleting  => FALSE);

      IF ( get_pk_for_validation(
             new_references.func_fltr_id
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
             new_references.func_fltr_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_parent_existance;

    END IF;

  END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_func_fltr_id                      IN OUT NOCOPY VARCHAR2,
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2,
    x_attr_val_desc                     IN     VARCHAR2,
    x_inst_org_val                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 23-OCT-2002
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_func_fltr_id                      => x_func_fltr_id,
      x_func_code                         => x_func_code,
      x_attr_type                         => x_attr_type,
      x_attr_val                          => x_attr_val,
      x_attr_val_desc                     => x_attr_val_desc,
      x_inst_org_val                      => x_inst_org_val,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_or_func_fltr (
      func_fltr_id,
      func_code,
      attr_type,
      attr_val,
      attr_val_desc,
      inst_org_val,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_or_func_fltr_s.NEXTVAL,
      new_references.func_code,
      new_references.attr_type,
      new_references.attr_val,
      new_references.attr_val_desc,
      new_references.inst_org_val,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, func_fltr_id INTO x_rowid, x_func_fltr_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_func_fltr_id                      IN     VARCHAR2,
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2,
    x_attr_val_desc                     IN     VARCHAR2,
    x_inst_org_val                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 23-OCT-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        func_code,
        attr_type,
        attr_val,
        attr_val_desc,
        inst_org_val
      FROM  igs_or_func_fltr
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
        (tlinfo.func_code = x_func_code)
        AND (tlinfo.attr_type = x_attr_type)
        AND (tlinfo.attr_val = x_attr_val)
        AND (tlinfo.attr_val_desc = x_attr_val_desc)
        AND (tlinfo.inst_org_val = x_inst_org_val)
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
    x_func_fltr_id                      IN     VARCHAR2,
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2,
    x_attr_val_desc                     IN     VARCHAR2,
    x_inst_org_val                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 23-OCT-2002
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
      x_func_fltr_id                      => x_func_fltr_id,
      x_func_code                         => x_func_code,
      x_attr_type                         => x_attr_type,
      x_attr_val                          => x_attr_val,
      x_attr_val_desc                     => x_attr_val_desc,
      x_inst_org_val                      => x_inst_org_val,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_or_func_fltr
      SET
        func_code                         = new_references.func_code,
        attr_type                         = new_references.attr_type,
        attr_val                          = new_references.attr_val,
        attr_val_desc                     = new_references.attr_val_desc,
        inst_org_val                      = new_references.inst_org_val,
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
    x_func_fltr_id                      IN OUT NOCOPY VARCHAR2,
    x_func_code                         IN     VARCHAR2,
    x_attr_type                         IN     VARCHAR2,
    x_attr_val                          IN     VARCHAR2,
    x_attr_val_desc                     IN     VARCHAR2,
    x_inst_org_val                      IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 23-OCT-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_or_func_fltr
      WHERE    func_fltr_id                      = x_func_fltr_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_func_fltr_id,
        x_func_code,
        x_attr_type,
        x_attr_val,
        x_attr_val_desc,
        x_inst_org_val,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_func_fltr_id,
      x_func_code,
      x_attr_type,
      x_attr_val,
      x_attr_val_desc,
      x_inst_org_val,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : prabhat.patel
  ||  Created On : 23-OCT-2002
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

    DELETE FROM igs_or_func_fltr
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_or_func_fltr_pkg;

/
