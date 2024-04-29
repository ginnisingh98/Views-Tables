--------------------------------------------------------
--  DDL for Package Body IGS_PS_DSCP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_DSCP_PKG" as
 /* $Header: IGSPI52B.pls 115.6 2002/11/29 02:30:30 nsidana ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PS_DSCP_ALL%RowType;
  new_references IGS_PS_DSCP_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_funding_index_1 IN NUMBER DEFAULT NULL,
    x_funding_index_2 IN NUMBER DEFAULT NULL,
    x_funding_index_3 IN NUMBER DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_DSCP_ALL
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
    new_references.discipline_group_cd := x_discipline_group_cd;
    new_references.description := x_description;
    new_references.funding_index_1 := x_funding_index_1;
    new_references.funding_index_2 := x_funding_index_2;
    new_references.funding_index_3 := x_funding_index_3;
    new_references.govt_discipline_group_cd := x_govt_discipline_group_cd;
    new_references.closed_ind := x_closed_ind;
    new_references.org_id:=x_org_id;
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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name	VARCHAR2(30);
	v_description			IGS_PS_DSCP_ALL.description%TYPE	DEFAULT NULL;
	v_funding_index_1		IGS_PS_DSCP_ALL.funding_index_1%TYPE	DEFAULT NULL;
	v_funding_index_2		IGS_PS_DSCP_ALL.funding_index_2%TYPE	DEFAULT NULL;
	v_funding_index_3		IGS_PS_DSCP_ALL.funding_index_3%TYPE	DEFAULT NULL;
	v_govt_discipline_group_cd
					IGS_PS_DSCP_ALL.govt_discipline_group_cd%TYPE DEFAULT NULL;
	v_closed_ind			IGS_PS_DSCP_ALL.closed_ind%TYPE		DEFAULT NULL;

	x_rowid		varchar2(25);
	l_org_id        NUMBER(15);
	CURSOR SPDH_CUR IS
		 SELECT Rowid
		 FROM IGS_PS_DSCP_HIST
		 WHERE discipline_group_cd = old_references.discipline_group_cd;

  BEGIN
	-- Validate Govt IGS_PS_DSCP group code. Also validate if the closed
	-- indicator has been updated from closed to open to
	-- verify that the Govt IGS_PS_DSCP group code is not closed.
	IF p_inserting OR
		(old_references.govt_discipline_group_cd <> new_references.govt_discipline_group_cd) OR
		((old_references.closed_ind = 'N') AND
		( new_references.closed_ind = 'Y')) THEN
		IF IGS_PS_VAL_DI.crsp_val_di_govt_dg (
			new_references.govt_discipline_group_cd,
			v_message_name) = FALSE THEN
			FND_MESSAGE.SET_NAME('IGS',v_message_name);
      IGS_GE_MSG_STACK.ADD;
			APP_EXCEPTION.RAISE_EXCEPTION;
		END IF;
	END IF;
	IF p_updating THEN
		IF old_references.description <> new_references.description OR
				nvl(old_references.funding_index_1,999999) <> nvl(new_references.funding_index_1,999999) OR
				nvl(old_references.funding_index_2,999999) <> nvl(new_references.funding_index_2,999999) OR
				nvl(old_references.funding_index_3,999999) <> nvl(new_references.funding_index_3,999999) OR
				old_references.govt_discipline_group_cd <> new_references.govt_discipline_group_cd OR
				old_references.closed_ind <> new_references.closed_ind THEN
			IF old_references.description <> new_references.description THEN
				v_description := old_references.description;
			END IF;
			IF nvl(old_references.funding_index_1,999999) <> nvl(new_references.funding_index_1,999999) THEN
				v_funding_index_1 := old_references.funding_index_1;
			END IF;
			IF nvl(old_references.funding_index_2,999999) <> nvl(new_references.funding_index_2,999999) THEN
				v_funding_index_2 := old_references.funding_index_2;
			END IF;
			IF nvl(old_references.funding_index_3,999999) <> nvl(new_references.funding_index_3,999999) THEN
				v_funding_index_3 := old_references.funding_index_3;
			END IF;
			IF old_references.govt_discipline_group_cd <> new_references.govt_discipline_group_cd THEN
				v_govt_discipline_group_cd := old_references.govt_discipline_group_cd;
			END IF;
			IF old_references.closed_ind <> new_references.closed_ind THEN
				v_closed_ind := old_references.closed_ind;
			END IF;


			BEGIN
				IGS_PS_DSCP_HIST_PKG.Insert_Row(
					X_ROWID     			=>	x_rowid,
					X_DISCIPLINE_GROUP_CD         => 	old_references.discipline_group_cd,
					X_HIST_START_DT               => 	old_references.last_update_date,
					X_HIST_END_DT                 => 	new_references.last_update_date,
					X_HIST_WHO                    => 	old_references.last_updated_by,
					X_DESCRIPTION                 => 	v_description,
					X_FUNDING_INDEX_1             => 	v_funding_index_1,
					X_FUNDING_INDEX_2             => 	v_funding_index_2,
					X_FUNDING_INDEX_3             => 	v_funding_index_3,
					X_GOVT_DISCIPLINE_GROUP_CD	=>	v_govt_discipline_group_cd,
					X_CLOSED_IND                  => 	v_closed_ind,
					X_MODE                        =>	'R',
					X_ORG_ID                      =>        old_references.org_id);
			END ;
		END IF;
	END IF;
	IF p_deleting THEN
		-- Delete IGS_PS_DSCP_HIST records if the IGS_PS_DSCP is deleted.
	BEGIN

		FOR SPDH_Rec IN SPDH_CUR
		Loop
			IGS_PS_DSCP_HIST_PKG.Delete_Row(X_ROWID => SPDH_Rec.Rowid);
		End Loop;

	END;

	END IF;


  END BeforeRowInsertUpdateDelete1;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN
 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'FUNDING_INDEX_1' then
     new_references.funding_index_1 := IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'FUNDING_INDEX_2' then
     new_references.funding_index_2 := IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'FUNDING_INDEX_3' then
     new_references.funding_index_3 := IGS_GE_NUMBER.TO_NUM(column_value);
 ELSIF upper(Column_name) = 'CLOSED_IND' then
     new_references.closed_ind := column_value;
 ELSIF upper(Column_name) = 'DISCIPLINE_GROUP_CD' then
     new_references.discipline_group_cd := column_value;
 ELSIF upper(Column_name) = 'GOVT_DISCIPLINE_GROUP_CD' then
     new_references.govt_discipline_group_cd := column_value;
END IF;

IF upper(column_name) = 'FUNDING_INDEX_2' OR
     column_name is null Then
     IF new_references.funding_index_2 < 0 OR new_references.funding_index_2 > 1.70 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'FUNDING_INDEX_3' OR
     column_name is null Then
     IF new_references.funding_index_3 < 0 OR new_references.funding_index_3 > 1.70 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'CLOSED_IND' OR
     column_name is null Then
     IF new_references.closed_ind NOT IN ('Y','N') THEN
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;

IF upper(column_name) = 'FUNDING_INDEX_1' OR
     column_name is null Then
     IF new_references.funding_index_1 < 0 OR new_references.funding_index_1 > 1.70 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'DISCIPLINE_GROUP_CD' OR
     column_name is null Then
     IF new_references.discipline_group_cd <> UPPER(new_references.discipline_group_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'GOVT_DISCIPLINE_GROUP_CD' OR
     column_name is null Then
     IF new_references.govt_discipline_group_cd <> UPPER(new_references.govt_discipline_group_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
END check_constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.govt_discipline_group_cd = new_references.govt_discipline_group_cd)) OR
        ((new_references.govt_discipline_group_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_GOVT_DSCP_PKG.Get_PK_For_Validation (
        new_references.govt_discipline_group_cd
        ) THEN
		 Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
		 App_Exception.Raise_Exception;
	 END IF;
   END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_TER_ED_UNI_AT_PKG.GET_FK_IGS_PS_DSCP (
      old_references.discipline_group_cd
      );

    IGS_PS_UNIT_DSCP_PKG.GET_FK_IGS_PS_DSCP (
      old_references.discipline_group_cd
      );

    IGS_PS_UNT_DSCP_HIST_PKG.GET_FK_IGS_PS_DSCP (
      old_references.discipline_group_cd
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_discipline_group_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_DSCP_ALL
      WHERE    discipline_group_cd = x_discipline_group_cd
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

  PROCEDURE GET_FK_IGS_PS_GOVT_DSCP (
    x_govt_discipline_group_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_DSCP_ALL
      WHERE    govt_discipline_group_cd = x_govt_discipline_group_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_DI_GD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_GOVT_DSCP;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_funding_index_1 IN NUMBER DEFAULT NULL,
    x_funding_index_2 IN NUMBER DEFAULT NULL,
    x_funding_index_3 IN NUMBER DEFAULT NULL,
    x_govt_discipline_group_cd IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
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
      x_discipline_group_cd,
      x_description,
      x_funding_index_1,
      x_funding_index_2,
      x_funding_index_3,
      x_govt_discipline_group_cd,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );


 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdateDelete1 ( p_inserting => TRUE );
      IF  Get_PK_For_Validation (
	     new_references.discipline_group_cd
          ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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
       Check_Child_Existance;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
	     new_references.discipline_group_cd
          ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
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


  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FUNDING_INDEX_1 in NUMBER,
  X_FUNDING_INDEX_2 in NUMBER,
  X_FUNDING_INDEX_3 in NUMBER,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_org_id IN NUMBER
  ) as
  /****************************************************************************
  sbaliga 	13-feb-2002	Assigned igs_ge_gen_003.get_org_id to x_org_id
                                   in call to before_dml as part of SWCR006 build.
      ****************************************************************************/
    cursor C is select ROWID from IGS_PS_DSCP_ALL
      where DISCIPLINE_GROUP_CD = X_DISCIPLINE_GROUP_CD;
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

 Before_DML( p_action => 'INSERT',
    x_rowid => X_ROWID,
    x_discipline_group_cd => X_DISCIPLINE_GROUP_CD,
    x_description => X_DESCRIPTION,
    x_funding_index_1 => X_FUNDING_INDEX_1,
    x_funding_index_2 => X_FUNDING_INDEX_2,
    x_funding_index_3 => X_FUNDING_INDEX_3,
    x_govt_discipline_group_cd => X_GOVT_DISCIPLINE_GROUP_CD,
    x_closed_ind => NVL(X_CLOSED_IND,'N'),
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN,
    x_org_id => igs_ge_gen_003.get_org_id
  );
  insert into IGS_PS_DSCP_ALL (
    DISCIPLINE_GROUP_CD,
    DESCRIPTION,
    FUNDING_INDEX_1,
    FUNDING_INDEX_2,
    FUNDING_INDEX_3,
    GOVT_DISCIPLINE_GROUP_CD,
    CLOSED_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.DISCIPLINE_GROUP_CD,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.FUNDING_INDEX_1,
    NEW_REFERENCES.FUNDING_INDEX_2,
    NEW_REFERENCES.FUNDING_INDEX_3,
    NEW_REFERENCES.GOVT_DISCIPLINE_GROUP_CD,
    NEW_REFERENCES.CLOSED_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
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
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FUNDING_INDEX_1 in NUMBER,
  X_FUNDING_INDEX_2 in NUMBER,
  X_FUNDING_INDEX_3 in NUMBER,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2

) as
  cursor c1 is select
      DESCRIPTION,
      FUNDING_INDEX_1,
      FUNDING_INDEX_2,
      FUNDING_INDEX_3,
      GOVT_DISCIPLINE_GROUP_CD,
      CLOSED_IND,
      ORG_ID
    from IGS_PS_DSCP_ALL
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
      AND ((tlinfo.FUNDING_INDEX_1 = X_FUNDING_INDEX_1)
           OR ((tlinfo.FUNDING_INDEX_1 is null)
               AND (X_FUNDING_INDEX_1 is null)))
      AND ((tlinfo.FUNDING_INDEX_2 = X_FUNDING_INDEX_2)
           OR ((tlinfo.FUNDING_INDEX_2 is null)
               AND (X_FUNDING_INDEX_2 is null)))
      AND ((tlinfo.FUNDING_INDEX_3 = X_FUNDING_INDEX_3)
           OR ((tlinfo.FUNDING_INDEX_3 is null)
               AND (X_FUNDING_INDEX_3 is null)))
      AND (tlinfo.GOVT_DISCIPLINE_GROUP_CD = X_GOVT_DISCIPLINE_GROUP_CD)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)

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
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FUNDING_INDEX_1 in NUMBER,
  X_FUNDING_INDEX_2 in NUMBER,
  X_FUNDING_INDEX_3 in NUMBER,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
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
    x_discipline_group_cd => X_DISCIPLINE_GROUP_CD,
    x_description => X_DESCRIPTION,
    x_funding_index_1 => X_FUNDING_INDEX_1,
    x_funding_index_2 => X_FUNDING_INDEX_2,
    x_funding_index_3 => X_FUNDING_INDEX_3,
    x_govt_discipline_group_cd => X_GOVT_DISCIPLINE_GROUP_CD,
    x_closed_ind => X_CLOSED_IND,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
  update IGS_PS_DSCP_ALL set
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    FUNDING_INDEX_1 = NEW_REFERENCES.FUNDING_INDEX_1,
    FUNDING_INDEX_2 = NEW_REFERENCES.FUNDING_INDEX_2,
    FUNDING_INDEX_3 = NEW_REFERENCES.FUNDING_INDEX_3,
    GOVT_DISCIPLINE_GROUP_CD = NEW_REFERENCES.GOVT_DISCIPLINE_GROUP_CD,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID  = X_ROWID
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
  X_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_DESCRIPTION in VARCHAR2,
  X_FUNDING_INDEX_1 in NUMBER,
  X_FUNDING_INDEX_2 in NUMBER,
  X_FUNDING_INDEX_3 in NUMBER,
  X_GOVT_DISCIPLINE_GROUP_CD in VARCHAR2,
  X_CLOSED_IND in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID IN NUMBER
  ) as
  cursor c1 is select rowid from IGS_PS_DSCP_ALL
     where DISCIPLINE_GROUP_CD = X_DISCIPLINE_GROUP_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_DISCIPLINE_GROUP_CD,
     X_DESCRIPTION,
     X_FUNDING_INDEX_1,
     X_FUNDING_INDEX_2,
     X_FUNDING_INDEX_3,
     X_GOVT_DISCIPLINE_GROUP_CD,
     X_CLOSED_IND,
     X_MODE,
     X_ORG_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_DISCIPLINE_GROUP_CD,
   X_DESCRIPTION,
   X_FUNDING_INDEX_1,
   X_FUNDING_INDEX_2,
   X_FUNDING_INDEX_3,
   X_GOVT_DISCIPLINE_GROUP_CD,
   X_CLOSED_IND,
   X_MODE
);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
 Before_DML( p_action => 'DELETE',
    x_rowid => X_ROWID
  );
  delete from IGS_PS_DSCP_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );
end DELETE_ROW;

end IGS_PS_DSCP_PKG;

/
