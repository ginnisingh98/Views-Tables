--------------------------------------------------------
--  DDL for Package Body ASO_WORKFLOW_QUOTE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_WORKFLOW_QUOTE_PVT" AS
/* $Header: asovwfqb.pls 120.1 2005/06/29 12:46:05 appldev ship $ */

-- Start of Comments
-- Package name     : ASO_WORKFLOW_QUOTE_PVT
-- Purpose          :
-- History          :
--                    03-26-2003 hyang - bug fix 2870829, increase size of
--                      FND_CURRENCIES.Symbol
-- NOTE             :
-- End of Comments


g_ItemType	            VARCHAR2(10) := 'ASOALERT';
g_processName           VARCHAR2(30) := 'PROCESSMAP';
G_PKG_NAME              CONSTANT VARCHAR2(30):= 'ASO_WORKFLOW_QUOTE_PVT';
G_FILE_NAME             CONSTANT VARCHAR2(12) := 'asovwfqb.pls';
NEWLINE	                VARCHAR2(1) := fnd_global.newline;
TAB		                  VARCHAR2(1) := fnd_global.tab;

GET_MESSAGE_ERROR  EXCEPTION;


CURSOR c_quote_header (p_quote_id NUMBER) IS
  SELECT  org_id, party_id, quote_name,quote_number,
          quote_version, quote_password, contract_requester_id,
          cust_account_id,invoice_to_party_id, invoice_to_party_site_id,
          quote_header_id, ordered_date, order_id, total_list_price,
          total_shipping_charge,total_tax, total_quote_price,
          invoice_to_cust_account_id,total_adjusted_amount,currency_code,
          resource_id
  FROM    aso_quote_headers_all
	WHERE   quote_header_id = p_quote_id;

g_quote_header_rec	c_quote_header%ROWTYPE;

CURSOR c_curr_symbol(p_currCode VARCHAR2) IS
  SELECT  fc.symbol
  FROM    FND_CURRENCIES fc
  WHERE   fc.currency_code = p_currCode;


PROCEDURE getUserType(pPartyId IN Varchar2,pUserType OUT NOCOPY /* file.sql.39 change */  Varchar2)
IS

  l_PartyType  Varchar2(30);
  l_UserType   Varchar2(30) := 'B2B';

  CURSOR  c_hz_parties(p_party_id NUMBER) IS
  	SELECT	Party_Name,Person_First_Name,Person_Middle_Name,Person_Last_name,party_type,Person_title
  	FROM	hz_parties
  	WHERE	party_id = p_party_id;

BEGIN

  FOR c_hz_parties_rec IN c_hz_parties(pPartyId)
  LOOP
    l_PartyType  := rtrim(c_hz_parties_rec.party_type);
  END LOOP;

  IF l_PartyType = 'PERSON'
  THEN
    l_userType  := 'B2C';
  END IF;

  pUserType  :=  l_userType;

END getUserType;

/* PROCEDURE: To send OUT email alert for change in contract status.

*/

PROCEDURE NotifyForASOContractChange(
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2  := FND_API.G_FALSE,
  p_quote_id          IN  NUMBER,
  p_contract_id       IN  NUMBER,
  p_notification_type IN  VARCHAR2,
  p_customer_comments IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
  x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER,
  x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
) IS

  l_event_type		          VARCHAR(30);
  l_item_key		            WF_ITEMS.ITEM_KEY%TYPE;
  l_item_owner              WF_USERS.NAME%TYPE := 'SYSADMIN';

  l_quote_org_id            NUMBER;

  l_org_contract_rep	      WF_USERS.NAME%TYPE;
  l_contract_requester	    WF_USERS.NAME%TYPE;
  l_contract_requester_id   NUMBER;

  l_quote_number            NUMBER;

  l_msite_id		            NUMBER := null;

  l_partyId                 NUMBER;

  l_notifEnabled		        VARCHAR2(3) := 'Y';
  l_notifName		            VARCHAR2(30) := 'ASOCONTRACTAPPROVED';
  l_UserType                VARCHAR2(30) := 'ALL';
  l_messageName             WF_MESSAGES.NAME%TYPE;
  l_msgEnabled	            VARCHAR2(3) :='Y';

  CURSOR c_fnd_user(lc_user_id NUMBER) IS
    SELECT  user_name
    FROM    fnd_user
    WHERE   user_id = lc_user_id;

