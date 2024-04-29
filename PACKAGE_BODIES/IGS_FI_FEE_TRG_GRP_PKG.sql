--------------------------------------------------------
--  DDL for Package Body IGS_FI_FEE_TRG_GRP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FEE_TRG_GRP_PKG" AS
   /* $Header: IGSSI36B.pls 115.5 2003/02/12 10:14:46 shtatiko ship $*/
 l_rowid VARCHAR2(25);
  old_references IGS_FI_FEE_TRG_GRP%RowType;
  new_references IGS_FI_FEE_TRG_GRP%RowType;

  PROCEDURE Set_Column_Values (

    p_action IN VARCHAR2,

    x_rowid IN VARCHAR2 DEFAULT NULL,

    x_fee_trigger_group_number IN NUMBER DEFAULT NULL,

    x_description IN VARCHAR2 DEFAULT NULL,

    x_logical_delete_dt IN DATE DEFAULT NULL,

    x_comments IN VARCHAR2 DEFAULT NULL,

    x_fee_cat IN VARCHAR2 DEFAULT NULL,

    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,

    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,

    x_fee_type IN VARCHAR2 DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,

    x_created_by IN NUMBER DEFAULT NULL,

    x_last_update_date IN DATE DEFAULT NULL,

    x_last_updated_by IN NUMBER DEFAULT NULL,

    x_last_update_login IN NUMBER DEFAULT NULL

  ) AS



    CURSOR cur_old_ref_values IS

      SELECT   *

      FROM     IGS_FI_FEE_TRG_GRP

      WHERE    rowid = x_rowid;



  BEGIN



    l_rowid := x_rowid;



    -- Code for setting the Old and New Reference Values.

    -- Populate Old Values.

    Open cur_old_ref_values;

    Fetch cur_old_ref_values INTO old_references;

    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT', 'VALIDATE_INSERT')) THEN

      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

      Return;

    END IF;

    Close cur_old_ref_values;



    -- Populate New Values.

    new_references.fee_trigger_group_number := x_fee_trigger_group_number;

    new_references.description := x_description;

    new_references.logical_delete_dt := x_logical_delete_dt;

    new_references.comments := x_comments;

    new_references.fee_cat := x_fee_cat;

    new_references.fee_cal_type := x_fee_cal_type;

    new_references.fee_ci_sequence_number := x_fee_ci_sequence_number;

    new_references.fee_type := x_fee_type;

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



  END Set_Column_Values;



  -- Trigger description :-

  -- "OSS_TST".trg_ftg_br_iu

  -- BEFORE INSERT OR UPDATE

  -- ON IGS_FI_FEE_TRG_GRP

  -- FOR EACH ROW



  PROCEDURE BeforeRowInsertUpdate1(

    p_inserting IN BOOLEAN DEFAULT FALSE,

    p_updating IN BOOLEAN DEFAULT FALSE,

    p_deleting IN BOOLEAN DEFAULT FALSE

    ) AS

	v_message_name varchar2(30);

  BEGIN

	IF p_inserting THEN

		-- Validate fee trigger group can be inserted

		IF IGS_FI_VAL_FTG.finp_val_ftg_ins (

				new_references.fee_type,

				v_message_name) = FALSE THEN

			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

		END IF;

	END IF;

	IF p_updating THEN

		-- Validate fee trigger group can be logically deleted

		IF (new_references.logical_delete_dt IS NOT NULL) THEN

			IF IGS_FI_VAL_FTG.finp_val_ftg_lgl_del (

					new_references.fee_cat,

					new_references.fee_cal_type,

					new_references.fee_ci_sequence_number,

					new_references.fee_type,

					new_references.fee_trigger_group_number,

					v_message_name) = FALSE THEN

				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;

			END IF;

		END IF;

	END IF;
  END BeforeRowInsertUpdate1;

   PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	DEFAULT NULL,
   Column_Value 	IN	VARCHAR2	DEFAULT NULL
   ) AS
   /*----------------------------------------------------------------------------
  ||  Created By :
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  vvutukur        17-May-2002  removed upper check on fee_type,fee_cat columns.bug#2344826.
  ----------------------------------------------------------------------------*/

   BEGIN
     IF Column_Name is NULL THEN
        	NULL;
     ELSIF upper(Column_Name) = 'FEE_CAL_TYPE' then
        	new_references.fee_cal_type := Column_Value;
     ELSIF upper(Column_Name) = 'DESCRIPTION' then
        	new_references.description := Column_Value;
     ELSIF upper(Column_Name) = 'FEE_CI_SEQUENCE_NUMBER' then
     	new_references.fee_ci_sequence_number := igs_ge_number.to_num(Column_Value);
     ELSIF upper(Column_Name) = 'FEE_TRIGGER_GROUP_NUMBER' then
     	new_references.fee_trigger_group_number := igs_ge_number.to_num(Column_Value);
	END IF;

    IF upper(Column_Name) = 'FEE_CAL_TYPE' OR
     		column_name is NULL THEN
   		IF new_references.fee_cal_type <> UPPER(new_references.fee_cal_type) THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
     END IF;
  IF upper(Column_Name) = 'FEE_CI_SEQUENCE_NUMBER' OR
     		column_name is NULL THEN
   		IF new_references.fee_ci_sequence_number < 1 OR
		   new_references.fee_ci_sequence_number > 999999 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;

   			App_Exception.Raise_Exception;
   		END IF;
  END IF;
  IF upper(Column_Name) = 'FEE_TRIGGER_GROUP_NUMBER' OR
     		column_name is NULL THEN
   		IF new_references.fee_trigger_group_number < 1 OR
		   new_references.fee_trigger_group_number > 999999 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;

   			App_Exception.Raise_Exception;
   		END IF;
  END IF;
