--------------------------------------------------------
--  DDL for Package Body OE_FLEX_COGS_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_FLEX_COGS_PUB" AS
/* $Header: OEXWCGSB.pls 120.2 2006/02/20 23:34:20 akyadav noship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'OE_Flex_Cogs_PUB';

TYPE  Chart_Of_Accounts_Rec_Type IS RECORD
(   ship_from_org_id      NUMBER          := NULL
  , chart_of_accounts_id  NUMBER          := NULL
);

TYPE Chart_Of_Accounts_Tbl_Type IS TABLE OF Chart_Of_Accounts_Rec_Type
    INDEX BY BINARY_INTEGER;

G_Chart_Of_Accounts_Rec      Chart_Of_Accounts_Rec_Type;
G_Chart_Of_Accounts_Tbl      Chart_Of_Accounts_Tbl_Type;
--  Start of Comments
--  API name    OE_Flex_Cogs_PUB
--  Type        Public
--  Version     Current version = 1.0
--              Initial version = 1.0

/*
Procedure log_error(p_error IN Varchar2, p_dummy IN NUMBER Default 0)
Begin
 qp_util.log_error(1,NULL, NULL, NULL, NULL,NULL,NULL, NULL,'ONT_COGS',
                   p_error, 'ONT_COGS');
End;
*/

/*===========================================================================+
 | Name: START_PROCESS                                                       |
 | Purpose: Runs the Workflow process to create the COGS account             |
 +===========================================================================*/

FUNCTION Start_Process
(
	p_api_version_number	IN	NUMBER,
	p_line_id          		IN 	NUMBER,
	x_return_ccid           OUT NOCOPY NUMBER,
	x_concat_segs           OUT NOCOPY VARCHAR2,
	x_concat_ids            OUT NOCOPY VARCHAR2,
	x_concat_descrs         OUT NOCOPY VARCHAR2,
	x_msg_count             OUT NOCOPY NUMBER,
 	x_msg_data              OUT NOCOPY VARCHAR2)
	RETURN VARCHAR2
IS

	l_itemtype  				VARCHAR2(30) := 'OECOGS';
	l_itemkey	  				VARCHAR2(38);
	l_result 	  				BOOLEAN;
	l_return_status				VARCHAR2(1);
	l_chart_of_accounts_id		NUMBER;
	l_option_flag				VARCHAR2(1);
	l_errmsg					VARCHAR2(2000);
	l_api_version_number		CONSTANT NUMBER := 1.0;
	l_api_name					CONSTANT VARCHAR2(30) := 'Start_Process';
	l_header_id					NUMBER;
	l_line_id					NUMBER;
	l_ship_from_org_id			NUMBER;
	l_commitment_id				NUMBER;
	l_sold_to_org_id			NUMBER;
	l_org_id					NUMBER;
	l_salesrep_id				NUMBER;
	l_inventory_item_id			NUMBER;
	l_item_type_code			VARCHAR2(30);
	l_line_category_code		VARCHAR2(30);
	l_reference_line_id			NUMBER;
	l_order_category_code		VARCHAR2(30);
	l_order_type_id				NUMBER;
        l_new_combination                       BOOLEAN;  -- 1775305
        lx_return_ccid                   NUMBER;
        lx_concat_segs                   VARCHAR2(1000);
        lx_concat_ids                    VARCHAR2(1000);
        lx_concat_descrs                 VARCHAR2(1000);
        lx_msg_count                     NUMBER;
        lx_msg_data                      VARCHAR2(1000);
        g_stmt                           VARCHAR2(500);

        --3406720
        l_aname                          wf_engine.nametabtyp;
        l_avalue                         wf_engine.numtabtyp;
        l_aname2                         wf_engine.nametabtyp;
        l_avaluetext                     wf_engine.texttabtyp;
        l_chart_of_accounts_rec          Chart_Of_Accounts_Rec_Type;
        l_debug_level CONSTANT           NUMBER := oe_debug_pub.g_debug_level;
        --Exception Management begin
        l_order_source_id 	         NUMBER;
        l_orig_sys_document_ref          VARCHAR2(50);
        l_orig_sys_line_ref              VARCHAR2(50);
        l_orig_sys_shipment_ref          VARCHAR2(50);
        l_change_sequence                VARCHAR2(50);
        l_source_document_type_id        NUMBER;
        l_source_document_id             NUMBER;
        l_source_document_line_id        NUMBER;
        --Exception Management end
