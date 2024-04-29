--------------------------------------------------------
--  DDL for Package CS_SYSTEM_OPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_SYSTEM_OPTIONS_PKG" AUTHID CURRENT_USER AS
/* $Header: cstsyops.pls 120.0 2005/08/12 15:27:08 aneemuch noship $ */

PROCEDURE INSERT_ROW (
   P_SYSTEM_OPTION_ID          IN   NUMBER,
   P_SR_AGENT_SECURITY         IN   VARCHAR2,
   P_SS_SRTYPE_RESTRICT        IN   VARCHAR2,
   P_CREATION_DATE             IN   DATE,
   P_CREATED_BY                IN   NUMBER,
   P_LAST_UPDATE_DATE          IN   DATE,
   P_LAST_UPDATED_BY           IN   NUMBER,
   P_LAST_UPDATE_LOGIN         IN   NUMBER,
   P_ATTRIBUTE1                IN   VARCHAR2,
   P_ATTRIBUTE2                IN   VARCHAR2,
   P_ATTRIBUTE3                IN   VARCHAR2,
   P_ATTRIBUTE4                IN   VARCHAR2,
   P_ATTRIBUTE5                IN   VARCHAR2,
   P_ATTRIBUTE6                IN   VARCHAR2,
   P_ATTRIBUTE7                IN   VARCHAR2,
   P_ATTRIBUTE8                IN   VARCHAR2,
   P_ATTRIBUTE9                IN   VARCHAR2,
   P_ATTRIBUTE10               IN   VARCHAR2,
   P_ATTRIBUTE11               IN   VARCHAR2,
   P_ATTRIBUTE12               IN   VARCHAR2,
   P_ATTRIBUTE13               IN   VARCHAR2,
   P_ATTRIBUTE14               IN   VARCHAR2,
   P_ATTRIBUTE15               IN   VARCHAR2,
   P_ATTRIBUTE_CATEGORY        IN   VARCHAR2,
   P_OBJECT_VERSION_NUMBER     IN   NUMBER );


PROCEDURE LOCK_ROW (
   P_SYSTEM_OPTION_ID          IN   NUMBER,
   P_OBJECT_VERSION_NUMBER     IN   NUMBER );


PROCEDURE UPDATE_ROW (
   P_SYSTEM_OPTION_ID          IN   NUMBER,
   P_SR_AGENT_SECURITY         IN   VARCHAR2,
   P_SS_SRTYPE_RESTRICT        IN   VARCHAR2,
   P_LAST_UPDATE_DATE          IN   DATE,
   P_LAST_UPDATED_BY           IN   NUMBER,
   P_LAST_UPDATE_LOGIN         IN   NUMBER,
   P_ATTRIBUTE1                IN   VARCHAR2,
   P_ATTRIBUTE2                IN   VARCHAR2,
   P_ATTRIBUTE3                IN   VARCHAR2,
   P_ATTRIBUTE4                IN   VARCHAR2,
   P_ATTRIBUTE5                IN   VARCHAR2,
   P_ATTRIBUTE6                IN   VARCHAR2,
   P_ATTRIBUTE7                IN   VARCHAR2,
   P_ATTRIBUTE8                IN   VARCHAR2,
   P_ATTRIBUTE9                IN   VARCHAR2,
   P_ATTRIBUTE10               IN   VARCHAR2,
   P_ATTRIBUTE11               IN   VARCHAR2,
   P_ATTRIBUTE12               IN   VARCHAR2,
   P_ATTRIBUTE13               IN   VARCHAR2,
   P_ATTRIBUTE14               IN   VARCHAR2,
   P_ATTRIBUTE15               IN   VARCHAR2,
   P_ATTRIBUTE_CATEGORY        IN   VARCHAR2,
   P_OBJECT_VERSION_NUMBER     IN   NUMBER );


PROCEDURE DELETE_ROW (
   P_SYSTEM_OPTION_ID          IN   NUMBER );

PROCEDURE LOAD_ROW (
   P_SYSTEM_OPTION_ID          IN   NUMBER,
   P_SR_AGENT_SECURITY         IN   VARCHAR2,
   P_SS_SRTYPE_RESTRICT        IN   VARCHAR2,
   P_CREATION_DATE             IN   VARCHAR2,
   P_CREATED_BY                IN   NUMBER,
   P_LAST_UPDATE_DATE          IN   VARCHAR2,
   P_LAST_UPDATED_BY           IN   NUMBER,
   P_LAST_UPDATE_LOGIN         IN   NUMBER,
   P_OWNER                     IN   VARCHAR2,
   P_ATTRIBUTE1                IN   VARCHAR2,
   P_ATTRIBUTE2                IN   VARCHAR2,
   P_ATTRIBUTE3                IN   VARCHAR2,
   P_ATTRIBUTE4                IN   VARCHAR2,
   P_ATTRIBUTE5                IN   VARCHAR2,
   P_ATTRIBUTE6                IN   VARCHAR2,
   P_ATTRIBUTE7                IN   VARCHAR2,
   P_ATTRIBUTE8                IN   VARCHAR2,
   P_ATTRIBUTE9                IN   VARCHAR2,
   P_ATTRIBUTE10               IN   VARCHAR2,
   P_ATTRIBUTE11               IN   VARCHAR2,
   P_ATTRIBUTE12               IN   VARCHAR2,
   P_ATTRIBUTE13               IN   VARCHAR2,
   P_ATTRIBUTE14               IN   VARCHAR2,
   P_ATTRIBUTE15               IN   VARCHAR2,
   P_ATTRIBUTE_CATEGORY        IN   VARCHAR2,
   P_OBJECT_VERSION_NUMBER     IN   NUMBER );

END CS_SYSTEM_OPTIONS_PKG;

 

/
