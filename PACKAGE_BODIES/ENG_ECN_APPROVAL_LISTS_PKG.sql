--------------------------------------------------------
--  DDL for Package Body ENG_ECN_APPROVAL_LISTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ECN_APPROVAL_LISTS_PKG" as
/*$Header: ENGAPPLB.pls 115.7 2004/05/11 13:26:01 amalviya ship $ */


PROCEDURE Insert_Row(X_Rowid                         IN OUT NOCOPY VARCHAR2,
                     X_Approval_List_Id              IN OUT NOCOPY NUMBER,
                     X_Approval_List_Name            VARCHAR2,
                     X_Disable_Date                  DATE DEFAULT NULL,
                     X_Description                   VARCHAR2 DEFAULT NULL,
                     X_Attribute_Category            VARCHAR2 DEFAULT NULL,
                     X_Attribute1                    VARCHAR2 DEFAULT NULL,
                     X_Attribute2                    VARCHAR2 DEFAULT NULL,
                     X_Attribute3                    VARCHAR2 DEFAULT NULL,
                     X_Attribute4                    VARCHAR2 DEFAULT NULL,
                     X_Attribute5                    VARCHAR2 DEFAULT NULL,
                     X_Attribute6                    VARCHAR2 DEFAULT NULL,
                     X_Attribute7                    VARCHAR2 DEFAULT NULL,
                     X_Attribute8                    VARCHAR2 DEFAULT NULL,
                     X_Attribute9                    VARCHAR2 DEFAULT NULL,
                     X_Attribute10                   VARCHAR2 DEFAULT NULL,
                     X_Attribute11                   VARCHAR2 DEFAULT NULL,
                     X_Attribute12                   VARCHAR2 DEFAULT NULL,
                     X_Attribute13                   VARCHAR2 DEFAULT NULL,
                     X_Attribute14                   VARCHAR2 DEFAULT NULL,
                     X_Attribute15                   VARCHAR2 DEFAULT NULL,
                     X_Creation_Date                 DATE,
                     X_Created_By                    NUMBER,
                     X_Last_Update_Login             NUMBER DEFAULT NULL,
                     X_Last_Update_Date              DATE,
                     X_Last_Updated_By               NUMBER
 ) IS
   CURSOR C IS SELECT rowid FROM eng_ecn_approval_lists
             WHERE approval_list_id = X_Approval_List_Id;
   CURSOR C2 IS SELECT eng_ecn_approval_lists_s.nextval FROM dual;

   myList      wf_parameter_list_t;
    l_username  varchar2(320);
BEGIN
   if (X_Approval_List_Id is NULL) then
     OPEN C2;
     FETCH C2 INTO X_Approval_List_Id;
     CLOSE C2;
   end if;
  INSERT INTO eng_ecn_approval_lists(
          approval_list_id,
          approval_list_name,
          disable_date,
          description,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15,
          creation_date,
          created_by,
          last_update_login,
          last_update_date,
          last_updated_by
         ) VALUES (
          X_Approval_List_Id,
          X_Approval_List_Name,
          X_Disable_Date,
          X_Description,
          X_Attribute_Category,
          X_Attribute1,
          X_Attribute2,
          X_Attribute3,
          X_Attribute4,
          X_Attribute5,
          X_Attribute6,
          X_Attribute7,
          X_Attribute8,
          X_Attribute9,
          X_Attribute10,
          X_Attribute11,
          X_Attribute12,
          X_Attribute13,
          X_Attribute14,
          X_Attribute15,
          X_Creation_Date,
          X_Created_By,
          X_Last_Update_Login,
          X_Last_Update_Date,
          X_Last_Updated_By
  );
  OPEN C;
  FETCH C INTO X_Rowid;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;

  -- construct attribute list --

   l_username  := 'ENG_LIST:'||to_char(X_Approval_List_Id);
  wf_event.AddParameterToList('DISPLAYNAME', X_Approval_List_Name, mylist);
  wf_event.AddParameterToList('DESCRIPTION', X_Description,  mylist);
  wf_event.AddParameterToList('USER_NAME', l_username, mylist);


  -- added for synchronize the work flow
  wf_local_synch.propagate_role(p_orig_system=>'ENG_LIST'  ,
                         p_orig_system_id    =>X_Approval_List_Id,
                         p_attributes        => mylist,
                         p_start_date        =>null,
                         p_expiration_date   =>X_Disable_Date);

