--------------------------------------------------------
--  DDL for Package Body IGS_PS_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_TYPE_PKG" AS
/* $Header: IGSPI36B.pls 115.16 2003/06/05 12:54:01 sarakshi ship $ */


  l_rowid VARCHAR2(25);
  old_references IGS_PS_TYPE_ALL%RowType;
  new_references IGS_PS_TYPE_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_govt_course_type IN NUMBER ,
    x_award_course_ind IN VARCHAR2 ,
    x_course_type_group_cd IN VARCHAR2 ,
    x_tac_course_level IN VARCHAR2 ,
    x_research_type_ind IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_course_type IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_primary_auto_select IN VARCHAR2 ,
    x_fin_aid_program_type IN VARCHAR2 ,
    x_enrolment_cat IN VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_TYPE_ALL
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
    new_references.description := x_description;
    new_references.govt_course_type := x_govt_course_type;
    new_references.award_course_ind := x_award_course_ind;
    new_references.course_type_group_cd := x_course_type_group_cd;
    new_references.tac_course_level := x_tac_course_level;
    new_references.research_type_ind := x_research_type_ind;
    new_references.closed_ind := x_closed_ind;
    new_references.course_type := x_course_type;
    new_references.primary_auto_select := x_primary_auto_select;
    new_references.fin_aid_program_type :=x_fin_aid_program_type;
    new_references.enrolment_cat := x_enrolment_cat;
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
    new_references.org_id := x_org_id;
  END Set_Column_Values;

  PROCEDURE BeforeRowInsertUpdate(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN
    ) AS
	v_message_name		VARCHAR2(30);
	v_description		IGS_PS_TYPE_ALL.description%TYPE;
	v_govt_course_type	IGS_PS_TYPE_ALL.govt_course_type%TYPE;
	v_course_type_group_cd	IGS_PS_TYPE_ALL.course_type_group_cd%TYPE;
	v_tac_course_level	IGS_PS_TYPE_ALL.tac_course_level%TYPE;
	v_closed_ind		IGS_PS_TYPE_ALL.closed_ind%TYPE;
	v_award_course_ind	IGS_PS_TYPE_ALL.award_course_ind%TYPE;
	v_research_type_ind	IGS_PS_TYPE_ALL.research_type_ind%TYPE;
        v_primary_auto_select   IGS_PS_TYPE_ALL.primary_auto_select%TYPE;
        v_enrolment_cat         IGS_PS_TYPE_ALL.enrolment_cat%TYPE;
	x_rowid		VARCHAR2(25);

	CURSOR SPTH_CUR IS SELECT Rowid
			FROM IGS_PS_TYPE_HIST_ALL
			WHERE	course_type = old_references.course_type;

  BEGIN
	-- Validate DEET IGS_PS_COURSE type.
	IF p_inserting OR
		(p_updating AND
		((old_references.govt_course_type <> new_references.govt_course_type) OR
		 (old_references.closed_ind = 'Y' AND new_references.closed_ind = 'N')))
