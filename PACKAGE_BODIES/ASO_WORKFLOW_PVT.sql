--------------------------------------------------------
--  DDL for Package Body ASO_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_WORKFLOW_PVT" as
/* $Header: asovwftb.pls 120.1 2005/06/29 12:46:12 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_WORKFLOW_PVT
-- Purpose         :
-- History         :
-- NOTE       :
--   		ASO_workflow_pvt - Procedure for all iStore alerts that will be
--                      			executed using Workflow
-- End of Comments

g_ItemType	Varchar2(10)   	:= 'ASOALERT';
g_processName 	Varchar2(30) 	:= 'ASOALERT';

Cursor c_ship_methods(pCode Varchar2) IS
  Select Meaning
  from   oe_ship_methods_v
  Where  Lookup_code = pCode;

Cursor c_quote_header (p_quote_id 	NUMBER) IS
	SELECT 	org_id,party_id, quote_name,quote_number, quote_version,
               	quote_password,cust_account_id,invoice_to_party_id,
                invoice_to_party_site_id,quote_header_id,ordered_date,
               	order_id, total_list_price,total_shipping_charge,total_tax,
        	total_quote_price,invoice_to_cust_account_id,
        	total_adjusted_amount,currency_code
	FROM aso_quote_headers_all
	WHERE  quote_header_id = p_quote_id;

g_quote_header_rec	c_quote_header%ROWTYPE;

Cursor c_quote_detail (p_quote_id	NUMBER) IS
	SELECT 	Inventory_item_id, Organization_id, Quantity,
		Line_quote_price,currency_code
        FROM Aso_quote_lines_all
	WHERE  quote_header_id = p_quote_id
	ORDER BY line_number;

g_quote_line_rec		c_quote_detail%ROWTYPE;

Cursor c_quote_payment (p_quote_id	NUMBER) IS
	SELECT Payment_type_code
      	FROM   Aso_Payments
	WHERE  quote_header_id = p_quote_id;

Cursor  c_hz_parties(p_party_id NUMBER) IS
	SELECT	Party_Name,Person_First_Name,Person_Middle_Name,
		Person_Last_name,party_type
	FROM	hz_parties
	WHERE	party_id = p_party_id;

Cursor  c_hz_contact_points(p_party_id NUMBER) IS
	SELECT 	Contact_Point_type,Primary_flag, Phone_line_type,
		Phone_Country_code, Phone_area_code, Phone_number, Email_address
	FROM	hz_contact_points
	WHERE	owner_table_name = 'HZ_PARTIES'
	AND	owner_table_id = p_party_id;


cursor c_curr_symbol(p_currCode VARCHAR2) IS
   SELECT fc.symbol FROM FND_CURRENCIES fc
   WHERE fc.currency_code = p_currCode;


NEWLINE		VARCHAR2(1) := fnd_global.newline;
TAB		VARCHAR2(1) := fnd_global.tab;


Procedure getUserType(pPartyId IN Varchar2,pUserType OUT NOCOPY /* file.sql.39 change */  Varchar2) IS
  l_PartyType  Varchar2(30);
  l_UserType   Varchar2(30) := 'B2B';
BEGIN

  FOR c_hz_parties_rec IN c_hz_parties(pPartyId)  LOOP
      l_PartyType  := rtrim(c_hz_parties_rec.party_type);
  END LOOP;

  If l_PartyType = 'PERSON' Then
     l_userType  := 'B2C';
  End If;

     pUserType  :=  l_userType;

END getUserType;


PROCEDURE NotifyOrderStatus(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_quote_id		IN	NUMBER,
	p_status 		IN	VARCHAR2,
	p_errmsg_count		IN	NUMBER,
	p_errmsg_data		IN	VARCHAR2,
	x_return_status	       OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	x_msg_count	 OUT NOCOPY /* file.sql.39 change */  NUMBER,
	x_msg_data	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
	) IS

	l_adhoc_user		WF_USERS.NAME%TYPE;
	l_item_key		WF_ITEMS.ITEM_KEY%TYPE;
	l_event_type		VARCHAR2(20);
	l_email_addr		WF_USERS.Email_Address%TYPE;
	l_this                  NUMBER;
	l_temp_str              VARCHAR2(2000);
	l_next                  NUMBER;
	l_errmsg_count		NUMBER;
	l_errmsg_data		VARCHAR2(32000);
	l_item_owner            WF_USERS.NAME%TYPE := 'SYSADMIN';
	l_UserType              Varchar2(30) := 'ALL';
      	l_notifname		Varchar2(100);
      	--dummy			pls_integer;
      	l_display_name		Varchar2(100) := 'Quoting Order Administrator';
      	l_name			Varchar2(100) := 'ASOORDERADMIN';
		CURSOR wf_name_cur IS
		select name
		from wf_users
		where orig_system = 'WF_LOCAL_USERS'
		and name = 'ASOORDERADMIN'
		and status = 'ACTIVE';
		l_wf_name_cur_name varchar2(2000);

