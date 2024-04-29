--------------------------------------------------------
--  DDL for Package Body WSH_FLEX_PKG_COGS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WSH_FLEX_PKG_COGS" AS
/* $Header: WSHWFDFB.pls 115.6 99/07/16 08:24:40 porting ship $ */

/*
 *   Global Variables
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
 | Name: START_PROCESS                                                       |
 | Purpose: Runs the Workflow process to create the COGS account             |
 +===========================================================================*/

  FUNCTION START_PROCESS(X_COMMITMENT_ID  IN NUMBER,
		   X_CUSTOMER_ID           IN NUMBER,
		   X_OPTION_FLAG           IN VARCHAR2,
		   X_ORDER_CATEGORY        IN VARCHAR2,
		   X_LINE_DETAIL_ID        IN NUMBER,
		   X_ORDER_LINE_HEADER_ID  IN NUMBER,
		   X_ORDER_LINE_ID         IN NUMBER,
		   X_PICKING_LINE_DTL_ID   IN NUMBER,
		   X_ORDER_TYPE_ID         IN NUMBER,
		   X_ORG_ID                IN NUMBER,
		   X_FLEX_NUMBER           IN NUMBER,
		   X_RETURN_CCID           IN OUT NUMBER,
		   X_CONCAT_SEGS           IN OUT VARCHAR2,
		   X_CONCAT_IDS            IN OUT VARCHAR2,
		   X_CONCAT_DESCRS         IN OUT VARCHAR2,
		   X_ERRMSG                IN OUT VARCHAR2)
		   RETURN BOOLEAN IS


  L_ITEMTYPE  VARCHAR2(30) := 'SHPFLXWF';
  L_ITEMKEY	  VARCHAR2(30);
  L_RESULT 	  BOOLEAN;
  L_commitment_id       NUMBER;
  L_line_detail_id      NUMBER;
  L_pick_line_detail_id NUMBER;
  L_organization_id     NUMBER;
  current_org_id 	NUMBER;
  new_ccid        boolean := TRUE; -- flag that indicates if CCID is new
  BEGIN  <<GEN_CCID>>

     --
     -- Bug 848715
     -- Set the Org
     --


     SELECT nvl(org_id, -99)
     INTO   current_org_id
     FROM   so_headers_all
     WHERE  header_id = X_ORDER_LINE_HEADER_ID;

     IF (DEBUG_COGS) THEN
	PRINTLN('Current Org Id : '||to_char(current_org_id));
     END IF;

     IF ( current_org_id <> -99 ) THEN
        FND_CLIENT_INFO.SET_ORG_CONTEXT(current_org_id);
     END IF;

     IF (DEBUG_COGS) THEN
	   PRINTLN('Calling Initialize from START_PROCESS');
     END IF;
     L_ITEMKEY := FND_FLEX_WORKFLOW.INITIALIZE
				('SQLGL',
				  'GL#',
				  X_FLEX_NUMBER,
			       'SHPFLXWF'
				 );

     IF (DEBUG_COGS) THEN
         PRINTLN('End of Initialize.');
         PRINTLN('L_ITEMTYPE = '||L_ITEMTYPE);
         PRINTLN('L_ITEMKEY = '||L_ITEMKEY);
     END IF;

     /* Bug 740007: map four variables to NULL as needed */

     L_commitment_id       := X_COMMITMENT_ID;
     L_line_detail_id      := X_LINE_DETAIL_ID;
     L_pick_line_detail_id := X_PICKING_LINE_DTL_ID;
     L_organization_id     := X_ORG_ID;

     IF L_commitment_id = 0 THEN
        L_commitment_id := NULL;
     END IF;

     IF L_line_detail_id = 0 THEN
        L_line_detail_id := NULL;
     END IF;

     IF L_pick_line_detail_id = 0 THEN
        L_pick_line_detail_id := NULL;
     END IF;

     IF L_organization_id = -1 THEN
        L_organization_id := NULL;
     END IF;

     /* Initialize the workflow item attributes  */
     IF (DEBUG_COGS) THEN
	   PRINTLN('Initilizing Workflow Item Attributes');
     END IF;
     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                               itemkey  => L_ITEMKEY,
                               aname    =>'COMMITMENT_ID',
                               avalue   => L_commitment_id);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                               itemkey  => L_ITEMKEY,
                               aname    =>'CUSTOMER_ID',
                               avalue   =>X_CUSTOMER_ID);

     wf_engine.SetItemAttrText(itemtype => L_ITEMTYPE,
                                  itemkey => L_ITEMKEY,
                                  aname   => 'OPTION_FLAG',
                                  avalue  =>  X_OPTION_FLAG);

     wf_engine.SetItemAttrText(itemtype => L_ITEMTYPE,
                                itemkey => L_ITEMKEY,
                                aname   => 'ORDER_CATEGORY',
                                avalue  =>  X_ORDER_CATEGORY);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                                  itemkey => L_ITEMKEY,
                                  aname   => 'LINE_DETAIL_ID',
                                  avalue  => L_line_detail_id);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                                  itemkey => L_ITEMKEY,
                                  aname   => 'ORDER_LINE_HEADER_ID',
                                  avalue  =>  X_ORDER_LINE_HEADER_ID);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                                  itemkey => L_ITEMKEY,
                                  aname   => 'ORDER_LINE_ID',
                                  avalue  =>  X_ORDER_LINE_ID);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                                  itemkey => L_ITEMKEY,
                                  aname   => 'PICKING_LINE_DETAIL_ID',
                                  avalue  => L_pick_line_detail_id);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                                  itemkey => L_ITEMKEY,
                                  aname   => 'ORDER_TYPE_ID',
                                  avalue  =>  X_ORDER_TYPE_ID);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                                  itemkey => L_ITEMKEY,
                                  aname   => 'ORGANIZATION_ID',
                                  avalue  => L_organization_id);

     wf_engine.SetItemAttrNumber(itemtype => L_ITEMTYPE,
                                 itemkey  => L_ITEMKEY,
                                 aname    =>'CHART_OF_ACCOUNTS_ID',
                                 avalue   =>X_FLEX_NUMBER);

     IF (DEBUG_COGS) THEN
	   PRINTLN('Calling FND_ELEX_WORKFLOW.GENERATE from START_PROCESS');
     END IF;
     l_result := FND_FLEX_WORKFLOW.GENERATE( 'SHPFLXWF',
				                         L_ITEMKEY,
                                                         TRUE, -- insert if new
				                         X_RETURN_CCID,
				                         X_CONCAT_SEGS,
				                         X_CONCAT_IDS,
				                         X_CONCAT_DESCRS,
				                         X_ERRMSG,
                                                         new_ccid);
     IF (DEBUG_COGS) THEN
	   PRINTLN('End of generate');
     END IF;
  	RETURN l_result;
     EXCEPTION
     WHEN OTHERS THEN
     IF (DEBUG_COGS) THEN
	   PRINTLN('ERROR: other excpn of START_PROCESS :'||sqlerrm);
     END IF;
     wf_core.context('WSH_FLEX_PKG_COGS','START_PROCESS',X_COMMITMENT_ID,X_CUSTOMER_ID,X_ORDER_TYPE_ID ,X_ORG_ID);
     raise;
  END; /*  START_PROCESS */

