--------------------------------------------------------
--  DDL for Package Body IGS_PE_PERSID_GROUP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGS_PE_PERSID_GROUP_PKG" AS
  /* $Header: IGSNI24B.pls 120.0 2005/06/01 20:06:40 appldev noship $ */

/*
  --------------------------------------------------------------------------------------
  -- Bug ID : 2204085
  -- who      when          what
  -- kpadiyar Mar 15,2002   Modified the lock row - Reverted back the lock row changes made
  --                        as the existing records shld be updatable.

  -------------------------------------------------------------------------------------------
  --------------------------------------------------------------------------------------
  -- Bug ID : 2203134 - NEED MORE UNIQUENESS ON IGS_PE_PERSID_GROUP_ALL
  -- who      when          what
  -- kpadiyar Mar 14,2002   Added Function get_uk_for_validation and check_uniqueness
  --                        for group_cd column

  -------------------------------------------------------------------------------------------

  --------------------------------------------------------------------------------------
  -- Bug ID : 2204085
  -- who      when          what
  -- kpadiyar Mar 14,2002   Modified the lock row - Removed the condition check for
  --                        Creator_person_id being null as this column is made not null

  -------------------------------------------------------------------------------------------

  --------------------------------------------------------------------------------------
  -- Bug ID : 2000408
  -- who      when          what
  -- CDCRUZ   Sep 24,2002   New Flex Fld Col's added for
  --                        Person DLD

  -------------------------------------------------------------------------------------------

Change History     : 1220935 bshankar 00/03/25
Procedure Affected : Lock_Row
Purpose            : Since the Creator_Person_Id column in the table has been made nullable, the check
                     in this procedure needs to be changed to prevent wrong locking.


*/

  l_rowid VARCHAR2(25);

  old_references IGS_PE_PERSID_GROUP_ALL%RowType;

  new_references IGS_PE_PERSID_GROUP_ALL%RowType;



  PROCEDURE Set_Column_Values (

    p_action IN VARCHAR2,

    x_rowid IN VARCHAR2 DEFAULT NULL,

    x_group_id IN NUMBER DEFAULT NULL,

    x_group_cd IN VARCHAR2 DEFAULT NULL,

    x_creator_person_id IN NUMBER DEFAULT NULL,

    x_description IN VARCHAR2 DEFAULT NULL,

    x_create_dt IN DATE DEFAULT NULL,

    x_closed_ind IN VARCHAR2 DEFAULT NULL,

    x_comments IN VARCHAR2 DEFAULT NULL,

  x_file_name           IN VARCHAR2 DEFAULT NULL,

  x_attribute_category  IN VARCHAR2 DEFAULT NULL,
  x_attribute1          IN VARCHAR2 DEFAULT NULL,
  x_attribute2          IN VARCHAR2 DEFAULT NULL,
  x_attribute3          IN VARCHAR2 DEFAULT NULL,
  x_attribute4          IN VARCHAR2 DEFAULT NULL,
  x_attribute5          IN VARCHAR2 DEFAULT NULL,
  x_attribute6          IN VARCHAR2 DEFAULT NULL,
  x_attribute7          IN VARCHAR2 DEFAULT NULL,
  x_attribute8          IN VARCHAR2 DEFAULT NULL,
  x_attribute9          IN VARCHAR2 DEFAULT NULL,
  x_attribute10         IN VARCHAR2 DEFAULT NULL,
  x_attribute11         IN VARCHAR2 DEFAULT NULL,
  x_attribute12         IN VARCHAR2 DEFAULT NULL,
  x_attribute13         IN VARCHAR2 DEFAULT NULL,
  x_attribute14         IN VARCHAR2 DEFAULT NULL,
  x_attribute15         IN VARCHAR2 DEFAULT NULL,
  x_attribute16         IN VARCHAR2 DEFAULT NULL,
  x_attribute17         IN VARCHAR2 DEFAULT NULL,
  x_attribute18         IN VARCHAR2 DEFAULT NULL,
  x_attribute19         IN VARCHAR2 DEFAULT NULL,
  x_attribute20         IN VARCHAR2 DEFAULT NULL,


    X_ORG_ID in NUMBER DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,

    x_created_by IN NUMBER DEFAULT NULL,

    x_last_update_date IN DATE DEFAULT NULL,

    x_last_updated_by IN NUMBER DEFAULT NULL,

    x_last_update_login IN NUMBER DEFAULT NULL

  ) AS



    CURSOR cur_old_ref_values IS

      SELECT   *

      FROM     IGS_PE_PERSID_GROUP_ALL

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

      Close cur_old_ref_values;
      App_Exception.Raise_Exception;
      Return;

    END IF;

    Close cur_old_ref_values;



    -- Populate New Values.

    new_references.group_id := x_group_id;

    new_references.group_cd := x_group_cd;

    new_references.creator_person_id := x_creator_person_id;

    new_references.description := x_description;

    new_references.create_dt := trunc(x_create_dt);

    new_references.closed_ind := x_closed_ind;

    new_references.comments := x_comments;

    new_references.org_id := x_org_id;

  new_references.file_name           := x_file_name ;

  new_references.attribute_category  := x_attribute_category ;
  new_references.attribute1          := x_attribute1 ;
  new_references.attribute2          := x_attribute2 ;
  new_references.attribute3          := x_attribute3 ;
  new_references.attribute4          := x_attribute4 ;
  new_references.attribute5          := x_attribute5 ;
  new_references.attribute6          := x_attribute6 ;
  new_references.attribute7          := x_attribute7 ;
  new_references.attribute8          := x_attribute8 ;
  new_references.attribute9          := x_attribute9 ;
  new_references.attribute10         := x_attribute10 ;
  new_references.attribute11         := x_attribute11 ;
  new_references.attribute12         := x_attribute12 ;
  new_references.attribute13         := x_attribute13 ;
  new_references.attribute14         := x_attribute14 ;
  new_references.attribute15         := x_attribute15 ;
  new_references.attribute16         := x_attribute16 ;
  new_references.attribute17         := x_attribute17 ;
  new_references.attribute18         := x_attribute18 ;
  new_references.attribute19         := x_attribute19 ;
  new_references.attribute20         := x_attribute20 ;

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
 Column_Name    IN      VARCHAR2        DEFAULT NULL,
 Column_Value   IN      VARCHAR2        DEFAULT NULL
 )
 AS
 BEGIN
    IF  column_name is null then
     NULL;
 ELSIF upper(Column_name) =  'GROUP_CD' then
     new_references.group_cd:= column_value;
 ELSIF upper(Column_name) = 'CLOSED_IND' then
     new_references.closed_ind := column_value;
 ELSIF upper(Column_name) = 'GROUP_ID' then
     new_references.group_id := IGS_GE_NUMBER.to_num(column_value);

 END IF;

