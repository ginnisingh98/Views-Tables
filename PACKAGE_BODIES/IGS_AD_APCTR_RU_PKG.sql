--------------------------------------------------------
--  DDL for Package Body IGS_AD_APCTR_RU_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_APCTR_RU_PKG" AS
/* $Header: IGSAIF0B.pls 115.8 2003/10/30 13:26:02 rghosh noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ad_apctr_ru_all%ROWTYPE;
  new_references igs_ad_apctr_ru_all%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_apc_trk_ru_id                     IN     NUMBER      DEFAULT NULL,
    x_admission_cat                     IN     VARCHAR2    DEFAULT NULL,
    x_s_admission_process_type          IN     VARCHAR2    DEFAULT NULL,
    x_s_rule_call_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_rul_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : sandhya.amaresh@oracle.com
  ||  Created On : 29-AUG-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_APCTR_RU_ALL
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
    new_references.apc_trk_ru_id                     := x_apc_trk_ru_id;
    new_references.admission_cat                     := x_admission_cat;
    new_references.s_admission_process_type          := x_s_admission_process_type;
    new_references.s_rule_call_cd                    := x_s_rule_call_cd;
    new_references.rul_sequence_number               := x_rul_sequence_number;

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

  PROCEDURE Check_Parent_Existance as
  BEGIN

    IF (((old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
        'ADMISSION_PROCESS_TYPE',
	  new_references.s_admission_process_type
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.s_rule_call_cd = new_references.s_rule_call_cd)) OR
        ((new_references.s_rule_call_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
         'TRACKING_TYPE',
	  new_references.s_rule_call_cd
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.admission_cat = new_references.admission_cat)) OR
        ((new_references.admission_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_AD_CAT_PKG.Get_PK_For_Validation (
	          new_references.admission_cat,
            'N'
	    ) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.rul_sequence_number = new_references.rul_sequence_number)) OR
        ((new_references.rul_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_RU_RULE_PKG.Get_PK_For_Validation (
	  new_references.rul_sequence_number
	) THEN
	Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
	App_Exception.Raise_Exception;
	END IF;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE GET_FK_IGS_AD_CAT(
    x_admission_cat IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APCTR_RU_ALL
      WHERE    admission_cat = x_admission_cat;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATR_AC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_CAT;

  PROCEDURE GET_FK_IGS_RU_RULE(
    x_rul_sequence_number IN VARCHAR2
    ) as

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_APCTR_RU_ALL
      WHERE    rul_sequence_number = x_rul_sequence_number;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ATR_RU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_RU_RULE;

  FUNCTION get_pk_for_validation (
    x_apc_trk_ru_id                     IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : sandhya.amaresh@oracle.com
  ||  Created On : 29-AUG-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_apctr_ru_all
      WHERE    apc_trk_ru_id = x_apc_trk_ru_id
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
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_apc_trk_ru_id                     IN     NUMBER      DEFAULT NULL,
    x_admission_cat                     IN     VARCHAR2    DEFAULT NULL,
    x_s_admission_process_type          IN     VARCHAR2    DEFAULT NULL,
    x_s_rule_call_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_rul_sequence_number               IN     NUMBER      DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : sandhya.amaresh@oracle.com
  ||  Created On : 29-AUG-2001
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
      x_apc_trk_ru_id,
      x_admission_cat,
      x_s_admission_process_type,
      x_s_rule_call_cd,
      x_rul_sequence_number,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.apc_trk_ru_id
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.apc_trk_ru_id
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
    x_apc_trk_ru_id                     IN OUT NOCOPY NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sandhya.amaresh@oracle.com
  ||  Created On : 29-AUG-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ad_apctr_ru_all
      WHERE    apc_trk_ru_id                     = x_apc_trk_ru_id;

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

    new_references.org_id := igs_ge_gen_003.get_org_id;

    x_apc_trk_ru_id := -1;
    before_dml(
      p_action                            => 'INSERT',
      x_rowid                             => x_rowid,
      x_apc_trk_ru_id                     => x_apc_trk_ru_id,
      x_admission_cat                     => x_admission_cat,
      x_s_admission_process_type          => x_s_admission_process_type,
      x_s_rule_call_cd                    => x_s_rule_call_cd,
      x_rul_sequence_number               => x_rul_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ad_apctr_ru_all (
      apc_trk_ru_id,
      admission_cat,
      s_admission_process_type,
      s_rule_call_cd,
      rul_sequence_number,
      org_id,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      igs_ad_apctr_ru_s.NEXTVAL,
      new_references.admission_cat,
      new_references.s_admission_process_type,
      new_references.s_rule_call_cd,
      new_references.rul_sequence_number,
      new_references.org_id,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    )RETURNING apc_trk_ru_id INTO x_apc_trk_ru_id;

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
    x_apc_trk_ru_id                     IN     NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER
  ) AS
  /*
  ||  Created By : sandhya.amaresh@oracle.com
  ||  Created On : 29-AUG-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        admission_cat,
        s_admission_process_type,
        s_rule_call_cd,
        rul_sequence_number
      FROM  igs_ad_apctr_ru_all
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
        (tlinfo.admission_cat = x_admission_cat)
        AND (tlinfo.s_admission_process_type = x_s_admission_process_type)
        AND ((tlinfo.s_rule_call_cd = x_s_rule_call_cd) OR ((tlinfo.s_rule_call_cd IS NULL) AND (X_s_rule_call_cd IS NULL)))
        AND (tlinfo.rul_sequence_number = x_rul_sequence_number)
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
    x_apc_trk_ru_id                     IN     NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sandhya.amaresh@oracle.com
  ||  Created On : 29-AUG-2001
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
      x_apc_trk_ru_id                     => x_apc_trk_ru_id,
      x_admission_cat                     => x_admission_cat,
      x_s_admission_process_type          => x_s_admission_process_type,
      x_s_rule_call_cd                    => x_s_rule_call_cd,
      x_rul_sequence_number               => x_rul_sequence_number,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ad_apctr_ru_all
      SET
        admission_cat                     = new_references.admission_cat,
        s_admission_process_type          = new_references.s_admission_process_type,
        s_rule_call_cd                    = new_references.s_rule_call_cd,
        rul_sequence_number               = new_references.rul_sequence_number,
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
    x_apc_trk_ru_id                     IN OUT NOCOPY NUMBER,
    x_admission_cat                     IN     VARCHAR2,
    x_s_admission_process_type          IN     VARCHAR2,
    x_s_rule_call_cd                    IN     VARCHAR2,
    x_rul_sequence_number               IN     NUMBER,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : sandhya.amaresh@oracle.com
  ||  Created On : 29-AUG-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ad_apctr_ru_all
      WHERE    apc_trk_ru_id                     = x_apc_trk_ru_id;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_apc_trk_ru_id,
        x_admission_cat,
        x_s_admission_process_type,
        x_s_rule_call_cd,
        x_rul_sequence_number,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_apc_trk_ru_id,
      x_admission_cat,
      x_s_admission_process_type,
      x_s_rule_call_cd,
      x_rul_sequence_number,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : sandhya.amaresh@oracle.com
  ||  Created On : 29-AUG-2001
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

    DELETE FROM igs_ad_apctr_ru_all
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ad_apctr_ru_pkg;

/
