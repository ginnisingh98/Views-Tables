--------------------------------------------------------
--  DDL for Package CS_KB_ELEMENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_ELEMENTS_PKG" AUTHID CURRENT_USER AS
 /* $Header: cskbels.pls 120.0 2005/06/01 09:15:55 appldev noship $ */

 -- For Return Status
 ERROR_STATUS      CONSTANT NUMBER      := -1;

 -- Default Increment for count
 COUNT_INCR  	CONSTANT NUMBER      := 1;
 COUNT_INIT  	CONSTANT NUMBER      := 1;

 PROCEDURE Insert_Row (
   X_ROWID              IN OUT NOCOPY VARCHAR2,
   X_ELEMENT_ID         IN            NUMBER,
   X_ELEMENT_NUMBER     IN            VARCHAR2,
   X_ELEMENT_TYPE_ID    IN            NUMBER,
   X_ELEMENT_NAME       IN            VARCHAR2,
   X_GROUP_FLAG         IN            NUMBER,
   X_STATUS             IN            VARCHAR2,
   X_ACCESS_LEVEL       IN            NUMBER,
   X_NAME               IN            VARCHAR2,
   X_DESCRIPTION        IN            CLOB,
   X_CREATION_DATE      IN            DATE,
   X_CREATED_BY         IN            NUMBER,
   X_LAST_UPDATE_DATE   IN            DATE,
   X_LAST_UPDATED_BY    IN            NUMBER,
   X_LAST_UPDATE_LOGIN  IN            NUMBER,
   X_LOCKED_BY          IN            NUMBER,
   X_LOCK_DATE          IN            DATE,
   X_ATTRIBUTE_CATEGORY IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE1         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE2         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE3         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE4         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE5         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE6         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE7         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE8         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE9         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE10        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE11        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE12        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE13        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE14        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE15        IN            VARCHAR2 DEFAULT NULL,
   X_START_ACTIVE_DATE  IN            DATE     DEFAULT NULL,
   X_END_ACTIVE_DATE    IN            DATE     DEFAULT NULL,
   X_CONTENT_TYPE       IN            VARCHAR2 DEFAULT NULL );


 PROCEDURE Lock_Row (
   X_ELEMENT_ID         IN            NUMBER,
   X_ELEMENT_NUMBER     IN            VARCHAR2,
   X_ELEMENT_TYPE_ID    IN            NUMBER,
   X_ELEMENT_NAME       IN            VARCHAR2,
   X_GROUP_FLAG         IN            NUMBER,
   X_STATUS             IN            VARCHAR2,
   X_ACCESS_LEVEL       IN            NUMBER,
   X_NAME               IN            VARCHAR2,
   X_DESCRIPTION        IN            CLOB,
   X_LOCKED_BY          IN            NUMBER,
   X_LOCK_DATE          IN            DATE,
   X_ATTRIBUTE_CATEGORY IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE1         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE2         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE3         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE4         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE5         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE6         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE7         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE8         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE9         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE10        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE11        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE12        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE13        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE14        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE15        IN            VARCHAR2 DEFAULT NULL,
   X_START_ACTIVE_DATE  IN            DATE     DEFAULT NULL,
   X_END_ACTIVE_DATE    IN            DATE     DEFAULT NULL,
   X_CONTENT_TYPE       IN            VARCHAR2 DEFAULT NULL );

 PROCEDURE Update_Row (
   X_ELEMENT_ID         IN            NUMBER,
   X_ELEMENT_NUMBER     IN            VARCHAR2,
   X_ELEMENT_TYPE_ID    IN            NUMBER,
   X_ELEMENT_NAME       IN            VARCHAR2,
   X_GROUP_FLAG         IN            NUMBER,
   X_STATUS             IN            VARCHAR2,
   X_ACCESS_LEVEL       IN            NUMBER,
   X_NAME               IN            VARCHAR2,
   X_DESCRIPTION        IN            CLOB,
   X_LAST_UPDATE_DATE   IN            DATE,
   X_LAST_UPDATED_BY    IN            NUMBER,
   X_LAST_UPDATE_LOGIN  IN            NUMBER,
   X_LOCKED_BY          IN            NUMBER,
   X_LOCK_DATE          IN            DATE,
   X_ATTRIBUTE_CATEGORY IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE1         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE2         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE3         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE4         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE5         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE6         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE7         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE8         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE9         IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE10        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE11        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE12        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE13        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE14        IN            VARCHAR2 DEFAULT NULL,
   X_ATTRIBUTE15        IN            VARCHAR2 DEFAULT NULL,
   X_START_ACTIVE_DATE  IN            DATE     DEFAULT NULL,
   X_END_ACTIVE_DATE    IN            DATE     DEFAULT NULL,
   X_CONTENT_TYPE       IN            VARCHAR2 DEFAULT NULL );


 PROCEDURE Delete_Row (
   X_ELEMENT_NUMBER IN VARCHAR2 );


 PROCEDURE Add_Language;


 PROCEDURE Translate_Row(
   X_ELEMENT_ID     IN NUMBER,
   X_ELEMENT_NUMBER IN VARCHAR2,
   X_OWNER          IN VARCHAR2,
   X_NAME           IN VARCHAR2,
   X_DESCRIPTION    IN VARCHAR2);


 PROCEDURE Load_Row(
   X_ELEMENT_ID      IN NUMBER,
   X_ELEMENT_NUMBER  IN VARCHAR2,
   X_ELEMENT_TYPE_ID IN NUMBER,
   X_STATUS          IN VARCHAR2,
   X_ACCESS_LEVEL    IN NUMBER,
   X_OWNER           IN VARCHAR2,
   X_NAME            IN VARCHAR2,
   X_DESCRIPTION     IN VARCHAR2);

 PROCEDURE Update_Clobs(
   P_ELEMENT_ID IN NUMBER);

end CS_KB_ELEMENTS_PKG;

 

/
