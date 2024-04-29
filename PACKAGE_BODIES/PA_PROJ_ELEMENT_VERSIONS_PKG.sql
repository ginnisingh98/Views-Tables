--------------------------------------------------------
--  DDL for Package Body PA_PROJ_ELEMENT_VERSIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PA_PROJ_ELEMENT_VERSIONS_PKG" AS
/* $Header: PATSKT2B.pls 120.1 2005/08/19 17:05:57 mwasowic noship $ */

PROCEDURE Insert_Row(
X_ROW_ID                   IN OUT NOCOPY VARCHAR2, --File.Sql.39 bug 4440895
X_ELEMENT_VERSION_ID       IN OUT NOCOPY NUMBER, --File.Sql.39 bug 4440895
X_PROJ_ELEMENT_ID	         IN NUMBER,
X_OBJECT_TYPE	         IN VARCHAR2,
X_PROJECT_ID	         IN NUMBER,
X_PARENT_STRUCTURE_VERSION_ID	IN NUMBER,
X_DISPLAY_SEQUENCE	NUMBER,
X_WBS_LEVEL	NUMBER,
X_WBS_NUMBER	VARCHAR2,
X_ATTRIBUTE_CATEGORY	VARCHAR2,
X_ATTRIBUTE1	VARCHAR2,
X_ATTRIBUTE2	VARCHAR2,
X_ATTRIBUTE3	VARCHAR2,
X_ATTRIBUTE4	VARCHAR2,
X_ATTRIBUTE5	VARCHAR2,
X_ATTRIBUTE6	VARCHAR2,
X_ATTRIBUTE7	VARCHAR2,
X_ATTRIBUTE8	VARCHAR2,
X_ATTRIBUTE9	VARCHAR2,
X_ATTRIBUTE10	VARCHAR2,
X_ATTRIBUTE11	VARCHAR2,
X_ATTRIBUTE12	VARCHAR2,
X_ATTRIBUTE13	VARCHAR2,
X_ATTRIBUTE14	VARCHAR2,
X_ATTRIBUTE15	VARCHAR2,
X_TASK_UNPUB_VER_STATUS_CODE VARCHAR2,
P_Financial_Task_Flag  IN VARCHAR2 := 'N', -- Added for FP_M changes Bug 3305199
x_source_object_id      IN NUMBER:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_NUM,       --Bug No 3594635 SMukka
x_source_object_type    IN VARCHAR2:= PA_INTERFACE_UTILS_PUB.G_PA_MISS_CHAR     --Bug No 3594635 SMukka
) IS

    CURSOR cur_elem_ver_seq
        IS
          SELECT pa_proj_element_versions_s.nextval
            FROM sys.dual;