IF upper(column_name) = 'GROUP_CD' OR
     column_name is null Then
     IF  new_references.group_cd <>UPPER(new_references.group_cd)Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;

 IF upper(column_name) = 'CLOSED_IND' OR
     column_name is null Then
     IF  new_references.closed_ind NOT IN ( 'Y' , 'N' )   Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
IF upper(column_name) = 'GROUP_ID' OR
     column_name is null Then
     IF    new_references.group_id < 1 OR new_references.group_id  > 999999 Then
       Fnd_Message.Set_Name ('IGS', 'IGS_GE_INVALID_VALUE');
       IGS_GE_MSG_STACK.ADD;
       App_Exception.Raise_Exception;
                   END IF;
              END IF;
 END Check_Constraints;

 PROCEDURE check_uniqueness AS
  /*************************************************************
  Created By : kpadiyar
  Date Created By : 14-MAR-2002
  Purpose : To check uniqueness for GROUP_CD column
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  kpadiyar        14-Mar-2002     Bug # 2203134 - to enforce uniqueness of group_cd column
  (reverse chronological order - newest change first)
  ***************************************************************/

   BEGIN
                IF get_uk_for_validation (
                                new_references.group_cd
                ) THEN
                Fnd_Message.Set_Name ('IGS', 'IGS_GE_RECORD_ALREADY_EXISTS');
                                IGS_GE_MSG_STACK.ADD;
                        app_exception.raise_exception;
                END IF;
 END Check_Uniqueness ;


  PROCEDURE Check_Parent_Existance AS

  BEGIN



    IF (((old_references.creator_person_id = new_references.creator_person_id)) OR

        ((new_references.creator_person_id IS NULL))) THEN

      NULL;

    ELSE
        IF  NOT IGS_PE_PERSON_PKG.Get_PK_For_Validation (
         new_references.creator_person_id) THEN
     Fnd_Message.Set_Name ('FND', 'FORM_RECORD_DELETED');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
        END IF;
    END IF;



  END Check_Parent_Existance;

  FUNCTION Get_PK_For_Validation (

    x_group_id IN NUMBER

    ) RETURN BOOLEAN AS



    CURSOR cur_rowid IS

      SELECT   rowid

      FROM     IGS_PE_PERSID_GROUP_ALL

      WHERE    group_id = x_group_id;



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

  FUNCTION get_uk_for_validation (
       x_group_cd           IN VARCHAR2
    ) RETURN BOOLEAN AS

  /*************************************************************
  Created By : kpadiyar
  Date Created By : 14-Mar-2002
  Purpose : To check for unqiueness of group_cd column Bug # 2203134
  Know limitations, enhancements or remarks
  Change History
  Who             When            What
  kpadiyar        14-Mar-2002     Bug # 2203134 - To enforce uniqueness on column group_cd
  (reverse chronological order - newest change first)
  ***************************************************************/

    CURSOR cur_rowid IS
      SELECT   rowid
      FROM     igs_pe_persid_group_all
      WHERE   group_cd = x_group_cd  AND
       ((l_rowid is null) or (rowid <> l_rowid))    ;

    lv_rowid cur_rowid%RowType;

  BEGIN

    OPEN cur_rowid;
    FETCH cur_rowid INTO lv_rowid;
    IF (cur_rowid%FOUND) THEN
      CLOSE cur_rowid;
        RETURN (true);
        ELSE
       CLOSE cur_rowid;
      RETURN(false);
    END IF;
  END get_uk_for_validation ;

