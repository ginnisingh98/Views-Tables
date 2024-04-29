--------------------------------------------------------
--  DDL for Package Body IGS_AD_SOURCE_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SOURCE_CAT_PKG" AS
/* $Header: IGSAI71B.pls 115.22 2003/07/01 10:24:41 pbondugu ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_source_cat_all%RowType;
  new_references igs_ad_source_cat_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
		x_org_id IN NUMBER DEFAULT NULL,
    x_src_cat_id IN NUMBER DEFAULT NULL,
    x_source_type_id IN NUMBER DEFAULT NULL,
    x_category_name IN VARCHAR2 DEFAULT NULL,
    x_mandatory_ind IN VARCHAR2 DEFAULT NULL,
    x_include_ind IN VARCHAR2 DEFAULT NULL,
    x_discrepancy_rule_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_ss_mandatory_ind IN VARCHAR2 DEFAULT NULL,
    x_ss_ind IN   VARCHAR2    DEFAULT NULL,
    x_display_sequence IN NUMBER DEFAULT NULL,
    x_DETAIL_LEVEL_IND IN VARCHAR2 DEFAULT NULL,
    x_AD_TAB_NAME  IN VARCHAR2 DEFAULT NULL,
    x_INT_TAB_NAME  IN VARCHAR2 DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
pkpatel      18-JUN-2001       Modified to add the processing for 3 new ADDED columns DETAIL_LEVEL_IND,AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_SOURCE_CAT_ALL
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
    new_references.org_id := x_org_id;
    new_references.src_cat_id := x_src_cat_id;
    new_references.source_type_id := x_source_type_id;
    new_references.category_name := x_category_name;
    new_references.mandatory_ind := x_mandatory_ind;
    new_references.include_ind := x_include_ind;
    new_references.discrepancy_rule_cd := x_discrepancy_rule_cd;
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
    new_references.ss_mandatory_ind := x_ss_mandatory_ind;
    new_references.ss_ind := x_ss_ind;
    new_references.display_sequence := x_display_sequence;
    new_references.DETAIL_LEVEL_IND := x_DETAIL_LEVEL_IND;
    new_references.ad_tab_name := x_ad_tab_name;
    new_references.int_tab_name := x_int_tab_name;

  END Set_Column_Values;

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
pkpatel      18-JUN-2001       Modified to add the processing for 3 new ADDED columns DETAIL_LEVEL_IND,AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'INCLUDE_IND'  THEN
        new_references.include_ind := column_value;
      ELSIF  UPPER(column_name) = 'MANDATORY_IND'  THEN
        new_references.mandatory_ind := column_value;
        ----Removed the validations for SS_IND,DISPLAY_SEQUENCE
      ELSIF UPPER(column_name) = 'DETAIL_LEVEL_IND' THEN
        new_references.detail_level_ind := column_value;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'INCLUDE_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.include_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'MANDATORY_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.mandatory_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'DETAIL_LEVEL_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.detail_level_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


END Check_Constraints;

  PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
   Begin
     	IF Get_Uk_For_Validation (
    		new_references.source_type_id
    		,new_references.category_name
    		) THEN
 	  Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
	  IGS_GE_MSG_STACK.ADD;
	  app_exception.raise_exception;
    	END IF;
   END Check_Uniqueness;



  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.discrepancy_rule_cd = new_references.discrepancy_rule_cd)) OR
        ((new_references.discrepancy_rule_cd IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_lookups_view_Pkg.Get_PK_For_Validation (
			'DISCREPANCY_RULE',
        		new_references.discrepancy_rule_cd
        )  THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.source_type_id = new_references.source_type_id)) OR
        ((new_references.source_type_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Pe_Src_Types_Pkg.Get_PK_For_Validation (
        		new_references.source_type_id
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_src_cat_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_source_cat_all
      WHERE    src_cat_id = x_src_cat_id
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
    x_source_type_id IN NUMBER,
    x_category_name VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_source_cat_all
      WHERE    source_type_id = x_source_type_id
      AND      category_name = x_category_name and      ((l_rowid is null) or (rowid <> l_rowid))

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


  PROCEDURE Get_FK_Igs_Pe_Src_Types (
    x_source_type_id IN NUMBER
    ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_source_cat_all
      WHERE    source_type_id = x_source_type_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ASRC_PST_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Pe_Src_Types;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
		x_org_id IN NUMBER DEFAULT NULL,
    x_src_cat_id IN NUMBER DEFAULT NULL,
    x_source_type_id IN NUMBER DEFAULT NULL,
    x_category_name IN VARCHAR2 DEFAULT NULL,
    x_mandatory_ind IN VARCHAR2 DEFAULT NULL,
    x_include_ind IN VARCHAR2 DEFAULT NULL,
    x_discrepancy_rule_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_ss_mandatory_ind IN VARCHAR2 DEFAULT NULL,
    x_ss_ind IN VARCHAR2 DEFAULT NULL,
    x_display_sequence IN NUMBER DEFAULT NULL,
    x_detail_level_ind IN VARCHAR2 DEFAULT NULL,
    x_ad_tab_name IN VARCHAR2 DEFAULT NULL,
    x_int_tab_name IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
pkpatel      18-JUN-2001       Modified to add the processing for 3 new ADDED columns DETAIL_LEVEL_IND,AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
			x_org_id,
      x_src_cat_id,
      x_source_type_id,
      x_category_name,
      x_mandatory_ind,
      x_include_ind,
      x_discrepancy_rule_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_ss_mandatory_ind,
      x_ss_ind,
      x_display_sequence,
      x_detail_level_ind,
      x_ad_tab_name,
      x_int_tab_name
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.src_cat_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      before_delete(
              X_ROWID=>	x_rowid
                   );
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.src_cat_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Uniqueness;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action           IN     VARCHAR2,
    x_rowid            IN     VARCHAR2,
    x_SRC_CAT_ID       IN OUT NOCOPY NUMBER,
    x_CATEGORY_NAME    IN     VARCHAR2
  ) IS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
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
      after_insert(
        x_SRC_CAT_ID       =>x_SRC_CAT_ID ,
        x_CATEGORY_NAME    =>x_CATEGORY_NAME
                  );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to After Delete.
      Null;
    END IF;

  l_rowid:=NULL;
  END After_DML;

 procedure INSERT_ROW (
       x_ROWID in out NOCOPY VARCHAR2,
       x_ORG_ID IN NUMBER,
       x_SRC_CAT_ID IN OUT NOCOPY NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_INCLUDE_IND IN VARCHAR2,
       x_DISCREPANCY_RULE_CD IN VARCHAR2,
       x_MODE in VARCHAR2 default 'R',
       x_SS_MANDATORY_IND IN VARCHAR2,
       x_SS_IND IN VARCHAR2,
       x_DISPLAY_SEQUENCE IN NUMBER,
       x_detail_level_ind IN VARCHAR2 DEFAULT NULL,
       x_ad_tab_name IN VARCHAR2 DEFAULT NULL,
       x_int_tab_name IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
pkpatel      18-JUN-2001       Modified to add the processing for 3 new ADDED columns DETAIL_LEVEL_IND,AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_SOURCE_CAT_ALL
             where                 SRC_CAT_ID= X_SRC_CAT_ID;

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 BEGIN
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

   X_SRC_CAT_ID := -1;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
		x_org_id => igs_ge_gen_003.get_org_id,
 	       x_src_cat_id=>X_SRC_CAT_ID,
 	       x_source_type_id=>X_SOURCE_TYPE_ID,
 	       x_category_name=>X_CATEGORY_NAME,
 	       x_mandatory_ind=>X_MANDATORY_IND,
 	       x_include_ind=>X_INCLUDE_IND,
 	       x_discrepancy_rule_cd=>X_DISCREPANCY_RULE_CD,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_ss_mandatory_ind=>X_SS_MANDATORY_IND,
	       x_ss_ind=>X_SS_IND,
	       x_display_sequence=>X_display_sequence,
	       x_detail_level_ind => NVL(X_DETAIL_LEVEL_IND,'N'),
	       x_ad_tab_name => X_AD_TAB_NAME,
	       x_int_tab_name => X_INT_TAB_NAME
              );
     insert into IGS_AD_SOURCE_CAT_ALL (
		ORG_ID,
		SRC_CAT_ID
		,SOURCE_TYPE_ID
		,CATEGORY_NAME
		,MANDATORY_IND
		,INCLUDE_IND
		,DISCREPANCY_RULE_CD
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN,
		SS_MANDATORY_IND
		,SS_IND
		,DISPLAY_SEQUENCE
		,DETAIL_LEVEL_IND
		,AD_TAB_NAME
		,INT_TAB_NAME
        ) values
         (
	        NEW_REFERENCES.ORG_ID,
	        IGS_AD_SRC_CAT_S.NEXTVAL
	        ,NEW_REFERENCES.SOURCE_TYPE_ID
	        ,NEW_REFERENCES.CATEGORY_NAME
	        ,NEW_REFERENCES.MANDATORY_IND
	        ,NEW_REFERENCES.INCLUDE_IND
	        ,NEW_REFERENCES.DISCREPANCY_RULE_CD
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,NULL
		,NULL
		,NULL
		,NEW_REFERENCES.DETAIL_LEVEL_IND
		,NEW_REFERENCES.AD_TAB_NAME
		,NEW_REFERENCES.INT_TAB_NAME
) RETURNING SRC_CAT_ID INTO X_SRC_CAT_ID;
		open c;
		 fetch c into X_ROWID;
 		if (c%notfound) then
		close c;
 	     raise no_data_found;
		end if;
 		close c;
    After_DML (
		p_action => 'INSERT' ,
		x_rowid => X_ROWID   ,
		x_src_cat_id => X_SRC_CAT_ID ,
		x_category_name => NEW_REFERENCES.CATEGORY_NAME );

end INSERT_ROW;


procedure LOCK_ROW (
      X_ROWID in  VARCHAR2,
       x_SRC_CAT_ID IN NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_INCLUDE_IND IN VARCHAR2,
       x_DISCREPANCY_RULE_CD IN VARCHAR2,
       x_ss_mandatory_ind IN VARCHAR2,
       x_ss_ind IN VARCHAR2,
       x_display_sequence IN NUMBER,
       x_detail_level_ind IN VARCHAR2 DEFAULT NULL,
       x_ad_tab_name  IN VARCHAR2 DEFAULT NULL,
       x_int_tab_name IN VARCHAR2 DEFAULT NULL
         ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
pkpatel      18-JUN-2001       Modified to add the processing for 3 new ADDED columns DETAIL_LEVEL_IND,AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is
   	select	SOURCE_TYPE_ID, CATEGORY_NAME, MANDATORY_IND, INCLUDE_IND, DISCREPANCY_RULE_CD,
   	SS_IND,DISPLAY_SEQUENCE,DETAIL_LEVEL_IND,AD_TAB_NAME,INT_TAB_NAME
   	  from IGS_AD_SOURCE_CAT_ALL
   	 where ROWID = X_ROWID
   	   for update nowait;
     tlinfo c1%rowtype;
BEGIN
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
   ----Removed the check  for SS_IND,DISPLAY_SEQUENCE,SS_MANDATORY_IND ( pbondugu  Bug #3032535)
if (
         ((tlinfo.MANDATORY_IND = X_MANDATORY_IND)
   	    OR ((tlinfo.MANDATORY_IND is null)
		AND (X_MANDATORY_IND is null)))
  AND (tlinfo.INCLUDE_IND = X_INCLUDE_IND)
  AND (tlinfo.DISCREPANCY_RULE_CD = X_DISCREPANCY_RULE_CD)
  AND ((tlinfo.DETAIL_LEVEL_IND = X_DETAIL_LEVEL_IND)
   	    OR ((tlinfo.DETAIL_LEVEL_IND is null)
		AND (X_DETAIL_LEVEL_IND is null)))
  AND ((tlinfo.AD_TAB_NAME = X_AD_TAB_NAME)
   	    OR ((tlinfo.AD_TAB_NAME is null)
		AND (X_AD_TAB_NAME is null)))
  AND ((tlinfo.INT_TAB_NAME = X_INT_TAB_NAME)
   	    OR ((tlinfo.INT_TAB_NAME is null)
		AND (X_INT_TAB_NAME is null)))
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
       x_SRC_CAT_ID IN NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_INCLUDE_IND IN VARCHAR2,
       x_DISCREPANCY_RULE_CD IN VARCHAR2,
      x_ss_mandatory_ind IN VARCHAR2,
      x_SS_IND IN VARCHAR2,
      x_DISPLAY_SEQUENCE IN NUMBER ,
      x_DETAIL_LEVEL_IND IN VARCHAR2 DEFAULT NULL,
      x_AD_TAB_NAME IN VARCHAR2 DEFAULT NULL,
      x_INT_TAB_NAME IN VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel      18-JUN-2001       Modified to add the processing for 3 new ADDED columns DETAIL_LEVEL_IND,AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 BEGIN
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
 	       x_src_cat_id=>X_SRC_CAT_ID,
 	       x_source_type_id=>X_SOURCE_TYPE_ID,
 	       x_category_name=>X_CATEGORY_NAME,
 	       x_mandatory_ind=>X_MANDATORY_IND,
 	       x_include_ind=>X_INCLUDE_IND,
 	       x_discrepancy_rule_cd=>X_DISCREPANCY_RULE_CD,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_ss_mandatory_ind=>X_SS_MANDATORY_IND,
	       x_ss_ind=>X_SS_IND,
	       x_display_sequence=>X_DISPLAY_SEQUENCE,
	       x_detail_level_ind=> X_DETAIL_LEVEL_IND,
	       x_ad_tab_name => X_AD_TAB_NAME,
	       x_int_tab_name => X_INT_TAB_NAME
	       );
   update IGS_AD_SOURCE_CAT_ALL set
        MANDATORY_IND =  NEW_REFERENCES.MANDATORY_IND,
        INCLUDE_IND =  NEW_REFERENCES.INCLUDE_IND,
        DISCREPANCY_RULE_CD =  NEW_REFERENCES.DISCREPANCY_RULE_CD,
	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	SS_MANDATORY_IND = NULL,
	SS_IND = NULL,
	DISPLAY_SEQUENCE = NULL,
	DETAIL_LEVEL_IND = NEW_REFERENCES.DETAIL_LEVEL_IND,
	AD_TAB_NAME = NEW_REFERENCES.AD_TAB_NAME,
	INT_TAB_NAME = NEW_REFERENCES.INT_TAB_NAME
	  where ROWID = X_ROWID;
	if (sql%notfound) then
		raise no_data_found;
	end if;

 After_DML (
	p_action => 'UPDATE' ,
	x_rowid => X_ROWID ,
	x_src_cat_id => NEW_REFERENCES.SRC_CAT_ID ,
	x_category_name => NEW_REFERENCES.CATEGORY_NAME
	);
end UPDATE_ROW;
 procedure ADD_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
			x_ORG_ID IN NUMBER,
       x_SRC_CAT_ID IN OUT NOCOPY NUMBER,
       x_SOURCE_TYPE_ID IN NUMBER,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_INCLUDE_IND IN VARCHAR2,
       x_DISCREPANCY_RULE_CD IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R',
      x_ss_mandatory_ind IN VARCHAR2,
      x_SS_IND IN VARCHAR2,
      x_DISPLAY_SEQUENCE IN NUMBER,
      x_DETAIL_LEVEL_IND IN VARCHAR2 DEFAULT NULL,
      x_AD_TAB_NAME IN VARCHAR2 DEFAULT NULL,
      x_INT_TAB_NAME IN VARCHAR2 DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel      18-JUN-2001       Modified to add the processing for 3 new ADDED columns DETAIL_LEVEL_IND,AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_SOURCE_CAT_ALL
             where     SRC_CAT_ID= X_SRC_CAT_ID
;
BEGIN
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
			x_ORG_ID,
       X_SRC_CAT_ID,
       X_SOURCE_TYPE_ID,
       X_CATEGORY_NAME,
       X_MANDATORY_IND,
       X_INCLUDE_IND,
       X_DISCREPANCY_RULE_CD,
      X_MODE,
      X_SS_MANDATORY_IND,
      X_SS_IND,
      X_DISPLAY_SEQUENCE ,
      X_DETAIL_LEVEL_IND,
      X_AD_TAB_NAME,
      X_INT_TAB_NAME
               );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_SRC_CAT_ID,
       X_SOURCE_TYPE_ID,
       X_CATEGORY_NAME,
       X_MANDATORY_IND,
       X_INCLUDE_IND,
       X_DISCREPANCY_RULE_CD,
      X_SS_MANDATORY_IND,
      X_SS_IND,
      X_DISPLAY_SEQUENCE,
      X_DETAIL_LEVEL_IND,
      X_AD_TAB_NAME,
      X_INT_TAB_NAME,
      X_MODE
 );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/
BEGIN

Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 delete from IGS_AD_SOURCE_CAT_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID,
 x_src_cat_id => NEW_REFERENCES.SRC_CAT_ID ,
 x_category_name => NEW_REFERENCES.CATEGORY_NAME
);
end DELETE_ROW;

procedure AFTER_INSERT(
   x_SRC_CAT_ID       IN OUT NOCOPY NUMBER,
   x_CATEGORY_NAME    IN     VARCHAR2
) AS
/*************************************************************
  Created By : ssomani
  Date Created On : 23-Oct-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
pkpatel       18-JUN-2001      DLD: Modelling and Forecasting-SDQ
                               Added logic to populate IGS_AD_DSCP_ATTR table
  (reverse chronological order - newest change first)
***************************************************************/
 l_rowid_ins        VARCHAR2(25);

 l_rowid_sysdiscrepancy_ins  VARCHAR2(25);
 l_discrepancy_attr_id       igs_ad_dscp_attr.discrepancy_attr_id%TYPE;

