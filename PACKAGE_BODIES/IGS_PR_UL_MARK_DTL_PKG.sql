--------------------------------------------------------
--  DDL for Package Body IGS_PR_UL_MARK_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_UL_MARK_DTL_PKG" AS
/* $Header: IGSQI47B.pls 115.0 2003/11/07 11:01:10 ijeddy noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pr_ul_mark_dtl%ROWTYPE;
  new_references igs_pr_ul_mark_dtl%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_total_credits                     IN     NUMBER,
    x_required_flag                     IN     VARCHAR2,
    x_priority_num                      IN     NUMBER,
    x_unit_selection_code               IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 15-OCT-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pr_ul_mark_dtl
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
    new_references.mark_config_id                    := x_mark_config_id;
    new_references.core_indicator_code               := x_core_indicator_code;
    new_references.total_credits                     := x_total_credits;
    new_references.required_flag                     := x_required_flag;
    new_references.priority_num                      := x_priority_num;
    new_references.unit_selection_code               := x_unit_selection_code;

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
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 15-OCT-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.mark_config_id = new_references.mark_config_id)) OR
        ((new_references.mark_config_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pr_ul_mark_cnfg_pkg.get_pk_for_validation (
                new_references.mark_config_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 15-OCT-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_ul_mark_dtl
      WHERE    mark_config_id = x_mark_config_id
      AND      core_indicator_code = x_core_indicator_code
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


  PROCEDURE get_fk_igs_pr_ul_mark_cnfg (
    x_mark_config_id                    IN     NUMBER
  ) AS
  /*
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 15-OCT-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pr_ul_mark_dtl
      WHERE   ((mark_config_id = x_mark_config_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_FOREIGN_KEY_REFERENCE');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pr_ul_mark_cnfg;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_total_credits                     IN     NUMBER,
    x_required_flag                     IN     VARCHAR2,
    x_priority_num                      IN     NUMBER,
    x_unit_selection_code               IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 15-OCT-2003
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
      x_mark_config_id,
      x_core_indicator_code,
      x_total_credits,
      x_required_flag,
      x_priority_num,
      x_unit_selection_code,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.mark_config_id,
             new_references.core_indicator_code
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
             new_references.mark_config_id,
             new_references.core_indicator_code
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
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_total_credits                     IN     NUMBER,
    x_required_flag                     IN     VARCHAR2,
    x_priority_num                      IN     NUMBER,
    x_unit_selection_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 15-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_PR_UL_MARK_DTL_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_mark_config_id                    => x_mark_config_id,
      x_core_indicator_code               => x_core_indicator_code,
      x_total_credits                     => x_total_credits,
      x_required_flag                     => x_required_flag,
      x_priority_num                      => x_priority_num,
      x_unit_selection_code               => x_unit_selection_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_pr_ul_mark_dtl (
      mark_config_id,
      core_indicator_code,
      total_credits,
      required_flag,
      priority_num,
      unit_selection_code,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.mark_config_id,
      new_references.core_indicator_code,
      new_references.total_credits,
      new_references.required_flag,
      new_references.priority_num,
      new_references.unit_selection_code,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_total_credits                     IN     NUMBER,
    x_required_flag                     IN     VARCHAR2,
    x_priority_num                      IN     NUMBER,
    x_unit_selection_code               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 15-OCT-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        total_credits,
        required_flag,
        priority_num,
        unit_selection_code
      FROM  igs_pr_ul_mark_dtl
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
        ((tlinfo.total_credits = x_total_credits) OR ((tlinfo.total_credits IS NULL) AND (X_total_credits IS NULL)))
        AND (tlinfo.required_flag = x_required_flag)
        AND (tlinfo.priority_num = x_priority_num)
        AND ((tlinfo.unit_selection_code = x_unit_selection_code) OR ((tlinfo.unit_selection_code IS NULL) AND (X_unit_selection_code IS NULL)))
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
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_total_credits                     IN     NUMBER,
    x_required_flag                     IN     VARCHAR2,
    x_priority_num                      IN     NUMBER,
    x_unit_selection_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 15-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_PR_UL_MARK_DTL_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_mark_config_id                    => x_mark_config_id,
      x_core_indicator_code               => x_core_indicator_code,
      x_total_credits                     => x_total_credits,
      x_required_flag                     => x_required_flag,
      x_priority_num                      => x_priority_num,
      x_unit_selection_code               => x_unit_selection_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_pr_ul_mark_dtl
      SET
        total_credits                     = new_references.total_credits,
        required_flag                     = new_references.required_flag,
        priority_num                      = new_references.priority_num,
        unit_selection_code               = new_references.unit_selection_code,
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
    x_mark_config_id                    IN     NUMBER,
    x_core_indicator_code               IN     VARCHAR2,
    x_total_credits                     IN     NUMBER,
    x_required_flag                     IN     VARCHAR2,
    x_priority_num                      IN     NUMBER,
    x_unit_selection_code               IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 15-OCT-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pr_ul_mark_dtl
      WHERE    mark_config_id                    = x_mark_config_id
      AND      core_indicator_code               = x_core_indicator_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_mark_config_id,
        x_core_indicator_code,
        x_total_credits,
        x_required_flag,
        x_priority_num,
        x_unit_selection_code,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_mark_config_id,
      x_core_indicator_code,
      x_total_credits,
      x_required_flag,
      x_priority_num,
      x_unit_selection_code,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Imran.Jeddy@oracle.com
  ||  Created On : 15-OCT-2003
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

    DELETE FROM igs_pr_ul_mark_dtl
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_pr_ul_mark_dtl_pkg;

/