BEGIN
     IF X_ELEMENT_VERSION_ID IS NULL
     THEN
        OPEN cur_elem_ver_seq;
        FETCH cur_elem_ver_seq INTO X_ELEMENT_VERSION_ID;
        CLOSE cur_elem_ver_seq;
     END IF;
     INSERT INTO pa_proj_element_versions(
                     ELEMENT_VERSION_ID
                    ,PROJ_ELEMENT_ID
                    ,OBJECT_TYPE
                    ,PROJECT_ID
                    ,PARENT_STRUCTURE_VERSION_ID
                    ,DISPLAY_SEQUENCE
                    ,WBS_LEVEL
                    ,WBS_NUMBER
                    ,CREATION_DATE
                    ,CREATED_BY
                    ,LAST_UPDATE_DATE
                    ,LAST_UPDATED_BY
                    ,LAST_UPDATE_LOGIN
                    ,RECORD_VERSION_NUMBER
                    ,ATTRIBUTE_CATEGORY
                    ,ATTRIBUTE1
                    ,ATTRIBUTE2
                    ,ATTRIBUTE3
                    ,ATTRIBUTE4
                    ,ATTRIBUTE5
                    ,ATTRIBUTE6
                    ,ATTRIBUTE7
                    ,ATTRIBUTE8
                    ,ATTRIBUTE9
                    ,ATTRIBUTE10
                    ,ATTRIBUTE11
                    ,ATTRIBUTE12
                    ,ATTRIBUTE13
                    ,ATTRIBUTE14
                    ,ATTRIBUTE15
                    ,TASK_UNPUB_VER_STATUS_CODE
		    ,FINANCIAL_TASK_FLAG  	-- Added for FP_M changes Bug 3305199
                    ,source_object_id           --Bug No 3594635 SMukka
                    ,source_object_type         --Bug No 3594635 SMukka
                    )
           VALUES(
                     X_ELEMENT_VERSION_ID
                    ,X_PROJ_ELEMENT_ID
                    ,X_OBJECT_TYPE
                    ,X_PROJECT_ID
                    ,X_PARENT_STRUCTURE_VERSION_ID
                    ,X_DISPLAY_SEQUENCE
                    ,X_WBS_LEVEL
                    ,X_WBS_NUMBER
                    ,SYSDATE                     ------CREATION_DATE
                    ,FND_GLOBAL.USER_ID          ------CREATED_BY
                    ,SYSDATE                     ------LAST_UPDATE_DATE
                    ,FND_GLOBAL.USER_ID          ------LAST_UPDATED_BY
                    ,FND_GLOBAL.LOGIN_ID         ------LAST_UPDATE_LOGIN
                    ,1                           ------RECORD_VERSION_NUMBER
                    ,X_ATTRIBUTE_CATEGORY
                    ,X_ATTRIBUTE1
                    ,X_ATTRIBUTE2
                    ,X_ATTRIBUTE3
                    ,X_ATTRIBUTE4
                    ,X_ATTRIBUTE5
                    ,X_ATTRIBUTE6
                    ,X_ATTRIBUTE7
                    ,X_ATTRIBUTE8
                    ,X_ATTRIBUTE9
                    ,X_ATTRIBUTE10
                    ,X_ATTRIBUTE11
                    ,X_ATTRIBUTE12
                    ,X_ATTRIBUTE13
                    ,X_ATTRIBUTE14
                    ,X_ATTRIBUTE15
                    ,X_TASK_UNPUB_VER_STATUS_CODE
		    ,P_Financial_Task_Flag   -- Added for FP_M changes Bug 3305199
                    ,x_source_object_id      --Bug No 3594635 SMukka
                    ,x_source_object_type    --Bug No 3594635 SMukka
                    );

END Insert_Row;


PROCEDURE Update_Row(
X_ROW_ID                   IN VARCHAR2,
X_ELEMENT_VERSION_ID       IN NUMBER,
X_PROJ_ELEMENT_ID	         IN NUMBER,
X_OBJECT_TYPE	         IN VARCHAR2,
X_PROJECT_ID	         IN NUMBER,
X_PARENT_STRUCTURE_VERSION_ID	IN NUMBER,
X_DISPLAY_SEQUENCE	NUMBER,
X_WBS_LEVEL	NUMBER,
X_WBS_NUMBER	VARCHAR2,
X_RECORD_VERSION_NUMBER	NUMBER,
X_ATTRIBUTE_CATEGORY	VARCHAR2,
X_ATTRIBUTE1	VARCHAR2,
X_ATTRIBUTE2	VARCHAR2,
X_ATTRIBUTE3	VARCHAR2,
X_ATTRIBUTE4	VARCHAR2,
X_ATTRIBUTE5	VARCHAR2,
X_ATTRIBUTE6	VARCHAR2,
X_ATTRIBUTE7	VARCHAR2,
X_ATTRIBUTE8	VARCHAR2,
X_ATTRIBUTE9	VARCHAR2,
X_ATTRIBUTE10	VARCHAR2,
X_ATTRIBUTE11	VARCHAR2,
X_ATTRIBUTE12	VARCHAR2,
X_ATTRIBUTE13	VARCHAR2,
X_ATTRIBUTE14	VARCHAR2,
X_ATTRIBUTE15	VARCHAR2,
X_TASK_UNPUB_VER_STATUS_CODE VARCHAR2
) IS
   CURSOR cur_proj_elem_ver
   IS
     SELECT *
       FROM pa_proj_element_versions
      WHERE element_version_id = X_ELEMENT_VERSION_ID;
  cur_proj_elem_ver_rec cur_proj_elem_ver%ROWTYPE;