BEGIN

  x_return_status :=  FND_API.g_ret_sts_success;

  -- Check for WorkFlow Feature Availablity.

  IF p_notification_type = 'CONTRACT_APPROVED'
  THEN
  -- Approved

    l_event_type 	:= 'ASOCONTRACTAPPROVED';
    l_notifName	  := 'ASOCONTRACTAPPROVED';

  ELSIF p_notification_type = 'CONTRACT_CANCELED'
  THEN

    l_event_type	:= 'ASOCONTRACTCANCELED';
    l_notifName	  := 'ASOCONTRACTCANCELED';

  ELSIF p_notification_type = 'CONTRACT_CHANGED'
  THEN

    l_event_type 	:= 'ASOCONTRACTCHANGED';
    l_notifName	  := 'ASOCONTRACTCHANGED';

  ELSIF p_notification_type = 'CONTRACT_REJECTED'
  THEN

    l_event_type 	:= 'ASOCONTRACTREJECTED';
    l_notifName	  := 'ASOCONTRACTREJECTED';

  END IF;

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('NotifyForASOContractChange: Check if this notification is enabled.', 1, 'Y');
  END IF;

  l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

  IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    aso_debug_pub.add('NotifyForASOContractChange: Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled, 1, 'Y');
  END IF;

  IF l_notifEnabled = 'Y'
  THEN

    FOR c_quote_rec In c_quote_header(p_quote_id)
    LOOP
      l_contract_requester_id   := c_quote_rec.contract_requester_id;
      l_quote_org_id            := c_quote_rec.org_id;
      l_quote_number            := c_quote_rec.quote_number;
		  l_partyId    	            := c_quote_rec.party_id;
    END LOOP;

    FOR c_fnd_user_rec In c_fnd_user(l_contract_requester_id)
    LOOP
      l_contract_requester   := c_fnd_user_rec.user_name;
    END LOOP;

	  l_msite_id := null;

    getUserType(l_partyId,l_UserType);

   	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
   	  aso_debug_pub.add('NotifyForASOContractChange: Get Message - MsiteId: '||to_Char(l_msite_id)||' Org_id: '||to_char(l_quote_org_id)||' User Type: '||l_userType, 1, 'Y');
   	END IF;

    IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
  	(
        p_org_id	=>	l_quote_org_id,
     	  p_msite_id      =>	l_msite_id,
        p_user_type	=>	l_userType,
        p_notif_name	=>	l_notifName,
        x_enabled_flag  =>      l_msgEnabled,
        x_wf_message_name	=> l_MessageName,
        x_return_status => x_return_status,
        x_msg_data 	=> x_msg_data,
        x_msg_count	=> x_msg_data
    );


    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.add('NotifyForASOContractChange: Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled, 1, 'Y');
    END IF;

    IF x_msg_count > 0
    THEN
      Raise GET_MESSAGE_ERROR;
    END IF;

    IF l_msgEnabled = 'Y'
    THEN

	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	      aso_debug_pub.add('NotifyForASOContractChange: NotifyForASOContractChange - eventtype - '||l_event_type, 1, 'Y');
	    END IF;

    	l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-C'||p_quote_id;

	    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	      aso_debug_pub.add('NotifyForASOContractChange: Create and Start Process with Item Key: '||l_item_key, 1, 'Y');
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
    		aname		=> 'MESSAGE',
    		avalue		=>  l_MessageName);

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
    		aname		=> 'QUOTEID',
    		avalue		=> p_quote_id);

    	wf_engine.SetItemAttrText(
    		itemtype 	=> g_ItemType,
    		itemkey  	=> l_item_key,
    		aname		=> 'QUOTENUM',
    		avalue		=> l_quote_number);

    	wf_engine.SetItemAttrText(
    		itemtype 	=> g_ItemType,
    		itemkey  	=> l_item_key,
    		aname		=> 'CONTRACTNO',
    		avalue		=> p_contract_id);

    	wf_engine.SetItemAttrText(
    		itemtype 	=> g_ItemType,
    		itemkey  	=> l_item_key,
    		aname		=> 'COMMENTS',
    		avalue		=> p_customer_comments);

    	wf_engine.SetItemAttrText(
    		itemtype 	=> g_ItemType,
    		itemkey  	=> l_item_key,
    		aname		=> 'SENDTO',
    		avalue		=> l_contract_requester);

    	wf_engine.SetItemOwner(
    		itemtype 	=> g_ItemType,
    		itemkey		=> l_item_key,
    		owner		=> l_item_owner);

    	wf_engine.StartProcess(
    		itemtype 	=> g_ItemType,
    		itemkey  	=> l_item_key);


    	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
    	  aso_debug_pub.add('NotifyForASOContractChange: Process Started', 1, 'Y');
    	END IF;
    END IF; -- msgEnabled
  END IF; -- NotiftEnabled

