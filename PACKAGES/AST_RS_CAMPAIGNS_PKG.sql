--------------------------------------------------------
--  DDL for Package AST_RS_CAMPAIGNS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AST_RS_CAMPAIGNS_PKG" AUTHID CURRENT_USER as
/* $Header: asttrcas.pls 120.1 2005/06/01 04:21:46 appldev  $ */
-- Start of Comments
-- Package name     : AST_RS_CAMPAIGNS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_RS_CAMPAIGN_ID   IN OUT NOCOPY /* file.sql.39 change */ NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_CAMPAIGN_ID    NUMBER,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_STATUS    VARCHAR2,
          p_ENABLED_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    VARCHAR2);

PROCEDURE Update_Row(
          p_RS_CAMPAIGN_ID    NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_CAMPAIGN_ID    NUMBER,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_STATUS    VARCHAR2,
          p_ENABLED_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    VARCHAR2);

PROCEDURE Lock_Row(
          p_RS_CAMPAIGN_ID    NUMBER,
          p_RESOURCE_ID    NUMBER,
          p_CAMPAIGN_ID    NUMBER,
          p_START_DATE    DATE,
          p_END_DATE    DATE,
          p_STATUS    VARCHAR2,
          p_ENABLED_FLAG    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATE_LOGIN    VARCHAR2);

PROCEDURE Delete_Row(
    p_RS_CAMPAIGN_ID  NUMBER);
End AST_RS_CAMPAIGNS_PKG;

 

/
