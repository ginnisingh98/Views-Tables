--------------------------------------------------------
--  DDL for Package Body IGS_CO_INTERAC_HIST_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CO_INTERAC_HIST_PKG" AS
/* $Header: IGSLI28B.pls 120.0 2005/06/01 19:36:59 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_co_interac_hist%ROWTYPE;
  new_references igs_co_interac_hist%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_student_id                        IN     NUMBER      ,
    x_request_id                        IN     NUMBER      ,
    x_document_id                       IN     NUMBER      ,
    x_document_type                     IN     VARCHAR2    ,
    x_sys_ltr_code                      IN     VARCHAR2    ,
    x_adm_application_number            IN     NUMBER      ,
    x_nominated_course_cd               IN     VARCHAR2    ,
    x_sequence_number                   IN     NUMBER      ,
    x_cal_type                          IN     VARCHAR2    ,
    x_ci_sequence_number                IN     NUMBER      ,
    x_requested_date                    IN     DATE        ,
    x_delivery_type                     IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_version_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 08-FEB-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_co_interac_hist
      WHERE    ROWID = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF ((cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT'))) THEN
      CLOSE cur_old_ref_values;
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_old_ref_values;
    -- Populate New Values.
    new_references.student_id                        := x_student_id;
    new_references.request_id                        := x_request_id;
    new_references.document_id                       := x_document_id;
    new_references.document_type                     := x_document_type;
    new_references.sys_ltr_code                      := x_sys_ltr_code;
    new_references.adm_application_number            := x_adm_application_number;
    new_references.nominated_course_cd               := x_nominated_course_cd;
    new_references.sequence_number                   := x_sequence_number;
    new_references.cal_type                          := x_cal_type;
    new_references.ci_sequence_number                := x_ci_sequence_number;
    new_references.requested_date                    := trunc(x_requested_date);
    new_references.delivery_type                     := x_delivery_type;
    new_references.version_id                        := x_version_id;
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
  ||  Created By : svenkata
  ||  Created On : 08-FEB-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IF (((old_references.student_id = new_references.student_id)) OR
        ((new_references.student_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.get_pk_for_validation (
                new_references.student_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_request_id                        IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : svenkata
  ||  Created On : 08-FEB-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igs_co_interac_hist
      WHERE    request_id = x_request_id
      FOR UPDATE NOWAIT;
    lv_rowid cur_rowid%ROWTYPE;
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

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    ,
    x_student_id                        IN     NUMBER      ,
    x_request_id                        IN     NUMBER      ,
    x_document_id                       IN     NUMBER      ,
    x_document_type                     IN     VARCHAR2    ,
    x_sys_ltr_code                      IN     VARCHAR2    ,
    x_adm_application_number            IN     NUMBER      ,
    x_nominated_course_cd               IN     VARCHAR2    ,
    x_sequence_number                   IN     NUMBER      ,
    x_cal_type                          IN     VARCHAR2    ,
    x_ci_sequence_number                IN     NUMBER      ,
    x_requested_date                    IN     DATE        ,
    x_delivery_type                     IN     VARCHAR2    ,
    x_creation_date                     IN     DATE        ,
    x_created_by                        IN     NUMBER      ,
    x_last_update_date                  IN     DATE        ,
    x_last_updated_by                   IN     NUMBER      ,
    x_last_update_login                 IN     NUMBER      ,
    x_version_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 08-FEB-2002
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
      x_student_id,
      x_request_id,
      x_document_id,
      x_document_type,
      x_sys_ltr_code,
      x_adm_application_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_cal_type,
      x_ci_sequence_number,
      x_requested_date,
      x_delivery_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_version_id
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.request_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.request_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.ADD;
        app_exception.raise_exception;
      END IF;
    END IF;
  END before_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_student_id                        IN     NUMBER,
    x_request_id                        IN     NUMBER,
    x_document_id                       IN     NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_adm_application_number            IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_delivery_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_version_id                        IN     NUMBER
  )AS
  /*
  ||  Created By : svenkata
  ||  Created On : 08-FEB-2002
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   ROWID
      FROM     igs_co_interac_hist
      WHERE    request_id                        = x_request_id;
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
    END IF ;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_student_id                        => x_student_id,
      x_request_id                        => x_request_id,
      x_document_id                       => x_document_id,
      x_document_type                     => x_document_type,
      x_sys_ltr_code                      => x_sys_ltr_code,
      x_adm_application_number            => x_adm_application_number,
      x_nominated_course_cd               => x_nominated_course_cd,
      x_sequence_number                   => x_sequence_number,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_requested_date                    => x_requested_date,
      x_delivery_type                     => x_delivery_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_version_id                        => x_version_id
    );
    INSERT INTO igs_co_interac_hist (
      student_id,
      request_id,
      document_id,
      document_type,
      sys_ltr_code,
      adm_application_number,
      nominated_course_cd,
      sequence_number,
      cal_type,
      ci_sequence_number,
      requested_date,
      delivery_type,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login,
      version_id
    ) VALUES (
      new_references.student_id,
      new_references.request_id,
      new_references.document_id,
      new_references.document_type,
      new_references.sys_ltr_code,
      new_references.adm_application_number,
      new_references.nominated_course_cd,
      new_references.sequence_number,
      new_references.cal_type,
      new_references.ci_sequence_number,
      new_references.requested_date,
      new_references.delivery_type,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      new_references.version_id
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
    x_student_id                        IN     NUMBER,
    x_request_id                        IN     NUMBER,
    x_document_id                       IN     NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_adm_application_number            IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_delivery_type                     IN     VARCHAR2,
    x_version_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 08-FEB-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        student_id,
	request_id,
        document_id,
        document_type,
        sys_ltr_code,
        adm_application_number,
        nominated_course_cd,
        sequence_number,
        cal_type,
        ci_sequence_number,
	requested_date,
	delivery_type,
	version_id
      FROM  igs_co_interac_hist
      WHERE ROWID = x_rowid
      FOR UPDATE NOWAIT;
    tlinfo c1%ROWTYPE;
  BEGIN
    OPEN c1;
    FETCH c1 INTO tlinfo;
    IF (c1%NOTFOUND) THEN
      fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.ADD;
      CLOSE c1;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE c1;
    IF (
        (tlinfo.student_id = x_student_id)
	AND  (tlinfo.request_id = x_request_id)
        AND (tlinfo.document_id = x_document_id)
        AND (tlinfo.document_type = x_document_type)
        AND (tlinfo.sys_ltr_code = x_sys_ltr_code)
        AND ((tlinfo.adm_application_number = x_adm_application_number) OR ((tlinfo.adm_application_number IS NULL) AND (X_adm_application_number IS NULL)))
        AND ((tlinfo.nominated_course_cd = x_nominated_course_cd) OR ((tlinfo.nominated_course_cd IS NULL) AND (X_nominated_course_cd IS NULL)))
        AND ((tlinfo.sequence_number = x_sequence_number) OR ((tlinfo.sequence_number IS NULL) AND (X_sequence_number IS NULL)))
        AND ((tlinfo.cal_type = x_cal_type) OR ((tlinfo.cal_type IS NULL) AND (X_cal_type IS NULL)))
        AND ((tlinfo.ci_sequence_number = x_ci_sequence_number) OR ((tlinfo.ci_sequence_number IS NULL) AND (X_ci_sequence_number IS NULL)))
	AND (tlinfo.requested_date = x_requested_date)
	AND (tlinfo.delivery_type  = x_delivery_type)
	AND ((tlinfo.version_id = x_version_id) OR ((tlinfo.version_id IS NULL) AND (X_version_id IS NULL)))
	) THEN
      NULL;
    ELSE
      fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    RETURN;
  END lock_row;

  PROCEDURE update_row (
    x_rowid                             IN     VARCHAR2,
    x_student_id                        IN     NUMBER,
    x_request_id                        IN     NUMBER,
    x_document_id                       IN     NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_adm_application_number            IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_delivery_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2,
    x_version_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 08-FEB-2002
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
      igs_ge_msg_stack.ADD;
      app_exception.raise_exception;
    END IF;
    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_student_id                        => x_student_id,
      x_request_id                        => x_request_id,
      x_document_id                       => x_document_id,
      x_document_type                     => x_document_type,
      x_sys_ltr_code                      => x_sys_ltr_code,
      x_adm_application_number            => x_adm_application_number,
      x_nominated_course_cd               => x_nominated_course_cd,
      x_sequence_number                   => x_sequence_number,
      x_cal_type                          => x_cal_type,
      x_ci_sequence_number                => x_ci_sequence_number,
      x_requested_date                    => x_requested_date,
      x_delivery_type                     => x_delivery_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login ,
      x_version_id                        => x_version_id
    );
    UPDATE igs_co_interac_hist
      SET
        student_id                        = new_references.student_id,
        request_id                        = new_references.request_id,
        document_id                       = new_references.document_id,
        document_type                     = new_references.document_type,
        sys_ltr_code                      = new_references.sys_ltr_code,
        adm_application_number            = new_references.adm_application_number,
        nominated_course_cd               = new_references.nominated_course_cd,
        sequence_number                   = new_references.sequence_number,
        cal_type                          = new_references.cal_type,
        ci_sequence_number                = new_references.ci_sequence_number,
        requested_date                    = new_references.requested_date,
        delivery_type                     = new_references.delivery_type,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login,
	version_id                        = new_references.version_id
      WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END update_row;

  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_student_id                        IN     NUMBER,
    x_request_id                        IN     NUMBER,
    x_document_id                       IN     NUMBER,
    x_document_type                     IN     VARCHAR2,
    x_sys_ltr_code                      IN     VARCHAR2,
    x_adm_application_number            IN     NUMBER,
    x_nominated_course_cd               IN     VARCHAR2,
    x_sequence_number                   IN     NUMBER,
    x_cal_type                          IN     VARCHAR2,
    x_ci_sequence_number                IN     NUMBER,
    x_requested_date                    IN     DATE,
    x_delivery_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 ,
    x_version_id                        IN     NUMBER
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 08-FEB-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   ROWID
      FROM     igs_co_interac_hist
      WHERE    request_id                        = x_request_id;
  BEGIN
    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;
      insert_row (
        x_rowid,
        x_student_id,
	x_request_id,
        x_document_id,
        x_document_type,
        x_sys_ltr_code,
        x_adm_application_number,
        x_nominated_course_cd,
        x_sequence_number,
        x_cal_type,
        x_ci_sequence_number,
        x_requested_date,
        x_delivery_type,
        x_mode ,
	x_version_id
      );
      RETURN;
    END IF;
    CLOSE c1;
    update_row (
      x_rowid,
      x_student_id,
      x_request_id,
      x_document_id,
      x_document_type,
      x_sys_ltr_code,
      x_adm_application_number,
      x_nominated_course_cd,
      x_sequence_number,
      x_cal_type,
      x_ci_sequence_number,
      x_requested_date,
      x_delivery_type,
      x_mode ,
      x_version_id
    );
  END add_row;
  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : svenkata
  ||  Created On : 08-FEB-2002
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
    DELETE FROM igs_co_interac_hist
    WHERE ROWID = x_rowid;
    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;
  END delete_row;
END Igs_Co_Interac_Hist_Pkg;

/