BEGIN
   /*OPEN cur_proj_elem_ver;
   FETCH cur_proj_elem_ver INTO cur_proj_elem_ver_rec;
   CLOSE cur_proj_elem_ver;

    if cur_proj_elem_ver_rec.record_version_number <> x_record_version_number
    then
      FND_MESSAGE.Set_Name('FND', 'FORM_RECORD_CHANGED');
      APP_EXCEPTION.Raise_Exception;
    end if; moved to private API */

     UPDATE pa_proj_element_versions
         SET         ELEMENT_VERSION_ID            = X_ELEMENT_VERSION_ID
                    ,PROJ_ELEMENT_ID	         = X_PROJ_ELEMENT_ID
                    ,OBJECT_TYPE	               = X_OBJECT_TYPE
                    ,PROJECT_ID	               = X_PROJECT_ID
                    ,PARENT_STRUCTURE_VERSION_ID   = X_PARENT_STRUCTURE_VERSION_ID
                    ,DISPLAY_SEQUENCE	         = X_DISPLAY_SEQUENCE
                    ,WBS_LEVEL	               = X_WBS_LEVEL
                    ,WBS_NUMBER		         = X_WBS_NUMBER
                    ,LAST_UPDATE_DATE	         = SYSDATE
                    ,LAST_UPDATED_BY	         = FND_GLOBAL.USER_ID
                    ,LAST_UPDATE_LOGIN	         = FND_GLOBAL.LOGIN_ID
                    ,RECORD_VERSION_NUMBER	   = NVL( RECORD_VERSION_NUMBER, 0 ) + 1
                    ,ATTRIBUTE_CATEGORY	         = X_ATTRIBUTE_CATEGORY
                    ,ATTRIBUTE1	               = X_ATTRIBUTE1
                    ,ATTRIBUTE2	               = X_ATTRIBUTE2
                    ,ATTRIBUTE3	               = X_ATTRIBUTE3
                    ,ATTRIBUTE4	               = X_ATTRIBUTE4
                    ,ATTRIBUTE5	               = X_ATTRIBUTE5
                    ,ATTRIBUTE6	               = X_ATTRIBUTE6
                    ,ATTRIBUTE7	               = X_ATTRIBUTE7
                    ,ATTRIBUTE8	               = X_ATTRIBUTE8
                    ,ATTRIBUTE9	               = X_ATTRIBUTE9
                    ,ATTRIBUTE10	               = X_ATTRIBUTE10
                    ,ATTRIBUTE11	               = X_ATTRIBUTE11
                    ,ATTRIBUTE12	               = X_ATTRIBUTE12
                    ,ATTRIBUTE13	               = X_ATTRIBUTE13
                    ,ATTRIBUTE14	               = X_ATTRIBUTE14
                    ,ATTRIBUTE15                   = X_ATTRIBUTE15
                    ,TASK_UNPUB_VER_STATUS_CODE = X_TASK_UNPUB_VER_STATUS_CODE
       WHERE rowid = x_row_id;

END Update_Row;

PROCEDURE Delete_Row(
X_ROW_ID                   IN VARCHAR2
) IS
BEGIN
    DELETE FROM pa_proj_element_versions
      WHERE rowid = x_row_id;
END Delete_Row;

END PA_PROJ_ELEMENT_VERSIONS_PKG;

/
