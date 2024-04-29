--------------------------------------------------------
--  DDL for Package Body ARI_CONFIG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARI_CONFIG" AS
/* $Header: ARICNFGB.pls 120.21.12010000.5 2008/11/10 11:51:51 avepati ship $ */

-- generates raw html code used by the homepage for the configurable section : the second column : when customer_id, user_id, or site_use_id are not available, the procedure should be passed -1.
-- If p_site_use_id = -1, then user has Customer level access. In all your custom queries, you need to set site ID to NULL
-- Please note the customerId and customerSiteUseId has been enforced to be encrypted in all URLs
-- If there are any customized links in this customized area in which p_customer_id or p_site_use_id is there in URL
-- THE LINK WILL STOP WORKING
-- For all links to any iReceivables pages in the URL use p_encrypted_customer_id and p_encrypted_site_use_id
-- The p_customer_id and p_site_use_id contains the same id in plain text to be used for select query or any other purpose.

PROCEDURE  get_homepage_customization(
		p_user_id       IN NUMBER,
		p_customer_id   IN NUMBER,
                p_site_use_id   IN NUMBER,
                p_encrypted_customer_id	IN VARCHAR2,
		p_encrypted_site_use_id	IN VARCHAR2,
		p_language      IN VARCHAR2,
                p_output_string OUT NOCOPY VARCHAR2) IS
BEGIN
   p_output_string := '                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td>
                          <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tr>
                              <td class="OraHeader">';

    p_output_string := p_output_string || fnd_message.get_string('AR', 'ARI_HOMEPAGE_CUST_NEWS');

    p_output_string := p_output_string || '</td>
                            </tr>
                            <tr>
                              <td class="OraBGAccentDark"></td>
                            </tr>
                          </table>
                        </td>
                      </tr>
                      <tr>
                        <td height="10"></td>
                      </tr>
                      <tr>
                        <td>
                          <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tr>
                              <td><ul>';

    p_output_string := p_output_string || fnd_message.get_string('AR', 'ARI_HOMEPAGE_CUST_NEWS_BODY');

    p_output_string := p_output_string || '</ul></td>
                            </tr>
                          </table>
                        </td>
                      </tr>
                    </table><br>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td>
                          <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tr>
                              <td class="OraHeader">';


    p_output_string := p_output_string || fnd_message.get_string('AR', 'ARI_HOMEPAGE_CUST_FAQS');

    p_output_string := p_output_string || '</td>
                            </tr>
                            <tr>
                              <td class="OraBGAccentDark"></td>
                            </tr>
                          </table>
                        </td>
                      </tr>
                      <tr>
                        <td height="10"></td>
                      </tr>
                      <tr>
                        <td>
                          <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tr>
                              <td><ul>';

    p_output_string := p_output_string || fnd_message.get_string('AR', 'ARI_HOMEPAGE_CUST_FAQS_BODY');

    p_output_string := p_output_string || '</td>
                            </tr>
                          </table>
                        </td>
                      </tr>
                    </table><br>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td>
                          <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tr>
                              <td class="OraHeader">';

    p_output_string := p_output_string || fnd_message.get_string('AR', 'ARI_HOMEPAGE_CUST_POLICY');

    p_output_string := p_output_string || '</td>
                            </tr>
                            <tr>
                              <td class="OraBGAccentDark"></td>
                            </tr>
                          </table>
                        </td>
                      </tr>
                      <tr>
                        <td height="10"></td>
                      </tr>
                      <tr>
                        <td>
                          <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tr>
                              <td><ul>';

    p_output_string := p_output_string || fnd_message.get_string('AR', 'ARI_HOMEPAGE_CUST_POLICY_BODY');

    p_output_string := p_output_string || '</td>
                            </tr>
                          </table>
                        </td>
                      </tr>
                    </table><br>
                    <table border="0" cellpadding="0" cellspacing="0" width="100%">
                      <tr>
                        <td>
                          <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tr>
                              <td class="OraHeader">';

    p_output_string := p_output_string || fnd_message.get_string('AR', 'ARI_HOMEPAGE_CUST_RESRC');

    p_output_string := p_output_string || '</td>
                            </tr>
                            <tr>
                              <td class="OraBGAccentDark"></td>
                            </tr>
                          </table>
                        </td>
                      </tr>
                      <tr>
                        <td height="10"></td>
                      </tr>
                      <tr>
                        <td>
                          <table border="0" cellpadding="0" cellspacing="0" width="100%">
                            <tr>
                              <td><ul>';

    p_output_string := p_output_string || fnd_message.get_string('AR', 'ARI_HOMEPAGE_CUST_RESRC_BODY');

    p_output_string := p_output_string || '</ul></td>
                            </tr>
                          </table>
                        </td>
                      </tr>
                    </table>
