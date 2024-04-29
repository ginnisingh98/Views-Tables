--------------------------------------------------------
--  DDL for Package Body IGS_FI_PP_TMPL_LNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_PP_TMPL_LNS_PKG" AS
/* $Header: IGSSID9B.pls 115.1 2003/09/08 16:56:40 smvk noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_fi_pp_tmpl_lns%ROWTYPE;
  new_references igs_fi_pp_tmpl_lns%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_plan_line_id                      IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER,
    x_plan_percent                      IN     NUMBER,
    x_plan_amt                          IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_fi_pp_tmpl_lns
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
    new_references.plan_line_id                      := x_plan_line_id;
    new_references.payment_plan_name                 := x_payment_plan_name;
    new_references.plan_line_num                     := x_plan_line_num;
    new_references.plan_percent                      := x_plan_percent;
    new_references.plan_amt                          := x_plan_amt;

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
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smvk           06-Sep-2003     Modified the standand message 'IGS_GE_RECORD_ALREADY_EXISTS' with
  ||                                 specific message 'IGS_FI_PP_TPL_INST_DEF_NUM'.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.payment_plan_name,
           new_references.plan_line_num
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_FI_PP_TPL_INST_DEF_NUM');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.payment_plan_name = new_references.payment_plan_name)) OR
        ((new_references.payment_plan_name IS NULL))) THEN
      NULL;
    ELSIF NOT igs_fi_pp_templates_pkg.get_pk_for_validation (
                new_references.payment_plan_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_plan_line_id                      IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_pp_tmpl_lns
      WHERE    plan_line_id = x_plan_line_id
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
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_fi_pp_tmpl_lns
      WHERE    payment_plan_name = x_payment_plan_name
      AND      plan_line_num = x_plan_line_num
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

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_plan_line_id                      IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER,
    x_plan_percent                      IN     NUMBER,
    x_plan_amt                          IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smvk           06-Sep-2003     l_rowid is initialized to null.
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_plan_line_id,
      x_payment_plan_name,
      x_plan_line_num,
      x_plan_percent,
      x_plan_amt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.plan_line_id
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
             new_references.plan_line_id
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

   l_rowid := NULL;
  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_plan_line_id                      IN OUT NOCOPY NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER,
    x_plan_percent                      IN     NUMBER,
    x_plan_amt                          IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_PP_TMPL_LNS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_plan_line_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_plan_line_id                      => x_plan_line_id,
      x_payment_plan_name                 => x_payment_plan_name,
      x_plan_line_num                     => x_plan_line_num,
      x_plan_percent                      => x_plan_percent,
      x_plan_amt                          => x_plan_amt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_fi_pp_tmpl_lns (
      plan_line_id,
      payment_plan_name,
      plan_line_num,
      plan_percent,
      plan_amt,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_fi_pp_tmpl_lns_s.NEXTVAL,
      new_references.payment_plan_name,
      new_references.plan_line_num,
      new_references.plan_percent,
      new_references.plan_amt,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, plan_line_id INTO x_rowid, x_plan_line_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_plan_line_id                      IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER,
    x_plan_percent                      IN     NUMBER,
    x_plan_amt                          IN     NUMBER
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        payment_plan_name,
        plan_line_num,
        plan_percent,
        plan_amt
      FROM  igs_fi_pp_tmpl_lns
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
        (tlinfo.payment_plan_name = x_payment_plan_name)
        AND (tlinfo.plan_line_num = x_plan_line_num)
        AND ((tlinfo.plan_percent = x_plan_percent) OR ((tlinfo.plan_percent IS NULL) AND (X_plan_percent IS NULL)))
        AND ((tlinfo.plan_amt = x_plan_amt) OR ((tlinfo.plan_amt IS NULL) AND (X_plan_amt IS NULL)))
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
    x_plan_line_id                      IN     NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER,
    x_plan_percent                      IN     NUMBER,
    x_plan_amt                          IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_FI_PP_TMPL_LNS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_plan_line_id                      => x_plan_line_id,
      x_payment_plan_name                 => x_payment_plan_name,
      x_plan_line_num                     => x_plan_line_num,
      x_plan_percent                      => x_plan_percent,
      x_plan_amt                          => x_plan_amt,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_fi_pp_tmpl_lns
      SET
        payment_plan_name                 = new_references.payment_plan_name,
        plan_line_num                     = new_references.plan_line_num,
        plan_percent                      = new_references.plan_percent,
        plan_amt                          = new_references.plan_amt,
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
    x_plan_line_id                      IN OUT NOCOPY NUMBER,
    x_payment_plan_name                 IN     VARCHAR2,
    x_plan_line_num                     IN     NUMBER,
    x_plan_percent                      IN     NUMBER,
    x_plan_amt                          IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_fi_pp_tmpl_lns
      WHERE    plan_line_id                      = x_plan_line_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_plan_line_id,
        x_payment_plan_name,
        x_plan_line_num,
        x_plan_percent,
        x_plan_amt,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_plan_line_id,
      x_payment_plan_name,
      x_plan_line_num,
      x_plan_percent,
      x_plan_amt,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : smvk
  ||  Created On : 24-AUG-2003
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

    DELETE FROM igs_fi_pp_tmpl_lns
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_fi_pp_tmpl_lns_pkg;

/
