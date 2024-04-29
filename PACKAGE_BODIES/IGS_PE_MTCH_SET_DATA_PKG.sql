--------------------------------------------------------
--  DDL for Package Body IGS_PE_MTCH_SET_DATA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_MTCH_SET_DATA_PKG" AS
/* $Header: IGSNI67B.pls 115.7 2002/11/29 01:29:01 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_pe_mtch_set_data_all%RowType;
  new_references igs_pe_mtch_set_data_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_match_set_data_id IN NUMBER DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_data_element IN VARCHAR2 DEFAULT NULL,
    x_value IN VARCHAR2 DEFAULT NULL,
    x_exact_include IN VARCHAR2 DEFAULT NULL,
    x_partial_include IN VARCHAR2 DEFAULT NULL,
    x_drop_if_null IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER
  ) AS

/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two Columns have added to this table.
  (reverse chronological order - newest change first)
***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_mtch_set_data_all
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
    new_references.match_set_data_id := x_match_set_data_id;
    new_references.match_set_id := x_match_set_id;
    new_references.data_element := x_data_element;
    new_references.value := x_value;
    new_references.exact_include := x_exact_include;
    new_references.partial_include := x_partial_include;
    new_references.drop_if_null := x_drop_if_null;
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
  sraj		17-MAY-2000	Two Columns have added to this table.
  (reverse chronological order - newest change first)
***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'EXACT_INCLUDE'  THEN
        new_references.exact_include := column_value;
      ELSIF  UPPER(column_name) = 'PARTIAL_INCLUDE'  THEN
        new_references.partial_include := column_value;
        NULL;
      ELSIF  UPPER(column_name) = 'DROP_IF_NULL'  THEN
        new_references.drop_if_null := column_value;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'EXACT_INCLUDE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.exact_include IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PARTIAL_INCLUDE' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.partial_include IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'DROP_IF_NULL' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.drop_if_null IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

  END Check_Constraints;

  FUNCTION Get_PK_For_Validation (
    x_match_set_data_id IN NUMBER
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
      FROM     igs_pe_mtch_set_data_all
      WHERE    match_set_data_id = x_match_set_data_id
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
    x_match_set_data_id IN NUMBER DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_data_element IN VARCHAR2 DEFAULT NULL,
    x_value IN VARCHAR2 DEFAULT NULL,
    x_exact_include IN VARCHAR2 DEFAULT NULL,
    x_partial_include IN VARCHAR2 DEFAULT NULL,
    x_drop_if_null IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER default NULL
  ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two Columns have added to this table.
  (reverse chronological order - newest change first)
***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_match_set_data_id,
      x_match_set_id,
      x_data_element,
      x_value,
      x_exact_include,
      x_partial_include,
      x_drop_if_null,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.match_set_data_id)  THEN
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
    		new_references.match_set_data_id)  THEN
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
       x_MATCH_SET_DATA_ID IN OUT NOCOPY NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_EXACT_INCLUDE IN VARCHAR2,
       x_PARTIAL_INCLUDE IN VARCHAR2,
       x_DROP_IF_NULL IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two Columns have added to this table.
  (reverse chronological order - newest change first)
***************************************************************/

    cursor C is select ROWID from igs_pe_mtch_set_data_all
             where MATCH_SET_DATA_ID= X_MATCH_SET_DATA_ID;

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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

       	SELECT IGS_PE_MTCH_SET_DATA_S.NEXTVAL
       	INTO X_MATCH_SET_DATA_ID
       	FROM DUAL;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_match_set_data_id=>X_MATCH_SET_DATA_ID,
 	       x_match_set_id=>X_MATCH_SET_ID,
 	       x_data_element=>X_DATA_ELEMENT,
 	       x_value=>X_VALUE,
 	       x_exact_include=>X_EXACT_INCLUDE,
 	       x_partial_include=>X_PARTIAL_INCLUDE,
 	       x_drop_if_null => X_DROP_IF_NULL,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
 	       x_org_id=>igs_ge_gen_003.get_org_id
);
     insert into igs_pe_mtch_set_data_all (
		MATCH_SET_DATA_ID
		,MATCH_SET_ID
		,DATA_ELEMENT
		,VALUE
		,EXACT_INCLUDE
		,PARTIAL_INCLUDE
		,DROP_IF_NULL
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN,
		 ORG_ID
        ) values  (
	        NEW_REFERENCES.MATCH_SET_DATA_ID
	        ,NEW_REFERENCES.MATCH_SET_ID
	        ,NEW_REFERENCES.DATA_ELEMENT
	        ,NEW_REFERENCES.VALUE
	        ,NEW_REFERENCES.EXACT_INCLUDE
	        ,NEW_REFERENCES.PARTIAL_INCLUDE
	        ,NEW_REFERENCES.DROP_IF_NULL
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN,
              NEW_REFERENCES.ORG_ID
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
       x_MATCH_SET_DATA_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_EXACT_INCLUDE IN VARCHAR2,
       x_PARTIAL_INCLUDE IN VARCHAR2,
       x_DROP_IF_NULL IN VARCHAR2
) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two Columns have added to this table.
  (reverse chronological order - newest change first)
