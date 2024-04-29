--------------------------------------------------------
--  DDL for Package Body XNB_SALES_ORDER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."XNB_SALES_ORDER_PVT" AS
/* $Header: XNBVPSOB.pls 120.4 2005/10/17 06:42:02 ksrikant noship $ */

g_xnb_transation_type       CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'XNB';
g_salesorder_add_txn_subtype    CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'SOO';
g_party_type    CONSTANT CHAR(1) NOT NULL DEFAULT 'C';
g_account_txn_subtype    CONSTANT VARCHAR2(5) NOT NULL DEFAULT 'AO';


/**** Private API to check whether the SalesOrder Line to be published has
/*    an noninvoiceable item or not */

   PROCEDURE check_noninvoiceable_item
   (
		itemtype  IN VARCHAR2,
		itemkey   IN VARCHAR2,
		actid 	  IN NUMBER,
		funcmode  IN VARCHAR2,
		resultout OUT NOCOPY VARCHAR2)
    AS

		l_so_org_id	NUMBER;
		l_so_line_id    NUMBER;
		l_flag		CHAR;

    BEGIN
	---------------------------------------------------------------------------------------
	--Set the Organization Id
	--
	---------------------------------------------------------------------------------------

	l_so_org_id := wf_engine.getitemattrtext (
						itemtype => itemtype,
						itemkey  => itemkey,
						aname    => 'SALE_ORG_ID');


	/* R12 MOAC UPTAKE :	ksrikant*/
	/*	dbms_application_info.set_client_info(l_so_org_id);	*/

	---------------------------------------------------------------------------------------
	--Get the Line Id
	--
	---------------------------------------------------------------------------------------

	l_so_line_id := wf_engine.getitemattrtext (
						 itemtype => itemtype,
	                     			 itemkey  => itemkey,
						 aname    => 'SALES_ORDER_ID');
	---------------------------------------------------------------------------------------
	--Get the Invoiceable Item Flag of the Item associated with Line Id.
	--
	---------------------------------------------------------------------------------------

	BEGIN

		SELECT			invoiceable_item_flag
		INTO			l_flag
		FROM			mtl_system_items_b
		WHERE			organization_id = l_so_org_id and inventory_item_id = (select inventory_item_id from oe_order_lines_all where line_id = l_so_line_id);

		EXCEPTION

			WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20043,'Invoiveable Item Flag has Wrong Value, Please Recheck the DATA');
	END;

	---------------------------------------------------------------------------------------
	--Check the Invoiceable Item Flag of the Item associated with Line Id.
	-- If  invoiceable_item_flag := 'N' then PUBLISH
	-- Elsif  invoiceable_item_flag := 'Y' then END
	---------------------------------------------------------------------------------------


	IF l_flag = 'N' THEN
	resultout := FND_API.G_FALSE;
	ELSIF l_flag = 'Y' THEN
	resultout := FND_API.G_TRUE;
	ELSE
	resultout := -1;
	END IF;

