--------------------------------------------------------
--  DDL for Package Body IGS_PS_UOFR_WLST_PRI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_UOFR_WLST_PRI_PKG" AS
/* $Header: IGSPI96B.pls 115.9 2003/12/05 13:22:37 sarakshi ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_uofr_wlst_pri%RowType;
  new_references igs_ps_uofr_wlst_pri%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_ofr_wl_priority_id IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_calender_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_priority_number IN NUMBER DEFAULT NULL,
    x_priority_value IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_UOFR_WLST_PRI
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
    new_references.unit_ofr_waitlist_priority_id := x_unit_ofr_wl_priority_id;
    new_references.unit_cd := x_unit_cd;
    new_references.version_number := x_version_number;
    new_references.calender_type := x_calender_type;
    new_references.ci_sequence_number := x_ci_sequence_number;
    new_references.priority_number := x_priority_number;
    new_references.priority_value := x_priority_value;
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
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
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
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.calender_type
    		,new_references.ci_sequence_number
    		,new_references.priority_value
    		,new_references.unit_cd
    		,new_references.version_number
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  smvk           31-Jan-2003     Bug # 2532094. Added the foreign key checking with igs_lookups_view.
  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.unit_cd = new_references.unit_cd) AND
         (old_references.version_number = new_references.version_number) AND
         (old_references.calender_type = new_references.calender_type) AND
         (old_references.ci_sequence_number = new_references.ci_sequence_number)) OR
        ((new_references.unit_cd IS NULL) OR
         (new_references.version_number IS NULL) OR
         (new_references.calender_type IS NULL) OR
         (new_references.ci_sequence_number IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Unit_Ofr_Pat_Pkg.Get_PK_For_Validation (
        		new_references.unit_cd,
         		 new_references.version_number,
         		 new_references.calender_type,
         		 new_references.ci_sequence_number
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.priority_value = new_references.priority_value)) OR
        ((new_references.priority_value IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation('UNIT_WAITLIST',
        new_references.priority_value) THEN
       Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ps_Uofr_Wlst_Prf_Pkg.Get_FK_Igs_Ps_Uofr_Wlst_Pri (
      old_references.unit_ofr_waitlist_priority_id
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_ofr_wl_priority_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_uofr_wlst_pri
      WHERE    unit_ofr_waitlist_priority_id = x_unit_ofr_wl_priority_id
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
    x_calender_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER,
    x_priority_value IN VARCHAR2,
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  sarakshi  03-Dec-2003  Bug#3168726,taken off priority_number from teh where condition.
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_uofr_wlst_pri
      WHERE    calender_type = x_calender_type
      AND      ci_sequence_number = x_ci_sequence_number
      AND      priority_value = x_priority_value
      AND      unit_cd = x_unit_cd
      AND      version_number = x_version_number and ((l_rowid is null) or (rowid <> l_rowid));
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
  PROCEDURE Get_FK_Igs_Ps_Unit_Ofr_Pat (
    x_unit_cd IN VARCHAR2,
    x_version_number IN NUMBER,
    x_cal_type IN VARCHAR2,
    x_ci_sequence_number IN NUMBER
    ) AS

  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_uofr_wlst_pri
      WHERE    unit_cd = x_unit_cd
      AND      version_number = x_version_number
      AND      calender_type = x_cal_type
      AND      ci_sequence_number = x_ci_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_Ps_Unit_Ofr_Pat;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_ofr_wl_priority_id IN NUMBER DEFAULT NULL,
    x_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_version_number IN NUMBER DEFAULT NULL,
    x_calender_type IN VARCHAR2 DEFAULT NULL,
    x_ci_sequence_number IN NUMBER DEFAULT NULL,
    x_priority_number IN NUMBER DEFAULT NULL,
    x_priority_value IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_unit_ofr_wl_priority_id,
      x_unit_cd,
      x_version_number,
      x_calender_type,
      x_ci_sequence_number,
      x_priority_number,
      x_priority_value,
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
    		new_references.unit_ofr_waitlist_priority_id)  THEN
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
      Check_Child_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.unit_ofr_waitlist_priority_id)  THEN
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
      Check_Child_Existance;
    END IF;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
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
       x_UNIT_OFR_WL_PRIORITY_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_UOFR_WLST_PRI
             where  UNIT_OFR_WAITLIST_PRIORITY_ID= X_UNIT_OFR_WL_PRIORITY_ID;
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
   SELECT IGS_PS_UOFR_WLST_PRI_S.NEXTVAL
   INTO   X_UNIT_OFR_WL_PRIORITY_ID
   FROM   dual;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_unit_ofr_wl_priority_id=>X_UNIT_OFR_WL_PRIORITY_ID,
 	       x_unit_cd=>X_UNIT_CD,
 	       x_version_number=>X_VERSION_NUMBER,
 	       x_calender_type=>X_CALENDER_TYPE,
 	       x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
 	       x_priority_number=>X_PRIORITY_NUMBER,
 	       x_priority_value=>X_PRIORITY_VALUE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_PS_UOFR_WLST_PRI (
		UNIT_OFR_WAITLIST_PRIORITY_ID
		,UNIT_CD
		,VERSION_NUMBER
		,CALENDER_TYPE
		,CI_SEQUENCE_NUMBER
		,PRIORITY_NUMBER
		,PRIORITY_VALUE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.UNIT_OFR_WAITLIST_PRIORITY_ID
	        ,NEW_REFERENCES.UNIT_CD
	        ,NEW_REFERENCES.VERSION_NUMBER
	        ,NEW_REFERENCES.CALENDER_TYPE
	        ,NEW_REFERENCES.CI_SEQUENCE_NUMBER
	        ,NEW_REFERENCES.PRIORITY_NUMBER
	        ,NEW_REFERENCES.PRIORITY_VALUE
	        ,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_DATE
		,X_LAST_UPDATED_BY
		,X_LAST_UPDATE_LOGIN);
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
       x_UNIT_OFR_WL_PRIORITY_ID IN NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      UNIT_CD
,      VERSION_NUMBER
,      CALENDER_TYPE
,      CI_SEQUENCE_NUMBER
,      PRIORITY_NUMBER
,      PRIORITY_VALUE
    from IGS_PS_UOFR_WLST_PRI
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
if ( (  tlinfo.UNIT_CD = X_UNIT_CD)
  AND (tlinfo.VERSION_NUMBER = X_VERSION_NUMBER)
  AND (tlinfo.CALENDER_TYPE = X_CALENDER_TYPE)
  AND (tlinfo.CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER)
  AND (tlinfo.PRIORITY_NUMBER = X_PRIORITY_NUMBER)
  AND (tlinfo.PRIORITY_VALUE = X_PRIORITY_VALUE)
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
       x_UNIT_OFR_WL_PRIORITY_ID IN NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
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
 	       x_unit_ofr_wl_priority_id=>X_UNIT_OFR_WL_PRIORITY_ID,
 	       x_unit_cd=>X_UNIT_CD,
 	       x_version_number=>X_VERSION_NUMBER,
 	       x_calender_type=>X_CALENDER_TYPE,
 	       x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,
 	       x_priority_number=>X_PRIORITY_NUMBER,
 	       x_priority_value=>X_PRIORITY_VALUE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_PS_UOFR_WLST_PRI set
      UNIT_CD =  NEW_REFERENCES.UNIT_CD,
      VERSION_NUMBER =  NEW_REFERENCES.VERSION_NUMBER,
      CALENDER_TYPE =  NEW_REFERENCES.CALENDER_TYPE,
      CI_SEQUENCE_NUMBER =  NEW_REFERENCES.CI_SEQUENCE_NUMBER,
      PRIORITY_NUMBER =  NEW_REFERENCES.PRIORITY_NUMBER,
      PRIORITY_VALUE =  NEW_REFERENCES.PRIORITY_VALUE,
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
       x_UNIT_OFR_WL_PRIORITY_ID IN OUT NOCOPY NUMBER,
       x_UNIT_CD IN VARCHAR2,
       x_VERSION_NUMBER IN NUMBER,
       x_CALENDER_TYPE IN VARCHAR2,
       x_CI_SEQUENCE_NUMBER IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PS_UOFR_WLST_PRI
          where   UNIT_OFR_WAITLIST_PRIORITY_ID= X_UNIT_OFR_WL_PRIORITY_ID;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_UNIT_OFR_WL_PRIORITY_ID,
       X_UNIT_CD,
       X_VERSION_NUMBER,
       X_CALENDER_TYPE,
       X_CI_SEQUENCE_NUMBER,
       X_PRIORITY_NUMBER,
       X_PRIORITY_VALUE,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_UNIT_OFR_WL_PRIORITY_ID,
       X_UNIT_CD,
       X_VERSION_NUMBER,
       X_CALENDER_TYPE,
       X_CI_SEQUENCE_NUMBER,
       X_PRIORITY_NUMBER,
       X_PRIORITY_VALUE,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : smanglm
  Date Created On : 4-MAY-2000
  Purpose : Creation of TBH
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
 delete from IGS_PS_UOFR_WLST_PRI
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ps_uofr_wlst_pri_pkg;

/
