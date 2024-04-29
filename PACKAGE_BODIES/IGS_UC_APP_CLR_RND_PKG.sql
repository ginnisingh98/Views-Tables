--------------------------------------------------------
--  DDL for Package Body IGS_UC_APP_CLR_RND_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_APP_CLR_RND_PKG" AS
/* $Header: IGSXI05B.pls 115.12 2003/07/21 12:21:58 ayedubat noship $ */


  l_rowid VARCHAR2(25);
  old_references igs_uc_app_clr_rnd%ROWTYPE;
  new_references igs_uc_app_clr_rnd%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_app_clear_round_id                IN     NUMBER  ,
    x_clearing_app_id                   IN     NUMBER  ,
    x_app_no                            IN     NUMBER  ,
    x_enquiry_no                        IN     NUMBER  ,
    x_round_no                          IN     NUMBER  ,
    x_institution                       IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER  ,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_accommodation_reqd                IN     VARCHAR2,
    x_round_type                        IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting datetimestamp column for ucfd203 - multiple cycles build, bug#2669208  |
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_APP_CLR_RND
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
    new_references.app_clear_round_id                := x_app_clear_round_id;
    new_references.clearing_app_id                   := x_clearing_app_id;
    new_references.app_no                            := x_app_no;
    new_references.enquiry_no                        := x_enquiry_no;
    new_references.round_no                          := x_round_no;
    new_references.institution                       := x_institution;
    new_references.ucas_program_code                 := x_ucas_program_code;
    new_references.ucas_campus                       := x_ucas_campus;
    new_references.oss_program_code                  := x_oss_program_code;
    new_references.oss_program_version               := x_oss_program_version;
    new_references.oss_location                      := x_oss_location;
    new_references.faculty                           := x_faculty;
    new_references.accommodation_reqd                := x_accommodation_reqd;
    new_references.round_type                        := x_round_type;
    new_references.result                            := x_result;
    new_references.system_code                       := x_system_code;

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

    new_references.oss_attendance_type               := x_oss_attendance_type;
    new_references.oss_attendance_mode               :=	x_oss_attendance_mode;

  END set_column_values;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    -- Cursor to fetch the current Institute Code
    CURSOR crnt_inst_cur IS
    SELECT DISTINCT current_inst_code
    FROM   igs_uc_defaults
    WHERE  current_inst_code IS NOT NULL;
    l_crnt_institute igs_uc_defaults.current_inst_code%TYPE;

  BEGIN

    IF (
        (
         (old_references.ucas_program_code = new_references.ucas_program_code) AND
         (old_references.institution = new_references.institution) AND
         (old_references.ucas_campus = new_references.ucas_campus) AND
         (old_references.system_code = new_references.system_code)
        )
        OR
        (
         (new_references.ucas_program_code IS NULL) OR
         (new_references.institution IS NULL) OR
         (new_references.ucas_campus IS NULL) OR
         (new_references.system_code IS NULL)
        )
       ) THEN
      NULL;

    ELSE

      l_crnt_institute := NULL;
      OPEN crnt_inst_cur;
      FETCH crnt_inst_cur INTO l_crnt_institute;
      CLOSE crnt_inst_cur;

      IF  new_references.institution = l_crnt_institute AND
             NOT igs_uc_crse_dets_pkg.get_pk_for_validation (
                  new_references.ucas_program_code,
                  new_references.institution,
                  new_references.ucas_campus,
                  new_references.system_code
                ) THEN
        fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;

      END IF;

    END IF;

    IF (((old_references.clearing_app_id = new_references.clearing_app_id)) OR
        ((new_references.clearing_app_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_app_clearing_pkg.get_pk_for_validation (
                new_references.clearing_app_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_app_clear_round_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_clr_rnd
      WHERE    app_clear_round_id = x_app_clear_round_id ;

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


  PROCEDURE get_fk_igs_uc_crse_dets (
    x_ucas_program_code                 IN     VARCHAR2,
    x_institute                         IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant       17Jun2002       Bug#2415346. UCAPCR_UCCSDE_FKIGS_UC_CRSE_DETS
  ||                                  message was replaced with IGS_UC_UCAPCR_UCCSDE_FK.
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_clr_rnd
      WHERE   ((institution = x_institute) AND
               (ucas_campus = x_ucas_campus) AND
               (ucas_program_code = x_ucas_program_code) AND
               (system_code = x_system_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCAPCR_UCCSDE_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_crse_dets;


  PROCEDURE get_fk_igs_uc_app_clearing (
    x_clearing_app_id                   IN     NUMBER
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant       17Jun2002       Bug#2415346. UCAPCR_UCAPCL_FKIGS_UC_APP_CLEARING
  ||                                  message was replaced with IGS_UC_UCAPCR_UCAPCL_FK.
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_clr_rnd
      WHERE   ((clearing_app_id = x_clearing_app_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCAPCR_UCAPCL_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_app_clearing;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_app_clear_round_id                IN     NUMBER  ,
    x_clearing_app_id                   IN     NUMBER  ,
    x_app_no                            IN     NUMBER  ,
    x_enquiry_no                        IN     NUMBER  ,
    x_round_no                          IN     NUMBER  ,
    x_institution                       IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER  ,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_accommodation_reqd                IN     VARCHAR2,
    x_round_type                        IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER  ,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting datetimestamp column for ucfd203 - multiple cycles build, bug#2669208  |
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_app_clear_round_id,
      x_clearing_app_id,
      x_app_no,
      x_enquiry_no,
      x_round_no,
      x_institution,
      x_ucas_program_code,
      x_ucas_campus,
      x_oss_program_code,
      x_oss_program_version,
      x_oss_location,
      x_faculty,
      x_accommodation_reqd,
      x_round_type,
      x_result,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_oss_attendance_type,
      x_oss_attendance_mode,
      x_system_code
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.app_clear_round_id
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
             new_references.app_clear_round_id
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
    x_app_clear_round_id                IN OUT NOCOPY NUMBER,
    x_clearing_app_id                   IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_round_no                          IN     NUMBER,
    x_institution                       IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_accommodation_reqd                IN     VARCHAR2,
    x_round_type                        IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting datetimestamp column for ucfd203 - multiple cycles build, bug#2669208  |
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_app_clr_rnd
      WHERE    app_clear_round_id                = x_app_clear_round_id;

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

    SELECT    igs_uc_app_clr_rnd_s.NEXTVAL
    INTO      x_app_clear_round_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_app_clear_round_id                => x_app_clear_round_id,
      x_clearing_app_id                   => x_clearing_app_id,
      x_app_no                            => x_app_no,
      x_enquiry_no                        => x_enquiry_no,
      x_round_no                          => x_round_no,
      x_institution                       => x_institution,
      x_ucas_program_code                 => x_ucas_program_code,
      x_ucas_campus                       => x_ucas_campus,
      x_oss_program_code                  => x_oss_program_code,
      x_oss_program_version               => x_oss_program_version,
      x_oss_location                      => x_oss_location,
      x_faculty                           => x_faculty,
      x_accommodation_reqd                => x_accommodation_reqd,
      x_round_type                        => x_round_type,
      x_result                            => x_result,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_oss_attendance_type               => x_oss_attendance_type,
      x_oss_attendance_mode               => x_oss_attendance_mode,
      x_system_code                       =>x_system_code
    );

    INSERT INTO igs_uc_app_clr_rnd (
      app_clear_round_id,
      clearing_app_id,
      app_no,
      enquiry_no,
      round_no,
      institution,
      ucas_program_code,
      ucas_campus,
      oss_program_code,
      oss_program_version,
      oss_location,
      faculty,
      accommodation_reqd,
      round_type,
      result,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      oss_attendance_type,
      oss_attendance_mode,
      system_code
    ) VALUES (
      new_references.app_clear_round_id,
      new_references.clearing_app_id,
      new_references.app_no,
      new_references.enquiry_no,
      new_references.round_no,
      new_references.institution,
      new_references.ucas_program_code,
      new_references.ucas_campus,
      new_references.oss_program_code,
      new_references.oss_program_version,
      new_references.oss_location,
      new_references.faculty,
      new_references.accommodation_reqd,
      new_references.round_type,
      new_references.result,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      new_references.oss_attendance_type,
      new_references.oss_attendance_mode,
      new_references.system_code
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
    x_app_clear_round_id                IN     NUMBER,
    x_clearing_app_id                   IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_round_no                          IN     NUMBER,
    x_institution                       IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_accommodation_reqd                IN     VARCHAR2,
    x_round_type                        IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting datetimestamp column for ucfd203 - multiple cycles build, bug#2669208  |
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        clearing_app_id,
        app_no,
        enquiry_no,
        round_no,
        institution,
        ucas_program_code,
        ucas_campus,
        oss_program_code,
        oss_program_version,
        oss_location,
        faculty,
        accommodation_reqd,
        round_type,
        result,
	oss_attendance_type,
	oss_attendance_mode,
	system_code
      FROM  igs_uc_app_clr_rnd
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
        (tlinfo.clearing_app_id = x_clearing_app_id)
        AND ((tlinfo.app_no = x_app_no) OR ((tlinfo.app_no IS NULL) AND (X_app_no IS NULL)))
        AND ((tlinfo.enquiry_no = x_enquiry_no) OR ((tlinfo.enquiry_no IS NULL) AND (X_enquiry_no IS NULL)))
        AND ((tlinfo.round_no = x_round_no) OR ((tlinfo.round_no IS NULL) AND (X_round_no IS NULL)))
        AND ((tlinfo.system_code = x_system_code) )
        AND ((tlinfo.institution = x_institution) OR ((tlinfo.institution IS NULL) AND (X_institution IS NULL)))
        AND ((tlinfo.ucas_program_code = x_ucas_program_code) OR ((tlinfo.ucas_program_code IS NULL) AND (X_ucas_program_code IS NULL)))
        AND ((tlinfo.ucas_campus = x_ucas_campus) OR ((tlinfo.ucas_campus IS NULL) AND (X_ucas_campus IS NULL)))
        AND ((tlinfo.oss_program_code = x_oss_program_code) OR ((tlinfo.oss_program_code IS NULL) AND (X_oss_program_code IS NULL)))
        AND ((tlinfo.oss_program_version = x_oss_program_version) OR ((tlinfo.oss_program_version IS NULL) AND (X_oss_program_version IS NULL)))
        AND ((tlinfo.oss_location = x_oss_location) OR ((tlinfo.oss_location IS NULL) AND (X_oss_location IS NULL)))
        AND ((tlinfo.faculty = x_faculty) OR ((tlinfo.faculty IS NULL) AND (X_faculty IS NULL)))
        AND (tlinfo.accommodation_reqd = x_accommodation_reqd)
        AND ((tlinfo.round_type = x_round_type) OR ((tlinfo.round_type IS NULL) AND (X_round_type IS NULL)))
        AND ((tlinfo.result = x_result) OR ((tlinfo.result IS NULL) AND (X_result IS NULL)))
        AND ((tlinfo.oss_attendance_type = x_oss_attendance_type) OR ((tlinfo.oss_attendance_type IS NULL) AND (x_oss_attendance_type IS NULL)))
        AND ((tlinfo.oss_attendance_mode = x_oss_attendance_mode) OR ((tlinfo.oss_attendance_mode IS NULL) AND (x_oss_attendance_mode IS NULL)))
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
    x_app_clear_round_id                IN     NUMBER,
    x_clearing_app_id                   IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_round_no                          IN     NUMBER,
    x_institution                       IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_accommodation_reqd                IN     VARCHAR2,
    x_round_type                        IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting datetimestamp column for ucfd203 - multiple cycles build, bug#2669208  |
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
      x_app_clear_round_id                => x_app_clear_round_id,
      x_clearing_app_id                   => x_clearing_app_id,
      x_app_no                            => x_app_no,
      x_enquiry_no                        => x_enquiry_no,
      x_round_no                          => x_round_no,
      x_institution                       => x_institution,
      x_ucas_program_code                 => x_ucas_program_code,
      x_ucas_campus                       => x_ucas_campus,
      x_oss_program_code                  => x_oss_program_code,
      x_oss_program_version               => x_oss_program_version,
      x_oss_location                      => x_oss_location,
      x_faculty                           => x_faculty,
      x_accommodation_reqd                => x_accommodation_reqd,
      x_round_type                        => x_round_type,
      x_result                            => x_result,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login,
      x_oss_attendance_type               => x_oss_attendance_type,
      x_oss_attendance_mode               => x_oss_attendance_mode,
      x_system_code                       => x_system_code
    );

    UPDATE igs_uc_app_clr_rnd
      SET
        clearing_app_id                   = new_references.clearing_app_id,
        app_no                            = new_references.app_no,
        enquiry_no                        = new_references.enquiry_no,
        round_no                          = new_references.round_no,
        institution                       = new_references.institution,
        ucas_program_code                 = new_references.ucas_program_code,
        ucas_campus                       = new_references.ucas_campus,
        oss_program_code                  = new_references.oss_program_code,
        oss_program_version               = new_references.oss_program_version,
        oss_location                      = new_references.oss_location,
        faculty                           = new_references.faculty,
        accommodation_reqd                = new_references.accommodation_reqd,
        round_type                        = new_references.round_type,
        result                            = new_references.result,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
	oss_attendance_type               = new_references.oss_attendance_type,
	oss_attendance_mode               = new_references.oss_attendance_mode,
	system_code			  = new_references.system_code
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_app_clear_round_id                IN OUT NOCOPY NUMBER,
    x_clearing_app_id                   IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_round_no                          IN     NUMBER,
    x_institution                       IN     VARCHAR2,
    x_ucas_program_code                 IN     VARCHAR2,
    x_ucas_campus                       IN     VARCHAR2,
    x_oss_program_code                  IN     VARCHAR2,
    x_oss_program_version               IN     NUMBER,
    x_oss_location                      IN     VARCHAR2,
    x_faculty                           IN     VARCHAR2,
    x_accommodation_reqd                IN     VARCHAR2,
    x_round_type                        IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_oss_attendance_type               IN     VARCHAR2,
    x_oss_attendance_mode               IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali  10-jun-03    obsoleting datetimestamp column for ucfd203 - multiple cycles build, bug#2669208  |
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_app_clr_rnd
      WHERE    app_clear_round_id                = x_app_clear_round_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_app_clear_round_id,
        x_clearing_app_id,
        x_app_no,
        x_enquiry_no,
        x_round_no,
        x_institution,
        x_ucas_program_code,
        x_ucas_campus,
        x_oss_program_code,
        x_oss_program_version,
        x_oss_location,
        x_faculty,
        x_accommodation_reqd,
        x_round_type,
        x_result,
        x_mode,
	x_oss_attendance_type,
	x_oss_attendance_mode,
	x_system_code
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_app_clear_round_id,
      x_clearing_app_id,
      x_app_no,
      x_enquiry_no,
      x_round_no,
      x_institution,
      x_ucas_program_code,
      x_ucas_campus,
      x_oss_program_code,
      x_oss_program_version,
      x_oss_location,
      x_faculty,
      x_accommodation_reqd,
      x_round_type,
      x_result,
      x_mode,
      x_oss_attendance_type,
      x_oss_attendance_mode,
      x_system_code
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : kakrishn@oracle.com
  ||  Created On : 21-FEB-2002
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

    DELETE FROM igs_uc_app_clr_rnd
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_app_clr_rnd_pkg;

/
