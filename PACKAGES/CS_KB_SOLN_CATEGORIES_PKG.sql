--------------------------------------------------------
--  DDL for Package CS_KB_SOLN_CATEGORIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SOLN_CATEGORIES_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbcats.pls 115.6 2003/08/06 23:16:59 dtian noship $ */

  procedure INSERT_ROW
  (
    X_ROWID                in OUT NOCOPY   VARCHAR2,
    X_CATEGORY_ID          in OUT NOCOPY   NUMBER,
    X_PARENT_CATEGORY_ID   in       NUMBER,
    X_NAME                 in       VARCHAR2,
    X_DESCRIPTION          in       VARCHAR2,
    X_CREATION_DATE        in       DATE,
    X_CREATED_BY           in       NUMBER,
    X_LAST_UPDATE_DATE     in       DATE,
    X_LAST_UPDATED_BY      in       NUMBER,
    X_LAST_UPDATE_LOGIN    in       NUMBER,
    X_VISIBILITY_ID        in       NUMBER
  );

  procedure UPDATE_ROW
  (
    X_CATEGORY_ID          in       NUMBER,
    X_PARENT_CATEGORY_ID   in       NUMBER,
    X_NAME                 in       VARCHAR2,
    X_DESCRIPTION          in       VARCHAR2,
    X_LAST_UPDATE_DATE     in       DATE,
    X_LAST_UPDATED_BY      in       NUMBER,
    X_LAST_UPDATE_LOGIN    in       NUMBER,
    X_VISIBILITY_ID        in       NUMBER
  );

  procedure DELETE_ROW
  (
    X_CATEGORY_ID          in       NUMBER
  );

  procedure LOCK_ROW
  (
    X_CATEGORY_ID          in       NUMBER,
    X_PARENT_CATEGORY_ID   in       NUMBER,
    X_NAME                 in       VARCHAR2,
    X_DESCRIPTION          in       VARCHAR2,
    X_CREATION_DATE        in       DATE,
    X_CREATED_BY           in       NUMBER,
    X_LAST_UPDATE_DATE     in       DATE,
    X_LAST_UPDATED_BY      in       NUMBER,
    X_LAST_UPDATE_LOGIN    in       NUMBER,
    X_VISIBILITY_ID        in       NUMBER
  );

  procedure ADD_LANGUAGE;

  PROCEDURE TRANSLATE_ROW
  (
    X_CATEGORY_ID           in NUMBER,
    X_NAME                  in VARCHAR2,
    X_DESCRIPTION           in VARCHAR2,
    X_OWNER                 in VARCHAR2
  );

  PROCEDURE LOAD_ROW
  (
    X_CATEGORY_ID           in NUMBER,
    X_PARENT_CATEGORY_ID    in NUMBER,
    X_NAME                  in VARCHAR2,
    X_DESCRIPTION           in VARCHAR2,
    X_OWNER                 in VARCHAR2,
    X_VISIBILITY_ID         in NUMBER
  );

END CS_KB_SOLN_CATEGORIES_PKG;

 

/