EXCEPTION
  WHEN OTHERS
  THEN
  	x_return_status := FND_API.g_ret_sts_error;
  	x_msg_count := 0;

  	wf_core.context('ASO_WORKFLOW_QUOTE_PVT',
  		'NotifyForASOContractChange',
  		l_event_type,
  		to_char(p_quote_id)
  	);
    RAISE GET_MESSAGE_ERROR;

END NotifyForASOContractChange;


PROCEDURE ParseThisString (
	p_string_in	      IN	VARCHAR2,
	p_string_out	    OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	p_string_left	    OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

  l_lengthy_word    BOOLEAN;
  l_line_length	    NUMBER;
  l_length		      NUMBER;
  l_lim		          NUMBER;
  i		              NUMBER;
  j		              NUMBER;
  l_pos		          NUMBER;

BEGIN
	l_line_length := 30;
	l_length := length(p_string_in);
	IF ( l_length < l_line_length ) THEN
		p_string_out := rpad(p_string_in,35,' ');
		p_string_left := '';
	ELSE
		l_lim := l_line_length;
		p_string_out := '';
		i := 1;
		j := 1;
		l_pos := 0;

		WHILE i <= l_lim LOOP
			j := instr(p_string_in,' ',i);
			IF( (j=0) AND (i=1) ) THEN
				l_pos := 28;
				l_lengthy_word := true;
			END IF;
			IF ( j <> 0 ) THEN
				i := j+1;
				l_pos := j;
			END IF;
			EXIT WHEN j = 0;
		END LOOP;
		p_string_out := substr(p_string_in,1,l_pos);
          IF ( l_lengthy_word = true ) THEN
			l_lengthy_word := false;
	          p_string_out :=  p_string_out || '-';
		END IF;
		IF (length(p_string_out) < 35 ) THEN
			p_string_out := rpad(p_string_out,35,' ');
		END IF;
		p_string_left := substr(p_string_in,l_pos+1,length(p_string_in)-l_pos);
	END IF;
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('ParseThisString - p_string_out - '||p_string_out, 1, 'Y');
	  aso_debug_pub.add('ParseThisString - p_string_left - '||p_string_left, 1, 'Y');
	END IF;
END ParseThisString;

FUNCTION AddSpaces (
	p_num_in		IN	NUMBER
) RETURN VARCHAR2
IS
  l_str_out	varchar2(200);
BEGIN
	l_str_out := rpad(' ',p_num_in,' ');
	return l_str_out;
END AddSpaces;


PROCEDURE GenerateQuoteHeader(
	document_id	      IN              	  VARCHAR2,
	display_type    	IN              	  VARCHAR2,
	document        	IN       OUT NOCOPY /* file.sql.39 change */     	 VARCHAR2,
	document_type   	IN       OUT NOCOPY /* file.sql.39 change */     	 VARCHAR2
)
IS

  l_item_key		wf_items.item_key%TYPE;
  l_quote_id		NUMBER;
  l_event_type		VARCHAR2(20);
  l_contract_id		NUMBER;
  l_contract_Number       VARCHAR2(120);
  l_contract_Modifier     VARCHAR2(120);
  l_comments		VARCHAR2(2000);
  l_contact_name		VARCHAR2(400);
  l_contact_number	VARCHAR2(70);
  l_contact_email		hz_contact_points.email_address%TYPE;
  l_bill_to_party_name	hz_parties.party_name%TYPE;
  l_bill_to_name		VARCHAR2(400);
  l_bill_to_number	VARCHAR2(70);
  l_bill_to_fax		VARCHAR2(70);
  l_bill_to_address	hz_locations.address1%TYPE;
  l_bill_to_city		hz_locations.city%TYPE;
  l_bill_to_state		hz_locations.state%TYPE;
  l_bill_to_zip		hz_locations.postal_code%TYPE;
  l_bill_to_country	hz_locations.country%TYPE;
  l_ship_to_site_id	aso_shipments.ship_to_party_site_id%TYPE;
  l_ship_to_party_id	aso_shipments.ship_to_party_id%TYPE;
  l_ship_to_cust_account_id aso_shipments.ship_to_cust_account_id%TYPE;
  l_ship_method_code	aso_shipments.ship_method_code%TYPE;

  l_ship_method		varchar2(80);

  l_ship_to_party_name	hz_parties.party_name%TYPE;
  l_ship_to_name		VARCHAR2(400);
  l_ship_to_number	VARCHAR2(70);
  l_ship_to_fax		VARCHAR2(70);
  l_ship_to_address	hz_locations.address1%TYPE;
  l_ship_to_city		hz_locations.city%TYPE;
  l_ship_to_state		hz_locations.state%TYPE;
  l_ship_to_zip		hz_locations.postal_code%TYPE;
  l_ship_to_country	hz_locations.country%TYPE;
  l_document		VARCHAR2(32000) := '';
  l_temp_str		VARCHAR2(2000):='';

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

  Cursor c_ship_methods(pCode Varchar2) IS
    Select Meaning
    from   oe_ship_methods_v
    Where  Lookup_code = pCode;

  CURSOR c_contract_header(p_id number) IS
    Select Contract_number,Contract_number_modifier
    From okc_k_headers_b
    Where ID = p_id;

  CURSOR  c_hz_parties(p_party_id NUMBER) IS
  	SELECT	Party_Name,Person_First_Name,Person_Middle_Name,Person_Last_name,party_type,Person_title
  	FROM	hz_parties
  	WHERE	party_id = p_party_id;

  CURSOR  c_hz_contact_points(p_party_id NUMBER) IS
  	SELECT Contact_Point_type,Primary_flag, Phone_line_type, Phone_Country_code, Phone_area_code, Phone_number, Email_address
  	FROM	hz_contact_points
  	WHERE	owner_table_name = 'HZ_PARTIES'
  	AND	owner_table_id = p_party_id;


  l_sold_contact_party_id		 Number;
  l_bill_contact_party_id		 Number;
  l_ship_contact_party_id		 Number;

BEGIN

  l_item_key := document_id;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteHeader - l_item_key - '||l_item_key, 1, 'Y');
	END IF;

	l_quote_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname	=> 'QUOTEID'
	);
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteHeader - l_quote_id - '||l_quote_id, 1, 'Y');
	END IF;

	l_event_type := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname   	=> 'EVENTTYPE'
	);

	l_contract_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey     => l_item_key,
		aname      => 'CONTRACTNO'
	);


	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteHeader - l_event_type - '|| l_event_type, 1, 'Y');
	END IF;

  FOR c_contract_rec In c_contract_header(l_contract_id)
  LOOP
    l_contract_number      := c_contract_rec.contract_number;
    l_contract_modifier    := c_contract_rec.contract_number_modifier;
  END LOOP;


	OPEN c_quote_header(l_quote_id);
	LOOP
		FETCH	c_quote_header INTO g_quote_header_rec;
		EXIT WHEN	c_quote_header%NOTFOUND;

		/* Get all contact information */

		l_contact_name := null;
    l_sold_contact_party_id := null;

    FOR c_hz_parties_rec IN c_hz_parties(g_quote_header_rec.party_id)
    LOOP
      IF   c_hz_parties_rec.party_type = 'PARTY_RELATIONSHIP'
      THEN
         l_contact_name   := upper(rtrim(c_hz_parties_rec.person_first_name))||' '||upper(rtrim(c_hz_parties_rec.person_last_name));

         l_sold_contact_party_id := g_quote_header_rec.party_id;
      END IF;
    END LOOP;

    IF l_sold_contact_party_id is NULL
    THEN
      FOR c_hz_cust_acct_rec IN  c_hz_cust_accounts(g_quote_header_rec.cust_account_id)
      LOOP
        l_contact_name   := upper(rtrim(c_hz_cust_acct_rec.person_first_name))||' '||upper(rtrim(c_hz_cust_acct_rec.person_last_name));
        l_sold_contact_party_id := c_hz_cust_acct_rec.party_id;
      END LOOP;
    END IF;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteHeader - l_contact_name '|| l_contact_name, 1, 'Y');
		END IF;

    l_contact_number := null;
		l_contact_email := null;

		FOR c_hz_contact_rec IN c_hz_contact_points(l_sold_contact_party_id)
		LOOP

  		IF (c_hz_contact_rec.contact_point_type =    'PHONE'
  		  AND c_hz_contact_rec.phone_line_type = 'GEN')
  		  AND (l_contact_number IS NULL OR c_hz_contact_rec.primary_flag ='Y')
  		THEN
        l_contact_number := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);
  		ELSIF c_hz_contact_rec.contact_point_type = 'EMAIL'  AND (l_contact_email IS NULL OR c_hz_contact_rec.primary_flag ='Y')
  		THEN
        l_contact_email := c_hz_contact_rec.email_address;
      END IF;
		END LOOP;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteHeader - l_contact_number - '|| l_contact_number, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - l_contact_email - '|| l_contact_email, 1, 'Y');
		END IF;

		/* Get all billing information */

		l_bill_to_party_name := null;
		l_bill_to_name := null;


                /* Bill Customer Info. From Invoice_To_Cust_Account_ID */

    FOR c_hz_cust_acct_rec IN  c_hz_cust_accounts(nvl(g_quote_header_rec.invoice_to_cust_account_id,g_quote_header_rec.cust_account_id))
    LOOP
 	    l_bill_to_party_name := rtrim(c_hz_cust_acct_rec.party_name);
      l_bill_to_name   := upper(rtrim(c_hz_cust_acct_rec.person_first_name))||' '||upper(rtrim(c_hz_cust_acct_rec.person_last_name));
      l_bill_contact_party_id := c_hz_cust_acct_rec.party_id;
    END LOOP;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteHeader - bill_party_name - '||l_bill_to_party_name, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - bill_name - '||l_bill_to_name, 1, 'Y');
		END IF;


    l_bill_to_number := null;
		l_bill_to_fax := null;

    /* Bill Contact Info. From Invoice_To_Party_ID (PARTY_RELATIONSHIP) OR Bill Customer Party Id. */

    IF g_quote_header_rec.invoice_to_party_id is NOT NULL
    THEN
      FOR c_hz_parties_rec IN c_hz_parties(g_quote_header_rec.invoice_to_party_id)
      LOOP
         IF c_hz_parties_rec.party_type = 'PARTY_RELATIONSHIP' THEN
          l_bill_contact_party_id := g_quote_header_rec.party_id;
         END IF;
      END LOOP;
    END IF;

    FOR c_hz_contact_rec IN c_hz_contact_points(l_bill_contact_party_id)
    LOOP
  		IF (c_hz_contact_rec.contact_point_type = 'PHONE' AND c_hz_contact_rec.phone_line_type = 'GEN') AND (l_bill_to_number IS NULL OR  c_hz_contact_rec.primary_flag ='Y')
  		THEN
        l_bill_to_number := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);
  		ELSIF (c_hz_contact_rec.contact_point_type = 'PHONE' AND c_hz_contact_rec.phone_line_type = 'FAX') AND (l_bill_to_fax IS NULL OR c_hz_contact_rec.primary_flag ='Y')
  		THEN
        l_bill_to_fax := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);
      END IF;
		END LOOP;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteHeader - bill_party_number - '||l_bill_to_number, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - bill_fax - '||l_bill_to_fax, 1, 'Y');
		END IF;

		l_bill_to_address := null;
		l_bill_to_city := null;
		l_bill_to_state := null;
		l_bill_to_zip := null;
		l_bill_to_country := null;

    /* Bill to Location id using invoice_to_party_site_id */

    FOR c_hz_locations_rec IN c_hz_locations(g_quote_header_rec.invoice_to_party_site_id)
    LOOP

  		l_bill_to_address := c_hz_locations_rec.loc_address;
  		l_bill_to_city := c_hz_locations_rec.loc_city;
  		l_bill_to_state := c_hz_locations_rec.loc_state;
  		l_bill_to_zip := c_hz_locations_rec.loc_zip;
  		l_bill_to_country := c_hz_locations_rec.loc_country;

		END LOOP;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteHeader - bill_address - '||l_bill_to_address, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - bill_city - '||l_bill_to_city, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - bill_state - '||l_bill_to_state, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - bill_zip - '||l_bill_to_zip, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - bill_country - '||l_bill_to_country, 1, 'Y');
		END IF;

		/* Get all shipping information */

		l_ship_to_site_id := null;
		l_ship_to_party_id := null;
		l_ship_method_code := null;

    FOR c_aso_shipments_rec IN c_aso_shipments(l_quote_id)
    LOOP
  		l_ship_to_site_id :=  c_aso_shipments_rec.ship_to_party_site_id;
  		l_ship_to_cust_account_id :=  c_aso_shipments_rec.ship_to_cust_account_id;
  		l_ship_to_party_id := c_aso_shipments_rec.ship_to_party_id;
  		l_ship_method_code := c_aso_shipments_rec.ship_method_code;
    END LOOP;

		FOR c_ship_method_rec in c_ship_methods(l_ship_method_code)
		LOOP
		  l_Ship_Method := c_ship_method_rec.Meaning;
		END LOOP;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteHeader - ship_to_site_id - '||l_ship_to_site_id, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - ship_to_party_id - '||l_ship_to_party_id, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - ship_to_method - '||l_ship_method_code, 1, 'Y');
		END IF;

    /* Shipping Customer Information - ship_to_cust_account_id */

    FOR c_hz_cust_acct_rec IN  c_hz_cust_accounts(nvl(l_ship_to_cust_account_id,g_quote_header_rec.cust_account_id))
    LOOP
      l_ship_to_party_name := rtrim(c_hz_cust_acct_rec.party_name);
      l_ship_to_name   := upper(rtrim(c_hz_cust_acct_rec.person_first_name))||' '||upper(rtrim(c_hz_cust_acct_rec.person_last_name));
      l_ship_contact_party_id := c_hz_cust_acct_rec.party_id;
    END LOOP;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteHeader - ship_to_party_name - '||l_ship_to_party_name, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - ship_to_name - '||l_ship_to_name, 1, 'Y');
		END IF;

    /* Shipping Contact ship_to_party_id(PARTY_REALTIONSHIP) OR Ship Customer's Party Id */
    IF l_ship_to_party_id IS NOT NULL
    THEN
      FOR c_hz_parties_rec IN c_hz_parties(l_ship_to_party_id)
      LOOP
        IF c_hz_parties_rec.party_type = 'PARTY_RELATIONSHIP'
        THEN
          l_ship_contact_party_id := g_quote_header_rec.party_id;
        END IF;
      END LOOP;
    END IF;

    FOR c_hz_contact_rec IN c_hz_contact_points(l_ship_contact_party_id)
    LOOP
      IF (c_hz_contact_rec.contact_point_type = 'PHONE' AND c_hz_contact_rec.phone_line_type = 'GEN')
        AND (l_ship_to_number IS NULL OR c_hz_contact_rec.primary_flag ='Y')
      THEN
         l_ship_to_number := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);
      ELSIF (c_hz_contact_rec.contact_point_type = 'PHONE' AND c_hz_contact_rec.phone_line_type = 'FAX')
        AND (l_ship_to_fax IS NULL OR c_hz_contact_rec.primary_flag ='Y')
      THEN
         l_ship_to_fax := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);
      END IF;
  	END LOOP;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteHeader - ship_to_number - '||l_ship_to_number, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - ship_to_fax - '||l_ship_to_fax, 1, 'Y');
		END IF;

		l_ship_to_address := null;
		l_ship_to_city    := null;
		l_ship_to_state   := null;
		l_ship_to_zip     := null;
		l_ship_to_country := null;

 		FOR c_hz_locations_rec IN  c_hz_locations(l_ship_to_site_id)
 		LOOP

  		l_ship_to_address := c_hz_locations_rec.loc_address;
  		l_ship_to_city    := c_hz_locations_rec.loc_city;
  		l_ship_to_state   := c_hz_locations_rec.loc_state;
  		l_ship_to_zip     := c_hz_locations_rec.loc_zip;
  		l_ship_to_country := c_hz_locations_rec.loc_country;

		END LOOP;


		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteHeader - ship_address - '||l_ship_to_address, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - ship_city - '||l_ship_to_city, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - ship_state - '||l_ship_to_state, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - ship_zip - '||l_ship_to_zip, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - ship_country - '||l_ship_to_country, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteHeader - quote_header_id - '||g_quote_header_rec.quote_header_id, 1, 'Y');
		END IF;

		IF (display_type = 'text/plain' )
		THEN
			fnd_message.set_name('ASO','ASO_TMPL_QUOTE_NAME_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||g_quote_header_rec.quote_name||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_QUOTE_NUMBER_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||g_quote_header_rec.quote_number||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_SHIP_METH_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_ship_method||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_CUST_CNTCT_INFO');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_CNTCT_NAME_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_contact_name||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_CNTCT_PHONE_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_contact_number||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_CNTCT_EMAIL_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_contact_email||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_ORD_BILL_INFO');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_CUST_NAME_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_bill_to_party_name||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_ADDRESS_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_bill_to_address||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_CITY_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_bill_to_city||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_STATE_PRO_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_bill_to_state||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_ZIP_POSTAL_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_bill_to_zip||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_COUNTRY_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_bill_to_country||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_CNTCT_NAME_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_bill_to_name||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_TEL_NO_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_bill_to_number||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_FAX_NO_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_bill_to_fax||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_ORD_SHIP_INFOR');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_CUST_NAME_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_ship_to_party_name||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_ADDRESS_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_ship_to_address||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_CITY_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_ship_to_city||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_STATE_PRO_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_ship_to_state||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_COUNTRY_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_ship_to_country||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_CNTCT_NAME_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_ship_to_name||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_TEL_NO_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_ship_to_number||NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_FAX_NO_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
			l_document := l_document || rpad(l_temp_str, 40, ' ')||l_ship_to_fax||NEWLINE;

		ELSE
				null;
		END IF;

	END LOOP;
	CLOSE c_quote_header;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteHeader - l_document'||NEWLINE|| l_document, 1, 'Y');
	END IF;

	document := l_document;
	document_type := 'text/plain';

	EXCEPTION
		WHEN OTHERS THEN
			IF c_quote_header%ISOPEN THEN
				CLOSE c_quote_header;
			END IF;
		Raise;