BEGIN
	/*oe_Debug_pub.setdebuglevel(5);*/
        --Commented out the call to debug on for bug 3406720
        --oe_debug_pub.debug_on;
        --oe_debug_pub.initialize;
        g_stmt:='1';

        IF l_debug_level > 0 THEN
        oe_debug_pub.add('Entering OE_Flex_Cogs_Pub.Start_process : '|| to_char(p_line_id),1);
        END IF;

	IF 	NOT FND_API.Compatible_API_Call
		(   l_api_version_number
		,   p_api_version_number
		,   l_api_name
		,   G_PKG_NAME
		)
		THEN
		RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
	END IF;

	IF	p_line_id IS NULL  OR
		p_line_id = FND_API.G_MISS_NUM THEN

		FND_MESSAGE.SET_NAME('ONT','OE_COGS_LINE_ID_MISSING');
		OE_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;

	END IF;

        g_stmt:='5';

	BEGIN
		SELECT	REFERENCE_LINE_ID,
				LINE_CATEGORY_CODE
		INTO	l_reference_line_id,
				l_line_category_code
		FROM	OE_ORDER_LINES
		WHERE	LINE_ID = p_line_id;

	EXCEPTION

		WHEN	NO_DATA_FOUND THEN
				FND_MESSAGE.SET_NAME('ONT','OE_COGS_INVALID_LINE_ID');
				FND_MESSAGE.SET_TOKEN('LINE_ID',l_line_id);
				OE_MSG_PUB.ADD;
				RAISE FND_API.G_EXC_ERROR;

	END;

	IF 	l_line_category_code = 'RETURN' and
		l_reference_line_id is not null THEN
		l_line_id := l_reference_line_id;
	ELSE
		l_line_id := p_line_id;
	END IF;

        g_stmt:='10';
	/* Retreive the header and line details */

	BEGIN

		SELECT	HEADER_ID,
				ORG_ID,
				SHIP_FROM_ORG_ID,
				SOLD_TO_ORG_ID,
				COMMITMENT_ID,
				SALESREP_ID,
				INVENTORY_ITEM_ID,
				ITEM_TYPE_CODE,
                                ORDER_SOURCE_ID,
                                ORIG_SYS_DOCUMENT_REF,
                                ORIG_SYS_LINE_REF,
                                ORIG_SYS_SHIPMENT_REF,
                                CHANGE_SEQUENCE,
                                SOURCE_DOCUMENT_TYPE_ID,
                                SOURCE_DOCUMENT_ID,
                                SOURCE_DOCUMENT_LINE_ID
		INTO	l_header_id,
				l_org_id,
				l_ship_from_org_id,
				l_sold_to_org_id,
				l_commitment_id,
				l_salesrep_id,
				l_inventory_item_id,
				l_item_type_code,
                                l_order_source_id,
                                l_orig_sys_document_ref,
                                l_orig_sys_line_ref,
                                l_orig_sys_shipment_ref,
                                l_change_sequence,
                                l_source_document_type_id,
                                l_source_document_id,
                                l_source_document_line_id
		FROM	OE_ORDER_LINES
		WHERE	LINE_ID = l_line_id;

          -- Exception Management begin Set message context
           OE_MSG_PUB.set_msg_context(
           p_entity_code           => 'LINE'
          ,p_entity_id                  => l_line_id
          ,p_header_id                  => l_header_id
          ,p_line_id                    => l_line_id
          ,p_order_source_id            => l_order_source_id
          ,p_orig_sys_document_ref      => l_orig_sys_document_ref
          ,p_orig_sys_document_line_ref => l_orig_sys_line_ref
          ,p_orig_sys_shipment_ref      => l_orig_sys_shipment_ref
          ,p_change_sequence            => l_change_sequence
          ,p_source_document_type_id    => l_source_document_type_id
          ,p_source_document_id         => l_source_document_id
          ,p_source_document_line_id    => l_source_document_line_id );
          --Exception Management end

	EXCEPTION

		WHEN NO_DATA_FOUND THEN
                    -- Set message context
                      OE_MSG_PUB.set_msg_context(
                       p_entity_code           => 'LINE'
                      ,p_entity_id                  => l_line_id
                      ,p_line_id                    => l_line_id
                      );

		      FND_MESSAGE.SET_NAME('ONT','OE_COGS_INVALID_LINE_ID');
		      FND_MESSAGE.SET_TOKEN('LINE_ID',l_line_id);
		      OE_MSG_PUB.ADD;
		      RAISE FND_API.G_EXC_ERROR;
	END;

        g_stmt:='15';

	SELECT	ORDER_CATEGORY_CODE,
			ORDER_TYPE_ID
	INTO	l_order_category_code,
			l_order_type_id
	FROM	OE_ORDER_HEADERS
	WHERE	HEADER_ID = l_header_id;

	IF	l_ship_from_org_id IS NULL THEN

		FND_MESSAGE.SET_NAME('ONT','OE_COGS_WAREHOUSE_MISSING');
		FND_MESSAGE.SET_TOKEN('LINE_ID',l_line_id);
		OE_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;

	END IF;

        g_stmt:='20';

	/* Retreive the Chart of accounts Id */
        -- 3406720 Cached the value for Chart of accounts id
        IF G_Chart_Of_Accounts_Tbl.exists(l_ship_from_org_id) THEN
           l_chart_of_accounts_id := G_Chart_Of_Accounts_Tbl(l_ship_from_org_id).Chart_Of_Accounts_Id;
        ELSE
           /*SELECT CHART_OF_ACCOUNTS_ID
           INTO   l_chart_of_accounts_id
           FROM   ORG_ORGANIZATION_DEFINITIONS
           WHERE  ORGANIZATION_ID = l_ship_from_org_id; */

 SELECT /*+ ordered use_nl(HOI1,HOI2,GSOB) */
      GSOB.CHART_OF_ACCOUNTS_ID CHART_OF_ACCOUNTS_ID
 INTO   l_chart_of_accounts_id
 FROM  HR_ORGANIZATION_UNITS HOU ,
      HR_ORGANIZATION_INFORMATION HOI1 ,
      HR_ORGANIZATION_INFORMATION HOI2 ,
      GL_SETS_OF_BOOKS GSOB
 WHERE HOU.ORGANIZATION_ID = HOI1.ORGANIZATION_ID
 AND  HOU.ORGANIZATION_ID = HOI2.ORGANIZATION_ID
 AND  HOI1.ORG_INFORMATION1 = 'INV'
 AND  HOI1.ORG_INFORMATION2 = 'Y'
 AND  ( HOI1.ORG_INFORMATION_CONTEXT || '' ) = 'CLASS'
 AND  ( HOI2.ORG_INFORMATION_CONTEXT || '' ) ='Accounting Information'
 AND  HOI2.ORG_INFORMATION1
      = GSOB.SET_OF_BOOKS_ID
 and  hou.organization_id = l_ship_from_org_id;

           l_chart_of_accounts_rec.ship_from_org_id := l_ship_from_org_id;
           l_chart_of_accounts_rec.chart_of_accounts_id := l_chart_of_accounts_id;
           G_Chart_Of_Accounts_Tbl(l_ship_from_org_id) := l_chart_of_accounts_rec;
        END IF;
	IF l_debug_level > 0 THEN
          oe_debug_pub.add('Chart Of accounts Id : '|| to_char(l_chart_of_accounts_id),2);
        END IF;
	/* Initialize the workflow item attributes  */
	l_itemkey := FND_FLEX_WORKFLOW.INITIALIZE
				('SQLGL',
				'GL#',
				l_chart_of_accounts_id,
				'OECOGS'
				);
        IF l_debug_level > 0 THEN
	   oe_debug_pub.add('Item Key : '||l_itemkey,2);
           oe_debug_pub.add('Initilizing Workflow Item Attributes');
        END If;
        g_stmt:='35';

        l_aname(1) := 'COMMITMENT_ID';
        l_avalue(1):= l_commitment_id;

        g_stmt:='40';

        l_aname(2) := 'CUSTOMER_ID';
        l_avalue(2):= l_sold_to_org_id;

        g_stmt:='45';

        l_aname2(1) := 'ORDER_CATEGORY';
        l_avaluetext(1):= l_order_category_code;

        g_stmt:='50';

        l_aname(3) := 'HEADER_ID';
        l_avalue(3):= l_header_id;

        g_stmt:='55';

        l_aname(4) := 'LINE_ID';
        l_avalue(4):= l_line_id;

        g_stmt:='60';

        l_aname(5) := 'ORDER_TYPE_ID';
        l_avalue(5):= l_order_type_id;

        l_aname(6) := 'ORGANIZATION_ID';
        l_avalue(6):= l_ship_from_org_id;

        l_aname(7) := 'ORG_ID';
        l_avalue(7):= l_org_id;

        l_aname(8) := 'CHART_OF_ACCOUNTS_ID';
        l_avalue(8):= l_chart_of_accounts_id;

        l_aname(9) := 'SALESREP_ID';
        l_avalue(9):= l_salesrep_id;

        l_aname(10) := 'INVENTORY_ITEM_ID';
        l_avalue(10):=l_inventory_item_id;

        wf_engine.SetItemAttrNumberArray(l_itemtype
                              , l_itemkey
                              , l_aname
                              , l_avalue
                              );

     g_stmt:='65';

	IF	l_item_type_code = OE_GLOBALS.G_ITEM_OPTION THEN

		l_option_flag := 'Y';
	ELSE
		l_option_flag := 'N';

	END IF;

        l_aname2(2) := 'OPTION_FLAG';
        l_avaluetext(2):= l_option_flag;
     g_stmt:='70';

        wf_engine.SetItemAttrTextArray(itemtype => l_itemtype,
                              itemkey  => l_itemkey,
                              aname    => l_aname2,
                              avalue   => l_avaluetext);
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Calling FND_ELEX_WORKFLOW.GENERATE from START_PROCESS');
        END IF;
    g_stmt:='75';
    l_result := FND_FLEX_WORKFLOW.GENERATE( itemtype => 'OECOGS',   -- 1775305
				            itemkey => l_itemkey,
                                            insert_if_new => TRUE,
				            ccid => lx_return_ccid,
				            concat_segs => lx_concat_segs,
				            concat_ids => lx_concat_ids,
				            concat_descrs => lx_concat_descrs,
				            error_message => l_errmsg,
                                            new_combination => l_new_combination);
        Begin
         g_stmt:='assigning back ccid';
         x_return_ccid:=lx_return_ccid;

         g_stmt:='assiging back concat segs';
	 x_concat_segs:=lx_concat_segs;

         g_stmt:='assigning back concat_ids';
	 x_concat_ids :=lx_concat_ids;

         g_stmt:='assigning back concat descrs';
	 x_concat_descrs:=lx_concat_descrs;

        Exception
          When Others Then
            oe_debug_pub.add(SQLERRM||':'||g_stmt);
            Raise FND_API.G_EXC_UNEXPECTED_ERROR;
        End;

        IF INSTR(l_errmsg, CHR(0)) > 0 THEN -- 2352606
	   fnd_message.set_encoded(l_errmsg);
	   l_errmsg := fnd_message.get;
        END IF;

	g_stmt:='80';

        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Return CCID : '|| x_return_ccid,2);
           oe_debug_pub.add('Concat Segments : '|| x_concat_segs,2);
	   oe_debug_pub.add('Concat Id : '|| x_concat_ids,2);
           oe_debug_pub.add('Concat Descriptions : '|| x_concat_descrs,2);
        END IF;

	IF	l_result THEN
		l_return_status := FND_API.G_RET_STS_SUCCESS;
	ELSE
                IF l_debug_level > 0 THEN
                   oe_debug_pub.add('Error Message : '|| l_errmsg,2);
	        END IF;
        	FND_MESSAGE.SET_NAME('ONT','OE_COGS_ACC_GEN_FAILED');
		FND_MESSAGE.SET_TOKEN('ERROR_MESSAGE',l_errmsg);
	        OE_MSG_PUB.ADD;
		RAISE FND_API.G_EXC_ERROR;
	END IF;
	   oe_debug_pub.add('Exiting OE_Flex_Cogs_Pub.Start_process : '|| l_return_status, 1); -- 2352606
        RETURN l_return_status;
