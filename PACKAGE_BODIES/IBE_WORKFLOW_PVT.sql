--------------------------------------------------------
--  DDL for Package Body IBE_WORKFLOW_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_WORKFLOW_PVT" AS
/* $Header: IBEVWFB.pls 120.32.12010000.13 2016/09/21 11:08:15 kdosapat ship $ */

/*
==============================================================================
| NAME
|   ibe_workflow_pvt - Procedure for all iStore alerts that will be
|                      executed using Workflow
|
| MODIFICATION HISTORY
|  07/25/00   hjaganat	Created for Account Registration
|  08/23/00   hjaganat  Modifications for Order Status Alerts
|                                       	completed
|  09/06/00   hjaganat	Modifications for Contracts completed
|  09/07/00   hjaganat	Modifications for Sales Assistance
|                                       	completed
|  10/06/00   hjaganat   Modifications for shipping and handling
|  12/05/00   hjaganat   Added additional exception handling
|  01/17/01   DKHANNA	 Modified to add cursors, profile contollable workflow,
|			 		 avoid adhoc user creation.
|  01/18/01   DKHANNA	 Improved Logic
|  01/22/01   DKHANNA	 Added suggestions by Harish
|  02/05/01   DKHANNA	 Bugfix: 1625486 - Performance
|  02/06/01   DKHANNA    Bugfix: 1625486 - Order_id - for ibe views
|  03/02/01   DKhanna    Bugfix: 1667013 - Replace order no. with web conf. no.
|  05/02/01   Dkhanna    Bugfix: 1751367 - Modified for Contract Workflow.
|  05/11/01   Dkhanna    Bugfix: 1768043 - Replaced extended_price with lines_total.
|  05/15/01   Dkhanna    Bugfix: 1783921 - Changing Subtotal defination
|  05/17/01   Dkhanna    Bugfix: 1786058 - Unable to Re-Send Contract Notification
|  06/13/01   Dkhanna    Bugfix: 1824177 - Shipment Method Code is Picked
|  07/14/01   Dkhanna    Bugfix: 1855509 - Major Change to accomodate the Map Frame Work
|  08/06/01   Dkhanna    Bugfix: 1915315 - TO_BE_SHIPPED(Y/N) IS NOT FILLED OUT
|  09/04/01   Dkhanna    Bugfix: 1971128 - SAVED CART IS NOT RETRIEVABLE
|  09/13/01   Dkhanna    Bugfix: 1993433 - Error After Filling 2ND email add. in Save Cart
|  09/17/01   Dkhanna    Bugfix: 1890460 - Currency Symbol with Amounts
|  09/13/01   Dkhanna    Bugfix: 1869219 - GLOBAL TAX Display in Order Notif.
|  02/10/01   Dkhanna    Bugfix: 2002751 - Wrong Alert When PO Opt. And No PO Num.
|  10/26/01   Ashukla	 			 - Added Method for Quote Publish
|  12/03/01   Ashukla    Bugfix: 1984683 - Getting Contact Name instead Customer Name
|  12/15/01   Ashukla    Bugfix: 2144114 - Notification error when word is bigger that 30 character
|  12/27/01   Ashukla	Bugfix: 2077446 - Add FirstName as token in IBE alerts
|  02/18/02   ljanakir   Bugfix: 2223507 - Added p_salesrep_user_id parameter
|								   for NotifyForSalesAssistance
|  03/13/02   ljanakir   Bugfix: 2111316 - Added the procedure NotifyForgetLogin
|  04/04/02   ljanakir   Bugfix: 2299210 - Modify NotifyForSharedCart to pass
|                                          in the first/last name of the sharer.
|                                          Modify procedures GetFirstName,
|								   GetLastName, GetTitle (similar to
|								   fix 2280544 done in branch)
|  05/15/02   mannamra   Enh   : 2116080 - Added a new API notify_cancel_order for
|                                          order cancellation.
|                                          Added new API to display line level details
|                                          with tax and without tax for both orders and quotes.
|                                          Added new API getfirstname_for_quote to retrieve the
|                                          first name of the owner of the quote.
|
|  05/24/02   mannamra   Bugfix: 2111316 - Modified procedure Notify_cancel_order to remove
|                                          any references to quote schema.
|                                          Added a new procedure get_contact_details_for_order
|
|  06/03/02   mannamra   Bugfix: 2380273 - Replaced HZ_PARTY_RELATIONSHIPS
|                                          with HZ_RELATIONSHIPS to improve query
|                                          performance.
|  06/10/02   mannamra   Bugfix: 2387181 - During cancel_order value for sold_to_contact is not
|                                          available in oe_order_headers_all table for some orders,
|                                          so using the value in last_updated_by column
|                                          to identify the appropriate recipient of
|                                          the cancel order notification.
|  06/18/02   mannamra   Bugfix: 2417011 - Obsoleted getfirstname_for_quote API because
|                                          getfirstname solves the purpose.
|  08/20/02   mannamra   Bugfix: 2426274 - Orders with KIT items should not show 'INCLUDED'
|                                          items, though their prices should be rolled up to
|                                          the KIT level.
|  09/06/02   mannamra   Bugfix: 2552417 - Notification shows two lines for a single line in
|                                          order
|  09/27/02   batoleti                     Added Notify_End_Working notification procedure
|  10/01/02   batoleti                     Added Notify_Finish_Sharing notification procedure
|  10/04/02   batoleti                     Added Notify_Shared_Cart  notification procedure
|  10/07/02   batoleti                     Added Notify_Access_Change notification procedure
|  12/12/02   SCHAK      Bug # 2691704     Modified for NOCOPY Changes.
|  01/16/03   mannamra   Enh   : 2745338 - Added API set_item_attributes and identify_cart_quote
|                                          Also included a fix to send access_change notif to B2C
|                                          users.
|  07/24/03   batoleti                     Added NotifyReturnOrderStatus notification procedure
/  8/26/03   abhandar                     changed getUserType(),Get_Name_Details()and NotifyRegistration()
/                                         Added Generate_Approval_Msg()
| 12/11/2003 3192506 IBE_USE_WORKFLOW profile Obsoletion
| 12/23/03   batoleti   Bug#3313522       Commented the IF (display_type = 'text/plain' ) checking conditions.
| 12/23/03   batoleti   Bug#3334542       Added billing address for B2C return order notifications.
| 12/29/03   batoleti   Bug#3325710       Added view Netprice token to order confirmation notification
|                                         sent to sharee.
| 12/30/03   mannamra    Bug#3319902      View shared cart should display 'owner' as a role.
| 01/14/04   batoleti    Bug#3342929      Added IBE_UTIL.nls_number_format function call for quantity and amount values
|                                         in istore workflow notification procedures.
| 01/19/04   batoleti    Bug#3378966      In Return order notification, the INCLUDED items are not shown.
| 01/29/04   batoleti    Bug#3348583      In Return order notification, order number should not be shown for the
|                                         child items.
| 02/05/04   mannamra    Bug#3316860      HTML enabled tokens with PL/SQL callbacks.
| 30/11/04   Knachiap    Bug#4031180      SetOrderId for OrderNotBooked Notification
| 06/12/04   Knachiap    Bug#4031180      OrderConf Notification to Recipient
| 07/12/04   abairy      Bug#4049509      Customised Approval Message Keys for Customised UserTypes
| 02/27/05   abairy      Bug #4184705     removed wrong usage of organization party number as orgId
| 01/May/05  Knachiap    MACD Notification Change for Cart/Checkout
| 06/02/05   abairy	 		  Added Generate_Credential_Msg procedure
| 07/18/05   banatara    Added the m_site_type='I' check for the ibe_msites table cursors
| 07/21/05   Knachiap    MOAC Fix
| 07/29/05   banatara    Removed the m_site_type='I' check for the ibe_msites table cursors
| 19/08/05   Knachiap    MOAC Changes
| 24/08/05   Knachiap    MOAC Changes - Client Info
| 09/06/05   abairy      Setting party number as the value for ORGNUM token in NotifyRegistration
|                        Changed Generate_credential_msg to only ignore password. Username shall always be shown.
|  14/Nov/05  Knachiap   Line Type for Quote
|  16/Nov/05  Knachiap   MACD Footer fixes
|  14/Dec/05  Knachiap   4774306 - SQL Perf Fixes
|  06/Jun/06  aannamal  5260544 - Fix to have negative amounts within angular brackets
|  19/Sep/06  aannamal  5480501 - Made changes to display correct line amount in Order confirmation Notification
|  08/May/09  ukalaiah  6877589 - WRONG WORKFLOW NOTIFICATION BEING FIRED FOR CREDIT CARD ORDERS
|  26/Jun/09  scnagara  8337371 - For NotifyReturnOrderStatus, passed the return order minisite id to
|					IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
|  1/Jul/09  scnagara  7720550 - For NotifyReturnOrderStatus and Notify_cancel_order,
|				 passed the current org Id to Retrieve_Msg_Mapping
| 23-AUG-2010 amaheshw 10016159 Replace IBY_TRXN_EXTENSIONS_V with IBY_EXTN_INSTR_DETAILS_VREM
| 23-MAY-2011 ytian 12573026 Modified buildDocument function to increase the VARCHAR2 size to 495.
| 07-MAY-2012 scnagara 13767382 procedure get_sales_assist_rsn_meaning - changed to use aso_lookups view
| 28-Mar-2013 nsatyava 13363458 & 16662526 1OFF:10009907:R12.IBE.B.3:12.1.3:OOB ORDER CONFIRMATION EMAIL ALIGNMENT ISSUE
| 19-Jun-2013 kdosapat 16930708 - ORDER CONFIRMATION EMAIL HAS THE INCORRECT SHIP TO NAME
| 15-NOV-2013 kdosapat 17230423 - ORDER CONFIRMATION EMAIL HAS THE BLANK SHIP TO NAME
| 26-AUG-2016 kdosapat 5917800  - INCONSISTENCY IN ISTORE BETWEEN MAILHTML AND MAILTEXT NOTIFICATIONS-P1
==============================================================================================
*/
l_true VARCHAR2(1)          := FND_API.G_TRUE;
g_ItemType	Varchar2(10) := 'IBEALERT';
g_processName Varchar2(30)  := 'PROCESSMAP';


GET_MESSAGE_ERROR  EXCEPTION;

Cursor c_ship_methods(pCode Varchar2) IS
  Select Meaning
  from   oe_ship_methods_v
  Where  Lookup_code = pCode;

  Cursor c_order_header (c_order_id NUMBER) IS
SELECT oh.ordered_date,
       oh.order_number,
       sold_to_party.party_name customer_name,
       oe_totals_grp.Get_Order_Total(oh.header_id,null,'ALL')order_total,
       oe_totals_grp.Get_Order_Total(oh.header_id,null,'CHARGES')charges_total,
       oe_totals_grp.Get_Order_Total(oh.header_id,null,'TAXES')taxes_total,
       oe_totals_grp.Get_Order_Total(oh.header_id,null,'LINES')lines_total,
       sold_to_party.party_id,
       oh.payment_type_code,
       oh.cust_po_number,
       substr(oh.credit_card_number,(length(oh.credit_card_number)-3),4)credit_card_number,
       oh.orig_sys_document_ref web_confirm_number,
       oh.shipping_method_code,
       oh.minisite_id,         -- bug 8337371, scnagara
       shipaddr.address1 ship_to_address1,
       shipaddr.address2 ship_to_address2,
       shipaddr.address3 ship_to_address3,
       shipaddr.address4 ship_to_address4,
       shipaddr.city ship_to_city,
       shipaddr.state ship_to_state,
       shipaddr.postal_code ship_to_postal_code,
       shipaddr.country ship_to_country,
       invaddr.address1 bill_to_address1,
       invaddr.address2 bill_to_address2,
       invaddr.address3 bill_to_address3,
       invaddr.address4 bill_to_address4,
       invaddr.city bill_to_city,
       invaddr.state bill_to_state,
       invaddr.postal_code bill_to_postal_code,
       invaddr.country bill_to_country,
       oh.transactional_curr_code
from   oe_order_headers_all oh,
       hz_parties sold_to_party,
       hz_cust_accounts sold_to_account,
       hz_locations shipaddr,
       hz_party_sites shp_party_site,
       hz_cust_acct_sites_all shp_acct_site,
       hz_cust_site_uses_all shp_site_use,
       hz_locations invaddr,
       hz_party_sites inv_party_site,
       hz_cust_acct_sites_all inv_acct_site,
       hz_cust_site_uses_all inv_site_use
where  oh.header_id=c_order_id
       and sold_to_party.party_id= sold_to_account.party_id
       and sold_to_account.cust_account_id = oh.sold_to_org_id
       and oh.ship_to_org_id=shp_site_use.site_use_id(+)
       and shp_site_use.cust_acct_site_id=shp_acct_site.cust_acct_site_id(+)
       and shp_acct_site.party_site_id=shp_party_site.party_site_id(+)
       and shp_party_site.location_id=shipaddr.location_id(+)
       and oh.invoice_to_org_id=inv_site_use.site_use_id(+)
       and inv_site_use.cust_acct_site_id=inv_acct_site.cust_acct_site_id(+)
       and inv_acct_site.party_site_id=inv_party_site.party_site_id(+)
       and inv_party_site.location_id=invaddr.location_id(+);

g_header_rec	c_order_header%ROWTYPE;

/*16930708 -  defining cursors to get SHIP_TO_PARTY_ID and PARTY_TYPE - start  */

/*17230423 - modified cursor c_get_shipTo_party_id for this bug fix
Cursor c_get_shipTo_party_id(p_quote_id NUMBER) is
  select SHIP_TO_PARTY_ID
  from aso_shipments
  where QUOTE_HEADER_ID = p_quote_id and QUOTE_LINE_ID is null; */

Cursor c_get_shipTo_party_id(p_quote_id NUMBER) is
  select nvl(SHIP_TO_PARTY_ID, ship_to_cust_party_id)
  from aso_shipments
  where QUOTE_HEADER_ID = p_quote_id and QUOTE_LINE_ID is null;

Cursor c_get_shipTo_party_type(p_shipTo_partyId NUMBER) is
  select PARTY_TYPE
  from hz_parties
  where PARTY_ID = p_shipTo_partyId;
  /* 16930708 - defining cursors to get SHIP_TO_PARTY_ID and PARTY_TYPE - end  */

Cursor c_order_detail(p_order_id  NUMBER) IS
SELECT ol.line_id,
       ol.item_type_code,
       ol.top_model_line_id,
       ol.link_to_line_id,
       msi.description item_description,
       ol.ordered_quantity,
       oe_totals_grp.Get_Order_Total(ol.header_id,ol.line_id,'LINES') lines_total,
       oe_totals_grp.Get_Order_Total(ol.header_id,ol.line_id,'TAXES') taxes_total,
       oe_totals_grp.Get_Order_Total(ol.header_id,ol.line_id,'CHARGES') charges_total,
       oe_totals_grp.Get_Order_Total(ol.header_id,ol.line_id,'ALL') extended_price
FROM   oe_order_lines_all ol, mtl_system_items_tl msi
WHERE  ol.header_id = p_order_id
       and ol.inventory_item_id = msi.inventory_item_id
       and msi.organization_id = oe_profile.value('OE_ORGANIZATION_ID', ol.org_id)
       and msi.language = userenv('LANG')
ORDER BY line_number, shipment_number,nvl(option_number,-1), nvl(component_number,-1), nvl(service_number,-1);

Cursor c_contract_rep (p_org_id NUMBER) IS
  Select ORG_INFORMATION1 Contract_Rep,
         ORG_INFORMATION2 Sales_Rep,
         ORG_INFORMATION3 CustCare_Rep
  From hr_organization_information
  where org_information_context = 'DEFAULT_NOTIFICATION_USER'
  And   organization_id = p_org_id;

Cursor c_contract_header(p_id number) IS
  Select Contract_number,Contract_number_modifier
  From okc_k_headers_b
  Where ID = p_id;

g_detail_rec	c_order_detail%ROWTYPE;

Cursor c_quote_header (p_quote_id 	NUMBER) IS
  SELECT org_id,
         party_id,
         quote_name,
         quote_number,
         quote_version,
         quote_password,
         cust_account_id,
         invoice_to_party_id,
         invoice_to_party_site_id,
         quote_header_id,
         ordered_date,
         order_id,
         total_list_price,
         total_shipping_charge,
         total_tax,
         total_quote_price,
         invoice_to_cust_account_id,
         total_adjusted_amount,
         currency_code,
         resource_id
    FROM aso_quote_headers_all
	WHERE  quote_header_id = p_quote_id;
  g_quote_header_rec  c_quote_header%ROWTYPE;

  Cursor c_quote_detail (p_quote_id	NUMBER) IS
    SELECT Inventory_item_id,
           Organization_id,
           Quantity,
           Line_quote_price,
           currency_code
    FROM Aso_quote_lines_all
	WHERE  quote_header_id = p_quote_id
	ORDER BY line_number;
  g_quote_line_rec		c_quote_detail%ROWTYPE;


  Cursor c_quote_payment (p_quote_id	NUMBER) IS
    SELECT  Payment_type_code
    FROM    Aso_Payments
    WHERE   quote_header_id = p_quote_id;

  Cursor  c_hz_parties(c_party_id NUMBER) IS
    SELECT    Party_Name,
              Person_First_Name,
              Person_Middle_Name,
              Person_Last_name,
              party_type,
              Person_title
	  FROM	  hz_parties
	  WHERE	  party_id = c_party_id;

  Cursor  c_hz_contact_points(p_party_id NUMBER) IS
    SELECT Contact_Point_type,
           Primary_flag,
           Phone_line_type,
           Phone_Country_code,
           Phone_area_code,
           Phone_number,
           Email_address
	FROM   hz_contact_points
	WHERE  owner_table_name = 'HZ_PARTIES'
	AND	owner_table_id = p_party_id;

  cursor c_order_curr_code(c_order_id number) is
    select transactional_curr_code
    from   oe_order_headers_all
    where  header_id = c_order_id;
  rec_order_curr_code  c_order_curr_code%rowtype;

  cursor c_curr_symbol(p_currCode VARCHAR2) IS
    SELECT fc.symbol
    FROM FND_CURRENCIES fc
    WHERE fc.currency_code = p_currCode;

   Cursor c_get_source_code(p_quote_id NUMBER) is
     select quote_source_code
     from aso_quote_headers_all
     where quote_header_id = p_quote_id;

  g_curr_sym   FND_CURRENCIES.SYMBOL%TYPE;
  g_amt_format  VARCHAR2(20);

  NEWLINE  VARCHAR2(1) := fnd_global.newline;
  TAB      VARCHAR2(1) := fnd_global.tab;


/*Procedure getUserType(pPartyId  IN Varchar2,
                      pUserType OUT NOCOPY Varchar2) IS
    l_PartyType  Varchar2(30);
    l_UserType   jtf_um_usertypes_b.usertype_key%type := 'B2B';
  BEGIN
    ----DBMS_OUTPUT.PUT('Into getusertype party_id is: '||ppartyid);
    FOR c_hz_parties_rec IN c_hz_parties(pPartyId)  LOOP
      ----DBMS_OUTPUT.PUT('Opened the cursor loop');

      l_PartyType  := rtrim(c_hz_parties_rec.party_type);
      ----DBMS_OUTPUT.PUT('party_type is: '||l_partytype);
    END LOOP;

    If l_PartyType = 'PERSON' Then
      l_userType  := 'B2C';
  End If;

     pUserType  :=  l_userType;

END getUserType;
*/

/*Returns the mail format preference of the mail recipient*/

/*PROCEDURE get_mail_format_pref(p_user_name IN  VARCHAR2,
                               x_mail_pref OUT VARCHAR2) is

cursor c_get_pref(c_user VARCHAR2) is
  SELECT name,
       notification_preference
  FROM wf_roles
  WHERE name = c_user;
rec_get_pref c_get_pref%rowtype;
l_mail_pref VARCHAR2(100);

BEGIN
  FOR rec_get_pref in c_get_pref(p_user_name) LOOP
    x_mail_pref := rec_get_pref.notification_preference;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('get_mail_format_pref: Mail preference: '|| x_mail_pref);
    END IF;
    EXIT when c_get_pref%NOTFOUND;
  END LOOP;
END;*/

Procedure getUserType(pPartyId  IN NUMBER,
                      pUserType OUT NOCOPY Varchar2) IS

    l_api_name   CONSTANT VARCHAR2(30) :='getUserType';
    l_PartyType  HZ_PARTIES.PARTY_TYPE%type :='';
    l_UserType   jtf_um_usertypes_b.usertype_key%type :='ALL';
    l_user_name  FND_USER.USER_NAME%type;
    l_is_pv_partner boolean :=false;
    l_is_int_primary_user boolean:=false;
    plsql_block VARCHAR2(500);
    pv_flag VARCHAR2(1):='N';

  -- check for user id exists in jtf_um_usertype_reg table
  -- if not then use the permissions logic to retrieve the user type else return ALL
  -- The new user type supported out of the box are :
  -- IBE_INDIVIDUAL, IBE_BUSINESS, IBE_PRIMARY, IBE_PARTNER, IBE_PARTNER_PRIMARY.
  --
   -- cursor to retrieve user type from jta tables
   Cursor c_get_user_type(c_party_id NUMBER) IS
    select b.usertype_key
    from jtf_um_usertype_reg a,jtf_um_usertypes_b b, fnd_user c , hz_parties d
    where a.usertype_id=b.usertype_id and c.user_id = a.user_id
    and d.party_id = c.customer_id and b.application_id=671
    and d.party_id = c_party_id;

   -- Cursor to get the party type , user name from fnd and hz tables
    Cursor c_get_party_type_user_name(c_party_id NUMBER) IS
    select d.party_type,c.user_name
    from fnd_user c , hz_parties d
    where d.party_id=c.customer_id
    and d.party_id=c_party_id;

  BEGIN

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('start: getUserType' ||':partyid='||pPartyId);
    END IF;

   open c_get_user_type(pPartyId);

   fetch c_get_user_type into l_UserType;

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('getUserType:After fetch' ||'l_UserType='||l_UserType);
    END IF;

   IF (c_get_user_type%NOTFOUND) THEN
    -- user not created thru the new JTA UM functionality
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('getUserType:' ||'l_UserType not found in jta tables');
     END IF;
     open c_get_party_type_user_name(pPartyId);
     fetch c_get_party_type_user_name into l_PartyType,l_user_name;
     CLOSE c_get_party_type_user_name;

     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('getUserType:' ||'l_PartyType='||l_PartyType);
     END IF;

     if (l_PartyType='PERSON') then
          l_userType:='IBE_INDIVIDUAL';
     else
         l_is_int_primary_user := IBE_UTIL.check_jtf_permission('IBE_INT_PRIMARY_USER',l_user_name);
       --  l_is_pv_partner := IBE_UTIL.check_jtf_permission('PV_PARTNER',l_user_name);

  -----------------------------------------------------------
  -- checking the PV_PARTNER permission thru a sql package
        BEGIN

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('getUserType:Before calling PV_USER_MGMT_PVTS.is_partner_user');
          END IF;

          plsql_block := 'BEGIN :pvFlag:=PV_USER_MGMT_PVT.is_partner_user(:partyId);END;';
          EXECUTE IMMEDIATE plsql_block USING OUT pv_flag,pPartyId;

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('getUserType:After calling PV_USER_MGMT_PVTS: value of permission='||pv_flag);
          END If;
        EXCEPTION
        WHEN OTHERS THEN
          --set partner permission to 'N'
          pv_flag := 'N';
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('getUserType: The This is a standalone iStore installation,with no PRM integration, hence the dynamic call to retrieve the PRM usertypes throws following exception,please ignore it');
             IBE_UTIL.DEBUG('getUserType:sqlcode='||sqlcode||' :sqlerr='|| sqlerrm);
             IBE_UTIL.DEBUG('getUserType:Reminder:Please ignore the above sql exception,there is no error here.It is an expected behaviour as per the code logic.');
        END IF;
     END;
     if pv_flag='Y' then
              l_is_pv_partner:=true;
         else
              l_is_pv_partner:=false;
         end if;
-------------------------------------------------
         if (l_is_pv_partner=true) THEN
            if (l_is_int_primary_user=true) then
               l_userType:='IBE_PARTNER_PRIMARY';
            else
               l_userType:='IBE_PARTNER_BUSINESS';
            end if;
         else -- partner is false
           if (l_is_int_primary_user=true) then
               l_userType:='IBE_PRIMARY';
            else
               l_userType:='IBE_BUSINESS';
            end if;
         END IF;
       END IF;
      END IF;
   CLOSE c_get_user_type;
   pUserType:=l_userType;
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('getUserType:' ||'pUserType='||pUserType);
   END IF;

END getUserType;

Procedure identify_cart_quote(p_quote_header_id IN NUMBER
                             ,x_is_it_quote     OUT NOCOPY VARCHAR2) is
cursor c_get_cart_type(c_quote_header_id NUMBER) is
select resource_id
from aso_quote_headers_all
where quote_header_id = c_quote_header_id;

rec_get_cart_type c_get_cart_type%rowtype;
l_is_it_quote     VARCHAR2(1) := fnd_api.g_false;
BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Identify_cart_quote: Start');
    IBE_UTIL.DEBUG('Identify_cart_quote:inout quote_header_id: '||p_quote_header_id);
  END IF;
  For rec_get_cart_type in c_get_cart_type(p_quote_header_id) LOOP
    IF (rec_get_cart_type.resource_id is not null) THEN
      l_is_it_quote := FND_API.G_TRUE;
    END IF;
    EXIT  when c_get_cart_type%notfound;
  END LOOP;
  x_is_it_quote := l_is_it_quote;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Identify_cart_quote:X_is_it_quote: '||x_is_it_quote);
  END IF;

END;

Procedure create_adhoc_entity
          ( p_quote_recipient_id      IN NUMBER  := FND_API.G_MISS_NUM
           ,p_quote_header_id         IN NUMBER  := FND_API.G_MISS_NUM
           ,p_email_address           IN VARCHAR2:= FND_API.G_MISS_CHAR
           ,p_Notification_preference IN VARCHAR2:= FND_API.G_MISS_CHAR
           ,x_adhoc_role              OUT NOCOPY VARCHAR2) is

l_adhoc_user         VARCHAR2(2000);
l_adhoc_user_display VARCHAR2(2000);
l_role_users         VARCHAR2(2000);
l_adhoc_role         VARCHAR2(2000);
l_adhoc_role_display VARCHAR2(2000);

BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Create_adhoc_entity:Start');
    IBE_UTIL.DEBUG('Create_adhoc_entity:Input recipient_id: '||p_quote_recipient_id);
    IBE_UTIL.DEBUG('Create_adhoc_entity:Input QUOTE_HEADER_ID: '||p_quote_header_id);
    IBE_UTIL.DEBUG('Create_adhoc_entity:Input email address: '||p_email_address);
  END IF;

  l_adhoc_user := 'SCU'||p_QUOTE_recipient_id
                       ||'Q'||p_quote_header_id||to_char(sysdate,'MMDDYYHH24MISS');
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Create_adhoc_entity:l_adhoc_user: '||l_adhoc_user);
  END IF;

  l_adhoc_user_display := 'SCU'||p_QUOTE_recipient_id
                               ||'Q'||p_quote_header_id||to_char(sysdate,'MMDDYYHH24MISS');

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Create_adhoc_entity:Creating adhoc user');
  END IF;
  wf_directory.CreateAdHocUser(
      name                    => l_adhoc_user              ,
      display_name            => l_adhoc_user_display      ,
      notification_preference => p_notification_preference ,
      email_address 	      => p_email_address           ,
      expiration_date         => sysdate + 1);


  l_role_users         := l_adhoc_user;

  l_adhoc_role         := 'SCR'||p_QUOTE_recipient_id
                               ||'Q'||p_quote_header_id||to_char(sysdate,'MMDDYYHH24MISS');
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Create_adhoc_entity:l_adhoc_role: '||l_adhoc_role);
  END IF;

  l_adhoc_role_display := 'SCR'||p_QUOTE_recipient_id
                               ||'Q'||p_quote_header_id||to_char(sysdate,'MMDDYYHH24MISS');
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Create_adhoc_entity:Creating ad-hoc role');
  END IF;

  wf_directory.CreateAdHocRole
       (role_name              => l_adhoc_role,
        role_display_name       => l_adhoc_role_display,
        notification_preference => p_notification_preference,
        role_users              => l_role_users,
        expiration_date         => sysdate + 1);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Create_adhoc_entity:x_adhoc_role: '||x_adhoc_role);
  END IF;
  x_adhoc_role := l_adhoc_role;
END;



procedure set_item_attributes
                  ( p_item_key          IN VARCHAR2
                   ,p_message_name      IN VARCHAR2
                   ,p_access_level      IN VARCHAR2 :=FND_API.G_MISS_CHAR
                   ,p_old_access_level  IN VARCHAR2 :=FND_API.G_MISS_CHAR
                   ,p_recipient_number  IN VARCHAR2 :=FND_API.G_MISS_CHAR
                   ,p_first_name        IN VARCHAR2
                   ,p_last_name         IN VARCHAR2
                   ,p_url               IN VARCHAR2 :=FND_API.G_MISS_CHAR
                   ,p_minisite_id       IN VARCHAR2
                   ,p_cart_name         IN VARCHAR2
                   ,p_adhoc_role        IN VARCHAR2 :=FND_API.G_MISS_CHAR
                   ,p_context_msg       IN VARCHAR2 :=FND_API.G_MISS_CHAR
                   ,p_notes             IN VARCHAR2 :=FND_API.G_MISS_CHAR
                   ,p_notif_context     IN VARCHAR2 ) is

l_item_owner WF_USERS.NAME%TYPE   := 'SYSADMIN';
l_temp_retrieve_str Varchar2(2000);
L_temp_update_str   Varchar2(2000);


BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes: Start');
    IBE_UTIL.DEBUG('Set_item_attributes:Input messsage name: '||p_message_name);
    IBE_UTIL.DEBUG('Set_item_attributes:retrieval_number: '||p_recipient_number);
    IBE_UTIL.DEBUG('Set_item_attributes:old_access_level: '||p_old_access_level);
    IBE_UTIL.DEBUG('Set_item_attributes:URL: '||p_url);
    IBE_UTIL.DEBUG('Set_item_attributes:context message: '||p_context_msg);
    IBE_UTIL.DEBUG('Set_item_attributes:msiteid: '||p_minisite_id);
    IBE_UTIL.DEBUG('Set_item_attributes:cartname: '||p_cart_name);
    IBE_UTIL.DEBUG('Set_item_attributes:first_name: '||p_first_name);
    IBE_UTIL.DEBUG('Set_item_attributes:last_name: '||p_last_name);
    IBE_UTIL.DEBUG('Set_item_attributes:p_item_key: '||p_item_key);
    IBE_UTIL.DEBUG('Set_item_attributes:p_notes: '||p_notes);
    IBE_UTIL.DEBUG('Set_item_attributes:Wf_engine.create_process: START');
  END IF;

  wf_engine.CreateProcess(
     itemtype  => g_ItemType,
     itemkey   => p_item_key,
     process   => g_processName);

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done creating process');
  END IF;

      wf_engine.SetItemUserKey(
        itemtype => g_ItemType,
        itemkey  => p_item_key,
        userkey  => p_item_key);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemUserKey');
  END IF;

      wf_engine.SetItemAttrText(
        itemtype => g_ItemType,
        itemkey  => p_item_key,
        aname    => 'MESSAGE',
        avalue   => p_Message_Name);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for MESSAGE');
  END IF;

      wf_engine.SetItemAttrText(
        itemtype => g_ItemType,
        itemkey  => p_item_key,
        aname	 => 'MSITEID',
        avalue   => p_minisite_id);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for MSITEID');
  END IF;

      wf_engine.SetItemAttrText(
        itemtype => g_ItemType,
        itemkey  => p_item_key,
        aname    => 'CARTNAME',
        avalue   => p_cart_name);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for CARTNAME');
  END IF;

      IF((p_first_name is not null) and
         (p_first_name <> FND_API.G_MISS_CHAR)) THEN
        wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => p_item_key,
          aname     => 'FIRSTNAME',
          avalue    => p_first_name);
      END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for FIRSTNAME');
  END IF;

      IF((p_last_name is not null) and
         (p_first_name <> FND_API.G_MISS_CHAR)) THEN
        wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => p_item_key,
          aname     => 'LASTNAME',
          avalue    => p_last_name);
      END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for LASTNAME');
  END IF;
      IF((p_notes is not null) and
         (p_notes <> FND_API.G_MISS_CHAR)) THEN
        wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => p_item_key,
          aname     => 'SHARECOMMENTS',
          avalue    => p_notes);
      END IF;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for COMMENTS');
  END IF;

  IF((p_notif_context = 'SHARECARTNOTIF') OR
     (p_notif_context = 'SHARECARTNOTIF_B2B')OR
     (p_notif_context = 'SHAREQUOTENOTIF') OR
     (p_notif_context = 'SHAREQUOTENOTIF_B2B') OR
     (p_notif_context = 'CHANGEACCESSLEVEL') OR
     (p_notif_context = 'CHANGEACCESSLEVEL_QUOTE')) THEN

        wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => p_item_key,
          aname    => 'ACCESSCODE',
          avalue   => p_access_level);
      END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for ACCESSLEVEL');
  END IF;


      IF((p_notif_context <> 'STOPWORKING' ) AND
          (p_notif_context <> 'STOPWORKING_QUOTE' )) THEN

        wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => p_item_key,
          aname     => 'ISTOREURL',
          avalue    => p_url);
      END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for URL');
  END IF;


      IF ((p_notif_context = 'STOPWORKING' ) OR
          (p_notif_context = 'STOPWORKING_QUOTE' ))THEN
        wf_engine.SetItemAttrText(
              itemtype => g_ItemType,
              itemkey  => p_item_key,
              aname    => 'CONTEXT_CODE',
              avalue   => p_context_msg);
      END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for CONTEXT_MESSAGE');
  END IF;

      IF ((p_notif_context = 'CHANGEACCESSLEVEL') OR
          (p_notif_context = 'CHANGEACCESSLEVEL_QUOTE')) THEN
        wf_engine.SetItemAttrText(
              itemtype => g_ItemType,
              itemkey  => p_item_key,
              aname    => 'ACCESSCODE_OLD',
              avalue   => p_old_access_level);
      END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for OLDACCESSLEVEL');
  END IF;

      IF((p_notif_context = 'SHARECARTNOTIF') OR
         (p_notif_context = 'SHARECARTNOTIF_B2B')OR
    	    (p_notif_context = 'CHANGEACCESSLEVEL')) THEN

        l_temp_update_str := 'IBE_PRMT_UPDATE_CART';

        wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => p_item_key,
          aname    => 'UPDATEMSG_CODE',
          avalue   => l_temp_update_str);
      END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for UPDATEMSG');
  END IF;

      IF ((p_notif_context = 'SHARECARTNOTIF') OR
           (p_notif_context = 'SHAREQUOTENOTIF'))THEN

        -- Retrieve the message text for retrieve message from fnd_messages
        --fnd_message.set_name('IBE','IBE_PRMT_SC_RETRIEVE');
        l_temp_retrieve_str := 'IBE_PRMT_SC_RETRIEVE';
        --l_temp_retrieve_str := fnd_message.get;

        wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => p_item_key,
          aname    => 'RETRIEVEMSG_CODE',
          avalue   => l_temp_retrieve_str);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for RETRIEVEMSG');
  END IF;

       wf_engine.SetItemAttrText(
        itemtype  => g_ItemType,
        itemkey   => p_item_key,
        aname     => 'SHNUM',
        avalue    => p_recipient_number);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for SHNUM');
  END IF;

      END IF;


      wf_engine.SetItemAttrText(
        itemtype => g_ItemType,
        itemkey  => p_item_key,
        aname    => 'SENDTO',
        avalue   => p_adhoc_role);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemAttribute for SENDTO');
  END IF;

      wf_engine.SetItemOwner(
        itemtype  => g_ItemType,
        itemkey   => p_item_key,
        owner     => l_item_owner);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done setItemOwner');
  END IF;

      wf_engine.StartProcess(
         itemtype  => g_ItemType,
         itemkey   => p_item_key);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Done StartProcess');
  END IF;
EXCEPTION
When OTHERS THEN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('Set_item_attributes:Exception block: '||SQLCODE||': '||SQLERRM);
  END IF;
  RAISE;
END ;



/*PROCEDURE Get_Name_details(p_party_id           IN  HZ_PARTIES.PARTY_ID%TYPE,
                           p_user_type          IN  VARCHAR2,
                           p_sharee_number      IN  NUMBER  := FND_API.G_MISS_NUM,
                           x_contact_first_name OUT NOCOPY HZ_PARTIES.PERSON_FIRST_NAME%TYPE,
                           x_contact_last_name  OUT NOCOPY HZ_PARTIES.PERSON_LAST_NAME%TYPE,
                           x_party_id           OUT NOCOPY HZ_PARTIES.PARTY_ID%TYPE) IS

  l_usertype               jtf_um_usertypes_b.usertype_key%type;
  l_contact_first_name     HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
  l_contact_last_name      HZ_PARTIES.PERSON_LAST_NAME%TYPE;
  l_partyid                HZ_PARTIES.PARTY_ID%TYPE;

  CURSOR c_get_recepient_name(p_party_id number) IS
         SELECT person_first_name, person_last_name
         FROM hz_parties
         WHERE party_id = p_party_id;

  rec_get_recepient_name c_get_recepient_name%rowtype;

 CURSOR b2b_contact_info(p_party_id number) IS
 SELECT p.person_first_name,
        p.person_last_name,
        p.party_id
 FROM   hz_relationships l,
        hz_parties p
 WHERE l.party_id   = p_party_id
   AND l.subject_id   = p.party_id
   AND l.subject_type = 'PERSON'
   AND l.object_type  = 'ORGANIZATION';
  rec_party_info b2b_contact_info%rowtype;

BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN

    ibe_util.debug('get_name_details:input user_type: '||p_user_type);
    ibe_util.debug('get_name_details:input party_id: '||p_party_id);
    ibe_util.debug('get_name_details:input sharee number: '||p_sharee_number);
  END IF;


          IF ((p_user_type = FND_API.G_MISS_CHAR)
              OR (p_user_type = null)) THEN
               -- User Type of the owner
               getUserType(p_party_Id,l_UserType);
          ELSE
               l_userType := p_user_type;
          END IF;
           IF (l_userType = 'B2B') THEN

               FOR rec_party_info IN b2b_contact_info(p_party_id)
               LOOP
                  x_Contact_First_Name := rec_party_info.person_first_name;
                  x_Contact_last_name  := rec_party_info.person_last_name;
                  x_party_id           := rec_party_info.party_id;
               END LOOP;
           ELSE
             x_party_id  :=  p_party_id;
             IF ((p_party_id is not null) or (p_party_id  <> fnd_api.g_miss_num)) THEN
                FOR rec_get_recepient_name IN c_get_recepient_name(p_party_id )
                LOOP
                   x_contact_first_name := rec_get_recepient_name.person_first_name;
                   x_contact_last_name := rec_get_recepient_name.person_last_name;
                END LOOP;
             END IF;
           END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN

    ibe_util.debug('get_name_details:output first_name: '||x_contact_first_name);
    ibe_util.debug('get_name_details:input last_name: '||x_contact_first_name);
  END IF;

END Get_Name_details;
*/
/********************************************************
Get_Name_Details: Here the input parameters are:
                  party_id, User type.

This procedure is responsible to retrive the
First name, last name of the person.
********************************************************/
--modified by abhandar for 11.5.10
--Modification : If  party_type= person then
--retrieve name from the HZ_PARTY, else retrieve from the HZ_Relationship and HZ_Part tables .

PROCEDURE Get_Name_details(p_party_id         	IN  HZ_PARTIES.PARTY_ID%TYPE,
                           p_user_type          	IN  VARCHAR2,
                           p_sharee_number      	IN  NUMBER  := NULL,
                           x_contact_first_name 	OUT NOCOPY HZ_PARTIES.PERSON_FIRST_NAME%TYPE,
                           x_contact_last_name  	OUT NOCOPY HZ_PARTIES.PERSON_LAST_NAME%TYPE,
                           x_party_id           	OUT NOCOPY HZ_PARTIES.PARTY_ID%TYPE) IS

  l_usertype              	jtf_um_usertypes_b.usertype_key%type;
  l_contact_first_name     	HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
  l_contact_last_name      	HZ_PARTIES.PERSON_LAST_NAME%TYPE;
  l_partyid                 HZ_PARTIES.PARTY_ID%TYPE;
  l_PartyType               Varchar2(30);


  CURSOR c_get_party_type_and_name (p_party_id number) IS
         SELECT party_type, person_first_name, person_last_name,party_id
         FROM hz_parties
         WHERE party_id = p_party_id;

  rec_get_recipient_name c_get_party_type_and_name%rowtype;

 CURSOR c_b2b_contact_info(p_party_id number) IS
 SELECT p.person_first_name,
        p.person_last_name,
        p.party_id
 FROM   hz_relationships l,
        hz_parties p
 WHERE l.party_id   = p_party_id
   AND l.subject_id   = p.party_id
   AND l.subject_type = 'PERSON'
   AND l.object_type  = 'ORGANIZATION';

  rec_party_info c_b2b_contact_info%rowtype;

BEGIN
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               ibe_util.debug('get_name_details:input user_type: '||p_user_type);
               ibe_util.debug('get_name_details:input party_id: '||p_party_id);
         END IF;
         open  c_get_party_type_and_name(p_party_id);
         Fetch c_get_party_type_and_name into l_partyType, x_contact_first_name ,x_contact_last_name,x_party_id ;

          IF (l_PartyType<>'PERSON') THEN
               FOR rec_party_info IN c_b2b_contact_info(p_party_id)   LOOP
                     x_Contact_First_Name := rec_party_info.person_first_name;
                     x_Contact_last_name  := rec_party_info.person_last_name;
                     x_party_id           := rec_party_info.party_id;
               END LOOP;
          ELSE
             x_party_id := p_party_id;

        END IF;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN

    ibe_util.debug('get_name_details:output first_name: '||x_contact_first_name);
    ibe_util.debug('get_name_details:input last_name: '||x_contact_first_name);
  END IF;

END Get_Name_details;



PROCEDURE NotifyForQuotePublish(
     p_api_version       IN   NUMBER,
     p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
     p_Msite_Id          IN   NUMBER,
     p_quote_id          IN   VARCHAR2,
     p_Req_Name          IN   Varchar2,
     p_Send_Name         IN   Varchar2,
     p_Email_Address     IN   Varchar2,
     p_url               IN   Varchar2,
     x_return_status     OUT NOCOPY  VARCHAR2,
     x_msg_count         OUT NOCOPY  NUMBER,
     x_msg_data          OUT NOCOPY  VARCHAR2
     ) IS


	g_ItemType Varchar2(10) := 'IBEALERT';
	g_processName Varchar2(30) := 'PROCESSMAP';


 	l_adhoc_user  WF_USERS.NAME%TYPE;
 	l_item_key      WF_ITEMS.ITEM_KEY%TYPE;
 	l_item_owner        WF_USERS.NAME%TYPE := 'SYSADMIN';

 	l_partyId               Number;

 	l_notifEnabled  Varchar2(3) := 'Y';
 	l_notifName      Varchar2(30) := 'QUOTEPUB';
 	l_OrgId       Number := null;
 	l_UserType          jtf_um_usertypes_b.usertype_key%type := 'ALL';

    	l_messageName           WF_MESSAGES.NAME%TYPE;
    	l_msgEnabled         VARCHAR2(3) :='Y';

	l_resource_id   number;
	l_first_name    JTF_RS_RESOURCE_EXTNS.SOURCE_FIRST_NAME%TYPE;
	l_last_name     JTF_RS_RESOURCE_EXTNS.SOURCE_LAST_NAME%TYPE;
	l_full_name     Varchar2(360);



	Cursor C_login_User(c_login_name VARCHAR2) IS
	Select USR.CUSTOMER_ID Name
	From   FND_USER USR
	Where  USR.EMPLOYEE_ID     is null
	and    user_name = c_login_name;

    Cursor C_Name_form_ResourceId(c_resource_id number)IS
    Select SOURCE_FIRST_NAME, SOURCE_LAST_NAME
    From   JTF_RS_RESOURCE_EXTNS
    Where  RESOURCE_ID = c_resource_id;

BEGIN

 	x_return_status :=  FND_API.g_ret_sts_success;


        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Check if this notification is enabled.');
        END IF;
        l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
        END IF;

        If l_notifEnabled = 'Y' Then

        	 l_adhoc_user := upper(p_send_name);

  		FOR c_rec IN c_login_user(l_adhoc_user) LOOP
   		l_adhoc_user := 'HZ_PARTY:'||c_rec.Name;
          l_partyId    := c_rec.Name;
          END LOOP;

      	l_orgId :=  MO_GLOBAL.get_current_org_id();
          getUserType(l_partyId,l_UserType);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Get Message - MsiteId: '||to_Char(p_msite_id)||' Org_id: '||to_char(l_orgId) ||' User Type: '||l_userType);
        END IF;

        	FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
			l_resource_id := c_quote_rec.resource_id;
		END LOOP;

 		FOR c_jtf_rs_rec In C_Name_form_ResourceId(l_resource_id) LOOP
			l_first_name :=  c_jtf_rs_rec.source_first_name;
			l_last_name  :=  c_jtf_rs_rec.source_last_name;
		END LOOP;
		l_full_name := l_last_name || ', ' || l_first_name;

     IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
   	(
         p_org_id => l_OrgId,
         p_msite_id      => p_msite_id,
         p_user_type => l_userType,
         p_notif_name => l_notifName,
         x_enabled_flag  => l_msgEnabled,
         x_wf_message_name => l_MessageName,
         x_return_status => x_return_status,
         x_msg_data  => x_msg_data,
         x_msg_count => x_msg_count);


         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
         END IF;


            If x_msg_count > 0 Then
               Raise GET_MESSAGE_ERROR;
            End if;

            If l_msgEnabled = 'Y' Then

         l_item_key := l_notifName||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_send_name;

  		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     		ibe_util.debug('Create and Start Process with Item Key: '||l_item_key);
  		END IF;

  		wf_engine.CreateProcess(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		process   => g_processName);

  		wf_engine.SetItemUserKey(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		userkey  	=> l_item_key);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname  	=> 'MESSAGE',
   		avalue  	=> l_MessageName);

  		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname  	=> 'SENDTO',
   		avalue  	=> l_adhoc_user);

  		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname     => 'EVENTTYPE',
   		avalue    => l_notifName);

          wf_engine.SetItemAttrText(
		itemtype  => g_ItemType,
		itemkey   => l_item_key,
		aname  	=> 'REQ_F_NAME',
		avalue  	=> l_first_name);

          wf_engine.SetItemAttrText(
		itemtype  => g_ItemType,
		itemkey   => l_item_key,
		aname  	=> 'REQ_L_NAME',
		avalue  	=> l_last_name);

  		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname  	=> 'REQ_NAME',
		avalue  	=> l_full_name);

  		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname  => 'LOGINNAME',
   		avalue  => p_send_name);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname  	=> 'QUOTEID',
   		avalue  	=> p_quote_id);

   		wf_engine.SetItemAttrText(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		aname  => 'URL',
   		avalue  => p_url);

   		wf_engine.SetItemOwner(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key,
   		owner  => l_item_owner);

   		wf_engine.StartProcess(
   		itemtype  => g_ItemType,
   		itemkey   => l_item_key);

  		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     		ibe_util.debug('Process Started');
  		END IF;

  			End If;
      	End If;
Exception

 When OTHERS Then
  x_return_status := FND_API.g_ret_sts_error;
  x_msg_count := 0;

 wf_core.context('ibe_workflow_pvt',
  'NotifyRegistration',
  p_send_name
 );
 raise;
END NotifyForQuotePublish;

-----------added by abhandar :08/26/03 - new procedure---------------
PROCEDURE Generate_Approval_Msg(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
	) is
  L_api_name     CONSTANT VARCHAR2(30)  := 'Generate_Approval_Msg';
  L_api_version  CONSTANT NUMBER     := 1.0;

  L_quote_flag  VARCHAR2(1) := fnd_api.g_true;
  L_tax_flag    VARCHAR2(1) := fnd_api.g_true;
  BEGIN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG(L_api_name||':START: value of document id ='||document_id);
    END IF;
    FND_MESSAGE.set_name('IBE',document_id);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG(L_api_name||':After call to FND_MESSAGE.set_name()');
    END IF;
	document:=FND_MESSAGE.get();
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG(L_api_name||'After Fnd_message.get(): document='||document);
    END IF;
    document_type := 'text/plain';
  EXCEPTION
    WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Unidentified error in ibe_workflow_pvt.Generate_Approval_Msg');
      END IF;

  END;
----------------------added by abhandar :end -----------------------

PROCEDURE Generate_Credential_Msg(
		document_id     IN  VARCHAR2,
		display_type    IN  VARCHAR2,
		document        IN  OUT NOCOPY VARCHAR2,
		document_type   IN  OUT NOCOPY	VARCHAR2
) is
	  L_api_name     CONSTANT VARCHAR2(30)  := 'Generate_Credential_Msg';
	  L_api_version  CONSTANT NUMBER     := 1.0;
	  l_item_key     WF_ITEMS.ITEM_KEY%TYPE;
	  -- l_uname	 VARCHAR2(30);
	  l_passwd	 VARCHAR2(30);
	  l_credential_line VARCHAR2(255);
BEGIN
		l_item_key:= document_id  ;
		-- l_uname := 	wf_engine.GetItemAttrText (
		--			itemtype 	=> g_itemType,
		--			itemkey  	=> l_item_key,
		--			aname	=> 'LOGINNAME'
		--		);
		l_passwd := 	wf_engine.GetItemAttrText (
				       itemtype 	=> g_itemType,
				       itemkey  	=> l_item_key,
				       aname	=> 'PASSWORD'
				);

		document := ' ';

	IF l_passwd is not null THEN

     --FND_MESSAGE.set_name('IBE','IBE_UM_WF_USER_CREDENTIALS');
	-- FND_MESSAGE.Set_Token('LOGINNAME', l_uname);
	FND_MESSAGE.set_name('IBE','IBE_UM_WF_USER_CREDENTIAL_PWD');
	FND_MESSAGE.Set_Token('PASSWORD', l_passwd);
	l_credential_line := ' ' || FND_MESSAGE.get();
	ELSE
	l_credential_line := ' ';

	END IF;

	      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
		 IBE_UTIL.DEBUG('ibe_workflow_pvt.Generater_Credential l_credential_line =' || l_credential_line);
	      END IF;
	    document := l_credential_line;

	    document_type := 'text/plain';
	EXCEPTION
	    WHEN OTHERS THEN
	      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
		 IBE_UTIL.DEBUG('Unidentified error in ibe_workflow_pvt.Generate_User_Credential_Msg');
	      END IF;
END Generate_Credential_Msg;


/* PROCEDURE:  To send out email alert for user registration.
   CALL IN FILE(s):  RegisterationHandler.java
*/

PROCEDURE NotifyRegistration (
	p_api_version   IN  NUMBER,
	p_init_msg_list	IN  VARCHAR2 := FND_API.G_FALSE,
	p_first_name    IN  VARCHAR2,
	p_last_name     IN  VARCHAR2,
	p_login_name    IN  VARCHAR2,
	p_password      IN  VARCHAR2,
    p_usertype      IN  VARCHAR2,
	p_email_address	IN  VARCHAR2,
	p_event_type    IN  VARCHAR2,
	p_language      IN  VARCHAR2,
	x_return_status	OUT NOCOPY	VARCHAR2,
	x_msg_count     OUT NOCOPY	NUMBER,
	x_msg_data      OUT NOCOPY	VARCHAR2
	) IS
Begin

NotifyRegistration (
	p_api_version,
	p_init_msg_list,
	null,
	p_first_name,
	p_last_name,
	p_login_name,
	p_password,
    p_usertype,
	p_email_address,
	p_event_type ,
	p_language,
	x_return_status,
	x_msg_count,
	x_msg_data
	);


End NotifyRegistration;

PROCEDURE NotifyRegistration (

	p_api_version   IN  NUMBER,
	p_init_msg_list	IN  VARCHAR2 := FND_API.G_FALSE,
	p_Msite_Id      IN  NUMBER,
	p_first_name    IN  VARCHAR2,
	p_last_name     IN  VARCHAR2,
	p_login_name    IN  VARCHAR2,
	p_password      IN  VARCHAR2,
    p_usertype      IN  VARCHAR2,
	p_email_address IN  VARCHAR2,
	p_event_type    IN  VARCHAR2,
	p_language      IN  VARCHAR2,
	x_return_status OUT NOCOPY	VARCHAR2,
	x_msg_count     OUT NOCOPY	NUMBER,
	x_msg_data      OUT NOCOPY	VARCHAR2
	) IS
	l_adhoc_user    WF_USERS.NAME%TYPE;
	l_item_key      WF_ITEMS.ITEM_KEY%TYPE;
	l_item_owner    WF_USERS.NAME%TYPE := 'SYSADMIN';
	l_partyId       Number;
	l_notifEnabled  Varchar2(3) := 'Y';
	l_notifName     Varchar2(30) := 'ACCTREGNOTIFICATION';
	l_OrgId         Number := null;
	l_partyNum      Varchar2(30);
	l_UserType      jtf_um_usertypes_b.usertype_key%type := 'ALL';
    l_messageName   WF_MESSAGES.NAME%TYPE;
    l_msgEnabled    VARCHAR2(3) :='Y';

    --ab

    l_url                 VARCHAR2(240) ; -- based on the JTA profile value
    l_merchant_name       VARCHAR(240); -- based on the JTA profile value
    l_approval_id         NUMBER;
    l_approval_msg_name   VARCHAR2(1000);
    l_partner_pos         NUMBER;
    --end ab
	Cursor C_login_User(c_login_name VARCHAR2) IS
	Select USR.CUSTOMER_ID Name
	From   FND_USER USR
	Where  USR.EMPLOYEE_ID   is null
	and    user_name = c_login_name;
    -- ab
    Cursor C_get_approval_id(c_usertype VARCHAR2) IS
    select approval_id from jtf_um_usertypes_b
    where usertype_key=c_usertype and (effective_end_date > sysdate or effective_end_date is null)
    and rownum= 1 and application_id=671;

   Cursor C_get_org_num(c_party_id NUMBER) IS
    select b.party_number
    from   hz_parties a,hz_parties b,hz_relationships c
    where  a.party_id= c.party_id
     and   b.party_id= c.object_id
	and   c.subject_table_name = 'HZ_PARTIES'
	and   c.object_table_name = 'HZ_PARTIES'
	and   c.directional_flag = 'F'
	and   a.party_id=c_party_id;

   -- end-ab
	BEGIN

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     ibe_util.debug('NotifyRegistration :start notification for p_login_name='||p_login_name);
    END If;
    -- get the URL from the profile
    l_url:=FND_PROFILE.value ('JTA_UM_APPL_URL');

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('NotifyRegistration:l_url='||l_url);
     END If;
    -- get the merchant name from the profile
    l_merchant_name:= FND_PROFILE.value('JTF_UM_MERCHANT_NAME');
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('NotifyRegistration:l_merchant_name='||l_merchant_name);
     END If;
    -- end-ab
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Check if this notification is enabled.');
        END IF;
        l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
        END IF;

        If l_notifEnabled = 'Y' Then
	        l_adhoc_user := upper(p_login_name);
     		FOR c_rec IN c_login_user(l_adhoc_user) LOOP
    			l_adhoc_user := 'HZ_PARTY:'||c_rec.Name;
	         	l_partyId    := c_rec.Name;
	        END LOOP;
    		l_orgId :=  MO_GLOBAL.get_current_org_id();

            OPEN C_get_org_num(l_partyId);
            FETCH C_get_org_num into l_partyNum;
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 ibe_util.debug('NotifyRegistration '||':l_partyId='||l_partyId ||':p_UserType='||p_UserType||'l_orgId='||l_orgId||':l_partyNum='||l_partyNum);
            END IF;
            CLOSE C_get_org_num;

           -- getUserType(l_partyId,l_UserType);
           l_UserType:=p_usertype;

           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             ibe_util.debug('NotifyRegistration:Before Get Message - MsiteId: '||to_Char(p_msite_id)||' Org_id: '||to_char(l_orgId)
 						||' User Type: '||l_userType);

           END IF;
           --ab-start
           -- get the approval id associated with the user type

           OPEN C_get_approval_id(l_UserType);
           FETCH C_get_approval_id into l_approval_id;
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             ibe_util.debug('NotifyRegistration:l_approval_id='||l_approval_id);
           END IF;
           IF C_get_approval_id%FOUND  AND l_approval_id >0 THEN
               ibe_util.debug('NotifyRegistration:Approval id associated with the user type');
              ------ approval associated with the user type -----------
               IF (l_UserType='IBE_INDIVIDUAL') THEN
                   l_approval_msg_name:='IBE_APPRVL_REQD_B2C';
               ELSIF (l_UserType='IBE_PRIMARY') OR (l_UserType='IBE_BUSINESS') THEN
                  l_approval_msg_name:='IBE_APPRVL_REQD_B2B';
               ELSIF (l_UserType='IBE_PARTNER_PRIMARY') OR (l_UserType='IBE_PARTNER_BUSINESS') THEN
                  l_approval_msg_name:='IBE_APPRVL_REQD_PRM';
               ELSE
                   l_approval_msg_name:= l_UserType||'_APPR';
		   ibe_util.debug('NotifyRegistration:l_approval_msg =: '||fnd_message.get(l_approval_msg_name));
		   If fnd_message.get(l_approval_msg_name)= l_approval_msg_name Then
		 	l_approval_msg_name:='IBE_APPRVL_REQD_CUST';
	       	   End if;
               END IF;
           ELSE --approval not associated with the user type
              ibe_util.debug('NotifyRegistration:Approval not associated with the user type');
              IF (l_UserType='IBE_INDIVIDUAL') THEN
                  l_approval_msg_name:='IBE_APPRVL_NOT_REQD_B2C';
              ELSIF (l_UserType='IBE_PRIMARY')OR (l_UserType='IBE_BUSINESS') THEN
                  l_approval_msg_name:='IBE_APPRVL_NOT_REQD_B2B';
              ELSIF (l_UserType='IBE_PARTNER_PRIMARY') OR (l_UserType='IBE_PARTNER_BUSINESS') THEN
                  l_approval_msg_name:='IBE_APPRVL_NOT_REQD_PRM';
              ELSE
                  l_approval_msg_name:= l_UserType||'_NOAPPR';
                  ibe_util.debug('NotifyRegistration:l_approval_msg =: '||fnd_message.get(l_approval_msg_name));
		  If fnd_message.get(l_approval_msg_name)= l_approval_msg_name Then
		  	l_approval_msg_name:='IBE_APPRVL_NOT_REQD_CUST';
		  End if;
              END IF;
          END IF;
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyRegistration:l_approval_msg_name='||l_approval_msg_name);
         END IF;
         CLOSE C_get_approval_id;
           --end ab
         IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
   		(   p_org_id	=>	l_OrgId,
        	p_msite_id      =>	p_msite_id,
	        p_user_type	=>	l_userType,
	        p_notif_name	=>	l_notifName,
	        x_enabled_flag  =>   l_msgEnabled,
	        x_wf_message_name	=> l_MessageName,
	        x_return_status => x_return_status,
	        x_msg_data 	=> x_msg_data,
	        x_msg_count	=> x_msg_count);

         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('NotifyRegistration:Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
            ibe_util.debug('NotifyRegistration:x_msg_count=:'||x_msg_count);
         END IF;
         -- If x_msg_count > 0 Then
         --   Raise GET_MESSAGE_ERROR;
         -- End if;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('NotifyRegistration:l_msg_enabled='||l_msgEnabled);
          END IF;
          If l_msgEnabled = 'Y' Then
	         l_item_key := p_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_login_name;
        	 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       	      ibe_util.debug('NotifyRegistration:Create and Start Process with Item Key: '||l_item_key);
             ibe_util.debug('The attributes to be set are: Message='||l_MessageName ||
             ':ApprovalMsgId='||l_approval_msg_name||
             ':FirstName='||p_first_name|| ':LastName='||p_last_name || ':LoginName=' ||p_login_name ||
             ':emailAddress='|| p_email_address || ':eventType='||p_event_type ||
             ':sendTo='||l_adhoc_user ||':URL=''||l_url'||':orgnum='||l_partyNum ||
             ':merchantName='||l_merchant_name);
            END IF;
    		wf_engine.CreateProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			process  	=> g_processName);

    		wf_engine.SetItemUserKey(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			userkey		=> l_item_key);

	       	wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'MESSAGE',
			avalue		=>  l_MessageName);

        	wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'FIRSTNAME',
			avalue		=> p_first_name);

     		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'LASTNAME',
			avalue		=> p_last_name);

        	wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'LOGINNAME',
			avalue		=> p_login_name);

     		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'PASSWORD',
			avalue		=> p_password);

    		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'EMAILADDRESS',
			avalue		=> p_email_address);

    		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'EVENTTYPE',
			avalue		=> p_event_type);

	    	wf_engine.SetItemAttrText(
   			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'SENDTO',
			avalue		=> l_adhoc_user);
       -- start ab
           wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'ISTOREURL',
			avalue		=> l_url);

            wf_engine.SetItemAttrText(
 			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'APPROVALMSGID',
			avalue		=> l_approval_msg_name);

            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    	       ibe_util.debug('NotifyRegistration :set attribute APPROVALMSGID='|| l_approval_msg_name);
             END IF;

            wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'ORGNUM',
			avalue		=> l_partyNum);

            wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'MERCHANTNAME',
			avalue		=> l_merchant_name);
         -- end ab

		wf_engine.SetItemAttrText(
		     itemtype  => g_ItemType,
		     itemkey   => l_item_key,
		     aname     => 'ITEMKEY',
		     avalue    => l_item_key);

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
			ibe_util.debug('NotifyRegistration : Item key set as'|| l_item_key);
		END IF;

        	wf_engine.SetItemOwner(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			owner		=> l_item_owner);

     		wf_engine.StartProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key);

	       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    	    ibe_util.debug('NotifyRegistration :workflow Process Started');
           END IF;
    	 End If;
      End If;
Exception
	When OTHERS Then
 	x_return_status := FND_API.g_ret_sts_error;
	x_msg_count := 0;
    wf_core.context('ibe_workflow_pvt',
	'NotifyRegistration',
	p_login_name
    );
    raise;
END NotifyRegistration;

--Bug 2111316
PROCEDURE NotifyForgetLogin(
     p_api_version       IN   NUMBER,
     p_init_msg_list     IN   VARCHAR2 := FND_API.G_FALSE,
     p_Msite_Id          IN   NUMBER,
     p_first_name        IN   VARCHAR2,
     p_last_name         IN   VARCHAR2,
     p_login_name        IN   VARCHAR2,
     p_password          IN   VARCHAR2,
     p_email_address     IN   VARCHAR2,
     x_return_status     OUT NOCOPY  VARCHAR2,
     x_msg_count         OUT NOCOPY  NUMBER,
     x_msg_data          OUT NOCOPY  VARCHAR2
     ) IS

     l_adhoc_user        WF_USERS.NAME%TYPE;
     l_item_key          WF_ITEMS.ITEM_KEY%TYPE;
     l_item_owner        WF_USERS.NAME%TYPE := 'SYSADMIN';

     l_partyId           Number;

     l_event_type        Varchar2(30) := 'FORGETLOGIN';
     l_notifEnabled      Varchar2(3) := 'Y';
     l_notifName         Varchar2(30) := 'FORGETLOGINNOTIFICATION';
     l_OrgId             Number := null;
     l_UserType          jtf_um_usertypes_b.usertype_key%type := 'ALL';

     l_messageName       WF_MESSAGES.NAME%TYPE;
     l_msgEnabled        VARCHAR2(3) :='Y';

     CURSOR c_login_User(c_login_name VARCHAR2) IS
     SELECT USR.CUSTOMER_ID Name
     FROM   FND_USER USR
     WHERE  USR.EMPLOYEE_ID  IS NULL
     AND    user_name = c_login_name;

BEGIN

  x_return_status :=  FND_API.g_ret_sts_success;


    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Check if this notification is enabled.');
    END IF;

    l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||
                                                           l_notifEnabled);
    END IF;

    IF l_notifEnabled = 'Y' THEN
      l_adhoc_user := upper(p_login_name);

      FOR c_rec IN c_login_user(l_adhoc_user) LOOP
        l_adhoc_user := 'HZ_PARTY:'||c_rec.Name;
        l_partyId    := c_rec.Name;
      END LOOP;

      l_orgId := MO_GLOBAL.get_current_org_id();
      getUserType(l_partyId,l_UserType);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Get Message - MsiteId: '||to_Char(p_msite_id)||
                     ' Org_id: '||to_char(l_orgId) ||' User Type: '||
                     l_userType);
      END IF;

      IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
      (
        p_org_id           =>  l_OrgId,
        p_msite_id         =>  p_msite_id,
        p_user_type        =>  l_userType,
        p_notif_name       =>  l_notifName,
        x_enabled_flag     =>  l_msgEnabled,
        x_wf_message_name  =>  l_MessageName,
        x_return_status    =>  x_return_status,
        x_msg_data         =>  x_msg_data,
        x_msg_count        =>  x_msg_count);


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||
                     l_msgEnabled);
      END IF;
      IF x_msg_count > 0 THEN
        Raise GET_MESSAGE_ERROR;
      END IF;

      IF l_msgEnabled = 'Y' THEN

        l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||
                      '-'||p_login_name;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Create and Start Process with Item Key: '||l_item_key);
        END IF;

        wf_engine.CreateProcess(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           process   => g_processName);

        wf_engine.SetItemUserKey(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           userkey   => l_item_key);

        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'MESSAGE',
           avalue    =>  l_MessageName);

        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'FIRSTNAME',
           avalue    => p_first_name);

        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'LASTNAME',
           avalue    => p_last_name);

        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'LOGINNAME',
           avalue    => p_login_name);

        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'PASSWORD',
           avalue    => p_password);

        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'EMAILADDRESS',
           avalue    => p_email_address);

        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'EVENTTYPE',
           avalue    => l_event_type);

        wf_engine.SetItemAttrText(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           aname     => 'SENDTO',
           avalue    => l_adhoc_user);

        wf_engine.SetItemOwner(
           itemtype  => g_ItemType,
           itemkey   => l_item_key,
           owner     => l_item_owner);

        wf_engine.StartProcess(
           itemtype  => g_ItemType,
           itemkey   => l_item_key);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Process Started');
        END IF;

      END IF;
    END IF;

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_error;
    x_msg_count := 0;
    wf_core.context('ibe_workflow_pvt', 'NotifyForgetLogin', p_login_name);
    raise;

END NotifyForgetLogin;


/* PROCEDURE: To send out email alert for various order status information.
   CALL IN FILE(s): Quote.java -> IBEVQASB.pls
*/

PROCEDURE NotifyOrderStatus(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_quote_id		IN	NUMBER,
	p_status 		IN	VARCHAR2,
	p_errmsg_count		IN	NUMBER,
	p_errmsg_data		IN	VARCHAR2,
	p_sharee_partyId    	IN   	NUMBER := NULL,
	x_return_status         OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	) IS

Begin

 NotifyOrderStatus(
	p_api_version,
	p_init_msg_list,
	null,
	p_quote_id,
	p_status,
	p_errmsg_count,
	p_errmsg_data,
	p_sharee_partyId,
	x_return_status,
	x_msg_count,
	x_msg_data);

END NotifyOrderStatus;

PROCEDURE NotifyOrderStatus(
	p_api_version    IN NUMBER,
	p_init_msg_list  IN VARCHAR2 := FND_API.G_FALSE,
	p_msite_id       IN NUMBER,
	p_quote_id       IN NUMBER,
	p_status         IN VARCHAR2,
	p_errmsg_count   IN NUMBER,
	p_errmsg_data    IN VARCHAR2,
	p_sharee_partyId IN NUMBER,
	x_return_status  OUT NOCOPY	VARCHAR2,
	x_msg_count      OUT NOCOPY	NUMBER,
	x_msg_data       OUT NOCOPY	VARCHAR2
	) IS

    l_adhoc_user    WF_USERS.NAME%TYPE;
    l_item_key      WF_ITEMS.ITEM_KEY%TYPE;
    l_event_type    VARCHAR2(20);
    l_email_addr    WF_USERS.Email_Address%TYPE;
    l_this          NUMBER;
    l_temp_str      VARCHAR2(2000);
    l_next          NUMBER;
    l_errmsg_count  NUMBER;
    l_errmsg_data   VARCHAR2(32000);
    l_party_id      NUMBER;
    lx_party_id     NUMBER;
    l_item_owner    WF_USERS.NAME%TYPE := 'SYSADMIN';
    l_order_id      NUMBER;
    l_partyId       Number;
    l_first_name    VARCHAR2(2000);
    l_last_name     VARCHAR2(2000);

    l_notifEnabled  Varchar2(3)  := 'Y';
    l_notifName     Varchar2(30) := 'ORDCONFNOTIFICATION';
    l_Orgid         Number       := null;
    l_UserType      jtf_um_usertypes_b.usertype_key%type := 'ALL';

    l_messageName   WF_MESSAGES.NAME%TYPE;
    l_msgEnabled    VARCHAR2(3) :='Y';

    l_payment_code  Varchar2(30) := 'NOPO';
    l_msite_name    VARCHAR2(2000);
    l_permission_to_view_price BOOLEAN;
    l_view_net_price_flag VARCHAR2(1);
    l_paynow_flag         VARCHAR2(1);
    l_reccharge_flag      VARCHAR2(1);
    l_adhoc_role                WF_ROLES.NAME%TYPE;
    l_adhoc_role_display        WF_ROLES.DISPLAY_NAME%TYPE;
    l_admin_email_addr          WF_USERS.email_address%TYPE;
    l_notification_preference   WF_USERS.NOTIFICATION_PREFERENCE%TYPE;
    l_admin_adhoc_user          WF_USERS.NAME%TYPE;
    l_admin_adhoc_user_display  WF_USERS.DISPLAY_NAME%TYPE;
    l_role_users                Varchar2(200);
    l_card_number               Varchar2(50);--bug 6877589 ukalaiah


/*  Cursor c_minisite_name(p_msite number) is
    SELECT msite_name
    FROM ibe_msites_vl
    WHERE msite_id = p_msite;
rec_minisite_name  c_minisite_name%rowtype;*/

--bug 6877589 ukalaiah
Cursor c_card_number (l_order_id NUMBER) IS
--bug 10016159    SELECT itev.card_number FROM  IBY_TRXN_EXTENSIONS_V itev
   SELECT itev.card_number FROM  IBY_EXTN_INSTR_DETAILS_V itev
   WHERE  itev.order_id = trim(to_char(l_order_id)) and instrument_type = 'CREDITCARD';

BEGIN
  x_return_status :=  FND_API.g_ret_sts_success;
  -- Check for WorkFlow Feature Availablity.
  /*for rec_minisite_name in c_minisite_name(p_msite_id)  loop
    l_msite_name := 'Msite_name'||rec_minisite_name.msite_name;
    exit when c_minisite_name%notfound;
  end loop;*/

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('Minisite_id in NotifyOrderStatus is: '||p_msite_id);
  END IF;
  /* Success 'S' indicates order confirmation for Credit Card or Fax Orders */
    l_adhoc_user := NULL;
    IF ( p_status = 'S' ) THEN
      FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
        l_adhoc_user :='HZ_PARTY:'||c_quote_rec.party_id;
        l_order_id   := c_quote_rec.order_id;
        l_partyId    := c_quote_rec.party_id;
        l_orgId      := c_quote_rec.org_id;
      END LOOP;
      FOR g_header_rec In c_order_header(l_order_id) LOOP
        l_event_type := 'ORDCONF';
        l_notifName  := 'ORDCONFNOTIFICATION';

        IF  trim(g_header_rec.payment_type_code) is NULL Then
          FOR c_quote_pay In c_quote_payment(p_quote_id) LOOP
            l_payment_code   := c_quote_pay.payment_type_code;
          End Loop;
          If l_payment_code  = 'PO' Then
            l_event_type := 'ORDFAX';
            l_notifName  := 'ORDFAXNOTIFICATION';
          End If;
        --bug 6877589 ukalaiah
        --ElsIf ( g_header_rec.payment_type_code = 'CREDIT_CARD' And trim(g_header_rec.credit_card_number) is NULL)  THEN
        ElsIf ( g_header_rec.payment_type_code = 'CREDIT_CARD')  THEN

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	     ibe_util.debug('trying for credit card  '||to_char(l_order_id));
	  END IF;
          OPEN c_card_number(l_order_id);
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	     ibe_util.debug('opened the cursor successfully');
	  END IF;

          IF (c_card_number%NOTFOUND) THEN
  	        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
		     ibe_util.debug('query returned zero rows, event type: fax');
	        END IF;
          	l_event_type := 'ORDFAX';
          	l_notifName  := 'ORDFAXNOTIFICATION';
          ELSE
  	        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
		     ibe_util.debug('query returned some rows, looking for credit card');
	        END IF;
                FETCH c_card_number into l_card_number;
                IF (trim(l_card_number) is NULL) THEN
  	        	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
			     ibe_util.debug('query returned some rows, credit card number not exist');
	        	END IF;
          		l_event_type := 'ORDFAX';
          		l_notifName  := 'ORDFAXNOTIFICATION';
                END IF;
          END IF;
          CLOSE c_card_number;
        END IF;
      END LOOP;
    ElsIF ( p_status = 'E' )THEN
      l_event_type := 'ORDERROR';
      l_notifName  := 'ORDNOTBOOKNOTIFICATION';
      l_errmsg_count := p_errmsg_count;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Notify Order Status - Error Message Count -  '||to_char(l_errmsg_count));
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
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('NotifyOrderStatus - Error Message Data After LOOP - '||l_errmsg_data);
      END IF;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Check if this notification is enabled.');
    END IF;
    l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
    END IF;
    If l_notifEnabled = 'Y' Then
      IF ( p_status = 'S' ) THEN
        getUserType(l_partyId,l_UserType);
        if(l_userType = 'IBE_PARTNER' or l_userType = 'IBE_PARTNER_PRIMARY') THEN
           l_admin_email_addr            := FND_PROFILE.VALUE_SPECIFIC('IBE_ORDER_ADMIN',null,null,671);
           -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
           -- l_notification_preference     := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
           l_notification_preference     := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');
           l_admin_adhoc_user            := 'IBEU'||to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id ;
           l_admin_adhoc_user_display    := 'IBEU'||to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id;
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.DEBUG('Partner Order-AdminEmail '||l_admin_email_addr||'Name'||l_admin_adhoc_user||'preference'||l_notification_preference);
           END IF;
           wf_directory.CreateAdHocUser(
            name                    => l_admin_adhoc_user,
            display_name            => l_admin_adhoc_user_display,
            notification_preference => l_notification_preference,
            email_address           => l_admin_email_addr,
            expiration_date         =>	sysdate + 1,
            language                => 'AMERICAN');
           l_role_users             := l_adhoc_user||','||l_admin_adhoc_user;
           l_adhoc_role             := 'IBEC'||to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id;
           l_adhoc_role_display     := 'IBEC'||to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id;

           wf_directory.CreateAdHocRole
            (role_name               => l_adhoc_role,
             role_display_name       => l_adhoc_role_display,
             language                => 'AMERICAN',
             notification_preference => l_notification_preference,
             role_users              => l_role_users,
             expiration_date         => sysdate + 1);
           l_adhoc_user               := l_adhoc_role;
           IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.DEBUG('Partner Order-Adhoc Role: '||l_adhoc_user);
           END IF;
        END IF; --Partner UserType End If
      Else
        L_adhoc_user  := FND_PROFILE.VALUE_SPECIFIC('IBE_DEF_ORDER_ADMIN_EMAIL',null,null,671);
        l_orgId       := null;
        l_userType    := 'ALL';
        FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
          l_order_id   := c_quote_rec.order_id;
        END LOOP;
      End if;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Get Message - MsiteId: '||to_Char(p_msite_id)||' Org_id: '||to_char(l_orgId)||' User Type: '||l_userType);
      END IF;

      /*The following function call determines whether the user has permission
       to view Price or not. This ibe_util.check_user_permission return TRUE if the permission
       to view net price is enabled for this user otherwise this function return false */

        l_permission_to_view_price := ibe_util.check_user_permission( p_permission => 'IBE_VIEW_NET_PRICE' );
        l_paynow_flag := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_ENABLE_PAY_NOW',null,null,671), 'N');
        l_reccharge_flag := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_ENABLE_RECURRING_CHARGES',null,null,671), 'N');

        IF (l_permission_to_view_price) THEN
            l_view_net_price_flag := 'Y';
        ELSE
            l_view_net_price_flag := 'N';
        END IF;

      IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping(
        p_org_id          => l_OrgId        ,
        p_msite_id        => p_msite_id     ,
        p_user_type       => l_userType     ,
        p_notif_name      => l_notifName    ,
        x_enabled_flag    => l_msgEnabled   ,
        x_wf_message_name => l_MessageName  ,
        x_return_status   => x_return_status,
        x_msg_data        => x_msg_data     ,
        x_msg_count       => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
      END IF;
      If x_msg_count > 0 Then
        Raise GET_MESSAGE_ERROR;
      End if;
      If l_msgEnabled = 'Y' Then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus - p_quote_id - '||to_char(p_quote_id)||','||p_status);
        END IF;

        get_name_details(
            p_party_id           => l_partyId,
            p_user_type          => FND_API.G_MISS_CHAR,
            x_contact_first_name => l_first_name,
            x_contact_last_name  => l_last_name,
            x_party_id           => lx_party_id);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('first_name of the owner: '||l_first_name);
        END IF;
        l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_id;
        /* Item Key should be Unique as it represent a process instance with ITEM TYPE*/
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Create and Start Process with Item Key: '||l_item_key);
        END IF;
        wf_engine.CreateProcess(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          process  	=> g_processName);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('DONE:Create and Start Process with Item Key: '||l_item_key);
        END IF;


        wf_engine.SetItemUserKey(
          itemtype 	=> g_ItemType,
          itemkey   => l_item_key,
          userkey   => l_item_key);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemUserKey');
        END IF;

        wf_engine.SetItemAttrText(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          aname		=> 'MESSAGE',
          avalue	=>  l_MessageName);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemAttrText for MESSAGE');
        END IF;

        wf_engine.SetItemAttrText(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          aname		=> 'ITEMKEY',
          avalue    => l_item_key);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemAttrText for ITEMKEY');
        END IF;

        wf_engine.SetItemAttrText(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          aname		=> 'EVENTTYPE',
          avalue	=> l_event_type);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemAttrText for EVENTTYPE');
        END IF;

        wf_engine.SetItemAttrText(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          aname		=> 'QUOTEID',
          avalue    => p_quote_id);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemAttrText for QUOTEID');
        END IF;

        wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
		  itemkey   => l_item_key,
		  aname     => 'MSITEID',
		  avalue    => p_msite_id);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemAttrText for MSITENAME');
        END IF;

        wf_engine.SetItemAttrText(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          aname		=> 'FIRSTNAME',
          avalue    => l_first_name);

      wf_engine.SetItemAttrText(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          aname		=> 'LASTNAME',
          avalue    => l_last_name);


        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemAttrText for FIRSTNAME');
        END IF;

        wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname    => 'ORDERID',
          avalue   => l_order_id);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemAttrText for ORDERID');
        END IF;

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname    => 'VIEWNETPRICE',
          avalue   => l_view_net_price_flag);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname    => 'RECCHARGEENABLED',
          avalue   => l_reccharge_flag);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname    => 'PAYNOWENABLED',
          avalue   => l_paynow_flag);


       wf_engine.SetItemAttrText(
         itemtype => g_ItemType,
         itemkey  => l_item_key,
         aname    => 'SENDTO',
         avalue   => l_adhoc_user);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemAttrText for SENDTO');
        END IF;

        wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname	   => 'ERRMSG',
          avalue   => l_errmsg_data);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemAttrText for ERRMSG');
        END IF;

        wf_engine.SetItemOwner(
          itemtype 	=> g_ItemType,
          itemkey	=> l_item_key,
          owner	=> l_item_owner);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus: Done setItemOwner');
        END IF;

        wf_engine.StartProcess(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Process Started');
        END IF;

      End If;
    END IF;

     IF(p_status = 'E' and l_order_id IS NOT NULL) then
      FOR g_header_rec In c_order_header(l_order_id) LOOP
        l_event_type := 'ORDCONF';
        l_notifName  := 'ORDCONFNOTIFICATION';

        IF  trim(g_header_rec.payment_type_code) is NULL Then
          FOR c_quote_pay In c_quote_payment(p_quote_id) LOOP
            l_payment_code   := c_quote_pay.payment_type_code;
          End Loop;
          If l_payment_code  = 'PO' Then
            l_event_type := 'ORDFAX';
            l_notifName  := 'ORDFAXNOTIFICATION';
          End If;
        --bug 6877589 ukalaiah
        --ElsIf ( g_header_rec.payment_type_code = 'CREDIT_CARD' And trim(g_header_rec.credit_card_number) is NULL)
        ElsIf ( g_header_rec.payment_type_code = 'CREDIT_CARD' )
	THEN
	  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	     ibe_util.debug('2:trying for credit card  '||to_char(l_order_id));
	  END IF;
	  OPEN c_card_number(l_order_id);
	  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	     ibe_util.debug('2:opened the cursor successfully');
	  END IF;

          IF (c_card_number%NOTFOUND) THEN
  	        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
		     ibe_util.debug('2:query returned zero rows, event type: fax');
	        END IF;
          	l_event_type := 'ORDFAX';
          	l_notifName  := 'ORDFAXNOTIFICATION';
          ELSE
  	        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
		     ibe_util.debug('2:query returned some rows, looking for credit card');
	        END IF;
                FETCH c_card_number into l_card_number;
                IF (trim(l_card_number) is NULL) THEN
  	        	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
			     ibe_util.debug('2:query returned some rows, credit card number not exist');
	        	END IF;
          		l_event_type := 'ORDFAX';
          		l_notifName  := 'ORDFAXNOTIFICATION';
                END IF;
          END IF;

          CLOSE c_card_number;
        END IF;
      END LOOP;
      l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);
     END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
      END IF;


        /*2369138
      If (l_msgEnabled = 'Y') AND (l_event_type = 'ORDCONF')
				AND (p_status = 'S')
				AND (p_sharee_partyId IS NOT NULL) Then*/
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus:p_sharee_party_id: '||p_sharee_partyId);
      END IF;

      IF (l_notifEnabled = 'Y') AND (p_sharee_partyId IS NOT NULL) THEN
        l_partyid := p_sharee_partyid;
        l_adhoc_user := 'HZ_PARTY:'||p_sharee_partyId;
        l_item_key   := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_id||'-'||l_partyId;
        getUserType(l_partyId, l_UserType);


        IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping(
          p_org_id		=> l_OrgId,
          p_msite_id      	=> p_msite_id,
          p_user_type		=> l_userType,
          p_notif_name		=> l_notifName,
          x_enabled_flag  	=> l_msgEnabled,
          x_wf_message_name	=> l_MessageName,
          x_return_status 	=> x_return_status,
          x_msg_data 		=> x_msg_data,
          x_msg_count		=> x_msg_data);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
        END IF;
        If x_msg_count > 0 Then
          Raise GET_MESSAGE_ERROR;
        End if;

      If l_msgEnabled = 'Y' Then
        get_name_details(
            p_party_id           => p_sharee_partyid,
            p_user_type          => FND_API.G_MISS_CHAR,
            x_contact_first_name => l_first_name,
            x_contact_last_name  => l_last_name,
            x_party_id           => l_partyid);


/*The following function call determines whether the user has permission
       to view Price or not. This ibe_util.check_user_permission return TRUE if the permission
       to view net price is enabled for this user otherwise this function return false */

        l_permission_to_view_price := ibe_util.check_user_permission( p_permission => 'IBE_VIEW_NET_PRICE' );
        l_paynow_flag := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_ENABLE_PAY_NOW',null,null,671), 'N');
        l_reccharge_flag := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_ENABLE_RECURRING_CHARGES',null,null,671), 'N');

        IF (l_permission_to_view_price) THEN
            l_view_net_price_flag := 'Y';
        ELSE
            l_view_net_price_flag := 'N';
        END IF;


        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('first_name of the recipient: '||l_first_name);
        END IF;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('NotifyOrderStatus - p_quote_id - '||to_char(p_quote_id)||','||p_status);
           ibe_util.debug('Create and Start Process with Item Key: '||l_item_key);
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
			aname		=> 'ORDERID',
			avalue		=> l_order_id);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname    => 'VIEWNETPRICE',
          avalue   => l_view_net_price_flag);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname    => 'RECCHARGEENABLED',
          avalue   => l_reccharge_flag);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname    => 'PAYNOWENABLED',
          avalue   => l_paynow_flag);

        wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
		  itemkey   => l_item_key,
		  aname     => 'MSITENAME',
		  avalue    => l_msite_name);

        wf_engine.SetItemAttrText(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          aname		=> 'FIRSTNAME',
          avalue    => l_first_name);

       wf_engine.SetItemAttrText(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          aname		=> 'LASTNAME',
          avalue    => l_last_name);


        wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'SENDTO',
			avalue		=> l_adhoc_user);

        wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey		=> l_item_key,
			aname		=> 'ERRMSG',
			avalue		=> l_errmsg_data);

        wf_engine.SetItemOwner(
			itemtype 	=> g_ItemType,
			itemkey		=> l_item_key,
			owner		=> l_item_owner);

        wf_engine.StartProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Process Started');
        END IF;
       End if;
      End If;
Exception
  When OTHERS Then
    x_return_status := FND_API.g_ret_sts_error;
    x_msg_count := 0;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('NotifyOrderStatus:Exception block: '||SQLCODE||': '||SQLERRM);
  END IF;

    wf_core.context('ibe_workflow_pvt',
                    'NotifyOrderStatus',
                    l_event_type,
                    to_char(p_quote_id)
                   );
    raise;

END NotifyOrderStatus;

/********************************************************
 NotifyReturnOrderStatus: Here the input parameters are
                          party_id of the user and
                          order_header_id of the return order.

 This procedure is responsible to send a retun order confirmation
 email to the end user. This notification has 2 differnt messages
 for B2B and B2C users.
 Here permission based pricing logic is incorporated.
*********************************************************/

PROCEDURE NotifyReturnOrderStatus(
		p_api_version     IN           NUMBER,
		p_init_msg_list   IN           VARCHAR2 := FND_API.G_FALSE,
          p_party_id        IN           NUMBER,
          p_order_header_id IN           NUMBER,
		p_errmsg_count    IN           NUMBER,
		p_errmsg_data     IN           VARCHAR2,
		x_return_status   OUT NOCOPY	 VARCHAR2,
		x_msg_count       OUT NOCOPY	 NUMBER,
		x_msg_data        OUT NOCOPY	 VARCHAR2
		) IS


         l_user_name                WF_USERS.NAME%TYPE;
	    l_item_key                 WF_ITEMS.ITEM_KEY%TYPE;
	    l_event_type               VARCHAR2(20);
	    l_party_id                 NUMBER;
	    l_item_owner               WF_USERS.NAME%TYPE := 'SYSADMIN';
	    l_order_header_id          NUMBER;
         l_permission_to_view_price BOOLEAN;
         l_view_net_price_flag      VARCHAR2(1);
         x_recepient_party_id       NUMBER;
         l_first_name               VARCHAR2(2000);
	    l_last_name                VARCHAR2(2000);
	    l_notifEnabled             VARCHAR2(3)  := 'Y';
	    l_notifName                VARCHAR2(30) ;
	    l_Orgid                    NUMBER       := null;
	    l_UserType                 jtf_um_usertypes_b.usertype_key%type;
	    l_messageName              WF_MESSAGES.NAME%TYPE;
	    l_msgEnabled               VARCHAR2(3) :='Y';
            l_minisite_id              NUMBER := null;  -- bug 8337371, scnagara


	BEGIN
	  x_return_status :=  FND_API.g_ret_sts_success;


	       l_event_type  := 'RETURNORDER';

	       l_party_id := p_party_id;

     -- identify whether the user type is B2B (IBE_BUSINESS, IBE_PRIMARY, IBE_PARTNER_PRIMARY
     -- and IBE_PARTNER_BUSINESS )or B2C (IBE_INDIVIDUAL).
     -- Based on the use type, set the notifications.


       l_notifName   := 'IBE_RETURNORDERCONF';
       -- initialize the user type variable.
       l_usertype     := FND_API.G_MISS_CHAR;
                 GetUserType(l_party_id,l_usertype);
       l_user_name := 'HZ_PARTY:'||l_party_id;

               -- Call the Get_Name_details to get the party_id of the email recepient.

                 x_recepient_party_id := 0;

                 Get_Name_details(p_party_id      => l_party_id,
                             p_user_type          => l_UserType,
                             x_contact_first_name => l_first_name,
                             x_contact_last_name  => l_last_name,
                             x_party_id           => x_recepient_party_id);

             --     l_user_name := 'HZ_PARTY:'||x_recepient_party_id;

	          l_order_header_id := p_order_header_id;

	l_OrgId := MO_GLOBAL.get_current_org_id(); -- bug 7720550, scnagara
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
		IBE_UTIL.DEBUG('NotifyReturnOrderStatus org id : '|| l_OrgId);
	END IF;

	FOR g_header_rec In c_order_header(l_order_header_id) LOOP   -- bug 8337371, scnagara
	    l_minisite_id := g_header_rec.minisite_id;
	END LOOP;

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
	    IBE_UTIL.DEBUG('NotifyReturnOrderStatus: l_order_header_id = ' || l_order_header_id);
	    IBE_UTIL.DEBUG('NotifyReturnOrderStatus: l_usertype = ' || l_usertype);
	    IBE_UTIL.DEBUG('NotifyReturnOrderStatus: l_Orgid = ' || l_Orgid);
	    IBE_UTIL.DEBUG('NotifyReturnOrderStatus: l_minisite_id = ' || l_minisite_id);
	    IBE_UTIL.DEBUG('NotifyReturnOrderStatus: l_party_id = ' || l_party_id);
	END IF;

/* Check whether the notification is enabled or not */
            l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);



	    IF l_notifEnabled = 'Y' Then


	       IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping(
	        p_org_id          => l_OrgId        ,
          --    p_msite_id      => NULL             ,     -- bug 8337371, scnagara
	        p_msite_id      => l_minisite_id    ,	  -- bug 8337371, scnagara
	        p_user_type       => l_userType     ,
	        p_notif_name      => l_notifName    ,
	        x_enabled_flag    => l_msgEnabled   ,
	        x_wf_message_name => l_MessageName  ,
	        x_return_status   => x_return_status,
	        x_msg_data 	      => x_msg_data     ,
	        x_msg_count	      => x_msg_data);

          -- Get permission based pricing value from api function

	  l_permission_to_view_price := ibe_util.check_user_permission( p_permission => 'IBE_VIEW_NET_PRICE' );
          IF (l_permission_to_view_price) THEN
             l_view_net_price_flag := 'Y';
          ELSE
            l_view_net_price_flag := 'N';
          END IF;


	      If l_msgEnabled = 'Y' Then

	        l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||l_order_header_id;

	        wf_engine.CreateProcess(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          process  	=> g_processName);

	       wf_engine.SetItemUserKey(
	          itemtype 	=> g_ItemType,
	          itemkey   => l_item_key,
	          userkey   => l_item_key);

	        wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'MESSAGE',
	          avalue	=>  l_MessageName);

	        wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'ITEMKEY',
	          avalue    => l_item_key);

	        wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'EVENTTYPE',
	          avalue	=> l_event_type);


	        wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'FIRSTNAME',
	          avalue    => l_first_name);

	         wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'LASTNAME',
	          avalue    => l_last_name);

                 wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'VIEWNETPRICE',
	          avalue    => l_view_net_price_flag);



                 wf_engine.SetItemAttrText(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key,
	          aname		=> 'STOREUSERTYPE',
	          avalue    => l_usertype);

	        wf_engine.SetItemAttrText(
	          itemtype => g_ItemType,
	          itemkey  => l_item_key,
	          aname    => 'ORDERID',
	          avalue   => l_order_header_id);

             wf_engine.SetItemAttrText(
	         itemtype => g_ItemType,
	         itemkey  => l_item_key,
	         aname    => 'SENDTO',
	         avalue   => l_user_name);

	       wf_engine.SetItemOwner(
	          itemtype 	=> g_ItemType,
	          itemkey	=> l_item_key,
	          owner	=> l_item_owner);



	        wf_engine.StartProcess(
	          itemtype 	=> g_ItemType,
	          itemkey  	=> l_item_key);


	      End If;

	     END IF;


	Exception
	  When OTHERS Then
	    x_return_status := FND_API.g_ret_sts_error;
	    x_msg_count := 0;

	    wf_core.context('ibe_workflow_pvt',
	                    'NotifyReturnOrderStatus',
	                    l_event_type,
	                    to_char(l_order_header_id)
	                   );
	    raise;

END NotifyReturnOrderStatus;


/*This procedure is used to get the contact details of the owner of the order.
Dependinng on the user type two seperate cursors are used to retrieve contact details of B2C or B2B users*/

 Procedure get_contact_details_for_order(
      p_api_version        IN  NUMBER,
      p_init_msg_list      IN  VARCHAR2 := FND_API.G_FALSE,
      p_commit             IN  VARCHAR2 := FND_API.G_FALSE   ,
      p_order_id           IN  NUMBER,
      x_contact_party_id   OUT NOCOPY NUMBER,
      x_contact_first_name OUT NOCOPY VARCHAR2,
      x_contact_mid_name   OUT NOCOPY VARCHAR2,
      x_contact_last_name  OUT NOCOPY VARCHAR2,
      x_return_status      OUT NOCOPY VARCHAR2,
      x_msg_count          OUT NOCOPY NUMBER,
      x_msg_data           OUT NOCOPY VARCHAR2
                                         ) is
  Cursor c_b2b_contact(c_order_id Number) IS
  Select p.party_id Person_Party_id,
         l.party_id contact_party_id,
         p.person_first_name,
         p.person_last_name,
         p.party_type,
         o.sold_to_contact_id
  from oe_order_headers_all o,
       hz_cust_Account_roles r,
       hz_relationships l,
       hz_parties p
  where o.header_id          = c_order_id
  and   o.sold_to_contact_id = r.cust_account_role_id
  and   r.party_id           = l.party_id
  and   l.subject_id         = p.party_id
  and   l.subject_type       = 'PERSON'
  and   l.object_type        = 'ORGANIZATION';

  cursor c_b2c_contact(c_order_id number) is
  select p.party_id,
         p.party_type,
         p.person_first_name,
         p.person_last_name,
         p.person_middle_name

  from hz_cust_accounts a,
       oe_order_headers_all o,
       hz_parties p
  where o.sold_to_org_id = a.cust_account_id
  and   a.party_id       = p.party_id
  and   o.header_id      = c_order_id;

  cursor c_last_updated_by(c_order_id number) is
  select f.customer_id       ,
         o.sold_to_contact_id,
         o.last_updated_by   ,
         p.person_first_name ,
         p.person_middle_name,
         p.person_last_name
  from hz_parties p,
       oe_order_headers_all o,
       fnd_user f,
       hz_relationships r
  where o.last_updated_by = f.user_id
  and   f.customer_id     = r.party_id
  and   r.subject_id      = p.party_id
  and r.subject_type      = 'PERSON'
  and r.object_type       = 'ORGANIZATION'
  and   o.header_id       = c_order_id;

  rec_b2c_contact c_b2c_contact%rowtype;
  rec_b2b_contact c_b2b_contact%rowtype;
  rec_last_updated_by c_last_updated_by%rowtype;
  l_sold_to_contact    NUMBER;
  l_contact_party_id   NUMBER;
  l_contact_first_name VARCHAR2(2000);
  l_contact_mid_name   VARCHAR2(2000);
  l_contact_last_name  VARCHAR2(2000);

  l_party_type  VARCHAR2(2000);
  G_PKG_NAME            CONSTANT VARCHAR2(30) := 'ibe_workflow_pvt';
  l_api_name            CONSTANT VARCHAR2(50) := 'Get_contact_details';
  l_api_version         NUMBER                := 1.0;

  BEGIN

    -- Standard Start of API savepoint
    SAVEPOINT get_contact_details_for_order;
    ----DBMS_OUTPUT.PUT('Standard Start of API savepoint');
    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(L_API_VERSION,
                                      p_api_version,
                                      L_API_NAME   ,
                                      G_PKG_NAME )
    THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.To_Boolean(p_init_msg_list) THEN
      FND_Msg_Pub.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    --Start of API Body
    ----DBMS_OUTPUT.PUT('Start of API Body');
    ----DBMS_OUTPUT.PUT('Order id is: '||p_order_id);
    FOR rec_b2c_contact in c_b2c_contact(p_order_id) LOOP
      l_party_type := rec_b2c_contact.party_type;
      ----DBMS_OUTPUT.PUT('Party type is: '||l_party_type);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('L_party_type in get_contact_details_for_order: '||l_party_type);
      END IF;
      IF (l_party_type = 'PERSON') then --B2C user, get the details directly from hz_parties
        x_contact_party_id    := rec_b2c_contact.party_id;
        x_contact_first_name  := rec_b2c_contact.person_first_name;
        x_contact_mid_name    := rec_b2c_contact.person_middle_name;
        x_contact_last_name   := rec_b2c_contact.person_last_name;
      END IF;
    exit when c_b2c_contact%notfound;
    END LOOP;

    IF (l_party_type = 'ORGANIZATION') then --B2B user, determine party_id of type 'RELATIONSHIP'
                                            --sold_to_contact_id in oe_order_headers_all is the account_id
                                            --of the organization owning the order
      FOR rec_b2b_contact IN c_b2b_contact(p_order_id) LOOP
        ----DBMS_OUTPUT.PUT('Order id is: '||p_order_id);
        l_sold_to_contact     := rec_b2b_contact.sold_to_contact_id;
        l_contact_party_id    := rec_b2b_contact.contact_party_id;
        l_contact_first_name  := rec_b2b_contact.person_first_name; --details of the 'PERSON' tied to the
        l_contact_mid_name    := rec_b2c_contact.person_middle_name;--'RELATIONSHIP'
        l_contact_last_name   := rec_b2c_contact.person_last_name;
        EXIT when c_b2b_contact%notfound;
      END LOOP;
      IF(l_sold_to_contact is null) THEN
        --last_updated_by column saves the fnd user_id. Customer_id column in fnd_user table saves the
        --party_id of the person who last_updated the order. Hence l_contact_party_id is assigned the value of
        --customer_id from fnd_user table.
        FOR rec_last_updated_by in c_last_updated_by(p_order_id) LOOP
          l_contact_party_id    := rec_last_updated_by.customer_id;
          l_contact_first_name  := rec_last_updated_by.person_first_name;
          l_contact_mid_name    := rec_last_updated_by.person_middle_name;
          l_contact_last_name   := rec_last_updated_by.person_last_name;
          EXIT when c_last_updated_by%NOTFOUND;
        END LOOP;
      END IF;
      x_contact_party_id   := l_contact_party_id;
      x_contact_first_name := l_contact_first_name;
      x_contact_mid_name   := l_contact_mid_name;
      x_contact_last_name  := l_contact_last_name;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.Debug('x_contact_party_id:   '||x_contact_party_id);
       IBE_UTIL.Debug('x_contact_first_name: '||x_contact_first_name);
       IBE_UTIL.Debug('x_contact_last_name:  '||x_contact_last_name);
    END IF;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean(p_commit) THEN
      COMMIT WORK;
    END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                             p_count   => x_msg_count    ,
                             p_data    => x_msg_data);
  EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
      ROLLBACK TO get_contact_details_for_order;
      x_return_status := FND_API.G_RET_STS_ERROR;
      FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
   WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
     ROLLBACK TO get_contact_details_for_order;
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     FND_Msg_Pub.Count_And_Get(p_encoded => FND_API.G_FALSE,
                               p_count   => x_msg_count    ,
                               p_data    => x_msg_data);
  WHEN OTHERS THEN
    ROLLBACK TO get_contact_details_for_order;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_Msg_Pub.Check_Msg_Level( FND_Msg_Pub.G_MSG_LVL_UNEXP_ERROR ) THEN
      FND_Msg_Pub.Add_Exc_Msg(G_PKG_NAME,
                              L_API_NAME);
    END IF;

END;

PROCEDURE Notify_cancel_order(
    p_api_version       IN  NUMBER,
    p_init_msg_list	    IN  VARCHAR2 := FND_API.G_FALSE,
    p_order_id          IN  NUMBER,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data		OUT NOCOPY VARCHAR2
	) is

    l_cust_adhoc_user  WF_USERS.NAME%TYPE;
    l_item_key         WF_ITEMS.ITEM_KEY%TYPE;
    l_event_type       VARCHAR2(20) := 'CNCLORDR';
    l_errmsg_count     NUMBER;
    l_errmsg_data      VARCHAR2(32000);
    l_party_id         NUMBER;
    l_contact_party_id NUMBER;
    l_msite_name       VARCHAR2(2000);
    l_item_owner       WF_USERS.NAME%TYPE := 'SYSADMIN';
    l_order_id         NUMBER;
    l_quote_id         NUMBER;
    l_order_num        NUMBER;
    l_contact_first_name VARCHAR2(2000);
    l_contact_mid_name   VARCHAR2(2000);
    l_contact_last_name  VARCHAR2(2000);


    l_notifEnabled  Varchar2(3) := 'Y';
    l_notifName     Varchar2(30) := 'CANCELORDER';
    l_Orgid         Number := null;
    l_UserType      jtf_um_usertypes_b.usertype_key%type := 'ALL';
    l_messageName   WF_MESSAGES.NAME%TYPE := 'CANCELORDER';
    l_msgEnabled    VARCHAR2(3) :='Y';


BEGIN
  --ibe_util.enable_debug;
  ----DBMS_OUTPUT.PUT('reday to call Notify_cancel_order');
  x_return_status :=  FND_API.g_ret_sts_success;
  -- Check for WorkFlow Feature Availablity.
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Check if this notification is enabled.');
    END IF;
    l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);
    ----DBMS_OUTPUT.PUT('Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
    --l_notifEnabled := 'Y';
    If l_notifEnabled = 'Y' Then
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.debug('Getting the contact party id');
    END IF;
    ----DBMS_OUTPUT.PUT('Getting the contact party id');
    ibe_workflow_pvt.get_contact_details_for_order
           (p_api_version        => 1.0             ,
            p_init_msg_list      => FND_API.G_TRUE  ,
            p_commit             => FND_API.G_FALSE ,
            p_order_id           => p_order_id      ,
            x_contact_party_id   => l_contact_party_id,
            x_contact_first_name => l_contact_first_name,
            x_contact_mid_name   => l_contact_mid_name,
            x_contact_last_name  => l_contact_last_name,
            x_return_status      => x_return_status,
            x_msg_count          => x_msg_count,
            x_msg_data           => x_msg_data      )      ;
      IF x_return_status = FND_API.G_RET_STS_ERROR THEN
 	    RAISE FND_API.G_EXC_ERROR;
      END IF;

      IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Contact party_id in Notify_Cancel_Order obtained from get_contact_from_order: '||l_contact_party_id);
      END IF;
      ----DBMS_OUTPUT.PUT('Contact party_id in Notify_Cancel_Order obtained from get_contact_from_order: '||l_contact_party_id);
       getUserType(l_contact_party_Id,
                   l_UserType);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('Getting the contact party id');
      END IF;
      l_cust_adhoc_user := 'HZ_PARTY:'||l_contact_party_id;--'HZ_PARTY:4230';


      --select the order number here
      select order_number into l_order_num
      from oe_order_headers_all i
      where header_id  = p_order_id;


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Get Message - Org_id: '||to_char(l_orgId)||' User Type: '||l_userType);
      END IF;
      ----DBMS_OUTPUT.PUT('Get Message - Org_id: '||to_char(l_orgId)||' User Type: '||l_userType);

      l_OrgId := MO_GLOBAL.get_current_org_id(); -- bug 7720550, scnagara
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Get Message - After setting, l_OrgId: '||to_char(l_OrgId));
      END IF;

      IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping(
        p_org_id          => l_OrgId,
        p_msite_id        => NULL,
        p_user_type	      => l_userType,
        p_notif_name      => l_notifName,
        x_enabled_flag    => l_msgEnabled,
        x_wf_message_name => l_MessageName,
        x_return_status   => x_return_status,
        x_msg_data        => x_msg_data,
        x_msg_count	      => x_msg_data);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
      END IF;
      ----DBMS_OUTPUT.PUT('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
      If x_msg_count > 0 Then
        Raise GET_MESSAGE_ERROR;
      End if;
      If l_msgEnabled = 'Y' Then
        --ibe_util.debug('NotifyOrderStatus - p_quote_id - '||to_char(p_quote_id)||','||p_status);
        l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_order_id;
       /* Item Key should be Unique as it represent a process instance with ITEM TYPE*/
	 	----DBMS_OUTPUT.PUT('Create and Start Process with Item Key: '||l_item_key);

		wf_engine.CreateProcess(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          process  	=> g_processName);

        wf_engine.SetItemUserKey(
          itemtype 	=> g_ItemType,
          itemkey   => l_item_key,
          userkey   => l_item_key);

        wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname    => 'MESSAGE',
          avalue   => l_MessageName);

		wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname    => 'ITEMKEY',
          avalue   => l_item_key);

       wf_engine.SetItemAttrText(
         itemtype => g_ItemType,
         itemkey  => l_item_key,
         aname    => 'EVENTTYPE',
         avalue	  => l_event_type);

      wf_engine.SetItemAttrText(
         itemtype => g_ItemType,
         itemkey  => l_item_key,
         aname    => 'QUOTEID',
         avalue	  => l_quote_id);

       wf_engine.SetItemAttrText(
         itemtype => g_ItemType,
         itemkey  => l_item_key,
         aname    => 'ORDERID',
         avalue	  => P_order_id);

      wf_engine.SetItemAttrText(
         itemtype => g_ItemType,
         itemkey  => l_item_key,
         aname    => 'ORDERNUMBER',
         avalue	  => l_order_num);

      wf_engine.SetItemAttrText(
         itemtype => g_ItemType,
         itemkey  => l_item_key,
         aname    => 'FIRSTNAME',
         avalue	  => l_contact_first_name);

      wf_engine.SetItemAttrText(
         itemtype => g_ItemType,
         itemkey  => l_item_key,
         aname    => 'LASTNAME',
         avalue	  => l_contact_last_name);

       wf_engine.SetItemAttrText(
         itemtype => g_ItemType,
         itemkey  => l_item_key,
         aname    => 'SENDTO',
         avalue   => l_cust_adhoc_user);

       wf_engine.SetItemAttrText(
         itemtype => g_ItemType,
         itemkey  => l_item_key,
         aname    => 'ERRMSG',
         avalue   => l_errmsg_data);

       wf_engine.SetItemOwner(
         itemtype => g_ItemType,
         itemkey  => l_item_key,
         owner    => l_item_owner);

		wf_engine.StartProcess(
          itemtype => g_ItemType,
          itemkey  => l_item_key);

	  ----DBMS_OUTPUT.PUT('Process Started');


      End If;
    End If;
Exception
  When OTHERS Then
    x_return_status := FND_API.g_ret_sts_error;
    x_msg_count := 0;
    wf_core.context('ibe_workflow_pvt',
                    'NotifyOrderStatus',
                    l_event_type,
                    to_char(p_order_id)
                  );
   raise;

END Notify_cancel_order;


/* PROCEDURE: To send out email alert for change in contract status.

*/

PROCEDURE NotifyForContractsStatus(
        p_api_version          IN      NUMBER,
        p_init_msg_list        IN      VARCHAR2 := FND_API.G_FALSE,
        p_quote_id             IN      NUMBER,
        p_contract_id          IN      NUMBER,
        p_contract_status      IN      NUMBER,
        x_return_status        OUT NOCOPY     VARCHAR2,
        x_msg_count            OUT NOCOPY     NUMBER,
        x_msg_data             OUT NOCOPY     VARCHAR2
) IS

	 l_event_type		VARCHAR(20);
	 l_item_key		WF_ITEMS.ITEM_KEY%TYPE;
	 l_item_owner           WF_USERS.NAME%TYPE := 'SYSADMIN';

	 l_quote_org_id         NUMBER;

	 l_org_contract_rep	WF_USERS.NAME%TYPE;
	 l_customer_user	WF_USERS.NAME%TYPE;

	l_quote_number         Number;

	l_msite_id		Number := null;

	l_partyId               Number;

	l_notifEnabled		Varchar2(3) := 'Y';
	l_notifName		Varchar2(30) := 'TERMAPPROVEDNOTIF';
	l_UserType              jtf_um_usertypes_b.usertype_key%type := 'ALL';
        l_messageName           WF_MESSAGES.NAME%TYPE;
        l_msgEnabled	        VARCHAR2(3) :='Y';
	   l_permission_to_view_price BOOLEAN;
        l_view_net_price_flag   VARCHAR2(1);
        l_paynow_flag         VARCHAR2(1);
        l_reccharge_flag      VARCHAR2(1);


BEGIN

         x_return_status :=  FND_API.g_ret_sts_success;


         If   p_contract_status = 0 then -- Approved

	      l_event_type 	:= 'TERMAPPROVED';
	      l_notifName	:= 'TERMAPPROVEDNOTIF';

         ElsIf p_contract_status = 1 then

               l_event_type	:= 'TERMREJECTED';
	       l_notifName	:= 'TERMREJECTEDNOTIF';

         Elsif p_contract_status = 2 then

	      l_event_type 	:= 'TERMCANCELLED';
	      l_notifName	:= 'TERMCANCELLEDNOTIF';

        End if;


        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Check if this notification is enabled.');
        END IF;

        l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
        END IF;

        If l_notifEnabled = 'Y' Then

	        FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
                	l_customer_user   :='HZ_PARTY:'||c_quote_rec.party_id;
	            l_quote_org_id    := c_quote_rec.org_id;
	            l_quote_number    := c_quote_rec.quote_number;
			l_partyId    	  := c_quote_rec.party_id;
        	END LOOP;

		l_msite_id := null;

                getUserType(l_partyId,l_UserType);

        	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           	ibe_util.debug('Get Message - MsiteId: '||to_Char(l_msite_id)||' Org_id: '||to_char(l_quote_org_id)||' User Type: '||l_userType);
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
	        x_msg_count	=> x_msg_data);


         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
         END IF;

        /*The following function call determines whether the user has permission
          to view Price or not. */

       l_permission_to_view_price := ibe_util.check_user_permission( p_permission => 'IBE_VIEW_NET_PRICE' );
       l_paynow_flag := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_ENABLE_PAY_NOW',null,null,671), 'N');
       l_reccharge_flag := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_ENABLE_RECURRING_CHARGES',null,null,671), 'N');

       IF (l_permission_to_view_price) THEN
           l_view_net_price_flag := 'Y';
       ELSE
           l_view_net_price_flag := 'N';
       END IF;

            If x_msg_count > 0 Then
               Raise GET_MESSAGE_ERROR;
            End if;

            If l_msgEnabled = 'Y' Then

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('NotifyForContractsStatus - eventtype - '||l_event_type);
		END IF;

	      If  Not (l_notifName = 'TERMREJECTEDNOTIF') Then

        	l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-C'||p_quote_id;

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('Create and Start Process with Item Key: '||l_item_key);
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
			aname		=> 'SENDTO',
			avalue		=> l_customer_user);


		wf_engine.SetItemAttrText(
			itemtype => g_ItemType,
			itemkey  => l_item_key,
			aname    => 'VIEWNETPRICE',
			avalue   => l_view_net_price_flag);

	       wf_engine.SetItemAttrText(
		  itemtype => g_ItemType,
		  itemkey  => l_item_key,
		  aname    => 'RECCHARGEENABLED',
		  avalue   => l_reccharge_flag);

	       wf_engine.SetItemAttrText(
		  itemtype => g_ItemType,
		  itemkey  => l_item_key,
		  aname    => 'PAYNOWENABLED',
		  avalue   => l_paynow_flag);

		wf_engine.SetItemOwner(
			itemtype 	=> g_ItemType,
			itemkey		=> l_item_key,
			owner		=> l_item_owner);

		wf_engine.StartProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key);


		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('Process Started');
		END IF;
	      End If;

		 l_org_contract_rep := null;

	          FOR c_rep_rec In c_contract_rep(l_quote_org_id) LOOP
        	        l_org_contract_rep :=  c_rep_rec.contract_rep;
	          END LOOP;

                If Not (l_org_contract_rep is null) Then

		l_org_contract_rep :=  upper(l_org_contract_rep);

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('Sending Mail to Contract Org Rep.: '||l_org_contract_rep);
		END IF;

		l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-S'||p_quote_id;

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('Create and Start Process with Item Key: '||l_item_key);
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
			aname		=> 'SENDTO',
			avalue		=> l_org_contract_rep);

		wf_engine.SetItemOwner(
			itemtype 	=> g_ItemType,
			itemkey		=> l_item_key,
			owner		=> l_item_owner);

		wf_engine.StartProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key);
		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('Process Started');
		END IF;

                End If;
           End If;
        End If;
Exception
	When OTHERS Then
		x_return_status := FND_API.g_ret_sts_error;
		x_msg_count := 0;

		wf_core.context('ibe_workflow_pvt',
			'NotifyForContractsStatus',
			l_event_type,
			to_char(p_quote_id)
		);
                raise GET_MESSAGE_ERROR;
END NotifyForContractsStatus;



/* PROCEDURE: To send out email alert for Contract Term Change Request.
   CALL IN FILE(s): Contract.java
*/


PROCEDURE NotifyForContractsChange(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_quote_id		IN	NUMBER,
	p_contract_id  	        IN	NUMBER,
	p_customer_comments	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_email_id	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
) IS

Begin

/*For bug 2875949*/
  IF (p_salesrep_email_id = fnd_api.g_miss_char) then
    IBE_UTIL.DEBUG('salesemail id is g miss char');
    return;
  ELSE
    IBE_UTIL.DEBUG('salesemail id is not g miss char, ideally call from iStore');
  END IF;
/*For bug 2875949*/

NotifyForContractsChange(
	p_api_version,
	p_init_msg_list,
	null,
	p_quote_id,
	p_contract_id,
	p_customer_comments,
	p_salesrep_email_id,
	x_return_status,
	x_msg_count,
	x_msg_data);

End NotifyForContractsChange;

PROCEDURE NotifyForContractsChange(
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_msite_id		IN	NUMBER,
	p_quote_id		IN	NUMBER,
	p_contract_id  	        IN	NUMBER,
	p_customer_comments	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_email_id	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
) IS

	l_cust_email_addr		WF_USERS.Email_Address%TYPE;
	l_cust_event_type		VARCHAR(20);
	l_cust_adhoc_user		WF_USERS.NAME%TYPE;
	l_cust_adhoc_user_display	WF_USERS.DISPLAY_NAME%TYPE;
	l_cust_item_key			WF_ITEMS.ITEM_KEY%TYPE;
	l_sales_email_addr		WF_USERS.email_address%TYPE;
	l_sales_event_type		VARCHAR(20);
	l_sales_adhoc_user		WF_USERS.NAME%TYPE;
	l_sales_adhoc_user_display	WF_USERS.DISPLAY_NAME%TYPE;
	l_sales_item_key		WF_ITEMS.ITEM_KEY%TYPE;
	l_item_owner                    WF_USERS.NAME%TYPE := 'SYSADMIN';
    l_notification_preference       WF_USERS.NOTIFICATION_PREFERENCE%TYPE;

	l_quote_org_id                  NUMBER;
	l_org_contract_rep		WF_USERS.NAME%TYPE;

	l_role_users			Varchar2(200);
	l_sales_adhoc_role		WF_ROLES.NAME%TYPE;
	l_sales_adhoc_role_display	WF_ROLES.DISPLAY_NAME%TYPE;

	l_quote_name 			Varchar2(50);
	l_quote_number                  Number;

	l_partyid		Number;
	l_notifEnabled		Varchar2(3) := 'Y';
	l_notifName		Varchar2(30) := 'CUSTQUOTENOTIFICATION';
	l_UserType              jtf_um_usertypes_b.usertype_key%type := 'ALL';
	l_MessageName		WF_MESSAGES.NAME%TYPE;
        l_msgEnabled	        VARCHAR2(3) :='Y';

BEGIN

  x_return_status :=  FND_API.g_ret_sts_success;


    FOR c_quote_rec In c_quote_header(p_quote_id) LOOP
      l_cust_adhoc_user :='HZ_PARTY:'||c_quote_rec.party_id;
      l_quote_org_id    := c_quote_rec.org_id;
      l_quote_name      := c_quote_rec.quote_name;
      l_quote_number    := c_quote_rec.quote_number;
      l_partyId    	    := c_quote_rec.party_id;
    END LOOP;

    l_notifName  := 'CUSTQUOTENOTIFICATION';
    l_cust_event_type := 'ORDCUSTQUOTE';

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Check if this notification is enabled.');
    END IF;

    l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
      END IF;

      If l_notifEnabled = 'Y' Then

        getUserType(l_partyId,l_UserType);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('Get Message - MsiteId: '||to_Char(p_msite_id)||' Org_id: '||to_char(l_quote_org_id)||' User Type: '||l_userType);
        END IF;

        IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
        (
          p_org_id	         => l_quote_org_id,
          p_msite_id         => p_msite_id,
          p_user_type        => l_userType,
          p_notif_name       => l_notifName,
          x_enabled_flag     => l_msgEnabled,
          x_wf_message_name  => l_MessageName,
          x_return_status    => x_return_status,
          x_msg_data 	    => x_msg_data,
          x_msg_count	    => x_msg_data);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
        END IF;

        If x_msg_count > 0 Then
          Raise GET_MESSAGE_ERROR;
        End if;

        If l_msgEnabled = 'Y' Then

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('NotifyForContractsChange - p_quote_id '||to_char(p_quote_id));
          END IF;

          l_cust_item_key := l_cust_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_id;

          /* Item Key should be Unique as it represent a process instance with ITEM TYPE*/
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('Create and Start Process with Item Key: '||l_cust_item_key);
          END IF;


         wf_engine.CreateProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key,
			process  	=> g_processName);

		wf_engine.SetItemUserKey(
			itemtype 	=> g_ItemType,
			itemkey		=> l_cust_item_key,
			userkey		=> l_cust_item_key);

	       wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key,
			aname		=> 'MESSAGE',
			avalue		=>  l_MessageName);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key,
			aname		=> 'ITEMKEY',
			avalue		=> l_cust_item_key);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key,
			aname		=> 'EVENTTYPE',
			avalue		=> l_cust_event_type);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key,
			aname		=> 'QUOTEID',
			avalue		=> p_quote_id);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key,
			aname		=> 'QUOTENUM',
			avalue		=> l_quote_number);


		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key,
			aname		=> 'CONTRACTNO',
			avalue		=> p_contract_id);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key,
			aname		=> 'QUOTENAME',
			avalue		=> l_quote_name);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key,
			aname		=> 'COMMENTS',
			avalue		=> p_customer_comments);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key,
			aname		=> 'SENDTO',
			avalue		=> l_cust_adhoc_user);

		wf_engine.SetItemOwner(
			itemtype 	=> g_ItemType,
			itemkey		=> l_cust_item_key,
			owner		=> l_item_owner);

		wf_engine.StartProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_cust_item_key);

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('Process Started');
          END IF;
        End If; --If msg enabled
      End If; --If notif enabled

	--Create and set process values for the salesrep quote notification

  l_notifName        := 'SALESQUOTENOTIFICATION';
  l_sales_event_type := 'ORDSALESQUOTE';

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('Check if this notification is enabled.');
  END IF;

  l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
    END IF;

    If l_notifEnabled = 'Y' Then

      l_UserType := 'ALL';
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Get Message - MsiteId: '||to_Char(p_msite_id)||' Org_id: '||to_char(l_quote_org_id)||' User Type: '||l_userType);
      END IF;

      IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
      (
        p_org_id          => l_quote_org_id,
        p_msite_id        => p_msite_id,
        p_user_type	      => l_userType,
        p_notif_name      => l_notifName,
        x_enabled_flag    => l_msgEnabled,
        x_wf_message_name => l_MessageName,
        x_return_status   => x_return_status,
        x_msg_data 	      => x_msg_data,
        x_msg_count	      => x_msg_data);


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
      END IF;

      If x_msg_count > 0 Then
        Raise GET_MESSAGE_ERROR;
      End if;

      If l_msgEnabled = 'Y' Then
        l_sales_adhoc_role := null;
        l_role_users       := null;

        FOR c_rep_rec In c_contract_rep(l_quote_org_id) LOOP
          l_org_contract_rep :=  c_rep_rec.contract_rep;
        END LOOP;

        IF(IBE_UTIL.g_debugon = l_true) THEN
          IBE_UTIL.DEBUG('Contracts rep from database l_org_contract_rep: '||l_org_contract_rep);
        END IF;
       -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
       -- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
       -- IBE_DEFAULT_USER_EMAIL_STYLE
         l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');
        IF ( p_salesrep_email_id is NOT NULL) THEN
          IF(IBE_UTIL.g_debugon = l_true) THEN
            IBE_UTIL.DEBUG(' p_salesrep_email_id is NOT NULL: '||p_salesrep_email_id );
          END IF;
          l_sales_adhoc_user         := 'IBEU'||to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id ;
          l_sales_adhoc_user_display := 'IBEU'||to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id;
          l_sales_email_addr         := p_salesrep_email_id;

          wf_directory.CreateAdHocUser(
            name                    => l_sales_adhoc_user,
            display_name            => l_sales_adhoc_user_display,
            notification_preference => l_notification_preference,
            email_address           => l_sales_email_addr,
            expiration_date         =>	sysdate + 1,
            language                => 'AMERICAN');

          If Not (l_org_contract_rep is null)  Then
            l_role_users := upper(l_org_contract_rep)||','||l_sales_adhoc_user;
          Else
            l_role_users := l_sales_adhoc_user;
          End If;

          l_sales_adhoc_role         := 'IBEC'||to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id;
          l_sales_adhoc_role_display := 'IBEC'||to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id;

          wf_directory.CreateAdHocRole
            (role_name               => l_sales_adhoc_role,
             role_display_name       => l_sales_adhoc_role_display,
             language                => 'AMERICAN',
             notification_preference => l_notification_preference,
             role_users              => l_role_users,
             expiration_date         => sysdate + 1);
        ELSE
          l_sales_adhoc_role := l_org_contract_rep;

        END IF;

        If Not( l_sales_adhoc_role is null) Then

          l_sales_adhoc_role := upper(l_sales_adhoc_role);
          l_sales_item_key := l_sales_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_id;

          /* Item Key should be Unique as it represent a process instance with ITEM TYPE*/

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            ibe_util.debug('Create and Start Process with Item Key: '||l_sales_item_key);
          END IF;

			wf_engine.CreateProcess(
				itemtype 	=> g_ItemType,
				itemkey  	=> l_sales_item_key,
				process  	=> g_processName);

			wf_engine.SetItemUserKey(
				itemtype 	=> g_ItemType,
				itemkey		=> l_sales_item_key,
				userkey		=> l_sales_item_key);

		       wf_engine.SetItemAttrText(
				itemtype 	=> g_ItemType,
				itemkey  	=> l_sales_item_key,
				aname		=> 'MESSAGE',
				avalue		=>  l_MessageName);

			wf_engine.SetItemAttrText(
				itemtype 	=> g_ItemType,
				itemkey  	=> l_sales_item_key,
				aname		=> 'ITEMKEY',
				avalue		=> l_sales_item_key);

			wf_engine.SetItemAttrText(
				itemtype 	=> g_ItemType,
				itemkey  	=> l_sales_item_key,
				aname		=> 'EVENTTYPE',
				avalue		=> l_sales_event_type);

			wf_engine.SetItemAttrText(
				itemtype 	=> g_ItemType,
				itemkey  	=> l_sales_item_key,
				aname		=> 'QUOTEID',
				avalue		=> p_quote_id);

			wf_engine.SetItemAttrText(
				itemtype 	=> g_ItemType,
				itemkey  	=> l_sales_item_key,
				aname		=> 'QUOTENUM',
				avalue	=> l_quote_number);

			wf_engine.SetItemAttrText(
				itemtype 	=> g_ItemType,
				itemkey  	=> l_sales_item_key,
				aname		=> 'CONTRACTNO',
				avalue	=> p_contract_id);

			wf_engine.SetItemAttrText(
				itemtype 	=> g_ItemType,
				itemkey  	=> l_sales_item_key,
				aname		=> 'COMMENTS',
				avalue	=> p_customer_comments);

			wf_engine.SetItemAttrText(
				itemtype 	=> g_ItemType,
				itemkey  	=> l_sales_item_key,
				aname		=> 'SENDTO',
				avalue	=> l_sales_adhoc_role);

			wf_engine.SetItemOwner(
				itemtype 	=> g_ItemType,
				itemkey		=> l_sales_item_key,
				owner		=> l_item_owner);

			wf_engine.StartProcess(
				itemtype 	=> g_ItemType,
				itemkey  	=> l_sales_item_key);

			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Process Started');
			END IF;
          End If; -- if l_sales_adhoc_role
        End If;  -- if salesquote message is enabled
      End If; -- if salesqute is enabled
Exception
	When OTHERS Then
		x_return_status := FND_API.g_ret_sts_error;
		x_msg_count := 0;
        IF(IBE_UTIL.g_debugon = l_true) THEN
          IBE_UTIL.DEBUG('NotifyForContractsChange:Exception: '||SQLCODE||SQLERRM);
        END IF;
        wf_core.context('ibe_workflow_pvt','NotifyQuote',l_sales_event_type,to_char(p_quote_id));
          raise;
END NotifyForContractsChange;




/* PROCEDURE: To send out email alert for Sales Assistance Request.
   CALL IN FILE(s): Quote.java
*/



PROCEDURE NotifyForSalesAssistance (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_quote_id		IN	NUMBER,
	p_customer_comments	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_email_id	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_reason_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_user_id  IN   NUMBER   := NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	) IS
Begin


NotifyForSalesAssistance (
	p_api_version,
	p_init_msg_list,
	null,
	p_quote_id,
	p_customer_comments,
	p_salesrep_email_id,
	p_reason_code,
	p_salesrep_user_id,
	x_return_status,
	x_msg_count,
	x_msg_data);


End NotifyForSalesAssistance;

PROCEDURE NotifyForSalesAssistance (
	p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
	p_msite_id		IN      NUMBER,
	p_quote_id		IN	NUMBER,
	p_customer_comments	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_email_id	IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_reason_code		IN	VARCHAR2 := FND_API.G_MISS_CHAR,
	p_salesrep_user_id  IN   NUMBER   := NULL,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	) IS

	l_cust_email_addr		hz_contact_points.email_address%TYPE;
	l_cust_event_type		VARCHAR(20);
	l_cust_adhoc_user		WF_USERS.NAME%TYPE;
	l_cust_adhoc_user_display	WF_USERS.DISPLAY_NAME%TYPE;
	l_cust_item_key			WF_ITEMS.ITEM_KEY%TYPE;
	l_sales_email_addr		WF_USERS.email_address%TYPE;
	l_sales_event_type		VARCHAR(20);

	l_role_users			Varchar2(200);
	l_sales_adhoc_role		WF_ROLES.NAME%TYPE;
	l_sales_adhoc_role_display	WF_ROLES.DISPLAY_NAME%TYPE;

	l_sales_adhoc_user		WF_USERS.NAME%TYPE;
	l_sales_adhoc_user_display	WF_USERS.DISPLAY_NAME%TYPE;

	l_sales_item_key		WF_ITEMS.ITEM_KEY%TYPE;
	l_item_owner                    WF_USERS.NAME%TYPE := 'SYSADMIN';

	l_Notification 			WF_USERS.Notification_Preference%TYPE;
	l_Lang 				WF_USERS.Language%TYPE;
	l_Territory 			WF_USERS.Territory%TYPE;
	l_email_addr			WF_USERS.email_address%TYPE;
	l_notification_preference       WF_USERS.NOTIFICATION_PREFERENCE%TYPE;

	l_order_id			NUMBER;
	l_sales_rep		WF_USERS.NAME%TYPE;

	l_partyId			Number;
	l_orgid				Number := null;
	l_notifEnabled			Varchar2(3) := 'Y';
	l_notifName			Varchar2(30) := 'CUSTASSISTNOTIFICATON';
	l_UserType              	jtf_um_usertypes_b.usertype_key%type := 'ALL';
	l_MessageName			WF_MESSAGES.NAME%TYPE;
        l_msgEnabled	        	VARCHAR2(3) :='Y';

     --Bug 2223507
	l_quote_num         VARCHAR2(1000) := null;
	l_first_name        VARCHAR2(1000);
	l_last_name         VARCHAR2(1000);
	l_contact_phone    hz_contact_points.phone_number%TYPE;
	l_cart_name        ibe_quote_headers_v.quote_name%TYPE;
	l_cart_date        ibe_quote_headers_v.last_update_date%TYPE;
	l_ship_to_name     aso_shipments_v.ship_to_cust_name%TYPE;
	l_address           VARCHAR2(4000);
	l_address1          VARCHAR2(240);
	l_address2          VARCHAR2(240);
	l_address3          VARCHAR2(240);
	l_address4          VARCHAR2(240);
	l_country           VARCHAR2(60);
	l_city              VARCHAR2(60);
	l_postal_code       VARCHAR2(60);
	l_ship_to_state     VARCHAR2(60);
	l_ship_to_province  VARCHAR2(60);
	l_ship_to_county    VARCHAR2(60);
	l_minisite_name    ibe_msites_vl.msite_name%TYPE;
	l_shipping_method  wsh_carrier_ship_methods_v.ship_method_code_meaning%TYPE;
	l_contact_name     ibe_quote_headers_v.party_name%TYPE;

	l_ship_and_hand    ibe_quote_headers_v.TOTAL_SHIPPING_CHARGE%TYPE;
	l_tax              ibe_quote_headers_v.TOTAL_TAX%TYPE;
	l_total            ibe_quote_headers_v.TOTAL_QUOTE_PRICE%TYPE;

	l_return_status    VARCHAR2(20);
	l_msg_count        NUMBER;
	l_msg_data         VARCHAR2(4000);

	l_employee_id      NUMBER;
    l_user_name        VARCHAR2(2000);
    l_permission_to_view_price BOOLEAN;
    l_view_net_price_flag VARCHAR2(1);
    l_paynow_flag         VARCHAR2(1);
    l_reccharge_flag      VARCHAR2(1);

    cursor c_userenv_partyid is
       select customer_id
       from FND_USER
       where user_id = FND_GLOBAL.USER_ID;
    rec_userenv_partyid      c_userenv_partyid%rowtype;

BEGIN
  x_return_status :=  FND_API.g_ret_sts_success;

  -- Check for WorkFlow Enable Profile


    FOR c_quote_rec In c_quote_header(p_quote_id)
    LOOP
	 l_orgid    	  := c_quote_rec.org_id;
	 l_order_id      := c_quote_rec.order_id;
	 l_quote_num     := c_quote_rec.quote_number;
    END LOOP;
    FOR rec_userenv_partyid in c_userenv_partyid LOOP

      l_cust_adhoc_user :='HZ_PARTY:'||rec_userenv_partyid.customer_id;
      l_partyId    	    := rec_userenv_partyid.customer_id;
      EXIT when c_userenv_partyid%notfound;
    END LOOP;

--Bug 2223507 start
    --Call the procedure to retrieve the token values for header/footer
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('NotifyForSalesAssistance - '||
								 'calling Get_sales_assist_hdr_tokens');
    END IF;
    IBE_CART_NOTIFY_UTIL.Get_sales_assist_hdr_tokens (
	 p_api_version       => 1.0,
	 p_init_msg_list     => FND_API.G_TRUE,
	 p_commit            => FND_API.G_FALSE,
	 x_return_status     => l_return_status,
	 x_msg_count         => l_msg_count,
	 x_msg_data          => l_msg_data,
	 p_quote_header_id   => p_quote_id,
	 p_minisite_id       => p_msite_id,
	 x_Contact_Name      => l_contact_name,
	 x_Contact_phone     => l_contact_phone,
	 x_email             => l_email_addr,
	 x_first_name        => l_first_name,
	 x_last_name         => l_last_name,
	 x_Cart_name         => l_cart_name,
	 x_cart_date         => l_cart_date,
	 x_Ship_to_name      => l_ship_to_name,
	 x_ship_to_address1  => l_address1,
	 x_ship_to_address2  => l_address2,
	 x_ship_to_address3  => l_address3,
	 x_ship_to_address4  => l_address4,
	 x_country           => l_country,
	 x_CITY              => l_city,
	 x_POSTAL_CODE       => l_postal_code,
	 x_SHIP_TO_STATE     => l_ship_to_state,
	 x_SHIP_TO_PROVINCE  => l_ship_to_province,
	 x_SHIP_TO_COUNTY    => l_ship_to_county,
	 x_shipping_method   => l_shipping_method,
	 x_minisite_name     => l_minisite_name,
	 x_ship_and_hand     => l_ship_and_hand,
	 x_tax               => l_tax,
	 x_total             => l_total
      );

    IF (l_return_status <> 'S') THEN
	 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	 ibe_util.debug('NotifyForSalesAssistance - Get_sales_assist_hdr_tokens,'||
	                                            'error occured;' ||l_msg_data);
      END IF;
    END IF;

    l_address := l_address1||NEWLINE;
    IF (l_address2 IS NOT NULL) THEN
	 l_address := l_address ||TAB||TAB||'      '||l_address2||NEWLINE;
    END IF;
    IF (l_address3 IS NOT NULL) THEN
	 l_address := l_address || TAB||TAB||'      '||l_address3||NEWLINE;
    END IF;
    IF (l_address4 IS NOT NULL) THEN
      l_address := l_address || TAB||TAB||'      '||l_address4||NEWLINE;
    END IF;
    l_address := l_address|| TAB||TAB||'      '||l_city||',';
    l_address := l_address|| l_ship_to_state||' ';
    l_address := l_address|| l_postal_code||NEWLINE;
    l_address := l_address|| TAB||TAB||'      '||l_country;

--Bug 2223507 end

    /* Permission based pricing function call
     This function returns TRUE if the user has permission to view net price
     Otherwise this function will return FALSE */
    l_permission_to_view_price := ibe_util.check_user_permission( p_permission => 'IBE_VIEW_NET_PRICE' );
    l_paynow_flag := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_ENABLE_PAY_NOW',null,null,671), 'N');
    l_reccharge_flag := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_ENABLE_RECURRING_CHARGES',null,null,671), 'N');


    IF (l_permission_to_view_price) THEN
      l_view_net_price_flag := 'Y';
    ELSE
      l_view_net_price_flag := 'N';
    END IF;


    l_cust_event_type := 'CUSTASSIST';
    l_notifName := 'CUSTASSISTNOTIFICATON';

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Check if this notification is enabled.');
    END IF;

    l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||
												   l_notifEnabled);
    END IF;
    IF l_notifEnabled = 'Y' THEN
      getUserType(l_partyId,l_UserType);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Get Message - MsiteId: '||to_Char(p_msite_id)||
				 ' Org_id: '||to_char(l_orgid)||' User Type: '||l_userType);
      END IF;

      IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
 	 (
       p_org_id          =>	l_orgId,
       p_msite_id        =>	p_msite_id,
       p_user_type       =>	l_userType,
       p_notif_name      =>	l_notifName,
       x_enabled_flag    => l_msgEnabled,
       x_wf_message_name => l_MessageName,
       x_return_status   => x_return_status,
       x_msg_data        => x_msg_data,
       x_msg_count       => x_msg_data);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||
													 l_msgEnabled);
      END IF;

      IF x_msg_count > 0 THEN
        Raise GET_MESSAGE_ERROR;
      END IF;

      IF l_msgEnabled = 'Y' THEN
	    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	      ibe_util.debug('NotifyForSalesAssistance - p_quote_id '||to_char(p_quote_id));
        END IF;
	   l_cust_item_key := l_cust_event_type||'-'||
					   to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_id;

	   /* Item Key should be Unique as it represent a process instance with
		 ITEM TYPE*/


	   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	   ibe_util.debug('Create and Start Process with Item Key: '||
												   l_cust_item_key);
        END IF;

	   wf_engine.CreateProcess(
	     itemtype 	=> g_ItemType,
		itemkey  	=> l_cust_item_key,
		process  	=> g_processName);

	   wf_engine.SetItemUserKey(
		itemtype 	=> g_ItemType,
		itemkey	=> l_cust_item_key,
		userkey	=> l_cust_item_key);

	   wf_engine.SetItemAttrText(
		itemtype 	=> g_ItemType,
		itemkey  	=> l_cust_item_key,
		aname		=> 'MESSAGE',
		avalue		=>  l_MessageName);

	   wf_engine.SetItemAttrText(
		itemtype 	=> g_ItemType,
		itemkey  	=> l_cust_item_key,
		aname		=> 'ITEMKEY',
		avalue		=> l_cust_item_key);

	   wf_engine.SetItemAttrText(
		itemtype 	=> g_ItemType,
		itemkey  	=> l_cust_item_key,
		aname		=> 'EVENTTYPE',
		avalue		=> l_cust_event_type);

	   wf_engine.SetItemAttrText(
		itemtype 	=> g_ItemType,
		itemkey  	=> l_cust_item_key,
		aname		=> 'QUOTEID',
		avalue		=> p_quote_id);

	   wf_engine.SetItemAttrText(
		itemtype 	=> g_ItemType,
		itemkey  	=> l_cust_item_key,
		aname		=> 'ORDERID',
		avalue		=> l_order_id);

	   wf_engine.SetItemAttrText(
		itemtype 	=> g_ItemType,
		itemkey  	=> l_cust_item_key,
		aname		=> 'COMMENTS',
		avalue		=> p_customer_comments);

	   wf_engine.SetItemAttrText(
		itemtype 	=> g_ItemType,
		itemkey  	=> l_cust_item_key,
		aname		=> 'SENDTO',
		avalue		=> l_cust_adhoc_user);

        --Bug 2223507 start
	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
	     itemkey   => l_cust_item_key,
		aname     => 'REASON',
		avalue    => p_reason_code);

	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
	     itemkey   => l_cust_item_key,
		aname     => 'FIRSTNAME',
		avalue    => l_first_name);

	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
		itemkey   => l_cust_item_key,
		aname     => 'CONTACTNAME',
		avalue    => l_contact_name);

	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
	     itemkey   => l_cust_item_key,
		aname     => 'EMAILADDRESS',
		avalue    => l_email_addr);

	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
	     itemkey   => l_cust_item_key,
		aname     => 'CONTACTPHONE',
		avalue    => l_contact_phone);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_cust_item_key,
          aname    => 'VIEWNETPRICE',
          avalue   => l_view_net_price_flag);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_cust_item_key,
          aname    => 'RECCHARGEENABLED',
          avalue   => l_reccharge_flag);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_cust_item_key,
          aname    => 'PAYNOWENABLED',
          avalue   => l_paynow_flag);

	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
		itemkey   => l_cust_item_key,
		aname     => 'MSITEID',
		avalue    => p_msite_id);

	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
	     itemkey   => l_cust_item_key,
		aname     => 'CARTNAME',
		avalue    => l_cart_name);

	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
	     itemkey   => l_cust_item_key,
		aname     => 'DATE_ITEMKEY',
		avalue    => l_cust_item_key);

	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
		itemkey   => l_cust_item_key,
		aname     => 'SHIPMETHOD',
		avalue    => l_shipping_method);

	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
	     itemkey   => l_cust_item_key,
		aname     => 'SHIPTONAME',
		avalue    => l_ship_to_name);

	   wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
	     itemkey   => l_cust_item_key,
		aname     => 'SHIPTOADDRESS',
		avalue    => l_address);

        --end bug 2223507

	   wf_engine.SetItemOwner(
		itemtype 	=> g_ItemType,
		itemkey		=> l_cust_item_key,
		owner		=> l_item_owner);

	   wf_engine.StartProcess(
		itemtype 	=> g_ItemType,
		itemkey  	=> l_cust_item_key);

	   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	   ibe_util.debug('Process Started');
	   END IF;
      END IF;  --l_msgEnabled = 'Y'
    END IF;    --l_notifEnabled = 'Y'

    --Create and set process values for the salesrep assist. notification

    l_sales_event_type := 'SALESASSIST';
    l_notifName := 'SALESASSISTNOTIFICATION';

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Check if this notification is enabled.');
    END IF;

    l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||
												    l_notifEnabled);
    END IF;

    IF l_notifEnabled = 'Y' THEN

	  l_UserType := 'ALL';
	  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	  ibe_util.debug('Get Message - MsiteId: '||to_Char(p_msite_id)||
			 	 ' Org_id: '||to_char(l_orgid)||' User Type: '||l_userType);
       END IF;
      IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
      (
       p_org_id          => l_orgId,
       p_msite_id        => p_msite_id,
       p_user_type        => l_userType,
       p_notif_name	      => l_notifName,
       x_enabled_flag     => l_msgEnabled,
       x_wf_message_name  => l_MessageName,
       x_return_status    => x_return_status,
       x_msg_data 	      => x_msg_data,
       x_msg_count	      => x_msg_data);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||
													l_msgEnabled);
      END IF;
      IF x_msg_count > 0 THEN
        Raise GET_MESSAGE_ERROR;
      END IF;

      IF l_msgEnabled = 'Y' THEN
        l_sales_adhoc_role := null;
        l_role_users := null;

        FOR c_rep_rec In c_contract_rep(l_orgid)
	    LOOP
          l_sales_rep :=  c_rep_rec.sales_rep;
	    END LOOP;

 -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
 -- l_notification_preference :=
     --     NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
        l_notification_preference :=
          NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');

--Bug 2223507 start
        IF ( (p_salesrep_email_id is NOT NULL AND p_salesrep_email_id <> FND_API.G_MISS_CHAR) OR
	       (p_salesrep_user_id is NOT NULL AND p_salesrep_user_id <> FND_API.G_MISS_NUM) ) THEN
--Bug 2223507 end

          IF (( p_salesrep_email_id is NOT NULL)
		   AND (p_salesrep_email_id <> FND_API.G_MISS_CHAR)) THEN

            l_sales_adhoc_user := 'IBEA'||to_char(sysdate,'MMDDYYHH24MISS')||
												   'Q'||p_quote_id ;
            l_sales_adhoc_user_display := 'IBEA'||
					    to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id;
            l_sales_email_addr := p_salesrep_email_id;

            wf_directory.CreateAdHocUser(
		      name                    => l_sales_adhoc_user,
              display_name            => l_sales_adhoc_user_display,
              notification_preference => l_notification_preference,
              email_address           => l_sales_email_addr,
              expiration_date         => sysdate + 1,
              language                => 'AMERICAN');
            l_role_users := l_sales_adhoc_user;
--Bug2223507	END IF;

--Bug 2223507 start
          END IF; -- p_salesrep_email_id is NOT NULL

          IF (p_salesrep_user_id is NOT NULL) THEN
            BEGIN
              SELECT Employee_ID,user_name
              INTO   l_employee_id,l_user_name
              FROM   FND_USER
              WHERE  USER_ID = p_salesrep_user_id;
            EXCEPTION
            WHEN OTHERS THEN
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 ibe_util.debug('NotifyforSalesAssistance: error while'||
                                             'getting the employee id');
              END IF;
            END;
            /*Create a role with the salesrep e-mail address (if any passed in)
              and the sales rep in the profile) */
            IF (l_user_name IS NOT NULL ) THEN
              IF (l_role_users is not null) THEN
                l_role_users := l_role_users||','||l_user_name;
              ELSE
                l_role_users := l_user_name;
              END IF;
            END IF; --l_user_name IS NOT NULL

          END IF; --p_salesrep_user_id is NOT NULL


          /*Attach the admin salesrep here*/
          IF ((l_Sales_Rep is not null) and (l_Sales_Rep <> l_user_name)) Then
            l_role_users := l_role_users||','||upper(l_Sales_Rep);
          END IF;

--Bug 2223507 end
          /*Finally create the WF ad hoc role*/
          l_sales_adhoc_role := 'IBEB'||
                                to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id;
          l_sales_adhoc_role_display := 'IBEB'||
                                to_char(sysdate,'MMDDYYHH24MISS')||'Q'||p_quote_id;

          wf_directory.CreateAdHocRole
            (role_name               => l_sales_adhoc_role,
             role_display_name       => l_sales_adhoc_role_display,
	         language                => 'AMERICAN',
	         notification_preference => l_notification_preference,
        	 role_users              => l_role_users,
             expiration_date         => sysdate + 1);

        ELSE  -- p_salesrep_email_id is NULL AND p_salesrep_user_id is null

          l_sales_adhoc_role := l_sales_rep;

        END IF;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('NotifySalesAssistance: l_sales_adhoc_role '||
										 l_sales_adhoc_role);
        END IF;


        IF l_sales_adhoc_role is not null THEN
          l_sales_adhoc_role := upper(l_sales_adhoc_role);
          l_sales_item_key   := l_sales_event_type||'-'||
                                to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_id;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             ibe_util.debug('Create and Start Process with Item Key: '||
												 l_sales_item_key);
          END IF;

	     wf_engine.CreateProcess(
		  itemtype 	=> g_ItemType,
		  itemkey  	=> l_sales_item_key,
		  process  	=> g_processName);

		wf_engine.SetItemUserKey(
		  itemtype	=> g_ItemType,
		  itemkey		=> l_sales_item_key,
		  userkey		=> l_sales_item_key);

		wf_engine.SetItemAttrText(
		  itemtype 	=> g_ItemType,
		  itemkey  	=> l_sales_item_key,
		  aname		=> 'MESSAGE',
		  avalue		=>  l_MessageName);

		wf_engine.SetItemAttrText(
		  itemtype 	=> g_ItemType,
		  itemkey  	=> l_sales_item_key,
		  aname		=> 'ITEMKEY',
		  avalue		=> l_sales_item_key);

		wf_engine.SetItemAttrText(
		  itemtype	=> g_ItemType,
		  itemkey  	=> l_sales_item_key,
		  aname		=> 'EVENTTYPE',
		  avalue		=> l_sales_event_type);

		wf_engine.SetItemAttrText(
		  itemtype	=> g_ItemType,
		  itemkey  	=> l_sales_item_key,
		  aname		=> 'QUOTEID',
		  avalue		=> p_quote_id);

	     wf_engine.SetItemAttrText(
		  itemtype	=> g_ItemType,
		  itemkey  	=> l_sales_item_key,
		  aname		=> 'ORDERID',
		  avalue		=> l_order_id);

		wf_engine.SetItemAttrText(
		  itemtype	=> g_ItemType,
		  itemkey  	=> l_sales_item_key,
		  aname		=> 'COMMENTS',
		  avalue		=> p_customer_comments);

          --Bug 2223507 start
	     wf_engine.SetItemAttrText(
		  itemtype	=> g_ItemType,
		  itemkey  	=> l_sales_item_key,
		  aname		=> 'QUOTENUM',
		  avalue		=> l_quote_num);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'FIRSTNAME',
		  avalue    => l_first_name);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'CONTACTNAME',
		  avalue    => l_contact_name);

-- For bug# 3268959

         wf_engine.SetItemAttrText(
              itemtype => g_ItemType,
              itemkey  => l_sales_item_key,
              aname    => 'VIEWNETPRICE',
              avalue   => l_view_net_price_flag);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_sales_item_key,
          aname    => 'RECCHARGEENABLED',
          avalue   => l_reccharge_flag);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_sales_item_key,
          aname    => 'PAYNOWENABLED',
          avalue   => l_paynow_flag);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'MSITEID',
		  avalue    => p_msite_id);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'REASON',
		  avalue    => p_reason_code);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'CONTACTPHONE',
		  avalue    => l_contact_phone);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'EMAILADDRESS',
		  avalue    => l_email_addr);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'CARTNAME',
		  avalue    => l_cart_name);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'DATE_ITEMKEY',
		  avalue    => l_sales_item_key);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'SHIPMETHOD',
		  avalue    => l_shipping_method);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'SHIPTONAME',
		  avalue    => l_ship_to_name);

          wf_engine.SetItemAttrText(
		  itemtype  => g_ItemType,
		  itemkey   => l_sales_item_key,
		  aname     => 'SHIPTOADDRESS',
		  avalue    => l_address);

		--Bug 2223507 end

		wf_engine.SetItemAttrText(
		  itemtype	=> g_ItemType,
		  itemkey  	=> l_sales_item_key,
		  aname		=> 'SENDTO',
		  avalue    => l_sales_adhoc_role);

		wf_engine.SetItemOwner(
		  itemtype	=> g_ItemType,
		  itemkey		=> l_sales_item_key,
		  owner		=> l_item_owner);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('Finally here');
        END IF;


		wf_engine.StartProcess(
		  itemtype	=> g_ItemType,
		  itemkey  	=> l_sales_item_key);
       ELSE
         IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           IBE_UTIL.DEBUG('NotifySalesAssist:Not sending sales assistance e-mail because l_sales_adhoc_role is null');
         END IF;

	   END IF;  --l_sales_adhoc_role is not null

      END IF;  --l_msgEnabled = 'Y
    END IF;  --l_notifEnabled = 'Y'

EXCEPTION

  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_error;
    x_msg_count := 0;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('NotifySalesAssist:Exception block: '||SQLCODE||': '||SQLERRM);
  END IF;

    wf_core.context('ibe_workflow_pvt',
	 'NotifySalesAssistance',
	 l_sales_event_type,
	 to_char(p_quote_id)
    );
    raise;

END NotifyForSalesAssistance;
------------------------------------

/********************************************************
Get_Speciality_Store_name: Here the input parameter is: msite id.

This procedure is responsible to retrive the
speciality store name related to the input parameter msite id.
********************************************************/
/*This procedure is commented, as minisite name will be obtained from a callback
/*PROCEDURE Get_Speciality_Store_name(p_msite                 IN  IBE_MSITES_VL.MSITE_ID%TYPE,
                                    x_Speciality_Store_Name OUT NOCOPY IBE_MSITES_VL.MSITE_NAME%TYPE) is
  CURSOR c_msite_name(p_msite number) IS
      SELECT msite_name
      FROM ibe_msites_vl
      WHERE msite_id = p_msite;
  rec_msite_name  c_msite_name%rowtype;
BEGIN

     FOR rec_msite_name IN c_msite_name(p_Msite)
     LOOP
         x_Speciality_Store_Name := rec_msite_name.msite_name;
     END LOOP;

END Get_Speciality_Store_name;*/

/********************************************************
This API is tyo determine if the contact point is saved against IBE_SH_QUOTE_ACCESS or HZ_PARTIES
If the contact point is saved against IBE_SH_QUOTE_ACCESS then notifications will only be
sent to ad-hoc users, otherwise they will be sent to users who will be identified by their party_id
in the HZ_PARTIES table
*********************************************************/
procedure locate_contact_point
  ( p_contact_point_id    IN  NUMBER ,
    x_create_adhoc_flag OUT NOCOPY VARCHAR2 ) is
cursor c_contact_point is
  select owner_table_name
  from hz_contact_points
  where contact_point_id = p_contact_point_id;
rec_contact_point  c_contact_point%rowtype;

begin

  for rec_contact_point in c_contact_point loop
    if rec_contact_point.owner_table_name = 'IBE_SH_QUOTE_ACCESS' then
      x_create_adhoc_flag := FND_API.G_TRUE;
    end if;
    exit when c_contact_point%notfound;
  end loop;

end;


/********************************************************
 Notify_End_Working: Here the input parameters are
				 quote_header_id of the shared cart.
				 party_id of the recepient,
				 cust_account_id of the recepient,
                                 Retrieval number for b2c users,
				 speciality store id,
				 URL of the shared cart.

 This procedure is responsible to send an email to the owner of the cart
 to inform that the recepinet has completed the modifications on the
 shared cart.
*********************************************************/
PROCEDURE Notify_End_Working(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2,
    p_quote_header_id   IN  NUMBER,
    p_party_id          IN  NUMBER,
    p_Cust_Account_Id   IN  NUMBER,
    p_retrieval_number  IN  NUMBER,
    p_minisite_id       IN  NUMBER,
    p_url               IN  VARCHAR2,
    p_notes             IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
 ) IS

    l_event_type               VARCHAR2(20) := 'ENDWORK';
    l_notifEnabled             Varchar2(3);
    l_notifName                Varchar2(30) := 'ENDWORK';
    l_notif_context            VARCHAR2(2000);
    l_Orgid                    Number := null;
    l_messageName              WF_MESSAGES.NAME%TYPE;
    l_msgEnabled               VARCHAR2(3);
    l_partyid                  HZ_PARTIES.PARTY_ID%TYPE;
    x_partyid                  HZ_PARTIES.PARTY_ID%TYPE;
    l_item_key                 WF_ITEMS.ITEM_KEY%TYPE;
    l_item_owner               WF_USERS.NAME%TYPE := 'SYSADMIN';
    l_user_name                WF_USERS.NAME%TYPE;
    l_usertype                 jtf_um_usertypes_b.usertype_key%type := FND_API.G_MISS_CHAR;
    l_notification_preference  WF_USERS.NOTIFICATION_PREFERENCE%TYPE;
    l_quote_name               ASO_QUOTE_HEADERS_ALL.QUOTE_NAME%TYPE;
    l_quote_Num                ASO_QUOTE_HEADERS_ALL.QUOTE_NUMBER%TYPE;
    l_quote_ver                ASO_QUOTE_HEADERS_ALL.QUOTE_VERSION%TYPE;
    l_msite_name               IBE_MSITES_VL.MSITE_NAME%TYPE;
    l_cart_name                ASO_QUOTE_HEADERS_ALL.QUOTE_NAME%TYPE;
    l_is_it_quote              VARCHAR2(1) := FND_API.G_FALSE;
    x_contact_first_name       HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
    x_contact_last_name        HZ_PARTIES.PERSON_LAST_NAME%TYPE;
    l_recip_name               Varchar2(2000);

  CURSOR c_msite_name(p_msite number) IS
          SELECT msite_name
          FROM ibe_msites_vl
          WHERE msite_id = p_msite;

   CURSOR c_b2c_sharing(c_retrieval_number number) is
    select quote_name
    from aso_quote_headers_all
    where quote_header_id = (select quote_header_id
                             from ibe_sh_quote_access
                             where quote_sharee_number = c_retrieval_number);
  CURSOR c_get_recip_name(c_retrieval_number number) is
    select recipient_name
    from ibe_sh_quote_access
    where quote_sharee_number = c_retrieval_number;

  rec_msite_name     C_MSITE_NAME%ROWTYPE;
  rec_b2c_sharing      c_b2c_sharing%ROWTYPE;
  rec_get_recip_name c_get_recip_name%rowtype;


BEGIN
 x_return_status :=  FND_API.g_ret_sts_success;


   identify_cart_quote(p_quote_header_id => p_Quote_Header_id,
                        x_is_it_quote    => l_is_it_quote);

   IF(l_is_it_quote = l_true) THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Notify_end_working:l_is_it_quote: '||l_is_it_quote);
     END IF;
     l_notifName   := 'ENDWORK_QUOTE';
     l_notif_context := 'ENDWORK_QUOTE';
   ELSE
     l_notif_context := 'ENDWORK';
   END IF;

    l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Notify_end_working: Notification enabled: '||l_notifEnabled);
    END IF;

    IF l_notifEnabled = 'Y' THEN
          --            IF (p_quote_header_id is not null) or (p_quote_header_id <> fnd_api.g_miss_num) THEN
      FOR c_quote_rec In c_quote_header(p_Quote_Header_id) LOOP
        l_user_name      :='HZ_PARTY:'||c_quote_rec.party_id;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('Notify_end_working: I_user_name: '||l_user_name);
        END IF;
        l_orgid      := c_quote_rec.org_id;
        l_cart_name  := c_quote_rec.quote_name;
        l_partyId    := c_quote_rec.party_id;
        l_quote_num  := c_quote_rec.quote_number;
        l_quote_ver  := c_quote_rec.quote_version;
      END LOOP;
      /*ELSE
          FOR rec_b2c_sharing in c_b2c_sharing(p_retrieval_number) LOOP
          l_cart_name := rec_b2c_sharing.cart_name;
          EXIT when c_b2c_sharing%notfound;
        END LOOP;
      END IF;*/

      -- Retrive Actual Message
      IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
      (
        p_org_id           => l_OrgId,
        p_msite_id         => p_minisite_id,
        p_user_type        => l_userType,
        p_notif_name       => l_notifName,
        x_enabled_flag     => l_msgEnabled,
        x_wf_message_name  => l_MessageName,
        x_return_status    => x_return_status,
        x_msg_data         => x_msg_data,
        x_msg_count        => x_msg_data);
      IF x_msg_count > 0 THEN
        Raise GET_MESSAGE_ERROR;
      END IF;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('Notify_end_working:l_MessageName: '||l_MessageName);
        ibe_util.debug('Notify_end_working:l_msgenabled: '||l_msgEnabled);
      END IF;

      IF l_msgEnabled = 'Y' THEN
        l_usertype     := FND_API.G_MISS_CHAR;
        x_contact_first_name  := NULL;
        x_contact_last_name   := NULL;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('Notify_end_working:querying recipient_name');
        END IF;
        FOR rec_get_recip_name in c_get_recip_name(p_retrieval_number) LOOP
          l_recip_name := rec_get_recip_name.recipient_name;
          IF(l_recip_name is not null) THEN
            x_contact_first_name := l_recip_name;
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              ibe_util.debug('Notify_end_working:recipient_name from sh_quote_access tbl: '||x_contact_first_name);
            END IF;

          ELSE
            Get_Name_details(
               p_party_id           => p_party_id,
               p_user_type          => l_UserType,
               x_contact_first_name => x_contact_first_name,
               x_contact_last_name  => x_contact_last_name,
               x_party_id           => x_partyid);
          END IF;
          EXIT when c_get_recip_name%NOTFOUND;
        END LOOP;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('Notify_end_working:p_retrieval_number: '||p_retrieval_number);
          ibe_util.debug('Notify_end_working:x_contact_first_name: '||x_contact_first_name);
          ibe_util.debug('Notify_end_working:x_contact_last_name: '||x_contact_last_name);
        END IF;
        -- Create Item Type and notification Preference
        l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_Quote_Header_id;
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('Notify_end_working:l_item_key: '||l_item_key);
        END IF;
        -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
        -- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
          l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');
        set_item_attributes
                  ( p_item_key          => l_item_key
                   ,p_message_name      => l_MessageName
                   ,p_recipient_number  => p_retrieval_number
                   ,p_first_name        => x_contact_first_name
                   ,p_last_name         => x_contact_last_name
                   ,p_url               => p_url
                   ,p_minisite_id       => p_minisite_id
                   ,p_cart_name         => l_cart_name
                   ,p_adhoc_role        => l_user_name
                   ,p_notes             => p_notes
                   ,p_notif_context     => l_notif_context);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('Notify_end_working:Create_process start');
        END IF;
      END IF;   --l_msgEnabled
    END IF;   --l_notifenabled
EXCEPTION

 WHEN OTHERS THEN
  x_return_status := FND_API.g_ret_sts_error;
  x_msg_count := 0;
  wf_core.context('IBE_WORKFLOW_PVT',l_notifname,l_messagename,p_quote_header_id);
  RAISE;

END Notify_End_Working;

/********************************************************
 Notify_Finish_Sharing: Here the input parameters are
			         quote_access_record of the shared cart.
				    speciality store id,
				    URL of the shared cart.
				    Context code : The context in which the mail has triggered.

 This procedure is responsible to send an email to the recepient of the cart
 to inform that the owner has finished sharing the shared cart.
 The email can be generated in any of the following scenarios:
    Owner has deleted the Cart
    Owner has placed the order
    Owner has revoked the sharing of the cart
    Owner has transferred the access of this shared cart.
*********************************************************/

PROCEDURE Notify_Finish_Sharing(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2,
    p_quote_access_rec  IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE,  --of the recepient
    p_minisite_id       IN  NUMBER,
    p_url               IN  VARCHAR2,
    p_context_code      IN  VARCHAR2,
    p_shared_by_partyid IN  NUMBER := FND_API.G_MISS_NUM,
    p_notes             IN  VARCHAR2,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
 ) IS
    l_event_type               VARCHAR2(20) := 'STOPWORK';
    l_notifEnabled             Varchar2(3);
    l_notifName                Varchar2(30) := 'STOPWORKING';
    l_notif_context            VARCHAR2(2000);
    l_Orgid                    Number := null;
    l_messageName              WF_MESSAGES.NAME%TYPE;
    l_msgEnabled               VARCHAR2(3);
    l_usertype                 jtf_um_usertypes_b.usertype_key%type := 'ALL' ;
    l_item_key                 WF_ITEMS.ITEM_KEY%TYPE;
    l_item_owner               WF_USERS.NAME%TYPE := 'SYSADMIN';
    l_user_name                WF_USERS.NAME%TYPE;
    l_notification_preference  WF_USERS.NOTIFICATION_PREFERENCE%TYPE ;
    l_msite_name               IBE_MSITES_VL.MSITE_NAME%TYPE;
    l_cart_name                ASO_QUOTE_HEADERS_ALL.QUOTE_NAME%TYPE;
    l_is_it_quote              VARCHAR2(1) := FND_API.G_FALSE;

    l_sharedby_first_name         HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
    l_sharedby_last_name          HZ_PARTIES.PERSON_LAST_NAME%TYPE;
    l_owner_partyid            HZ_PARTIES.PARTY_ID%TYPE;
    x_owner_new_party_id       HZ_PARTIES.PARTY_ID%TYPE;

    l_recepient_first_name     HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
    l_recepient_last_name      HZ_PARTIES.PERSON_LAST_NAME%TYPE;
    x_recepient_party_id       HZ_PARTIES.PARTY_ID%TYPE;

    l_stop_working_msg_context FND_NEW_MESSAGES.MESSAGE_TEXT%TYPE;

    l_role_users               Varchar2(200);
    l_adhoc_role               WF_ROLES.NAME%TYPE;
    l_adhoc_role_display	   WF_ROLES.DISPLAY_NAME%TYPE;
    l_adhoc_user               WF_USERS.NAME%TYPE;
    l_adhoc_user_display       WF_USERS.DISPLAY_NAME%TYPE;
    l_create_adhoc_flag        VARCHAR2(1);
    l_context_code             VARCHAR2(2000);


  /*CURSOR c_context_code(c_context_code VARCHAR2) IS
           SELECT message_text
           FROM fnd_new_messages
           WHERE message_name = c_context_code
		 AND   application_id = 671
           AND   language_code = userenv('LANG');
  rec_get_context_msg C_CONTEXT_CODE%ROWTYPE;*/


BEGIN
 x_return_status :=  FND_API.g_ret_sts_success ;

-- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
-- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');

   l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');

   l_context_code := p_context_code;

   identify_cart_quote(p_quote_header_id => p_quote_access_rec.Quote_Header_id,
                       x_is_it_quote     => l_is_it_quote);

   IF(l_is_it_quote = l_true) THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Notify_finish_sharing:l_is_it_quote: '||l_is_it_quote);
     END IF;
     l_notifName            := 'STOPWORKING_QUOTE';
     l_notif_context        := 'STOPWORKING_QUOTE';
     IF (p_context_code = 'IBE_SC_CART_ORDERED') THEN
       l_context_code := 'IBE_SC_QUOTE_ORDERED';
     ELSIF(p_context_code = 'IBE_SC_CART_STOPSHARING') THEN
       l_context_code := 'IBE_SC_QUOTE_STOPSHARING';
     END IF;

   ELSE
     l_notifName := 'STOPWORKING';
     l_notif_context := 'STOPWORKING';
   END IF;


   l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_finish_sharing: '||l_notifEnabled);
   END IF;
   IF l_notifEnabled = 'Y' THEN


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Notify_finish_sharing: Notification enabled');
         IBE_UTIL.DEBUG('Notify_finish_sharing:Querying owner party_id');
      END IF;
            FOR c_quote_rec In c_quote_header(p_quote_access_rec.Quote_Header_id)
	    LOOP
                 l_owner_partyid  := c_quote_rec.party_id;
                 l_orgid          := c_quote_rec.org_id;
                 l_cart_name      := c_quote_rec.quote_name;  -- cart name
                 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                    IBE_UTIL.DEBUG('Notify_finish_sharing:Quote_header_id for stop_sharing: '||p_quote_access_rec.Quote_Header_id);
                    IBE_UTIL.DEBUG('Notify_finish_sharing:Owner_party_id: '||l_owner_partyid);
                    IBE_UTIL.DEBUG('Notify_finish_sharing:Owner cart name: '||l_cart_name);
                 END IF;
            END LOOP;

            l_usertype     := FND_API.G_MISS_CHAR;
            l_sharedby_first_name := NULL;
            l_sharedby_last_name  := NULL;
            Get_Name_details(p_party_id           => p_shared_by_partyid,
                             p_user_type          => l_UserType,
                             x_contact_first_name => l_sharedby_first_name,
                             x_contact_last_name  => l_sharedby_last_name,
                             x_party_id           => x_owner_new_party_id);


           -- Dealing with context..........

           /*FOR rec_get_context_msg IN c_context_code(l_context_code)
           LOOP
               l_stop_working_msg_context := rec_get_context_msg.message_text;
           END LOOP;*/

          --whether to create adhoc users or not
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Notify_finish_sharing:locate_contact_point:whether to create adhoc users or not');
          END IF;
          locate_contact_point(
                    p_contact_point_id  => p_quote_access_rec.contact_point_id,
                    x_create_adhoc_flag => l_create_adhoc_flag);


          IF (l_create_adhoc_flag = FND_API.G_TRUE) THEN
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('Notify_finish_sharing:l_create_adhoc_flag: '||l_create_adhoc_flag);
            END IF;

            /*If an e-mail address is passed then the recipient party
             does not have a contact point, hence we create an adhoc user*/
            create_adhoc_entity
                ( p_quote_recipient_id     => p_quote_access_rec.QUOTE_SHAREE_ID
                ,p_quote_header_id         => p_quote_access_rec.quote_header_id
                ,p_email_address           => p_quote_access_rec.email_contact_address
                ,p_Notification_preference => l_notification_preference
                ,x_adhoc_role              => l_adhoc_role);
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
              IBE_UTIL.DEBUG('Notify_finish_sharing:Create_adhoc_entity: done');
            END IF;

          Else

            l_user_name := 'HZ_PARTY:'||p_quote_access_rec.party_id;
            l_adhoc_role := l_user_name;

          End If;

          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Notify_finish_sharing:l_adhoc_role: '||l_adhoc_role);
          END IF;


        -- Retrive Actual Message
            IF (IBE_UTIL.G_DEBUGON = l_true) THEN
               IBE_UTIL.DEBUG('Notify_finish_sharing:Retrievng message mapping');
            END IF;
            IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
              (
                p_org_id           => l_OrgId,
                p_msite_id         => p_minisite_id,
                p_user_type        => l_userType,
                p_notif_name       => l_notifName,
                x_enabled_flag     => l_msgEnabled,
                x_wf_message_name  => l_MessageName,
                x_return_status    => x_return_status,
                x_msg_data         => x_msg_data,
                x_msg_count        => x_msg_data);
           IF x_msg_count > 0 THEN
              Raise GET_MESSAGE_ERROR;
           END IF;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             IBE_UTIL.DEBUG('Notify_finish_sharing:After message mapping:l_messagename: '||l_MessageName);
             IBE_UTIL.DEBUG('Notify_finish_sharing:After message mapping:l_msg_enabled: '||l_msgEnabled);
          END IF;

          IF l_msgEnabled = 'Y' THEN

              -- Create Item Type and notification Preference
              l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_access_rec.Quote_Header_id
                         ||p_quote_access_rec.Quote_sharee_number;
              IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('Notify_finish_sharing:Item_key : '||l_item_key);
              END IF;
              -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
              -- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
              -- IBE_DEFAULT_USER_EMAIL_STYLE
                   l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');

             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                IBE_UTIL.DEBUG('Notify_finish_sharing:Create_process start');
             END IF;

             set_item_attributes
                  ( p_item_key     => l_item_key
                   ,p_message_name => l_MessageName
                   ,p_first_name   => l_sharedby_first_name
                   ,p_last_name    => l_sharedby_last_name
                   ,p_minisite_id  => p_minisite_id
                   ,p_cart_name    => l_cart_name
                   ,p_adhoc_role   => l_adhoc_role
                   ,p_context_msg  => l_context_code
                   ,p_notes        => p_notes
                   ,p_notif_context=> l_notif_context);

      END IF; --l_msgEnabled
    END IF;  --l_notif enabled
EXCEPTION

 WHEN OTHERS THEN
  x_return_status := FND_API.g_ret_sts_error;
  x_msg_count := 0;
  wf_core.context('IBE_WORKFLOW_PVT',l_notifName,l_notifName);
  RAISE;

END Notify_Finish_Sharing;

/********************************************************
 NotifyForSharedCart : Here the input parameters are
			         quote_access_record of the shared cart.
				    speciality store id,
				    URL of the shared cart.
Here owner will send email to the recepient.
Depending on the recepient user type (B2B/B2C) the email body
will be changed.
********************************************************/
PROCEDURE Notify_shared_cart (
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2,
    p_quote_access_rec   IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE,  --of the recepient
    p_minisite_id        IN  NUMBER,
    p_url                IN  VARCHAR2,
    p_shared_by_party_id IN  NUMBER := FND_API.G_MISS_NUM,
    p_notes              IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data           OUT NOCOPY VARCHAR2
 ) IS
    l_event_type               VARCHAR2(20) := 'SHARECARTNOTIF';
    l_notifEnabled             Varchar2(3) ;
    l_notifName                Varchar2(30):= 'SHARECARTNOTIF';
    l_notif_context            VARCHAR2(2000);
    l_Orgid                    Number := null;
    l_messageName              WF_MESSAGES.NAME%TYPE;
    l_msgEnabled               VARCHAR2(3);
    l_usertype                 jtf_um_usertypes_b.usertype_key%type := 'ALL' ;
    l_item_key                 WF_ITEMS.ITEM_KEY%TYPE;
    l_item_owner               WF_USERS.NAME%TYPE := 'SYSADMIN';
    l_user_name                WF_USERS.NAME%TYPE;
    l_notification_preference  WF_USERS.NOTIFICATION_PREFERENCE%TYPE ;
    l_msite_name               IBE_MSITES_VL.MSITE_NAME%TYPE;
    l_cart_name                ASO_QUOTE_HEADERS_ALL.QUOTE_NAME%TYPE;
    l_is_it_quote              VARCHAR2(1) := FND_API.G_FALSE;

    l_sharedby_first_name         HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
    l_sharedby_last_name          HZ_PARTIES.PERSON_LAST_NAME%TYPE;
    l_owner_partyid            HZ_PARTIES.PARTY_ID%TYPE;
    x_owner_new_party_id       HZ_PARTIES.PARTY_ID%TYPE;

    l_recepient_first_name     HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
    l_recepient_last_name      HZ_PARTIES.PERSON_LAST_NAME%TYPE;
    x_recepient_party_id       HZ_PARTIES.PARTY_ID%TYPE;
    l_accesslevel              VARCHAR2(60);

    l_role_users               Varchar2(400);
    l_adhoc_role               WF_ROLES.NAME%TYPE;
    l_adhoc_role_display       WF_ROLES.DISPLAY_NAME%TYPE;
    l_adhoc_user               WF_USERS.NAME%TYPE;
    l_adhoc_user_display       WF_USERS.DISPLAY_NAME%TYPE;
    l_create_adhoc_flag        VARCHAR2(1);

    l_temp_retrieve_str        VARCHAR2(1000);
    l_temp_update_str          VARCHAR2(1000);


BEGIN
 x_return_status :=  FND_API.g_ret_sts_success ;
 -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
 -- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');

 -- IBE_DEFAULT_USER_EMAIL_STYLE
    l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');
   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Notify_shared_cart:calling identify_cart_quote');
   END IF;


   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
     IBE_UTIL.DEBUG('Notify_shared_cart:Determining party_type');
   END IF;
   IF ((p_quote_access_rec.party_id is null )
       OR (p_quote_access_rec.party_id = FND_API.G_MISS_NUM)) THEN

     l_usertype := 'IBE_INDIVIDUAL';

   ELSE
     getUserType(p_quote_access_rec.party_id,l_UserType);
   END IF;

   identify_cart_quote(p_quote_header_id => p_quote_access_rec.Quote_Header_id,
                       x_is_it_quote     => l_is_it_quote);

   IF(l_is_it_quote = l_true) THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Notify_shared_cart:l_is_it_quote: '||l_is_it_quote);
     END IF;
     l_notifname   := 'SHAREQUOTENOTIF';
     IF (l_usertype = 'IBE_INDIVIDUAL') THEN
       l_notif_context := 'SHAREQUOTENOTIF';
     ELSE
       l_notif_context := 'SHAREQUOTENOTIF_B2B';
     END IF;
   ELSE
     l_notifname   := 'SHARECARTNOTIF';
     IF (l_usertype = 'IBE_INDIVIDUAL') THEN
       l_notif_context := 'SHARECARTNOTIF';
     ELSE
       l_notif_context := 'SHARECARTNOTIF_B2B';
     END IF;
   END IF;

 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_UTIL.DEBUG('Notify_shared_cart:l_notifname: '||l_notifName);
   IBE_UTIL.DEBUG('Notify_shared_cart:l_usertype: '||l_usertype);
 END IF;
 l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);
 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   IBE_UTIL.DEBUG('Notify_shared_cart:Shared cart notification enabled: '||l_notifEnabled);
 END IF;

 IF l_notifEnabled = 'Y' THEN
   --get owner party_id, cart_name here from input quote_header_id
   FOR c_quote_rec IN c_quote_header(p_quote_access_rec.Quote_Header_id)
   LOOP
      l_owner_partyid  := c_quote_rec.party_id;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_shared_cart:Owner party_id: '||l_owner_partyid);
      END IF;
      l_orgid          := c_quote_rec.org_id;
      l_cart_name      := c_quote_rec.quote_name;  -- cart name
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_shared_cart:cart name: '||l_cart_name);
      END IF;
    END LOOP;

    --get owner name from owner party_id obtained above
    l_sharedby_first_name := NULL;
    l_sharedby_last_name  := NULL;
    Get_Name_details(p_party_id           => p_shared_by_party_id,
                     p_user_type          => l_UserType,
                     x_contact_first_name => l_sharedby_first_name,
                     x_contact_last_name  => l_sharedby_last_name,
                     x_party_id           => x_owner_new_party_id);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_shared_cart:Owner first name: '||l_sharedby_first_name);
      IBE_UTIL.DEBUG('Notify_shared_cart:owner last name: '||l_sharedby_last_name);
    END IF;
    --whether to create adhoc user or not

    locate_contact_point(
              p_contact_point_id  => p_quote_access_rec.contact_point_id,
              x_create_adhoc_flag => l_create_adhoc_flag);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_shared_cart:l_create_adhoc_flag: '||l_create_adhoc_flag);
    END IF;

    --if create adhoc user flag is "true" then call wf_directory API
    IF (l_create_adhoc_flag = FND_API.G_TRUE) THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_shared_cart:l_create_adhoc_flag is true');
        IBE_UTIL.DEBUG('Notify_shared_cart:p_quote_access_rec.QUOTE_SHAREE_ID: '||p_quote_access_rec.QUOTE_SHAREE_ID);
        IBE_UTIL.DEBUG('Notify_shared_cart:p_quote_access_rec.quote_header_id: '||p_quote_access_rec.quote_header_id);
      END IF;

      create_adhoc_entity
          ( p_quote_recipient_id      => p_quote_access_rec.QUOTE_SHAREE_ID
           ,p_quote_header_id         => p_quote_access_rec.quote_header_id
           ,p_email_address           => p_quote_access_rec.email_contact_address
           ,p_Notification_preference => l_notification_preference
           ,x_adhoc_role              => l_adhoc_role);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_shared_cart:Create_adhoc_entity: done');
      END IF;
    Else

      l_user_name  := 'HZ_PARTY:'||p_quote_access_rec.party_id;
      l_adhoc_role := l_user_name;

    End If; --create adhoc user or not

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_shared_cart:l_adhoc role: '||l_adhoc_role);
    END IF;

    --Get Access Level Info.
/*    IF (p_quote_access_rec.UPDATE_PRIVILEGE_TYPE_CODE = 'A') THEN
      l_accesslevel := 'Administrator';
    ELSIF (p_quote_access_rec.UPDATE_PRIVILEGE_TYPE_CODE = 'F' OR
           p_quote_access_rec.UPDATE_PRIVILEGE_TYPE_CODE = 'U' ) THEN
      l_accesslevel := 'Participant';
    ELSE
      l_accesslevel := 'Viewer';
    END IF;*/

    -- Retrive Actual Message
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_shared_cart:retrieving message mapping');
    END IF;

    -- Retrieve the message text for update message from fnd_messages

    IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
      (
        p_org_id           => l_OrgId,
        p_msite_id         => p_minisite_id,
        p_user_type        => l_userType,
        p_notif_name       => l_notifName,
        x_enabled_flag     => l_msgEnabled,
        x_wf_message_name  => l_MessageName,
        x_return_status    => x_return_status,
        x_msg_data         => x_msg_data,
        x_msg_count        => x_msg_data);

    IF x_msg_count > 0 THEN
      Raise GET_MESSAGE_ERROR;
    END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_shared_cart:Message_name: '||l_messageName);
      IBE_UTIL.DEBUG('Notify_shared_cart:l_msgenabled: '||l_msgenabled);
    END IF;

    IF l_msgEnabled = 'Y' THEN

      -- Create Item Type and notification Preference
      l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_access_rec.Quote_Header_id
                                ||p_quote_access_rec.Quote_sharee_number;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_shared_cart:Item_key: '||l_item_key);
      END IF;
     -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
     -- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
     -- IBE_DEFAULT_USER_EMAIL_STYLE
     l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');

      set_item_attributes
                  ( p_item_key         => l_item_key
                   ,p_message_name     => l_MessageName
                   ,p_access_level     => p_quote_access_rec.UPDATE_PRIVILEGE_TYPE_CODE
                   ,p_recipient_number => p_quote_access_rec.quote_sharee_number
                   ,p_first_name       => l_sharedby_first_name
                   ,p_last_name        => l_sharedby_last_name
                   ,p_url              => p_url
                   ,p_minisite_id      => p_minisite_id
                   ,p_cart_name        => l_cart_name
                   ,p_adhoc_role       => l_adhoc_role
                   ,p_notes            => p_notes
                   ,p_notif_context    => l_notif_context);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_shared_cart:Set_item_attributes: Done');
      END IF;
    END IF; ----l_msgEnabled
 END IF;   -- l_notifenabled
EXCEPTION

 WHEN OTHERS THEN
  x_return_status := FND_API.g_ret_sts_error;
  x_msg_count := 0;
  wf_core.context('IBE_WORKFLOW_PVT',l_notifName,l_notifName);
  RAISE;

END Notify_Shared_Cart ;

/********************************************************
 Notify_Access_Change: Here the input parameters are
			         quote_access_record of the shared cart.
				    speciality store id,
				    old_access_level of the recepient
				    URL of the shared cart.
Here owner will send email to the recepient.
This email states that the recepient access level is changed from old access level
to the new access level.
********************************************************/
PROCEDURE Notify_Access_Change(
    p_api_version        IN  NUMBER,
    p_init_msg_list      IN  VARCHAR2,
    p_quote_access_rec   IN  IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE,  --of the recepient
    p_minisite_id        IN  NUMBER,
    p_url                IN  VARCHAR2,
    p_old_accesslevel    IN  VARCHAR2,
    p_shared_by_party_id IN  NUMBER := FND_API.G_MISS_NUM,
    p_notes              IN  VARCHAR2,
    x_return_status      OUT NOCOPY VARCHAR2,
    x_msg_count          OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
 ) IS
    l_event_type               VARCHAR2(20) := 'ACCESSCHANGE';
    l_notifEnabled             Varchar2(3);
    l_notifName                Varchar2(30) := 'CHANGEACCESSLEVEL';
    l_notif_context            VARCHAR2(2000);
    l_Orgid                    Number := null;
    l_messageName              WF_MESSAGES.NAME%TYPE;
    l_msgEnabled               VARCHAR2(3);
    l_usertype                 jtf_um_usertypes_b.usertype_key%type := 'ALL' ;
    l_item_key                 WF_ITEMS.ITEM_KEY%TYPE;
    l_item_owner               WF_USERS.NAME%TYPE := 'SYSADMIN';
    l_user_name                WF_USERS.NAME%TYPE;
    l_notification_preference  WF_USERS.NOTIFICATION_PREFERENCE%TYPE ;
    l_msite_name               IBE_MSITES_VL.MSITE_NAME%TYPE;
    l_cart_name                ASO_QUOTE_HEADERS_ALL.QUOTE_NAME%TYPE;
    l_is_it_quote              varchar2(1) := FND_API.G_FALSE;

    l_sharedby_first_name         HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
    l_sharedby_last_name          HZ_PARTIES.PERSON_LAST_NAME%TYPE;
    l_owner_partyid            HZ_PARTIES.PARTY_ID%TYPE;
    x_owner_new_party_id       HZ_PARTIES.PARTY_ID%TYPE;

    l_recepient_first_name     HZ_PARTIES.PERSON_FIRST_NAME%TYPE;
    l_recepient_last_name      HZ_PARTIES.PERSON_LAST_NAME%TYPE;
    x_recepient_party_id       HZ_PARTIES.PARTY_ID%TYPE;

    l_new_access_level         VARCHAR2(60);
    l_old_access_level         VARCHAR2(60);

    l_role_users               Varchar2(400);
    l_adhoc_role               WF_ROLES.NAME%TYPE;
    l_adhoc_role_display       WF_ROLES.DISPLAY_NAME%TYPE;
    l_adhoc_user               WF_USERS.NAME%TYPE;
    l_adhoc_user_display       WF_USERS.DISPLAY_NAME%TYPE;
    l_create_adhoc_flag        VARCHAR2(1);
    l_quote_access_rec         IBE_QUOTE_SAVESHARE_pvt.QUOTE_ACCESS_REC_TYPE;
    l_temp_update_str          VARCHAR2(1000);
    l_url                      VARCHAR2(2000);

    cursor c_get_email(c_contact_point_id NUMBER) is
    select email_address
    from HZ_CONTACT_POINTS
    where contact_point_id = c_contact_point_id;

    rec_get_email c_get_email%rowtype;

BEGIN
 x_return_status :=  FND_API.g_ret_sts_success ;
 -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
 -- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
 -- IBE_DEFAULT_USER_EMAIL_STYLE
 l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');
 l_quote_access_rec := p_quote_access_rec;

 identify_cart_quote(p_quote_header_id => l_quote_access_rec.Quote_Header_id,
                     x_is_it_quote     => l_is_it_quote);

   IF(l_is_it_quote = l_true) THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Notify_shared_cart:l_is_it_quote: '||l_is_it_quote);
     END IF;
     l_notifName     := 'CHANGEACCESSLEVEL_QUOTE';
     l_notif_context := 'CHANGEACCESSLEVEL_QUOTE';
   ELSE
     l_notif_context := 'CHANGEACCESSLEVEL';
   END IF;


  l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_access_change:l_notifEnabled: '||l_notifEnabled);
    END IF;
    --l_notifEnabled := 'Y';
    If l_notifEnabled = 'Y' Then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_access_change:Notification enabled');
        IBE_UTIL.DEBUG('Notify_access_change:Quote_header_id of shared cart: '||l_quote_access_rec.Quote_Header_id);
      END IF;
      FOR c_quote_rec In c_quote_header(l_quote_access_rec.Quote_Header_id) LOOP
          l_owner_partyid  := c_quote_rec.party_id;
          l_orgid          := c_quote_rec.org_id;
          l_cart_name      := c_quote_rec.quote_name;  -- cart name
      END LOOP;

      l_usertype     := FND_API.G_MISS_CHAR;
      l_sharedby_first_name := NULL;
      l_sharedby_last_name  := NULL;
      Get_Name_details(p_party_id           => p_shared_by_party_id,
                       p_user_type          => l_UserType,
                       x_contact_first_name => l_sharedby_first_name,
                       x_contact_last_name  => l_sharedby_last_name,
                       x_party_id           => x_owner_new_party_id);

      -- Now identify whether the recepient is B2B or B2C ****
      -- Call the Get_Name_details to get the party_id of the recepient.
      -- And pipe it with HZ_PARTIES to get email id of the recepient.

      l_usertype     := FND_API.G_MISS_CHAR;
      x_recepient_party_id := 0;
      Get_Name_details(p_party_id           => l_quote_access_rec.party_id,
                       p_user_type          => l_UserType,
                       x_contact_first_name => l_recepient_first_name,
                       x_contact_last_name  => l_recepient_last_name,
                       x_party_id           => x_recepient_party_id);

      l_user_name := 'HZ_PARTY:'||x_recepient_party_id;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_access_change:recipient first name: '||l_recepient_first_name);
        IBE_UTIL.DEBUG('Notify_access_change:recipient last name: '||l_recepient_last_name);
        IBE_UTIL.DEBUG('Notify_access_change:recipient party_id: '||x_recepient_party_id);
      END IF;


      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_access_change:Calling locate_contact_point');
      END IF;

      locate_contact_point(
                    p_contact_point_id  => l_quote_access_rec.contact_point_id,
                    x_create_adhoc_flag => l_create_adhoc_flag);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_access_change:l_create_adhoc_flag: '||l_create_adhoc_flag);
      END IF;
      IF (l_create_adhoc_flag = FND_API.G_TRUE) THEN

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('Notify_access_change:Opening c_get_email');
        END IF;

        FOR rec_get_email in c_get_email(l_quote_access_rec.contact_point_id) LOOP
          l_quote_access_rec.email_contact_address := rec_get_email.email_address;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
            IBE_UTIL.DEBUG('Notify_access_change:email address in c_get_email: '||l_quote_access_rec.email_contact_address);
          END IF;
          EXIT WHEN c_get_email%notfound;
        END LOOP;

        /*If an e-mail address is passed then the recipient party
        does not have a contact point, hence we create an adhoc user*/

        create_adhoc_entity
          ( p_quote_recipient_id      => l_quote_access_rec.QUOTE_SHAREE_ID
           ,p_quote_header_id         => l_quote_access_rec.quote_header_id
           ,p_email_address           => l_quote_access_rec.email_contact_address
           ,p_Notification_preference => l_notification_preference
           ,x_adhoc_role              => l_adhoc_role);
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          IBE_UTIL.DEBUG('Notify_access_change:Create_adhoc_entity: done');
        END IF;

      Else --for create_adhoc_flag

        l_user_name := 'HZ_PARTY:'||l_quote_access_rec.party_id;
        l_adhoc_role := l_user_name;

      End If; --for create_adhoc_flag

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_access_change:l_adhoc_role: '||l_adhoc_role);
      END IF;

      -- Retrive Actual Message
      IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
        (
         p_org_id          => l_OrgId,
         p_msite_id        => p_minisite_id,
         p_user_type       => l_userType,
         p_notif_name      => l_notifName,
         x_enabled_flag    => l_msgEnabled,
         x_wf_message_name => l_MessageName,
         x_return_status   => x_return_status,
         x_msg_data        => x_msg_data,
         x_msg_count       => x_msg_data);

      IF x_msg_count > 0 THEN
        Raise GET_MESSAGE_ERROR;
      END IF;

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_access_change:After message mapping call:l_MessageName: '||l_MessageName);
        IBE_UTIL.DEBUG('Notify_access_change:l_msgEnabled: '||l_msgEnabled);
      END IF;

      -- Retrieve the message text for update message from fnd_messages
      fnd_message.set_name('IBE','IBE_PRMT_UPDATE_CART');
      l_temp_update_str := FND_API.G_MISS_CHAR;
      l_temp_update_str := fnd_message.get;
      --l_msgEnabled := 'Y';
      IF l_msgEnabled = 'Y' THEN
     l_url := p_url;
	 l_url := l_url||p_quote_access_rec.quote_sharee_number;
      -- Create Item Type and notification Preference
      l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||l_quote_access_rec.Quote_Header_id||
                    l_quote_access_rec.quote_sharee_number ;
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Notify_access_change:Calling set_item_attributes');
       END IF;
       set_item_attributes
                  ( p_item_key         => l_item_key
                   ,p_message_name     => l_messagename
                   ,p_access_level     => l_quote_access_rec.UPDATE_PRIVILEGE_TYPE_CODE
                   ,p_old_access_level => P_old_accesslevel
                   ,p_first_name       => l_sharedby_first_name
                   ,p_last_name        => l_sharedby_last_name
                   ,p_url              => l_url
                   ,p_minisite_id      => p_minisite_id
                   ,p_cart_name        => l_cart_name
                   ,p_adhoc_role       => l_adhoc_role
                   ,p_notes            => p_notes
                   ,p_notif_context    => l_notif_context);
       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Notify_access_change:Done calling set_item_attributes');
       END IF;
     END IF;  --l_msgEnabled
    END IF;  --l_notifenabled
EXCEPTION

 WHEN OTHERS THEN
  x_return_status := FND_API.g_ret_sts_error;
  x_msg_count := 0;
  wf_core.context('IBE_WORKFLOW_PVT',l_notifName,l_notifName);
  RAISE;

END Notify_access_change;

PROCEDURE Notify_view_shared_cart(
    p_api_version       IN  NUMBER,
    p_init_msg_list     IN  VARCHAR2,
    p_quote_access_rec  IN  IBE_QUOTE_SAVESHARE_PVT.QUOTE_ACCESS_REC_TYPE, --of the recepient
    p_minisite_id       IN  NUMBER,
    p_url               IN  VARCHAR2,
    p_sent_by_party_id  IN  NUMBER  ,
    p_notes             IN  VARCHAR2,
    p_owner_party_id    IN  NUMBER  := FND_API.G_MISS_NUM,
    x_return_status     OUT NOCOPY VARCHAR2,
    x_msg_count         OUT NOCOPY NUMBER,
    x_msg_data          OUT NOCOPY VARCHAR2
    ) is

cursor c_quote_name(c_qte_header_id number) is
  select quote_name
  from   aso_quote_headers_all
  where quote_header_id = c_qte_header_id;

cursor c_get_email(c_contact_point_id NUMBER) is
  select email_address
  from HZ_CONTACT_POINTS
  where contact_point_id = c_contact_point_id;

rec_get_email        c_get_email%rowtype;
rec_quote_name       c_quote_name%rowtype;

l_item_owner          WF_USERS.NAME%TYPE := 'SYSADMIN';
l_item_key            WF_ITEMS.ITEM_KEY%TYPE;
l_event_type          VARCHAR2(100)      := 'VIEWSHAREDCART';

l_sent_by_first_name  VARCHAR2(1000);
l_sent_by_last_name   VARCHAR2(1000);
l_sent_by_party_id    NUMBER;
l_owner_first_name    VARCHAR2(1000);
l_owner_last_name     VARCHAR2(1000);
l_owner_party_id      NUMBER;
l_quote_name          VARCHAR2(1000);
l_user_Type           jtf_um_usertypes_b.usertype_key%type;
l_msg_Enabled         VARCHAR2(1);
l_msg_name            VARCHAR2(1000);
l_org_id              NUMBER;
l_create_adhoc_flag   VARCHAR2(10);
l_adhoc_role          VARCHAR2(2000);
l_url                 VARCHAR2(4000);
l_access_code         VARCHAR2(2000);
l_email_address       VARCHAR2(2000);
l_notif_Enabled       VARCHAR2(1);

l_notif_name          VARCHAR2(1000) := 'IBE_VIEWSHAREDCART';
l_notification_preference   WF_USERS.NOTIFICATION_PREFERENCE%TYPE;
BEGIN
x_return_status :=  FND_API.g_ret_sts_success ;
IBE_UTIL.DEBUG('Notify_view_shared_cart: START');

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('Check if this notification is enabled.');
  END IF;

  l_notif_Enabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notif_Name);
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('Notification Name: '||l_notif_Name||' Enabled: '||l_notif_Enabled);
  END IF;

 -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
 -- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
 -- IBE_DEFAULT_USER_EMAIL_STYLE
 l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');
  locate_contact_point(
     p_contact_point_id  => p_quote_access_rec.contact_point_id,
     x_create_adhoc_flag => l_create_adhoc_flag);


  IF (l_create_adhoc_flag = FND_API.G_TRUE) THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_view_shared_cart:l_create_adhoc_flag: '||l_create_adhoc_flag);
    END IF;


    FOR rec_get_email in c_get_email(p_quote_access_rec.contact_point_id) LOOP
      l_email_address := rec_get_email.email_address;
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_access_change:email address in c_get_email: '||l_email_address);
      END IF;
      EXIT WHEN c_get_email%notfound;
    END LOOP;

    /*If an e-mail address is passed then the recipient party
    does not have a contact point, hence we create an adhoc user*/
    create_adhoc_entity
      ( p_quote_recipient_id     => p_quote_access_rec.QUOTE_SHAREE_ID
      ,p_quote_header_id         => p_quote_access_rec.quote_header_id
      ,p_email_address           => l_email_address
      ,p_Notification_preference => l_notification_preference
      ,x_adhoc_role              => l_adhoc_role);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_view_shared_cart:Create_adhoc_entity: done');
      END IF;

  ELSE
    l_adhoc_role := 'HZ_PARTY:'||p_quote_access_rec.party_id;
  END IF;


  IF l_notif_Enabled = 'Y' THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_view_shared_cart:sent_by_party_id: '||p_sent_by_party_id);
      IBE_UTIL.DEBUG('Notify_view_shared_cart:Calling get_name_details for the owner');
      IBE_UTIL.DEBUG('Notify_view_shared_cart:p_quote_access_rec.party_id '||p_quote_access_rec.party_id);
    END IF;

    Get_Name_details(p_party_id            => p_sent_by_party_id,
                      p_user_type          => FND_API.G_MISS_CHAR,
                      x_contact_first_name => l_sent_by_first_name,
                      x_contact_last_name  => l_sent_by_last_name,
                      x_party_id           => l_sent_by_party_id);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_view_shared_cart:sent_by first name: '||l_sent_by_first_name);
      IBE_UTIL.DEBUG('Notify_view_shared_cart:sent_by last name: '||l_sent_by_last_name);
    END IF;

    FOR rec_quote_name in c_quote_name(p_quote_access_rec.quote_header_id) LOOP
      l_quote_name := rec_quote_name.quote_name;
      EXIT when c_quote_name%NOTFOUND;
    END LOOP;

    getusertype(p_quote_access_rec.party_id, l_user_type);

    IF ((p_owner_party_id is not null ) AND
        (p_owner_party_id <> FND_API.G_MISS_NUM)) THEN
      l_url := p_url;
      l_access_code :='O';
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Notify_view_shared_cart:l_access_code '||l_access_code);
      END IF;
    ELSE
      l_access_code := p_quote_access_rec.UPDATE_PRIVILEGE_TYPE_CODE;
      l_url := p_url;
      l_url := l_url|| p_quote_access_rec.quote_sharee_number;
    END IF;

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_view_shared_cart:quote name: '||l_quote_name);
      IBE_UTIL.DEBUG('Notify_view_shared_cart:retrieving message mapping');
    END IF;

    l_org_Id := MO_GLOBAL.get_current_org_id();
    IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
      (
	    p_org_id           => l_Org_Id,
        p_msite_id         => p_minisite_id,
        p_user_type	       => l_user_Type,
	    p_notif_name 	   => l_notif_Name,
        x_enabled_flag     => l_msg_Enabled,
        x_wf_message_name  => l_msg_name,
        x_return_status    => x_return_status,
        x_msg_data 	       => x_msg_data,
        x_msg_count	       => x_msg_data);

    IF x_msg_count > 0 Then
      Raise GET_MESSAGE_ERROR;
    END IF;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      ibe_util.debug('Message Name: '||l_msg_name||' Enabled: '||l_msg_Enabled);
    END IF;

    IF l_msg_Enabled = 'Y' THEN
      IF (p_quote_access_rec.Quote_sharee_number is not null AND
	     p_quote_access_rec.Quote_sharee_number <> FND_API.G_MISS_NUM) THEN
        l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_access_rec.Quote_Header_id
                                  ||p_quote_access_rec.Quote_sharee_number;
      ELSE
        l_item_key := l_event_type||'-'||to_char(sysdate,'MMDDYYHH24MISS')||'-'||p_quote_access_rec.Quote_Header_id;
      END IF;

    -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
    --  l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
    -- IBE_DEFAULT_USER_EMAIL_STYLE
    l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        ibe_util.debug('view_shared_cart:item_key: '||l_item_key);
        ibe_util.debug('ready to create process');
      END IF;

      wf_engine.CreateProcess(
        itemtype 	=> g_ItemType,
        itemkey   => l_item_key,
        process   => g_processName);

      wf_engine.SetItemUserKey(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          userkey   => l_item_key);

      wf_engine.SetItemAttrText(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          aname     => 'MESSAGE',
          avalue    => l_msg_name);

      wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => l_item_key,
          aname     => 'SENTBYFIRSTNAME',
          avalue    => l_sent_by_first_name);

      wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => l_item_key,
          aname     => 'SENTBYLASTNAME',
          avalue    => l_sent_by_last_name);

      wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => l_item_key,
          aname     => 'FIRSTNAME',
          avalue    => l_owner_first_name);

      wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => l_item_key,
          aname     => 'LASTNAME',
          avalue    => l_owner_last_name);


      wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => l_item_key,
          aname     => 'CARTNAME',
          avalue    => l_quote_name);

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Notify_view_shared_cart:ACCESSCODE: '||p_quote_access_rec.UPDATE_PRIVILEGE_TYPE_CODE);
    END IF;
      wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => l_item_key,
          aname     => 'ACCESSCODE',
          avalue    => l_access_code);

      wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => l_item_key,
          aname     => 'ISTOREURL',
          avalue    => L_url);

      wf_engine.SetItemAttrText(
        itemtype  => g_ItemType,
        itemkey   => l_item_key,
        aname     => 'DATE_ITEMKEY',
        avalue    => l_item_key);

	  wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => l_item_key,
          aname     => 'SHARECOMMENTS',
          avalue    => p_notes);

       wf_engine.SetItemAttrText(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key,
          aname     => 'MSITEID',
          avalue    => p_minisite_id);

       wf_engine.SetItemAttrText(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          aname    => 'UPDATEMSG_CODE',
          avalue   => 'IBE_PRMT_UPDATE_CART');

      wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
          itemkey   => l_item_key,
          aname     => 'SENDTO',
          avalue    => l_adhoc_role);

      wf_engine.SetItemOwner(
          itemtype => g_ItemType,
          itemkey  => l_item_key,
          owner    => l_item_owner);

      wf_engine.StartProcess(
          itemtype 	=> g_ItemType,
          itemkey  	=> l_item_key);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	    IBE_UTIL.DEBUG('Process Started');
      END IF;

    END IF;
  END IF;
EXCEPTION

 WHEN OTHERS THEN
  x_return_status := FND_API.g_ret_sts_error;
  x_msg_count := 0;
  --wf_core.context('IBE_WORKFLOW_PVT',l_notifName,l_notifName);
  RAISE;

END;


------------------------------------------------------------------------

PROCEDURE NotifyForSharedCart (
    p_api_version		IN	NUMBER,
	p_init_msg_list		IN	VARCHAR2 := FND_API.G_FALSE,
    p_Quote_Header_id       IN   	NUMBER,
 	p_emailAddress          IN   	VARCHAR2,
	p_quoteShareeNum	IN	NUMBER,
	p_privilegeType         IN   	VARCHAR2,
  	p_url                   IN   	VARCHAR2,
	p_comments              IN   	VARCHAR2 := FND_API.G_MISS_CHAR,
	x_return_status		OUT NOCOPY	VARCHAR2,
	x_msg_count		OUT NOCOPY	NUMBER,
	x_msg_data		OUT NOCOPY	VARCHAR2
	) IS


BEGIN

NotifyForSharedCart (
	p_api_version,
	p_init_msg_list,
	null,
        p_Quote_Header_id,
 	p_emailAddress,
	p_quoteShareeNum,
	p_privilegeType,
  	p_url,
	p_comments,
	x_return_status,
	x_msg_count,
	x_msg_data);


End NotifyForSharedCart;


PROCEDURE NotifyForSharedCart (
  p_api_version     IN  NUMBER,
  p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
  p_Msite_id        IN 	NUMBER,
  p_Quote_Header_id IN  NUMBER,
  p_emailAddress    IN  VARCHAR2,
  p_quoteShareeNum  IN  NUMBER,
  p_privilegeType   IN  VARCHAR2,
  p_url             IN  VARCHAR2,
  p_comments        IN  VARCHAR2 := FND_API.G_MISS_CHAR,
  x_return_status   OUT NOCOPY VARCHAR2,
  x_msg_count       OUT NOCOPY NUMBER,
  x_msg_data        OUT NOCOPY VARCHAR2
  ) IS

  l_event_type    Varchar2(30) := 'SHAREDCART';
  l_notifEnabled  Varchar2(3)  := 'Y';
  l_notifName     Varchar2(30) := 'SHAREDCART';
  l_OrgId         Number       := null;
  l_UserType      jtf_um_usertypes_b.usertype_key%type := 'ALL';
  l_messageName   WF_MESSAGES.NAME%TYPE;
  l_msgEnabled    VARCHAR2(3) :='Y';
  l_partyid       Number;
  l_item_key      WF_ITEMS.ITEM_KEY%TYPE;
  l_item_owner    WF_USERS.NAME%TYPE := 'SYSADMIN';
  l_user_name     WF_USERS.NAME%TYPE;
  l_role_users    Varchar2(200);
  l_adhoc_role    WF_ROLES.NAME%TYPE;
  l_adhoc_role_display	     WF_ROLES.DISPLAY_NAME%TYPE;
  l_adhoc_user               WF_USERS.NAME%TYPE;
  l_adhoc_user_display       WF_USERS.DISPLAY_NAME%TYPE;
  l_notification_preference  WF_USERS.NOTIFICATION_PREFERENCE%TYPE;
  l_quote_name               Varchar2(50);
  l_quote_Num                Number;
  l_quote_ver                Number;
  l_quote_password           Varchar2(240);

     --2299210
  l_first_name_sc            VARCHAR2(360) := 'Firstname';
  l_last_name_sc             VARCHAR2(360);
  l_dummy_document_type      VARCHAR2(200);

BEGIN
  x_return_status :=  FND_API.g_ret_sts_success;

  -- Check for WorkFlow Feature Availablity.
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Check if this notification is enabled.');
    END IF;
    l_notifEnabled := IBE_WF_NOTIF_SETUP_PVT.Check_Notif_Enabled(l_notifName);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Notification Name: '||l_notifName||' Enabled: '||l_notifEnabled);
    END IF;
    If l_notifEnabled = 'Y' Then
      FOR c_quote_rec In c_quote_header(p_Quote_Header_id) LOOP
        l_user_name      :='HZ_PARTY:'||c_quote_rec.party_id;
        l_orgid          := c_quote_rec.org_id;
        l_quote_name     := c_quote_rec.quote_name;
        l_partyId        := c_quote_rec.party_id;
        l_quote_password := c_quote_rec.quote_password;
        l_quote_num      := c_quote_rec.quote_number;
        l_quote_ver      := c_quote_rec.quote_version;
      END LOOP;
	   --2299210
      GetFirstName (p_Quote_Header_id,
                              null,
                              l_first_name_sc,
                              l_dummy_document_type);

      GetLastName (p_Quote_Header_id, null,
                   l_last_name_sc,
                   l_dummy_document_type);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Sharee First Name: '||nvl(l_first_name_sc,'noname'));
         ibe_util.debug('Sharee Last Name: '||l_last_name_sc);
      END IF;

      getUserType(l_partyId,l_UserType);
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Get Message - MsiteId: '||to_Char(p_msite_id)||' Org_id: '||to_char(l_orgId)
 	                 ||' User Type: '||l_userType);
      END IF;
      IBE_WF_MSG_MAPPING_PVT.Retrieve_Msg_Mapping
      (
	    p_org_id           => l_OrgId,
        p_msite_id         => p_msite_id,
        p_user_type	       => l_userType,
	    p_notif_name 	   => l_notifName,
        x_enabled_flag     => l_msgEnabled,
        x_wf_message_name  => l_MessageName,
        x_return_status    => x_return_status,
        x_msg_data 	       => x_msg_data,
        x_msg_count	       => x_msg_data);

      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('Message Name: '||l_MessageName||' Enabled: '||l_msgEnabled);
      END IF;
      If x_msg_count > 0 Then
        Raise GET_MESSAGE_ERROR;
      End if;

      if l_msgEnabled = 'Y' Then
        l_item_key := l_event_type||'-'||p_quoteShareeNum||'-'||p_Quote_Header_id;
        -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
       -- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
       -- IBE_DEFAULT_USER_EMAIL_STYLE
       l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');
        If p_emailaddress is not null Then
          l_adhoc_user 	:= 'SCU'||p_quoteShareeNum||'Q'||p_Quote_Header_id ;
          l_adhoc_user_display := 'SCU'||p_quoteShareeNum||'Q'||p_Quote_Header_id;
          wf_directory.CreateAdHocUser(
            name                    => l_adhoc_user,
            display_name            => l_adhoc_user_display,
            notification_preference => l_notification_preference,
            email_address 	        => p_emailAddress,
            expiration_date         => sysdate + 1);

            --l_user_name 	 :='HZ_PARTY:'||c_quote_rec.party_id;
            --l_adhoc_user  := 'SCU'||p_quoteShareeNum||'Q'||p_Quote_Header_id ;
          l_role_users := l_user_name||','||l_adhoc_user;
          l_adhoc_role := 'SCR'||p_quoteShareeNum||'Q'||p_Quote_Header_id;
          l_adhoc_role_display := 'SCR'||p_quoteShareeNum||'Q'||p_Quote_Header_id;
          wf_directory.CreateAdHocRole
            (role_name               => l_adhoc_role,
             role_display_name       => l_adhoc_role_display,
             notification_preference => l_notification_preference,
       	     role_users              => l_role_users,
             expiration_date         => sysdate + 1);
        Else
          l_adhoc_role := l_user_name;
        End If;


	 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	 ibe_util.debug('Create and Start Process with Item Key: '||l_item_key);
	 END IF;

		wf_engine.CreateProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			process  	=> g_processName);

		wf_engine.SetItemUserKey(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			userkey		=> l_item_key);

	       	wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'MESSAGE',
			avalue		=>  l_MessageName);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'PASSWORD',
			avalue		=> l_quote_password);


		wf_engine.SetItemAttrNumber(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname	=> 'QUOTEID',
			avalue	=> p_Quote_Header_id);


		wf_engine.SetItemAttrNumber(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname	=> 'QUOTENUM',
			avalue	=> l_quote_num);

		wf_engine.SetItemAttrNumber(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname	=> 'QUOTEVER',
			avalue	=> l_quote_ver);

		wf_engine.SetItemAttrNumber(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname	=> 'SHNUM',
			avalue	=> p_quoteShareeNum);


		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'QUOTENAME',
			avalue		=> l_quote_name);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'ISTOREURL',
			avalue		=> p_url);

		wf_engine.SetItemAttrText(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'COMMENTS',
			avalue		=> p_Comments);

          --2299210
		wf_engine.SetItemAttrText(
		     itemtype 	=> g_ItemType,
		     itemkey  	=> l_item_key,
		     aname		=> 'FIRSTNAME',
		     avalue		=> l_first_name_sc);

		wf_engine.SetItemAttrText(
		     itemtype 	=> g_ItemType,
		     itemkey  	=> l_item_key,
		     aname		=> 'LASTNAME',
		     avalue		=> l_last_name_sc);

        wf_engine.SetItemAttrText(
          itemtype  => g_ItemType,
		  itemkey   => l_item_key,
		  aname     => 'MSITEID',
		  avalue    => p_msite_id);

		wf_engine.SetItemAttrText(
			itemtype	=> g_ItemType,
			itemkey  	=> l_item_key,
			aname		=> 'SENDTO',
			avalue		=> l_adhoc_role);


		wf_engine.SetItemOwner(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key,
			owner		=> l_item_owner);

		wf_engine.StartProcess(
			itemtype 	=> g_ItemType,
			itemkey  	=> l_item_key);

	 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	 ibe_util.debug('Process Started');
	 END IF;

	 End If;
      End If;
Exception

	When OTHERS Then
		x_return_status := FND_API.g_ret_sts_error;
		x_msg_count := 0;
		wf_core.context('ibe_workflow_pvt','SHAREDCART','SHAREDCART');
		raise;
End NotifyForSharedCart;



PROCEDURE ParseThisString (
	p_string_in	IN	VARCHAR2,
	p_string_out	OUT NOCOPY	VARCHAR2,
	p_string_left	OUT NOCOPY	VARCHAR2
) IS

l_lengthy_word BOOLEAN;
l_line_length	NUMBER;
l_length		NUMBER;
l_lim		NUMBER;
i		NUMBER;
j		NUMBER;
l_pos		NUMBER;
l_pre_pos   NUMBER;
temp1     NUMBER;
temp2     NUMBER;

BEGIN
	l_line_length := 20;
	l_length := length(p_string_in);
	IF ( l_length < l_line_length ) THEN
		p_string_out := rpad(p_string_in,20,' ');
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
				l_pos := 18;
				l_lengthy_word := true;
			END IF;
			IF ( j <> 0 ) THEN
				i := j+1;
				l_pre_pos := l_pos; -- bug 13363458, nsatyava
				l_pos := j;
			END IF;
			EXIT WHEN j = 0;
		END LOOP;

            --added fix to avoid inifinite loop when word longer than 20 - 13363458
            temp1 := 1;
            temp2 := 1;
            temp2 := instr(p_string_in,' ',temp1);
            if (temp2-temp1) >19 then
                 l_lengthy_word := true;
                 l_pos := 18;
            else
                    IF (l_pos > 20 ) THEN
                    l_pos := l_pre_pos;
                   END IF;
             end if;


		p_string_out := substr(p_string_in,1,l_pos);
          IF ( l_lengthy_word = true ) THEN
			l_lengthy_word := false;
	          p_string_out :=  p_string_out || '-';
		END IF;
		IF (length(p_string_out) < 20 ) THEN
			p_string_out := rpad(p_string_out,20,' ');
   		END IF;
		p_string_left := substr(p_string_in,l_pos+1,length(p_string_in)-l_pos);
	END IF;
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('ParseThisString - p_string_out - '||p_string_out);
   	ibe_util.debug('ParseThisString - p_string_left - '||p_string_left);
	END IF;
END ParseThisString;

PROCEDURE ParseThisString1 (
	p_string_in	IN	VARCHAR2,
	p_string_out	OUT NOCOPY	VARCHAR2,
	p_string_left	OUT NOCOPY	VARCHAR2
) IS

l_lengthy_word BOOLEAN;
l_line_length	NUMBER;
l_length		NUMBER;
l_lim		NUMBER;
i		NUMBER;
j		NUMBER;
l_pos		NUMBER;

BEGIN
	l_line_length := 10;
	l_length := length(p_string_in);
	IF ( l_length < l_line_length ) THEN
		p_string_out := rpad(p_string_in,12,' ');
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
				l_pos := 8;
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
		IF (length(p_string_out) < 12 ) THEN
			p_string_out := rpad(p_string_out,12,' ');
		END IF;
		p_string_left := substr(p_string_in,l_pos+1,length(p_string_in)-l_pos);
	END IF;

END ParseThisString1;



FUNCTION AddSpaces (
	p_num_in		IN	NUMBER
) RETURN VARCHAR2
IS
l_str_out	varchar2(200);
BEGIN
	l_str_out := rpad(' ',p_num_in,' ');
	return l_str_out;
END AddSpaces;

PROCEDURE GenerateHeader(
  document_id   IN      VARCHAR2,
  display_type  IN      VARCHAR2,
  document      IN OUT NOCOPY  VARCHAR2,
  document_type IN OUT NOCOPY  VARCHAR2
)IS

l_item_type         wf_items.item_type%TYPE;
l_item_key          wf_items.item_key%TYPE;
l_quote_id          NUMBER;
l_event_type        VARCHAR2(20);
l_document          VARCHAR2(32000) := '';
l_party_first_name  hz_parties.person_first_name%TYPE;
l_party_last_name   hz_parties.person_last_name%TYPE;
l_temp_str          VARCHAR2(2000):='';
l_errmsg_data       VARCHAR2(2000):='';
l_order_id          NUMBER;
l_Ship_Method       Varchar2(80);
l_view_net_price_flag VARCHAR2(1);
l_user_type          jtf_um_usertypes_b.usertype_key%type;
l_notif_name        VARCHAR2(20);

/* 16930708 - Defining local variables to hold shipTo details - start  */
l_shipTo_partyId    NUMBER;
l_shipTo_partyType VARCHAR2(2000);
l_shipTo_first_name VARCHAR2(2000);
l_shipTo_last_name  VARCHAR2(2000);
/* 16930708 - Defining local variables to hold shipTo details- end  */


  BEGIN
    l_item_key := document_id;
    ----DBMS_OUTPUT.PUT('Item key in generateHeader is: '||l_item_key);

 l_event_type := wf_engine.GetItemAttrText (
      itemtype 	=> g_itemType,
      itemkey  	=> l_item_key,
      aname		=> 'EVENTTYPE'
	);


  IF l_event_type <> 'RETURNORDER' THEN

       l_quote_id  := wf_engine.GetItemAttrText (
         itemtype => g_itemType,
         itemkey  => l_item_key,
         aname    => 'QUOTEID'
	  );

       l_errmsg_data := wf_engine.GetItemAttrText (
          itemtype => g_itemType,
          itemkey  => l_item_key,
          aname    => 'ERRMSG'
	   );

    END IF;


    l_order_id := wf_engine.GetItemAttrText (
      itemtype => g_itemType,
      itemkey  => l_item_key,
      aname    => 'ORDERID'
	);


    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('GenerateHeader - l_event_type -'|| l_event_type);
    END IF;

    OPEN c_order_header(l_order_id);
    LOOP
      FETCH c_order_header INTO g_header_rec;
      EXIT WHEN c_order_header%NOTFOUND;

      /*16930708 - Getting shipTo first_name and last_name - start */
        Open c_get_shipTo_party_id(l_quote_id);
        FETCH c_get_shipTo_party_id into l_shipTo_partyId;
        Close c_get_shipTo_party_id;

        Open c_get_shipTo_party_type(l_shipTo_partyId);
        FETCH c_get_shipTo_party_type into l_shipTo_partyType;
        Close c_get_shipTo_party_type;

        l_shipTo_first_name:= ASO_SHIPMENT_PVT.Get_party_first_name(l_shipTo_partyId,l_shipTo_partyType);
        l_shipTo_last_name:= ASO_SHIPMENT_PVT.Get_party_last_name(l_shipTo_partyId,l_shipTo_partyType);

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('16930708 - GenerateHeader-first_name of shipTo: '||l_shipTo_first_name);
        END IF;

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('16930708 - GenerateHeader-last_name of shipTo: '||l_shipTo_last_name);
        END IF;

        /*16930708 - Getting shipTo first_name and last_name - end */

      l_party_first_name := null;
      l_party_last_name := null;

 l_party_first_name:= wf_engine.GetItemAttrText (
      itemtype => g_itemType,
      itemkey  => l_item_key,
      aname    => 'FIRSTNAME'
	);

 l_party_last_name:= wf_engine.GetItemAttrText (
      itemtype => g_itemType,
      itemkey  => l_item_key,
      aname    => 'LASTNAME'
	);

      IF l_event_type <> 'RETURNORDER' THEN
         For c_ship_method_rec in c_ship_methods(g_header_rec.shipping_method_code)
         LOOP
		l_Ship_Method := c_ship_method_rec.Meaning;
         END LOOP;
      END IF;

      IF ( l_event_type = 'ORDFAX' OR l_event_type = 'ORDCONF' OR l_event_type = 'CNCLORDR' OR l_event_type = 'RETURNORDER') THEN
       -- IF (display_type = 'text/plain' ) THEN
          fnd_message.set_name('IBE','IBE_PRMT_ORDER_NO_COLON');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document || RPAD(l_temp_str, 32) || g_header_rec.order_number||NEWLINE; -- bug 13363458, nsatyava
          fnd_message.set_name('IBE','IBE_PRMT_ORDER_DATE_COLON');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document || RPAD(l_temp_str, 32) || g_header_rec.ordered_date||NEWLINE;
          IF l_event_type <> 'RETURNORDER' THEN
             fnd_message.set_name('IBE','IBE_PRMT_SHIP_METH_COLON');
             l_temp_str := null;
             l_temp_str := fnd_message.get;
             l_document := l_document || RPAD(l_temp_str, 32) || l_Ship_Method||NEWLINE;
          END IF;
         -- Need to get the user type. For individual users, show address, for others skip.
          l_user_type := wf_engine.GetItemAttrText (
                         itemtype => g_itemType,
                         itemkey  => l_item_key,
                         aname    => 'STOREUSERTYPE'
	                   );
          IF  ((l_user_type = 'IBE_INDIVIDUAL'and l_event_type = 'RETURNORDER') or (l_event_type <>  'RETURNORDER')) THEN
             IF (l_event_type <> 'RETURNORDER') THEN
                 fnd_message.set_name('IBE','IBE_PRMT_SHIP_INFO_COLON');
                 l_temp_str := null;
                 l_temp_str := fnd_message.get;
                 /*16930708 -  start */
                 IF (l_event_type = 'ORDCONF') THEN
                   l_party_first_name := l_shipTo_first_name;
                   l_party_last_name := l_shipTo_last_name;
                   END IF;
                /*16930708 -  end */

                 l_document := l_document || RPAD(l_temp_str, 32) || l_party_first_name||' '||l_party_last_name||NEWLINE;
                 l_document := l_document || RPAD(' ', 32) || g_header_rec.ship_to_address1||NEWLINE;
                 IF ( rtrim(g_header_rec.ship_to_address2) IS NOT NULL ) THEN
                      l_document := l_document || RPAD(' ', 32) || g_header_rec.ship_to_address2||NEWLINE;
                 END IF;
                 IF ( rtrim(g_header_rec.ship_to_address3) IS NOT NULL ) THEN
                      l_document := l_document || RPAD(' ', 32) || g_header_rec.ship_to_address3||NEWLINE;
                 END IF;
                 IF ( rtrim(g_header_rec.ship_to_address4) IS NOT NULL ) THEN
                      l_document := l_document || RPAD(' ', 32) || g_header_rec.ship_to_address4||NEWLINE;
                 END IF;
                 l_document := l_document || RPAD(' ', 32) ||  g_header_rec.ship_to_city||',';
                 l_document := l_document || g_header_rec.ship_to_state||' ';
                 l_document := l_document || g_header_rec.ship_to_postal_code||NEWLINE;
                 l_document := l_document || RPAD(' ', 32) || g_header_rec.ship_to_country;

              ELSE  ---3334542
                 fnd_message.set_name('IBE','IBE_EOS_BILLING_ADDRESS_COLON');
                 l_temp_str := null;
                 l_temp_str := fnd_message.get;

                 l_document := l_document || RPAD(l_temp_str, 32) || l_party_first_name||' '||l_party_last_name||NEWLINE;
                 l_document := l_document || RPAD(' ', 32) || g_header_rec.bill_to_address1||NEWLINE;
                 IF ( rtrim(g_header_rec.bill_to_address2) IS NOT NULL ) THEN
                      l_document := l_document || RPAD(' ', 32) || g_header_rec.bill_to_address2||NEWLINE;
                 END IF;
                 IF ( rtrim(g_header_rec.bill_to_address3) IS NOT NULL ) THEN
                      l_document := l_document || RPAD(' ', 32) || g_header_rec.bill_to_address3||NEWLINE;
                 END IF;
                 IF ( rtrim(g_header_rec.bill_to_address4) IS NOT NULL ) THEN
                      l_document := l_document || RPAD(' ', 32) || g_header_rec.bill_to_address4||NEWLINE;
                 END IF;
                 l_document := l_document || RPAD(' ', 32) || g_header_rec.bill_to_city||',';
                 l_document := l_document || g_header_rec.bill_to_state||' ';
                 l_document := l_document || g_header_rec.bill_to_postal_code||NEWLINE;
                 l_document := l_document || RPAD(' ', 32) || g_header_rec.bill_to_country;

              END IF;

          END IF;
        --ELSE
          --null;
        --END IF;
      ELSIF ( l_event_type = 'ORDERROR') THEN
       -- IF (display_type = 'text/plain' ) THEN
          fnd_message.set_name('IBE','IBE_PRMT_ORDER_NO_COLON');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document || RPAD(l_temp_str, 32) || g_header_rec.order_number||NEWLINE;
          fnd_message.set_name('IBE','IBE_PRMT_OOE_NO_COLON');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document|| RPAD(l_temp_str, 32) || g_header_rec.order_number||NEWLINE;
          fnd_message.set_name('IBE','IBE_PRMT_COMPANY_NAME_COLON');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document|| RPAD(l_temp_str, 32) || g_header_rec.customer_name||NEWLINE;
          fnd_message.set_name('IBE','IBE_PRMT_NAME_COLON');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document || RPAD(l_temp_str, 32) || l_party_first_name||' '||l_party_last_name||NEWLINE;
          fnd_message.set_name('IBE','IBE_PRMT_DATE_SUBMIT_COLON');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document || RPAD(l_temp_str, 32) || g_header_rec.ordered_date||NEWLINE;
          -- Need to restrict the end user to view the net price.

          l_view_net_price_flag := wf_engine.GetItemAttrText (
		                            itemtype 	=> g_itemType,
		                            itemkey  	=> l_item_key,
		                            aname	=> 'VIEWNETPRICE'
	                                    );

          IF l_view_net_price_flag = 'Y' THEN
             fnd_message.set_name('IBE','IBE_PRMT_ORDER_TOTAL_COLON');
             l_temp_str := null;
             l_temp_str := fnd_message.get;
             l_document := l_document|| RPAD(l_temp_str, 32) || to_char(g_header_rec.order_total)||NEWLINE;
             fnd_message.set_name('IBE','IBE_PRMT_PAY_METH_COLON');
             l_temp_str := null;
             l_temp_str := fnd_message.get;
             l_document := l_document|| RPAD(l_temp_str, 32) || g_header_rec.payment_type_code||NEWLINE;
          END IF;
          fnd_message.set_name('IBE','IBE_PRMT_REASON_CODE_COLON');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document || RPAD(l_temp_str, 32) || NEWLINE ;
          l_document := l_document || RPAD(' ', 32) || l_errmsg_data ||NEWLINE;
          IF (IBE_UTIL.G_DEBUGON = l_true) THEN
             ibe_util.debug('Error Message '|| l_errmsg_data);
          END IF;
       -- ELSE
         -- null;
        --END IF;
      END IF;
    END LOOP;
    CLOSE c_order_header;



    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('GenerateHeader - l_document - '||NEWLINE|| l_document);
    END IF;
    l_document := l_document||NEWLINE;
    document := l_document;


  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
    document :=  '<Pre>' || document;  -- bug 13363458, 16662526  nsatyava
  ELSE
    document_type := 'text/plain';
  END IF;

    EXCEPTION
      When Others Then
        IF c_order_header%ISOPEN THEN
          CLOSE c_order_header;
        END IF;
      Raise;
  END GenerateHeader;

 PROCEDURE GenerateAssistHeader(
 document_id            IN              	VARCHAR2,
 display_type            	IN              	VARCHAR2,
 document                 IN	OUT NOCOPY     	VARCHAR2,
 document_type	IN      	OUT NOCOPY     	VARCHAR2
 )
IS
l_item_type		      wf_items.item_type%TYPE;
l_item_key		      wf_items.item_key%TYPE;
l_quote_id		      NUMBER;
l_event_type		VARCHAR2(20);
l_comments		      VARCHAR2(2000);
l_party_first_name	hz_parties.person_first_name%TYPE;
l_party_last_name	      hz_parties.person_last_name%TYPE;
l_contact_party_id      hz_parties.party_id%TYPE;
l_contact_name		VARCHAR2(400);
l_contact_number	      VARCHAR2(70);
l_contact_email		hz_contact_points.email_address%TYPE;
l_contact_fax		VARCHAR2(70);
l_ship_address		hz_locations.address1%TYPE;
l_bill_address		hz_locations.address1%TYPE;
l_document		      VARCHAR2(32000) := '';
l_temp_str		      VARCHAR2(2000):='';
l_order_id		      NUMBER;

l_ship_method	      Varchar2(80);

Cursor c_b2b_contact(pOrder Number) IS
Select p.party_id Person_Party_id,
       l.party_id contact_party_id,
       p.person_first_name,
       p.person_last_name,
       p.party_type
from oe_order_headers_all o,
     hz_cust_Account_roles r,
     hz_relationships l,
     hz_parties p
where o.header_id        = pOrder
and o.sold_to_contact_id = r.cust_account_role_id
and r.party_id           = l.party_id
and l.subject_id         = p.party_id
and l.subject_type       = 'PERSON'
and l.object_type        = 'ORGANIZATION';


BEGIN

	l_item_key := document_id;

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateAssistHeader - l_item_key -  '||l_item_key);
	END IF;

	l_quote_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname	      => 'QUOTEID');

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateAssistHeader - l_quote_id - '||l_quote_id);
	END IF;

	l_order_id := wf_engine.GetItemAttrText (
		itemtype => g_itemType,
		itemkey  => l_item_key,
		aname	   => 'ORDERID');

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('GenerateHeader - l_order_id -  '||l_order_id);
       END IF;

	l_event_type := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname   	=> 'EVENTTYPE');

	l_comments := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey     => l_item_key,
		aname       => 'COMMENTS');

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateAssistHeader - l_event_type - '|| l_event_type);
   	ibe_util.debug('GenerateAssistHeader - l_event_type -'|| l_event_type);
	END IF;

	OPEN c_order_header(l_order_id);
	LOOP
		FETCH	c_order_header INTO g_header_rec;
		EXIT WHEN c_order_header%NOTFOUND;

            l_party_first_name := null;
		l_party_last_name  := null;
		l_contact_name     := null;

            FOR c_hz_parties_rec IN c_hz_parties(g_header_rec.party_id) LOOP
		 If  c_hz_parties_rec.Party_type = 'ORGANIZATION' Then
                  For c_b2b_contact_rec in c_b2b_contact(l_order_id) Loop
			 l_party_first_name := upper(rtrim(c_b2b_contact_rec.person_first_name));
			 l_party_last_name  := upper(rtrim(c_b2b_contact_rec.person_last_name));
        	       l_contact_name     := l_party_first_name||' '||l_party_last_name;
			 l_contact_party_id := c_b2b_contact_rec.contact_party_id;
		     End Loop;
              Else
			l_party_first_name := upper(rtrim(c_hz_parties_rec.person_first_name));
			l_party_last_name  := upper(rtrim(c_hz_parties_rec.person_last_name));
                	l_contact_name     := l_party_first_name||' '||l_party_last_name;
			l_contact_party_id := g_header_rec.party_id;
		 End If;
            END LOOP;

                IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                   ibe_util.debug('GenerateAssistHeader - l_contact_name '|| l_contact_name);
                END IF;

                l_contact_number := NULL;
		    l_contact_email  := NULL;
                l_contact_fax    := NULL;

                FOR c_hz_contact_rec IN c_hz_contact_points(l_contact_party_id) LOOP

   		   If (c_hz_contact_rec.contact_point_type = 'PHONE' AND c_hz_contact_rec.phone_line_type = 'GEN')
               AND (l_contact_number IS NULL OR c_hz_contact_rec.primary_flag ='Y')
               Then

                   l_contact_number := trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);

		  Elsif c_hz_contact_rec.contact_point_type = 'EMAIL'  AND (l_contact_email IS NULL OR c_hz_contact_rec.primary_flag ='Y')  Then

                   l_contact_email := c_hz_contact_rec.email_address;

                Elsif (c_hz_contact_rec.contact_point_type = 'PHONE' AND c_hz_contact_rec.phone_line_type = 'FAX')  AND (l_contact_fax IS NULL OR c_hz_contact_rec.primary_flag ='Y')  Then

                   l_contact_fax  :=   trim(c_hz_contact_rec.Phone_Country_code||' '||c_hz_contact_rec.Phone_area_code||' '||c_hz_contact_rec.Phone_number);

                End If;

                END LOOP;

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateAssistHeader - l_contact_number - '|| l_contact_number);
		END IF;

		l_ship_address := rtrim(g_header_rec.ship_to_address1) ||' '||rtrim(g_header_rec.ship_to_address2) ||' '||
				rtrim(g_header_rec.ship_to_address3) ||' '||rtrim(g_header_rec.ship_to_address4) ;

		l_bill_address := rtrim(g_header_rec.bill_to_address1) ||' '||rtrim(g_header_rec.bill_to_address2) ||' '||
				rtrim(g_header_rec.bill_to_address3) ||' '||rtrim(g_header_rec.bill_to_address4) ;

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateAssistHeader - l_bill_address - '|| l_bill_address);
   		ibe_util.debug('GenerateAssistHeader - l_ship_address - '|| l_ship_address);
		END IF;

		For c_ship_method_rec in c_ship_methods(g_header_rec.shipping_method_code) LOOP
		l_Ship_Method := c_ship_method_rec.Meaning;
		End Loop;

		IF ( l_event_type = 'CUSTASSIST' ) THEN
			--IF ( display_type = 'text/plain' ) THEN
				fnd_message.set_name('IBE','IBE_PRMT_CUST_CNTCT_INFO');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_NAME_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_contact_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_NUM_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_contact_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_EMAIL_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_contact_email||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_COMMENTS_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_comments ||NEWLINE||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ORDER_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||g_header_rec.order_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ORDER_DATE_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||g_header_rec.ordered_date||NEWLINE||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_SHIP_METH_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_ship_method||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CUST_NAME_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||g_header_rec.customer_name||NEWLINE;
				l_document := l_document || TAB||TAB||TAB||TAB||l_ship_address||NEWLINE;
				l_document := l_document || TAB||TAB||TAB||TAB||g_header_rec.ship_to_city||NEWLINE;
				l_document := l_document || TAB||TAB||TAB||TAB||g_header_rec.ship_to_state||' ';
				l_document := l_document || g_header_rec.ship_to_postal_code||NEWLINE;
				l_document := l_document || TAB||TAB||TAB||TAB||g_header_rec.ship_to_country||NEWLINE;
			--ELSE
				--null;
			--END IF;
		ELSIF ( l_event_type = 'SALESASSIST' ) THEN
			--IF (display_type = 'text/plain' ) THEN
				fnd_message.set_name('IBE','IBE_PRMT_ORDER_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||g_header_rec.order_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_OOE_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document|| l_temp_str ||TAB||TAB||TAB ||g_header_rec.order_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ORDER_DATE_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||g_header_rec.ordered_date||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_SHIP_METH_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str||TAB||TAB||l_ship_method||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CUST_CNTCT_INFO');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_NAME_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_contact_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_NUM_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_contact_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_EMAIL_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||l_contact_email||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_COMMENTS_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_comments ||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ORD_BILL_INFO');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CUST_NAME_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||g_header_rec.customer_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ADDRESS_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_address||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CITY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||g_header_rec.bill_to_city||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_STATE_PRO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||g_header_rec.bill_to_state||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ZIP_POSTAL_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||g_header_rec.bill_to_postal_code||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_COUNTRY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||g_header_rec.bill_to_country||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_NAME_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_contact_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_TEL_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||l_contact_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_FAX_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_contact_fax||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ORD_SHIP_INFOR');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CUST_NAME_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||g_header_rec.customer_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ADDRESS_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_address||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CITY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str||TAB||TAB||TAB||g_header_rec.ship_to_city||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_STATE_PRO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str||TAB||TAB||g_header_rec.ship_to_state||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ZIP_POSTAL_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str||TAB||g_header_rec.ship_to_postal_code||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_COUNTRY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str||TAB||TAB||g_header_rec.ship_to_country||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_NAME_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str||TAB||TAB||l_contact_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_TEL_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str||TAB||l_contact_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_FAX_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str||TAB||TAB||l_contact_fax||NEWLINE;
			--ELSE
				--null;
			--END IF;
		END IF;
	END LOOP;
	CLOSE c_order_header;

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateAssistHeader - l_document - '||NEWLINE|| l_document);
	END IF;

	document := l_document;

    IF(display_type = 'text/html') THEN
      document_type := 'text/html';
    ELSE
      document_type := 'text/plain';
    END IF;

	EXCEPTION
		When Others Then
			IF c_order_header%ISOPEN THEN
				CLOSE c_order_header;
			END IF;
		Raise;
END GenerateAssistHeader;

/********************************************************
 GenerateOrderDetailHeader: Here the input parameters are
                          document_id and display_type.
                          document_id is nothingbut item key.
                          display_type is text or html type message.
                          The in and out parameters are document and document_type.
                          Docuemnt contains order detail header info.
                          (EX: Product number, amount ..)
                         And document type is again text/html.

 This procedure is responsible to send order detail header lables to workflow process.
 This procedure is getting called from workflow process.
 If the permission based procing is enabled then added amount label to the document
 otherwise, except amount label all other required lables are added.

*********************************************************/
PROCEDURE GenerateOrderDetailHeader(
	document_id  	IN              VARCHAR2,
	display_type	IN              VARCHAR2,
	document	     IN OUT NOCOPY	 VARCHAR2,
	document_type	IN OUT NOCOPY	 VARCHAR2
) IS
l_document	        VARCHAR2(32000) := ' '||NEWLINE;
l_view_net_price_flag  VARCHAR2(1);
l_item_key	        WF_ITEMS.ITEM_KEY%TYPE;
l_order_id             NUMBER;
l_temp_str	        VARCHAR2(2000):='';
l_event_type	  VARCHAR2(20);
l_quote_id       NUMBER;
l_quote_source_code     VARCHAR2(100);


BEGIN


   l_item_key:= document_id  ;

   l_view_net_price_flag := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname	=> 'VIEWNETPRICE'
	);


   l_event_type := wf_engine.GetItemAttrText (
                   itemtype 	=> g_itemType,
                   itemkey  	=> l_item_key,
                   aname	=> 'EVENTTYPE'
                  );

   l_quote_id := wf_engine.GetItemAttrText (
                  itemtype => g_itemType,
                  itemkey  => l_item_key,
                  aname    => 'QUOTEID');

IF (l_event_type = 'RETURNORDER') THEN  -- For Return Order WF Notification
   fnd_message.set_name('IBE','IBE_PRMT_PRODUCT_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := rpad(l_temp_str,7)||' ';
   fnd_message.set_name('IBE','IBE_PRMT_DESCRIPTION_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document||rpad(l_temp_str,20)||' ';
   fnd_message.set_name('IBE','IBE_PRMT_ORDER_NO_DOT_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document||rpad(l_temp_str,9)||' ';
   fnd_message.set_name('IBE','IBE_PRMT_QUANTITY_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document||rpad(l_temp_str,4)||' ';
   IF l_view_net_price_flag = 'Y' THEN
       fnd_message.set_name('IBE','IBE_PRMT_RETURN_AMOUNT_G');
              l_temp_str := null;
              l_temp_str := fnd_message.get;
              l_document := l_document||rpad(l_temp_str,15)||' ';
   END IF;
   fnd_message.set_name('IBE','IBE_PRMT_RETURN_REASON_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document||rpad(l_temp_str,13);
ELSIF (l_event_type = 'CUSTASSIST' OR l_event_type = 'SALESASSIST') THEN   -- For Sales Assistance WF Notification
  Open c_get_source_code(l_quote_id);
  FETCH c_get_source_code into l_quote_source_code;
  Close c_get_source_code;
  if (l_quote_source_code = 'IStore InstallBase') then
    fnd_message.set_name('IBE','IBE_M_ACTION_PRMT');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document ||rpad(l_temp_str,9)||' ';

   end if;
   fnd_message.set_name('IBE','IBE_PRMT_PRODUCT_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document ||rpad(l_temp_str,28)||' ';
   fnd_message.set_name('IBE','IBE_PRMT_UOM_SHORT_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document||lpad(l_temp_str,8)||' ';
   fnd_message.set_name('IBE','IBE_PRMT_QUANTITY_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document||lpad(l_temp_str,7)||' ';
   if (l_quote_source_code <> 'IStore InstallBase') then
   fnd_message.set_name('IBE','Shippable');
            l_temp_str := null;
            l_temp_str := fnd_message.get;
            l_document := l_document||lpad(l_temp_str,9)||' ';
   end if;
   IF l_view_net_price_flag = 'Y' THEN
        fnd_message.set_name('IBE','IBE_PRMT_AMOUNT_G');
             l_temp_str := null;
             l_temp_str := fnd_message.get;
             l_document := l_document||lpad(l_temp_str,15)||' ';
   END IF;
ELSE -- For all other WF notifications (Order conf and Contracts negeotiations)
  Open c_get_source_code(l_quote_id);
  FETCH c_get_source_code into l_quote_source_code;
  Close c_get_source_code;

   if (l_quote_source_code = 'IStore InstallBase') then
    fnd_message.set_name('IBE','IBE_M_ACTION_PRMT');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document ||rpad(l_temp_str,9)||' ';

   end if;
   fnd_message.set_name('IBE','IBE_PRMT_PRODUCT_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document ||rpad(l_temp_str,28)||' ';
   fnd_message.set_name('IBE','IBE_PRMT_UOM_SHORT_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document||lpad(l_temp_str,8)||' ';
   fnd_message.set_name('IBE','IBE_PRMT_QUANTITY_G');
          l_temp_str := null;
          l_temp_str := fnd_message.get;
          l_document := l_document||lpad(l_temp_str,7)||' ';
   if (l_quote_source_code <> 'IStore InstallBase') then
   fnd_message.set_name('IBE','Shippable');
            l_temp_str := null;
            l_temp_str := fnd_message.get;
            l_document := l_document||lpad(l_temp_str,9)||' ';
   end if;
   IF l_view_net_price_flag = 'Y' THEN
        fnd_message.set_name('IBE','IBE_PRMT_AMOUNT_G');
             l_temp_str := null;
             l_temp_str := fnd_message.get;
             l_document := l_document||lpad(l_temp_str,15)||' ';
   END IF;
END IF;

   document := l_document||NEWLINE;

   IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;

END GenerateOrderDetailHeader;




--This API added by mannamra
  PROCEDURE Generate_Detail(
    P_item_key   IN VARCHAR2,
    p_quote_flag IN VARCHAR2,
    p_tax_flag   IN VARCHAR2,
    x_document   OUT NOCOPY VARCHAR2
	) is
  l_item_type	wf_items.item_type%TYPE;
  l_item_key	wf_items.item_key%TYPE;
  l_quote_id	NUMBER;
  l_event_type	VARCHAR2(20);
  l_document	VARCHAR2(32000) := '';
  l_ship_flag	VARCHAR2(1);
  l_string_in 	VARCHAR2(250);
  l_string_out	VARCHAR2(250);
  l_string_left	VARCHAR2(250);
  l_order_id    NUMBER;
  l_can_qty       VARCHAR2(50);
  l_can_amt       VARCHAR2(50);

  l_amt_format  Varchar2(50);
  l_curr_sym   FND_CURRENCIES.SYMBOL%TYPE;
  l_temp_str	VARCHAR2(2000):='';
  l_view_net_price_flag   VARCHAR2(1);
  l_view_line_type_flag   VARCHAR2(1) := FND_API.G_FALSE;
  Cursor c_ship_flag(p_line_id NUMBER) IS
  SELECT msi.shippable_item_flag
  FROM oe_order_lines_all line,
       OE_SYSTEM_PARAMETERS_ALL osp,
       mtl_system_items_kfv msi
  WHERE line.line_id = p_line_id
  AND   line.org_id = osp.org_id
  AND   osp.master_organization_id  = msi.organization_id
  AND   line.inventory_item_id = msi.inventory_item_id;


notif_line_tbl         Notif_Line_Tbl_Type;
Cursor c_get_top_quote_lines(p_quote_header_id number) is
        SELECT   m.description,
                 u.unit_of_measure,
		       q.quote_line_id,
                 q.Quantity,
                 q.item_type_code,
                 q.Line_quote_price,
 	         q.currency_code,
                 uom.unit_of_measure_tl charge_periodicity_desc,
                 m.shippable_item_flag,
                 sum(t.tax_amount) tax_amount,
                 qld.config_instance_name,
 		 tran.name action,
	         qld.config_delta
        FROM Aso_quote_lines_all q,
             mtl_system_items_vl m,
             aso_tax_details t,
             mtl_units_of_measure u,
             Aso_quote_line_details qld,
             oe_transaction_types_tl tran,
             mtl_units_of_measure_tl uom
        WHERE q.inventory_item_id = m.inventory_item_id
              and q.organization_id   = m.organization_id
              and t.quote_line_id(+)     = q.quote_line_id
              and u.uom_code = q.uom_code
              and q.quote_header_id   = p_quote_header_id --2548--6399
              and q.item_type_code <> 'CFG'
              and qld.quote_line_id(+) = q.quote_line_id
    	      and tran.TRANSACTION_TYPE_ID(+) = q.order_line_type_id
	      and tran.language(+) = userenv('lang')
    	      and uom.uom_code(+) = q.charge_periodicity_code
    	      and uom.language(+) = userenv('lang')
              and qld.ref_line_id is null
        GROUP BY q.quote_line_id,
	   		  q.line_number,
			  m.description,
			  u.unit_of_measure,
			  q.Quantity,
			  q.item_type_code,
			  q.Line_quote_price,
			  q.charge_periodicity_code,
			  q.currency_code,
			  m.shippable_item_flag,
		       qld.config_instance_name,
		       tran.name,
		       uom.unit_of_measure_tl,
		       qld.config_delta
         ORDER BY q.line_number;
  g_notif_quote_line_rec		c_get_top_quote_lines%ROWTYPE;

  Cursor c_get_config_tree (p_quote_header_id number,p_parent_line_id number) is
	SELECT m.description description,
		u.unit_of_measure,
		q.Quantity,
		q.item_type_code,
		q.Line_quote_price,
                uom.unit_of_measure_tl charge_periodicity_desc,
		m.shippable_item_flag,
		m.bom_item_type,
		m.config_model_type,
		sum(t.tax_amount) tax_amount,
		qld.config_instance_name,
		tran.name action,
		qld.config_delta
	FROM (  SELECT related_quote_line_id,LEVEL depth
		FROM aso_line_relationships
		START WITH quote_line_id = p_parent_line_id
		CONNECT BY quote_line_id =
		PRIOR related_quote_line_id  ) ALR,
		Aso_quote_lines_all q,
		mtl_system_items_vl m,
		aso_tax_details t,
		mtl_units_of_measure u,
		Aso_quote_line_details qld,
		oe_transaction_types_tl tran,
                mtl_units_of_measure_tl uom
	WHERE q.quote_line_id = ALR.related_quote_line_id and
		q.inventory_item_id = m.inventory_item_id
		and   q.organization_id   = m.organization_id
		and   t.quote_line_id(+)     = q.quote_line_id
		and   u.uom_code = q.uom_code
		and   q.quote_header_id   = p_quote_header_id -- 2548--6399
		and   qld.quote_line_id(+) = q.quote_line_id
		and   tran.TRANSACTION_TYPE_ID(+) = q.order_line_type_id
		and   tran.language(+) = userenv('lang')
     	        and   uom.uom_code(+) = q.charge_periodicity_code
    	        and   uom.language(+) = userenv('lang')
	GROUP BY q.quote_line_id,
	         q.line_number,
		    m.description,
		    u.unit_of_measure,
		    q.Quantity,
		    q.item_type_code,
		    q.Line_quote_price,
		    q.charge_periodicity_code,
		    m.shippable_item_flag,
		    m.bom_item_type,
		    m.config_model_type,
		    qld.config_instance_name,
		    tran.name,
		    uom.unit_of_measure_tl,
		    qld.config_delta
		ORDER BY q.line_number;
  g_notif_config_line_rec		c_get_config_tree%ROWTYPE;

  Cursor c_get_top_order_lines(p_order_id  NUMBER) IS
  SELECT ol.item_type_code,
         ol.top_model_line_id,
         ol.link_to_line_id,
         msi.description description,
         cfgdtl.name config_instance_name,
	 linetyp.name action,
         ol.order_quantity_uom unit_of_measure,
         ol.ordered_quantity quantity,
         msit1.UNIT_OF_MEASURE charge_periodicity_desc,
         oe_totals_grp.Get_Order_Total(ol.header_id,ol.line_id,'LINES') lines_total,
         oe_totals_grp.Get_Order_Total(ol.header_id,ol.line_id,'TAXES') taxes_total,
	 ol.shippable_flag,
         decode(msi.config_model_type,'N','Y','N') model_container_flag,
         cfgdtl.config_delta config_delta_flag
  FROM   oe_order_lines_all ol,
         mtl_system_items_vl msi,
         CZ_CONFIG_ITEMS cfgdtl,
         mtl_units_of_measure_tl msit1,
	 oe_transaction_types_tl linetyp
  WHERE  ol.header_id = p_order_id
         AND decode(ol.top_model_line_id,null,'1',decode(ol.top_model_line_id,ol.line_id,decode(ol.link_to_line_id,null,'1','2'),'2'))= '1'
         and ol.inventory_item_id = msi.inventory_item_Id
         and msit1.language(+) = userenv('LANG')
         and ol.charge_periodicity_code = msit1.uom_code(+)
         and msi.organization_id = oe_profile.value('OE_ORGANIZATION_ID', ol.org_id)
         and ol.config_header_id = cfgdtl.config_hdr_id(+)
         and ol.config_rev_nbr = cfgdtl.config_rev_nbr (+)
         and ol.configuration_id = cfgdtl.config_item_id(+)
         AND ol.line_type_id = linetyp.transaction_type_id
         AND linetyp.language = userenv('LANG')
  ORDER BY ol.line_number,
     shipment_number,
     nvl( option_number,-1),
     nvl( component_number,-1),
     nvl( service_number,-1);
  g_notif_order_line_rec c_get_top_order_lines%ROWTYPE;

Cursor c_get_order_config_tree(p_order_id  NUMBER, p_mdl_top_line_id VARCHAR2) IS
  SELECT ol.item_type_code,
         ol.top_model_line_id,
         ol.link_to_line_id,
         msi.description description,
         cfgdtl.name config_instance_name,
	 linetyp.name action,
         ol.order_quantity_uom unit_of_measure,
         ol.ordered_quantity quantity,
         msit1.UNIT_OF_MEASURE charge_periodicity_desc,
         oe_totals_grp.Get_Order_Total(ol.header_id,ol.line_id,'LINES') lines_total,
         oe_totals_grp.Get_Order_Total(ol.header_id,ol.line_id,'TAXES') taxes_total,
	 ol.shippable_flag,
         decode(msi.config_model_type,'N','Y','N') model_container_flag,
         cfgdtl.config_delta config_delta_flag
  FROM   oe_order_lines_all ol,
         mtl_system_items_vl msi,
         CZ_CONFIG_ITEMS cfgdtl,
         mtl_units_of_measure_tl msit1,
	 oe_transaction_types_tl linetyp
  WHERE  ol.header_id = p_order_id
	 and link_to_line_id is not null
 	 and ( top_model_line_id = p_mdl_top_line_id)
         and ol.inventory_item_id = msi.inventory_item_Id
         and msit1.language(+) = userenv('LANG')
         and ol.charge_periodicity_code = msit1.uom_code(+)
         and msi.organization_id = oe_profile.value('OE_ORGANIZATION_ID', ol.org_id)
         and ol.config_header_id = cfgdtl.config_hdr_id(+)
         and ol.config_rev_nbr = cfgdtl.config_rev_nbr (+)
         and ol.configuration_id = cfgdtl.config_item_id(+)
         AND ol.line_type_id = linetyp.transaction_type_id
         AND linetyp.language = userenv('LANG')
  ORDER BY ol.line_number,
     shipment_number,
     nvl( option_number,-1),
     nvl( component_number,-1),
     nvl( service_number,-1);
  g_notif_config_orderline_rec		c_get_order_config_tree%ROWTYPE;

  l_index number := 1;

  ord_detail_rec            c_order_detail%rowtype;

  type order_details_tbl_type is table of ibe_order_detail_v%rowtype
                                          INDEX BY BINARY_INTEGER;
  ord_detail_tbl    order_details_tbl_type;
  i                 number :=1;
  j                 number :=1;
  counter           number;
  l_kit_line_id     number;
  l_kit_index       number :=0 ;
  l_kit_line_price  number := 0;
  l_kit_line_tax    number := 0;
  l_kit_found_here    number := 0;
  l_displayOptionClass VARCHAR2(1);
  l_displayUnchangedItem VARCHAR2(1);
  l_quote_source_code    VARCHAR2(100);

  TYPE Kit_log_rec IS RECORD (
      Kit_line_index    NUMBER,
      item_type_code    VARCHAR2(2000),
      lines_total       NUMBER,
      taxes_total       NUMBER,
      total_line_price  NUMBER,
      total_tax_price   NUMBER);

  TYPE kit_log_tbl_type IS table OF kit_log_rec INDEX BY BINARY_INTEGER;
  kit_log_tbl         kit_log_tbl_type; --PL/SQl table to save 'KIT' and 'INCLUDED' items


--  ord_detail_rec    order_details_rec_type;
 BEGIN

    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Generate_detail:START');
    END IF;
    ----DBMS_OUTPUT.PUT('Quote flag is: '||p_quote_flag);
    ----DBMS_OUTPUT.PUT('Tax flag is: '||p_tax_flag);
    l_item_key := p_item_key;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Generate_Detail - l_item_key  -  '||l_item_key);
    END IF;

    l_quote_id := wf_engine.GetItemAttrText (
                            itemtype => g_itemType,
                            itemkey  => l_item_key,
                            aname    => 'QUOTEID'
	                        );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Generate_Detail - l_quote_id - '||l_quote_id);
    END IF;
    l_order_id := wf_engine.GetItemAttrText (
                            itemtype => g_itemType,
                            itemkey  => l_item_key,
                            aname    => 'ORDERID'
                            );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Generate_Detail - l_order_id -  '||l_order_id);
    END IF;
	l_event_type := wf_engine.GetItemAttrText (
                              itemtype 	=> g_itemType,
                              itemkey  	=> l_item_key,
                              aname		=> 'EVENTTYPE'
                             );
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Generate_Detail - l_event_type - '|| l_event_type);
    END IF;


    l_view_net_price_flag := wf_engine.GetItemAttrText (
		               itemtype 	=> g_itemType,
		               itemkey  	=> l_item_key,
		               aname	=> 'VIEWNETPRICE'
	                       );

    Open c_get_source_code(l_quote_id);
    FETCH c_get_source_code into l_quote_source_code;
    Close c_get_source_code;
    if (l_quote_source_code = 'IStore InstallBase') then
        l_view_line_type_flag := FND_API.G_TRUE;
    end if;

    For g_quote_header_rec In c_quote_header(l_quote_id) Loop
      l_amt_format := FND_CURRENCY.GET_FORMAT_MASK(g_quote_header_rec.currency_code,18);
       g_amt_format := l_amt_format;
      IF l_view_net_price_flag = 'Y' THEN
         For curr_sym_rec In c_curr_symbol(g_quote_header_rec.currency_code)
         Loop
             l_curr_sym   := trim(nvl(curr_sym_rec.symbol,' '));
	     g_curr_sym   := l_curr_sym;
             IF (IBE_UTIL.G_DEBUGON = l_true) THEN
                 IBE_UTIL.DEBUG('currency symbol is: '||nvl(l_curr_sym,'nothing'));
             END IF;
        End Loop;
      END IF;
    End Loop;
    ----DBMS_OUTPUT.PUT('Quote flag is: '||p_quote_flag);
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('p_quote_flag '||p_quote_flag);
    END IF;
    --Get Display Option class profile value
    l_displayOptionClass := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DISPLAY_OPTION_CLASSES',null,null,671), 'Y');
    l_displayUnchangedItem := NVL( FND_PROFILE.VALUE_SPECIFIC('CZ_OUTPUT_IB_UNCHD_CHILD_ITEMS',null,null,671), 'Y');

    IF(p_quote_flag = fnd_api.g_true) then
	    FOR g_notif_quote_line_rec IN c_get_top_quote_lines(l_quote_id) LOOP
	    if(g_notif_quote_line_rec.config_instance_name is not null) then
	       notif_line_tbl(l_index).Product := g_notif_quote_line_rec.description||':'||g_notif_quote_line_rec.config_instance_name;
	    else
	       notif_line_tbl(l_index).Product := g_notif_quote_line_rec.description;
	    end if;
	    --DBMS_OUTPUT.PUT_LINE(Notif_Line_Tbl(l_index).Product);
	    notif_line_tbl(l_index).UOM         :=g_notif_quote_line_rec.unit_of_measure;
	    notif_line_tbl(l_index).Quantity    :=g_notif_quote_line_rec.Quantity;
	    notif_line_tbl(l_index).Shippable   :=g_notif_quote_line_rec.shippable_item_flag;
	    notif_line_tbl(l_index).NetAmount   :=g_notif_quote_line_rec.Line_quote_price;
	    notif_line_tbl(l_index).Periodicity :=g_notif_quote_line_rec.charge_periodicity_desc;
	    notif_line_tbl(l_index).TaxAmount   :=g_notif_quote_line_rec.tax_amount;
	    if(g_notif_quote_line_rec.config_delta <> 0) then
	      notif_line_tbl(l_index).Action      :=g_notif_quote_line_rec.action;
	    end if;
	    l_index := l_index+1;
	    if(g_notif_quote_line_rec.item_type_code = 'MDL') then
	     For g_notif_config_line_rec In c_get_config_tree(l_quote_id,g_notif_quote_line_rec.quote_line_id) Loop
 	     if((l_displayOptionClass = 'Y' OR (l_displayOptionClass = 'N'  and g_notif_config_line_rec.bom_item_type <> '2'))
 	        and (l_displayUnchangedItem = 'Y' OR (l_displayUnchangedItem = 'N' and g_notif_config_line_rec.config_delta <> '0')))then
				if(g_notif_config_line_rec.config_instance_name is not null) then
				  notif_line_tbl(l_index).Product := g_notif_config_line_rec.description||':'||g_notif_quote_line_rec.config_instance_name;
				else
				  notif_line_tbl(l_index).Product := g_notif_config_line_rec.description;
				end if;
				notif_line_tbl(l_index).UOM         :=g_notif_config_line_rec.unit_of_measure;
				notif_line_tbl(l_index).Quantity    :=g_notif_config_line_rec.Quantity;
				notif_line_tbl(l_index).Shippable   :=g_notif_config_line_rec.shippable_item_flag;
				notif_line_tbl(l_index).NetAmount   :=g_notif_config_line_rec.Line_quote_price;
				notif_line_tbl(l_index).Periodicity :=g_notif_config_line_rec.charge_periodicity_desc;
				notif_line_tbl(l_index).TaxAmount   :=g_notif_config_line_rec.tax_amount;
			        if(g_notif_config_line_rec.config_delta <> 0) then
				  notif_line_tbl(l_index).Action      :=g_notif_config_line_rec.action;
				end if;
			  l_index := l_index+1;
        END IF;--Hide Option class and Unchanged Lines
	     end loop;
	    end if;
	    notif_line_tbl(l_index-1).LastItem := FND_API.G_TRUE;
	    EXIT WHEN c_get_top_quote_lines%NOTFOUND;
	    END LOOP;
      l_document  :=  buildDocument(notif_line_tbl,l_view_net_price_flag,l_view_line_type_flag,p_tax_flag);
    --Order details content generation
    Elsif(p_quote_flag = fnd_api.g_false) then
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('p_quote_flag is false, entering the order area');
      END IF;
      --Begin New Order Generate Detail
      FOR g_notif_order_line_rec IN c_get_top_order_lines(l_order_id) LOOP
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.debug('Notif Order Line not null');
      END IF;
	    if(g_notif_order_line_rec.config_instance_name is not null) then
	       notif_line_tbl(l_index).Product := g_notif_order_line_rec.description||':'||g_notif_order_line_rec.config_instance_name;
	    else
	       notif_line_tbl(l_index).Product := g_notif_order_line_rec.description;
	    end if;
	    --DBMS_OUTPUT.PUT_LINE(Notif_Line_Tbl(l_index).Product);
	    notif_line_tbl(l_index).UOM         :=g_notif_order_line_rec.unit_of_measure;
	    notif_line_tbl(l_index).Quantity    :=g_notif_order_line_rec.Quantity;
	    notif_line_tbl(l_index).Shippable   :=g_notif_order_line_rec.shippable_flag;
	    notif_line_tbl(l_index).NetAmount   :=g_notif_order_line_rec.lines_total;
	    notif_line_tbl(l_index).Periodicity :=g_notif_order_line_rec.charge_periodicity_desc;
	    notif_line_tbl(l_index).TaxAmount   :=g_notif_order_line_rec.taxes_total;
	    if (g_notif_order_line_rec.config_delta_flag <> 0) then
    	      notif_line_tbl(l_index).Action      :=g_notif_order_line_rec.action;
	    end if;
      l_index := l_index+1;
      if(g_notif_order_line_rec.item_type_code = 'MODEL') then
        For g_notif_config_orderline_rec In c_get_order_config_tree(l_order_id,g_notif_order_line_rec.top_model_line_id) Loop
 	     if((l_displayOptionClass = 'Y' OR (l_displayOptionClass = 'N'  and g_notif_config_orderline_rec.item_type_code <> 'CLASS'))
 	        and (l_displayUnchangedItem = 'Y' OR (l_displayUnchangedItem = 'N' and g_notif_config_orderline_rec.config_delta_flag <> '0'))) then
 	       if(g_notif_config_orderline_rec.config_instance_name is not null) then
		       notif_line_tbl(l_index).Product := g_notif_config_orderline_rec.description||':'||g_notif_config_orderline_rec.config_instance_name;
		     else
		       notif_line_tbl(l_index).Product := g_notif_config_orderline_rec.description;
		     end if;
				 notif_line_tbl(l_index).UOM         :=g_notif_config_orderline_rec.unit_of_measure;
				 notif_line_tbl(l_index).Quantity    :=g_notif_config_orderline_rec.Quantity;
				 notif_line_tbl(l_index).Shippable   :=g_notif_config_orderline_rec.shippable_flag;
				 notif_line_tbl(l_index).NetAmount   :=g_notif_config_orderline_rec.lines_total;
				 notif_line_tbl(l_index).Periodicity :=g_notif_config_orderline_rec.charge_periodicity_desc;
				 notif_line_tbl(l_index).TaxAmount   :=g_notif_config_orderline_rec.taxes_total;
                                 if (g_notif_config_orderline_rec.config_delta_flag <> 0) then
  				   notif_line_tbl(l_index).Action      :=g_notif_config_orderline_rec.action;
				 end if;
         l_index := l_index+1;
        END IF;--Hide Option class and Unchanged Lines
      END LOOP;
      END IF;
      if(g_notif_order_line_rec.item_type_code = 'KIT') then
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.Debug('Kit found here: Need to do changes');
        END IF;
        For g_notif_config_orderline_rec In c_get_order_config_tree(l_quote_id,g_notif_order_line_rec.top_model_line_id) Loop
         notif_line_tbl(l_index).NetAmount := notif_line_tbl(l_index).NetAmount + g_notif_config_orderline_rec.lines_total;
         notif_line_tbl(l_index).TaxAmount := notif_line_tbl(l_index).NetAmount + g_notif_config_orderline_rec.lines_total;
	      END LOOP;
      end if;
      notif_line_tbl(l_index-1).LastItem := FND_API.G_TRUE;
      END LOOP;
      --End New Order Generate Detail
      l_document  :=  buildDocument(notif_line_tbl,l_view_net_price_flag,l_view_line_type_flag,p_tax_flag);
    END IF; --for l_quote_flag
    x_document := l_document;
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       ibe_util.debug('Generate_Detail -  l_document - ' ||NEWLINE||l_document);
    END IF;
  END;

/********************************************************
 GenerateReturnDetail: Here the input parameters are
                       item_key and tax_flag of the user and
                       x_document is the output parameter.

 This procedure is responsible to retrive the return order details.
 This procedure is being called from Generate_Rtn_ord_Detail_notax
 and Generate_Rtn_ord_Detail_wtax procedures.
*********************************************************/
PROCEDURE GenerateReturnDetail(
	P_item_key	IN                  VARCHAR2,
	p_tax_flag	IN                  VARCHAR2,
	x_document	IN	OUT NOCOPY	VARCHAR2
)IS

l_item_key	        WF_ITEMS.ITEM_KEY%TYPE;
l_event_type	        VARCHAR2(20);
l_document	        VARCHAR2(32000) := '';
l_string_in 	        VARCHAR2(250);
l_string_out	        VARCHAR2(250);
l_string_left	        VARCHAR2(250);
lr_string_in 	        VARCHAR2(250);
lr_string_out	        VARCHAR2(250);
lr_string_left	        VARCHAR2(250);
lr_length              NUMBER;
l_order_id             NUMBER;
l_amt_format           VARCHAR2(50);
l_curr_sym   FND_CURRENCIES.SYMBOL%TYPE;
l_temp_str	        VARCHAR2(2000) :='';
l_view_net_price_flag  VARCHAR2(2);
l_tax_flag             VARCHAR2(1);
l_parent_line_id       NUMBER;
p_index                NUMBER;
l_return_reason_code   AR_LOOKUPS.LOOKUP_CODE%TYPE;
l_return_reason        AR_LOOKUPS.MEANING%TYPE;
p_mdl_source_line_id   VARCHAR2(240);
l_print_len            NUMBER;
  l_can_qty       VARCHAR2(50);
  l_can_amt       VARCHAR2(50);


Cursor cursor_for_std_mdl_items(p_order_id  NUMBER) IS
  SELECT source_line_id,
         item_type_code,
         orig_top_model_line_id,
         orig_link_to_line_id,
         item_description,
         item_number,
         source_order_number,
         return_reason_code,
         returned_quantity,
         lines_total,
         taxes_total,
         charges_total
  FROM ibe_return_detail_v
  WHERE  header_id = p_order_id
  AND (orig_top_model_line_id is null or (orig_top_model_line_id = source_line_id and orig_link_to_line_id is null))
  ORDER BY line_number,
           shipment_number,
           nvl( option_number,-1),
           nvl( component_number,-1),
           nvl( service_number,-1);
c_detail_rec1 cursor_for_std_mdl_items%rowtype;

Cursor cursor_for_mdl_components(p_order_id  NUMBER, p_mdl_source_line_id VARCHAR2) IS
  SELECT source_line_id,
         item_type_code,
         orig_top_model_line_id,
         orig_link_to_line_id,
         orig_item_type_code,
         item_description,
         item_number,
         source_order_number,
         return_reason_code,
         returned_quantity,
         lines_total,
         taxes_total,
         charges_total
  FROM ibe_return_detail_v
  WHERE  header_id = p_order_id
  and orig_link_to_line_id is not null and ( orig_top_model_line_id = to_number(p_mdl_source_line_id))
  ORDER BY line_number,
           shipment_number,
           nvl( option_number,-1),
           nvl( component_number,-1),
           nvl( service_number,-1);
c_detail_rec2 cursor_for_mdl_components%rowtype;

CURSOR c_return_reason(l_return_reason_code VARCHAR2) IS
SELECT meaning
FROM ar_lookups
WHERE lookup_type = 'CREDIT_MEMO_REASON'
  AND lookup_code = l_return_reason_code;

  type order_details_tbl_type is table of ibe_return_detail_v%rowtype
                                          INDEX BY BINARY_INTEGER;
  ord_detail_tbl    order_details_tbl_type;
  i                 number :=1;
  j                 number :=1;
  counter           number;
  l_kit_line_id     number;
  l_kit_index       number :=0 ;
  l_kit_line_price  number := 0;
  l_kit_line_tax    number := 0;
  l_kit_found_here    number := 0;
  TYPE Kit_log_rec IS RECORD (
      Kit_line_index    NUMBER,
      item_type_code    VARCHAR2(2000),
      lines_total       NUMBER,
      taxes_total       NUMBER,
      total_line_price  NUMBER,
      total_tax_price   NUMBER);

  TYPE kit_log_tbl_type IS table OF kit_log_rec INDEX BY BINARY_INTEGER;
  kit_log_tbl         kit_log_tbl_type; --PL/SQl table to save 'KIT' and 'INCLUDED' items

BEGIN


	l_item_key := P_item_key;

	l_order_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname	=> 'ORDERID'
	);


	l_event_type := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname		=> 'EVENTTYPE'
	);



        For ord_hd_rec In c_order_header(l_order_id) Loop
	       l_amt_format := FND_CURRENCY.GET_FORMAT_MASK(ord_hd_rec.transactional_curr_code,18);

             For curr_sym_rec In c_curr_symbol(ord_hd_rec.transactional_curr_code) Loop
               l_curr_sym   := trim(nvl(curr_sym_rec.symbol,' '));
             End Loop;

        End Loop;



        OPEN cursor_for_std_mdl_items(l_order_id);
        LOOP

-------------------------------------------
         FETCH cursor_for_std_mdl_items INTO c_detail_rec1;
          EXIT WHEN cursor_for_std_mdl_items%NOTFOUND;

          IF(c_detail_rec1.orig_top_model_line_id is NULL) THEN  -- STD item

             ord_detail_tbl(i).line_id          := c_detail_rec1.source_line_id;
             ord_detail_tbl(i).item_number      := c_detail_rec1.item_number;
             ord_detail_tbl(i).item_description := c_detail_rec1.item_description;
             ord_detail_tbl(i).source_order_number := c_detail_rec1.source_order_number;
             ord_detail_tbl(i).item_type_code   := c_detail_rec1.item_type_code;
             ord_detail_tbl(i).returned_quantity := c_detail_rec1.returned_quantity;
             ord_detail_tbl(i).return_reason_code    := c_detail_rec1.return_reason_code;
             ord_detail_tbl(i).lines_total      := c_detail_rec1.lines_total;
             ord_detail_tbl(i).taxes_total      := c_detail_rec1.taxes_total;
             i:=i+1;
          ELSE -- MDL item case
             -- First take the model item and save it in ord_detail_tbl.
             ord_detail_tbl(i).line_id          := c_detail_rec1.source_line_id;
             p_mdl_source_line_id               := c_detail_rec1.source_line_id;
             ord_detail_tbl(i).item_number      := c_detail_rec1.item_number;
             ord_detail_tbl(i).item_description := c_detail_rec1.item_description;
             ord_detail_tbl(i).source_order_number := c_detail_rec1.source_order_number;
             ord_detail_tbl(i).item_type_code   := c_detail_rec1.item_type_code;
             ord_detail_tbl(i).returned_quantity := c_detail_rec1.returned_quantity;
             ord_detail_tbl(i).return_reason_code    := c_detail_rec1.return_reason_code;
             ord_detail_tbl(i).lines_total      := c_detail_rec1.lines_total;
             ord_detail_tbl(i).taxes_total      := c_detail_rec1.taxes_total;
             j:= i; -- to note that this is a model item and we need to roll up the total and taxes
             i:=i+1;
             -- now get the components of this model item.
             OPEN cursor_for_mdl_components(l_order_id, p_mdl_source_line_id);
             LOOP
               FETCH cursor_for_mdl_components INTO c_detail_rec2;
               EXIT WHEN cursor_for_mdl_components%NOTFOUND;
            IF (c_detail_rec2.orig_item_type_code <> 'INCLUDED') THEN
               ord_detail_tbl(i).line_id          := c_detail_rec2.source_line_id;
               ord_detail_tbl(i).item_number      := c_detail_rec2.item_number;
               ord_detail_tbl(i).item_description := c_detail_rec2.item_description;
               ord_detail_tbl(i).source_order_number := NULL;--c_detail_rec2.source_order_number;
               ord_detail_tbl(i).item_type_code   := c_detail_rec2.item_type_code;
               ord_detail_tbl(i).returned_quantity := c_detail_rec2.returned_quantity;
               ord_detail_tbl(i).return_reason_code    :='';
               i := i+1;
            END IF;
               -- below roll up the totals to its parent (model) item.
               ord_detail_tbl(j).lines_total      := ord_detail_tbl(j).lines_total + c_detail_rec2.lines_total;
               ord_detail_tbl(j).taxes_total      := ord_detail_tbl(j).taxes_total + c_detail_rec2.taxes_total;
             END LOOP;
               CLOSE cursor_for_mdl_components;
          END IF;

        END LOOP;
      CLOSE cursor_for_std_mdl_items;
-------------------------------------

      i := 0;
           /*Construct the display string from the ord_detail_tbl here*/
-------------------------------
FOR i IN 1..ORD_DETAIL_TBL.COUNT loop
        l_document := l_document || rpad(ltrim(rtrim(ord_detail_tbl(i).item_number)),7)||' ';
        l_string_in := rtrim(ord_detail_tbl(i).item_description);
        l_string_out := '';
        l_string_left := '';
        ibe_workflow_pvt.ParseThisString1(l_string_in,l_string_out,l_string_left);
       l_document := l_document ||rpad(l_string_out,20)||' ' ;
        IF (ord_detail_tbl(i).source_order_number IS NOT NULL) THEN
           l_document := l_document || rpad(to_char(ord_detail_tbl(i).source_order_number),9)||' ';
        ELSE
           l_document := l_document || rpad(' ',10);
        END IF;
        l_can_qty  := ibe_util.nls_number_format(p_number_in => to_char(ord_detail_tbl(i).returned_quantity));
        l_document := l_document || rpad(to_char(to_number(l_can_qty)),5)||' ';

        l_view_net_price_flag:= wf_engine.GetItemAttrText (
                  itemtype => g_itemType,
                  itemkey  => l_item_key,
                  aname    => 'VIEWNETPRICE'
                    );
        IF l_view_net_price_flag = 'Y'  THEN
           IF (to_char(ord_detail_tbl(i).lines_total) is  null) THEN
             l_document := l_document || lpad(' ' || to_char(to_number(ord_detail_tbl(i).lines_total),l_amt_format), 14, ' ');
           ELSE
           l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(ord_detail_tbl(i).lines_total));
           l_document := l_document || lpad(l_curr_sym || to_char(to_number(l_can_amt),l_amt_format), 14, ' ')||' ';
           END IF;
        END IF;
       IF (ord_detail_tbl(i).return_reason_code is not NULL) THEN
          l_return_reason_code := ord_detail_tbl(i).return_reason_code;
          l_return_reason := ' ';
          OPEN c_return_reason(l_return_reason_code);
          LOOP
            FETCH c_return_reason INTO l_return_reason;
            EXIT WHEN c_return_reason%NOTFOUND;
            ord_detail_tbl(i).return_reason_code := l_return_reason;
          END LOOP;
          CLOSE c_return_reason ;
        ELSE
          l_document := l_document||NEWLINE;
        END IF;
        lr_length := length(ord_detail_tbl(i).return_reason_code);
        IF (lr_length > 12) THEN
            lr_string_in := rtrim(ord_detail_tbl(i).return_reason_code);
            lr_string_out := '';
            lr_string_left := '';
            ibe_workflow_pvt.ParseThisString1(lr_string_in,lr_string_out,lr_string_left);
            l_document := l_document||rpad(lr_string_out,11)|| NEWLINE;
            lr_length := length(lr_string_left);
            IF (lr_length > 0) THEN
                   lr_string_in := lr_string_left;
            ELSE
                   lr_string_in := '';
            END IF;
         ELSE
               --l_document := l_document || ord_detail_tbl(i).return_reason_code||NEWLINE;
                 IF lr_length <> 0 THEN
                   l_print_len := length(ord_detail_tbl(i).return_reason_code);
                   IF l_view_net_price_flag = 'Y'  THEN
                      l_print_len := 12;
                   ELSE
                      --l_document := l_document||rpad(' ',15); -----29-dec-2003
                      l_print_len := 12;
                   END IF;
                   l_document := l_document ||rpad(ord_detail_tbl(i).return_reason_code,l_print_len)||NEWLINE;
                 END IF;
         END IF;
	l_string_in := l_string_left;
     WHILE  length(l_string_in) > 0 or length(lr_string_in) > 0  LOOP
          IF (length(l_string_in) > 0) THEN
             l_string_out := '';
             l_string_left := '';
             ibe_workflow_pvt.ParseThisString1(l_string_in,l_string_out,l_string_left);
             IF l_view_net_price_flag = 'Y'  THEN
                  l_document := l_document ||rpad(' ',8)||rpad(l_string_out,20)||rpad(' ',32) ;
             ELSE
                  l_document := l_document ||rpad(' ',8)||rpad(l_string_out,20)||rpad(' ',17) ;
             END IF;

             l_string_in := l_string_left ;
                   IF length(lr_string_in) > 0   THEN
                     lr_string_out := '';
                     lr_string_left := '';
                     ibe_workflow_pvt.ParseThisString1(lr_string_in,lr_string_out,lr_string_left);
                     IF l_view_net_price_flag = 'Y'  THEN
                        l_print_len := 11;
                     ELSE
                        l_print_len := 11;
                     END IF;
                     l_document := l_document ||rpad(lr_string_out,l_print_len)||NEWLINE;
                     --l_document := l_document ||TAB||TAB||TAB||TAB||TAB||TAB||lr_string_out||NEWLINE ;
                     lr_string_in := lr_string_left ;
                   ELSE
                       l_document := l_document||NEWLINE;
                   END IF;
             ELSE
                 IF (length(lr_string_in) > 0 ) THEN
                  lr_string_out := '';
                  lr_string_left := '';
               ibe_workflow_pvt.ParseThisString1(lr_string_in,lr_string_out,lr_string_left);
               --l_document := l_document ||TAB||TAB||TAB||TAB||lr_string_out||NEWLINE ;
                IF l_view_net_price_flag = 'Y'  THEN
                   l_print_len := 11;
                   l_document := l_document ||rpad(' ',60)||rpad(lr_string_out,l_print_len)||NEWLINE;
                ELSE
                   l_print_len := 11;
                   l_document := l_document ||rpad(' ',46)||rpad(lr_string_out,l_print_len)||NEWLINE;
                END IF;
                     --l_document := l_document ||rpad(' ',58)||rpad(lr_string_out,l_print_len)||NEWLINE;
               lr_string_in := lr_string_left ;
                  ELSE
                     l_document := l_document ||NEWLINE;
                  END IF;
              END IF;
     END LOOP;
        IF (l_view_net_price_flag = 'Y' and p_tax_flag = fnd_api.g_true)  THEN
	    fnd_message.set_name('IBE','IBE_PRMT_ORD_TAX');
	    l_temp_str := null;
	    l_temp_str := fnd_message.get;
            IF  (to_char(ord_detail_tbl(i).taxes_total) is not null) THEN
              --l_document := l_document ||
              --lpad(l_temp_str||': '||' '|| to_char(to_number(ord_detail_tbl(i).taxes_total),l_amt_format),72,' ')||NEWLINE;
            --ELSE
            l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(ord_detail_tbl(i).taxes_total));
	      l_document := l_document ||
                    lpad(l_temp_str||': '||l_curr_sym|| to_char(to_number(l_can_amt),l_amt_format),59,' ')||NEWLINE;
            END IF;
         END IF;
		l_document := l_document || NEWLINE;
   END LOOP;


----------------------------
   x_document := l_document;


   EXCEPTION
       When Others Then
		 NULL;
	Raise;
END GenerateReturnDetail;


  PROCEDURE Generate_order_Detail_wtax(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
	) is
  L_api_name     CONSTANT VARCHAR2(30)  := 'Generate_order_Detail_wtax';
  L_api_version  CONSTANT NUMBER     := 1.0;

  L_quote_flag  VARCHAR2(1) := fnd_api.g_false;
  L_tax_flag    VARCHAR2(1) := fnd_api.g_true;
  BEGIN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Generate_order_Detail_wtax:START');
    END IF;
    ibe_workflow_pvt.Generate_Detail(
	  P_item_key   => document_id,
      p_quote_flag => l_quote_flag,
      p_tax_flag   => l_tax_flag,
	  x_document   => document
	  );

    IF(display_type = 'text/html') THEN
      document_type := 'text/html';
    ELSE
      document_type := 'text/plain';
    END IF;

   EXCEPTION
   WHEN OTHERS THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Unidentified error in ibe_workflow_pvt.Generate_order_Detail_wtax');
     END IF;

   END;
/********************************************************
Generate_Rtn_ord_Detail_wtax: Here the input parameters are
                              document_id and display_type.
                              document_id is nothingbut item key.
                              display_type is text or html type message.
                              The in and out parameters are document and document_type.
                              Docuemnt contains order details.
                              And document type is again text/html.

 This procedure is responsible to get order details (with tax) and sent to workflow process.
 This procedure is getting called from workflow process.
 This procedure calls GenerateReturnDetail procedure. And this procedure sends the
 order details in document parameter. This parameter value will be sent back to workflow process
*********************************************************/
PROCEDURE  Generate_Rtn_ord_Detail_wtax (
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
	) is
  l_api_name     CONSTANT VARCHAR2(30)  := 'Generate_rtn_ord_Detail_wtax';
  l_api_version  CONSTANT NUMBER        := 1.0;
  l_tax_flag              VARCHAR2(1)   := fnd_api.g_true;

BEGIN

     ibe_workflow_pvt.GenerateReturnDetail(
	  p_item_key   => document_id,
       p_tax_flag   => l_tax_flag,
	  x_document   => document
	  );

     IF(display_type = 'text/html') THEN
      document_type := 'text/html';
     ELSE
      document_type := 'text/plain';
     END IF;

   EXCEPTION
   WHEN OTHERS THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Unidentified error in ibe_workflow_pvt.Generate_rtn_ord_Detail_wtax');
     END IF;

END Generate_Rtn_ord_Detail_wtax ;



  --Added by mannamra
  PROCEDURE Generate_quote_Detail_wtax(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
	) is
  L_api_name     CONSTANT VARCHAR2(30)  := 'Generate_quote_Detail_wtax';
  L_api_version  CONSTANT NUMBER     := 1.0;

  L_quote_flag  VARCHAR2(1) := fnd_api.g_true;
  L_tax_flag    VARCHAR2(1) := fnd_api.g_true;
  BEGIN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Generate_quote_Detail_wtax:START');
    END IF;
    ibe_workflow_pvt.Generate_Detail(
	  P_item_key   => document_id,
      p_quote_flag => l_quote_flag,
      p_tax_flag   => l_tax_flag,
	  x_document   => document
	  );

  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Unidentified error in ibe_workflow_pvt.Generate_quote_Detail_wtax');
      END IF;

  END;
  --Added by mannamra
  PROCEDURE Generate_order_Detail_notax(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
	) is
  L_api_name     CONSTANT VARCHAR2(30)  := 'Generate_order_Detail_notax';
  L_api_version  CONSTANT NUMBER     := 1.0;

  L_quote_flag  VARCHAR2(1) := fnd_api.g_false;
  L_tax_flag    VARCHAR2(1) := fnd_api.g_false;
  BEGIN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Generate_order_Detail_notax:START');
    END IF;
    ----DBMS_OUTPUT.PUT('Generate_order_Detail_notax:START');
    ibe_workflow_pvt.Generate_Detail(
	  P_item_key   => document_id,
      p_quote_flag => l_quote_flag,
      p_tax_flag   => l_tax_flag,
	  x_document   => document
	  );

  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Unidentified error in ibe_workflow_pvt.Generate_order_Detail_notax');
      END IF;

  END;

/********************************************************
Generate_Rtn_ord_Detail_notax: Here the input parameters are
                               document_id and display_type.
                              document_id is nothingbut item key.
                              display_type is text or html type message.
                              The in and out parameters are document and document_type.
                              Docuemnt contains order details.
                              And document type is again text/html.

 This procedure is responsible to get order details (without tax) and sent to workflow process.
 This procedure is getting called from workflow process.
 This procedure calls GenerateReturnDetail procedure. And this procedure sends the
 order details in document parameter. This parameter value will be sent back to workflow process
*********************************************************/
PROCEDURE  Generate_Rtn_ord_Detail_notax (
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
	) is
  l_api_name     CONSTANT VARCHAR2(30)  := 'Generate_rtn_ord_Detail_notax';
  l_api_version  CONSTANT NUMBER        := 1.0;
  l_tax_flag              VARCHAR2(1)   := fnd_api.g_false;

BEGIN

    ibe_workflow_pvt.GenerateReturnDetail(
	p_item_key   => document_id,
        p_tax_flag   => l_tax_flag,
	x_document   => document
	);

   IF(display_type = 'text/html') THEN
     document_type := 'text/html';
   ELSE
     document_type := 'text/plain';
   END IF;

   EXCEPTION
   WHEN OTHERS THEN
     IF (IBE_UTIL.G_DEBUGON = l_true) THEN
        IBE_UTIL.DEBUG('Unidentified error in ibe_workflow_pvt.Generate_rtn_ord_Detail_notax');
     END IF;

END Generate_Rtn_ord_Detail_notax;



  --Added by mannamra
  PROCEDURE Generate_quote_Detail_notax(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
	) is
  L_api_name     CONSTANT VARCHAR2(30)  := 'Generate_quote_Detail_notax';
  L_api_version  CONSTANT NUMBER     := 1.0;

  L_quote_flag  VARCHAR2(1) := fnd_api.g_true;
  L_tax_flag    VARCHAR2(1) := fnd_api.g_false;
  BEGIN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
       IBE_UTIL.DEBUG('Generate_order_Detail_notax:START');
    END IF;
    ibe_workflow_pvt.Generate_Detail(
	  P_item_key   => document_id,
      p_quote_flag => l_quote_flag,
      p_tax_flag   => l_tax_flag,
	  x_document   => document
	  );

  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;

  EXCEPTION
    WHEN OTHERS THEN
      IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         IBE_UTIL.DEBUG('Unidentified error in ibe_workflow_pvt.Generate_quote_Detail_notax');
      END IF;

  END;
--existing API
PROCEDURE GenerateDetail(
	document_id	IN              VARCHAR2,
	display_type	IN              VARCHAR2,
	document	IN	OUT NOCOPY	VARCHAR2,
	document_type	IN	OUT NOCOPY	VARCHAR2
)IS

l_item_type	wf_items.item_type%TYPE;
l_item_key	wf_items.item_key%TYPE;
l_quote_id	NUMBER;
l_event_type	VARCHAR2(20);
l_document	VARCHAR2(32000) := '';
l_ship_flag	VARCHAR2(1);
l_string_in 	VARCHAR2(250);
l_string_out	VARCHAR2(250);
l_string_left	VARCHAR2(250);
l_order_id      NUMBER;

l_amt_format   Varchar2(50);
l_curr_sym   FND_CURRENCIES.SYMBOL%TYPE;

l_temp_str	VARCHAR2(2000):='';
l_view_net_price_flag VARCHAR2(1);

Cursor c_ship_flag(p_line_id NUMBER) IS
SELECT msi.shippable_item_flag
FROM oe_order_lines_all line, OE_SYSTEM_PARAMETERS_ALL osp,
mtl_system_items_kfv msi
WHERE line.line_id = p_line_id
AND   line.org_id = osp.org_id
AND   osp.master_organization_id  = msi.organization_id
AND   line.inventory_item_id = msi.inventory_item_id;

BEGIN

	l_item_key := document_id;
    ----DBMS_OUTPUT.PUT('Calling GenerateDetail - l_item_key  -  '||l_item_key);
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateDetail - l_item_key  -  '||l_item_key);
	END IF;

	l_quote_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname	=> 'QUOTEID'
	);
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateDetail - l_quote_id - '||l_quote_id);
	END IF;

	l_order_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname	=> 'ORDERID'
	);

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('GenerateDetail - l_order_id -  '||l_order_id);
       END IF;


	l_event_type := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname		=> 'EVENTTYPE'
	);


      l_view_net_price_flag:= wf_engine.GetItemAttrText (
                    itemtype => g_itemType,
                    itemkey  => l_item_key,
                    aname    => 'VIEWNETPRICE'
	          );


	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateDetail - l_event_type - '|| l_event_type);
	END IF;

        IF l_view_net_price_flag = 'Y' THEN
           For ord_hd_rec In c_order_header(l_order_id) Loop
	       l_amt_format := FND_CURRENCY.GET_FORMAT_MASK(ord_hd_rec.transactional_curr_code,18);

               For curr_sym_rec In c_curr_symbol(ord_hd_rec.transactional_curr_code)
               Loop
                   l_curr_sym   := trim(nvl(curr_sym_rec.symbol,' '));
               End Loop;

            End Loop;
         END IF;

	OPEN c_order_detail(l_order_id);
		LOOP
		FETCH	c_order_detail INTO g_detail_rec;
		EXIT WHEN	c_order_detail%NOTFOUND;


		l_ship_flag := null;

                FOR c_ship_rec IN c_ship_flag(g_detail_rec.line_id) LOOP
		 l_ship_flag := c_ship_rec.shippable_item_flag;
		END LOOP;

		l_string_in := rtrim(g_detail_rec.item_description);
		l_string_out := '';
		l_string_left := '';
		ibe_workflow_pvt.ParseThisString(l_string_in,l_string_out,l_string_left);

		l_document := l_document || l_string_out ||TAB;
		l_document := l_document || to_char(g_detail_rec.ordered_quantity)||TAB;
		l_document := l_document || l_ship_flag;
            IF l_view_net_price_flag = 'Y' THEN
		   l_document := l_document || lpad(l_curr_sym || to_char(g_detail_rec.lines_total,l_amt_format), 23, ' ');
            END IF;

		l_string_in := l_string_left;
		WHILE  length(l_string_in) > 0  LOOP
			l_string_out := '';
			l_string_left := '';
			ibe_workflow_pvt.ParseThisString(l_string_in,l_string_out,l_string_left);
			l_document := l_document || l_string_out ||NEWLINE;
			l_string_in := l_string_left;
		END LOOP;

           IF l_view_net_price_flag = 'Y' THEN
		   fnd_message.set_name('IBE','IBE_PRMT_ORD_TAX');
		   l_temp_str := null;
		   l_temp_str := fnd_message.get;

		   l_document := l_document ||
                                 lpad(l_temp_str||': '||l_curr_sym|| to_char(g_detail_rec.taxes_total,l_amt_format),72,' ')||
                                 NEWLINE;
          END IF;

		l_document := l_document || NEWLINE;

	END LOOP;
	CLOSE c_order_detail;

	document := l_document;

    IF(display_type = 'text/html') THEN
      document_type := 'text/html';
    ELSE
      document_type := 'text/plain';
    END IF;

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateDetail -  l_document - ' ||NEWLINE||l_document);
	END IF;

	EXCEPTION
		When Others Then
			IF c_order_detail%ISOPEN THEN
				CLOSE c_order_detail;
			END IF;
		Raise;
END GenerateDetail;

PROCEDURE GenerateFooter(
	document_id	IN              	VARCHAR2,
	display_type	IN              	VARCHAR2,
	document		IN OUT NOCOPY	VARCHAR2,
	document_type	IN	OUT NOCOPY	VARCHAR2
)IS

l_item_type	wf_items.item_type%TYPE;
l_item_key	wf_items.item_key%TYPE;
l_quote_id	NUMBER;
l_event_type	VARCHAR2(20);
l_document	VARCHAR2(32000) := '';
l_temp_str	VARCHAR2(2000):='';
l_sub_total	NUMBER;
l_order_id      NUMBER;
l_view_net_price_flag VARCHAR2(1);


l_amt_format   Varchar2(50);
l_curr_sym   FND_CURRENCIES.SYMBOL%TYPE;

l_can_amt    VARCHAR2(50);
l_paynow varchar2(1);
l_reccharge varchar2(1);

Cursor c_macd_order_header (c_order_id NUMBER) IS
Select oe_totals_grp.Get_PayNow_Total(oh.header_id,null,'LINES') PayNow_lines_total,
       oe_totals_grp.Get_PayNow_Total(oh.header_id,null,'CHARGES') PayNow_charges_total,
       oe_totals_grp.Get_PayNow_Total(oh.header_id,null,'TAXES') PayNow_taxes_total,
       oe_totals_grp.Get_PayNow_Total(oh.header_id,null,'ALL') PayNow_order_total,
       oh.transactional_curr_code,
       oe_totals_grp.Get_Order_Total(oh.header_id,null,'ALL') order_total,
       oh.order_number
from   oe_order_headers_all oh
where  oh.header_id =  c_order_id;
g_macd_ord_rec  c_macd_order_header%ROWTYPE;
l_rec_charge_tbl OE_OE_TOTALS_SUMMARY.Rec_Charges_Tbl_Type;

i number;

BEGIN

	l_item_key := document_id;
    ----DBMS_OUTPUT.PUT('Calling GenerateFooter - l_item_key - '||l_item_key);
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateFooter - l_item_key - '||l_item_key);
	END IF;

	l_quote_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname	=> 'QUOTEID'
	);
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateFooter - l_quote_id - '||l_quote_id);
	END IF;

	l_order_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname	=> 'ORDERID'
	);

       IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('GenerateFooter - l_order_id -  '||l_order_id);
       END IF;

	l_event_type := wf_engine.GetItemAttrText (
		itemtype 	=> g_itemType,
		itemkey  	=> l_item_key,
		aname	=> 'EVENTTYPE'
	);


     l_view_net_price_flag:= wf_engine.GetItemAttrText (
                       itemtype => g_itemType,
                       itemkey  => l_item_key,
                       aname    => 'VIEWNETPRICE'
	               );

   l_paynow := wf_engine.GetItemAttrText (
                       itemtype => g_itemType,
                       itemkey  => l_item_key,
                       aname    => 'PAYNOWENABLED'
	               );
   l_reccharge := wf_engine.GetItemAttrText (
                       itemtype => g_itemType,
                       itemkey  => l_item_key,
                       aname    => 'RECCHARGEENABLED'
	               );

   IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    ibe_util.debug('l_reccharge and l_paynow'||l_reccharge||'paynow'||l_paynow);
    ibe_util.debug('Event Type ' || l_event_type);
    ibe_util.debug('l_view_net_price_flag'||l_view_net_price_flag);
   END IF;

   if(l_reccharge = 'Y' and l_event_type  <> 'RETURNORDER') THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
         ibe_util.debug('GenerateFooter - MACD Order Footer  '|| l_event_type);
        END IF;
        OPEN c_macd_order_header(l_order_id);
        LOOP
        FETCH    c_macd_order_header INTO g_macd_ord_rec;
        EXIT WHEN    c_macd_order_header%NOTFOUND;

        IF l_view_net_price_flag = 'Y' THEN
         l_amt_format := FND_CURRENCY.GET_FORMAT_MASK(g_macd_ord_rec.transactional_curr_code,22);
         For curr_sym_rec In c_curr_symbol(g_macd_ord_rec.transactional_curr_code) Loop
           l_curr_sym   := trim(nvl(curr_sym_rec.symbol,' '));
          End Loop;
         END IF;
         IF l_view_net_price_flag = 'Y' THEN
         fnd_message.set_name('IBE','IBE_PRMT_OT_ONE_TIME_PRICE');
         l_temp_str := null;
         l_temp_str := fnd_message.get;
         l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_macd_ord_rec.order_total));
         l_document := l_document|| lpad(l_temp_str,51,' ')|| ' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt), l_amt_format), 20, ' ')||NEWLINE;

        --Call OM to find the recurring totals
        OE_Totals_GRP.GET_RECURRING_TOTALS
        (
          p_header_id => l_order_id,
          x_rec_charges_tbl => l_rec_charge_tbl
         );
        IF(l_rec_charge_tbl is not null) THEN
        i := l_rec_charge_tbl.FIRST;
        WHILE i is not null
            LOOP
        l_document := l_document || lpad(l_rec_charge_tbl(i).charge_periodicity_meaning,51,' ');
        l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(l_rec_charge_tbl(i).rec_subtotal));
        l_document := l_document || lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;
        i := l_rec_charge_tbl.NEXT(i);
        END LOOP;
           END IF;
        END IF;
           END LOOP;
           CLOSE c_macd_order_header;
   ELSE
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateFooter - NON-MACD Order Footer l_event_type - '|| l_event_type);
	END IF;

	OPEN c_order_header(l_order_id);
	LOOP
		FETCH	c_order_header INTO g_header_rec;
		EXIT WHEN	c_order_header%NOTFOUND;


                IF l_view_net_price_flag = 'Y' THEN
  	            l_amt_format := FND_CURRENCY.GET_FORMAT_MASK(g_header_rec.transactional_curr_code,22);

                  For curr_sym_rec In c_curr_symbol(g_header_rec.transactional_curr_code) Loop
                      l_curr_sym   := trim(nvl(curr_sym_rec.symbol,' '));
                 End Loop;
               END IF;


		--IF (display_type = 'text/plain' ) THEN
               IF l_view_net_price_flag = 'Y' THEN

			fnd_message.set_name('IBE','IBE_PRMT_SUBTOTAL_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;

			l_sub_total := g_header_rec.lines_total;
                  l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(l_sub_total));
                IF l_event_type  = 'RETURNORDER' THEN
                     l_document := l_document ||lpad(l_temp_str,44,' ')||' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),14,' ')||NEWLINE;
                ELSE
                     l_document := l_document ||lpad(l_temp_str,51,' ')||' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;
                END IF;
                l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_header_rec.charges_total));
                IF l_event_type  = 'RETURNORDER' THEN
			   fnd_message.set_name('IBE','IBE_OT_RET_CHARGES');
			   l_temp_str := null;
			   l_temp_str := fnd_message.get;

			   l_document := l_document || lpad(l_temp_str,44,' ')||' '||  lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),14,' ')||NEWLINE;
               ELSE
			   fnd_message.set_name('IBE','IBE_PRMT_SHIP_HAND_COLON');
			   l_temp_str := null;
			   l_temp_str := fnd_message.get;

			   l_document := l_document || lpad(l_temp_str,51,' ')||' '||  lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;
               END IF;
			fnd_message.set_name('IBE','IBE_PRMT_TAX_EST_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
                  l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_header_rec.taxes_total));
               IF l_event_type  = 'RETURNORDER' THEN
                  l_document := l_document || lpad(l_temp_str,44,' ')||' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),14,' ')||NEWLINE;
               ELSE
                  l_document := l_document || lpad(l_temp_str,51,' ')||' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;
               END IF;


                        fnd_message.set_name('IBE','IBE_PRMT_SC_TOTAL2');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
                  l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_header_rec.order_total));
               IF l_event_type  = 'RETURNORDER' THEN
                     l_document := l_document|| lpad(l_temp_str,44,' ')|| ' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt), l_amt_format), 14, ' ')||NEWLINE;
               ELSE
                        l_document := l_document|| lpad(l_temp_str,51,' ')|| ' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt), l_amt_format), 20, ' ')||NEWLINE;
               END IF;
               END IF;
		--ELSE
			--null;
		--END IF;
	END LOOP;
	CLOSE c_order_header;
	END IF; --Non MACD Footer

        --Amount due with order display
     if (l_reccharge = 'Y' OR l_paynow = 'Y') then
          OPEN c_macd_order_header(l_order_id);
          LOOP
          FETCH     c_macd_order_header INTO g_macd_ord_rec;
          EXIT WHEN     c_macd_order_header%NOTFOUND;

          IF l_view_net_price_flag = 'Y' THEN
           l_amt_format := FND_CURRENCY.GET_FORMAT_MASK(g_macd_ord_rec.transactional_curr_code,22);
           For curr_sym_rec In c_curr_symbol(g_macd_ord_rec.transactional_curr_code) Loop
             l_curr_sym   := trim(nvl(curr_sym_rec.symbol,' '));
            End Loop;
           END IF;
           IF l_view_net_price_flag = 'Y' THEN
           fnd_message.set_name('IBE','IBE_PRMT_SC_PAY_NOW_CHARGES');
           l_temp_str := null;
           l_temp_str := fnd_message.get;
           l_document := l_document || lpad(l_temp_str,51,' ')||NEWLINE;
           l_document := l_document || lpad('-',(51-length(l_temp_str)))||rpad('-',(71-(51-(length(l_temp_str)))),'-')||NEWLINE;

           fnd_message.set_name('IBE','IBE_PRMT_SUBTOTAL_COLON');
           l_temp_str := null;
           l_temp_str := fnd_message.get;
           l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_macd_ord_rec.paynow_lines_total));
           l_document := l_document ||lpad(l_temp_str,51,' ')||' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;

           fnd_message.set_name('IBE','IBE_PRMT_TAX_COL');
           l_temp_str := null;
           l_temp_str := fnd_message.get;
           l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_macd_ord_rec.paynow_taxes_total));
           l_document := l_document || lpad(l_temp_str,51,' ')||' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;

           fnd_message.set_name('IBE','IBE_PRMT_SHIP_HAND_COLON');
           l_temp_str := null;
           l_temp_str := fnd_message.get;
           l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_macd_ord_rec.paynow_charges_total));
           l_document := l_document || lpad(l_temp_str,51,' ')||' '||  lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;

           fnd_message.set_name('IBE','IBE_PRMT_SC_PN_TOTAL_COL');
           l_temp_str := null;
           l_temp_str := fnd_message.get;
           l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_macd_ord_rec.paynow_order_total));
           l_document := l_document|| lpad(l_temp_str,51,' ')|| ' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt), l_amt_format), 20, ' ');
          END IF;
            END LOOP;
            CLOSE c_macd_order_header;
     end if;

	document := l_document;

    IF(display_type = 'text/html') THEN
      document_type := 'text/html';
      document := document || '</Pre>';  -- bug 13363458, nsatyava
    ELSE
      document_type := 'text/plain';
    END IF;
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateFooter - l_document - '||NEWLINE|| l_document);
	END IF;

	EXCEPTION
		When Others Then
			IF c_order_header%ISOPEN THEN
				CLOSE c_order_header;
			END IF;
		Raise;
END GenerateFooter;

PROCEDURE GenerateQuoteHeader(
	document_id	IN              	VARCHAR2,
	display_type    	IN              	VARCHAR2,
	document        	IN      	OUT NOCOPY     	VARCHAR2,
	document_type   	IN      	OUT NOCOPY     	VARCHAR2
) IS

l_item_type		wf_items.item_type%TYPE := 'IBEALERT';
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

l_sold_contact_party_id		 Number;
l_bill_contact_party_id		 Number;
l_ship_contact_party_id		 Number;


BEGIN

        l_item_key := document_id;

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteHeader - l_item_key - '||l_item_key);
	END IF;

	l_quote_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname	=> 'QUOTEID'
	);
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteHeader - l_quote_id - '||l_quote_id);
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


	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteHeader - l_event_type - '|| l_event_type);
	END IF;

          FOR c_contract_rec In c_contract_header(l_contract_id) LOOP
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

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateQuoteHeader - l_contact_name '|| l_contact_name);
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

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateQuoteHeader - l_contact_number - '|| l_contact_number);
   		ibe_util.debug('GenerateQuoteHeader - l_contact_email - '|| l_contact_email);
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

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateQuoteHeader - bill_party_name - '||l_bill_to_party_name);
   		ibe_util.debug('GenerateQuoteHeader - bill_name - '||l_bill_to_name);
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

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateQuoteHeader - bill_party_number - '||l_bill_to_number);
   		ibe_util.debug('GenerateQuoteHeader - bill_fax - '||l_bill_to_fax);
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

        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('GenerateQuoteHeader - bill_address - '||l_bill_to_address);
          ibe_util.debug('GenerateQuoteHeader - bill_city - '||l_bill_to_city);
          ibe_util.debug('GenerateQuoteHeader - bill_state - '||l_bill_to_state);
          ibe_util.debug('GenerateQuoteHeader - bill_zip - '||l_bill_to_zip);
          ibe_util.debug('GenerateQuoteHeader - bill_country - '||l_bill_to_country);
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

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
          ibe_util.debug('GenerateQuoteHeader - ship_to_site_id - '||l_ship_to_site_id);
          ibe_util.debug('GenerateQuoteHeader - ship_to_party_id - '||l_ship_to_party_id);
          ibe_util.debug('GenerateQuoteHeader - ship_to_method - '||l_ship_method_code);
		END IF;

                 /* Shipping Customer Information - ship_to_cust_account_id */




                 FOR c_hz_cust_acct_rec IN  c_hz_cust_accounts(nvl(l_ship_to_cust_account_id,g_quote_header_rec.cust_account_id)) LOOP
 		     l_ship_to_party_name := rtrim(c_hz_cust_acct_rec.party_name);
                     l_ship_to_name   := upper(rtrim(c_hz_cust_acct_rec.person_first_name))||' '||upper(rtrim(c_hz_cust_acct_rec.person_last_name));
                     l_ship_contact_party_id := c_hz_cust_acct_rec.party_id;
                 End Loop;


		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateQuoteHeader - ship_to_party_name - '||l_ship_to_party_name);
   		ibe_util.debug('GenerateQuoteHeader - ship_to_name - '||l_ship_to_name);
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

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateQuoteHeader - ship_to_number - '||l_ship_to_number);
   		ibe_util.debug('GenerateQuoteHeader - ship_to_fax - '||l_ship_to_fax);
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


		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateQuoteHeader - ship_address - '||l_ship_to_address);
   		ibe_util.debug('GenerateQuoteHeader - ship_city - '||l_ship_to_city);
   		ibe_util.debug('GenerateQuoteHeader - ship_state - '||l_ship_to_state);
   		ibe_util.debug('GenerateQuoteHeader - ship_zip - '||l_ship_to_zip);
   		ibe_util.debug('GenerateQuoteHeader - ship_country - '||l_ship_to_country);
   		ibe_util.debug('GenerateQuoteHeader - quote_header_id - '||g_quote_header_rec.quote_header_id);
		END IF;

		--IF (display_type = 'text/plain' ) THEN
				fnd_message.set_name('IBE','IBE_PRMT_QUOTE_ID_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||g_quote_header_rec.quote_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CONTRACT_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||l_contract_number||' '||l_contract_modifier||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_QUOTE_NAME_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||g_quote_header_rec.quote_name||NEWLINE;
/*
				fnd_message.set_name('IBE','IBE_PRMT_ORDER_DATE_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||g_quote_header_rec.ordered_date||NEWLINE;
*/
				fnd_message.set_name('IBE','IBE_PRMT_SHIP_METH_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_method||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CUST_CNTCT_INFO');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_NAME_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_contact_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_NUM_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_contact_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_EMAIL_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_contact_email||NEWLINE;


                             If not(l_event_type = 'TERMREJECTED') Then
	                          l_comments := wf_engine.GetItemAttrText (
			 		itemtype	=> l_item_type,
					itemkey     => l_item_key,
					aname       => 'COMMENTS'
					);
				fnd_message.set_name('IBE','IBE_PRMT_ADDL_TERMS_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||l_comments ||NEWLINE;
                             End If;

				fnd_message.set_name('IBE','IBE_PRMT_ORD_BILL_INFO');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CUST_NAME_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_party_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ADDRESS_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_address||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CITY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_bill_to_city||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_STATE_PRO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_state||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ZIP_POSTAL_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||l_bill_to_zip||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_COUNTRY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_country||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_NAME_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_TEL_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||l_bill_to_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_FAX_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_bill_to_fax||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ORD_SHIP_INFOR');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || NEWLINE ||l_temp_str ||NEWLINE||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CUST_NAME_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_party_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_ADDRESS_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_address||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CITY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||TAB||l_ship_to_city||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_STATE_PRO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_state||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_COUNTRY_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_country||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_CNTCT_NAME_COL');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_name||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_TEL_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||l_ship_to_number||NEWLINE;

				fnd_message.set_name('IBE','IBE_PRMT_FAX_NO_COLON');
				l_temp_str := null;
				l_temp_str := fnd_message.get;
				l_document := l_document || l_temp_str ||TAB||TAB||l_ship_to_fax||NEWLINE;

		--ELSE
				--null;
		--END IF;

	END LOOP;
	CLOSE c_quote_header;

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteHeader - l_document'||NEWLINE|| l_document);
	END IF;

	document := l_document;

    IF(display_type = 'text/html') THEN
      document_type := 'text/html';
    ELSE
      document_type := 'text/plain';
    END IF;

	EXCEPTION
		When Others Then
			IF c_quote_header%ISOPEN THEN
				CLOSE c_quote_header;
			END IF;
		Raise;
END GenerateQuoteHeader;



PROCEDURE GenerateQuoteDetail(
	document_id	IN		VARCHAR2,
	display_type	IN		VARCHAR2,
	document		IN OUT NOCOPY	VARCHAR2,
	document_type	IN	OUT NOCOPY	VARCHAR2
) IS

l_item_type		wf_items.item_type%TYPE := 'IBEALERT';
l_item_key		wf_items.item_key%TYPE;
l_quote_id		NUMBER;
l_event_type		VARCHAR2(20);
l_document		VARCHAR2(32000) := '';
l_description		mtl_system_items_kfv.description%TYPE;
l_ship_flag		VARCHAR2(1);
l_string_in 		VARCHAR2(250);
l_string_out		VARCHAR2(250);
l_string_left		VARCHAR2(250);
l_view_net_price_flag   VARCHAR2(1);

l_amt_format   Varchar2(50);
l_curr_sym   FND_CURRENCIES.SYMBOL%TYPE;

Cursor c_ship_flag(p_inv_item_id NUMBER,p_org_id NUMBER) IS
SELECT 		shippable_item_flag, rtrim(description) Description
	FROM		mtl_system_items_kfv
	WHERE		inventory_item_id = p_inv_item_id
	AND		organization_id = p_org_id;

BEGIN


        l_item_key := document_id;

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteDetail_new - l_item_key - '||l_item_key);
	END IF;

	l_quote_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname	=> 'QUOTEID'
	);
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteDetail_new - l_quote_id - '||l_quote_id);
	END IF;

	l_event_type := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname	 => 'EVENTTYPE'
	);
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteDetail - l_event_type - '|| l_event_type);
	END IF;

        l_view_net_price_flag := wf_engine.GetItemAttrText (
		                    itemtype 	=> g_itemType,
		                    itemkey  	=> l_item_key,
		                     aname	=> 'VIEWNETPRICE'
	                           );


         For qte_hd_rec In c_quote_header(l_quote_id) Loop

            IF l_view_net_price_flag = 'Y' THEN
  	       l_amt_format := FND_CURRENCY.GET_FORMAT_MASK(qte_hd_rec.Currency_code,18);

               For curr_sym_rec In c_curr_symbol(qte_hd_rec.Currency_code)
               Loop
                  l_curr_sym   := trim(nvl(curr_sym_rec.symbol,' '));
               End Loop;
            END IF;

        End Loop;


	OPEN c_quote_detail(l_quote_id);
	LOOP
		FETCH	c_quote_detail INTO g_quote_line_rec;
		EXIT WHEN	c_quote_detail%NOTFOUND;

		l_ship_flag := null;
		l_description := null;

		FOR c_ship_rec IN c_ship_flag(g_quote_line_rec.inventory_item_id,g_quote_line_rec.organization_id) LOOP

		l_ship_flag := c_ship_rec.shippable_item_flag;
		l_description := c_ship_rec.description;

		END LOOP;

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateQuoteDetail - l_ship_flag - '|| l_ship_flag);
   		ibe_util.debug('GenerateQuoteDetail - l_description - '|| l_description);
   		ibe_util.debug('GenerateQuoteDetail - quantity - '||g_quote_line_rec.quantity);
   		ibe_util.debug('GenerateQuoteDetail - price '||g_quote_line_rec.line_quote_price);
		END IF;

		l_string_in := l_description;
		l_string_out := '';
		l_string_left := '';
		ibe_workflow_pvt.ParseThisString(l_string_in,l_string_out,l_string_left);

		l_document := l_document || l_string_out ||TAB;
		l_document := l_document || to_char(g_quote_line_rec.quantity)||TAB;
		l_document := l_document || l_ship_flag;
            IF l_view_net_price_flag = 'Y' THEN
		   l_document := l_document || lpad(l_curr_sym||to_char( (g_quote_line_rec.quantity*g_quote_line_rec.line_quote_price), l_amt_format),23,' ');
            END IF;

		l_string_in := l_string_left;
		WHILE  length(l_string_in) > 0  LOOP
			l_string_out := '';
			l_string_left := '';
			ibe_workflow_pvt.ParseThisString(l_string_in,l_string_out,l_string_left);
			l_document := l_document || l_string_out ||NEWLINE;
			l_string_in := l_string_left;
		END LOOP;
		l_document := l_document || NEWLINE;

	END LOOP;
	CLOSE c_quote_detail;

	document := l_document;

	IF(display_type = 'text/html') THEN
      document_type := 'text/html';
    ELSE
      document_type := 'text/plain';
    END IF;

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteDetail - l_document - '||NEWLINE|| l_document);
	END IF;

	EXCEPTION
		When Others Then
			IF c_quote_detail%ISOPEN THEN
				CLOSE c_quote_detail;
			END IF;
		Raise;
END GenerateQuoteDetail;

PROCEDURE GenerateQuoteFooter(
	document_id		IN		VARCHAR2,
	display_type		IN		VARCHAR2,
	document			IN OUT NOCOPY	VARCHAR2,
	document_type		IN	OUT NOCOPY	VARCHAR2
)IS

l_item_type		wf_items.item_type%TYPE := 'IBEALERT';
l_item_key		wf_items.item_key%TYPE;
l_quote_id		NUMBER;
l_event_type		VARCHAR2(20);
l_document		VARCHAR2(32000) := '';
l_temp_str		VARCHAR2(2000):='';
l_sub_total		NUMBER;

l_view_net_price_flag   VARCHAR2(1);
l_amt_format   Varchar2(50);
l_curr_sym   FND_CURRENCIES.SYMBOL%TYPE;

l_can_amt     VARCHAR2(50);
l_paynow VARCHAR2(1);
l_reccharge VARCHAR2(1);

Cursor c_reccur_quote_footer(c_quote_id NUMBER) IS
select uom.unit_of_measure_tl charge_periodicity_desc,nvl(sum(ql.line_quote_price*ql.quantity),'0.00') rec_subtotal
from aso_quote_lines_all ql,mtl_units_of_measure_tl uom
where ql.quote_header_id = c_quote_id
      and ql.charge_periodicity_code is not null
      and uom.uom_code(+) = ql.charge_periodicity_code
      and uom.language(+) = userenv('lang')
group by uom.unit_of_measure_tl;
g_recur_quote_rec c_reccur_quote_footer%ROWTYPE;

Cursor c_macd_quote_footer(c_quote_id NUMBER) IS
select nvl(sum(ql.line_paynow_subtotal),'0.00')paynow_lines_total,nvl(sum(ql.line_paynow_charges),'0.00')paynow_charges_total,nvl(sum(ql.line_paynow_tax),'0.00')paynow_taxes_total,
       nvl(sum(ql.line_paynow_subtotal + ql.line_paynow_charges + ql.line_paynow_tax),'0.00')paynow_order_total,
       qh.total_quote_price quote_total,qh.currency_code
from aso_quote_lines_all ql,aso_quote_headers_all qh
where qh.quote_header_id = c_quote_id
      and ql.quote_header_id = qh.quote_header_id
group by ql.quote_header_id,qh.total_quote_price,qh.currency_code;
g_macd_quote_rec c_macd_quote_footer%ROWTYPE;


BEGIN

        l_item_key := document_id;

	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteFooter - l_item_key - '||l_item_key);
	END IF;

	l_quote_id := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname	=> 'QUOTEID'
	);
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteFooter - l_quote_id - '||l_quote_id);
	END IF;

	l_event_type := wf_engine.GetItemAttrText (
		itemtype 	=> g_ItemType,
		itemkey  	=> l_item_key,
		aname	=> 'EVENTTYPE'
	);
	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteFooter - l_event_type - '|| l_event_type);
	END IF;


        l_view_net_price_flag := wf_engine.GetItemAttrText (
		                  itemtype 	=> g_itemType,
		                  itemkey  	=> l_item_key,
		                  aname	=> 'VIEWNETPRICE'
	                          );

        l_paynow := wf_engine.GetItemAttrText (
                       itemtype => g_itemType,
                       itemkey  => l_item_key,
                       aname    => 'PAYNOWENABLED'
	               );

        l_reccharge := wf_engine.GetItemAttrText (
                       itemtype => g_itemType,
                       itemkey  => l_item_key,
                       aname    => 'RECCHARGEENABLED'
	               );

        if(l_reccharge = 'Y') THEN
        IF (IBE_UTIL.G_DEBUGON = l_true) THEN
           ibe_util.debug('GenerateQuoteFooter - Recurring loop');
        end if;
             OPEN c_quote_header(l_quote_id);
        LOOP
          FETCH      c_quote_header INTO g_quote_header_rec;
          EXIT WHEN      c_quote_header%NOTFOUND;
          IF l_view_net_price_flag = 'Y' THEN
             l_amt_format := FND_CURRENCY.GET_FORMAT_MASK( g_quote_header_rec.Currency_code,22);
             For curr_sym_rec In c_curr_symbol(g_quote_header_rec.Currency_code) Loop
               l_curr_sym   := trim(curr_sym_rec.symbol);
             End Loop;

           fnd_message.set_name('IBE','IBE_PRMT_OT_ONE_TIME_PRICE');
           l_temp_str := null;
           l_temp_str := fnd_message.get;
           l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_quote_header_rec.total_quote_price));
           l_document := l_document|| lpad(l_temp_str,51,' ')|| ' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt), l_amt_format), 20, ' ')||NEWLINE;

            OPEN c_reccur_quote_footer(l_quote_id);
           LOOP
           FETCH      c_reccur_quote_footer INTO g_recur_quote_rec;
           EXIT WHEN      c_reccur_quote_footer%NOTFOUND;
           l_document := l_document || lpad(g_recur_quote_rec.charge_periodicity_desc,51,' ');
           l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_recur_quote_rec.rec_subtotal));
           l_document := l_document || lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;
           END LOOP;
           CLOSE c_reccur_quote_footer;

        END IF;
        END LOOP;
        CLOSE c_quote_header;
        else
	OPEN c_quote_header(l_quote_id);
	LOOP
		FETCH	c_quote_header INTO g_quote_header_rec;
		EXIT WHEN	c_quote_header%NOTFOUND;

                 IF l_view_net_price_flag = 'Y' THEN
                    l_amt_format := FND_CURRENCY.GET_FORMAT_MASK( g_quote_header_rec.Currency_code,22);

                     For curr_sym_rec In c_curr_symbol(g_quote_header_rec.Currency_code) Loop
                         l_curr_sym   := trim(curr_sym_rec.symbol);
                     End Loop;
                 END IF;



		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('GenerateQuoteFooter - shipping - '||to_char(g_quote_header_rec.total_shipping_charge));
   		ibe_util.debug('GenerateQuoteFooter - tax - '||to_char(g_quote_header_rec.total_tax));
   		ibe_util.debug('GenerateQuoteFooter - total quote price - '||to_char(g_quote_header_rec.total_quote_price));
		END IF;

		--IF (display_type = 'text/plain' ) THEN
                IF l_view_net_price_flag = 'Y' THEN

			fnd_message.set_name('IBE','IBE_PRMT_SUBTOTAL_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;

			l_sub_total := g_quote_header_rec.total_list_price - abs(g_quote_header_rec.total_adjusted_amount);
                  l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(l_sub_total));
			l_document := l_document || lpad(l_temp_str,51,' ')|| ' '|| lpad( l_curr_sym||to_char(to_number(l_can_amt),l_amt_format), 20, ' ')|| NEWLINE;


			fnd_message.set_name('IBE','IBE_PRMT_SHIP_HAND_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
                  l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_quote_header_rec.total_shipping_charge));
			l_document := l_document || lpad(l_temp_str,51,' ')|| ' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt), l_amt_format), 20, ' ')|| NEWLINE;


			fnd_message.set_name('IBE','IBE_PRMT_TAX_EST_COLON');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
                  l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_quote_header_rec.total_tax));
			l_document := l_document || lpad(l_temp_str,51,' ')|| ' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')|| NEWLINE;

			fnd_message.set_name('IBE','IBE_PRMT_SC_TOTAL2');
			l_temp_str := null;
			l_temp_str := fnd_message.get;
                  l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_quote_header_rec.total_quote_price));
			l_document := l_document ||  lpad(l_temp_str,51,' ')|| ' '||  lpad(l_curr_sym|| to_char(to_number(l_can_amt),l_amt_format),20,' ');
                END IF;
		--ELSE
			--null;
		--END IF;
	END LOOP;
	CLOSE c_quote_header;
        end if; -- Recurring charge else loop

       if (l_reccharge = 'Y' OR l_paynow = 'Y') then
            OPEN c_macd_quote_footer(l_quote_id);
            LOOP
            FETCH      c_macd_quote_footer INTO g_macd_quote_rec;
            EXIT WHEN      c_macd_quote_footer%NOTFOUND;

            IF l_view_net_price_flag = 'Y' THEN
                    l_amt_format := FND_CURRENCY.GET_FORMAT_MASK( g_macd_quote_rec.Currency_code,22);
                    For curr_sym_rec In c_curr_symbol(g_macd_quote_rec.Currency_code) Loop
                         l_curr_sym   := trim(curr_sym_rec.symbol);
                     End Loop;
             END IF;
             IF l_view_net_price_flag = 'Y' THEN
             fnd_message.set_name('IBE','IBE_PRMT_SC_PAY_NOW_CHARGES');
             l_temp_str := null;
             l_temp_str := fnd_message.get;
             l_document := l_document || lpad(l_temp_str,51,' ')||NEWLINE;
             l_document := l_document || lpad('-',(51-length(l_temp_str)))||rpad('-',(71-(51-(length(l_temp_str)))),'-')||NEWLINE;

             fnd_message.set_name('IBE','IBE_PRMT_SUBTOTAL_COLON');
             l_temp_str := null;
             l_temp_str := fnd_message.get;
             l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_macd_quote_rec.paynow_lines_total));
             l_document := l_document ||lpad(l_temp_str,51,' ')||' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;

             fnd_message.set_name('IBE','IBE_PRMT_TAX_COL');
             l_temp_str := null;
             l_temp_str := fnd_message.get;
             l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_macd_quote_rec.paynow_taxes_total));
             l_document := l_document || lpad(l_temp_str,51,' ')||' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;

             fnd_message.set_name('IBE','IBE_PRMT_SHIP_HAND_COLON');
             l_temp_str := null;
             l_temp_str := fnd_message.get;
             l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_macd_quote_rec.paynow_charges_total));
             l_document := l_document || lpad(l_temp_str,51,' ')||' '||  lpad(l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),20,' ')||NEWLINE;

             fnd_message.set_name('IBE','IBE_PRMT_SC_PN_TOTAL_COL');
             l_temp_str := null;
             l_temp_str := fnd_message.get;
             l_can_amt := ibe_util.nls_number_format(p_number_in => to_char(g_macd_quote_rec.paynow_order_total));
             l_document := l_document|| lpad(l_temp_str,51,' ')|| ' '|| lpad(l_curr_sym||to_char(to_number(l_can_amt), l_amt_format), 20, ' ');
             END IF;
             END LOOP;
             CLOSE c_macd_quote_footer;
       end if;

	document := l_document;

    IF(display_type = 'text/html') THEN
      document_type := 'text/html';
    ELSE
      document_type := 'text/plain';
    END IF;


	IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   	ibe_util.debug('GenerateQuoteFooter - l_document - '||NEWLINE|| l_document);
	END IF;

	EXCEPTION
		When Others Then
			IF c_quote_header%ISOPEN THEN
				CLOSE c_quote_header;
			END IF;
		Raise;
END GenerateQuoteFooter;

PROCEDURE Selector(
	itemtype		IN	VARCHAR2,
	itemkey		IN	VARCHAR2,
	actid		IN	NUMBER,
	funcmode		IN	VARCHAR2,
	result		OUT NOCOPY	VARCHAR2
) IS

l_event_type		VARCHAR2(50);

BEGIN
	IF ( funcmode = 'RUN' ) THEN
		l_event_type := wf_engine.GetItemAttrText(
			itemtype 	=> itemtype,
			itemkey  	=> itemkey,
			aname   	=> 'EVENTTYPE'
		);

		IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   		ibe_util.debug('Selector - Inside  RUN- '||l_event_type);
		END IF;

		IF l_event_type = 'ACCOUNT_REGISTRATION' THEN
			result := 'COMPLETE:ACCTREG';
		ELSIF l_event_type = 'ORDCONF' THEN
			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Selector - Inside  order confirmation selection ');
			END IF;
			result := 'COMPLETE:ORDCONF';
		ELSIF l_event_type = 'ORDFAX' THEN
			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Selector - Inside  order fax selection ');
			END IF;
			result := 'COMPLETE:ORDFAX';
		ELSIF l_event_type = 'ORDERROR' THEN
			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Selector - Inside  order error selection ');
			END IF;
			result := 'COMPLETE:ORDERROR';
		ELSIF l_event_type = 'ORDCUSTQUOTE' THEN
			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Selector - Inside  order cust quote selection ');
			END IF;
			result := 'COMPLETE:ORDCUSTQUOTE';
		ELSIF l_event_type = 'ORDSALESQUOTE' THEN
			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Selector - Inside  order sales quote selection ');
			END IF;
			result := 'COMPLETE:ORDSALESQUOTE';
		ELSIF l_event_type = 'CUSTASSIST' THEN
			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Selector - Inside  cust assist selection ');
			END IF;
			result := 'COMPLETE:CUSTASSIST';
		ELSIF l_event_type = 'SALESASSIST' THEN
			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Selector - Inside sales assist selection ');
			END IF;
			result := 'COMPLETE:SALESASSIST';
		ELSIF l_event_type = 'TERMAPPROVED' THEN
			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Selector - Inside Term Apporved selection ');
			END IF;
			result := 'COMPLETE:TERMAPPROVED';
		ELSIF l_event_type = 'TERMREJECTED' THEN
			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Selector - Inside Term Rejected selection ');
			END IF;
			result := 'COMPLETE:TERMREJECTED';
		ELSIF l_event_type = 'TERMCANCELLED' THEN
			IF (IBE_UTIL.G_DEBUGON = l_true) THEN
   			ibe_util.debug('Selector - Inside Term Cancelled selection ');
			END IF;
			result := 'COMPLETE:TERMCANCELLED';
		END IF;
	END IF;
	IF ( funcmode = 'CANCEL' ) THEN
		result := 'COMPLETE';
	END IF;
END Selector;

PROCEDURE GetFirstName(
	document_id	IN		VARCHAR2,
	display_type	IN		VARCHAR2,
	document	IN 	OUT NOCOPY	VARCHAR2,
	document_type	IN	OUT NOCOPY	VARCHAR2
) IS

 l_party_id 	number;
 l_first_name  varchar2(150);
 l_order_id    number;

Cursor c_b2b_contact(c_order_id Number) IS
Select p.party_id Person_Party_id,
       l.party_id contact_party_id,
       p.person_first_name,
       p.person_last_name,
       p.party_type
from oe_order_headers_all o,
       hz_cust_Account_roles r,
       hz_relationships l,
       hz_parties p
  where o.header_id        = c_order_id
  and o.sold_to_contact_id = r.cust_account_role_id
  and r.party_id           = l.party_id
  and l.subject_id         = p.party_id
  and l.subject_type       = 'PERSON'
  and l.object_type        = 'ORGANIZATION';

--bug 2299210
Cursor c_b2b_contact_new(pPartyId Number) IS
Select p.person_first_name,
       p.person_last_name,
       p.person_title,
       p.party_type
from hz_relationships l,
       hz_parties p
  where l.party_id   = pPartyId
  and l.subject_id   = p.party_id
  and l.subject_type = 'PERSON'
  and l.object_type  = 'ORGANIZATION';
--bug 2299210

Begin

	FOR c_quote_rec In c_quote_header(to_number(document_id)) LOOP
   		l_party_id := c_quote_rec.party_id;
 		l_order_id := c_quote_rec.order_id;
	END LOOP;

	FOR c_hz_parties_rec IN c_hz_parties(l_party_id) LOOP
		If  c_hz_parties_rec.Party_type = 'PARTY_RELATIONSHIP' Then
 			For c_b2b_contact_rec in c_b2b_contact(l_order_id) Loop
  				l_first_name := upper(rtrim(c_b2b_contact_rec.person_first_name));
 			End Loop;
  		Else
				l_first_name := upper(rtrim(c_hz_parties_rec.person_first_name));
   		End If;
  	END LOOP;

--bug 2299210
     IF l_first_name IS NULL THEN
	  FOR c_hz_parties_rec IN c_hz_parties(l_party_id) LOOP
	    IF c_hz_parties_rec.Party_type = 'PARTY_RELATIONSHIP' THEN
		 FOR c_b2b_contact_rec in c_b2b_contact_new(l_party_id) LOOP
		   l_first_name := upper(rtrim(c_b2b_contact_rec.person_first_name));
           END LOOP;
         END IF;
       END LOOP;
     END IF;

	document := l_first_name;

    IF(display_type = 'text/html') THEN
      document_type := 'text/html';
    ELSE
      document_type := 'text/plain';
    END IF;

End GetFirstName;

PROCEDURE GetLastName(
	document_id    IN        VARCHAR2,
	display_type   IN        VARCHAR2,
	document       IN   OUT NOCOPY  VARCHAR2,
	document_type  IN   OUT NOCOPY  VARCHAR2
) IS

	l_party_id    number;
	l_last_name  varchar2(150);
	l_order_id    number;

Cursor c_b2b_contact(c_Order_id Number) IS
Select p.party_id Person_Party_id,
       l.party_id contact_party_id,
       p.person_first_name,
       p.person_last_name,
       p.party_type
from oe_order_headers_all o,
     hz_cust_Account_roles r,
     hz_relationships l,
     hz_parties p
where o.header_id        = c_Order_id
and o.sold_to_contact_id = r.cust_account_role_id
and r.party_id           = l.party_id
and l.subject_id         = p.party_id
and l.subject_type       = 'PERSON'
and l.object_type        = 'ORGANIZATION';

--bug 2299210
Cursor c_b2b_contact_new(pPartyId Number) IS
Select p.person_first_name,
       p.person_last_name,
       p.person_title,
       p.party_type
from hz_relationships l,
     hz_parties p
where l.party_id     = pPartyId
and   l.subject_id   = p.party_id
and   l.subject_type = 'PERSON'
and   l.object_type  = 'ORGANIZATION';
--bug 2299210

Begin

	FOR c_quote_rec In c_quote_header(to_number(document_id)) LOOP
		l_party_id := c_quote_rec.party_id;
		l_order_id := c_quote_rec.order_id;
	END LOOP;

	FOR c_hz_parties_rec IN c_hz_parties(l_party_id) LOOP
		If  c_hz_parties_rec.Party_type = 'PARTY_RELATIONSHIP' Then
			For c_b2b_contact_rec in c_b2b_contact(l_order_id) Loop
				l_last_name := upper(rtrim(c_b2b_contact_rec.person_last_name));
			End Loop;
		Else
			l_last_name := upper(rtrim(c_hz_parties_rec.person_last_name));
 		End If;
 	END LOOP;

--bug 2299210
     IF l_last_name IS NULL THEN
       FOR c_hz_parties_rec IN c_hz_parties(l_party_id) LOOP
	    IF  c_hz_parties_rec.Party_type = 'PARTY_RELATIONSHIP' THEN
		 FOR c_b2b_contact_rec in c_b2b_contact_new(l_party_id) LOOP
		   l_last_name := upper(rtrim(c_b2b_contact_rec.person_last_name));
           END LOOP;
         END IF;
       END LOOP;
     END IF;

	document := l_last_name;

	IF(display_type = 'text/html') THEN
      document_type := 'text/html';
    ELSE
      document_type := 'text/plain';
    END IF;

End GetLastName;


PROCEDURE GetTitle(
document_id    IN        VARCHAR2,
display_type   IN        VARCHAR2,
document       IN   OUT NOCOPY  VARCHAR2,
document_type  IN   OUT NOCOPY  VARCHAR2
) IS

l_party_id    		number;
l_order_id    		number;
l_person_title  	HZ_PARTIES.PERSON_TITLE%TYPE;

Cursor c_b2b_contact(c_Order_id Number) IS
Select p.party_id Person_Party_id,
       l.party_id contact_party_id,
       p.person_first_name,
       p.person_last_name,
       p.party_type,
       p.person_title
from oe_order_headers_all o,
     hz_cust_Account_roles r,
     hz_relationships l,
     hz_parties p
where o.header_id        = c_order_id
and o.sold_to_contact_id = r.cust_account_role_id
and r.party_id           = l.party_id
and l.subject_id         = p.party_id
and l.subject_type       = 'PERSON'
and l.object_type        = 'ORGANIZATION';

--bug 2299210
Cursor c_b2b_contact_new(pPartyId Number) IS
Select p.person_first_name,
       p.person_last_name,
       p.person_title,
       p.party_type
from hz_relationships l,
     hz_parties p
where l.party_id   = pPartyId
and l.subject_id   = p.party_id
and l.subject_type = 'PERSON'
and l.object_type  = 'ORGANIZATION';
--bug 2299210

Begin

	FOR c_quote_rec In c_quote_header(to_number(document_id)) LOOP
		l_party_id := c_quote_rec.party_id;
		l_order_id := c_quote_rec.order_id;
	END LOOP;

	FOR c_hz_parties_rec IN c_hz_parties(l_party_id) LOOP
		If  c_hz_parties_rec.Party_type = 'PARTY_RELATIONSHIP' Then
			For c_b2b_contact_rec in c_b2b_contact(l_order_id) Loop
				l_person_title := upper(rtrim(c_b2b_contact_rec.person_title));
			End Loop;
		Else
			l_person_title := upper(rtrim(c_hz_parties_rec.person_title));
		End If;
	END LOOP;

--bug 2299210
     IF l_person_title IS NULL THEN
	  FOR c_hz_parties_rec IN c_hz_parties(l_party_id) LOOP
	    IF  c_hz_parties_rec.Party_type = 'PARTY_RELATIONSHIP' THEN
		 FOR c_b2b_contact_rec in c_b2b_contact_new(l_party_id) LOOP
		   l_person_title := upper(rtrim(c_b2b_contact_rec.person_title));
           END LOOP;
         END IF;
       END LOOP;
     END IF;

	document := l_person_title;

	IF(display_type = 'text/html') THEN
      document_type := 'text/html';
    ELSE
      document_type := 'text/plain';
    END IF;

End GetTitle;


PROCEDURE GetContractRef(
	document_id	IN		VARCHAR2,
	display_type	IN		VARCHAR2,
	document		IN OUT NOCOPY	VARCHAR2,
	document_type	IN	OUT NOCOPY	VARCHAR2
) IS

  l_contract_number varchar2(120);
  l_contract_modifier varchar2(120);
  l_contract_ref varchar2(245);
 Begin

   FOR c_contract_rec In c_contract_header(to_number(document_id)) LOOP
      l_contract_number      := c_contract_rec.contract_number;
      l_contract_modifier    := c_contract_rec.contract_number_modifier;
      l_contract_ref 	       := l_contract_number||' '||l_contract_modifier;
   END LOOP;

  document :=  l_contract_ref;

  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;

 End GetContractRef;

PROCEDURE GetCartName(
	document_id	IN		VARCHAR2,
	display_type	IN		VARCHAR2,
	document		IN OUT NOCOPY	VARCHAR2,
	document_type	IN	OUT NOCOPY	VARCHAR2
) IS

 l_cart_name varchar2(50);

 Begin

  FOR c_quote_rec In c_quote_header(to_number(document_id)) LOOP
       l_cart_name := c_quote_rec.quote_name;
  END LOOP;

  document := l_cart_name;

  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;

 End GetCartName;

PROCEDURE get_wf_user (
  p_user_id          IN         NUMBER,
  p_user_source      IN         VARCHAR2 DEFAULT 'HZ_PARTY',
  p_email_address    IN         VARCHAR2,
  p_quote_header_id  IN         NUMBER DEFAULT 1,
  x_adhoc_user       OUT NOCOPY VARCHAR2
) IS

--define local variables here
l_wf_user                    VARCHAR2(320);
l_wf_email                   VARCHAR2(2000);
l_lang_pref                  VARCHAR2(4000);
l_terr_pref                  VARCHAR2(4000);
l_sess_lang                  VARCHAR2(40);
l_sess_terr                  VARCHAR2(40);
l_adhoc_user                 VARCHAR2(4000);
l_adhoc_user_display         VARCHAR2(4000);
l_notification_preference  WF_USERS.NOTIFICATION_PREFERENCE%TYPE;
l_notif_pref               WF_USERS.NOTIFICATION_PREFERENCE%TYPE;
l_email_addr               VARCHAR2(2000);

BEGIN
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_user:Start');
  IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_user:Input user_id: '||p_user_id);
  IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_user:Input user_source: '||p_user_source);
  IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_user:Input email_address: '||p_email_address);
  IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_user:Input quote_header_id: '||p_quote_header_id);
END IF;

IF (p_user_id > 0) THEN
  IF (p_user_source IS NOT NULL AND p_user_source = 'HZ_PARTY') THEN
    l_wf_user := 'HZ_PARTY:'||p_user_id;
  ELSIF (p_user_source IS NOT NULL AND p_user_source = 'PER') THEN
    l_wf_user := 'PER:'||p_user_id;
  ELSE
    l_wf_user := 'HZ_PARTY:'||p_user_id;
  END IF;
  --first get the preferred language for this workflow user
  BEGIN
    SELECT DISTINCT language, territory, notification_preference, email_address
    INTO   l_lang_pref, l_terr_pref, l_notif_pref, l_email_addr
    FROM   wf_users
    WHERE  name = l_wf_user;
  EXCEPTION
    WHEN OTHERS THEN
      --exception while retrieving the language/territory prefs
      --could be because the row does not exist
      --in this case just return the input parameter as the output
      x_adhoc_user := l_wf_user;
  END;

  --first check the profile to determine whether notification messages should be
  --sent in user's preferred language or based on the session language
  IF (1=1) THEN
    --notificiation messages should be sent in the session language
    --check whether the session language/territory is the same as the
    --user's preference
    SELECT DISTINCT value
    INTO   l_sess_lang
    FROM   nls_session_parameters
    WHERE  parameter = 'NLS_LANGUAGE';

    SELECT DISTINCT value
    INTO   l_sess_terr
    FROM   nls_session_parameters
    WHERE  parameter = 'NLS_TERRITORY';

    IF (l_sess_lang <> l_lang_pref) THEN
      --need to create an adhoc user
      l_adhoc_user := substrb(('IBEUE'||FND_GLOBAL.User_ID||to_char(sysdate,'MMDDYYHH24MISS')||p_quote_header_id),1,320);
      l_adhoc_user_display := substrb(('IBEUE'||FND_GLOBAL.User_ID||to_char(sysdate,'MMDDYYHH24MISS')||p_quote_header_id),1,320);

      wf_directory.CreateAdHocUser(
        name                    => l_adhoc_user              ,
        display_name            => l_adhoc_user_display      ,
        language                => l_sess_lang               ,
        territory               => l_sess_terr               ,
        notification_preference => l_notif_pref              ,
        email_address            => l_email_addr              ,
        expiration_date         => sysdate + 1);

      x_adhoc_user := l_adhoc_user;

    ELSE
      --no need to create an adhoc user
      x_adhoc_user := l_wf_user;

    END IF;

  ELSE
    --notification messages should be sent in user's preferred language
    --no need to check anything else
    x_adhoc_user := l_wf_user;

  END IF;

ELSE
  --only e-mail address passed in
  --create an adhoc user with session lang and territory as preference
  l_adhoc_user := substrb(('IBEUE'||FND_GLOBAL.User_ID||to_char(sysdate,'MMDDYYHH24MISS')||p_quote_header_id),1,320);
  l_adhoc_user_display := substrb(('IBEUE'||FND_GLOBAL.User_ID||to_char(sysdate,'MMDDYYHH24MISS')||p_quote_header_id),1,320);

  -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
  -- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
  -- IBE_DEFAULT_USER_EMAIL_STYLE
  l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');

  wf_directory.CreateAdHocUser(
      name                    => l_adhoc_user              ,
      display_name            => l_adhoc_user_display      ,
      language                => l_sess_lang               ,
      territory               => l_sess_terr               ,
      notification_preference => l_notification_preference ,
      email_address            => p_email_address           ,
      expiration_date         => sysdate + 1);

  x_adhoc_user := l_adhoc_user;

END IF;

IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_user:x_adhoc_user = '||x_adhoc_user);
  IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_user:x_adhoc_user:End') ;
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_user:Exception occured');
    END IF;
    RAISE;
END get_wf_user;


PROCEDURE get_wf_role (
  p_wf_users_tbl    IN         JTF_VARCHAR2_TABLE_100,
  p_quote_header_id IN         NUMBER,
  x_wf_role         OUT NOCOPY VARCHAR2
) IS
--any local variables go here
i   binary_integer := 0;
l_wf_role_usrs        VARCHAR2(4000);
l_adhoc_role          VARCHAR2(4000);
l_adhoc_role_display  VARCHAR2(4000);
l_sess_lang  varchar2(40);
l_sess_terr  varchar2(40);
l_notification_preference  WF_USERS.NOTIFICATION_PREFERENCE%TYPE;

BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_role:Start');
  END IF;
  IF (p_wf_users_tbl IS NULL OR p_wf_users_tbl.COUNT <= 0) THEN
    return;
  END IF;

  l_adhoc_role := substrb(('IBER'||FND_GLOBAL.User_ID||to_char(sysdate,'MMDDYYHH24MISS')||p_wf_users_tbl(1)||p_quote_header_id),1,320);
  l_adhoc_role_display := substrb(('IBE'||FND_GLOBAL.User_ID||to_char(sysdate,'MMDDYYHH24MISS')||p_wf_users_tbl(1)||p_quote_header_id),1,320);

  SELECT DISTINCT value
  INTO   l_sess_lang
  FROM   nls_session_parameters
  WHERE  parameter = 'NLS_LANGUAGE';

  SELECT DISTINCT value
  INTO   l_sess_terr
  FROM   nls_session_parameters
  WHERE  parameter = 'NLS_TERRITORY';

  FOR i IN 1..p_wf_users_tbl.COUNT LOOP
    l_wf_role_usrs := l_wf_role_usrs ||','|| p_wf_users_tbl(i);
  END LOOP;
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_role:l_wf_role_usrs='||l_wf_role_usrs);
  END IF;

 -- Email Notifications ER 5917800 - removing the reference of the depreciated profile option
 -- l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_FORMAT',null,null,671), 'MAILTEXT');
 -- IBE_DEFAULT_USER_EMAIL_STYLE
 l_notification_preference := NVL( FND_PROFILE.VALUE_SPECIFIC('IBE_DEFAULT_USER_EMAIL_STYLE',null,null,671), 'MAILTEXT');

  wf_directory.CreateAdHocRole
    (role_name               => l_adhoc_role,
     role_display_name       => l_adhoc_role_display,
     language                => l_sess_lang,
     territory               => l_sess_terr,
     notification_preference => l_notification_preference,
     role_users              => l_wf_role_usrs,
     expiration_date         => sysdate + 1);

  x_wf_role := l_adhoc_role;
IF (IBE_UTIL.G_DEBUGON = l_true) THEN
  IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_role:End');
END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('ibe_workflow_pvt.get_wf_role:Exception occured');
    END IF;
    RAISE;
END get_wf_role;

/* PL/SQL callbacks for translatable tokens */

PROCEDURE get_speciality_store_name(
        document_id     IN  VARCHAR2,
        display_type    IN  VARCHAR2,
        document        IN  OUT NOCOPY VARCHAR2,
        document_type   IN  OUT NOCOPY VARCHAR2 ) is

l_msite_id   NUMBER;
  CURSOR c_msite_name(c_msite_id number) IS
      SELECT msite_name
      FROM ibe_msites_vl
      WHERE msite_id = c_msite_id;
  rec_msite_name  c_msite_name%rowtype;

BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('get_speciality_store_name:Document_id: '||document_id);
  END IF;
  FOR rec_msite_name IN c_msite_name(document_id) LOOP
    document := rec_msite_name.msite_name;
    EXIT when c_msite_name%NOTFOUND;
  END LOOP;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('get_speciality_store_name:Document: '||document);
  END IF;

  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;

END get_speciality_store_name;

PROCEDURE get_fnd_lkpup_value(
        document_id     IN  VARCHAR2,
        display_type    IN  VARCHAR2,
        document        IN  OUT NOCOPY VARCHAR2,
        document_type   IN  OUT NOCOPY VARCHAR2 ) is
cursor c_fnd_lkpup_value(c_fnd_code VARCHAR2) is
  select meaning
  from fnd_lookups
  where lookup_type = 'IBE_QUOTE_UPDATE_PRIVILEGE_WF'
  and lookup_code   = c_fnd_code;

rec_fnd_lkpup_value  c_fnd_lkpup_value%rowtype;
BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('get_fnd_lkpup_value:Document_id: '||document_id);
  END IF;
  FOR rec_fnd_lkpup_value in c_fnd_lkpup_value(document_id) LOOP
    document :=  rec_fnd_lkpup_value.meaning;
    EXIT when c_fnd_lkpup_value%NOTFOUND;
  END LOOP;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('get_fnd_lkpup_value:Document: '||document);
  END IF;

  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;
END ;

PROCEDURE get_FND_message(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY	VARCHAR2
	) is

BEGIN
  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('get_FND_message:START: value of document id ='||document_id);
  END IF;
  FND_MESSAGE.set_name('IBE',document_id);
  document:=FND_MESSAGE.get();

  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;

END get_FND_message;

PROCEDURE get_date(
	document_id     IN  VARCHAR2,
	display_type    IN  VARCHAR2,
	document        IN  OUT NOCOPY VARCHAR2,
	document_type   IN  OUT NOCOPY VARCHAR2
	)   is
BEGIN

  document := to_char(sysdate);

  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;

END;

PROCEDURE get_sales_assist_rsn_meaning(
        document_id     IN  VARCHAR2,
        display_type    IN  VARCHAR2,
        document        IN  OUT NOCOPY VARCHAR2,
        document_type   IN  OUT NOCOPY VARCHAR2 ) is
cursor c_fnd_lookup_value(c_fnd_code VARCHAR2) is
  select meaning
  from aso_lookups  /* Bug 13767382, scnagara - changed from fnd_lookups to aso_lookups*/
  where lookup_type = 'ASO_SALESREP_ASSISTANCE_REASON'
  and lookup_code   = c_fnd_code;

rec_fnd_lkpup_value  c_fnd_lookup_value%rowtype;
BEGIN

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('get_sales_assist_rsn_meaning:Document_id: '||document_id);
  END IF;
  FOR rec_fnd_lookup_value in c_fnd_lookup_value(document_id) LOOP
    document :=  rec_fnd_lookup_value.meaning;
    EXIT when c_fnd_lookup_value%NOTFOUND;
  END LOOP;

  IF (IBE_UTIL.G_DEBUGON = l_true) THEN
    IBE_UTIL.DEBUG('get_sales_assist_rsn_meaning:Document: '||document);
  END IF;

  IF(display_type = 'text/html') THEN
    document_type := 'text/html';
  ELSE
    document_type := 'text/plain';
  END IF;
END get_sales_assist_rsn_meaning;

FUNCTION buildDocument
(
  notif_line_tbl IN Notif_Line_Tbl_Type,
  view_net_price_flag VARCHAR2,
  view_line_type_flag VARCHAR2,
  tax_flag VARCHAR2
) return VARCHAR2
is
   counter Number;
   ldocument          VARCHAR2(32000) := '';
   l_string_in VARCHAR2(495);
   l_string_left VARCHAR2(495);
   l_string_out VARCHAR2(495);
   l_line_num NUMBER := 1;
   l_can_amt NUMBER;
   l_amt_format VARCHAR2(20);
   l_curr_sym   FND_CURRENCIES.SYMBOL%TYPE;
   l_space_len NUMBER := 56;
   l_temp_str VARCHAR2(100);
BEGIN

 l_curr_sym   := g_curr_sym;
 l_amt_format := g_amt_format;
 for counter in 1..notif_line_tbl.count loop
 l_space_len := 56;
 if(view_line_type_flag = fnd_api.g_true) then
   if(Notif_Line_Tbl(counter).Action is not null AND Notif_Line_Tbl(counter).Action <> FND_API.G_MISS_CHAR) then
      ldocument := ldocument || rpad(Notif_Line_Tbl(counter).Action,9,' ')||' ';
   else
      ldocument := ldocument || lpad(' ',9)||' ';
   end if;
 end if;
 l_string_in := Notif_Line_Tbl(counter).Product;
 parseString
   (p_string_in => l_string_in,
    p_string_len => 28,
    p_string_out => l_string_out,
    p_string_left => l_string_left);
  ldocument := ldocument || rpad(l_string_out,28)||' ';
  ldocument := ldocument || lpad(trim(Notif_Line_Tbl(counter).UOM),8)||' ';
  ldocument := ldocument || lpad(trim(Notif_Line_Tbl(counter).Quantity),7)||' ';
  if(view_line_type_flag <> fnd_api.g_true) then
  ldocument := ldocument || lpad(trim(Notif_Line_Tbl(counter).Shippable),9)||' ';
  end if;
  if(view_net_price_flag = 'Y') then
   l_can_amt  := ibe_util.nls_number_format(p_number_in => to_char(Notif_Line_Tbl(counter).NetAmount));
   ldocument := ldocument || lpad(trim(l_curr_sym)||trim(to_char(to_number(l_can_amt),l_amt_format)),16);
  end if;
  ldocument := ldocument ||NEWLINE;
  l_string_in := l_string_left;
  if(length(l_string_in) > 0) THEN
    if(view_line_type_flag = fnd_api.g_true) then
      ldocument := ldocument || rpad(' ',9)||' ';
    end if;
     parseString
	   (p_string_in => l_string_in,
	    p_string_len => 28,
	    p_string_out => l_string_out,
	    p_string_left => l_string_left);
      ldocument := ldocument || rpad(trim(l_string_out),28)||' ';
      if(view_line_type_flag = fnd_api.g_true) then
       l_space_len := l_space_len - 39;
      else
       l_space_len := l_space_len - 29;
      end if;
      if (Notif_Line_Tbl(counter).Periodicity is not null) then
        ldocument := ldocument || lpad(' ',l_space_len) || lpad(trim(Notif_Line_Tbl(counter).Periodicity),16)||NEWLINE;
      else
        ldocument := ldocument ||lpad(' ',l_space_len)||lpad(' ',16)||NEWLINE;
      end if;
  else
      if (Notif_Line_Tbl(counter).Periodicity is not null) then
        ldocument := ldocument || lpad(' ',l_space_len) || lpad(trim(Notif_Line_Tbl(counter).Periodicity),16)||NEWLINE;
      end if;
  END IF;
  l_string_in := l_string_left;
	WHILE  length(l_string_in) > 0  LOOP
			l_string_out := '';
			l_string_left := '';
			parseString(l_string_in,28,l_string_out,l_string_left);
			ldocument := ldocument || rpad(trim(l_string_out),28) ||NEWLINE;
			l_string_in := l_string_left;
	END LOOP;
  IF(tax_flag = fnd_api.g_true) then
     IF view_net_price_flag = 'Y' THEN
       fnd_message.set_name('IBE','IBE_PRMT_ORD_TAX');
       l_temp_str := null;
       l_temp_str := fnd_message.get;
       l_can_amt  := ibe_util.nls_number_format(p_number_in => to_char(Notif_Line_Tbl(counter).TaxAmount));
       ldocument := ldocument ||lpad(l_temp_str||': '||l_curr_sym||to_char(to_number(l_can_amt),l_amt_format),72,' ')||NEWLINE;
     END IF;
  END IF;

 IF (FND_API.To_Boolean(Notif_Line_Tbl(counter).LastItem) and counter <> Notif_Line_Tbl.count) THEN
   ldocument := ldocument || '------------------------------------------------------------------------'||NEWLINE;
 END IF;
 IF (IBE_UTIL.G_DEBUGON = l_true) THEN
      IBE_UTIL.DEBUG('Going to print ldocument in buildDocument'||ldocument);
 END IF;
 end loop;
 return ldocument;
END buildDocument;

PROCEDURE ParseThisString (
	p_string_in	IN	VARCHAR2,
	p_string_len     IN NUMBER := 12,
	p_string_out	OUT NOCOPY	VARCHAR2,
	p_string_left	OUT NOCOPY	VARCHAR2
) IS

l_lengthy_word BOOLEAN;
l_line_length	NUMBER;
l_length		NUMBER;
l_lim		NUMBER;
i		NUMBER;
j		NUMBER;
l_pos		NUMBER;

BEGIN
	l_length := length(p_string_in);
	IF ( l_length < l_line_length ) THEN
		p_string_out := rpad(p_string_in,p_string_len,' ');
		p_string_left := '';
	ELSE
	     p_string_out := substr(p_string_in,1,p_string_len);
  	     p_string_out := rpad(p_string_out,p_string_len,' ');
	     p_string_left := substr(p_string_in,p_string_len+1,length(p_string_in)-p_string_len);
        END IF;
END ParseThisString;

PROCEDURE parseString (
	p_string_in	IN	VARCHAR2,
	p_string_len     IN NUMBER := 12,
	p_string_out	OUT NOCOPY	VARCHAR2,
	p_string_left	OUT NOCOPY	VARCHAR2
) IS

l_lengthy_word BOOLEAN;
l_length		NUMBER;
l_lim		NUMBER;
i		NUMBER;
j		NUMBER;
l_pos		NUMBER;

BEGIN
	l_length := length(p_string_in);
	IF ( l_length <= p_string_len ) THEN
		p_string_out := rpad(p_string_in,p_string_len,' ');
		p_string_left := '';
	ELSE
	     p_string_out := substr(p_string_in,1,p_string_len);
  	     p_string_out := rpad(p_string_out,p_string_len,' ');
	     p_string_left := substr(p_string_in,p_string_len+1,length(p_string_in)-p_string_len);
   END IF;
END parseString;

END ibe_workflow_pvt;

/
