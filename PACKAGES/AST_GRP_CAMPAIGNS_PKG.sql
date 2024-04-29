--------------------------------------------------------
--  DDL for Package AST_GRP_CAMPAIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_GRP_CAMPAIGNS_PKG" AUTHID CURRENT_USER as
/* $Header: asttgcas.pls 120.1 2005/06/01 03:41:33 appldev  $ */
-- Start of Comments
-- Package name     : AST_GRP_CAMPAIGNS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_GROUP_CAMPAIGN_ID   IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
          p_GROUP_ID    NUMBER,
          p_CAMPAIGN_ID    NUMBER,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_ENABLED_FLAG    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE);

PROCEDURE Update_Row(
          p_GROUP_CAMPAIGN_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_CAMPAIGN_ID    NUMBER,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_ENABLED_FLAG    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE);

PROCEDURE Lock_Row(
          p_GROUP_CAMPAIGN_ID    NUMBER,
          p_GROUP_ID    NUMBER,
          p_CAMPAIGN_ID    NUMBER,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_ENABLED_FLAG    VARCHAR2,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE);

PROCEDURE Delete_Row(
    p_GROUP_CAMPAIGN_ID  NUMBER);
End AST_GRP_CAMPAIGNS_PKG;

 

/
