--------------------------------------------------------
--  DDL for Package Body IGS_AS_UNIT_AI_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_UNIT_AI_GRP_PKG" AS
/* $Header: IGSDI81B.pls 115.0 2003/12/05 10:39:40 kdande noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_as_unit_ai_grp%ROWTYPE;
  new_references igs_as_unit_ai_grp%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_as_unit_ai_grp
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
    new_references.unit_ass_item_group_id            := x_unit_ass_item_group_id;
    new_references.unit_cd                           := x_unit_cd;
    new_references.version_number                    := x_version_number;
    new_references.cal_type                          := x_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.group_name                        := x_group_name;
    new_references.midterm_formula_code              := x_midterm_formula_code;
    new_references.midterm_formula_qty               := x_midterm_formula_qty;
    new_references.midterm_weight_qty                := x_midterm_weight_qty;
    new_references.final_formula_code                := x_final_formula_code;
    new_references.final_formula_qty                 := x_final_formula_qty;
    new_references.final_weight_qty                  := x_final_weight_qty;

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
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.group_name,
           new_references.unit_cd,
           new_references.version_number,
           new_references.cal_type,
           new_references.ci_sequence_number
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_child_existance AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    igs_as_unitass_item_pkg.get_fk_igs_as_unit_ai_grp (
      old_references.unit_ass_item_group_id
      );
  END check_child_existance;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.cal_type = new_references.cal_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.cal_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ofr_pat_pkg.get_pk_for_validation (
                new_references.unit_cd,
                new_references.version_number,
                new_references.cal_type,
                new_references.ci_sequence_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_unit_ass_item_group_id            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_unit_ai_grp
      WHERE    unit_ass_item_group_id = x_unit_ass_item_group_id
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
    x_group_name                        IN     VARCHAR2,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_unit_ai_grp
      WHERE    group_name = x_group_name
      AND      unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      cal_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number
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


  PROCEDURE get_fk_igs_ps_unit_ofr_pat (
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_unit_ai_grp
      WHERE   ((cal_type = x_cal_type) AND
               (ci_sequence_number = x_ci_sequence_number) AND
               (unit_cd = x_unit_cd) AND
               (version_number = x_version_number));

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

  END get_fk_igs_ps_unit_ofr_pat;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
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
      x_unit_ass_item_group_id,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_group_name,
      x_midterm_formula_code,
      x_midterm_formula_qty,
      x_midterm_weight_qty,
      x_final_formula_code,
      x_final_formula_qty,
      x_final_weight_qty,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.unit_ass_item_group_id
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
             new_references.unit_ass_item_group_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

    IF (p_action IN ('VALIDATE_INSERT', 'VALIDATE_UPDATE', 'VALIDATE_DELETE')) THEN
      l_rowid := NULL;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_ass_item_group_id            IN OUT NOCOPY NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_AS_UNIT_AI_GRP_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_unit_ass_item_group_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_unit_ass_item_group_id            => x_unit_ass_item_group_id,
      x_unit_cd                           => x_unit_cd,
      x_version_number                    => x_version_number,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_group_name                        => x_group_name,
      x_midterm_formula_code              => x_midterm_formula_code,
      x_midterm_formula_qty               => x_midterm_formula_qty,
      x_midterm_weight_qty                => x_midterm_weight_qty,
      x_final_formula_code                => x_final_formula_code,
      x_final_formula_qty                 => x_final_formula_qty,
      x_final_weight_qty                  => x_final_weight_qty,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_as_unit_ai_grp (
      unit_ass_item_group_id,
      unit_cd,
      version_number,
      cal_type,
      ci_sequence_number,
      group_name,
      midterm_formula_code,
      midterm_formula_qty,
      midterm_weight_qty,
      final_formula_code,
      final_formula_qty,
      final_weight_qty,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_as_unit_ai_grp_s.NEXTVAL,
      new_references.unit_cd,
      new_references.version_number,
      new_references.cal_type,
      new_references.ci_sequence_number,
      new_references.group_name,
      new_references.midterm_formula_code,
      new_references.midterm_formula_qty,
      new_references.midterm_weight_qty,
      new_references.final_formula_code,
      new_references.final_formula_qty,
      new_references.final_weight_qty,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, unit_ass_item_group_id INTO x_rowid, x_unit_ass_item_group_id;

    l_rowid := NULL;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        unit_cd,
        version_number,
        cal_type,
        ci_sequence_number,
        group_name,
        midterm_formula_code,
        midterm_formula_qty,
        midterm_weight_qty,
        final_formula_code,
        final_formula_qty,
        final_weight_qty
      FROM  igs_as_unit_ai_grp
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
        (tlinfo.unit_cd = x_unit_cd)
        AND (tlinfo.version_number = x_version_number)
        AND (tlinfo.cal_type = x_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
        AND (tlinfo.group_name = x_group_name)
        AND ((tlinfo.midterm_formula_code = x_midterm_formula_code) OR ((tlinfo.midterm_formula_code IS NULL) AND (X_midterm_formula_code IS NULL)))
        AND ((tlinfo.midterm_formula_qty = x_midterm_formula_qty) OR ((tlinfo.midterm_formula_qty IS NULL) AND (X_midterm_formula_qty IS NULL)))
        AND ((tlinfo.midterm_weight_qty = x_midterm_weight_qty) OR ((tlinfo.midterm_weight_qty IS NULL) AND (X_midterm_weight_qty IS NULL)))
        AND ((tlinfo.final_formula_code = x_final_formula_code) OR ((tlinfo.final_formula_code IS NULL) AND (X_final_formula_code IS NULL)))
        AND ((tlinfo.final_formula_qty = x_final_formula_qty) OR ((tlinfo.final_formula_qty IS NULL) AND (X_final_formula_qty IS NULL)))
        AND ((tlinfo.final_weight_qty = x_final_weight_qty) OR ((tlinfo.final_weight_qty IS NULL) AND (X_final_weight_qty IS NULL)))
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
    x_unit_ass_item_group_id            IN     NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_AS_UNIT_AI_GRP_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_unit_ass_item_group_id            => x_unit_ass_item_group_id,
      x_unit_cd                           => x_unit_cd,
      x_version_number                    => x_version_number,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_group_name                        => x_group_name,
      x_midterm_formula_code              => x_midterm_formula_code,
      x_midterm_formula_qty               => x_midterm_formula_qty,
      x_midterm_weight_qty                => x_midterm_weight_qty,
      x_final_formula_code                => x_final_formula_code,
      x_final_formula_qty                 => x_final_formula_qty,
      x_final_weight_qty                  => x_final_weight_qty,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_as_unit_ai_grp
      SET
        unit_cd                           = new_references.unit_cd,
        version_number                    = new_references.version_number,
        cal_type                          = new_references.cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        group_name                        = new_references.group_name,
        midterm_formula_code              = new_references.midterm_formula_code,
        midterm_formula_qty               = new_references.midterm_formula_qty,
        midterm_weight_qty                = new_references.midterm_weight_qty,
        final_formula_code                = new_references.final_formula_code,
        final_formula_qty                 = new_references.final_formula_qty,
        final_weight_qty                  = new_references.final_weight_qty,
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
    x_unit_ass_item_group_id            IN OUT NOCOPY NUMBER,
    x_unit_cd                           IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_as_unit_ai_grp
      WHERE    unit_ass_item_group_id            = x_unit_ass_item_group_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_unit_ass_item_group_id,
        x_unit_cd,
        x_version_number,
        x_cal_type,
        x_ci_sequence_number,
        x_group_name,
        x_midterm_formula_code,
        x_midterm_formula_qty,
        x_midterm_weight_qty,
        x_final_formula_code,
        x_final_formula_qty,
        x_final_weight_qty,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_unit_ass_item_group_id,
      x_unit_cd,
      x_version_number,
      x_cal_type,
      x_ci_sequence_number,
      x_group_name,
      x_midterm_formula_code,
      x_midterm_formula_qty,
      x_midterm_weight_qty,
      x_final_formula_code,
      x_final_formula_qty,
      x_final_weight_qty,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 01-OCT-2003
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

    DELETE FROM igs_as_unit_ai_grp
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

    l_rowid := NULL;

  END delete_row;


END igs_as_unit_ai_grp_pkg;

/
