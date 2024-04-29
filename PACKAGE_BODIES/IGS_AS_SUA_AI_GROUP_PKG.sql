--------------------------------------------------------
--  DDL for Package Body IGS_AS_SUA_AI_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AS_SUA_AI_GROUP_PKG" AS
/* $Header: IGSDI83B.pls 120.0 2005/07/05 13:03:38 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_as_sua_ai_group%ROWTYPE;
  new_references igs_as_sua_ai_group%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sua_ass_item_group_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_us_ass_item_group_id              IN     NUMBER,
    x_logical_delete_date               IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_as_sua_ai_group
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
    new_references.sua_ass_item_group_id             := x_sua_ass_item_group_id;
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.uoo_id                            := x_uoo_id;
    new_references.group_name                        := x_group_name;
    new_references.midterm_formula_code              := x_midterm_formula_code;
    new_references.midterm_formula_qty               := x_midterm_formula_qty;
    new_references.midterm_weight_qty                := x_midterm_weight_qty;
    new_references.final_formula_code                := x_final_formula_code;
    new_references.final_formula_qty                 := x_final_formula_qty;
    new_references.final_weight_qty                  := x_final_weight_qty;
    new_references.unit_ass_item_group_id            := x_unit_ass_item_group_id;
    new_references.us_ass_item_group_id              := x_us_ass_item_group_id;
    new_references.logical_delete_date               := x_logical_delete_date;

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
  ||  Created On : 10-OCT-2003
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.course_cd,
           new_references.uoo_id,
           new_references.group_name
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
    igs_as_su_atmpt_itm_pkg.get_fk_igs_as_sua_ai_group (
      old_references.sua_ass_item_group_id
    );
    igs_as_suaai_ouhist_pkg.get_fk_igs_as_sua_ai_group (
      old_references.sua_ass_item_group_id
    );
  END check_child_existance;

  PROCEDURE check_parent_existance AS
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

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd) AND
         (old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL) OR
         (new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_en_su_attempt_pkg.get_pk_for_validation (
                new_references.person_id,
                new_references.course_cd,
                new_references.uoo_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_ass_item_group_id = new_references.unit_ass_item_group_id)) OR
        ((new_references.unit_ass_item_group_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_unit_ai_grp_pkg.get_pk_for_validation (
                new_references.unit_ass_item_group_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.us_ass_item_group_id = new_references.us_ass_item_group_id)) OR
        ((new_references.us_ass_item_group_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_as_us_ai_group_pkg.get_pk_for_validation (
                new_references.us_ass_item_group_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_sua_ass_item_group_id             IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_sua_ai_group
      WHERE    sua_ass_item_group_id = x_sua_ass_item_group_id
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
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_group_name                        IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_sua_ai_group
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      uoo_id = x_uoo_id
      AND      group_name = x_group_name
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


  PROCEDURE get_fk_igs_en_su_attempt (
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_sua_ai_group
      WHERE   ((course_cd = x_course_cd) AND
               (person_id = x_person_id) AND
               (uoo_id = x_uoo_id));

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

  END get_fk_igs_en_su_attempt;


  PROCEDURE get_fk_igs_as_unit_ai_grp (
    x_unit_ass_item_group_id            IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_sua_ai_group
      WHERE   ((unit_ass_item_group_id = x_unit_ass_item_group_id));

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

  END get_fk_igs_as_unit_ai_grp;


  PROCEDURE get_fk_igs_as_us_ai_group (
    x_us_ass_item_group_id              IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_as_sua_ai_group
      WHERE   ((us_ass_item_group_id = x_us_ass_item_group_id));

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

  END get_fk_igs_as_us_ai_group;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sua_ass_item_group_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_us_ass_item_group_id              IN     NUMBER,
    x_logical_delete_date               IN     DATE,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
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
      x_sua_ass_item_group_id,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_group_name,
      x_midterm_formula_code,
      x_midterm_formula_qty,
      x_midterm_weight_qty,
      x_final_formula_code,
      x_final_formula_qty,
      x_final_weight_qty,
      x_unit_ass_item_group_id,
      x_us_ass_item_group_id,
      x_logical_delete_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.sua_ass_item_group_id
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
             new_references.sua_ass_item_group_id
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

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sua_ass_item_group_id             IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_us_ass_item_group_id              IN     NUMBER,
    x_logical_delete_date               IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_AS_SUA_AI_GROUP_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_sua_ass_item_group_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sua_ass_item_group_id             => x_sua_ass_item_group_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_group_name                        => x_group_name,
      x_midterm_formula_code              => x_midterm_formula_code,
      x_midterm_formula_qty               => x_midterm_formula_qty,
      x_midterm_weight_qty                => x_midterm_weight_qty,
      x_final_formula_code                => x_final_formula_code,
      x_final_formula_qty                 => x_final_formula_qty,
      x_final_weight_qty                  => x_final_weight_qty,
      x_unit_ass_item_group_id            => x_unit_ass_item_group_id,
      x_us_ass_item_group_id              => x_us_ass_item_group_id,
      x_logical_delete_date               => x_logical_delete_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  INSERT INTO igs_as_sua_ai_group (
      sua_ass_item_group_id,
      person_id,
      course_cd,
      uoo_id,
      group_name,
      midterm_formula_code,
      midterm_formula_qty,
      midterm_weight_qty,
      final_formula_code,
      final_formula_qty,
      final_weight_qty,
      unit_ass_item_group_id,
      us_ass_item_group_id,
      logical_delete_date,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_as_sua_ai_group_s.NEXTVAL,
      new_references.person_id,
      new_references.course_cd,
      new_references.uoo_id,
      new_references.group_name,
      new_references.midterm_formula_code,
      new_references.midterm_formula_qty,
      new_references.midterm_weight_qty,
      new_references.final_formula_code,
      new_references.final_formula_qty,
      new_references.final_weight_qty,
      new_references.unit_ass_item_group_id,
      new_references.us_ass_item_group_id,
      new_references.logical_delete_date,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, sua_ass_item_group_id INTO x_rowid, x_sua_ass_item_group_id;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

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
    x_sua_ass_item_group_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_us_ass_item_group_id              IN     NUMBER,
    x_logical_delete_date               IN     DATE
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        course_cd,
        uoo_id,
        group_name,
        midterm_formula_code,
        midterm_formula_qty,
        midterm_weight_qty,
        final_formula_code,
        final_formula_qty,
        final_weight_qty,
        unit_ass_item_group_id,
        us_ass_item_group_id,
        logical_delete_date
      FROM  igs_as_sua_ai_group
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
        (tlinfo.person_id = x_person_id)
        AND (tlinfo.course_cd = x_course_cd)
        AND (tlinfo.uoo_id = x_uoo_id)
        AND (tlinfo.group_name = x_group_name)
        AND ((tlinfo.midterm_formula_code = x_midterm_formula_code) OR ((tlinfo.midterm_formula_code IS NULL) AND (X_midterm_formula_code IS NULL)))
        AND ((tlinfo.midterm_formula_qty = x_midterm_formula_qty) OR ((tlinfo.midterm_formula_qty IS NULL) AND (X_midterm_formula_qty IS NULL)))
        AND ((tlinfo.midterm_weight_qty = x_midterm_weight_qty) OR ((tlinfo.midterm_weight_qty IS NULL) AND (X_midterm_weight_qty IS NULL)))
        AND ((tlinfo.final_formula_code = x_final_formula_code) OR ((tlinfo.final_formula_code IS NULL) AND (X_final_formula_code IS NULL)))
        AND ((tlinfo.final_formula_qty = x_final_formula_qty) OR ((tlinfo.final_formula_qty IS NULL) AND (X_final_formula_qty IS NULL)))
        AND ((tlinfo.final_weight_qty = x_final_weight_qty) OR ((tlinfo.final_weight_qty IS NULL) AND (X_final_weight_qty IS NULL)))
        AND ((tlinfo.unit_ass_item_group_id = x_unit_ass_item_group_id) OR ((tlinfo.unit_ass_item_group_id IS NULL) AND (X_unit_ass_item_group_id IS NULL)))
        AND ((tlinfo.us_ass_item_group_id = x_us_ass_item_group_id) OR ((tlinfo.us_ass_item_group_id IS NULL) AND (X_us_ass_item_group_id IS NULL)))
        AND ((tlinfo.logical_delete_date = x_logical_delete_date) OR ((tlinfo.logical_delete_date IS NULL) AND (x_logical_delete_date IS NULL)))
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
    x_sua_ass_item_group_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_us_ass_item_group_id              IN     NUMBER,
    x_logical_delete_date               IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_AS_SUA_AI_GROUP_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_sua_ass_item_group_id             => x_sua_ass_item_group_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_uoo_id                            => x_uoo_id,
      x_group_name                        => x_group_name,
      x_midterm_formula_code              => x_midterm_formula_code,
      x_midterm_formula_qty               => x_midterm_formula_qty,
      x_midterm_weight_qty                => x_midterm_weight_qty,
      x_final_formula_code                => x_final_formula_code,
      x_final_formula_qty                 => x_final_formula_qty,
      x_final_weight_qty                  => x_final_weight_qty,
      x_unit_ass_item_group_id            => x_unit_ass_item_group_id,
      x_us_ass_item_group_id              => x_us_ass_item_group_id,
      x_logical_delete_date               => x_logical_delete_date,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  UPDATE igs_as_sua_ai_group
      SET
        person_id                         = new_references.person_id,
        course_cd                         = new_references.course_cd,
        uoo_id                            = new_references.uoo_id,
        group_name                        = new_references.group_name,
        midterm_formula_code              = new_references.midterm_formula_code,
        midterm_formula_qty               = new_references.midterm_formula_qty,
        midterm_weight_qty                = new_references.midterm_weight_qty,
        final_formula_code                = new_references.final_formula_code,
        final_formula_qty                 = new_references.final_formula_qty,
        final_weight_qty                  = new_references.final_weight_qty,
        unit_ass_item_group_id            = new_references.unit_ass_item_group_id,
        us_ass_item_group_id              = new_references.us_ass_item_group_id,
        logical_delete_date               = new_references.logical_delete_date,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
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
    x_sua_ass_item_group_id             IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_uoo_id                            IN     NUMBER,
    x_group_name                        IN     VARCHAR2,
    x_midterm_formula_code              IN     VARCHAR2,
    x_midterm_formula_qty               IN     NUMBER,
    x_midterm_weight_qty                IN     NUMBER,
    x_final_formula_code                IN     VARCHAR2,
    x_final_formula_qty                 IN     NUMBER,
    x_final_weight_qty                  IN     NUMBER,
    x_unit_ass_item_group_id            IN     NUMBER,
    x_us_ass_item_group_id              IN     NUMBER,
    x_logical_delete_date               IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_as_sua_ai_group
      WHERE    sua_ass_item_group_id             = x_sua_ass_item_group_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sua_ass_item_group_id,
        x_person_id,
        x_course_cd,
        x_uoo_id,
        x_group_name,
        x_midterm_formula_code,
        x_midterm_formula_qty,
        x_midterm_weight_qty,
        x_final_formula_code,
        x_final_formula_qty,
        x_final_weight_qty,
        x_unit_ass_item_group_id,
        x_us_ass_item_group_id,
        x_logical_delete_date,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sua_ass_item_group_id,
      x_person_id,
      x_course_cd,
      x_uoo_id,
      x_group_name,
      x_midterm_formula_code,
      x_midterm_formula_qty,
      x_midterm_weight_qty,
      x_final_formula_code,
      x_final_formula_qty,
      x_final_weight_qty,
      x_unit_ass_item_group_id,
      x_us_ass_item_group_id,
      x_logical_delete_date,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 10-OCT-2003
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
  DELETE FROM igs_as_sua_ai_group
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


END igs_as_sua_ai_group_pkg;

/
