--------------------------------------------------------
--  DDL for Package Body INV_INTERCOMPANY_COGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_INTERCOMPANY_COGS" AS
/* $Header: INVCSTUB.pls 120.1 2005/06/22 07:36:38 appldev ship $ */



    FUNCTION BUILD (
        FB_FLEX_NUM IN NUMBER DEFAULT 101,
        IC_CUSTOMER_ID IN VARCHAR2 DEFAULT NULL,
        IC_ITEM_ID IN VARCHAR2 DEFAULT NULL,
        IC_ORDER_HEADER_ID IN VARCHAR2 DEFAULT NULL,
        IC_ORDER_LINE_ID IN VARCHAR2 DEFAULT NULL,
        IC_ORDER_TYPE_ID IN VARCHAR2 DEFAULT NULL,
        IC_SELL_OPER_UNIT IN VARCHAR2 DEFAULT NULL,
        FB_FLEX_SEG IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
        FB_ERROR_MSG IN OUT NOCOPY /* file.sql.39 change */ VARCHAR2)
        RETURN BOOLEAN
    IS

BEGIN
  FB_FLEX_SEG := NULL;
  FND_MESSAGE.SET_NAME('FND', 'FLEXWK-UPGRADE FUNC MISSING');
  FND_MESSAGE.SET_TOKEN('FUNC', 'INV_INTERCOMPANY_COGS');
  FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
  RETURN FALSE;
END;

END INV_INTERCOMPANY_COGS;

/
