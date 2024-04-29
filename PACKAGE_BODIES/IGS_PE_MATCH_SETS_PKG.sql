--------------------------------------------------------
--  DDL for Package Body IGS_PE_MATCH_SETS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_MATCH_SETS_PKG" AS
/* $Header: IGSNI66B.pls 120.0 2005/06/01 20:07:51 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_pe_match_sets_all%RowType;
  new_references igs_pe_match_sets_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_source_type_id IN NUMBER DEFAULT NULL,
    x_match_set_name IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_PARTIAL_IF_NULL IN VARCHAR2 DEFAULT NULL,
    x_EXCLUDE_INACTIVE_IND IN VARCHAR2 DEFAULT 'N',
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    X_ORG_ID in NUMBER default NULL,
    x_primary_addr_flag IN VARCHAR2 DEFAULT NULL
  ) AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
  (reverse chronological order - newest change first)
***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_match_sets_all
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
    new_references.match_set_id := x_match_set_id;
    new_references.source_type_id := x_source_type_id;
    new_references.match_set_name := x_match_set_name;
    new_references.description := x_description;
    new_references.closed_ind := x_closed_ind;
    new_references.partial_if_null := x_partial_if_null;
    new_references.org_id := x_org_id;
    new_references.primary_addr_flag := x_primary_addr_flag;
    new_references.exclude_inactive_ind := x_exclude_inactive_ind;

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
  sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
  (reverse chronological order - newest change first)
***************************************************************/
  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'CLOSED_IND'  THEN
        new_references.closed_ind := column_value;
      ELSIF  UPPER(column_name) = 'PARTIAL_IF_NULL'  THEN
        new_references.closed_ind := column_value;

        NULL;
      END IF;



    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'CLOSED_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.closed_ind IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'PARTIAL_IF_NULL' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.partial_if_null IN ('Y', 'N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

  END Check_Constraints;

  FUNCTION Get_PK_For_Validation (
    x_match_set_id IN NUMBER
    ) RETURN BOOLEAN AS
/*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
  (reverse chronological order - newest change first)
***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_match_sets_all
      WHERE    match_set_id = x_match_set_id
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

  PROCEDURE GET_FK_IGS_PE_SRC_TYPES (
      X_source_type_id in number
      ) as
  /*************************************************************
  Created By :svisweas
  Date Created By :27-MAY-2000
  Purpose : To get FK from IGS_PE_SRC_TYPES
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svisweas	  27-MAY-2000     Added This procedure after corrections
  				              in the repository
  pkpatel     10-JUN-2003     Bug 2996726
                              Modified match_set_id to source_type_id
  (reverse chronological order - newest change first)
  ***************************************************************/
    cursor cur_rowid is
    select rowid
    from igs_pe_match_sets_all
    where source_type_id = x_source_type_id;

    lv_rowid cur_rowid%rowtype;

 begin
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_MTCH_SETS_SRC_TYP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

END GET_FK_IGS_PE_SRC_TYPES;

PROCEDURE GET_FK_IGS_PE_DUP_PAIRS (
      X_duplicate_pair_id in number
     ) as
  /*************************************************************
  Created By :svisweas
  Date Created By :27-MAY-2000
  Purpose : To get FK from IGS_PE_DUP_PAIRS
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  svisweas	  27-MAY-2000     Added This procedure after corrections
  				  in the repository
  (reverse chronological order - newest change first)
  ***************************************************************/
    cursor cur_rowid is
    select rowid
    from igs_pe_match_sets_all
    where match_set_id = x_duplicate_pair_id;

    lv_rowid cur_rowid%rowtype;

 begin
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PE_MTCH_SETS_DUP_PAIRS_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

