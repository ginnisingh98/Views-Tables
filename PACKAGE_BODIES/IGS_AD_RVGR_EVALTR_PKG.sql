--------------------------------------------------------
--  DDL for Package Body IGS_AD_RVGR_EVALTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_RVGR_EVALTR_PKG" AS
/* $Header: IGSAIF6B.pls 115.10 2003/03/25 13:38:59 rghosh noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_rvgr_evaltr%ROWTYPE;
  new_references igs_ad_rvgr_evaltr%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_revgr_evaluator_id                IN     NUMBER      DEFAULT NULL,
    x_appl_revprof_revgr_id             IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_person_number                     IN     VARCHAR2    DEFAULT NULL,
    x_evaluation_sequence               IN     NUMBER      DEFAULT NULL,
    x_program_approver_ind              IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ad_rvgr_evaltr
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
    new_references.revgr_evaluator_id                := x_revgr_evaluator_id;
    new_references.appl_revprof_revgr_id             := x_appl_revprof_revgr_id;
    new_references.person_id                         := x_person_id;
    new_references.person_number                     := x_person_number;
    new_references.evaluation_sequence               := x_evaluation_sequence;
    new_references.program_approver_ind              := x_program_approver_ind;

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

  PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :Rishi Ghosh
  Date Created By :23-Dec-2002
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.appl_revprof_revgr_id
    		,new_references.person_id
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                IGS_GE_MSG_STACK.ADD;
		app_exception.raise_exception;
    		END IF;
  END Check_Uniqueness ;


  PROCEDURE check_parent_existance AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Checks for the existance of Parent records.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF (((old_references.appl_revprof_revgr_id = new_references.appl_revprof_revgr_id)) OR
        ((new_references.appl_revprof_revgr_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ad_apl_rprf_rgr_pkg.get_pk_for_validation (
                new_references.appl_revprof_revgr_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_pe_person_pkg.get_pk_for_validation (
                new_references.person_id
              ) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_parent_existance;


  FUNCTION get_pk_for_validation (
    x_revgr_evaluator_id                IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_rvgr_evaltr
      WHERE    revgr_evaluator_id = x_revgr_evaluator_id
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


  FUNCTION get_uk_for_validation (
   x_appl_revprof_revgr_id                IN     NUMBER,
   x_person_id                            IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : rishi.ghosh@oracle.com
  ||  Created On : 17-dec-2002
  ||  Purpose : Validates the Unique Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_rvgr_evaltr
      WHERE    appl_revprof_revgr_id = x_appl_revprof_revgr_id
      AND      person_id = x_person_id
      AND      (l_rowid IS NULL OR rowid <> l_rowid)
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

  END get_uk_for_validation;


  PROCEDURE get_fk_igs_ad_apl_rprf_rgr (
    x_appl_revprof_revgr_id             IN     NUMBER
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_rvgr_evaltr
      WHERE   ((appl_revprof_revgr_id = x_appl_revprof_revgr_id));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_RGREVL_APRRGR_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;
  END  get_fk_igs_ad_apl_rprf_rgr;

  PROCEDURE get_fk_hz_parties (
    x_person_id                IN     NUMBER
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Validates the Foreign Keys for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_rvgr_evaltr
      WHERE   (person_id = x_person_id) ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_AD_RGREVL_HP_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_hz_parties;


  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_revgr_evaluator_id                IN     NUMBER      DEFAULT NULL,
    x_appl_revprof_revgr_id             IN     NUMBER      DEFAULT NULL,
    x_person_id                         IN     NUMBER      DEFAULT NULL,
    x_person_number                     IN     VARCHAR2    DEFAULT NULL,
    x_evaluation_sequence               IN     NUMBER      DEFAULT NULL,
    x_program_approver_ind              IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
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
      x_revgr_evaluator_id,
      x_appl_revprof_revgr_id,
      x_person_id,
      x_person_number,
      x_evaluation_sequence,
      x_program_approver_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.revgr_evaluator_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      Check_Uniqueness;

      check_parent_existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      check_uniqueness;
      check_parent_existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.revgr_evaluator_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Insert.
      Check_Uniqueness;
    END IF;

  l_rowid :=NULL;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_revgr_evaluator_id                IN OUT NOCOPY NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_evaluation_sequence               IN     NUMBER,
    x_program_approver_ind              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_rvgr_evaltr
      WHERE    revgr_evaluator_id                = x_revgr_evaluator_id;

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

    x_revgr_evaluator_id := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_revgr_evaluator_id                => x_revgr_evaluator_id,
      x_appl_revprof_revgr_id             => x_appl_revprof_revgr_id,
      x_person_id                         => x_person_id,
      x_person_number                     => x_person_number,
      x_evaluation_sequence               => x_evaluation_sequence,
      x_program_approver_ind              => x_program_approver_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ad_rvgr_evaltr (
      revgr_evaluator_id,
      appl_revprof_revgr_id,
      person_id,
      person_number,
      evaluation_sequence,
      program_approver_ind,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_ad_rvgr_evaltr_s.NEXTVAL,
      new_references.appl_revprof_revgr_id,
      new_references.person_id,
      new_references.person_number,
      new_references.evaluation_sequence,
      new_references.program_approver_ind,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    )RETURNING revgr_evaluator_id INTO x_revgr_evaluator_id;

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
    x_revgr_evaluator_id                IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_evaluation_sequence               IN     NUMBER,
    x_program_approver_ind              IN     VARCHAR2
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        appl_revprof_revgr_id,
        person_id,
        person_number,
        evaluation_sequence,
        program_approver_ind
      FROM  igs_ad_rvgr_evaltr
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
        (tlinfo.appl_revprof_revgr_id = x_appl_revprof_revgr_id)
        AND (tlinfo.person_id = x_person_id)
        AND (tlinfo.person_number = x_person_number)
        AND ((tlinfo.evaluation_sequence = x_evaluation_sequence) OR ((tlinfo.evaluation_sequence IS NULL) AND (X_evaluation_sequence IS NULL)))
        AND (tlinfo.program_approver_ind = x_program_approver_ind)
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
    x_revgr_evaluator_id                IN     NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_evaluation_sequence               IN     NUMBER,
    x_program_approver_ind              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
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
      x_revgr_evaluator_id                => x_revgr_evaluator_id,
      x_appl_revprof_revgr_id             => x_appl_revprof_revgr_id,
      x_person_id                         => x_person_id,
      x_person_number                     => x_person_number,
      x_evaluation_sequence               => x_evaluation_sequence,
      x_program_approver_ind              => x_program_approver_ind,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ad_rvgr_evaltr
      SET
        appl_revprof_revgr_id             = new_references.appl_revprof_revgr_id,
        person_id                         = new_references.person_id,
        person_number                     = new_references.person_number,
        evaluation_sequence               = new_references.evaluation_sequence,
        program_approver_ind              = new_references.program_approver_ind,
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
    x_revgr_evaluator_id                IN OUT NOCOPY NUMBER,
    x_appl_revprof_revgr_id             IN     NUMBER,
    x_person_id                         IN     NUMBER,
    x_person_number                     IN     VARCHAR2,
    x_evaluation_sequence               IN     NUMBER,
    x_program_approver_ind              IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_rvgr_evaltr
      WHERE    revgr_evaluator_id                = x_revgr_evaluator_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_revgr_evaluator_id,
        x_appl_revprof_revgr_id,
        x_person_id,
        x_person_number,
        x_evaluation_sequence,
        x_program_approver_ind,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_revgr_evaluator_id,
      x_appl_revprof_revgr_id,
      x_person_id,
      x_person_number,
      x_evaluation_sequence,
      x_program_approver_ind,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : ravi.boddu@oracle.com
  ||  Created On : 09-NOV-2001
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

    DELETE FROM igs_ad_rvgr_evaltr
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_rvgr_evaltr_pkg;

/