FUNCTION val_persid_group(p_group_id IN NUMBER ,
                          p_message_name OUT NOCOPY VARCHAR2 )
RETURN BOOLEAN IS
   v_closed_ind  igs_pe_persid_group_all.closed_ind%TYPE;

   CURSOR  c_get_closed_ind ( cp_group_id  igs_pe_persid_group_all.group_id%TYPE) IS
   SELECT  closed_ind
   FROM    igs_pe_persid_group_all
   WHERE   group_id = cp_group_id;

BEGIN
   p_message_name := NULL;
   OPEN c_get_closed_ind(p_group_id);
   FETCH c_get_closed_ind INTO v_closed_ind;
   IF (c_get_closed_ind%NOTFOUND) THEN
      CLOSE c_get_closed_ind;
      RETURN TRUE;
   END IF;
      CLOSE c_get_closed_ind;
   IF (v_closed_ind = 'Y') THEN
      p_message_name := 'IGS_PE_PERSID_CLOSED';
      RETURN FALSE;
   END IF;
   RETURN TRUE;

END val_persid_group;


  PROCEDURE GET_FK_IGS_PE_PERSON (

    x_person_id IN NUMBER

    ) AS



    CURSOR cur_rowid IS

      SELECT   rowid

      FROM     IGS_PE_PERSID_GROUP_ALL

      WHERE    creator_person_id = x_person_id ;



    lv_rowid cur_rowid%RowType;



  BEGIN



    Open cur_rowid;

    Fetch cur_rowid INTO lv_rowid;

    IF (cur_rowid%FOUND) THEN

      Fnd_Message.Set_Name ('IGS', 'IGS_PE_PIG_PE_FK');

       IGS_GE_MSG_STACK.ADD;

      Close cur_rowid;
      App_Exception.Raise_Exception;
      Return;

    END IF;

    Close cur_rowid;



  END GET_FK_IGS_PE_PERSON;



  PROCEDURE Before_DML (

    p_action IN VARCHAR2,

    x_rowid IN  VARCHAR2 DEFAULT NULL,

    x_group_id IN NUMBER DEFAULT NULL,

    x_group_cd IN VARCHAR2 DEFAULT NULL,

    x_creator_person_id IN NUMBER DEFAULT NULL,

    x_description IN VARCHAR2 DEFAULT NULL,

    x_create_dt IN DATE DEFAULT NULL,

    x_closed_ind IN VARCHAR2 DEFAULT NULL,

    x_comments IN VARCHAR2 DEFAULT NULL,

  x_file_name           IN VARCHAR2 DEFAULT NULL,
  x_attribute_category  IN VARCHAR2 DEFAULT NULL,
  x_attribute1          IN VARCHAR2 DEFAULT NULL,
  x_attribute2          IN VARCHAR2 DEFAULT NULL,
  x_attribute3          IN VARCHAR2 DEFAULT NULL,
  x_attribute4          IN VARCHAR2 DEFAULT NULL,
  x_attribute5          IN VARCHAR2 DEFAULT NULL,
  x_attribute6          IN VARCHAR2 DEFAULT NULL,
  x_attribute7          IN VARCHAR2 DEFAULT NULL,
  x_attribute8          IN VARCHAR2 DEFAULT NULL,
  x_attribute9          IN VARCHAR2 DEFAULT NULL,
  x_attribute10         IN VARCHAR2 DEFAULT NULL,
  x_attribute11         IN VARCHAR2 DEFAULT NULL,
  x_attribute12         IN VARCHAR2 DEFAULT NULL,
  x_attribute13         IN VARCHAR2 DEFAULT NULL,
  x_attribute14         IN VARCHAR2 DEFAULT NULL,
  x_attribute15         IN VARCHAR2 DEFAULT NULL,
  x_attribute16         IN VARCHAR2 DEFAULT NULL,
  x_attribute17         IN VARCHAR2 DEFAULT NULL,
  x_attribute18         IN VARCHAR2 DEFAULT NULL,
  x_attribute19         IN VARCHAR2 DEFAULT NULL,
  x_attribute20         IN VARCHAR2 DEFAULT NULL,

    X_ORG_ID in NUMBER DEFAULT NULL,

    x_creation_date IN DATE DEFAULT NULL,

    x_created_by IN NUMBER DEFAULT NULL,

    x_last_update_date IN DATE DEFAULT NULL,

    x_last_updated_by IN NUMBER DEFAULT NULL,

    x_last_update_login IN NUMBER DEFAULT NULL

  ) AS
CURSOR is_creator_deceased IS SELECT deceased_ind FROM igs_pe_hz_parties WHERE party_id = x_creator_person_id;
CURSOR is_creator_too_young IS SELECT date_of_birth FROM HZ_PERSON_PROFILES where party_id = x_creator_person_id AND effective_end_date IS NULL;

