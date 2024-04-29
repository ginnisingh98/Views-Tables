--------------------------------------------------------
--  DDL for Package Body XNB_CMN_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNB_CMN_PVT" AS
/* $Header: XNBVCMNB.pls 120.18 2006/11/20 05:40:50 pselvam noship $ */

       --Private Constants defined for this package.
        --g_party_type: The XML Gateway Trading Partner Type is assumed to be 'C'-Customer here
       g_party_type    CONSTANT CHAR(1) NOT NULL DEFAULT 'C';

        --XML Gateway Transaction Type for XNB
    g_xnb_transation_type       CONSTANT CHAR(3) NOT NULL DEFAULT 'XNB';
        --XML Gateway Transaction Subtypes for the Various Messages
    g_owner_change_txn_subtype		CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'OO';
    g_item_update_txn_subtype		CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'IO';
--    g_account_add_txn_subtype		CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'AAO';
    g_account_txn_subtype		CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'AO';
--    g_account_update_txn_subtype	CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'UAO';
    g_salesorder_add_txn_subtype	CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'SOO';

    g_grpso_add_txn_subtype	CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'GSOO';


/**** Function used to check whether the account message is to be published or not*/
/* This function is no longer used from TBI R12 : ksrikant*/


/*PROCEDURE check_acct_update_publish
(
		 		 itemtype  	IN VARCHAR2,
				 itemkey 	IN VARCHAR2,
				 actid 		IN NUMBER,
				 funcmode 	IN VARCHAR2,
				 resultout 	OUT NOCOPY VARCHAR2
)
AS
	l_transaction_type	        VARCHAR2(15);
	l_transaction_subtype		VARCHAR2(10);
	l_party_id		        NUMBER;
	l_party_site_id		        NUMBER;
	l_party_type		        VARCHAR2(30);
	l_num			        NUMBER ;
	l_event_name			VARCHAR2(50);
	l_doc_no 		        VARCHAR2(30);
BEGIN

    l_transaction_type := g_xnb_transation_type;
 	l_transaction_subtype := g_account_txn_subtype;
	l_party_type := g_party_type;
	l_num := 0;

    l_event_name :=  wf_engine.getitemattrtext (
                        						  itemtype => itemtype,
						                          itemkey  => itemkey,
                        						  aname    => 'ACCT_EVENT_NAME');

   	l_doc_no := wf_engine.getitemattrtext (
                    						  itemtype => itemtype,
					                       	  itemkey  => itemkey,
                    						  aname    => 'ACCOUNT_NUMBER');

     XNB_DEBUG.log('check_acct_update_publish',l_event_name);

	IF l_event_name = 'oracle.apps.xnb.account.update' THEN

		l_num := xnb_util_pvt.check_collaboration_doc_status (l_doc_no, 'XNB_ACCOUNT');

		XNB_DEBUG.log('check_acct_update_publish',l_num);

		IF l_num = 1 THEN
		    resultout := FND_API.G_TRUE;
		END IF;

		IF l_num = 2 THEN
		    resultout := FND_API.G_FALSE;
		END IF;


	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR (-20041, SQLERRM(SQLCODE));
			resultout := 1;

END check_acct_update_publish; */

    --Procedures defined by this packages
PROCEDURE set_item_attributes
(
		 		 itemtype  	IN VARCHAR2,
				 itemkey 	IN VARCHAR2,
				 actid 		IN NUMBER,
				 funcmode 	IN VARCHAR2,
				 resultout 	OUT NOCOPY VARCHAR2
)
AS

	l_transaction_type	        VARCHAR2(15) ;
	l_transaction_subtype	    VARCHAR2(10) ;
	l_party_id		            NUMBER;
	l_party_site_id		        NUMBER;
	l_party_type		         VARCHAR2(30);
	l_message_text		        VARCHAR2(100);
	l_num			    NUMBER ;
	l_doc_no		    NUMBER;
	l_event_key		VARCHAR2(100);
BEGIN

 	l_transaction_type := g_xnb_transation_type;
	l_transaction_subtype := g_item_update_txn_subtype;
	l_party_type := g_party_type;

	l_num := 0;
 ---------------------------------------------------------------------------------------
 --Get the party details
 --
 ---------------------------------------------------------------------------------------
    BEGIN

            SELECT  party_id,
                    party_site_id
            INTO    l_party_id,
                    l_party_site_id
            FROM    ecx_oag_controlarea_tp_v
            WHERE   transaction_type = l_transaction_type
            AND     transaction_subtype = l_transaction_subtype
            AND     party_type = l_party_type;

            EXCEPTION

                WHEN NO_DATA_FOUND THEN
                	RAISE_APPLICATION_ERROR (-20140, 'Party Information is Missing. Please check the Trading Partner Setup in XML Gateway');
	               	resultout := 1;

		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR (-20041, SQLERRM(SQLCODE));
			resultout := 1;
    END;


 ---------------------------------------------------------------------------------------
 --Set all the required attributes
 --
  ---------------------------------------------------------------------------------------

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_TRANSACTION_TYPE',
					l_transaction_type);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_TRANSACTION_SUBTYPE',
					l_transaction_subtype);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_ID',
					l_party_id);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_SITE_ID',
					l_party_site_id);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_TYPE',
					l_party_type);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_SEND_MODE',
					'SYNCH');

	wf_engine.setitemattrnumber (
					itemtype,
					itemkey,
					'ECX_DEBUG_LEVEL',
					1);

l_event_key  := 'XNB'||'_PUBLISH_ITEM_'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');

        wf_engine.setitemattrtext (
						itemtype,
						itemkey,
						'XML_EVENT_KEY',
						l_event_key);

/***** Item Publish Changes incorporated*/
/*					*/
/*					*/

	/* l_doc_no := wf_engine.getitemattrtext (
						  itemtype => itemtype,
						  itemkey  => itemkey,
						  aname    => 'ITEM_ID');


	---------------------------------------------------------------------------------------
	--Check to see if the collaboration already exists for the Item
	--if l_num = 2 Collaboration doesn't exist so Create
	--else Collaboration exists so Update
	---------------------------------------------------------------------------------------

	l_num := xnb_util_pvt.check_collaboration_doc_status (l_doc_no, l_transaction_type, l_transaction_subtype);

	IF l_num = 2 THEN
		resultout := FND_API.G_FALSE;
		RETURN ;
	ELSE

		---------------------------------------------------------------------------------------
		--Update the MESSAGE_TEXT to reflect the Update of Collaboration
		--
		---------------------------------------------------------------------------------------

		l_message_text := l_transaction_type||l_transaction_subtype||l_party_id||l_doc_no||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');

		wf_engine.setitemattrtext (
						itemtype,
						itemkey,
						'MESSAGE_TEXT',
						l_message_text);

		wf_engine.setitemattrdate (
						itemtype,
						itemkey,
						'LAST_UPDATE_DATE',
						sysdate);
		resultout := FND_API.G_TRUE;
		RETURN ;
	END IF; */


	EXCEPTION
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR (-20041, SQLERRM(SQLCODE));
			resultout := 1;


-- Enf of Function
END set_item_attributes;

PROCEDURE set_acct_update_attributes (
				itemtype  	IN VARCHAR2,
		 		itemkey 	IN VARCHAR2,
		 		actid 		IN NUMBER,
		 		funcmode 	IN VARCHAR2,
		 		resultout 	OUT NOCOPY VARCHAR2
		 	     )
AS

	l_transaction_type 	    VARCHAR2(15) ;
	l_transaction_subtype 	VARCHAR2(10) ;
	l_party_id		        NUMBER;
	l_party_site_id 	    NUMBER;
	l_party_type 		    VARCHAR2(30) ;
	l_message_text 		    VARCHAR2(100);
	l_num 			        NUMBER ;
	l_doc_no 		        VARCHAR2(30);
	l_org_id 		        NUMBER;
	l_cust_ac_id			NUMBER;
	l_temp				NUMBER;
	l_event_key		VARCHAR2(100);
	l_event_name		VARCHAR2(50);
	l_ref_id		VARCHAR2(200);
BEGIN

 l_transaction_type := g_xnb_transation_type;
 	l_transaction_subtype := g_account_txn_subtype;
	l_party_type := g_party_type;
	l_num := 0;

 ---------------------------------------------------------------------------------------
 -- Get the Account Number and the Organization Id
 --
  ---------------------------------------------------------------------------------------
	l_doc_no := wf_engine.getitemattrtext (
						  itemtype => itemtype,
						  itemkey  => itemkey,
						  aname    => 'ACCOUNT_NUMBER');

	l_org_id := wf_engine.getitemattrtext (
						  itemtype => itemtype,
						  itemkey  => itemkey,
						  aname    => 'ACCT_ORG_ID');

	---------------------------------------------------------------------------------------
	--Set the Organization Id
	--
	---------------------------------------------------------------------------------------
	/* R12 MOAC UPTAKE :	ksrikant*/

	/*dbms_application_info.set_client_info(l_org_id);*/


