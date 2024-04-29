--------------------------------------------------------
--  DDL for Package Body IGS_PE_DATA_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_DATA_GROUPS_PKG" AS
/* $Header: IGSNI60B.pls 120.1 2006/01/25 09:14:22 skpandey noship $ */
/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To create Table Handler
Know limitations, enhancements or remarks : None
Change History
Who             When            What


(reverse chronological order - newest change first)
********************************************************/

  l_rowid VARCHAR2(25);
  old_references igs_pe_data_groups_all%RowType;
  new_references igs_pe_data_groups_all%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_data_group_id IN NUMBER DEFAULT NULL,
    x_data_group IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_lvl IN VARCHAR2 DEFAULT NULL,
    x_lvl_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER default NULL
  ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To Set Column Values
Know limitations, enhancements or remarks : None
Change History
Who             When            What


(reverse chronological order - newest change first)
********************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     igs_pe_data_groups_all
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
    new_references.data_group_id := x_data_group_id;
    new_references.data_group := x_data_group;
    new_references.description := x_description;
    new_references.lvl := x_lvl;
    new_references.lvl_description := x_lvl_description;
    new_references.closed_ind := x_closed_ind;
    new_references.org_id := x_org_id;
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

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To Check Constraints
Know limitations, enhancements or remarks : None
Change History
Who             When            What


(reverse chronological order - newest chanfe first)
********************************************************/

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

     IF column_name IS NULL THEN
        NULL;
      ELSIF  UPPER(column_name) = 'LVL'  THEN
        new_references.lvl := column_value;
        NULL;
      END IF;

    -- The following code checks for check constraints on the Columns.
      IF Upper(Column_Name) = 'LVL' OR
        Column_Name IS NULL THEN
        IF NOT (new_references.lvl  IN (1,2,3,4,5))  THEN
           Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
          IGS_GE_MSG_STACK.ADD;
           App_Exception.Raise_Exception;
        END IF;
      END IF;


  END Check_Constraints;

   PROCEDURE Check_Uniqueness AS
/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To Check Constraints
Know limitations, enhancements or remarks : None
Change History
Who             When            What


(reverse chronological order - newest chanfe first)
********************************************************/
   Begin
        IF Get_Uk_For_Validation (
        new_references.data_group
        ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
        IGS_GE_MSG_STACK.ADD;
        app_exception.raise_exception;
        END IF;
 END Check_Uniqueness ;

  FUNCTION Get_PK_For_Validation (
    x_data_group_id IN NUMBER
    ) RETURN BOOLEAN AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To enforce Primary Key validation
Know limitations, enhancements or remarks : None
Change History
Who             When            What
skpandey        24-JAN-2006     Bug#3686681: Full table scan Issue. Removed Upper to optimize query.
(reverse chronological order - newest change first)
********************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_data_groups_all
      WHERE    data_group_id = UPPER(X_data_group_id);

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
    x_data_group IN VARCHAR2
    ) RETURN BOOLEAN AS
/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To enforce Primary Key validation
Know limitations, enhancements or remarks : None
Change History
Who             When            What


(reverse chronological order - newest chanfe first)
********************************************************/
    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_data_groups_all
      WHERE    data_group = x_data_group
      and      ((l_rowid is null) or (rowid <> l_rowid));

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Close cur_rowid;
        Return (TRUE);
        ELSE
       close cur_rowid;
      return(false);
    END IF;
  END Get_UK_For_Validation ;