END Insert_Row;
PROCEDURE Lock_Row(X_Rowid                                 VARCHAR2,
                   X_Approval_List_Id                      NUMBER,
                   X_Approval_List_Name                    VARCHAR2,
                   X_Disable_Date                          DATE DEFAULT NULL,
                   X_Description                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute_Category                    VARCHAR2 DEFAULT NULL ,
                   X_Attribute1                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute2                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute3                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute4                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute5                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute6                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute7                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute8                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute9                            VARCHAR2 DEFAULT NULL ,
                   X_Attribute10                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute11                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute12                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute13                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute14                           VARCHAR2 DEFAULT NULL ,
                   X_Attribute15                           VARCHAR2 DEFAULT NULL
) IS
  CURSOR C IS
      SELECT *
      FROM   eng_ecn_approval_lists
      WHERE  rowid = X_Rowid
      FOR UPDATE of Approval_List_Id NOWAIT;
  Recinfo C%ROWTYPE;
BEGIN
  OPEN C;
  FETCH C INTO Recinfo;
  if (C%NOTFOUND) then
    CLOSE C;
    RAISE NO_DATA_FOUND;
  end if;
  CLOSE C;
  if (
          (   (Recinfo.approval_list_id = X_Approval_List_Id)
           OR (    (Recinfo.approval_list_id IS NULL)
               AND (X_Approval_List_Id IS NULL)))
      AND (   (Recinfo.approval_list_name = X_Approval_List_Name)
           OR (    (Recinfo.approval_list_name IS NULL)
               AND (X_Approval_List_Name IS NULL)))
      AND (   (Recinfo.disable_date = X_Disable_Date)
           OR (    (Recinfo.disable_date IS NULL)
               AND (X_Disable_Date IS NULL)))
      AND (   (Recinfo.description = X_Description)
           OR (    (Recinfo.description IS NULL)
               AND (X_Description IS NULL)))
      AND (   (Recinfo.attribute_category = X_Attribute_Category)
           OR (    (Recinfo.attribute_category IS NULL)
               AND (X_Attribute_Category IS NULL)))
      AND (   (Recinfo.attribute1 = X_Attribute1)
           OR (    (Recinfo.attribute1 IS NULL)
               AND (X_Attribute1 IS NULL)))
      AND (   (Recinfo.attribute2 = X_Attribute2)
           OR (    (Recinfo.attribute2 IS NULL)
               AND (X_Attribute2 IS NULL)))
      AND (   (Recinfo.attribute3 = X_Attribute3)
           OR (    (Recinfo.attribute3 IS NULL)
               AND (X_Attribute3 IS NULL)))
      AND (   (Recinfo.attribute4 = X_Attribute4)
           OR (    (Recinfo.attribute4 IS NULL)
               AND (X_Attribute4 IS NULL)))
      AND (   (Recinfo.attribute5 = X_Attribute5)
           OR (    (Recinfo.attribute5 IS NULL)
               AND (X_Attribute5 IS NULL)))
      AND (   (Recinfo.attribute6 = X_Attribute6)
           OR (    (Recinfo.attribute6 IS NULL)
               AND (X_Attribute6 IS NULL)))
      AND (   (Recinfo.attribute7 = X_Attribute7)
           OR (    (Recinfo.attribute7 IS NULL)
               AND (X_Attribute7 IS NULL)))
      AND (   (Recinfo.attribute8 = X_Attribute8)
           OR (    (Recinfo.attribute8 IS NULL)
               AND (X_Attribute8 IS NULL)))
      AND (   (Recinfo.attribute9 = X_Attribute9)
           OR (    (Recinfo.attribute9 IS NULL)
               AND (X_Attribute9 IS NULL)))
      AND (   (Recinfo.attribute10 = X_Attribute10)
           OR (    (Recinfo.attribute10 IS NULL)
               AND (X_Attribute10 IS NULL)))
      AND (   (Recinfo.attribute11 = X_Attribute11)
           OR (    (Recinfo.attribute11 IS NULL)
               AND (X_Attribute11 IS NULL)))
      AND (   (Recinfo.attribute12 = X_Attribute12)
           OR (    (Recinfo.attribute12 IS NULL)
               AND (X_Attribute12 IS NULL)))
      AND (   (Recinfo.attribute13 = X_Attribute13)
           OR (    (Recinfo.attribute13 IS NULL)
               AND (X_Attribute13 IS NULL)))
      AND (   (Recinfo.attribute14 = X_Attribute14)
           OR (    (Recinfo.attribute14 IS NULL)
               AND (X_Attribute14 IS NULL)))
      AND (   (Recinfo.attribute15 = X_Attribute15)
           OR (    (Recinfo.attribute15 IS NULL)
               AND (X_Attribute15 IS NULL)))
          ) then
    return;
  else
    FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.RAISE_EXCEPTION;
  end if;
