--------------------------------------------------------
--  DDL for Package CSC_PROF_GROUP_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_PROF_GROUP_CATEGORIES_PKG" AUTHID CURRENT_USER as
/* $Header: csctpcas.pls 120.1 2005/08/24 03:04:06 vshastry noship $ */
-- Start of Comments
-- Package name     : CSC_PROF_GROUP_CATEGORIES_PKG
-- Purpose          :
-- History          :
-- 26 Nov 2002 JAmose For Fnd_Api.G_Miss* changes
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_GROUP_CATEGORY_ID   IN OUT NOCOPY NUMBER,
          p_GROUP_ID    NUMBER,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG     VARCHAR2);

PROCEDURE Update_Row(
          p_GROUP_CATEGORY_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG     VARCHAR2);

PROCEDURE Lock_Row(
          p_GROUP_CATEGORY_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_CATEGORY_CODE    VARCHAR2,
          p_CATEGORY_SEQUENCE    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_SEEDED_FLAG     VARCHAR2);

PROCEDURE Delete_Row(
          p_GROUP_CATEGORY_ID  NUMBER);

Procedure LOAD_ROW (
 	  p_GROUP_CATEGORY_ID    IN NUMBER,
 	  p_GROUP_ID             IN NUMBER,
 	  p_CATEGORY_CODE        IN VARCHAR2,
 	  p_CATEGORY_SEQUENCE    IN NUMBER,
          p_SEEDED_FLAG          IN VARCHAR2,
          p_last_updated_by      IN NUMBER,
          p_last_update_date     IN DATE ) ;

End CSC_PROF_GROUP_CATEGORIES_PKG;

 

/