';

END;



-- this procedure outputs the number of rows that the default
-- account details page view should show in the results region.
PROCEDURE Restrict_By_Rows (
        x_output_number OUT NOCOPY     NUMBER,
        x_customer_id   IN      VARCHAR2,
        x_customer_site_use_id  IN      VARCHAR2,
        x_language_string       IN      VARCHAR2
)
IS
BEGIN
    x_output_number := 10;
END Restrict_By_Rows;


PROCEDURE  get_discount_customization(
		p_customer_id   IN NUMBER,
                p_site_use_id   IN NUMBER,
                p_language      IN VARCHAR2,
                p_render        OUT NOCOPY VARCHAR2,
                p_output_string OUT NOCOPY VARCHAR2) IS
BEGIN

  p_output_string := 'Put your customized discount information here.';
  p_render        := 'Y';

END get_discount_customization;


PROCEDURE  get_dispute_customization(
		p_customer_id   IN NUMBER,
                p_site_use_id   IN NUMBER,
                p_language      IN VARCHAR2,
                p_render        OUT NOCOPY VARCHAR2,
                p_output_string OUT NOCOPY VARCHAR2) IS
BEGIN

  p_output_string := 'Put your customized dispute information here.';
  p_render        := 'Y';

END get_dispute_customization;




-- CUSTOM TRANSACTION SEARCH
-- This procedure need to be modified by deploying company to write
-- the query for the customized search
-- The customer MUST select all columns in  AR_IREC_CUSTOM_SRCH_GT
-- Table , except columns Attribute1 to Attribute5 which are optional
--
-- The input parameter to the procedure are :-
--  p_customer_id		Customer ID
--  p_customer_site_id		Customer Site Use ID
--  p_person_id			Person ID
--  p_transaction_status	Transaction Status value in pop list
--  p_transaction_type 		Transaction Type value in pop list
--  p_currency			Active Currency type
--  p_keyword			Search Keyword , NULL if user not entered
--  p_amount_from		Amount From in Advance search , NULL if not entered
--  p_amount_to			Amount To in Advance search , NULL if user not entered
--  p_trans_date_from		Transaction Date From in Advance search (DD-MON-YYYY )
--				NULL if user not entered
--  p_trans_date_to		Transaction Date To in Advance Search (DD-MON-YYYY )
--				NULL if user not entered
--  p_due_date_from		Due Date From in Advance search , NULL if user not entered
--  p_due_date_to		Due Date To in Advance search , NULL if user not entered

