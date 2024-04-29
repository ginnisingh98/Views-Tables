--------------------------------------------------------
--  DDL for Package Body ENG_ECO_PRIOR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENG_ECO_PRIOR_PKG" as
/* $Header: engpecpb.pls 115.2 2003/02/07 09:07:07 rbehal ship $ */


PROCEDURE Check_Unique(
	X_Org_id	NUMBER,
	X_Priority_code VARCHAR2) IS
    dummy	number;
BEGIN
    select 1 into dummy from dual where not exists
	(select 1 from eng_change_priorities
	where ENG_CHANGE_PRIORITY_CODE = X_Priority_code
	and   ORGANIZATION_ID = X_Org_id
	);
EXCEPTION
    when NO_DATA_FOUND then
	FND_MESSAGE.SET_NAME('INV', 'INV_ALREADY_EXISTS');
        FND_MESSAGE.SET_TOKEN('ENTITY', X_Priority_Code);
	APP_EXCEPTION.RAISE_EXCEPTION;
END Check_Unique;

PROCEDURE CHECK_REFERENCES(
	X_Org_id	NUMBER,
	X_Priority_code VARCHAR2) IS
DUMMY        NUMBER;
BEGIN
       SELECT 1 INTO DUMMY FROM DUAL WHERE NOT EXISTS
         (SELECT 1 FROM ENG_ENGINEERING_CHANGES
          WHERE ORGANIZATION_ID = X_Org_id
            AND PRIORITY_CODE = X_Priority_code
         );

EXCEPTION
    WHEN NO_DATA_FOUND THEN
         FND_MESSAGE.SET_NAME('ENG', 'ENG_CANNOT_DELETE_USED');
         FND_MESSAGE.SET_TOKEN('ENTITY', 'PRIORITY', TRUE);
         APP_EXCEPTION.RAISE_EXCEPTION;
END CHECK_REFERENCES;

END ENG_ECO_PRIOR_PKG ;

/
