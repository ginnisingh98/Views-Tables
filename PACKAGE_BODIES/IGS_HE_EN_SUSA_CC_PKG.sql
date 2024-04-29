--------------------------------------------------------
--  DDL for Package Body IGS_HE_EN_SUSA_CC_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_EN_SUSA_CC_PKG" AS
/* $Header: IGSWI44B.pls 120.2 2005/07/03 18:46:50 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_en_susa_cc%ROWTYPE;
  new_references igs_he_en_susa_cc%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_he_susa_cc_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 02-SEP-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_he_en_susa_cc
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
    new_references.he_susa_cc_id                     := x_he_susa_cc_id;
    new_references.person_id                         := x_person_id;
    new_references.course_cd                         := x_course_cd;
    new_references.unit_set_cd                       := x_unit_set_cd;
    new_references.sequence_number                   := x_sequence_number;
    new_references.cost_centre                       := x_cost_centre;
    new_references.subject                           := x_subject;
    new_references.proportion                        := x_proportion;

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
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 02-SEP-2003
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
           new_references.unit_set_cd,
           new_references.sequence_number,
           new_references.cost_centre,
           new_references.subject
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  FUNCTION get_pk_for_validation (
    x_he_susa_cc_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 02-SEP-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_en_susa_cc
      WHERE    he_susa_cc_id = x_he_susa_cc_id
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
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 02-SEP-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_en_susa_cc
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      unit_set_cd = x_unit_set_cd
      AND      sequence_number = x_sequence_number
      AND      cost_centre = x_cost_centre
      AND      subject = x_subject
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
    x_he_susa_cc_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 02-SEP-2003
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
      x_he_susa_cc_id,
      x_person_id,
      x_course_cd,
      x_unit_set_cd,
      x_sequence_number,
      x_cost_centre,
      x_subject,
      x_proportion,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.he_susa_cc_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.he_susa_cc_id
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

    IF (p_action IN ('VALIDATE_INSERT', 'VALIDATE_UPDATE', 'VALIDATE_DELETE')) THEN
      l_rowid := NULL;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_he_susa_cc_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 02-SEP-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_EN_SUSA_CC_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_he_susa_cc_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_he_susa_cc_id                     => x_he_susa_cc_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_unit_set_cd                       => x_unit_set_cd,
      x_sequence_number                   => x_sequence_number,
      x_cost_centre                       => x_cost_centre,
      x_subject                           => x_subject,
      x_proportion                        => x_proportion,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_he_en_susa_cc (
      he_susa_cc_id,
      person_id,
      course_cd,
      unit_set_cd,
      sequence_number,
      cost_centre,
      subject,
      proportion,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_he_en_susa_cc_s.NEXTVAL,
      new_references.person_id,
      new_references.course_cd,
      new_references.unit_set_cd,
      new_references.sequence_number,
      new_references.cost_centre,
      new_references.subject,
      new_references.proportion,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID, he_susa_cc_id INTO x_rowid, x_he_susa_cc_id;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    l_rowid := NULL;


EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
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
    x_he_susa_cc_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_proportion                        IN     NUMBER
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 02-SEP-2003
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
        unit_set_cd,
        sequence_number,
        cost_centre,
        subject,
        proportion
      FROM  igs_he_en_susa_cc
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
        AND (tlinfo.unit_set_cd = x_unit_set_cd)
        AND (tlinfo.sequence_number = x_sequence_number)
        AND (tlinfo.cost_centre = x_cost_centre)
        AND (tlinfo.subject = x_subject)
        AND (tlinfo.proportion = x_proportion)
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
    x_he_susa_cc_id                     IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 02-SEP-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_EN_SUSA_CC_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_he_susa_cc_id                     => x_he_susa_cc_id,
      x_person_id                         => x_person_id,
      x_course_cd                         => x_course_cd,
      x_unit_set_cd                       => x_unit_set_cd,
      x_sequence_number                   => x_sequence_number,
      x_cost_centre                       => x_cost_centre,
      x_subject                           => x_subject,
      x_proportion                        => x_proportion,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_he_en_susa_cc
      SET
        person_id                         = new_references.person_id,
        course_cd                         = new_references.course_cd,
        unit_set_cd                       = new_references.unit_set_cd,
        sequence_number                   = new_references.sequence_number,
        cost_centre                       = new_references.cost_centre,
        subject                           = new_references.subject,
        proportion                        = new_references.proportion,
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


    l_rowid := NULL;

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
    x_he_susa_cc_id                     IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_unit_set_cd                       IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cost_centre                       IN     VARCHAR2,
    x_subject                           IN     VARCHAR2,
    x_proportion                        IN     NUMBER,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 02-SEP-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_en_susa_cc
      WHERE    he_susa_cc_id                     = x_he_susa_cc_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_he_susa_cc_id,
        x_person_id,
        x_course_cd,
        x_unit_set_cd,
        x_sequence_number,
        x_cost_centre,
        x_subject,
        x_proportion,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_he_susa_cc_id,
      x_person_id,
      x_course_cd,
      x_unit_set_cd,
      x_sequence_number,
      x_cost_centre,
      x_subject,
      x_proportion,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : anji.yedubati@oracle.com
  ||  Created On : 02-SEP-2003
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
 DELETE FROM igs_he_en_susa_cc
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


    l_rowid := NULL;

  END delete_row;


END igs_he_en_susa_cc_pkg;

/
