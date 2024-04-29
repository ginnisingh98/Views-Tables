--------------------------------------------------------
--  DDL for Package Body IGS_EN_INST_WLST_OPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_INST_WLST_OPT_PKG" AS
/* $Header: IGSEI16B.pls 115.10 2003/09/18 03:45:11 svanukur ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_EN_INST_WLST_OPT_ALL%RowType;
  new_references IGS_EN_INST_WLST_OPT_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL,
    x_inst_waitlist_id IN NUMBER DEFAULT NULL,
    x_cal_type IN VARCHAR2 DEFAULT NULL,
    x_waitlist_alwd IN VARCHAR2 DEFAULT NULL,
    x_smlnes_waitlist_alwd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_INST_WLST_OPT_ALL
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
    new_references.inst_waitlist_id := x_inst_waitlist_id;
    new_references.cal_type := x_cal_type;
    new_references.waitlist_alwd := x_waitlist_alwd;
    new_references.smlnes_waitlist_alwd := x_smlnes_waitlist_alwd;
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
  Created By : ahemmige
  Date Created : 20-MAY-2000
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

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.cal_type

    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (old_references.cal_type = new_references.cal_type)
          OR
        (new_references.cal_type IS NULL)
          THEN
      NULL;
    ELSIF NOT Igs_Ca_Type_Pkg.Get_PK_For_Validation (
        		new_references.cal_type

        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_inst_waitlist_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_INST_WLST_OPT_ALL
      WHERE    inst_waitlist_id = x_inst_waitlist_id
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
    x_cal_type IN VARCHAR2

    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_INST_WLST_OPT_ALL
      WHERE    cal_type = x_cal_type
      	and      ((l_rowid is null) or (rowid <> l_rowid))

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
  PROCEDURE Get_FK_Igs_Ca_Type (
    x_cal_type IN VARCHAR2
       ) AS

  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  svanukur     01-sep-2003      created as part of waitlist enhancement build #3052426
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_EN_INST_WLST_OPT_ALL
      WHERE    cal_type = x_cal_type ;


    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_OUW_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;


  END Get_FK_Igs_Ca_Type;

  PROCEDURE Get_FK_Igs_Ca_Inst (
    x_cal_type IN VARCHAR2,
    x_sequence_number IN NUMBER
    ) AS

  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  svanukur       02-sep-2003   commenting since sequence_number is obsoleted
                               as part of waitlist enhancement build 3052426
                               to avoid dependency on psp build #3045007
  ***************************************************************/

   /* CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_or_unit_wlst_all
      WHERE    cal_type = x_cal_type
      AND      sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_OUW_OU_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid; */
    BEGIN
    NULL;

  END Get_FK_Igs_Ca_Inst;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 ,
    x_org_id IN NUMBER ,
    x_inst_waitlist_id IN NUMBER ,
    x_cal_type IN VARCHAR2 ,
    x_waitlist_alwd IN VARCHAR2 ,
    x_smlnes_waitlist_alwd IN VARCHAR2 ,
    x_creation_date IN DATE ,
    x_created_by IN NUMBER ,
    x_last_update_date IN DATE ,
    x_last_updated_by IN NUMBER ,
    x_last_update_login IN NUMBER
  ) AS
  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
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
      x_inst_waitlist_id,
      x_cal_type,
      x_waitlist_alwd,
      x_smlnes_waitlist_alwd,
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
    		new_references.inst_waitlist_id)  THEN
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
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.inst_waitlist_id)  THEN
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
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
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
       X_ORG_ID in NUMBER,
       x_INST_WAITLIST_ID IN OUT NOCOPY NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_WAITLIST_ALWD IN VARCHAR2,
       x_SMLNES_WAITLIST_ALWD IN VARCHAR2,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_EN_INST_WLST_OPT_ALL
             where                 INST_WAITLIST_ID= X_INST_WAITLIST_ID
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
   select IGS_EN_INST_WLST_OPT_S.nextval into x_inst_waitlist_id from dual;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
               x_org_id => igs_ge_gen_003.get_org_id,
 	       x_inst_waitlist_id=>X_INST_WAITLIST_ID,
 	       x_cal_type=>X_CAL_TYPE,
 	       x_waitlist_alwd=>X_WAITLIST_ALWD,
 	       x_smlnes_waitlist_alwd=>X_SMLNES_WAITLIST_ALWD,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_EN_INST_WLST_OPT_ALL (
		org_id
		,INST_WAITLIST_ID
		,CAL_TYPE
		,WAITLIST_ALWD
		,SMLNES_WAITLIST_ALWD
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
                NEW_REFERENCES.ORG_ID
	        ,NEW_REFERENCES.INST_WAITLIST_ID
	        ,NEW_REFERENCES.CAL_TYPE
	        ,NEW_REFERENCES.WAITLIST_ALWD
	        ,NEW_REFERENCES.SMLNES_WAITLIST_ALWD
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
       x_INST_WAITLIST_ID IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_WAITLIST_ALWD IN VARCHAR2,
       x_SMLNES_WAITLIST_ALWD IN VARCHAR2  ) AS
  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
          CAL_TYPE,

      WAITLIST_ALWD
,      SMLNES_WAITLIST_ALWD
    from IGS_EN_INST_WLST_OPT_ALL
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
if ( (  tlinfo.CAL_TYPE = X_CAL_TYPE)

  AND (tlinfo.WAITLIST_ALWD = X_WAITLIST_ALWD)
  AND (tlinfo.SMLNES_WAITLIST_ALWD = X_SMLNES_WAITLIST_ALWD)
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
       x_INST_WAITLIST_ID IN NUMBER,
       x_CAL_TYPE IN VARCHAR2,
        x_WAITLIST_ALWD IN VARCHAR2,
       x_SMLNES_WAITLIST_ALWD IN VARCHAR2,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
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
 	       x_inst_waitlist_id=>X_INST_WAITLIST_ID,
 	       x_cal_type=>X_CAL_TYPE,
 	       x_waitlist_alwd=>X_WAITLIST_ALWD,
 	       x_smlnes_waitlist_alwd=>X_SMLNES_WAITLIST_ALWD,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_EN_INST_WLST_OPT_ALL set
      CAL_TYPE =  NEW_REFERENCES.CAL_TYPE,
       WAITLIST_ALWD =  NEW_REFERENCES.WAITLIST_ALWD,
      SMLNES_WAITLIST_ALWD =  NEW_REFERENCES.SMLNES_WAITLIST_ALWD,
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
       x_INST_WAITLIST_ID IN OUT NOCOPY NUMBER,
       x_CAL_TYPE IN VARCHAR2,
       x_WAITLIST_ALWD IN VARCHAR2,
       x_SMLNES_WAITLIST_ALWD IN VARCHAR2,
      X_MODE in VARCHAR2
  ) AS
  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_EN_INST_WLST_OPT_ALL
             where     INST_WAITLIST_ID= X_INST_WAITLIST_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       x_org_id,
       X_INST_WAITLIST_ID,
       X_CAL_TYPE,
       X_WAITLIST_ALWD,
       X_SMLNES_WAITLIST_ALWD,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_INST_WAITLIST_ID,
       X_CAL_TYPE,
       X_WAITLIST_ALWD,
       X_SMLNES_WAITLIST_ALWD,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : ahemmige
  Date Created : 20-MAY-2000
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
 delete from IGS_EN_INST_WLST_OPT_ALL
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_en_inst_wlst_opt_pkg;

/
