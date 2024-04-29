--------------------------------------------------------
--  DDL for Package Body IGS_DA_REQ_STDNTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_DA_REQ_STDNTS_PKG" AS
/* $Header: IGSKI49B.pls 120.0 2005/07/05 13:01:20 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_da_req_stdnts%ROWTYPE;
  new_references igs_da_req_stdnts%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_igs_da_req_stdnts_id              IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_major_unit_set_cd                 IN     VARCHAR2,
    x_program_major_code                IN     VARCHAR2,
    x_report_text                       IN     CLOB,
    x_wif_id                            IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_error_code                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_da_req_stdnts
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
    new_references.batch_id                          := x_batch_id;
    new_references.igs_da_req_stdnts_id              := x_igs_da_req_stdnts_id;
    new_references.person_id                         := x_person_id;
    new_references.program_code                      := x_program_code;
    new_references.wif_program_code                  := x_wif_program_code;
    new_references.special_program_code              := x_special_program_code;
    new_references.major_unit_set_cd                 := x_major_unit_set_cd;
    new_references.program_major_code                := x_program_major_code;
    new_references.report_text                       := x_report_text;
    new_references.wif_id                            := x_wif_id;
    new_references.error_code                        := x_error_code;

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
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.program_code = new_references.program_code)) OR
        ((new_references.program_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_course_pkg.get_pk_for_validation (
                new_references.program_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.wif_program_code = new_references.wif_program_code)) OR
        ((new_references.wif_program_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_course_pkg.get_pk_for_validation (
                new_references.wif_program_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.batch_id = new_references.batch_id) AND
         (old_references.wif_id = new_references.wif_id)) OR
        ((new_references.batch_id IS NULL) OR
         (new_references.wif_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_da_req_wif_pkg.get_pk_for_validation (
                new_references.batch_id,
                new_references.wif_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_igs_da_req_stdnts_id              IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_req_stdnts
      WHERE    igs_da_req_stdnts_id = x_igs_da_req_stdnts_id
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


  PROCEDURE get_fk_igs_ps_course (
    x_course_cd                         IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_req_stdnts
      WHERE   ((program_code = x_course_cd))
      OR      ((wif_program_code = x_course_cd));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_REQS_PSC_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ps_course;


  PROCEDURE get_fk_igs_da_req_wif (
    x_batch_id                          IN     NUMBER,
    x_wif_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_da_req_stdnts
      WHERE   ((batch_id = x_batch_id) AND
               (wif_id = x_wif_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_DA_REQS_WIF_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_da_req_wif;

  PROCEDURE BeforeInsert(p_inserting BOOLEAN , p_updating BOOLEAN) AS


   CURSOR cur_setup IS
     SELECT program_definition_ind
     FROM igs_da_setup;

   l_program_definition_ind igs_da_setup.program_definition_ind%TYPE;

  BEGIN


  IF ( p_inserting = TRUE ) THEN

     OPEN cur_setup;
     FETCH cur_setup INTO l_program_definition_ind ;
     CLOSE cur_setup;

     IF ( l_program_definition_ind = 'Y') THEN

     -- Enrolled Program
       IF ( new_references.program_code IS NOT NULL ) THEN
         IF (new_references.major_unit_set_cd IS NOT NULL) THEN
	        new_references.program_major_code := new_references.program_code || ' ' || new_references.major_unit_set_cd;
         ELSE
	        new_references.program_major_code := new_references.program_code ;
	 END IF;

     -- What If Program
       ELSIF ( new_references.wif_program_code IS NOT NULL ) THEN
         IF (new_references.major_unit_set_cd IS NOT NULL ) THEN
	         new_references.program_major_code := new_references.wif_program_code || ' ' || new_references.major_unit_set_cd;
         ELSE
	         new_references.program_major_code := new_references.wif_program_code ;
	 END IF;
     -- Special Program
       ELSIF ( new_references.special_program_code IS NOT NULL ) THEN

         new_references.program_major_code := new_references.special_program_code;

      END IF;
    ELSE

     -- Enrolled Program
	IF ( new_references.program_code IS NOT NULL ) THEN
         new_references.program_code := new_references.program_code;

     -- What If Program
        ELSIF ( new_references.wif_program_code IS NOT NULL ) THEN
         new_references.program_code := new_references.wif_program_code;

     -- Special Program
        ELSIF ( new_references.special_program_code IS NOT NULL ) THEN
	 new_references.program_code := new_references.special_program_code;
	END IF;

    END IF ;
  END IF ;

 END BeforeInsert;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_igs_da_req_stdnts_id              IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_major_unit_set_cd                 IN     VARCHAR2,
    x_program_major_code                IN     VARCHAR2,
    x_report_text                       IN     CLOB,
    x_wif_id                            IN     NUMBER,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER,
    x_error_code                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
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
      x_batch_id,
      x_igs_da_req_stdnts_id,
      x_person_id,
      x_program_code,
      x_wif_program_code,
      x_special_program_code,
      x_major_unit_set_cd,
      x_program_major_code,
      x_report_text,
      x_wif_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_error_code
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.igs_da_req_stdnts_id
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
             new_references.igs_da_req_stdnts_id
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
    x_batch_id                          IN     NUMBER,
    x_igs_da_req_stdnts_id              IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_major_unit_set_cd                 IN     VARCHAR2,
    x_program_major_code                IN     VARCHAR2,
    x_report_text                       IN     CLOB,
    x_wif_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_REQ_STDNTS_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

--    x_igs_da_req_stdnts_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_batch_id                          => x_batch_id,
      x_igs_da_req_stdnts_id              => x_igs_da_req_stdnts_id,
      x_person_id                         => x_person_id,
      x_program_code                      => x_program_code,
      x_wif_program_code                  => x_wif_program_code,
      x_special_program_code              => x_special_program_code,
      x_major_unit_set_cd                 => x_major_unit_set_cd,
      x_program_major_code                => x_program_major_code,
      x_report_text                       => x_report_text,
      x_wif_id                            => x_wif_id,
      x_error_code                        => x_error_code,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );


  -- The call BeforeInsert is added by ddey as a part of bug number # 3016150

    BeforeInsert(TRUE,FALSE);


    INSERT INTO igs_da_req_stdnts (
      batch_id,
      igs_da_req_stdnts_id,
      person_id,
      program_code,
      wif_program_code,
      special_program_code,
      major_unit_set_cd,
      program_major_code,
      report_text,
      wif_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      error_code
    ) VALUES (
      new_references.batch_id,
      igs_da_req_stdnts_s.NEXTVAL,
      new_references.person_id,
      new_references.program_code,
      new_references.wif_program_code,
      new_references.special_program_code,
      new_references.major_unit_set_cd,
      new_references.program_major_code,
      new_references.report_text,
      new_references.wif_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.error_code
    ) RETURNING ROWID, igs_da_req_stdnts_id INTO x_rowid, x_igs_da_req_stdnts_id;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_igs_da_req_stdnts_id              IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_major_unit_set_cd                 IN     VARCHAR2,
    x_program_major_code                IN     VARCHAR2,
    x_report_text                       IN     CLOB,
    x_wif_id                            IN     NUMBER,
    x_error_code                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        batch_id,
        person_id,
        program_code,
        wif_program_code,
        special_program_code,
        major_unit_set_cd,
        program_major_code,
        report_text,
        wif_id,
        error_code
      FROM  igs_da_req_stdnts
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
        (tlinfo.batch_id = x_batch_id)
        AND (tlinfo.person_id = x_person_id)
        AND ((tlinfo.program_code = x_program_code) OR ((tlinfo.program_code IS NULL) AND (X_program_code IS NULL)))
        AND ((tlinfo.wif_program_code = x_wif_program_code) OR ((tlinfo.wif_program_code IS NULL) AND (X_wif_program_code IS NULL)))
        AND ((tlinfo.special_program_code = x_special_program_code) OR ((tlinfo.special_program_code IS NULL) AND (X_special_program_code IS NULL)))
        AND ((tlinfo.major_unit_set_cd = x_major_unit_set_cd) OR ((tlinfo.major_unit_set_cd IS NULL) AND (X_major_unit_set_cd IS NULL)))
        AND ((tlinfo.program_major_code = x_program_major_code) OR ((tlinfo.program_major_code IS NULL) AND (X_program_major_code IS NULL)))
        AND ((tlinfo.wif_id = x_wif_id) OR ((tlinfo.wif_id IS NULL) AND (X_wif_id IS NULL)) )
        AND ((tlinfo.error_code = x_error_code) OR ((tlinfo.error_code IS NULL) AND (x_error_code IS NULL)) )
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
    x_batch_id                          IN     NUMBER,
    x_igs_da_req_stdnts_id              IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_major_unit_set_cd                 IN     VARCHAR2,
    x_program_major_code                IN     VARCHAR2,
    x_report_text                       IN     CLOB,
    x_wif_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_DA_REQ_STDNTS_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

--    x_igs_da_req_stdnts_id := NULL;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_batch_id                          => x_batch_id,
      x_igs_da_req_stdnts_id              => x_igs_da_req_stdnts_id,
      x_person_id                         => x_person_id,
      x_program_code                      => x_program_code,
      x_wif_program_code                  => x_wif_program_code,
      x_special_program_code              => x_special_program_code,
      x_major_unit_set_cd                 => x_major_unit_set_cd,
      x_program_major_code                => x_program_major_code,
      x_report_text                       => x_report_text,
      x_wif_id                            => x_wif_id,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_error_code                        => x_error_code
    );

    UPDATE igs_da_req_stdnts
      SET
        batch_id                          = new_references.batch_id,
        person_id                         = new_references.person_id,
        program_code                      = new_references.program_code,
        wif_program_code                  = new_references.wif_program_code,
        special_program_code              = new_references.special_program_code,
        major_unit_set_cd                 = new_references.major_unit_set_cd,
        program_major_code                = new_references.program_major_code,
        report_text                       = new_references.report_text,
        wif_id                            = new_references.wif_id,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
        error_code                        = x_error_code
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_batch_id                          IN     NUMBER,
    x_igs_da_req_stdnts_id              IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_program_code                      IN     VARCHAR2,
    x_wif_program_code                  IN     VARCHAR2,
    x_special_program_code              IN     VARCHAR2,
    x_major_unit_set_cd                 IN     VARCHAR2,
    x_program_major_code                IN     VARCHAR2,
    x_report_text                       IN     CLOB,
    x_wif_id                            IN     NUMBER,
    x_mode                              IN     VARCHAR2,
    x_error_code                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_da_req_stdnts
      WHERE    igs_da_req_stdnts_id              = x_igs_da_req_stdnts_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_batch_id,
        x_igs_da_req_stdnts_id,
        x_person_id,
        x_program_code,
        x_wif_program_code,
        x_special_program_code,
        x_major_unit_set_cd,
        x_program_major_code,
        x_report_text,
        x_wif_id,
        x_mode,
        x_error_code
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_batch_id,
      x_igs_da_req_stdnts_id,
      x_person_id,
      x_program_code,
      x_wif_program_code,
      x_special_program_code,
      x_major_unit_set_cd,
      x_program_major_code,
      x_report_text,
      x_wif_id,
      x_mode,
      x_error_code
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 27-MAR-2003
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

    DELETE FROM igs_da_req_stdnts
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_da_req_stdnts_pkg;

/
