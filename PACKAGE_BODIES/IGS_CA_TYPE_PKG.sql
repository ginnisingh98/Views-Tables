--------------------------------------------------------
--  DDL for Package Body IGS_CA_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_TYPE_PKG" AS
/* $Header: IGSCI17B.pls 115.9 2003/09/02 08:44:43 svanukur ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_CA_TYPE%RowType;
  new_references IGS_CA_TYPE%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_cal_type IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_s_cal_cat IN VARCHAR2 ,
    x_abbreviation IN VARCHAR2 ,
    x_arts_teaching_cal_type_cd IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_notes IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_TYPE
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
    new_references.cal_type := x_cal_type;
    new_references.description := x_description;
    new_references.s_cal_cat := x_s_cal_cat;
    new_references.abbreviation := x_abbreviation;
    new_references.arts_teaching_cal_type_cd := x_arts_teaching_cal_type_cd;
    new_references.closed_ind := x_closed_ind;
    new_references.notes := x_notes;
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
  -- "OSS_TST".trg_cat_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_CA_TYPE
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	v_message_name		varchar2(30);
  BEGIN
	IF  p_inserting OR p_updating THEN
	    -- Validate that the ARTS teaching calendar type is not closed
	    IF 	new_references.arts_teaching_cal_type_cd IS NOT NULL THEN
		    IF	IGS_CA_VAL_CAT.calp_val_atctc_clsd(
				new_references.arts_teaching_cal_type_cd,
				 v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
		    END IF;
	   END IF;
	    -- Validate that the ARTS teaching calendar type is specified only for
	    -- TEACHING system calendar category
	    IF	IGS_CA_VAL_CAT.calp_val_cat_arts_cd(
			new_references.s_cal_cat,
			new_references.arts_teaching_cal_type_cd,
			 v_message_name) = FALSE THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
	    END IF;
 	END IF;
	IF p_updating THEN
		-- Validate that the system calendar category is not being changed
		-- when the calendar type has active or inactive calendar instances
		IF (new_references.s_cal_cat <> old_references.s_cal_cat) THEN
			IF IGS_CA_VAL_CAT.calp_val_sys_cal_cat(
				new_references.cal_type,
				 v_message_name) = FALSE THEN
					Fnd_Message.Set_Name('IGS',v_message_name);
					IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
	 		 END IF;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	,
   Column_Value 	IN	VARCHAR2
   ) AS
   BEGIN

  IF Column_Name is NULL THEN
  	NULL;
  ELSIF upper(Column_Name) = 'ABBREVIATION' then
  	new_references.abbreviation := Column_Value;
  ELSIF upper(Column_Name) = 'CLOSED_IND' then
  	new_references.closed_ind := Column_Value;
  ELSIF upper(Column_Name) = 'S_CAL_CAT' then
  	new_references.s_cal_cat := Column_Value;
  ELSIF upper(Column_Name) = 'CAL_TYPE' then
  	new_references.cal_type := Column_Value;
  ELSIF upper(Column_Name) = 'ARTS_TEACHING_CAL_TYPE_CD' then
    	new_references.arts_teaching_cal_type_cd := Column_Value;
  END IF;

  IF upper(Column_Name) = 'ABBREVIATION' OR
  		column_name is NULL THEN
		IF new_references.abbreviation <> UPPER(new_references.abbreviation) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
  END IF;
  IF upper(Column_Name) = 'S_CAL_CAT' OR
  		column_name is NULL THEN
		IF new_references.s_cal_cat <> UPPER(new_references.s_cal_cat) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
  END IF;
  IF upper(Column_Name) = 'ARTS_TEACHING_CAL_TYPE_CD' OR
    		column_name is NULL THEN
  		IF new_references.arts_teaching_cal_type_cd <> UPPER(new_references.arts_teaching_cal_type_cd) THEN
  			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
  			IGS_GE_MSG_STACK.ADD;
  			App_Exception.Raise_Exception;
  		END IF;
  END IF;

  IF upper(Column_Name) = 'CAL_TYPE' OR
  		column_name is NULL THEN
		IF new_references.cal_type <> UPPER(new_references.cal_type) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
  END IF;
  IF upper(Column_Name) = 'CLOSED_IND' OR
		  column_name is NULL THEN
		IF new_references.closed_ind NOT IN ('Y', 'N') THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
  END IF;
END Check_Constraints;

PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.arts_teaching_cal_type_cd = new_references.arts_teaching_cal_type_cd)) OR
        ((new_references.arts_teaching_cal_type_cd IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_ARTS_TC_CA_CD_PKG.Get_PK_For_Validation (
        new_references.arts_teaching_cal_type_cd
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		     IGS_GE_MSG_STACK.ADD;
		     App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.s_cal_cat = new_references.s_cal_cat)) OR
        ((new_references.s_cal_cat IS NULL))) THEN
      NULL;
    ELSE
	  null;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_EN_ATD_TYPE_LOAD_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_CA_INST_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_PS_FEE_TRG_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_PS_OFR_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_ST_DFT_LOAD_APPO_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_PS_PAT_OF_STUDY_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_PS_PAT_STUDY_PRD_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_PR_RU_CA_TYPE_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_AS_UNITASS_ITEM_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_FI_UNIT_FEE_TRG_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_PS_UNIT_OFR_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    IGS_AD_CAL_CONF_PKG.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    igs_as_anon_method_pkg.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );

    igs_en_config_enr_cp_pkg.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );
    igs_en_or_unit_wlst_pkg.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );
    igs_en_inst_wlst_opt_pkg.GET_FK_IGS_CA_TYPE (
      old_references.cal_type
      );
  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_cal_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_TYPE
      WHERE    cal_type = x_cal_type
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

  PROCEDURE GET_FK_IGS_CA_ARTS_TC_CA_CD (
    x_arts_teaching_cal_type_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_TYPE
      WHERE    arts_teaching_cal_type_cd = x_arts_teaching_cal_type_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_CAT_ATCTC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_ARTS_TC_CA_CD;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_cal_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_TYPE
      WHERE    s_cal_cat = x_s_cal_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_CAT_LKUP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_cal_type IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_s_cal_cat IN VARCHAR2 ,
    x_abbreviation IN VARCHAR2 ,
    x_arts_teaching_cal_type_cd IN VARCHAR2 ,
    x_closed_ind IN VARCHAR2 ,
    x_notes IN VARCHAR2 ,
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
      x_cal_type,
      x_description,
      x_s_cal_cat,
      x_abbreviation,
      x_arts_teaching_cal_type_cd,
      x_closed_ind,
      x_notes,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE,
                               p_updating  => FALSE,
		               p_deleting  => FALSE);
	  IF Get_PK_For_Validation ( new_references.cal_type )
	  THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
	  END IF;
	      Check_Constraints;
	      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_inserting => FALSE,
			       p_updating => TRUE,
			       p_deleting  => FALSE);
	      Check_Constraints;
	      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
         Check_Child_Existance;
   ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation ( new_references.cal_type )
	  THEN
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
  X_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_CA_TYPE
      where CAL_TYPE = X_CAL_TYPE;
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
    p_action =>'INSERT',
    x_rowid =>X_ROWID,
    x_cal_type =>X_CAL_TYPE,
    x_description =>X_DESCRIPTION,
    x_s_cal_cat =>X_S_CAL_CAT,
    x_abbreviation =>X_ABBREVIATION,
    x_arts_teaching_cal_type_cd =>X_ARTS_TEACHING_CAL_TYPE_CD,
    x_closed_ind =>NVL(X_CLOSED_IND,'N'),
    x_notes =>X_NOTES,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_CA_TYPE (
    CAL_TYPE,
    DESCRIPTION,
    S_CAL_CAT,
    ABBREVIATION,
    ARTS_TEACHING_CAL_TYPE_CD,
    CLOSED_IND,
    NOTES,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.S_CAL_CAT,
    NEW_REFERENCES.ABBREVIATION,
    NEW_REFERENCES.ARTS_TEACHING_CAL_TYPE_CD,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.NOTES,
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
After_DML (
    p_action =>'INSERT',
    x_rowid =>X_ROWID
  );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2
) AS
  cursor c1 is select
      DESCRIPTION,
      S_CAL_CAT,
      ABBREVIATION,
      ARTS_TEACHING_CAL_TYPE_CD,
      CLOSED_IND,
      NOTES
    from IGS_CA_TYPE
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

  if ( (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.S_CAL_CAT = X_S_CAL_CAT)
      AND ((tlinfo.ABBREVIATION = X_ABBREVIATION)
           OR ((tlinfo.ABBREVIATION is null)
               AND (X_ABBREVIATION is null)))
      AND ((tlinfo.ARTS_TEACHING_CAL_TYPE_CD = X_ARTS_TEACHING_CAL_TYPE_CD)
           OR ((tlinfo.ARTS_TEACHING_CAL_TYPE_CD is null)
               AND (X_ARTS_TEACHING_CAL_TYPE_CD is null)))
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.NOTES = X_NOTES)
           OR ((tlinfo.NOTES is null)
               AND (X_NOTES is null)))
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
  X_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2
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
    p_action =>'UPDATE',
    x_rowid =>X_ROWID,
    x_cal_type =>X_CAL_TYPE,
    x_description =>X_DESCRIPTION,
    x_s_cal_cat =>X_S_CAL_CAT,
    x_abbreviation =>X_ABBREVIATION,
    x_arts_teaching_cal_type_cd =>X_ARTS_TEACHING_CAL_TYPE_CD,
    x_closed_ind =>X_CLOSED_IND,
    x_notes =>X_NOTES,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  update IGS_CA_TYPE set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    S_CAL_CAT = NEW_REFERENCES.S_CAL_CAT,
    ABBREVIATION = NEW_REFERENCES.ABBREVIATION,
    ARTS_TEACHING_CAL_TYPE_CD = NEW_REFERENCES.ARTS_TEACHING_CAL_TYPE_CD,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    NOTES = NEW_REFERENCES.NOTES,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID=X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action =>'UPDATE',
    x_rowid =>X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_CAL_TYPE in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_S_CAL_CAT in VARCHAR2,
  X_ABBREVIATION in VARCHAR2,
  X_ARTS_TEACHING_CAL_TYPE_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_NOTES in VARCHAR2,
  X_MODE in VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_CA_TYPE
     where CAL_TYPE = X_CAL_TYPE
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_CAL_TYPE,
     X_DESCRIPTION,
     X_S_CAL_CAT,
     X_ABBREVIATION,
     X_ARTS_TEACHING_CAL_TYPE_CD,
     X_CLOSED_IND,
     X_NOTES,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_CAL_TYPE,
   X_DESCRIPTION,
   X_S_CAL_CAT,
   X_ABBREVIATION,
   X_ARTS_TEACHING_CAL_TYPE_CD,
   X_CLOSED_IND,
   X_NOTES,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
begin
Before_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
  delete from IGS_CA_TYPE
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
end DELETE_ROW;

end IGS_CA_TYPE_PKG;

/
