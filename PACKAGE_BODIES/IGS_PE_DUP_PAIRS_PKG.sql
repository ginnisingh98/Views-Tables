--------------------------------------------------------
--  DDL for Package Body IGS_PE_DUP_PAIRS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_DUP_PAIRS_PKG" AS
/* $Header: IGSNI68B.pls 115.9 2002/11/29 01:29:17 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PE_DUP_PAIRS_ALL%RowType;
  new_references IGS_PE_DUP_PAIRS_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_duplicate_pair_id IN NUMBER DEFAULT NULL,
    x_batch_id IN NUMBER DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_actual_person_id IN NUMBER DEFAULT NULL,
    x_duplicate_person_id IN NUMBER DEFAULT NULL,
    x_obsolete_id IN NUMBER DEFAULT NULL,
    x_match_category IN VARCHAR2 DEFAULT NULL,
    x_dup_status IN VARCHAR2 DEFAULT NULL,
    x_address_type IN VARCHAR2 DEFAULT NULL,
    x_location_id IN NUMBER DEFAULT NULL,
    x_person_id_type IN VARCHAR2 DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :SVISWEAS

  Date Created By :11-MAY-2000

  Purpose :

  Know limitations, enhancements or remarks

  Change History

  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_DUP_PAIRS_ALL
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
    new_references.duplicate_pair_id := x_duplicate_pair_id;
    new_references.batch_id := x_batch_id;
    new_references.match_set_id := x_match_set_id;
    new_references.actual_person_id := x_actual_person_id;
    new_references.duplicate_person_id := x_duplicate_person_id;
    new_references.obsolete_id := x_obsolete_id;
    new_references.match_category := x_match_category;
    new_references.dup_status := x_dup_status;
    new_references.address_type := x_address_type;
    new_references.location_id := x_location_id;
    new_references.person_id_type := x_person_id_type;
    new_references.org_id := x_org_id;
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
  /*************************************************************
  Created By :SVISWEAS

  Date Created By :11-MAY-2000

  Purpose :

  Know limitations, enhancements or remarks

  Change History

  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'MATCH_CATEGORY'  THEN
        new_references.match_category := column_value;
        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'MATCH_CATEGORY' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.match_category IN ('M', 'P'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  FUNCTION Get_PK_For_Validation (
    x_duplicate_pair_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :SVISWEAS

  Date Created By :11-MAY-2000

  Purpose :

  Know limitations, enhancements or remarks

  Change History

  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_DUP_PAIRS_ALL
      WHERE    duplicate_pair_id = x_duplicate_pair_id
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_duplicate_pair_id IN NUMBER DEFAULT NULL,
    x_batch_id IN NUMBER DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_actual_person_id IN NUMBER DEFAULT NULL,
    x_duplicate_person_id IN NUMBER DEFAULT NULL,
    x_obsolete_id IN NUMBER DEFAULT NULL,
    x_match_category IN VARCHAR2 DEFAULT NULL,
    x_dup_status IN VARCHAR2 DEFAULT NULL,
    x_address_type IN VARCHAR2 DEFAULT NULL,
    x_location_id IN NUMBER DEFAULT NULL,
    x_person_id_type IN VARCHAR2 DEFAULT NULL,
    X_ORG_ID in NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :SVISWEAS

  Date Created By :11-MAY-2000

  Purpose :

  Know limitations, enhancements or remarks

  Change History

  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_duplicate_pair_id,
      x_batch_id,
      x_match_set_id,
      x_actual_person_id,
      x_duplicate_person_id,
      x_obsolete_id,
      x_match_category,
      x_dup_status,
      x_address_type,
      x_location_id,
      x_person_id_type,
      x_org_id,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.duplicate_pair_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.duplicate_pair_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :SVISWEAS

  Date Created By :11-MAY-2000

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
       x_DUPLICATE_PAIR_ID IN OUT NOCOPY NUMBER,
       x_BATCH_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_ACTUAL_PERSON_ID IN NUMBER,
       x_DUPLICATE_PERSON_ID IN NUMBER,
       x_OBSOLETE_ID IN NUMBER,
       x_MATCH_CATEGORY IN VARCHAR2,
       x_DUP_STATUS IN VARCHAR2,
       x_ADDRESS_TYPE IN VARCHAR2,
       x_LOCATION_ID IN NUMBER,
       x_PERSON_ID_TYPE IN VARCHAR2,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :SVISWEAS

  Date Created By :11-MAY-2000

  Purpose :

  Know limitations, enhancements or remarks

  Change History

  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PE_DUP_PAIRS_ALL
             where DUPLICATE_PAIR_ID= X_DUPLICATE_PAIR_ID
;
     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
     X_REQUEST_ID NUMBER;
     X_PROGRAM_ID NUMBER;
     X_PROGRAM_APPLICATION_ID NUMBER;
     X_PROGRAM_UPDATE_DATE DATE;
 begin
     X_LAST_UPDATE_DATE := SYSDATE;
     if (X_MODE = 'I') then
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
        FND_MESSAGE.SET_NAME('FND','SYSTEM-INVALID ARGS');
        IGS_GE_MSG_STACK.ADD;
        app_exception.raise_exception;
     end if;

       SELECT IGS_PE_DUP_PAIRS_S.NEXTVAL
       INTO X_DUPLICATE_PAIR_ID
       FROM DUAL;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_duplicate_pair_id=>X_DUPLICATE_PAIR_ID,
 	       x_batch_id=>X_BATCH_ID,
 	       x_match_set_id=>X_MATCH_SET_ID,
 	       x_actual_person_id=>X_ACTUAL_PERSON_ID,
 	       x_duplicate_person_id=>X_DUPLICATE_PERSON_ID,
 	       x_obsolete_id=>X_OBSOLETE_ID,
 	       x_match_category=>X_MATCH_CATEGORY,
 	       x_dup_status=>X_DUP_STATUS,
 	       x_address_type=>X_ADDRESS_TYPE,
 	       x_location_id=>X_LOCATION_ID,
 	       x_person_id_type=>X_PERSON_ID_TYPE,
         x_org_id => igs_ge_gen_003.get_org_id,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_PE_DUP_PAIRS_ALL (
		DUPLICATE_PAIR_ID
		,BATCH_ID
		,MATCH_SET_ID
		,ACTUAL_PERSON_ID
		,DUPLICATE_PERSON_ID
		,OBSOLETE_ID
		,MATCH_CATEGORY
		,DUP_STATUS
		,ADDRESS_TYPE
		,LOCATION_ID
		,PERSON_ID_TYPE
    ,ORG_ID
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,REQUEST_ID
		,PROGRAM_ID
		,PROGRAM_APPLICATION_ID
		,PROGRAM_UPDATE_DATE
        ) values  (
	        NEW_REFERENCES.DUPLICATE_PAIR_ID
	        ,NEW_REFERENCES.BATCH_ID
	        ,NEW_REFERENCES.MATCH_SET_ID
	        ,NEW_REFERENCES.ACTUAL_PERSON_ID
	        ,NEW_REFERENCES.DUPLICATE_PERSON_ID
	        ,NEW_REFERENCES.OBSOLETE_ID
	        ,NEW_REFERENCES.MATCH_CATEGORY
	        ,NEW_REFERENCES.DUP_STATUS
	        ,NEW_REFERENCES.ADDRESS_TYPE
                ,NEW_REFERENCES.LOCATION_ID
	        ,NEW_REFERENCES.PERSON_ID_TYPE
          ,NEW_REFERENCES.ORG_ID
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,X_REQUEST_ID
		,X_PROGRAM_ID
		,X_PROGRAM_APPLICATION_ID
		,X_PROGRAM_UPDATE_DATE
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
       x_DUPLICATE_PAIR_ID IN NUMBER,
       x_BATCH_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_ACTUAL_PERSON_ID IN NUMBER,
       x_DUPLICATE_PERSON_ID IN NUMBER,
       x_OBSOLETE_ID IN NUMBER,
       x_MATCH_CATEGORY IN VARCHAR2,
       x_DUP_STATUS IN VARCHAR2,
       x_ADDRESS_TYPE IN VARCHAR2,
       x_LOCATION_ID IN NUMBER,
       x_PERSON_ID_TYPE IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :SVISWEAS

  Date Created By :11-MAY-2000

  Purpose :

  Know limitations, enhancements or remarks

  Change History

  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      BATCH_ID
,      MATCH_SET_ID
,      ACTUAL_PERSON_ID
,      DUPLICATE_PERSON_ID
,      OBSOLETE_ID
,      MATCH_CATEGORY
,      DUP_STATUS
,      ADDRESS_TYPE
,      LOCATION_ID
,      PERSON_ID_TYPE
    from IGS_PE_DUP_PAIRS_ALL
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
if (tlinfo.BATCH_ID = X_BATCH_ID)
  AND (tlinfo.MATCH_SET_ID = X_MATCH_SET_ID)
  AND (tlinfo.ACTUAL_PERSON_ID = X_ACTUAL_PERSON_ID)
  AND (tlinfo.DUPLICATE_PERSON_ID = X_DUPLICATE_PERSON_ID)
  AND (tlinfo.OBSOLETE_ID = X_OBSOLETE_ID)
 	    OR (tlinfo.OBSOLETE_ID is null)
		AND (X_OBSOLETE_ID is null)
  AND (tlinfo.MATCH_CATEGORY = X_MATCH_CATEGORY)
  AND (tlinfo.DUP_STATUS = X_DUP_STATUS)
  AND (tlinfo.ADDRESS_TYPE = X_ADDRESS_TYPE)
 	    OR (tlinfo.ADDRESS_TYPE is null)
		AND (X_ADDRESS_TYPE is null)
  AND (tlinfo.LOCATION_ID = X_LOCATION_ID)
 	    OR (tlinfo.LOCATION_ID is null)
		AND (X_LOCATION_ID is null)
  AND (tlinfo.PERSON_ID_TYPE = X_PERSON_ID_TYPE)
 	    OR (tlinfo.PERSON_ID_TYPE is null)
		AND (X_PERSON_ID_TYPE is null)
   then
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
       x_DUPLICATE_PAIR_ID IN NUMBER,
       x_BATCH_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_ACTUAL_PERSON_ID IN NUMBER,
       x_DUPLICATE_PERSON_ID IN NUMBER,
       x_OBSOLETE_ID IN NUMBER,
       x_MATCH_CATEGORY IN VARCHAR2,
       x_DUP_STATUS IN VARCHAR2,
       x_ADDRESS_TYPE IN VARCHAR2,
       x_LOCATION_ID IN NUMBER,
       x_PERSON_ID_TYPE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :SVISWEAS

  Date Created By :11-MAY-2000

  Purpose :

  Know limitations, enhancements or remarks

  Change History

  Who             When            What

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
 	       x_duplicate_pair_id=>X_DUPLICATE_PAIR_ID,
 	       x_batch_id=>X_BATCH_ID,
 	       x_match_set_id=>X_MATCH_SET_ID,
 	       x_actual_person_id=>X_ACTUAL_PERSON_ID,
 	       x_duplicate_person_id=>X_DUPLICATE_PERSON_ID,
 	       x_obsolete_id=>X_OBSOLETE_ID,
 	       x_match_category=>X_MATCH_CATEGORY,
 	       x_dup_status=>X_DUP_STATUS,
 	       x_address_type=>X_ADDRESS_TYPE,
 	       x_location_id=>X_LOCATION_ID,
 	       x_person_id_type=>X_PERSON_ID_TYPE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);

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


   update IGS_PE_DUP_PAIRS_ALL set
      BATCH_ID =  NEW_REFERENCES.BATCH_ID,
      MATCH_SET_ID =  NEW_REFERENCES.MATCH_SET_ID,
      ACTUAL_PERSON_ID =  NEW_REFERENCES.ACTUAL_PERSON_ID,
      DUPLICATE_PERSON_ID =  NEW_REFERENCES.DUPLICATE_PERSON_ID,
      OBSOLETE_ID =  NEW_REFERENCES.OBSOLETE_ID,
      MATCH_CATEGORY =  NEW_REFERENCES.MATCH_CATEGORY,
      DUP_STATUS =  NEW_REFERENCES.DUP_STATUS,
      ADDRESS_TYPE =  NEW_REFERENCES.ADDRESS_TYPE,
      LOCATION_ID =  NEW_REFERENCES.LOCATION_ID,
      PERSON_ID_TYPE =  NEW_REFERENCES.PERSON_ID_TYPE,
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
       x_DUPLICATE_PAIR_ID IN OUT NOCOPY NUMBER,
       x_BATCH_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_ACTUAL_PERSON_ID IN NUMBER,
       x_DUPLICATE_PERSON_ID IN NUMBER,
       x_OBSOLETE_ID IN NUMBER,
       x_MATCH_CATEGORY IN VARCHAR2,
       x_DUP_STATUS IN VARCHAR2,
       x_ADDRESS_TYPE IN VARCHAR2,
       x_LOCATION_ID IN NUMBER,
       x_PERSON_ID_TYPE IN VARCHAR2,
       X_ORG_ID in NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :SVISWEAS

  Date Created By :11-MAY-2000

  Purpose :

  Know limitations, enhancements or remarks

  Change History

  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PE_DUP_PAIRS_ALL
             where  DUPLICATE_PAIR_ID= X_DUPLICATE_PAIR_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_DUPLICATE_PAIR_ID,
       X_BATCH_ID,
       X_MATCH_SET_ID,
       X_ACTUAL_PERSON_ID,
       X_DUPLICATE_PERSON_ID,
       X_OBSOLETE_ID,
       X_MATCH_CATEGORY,
       X_DUP_STATUS,
       X_ADDRESS_TYPE,
       X_LOCATION_ID,
       X_PERSON_ID_TYPE,
       X_ORG_ID,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_DUPLICATE_PAIR_ID,
       X_BATCH_ID,
       X_MATCH_SET_ID,
       X_ACTUAL_PERSON_ID,
       X_DUPLICATE_PERSON_ID,
       X_OBSOLETE_ID,
       X_MATCH_CATEGORY,
       X_DUP_STATUS,
       X_ADDRESS_TYPE,
       X_LOCATION_ID,
       X_PERSON_ID_TYPE,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By :SVISWEAS

  Date Created By :11-MAY-2000

  Purpose :

  Know limitations, enhancements or remarks

  Change History

  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 delete from IGS_PE_DUP_PAIRS_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_pe_dup_pairs_pkg;

/
