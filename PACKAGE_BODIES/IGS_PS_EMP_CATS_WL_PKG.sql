--------------------------------------------------------
--  DDL for Package Body IGS_PS_EMP_CATS_WL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_EMP_CATS_WL_PKG" AS
/* $Header: IGSPI3KB.pls 120.0 2005/06/02 00:18:30 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_emp_cats_wl%ROWTYPE;
  new_references igs_ps_emp_cats_wl%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2,
    x_expected_wl_num                   IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 13-JUN-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ps_emp_cats_wl
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
    new_references.cal_cat_code                      := x_cal_cat_code;
    new_references.emp_cat_code                      := x_emp_cat_code;
    new_references.expected_wl_num                   := x_expected_wl_num;

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
  ||  Created By : smvk
  ||  Created On : 13-JUN-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.cal_cat_code = new_references.cal_cat_code)) OR
        ((new_references.cal_cat_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_exp_wl_pkg.get_pk_for_validation (
                new_references.cal_cat_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smvk
  ||  Created On : 13-JUN-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_emp_cats_wl
      WHERE    cal_cat_code = x_cal_cat_code
      AND      emp_cat_code = x_emp_cat_code
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


  PROCEDURE get_fk_igs_ps_exp_wl (
    x_calendar_cat                      IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 13-JUN-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_emp_cats_wl
      WHERE   ((cal_cat_code = x_calendar_cat));

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

  END get_fk_igs_ps_exp_wl;

  PROCEDURE check_expected_wl_num
  AS
/*
  ||  Created By : sarakshi
  ||  Created On : 14-Feb-2005
  ||  Purpose : To verify that decreasing the value for expected_wl_num will have no impact on the assigned workload for any faculty.
  ||
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_igs_ps_fac_wl IS
    SELECT cal_type,ci_sequence_number,person_id
    FROM   igs_ps_fac_wl;

    l_n_exp_wl NUMBER;
    l_n_tot_fac_wl NUMBER;
    l_error BOOLEAN := FALSE;
  BEGIN
    IF new_references.expected_wl_num <> old_references.expected_wl_num AND new_references.expected_wl_num < old_references.expected_wl_num THEN
      FOR cur_igs_ps_fac_wl_rec IN cur_igs_ps_fac_wl LOOP
        IF igs_ps_gen_001.fac_exceed_exp_wl(cur_igs_ps_fac_wl_rec.cal_type,
                                            cur_igs_ps_fac_wl_rec.ci_sequence_number,
                                            cur_igs_ps_fac_wl_rec.person_id,
                                            0,
                                            l_n_tot_fac_wl,
                                            l_n_exp_wl
                                            ) THEN
          l_error := TRUE;
	  EXIT;
        END IF;
      END LOOP;

      IF l_error THEN
        fnd_message.set_name('IGS','IGS_PS_DECREASE_NOT_EXP_WL');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    END IF;
  END check_expected_wl_num;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2,
    x_expected_wl_num                   IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 13-JUN-2003
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
      x_cal_cat_code,
      x_emp_cat_code,
      x_expected_wl_num,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.cal_cat_code,
             new_references.emp_cat_code
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
             new_references.cal_cat_code,
             new_references.emp_cat_code
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
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2,
    x_expected_wl_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 13-JUN-2003
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
      fnd_message.set_token ('ROUTINE', 'igs_ps_emp_cats_wl_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_cal_cat_code                      => x_cal_cat_code,
      x_emp_cat_code                      => x_emp_cat_code,
      x_expected_wl_num                   => x_expected_wl_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ps_emp_cats_wl (
      cal_cat_code,
      emp_cat_code,
      expected_wl_num,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.cal_cat_code,
      new_references.emp_cat_code,
      new_references.expected_wl_num,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2,
    x_expected_wl_num                   IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 13-JUN-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        expected_wl_num
      FROM  igs_ps_emp_cats_wl
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
        (tlinfo.expected_wl_num = x_expected_wl_num)
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
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2,
    x_expected_wl_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 13-JUN-2003
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
      fnd_message.set_token ('ROUTINE', 'igs_ps_emp_cats_wl_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_cal_cat_code                      => x_cal_cat_code,
      x_emp_cat_code                      => x_emp_cat_code,
      x_expected_wl_num                   => x_expected_wl_num,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ps_emp_cats_wl
      SET
        expected_wl_num                   = new_references.expected_wl_num,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    --Added as a part of bug#4099575,should not allow to lower the value of expected_wl_num if it is disrupting the setting already done in assign/override faculty workload
    check_expected_wl_num;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_cal_cat_code                      IN     VARCHAR2,
    x_emp_cat_code                      IN     VARCHAR2,
    x_expected_wl_num                   IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 13-JUN-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_emp_cats_wl
      WHERE    cal_cat_code                      = x_cal_cat_code
      AND      emp_cat_code                      = x_emp_cat_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_cal_cat_code,
        x_emp_cat_code,
        x_expected_wl_num,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_cal_cat_code,
      x_emp_cat_code,
      x_expected_wl_num,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 13-JUN-2003
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

    DELETE FROM igs_ps_emp_cats_wl
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ps_emp_cats_wl_pkg;

/
