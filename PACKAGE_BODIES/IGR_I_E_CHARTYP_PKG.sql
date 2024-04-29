--------------------------------------------------------
--  DDL for Package Body IGR_I_E_CHARTYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGR_I_E_CHARTYP_PKG" AS
/* $Header: IGSRH04B.pls 120.0 2005/06/01 15:59:53 appldev noship $ */

  l_rowid VARCHAR2(25);
  old_references IGR_I_E_CHARTYP%RowType;
  new_references IGR_I_E_CHARTYP%RowType;

  PROCEDURE set_column_values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enquiry_characteristic_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igr_i_e_chartyp
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      fnd_message.set_name ('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      CLOSE cur_old_ref_values;
      app_exception.raise_exception;
      RETURN;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.enquiry_characteristic_type := x_enquiry_characteristic_type;
    new_references.description := x_description;
    new_references.closed_ind := x_closed_ind;
    IF (p_action = 'UPDATE') THEN
      new_references.creation_date := old_references.creation_date;
      new_references.created_by := old_references.created_by;
    ELSE
      new_references.creation_date := x_creation_date;
      new_references.created_by := x_created_by;
    END IF;
    new_references.last_update_date := x_last_update_date;
    new_references.last_updated_by := x_last_updated_by;
    new_references.last_update_login := x_last_update_login;

  END set_column_values;

  PROCEDURE check_child_existance AS
  BEGIN
    igr_i_a_chartyp_pkg.igr_i_e_chartyp (
      old_references.enquiry_characteristic_type
      );
  END check_child_existance;

  FUNCTION   get_pk_for_validation (
    x_enquiry_characteristic_type IN VARCHAR2,
    x_closed_ind IN     VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   ROWID
      FROM     igr_i_e_chartyp
      WHERE    enquiry_characteristic_type = x_enquiry_characteristic_type AND
               closed_ind = NVL(x_closed_ind,closed_ind);

    lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    Open cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      RETURN (TRUE);
    ELSE
      CLOSE cur_rowid;
      RETURN (FALSE);
    END IF;
    CLOSE cur_rowid;
  END get_pk_for_validation;


PROCEDURE Check_Constraints (
Column_Name	IN	VARCHAR2	DEFAULT NULL,
Column_Value 	IN	VARCHAR2	DEFAULT NULL
	) as
BEGIN

      IF  column_name IS NULL THEN
         NULL;
      ELSIF UPPER(column_name) = 'CLOSED_IND' THEN
         new_references.closed_ind:= column_value;
      ELSIF UPPER(column_name) = 'ENQUIRY_CHARACTERISTIC_TYPE' THEN
         new_references.enquiry_characteristic_type:= column_value;
      END IF;
     IF UPPER(column_name) = 'CLOSED_IND' OR
        column_name IS NULL THEN
        IF new_references.closed_ind <> UPPER(new_references.closed_ind) or new_references.closed_ind NOT IN ( 'Y' , 'N' ) THEN
          fnd_message.set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;
     END IF;

     IF UPPER(column_name) = 'ENQUIRY_CHARACTERISTIC_TYPE' OR
        column_name IS NULL THEN
        IF new_references.enquiry_characteristic_type <> UPPER(new_references.enquiry_characteristic_type) THEN
          fnd_message.set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
          igs_ge_msg_stack.add;
          app_exception.raise_exception;
        END IF;
     END IF;

END check_constraints;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enquiry_characteristic_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) as
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_enquiry_characteristic_type,
      x_description,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
    IF Get_PK_For_Validation (
          new_references.enquiry_characteristic_type
	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
 	App_Exception.Raise_Exception;
    END IF;

      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
         new_references.enquiry_characteristic_type
			             ) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        igs_ge_msg_stack.add;
	App_Exception.Raise_Exception;
    END IF;
	        Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	        Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
              Check_Child_Existance;
    END IF;

  END Before_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    CURSOR c IS SELECT ROWID FROM IGR_I_E_CHARTYP
      where ENQUIRY_CHARACTERISTIC_TYPE = X_ENQUIRY_CHARACTERISTIC_TYPE;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    IF X_LAST_UPDATED_BY IS NULL THEN
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    IF X_LAST_UPDATE_LOGIN is NULL THEN
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;

Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_closed_ind=>NVL(X_CLOSED_IND,'N'),
 x_description=>X_DESCRIPTION,
 x_enquiry_characteristic_type=>X_ENQUIRY_CHARACTERISTIC_TYPE,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );

  INSERT INTO IGR_I_E_CHARTYP (
    ENQUIRY_CHARACTERISTIC_TYPE,
    DESCRIPTION,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) VALUES (
    NEW_REFERENCES.ENQUIRY_CHARACTERISTIC_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.CLOSED_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  OPEN c;
  FETCH c INTO X_ROWID;
  IF (c%NOTFOUND) THEN
    CLOSE c;
    RAISE NO_DATA_FOUND;
  END IF;
  CLOSE c;

end INSERT_ROW;

PROCEDURE lock_row (
  X_ROWID in VARCHAR2,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2
) as
  CURSOR c1 IS SELECT
      DESCRIPTION,
      CLOSED_IND
    FROM IGR_I_E_CHARTYP
    WHERE ROWID = X_ROWID
    FOR UPDATE NOWAIT;
  tlinfo c1%rowtype;

begin
  OPEN c1;
  FETCH c1 INTO tlinfo;
  IF (c1%NOTFOUND) THEN
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    CLOSE c1;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
  ) THEN
    NULL;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;
  RETURN;
END LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  IF(X_MODE = 'I') THEN
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  ELSIF (X_MODE = 'R') THEN
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    END IF;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    END IF;
  ELSE
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  END IF;

Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_closed_ind=>X_CLOSED_IND,
 x_description=>X_DESCRIPTION,
 x_enquiry_characteristic_type=>X_ENQUIRY_CHARACTERISTIC_TYPE,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );

  UPDATE IGR_I_E_CHARTYP SET
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  WHERE ROWID = X_ROWID
  ;
  IF (sql%notfound) THEN
    RAISE NO_DATA_FOUND;
  END IF;
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENQUIRY_CHARACTERISTIC_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  CURSOR c1 IS SELECT ROWID FROM IGR_I_E_CHARTYP
     WHERE ENQUIRY_CHARACTERISTIC_TYPE = X_ENQUIRY_CHARACTERISTIC_TYPE
  ;

BEGIN
  OPEN c1;
  FETCH c1 INTO X_ROWID;
  IF (c1%notfound) THEN
    CLOSE c1;
    INSERT_ROW (
     X_ROWID,
     X_ENQUIRY_CHARACTERISTIC_TYPE,
     X_DESCRIPTION,
     X_CLOSED_IND,
     X_MODE);
    return;
  END IF;
  CLOSE c1;
  UPDATE_ROW (
   X_ROWID,
   X_ENQUIRY_CHARACTERISTIC_TYPE,
   X_DESCRIPTION,
   X_CLOSED_IND,
   X_MODE);
END ADD_ROW;

END IGR_I_E_CHARTYP_PKG;

/