BEGIN
 	x_return_status :=  FND_API.g_ret_sts_success;

      	l_event_type := 'ORDERROR';
		l_notifName  := 'ORDERROR';

		l_errmsg_count := p_errmsg_count;
                IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('Notify Order Status - Error Message Count -  '||to_char(l_errmsg_count),1,'Y');
		END IF;

		IF ( l_errmsg_count = 1 ) THEN
			l_errmsg_data  := p_errmsg_data;
		ELSE
			l_this := 1;
			l_errmsg_data := '';
			WHILE ( l_this <= l_errmsg_count ) LOOP
				l_temp_str := null;
				fnd_msg_pub.Get(l_this,FND_API.G_FALSE,l_temp_str,l_next);
				l_errmsg_data := l_errmsg_data || TAB || TAB ||l_temp_str || NEWLINE;
				l_this := l_this + 1;
			END LOOP;
		END IF;

                IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('NotifyOrderStatus - Error Message Data After LOOP - '||l_errmsg_data,1,'Y');
		END IF;


		l_adhoc_user  := FND_PROFILE.VALUE('ASO_ADMIN_EMAIL');

		OPEN  wf_name_cur;
		FETCH wf_name_cur INTO l_wf_name_cur_name;
		CLOSE  wf_name_cur;

            If l_wf_name_cur_name is not null Then

                    wf_directory.SetAdHocUserAttr(
					user_name   		=> l_name,
				  	notification_preference => 'MAILTEXT',
                     	                email_address  		=> l_adhoc_user );

                    wf_directory.SetAdHocUserExpiration(
					user_name    	=> l_name,
				        expiration_date => sysdate+10);

           Else
			 wf_directory.CreateAdHocUser(
				name          		=> l_name,
                      		display_name  		=> l_display_name,
				notification_preference => 'MAILTEXT',
                      		email_address     	=> l_adhoc_user,
                     		expiration_date   	=> sysdate+10 );

           End If;

           IF aso_debug_pub.g_debug_flag = 'Y' THEN
              ASO_DEBUG_PUB.add('NotifyOrderStatus - p_quote_id - '||to_char(p_quote_id)||','||p_status,1,'Y');
	   END IF;

           l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_id;

           /* Item Key should be Unique as it represent a process instance with ITEM TYPE*/

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
	        ASO_DEBUG_PUB.add('Create and Start Process with Item Key: '||l_item_key,1,'Y');
             END IF;

		wf_engine.CreateProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			process  	=> g_processName);

		wf_engine.SetItemUserKey(
			itemtype 	=> g_ItemType,
			itemkey		=> l_item_key,
			userkey		=> l_item_key);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'ITEMKEY',
			avalue		=> l_item_key);


  		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'EVENTTYPE',
			avalue		=> l_event_type);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'QUOTE_ID',
			avalue		=> p_quote_id);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'SENDTO',
			avalue		=> l_name);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey		=> l_item_key,
			aname 		=> 'ERRMSG',
			avalue		=> l_errmsg_data);

		wf_engine.SetItemOwner(
			itemtype 	=> g_ItemType,
			itemkey		=> l_item_key,
			owner		=> l_item_owner);

		wf_engine.StartProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key);

             IF aso_debug_pub.g_debug_flag = 'Y' THEN
	        ASO_DEBUG_PUB.add('Process Started',1,'Y');
	     END IF;

Exception
	When OTHERS Then
		x_return_status := FND_API.g_ret_sts_error;
		x_msg_count := 0;

		wf_core.context('ASO_WORKFLOW_PVT',
			'NotifyOrderStatus',
			l_event_type,
			to_char(p_quote_id)
		);
                raise;

