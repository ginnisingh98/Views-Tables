--------------------------------------------------------
--  DDL for Package CSC_PROF_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_GROUPS_PKG" AUTHID CURRENT_USER as
/* $Header: csctpgrs.pls 115.10 2002/12/03 18:29:06 jamose ship $ */
-- Start of Comments
-- Package name     : CSC_PROF_GROUPS_PKG
-- Purpose          :
-- History          :
-- 29 Nov 02   jamose made changes for the NOCOPY and FND_API.G_MISS*
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_GROUP_ID   IN OUT NOCOPY NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_GROUP_NAME    VARCHAR2,
          p_GROUP_NAME_CODE    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_USE_IN_CUSTOMER_DASHBOARD    VARCHAR2,
          p_PARTY_TYPE    VARCHAR2,
          p_SEEDED_FLAG    VARCHAR2,
	       x_OBJECT_VERSION_NUMBER OUT NOCOPY NUMBER,
          p_APPLICATION_ID    NUMBER);


PROCEDURE Update_Row(
          p_GROUP_ID    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_GROUP_NAME    VARCHAR2,
          p_GROUP_NAME_CODE    VARCHAR2,
          p_DESCRIPTION    VARCHAR2,
          p_START_DATE_ACTIVE    DATE,
          p_END_DATE_ACTIVE    DATE,
          p_USE_IN_CUSTOMER_DASHBOARD    VARCHAR2,
          p_PARTY_TYPE    VARCHAR2,
          p_SEEDED_FLAG    VARCHAR2,
	  px_OBJECT_VERSION_NUMBER IN OUT NOCOPY NUMBER,
          p_APPLICATION_ID    NUMBER );

PROCEDURE Delete_Row(
    p_GROUP_ID  NUMBER,
    p_OBJECT_VERSION_NUMBER NUMBER);

procedure LOCK_ROW (
  P_GROUP_ID in NUMBER,
  P_OBJECT_VERSION_NUMBER in NUMBER );

procedure ADD_LANGUAGE;

PROCEDURE TRANSLATE_ROW (
   p_group_id                    IN      NUMBER,
   p_group_name                  IN      VARCHAR2,
   p_description                 IN      VARCHAR2,
   p_owner                       IN      VARCHAR2 );

PROCEDURE LOAD_ROW(
   p_GROUP_ID                    IN      NUMBER,
   p_LAST_UPDATED_BY             IN      NUMBER,
   p_LAST_UPDATE_DATE            IN      DATE,
   p_LAST_UPDATE_LOGIN           IN      NUMBER,
   p_GROUP_NAME                  IN      VARCHAR2,
   p_GROUP_NAME_CODE             IN      VARCHAR2,
   p_DESCRIPTION                 IN      VARCHAR2,
   p_START_DATE_ACTIVE           IN      DATE,
   p_END_DATE_ACTIVE             IN      DATE,
   p_USE_IN_CUSTOMER_DASHBOARD   IN      VARCHAR2,
   p_PARTY_TYPE                  IN      VARCHAR2,
   p_SEEDED_FLAG		 IN      VARCHAR2,
   px_OBJECT_VERSION_NUMBER      IN OUT NOCOPY NUMBER ,
   p_APPLICATION_ID              IN      NUMBER,
   p_OWNER                       IN      VARCHAR2);

End CSC_PROF_GROUPS_PKG;

 

/