END GET_FK_IGS_PE_DUP_PAIRS;


  PROCEDURE AfterRowInsert IS
  /*************************************************************
  Created By :sraj
  Date Created By :11-MAY-2000
  Purpose : To add the duplicate data elements for a match set
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  asbala          28-nov-2003     Removed data element 'SURNAME_5_CHAR'
  sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR Src_Type IS
   SELECT 'X' FROM IGS_PE_SRC_TYPES WHERE SOURCE_TYPE_ID = new_references.source_type_id AND SYSTEM_SOURCE_TYPE = 'MANUAL';

   CURSOR Dup_Data IS
   SELECT LOOKUP_CODE FROM IGS_LOOKUPS_VIEW WHERE LOOKUP_TYPE = 'DUPLICATE_DATA_ELEMENTS' AND ENABLED_FLAG = 'Y';

   lv_SrcType VARCHAR2(1);
   lv_RowId	  VARCHAR2(25);
   lv_Partial_Inc VARCHAR2(1);
   lv_Exact_Inc VARCHAR2(1);
   ln_Mtch_Set_Data_Id NUMBER(15);
  BEGIN
   OPEN Src_Type;
   FETCH Src_Type INTO lv_SrcType;
   IF Src_Type%FOUND THEN
     FOR Dup_Data_Rec IN Dup_Data LOOP
	   IF Dup_Data_Rec.Lookup_Code IN ('SURNAME', 'GIVEN_NAME',
	   	  		'GIVEN_NAME_1_CHAR', 'BIRTH_DT', 'SEX', 'PREF_ALTERNATE_ID') THEN
        IF Dup_Data_Rec.Lookup_Code IN ('SURNAME', 'GIVEN_NAME_1_CHAR') THEN
	      lv_Partial_Inc := 'Y';
	      lv_Exact_Inc := 'Y';
	    ELSE
	      lv_Partial_Inc := 'N';
	      lv_Exact_Inc := 'N';
        END IF;
	    lv_RowID := NULL;

	   Igs_Pe_Mtch_Set_Data_Pkg.INSERT_ROW (
       X_ROWID 	=> lv_RowId,
       x_MATCH_SET_DATA_ID => ln_Mtch_Set_Data_Id,
       x_MATCH_SET_ID => new_references.match_set_id,
       x_DATA_ELEMENT => Dup_Data_Rec.Lookup_Code,
       x_VALUE => NULL,
       x_EXACT_INCLUDE => lv_Exact_Inc,
       x_PARTIAL_INCLUDE => lv_Partial_Inc,
       x_DROP_IF_NULL => 'N',
       X_MODE  =>'R',
       x_org_id=>new_references.ORG_ID
      );
     END IF;
    END LOOP;
   ELSE
     FOR Dup_Data_Rec IN Dup_Data LOOP
	   IF Dup_Data_Rec.Lookup_Code IN ('SURNAME', 'GIVEN_NAME_1_CHAR') THEN
	     lv_Partial_Inc := 'Y';
	     lv_Exact_Inc := 'Y';
	   ELSE
	     lv_Partial_Inc := 'N';
	     lv_Exact_Inc := 'N';
       END IF;
	   lv_RowID := NULL;

	   Igs_Pe_Mtch_Set_Data_Pkg.INSERT_ROW (
       X_ROWID 	=> lv_RowId,
       x_MATCH_SET_DATA_ID => ln_Mtch_Set_Data_Id,
       x_MATCH_SET_ID => new_references.match_set_id,
       x_DATA_ELEMENT => Dup_Data_Rec.Lookup_Code,
       x_VALUE => NULL,
       x_EXACT_INCLUDE => lv_Exact_Inc,
       x_PARTIAL_INCLUDE => lv_Partial_Inc,
       x_DROP_IF_NULL => 'N',
      X_MODE  => 'R',
       x_org_id=>new_references.ORG_ID
      );
	 END LOOP;
   END IF;
  CLOSE Src_Type;
 END AfterRowInsert;

 PROCEDURE BeforeDelete IS
  /*************************************************************
  Created By :sraj
  Date Created By :11-MAY-2000
  Purpose : To delete the duplicate data elements when a match set is deleted
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
  (reverse chronological order - newest change first)
  ***************************************************************/


   CURSOR Dup_Data IS
   SELECT ROWID FROM IGS_PE_MTCH_SET_DATA WHERE MATCH_SET_ID = old_references.Match_Set_Id;
   lv_RowId VARCHAR2(25);
  BEGIN
      FOR Dup_Data_Rec IN Dup_Data LOOP
        Igs_Pe_Mtch_Set_Data_Pkg.DELETE_ROW (
        X_ROWID 	=> Dup_Data_Rec.ROWID );
     END LOOP;
 END BeforeDelete;


