--------------------------------------------------------
--  DDL for Package Body IGS_CO_S_LTR_PARAM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_S_LTR_PARAM_PKG" AS
/* $Header: IGSLI18B.pls 115.5 2002/11/29 01:06:38 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_co_s_ltr_param%ROWTYPE;
  new_references igs_co_s_ltr_param%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_s_letter_parameter_type           IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_code_block                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CO_S_LTR_PARAM
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
    new_references.s_letter_parameter_type           := x_s_letter_parameter_type;
    new_references.description                       := x_description;
    new_references.closed_ind                        := x_closed_ind;
    new_references.code_block                        := x_code_block;

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


  PROCEDURE check_constraints (
    column_name    IN     VARCHAR2    DEFAULT NULL,
    column_value   IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the Check Constraint logic for the the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (column_name IS NULL) THEN
      NULL;
    ELSIF (UPPER(column_name) = 'CLOSED_IND') THEN
      new_references.closed_ind := column_value;
    END IF;

    IF (UPPER(column_name) = 'CLOSED_IND' OR column_name IS NULL) THEN
      IF NOT (new_references.closed_ind IN ('Y', 'N'))  THEN
        fnd_message.set_name('IGS','IGS_GE_INVALID_VALUE');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END check_constraints;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_co_ltr_parm_type_pkg.get_fk_igs_co_s_ltr_param (
      old_references.s_letter_parameter_type
    );

    igs_co_s_ltr_pr_arg_pkg.get_fk_igs_co_s_ltr_param (
      old_references.s_letter_parameter_type
    );

    igs_co_s_ltr_pr_rstn_pkg.get_fk_igs_co_s_ltr_param (
      old_references.s_letter_parameter_type
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_s_letter_parameter_type           IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_co_s_ltr_param
      WHERE    s_letter_parameter_type = x_s_letter_parameter_type
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
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_s_letter_parameter_type           IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_code_block                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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
      x_s_letter_parameter_type,
      x_description,
      x_closed_ind,
      x_code_block,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.s_letter_parameter_type
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.s_letter_parameter_type
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_code_block                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_co_s_ltr_param
      WHERE    s_letter_parameter_type           = x_s_letter_parameter_type;

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
      x_s_letter_parameter_type           => x_s_letter_parameter_type,
      x_description                       => x_description,
      x_closed_ind                        => NVL (x_closed_ind,'N' ),
      x_code_block                        => x_code_block,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_co_s_ltr_param (
      s_letter_parameter_type,
      description,
      closed_ind,
      code_block,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.s_letter_parameter_type,
      new_references.description,
      new_references.closed_ind,
      new_references.code_block,
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
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_code_block                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        description,
        closed_ind,
        code_block
      FROM  igs_co_s_ltr_param
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
        (tlinfo.description = x_description)
        AND (tlinfo.closed_ind = x_closed_ind)
        AND ((tlinfo.code_block = x_code_block) OR ((tlinfo.code_block IS NULL) AND (X_code_block IS NULL)))
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
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_code_block                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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
      x_s_letter_parameter_type           => x_s_letter_parameter_type,
      x_description                       => x_description,
      x_closed_ind                        => NVL (x_closed_ind,'N' ),
      x_code_block                        => x_code_block,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_co_s_ltr_param
      SET
        description                       = new_references.description,
        closed_ind                        = new_references.closed_ind,
        code_block                        = new_references.code_block,
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
    x_s_letter_parameter_type           IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_code_block                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_co_s_ltr_param
      WHERE    s_letter_parameter_type           = x_s_letter_parameter_type;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_s_letter_parameter_type,
        x_description,
        x_closed_ind,
        x_code_block,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_s_letter_parameter_type,
      x_description,
      x_closed_ind,
      x_code_block,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : deepankar.dey@oracle.com
  ||  Created On : 14-DEC-2000
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

    DELETE FROM igs_co_s_ltr_param
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_co_s_ltr_param_pkg;

/