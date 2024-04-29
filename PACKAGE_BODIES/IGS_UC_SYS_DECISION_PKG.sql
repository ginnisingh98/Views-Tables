--------------------------------------------------------
--  DDL for Package Body IGS_UC_SYS_DECISION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_SYS_DECISION_PKG" AS
/* $Header: IGSXI44B.pls 115.6 2003/12/07 15:32:48 pmarada noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_sys_decision%ROWTYPE;
  new_references igs_uc_sys_decision%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_s_adm_outcome_status              IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_decision_type                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  pmarada      05-dec-03  Added decision_type as per UC205FD,bug 2669224
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_uc_sys_decision
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
    new_references.system_code                       := x_system_code;
    new_references.decision_code                     := x_decision_code;
    new_references.s_adm_outcome_status              := x_s_adm_outcome_status;
    new_references.closed_ind                        := x_closed_ind;
    new_references.decision_type                     := x_decision_type;

  END set_column_values;


  PROCEDURE check_child_existance AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Checks for the existance of Child records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    igs_uc_map_off_resp_pkg.get_fk_igs_uc_sys_decision (
      old_references.system_code,
      old_references.decision_code
    );

    igs_uc_map_out_stat_pkg.get_fk_igs_uc_sys_decision (
      old_references.system_code,
      old_references.decision_code
    );

  END check_child_existance;

  FUNCTION get_pk_for_validation (
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_sys_decision
      WHERE    system_code = x_system_code
      AND      decision_code = x_decision_code ;

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
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_s_adm_outcome_status              IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_decision_type                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
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
      x_system_code,
      x_decision_code,
      x_s_adm_outcome_status,
      x_closed_ind ,
      x_decision_type
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.system_code,
             new_references.decision_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
         NULL;

    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      check_child_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.system_code,
             new_references.decision_code
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
         NULL;
     ELSIF (p_action = 'VALIDATE_DELETE') THEN
      check_child_existance;
    END IF;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_s_adm_outcome_status              IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_decision_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
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
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_system_code                       => x_system_code,
      x_decision_code                     => x_decision_code,
      x_s_adm_outcome_status              => x_s_adm_outcome_status,
      x_closed_ind                        => x_closed_ind ,
      x_decision_type                     => x_decision_type
    );

    INSERT INTO igs_uc_sys_decision (
      system_code,
      decision_code,
      s_adm_outcome_status,
      closed_ind  ,
      decision_type
    ) VALUES (
      new_references.system_code,
      new_references.decision_code,
      new_references.s_adm_outcome_status,
      new_references.closed_ind ,
      new_references.decision_type
    ) RETURNING ROWID INTO x_rowid;

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_s_adm_outcome_status              IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_decision_type                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        s_adm_outcome_status,
        closed_ind,
        decision_type
      FROM  igs_uc_sys_decision
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
        (tlinfo.s_adm_outcome_status = x_s_adm_outcome_status)
        AND (tlinfo.closed_ind = x_closed_ind)
        AND (tlinfo.decision_type = x_decision_type)
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
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_s_adm_outcome_status              IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_decision_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
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
      x_system_code                       => x_system_code,
      x_decision_code                     => x_decision_code,
      x_s_adm_outcome_status              => x_s_adm_outcome_status,
      x_closed_ind                        => x_closed_ind,
      x_decision_type                     => x_decision_type
    );

    UPDATE igs_uc_sys_decision
      SET
        s_adm_outcome_status              = new_references.s_adm_outcome_status,
        closed_ind                        = new_references.closed_ind ,
        decision_type                     = new_references.decision_type
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_s_adm_outcome_status              IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_decision_type                     IN     VARCHAR2,
    x_mode                              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_uc_sys_decision
      WHERE    system_code                       = x_system_code
      AND      decision_code                     = x_decision_code;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_system_code,
        x_decision_code,
        x_s_adm_outcome_status,
        x_closed_ind,
        x_decision_type,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_system_code,
      x_decision_code,
      x_s_adm_outcome_status,
      x_closed_ind,
      x_decision_type,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
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

    DELETE FROM igs_uc_sys_decision
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_sys_decision_pkg;

/
