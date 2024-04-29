--------------------------------------------------------
--  DDL for Package Body CSF_DEBRIEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_DEBRIEF_PKG" as
/* $Header: csftdbfb.pls 120.0 2005/05/25 11:01:30 appldev noship $ */
-- Start of Comments
-- Package name     : CSF_DEBRIEF_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'CSF_DEBRIEF_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csftdbfb.pls';


PROCEDURE Insert_Row(	X_Rowid                           IN OUT NOCOPY VARCHAR2,
                  	X_DEBRIEF_HEADER_ID               IN OUT NOCOPY NUMBER,
 				X_DEBRIEF_NUMBER                  VARCHAR2,
 				X_DEBRIEF_DATE                    DATE,
 				X_DEBRIEF_STATUS_ID               NUMBER,
 				X_TASK_ASSIGNMENT_ID              NUMBER,
 				X_CREATED_BY                      NUMBER,
 				X_CREATION_DATE                   DATE,
 				X_LAST_UPDATED_BY                 NUMBER,
 				X_LAST_UPDATE_DATE                DATE,
 				X_LAST_UPDATE_LOGIN               NUMBER,
 				X_ATTRIBUTE1                      VARCHAR2,
 				X_ATTRIBUTE2                      VARCHAR2,
 				X_ATTRIBUTE3                      VARCHAR2,
 				X_ATTRIBUTE4                      VARCHAR2,
 				X_ATTRIBUTE5                      VARCHAR2,
 				X_ATTRIBUTE6                      VARCHAR2,
 				X_ATTRIBUTE7                      VARCHAR2,
	 			X_ATTRIBUTE8                      VARCHAR2,
 				X_ATTRIBUTE9                      VARCHAR2,
 				X_ATTRIBUTE10                     VARCHAR2,
 				X_ATTRIBUTE11                     VARCHAR2,
	 			X_ATTRIBUTE12                     VARCHAR2,
 				X_ATTRIBUTE13                     VARCHAR2,
 				X_ATTRIBUTE14                     VARCHAR2,
 				X_ATTRIBUTE15                     VARCHAR2,
 				X_ATTRIBUTE_CATEGORY              VARCHAR2 )


 IS
   CURSOR C2 IS SELECT CSF_DEBRIEF_HEADERS_S1.nextval FROM sys.dual;
BEGIN


	NULL;



--  END;

End  Insert_Row;

 PROCEDURE Update_Row( X_RowId					VARCHAR2,
				X_DEBRIEF_HEADER_ID         		NUMBER,
 				X_DEBRIEF_NUMBER                  	VARCHAR2,
 				X_DEBRIEF_DATE                    	DATE,
 				X_DEBRIEF_STATUS_ID               	NUMBER,
 				X_TASK_ASSIGNMENT_ID              	NUMBER,
 				X_CREATED_BY                      	NUMBER,
 				X_CREATION_DATE                  	DATE,
 				X_LAST_UPDATED_BY                 	NUMBER,
 				X_LAST_UPDATE_DATE                	DATE,
 				X_LAST_UPDATE_LOGIN               	NUMBER,
 				X_ATTRIBUTE1                      	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE2                      	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE3                      	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE4                      	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE5                      	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE6                      	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE7                      	VARCHAR2 DEFAULT NULL,
	 			X_ATTRIBUTE8                      	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE9                      	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE10                     	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE11                     	VARCHAR2 DEFAULT NULL,
	 			X_ATTRIBUTE12                     	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE13                     	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE14                     	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE15                     	VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE_CATEGORY              	VARCHAR2 DEFAULT NULL )


 IS
 BEGIN
    NULL;
END  Update_Row;


 PROCEDURE Lock_Row(	X_Rowid                           VARCHAR2,
				X_DEBRIEF_HEADER_ID               NUMBER,
 				X_DEBRIEF_NUMBER                  VARCHAR2,
 				X_DEBRIEF_DATE                    DATE,
 				X_DEBRIEF_STATUS_ID               NUMBER,
 				X_TASK_ASSIGNMENT_ID              NUMBER,
 				X_CREATED_BY                      NUMBER,
 				X_CREATION_DATE                   DATE,
 				X_LAST_UPDATED_BY                 NUMBER,
 				X_LAST_UPDATE_DATE                DATE,
 				X_LAST_UPDATE_LOGIN               NUMBER,
 				X_ATTRIBUTE1                      VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE2                      VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE3                      VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE4                      VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE5                      VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE6                      VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE7                      VARCHAR2 DEFAULT NULL,
	 			X_ATTRIBUTE8                      VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE9                      VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE10                     VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE11                     VARCHAR2 DEFAULT NULL,
	 			X_ATTRIBUTE12                     VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE13                     VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE14                     VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE15                     VARCHAR2 DEFAULT NULL,
 				X_ATTRIBUTE_CATEGORY              VARCHAR2 DEFAULT NULL )


 IS

 BEGIN
		NULL;


END  Lock_Row;

PROCEDURE Delete_Row(X_Rowid VARCHAR2) IS

BEGIN
	NULL;

END DELETE_ROW;



End CSF_DEBRIEF_PKG;

/
