--------------------------------------------------------
--  DDL for Package Body IGS_PE_HLTH_INS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_HLTH_INS_PKG" AS
/* $Header: IGSNI57B.pls 120.3 2005/10/17 02:21:48 appldev ship $ */

  l_rowid VARCHAR2(25);
  old_references IGS_PE_HLTH_INS_ALL%RowType;
  new_references IGS_PE_HLTH_INS_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_health_ins_id IN NUMBER ,
    x_person_id IN NUMBER ,
    x_insurance_provider IN VARCHAR2,
    x_policy_number IN VARCHAR2 ,
    x_start_date IN DATE ,
    x_end_date IN DATE ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    X_ORG_ID in NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER ,
    x_insurance_cd      IN  VARCHAR2
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_HLTH_INS_ALL
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
    new_references.health_ins_id := x_health_ins_id;
    new_references.person_id := x_person_id;
    new_references.insurance_provider := x_insurance_provider;
    new_references.policy_number := x_policy_number;
    new_references.start_date := x_start_date;
    new_references.end_date := x_end_date;
    new_references.attribute_category := x_attribute_category;
    new_references.attribute1 := x_attribute1;
    new_references.attribute2 := x_attribute2;
    new_references.attribute3 := x_attribute3;
    new_references.attribute4 := x_attribute4;
    new_references.attribute5 := x_attribute5;
    new_references.attribute6 := x_attribute6;
    new_references.attribute7 := x_attribute7;
    new_references.attribute8 := x_attribute8;
    new_references.attribute9 := x_attribute9;
    new_references.attribute10 := x_attribute10;
    new_references.attribute11 := x_attribute11;
    new_references.attribute12 := x_attribute12;
    new_references.attribute13 := x_attribute13;
    new_references.attribute14 := x_attribute14;
    new_references.attribute15 := x_attribute15;
    new_references.attribute16 := x_attribute16;
    new_references.attribute17 := x_attribute17;
    new_references.attribute18 := x_attribute18;
    new_references.attribute19 := x_attribute19;
    new_references.attribute20 := x_attribute20;
    new_references.org_id := x_org_id;
    new_references.insurance_cd := x_insurance_cd;
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


 PROCEDURE BeforeRowInsertUpdate(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) as
  ------------------------------------------------------------------------------------------
  --Created by  : vredkar
  --Date created: 19-JUL-2005
  --
  --Purpose:
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------
  CURSOR validate_brth_dt(cp_person_id NUMBER) IS
  SELECT birth_date FROM
  IGS_PE_PERSON_BASE_V
  WHERE person_id =  cp_person_id ;

  l_bth_dt IGS_PE_PERSON_BASE_V.birth_date%TYPE;

  BEGIN
       IF p_inserting OR p_updating THEN
          OPEN validate_brth_dt(new_references.person_id);
          FETCH validate_brth_dt INTO  l_bth_dt;
          CLOSE validate_brth_dt;

          IF new_references.END_DATE IS NOT NULL AND new_references.START_DATE > new_references.END_DATE  THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_FI_ST_DT_LE_END_DT');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;

	 ELSIF  l_bth_dt IS NOT NULL AND l_bth_dt >  new_references.START_DATE  THEN
             FND_MESSAGE.SET_NAME('IGS','IGS_AD_STRT_DT_LESS_BIRTH_DT');
             IGS_GE_MSG_STACK.ADD;
             APP_EXCEPTION.RAISE_EXCEPTION;
         END IF;

     END IF;


 END BeforeRowInsertUpdate;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2   ,
		 Column_Value IN VARCHAR2   ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
  BEGIN

      IF column_name IS NULL THEN
        NULL;
        NULL;
      END IF;

  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
