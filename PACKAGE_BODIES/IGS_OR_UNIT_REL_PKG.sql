--------------------------------------------------------
--  DDL for Package Body IGS_OR_UNIT_REL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_OR_UNIT_REL_PKG" AS
 /* $Header: IGSOI14B.pls 115.9 2003/03/27 06:41:35 kpadiyar ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_OR_UNIT_REL%RowType;
  new_references IGS_OR_UNIT_REL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_parent_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_parent_start_dt IN DATE DEFAULT NULL,
    x_child_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_child_start_dt IN DATE DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_OR_UNIT_REL
      WHERE    rowid = x_rowid;
  BEGIN
    l_rowid := x_rowid;
    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN

       Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Close cur_old_ref_values;
      Return;
    END IF;
    Close cur_old_ref_values;
    -- Populate New Values.
    new_references.parent_org_unit_cd := x_parent_org_unit_cd;
    new_references.parent_start_dt := x_parent_start_dt;
    new_references.child_org_unit_cd := x_child_org_unit_cd;
    new_references.child_start_dt := x_child_start_dt;
    new_references.create_dt := x_create_dt;
    new_references.logical_delete_dt := x_logical_delete_dt;
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
  -- Trigger description :-
  -- "OSS_TST".trg_our_ar_i
  -- AFTER INSERT
  -- ON IGS_OR_UNIT_REL
  -- FOR EACH ROW

  PROCEDURE BeforeRowInsert1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name   VARCHAR2(30);
    CURSOR c_exists IS
       SELECT 'Y'
       FROM   IGS_OR_UNIT_REL
       WHERE  parent_org_unit_cd = new_references.parent_org_unit_cd
       AND    child_org_unit_cd = new_references.child_org_unit_cd
       AND    logical_delete_dt IS NULL;
    l_exists VARCHAR(1) := 'N';
  BEGIN
   IF p_inserting THEN
    OPEN c_exists;
    FETCH c_exists INTO l_exists;
    CLOSE c_exists;
     IF l_exists = 'Y' THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
     END IF;
   END IF;
  END BeforeRowInsert1;

  PROCEDURE AfterRowInsert1(
    p_inserting IN BOOLEAN DEFAULT FALSE,
    p_updating IN BOOLEAN DEFAULT FALSE,
    p_deleting IN BOOLEAN DEFAULT FALSE
    ) AS
	v_message_name   VARCHAR2(30);
	v_rowid_saved	BOOLEAN := FALSE;
  BEGIN
	-- Validate the org IGS_PS_UNIT relationship.
	 -- Save the rowid of the current row.
	v_rowid_saved := TRUE;
	-- Cannot call orgp_val_our because trigger may be mutating.
-- Pasted from Mutation Handling Validaton Trig
  		-- Validate org IGS_PS_UNIT relationship.
  		IF IGS_OR_VAL_OUR.orgp_val_our (New_References.parent_org_unit_cd,
  				New_References.parent_start_dt,
  				New_References.child_org_unit_cd,
  				New_References.child_start_dt,
  						v_message_name) = FALSE THEN
			Fnd_Message.Set_Name('IGS',v_message_name);
			IGS_GE_MSG_STACK.ADD;
			App_Exception.Raise_Exception ;
  		END IF;
  END AfterRowInsert1;
  -- Trigger description :-
  -- "OSS_TST".trg_our_as_i
  -- AFTER INSERT
  -- ON IGS_OR_UNIT_REL

  PROCEDURE Check_Parent_Existance AS
  BEGIN
    IF (((old_references.child_org_unit_cd = new_references.child_org_unit_cd) AND
         (old_references.child_start_dt = new_references.child_start_dt)) OR
        ((new_references.child_org_unit_cd IS NULL) OR
         (new_references.child_start_dt IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.child_org_unit_cd,
        new_references.child_start_dt
        )THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
	  END IF;
    END IF;
    IF (((old_references.parent_org_unit_cd = new_references.parent_org_unit_cd) AND
         (old_references.parent_start_dt = new_references.parent_start_dt)) OR
        ((new_references.parent_org_unit_cd IS NULL) OR
         (new_references.parent_start_dt IS NULL))) THEN
      NULL;
    ELSE
     IF NOT IGS_OR_UNIT_PKG.Get_PK_For_Validation (
        new_references.parent_org_unit_cd,
        new_references.parent_start_dt
        )THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;

	  END IF;
    END IF;
  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance AS
  BEGIN
    IGS_OR_REL_PS_TYPE_PKG.GET_FK_IGS_OR_UNIT_REL (
      old_references.parent_org_unit_cd,
      old_references.parent_start_dt,
      old_references.child_org_unit_cd,
      old_references.child_start_dt,
      old_references.create_dt
      );
  END Check_Child_Existance;

  PROCEDURE Check_Uniqueness AS
  BEGIN
    IF Get_PK_for_Validation (
      new_references.parent_org_unit_cd,
      new_references.parent_start_dt,
      new_references.child_org_unit_cd,
      new_references.child_start_dt,
      new_references.create_dt
      ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
    END IF ;
  END Check_Uniqueness;


  FUNCTION Get_PK_For_Validation (
    x_parent_org_unit_cd IN VARCHAR2,
    x_parent_start_dt IN DATE,
    x_child_org_unit_cd IN VARCHAR2,
    x_child_start_dt IN DATE,
    x_create_dt IN DATE
    ) RETURN BOOLEAN AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_UNIT_REL
      WHERE    parent_org_unit_cd = x_parent_org_unit_cd
      AND      parent_start_dt = x_parent_start_dt
      AND      child_org_unit_cd = x_child_org_unit_cd
      AND      child_start_dt = x_child_start_dt
      AND      create_dt = x_create_dt
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
  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_OR_UNIT (
    x_org_unit_cd IN VARCHAR2,
    x_start_dt IN DATE
    ) AS
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_OR_UNIT_REL
      WHERE (   (child_org_unit_cd = x_org_unit_cd AND child_start_dt = x_start_dt)
      OR       (parent_org_unit_cd = x_org_unit_cd AND parent_start_dt = x_start_dt)) ;
    lv_rowid cur_rowid%RowType;
  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid	;
      Fnd_Message.Set_Name ('IGS', 'IGS_OR_OUR_OU_CHILD_FK');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;

      Return;
    END IF;
    Close cur_rowid;
  END GET_FK_IGS_OR_UNIT;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_parent_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_parent_start_dt IN DATE DEFAULT NULL,
    x_child_org_unit_cd IN VARCHAR2 DEFAULT NULL,
    x_child_start_dt IN DATE DEFAULT NULL,
    x_create_dt IN DATE DEFAULT NULL,
    x_logical_delete_dt IN DATE DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  BEGIN
    Set_Column_Values (
      p_action,
      x_rowid,
      x_parent_org_unit_cd,
      x_parent_start_dt,
      x_child_org_unit_cd,
      x_child_start_dt,
      x_create_dt,
      x_logical_delete_dt,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login
    );
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.

      Check_Parent_Existance;
      Check_Uniqueness;
      BeforeRowInsert1 ( p_inserting => TRUE );
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Parent_Existance;
    ELSIF (p_action = 'DELETE') THEN
      -- Call all the procedures related to Before Delete.
      Check_Child_Existance;

	ELSIF (p_action = 'VALIDATE_INSERT') THEN
      BeforeRowInsert1 ( p_inserting => TRUE );

	ELSIF (p_action = 'VALIDATE_UPDATE') THEN

       NULL;
	ELSIF (p_action = 'VALIDATE_DELETE') THEN

   Check_Child_Existance ;

    END IF;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) AS
  BEGIN
    l_rowid := x_rowid;
    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      AfterRowInsert1 ( p_inserting => TRUE );
    END IF;
  END After_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PARENT_ORG_UNIT_CD in VARCHAR2,
  X_PARENT_START_DT in DATE,
  X_CHILD_ORG_UNIT_CD in VARCHAR2,
  X_CHILD_START_DT in DATE,
  X_CREATE_DT in out NOCOPY DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_OR_UNIT_REL
      where PARENT_ORG_UNIT_CD = X_PARENT_ORG_UNIT_CD
      and PARENT_START_DT = X_PARENT_START_DT
      and CHILD_ORG_UNIT_CD = X_CHILD_ORG_UNIT_CD
      and CHILD_START_DT = X_CHILD_START_DT
      and CREATE_DT = NEW_REFERENCES.CREATE_DT;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
   x_child_org_unit_cd=>X_CHILD_ORG_UNIT_CD,
   x_child_start_dt=>X_CHILD_START_DT,
   x_create_dt=>NVL(X_CREATE_DT,SYSDATE),
   x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
   x_parent_org_unit_cd=>X_PARENT_ORG_UNIT_CD,
   x_parent_start_dt=>X_PARENT_START_DT,
   x_creation_date=>X_LAST_UPDATE_DATE,
   x_created_by=>X_LAST_UPDATED_BY,
   x_last_update_date=>X_LAST_UPDATE_DATE,
   x_last_updated_by=>X_LAST_UPDATED_BY,
   x_last_update_login=>X_LAST_UPDATE_LOGIN
   );
  insert into IGS_OR_UNIT_REL (
    PARENT_ORG_UNIT_CD,
    PARENT_START_DT,
    CHILD_ORG_UNIT_CD,
    CHILD_START_DT,
    CREATE_DT,
    LOGICAL_DELETE_DT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN
  ) values (
    NEW_REFERENCES.PARENT_ORG_UNIT_CD,
    NEW_REFERENCES.PARENT_START_DT,
    NEW_REFERENCES.CHILD_ORG_UNIT_CD,
    NEW_REFERENCES.CHILD_START_DT,
    NEW_REFERENCES.CREATE_DT,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN
  );
  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
  After_DML(
    p_action=>'INSERT',
    x_rowid=>X_ROWID
    );
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PARENT_ORG_UNIT_CD in VARCHAR2,
  X_PARENT_START_DT in DATE,
  X_CHILD_ORG_UNIT_CD in VARCHAR2,
  X_CHILD_START_DT in DATE,
  X_CREATE_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE
) AS
  cursor c1 is select
      LOGICAL_DELETE_DT
    from IGS_OR_UNIT_REL
    where ROWID = X_ROWID
    for update nowait ;
  tlinfo c1%rowtype;
begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    app_exception.raise_exception;
    close c1;
    return;
  end if;
  close c1;
      if ( ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
  ) then
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
    app_exception.raise_exception;
  end if;
  return;
end LOCK_ROW;

procedure UPDATE_ROW (
  X_ROWID in VARCHAR2,
  X_PARENT_ORG_UNIT_CD in VARCHAR2,
  X_PARENT_START_DT in DATE,
  X_CHILD_ORG_UNIT_CD in VARCHAR2,
  X_CHILD_START_DT in DATE,
  X_CREATE_DT in DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;
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
    FND_MESSAGE.SET_NAME('FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
   Before_DML(
    p_action=>'UPDATE',
    x_rowid=>X_ROWID,
    x_child_org_unit_cd=>X_CHILD_ORG_UNIT_CD,
    x_child_start_dt=>X_CHILD_START_DT,
    x_create_dt=>NVL(X_CREATE_DT,SYSDATE),
    x_logical_delete_dt=>X_LOGICAL_DELETE_DT,
    x_parent_org_unit_cd=>X_PARENT_ORG_UNIT_CD,
    x_parent_start_dt=>X_PARENT_START_DT,
    x_creation_date=>X_LAST_UPDATE_DATE,
    x_created_by=>X_LAST_UPDATED_BY,
    x_last_update_date=>X_LAST_UPDATE_DATE,
    x_last_updated_by=>X_LAST_UPDATED_BY,
    x_last_update_login=>X_LAST_UPDATE_LOGIN
    );
  update IGS_OR_UNIT_REL set
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
  where ROWID = X_ROWID ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
    p_action=>'UPDATE',
    x_rowid=>X_ROWID
    );
end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PARENT_ORG_UNIT_CD in VARCHAR2,
  X_PARENT_START_DT in DATE,
  X_CHILD_ORG_UNIT_CD in VARCHAR2,
  X_CHILD_START_DT in DATE,
  X_CREATE_DT in out NOCOPY DATE,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_OR_UNIT_REL
     where PARENT_ORG_UNIT_CD = X_PARENT_ORG_UNIT_CD
     and PARENT_START_DT = X_PARENT_START_DT
     and CHILD_ORG_UNIT_CD = X_CHILD_ORG_UNIT_CD
     and CHILD_START_DT = X_CHILD_START_DT
     and CREATE_DT = NVL(X_CREATE_DT,SYSDATE)
  ;
begin
  open c1;
  fetch c1 into X_ROWID ;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PARENT_ORG_UNIT_CD,
     X_PARENT_START_DT,
     X_CHILD_ORG_UNIT_CD,
     X_CHILD_START_DT,
     X_CREATE_DT,
     X_LOGICAL_DELETE_DT,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (
   X_ROWID,
   X_PARENT_ORG_UNIT_CD,
   X_PARENT_START_DT,
   X_CHILD_ORG_UNIT_CD,
   X_CHILD_START_DT,
   X_CREATE_DT,
   X_LOGICAL_DELETE_DT,
   X_MODE);
end ADD_ROW;

procedure DELETE_ROW (
    X_ROWID in VARCHAR2
    ) AS
begin
  Before_DML(
   p_action=>'DELETE',
   x_rowid=>X_ROWID
   );
  delete from IGS_OR_UNIT_REL
  where ROWID = X_ROWID ;
  if (sql%notfound) then
    raise no_data_found;
  end if;
  After_DML(
    p_action=>'DELETE',
    x_rowid=>X_ROWID
    );
end DELETE_ROW;

procedure Check_Constraints (
  Column_Name in VARCHAR2 DEFAULT NULL ,
  Column_Value in VARCHAR2 DEFAULT NULL
  ) AS
   /*----------------------------------------------------------------------------
  ||  Created By : pkpatel
  ||  Created On :
  ||  Purpose :
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  ||  pkpatel       29-JUL-2002     Bug No: 2461744
  ||                                Stuffed the procedure since the upper check on parent_org_unit_cd and child_org_unit_cd was removed
  ----------------------------------------------------------------------------*/
 BEGIN

IF Column_Name is null THEN
  NULL;
END IF ;

END Check_Constraints ;

end IGS_OR_UNIT_REL_PKG;

/
