--------------------------------------------------------
--  DDL for Package Body JA_JAIN57PI_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JA_JAIN57PI_XMLP_PKG" AS
/* $Header: JAIN57PIB.pls 120.1 2007/12/25 16:09:04 dwkrishn noship $ */
  FUNCTION P_TO_DATEVALIDTRIGGER RETURN BOOLEAN IS
  BEGIN
    IF P_TO_DATE IS NULL THEN
      CP_TO_DATE := SYSDATE;
    ELSE
      CP_TO_DATE := TO_CHAR(P_TO_DATE,'DD-MON-YY');
    END IF;
    RETURN (TRUE);
  END P_TO_DATEVALIDTRIGGER;

  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
  END AFTERREPORT;
FUNCTION BEFOREREPORT RETURN BOOLEAN IS
BFT BOOLEAN;
BEGIN
BFT:=JA_JAIN57PI_XMLP_PKG.P_TO_DATEVALIDTRIGGER;
--SRW.MESSAGE(1275,'REPORT VERSION IS 115.1 LAST MODIFIED DATE IS 17/11/2004 ');
BEGIN
  IF TRUNC(P_FROM_DATE) IS NULL THEN
  SELECT 	MIN( CREATION_DATE) INTO CP_FROM_DATE
  FROM  	JAI_PO_OSP_HDRS F3
  WHERE 	F3.ORGANIZATION_ID 	= P_ORGANIZATION_ID
  AND		F3.LOCATION_ID 		= NVL(P_LOCATION_ID,F3.LOCATION_ID);
  ELSE
   CP_FROM_DATE := TO_CHAR(P_FROM_DATE,'DD-MON-YY');
  END IF;
END;

BEGIN
--SRW.USER_EXIT('FND SRWINIT');
/*EXCEPTION
  WHEN SRW.USER_EXIT_FAILURE THEN SRW.MESSAGE(010,'FAILED IN BEFORE REPORT TRIGGER, SRWINIT. ');
RAISE;*/
NULL;
END;

BEGIN
--SRW.REFERENCE(:P_STRUCT_NUM);
/*SRW.USER_EXIT('FND FLEXSQL CODE="MSTK" NUM=":P_STRUCT_NUM" DISPLAY="ALL"
    APPL_SHORT_NAME="INV" OUTPUT=":P_ITEM_FLEXDATA" MODE="SELECT" TABLEALIAS="MSI"');
EXCEPTION
   WHEN SRW.USER_EXIT_FAILURE THEN SRW.MESSAGE(020,'FAILED IN BEFORE REPORT TRIGGER, ITEM SELECT. ');
RAISE;*/
NULL;
END;

RETURN (TRUE);

END;
END JA_JAIN57PI_XMLP_PKG;


/
