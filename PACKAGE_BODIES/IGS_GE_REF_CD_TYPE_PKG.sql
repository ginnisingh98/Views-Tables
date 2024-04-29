--------------------------------------------------------
--  DDL for Package Body IGS_GE_REF_CD_TYPE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_GE_REF_CD_TYPE_PKG" as
/* $Header: IGSMI04B.pls 120.1 2006/01/25 09:19:54 skpandey noship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_GE_REF_CD_TYPE_ALL%RowType;
  new_references IGS_GE_REF_CD_TYPE_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_self_service_flag IN VARCHAR2 DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_program_flag IN VARCHAR2 DEFAULT NULL,
    x_program_offering_option_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_section_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_section_occurrence_flag IN VARCHAR2 DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_mandatory_flag IN VARCHAR2 DEFAULT NULL,
    x_restricted_flag IN VARCHAR2
  ) as

/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sbeerell        09-MAY-2000     Changed according to DLD version 2
  (reverse chronological order - newest change first)
***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_GE_REF_CD_TYPE_ALL
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
    new_references.self_service_flag := x_self_service_flag;
    new_references.reference_cd_type := x_reference_cd_type;
    new_references.description := x_description;
    new_references.s_reference_cd_type := x_s_reference_cd_type;
    new_references.closed_ind := x_closed_ind;
    new_references.program_flag := x_program_flag;
    new_references.program_offering_option_flag := x_program_offering_option_flag;
    new_references.unit_flag := x_unit_flag;
    new_references.unit_section_flag := x_unit_section_flag;
    new_references.unit_section_occurrence_flag := x_unit_section_occurrence_flag;
    new_references.mandatory_flag := x_mandatory_flag;
    new_references.restricted_flag:= x_restricted_flag;
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

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
***************************************************************/
v_message_name NUMBER(5);
  BEGIN
	-- Validate system reference code type.
	IF p_inserting OR
		(p_updating AND
		((old_references.s_reference_cd_type <> new_references.s_reference_cd_type) OR
		(old_references.closed_ind = 'Y' AND new_references.closed_ind = 'N'))) THEN
		IF IGS_PS_VAL_RCT.crsp_val_rct_srct (
			new_references.s_reference_cd_type,
			v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS' , v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;

 PROCEDURE Check_Constraints(
   Column_Name IN VARCHAR2 DEFAULT NULL,
   Column_Value IN VARCHAR2 DEFAULT NULL
 ) as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
***************************************************************/
 BEGIN
	IF column_name is null then
	   NULL;
	ELSIF upper(Column_name) = 'CLOSED_IND' then
		new_references.closed_ind := COLUMN_VALUE;
	ELSIF upper(Column_name) = 'REFERENCE_CD_TYPE' then
		new_references.reference_cd_type := COLUMN_VALUE;
	ELSIF upper(Column_name) = 'S_REFERENCE_CD_TYPE' then
		new_references.s_reference_cd_type := COLUMN_VALUE;
	END IF;
	IF upper(Column_name) = 'CLOSED_IND' OR column_name is null then
		IF new_references.closed_ind <> UPPER(new_references.closed_ind ) OR
			new_references.closed_ind NOT IN ( 'Y' , 'N' ) then
			      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			      IGS_GE_MSG_STACK.ADD;
				App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_name) = 'REFERENCE_CD_TYPE' OR column_name is null then
		IF new_references.reference_cd_type  <> UPPER(new_references.reference_cd_type  ) then
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_name) = 'S_REFERENCE_CD_TYPE' OR column_name is null then
		IF new_references.s_reference_cd_type  <> UPPER(new_references.s_reference_cd_type  ) then
		      Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
		      IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;


      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'SELF_SERVICE_FLAG'  THEN
        new_references.self_service_flag := column_value;
      ELSIF  UPPER(column_name) = 'PROGRAM_FLAG'  THEN
        new_references.program_flag := column_value;
      ELSIF  UPPER(column_name) = 'PROGRAM_OFFERING_OPTION_FLAG'  THEN
        new_references.program_offering_option_flag := column_value;
      ELSIF  UPPER(column_name) = 'UNIT_FLAG'  THEN
        new_references.unit_flag := column_value;
      ELSIF  UPPER(column_name) = 'UNIT_SECTION_FLAG'  THEN
        new_references.unit_section_flag := column_value;
      ELSIF  UPPER(column_name) = 'UNIT_SECTION_OCCURRENCE_FLAG'  THEN
        new_references.unit_section_occurrence_flag := column_value;

        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'SELF_SERVICE_FLAG' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.self_service_flag IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PROGRAM_FLAG' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.program_flag IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PROGRAM_OFFERING_OPTION_FLAG' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.program_offering_option_flag IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'UNIT_FLAG' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.unit_flag IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'UNIT_SECTION_FLAG' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.unit_section_flag IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'UNIT_SECTION_OCCURRENCE_FLAG' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.unit_section_occurrence_flag IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

      --Added as a part of Enh#2858431
      IF NOT (new_references.restricted_flag IN ('Y', 'N'))  THEN
         Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
         IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;

 END Check_Constraints;


  PROCEDURE Check_Parent_Existance as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
