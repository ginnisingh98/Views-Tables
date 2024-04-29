--------------------------------------------------------
--  DDL for Package Body PA_RES_LIST_ASSIGNMENT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_RES_LIST_ASSIGNMENT_PKG" AS
/* $Header: PARLASTB.pls 120.2 2005/08/31 11:46:55 ramurthy noship $ */
-- Standard Table Handler procedures for PA_RESOURCE_LIST_ASSIGNMENTS  table
PROCEDURE Insert_row        (X_ROW_ID IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
                             X_RESOURCE_LIST_ASSIGNMENT_ID NUMBER,
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_PROJECT_ID              NUMBER,
                             X_RESOURCE_LIST_CHANGED_FLAG VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_CREATION_DATE           DATE,
                             X_CREATED_BY              NUMBER,
                             X_LAST_UPDATE_LOGIN       NUMBER ) IS

CURSOR RES_LIST_ASSGMT_CUR IS Select Rowid from PA_RESOURCE_LIST_ASSIGNMENTS
Where Resource_List_Assignment_Id   =  X_Resource_List_Assignment_Id;
BEGIN
      Insert into PA_RESOURCE_LIST_ASSIGNMENTS (
            RESOURCE_LIST_ASSIGNMENT_ID,
            RESOURCE_LIST_ID,
            PROJECT_ID,
            RESOURCE_LIST_CHANGED_FLAG,
            LAST_UPDATED_BY,
            LAST_UPDATE_DATE,
            CREATION_DATE,
            CREATED_BY,
            LAST_UPDATE_LOGIN)
    Values
           (X_RESOURCE_LIST_ASSIGNMENT_ID,
            X_RESOURCE_LIST_ID,
            X_PROJECT_ID,
            X_RESOURCE_LIST_CHANGED_FLAG,
            X_LAST_UPDATED_BY,
            X_LAST_UPDATE_DATE,
            X_CREATION_DATE,
            X_CREATED_BY,
            X_LAST_UPDATE_LOGIN);

       Open RES_LIST_ASSGMT_CUR;
       Fetch RES_LIST_ASSGMT_CUR Into X_Row_Id;
       If (RES_LIST_ASSGMT_CUR%NOTFOUND)  then
           Close RES_LIST_ASSGMT_CUR;
           Raise NO_DATA_FOUND;
        End If;
       Close RES_LIST_ASSGMT_CUR;
Exception
       When Others Then
       FND_MESSAGE.SET_NAME('PA' ,SQLERRM);
       APP_EXCEPTION.RAISE_EXCEPTION;
END Insert_Row;
PROCEDURE Update_Row        (X_ROW_ID IN VARCHAR2,
                             X_RESOURCE_LIST_CHANGED_FLAG VARCHAR2,
                             X_LAST_UPDATED_BY         NUMBER,
                             X_LAST_UPDATE_DATE        DATE,
                             X_LAST_UPDATE_LOGIN       NUMBER ) Is

BEGIN

       Update PA_RESOURCE_LIST_ASSIGNMENTS
       SET
       RESOURCE_LIST_CHANGED_FLAG = X_RESOURCE_LIST_CHANGED_FLAG,
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
                             X_RESOURCE_LIST_ID        NUMBER,
                             X_RESOURCE_LIST_CHANGED_FLAG VARCHAR2 ) Is

CURSOR C Is
    Select * From PA_RESOURCE_LIST_ASSIGNMENTS WHERE ROWID = X_ROW_ID
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
       (X_RESOURCE_LIST_ID = Recinfo.RESOURCE_LIST_ID) AND
       (X_RESOURCE_LIST_CHANGED_FLAG = Recinfo.RESOURCE_LIST_CHANGED_FLAG) )
   Then
         Return;
   Else
         FND_MESSAGE.SET_NAME('FND','FORM_RECORD_CHANGED');
         APP_EXCEPTION.RAISE_EXCEPTION;
   END If;

End Lock_Row;

Procedure Delete_Row (X_ROW_ID IN VARCHAR2) Is
Begin
   Delete from PA_RESOURCE_LIST_ASSIGNMENTS Where RowId = X_Row_Id;
If SQL%NOTFOUND Then
   Raise NO_DATA_FOUND;
End If;
End Delete_Row;
End  PA_Res_list_Assignment_Pkg;

/