-- The users need to return the column heading for all columns which has
-- to be displayed in the custom search
-- and to return NULL for the columns which needs not to be displayed
--
--  PARAMETER      Corresponding  Field in Table    Default Column Heading
--	          ( AR_IREC_CUSTOM_SRCH_GT)
--  p_transaction_col	TRX_NUMBER 		"Transactions"
--  p_type_col		CLASS			"Type"
--  p_status_col	STATUS			 "Status"
--  p_date_col		TRX_DATE		 "Date"
--  p_due_date_col	DUE_DATE		 "Due Date"
--  p_purchase_order_col     - - - 		 "Purchase Order"
--  p_sales_order_col	     - - -  		 "Sales Order / Project"
--  p_original_amt_col	AMOUNT_DUE_ORIGINAL	 "Original Amount"
--  p_remaining_amt_col	AMOUNT_DUE_REMAINING	 "Remaining Amount"
--  p_attribute1_col	ATTRIBUTE1		   NULL  ( not displayed )
--  p_attribute2_col	ATTRIBUTE2		   NULL  ( not displayed )
--  p_attribute3_col	ATTRIBUTE3		   NULL  ( not displayed )
--  p_attribute4_col	ATTRIBUTE4		   NULL  ( not displayed )
--  p_attribute5_col	ATTRIBUTE5		   NULL  ( not displayed )
--
--  The users need to do all validation checks , depending on the custom
--  search attribute , in case of any error
--
--  set the value of p_search_result to 'ERROR'
--
--  set the value of p_message_id to the Error message Id which is to be thrown in
--  case of the error
--
--  set the value of p_msg_app_id to the application id of error message. If no
--  application id is specified default is taken as 'AR'
--
-- For more Reference please refer to "iReceivables Custom Transaction Search"
-- White paper available on MetaLink
--
PROCEDURE search_custom_trx (
		p_session_id            IN      VARCHAR2,
		p_customer_id 		IN	VARCHAR2,
		p_customer_site_id	IN	VARCHAR2,
		p_org_id                 	IN   	 VARCHAR2,
		p_person_id		IN	VARCHAR2,
		p_transaction_status	IN	VARCHAR2,
		p_transaction_type	IN	VARCHAR2,
		p_currency		IN	VARCHAR2,
		p_keyword		IN	VARCHAR2,
		p_amount_from		IN	VARCHAR2,
		p_amount_to		IN	VARCHAR2,
		p_trans_date_from	IN	VARCHAR2,
		p_trans_date_to		IN	VARCHAR2,
		p_due_date_from		IN	VARCHAR2,
		p_due_date_to		IN	VARCHAR2,
		p_org_name             	 OUT  NOCOPY     VARCHAR2,
		p_transaction_col	OUT  NOCOPY	VARCHAR2,
		p_type_col		OUT  NOCOPY	VARCHAR2,
		p_status_col		OUT  NOCOPY	VARCHAR2,
		p_date_col		OUT  NOCOPY	VARCHAR2,
		p_due_date_col		OUT  NOCOPY	VARCHAR2,
		p_purchase_order_col	OUT  NOCOPY	VARCHAR2,
		p_sales_order_col	OUT  NOCOPY	VARCHAR2,
		p_original_amt_col	OUT  NOCOPY	VARCHAR2,
		p_remaining_amt_col	OUT  NOCOPY	VARCHAR2,
		p_attribute1_col	OUT  NOCOPY	VARCHAR2,
		p_attribute2_col	OUT  NOCOPY	VARCHAR2,
		p_attribute3_col	OUT  NOCOPY	VARCHAR2,
		p_attribute4_col	OUT  NOCOPY	VARCHAR2,
		p_attribute5_col	OUT  NOCOPY	VARCHAR2,
		p_search_result		OUT  NOCOPY	VARCHAR2,
		p_message_id		OUT  NOCOPY	VARCHAR2,
		p_msg_app_id		OUT  NOCOPY	VARCHAR2
				) IS

BEGIN

p_transaction_col := 'Transaction' ;
p_type_col := 'Type' ;
p_status_col := 'Status' ;
p_date_col := 'Date' ;
p_due_date_col := 'Due Date' ;
p_purchase_order_col := 'Purchase Order';
p_sales_order_col := 'Sales Order /Project' ;
p_original_amt_col := 'Original Amount ' ;
p_remaining_amt_col := 'Remaining Amount ' ;
p_attribute1_col := NULL ;
p_attribute2_col := NULL ;
p_attribute3_col := NULL ;
p_attribute4_col := NULL ;
p_attribute5_col := NULL ;
p_msg_app_id := 'AR' ;