THEN
		IF IGS_PS_VAL_CTY.crsp_val_cty_govt (
				new_references.govt_course_type,
				v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate IGS_PS_COURSE type group code.
	IF p_inserting OR
		(p_updating AND
		(NVL(old_references.course_type_group_cd, 'null') <>
			NVL(new_references.course_type_group_cd, 'null') OR
		 (old_references.closed_ind = 'Y' AND new_references.closed_ind = 'N')))
THEN
		IF IGS_PS_VAL_CTY.crsp_val_cty_group (
				new_references.course_type_group_cd,
				v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the IGS_PS_AWD IGS_PS_COURSE indicator.
	IF (p_updating AND
		(old_references.award_course_ind <> new_references.award_course_ind)) THEN
		IF IGS_PS_VAL_CTY.crsp_val_cty_award (
				new_references.course_type,
				new_references.award_course_ind,
				v_message_name) = FALSE THEN
		Fnd_Message.Set_Name('IGS',v_message_name);
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Create history record.
	IF p_updating THEN
		IF              old_references.description <> new_references.description OR
				old_references.govt_course_type <> new_references.govt_course_type OR
				NVL(old_references.course_type_group_cd, 'null') <>
				NVL(new_references.course_type_group_cd, 'null') OR
				NVL(old_references.tac_course_level, 'null') <>
				NVL(new_references.tac_course_level, 'null') OR
				NVL(old_references.primary_auto_select, 'null') <> -- added as part of Career_Impact build
				NVL(new_references.primary_auto_select, 'null') OR
                                NVL(old_references.fin_aid_program_type,'null') <>
                                NVL(new_references.fin_aid_program_type,'null') OR
				old_references.closed_ind <> new_references.closed_ind OR
				old_references.award_course_ind <> new_references.award_course_ind OR
				old_references.research_type_ind <> new_references.research_type_ind
				THEN
			SELECT	DECODE (old_references.description,
					new_references.description, NULL, old_references.description),
				DECODE (old_references.govt_course_type,
					new_references.govt_course_type, NULL,old_references.govt_course_type),
				DECODE (NVL(old_references.course_type_group_cd, 'null'),
					NVL(new_references.course_type_group_cd, 'null'),
					NULL,	old_references.course_type_group_cd),
				DECODE (NVL(old_references.tac_course_level, 'null'),
					NVL(new_references.tac_course_level, 'null'), NULL,
					old_references.tac_course_level),
				DECODE (old_references.closed_ind,
					new_references.closed_ind, NULL, old_references.closed_ind),
				DECODE (old_references.award_course_ind,
					new_references.award_course_ind, NULL,
					old_references.award_course_ind),
				DECODE (old_references.research_type_ind,
					new_references.research_type_ind, NULL,
					old_references.research_type_ind),
                                DECODE (NVL(old_references.primary_auto_select,'null'),
                                        NVL(new_references.primary_auto_select,'null'),
                                        NULL,old_references.primary_auto_select)
				INTO	v_description,
				v_govt_course_type,
				v_course_type_group_cd,
				v_tac_course_level,
				v_closed_ind,
				v_award_course_ind,
				v_research_type_ind,
                                v_primary_auto_select
			FROM	dual;


	BEGIN
	IGS_PS_TYPE_HIST_PKG.Insert_Row(
			X_ROWID			=> x_rowid,
			X_COURSE_TYPE		=> old_references.course_type,
			X_HIST_START_DT		=> old_references.last_update_date,
			X_HIST_END_DT		=> new_references.last_update_date,
			X_HIST_WHO		=> old_references.last_updated_by,
			X_DESCRIPTION		=> v_description,
			X_GOVT_COURSE_TYPE	=> v_govt_course_type,
			X_AWARD_COURSE_IND	=> v_award_course_ind,
			X_COURSE_TYPE_GROUP_CD	=> v_course_type_group_cd,
			X_TAC_COURSE_LEVEL	=> v_tac_course_level,
			X_RESEARCH_TYPE_IND	=> v_research_type_ind,
			X_CLOSED_IND		=> v_closed_ind,
			X_MODE			=> 'R',
			X_ORG_ID 		=> old_references.org_id,
                        X_PRIMARY_AUTO_SELECT   => v_primary_auto_select,
                        X_FIN_AID_PROGRAM_TYPE  => old_references.fin_aid_program_type
                    );
	END;

        END IF;
      END IF;

  END BeforeRowInsertUpdate;

  PROCEDURE Check_Constraints (
	Column_Name IN VARCHAR2 ,
	Column_Value IN VARCHAR2
  ) AS
  BEGIN
	IF column_name is null THEN
	   NULL;
	ELSIF upper(column_name) = 'CLOSED_IND' THEN
	   new_references.closed_ind := column_value;
	ELSIF upper(column_name) = 'RESEARCH_TYPE_IND' THEN
	   new_references.research_type_ind := column_value;
	ELSIF upper(column_name) = 'COURSE_TYPE' THEN
	   new_references.course_type := column_value;
	ELSIF upper(column_name) = 'AWARD_COURSE_IND' THEN
	   new_references.award_course_ind := column_value;
 	ELSIF upper(column_name) = 'COURSE_TYPE_GROUP_CD' THEN
	   new_references.course_type_group_cd := column_value;
	ELSIF upper(column_name) = 'TAC_COURSE_LEVEL' THEN
	   new_references.tac_course_level := column_value;
        ELSIF upper(column_name) = 'PRIMARY_AUTO_SELECT' THEN -- added as part of Career_Impact build
           new_references.primary_auto_select := column_value;
        ELSIF upper(column_name) = 'ENROLMENT_CAT' THEN -- added as part of Self Service Setup build
           new_references.enrolment_cat := column_value;
        ELSIF upper(column_name) = 'FIN_AID_PROGRAM_TYPE' THEN -- added as part of FA Program Type build
           new_references.fin_aid_program_type:= column_value;
	END IF;

	IF upper(column_name)= 'COURSE_TYPE' OR
		column_name is null THEN
		IF new_references.course_type <> UPPER(new_references.course_type )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'COURSE_TYPE_GROUP_CD' OR
		column_name is null THEN
		IF new_references.course_type_group_cd <> UPPER(new_references.course_type_group_cd )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

	IF upper(column_name)= 'TAC_COURSE_LEVEL' OR
		column_name is null THEN
		IF new_references.tac_course_level <> UPPER(new_references.tac_course_level)
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'RESEARCH_TYPE_IND' OR
		column_name is null THEN
		IF new_references.research_type_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'CLOSED_IND' OR
		column_name is null THEN
		IF new_references.closed_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;

  	IF upper(column_name)= 'AWARD_COURSE_IND' OR
		column_name is null THEN
		IF new_references.award_course_ind NOT IN ( 'Y' , 'N' )
		THEN
            	Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
            	IGS_GE_MSG_STACK.ADD;
            	App_Exception.Raise_Exception;
		END IF;
	END IF;
  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_type_group_cd = new_references.course_type_group_cd)) OR
        ((new_references.course_type_group_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_TYPE_GRP_PKG.Get_PK_For_Validation (
        new_references.course_type_group_cd
      )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.govt_course_type = new_references.govt_course_type)) OR
        ((new_references.govt_course_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_GOVT_TYPE_PKG.Get_PK_For_Validation (
        new_references.govt_course_type
      )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      END IF;
    END IF;
  --Added new foreign key column enrolment_cat as a part of self service setup build enh bug #2043044
    IF (((old_references.enrolment_cat = new_references.enrolment_cat)) OR
        ((new_references.enrolment_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ENROLMENT_CAT_PKG.Get_PK_For_Validation (
        new_references.enrolment_cat
      )THEN
	Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
     END IF;
    END IF;

  END Check_Parent_Existance;


  FUNCTION Get_PK_For_Validation (
    x_course_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_TYPE_ALL
      WHERE    course_type = x_course_type;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
	IF (cur_rowid%FOUND) THEN
		Close cur_rowid;
		Return(TRUE);
	ELSE
		Close cur_rowid;
		Return(FALSE);
	END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_PS_TYPE_GRP (
    x_course_type_group_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_TYPE_ALL
      WHERE    course_type_group_cd = x_course_type_group_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CTY_CTG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_TYPE_GRP;

  PROCEDURE GET_FK_IGS_PS_GOVT_TYPE (
    x_govt_course_type IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_TYPE_ALL
      WHERE    govt_course_type = x_govt_course_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CTY_GCT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_GOVT_TYPE;

  PROCEDURE GET_FK_IGS_EN_ENROLMENT_CAT (
    x_enrolment_cat IN VARCHAR2)   AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_TYPE_ALL
      WHERE    enrolment_cat = x_enrolment_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_CTY_CTG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ENROLMENT_CAT;



  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_govt_course_type IN NUMBER ,
    x_award_course_ind IN VARCHAR2 ,
    x_course_type_group_cd IN VARCHAR2 ,
    x_tac_course_level IN VARCHAR2 ,
    x_research_type_ind IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_course_type IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_org_id IN NUMBER ,
    x_primary_auto_select IN VARCHAR2 ,
    x_fin_aid_program_type IN VARCHAR2 ,
    x_enrolment_cat IN VARCHAR2
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_description,
      x_govt_course_type,
      x_award_course_ind,
      x_course_type_group_cd,
      x_tac_course_level,
      x_research_type_ind,
      x_closed_ind,
      x_course_type,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_primary_auto_select,
      x_fin_aid_program_type,
      x_enrolment_cat
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate( p_inserting => TRUE,p_updating=>FALSE);
	IF Get_PK_For_Validation(
    		new_references.course_type
    	) THEN
	Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
	END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate( p_updating => TRUE,p_inserting=>FALSE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 IF Get_PK_For_Validation(
    		new_references.course_type
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
  X_COURSE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_AWARD_COURSE_IND in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_TAC_COURSE_LEVEL in VARCHAR2,
  X_RESEARCH_TYPE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ORG_ID in NUMBER,
  X_PRIMARY_AUTO_SELECT IN VARCHAR2 ,
  X_FIN_AID_PROGRAM_TYPE IN VARCHAR2 ,
  X_ENROLMENT_CAT in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_PS_TYPE_ALL
      where COURSE_TYPE = X_COURSE_TYPE;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
BEGIN
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
 Before_DML( p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_description => X_DESCRIPTION,
    x_govt_course_type => X_GOVT_COURSE_TYPE,
    x_award_course_ind => NVL(X_AWARD_COURSE_IND,'Y'),
    x_course_type_group_cd => X_COURSE_TYPE_GROUP_CD,
    x_tac_course_level => X_TAC_COURSE_LEVEL,
    x_research_type_ind => NVL(X_RESEARCH_TYPE_IND,'N'),
    x_closed_ind => NVL(X_CLOSED_IND,'N'),
    x_course_type => X_COURSE_TYPE,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_primary_auto_select => X_PRIMARY_AUTO_SELECT,
    x_fin_aid_program_type=>X_FIN_AID_PROGRAM_TYPE,
    x_enrolment_cat => X_ENROLMENT_CAT
  );
  insert into IGS_PS_TYPE_ALL (
    COURSE_TYPE,
    DESCRIPTION,
    GOVT_COURSE_TYPE,
    AWARD_COURSE_IND,
    COURSE_TYPE_GROUP_CD,
    TAC_COURSE_LEVEL,
    RESEARCH_TYPE_IND,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID,
    PRIMARY_AUTO_SELECT,
    FIN_AID_PROGRAM_TYPE,
    ENROLMENT_CAT
  ) values (
    NEW_REFERENCES.COURSE_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.GOVT_COURSE_TYPE,
    NEW_REFERENCES.AWARD_COURSE_IND,
    NEW_REFERENCES.COURSE_TYPE_GROUP_CD,
    NEW_REFERENCES.TAC_COURSE_LEVEL,
    NEW_REFERENCES.RESEARCH_TYPE_IND,
    NEW_REFERENCES.CLOSED_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID,
    NEW_REFERENCES.PRIMARY_AUTO_SELECT,
    NEW_REFERENCES.FIN_AID_PROGRAM_TYPE,
    NEW_REFERENCES.ENROLMENT_CAT
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;

 After_DML(
  p_action => 'INSERT',
  x_rowid => X_ROWID
  );

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_COURSE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_AWARD_COURSE_IND in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_TAC_COURSE_LEVEL in VARCHAR2,
  X_RESEARCH_TYPE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_PRIMARY_AUTO_SELECT in VARCHAR2,
  X_FIN_AID_PROGRAM_TYPE IN VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2
  ) AS
  cursor c1 is select
      DESCRIPTION,
      GOVT_COURSE_TYPE,
      AWARD_COURSE_IND,
      COURSE_TYPE_GROUP_CD,
      TAC_COURSE_LEVEL,
      RESEARCH_TYPE_IND,
      CLOSED_IND,
      PRIMARY_AUTO_SELECT,
      FIN_AID_PROGRAM_TYPE,
      ENROLMENT_CAT
    from IGS_PS_TYPE_ALL
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.GOVT_COURSE_TYPE = X_GOVT_COURSE_TYPE)
      AND (tlinfo.AWARD_COURSE_IND = X_AWARD_COURSE_IND)
      AND ((tlinfo.COURSE_TYPE_GROUP_CD = X_COURSE_TYPE_GROUP_CD)
           OR ((tlinfo.COURSE_TYPE_GROUP_CD is null)
               AND (X_COURSE_TYPE_GROUP_CD is null)))
      AND ((tlinfo.TAC_COURSE_LEVEL = X_TAC_COURSE_LEVEL)
           OR ((tlinfo.TAC_COURSE_LEVEL is null)
               AND (X_TAC_COURSE_LEVEL is null)))
      AND (tlinfo.RESEARCH_TYPE_IND = X_RESEARCH_TYPE_IND)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.PRIMARY_AUTO_SELECT = X_PRIMARY_AUTO_SELECT)
           OR ((tlinfo.PRIMARY_AUTO_SELECT is null)
               AND (X_PRIMARY_AUTO_SELECT is null)))
      AND ((tlinfo.ENROLMENT_CAT = X_ENROLMENT_CAT)
           OR ((tlinfo.ENROLMENT_CAT is null)
               AND (X_ENROLMENT_CAT is null)))
      AND ((tlinfo.FIN_AID_PROGRAM_TYPE= X_FIN_AID_PROGRAM_TYPE)
           OR ((tlinfo.FIN_AID_PROGRAM_TYPE IS NULL)
               AND (X_FIN_AID_PROGRAM_TYPE IS NULL)))
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
  X_COURSE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_AWARD_COURSE_IND in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_TAC_COURSE_LEVEL in VARCHAR2,
  X_RESEARCH_TYPE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_PRIMARY_AUTO_SELECT in VARCHAR2 ,
  X_FIN_AID_PROGRAM_TYPE IN VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2 ) AS
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
 Before_DML( p_action => 'UPDATE',
    x_rowid => X_ROWID,
    x_description => X_DESCRIPTION,
    x_govt_course_type => X_GOVT_COURSE_TYPE,
    x_award_course_ind => X_AWARD_COURSE_IND,
    x_course_type_group_cd => X_COURSE_TYPE_GROUP_CD,
    x_tac_course_level => X_TAC_COURSE_LEVEL,
    x_research_type_ind => X_RESEARCH_TYPE_IND,
    x_closed_ind => X_CLOSED_IND,
    x_course_type => X_COURSE_TYPE,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_primary_auto_select => X_PRIMARY_AUTO_SELECT,
    x_fin_aid_program_type=> X_FIN_AID_PROGRAM_TYPE,
    x_enrolment_cat => X_ENROLMENT_CAT
  );
  update IGS_PS_TYPE_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    GOVT_COURSE_TYPE = NEW_REFERENCES.GOVT_COURSE_TYPE,
    AWARD_COURSE_IND = NEW_REFERENCES.AWARD_COURSE_IND,
    COURSE_TYPE_GROUP_CD = NEW_REFERENCES.COURSE_TYPE_GROUP_CD,
    TAC_COURSE_LEVEL = NEW_REFERENCES.TAC_COURSE_LEVEL,
    RESEARCH_TYPE_IND = NEW_REFERENCES.RESEARCH_TYPE_IND,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    PRIMARY_AUTO_SELECT = X_PRIMARY_AUTO_SELECT,
    FIN_AID_PROGRAM_TYPE= X_FIN_AID_PROGRAM_TYPE,
    ENROLMENT_CAT  = X_ENROLMENT_CAT
  where ROWID = X_ROWID
 ;
  if (sql%notfound) then
    raise no_data_found;
  end if;

 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_COURSE_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_GOVT_COURSE_TYPE in NUMBER,
  X_AWARD_COURSE_IND in VARCHAR2,
  X_COURSE_TYPE_GROUP_CD in VARCHAR2,
  X_TAC_COURSE_LEVEL in VARCHAR2,
  X_RESEARCH_TYPE_IND in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ORG_ID in NUMBER,
  X_PRIMARY_AUTO_SELECT in VARCHAR2,
  X_FIN_AID_PROGRAM_TYPE IN VARCHAR2,
  X_ENROLMENT_CAT in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_PS_TYPE_ALL
     where COURSE_TYPE = X_COURSE_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_COURSE_TYPE,
     X_DESCRIPTION,
     X_GOVT_COURSE_TYPE,
     X_AWARD_COURSE_IND,
     X_COURSE_TYPE_GROUP_CD,
     X_TAC_COURSE_LEVEL,
     X_RESEARCH_TYPE_IND,
     X_CLOSED_IND,
     X_MODE,
     X_ORG_ID,
     X_PRIMARY_AUTO_SELECT,
     X_FIN_AID_PROGRAM_TYPE,
     X_ENROLMENT_CAT
     );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_COURSE_TYPE,
   X_DESCRIPTION,
   X_GOVT_COURSE_TYPE,
   X_AWARD_COURSE_IND,
   X_COURSE_TYPE_GROUP_CD,
   X_TAC_COURSE_LEVEL,
   X_RESEARCH_TYPE_IND,
   X_CLOSED_IND,
   X_MODE,
   X_PRIMARY_AUTO_SELECT,
   X_FIN_AID_PROGRAM_TYPE,
   X_ENROLMENT_CAT
   );
end ADD_ROW;


end IGS_PS_TYPE_PKG;

/
