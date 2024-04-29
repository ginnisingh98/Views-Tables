--------------------------------------------------------
--  DDL for Package Body IGS_PE_STD_TODO_REF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_STD_TODO_REF_PKG" AS
 /* $Header: IGSNI37B.pls 120.0 2005/06/01 19:04:50 appldev noship $ */


l_rowid VARCHAR2(25);

  old_references IGS_PE_STD_TODO_REF%RowType;

  new_references IGS_PE_STD_TODO_REF%RowType;



 PROCEDURE Set_Column_Values (

    p_action IN VARCHAR2,

    x_rowid IN VARCHAR2 DEFAULT NULL,

    x_person_id IN NUMBER DEFAULT NULL,

    x_s_student_todo_type IN VARCHAR2 DEFAULT NULL,

    x_sequence_number IN NUMBER DEFAULT NULL,

    x_reference_number IN NUMBER DEFAULT NULL,

    x_cal_type IN VARCHAR2 DEFAULT NULL,

    x_ci_sequence_number IN NUMBER DEFAULT NULL,

    x_course_cd IN VARCHAR2 DEFAULT NULL,

    x_unit_cd IN VARCHAR2 DEFAULT NULL,

    x_other_reference IN VARCHAR2 DEFAULT NULL,

    x_logical_delete_dt IN DATE DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,

    x_created_by IN NUMBER DEFAULT NULL,

    x_last_update_date IN DATE DEFAULT NULL,

    x_last_updated_by IN NUMBER DEFAULT NULL,

    x_last_update_login IN NUMBER DEFAULT NULL,

    x_uoo_id IN NUMBER DEFAULT NULL

  ) AS



    CURSOR cur_old_ref_values IS

      SELECT   *

      FROM     IGS_PE_STD_TODO_REF

      WHERE    rowid = x_rowid;



  BEGIN



    l_rowid := x_rowid;



    -- Code for setting the Old and New Reference Values.

    -- Populate Old Values.

    Open cur_old_ref_values;

    Fetch cur_old_ref_values INTO old_references;

    IF (cur_old_ref_values%NOTFOUND) AND (p_action NOT IN( 'INSERT','VALIDATE_INSERT')) THEN

      Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
      IGS_GE_MSG_STACK.ADD;


      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;

    END IF;

    Close cur_old_ref_values;



    -- Populate New Values.

    new_references.person_id := x_person_id;

    new_references.s_student_todo_type := x_s_student_todo_type;

    new_references.sequence_number := x_sequence_number;

    new_references.reference_number := x_reference_number;

    new_references.cal_type:= x_cal_type;

    new_references.ci_sequence_number := x_ci_sequence_number;

    new_references.course_cd := x_course_cd;

    new_references.unit_cd := x_unit_cd;

    new_references.other_reference := x_other_reference;

    new_references.logical_delete_dt := x_logical_delete_dt;

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
 Column_Name	IN	VARCHAR2	DEFAULT NULL,
 Column_Value 	IN	VARCHAR2	DEFAULT NULL
 )
 AS
 BEGIN
    IF  column_name is null then
     NULL;
ELSIF upper(Column_name) =  'CAL_TYPE' then
     new_references.cal_type:= column_value;
ELSIF upper(Column_name) =  'COURSE_CD' then
     new_references.course_cd:= column_value;
ELSIF upper(Column_name) =  'OTHER_REFERENCE' then
     new_references.other_reference:= column_value;
ELSIF upper(Column_name) =  'S_STUDENT_TODO_TYPE' then
     new_references.s_student_todo_type:= column_value;
ELSIF upper(Column_name) =  'UNIT_CD' then
     new_references.unit_cd:= column_value;
ELSIF upper(Column_name) =  'SEQUENCE_NUMBER' then
     new_references.sequence_number := IGS_GE_NUMBER.to_num(column_value);
ELSIF upper(Column_name) =  'CI_SEQUENCE_NUMBER' then
     new_references.ci_sequence_number :=IGS_GE_NUMBER.to_num(column_value);
ELSIF upper(Column_name) =  'REFERENCE_NUMBER' then
     new_references.reference_number := IGS_GE_NUMBER.to_num(column_value);

END IF;

IF upper(column_name) = 'CAL_TYPE' OR
     column_name is null Then
     IF  new_references.cal_type <>UPPER(new_references.cal_type )Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'COURSE_CD' OR
     column_name is null Then
     IF  new_references.course_cd <>UPPER(new_references.course_cd)Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;
IF upper(column_name) = 'OTHER_REFERENCE' OR
     column_name is null Then
     IF  new_references.other_reference <>UPPER(new_references.other_reference)Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