END search_custom_trx ;




-- CUSTOM CUSTOMER SEARCH
-- This procedure need to be modified by deploying company to write
-- the query for the customized customer search

-- The following columns MUST be inserted in table AR_IREC_CUSTOM_CUST_GT for all rows
--
-- CUSTOMER_ID
-- ADDRESS_ID

-- The following columns are not mandatory but are advised to be inserted in table
-- AR_IREC_CUSTOM_CUST_GT for all rows
--
-- CUSTOMER_NUMBER
-- CUSTOMER_NAME
-- CONCATENATED_ADDRESS
-- LOCATION
--
-- The link for customer account level ( all locations ) could be created by putting
-- the address_id as -1 ( minus one )
-- The address ( concatenated_address ) displayed for account level link is 'All Locations'.
-- Any value for column CONCATENATED_ADDRESS if entered is ignored for the row
-- with ADDRESS_ID as -1 and 'All Locations' text is shown for address column.
-- For All Locations, set LOCATION to null

-- The following columns MUST be inserted in table AR_IREC_CUSTOM_CUST_GT if
-- the TRANSACTION NUMBER column is displayed and transaction is of type
-- Invoice , Debit Memo , Charge Back , Deposit or Guarantee ( Class as INV , DM , CB ,
-- DEP , or GAUR respectively )
--
-- TRX_NUMBER
-- CUSTOMER_TRX_ID
-- CASH_RECEIPT_ID
-- TERMS_SEQUENCE_NUMBER
-- CLASS ( e.g. INV , DM , CB , DEP or GAUR )


-- The following columns MUST be inserted in table AR_IREC_CUSTOM_CUST_GT if
-- the TRANSACTION NUMBER column is displayed and transaction is of type
-- Payment ( Class as PMT )
--
-- TRX_NUMBER
-- CASH_RECEIPT_ID
-- CLASS ( as PMT )