***************************************************************/

  BEGIN

    IF (((old_references.s_reference_cd_type = new_references.s_reference_cd_type)) OR
        ((new_references.s_reference_cd_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_LOOKUPS_view_Pkg.Get_PK_For_Validation (
	  'REFERENCE_CD_TYPE',
        new_references.s_reference_cd_type
        ) THEN
		Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
***************************************************************/

  BEGIN

    IGS_GE_REF_CD_PKG.GET_FK_IGS_GE_REF_CD_TYPE(
       old_references.reference_cd_type
      );

    IGS_PS_ENT_PT_REF_CD_PKG.GET_FK_IGS_GE_REF_CD_TYPE (
       old_references.reference_cd_type
      );

    IGS_PS_REF_CD_PKG.GET_FK_IGS_GE_REF_CD_TYPE (
       old_references.reference_cd_type
      );

    IGS_PS_REF_CD_HIST_PKG.GET_FK_IGS_GE_REF_CD_TYPE (
       old_references.reference_cd_type
      );

    IGS_PS_UNIT_REF_CD_PKG.GET_FK_IGS_GE_REF_CD_TYPE (
      old_references.reference_cd_type
      );

    IGS_PS_UNIT_REF_HIST_PKG.GET_FK_IGS_GE_REF_CD_TYPE (
      old_references.reference_cd_type
      );

    igs_ps_unitreqref_cd_pkg.get_fk_igs_ge_ref_cd_type (
      old_references.reference_cd_type
      );

    igs_ps_us_req_ref_cd_pkg.get_fk_igs_ge_ref_cd_type (
      old_references.reference_cd_type
      );

    igs_ps_usec_ref_cd_pkg.get_fk_igs_ge_ref_cd_type (
      old_references.reference_cd_type
      );

    igs_ps_usec_ocur_ref_pkg.get_fk_igs_ge_ref_cd_type (
      old_references.reference_cd_type
      );

  END Check_Child_Existance;

  FUNCTION GET_PK_FOR_VALIDATION (
    x_reference_cd_type IN VARCHAR2
    ) RETURN BOOLEAN as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
***************************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_GE_REF_CD_TYPE_ALL
      WHERE    reference_cd_type  = x_reference_cd_type
      FOR UPDATE NOWAIT;

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

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_reference_cd_type IN VARCHAR2
    ) as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  skpandey        24-JAN-2006     Bug#3686538: Stubbed as a part of query optimization
  (reverse chronological order - newest change first)
***************************************************************/
  BEGIN
	NULL;
  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_self_service_flag IN VARCHAR2 DEFAULT NULL,
    x_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_s_reference_cd_type IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_program_flag IN VARCHAR2 DEFAULT NULL,
    x_program_offering_option_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_section_flag IN VARCHAR2 DEFAULT NULL,
    x_unit_section_occurrence_flag IN VARCHAR2 DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_mandatory_flag                    IN     VARCHAR2    DEFAULT NULL,
    x_restricted_flag IN VARCHAR2
  ) as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sbeerell        09-MAY-2000     Changed according to DLD version 2
  (reverse chronological order - newest change first)
***************************************************************/
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_self_service_flag,
      x_reference_cd_type,
      x_description,
      x_s_reference_cd_type,
      x_closed_ind,
      x_program_flag,
      x_program_offering_option_flag,
      x_unit_flag,
      x_unit_section_flag,
      x_unit_section_occurrence_flag,

      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id,
      x_mandatory_flag,
      x_restricted_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
  	IF  GET_PK_FOR_VALIDATION ( new_references.reference_cd_type)  THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
		IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
	END IF;
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
	Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
  	IF  GET_PK_FOR_VALIDATION ( new_references.reference_cd_type )  THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
  ) as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