END IF;

IF upper(column_name) = 'S_STUDENT_TODO_TYPE' OR
     column_name is null Then
     IF new_references.s_student_todo_type <>UPPER(new_references.s_student_todo_type)Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
     END IF;
 END IF;
 IF upper(column_name) = 'UNIT_CD' OR
     column_name is null Then
     IF new_references.unit_cd <>UPPER(new_references.unit_cd ) Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
      END IF;
 END IF;

IF upper(column_name) = 'CI_SEQUENCE_NUMBER' OR
     column_name is null Then
     IF    new_references.ci_sequence_number < 1 OR new_references.ci_sequence_number > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;

-- remove check on reference number.

 END Check_Constraints;



  PROCEDURE Check_Parent_Existance AS

  BEGIN
    IF (((old_references.person_id = new_references.person_id) AND
         (old_references.s_student_todo_type = new_references.s_student_todo_type) AND
         (old_references.sequence_number = new_references.sequence_number)) OR
        ((new_references.person_id IS NULL) OR
         (new_references.s_student_todo_type IS NULL) OR
         (new_references.sequence_number IS NULL))) THEN
      NULL;

    ELSE
  IF  NOT IGS_PE_STD_TODO_PKG.Get_PK_For_Validation (
         new_references.person_id,
        new_references.s_student_todo_type,
        new_references.sequence_number ) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
 END IF;
    END IF;
  END Check_Parent_Existance;



  FUNCTION Get_PK_For_Validation (

    x_person_id IN NUMBER,

    x_s_student_todo_type IN VARCHAR2,

    x_sequence_number IN NUMBER,

    x_reference_number IN NUMBER

    ) RETURN BOOLEAN AS



    CURSOR cur_rowid IS

      SELECT   rowid

      FROM     IGS_PE_STD_TODO_REF

      WHERE    person_id = x_person_id

      AND      s_student_todo_type = x_s_student_todo_type

      AND      sequence_number = x_sequence_number

      AND      reference_number = x_reference_number

      FOR UPDATE NOWAIT;



    lv_rowid cur_rowid%RowType;



  BEGIN
    Open cur_rowid;
    Fetch cur_rowid INTO lv_rowid;
     IF (cur_rowid%FOUND) THEN
       Close cur_rowid;
       Return (TRUE);
 	ELSE
       Close cur_rowid;
       Return (FALSE);
 END IF;
  END Get_PK_For_Validation;



  PROCEDURE GET_FK_IGS_PE_STD_TODO (

    x_person_id IN NUMBER,

    x_s_student_todo_type IN VARCHAR2,

    x_sequence_number IN NUMBER

    ) AS



    CURSOR cur_rowid IS

      SELECT   rowid

      FROM     IGS_PE_STD_TODO_REF

      WHERE    person_id = x_person_id

      AND      s_student_todo_type = x_s_student_todo_type

      AND      sequence_number = x_sequence_number ;



    lv_rowid cur_rowid%RowType;



  BEGIN



    Open cur_rowid;

    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN

      Fnd_Message.Set_Name ('IGS', 'IGS_PE_STR_ST_FK');
      IGS_GE_MSG_STACK.ADD;


      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;

    END IF;

    Close cur_rowid;


  END GET_FK_IGS_PE_STD_TODO;



  PROCEDURE Before_DML (

    p_action IN VARCHAR2,

    x_rowid IN VARCHAR2 DEFAULT NULL,

    x_person_id IN NUMBER DEFAULT NULL,

    x_s_student_todo_type IN VARCHAR2 DEFAULT NULL,

    x_sequence_number IN NUMBER DEFAULT NULL,

    x_reference_number IN NUMBER DEFAULT NULL,

    x_cal_type IN VARCHAR2 DEFAULT NULL,

    x_ci_sequence_number IN NUMBER DEFAULT NULL,

    x_course_cd IN VARCHAR2 DEFAULT NULL,

    x_unit_cd IN VARCHAR2 DEFAULT NULL,

    x_other_reference IN VARCHAR2 DEFAULT NULL,

    x_logical_delete_dt IN DATE DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,

    x_created_by IN NUMBER DEFAULT NULL,

    x_last_update_date IN DATE DEFAULT NULL,

    x_last_updated_by IN NUMBER DEFAULT NULL,

    x_last_update_login IN NUMBER DEFAULT NULL,

    x_uoo_id IN NUMBER DEFAULT NULL

  ) AS

  BEGIN



    Set_Column_Values (

      p_action,

      x_rowid,

      x_person_id,

      x_s_student_todo_type,

      x_sequence_number,

      x_reference_number,

      x_cal_type,

      x_ci_sequence_number,

      x_course_cd,

      x_unit_cd,

      x_other_reference,

      x_logical_delete_dt,

      x_creation_date,

      x_created_by,

      x_last_update_date,

      x_last_updated_by,

      x_last_update_login,

      x_uoo_id

    );



 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.

      IF  Get_PK_For_Validation (
          new_references.person_id ,
    new_references.s_student_todo_type ,
    new_references.sequence_number ,
    new_references.reference_number ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
      Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'UPDATE') THEN
       -- Call all the procedures related to Before Update.

       Check_Constraints; -- if procedure present
       Check_Parent_Existance; -- if procedure present

 ELSIF (p_action = 'DELETE') THEN
       -- Call all the procedures related to Before Delete.

       NULL;
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
      IF  Get_PK_For_Validation (
          new_references.person_id ,
    new_references.s_student_todo_type ,
    new_references.sequence_number ,
    new_references.reference_number ) THEN
         Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
         IGS_GE_MSG_STACK.ADD;
          App_Exception.Raise_Exception;
      END IF;

      Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN

       Check_Constraints; -- if procedure present

