--------------------------------------------------------
--  DDL for Package HZ_MERGE_BATCH_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HZ_MERGE_BATCH_PKG" AUTHID CURRENT_USER as
/* $Header: ARHMBTBS.pls 120.2 2005/06/16 21:12:24 jhuang noship $ */
-- Start of Comments
-- Package name     : HZ_MERGE_BATCH_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_BATCH_ID   IN OUT NOCOPY NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_BATCH_NAME    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_BATCH_STATUS    VARCHAR2,
          p_BATCH_COMMIT    VARCHAR2,
          p_BATCH_DELETE    VARCHAR2,
          p_MERGE_REASON_CODE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER);

PROCEDURE Update_Row(
          p_BATCH_ID    NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_BATCH_NAME    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_BATCH_STATUS    VARCHAR2,
          p_BATCH_COMMIT    VARCHAR2,
          p_BATCH_DELETE    VARCHAR2,
          p_MERGE_REASON_CODE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER);

PROCEDURE Lock_Row(
          p_BATCH_ID    NUMBER,
          p_RULE_SET_NAME    VARCHAR2,
          p_BATCH_NAME    VARCHAR2,
          p_REQUEST_ID    NUMBER,
          p_BATCH_STATUS    VARCHAR2,
          p_BATCH_COMMIT    VARCHAR2,
          p_BATCH_DELETE    VARCHAR2,
          p_MERGE_REASON_CODE    VARCHAR2,
          p_CREATED_BY    NUMBER,
          p_CREATION_DATE    DATE,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_LAST_UPDATE_DATE    DATE,
          p_LAST_UPDATED_BY    NUMBER);

PROCEDURE Delete_Row(
    p_BATCH_ID  NUMBER);
End HZ_MERGE_BATCH_PKG;

 

/