***************************************************************/

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
  x_SELF_SERVICE_FLAG IN VARCHAR2,
  x_REFERENCE_CD_TYPE IN VARCHAR2,
  x_DESCRIPTION IN VARCHAR2,
  x_S_REFERENCE_CD_TYPE IN VARCHAR2,
  x_CLOSED_IND IN VARCHAR2,
  x_PROGRAM_FLAG IN VARCHAR2,
  x_PROGRAM_OFFERING_OPTION_FLAG IN VARCHAR2,
  x_UNIT_FLAG IN VARCHAR2,
  x_UNIT_SECTION_FLAG IN VARCHAR2,
  x_UNIT_SECTION_OCCURRENCE_FLAG IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  x_mandatory_flag                    IN     VARCHAR2    DEFAULT NULL,
  x_restricted_flag IN VARCHAR2
  ) as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sbaliga	13-feb-2002	  Assigned igs_ge_gen-003.get_org_id to x-org_id in before_dml
  				 as part of SWCR006 build.
  sbeerell        09-MAY-2000     Changed according to DLD version 2
  (reverse chronological order - newest change first)
***************************************************************/

    cursor C is select ROWID from IGS_GE_REF_CD_TYPE_ALL
      where REFERENCE_CD_TYPE = X_REFERENCE_CD_TYPE;
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
    x_rowid => X_ROWID,
    x_org_id => igs_ge_gen_003.get_org_id,
    x_self_service_flag=>X_SELF_SERVICE_FLAG,
    x_reference_cd_type=>X_REFERENCE_CD_TYPE,
    x_description=>X_DESCRIPTION,
    x_s_reference_cd_type=>X_S_REFERENCE_CD_TYPE,
    x_closed_ind=>NVL(X_CLOSED_IND,'N' ),
    x_program_flag=>X_PROGRAM_FLAG,
    x_program_offering_option_flag=>X_PROGRAM_OFFERING_OPTION_FLAG,
    x_unit_flag=>X_UNIT_FLAG,
    x_unit_section_flag=>X_UNIT_SECTION_FLAG,
    x_unit_section_occurrence_flag=>X_UNIT_SECTION_OCCURRENCE_FLAG,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN,

    x_mandatory_flag => X_MANDATORY_FLAG,
    x_restricted_flag =>x_restricted_flag
);
  insert into IGS_GE_REF_CD_TYPE_ALL (
                 SELF_SERVICE_FLAG
                ,REFERENCE_CD_TYPE
                ,DESCRIPTION
                ,S_REFERENCE_CD_TYPE
                ,CLOSED_IND
                ,PROGRAM_FLAG
                ,PROGRAM_OFFERING_OPTION_FLAG
                ,UNIT_FLAG
                ,UNIT_SECTION_FLAG
                ,UNIT_SECTION_OCCURRENCE_FLAG
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN
                ,ORG_ID
                ,MANDATORY_FLAG
                ,RESTRICTED_FLAG
  ) values (
                 NEW_REFERENCES.SELF_SERVICE_FLAG
                ,NEW_REFERENCES.REFERENCE_CD_TYPE
                ,NEW_REFERENCES.DESCRIPTION
                ,NEW_REFERENCES.S_REFERENCE_CD_TYPE
                ,NEW_REFERENCES.CLOSED_IND
                ,NEW_REFERENCES.PROGRAM_FLAG
                ,NEW_REFERENCES.PROGRAM_OFFERING_OPTION_FLAG
                ,NEW_REFERENCES.UNIT_FLAG
                ,NEW_REFERENCES.UNIT_SECTION_FLAG
                ,NEW_REFERENCES.UNIT_SECTION_OCCURRENCE_FLAG
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN
                ,NEW_REFERENCES.ORG_ID
                ,NEW_REFERENCES.MANDATORY_FLAG
                ,NEW_REFERENCES.RESTRICTED_FLAG
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
    x_rowid => X_ROWID
);
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  x_SELF_SERVICE_FLAG IN VARCHAR2,
  x_REFERENCE_CD_TYPE IN VARCHAR2,
  x_DESCRIPTION IN VARCHAR2,
  x_S_REFERENCE_CD_TYPE IN VARCHAR2,
  x_CLOSED_IND IN VARCHAR2,
  x_PROGRAM_FLAG IN VARCHAR2,
  x_PROGRAM_OFFERING_OPTION_FLAG IN VARCHAR2,
  x_UNIT_FLAG IN VARCHAR2,
  x_UNIT_SECTION_FLAG IN VARCHAR2,
  x_UNIT_SECTION_OCCURRENCE_FLAG IN VARCHAR2,
  x_mandatory_flag IN VARCHAR2 DEFAULT NULL ,
  x_restricted_flag IN VARCHAR2
) as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sbeerell        09-MAY-2000     Changed according to DLD version 2
  (reverse chronological order - newest change first)