/* Functionality Included based on the Bug 3882580*/
 ---------------------------------------------------------------------------------------
 -- Determine whether a primary Bill_to exists for the Account
 --
 ----------------------------------------------------------------------------------------

  BEGIN

	SELECT	cust_account_id
	INTO	l_cust_ac_id
	FROM	hz_cust_accounts
	WHERE   account_number = l_doc_no;

	SELECT	cust_account_id
	INTO	l_temp
	FROM	xnb_primary_bill_to_addr_v
	WHERE	cust_account_id = l_cust_ac_id
	AND	org_id = l_org_id;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR (-20110, 'Primary Bill_To does not exist for the Account Chosen, Assign a Primary Bill_to and Retry');
			resultout := 1;

		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR (-20042, SQLERRM(SQLCODE));
			resultout := 1;
   END;


 ---------------------------------------------------------------------------------------
 --Get the party details
 --
  ---------------------------------------------------------------------------------------
  BEGIN

     SELECT     party_id,
                party_site_id
        INTO    l_party_id,
                l_party_site_id
        FROM    ecx_oag_controlarea_tp_v
        WHERE   transaction_type = l_transaction_type
        AND     transaction_subtype = l_transaction_subtype
        AND     party_type = l_party_type;

   EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR (-20140, 'Party Information is Missing. Please check the Trading Partner Setup in XML Gateway');
		resultout := 1;

		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR (-20043, SQLERRM(SQLCODE));
			resultout := 1;
   END;

---------------------------------------------------------------------------------------
--Set all the required attributes
--
---------------------------------------------------------------------------------------

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_TRANSACTION_TYPE',
					l_transaction_type);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_TRANSACTION_SUBTYPE',
					l_transaction_subtype);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_ID',
					l_party_id);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_SITE_ID',
					l_party_site_id);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_TYPE',
					l_party_type);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_SEND_MODE',
					'SYNCH');

	wf_engine.setitemattrnumber (
					itemtype,
					itemkey,
					'ECX_DEBUG_LEVEL',
					3);

	---------------------------------------------------------------------------------------
	--Set the Reference Id for the Account
	--
	---------------------------------------------------------------------------------------

	    l_event_name := 'oracle.apps.xnb.account.update';
            l_event_key  := 'XNB'||'PUBLISH_ACCOUNT'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
            l_ref_id := 'LM0001:'||l_event_name||':'||l_event_key;

   	    wf_engine.setitemattrtext (
						itemtype,
						itemkey,
						'REFERENCE_ID',
						l_ref_id);

        wf_engine.setitemattrtext (
						itemtype,
						itemkey,
						'XML_EVENT_KEY',
						l_event_key);

	EXCEPTION
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR (-20044, SQLERRM(SQLCODE));
			resultout := 1;

END set_acct_update_attributes;



PROCEDURE set_acct_attributes (
				itemtype  	IN VARCHAR2,
		 		itemkey 	IN VARCHAR2,
		 		actid 		IN NUMBER,
		 		funcmode 	IN VARCHAR2,
		 		resultout 	OUT NOCOPY VARCHAR2
		 	     )
AS

	l_transaction_type 	    VARCHAR2(15) ;
	l_transaction_subtype 	VARCHAR2(10) ;
	l_party_id		        NUMBER;
	l_party_site_id 	    NUMBER;
	l_party_type 		    VARCHAR2(30) ;
	l_message_text 		    VARCHAR2(100);
	l_num 			        NUMBER ;
	l_doc_no 		        VARCHAR2(10);
	l_org_id 		        NUMBER;
	l_cust_ac_id			NUMBER;
	l_temp				NUMBER;
	l_event_key		VARCHAR2(100);
	l_event_name		VARCHAR2(50);
	l_ref_id		VARCHAR2(200);
BEGIN

 l_transaction_type := g_xnb_transation_type;
 	l_transaction_subtype := g_account_txn_subtype;
	l_party_type := g_party_type;
	l_num := 0;

 ---------------------------------------------------------------------------------------
 -- Get the Account Number and the Organization Id
 --
  ---------------------------------------------------------------------------------------
	l_doc_no := wf_engine.getitemattrtext (
						  itemtype => itemtype,
						  itemkey  => itemkey,
						  aname    => 'ACCOUNT_NUMBER');

	l_org_id := wf_engine.getitemattrtext (
						  itemtype => itemtype,
						  itemkey  => itemkey,
						  aname    => 'ACCT_ORG_ID');

	---------------------------------------------------------------------------------------
	--Set the Organization Id
	--
	---------------------------------------------------------------------------------------

	/* R12 MOAC UPTAKE :	ksrikant*/
	/*dbms_application_info.set_client_info(l_org_id);*/


/* Functionality Included based on the Bug 3882580*/
 ---------------------------------------------------------------------------------------
 -- Determine whether a primary Bill_to exists for the Account
 --
 ----------------------------------------------------------------------------------------

  BEGIN

	SELECT	cust_account_id
	INTO	l_cust_ac_id
	FROM	hz_cust_accounts
	WHERE   account_number = l_doc_no;

	SELECT	cust_account_id
	INTO	l_temp
	FROM	xnb_primary_bill_to_addr_v
	WHERE	cust_account_id = l_cust_ac_id
	AND	org_id = l_org_id;

	EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR (-20110, 'Primary Bill_To does not exist for the Account Chosen, Assign a Primary Bill_to and Retry');
		resultout := 1;

		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR (-20046, SQLERRM(SQLCODE));
			resultout := 1;
   END;


 ---------------------------------------------------------------------------------------
 --Get the party details
 --
  ---------------------------------------------------------------------------------------
  BEGIN

     SELECT     party_id,
                party_site_id
        INTO    l_party_id,
                l_party_site_id
        FROM    ecx_oag_controlarea_tp_v
        WHERE   transaction_type = l_transaction_type
        AND     transaction_subtype = l_transaction_subtype
        AND     party_type = l_party_type;

   EXCEPTION
		WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR (-20140, 'Party Information is Missing. Please check the Trading Partner Setup in XML Gateway');
		resultout := 1;

		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR (-20047, SQLERRM(SQLCODE));
			resultout := 1;
   END;

---------------------------------------------------------------------------------------
--Set all the required attributes
--
---------------------------------------------------------------------------------------

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_TRANSACTION_TYPE',
					l_transaction_type);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_TRANSACTION_SUBTYPE',
					l_transaction_subtype);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_ID',
					l_party_id);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_SITE_ID',
					l_party_site_id);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_TYPE',
					l_party_type);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_SEND_MODE',
					'SYNCH');

	wf_engine.setitemattrnumber (
					itemtype,
					itemkey,
					'ECX_DEBUG_LEVEL',
					1);

	---------------------------------------------------------------------------------------
	--Set the Reference Id for the Account
	--
	---------------------------------------------------------------------------------------

	    l_event_name := 'oracle.apps.xnb.account.create';
            l_event_key  := 'XNB'||'PUBLISH_ACCOUNT'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
            l_ref_id := 'LM0001:'||l_event_name||':'||l_event_key;

   	    wf_engine.setitemattrtext (
						itemtype,
						itemkey,
						'REFERENCE_ID',
						l_ref_id);

        wf_engine.setitemattrtext (
						itemtype,
						itemkey,
						'XML_EVENT_KEY',
						l_event_key);



	---------------------------------------------------------------------------------------
	--Check to see if the collaboration already exists for the Account
	--if l_num = 2 Collaboration doesn't exist so Create
	--else Collaboration exists so Update
	---------------------------------------------------------------------------------------

	l_num := xnb_util_pvt.check_collaboration_doc_status (l_doc_no, 'XNB_ACCOUNT');

	IF l_num = 2 THEN
		resultout := FND_API.G_FALSE;
		RETURN ;
	ELSE
		---------------------------------------------------------------------------------------
		--Update the MESSAGE_TEXT to reflect the Update of Collaboration
		--
		---------------------------------------------------------------------------------------

		   l_message_text := l_transaction_type||l_transaction_subtype||l_party_id||l_doc_no||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');

		   wf_engine.setitemattrtext (
						itemtype,
						itemkey,
						'MESSAGE_TEXT',
						l_message_text);

		   wf_engine.setitemattrdate (
						itemtype,
						itemkey,
						'LAST_UPDATE_DATE',
						SYSDATE);
		   resultout := FND_API.G_TRUE;
		   RETURN ;
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR (-20048, SQLERRM(SQLCODE));
			resultout := 1;

--End of Function
END set_acct_attributes;