EXCEPTION

    WHEN NO_DATA_FOUND THEN
	FND_MESSAGE.SET_NAME('ONT','OE_COGS_COA_ID_NOT_FOUND');
	FND_MESSAGE.SET_TOKEN('ORGANIZATION_ID',l_ship_from_org_id);
	OE_MSG_PUB.ADD;

        x_msg_count := OE_MSG_PUB.Count_Msg; -- 2352606 start
        IF x_msg_count > 0 THEN
	    x_msg_data := OE_MSG_PUB.Get
	    (   p_encoded => FND_API.G_FALSE
	    ,   p_msg_index =>  OE_MSG_PUB.G_LAST
	    );
	    OE_MSG_PUB.Reset;
	END IF;
	oe_debug_pub.add('Exiting OE_Flex_Cogs_Pub.Start_process : NDF', 1);  -- 2352606 end

        oe_debug_pub.add(SQLERRM||':'||g_stmt);
	return FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_ERROR THEN
        x_msg_count := OE_MSG_PUB.Count_Msg; -- 2352606 start
        IF x_msg_count > 0 THEN
	    x_msg_data := OE_MSG_PUB.Get
	    (   p_encoded => FND_API.G_FALSE
	    ,   p_msg_index =>  OE_MSG_PUB.G_LAST
	    );
	    OE_MSG_PUB.Reset;
	END IF;
	oe_debug_pub.add('Exiting OE_Flex_Cogs_Pub.Start_process : E', 1);  -- 2352606 end

        oe_debug_pub.add(SQLERRM||':'||g_stmt);
	return FND_API.G_RET_STS_ERROR;

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        --  Get message count and data

        x_msg_count := OE_MSG_PUB.Count_Msg; -- 2352606 start
        IF x_msg_count > 0 THEN
	    x_msg_data := OE_MSG_PUB.Get
	    (   p_encoded => FND_API.G_FALSE
	    ,   p_msg_index =>  OE_MSG_PUB.G_LAST
	    );
	    OE_MSG_PUB.Reset;
	END IF;
	oe_debug_pub.add('Exiting OE_Flex_Cogs_Pub.Start_process : U', 1);  -- 2352606 end

        oe_debug_pub.add(SQLERRM||':'||g_stmt);
        return FND_API.G_RET_STS_UNEXP_ERROR ;

    WHEN OTHERS THEN

        IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            OE_MSG_PUB.Add_Exc_Msg
            (   G_PKG_NAME
            ,   'Start_Process'
            );

        END IF;

        --  Get message count and data

        x_msg_count := OE_MSG_PUB.Count_Msg; -- 2352606 start
        IF x_msg_count > 0 THEN
	    x_msg_data := OE_MSG_PUB.Get
	    (   p_encoded => FND_API.G_FALSE
	    ,   p_msg_index =>  OE_MSG_PUB.G_LAST
	    );
	    OE_MSG_PUB.Reset;
	END IF;

	oe_debug_pub.add('Exiting OE_Flex_Cogs_Pub.Start_process : O', 1);  -- 2352606 end
        oe_debug_pub.add(SQLERRM||':'||g_stmt);
        return FND_API.G_RET_STS_UNEXP_ERROR;

END Start_Process; /*  START_PROCESS */

/*===========================================================================+
 | Name: GET_COST_SALE_ITEM_DERIVED                                          |
 | Purpose: Derives the COGS account for a line regardless of the option flag|
 +===========================================================================*/

PROCEDURE Get_Cost_Sale_Item_Derived
(
	itemtype  	IN VARCHAR2,
	itemkey     IN VARCHAR2,
	actid       IN NUMBER,
	funcmode    IN VARCHAR2,
	result      OUT NOCOPY VARCHAR2)
IS
	l_cost_sale_item_derived	    VARCHAR2(240) DEFAULT NULL;
	l_line_id                  		NUMBER;
	l_organization_id               NUMBER;
	l_inventory_item_id				NUMBER;
	fb_error_msg	                VARCHAR2(240) DEFAULT NULL;
	l_error_msg	        			VARCHAR2(240) DEFAULT NULL;
	l_item_type_code				VARCHAR2(30);
	l_link_to_line_id				NUMBER;

        l_debug_level CONSTANT          NUMBER := oe_debug_pub.g_debug_level;