***************************************************************/

   cursor c1 is select
      MATCH_SET_ID
,      DATA_ELEMENT
,      VALUE
,      EXACT_INCLUDE
,      PARTIAL_INCLUDE
,	 DROP_IF_NULL
    from igs_pe_mtch_set_data_all
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
if (tlinfo.MATCH_SET_ID = X_MATCH_SET_ID)
  AND (tlinfo.DATA_ELEMENT = X_DATA_ELEMENT)
 	    OR (tlinfo.DATA_ELEMENT is null)
		AND (X_DATA_ELEMENT is null)
  AND (tlinfo.VALUE = X_VALUE)
 	    OR (tlinfo.VALUE is null)
		AND (X_VALUE is null)
  AND (tlinfo.EXACT_INCLUDE = X_EXACT_INCLUDE)
  AND (tlinfo.PARTIAL_INCLUDE = X_PARTIAL_INCLUDE)
  AND (tlinfo.DROP_IF_NULL = X_DROP_IF_NULL)
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
       x_MATCH_SET_DATA_ID IN NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_EXACT_INCLUDE IN VARCHAR2,
       x_PARTIAL_INCLUDE IN VARCHAR2,
       x_DROP_IF_NULL IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two Columns have added to this table.
  (reverse chronological order - newest change first)
***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
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
 	       x_match_set_data_id=>X_MATCH_SET_DATA_ID,
 	       x_match_set_id=>X_MATCH_SET_ID,
 	       x_data_element=>X_DATA_ELEMENT,
 	       x_value=>X_VALUE,
 	       x_exact_include=>X_EXACT_INCLUDE,
 	       x_partial_include=>X_PARTIAL_INCLUDE,
 	       x_drop_if_null=>X_DROP_IF_NULL,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN
);
   update igs_pe_mtch_set_data_all set
      MATCH_SET_ID =  NEW_REFERENCES.MATCH_SET_ID,
      DATA_ELEMENT =  NEW_REFERENCES.DATA_ELEMENT,
      VALUE =  NEW_REFERENCES.VALUE,
      EXACT_INCLUDE =  NEW_REFERENCES.EXACT_INCLUDE,
      PARTIAL_INCLUDE =  NEW_REFERENCES.PARTIAL_INCLUDE,
      DROP_IF_NULL =  NEW_REFERENCES.DROP_IF_NULL,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
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
       x_MATCH_SET_DATA_ID IN OUT NOCOPY NUMBER,
       x_MATCH_SET_ID IN NUMBER,
       x_DATA_ELEMENT IN VARCHAR2,
       x_VALUE IN VARCHAR2,
       x_EXACT_INCLUDE IN VARCHAR2,
       x_PARTIAL_INCLUDE IN VARCHAR2,
       x_DROP_IF_NULL IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
       X_ORG_ID in NUMBER
  ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two Columns have added to this table.
  (reverse chronological order - newest change first)
***************************************************************/

    cursor c1 is select ROWID from igs_pe_mtch_set_data_all
             where     MATCH_SET_DATA_ID= X_MATCH_SET_DATA_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_MATCH_SET_DATA_ID,
       X_MATCH_SET_ID,
       X_DATA_ELEMENT,
       X_VALUE,
       X_EXACT_INCLUDE,
       X_PARTIAL_INCLUDE,
       X_DROP_IF_NULL,
      X_MODE ,
      x_org_id
);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_MATCH_SET_DATA_ID,
       X_MATCH_SET_ID,
       X_DATA_ELEMENT,
       X_VALUE,
       X_EXACT_INCLUDE,
       X_PARTIAL_INCLUDE,
       X_DROP_IF_NULL,
      X_MODE
);
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
 delete from igs_pe_mtch_set_data_all
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_pe_mtch_set_data_pkg;

/
