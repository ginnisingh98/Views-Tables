--------------------------------------------------------
--  DDL for Package Body IGF_AP_ST_INST_APPL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGF_AP_ST_INST_APPL_PKG" AS
/* $Header: IGFAI12B.pls 120.1 2005/08/16 23:07:31 appldev ship $ */
 /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Table Handler package for igf_ap_st_inst_appl table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  l_rowid VARCHAR2(25);
  old_references igf_ap_st_inst_appl_all%ROWTYPE;
  new_references igf_ap_st_inst_appl_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inst_app_id                       IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_question_id                       IN     NUMBER      DEFAULT NULL,
    x_question_value                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_application_code                  IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGF_AP_ST_INST_APPL_ALL
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
    new_references.inst_app_id                       := x_inst_app_id;
    new_references.base_id                           := x_base_id;
    new_references.question_id                       := x_question_id;
    new_references.question_value                    := x_question_value;
    new_references.application_code                  := x_application_code;

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
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.base_id,
           new_references.question_id,
           new_references.application_code
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.question_id = new_references.question_id)) OR
        ((new_references.question_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_appl_setup_pkg.get_pk_for_validation (
                new_references.question_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.base_id = new_references.base_id)) OR
        ((new_references.base_id IS NULL))) THEN
      NULL;
    ELSIF NOT igf_ap_fa_base_rec_pkg.get_pk_for_validation (
                new_references.base_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_inst_app_id                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_st_inst_appl_all
      WHERE    inst_app_id = x_inst_app_id
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
    x_base_id                           IN     NUMBER,
    x_question_id                       IN     NUMBER,
    x_application_code                  IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_st_inst_appl_all
      WHERE    base_id = x_base_id
      AND      question_id = x_question_id
      AND      application_code = x_application_code
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


  PROCEDURE get_fk_igf_ap_appl_setup (
    x_question_id                       IN     NUMBER
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_st_inst_appl_all
      WHERE   ((question_id = x_question_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AP_SIA_IAS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_appl_setup;


  PROCEDURE get_fk_igf_ap_fa_base_rec (
    x_base_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igf_ap_st_inst_appl_all
      WHERE   ((base_id = x_base_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGF', 'IGF_AP_SIA_FA_DETAIL_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igf_ap_fa_base_rec;

	PROCEDURE get_fk_igf_ap_appl_status (
 	  x_base_id                           IN     NUMBER,
 	  x_application_code                  IN     VARCHAR2
 	) AS
 	/*
 	||  Created By : veramach
 	||  Created On : 17/August/2005
 	||  Purpose : Validates the Foreign Keys for the table.
 	||  Known limitations, enhancements or remarks :
 	||  Change History :
 	||  Who             When            What
 	||  (reverse chronological order - newest change first)
 	*/
 	  CURSOR cur_rowid IS
 	    SELECT   rowid
 	    FROM     igf_ap_st_inst_appl_all
 	    WHERE   ((base_id = x_base_id)
      AND     (application_code=x_application_code));

 	  lv_rowid cur_rowid%RowType;

 	BEGIN

 	  OPEN cur_rowid;
 	  FETCH cur_rowid INTO lv_rowid;
 	  IF (cur_rowid%FOUND) THEN
 	    CLOSE cur_rowid;
 	    fnd_message.set_name ('IGF', 'IGF_AP_SIA_FA_DETAIL_FK');
 	    igs_ge_msg_stack.add;
 	    app_exception.raise_exception;
 	    RETURN;
 	  END IF;
 	  CLOSE cur_rowid;

 	END get_fk_igf_ap_appl_status;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_inst_app_id                       IN     NUMBER      DEFAULT NULL,
    x_base_id                           IN     NUMBER      DEFAULT NULL,
    x_question_id                       IN     NUMBER      DEFAULT NULL,
    x_question_value                    IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_application_code                  IN     VARCHAR2    DEFAULT NULL
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
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
      x_inst_app_id,
      x_base_id,
      x_question_id,
      x_question_value,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_application_code
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.inst_app_id
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
             new_references.inst_app_id
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

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst_app_id                       IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_question_id                       IN     NUMBER,
    x_question_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_application_code                  IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igf_ap_st_inst_appl_all
      WHERE    inst_app_id                       = x_inst_app_id;

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;

    l_org_id                     igf_ap_st_inst_appl_all.org_id%TYPE  DEFAULT igf_aw_gen.get_org_id;

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
    SELECT igf_ap_st_inst_appl_s.nextval INTO x_inst_app_id FROM DUAL;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_inst_app_id                       => x_inst_app_id,
      x_base_id                           => x_base_id,
      x_question_id                       => x_question_id,
      x_question_value                    => x_question_value,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_application_code                  => x_application_code
    );

    INSERT INTO igf_ap_st_inst_appl_all (
      inst_app_id,
      base_id,
      question_id,
      question_value,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      org_id,
      application_code
    ) VALUES (
      new_references.inst_app_id,
      new_references.base_id,
      new_references.question_id,
      new_references.question_value,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      l_org_id,
      new_references.application_code
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
    x_inst_app_id                       IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_question_id                       IN     NUMBER,
    x_question_value                    IN     VARCHAR2,
    x_application_code                  IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        base_id,
        question_id,
        question_value,
        org_id,
        application_code
      FROM  igf_ap_st_inst_appl_all
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
        (tlinfo.base_id = x_base_id)
        AND (tlinfo.question_id = x_question_id)
        AND ((tlinfo.question_value = x_question_value) OR ((tlinfo.question_value IS NULL) AND (X_question_value IS NULL)))
        AND ((tlinfo.application_code = x_application_code) OR ((tlinfo.application_code IS NULL) AND (x_application_code IS NULL)))
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
    x_inst_app_id                       IN     NUMBER,
    x_base_id                           IN     NUMBER,
    x_question_id                       IN     NUMBER,
    x_question_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_application_code                  IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
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
      x_inst_app_id                       => x_inst_app_id,
      x_base_id                           => x_base_id,
      x_question_id                       => x_question_id,
      x_question_value                    => x_question_value,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_application_code                  => x_application_code
    );

    UPDATE igf_ap_st_inst_appl_all
      SET
        base_id                           = new_references.base_id,
        question_id                       = new_references.question_id,
        question_value                    = new_references.question_value,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        application_code                  = new_references.application_code
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_inst_app_id                       IN OUT NOCOPY NUMBER,
    x_base_id                           IN     NUMBER,
    x_question_id                       IN     NUMBER,
    x_question_value                    IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_application_code                  IN     VARCHAR2 DEFAULT NULL
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igf_ap_st_inst_appl_all
      WHERE    inst_app_id                       = x_inst_app_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_inst_app_id,
        x_base_id,
        x_question_id,
        x_question_value,
        x_mode,
        x_application_code
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_inst_app_id,
      x_base_id,
      x_question_id,
      x_question_value,
      x_mode,
      x_application_code
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : skoppula
  ||  Created On : 05-DEC-2000
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

    DELETE FROM igf_ap_st_inst_appl_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igf_ap_st_inst_appl_pkg;

/
