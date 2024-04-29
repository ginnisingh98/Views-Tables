--------------------------------------------------------
--  DDL for Package AMS_DM_SOURCE_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_DM_SOURCE_PKG" AUTHID CURRENT_USER as
/* $Header: amstdsrs.pls 115.9 2003/09/03 19:42:33 nyostos ship $ */
-- Start of Comments
-- Package name     : AMS_DM_SOURCE_PKG
-- Purpose          :
-- History          :
-- 30-jan-2001 choang   Changed p_tree_node to p_rule_id.
-- 07-Jan-2002 choang   Removed security group id
-- 28-Jul-2003 nyostos  Added PERCENTILE column.
-- NOTE             :
-- End of Comments

PROCEDURE Insert_Row(
          px_SOURCE_ID        IN OUT NOCOPY NUMBER,
          p_LAST_UPDATE_DATE  DATE,
          p_LAST_UPDATED_BY   NUMBER,
          p_CREATION_DATE     DATE,
          p_CREATED_BY        NUMBER,
          p_LAST_UPDATE_LOGIN NUMBER,
          px_OBJECT_VERSION_NUMBER  IN OUT NOCOPY NUMBER,
          p_MODEL_TYPE        VARCHAR2,
          p_ARC_USED_FOR_OBJECT     VARCHAR2,
          p_USED_FOR_OBJECT_ID      NUMBER,
          p_PARTY_ID          NUMBER,
          p_SCORE_RESULT      VARCHAR2,
          p_TARGET_VALUE      VARCHAR2,
          p_CONFIDENCE        NUMBER,
          p_CONTINUOUS_SCORE  NUMBER,
          p_decile            NUMBER,
          p_PERCENTILE        NUMBER);

PROCEDURE Update_Row(
          p_SOURCE_ID            NUMBER,
          p_LAST_UPDATE_DATE     DATE,
          p_LAST_UPDATED_BY      NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER   NUMBER,
          p_MODEL_TYPE           VARCHAR2,
          p_ARC_USED_FOR_OBJECT  VARCHAR2,
          p_USED_FOR_OBJECT_ID   NUMBER,
          p_PARTY_ID             NUMBER,
          p_SCORE_RESULT         VARCHAR2,
          p_TARGET_VALUE         VARCHAR2,
          p_CONFIDENCE           NUMBER,
          p_CONTINUOUS_SCORE     NUMBER,
          p_decile               NUMBER,
          p_PERCENTILE           NUMBER);

PROCEDURE Lock_Row(
          p_SOURCE_ID            NUMBER,
          p_LAST_UPDATE_DATE     DATE,
          p_LAST_UPDATED_BY      NUMBER,
          p_CREATION_DATE        DATE,
          p_CREATED_BY           NUMBER,
          p_LAST_UPDATE_LOGIN    NUMBER,
          p_OBJECT_VERSION_NUMBER   NUMBER,
          p_MODEL_TYPE           VARCHAR2,
          p_ARC_USED_FOR_OBJECT  VARCHAR2,
          p_USED_FOR_OBJECT_ID   NUMBER,
          p_PARTY_ID             NUMBER,
          p_SCORE_RESULT         VARCHAR2,
          p_TARGET_VALUE         VARCHAR2,
          p_CONFIDENCE           NUMBER,
          p_CONTINUOUS_SCORE     NUMBER,
          p_decile               NUMBER,
          p_PERCENTILE           NUMBER);

PROCEDURE Delete_Row(
    p_SOURCE_ID  NUMBER);
End AMS_DM_SOURCE_PKG;

 

/
