--------------------------------------------------------
--  DDL for Package FND_APPLICATION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_APPLICATION_PKG" AUTHID CURRENT_USER as
/* $Header: AFSCAPPS.pls 120.3 2005/10/05 13:23:43 pdeluna ship $ */

/* INSERT_ROW */
procedure INSERT_ROW (
  X_ROWID                  in out nocopy VARCHAR2,
  X_APPLICATION_ID         in NUMBER,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_BASEPATH               in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  X_CREATION_DATE          in DATE,
  X_CREATED_BY             in NUMBER,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in NUMBER,
  X_LAST_UPDATE_LOGIN      in NUMBER,
  X_PRODUCT_CODE           in VARCHAR2 default NULL
);

/* LOCK_ROW */
procedure LOCK_ROW (
  X_APPLICATION_ID         in NUMBER,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_BASEPATH               in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2
);

/* UPDATE_ROW */
procedure UPDATE_ROW(
  X_APPLICATION_ID         in NUMBER,
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_BASEPATH               in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  X_LAST_UPDATE_DATE       in DATE,
  X_LAST_UPDATED_BY        in NUMBER,
  X_LAST_UPDATE_LOGIN      in NUMBER,
  X_PRODUCT_CODE           in VARCHAR2 default NULL
);

/* LOAD_ROW*/
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_BASEPATH               in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  X_PRODUCT_CODE           in VARCHAR2 default NULL
);

/* Overloaded version #1 of LOAD_ROW. */
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_BASEPATH               in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  X_CUSTOM_MODE            in VARCHAR2,
  X_LAST_UPDATE_DATE       in VARCHAR2,
  X_PRODUCT_CODE           in VARCHAR2 default NULL
);

/* Overloaded version #2 of LOAD_ROW. */
procedure LOAD_ROW (
  X_APPLICATION_SHORT_NAME   in VARCHAR2,
  X_APPLICATION_ID           in NUMBER,
  X_OWNER                    in VARCHAR2,
  X_BASEPATH                 in VARCHAR2,
  X_APPLICATION_NAME         in VARCHAR2,
  X_DESCRIPTION              in VARCHAR2,
  X_CUSTOM_MODE              in VARCHAR2,
  X_LAST_UPDATE_DATE         in VARCHAR2,
  X_PRODUCT_CODE             in VARCHAR2 default NULL
);

/* TRANSLATE_ROW */
procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2
);

/* Overloaded version of TRANSLATE_ROW */
procedure TRANSLATE_ROW (
  X_APPLICATION_SHORT_NAME in VARCHAR2,
  X_OWNER                  in VARCHAR2,
  X_APPLICATION_NAME       in VARCHAR2,
  X_DESCRIPTION            in VARCHAR2,
  x_custom_mode            in VARCHAR2,
  x_last_update_date       in VARCHAR2
);

/* DELETE_ROW */
procedure DELETE_ROW (
  X_APPLICATION_ID in NUMBER
);

/* ADD_LANGUAGE */
procedure ADD_LANGUAGE;

end FND_APPLICATION_PKG;

 

/