--Inserting records corresponding to CATEGORY_NAME into IGS_AD_DSCP_ATTR reading from IGS_AD_SYSDSCP_ATTR
--cursor c_attr is select category_name,attribute_name from IGS_AD_SYSDSCP_ATTR
--where   category_name=x_CATEGORY_NAME;

 CURSOR  c_sysdiscrepancy_attr_cur IS
SELECT a.lookup_code
FROM   igs_lookup_values a
       ,igs_lookup_values b
WHERE  b.lookup_code = 'PERSON' -- applicable only for person details
AND    b.lookup_code = x_category_name
AND    b.lookup_type = 'IMP_CATEGORIES'
AND    NVL(b.closed_ind,'N') = 'N'
AND    a.lookup_type = 'IGS_PE_DTL_ATTR_DISCRP_RULE'
AND    NVL(a.closed_ind,'N') = 'N';

BEGIN

FOR c_sysdiscrepancy_attr_rec IN c_sysdiscrepancy_attr_cur LOOP
  igs_ad_dscp_attr_pkg.insert_row(
        X_ROWID                =>l_rowid_sysdiscrepancy_ins,
        X_DISCREPANCY_ATTR_ID  =>l_discrepancy_attr_id,
        X_SRC_CAT_ID           =>x_src_cat_id,
        X_ATTRIBUTE_NAME       =>c_sysdiscrepancy_attr_rec.lookup_code,
        X_DISCREPANCY_RULE_CD  =>'I', -- To make the default DISCREPANCY RULE as 'I' i.e. 'Updating Existing Values With Imported Values'
        X_MODE                 =>'R');