l_deceased_ind IGS_PE_HZ_PARTIES.deceased_ind%TYPE;
l_date_of_birth HZ_PERSON_PROFILES.date_of_birth%TYPE;

BEGIN
  Set_Column_Values (

      p_action,

      x_rowid,

      x_group_id,

      x_group_cd,

      x_creator_person_id,

      x_description,

      x_create_dt,

      x_closed_ind,

      x_comments,

      x_file_name,

  x_attribute_category ,
  x_attribute1         ,
  x_attribute2         ,
  x_attribute3         ,
  x_attribute4         ,
  x_attribute5         ,
  x_attribute6         ,
  x_attribute7         ,
  x_attribute8         ,
  x_attribute9         ,
  x_attribute10        ,
  x_attribute11        ,
  x_attribute12        ,
  x_attribute13        ,
  x_attribute14        ,
  x_attribute15        ,
  x_attribute16        ,
  x_attribute17        ,
  x_attribute18        ,
  x_attribute19        ,
  x_attribute20        ,


      x_org_id,

      x_creation_date,

      x_created_by,

      x_last_update_date,

      x_last_updated_by,

      x_last_update_login

    );


 IF (p_action in ('INSERT','UPDATE')) THEN
  OPEN is_creator_deceased; FETCH is_creator_deceased INTO l_deceased_ind; CLOSE is_creator_deceased;
  IF(NVL(l_deceased_ind,'N')='Y')THEN
    Fnd_Message.Set_Name ('IGS', 'IGS_PE_CRT_PRSN_DECEASED');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
  END IF;
  OPEN is_creator_too_young; FETCH is_creator_too_young INTO l_date_of_birth; CLOSE is_creator_too_young;
  IF(l_date_of_birth IS NOT NULL AND l_date_of_birth > x_create_dt ) THEN
    Fnd_Message.Set_Name ('IGS', 'IGS_PE_DOB_LT_CRT_DT');
    IGS_GE_MSG_STACK.ADD;
    App_Exception.Raise_Exception;
  END IF;
 END IF;
 IF (p_action = 'INSERT') THEN
       -- Call all the procedures related to Before Insert.
   IF  Get_PK_For_Validation (
     new_references.group_id ) THEN
     Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
   END IF;
   check_uniqueness;
   Check_Constraints; -- if procedure present
   Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'UPDATE') THEN
 -- Call all the procedures related to Before Update.
   check_uniqueness;
   Check_Constraints; -- if procedure present
   Check_Parent_Existance; -- if procedure present
 ELSIF (p_action = 'VALIDATE_INSERT') THEN
   IF  Get_PK_For_Validation (
     new_references.group_id ) THEN
     Fnd_Message.Set_Name ('IGS', 'IGS_GE_MULTI_ORG_DUP_REC');
     IGS_GE_MSG_STACK.ADD;
     App_Exception.Raise_Exception;
   END IF;
   Check_Constraints; -- if procedure present
 ELSIF (p_action = 'VALIDATE_UPDATE') THEN
   check_uniqueness;
   Check_Constraints; -- if procedure present
 END IF;
 l_rowid := NULL;
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

    END IF;
    l_rowid := NULL;
  END After_DML;


