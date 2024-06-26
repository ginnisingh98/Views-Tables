--------------------------------------------------------
--  DDL for Package Body IGS_HE_SUB_RTN_QUAL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_HE_SUB_RTN_QUAL_PKG" AS
/* $Header: IGSWI37B.pls 115.0 2003/04/29 09:14:41 pmarada noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_he_sub_rtn_qual%ROWTYPE;
  new_references igs_he_sub_rtn_qual%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_qual_period_desc                  IN     VARCHAR2,
    x_qual_period_type                  IN     VARCHAR2,
    x_qual_period_start_date            IN     DATE,
    x_qual_period_end_date              IN     DATE,
    x_census_date                       IN     DATE,
    x_survey_start_date                 IN     DATE,
    x_survey_end_date                   IN     DATE,
    x_closed_ind                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 29-APR-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_he_sub_rtn_qual
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
    new_references.submission_name                   := x_submission_name;
    new_references.user_return_subclass              := x_user_return_subclass;
    new_references.return_name                       := x_return_name;
    new_references.qual_period_code                  := x_qual_period_code;
    new_references.qual_period_desc                  := x_qual_period_desc;
    new_references.qual_period_type                  := x_qual_period_type;
    new_references.qual_period_start_date            := x_qual_period_start_date;
    new_references.qual_period_end_date              := x_qual_period_end_date;
    new_references.census_date                       := x_census_date;
    new_references.survey_start_date                 := x_survey_start_date;
    new_references.survey_end_date                   := x_survey_end_date;
    new_references.closed_ind                        := x_closed_ind;

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
  ||  Created On : 29-APR-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.submission_name = new_references.submission_name) AND
         (old_references.user_return_subclass = new_references.user_return_subclass) AND
         (old_references.return_name = new_references.return_name)) OR
        ((new_references.submission_name IS NULL) OR
         (new_references.user_return_subclass IS NULL) OR
         (new_references.return_name IS NULL))) THEN
      NULL;
    ELSIF NOT igs_he_submsn_return_pkg.get_pk_for_validation (
                new_references.submission_name,
                new_references.user_return_subclass,
                new_references.return_name
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By :
  ||  Created On : 29-APR-2003
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_he_stdnt_dlhe_pkg.get_fk_igs_he_sub_rtn_qual (
      old_references.submission_name,
      old_references.user_return_subclass,
      old_references.return_name,
      old_references.qual_period_code
    );

  END check_child_existance;


  FUNCTION get_pk_for_validation (
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 29-APR-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_sub_rtn_qual
      WHERE    submission_name = x_submission_name
      AND      user_return_subclass = x_user_return_subclass
      AND      return_name = x_return_name
      AND      qual_period_code = x_qual_period_code
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


  PROCEDURE get_fk_igs_he_submsn_return (
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 29-APR-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_he_sub_rtn_qual
      WHERE   ((return_name = x_return_name) AND
               (submission_name = x_submission_name) AND
               (user_return_subclass = x_user_return_subclass));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_HE_HSRQ_HSR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_he_submsn_return;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_qual_period_desc                  IN     VARCHAR2,
    x_qual_period_type                  IN     VARCHAR2,
    x_qual_period_start_date            IN     DATE,
    x_qual_period_end_date              IN     DATE,
    x_census_date                       IN     DATE,
    x_survey_start_date                 IN     DATE,
    x_survey_end_date                   IN     DATE,
    x_closed_ind                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 29-APR-2003
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
      x_submission_name,
      x_user_return_subclass,
      x_return_name,
      x_qual_period_code,
      x_qual_period_desc,
      x_qual_period_type,
      x_qual_period_start_date,
      x_qual_period_end_date,
      x_census_date,
      x_survey_start_date,
      x_survey_end_date,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.submission_name,
             new_references.user_return_subclass,
             new_references.return_name,
             new_references.qual_period_code
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
             new_references.submission_name,
             new_references.user_return_subclass,
             new_references.return_name,
             new_references.qual_period_code
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
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_qual_period_desc                  IN     VARCHAR2,
    x_qual_period_type                  IN     VARCHAR2,
    x_qual_period_start_date            IN     DATE,
    x_qual_period_end_date              IN     DATE,
    x_census_date                       IN     DATE,
    x_survey_start_date                 IN     DATE,
    x_survey_end_date                   IN     DATE,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 29-APR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_SUB_RTN_QUAL_PKG.INSERT_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_submission_name                   => x_submission_name,
      x_user_return_subclass              => x_user_return_subclass,
      x_return_name                       => x_return_name,
      x_qual_period_code                  => x_qual_period_code,
      x_qual_period_desc                  => x_qual_period_desc,
      x_qual_period_type                  => x_qual_period_type,
      x_qual_period_start_date            => x_qual_period_start_date,
      x_qual_period_end_date              => x_qual_period_end_date,
      x_census_date                       => x_census_date,
      x_survey_start_date                 => x_survey_start_date,
      x_survey_end_date                   => x_survey_end_date,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_he_sub_rtn_qual (
      submission_name,
      user_return_subclass,
      return_name,
      qual_period_code,
      qual_period_desc,
      qual_period_type,
      qual_period_start_date,
      qual_period_end_date,
      census_date,
      survey_start_date,
      survey_end_date,
      closed_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.submission_name,
      new_references.user_return_subclass,
      new_references.return_name,
      new_references.qual_period_code,
      new_references.qual_period_desc,
      new_references.qual_period_type,
      new_references.qual_period_start_date,
      new_references.qual_period_end_date,
      new_references.census_date,
      new_references.survey_start_date,
      new_references.survey_end_date,
      new_references.closed_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_qual_period_desc                  IN     VARCHAR2,
    x_qual_period_type                  IN     VARCHAR2,
    x_qual_period_start_date            IN     DATE,
    x_qual_period_end_date              IN     DATE,
    x_census_date                       IN     DATE,
    x_survey_start_date                 IN     DATE,
    x_survey_end_date                   IN     DATE,
    x_closed_ind                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 29-APR-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        qual_period_desc,
        qual_period_type,
        qual_period_start_date,
        qual_period_end_date,
        census_date,
        survey_start_date,
        survey_end_date,
        closed_ind
      FROM  igs_he_sub_rtn_qual
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
        (tlinfo.qual_period_desc = x_qual_period_desc)
        AND (tlinfo.qual_period_type = x_qual_period_type)
        AND (tlinfo.qual_period_start_date = x_qual_period_start_date)
        AND (tlinfo.qual_period_end_date = x_qual_period_end_date)
        AND (tlinfo.census_date = x_census_date)
        AND (tlinfo.survey_start_date = x_survey_start_date)
        AND (tlinfo.survey_end_date = x_survey_end_date)
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
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_qual_period_desc                  IN     VARCHAR2,
    x_qual_period_type                  IN     VARCHAR2,
    x_qual_period_start_date            IN     DATE,
    x_qual_period_end_date              IN     DATE,
    x_census_date                       IN     DATE,
    x_survey_start_date                 IN     DATE,
    x_survey_end_date                   IN     DATE,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 29-APR-2003
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
      fnd_message.set_token ('ROUTINE', 'IGS_HE_SUB_RTN_QUAL_PKG.UPDATE_ROW');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_submission_name                   => x_submission_name,
      x_user_return_subclass              => x_user_return_subclass,
      x_return_name                       => x_return_name,
      x_qual_period_code                  => x_qual_period_code,
      x_qual_period_desc                  => x_qual_period_desc,
      x_qual_period_type                  => x_qual_period_type,
      x_qual_period_start_date            => x_qual_period_start_date,
      x_qual_period_end_date              => x_qual_period_end_date,
      x_census_date                       => x_census_date,
      x_survey_start_date                 => x_survey_start_date,
      x_survey_end_date                   => x_survey_end_date,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_he_sub_rtn_qual
      SET
        qual_period_desc                  = new_references.qual_period_desc,
        qual_period_type                  = new_references.qual_period_type,
        qual_period_start_date            = new_references.qual_period_start_date,
        qual_period_end_date              = new_references.qual_period_end_date,
        census_date                       = new_references.census_date,
        survey_start_date                 = new_references.survey_start_date,
        survey_end_date                   = new_references.survey_end_date,
        closed_ind                        = new_references.closed_ind,
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
    x_submission_name                   IN     VARCHAR2,
    x_user_return_subclass              IN     VARCHAR2,
    x_return_name                       IN     VARCHAR2,
    x_qual_period_code                  IN     VARCHAR2,
    x_qual_period_desc                  IN     VARCHAR2,
    x_qual_period_type                  IN     VARCHAR2,
    x_qual_period_start_date            IN     DATE,
    x_qual_period_end_date              IN     DATE,
    x_census_date                       IN     DATE,
    x_survey_start_date                 IN     DATE,
    x_survey_end_date                   IN     DATE,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 29-APR-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_he_sub_rtn_qual
      WHERE    submission_name                   = x_submission_name
      AND      user_return_subclass              = x_user_return_subclass
      AND      return_name                       = x_return_name
      AND      qual_period_code                  = x_qual_period_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_submission_name,
        x_user_return_subclass,
        x_return_name,
        x_qual_period_code,
        x_qual_period_desc,
        x_qual_period_type,
        x_qual_period_start_date,
        x_qual_period_end_date,
        x_census_date,
        x_survey_start_date,
        x_survey_end_date,
        x_closed_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_submission_name,
      x_user_return_subclass,
      x_return_name,
      x_qual_period_code,
      x_qual_period_desc,
      x_qual_period_type,
      x_qual_period_start_date,
      x_qual_period_end_date,
      x_census_date,
      x_survey_start_date,
      x_survey_end_date,
      x_closed_ind,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 29-APR-2003
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

    DELETE FROM igs_he_sub_rtn_qual
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_he_sub_rtn_qual_pkg;

/
