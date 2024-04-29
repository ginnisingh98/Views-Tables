--------------------------------------------------------
--  DDL for Package Body IGS_AD_APPL_PERSTAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APPL_PERSTAT_PKG" AS
/* $Header: IGSAIG3B.pls 120.3 2005/10/03 08:24:03 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_appl_perstat%ROWTYPE;
  new_references igs_ad_appl_perstat%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_perstat_id                   IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_admission_appl_number             IN     NUMBER      DEFAULT NULL,
    x_persl_stat_type                   IN     VARCHAR2    DEFAULT NULL,
    x_date_received                     IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : vdixit
  ||  Created On : 21-DEC-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ad_appl_perstat
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
    new_references.appl_perstat_id                   := x_appl_perstat_id;
    new_references.person_id                         := x_person_id;
    new_references.admission_appl_number             := x_admission_appl_number;
    new_references.persl_stat_type                   := x_persl_stat_type;
    new_references.date_received                     := TRUNC(x_date_received);

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

  PROCEDURE BeforeRowInsertUpdate(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
    CURSOR c_birth_date(p_person_id igs_pe_person_base_v.person_id%TYPE) IS
     SELECT birth_date
     FROM   igs_pe_person_base_v
     WHERE  person_id =p_person_id ;

  l_birth_date     igs_pe_person_base_v.birth_date%TYPE;

  BEGIN
    OPEN c_birth_date(new_references.person_id);
    FETCH c_birth_date INTO l_birth_date;
    CLOSE c_birth_date;

    IF ((l_birth_date IS NOT NULL) AND (l_birth_date > new_references.date_received)) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_DOB_ERROR');
       FND_MESSAGE.SET_TOKEN ('NAME',fnd_message.get_string('IGS', 'IGS_AD_DT_RECV'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;

    IF (new_references.date_received > SYSDATE) THEN
       FND_MESSAGE.SET_NAME('IGS','IGS_AD_DATE_SYSDATE');
       FND_MESSAGE.SET_TOKEN ('NAME',fnd_message.get_string('IGS', 'IGS_AD_DT_RECV'));
       IGS_GE_MSG_STACK.ADD;
       APP_EXCEPTION.RAISE_EXCEPTION;
    END IF;
  END BeforeRowInsertUpdate;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : vdixit
  ||  Created On : 21-DEC-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.persl_stat_type = new_references.persl_stat_type)) OR
        ((new_references.persl_stat_type IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_per_stm_typ_pkg.get_pk_for_validation (
                new_references.persl_stat_type ,
                'N'
              ) THEN
         FND_MESSAGE.SET_NAME('IGS','IGS_GE_PK_UK_NOT_FOUND_CLOSED');
         FND_MESSAGE.SET_TOKEN('ATTRIBUTE',FND_MESSAGE.GET_STRING('IGS','IGS_AD_CHILD_PER_STAT'));
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
    END IF;

  END check_parent_existance;

    FUNCTION get_pk_for_validation (
    x_appl_perstat_id                      IN     NUMBER,
    x_person_id                            IN     NUMBER,
    x_admission_appl_number                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 21-DEC-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_appl_perstat
      WHERE    appl_perstat_id = x_appl_perstat_id AND
               person_id =  x_person_id AND
               admission_appl_number = x_admission_appl_number
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


  PROCEDURE get_fk_igs_ad_per_stm_typ (
    x_persl_stat_type                   IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vdixit
  ||  Created On : 21-DEC-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_appl_perstat
      WHERE   ((persl_stat_type = x_persl_stat_type));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_APS_ST_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_per_stm_typ;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_appl_perstat_id                   IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_admission_appl_number             IN     NUMBER      DEFAULT NULL,
    x_persl_stat_type                   IN     VARCHAR2    DEFAULT NULL,
    x_date_received                     IN     DATE        DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : vdixit
  ||  Created On : 21-DEC-2001
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
      x_appl_perstat_id,
      x_person_id,
      x_admission_appl_number,
      x_persl_stat_type,
      x_date_received,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    igs_ad_gen_002.check_adm_appl_inst_stat(
      nvl(x_person_id,old_references.person_id),
      nvl(x_admission_appl_number,old_references.admission_appl_number),
      NULL,
      NULL,
      'Y'              -- proceed phase - apadegal adtd001 igs.m
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate ( p_inserting => TRUE );
      IF ( get_pk_for_validation(  new_references.appl_perstat_id,
                                   new_references.person_id,
                                   new_references.admission_appl_number )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate ( p_updating => TRUE );
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation ( new_references.appl_perstat_id,
                                   new_references.person_id,
                                   new_references.admission_appl_number
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
    x_appl_perstat_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_persl_stat_type                   IN     VARCHAR2,
    x_date_received                     IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vdixit
  ||  Created On : 21-DEC-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ravishar      05/27/05        Security related changes
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_appl_perstat
      WHERE    appl_perstat_id = x_appl_perstat_id;

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
    ELSIF (X_MODE IN ('R', 'S')) THEN
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    x_appl_perstat_id := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_appl_perstat_id                   => x_appl_perstat_id,
      x_person_id                         => x_person_id,
      x_admission_appl_number             => x_admission_appl_number,
      x_persl_stat_type                   => x_persl_stat_type,
      x_date_received                     => x_date_received,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

  IF (x_mode = 'S') THEN
     igs_sc_gen_001.set_ctx('R');
  END IF;
 INSERT INTO igs_ad_appl_perstat (
      appl_perstat_id,
      person_id,
      admission_appl_number,
      persl_stat_type,
      date_received,
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
      igs_ad_appl_perstat_s.NEXTVAL,
      new_references.person_id,
      new_references.admission_appl_number,
      new_references.persl_stat_type,
      new_references.date_received,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_request_id,
      x_program_id,
      x_program_application_id,
      x_program_update_date
    ) RETURNING appl_perstat_id INTO x_appl_perstat_id;
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
   IF (x_mode = 'S') THEN
      igs_sc_gen_001.unset_ctx('R');
   END IF;

    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
 END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_appl_perstat_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_persl_stat_type                   IN     VARCHAR2,
    x_date_received                     IN     DATE
  ) AS
  /*
  ||  Created By : vdixit
  ||  Created On : 21-DEC-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        appl_perstat_id,
        person_id,
        admission_appl_number,
        persl_stat_type,
        date_received
      FROM  igs_ad_appl_perstat
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
        (tlinfo.appl_perstat_id = x_appl_perstat_id)
        AND (tlinfo.person_id = x_person_id)
        AND (tlinfo.admission_appl_number = x_admission_appl_number)
        AND (tlinfo.persl_stat_type = x_persl_stat_type)
        AND (TRUNC(tlinfo.date_received) = TRUNC(x_date_received) )
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
    x_appl_perstat_id                   IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_persl_stat_type                   IN     VARCHAR2,
    x_date_received                     IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vdixit
  ||  Created On : 21-DEC-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ravishar      05/27/05        Security related changes
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
      x_appl_perstat_id                   => x_appl_perstat_id,
      x_person_id                         => x_person_id,
      x_admission_appl_number             => x_admission_appl_number,
      x_persl_stat_type                   => x_persl_stat_type,
      x_date_received                     => x_date_received,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    IF (X_MODE IN ('R', 'S')) THEN
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

  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 UPDATE igs_ad_appl_perstat
      SET
        appl_perstat_id                   = new_references.appl_perstat_id,
        person_id                         = new_references.person_id,
        admission_appl_number             = new_references.admission_appl_number,
        persl_stat_type                   = new_references.persl_stat_type,
        date_received                     = new_references.date_received,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login ,
        request_id                        = x_request_id,
        program_id                        = x_program_id,
        program_application_id            = x_program_application_id,
        program_update_date               = x_program_update_date
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
        igs_sc_gen_001.unset_ctx('R');
     END IF;
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
 END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
       igs_sc_gen_001.unset_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_appl_perstat_id                   IN OUT NOCOPY NUMBER,
    x_person_id                         IN     NUMBER,
    x_admission_appl_number             IN     NUMBER,
    x_persl_stat_type                   IN     VARCHAR2,
    x_date_received                     IN     DATE,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : vdixit
  ||  Created On : 21-DEC-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_appl_perstat
      WHERE    appl_perstat_id = x_appl_perstat_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_appl_perstat_id,
        x_person_id,
        x_admission_appl_number,
        x_persl_stat_type,
        x_date_received,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_appl_perstat_id,
      x_person_id,
      x_admission_appl_number,
      x_persl_stat_type,
      x_date_received,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2,
  x_mode IN VARCHAR2
  ) AS
  /*
  ||  Created By : vdixit
  ||  Created On : 21-DEC-2001
  ||  Purpose : Handles the DELETE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  ravishar      05/27/05        Security related changes
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
 DELETE FROM igs_ad_appl_perstat
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     IF (x_mode = 'S') THEN
        igs_sc_gen_001.set_ctx('R');
     END IF;
     app_exception.raise_exception;
 END IF;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


EXCEPTION
  WHEN OTHERS THEN
    IF (x_mode = 'S') THEN
       igs_sc_gen_001.set_ctx('R');
    END IF;
    IF SQLCODE = '-28115' OR SQLCODE = '-28113' OR SQLCODE = '-28111' THEN
      -- Code to handle Security Policy error raised
      -- 1) ORA-28115 (policy with check option violation) which is raised when Policy predicate was evaluated to FALSE with the updated values.
      -- 2) ORA-28113 (policy predicate has error) which is raised when Policy function generates invalid predicate.
      -- 3) ORA-28111 (insufficient privilege to evaluate policy predicate) which is raised when Predicate has a subquery which contains objects
      --    that the ownerof policy function does not have privilege to access.
      FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      FND_MESSAGE.SET_TOKEN('ERR_CD',SQLCODE);
      IGS_GE_MSG_STACK.ADD;
      app_exception.raise_exception;
    ELSE
      RAISE;
    END IF;
  END delete_row;


END igs_ad_appl_perstat_pkg;

/
