--------------------------------------------------------
--  DDL for Package Body IGS_PE_PRSID_GRP_MEM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PRSID_GRP_MEM_PKG" AS
/* $Header: IGSNI22B.pls 120.0 2005/06/01 21:38:36 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_pe_prsid_grp_mem_all%RowType;
  new_references igs_pe_prsid_grp_mem_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_group_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PRSID_GRP_MEM_ALL
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
    new_references.group_id := x_group_id;
    new_references.person_id := x_person_id;
    new_references.start_date := trunc(x_start_date);
    new_references.end_date := trunc(x_end_date);

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

  PROCEDURE BeforeRowInsertUpdateDelete1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

	v_message_name  varchar2(30);
  BEGIN
	-- Validate the insert
	IF p_inserting THEN
		IF IGS_PE_VAL_PIGM.idgp_val_pigm_iud (
				new_references.group_id,
				'INSERT',
				v_message_name) = FALSE THEN
			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the update
	IF p_updating THEN
		IF IGS_PE_VAL_PIGM.idgp_val_pigm_iud (
				new_references.group_id,
				'UPDATE',
				v_message_name) = FALSE THEN
			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
	END IF;
	-- Validate the delete
	IF p_deleting THEN
		IF IGS_PE_VAL_PIGM.idgp_val_pigm_iud (
				old_references.group_id,
				'DELETE',
				v_message_name) = FALSE THEN
			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdateDelete1;

  PROCEDURE BeforeInsertUpdate(p_inserting BOOLEAN , p_updating BOOLEAN) AS
  p_message_name VARCHAR2(30);
  BEGIN
   IF p_inserting = TRUE THEN
   -- asbala Bug 3671159: When members are inserted into a closed group, IGS_PE_PIG_CLOSED_NO_INSRT
   -- message is to be displayed.
    IF  NOT IGS_PE_PERSID_GROUP_PKG.val_persid_group(new_references.group_id,p_message_name) THEN
        FND_MSG_PUB.initialize;  -- Bug 3671159: Error msg displayed multiple times in Self Service. Hence,
                            -- clearing message stack.
	Fnd_Message.Set_Name('IGS', 'IGS_PE_PIG_CLOSED_NO_INSRT');
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END IF;
   ELSIF (p_updating = TRUE AND new_references.group_id <> old_references.group_id ) THEN
    IF  NOT IGS_PE_PERSID_GROUP_PKG.val_persid_group(new_references.group_id,p_message_name) THEN
        FND_MSG_PUB.initialize;  -- Bug 3671159: Error msg displayed multiple times in Self Service. Hence,
                            -- clearing message stack.
	Fnd_Message.Set_Name('IGS', p_message_name);
	IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END IF;
   END IF;
  END BeforeInsertUpdate;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

   IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) = 'GROUP_ID' then
     new_references.group_id  := IGS_GE_NUMBER.to_num(column_value);
     IF new_references.group_id < 1 OR new_references.group_id > 999999  Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
END IF;


 END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

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

        IF (((old_references.group_id = new_references.group_id)) OR
        ((new_references.group_id IS NULL))) THEN
      NULL;
    ELSE

         IF  NOT IGS_PE_PERSID_GROUP_PKG.Get_PK_For_Validation (
         new_references.group_id  ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;


  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_group_id IN NUMBER,
    x_person_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_prsid_grp_mem_all
      WHERE    group_id = x_group_id
      AND      person_id = x_person_id
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

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_prsid_grp_mem_all
      WHERE    person_id = x_person_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PIGM_PE_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Person;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_group_id IN NUMBER DEFAULT NULL,
    x_person_id IN NUMBER DEFAULT NULL,
    x_start_date IN DATE DEFAULT NULL,
    x_end_date IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  sjalasut        June 7, 2002    bug 2381248
  (reverse chronological order - newest change first)
  ***************************************************************/
  CURSOR c_get_birth_date is SELECT date_of_birth FROM HZ_PERSON_PROFILES WHERE PARTY_ID = x_person_id
  AND EFFECTIVE_END_DATE IS NULL;
  l_birth_date HZ_PERSON_PROFILES.date_of_birth%TYPE;

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_group_id,
      x_person_id,
      x_start_date,
      x_end_date,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_org_id
    );
    -- The following code has been addedas a part of the bug fix 2381248
     IF(p_action IN ('INSERT','UPDATE')) THEN
       OPEN c_get_birth_date; FETCH c_get_birth_date INTO l_birth_date; CLOSE c_get_birth_date;
       IF l_birth_date IS NOT NULL THEN
        IF x_start_date < l_birth_date THEN
         FND_MESSAGE.SET_NAME ('IGS','IGS_AD_STRT_DT_LESS_BIRTH_DT');
         IGS_GE_MSG_STACK.ADD;
         APP_EXCEPTION.RAISE_EXCEPTION;
	END IF;
       END IF;
     END IF;
     IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
       BeforeInsertUpdate(TRUE,FALSE);
      IF  Get_PK_For_Validation (
          new_references.group_id ,
          new_references.person_id) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
      Check_Parent_Existance; -- if procedure present
     ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       BeforeInsertUpdate(FALSE,TRUE);
       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present
     ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.
      NULL;
     ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
         new_references.group_id ,
          new_references.person_id) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints; -- if procedure present