/*===========================================================================+
 | Name: GET_COST_SALE_ITEM_DERIVED                                          |
 | Purpose: Derives the COGS account for a line regardless of the option flag|
 +===========================================================================*/

  PROCEDURE GET_COST_SALE_ITEM_DERIVED(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)
  IS
     L_COST_SALE_ITEM_DERIVED	         VARCHAR2(240) DEFAULT NULL;
     L_LINE_DETAIL_ID                  NUMBER;
     L_ORDER_LINE_ID                   NUMBER;
     L_PICK_LINE_DETAIL_ID             NUMBER;
     L_ORGANIZATION_ID                 NUMBER;
     FB_ERROR_MSG	                   VARCHAR2(240) DEFAULT NULL;
  BEGIN <<GET_COST_SALE_ITEM_DERIVED>>
    IF (DEBUG_COGS) THEN
	  DBMS_OUTPUT.ENABLE(1000000);
	  PRINTLN('Calling WSH_FLEX_PKG_COGS.GET_COST_SALE_ITEM_DERIVED');
          PRINTLN('FUNCMODE = '||FUNCMODE);
    END IF;
    IF (FUNCMODE = 'RUN') THEN
       L_LINE_DETAIL_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'LINE_DETAIL_ID');
       L_ORDER_LINE_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_LINE_ID');
       L_PICK_LINE_DETAIL_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'PICKING_LINE_DETAIL_ID');
       L_ORGANIZATION_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORGANIZATION_ID');
       L_COST_SALE_ITEM_DERIVED := NULL;

       IF (L_LINE_DETAIL_ID IS NOT NULL) THEN
           IF (DEBUG_COGS) THEN
             PRINTLN('L_LINE_DETAIL_ID is not null.');
           END IF;
           BEGIN
              SELECT  NVL(M.COST_OF_SALES_ACCOUNT,0)
	         INTO    L_COST_SALE_ITEM_DERIVED
              FROM    SO_LINE_DETAILS LD,
				  MTL_SYSTEM_ITEMS M
              WHERE   LD.LINE_DETAIL_ID = L_LINE_DETAIL_ID
              AND     M.ORGANIZATION_ID = LD.WAREHOUSE_ID
		    AND     M.INVENTORY_ITEM_ID = LD.INVENTORY_ITEM_ID;
              IF (DEBUG_COGS) THEN
                 PRINTLN('L_COST_SALE_ITEM_DERIVED = '||L_COST_SALE_ITEM_DERIVED);
              END IF;
              EXCEPTION
                WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(L_LINE_DETAIL_ID));
                FND_MESSAGE.SET_TOKEN('VSET_ID', '102319');
                FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                result :=  'COMPLETE:FAILURE';
                RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_COST_SALE_ITEM_DERIVED 1 :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;

           END;
       END IF;
       IF (L_COST_SALE_ITEM_DERIVED IS NULL) THEN
         IF (L_PICK_LINE_DETAIL_ID IS NOT NULL) THEN
           IF (DEBUG_COGS) THEN
             PRINTLN('L_COST_SALE_ITEM_DERIVED is null and L_PICK_LINE_DETAIL_ID is not null');
           END IF;
           BEGIN
              SELECT   NVL(M.COST_OF_SALES_ACCOUNT,0)
	         INTO     L_COST_SALE_ITEM_DERIVED
              FROM     SO_PICKING_LINE_DETAILS PLD,
				   SO_PICKING_LINES PL,
				   MTL_SYSTEM_ITEMS M
              WHERE    PLD.PICKING_LINE_DETAIL_ID = L_PICK_LINE_DETAIL_ID
              AND      PL.PICKING_LINE_ID = PLD.PICKING_LINE_ID
		    AND      M.ORGANIZATION_ID = PLD.WAREHOUSE_ID
		    AND      M.INVENTORY_ITEM_ID = PL.INVENTORY_ITEM_ID;
              IF (DEBUG_COGS) THEN
                PRINTLN('L_COST_SALE_ITEM_DERIVED = '||L_COST_SALE_ITEM_DERIVED);
              END IF;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(L_PICK_LINE_DETAIL_ID));
                FND_MESSAGE.SET_TOKEN('VSET_ID', '102320');
                FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                result :=  'COMPLETE:FAILURE';
                RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_COST_SALE_ITEM_DERIVED 2 :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
           END;
         END IF;
       END IF;
       IF (L_COST_SALE_ITEM_DERIVED IS NULL) THEN
         IF (L_ORGANIZATION_ID IS NOT NULL) THEN
           IF (DEBUG_COGS) THEN
             PRINTLN('L_COST_SALE_ITEM_DERIVED is null and L_ORGANIZATION_ID is not null');
           END IF;
           BEGIN
              SELECT   NVL(M.COST_OF_SALES_ACCOUNT,0)
	         INTO     L_COST_SALE_ITEM_DERIVED
              FROM     SO_LINES L,
				   MTL_SYSTEM_ITEMS M
              WHERE    M.ORGANIZATION_ID = L_ORGANIZATION_ID
              AND      L.LINE_ID = L_ORDER_LINE_ID
		    AND      M.INVENTORY_ITEM_ID = L.INVENTORY_ITEM_ID;
              IF (DEBUG_COGS) THEN
                 PRINTLN('L_COST_SALE_ITEM_DERIVED = '||L_COST_SALE_ITEM_DERIVED);
              END IF;
              EXCEPTION
              WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(L_ORDER_LINE_ID));
                FND_MESSAGE.SET_TOKEN('VSET_ID', '102318');
                FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                result :=  'COMPLETE:FAILURE';
	           RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_COST_SALE_ITEM_DERIVED 3 :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
           END;
         END IF;
       END IF;
       wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',TO_NUMBER(L_COST_SALE_ITEM_DERIVED));
       result := 'COMPLETE:SUCCESS';
    IF (DEBUG_COGS) THEN
	  PRINTLN('Input Paramerers : ');
	  PRINTLN('Line detail id :'||to_char(l_line_detail_id));
	  PRINTLN('Line id :'||to_char(l_order_line_id));
	  PRINTLN('Picking line detail id :'||to_char(l_pick_line_detail_id));
	  PRINTLN('Organization id :'||to_char(l_organization_id));
	  PRINTLN('Output : ');
	  PRINTLN('Generated CCID :'||l_cost_sale_item_derived);
    END IF;
       RETURN;
    ELSIF (funcmode = 'CANCEL') THEN
       result :=  wf_engine.eng_completed;
       RETURN;
    ELSE
       result := '';
       RETURN;
    END IF;
    EXCEPTION
       WHEN OTHERS THEN
       IF (DEBUG_COGS) THEN
	   PRINTLN('ERROR: other excpn of GET_COST_SALE_ITEM_DERIVED : '||sqlerrm);
       END IF;
         wf_core.context('WSH_FLEX_PKG_COGS','GET_COST_SALE_ITEM_DERIVED',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
         result :=  'COMPLETE:FAILURE';
         RAISE;
  END;  /* GET_COST_SALE_ITEM_DERIVED */

/*===========================================================================+
 | Name: GET_COST_SALE_MODEL_DERIVED                                         |
 | Purpose: Derives the COGS account for a model                             |
 +===========================================================================*/

  PROCEDURE GET_COST_SALE_MODEL_DERIVED(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)
  IS
      L_COST_SALE_MODEL_DERIVED	    VARCHAR2(240) DEFAULT NULL;
      L_LINE_DETAIL_ID                  NUMBER;
      L_ORDER_LINE_ID                   NUMBER;
      L_PICK_LINE_DETAIL_ID             NUMBER;
      L_ORGANIZATION_ID                 NUMBER;
      FB_ERROR_MSG	                   VARCHAR2(240) DEFAULT NULL;
  BEGIN <<GET_COST_SALE_MODEL_DERIVED>>
     IF (DEBUG_COGS) THEN
	  DBMS_OUTPUT.ENABLE(1000000);
	  PRINTLN('Calling WSH_FLEX_PKG_COGS.GET_COST_SALE_MODEL_DERIVED');
          PRINTLN('FUNCMODE = '||FUNCMODE);
     END IF;
     IF (FUNCMODE = 'RUN') THEN
      L_LINE_DETAIL_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'LINE_DETAIL_ID');
      L_ORDER_LINE_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_LINE_ID');
      L_PICK_LINE_DETAIL_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'PICKING_LINE_DETAIL_ID');
      L_ORGANIZATION_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORGANIZATION_ID');
      L_COST_SALE_MODEL_DERIVED := NULL;
      IF (L_LINE_DETAIL_ID IS NOT NULL) THEN
          BEGIN
           IF (DEBUG_COGS) THEN
             PRINTLN('L_LINE_DETAIL_ID is not null');
           END IF;
             SELECT    NVL(M.COST_OF_SALES_ACCOUNT,0)
	        INTO      L_COST_SALE_MODEL_DERIVED
             FROM      SO_LINE_DETAILS LD,
				   MTL_SYSTEM_ITEMS M
             WHERE     LD.LINE_DETAIL_ID = L_LINE_DETAIL_ID
             AND       M.ORGANIZATION_ID = LD.WAREHOUSE_ID
		   AND       M.INVENTORY_ITEM_ID = LD.INVENTORY_ITEM_ID;
             IF (DEBUG_COGS) THEN
               PRINTLN('L_COST_SALE_MODEL_DERIVED = '||L_COST_SALE_MODEL_DERIVED);
	     END IF;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(L_LINE_DETAIL_ID));
                FND_MESSAGE.SET_TOKEN('VSET_ID', '102319');
                FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                result :=  'COMPLETE:FAILURE';
	           RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_COST_SALE_MODEL_DERIVED 1 :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
          END;
      END IF;
      IF (L_COST_SALE_MODEL_DERIVED IS NULL) THEN
        IF (L_PICK_LINE_DETAIL_ID IS NOT NULL) THEN
          IF (DEBUG_COGS) THEN
            PRINTLN('L_COST_SALE_MODEL_DERIVED is null and L_PICK_LINE_DETAIL_ID is not null');
	  END IF;
          BEGIN
             SELECT    NVL(M.COST_OF_SALES_ACCOUNT,0)
	        INTO      L_COST_SALE_MODEL_DERIVED
             FROM      SO_PICKING_LINE_DETAILS PLD,
				   SO_PICKING_LINES PL,
				   MTL_SYSTEM_ITEMS M
             WHERE     PLD.PICKING_LINE_DETAIL_ID = L_PICK_LINE_DETAIL_ID
             AND       PL.PICKING_LINE_ID = PLD.PICKING_LINE_ID
		   AND       M.ORGANIZATION_ID = PLD.WAREHOUSE_ID
		   AND       M.INVENTORY_ITEM_ID = PL.INVENTORY_ITEM_ID;
             IF (DEBUG_COGS) THEN
               PRINTLN('L_COST_SALE_MODEL_DERIVED = '||L_COST_SALE_MODEL_DERIVED);
	     END IF;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                  FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(L_PICK_LINE_DETAIL_ID));
                  FND_MESSAGE.SET_TOKEN('VSET_ID', '102320');
                  FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                  wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                  result :=  'COMPLETE:FAILURE';
	             RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_COST_SALE_MODEL_DERIVED 2 :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
          END;
        END IF;
      END IF;
      IF (L_COST_SALE_MODEL_DERIVED IS NULL) THEN
        IF (L_ORGANIZATION_ID IS NOT NULL) THEN
           IF (DEBUG_COGS) THEN
             PRINTLN('L_COST_SALE_ITEM_DERIVED is null and L_ORGANIZATION_ID is not null');
	   END IF;
          BEGIN
             SELECT    NVL(M.COST_OF_SALES_ACCOUNT,0)
	        INTO      L_COST_SALE_MODEL_DERIVED
             FROM      SO_LINES L,
				   MTL_SYSTEM_ITEMS M
             WHERE     M.ORGANIZATION_ID = L_ORGANIZATION_ID
             AND       L.LINE_ID = L_ORDER_LINE_ID
		   AND       M.INVENTORY_ITEM_ID = L.INVENTORY_ITEM_ID;
             IF (DEBUG_COGS) THEN
               PRINTLN('L_COST_SALE_MODEL_DERIVED = '||L_COST_SALE_MODEL_DERIVED);
	     END IF;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                  FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(L_ORDER_LINE_ID));
                  FND_MESSAGE.SET_TOKEN('VSET_ID', '102318');
                  FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                  wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                  result :=  'COMPLETE:FAILURE';
	             RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_COST_SALE_MODEL_DERIVED 3 :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
          END;
        END IF;
      END IF;
      IF (L_COST_SALE_MODEL_DERIVED IS NULL) THEN
        IF (L_ORDER_LINE_ID IS NOT NULL) THEN
          IF (DEBUG_COGS) THEN
            PRINTLN('L_COST_SALE_ITEM_DERIVED is null and L_ORDER_LINE_ID is not null');
	  END IF;
          BEGIN
             SELECT NVL(COST_OF_SALES_ACCOUNT,0)
	        INTO   L_COST_SALE_MODEL_DERIVED
             FROM   SO_MODEL_LINE_COGS_ACCOUNT
             WHERE  LINE_ID = L_ORDER_LINE_ID;
             IF (DEBUG_COGS) THEN
                PRINTLN('L_COST_SALE_MODEL_DERIVED = '||L_COST_SALE_MODEL_DERIVED);
	     END IF;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                  FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                  FND_MESSAGE.SET_TOKEN('VALUE', TO_CHAR(L_ORDER_LINE_ID));
                  FND_MESSAGE.SET_TOKEN('VSET_ID', '102321');
                  FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                  wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                  result :=  'COMPLETE:FAILURE';
	             RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_COST_SALE_MODEL_DERIVED 4 :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
          END;
        END IF;
      END IF;
      wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',TO_NUMBER(L_COST_SALE_MODEL_DERIVED));
      result := 'COMPLETE:SUCCESS';
      IF (DEBUG_COGS) THEN
	  PRINTLN('Input Paramerers : ');
	  PRINTLN('Line detail id :'||to_char(l_line_detail_id));
	  PRINTLN('Line id :'||to_char(l_order_line_id));
	  PRINTLN('Picking line detail id :'||to_char(l_pick_line_detail_id));
	  PRINTLN('Organization id :'||to_char(l_organization_id));
	  PRINTLN('Output : ');
	  PRINTLN('Generated CCID :'||l_cost_sale_model_derived);
      END IF;
      RETURN;
     ELSIF (funcmode = 'CANCEL') THEN
      result :=  wf_engine.eng_completed;
      RETURN;
     ELSE
      result := '';
      RETURN;
     END IF;
     EXCEPTION
        WHEN OTHERS THEN
            IF (DEBUG_COGS) THEN
	      PRINTLN('ERROR: other excpn of GET_COST_SALE_MODEL_DERIVED : '||sqlerrm);
            END IF;
            wf_core.context('WSH_FLEX_PKG_COGS','GET_COST_SALE_MODEL_DERIVED',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
            result :=  'COMPLETE:FAILURE';
	     RAISE;
  END;  /* GET_COST_SALE_MODEL_DERIVED */


/*===========================================================================+
 | Name: GET_ORDER_TYPE_DERIVED                                         |
 | Purpose: Derives the CCID from the Order type                             |
 +===========================================================================*/

  PROCEDURE GET_ORDER_TYPE_DERIVED(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)
  IS
     L_ORDER_TYPE_CCID                 VARCHAR2(240) DEFAULT NULL;
     L_ORDER_TYPE_ID                   NUMBER;
     FB_ERROR_MSG	                   VARCHAR2(240) DEFAULT NULL;
  BEGIN <<GET_ORDER_TYPE_DERIVED>>
     IF (DEBUG_COGS) THEN
	  DBMS_OUTPUT.ENABLE(1000000);
	  PRINTLN('Calling WSH_FLEX_PKG_COGS.GET_ORDER_TYPE_DERIVED');
	  PRINTLN('FUNCMODE = '||FUNCMODE);
     END IF;
     IF (FUNCMODE = 'RUN') THEN
       L_ORDER_TYPE_ID := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_TYPE_ID');
       L_ORDER_TYPE_CCID := NULL;
       IF (L_ORDER_TYPE_ID IS NOT NULL) THEN
         IF (DEBUG_COGS) THEN
            PRINTLN('L_ORDER_TYPE_ID is not null');
	 END IF;
         BEGIN
	       SELECT    NVL(COST_OF_GOODS_SOLD_ACCOUNT, 0)
	       INTO      L_ORDER_TYPE_CCID
	       FROM      SO_ORDER_TYPES
	       WHERE     ORDER_TYPE_ID = L_ORDER_TYPE_ID;
               IF (DEBUG_COGS) THEN
                 PRINTLN('L_ORDER_TYPE_CCID = '||L_ORDER_TYPE_CCID);
	       END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
               FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
               FND_MESSAGE.SET_TOKEN('VALUE',TO_CHAR(L_ORDER_TYPE_ID));
               FND_MESSAGE.SET_TOKEN('VSET_ID', '101643');
               FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
               wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
               result :=  'COMPLETE:FAILURE';
	          RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_ORDER_TYPE_DERIVED  :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
         END;
       END IF;
       wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',TO_NUMBER(L_ORDER_TYPE_CCID));
       result := 'COMPLETE:SUCCESS';
      IF (DEBUG_COGS) THEN
	  PRINTLN('Input Paramerers : ');
	  PRINTLN('Order Type ID :'||to_char(l_order_type_id));
	  PRINTLN('Output : ');
	  PRINTLN('Generated CCID :'||l_order_type_ccid);
      END IF;
       RETURN;
     ELSIF (funcmode = 'CANCEL') THEN
       result :=  wf_engine.eng_completed;
       RETURN;
     ELSE
       result := '';
       RETURN;
     END IF;
     EXCEPTION
        WHEN OTHERS THEN
       IF (DEBUG_COGS) THEN
	   PRINTLN('ERROR: other excpn of GET_ORDER_TYPE_DERIVED : '||sqlerrm);
       END IF;
            wf_core.context('WSH_FLEX_PKG_COGS','GET_ORDER_TYPE_DERIVED',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
            result :=  'COMPLETE:FAILURE';
	     RAISE;
  END; /* GET_ORDER_TYPE_DERIVED */

/*===========================================================================+
 | Name: GET_SALESREP_REV_DERIVED                                            |
 | Purpose: Derives the CCID from salesrep's revenue segment                 |
 +===========================================================================*/

  PROCEDURE GET_SALESREP_REV_DERIVED(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)
  IS
     L_SALESREP_REV_DERIVED            VARCHAR2(240) DEFAULT NULL;
     L_SALESREP_ID                     NUMBER;
     FB_ERROR_MSG	                   VARCHAR2(240) DEFAULT NULL;
  BEGIN <<GET_SALESREP_REV_DERIVED>>
     IF (DEBUG_COGS) THEN
	  DBMS_OUTPUT.ENABLE(1000000);
	  PRINTLN('Calling WSH_FLEX_PKG_COGS.GET_SALESREP_REV_DERIVED');
	  PRINTLN('FUNCMODE = '||FUNCMODE);
     END IF;
     IF (FUNCMODE = 'RUN') THEN
       L_SALESREP_ID := wf_engine.GetActivityAttrNumber(itemtype,itemkey,actid,'SALESREPID');
       L_SALESREP_REV_DERIVED := NULL;
       IF (L_SALESREP_ID IS NOT NULL) THEN
         IF (DEBUG_COGS) THEN
            PRINTLN('L_SALESREP_ID is not null');
	 END IF;
         BEGIN
	       SELECT    NVL(GL_ID_REV, 0)
	       INTO      L_SALESREP_REV_DERIVED
	       FROM      RA_SALESREPS
	       WHERE     SALESREP_ID = L_SALESREP_ID;
               IF (DEBUG_COGS) THEN
                 PRINTLN('L_SALESREP_REV_DERIVED = '||L_SALESREP_REV_DERIVED);
	       END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                   FND_MESSAGE.SET_TOKEN('VALUE',TO_CHAR(L_SALESREP_ID));
                   FND_MESSAGE.SET_TOKEN('VSET_ID', '101645');
                   FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                   wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                   result :=  'COMPLETE:FAILURE';
	              RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_SALESREP_REV_DERIVED  :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
         END;
       END IF;
       wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',TO_NUMBER(L_SALESREP_REV_DERIVED));
       result := 'COMPLETE:SUCCESS';
       IF (DEBUG_COGS) THEN
	    PRINTLN('Input Paramerers : ');
	    PRINTLN('Salesrep ID :' || to_char(l_salesrep_id));
	    PRINTLN('Output : ');
	    PRINTLN('Generated CCID :'||l_salesrep_rev_derived);
       END IF;
       RETURN;
     ELSIF (funcmode = 'CANCEL') THEN
       result :=  wf_engine.eng_completed;
       RETURN;
     ELSE
       result := '';
       RETURN;
     END IF;
       EXCEPTION
          WHEN OTHERS THEN
          IF (DEBUG_COGS) THEN
	   PRINTLN('ERROR: other excpn of GET_SALESREP_REV_DERIVED : '||sqlerrm);
          END IF;
              wf_core.context('WSH_FLEX_PKG_COGS','GET_SALESREP_REV_DERIVED',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
              result :=  'COMPLETE:FAILURE';
       	RAISE;
  END; /* GET_SALESREP_REV_DERIVED */

/*===========================================================================+
 | Name: GET_SALESREP_ID                                                     |
 | Purpose: Derives the salesrep's ID                                        |
 +===========================================================================*/

  PROCEDURE GET_SALESREP_ID(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)
  IS
      L_SALESREP_ID                     VARCHAR2(240) DEFAULT NULL;
      L_ORDER_LINE_ID                   NUMBER;
      FB_ERROR_MSG	                   VARCHAR2(240) DEFAULT NULL;
  BEGIN <<GET_SALESREP_ID>>
     IF (DEBUG_COGS) THEN
	  DBMS_OUTPUT.ENABLE(1000000);
	  PRINTLN('Calling WSH_FLEX_PKG_COGS.GET_SALESREP_ID');
	  PRINTLN('FUNCMODE = '||FUNCMODE);
     END IF;
     IF (FUNCMODE = 'RUN') THEN
       L_ORDER_LINE_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_LINE_ID');
       IF (DEBUG_COGS) THEN
	    PRINTLN('Input Paramerers : ');
	    PRINTLN('Order Limne ID :'|| to_char(l_order_line_id));
       END IF;
       L_SALESREP_ID := NULL;
       IF (L_ORDER_LINE_ID IS NOT NULL) THEN
         IF (DEBUG_COGS) THEN
             PRINTLN('L_ORDER_LINE_ID is not null');
	 END IF;
         BEGIN
	       SELECT    SALESREP_ID
	       INTO      L_SALESREP_ID
	       FROM      SO_LINE_SALES_CREDITS
	       WHERE     LINE_ID = L_ORDER_LINE_ID
	       AND       QUOTA_FLAG = 'Y'
	       AND       SALESREP_ID = (
					   SELECT MIN(SALESREP_ID)
					   FROM SO_LINE_SALES_CREDITS C1
					   WHERE C1.LINE_ID = L_ORDER_LINE_ID
					   AND C1.QUOTA_FLAG = 'Y'
					   AND C1.PERCENT = (
						  SELECT MAX(PERCENT)
						  FROM SO_LINE_SALES_CREDITS C2
						  WHERE C2.LINE_ID = L_ORDER_LINE_ID
						  AND   C2.QUOTA_FLAG = 'Y'
						  AND C2.LEVEL_ID = (
							 SELECT MAX(LEVEL_ID)
							 FROM   SO_LINE_SALES_CREDITS C3
							 WHERE  C3.LINE_ID = L_ORDER_LINE_ID
							 AND    C3.QUOTA_FLAG = 'Y'
										 )
                                              )
                           )
            AND ROWNUM = 1;
             IF (DEBUG_COGS) THEN
                PRINTLN('L_SALESREP_ID = '||L_SALESREP_ID);
	     END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                 FND_MESSAGE.SET_TOKEN('VALUE',TO_CHAR(L_ORDER_LINE_ID));
                 FND_MESSAGE.SET_TOKEN('VSET_ID', '101646');
                 FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                 wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                 result :=  'COMPLETE:FAILURE';
	            RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_SALESREP_ID  :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
         END;
         wf_engine.setItemAttrNumber(itemtype,itemkey,'SALESREP_ID',TO_NUMBER(L_SALESREP_ID));
         result := 'COMPLETE:SUCCESS';
       ELSE
         result :=  'COMPLETE:FAILURE';
	    RETURN;
       END IF;
       IF (DEBUG_COGS) THEN
	    PRINTLN('Output : ');
	    PRINTLN('Salesrep ID :'|| l_salesrep_id);
       END IF;
       RETURN;
     ELSIF (funcmode = 'CANCEL') THEN
        result :=  wf_engine.eng_completed;
        RETURN;
     ELSE
        result := '';
        RETURN;
     END IF;
     EXCEPTION
        WHEN OTHERS THEN
          IF (DEBUG_COGS) THEN
	   PRINTLN('ERROR: other excpn of GET_SALESREP_ID : '||sqlerrm);
          END IF;
          wf_core.context('WSH_FLEX_PKG_COGS','GET_SALESREP_ID',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
          result :=  'COMPLETE:FAILURE';
	     RAISE;
  END; /* GET_SALESREP_ID */

/*===========================================================================+
 | Name: GET_COST_SALE                                                       |
 | Purpose: Derives a cost of sales account for an inventory Item ID         |
 | and Organization ID                                                       |
 +===========================================================================*/

  PROCEDURE GET_COST_SALE(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)
  IS
     L_ACCOUNT_DERIVED                 VARCHAR2(240) DEFAULT NULL;
     L_INV_ITEM_ID                     NUMBER;
     L_ORGANIZATION_ID                 NUMBER;
     FB_ERROR_MSG	                   VARCHAR2(240) DEFAULT NULL;
  BEGIN <<GET_COST_SALE>>
      IF (DEBUG_COGS) THEN
	   DBMS_OUTPUT.ENABLE(1000000);
	   PRINTLN('Calling WSH_FLEX_PKG_COGS.GET_COST_SALE');
	   PRINTLN('FUNCMODE = '||FUNCMODE);
      END IF;
      IF (FUNCMODE = 'RUN') THEN
        L_INV_ITEM_ID := wf_engine.GetActivityAttrNumber(itemtype,itemkey,actid,'INVITEMID');
        L_ORGANIZATION_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORGANIZATION_ID');
       IF (DEBUG_COGS) THEN
	    PRINTLN('Input Paramerers : ');
	    PRINTLN('Inventory Item ID :'|| to_char(l_inv_item_id));
	    PRINTLN('Organization ID :'|| to_char(l_organization_id));
       END IF;
        L_ACCOUNT_DERIVED := NULL;
        IF (L_INV_ITEM_ID IS NOT NULL) THEN
          IF (DEBUG_COGS) THEN
             PRINTLN('L_INV_ITEM_ID is not null');
	  END IF;
          BEGIN
	        SELECT    NVL(COST_OF_SALES_ACCOUNT, 0)
	        INTO      L_ACCOUNT_DERIVED
	        FROM      MTL_SYSTEM_ITEMS
	        WHERE     INVENTORY_ITEM_ID = L_INV_ITEM_ID
	        AND       ORGANIZATION_ID = L_ORGANIZATION_ID;
             IF (DEBUG_COGS) THEN
                PRINTLN('L_ACCOUNT_DERIVED = '||L_ACCOUNT_DERIVED);
	     END IF;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                    FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                    FND_MESSAGE.SET_TOKEN('VALUE',TO_CHAR(L_INV_ITEM_ID));
                    FND_MESSAGE.SET_TOKEN('VSET_ID', '101640');
                    FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                    wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                    result :=  'COMPLETE:FAILURE';
	               RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_COST_SALE  :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
          END;
          wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',TO_NUMBER(L_ACCOUNT_DERIVED));
          result := 'COMPLETE:SUCCESS';
        ELSE
          result :=  'COMPLETE:FAILURE';
	     RETURN;
        END IF;
       IF (DEBUG_COGS) THEN
	    PRINTLN('Output : ');
	    PRINTLN('Generated CCID :'|| l_account_derived);
       END IF;
        RETURN;
      ELSIF (funcmode = 'CANCEL') THEN
         result :=  wf_engine.eng_completed;
         RETURN;
      ELSE
         result := '';
         RETURN;
      END IF;
      EXCEPTION
         WHEN OTHERS THEN
         IF (DEBUG_COGS) THEN
	   PRINTLN('ERROR: other excpn of GET_COST_SALE : '||sqlerrm);
         END IF;
             wf_core.context('WSH_FLEX_PKG_COGS','GET_SALESREP_REV_DERIVED',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
             result :=  'COMPLETE:FAILURE';
	        RAISE;
  END; /* GET_COST_SALE */

/*===========================================================================+
 | Name: GET_INV_ITEM_ID                                                     |
 | Purpose: Derives Inventory Item ID from Order Line ID                     |
 +===========================================================================*/

  PROCEDURE GET_INV_ITEM_ID(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)
  IS
     L_INV_ITEM_ID                     VARCHAR2(240) DEFAULT NULL;
     L_ORDER_LINE_ID                   NUMBER;
     FB_ERROR_MSG	                   VARCHAR2(240) DEFAULT NULL;
  BEGIN <<GET_INV_ITEM_ID>>
      IF (DEBUG_COGS) THEN
	   DBMS_OUTPUT.ENABLE(1000000);
	   PRINTLN('Calling WSH_FLEX_PKG_COGS.GET_INV_ITEM_ID');
	   PRINTLN('FUNCMODE = '||FUNCMODE);
      END IF;
     IF (FUNCMODE = 'RUN') THEN
       L_ORDER_LINE_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_LINE_ID');
       L_INV_ITEM_ID := NULL;
        IF (L_ORDER_LINE_ID IS NOT NULL) THEN
          IF (DEBUG_COGS) THEN
             PRINTLN('L_ACCOUNT_DERIVED is not null');
	  END IF;
          BEGIN
	        SELECT    INVENTORY_ITEM_ID
	        INTO      L_INV_ITEM_ID
	        FROM      SO_LINES
	        WHERE     LINE_ID = L_ORDER_LINE_ID;
                IF (DEBUG_COGS) THEN
                  PRINTLN('L_INV_ITEM_ID = '||L_INV_ITEM_ID);
	        END IF;
             EXCEPTION
                WHEN NO_DATA_FOUND THEN
                FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                FND_MESSAGE.SET_TOKEN('VALUE',TO_CHAR(L_ORDER_LINE_ID));
                FND_MESSAGE.SET_TOKEN('VSET_ID', '101641');
                FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                result :=  'COMPLETE:FAILURE';
	           RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_INV_ITEM_ID  :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
          END;
          wf_engine.setItemAttrNumber(itemtype,itemkey,'INV_ITEM_ID',TO_NUMBER(L_INV_ITEM_ID));
          result := 'COMPLETE:SUCCESS';
        ELSE
          result :=  'COMPLETE:FAILURE';
	     RETURN;
        END IF;
        IF (DEBUG_COGS) THEN
	     PRINTLN('Input Paramerers : ');
	     PRINTLN('Line ID :'|| to_char(l_order_line_id));
	     PRINTLN('Output : ');
	     PRINTLN('Inventory Item ID :'||l_inv_item_id);
        END IF;
        RETURN;
     ELSIF (funcmode = 'CANCEL') THEN
        result :=  wf_engine.eng_completed;
        RETURN;
     ELSE
        result := '';
        RETURN;
     END IF;
     EXCEPTION
        WHEN OTHERS THEN
        IF (DEBUG_COGS) THEN
	   PRINTLN('ERROR: other excpn of GET_INV_ITEM_ID : '||sqlerrm);
        END IF;
          wf_core.context('WSH_FLEX_PKG_COGS','GET_INV_ITEM_ID',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
          result :=  'COMPLETE:FAILURE';
	     RAISE;
  END; /* GET_INV_ITEM_ID */

/*===========================================================================+
 | Name: GET_TRX_TYPE                                                        |
 | Purpose: Derives the transaction type for a commitment ID                 |
 +===========================================================================*/

  PROCEDURE GET_TRX_TYPE(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)
  IS
      L_TRX_TYPE                       VARCHAR2(240) DEFAULT NULL;
      L_COMMITMENT_ID                  NUMBER;
      FB_ERROR_MSG	                   VARCHAR2(240) DEFAULT NULL;
  BEGIN <<GET_TRX_TYPE>>
     IF (DEBUG_COGS) THEN
	  DBMS_OUTPUT.ENABLE(1000000);
	  PRINTLN('Calling WSH_FLEX_PKG_COGS.GET_TRX_TYPE');
     END IF;
     IF (FUNCMODE = 'RUN') THEN
       L_COMMITMENT_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'COMMITMENT_ID');
       IF (DEBUG_COGS) THEN
	    PRINTLN('Input Paramerers : ');
	    PRINTLN('Commitment ID :'|| to_char(l_commitment_id));
	    PRINTLN('FUNCMODE = '||FUNCMODE);
       END IF;
       L_TRX_TYPE:= NULL;
       IF (L_COMMITMENT_ID IS NOT NULL) THEN
         IF (DEBUG_COGS) THEN
             PRINTLN('L_COMMITMENT_ID is not null.');
	 END IF;
         BEGIN
	       SELECT    TYPE.TYPE
	       INTO      L_TRX_TYPE
	       FROM      RA_CUSTOMER_TRX TRX, RA_CUST_TRX_TYPES TYPE
	       WHERE     TRX.CUSTOMER_TRX_ID = L_COMMITMENT_ID
	       AND       TRX.CUST_TRX_TYPE_ID = TYPE.CUST_TRX_TYPE_ID;
             IF (DEBUG_COGS) THEN
                PRINTLN('L_TRX_TYPE = '||L_TRX_TYPE);
	     END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                 FND_MESSAGE.SET_TOKEN('VALUE',TO_CHAR(L_COMMITMENT_ID));
                 FND_MESSAGE.SET_TOKEN('VSET_ID', '101647');
                 FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                 wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                 result :=  'COMPLETE:FAILURE';
	            RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_TRX_TYPE  :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
         END;
         wf_engine.setItemAttrText(itemtype,itemkey,'TRX_TYPE_DERIVED',L_TRX_TYPE);
         result := 'COMPLETE:SUCCESS';
       ELSE
         result :=  'COMPLETE:FAILURE';
	    RETURN;
       END IF;
       IF (DEBUG_COGS) THEN
	    PRINTLN('Output : ');
	    PRINTLN('Transaction Type'||l_trx_type);
       END IF;
       RETURN;
     ELSIF (funcmode = 'CANCEL') THEN
       result :=  wf_engine.eng_completed;
       RETURN;
     ELSE
       result := '';
       RETURN;
     END IF;
     EXCEPTION
         WHEN OTHERS THEN
         IF (DEBUG_COGS) THEN
	   PRINTLN('ERROR: other excpn of GET_TRX_TYPE : '||sqlerrm);
         END IF;
           wf_core.context('WSH_FLEX_PKG_COGS','GET_TRX_TYPE',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
           result :=  'COMPLETE:FAILURE';
	      RAISE;
  END; /* GET_TRX_TYPE */

/*===========================================================================+
 | Name: GET_OPERATING_UNIT                                                  |
 | Purpose: Derives the selling operating unit                               |
 +===========================================================================*/

  PROCEDURE GET_OPERATING_UNIT(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)
  IS
     L_OPERATING_UNIT                  VARCHAR2(240) DEFAULT NULL;
     L_ORDER_LINE_ID                   NUMBER;
     FB_ERROR_MSG	                   VARCHAR2(240) DEFAULT NULL;
  BEGIN <<GET_OPERATING_UNIT>>
     IF (DEBUG_COGS) THEN
	  DBMS_OUTPUT.ENABLE(1000000);
	  PRINTLN('Calling WSH_FLEX_PKG_COGS.GET_OPERATING_UNIT');
	  PRINTLN('FUNCMODE = '||FUNCMODE);
     END IF;
     IF (FUNCMODE = 'RUN') THEN
       L_ORDER_LINE_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_LINE_ID');
       IF (DEBUG_COGS) THEN
	    PRINTLN('Input Paramerers : ');
	    PRINTLN('Line ID :'||to_char(l_order_line_id));
       END IF;
       L_OPERATING_UNIT := NULL;
       IF (L_ORDER_LINE_ID IS NOT NULL) THEN
         IF (DEBUG_COGS) THEN
              PRINTLN('L_ORDER_LINE_ID  is not null.');
	 END IF;
         BEGIN
	       SELECT    ORG_ID
	       INTO      L_OPERATING_UNIT
	       FROM      SO_LINES
	       WHERE     LINE_ID = L_ORDER_LINE_ID;
               IF (DEBUG_COGS) THEN
                 PRINTLN('L_OPERATING_UNIT = '||L_OPERATING_UNIT);
	       END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                   FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                   FND_MESSAGE.SET_TOKEN('VALUE',TO_CHAR(L_ORDER_LINE_ID));
                   FND_MESSAGE.SET_TOKEN('VSET_ID','103098');
                   FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                   wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                   result :=  'COMPLETE:FAILURE';
	              RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_OPERATING_UNIT  :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
         END;
         wf_engine.setItemAttrNumber(itemtype,itemkey,'ORG_ID',TO_NUMBER(L_OPERATING_UNIT));
         result := 'COMPLETE:SUCCESS';
       ELSE
         result :=  'COMPLETE:FAILURE';
	    RETURN;
       END IF;
       IF (DEBUG_COGS) THEN
	    PRINTLN('Output : ');
	    PRINTLN('Operating Unit :'||l_operating_unit);
       END IF;
       RETURN;
     ELSIF (funcmode = 'CANCEL') THEN
       result :=  wf_engine.eng_completed;
       RETURN;
     ELSE
       result := '';
       RETURN;
     END IF;
     EXCEPTION
        WHEN OTHERS THEN
        IF (DEBUG_COGS) THEN
	   PRINTLN('ERROR: other excpn of GET_OPERATING_UNIT : '||sqlerrm);
        END IF;
          wf_core.context('WSH_FLEX_PKG_COGS','GET_OPERATING_UNIT',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
          result :=  'COMPLETE:FAILURE';
	     RAISE;
  END; /* GET_OPERATING_UNIT */

/*===========================================================================+
 | Name: GET_PARENT_LINE                                                     |
 | Purpose: Derives a parent line id for a order line id                     |
 +===========================================================================*/

  PROCEDURE GET_PARENT_LINE(ITEMTYPE  IN VARCHAR2,
	    	   ITEMKEY     IN VARCHAR2,
		   ACTID       IN NUMBER,
		   FUNCMODE    IN VARCHAR2,
		   RESULT      OUT VARCHAR2)
  IS
     L_PARENT_LINE_ID                  VARCHAR2(240) DEFAULT NULL;
     L_ORDER_LINE_ID                   NUMBER;
     FB_ERROR_MSG	                   VARCHAR2(240) DEFAULT NULL;
  BEGIN <<GET_PARENT_LINE>>
     IF (DEBUG_COGS) THEN
	  DBMS_OUTPUT.ENABLE(1000000);
	  PRINTLN('Calling WSH_FLEX_PKG_COGS.GET_PARENT_LINE');
	  PRINTLN('FUNCMODE = '||FUNCMODE);
     END IF;
     IF (FUNCMODE = 'RUN') THEN
       L_ORDER_LINE_ID:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_LINE_ID');
       L_PARENT_LINE_ID  := NULL;
       IF (L_ORDER_LINE_ID IS NOT NULL) THEN
         IF (DEBUG_COGS) THEN
             PRINTLN('L_ORDER_LINE_ID is not null.');
	 END IF;
         BEGIN
	       SELECT    PARENT_LINE_ID
	       INTO      L_PARENT_LINE_ID
	       FROM      SO_LINES
	       WHERE     LINE_ID = L_ORDER_LINE_ID;
               IF (DEBUG_COGS) THEN
                PRINTLN('L_PARENT_LINE_ID = '||L_PARENT_LINE_ID);
	       END IF;
            EXCEPTION
               WHEN NO_DATA_FOUND THEN
                 FND_MESSAGE.SET_NAME('FND', 'FLEX-BUILD INVALID VALUE');
                 FND_MESSAGE.SET_TOKEN('VALUE',TO_CHAR(L_ORDER_LINE_ID));
                 FND_MESSAGE.SET_TOKEN('VSET_ID','101644');
                 FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
                 wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',FB_ERROR_MSG);
                 result :=  'COMPLETE:FAILURE';
	            RETURN;
                WHEN OTHERS THEN
                  IF (DEBUG_COGS) THEN
	             PRINTLN('ERROR: other excpn of GET_PARENT_LINE  :'||sqlerrm);
                  END IF;
                  result :=  'COMPLETE:FAILURE';
                  RAISE;
         END;
       END IF;
       wf_engine.setItemAttrNumber(itemtype,itemkey,'PARENT_LINE_ID_DERIVED',L_PARENT_LINE_ID);
       result := 'COMPLETE:SUCCESS';
       IF (DEBUG_COGS) THEN
	    PRINTLN('Input Paramerers : ');
	    PRINTLN('Line ID :'||to_char(l_order_line_id));
	    PRINTLN('Output : ');
	    PRINTLN('Parent Line ID :'|| l_parent_line_id);
       END IF;
       RETURN;
     ELSIF (funcmode = 'CANCEL') THEN
       result :=  wf_engine.eng_completed;
       RETURN;
     ELSE
       result := '';
       RETURN;
     END IF;
     EXCEPTION
        WHEN OTHERS THEN
        IF (DEBUG_COGS) THEN
	   PRINTLN('ERROR: other excpn of GET_PARENT_LINE : '||sqlerrm);
        END IF;
          wf_core.context('WSH_FLEX_PKG_COGS','GET_PARENT_LINE',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
          result :=  'COMPLETE:FAILURE';
	     RAISE;
  END; /* GET_PARENT_LINE */

 END WSH_FLEX_PKG_COGS;

/