FUNCTION val_data_group(p_data_group_id IN NUMBER ,
                        p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
   v_closed_ind  igs_pe_data_groups_all.closed_ind%TYPE;
   CURSOR  c_get_closed_ind ( cp_data_group igs_pe_data_groups_all.data_group_id%TYPE) IS
   SELECT  closed_ind
   FROM    igs_pe_data_groups_all
   WHERE   data_group_id = cp_data_group;

BEGIN
   p_message_name := NULL;
   OPEN c_get_closed_ind(p_data_group_id);
   FETCH c_get_closed_ind INTO v_closed_ind;
   IF (c_get_closed_ind%NOTFOUND) THEN
      CLOSE c_get_closed_ind;
      RETURN TRUE;
   END IF;
   CLOSE c_get_closed_ind;
   IF (v_closed_ind = 'Y') THEN
      p_message_name := 'IGS_PE_DATA_CLOSED';
      RETURN FALSE;
   END IF;
   RETURN TRUE;
END val_data_group;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_data_group_id IN NUMBER DEFAULT NULL,
    x_data_group IN VARCHAR2 DEFAULT NULL,
    x_description IN VARCHAR2 DEFAULT NULL,
    x_lvl IN VARCHAR2 DEFAULT NULL,
    x_lvl_description IN VARCHAR2 DEFAULT NULL,
    x_closed_ind IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    X_ORG_ID in NUMBER default NULL
  ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To check Before DML
Know limitations, enhancements or remarks : None
Change History
Who             When            What


(reverse chronological order - newest change first)
 asbala          18-JUL-03        2885709, made l_rowid := null at the end of before_dml
********************************************************/

  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_data_group_id,
      x_data_group,
      x_description,
      x_lvl,
      x_lvl_description,
      x_closed_ind,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
      Null;
             IF Get_Pk_For_Validation(
                new_references.data_group_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
               IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Null;
      Check_Constraints;
      Check_Uniqueness;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
         -- Call all the procedures related to Before Insert.
      IF Get_PK_For_Validation (
                new_references.data_group_id)  THEN
               Fnd_Message.Set_name('IGS','IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
               App_Exception.Raise_Exception;
             END IF;
      Check_Constraints;

    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      Check_Constraints;

    END IF;
    l_rowid:=null;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To check After DML
Know limitations, enhancements or remarks : None
Change History
Who             When            What
asbala        21-JUL-03      2885709 Made l_rowid:=null in the end

(reverse chronological order - newest change first)
********************************************************/

  BEGIN

    l_rowid := x_rowid;

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to After Insert.
      Null;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to After Update.
      Null;
    END IF;

    l_rowid:=null;

  END After_DML;

 procedure INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_DATA_GROUP_ID IN OUT NOCOPY NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_LVL IN VARCHAR2,
       x_LVL_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To insert row
Know limitations, enhancements or remarks : None
Change History
Who             When            What


(reverse chronological order - newest chanfe first)
********************************************************/

    cursor C is select ROWID from igs_pe_data_groups_all
             where                 DATA_GROUP_ID= X_DATA_GROUP_ID
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

Select IGS_PE_DATA_GROUPS_S.NEXTVAL into X_DATA_GROUP_ID From Dual;

   Before_DML(
                p_action=>'INSERT',
                x_rowid=>X_ROWID,
               x_data_group_id=>X_DATA_GROUP_ID,
               x_data_group=>X_DATA_GROUP,
               x_description=>X_DESCRIPTION,
               x_lvl=>X_LVL,
               x_lvl_description=>X_LVL_DESCRIPTION,
               x_closed_ind=>X_CLOSED_IND,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN,
               x_org_id=>igs_ge_gen_003.get_org_id
);
     insert into igs_pe_data_groups_all (
                DATA_GROUP_ID
                ,DATA_GROUP
                ,DESCRIPTION
                ,LVL
                ,LVL_DESCRIPTION
                ,CLOSED_IND
                ,CREATION_DATE
                ,CREATED_BY
                ,LAST_UPDATE_DATE
                ,LAST_UPDATED_BY
                ,LAST_UPDATE_LOGIN,
                 ORG_ID
        ) values  (
                NEW_REFERENCES.DATA_GROUP_ID
                ,NEW_REFERENCES.DATA_GROUP
                ,NEW_REFERENCES.DESCRIPTION
                ,NEW_REFERENCES.LVL
                ,NEW_REFERENCES.LVL_DESCRIPTION
                ,NEW_REFERENCES.CLOSED_IND
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_DATE
                ,X_LAST_UPDATED_BY
                ,X_LAST_UPDATE_LOGIN,
              NEW_REFERENCES.ORG_ID
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
       x_DATA_GROUP_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_LVL IN VARCHAR2,
       x_LVL_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2
 )
       AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To Lock Row
Know limitations, enhancements or remarks : None
Change History
Who             When            What


(reverse chronological order - newest change first)
********************************************************/

   cursor c1 is select
      DATA_GROUP
,      DESCRIPTION
,      LVL
,      LVL_DESCRIPTION
,      CLOSED_IND
    from igs_pe_data_groups_all
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
if ( (  tlinfo.DATA_GROUP = X_DATA_GROUP)
  AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
  AND (tlinfo.LVL = X_LVL)
  AND (tlinfo.LVL_DESCRIPTION = X_LVL_DESCRIPTION)
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
       x_DATA_GROUP_ID IN NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_LVL IN VARCHAR2,
       x_LVL_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'
  ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To Update Row
Know limitations, enhancements or remarks : None
Change History
Who             When            What


(reverse chronological order - newest change first)
********************************************************/

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
               x_data_group_id=>X_DATA_GROUP_ID,
               x_data_group=>X_DATA_GROUP,
               x_description=>X_DESCRIPTION,
               x_lvl=>X_LVL,
               x_lvl_description=>X_LVL_DESCRIPTION,
               x_closed_ind=>X_CLOSED_IND,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN
);
   update igs_pe_data_groups_all set
      DATA_GROUP =  NEW_REFERENCES.DATA_GROUP,
      DESCRIPTION =  NEW_REFERENCES.DESCRIPTION,
      LVL =  NEW_REFERENCES.LVL,
      LVL_DESCRIPTION =  NEW_REFERENCES.LVL_DESCRIPTION,
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
       x_DATA_GROUP_ID IN OUT NOCOPY NUMBER,
       x_DATA_GROUP IN VARCHAR2,
       x_DESCRIPTION IN VARCHAR2,
       x_LVL IN VARCHAR2,
       x_LVL_DESCRIPTION IN VARCHAR2,
       x_CLOSED_IND IN VARCHAR2,
      X_MODE in VARCHAR2 default 'R'  ,
       X_ORG_ID in NUMBER
  ) AS

/******************************************************
Created By : nigupta
Date Created By : 11-MAY-2000
Purpose : To Add Row
Know limitations, enhancements or remarks : None
Change History
Who             When            What


(reverse chronological order - newest change first)
********************************************************/

    cursor c1 is select ROWID from igs_pe_data_groups_all
             where     DATA_GROUP_ID= X_DATA_GROUP_ID
;
begin
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    INSERT_ROW (
      X_ROWID,
       X_DATA_GROUP_ID,
       X_DATA_GROUP,
       X_DESCRIPTION,
       X_LVL,
       X_LVL_DESCRIPTION,
       X_CLOSED_IND,
      X_MODE,
      x_org_id
 );
     return;
        end if;
           close c1;
UPDATE_ROW (
      X_ROWID,
       X_DATA_GROUP_ID,
       X_DATA_GROUP,
       X_DESCRIPTION,
       X_LVL,
       X_LVL_DESCRIPTION,
       X_CLOSED_IND,
      X_MODE
);
end ADD_ROW;

END igs_pe_data_groups_pkg;

/