PROCEDURE set_sales_order_attributes (
					itemtype  	IN VARCHAR2,
		 			itemkey 	IN VARCHAR2,
		 			actid 		IN NUMBER,
		 			funcmode 	IN VARCHAR2,
		 			resultout 	OUT NOCOPY VARCHAR2)
AS

	l_transaction_type 		VARCHAR2(15) ;
	l_transaction_subtype 		VARCHAR2(10) ;
	l_party_id			NUMBER ;
	l_party_site_id 		NUMBER ;
	l_party_type 			VARCHAR2(30) ;
/*	l_message_text 			VARCHAR2(100);	*/
	l_num 			        VARCHAR2(30);
	l_doc_no 		        NUMBER;
	l_order_num 		        NUMBER;
	l_org_id 		        NUMBER;

 /*   INVALID_COLLAB_EXCEPTION EXCEPTION;*/

BEGIN

	l_transaction_type := g_xnb_transation_type;
	l_transaction_subtype := g_salesorder_add_txn_subtype;
	l_party_type := g_party_type;
	l_num := 0;

 ---------------------------------------------------------------------------------------
 --Get the party details
 --
  ---------------------------------------------------------------------------------------
        BEGIN

             SELECT     party_id,
                        party_site_id
             INTO       l_party_id,
                        l_party_site_id
             FROM        ecx_oag_controlarea_tp_v
             WHERE       transaction_type = l_transaction_type
             AND         transaction_subtype = l_transaction_subtype
             AND         party_type = l_party_type;

        EXCEPTION

			WHEN NO_DATA_FOUND THEN
				RAISE_APPLICATION_ERROR (-20080, 'XML GATEWAY TRADING PARTNER SETUP IS INCOMPLETE');
				resultout := 1;


			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR (-20081, SQLERRM(SQLCODE));
				resultout := 1;
		END;

---------------------------------------------------------------------------------------
--Set all the required attributes
--
---------------------------------------------------------------------------------------

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_TRANSACTION_TYPE',
					l_transaction_type);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_TRANSACTION_SUBTYPE',
					l_transaction_subtype);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_ID',
					l_party_id);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_SITE_ID',
					l_party_site_id);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_TYPE',
					l_party_type);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_SEND_MODE',
					'SYNCH');

	wf_engine.setitemattrnumber (
					itemtype,
					itemkey,
					'ECX_DEBUG_LEVEL',
					1);

	l_doc_no := wf_engine.getitemattrtext (
						itemtype => itemtype,
						itemkey  => itemkey,
						aname    => 'SALES_ORDER_ID');

	/*  R12 MOAC UPTAKE :	ksrikant	*/

	/*22-Apr-2006  pselvam   Bug Fix 5166267 - Action Tag Empty
	  Including the below to fetch org_id
	*/

	l_org_id := wf_engine.getitemattrtext (
						itemtype => itemtype,
						itemkey  => itemkey,
						aname    => 'SALE_ORG_ID');

	BEGIN

		SELECT		ohdr.order_number
		INTO		l_order_num
		FROM		oe_order_headers_all ohdr,
			        oe_order_lines_all oline
		WHERE		ohdr.header_id = oline.header_id
		AND		oline.line_id = l_doc_no;

		EXCEPTION

			WHEN NO_DATA_FOUND THEN
				RAISE_APPLICATION_ERROR (-20082, 'Order Number is Missing in while Creating CLN Doc Number');
				resultout := 1;

			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR (-20083, SQLERRM(SQLCODE));
				resultout := 1;
		END;

	---------------------------------------------------------------------------------------
	--Set the Organization Id
	--
	---------------------------------------------------------------------------------------

	/*	 R12 MOAC UPTAKE :	ksrikant	*/
	/*	dbms_application_info.set_client_info(l_org_id);*/
--22-Apr-2006  pselvam   Bug Fix 5166267 - Action Tag Empty
	mo_global.set_policy_context('S',l_org_id);

-- Fix for Bug 3916658

	l_num := l_order_num||':'||l_doc_no;

		wf_engine.setitemattrtext (
				   	                itemtype,
                					itemkey,
				                	'XNB_SALESORDER_NUM',
                					l_num);


	---------------------------------------------------------------------------------------
	--Check to see if the collaboration already exists for the Sales Order
	--if l_num = 2 Collaboration doesn't exist so Create
	--else Collaboration exists so Update
	---------------------------------------------------------------------------------------

/*	l_num := xnb_util_pvt.check_collaboration_doc_status (l_doc_no, l_transaction_type, l_transaction_subtype);

	IF l_num = 2 THEN
		resultout := FND_API.G_FALSE;
		RETURN ;
	ELSE
		---------------------------------------------------------------------------------------
		--Collaboration Already Exists..
		--
		---------------------------------------------------------------------------------------
		resultout := FND_API.G_TRUE;
        RETURN;
	END IF;*/

	EXCEPTION
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR (-20049, SQLERRM(SQLCODE));
			resultout := 1;

 --End of Function
END set_sales_order_attributes;

        ------------------------------------------------------------------------
        --This procedure sets the Workflow attributes required to initialize the
        --XNB IB Ownership change workflow process.
        --This procedure is called from the workflow process.
        --The arguments correspond to the standard workflow function arguments.
        --Returns status through OUT parameter resultout. True on Success, False on error.
        -----------------------------------------------------------------------
    PROCEDURE set_owner_attributes(itemtype  IN VARCHAR2,
		            itemkey IN VARCHAR2,
		            actid IN NUMBER,
		            funcmode IN VARCHAR2,
		            resultout OUT NOCOPY VARCHAR2)
    AS
        l_transaction_type          VARCHAR2(10) ;          --XML GW Internal Txn Type - XNB
        l_transaction_subtype       VARCHAR2(10) ;     --XML GW Internal Txn Subtype - Owner Outbound
        l_party_id                  ecx_oag_controlarea_tp_v.party_id%TYPE;             --Trading Partner ID (from XML Gateway setup)
        l_party_site_id             ecx_oag_controlarea_tp_v.party_site_id%TYPE;        --Trading Partner Site ID (from XML Gateway setup)
        l_party_type                VARCHAR2(30) ;                   --XML Gateway Party Type

    BEGIN

    l_transaction_type := g_xnb_transation_type;
    l_transaction_subtype := g_owner_change_txn_subtype;
	l_party_type := g_party_type;

        --Retrieve the required attributes for the workflow

 ---------------------------------------------------------------------------------------
 --Get the party details
 --
  ---------------------------------------------------------------------------------------
        BEGIN

             SELECT     party_id,
                        party_site_id
             INTO       l_party_id,
                        l_party_site_id
             FROM        ecx_oag_controlarea_tp_v
             WHERE       transaction_type = l_transaction_type
             AND         transaction_subtype = l_transaction_subtype
             AND         party_type = l_party_type;

        EXCEPTION

			WHEN NO_DATA_FOUND THEN
				RAISE_APPLICATION_ERROR (-20080, 'XML GATEWAY TRADING PARTNER SETUP IS INCOMPLETE');
				resultout := 1;


			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR (-20081, SQLERRM(SQLCODE));
				resultout := 1;
		END;

