--------------------------------------------------------
--  DDL for Package Body IGS_AV_ADV_STANDING_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AV_ADV_STANDING_PKG" AS
/* $Header: IGSBI01B.pls 120.0 2005/07/05 16:04:58 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_AV_ADV_STANDING_ALL%RowType;
  new_references IGS_AV_ADV_STANDING_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_total_exmptn_approved IN NUMBER DEFAULT NULL,
    x_total_exmptn_granted IN NUMBER DEFAULT NULL,
    x_total_exmptn_perc_grntd IN NUMBER DEFAULT NULL,
    x_exemption_institution_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AV_ADV_STANDING_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      Igs_Ge_Msg_Stack.Add;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.person_id := x_person_id;
    new_references.course_cd := x_course_cd;
    new_references.version_number := x_version_number;
    new_references.total_exmptn_approved := x_total_exmptn_approved;
    new_references.total_exmptn_granted := x_total_exmptn_granted;
    new_references.total_exmptn_perc_grntd := x_total_exmptn_perc_grntd;
    new_references.exemption_institution_cd := x_exemption_institution_cd;
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

  -- Trigger description :-
  -- "OSS_TST".trg_as_br_iu
  -- BEFORE INSERT OR UPDATE
  -- ON IGS_AV_ADV_STANDING_ALL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsertUpdate1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
    v_message_name  varchar2(30);
  BEGIN
	-- Validate Advanced Standing IGS_PS_COURSE Code.
	IF p_inserting THEN
		IF IGS_AV_VAL_AS.advp_val_as_crs (
					new_references.person_id,
					new_references.course_cd,
					new_references.version_number,
					v_message_name) = FALSE THEN
			 Fnd_Message.Set_Name('IGS', v_message_name);
			 Igs_Ge_Msg_Stack.Add;
                   App_Exception.Raise_Exception;
		END IF;
	END IF;

  END BeforeRowInsertUpdate1;

--
  PROCEDURE CHECK_CONSTRAINTS (
      Column_name IN VARCHAR2 DEFAULT NULL,
      Column_Value IN VARCHAR2 DEFAULT NULL) AS
    CURSOR c_local_inst_ind (
  		cp_ins_cd	igs_or_institution.institution_cd%TYPE) IS
  		SELECT 	ins.local_institution_ind
  		FROM	igs_or_institution ins
  		WHERE	ins.institution_cd = cp_ins_cd;
    CURSOR cur_program_exempt_totals (
   			cp_course_cd	  IGS_PS_VER.course_cd%TYPE,
  			cp_version_number IGS_PS_VER.version_number%TYPE,
            cp_local_ind      VARCHAR2) IS
      SELECT  DECODE (cp_local_ind, 'N', NVL (cv.external_adv_stnd_limit, -1),
                                         NVL (cv.internal_adv_stnd_limit, -1)) adv_stnd_limit
  	  FROM	  igs_ps_ver cv
  	  WHERE   cv.course_cd        = cp_course_cd
      AND     cv.version_number   = cp_version_number;
     rec_cur_program_exempt_totals cur_program_exempt_totals%ROWTYPE;
     rec_local_inst_ind c_local_inst_ind%ROWTYPE;
     l_message_name fnd_new_messages.message_name%TYPE;
  BEGIN

  IF  column_name is null then
       NULL;
  ELSIF upper(Column_name) = 'COURSE_CD' then
       new_references.COURSE_CD := column_value;
  ELSIF upper(Column_name) = 'TOTAL_EXMPTN_GRANTED' then
       new_references. TOTAL_EXMPTN_GRANTED := IGS_GE_NUMBER.TO_NUM(column_value);
  ELSIF upper(Column_name) = 'EXEMPTION_INSTITUTION_CD' then
       new_references.EXEMPTION_INSTITUTION_CD := column_value;
  ELSIF upper(Column_name) = 'TOTAL_EXMPTN_PERC_GRNTD' then
       new_references.TOTAL_EXMPTN_PERC_GRNTD := IGS_GE_NUMBER.TO_NUM(column_value);
  ELSIF upper(Column_name) = 'TOTAL_EXMPTN_APPROVED' then
       new_references.TOTAL_EXMPTN_APPROVED := IGS_GE_NUMBER.TO_NUM(column_value);
  END IF;

  IF upper(column_name) = 'COURSE_CD' OR
      column_name is null Then
      IF new_references.COURSE_CD <> UPPER(new_references.COURSE_CD) Then
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
        Igs_Ge_Msg_Stack.Add;
        App_Exception.Raise_Exception;
      END IF;
  END IF;
  OPEN c_local_inst_ind (new_references.exemption_institution_cd);
  FETCH c_local_inst_ind INTO rec_local_inst_ind;
  IF (c_local_inst_ind%NOTFOUND) THEN
    rec_local_inst_ind.local_institution_ind := 'N';
  END IF;
  CLOSE c_local_inst_ind;
  IF (rec_local_inst_ind.local_institution_ind = 'N') THEN
    l_message_name := 'IGS_AV_EXCEEDS_PRGVER_EXT_LMT';
  ELSE
    l_message_name := 'IGS_AV_EXCEEDS_PRGVER_INT_LMT';
  END IF;
  OPEN cur_program_exempt_totals (
         new_references.course_cd,
         new_references.version_number,
         rec_local_inst_ind.local_institution_ind);
  FETCH cur_program_exempt_totals INTO rec_cur_program_exempt_totals;
  CLOSE cur_program_exempt_totals;
  IF upper(column_name) = 'TOTAL_EXMPTN_GRANTED' OR
     column_name is null Then
     IF (rec_cur_program_exempt_totals.adv_stnd_limit <> -1) THEN
       IF new_references.total_exmptn_granted < 0 OR
         new_references.total_exmptn_granted > rec_cur_program_exempt_totals.adv_stnd_limit Then
         Fnd_Message.Set_Name ('IGS', l_message_name);
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception;
       END IF;
     END IF;
  END IF;

  IF upper(column_name) = 'TOTAL_EXMPTN_PERC_GRNTD' OR
     column_name is null Then
     IF new_references.TOTAL_EXMPTN_PERC_GRNTD < 0 OR
         new_references.TOTAL_EXMPTN_PERC_GRNTD > 100 Then
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception;
      END IF;
   END IF;

   IF upper(column_name) = 'TOTAL_EXMPTN_APPROVED' OR
     column_name is null Then
     IF (rec_cur_program_exempt_totals.adv_stnd_limit <> -1) THEN
       IF new_references.TOTAL_EXMPTN_APPROVED < 0 OR
          new_references.TOTAL_EXMPTN_APPROVED > rec_cur_program_exempt_totals.adv_stnd_limit Then
          Fnd_Message.Set_Name ('IGS', l_message_name);
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception;
       END IF;
     END IF;
   END IF;
   END CHECK_CONSTRAINTS ;
--

  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd) AND
         (old_references.version_number = new_references.version_number)) OR
        ((new_references.course_cd IS NULL) AND
         (new_references.version_number IS NULL))) THEN
      NULL;
    ELSE
---
    IF  NOT IGS_PS_VER_PKG.Get_PK_For_Validation (
          new_references.course_cd,
          new_references.version_number) THEN

          FND_Message.Set_Name('FND','FORM_RECORD_DELETED');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception ;

    END IF;
---
   END IF;

   IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSE
---
       IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
          new_references.person_id) THEN

          FND_Message.Set_Name('FND','FORM_RECORD_DELETED');
          Igs_Ge_Msg_Stack.Add;
          App_Exception.Raise_Exception ;
       END IF;
---
    END IF;

  END Check_Parent_Existance;


  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AV_STND_UNIT_PKG.GET_FK_IGS_AV_ADV_STANDING (
      old_references.person_id,
      old_references.course_cd,
      old_references.version_number,
      old_references.exemption_institution_cd
      );

    IGS_AV_STND_UNIT_LVL_PKG.GET_FK_IGS_AV_ADV_STANDING (
      old_references.person_id,
      old_references.course_cd,
      old_references.version_number,
      old_references.exemption_institution_cd
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id IN NUMBER,
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_exemption_institution_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_ADV_STANDING_ALL
      WHERE    person_id = x_person_id
      AND      course_cd = x_course_cd
      AND      version_number = x_version_number
      AND      exemption_institution_cd =x_exemption_institution_cd
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
---
    IF (cur_rowid%FOUND) THEN
       Close cur_rowid;
       Return (TRUE);
    ELSE
       Close cur_rowid;
       Return (FALSE);
    END IF;
---
  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_PS_VER (
    x_course_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_ADV_STANDING_ALL
      WHERE    course_cd = x_course_cd
      AND      version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
 IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_AS_CRV_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
  END GET_FK_IGS_PS_VER;

  PROCEDURE GET_FK_IGS_PE_PERSON (
    x_person_id IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_AV_ADV_STANDING_ALL
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_AV_AS_PE_FK');
      Igs_Ge_Msg_Stack.Add;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PE_PERSON;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN  VARCHAR2 DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_total_exmptn_approved IN NUMBER DEFAULT NULL,
    x_total_exmptn_granted IN NUMBER DEFAULT NULL,
    x_total_exmptn_perc_grntd IN NUMBER DEFAULT NULL,
    x_exemption_institution_cd IN VARCHAR2 DEFAULT NULL,
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
      x_person_id,
      x_course_cd,
      x_version_number,
      x_total_exmptn_approved,
      x_total_exmptn_granted,
      x_total_exmptn_perc_grntd,
      x_exemption_institution_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );

   IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate1 ( p_inserting => TRUE );
--
      IF Get_PK_For_Validation (new_references.person_id,
                                new_references.course_cd, new_references.version_number,new_references.exemption_institution_cd)  THEN
         FND_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC') ;
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception ;
      END IF;
--
      CHECK_CONSTRAINTS;
      Check_Parent_Existance;
   ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdate1 ( p_updating => TRUE );
      CHECK_CONSTRAINTS;
      Check_Parent_Existance;
   ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;
--
   ELSIF (P_Action = 'VALIDATE_INSERT') THEN
     IF Get_PK_For_Validation (new_references.person_id,
                              new_references.course_cd, new_references.version_number,new_references.exemption_institution_cd)  THEN
         FND_Message.Set_Name('IGS','IGS_GE_MULTI_ORG_DUP_REC') ;
         Igs_Ge_Msg_Stack.Add;
         App_Exception.Raise_Exception ;
     END IF;
     CHECK_CONSTRAINTS;
   ELSIF (P_Action = 'VALIDATE_UPDATE') THEN
     CHECK_CONSTRAINTS;
   ELSIF (P_Action = 'VALIDATE_DELETE') THEN
     Check_Child_Existance;
   END IF;
--
  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TOTAL_EXMPTN_APPROVED in NUMBER,
  X_TOTAL_EXMPTN_GRANTED in NUMBER,
  X_TOTAL_EXMPTN_PERC_GRNTD in NUMBER,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_AV_ADV_STANDING_ALL
      where PERSON_ID = X_PERSON_ID
      and COURSE_CD = X_COURSE_CD
      and VERSION_NUMBER = X_VERSION_NUMBER;
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
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'INSERT',
 x_rowid=>X_ROWID,
 x_course_cd=>X_COURSE_CD,
 x_exemption_institution_cd=>X_EXEMPTION_INSTITUTION_CD,
 x_person_id=>X_PERSON_ID,
 x_total_exmptn_approved=>NVL(X_TOTAL_EXMPTN_APPROVED,0),
 x_total_exmptn_granted=>NVL(X_TOTAL_EXMPTN_GRANTED,0),
 x_total_exmptn_perc_grntd=>NVL(X_TOTAL_EXMPTN_PERC_GRNTD,0),
 x_version_number=>X_VERSION_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN,
 x_org_id=>igs_ge_gen_003.get_org_id
 );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  insert into IGS_AV_ADV_STANDING_ALL (
    PERSON_ID,
    COURSE_CD,
    VERSION_NUMBER,
    TOTAL_EXMPTN_APPROVED,
    TOTAL_EXMPTN_GRANTED,
    TOTAL_EXMPTN_PERC_GRNTD,
    EXEMPTION_INSTITUTION_CD,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.VERSION_NUMBER,
    NEW_REFERENCES.TOTAL_EXMPTN_APPROVED,
    NEW_REFERENCES.TOTAL_EXMPTN_GRANTED,
    NEW_REFERENCES.TOTAL_EXMPTN_PERC_GRNTD,
    NEW_REFERENCES.EXEMPTION_INSTITUTION_CD,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
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
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TOTAL_EXMPTN_APPROVED in NUMBER,
  X_TOTAL_EXMPTN_GRANTED in NUMBER,
  X_TOTAL_EXMPTN_PERC_GRNTD in NUMBER,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2
) AS
  cursor c1 is select
      TOTAL_EXMPTN_APPROVED,
      TOTAL_EXMPTN_GRANTED,
      TOTAL_EXMPTN_PERC_GRNTD,
      EXEMPTION_INSTITUTION_CD
    from IGS_AV_ADV_STANDING_ALL
    where ROWID = X_ROWID  for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    Igs_Ge_Msg_Stack.Add;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;

  if ( (tlinfo.TOTAL_EXMPTN_APPROVED = X_TOTAL_EXMPTN_APPROVED)
      AND (tlinfo.TOTAL_EXMPTN_GRANTED = X_TOTAL_EXMPTN_GRANTED)
      AND (tlinfo.TOTAL_EXMPTN_PERC_GRNTD = X_TOTAL_EXMPTN_PERC_GRNTD)
      AND (tlinfo.EXEMPTION_INSTITUTION_CD = X_EXEMPTION_INSTITUTION_CD)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TOTAL_EXMPTN_APPROVED in NUMBER,
  X_TOTAL_EXMPTN_GRANTED in NUMBER,
  X_TOTAL_EXMPTN_PERC_GRNTD in NUMBER,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
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
    Igs_Ge_Msg_Stack.Add;
    app_exception.raise_exception;
  end if;
Before_DML(
 p_action=>'UPDATE',
 x_rowid=>X_ROWID,
 x_course_cd=>X_COURSE_CD,
 x_exemption_institution_cd=>X_EXEMPTION_INSTITUTION_CD,
 x_person_id=>X_PERSON_ID,
 x_total_exmptn_approved=>X_TOTAL_EXMPTN_APPROVED,
 x_total_exmptn_granted=>X_TOTAL_EXMPTN_GRANTED,
 x_total_exmptn_perc_grntd=>X_TOTAL_EXMPTN_PERC_GRNTD,
 x_version_number=>X_VERSION_NUMBER,
 x_creation_date=>X_LAST_UPDATE_DATE,
 x_created_by=>X_LAST_UPDATED_BY,
 x_last_update_date=>X_LAST_UPDATE_DATE,
 x_last_updated_by=>X_LAST_UPDATED_BY,
 x_last_update_login=>X_LAST_UPDATE_LOGIN
 );
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  update IGS_AV_ADV_STANDING_ALL set
    TOTAL_EXMPTN_APPROVED = NEW_REFERENCES.TOTAL_EXMPTN_APPROVED,
    TOTAL_EXMPTN_GRANTED = NEW_REFERENCES.TOTAL_EXMPTN_GRANTED,
    TOTAL_EXMPTN_PERC_GRNTD = NEW_REFERENCES.TOTAL_EXMPTN_PERC_GRNTD,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID  ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


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
  X_COURSE_CD in VARCHAR2,
  X_VERSION_NUMBER in NUMBER,
  X_TOTAL_EXMPTN_APPROVED in NUMBER,
  X_TOTAL_EXMPTN_GRANTED in NUMBER,
  X_TOTAL_EXMPTN_PERC_GRNTD in NUMBER,
  X_EXEMPTION_INSTITUTION_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_AV_ADV_STANDING_ALL
     where PERSON_ID = X_PERSON_ID
     and COURSE_CD = X_COURSE_CD
     and VERSION_NUMBER = X_VERSION_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID ;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_COURSE_CD,
     X_VERSION_NUMBER,
     X_TOTAL_EXMPTN_APPROVED,
     X_TOTAL_EXMPTN_GRANTED,
     X_TOTAL_EXMPTN_PERC_GRNTD,
     X_EXEMPTION_INSTITUTION_CD,
     X_ORG_ID,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PERSON_ID,
   X_COURSE_CD,
   X_VERSION_NUMBER,
   X_TOTAL_EXMPTN_APPROVED,
   X_TOTAL_EXMPTN_GRANTED,
   X_TOTAL_EXMPTN_PERC_GRNTD,
   X_EXEMPTION_INSTITUTION_CD,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
   X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2) AS
begin
 Before_DML(
  p_action => 'DELETE',
  x_rowid => X_ROWID
  );


  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
  delete from IGS_AV_ADV_STANDING_ALL
  where ROWID = X_ROWID ;
  if (sql%notfound) then
     fnd_message.set_name ('IGS', 'IGS_SC_POLICY_UPD_DEL_EXCEP');
     igs_ge_msg_stack.add;
     igs_sc_gen_001.unset_ctx('R');
     app_exception.raise_exception;
 end if;
 IF (x_mode = 'S') THEN
    igs_sc_gen_001.unset_ctx('R');
  END IF;


end DELETE_ROW;

end IGS_AV_ADV_STANDING_PKG;

/
