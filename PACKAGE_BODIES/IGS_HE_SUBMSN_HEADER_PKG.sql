--------------------------------------------------------
--  DDL for Package Body IGS_HE_SUBMSN_HEADER_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_SUBMSN_HEADER_PKG" AS
/* $Header: IGSWI10B.pls 115.5 2002/11/29 04:37:10 nsidana noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_submsn_header%ROWTYPE;
  new_references igs_he_submsn_header%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_sub_hdr_id                        IN     NUMBER       ,
    x_submission_name                   IN     VARCHAR2     ,
    x_description                       IN     VARCHAR2     ,
    x_enrolment_start_date              IN     DATE         ,
    x_enrolment_end_date                IN     DATE         ,
    x_offset_days                       IN     NUMBER       ,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2     ,
    x_apply_to_inst_st_dt               IN     VARCHAR2     ,
    x_complete_flag                     IN     VARCHAR2     ,
    x_validation_country                IN     VARCHAR2     ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_HE_SUBMSN_HEADER
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
    new_references.sub_hdr_id                        := x_sub_hdr_id;
    new_references.submission_name                   := x_submission_name;
    new_references.description                       := x_description;
    new_references.enrolment_start_date              := x_enrolment_start_date;
    new_references.enrolment_end_date                := x_enrolment_end_date;
    new_references.offset_days                       := x_offset_days;
    new_references.apply_to_atmpt_st_dt              := x_apply_to_atmpt_st_dt;
    new_references.apply_to_inst_st_dt               := x_apply_to_inst_st_dt;
    new_references.validation_country                := x_validation_country;
    new_references.complete_flag                     := x_complete_flag;

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


  PROCEDURE check_child_existance IS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_he_submsn_return_pkg.get_fk_igs_he_submsn_header (
      old_references.submission_name
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_submission_name                   IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_submsn_header
      WHERE    submission_name = x_submission_name
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2     ,
    x_sub_hdr_id                        IN     NUMBER      ,
    x_submission_name                   IN     VARCHAR2     ,
    x_description                       IN     VARCHAR2     ,
    x_enrolment_start_date              IN     DATE         ,
    x_enrolment_end_date                IN     DATE         ,
    x_offset_days                       IN     NUMBER       ,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2     ,
    x_apply_to_inst_st_dt               IN     VARCHAR2     ,
    x_complete_flag                     IN     VARCHAR2     ,
    x_validation_country                IN     VARCHAR2     ,
    x_creation_date                     IN     DATE         ,
    x_created_by                        IN     NUMBER       ,
    x_last_update_date                  IN     DATE         ,
    x_last_updated_by                   IN     NUMBER       ,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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
      x_sub_hdr_id,
      x_submission_name,
      x_description,
      x_enrolment_start_date,
      x_enrolment_end_date,
      x_offset_days,
      x_apply_to_atmpt_st_dt,
      x_apply_to_inst_st_dt,
      x_complete_flag,
      x_validation_country ,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.submission_name
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.submission_name
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
    x_sub_hdr_id                        IN OUT NOCOPY NUMBER,
    x_submission_name                   IN OUT NOCOPY VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_enrolment_start_date              IN     DATE,
    x_enrolment_end_date                IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2,
    x_apply_to_inst_st_dt               IN     VARCHAR2,
    x_complete_flag                     IN     VARCHAR2,
    x_validation_country                IN     VARCHAR2     ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_he_submsn_header
      WHERE    submission_name                   = x_submission_name;

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

    SELECT    igs_he_submsn_header_s.NEXTVAL
    INTO      x_sub_hdr_id
    FROM      dual;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_sub_hdr_id                        => x_sub_hdr_id,
      x_submission_name                   => x_submission_name,
      x_description                       => x_description,
      x_enrolment_start_date              => x_enrolment_start_date,
      x_enrolment_end_date                => x_enrolment_end_date,
      x_offset_days                       => x_offset_days,
      x_apply_to_atmpt_st_dt              => x_apply_to_atmpt_st_dt,
      x_apply_to_inst_st_dt               => x_apply_to_inst_st_dt,
      x_complete_flag                     => x_complete_flag,
      x_validation_country                => x_validation_country,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_submsn_header (
      sub_hdr_id,
      submission_name,
      description,
      enrolment_start_date,
      enrolment_end_date,
      offset_days,
      apply_to_atmpt_st_dt,
      apply_to_inst_st_dt,
      complete_flag,
      validation_country,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.sub_hdr_id,
      new_references.submission_name,
      new_references.description,
      new_references.enrolment_start_date,
      new_references.enrolment_end_date,
      new_references.offset_days,
      new_references.apply_to_atmpt_st_dt,
      new_references.apply_to_inst_st_dt,
      new_references.complete_flag,
      new_references.validation_country,
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
    x_sub_hdr_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_enrolment_start_date              IN     DATE,
    x_enrolment_end_date                IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2,
    x_apply_to_inst_st_dt               IN     VARCHAR2,
    x_complete_flag                     IN     VARCHAR2,
    x_validation_country                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        sub_hdr_id,
        description,
        enrolment_start_date,
        enrolment_end_date,
        offset_days,
        apply_to_atmpt_st_dt,
        apply_to_inst_st_dt,
        complete_flag,
        validation_country
      FROM  igs_he_submsn_header
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
        (tlinfo.sub_hdr_id = x_sub_hdr_id)
        AND (tlinfo.description = x_description)
        AND (tlinfo.enrolment_start_date = x_enrolment_start_date)
        AND (tlinfo.enrolment_end_date = x_enrolment_end_date)
        AND ((tlinfo.offset_days = x_offset_days) OR ((tlinfo.offset_days IS NULL) AND (X_offset_days IS NULL)))
        AND ((tlinfo.apply_to_atmpt_st_dt = x_apply_to_atmpt_st_dt) OR ((tlinfo.apply_to_atmpt_st_dt IS NULL) AND (X_apply_to_atmpt_st_dt IS NULL)))
        AND ((tlinfo.apply_to_inst_st_dt = x_apply_to_inst_st_dt) OR ((tlinfo.apply_to_inst_st_dt IS NULL) AND (X_apply_to_inst_st_dt IS NULL)))
        AND ((tlinfo.validation_country = x_validation_country) OR ((tlinfo.validation_country IS NULL) AND (X_validation_country IS NULL)))
        AND (tlinfo.complete_flag = x_complete_flag)
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
    x_sub_hdr_id                        IN     NUMBER,
    x_submission_name                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_enrolment_start_date              IN     DATE,
    x_enrolment_end_date                IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2,
    x_apply_to_inst_st_dt               IN     VARCHAR2,
    x_complete_flag                     IN     VARCHAR2,
    x_validation_country                IN     VARCHAR2 ,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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
      x_sub_hdr_id                        => x_sub_hdr_id,
      x_submission_name                   => x_submission_name,
      x_description                       => x_description,
      x_enrolment_start_date              => x_enrolment_start_date,
      x_enrolment_end_date                => x_enrolment_end_date,
      x_offset_days                       => x_offset_days,
      x_apply_to_atmpt_st_dt              => x_apply_to_atmpt_st_dt,
      x_apply_to_inst_st_dt               => x_apply_to_inst_st_dt,
      x_complete_flag                     => x_complete_flag,
      x_validation_country                => x_validation_country,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_submsn_header
      SET
        sub_hdr_id                        = new_references.sub_hdr_id,
        description                       = new_references.description,
        enrolment_start_date              = new_references.enrolment_start_date,
        enrolment_end_date                = new_references.enrolment_end_date,
        offset_days                       = new_references.offset_days,
        apply_to_atmpt_st_dt              = new_references.apply_to_atmpt_st_dt,
        apply_to_inst_st_dt               = new_references.apply_to_inst_st_dt,
        complete_flag                     = new_references.complete_flag,
        validation_country                = new_references.validation_country,
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
    x_sub_hdr_id                        IN OUT NOCOPY    NUMBER,
    x_submission_name                   IN OUT NOCOPY VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_enrolment_start_date              IN     DATE,
    x_enrolment_end_date                IN     DATE,
    x_offset_days                       IN     NUMBER,
    x_apply_to_atmpt_st_dt              IN     VARCHAR2,
    x_apply_to_inst_st_dt               IN     VARCHAR2,
    x_complete_flag                     IN     VARCHAR2,
    x_validation_country                IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_submsn_header
      WHERE    submission_name                   = x_submission_name;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_sub_hdr_id,
        x_submission_name,
        x_description,
        x_enrolment_start_date,
        x_enrolment_end_date,
        x_offset_days,
        x_apply_to_atmpt_st_dt,
        x_apply_to_inst_st_dt,
        x_complete_flag,
        x_validation_country,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_sub_hdr_id,
      x_submission_name,
      x_description,
      x_enrolment_start_date,
      x_enrolment_end_date,
      x_offset_days,
      x_apply_to_atmpt_st_dt,
      x_apply_to_inst_st_dt,
      x_complete_flag,
      x_validation_country,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : rgopalan
  ||  Created On : 15-JUN-2001
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

    DELETE FROM igs_he_submsn_header
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_submsn_header_pkg;

/