END GenerateQuoteHeader;



PROCEDURE GenerateQuoteDetail(
	document_id	      IN		  VARCHAR2,
	display_type	    IN		  VARCHAR2,
	document		      IN  OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	document_type	    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

  l_item_key		wf_items.item_key%TYPE;
  l_quote_id		NUMBER;
  l_event_type		VARCHAR2(20);
  l_document		VARCHAR2(32000) := '';
  l_description		mtl_system_items_kfv.description%TYPE;
  l_ship_flag		VARCHAR2(1);
  l_string_in 		VARCHAR2(250);
  l_string_out		VARCHAR2(250);
  l_string_left		VARCHAR2(250);


  l_amt_format   Varchar2(50);
  -- hyang - bug fix 2870829
  l_curr_sym     Varchar2(12);

  Cursor c_ship_flag(p_inv_item_id NUMBER,p_org_id NUMBER) IS
    SELECT 		shippable_item_flag, rtrim(description) Description
  	FROM		mtl_system_items_kfv
  	WHERE		inventory_item_id = p_inv_item_id
  	AND		organization_id = p_org_id;

  Cursor c_quote_detail (p_quote_id	NUMBER) IS
  	SELECT Inventory_item_id, Organization_id, Quantity, Line_quote_price,currency_code
          FROM Aso_quote_lines_all
  	WHERE  quote_header_id = p_quote_id
  	ORDER BY line_number;
  l_quote_line_rec		c_quote_detail%ROWTYPE;

BEGIN


  l_item_key := document_id;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteDetail - l_item_key - '||l_item_key, 1, 'Y');
	END IF;

	l_quote_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname	=> 'QUOTEID'
	);
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteDetail - l_quote_id - '||l_quote_id, 1, 'Y');
	END IF;

	l_event_type := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname	 => 'EVENTTYPE'
	);
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteDetail - l_event_type - '|| l_event_type, 1, 'Y');
	END IF;


  FOR qte_hd_rec In c_quote_header(l_quote_id)
  LOOP
    l_amt_format := FND_CURRENCY.GET_FORMAT_MASK(qte_hd_rec.Currency_code,18);
    FOR curr_sym_rec In c_curr_symbol(qte_hd_rec.Currency_code)
    LOOP
      l_curr_sym   := trim(nvl(curr_sym_rec.symbol,' '));
    END LOOP;
  END LOOP;

	OPEN c_quote_detail(l_quote_id);
	LOOP
		FETCH	c_quote_detail INTO l_quote_line_rec;
		EXIT WHEN	c_quote_detail%NOTFOUND;

		l_ship_flag := null;
		l_description := null;

		FOR c_ship_rec IN c_ship_flag(l_quote_line_rec.inventory_item_id,l_quote_line_rec.organization_id) LOOP

		l_ship_flag := c_ship_rec.shippable_item_flag;
		l_description := c_ship_rec.description;

		END LOOP;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteDetail - l_ship_flag - '|| l_ship_flag, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteDetail - l_description - '|| l_description, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteDetail - quantity - '||l_quote_line_rec.quantity, 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteDetail - price '||l_quote_line_rec.line_quote_price, 1, 'Y');
		END IF;

		l_string_in := l_description;
		l_string_out := '';
		l_string_left := '';
		ParseThisString(l_string_in,l_string_out,l_string_left);

		l_document := l_document || rpad(l_string_out, 36, ' ');
		l_document := l_document || rpad(to_char(l_quote_line_rec.quantity), 15, ' ');
		l_document := l_document || l_ship_flag;
		l_document := l_document || lpad(l_curr_sym||to_char( (l_quote_line_rec.quantity*l_quote_line_rec.line_quote_price), l_amt_format),23,' ') ||NEWLINE;

		l_string_in := l_string_left;
		WHILE  length(l_string_in) > 0  LOOP
			l_string_out := '';
			l_string_left := '';
			ParseThisString(l_string_in,l_string_out,l_string_left);
			l_document := l_document || l_string_out ||NEWLINE;
			l_string_in := l_string_left;
		END LOOP;
		l_document := l_document || NEWLINE;

	END LOOP;
	CLOSE c_quote_detail;

	document := l_document;
	document_type := 'text/plain';
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteDetail - l_document - '||NEWLINE|| l_document, 1, 'Y');
	END IF;

	EXCEPTION
		WHEN OTHERS THEN
			IF c_quote_detail%ISOPEN THEN
				CLOSE c_quote_detail;
			END IF;
		RAISE;
