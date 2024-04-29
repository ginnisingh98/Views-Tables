--------------------------------------------------------
--  DDL for Package Body IGS_PR_OU_PS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PR_OU_PS_PKG" as
/* $Header: IGSQI05B.pls 115.7 2003/02/25 09:11:31 anilk ship $ */
  l_rowid VARCHAR2(25);
  old_references IGS_PR_OU_PS_ALL%RowType;
  new_references IGS_PR_OU_PS_ALL%RowType;

  PROCEDURE Set_Column_Values (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_pro_sequence_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL ,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS

    CURSOR cur_old_ref_values IS
      SELECT   *
      FROM     IGS_PR_OU_PS_ALL
      WHERE    rowid = x_rowid;

  BEGIN

    l_rowid := x_rowid;

    -- Code for setting the Old and New Reference Values.
    -- Populate Old Values.
    Open cur_old_ref_values;
    Fetch cur_old_ref_values INTO old_references;
    IF (cur_old_ref_values%NOTFOUND) AND (p_action not in ('INSERT','VALIDATE_INSERT')) THEN
      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_old_ref_values;

    -- Populate New Values.
    new_references.progression_rule_cat := x_progression_rule_cat;
    new_references.pra_sequence_number := x_pra_sequence_number;
    new_references.pro_sequence_number := x_pro_sequence_number;
    new_references.course_cd := x_course_cd;
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


  PROCEDURE Check_Parent_Existance AS
  BEGIN

    IF (((old_references.course_cd = new_references.course_cd)) OR
        ((new_references.course_cd IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PS_COURSE_PKG.Get_PK_For_Validation (
        new_references.course_cd
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

    IF (((old_references.progression_rule_cat = new_references.progression_rule_cat) AND
         (old_references.pra_sequence_number = new_references.pra_sequence_number) AND
         (old_references.pro_sequence_number = new_references.pro_sequence_number)) OR
        ((new_references.progression_rule_cat IS NULL) OR
         (new_references.pra_sequence_number IS NULL) OR
         (new_references.pro_sequence_number IS NULL))) THEN
      NULL;
    ELSE
      IF NOT IGS_PR_RU_OU_PKG.Get_PK_For_Validation (
        new_references.progression_rule_cat,
        new_references.pra_sequence_number,
        new_references.pro_sequence_number
        ) THEN
        Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;
        App_Exception.Raise_Exception;
      END IF;
    END IF;

  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_pro_sequence_number IN NUMBER,
    x_course_cd IN VARCHAR2
    )  RETURN BOOLEAN AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_OU_PS_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_pra_sequence_number
      AND      pro_sequence_number = x_pro_sequence_number
      AND      course_cd = x_course_cd
      FOR UPDATE NOWAIT;

    lv_rowid cur_rowid%RowType;
BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
	Close Cur_rowid;
      Return(TRUE);
    ELSE
      Close cur_rowid;
      Return(FALSE);
    END IF;

  END Get_PK_For_Validation;

  PROCEDURE GET_FK_IGS_PS_COURSE (
    x_course_cd IN VARCHAR2
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_OU_PS_ALL
      WHERE    course_cd = x_course_cd ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS', 'IGS_PR_POC_CRS_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PS_COURSE;

  PROCEDURE GET_FK_IGS_PR_RU_OU (
    x_progression_rule_cat IN VARCHAR2,
    x_pra_sequence_number IN NUMBER,
    x_sequence_number IN NUMBER
    ) AS

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     IGS_PR_OU_PS_ALL
      WHERE    progression_rule_cat = x_progression_rule_cat
      AND      pra_sequence_number = x_pra_sequence_number
      AND      pro_sequence_number = x_sequence_number ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      Fnd_Message.Set_Name ('IGS','IGS_PR_POC_PRO_FK');
      IGS_GE_MSG_STACK.ADD;
      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;
    END IF;
    Close cur_rowid;

  END GET_FK_IGS_PR_RU_OU;

  PROCEDURE BeforeInsertUpdate( p_action VARCHAR2 ) AS
  /*
  ||  Created By : anilk
  ||  Created On : 25-FEB-2003
  ||  Known limitations, enhancements or remarks :
  ||  Change History :
  ||  Who             When            What
  ||  (reverse chronological order - newest change first)
  */
    CURSOR c_parent (
         cp_progression_rule_cat    IGS_PR_RU_OU.progression_rule_cat%TYPE,
         cp_pra_sequence_number     IGS_PR_RU_OU.pra_sequence_number%TYPE,
         cp_sequence_number         IGS_PR_RU_OU.sequence_number%TYPE  ) IS
     SELECT 1
     FROM   IGS_PR_RU_OU pro
     WHERE  pro.progression_rule_cat = cp_progression_rule_cat    AND
            pro.pra_sequence_number  = cp_pra_sequence_number AND
            pro.sequence_number      = cp_sequence_number     AND
            pro.logical_delete_dt is NULL;

    l_dummy NUMBER;

  BEGIN

   IF (p_action = 'INSERT') THEN
      OPEN c_parent( new_references.progression_rule_cat, new_references.pra_sequence_number, new_references.pro_sequence_number );
      FETCH c_parent INTO l_dummy;
      IF c_parent%NOTFOUND THEN
          CLOSE c_parent;
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
      END IF;
      CLOSE c_parent;
   ELSIF(p_action = 'UPDATE') THEN
      IF new_references.progression_rule_cat <> old_references.progression_rule_cat  OR
         new_references.pra_sequence_number <> old_references.pra_sequence_number  OR
         new_references.pro_sequence_number <> old_references.pro_sequence_number  THEN
        OPEN c_parent( new_references.progression_rule_cat,  new_references.pra_sequence_number, new_references.pro_sequence_number );
        FETCH c_parent INTO l_dummy;
        IF c_parent%NOTFOUND THEN
          CLOSE c_parent;
          FND_MESSAGE.SET_NAME('FND', 'FORM_RECORD_DELETED');
          IGS_GE_MSG_STACK.ADD;
          APP_EXCEPTION.RAISE_EXCEPTION;
        END IF;
        CLOSE c_parent;
      END IF;
   END IF;

  END BeforeInsertUpdate;

	PROCEDURE Before_DML (
    p_action IN VARCHAR2,
    x_rowid IN VARCHAR2 DEFAULT NULL,
    x_progression_rule_cat IN VARCHAR2 DEFAULT NULL,
    x_pra_sequence_number IN NUMBER DEFAULT NULL,
    x_pro_sequence_number IN NUMBER DEFAULT NULL,
    x_course_cd IN VARCHAR2 DEFAULT NULL,
    x_creation_date IN DATE DEFAULT NULL,
    x_created_by IN NUMBER DEFAULT NULL,
    x_last_update_date IN DATE DEFAULT NULL,
    x_last_updated_by IN NUMBER DEFAULT NULL,
    x_last_update_login IN NUMBER DEFAULT NULL,
    x_org_id IN NUMBER DEFAULT NULL
  ) AS
  BEGIN

    Set_Column_Values (
      p_action,
      x_rowid,
      x_progression_rule_cat,
      x_pra_sequence_number,
      x_pro_sequence_number,
      x_course_cd,
      x_creation_date,
      x_created_by,
      x_last_update_date,
      x_last_updated_by,
      x_last_update_login ,
      x_org_id
    );

    IF (p_action = 'INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation (
         new_references.progression_rule_cat,
         new_references.pra_sequence_number,
         new_references.pro_sequence_number,
         new_references.course_cd
         ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
      Check_Parent_Existance;
    ELSIF (p_action = 'VALIDATE_INSERT') THEN
      -- Call all the procedures related to Before Insert.
	IF Get_PK_For_Validation (
         new_references.progression_rule_cat,
         new_references.pra_sequence_number,
         new_references.pro_sequence_number,
         new_references.course_cd
         ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
      IGS_GE_MSG_STACK.ADD;
         App_Exception.Raise_Exception;
      END IF;
      Check_Constraints;
    ELSIF (p_action = 'VALIDATE_UPDATE') THEN
      -- Call all the procedures related to Before Update.
      Check_Constraints;
    END IF;

    -- anilk, bug#2784198
    BeforeInsertUpdate(p_action);

  END Before_DML;

procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRO_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_MODE in VARCHAR2 default 'R',
  X_ORG_ID in NUMBER
  ) as
    cursor C is select ROWID from IGS_PR_OU_PS_ALL
      where PROGRESSION_RULE_CAT = X_PROGRESSION_RULE_CAT
      and PRA_SEQUENCE_NUMBER = X_PRA_SEQUENCE_NUMBER
      and PRO_SEQUENCE_NUMBER = X_PRO_SEQUENCE_NUMBER
      and COURSE_CD = X_COURSE_CD;
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

Before_DML (
    p_action => 'INSERT',
    x_rowid => x_rowid,
    x_progression_rule_cat => x_progression_rule_cat,
    x_pra_sequence_number => x_pra_sequence_number,
    x_pro_sequence_number => x_pro_sequence_number,
    x_course_cd => x_course_cd,
    x_creation_date => x_last_update_date,
    x_created_by => x_last_updated_by,
    x_last_update_date => x_last_update_date,
    x_last_updated_by => x_last_updated_by,
    x_last_update_login => x_last_update_login,
    x_org_id => igs_ge_gen_003.get_org_id
  );

  insert into IGS_PR_OU_PS_ALL (
    PROGRESSION_RULE_CAT,
    PRA_SEQUENCE_NUMBER,
    PRO_SEQUENCE_NUMBER,
    COURSE_CD,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,
    ORG_ID
  ) values (
    NEW_REFERENCES.PROGRESSION_RULE_CAT,
    NEW_REFERENCES.PRA_SEQUENCE_NUMBER,
    NEW_REFERENCES.PRO_SEQUENCE_NUMBER,
    NEW_REFERENCES.COURSE_CD,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,
    NEW_REFERENCES.ORG_ID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;
end INSERT_ROW;

procedure LOCK_ROW (
  X_ROWID in VARCHAR2,
  X_PROGRESSION_RULE_CAT in VARCHAR2,
  X_PRA_SEQUENCE_NUMBER in NUMBER,
  X_PRO_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2
) as
  cursor c1 is select
        rowid
    from IGS_PR_OU_PS_ALL
    Where ROWID = X_ROWID for update nowait;
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
  return;
end LOCK_ROW;

procedure DELETE_ROW (
  X_ROWID in VARCHAR2
) as
begin
Before_DML (
    p_action => 'DELETE',
    x_rowid => X_ROWID
  );

  delete from IGS_PR_OU_PS_ALL
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;


end DELETE_ROW;

PROCEDURE  Check_Constraints (
    Column_Name IN VARCHAR2 DEFAULT NULL,
    Column_Value IN VARCHAR2 DEFAULT NULL
) AS

BEGIN
IF Column_Name is null THEN
  NULL;
ELSIF upper(Column_name) = 'COURSE_CD' THEN
  new_references.COURSE_CD:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PROGRESSION_RULE_CAT' THEN
  new_references.PROGRESSION_RULE_CAT:= COLUMN_VALUE ;

ELSIF upper(Column_name) = 'PRO_SEQUENCE_NUMBER' THEN
  new_references.PRO_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

ELSIF upper(Column_name) = 'PRA_SEQUENCE_NUMBER' THEN
  new_references.PRA_SEQUENCE_NUMBER:= IGS_GE_NUMBER.to_num(COLUMN_VALUE) ;

END IF ;

IF upper(Column_name) = 'COURSE_CD' OR COLUMN_NAME IS NULL THEN
  IF new_references.COURSE_CD<> upper(new_references.COURSE_CD) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PROGRESSION_RULE_CAT' OR COLUMN_NAME IS NULL THEN
  IF new_references.PROGRESSION_RULE_CAT<> upper(new_references.PROGRESSION_RULE_CAT) then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRO_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRO_SEQUENCE_NUMBER < 1 or new_references.PRO_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;

IF upper(Column_name) = 'PRA_SEQUENCE_NUMBER' OR COLUMN_NAME IS NULL THEN
  IF new_references.PRA_SEQUENCE_NUMBER < 1 or new_references.PRA_SEQUENCE_NUMBER > 999999 then
    Fnd_Message.Set_Name('IGS','IGS_GE_INVALID_VALUE');
      IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception ;
  END IF;

END IF ;



END Check_Constraints;

end IGS_PR_OU_PS_PKG;

/
