--------------------------------------------------------
--  DDL for Package Body PA_RESOURCE_LIST_USES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RESOURCE_LIST_USES_PKG" AS
/* $Header: PARLUSTB.pls 120.2 2005/08/31 11:47:15 ramurthy noship $ */
-- Standard Table Handler procedures for PA_RESOURCE_LIST_USES table

PROCEDURE Insert_row        (X_ROW_ID IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_RESOURCE_LIST_ASSIGNMENT_ID NUMBER,
                             X_USE_CODE                VARCHAR2,
                             X_DEFAULT_FLAG            VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_CREATION_DATE           DATE,
                             X_CREATED_BY              NUMBER,
                             X_LAST_UPDATE_LOGIN       NUMBER ) Is

CURSOR RES_LIST_USES_CUR IS Select Rowid from PA_RESOURCE_LIST_USES
Where Resource_List_Assignment_Id   =  X_Resource_List_Assignment_Id And
Use_Code = X_Use_Code;
BEGIN
      Insert into PA_RESOURCE_LIST_USES (
            RESOURCE_LIST_ASSIGNMENT_ID,
            USE_CODE,
            DEFAULT_FLAG,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN)
    Values
           (X_RESOURCE_LIST_ASSIGNMENT_ID,
            X_USE_CODE,
            X_DEFAULT_FLAG,
            X_LAST_UPDATED_BY,
            X_LAST_UPDATE_DATE,
            X_CREATION_DATE,
            X_CREATED_BY,
            X_LAST_UPDATE_LOGIN);

       Open RES_LIST_USES_CUR;
       Fetch RES_LIST_USES_CUR Into X_Row_Id;
       If (RES_LIST_USES_CUR%NOTFOUND)  then
           Close RES_LIST_USES_CUR;
           Raise NO_DATA_FOUND;
        End If;
       Close RES_LIST_USES_CUR;
Exception
       When Others Then
       FND_MESSAGE.SET_NAME('PA' ,SQLERRM);
       APP_EXCEPTION.RAISE_EXCEPTION;
END Insert_Row;


PROCEDURE Update_Row        (X_ROW_ID IN VARCHAR2,
                             X_USE_CODE                VARCHAR2,
                             X_DEFAULT_FLAG            VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_LAST_UPDATE_LOGIN       NUMBER ) IS
BEGIN

       Update PA_RESOURCE_LIST_USES
       SET
       USE_CODE                   = X_USE_CODE,
       DEFAULT_FLAG               = X_DEFAULT_FLAG,
       LAST_UPDATED_BY            = X_LAST_UPDATED_BY,
       LAST_UPDATE_DATE           = X_LAST_UPDATE_DATE,
       LAST_UPDATE_LOGIN          = X_LAST_UPDATE_LOGIN
       Where ROWID   = X_ROW_ID;
      If SQL%NOTFOUND Then
         Raise NO_DATA_FOUND;
      End If;
END Update_Row;

Procedure Lock_Row          (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_ASSIGNMENT_ID NUMBER,
                             X_USE_CODE                VARCHAR2,
                             X_DEFAULT_FLAG            VARCHAR2) Is

CURSOR C Is
    Select * From PA_RESOURCE_LIST_USES WHERE ROWID = X_ROW_ID
    For Update of RESOURCE_LIST_ASSIGNMENT_ID NOWAIT;
    Recinfo C%ROWTYPE;
Begin
    OPEN C;
    FETCH C INTO Recinfo;
    If (C%NOTFOUND) THEN
       Close C;
       FND_MESSAGE.SET_NAME('FND','FORM_RECORD_DELETED');
       APP_EXCEPTION.RAISE_EXCEPTION;
   END If;
   CLOSE C;
   IF (
     (X_RESOURCE_LIST_ASSIGNMENT_ID = Recinfo.RESOURCE_LIST_ASSIGNMENT_ID) AND
     (X_DEFAULT_FLAG                = Recinfo.DEFAULT_FLAG) AND
     (X_USE_CODE                    = Recinfo.USE_CODE ) )
   Then
         return;
   Else
         FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
         APP_EXCEPTION.RAISE_EXCEPTION;
   END If;

End Lock_Row;

Procedure Delete_Row (X_ROW_ID IN VARCHAR2) Is
Begin
   Delete from PA_RESOURCE_LIST_USES Where RowId = X_Row_Id;
If SQL%NOTFOUND Then
   Raise NO_DATA_FOUND;
End If;
End Delete_Row;
End  PA_Resource_list_uses_Pkg;

/
