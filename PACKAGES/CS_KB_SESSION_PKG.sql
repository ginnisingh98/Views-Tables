--------------------------------------------------------
--  DDL for Package CS_KB_SESSION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SESSION_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbsess.pls 120.0 2005/06/01 12:33:09 appldev noship $ */

  /* for return status */
  ERROR_STATUS      CONSTANT NUMBER      := -1;
  OKAY_STATUS       CONSTANT NUMBER      := 0;

  procedure INSERT_ROW
  (
    X_ROWID                OUT NOCOPY VARCHAR2,
    X_SESSION_ID           OUT NOCOPY NUMBER,
    P_SOURCE_OBJECT_CODE    in VARCHAR2,
    P_SOURCE_OBJECT_ID      in NUMBER,
    P_CREATION_DATE         in DATE,
    P_CREATED_BY            in NUMBER,
    P_LAST_UPDATE_DATE      in DATE,
    P_LAST_UPDATED_BY       in NUMBER,
    P_LAST_UPDATE_LOGIN     in NUMBER
  );

  procedure UPDATE_ROW
  (
    P_SESSION_ID            in NUMBER,
    P_SOURCE_OBJECT_CODE    in VARCHAR2,
    P_SOURCE_OBJECT_ID      in NUMBER,
    P_LAST_UPDATE_DATE      in DATE,
    P_LAST_UPDATED_BY       in NUMBER,
    P_LAST_UPDATE_LOGIN     in NUMBER
  );

  procedure DELETE_ROW
  (
    P_SESSION_ID            in NUMBER
  );

  procedure LOAD_ROW
  (
    P_SESSION_ID            in NUMBER,
    P_SOURCE_OBJECT_CODE    in VARCHAR2,
    P_SOURCE_OBJECT_ID      in NUMBER,
    P_OWNER                 in VARCHAR2
  );

END CS_KB_SESSION_PKG;

 

/
