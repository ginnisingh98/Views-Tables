--------------------------------------------------------
--  DDL for Package Body IGS_EN_CAT_PRC_DTL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_CAT_PRC_DTL_PKG" AS
/* $Header: IGSEI15B.pls 115.6 2003/06/11 06:23:21 rnirwani ship $ */
  -------------------------------------------------------------------------------------------
  --Change History:
  --Who         When            What
  --smadathi    24-AUG-2001     Bug No. 1956374 .The call to igs_ge_gen_004.genp_val_sdtt_sess
  --                            is changed to igs_as_val_suaap.genp_val_sdtt_sess
  -------------------------------------------------------------------------------------------

  l_rowid VARCHAR2(25);
  old_references IGS_EN_CAT_PRC_DTL%RowType;
  new_references IGS_EN_CAT_PRC_DTL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_enrolment_cat IN VARCHAR2 ,
    x_s_student_comm_type IN VARCHAR2 ,
    x_enr_method_type IN VARCHAR2 ,
    x_person_add_allow_ind IN VARCHAR2 ,
    x_course_add_allow_ind IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_enforce_date_alias  IN VARCHAR2 ,
    x_config_min_cp_valdn IN VARCHAR2
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_CAT_PRC_DTL
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
    new_references.person_add_allow_ind := x_person_add_allow_ind;
    new_references.course_add_allow_ind := x_course_add_allow_ind;
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
    new_references.enforce_date_alias  :=  x_enforce_date_alias;
    new_references.config_min_cp_valdn := x_config_min_cp_valdn;


  END Set_Column_Values;

  -- Trigger description :-
  -- "OSS_TST".trg_ecpd_br_i
  -- BEFORE INSERT
  -- ON IGS_EN_CAT_PRC_DTL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsert1(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
      v_message_name  varchar2(30);
  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_CAT_PRC_DTL') THEN
		IF p_inserting THEN
			-- Validate the enrolment method type
			IF IGS_EN_VAL_ECPD.enrp_val_ecpd_emt(
					new_references.enr_method_type,
	 				v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
			END IF;
		END IF;
	END IF;


  END BeforeRowInsert1;

  -- Trigger description :-
  -- "OSS_TST".trg_ecpd_as_i
  -- AFTER INSERT
  -- ON IGS_EN_CAT_PRC_DTL

  PROCEDURE AfterStmtInsert2(
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS
	CURSOR c_ecpd IS
	SELECT	enrolment_cat,
		enr_method_type,
		s_student_comm_type
	FROM	IGS_EN_CAT_PRC_DTL;
      v_message_name  varchar2(30);
  BEGIN
	-- If trigger has not been disabled, perform required processing
	IF p_inserting AND
	     igs_as_val_suaap.genp_val_sdtt_sess('IGS_EN_CAT_PRC_DTL') THEN
		FOR v_ecpd_rec IN c_ecpd
		LOOP
			-- Validate the enrolment method type
			IF IGS_EN_VAL_ECPD.enrp_val_ecpd_comm(
					v_ecpd_rec.enrolment_cat,
					v_ecpd_rec.enr_method_type,
					v_ecpd_rec.s_student_comm_type,
		 			v_message_name) = FALSE THEN
			    Fnd_Message.Set_Name('IGS', v_message_name);
IGS_GE_MSG_STACK.ADD;
			    App_Exception.Raise_Exception;
			END IF;
		END LOOP;
	END IF;


  END AfterStmtInsert2;

 PROCEDURE Check_Constraints (
 	Column_Name	IN	VARCHAR2	,
 	Column_Value 	IN	VARCHAR2
 ) as

  BEGIN

    -- The following code checks for check constraints on the Columns.

    IF column_name is NULL THEN
        NULL;
    ELSIF  UPPER(column_name) = 'ENR_METHOD_TYPE' THEN
        new_references.enr_method_type := column_value;
    ELSIF  UPPER(column_name) = 'ENROLMENT_CAT' THEN
        new_references.enrolment_cat := column_value;
    ELSIF  UPPER(column_name) = 'COURSE_ADD_ALLOW_IND' THEN
        new_references.course_add_allow_ind := column_value;
    ELSIF  UPPER(column_name) = 'PERSON_ADD_ALLOW_IND' THEN
        new_references.person_add_allow_ind := column_value;
    ELSIF  UPPER(column_name) = 'S_STUDENT_COMM_TYPE' THEN
        new_references.s_student_comm_type := column_value;
    END IF;

    IF ((UPPER (column_name) = 'S_STUDENT_COMM_TYPE') OR (column_name IS NULL)) THEN
      IF new_references.s_student_comm_type NOT IN ( 'NEW' , 'RETURN' , 'ALL' )  THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'PERSON_ADD_ALLOW_IND') OR (column_name IS NULL)) THEN
      IF new_references.person_add_allow_ind NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'COURSE_ADD_ALLOW_IND') OR (column_name IS NULL)) THEN
      IF new_references.course_add_allow_ind NOT IN ( 'Y' , 'N' ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'ENROLMENT_CAT') OR (column_name IS NULL)) THEN
      IF (new_references.enrolment_cat <> UPPER (new_references.enrolment_cat)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF ((UPPER (column_name) = 'ENR_METHOD_TYPE') OR (column_name IS NULL)) THEN
      IF (new_references.enr_method_type <> UPPER (new_references.enr_method_type)) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;


  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.enr_method_type = new_references.enr_method_type)) OR
        ((new_references.enr_method_type IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_METHOD_TYPE_PKG.Get_PK_For_Validation (
        new_references.enr_method_type
        ) THEN

	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;

       END IF;

    END IF;

    IF (((old_references.enrolment_cat = new_references.enrolment_cat)) OR
        ((new_references.enrolment_cat IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_EN_ENROLMENT_CAT_PKG.Get_PK_For_Validation (
        new_references.enrolment_cat
        ) THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;

       END IF;

    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_EN_CAT_PRC_STEP_PKG.GET_FK_IGS_EN_CAT_PRC_DTL (
      old_references.enrolment_cat,
      old_references.s_student_comm_type,
      old_references.enr_method_type
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_enrolment_cat IN VARCHAR2,
    x_s_student_comm_type IN VARCHAR2,
    x_enr_method_type IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAT_PRC_DTL
      WHERE    enrolment_cat = x_enrolment_cat
      AND      s_student_comm_type = x_s_student_comm_type
      AND      enr_method_type = x_enr_method_type
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

  PROCEDURE GET_FK_IGS_EN_METHOD_TYPE (
    x_enr_method_type IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAT_PRC_DTL
      WHERE    enr_method_type = x_enr_method_type ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_ECPD_EMT_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_METHOD_TYPE;

  PROCEDURE GET_FK_IGS_EN_ENROLMENT_CAT (
    x_enrolment_cat IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_CAT_PRC_DTL
      WHERE    enrolment_cat = x_enrolment_cat ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_ECPD_EC_FK');
IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_EN_ENROLMENT_CAT;


 PROCEDURE get_fk_igs_ca_da (
    x_dt_alias               IN     VARCHAR2
  ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_cat_prc_dtl
      WHERE   ((enforce_date_alias = x_dt_alias));

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name ('IGS', 'IGS_EN_ECPD_DA_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_fk_igs_ca_da;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_enrolment_cat IN VARCHAR2 ,
    x_s_student_comm_type IN VARCHAR2 ,
    x_enr_method_type IN VARCHAR2 ,
    x_person_add_allow_ind IN VARCHAR2 ,
    x_course_add_allow_ind IN VARCHAR2 ,
    x_creation_date IN DATE  ,
    x_created_by IN NUMBER  ,
    x_last_update_date IN DATE  ,
    x_last_updated_by IN NUMBER  ,
    x_last_update_login IN NUMBER  ,
    x_enforce_date_alias  IN VARCHAR2 ,
    x_config_min_cp_valdn IN VARCHAR2
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_enrolment_cat,
      x_s_student_comm_type,
      x_enr_method_type,
      x_person_add_allow_ind,
      x_course_add_allow_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_enforce_date_alias ,
      x_config_min_cp_valdn
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsert1 ( p_inserting => TRUE ,
		         p_updating  => FALSE,
			 p_deleting  => FALSE );
	IF Get_PK_For_Validation(
		          new_references.enrolment_cat,
		          new_references.s_student_comm_type,
                          new_references.enr_method_type
	                            ) THEN
 		Fnd_message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
IGS_GE_MSG_STACK.ADD;
 		App_Exception.Raise_Exception;

	END IF;

      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.

      Check_Child_Existance;

    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      		IF  Get_PK_For_Validation (
		          new_references.enrolment_cat,
		          new_references.s_student_comm_type,
                          new_references.enr_method_type
				 ) THEN
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
  )AS
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterStmtInsert2 ( p_inserting => TRUE,
                         p_updating  => FALSE,
			 p_deleting  => FALSE);
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
  X_PERSON_ADD_ALLOW_IND in VARCHAR2,
  X_COURSE_ADD_ALLOW_IND in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ENFORCE_DATE_ALIAS  IN VARCHAR2 ,
  X_CONFIG_MIN_CP_VALDN IN VARCHAR2
  ) AS
    cursor C is select ROWID from IGS_EN_CAT_PRC_DTL
      where ENROLMENT_CAT = X_ENROLMENT_CAT
      and S_STUDENT_COMM_TYPE = X_S_STUDENT_COMM_TYPE
      and ENR_METHOD_TYPE = X_ENR_METHOD_TYPE;
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
  p_action => 'INSERT',
  x_rowid => X_ROWID,
  x_enrolment_cat => X_ENROLMENT_CAT,
  x_s_student_comm_type => X_S_STUDENT_COMM_TYPE,
  x_enr_method_type => X_ENR_METHOD_TYPE,
  x_person_add_allow_ind => X_PERSON_ADD_ALLOW_IND,
  x_course_add_allow_ind => X_COURSE_ADD_ALLOW_IND,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_enforce_date_alias =>  X_ENFORCE_DATE_ALIAS,
  x_config_min_cp_valdn =>   X_CONFIG_MIN_CP_VALDN
);

  insert into IGS_EN_CAT_PRC_DTL (
    ENROLMENT_CAT,
    S_STUDENT_COMM_TYPE,
    ENR_METHOD_TYPE,
    PERSON_ADD_ALLOW_IND,
    COURSE_ADD_ALLOW_IND,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ENFORCE_DATE_ALIAS,
    CONFIG_MIN_CP_VALDN
  ) values (
    NEW_REFERENCES.ENROLMENT_CAT,
    NEW_REFERENCES.S_STUDENT_COMM_TYPE,
    NEW_REFERENCES.ENR_METHOD_TYPE,
    NEW_REFERENCES.PERSON_ADD_ALLOW_IND,
    NEW_REFERENCES.COURSE_ADD_ALLOW_IND,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ENFORCE_DATE_ALIAS,
    NEW_REFERENCES.CONFIG_MIN_CP_VALDN
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
  X_ENROLMENT_CAT in VARCHAR2,
  X_S_STUDENT_COMM_TYPE in VARCHAR2,
  X_ENR_METHOD_TYPE in VARCHAR2,
  X_PERSON_ADD_ALLOW_IND in VARCHAR2,
  X_COURSE_ADD_ALLOW_IND in VARCHAR2,
  X_ENFORCE_DATE_ALIAS  IN VARCHAR2 ,
  X_CONFIG_MIN_CP_VALDN IN VARCHAR2
) AS
  cursor c1 is select
      PERSON_ADD_ALLOW_IND,
      COURSE_ADD_ALLOW_IND,
      ENFORCE_DATE_ALIAS,
      CONFIG_MIN_CP_VALDN
    from IGS_EN_CAT_PRC_DTL
    where ROWID = X_ROWID
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

  if ( (tlinfo.PERSON_ADD_ALLOW_IND = X_PERSON_ADD_ALLOW_IND)
      AND (tlinfo.COURSE_ADD_ALLOW_IND = X_COURSE_ADD_ALLOW_IND)
      AND ((tlinfo.ENFORCE_DATE_ALIAS = X_ENFORCE_DATE_ALIAS) OR ((tlinfo.ENFORCE_DATE_ALIAS IS NULL) AND (X_ENFORCE_DATE_ALIAS IS NULL)))
        AND ((tlinfo.CONFIG_MIN_CP_VALDN = X_CONFIG_MIN_CP_VALDN) OR ((tlinfo.CONFIG_MIN_CP_VALDN IS NULL) AND (X_CONFIG_MIN_CP_VALDN IS NULL)))
       ) THEN
      NULL;
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
  X_PERSON_ADD_ALLOW_IND in VARCHAR2,
  X_COURSE_ADD_ALLOW_IND in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ENFORCE_DATE_ALIAS  IN VARCHAR2 ,
  X_CONFIG_MIN_CP_VALDN IN VARCHAR2
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
  p_action => 'UPDATE',
  x_rowid => X_ROWID,
  x_enrolment_cat => X_ENROLMENT_CAT,
  x_s_student_comm_type => X_S_STUDENT_COMM_TYPE,
  x_enr_method_type => X_ENR_METHOD_TYPE,
  x_person_add_allow_ind => X_PERSON_ADD_ALLOW_IND,
  x_course_add_allow_ind => X_COURSE_ADD_ALLOW_IND,
  x_creation_date => X_LAST_UPDATE_DATE,
  x_created_by => X_LAST_UPDATED_BY,
  x_last_update_date =>X_LAST_UPDATE_DATE,
  x_last_updated_by => X_LAST_UPDATED_BY,
  x_last_update_login => X_LAST_UPDATE_LOGIN,
  x_enforce_date_alias  =>  X_ENFORCE_DATE_ALIAS,
  x_config_min_cp_valdn =>  X_CONFIG_MIN_CP_VALDN
);

  update IGS_EN_CAT_PRC_DTL set
    PERSON_ADD_ALLOW_IND = NEW_REFERENCES.PERSON_ADD_ALLOW_IND,
    COURSE_ADD_ALLOW_IND = NEW_REFERENCES.COURSE_ADD_ALLOW_IND,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
    ENFORCE_DATE_ALIAS  =  NEW_REFERENCES.ENFORCE_DATE_ALIAS,
    CONFIG_MIN_CP_VALDN = NEW_REFERENCES.CONFIG_MIN_CP_VALDN
    where ROWID = X_ROWID;

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
  X_ENROLMENT_CAT in VARCHAR2,
  X_S_STUDENT_COMM_TYPE in VARCHAR2,
  X_ENR_METHOD_TYPE in VARCHAR2,
  X_PERSON_ADD_ALLOW_IND in VARCHAR2,
  X_COURSE_ADD_ALLOW_IND in VARCHAR2,
  X_MODE in VARCHAR2 ,
  X_ENFORCE_DATE_ALIAS  IN VARCHAR2 ,
  X_CONFIG_MIN_CP_VALDN IN VARCHAR2
  ) AS
  cursor c1 is select rowid from IGS_EN_CAT_PRC_DTL
     where ENROLMENT_CAT = X_ENROLMENT_CAT
     and S_STUDENT_COMM_TYPE = X_S_STUDENT_COMM_TYPE
     and ENR_METHOD_TYPE = X_ENR_METHOD_TYPE
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
     X_PERSON_ADD_ALLOW_IND,
     X_COURSE_ADD_ALLOW_IND,
     X_MODE,
     X_ENFORCE_DATE_ALIAS,
     X_CONFIG_MIN_CP_VALDN
  );
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_ENROLMENT_CAT,
   X_S_STUDENT_COMM_TYPE,
   X_ENR_METHOD_TYPE,
   X_PERSON_ADD_ALLOW_IND,
   X_COURSE_ADD_ALLOW_IND,
   X_MODE,
   X_ENFORCE_DATE_ALIAS,
   X_CONFIG_MIN_CP_VALDN
);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
  ) AS
begin
Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
);


  delete from IGS_EN_CAT_PRC_DTL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
);

end DELETE_ROW;

end IGS_EN_CAT_PRC_DTL_PKG;

/
