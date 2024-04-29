--------------------------------------------------------
--  DDL for Package Body IGS_UC_MAP_OUT_STAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_UC_MAP_OUT_STAT_PKG" AS
/* $Header: IGSXI45B.pls 115.8 2003/10/30 13:32:48 rghosh noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_uc_map_out_stat%ROWTYPE;
  new_references igs_uc_map_out_stat%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_adm_outcome_status                IN     VARCHAR2,
    x_default_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_uc_map_out_stat
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
    new_references.adm_outcome_status                := x_adm_outcome_status;
    new_references.default_ind                       := NVL(x_default_ind,'N');
    new_references.closed_ind                        := NVL(x_closed_ind,'N');

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
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Handles the Unique Constraint logic defined for the columns.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.system_code,
           new_references.adm_outcome_status
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_UC_OUTSTAT');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.system_code = new_references.system_code) AND
         (old_references.decision_code = new_references.decision_code)) OR
        ((new_references.system_code IS NULL) OR
         (new_references.decision_code IS NULL))) THEN
      NULL;
    ELSIF NOT igs_uc_sys_decision_pkg.get_pk_for_validation (
                new_references.system_code,
                new_references.decision_code
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.adm_outcome_status = new_references.adm_outcome_status)) OR
        ((new_references.adm_outcome_status IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_ou_stat_pkg.get_pk_for_validation (
                new_references.adm_outcome_status ,
                'N'
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_adm_outcome_status                IN     VARCHAR2
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
      FROM     igs_uc_map_out_stat
      WHERE    system_code = x_system_code
      AND      decision_code = x_decision_code
      AND      adm_outcome_status = x_adm_outcome_status ;

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
    x_system_code                       IN     VARCHAR2,
    x_adm_outcome_status                IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  smaddali 15-oct-2002 modified cursor cur_rowid for bug 2624102
  ||  (reverse chronological order - newest change first)
  */
    -- smaddali modified this cursor to add the check that closed_ind = 'N' and removed rowid check
    -- for bug 2624102
    CURSOR cur_rowid IS
      SELECT   count(*)
      FROM     igs_uc_map_out_stat
      WHERE    system_code = x_system_code
      AND      adm_outcome_status = x_adm_outcome_status
      AND      NVL(closed_ind,'N') = 'N' ;

  lv_count NUMBER ;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_count;
    CLOSE cur_rowid ;
    IF lv_count > 1 THEN
        RETURN (true);
    ELSE
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


  PROCEDURE get_fk_igs_uc_sys_decision (
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_map_out_stat
      WHERE   ((decision_code = x_decision_code) AND
               (system_code = x_system_code));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_UC_UCSD_UMO_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_uc_sys_decision;


  PROCEDURE get_fk_igs_ad_ou_stat (
    x_adm_outcome_status                IN     VARCHAR2
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_uc_map_out_stat
      WHERE   ((adm_outcome_status = x_adm_outcome_status));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_AOS_UMOU_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ad_ou_stat;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_adm_outcome_status                IN     VARCHAR2,
    x_default_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
    x_creation_date                     IN     DATE,
    x_created_by                        IN     NUMBER,
    x_last_update_date                  IN     DATE,
    x_last_updated_by                   IN     NUMBER,
    x_last_update_login                 IN     NUMBER
  ) AS
  /*
  ||  Created By : Babita.Yadav@oracle.com
  ||  Created On : 17-SEP-2002
  ||  Purpose : Initialises the columns, Checks Constraints, Calls the
  ||            Trigger Handlers for the table, before any DML operation.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  || smaddali removed check_uniqueness call from here and put it in after_dml for bug 2630219
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    set_column_values (
      p_action,
      x_rowid,
      x_system_code,
      x_decision_code,
      x_adm_outcome_status,
      x_default_ind,
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
             new_references.system_code,
             new_references.decision_code,
             new_references.adm_outcome_status
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
             new_references.system_code,
             new_references.decision_code,
             new_references.adm_outcome_status
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
    END IF;

  END before_dml;

  PROCEDURE After_dml (
      p_action IN VARCHAR2,
      x_rowid IN VARCHAR2
    ) AS
  -- Who       When         What
  -- Pmarada   20-sep-2002  Added as part of ucfd01 build, bug 2553677
  -- smaddali 16-oct-2002 added cursor c_active and add check_uniqueness call ,for bug 2624102
  -- pmarada  07-Jan-2003  Moved the decision mapping validation from here to pld post forms commit. bug 2649200

    BEGIN

     IF (p_action = 'INSERT') OR (p_action = 'UPDATE')  THEN
       -- smaddali aded check_uniqueness check here instead of before_dml for bug 2630219
        check_uniqueness;
     END IF;

  END after_dml;

  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_adm_outcome_status                IN     VARCHAR2,
    x_default_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
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
      x_adm_outcome_status                => x_adm_outcome_status,
      x_default_ind                       => x_default_ind,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_uc_map_out_stat (
      system_code,
      decision_code,
      adm_outcome_status,
      default_ind,
      closed_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.system_code,
      new_references.decision_code,
      new_references.adm_outcome_status,
      new_references.default_ind,
      new_references.closed_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    ) RETURNING ROWID INTO x_rowid;

     After_DML(
      p_action => 'INSERT',
      x_rowid => X_ROWID
      );

  END insert_row;


  PROCEDURE lock_row (
    x_rowid                             IN     VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_adm_outcome_status                IN     VARCHAR2,
    x_default_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2
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
        default_ind,
        closed_ind
      FROM  igs_uc_map_out_stat
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

    IF ( (tlinfo.default_ind = x_default_ind)   AND (tlinfo.closed_ind = x_closed_ind)  ) THEN
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
    x_adm_outcome_status                IN     VARCHAR2,
    x_default_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
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
      x_adm_outcome_status                => x_adm_outcome_status,
      x_default_ind                       => x_default_ind,
      x_closed_ind                        => x_closed_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_uc_map_out_stat
      SET
        default_ind                       = new_references.default_ind,
        closed_ind                        = new_references.closed_ind,
        last_update_date                  = x_last_update_date,
        last_updated_by                   = x_last_updated_by,
        last_update_login                 = x_last_update_login
      WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

     After_DML(
      p_action => 'UPDATE',
      x_rowid => X_ROWID
      );

  END update_row;


  PROCEDURE add_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_system_code                       IN     VARCHAR2,
    x_decision_code                     IN     VARCHAR2,
    x_adm_outcome_status                IN     VARCHAR2,
    x_default_ind                       IN     VARCHAR2,
    x_closed_ind                        IN     VARCHAR2,
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
      FROM     igs_uc_map_out_stat
      WHERE    system_code                       = x_system_code
      AND      decision_code                     = x_decision_code
      AND      adm_outcome_status                = x_adm_outcome_status;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_system_code,
        x_decision_code,
        x_adm_outcome_status,
        x_default_ind,
        x_closed_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_system_code,
      x_decision_code,
      x_adm_outcome_status,
      x_default_ind,
      x_closed_ind,
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

    DELETE FROM igs_uc_map_out_stat
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_uc_map_out_stat_pkg;

/
