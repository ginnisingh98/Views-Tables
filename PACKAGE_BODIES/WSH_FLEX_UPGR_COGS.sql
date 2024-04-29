--------------------------------------------------------
--  DDL for Package Body WSH_FLEX_UPGR_COGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FLEX_UPGR_COGS" AS
/* $Header: WSHWFUPB.pls 115.7 99/07/16 08:24:48 porting ship $ */

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
		         PRINTLN('Calling Stub WSH_FLEX_UPGR_COGS.BUILD');
            END IF;
		  FB_FLEX_SEG := NULL;
		  FND_MESSAGE.SET_NAME('FND', 'FLEXWK-UPGRADE FUNC MISSING');
		  FND_MESSAGE.SET_TOKEN('FUNC','OE_INVENTORY_INTERFACE');
		  FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
		  RETURN FALSE;
END; /* BUILD */


/*===========================================================================+
 | Name: UPGRADE_COGS_FLEX                                                   |
 | Purpose: Determines whether an item is an option item or not              |
 +===========================================================================*/

PROCEDURE UPGRADE_COGS_FLEX(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY	IN VARCHAR2,
		   ACTID	     IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)

IS
L_LINE_DETAIL_ID                  NUMBER;
L_ORDER_LINE_ID                   NUMBER;
L_PICK_LINE_DETAIL_ID             NUMBER;
L_ORGANIZATION_ID                 NUMBER;
L_COMMITMENT_ID                   NUMBER;
L_CUSTOMER_ID                     NUMBER;
L_HEADER_ID                       NUMBER;
L_ORDER_CATEGORY                  VARCHAR2(10);
L_ORDER_TYPE_ID                   NUMBER;
L_OPTION_FLAG                     VARCHAR2(2);
L_FLEX_NUM                        NUMBER;
L_FB_FLEX_SEGS                    VARCHAR2(240) DEFAULT NULL;
L_FB_ERROR_MSG                    VARCHAR2(240) DEFAULT NULL;
BEGIN <<UPGRADE_COGS_FLEX>>
 IF (DEBUG_COGS) THEN
      DBMS_OUTPUT.ENABLE(1000000);
      PRINTLN('Calling OE_INVENTORY_INTERFACE.BUILD');
 END IF;
 IF (FUNCMODE = 'RUN') THEN
     L_LINE_DETAIL_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'LINE_DETAIL_ID');
     L_ORDER_LINE_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_LINE_ID');
     L_PICK_LINE_DETAIL_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'PICKING_LINE_DETAIL_ID');
     L_ORGANIZATION_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORGANIZATION_ID');
     L_COMMITMENT_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'COMMITMENT_ID');
     L_CUSTOMER_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'CUSTOMER_ID');
     L_HEADER_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_LINE_HEADER_ID');
     L_ORDER_CATEGORY:= wf_engine.GetItemAttrText(itemtype,itemkey,'ORDER_CATEGORY');
     L_ORDER_TYPE_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_TYPE_ID');
     L_OPTION_FLAG:= wf_engine.GetItemAttrText(itemtype,itemkey,'OPTION_FLAG');
     L_FLEX_NUM:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'CHART_OF_ACCOUNTS_ID');

     IF (DEBUG_COGS) THEN
	     PRINTLN('Input Paramerers : ');
		PRINTLN('Line detail id :'||to_char(l_line_detail_id));
		PRINTLN('Line id :'||to_char(l_order_line_id));
		PRINTLN('Picking line detail id :'||to_char(l_pick_line_detail_id));
		PRINTLN('Organization id :'||to_char(l_organization_id));
		PRINTLN('Commitment ID :'||to_char(l_commitment_id));
		PRINTLN('Customer ID :'||to_char(l_customer_id));
		PRINTLN('Order Category :'||l_order_category);
		PRINTLN('Order Type :'||to_char(l_order_type_id));
		PRINTLN('Option Flag :'||l_option_flag);
		PRINTLN('Structure Number :'|| to_char(l_flex_num));
     END IF;

    IF (OE_INVENTORY_INTERFACE.BUILD(L_FLEX_NUM,
							L_COMMITMENT_ID,
							L_CUSTOMER_ID,
							L_HEADER_ID,
							L_LINE_DETAIL_ID,
                                   L_OPTION_FLAG,
							L_ORDER_CATEGORY,
							L_ORDER_LINE_ID,
							L_ORDER_TYPE_ID,
							L_ORGANIZATION_ID,
                                   L_PICK_LINE_DETAIL_ID,
							L_FB_FLEX_SEGS,
                                   L_FB_ERROR_MSG)=TRUE)
    THEN
            PRINTLN ('OE_INVENTORY_INTERFACE.BUILD returned SUCCESS ');
            result := 'COMPLETE:SUCCESS';
    ELSE
            PRINTLN ('OE_INVENTORY_INTERFACE.BUILD returned FAILURE ');
            result := 'COMPLETE:FAILURE';
    END IF;

    IF L_FB_ERROR_MSG IS NOT NULL THEN
        wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',L_FB_ERROR_MSG);
        PRINTLN ('Error : L_FB_ERROR_MSG = '||L_FB_ERROR_MSG);
    END IF;

    FND_FLEX_WORKFLOW.LOAD_CONCATENATED_SEGMENTS(itemtype,
                                                 itemkey,
                                                 l_fb_flex_segs);
    RETURN;

 ELSIF (funcmode = 'CANCEL') THEN
   result := wf_engine.eng_completed;
   RETURN;
 ELSE
   result := '';
   RETURN;
 END IF;
EXCEPTION
   WHEN OTHERS THEN
       wf_core.context('WSH_FLEX_UPGR_COGS','UPGRADE_COGS_FLEX',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
	RAISE;
END;  /* UPGRADE_COGS_FLEX */
END WSH_FLEX_UPGR_COGS;

/
