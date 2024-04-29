--------------------------------------------------------
--  DDL for Package Body MTL_PENDING_STATUS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."MTL_PENDING_STATUS_PKG" as
/* $Header: INVISMPB.pls 120.1 2005/06/11 08:11:16 appldev  $ */


  PROCEDURE get_org (X_ORG_ID        IN    NUMBER,
                     X_CUR_ORG_ID       OUT NOCOPY /* file.sql.39 change */  NUMBER,
                     X_CUR_ORG_CODE     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
                     X_CUR_ORG_NAME     OUT NOCOPY /* file.sql.39 change */  VARCHAR2

  ) IS

    CONTROL_LEVEL   NUMBER := 0 ;
    SEL_ORG         NUMBER;
    PASS_ORG        NUMBER;

    CURSOR C IS
        SELECT control_level
        FROM   MTL_ITEM_ATTRIBUTES A
        WHERE  A.ATTRIBUTE_NAME =
                'MTL_SYSTEM_ITEMS.INVENTORY_ITEM_STATUS_CODE';

    CURSOR D IS
        SELECT MASTER_ORGANIZATION_ID
        FROM   MTL_PARAMETERS P
        WHERE  P.ORGANIZATION_ID = PASS_ORG;

  BEGIN


    OPEN C;
    FETCH C INTO CONTROL_LEVEL ;
    if (C%NOTFOUND) then
      CLOSE C;

      APP_EXCEPTION.Raise_Exception;
    end if;
    CLOSE C;



    IF(CONTROL_LEVEL = 1) THEN
      PASS_ORG := X_ORG_ID;
      OPEN D;
      FETCH D INTO SEL_ORG;
      X_CUR_ORG_ID := SEL_ORG;
      if (D%NOTFOUND) then

          close D;
          APP_EXCEPTION.Raise_Exception;
      end if;
      CLOSE D;
    ELSE

        X_CUR_ORG_ID := X_ORG_ID;
        SEL_ORG      := X_ORG_ID;
    END IF;

  SELECT   organization_code, organization_name
    INTO   X_CUR_ORG_CODE, X_CUR_ORG_NAME
    FROM   ORG_ORGANIZATION_DEFINITIONS
    WHERE  ORGANIZATION_ID = SEL_ORG;

/*
   X_CUR_ORG_CODE := ORG_CODE;
   X_CUR_ORG_NAME := ORG_NAME;
*/

   if (SQL%NOTFOUND) THEN
       APP_EXCEPTION.Raise_Exception;
   end if;


  END get_org;


END MTL_PENDING_STATUS_PKG;

/
