--------------------------------------------------------
--  DDL for Package Body IGS_RU_TRG_GROUP_CD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_RU_TRG_GROUP_CD_PKG" AS
/* $Header: IGSUI20B.pls 115.8 2002/11/29 04:30:23 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ru_trg_group_cd%RowType;
  new_references igs_ru_trg_group_cd%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_group_cd IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
) AS

  /*************************************************************
  Created By : tray
  Date Created By : 10.05.2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/


    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_RU_TRG_GROUP_CD
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
      IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_TRG_GROUP_CD    : P_ACTION  INSERT, VALIDATE_INSERT  : IGSUI20B.PLS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.group_cd := x_group_cd;
    new_references.description := x_description;
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
		 Column_Name IN VARCHAR2  ,
		 Column_Value IN VARCHAR2  ) AS

  /*************************************************************
  Created By : tray
  Date Created By : 10.05.2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
        NULL;
      END IF;




  END Check_Constraints;


  PROCEDURE Check_Child_Existance IS
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

    Igs_Ru_Turin_Rule_Gr_Pkg.Get_FK_Igs_Ru_Trg_Group_Cd (
      old_references.group_cd
      );

  END Check_Child_Existance;


  FUNCTION Get_PK_For_Validation (
    x_group_cd IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : tray
  Date Created By : 10.05.2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ru_trg_group_cd
      WHERE    group_cd = x_group_cd
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
    x_rowid IN VARCHAR2 ,
    x_group_cd IN VARCHAR2 ,
    x_description IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS

  /*************************************************************
  Created By : tray
  Date Created By : 10.05.2000
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
      x_group_cd,
      x_description,
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
    		new_references.group_cd)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.group_cd)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_DELETE') THEN
      Null;
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS

    /*************************************************************
  Created By : tray
  Date Created By : 10.05.2000
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
       x_GROUP_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
      X_MODE in VARCHAR2
) AS
    /*************************************************************
  Created By : tray
  Date Created By : 10.05.2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/


    cursor C is select ROWID from IGS_RU_TRG_GROUP_CD
             where                 GROUP_CD= X_GROUP_CD
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
 	       x_group_cd=>X_GROUP_CD,
 	       x_description=>X_DESCRIPTION,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_RU_TRG_GROUP_CD (
		GROUP_CD
		,DESCRIPTION
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.GROUP_CD
	        ,NEW_REFERENCES.DESCRIPTION
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
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
       x_GROUP_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2  ) AS

   /*************************************************************
  Created By : tray
  Date Created By : 10.05.2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      DESCRIPTION
    from IGS_RU_TRG_GROUP_CD
    where ROWID = X_ROWID
    for update nowait;
     tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
     IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_TRG_GROUP_CD    : P_ACTION  LOCK_ROW : IGSUI20B.PLS');
      IGS_GE_MSG_STACK.ADD;
    close c1;
    app_exception.raise_exception;
    return;
  end if;
  close c1;
if ( (  tlinfo.DESCRIPTION = X_DESCRIPTION)
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_RU_GEN_006.SET_TOKEN(' IGS_RU_TRG_GROUP_CD    : P_ACTION  LOCK_ROW  FORM_RECORD_CHANGED: IGSUI20B.PLS');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

 Procedure UPDATE_ROW (
      X_ROWID in  VARCHAR2,
       x_GROUP_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
      X_MODE in VARCHAR2
) AS

    /*************************************************************
  Created By : tray
  Date Created By : 10.05.2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

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
 	       x_group_cd=>X_GROUP_CD,
 	       x_description=>X_DESCRIPTION,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_RU_TRG_GROUP_CD set
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
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
       x_GROUP_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
      X_MODE in VARCHAR2
) AS

    /*************************************************************
  Created By : tray
  Date Created By : 10.05.2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

   (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_RU_TRG_GROUP_CD
             where     GROUP_CD= X_GROUP_CD
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_GROUP_CD,
       X_DESCRIPTION,
      X_MODE );
     return;
	end if;
	   close c1;

UPDATE_ROW (
      X_ROWID,
       X_GROUP_CD,
       X_DESCRIPTION,
      X_MODE );
end ADD_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS

  /*************************************************************
  Created By : tray
  Date Created By : 10.05.2000
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
 delete from IGS_RU_TRG_GROUP_CD
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ru_trg_group_cd_pkg;

/