END LOOP;
END after_insert;

procedure BEFORE_DELETE (
  X_ROWID in VARCHAR2
) AS
/*************************************************************
  Created By : ssomani
  Date Created On : 23-Oct-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
pkpatel       18-JUN-2001    DLD: Modelling and Forecasting
                             Added logic to delete records from IGS_AD_DSCP_ATTR table
  (reverse chronological order - newest change first)
  ***************************************************************/
 --Deleting records from child table IGS_AD_DSCP_ATTR using foriegn key SRC_CAT_ID
 CURSOR  c_sysdiscrepancy_attr_del_cur IS
 SELECT  ROWID
 FROM    igs_ad_dscp_attr
 WHERE   src_cat_id  =    (SELECT  src_cat_id
   			   FROM    igs_ad_source_cat_all
   			   WHERE   ROWID = X_ROWID);

BEGIN

OPEN c_sysdiscrepancy_attr_del_cur;
  LOOP
    FETCH c_sysdiscrepancy_attr_del_cur into l_rowid;
    EXIT  WHEN c_sysdiscrepancy_attr_del_cur%NOTFOUND;
    igs_ad_dscp_attr_pkg.delete_row(l_rowid);
  END LOOP;

  IF c_sysdiscrepancy_attr_del_cur%ISOPEN THEN
     CLOSE c_sysdiscrepancy_attr_del_cur;
  END IF;

END before_delete;

END igs_ad_source_cat_pkg;

/
