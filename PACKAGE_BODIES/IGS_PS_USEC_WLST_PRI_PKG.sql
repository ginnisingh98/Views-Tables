--------------------------------------------------------
--  DDL for Package Body IGS_PS_USEC_WLST_PRI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PS_USEC_WLST_PRI_PKG" AS
/* $Header: IGSPI0YB.pls 120.0 2005/06/01 16:01:10 appldev noship $ */
  l_rowid VARCHAR2(25);
  old_references igs_ps_usec_wlst_pri%RowType;
  new_references igs_ps_usec_wlst_pri%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_sec_wlst_priority_id IN NUMBER DEFAULT NULL,
    x_priority_number IN NUMBER DEFAULT NULL,
    x_priority_value IN VARCHAR2 DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PS_USEC_WLST_PRI
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    OPEN cur_old_ref_values;
    FETCH cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN ('INSERT','VALIDATE_INSERT')) THEN
      Close cur_old_ref_values;
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.unit_sec_waitlist_priority_id := x_unit_sec_wlst_priority_id;
    new_references.priority_number := x_priority_number;
    new_references.priority_value := x_priority_value;
    new_references.uoo_id := x_uoo_id;
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
  Created By : venagara
  Date Created By : 2000/05/12
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
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   BEGIN
     IF Get_Uk_For_Validation (
        new_references.priority_value
        ,new_references.uoo_id
        ) THEN
        Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
        IGS_GE_MSG_STACK.ADD;
        app_exception.raise_exception;
    END IF;
 END Check_Uniqueness;

  PROCEDURE Check_Parent_Existance AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    IF (((old_references.priority_value = new_references.priority_value)) OR
        ((new_references.priority_value IS NULL))) THEN
      NULL;
    ELSIF NOT igs_lookups_view_pkg.get_pk_for_validation('UNIT_WAITLIST',
        new_references.priority_value) THEN
       Fnd_Message.Set_Name('FND','FORM_RECORD_DELETED');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
    END IF;

    IF (((old_references.uoo_id = new_references.uoo_id)) OR
        ((new_references.uoo_id IS NULL))) THEN
      NULL;
    ELSIF NOT igs_ps_unit_ofr_opt_pkg.get_uk_for_validation(
                        new_references.uoo_id
        )  THEN
         Fnd_Message.Set_Name ('FND','FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
    END IF;

  END Check_Parent_Existance;

  PROCEDURE Check_Child_Existance IS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

  BEGIN

    Igs_Ps_Usec_Wlst_Prf_Pkg.Get_FK_Igs_Ps_Usec_Wlst_Pri (
      old_references.unit_sec_waitlist_priority_id
      );

  END Check_Child_Existance;

  FUNCTION Get_PK_For_Validation (
    x_unit_sec_wlst_priority_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_wlst_pri
      WHERE    unit_sec_waitlist_priority_id = x_unit_sec_wlst_priority_id
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
    x_priority_value IN VARCHAR2,
    x_uoo_id IN NUMBER
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_wlst_pri
      WHERE    priority_value = x_priority_value
      AND      uoo_id = x_uoo_id
      AND      ((l_rowid is null) or (rowid <> l_rowid)) ;
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

  PROCEDURE get_ufk_igs_ps_unit_ofr_opt (
    x_uoo_id IN NUMBER
    ) AS

  /*************************************************************
  Created By : schodava
  Date Created By : 12-Sep-2003
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_ps_usec_wlst_pri
      WHERE    uoo_id = x_uoo_id;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
      fnd_message.set_name('IGS', 'IGS_PS_USP_UOO_FK');
      igs_ge_msg_stack.add;
      app_exception.raise_exception;
      RETURN;
    END IF;
    CLOSE cur_rowid;

  END get_ufk_igs_ps_unit_ofr_opt;

  PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_unit_sec_wlst_priority_id IN NUMBER DEFAULT NULL,
    x_priority_number IN NUMBER DEFAULT NULL,
    x_priority_value IN VARCHAR2 DEFAULT NULL,
    x_uoo_id IN NUMBER DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
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
      x_unit_sec_wlst_priority_id,
      x_priority_number,
      x_priority_value,
      x_uoo_id,
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
                new_references.unit_sec_waitlist_priority_id)  THEN
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
                new_references.unit_sec_waitlist_priority_id)  THEN
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
    l_rowid := null;
  END Before_DML;

  PROCEDURE After_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2
  ) IS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
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

 PROCEDURE INSERT_ROW (
      X_ROWID in out NOCOPY VARCHAR2,
       x_unit_sec_wlst_priority_id IN OUT NOCOPY NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
       x_uoo_id IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR C IS
    SELECT ROWID
    FROM igs_ps_usec_wlst_pri
    WHERE unit_sec_waitlist_priority_id = x_unit_sec_wlst_priority_id;

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 BEGIN
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
     igs_ps_usec_wlst_pri_s.nextval
   INTO
     x_unit_sec_wlst_priority_id
   FROM dual;
   before_dml(p_action=>'INSERT',
               x_rowid=>x_rowid,
               x_unit_sec_wlst_priority_id=>x_unit_sec_wlst_priority_id,
               x_priority_number=>x_priority_number,
               x_priority_value=>x_priority_value,
               x_uoo_id => x_uoo_id,
               x_creation_date=>x_last_update_date,
               x_created_by=>x_last_updated_by,
               x_last_update_date=>x_last_update_date,
               x_last_updated_by=>x_last_updated_by,
               x_last_update_login=>x_last_update_login);
     INSERT INTO igs_ps_usec_wlst_pri (
                unit_sec_waitlist_priority_id
                ,priority_number
                ,priority_value
                ,uoo_id
                ,creation_date
                ,created_by
                ,last_update_date
                ,last_updated_by
                ,last_update_login
        ) VALUES  (
                new_references.unit_sec_waitlist_priority_id
                ,new_references.priority_number
                ,new_references.priority_value
                ,new_references.uoo_id
                ,x_last_update_date
                ,x_last_updated_by
                ,x_last_update_date
                ,x_last_updated_by
                ,x_last_update_login
        );
                OPEN c;
                FETCH c INTO X_ROWID;
                IF (c%NOTFOUND) then
                CLOSE c;
                RAISE no_data_found;
                END IF;
                CLOSE c;
    after_dml (
                p_action => 'INSERT' ,
                x_rowid =>  X_ROWID );
END insert_row;

 PROCEDURE lock_row (
      X_ROWID in  VARCHAR2,
       x_unit_sec_wlst_priority_id IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
       x_uoo_id IN NUMBER) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

   CURSOR c1 IS SELECT
      priority_number
,      priority_value
,      uoo_id
    FROM igs_ps_usec_wlst_pri
    WHERE ROWID = x_rowid
    FOR UPDATE NOWAIT;
     tlinfo c1%ROWTYPE;
BEGIN
  OPEN c1;
  FETCH c1 INTO tlinfo;
  if (c1%NOTFOUND) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
      igs_ge_msg_stack.add;
    CLOSE c1;
    app_exception.raise_exception;
    RETURN;
  END IF;
  CLOSE c1;
IF ( (  tlinfo.uoo_id = x_uoo_id)
  AND (tlinfo.priority_number = x_priority_number)
  AND (tlinfo.priority_value = x_priority_value)
  ) THEN
    null;
  else
    fnd_message.set_name('FND', 'FORM_RECORD_CHANGED');
      IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;
  return;
END lock_row;

 PROCEDURE update_row (
      X_ROWID in  VARCHAR2,
       x_unit_sec_wlst_priority_id IN NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
       x_uoo_id IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

     X_LAST_UPDATE_DATE DATE ;
     X_LAST_UPDATED_BY NUMBER ;
     X_LAST_UPDATE_LOGIN NUMBER ;
 BEGIN
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
        fnd_message.set_name('FND','SYSTEM-INVALID ARGS');
      IGS_GE_MSG_STACK.ADD;
          app_exception.raise_exception;
       end if;
   before_dml(
                p_action=>'UPDATE',
                x_rowid=>X_ROWID,
               x_unit_sec_wlst_priority_id=>x_unit_sec_wlst_priority_id,
               x_priority_number=>X_PRIORITY_NUMBER,
               x_priority_value=>X_PRIORITY_VALUE,
               x_uoo_id => x_uoo_id,
               x_creation_date=>X_LAST_UPDATE_DATE,
               x_created_by=>X_LAST_UPDATED_BY,
               x_last_update_date=>X_LAST_UPDATE_DATE,
               x_last_updated_by=>X_LAST_UPDATED_BY,
               x_last_update_login=>X_LAST_UPDATE_LOGIN);
   UPDATE IGS_PS_USEC_WLST_PRI set
      uoo_id = new_references.uoo_id,
      priority_number =  new_references.priority_number,
      priority_value =  new_references.priority_value,
        last_update_date = x_last_update_date,
        last_updated_by = x_last_updated_by,
        last_update_login = x_last_update_login
          where ROWID = X_ROWID;
        if (sql%NOTFOUND) then
                RAISE no_data_found;
        end if;

 After_DML (
        p_action => 'UPDATE' ,
        x_rowid => X_ROWID
        );
END update_row;

 PROCEDURE add_row (
      X_ROWID in out NOCOPY VARCHAR2,
       x_unit_sec_wlst_priority_id IN OUT NOCOPY NUMBER,
       x_PRIORITY_NUMBER IN NUMBER,
       x_PRIORITY_VALUE IN VARCHAR2,
       x_uoo_id IN NUMBER,
      X_MODE in VARCHAR2 default 'R'
  ) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
  Purpose :
  Know limitations, enhancements or remarks
  Change History
  Who             When            What

  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR c1 is select ROWID from IGS_PS_USEC_WLST_PRI
             where     UNIT_SEC_WAITLIST_PRIORITY_ID= x_unit_sec_wlst_priority_id
;
BEGIN
        open c1;
                fetch c1 into X_ROWID;
        if (c1%notfound) then
        close c1;
    insert_row (
      X_ROWID,
       x_unit_sec_wlst_priority_id,
       X_PRIORITY_NUMBER,
       X_PRIORITY_VALUE,
       x_uoo_id,
       X_MODE );
     return;
        end if;
           close c1;
update_row (
      X_ROWID,
       x_unit_sec_wlst_priority_id,
       X_PRIORITY_NUMBER,
       X_PRIORITY_VALUE,
       x_uoo_id,
      X_MODE );
end ADD_ROW;

PROCEDURE delete_row (
  X_ROWID in VARCHAR2
) AS
  /*************************************************************
  Created By : venagara
  Date Created By : 2000/05/12
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
 DELETE FROM
  igs_ps_usec_wlst_pri
 WHERE ROWID = x_rowid;
  if (sql%notfound) THEN
    RAISE no_data_found;
  end if;
After_DML (
 p_action => 'DELETE',
 x_rowid => X_ROWID
);
end delete_row;

END igs_ps_usec_wlst_pri_pkg;

/