---------------------------------------------------------------------------------------
--Set all the required attributes
--
---------------------------------------------------------------------------------------

                --Set the Workflow attributes
        wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'ECX_TRANSACTION_TYPE',
                l_transaction_type);

        wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'ECX_TRANSACTION_SUBTYPE',
                l_transaction_subtype);

        wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'ECX_PARTY_ID',
                l_party_id);

        wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'ECX_PARTY_SITE_ID',
                l_party_site_id);

        wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'ECX_PARTY_TYPE',
                l_party_type);

        wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'ECX_SEND_MODE',
                'SYNCH');

        --return Workflow lookup value TRUE to indicate success
        resultout := FND_API.G_TRUE;

    EXCEPTION
        WHEN OTHERS THEN
            --return Workflow lookup value FALSE to indicate failure
            resultout := FND_API.G_FALSE;
    --End of Procedure
    END set_owner_attributes;

        -----------------------------------------------------------------------------------------------------------
        --This procedure checks to see if the Inventory Item of the IB instance, whose details are to be published,
        --is Provisionable. The current check involves only checking if the item is non-invoicable. Only non-invoicable
        --items need be sent to the external billing application.
        --Checks Inventory MTL_SYSTEM_ITEMS_B to see if, for the item
        --      INVOICEABLE_ITEM_FLAG = "N" - If TRUE the item is to be invoiced by an external biller.
        --Arguments: Standard workflow function args
        --Returns: resultout.   TRUE if the instance is provisionable (i.e  INVOICEABLE_ITEM_FLAG = "N" )
        --                      FALSE if the instance is not provisionable (i.e  INVOICEABLE_ITEM_FLAG = "N" )
        --Called by the workflow process: XNBFLOWS/OWNER_CHANGE_PROCESS
        --Errors: Are not handled. Would halt the workflow that calls this.
        ------------------------------------------------------------------------------------------------------------
    PROCEDURE check_item_provisionable(
                itemtype  IN VARCHAR2,
		        itemkey IN VARCHAR2,
		        actid IN NUMBER,
		        funcmode IN VARCHAR2,
		        resultout OUT NOCOPY VARCHAR2)
    AS
        l_instance_id       NUMBER;      --IB instance ID retrieved from the WF
        l_invoiceable_flag  VARCHAR2(2);
    BEGIN
        --Retrive the IB Instance ID from the workflow. INSTANCE_ID is NUMBER.
        l_instance_id := to_number(wf_engine.getitemattrtext(
                    itemtype,
                    itemkey,
                    'IB_INSTANCE_ID'));

        --Hit MTL_SYSTEM_ITEMS_B to see if the Item is invoicable
        SELECT  msib.invoiceable_item_flag
        INTO    l_invoiceable_flag
        FROM    mtl_system_items_b msib,
                csi_item_instances cii
        WHERE   cii.instance_id = l_instance_id
        AND     msib.inventory_item_id = cii.inventory_item_id
        AND     msib.organization_id = cii.inv_master_organization_id;

        IF (l_invoiceable_flag = 'N' ) THEN  --Item is non-invoicable(provisionable)
            resultout := FND_API.G_TRUE;
        ELSE  /* N */                 --Item is not Provisionable
            resultout := FND_API.G_FALSE;
        END IF;
    --End of Procedure
    END check_item_provisionable;

        ------------------------------------------------------------------------------------------------------------
        --This procedure checks to see if the IB instance Owner Account, whose details are to be published, has been
        --sent to a billing application.
        --Retrieves the Account Number corresponding to the AccountID, from HZ_CUST_ACCOUNTS.
        --The retrieved Account Number is set as a workflow Attribute. (Required by the next Workflow Activity)
        --Retrieves the Inventory Master Org ID from CSI_ITEM_INSTANCES corresponding to the Instance ID in workflow
        --The retrieved Org ID is set as a worfflow Attribute. (Required by the next Workflow Activity)
        --Checks for a customer account collaboration with document number = ACCOUNT_NUMBER
        --  has been successfully completed with every biller sending atleast one SUCCESS CBOD to the message.
        --Arguments: Standard workflow function args
        --Returns: resultout.   TRUE if the account is published and confirmed SUCCESS by all billers.
        --                      FALSE if the account-publish is not confirmed SUCCESS by all billers.
        --Exceptions: Left unhandled until proper error handling is introduced in the workflow
        --Called by the Workflow Item Type: XNBFLOWS, Process: OWNER_CHANGE_PROCESS
        -----------------------------------------------------------------------------------------------------------
    PROCEDURE check_account_published(itemtype  IN VARCHAR2,
		                              itemkey IN VARCHAR2,
		                              actid IN NUMBER,
		                              funcmode IN VARCHAR2,
		                              resultout OUT NOCOPY VARCHAR2)
    AS

        l_instance_id               csi_item_instances.instance_id%TYPE;
        l_inv_org_id                csi_item_instances.inv_master_organization_id%TYPE;
        l_account_id                csi_item_instances.owner_party_account_id%TYPE;
        l_account_number            hz_cust_accounts.account_number%TYPE;

        l_transaction_type          VARCHAR2(5) ;       --XML GW Internal Txn Type - XNB
        l_transaction_subtype       VARCHAR2(5) ;       --XML GW Internal Txn Subtype - Owner Outbound
        l_party_type                VARCHAR2(30) ;       --XML Gateway Party Type
        l_trading_partner_id        NUMBER;

        l_event_name                VARCHAR2(50);       --for the Account Sub Flow. Event Name
        l_event_key                 VARCHAR2(50);       --for the Account Sub Flow. Event Name
        l_app_ref_id                VARCHAR2(100);      --for the Account Sub Flow. Application Ref ID for CLN update

        l_ret                       NUMBER;

    BEGIN

    l_transaction_type := g_xnb_transation_type;
	l_transaction_subtype := g_account_txn_subtype;
	l_party_type := g_party_type;

        --Retrive the Account ID from the workflow. Account ID is NUMBER
        l_account_id := to_number(
                wf_engine.getitemattrtext(
                    itemtype,
                    itemkey,
                    'IB_OWNER_ACCT_ID_NEW') );

        --Get Account Number from HZ_CUST_ACCOUNTS
        SELECT  account_number
        INTO    l_account_number
        FROM    hz_cust_accounts
        WHERE   cust_account_id = l_account_id;

        --Set the Account Number as a workflow attribute
        wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'IB_OWNER_ACCT_NO_NEW',
                l_account_number);

        --Retrive the Instance ID from the workflow. IB Instance ID is a NUMBER
        l_instance_id := to_number(
                    wf_engine.getitemattrtext(
                        itemtype,
                        itemkey,
                        'IB_INSTANCE_ID') );

        --Get the Inventory Master Organization ID from CSI_ITEM_INSTANCES
        SELECT  inv_master_organization_id
        INTO    l_inv_org_id
        FROM    csi_item_instances
        WHERE   instance_id = l_instance_id;

        --Set the Org ID as a workflow attribute
        wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'IB_INSTANCE_ORG_ID',
                to_char(l_inv_org_id));

        --Call the util procedure and check Collaboration History, if the account is published
        l_ret := xnb_util_pvt.check_collaboration_doc_status (
			to_char(l_instance_id),
			'XNB_OWNER');

        IF (l_ret = 2 OR l_ret = -1) THEN  --If it was not found / or there was an error
            --The workflow will next branch to the account publish process and try to publish an account

            l_event_name    := 'oracle.apps.xnb.account.create';
            l_event_key     := 'XNB_IBCHOWN_ACCTPUB:'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
            l_app_ref_id    := 'XNB_REF:' || l_event_name || l_event_key;

            --Set the workflow attributes for this subflow
            --Event Name

            wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'ACCT_EVENT_NAME',
                l_event_name);

            --Event Key
            wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'ACCT_EVENT_KEY',
                l_event_key);

            --Application Reference ID
            wf_engine.setitemattrtext(
                itemtype,
                itemkey,
                'REFERENCE_ID',
                l_app_ref_id);

            resultout := FND_API.G_FALSE;
        ELSE  /* 0 or 1 */                 --Published success.
            resultout := FND_API.G_TRUE;
        END IF;
    --End of Function
    END check_account_published;


       ---------------------------------------------------------------------------------------------------
        --This procedure checks to see if a collaboration exists for this instance for OWNER CHANGE
        --Calls the util procedure 'validate_document'
        --Arguments: Standard workflow function args.
        --Returns status through result_out: FND_API.G_TRUE if exists, FND_API.G_FALSE if it does not exist.
        ---------------------------------------------------------------------------------------------------
    PROCEDURE check_owner_change_cln(
                itemtype  IN VARCHAR2,
		        itemkey IN VARCHAR2,
		        actid IN NUMBER,
		        funcmode IN VARCHAR2,
		        resultout OUT NOCOPY VARCHAR2)
    AS
        l_transaction_type          VARCHAR2(5) ;           --XML GW Internal Txn Type - XNB
        l_transaction_subtype       VARCHAR2(5) ;           --XML GW Internal Txn Subtype - Owner Outbound
        l_party_type                VARCHAR2(30) ;           --XML Gateway Party Type
        l_trading_partner_id        NUMBER;
        l_document_id               NUMBER;
        l_ret                       NUMBER;
    BEGIN

       	l_transaction_type := g_xnb_transation_type;
       	l_transaction_subtype := g_owner_change_txn_subtype;
	l_party_type := g_party_type;

        --Retrive the instance ID (Collaboration Document ID) from the workflow
        l_document_id := wf_engine.getitemattrtext(
               		itemtype,
                	itemkey,
                	'IB_INSTANCE_ID');

       --Call the util procedure and check Collaboration History
        l_ret :=  xnb_util_pvt.check_collaboration_doc_status (
			l_document_id,
			'XNB_OWNER');


        IF (l_ret = 2 OR l_ret = -1) THEN  --If it was not found / or there was an error
            resultout := FND_API.G_FALSE;
        ELSE  /* 0 or 1 */                 --Published success / Published failure
            resultout := FND_API.G_TRUE;
        END IF;
    --Exceptions left unhandled
    --End of Procedure
    END check_owner_change_cln;



/*** SalesOrder Node which is called whenever a Salesorder is booked */
/* Sales order Node impregnated in Line Flow od SRVDV11i  */

PROCEDURE publish_salesorder_info(itemtype  IN VARCHAR2,
		 itemkey IN VARCHAR2,
		 actid IN NUMBER,
		 funcmode IN VARCHAR2,
		 resultout OUT NOCOPY VARCHAR2)