ELSIF (p_action = 'VALIDATE_DELETE') THEN
     NULL;
 END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
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
       x_GROUP_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 ,
      X_ORG_ID in NUMBER
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PE_PRSID_GRP_MEM_ALL
             where                 GROUP_ID= X_GROUP_ID
            and PERSON_ID = X_PERSON_ID;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
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
         X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
    X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
    if (X_REQUEST_ID =  -1) then
      X_REQUEST_ID := NULL;
      X_PROGRAM_ID := NULL;
      X_PROGRAM_APPLICATION_ID := NULL;
      X_PROGRAM_UPDATE_DATE := NULL;
    else
      X_PROGRAM_UPDATE_DATE := SYSDATE;
    end if;
       else
        FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_group_id=>X_GROUP_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_org_id=>igs_ge_gen_003.get_org_id
	     );
     insert into IGS_PE_PRSID_GRP_MEM_ALL (
		GROUP_ID
		,PERSON_ID
		,START_DATE
		,END_DATE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,REQUEST_ID
		,PROGRAM_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE
		,ORG_ID
        ) values  (
	        NEW_REFERENCES.GROUP_ID
	        ,NEW_REFERENCES.PERSON_ID
	        ,NEW_REFERENCES.START_DATE
	        ,NEW_REFERENCES.END_DATE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,X_REQUEST_ID
		,X_PROGRAM_ID
		,X_PROGRAM_APPLICATION_ID
		,X_PROGRAM_UPDATE_DATE
		,NEW_REFERENCES.ORG_ID
);
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
end INSERT_ROW;


 procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_GROUP_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE
       ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      START_DATE,
      END_DATE
    from IGS_PE_PRSID_GRP_MEM_ALL
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
if (
           ((tlinfo.START_DATE = X_START_DATE) OR ((tlinfo.START_DATE is null) AND (X_START_DATE is null))) AND
	   ((tlinfo.END_DATE = X_END_DATE)     OR ((tlinfo.END_DATE is null)   AND (X_END_DATE is null)))
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
       x_GROUP_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
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
 		p_action=>'UPDATE',
 		x_rowid=>X_ROWID,
 	       x_group_id=>X_GROUP_ID,
 	       x_person_id=>X_PERSON_ID,
 	       x_start_date=>X_START_DATE,
 	       x_end_date=>X_END_DATE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN
	     );

  if (X_MODE = 'R') then
   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;
   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;
   if (X_REQUEST_ID = -1) then
    X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;
    X_PROGRAM_ID := OLD_REFERENCES.PROGRAM_ID;
    X_PROGRAM_APPLICATION_ID := OLD_REFERENCES.PROGRAM_APPLICATION_ID;
    X_PROGRAM_UPDATE_DATE := OLD_REFERENCES.PROGRAM_UPDATE_DATE;
   else
    X_PROGRAM_UPDATE_DATE := SYSDATE;
   end if;
  end if;


   update IGS_PE_PRSID_GRP_MEM_ALL set
        START_DATE =  NEW_REFERENCES.START_DATE,
        END_DATE =  NEW_REFERENCES.END_DATE,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	REQUEST_ID = X_REQUEST_ID,
	PROGRAM_ID = X_PROGRAM_ID,
	PROGRAM_APPLICATION_ID = PROGRAM_APPLICATION_ID,
	PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE
     where ROWID = X_ROWID;

	if (sql%notfound) then
		raise no_data_found;
	end if;

 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID
	);
end UPDATE_ROW;

 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_GROUP_ID IN NUMBER,
       x_PERSON_ID IN NUMBER,
       x_START_DATE IN DATE,
       x_END_DATE IN DATE,
      X_MODE in VARCHAR2 ,
      X_ORG_ID in NUMBER
  ) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PE_PRSID_GRP_MEM_ALL
             where     GROUP_ID= X_GROUP_ID
            and PERSON_ID = X_PERSON_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_GROUP_ID,
       X_PERSON_ID,
       X_START_DATE,
       X_END_DATE,
      X_MODE,
      X_ORG_ID );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_GROUP_ID,
       X_PERSON_ID,
       X_START_DATE,
       X_END_DATE,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj            2000/05/05      the table structure has been changed
  (reverse chronological order - newest change first)
  ***************************************************************/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 delete from IGS_PE_PRSID_GRP_MEM_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_pe_prsid_grp_mem_pkg;

/
