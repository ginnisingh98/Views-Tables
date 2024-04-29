--------------------------------------------------------
--  DDL for Package Body IGS_GE_CFG_FORM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_CFG_FORM_PKG" AS
/* $Header: IGSNIA0B.pls 120.0 2005/06/02 00:17:52 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ge_cfg_form%ROWTYPE;
  new_references igs_ge_cfg_form%ROWTYPE;
  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_query_only_ind                    IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 08-OCT-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ge_cfg_form
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
    new_references.responsibility_id                 := x_responsibility_id;
    new_references.form_code                         := x_form_code;
    new_references.query_only_ind                    := x_query_only_ind;
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
  PROCEDURE check_child_existance AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 08-OCT-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    igs_ge_cfg_tab_pkg.get_fk_igs_ge_cfg_form (
      old_references.responsibility_id,
      old_references.form_code
    );
  END check_child_existance;
  FUNCTION get_pk_for_validation (
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 08-OCT-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ge_cfg_form
      WHERE    responsibility_id = x_responsibility_id
      AND      form_code = x_form_code
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

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_query_only_ind                    IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 08-OCT-2002
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
      x_responsibility_id,
      x_form_code,
      x_query_only_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.responsibility_id,
             new_references.form_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

   ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.responsibility_id,
             new_references.form_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;
  END before_dml;
  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_query_only_ind                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 08-OCT-2002
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
      x_responsibility_id                 => x_responsibility_id,
      x_form_code                         => x_form_code,
      x_query_only_ind                    => x_query_only_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );
    INSERT INTO igs_ge_cfg_form (
      responsibility_id,
      form_code,
      query_only_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.responsibility_id,
      new_references.form_code,
      new_references.query_only_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;
  END insert_row;
  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_query_only_ind                    IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 08-OCT-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        query_only_ind
      FROM  igs_ge_cfg_form
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
        (tlinfo.query_only_ind = x_query_only_ind)
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
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_query_only_ind                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 08-OCT-2002
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
      x_responsibility_id                 => x_responsibility_id,
      x_form_code                         => x_form_code,
      x_query_only_ind                    => x_query_only_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );
    UPDATE igs_ge_cfg_form
      SET
        query_only_ind                    = new_references.query_only_ind,
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
    x_responsibility_id                 IN     NUMBER,
    x_form_code                         IN     VARCHAR2,
    x_query_only_ind                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 08-OCT-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ge_cfg_form
      WHERE    responsibility_id                 = x_responsibility_id
      AND      form_code                         = x_form_code;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_responsibility_id,
        x_form_code,
        x_query_only_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_responsibility_id,
      x_form_code,
      x_query_only_ind,
      x_mode
    );
  END add_row;
  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 08-OCT-2002
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
    DELETE FROM igs_ge_cfg_form
    WHERE rowid = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;


  PROCEDURE do_copy (
    x_from_responsibility_id                 IN     NUMBER,
    x_to_responsibility_id                   IN     NUMBER
  ) AS
  /*
  ||  Created By : kiran.padiyar@oracle.com
  ||  Created On : 07-OCT-2002
  ||  Purpose : Does the copy of configuration from the from responsibility
  ||            to the to responsibility.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  lv_rowid ROWID;
  BEGIN
    -- Delete from Tab Configuration
        For i in (SELECT rowid FROM igs_ge_cfg_tab WHERE responsibility_id = x_to_responsibility_id) LOOP
         igs_ge_cfg_tab_pkg.delete_row (
                                         i.rowid
                                         );
    END LOOP;
    -- Delete from Form Configuration
        For i in (SELECT rowid FROM igs_ge_cfg_form WHERE responsibility_id = x_to_responsibility_id) LOOP
         igs_ge_cfg_form_pkg.delete_row (
                                         i.rowid
                                         );

    END LOOP;
    -- Delete from Nav Configuration
        For i in (SELECT rowid FROM igs_ge_cfg_nav WHERE responsibility_id = x_to_responsibility_id) LOOP
         igs_ge_cfg_nav_pkg.delete_row (
                                         i.rowid
                                         );
    END LOOP;

    -- Insert for the Form Configuration
    For i in (SELECT form_code,query_only_ind FROM igs_ge_cfg_form WHERE responsibility_id = x_from_responsibility_id) LOOP
          lv_rowid := Null;
         igs_ge_cfg_form_pkg.insert_row (
                                         lv_rowid,
                                         x_to_responsibility_id,
                                         i.form_code,
                                         i.query_only_ind,
                                         'R'
                                         );
    END LOOP;

    -- Insert for the Tab Configuration
    For i in (SELECT form_code,tab_code,config_opt FROM igs_ge_cfg_tab WHERE responsibility_id = x_from_responsibility_id) LOOP
          lv_rowid := Null;
         igs_ge_cfg_tab_pkg.insert_row (
                                         lv_rowid,
                                         x_to_responsibility_id,
                                         i.form_code,
                                         i.tab_code,
                                         i.config_opt,
                                         'R'
                                         );
    END LOOP;

    -- Insert for the Nav Configuration
    For i in (SELECT form_code,seq_number,subform_code,but_label FROM igs_ge_cfg_nav WHERE responsibility_id = x_from_responsibility_id) LOOP
          lv_rowid := Null;
         igs_ge_cfg_nav_pkg.insert_row (
                                         lv_rowid,
                                         x_to_responsibility_id,
                                         i.form_code,
                                         i.seq_number,
                                         i.subform_code,
                                         i.but_label,
                                         'R'
                                         );
    END LOOP;

  END do_copy;

END igs_ge_cfg_form_pkg;

/
