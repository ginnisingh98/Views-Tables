--------------------------------------------------------
--  DDL for Package CS_KB_SESSION_ATTR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CS_KB_SESSION_ATTR_PKG" AUTHID CURRENT_USER AS
/* $Header: cskbssas.pls 115.5 2002/11/11 23:53:03 mkettle noship $ */

  /* for return status */
  ERROR_STATUS      CONSTANT NUMBER      := -1;
  OKAY_STATUS       CONSTANT NUMBER      := 0;

  /* Valid session attributes */
  PRODUCT_ATTR      CONSTANT VARCHAR2(30) := 'PRODUCT';

  /* HIGH LEVEL TABLE HANDLERS */

  function add_km_session_attr
  (
    X_SESSION_ATTR_ID     OUT NOCOPY NUMBER,
    P_SESSION_ID           in NUMBER,
    P_ATTRIBUTE_TYPE       in VARCHAR2,
    P_ATTRIBUTE_NAME       in VARCHAR2,
    P_VALUE1               in VARCHAR2,
    P_VALUE2               in VARCHAR2 DEFAULT NULL
  ) return number;

  function update_km_session_attr
  (
    P_SESSION_ATTR_ID      in NUMBER,
    P_SESSION_ID           in NUMBER,
    P_ATTRIBUTE_TYPE       in VARCHAR2,
    P_ATTRIBUTE_NAME       in VARCHAR2,
    P_VALUE1               in VARCHAR2,
    P_VALUE2               in VARCHAR2 DEFAULT NULL
  ) return number;

  function remove_km_session_attr
  (
    P_SESSION_ATTR_ID      in NUMBER
  ) return number;

  function remove_all_km_session_attrs
  (
    P_SESSION_ID           in NUMBER
  ) return number;


  /* LOW LEVEL TABLE HANDLERS */

  procedure INSERT_ROW
  (
    X_ROWID                OUT NOCOPY VARCHAR2,
    X_SESSION_ATTR_ID      OUT NOCOPY NUMBER,
    P_SESSION_ID            in NUMBER,
    P_ATTRIBUTE_TYPE        in VARCHAR2,
    P_ATTRIBUTE_NAME       in VARCHAR2,
    P_VALUE1                in VARCHAR2,
    P_VALUE2                in VARCHAR2 DEFAULT NULL,
    P_CREATION_DATE         in DATE,
    P_CREATED_BY            in NUMBER,
    P_LAST_UPDATE_DATE      in DATE,
    P_LAST_UPDATED_BY       in NUMBER,
    P_LAST_UPDATE_LOGIN     in NUMBER
  );

  procedure UPDATE_ROW
  (
    P_SESSION_ATTR_ID       in NUMBER,
    P_SESSION_ID            in NUMBER,
    P_ATTRIBUTE_TYPE        in VARCHAR2,
    P_ATTRIBUTE_NAME       in VARCHAR2,
    P_VALUE1                in VARCHAR2,
    P_VALUE2                in VARCHAR2 DEFAULT NULL,
    P_LAST_UPDATE_DATE      in DATE,
    P_LAST_UPDATED_BY       in NUMBER,
    P_LAST_UPDATE_LOGIN     in NUMBER
  );

  procedure DELETE_ROW
  (
    P_SESSION_ATTR_ID       in NUMBER
  );

  procedure LOAD_ROW
  (
    P_SESSION_ATTR_ID       in NUMBER,
    P_SESSION_ID            in NUMBER,
    P_ATTRIBUTE_TYPE        in VARCHAR2,
    P_ATTRIBUTE_NAME       in VARCHAR2,
    P_VALUE1                in VARCHAR2,
    P_VALUE2                in VARCHAR2 DEFAULT NULL,
    P_OWNER                 in VARCHAR2
  );

END CS_KB_SESSION_ATTR_PKG;

 

/
