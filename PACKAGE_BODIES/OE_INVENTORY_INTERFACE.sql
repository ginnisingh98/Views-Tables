--------------------------------------------------------
--  DDL for Package Body OE_INVENTORY_INTERFACE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_INVENTORY_INTERFACE" AS
/* $Header: WSHWFSTB.pls 115.0 99/08/19 17:54:48 porting ship  $ */

/*
 *  Global Variables
 */

  DEBUG_COGS BOOLEAN := FALSE;

--
-- PRIVATE PROCEDURES
--

  PROCEDURE PRINTLN(p_string	IN VARCHAR2) IS
  BEGIN
    --dbms_output.enable(1000000);
    --dbms_output.put_line(p_string);
    null;
  END PRINTLN;

--
-- PUBLIC FUNCTIONS
--


/*===========================================================================+
 | Name: BUILD                                                               |
 | Purpose: This is a stub build function that returns a value FALSE and     |
 |          sets the value of the output varriable FB_FLEX_SEGto NULL and    |
 |          output error message variable FB_ERROR_MSG to the AOL error      |
 |          message FLEXWK-UPGRADE FUNC MISSING. This will ensure that the   |
 |          user will get an appropriate error message if they try to use    |
 |          the FLEXBUILDER_UPGRADE process without creating the conversion  |
 |          package successfully.                                            |
 +===========================================================================*/
FUNCTION BUILD (
		  FB_FLEX_NUM IN NUMBER DEFAULT 101,
		  OE_II_COMMITMENT_ID_RAW IN VARCHAR2 DEFAULT NULL,
		  OE_II_CUSTOMER_ID_RAW IN VARCHAR2 DEFAULT NULL,
		  OE_II_HEADER_ID_RAW IN VARCHAR2 DEFAULT NULL,
		  OE_II_LINE_DETAIL_ID_RAW IN VARCHAR2 DEFAULT NULL,
		  OE_II_OPTION_FLAG_RAW IN VARCHAR2 DEFAULT NULL,
		  OE_II_ORDER_CATEGORY_RAW IN VARCHAR2 DEFAULT NULL,
		  OE_II_ORDER_LINE_ID_RAW IN VARCHAR2 DEFAULT NULL,
            OE_II_ORDER_TYPE_ID_RAW IN VARCHAR2 DEFAULT NULL,
            OE_II_ORGANIZATION_ID_RAW IN VARCHAR2 DEFAULT NULL,
            OE_II_PICK_LINE_DETAIL_ID_RAW IN VARCHAR2 DEFAULT NULL,
            FB_FLEX_SEG IN OUT VARCHAR2,
            FB_ERROR_MSG IN OUT VARCHAR2)
            RETURN BOOLEAN
IS
BEGIN <<BUILD>>
            IF (DEBUG_COGS) THEN
	        DBMS_OUTPUT.ENABLE(1000000);
		PRINTLN('Calling Stub OE_INVENTORY_INTERFACE.BUILD');
            END IF;

	    FB_FLEX_SEG := NULL;
	    FND_MESSAGE.SET_NAME('FND', 'FLEXWK-UPGRADE FUNC MISSING');
	    FND_MESSAGE.SET_TOKEN('FUNC','OE_INVENTORY_INTERFACE');
	    FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;

	    RETURN FALSE;
END; /* BUILD */


END OE_INVENTORY_INTERFACE;

/
