--------------------------------------------------------
--  DDL for Package Body IGS_AD_PRCS_CAT_STEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_PRCS_CAT_STEP_PKG" AS
/* $Header: IGSAI37B.pls 115.23 2003/10/30 13:20:14 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AD_PRCS_CAT_STEP_ALL%RowType;
  new_references IGS_AD_PRCS_CAT_STEP_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_org_id IN NUMBER,
    x_admission_cat IN VARCHAR2 ,
    x_s_admission_process_type IN VARCHAR2 ,
    x_s_admission_step_type IN VARCHAR2 ,
    x_mandatory_step_ind IN VARCHAR2 ,
    x_step_type_restriction_num IN NUMBER ,
    x_step_order_num IN NUMBER ,
    x_step_group_type IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_PRCS_CAT_STEP_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
       Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.org_id := x_org_id;
    new_references.admission_cat := x_admission_cat;
    new_references.s_admission_process_type := x_s_admission_process_type;
    new_references.s_admission_step_type := x_s_admission_step_type;
    new_references.mandatory_step_ind := x_mandatory_step_ind;
    new_references.step_type_restriction_num := x_step_type_restriction_num;
    new_references.step_order_num := x_step_order_num;
    new_references.step_group_type := x_step_group_type;
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

  PROCEDURE BeforeRowInsertUpdate(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE
    ) as
     v_message_name                  VARCHAR2(30);
  BEGIN
        IF (p_inserting OR (p_updating AND (old_references.s_admission_step_type <> new_references.s_admission_step_type))) THEN
	 IF NOT IGS_TR_VAL_TRI.TRKP_VAL_TRI_TYPE (new_references.s_admission_step_type,
	                                          v_message_name) THEN
             Fnd_Message.Set_Name('IGS', v_message_name);
             IGS_GE_MSG_STACK.ADD;
             App_Exception.Raise_Exception;
	 END IF;
        END IF;
  END BeforeRowInsertUpdate;

  -- Trigger description :-
  -- "OSS_TST".trg_apcs_br_iud
  -- BEFORE INSERT OR DELETE OR UPDATE
  -- ON IGS_AD_PRCS_CAT_STEP
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_admission_cat	IGS_AD_PRCS_CAT.admission_cat%TYPE;
	v_message_name	VARCHAR2(30);
  BEGIN

  	IF NVL(new_references.step_group_type,'TRACK') <> 'TRACK' THEN
	  IF NVL(p_inserting, FALSE) THEN
		  -- Validate the system admission step type closed indicator.
		  IF IGS_AD_VAL_APCS.admp_val_sasty_clsd (
				new_references.s_admission_step_type,
				v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		  END IF;
	  END IF;

	END IF;
	-- Set the Admission Category value.
	IF NVL(p_deleting, FALSE) THEN
		v_admission_cat := old_references.admission_cat;
	ELSE
		v_admission_cat := new_references.admission_cat;
	END IF;
	-- Validate the admission category closed indicator.
	IF IGS_AD_VAL_ACCT.admp_val_ac_closed (
			v_admission_cat,
			v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
	END IF;

	IF NVL(new_references.step_group_type,'TRACK') <> 'TRACK' THEN

	-- If the step_group_type is not 'TRACK' only then perform the
	-- following checks per bug 2431650 as these are not required for
	-- step_group_type of 'TRACK'

	-- Validate the Mandatory Step Indicator.
	IF NVL(p_inserting, FALSE) OR
		( NVL(p_updating, FALSE) AND
		 old_references.mandatory_step_ind <> new_references.mandatory_step_ind) THEN
		IF IGS_AD_VAL_APCS.admp_val_apcs_mndtry (
				new_references.s_admission_step_type,
				new_references.mandatory_step_ind,
				v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the Step Type Restriction Number.
	IF NVL(p_inserting, FALSE) OR
		(NVL(p_updating, FALSE) AND
		 NVL(old_references.step_type_restriction_num, -1) <>
			NVL(new_references.step_type_restriction_num, -1)) THEN
		IF IGS_AD_VAL_APCS.admp_val_apcs_rstrct (
				new_references.s_admission_step_type,
				new_references.step_type_restriction_num,
				v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the Step Order Number.
	IF NVL(p_inserting, FALSE) OR
		(NVL(p_updating, FALSE) AND
		 NVL(old_references.step_order_num, -1) <>
			NVL(new_references.step_order_num, -1)) THEN
		IF IGS_AD_VAL_APCS.admp_val_apcs_order (
				new_references.s_admission_step_type,
				new_references.step_order_num,
				v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;

	END IF;


  END BeforeRowInsertUpdateDelete1;

PROCEDURE Check_Constraints (
	 Column_Name	IN	VARCHAR2,
	 Column_Value 	IN	VARCHAR2
)
 AS
 BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'MANDATORY_STEP_IND' then
     new_references.mandatory_step_ind := column_value;
 ELSIF upper(Column_name) = 'STEP_TYPE_RESTRICTION_NUM' then
     new_references.step_type_restriction_num := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'STEP_ORDER_NUM' then
     new_references.step_order_num := igs_ge_number.to_num(column_value);
 ELSIF upper(Column_name) = 'ADMISSION_CAT' then
     new_references.admission_cat := column_value;
 ELSIF upper(Column_name) = 'S_ADMISSION_PROCESS_TYPE' then
     new_references.s_admission_process_type := column_value;
 ELSIF upper(Column_name) = 'S_ADMISSION_STEP_TYPE' then
     new_references.s_admission_step_type := column_value;
 ELSIF upper(Column_name) = 'STEP_GROUP_TYPE' then
     new_references.step_group_type := column_value;

END IF;


IF upper(column_name) = 'MANDATORY_STEP_IND' OR
     column_name is null Then
     IF new_references.mandatory_step_ind NOT IN ('Y','N') Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'STEP_TYPE_RESTRICTION_NUM' OR
     column_name is null Then
     IF new_references.step_type_restriction_num  < 1 OR
          new_references.step_type_restriction_num > 99 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'STEP_ORDER_NUM' OR
     column_name is null Then
     IF new_references.step_order_num  < 1 OR
          new_references.step_order_num > 999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'ADMISSION_CAT' OR
     column_name is null Then
     IF new_references.admission_cat <>
UPPER(new_references.admission_cat) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;
IF upper(column_name) = 'MANDATORY_STEP_IND' OR
     column_name is null Then
     IF new_references.mandatory_step_ind <>
		UPPER(new_references.mandatory_step_ind) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;
IF upper(column_name) = 'S_ADMISSION_PROCESS_TYPE' OR
     column_name is null Then
     IF new_references.s_admission_process_type <>
		UPPER(new_references.s_admission_process_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;
IF upper(column_name) = 'S_ADMISSION_STEP_TYPE' OR
     column_name is null Then
     IF new_references.s_admission_step_type <>
		UPPER(new_references.s_admission_step_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'STEP_GROUP_TYPE' OR
     column_name is null Then
     IF new_references.step_group_type <>
		UPPER(new_references.step_group_type) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'STEP_GROUP_TYPE' OR
     column_name is null Then
     IF new_references.step_group_type IS NULL Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_MANDATORY_FLD');
	   IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;


END Check_Constraints;



  PROCEDURE Check_Parent_Existance AS
    CURSOR  cur_s_tracking_type IS
         SELECT S_TRACKING_TYPE
     FROM   IGS_TR_TYPE
     WHERE  TRACKING_TYPE = new_references.s_admission_step_type;

    s_tracking_type_rec  cur_s_tracking_type%ROWTYPE;
  BEGIN
  /*=======================================================================+
  --
  -- HISTORY
  -- nsinha            03-Aug-2001      BUG Enh No : 1905651 Added
  --                                    cur_s_tracking_type check.
  *=======================================================================*/

    IF (((old_references.admission_cat = new_references.admission_cat) AND
         (old_references.s_admission_process_type = new_references.s_admission_process_type)) OR
        ((new_references.admission_cat IS NULL) OR
         (new_references.s_admission_process_type IS NULL))) THEN
      NULL;
    ELSE
	IF NOT IGS_AD_PRCS_CAT_PKG.Get_PK_For_Validation (
      	  new_references.admission_cat,
	        new_references.s_admission_process_type,
          'N'
      	  ) THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		 IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
	     	 END IF;
    END IF;

    IF (((old_references.s_admission_step_type = new_references.s_admission_step_type)) OR
        ((new_references.s_admission_step_type IS NULL))) THEN
      NULL;
    ELSE
      OPEN  cur_s_tracking_type;
      FETCH cur_s_tracking_type INTO s_tracking_type_rec;

      IF cur_s_tracking_type%NOTFOUND THEN
	    -- Record is not for TRACKING.
        IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation(
		  'ADMISSION_STEP_TYPE',
		  new_references.s_admission_step_type
	  ) THEN
          CLOSE cur_s_tracking_type;
	      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	      IGS_GE_MSG_STACK.ADD;
	      App_Exception.Raise_Exception;
       END IF;
     END IF;
     CLOSE cur_s_tracking_type;
    END IF;
  END Check_Parent_Existance;

