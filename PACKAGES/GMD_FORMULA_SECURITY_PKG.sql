--------------------------------------------------------
--  DDL for Package GMD_FORMULA_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GMD_FORMULA_SECURITY_PKG" AUTHID CURRENT_USER as
/* $Header: GMDFMSCS.pls 120.1 2005/07/26 11:49:47 txdaniel noship $ */

  PROCEDURE insert_row (
    X_FORMULA_SECURITY_ID OUT NOCOPY  NUMBER,
    X_FORMULA_ID IN NUMBER,
    X_ACCESS_TYPE_IND IN VARCHAR2,
    X_ORGANIZATION_ID IN NUMBER,
    X_USER_ID IN NUMBER,
    X_RESPONSIBILITY_ID IN NUMBER,
    X_OTHER_ORGANIZATION_ID IN NUMBER,
    X_CREATION_DATE IN DATE,
    X_CREATED_BY IN NUMBER,
    X_LAST_UPDATE_DATE IN DATE,
    X_LAST_UPDATED_BY IN NUMBER,
    X_LAST_UPDATE_LOGIN IN NUMBER);

  PROCEDURE update_row (
    X_FORMULA_SECURITY_ID IN NUMBER,
    X_FORMULA_ID IN NUMBER,
    X_ACCESS_TYPE_IND IN VARCHAR2,
    X_ORGANIZATION_ID IN NUMBER,
    X_USER_ID IN NUMBER,
    X_RESPONSIBILITY_ID IN NUMBER,
    X_OTHER_ORGANIZATION_ID IN NUMBER,
    X_LAST_UPDATE_DATE IN DATE,
    X_LAST_UPDATED_BY IN NUMBER,
    X_LAST_UPDATE_LOGIN IN NUMBER);

  PROCEDURE delete_row (X_FORMULA_SECURITY_ID IN NUMBER);

end GMD_FORMULA_SECURITY_PKG;

 

/