FUNCTION Get_UK1_For_Validation (
    x_match_set_name IN VARCHAR2
    )
   RETURN BOOLEAN
  /*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_match_sets_all
      WHERE    UPPER(match_set_name) = UPPER(x_match_set_name)
      AND ((l_rowid is null) or (rowid <> l_rowid))
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;

  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close cur_rowid;
 	RETURN(TRUE);
    ELSE
        Close cur_rowid;
        RETURN(FALSE);
    END IF;

  END Get_UK1_For_Validation;

PROCEDURE Check_Uniqueness AS
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
	IF Get_UK1_For_Validation (
		new_references.match_set_name
	) THEN
	        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
	        IGS_GE_MSG_STACK.ADD;
        	App_Exception.Raise_Exception;
	END IF;

  END Check_Uniqueness;



  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_match_set_id IN NUMBER DEFAULT NULL,
    x_source_type_id IN NUMBER DEFAULT NULL,
    x_match_set_name IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_partial_if_null IN VARCHAR2 DEFAULT NULL,
    x_exclude_inactive_ind IN VARCHAR2 DEFAULT 'N',
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_primary_addr_flag IN VARCHAR2 DEFAULT 'N',
    X_ORG_ID in NUMBER default NULL

  ) AS
  /*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
  (reverse chronological order - newest change first)
  asbala         21-JUL-03       Removed call to check_uniqueness from Validate_Insert and Validate_Update
                                 and made l_rowid := null at the end of before_dml
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_match_set_id,
      x_source_type_id,
      x_match_set_name,
      x_description,
      x_closed_ind,
      x_partial_if_null,
      x_exclude_inactive_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id,
      x_primary_addr_flag
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.match_set_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      BeforeDelete;
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.match_set_id)  THEN
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

    l_rowid := null;

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
   sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
  (reverse chronological order - newest change first)
  ***************************************************************/
  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsert;
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

   l_rowid := null;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_MATCH_SET_ID IN OUT NOCOPY NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_MATCH_SET_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_PARTIAL_IF_NULL IN VARCHAR2,
       x_EXCLUDE_INACTIVE_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER,
       x_primary_addr_flag IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sbaliga	 13-feb-2002	assigned igs_ge_gen_003.get_org_id to x_org_id
  			in call to before_dml as part of SWCR006 build.
   sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
  (reverse chronological order - newest change first)
  ***************************************************************/
    cursor C is select ROWID from igs_pe_match_sets_all
             where                 MATCH_SET_ID= X_MATCH_SET_ID
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

       SELECT igs_pe_match_sets_S.NEXTVAL
       INTO X_MATCH_SET_ID
       FROM DUAL;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_match_set_id=>X_MATCH_SET_ID,
 	       x_source_type_id=>X_SOURCE_TYPE_ID,
 	       x_match_set_name=>X_MATCH_SET_NAME,
 	       x_description=>X_DESCRIPTION,
 	       x_closed_ind=>X_CLOSED_IND,
 	       x_partial_if_null => X_PARTIAL_IF_NULL,
               x_EXCLUDE_INACTIVE_IND => x_EXCLUDE_INACTIVE_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_primary_addr_flag=>X_primary_addr_flag,
               x_org_id=>igs_ge_gen_003.get_org_id

 	       );
     insert into igs_pe_match_sets_all (
		MATCH_SET_ID
		,SOURCE_TYPE_ID
		,MATCH_SET_NAME
		,DESCRIPTION
		,CLOSED_IND
		,PARTIAL_IF_NULL
		,EXCLUDE_INACTIVE_IND
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,ORG_ID
		,primary_addr_flag

        ) values  (
	        NEW_REFERENCES.MATCH_SET_ID
	        ,NEW_REFERENCES.SOURCE_TYPE_ID
	        ,NEW_REFERENCES.MATCH_SET_NAME
	        ,NEW_REFERENCES.DESCRIPTION
	        ,NEW_REFERENCES.CLOSED_IND
	        ,NEW_REFERENCES.PARTIAL_IF_NULL
		,NEW_REFERENCES.EXCLUDE_INACTIVE_IND
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
                ,NEW_REFERENCES.ORG_ID
		,NEW_REFERENCES.primary_addr_flag

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
       x_MATCH_SET_ID IN NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_MATCH_SET_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_PARTIAL_IF_NULL IN VARCHAR2,
       x_primary_addr_flag IN VARCHAR2,
       x_exclude_inactive_ind IN VARCHAR2
 ) AS
  /*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
   sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
  (reverse chronological order - newest change first)
  ***************************************************************/
   cursor c1 is select
      SOURCE_TYPE_ID
