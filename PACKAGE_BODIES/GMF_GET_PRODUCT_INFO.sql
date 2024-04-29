--------------------------------------------------------
--  DDL for Package Body GMF_GET_PRODUCT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMF_GET_PRODUCT_INFO" AS
/* $Header: gmfgtprb.pls 115.2 2002/11/11 00:38:16 rseshadr ship $ */
  CURSOR CUR_GMS_GET_PRODUCT_INFO IS
  SELECT PR.PRODUCT_GROUP_ID,
         PR.PRODUCT_GROUP_NAME,
         PR.RELEASE_NAME,
         -99,
         PR.PRODUCT_GROUP_TYPE,
         PR.ARGUMENT1,
         PR.MULTI_ORG_FLAG,
         PR.MULTI_LINGUAL_FLAG,
         '',
         PR.LAST_UPDATE_DATE,
         PR.LAST_UPDATED_BY,
         PR.CREATION_DATE,
         PR.CREATED_BY
  FROM   FND_PRODUCT_GROUPS PR;
  PROCEDURE GMS_GET_PRODUCT_INFO
         (PRODUCT_GROUP_ID               OUT    NOCOPY NUMBER,
          PRODUCT_GROUP_NAME             OUT    NOCOPY VARCHAR2,
          RELEASE_NAME                   OUT    NOCOPY VARCHAR2,
          LANGUAGE_ID                    OUT    NOCOPY NUMBER,
          PRODUCT_GROUP_TYPE             OUT    NOCOPY VARCHAR2,
          ARGUMENT1                      OUT    NOCOPY VARCHAR2,
          MULTI_ORG_FLAG                 OUT    NOCOPY VARCHAR2,
          MULTI_LINGUAL_FLAG             OUT    NOCOPY VARCHAR2,
          CODESET                        OUT    NOCOPY VARCHAR2,
          CREATED_BY                     OUT    NOCOPY NUMBER,
          CREATION_DATE                  OUT    NOCOPY DATE,
          LAST_UPDATE_DATE               OUT    NOCOPY DATE,
          LAST_UPDATED_BY                OUT    NOCOPY NUMBER,
          ROW_TO_FETCH                   IN OUT NOCOPY NUMBER,
          ERROR_STATUS                   OUT    NOCOPY NUMBER)   IS
/*    CREATEDBY   NUMBER;*/
/*    MODIFIEDBY  NUMBER;*/
    BEGIN
      IF NOT CUR_GMS_GET_PRODUCT_INFO%ISOPEN THEN
        OPEN CUR_GMS_GET_PRODUCT_INFO;
      END IF;
      FETCH CUR_GMS_GET_PRODUCT_INFO
      INTO  PRODUCT_GROUP_ID,               PRODUCT_GROUP_NAME,
            RELEASE_NAME,                   LANGUAGE_ID,
            PRODUCT_GROUP_TYPE,             ARGUMENT1,
            MULTI_ORG_FLAG,                 MULTI_LINGUAL_FLAG,
            CODESET,
            LAST_UPDATE_DATE,               LAST_UPDATED_BY,
            CREATION_DATE,                  CREATED_BY;
      IF CUR_GMS_GET_PRODUCT_INFO%NOTFOUND THEN
        ERROR_STATUS := 100;
        CLOSE CUR_GMS_GET_PRODUCT_INFO;
/*      ELSE*/
/*        CREATED_BY := PKG_FND_GET_USERS.FND_GET_USERS(CREATEDBY);*/
/*        LAST_UPDATED_BY := PKG_FND_GET_USERS.FND_GET_USERS(MODIFIEDBY);*/
      END IF;
      IF ROW_TO_FETCH = 1 AND CUR_GMS_GET_PRODUCT_INFO%ISOPEN THEN
        CLOSE CUR_GMS_GET_PRODUCT_INFO;
      END IF;
      EXCEPTION
        WHEN OTHERS THEN
          ERROR_STATUS := SQLCODE;
  END GMS_GET_PRODUCT_INFO;
END GMF_GET_PRODUCT_INFO;

/
