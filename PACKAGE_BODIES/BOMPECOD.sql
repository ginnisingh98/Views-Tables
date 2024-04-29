--------------------------------------------------------
--  DDL for Package Body BOMPECOD
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."BOMPECOD" AS
/* $Header: BOMECODB.pls 115.5 2004/05/18 01:17:42 rfarook ship $ */

PROCEDURE BOM_DELETE_ECO
   (P_CHANGE_NOTICE             IN      VARCHAR2,
    P_ORGANIZATION_ID           IN      NUMBER)
IS

BEGIN

    DELETE FROM ENG_CHANGE_ORDER_REVISIONS
    WHERE  ORGANIZATION_ID = P_ORGANIZATION_ID
    AND    CHANGE_NOTICE = P_CHANGE_NOTICE;

    DELETE FROM ENG_CURRENT_SCHEDULED_DATES
    WHERE  ORGANIZATION_ID = P_ORGANIZATION_ID
    AND    CHANGE_NOTICE = P_CHANGE_NOTICE;

    DELETE FROM BOM_REFERENCE_DESIGNATORS R
    WHERE  R.COMPONENT_SEQUENCE_ID IN
           (SELECT C.COMPONENT_SEQUENCE_ID
            FROM   BOM_INVENTORY_COMPONENTS C,
                   ENG_REVISED_ITEMS RI
            WHERE  RI.REVISED_ITEM_SEQUENCE_ID = C.REVISED_ITEM_SEQUENCE_ID
            AND    RI.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND    RI.CHANGE_NOTICE = P_CHANGE_NOTICE
            AND    C.IMPLEMENTATION_DATE IS NULL);

    DELETE FROM BOM_SUBSTITUTE_COMPONENTS S
    WHERE S.COMPONENT_SEQUENCE_ID IN
           (SELECT C.COMPONENT_SEQUENCE_ID
            FROM   BOM_INVENTORY_COMPONENTS C,
                   ENG_REVISED_ITEMS RI
            WHERE  RI.REVISED_ITEM_SEQUENCE_ID = C.REVISED_ITEM_SEQUENCE_ID
            AND    RI.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND    RI.CHANGE_NOTICE = P_CHANGE_NOTICE
            AND    C.IMPLEMENTATION_DATE IS NULL);


    DELETE FROM BOM_INVENTORY_COMPONENTS C
    WHERE  C.IMPLEMENTATION_DATE IS NULL
    AND C.REVISED_ITEM_SEQUENCE_ID IN
           (SELECT R.REVISED_ITEM_SEQUENCE_ID
            FROM   ENG_REVISED_ITEMS R
            WHERE  R.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND    R.CHANGE_NOTICE = P_CHANGE_NOTICE);

    UPDATE BOM_INVENTORY_COMPONENTS C
    SET C.REVISED_ITEM_SEQUENCE_ID = NULL
--        C.CHANGE_NOTICE = NULL                -- Bug2627917
    WHERE  C.IMPLEMENTATION_DATE IS NOT NULL
    AND    C.REVISED_ITEM_SEQUENCE_ID IN
           (SELECT R.REVISED_ITEM_SEQUENCE_ID
            FROM   ENG_REVISED_ITEMS R
            WHERE  R.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND    R.CHANGE_NOTICE = P_CHANGE_NOTICE);

    DELETE FROM ENG_REVISED_COMPONENTS C
    WHERE  EXISTS
           (SELECT NULL
            FROM   ENG_REVISED_ITEMS R
            WHERE  R.ORGANIZATION_ID = P_ORGANIZATION_ID
            AND    R.CHANGE_NOTICE = P_CHANGE_NOTICE
            AND    R.REVISED_ITEM_SEQUENCE_ID = C.REVISED_ITEM_SEQUENCE_ID);

    DELETE FROM MTL_ITEM_REVISIONS_TL
    WHERE REVISION_ID IN (SELECT REVISION_ID
			 FROM  MTL_ITEM_REVISIONS_B
			 WHERE CHANGE_NOTICE = P_CHANGE_NOTICE
    		 	 AND   ORGANIZATION_ID = P_ORGANIZATION_ID
    			 AND   IMPLEMENTATION_DATE IS NULL);

    DELETE FROM MTL_ITEM_REVISIONS_B
    WHERE  CHANGE_NOTICE = P_CHANGE_NOTICE
    AND    ORGANIZATION_ID = P_ORGANIZATION_ID
    AND    IMPLEMENTATION_DATE IS NULL;


    UPDATE MTL_ITEM_REVISIONS_B
    SET    CHANGE_NOTICE = NULL,
           REVISED_ITEM_SEQUENCE_ID = NULL
    WHERE  CHANGE_NOTICE = P_CHANGE_NOTICE
    AND    ORGANIZATION_ID = P_ORGANIZATION_ID
    AND    IMPLEMENTATION_DATE IS NOT NULL;

    DELETE FROM ENG_REVISED_ITEMS
    WHERE  CHANGE_NOTICE = P_CHANGE_NOTICE
    AND    ORGANIZATION_ID = P_ORGANIZATION_ID;

    DELETE FROM ENG_ENGINEERING_CHANGES
    WHERE  CHANGE_NOTICE = P_CHANGE_NOTICE
    AND    ORGANIZATION_ID = P_ORGANIZATION_ID;

    DELETE FROM BOM_BILL_OF_MATERIALS B
    WHERE  ORGANIZATION_ID = P_ORGANIZATION_ID
    AND    PENDING_FROM_ECN = P_CHANGE_NOTICE
    AND    NOT EXISTS (SELECT NULL
                       FROM   BOM_INVENTORY_COMPONENTS C
                       WHERE  C.BILL_SEQUENCE_ID = B.BILL_SEQUENCE_ID)
    AND    NOT EXISTS (SELECT NULL
                       FROM   ENG_REVISED_ITEMS R
                       WHERE  R.BILL_SEQUENCE_ID = B.BILL_SEQUENCE_ID);

EXCEPTION
WHEN others THEN rollback;

END BOM_DELETE_ECO;

END BOMPECOD;  /* End of package */

/