ELSIF (p_action = 'VALIDATE_DELETE') THEN
      NULL;
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

      Null;

    ELSIF (p_action = 'UPDATE') THEN

      -- Call all the procedures related to After Update.

      Null;

    ELSIF (p_action = 'DELETE') THEN

      -- Call all the procedures related to After Delete.

      Null;

    END IF;



  END After_DML;





--
procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_OTHER_REFERENCE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  ) AS
    cursor C is select ROWID from IGS_PE_STD_TODO_REF
      where PERSON_ID = X_PERSON_ID
      and S_STUDENT_TODO_TYPE = X_S_STUDENT_TODO_TYPE
      and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
      and REFERENCE_NUMBER = X_REFERENCE_NUMBER;
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;

    X_REQUEST_ID NUMBER;

    X_PROGRAM_ID NUMBER;

    X_PROGRAM_APPLICATION_ID NUMBER;

    X_PROGRAM_UPDATE_DATE DATE;
    gv_other_detail VARCHAR2(255);
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

    X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;



   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;

  if (X_REQUEST_ID = -1) then

     X_REQUEST_ID := NULL;

     X_PROGRAM_ID := NULL;

     X_PROGRAM_APPLICATION_ID := NULL;

     X_PROGRAM_UPDATE_DATE := NULL;

 else

     X_PROGRAM_UPDATE_DATE := SYSDATE;

 end if;
  else
    FND_MESSAGE.SET_NAME( 'FND', 'SYSTEM-INVALID ARGS');
    IGS_GE_MSG_STACK.ADD;
    app_exception.raise_exception;
  end if;



Before_DML(

 p_action=>'INSERT',

 x_rowid=>X_ROWID,

 x_cal_type=>X_CAL_TYPE,

 x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,

 x_course_cd=>X_COURSE_CD,

 x_logical_delete_dt=>X_LOGICAL_DELETE_DT,

 x_other_reference=>X_OTHER_REFERENCE,

 x_person_id=>X_PERSON_ID,

 x_reference_number=>X_REFERENCE_NUMBER,

 x_s_student_todo_type=>X_S_STUDENT_TODO_TYPE,

 x_sequence_number=>X_SEQUENCE_NUMBER,

 x_unit_cd=>X_UNIT_CD,

 x_creation_date=>X_LAST_UPDATE_DATE,

 x_created_by=>X_LAST_UPDATED_BY,

 x_last_update_date=>X_LAST_UPDATE_DATE,

 x_last_updated_by=>X_LAST_UPDATED_BY,

 x_last_update_login=>X_LAST_UPDATE_LOGIN,

 x_uoo_id=>X_UOO_ID

 );



  insert into IGS_PE_STD_TODO_REF (
    PERSON_ID,
    S_STUDENT_TODO_TYPE,
    SEQUENCE_NUMBER,
    REFERENCE_NUMBER,
    CAL_TYPE,
    CI_SEQUENCE_NUMBER,
    COURSE_CD,
    UNIT_CD,
    OTHER_REFERENCE,
    LOGICAL_DELETE_DT,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,

    REQUEST_ID,

    PROGRAM_ID,

    PROGRAM_APPLICATION_ID,

    PROGRAM_UPDATE_DATE,
    UOO_ID
  ) values (
    NEW_REFERENCES.PERSON_ID,
    NEW_REFERENCES.S_STUDENT_TODO_TYPE,
    NEW_REFERENCES.SEQUENCE_NUMBER,
    NEW_REFERENCES.REFERENCE_NUMBER,
    NEW_REFERENCES.CAL_TYPE,
    NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    NEW_REFERENCES.COURSE_CD,
    NEW_REFERENCES.UNIT_CD,
    NEW_REFERENCES.OTHER_REFERENCE,
    NEW_REFERENCES.LOGICAL_DELETE_DT,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,

    X_REQUEST_ID,

    X_PROGRAM_ID,

    X_PROGRAM_APPLICATION_ID,

    X_PROGRAM_UPDATE_DATE ,
    NEW_REFERENCES.UOO_ID
  );

  open c;
  fetch c into X_ROWID;
  if (c%notfound) then
    close c;
    raise no_data_found;
  end if;
  close c;


 After_DML(

  p_action => 'INSERT',

  x_rowid => X_ROWID

  );

