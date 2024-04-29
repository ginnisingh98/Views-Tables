--------------------------------------------------------
--  DDL for Package Body IGS_EN_CAT_PRC_STEP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_CAT_PRC_STEP_PKG" AS
/* $Header: IGSEI25B.pls 115.8 2003/06/11 06:28:29 rnirwani ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_ge_gen_004.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_EN_CAT_PRC_STEP_ALL%RowType;
  new_references IGS_EN_CAT_PRC_STEP_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_s_student_comm_type IN VARCHAR2 DEFAULT NULL,
    x_enr_method_type IN VARCHAR2 DEFAULT NULL,
    x_s_enrolment_step_type IN VARCHAR2 DEFAULT NULL,
    x_step_order_num IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER  DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_CAT_PRC_STEP_ALL
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
    new_references.enrolment_cat := x_enrolment_cat;
    new_references.s_student_comm_type := x_s_student_comm_type;
    new_references.enr_method_type := x_enr_method_type;
    new_references.s_enrolment_step_type := x_s_enrolment_step_type;
    new_references.step_order_num := x_step_order_num;
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
    new_references.org_id := x_org_id ;
  END Set_Column_Values;

  -- Trigger description :-
  -- "OSS_TST".trg_ecps_br_i
  -- BEFORE INSERT
  -- ON IGS_EN_CAT_PRC_STEP
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsert1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	varchar2(30);
  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_CAT_PRC_STEP_ALL') THEN
		IF p_inserting THEN
			-- Validate the system enrolment step type
			IF IGS_EN_VAL_ECPS.enrp_val_ecps_sest(
					new_references.s_enrolment_step_type,
	 				 v_message_name) = FALSE THEN
				fnd_message.set_name('IGS',v_message_name);
IGS_GE_MSG_STACK.ADD;
				app_exception.raise_exception;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsert1;

  procedure Check_constraints(
	column_name IN VARCHAR2 DEFAULT NULL,
	column_value IN VARCHAR2 DEFAULT NULL
   ) AS
begin
	IF column_name is null then
	   NULL;
	ELSIF upper(column_name) = 'ENROLMENT_CAT' then
		new_references.enrolment_cat := column_value;
	ELSIF upper(column_name) = 'ENR_METHOD_TYPE' then
		new_references.enr_method_type := column_value;
	ELSIF upper(column_name) = 'MANDATORY_STEP_IND' then
		new_references.mandatory_step_ind := column_value;
	ELSIF upper(column_name) = 'S_ENROLMENT_STEP_TYPE' then
		new_references.s_enrolment_step_type := column_value;
	ELSIF upper(column_name) = 'S_STUDENT_COMM_TYPE' then
		new_references.s_student_comm_type := column_value;
	end if;

	IF upper(column_name) = 'ENROLMENT_CAT' OR
	  column_name is null then
	   if new_references.enrolment_cat <> upper(new_references.enrolment_cat) then
         	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	  end if;
	end if;
	IF upper(column_name) = 'ENR_METHOD_TYPE'  OR
	  column_name is null then
	   if new_references.enr_method_type <>upper(new_references.enr_method_type) then
         	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	  end if;
	end if;
	IF upper(column_name) = 'MANDATORY_STEP_IND'  OR
	  column_name is null then
	   if new_references.mandatory_step_ind <> upper(new_references.mandatory_step_ind) OR
	      new_references.mandatory_step_ind NOT IN ('Y','N') then
         	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	  end if;
	end if;
	IF upper(column_name) = 'S_ENROLMENT_STEP_TYPE'   OR
	  column_name is null then
	   if new_references.s_enrolment_step_type <> upper(new_references.s_enrolment_step_type) then
         	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	  end if;
	end if;
	IF upper(column_name) = 'S_STUDENT_COMM_TYPE'  OR
	  column_name is null then
	   if new_references.s_student_comm_type <> upper(new_references.s_student_comm_type) then
         	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
         	App_Exception.Raise_Exception;
	  end if;
	end if;
END check_constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.enrolment_cat = new_references.enrolment_cat) AND
         (old_references.s_student_comm_type = new_references.s_student_comm_type) AND
         (old_references.enr_method_type = new_references.enr_method_type)) OR
        ((new_references.enrolment_cat IS NULL) OR
         (new_references.s_student_comm_type IS NULL) OR
         (new_references.enr_method_type IS NULL))) THEN
      NULL;
    ELSE
      if not IGS_EN_CAT_PRC_DTL_PKG.Get_PK_For_Validation (
        new_references.enrolment_cat,
        new_references.s_student_comm_type,
        new_references.enr_method_type
        ) then
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     end if;
    END IF;

    IF (((old_references.s_enrolment_step_type = new_references.s_enrolment_step_type)) OR
        ((new_references.s_enrolment_step_type IS NULL))) THEN
      NULL;
    ELSE
      if not IGS_LOOKUPS_VIEW_Pkg.Get_PK_For_Validation (
	'ENROLMENT_STEP_TYPE',
        new_references.s_enrolment_step_type
        ) then
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
     end if;
    END IF;

  END Check_Parent_Existance;

 FUNCTION Get_PK_For_Validation (
    x_enrolment_cat IN VARCHAR2,
    x_s_student_comm_type IN VARCHAR2,
    x_enr_method_type IN VARCHAR2,
    x_s_enrolment_step_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAT_PRC_STEP_ALL
      WHERE    enrolment_cat = x_enrolment_cat
      AND      s_student_comm_type = x_s_student_comm_type
      AND      enr_method_type = x_enr_method_type
      AND      s_enrolment_step_type = x_s_enrolment_step_type
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
     IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
	return(TRUE);
    else
	Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_EN_CAT_PRC_DTL (
    x_enrolment_cat IN VARCHAR2,
    x_s_student_comm_type IN VARCHAR2,
    x_enr_method_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAT_PRC_STEP_ALL
      WHERE    enrolment_cat = x_enrolment_cat
      AND      s_student_comm_type = x_s_student_comm_type
      AND      enr_method_type = x_enr_method_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_ECPS_ECPD_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_CAT_PRC_DTL;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_enrolment_step_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAT_PRC_STEP_ALL
      WHERE    s_enrolment_step_type = x_s_enrolment_step_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_ECPS_LKUPV_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_enrolment_cat IN VARCHAR2 DEFAULT NULL,
    x_s_student_comm_type IN VARCHAR2 DEFAULT NULL,
    x_enr_method_type IN VARCHAR2 DEFAULT NULL,
    x_s_enrolment_step_type IN VARCHAR2 DEFAULT NULL,
    x_step_order_num IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_enrolment_cat,
      x_s_student_comm_type,
      x_enr_method_type,
      x_s_enrolment_step_type,
      x_step_order_num,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsert1 ( p_inserting => TRUE );
	IF Get_PK_For_Validation (
 	   new_references.enrolment_cat,
 	   new_references.s_student_comm_type,
 	   new_references.enr_method_type,
 	   new_references.s_enrolment_step_type
    	) then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        end if;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
   ELSIF (p_action = 'VALIDATE_INSERT') then
	IF Get_PK_For_Validation (
 	   new_references.enrolment_cat,
 	   new_references.s_student_comm_type,
 	   new_references.enr_method_type,
 	   new_references.s_enrolment_step_type
    	) then
 	 Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
        end if;
      Check_constraints;
   ELSIF (p_action = 'VALIDATE_UPDATE') THEN
    Check_constraints;
   ELSIF (p_action = 'VALIDATE_DELETE') THEN
	null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_S_STUDENT_COMM_TYPE in VARCHAR2,
  X_ENR_METHOD_TYPE in VARCHAR2,
  X_S_ENROLMENT_STEP_TYPE in VARCHAR2,
  X_STEP_ORDER_NUM in NUMBER,
  X_MODE in VARCHAR2 default 'R',
    x_org_id IN NUMBER
  ) AS
    cursor C is select ROWID from IGS_EN_CAT_PRC_STEP_ALL
      where ENROLMENT_CAT = X_ENROLMENT_CAT
      and S_STUDENT_COMM_TYPE = X_S_STUDENT_COMM_TYPE
      and ENR_METHOD_TYPE = X_ENR_METHOD_TYPE
      and S_ENROLMENT_STEP_TYPE = X_S_ENROLMENT_STEP_TYPE;
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
  Before_DML (
    p_action => 'INSERT',
    x_rowid =>   X_ROWID,
    x_enrolment_cat => X_ENROLMENT_CAT,
    x_s_student_comm_type => X_S_STUDENT_COMM_TYPE,
    x_enr_method_type => X_ENR_METHOD_TYPE,
    x_s_enrolment_step_type => X_S_ENROLMENT_STEP_TYPE,
    x_step_order_num => X_STEP_ORDER_NUM,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
  );
  insert into IGS_EN_CAT_PRC_STEP_ALL (
    ENROLMENT_CAT,
    S_STUDENT_COMM_TYPE,
    ENR_METHOD_TYPE,
    S_ENROLMENT_STEP_TYPE,
    STEP_ORDER_NUM,
    MANDATORY_STEP_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    org_id
  ) values (
    NEW_REFERENCES.ENROLMENT_CAT,
    NEW_REFERENCES.S_STUDENT_COMM_TYPE,
    NEW_REFERENCES.ENR_METHOD_TYPE,
    NEW_REFERENCES.S_ENROLMENT_STEP_TYPE,
    NEW_REFERENCES.STEP_ORDER_NUM,
    NEW_REFERENCES.MANDATORY_STEP_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.org_id
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  After_DML (
    p_action => 'INSERT',
    x_rowid =>   X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_S_STUDENT_COMM_TYPE in VARCHAR2,
  X_ENR_METHOD_TYPE in VARCHAR2,
  X_S_ENROLMENT_STEP_TYPE in VARCHAR2,
  X_STEP_ORDER_NUM in NUMBER
) AS
  cursor c1 is select
      STEP_ORDER_NUM,
      MANDATORY_STEP_IND
    from IGS_EN_CAT_PRC_STEP_ALL
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

      if ( ((tlinfo.STEP_ORDER_NUM = X_STEP_ORDER_NUM)
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
  X_ENROLMENT_CAT in VARCHAR2,
  X_S_STUDENT_COMM_TYPE in VARCHAR2,
  X_ENR_METHOD_TYPE in VARCHAR2,
  X_S_ENROLMENT_STEP_TYPE in VARCHAR2,
  X_STEP_ORDER_NUM in NUMBER,
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
  Before_DML (
    p_action => 'UPDATE',
    x_rowid =>   X_ROWID,
    x_enrolment_cat => X_ENROLMENT_CAT,
    x_s_student_comm_type => X_S_STUDENT_COMM_TYPE,
    x_enr_method_type => X_ENR_METHOD_TYPE,
    x_s_enrolment_step_type => X_S_ENROLMENT_STEP_TYPE,
    x_step_order_num => X_STEP_ORDER_NUM,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_EN_CAT_PRC_STEP_ALL set
    STEP_ORDER_NUM     = NEW_REFERENCES.STEP_ORDER_NUM,
    MANDATORY_STEP_IND = NEW_REFERENCES.MANDATORY_STEP_IND,
    LAST_UPDATE_DATE   = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY    = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN  = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'UPDATE',
    x_rowid =>   X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2,
  X_S_STUDENT_COMM_TYPE in VARCHAR2,
  X_ENR_METHOD_TYPE in VARCHAR2,
  X_S_ENROLMENT_STEP_TYPE in VARCHAR2,
  X_STEP_ORDER_NUM in NUMBER,
  X_MODE in VARCHAR2 default 'R',
    x_org_id IN NUMBER
  ) AS
  cursor c1 is select rowid from IGS_EN_CAT_PRC_STEP_ALL
     where ENROLMENT_CAT = X_ENROLMENT_CAT
     and S_STUDENT_COMM_TYPE = X_S_STUDENT_COMM_TYPE
     and ENR_METHOD_TYPE = X_ENR_METHOD_TYPE
     and S_ENROLMENT_STEP_TYPE = X_S_ENROLMENT_STEP_TYPE
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_ENROLMENT_CAT,
     X_S_STUDENT_COMM_TYPE,
     X_ENR_METHOD_TYPE,
     X_S_ENROLMENT_STEP_TYPE,
     X_STEP_ORDER_NUM,
     X_MODE,
    x_org_id  );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ENROLMENT_CAT,
   X_S_STUDENT_COMM_TYPE,
   X_ENR_METHOD_TYPE,
   X_S_ENROLMENT_STEP_TYPE,
   X_STEP_ORDER_NUM,
   X_MODE );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
)AS
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid =>   X_ROWID
  );
  delete from IGS_EN_CAT_PRC_STEP_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'DELETE',
    x_rowid =>   X_ROWID
  );
end DELETE_ROW;

end IGS_EN_CAT_PRC_STEP_PKG;

/