END NotifyOrderStatus;

PROCEDURE GenerateQuoteHeader(
	document_id		IN              	VARCHAR2,
	display_type    	IN              	VARCHAR2,
	document        	IN      OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
	document_type   	IN      OUT NOCOPY /* file.sql.39 change */   VARCHAR2
) IS

l_item_key			wf_items.item_key%TYPE;
l_quote_id			NUMBER;
l_event_type			VARCHAR2(20);
l_contract_id			NUMBER;
l_contract_Number       	VARCHAR2(120);
l_contract_Modifier     	VARCHAR2(120);
l_contact_name			VARCHAR2(400);
l_contact_number		VARCHAR2(70);
l_contact_email			hz_contact_points.email_address%TYPE;
l_bill_to_party_name		hz_parties.party_name%TYPE;
l_bill_to_name			VARCHAR2(400);
l_bill_to_number		VARCHAR2(70);
l_bill_to_fax			VARCHAR2(70);
l_bill_to_address		hz_locations.address1%TYPE;
l_bill_to_city			hz_locations.city%TYPE;
l_bill_to_state			hz_locations.state%TYPE;
l_bill_to_zip			hz_locations.postal_code%TYPE;
l_bill_to_country		hz_locations.country%TYPE;
l_ship_to_site_id		aso_shipments.ship_to_party_site_id%TYPE;
l_ship_to_party_id		aso_shipments.ship_to_party_id%TYPE;
l_ship_to_cust_account_id 	aso_shipments.ship_to_cust_account_id%TYPE;
l_ship_method_code		aso_shipments.ship_method_code%TYPE;
l_ship_method			varchar2(80);
l_ship_to_party_name		hz_parties.party_name%TYPE;
l_ship_to_name			VARCHAR2(400);
l_ship_to_number		VARCHAR2(70);
l_ship_to_fax			VARCHAR2(70);
l_ship_to_address		hz_locations.address1%TYPE;
l_ship_to_city			hz_locations.city%TYPE;
l_ship_to_state			hz_locations.state%TYPE;
l_ship_to_zip			hz_locations.postal_code%TYPE;
l_ship_to_country		hz_locations.country%TYPE;
l_document			VARCHAR2(32000) := '';
l_temp_str			VARCHAR2(2000):='';

Cursor c_hz_locations(p_loc_site_id NUMBER) IS
SELECT	rtrim(address1) || ' ' || rtrim(address2) || ' ' || rtrim(address3) || ' ' || rtrim(address4) loc_address,
	rtrim(city) loc_city,
        rtrim(state)||'/' || rtrim(province) loc_state,
        rtrim(postal_code) loc_zip,
        rtrim(country) loc_country
	FROM		hz_locations
	WHERE 		location_id = (	SELECT 	location_id
					FROM   	hz_party_sites
					WHERE	party_site_id = p_loc_site_id);
Cursor c_aso_shipments(p_quote_id NUMBER) IS
SELECT 	ship_to_cust_account_id, ship_to_party_site_id, ship_to_party_id, ship_method_code
	FROM	aso_shipments
	WHERE   quote_header_id = p_quote_id
	AND	quote_line_id IS NULL
	AND	rownum = 1;


Cursor c_hz_cust_accounts(p_cust_account_id NUMBER) IS
 SELECT hc.party_id,hp.Party_Name,hp.Person_First_Name,hp.Person_Middle_Name,hp.Person_Last_name,hp.party_type
 FROM	hz_cust_accounts hc, hz_parties hp
 WHERE  cust_account_id = p_cust_account_id
 AND    hc.party_id = hp.party_id;

l_sold_contact_party_id		 Number;
l_bill_contact_party_id		 Number;
l_ship_contact_party_id		 Number;


