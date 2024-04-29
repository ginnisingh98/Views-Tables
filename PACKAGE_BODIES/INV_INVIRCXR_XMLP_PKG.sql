--------------------------------------------------------
--  DDL for Package Body INV_INVIRCXR_XMLP_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INVIRCXR_XMLP_PKG" AS
/* $Header: INVIRCXRB.pls 120.1 2007/12/25 10:21:53 dwkrishn noship $ */
  FUNCTION BEFOREREPORT RETURN BOOLEAN IS
  BEGIN
    BEGIN
      P_CONC_REQUEST_ID := FND_GLOBAL.CONC_REQUEST_ID;
      /*SRW.USER_EXIT('FND SRWINIT')*/NULL;
    EXCEPTION
      WHEN /*SRW.USER_EXIT_FAILURE*/OTHERS THEN
        /*SRW.MESSAGE(1
                   ,'Srwinit failed before report trigger')*/NULL;
        RAISE;
    END;
    IF (P_CUSTOMER_FROM IS NOT NULL) THEN
      P_WHERE := ' And A.customer_id =' || '''' || P_CUSTOMER_FROM || '''';
    END IF;
    IF (P_CUSTOMER_ADDRESS_CATEGORY IS NOT NULL) THEN
      P_WHERE := P_WHERE || ' And A.customer_category =' || '''' || P_CUSTOMER_ADDRESS_CATEGORY || '''';
    END IF;
    IF (P_CUSTOMER_ADDRESS IS NOT NULL) THEN
      P_WHERE := P_WHERE || ' And A.concatenated_address =' || '''' || P_CUSTOMER_ADDRESS || '''';
    END IF;
    IF (P_CUSTOMER_ITEM_NBR_FROM IS NOT NULL) THEN
      P_WHERE := P_WHERE || ' And A.customer_item_number >=' || '''' || P_CUSTOMER_ITEM_NBR_FROM || '''';
    END IF;
    IF (P_CUSTOMER_ITEM_NBR_TO IS NOT NULL) THEN
      P_WHERE := P_WHERE || ' And A.customer_item_number <=' || '''' || P_CUSTOMER_ITEM_NBR_TO || '''';
    END IF;
    IF (P_ITEM_LEVEL IS NOT NULL) THEN
      P_WHERE := P_WHERE || ' And A.item_level = ' || '''' || P_ITEM_LEVEL || '''';
    END IF;
    IF (P_LIST_LOWEST_RANK = 'Yes' OR P_LIST_LOWEST_RANK = 'Y') THEN
      P_WHERE := P_WHERE || ' And A.Rank =
                     (Select min(Rank) from MTL_CUSTOMER_ITEM_XREFS_V B
                      Where A.customer_item_id = B.customer_item_id
                      And A.master_organization_id = B.master_organization_id)';
    END IF;
    RETURN (TRUE);
  END BEFOREREPORT;
  FUNCTION AFTERREPORT RETURN BOOLEAN IS
  BEGIN
    /*SRW.USER_EXIT('FND SRWEXIT')*/NULL;
    RETURN (TRUE);
    RETURN (TRUE);
  END AFTERREPORT;
  FUNCTION G_BODYGROUPFILTER RETURN BOOLEAN IS
  BEGIN
    RETURN (TRUE);
  END G_BODYGROUPFILTER;
END INV_INVIRCXR_XMLP_PKG;


/