--End of Function
END check_noninvoiceable_item;

    /*****Private API to check whether the account of the sales order line	*/
    /*  is already publishes							*/
    /*										*/

    PROCEDURE check_account
    (
	    itemtype			IN VARCHAR2,
	    itemkey			    IN VARCHAR2,
	    actid			    IN NUMBER,
	    funcmode			IN VARCHAR2,
	    resultout			OUT NOCOPY VARCHAR2)
    AS

	    l_so_org_id	        NUMBER;
	    l_so_doc_id	        NUMBER;
	    l_cust_acct_id	NUMBER;
	    l_acct_num	        VARCHAR2(10);
	    l_party_id	        NUMBER;
	    l_num               NUMBER;
	    l_event_key         VARCHAR2(100);
	    l_event_name        VARCHAR2(50);
	    l_ref_id            VARCHAR2(200);


	l_transaction_type	    VARCHAR2(15) ;
	l_transaction_subtype	    VARCHAR2(10) ;
	l_party_type		    VARCHAR2(30);
	l_flag			    VARCHAR2(10);
	l_cnt			    NUMBER;
	l_cnt_t			    NUMBER;
	---------------------------------------------------------------------------------------
	--Cursor to retrieve the Billing Applications
	--Cursor is specific to the Profile value = 'ONERROR' for Profile : XNB_ACCT_REPUB_AT_LINE
	---------------------------------------------------------------------------------------


	cursor l_tp_codes is
	SELECT	SOURCE_TP_LOCATION_CODE
	FROM	ECX_TP_DETAILS_V
	WHERE	TRANSACTION_TYPE = 'XNB' AND TRANSACTION_SUBTYPE = 'CBODI';

	l_tp_code ecx_tp_details.source_tp_location_code%TYPE;

    BEGIN

	l_transaction_type := g_xnb_transation_type;
	l_transaction_subtype :=g_account_txn_subtype;
	l_party_type := g_party_type;
	l_cnt := 0;
	l_cnt_t := 0;

	    ---------------------------------------------------------------------------------------
	    --Set the Organization Id
	    --
	    ---------------------------------------------------------------------------------------

	    l_so_org_id := wf_engine.getitemattrtext (
						itemtype => itemtype,
						itemkey  => itemkey,
						aname    => 'SALE_ORG_ID');


         /* R12 MOAC UPTAKE :	ksrikant*/
	 /*   dbms_application_info.set_client_info(l_so_org_id);	*/


	    l_so_doc_id := wf_engine.getitemattrtext (
						 itemtype => itemtype,
	                     			 itemkey  => itemkey,
						 aname    => 'SALES_ORDER_ID');

	    ---------------------------------------------------------------------------------------
	    --Get the Customer Account Id of the Order Line
	    --
	    ---------------------------------------------------------------------------------------
	    BEGIN

		    SELECT		sold_to_org_id
		    INTO		l_cust_acct_id
		    FROM		oe_order_lines_all
		    WHERE		line_id = l_so_doc_id;

		EXCEPTION

		WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20067,'Customer Account Id does not exist, check the DataBase');

	     END;
	    ---------------------------------------------------------------------------------------
	    --Get the Customer Account Number for the Account Id
	    --
	    ---------------------------------------------------------------------------------------
	    BEGIN

	    SELECT		account_number
	    INTO		l_acct_num
	    FROM		hz_cust_accounts
	    WHERE		cust_account_id = l_cust_acct_id;

		EXCEPTION

		WHEN NO_DATA_FOUND THEN
		RAISE_APPLICATION_ERROR(-20068,'AccountNumber  does not exist for the Sold to Org Id, check the DataBase');

	     END;


	    ---------------------------------------------------------------------------------------
	    --Check profile value XNB_ACCT_REPUB_AT_LINE to determine whether to publish
	    --the account information
	    ---------------------------------------------------------------------------------------

	    fnd_profile.get('XNB_ACCT_REPUB_AT_LINE',l_flag);

	    IF (l_flag = 'NEVER' OR l_flag IS NULL)	THEN

		SELECT		count(collaboration_id)
		INTO		l_cnt
		FROM		cln_coll_hist_hdr
		WHERE		document_no = l_acct_num;

		IF (l_cnt > 0 ) THEN
		    resultout := FND_API.G_TRUE;
		    RETURN ;
		END IF;
	    END IF;

	    ---------------------------------------------------------------------------------------
	    --Check to see if the account has already been published
	    --
	    ---------------------------------------------------------------------------------------

	    l_num := xnb_util_pvt.check_collaboration_doc_status (l_acct_num, 'XNB_ACCOUNT');

	    ---------------------------------------------------------------------------------------
	    --'ONERROR' publsihes the account if there is no success and an failure in the
	    --collaboration. It does not publsih if there is no reply from the billing application.
	    ---------------------------------------------------------------------------------------



	    IF (l_flag = 'ON_ERROR') THEN

			open l_tp_codes;
			fetch l_tp_codes into l_tp_code ;

			while (l_tp_codes%FOUND) LOOP

				select		COUNT(clndtl.collaboration_dtl_id)
				into            l_cnt
				from		cln_coll_hist_hdr clnhdr,
						cln_coll_hist_dtl clndtl
				where
						clnhdr.application_id  = '881'
						and  clnhdr.collaboration_type = 'XNB_ACCOUNT'
						and clnhdr.document_no = l_acct_num
						and clnhdr.collaboration_id = clndtl.collaboration_id
						and clndtl.collaboration_document_type = 'CONFIRM_BOD'
						and clndtl.originator_reference = l_tp_code
						and clndtl.document_status = 'SUCCESS';

				IF ( l_cnt = 0) THEN

					select		COUNT(clndtl.collaboration_dtl_id)
					into            l_cnt_t
					from		cln_coll_hist_hdr clnhdr,
							cln_coll_hist_dtl clndtl
					where
							clnhdr.application_id  = '881'
	       					and  clnhdr.collaboration_type = 'XNB_ACCOUNT'
    						and clnhdr.document_no = l_acct_num
							and clnhdr.collaboration_id = clndtl.collaboration_id
							and clndtl.collaboration_document_type = 'CONFIRM_BOD'
							and clndtl.originator_reference = l_tp_code
							and clndtl.document_status = 'ERROR';

					IF l_cnt_t > 0 THEN

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
												'ACCOUNT_NUMBER',
												l_acct_num);

						 wf_engine.setitemattrtext (
												itemtype,
												itemkey,
												'ACCT_ORG_ID',
												l_so_org_id);

						 wf_engine.setitemattrtext (
												itemtype,
												itemkey,
												'ACCT_EVENT_NAME',
												l_event_name);

						 wf_engine.setitemattrtext (
												itemtype,
												itemkey,
												'ACCT_EVENT_KEY',
												l_event_key);

						resultout := FND_API.G_FALSE;
						RETURN;
					END IF;
				END IF;

			 fetch l_tp_codes into l_tp_code;
		         END LOOP;
		resultout := FND_API.G_TRUE;
		RETURN;
	      END IF;




	    ---------------------------------------------------------------------------------------
	    --If Colloboration doesn't exist then publish the account information
	    --Else Continue flow
	    ---------------------------------------------------------------------------------------

	    IF l_num = 2 THEN

            l_event_name := 'oracle.apps.xnb.account.create';
            l_event_key  := 'XNB'||'PUBLISH_ACCOUNT :'||l_acct_num||':'||to_char(SYSDATE,'DD-Mon-YYYY HH24:MI:SS');
            l_ref_id := 'LM0001:'||l_event_name||':'||l_event_key;

   	    wf_engine.setitemattrtext (
							itemtype,
							itemkey,
							'REFERENCE_ID',
							l_ref_id);

	    wf_engine.setitemattrtext (
							itemtype,
							itemkey,
							'ACCOUNT_NUMBER',
							l_acct_num);

            wf_engine.setitemattrtext (
							itemtype,
							itemkey,
							'ACCT_ORG_ID',
							l_so_org_id);

            wf_engine.setitemattrtext (
							itemtype,
							itemkey,
							'ACCT_EVENT_NAME',
							l_event_name);

            wf_engine.setitemattrtext (
							itemtype,
							itemkey,
							'ACCT_EVENT_KEY',
							l_event_key);

		    resultout := FND_API.G_FALSE;
		    RETURN ;
	    ELSE
		    resultout := FND_API.G_TRUE;
		    RETURN ;
	    END IF;

	EXCEPTION

		WHEN OTHERS THEN
			 RAISE_APPLICATION_ERROR(-20034, SQLERRM(SQLCODE));

    --End of Function
    END check_account;

    /***** Private API to construct the Data to be published			        */
    /* Inserts the publishing related data into the table xnb_bill_to_party_details	*/


    PROCEDURE publish_bill_to_address(	itemtype  	IN VARCHAR2,
		 			itemkey 	IN VARCHAR2,
		 			actid 		IN NUMBER,
		 			funcmode	IN VARCHAR2,
					resultout 	OUT NOCOPY VARCHAR2)
    AS
	    l_inv_to_org_id 	    NUMBER;
	    l_sold_to_org_id 	    NUMBER;
	    l_pri_bill_to_site_id 	NUMBER;
	    l_site_ids 		        NUMBER;
	    l_bill_to_owner_flag 	CHAR;
	    l_primary_bill_to_flag 	CHAR;
	    l_party_number		VARCHAR2(30);
	    l_party_name	  	    VARCHAR2(240);
    	    l_account_number		VARCHAR2(30);
	    l_account_name	  	    VARCHAR2(240);
	    l_bill_to_address	    VARCHAR2(500);
	    l_country		        VARCHAR2(60);
	    l_state		            VARCHAR2(60);
	    l_county	            VARCHAR2(60);
	    l_city		 	        VARCHAR2(60);
	    l_postal_code	 	    VARCHAR2(60);
	    x_result 		        NUMBER;
	    l_doc_id 		        NUMBER;
	    l_org_id        	    NUMBER;
	    l_party_id			NUMBER;
	    l_account_id		NUMBER;

	    ----------------------------------------------------------------------------------
	    --Cursor to retrieve all the BILL_TO addresses associated with Customer Account Id
	    --of ORDER LINE
	    ----------------------------------------------------------------------------------

	    CURSOR l_sites (pl_sold_to_org_id NUMBER,
			    pl_org_id	NUMBER)
	    IS
	        SELECT		DISTINCT	t1.site_use_id
	        FROM
					hz_cust_site_uses_all t1,
					hz_cust_acct_sites_all t2
	        WHERE		t1.cust_acct_site_id = t2.cust_acct_site_id
	        AND		t2.cust_account_id = pl_sold_to_org_id
		AND		t1.org_id = pl_org_id
	        AND		t1.site_use_code = 'BILL_TO';

        BEGIN

		l_bill_to_owner_flag := 'N';
		l_primary_bill_to_flag := 'N';
	        ------------------------------------------------------------------------------
	        --Set the Organization Id
	        --
	        ------------------------------------------------------------------------------




		l_org_id := wf_engine.getitemattrtext (
							itemtype => itemtype,
							itemkey  => itemkey,
							aname    => 'SALE_ORG_ID');


	       	/* R12 MOAC UPTAKE :	ksrikant*/
	        /*dbms_application_info.set_client_info(l_org_id);*/


	        l_doc_id := wf_engine.getitemattrtext (
							 itemtype => itemtype,
							 itemkey  => itemkey,
							 aname    => 'SALES_ORDER_ID');

	        -----------------------------------------------------------------------------
	        --Get the Customer Account Site Id and Customer Account Id of the Order Line
	        --
	        -----------------------------------------------------------------------------

		BEGIN

			SELECT		invoice_to_org_id,
					sold_to_org_id
			INTO		l_inv_to_org_id,
					l_sold_to_org_id
			FROM		oe_order_lines_all
			WHERE		line_id = l_doc_id;   --DOCUMENT_ID

			EXCEPTION

			WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20069,'INVOICE_TO_ORG_ID OR SOLD_TO_ORG_ID IS MISSING');
			resultout := 1;
		END;

	    ----------------------------------------------------------------------------------
	    --Retrieve the Primary BILL_TO address associated with Customer Account Id
	    --of ORDER LINE
	    ----------------------------------------------------------------------------------

	    BEGIN

		    SELECT		t1.site_use_id
		    INTO 		l_pri_bill_to_site_id
		    FROM		hz_cust_site_uses_all t1,
					hz_cust_acct_sites_all t2
		    WHERE		t1.site_use_code = 'BILL_TO'
		    AND 		t1.primary_flag = 'Y'
		    AND 		t1.status = 'A'
		    AND			t1.org_id = l_org_id
		    AND 		t1.cust_acct_site_id = t2.cust_acct_site_id
		    AND 		t2.cust_account_id =  l_sold_to_org_id;




		EXCEPTION

		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20070,'Primary Bill_to Address does not exist, Add the primary Bill_to Address and Retry');
			resultout := 1;

	     END;

	    OPEN l_sites (l_sold_to_org_id, l_org_id);
	    FETCH l_sites INTO l_site_ids;
	    WHILE (l_sites%FOUND) LOOP



		    -------------------------------------------------------------------------------------------
		    --Check to see if Cust Account Site Id Belongs to the Customer Account Id for which
		    --the order is billed
		    -- If Yes set BILL_TO_OWNER_FLAG  =  'Y'
		    -- Else   set BILL_TO_OWNER_FLAG  =  'N'
		    -------------------------------------------------------------------------------------------

		    IF(l_site_ids = l_inv_to_org_id) THEN
			    l_bill_to_owner_flag := 'Y';
		        --  it belongs to the L_SOLD_TO_ORG_ID
		        --  Check for Primary Bill To of  L_SOLD_TO_ORG_ID

		        -------------------------------------------------------------------------------------------
		        --Check to see if Cust Account Site Id is the Primary BILL_TO of the
		        --Customer Account Id for which the order is billed
		        -- If Yes set PRIMARY_BILL_TO_FLAG  =  'Y'
		        -- Else   set PRIMARY_BILL_TO_FLAG  =  'N'
		        -------------------------------------------------------------------------------------------

			        IF(l_site_ids = l_pri_bill_to_site_id) THEN
				        l_primary_bill_to_flag := 'Y';



				        ---------------------------------------------------------------------------
				        --Get the Details of PRIMARY BILL_TO Address
				        --
				        ---------------------------------------------------------------------------

				        get_bill_to_address  (	l_inv_to_org_id,
							l_party_id,
							l_account_id,
							l_party_number,
							l_party_name,
							l_account_number,
							l_account_name,
							l_bill_to_address,
							l_country,
							l_state,
							l_county,
							l_city,
							l_postal_code,
							x_result);

				        ----------------------------------------------------------------------------
				        --Store the complete address details and flags into xnb_bill_to_party_details
				        --
				        ----------------------------------------------------------------------------

				        create_sales_order  ( 	l_doc_id,
							l_party_id,
							l_account_id,
							l_party_number,
							l_party_name,
							l_account_number,
							l_account_name,
							l_bill_to_address,
							l_country,
							l_state,
							l_county,
							l_city,
							l_postal_code,
							l_primary_bill_to_flag,
							l_bill_to_owner_flag,
							x_result);

				        --CLOSE CURSOR  AND RETURN
				        CLOSE l_sites;
				        RETURN;

			        ELSE
				        l_primary_bill_to_flag := 'N';

				        ---------------------------------------------------------------------------
				        --Get the Details of BILL_TO Address Speicied for the Order Line
				        --
				        ---------------------------------------------------------------------------

				        get_bill_to_address  (	l_inv_to_org_id,
								l_party_id,
								l_account_id,
								l_party_number,
								l_party_name,
								l_account_number,
								l_account_name,
								l_bill_to_address,
								l_country,
								l_state,
								l_county,
								l_city,
								l_postal_code,
								x_result);

				        ---------------------------------------------------------------------------
				        --Store the complete address details and flags into xnb_bill_to_party_details
				        --
				        ---------------------------------------------------------------------------

				        create_sales_order  ( 	l_doc_id,
								l_party_id,
								l_account_id,
								l_party_number,
								l_party_name,
								l_account_number,
								l_account_name,
								l_bill_to_address,
								l_country,
								l_state,
								l_county,
								l_city,
								l_postal_code,
								l_primary_bill_to_flag,
								l_bill_to_owner_flag,
								x_result);

			            --CLOSE CURSOR  AND RETURN
			            CLOSE l_sites;
			            RETURN;
			        -- End of If Primary Bill_to
			        END IF;

		        --Enf of if it belongs to the L_SOLD_TO_ORG_ID
		        END IF;

		    FETCH l_sites INTO l_site_ids;
	    -- End of While
	    END LOOP;

	    l_bill_to_owner_flag := 'N';

	    --CLOSE CURSOR  AND RETURN
            CLOSE l_sites;

	    -------------------------------------------------------------------------------------------
	    --Cust Account Site Id does not Belong to the Customer Account Id
	    --PUBLISH THE BILL TO SPECIFIED IN THE ORDER LINE ** INVOICE_TO_ORG_ID
	    --RELATIONSHIP EXISTS HERE
	    -------------------------------------------------------------------------------------------

	    get_bill_to_address  (	l_inv_to_org_id,
					l_party_id,
					l_account_id,
   					l_party_number,
					l_party_name,
					l_account_number,
					l_account_name,
   					l_bill_to_address,
   					l_country,
		   			l_state,
					l_county,
					l_city,
					l_postal_code,
					x_result);

	    create_sales_order  ( 	l_doc_id,
					l_party_id,
					l_account_id,
					l_party_number,
					l_party_name,
					l_account_number,
					l_account_name,
					l_bill_to_address,
					l_country,
					l_state,
					l_county,
					l_city,
					l_postal_code,
					l_primary_bill_to_flag,
					l_bill_to_owner_flag,
					x_result);

   	    RETURN;

	EXCEPTION


		WHEN OTHERS THEN
			 RAISE_APPLICATION_ERROR(-20034, SQLERRM(SQLCODE));
    --End of Function
    END PUBLISH_BILL_TO_ADDRESS;


    /***** Private API to return the Bill To Address for a given Cust Account Site Id	*/
    /*											*/
    /*											*/

    PROCEDURE get_bill_to_address
    (
	    l_inv_to_org_id 	IN 	NUMBER ,
	    l_party_id		OUT	NOCOPY NUMBER,
	    l_account_id	OUT	NOCOPY NUMBER,
	    l_party_number	OUT	NOCOPY VARCHAR2,
	    l_party_name	OUT	NOCOPY VARCHAR2,
	    l_account_number	OUT	NOCOPY VARCHAR2,
	    l_account_name	OUT	NOCOPY VARCHAR2,
	    l_bill_to_address	OUT	NOCOPY VARCHAR2,
	    l_country		OUT	NOCOPY VARCHAR2,
	    l_state		OUT	NOCOPY VARCHAR2,
	    l_county		OUT	NOCOPY VARCHAR2,
	    l_city		OUT	NOCOPY VARCHAR2,
	    l_postal_code	OUT	NOCOPY VARCHAR2,
	    x_result 		OUT	NOCOPY NUMBER
    )
    AS

    BEGIN

	    -------------------------------------------------------------------------------------------
	    --Query to extract the Bill to Address for a given Cust Account Site Id
	    --
	    -------------------------------------------------------------------------------------------

	    SELECT 	    c.party_id,
			    c.party_number,
			    c.party_name,
			    b.cust_account_id,
			    b.account_number,
			    b.account_name,
			    locations.address1||DECODE(locations.address2
			    , NULL
			    , NULL
			    , ';'||locations.address2|| DECODE(locations.address3
			    , NULL
			    , NULL
			    , ';'||locations.address3|| DECODE(locations.address4
			    , NULL
			    , NULL
			    , ';'||locations.address4))) bill_to_address,
			    locations.country,
          		    locations.state,
			    locations.county,
		            locations.city,
		            locations.postal_code
	    INTO
		    l_party_id,
		    l_party_number,
		    l_party_name,
		    l_account_id,
		    l_account_number,
		    l_account_name,
		    l_bill_to_address,
		    l_country,
		    l_state,
		    l_county,
		    l_city,
		    l_postal_code
	    FROM
		    hz_cust_site_uses_all p,
		    hz_cust_acct_sites_all a,
		    hz_cust_accounts b,
		    hz_parties c,
		    hz_party_sites d,
		    hz_locations locations
	    WHERE
		    p.site_use_id = l_inv_to_org_id
		    and a.cust_acct_site_id = p.cust_acct_site_id
		    and  a.cust_account_id = b.cust_account_id
		    and  b.party_id = c.party_id
		    and a.party_site_id = d.party_site_id
		    and d.location_id = locations.location_id;

	    EXCEPTION

	    	WHEN NO_DATA_FOUND  THEN
	    	X_RESULT := 0;
    --End of Function
    END get_bill_to_address;

    /***** Private API to insert the sales Order Data to be published into the table	*/
    /*     xnb_bill_to_party_details								*/
    /*											*/


    PROCEDURE create_sales_order
    (
	l_doc_id			IN 	NUMBER,
        l_party_id			IN	NUMBER,
        l_account_id			IN	NUMBER,
	l_party_number			IN	VARCHAR2,
    	l_party_name			IN 	VARCHAR2,
	l_account_number		IN	VARCHAR2,
	l_account_name			IN 	VARCHAR2,
    	l_bill_to_address		IN 	VARCHAR2,
    	l_country			IN 	VARCHAR2,
    	l_state				IN 	VARCHAR2,
    	l_county	 		IN 	VARCHAR2,
    	l_city		 		IN 	VARCHAR2,
    	l_postal_code			IN 	VARCHAR2,
    	l_primary_bill_to_flag		IN 	CHAR,
    	l_bill_to_owner_flag		IN 	CHAR,
    	x_result			OUT	NOCOPY NUMBER
    )
    AS

    	l_sql VARCHAR2(5000);

    BEGIN
	    -------------------------------------------------------------------------------------------
	    --Insert the records to XNB_BILL_TO_PARTY_DETAILS
	    --
	    -------------------------------------------------------------------------------------------

	    l_sql := 'INSERT INTO xnb_bill_to_party_details'||
		'(PARTY_ATTRIBUTE1, '||
		'PARTY_ATTRIBUTE2, '||
		'PARTY_ATTRIBUTE3, '||
		'PARTY_ATTRIBUTE4, '||
		'PARTY_ATTRIBUTE5, '||
		'PARTY_ATTRIBUTE6, '||
		'PARTY_ATTRIBUTE7, '||
		'PARTY_ATTRIBUTE8, '||
		'PARTY_ATTRIBUTE9, '||
		'PARTY_ATTRIBUTE10, '||
		'PARTY_ATTRIBUTE11, '||
		'PARTY_ATTRIBUTE12, '||
		'PARTY_ATTRIBUTE13, '||
		'PARTY_ATTRIBUTE14, '||
		'PARTY_ATTRIBUTE15, '||
		'ACCT_ATTRIBUTE1, '||
		'ACCT_ATTRIBUTE2, '||
		'ACCT_ATTRIBUTE3, '||
		'ACCT_ATTRIBUTE4, '||
		'ACCT_ATTRIBUTE5, '||
		'ACCT_ATTRIBUTE6, '||
		'ACCT_ATTRIBUTE7, '||
		'ACCT_ATTRIBUTE8, '||
		'ACCT_ATTRIBUTE9, '||
		'ACCT_ATTRIBUTE10, '||
		'ACCT_ATTRIBUTE11, '||
		'ACCT_ATTRIBUTE12, '||
		'ACCT_ATTRIBUTE13, '||
		'ACCT_ATTRIBUTE14, '||
		'ACCT_ATTRIBUTE15, '||
		'ORDER_LINE_ID, '||
		'PARTY_NUMBER, '||
		'PARTY_NAME, '||
		'ACCOUNT_NUMBER, '||
		'ACCOUNT_NAME, '||
		'PRIMARY_BILL_TO_FLAG, '||
		'BILL_TO_OWNER_FLAG, '||
		'BILL_TO_ADDRESS, '||
		'COUNTRY, '||
		'STATE, '||
		'COUNTY, '||
		'CITY, '||
		'POSTAL_CODE) '||
		'(SELECT '||
		'A.ATTRIBUTE1, '||
		'A.ATTRIBUTE2, '||
		'A.ATTRIBUTE3, '||
		'A.ATTRIBUTE4, '||
		'A.ATTRIBUTE5, '||
		'A.ATTRIBUTE6, '||
		'A.ATTRIBUTE7, '||
		'A.ATTRIBUTE8, '||
		'A.ATTRIBUTE9, '||
		'A.ATTRIBUTE10, '||
		'A.ATTRIBUTE11, '||
		'A.ATTRIBUTE12, '||
		'A.ATTRIBUTE13, '||
		'A.ATTRIBUTE14, '||
		'A.ATTRIBUTE15, '||
		'B.ATTRIBUTE1, '||
		'B.ATTRIBUTE2, '||
		'B.ATTRIBUTE3, '||
		'B.ATTRIBUTE4, '||
		'B.ATTRIBUTE5, '||
		'B.ATTRIBUTE6, '||
		'B.ATTRIBUTE7, '||
		'B.ATTRIBUTE8, '||
		'B.ATTRIBUTE9, '||
		'B.ATTRIBUTE10, '||
		'B.ATTRIBUTE11, '||
		'B.ATTRIBUTE12, '||
		'B.ATTRIBUTE13, '||
		'B.ATTRIBUTE14, '||
		'B.ATTRIBUTE15, '''||l_doc_id||''','''||l_party_number||''','''||l_party_name||''','''||l_account_number||''','''||
		l_account_name||''','''||l_primary_bill_to_flag||''','''||l_bill_to_owner_flag||''','''||l_bill_to_address||''','''||
		l_country||''','''||l_state||''','''||l_county||''','''||l_city||''','''||l_postal_code||''''||
		' FROM HZ_PARTIES A, HZ_CUST_ACCOUNTS B '||
		' WHERE A.PARTY_ID = B.PARTY_ID AND A.PARTY_ID = '||l_party_id||' AND B.CUST_ACCOUNT_ID = '||l_account_id||')';

    	    -------------------------------------------------------------------------------------------
	    --Execute the Query
	    --
	    -------------------------------------------------------------------------------------------

	    EXECUTE IMMEDIATE l_sql;
	    COMMIT;

	EXCEPTION

		WHEN OTHERS THEN
			X_RESULT := 0;

    --End of Function
    END create_sales_order;

    /***** Private API to remove the published data from the xnb_bill_to_party_details	*/
    /*											*/
    /*											*/

    PROCEDURE truncate_sales_order (
					itemtype  	IN VARCHAR2,
		 			itemkey 	IN VARCHAR2,
		 			actid 		IN 	NUMBER,
		 			funcmode 	IN VARCHAR2,
					resultout 	OUT NOCOPY VARCHAR2
				)
    AS

	    l_doc_id NUMBER;

    begin

	    l_doc_id := wf_engine.getitemattrtext (
					    itemtype => itemtype,
	                    itemkey  => itemkey,
                        aname    => 'SALES_ORDER_ID');

	    ------------------------------------------------------------------------------
	    --Query to Delete the Published details
	    --
	    ------------------------------------------------------------------------------

	    DELETE FROM xnb_bill_to_party_details
	    WHERE order_line_id = l_doc_id;

	    COMMIT;

    --End of Function
    END truncate_sales_order;


    procedure return_install_at_addr(
                            p_instance_id     in number,
                            p_address_line    out nocopy varchar2,
                            p_city            out nocopy varchar2,
                            p_country         out nocopy varchar2,
                            p_county          out nocopy varchar2,
                            p_postal_code     out nocopy varchar2,
                            p_state           out nocopy varchar2)
as
                            l_loc_type_code   varchar2(30);
                            l_install_loc_id  NUMBER;
                            l_loc_id          NUMBER;
begin

                begin

                    select      install_location_type_code
                    into        l_loc_type_code
                    from        csi_item_instances
                    where       instance_id = p_instance_id;


                    exception

                        WHEN NO_DATA_FOUND THEN
                        return;

                 end;

                 IF l_loc_type_code = 'HZ_PARTY_SITES' THEN

                     BEGIN

                            SELECT      install_location_id
                            into        l_install_loc_id
                            from        csi_item_instances
                            where       instance_id = p_instance_id;

                            exception

                                WHEN NO_DATA_FOUND THEN
                                return;

                     END;

                     BEGIN

                            SELECT      location_id
                            into        l_loc_id
                            from        hz_party_sites
                            where       party_site_id = l_install_loc_id;

                            exception

                                WHEN NO_DATA_FOUND THEN
                                RAISE_APPLICATION_ERROR(-20023,'Address does not exist for InstallBase Party Site Id, Please Recheck the DATA');

                     END;

                     BEGIN

                            SELECT      ADDRESS1||DECODE(ADDRESS2
                                        , NULL
                                        , NULL
                                        , ';'||ADDRESS2|| DECODE(ADDRESS3
                                        , NULL
                                        , NULL
                                        , ';'||ADDRESS3|| DECODE(ADDRESS4
                                        , NULL
                                        , NULL
                                        , ';'||ADDRESS4))),
                                        city,
                                        country,
                                        county,
                                        postal_code,
                                        state
                            INTO        p_address_line,
                                        p_city,
                                        p_country,
                                        p_county,
                                        p_postal_code,
                                        p_state
                            FROM        hz_locations
                            WHERE       location_id = l_loc_id;

                            exception

                                WHEN NO_DATA_FOUND THEN
                                RAISE_APPLICATION_ERROR(-20033,'Address does not exist in HZ_LOCATIONS(HZ_PARTY_SITES), Please Recheck the DATA');

                     END;

                 END IF;

                 IF l_loc_type_code = 'HZ_LOCATIONS' THEN

                     BEGIN

                            SELECT      install_location_id
                            into        l_install_loc_id
                            from        csi_item_instances
                            where       instance_id = p_instance_id;

                            exception

                                WHEN NO_DATA_FOUND THEN
                                return;

                     END;

                     BEGIN

                            SELECT      ADDRESS1||DECODE(ADDRESS2
                                        , NULL
                                        , NULL
                                        , ';'||ADDRESS2|| DECODE(ADDRESS3
                                        , NULL
                                        , NULL
                                        , ';'||ADDRESS3|| DECODE(ADDRESS4
                                        , NULL
                                        , NULL
                                        , ';'||ADDRESS4))),
                                        city,
                                        country,
                                        county,
                                        postal_code,
                                        state
                            INTO        p_address_line,
                                        p_city,
                                        p_country,
                                        p_county,
                                        p_postal_code,
                                        p_state
                            FROM        hz_locations
                            WHERE       location_id = l_install_loc_id;

                            EXCEPTION

                                WHEN NO_DATA_FOUND THEN
                                RAISE_APPLICATION_ERROR(-20043,'Address does not exist in HZ_LOCATIONS, Please Recheck the DATA');

                     END;

                END IF;

                EXCEPTION

                     WHEN OTHERS THEN
                     RAISE_APPLICATION_ERROR(-20053,'Exception while returning Install At Address : '||SQLERRM(SQLCODE));

END return_install_at_addr;


/*** Procedure to return the Ship To address of the order */

procedure return_ship_to_address(
			    p_ship_to_org_id     in number,
                            p_address_line    out nocopy varchar2,
                            p_city            out nocopy varchar2,
                            p_country         out nocopy varchar2,
                            p_county          out nocopy varchar2,
                            p_postal_code     out nocopy varchar2,
                            p_state           out nocopy varchar2)
AS
BEGIN

		SELECT 	    locations.address1||DECODE(locations.address2
			    , NULL
			    , NULL
			    , ';'||locations.address2|| DECODE(locations.address3
			    , NULL
			    , NULL
			    , ';'||locations.address3|| DECODE(locations.address4
			    , NULL
			    , NULL
			    , ';'||locations.address4))) bill_to_address,
			    locations.country,
          		    locations.state,
			    locations.county,
		            locations.city,
		            locations.postal_code
	    INTO
		    p_address_line,
		    p_country,
		    p_state,
		    p_county,
		    p_city,
		    p_postal_code
	    FROM
		    hz_cust_site_uses_all p,
		    hz_cust_acct_sites_all a,
		    hz_cust_accounts b,
		    hz_parties c,
		    hz_party_sites d,
		    hz_locations locations
	    WHERE
		    p.site_use_id = p_ship_to_org_id
		    and a.cust_acct_site_id = p.cust_acct_site_id
		    and  a.cust_account_id = b.cust_account_id
		    and  b.party_id = c.party_id
		    and a.party_site_id = d.party_site_id
		    and d.location_id = locations.location_id;

	 EXCEPTION
                    WHEN OTHERS THEN
                    RAISE_APPLICATION_ERROR(-20043,'Address does not exist in HZ_LOCATIONS, Please Recheck the DATA');

END return_ship_to_address;


PROCEDURE publish_line_bill_to_address(		itemtype  IN VARCHAR2,
		 				itemkey   IN VARCHAR2,
		 				actid 	  IN NUMBER,
		 				funcmode  IN VARCHAR2,
						resultout OUT NOCOPY VARCHAR2)

    AS
	    l_inv_to_org_id 		NUMBER;
	    l_sold_to_org_id 		NUMBER;
	    l_pri_bill_to_site_id 	NUMBER;
	    l_site_ids 		        NUMBER;
	    l_bill_to_owner_flag 	CHAR;
	    l_primary_bill_to_flag 	CHAR;
	    l_party_number		VARCHAR2(30);
	    l_party_name	  	VARCHAR2(240);
    	    l_account_number		VARCHAR2(30);
	    l_account_name	  	VARCHAR2(240);
	    l_bill_to_address		VARCHAR2(500);
	    l_country		        VARCHAR2(60);
	    l_state		        VARCHAR2(60);
	    l_county			VARCHAR2(60);
	    l_city		 	VARCHAR2(60);
	    l_postal_code	 	VARCHAR2(60);
	    x_result 		        NUMBER;
	    l_order_number	        NUMBER;
	    l_line_id			NUMBER;
	    l_org_id        		NUMBER;
	    l_party_id			NUMBER;
	    l_account_id		NUMBER;
	    l_flag			CHAR;

	    ----------------------------------------------------------------------------------
	    --Cursor to retrieve all the BILL_TO addresses associated with Customer Account Id
	    --of ORDER LINE
	    ----------------------------------------------------------------------------------

	    CURSOR l_sites (pl_sold_to_org_id NUMBER,
			    pl_org_id	NUMBER)
	    IS
	        SELECT		DISTINCT	t1.site_use_id
	        FROM
					hz_cust_site_uses_all t1,
					hz_cust_acct_sites_all t2
	        WHERE		t1.cust_acct_site_id = t2.cust_acct_site_id
	        AND		t2.cust_account_id = pl_sold_to_org_id
		AND		t1.org_id = pl_org_id
	        AND		t1.site_use_code = 'BILL_TO';

	    ----------------------------------------------------------------------------------
	    --Cursor to retrieve all the LINE_IDs associated with ORDER NUMBER
	    --
	    ----------------------------------------------------------------------------------

		CURSOR l_line_ids (p_order_num NUMBER)
		IS
		SELECT		line.line_id
		FROM		oe_order_headers_all  head,
				oe_order_lines_all    line,
				mtl_system_items_vl   item
		WHERE		head.order_number = p_order_num
	        AND		head.header_id = line.header_id
		AND		line.inventory_item_id = item.inventory_item_id
		AND		item.organization_id  =   line.ship_from_org_id
	        AND		item.invoiceable_item_flag = 'N';

        BEGIN

XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','Just After Begin');

	l_order_number := wf_engine.getitemattrtext (
						    itemtype => itemtype,
				                    itemkey  => itemkey,
				                    aname    => 'ORDER_NUMBER');

	l_org_id := wf_engine.getitemattrtext (
							itemtype => itemtype,
							itemkey  => itemkey,
							aname    => 'SALE_ORG_ID');

    ----------------------------------------------------------------------------------
	--Open the Cursor to retrieve all the LINE_IDs associated with ORDER NUMBER
	--
	----------------------------------------------------------------------------------
--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','Before Opening the cursor for Line_ids');



	OPEN l_line_ids (l_order_number);
	    FETCH l_line_ids INTO l_line_id;

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','Fetching line_id_'||l_line_id);

	    WHILE (l_line_ids%FOUND) LOOP

		l_bill_to_owner_flag := 'N';
		l_primary_bill_to_flag := 'N';
		l_flag := 'N';

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','In While loop for line_id_'||l_line_id);


    		-----------------------------------------------------------------------------
	        --Get the Customer Account Site Id and Customer Account Id of the Order Line
	        --
	        -----------------------------------------------------------------------------

		BEGIN


			SELECT		invoice_to_org_id,
    					sold_to_org_id
			INTO		l_inv_to_org_id,
	       				l_sold_to_org_id
			FROM		oe_order_lines_all
			WHERE		line_id = l_line_id;   --DOCUMENT_ID

			EXCEPTION

			WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20069,'INVOICE_TO_ORG_ID OR SOLD_TO_ORG_ID IS MISSING');
			resultout := 1;
		END;

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','Extracted the Invoice_to_org_id_'||l_inv_to_org_id);
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','Extracted the Sold_to_org_id_'||l_sold_to_org_id);

	    ----------------------------------------------------------------------------------
	    --Retrieve the Primary BILL_TO address associated with Customer Account Id
	    --of ORDER LINE
	    ----------------------------------------------------------------------------------

	    BEGIN

		    SELECT		t1.site_use_id
		    INTO 		l_pri_bill_to_site_id
		    FROM		hz_cust_site_uses_all t1,
    					hz_cust_acct_sites_all t2
		    WHERE		t1.site_use_code = 'BILL_TO'
		    AND 		t1.primary_flag = 'Y'
		    AND 		t1.status = 'A'
		    AND			t1.org_id = l_org_id
		    AND 		t1.cust_acct_site_id = t2.cust_acct_site_id
		    AND 		t2.cust_account_id =  l_sold_to_org_id;




		EXCEPTION

		WHEN NO_DATA_FOUND THEN
			RAISE_APPLICATION_ERROR(-20070,'Primary Bill_to Address does not exist, Add the primary Bill_to Address and Retry');
			resultout := 1;

	     END;

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','Extracted the Pri_bill_to_site_id_'||l_pri_bill_to_site_id);

	    OPEN l_sites (l_sold_to_org_id, l_org_id);
	    FETCH l_sites INTO l_site_ids;
	    WHILE (l_sites%FOUND) LOOP

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','In While loop for site_use_id_'||l_site_ids);



		    -------------------------------------------------------------------------------------------
		    --Check to see if Cust Account Site Id Belongs to the Customer Account Id for which
		    --the order is billed
		    -- If Yes set BILL_TO_OWNER_FLAG  =  'Y'
		    -- Else   set BILL_TO_OWNER_FLAG  =  'N'
		    -------------------------------------------------------------------------------------------

		    IF(l_site_ids = l_inv_to_org_id) THEN
			    l_bill_to_owner_flag := 'Y';
		        --  it belongs to the L_SOLD_TO_ORG_ID
		        --  Check for Primary Bill To of  L_SOLD_TO_ORG_ID

                    l_flag := 'Y';

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','In If loop l_site_ids = l_inv_to_org_id_'||l_flag);


		        -------------------------------------------------------------------------------------------
		        --Check to see if Cust Account Site Id is the Primary BILL_TO of the
		        --Customer Account Id for which the order is billed
		        -- If Yes set PRIMARY_BILL_TO_FLAG  =  'Y'
		        -- Else   set PRIMARY_BILL_TO_FLAG  =  'N'
		        -------------------------------------------------------------------------------------------

			        IF(l_site_ids = l_pri_bill_to_site_id) THEN
				        l_primary_bill_to_flag := 'Y';

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','In If loop l_site_ids = l_pri_bill_to_site_id');


				        ---------------------------------------------------------------------------
				        --Get the Details of PRIMARY BILL_TO Address
				        --
				        ---------------------------------------------------------------------------

				        get_bill_to_address  (	l_inv_to_org_id,
							l_party_id,
							l_account_id,
							l_party_number,
							l_party_name,
							l_account_number,
							l_account_name,
							l_bill_to_address,
							l_country,
							l_state,
							l_county,
							l_city,
							l_postal_code,
							x_result);

				        ----------------------------------------------------------------------------
				        --Store the complete address details and flags into xnb_bill_to_party_details
				        --
				        ----------------------------------------------------------------------------

				        create_sales_order  ( 	l_line_id,
							l_party_id,
							l_account_id,
							l_party_number,
							l_party_name,
							l_account_number,
							l_account_name,
							l_bill_to_address,
							l_country,
							l_state,
							l_county,
							l_city,
							l_postal_code,
							l_primary_bill_to_flag,
							l_bill_to_owner_flag,
							x_result);


			        ELSE
				        l_primary_bill_to_flag := 'N';

				        ---------------------------------------------------------------------------
				        --Get the Details of BILL_TO Address Speicied for the Order Line
				        --
				        ---------------------------------------------------------------------------

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','In ELSE loop l_site_ids = l_pri_bill_to_site_id');


				        get_bill_to_address  (	l_inv_to_org_id,
								l_party_id,
								l_account_id,
								l_party_number,
								l_party_name,
								l_account_number,
								l_account_name,
								l_bill_to_address,
								l_country,
								l_state,
								l_county,
								l_city,
								l_postal_code,
								x_result);

				        ---------------------------------------------------------------------------
				        --Store the complete address details and flags into xnb_bill_to_party_details
				        --
				        ---------------------------------------------------------------------------

				        create_sales_order  ( 	l_line_id,
								l_party_id,
								l_account_id,
								l_party_number,
								l_party_name,
								l_account_number,
								l_account_name,
								l_bill_to_address,
								l_country,
								l_state,
								l_county,
								l_city,
								l_postal_code,
								l_primary_bill_to_flag,
								l_bill_to_owner_flag,
								x_result);


			        -- End of If Primary Bill_to
			        END IF;

		        --Enf of if it belongs to the L_SOLD_TO_ORG_ID
		        END IF;

		    FETCH l_sites INTO l_site_ids;
	    -- End of While
	    END LOOP;

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','END of While loop for site_use_id_');


	    l_bill_to_owner_flag := 'N';

	    --CLOSE CURSOR  AND RETURN
            CLOSE l_sites;

	    -------------------------------------------------------------------------------------------
	    --Cust Account Site Id does not Belong to the Customer Account Id
	    --PUBLISH THE BILL TO SPECIFIED IN THE ORDER LINE ** INVOICE_TO_ORG_ID
	    --RELATIONSHIP EXISTS HERE
	    -------------------------------------------------------------------------------------------

        IF l_flag = 'N' THEN

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','In the If Flag = N_'||l_flag);



	            get_bill_to_address  (	l_inv_to_org_id,
				                    	l_party_id,
				                    	l_account_id,
   				                     	l_party_number,
				                    	l_party_name,
				                    	l_account_number,
				                    	l_account_name,
   				                     	l_bill_to_address,
   				                     	l_country,
		   		                     	l_state,
				                    	l_county,
				                    	l_city,
				                    	l_postal_code,
				                    	x_result);

	            create_sales_order  ( 	l_line_id,
				                    	l_party_id,
				                        l_account_id,
				                    	l_party_number,
				                        l_party_name,
				                        l_account_number,
				                    	l_account_name,
				                    	l_bill_to_address,
				                    	l_country,
				                    	l_state,
				                    	l_county,
				                    	l_city,
				                    	l_postal_code,
				                    	l_primary_bill_to_flag,
				                    	l_bill_to_owner_flag,
				                    	x_result);

            -- End if l_flag
            END IF;

	    FETCH l_line_ids INTO l_line_id;
	    -- End of While
        END LOOP;

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','END of While loop for Line_Ids_');
        RETURN;


	--CLOSE CURSOR  AND RETURN
            CLOSE l_line_ids;

--debug
	    XNB_DEBUG.log('XNB_SO_PVT.PUBLISH_LINES_BILL_TOS','After Close for Cursor Line_Ids');


	EXCEPTION


		WHEN OTHERS THEN
			 RAISE_APPLICATION_ERROR(-20034, SQLERRM(SQLCODE));
    --End of Function
    END publish_line_bill_to_address;


    PROCEDURE truncate_all_lines
    (
	    itemtype			IN VARCHAR2,
	    itemkey			IN VARCHAR2,
	    actid			IN NUMBER,
	    funcmode			IN VARCHAR2,
	    resultout			OUT NOCOPY VARCHAR2
    )

 AS

	CURSOR l_line_ids (p_order_num NUMBER)
	IS
	SELECT  line_id
	FROM    oe_order_headers_all head,
	        oe_order_lines_all   line
	WHERE   head.header_id = line.header_id
	AND     head.order_number = p_order_num;

	l_order_number	NUMBER;
	l_line_id	NUMBER;

    begin

	    l_order_number := wf_engine.getitemattrtext (
						    itemtype => itemtype,
				                    itemkey  => itemkey,
						    aname    => 'ORDER_NUMBER');

	    ------------------------------------------------------------------------------
	    --Query to Delete the Published details
	    --
	    ------------------------------------------------------------------------------

	    OPEN l_line_ids (l_order_number);
	    FETCH l_line_ids INTO l_line_id;
	    WHILE (l_line_ids%FOUND) LOOP

		    DELETE FROM xnb_bill_to_party_details
		    WHERE order_line_id = l_line_id;

	    FETCH l_line_ids INTO l_line_id;
	    END LOOP;

	    COMMIT;

       	    --CLOSE CURSOR  AND RETURN
            CLOSE l_line_ids;

    --End of Function
    END truncate_all_lines;


--End of Package
END xnb_sales_order_pvt;

/