BEGIN

        l_item_key := document_id;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   ASO_DEBUG_PUB.add('GenerateQuoteHeader - l_item_key - '||l_item_key,1,'Y');
	END IF;

	l_quote_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname		=> 'QUOTE_ID'
	);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   ASO_DEBUG_PUB.add('GenerateQuoteHeader - l_quote_id - '||l_quote_id,1,'Y');
	END IF;

	l_event_type := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname   	=> 'EVENTTYPE'
	);

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   aso_debug_pub.add('GenerateQuoteHeader - l_event_type - '|| l_event_type,1,'Y');
	END IF;

	OPEN c_quote_header(l_quote_id);
	LOOP
		FETCH	c_quote_header INTO g_quote_header_rec;
		EXIT WHEN	c_quote_header%NOTFOUND;

		/* Get all contact information */

		l_contact_name := null;
            	l_sold_contact_party_id := null;

                FOR c_hz_parties_rec IN c_hz_parties(g_quote_header_rec.party_id) LOOP
                If   c_hz_parties_rec.party_type = 'PARTY_RELATIONSHIP' Then
                     l_contact_name   := upper(rtrim(c_hz_parties_rec.person_first_name))||' '||upper(rtrim(c_hz_parties_rec.person_last_name));

                     l_sold_contact_party_id := g_quote_header_rec.party_id;
                End If;
                END LOOP;


                If l_sold_contact_party_id is null Then
                    FOR c_hz_cust_acct_rec IN  c_hz_cust_accounts(g_quote_header_rec.cust_account_id) LOOP
                     l_contact_name   := upper(rtrim(c_hz_cust_acct_rec.person_first_name))||' '||upper(rtrim(c_hz_cust_acct_rec.person_last_name));
                     l_sold_contact_party_id := c_hz_cust_acct_rec.party_id;
                    End Loop;
                 End If;

        	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - l_contact_name '|| l_contact_name,1,'Y');
		END IF;

        	l_contact_number := null;
		l_contact_email := null;


		FOR c_hz_contact_rec IN c_hz_contact_points(l_sold_contact_party_id) LOOP

		If (c_hz_contact_rec.contact_point_type =    'PHONE' AND c_hz_contact_rec.phone_line_type = 'GEN') AND (l_contact_number IS NULL OR c_hz_contact_rec.primary_flag ='Y') Then

                   l_contact_number := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);

		Elsif c_hz_contact_rec.contact_point_type = 'EMAIL'  AND (l_contact_email IS NULL OR c_hz_contact_rec.primary_flag ='Y')  Then

                   l_contact_email := c_hz_contact_rec.email_address;

                End If;
		END LOOP;

        	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - l_contact_number - '|| l_contact_number,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - l_contact_email - '|| l_contact_email,1,'Y');
		END IF;


		/* Get all billing information */

		l_bill_to_party_name := null;
		l_bill_to_name := null;


                /* Bill Customer Info. From Invoice_To_Cust_Account_ID */

                FOR c_hz_cust_acct_rec IN  c_hz_cust_accounts(nvl(g_quote_header_rec.invoice_to_cust_account_id,g_quote_header_rec.cust_account_id)) LOOP
 		     l_bill_to_party_name := rtrim(c_hz_cust_acct_rec.party_name);
                     l_bill_to_name   := upper(rtrim(c_hz_cust_acct_rec.person_first_name))||' '||upper(rtrim(c_hz_cust_acct_rec.person_last_name));
                     l_bill_contact_party_id := c_hz_cust_acct_rec.party_id;
                 End Loop;

        	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - bill_party_name - '||l_bill_to_party_name,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - bill_name - '||l_bill_to_name,1,'Y');
		END IF;


            	l_bill_to_number := null;
		l_bill_to_fax := null;

                /* Bill Contact Info. From Invoice_To_Party_ID (PARTY_RELATIONSHIP) OR Bill Customer Party Id. */

                 If g_quote_header_rec.invoice_to_party_id is not null Then
                   FOR c_hz_parties_rec IN c_hz_parties(g_quote_header_rec.invoice_to_party_id) LOOP
                       If c_hz_parties_rec.party_type = 'PARTY_RELATIONSHIP' Then
                          l_bill_contact_party_id := g_quote_header_rec.party_id;
                        End If;
                   END LOOP;
                End if;

                FOR c_hz_contact_rec IN c_hz_contact_points(l_bill_contact_party_id) LOOP

		If (c_hz_contact_rec.contact_point_type = 'PHONE' AND c_hz_contact_rec.phone_line_type = 'GEN') AND (l_bill_to_number IS NULL OR  c_hz_contact_rec.primary_flag ='Y')  Then

                   l_bill_to_number := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);

		Elsif (c_hz_contact_rec.contact_point_type = 'PHONE' AND c_hz_contact_rec.phone_line_type = 'FAX') AND (l_bill_to_fax IS NULL OR c_hz_contact_rec.primary_flag ='Y')  Then

                   l_bill_to_fax := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);

                End If;
		END LOOP;

        	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - bill_party_number - '||l_bill_to_number,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - bill_fax - '||l_bill_to_fax,1,'Y');
		END IF;
		l_bill_to_address := null;
		l_bill_to_city := null;
		l_bill_to_state := null;
		l_bill_to_zip := null;
		l_bill_to_country := null;

                /* Bill to Location id using invoice_to_party_site_id */

                FOR c_hz_locations_rec IN c_hz_locations(g_quote_header_rec.invoice_to_party_site_id) LOOP

		l_bill_to_address := c_hz_locations_rec.loc_address;
		l_bill_to_city := c_hz_locations_rec.loc_city;
		l_bill_to_state := c_hz_locations_rec.loc_state;
		l_bill_to_zip := c_hz_locations_rec.loc_zip;
		l_bill_to_country := c_hz_locations_rec.loc_country;

		END LOOP;

        	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - bill_address - '||l_bill_to_address,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - bill_city - '||l_bill_to_city,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - bill_state - '||l_bill_to_state,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - bill_zip - '||l_bill_to_zip,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - bill_country - '||l_bill_to_country,1,'Y');
		END IF;

		/* Get all shipping information */

		l_ship_to_site_id := null;
		l_ship_to_party_id := null;
		l_ship_method_code := null;

                FOR c_aso_shipments_rec IN c_aso_shipments(l_quote_id) LOOP
		l_ship_to_site_id :=  c_aso_shipments_rec.ship_to_party_site_id;
		l_ship_to_cust_account_id :=  c_aso_shipments_rec.ship_to_cust_account_id;
		l_ship_to_party_id := c_aso_shipments_rec.ship_to_party_id;
		l_ship_method_code := c_aso_shipments_rec.ship_method_code;
                END LOOP;

		For c_ship_method_rec in c_ship_methods(l_ship_method_code) LOOP
		l_Ship_Method := c_ship_method_rec.Meaning;
		End Loop;

        	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_to_site_id - '||l_ship_to_site_id,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_to_party_id - '||l_ship_to_party_id,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_to_method - '||l_ship_method_code,1,'Y');
		END IF;

                 /* Shipping Customer Information - ship_to_cust_account_id */

                 FOR c_hz_cust_acct_rec IN  c_hz_cust_accounts(nvl(l_ship_to_cust_account_id,g_quote_header_rec.cust_account_id)) LOOP
 		     l_ship_to_party_name := rtrim(c_hz_cust_acct_rec.party_name);
                     l_ship_to_name   := upper(rtrim(c_hz_cust_acct_rec.person_first_name))||' '||upper(rtrim(c_hz_cust_acct_rec.person_last_name));
                     l_ship_contact_party_id := c_hz_cust_acct_rec.party_id;
                 End Loop;


        	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_to_party_name - '||l_ship_to_party_name,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_to_name - '||l_ship_to_name,1,'Y');
		END IF;

                /* Shipping Contact ship_to_party_id(PARTY_REALTIONSHIP) OR Ship Customer's Party Id */
                If l_ship_to_party_id is not null Then
                   FOR c_hz_parties_rec IN c_hz_parties(l_ship_to_party_id) LOOP
                       If c_hz_parties_rec.party_type = 'PARTY_RELATIONSHIP' Then
                          l_ship_contact_party_id := g_quote_header_rec.party_id;
                        End If;
                   END LOOP;
                End If;

                FOR c_hz_contact_rec IN c_hz_contact_points(l_ship_contact_party_id) LOOP

		If (c_hz_contact_rec.contact_point_type = 'PHONE' AND c_hz_contact_rec.phone_line_type = 'GEN')  AND (l_ship_to_number IS NULL OR c_hz_contact_rec.primary_flag ='Y')  Then

                   l_ship_to_number := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);

		Elsif (c_hz_contact_rec.contact_point_type = 'PHONE' AND c_hz_contact_rec.phone_line_type = 'FAX')   AND (l_ship_to_fax IS NULL OR c_hz_contact_rec.primary_flag ='Y') Then

                   l_ship_to_fax := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);

                End If;
		END LOOP;

        	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_to_number - '||l_ship_to_number,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_to_fax - '||l_ship_to_fax,1,'Y');
		END IF;

		l_ship_to_address := null;
		l_ship_to_city    := null;
		l_ship_to_state   := null;
		l_ship_to_zip     := null;
		l_ship_to_country := null;

    		FOR c_hz_locations_rec IN  c_hz_locations(l_ship_to_site_id) LOOP

		l_ship_to_address := c_hz_locations_rec.loc_address;
		l_ship_to_city    := c_hz_locations_rec.loc_city;
		l_ship_to_state   := c_hz_locations_rec.loc_state;
		l_ship_to_zip     := c_hz_locations_rec.loc_zip;
		l_ship_to_country := c_hz_locations_rec.loc_country;

		END LOOP;


        	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_address - '||l_ship_to_address,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_city - '||l_ship_to_city,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_state - '||l_ship_to_state,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_zip - '||l_ship_to_zip,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - ship_country - '||l_ship_to_country,1,'Y');
		   ASO_DEBUG_PUB.add('GenerateQuoteHeader - quote_header_id - '||g_quote_header_rec.quote_header_id,1,'Y');
		END IF;

		IF (display_type = 'text/plain' ) THEN
				fnd_message.set_name('ASO','ASO_PRMT_QUOTE_NUMBER_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||g_quote_header_rec.quote_number||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_QUOTE_NAME_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||g_quote_header_rec.quote_name||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_SHIP_METH_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_method||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_CUST_CNTCT_INFO');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_CNTCT_NAME_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_contact_name||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_CNTCT_NUM_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_contact_number||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_CNTCT_EMAIL_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_contact_email||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_QUOTE_BILL_INFO');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_CUST_NAME_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_party_name||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_ADDRESS_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_address||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_CITY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_bill_to_city||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_STATE_PRO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_state||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_ZIP_POSTAL_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||l_bill_to_zip||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_COUNTRY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_country||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_CNTCT_NAME_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_name||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_TEL_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||l_bill_to_number||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_FAX_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_fax||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_QUOTE_SHIP_INFOR');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_CUST_NAME_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_party_name||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_ADDRESS_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_address||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_CITY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_ship_to_city||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_STATE_PRO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_state||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_COUNTRY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_country||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_CNTCT_NAME_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_name||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_TEL_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||l_ship_to_number||NEWLINE;

				fnd_message.set_name('ASO','ASO_PRMT_FAX_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_fax||NEWLINE;

		ELSE
				null;
		END IF;

	END LOOP;
	CLOSE c_quote_header;

        IF aso_debug_pub.g_debug_flag = 'Y' THEN
	   ASO_DEBUG_PUB.add('GenerateQuoteHeader - l_document'||NEWLINE|| l_document,1,'Y');
	END IF;

	document := l_document;
	document_type := 'text/plain';

	EXCEPTION
		When Others Then
			IF c_quote_header%ISOPEN THEN
				CLOSE c_quote_header;
			END IF;
		Raise;
END GenerateQuoteHeader;

PROCEDURE Selector(
	itemtype	IN	VARCHAR2,
	itemkey		IN	VARCHAR2,
	actid		IN	NUMBER,
	funcmode	IN	VARCHAR2,
	result	 OUT NOCOPY /* file.sql.39 change */  VARCHAR2
) IS

l_event_type		VARCHAR2(50);

BEGIN
	IF ( funcmode = 'RUN' ) THEN
		l_event_type := wf_engine.GetItemAttrText(
			itemtype 	=> itemtype,
			itemkey  	=> itemkey,
			aname   	=> 'EVENTTYPE'
		);

        	IF aso_debug_pub.g_debug_flag = 'Y' THEN
		   ASO_DEBUG_PUB.add('Selector - Inside  RUN- '||l_event_type,1,'Y');
		END IF;

		IF l_event_type = 'ORDERROR' THEN
        		IF aso_debug_pub.g_debug_flag = 'Y' THEN
			   ASO_DEBUG_PUB.add('Selector - Inside  order confirmation selection ',1,'Y');
			END IF;
			result := 'COMPLETE:ORDERROR';
		END IF;
	END IF;
	IF ( funcmode = 'CANCEL' ) THEN
		result := 'COMPLETE';
	END IF;
END Selector;

END aso_workflow_pvt;

/