BEGIN
         -- start data fix project
        OE_STANDARD_WF.Set_Msg_Context(actid);
        -- end data fix project
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Entering OE_Flex_Cogs_Pub.GET_COST_SALE_ITEM_DERIVED');
	   oe_debug_pub.add(' Item Type : '||itemtype,2);
           oe_debug_pub.add(' Item Key : '||itemkey,2);
	   oe_debug_pub.add(' Activity Id : '||to_char(actid),2);
           oe_debug_pub.add(' funcmode : '||funcmode,2);
        END IF;
    IF	(FUNCMODE = 'RUN') THEN
       	l_line_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'LINE_ID');
       	l_organization_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORGANIZATION_ID');
       	l_inventory_item_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'INVENTORY_ITEM_ID');

		SELECT	LINK_TO_LINE_ID,
				ITEM_TYPE_CODE
		INTO	l_link_to_line_id,
				l_item_type_code
		FROM	OE_ORDER_LINES
		WHERE	LINE_ID = l_line_id;

      	l_cost_sale_item_derived := NULL;

      	IF  l_line_id IS NOT NULL THEN
       		BEGIN
             SELECT  NVL(M.COST_OF_SALES_ACCOUNT,0)
	         INTO    l_cost_sale_item_derived
             FROM    OE_ORDER_LINES OL,
		  	 MTL_SYSTEM_ITEMS M
             WHERE   OL.LINE_ID = l_line_id
             AND     M.ORGANIZATION_ID = OL.SHIP_FROM_ORG_ID
		     AND     M.INVENTORY_ITEM_ID = OL.INVENTORY_ITEM_ID;
          	EXCEPTION
              WHEN NO_DATA_FOUND THEN

				IF	l_item_type_code <> OE_GLOBALS.G_ITEM_CONFIG THEN

					FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
					FND_MESSAGE.SET_TOKEN('PARAM1','Inventory Item id');
					FND_MESSAGE.SET_TOKEN('PARAM2','/Warehouse ');
					FND_MESSAGE.SET_TOKEN('VALUE1',l_inventory_item_id);
					FND_MESSAGE.SET_TOKEN('VALUE2',l_organization_id);
                	FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
				 	FND_MESSAGE.SET_ENCODED(fb_error_msg);
				 	l_error_msg := FND_MESSAGE.GET;
                	wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
                	result :=  'COMPLETE:FAILURE';
                	RETURN;
				END IF;
          	END;
		END IF;

       	IF	l_cost_sale_item_derived IS NULL THEN

			IF	l_item_type_code = OE_GLOBALS.G_ITEM_CONFIG THEN
			        IF l_debug_level > 0 THEN
                                   oe_debug_pub.add('Going for Model line for CONFIG',2);
                                END IF;
            BEGIN

            	SELECT  NVL(M.COST_OF_SALES_ACCOUNT,0)
	        	INTO    l_cost_sale_item_derived
              	FROM    OE_ORDER_LINES OL,
			   			MTL_SYSTEM_ITEMS M
              	WHERE   OL.LINE_ID = l_link_to_line_id
              	AND     M.ORGANIZATION_ID = OL.SHIP_FROM_ORG_ID
		    	AND     M.INVENTORY_ITEM_ID = OL.INVENTORY_ITEM_ID;
            EXCEPTION
              	WHEN NO_DATA_FOUND THEN
					FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
					FND_MESSAGE.SET_TOKEN('PARAM1','Inventory Item id');
					FND_MESSAGE.SET_TOKEN('PARAM2','/Warehouse ');
					FND_MESSAGE.SET_TOKEN('VALUE1',l_inventory_item_id);
					FND_MESSAGE.SET_TOKEN('VALUE2',l_organization_id);
               	 	FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
					FND_MESSAGE.SET_ENCODED(fb_error_msg);
				 	l_error_msg := FND_MESSAGE.GET;
               	 	wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
               	 	result :=  'COMPLETE:FAILURE';
               	 	RETURN;
           	END;

		   END IF;
       	END IF;

		IF 	l_cost_sale_item_derived = 0 THEN

			FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
			FND_MESSAGE.SET_TOKEN('PARAM1','Inventory Item id');
			FND_MESSAGE.SET_TOKEN('PARAM2','/Warehouse ');
			FND_MESSAGE.SET_TOKEN('VALUE1',l_inventory_item_id);
			FND_MESSAGE.SET_TOKEN('VALUE2',l_organization_id);

			fb_error_msg := FND_MESSAGE.GET_ENCODED;
			FND_MESSAGE.SET_ENCODED(fb_error_msg);
			l_error_msg := FND_MESSAGE.GET;

            wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
            result :=  'COMPLETE:FAILURE';
	        RETURN;

		END IF;

       	wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',TO_NUMBER(l_cost_sale_item_derived));
       	result := 'COMPLETE:SUCCESS';
             IF l_debug_level > 0 THEN
	  	oe_debug_pub.add('Input Paramerers : ');
	  	oe_debug_pub.add('Line id :'||to_char(l_line_id));
	  	oe_debug_pub.add('Organization id :'||to_char(l_organization_id));
	  	oe_debug_pub.add('Output : ');
	  	oe_debug_pub.add('Generated CCID :'||l_cost_sale_item_derived);

	  	oe_debug_pub.add('Exiting from OE_Flex_COGS_Pub.Get_Cost_Sale_Item_Derived',1);
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
         wf_core.context('OE_FLEX_COGS_PUB','GET_COST_SALE_ITEM_DERIVED',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
         result :=  'COMPLETE:FAILURE';
         -- start data fix project
         OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
         -- end data fix project
         RAISE;
END GET_COST_SALE_ITEM_DERIVED;

/*===========================================================================+
 | Name: GET_MODEL_DERIVED                                          |
 | Purpose: Derives the COGS account for an option line from it's option	|
 +===========================================================================*/

PROCEDURE Get_Model_Derived
(
	itemtype  IN VARCHAR2,
	itemkey     IN VARCHAR2,
	actid       IN NUMBER,
	funcmode    IN VARCHAR2,
	result      OUT NOCOPY VARCHAR2)

IS
	l_cost_sale_model_derived	    VARCHAR2(240) DEFAULT NULL;
	l_line_id                  		NUMBER;
	l_organization_id               NUMBER;
	l_model_line_id					NUMBER;
	fb_error_msg	                VARCHAR2(240) DEFAULT NULL;
	l_error_msg	        			VARCHAR2(240) DEFAULT NULL;
	l_ship_from_org_id				NUMBER;
	l_inventory_item_id				NUMBER;
	l_top_model_line_id				NUMBER;

        l_debug_level CONSTANT                          NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        -- start data fix project
        OE_STANDARD_WF.Set_Msg_Context(actid);
        -- end data fix project
    IF  l_debug_level > 0 THEN
	oe_debug_pub.add('Entering OE_Flex_Cogs_Pub.GET_COST_SALE_MODEL_DERIVED');

	oe_debug_pub.add(' Item Type : '||itemtype,2);
	oe_debug_pub.add(' Item Key : '||itemkey,2);
	oe_debug_pub.add(' Activity Id : '||to_char(actid),2);
	oe_debug_pub.add(' funcmode : '||funcmode,2);
    END IF;
    IF 	(FUNCMODE = 'RUN') THEN
       	l_line_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'LINE_ID');

		SELECT	TOP_MODEL_LINE_ID,
				INVENTORY_ITEM_ID,
				SHIP_FROM_ORG_ID
		INTO	l_top_model_line_id,
				l_inventory_item_id,
				l_ship_from_org_id
		FROM	OE_ORDER_LINES
		WHERE	LINE_ID = l_line_id;

	   	l_model_line_id := l_top_model_line_id;
		l_organization_id := l_ship_from_org_id;
	        IF l_debug_level > 0 THEN
                   oe_debug_pub.add('Model Line Id : '||to_char(l_model_line_id),2);
                END IF;
       	l_cost_sale_model_derived := NULL;

       	IF 	(l_model_line_id IS NOT NULL) THEN
       	    BEGIN
           	  SELECT  NVL(M.COST_OF_SALES_ACCOUNT,0)
	       	  INTO    l_cost_sale_model_derived
           	  FROM    OE_ORDER_LINES OL,
				  	  MTL_SYSTEM_ITEMS M
           	  WHERE   OL.LINE_ID = l_model_line_id
              AND     M.ORGANIZATION_ID = OL.SHIP_FROM_ORG_ID
		      AND     M.INVENTORY_ITEM_ID = OL.INVENTORY_ITEM_ID;
            EXCEPTION
              WHEN NO_DATA_FOUND THEN
					FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
					FND_MESSAGE.SET_TOKEN('PARAM1','Inventory Item id');
					FND_MESSAGE.SET_TOKEN('PARAM2','/Warehouse ');
					FND_MESSAGE.SET_TOKEN('VALUE1',l_inventory_item_id);
					FND_MESSAGE.SET_TOKEN('VALUE2',l_organization_id);
					fb_error_msg := FND_MESSAGE.GET_ENCODED;
					FND_MESSAGE.SET_ENCODED(fb_error_msg);
					l_error_msg := FND_MESSAGE.GET;
                	wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
                	result :=  'COMPLETE:FAILURE';
                	RETURN;
            END;
       	END IF;

		IF 	l_cost_sale_model_derived = 0 THEN

			FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
			FND_MESSAGE.SET_TOKEN('PARAM1','Inventory Item id');
			FND_MESSAGE.SET_TOKEN('PARAM2','/Warehouse ');
			FND_MESSAGE.SET_TOKEN('VALUE1',l_inventory_item_id);
			FND_MESSAGE.SET_TOKEN('VALUE2',l_organization_id);

			fb_error_msg := FND_MESSAGE.GET_ENCODED;
			FND_MESSAGE.SET_ENCODED(fb_error_msg);
			l_error_msg := FND_MESSAGE.GET;

            wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
            result :=  'COMPLETE:FAILURE';
	        RETURN;

		END IF;

       	wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',TO_NUMBER(l_cost_sale_model_derived));
       	result := 'COMPLETE:SUCCESS';
           IF l_debug_level > 0 THEN
	  	oe_debug_pub.add('Input Paramerers : ');
	  	oe_debug_pub.add('Line id :'||to_char(l_line_id));
	  	oe_debug_pub.add('Output : ');
	  	oe_debug_pub.add('Generated CCID :'||l_cost_sale_model_derived);

	  	oe_debug_pub.add('Exiting from OE_Flex_COGS_Pub.Get_Model_Derived',1);
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
         wf_core.context('OE_FLEX_COGS_PUB','GET_MODEL_DERIVED',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
         result :=  'COMPLETE:FAILURE';
         -- start data fix project
         OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
         -- end data fix project
         RAISE;
END Get_Model_Derived;


/*===========================================================================+
 | Name: GET_ORDER_TYPE_DERIVED                                              |
 | Purpose: Derives the CCID from the Order type                             |
 +===========================================================================*/

PROCEDURE Get_Order_Type_Derived
(
	itemtype  	IN VARCHAR2,
	itemkey     IN VARCHAR2,
	actid       IN NUMBER,
	funcmode    IN VARCHAR2,
	result      OUT NOCOPY VARCHAR2)
IS
	l_order_type_ccid               VARCHAR2(240) DEFAULT NULL;
	l_order_type_id                 NUMBER;
	fb_error_msg	                VARCHAR2(240) DEFAULT NULL;
	l_error_msg	                   	VARCHAR2(240) DEFAULT NULL;

        l_debug_level CONSTANT          NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        -- start data fix project
        OE_STANDARD_WF.Set_Msg_Context(actid);
        -- end data fix project
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Entering OE_Flex_Cogs_Pub.GET_ORDER_TYPE_DERIVED');
	   oe_debug_pub.add(' Item Type : '||itemtype,2);
           oe_debug_pub.add(' Item Key : '||itemkey,2);
	   oe_debug_pub.add(' Activity Id : '||to_char(actid),2);
           oe_debug_pub.add(' funcmode : '||funcmode,2);
        END IF;

	IF 	(funcmode = 'RUN') THEN
       	l_order_type_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_TYPE_ID');
       	l_order_type_ccid := NULL;
       	IF 	(l_order_type_id IS NOT NULL) THEN
         	BEGIN
	       		SELECT    NVL(COST_OF_GOODS_SOLD_ACCOUNT, 0)
	       		INTO      l_order_type_ccid
	       		FROM      OE_TRANSACTION_TYPES_ALL
	       		WHERE     TRANSACTION_TYPE_ID = l_order_type_id;
           	EXCEPTION
            	WHEN NO_DATA_FOUND THEN
					FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
					FND_MESSAGE.SET_TOKEN('PARAM1','Order Type Id');
					FND_MESSAGE.SET_TOKEN('PARAM2','');
					FND_MESSAGE.SET_TOKEN('VALUE1',l_order_type_id);
					FND_MESSAGE.SET_TOKEN('VALUE2','');
					fb_error_msg := FND_MESSAGE.GET_ENCODED;
					FND_MESSAGE.SET_ENCODED(fb_error_msg);
					l_error_msg := FND_MESSAGE.GET;
               		wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
               		result :=  'COMPLETE:FAILURE';
	          		RETURN;
         	END;
       	END IF;

		IF 	l_order_type_ccid = 0 THEN

			FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
			FND_MESSAGE.SET_TOKEN('PARAM1','Order Type Id');
			FND_MESSAGE.SET_TOKEN('PARAM2','');
			FND_MESSAGE.SET_TOKEN('VALUE1',l_order_type_id);
			FND_MESSAGE.SET_TOKEN('VALUE2','');

			fb_error_msg := FND_MESSAGE.GET_ENCODED;
			FND_MESSAGE.SET_ENCODED(fb_error_msg);
			l_error_msg := FND_MESSAGE.GET;

            wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
            result :=  'COMPLETE:FAILURE';
	        RETURN;

		END IF;

       	wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',TO_NUMBER(L_ORDER_TYPE_CCID));
       	result := 'COMPLETE:SUCCESS';
             IF l_debug_level > 0 THEN
	  	oe_debug_pub.add('Input Paramerers : ',2);
	  	oe_debug_pub.add('Order Type ID :'||to_char(l_order_type_id),2);
	  	oe_debug_pub.add('Output : ',2);
	  	oe_debug_pub.add('Generated CCID :'||l_order_type_ccid,2);
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
            wf_core.context('OE_FLEX_COGS_PUB','GET_ORDER_TYPE_DERIVED',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
            result :=  'COMPLETE:FAILURE';
         -- start data fix project
         OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
         OE_STANDARD_WF.Save_Messages;
         OE_STANDARD_WF.Clear_Msg_Context;
         -- end data fix project
	     RAISE;
END Get_Order_Type_Derived;

/*===========================================================================+
 | Name: GET_SALESREP_REV_DERIVED                                            |
 | Purpose: Derives the CCID from salesrep's revenue segment                 |
 +===========================================================================*/

PROCEDURE Get_Salesrep_Rev_Derived
(
	itemtype  	IN VARCHAR2,
	itemkey     IN VARCHAR2,
	actid       IN NUMBER,
	funcmode    IN VARCHAR2,
	result      OUT NOCOPY VARCHAR2)

IS

	l_salesrep_rev_derived	VARCHAR2(240) DEFAULT NULL;
	l_salesrep_id           NUMBER;
	fb_error_msg	        VARCHAR2(240) DEFAULT NULL;
	l_error_msg	        	VARCHAR2(240) DEFAULT NULL;
        l_debug_level CONSTANT  NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        -- start data fix project
        OE_STANDARD_WF.Set_Msg_Context(actid);
        -- end data fix project
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Entering OE_FLEX_COGS_PUB.GET_SALESREP_REV_DERIVED',1);
        END IF;
	IF 	(FUNCMODE = 'RUN') THEN
		l_salesrep_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'SALESREP_ID');
	        IF l_debug_level > 0 THEN
                   oe_debug_pub.add('Sales rep id : '||to_char(l_salesrep_id),2);
                END If;
       	l_salesrep_rev_derived := NULL;

       	IF 	(l_salesrep_id IS NOT NULL) THEN

         	BEGIN
	       		SELECT    NVL(GL_ID_REV, 0)
	       		INTO      l_salesrep_rev_derived
	       		FROM      RA_SALESREPS
	       		WHERE     SALESREP_ID = L_SALESREP_ID;


           	EXCEPTION
               	WHEN NO_DATA_FOUND THEN

					FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
					FND_MESSAGE.SET_TOKEN('PARAM1','Sales rep id');
					FND_MESSAGE.SET_TOKEN('PARAM2','');
					FND_MESSAGE.SET_TOKEN('VALUE1',l_salesrep_id);
					FND_MESSAGE.SET_TOKEN('VALUE2','');
					fb_error_msg := FND_MESSAGE.GET_ENCODED;
					FND_MESSAGE.SET_ENCODED(fb_error_msg);
					l_error_msg := FND_MESSAGE.GET;
                   	wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
					result :=  'COMPLETE:FAILURE';
					RETURN;
         	END;
       	END IF;

		IF 	l_salesrep_rev_derived = 0 THEN

			FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
			FND_MESSAGE.SET_TOKEN('PARAM1','Sales rep id');
			FND_MESSAGE.SET_TOKEN('PARAM2','');
			FND_MESSAGE.SET_TOKEN('VALUE1',l_salesrep_id);
			FND_MESSAGE.SET_TOKEN('VALUE2','');

			fb_error_msg := FND_MESSAGE.GET_ENCODED;
			FND_MESSAGE.SET_ENCODED(fb_error_msg);
			l_error_msg := FND_MESSAGE.GET;

            wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
            result :=  'COMPLETE:FAILURE';
	        RETURN;

		END IF;

       	wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',TO_NUMBER(l_salesrep_rev_derived));
       	result := 'COMPLETE:SUCCESS';
	 IF l_debug_level > 0 THEN
            oe_debug_pub.add('Input Paramerers : ',2);
	    oe_debug_pub.add('Salesrep ID :' || to_char(l_salesrep_id),2);
	    oe_debug_pub.add('Output : ',2);
	    oe_debug_pub.add('Generated CCID :'||l_salesrep_rev_derived,2);
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
              wf_core.context('OE_FLEX_COGS_PUB','GET_SALESREP_REV_DERIVED',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
              result :=  'COMPLETE:FAILURE';
              -- start data fix project
              OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
              OE_STANDARD_WF.Save_Messages;
              OE_STANDARD_WF.Clear_Msg_Context;
              -- end data fix project
       	RAISE;
END Get_Salesrep_Rev_Derived;


/*===========================================================================+
 | Name: Get_Type_From_Line                                                  |
 | Purpose: Get transaction type id from a line                              |
 +===========================================================================*/
PROCEDURE Get_Type_From_Line
(       itemtype    IN VARCHAR2,
	itemkey     IN VARCHAR2,
	actid       IN NUMBER,
	funcmode    IN VARCHAR2,
	result      OUT NOCOPY VARCHAR2)

IS
	l_order_line_id			NUMBER;
	l_header_id			     NUMBER;
	fb_error_msg			VARCHAR2(240) DEFAULT NULL;
	l_error_msg				VARCHAR2(240) DEFAULT NULL;
        l_order_type_id                NUMBER; --a.k.a transaction_type_id, line_type_id
        l_debug_level CONSTANT         NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        -- start data fix project
        OE_STANDARD_WF.Set_Msg_Context(actid);
        -- end data fix project
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Entering  Get_type_from_line',2);
        END IF;
        --DBMS_OUTPUT.PUT_LINE('Entering get_line_from_line');

	IF 	(FUNCMODE = 'RUN') THEN
       	l_order_line_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'LINE_ID');
       	    IF l_debug_level > 0 THEN
	       oe_debug_pub.add('Input Paramerers : ',2);
	       oe_debug_pub.add('Order Line ID :'|| to_char(l_order_line_id),2);
	    END IF;

       	IF 	(l_order_line_id IS NOT NULL) THEN
         	BEGIN

                        Select line_type_id
                        Into   l_order_type_id
                        From   oe_order_lines_all
                        Where  line_id = l_order_line_id;

			EXCEPTION
		          WHEN NO_DATA_FOUND THEN
			  --FND_MESSAGE.SET_NAME('ONT','OE_COGS_SALESREP_NOT_FOUND');
			  --FND_MESSAGE.SET_TOKEN('LINEID',l_order_line_id);
		       	  --fb_error_msg := FND_MESSAGE.GET_ENCODED;
		  	  --FND_MESSAGE.SET_ENCODED(fb_error_msg);
			  --l_error_msg := FND_MESSAGE.GET;
         	 	  wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE','No line type id found in oe_order_lines_all');
         		  result :=  'COMPLETE:FAILURE';
         		  RETURN;

         	END;
         	wf_engine.setItemAttrNumber(itemtype,itemkey,'ORDER_TYPE_ID',l_order_type_id);
         	result := 'COMPLETE:SUCCESS';
       	ELSE
         	result :=  'COMPLETE:FAILURE';
	    	RETURN;
       	END IF;
	    IF l_debug_level > 0 THEN
               oe_debug_pub.add('Output : ',2);
               oe_debug_pub.add('Salesrep ID :'|| l_order_type_id,2);
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
		wf_core.context('OE_FLEX_COGS_PUB','GET_TYPE_FROM_LINE',
		itemtype,itemkey,TO_CHAR(actid),funcmode);
		result :=  'COMPLETE:FAILURE';
                -- start data fix project
                OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
                OE_STANDARD_WF.Save_Messages;
                OE_STANDARD_WF.Clear_Msg_Context;
                -- end data fix project
		RAISE;
END Get_Type_From_Line;


/*===========================================================================+
 | Name: GET_SALESREP_ID                                                     |
 | Purpose: Derives the salesrep's ID                                        |
 +===========================================================================*/

PROCEDURE Get_Salesrep_Id
(
	itemtype  	IN VARCHAR2,
	itemkey     IN VARCHAR2,
	actid       IN NUMBER,
	funcmode    IN VARCHAR2,
	result      OUT NOCOPY VARCHAR2)

IS
	l_salesrep_id			VARCHAR2(240) DEFAULT NULL;
	l_order_line_id			NUMBER;
	l_header_id			     NUMBER;
	fb_error_msg			VARCHAR2(240) DEFAULT NULL;
	l_error_msg				VARCHAR2(240) DEFAULT NULL;
        l_debug_level CONSTANT          NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        -- start data fix project
        OE_STANDARD_WF.Set_Msg_Context(actid);
        -- end data fix project
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Entering OE_FLEX_COGS_PUB.GET_SALESREP_ID',2);
        END IF;
	IF 	(FUNCMODE = 'RUN') THEN
       	l_order_line_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'LINE_ID');
       	l_header_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');

        IF l_debug_level > 0 THEN
            oe_debug_pub.add('Input Paramerers : ',2);
	    oe_debug_pub.add('Order Line ID :'|| to_char(l_order_line_id),2);
	    oe_debug_pub.add('Order Header ID :'|| to_char(l_header_id),2);
        END IF;
       	l_salesrep_id := NULL;

       	IF 	(l_order_line_id IS NOT NULL) THEN
         	BEGIN
	       		SELECT    SALESREP_ID
	       		INTO      l_salesrep_id
	       		FROM      OE_SALES_CREDITS
	       		WHERE     LINE_ID = L_ORDER_LINE_ID
	       		AND       SALESREP_ID = (
							   	SELECT MIN(SALESREP_ID)
					   			FROM OE_SALES_CREDITS SC ,
						   		OE_SALES_CREDIT_TYPES SCT
					   			WHERE SC.LINE_ID = L_ORDER_LINE_ID
								AND   SC.SALES_CREDIT_TYPE_ID = SCT.SALES_CREDIT_TYPE_ID
					   			AND SCT.QUOTA_FLAG = 'Y'
					   			AND SC.PERCENT = (
						  		SELECT MAX(PERCENT)
								FROM OE_SALES_CREDITS SC, --Bug4096083 start
                                                                OE_SALES_CREDIT_TYPES SCT
                                                                WHERE SC.LINE_ID = L_ORDER_LINE_ID
                                                                AND   SC.SALES_CREDIT_TYPE_ID = SCT.SALES_CREDIT_TYPE_ID
                                                                AND   SCT.QUOTA_FLAG = 'Y' --Bug4096083 end
                           		                   )
                           				)
            	AND ROWNUM = 1;

			EXCEPTION
				WHEN NO_DATA_FOUND THEN
	                IF l_debug_level > 0 THEN
                           oe_debug_pub.add('Sales rep not found at line level',2);
                        END IF;
				BEGIN
			  	     SELECT    SALESREP_ID
	       		     INTO      l_salesrep_id
	       		     FROM      OE_SALES_CREDITS
	       		     WHERE     HEADER_ID = l_header_id
					AND       LINE_ID IS NULL
	       		     AND       SALESREP_ID = (
							   	SELECT MIN(SALESREP_ID)
					   			FROM OE_SALES_CREDITS SC ,
						   		OE_SALES_CREDIT_TYPES SCT
					   			WHERE SC.HEADER_ID = L_HEADER_ID
					               		AND   SC.LINE_ID IS NULL
								AND   SC.SALES_CREDIT_TYPE_ID = SCT.SALES_CREDIT_TYPE_ID
					   			AND SCT.QUOTA_FLAG = 'Y'
					   			AND SC.PERCENT = (
						  		SELECT MAX(PERCENT)
								FROM OE_SALES_CREDITS SC, --Bug4096083 start
                                                                OE_SALES_CREDIT_TYPES SCT
                                                                WHERE SC.HEADER_ID = L_HEADER_ID
                                                                AND   SC.LINE_ID IS NULL
                                                                AND   SC.SALES_CREDIT_TYPE_ID = SCT.SALES_CREDIT_TYPE_ID
                                                                AND   SCT.QUOTA_FLAG = 'Y' --Bug4096083 end
                           		                   )
                           				)
            	          AND ROWNUM = 1;

				EXCEPTION

				     WHEN NO_DATA_FOUND THEN
					FND_MESSAGE.SET_NAME('ONT','OE_COGS_SALESREP_NOT_FOUND');
					FND_MESSAGE.SET_TOKEN('LINEID',l_order_line_id);
					fb_error_msg := FND_MESSAGE.GET_ENCODED;
					FND_MESSAGE.SET_ENCODED(fb_error_msg);
					l_error_msg := FND_MESSAGE.GET;
         				wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
         				result :=  'COMPLETE:FAILURE';
         				RETURN;
                    END;
         	END;
         	wf_engine.setItemAttrNumber(itemtype,itemkey,'SALESREP_ID',TO_NUMBER(l_salesrep_id));
         	result := 'COMPLETE:SUCCESS';
       	ELSE
         	result :=  'COMPLETE:FAILURE';
	    	RETURN;
       	END IF;
	    IF l_debug_level > 0 THEN
               oe_debug_pub.add('Output : ',2);
	       oe_debug_pub.add('Salesrep ID :'|| l_salesrep_id,2);
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
		wf_core.context('OE_FLEX_COGS_PUB','GET_SALESREP_ID',
		itemtype,itemkey,TO_CHAR(actid),funcmode);
		result :=  'COMPLETE:FAILURE';
                -- start data fix project
                OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
                OE_STANDARD_WF.Save_Messages;
                OE_STANDARD_WF.Clear_Msg_Context;
                -- end data fix project
		RAISE;
