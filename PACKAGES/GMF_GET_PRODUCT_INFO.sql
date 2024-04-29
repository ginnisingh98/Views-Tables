--------------------------------------------------------
--  DDL for Package GMF_GET_PRODUCT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMF_GET_PRODUCT_INFO" AUTHID CURRENT_USER AS
/* $Header: gmfgtprs.pls 115.1 2002/11/11 00:38:25 rseshadr ship $ */
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
               ERROR_STATUS                   OUT    NOCOPY NUMBER);
END GMF_GET_PRODUCT_INFO;

 

/
