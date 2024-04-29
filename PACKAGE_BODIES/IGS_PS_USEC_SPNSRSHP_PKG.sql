--------------------------------------------------------
--  DDL for Package Body IGS_PS_USEC_SPNSRSHP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_USEC_SPNSRSHP_PKG" AS
/* $Header: IGSPI1DB.pls 115.8 2003/03/21 08:04:56 sarakshi ship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_usec_spnsrshp%RowType;
  new_references igs_ps_usec_spnsrshp%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_section_sponsorship_id IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_organization_code IN VARCHAR2 DEFAULT NULL,
    x_sponsorship_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_USEC_SPNSRSHP
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
    new_references.unit_section_sponsorship_id := x_unit_section_sponsorship_id;
    new_references.uoo_id := x_uoo_id;
    new_references.organization_code := x_organization_code;
    new_references.sponsorship_percentage := x_sponsorship_percentage;
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
  Created By :         aiyer
  Date Created By :    12/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

      IF column_name IS NULL THEN
        NULL;
	ELSIF upper(column_name) = 'SPONSORSHIP_PERCENTAGE' THEN
	   new_references.sponsorship_percentage := igs_ge_number.to_num(column_value);
      END IF;

      IF upper(column_name)= 'SPONSORSHIP_PERCENTAGE' OR column_name is null THEN
	  IF (new_references.sponsorship_percentage not between 0 and 100) THEN
          Fnd_Message.Set_Name ('IGS', 'IGS_PS_SPNSRSHP_NOTBET_0_100');
          IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
        END IF;
	END IF;
 END Check_Constraints;

 PROCEDURE Check_Uniqueness AS
  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   begin
     		IF Get_Uk_For_Validation (
    		new_references.uoo_id,
            new_references.organization_code
    		) THEN
 		Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
      IGS_GE_MSG_STACK.ADD;
			app_exception.raise_exception;
    		END IF;
 END Check_Uniqueness ;
  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT Igs_Ps_Unit_Ofr_Opt_Pkg.Get_UK_For_Validation (
        		new_references.uoo_id
                )  THEN
	 Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
 	 App_Exception.Raise_Exception;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_section_sponsorship_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_spnsrshp
      WHERE    unit_section_sponsorship_id = x_unit_section_sponsorship_id
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
    x_uoo_id IN NUMBER,
    x_organization_code IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_spnsrshp
      WHERE    uoo_id = x_uoo_id and organization_code = x_organization_code	and      ((l_rowid is null) or (rowid <> l_rowid))

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
  PROCEDURE Get_UFK_Igs_Ps_Unit_Ofr_Opt (
    x_uoo_id IN NUMBER
    ) AS

  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_spnsrshp
      WHERE    uoo_id = x_uoo_id ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
      Fnd_Message.Set_Name ('IGS', 'IGS_PS_USPN_UOO_UFK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END Get_UFK_Igs_Ps_Unit_Ofr_Opt;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_section_sponsorship_id IN NUMBER DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_organization_code IN VARCHAR2 DEFAULT NULL,
    x_sponsorship_percentage IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
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
      x_unit_section_sponsorship_id,
      x_uoo_id,
      x_organization_code,
      x_sponsorship_percentage,
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
    		new_references.unit_section_sponsorship_id)  THEN
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
    		new_references.unit_section_sponsorship_id)  THEN
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

   l_rowid:=NULL;

  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
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

    l_rowid := null;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_UNIT_SECTION_SPONSORSHIP_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_ORGANIZATION_CODE IN VARCHAR2,
       x_SPONSORSHIP_PERCENTAGE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor C is select ROWID from IGS_PS_USEC_SPNSRSHP
             where                 UNIT_SECTION_SPONSORSHIP_ID= X_UNIT_SECTION_SPONSORSHIP_ID
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

       SELECT
       		IGS_PS_USEC_SPNSRSHP_S.NEXTVAL
       	INTO
       		x_UNIT_SECTION_SPONSORSHIP_ID

       	FROM
       		Dual;
   Before_DML(
 		p_action=>'INSERT',
 		x_rowid=>X_ROWID,
 	       x_unit_section_sponsorship_id=>X_UNIT_SECTION_SPONSORSHIP_ID,
 	       x_uoo_id=>X_UOO_ID,
 	       x_organization_code=>X_ORGANIZATION_CODE,
 	       x_sponsorship_percentage=>X_SPONSORSHIP_PERCENTAGE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
     insert into IGS_PS_USEC_SPNSRSHP (
		UNIT_SECTION_SPONSORSHIP_ID
		,UOO_ID
		,ORGANIZATION_CODE
		,SPONSORSHIP_PERCENTAGE
	        ,CREATION_DATE
		,CREATED_BY
		,LAST_UPDATE_DATE
		,LAST_UPDATED_BY
		,LAST_UPDATE_LOGIN
        ) values  (
	        NEW_REFERENCES.UNIT_SECTION_SPONSORSHIP_ID
	        ,NEW_REFERENCES.UOO_ID
	        ,NEW_REFERENCES.ORGANIZATION_CODE
	        ,NEW_REFERENCES.SPONSORSHIP_PERCENTAGE
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
       x_UNIT_SECTION_SPONSORSHIP_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_ORGANIZATION_CODE IN VARCHAR2,
       x_SPONSORSHIP_PERCENTAGE IN NUMBER  ) AS
  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   cursor c1 is select
      UOO_ID
,      ORGANIZATION_CODE
,      SPONSORSHIP_PERCENTAGE
    from IGS_PS_USEC_SPNSRSHP
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
if ( (  tlinfo.UOO_ID = X_UOO_ID)
  AND (tlinfo.ORGANIZATION_CODE = X_ORGANIZATION_CODE)
  AND (tlinfo.SPONSORSHIP_PERCENTAGE = X_SPONSORSHIP_PERCENTAGE)
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
       x_UNIT_SECTION_SPONSORSHIP_ID IN NUMBER,
       x_UOO_ID IN NUMBER,
       x_ORGANIZATION_CODE IN VARCHAR2,
       x_SPONSORSHIP_PERCENTAGE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
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
 	       x_unit_section_sponsorship_id=>X_UNIT_SECTION_SPONSORSHIP_ID,
 	       x_uoo_id=>X_UOO_ID,
 	       x_organization_code=>X_ORGANIZATION_CODE,
 	       x_sponsorship_percentage=>X_SPONSORSHIP_PERCENTAGE,
	       x_creation_date=>X_LAST_UPDATE_DATE,
	       x_created_by=>X_LAST_UPDATED_BY,
	       x_last_update_date=>X_LAST_UPDATE_DATE,
	       x_last_updated_by=>X_LAST_UPDATED_BY,
	       x_last_update_login=>X_LAST_UPDATE_LOGIN);
   update IGS_PS_USEC_SPNSRSHP set
      UOO_ID =  NEW_REFERENCES.UOO_ID,
      ORGANIZATION_CODE =  NEW_REFERENCES.ORGANIZATION_CODE,
      SPONSORSHIP_PERCENTAGE =  NEW_REFERENCES.SPONSORSHIP_PERCENTAGE,
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
       x_UNIT_SECTION_SPONSORSHIP_ID IN OUT NOCOPY NUMBER,
       x_UOO_ID IN NUMBER,
       x_ORGANIZATION_CODE IN VARCHAR2,
       x_SPONSORSHIP_PERCENTAGE IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    cursor c1 is select ROWID from IGS_PS_USEC_SPNSRSHP
             where     UNIT_SECTION_SPONSORSHIP_ID= X_UNIT_SECTION_SPONSORSHIP_ID
;
begin
	open c1;
		fetch c1 into X_ROWID;
	if (c1%notfound) then
	close c1;
    INSERT_ROW (
      X_ROWID,
       X_UNIT_SECTION_SPONSORSHIP_ID,
       X_UOO_ID,
       X_ORGANIZATION_CODE,
       X_SPONSORSHIP_PERCENTAGE,
      X_MODE );
     return;
	end if;
	   close c1;
UPDATE_ROW (
      X_ROWID,
       X_UNIT_SECTION_SPONSORSHIP_ID,
       X_UOO_ID,
       X_ORGANIZATION_CODE,
       X_SPONSORSHIP_PERCENTAGE,
      X_MODE );
end ADD_ROW;
procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By :         aiyer
  Date Created By :    12/May/2000
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
 delete from IGS_PS_USEC_SPNSRSHP
 where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end DELETE_ROW;
END igs_ps_usec_spnsrshp_pkg;

/