END Get_Salesrep_Id;

/*===========================================================================+
 | Name: Get_invitm_Org_derived
 | Purpose: Derives a cost of sales account for an inventory Item ID         |
 | and Selling Operating Unit
 +===========================================================================*/

PROCEDURE Get_Invitm_Org_Derived
(
	itemtype  IN VARCHAR2,
	itemkey     IN VARCHAR2,
	actid       IN NUMBER,
	funcmode    IN VARCHAR2,
	result      OUT NOCOPY VARCHAR2)
IS
	l_account_derived      	VARCHAR2(240) DEFAULT NULL;
	l_inv_item_id          	NUMBER;
	l_ship_from_org_id               	NUMBER;
	fb_error_msg	       	VARCHAR2(240) DEFAULT NULL;
	l_error_msg	       		VARCHAR2(240) DEFAULT NULL;

        l_debug_level CONSTANT  NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        -- start data fix project
        OE_STANDARD_WF.Set_Msg_Context(actid);
        -- end data fix project
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Entering OE_FLEX_COGS_PUB.Get_Invitm_Org_Derived',1);
        END IF;
	IF 	(FUNCMODE = 'RUN') THEN
        l_inv_item_id := wf_engine.GetItemAttrNumber(itemtype,itemkey,'INVENTORY_ITEM_ID');
        l_ship_from_org_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORGANIZATION_ID');
	    IF l_debug_level > 0 THEN
               oe_debug_pub.add('Input Paramerers : ',2);
	       oe_debug_pub.add('Inventory Item ID :'|| to_char(l_inv_item_id),2);
	       oe_debug_pub.add('Organization ID :'|| to_char(l_ship_from_org_id),2);
            END IF;
        L_ACCOUNT_DERIVED := NULL;
        IF 	(L_INV_ITEM_ID IS NOT NULL) THEN
          	BEGIN
	       		SELECT    NVL(COST_OF_SALES_ACCOUNT, 0)
	        	INTO      l_account_derived
	        	FROM      MTL_SYSTEM_ITEMS
	        	WHERE     INVENTORY_ITEM_ID = l_inv_item_id
	        	AND       ORGANIZATION_ID = l_ship_from_org_id;
            EXCEPTION
                WHEN NO_DATA_FOUND THEN
					FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
					FND_MESSAGE.SET_TOKEN('PARAM1','Inventory Item id');
					FND_MESSAGE.SET_TOKEN('PARAM2','/Warehouse ');
					FND_MESSAGE.SET_TOKEN('VALUE1',l_inv_item_id);
					FND_MESSAGE.SET_TOKEN('VALUE2',l_ship_from_org_id);
					fb_error_msg := FND_MESSAGE.GET_ENCODED;
					FND_MESSAGE.SET_ENCODED(fb_error_msg);
					l_error_msg := FND_MESSAGE.GET;
                    wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
                    result :=  'COMPLETE:FAILURE';
	               	RETURN;
        	END;

			IF 	l_account_derived = 0 THEN

				FND_MESSAGE.SET_NAME('ONT','OE_COGS_CCID_GEN_FAILED');
				FND_MESSAGE.SET_TOKEN('PARAM1','Inventory Item id');
				FND_MESSAGE.SET_TOKEN('PARAM2','/Warehouse ');
				FND_MESSAGE.SET_TOKEN('VALUE1',l_inv_item_id);
				FND_MESSAGE.SET_TOKEN('VALUE2',l_ship_from_org_id);

				fb_error_msg := FND_MESSAGE.GET_ENCODED;
				FND_MESSAGE.SET_ENCODED(fb_error_msg);
				l_error_msg := FND_MESSAGE.GET;

           		wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
            	result :=  'COMPLETE:FAILURE';
	        	RETURN;

			END IF;
          	wf_engine.setItemAttrNumber(itemtype,itemkey,'GENERATED_CCID',TO_NUMBER(l_account_derived));
          	result := 'COMPLETE:SUCCESS';
        ELSE
        	result :=  'COMPLETE:FAILURE';
	     	RETURN;
        END IF;
	    IF l_debug_level > 0 THEN
               oe_debug_pub.add('Output : ',2);
	       oe_debug_pub.add('Generated CCID :'|| l_account_derived,2);
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
		wf_core.context('OE_FLEX_COGS_PUB','Get_Invitm_Org_Derived',
		itemtype,itemkey,TO_CHAR(actid),funcmode);
		result :=  'COMPLETE:FAILURE';
                -- start data fix project
                OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
                OE_STANDARD_WF.Save_Messages;
                OE_STANDARD_WF.Clear_Msg_Context;
                -- end data fix project
		RAISE;

