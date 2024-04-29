--------------------------------------------------------
--  DDL for Package Body IGS_PS_NSUS_RTN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_NSUS_RTN_PKG" AS
/* $Header: IGSPI3NB.pls 120.0 2005/06/01 22:12:29 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_nsus_rtn%ROWTYPE;
  new_references igs_ps_nsus_rtn%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_incl_wkend_duration_flag          IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ps_nsus_rtn
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
    new_references.non_std_usec_rtn_id               := x_non_std_usec_rtn_id;
    new_references.uoo_id                            := x_uoo_id;
    new_references.fee_type                          := x_fee_type;
    new_references.definition_code                   := x_definition_code;
    new_references.formula_method                    := x_formula_method;
    new_references.round_method                      := x_round_method;
    new_references.incl_wkend_duration_flag          := x_incl_wkend_duration_flag;

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

  PROCEDURE check_constraints(
                                Column_Name     IN      VARCHAR2        ,
                                Column_Value    IN      VARCHAR2        )
  AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Handles the column Constraints logic.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    l_c_column_value VARCHAR2(30) ;
  BEGIN
    l_c_column_value := UPPER(Column_Name);
    IF Column_Name IS NULL THEN
           NULL;
    ELSIF l_c_column_value ='INCL_WKEND_DURATION_FLAG' THEN
           New_References.incl_wkend_duration_flag := Column_Value;
    ELSIF l_c_column_value ='FORMULA_METHOD' THEN
           New_References.formula_method := Column_Value;
    ELSIF l_c_column_value ='ROUND_METHOD' THEN
           New_References.round_method := Column_Value;
    END IF;

    IF l_c_column_value ='INCL_WKEND_DURATION_FLAG' OR Column_Name IS NULL THEN
       IF New_References.incl_wkend_duration_flag NOT IN ( 'Y' , 'N' ) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF l_c_column_value ='FORMULA_METHOD' OR Column_Name IS NULL THEN
       IF New_References.formula_method NOT IN ( 'D' , 'M' ,'P','N') THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
    END IF;

    IF l_c_column_value ='ROUND_METHOD' OR Column_Name IS NULL THEN
       IF New_References.round_method NOT IN ( 'S' , 'A' ) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
    END IF;

  END check_constraints ;

  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.uoo_id,
           new_references.fee_type
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation (
                new_references.uoo_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_fee_type_pkg.get_pk_for_validation (
                new_references.fee_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_ps_nsus_rtn_dtl_pkg.get_fk_igs_ps_nsus_rtn (
      old_references.non_std_usec_rtn_id
    );

    igs_en_dl_offset_cons_pkg.get_fk_igs_ps_nsus_rtn (
      old_references.non_std_usec_rtn_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_non_std_usec_rtn_id               IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_nsus_rtn
      WHERE    non_std_usec_rtn_id = x_non_std_usec_rtn_id
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
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_nsus_rtn
      WHERE    ((uoo_id = x_uoo_id) OR (uoo_id IS NULL AND x_uoo_id IS NULL))
      AND      ((fee_type = x_fee_type) OR (fee_type IS NULL AND x_fee_type IS NULL))
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


  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_nsus_rtn
      WHERE   ((uoo_id = x_uoo_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_NR_USEC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ps_unit_ofr_opt;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_incl_wkend_duration_flag          IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
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
      x_non_std_usec_rtn_id,
      x_uoo_id,
      x_fee_type,
      x_definition_code,
      x_formula_method,
      x_round_method,
      x_incl_wkend_duration_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.non_std_usec_rtn_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_constraints;
      check_parent_existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.non_std_usec_rtn_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      check_constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_non_std_usec_rtn_id               IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_incl_wkend_duration_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_PS_NSUS_RTN_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_non_std_usec_rtn_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_non_std_usec_rtn_id               => x_non_std_usec_rtn_id,
      x_uoo_id                            => x_uoo_id,
      x_fee_type                          => x_fee_type,
      x_definition_code                   => x_definition_code,
      x_formula_method                    => x_formula_method,
      x_round_method                      => x_round_method,
      x_incl_wkend_duration_flag          => x_incl_wkend_duration_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ps_nsus_rtn (
      non_std_usec_rtn_id,
      uoo_id,
      fee_type,
      definition_code,
      formula_method,
      round_method,
      incl_wkend_duration_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_ps_nsus_rtn_s.NEXTVAL,
      new_references.uoo_id,
      new_references.fee_type,
      new_references.definition_code,
      new_references.formula_method,
      new_references.round_method,
      new_references.incl_wkend_duration_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, non_std_usec_rtn_id INTO x_rowid, x_non_std_usec_rtn_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_incl_wkend_duration_flag          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        uoo_id,
        fee_type,
        definition_code,
        formula_method,
        round_method,
        incl_wkend_duration_flag
      FROM  igs_ps_nsus_rtn
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
        ((tlinfo.uoo_id = x_uoo_id) OR ((tlinfo.uoo_id IS NULL) AND (X_uoo_id IS NULL)))
        AND ((tlinfo.fee_type = x_fee_type) OR ((tlinfo.fee_type IS NULL) AND (X_fee_type IS NULL)))
        AND (tlinfo.definition_code = x_definition_code)
        AND (tlinfo.formula_method = x_formula_method)
        AND (tlinfo.round_method = x_round_method)
        AND (tlinfo.incl_wkend_duration_flag = x_incl_wkend_duration_flag)
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
    x_non_std_usec_rtn_id               IN     NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_incl_wkend_duration_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
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
      fnd_message.set_token ('ROUTINE', 'IGS_PS_NSUS_RTN_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_non_std_usec_rtn_id               => x_non_std_usec_rtn_id,
      x_uoo_id                            => x_uoo_id,
      x_fee_type                          => x_fee_type,
      x_definition_code                   => x_definition_code,
      x_formula_method                    => x_formula_method,
      x_round_method                      => x_round_method,
      x_incl_wkend_duration_flag          => x_incl_wkend_duration_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ps_nsus_rtn
      SET
        uoo_id                            = new_references.uoo_id,
        fee_type                          = new_references.fee_type,
        definition_code                   = new_references.definition_code,
        formula_method                    = new_references.formula_method,
        round_method                      = new_references.round_method,
        incl_wkend_duration_flag          = new_references.incl_wkend_duration_flag,
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
    x_non_std_usec_rtn_id               IN OUT NOCOPY NUMBER,
    x_uoo_id                            IN     NUMBER,
    x_fee_type                          IN     VARCHAR2,
    x_definition_code                   IN     VARCHAR2,
    x_formula_method                    IN     VARCHAR2,
    x_round_method                      IN     VARCHAR2,
    x_incl_wkend_duration_flag          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_nsus_rtn
      WHERE    non_std_usec_rtn_id               = x_non_std_usec_rtn_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_non_std_usec_rtn_id,
        x_uoo_id,
        x_fee_type,
        x_definition_code,
        x_formula_method,
        x_round_method,
        x_incl_wkend_duration_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_non_std_usec_rtn_id,
      x_uoo_id,
      x_fee_type,
      x_definition_code,
      x_formula_method,
      x_round_method,
      x_incl_wkend_duration_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sanjeeb.rakshit@oracle.com
  ||  Created On : 10-SEP-2004
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

    DELETE FROM igs_ps_nsus_rtn
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ps_nsus_rtn_pkg;

/
