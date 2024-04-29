--------------------------------------------------------
--  DDL for Package Body IGS_AD_ROOM_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_AD_ROOM_PKG" AS
/* $Header: IGSAIB5B.pls 115.15 2003/10/30 13:17:31 akadam ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ad_room_all%RowType;
  new_references igs_ad_room_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
		x_org_id IN NUMBER DEFAULT NULL,
    x_room_id IN NUMBER DEFAULT NULL,
    x_building_id IN NUMBER DEFAULT NULL,
    x_room_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_primary_use_cd IN VARCHAR2 DEFAULT NULL,
    x_capacity IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_AD_ROOM_ALL
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
    new_references.room_id := x_room_id;
    new_references.building_id := x_building_id;
    new_references.room_cd := x_room_cd;
    new_references.description := x_description;
    new_references.primary_use_cd := x_primary_use_cd;
    new_references.capacity := x_capacity;
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

  PROCEDURE Check_Constraints (
		 Column_Name IN VARCHAR2  DEFAULT NULL,
		 Column_Value IN VARCHAR2  DEFAULT NULL ) AS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

     IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'CLOSED_IND'  THEN
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


  END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.building_id
    		,new_references.room_cd
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.building_id = new_references.building_id)) OR
        ((new_references.building_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ad_Building_Pkg.Get_PK_For_Validation (
              new_references.building_id ,
              'N')  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;
    if not IGS_LOOKUPS_VIEW_PKG.Get_PK_For_Validation ( 'PRIMARY_USE',
    new_references.primary_use_cd ) THEN
    	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;


  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ps_Unit_Location_Pkg.Get_FK_Igs_Ad_Room (
      old_references.room_id
      );

     Igs_Ps_Usec_Occurs_Pkg.Get_FK_Igs_Ad_Room (
        old_references.room_id
      );

     igs_ps_us_unsched_cl_pkg.Get_FK_Igs_Ad_Room (
        old_references.room_id
      );

     igs_ps_usec_occurs_pkg.Get_FK_Igs_Ad_Room (
        old_references.room_id
      );
      igs_ad_panel_dtls_pkg.get_fk_igs_ad_room(
        old_references.room_id
      );


  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_room_id IN NUMBER,
    x_closed_ind IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_room_all
      WHERE    room_id = x_room_id AND
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

  FUNCTION Get_UK_For_Validation (
    x_building_id IN NUMBER,
    x_room_cd IN VARCHAR2,
    x_closed_ind  IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_room_all
      WHERE    building_id = x_building_id  AND
              room_cd = x_room_cd 	AND
             ((l_rowid is null) or (rowid <> l_rowid)) AND
               closed_ind = NVL(x_closed_ind,closed_ind)

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
  PROCEDURE GET_FK_Igs_Ad_Building (
    x_building_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ad_room_all
      WHERE    building_id = x_building_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_AD_ROOM_BLDG_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ad_Building;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
		x_org_id IN NUMBER DEFAULT NULL,
    x_room_id IN NUMBER DEFAULT NULL,
    x_building_id IN NUMBER DEFAULT NULL,
    x_room_cd IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,

    x_primary_use_cd IN VARCHAR2 DEFAULT NULL,
    x_capacity IN NUMBER DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
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
			x_org_id,
      x_room_id,
      x_building_id,
      x_room_cd,
      x_description,
      x_primary_use_cd,
      x_capacity,
      x_closed_ind,
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
    		new_references.room_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
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
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.room_id)  THEN
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
      Check_Child_Existance;
    END IF;
    l_rowid:=NULL;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
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

  l_rowid:=NULL;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
			x_ORG_ID IN NUMBER,
       x_ROOM_ID IN OUT NOCOPY NUMBER,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PRIMARY_USE_CD IN VARCHAR2,
       x_CAPACITY IN NUMBER,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_AD_ROOM_ALL
             where                 ROOM_ID= X_ROOM_ID
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

   x_ROOM_ID := -1;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
		x_org_id => igs_ge_gen_003.get_org_id,
 	       x_room_id=>X_ROOM_ID,
 	       x_building_id=>X_BUILDING_ID,
 	       x_room_cd=>X_ROOM_CD,
 	       x_description=>X_DESCRIPTION,
 	       x_primary_use_cd=>X_PRIMARY_USE_CD,
 	       x_capacity=>X_CAPACITY,
 	       x_closed_ind=>X_CLOSED_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_AD_ROOM_ALL (
		ORG_ID,
		ROOM_ID
		,BUILDING_ID
		,ROOM_CD
		,DESCRIPTION
		,PRIMARY_USE_CD
		,CAPACITY
		,CLOSED_IND
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.ORG_ID,
	        IGS_AD_ROOM_S.NEXTVAL
	        ,NEW_REFERENCES.BUILDING_ID
	        ,NEW_REFERENCES.ROOM_CD
	        ,NEW_REFERENCES.DESCRIPTION
	        ,NEW_REFERENCES.PRIMARY_USE_CD
	        ,NEW_REFERENCES.CAPACITY
	        ,NEW_REFERENCES.CLOSED_IND
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY

		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN
)RETURNING ROOM_ID INTO x_ROOM_ID;
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
       x_ROOM_ID IN NUMBER,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PRIMARY_USE_CD IN VARCHAR2,
       x_CAPACITY IN NUMBER,
       x_CLOSED_IND IN VARCHAR2  ) AS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      BUILDING_ID
,      ROOM_CD
,      DESCRIPTION
,      PRIMARY_USE_CD
,      CAPACITY
,      CLOSED_IND
    from IGS_AD_ROOM_ALL
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
if ( (  tlinfo.BUILDING_ID = X_BUILDING_ID)
  AND (tlinfo.ROOM_CD = X_ROOM_CD)
  AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
  AND (tlinfo.PRIMARY_USE_CD = X_PRIMARY_USE_CD)
  AND (tlinfo.CAPACITY = X_CAPACITY)
  AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
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
       x_ROOM_ID IN NUMBER,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PRIMARY_USE_CD IN VARCHAR2,
       x_CAPACITY IN NUMBER,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
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
 	       x_room_id=>X_ROOM_ID,
 	       x_building_id=>X_BUILDING_ID,
 	       x_room_cd=>X_ROOM_CD,
 	       x_description=>X_DESCRIPTION,
 	       x_primary_use_cd=>X_PRIMARY_USE_CD,
 	       x_capacity=>X_CAPACITY,
 	       x_closed_ind=>X_CLOSED_IND,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_AD_ROOM_ALL set
      BUILDING_ID =  NEW_REFERENCES.BUILDING_ID,
      ROOM_CD =  NEW_REFERENCES.ROOM_CD,
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      PRIMARY_USE_CD =  NEW_REFERENCES.PRIMARY_USE_CD,
      CAPACITY =  NEW_REFERENCES.CAPACITY,
      CLOSED_IND =  NEW_REFERENCES.CLOSED_IND,
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
			X_ORG_ID in NUMBER,
       x_ROOM_ID IN OUT NOCOPY NUMBER,
       x_BUILDING_ID IN NUMBER,
       x_ROOM_CD IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_PRIMARY_USE_CD IN VARCHAR2,
       x_CAPACITY IN NUMBER,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_AD_ROOM_ALL
             where     ROOM_ID= X_ROOM_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
			X_ORG_ID,
       X_ROOM_ID,
       X_BUILDING_ID,
       X_ROOM_CD,
       X_DESCRIPTION,
       X_PRIMARY_USE_CD,
       X_CAPACITY,
       X_CLOSED_IND,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_ROOM_ID,
       X_BUILDING_ID,

       X_ROOM_CD,
       X_DESCRIPTION,
       X_PRIMARY_USE_CD,
       X_CAPACITY,
       X_CLOSED_IND,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By :hsahni
  Date Created By :10-MAY-2000
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
 delete from IGS_AD_ROOM_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ad_room_pkg;

/