END Lock_Row;
PROCEDURE Update_Row(X_Rowid                               VARCHAR2,
                     X_Approval_List_Id                    NUMBER,
                     X_Approval_List_Name                  VARCHAR2,
                     X_Disable_Date                        DATE DEFAULT NULL,
                     X_Description                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute_Category                  VARCHAR2 DEFAULT NULL ,
                     X_Attribute1                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute2                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute3                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute4                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute5                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute6                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute7                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute8                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute9                          VARCHAR2 DEFAULT NULL ,
                     X_Attribute10                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute11                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute12                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute13                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute14                         VARCHAR2 DEFAULT NULL ,
                     X_Attribute15                         VARCHAR2 DEFAULT NULL ,
                     X_Last_Update_Login                   NUMBER DEFAULT NULL,
                     X_Last_Update_Date                    DATE,
                     X_Last_Updated_By                     NUMBER
) IS

/* Added for Bug 3511260 */

Cursor user_roles is
  select START_DATE,
         USER_ORIG_SYSTEM,USER_ORIG_SYSTEM_ID
  from WF_LOCAL_USER_ROLES
  where role_orig_system= 'ENG_LIST' and
        role_orig_system_id = X_Approval_List_Id;
 myList      wf_parameter_list_t;
 l_username           varchar2(320);
 lemail               WF_LOCAL_ROLES.EMAIL_ADDRESS%type;
 lfax                 WF_LOCAL_ROLES.FAX%type;
BEGIN
  UPDATE eng_ecn_approval_lists
  SET
    approval_list_id                          =    X_Approval_List_Id,
    approval_list_name                        =    X_Approval_List_Name,
    disable_date                              =    X_Disable_Date,
    description                               =    X_Description,
    attribute_category                        =    X_Attribute_Category,
    attribute1                                =    X_Attribute1,
    attribute2                                =    X_Attribute2,
    attribute3                                =    X_Attribute3,
    attribute4                                =    X_Attribute4,
    attribute5                                =    X_Attribute5,
    attribute6                                =    X_Attribute6,
    attribute7                                =    X_Attribute7,
    attribute8                                =    X_Attribute8,
    attribute9                                =    X_Attribute9,
    attribute10                               =    X_Attribute10,
    attribute11                               =    X_Attribute11,
    attribute12                               =    X_Attribute12,
    attribute13                               =    X_Attribute13,
    attribute14                               =    X_Attribute14,
    attribute15                               =    X_Attribute15,
    last_update_login                         =    X_Last_Update_Login,
    last_update_date                          =    X_Last_Update_Date,
    last_updated_by                           =    X_Last_Updated_By
  WHERE rowid = X_rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

 l_username  := 'ENG_LIST:'||to_char(X_Approval_List_Id);