EXCEPTION
	WHEN OTHERS THEN
		 Fnd_Message.Set_Name('IGS', 'IGS_GE_UNHANDLED_EXCEPTION');
		 IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;

end INSERT_ROW;

procedure LOCK_ROW (

  X_ROWID in VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_OTHER_REFERENCE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_UOO_ID in NUMBER
) AS
  cursor c1 is select
      CAL_TYPE,
      CI_SEQUENCE_NUMBER,
      COURSE_CD,
      UNIT_CD,
      OTHER_REFERENCE,
      LOGICAL_DELETE_DT,
      UOO_ID
    from IGS_PE_STD_TODO_REF
    where ROWID = X_ROWID
    for update nowait;
  tlinfo c1%rowtype;

begin
  open c1;
  fetch c1 into tlinfo;
  if (c1%notfound) then
    fnd_message.set_name('FND', 'FORM_RECORD_DELETED');
    close c1;
    App_Exception.Raise_Exception;
    return;
  end if;
  close c1;

      if ( ((tlinfo.CAL_TYPE = X_CAL_TYPE)
           OR ((tlinfo.CAL_TYPE is null)
               AND (X_CAL_TYPE is null)))
      AND ((tlinfo.CI_SEQUENCE_NUMBER = X_CI_SEQUENCE_NUMBER)
           OR ((tlinfo.CI_SEQUENCE_NUMBER is null)
               AND (X_CI_SEQUENCE_NUMBER is null)))
      AND ((tlinfo.COURSE_CD = X_COURSE_CD)
           OR ((tlinfo.COURSE_CD is null)
               AND (X_COURSE_CD is null)))
      AND ((tlinfo.UNIT_CD = X_UNIT_CD)
           OR ((tlinfo.UNIT_CD is null)
               AND (X_UNIT_CD is null)))
      AND ((tlinfo.OTHER_REFERENCE = X_OTHER_REFERENCE)
           OR ((tlinfo.OTHER_REFERENCE is null)
               AND (X_OTHER_REFERENCE is null)))
      AND ((tlinfo.LOGICAL_DELETE_DT = X_LOGICAL_DELETE_DT)
           OR ((tlinfo.LOGICAL_DELETE_DT is null)
               AND (X_LOGICAL_DELETE_DT is null)))
     AND ((tlinfo.UOO_ID = X_UOO_ID)
           OR ((tlinfo.UOO_ID is null)
               AND (X_UOO_ID is null)))

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
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_OTHER_REFERENCE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  ) AS
    X_LAST_UPDATE_DATE DATE;
    X_LAST_UPDATED_BY NUMBER;
    X_LAST_UPDATE_LOGIN NUMBER;

    X_REQUEST_ID NUMBER;

    X_PROGRAM_ID NUMBER;

    X_PROGRAM_APPLICATION_ID NUMBER;

    X_PROGRAM_UPDATE_DATE DATE;
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

--



  Before_DML(

   p_action=>'UPDATE',

   x_rowid=>X_ROWID,

   x_cal_type=>X_CAL_TYPE,

   x_ci_sequence_number=>X_CI_SEQUENCE_NUMBER,

   x_course_cd=>X_COURSE_CD,

   x_logical_delete_dt=>X_LOGICAL_DELETE_DT,

   x_other_reference=>X_OTHER_REFERENCE,

   x_person_id=>X_PERSON_ID,

   x_reference_number=>X_REFERENCE_NUMBER,

   x_s_student_todo_type=>X_S_STUDENT_TODO_TYPE,

   x_sequence_number=>X_SEQUENCE_NUMBER,

   x_unit_cd=>X_UNIT_CD,

   x_creation_date=>X_LAST_UPDATE_DATE,

   x_created_by=>X_LAST_UPDATED_BY,

   x_last_update_date=>X_LAST_UPDATE_DATE,

   x_last_updated_by=>X_LAST_UPDATED_BY,

   x_last_update_login=>X_LAST_UPDATE_LOGIN,
   x_uoo_id=>X_UOO_ID


   );