END Get_Invitm_Org_Derived;

PROCEDURE Check_Option
(
	itemtype  	IN VARCHAR2,
	itemkey     IN VARCHAR2,
	actid       IN NUMBER,
	funcmode    IN VARCHAR2,
	result      OUT NOCOPY VARCHAR2)

IS

	l_option_flag					VARCHAR2(1);
	fb_error_msg	                VARCHAR2(240) DEFAULT NULL;
        l_debug_level CONSTANT          NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        -- start data fix project
        OE_STANDARD_WF.Set_Msg_Context(actid);
        -- end data fix project
	IF l_debug_level > 0 THEN
           oe_debug_pub.add('Entering OE_FLEX_COGS_PUB.Check_Option',1);
        END IF;
	IF 	(FUNCMODE = 'RUN') THEN
        l_option_flag := wf_engine.GetItemAttrText(itemtype,itemkey,'OPTION_FLAG');
	    IF l_debug_level > 0 THEN
               oe_debug_pub.add('Option Flag :'|| l_option_flag,2);
            END IF;
		IF	l_option_flag = 'Y' THEN

        	result := 'COMPLETE:TRUE';
		ELSE
        	result := 'COMPLETE:FALSE';

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
		wf_core.context('OE_FLEX_COGS_PUB','Check_Option',
		itemtype,itemkey,TO_CHAR(actid),funcmode);
		result :=  'COMPLETE:FAILURE';
                -- start data fix project
                OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
                OE_STANDARD_WF.Save_Messages;
                OE_STANDARD_WF.Clear_Msg_Context;
                -- end data fix project
		RAISE;
