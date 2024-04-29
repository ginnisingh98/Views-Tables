--------------------------------------------------------
--  DDL for Package Body IGF_SP_PRG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_SP_PRG_PKG" AS
/* $Header: IGFPI02B.pls 115.2 2003/03/19 08:49:48 smadathi noship $ */

  l_rowid VARCHAR2(25);
  old_references igf_sp_prg_all%ROWTYPE;
  new_references igf_sp_prg_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fee_cls_prg_id                    IN     NUMBER      DEFAULT NULL,
    x_fee_cls_id                        IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_fee_percent                       IN     NUMBER      DEFAULT NULL,
    x_max_amount                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igf_sp_prg_all
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
    new_references.fee_cls_prg_id                    := x_fee_cls_prg_id;
    new_references.fee_cls_id                        := x_fee_cls_id;
    new_references.course_cd                         := x_course_cd;
    new_references.version_number                    := x_version_number;
    new_references.fee_percent                       := x_fee_percent;
    new_references.max_amount                        := x_max_amount;

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
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.fee_cls_id,
           new_references.course_cd,
           new_references.version_number
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.fee_cls_id = new_references.fee_cls_id)) OR
        ((new_references.fee_cls_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_sp_fc_pkg.get_pk_for_validation (
                new_references.fee_cls_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.course_cd      = new_references.course_cd)       AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
	 (new_references.version_number IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_ver_pkg.get_pk_for_validation (
                new_references.course_cd,
                new_references.version_number
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igf_sp_unit_pkg.get_fk_igf_sp_prg (
      old_references.fee_cls_prg_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_fee_cls_prg_id                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sp_prg_all
      WHERE    fee_cls_prg_id = x_fee_cls_prg_id
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
    x_fee_cls_id                        IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sp_prg_all
      WHERE    fee_cls_id = x_fee_cls_id
      AND      course_cd = x_course_cd
      AND      version_number = x_version_number
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


  PROCEDURE get_fk_igf_sp_fc (
    x_fee_cls_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sp_prg_all
      WHERE   ((fee_cls_id = x_fee_cls_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SP_SFCLP_SFCL_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_sp_fc;

  PROCEDURE get_fk_igs_ps_ver (
    x_course_cd                        IN VARCHAR2,
    x_version_number		       IN NUMBER
  ) AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_sp_prg_all
      WHERE  (  course_cd = x_course_cd
        AND    version_number = x_version_number );

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_SP_SFCLP_CRV_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_ver;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_fee_cls_prg_id                    IN     NUMBER      DEFAULT NULL,
    x_fee_cls_id                        IN     NUMBER      DEFAULT NULL,
    x_course_cd                         IN     VARCHAR2    DEFAULT NULL,
    x_version_number                    IN     NUMBER      DEFAULT NULL,
    x_fee_percent                       IN     NUMBER      DEFAULT NULL,
    x_max_amount                        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||   smadathi    18-FEB-2003     Bug 2473845. Added logic to re initialize l_rowid to null
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_fee_cls_prg_id,
      x_fee_cls_id,
      x_course_cd,
      x_version_number,
      x_fee_percent,
      x_max_amount,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.fee_cls_prg_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.fee_cls_prg_id
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
      check_child_existance;
    END IF;
    l_rowid := NULL;
  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_fee_cls_prg_id                    IN OUT NOCOPY NUMBER,
    x_fee_cls_id                        IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_fee_percent                       IN     NUMBER,
    x_max_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_sp_prg_all
      WHERE    fee_cls_prg_id                    = x_fee_cls_prg_id;

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

    SELECT    igf_sp_prg_s.NEXTVAL
    INTO      x_fee_cls_prg_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_fee_cls_prg_id                    => x_fee_cls_prg_id,
      x_fee_cls_id                        => x_fee_cls_id,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_fee_percent                       => x_fee_percent,
      x_max_amount                        => x_max_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igf_sp_prg_all (
      fee_cls_prg_id,
      fee_cls_id,
      course_cd,
      version_number,
      fee_percent,
      max_amount,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.fee_cls_prg_id,
      new_references.fee_cls_id,
      new_references.course_cd,
      new_references.version_number,
      new_references.fee_percent,
      new_references.max_amount,
      new_references.org_id,
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
    x_fee_cls_prg_id                    IN     NUMBER,
    x_fee_cls_id                        IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_fee_percent                       IN     NUMBER,
    x_max_amount                        IN     NUMBER
  ) AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        fee_cls_id,
        course_cd,
        version_number,
        fee_percent,
        max_amount
      FROM  igf_sp_prg_all
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
        (tlinfo.fee_cls_id = x_fee_cls_id)
        AND (tlinfo.course_cd = x_course_cd)
        AND (tlinfo.version_number = x_version_number)
        AND ((tlinfo.fee_percent = x_fee_percent) OR ((tlinfo.fee_percent IS NULL) AND (X_fee_percent IS NULL)))
        AND ((tlinfo.max_amount = x_max_amount) OR ((tlinfo.max_amount IS NULL) AND (X_max_amount IS NULL)))
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
    x_fee_cls_prg_id                    IN     NUMBER,
    x_fee_cls_id                        IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_fee_percent                       IN     NUMBER,
    x_max_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
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
      x_fee_cls_prg_id                    => x_fee_cls_prg_id,
      x_fee_cls_id                        => x_fee_cls_id,
      x_course_cd                         => x_course_cd,
      x_version_number                    => x_version_number,
      x_fee_percent                       => x_fee_percent,
      x_max_amount                        => x_max_amount,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igf_sp_prg_all
      SET
        fee_cls_id                        = new_references.fee_cls_id,
        course_cd                         = new_references.course_cd,
        version_number                    = new_references.version_number,
        fee_percent                       = new_references.fee_percent,
        max_amount                        = new_references.max_amount,
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
    x_fee_cls_prg_id                    IN OUT NOCOPY NUMBER,
    x_fee_cls_id                        IN     NUMBER,
    x_course_cd                         IN     VARCHAR2,
    x_version_number                    IN     NUMBER,
    x_fee_percent                       IN     NUMBER,
    x_max_amount                        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_sp_prg_all
      WHERE    fee_cls_prg_id                    = x_fee_cls_prg_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_fee_cls_prg_id,
        x_fee_cls_id,
        x_course_cd,
        x_version_number,
        x_fee_percent,
        x_max_amount,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_fee_cls_prg_id,
      x_fee_cls_id,
      x_course_cd,
      x_version_number,
      x_fee_percent,
      x_max_amount,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Rakesh Singh
  ||  Created On : 28-DEC-2001
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

    DELETE FROM igf_sp_prg_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_sp_prg_pkg;

/