/* added for bug 3511260 */

   select EMAIL_ADDRESS,FAX
   into lemail,lfax
   from WF_LOCAL_ROLES
   where NAME = l_username and
         ORIG_SYSTEM = 'ENG_LIST' and
         ORIG_SYSTEM_ID = X_Approval_List_Id;


   -- construct attribute list --
  wf_event.AddParameterToList('DISPLAYNAME', X_Approval_List_Name, mylist);
  wf_event.AddParameterToList('DESCRIPTION', X_Description,  mylist);
  wf_event.AddParameterToList('USER_NAME', l_username, mylist);
  wf_event.AddParameterToList('MAIL', lemail, mylist);
  wf_event.AddParameterToList('FACSIMILETELEPHONENUMBER', lfax, mylist);
  wf_event.AddParameterToList('WFSYNCH_OVERWRITE','TRUE', mylist);


  -- added for synchronize the work flow
  wf_local_synch.propagate_role(p_orig_system=>'ENG_LIST'  ,
                         p_orig_system_id    =>X_Approval_List_Id,
                         p_attributes        => mylist,
                         p_start_date        =>null,
                         p_expiration_date   =>X_Disable_Date);

/* Added for Bug 3511260
   When approval list is reactivated all the approvers in the list retain
   the original expirtaion date. So Notifications are not sent to users even
   though the Role is re acttivated. Below code is added to update the User
  role relation in the table*/

  for c in user_roles loop

     wf_local_synch.propagate_user_role(

      p_user_orig_system     => c.USER_ORIG_SYSTEM,
      p_user_orig_system_id  => c.USER_ORIG_SYSTEM_ID,
      p_role_orig_system     => 'ENG_LIST',
      p_role_orig_system_id  => x_approval_List_Id,
      p_start_date           => c.START_DATE,
      p_overwrite            => TRUE,
      p_expiration_date      => X_Disable_Date);

  end loop;

END Update_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS
 x_approval_list_id number;
 myList      wf_parameter_list_t;

BEGIN

  select approval_list_id into x_approval_list_id
  from eng_ecn_approval_lists
  where  rowid = X_Rowid;

  DELETE FROM eng_ecn_approval_lists
  WHERE  rowid = X_Rowid;
  if (SQL%NOTFOUND) then
    RAISE NO_DATA_FOUND;
  end if;

  -- construct attribute list --
  wf_event.AddParameterToList('DELETE','TRUE', mylist);

  -- added for synchronize the work flow
  wf_local_synch.propagate_role(p_orig_system=> 'ENG_LIST'  ,
                         p_orig_system_id    => X_Approval_List_Id,
                         p_attributes        => mylist,
                         p_start_date        => null,
                         p_expiration_date   => sysdate);


END Delete_Row;

PROCEDURE Check_References(X_Approval_List_Id NUMBER) IS
  DUMMY NUMBER;
BEGIN
  SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM ENG_ENGINEERING_CHANGES
       WHERE Approval_List_Id = X_Approval_List_Id
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    FND_MESSAGE.SET_NAME('ENG', 'LIST IN USE');
    APP_EXCEPTION.RAISE_EXCEPTION;
END CHECK_REFERENCES;

PROCEDURE Check_Unique(X_Rowid VARCHAR2,
                       X_Approval_List_Name VARCHAR2) IS
  DUMMY NUMBER;
BEGIN
  SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
    (SELECT 1 FROM ENG_ECN_APPROVAL_LISTS
       WHERE (Approval_List_Name = X_Approval_List_Name)
         AND ((X_Rowid is NULL) or (ROWID <> X_Rowid))
    );
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      -- FND_MESSAGE.SET_NAME('ENG', 'Approval List Name Already Used');
      APP_EXCEPTION.RAISE_EXCEPTION;
  END Check_Unique;

END ENG_ECN_APPROVAL_LISTS_PKG ;

/