procedure INSERT_ROW (
  X_ROWID in out NOCOPY VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_GROUP_CD in VARCHAR2,
  X_CREATOR_PERSON_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATE_DT in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_FILE_NAME           in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY  in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20         in      VARCHAR2 DEFAULT NULL,
  X_ORG_ID in NUMBER,
  X_MODE in VARCHAR2 default 'R'
  ) AS
    cursor C is select ROWID from IGS_PE_PERSID_GROUP_ALL
      where GROUP_ID = X_GROUP_ID;
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

  x_closed_ind=> NVL(X_CLOSED_IND,'N'),

  x_comments=>X_COMMENTS,

  x_create_dt=>X_CREATE_DT,

  x_creator_person_id=>X_CREATOR_PERSON_ID,

  x_description=>X_DESCRIPTION,

  x_group_cd=>X_GROUP_CD,

  x_group_id=>X_GROUP_ID,

  x_file_name          => X_FILE_NAME,
  x_attribute_category => X_ATTRIBUTE_CATEGORY,
  x_attribute1         => X_ATTRIBUTE1,
  x_attribute2         => X_ATTRIBUTE2,
  x_attribute3         => X_ATTRIBUTE3,
  x_attribute4         => X_ATTRIBUTE4,
  x_attribute5         => X_ATTRIBUTE5,
  x_attribute6         => X_ATTRIBUTE6,
  x_attribute7         => X_ATTRIBUTE7,
  x_attribute8         => X_ATTRIBUTE8,
  x_attribute9         => X_ATTRIBUTE9,
  x_attribute10        => X_ATTRIBUTE10,
  x_attribute11        => X_ATTRIBUTE11,
  x_attribute12        => X_ATTRIBUTE12,
  x_attribute13        => X_ATTRIBUTE13,
  x_attribute14        => X_ATTRIBUTE14,
  x_attribute15        => X_ATTRIBUTE15,
  x_attribute16        => X_ATTRIBUTE16,
  x_attribute17        => X_ATTRIBUTE17,
  x_attribute18        => X_ATTRIBUTE18,
  x_attribute19        => X_ATTRIBUTE19,
  x_attribute20        => X_ATTRIBUTE20,


  x_org_id => igs_ge_gen_003.get_org_id,

  x_creation_date=>X_LAST_UPDATE_DATE,

  x_created_by=>X_LAST_UPDATED_BY,

  x_last_update_date=>X_LAST_UPDATE_DATE,

  x_last_updated_by=>X_LAST_UPDATED_BY,

  x_last_update_login=>X_LAST_UPDATE_LOGIN

  );
  insert into IGS_PE_PERSID_GROUP_ALL (
    GROUP_ID,
    GROUP_CD,
    CREATOR_PERSON_ID,
    DESCRIPTION,
    CREATE_DT,
    CLOSED_IND,
    COMMENTS,
    FILE_NAME,
    ATTRIBUTE_CATEGORY,
    ATTRIBUTE1  ,
    ATTRIBUTE2  ,
    ATTRIBUTE3  ,
    ATTRIBUTE4  ,
    ATTRIBUTE5  ,
    ATTRIBUTE6  ,
    ATTRIBUTE7  ,
    ATTRIBUTE8  ,
    ATTRIBUTE9  ,
    ATTRIBUTE10 ,
    ATTRIBUTE11 ,
    ATTRIBUTE12 ,
    ATTRIBUTE13 ,
    ATTRIBUTE14 ,
    ATTRIBUTE15 ,
    ATTRIBUTE16 ,
    ATTRIBUTE17 ,
    ATTRIBUTE18 ,
    ATTRIBUTE19 ,
    ATTRIBUTE20 ,
    ORG_ID,
    CREATION_DATE,
    CREATED_BY,
    LAST_UPDATE_DATE,
    LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN,

    REQUEST_ID,

    PROGRAM_ID,

    PROGRAM_APPLICATION_ID,

    PROGRAM_UPDATE_DATE

  ) values (
    NEW_REFERENCES.GROUP_ID,
    NEW_REFERENCES.GROUP_CD,
    NEW_REFERENCES.CREATOR_PERSON_ID,
    NEW_REFERENCES.DESCRIPTION,
    NEW_REFERENCES.CREATE_DT,
    NEW_REFERENCES.CLOSED_IND,
    NEW_REFERENCES.COMMENTS,
    NEW_REFERENCES.FILE_NAME,
    NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    NEW_REFERENCES.ATTRIBUTE1  ,
    NEW_REFERENCES.ATTRIBUTE2  ,
    NEW_REFERENCES.ATTRIBUTE3  ,
    NEW_REFERENCES.ATTRIBUTE4  ,
    NEW_REFERENCES.ATTRIBUTE5  ,
    NEW_REFERENCES.ATTRIBUTE6  ,
    NEW_REFERENCES.ATTRIBUTE7  ,
    NEW_REFERENCES.ATTRIBUTE8  ,
    NEW_REFERENCES.ATTRIBUTE9  ,
    NEW_REFERENCES.ATTRIBUTE10 ,
    NEW_REFERENCES.ATTRIBUTE11 ,
    NEW_REFERENCES.ATTRIBUTE12 ,
    NEW_REFERENCES.ATTRIBUTE13 ,
    NEW_REFERENCES.ATTRIBUTE14 ,
    NEW_REFERENCES.ATTRIBUTE15 ,
    NEW_REFERENCES.ATTRIBUTE16 ,
    NEW_REFERENCES.ATTRIBUTE17 ,
    NEW_REFERENCES.ATTRIBUTE18 ,
    NEW_REFERENCES.ATTRIBUTE19 ,
    NEW_REFERENCES.ATTRIBUTE20 ,
    NEW_REFERENCES.ORG_ID,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_DATE,
    X_LAST_UPDATED_BY,
    X_LAST_UPDATE_LOGIN,

    X_REQUEST_ID,

    X_PROGRAM_ID,

    X_PROGRAM_APPLICATION_ID,

    X_PROGRAM_UPDATE_DATE
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
end INSERT_ROW;

procedure LOCK_ROW (

  X_ROWID in VARCHAR2,
  X_GROUP_ID in NUMBER,
  X_GROUP_CD in VARCHAR2,
  X_CREATOR_PERSON_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATE_DT in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_FILE_NAME           in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY  in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20         in      VARCHAR2 DEFAULT NULL
) AS
  cursor c1 is select
      GROUP_CD,
      CREATOR_PERSON_ID,
      DESCRIPTION,
      CREATE_DT,
      CLOSED_IND,
      COMMENTS,
      FILE_NAME,
      ATTRIBUTE_CATEGORY,
      ATTRIBUTE1,
      ATTRIBUTE2,
      ATTRIBUTE3,
      ATTRIBUTE4,
      ATTRIBUTE5,
      ATTRIBUTE6,
      ATTRIBUTE7,
      ATTRIBUTE8,
      ATTRIBUTE9,
      ATTRIBUTE10,
      ATTRIBUTE11,
      ATTRIBUTE12,
      ATTRIBUTE13,
      ATTRIBUTE14,
      ATTRIBUTE15,
      ATTRIBUTE16,
      ATTRIBUTE17,
      ATTRIBUTE18,
      ATTRIBUTE19,
      ATTRIBUTE20
    from IGS_PE_PERSID_GROUP_ALL
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

  if ((tlinfo.GROUP_CD = X_GROUP_CD)
      AND ((tlinfo.CREATOR_PERSON_ID = X_CREATOR_PERSON_ID)
                  OR ((tlinfo.CREATOR_PERSON_ID IS null)
                         AND (X_CREATOR_PERSON_ID IS null)))
      AND (tlinfo.DESCRIPTION = X_DESCRIPTION)
      AND (tlinfo.CREATE_DT = X_CREATE_DT)
      AND (tlinfo.CLOSED_IND = X_CLOSED_IND)
      AND ((tlinfo.COMMENTS = X_COMMENTS) OR ((tlinfo.COMMENTS is null) AND (X_COMMENTS is null)))
     AND (( tlinfo.FILE_NAME = X_FILE_NAME) OR (( tlinfo.FILE_NAME is null) AND (X_FILE_NAME is null)))
     AND (( tlinfo.ATTRIBUTE_CATEGORY = X_ATTRIBUTE_CATEGORY) OR (( tlinfo.ATTRIBUTE_CATEGORY is null) AND (X_ATTRIBUTE_CATEGORY is null)))
     AND (( tlinfo.ATTRIBUTE1 = X_ATTRIBUTE1) OR (( tlinfo.ATTRIBUTE1 is null) AND (X_ATTRIBUTE1 is null)))
     AND (( tlinfo.ATTRIBUTE2 = X_ATTRIBUTE2) OR (( tlinfo.ATTRIBUTE2 is null) AND (X_ATTRIBUTE2 is null)))
     AND (( tlinfo.ATTRIBUTE3 = X_ATTRIBUTE3) OR (( tlinfo.ATTRIBUTE3 is null) AND (X_ATTRIBUTE3 is null)))
     AND (( tlinfo.ATTRIBUTE4 = X_ATTRIBUTE4) OR (( tlinfo.ATTRIBUTE4 is null) AND (X_ATTRIBUTE4 is null)))
     AND (( tlinfo.ATTRIBUTE5 = X_ATTRIBUTE5) OR (( tlinfo.ATTRIBUTE5 is null) AND (X_ATTRIBUTE5 is null)))
     AND (( tlinfo.ATTRIBUTE6 = X_ATTRIBUTE6) OR (( tlinfo.ATTRIBUTE6 is null) AND (X_ATTRIBUTE6 is null)))
     AND (( tlinfo.ATTRIBUTE7 = X_ATTRIBUTE7) OR (( tlinfo.ATTRIBUTE7 is null) AND (X_ATTRIBUTE7 is null)))
     AND (( tlinfo.ATTRIBUTE8 = X_ATTRIBUTE8) OR (( tlinfo.ATTRIBUTE8 is null) AND (X_ATTRIBUTE8 is null)))
     AND (( tlinfo.ATTRIBUTE9 = X_ATTRIBUTE9) OR (( tlinfo.ATTRIBUTE9 is null) AND (X_ATTRIBUTE9 is null)))
     AND (( tlinfo.ATTRIBUTE10 = X_ATTRIBUTE10) OR (( tlinfo.ATTRIBUTE10 is null) AND (X_ATTRIBUTE10 is null)))
     AND (( tlinfo.ATTRIBUTE11 = X_ATTRIBUTE11) OR (( tlinfo.ATTRIBUTE11 is null) AND (X_ATTRIBUTE11 is null)))
     AND (( tlinfo.ATTRIBUTE12 = X_ATTRIBUTE12) OR (( tlinfo.ATTRIBUTE12 is null) AND (X_ATTRIBUTE12 is null)))
     AND (( tlinfo.ATTRIBUTE13 = X_ATTRIBUTE13) OR (( tlinfo.ATTRIBUTE13 is null) AND (X_ATTRIBUTE13 is null)))
     AND (( tlinfo.ATTRIBUTE14 = X_ATTRIBUTE14) OR (( tlinfo.ATTRIBUTE14 is null) AND (X_ATTRIBUTE14 is null)))
     AND (( tlinfo.ATTRIBUTE15 = X_ATTRIBUTE15) OR (( tlinfo.ATTRIBUTE15 is null) AND (X_ATTRIBUTE15 is null)))
     AND (( tlinfo.ATTRIBUTE16 = X_ATTRIBUTE16) OR (( tlinfo.ATTRIBUTE16 is null) AND (X_ATTRIBUTE16 is null)))
     AND (( tlinfo.ATTRIBUTE17 = X_ATTRIBUTE17) OR (( tlinfo.ATTRIBUTE17 is null) AND (X_ATTRIBUTE17 is null)))
     AND (( tlinfo.ATTRIBUTE18 = X_ATTRIBUTE18) OR (( tlinfo.ATTRIBUTE18 is null) AND (X_ATTRIBUTE18 is null)))
     AND (( tlinfo.ATTRIBUTE19 = X_ATTRIBUTE19) OR (( tlinfo.ATTRIBUTE19 is null) AND (X_ATTRIBUTE19 is null)))
     AND (( tlinfo.ATTRIBUTE20 = X_ATTRIBUTE20) OR (( tlinfo.ATTRIBUTE20 is null) AND (X_ATTRIBUTE20 is null)))

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
  X_GROUP_ID in NUMBER,
  X_GROUP_CD in VARCHAR2,
  X_CREATOR_PERSON_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATE_DT in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_FILE_NAME           in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE_CATEGORY  in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE1          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE2          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE3          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE4          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE5          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE6          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE7          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE8          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE9          in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE10         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE11         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE12         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE13         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE14         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE15         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE16         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE17         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE18         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE19         in      VARCHAR2 DEFAULT NULL,
  X_ATTRIBUTE20         in      VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
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

 Before_DML(

  p_action=>'UPDATE',

  x_rowid=>X_ROWID,

  x_closed_ind=>X_CLOSED_IND,

  x_comments=>X_COMMENTS,

  x_create_dt=>X_CREATE_DT,

  x_creator_person_id=>X_CREATOR_PERSON_ID,

  x_description=>X_DESCRIPTION,

  x_group_cd=>X_GROUP_CD,

  x_group_id=>X_GROUP_ID,

  x_file_name          => X_FILE_NAME,

  x_attribute_category => X_ATTRIBUTE_CATEGORY,
  x_attribute1         => X_ATTRIBUTE1,
  x_attribute2         => X_ATTRIBUTE2,
  x_attribute3         => X_ATTRIBUTE3,
  x_attribute4         => X_ATTRIBUTE4,
  x_attribute5         => X_ATTRIBUTE5,
  x_attribute6         => X_ATTRIBUTE6,
  x_attribute7         => X_ATTRIBUTE7,
  x_attribute8         => X_ATTRIBUTE8,
  x_attribute9         => X_ATTRIBUTE9,
  x_attribute10        => X_ATTRIBUTE10,
  x_attribute11        => X_ATTRIBUTE11,
  x_attribute12        => X_ATTRIBUTE12,
  x_attribute13        => X_ATTRIBUTE13,
  x_attribute14        => X_ATTRIBUTE14,
  x_attribute15        => X_ATTRIBUTE15,
  x_attribute16        => X_ATTRIBUTE16,
  x_attribute17        => X_ATTRIBUTE17,
  x_attribute18        => X_ATTRIBUTE18,
  x_attribute19        => X_ATTRIBUTE19,
  x_attribute20        => X_ATTRIBUTE20,


  x_creation_date=>X_LAST_UPDATE_DATE,

  x_created_by=>X_LAST_UPDATED_BY,

  x_last_update_date=>X_LAST_UPDATE_DATE,

  x_last_updated_by=>X_LAST_UPDATED_BY,

  x_last_update_login=>X_LAST_UPDATE_LOGIN

  );

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


  update IGS_PE_PERSID_GROUP_ALL set
    GROUP_CD = NEW_REFERENCES.GROUP_CD,
    CREATOR_PERSON_ID = NEW_REFERENCES.CREATOR_PERSON_ID,
    DESCRIPTION = NEW_REFERENCES.DESCRIPTION,
    CREATE_DT = NEW_REFERENCES.CREATE_DT,
    CLOSED_IND = NEW_REFERENCES.CLOSED_IND,
    COMMENTS = NEW_REFERENCES.COMMENTS,
    FILE_NAME = NEW_REFERENCES.FILE_NAME,
    ATTRIBUTE_CATEGORY = NEW_REFERENCES.ATTRIBUTE_CATEGORY,
    ATTRIBUTE1 = NEW_REFERENCES.ATTRIBUTE1,
    ATTRIBUTE2 = NEW_REFERENCES.ATTRIBUTE2,
    ATTRIBUTE3 = NEW_REFERENCES.ATTRIBUTE3,
    ATTRIBUTE4 = NEW_REFERENCES.ATTRIBUTE4,
    ATTRIBUTE5 = NEW_REFERENCES.ATTRIBUTE5,
    ATTRIBUTE6 = NEW_REFERENCES.ATTRIBUTE6,
    ATTRIBUTE7 = NEW_REFERENCES.ATTRIBUTE7,
    ATTRIBUTE8 = NEW_REFERENCES.ATTRIBUTE8,
    ATTRIBUTE9 = NEW_REFERENCES.ATTRIBUTE9,
    ATTRIBUTE10 = NEW_REFERENCES.ATTRIBUTE10,
    ATTRIBUTE11 = NEW_REFERENCES.ATTRIBUTE11,
    ATTRIBUTE12 = NEW_REFERENCES.ATTRIBUTE12,
    ATTRIBUTE13 = NEW_REFERENCES.ATTRIBUTE13,
    ATTRIBUTE14 = NEW_REFERENCES.ATTRIBUTE14,
    ATTRIBUTE15 = NEW_REFERENCES.ATTRIBUTE15,
    ATTRIBUTE16 = NEW_REFERENCES.ATTRIBUTE16,
    ATTRIBUTE17 = NEW_REFERENCES.ATTRIBUTE17,
    ATTRIBUTE18 = NEW_REFERENCES.ATTRIBUTE18,
    ATTRIBUTE19 = NEW_REFERENCES.ATTRIBUTE19,
    ATTRIBUTE20 = NEW_REFERENCES.ATTRIBUTE20,
    LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN,

    REQUEST_ID = X_REQUEST_ID,

    PROGRAM_ID = X_PROGRAM_ID,

    PROGRAM_APPLICATION_ID = X_PROGRAM_APPLICATION_ID,

    PROGRAM_UPDATE_DATE = X_PROGRAM_UPDATE_DATE

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
  X_GROUP_ID in NUMBER,
  X_GROUP_CD in VARCHAR2,
  X_CREATOR_PERSON_ID in NUMBER,
  X_DESCRIPTION in VARCHAR2,
  X_CREATE_DT in DATE,
  X_CLOSED_IND in VARCHAR2,
  X_COMMENTS in VARCHAR2,
  X_ORG_ID in NUMBER,
  X_FILE_NAME           IN VARCHAR2 DEFAULT NULL,
  x_attribute_category  IN VARCHAR2 DEFAULT NULL,
  x_attribute1          IN VARCHAR2 DEFAULT NULL,
  x_attribute2          IN VARCHAR2 DEFAULT NULL,
  x_attribute3          IN VARCHAR2 DEFAULT NULL,
  x_attribute4          IN VARCHAR2 DEFAULT NULL,
  x_attribute5          IN VARCHAR2 DEFAULT NULL,
  x_attribute6          IN VARCHAR2 DEFAULT NULL,
  x_attribute7          IN VARCHAR2 DEFAULT NULL,
  x_attribute8          IN VARCHAR2 DEFAULT NULL,
  x_attribute9          IN VARCHAR2 DEFAULT NULL,
  x_attribute10         IN VARCHAR2 DEFAULT NULL,
  x_attribute11         IN VARCHAR2 DEFAULT NULL,
  x_attribute12         IN VARCHAR2 DEFAULT NULL,
  x_attribute13         IN VARCHAR2 DEFAULT NULL,
  x_attribute14         IN VARCHAR2 DEFAULT NULL,
  x_attribute15         IN VARCHAR2 DEFAULT NULL,
  x_attribute16         IN VARCHAR2 DEFAULT NULL,
  x_attribute17         IN VARCHAR2 DEFAULT NULL,
  x_attribute18         IN VARCHAR2 DEFAULT NULL,
  x_attribute19         IN VARCHAR2 DEFAULT NULL,
  x_attribute20         IN VARCHAR2 DEFAULT NULL,
  X_MODE in VARCHAR2 default 'R'
  ) AS
  cursor c1 is select rowid from IGS_PE_PERSID_GROUP_ALL
     where GROUP_ID = X_GROUP_ID
  ;

begin
  open c1;
  fetch c1 into X_ROWID;
  if (c1%notfound) then
    close c1;
    INSERT_ROW (
     X_ROWID,
     X_GROUP_ID,
     X_GROUP_CD,
     X_CREATOR_PERSON_ID,
     X_DESCRIPTION,
     X_CREATE_DT,
     X_CLOSED_IND,
     X_COMMENTS,
    X_FILE_NAME,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE16,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
     x_org_id,
     X_MODE);
    return;
  end if;
  close c1;
  UPDATE_ROW (

   X_ROWID,
   X_GROUP_ID,
   X_GROUP_CD,
   X_CREATOR_PERSON_ID,
   X_DESCRIPTION,
   X_CREATE_DT,
   X_CLOSED_IND,
   X_COMMENTS,
    X_FILE_NAME,
    X_ATTRIBUTE_CATEGORY,
    X_ATTRIBUTE1,
    X_ATTRIBUTE2,
    X_ATTRIBUTE3,
    X_ATTRIBUTE4,
    X_ATTRIBUTE5,
    X_ATTRIBUTE6,
    X_ATTRIBUTE7,
    X_ATTRIBUTE8,
    X_ATTRIBUTE9,
    X_ATTRIBUTE10,
    X_ATTRIBUTE11,
    X_ATTRIBUTE12,
    X_ATTRIBUTE13,
    X_ATTRIBUTE14,
    X_ATTRIBUTE15,
    X_ATTRIBUTE16,
    X_ATTRIBUTE17,
    X_ATTRIBUTE18,
    X_ATTRIBUTE19,
    X_ATTRIBUTE20,
   X_MODE);
end ADD_ROW;

end IGS_PE_PERSID_GROUP_PKG;

/