/***********************************************************

Created By : svisweas

Date Created By : 2000/05/17

Purpose : Check for uniqueness

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
   begin
     		IF Get_Uk_For_Validation (
    		new_references.insurance_cd --making id cd
    		,new_references.start_date
    		,new_references.person_id
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_PE_HLTH_INS_DUP_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;



  PROCEDURE Check_Parent_Existance AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
  BEGIN

    IF (((old_references.person_id = new_references.person_id)) OR
        ((new_references.person_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Person_Pkg.Get_PK_For_Validation (
        		new_references.person_id
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.insurance_cd = new_references.insurance_cd)) OR  -- making id cd
        ((new_references.insurance_cd IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.Get_PK_For_Validation (
        		'PE_INS_TYPE',
			new_references.insurance_cd
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_health_ins_id IN NUMBER
    ) RETURN BOOLEAN AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_HLTH_INS_ALL
      WHERE    health_ins_id = x_health_ins_id
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

  FUNCTION Get_UK_For_Validation (
    x_insurance_cd IN VARCHAR2, -- change id to cd
    x_start_date IN DATE,
    x_person_id IN NUMBER
    ) RETURN BOOLEAN AS
/***********************************************************

Created By : svisweas

Date Created By : 2000/05/17

Purpose : Check for uniqueness

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
      CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_HLTH_INS_ALL
      WHERE    insurance_cd = x_insurance_cd
      AND      start_date = x_start_date and person_id = x_person_id and ((l_rowid is null) or (rowid <> l_rowid))

      ;
    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        return (true);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK_For_Validation ;



  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_HLTH_INS_ALL
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PHI_PP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;

/*  PROCEDURE Get_FK_Igs_Pe_Code_Classes (
    x_code_classes_id IN NUMBER
    ) AS


Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What



    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_HLTH_INS_ALL
      WHERE    insurance_id = x_code_classes_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PHI_PCC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Code_Classes; */

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_health_ins_id IN NUMBER ,
    x_person_id IN NUMBER ,
    x_insurance_provider IN VARCHAR2 ,
    x_policy_number IN VARCHAR2 ,
    x_start_date IN DATE ,
    x_end_date IN DATE ,
    x_attribute_category IN VARCHAR2 ,
    x_attribute1 IN VARCHAR2 ,
    x_attribute2 IN VARCHAR2 ,
    x_attribute3 IN VARCHAR2 ,
    x_attribute4 IN VARCHAR2 ,
    x_attribute5 IN VARCHAR2 ,
    x_attribute6 IN VARCHAR2 ,
    x_attribute7 IN VARCHAR2 ,
    x_attribute8 IN VARCHAR2 ,
    x_attribute9 IN VARCHAR2 ,
    x_attribute10 IN VARCHAR2,
    x_attribute11 IN VARCHAR2,
    x_attribute12 IN VARCHAR2,
    x_attribute13 IN VARCHAR2,
    x_attribute14 IN VARCHAR2,
    x_attribute15 IN VARCHAR2,
    x_attribute16 IN VARCHAR2,
    x_attribute17 IN VARCHAR2,
    x_attribute18 IN VARCHAR2,
    x_attribute19 IN VARCHAR2,
    x_attribute20 IN VARCHAR2,
    X_ORG_ID in NUMBER ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER,
    x_insurance_cd IN VARCHAR2
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_health_ins_id,
      x_person_id,
      x_insurance_provider,
      x_policy_number,
      x_start_date,
      x_end_date,
      x_attribute_category,
      x_attribute1,
      x_attribute2,
      x_attribute3,
      x_attribute4,
      x_attribute5,
      x_attribute6,
      x_attribute7,
      x_attribute8,
      x_attribute9,
      x_attribute10,
      x_attribute11,
      x_attribute12,
      x_attribute13,
      x_attribute14,
      x_attribute15,
      x_attribute16,
      x_attribute17,
      x_attribute18,
      x_attribute19,
      x_attribute20,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_insurance_cd
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      BeforeRowInsertUpdate( TRUE, FALSE,FALSE );
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.health_ins_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate( FALSE,TRUE,FALSE );
      Null;
      Check_Constraints;
      Check_Uniqueness;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.health_ins_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
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
       x_HEALTH_INS_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_INSURANCE_PROVIDER IN VARCHAR2,
       x_POLICY_NUMBER IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 ,
      x_INSURANCE_CD IN VARCHAR2
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
    cursor C is select ROWID from IGS_PE_HLTH_INS_ALL
             where                 HEALTH_INS_ID= X_HEALTH_INS_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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
     SELECT IGS_PE_HLTH_INS_S.NEXTVAL INTO X_HEALTH_INS_ID
      FROM DUAL;

   Before_DML(
 		p_action		=>'INSERT',
 		x_rowid			=>X_ROWID,
 	       x_health_ins_id		=>X_HEALTH_INS_ID,
 	       x_person_id		=>X_PERSON_ID,
 	       x_insurance_provider	=>X_INSURANCE_PROVIDER,
 	       x_policy_number		=>X_POLICY_NUMBER,
 	       x_start_date		=>X_START_DATE,
 	       x_end_date		=>X_END_DATE,
 	       x_attribute_category	=>X_ATTRIBUTE_CATEGORY,
 	       x_attribute1		=>X_ATTRIBUTE1,
 	       x_attribute2		=>X_ATTRIBUTE2,
 	       x_attribute3		=>X_ATTRIBUTE3,
 	       x_attribute4		=>X_ATTRIBUTE4,
 	       x_attribute5		=>X_ATTRIBUTE5,
 	       x_attribute6		=>X_ATTRIBUTE6,
 	       x_attribute7		=>X_ATTRIBUTE7,
 	       x_attribute8		=>X_ATTRIBUTE8,
 	       x_attribute9		=>X_ATTRIBUTE9,
 	       x_attribute10		=>X_ATTRIBUTE10,
 	       x_attribute11		=>X_ATTRIBUTE11,
 	       x_attribute12		=>X_ATTRIBUTE12,
 	       x_attribute13		=>X_ATTRIBUTE13,
 	       x_attribute14		=>X_ATTRIBUTE14,
 	       x_attribute15		=>X_ATTRIBUTE15,
 	       x_attribute16		=>X_ATTRIBUTE16,
 	       x_attribute17		=>X_ATTRIBUTE17,
 	       x_attribute18		=>X_ATTRIBUTE18,
 	       x_attribute19		=>X_ATTRIBUTE19,
 	       x_attribute20		=>X_ATTRIBUTE20,
		x_org_id		=> igs_ge_gen_003.get_org_id,
	       x_creation_date		=>X_LAST_UPDATE_DATE,
	       x_created_by		=>X_LAST_UPDATED_BY,
	       x_last_update_date	=>X_LAST_UPDATE_DATE,
	       x_last_updated_by	=>X_LAST_UPDATED_BY,
	       x_last_update_login	=>X_LAST_UPDATE_LOGIN,
	       x_insurance_cd		=> X_INSURANCE_CD);
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PE_HLTH_INS_ALL (
		HEALTH_INS_ID
		,PERSON_ID
		,INSURANCE_PROVIDER
		,POLICY_NUMBER
		,START_DATE
		,END_DATE
		,ATTRIBUTE_CATEGORY
		,ATTRIBUTE1
		,ATTRIBUTE2
		,ATTRIBUTE3
		,ATTRIBUTE4
		,ATTRIBUTE5
		,ATTRIBUTE6
		,ATTRIBUTE7
		,ATTRIBUTE8
		,ATTRIBUTE9
		,ATTRIBUTE10
		,ATTRIBUTE11
		,ATTRIBUTE12
		,ATTRIBUTE13
		,ATTRIBUTE14
		,ATTRIBUTE15
		,ATTRIBUTE16
		,ATTRIBUTE17
		,ATTRIBUTE18
		,ATTRIBUTE19
		,ATTRIBUTE20
                ,ORG_ID
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
                ,INSURANCE_CD
        ) values  (
	        NEW_REFERENCES.HEALTH_INS_ID
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.INSURANCE_PROVIDER
	        ,NEW_REFERENCES.POLICY_NUMBER
	        ,NEW_REFERENCES.START_DATE
	        ,NEW_REFERENCES.END_DATE
	        ,NEW_REFERENCES.ATTRIBUTE_CATEGORY
	        ,NEW_REFERENCES.ATTRIBUTE1
	        ,NEW_REFERENCES.ATTRIBUTE2
	        ,NEW_REFERENCES.ATTRIBUTE3
	        ,NEW_REFERENCES.ATTRIBUTE4
	        ,NEW_REFERENCES.ATTRIBUTE5
	        ,NEW_REFERENCES.ATTRIBUTE6
	        ,NEW_REFERENCES.ATTRIBUTE7
	        ,NEW_REFERENCES.ATTRIBUTE8
	        ,NEW_REFERENCES.ATTRIBUTE9
	        ,NEW_REFERENCES.ATTRIBUTE10
	        ,NEW_REFERENCES.ATTRIBUTE11
	        ,NEW_REFERENCES.ATTRIBUTE12
	        ,NEW_REFERENCES.ATTRIBUTE13
	        ,NEW_REFERENCES.ATTRIBUTE14
	        ,NEW_REFERENCES.ATTRIBUTE15
	        ,NEW_REFERENCES.ATTRIBUTE16
	        ,NEW_REFERENCES.ATTRIBUTE17
	        ,NEW_REFERENCES.ATTRIBUTE18
	        ,NEW_REFERENCES.ATTRIBUTE19
	        ,NEW_REFERENCES.ATTRIBUTE20
                ,NEW_REFERENCES.ORG_ID
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,NEW_REFERENCES.INSURANCE_CD
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
    After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID );
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
      X_ROWID in  VARCHAR2,
       x_HEALTH_INS_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_INSURANCE_PROVIDER IN VARCHAR2,
       x_POLICY_NUMBER IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       x_INSURANCE_CD IN VARCHAR2
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
   cursor c1 is select
      PERSON_ID