END GenerateQuoteDetail;

PROCEDURE GenerateQuoteFooter(
	document_id		    IN		  VARCHAR2,
	display_type		  IN		  VARCHAR2,
	document			    IN  OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	document_type		  IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

  l_item_key		wf_items.item_key%TYPE;
  l_quote_id		NUMBER;
  l_event_type		VARCHAR2(20);
  l_document		VARCHAR2(32000) := '';
  l_temp_str		VARCHAR2(2000):='';
  l_sub_total		NUMBER;


  l_amt_format   Varchar2(50);
  -- hyang - bug fix 2870829
  l_curr_sym     Varchar2(12);


BEGIN

  l_item_key := document_id;

	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteFooter - l_item_key - '||l_item_key, 1, 'Y');
	END IF;

	l_quote_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname	=> 'QUOTEID'
	);
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteFooter - l_quote_id - '||l_quote_id, 1, 'Y');
	END IF;

	l_event_type := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname	=> 'EVENTTYPE'
	);
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteFooter - l_event_type - '|| l_event_type, 1, 'Y');
	END IF;

	OPEN c_quote_header(l_quote_id);
	LOOP
		FETCH	c_quote_header INTO g_quote_header_rec;
		EXIT WHEN	c_quote_header%NOTFOUND;

    l_amt_format := FND_CURRENCY.GET_FORMAT_MASK( g_quote_header_rec.Currency_code,22);

    FOR curr_sym_rec In c_curr_symbol(g_quote_header_rec.Currency_code)
    LOOP
        l_curr_sym   := trim(curr_sym_rec.symbol);
    END LOOP;

		IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
		  aso_debug_pub.add('GenerateQuoteFooter - shipping - '||to_char(g_quote_header_rec.total_shipping_charge), 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteFooter - tax - '||to_char(g_quote_header_rec.total_tax), 1, 'Y');
		  aso_debug_pub.add('GenerateQuoteFooter - total quote price - '||to_char(g_quote_header_rec.total_quote_price), 1, 'Y');
		END IF;

		IF (display_type = 'text/plain' ) THEN


			fnd_message.set_name('ASO','ASO_TMPL_SHIP_HAND_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;

			l_document := l_document || lpad(l_temp_str,54,' ')|| ' '|| lpad(l_curr_sym||to_char(NVL(g_quote_header_rec.total_shipping_charge, 0), l_amt_format), 20, ' ')|| NEWLINE;


			fnd_message.set_name('ASO','ASO_TMPL_TAX_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;

			l_document := l_document || lpad(l_temp_str,54,' ')|| ' '|| lpad(l_curr_sym||to_char(NVL(g_quote_header_rec.total_tax, 0),l_amt_format),20,' ')|| NEWLINE;

			fnd_message.set_name('ASO','ASO_TMPL_TOTAL_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;

			l_document := l_document ||  lpad(l_temp_str,54,' ')|| ' '||  lpad(l_curr_sym|| to_char(NVL(g_quote_header_rec.total_quote_price, 0),l_amt_format),20,' ');

		ELSE
			null;
		END IF;
	END LOOP;
	CLOSE c_quote_header;

	document := l_document;
	document_type := 'text/plain';
	IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
	  aso_debug_pub.add('GenerateQuoteFooter - l_document - '||NEWLINE|| l_document, 1, 'Y');
	END IF;

	EXCEPTION
		When Others Then
			IF c_quote_header%ISOPEN THEN
				CLOSE c_quote_header;
			END IF;
		Raise;
END GenerateQuoteFooter;


PROCEDURE GetContractRef(
	document_id	      IN		  VARCHAR2,
	display_type	    IN		  VARCHAR2,
	document		      IN  OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	document_type	    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

  l_contract_number varchar2(120);
  l_contract_modifier varchar2(120);
  l_contract_ref varchar2(245);

  CURSOR c_contract_header(p_id number) IS
  Select Contract_number,Contract_number_modifier
  From okc_k_headers_b
  Where ID = p_id;

BEGIN

  FOR c_contract_rec In c_contract_header(to_number(document_id)) LOOP
    l_contract_number      := c_contract_rec.contract_number;
    l_contract_modifier    := c_contract_rec.contract_number_modifier;
    l_contract_ref 	       := l_contract_number||' '||l_contract_modifier;
  END LOOP;

  document :=  l_contract_ref;
  document_type := 'text/plain';

END GetContractRef;

PROCEDURE GetCartName(
	document_id	      IN		  VARCHAR2,
	display_type	    IN		  VARCHAR2,
	document		      IN  OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
	document_type	    IN OUT NOCOPY /* file.sql.39 change */  VARCHAR2
)
IS

  l_cart_name varchar2(50);

BEGIN

  FOR c_quote_rec In c_quote_header(to_number(document_id)) LOOP
    l_cart_name := c_quote_rec.quote_name;
  END LOOP;

  document := l_cart_name;
  document_type := 'text/plain';

END GetCartName;

END ASO_WORKFLOW_QUOTE_PVT;

/
