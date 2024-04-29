--------------------------------------------------------
--  DDL for Package Body IGS_PE_PRIV_LEVEL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PRIV_LEVEL_PKG" AS
/* $Header: IGSNI61B.pls 120.1 2005/06/28 06:12:06 appldev ship $ */

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To create Table Handler Body
Know limitations, enhancements or remarks : None
Change History
Who		When		What
(reverse chronological order - newest change first)
********************************************************/

  l_rowid VARCHAR2(25);
  old_references igs_pe_priv_level%RowType;
  new_references igs_pe_priv_level%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_privacy_level_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_data_group IN VARCHAR2 DEFAULT NULL,
    x_data_group_id IN NUMBER DEFAULT NULL,
    x_action IN VARCHAR2 DEFAULT NULL,
    x_whom IN VARCHAR2 DEFAULT NULL,
    x_ref_notes_id IN NUMBER DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS


/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To Set Column Values
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PRIV_LEVEL
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
    new_references.privacy_level_id := x_privacy_level_id;
    new_references.person_id := x_person_id;
    new_references.data_group := x_data_group;
    new_references.data_group_id := x_data_group_id;
    new_references.action := x_action;
    new_references.whom := x_whom;
    new_references.ref_notes_id := x_ref_notes_id;
    new_references.start_date := x_start_date;
    new_references.end_date := x_end_date;
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

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To check constraints
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
        NULL;
      END IF;
  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To Check Parent Existance
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

  BEGIN

    IF NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation ('PERSON_PRIVACY_ACTION',
     new_references.ACTION) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

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

    IF (((old_references.data_group_id = new_references.data_group_id)) OR
        ((new_references.data_group_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Data_Groups_Pkg.Get_PK_For_Validation (
        		new_references.data_group_id
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;
    IF (((old_references.ref_notes_id = new_references.ref_notes_id)) OR
        ((new_references.ref_notes_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ge_Note_Pkg.Get_PK_For_Validation (
        		new_references.ref_notes_id
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_privacy_level_id IN NUMBER
    ) RETURN BOOLEAN AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To enforce Primary Key validations
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_priv_level
      WHERE    privacy_level_id = x_privacy_level_id
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

  PROCEDURE Get_FK_Igs_Pe_Person (
    x_person_id IN NUMBER
    ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To enforce Foriegn Key validation
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_priv_level
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PP_PPL_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;

  PROCEDURE BeforeDeletePrivLevel
  IS
    CURSOR ref_notes IS
    SELECT rowid
    FROM   igs_ge_note
    WHERE  reference_number = old_references.ref_notes_id;
  BEGIN
    FOR ref_rec IN ref_notes LOOP
      igs_ge_note_pkg.delete_row (ref_rec.rowid);
    END LOOP;

  END BeforeDeletePrivLevel;

  PROCEDURE beforeinsertupdate(p_inserting BOOLEAN , p_updating BOOLEAN) IS
    p_message_name VARCHAR2(30);
  BEGIN
    IF ( p_inserting = TRUE OR ( p_updating = TRUE AND new_references.data_group_id <> old_references.data_group_id ) ) THEN
        IF NOT igs_pe_data_groups_pkg.val_data_group(new_references.data_group_id , p_message_name) THEN
           Fnd_Message.Set_Name ('IGS',p_message_name);
           IGS_GE_MSG_STACK.ADD;
 	   App_Exception.Raise_Exception;
        END IF;
    END IF;

    IF p_inserting OR p_updating THEN
      IF(new_references.start_date IS NOT NULL) THEN

          /* kumma, 2902713, Modified the following if condition so that start date should not get compare with the sysdate if user has not changed the start date */

        --IF(trunc(new_references.start_date) <> trunc(sysdate) aND new_references.start_date < sysdate) THEN
        IF(trunc(new_references.start_date) < trunc(sysdate) AND new_references.start_date <> nvl((old_references.start_date),trunc(sysdate)))  THEN
            Fnd_Message.Set_Name('IGS','IGS_FI_ST_NOT_LT_CURRDT');
            IGS_GE_MSG_STACK.ADD;
            App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF(new_references.start_date > new_references.end_date) THEN
	Fnd_Message.Set_name('IGS','IGS_PE_FROM_DT_GRT_TO_DATE');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;
  END;



 PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_privacy_level_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_data_group IN VARCHAR2 DEFAULT NULL,
    x_data_group_id IN NUMBER DEFAULT NULL,
    x_lvl IN NUMBER DEFAULT NULL,
    x_action IN VARCHAR2 DEFAULT NULL,
    x_whom IN VARCHAR2 DEFAULT NULL,
    x_ref_notes_id IN NUMBER DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To check before DML
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_privacy_level_id,
      x_person_id,
      x_data_group,
      x_data_group_id,
      x_action,
      x_whom,
      x_ref_notes_id,
      x_start_date,
      x_end_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
     IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      beforeinsertupdate(TRUE,FALSE);
	     IF Get_Pk_For_Validation(
    		new_references.privacy_level_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      beforeinsertupdate(FALSE,TRUE);
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
       BeforeDeletePrivLevel;
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.privacy_level_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML;


 PROCEDURE afterrowinsertupdate(
    p_inserting IN BOOLEAN,
    p_updating IN BOOLEAN,
    p_deleting IN BOOLEAN
    ) AS
  ------------------------------------------------------------------------------------------
  --Created by  : kumma
  --Date created: 23-APR-2003
  --
  --Purpose:Bug 2902713. Moved the overlap validation from library
  --
  --Known limitations/enhancements and/or remarks:
  --
  --Change History:
  --Who         When            What
  ----------------------------------------------------------------------------------------------
  CURSOR c_priv_overlap(cp_person_id igs_pe_visa.person_id%TYPE, cp_data_group_id igs_pe_priv_level.data_group_id%TYPE) IS
  SELECT count(1)
  FROM
     igs_pe_priv_level p1,
     igs_pe_priv_level p2
  WHERE
     p1.person_id = cp_person_id and
     p1.person_id = p2.person_id and
     p1.data_group_id = cp_data_group_id and
     p1.data_group_id = p2.data_group_id and
     NVL(p1.end_date,TO_DATE('4712/12/31','YYYY/MM/DD')) >= p2.start_date and
     NVL(p1.end_date,TO_DATE('4712/12/31','YYYY/MM/DD')) <= NVL(p2.end_date,TO_DATE('4712/12/31','YYYY/MM/DD')) and
     p1.rowid <> p2.rowid;

    l_count  NUMBER(1);
 BEGIN
  OPEN c_priv_overlap(new_references.person_id,new_references.data_group_id);
  FETCH c_priv_overlap INTO l_count;
  CLOSE c_priv_overlap;

  IF l_count > 0 THEN
    FND_MESSAGE.SET_NAME('IGS','IGS_PE_PRIV_DT_OVERLAP');
    IGS_GE_MSG_STACK.ADD;
    APP_EXCEPTION.RAISE_EXCEPTION;
  END IF;
 END afterrowinsertupdate;



  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To check after DML
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsertUpdate (
          p_inserting => TRUE,
          p_updating  => FALSE,
          p_deleting  => FALSE
         );

    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      AfterRowInsertUpdate (
          p_inserting => FALSE,
          p_updating  => TRUE,
          p_deleting  => FALSE
         );
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PRIVACY_LEVEL_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DATA_GROUP_ID IN NUMBER,
       x_LVL IN NUMBER,
       x_ACTION IN VARCHAR2,
       x_WHOM IN VARCHAR2,
       x_REF_NOTES_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To insert row
Know limitations, enhancements or remarks : None
Change History
Who		When		What
kumma           03-JUN-2002     Passes NULL for LVL, bug # 2377971

(reverse chronological order - newest change first)
********************************************************/

    cursor C is select ROWID from IGS_PE_PRIV_LEVEL
             where                 PRIVACY_LEVEL_ID= X_PRIVACY_LEVEL_ID
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

Select IGS_PE_PRIV_LEVEL_S.NEXTVAL into X_PRIVACY_LEVEL_ID from Dual;

   Before_DML(
 	       p_action=>'INSERT',
 	       x_rowid=>X_ROWID,
 	       x_privacy_level_id=>X_PRIVACY_LEVEL_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_data_group=>X_DATA_GROUP,
 	       x_data_group_id=>X_DATA_GROUP_ID,
 	       x_action=>X_ACTION,
 	       x_whom=>X_WHOM,
  	       x_ref_notes_id=>X_REF_NOTES_ID,
	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
      IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 insert into IGS_PE_PRIV_LEVEL (
		PRIVACY_LEVEL_ID
		,PERSON_ID
		,DATA_GROUP
		,DATA_GROUP_ID
		,LVL
		,ACTION
		,WHOM
		,REF_NOTES_ID
		,START_DATE
		,END_DATE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.PRIVACY_LEVEL_ID
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.DATA_GROUP
	        ,NEW_REFERENCES.DATA_GROUP_ID
	        ,NULL
	        ,NEW_REFERENCES.ACTION
	        ,NEW_REFERENCES.WHOM
	        ,NEW_REFERENCES.REF_NOTES_ID
	        ,NEW_REFERENCES.START_DATE
	        ,NEW_REFERENCES.END_DATE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
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
       x_PRIVACY_LEVEL_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DATA_GROUP_ID IN NUMBER,
       x_LVL IN NUMBER,
       x_ACTION IN VARCHAR2,
       x_WHOM IN VARCHAR2,
       x_REF_NOTES_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE  ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To lock row
Know limitations, enhancements or remarks : None
Change History
Who		When		What
kumma           03-JUN-2002     Removed the comparison for LVL, Bug # 2377971
                                and also modified the cursor query to not to select LVL

(reverse chronological order - newest change first)
********************************************************/

   cursor c1 is select
      PERSON_ID
,      DATA_GROUP
,      DATA_GROUP_ID
,      ACTION
,      WHOM
,      REF_NOTES_ID
,      START_DATE
,      END_DATE
    from IGS_PE_PRIV_LEVEL
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
  AND (tlinfo.DATA_GROUP = X_DATA_GROUP)
  AND (tlinfo.DATA_GROUP_ID = X_DATA_GROUP_ID)
  AND (tlinfo.ACTION = X_ACTION)
  AND (tlinfo.WHOM = X_WHOM)
  AND ((tlinfo.REF_NOTES_ID = X_REF_NOTES_ID)
 	    OR ((tlinfo.REF_NOTES_ID is null)
		AND (X_REF_NOTES_ID is null)))
  AND (tlinfo.START_DATE = X_START_DATE)
  AND ((tlinfo.END_DATE = X_END_DATE)
 	    OR ((tlinfo.END_DATE is null)
		AND (X_END_DATE is null)))
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
       x_PRIVACY_LEVEL_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DATA_GROUP_ID IN NUMBER,
       x_LVL IN NUMBER,
       x_ACTION IN VARCHAR2,
       x_WHOM IN VARCHAR2,
       x_REF_NOTES_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To update row
Know limitations, enhancements or remarks : None
Change History
Who		When		What
kumma           03-JUN-2002     Removed the code to update LVL, Bug # 2377971

(reverse chronological order - newest change first)
********************************************************/

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
 	       x_privacy_level_id=>X_PRIVACY_LEVEL_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_data_group=>X_DATA_GROUP,
 	       x_data_group_id=>X_DATA_GROUP_ID,
 	       x_action=>X_ACTION,
 	       x_whom=>X_WHOM,
  	       x_ref_notes_id=>X_REF_NOTES_ID,
	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
    IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 update IGS_PE_PRIV_LEVEL set
      PERSON_ID =  NEW_REFERENCES.PERSON_ID,
      DATA_GROUP =  NEW_REFERENCES.DATA_GROUP,
      DATA_GROUP_ID =  NEW_REFERENCES.DATA_GROUP_ID,
      ACTION =  NEW_REFERENCES.ACTION,
      WHOM =  NEW_REFERENCES.WHOM,
      REF_NOTES_ID =  NEW_REFERENCES.REF_NOTES_ID,
      START_DATE =  NEW_REFERENCES.START_DATE,
      END_DATE =  NEW_REFERENCES.END_DATE,
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
       x_PRIVACY_LEVEL_ID IN OUT NOCOPY NUMBER,
       x_PERSON_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DATA_GROUP_ID IN NUMBER,
       x_LVL IN NUMBER,
       x_ACTION IN VARCHAR2,
       x_WHOM IN VARCHAR2,
       x_REF_NOTES_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 default 'R'
  ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To add row
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

    cursor c1 is select ROWID from IGS_PE_PRIV_LEVEL
             where     PRIVACY_LEVEL_ID= X_PRIVACY_LEVEL_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_PRIVACY_LEVEL_ID,
       X_PERSON_ID,
       X_DATA_GROUP,
       X_DATA_GROUP_ID,
       X_LVL,
       X_ACTION,
       X_WHOM,
       X_REF_NOTES_ID,
       X_START_DATE,
       X_END_DATE,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_PRIVACY_LEVEL_ID,
       X_PERSON_ID,
       X_DATA_GROUP,
       X_DATA_GROUP_ID,
       X_LVL,
       X_ACTION,
       X_WHOM,
       X_REF_NOTES_ID,
       X_START_DATE,
       X_END_DATE,
      X_MODE );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2,
  x_mode IN VARCHAR2
) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To Delete row
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
  IF (x_mode = 'S') THEN
    igs_sc_gen_001.set_ctx('R');
  END IF;
 delete from IGS_PE_PRIV_LEVEL
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
END igs_pe_priv_level_pkg;

/
