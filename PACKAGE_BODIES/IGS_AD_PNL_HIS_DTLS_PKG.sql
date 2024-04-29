--------------------------------------------------------
--  DDL for Package Body IGS_AD_PNL_HIS_DTLS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PNL_HIS_DTLS_PKG" AS
/* $Header: IGSAIH4B.pls 120.0 2005/06/01 23:45:07 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_pnl_his_dtls%ROWTYPE;
  new_references igs_ad_pnl_his_dtls%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE,
    x_final_decision_code               IN     VARCHAR2,
    x_final_decision_type               IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 17-JUN-2003
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ad_pnl_his_dtls
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
    new_references.panel_dtls_id                     := x_panel_dtls_id;
    new_references.history_date                      := x_history_date;
    new_references.final_decision_code              := x_final_decision_code;
    new_references.final_decision_type              := x_final_decision_type;

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
  ||  Created On : 17-JUN-2003
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.panel_dtls_id = new_references.panel_dtls_id)) OR
        ((new_references.panel_dtls_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_panel_dtls_pkg.get_pk_for_validation (
                new_references.panel_dtls_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF ((old_references.final_decision_code = new_references.final_decision_code) AND
         (old_references.final_decision_type = new_references.final_decision_type)) THEN
      NULL;
    ELSIF NOT igs_ad_code_classes_pkg.get_uk_For_validation (
                new_references.final_decision_code,
                new_references.final_decision_type ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE
  ) RETURN BOOLEAN AS
  /*
  ||  Created By :
  ||  Created On : 17-JUN-2003
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_pnl_his_dtls
      WHERE    panel_dtls_id = x_panel_dtls_id
      AND      history_date = x_history_date
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


  PROCEDURE get_fk_igs_ad_panel_dtls (
    x_panel_dtls_id                     IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 17-JUN-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_pnl_his_dtls
      WHERE   ((panel_dtls_id = x_panel_dtls_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_PNLHIS_PNDTLS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_panel_dtls;


  PROCEDURE get_ufk_igs_ad_code_classes (
    x_name                              IN     VARCHAR2,
    x_class                             IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 17-JUN-2003
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_pnl_his_dtls
      WHERE   ((final_decision_code = x_name) AND
               (final_decision_type = x_class));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_PNLHIS_CODE_CLS_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ad_code_classes;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE,
    x_final_decision_code              IN     VARCHAR2,
    x_final_decision_type              IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By :
  ||  Created On : 17-JUN-2003
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
      x_panel_dtls_id,
      x_history_date,
      x_final_decision_code,
      x_final_decision_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.panel_dtls_id,
             new_references.history_date
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
             new_references.panel_dtls_id,
             new_references.history_date
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
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE,
    x_final_decision_code              IN     VARCHAR2,
    x_final_decision_type              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 17-JUN-2003
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
      fnd_message.set_token ('ROUTINE', 'igs_ad_pnl_his_dtls_pkg.insert_row');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_panel_dtls_id                     => x_panel_dtls_id,
      x_history_date                      => x_history_date,
      x_final_decision_code              => x_final_decision_code,
      x_final_decision_type              => x_final_decision_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ad_pnl_his_dtls (
      panel_dtls_id,
      history_date,
      final_decision_code,
      final_decision_type,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.panel_dtls_id,
      new_references.history_date,
      new_references.final_decision_code,
      new_references.final_decision_type,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

EXCEPTION
  WHEN OTHERS THEN
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
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE,
    x_final_decision_code              IN     VARCHAR2,
    x_final_decision_type              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 17-JUN-2003
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        final_decision_code,
        final_decision_type
      FROM  igs_ad_pnl_his_dtls
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
        ((tlinfo.final_decision_code = x_final_decision_code) OR ((tlinfo.final_decision_code IS NULL) AND (X_final_decision_code IS NULL)))
        AND ((tlinfo.final_decision_type = x_final_decision_type) OR ((tlinfo.final_decision_type IS NULL) AND (X_final_decision_type IS NULL)))
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
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE,
    x_final_decision_code              IN     VARCHAR2,
    x_final_decision_type              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 17-JUN-2003
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
      fnd_message.set_token ('ROUTINE', 'igs_ad_pnl_his_dtls_pkg.update_row');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'UPDATE',
      x_rowid                             => x_rowid,
      x_panel_dtls_id                     => x_panel_dtls_id,
      x_history_date                      => x_history_date,
      x_final_decision_code              => x_final_decision_code,
      x_final_decision_type              => x_final_decision_type,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ad_pnl_his_dtls
      SET
        final_decision_code              = new_references.final_decision_code,
        final_decision_type              = new_references.final_decision_type,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
          IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
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
  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_panel_dtls_id                     IN     NUMBER,
    x_history_date                      IN     DATE,
    x_final_decision_code              IN     VARCHAR2,
    x_final_decision_type              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 17-JUN-2003
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_pnl_his_dtls
      WHERE    panel_dtls_id                     = x_panel_dtls_id
      AND      history_date                      = x_history_date;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_panel_dtls_id,
        x_history_date,
        x_final_decision_code,
        x_final_decision_type,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_panel_dtls_id,
      x_history_date,
      x_final_decision_code,
      x_final_decision_type,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By :
  ||  Created On : 17-JUN-2003
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

    DELETE FROM igs_ad_pnl_his_dtls
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
          FND_MESSAGE.SET_NAME ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
          IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
    END IF;

EXCEPTION
  WHEN OTHERS THEN
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


END igs_ad_pnl_his_dtls_pkg;

/
