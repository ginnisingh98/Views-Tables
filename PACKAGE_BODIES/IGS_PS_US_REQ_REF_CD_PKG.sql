--------------------------------------------------------
--  DDL for Package Body IGS_PS_US_REQ_REF_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_US_REQ_REF_CD_PKG" AS
/* $Header: IGSPI2TB.pls 115.6 2003/05/09 06:42:28 sarakshi ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_us_req_ref_cd%ROWTYPE;
  new_references igs_ps_us_req_ref_cd%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_unit_section_req_ref_cd_id        IN     NUMBER      DEFAULT NULL,
    x_unit_section_reference_id         IN     NUMBER      DEFAULT NULL,
    x_reference_cd_type                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL ,
    x_reference_code                    IN     VARCHAR2,
    x_reference_code_desc               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_US_REQ_REF_CD
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
    new_references.unit_section_req_ref_cd_id        := x_unit_section_req_ref_cd_id;
    new_references.unit_section_reference_id         := x_unit_section_reference_id;
    new_references.reference_cd_type                 := x_reference_cd_type;
    new_references.reference_code                    := x_reference_code;
    new_references.reference_code_desc               := x_reference_code_desc;

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
  ||  Created On : 25-MAY-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.unit_section_reference_id,
           new_references.reference_cd_type,
           new_references.reference_code
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  CURSOR cur_reference_cd_chk(cp_reference_cd_type igs_ge_ref_cd_type_all.reference_cd_type%TYPE) IS
  SELECT 'X'
  FROM   igs_ge_ref_cd_type_all
  WHERE  restricted_flag='Y'
  AND    reference_cd_type=cp_reference_cd_type;
  l_var  VARCHAR2(1);

  BEGIN

    --Enh#2858431, added as a part of PSP Enhancement build
    OPEN cur_reference_cd_chk(new_references.reference_cd_type);
    FETCH cur_reference_cd_chk INTO l_var;
    IF cur_reference_cd_chk%FOUND THEN
      IF (((old_references.reference_cd_type = new_references.reference_cd_type) AND
         (old_references.reference_code = new_references.reference_code)) OR
        ((new_references.reference_cd_type IS NULL) OR
         (new_references.reference_code IS NULL))) THEN
        NULL;
      ELSIF NOT igs_ge_ref_cd_pkg.get_uk_For_validation (
                  new_references.reference_cd_type,
                  new_references.reference_code
                ) THEN
        CLOSE cur_reference_cd_chk;
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;
    CLOSE cur_reference_cd_chk;


    IF (((old_references.reference_cd_type = new_references.reference_cd_type)) OR
        ((new_references.reference_cd_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ge_ref_cd_type_pkg.get_pk_for_validation (
                new_references.reference_cd_type
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.unit_section_reference_id = new_references.unit_section_reference_id)) OR
        ((new_references.unit_section_reference_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_usec_ref_pkg.get_pk_for_validation (
                new_references.unit_section_reference_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_unit_section_req_ref_cd_id        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_req_ref_cd
      WHERE    unit_section_req_ref_cd_id = x_unit_section_req_ref_cd_id
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
    x_unit_section_reference_id         IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_reference_code                    IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_req_ref_cd
      WHERE    unit_section_reference_id = x_unit_section_reference_id
      AND      reference_cd_type = x_reference_cd_type
      AND      reference_code = x_reference_code
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


  PROCEDURE get_ufk_igs_ge_ref_cd (
    x_reference_cd_type                 IN    VARCHAR2,
    x_reference_code                    IN    VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_req_ref_cd
      WHERE    reference_cd_type = x_reference_cd_type
      AND      reference_code= x_reference_code;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_RC_USRRC_FK1');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ge_ref_cd;


  PROCEDURE get_fk_igs_ge_ref_cd_type (
    x_reference_cd_type                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_req_ref_cd
      WHERE   ((reference_cd_type = x_reference_cd_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_RCT_USRRC_FK2');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ge_ref_cd_type;


  PROCEDURE get_fk_igs_ps_usec_ref (
    x_unit_section_reference_id         IN     NUMBER
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_req_ref_cd
      WHERE   ((unit_section_reference_id = x_unit_section_reference_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PS_USR_USRRC_FK3');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_usec_ref;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_unit_section_req_ref_cd_id        IN     NUMBER      DEFAULT NULL,
    x_unit_section_reference_id         IN     NUMBER      DEFAULT NULL,
    x_reference_cd_type                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_reference_code                    IN     VARCHAR2,
    x_reference_code_desc               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
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
      x_unit_section_req_ref_cd_id,
      x_unit_section_reference_id,
      x_reference_cd_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_reference_code,
      x_reference_code_desc
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.unit_section_req_ref_cd_id
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
             new_references.unit_section_req_ref_cd_id
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

    l_rowid:=NULL;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_section_req_ref_cd_id        IN OUT NOCOPY NUMBER,
    x_unit_section_reference_id         IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_reference_code                    IN     VARCHAR2,
    x_reference_code_desc               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ps_us_req_ref_cd
      WHERE    unit_section_req_ref_cd_id        = x_unit_section_req_ref_cd_id;

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

    SELECT    igs_ps_us_req_ref_cd_s.NEXTVAL
    INTO      x_unit_section_req_ref_cd_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_unit_section_req_ref_cd_id        => x_unit_section_req_ref_cd_id,
      x_unit_section_reference_id         => x_unit_section_reference_id,
      x_reference_cd_type                 => x_reference_cd_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_reference_code                    => x_reference_code,
      x_reference_code_desc               => x_reference_code_desc
    );

    INSERT INTO igs_ps_us_req_ref_cd (
      unit_section_req_ref_cd_id,
      unit_section_reference_id,
      reference_cd_type,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      reference_code,
      reference_code_desc
    ) VALUES (
      new_references.unit_section_req_ref_cd_id,
      new_references.unit_section_reference_id,
      new_references.reference_cd_type,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      new_references.reference_code,
      new_references.reference_code_desc
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
    x_unit_section_req_ref_cd_id        IN     NUMBER,
    x_unit_section_reference_id         IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_reference_code                    IN     VARCHAR2,
    x_reference_code_desc               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        unit_section_reference_id,
        reference_cd_type,
        reference_code,
        reference_code_desc
      FROM  igs_ps_us_req_ref_cd
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
        (tlinfo.unit_section_reference_id = x_unit_section_reference_id)
        AND (tlinfo.reference_cd_type = x_reference_cd_type)
        AND ((tlinfo.reference_code= x_reference_code)
           OR ((tlinfo.reference_code IS NULL)
               AND (x_reference_code IS NULL)))
        AND ((tlinfo.reference_code_desc= x_reference_code_desc)
           OR ((tlinfo.reference_code_desc IS NULL)
               AND (x_reference_code_desc IS NULL)))
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
    x_unit_section_req_ref_cd_id        IN     NUMBER,
    x_unit_section_reference_id         IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_reference_code                    IN     VARCHAR2,
    x_reference_code_desc               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
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
      x_unit_section_req_ref_cd_id        => x_unit_section_req_ref_cd_id,
      x_unit_section_reference_id         => x_unit_section_reference_id,
      x_reference_cd_type                 => x_reference_cd_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_reference_code                    => x_reference_code,
      x_reference_code_desc               => x_reference_code_desc
    );

    UPDATE igs_ps_us_req_ref_cd
      SET
        unit_section_reference_id         = new_references.unit_section_reference_id,
        reference_cd_type                 = new_references.reference_cd_type,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        reference_code                    = x_reference_code,
        reference_code_desc               = x_reference_code_desc
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_unit_section_req_ref_cd_id        IN OUT NOCOPY NUMBER,
    x_unit_section_reference_id         IN     NUMBER,
    x_reference_cd_type                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_reference_code                    IN     VARCHAR2,
    x_reference_code_desc               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_us_req_ref_cd
      WHERE    unit_section_req_ref_cd_id        = x_unit_section_req_ref_cd_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_unit_section_req_ref_cd_id,
        x_unit_section_reference_id,
        x_reference_cd_type,
        x_mode ,
        x_reference_code,
        x_reference_code_desc
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_unit_section_req_ref_cd_id,
      x_unit_section_reference_id,
      x_reference_cd_type,
      x_mode,
      x_reference_code,
      x_reference_code_desc
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Kalyan.Dande@oracle.com
  ||  Created On : 25-MAY-2001
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

    DELETE FROM igs_ps_us_req_ref_cd
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ps_us_req_ref_cd_pkg;

/