FUNCTION Get_PK_For_Validation (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2,
    x_s_admission_step_type IN VARCHAR2,
    x_step_group_type IN VARCHAR2
    )
RETURN BOOLEAN
AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRCS_CAT_STEP_ALL
      WHERE    admission_cat = x_admission_cat
      AND      s_admission_process_type = x_s_admission_process_type
      AND      s_admission_step_type = x_s_admission_step_type
      AND      step_group_type = x_step_group_type
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

  PROCEDURE GET_FK_IGS_AD_PRCS_CAT (
    x_admission_cat IN VARCHAR2,
    x_s_admission_process_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRCS_CAT_STEP_ALL
      WHERE    admission_cat = x_admission_cat
      AND      s_admission_process_type = x_s_admission_process_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCS_APC_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
       Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_AD_PRCS_CAT;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW(
    x_s_admission_step_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AD_PRCS_CAT_STEP_ALL
      WHERE    s_admission_step_type = x_s_admission_step_type
      AND      step_group_type <> 'TRACK';

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_APCS_SLV_FK');
	  IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_org_id IN NUMBER,
    x_admission_cat IN VARCHAR2 ,
    x_s_admission_process_type IN VARCHAR2 ,
    x_s_admission_step_type IN VARCHAR2 ,
    x_mandatory_step_ind IN VARCHAR2 ,
    x_step_type_restriction_num IN NUMBER ,
    x_step_order_num IN NUMBER ,
    x_step_group_type IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_id,
      x_admission_cat,
      x_s_admission_process_type,
      x_s_admission_step_type,
      x_mandatory_step_ind,
      x_step_type_restriction_num,
      x_step_order_num,
      x_step_group_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

IF (p_action = 'INSERT') THEN
     BeforeRowInsertUpdate(p_inserting => TRUE);
     BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE, p_updating => FALSE, p_deleting => FALSE );
      IF  Get_PK_For_Validation (
          new_references.admission_cat,
          new_references.s_admission_process_type,
          new_references.s_admission_step_type,
          new_references.step_group_type
          ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
		 IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
 ELSIF (p_action = 'UPDATE') THEN
       BeforeRowInsertUpdate(p_updating => TRUE);
       BeforeRowInsertUpdateDelete1 ( p_updating => TRUE, p_inserting => FALSE, p_deleting => FALSE );
       Check_Constraints;
       Check_Parent_Existance;
 ELSIF (p_action = 'DELETE') THEN
      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE,p_inserting => FALSE,p_updating => FALSE);
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.admission_cat,
          new_references.s_admission_process_type,
          new_references.s_admission_step_type,
          new_references.step_group_type
          ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
		 IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints;
 END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID IN NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_S_ADMISSION_STEP_TYPE in VARCHAR2,
  X_MANDATORY_STEP_IND in VARCHAR2,
  X_STEP_TYPE_RESTRICTION_NUM in NUMBER,
  X_STEP_ORDER_NUM in NUMBER,
  X_STEP_GROUP_TYPE in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
/*-----------------------------------------------------------------------------------
--History
--Who             When          What
--sbaliga	12-feb-2002	Modified call to before_dml by assigning to x_org_id
--				the value of function igs_ge_gen_003.get_org_id
--				as part of SWCR006 build.
---------------------------------------------------------------------------------------*/

    cursor C is select ROWID from IGS_AD_PRCS_CAT_STEP_ALL
      where ADMISSION_CAT = X_ADMISSION_CAT
      and S_ADMISSION_PROCESS_TYPE = X_S_ADMISSION_PROCESS_TYPE
      and S_ADMISSION_STEP_TYPE = X_S_ADMISSION_STEP_TYPE
      and STEP_GROUP_TYPE = X_STEP_GROUP_TYPE;
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
  Before_DML(p_action =>'INSERT',
  x_rowid =>X_ROWID,
  x_org_id => igs_ge_gen_003.get_org_id,
  x_admission_cat => X_ADMISSION_CAT,
  x_s_admission_process_type => X_S_ADMISSION_PROCESS_TYPE,
  x_s_admission_step_type => X_S_ADMISSION_STEP_TYPE,
  x_mandatory_step_ind => NVL(X_MANDATORY_STEP_IND,'Y'),
  x_step_type_restriction_num => X_STEP_TYPE_RESTRICTION_NUM,
  x_step_order_num => X_STEP_ORDER_NUM,
  x_step_group_type => X_STEP_GROUP_TYPE,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

  insert into IGS_AD_PRCS_CAT_STEP_ALL (
    ORG_ID,
    ADMISSION_CAT,
    S_ADMISSION_PROCESS_TYPE,
    S_ADMISSION_STEP_TYPE,
    MANDATORY_STEP_IND,
    STEP_TYPE_RESTRICTION_NUM,
    STEP_ORDER_NUM,
    STEP_GROUP_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.ADMISSION_CAT,
    NEW_REFERENCES.S_ADMISSION_PROCESS_TYPE,
    NEW_REFERENCES.S_ADMISSION_STEP_TYPE,
    NEW_REFERENCES.MANDATORY_STEP_IND,
    NEW_REFERENCES.STEP_TYPE_RESTRICTION_NUM,
    NEW_REFERENCES.STEP_ORDER_NUM,
    NEW_REFERENCES.STEP_GROUP_TYPE,
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
After_DML(
 p_action =>'INSERT',
 x_rowid => X_ROWID
);
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_S_ADMISSION_STEP_TYPE in VARCHAR2,
  X_MANDATORY_STEP_IND in VARCHAR2,
  X_STEP_TYPE_RESTRICTION_NUM in NUMBER,
  X_STEP_ORDER_NUM in NUMBER,
  X_STEP_GROUP_TYPE in VARCHAR2
) AS
  cursor c1 is select
      MANDATORY_STEP_IND,
      STEP_TYPE_RESTRICTION_NUM,
      STEP_ORDER_NUM
    from IGS_AD_PRCS_CAT_STEP_ALL
    where ROWID = X_ROWID for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    close c1;
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.MANDATORY_STEP_IND = X_MANDATORY_STEP_IND)
      AND ((tlinfo.STEP_TYPE_RESTRICTION_NUM = X_STEP_TYPE_RESTRICTION_NUM)
           OR ((tlinfo.STEP_TYPE_RESTRICTION_NUM is null)
               AND (X_STEP_TYPE_RESTRICTION_NUM is null)))
      AND ((tlinfo.STEP_ORDER_NUM = X_STEP_ORDER_NUM)
           OR ((tlinfo.STEP_ORDER_NUM is null)
               AND (X_STEP_ORDER_NUM is null)))
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
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_S_ADMISSION_STEP_TYPE in VARCHAR2,
  X_MANDATORY_STEP_IND in VARCHAR2,
  X_STEP_TYPE_RESTRICTION_NUM in NUMBER,
  X_STEP_ORDER_NUM in NUMBER,
  X_STEP_GROUP_TYPE in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
  /*-----------------------------------------------------------------------------------
--History
--Who             When          What
--sbaliga	12-feb-2002	Modified call to before_dml by assigning to x_org_id
--				the value of function igs_ge_gen_003.get_org_id
--				as part of SWCR006 build.
---------------------------------------------------------------------------------------*/
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
  Before_DML(p_action =>'UPDATE',
  x_rowid =>X_ROWID,
  x_org_id  => igs_ge_gen_003.get_org_id,
  x_admission_cat => X_ADMISSION_CAT,
  x_s_admission_process_type => X_S_ADMISSION_PROCESS_TYPE,
  x_s_admission_step_type => X_S_ADMISSION_STEP_TYPE,
  x_mandatory_step_ind => X_MANDATORY_STEP_IND,
  x_step_type_restriction_num => X_STEP_TYPE_RESTRICTION_NUM,
  x_step_order_num => X_STEP_ORDER_NUM,
  x_step_group_type => X_STEP_GROUP_TYPE,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date => X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN
  );

update IGS_AD_PRCS_CAT_STEP_ALL set
    MANDATORY_STEP_IND = NEW_REFERENCES.MANDATORY_STEP_IND,
    STEP_TYPE_RESTRICTION_NUM = NEW_REFERENCES.STEP_TYPE_RESTRICTION_NUM,
    STEP_ORDER_NUM = NEW_REFERENCES.STEP_ORDER_NUM,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML(
 p_action =>'UPDATE',
 x_rowid => X_ROWID
);
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ORG_ID in NUMBER,
  X_ADMISSION_CAT in VARCHAR2,
  X_S_ADMISSION_PROCESS_TYPE in VARCHAR2,
  X_S_ADMISSION_STEP_TYPE in VARCHAR2,
  X_MANDATORY_STEP_IND in VARCHAR2,
  X_STEP_TYPE_RESTRICTION_NUM in NUMBER,
  X_STEP_ORDER_NUM in NUMBER,
  X_STEP_GROUP_TYPE in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_AD_PRCS_CAT_STEP_ALL
     where ADMISSION_CAT = X_ADMISSION_CAT
     and S_ADMISSION_PROCESS_TYPE = X_S_ADMISSION_PROCESS_TYPE
     and S_ADMISSION_STEP_TYPE = X_S_ADMISSION_STEP_TYPE
     and step_group_Type = X_STEP_GROUP_TYPE ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ORG_ID,
     X_ADMISSION_CAT,
     X_S_ADMISSION_PROCESS_TYPE,
     X_S_ADMISSION_STEP_TYPE,
     X_MANDATORY_STEP_IND,
     X_STEP_TYPE_RESTRICTION_NUM,
     X_STEP_ORDER_NUM,
     X_STEP_GROUP_TYPE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ADMISSION_CAT,
   X_S_ADMISSION_PROCESS_TYPE,
   X_S_ADMISSION_STEP_TYPE,
   X_MANDATORY_STEP_IND,
   X_STEP_TYPE_RESTRICTION_NUM,
   X_STEP_ORDER_NUM,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID,
 x_org_id => NULL
);

  delete from IGS_AD_PRCS_CAT_STEP_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML(
 p_action =>'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;

end IGS_AD_PRCS_CAT_STEP_PKG;

/
