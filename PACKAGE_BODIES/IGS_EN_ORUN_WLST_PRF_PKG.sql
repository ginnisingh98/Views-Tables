--------------------------------------------------------
--  DDL for Package Body IGS_EN_ORUN_WLST_PRF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_EN_ORUN_WLST_PRF_PKG" AS
/* $Header: IGSEI35B.pls 115.7 2002/11/28 23:40:14 nsidana ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_en_orun_wlst_prf%RowType;
  new_references igs_en_orun_wlst_prf%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_wlst_prf_id IN NUMBER DEFAULT NULL,
    x_org_unit_wlst_pri_id IN NUMBER DEFAULT NULL,
    x_preference_order IN NUMBER DEFAULT NULL,
    x_preference_code IN VARCHAR2 DEFAULT NULL,
    x_preference_version IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_EN_ORUN_WLST_PRF
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
    new_references.org_unit_wlst_prf_id := x_org_unit_wlst_prf_id;
    new_references.org_unit_wlst_pri_id := x_org_unit_wlst_pri_id;
    new_references.preference_order := x_preference_order;
    new_references.preference_code := x_preference_code;
    new_references.preference_version := x_preference_version;
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
  Date Created on : 26-MAY-2000
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

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.org_unit_wlst_pri_id = new_references.org_unit_wlst_pri_id)) OR
        ((new_references.org_unit_wlst_pri_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_En_Orun_Wlst_Pri_Pkg.Get_PK_For_Validation (
        		new_references.org_unit_wlst_pri_id
        )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_org_unit_wlst_prf_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_orun_wlst_prf
      WHERE    org_unit_wlst_prf_id = x_org_unit_wlst_prf_id
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

  PROCEDURE Get_FK_Igs_En_Or_Unit_Wlst_Pri (
    x_org_unit_wlst_pri_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_orun_wlst_prf
      WHERE    org_unit_wlst_pri_id = x_org_unit_wlst_pri_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_EN_OUWPR_OUWP_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_FK_Igs_En_Or_Unit_Wlst_Pri;
  PROCEDURE check_uniqueness AS
  /*
  ||  Created By : Navin
  ||  Created On : 26-SEP-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Navin           26-SEP-2001     Created this function as part of
  ||				      fixing Bug# : 2005616
  ||  (reverse chronological order - newest change first)
  */
  BEGIN

    IF ( get_uk_for_validation (
           new_references.org_unit_wlst_pri_id,
           new_references.preference_code,
           new_references.preference_version
         )
       ) THEN
      fnd_message.set_name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END check_uniqueness;

  FUNCTION get_uk_for_validation (
    x_org_unit_wlst_pri_id              IN     NUMBER,
    x_preference_code                   IN     VARCHAR2,
    x_preference_version                IN     VARCHAR2
  ) RETURN BOOLEAN AS
  /*
  ||  Created By : Navin
  ||  Created On : 26-SEP-2001
  ||  Purpose : Validates the Unique Keys of the table.
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  Navin           26-SEP-2001     Created this function as part of
  ||				      fixing Bug# : 2005616
  ||  (reverse chronological order - newest change first)
  */

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_en_orun_wlst_prf
      WHERE    org_unit_wlst_pri_id = x_org_unit_wlst_pri_id
      AND      preference_code = x_preference_code
      AND      NVL(preference_version,'*') = NVL(x_preference_version,'*')
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

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_org_unit_wlst_prf_id IN NUMBER DEFAULT NULL,
    x_org_unit_wlst_pri_id IN NUMBER DEFAULT NULL,
    x_preference_order IN NUMBER DEFAULT NULL,
    x_preference_code IN VARCHAR2 DEFAULT NULL,
    x_preference_version IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  Who             When            What
  Navin           26-SEP-2001     Added the calls to Check_uniqueness as part of
  			          fixing Bug# : 2005616

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_org_unit_wlst_prf_id,
      x_org_unit_wlst_pri_id,
      x_preference_order,
      x_preference_code,
      x_preference_version,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	     IF Get_Pk_For_Validation(
    		new_references.org_unit_wlst_prf_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_uniqueness;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Null;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
	 -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
    		new_references.org_unit_wlst_prf_id)  THEN
	       Fnd_Message.Set_name('IGS','IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
	       App_Exception.Raise_Exception;
	     END IF;
      Check_uniqueness;
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
  Created By : smanglm
  Date Created on : 26-MAY-2000
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

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_ORG_UNIT_WLST_PRF_ID IN OUT NOCOPY NUMBER,
       x_ORG_UNIT_WLST_PRI_ID IN NUMBER,
       x_PREFERENCE_ORDER IN NUMBER,
       x_PREFERENCE_CODE IN VARCHAR2,
       x_PREFERENCE_VERSION IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_EN_ORUN_WLST_PRF
             where                 ORG_UNIT_WLST_PRF_ID= X_ORG_UNIT_WLST_PRF_ID
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
   SELECT IGS_EN_OR_UNIT_WLST_PRF_S.NEXTVAL
   INTO   x_org_unit_wlst_prf_id
   FROm   dual;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_org_unit_wlst_prf_id=>X_ORG_UNIT_WLST_PRF_ID,
 	       x_org_unit_wlst_pri_id=>X_ORG_UNIT_WLST_PRI_ID,
 	       x_preference_order=>X_PREFERENCE_ORDER,
 	       x_preference_code=>X_PREFERENCE_CODE,
 	       x_preference_version=>X_PREFERENCE_VERSION,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_EN_ORUN_WLST_PRF (
		ORG_UNIT_WLST_PRF_ID
		,ORG_UNIT_WLST_PRI_ID
		,PREFERENCE_ORDER
		,PREFERENCE_CODE
		,PREFERENCE_VERSION
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.ORG_UNIT_WLST_PRF_ID
	        ,NEW_REFERENCES.ORG_UNIT_WLST_PRI_ID
	        ,NEW_REFERENCES.PREFERENCE_ORDER
	        ,NEW_REFERENCES.PREFERENCE_CODE
	        ,NEW_REFERENCES.PREFERENCE_VERSION
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
       x_ORG_UNIT_WLST_PRF_ID IN NUMBER,
       x_ORG_UNIT_WLST_PRI_ID IN NUMBER,
       x_PREFERENCE_ORDER IN NUMBER,
       x_PREFERENCE_CODE IN VARCHAR2,
       x_PREFERENCE_VERSION IN VARCHAR2  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      ORG_UNIT_WLST_PRI_ID
,      PREFERENCE_ORDER
,      PREFERENCE_CODE
,      PREFERENCE_VERSION
    from IGS_EN_ORUN_WLST_PRF
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
if ( (  tlinfo.ORG_UNIT_WLST_PRI_ID = X_ORG_UNIT_WLST_PRI_ID)
  AND (tlinfo.PREFERENCE_ORDER = X_PREFERENCE_ORDER)
  AND (tlinfo.PREFERENCE_CODE = X_PREFERENCE_CODE)
  AND ((tlinfo.PREFERENCE_VERSION = X_PREFERENCE_VERSION)
 	    OR ((tlinfo.PREFERENCE_VERSION is null)
		AND (X_PREFERENCE_VERSION is null)))
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
       x_ORG_UNIT_WLST_PRF_ID IN NUMBER,
       x_ORG_UNIT_WLST_PRI_ID IN NUMBER,
       x_PREFERENCE_ORDER IN NUMBER,
       x_PREFERENCE_CODE IN VARCHAR2,
       x_PREFERENCE_VERSION IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
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
 	       x_org_unit_wlst_prf_id=>X_ORG_UNIT_WLST_PRF_ID,
 	       x_org_unit_wlst_pri_id=>X_ORG_UNIT_WLST_PRI_ID,
 	       x_preference_order=>X_PREFERENCE_ORDER,
 	       x_preference_code=>X_PREFERENCE_CODE,
 	       x_preference_version=>X_PREFERENCE_VERSION,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_EN_ORUN_WLST_PRF set
      ORG_UNIT_WLST_PRI_ID =  NEW_REFERENCES.ORG_UNIT_WLST_PRI_ID,
      PREFERENCE_ORDER =  NEW_REFERENCES.PREFERENCE_ORDER,
      PREFERENCE_CODE =  NEW_REFERENCES.PREFERENCE_CODE,
      PREFERENCE_VERSION =  NEW_REFERENCES.PREFERENCE_VERSION,
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
       x_ORG_UNIT_WLST_PRF_ID IN OUT NOCOPY NUMBER,
       x_ORG_UNIT_WLST_PRI_ID IN NUMBER,
       x_PREFERENCE_ORDER IN NUMBER,
       x_PREFERENCE_CODE IN VARCHAR2,
       x_PREFERENCE_VERSION IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
  Purpose : Creation of TBH
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_EN_ORUN_WLST_PRF
             where     ORG_UNIT_WLST_PRF_ID= X_ORG_UNIT_WLST_PRF_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_ORG_UNIT_WLST_PRF_ID,
       X_ORG_UNIT_WLST_PRI_ID,
       X_PREFERENCE_ORDER,
       X_PREFERENCE_CODE,
       X_PREFERENCE_VERSION,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_ORG_UNIT_WLST_PRF_ID,
       X_ORG_UNIT_WLST_PRI_ID,
       X_PREFERENCE_ORDER,
       X_PREFERENCE_CODE,
       X_PREFERENCE_VERSION,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : smanglm
  Date Created on : 26-MAY-2000
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
 delete from IGS_EN_ORUN_WLST_PRF
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_en_orun_wlst_prf_pkg;

/