***************************************************************/

  cursor c1 is select
     SELF_SERVICE_FLAG,
     DESCRIPTION,
     S_REFERENCE_CD_TYPE,
     CLOSED_IND,
     PROGRAM_FLAG,
     PROGRAM_OFFERING_OPTION_FLAG,
     UNIT_FLAG,
     UNIT_SECTION_FLAG,
     UNIT_SECTION_OCCURRENCE_FLAG,
     MANDATORY_FLAG,
     RESTRICTED_FLAG
    from IGS_GE_REF_CD_TYPE_ALL
       where ROWID = X_ROWID
    for update  nowait;
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

  if((tlinfo.SELF_SERVICE_FLAG = X_SELF_SERVICE_FLAG)
    AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
    AND (tlinfo.S_REFERENCE_CD_TYPE = X_S_REFERENCE_CD_TYPE)
    AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
    AND (tlinfo.PROGRAM_FLAG = X_PROGRAM_FLAG)
    AND (tlinfo.PROGRAM_OFFERING_OPTION_FLAG = X_PROGRAM_OFFERING_OPTION_FLAG)
    AND (tlinfo.UNIT_FLAG = X_UNIT_FLAG)
    AND (tlinfo.UNIT_SECTION_FLAG = X_UNIT_SECTION_FLAG)
    AND (tlinfo.UNIT_SECTION_OCCURRENCE_FLAG = X_UNIT_SECTION_OCCURRENCE_FLAG)
    AND ((tlinfo.mandatory_flag = x_mandatory_flag)
         OR ((tlinfo.mandatory_flag IS NULL)
             AND (X_mandatory_flag IS NULL)))
    AND ((tlinfo.restricted_flag = x_restricted_flag)
         OR ((tlinfo.restricted_flag IS NULL)
             AND (X_restricted_flag IS NULL)))
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
  x_SELF_SERVICE_FLAG IN VARCHAR2,
  x_REFERENCE_CD_TYPE IN VARCHAR2,
  x_DESCRIPTION IN VARCHAR2,
  x_S_REFERENCE_CD_TYPE IN VARCHAR2,
  x_CLOSED_IND IN VARCHAR2,
  x_PROGRAM_FLAG IN VARCHAR2,
  x_PROGRAM_OFFERING_OPTION_FLAG IN VARCHAR2,
  x_UNIT_FLAG IN VARCHAR2,
  x_UNIT_SECTION_FLAG IN VARCHAR2,
  x_UNIT_SECTION_OCCURRENCE_FLAG IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  x_mandatory_flag IN VARCHAR2 DEFAULT NULL,
  x_restricted_flag IN VARCHAR2
  ) as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sbeerell        09-MAY-2000     Changed according to DLD version 2
  (reverse chronological order - newest change first)
