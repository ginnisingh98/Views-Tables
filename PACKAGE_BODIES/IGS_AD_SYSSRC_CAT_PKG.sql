--------------------------------------------------------
--  DDL for Package Body IGS_AD_SYSSRC_CAT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_SYSSRC_CAT_PKG" AS
/* $Header: IGSAI72B.pls 115.13 2003/10/30 13:16:33 akadam ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_syssrc_cat%RowType;
  new_references igs_ad_syssrc_cat%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_system_source_type IN VARCHAR2 DEFAULT NULL,
    x_category_name IN VARCHAR2 DEFAULT NULL,
    x_mandatory_ind IN VARCHAR2 DEFAULT NULL,
    x_ss_ind IN VARCHAR2 DEFAULT NULL,
    x_display_sequence IN NUMBER DEFAULT NULL,
    x_ad_tab_name  IN VARCHAR2 DEFAULT NULL,
    x_int_tab_name IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  ) AS

  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel        16-JUN-2001   Added processing for two newly added columns AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_SYSSRC_CAT
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
    new_references.system_source_type := x_system_source_type;
    new_references.category_name := x_category_name;
    new_references.mandatory_ind := x_mandatory_ind;
    new_references.ss_ind := x_ss_ind;
    new_references.display_sequence := x_display_sequence;
    new_references.ad_tab_name  := x_ad_tab_name;
    new_references.int_tab_name := x_int_tab_name;
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
    new_references.closed_ind := NVL(x_closed_ind,'N');

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

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'MANDATORY_IND'  THEN
        new_references.mandatory_ind := column_value;
        NULL;
      END IF;
     ----Removed the validations for SS_IND,DISPLAY_SEQUENCE ( pbondugu  Bug #3032535)
    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'MANDATORY_IND' OR
      	Column_Name IS NULL THEN
        IF NOT (new_references.mandatory_ind IN ('Y','N'))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
           IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;

  END Check_Constraints;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  hreddych     26-mar-2002     2803604 -To remove dependency on the
                               Igs_lookups_view_Pkg in seed env
                               Lookups are not deleted Hence no need to
                               check for existence.
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN
    NULL;

/*    IF (((old_references.category_name = new_references.category_name)) OR
        ((new_references.category_name IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_lookups_view_Pkg.Get_PK_For_Validation (
			'SYSTEM_SOURCE_TYPES',
        		new_references.system_source_type
        )  THEN
      Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
    END IF;

*/
  END Check_Parent_Existance;


  FUNCTION Get_PK_For_Validation (
    x_category_name IN VARCHAR2,
    x_system_source_type IN VARCHAR2,
    x_closed_ind IN VARCHAR2
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
      FROM     igs_ad_syssrc_cat
      WHERE    category_name = x_category_name
      AND      system_source_type = x_system_source_type AND
               closed_ind = NVL(x_closed_ind,closed_ind)
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


  FUNCTION get_uk_for_validation (
    x_category_name                     IN     VARCHAR2,
    x_system_source_type                IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : kumma
  ||  Created On : 12-FEB-2003
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_syssrc_cat
      WHERE    upper(category_name) = upper(x_category_name)
      AND      upper(system_source_type) = upper(x_system_source_type)
      AND      ((l_rowid IS NULL) OR (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN
    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
    ELSE
       CLOSE cur_rowid;
      RETURN(FALSE);
    END IF;

  END get_uk_for_validation ;


 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :
  Date Created By :
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  (reverse chronological order - newest change first)
  ***************************************************************/

 BEGIN
     		IF Get_Uk_For_Validation (
    		new_references.category_name
    		,new_references.system_source_type
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
		    IGS_GE_MSG_STACK.ADD;
		    app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;


  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_system_source_type IN VARCHAR2 DEFAULT NULL,
    x_category_name IN VARCHAR2 DEFAULT NULL,
    x_mandatory_ind IN VARCHAR2 DEFAULT NULL,
    x_ss_ind IN VARCHAR2 DEFAULT NULL,
    x_display_sequence IN NUMBER DEFAULT NULL,
    x_ad_tab_name  IN VARCHAR2 DEFAULT NULL,
    x_int_tab_name IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel   16-JUN-2001     Added processing for two newly added columns AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_system_source_type,
      x_category_name,
      x_mandatory_ind,
      x_ss_ind,
      x_display_sequence,
      x_ad_tab_name,
      x_int_tab_name,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login,
      x_closed_ind
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
	     IF Get_Pk_For_Validation(
    		new_references.category_name,
    		new_references.system_source_type)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      --kumma, called the Check_Uniqueness 2664699
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      --kumma, called the Check_Uniqueness 2664699
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.category_name,
    		new_references.system_source_type)  THEN
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

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
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
       x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_SS_IND IN VARCHAR2,
       x_DISPLAY_SEQUENCE IN NUMBER,
       x_ad_tab_name  IN VARCHAR2 DEFAULT NULL,
       x_int_tab_name IN VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R',
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel     16-JUN-2001    Added processing for two newly added columns AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_SYSSRC_CAT
             where                 CATEGORY_NAME= X_CATEGORY_NAME
            and SYSTEM_SOURCE_TYPE = X_SYSTEM_SOURCE_TYPE
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
 	       x_system_source_type=>X_SYSTEM_SOURCE_TYPE,
 	       x_category_name=>X_CATEGORY_NAME,
 	       x_mandatory_ind=>X_MANDATORY_IND,
 	       x_ss_ind=>X_SS_IND,
 	       x_display_sequence=>X_DISPLAY_SEQUENCE,
 	       x_ad_tab_name=>X_AD_TAB_NAME,
	       x_int_tab_name=>X_INT_TAB_NAME,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_closed_ind=>X_CLOSED_IND);
     insert into IGS_AD_SYSSRC_CAT (
		SYSTEM_SOURCE_TYPE
		,CATEGORY_NAME
		,MANDATORY_IND
		,SS_IND
		,DISPLAY_SEQUENCE
		,AD_TAB_NAME
		,INT_TAB_NAME
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
		,CLOSED_IND
        ) values  (
	        NEW_REFERENCES.SYSTEM_SOURCE_TYPE
	        ,NEW_REFERENCES.CATEGORY_NAME
	        ,NEW_REFERENCES.MANDATORY_IND
	        ,NULL
	        ,NULL
	        ,NEW_REFERENCES.AD_TAB_NAME
	        ,NEW_REFERENCES.INT_TAB_NAME
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
		,NVL(X_CLOSED_IND,'N')
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
       x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_SS_IND IN VARCHAR2,
       x_DISPLAY_SEQUENCE IN NUMBER,
       x_AD_TAB_NAME IN VARCHAR2 DEFAULT NULL,
       x_INT_TAB_NAME IN VARCHAR2 DEFAULT NULL,
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
		    ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
 pkpatel     16-JUN-2001    Added processing for two newly added columns AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      SYSTEM_SOURCE_TYPE,
      CATEGORY_NAME,
      MANDATORY_IND,
      SS_IND,
      DISPLAY_SEQUENCE,
      AD_TAB_NAME,
      INT_TAB_NAME,
      CLOSED_IND
    from IGS_AD_SYSSRC_CAT
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
if (        (tlinfo.MANDATORY_IND = X_MANDATORY_IND)
     AND ((tlinfo.AD_TAB_NAME = X_AD_TAB_NAME) OR ((tlinfo.AD_TAB_NAME IS NULL) AND (X_AD_TAB_NAME IS NULL)))
     AND ((tlinfo.INT_TAB_NAME = X_INT_TAB_NAME) OR ((tlinfo.INT_TAB_NAME IS NULL) AND (X_INT_TAB_NAME IS NULL)))
     AND ((tlinfo.CLOSED_IND = X_CLOSED_IND) OR ((tlinfo.CLOSED_IND IS NULL) AND (X_CLOSED_IND IS NULL)))
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
       x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_SS_IND IN VARCHAR2,
       x_DISPLAY_SEQUENCE IN NUMBER,
       x_AD_TAB_NAME IN VARCHAR2 DEFAULT NULL,
       x_INT_TAB_NAME IN VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R',
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
pkpatel       16-JUN-2001   Added processing for two newly added columns AD_TAB_NAME and INT_TAB_NAME
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
 	       x_system_source_type=>X_SYSTEM_SOURCE_TYPE,
 	       x_category_name=>X_CATEGORY_NAME,
 	       x_mandatory_ind=>X_MANDATORY_IND,
 	       x_ss_ind=>X_SS_IND,
 	       x_display_sequence=>X_DISPLAY_SEQUENCE,
               x_ad_tab_name=>X_AD_TAB_NAME,
               x_int_tab_name=>X_INT_TAB_NAME,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN,
	       x_closed_ind=>X_CLOSED_IND);

            update IGS_AD_SYSSRC_CAT set
               mandatory_ind=X_MANDATORY_IND,
               ss_ind=NULL,
               display_sequence=NULL,
               ad_tab_name=X_AD_TAB_NAME,
               int_tab_name=X_INT_TAB_NAME,
  	       LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
	       LAST_UPDATED_BY = X_LAST_UPDATED_BY,
	       LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,
	       CLOSED_IND = NVL(X_CLOSED_IND,'N')
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
       x_SYSTEM_SOURCE_TYPE IN VARCHAR2,
       x_CATEGORY_NAME IN VARCHAR2,
       x_MANDATORY_IND IN VARCHAR2,
       x_SS_IND IN VARCHAR2,
       x_DISPLAY_SEQUENCE IN NUMBER,
       x_AD_TAB_NAME IN VARCHAR2 DEFAULT NULL,
       x_INT_TAB_NAME IN VARCHAR2 DEFAULT NULL,
      X_MODE in VARCHAR2 default 'R',
      X_CLOSED_IND IN VARCHAR2 DEFAULT 'N'
  ) AS
  /*************************************************************
  Created By : amuthu
  Date Created On : 16-May-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
pkpatel       16-JUN-2001    Added processing for two newly added columns AD_TAB_NAME and INT_TAB_NAME
  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_SYSSRC_CAT
             where     CATEGORY_NAME= X_CATEGORY_NAME
            and SYSTEM_SOURCE_TYPE = X_SYSTEM_SOURCE_TYPE
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_SYSTEM_SOURCE_TYPE,
       X_CATEGORY_NAME,
       X_MANDATORY_IND,
       X_SS_IND,
       X_DISPLAY_SEQUENCE,
       X_AD_TAB_NAME,
       X_INT_TAB_NAME,
      X_MODE,
      X_CLOSED_IND);
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_SYSTEM_SOURCE_TYPE,
       X_CATEGORY_NAME,
       X_MANDATORY_IND,
       X_SS_IND,
       X_DISPLAY_SEQUENCE,
       X_AD_TAB_NAME,
       X_INT_TAB_NAME,
      X_MODE,
      X_CLOSED_IND);
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

begin
Before_DML (
p_action => 'DELETE',
x_rowid => X_ROWID
);
 delete from IGS_AD_SYSSRC_CAT
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ad_syssrc_cat_pkg;

/
