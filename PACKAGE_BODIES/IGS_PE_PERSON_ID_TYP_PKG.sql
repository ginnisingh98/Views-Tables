--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERSON_ID_TYP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERSON_ID_TYP_PKG" AS
  /* $Header: IGSNI25B.pls 120.1 2006/01/25 09:20:33 skpandey noship $ */

------------------------------------------------------------------
-- Change History
--
-- Bug ID : 2000408
-- who      when          what
-- CDCRUZ   Sep 24,2002   New Col added for
--                        Person DLD / FORMAT_MASK
------------------------------------------------------------------

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To create TBH Body
Know limitations, enhancements or remarks : None
Change History
Who		When		What
sraj		17-MAY-2000	Two columns have been added to this table.
(reverse chronological order - newest change first)
********************************************************/

  l_rowid VARCHAR2(25);
  old_references IGS_PE_PERSON_ID_TYP%RowType;
  new_references IGS_PE_PERSON_ID_TYP%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2  ,
    x_person_id_type IN VARCHAR2  ,
    x_description IN VARCHAR2  ,
    x_s_person_id_type IN VARCHAR2  ,
    x_institution_cd IN VARCHAR2  ,
    x_preferred_ind IN VARCHAR2  ,
    x_unique_ind IN VARCHAR2  ,
    X_FORMAT_MASK IN VARCHAR2 ,
    X_REGION_IND IN  VARCHAR2,
    x_creation_date IN DATE  ,
    x_created_by IN NUMBER  ,
    x_last_update_date IN DATE  ,
    x_last_updated_by IN NUMBER  ,
    x_last_update_login IN NUMBER ,
    x_closed_ind IN VARCHAR2
  ) AS

  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two columns have been added to this table.
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PE_PERSON_ID_TYP
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
    new_references.person_id_type := x_person_id_type;
    new_references.description := x_description;
    new_references.s_person_id_type := x_s_person_id_type;
    new_references.institution_cd := x_institution_cd;
    new_references.preferred_ind := x_preferred_ind;
    new_references.unique_ind := x_unique_ind;
    new_references.format_mask := x_format_mask ;
    new_references.region_ind := x_region_ind;
    new_references.closed_ind := x_closed_ind;

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
    p_inserting IN BOOLEAN ,
    p_updating IN BOOLEAN ,
    p_deleting IN BOOLEAN
    ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : Before row insert and update
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

v_message_name  varchar2(30);
  BEGIN
	-- Validate IGS_PE_PERSON ID TYPE.
	-- IGS_OR_INSTITUTION closed indicator.
	IF new_references.institution_cd IS NOT NULL AND
		(NVL(old_references.institution_cd, 'NULL') <> new_references.institution_cd) THEN
		IF IGS_EN_VAL_PIT.enrp_val_pit_inst_cd (
				new_references.institution_cd,
				v_message_name) = FALSE THEN
			 Fnd_Message.Set_Name('IGS', v_message_name);
			 IGS_GE_MSG_STACK.ADD;
                         App_Exception.Raise_Exception;
		END IF;
	END IF;
  END BeforeRowInsertUpdate1;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  ,
		 Column_Value IN VARCHAR2   ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 17-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   sraj		17-MAY-2000	     Two columns have been added to this table.
   pkpatel  19-JUL-2002      Bug No: 2384824
                             Removed the upper check for Institution Code
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'PREFERRED_IND'  THEN
        new_references.preferred_ind := column_value;
      ELSIF  UPPER(column_name) = 'UNIQUE_IND'  THEN
        new_references.unique_ind := column_value;
      ELSIF  UPPER(column_name) = 'REGION_IND'  THEN
        new_references.region_ind := column_value;
      ELSIF  UPPER(column_name) = 'PERSON_ID_TYPE'  THEN
        new_references.person_id_type := column_value;
       ELSIF  UPPER(column_name) = 'S_PERSON_ID_TYPE'  THEN
        new_references.s_person_id_type := column_value;
      ELSIF  UPPER(column_name) = 'INSTITUTION_CD'  THEN
        new_references.institution_cd := column_value;
        NULL;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PREFERRED_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.preferred_ind IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'UNIQUE_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.unique_ind IN ('N', 'Y'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


     IF Upper(Column_Name) = 'REGION_IND' OR
     	Column_Name IS NULL THEN
       IF NOT (new_references.region_ind IN ('N', 'Y'))  THEN
          Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
     IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
       END IF;
     END IF;

    IF  UPPER(Column_Name) = 'PERSON_ID_TYPE' OR
      		Column_Name IS NULL THEN
        IF new_references.PERSON_ID_TYPE <> UPPER(new_references.person_id_type) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;

      IF  UPPER(Column_Name) = 'S_PERSON_ID_TYPE' OR
      		Column_Name IS NULL THEN
        IF new_references.S_PERSON_ID_TYPE <> UPPER(new_references.s_person_id_type) THEN
		Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
		App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To check parent existance
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

  BEGIN
    IF (((old_references.institution_cd = new_references.institution_cd)) OR
        ((new_references.institution_cd IS NULL))) THEN
      NULL;
    ELSE

      IF  NOT IGS_OR_INSTITUTION_PKG.Get_PK_For_Validation (
         new_references.institution_cd) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;
    IF (((old_references.s_person_id_type = new_references.s_person_id_type)) OR
        ((new_references.s_person_id_type IS NULL))) THEN
      NULL;
    ELSE
       IF  NOT IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation (
         'PERSON_ID_TYPE',new_references.s_person_id_type) THEN
         Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
         IGS_GE_MSG_STACK.ADD;
              App_Exception.Raise_Exception;
       END IF;

    END IF;
  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_person_id_type IN VARCHAR2
    )  RETURN BOOLEAN AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To enforce primary key validations