AS

 l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
 l_key varchar2(200) ;
 l_line_id 	NUMBER;
 l_org_id 	NUMBER;
 l_order_num 	NUMBER;

begin

	l_line_id := to_number(itemkey);

	-------------------------------------------------------------------------------------
	--Retrieve the Order Number
	--
	-------------------------------------------------------------------------------------
	BEGIN

		SELECT		ohdr.order_number
		INTO		l_order_num
		FROM		oe_order_headers_all ohdr,
			        oe_order_lines_all oline
		WHERE		ohdr.header_id = oline.header_id
		AND		oline.line_id = l_line_id;

		EXCEPTION

			WHEN NO_DATA_FOUND THEN
				RAISE_APPLICATION_ERROR (-20084, 'Order Number is Missing. Please check the Database');
				resultout := 1;

			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR (-20085, SQLERRM(SQLCODE));
				resultout := 1;
		END;

	l_key := 'XNB:'||'SALESORDER_LINE : '||l_order_num||':'||l_line_id;

	SELECT org_id into l_org_id from oe_order_lines_all
	WHERE line_id = l_line_id;

	wf_event.AddParameterToList(p_name =>'SALES_ORDER_ID',p_value => l_line_id,p_parameterlist => l_parameter_list);
	wf_event.AddParameterToList(p_name =>'SALE_ORG_ID',p_value => l_org_id,p_parameterlist => l_parameter_list);

	wf_event.raise( p_event_name => 'oracle.apps.xnb.salesorder.create',
				p_event_key => l_key,
				p_parameters => l_parameter_list);


	EXCEPTION

		WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20100,' org_id does not exist for the oRDER NUMBER');

		WHEN OTHERS THEN
		RAISE_APPLICATION_ERROR(-20108, SQLERRM(SQLCODE));

END publish_salesorder_info;


/*** Account Node which is called whenever a Salesorder is booked */
/* Account Node impregnated in Order Header Flow od SRVDV11i  */

PROCEDURE publish_account_info(itemtype  IN VARCHAR2,
		 itemkey IN VARCHAR2,
		 actid IN NUMBER,
		 funcmode IN VARCHAR2,
		 resultout OUT NOCOPY VARCHAR2)
AS

 l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
 l_key 			varchar2(200);
 l_account_number 	VARCHAR2(30);
 l_order_no 		NUMBER;
 l_org_id 		NUMBER;
 l_sold_to_org_id 	NUMBER;

--------------------------------------------------------------------------------
-- Cursor to retrieve all the account numbers associated with the order
--
--------------------------------------------------------------------------------

  CURSOR l_accounts (pl_order_number NUMBER,
			    pl_org_id	NUMBER)
  IS
  SELECT	accounts.account_number
  FROM		xnb_salesorder_accounts_v accounts
  WHERE		accounts.order_number = pl_order_number
  AND		accounts.org_id = pl_org_id;

begin

	--------------------------------------------------------------------------------
	-- Retrieve the ordernumber from the OM Order Header Attribute
	--
	--------------------------------------------------------------------------------

	l_order_no := WF_ENGINE.GETITEMATTRTEXT (ITEMTYPE => ITEMTYPE,
						     ITEMKEY  => ITEMKEY,
						     ANAME    => 'ORDER_NUMBER');

	--------------------------------------------------------------------------------
	-- Retrieve the Organization Id from the ordernumber
	--
	--------------------------------------------------------------------------------

	-- SELECT org_id INTO l_org_id FROM oe_order_headers_all
	-- WHERE order_number = l_order_no;

	--------------------------------------------------------------------------------
	-- Retrieve the organization id from the OM Order Header Attribute
	--
	--------------------------------------------------------------------------------

	l_org_id := WF_ENGINE.GETITEMATTRTEXT (ITEMTYPE => ITEMTYPE,
						     ITEMKEY  => ITEMKEY,
						     ANAME    => 'ORG_ID');

	--------------------------------------------------------------------------------
	-- Iterate the Cursor to publish all the accounts
	--
	--------------------------------------------------------------------------------

	OPEN l_accounts (l_order_no, l_org_id);
	FETCH l_accounts into l_account_number;
	WHILE (l_accounts%FOUND) LOOP

		  l_key := 'XNB:'||'ACCOUNT:'||l_account_number||':'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');

		  wf_event.AddParameterToList(p_name =>'ACCOUNT_NUMBER',p_value => l_account_number,p_parameterlist =>l_parameter_list);
		  wf_event.AddParameterToList(p_name =>'ACCT_ORG_ID',p_value => l_org_id ,p_parameterlist => l_parameter_list);

		  --------------------------------------------------------------------------------
	   	  -- Raise the event to publish the account number with the necessary parameters
	          --
	      	  --------------------------------------------------------------------------------


		  wf_event.raise( p_event_name => 'oracle.apps.xnb.account.create',
						  p_event_key => l_key,
						  p_parameters => l_parameter_list);

		  FETCH l_accounts into l_account_number;
	END LOOP;

	--------------------------------------------------------------------------------
	-- Close the Cursor
	--
	--------------------------------------------------------------------------------
	CLOSE l_accounts;

	EXCEPTION

		WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20100,' Org_id does not exist for the ORDER NUMBER');

		WHEN OTHERS THEN
		CLOSE l_accounts;
		RAISE_APPLICATION_ERROR(-20108, SQLERRM(SQLCODE));

END publish_account_info;

Function check_subscribed_events(
                                            p_subscription_guid  IN RAW,
                                            p_event              IN OUT NOCOPY WF_EVENT_T
                                 )
return VARCHAR2
AS

    l_event_name	      VARCHAR2(50);
    l_subscribed_event xnb_subscribed_events.event_name%TYPE;
    x_result		      VARCHAR2(20);
    l_err_name                VARCHAR2(40);
    l_err_message             VARCHAR2(100);
    l_err_stack               VARCHAR2(1000);

CURSOR l_sub_events IS
SELECT DISTINCT event_name FROM xnb_subscribed_events
WHERE entity_type = 'ACCOUNT_UPDATE';

BEGIN

    XNB_DEBUG.log('XNB_CMN_PVT.CHECK_SUBSCRIBED_EVENTS','Subscription has Triggered');
    l_event_name := p_event.geteventname();
    XNB_DEBUG.log('XNB_CMN_PVT.CHECK_SUBSCRIBED_EVENTS',l_event_name);

    OPEN l_sub_events;
    FETCH l_sub_events INTO l_subscribed_event;

    XNB_DEBUG.log('XNB_CMN_PVT.CHECK_SUBSCRIBED_EVENTS','AFTER FETCH');

    WHILE (l_sub_events%FOUND) LOOP
        XNB_DEBUG.log('XNB_CMN_PVT.CHECK_SUBSCRIBED_EVENTS','INSIDE WHILE');

        IF (l_subscribed_event = l_event_name) THEN
            publish_account_update(l_event_name, p_event);
            x_result := 'SUCCESS';
            CLOSE l_sub_events;
            XNB_DEBUG.log('XNB_CMN_PVT.CHECK_SUBSCRIBED_EVENTS','Successfully CHECKED x_result'||x_result);
            RETURN x_result;
        END IF;

        FETCH l_sub_events INTO l_subscribed_event;
    END LOOP;

    CLOSE l_sub_events;
    x_result := 'SUCCESS';
    XNB_DEBUG.log('XNB_CMN_PVT.CHECK_SUBSCRIBED_EVENTS','After Cursor Close,'||x_result);
    RETURN x_result;

    EXCEPTION

        WHEN OTHERS THEN
            wf_core.GET_ERROR       (err_name           => l_err_name,
                                    err_message        => l_err_message,
                                    err_stack          => l_err_stack,
                                    maxErrStackLength  => 900);
            XNB_DEBUG.log('XNB_CMN_PVT.CHECK_SUBSCRIBED_EVENTS',l_err_name||' : '||l_err_message);
            CLOSE l_sub_events;
            x_result := 'ERROR';
            RETURN x_result;

END check_subscribed_events;

PROCEDURE publish_account_update(l_event_name IN VARCHAR2,
                                p_event              IN OUT NOCOPY WF_EVENT_T)
AS

    l_param_value 		VARCHAR2(60);
    l_rel_cust_acct_id 		VARCHAR2(60);
    l_pri_bill_to_site_id 	VARCHAR2(60);
    l_account_number 		VARCHAR2(30);
    l_org_id 			NUMBER;
    l_site_use_code 		VARCHAR2(50);
    l_site_use_id 		VARCHAR2(50);
    l_num			NUMBER;
    l_flag 			CHAR;
    l_err_name                VARCHAR2(40);
    l_err_message             VARCHAR2(100);
    l_err_stack               VARCHAR2(1000);
    l_table_name	      VARCHAR2(30);

