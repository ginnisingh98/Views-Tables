--------------------------------------------------------
--  DDL for Package CS_SR_LINK_TYPES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SR_LINK_TYPES_PKG" AUTHID CURRENT_USER AS
/* $Header: cstlntys.pls 115.1 2002/12/04 02:56:22 dejoseph noship $ */

   PROCEDURE INSERT_ROW (
      PX_LINK_TYPE_ID           IN OUT NOCOPY NUMBER,
      P_NAME                    IN VARCHAR2,
      P_DESCRIPTION             IN VARCHAR2,
      P_RECIPROCAL_LINK_TYPE_ID IN NUMBER,
      P_START_DATE_ACTIVE       IN DATE,
      P_END_DATE_ACTIVE         IN DATE,
      P_APPLICATION_ID          IN NUMBER,
      P_SEEDED_FLAG             IN VARCHAR2,
      P_USER_ID                 IN NUMBER, -- used for created and updated by
      P_LOGIN_ID                IN NUMBER, -- used for last update login id.
      P_ATTRIBUTE1              IN VARCHAR2,
      P_ATTRIBUTE2              IN VARCHAR2,
      P_ATTRIBUTE3              IN VARCHAR2,
      P_ATTRIBUTE4              IN VARCHAR2,
      P_ATTRIBUTE5              IN VARCHAR2,
      P_ATTRIBUTE6              IN VARCHAR2,
      P_ATTRIBUTE7              IN VARCHAR2,
      P_ATTRIBUTE8              IN VARCHAR2,
      P_ATTRIBUTE9              IN VARCHAR2,
      P_ATTRIBUTE10             IN VARCHAR2,
      P_ATTRIBUTE11             IN VARCHAR2,
      P_ATTRIBUTE12             IN VARCHAR2,
      P_ATTRIBUTE13             IN VARCHAR2,
      P_ATTRIBUTE14             IN VARCHAR2,
      P_ATTRIBUTE15             IN VARCHAR2,
      P_CONTEXT                 IN VARCHAR2,
      P_OBJECT_VERSION_NUMBER   IN NUMBER,
      P_SECURITY_GROUP_ID       IN NUMBER,
      P_ATTRIBUTE_CONTEXT       IN VARCHAR2,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2,
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER,
      X_RECIPROCAL_LINK_ID      OUT NOCOPY   NUMBER,
      X_LINK_ID			OUT NOCOPY   NUMBER );

   PROCEDURE LOCK_ROW (
      P_LINK_TYPE_ID            IN NUMBER,
      P_OBJECT_VERSION_NUMBER   IN NUMBER );

   PROCEDURE UPDATE_ROW (
      P_LINK_TYPE_ID            IN NUMBER,
      P_RECIPROCAL_LINK_TYPE_ID IN NUMBER,
      P_START_DATE_ACTIVE       IN DATE,
      P_END_DATE_ACTIVE         IN DATE,
      P_APPLICATION_ID          IN NUMBER,
      P_SEEDED_FLAG             IN VARCHAR2,
      P_USER_ID                 IN NUMBER, -- used for created and updated by
      P_LOGIN_ID                IN NUMBER, -- used for last update login id.
      P_ATTRIBUTE1              IN VARCHAR2,
      P_ATTRIBUTE2              IN VARCHAR2,
      P_ATTRIBUTE3              IN VARCHAR2,
      P_ATTRIBUTE4              IN VARCHAR2,
      P_ATTRIBUTE5              IN VARCHAR2,
      P_ATTRIBUTE6              IN VARCHAR2,
      P_ATTRIBUTE7              IN VARCHAR2,
      P_ATTRIBUTE8              IN VARCHAR2,
      P_ATTRIBUTE9              IN VARCHAR2,
      P_ATTRIBUTE10             IN VARCHAR2,
      P_ATTRIBUTE11             IN VARCHAR2,
      P_ATTRIBUTE12             IN VARCHAR2,
      P_ATTRIBUTE13             IN VARCHAR2,
      P_ATTRIBUTE14             IN VARCHAR2,
      P_ATTRIBUTE15             IN VARCHAR2,
      P_CONTEXT                 IN VARCHAR2,
      P_OBJECT_VERSION_NUMBER   IN NUMBER,
      P_SECURITY_GROUP_ID       IN NUMBER,
      P_ATTRIBUTE_CONTEXT       IN VARCHAR2,
      P_NAME                    IN VARCHAR2,
      P_DESCRIPTION             IN VARCHAR2,
      X_RETURN_STATUS	        OUT NOCOPY   VARCHAR2,
      X_MSG_COUNT		OUT NOCOPY   NUMBER,
      X_MSG_DATA		OUT NOCOPY   VARCHAR2,
      X_OBJECT_VERSION_NUMBER   OUT NOCOPY   NUMBER,
      X_RECIPROCAL_LINK_ID      OUT NOCOPY   NUMBER,
      X_LINK_ID			OUT NOCOPY   NUMBER );

   PROCEDURE DELETE_ROW (
      P_LINK_TYPE_ID in NUMBER );

   PROCEDURE ADD_LANGUAGE;

   PROCEDURE TRANSLATE_ROW (
      P_LINK_TYPE_ID            IN NUMBER,
      P_NAME                    IN VARCHAR2,
      P_DESCRIPTION             IN VARCHAR2,
      P_OWNER                   IN VARCHAR2 );

   PROCEDURE LOAD_ROW (
      P_LINK_TYPE_ID            IN NUMBER,
      P_NAME                    IN VARCHAR2,
      P_DESCRIPTION             IN VARCHAR2,
      P_RECIPROCAL_LINK_TYPE_ID IN NUMBER,
      P_START_DATE_ACTIVE       IN VARCHAR2,
      P_END_DATE_ACTIVE         IN VARCHAR2,
      P_OWNER                   IN VARCHAR2,
      P_APPLICATION_ID          IN NUMBER,
      P_SEEDED_FLAG             IN VARCHAR2,
      P_ATTRIBUTE1              IN VARCHAR2,
      P_ATTRIBUTE2              IN VARCHAR2,
      P_ATTRIBUTE3              IN VARCHAR2,
      P_ATTRIBUTE4              IN VARCHAR2,
      P_ATTRIBUTE5              IN VARCHAR2,
      P_ATTRIBUTE6              IN VARCHAR2,
      P_ATTRIBUTE7              IN VARCHAR2,
      P_ATTRIBUTE8              IN VARCHAR2,
      P_ATTRIBUTE9              IN VARCHAR2,
      P_ATTRIBUTE10             IN VARCHAR2,
      P_ATTRIBUTE11             IN VARCHAR2,
      P_ATTRIBUTE12             IN VARCHAR2,
      P_ATTRIBUTE13             IN VARCHAR2,
      P_ATTRIBUTE14             IN VARCHAR2,
      P_ATTRIBUTE15             IN VARCHAR2,
      P_CONTEXT                 IN VARCHAR2,
      P_OBJECT_VERSION_NUMBER   IN NUMBER,
      P_SECURITY_GROUP_ID       IN NUMBER,
      P_ATTRIBUTE_CONTEXT       IN VARCHAR2 );



END CS_SR_LINK_TYPES_PKG;

 

/
