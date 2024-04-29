--------------------------------------------------------
--  DDL for Package Body IGR_I_E_TESTTYPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_E_TESTTYPS_PKG" AS
/* $Header: IGSRH11B.pls 120.0 2005/06/01 19:35:20 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igr_i_e_testtyps%ROWTYPE;
  new_references igr_i_e_testtyps%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ent_test_type_id                  IN     NUMBER      DEFAULT NULL,
    x_admission_test_type               IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_inquiry_type_id			IN     NUMBER 	   DEFAULT NULL   --Added for APC Inegration  Apadegal
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGR_I_E_TESTTYPS
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
    new_references.ent_test_type_id                  := x_ent_test_type_id;
    new_references.admission_test_type               := x_admission_test_type;
    new_references.closed_ind                        := x_closed_ind;
    new_references.inquiry_type_id                   := x_inquiry_type_id; --Added for APC Inegration  Apadegal

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
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.admission_test_type,
	   new_references.inquiry_type_id	     --Added for APC Inegration  Apadegal

         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||
  ||  (reverse chronological order - newest change first)
  */
  BEGIN


    -- Added  the code for inquiry_type_id (new coloumn) --	  for APC Inegration  Apadegal
     IF (((old_references.inquiry_type_id = new_references.inquiry_type_id)) OR
        ((new_references.inquiry_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT igr_i_inquiry_types_pkg.get_pk_for_validation (
                new_references.inquiry_type_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.admission_test_type = new_references.admission_test_type)) OR
        ((new_references.admission_test_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_test_type_pkg.get_pk_for_validation (
                new_references.admission_test_type ,
              'N' ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_ent_test_type_id                  IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_E_TESTTYPS
      WHERE    ent_test_type_id = x_ent_test_type_id
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

    x_admission_test_type               IN     VARCHAR2,
    x_inquiry_type_id	                IN     NUMBER --Added for APC Inegration-  Apadegal
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Apadegal        07-Mar-2005     changed the condition to check inquiry type id instead of entry stat id.
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_E_TESTTYPS
      WHERE    inquiry_type_id = x_inquiry_type_id
      AND      admission_test_type = x_admission_test_type
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





  PROCEDURE get_fk_igs_ad_test_type (
    x_admission_test_type               IN     VARCHAR2
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGR_I_E_TESTTYPS
      WHERE   ((admission_test_type = x_admission_test_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_AIETT_ADTT_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_test_type;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_ent_test_type_id                  IN     NUMBER      DEFAULT NULL,
    x_admission_test_type               IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL,
    x_inquiry_type_id			IN     NUMBER 	   DEFAULT NULL   --Added for APC Inegration  Apadegal
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
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
      x_ent_test_type_id,
      x_admission_test_type,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_inquiry_type_id			 --Added for APC Inegration  Apadegal
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.ent_test_type_id
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
             new_references.ent_test_type_id
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
    x_ent_test_type_id                  IN OUT NOCOPY NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R' ,
    x_inquiry_type_id			IN     NUMBER 	      --Added for APC Inegration  Apadegal
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     IGR_I_E_TESTTYPS
      WHERE    ent_test_type_id                  = x_ent_test_type_id;

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

    X_ENT_TEST_TYPE_ID := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_ent_test_type_id                  => x_ent_test_type_id,
      x_admission_test_type               => x_admission_test_type,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_inquiry_type_id			  => x_inquiry_type_id   --Added for APC Inegration  Apadegal

    );

    INSERT INTO IGR_I_E_TESTTYPS (
      ent_test_type_id,
      admission_test_type,
      closed_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      inquiry_type_id		--Added for APC Inegration  Apadegal
    ) VALUES (
      IGR_I_E_TESTTYPS_S.NEXTVAL,
      new_references.admission_test_type,
      new_references.closed_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      new_references.inquiry_type_id	       --Added for APC Inegration  Apadegal
    )RETURNING ENT_TEST_TYPE_ID INTO X_ENT_TEST_TYPE_ID;

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
    x_ent_test_type_id                  IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_inquiry_type_id                   IN     NUMBER --Added for APC Inegration  Apadegal
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
	inquiry_type_id ,                  --Added for APC Inegration  Apadegal
        admission_test_type,
        closed_ind
      FROM  IGR_I_E_TESTTYPS
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
	  (tlinfo.inquiry_type_id = x_inquiry_type_id)	       -- added for APC Inegration  Apadegal
        AND (tlinfo.admission_test_type = x_admission_test_type)
        AND (tlinfo.closed_ind = x_closed_ind)
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
    x_ent_test_type_id                  IN     NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'  ,
    x_inquiry_type_id                   IN     NUMBER --Added for APC Inegration  Apadegal
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
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
      x_ent_test_type_id                  => x_ent_test_type_id,
      x_admission_test_type               => x_admission_test_type,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_inquiry_type_id			  => x_inquiry_type_id   --Added for APC Inegration  Apadegal
    );

    UPDATE IGR_I_E_TESTTYPS
      SET
        admission_test_type               = new_references.admission_test_type,
        closed_ind                        = new_references.closed_ind,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
	inquiry_type_id			  = new_references.inquiry_type_id   --Added for APC Inegration  Apadegal
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_ent_test_type_id                  IN OUT NOCOPY NUMBER,
    x_admission_test_type               IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R',
    x_inquiry_type_id                   IN     NUMBER --Added for APC Inegration  Apadegal
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     IGR_I_E_TESTTYPS
      WHERE    ent_test_type_id                  = x_ent_test_type_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_ent_test_type_id,
        x_admission_test_type,
        x_closed_ind,
        x_mode ,
	x_inquiry_type_id	    --Added for APC Inegration  Apadegal
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_ent_test_type_id,
      x_admission_test_type,
      x_closed_ind,
      x_mode  ,
      x_inquiry_type_id	    --Added for APC Inegration  Apadegal
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : jbegum
  ||  Created On : 28-MAY-2001
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

    DELETE FROM igr_i_e_testtyps
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;

 PROCEDURE   get_fk_igr_i_inquiry_types (
    x_inquiry_type_id	                IN     NUMBER
  )
  ------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --apadegal    07-Mar-2005     APC build, Added the function for checking
  --                                child existence
  -------------------------------------------------------------------
  AS
   CURSOR cur_rowid IS
     SELECT rowid
     FROM   igr_i_e_testtyps
     WHERE  inquiry_type_id= x_inquiry_type_id;

   lv_rowid cur_rowid%RowType;
  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGR_INQTYP_TSTTYP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END 	get_fk_igr_i_inquiry_types;
END igr_i_e_testtyps_pkg;

/
