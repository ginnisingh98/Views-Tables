--------------------------------------------------------
--  DDL for Package Body IGF_AW_FISAP_II_H_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AW_FISAP_II_H_PKG" AS
/* $Header: IGFWI44B.pls 115.5 2002/11/28 14:42:52 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_aw_fisap_ii_h%ROWTYPE;
  new_references igf_aw_fisap_ii_h%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fisap_id                          IN     NUMBER      DEFAULT NULL,
    x_category_id                       IN     NUMBER      DEFAULT NULL,
    x_fisap_section                     IN     VARCHAR2    DEFAULT NULL,
    x_depend_stat                       IN     VARCHAR2    DEFAULT NULL,
    x_class_standing                    IN     VARCHAR2    DEFAULT NULL,
    x_student_count                     IN     NUMBER      DEFAULT NULL,
    x_auto_efc                          IN     VARCHAR2    DEFAULT NULL,
    x_minvalue                          IN     NUMBER      DEFAULT NULL,
    x_maxvalue                          IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AW_FISAP_II_H
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
    new_references.fisap_id                          := x_fisap_id;
    new_references.category_id                       := x_category_id;
    new_references.fisap_section                     := x_fisap_section;
    new_references.depend_stat                       := x_depend_stat;
    new_references.class_standing                    := x_class_standing;
    new_references.student_count                     := x_student_count;
    new_references.auto_efc                          := x_auto_efc;
    new_references.minvalue                          := x_minvalue;
    new_references.maxvalue                          := x_maxvalue;
    new_references.ci_cal_type                       := x_ci_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;

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
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.category_id = new_references.category_id)) OR
        ((new_references.category_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_aw_fisap_repset_pkg.get_pk_for_validation (
                new_references.category_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_fisap_id                          IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fisap_ii_h
      WHERE    fisap_id = x_fisap_id
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


  PROCEDURE get_fk_igf_aw_fisap_repset (
    x_category_id                       IN     NUMBER
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_aw_fisap_ii_h
      WHERE   ((category_id = x_category_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AW_FISIIH_FISET_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_aw_fisap_repset;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fisap_id                          IN     NUMBER      DEFAULT NULL,
    x_category_id                       IN     NUMBER      DEFAULT NULL,
    x_fisap_section                     IN     VARCHAR2    DEFAULT NULL,
    x_depend_stat                       IN     VARCHAR2    DEFAULT NULL,
    x_class_standing                    IN     VARCHAR2    DEFAULT NULL,
    x_student_count                     IN     NUMBER      DEFAULT NULL,
    x_auto_efc                          IN     VARCHAR2    DEFAULT NULL,
    x_minvalue                          IN     NUMBER      DEFAULT NULL,
    x_maxvalue                          IN     NUMBER      DEFAULT NULL,
    x_ci_cal_type                       IN     VARCHAR2    DEFAULT NULL,
    x_ci_sequence_number                IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
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
      x_fisap_id,
      x_category_id,
      x_fisap_section,
      x_depend_stat,
      x_class_standing,
      x_student_count,
      x_auto_efc,
      x_minvalue,
      x_maxvalue,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.fisap_id
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
             new_references.fisap_id
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
    x_fisap_id                          IN OUT NOCOPY NUMBER,
    x_category_id                       IN     NUMBER,
    x_fisap_section                     IN     VARCHAR2,
    x_depend_stat                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_student_count                     IN     NUMBER,
    x_auto_efc                          IN     VARCHAR2,
    x_minvalue                          IN     NUMBER,
    x_maxvalue                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_aw_fisap_ii_h
      WHERE    fisap_id                          = x_fisap_id;

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

    SELECT    igf_aw_fisap_ii_h_s.NEXTVAL
    INTO      x_fisap_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_fisap_id                          => x_fisap_id,
      x_category_id                       => x_category_id,
      x_fisap_section                     => x_fisap_section,
      x_depend_stat                       => x_depend_stat,
      x_class_standing                    => x_class_standing,
      x_student_count                     => x_student_count,
      x_auto_efc                          => x_auto_efc,
      x_minvalue                          => x_minvalue,
      x_maxvalue                          => x_maxvalue,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_aw_fisap_ii_h (
      fisap_id,
      category_id,
      fisap_section,
      depend_stat,
      class_standing,
      student_count,
      auto_efc,
      minvalue,
      maxvalue,
      ci_cal_type,
      ci_sequence_number,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.fisap_id,
      new_references.category_id,
      new_references.fisap_section,
      new_references.depend_stat,
      new_references.class_standing,
      new_references.student_count,
      new_references.auto_efc,
      new_references.minvalue,
      new_references.maxvalue,
      new_references.ci_cal_type,
      new_references.ci_sequence_number,
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
    x_fisap_id                          IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_fisap_section                     IN     VARCHAR2,
    x_depend_stat                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_student_count                     IN     NUMBER,
    x_auto_efc                          IN     VARCHAR2,
    x_minvalue                          IN     NUMBER,
    x_maxvalue                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        category_id,
        fisap_section,
        depend_stat,
        class_standing,
        student_count,
        auto_efc,
        minvalue,
        maxvalue,
        ci_cal_type,
        ci_sequence_number
      FROM  igf_aw_fisap_ii_h
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
        ((tlinfo.category_id = x_category_id) OR ((tlinfo.category_id IS NULL) AND (X_category_id IS NULL)))
        AND ((tlinfo.fisap_section = x_fisap_section) OR ((tlinfo.fisap_section IS NULL) AND (X_fisap_section IS NULL)))
        AND ((tlinfo.depend_stat = x_depend_stat) OR ((tlinfo.depend_stat IS NULL) AND (X_depend_stat IS NULL)))
        AND ((tlinfo.class_standing = x_class_standing) OR ((tlinfo.class_standing IS NULL) AND (X_class_standing IS NULL)))
        AND ((tlinfo.student_count = x_student_count) OR ((tlinfo.student_count IS NULL) AND (X_student_count IS NULL)))
        AND (tlinfo.auto_efc = x_auto_efc)
        AND ((tlinfo.minvalue = x_minvalue) OR ((tlinfo.minvalue IS NULL) AND (X_minvalue IS NULL)))
        AND ((tlinfo.maxvalue = x_maxvalue) OR ((tlinfo.maxvalue IS NULL) AND (X_maxvalue IS NULL)))
        AND (tlinfo.ci_cal_type = x_ci_cal_type)
        AND (tlinfo.ci_sequence_number = x_ci_sequence_number)
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
    x_fisap_id                          IN     NUMBER,
    x_category_id                       IN     NUMBER,
    x_fisap_section                     IN     VARCHAR2,
    x_depend_stat                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_student_count                     IN     NUMBER,
    x_auto_efc                          IN     VARCHAR2,
    x_minvalue                          IN     NUMBER,
    x_maxvalue                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
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
      x_fisap_id                          => x_fisap_id,
      x_category_id                       => x_category_id,
      x_fisap_section                     => x_fisap_section,
      x_depend_stat                       => x_depend_stat,
      x_class_standing                    => x_class_standing,
      x_student_count                     => x_student_count,
      x_auto_efc                          => x_auto_efc,
      x_minvalue                          => x_minvalue,
      x_maxvalue                          => x_maxvalue,
      x_ci_cal_type                       => x_ci_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_aw_fisap_ii_h
      SET
        category_id                       = new_references.category_id,
        fisap_section                     = new_references.fisap_section,
        depend_stat                       = new_references.depend_stat,
        class_standing                    = new_references.class_standing,
        student_count                     = new_references.student_count,
        auto_efc                          = new_references.auto_efc,
        minvalue                          = new_references.minvalue,
        maxvalue                          = new_references.maxvalue,
        ci_cal_type                       = new_references.ci_cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
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
    x_fisap_id                          IN OUT NOCOPY NUMBER,
    x_category_id                       IN     NUMBER,
    x_fisap_section                     IN     VARCHAR2,
    x_depend_stat                       IN     VARCHAR2,
    x_class_standing                    IN     VARCHAR2,
    x_student_count                     IN     NUMBER,
    x_auto_efc                          IN     VARCHAR2,
    x_minvalue                          IN     NUMBER,
    x_maxvalue                          IN     NUMBER,
    x_ci_cal_type                       IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_aw_fisap_ii_h
      WHERE    fisap_id                          = x_fisap_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_fisap_id,
        x_category_id,
        x_fisap_section,
        x_depend_stat,
        x_class_standing,
        x_student_count,
        x_auto_efc,
        x_minvalue,
        x_maxvalue,
        x_ci_cal_type,
        x_ci_sequence_number,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_fisap_id,
      x_category_id,
      x_fisap_section,
      x_depend_stat,
      x_class_standing,
      x_student_count,
      x_auto_efc,
      x_minvalue,
      x_maxvalue,
      x_ci_cal_type,
      x_ci_sequence_number,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : ssawhney
  ||  Created On : 22-OCT-2001
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

    DELETE FROM igf_aw_fisap_ii_h
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_aw_fisap_ii_h_pkg;

/
