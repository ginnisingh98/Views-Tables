--------------------------------------------------------
--  DDL for Package Body IGS_PS_US_PRENR_CFG_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_US_PRENR_CFG_PKG" AS
/* $Header: IGSPI3CB.pls 115.8 2003/06/06 11:43:11 myoganat noship $ */

  l_rowid VARCHAR2(25);
  old_references igs_ps_us_prenr_cfg%ROWTYPE;
  new_references igs_ps_us_prenr_cfg%ROWTYPE;

  PROCEDURE set_column_values (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_mapping_set_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_sequence_no                       IN     NUMBER      DEFAULT NULL,
    x_unit_set_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : bayadav
  ||  Created On : 20-NOV-2001
  ||  Purpose : Initialises the Old and New references for the columns of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_ps_us_prenr_cfg
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
    new_references.mapping_set_cd                    := x_mapping_set_cd;
    new_references.sequence_no                       := x_sequence_no;
    new_references.unit_set_cd                       := x_unit_set_cd;


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

 PROCEDURE Check_Constraints (
 	Column_Name	IN	VARCHAR2	DEFAULT NULL,
 	Column_Value 	IN	VARCHAR2	DEFAULT NULL
 ) as

  BEGIN

  -- The following code checks for check constraints on the Columns.

    IF column_name is NULL THEN
        NULL;
    ELSIF  UPPER(column_name) = 'UNIT_SET_CDT' THEN
        new_references.unit_set_cd := column_value;
    ELSIF  UPPER(column_name) = 'SEQUENCE_NO' THEN
        new_references.sequence_no := IGS_GE_NUMBER.TO_NUM(column_value);
    ELSIF  UPPER(column_name) = 'MAPPING_SET_CD' THEN
        new_references.mapping_set_cd := column_value;

    END IF;
 END Check_Constraints;


 PROCEDURE Check_Uniqueness AS
  BEGIN

      IF Get_UK_For_Validation (
      new_references.unit_set_cd) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_PS_US_PRENR_CFG_UK');
	        IGS_GE_MSG_STACK.ADD;
	        App_Exception.Raise_Exception;
	END IF;
  END Check_Uniqueness ;

  PROCEDURE Check_Child_Existance AS
  /*
  ||  Created By : myoganat
  ||  Created On : 02-Jun-2003
  ||  Purpose : Validates the child existance.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
  BEGIN
    IGS_EN_UNIT_SET_MAP_PKG.get_fk_igs_ps_us_prenr_cfg (
      old_references.mapping_set_cd ,
      old_references.sequence_no);
  END Check_Child_Existance;


  FUNCTION get_pk_for_validation (
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : bayadav
  ||  Created On : 20-NOV-2001
  ||  Purpose : Validates the Primary Key of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_us_prenr_cfg
      WHERE    mapping_set_cd = x_mapping_set_cd
      AND      sequence_no = x_sequence_no
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
    x_unit_Set_cd IN varchar2
    )
  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_US_PRENR_CFG
      WHERE    unit_set_cd     = x_unit_set_cd
      AND ((l_rowid IS NULL) OR (rowid <> l_rowid))
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Return (TRUE);
    ELSE
	Close cur_rowid;
      Return (FALSE);
    END IF;
  END get_uk_for_validation;


 PROCEDURE get_fk_igs_en_unit_set(
    x_unit_set_cd IN VARCHAR2
    )as

    CURSOR cur_rowid IS
      SELECT   us.rowid
      FROM     IGS_EN_UNIT_SET_ALL us,IGS_EN_UNIT_SET_STAT uss
      WHERE   unit_set_cd = x_unit_set_cd
      AND    (expiry_dt is NULL or expiry_dt >= SYSDATE)
      AND us.unit_set_status = uss.unit_set_status AND
      uss.s_unit_set_status = 'ACTIVE' ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_PUPC_US_FK1');
		IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;



 END  get_fk_igs_en_unit_set;

  PROCEDURE before_dml (
    p_action                            IN     VARCHAR2,
    x_rowid                             IN     VARCHAR2    DEFAULT NULL,
    x_mapping_set_cd                    IN     VARCHAR2    DEFAULT NULL,
    x_sequence_no                       IN     NUMBER      DEFAULT NULL,
    x_unit_set_cd                       IN     VARCHAR2    DEFAULT NULL,
    x_creation_date                     IN     DATE        DEFAULT NULL,
    x_created_by                        IN     NUMBER      DEFAULT NULL,
    x_last_update_date                  IN     DATE        DEFAULT NULL,
    x_last_updated_by                   IN     NUMBER      DEFAULT NULL,
    x_last_update_login                 IN     NUMBER      DEFAULT NULL
  ) AS
  /*
  ||  Created By : bayadav
  ||  Created On : 20-NOV-2001
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
      x_mapping_set_cd,
      x_sequence_no,
      x_unit_set_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation(
             new_references.mapping_set_cd,
             new_references.sequence_no
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
	Check_Constraints;
	Check_Uniqueness;
     ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Update.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
      IF ( get_pk_for_validation (
             new_references.mapping_set_cd,
             new_references.sequence_no
           )
         ) THEN
        fnd_message.set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
        app_exception.raise_exception;
      END IF;
       Check_Constraints;
	Check_Uniqueness;
     ELSIF (p_action = 'VALIDATE_UPDATE') THEN
        Check_Constraints;
	Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Check_Child_Existance;
    END IF;

  l_rowid:=NULL;

  END before_dml;


  PROCEDURE insert_row (
    x_rowid                             IN OUT NOCOPY VARCHAR2,
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : bayadav
  ||  Created On : 20-NOV-2001
  ||  Purpose : Handles the INSERT DML logic for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c IS
      SELECT   rowid
      FROM     igs_ps_us_prenr_cfg
      WHERE    mapping_set_cd                    = x_mapping_set_cd
      AND      sequence_no                       = x_sequence_no;

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
      x_mapping_set_cd                    => x_mapping_set_cd,
      x_sequence_no                       => x_sequence_no,
      x_unit_set_cd                       => x_unit_set_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    INSERT INTO igs_ps_us_prenr_cfg (
      mapping_set_cd,
      sequence_no,
      unit_set_cd,
      creation_date,
      created_by,
      last_update_date,
      last_updated_by,
      last_update_login
    ) VALUES (
      new_references.mapping_set_cd,
      new_references.sequence_no,
      new_references.unit_set_cd,
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
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2
  ) AS
  /*
  ||  Created By : bayadav
  ||  Created On : 20-NOV-2001
  ||  Purpose : Handles the LOCK mechanism for the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT
        unit_set_cd
      FROM  igs_ps_us_prenr_cfg
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

    IF (tlinfo.unit_set_cd = x_unit_set_cd) THEN

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
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : bayadav
  ||  Created On : 20-NOV-2001
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
      x_mapping_set_cd                    => x_mapping_set_cd,
      x_sequence_no                       => x_sequence_no,
      x_unit_set_cd                       => x_unit_set_cd,
      x_creation_date                     => x_last_update_date,
      x_created_by                        => x_last_updated_by,
      x_last_update_date                  => x_last_update_date,
      x_last_updated_by                   => x_last_updated_by,
      x_last_update_login                 => x_last_update_login
    );

    UPDATE igs_ps_us_prenr_cfg
      SET
        unit_set_cd                       = new_references.unit_set_cd,
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
    x_mapping_set_cd                    IN     VARCHAR2,
    x_sequence_no                       IN     NUMBER,
    x_unit_set_cd                       IN     VARCHAR2,
    x_mode                              IN     VARCHAR2 DEFAULT 'R'
  ) AS
  /*
  ||  Created By : bayadav
  ||  Created On : 20-NOV-2001
  ||  Purpose : Adds a row if there is no existing row, otherwise updates existing row in the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c1 IS
      SELECT   rowid
      FROM     igs_ps_us_prenr_cfg
      WHERE    mapping_set_cd                    = x_mapping_set_cd
      AND      sequence_no                       = x_sequence_no;

  BEGIN

    OPEN c1;
    FETCH c1 INTO x_rowid;
    IF (c1%NOTFOUND) THEN
      CLOSE c1;

      insert_row (
        x_rowid,
        x_mapping_set_cd,
        x_sequence_no,
        x_unit_set_cd,
        x_mode
      );
      RETURN;
    END IF;
    CLOSE c1;

    update_row (
      x_rowid,
      x_mapping_set_cd,
      x_sequence_no,
      x_unit_set_cd,
      x_mode
    );

  END add_row;


  PROCEDURE delete_row (
    x_rowid IN VARCHAR2
  ) AS
  /*
  ||  Created By : bayadav
  ||  Created On : 20-NOV-2001
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

    DELETE FROM igs_ps_us_prenr_cfg
    WHERE rowid = x_rowid;

    IF (SQL%NOTFOUND) THEN
      RAISE NO_DATA_FOUND;
    END IF;

  END delete_row;


END igs_ps_us_prenr_cfg_pkg;

/