--

if (X_MODE = 'R') then

   X_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;

   X_PROGRAM_ID := FND_GLOBAL.CONC_PROGRAM_ID;

   X_PROGRAM_APPLICATION_ID := FND_GLOBAL.PROG_APPL_ID;

  if (X_REQUEST_ID = -1) then

     X_REQUEST_ID := OLD_REFERENCES.REQUEST_ID;

     X_PROGRAM_ID := OLD_REFERENCES. PROGRAM_ID;

     X_PROGRAM_APPLICATION_ID :=

                OLD_REFERENCES.PROGRAM_APPLICATION_ID;

     X_PROGRAM_UPDATE_DATE :=

                  OLD_REFERENCES.PROGRAM_UPDATE_DATE;

 else

     X_PROGRAM_UPDATE_DATE := SYSDATE;



 end if;



end if;



  update IGS_PE_STD_TODO_REF set
    CAL_TYPE = NEW_REFERENCES.CAL_TYPE,
    CI_SEQUENCE_NUMBER = NEW_REFERENCES.CI_SEQUENCE_NUMBER,
    COURSE_CD = NEW_REFERENCES.COURSE_CD,
    UNIT_CD = NEW_REFERENCES.UNIT_CD,
    OTHER_REFERENCE = NEW_REFERENCES.OTHER_REFERENCE,
    LOGICAL_DELETE_DT = NEW_REFERENCES.LOGICAL_DELETE_DT,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,

    REQUEST_ID = X_REQUEST_ID,

    PROGRAM_ID = X_PROGRAM_ID,

    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,

    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE,
    UOO_ID = NEW_REFERENCES.UOO_ID
  where ROWID = X_ROWID
  ;
  if (sql%notfound) then
    raise no_data_found;
  end if;


After_DML(

  p_action => 'UPDATE',

  x_rowid => X_ROWID

  );



end UPDATE_ROW;

procedure ADD_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_PERSON_ID in NUMBER,
  X_S_STUDENT_TODO_TYPE in VARCHAR2,
  X_SEQUENCE_NUMBER in NUMBER,
  X_REFERENCE_NUMBER in NUMBER,
  X_CAL_TYPE in VARCHAR2,
  X_CI_SEQUENCE_NUMBER in NUMBER,
  X_COURSE_CD in VARCHAR2,
  X_UNIT_CD in VARCHAR2,
  X_OTHER_REFERENCE in VARCHAR2,
  X_LOGICAL_DELETE_DT in DATE,
  X_MODE in VARCHAR2 default 'R',
  X_UOO_ID in NUMBER
  ) AS
  cursor c1 is select rowid from IGS_PE_STD_TODO_REF
     where PERSON_ID = X_PERSON_ID
     and S_STUDENT_TODO_TYPE = X_S_STUDENT_TODO_TYPE
     and SEQUENCE_NUMBER = X_SEQUENCE_NUMBER
     and REFERENCE_NUMBER = X_REFERENCE_NUMBER
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_PERSON_ID,
     X_S_STUDENT_TODO_TYPE,
     X_SEQUENCE_NUMBER,
     X_REFERENCE_NUMBER,
     X_CAL_TYPE,
     X_CI_SEQUENCE_NUMBER,
     X_COURSE_CD,
     X_UNIT_CD,
     X_OTHER_REFERENCE,
     X_LOGICAL_DELETE_DT,
     X_MODE,
     X_UOO_ID);
    return;
  end if;
  close c1;
  UPDATE_ROW (

   X_ROWID,
   X_PERSON_ID,
   X_S_STUDENT_TODO_TYPE,
   X_SEQUENCE_NUMBER,
   X_REFERENCE_NUMBER,
   X_CAL_TYPE,
   X_CI_SEQUENCE_NUMBER,
   X_COURSE_CD,
   X_UNIT_CD,
   X_OTHER_REFERENCE,
   X_LOGICAL_DELETE_DT,
   X_MODE,
   X_UOO_ID);
end ADD_ROW;

procedure DELETE_ROW (
 X_ROWID in VARCHAR2
) AS
begin



Before_DML(

  p_action => 'DELETE',

  x_rowid => X_ROWID

  );


  delete from IGS_PE_STD_TODO_REF
  where ROWID = X_ROWID;
  if (sql%notfound) then
    raise no_data_found;
  end if;



After_DML(

  p_action => 'DELETE',

  x_rowid => X_ROWID

  );
end DELETE_ROW;

end IGS_PE_STD_TODO_REF_PKG;

/
