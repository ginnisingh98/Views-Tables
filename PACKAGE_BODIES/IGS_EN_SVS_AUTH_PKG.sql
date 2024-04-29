--------------------------------------------------------
--  DDL for Package Body IGS_EN_SVS_AUTH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_SVS_AUTH_PKG" AS
/* $Header: IGSEI66B.pls 120.1 2006/05/02 01:42:09 amuthu noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_en_svs_auth%ROWTYPE;
  new_references igs_en_svs_auth%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_sevis_authorization_no            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cancel_flag                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_en_svs_auth
      WHERE    rowid = x_rowid;

    CURSOR c_max_auth_no (cp_person_id HZ_PARTIES.PARTY_ID%TYPE) IS
    SELECT SEVIS_AUTHORIZATION_NO
    FROM igs_en_svs_auth esa1
    WHERE person_id = cp_person_id
    AND SEVIS_AUTHORIZATION_NO = (SELECT  max(SEVIS_AUTHORIZATION_NO)
                                  FROM igs_en_svs_auth esa2
                                  WHERE esa2.person_id = esa1.person_id)
    FOR UPDATE;


   l_sevis_authorization_no igs_en_svs_auth.SEVIS_AUTHORIZATION_NO%TYPE;

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
    new_references.sevis_authorization_code          := x_sevis_authorization_code;
    new_references.start_dt                          := x_start_dt;
    new_references.end_dt                            := x_end_dt;
    new_references.comments                          := x_comments;
    new_references.sevis_auth_id                     := x_sevis_auth_id;

    IF p_action = 'INSERT' THEN
      OPEN c_max_auth_no(x_person_id);
      FETCH c_max_auth_no INTO l_sevis_authorization_no;
      CLOSE c_max_auth_no;
      new_references.sevis_authorization_no            := NVL(l_sevis_authorization_no,0) + 1;
    ELSE
      new_references.sevis_authorization_no            := x_sevis_authorization_no;
    END IF;

    new_references.person_id                         := x_person_id;
    new_references.cancel_flag                       := x_cancel_flag;

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
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF new_references.cancel_flag <> 'Y' THEN
      IF ( get_uk_for_validation (
           new_references.person_id,
           new_references.sevis_authorization_code,
           new_references.start_dt
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_EN_SVS_AUTH_CD_REPEAT');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      END IF;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : sanil.madathil@oracle.com
  ||  Created On : 25-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;

  PROCEDURE check_child_existance AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_en_svs_auth_cal_pkg.get_fk_igs_en_svs_auth (
      old_references.sevis_auth_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_sevis_auth_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_svs_auth
      WHERE    sevis_auth_id = x_sevis_auth_id
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
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_svs_auth
      WHERE    person_id = x_person_id
      AND      sevis_authorization_code = x_sevis_authorization_code
      AND      start_dt = x_start_dt
      AND      cancel_flag <> 'Y'
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

  PROCEDURE beforeudpate1(
    x_sevis_auth_id                     IN     NUMBER
  ) AS

    CURSOR c_auth_cal IS
    SELECT sac.rowid row_id
    FROM IGS_EN_SVS_AUTH_CAL sac
    WHERE sevis_auth_id = x_sevis_auth_id;


  BEGIN

    FOR c_auth_cal_rec in c_auth_cal LOOP

      IGS_EN_SVS_AUTH_CAL_PKG.DELETE_ROW(c_auth_cal_rec.row_id);

    END LOOP;


  END beforeudpate1;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_sevis_authorization_no            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cancel_flag                       IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    l_no_of_months NUMBER;

  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_sevis_authorization_code,
      x_start_dt,
      x_end_dt,
      x_comments,
      x_sevis_auth_id,
      x_sevis_authorization_no,
      x_person_id,
      x_cancel_flag,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.sevis_auth_id
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
             new_references.sevis_auth_id
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

    IF (p_action = 'INSERT' OR p_action = 'UPDATE') THEN
      IF igs_en_sevis.is_auth_rec_duration_exceeds(new_references.person_id,
                                                new_references.start_dt,
                                                new_references.end_dt,
                                                l_no_of_months) THEN
        FND_MESSAGE.Set_name('IGS', 'IGS_EN_AUTH_PERIOD_VAL');
        FND_MESSAGE.Set_token('N',l_no_of_months );
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  IF (p_action = 'UPDATE') AND new_references.cancel_flag = 'Y'
  AND new_references.cancel_flag <> old_references.cancel_flag THEN
    beforeudpate1(new_references.sevis_auth_id);
  END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_sevis_auth_id                     IN OUT NOCOPY NUMBER,
    x_sevis_authorization_no            IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_cancel_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    x_last_update_date           DATE;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      x_request_id             := fnd_global.conc_request_id;
      x_program_id             := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;

      IF (x_request_id = -1) THEN
        x_request_id             := NULL;
        x_program_id             := NULL;
        x_program_application_id := NULL;
        x_program_update_date    := NULL;
      ELSE
        x_program_update_date    := SYSDATE;
      END IF;
    ELSE
      fnd_message.set_name ('FND', 'SYSTEM-INVALID ARGS');
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SVS_AUTH_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_sevis_auth_id := NULL;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sevis_authorization_code            => x_sevis_authorization_code,
      x_start_dt                          => x_start_dt,
      x_end_dt                            => x_end_dt,
      x_comments                          => x_comments,
      x_sevis_auth_id                     => x_sevis_auth_id,
      x_sevis_authorization_no            => x_sevis_authorization_no,
      x_person_id                         => x_person_id,
      x_cancel_flag                 => x_cancel_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_en_svs_auth (
      sevis_authorization_code,
      start_dt,
      end_dt,
      comments,
      sevis_auth_id,
      sevis_authorization_no,
      person_id,
      cancel_flag,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      request_id,
      program_id,
      program_application_id,
      program_update_date
    ) VALUES (
      new_references.sevis_authorization_code,
      new_references.start_dt,
      new_references.end_dt,
      new_references.comments,
      igs_en_svs_auth_s.NEXTVAL,
      new_references.sevis_authorization_no,
      new_references.person_id,
      new_references.cancel_flag,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING ROWID, sevis_auth_id,sevis_authorization_no
           INTO x_rowid, x_sevis_auth_id, x_sevis_authorization_no;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_sevis_authorization_no            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cancel_flag                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        sevis_authorization_code,
        start_dt,
        end_dt,
        comments,
        sevis_authorization_no,
        person_id,
        cancel_flag
      FROM  igs_en_svs_auth
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
        (tlinfo.sevis_authorization_code = x_sevis_authorization_code)
        AND (trunc(tlinfo.start_dt) = trunc(x_start_dt))
        AND (trunc(tlinfo.end_dt) = trunc(x_end_dt))
        AND ((tlinfo.comments = x_comments) OR ((tlinfo.comments IS NULL) AND (X_comments IS NULL)))
        AND (tlinfo.sevis_authorization_no = x_sevis_authorization_no)
        AND (tlinfo.person_id = x_person_id)
        AND (tlinfo.cancel_flag = x_cancel_flag)
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
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_sevis_auth_id                     IN     NUMBER,
    x_sevis_authorization_no            IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_cancel_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    x_last_update_date           DATE ;
    x_last_updated_by            NUMBER;
    x_last_update_login          NUMBER;
    x_request_id                 NUMBER;
    x_program_id                 NUMBER;
    x_program_application_id     NUMBER;
    x_program_update_date        DATE;

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
      fnd_message.set_token ('ROUTINE', 'IGS_EN_SVS_AUTH_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_sevis_authorization_code            => x_sevis_authorization_code,
      x_start_dt                          => x_start_dt,
      x_end_dt                            => x_end_dt,
      x_comments                          => x_comments,
      x_sevis_auth_id                     => x_sevis_auth_id,
      x_sevis_authorization_no            => x_sevis_authorization_no,
      x_person_id                         => x_person_id,
      x_cancel_flag                 => x_cancel_flag,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (x_mode = 'R') THEN
      x_request_id := fnd_global.conc_request_id;
      x_program_id := fnd_global.conc_program_id;
      x_program_application_id := fnd_global.prog_appl_id;
      IF (x_request_id =  -1) THEN
        x_request_id := old_references.request_id;
        x_program_id := old_references.program_id;
        x_program_application_id := old_references.program_application_id;
        x_program_update_date := old_references.program_update_date;
      ELSE
        x_program_update_date := SYSDATE;
      END IF;
    END IF;

    UPDATE igs_en_svs_auth
      SET
        sevis_authorization_code            = new_references.sevis_authorization_code,
        start_dt                          = new_references.start_dt,
        end_dt                            = new_references.end_dt,
        comments                          = new_references.comments,
        sevis_authorization_no            = new_references.sevis_authorization_no,
        person_id                         = new_references.person_id,
        cancel_flag                 = new_references.cancel_flag,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_sevis_authorization_code          IN     VARCHAR2,
    x_start_dt                          IN     DATE,
    x_end_dt                            IN     DATE,
    x_comments                          IN     VARCHAR2,
    x_sevis_auth_id                     IN OUT NOCOPY NUMBER,
    x_sevis_authorization_no            IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_cancel_flag                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_en_svs_auth
      WHERE    sevis_auth_id                     = x_sevis_auth_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sevis_authorization_code,
        x_start_dt,
        x_end_dt,
        x_comments,
        x_sevis_auth_id,
        x_sevis_authorization_no,
        x_person_id,
        x_cancel_flag,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sevis_authorization_code,
      x_start_dt,
      x_end_dt,
      x_comments,
      x_sevis_auth_id,
      x_sevis_authorization_no,
      x_person_id,
      x_cancel_flag,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 08-MAR-2006
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

    DELETE FROM igs_en_svs_auth
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_en_svs_auth_pkg;

/