***************************************************************/

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
    x_rowid => X_ROWID,
    x_self_service_flag=>X_SELF_SERVICE_FLAG,
    x_reference_cd_type=>X_REFERENCE_CD_TYPE,
    x_description=>X_DESCRIPTION,
    x_s_reference_cd_type=>X_S_REFERENCE_CD_TYPE,
    x_closed_ind=>NVL(X_CLOSED_IND,'N' ),
    x_program_flag=>X_PROGRAM_FLAG,
    x_program_offering_option_flag=>X_PROGRAM_OFFERING_OPTION_FLAG,
    x_unit_flag=>X_UNIT_FLAG,
    x_unit_section_flag=>X_UNIT_SECTION_FLAG,
    x_unit_section_occurrence_flag=>X_UNIT_SECTION_OCCURRENCE_FLAG,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN,

    x_mandatory_flag =>X_MANDATORY_FLAG,
    x_restricted_flag => x_restricted_flag
		);

  update IGS_GE_REF_CD_TYPE_ALL set
      SELF_SERVICE_FLAG =  NEW_REFERENCES.SELF_SERVICE_FLAG,
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      S_REFERENCE_CD_TYPE =  NEW_REFERENCES.S_REFERENCE_CD_TYPE,
      CLOSED_IND =  NEW_REFERENCES.CLOSED_IND,
      PROGRAM_FLAG =  NEW_REFERENCES.PROGRAM_FLAG,
      PROGRAM_OFFERING_OPTION_FLAG =  NEW_REFERENCES.PROGRAM_OFFERING_OPTION_FLAG,
      UNIT_FLAG =  NEW_REFERENCES.UNIT_FLAG,
      UNIT_SECTION_FLAG =  NEW_REFERENCES.UNIT_SECTION_FLAG,
      UNIT_SECTION_OCCURRENCE_FLAG =  NEW_REFERENCES.UNIT_SECTION_OCCURRENCE_FLAG,
      LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
      LAST_UPDATED_BY = X_LAST_UPDATED_BY,
      LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
      MANDATORY_FLAG = NEW_REFERENCES.MANDATORY_FLAG,
      RESTRICTED_FLAG = NEW_REFERENCES.RESTRICTED_FLAG
    where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'UPDATE',
    x_rowid => X_ROWID
  );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  x_SELF_SERVICE_FLAG IN VARCHAR2,
  x_REFERENCE_CD_TYPE IN VARCHAR2,
  x_DESCRIPTION IN VARCHAR2,
  x_S_REFERENCE_CD_TYPE IN VARCHAR2,
  x_CLOSED_IND IN VARCHAR2,
  x_PROGRAM_FLAG IN VARCHAR2,
  x_PROGRAM_OFFERING_OPTION_FLAG IN VARCHAR2,
  x_UNIT_FLAG IN VARCHAR2,
  x_UNIT_SECTION_FLAG IN VARCHAR2,
  x_UNIT_SECTION_OCCURRENCE_FLAG IN VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER,
  X_mandatory_flag IN VARCHAR2 DEFAULT NULL,
  x_restricted_flag IN VARCHAR2
  ) as
/*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sbeerell        09-MAY-2000     Changed according to DLD version 2
  (reverse chronological order - newest change first)
***************************************************************/

  cursor c1 is select rowid from IGS_GE_REF_CD_TYPE_ALL
  where ROWID = X_ROWID
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SELF_SERVICE_FLAG,
     X_REFERENCE_CD_TYPE,
     X_DESCRIPTION,
     X_S_REFERENCE_CD_TYPE,
     X_CLOSED_IND,
     X_PROGRAM_FLAG,
     X_PROGRAM_OFFERING_OPTION_FLAG,
     X_UNIT_FLAG,
     X_UNIT_SECTION_FLAG,
     X_UNIT_SECTION_OCCURRENCE_FLAG,
     X_MODE,
     X_ORG_ID,
     x_MANDATORY_FLAG,
     x_RESTRICTED_FLAG);

    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SELF_SERVICE_FLAG,
   X_REFERENCE_CD_TYPE,
   X_DESCRIPTION,
   X_S_REFERENCE_CD_TYPE,
   X_CLOSED_IND,
   X_PROGRAM_FLAG,
   X_PROGRAM_OFFERING_OPTION_FLAG,
   X_UNIT_FLAG,
   X_UNIT_SECTION_FLAG,
   X_UNIT_SECTION_OCCURRENCE_FLAG,
   X_MODE,
   x_MANDATORY_FLAG ,
   x_RESTRICTED_FLAG);

end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
  Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  delete from IGS_GE_REF_CD_TYPE_ALL
    where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_GE_REF_CD_TYPE_PKG;

/