,      INSURANCE_PROVIDER
,      POLICY_NUMBER
,      START_DATE
,      END_DATE
,      ATTRIBUTE_CATEGORY
,      ATTRIBUTE1
,      ATTRIBUTE2
,      ATTRIBUTE3
,      ATTRIBUTE4
,      ATTRIBUTE5
,      ATTRIBUTE6
,      ATTRIBUTE7
,      ATTRIBUTE8
,      ATTRIBUTE9
,      ATTRIBUTE10
,      ATTRIBUTE11
,      ATTRIBUTE12
,      ATTRIBUTE13
,      ATTRIBUTE14
,      ATTRIBUTE15
,      ATTRIBUTE16
,      ATTRIBUTE17
,      ATTRIBUTE18
,      ATTRIBUTE19
,      ATTRIBUTE20
,      INSURANCE_CD
    from IGS_PE_HLTH_INS_ALL
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
if ( (  tlinfo.PERSON_ID = X_PERSON_ID)
   AND (tlinfo.INSURANCE_PROVIDER = X_INSURANCE_PROVIDER)
  AND (tlinfo.POLICY_NUMBER = X_POLICY_NUMBER)
  AND (tlinfo.START_DATE = X_START_DATE)
  AND ((tlinfo.END_DATE = X_END_DATE)
 	    OR ((tlinfo.END_DATE is null)
		AND (X_END_DATE is null)))


  AND ((tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY)
 	    OR ((tlinfo.ATTRIBUTE_CATEGORY is null)
		AND (X_ATTRIBUTE_CATEGORY is null)))
  AND ((tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1)
 	    OR ((tlinfo.ATTRIBUTE1 is null)
		AND (X_ATTRIBUTE1 is null)))
  AND ((tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2)
 	    OR ((tlinfo.ATTRIBUTE2 is null)
		AND (X_ATTRIBUTE2 is null)))
  AND ((tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3)
 	    OR ((tlinfo.ATTRIBUTE3 is null)
		AND (X_ATTRIBUTE3 is null)))
  AND ((tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4)
 	    OR ((tlinfo.ATTRIBUTE4 is null)
		AND (X_ATTRIBUTE4 is null)))
  AND ((tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5)
 	    OR ((tlinfo.ATTRIBUTE5 is null)
		AND (X_ATTRIBUTE5 is null)))
  AND ((tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6)
 	    OR ((tlinfo.ATTRIBUTE6 is null)
		AND (X_ATTRIBUTE6 is null)))
  AND ((tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7)
 	    OR ((tlinfo.ATTRIBUTE7 is null)
		AND (X_ATTRIBUTE7 is null)))
  AND ((tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8)
 	    OR ((tlinfo.ATTRIBUTE8 is null)
		AND (X_ATTRIBUTE8 is null)))
  AND ((tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9)
 	    OR ((tlinfo.ATTRIBUTE9 is null)
		AND (X_ATTRIBUTE9 is null)))
  AND ((tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10)
 	    OR ((tlinfo.ATTRIBUTE10 is null)
		AND (X_ATTRIBUTE10 is null)))
  AND ((tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11)
 	    OR ((tlinfo.ATTRIBUTE11 is null)
		AND (X_ATTRIBUTE11 is null)))
  AND ((tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12)
 	    OR ((tlinfo.ATTRIBUTE12 is null)
		AND (X_ATTRIBUTE12 is null)))
  AND ((tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13)
 	    OR ((tlinfo.ATTRIBUTE13 is null)
		AND (X_ATTRIBUTE13 is null)))
  AND ((tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14)
 	    OR ((tlinfo.ATTRIBUTE14 is null)
		AND (X_ATTRIBUTE14 is null)))
  AND ((tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15)
 	    OR ((tlinfo.ATTRIBUTE15 is null)
		AND (X_ATTRIBUTE15 is null)))
  AND ((tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16)
 	    OR ((tlinfo.ATTRIBUTE16 is null)
		AND (X_ATTRIBUTE16 is null)))
  AND ((tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17)
 	    OR ((tlinfo.ATTRIBUTE17 is null)
		AND (X_ATTRIBUTE17 is null)))
  AND ((tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18)
 	    OR ((tlinfo.ATTRIBUTE18 is null)
		AND (X_ATTRIBUTE18 is null)))
  AND ((tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19)
 	    OR ((tlinfo.ATTRIBUTE19 is null)
		AND (X_ATTRIBUTE19 is null)))
  AND ((tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20)   OR ((tlinfo.ATTRIBUTE20 is null)	AND (X_ATTRIBUTE20 is null)))


  AND (tlinfo.INSURANCE_CD = X_INSURANCE_CD)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_HEALTH_INS_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_INSURANCE_PROVIDER IN VARCHAR2,
       x_POLICY_NUMBER IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
      X_MODE in VARCHAR2 ,
      x_INSURANCE_CD IN VARCHAR2
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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
   Before_DML(
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_health_ins_id=>X_HEALTH_INS_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_insurance_provider=>X_INSURANCE_PROVIDER,
 	       x_policy_number=>X_POLICY_NUMBER,
 	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
 	       x_attribute_category=>X_ATTRIBUTE_CATEGORY,
 	       x_attribute1=>X_ATTRIBUTE1,
 	       x_attribute2=>X_ATTRIBUTE2,
 	       x_attribute3=>X_ATTRIBUTE3,
 	       x_attribute4=>X_ATTRIBUTE4,
 	       x_attribute5=>X_ATTRIBUTE5,
 	       x_attribute6=>X_ATTRIBUTE6,
 	       x_attribute7=>X_ATTRIBUTE7,
 	       x_attribute8=>X_ATTRIBUTE8,
 	       x_attribute9=>X_ATTRIBUTE9,
 	       x_attribute10=>X_ATTRIBUTE10,
 	       x_attribute11=>X_ATTRIBUTE11,
 	       x_attribute12=>X_ATTRIBUTE12,
 	       x_attribute13=>X_ATTRIBUTE13,
 	       x_attribute14=>X_ATTRIBUTE14,
 	       x_attribute15=>X_ATTRIBUTE15,
 	       x_attribute16=>X_ATTRIBUTE16,
 	       x_attribute17=>X_ATTRIBUTE17,
 	       x_attribute18=>X_ATTRIBUTE18,
 	       x_attribute19=>X_ATTRIBUTE19,
 	       x_attribute20=>X_ATTRIBUTE20,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
 	       x_insurance_cd=>X_INSURANCE_CD  );
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_PE_HLTH_INS_ALL set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      INSURANCE_PROVIDER =  NEW_REFERENCES.INSURANCE_PROVIDER,
      POLICY_NUMBER =  NEW_REFERENCES.POLICY_NUMBER,
      START_DATE =  NEW_REFERENCES.START_DATE,
      END_DATE =  NEW_REFERENCES.END_DATE,
      ATTRIBUTE_CATEGORY =  NEW_REFERENCES.ATTRIBUTE_CATEGORY,
      ATTRIBUTE1 =  NEW_REFERENCES.ATTRIBUTE1,
      ATTRIBUTE2 =  NEW_REFERENCES.ATTRIBUTE2,
      ATTRIBUTE3 =  NEW_REFERENCES.ATTRIBUTE3,
      ATTRIBUTE4 =  NEW_REFERENCES.ATTRIBUTE4,
      ATTRIBUTE5 =  NEW_REFERENCES.ATTRIBUTE5,
      ATTRIBUTE6 =  NEW_REFERENCES.ATTRIBUTE6,
      ATTRIBUTE7 =  NEW_REFERENCES.ATTRIBUTE7,
      ATTRIBUTE8 =  NEW_REFERENCES.ATTRIBUTE8,
      ATTRIBUTE9 =  NEW_REFERENCES.ATTRIBUTE9,
      ATTRIBUTE10 =  NEW_REFERENCES.ATTRIBUTE10,
      ATTRIBUTE11 =  NEW_REFERENCES.ATTRIBUTE11,
      ATTRIBUTE12 =  NEW_REFERENCES.ATTRIBUTE12,
      ATTRIBUTE13 =  NEW_REFERENCES.ATTRIBUTE13,
      ATTRIBUTE14 =  NEW_REFERENCES.ATTRIBUTE14,
      ATTRIBUTE15 =  NEW_REFERENCES.ATTRIBUTE15,
      ATTRIBUTE16 =  NEW_REFERENCES.ATTRIBUTE16,
      ATTRIBUTE17 =  NEW_REFERENCES.ATTRIBUTE17,
      ATTRIBUTE18 =  NEW_REFERENCES.ATTRIBUTE18,
      ATTRIBUTE19 =  NEW_REFERENCES.ATTRIBUTE19,
      ATTRIBUTE20 =  NEW_REFERENCES.ATTRIBUTE20,
      INSURANCE_CD =NEW_REFERENCES.INSURANCE_CD,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
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


 After_DML (
	p_action => 'UPDATE' ,
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
       x_HEALTH_INS_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_INSURANCE_PROVIDER IN VARCHAR2,
       x_POLICY_NUMBER IN VARCHAR2,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
       x_ATTRIBUTE_CATEGORY IN VARCHAR2,
       x_ATTRIBUTE1 IN VARCHAR2,
       x_ATTRIBUTE2 IN VARCHAR2,
       x_ATTRIBUTE3 IN VARCHAR2,
       x_ATTRIBUTE4 IN VARCHAR2,
       x_ATTRIBUTE5 IN VARCHAR2,
       x_ATTRIBUTE6 IN VARCHAR2,
       x_ATTRIBUTE7 IN VARCHAR2,
       x_ATTRIBUTE8 IN VARCHAR2,
       x_ATTRIBUTE9 IN VARCHAR2,
       x_ATTRIBUTE10 IN VARCHAR2,
       x_ATTRIBUTE11 IN VARCHAR2,
       x_ATTRIBUTE12 IN VARCHAR2,
       x_ATTRIBUTE13 IN VARCHAR2,
       x_ATTRIBUTE14 IN VARCHAR2,
       x_ATTRIBUTE15 IN VARCHAR2,
       x_ATTRIBUTE16 IN VARCHAR2,
       x_ATTRIBUTE17 IN VARCHAR2,
       x_ATTRIBUTE18 IN VARCHAR2,
       x_ATTRIBUTE19 IN VARCHAR2,
       x_ATTRIBUTE20 IN VARCHAR2,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2,
      x_INSURANCE_CD IN VARCHAR2
  ) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
    cursor c1 is select ROWID from IGS_PE_HLTH_INS_ALL
             where     HEALTH_INS_ID= X_HEALTH_INS_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_HEALTH_INS_ID,
       X_PERSON_ID,
       X_INSURANCE_PROVIDER,
       X_POLICY_NUMBER,
       X_START_DATE,
       X_END_DATE,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
       X_ORG_ID,
      X_MODE,
      X_INSURANCE_CD);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_HEALTH_INS_ID,
       X_PERSON_ID,
       X_INSURANCE_PROVIDER,
       X_POLICY_NUMBER,
       X_START_DATE,
       X_END_DATE,
       X_ATTRIBUTE_CATEGORY,
       X_ATTRIBUTE1,
       X_ATTRIBUTE2,
       X_ATTRIBUTE3,
       X_ATTRIBUTE4,
       X_ATTRIBUTE5,
       X_ATTRIBUTE6,
       X_ATTRIBUTE7,
       X_ATTRIBUTE8,
       X_ATTRIBUTE9,
       X_ATTRIBUTE10,
       X_ATTRIBUTE11,
       X_ATTRIBUTE12,
       X_ATTRIBUTE13,
       X_ATTRIBUTE14,
       X_ATTRIBUTE15,
       X_ATTRIBUTE16,
       X_ATTRIBUTE17,
       X_ATTRIBUTE18,
       X_ATTRIBUTE19,
       X_ATTRIBUTE20,
      X_MODE,
      X_INSURANCE_CD);
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS
/***********************************************************

Created By : vvaitla

Date Created By : 2000/05/10

Purpose : To update,insert, add rows

Know limitations, enhancements or remarks

Change History

Who      When     What

****************************************************************/
begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_PE_HLTH_INS_ALL
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

After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_pe_hlth_ins_pkg;

/