END Check_Option;

/*===========================================================================+
 | Name: GET_TRX_TYPE                                                        |
 | Purpose: Derives the transaction type for a commitment ID                 |
 +===========================================================================*/

PROCEDURE Get_Trx_Type
(
	itemtype  	IN VARCHAR2,
	itemkey     IN VARCHAR2,
	actid       IN NUMBER,
	funcmode    IN VARCHAR2,
	result      OUT NOCOPY VARCHAR2)
IS
	l_trx_type                       VARCHAR2(240) DEFAULT NULL;
	l_commitment_id                  NUMBER;
	fb_error_msg	                   VARCHAR2(240) DEFAULT NULL;
	l_error_msg	                   VARCHAR2(240) DEFAULT NULL;
        l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        -- start data fix project
        OE_STANDARD_WF.Set_Msg_Context(actid);
        -- end data fix project
        IF l_debug_level > 0 THEN
           oe_debug_pub.add('Entering OE_FLEX_COGS_PUB.GET_TRX_TYPE',2);
        END IF;
	IF 	(FUNCMODE = 'RUN') THEN
       	l_commitment_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'COMMITMENT_ID');
	    IF l_debug_level > 0 THEN
               oe_debug_pub.add('Input Paramerers : ',2);
	       oe_debug_pub.add('Commitment ID :'|| to_char(l_commitment_id),2);
            END IF;
 	l_trx_type := NULL;

       	IF 	(l_commitment_id IS NOT NULL) THEN
         	BEGIN
	       		SELECT    /* MOAC_SQL_CHANGE */ TYPE.TYPE
	       		INTO      l_trx_type
	       		FROM      RA_CUSTOMER_TRX TRX, RA_CUST_TRX_TYPES_ALL TYPE
	       		WHERE     TRX.CUSTOMER_TRX_ID = L_COMMITMENT_ID
                        AND       TRX.ORG_ID = TYPE.ORG_ID
	       		AND       TRX.CUST_TRX_TYPE_ID = TYPE.CUST_TRX_TYPE_ID;
           	EXCEPTION
               WHEN NO_DATA_FOUND THEN
				FND_MESSAGE.SET_NAME('ONT','OE_COGS_TRX_TYPE_NOT_FOUND');
				FND_MESSAGE.SET_TOKEN('COMMITMENTID',l_commitment_id);
				fb_error_msg := FND_MESSAGE.GET_ENCODED;
				FND_MESSAGE.SET_ENCODED(fb_error_msg);
				l_error_msg := FND_MESSAGE.GET;
                 	wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',l_error_msg);
                 	result :=  'COMPLETE:FAILURE';
	            	RETURN;
         	END;
         	wf_engine.setItemAttrText(itemtype,itemkey,'TRX_TYPE_DERIVED',l_trx_type);
         	result := 'COMPLETE:SUCCESS';
       ELSE
         	result :=  'COMPLETE:FAILURE';
	    	RETURN;
       END IF;
	   IF l_debug_level > 0 THEN
              oe_debug_pub.add('Output : ',2);
	      oe_debug_pub.add('Transaction Type'||l_trx_type,2);
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
		wf_core.context('OE_FLEX_COGS_PUB','GET_TRX_TYPE',
		itemtype,itemkey,TO_CHAR(actid),funcmode);
		result :=  'COMPLETE:FAILURE';
                -- start data fix project
                OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
                OE_STANDARD_WF.Save_Messages;
                OE_STANDARD_WF.Clear_Msg_Context;
                -- end data fix project
		RAISE;
