--------------------------------------------------------
--  DDL for Package Body XLE_UTILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XLE_UTILITY_PUB" AS
/* $Header: xleutilb.pls 120.1 2005/01/21 23:34:01 guyuan ship $ */

FUNCTION created_by RETURN NUMBER IS
BEGIN
    RETURN NVL(FND_GLOBAL.user_id,-1);
END created_by;

FUNCTION creation_date RETURN DATE IS
BEGIN
    RETURN SYSDATE;
END creation_date;

FUNCTION last_updated_by RETURN NUMBER IS
BEGIN
    RETURN NVL(FND_GLOBAL.user_id,-1);
END last_updated_by;

FUNCTION last_update_date RETURN DATE IS
BEGIN
    RETURN SYSDATE;
END last_update_date;

FUNCTION last_update_login RETURN NUMBER IS
BEGIN
    IF FND_GLOBAL.conc_login_id = -1 OR
       FND_GLOBAL.conc_login_id IS NULL
    THEN
        RETURN FND_GLOBAL.login_id;
    ELSE
        RETURN FND_GLOBAL.conc_login_id;
    END IF;
END last_update_login;

END XLE_Utility_PUB;

/
