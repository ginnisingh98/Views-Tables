--------------------------------------------------------
--  DDL for Package Body IGS_UC_APP_CLEARING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_APP_CLEARING_PKG" AS
/* $Header: IGSXI04B.pls 115.7 2003/06/11 10:28:02 smaddali noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_app_clearing%ROWTYPE;
  new_references igs_uc_app_clearing%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_clearing_app_id                   IN     NUMBER  ,
    x_app_id                            IN     NUMBER  ,
    x_enquiry_no                        IN     NUMBER  ,
    x_app_no                            IN     NUMBER  ,
    x_date_cef_sent                     IN     DATE    ,
    x_cef_no                            IN     NUMBER  ,
    x_central_clearing                  IN     VARCHAR2,
    x_institution                       IN     VARCHAR2,
    x_course                            IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER  ,
    x_entry_year                        IN     NUMBER  ,
    x_entry_point                       IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_cef_received                      IN     VARCHAR2,
    x_clearing_app_source               IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03 obsoleting datetimestamp field for ucfd203 - bug#2669208
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_UC_APP_CLEARING
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
    new_references.clearing_app_id                   := x_clearing_app_id;
    new_references.app_id                            := x_app_id;
    new_references.enquiry_no                        := x_enquiry_no;
    new_references.app_no                            := x_app_no;
    new_references.date_cef_sent                     := x_date_cef_sent;
    new_references.cef_no                            := x_cef_no;
    new_references.central_clearing                  := x_central_clearing;
    new_references.institution                       := x_institution;
    new_references.course                            := x_course;
    new_references.campus                            := x_campus;
    new_references.entry_month                       := x_entry_month;
    new_references.entry_year                        := x_entry_year;
    new_references.entry_point                       := x_entry_point;
    new_references.result                            := x_result;
    new_references.cef_received                      := x_cef_received;
    new_references.clearing_app_source               := x_clearing_app_source;
    new_references.imported                          := x_imported;

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
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.app_id = new_references.app_id)) OR
        ((new_references.app_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_applicants_pkg.get_pk_for_validation (
                new_references.app_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_uc_app_clr_rnd_pkg.get_fk_igs_uc_app_clearing (
      old_references.clearing_app_id
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_clearing_app_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_clearing
      WHERE    clearing_app_id = x_clearing_app_id ;

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


  PROCEDURE get_fk_igs_uc_applicants (
    x_app_id                            IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  Nishikant       17Jun2002       Bug#2415346. UCAPCL_UCAP_FKIGS_UC_APPLICANTS
  ||                                  message was replaced with IGS_UC_UCAPCL_UCAP_FK.
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_app_clearing
      WHERE   ((app_id = x_app_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCAPCL_UCAP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_applicants;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_clearing_app_id                   IN     NUMBER  ,
    x_app_id                            IN     NUMBER  ,
    x_enquiry_no                        IN     NUMBER  ,
    x_app_no                            IN     NUMBER  ,
    x_date_cef_sent                     IN     DATE    ,
    x_cef_no                            IN     NUMBER  ,
    x_central_clearing                  IN     VARCHAR2,
    x_institution                       IN     VARCHAR2,
    x_course                            IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER  ,
    x_entry_year                        IN     NUMBER  ,
    x_entry_point                       IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_cef_received                      IN     VARCHAR2,
    x_clearing_app_source               IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_creation_date                     IN     DATE    ,
    x_created_by                        IN     NUMBER  ,
    x_last_update_date                  IN     DATE    ,
    x_last_updated_by                   IN     NUMBER  ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03 obsoleting datetimestamp field for ucfd203 - bug#2669208
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_clearing_app_id,
      x_app_id,
      x_enquiry_no,
      x_app_no,
      x_date_cef_sent,
      x_cef_no,
      x_central_clearing,
      x_institution,
      x_course,
      x_campus,
      x_entry_month,
      x_entry_year,
      x_entry_point,
      x_result,
      x_cef_received,
      x_clearing_app_source,
      x_imported,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.clearing_app_id
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
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.clearing_app_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_clearing_app_id                   IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_date_cef_sent                     IN     DATE,
    x_cef_no                            IN     NUMBER,
    x_central_clearing                  IN     VARCHAR2,
    x_institution                       IN     VARCHAR2,
    x_course                            IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_cef_received                      IN     VARCHAR2,
    x_clearing_app_source               IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03 obsoleting datetimestamp field for ucfd203 - bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_uc_app_clearing
      WHERE    clearing_app_id                   = x_clearing_app_id;

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

    SELECT    igs_uc_app_clearing_s.NEXTVAL
    INTO      x_clearing_app_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_clearing_app_id                   => x_clearing_app_id,
      x_app_id                            => x_app_id,
      x_enquiry_no                        => x_enquiry_no,
      x_app_no                            => x_app_no,
      x_date_cef_sent                     => x_date_cef_sent,
      x_cef_no                            => x_cef_no,
      x_central_clearing                  => x_central_clearing,
      x_institution                       => x_institution,
      x_course                            => x_course,
      x_campus                            => x_campus,
      x_entry_month                       => x_entry_month,
      x_entry_year                        => x_entry_year,
      x_entry_point                       => x_entry_point,
      x_result                            => x_result,
      x_cef_received                      => x_cef_received,
      x_clearing_app_source               => x_clearing_app_source,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_app_clearing (
      clearing_app_id,
      app_id,
      enquiry_no,
      app_no,
      date_cef_sent,
      cef_no,
      central_clearing,
      institution,
      course,
      campus,
      entry_month,
      entry_year,
      entry_point,
      result,
      cef_received,
      clearing_app_source,
      imported,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.clearing_app_id,
      new_references.app_id,
      new_references.enquiry_no,
      new_references.app_no,
      new_references.date_cef_sent,
      new_references.cef_no,
      new_references.central_clearing,
      new_references.institution,
      new_references.course,
      new_references.campus,
      new_references.entry_month,
      new_references.entry_year,
      new_references.entry_point,
      new_references.result,
      new_references.cef_received,
      new_references.clearing_app_source,
      new_references.imported,
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
    x_clearing_app_id                   IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_date_cef_sent                     IN     DATE,
    x_cef_no                            IN     NUMBER,
    x_central_clearing                  IN     VARCHAR2,
    x_institution                       IN     VARCHAR2,
    x_course                            IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_cef_received                      IN     VARCHAR2,
    x_clearing_app_source               IN     VARCHAR2,
    x_imported                          IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03 obsoleting datetimestamp field for ucfd203 - bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        app_id,
        enquiry_no,
        app_no,
        date_cef_sent,
        cef_no,
        central_clearing,
        institution,
        course,
        campus,
        entry_month,
        entry_year,
        entry_point,
        result,
        cef_received,
        clearing_app_source,
        imported
      FROM  igs_uc_app_clearing
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
        (tlinfo.app_id = x_app_id)
        AND ((tlinfo.enquiry_no = x_enquiry_no) OR ((tlinfo.enquiry_no IS NULL) AND (X_enquiry_no IS NULL)))
        AND ((tlinfo.app_no = x_app_no) OR ((tlinfo.app_no IS NULL) AND (X_app_no IS NULL)))
        AND ((tlinfo.date_cef_sent = x_date_cef_sent) OR ((tlinfo.date_cef_sent IS NULL) AND (X_date_cef_sent IS NULL)))
        AND (tlinfo.cef_no = x_cef_no)
        AND (tlinfo.central_clearing = x_central_clearing)
        AND ((tlinfo.institution = x_institution) OR ((tlinfo.institution IS NULL) AND (X_institution IS NULL)))
        AND ((tlinfo.course = x_course) OR ((tlinfo.course IS NULL) AND (X_course IS NULL)))
        AND ((tlinfo.campus = x_campus) OR ((tlinfo.campus IS NULL) AND (X_campus IS NULL)))
        AND ((tlinfo.entry_month = x_entry_month) OR ((tlinfo.entry_month IS NULL) AND (X_entry_month IS NULL)))
        AND ((tlinfo.entry_year = x_entry_year) OR ((tlinfo.entry_year IS NULL) AND (X_entry_year IS NULL)))
        AND ((tlinfo.entry_point = x_entry_point) OR ((tlinfo.entry_point IS NULL) AND (X_entry_point IS NULL)))
        AND ((tlinfo.result = x_result) OR ((tlinfo.result IS NULL) AND (X_result IS NULL)))
        AND (tlinfo.cef_received = x_cef_received)
        AND (tlinfo.clearing_app_source = x_clearing_app_source)
        AND (tlinfo.imported = x_imported)
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
    x_clearing_app_id                   IN     NUMBER,
    x_app_id                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_date_cef_sent                     IN     DATE,
    x_cef_no                            IN     NUMBER,
    x_central_clearing                  IN     VARCHAR2,
    x_institution                       IN     VARCHAR2,
    x_course                            IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_cef_received                      IN     VARCHAR2,
    x_clearing_app_source               IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Handles the UPDATE DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03 obsoleting datetimestamp field for ucfd203 - bug#2669208
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
      x_clearing_app_id                   => x_clearing_app_id,
      x_app_id                            => x_app_id,
      x_enquiry_no                        => x_enquiry_no,
      x_app_no                            => x_app_no,
      x_date_cef_sent                     => x_date_cef_sent,
      x_cef_no                            => x_cef_no,
      x_central_clearing                  => x_central_clearing,
      x_institution                       => x_institution,
      x_course                            => x_course,
      x_campus                            => x_campus,
      x_entry_month                       => x_entry_month,
      x_entry_year                        => x_entry_year,
      x_entry_point                       => x_entry_point,
      x_result                            => x_result,
      x_cef_received                      => x_cef_received,
      x_clearing_app_source               => x_clearing_app_source,
      x_imported                          => x_imported,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_app_clearing
      SET
        app_id                            = new_references.app_id,
        enquiry_no                        = new_references.enquiry_no,
        app_no                            = new_references.app_no,
        date_cef_sent                     = new_references.date_cef_sent,
        cef_no                            = new_references.cef_no,
        central_clearing                  = new_references.central_clearing,
        institution                       = new_references.institution,
        course                            = new_references.course,
        campus                            = new_references.campus,
        entry_month                       = new_references.entry_month,
        entry_year                        = new_references.entry_year,
        entry_point                       = new_references.entry_point,
        result                            = new_references.result,
        cef_received                      = new_references.cef_received,
        clearing_app_source               = new_references.clearing_app_source,
        imported                          = new_references.imported,
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
    x_clearing_app_id                   IN OUT NOCOPY NUMBER,
    x_app_id                            IN     NUMBER,
    x_enquiry_no                        IN     NUMBER,
    x_app_no                            IN     NUMBER,
    x_date_cef_sent                     IN     DATE,
    x_cef_no                            IN     NUMBER,
    x_central_clearing                  IN     VARCHAR2,
    x_institution                       IN     VARCHAR2,
    x_course                            IN     VARCHAR2,
    x_campus                            IN     VARCHAR2,
    x_entry_month                       IN     NUMBER,
    x_entry_year                        IN     NUMBER,
    x_entry_point                       IN     VARCHAR2,
    x_result                            IN     VARCHAR2,
    x_cef_received                      IN     VARCHAR2,
    x_clearing_app_source               IN     VARCHAR2,
    x_imported                          IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali 10-jun-03 obsoleting datetimestamp field for ucfd203 - bug#2669208
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_app_clearing
      WHERE    clearing_app_id                   = x_clearing_app_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_clearing_app_id,
        x_app_id,
        x_enquiry_no,
        x_app_no,
        x_date_cef_sent,
        x_cef_no,
        x_central_clearing,
        x_institution,
        x_course,
        x_campus,
        x_entry_month,
        x_entry_year,
        x_entry_point,
        x_result,
        x_cef_received,
        x_clearing_app_source,
        x_imported,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_clearing_app_id,
      x_app_id,
      x_enquiry_no,
      x_app_no,
      x_date_cef_sent,
      x_cef_no,
      x_central_clearing,
      x_institution,
      x_course,
      x_campus,
      x_entry_month,
      x_entry_year,
      x_entry_point,
      x_result,
      x_cef_received,
      x_clearing_app_source,
      x_imported,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 01-OCT-2001
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

    DELETE FROM igs_uc_app_clearing
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_app_clearing_pkg;

/
