--------------------------------------------------------
--  DDL for Package Body IGS_TR_STEP_CTLG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_TR_STEP_CTLG_PKG" AS
/* $Header: IGSTI13B.pls 115.8 2003/06/26 06:53:14 vrathi ship $ */

  l_rowid VARCHAR2(25);
  old_references igs_tr_step_ctlg_all%ROWTYPE;
  new_references igs_tr_step_ctlg_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_step_catalog_id                   IN     NUMBER      DEFAULT NULL,
    x_step_catalog_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_action_days                       IN     NUMBER      DEFAULT NULL,
    x_s_tracking_step_type              IN     VARCHAR2    DEFAULT NULL,
    x_publish_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 18-JUN-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_TR_STEP_CTLG_ALL
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
    new_references.step_catalog_id                   := x_step_catalog_id;
    new_references.step_catalog_cd                   := x_step_catalog_cd;
    new_references.description                       := x_description;
    new_references.action_days                       := x_action_days;
    new_references.s_tracking_step_type              := x_s_tracking_step_type;
    new_references.publish_ind                       := x_publish_ind;
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


  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : smaddali
  ||  Created On : 18-JUN-2001
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.step_catalog_cd
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : smaddali
  ||  Created On : 18-JUN-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.s_tracking_step_type = new_references.s_tracking_step_type)) OR
        ((new_references.s_tracking_step_type IS NULL))) THEN
             NULL;
    ELSIF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
          'TRACKING_STEP_TYPE',
          new_references.s_tracking_step_type
          )THEN
            Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
    END IF;

  END check_parent_existance;

  FUNCTION get_pk_for_validation (
    x_step_catalog_id                   IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smaddali
  ||  Created On : 18-JUN-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_tr_step_ctlg_all
      WHERE    step_catalog_id = x_step_catalog_id;

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
    x_step_catalog_cd                   IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : smaddali
  ||  Created On : 18-JUN-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_tr_step_ctlg_all
      WHERE    step_catalog_cd = x_step_catalog_cd
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


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_step_catalog_id                   IN     NUMBER      DEFAULT NULL,
    x_step_catalog_cd                   IN     VARCHAR2    DEFAULT NULL,
    x_description                       IN     VARCHAR2    DEFAULT NULL,
    x_action_days                       IN     NUMBER      DEFAULT NULL,
    x_s_tracking_step_type              IN     VARCHAR2    DEFAULT NULL,
    x_publish_ind                       IN     VARCHAR2    DEFAULT NULL,
    x_closed_ind                        IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 18-JUN-2001
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vrathi          19-jun-2003     Bug: 2885713
  ||                                  Made l_rowid Null after Before_DML
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_step_catalog_id,
      x_step_catalog_cd,
      x_description,
      x_action_days,
      x_s_tracking_step_type,
      x_publish_ind,
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
             new_references.step_catalog_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      check_uniqueness;
      check_parent_existance ;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance ;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.step_catalog_id
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

    l_rowid := NULL;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_step_catalog_id                   IN OUT NOCOPY NUMBER,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_action_days                       IN     NUMBER,
    x_s_tracking_step_type              IN     VARCHAR2,
    x_publish_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 18-JUN-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_tr_step_ctlg_all
      WHERE    step_catalog_id                   = x_step_catalog_id;

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

    SELECT    igs_tr_step_ctlg_all_s.NEXTVAL
    INTO      x_step_catalog_id
    FROM      dual;

    new_references.org_id := igs_ge_gen_003.get_org_id;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_step_catalog_id                   => x_step_catalog_id,
      x_step_catalog_cd                   => x_step_catalog_cd,
      x_description                       => x_description,
      x_action_days                       => x_action_days,
      x_s_tracking_step_type              => x_s_tracking_step_type,
      x_publish_ind                       => x_publish_ind,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_tr_step_ctlg_all (
      step_catalog_id,
      step_catalog_cd,
      description,
      action_days,
      s_tracking_step_type,
      publish_ind,
      closed_ind,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.step_catalog_id,
      new_references.step_catalog_cd,
      new_references.description,
      new_references.action_days,
      new_references.s_tracking_step_type,
      new_references.publish_ind,
      new_references.closed_ind,
      new_references.org_id,
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
    x_step_catalog_id                   IN     NUMBER,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_action_days                       IN     NUMBER,
    x_s_tracking_step_type              IN     VARCHAR2,
    x_publish_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 18-JUN-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        step_catalog_cd,
        description,
        action_days,
        s_tracking_step_type,
        publish_ind,
        closed_ind
      FROM  igs_tr_step_ctlg_all
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
        (tlinfo.step_catalog_cd = x_step_catalog_cd)
        AND (tlinfo.description = x_description)
        AND (tlinfo.action_days = x_action_days)
        AND (tlinfo.s_tracking_step_type = x_s_tracking_step_type)
        AND (tlinfo.publish_ind = x_publish_ind)
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
    x_step_catalog_id                   IN     NUMBER,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_action_days                       IN     NUMBER,
    x_s_tracking_step_type              IN     VARCHAR2,
    x_publish_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 18-JUN-2001
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
      x_step_catalog_id                   => x_step_catalog_id,
      x_step_catalog_cd                   => x_step_catalog_cd,
      x_description                       => x_description,
      x_action_days                       => x_action_days,
      x_s_tracking_step_type              => x_s_tracking_step_type,
      x_publish_ind                       => x_publish_ind,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_tr_step_ctlg_all
      SET
        step_catalog_cd                   = new_references.step_catalog_cd,
        description                       = new_references.description,
        action_days                       = new_references.action_days,
        s_tracking_step_type              = new_references.s_tracking_step_type,
        publish_ind                       = new_references.publish_ind,
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
    x_step_catalog_id                   IN OUT NOCOPY NUMBER,
    x_step_catalog_cd                   IN     VARCHAR2,
    x_description                       IN     VARCHAR2,
    x_action_days                       IN     NUMBER,
    x_s_tracking_step_type              IN     VARCHAR2,
    x_publish_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : smaddali
  ||  Created On : 18-JUN-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_tr_step_ctlg_all
      WHERE    step_catalog_id                   = x_step_catalog_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_step_catalog_id,
        x_step_catalog_cd,
        x_description,
        x_action_days,
        x_s_tracking_step_type,
        x_publish_ind,
        x_closed_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_step_catalog_id,
      x_step_catalog_cd,
      x_description,
      x_action_days,
      x_s_tracking_step_type,
      x_publish_ind,
      x_closed_ind,
      x_mode
    );

  END add_row;

END igs_tr_step_ctlg_pkg;

/
