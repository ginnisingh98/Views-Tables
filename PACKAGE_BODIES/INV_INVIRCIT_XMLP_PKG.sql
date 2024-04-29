--------------------------------------------------------
--  DDL for Package Body INV_INVIRCIT_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRCIT_XMLP_PKG" AS
/* $Header: INVIRCITB.pls 120.1 2007/12/25 10:19:00 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
    P_ORG_ID_1:=nvl(P_ORG_ID,592);
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Srwinit failed before report trigger')*/NULL;
        RAISE;
    END;
    IF (P_CUSTOMER IS NOT NULL) THEN
      P_WHERE := ' And MCI.customer_id =' || '''' || P_CUSTOMER || '''';
    END IF;
    IF (P_CUSTOMER_ADDRESS_CATEGORY IS NOT NULL) THEN
      P_WHERE := P_WHERE || ' And MCI.customer_category =' || '''' || P_CUSTOMER_ADDRESS_CATEGORY || '''';
    END IF;
    IF (P_CUSTOMER_ADDRESS IS NOT NULL) THEN
      P_WHERE := P_WHERE || ' And MCI.concatenated_address =' || '''' || P_CUSTOMER_ADDRESS || '''';
    END IF;
    IF (P_CUSTOMER_ITEM_NBR_FROM IS NOT NULL) THEN
      P_WHERE := P_WHERE || ' And MCI.customer_item_number >=' || '''' || P_CUSTOMER_ITEM_NBR_FROM || '''';
    END IF;
    IF (P_CUSTOMER_ITEM_NBR_TO IS NOT NULL) THEN
      P_WHERE := P_WHERE || ' And MCI.customer_item_number <=' || '''' || P_CUSTOMER_ITEM_NBR_TO || '''';
    END IF;
    IF (P_LIST_CUSTOMER_ITEMS_WO_XREFS = 'Yes' OR P_LIST_CUSTOMER_ITEMS_WO_XREFS = 'Y') THEN
      P_WHERE := P_WHERE || ' And MCI.Customer_Item_Id In
                     (Select A.Customer_Item_Id
                     From   MTL_CUSTOMER_ITEMS A
                     Minus
                     Select Distinct B.Customer_Item_Id
                     From   MTL_CUSTOMER_ITEM_XREFS B)';
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;
END INV_INVIRCIT_XMLP_PKG;


/
