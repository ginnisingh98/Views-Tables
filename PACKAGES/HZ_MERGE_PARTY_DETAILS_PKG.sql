--------------------------------------------------------
--  DDL for Package HZ_MERGE_PARTY_DETAILS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MERGE_PARTY_DETAILS_PKG" AUTHID CURRENT_USER as
/* $Header: ARHPDTBS.pls 120.2 2005/10/30 04:22:05 appldev noship $ */
-- Start of Comments
-- Package name     : HZ_MERGE_PARTY_DETAILS_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          p_BATCH_PARTY_ID    NUMBER,
          p_ENTITY_NAME    VARCHAR2,
          p_MERGE_FROM_ENTITY_ID    NUMBER,
          p_MERGE_TO_ENTITY_ID    NUMBER,
          p_MANDATORY_MERGE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER);

PROCEDURE Update_Row(
          p_BATCH_PARTY_ID    NUMBER,
          p_ENTITY_NAME    VARCHAR2,
          p_MERGE_FROM_ENTITY_ID    NUMBER,
          p_MERGE_TO_ENTITY_ID    NUMBER,
          p_MANDATORY_MERGE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER);

PROCEDURE Lock_Row(
          p_BATCH_PARTY_ID    NUMBER,
          p_ENTITY_NAME    VARCHAR2,
          p_MERGE_FROM_ENTITY_ID    NUMBER,
          p_MERGE_TO_ENTITY_ID    NUMBER,
          p_MANDATORY_MERGE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER);

PROCEDURE Delete_Row(
    p_BATCH_PARTY_ID  NUMBER,
    p_ENTITY_NAME    VARCHAR2,
    p_MERGE_FROM_ENTITY_ID    NUMBER);

End HZ_MERGE_PARTY_DETAILS_PKG;

 

/
