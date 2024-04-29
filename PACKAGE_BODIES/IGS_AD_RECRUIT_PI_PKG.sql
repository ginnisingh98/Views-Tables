--------------------------------------------------------
--  DDL for Package Body IGS_AD_RECRUIT_PI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_RECRUIT_PI_PKG" AS
/* $Header: IGSAIE5B.pls 115.11 2003/12/09 11:08:04 akadam ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_recruit_pi%ROWTYPE;
  new_references igs_ad_recruit_pi%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_probability_index_id              IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_probability_type_code_id          IN     NUMBER      DEFAULT NULL,
    x_calculation_date                  IN     DATE        DEFAULT NULL,
    x_probability_value                 IN     NUMBER      DEFAULT NULL,
    x_probability_source_code_id        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_RECRUIT_PI
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
    new_references.probability_index_id              := x_probability_index_id;
    new_references.person_id                         := x_person_id;
    new_references.probability_type_code_id          := x_probability_type_code_id;
    new_references.calculation_date                  := TRUNC(x_calculation_date);
    new_references.probability_value                 := x_probability_value;
    new_references.probability_source_code_id        := x_probability_source_code_id;

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
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.probability_type_code_id,
           new_references.calculation_date,
           new_references.person_id
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

    PROCEDURE Check_Constraints (
    Column_Name	IN	VARCHAR2	DEFAULT NULL,
    Column_Value 	IN	VARCHAR2	DEFAULT NULL
  ) AS
  /*
  ||  Created By : vdixit
  ||  Created On : 22-OCT-2001
  ||  Purpose : Handles the Check Constraint via bug 2030644
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

  BEGIN
	IF  column_name is null then
     		NULL;
	ELSIF upper(Column_name) = 'PROBABILITY_VALUE' Then
     		new_references.probability_value := column_value;
	END IF;

	IF upper(column_name) = 'PROBABILITY_VALUE'  OR column_name is null Then

	        IF new_references.probability_value < 0  Then

       		  Fnd_Message.Set_Name ('IGS', 'IGS_AD_PROB_VAL');
       		  IGS_GE_MSG_STACK.ADD;
       		  App_Exception.Raise_Exception;

     		END IF;

	END IF;
  END Check_Constraints;



  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.probability_type_code_id = new_references.probability_type_code_id)) OR
        ((new_references.probability_type_code_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_code_classes_pkg.get_uk2_for_validation (
                new_references.probability_type_code_id ,
                'PROB_TYPE',
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.probability_source_code_id = new_references.probability_source_code_id)) OR
        ((new_references.probability_source_code_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_code_classes_pkg.get_uk2_for_validation (
                new_references.probability_source_code_id ,
                'PROB_SOURCE',
                 'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_probability_index_id              IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_recruit_pi
      WHERE    probability_index_id = x_probability_index_id
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
    x_probability_type_code_id          IN     NUMBER,
    x_calculation_date                  IN     DATE,
    x_person_id                         IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_recruit_pi
      WHERE    probability_type_code_id = x_probability_type_code_id
      AND      TRUNC(calculation_date) = TRUNC(x_calculation_date)
      AND      person_id = x_person_id
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


  PROCEDURE get_fk_igs_pe_person (
    x_party_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_recruit_pi
      WHERE   ((person_id = x_party_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_IARP_PE_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_pe_person;


  PROCEDURE get_fk_igs_ad_code_classes (
    x_code_id                           IN     NUMBER
  ) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_recruit_pi
      WHERE   ((probability_type_code_id = x_code_id))
      OR      ((probability_source_code_id = x_code_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_IARP_ADCC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_code_classes;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_probability_index_id              IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_probability_type_code_id          IN     NUMBER      DEFAULT NULL,
    x_calculation_date                  IN     DATE        DEFAULT NULL,
    x_probability_value                 IN     NUMBER      DEFAULT NULL,
    x_probability_source_code_id        IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
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
      x_probability_index_id,
      x_person_id,
      x_probability_type_code_id,
      x_calculation_date,
      x_probability_value,
      x_probability_source_code_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.probability_index_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      Check_Constraints;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      Check_Constraints;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.probability_index_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      Check_Constraints;
      ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      check_uniqueness;
      Check_Constraints;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_probability_index_id              IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_probability_type_code_id          IN     NUMBER,
    x_calculation_date                  IN     DATE,
    x_probability_value                 IN     NUMBER,
    x_probability_source_code_id        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_recruit_pi
      WHERE    probability_index_id              = x_probability_index_id;

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

    x_probability_index_id := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_probability_index_id              => x_probability_index_id,
      x_person_id                         => x_person_id,
      x_probability_type_code_id          => x_probability_type_code_id,
      x_calculation_date                  => x_calculation_date,
      x_probability_value                 => x_probability_value,
      x_probability_source_code_id        => x_probability_source_code_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ad_recruit_pi (
      probability_index_id,
      person_id,
      probability_type_code_id,
      calculation_date,
      probability_value,
      probability_source_code_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_ad_recruit_pi_s.NEXTVAL,
      new_references.person_id,
      new_references.probability_type_code_id,
      new_references.calculation_date,
      new_references.probability_value,
      new_references.probability_source_code_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    )RETURNING probability_index_id INTO x_probability_index_id;

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
    x_probability_index_id              IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_probability_type_code_id          IN     NUMBER,
    x_calculation_date                  IN     DATE,
    x_probability_value                 IN     NUMBER,
    x_probability_source_code_id        IN     NUMBER
  ) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        probability_type_code_id,
        calculation_date,
        probability_value,
        probability_source_code_id
      FROM  igs_ad_recruit_pi
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
        AND (tlinfo.probability_type_code_id = x_probability_type_code_id)
        AND (TRUNC(tlinfo.calculation_date) = TRUNC(x_calculation_date))
        AND ((tlinfo.probability_value = x_probability_value) OR ((tlinfo.probability_value IS NULL) AND (X_probability_value IS NULL)))
        AND ((tlinfo.probability_source_code_id = x_probability_source_code_id) OR ((tlinfo.probability_source_code_id IS NULL) AND (X_probability_source_code_id IS NULL)))
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
    x_probability_index_id              IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_probability_type_code_id          IN     NUMBER,
    x_calculation_date                  IN     DATE,
    x_probability_value                 IN     NUMBER,
    x_probability_source_code_id        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
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
      x_probability_index_id              => x_probability_index_id,
      x_person_id                         => x_person_id,
      x_probability_type_code_id          => x_probability_type_code_id,
      x_calculation_date                  => x_calculation_date,
      x_probability_value                 => x_probability_value,
      x_probability_source_code_id        => x_probability_source_code_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ad_recruit_pi
      SET
        person_id                         = new_references.person_id,
        probability_type_code_id          = new_references.probability_type_code_id,
        calculation_date                  = new_references.calculation_date,
        probability_value                 = new_references.probability_value,
        probability_source_code_id        = new_references.probability_source_code_id,
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
    x_probability_index_id              IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_probability_type_code_id          IN     NUMBER,
    x_calculation_date                  IN     DATE,
    x_probability_value                 IN     NUMBER,
    x_probability_source_code_id        IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_recruit_pi
      WHERE    probability_index_id              = x_probability_index_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_probability_index_id,
        x_person_id,
        x_probability_type_code_id,
        x_calculation_date,
        x_probability_value,
        x_probability_source_code_id,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_probability_index_id,
      x_person_id,
      x_probability_type_code_id,
      x_calculation_date,
      x_probability_value,
      x_probability_source_code_id,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : pkpatel
  ||  Created On : 18-JUL-2001
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

    DELETE FROM igs_ad_recruit_pi
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_recruit_pi_pkg;

/
