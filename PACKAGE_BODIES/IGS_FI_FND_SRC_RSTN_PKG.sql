--------------------------------------------------------
--  DDL for Package Body IGS_FI_FND_SRC_RSTN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_FI_FND_SRC_RSTN_PKG" AS
 /* $Header: IGSSI40B.pls 115.3 2002/11/29 03:46:46 nsidana ship $*/



 l_rowid VARCHAR2(25);

  old_references IGS_FI_FND_SRC_RSTN%RowType;

  new_references IGS_FI_FND_SRC_RSTN%RowType;



  PROCEDURE Set_Column_Values (

    p_action IN VARCHAR2,

    x_rowid IN VARCHAR2 DEFAULT NULL,

    x_course_cd IN VARCHAR2 DEFAULT NULL,

    x_version_number IN NUMBER DEFAULT NULL,

    x_funding_source IN VARCHAR2 DEFAULT NULL,

    x_dflt_ind IN VARCHAR2 DEFAULT NULL,

    x_restricted_ind IN VARCHAR2 DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,

    x_created_by IN NUMBER DEFAULT NULL,

    x_last_update_date IN DATE DEFAULT NULL,

    x_last_updated_by IN NUMBER DEFAULT NULL,

    x_last_update_login IN NUMBER DEFAULT NULL

  ) AS



    CURSOR cur_old_ref_values IS

      SELECT   *

      FROM     IGS_FI_FND_SRC_RSTN

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

    new_references.course_cd := x_course_cd;

    new_references.version_number := x_version_number;

    new_references.funding_source := x_funding_source;

    new_references.dflt_ind := x_dflt_ind;

    new_references.restricted_ind := x_restricted_ind;

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

  -- "OSS_TST".trg_fsr_br_iud

  -- BEFORE INSERT OR DELETE OR UPDATE

  -- ON IGS_FI_FND_SRC_RSTN

  -- FOR EACH ROW



  PROCEDURE BeforeRowInsertUpdateDelete1(

    p_inserting IN BOOLEAN DEFAULT FALSE,

    p_updating IN BOOLEAN DEFAULT FALSE,

    p_deleting IN BOOLEAN DEFAULT FALSE

    ) AS

	v_message_name varchar2(30);

	v_course_cd	IGS_FI_FND_SRC_RSTN.course_cd%TYPE;

	v_version_number	IGS_FI_FND_SRC_RSTN.version_number%TYPE;

	v_dflt_ind		IGS_FI_FND_SRC_RSTN.dflt_ind%TYPE;

	v_restricted_ind	IGS_FI_FND_SRC_RSTN.restricted_ind%TYPE;

  BEGIN

	-- Set variables.

	IF p_deleting THEN

		v_course_cd := old_references.course_cd;

		v_version_number := old_references.version_number;

	ELSE -- p_inserting or p_updating

		v_course_cd := new_references.course_cd;

		v_version_number := new_references.version_number;

	END IF;

	-- Validate the insert/update/delete.

	IF  IGS_PS_VAL_CRS.crsp_val_iud_crv_dtl (

			v_course_cd,

			v_version_number,

			v_message_name) = FALSE THEN

		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;

	END IF;

	-- Validate funding source.  Funding source is not updateable.

	IF p_inserting THEN

		IF IGS_PS_VAL_FSr.crsp_val_fsr_fnd_src (

				new_references.funding_source,

				v_message_name) = FALSE THEN

			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

		END IF;

	END IF;

	-- Validate restricted/default indicators.

	IF p_inserting OR p_updating THEN

		IF IGS_PS_VAL_FSr.crsp_val_fsr_inds (

				new_references.dflt_ind,

				new_references.restricted_ind,

				v_message_name) = FALSE THEN

			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;

		END IF;

	END IF;

	-- Create history record for update.

	IF p_updating THEN

		IF old_references.dflt_ind <> new_references.dflt_ind OR

			old_references.restricted_ind <> new_references.restricted_ind THEN

			SELECT	DECODE(old_references.dflt_ind,new_references.dflt_ind,NULL,old_references.dflt_ind),

				DECODE(old_references.restricted_ind,new_references.restricted_ind,NULL,old_references.restricted_ind)

			INTO	v_dflt_ind,

				v_restricted_ind

			FROM	dual;

			IGS_PS_GEN_004.CRSP_INS_FSR_HIST(

				old_references.course_cd,

				old_references.version_number,

				old_references.funding_source,

				old_references.last_update_date,

				new_references.last_update_date,

				old_references.last_updated_by,

				v_dflt_ind,

				v_restricted_ind);

		END IF;

	END IF;

	-- Create history record for deletion.

	IF p_deleting THEN

		IGS_PS_GEN_004.CRSP_INS_FSR_HIST(

			old_references.course_cd,

			old_references.version_number,

			old_references.funding_source,

			old_references.last_update_date,

			SYSDATE,

			old_references.last_updated_by,

			old_references.dflt_ind,

			old_references.restricted_ind);

	END IF;





  END BeforeRowInsertUpdateDelete1;

   PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	DEFAULT NULL,
   Column_Value 	IN	VARCHAR2	DEFAULT NULL
   )AS
   BEGIN

  IF Column_Name is NULL THEN
  	NULL;
  ELSIF upper(Column_Name) = 'DFLT_IND' then
  	new_references.dflt_ind := Column_Value;
  ELSIF upper(Column_Name) = 'RESTRICTED_IND' then
  	new_references.restricted_ind := Column_Value;
  ELSIF upper(Column_Name) = 'COURSE_CD' then
  	new_references.course_cd := Column_Value;
  ELSIF upper(Column_Name) = 'FUNDING_SOURCE' then
    	new_references.funding_source := Column_Value;
  END IF;
  IF upper(Column_Name) = 'RESTRICTED_IND' OR 	column_name is NULL THEN
     		IF new_references.restricted_ind <> 'Y' AND
			   new_references.restricted_ind <> 'N'
			   THEN
     				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
     				App_Exception.Raise_Exception;
     		END IF;
  END IF;

  IF upper(Column_Name) = 'DFLT_IND' OR 	column_name is NULL THEN
       		IF new_references.dflt_ind <> 'Y' AND
  			   new_references.dflt_ind <> 'N'
  			   THEN
       				Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
				IGS_GE_MSG_STACK.ADD;
       				App_Exception.Raise_Exception;
       		END IF;
  END IF;
  IF upper(Column_Name) = 'COURSE_CD' OR
    		column_name is NULL THEN
  		IF new_references.course_cd <> UPPER(new_references.course_cd) THEN
  			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
  			App_Exception.Raise_Exception;
  		END IF;
  END IF;
  IF upper(Column_Name) = 'FUNDING_SOURCE' OR
    		column_name is NULL THEN
  		IF new_references.funding_source <> UPPER(new_references.funding_source) THEN
  			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
  			App_Exception.Raise_Exception;
  		END IF;
  END IF;

   END Check_Constraints;
  PROCEDURE Check_Parent_Existance AS

  BEGIN
    IF (((old_references.funding_source = new_references.funding_source)) OR
        ((new_references.funding_source IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_FI_FUND_SRC_PKG.Get_PK_For_Validation (
        new_references.funding_source
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
                 IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
			IGS_GE_MSG_STACK.ADD;
     		 App_Exception.Raise_Exception;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_funding_source IN VARCHAR2
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
     SELECT   rowid
      FROM     IGS_FI_FND_SRC_RSTN
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      funding_source = x_funding_source
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


 PROCEDURE GET_FK_IGS_FI_FUND_SRC (
	   x_funding_source IN VARCHAR2
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_FI_FND_SRC_RSTN
      WHERE    funding_source = x_funding_source ;

    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FSR_FS_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_FI_FUND_SRC;



  PROCEDURE GET_FK_IGS_PS_VER (

    x_course_cd IN VARCHAR2,

    x_version_number IN NUMBER

    ) AS



    CURSOR cur_rowid IS

      SELECT   rowid

      FROM     IGS_FI_FND_SRC_RSTN

      WHERE    course_cd = x_course_cd

      AND      version_number = x_version_number ;



    lv_rowid cur_rowid%RowType;



  BEGIN



    Open cur_rowid;

    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN

      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_FI_FSR_CRV_FK');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;


      Return;

    END IF;

    Close cur_rowid;



  END GET_FK_IGS_PS_VER;



  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_funding_source IN VARCHAR2 DEFAULT NULL,
    x_dflt_ind IN VARCHAR2 DEFAULT NULL,
    x_restricted_ind IN VARCHAR2 DEFAULT NULL,
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

      x_course_cd,

      x_version_number,

      x_funding_source,

      x_dflt_ind,

      x_restricted_ind,

      x_creation_date,

      x_created_by,

      x_last_update_date,

      x_last_updated_by,

      x_last_update_login

    );



    IF (p_action = 'INSERT') THEN

      -- Call all the procedures related to Before Insert.

      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
	  IF Get_PK_For_Validation (  new_references.course_cd,
    							  new_references.version_number,
    							  new_references.funding_source ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	  END IF;

      Check_Constraints;

      Check_Parent_Existance;

    ELSIF (p_action = 'UPDATE') THEN

      -- Call all the procedures related to Before Update.

      BeforeRowInsertUpdateDelete1 ( p_updating => TRUE );

      Check_Constraints;

      Check_Parent_Existance;

    ELSIF (p_action = 'DELETE') THEN

      -- Call all the procedures related to Before Delete.

      BeforeRowInsertUpdateDelete1 ( p_deleting => TRUE );

   ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation (  new_references.course_cd,
    							  new_references.version_number,
    							  new_references.funding_source ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	  END IF;
			Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	 	Check_Constraints;
    END IF;
  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_FI_FND_SRC_RSTN
      where COURSE_CD = X_COURSE_CD
      and FUNDING_SOURCE = X_FUNDING_SOURCE
      and VERSION_NUMBER = X_VERSION_NUMBER;
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
 x_course_cd=>X_COURSE_CD,
 x_dflt_ind=>NVL(X_DFLT_IND,'N'),
 x_funding_source=>X_FUNDING_SOURCE,
 x_restricted_ind=>NVL(X_RESTRICTED_IND,'Y'),
 x_version_number=>X_VERSION_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
);

  insert into IGS_FI_FND_SRC_RSTN (
    COURSE_CD,
    VERSION_NUMBER,
    FUNDING_SOURCE,
    DFLT_IND,
    RESTRICTED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.FUNDING_SOURCE,
    NEW_REFERENCES.DFLT_IND,
    NEW_REFERENCES.RESTRICTED_IND,
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
  X_COURSE_CD in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2
) AS
  cursor c1 is select
      DFLT_IND,
      RESTRICTED_IND
    from IGS_FI_FND_SRC_RSTN
    where ROWID=X_ROWID
    for update nowait;
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

  if ( (tlinfo.DFLT_IND = X_DFLT_IND)
      AND (tlinfo.RESTRICTED_IND = X_RESTRICTED_IND)
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
  X_COURSE_CD in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2,
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

		 x_course_cd=>X_COURSE_CD,

		 x_dflt_ind=>X_DFLT_IND,

		 x_funding_source=>X_FUNDING_SOURCE,

		 x_restricted_ind=>X_RESTRICTED_IND,

		 x_version_number=>X_VERSION_NUMBER,

		 x_creation_date=>X_LAST_UPDATE_DATE,

		 x_created_by=>X_LAST_UPDATED_BY,

		 x_last_update_date=>X_LAST_UPDATE_DATE,

		 x_last_updated_by=>X_LAST_UPDATED_BY,

		 x_last_update_login=>X_LAST_UPDATE_LOGIN

	);


  update IGS_FI_FND_SRC_RSTN set
    DFLT_IND = NEW_REFERENCES.DFLT_IND,
    RESTRICTED_IND = NEW_REFERENCES.RESTRICTED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_CD in VARCHAR2,
  X_FUNDING_SOURCE in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_DFLT_IND in VARCHAR2,
  X_RESTRICTED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_FI_FND_SRC_RSTN
     where COURSE_CD = X_COURSE_CD
     and FUNDING_SOURCE = X_FUNDING_SOURCE
     and VERSION_NUMBER = X_VERSION_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_CD,
     X_FUNDING_SOURCE,
     X_VERSION_NUMBER,
     X_DFLT_IND,
     X_RESTRICTED_IND,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_CD,
   X_FUNDING_SOURCE,
   X_VERSION_NUMBER,
   X_DFLT_IND,
   X_RESTRICTED_IND,
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
  delete from IGS_FI_FND_SRC_RSTN
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
end DELETE_ROW;
end IGS_FI_FND_SRC_RSTN_PKG;

/