,      MATCH_SET_NAME
,      DESCRIPTION
,      CLOSED_IND
, PARTIAL_IF_NULL
, primary_addr_flag
, exclude_inactive_ind
    from igs_pe_match_sets_all
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

if ( (  tlinfo.SOURCE_TYPE_ID = X_SOURCE_TYPE_ID)
  AND (tlinfo.MATCH_SET_NAME = X_MATCH_SET_NAME)
  AND ((tlinfo.DESCRIPTION = X_DESCRIPTION)
 	    OR ((tlinfo.DESCRIPTION is null)
		AND (X_DESCRIPTION is null)))
  AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
  AND (tlinfo.PARTIAL_IF_NULL = X_PARTIAL_IF_NULL)
  AND ((tlinfo.primary_addr_flag = X_primary_addr_flag)
  OR ((tlinfo.primary_addr_flag is null) and (X_primary_addr_flag is null)))
  AND ((tlinfo.exclude_inactive_ind = X_exclude_inactive_ind)
  OR ((tlinfo.exclude_inactive_ind is null) and (X_exclude_inactive_ind is null)))
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
       x_MATCH_SET_ID IN NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_MATCH_SET_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       x_PARTIAL_IF_NULL IN VARCHAR2,
       x_primary_addr_flag IN VARCHAR2,
       x_exclude_inactive_ind IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
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
 	       x_match_set_id=>X_MATCH_SET_ID,
 	       x_source_type_id=>X_SOURCE_TYPE_ID,
 	       x_match_set_name=>X_MATCH_SET_NAME,
 	       x_description=>X_DESCRIPTION,
 	       x_closed_ind=>X_CLOSED_IND,
      	       x_partial_if_null =>X_PARTIAL_IF_NULL,
	       x_exclude_inactive_ind =>x_exclude_inactive_ind,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_primary_addr_flag=>X_primary_addr_flag,
	       x_org_id=>igs_ge_gen_003.get_org_id
);
   update igs_pe_match_sets_all set
      SOURCE_TYPE_ID =  NEW_REFERENCES.SOURCE_TYPE_ID,
      MATCH_SET_NAME =  NEW_REFERENCES.MATCH_SET_NAME,
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      CLOSED_IND =  NEW_REFERENCES.CLOSED_IND,
      PARTIAL_IF_NULL = NEW_REFERENCES.PARTIAL_IF_NULL,
      primary_addr_flag = NEW_REFERENCES.primary_addr_flag,
      exclude_inactive_ind = NEW_REFERENCES.exclude_inactive_ind,
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
       x_MATCH_SET_ID IN OUT NOCOPY NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_MATCH_SET_NAME IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
       X_PARTIAL_IF_NULL  IN VARCHAR2,
       X_EXCLUDE_INACTIVE_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER,
       X_primary_addr_flag IN VARCHAR2
  ) AS
  /*************************************************************
  Created By :SVISWEAS
  Date Created By :11-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sraj		  17-MAY-2000     Added a column PARTIAL_IF_NULL to the table
  (reverse chronological order - newest change first)
  ***************************************************************/
    cursor c1 is select ROWID from igs_pe_match_sets_all
             where     MATCH_SET_ID= X_MATCH_SET_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_MATCH_SET_ID,
       X_SOURCE_TYPE_ID,
       X_MATCH_SET_NAME,
       X_DESCRIPTION,
       X_CLOSED_IND,
       X_PARTIAL_IF_NULL,
       X_EXCLUDE_INACTIVE_IND,
      X_MODE ,
      x_org_id,
      X_primary_addr_flag
);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_MATCH_SET_ID,
       X_SOURCE_TYPE_ID,
       X_MATCH_SET_NAME,
       X_DESCRIPTION,
       X_CLOSED_IND,
       X_PARTIAL_IF_NULL,
       X_primary_addr_flag,
       X_EXCLUDE_INACTIVE_IND,
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
 delete from igs_pe_match_sets_all
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_pe_match_sets_pkg;

/