/* 30-May-2006  pselvam   ST1 Bug Fix 5254717 - Acct Update Org Id issue */
    l_user_id                 NUMBER;
    l_resp_id                 NUMBER;
    l_resp_appl_id            NUMBER;

TYPE AccountNumTyp IS TABLE OF HZ_CUST_ACCOUNTS.ACCOUNT_NUMBER%TYPE
INDEX BY BINARY_INTEGER;

l_acc_num AccountNumTyp;

BEGIN

/*30-May-2006  pselvam   ST1 Bug Fix 5254717 - Acct Update Org Id issue*/
--fnd_profile.GET( 'ORG_ID', l_org_id );

  l_user_id := p_event.GetValueForParameter('USER_ID');
  l_resp_id := p_event.GetValueForParameter('RESP_ID');
  l_resp_appl_id := p_event.GetValueForParameter('RESP_APPL_ID');

  FND_GLOBAL.apps_initialize(l_user_id, l_resp_id, l_resp_appl_id);

  MO_GLOBAL.init('AR');

  l_org_id := MO_UTILS.get_default_org_id;

/* R12 MOAC UPTAKE :	ksrikant*/
/*dbms_application_info.set_client_info(l_org_id);*/

IF l_event_name = 'oracle.apps.ar.hz.CustAccount.update' THEN

    l_param_value := p_event.GetValueForParameter('CUST_ACCOUNT_ID');
    XNB_DEBUG.log('Event_subscription',l_param_value);

	BEGIN


		SELECT  ACCOUNT_NUMBER
		INTO    l_account_number
		FROM    HZ_CUST_ACCOUNTS
		WHERE   CUST_ACCOUNT_ID = l_param_value;

		XNB_DEBUG.log('oracle.apps.ar.hz.CustAccount.update',l_account_number);

		EXCEPTION

		    WHEN NO_DATA_FOUND THEN
			WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
			WF_EVENT.setErrorInfo(p_event, 'ERROR');
			XNB_DEBUG.log('XNB_CMN_PVT_TEMP.PUBLISH_ACCT_UPDATE','ACCOUNT_NUMBER IS NULL FOR CustAccount.update');
			RAISE;
	END;

	l_num := xnb_util_pvt.check_collaboration_doc_status (l_account_number, 'XNB_ACCOUNT');

	IF l_num = 1 THEN
		raise_acctupdate_event(l_account_number, l_org_id, l_event_name, l_param_value);
	END IF;
/*C547_XNB - Obsolete Billing Preference information*/
/*
ELSIF l_event_name = 'oracle.apps.ar.hz.BillingPreference.create' OR l_event_name = 'oracle.apps.ar.hz.BillingPreference.update' THEN

    l_param_value := p_event.GetValueForParameter('BILLING_PREFERENCES_ID');
    XNB_DEBUG.log('Event_subscription',l_param_value);

    BEGIN

        SELECT      account_number
        INTO        l_account_number
        FROM        hz_billing_preferences bill_pref,
                    hz_cust_accounts acc
        WHERE       bill_pref.cust_account_id = acc.cust_account_id
        AND         bill_pref.billing_preferences_id = l_param_value;

        XNB_DEBUG.log('oracle.apps.ar.hz.BillingPreference',l_account_number);

        EXCEPTION

            WHEN NO_DATA_FOUND THEN
                WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
                WF_EVENT.setErrorInfo(p_event, 'ERROR');
                XNB_DEBUG.log('XNB_CMN_PVT_TEMP.PUBLISH_ACCT_UPDATE','ACCOUNT_NUMBER IS NULL FOR BillingPreference');
                RAISE;
    END;

    l_num := xnb_util_pvt.check_collaboration_doc_status (l_account_number, 'XNB_ACCOUNT');

	IF l_num = 1 THEN
		raise_acctupdate_event(l_account_number, l_org_id, l_event_name, l_param_value);
	END IF;
*/
ELSIF l_event_name = 'oracle.apps.ar.hz.CustAcctRelate.create' OR l_event_name = 'oracle.apps.ar.hz.CustAcctRelate.update' THEN

    l_param_value := p_event.GetValueForParameter('CUST_ACCOUNT_ID');
    l_rel_cust_acct_id := p_event.GetValueForParameter('RELATED_CUST_ACCOUNT_ID');
    XNB_DEBUG.log('Event_subscription',l_param_value);

    BEGIN

        SELECT              distinct ACCT.ACCOUNT_NUMBER
        INTO                l_account_number
        FROM                HZ_CUST_ACCOUNTS        ACCT,
                            HZ_CUST_ACCT_RELATE_ALL ACCT_REL
        WHERE               ACCT.CUST_ACCOUNT_ID = l_param_value
        AND                 ACCT.CUST_ACCOUNT_ID = ACCT_REL.CUST_ACCOUNT_ID;

    XNB_DEBUG.log('oracle.apps.ar.hz.CustAcctRelate','Account Number'||l_account_number);
    XNB_DEBUG.log('oracle.apps.ar.hz.CustAcctRelate','Related Cust Account Id '||l_rel_cust_acct_id);

	l_param_value := l_rel_cust_acct_id;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN
                WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
                WF_EVENT.setErrorInfo(p_event, 'ERROR');
                XNB_DEBUG.log('XNB_CMN_PVT_TEMP.PUBLISH_ACCT_UPDATE','ACCOUNT_NUMBER IS NULL FOR CustAcctRelate');
                RAISE;
    END;

        l_num := xnb_util_pvt.check_collaboration_doc_status (l_account_number, 'XNB_ACCOUNT');

	IF l_num = 1 THEN
		raise_acctupdate_event(l_account_number, l_org_id, l_event_name, l_param_value);
        END IF;


ELSIF l_event_name = 'oracle.apps.ar.hz.CustAcctSiteUse.create' OR l_event_name = 'oracle.apps.ar.hz.CustAcctSiteUse.update' THEN
    l_param_value := p_event.GetValueForParameter('SITE_USE_ID');
    XNB_DEBUG.log('Event_subscription',l_param_value);

    BEGIN

	/* R12 MOAC UPTAKE :	ksrikant*/

        SELECT 	 	   site_use_code,
			   primary_flag
        INTO		   l_site_use_code,
                           l_flag
        FROM 		   hz_cust_site_uses_all
        WHERE 		   site_use_id = l_param_value;

        EXCEPTION

            WHEN NO_DATA_FOUND THEN
            WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
                WF_EVENT.setErrorInfo(p_event, 'ERROR');
                XNB_DEBUG.log('XNB_CMN_PVT_TEMP.PUBLISH_ACCT_UPDATE','ACCOUNT_NUMBER IS NULL FOR CustAcctSiteUse');
                RAISE;
    END;

        IF l_event_name = 'oracle.apps.ar.hz.CustAcctSiteUse.create' THEN

		XNB_DEBUG.log('Event_subscription','Inside If oracle.apps.ar.hz.CustAcctSiteUse.create');

                IF  l_site_use_code = 'BILL_TO' AND l_flag = 'Y' THEN


                BEGIN

		/* R12 MOAC UPTAKE :	ksrikant*/

                    SELECT 	 	   b.account_number
 	            INTO		   l_account_number
                    FROM		   hz_cust_site_uses_all p,
                    			   hz_cust_acct_sites_all a,
            	          		   hz_cust_accounts b
                    WHERE		   p.site_use_id = l_param_value
                    AND 		   a.cust_acct_site_id = p.cust_acct_site_id
                    AND  		   a.cust_account_id = b.cust_account_id;

                    XNB_DEBUG.log('oracle.apps.ar.hz.CustAcctSiteUse.create',l_account_number);

                    EXCEPTION

                    WHEN NO_DATA_FOUND THEN
                        WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
                        WF_EVENT.setErrorInfo(p_event, 'ERROR');
                        XNB_DEBUG.log('XNB_CMN_PVT_TEMP.PUBLISH_ACCT_UPDATE','ACCOUNT_NUMBER IS NULL FOR CustAcctSiteUse.create');
                        RAISE;
                     END;

		     l_num := xnb_util_pvt.check_collaboration_doc_status (l_account_number, 'XNB_ACCOUNT');

			IF l_num = 1 THEN
				raise_acctupdate_event(l_account_number, l_org_id, l_event_name, l_param_value);
		        END IF;

		END IF;

        ELSIF l_event_name = 'oracle.apps.ar.hz.CustAcctSiteUse.update' THEN

            IF  l_site_use_code = 'BILL_TO' THEN

                BEGIN

			/* R12 MOAC UPTAKE :	ksrikant*/

                    SELECT 	 	   b.account_number
 	            INTO		   l_account_number
                    FROM		   hz_cust_site_uses_all p,
                    			   hz_cust_acct_sites_all a,
            	          		   hz_cust_accounts b
                    WHERE		   p.site_use_id = l_param_value
                    AND 		   a.cust_acct_site_id = p.cust_acct_site_id
                    AND  		   a.cust_account_id = b.cust_account_id;

                    XNB_DEBUG.log('oracle.apps.ar.hz.CustAcctSiteUse.update',l_account_number);

                    EXCEPTION

                    WHEN NO_DATA_FOUND THEN
                        WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
                        WF_EVENT.setErrorInfo(p_event, 'ERROR');
                        XNB_DEBUG.log('XNB_CMN_PVT_TEMP.PUBLISH_ACCT_UPDATE','ACCOUNT_NUMBER IS NULL FOR CustAcctSiteUse.update');
                        RAISE;
                END;

		l_num := xnb_util_pvt.check_collaboration_doc_status (l_account_number, 'XNB_ACCOUNT');

		IF l_num = 1 THEN
			raise_acctupdate_event(l_account_number, l_org_id, l_event_name, l_param_value);
	        END IF;

            END IF; -- END l_site_use_code = 'BILL_TO'

          END IF;  -- l_event_name = 'oracle.apps.ar.hz.CustAcctSiteUse.create'