END Get_Trx_Type;

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

FUNCTION Build (
	fb_flex_num IN NUMBER DEFAULT 101,
	oe_ii_commitment_id_RAW IN VARCHAR2 DEFAULT NULL,
	oe_ii_customer_id_raw IN VARCHAR2 DEFAULT NULL,
	oe_ii_header_id_raw IN VARCHAR2 DEFAULT NULL,
	oe_ii_option_flag_raw IN VARCHAR2 DEFAULT NULL,
	oe_ii_order_category_raw IN VARCHAR2 DEFAULT NULL,
	oe_ii_order_line_id_raw IN VARCHAR2 DEFAULT NULL,
	oe_ii_order_type_id_raw IN VARCHAR2 DEFAULT NULL,
	oe_ii_organization_id_raw IN VARCHAR2 DEFAULT NULL,
	fb_flex_seg IN OUT NOCOPY VARCHAR2,
	fb_error_msg IN OUT NOCOPY VARCHAR2)
RETURN BOOLEAN
IS
        l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN
	IF l_debug_level > 0 THEN
           oe_debug_pub.add('Entering OE_FLEX_COGS_PUB.BUILD',2);
        END IF;
	fb_flex_seg := NULL;

	FND_MESSAGE.SET_NAME('FND', 'FLEXWK-UPGRADE FUNC MISSING');
	FND_MESSAGE.SET_TOKEN('FUNC','OE_INVENTORY_INTERFACE');
	FB_ERROR_MSG := FND_MESSAGE.GET_ENCODED;
	RETURN FALSE;
END Build;


/*===========================================================================+
 | Name: UPGRADE_COGS_FLEX                                                   |
 | Purpose: Determines whether an item is an option item or not              |
 +===========================================================================*/

PROCEDURE Upgrade_Cogs_Flex
(
	itemtype  	IN VARCHAR2,
	itemkey		IN VARCHAR2,
	actid	    IN NUMBER,
	funcmode    IN VARCHAR2,
	result      OUT NOCOPY VARCHAR2)

IS

	l_order_line_id                   NUMBER;
	l_organization_id                 NUMBER;
	l_commitment_id                   NUMBER;
	l_customer_id                     NUMBER;
	l_header_id                       NUMBER;
	l_order_category                  VARCHAR2(30);
	l_order_type_id                   NUMBER;
	l_option_flag                     VARCHAR2(2);
	l_flex_num                        NUMBER;
	l_fb_flex_segs                    VARCHAR2(240) DEFAULT NULL;
	l_fb_error_msg                    VARCHAR2(240) DEFAULT NULL;
        l_debug_level CONSTANT            NUMBER := oe_debug_pub.g_debug_level;
BEGIN
        -- start data fix project
        OE_STANDARD_WF.Set_Msg_Context(actid);
        -- end data fix project
        IF l_debug_level > 0 THEN
            oe_debug_pub.add('Entering OE_FLEX_COGS_PUB.BUILD',1);
        END IF;
 	IF (FUNCMODE = 'RUN') THEN

     	l_order_line_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'LINE_ID');
     	l_organization_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORGANIZATION_ID');
     	l_commitment_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'COMMITMENT_ID');
     	l_customer_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'CUSTOMER_ID');
     	l_header_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'HEADER_ID');
     	l_order_category:= wf_engine.GetItemAttrText(itemtype,itemkey,'ORDER_CATEGORY');
     	l_order_type_id:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'ORDER_TYPE_ID');
     	l_option_flag:= wf_engine.GetItemAttrText(itemtype,itemkey,'OPTION_FLAG');
     	l_flex_num:= wf_engine.GetItemAttrNumber(itemtype,itemkey,'CHART_OF_ACCOUNTS_ID');

	     IF l_debug_level > 0 THEN
                oe_debug_pub.add('Input Paramerers : ',2);
		oe_debug_pub.add('Line id :'||to_char(l_order_line_id),2);
		oe_debug_pub.add('Organization id :'||to_char(l_organization_id),2);
		oe_debug_pub.add('Commitment ID :'||to_char(l_commitment_id),2);
		oe_debug_pub.add('Customer ID :'||to_char(l_customer_id),2);
		oe_debug_pub.add('Order Category :'||l_order_category,2);
		oe_debug_pub.add('Order Type :'||to_char(l_order_type_id),2);
		oe_debug_pub.add('Option Flag :'||l_option_flag,2);
		oe_debug_pub.add('Structure Number :'|| to_char(l_flex_num),2);
            END IF;
    	IF (OE_FLEX_COGS_PUB.Build(
							l_flex_num,
							l_commitment_id,
							l_customer_id,
							l_header_id,
                            l_option_flag,
							l_order_category,
							l_order_line_id,
							l_order_type_id,
							l_organization_id,
							l_fb_flex_segs,
                            l_fb_error_msg)=TRUE) THEN

		  result := 'COMPLETE:SUCCESS';
    	ELSE
            result := 'COMPLETE:FAILURE';
    	END IF;

    	IF 	L_FB_ERROR_MSG IS NOT NULL THEN
       	 	wf_engine.setItemAttrText(itemtype,itemkey,'ERROR_MESSAGE',L_FB_ERROR_MSG);
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
       wf_core.context('OE_FLEX_COGS_PUB','UPGRADE_COGS_FLEX',
			itemtype,itemkey,TO_CHAR(actid),funcmode);
        -- start data fix project
        OE_STANDARD_WF.Add_Error_Activity_Msg(p_actid => actid,
                                          p_itemtype => itemtype,
                                          p_itemkey => itemkey);
        OE_STANDARD_WF.Save_Messages;
        OE_STANDARD_WF.Clear_Msg_Context;
        -- end data fix project
	RAISE;
END Upgrade_Cogs_Flex;

END OE_Flex_Cogs_Pub;

/
