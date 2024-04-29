--------------------------------------------------------
--  DDL for Package Body IGS_PE_HEARING_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_HEARING_DTLS_PKG" AS
/* $Header: IGSNI92B.pls 120.1 2005/06/28 05:40:08 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_pe_hearing_dtls%ROWTYPE;
  new_references igs_pe_hearing_dtls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hearing_details_id                IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_dspl_file_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_acad_dism_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_non_acad_dism_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_hearing_dtls
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
    new_references.hearing_details_id                := x_hearing_details_id;
    new_references.person_id                         := x_person_id;
    new_references.description                       := x_description;
    new_references.start_date                        := x_start_date;
    new_references.end_date                          := x_end_date;
    new_references.dspl_file_ind                     := x_dspl_file_ind;
    new_references.acad_dism_ind                     := x_acad_dism_ind;
    new_references.non_acad_dism_ind                 := x_non_acad_dism_ind;

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

 PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) as
  ------------------------------------------------------------------------------------------
  --Created by  : pkpatel
  --Date created: 06-JUN-2002
  --
  --Purpose:
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------
  CURSOR validate_cr_dt IS
  SELECT birth_date FROM
  IGS_PE_PERSON_BASE_V
  WHERE person_id = new_references.person_id  ;

  l_birth_dt IGS_PE_PERSON_BASE_V.BIRTH_DATE%TYPE;

  BEGIN
       IF p_inserting OR p_updating THEN
          OPEN validate_cr_dt;
          FETCH validate_cr_dt INTO l_birth_dt;
          CLOSE validate_cr_dt;
          IF l_birth_dt IS NOT NULL AND l_birth_dt >  new_references.start_date THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_AD_STRT_DT_LESS_BIRTH_DT');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;

          IF new_references.start_date IS NULL AND new_references.end_date IS NOT NULL THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_PE_CANT_SPECIFY_FROM_DATE');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;
          END IF;

       END IF;

 END BeforeRowInsertUpdate1;



  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_hearing_details_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_hearing_dtls
      WHERE    hearing_details_id = x_hearing_details_id
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


  PROCEDURE get_fk_hz_parties (
    x_party_id                          IN     NUMBER
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_hearing_dtls
      WHERE   ((person_id = x_party_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_PE_PHD_HZ_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_hearing_details_id                IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_start_date                        IN     DATE        DEFAULT NULL,
    x_end_date                          IN     DATE        DEFAULT NULL,
    x_dspl_file_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_acad_dism_ind                     IN     VARCHAR2    DEFAULT NULL,
    x_non_acad_dism_ind                 IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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
      x_hearing_details_id,
      x_person_id,
      x_description,
      x_start_date,
      x_end_date,
      x_dspl_file_ind,
      x_acad_dism_ind,
      x_non_acad_dism_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

      BeforeRowInsertUpdate1( TRUE, FALSE,FALSE );
      IF ( get_pk_for_validation(
             new_references.hearing_details_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.

      BeforeRowInsertUpdate1( FALSE,TRUE,FALSE );
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.

      BeforeRowInsertUpdate1( TRUE, FALSE,FALSE );
      IF ( get_pk_for_validation (
             new_references.hearing_details_id
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
    x_hearing_details_id                IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_dspl_file_ind                     IN     VARCHAR2,
    x_acad_dism_ind                     IN     VARCHAR2,
    x_non_acad_dism_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_pe_hearing_dtls
      WHERE    hearing_details_id                = x_hearing_details_id;

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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    SELECT    igs_pe_hearing_dtls_s.NEXTVAL
    INTO      x_hearing_details_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_hearing_details_id                => x_hearing_details_id,
      x_person_id                         => x_person_id,
      x_description                       => x_description,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_dspl_file_ind                     => x_dspl_file_ind,
      x_acad_dism_ind                     => x_acad_dism_ind,
      x_non_acad_dism_ind                 => x_non_acad_dism_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_pe_hearing_dtls (
      hearing_details_id,
      person_id,
      description,
      start_date,
      end_date,
      dspl_file_ind,
      acad_dism_ind,
      non_acad_dism_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.hearing_details_id,
      new_references.person_id,
      new_references.description,
      new_references.start_date,
      new_references.end_date,
      new_references.dspl_file_ind,
      new_references.acad_dism_ind,
      new_references.non_acad_dism_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


    OPEN c;
    FETCH c INTO x_rowid;
    IF (c%NOTFOUND) THEN
      CLOSE c;
      RAISE NO_DATA_FOUND;
    END IF;
    CLOSE c;


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
    x_hearing_details_id                IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_dspl_file_ind                     IN     VARCHAR2,
    x_acad_dism_ind                     IN     VARCHAR2,
    x_non_acad_dism_ind                 IN     VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        person_id,
        description,
        start_date,
        end_date,
        dspl_file_ind,
        acad_dism_ind,
        non_acad_dism_ind
      FROM  igs_pe_hearing_dtls
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
        AND (tlinfo.description = x_description)
        AND ((tlinfo.start_date = x_start_date) OR ((tlinfo.start_date IS NULL) AND (X_start_date IS NULL)))
        AND ((tlinfo.end_date = x_end_date) OR ((tlinfo.end_date IS NULL) AND (X_end_date IS NULL)))
        AND (tlinfo.dspl_file_ind = x_dspl_file_ind)
        AND (tlinfo.acad_dism_ind = x_acad_dism_ind)
        AND (tlinfo.non_acad_dism_ind = x_non_acad_dism_ind)
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
    x_hearing_details_id                IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_dspl_file_ind                     IN     VARCHAR2,
    x_acad_dism_ind                     IN     VARCHAR2,
    x_non_acad_dism_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_hearing_details_id                => x_hearing_details_id,
      x_person_id                         => x_person_id,
      x_description                       => x_description,
      x_start_date                        => x_start_date,
      x_end_date                          => x_end_date,
      x_dspl_file_ind                     => x_dspl_file_ind,
      x_acad_dism_ind                     => x_acad_dism_ind,
      x_non_acad_dism_ind                 => x_non_acad_dism_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

     IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_pe_hearing_dtls
      SET
        person_id                         = new_references.person_id,
        description                       = new_references.description,
        start_date                        = new_references.start_date,
        end_date                          = new_references.end_date,
        dspl_file_ind                     = new_references.dspl_file_ind,
        acad_dism_ind                     = new_references.acad_dism_ind,
        non_acad_dism_ind                 = new_references.non_acad_dism_ind,
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
    x_hearing_details_id                IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_description                       IN     VARCHAR2,
    x_start_date                        IN     DATE,
    x_end_date                          IN     DATE,
    x_dspl_file_ind                     IN     VARCHAR2,
    x_acad_dism_ind                     IN     VARCHAR2,
    x_non_acad_dism_ind                 IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_pe_hearing_dtls
      WHERE    hearing_details_id                = x_hearing_details_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_hearing_details_id,
        x_person_id,
        x_description,
        x_start_date,
        x_end_date,
        x_dspl_file_ind,
        x_acad_dism_ind,
        x_non_acad_dism_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_hearing_details_id,
      x_person_id,
      x_description,
      x_start_date,
      x_end_date,
      x_dspl_file_ind,
      x_acad_dism_ind,
      x_non_acad_dism_ind,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : cdcruz
  ||  Created On : 21-SEP-2001
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
 DELETE FROM igs_pe_hearing_dtls
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


END igs_pe_hearing_dtls_pkg;

/
