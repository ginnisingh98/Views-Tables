--------------------------------------------------------
--  DDL for Package BSC_SYS_IMAGES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."BSC_SYS_IMAGES_PKG" AUTHID CURRENT_USER AS
/* $Header: BSCSYSIS.pls 120.0 2005/06/01 14:54:39 appldev noship $ */

PROCEDURE UPDATE_ROW
(
    X_FILE_NAME               IN VARCHAR2,
    X_DESCRIPTION             IN VARCHAR2,
    X_WIDTH                   IN NUMBER,
    X_HEIGHT                  IN NUMBER,
    X_LAST_UPDATE_DATE        IN VARCHAR2,
    X_LAST_UPDATED_BY         IN NUMBER,
    X_LAST_UPDATE_LOGIN       IN NUMBER
);

PROCEDURE UPDATE_ROW
(
    X_FILE_NAME               IN VARCHAR2,
    X_DESCRIPTION             IN VARCHAR2,
    X_WIDTH                   IN NUMBER,
    X_HEIGHT                  IN NUMBER,
    X_MIME_TYPE               IN VARCHAR2,
    X_LAST_UPDATE_DATE        IN VARCHAR2,
    X_LAST_UPDATED_BY         IN NUMBER,
    X_LAST_UPDATE_LOGIN       IN NUMBER
);

PROCEDURE INSERT_ROW
(
    X_IMAGE_ID                  IN NUMBER,
    X_FILE_NAME                 IN VARCHAR2,
    X_DESCRIPTION               IN VARCHAR2,
    X_WIDTH                     IN NUMBER,
    X_HEIGHT                    IN NUMBER,
    X_CREATED_BY                IN  NUMBER,
    X_LAST_UPDATED_BY           IN  NUMBER,
    X_LAST_UPDATE_LOGIN         IN  NUMBER
);

PROCEDURE INSERT_ROW
(
    X_IMAGE_ID                  IN NUMBER,
    X_FILE_NAME                 IN VARCHAR2,
    X_DESCRIPTION               IN VARCHAR2,
    X_WIDTH                     IN NUMBER,
    X_HEIGHT                    IN NUMBER,
    X_MIME_TYPE                 IN VARCHAR2,
    X_CREATED_BY                IN NUMBER,
    X_LAST_UPDATED_BY           IN NUMBER,
    X_LAST_UPDATE_LOGIN         IN NUMBER
);

END BSC_SYS_IMAGES_PKG;

 

/