END Check_Constraints;

PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.fee_cat = new_references.fee_cat) AND
         (old_references.fee_cal_type = new_references.fee_cal_type) AND
         (old_references.fee_ci_sequence_number = new_references.fee_ci_sequence_number) AND
         (old_references.fee_type = new_references.fee_type)) OR
        ((new_references.fee_cat IS NULL) OR
         (new_references.fee_cal_type IS NULL) OR
         (new_references.fee_ci_sequence_number IS NULL) OR
         (new_references.fee_type IS NULL))) THEN
		      NULL;
    ELSIF NOT IGS_FI_F_CAT_FEE_LBL_PKG.Get_PK_For_Validation (
        new_references.fee_cat,
        new_references.fee_cal_type,
        new_references.fee_ci_sequence_number,
        new_references.fee_type
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_Existance;


  PROCEDURE Check_Child_Existance AS

  BEGIN
    IGS_PS_FEE_TRG_PKG.GET_FK_IGS_FI_FEE_TRG_GRP (
      OLD_references.fee_cat,
      OLD_references.fee_cal_type,
      OLD_references.fee_ci_sequence_number,
      OLD_references.fee_type,
      OLD_references.fee_trigger_group_number
      );

    IGS_FI_UNIT_FEE_TRG_PKG.GET_FK_IGS_FI_FEE_TRG_GRP (
      OLD_references.fee_cat,
      OLD_references.fee_cal_type,
      OLD_references.fee_ci_sequence_number,
      OLD_references.fee_type,
      OLD_references.fee_trigger_group_number
      );

    IGS_EN_UNITSETFEETRG_PKG.GET_FK_IGS_FI_FEE_TRG_GRP (
      OLD_references.fee_cat,
      OLD_references.fee_cal_type,
      old_references.fee_ci_sequence_number,
      OLD_references.fee_type,
      OLD_references.fee_trigger_group_number
      );
  END Check_Child_Existance;



  FUNCTION Get_PK_For_Validation (
    x_fee_cat IN VARCHAR2,
    x_fee_cal_type IN VARCHAR2,
    x_fee_ci_sequence_number IN NUMBER,
    x_fee_type IN VARCHAR2,
    x_fee_trigger_group_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FEE_TRG_GRP
      WHERE    fee_cat = x_fee_cat
      AND      fee_cal_type = x_fee_cal_type
      AND      fee_ci_sequence_number = x_fee_ci_sequence_number
      AND      fee_type = x_fee_type
      AND      fee_trigger_group_number = x_fee_trigger_group_number
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
END Get_PK_For_Validation;



  PROCEDURE Before_DML (

    p_action IN VARCHAR2,

    x_rowid IN  VARCHAR2 DEFAULT NULL,

    x_fee_trigger_group_number IN NUMBER DEFAULT NULL,

    x_description IN VARCHAR2 DEFAULT NULL,

    x_logical_delete_dt IN DATE DEFAULT NULL,

    x_comments IN VARCHAR2 DEFAULT NULL,

    x_fee_cat IN VARCHAR2 DEFAULT NULL,

    x_fee_cal_type IN VARCHAR2 DEFAULT NULL,

    x_fee_ci_sequence_number IN NUMBER DEFAULT NULL,

    x_fee_type IN VARCHAR2 DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,

    x_created_by IN NUMBER DEFAULT NULL,

    x_last_update_date IN DATE DEFAULT NULL,

    x_last_updated_by IN NUMBER DEFAULT NULL,

    x_last_update_login IN NUMBER DEFAULT NULL

  ) AS

  BEGIN



    Set_Column_Values (

      p_action,

      x_rowid,

      x_fee_trigger_group_number,

      x_description,

      x_logical_delete_dt,

      x_comments,

      x_fee_cat,

      x_fee_cal_type,

      x_fee_ci_sequence_number,

      x_fee_type,

      x_creation_date,

      x_created_by,

      x_last_update_date,

      x_last_updated_by,

      x_last_update_login

    );



    IF (p_action = 'INSERT') THEN

      -- Call all the procedures related to Before Insert.

      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
	 IF  Get_PK_For_Validation (
    		new_references.fee_cat,
    		new_references.fee_cal_type,
    		new_references.fee_ci_sequence_number,
    		new_references.fee_type,
    		new_references.fee_trigger_group_number ) THEN

		         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                         IGS_GE_MSG_STACK.ADD;
		         App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	 IF  Get_PK_For_Validation (
    		new_references.fee_cat,
    		new_references.fee_cal_type,
    		new_references.fee_ci_sequence_number,
    		new_references.fee_type,
    		new_references.fee_trigger_group_number ) THEN

		         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                         IGS_GE_MSG_STACK.ADD;

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
  X_FEE_CAT in VARCHAR2,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_FI_FEE_TRG_GRP
      where FEE_CAT = X_FEE_CAT
      and FEE_TRIGGER_GROUP_NUMBER = X_FEE_TRIGGER_GROUP_NUMBER
      and FEE_CAL_TYPE = X_FEE_CAL_TYPE
      and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
      and FEE_TYPE = X_FEE_TYPE;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;



 Before_DML(

  p_action=>'INSERT',

  x_rowid=>X_ROWID,

  x_comments=>X_COMMENTS,

  x_description=>X_DESCRIPTION,

  x_fee_cal_type=>X_FEE_CAL_TYPE,

  x_fee_cat=>X_FEE_CAT,

  x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,

  x_fee_trigger_group_number=>X_FEE_TRIGGER_GROUP_NUMBER,

  x_fee_type=>X_FEE_TYPE,

  x_logical_delete_dt=>X_LOGICAL_DELETE_DT,

  x_creation_date=>X_LAST_UPDATE_DATE,

  x_created_by=>X_LAST_UPDATED_BY,

  x_last_update_date=>X_LAST_UPDATE_DATE,

  x_last_updated_by=>X_LAST_UPDATED_BY,

  x_last_update_login=>X_LAST_UPDATE_LOGIN

);



  insert into IGS_FI_FEE_TRG_GRP (
    FEE_CAT,
    FEE_CAL_TYPE,
    FEE_CI_SEQUENCE_NUMBER,
    FEE_TYPE,
    FEE_TRIGGER_GROUP_NUMBER,
    DESCRIPTION,
    LOGICAL_DELETE_DT,
    COMMENTS,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.FEE_CAT,
    NEW_REFERENCES.FEE_CAL_TYPE,
    NEW_REFERENCES.FEE_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.FEE_TYPE,
    NEW_REFERENCES.FEE_TRIGGER_GROUP_NUMBER,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
    NEW_REFERENCES.COMMENTS,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_COMMENTS in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      LOGICAL_DELETE_DT,
      COMMENTS
    from IGS_FI_FEE_TRG_GRP
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
      AND ((tlinfo.COMMENTS = X_COMMENTS)
           OR ((tlinfo.COMMENTS is null)
               AND (X_COMMENTS is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE = 'R') then
    X_LAST_UPDATED_BY := FND_GLOBAL.USER_ID;
    if X_LAST_UPDATED_BY is NULL then
      X_LAST_UPDATED_BY := -1;
    end if;
    X_LAST_UPDATE_LOGIN :=FND_GLOBAL.LOGIN_ID;
    if X_LAST_UPDATE_LOGIN is NULL then
      X_LAST_UPDATE_LOGIN := -1;
    end if;
  else
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;



 Before_DML(

  p_action=>'UPDATE',

  x_rowid=>X_ROWID,

  x_comments=>X_COMMENTS,

  x_description=>X_DESCRIPTION,

  x_fee_cal_type=>X_FEE_CAL_TYPE,

  x_fee_cat=>X_FEE_CAT,

  x_fee_ci_sequence_number=>X_FEE_CI_SEQUENCE_NUMBER,

  x_fee_trigger_group_number=>X_FEE_TRIGGER_GROUP_NUMBER,

  x_fee_type=>X_FEE_TYPE,

  x_logical_delete_dt=>X_LOGICAL_DELETE_DT,

  x_creation_date=>X_LAST_UPDATE_DATE,

  x_created_by=>X_LAST_UPDATED_BY,

  x_last_update_date=>X_LAST_UPDATE_DATE,

  x_last_updated_by=>X_LAST_UPDATED_BY,

  x_last_update_login=>X_LAST_UPDATE_LOGIN

);




  update IGS_FI_FEE_TRG_GRP set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_FEE_CAT in VARCHAR2,
  X_FEE_TRIGGER_GROUP_NUMBER in NUMBER,
  X_FEE_CAL_TYPE in VARCHAR2,
  X_FEE_CI_SEQUENCE_NUMBER in NUMBER,
  X_FEE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_COMMENTS in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_FEE_TRG_GRP
     where FEE_CAT = X_FEE_CAT
     and FEE_TRIGGER_GROUP_NUMBER = X_FEE_TRIGGER_GROUP_NUMBER
     and FEE_CAL_TYPE = X_FEE_CAL_TYPE
     and FEE_CI_SEQUENCE_NUMBER = X_FEE_CI_SEQUENCE_NUMBER
     and FEE_TYPE = X_FEE_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_FEE_CAT,
     X_FEE_TRIGGER_GROUP_NUMBER,
     X_FEE_CAL_TYPE,
     X_FEE_CI_SEQUENCE_NUMBER,
     X_FEE_TYPE,
     X_DESCRIPTION,
     X_LOGICAL_DELETE_DT,
     X_COMMENTS,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
  X_ROWID,
   X_FEE_CAT,
   X_FEE_TRIGGER_GROUP_NUMBER,
   X_FEE_CAL_TYPE,
   X_FEE_CI_SEQUENCE_NUMBER,
   X_FEE_TYPE,
   X_DESCRIPTION,
   X_LOGICAL_DELETE_DT,
   X_COMMENTS,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
  delete from IGS_FI_FEE_TRG_GRP
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;

end IGS_FI_FEE_TRG_GRP_PKG;

/
