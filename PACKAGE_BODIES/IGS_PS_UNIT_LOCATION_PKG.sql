--------------------------------------------------------
--  DDL for Package Body IGS_PS_UNIT_LOCATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UNIT_LOCATION_PKG" AS
/* $Header: IGSPI0LB.pls 115.8 2003/10/30 13:30:23 rghosh ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_unit_location%RowType;
  new_references igs_ps_unit_location%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_location_id IN NUMBER DEFAULT NULL,
    x_unit_code IN VARCHAR2 DEFAULT NULL,
    x_unit_version_number IN NUMBER DEFAULT NULL,
    x_location_code IN VARCHAR2 DEFAULT NULL,
    x_building_id IN NUMBER DEFAULT NULL,
    x_room_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UNIT_LOCATION
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
    new_references.unit_location_id := x_unit_location_id;
    new_references.unit_code := x_unit_code;
    new_references.unit_version_number := x_unit_version_number;
    new_references.location_code := x_location_code;
    new_references.building_id := x_building_id;
    new_references.room_id := x_room_id;
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
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
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

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.location_code
    		,new_references.room_id
    		,new_references.unit_code
    		,new_references.unit_version_number
    		,new_references.building_id
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.location_code = new_references.location_code)) OR
        ((new_references.location_code IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Location_Pkg.Get_PK_For_Validation (
        		new_references.location_code ,
            'N'
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.unit_code = new_references.unit_code) AND
         (old_references.unit_version_number = new_references.unit_version_number)) OR
        ((new_references.unit_code IS NULL) OR
         (new_references.unit_version_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Unit_Ver_Pkg.Get_PK_For_Validation (
        		new_references.unit_code,
         		 new_references.unit_version_number
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.room_id = new_references.room_id)) OR
        ((new_references.room_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Room_Pkg.Get_PK_For_Validation (
        		new_references.room_id ,
            'N'
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.building_id = new_references.building_id)) OR
        ((new_references.building_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Building_Pkg.Get_PK_For_Validation (
        		new_references.building_id ,
            'N'
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_location_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_location
      WHERE    unit_location_id = x_unit_location_id
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
    x_location_code IN VARCHAR2,
    x_room_id IN NUMBER,
    x_unit_code IN VARCHAR2,
    x_unit_version_number IN NUMBER,
    x_building_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_location
      WHERE    location_code = x_location_code
      AND      unit_code = x_unit_code
      AND      unit_version_number = x_unit_version_number
      AND      nvl(room_id,0) = nvl(x_room_id,0)
      AND      nvl(building_id,0) = nvl(x_building_id,0)
      AND      ((l_rowid is null) or (rowid <> l_rowid))

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
  PROCEDURE Get_FK_Igs_Ad_Location (
    x_location_cd IN VARCHAR2
    ) AS

  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_location
      WHERE    location_code = x_location_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UL_LOC_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Location;

  PROCEDURE Get_FK_Igs_Ps_Unit_Ver (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) AS

  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_location
      WHERE    unit_code = x_unit_cd
      AND      unit_version_number = x_version_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UL_UV_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Unit_Ver;

  PROCEDURE Get_FK_Igs_Ad_Room (
    x_room_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_location
      WHERE    room_id = x_room_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UL_ROOM_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Room;

  PROCEDURE Get_FK_Igs_Ad_Building (
    x_building_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_unit_location
      WHERE    building_id = x_building_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_UL_BLDG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Building;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_location_id IN NUMBER DEFAULT NULL,
    x_unit_code IN VARCHAR2 DEFAULT NULL,
    x_unit_version_number IN NUMBER DEFAULT NULL,
    x_location_code IN VARCHAR2 DEFAULT NULL,
    x_building_id IN NUMBER DEFAULT NULL,
    x_room_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_location_id,
      x_unit_code,
      x_unit_version_number,
      x_location_code,
      x_building_id,
      x_room_id,
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
    		new_references.unit_location_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.unit_location_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
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
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
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
l_rowid:=NULL;
  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_LOCATION_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_LOCATION_CODE IN VARCHAR2,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_UNIT_LOCATION
             where                 UNIT_LOCATION_ID= X_UNIT_LOCATION_ID
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
   Select IGS_PS_UNIT_LOCATION_S.NEXTVAL into x_unit_location_id from dual;

   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_unit_location_id=>X_UNIT_LOCATION_ID,
 	       x_unit_code=>X_UNIT_CODE,
 	       x_unit_version_number=>X_UNIT_VERSION_NUMBER,
 	       x_location_code=>X_LOCATION_CODE,
 	       x_building_id=>X_BUILDING_ID,
 	       x_room_id=>X_ROOM_ID,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_PS_UNIT_LOCATION (
		UNIT_LOCATION_ID
		,UNIT_CODE
		,UNIT_VERSION_NUMBER
		,LOCATION_CODE
		,BUILDING_ID
		,ROOM_ID
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.UNIT_LOCATION_ID
	        ,NEW_REFERENCES.UNIT_CODE
	        ,NEW_REFERENCES.UNIT_VERSION_NUMBER
	        ,NEW_REFERENCES.LOCATION_CODE
	        ,NEW_REFERENCES.BUILDING_ID
	        ,NEW_REFERENCES.ROOM_ID
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
       x_UNIT_LOCATION_ID IN NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_LOCATION_CODE IN VARCHAR2,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_ID IN NUMBER  ) AS
  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      UNIT_CODE
,      UNIT_VERSION_NUMBER
,      LOCATION_CODE
,      BUILDING_ID
,      ROOM_ID
    from IGS_PS_UNIT_LOCATION
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
if ( (  tlinfo.UNIT_CODE = X_UNIT_CODE)
  AND (tlinfo.UNIT_VERSION_NUMBER = X_UNIT_VERSION_NUMBER)
  AND (tlinfo.LOCATION_CODE = X_LOCATION_CODE)
  AND ((tlinfo.BUILDING_ID = X_BUILDING_ID)
            OR ((tlinfo.BUILDING_ID is null)
		AND (X_BUILDING_ID is null)))
  AND ((tlinfo.ROOM_ID = X_ROOM_ID)
 	    OR ((tlinfo.ROOM_ID is null)
		AND (X_ROOM_ID is null)))
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
       x_UNIT_LOCATION_ID IN NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_LOCATION_CODE IN VARCHAR2,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
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
 	       x_unit_location_id=>X_UNIT_LOCATION_ID,
 	       x_unit_code=>X_UNIT_CODE,
 	       x_unit_version_number=>X_UNIT_VERSION_NUMBER,
 	       x_location_code=>X_LOCATION_CODE,
 	       x_building_id=>X_BUILDING_ID,
 	       x_room_id=>X_ROOM_ID,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_PS_UNIT_LOCATION set
      UNIT_CODE =  NEW_REFERENCES.UNIT_CODE,
      UNIT_VERSION_NUMBER =  NEW_REFERENCES.UNIT_VERSION_NUMBER,
      LOCATION_CODE =  NEW_REFERENCES.LOCATION_CODE,
      BUILDING_ID =  NEW_REFERENCES.BUILDING_ID,
      ROOM_ID =  NEW_REFERENCES.ROOM_ID,
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
       x_UNIT_LOCATION_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CODE IN VARCHAR2,
       x_UNIT_VERSION_NUMBER IN NUMBER,
       x_LOCATION_CODE IN VARCHAR2,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_ID IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PS_UNIT_LOCATION
             where     UNIT_LOCATION_ID= X_UNIT_LOCATION_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_UNIT_LOCATION_ID,
       X_UNIT_CODE,
       X_UNIT_VERSION_NUMBER,
       X_LOCATION_CODE,
       X_BUILDING_ID,
       X_ROOM_ID,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_UNIT_LOCATION_ID,
       X_UNIT_CODE,
       X_UNIT_VERSION_NUMBER,
       X_LOCATION_CODE,
       X_BUILDING_ID,
       X_ROOM_ID,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : sokaul
  Date Created By : 11-MAY-2000
  Purpose : NEW TABLE
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
 delete from IGS_PS_UNIT_LOCATION
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ps_unit_location_pkg;

/
