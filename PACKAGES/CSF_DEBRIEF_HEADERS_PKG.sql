--------------------------------------------------------
--  DDL for Package CSF_DEBRIEF_HEADERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSF_DEBRIEF_HEADERS_PKG" AUTHID CURRENT_USER as
/* $Header: csftdbhs.pls 120.0.12010000.2 2008/08/05 18:10:56 syenduri ship $ */
TYPE internal_user_hooks_rec IS RECORD
(
DEBRIEF_HEADER_ID                NUMBER		:=  	FND_API.G_MISS_NUM,
DEBRIEF_NUMBER                   VARCHAR2(50)	:= 	FND_API.G_MISS_CHAR,
DEBRIEF_DATE                     DATE		:= 	FND_API.G_MISS_DATE,
DEBRIEF_STATUS_ID                NUMBER		:=  	FND_API.G_MISS_NUM,
TASK_ASSIGNMENT_ID               NUMBER		:=  	FND_API.G_MISS_NUM,
CREATED_BY                       NUMBER		:=  	FND_API.G_MISS_NUM,
CREATION_DATE                    DATE		:= 	FND_API.G_MISS_DATE,
LAST_UPDATED_BY                  NUMBER		:=  	FND_API.G_MISS_NUM,
LAST_UPDATE_DATE                 DATE 		:= 	FND_API.G_MISS_DATE,
LAST_UPDATE_LOGIN                NUMBER		:=  	FND_API.G_MISS_NUM,
ATTRIBUTE1                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE2                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE3                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE4                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE5                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE6                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE7                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE8                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE9                       VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE10                      VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE11                      VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE12                      VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE13                      VARCHAR2(150)	:=	FND_API.G_MISS_CHAR,
ATTRIBUTE14                      VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE15                      VARCHAR2(150)	:= 	FND_API.G_MISS_CHAR,
ATTRIBUTE_CATEGORY               VARCHAR2(30)	:= 	FND_API.G_MISS_CHAR,
object_version_number            NUMBER        :=  FND_API.G_MISS_NUM,
    TRAVEL_START_TIME                DATE       :=  FND_API.G_MISS_DATE,
    TRAVEL_END_TIME                  DATE        :=  FND_API.G_MISS_DATE,
    TRAVEL_DISTANCE_IN_KM            NUMBER        :=  FND_API.G_MISS_NUM);
user_hooks_rec  CSF_DEBRIEF_HEADERS_PKG.internal_user_hooks_rec ;

PROCEDURE Insert_Row(
          px_DEBRIEF_HEADER_ID   IN OUT NOCOPY NUMBER,
          p_DEBRIEF_NUMBER    VARCHAR2,
          p_DEBRIEF_DATE    DATE,
          p_DEBRIEF_STATUS_ID    NUMBER,
          p_TASK_ASSIGNMENT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
	      p_COMMIT   IN    VARCHAR2 DEFAULT Null,
          p_object_version_number    IN        NUMBER default null,
          p_TRAVEL_START_TIME        IN        DATE default null,
          p_TRAVEL_END_TIME          In        DATE default null,
          p_TRAVEL_DISTANCE_IN_KM    In        NUMBER default null,  -- added for bug 3565704
          p_DML_mode                           VARCHAR2 default NULL -- added for bug 6914559
          );

PROCEDURE Update_Row(
          p_DEBRIEF_HEADER_ID    NUMBER,
          p_DEBRIEF_NUMBER    VARCHAR2,
          p_DEBRIEF_DATE    DATE,
          p_DEBRIEF_STATUS_ID    NUMBER,
          p_TASK_ASSIGNMENT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_object_version_number    IN        NUMBER default null,
          p_TRAVEL_START_TIME        IN        DATE default null,
          p_TRAVEL_END_TIME          In        DATE default null,
          p_TRAVEL_DISTANCE_IN_KM    In        NUMBER default null,
          p_DML_mode                           VARCHAR2 default NULL -- added for bug 6914559
         );

PROCEDURE Lock_Row(
          p_DEBRIEF_HEADER_ID    NUMBER,
          p_DEBRIEF_NUMBER    VARCHAR2,
          p_DEBRIEF_DATE    DATE,
          p_DEBRIEF_STATUS_ID    NUMBER,
          p_TASK_ASSIGNMENT_ID    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_ATTRIBUTE1    VARCHAR2,
          p_ATTRIBUTE2    VARCHAR2,
          p_ATTRIBUTE3    VARCHAR2,
          p_ATTRIBUTE4    VARCHAR2,
          p_ATTRIBUTE5    VARCHAR2,
          p_ATTRIBUTE6    VARCHAR2,
          p_ATTRIBUTE7    VARCHAR2,
          p_ATTRIBUTE8    VARCHAR2,
          p_ATTRIBUTE9    VARCHAR2,
          p_ATTRIBUTE10    VARCHAR2,
          p_ATTRIBUTE11    VARCHAR2,
          p_ATTRIBUTE12    VARCHAR2,
          p_ATTRIBUTE13    VARCHAR2,
          p_ATTRIBUTE14    VARCHAR2,
          p_ATTRIBUTE15    VARCHAR2,
          p_ATTRIBUTE_CATEGORY    VARCHAR2,
          p_object_version_number    IN        NUMBER default null,
          p_TRAVEL_START_TIME        IN        DATE default null,
          p_TRAVEL_END_TIME          In        DATE default null,
          p_TRAVEL_DISTANCE_IN_KM    In        NUMBER default null
          );

PROCEDURE Delete_Row(
    p_DEBRIEF_HEADER_ID  NUMBER,
    p_DML_mode           VARCHAR2 default NULL -- added for bug 6914559
    );

FUNCTION GET_RESOURCE_NAME(
    p_resource_id   number,
    p_resource_type varchar2)
    RETURN varchar2;

END CSF_DEBRIEF_HEADERS_PKG;

/