ELSIF l_event_name = 'oracle.apps.ar.hz.CustProfileAmt.create' OR l_event_name = 'oracle.apps.ar.hz.CustProfileAmt.update' THEN

    l_param_value := p_event.GetValueForParameter('CUST_ACCT_PROFILE_AMT_ID');
    XNB_DEBUG.log('Event_subscription',l_param_value);

    BEGIN

--ST1 BUG Fix 5221801 - Cust Profile and Profile Amts
        SELECT      account_number,
	            pfl.site_use_id
        INTO        l_account_number,
	            l_site_use_id
        FROM        HZ_CUST_PROFILE_AMTS pfl_amnts,
	            HZ_CUSTOMER_PROFILES pfl,
                    hz_cust_accounts acc
        WHERE       pfl_amnts.cust_account_id = acc.cust_account_id
	AND         pfl.cust_account_profile_id = pfl_amnts.cust_account_profile_id
	AND         pfl_amnts.CUST_ACCT_PROFILE_AMT_ID = l_param_value;

		XNB_DEBUG.log('oracle.apps.ar.hz.CustProfileAmt',l_account_number);

        EXCEPTION

            WHEN NO_DATA_FOUND THEN
                WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
                WF_EVENT.setErrorInfo(p_event, 'ERROR');
                XNB_DEBUG.log('XNB_CMN_PVT_TEMP.PUBLISH_ACCT_UPDATE','ACCOUNT_NUMBER IS NULL FOR CustProfileAmt');
                RAISE;
    END;

    IF l_site_use_id IS NULL THEN--ST1 BUG Fix 5221801 - Cust Profile and Profile Amts
	    l_num := xnb_util_pvt.check_collaboration_doc_status (l_account_number, 'XNB_ACCOUNT');
	    XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','Check the collaboration FOR CustProfileAmt_'||l_num);

		IF l_num = 1 THEN
			raise_acctupdate_event(l_account_number, l_org_id, l_event_name, l_param_value);
			XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','After Raising the Account Publish Event FOR CustProfileAmt');
		END IF;
    END IF;

/* R12 Introduction of 4 new events : ksrikant*/
ELSIF l_event_name = 'oracle.apps.ar.hz.Person.update' OR l_event_name = 'oracle.apps.ar.hz.Organization.update' THEN

	l_param_value := p_event.GetValueForParameter('PARTY_ID');
	XNB_DEBUG.log('Event_subscription',l_param_value);

	BEGIN

		SELECT			account_number
		BULK COLLECT INTO	l_acc_num
		FROM			hz_cust_accounts
		WHERE			party_id = l_param_value;


		EXCEPTION

		WHEN NO_DATA_FOUND THEN
			WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
	                WF_EVENT.setErrorInfo(p_event, 'ERROR');
	                XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCT_UPDATE','ACCOUNT_NUMBER IS NULL FOR Party Update');
		        RAISE;

		WHEN OTHERS THEN
			XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCT_UPDATE', SQLERRM);

	END;

	XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','Before FOR Loop of Party');

	FOR i IN 1..l_acc_num.COUNT LOOP

		XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','Inside FOR Loop of Party');
		l_num := xnb_util_pvt.check_collaboration_doc_status (l_acc_num(i), 'XNB_ACCOUNT');
		    XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','Check the collaboration FOR Party_'||l_acc_num(i)||'_'||l_num);

		IF l_num = 1 THEN
			raise_acctupdate_event(l_acc_num(i), l_org_id, l_event_name, l_param_value);
			XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','After Raising the Account Publish Event FOR Party Account Num_'||l_acc_num(i));
	        END IF;

	END LOOP;

ELSIF l_event_name = 'oracle.apps.ar.hz.CustomerProfile.update' THEN

	l_param_value := p_event.GetValueForParameter('CUST_ACCOUNT_PROFILE_ID');
	XNB_DEBUG.log('Event_subscription',l_param_value);

	BEGIN
--ST1 BUG Fix 5221801 - Cust Profile and Profile Amts
		SELECT 	 b.account_number,
		         a.site_use_id
		INTO   	 l_account_number,
		         l_site_use_id
		FROM 	 hz_customer_profiles a,
		 	 hz_cust_accounts b
		WHERE 	 a.cust_account_profile_id = l_param_value
		AND 	 a.cust_account_id = b.cust_account_id;

		XNB_DEBUG.log('oracle.apps.ar.hz.CustomerProfile',l_account_number);

		EXCEPTION

		WHEN NO_DATA_FOUND THEN
			WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
	                WF_EVENT.setErrorInfo(p_event, 'ERROR');
	                XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCT_UPDATE','Check the Cust_Account_Id for the Updated Customer Profile');
		        RAISE;

		WHEN OTHERS THEN
			XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCT_UPDATE', SQLERRM);

	END;

        IF l_site_use_id IS NULL THEN--ST1 BUG Fix 5221801 - Cust Profile and Profile Amts
		l_num := xnb_util_pvt.check_collaboration_doc_status (l_account_number, 'XNB_ACCOUNT');
		XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','Check the collaboration FOR Credit CustomerProfile_'||l_num);

		IF l_num = 1 THEN
			raise_acctupdate_event(l_account_number, l_org_id, l_event_name, l_param_value);
			XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','After Raising the Account Publish Event FOR Credit CustomerProfile');
		END IF;
        END IF;

ELSIF l_event_name = 'oracle.apps.ar.hz.ContactPoint.update' THEN

	l_param_value := p_event.GetValueForParameter('CONTACT_POINT_ID');
	XNB_DEBUG.log('Event_subscription',l_param_value);

	BEGIN

		SELECT 	 owner_table_name
		INTO   	 l_table_name
		FROM 	 hz_contact_points
		WHERE	 contact_point_id = l_param_value;

		EXCEPTION

		WHEN NO_DATA_FOUND THEN
			WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
	                WF_EVENT.setErrorInfo(p_event, 'ERROR');
	                XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCT_UPDATE','Check the Owner Table Name in HZ_CONTACT_POINTS');
		        RAISE;

		WHEN OTHERS THEN
			XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCT_UPDATE', SQLERRM);

	END;

	IF l_table_name = 'HZ_PARTIES' THEN

	XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCT_UPDATE', 'Inside IF l_table_name = hz_parties');

	      BEGIN

			SELECT 			c.account_number
			BULK COLLECT INTO	l_acc_num
			FROM 			hz_contact_points a,
						hz_parties b,
						hz_cust_accounts c
			WHERE 			a.contact_point_id = l_param_value
			AND 			a.owner_table_id = b.party_id
			AND 			b.party_id = c.party_id;

		    EXCEPTION

			WHEN NO_DATA_FOUND THEN
				WF_CORE.CONTEXT('XNB_CMN_PVT_TEMP', 'PUBLISH_ACCT_UPDATE', p_event.getEventName());
				WF_EVENT.setErrorInfo(p_event, 'ERROR');
				XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCT_UPDATE','ACCOUNT_NUMBER IS NULL FOR Contact Point Update');
				RAISE;

			WHEN OTHERS THEN
				XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCT_UPDATE', SQLERRM);

		END;

			XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','Before FOR Loop of Contact Point Update');

		FOR i IN 1..l_acc_num.COUNT LOOP

			XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','Inside FOR Loop of Contact Point Update');

			l_num := xnb_util_pvt.check_collaboration_doc_status (l_acc_num(i), 'XNB_ACCOUNT');
			    XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','Check the collaboration FOR Contact Point_'||l_acc_num(i)||'_'||l_num);

			IF l_num = 1 THEN
				raise_acctupdate_event(l_acc_num(i), l_org_id, l_event_name, l_param_value);
				XNB_DEBUG.log('XNB_CMN_PVT.PUBLISH_ACCOUNT_UPDATE','After Raising the Account Publish Event FOR Contact Point_'||l_acc_num(i));
			END IF;

		END LOOP;

	END IF; /* l_table_name = 'HZ_PARTIES'  */

