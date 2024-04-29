--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_PKG" AUTHID CURRENT_USER as
/* $Header: csftdbfs.pls 120.0 2005/05/25 10:59:47 appldev noship $ */


  PROCEDURE Insert_Row(	X_Rowid                           IN OUT NOCOPY VARCHAR2,
                  	X_DEBRIEF_HEADER_ID               IN OUT NOCOPY  NUMBER,
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
 				X_ATTRIBUTE_CATEGORY              VARCHAR2 );


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
 				X_ATTRIBUTE_CATEGORY              VARCHAR2 DEFAULT NULL );


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
 				X_ATTRIBUTE_CATEGORY              	VARCHAR2 DEFAULT NULL );



  PROCEDURE Delete_Row(X_Rowid VARCHAR2);

END CSF_DEBRIEF_PKG;

 

/