-- The following columns MUST be inserted in table AR_IREC_CUSTOM_CUST_GT if
-- the TRANSACTION NUMBER column is displayed and transaction is of type
-- Credit Memo ( Class as CM )
--
-- TRX_NUMBER
-- CUSTOMER_TRX_ID
-- TERMS_SEQUENCE_NUMBER
-- CLASS ( as CM )
--
-- The following columns MUST be inserted in table AR_IREC_CUSTOM_CUST_GT if
-- the TRANSACTION NUMBER column is displayed and transaction is of type
-- Credit Request ( CLASS as REQ)
--
-- TRX_NUMBER
-- CUSTOMER_TRX_ID
-- INVOICE_CURRENCY_CODE
-- REQUEST_ID
-- REQUEST_URL ( column URL in view ra_cm_requests )
-- CLASS ( as REQ )
--
--
-- columns Attribute1 to Attribute5 which are optional for all search types
--
--
-- The input parameter to the procedure are :-
--  p_user_id			User Name
--  p_is_external_user      Responsibility type , in case of External user value is 'Y'
--			    and in case of internal user the value is 'N'
--  p_search_attribute      lookup code for custom search attribute
--  p_search_keyword        Search keyword , null in case user has not entered anything
--  p_org_id                OrgId of the user
--
-- The users need to return the column heading for all columns which has
-- to be displayed in the custom search
-- and to return NULL for the columns which needs not to be displayed
--
--  PARAMETER      Corresponding  Field in Table   Suggested Column Heading
--	          ( AR_IREC_CUSTOM_CUST_GT)
--  p_org_name		  Organization		        "Organization"
--  p_trx_number_col      TRX_NUMBER			"Transaction Number"
--  p_customer_name_col   CUSTOMER_NAME			"Customer Name"
--  p_customer_number_col CUSTOMER_NUMBER		"Customer Number"
--  p_address_col         CONCATENATED_ADDRESS		"Address"
--  p_address_type_col Transient (based on Customer_id 	"Address Type"
--			 and Addrress_id )
--  p_contact_name_col      - do -			"Contact Name"
--  p_contact_phone_col     - do -			"Contact Phone"
--  p_account_summary_col   - do -			"Account Summary"
--  p_attribute1_col	  ATTRIBUTE1		   NULL  ( not displayed )
--  p_attribute2_col	  ATTRIBUTE2		   NULL  ( not displayed )
--  p_attribute3_col	  ATTRIBUTE3		   NULL  ( not displayed )
--  p_attribute4_col	  ATTRIBUTE4		   NULL  ( not displayed )
--  p_attribute5_col	  ATTRIBUTE5		   NULL  ( not displayed )
--  p_customer_location_col   LOCATION			"Customer Location"
--
--  ERROR DISPLAY
--
--  The users need to do all validation checks , depending on the context of custom
--  search attribute.
--  In case of any error set the value of p_search_result to FND_API.G_RET_STS_ERROR
--  In case of success search set the value of p_search_result to FND_API.G_RET_STS_SUCCESS
--
--  set the value of p_message_id to the Error message Id which is to be thrown in
--  case of the error
--
--  set the value of p_msg_app_id to the application id of error message. If no
--  application id is specified default is taken as 'AR'
--
-- For more Reference please refer to "iReceivables Custom Customer Search"
-- White paper available on MetaLink
--
PROCEDURE search_custom_customer(
                p_user_name             IN      VARCHAR2,
                p_is_external_user      IN      VARCHAR2,
                p_search_attribute      IN      VARCHAR2,
                p_search_keyword        IN      VARCHAR2,
                p_org_id                IN      NUMBER,
                p_org_name		OUT  NOCOPY     VARCHAR2,
                p_trx_number_col        OUT  NOCOPY     VARCHAR2,
                p_customer_name_col     OUT  NOCOPY     VARCHAR2,
                p_customer_number_col   OUT  NOCOPY     VARCHAR2,
                p_address_col           OUT  NOCOPY     VARCHAR2,
                p_address_type_col      OUT  NOCOPY     VARCHAR2,
                p_contact_name_col      OUT  NOCOPY     VARCHAR2,
                p_contact_phone_col     OUT  NOCOPY     VARCHAR2,
                p_account_summary_col   OUT  NOCOPY     VARCHAR2,
                p_attribute1_col        OUT  NOCOPY     VARCHAR2,
                p_attribute2_col        OUT  NOCOPY     VARCHAR2,
                p_attribute3_col        OUT  NOCOPY     VARCHAR2,
                p_attribute4_col        OUT  NOCOPY     VARCHAR2,
                p_attribute5_col        OUT  NOCOPY     VARCHAR2,
                p_search_result         OUT  NOCOPY     VARCHAR2,
                p_message_id            OUT  NOCOPY     VARCHAR2,
                p_msg_app_id            OUT  NOCOPY     VARCHAR2,
                p_customer_location_col OUT  NOCOPY     VARCHAR2
                                ) IS

BEGIN

 p_org_name       := 'Organization';
 p_trx_number_col := NULL ;
 p_customer_name_col := 'Customer Name' ;
 p_customer_number_col := 'Customer Number' ;
 p_customer_location_col := 'Customer Location';
 p_address_col := 'Address' ;
 p_address_type_col := 'Address Type' ;
 p_contact_name_col := 'Contact Name' ;
 p_contact_phone_col := 'Contact Phone' ;
 p_account_summary_col := 'Account Summary' ;
 p_attribute1_col := NULL ;
 p_attribute2_col := NULL ;
 p_attribute3_col := NULL ;
 p_attribute4_col := NULL ;
 p_attribute5_col := NULL ;
 p_search_result := NULL ;
 p_message_id := NULL ;
 p_msg_app_id := NULL ;


END search_custom_customer ;


END ari_config;

/