END IF;  /* If l_event_name = EVENT_NAME */

END publish_account_update;




PROCEDURE raise_acctupdate_event(
					p_account_number IN VARCHAR2,
					p_org_id	 IN NUMBER,
					p_event_name	 IN VARCHAR2,
					p_param_value	 IN VARCHAR2)
AS

	    l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
	    l_key 		      VARCHAR2(200);
	    l_err_name                VARCHAR2(40);
	    l_err_message             VARCHAR2(100);
	    l_err_stack               VARCHAR2(1000);
BEGIN

	------------------------------------------------------------------------------------
	--Generate the Key, set the required parameters and
	--raise the business event to publish the account update message
	--
	------------------------------------------------------------------------------------

	l_key := 'XNB:'||'ACCOUNT:'||p_account_number||':'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');

	wf_event.AddParameterToList(    p_name =>'ACCOUNT_NUMBER',
					p_value => p_account_number,
					p_parameterlist => l_parameter_list);

	XNB_DEBUG.log('XNB_CMN_PVT_TEMP.PUBLISH_ACCT_UPDATE','Org_id before Raising Event'||p_org_id);

	wf_event.AddParameterToList(   p_name =>'ACCT_ORG_ID',
					p_value => p_org_id,
					p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList(   p_name =>'PARAMETER3',
					p_value => p_event_name,
					p_parameterlist => l_parameter_list);

	wf_event.AddParameterToList(   p_name =>'ECX_PARAMETER4',
					p_value => p_param_value,
					p_parameterlist => l_parameter_list);

	wf_event.raise(	p_event_name => 'oracle.apps.xnb.account.update',
			p_event_key => l_key,
			p_parameters => l_parameter_list);


EXCEPTION

    WHEN OTHERS THEN
          wf_core.GET_ERROR(        err_name           => l_err_name,
                                    err_message        => l_err_message,
                                    err_stack          => l_err_stack,
                                    maxErrStackLength  => 900);
          XNB_DEBUG.log('XNB_CMN_PVT_TEMP.RAISE_ACCTUPDATE_EVENT',l_err_name||' : '||l_err_message);
                RAISE;

END RAISE_ACCTUPDATE_EVENT;


PROCEDURE set_grpsales_order_attributes (
					itemtype  	IN VARCHAR2,
		 			itemkey 	IN VARCHAR2,
		 			actid 		IN NUMBER,
		 			funcmode 	IN VARCHAR2,
		 			resultout 	OUT NOCOPY VARCHAR2)
AS

	l_transaction_type 		VARCHAR2(15) ;
	l_transaction_subtype 		VARCHAR2(10) ;
	l_party_id			NUMBER ;
	l_party_site_id 		NUMBER ;
	l_party_type 			VARCHAR2(30) ;
	l_event_key			VARCHAR2(100);
	l_org_id 		        NUMBER;

BEGIN

	l_transaction_type := g_xnb_transation_type;
	l_transaction_subtype := g_grpso_add_txn_subtype;
	l_party_type := g_party_type;

	l_event_key  := 'XNB'||'PUBLISH_GSO'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');


	---------------------------------------------------------------------------------------
	--Get the party details
	--
	---------------------------------------------------------------------------------------
        BEGIN

             SELECT     party_id,
                        party_site_id
             INTO       l_party_id,
                        l_party_site_id
             FROM        ecx_oag_controlarea_tp_v
             WHERE       transaction_type = l_transaction_type
             AND         transaction_subtype = l_transaction_subtype
             AND         party_type = l_party_type;

        EXCEPTION

			WHEN NO_DATA_FOUND THEN
				RAISE_APPLICATION_ERROR (-20080, 'XML GATEWAY TRADING PARTNER SETUP IS INCOMPLETE');
				resultout := 1;


			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR (-20081, SQLERRM(SQLCODE));
				resultout := 1;
		END;

	---------------------------------------------------------------------------------------
	--	Set all the required attributes
	--
	---------------------------------------------------------------------------------------

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_TRANSACTION_TYPE',
					l_transaction_type);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_TRANSACTION_SUBTYPE',
					l_transaction_subtype);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_ID',
					l_party_id);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_SITE_ID',
					l_party_site_id);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_PARTY_TYPE',
					l_party_type);

	wf_engine.setitemattrtext (
					itemtype,
					itemkey,
					'ECX_SEND_MODE',
					'SYNCH');

	wf_engine.setitemattrnumber (
					itemtype,
					itemkey,
					'ECX_DEBUG_LEVEL',
					1);

        wf_engine.setitemattrtext (
						itemtype,
						itemkey,
						'XML_EVENT_KEY',
						l_event_key);

--22-Apr-2006  pselvam   Bug Fix 5166267 - Action Tag Empty
	l_org_id := wf_engine.getitemattrtext (
						itemtype => itemtype,
						itemkey  => itemkey,
						aname    => 'SALE_ORG_ID');

	mo_global.set_policy_context('S',l_org_id);


 --End of Function
END set_grpsales_order_attributes;

/*** Procedure to publish the Grouped Salesorder Message */

PROCEDURE publish_grpsalesorder_info(	 itemtype	IN VARCHAR2,
					 itemkey	IN VARCHAR2,
					 actid		IN NUMBER,
					 funcmode	IN VARCHAR2,
					 resultout	OUT NOCOPY VARCHAR2)
AS

 l_parameter_list wf_parameter_list_t := wf_parameter_list_t();
 l_key 			VARCHAR2(200);
 l_order_number 	NUMBER;
 l_org_id		NUMBER;
 l_num			NUMBER;


BEGIN
	l_num := 0;
	--------------------------------------------------------------------------------
	-- Retrieve the ordernumber from the OM Order Header Attribute
	--
	--------------------------------------------------------------------------------

	l_order_number := WF_ENGINE.GETITEMATTRTEXT (    ITEMTYPE => ITEMTYPE,
							 ITEMKEY  => ITEMKEY,
							 ANAME    => 'ORDER_NUMBER');

	BEGIN

		SELECT		count(line.line_id)
		INTO		l_num
		FROM		oe_order_headers_all  head,
				oe_order_lines_all    line,
				mtl_system_items_vl   item
		WHERE		head.order_number = l_order_number
		AND   		head.header_id = line.header_id
		AND		line.inventory_item_id = item.inventory_item_id
		AND		item.organization_id  =   line.ship_from_org_id
	        AND		item.invoiceable_item_flag = 'N';

		EXCEPTION

			WHEN OTHERS THEN
				RAISE_APPLICATION_ERROR (-20011, SQLERRM(SQLCODE));
				resultout := 1;

	END;

	IF l_num = 0 THEN
		resultout := 0;
		RETURN;
	ELSE
/*
		BEGIN

			SELECT		org_id
			INTO		l_org_id
			FROM		oe_order_headers_all
			WHERE		order_number = l_order_number;

			EXCEPTION

				WHEN NO_DATA_FOUND THEN
					RAISE_APPLICATION_ERROR (-20080, 'ORG_ID is missing in ORDER Headers Table');
					resultout := 1;


				WHEN OTHERS THEN
					RAISE_APPLICATION_ERROR (-20081, SQLERRM(SQLCODE));
					resultout := 1;

		END;
*/

		--------------------------------------------------------------------------------
		-- Retrieve the orgnization id from the OM Order Header Attribute
		--
		--------------------------------------------------------------------------------

		l_org_id := WF_ENGINE.GETITEMATTRTEXT (    ITEMTYPE => ITEMTYPE,
								 ITEMKEY  => ITEMKEY,
								 ANAME    => 'ORG_ID');


		l_key := 'XNB:'||'GRPSALESORDER:'||l_order_number;
		wf_event.AddParameterToList(p_name =>'ORDER_NUMBER', p_value => l_order_number, p_parameterlist =>l_parameter_list);
		wf_event.AddParameterToList(p_name =>'SALE_ORG_ID',p_value => l_org_id,p_parameterlist => l_parameter_list);

		--------------------------------------------------------------------------------
		-- Raise the event to publish the grouped salesorder with the necessary parameters
		--
		--------------------------------------------------------------------------------

		wf_event.raise( p_event_name => 'oracle.apps.xnb.groupedsalesorder.create',
				p_event_key => l_key,
				p_parameters => l_parameter_list);
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			RAISE_APPLICATION_ERROR(-20108, SQLERRM(SQLCODE));

END publish_grpsalesorder_info;


--End of Package
END XNB_CMN_PVT;

/
