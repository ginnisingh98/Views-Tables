--------------------------------------------------------
--  DDL for Package Body GMD_FORMULA_SECURITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."GMD_FORMULA_SECURITY_PKG" as
/* $Header: GMDFMSCB.pls 120.1 2005/07/26 11:51:04 txdaniel noship $ */

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
    X_LAST_UPDATE_LOGIN IN NUMBER) IS

    CURSOR Cur_get_security_id IS
    SELECT gmd_formula_security_id_s.NextVal
    FROM dual;
    l_formula_security_id	NUMBER;
  BEGIN
    OPEN Cur_get_security_id;
    FETCH Cur_get_security_id INTO l_formula_security_id;
    CLOSE Cur_get_security_id;
    INSERT INTO gmd_formula_security (
    	FORMULA_SECURITY_ID,
    	FORMULA_ID,
    	ACCESS_TYPE_IND,
    	ORGANIZATION_ID,
    	USER_ID,
    	RESPONSIBILITY_ID,
    	OTHER_ORGANIZATION_ID,
    	CREATION_DATE,
    	CREATED_BY,
    	LAST_UPDATE_DATE,
    	LAST_UPDATED_BY,
    	LAST_UPDATE_LOGIN)
    VALUES (
        l_formula_security_id,
    	X_FORMULA_ID,
    	X_ACCESS_TYPE_IND ,
    	X_ORGANIZATION_ID,
    	X_USER_ID,
    	X_RESPONSIBILITY_ID ,
    	X_OTHER_ORGANIZATION_ID,
    	X_CREATION_DATE,
    	X_CREATED_BY,
    	X_LAST_UPDATE_DATE ,
    	X_LAST_UPDATED_BY,
    	X_LAST_UPDATE_LOGIN);
    X_formula_security_id := l_formula_security_id;

    IF (SQL%NOTFOUND) then
      RAISE no_data_found;
    END IF;
  END insert_row;

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
    X_LAST_UPDATE_LOGIN IN NUMBER) IS
  BEGIN
    UPDATE gmd_formula_security SET
    	FORMULA_ID = X_FORMULA_ID,
    	ACCESS_TYPE_IND = X_ACCESS_TYPE_IND,
    	ORGANIZATION_ID = X_ORGANIZATION_ID,
    	USER_ID = X_USER_ID,
    	RESPONSIBILITY_ID = X_RESPONSIBILITY_ID,
    	OTHER_ORGANIZATION_ID = X_OTHER_ORGANIZATION_ID,
    	LAST_UPDATE_DATE = X_LAST_UPDATE_DATE,
    	LAST_UPDATED_BY = X_LAST_UPDATED_BY,
    	LAST_UPDATE_LOGIN = X_LAST_UPDATE_LOGIN
    WHERE FORMULA_SECURITY_ID = X_FORMULA_SECURITY_ID;


    IF (SQL%NOTFOUND) then
      RAISE no_data_found;
    END IF;
  END update_row;

  PROCEDURE delete_row (X_FORMULA_SECURITY_ID in NUMBER) IS
  BEGIN
    DELETE
    FROM gmd_formula_security
    WHERE formula_security_id = X_formula_security_id;

    IF (SQL%NOTFOUND) then
      RAISE no_data_found;
    END IF;

  END delete_row;


end GMD_FORMULA_SECURITY_PKG;

/
