--------------------------------------------------------
--  DDL for Package Body IGS_PS_STDNT_APV_ALT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_STDNT_APV_ALT_PKG" as
/* $Header: IGSPI65B.pls 120.2 2005/07/05 02:37:43 appldev ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_pr_val_scaae.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------
  l_rowid VARCHAR2(25);
  old_references IGS_PS_STDNT_APV_ALT%RowType;
  new_references IGS_PS_STDNT_APV_ALT%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_exit_course_cd IN VARCHAR2 DEFAULT NULL,
    x_exit_version_number IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_rqrmnts_complete_ind IN VARCHAR2 DEFAULT NULL,
    x_rqrmnts_complete_dt IN DATE DEFAULT NULL,
    x_s_completed_source_type IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_STDNT_APV_ALT
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
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.exit_course_cd := x_exit_course_cd;
    new_references.exit_version_number := x_exit_version_number;
    new_references.version_number := x_version_number;
    new_references.rqrmnts_complete_ind := x_rqrmnts_complete_ind;
    new_references.rqrmnts_complete_dt := x_rqrmnts_complete_dt;
    new_references.s_completed_source_type := x_s_completed_source_type;
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

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name		VARCHAR2(30);
  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_PS_STDNT_APV_ALT') THEN
		IF p_inserting OR p_updating THEN
			-- Validate completing an alternative exit IGS_PS_COURSE
			IF p_inserting OR
			  (p_updating AND
			   new_references.rqrmnts_complete_ind <> old_references.rqrmnts_complete_ind) THEN
			      IF new_references.rqrmnts_complete_ind = 'Y' THEN
				-- Validate that SCA Status is not 'COMPLETED' or 'UNCONFIRM'.
				IF IGS_PR_VAL_SCA.prgp_val_sca_status (
					new_references.person_id,
					new_references.course_cd,
					v_message_name) = FALSE THEN
							Fnd_Message.Set_Name('IGS', v_message_name);
							IGS_GE_MSG_STACK.ADD;
							App_Exception.Raise_Exception;
				END IF;
				-- Validate that no IGS_PS_UNIT sets are incomplete or un-ended.
				IF IGS_PR_VAL_SCA.prgp_val_susa_cmplt (
					new_references.person_id,
					new_references.course_cd,
					v_message_name) = FALSE THEN
							Fnd_Message.Set_Name('IGS', v_message_name);
							IGS_GE_MSG_STACK.ADD;
							App_Exception.Raise_Exception;
				END IF;
				-- Validate that SCA status is not DISCONTIN, INTERMIT or LAPSED.
				IF IGS_PR_VAL_SCAAE.prgp_val_sca_cmplt (
					new_references.person_id,
					new_references.course_cd,
					v_message_name) = FALSE THEN
							Fnd_Message.Set_Name('IGS', v_message_name);
							IGS_GE_MSG_STACK.ADD;
							App_Exception.Raise_Exception;
				END IF;
			    ELSE
				-- Check that associated IGS_GR_GRADUAND record does not have a status
				-- of 'GRADUATED' or 'SURRENDER'.
				IF IGS_PR_VAL_SCA.prgp_val_undo_cmpltn (
					new_references.person_id,
					new_references.course_cd,
					new_references.version_number,
					new_references.exit_course_cd,
					new_references.exit_version_number,
					v_message_name) = FALSE THEN
							Fnd_Message.Set_Name('IGS', v_message_name);
							IGS_GE_MSG_STACK.ADD;
							App_Exception.Raise_Exception;
				END IF;
			    END IF;
			END IF;
			-- Validate completion details
			IF p_inserting OR
			   (p_updating AND
			   ((new_references.rqrmnts_complete_dt IS NULL AND
			      old_references.rqrmnts_complete_dt IS NOT NULL) OR
		 	    (new_references.rqrmnts_complete_dt IS NOT NULL AND
			     old_references.rqrmnts_complete_dt IS NULL) OR
			    (new_references.rqrmnts_complete_dt IS NOT NULL AND
			     old_references.rqrmnts_complete_dt <>new_references.rqrmnts_complete_dt))) THEN
				IF IGS_PR_VAL_SCAAE.prgp_val_scaae_cmplt(
					new_references.rqrmnts_complete_ind,
					new_references.rqrmnts_complete_dt,
					v_message_name) = FALSE THEN
							Fnd_Message.Set_Name('IGS', v_message_name);
							IGS_GE_MSG_STACK.ADD;
							App_Exception.Raise_Exception;
				END IF;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsertUpdate1;

 PROCEDURE Check_Constraints (
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN

 IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'COURSE_CD' then
     new_references.course_cd := column_value;
 ELSIF upper(Column_name) = 'EXIT_COURSE_CD' then
     new_references.exit_course_cd := column_value;
 ELSIF upper(Column_name) = 'RQRMNTS_COMPLETE_IND' then
     new_references.rqrmnts_complete_ind := column_value;
 ELSIF upper(Column_name) = 'S_COMPLETED_SOURCE_TYPE' then
     new_references.s_completed_source_type := column_value;
 END IF;

IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF new_references.course_cd <> UPPER(new_references.course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'EXIT_COURSE_CD' OR
     column_name is null Then
     IF new_references.exit_course_cd <> UPPER(new_references.exit_course_cd) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'S_COMPLETED_SOURCE_TYPE' OR
     column_name is null Then
     IF new_references.s_completed_source_type NOT IN ( 'SYSTEM' , 'MANUAL' ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'RQRMNTS_COMPLETE_IND' OR
     column_name is null Then
     IF new_references.rqrmnts_complete_ind NOT IN ( 'Y' , 'N' ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

END check_constraints;


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.exit_course_cd = new_references.exit_course_cd)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.exit_course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PE_ALTERNATV_EXT_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number,
        new_references.exit_course_cd
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.exit_course_cd = new_references.exit_course_cd) AND
         (old_references.exit_version_number = new_references.exit_version_number)) OR
        ((new_references.exit_course_cd IS NULL) OR
         (new_references.exit_version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.exit_course_cd,
        new_references.exit_version_number
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) OR
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
        new_references.course_cd,
        new_references.version_number
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
    END IF;

    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.course_cd = new_references.course_cd)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_STDNT_PS_ATT_PKG.Get_PK_For_Validation (
        new_references.person_id,
        new_references.course_cd
        ) THEN
	    Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	    IGS_GE_MSG_STACK.ADD;
	    App_Exception.Raise_Exception;
	END IF;
    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_exit_course_cd IN VARCHAR2,
    x_exit_version_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_STDNT_APV_ALT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      exit_course_cd = x_exit_course_cd
      AND      exit_version_number = x_exit_version_number
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

  PROCEDURE GET_FK_IGS_PE_ALTERNATV_EXT (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_exit_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_STDNT_APV_ALT
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      exit_course_cd = x_exit_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_SCAAE_AE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_ALTERNATV_EXT;

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_STDNT_APV_ALT
      WHERE    (exit_course_cd = x_course_cd
      AND      exit_version_number = x_version_number)
	OR       (course_cd = x_course_cd
      AND      version_number = x_version_number);

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_SCAAE_CRV_EXIT_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_VER;


  PROCEDURE GET_FK_IGS_EN_STDNT_PS_ATT (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PS_STDNT_APV_ALT
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_SCAAE_SCA_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_STDNT_PS_ATT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_exit_course_cd IN VARCHAR2 DEFAULT NULL,
    x_exit_version_number IN NUMBER DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_rqrmnts_complete_ind IN VARCHAR2 DEFAULT NULL,
    x_rqrmnts_complete_dt IN DATE DEFAULT NULL,
    x_s_completed_source_type IN VARCHAR2 DEFAULT NULL,
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
      x_person_id,
      x_course_cd,
      x_exit_course_cd,
      x_exit_version_number,
      x_version_number,
      x_rqrmnts_complete_ind,
      x_rqrmnts_complete_dt,
      x_s_completed_source_type,
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
			    new_references.person_id,
			    new_references.course_cd,
			    new_references.exit_course_cd,
			    new_references.exit_version_number
					 ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
			    new_references.person_id,
			    new_references.course_cd,
			    new_references.exit_course_cd,
			    new_references.exit_version_number
					 ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
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
  X_PERSON_ID in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
    cursor C is select ROWID from IGS_PS_STDNT_APV_ALT
      where PERSON_ID = X_PERSON_ID
      and EXIT_COURSE_CD = X_EXIT_COURSE_CD
      and EXIT_VERSION_NUMBER = X_EXIT_VERSION_NUMBER
      and COURSE_CD = X_COURSE_CD;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
begin
  X_LAST_UPDATE_DATE := SYSDATE;
  if(X_MODE = 'I') then
    X_LAST_UPDATED_BY := 1;
    X_LAST_UPDATE_LOGIN := 0;
  elsif (X_MODE IN ('R', 'S')) then
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
    x_person_id => X_PERSON_ID,
    x_course_cd => X_COURSE_CD,
    x_exit_course_cd => X_EXIT_COURSE_CD,
    x_exit_version_number => X_EXIT_VERSION_NUMBER,
    x_version_number => X_VERSION_NUMBER,
    x_rqrmnts_complete_ind => NVL(X_RQRMNTS_COMPLETE_IND,'N'),
    x_rqrmnts_complete_dt => X_RQRMNTS_COMPLETE_DT,
    x_s_completed_source_type => X_S_COMPLETED_SOURCE_TYPE,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PS_STDNT_APV_ALT (
    PERSON_ID,
    COURSE_CD,
    EXIT_COURSE_CD,
    EXIT_VERSION_NUMBER,
    VERSION_NUMBER,
    RQRMNTS_COMPLETE_IND,
    RQRMNTS_COMPLETE_DT,
    S_COMPLETED_SOURCE_TYPE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.EXIT_COURSE_CD,
    NEW_REFERENCES.EXIT_VERSION_NUMBER,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.RQRMNTS_COMPLETE_IND,
    NEW_REFERENCES.RQRMNTS_COMPLETE_DT,
    NEW_REFERENCES.S_COMPLETED_SOURCE_TYPE,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


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

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE IN (-28115, -28113, -28111)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_POLICY_EXCEPTION');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2
) as
  cursor c1 is select
      VERSION_NUMBER,
      RQRMNTS_COMPLETE_IND,
      RQRMNTS_COMPLETE_DT,
      S_COMPLETED_SOURCE_TYPE
    from IGS_PS_STDNT_APV_ALT
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

  if ( (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
      AND (tlinfo.RQRMNTS_COMPLETE_IND = X_RQRMNTS_COMPLETE_IND)
      AND ((tlinfo.RQRMNTS_COMPLETE_DT = X_RQRMNTS_COMPLETE_DT)
           OR ((tlinfo.RQRMNTS_COMPLETE_DT is null)
               AND (X_RQRMNTS_COMPLETE_DT is null)))
      AND ((tlinfo.S_COMPLETED_SOURCE_TYPE = X_S_COMPLETED_SOURCE_TYPE)
           OR ((tlinfo.S_COMPLETED_SOURCE_TYPE is null)
               AND (X_S_COMPLETED_SOURCE_TYPE is null)))
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
  X_PERSON_ID in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
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
  elsif (X_MODE IN ('R', 'S')) then
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
    x_person_id => X_PERSON_ID,
    x_course_cd => X_COURSE_CD,
    x_exit_course_cd => X_EXIT_COURSE_CD,
    x_exit_version_number => X_EXIT_VERSION_NUMBER,
    x_version_number => X_VERSION_NUMBER,
    x_rqrmnts_complete_ind => X_RQRMNTS_COMPLETE_IND,
    x_rqrmnts_complete_dt => X_RQRMNTS_COMPLETE_DT,
    x_s_completed_source_type => X_S_COMPLETED_SOURCE_TYPE,
    x_creation_date => X_LAST_UPDATE_DATE,
    x_created_by => X_LAST_UPDATED_BY,
    x_last_update_date => X_LAST_UPDATE_DATE,
    x_last_updated_by => X_LAST_UPDATED_BY,
    x_last_update_login => X_LAST_UPDATE_LOGIN
  );
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_PS_STDNT_APV_ALT set
    VERSION_NUMBER = NEW_REFERENCES.VERSION_NUMBER,
    RQRMNTS_COMPLETE_IND = NEW_REFERENCES.RQRMNTS_COMPLETE_IND,
    RQRMNTS_COMPLETE_DT = NEW_REFERENCES.RQRMNTS_COMPLETE_DT,
    S_COMPLETED_SOURCE_TYPE = NEW_REFERENCES.S_COMPLETED_SOURCE_TYPE,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

 After_DML(
  p_action => 'UPDATE',
  x_rowid => X_ROWID
  );

EXCEPTION
  WHEN OTHERS THEN
    IF (SQLCODE = (-28115)) THEN
      fnd_message.set_name ('IGS', 'IGS_SC_UPD_POLICY_EXCP');
      fnd_message.set_token ('ERR_CD', SQLCODE);
      igs_ge_msg_stack.add;
      igs_sc_gen_001.unset_ctx('R');
      app_exception.raise_exception;
    ELSE
      igs_sc_gen_001.unset_ctx('R');
      RAISE;
    END IF;

end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_EXIT_COURSE_CD in VARCHAR2,
  X_EXIT_VERSION_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_RQRMNTS_COMPLETE_IND in VARCHAR2,
  X_RQRMNTS_COMPLETE_DT in DATE,
  X_S_COMPLETED_SOURCE_TYPE in VARCHAR2,
  X_MODE in VARCHAR2 default 'R'
  ) as
  cursor c1 is select rowid from IGS_PS_STDNT_APV_ALT
     where PERSON_ID = X_PERSON_ID
     and EXIT_COURSE_CD = X_EXIT_COURSE_CD
     and EXIT_VERSION_NUMBER = X_EXIT_VERSION_NUMBER
     and COURSE_CD = X_COURSE_CD
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_EXIT_COURSE_CD,
     X_EXIT_VERSION_NUMBER,
     X_COURSE_CD,
     X_VERSION_NUMBER,
     X_RQRMNTS_COMPLETE_IND,
     X_RQRMNTS_COMPLETE_DT,
     X_S_COMPLETED_SOURCE_TYPE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_EXIT_COURSE_CD,
   X_EXIT_VERSION_NUMBER,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_RQRMNTS_COMPLETE_IND,
   X_RQRMNTS_COMPLETE_DT,
   X_S_COMPLETED_SOURCE_TYPE,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) as
begin
 Before_DML( p_action => 'DELETE',
    x_rowid => X_ROWID
  );
   IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_PS_STDNT_APV_ALT
  where ROWID = X_ROWID;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;

 After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );

end DELETE_ROW;

end IGS_PS_STDNT_APV_ALT_PKG;

/
