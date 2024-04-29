--------------------------------------------------------
--  DDL for Package Body IGS_CA_INST_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_CA_INST_REL_PKG" AS
/* $Header: IGSCI13B.pls 120.0 2005/06/02 03:52:17 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_CA_INST_REL%RowType;
  new_references IGS_CA_INST_REL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sub_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sub_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_sup_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sup_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_load_research_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_CA_INST_REL
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
    new_references.sub_cal_type := x_sub_cal_type;
    new_references.sub_ci_sequence_number := x_sub_ci_sequence_number;
    new_references.sup_cal_type := x_sup_cal_type;
    new_references.sup_ci_sequence_number := x_sup_ci_sequence_number;
    new_references.load_research_percentage := x_load_research_percentage;
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
  -- "OSS_TST".trg_cir_as_i
  -- AFTER INSERT
  -- ON IGS_CA_INST_REL

  PROCEDURE BeforeRowInsertUpdateDelete(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  /******************************************************************
  Created By        : schodava
  Date Created By   : 22-Jan-2002
  Purpose           : Enh # 2187247
		      Validates a one-to-one relation only between
		      a Fee and Load calendar instance.
		      Prevents delete of a FCI-LCI relation
		      if used in FAM module, FTCI or FCCI
  Known limitations,
  enhancements,
  remarks            :
  Change History
  Who		 When		 What
  smvk		05-Feb-2002	Added call to IGS_FI_CREDITS_PKG.GET_FK_IGS_CA_INST_2
				This is as per new Application Hierarchicy Compliance DLD
		    		Enhancement Bug No. 2191470
  ******************************************************************/
    cst_load	CONSTANT VARCHAR2(10):= 'LOAD';
    cst_fee	CONSTANT VARCHAR2(10):= 'FEE';
    l_c_sup_cat	igs_ca_type.s_cal_cat%TYPE;

    CURSOR	c_cat(cp_cal_type IN igs_ca_type.cal_type%TYPE) IS
    SELECT	s_cal_cat
    FROM	igs_ca_type
    WHERE	cal_type = cp_cal_type;

    CURSOR	c_fci_lci(cp_sup_cal_type IN igs_ca_inst.cal_type%TYPE,
			  cp_sup_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE,
			  cp_sub_cal_type IN igs_ca_inst.cal_type%TYPE,
			  cp_sub_ci_sequence_number IN igs_ca_inst.sequence_number%TYPE) IS
    SELECT	'x'
    FROM	igs_ca_inst_rel cir,
		igs_ca_type ct1,
		igs_ca_type ct2
    WHERE	cir.sub_cal_type		= ct1.cal_type
    AND		ct1.s_cal_cat			= cst_load
    AND 	cir.sup_cal_type		= ct2.cal_type
    AND		ct2.s_cal_cat			= cst_fee
    AND		((cir.sup_cal_type		= cp_sup_cal_type
		AND cir.sup_ci_sequence_number	= cp_sup_ci_sequence_number)
		OR (cir.sub_cal_type		= cp_sub_cal_type
		AND cir.sub_ci_sequence_number  = cp_sub_ci_sequence_number))
    AND		cir.rowid <> NVL(l_rowid,'0');

  BEGIN

    IF p_inserting or p_updating THEN
      -- Allows only one to one relation between a Fee Cal Instance
      -- and a Load Cal Instance
      FOR l_c_cat IN c_cat(new_references.sup_cal_type) LOOP
        l_c_sup_cat := l_c_cat.s_cal_cat;
      END LOOP;
        FOR l_c_cat IN c_cat(new_references.sub_cal_type) LOOP
          IF l_c_sup_cat = cst_fee AND
	     l_c_cat.s_cal_cat = cst_load THEN
 	    FOR l_c_fci_lci IN c_fci_lci(new_references.sup_cal_type,
					 new_references.sup_ci_sequence_number,
					 new_references.sub_cal_type,
					 new_references.sub_ci_sequence_number) LOOP
	    	FND_MESSAGE.SET_NAME('IGS','IGS_FI_FCI_LCI_ONE_REL');
	    	IGS_GE_MSG_STACK.ADD;
	    	APP_EXCEPTION.RAISE_EXCEPTION;
	    END LOOP;
	  END IF;
	END LOOP;
    END IF;

    IF p_deleting THEN

    -- Prevents delete of a Fee Cal Instance relation if it is used in the FTCI table
      IGS_FI_F_TYP_CA_INST_PKG.GET_FK_IGS_CA_INST (
        old_references.sup_cal_type,
        old_references.sup_ci_sequence_number
      );

    -- Prevents delete of a Fee Cal Instance relation if it is used in the FCCI table
    IGS_FI_F_CAT_CA_INST_PKG.GET_FK_IGS_CA_INST (
        old_references.sup_cal_type,
        old_references.sup_ci_sequence_number
      );

    -- Prevents delete if Fee Cal Instance is used in igs_fi_credits_all table Bug No. 2191470
    IGS_FI_CREDITS_PKG.GET_FK_IGS_CA_INST_2(
        old_references.sup_cal_type,
        old_references.sup_ci_sequence_number
    );

    END IF;

  END BeforeRowInsertUpdateDelete;

  PROCEDURE AfterStmtInsert2(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  v_message_name	varchar2(30);
  BEGIN
  	-- Validation routine calls.
  	IF p_inserting THEN
  		-- Validate superior/sub-ordinate calendar instance relationship
  		IF IGS_CA_VAL_CIR.calp_val_cir_ci	 (new_references.sub_cal_type,
  			new_references.sub_ci_sequence_number,
  			new_references.sup_cal_type,
  			new_references.sup_ci_sequence_number,
  			v_message_name) = FALSE
  		THEN
				Fnd_Message.Set_Name('IGS',v_message_name);
				IGS_GE_MSG_STACK.ADD;
				APP_EXCEPTION.RAISE_EXCEPTION;
  		END IF;
  	END IF;
  END AfterStmtInsert2;

FUNCTION Check_acad_adm_cal_rel(p_rowid IN ROWID )
  RETURN BOOLEAN AS
  CURSOR c_acad_adm_rel IS
  SELECT 'X'
  FROM   igs_ca_inst_rel a ,
         igs_ca_type b ,
         igs_ca_type c ,
         igs_ca_inst d ,
         igs_ca_inst e ,
	 igs_ca_stat f,
	 igs_ca_stat g
   WHERE a.rowid = p_rowid
   AND   a.sub_cal_type = b.cal_type
   AND   b.s_cal_cat = 'ADMISSION'
   AND   a.sup_cal_type = c.cal_type
   AND   c.s_cal_cat = 'ACADEMIC'
   AND   a.sub_cal_type = d.cal_type
   AND   a.sub_ci_sequence_number = d.sequence_number
   AND   f.s_cal_status = 'ACTIVE'
   AND   d.cal_status = f.cal_status
   AND   a.sup_cal_type = e.cal_type
   AND   a.sup_ci_sequence_number = e.sequence_number
   AND   g.s_cal_status = 'ACTIVE'
   AND   e.cal_status = g.cal_status;
   l_c_acad_adm_rel VARCHAR2(1);
BEGIN
    OPEN c_acad_adm_rel;
     FETCH c_acad_adm_rel INTO l_c_acad_adm_rel;
     IF c_acad_adm_rel%FOUND THEN
      RETURN TRUE;
     ELSE
      RETURN FALSE;
     END IF;
    CLOSE c_acad_adm_rel;
END Check_acad_adm_cal_rel;

PROCEDURE Check_Constraints (
   Column_Name	IN	VARCHAR2	DEFAULT NULL,
   Column_Value 	IN	VARCHAR2	DEFAULT NULL
   ) AS
BEGIN
  	IF Column_Name is NULL THEN
  		NULL;
  	ELSIF upper(Column_Name) = 'LOAD_RESEARCH_PERCENTAGE' then
  		new_references.load_research_percentage := igs_ge_number.to_num(Column_Value);
  	ELSIF upper(Column_Name) = 'SUB_CAL_TYPE' then
  		new_references.sub_cal_type := Column_Value;
  	ELSIF upper(Column_Name) = 'SUP_CAL_TYPE' then
  		new_references.sup_cal_type := Column_Value;
  	END IF;

   	IF upper(Column_Name) = 'LOAD_RESEARCH_PERCENTAGE' OR
     		column_name is NULL THEN
   		IF new_references.load_research_percentage < 000.01 OR new_references.load_research_percentage > 100.00 THEN
   			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
   			IGS_GE_MSG_STACK.ADD;
   			App_Exception.Raise_Exception;
   		END IF;
	END IF;
	IF upper(Column_Name) = 'SUB_CAL_TYPE' OR
  		column_name is NULL THEN
		IF new_references.sub_cal_type <> UPPER(new_references.sub_cal_type) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
	IF upper(Column_Name) = 'SUP_CAL_TYPE' OR
  		column_name is NULL THEN
		IF new_references.sup_cal_type <> UPPER(new_references.sup_cal_type) THEN
			Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception;
		END IF;
	END IF;
END Check_Constraints;

PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.sub_cal_type = new_references.sub_cal_type) AND
         (old_references.sub_ci_sequence_number = new_references.sub_ci_sequence_number)) OR
        ((new_references.sub_cal_type IS NULL) OR
         (new_references.sub_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.sub_cal_type,
        new_references.sub_ci_sequence_number
        ) THEN
		     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
		     IGS_GE_MSG_STACK.ADD;
		     App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.sup_cal_type = new_references.sup_cal_type) AND
         (old_references.sup_ci_sequence_number = new_references.sup_ci_sequence_number)) OR
        ((new_references.sup_cal_type IS NULL) OR
         (new_references.sup_ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT IGS_CA_INST_PKG.Get_PK_For_Validation (
        new_references.sup_cal_type,
        new_references.sup_ci_sequence_number
        ) THEN
	     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
	     IGS_GE_MSG_STACK.ADD;
	     App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN

    IGS_AD_APPL_PKG.GET_FK_IGS_CA_INST_REL (
      old_references.sub_cal_type,
      old_references.sub_ci_sequence_number,
      old_references.sup_cal_type,
      old_references.sup_ci_sequence_number
      );

    IF NVL(fnd_profile.value('IGS_RECRUITING_ENABLED'), 'N') = 'Y' THEN
      EXECUTE IMMEDIATE
      'begin IGR_I_APPL_PKG.GET_FK_IGS_CA_INST_REL  ( :1, :2, :3, :4); end;'
      USING old_references.sub_cal_type,
        old_references.sub_ci_sequence_number,
        old_references.sup_cal_type,
        old_references.sup_ci_sequence_number;
    END IF;

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_sub_cal_type IN VARCHAR2,
    x_sub_ci_sequence_number IN NUMBER,
    x_sup_cal_type IN VARCHAR2,
    x_sup_ci_sequence_number IN NUMBER
    ) RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_INST_REL
      WHERE    sub_cal_type = x_sub_cal_type
      AND      sub_ci_sequence_number = x_sub_ci_sequence_number
      AND      sup_cal_type = x_sup_cal_type
      AND      sup_ci_sequence_number = x_sup_ci_sequence_number;

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

  PROCEDURE GET_FK_IGS_CA_INST (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_CA_INST_REL
      WHERE    (sub_cal_type = x_cal_type
      AND      sub_ci_sequence_number = x_sequence_number)
	OR	   (sup_cal_type = x_cal_type
      AND      sup_ci_sequence_number = x_sequence_number);
    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_CA_CIR_CI_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_CA_INST;



  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_sub_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sub_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_sup_cal_type IN VARCHAR2 DEFAULT NULL,
    x_sup_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_load_research_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /******************************************************************
  Change History
  Who		 When		 What
  schodava	 4-2-2002	 Enh # 2187247
				 Added call to BeforeRowInsertUpdateDelete
  kpadiyar       06-JAN-2002     Stop delete if SUP-CAL = Academic and SUB-CAL = Admission
				 and both calendars have active status.
  ******************************************************************/
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_sub_cal_type,
      x_sub_ci_sequence_number,
      x_sup_cal_type,
      x_sup_ci_sequence_number,
      x_load_research_percentage,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation (
		new_references.sub_cal_type,
		new_references.sub_ci_sequence_number,
		new_references.sup_cal_type,
		new_references.sup_ci_sequence_number ) THEN
			 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
			 IGS_GE_MSG_STACK.ADD;
			 App_Exception.Raise_Exception;
	  END IF;
      BeforeRowInsertUpdateDelete(p_inserting => TRUE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      BeforeRowInsertUpdateDelete(p_updating => TRUE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN

      -- Call all the procedures related to Before Delete.
      BeforeRowInsertUpdateDelete(p_deleting => TRUE);
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	  IF Get_PK_For_Validation (
		new_references.sub_cal_type,
		new_references.sub_ci_sequence_number,
		new_references.sup_cal_type,
		new_references.sup_ci_sequence_number ) THEN
			 Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
			 IGS_GE_MSG_STACK.ADD;
			 App_Exception.Raise_Exception;
	  END IF;
		Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
	Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      -- Stop delete if SUP-CAL = Academic and SUB-CAL = Admission and both calendars have active status.
      IF Check_acad_adm_cal_rel (p_rowid => x_rowid) THEN
			 Fnd_Message.Set_Name ('IGS', 'IGS_CA_REL_DEL_NOT');
			 IGS_GE_MSG_STACK.ADD;
			 App_Exception.Raise_Exception;
      END IF;
	BeforeRowInsertUpdateDelete(p_deleting => TRUE);
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
      AfterStmtInsert2 ( p_inserting => TRUE );
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
  X_SUB_CAL_TYPE in VARCHAR2,
  X_SUB_CI_SEQUENCE_NUMBER in NUMBER,
  X_SUP_CAL_TYPE in VARCHAR2,
  X_SUP_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOAD_RESEARCH_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_CA_INST_REL
      where SUB_CAL_TYPE = X_SUB_CAL_TYPE
      and SUB_CI_SEQUENCE_NUMBER = X_SUB_CI_SEQUENCE_NUMBER
      and SUP_CAL_TYPE = X_SUP_CAL_TYPE
      and SUP_CI_SEQUENCE_NUMBER = X_SUP_CI_SEQUENCE_NUMBER;
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
    x_sub_cal_type =>X_SUB_CAL_TYPE,
    x_sub_ci_sequence_number =>X_SUB_CI_SEQUENCE_NUMBER,
    x_sup_cal_type =>X_SUP_CAL_TYPE,
    x_sup_ci_sequence_number =>X_SUP_CI_SEQUENCE_NUMBER,
    x_load_research_percentage =>X_LOAD_RESEARCH_PERCENTAGE,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  insert into IGS_CA_INST_REL (
    SUB_CAL_TYPE,
    SUB_CI_SEQUENCE_NUMBER,
    SUP_CAL_TYPE,
    SUP_CI_SEQUENCE_NUMBER,
    LOAD_RESEARCH_PERCENTAGE,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.SUB_CAL_TYPE,
    NEW_REFERENCES.SUB_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.SUP_CAL_TYPE,
    NEW_REFERENCES.SUP_CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.LOAD_RESEARCH_PERCENTAGE,
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
  X_SUB_CAL_TYPE in VARCHAR2,
  X_SUB_CI_SEQUENCE_NUMBER in NUMBER,
  X_SUP_CAL_TYPE in VARCHAR2,
  X_SUP_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOAD_RESEARCH_PERCENTAGE in NUMBER
) AS
  cursor c1 is select
      LOAD_RESEARCH_PERCENTAGE
    from IGS_CA_INST_REL
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

      if ( ((tlinfo.LOAD_RESEARCH_PERCENTAGE = X_LOAD_RESEARCH_PERCENTAGE)
           OR ((tlinfo.LOAD_RESEARCH_PERCENTAGE is null)
               AND (X_LOAD_RESEARCH_PERCENTAGE is null)))
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
  X_SUB_CAL_TYPE in VARCHAR2,
  X_SUB_CI_SEQUENCE_NUMBER in NUMBER,
  X_SUP_CAL_TYPE in VARCHAR2,
  X_SUP_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOAD_RESEARCH_PERCENTAGE in NUMBER,
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
    p_action =>'UPDATE',
    x_rowid =>X_ROWID,
    x_sub_cal_type =>X_SUB_CAL_TYPE,
    x_sub_ci_sequence_number =>X_SUB_CI_SEQUENCE_NUMBER,
    x_sup_cal_type =>X_SUP_CAL_TYPE,
    x_sup_ci_sequence_number =>X_SUP_CI_SEQUENCE_NUMBER,
    x_load_research_percentage =>X_LOAD_RESEARCH_PERCENTAGE,
    x_creation_date =>X_LAST_UPDATE_DATE,
    x_created_by =>X_LAST_UPDATED_BY,
    x_last_update_date =>X_LAST_UPDATE_DATE,
    x_last_updated_by =>X_LAST_UPDATED_BY,
    x_last_update_login =>X_LAST_UPDATE_LOGIN
  );
  update IGS_CA_INST_REL set
    LOAD_RESEARCH_PERCENTAGE = NEW_REFERENCES.LOAD_RESEARCH_PERCENTAGE,
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
  X_SUB_CAL_TYPE in VARCHAR2,
  X_SUB_CI_SEQUENCE_NUMBER in NUMBER,
  X_SUP_CAL_TYPE in VARCHAR2,
  X_SUP_CI_SEQUENCE_NUMBER in NUMBER,
  X_LOAD_RESEARCH_PERCENTAGE in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_CA_INST_REL
     where SUB_CAL_TYPE = X_SUB_CAL_TYPE
     and SUB_CI_SEQUENCE_NUMBER = X_SUB_CI_SEQUENCE_NUMBER
     and SUP_CAL_TYPE = X_SUP_CAL_TYPE
     and SUP_CI_SEQUENCE_NUMBER = X_SUP_CI_SEQUENCE_NUMBER
  ;
begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_SUB_CAL_TYPE,
     X_SUB_CI_SEQUENCE_NUMBER,
     X_SUP_CAL_TYPE,
     X_SUP_CI_SEQUENCE_NUMBER,
     X_LOAD_RESEARCH_PERCENTAGE,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_SUB_CAL_TYPE,
   X_SUB_CI_SEQUENCE_NUMBER,
   X_SUP_CAL_TYPE,
   X_SUP_CI_SEQUENCE_NUMBER,
   X_LOAD_RESEARCH_PERCENTAGE,
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
  delete from IGS_CA_INST_REL
  where ROWID=X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
    p_action =>'DELETE',
    x_rowid =>X_ROWID
  );
end DELETE_ROW;

end IGS_CA_INST_REL_PKG;

/