Know limitations, enhancements or remarks : None
Change History
Who		  When		    What
pkpatel   19-JUL-2002   Bug No: 2384824
                        Modified the logic to lock the parent record only while the child records are not present for that person_id_type
						If the childs are present then the person_id_type can not be deleted since the child alternate person I can only
						be end dated. Hence no need to lock the records.
(reverse chronological order - newest change first)
********************************************************/
       --Cursor to check the existence of parent
      CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERSON_ID_TYP
      WHERE    person_id_type = x_person_id_type;

      lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
       CLOSE cur_rowid;
       RETURN (TRUE);
    ELSE
       CLOSE cur_rowid;
       RETURN (FALSE);
    END IF;
  END Get_PK_For_Validation;

  FUNCTION Get_PID_Type_Validation (
    x_person_id_type IN VARCHAR2
    )  RETURN BOOLEAN AS

/******************************************************
Created By : ssaleem
Date Created By : 17-SEP-2004
Purpose : To enforce primary key validations with closed indicator
Know limitations, enhancements or remarks : This function is created
                 after adding closed indicator in IGS_PE_PERSON_ID_TYP
Change History
Who		  When		    What
(reverse chronological order - newest change first)
********************************************************/
       --Cursor to check the existence of parent
      CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERSON_ID_TYP
      WHERE    person_id_type = x_person_id_type AND
               CLOSED_IND = 'N';

      lv_rowid cur_rowid%ROWTYPE;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
       CLOSE cur_rowid;
       RETURN (TRUE);
    ELSE
       CLOSE cur_rowid;
       RETURN (FALSE);
    END IF;
  END Get_PID_Type_Validation;



  PROCEDURE GET_FK_IGS_OR_INSTITUTION (
    x_institution_cd IN VARCHAR2
    ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To enforce foriegn key validations
Know limitations, enhancements or remarks : None
Change History
Who		When		What


(reverse chronological order - newest change first)
********************************************************/

   CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PE_PERSON_ID_TYP
      WHERE    institution_cd = x_institution_cd ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PIT_INS_FK');
       IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_OR_INSTITUTION;

  PROCEDURE GET_FK_IGS_LOOKUPS_VIEW (
    x_s_person_id_type IN VARCHAR2
    ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : for lookup views
Know limitations, enhancements or remarks : None
Change History
Who		When		What
skpandey        24-JAN-2006     Bug#3686538: Stubbed as a part of query optimization
(reverse chronological order - newest change first)
********************************************************/
  BEGIN
	NULL;
  END GET_FK_IGS_LOOKUPS_VIEW;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2  ,
    x_person_id_type IN VARCHAR2  ,
    x_description IN VARCHAR2  ,
    x_s_person_id_type IN VARCHAR2  ,
    x_institution_cd IN VARCHAR2  ,
    x_preferred_ind IN VARCHAR2  ,
    x_unique_ind IN VARCHAR2  ,
    X_FORMAT_MASK IN VARCHAR2 ,
    X_REGION_IND IN  VARCHAR2,
    x_closed_ind IN VARCHAR2,
    x_creation_date IN DATE  ,
    x_created_by IN NUMBER  ,
    x_last_update_date IN DATE  ,
    x_last_updated_by IN NUMBER  ,
    x_last_update_login IN NUMBER
  ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 17-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two columns have been added to this table.
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_person_id_type,
      x_description,
      x_s_person_id_type,
      x_institution_cd,
      x_preferred_ind,
      x_unique_ind,
      x_format_mask,
      x_region_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_closed_ind
    );

     IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
     BeforeRowInsertUpdate1 ( p_inserting => TRUE,
                              p_updating => FALSE ,
    p_deleting => FALSE);
      IF  Get_PK_For_Validation (
          new_references.person_id_type ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
      Check_Parent_Existance; -- if procedure present

 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.
       BeforeRowInsertUpdate1 ( p_updating => TRUE,
                                p_inserting => FALSE ,
                                p_deleting => FALSE);
       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present

 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.person_id_type ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present

 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
       Check_Constraints; -- if procedure present
 END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS

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
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    END IF;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_PERSON_ID_TYPE IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_PREFERRED_IND IN VARCHAR2,
       x_UNIQUE_IND IN VARCHAR2,
       X_FORMAT_MASK IN VARCHAR2 ,
       X_REGION_IND IN  VARCHAR2,
      X_MODE in VARCHAR2,
      X_CLOSED_IND IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 17-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two columns have been added to this table.
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PE_PERSON_ID_TYP
             where                 PERSON_ID_TYPE= X_PERSON_ID_TYPE
;
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
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_person_id_type=>X_PERSON_ID_TYPE,
 	       x_description=>X_DESCRIPTION,
 	       x_s_person_id_type=>X_S_PERSON_ID_TYPE,
 	       x_institution_cd=>X_INSTITUTION_CD,
 	       x_preferred_ind=>X_PREFERRED_IND,
 	       x_unique_ind=>X_UNIQUE_IND,
	       x_format_mask=>X_format_mask,
               x_region_ind => X_REGION_IND,
               x_closed_ind=> X_CLOSED_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN
	       );
     insert into IGS_PE_PERSON_ID_TYP (
		PERSON_ID_TYPE
		,DESCRIPTION
		,S_PERSON_ID_TYPE
		,INSTITUTION_CD
		,PREFERRED_IND
		,UNIQUE_IND
		,FORMAT_MASK
          ,REGION_IND
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CLOSED_IND
        ) values  (
	        NEW_REFERENCES.PERSON_ID_TYPE
	        ,NEW_REFERENCES.DESCRIPTION
	        ,NEW_REFERENCES.S_PERSON_ID_TYPE
	        ,NEW_REFERENCES.INSTITUTION_CD
	        ,NEW_REFERENCES.PREFERRED_IND
	        ,NEW_REFERENCES.UNIQUE_IND
	        ,NEW_REFERENCES.FORMAT_MASK
             ,NEW_REFERENCES.REGION_IND
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,NEW_REFERENCES.CLOSED_IND
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
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_PERSON_ID_TYPE IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_PREFERRED_IND IN VARCHAR2,
       x_UNIQUE_IND IN VARCHAR2 ,
       X_FORMAT_MASK IN VARCHAR2,
       X_REGION_IND IN  VARCHAR2
       ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 17-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two columns have been added to this table.
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      DESCRIPTION
,      S_PERSON_ID_TYPE
,      INSTITUTION_CD
,      PREFERRED_IND
,      UNIQUE_IND
,      FORMAT_MASK
,     REGION_IND
    from IGS_PE_PERSON_ID_TYP
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
if (  (tlinfo.DESCRIPTION = X_DESCRIPTION)
  AND ((tlinfo.S_PERSON_ID_TYPE = X_S_PERSON_ID_TYPE)
 	    OR ((tlinfo.S_PERSON_ID_TYPE is null)
		AND (X_S_PERSON_ID_TYPE is null)))
  AND ((tlinfo.INSTITUTION_CD = X_INSTITUTION_CD)
 	    OR ((tlinfo.INSTITUTION_CD is null)
		AND (X_INSTITUTION_CD is null)))
  AND ((tlinfo.PREFERRED_IND = X_PREFERRED_IND)
 	    OR ((tlinfo.PREFERRED_IND is null)
		AND (X_PREFERRED_IND is null)))

  AND ((tlinfo.FORMAT_MASK = X_FORMAT_MASK)
 	    OR ((tlinfo.FORMAT_MASK is null)
		AND (X_FORMAT_MASK is null)))

  AND ((tlinfo.UNIQUE_IND = X_UNIQUE_IND)
 	    OR ((tlinfo.UNIQUE_IND is null)
		AND (X_UNIQUE_IND is null)))

   AND ((tlinfo.REGION_IND = X_REGION_IND)
         OR((tlinfo.REGION_IND IS NULL)
         AND (X_REGION_IND IS NULL)))

   )then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

 PROCEDURE UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_PERSON_ID_TYPE IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_PREFERRED_IND IN VARCHAR2,
       x_UNIQUE_IND IN VARCHAR2,
      X_FORMAT_MASK IN VARCHAR2 ,
       X_REGION_IND IN  VARCHAR2,
      X_MODE in VARCHAR2,
      X_CLOSED_IND IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 17-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two columns have been added to this table.
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
 	       x_person_id_type=>X_PERSON_ID_TYPE,
 	       x_description=>X_DESCRIPTION,
 	       x_s_person_id_type=>X_S_PERSON_ID_TYPE,
 	       x_institution_cd=>X_INSTITUTION_CD,
 	       x_preferred_ind=>X_PREFERRED_IND,
 	       x_unique_ind=>X_UNIQUE_IND,
	       x_format_mask=>X_FORMAT_MASK,
               x_region_ind => X_REGION_IND,
               x_closed_ind => X_CLOSED_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN
	       );
   update IGS_PE_PERSON_ID_TYP set
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      S_PERSON_ID_TYPE =  NEW_REFERENCES.S_PERSON_ID_TYPE,
      INSTITUTION_CD =  NEW_REFERENCES.INSTITUTION_CD,
      PREFERRED_IND =  NEW_REFERENCES.PREFERRED_IND,
      UNIQUE_IND =  NEW_REFERENCES.UNIQUE_IND,
      FORMAT_MASK = NEW_REFERENCES.FORMAT_MASK,
      REGION_IND =  NEW_REFERENCES.REGION_IND,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
        CLOSED_IND = NEW_REFERENCES.CLOSED_IND
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
       x_PERSON_ID_TYPE IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_S_PERSON_ID_TYPE IN VARCHAR2,
       x_INSTITUTION_CD IN VARCHAR2,
       x_PREFERRED_IND IN VARCHAR2,
       x_UNIQUE_IND IN VARCHAR2,
       X_FORMAT_MASK IN VARCHAR2 ,
       X_REGION_IND IN  VARCHAR2,
       X_MODE in VARCHAR2,
       X_CLOSED_IND IN VARCHAR2
  ) AS
  /*************************************************************
  Created By : sraj
  Date Created By : 17-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		17-MAY-2000	Two columns have been added to this table.
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PE_PERSON_ID_TYP
             where     PERSON_ID_TYPE= X_PERSON_ID_TYPE
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_PERSON_ID_TYPE,
       X_DESCRIPTION,
       X_S_PERSON_ID_TYPE,
       X_INSTITUTION_CD,
       X_PREFERRED_IND,
       X_UNIQUE_IND,
       X_FORMAT_MASK,
       X_REGION_IND,
      X_MODE,
      X_CLOSED_IND);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_PERSON_ID_TYPE,
       X_DESCRIPTION,
       X_S_PERSON_ID_TYPE,
       X_INSTITUTION_CD,
       X_PREFERRED_IND,
       X_UNIQUE_IND,
       X_FORMAT_MASK,
       X_REGION_IND ,
      X_MODE,
      X_CLOSED_IND);
end ADD_ROW;

END igs_pe_person_id_typ_pkg;

/
