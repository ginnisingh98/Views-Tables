--------------------------------------------------------
--  DDL for Package CSC_ROUTING_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSC_ROUTING_UTL" AUTHID CURRENT_USER AS
/* $Header: cscotmrs.pls 120.2 2006/06/15 21:09:09 hbchung ship $ */

------------------------------------------------------------------------------
--  Procedure:   decode_ani
--  Usage:    used by the Routing module to decode the string passed in the
--            IVT values to the constituent telephone number pieces required
--            by the get_customerid_from_ANI function.
--  Parameters:  NI code received
--  Return:  4 substrings
--
------------------------------------------------------------------------------
PROCEDURE decode_ANI (
		    p_ANI_CODE          IN         VARCHAR2,
		    p_country_code      OUT NOCOPY VARCHAR2,
		    p_area_code         OUT NOCOPY VARCHAR2,
		    p_phone_num         OUT NOCOPY VARCHAR2,
		    p_phone_ext         OUT NOCOPY VARCHAR2);

--
------------------------------------------------------------------------------
--  Function	: Get_Customer_From_Account_Num
--  Usage	: Used by the Routing module to get the customer ID from the
--		  customer account number
--  Description	: This function retrieves the primary party id associated
--		  with the specified customer account number.
--  Parameters	:
--	p_customer_account_number	IN	VARCHAR2(30)	Required
--
--  Return	: NUMBER
--		  If the given customer does not exist, this function returns
--		  NULL.
------------------------------------------------------------------------------

FUNCTION Get_Customer_From_Account_Num
( p_cust_acct_number IN VARCHAR2)
Return NUMBER;


------------------------------------------------------------------------------
--  Function	: Get_Customer_From_Contract_Num
--  Usage	: Used by the Routing module to get the customer ID from the
--		  contract number.
--  Description	: This function retrieves a party ID from
--		  OKC_ given a contract number. If there
--		  is more than one customer associated with the given
--		  contract, this function will return the first party ID
--		  that it retrieves.
--  Parameters	:
--	p_contract_number	IN	VARCHAR2(30)	Required
--
--  Return	: NUMBER
--		  If there is no party associated with the given contract,
--		  or the contract does not exist, this function returns NULL.
------------------------------------------------------------------------------
FUNCTION Get_Customer_From_Contract_Num (p_contract_number IN VARCHAR2)
	Return Number;


------------------------------------------------------------------------------
--  Function	: Get_Customer_From_Site_Num
--  Usage	: Used by the Routing module to get the customer ID from the
--		  party site number.
--  Description	: This function retrieves a party ID from
--		  HZ_PARTY_SITES given a site number.
--  Parameters	:
--	p_site_number	IN	VARCHAR2(30)	Required
--
--  Return	: NUMBER
--		  If there is no party associated with the given site number,
--		  this function returns NULL.
------------------------------------------------------------------------------
FUNCTION Get_Customer_From_Site_Num (p_site_number IN VARCHAR2)
	Return Number;


------------------------------------------------------------------------------
--  Function	: Get_Customer_From_Repair_Num
--  Usage	: Used by the Routing module to get the customer ID from the
--		  repair number.
--  Description	: This function retrieves a party ID from
--		  CSD_REPAIRS_V given a repair number. If there
--  Parameters	:
--	p_repair_number	IN	VARCHAR2(30)	Required
--
--  Return	: NUMBER
--		  If there is no party associated with the given repair,
--		  or the repair does not exist, this function returns NULL.
------------------------------------------------------------------------------
FUNCTION Get_Customer_From_Repair_Num (P_Repair_Number IN VARCHAR2)
Return Number;


------------------------------------------------------------------------------
--  Function	: Get_Customer_From_Defect_Num
--  Usage	: Used by the Routing module to get the customer ID from the
--		  defect number.
--  Description	: This function retrieves a party ID from
--		  CSS_DEF_DEFECTS_ALL_V given a defect number.
--  Parameters	:
--	p_defect_number	IN	VARCHAR2(30)	Required
--
--  Return	: NUMBER
--		  If there is no party associated with the given defect,
--		  or the defect does not exist, this function returns NULL.
------------------------------------------------------------------------------
FUNCTION Get_Customer_From_Defect_Num(p_defect_number IN VARCHAR2)
	Return Number;

------------------------------------------------------------------------------
--  Function	: Get_Customer_From_ANI
--  Usage	: Used by the Routing module to get the party ID from the
--		  contact's phone number
--  Description	: This function retrieves a party ID from the
--		  HZ_CONTACT_POINTS table given a phone number of a customer contact.
--		  If there is more than one customer associated with the given phone
--		  number, this function will return the first customer ID that
--		  it retrieves.
--  Parameters	:
--	p_area_code		IN	VARCHAR2(10)	Optional
--	p_phone_number		IN	VARCHAR2(40)	Required
--	p_extension		IN	VARCHAR2(20)	Optional
--	p_country_code		IN	VARCHAR2(20)	Optional
--
--  Return	: NUMBER
--		  If there is no customer associated with the given phone
--		  number, or the phone number does not exist (in the system),
--		  this function returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_Customer_From_ANI
( p_country_code	IN	VARCHAR2	:= NULL,
  p_area_code		IN	VARCHAR2 := NULL,
  p_phone_number	IN	VARCHAR2,
  p_extension		IN	VARCHAR2 := NULL)
Return Number;


------------------------------------------------------------------------------
--  Function	: Get_Customer_From_CustomerNum
--  Usage	: Used by the Routing module to get the customer ID from the
--		  customer number
--  Description	: This function retrieves a party ID from the
--		  HZ_PARTIES table given a party number. If there is more than one
--		  party with the given number, this function will return the
--		  first party ID that it retrieves.
--  Parameters	:
--	p_party_number	IN	VARCHAR2(30)	Required
--
--  Return	: NUMBER
--		  If the given customer does not exist, this function returns
--		  NULL.
------------------------------------------------------------------------------

FUNCTION Get_Customer_From_CustomerNum (p_party_number IN VARCHAR2)
	Return Number;


------------------------------------------------------------------------------
--  Function	: Get_Customer_From_InvoiceNum
--  Usage	: Used by the Routing module to get the customer ID from the
--		  sales invoice number.
--  Description	: This function retrieves a customer ID from the
--		  RA_CUSTOMER_TRX_ALL table given an invoice number. If there
--		  are more than one customer associated with the given
--		  invoice, this function will return the first customer ID
--		  that it retrieves.
--  Parameters	:
--	p_invoice_number	IN	VARCHAR2(20)	Required
--
--  Return	: NUMBER
--		  If there is no customer associated with the given invoice,
--		  or the invoice does not exist, this function returns NULL.
------------------------------------------------------------------------------
FUNCTION Get_Customer_From_InvoiceNum(P_Invoice_Number IN VARCHAR2)
	Return Number;


------------------------------------------------------------------------------
--  Function	: Get_Name_Of_Customer
--  Usage	: Used by the Routing module to get the customer name from the
--		  customer ID
--  Description	: This function retrieves the customer name from the
--		  HZ_PARTIES table given a customer ID.
--  Parameters	:
--	p_party_id		IN	NUMBER		Required
--
--  Return	: VARCHAR2(255)
--		  If there is no customer with the given party ID, this
--		  function returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_Name_Of_Customer(p_party_id IN NUMBER) Return VARCHAR2;


------------------------------------------------------------------------------
--  Function	: Get_Status_Of_Customer
--  Usage	: Used by the Routing module to get the customer status
--  Description	: This function retrieves the customer status flag from the
--		  HZ_PARTIES table given a party ID.
--  Parameters	:
--	p_party_id		IN	NUMBER		Required
--
--  Return	: VARCHAR2(1)
--		  If there is no customer with the given customer ID, this
--		  function returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_Status_Of_Customer(p_party_id IN NUMBER) Return VARCHAR2;


------------------------------------------------------------------------------
--  Function	: Is_CP_Existent
--  Usage	: Used by the Routing module to determine whether a customer
--		  product exists in the installed base with the given ID
--  Description	: This function finds a row in the CS_CUSTOMER_PRODUCTS_ALL
--		  table that matches the given customer product ID.
--  Parameters	:
--	p_customer_product_id	IN	NUMBER		Required
--
--  Return	: BOOLEAN
--		  If there is a row that matches the given ID, this function
--		  returns TRUE. Else it returns FALSE.
------------------------------------------------------------------------------

FUNCTION Is_CP_Existent(p_customer_product_id IN NUMBER) Return BOOLEAN;


------------------------------------------------------------------------------
--  Function	: Customer_ID_Exists
--  Usage	: Used by the Routing module to determine whether a customer
--		  exists with the given ID
--  Description	: This function finds a row in the HZ_PARTIES
--		  table that matches the given customer ID.
--  Parameters	:
--	p_customer_id	IN	NUMBER		Required
--
--  Return	: BOOLEAN
--		  If there is a row that matches the given ID, this function
--		  returns TRUE. Else it returns FALSE.
------------------------------------------------------------------------------

FUNCTION Customer_ID_Exists(p_customer_id IN NUMBER) Return BOOLEAN;


------------------------------------------------------------------------------
--  Function	: Get_CP_From_ReferenceNum
--  Usage	: Used by the Routing module to get the customer product ID
--		  from the reference number
--  Description	: This function retrieves a customer product ID from the
--		  CS_CUSTOMER_PRODUCT_ALL table given a reference number.
--  Parameters	:
--	p_reference_number	IN	NUMBER		Required
--
--  Return	: NUMBER
--		  If the given reference number does not exist, this function
--		  returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_CP_From_ReferenceNum(p_reference_number IN NUMBER)
	Return NUMBER;


------------------------------------------------------------------------------
--  Function	: Get_Product_From_ReferenceNum
--  Usage	: Used by the Routing module to get the inventory item ID
--		  from the reference number
--  Description	: This function retrieves an inventory item ID from the
--		  CS_CUSTOMER_PRODUCT_ALL table given a reference number.
--  Parameters	:
--	p_reference_number	IN	NUMBER		Required
--
--  Return	: NUMBER
--		  If the given reference number does not exist, this function
--		  returns NULL.
------------------------------------------------------------------------------
FUNCTION Get_Product_From_ReferenceNum(p_reference_number IN NUMBER)
	Return NUMBER;

------------------------------------------------------------------------------
--  Function	: Get_Name_Of_Product
--  Usage	: Used by the Routing module to get the product name from the
--		  inventory item ID
--  Description	: This function retrieves the product name from the
--		  MTL_SYSTEM_ITEMS table given an inventory item ID and an
--		  organization ID. The inventory organization ID is required
--		  because the same item can be defined in more than one
--		  organization.
--  Parameters	:
--	p_inventory_item_id	IN	NUMBER		Required
--	p_inventory_org_id	IN	NUMBER		Required
--
--  Return	: VARCHAR2(240)
--		  If there is no product with the given inventory item ID,
--		  this function returns NULL.
------------------------------------------------------------------------------
FUNCTION Get_Name_Of_Product
 (p_inventory_item_id	IN	NUMBER,
  p_inventory_org_id	IN	NUMBER)
Return VARCHAR2;

------------------------------------------------------------------------------
--  Function	: Get_Customer_From_Email
--  Usage	: Used to get the party ID from the sender's email address (email
--		  integration)
--  Description	: This function retrieves a party ID from the
--		  JTF_CONTACT_POINTS_V given a email address.
--		  If there is more than one customer associated with the given email
--		  address, this function will return the first customer ID that
--		  it retrieves.
--  Parameters	:
--	p_email_address	IN	VARCHAR2(2000)	Required
--
--  Return	: NUMBER
--		  If there is no customer associated with the given email
--		  address, or the email address does not exist (in the system),
--		  this function returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_Customer_From_Email
( p_email_address	IN	VARCHAR2)
Return Number;


------------------------------------------------------------------------------
--  Function	: Get_Customer_From_ContactNum
--  Usage	: Used to get the party ID from the Contact Number passed in the IVR parms
--  Description	: This function retrieves a party ID from the
--		  HZ_PARTIES table by traversing the relationships from HZ_ORG_CONTACTS
--          and HZ_PARTY_RELATIONSHIPS.
--		  If there is more than one party_id associated with the given ContactNum
--		  this function will return the first party_id that it retrieves.
--  Parameters	:
--	p_contact_number  IN	VARCHAR2(1996)	Required
--
--  Return	: NUMBER
--		  If there is no party_id associated with the given ContactNum
--		  this function returns NULL.
------------------------------------------------------------------------------

FUNCTION Get_Customer_From_ContactNum
( p_contact_number  IN	VARCHAR2)
Return Number;

------------------------------------------------------------------------------
--  Function	: reverse_number
--  Usage	: Used to get reverse number for the number passed to function
--  Description	: This function is built to reverse the number passed to it.
--		  This function can be used instead of the standard REVERSE
--		  function because the REVERSE fucntion cannot be used in PL/
--  Parameters	:
--	p_phone_number  IN	VARCHAR2(1996)	Required
--
--  Return	: VARCHAR2
-----------------------------------------------------------------------------
FUNCTION reverse_number(p_phone_number VARCHAR2)
RETURN VARCHAR2;

------------------------------------------------------------------------------
--  Function	: Get_Customer_From_Reverse_ANI
--  Usage	: Used to get the party ID from the reversed ANI Number passed in the IVR parms
--  Description	: This function retrieves a owner_table_id from the
--		  HZ_CONTACT_POINTS
--		  If there is more than one party_id associated with the given ContactNum
--		  this function will return the first party_id that it retrieves.
--  Parameters	:
--	p_rANI  IN	VARCHAR2(1996)	Required
--
--  Return	: NUMBER
--		  If there is no party_id associated with the given ContactNum
--		  this function returns NULL.
------------------------------------------------------------------------------

FUNCTION get_customer_from_reverse_ANI
( p_rANI  IN	VARCHAR2,
  x_uwq_multi_record_match OUT NOCOPY VARCHAR2,
  x_phone_id OUT NOCOPY NUMBER )
RETURN NUMBER;

--
------------------------------------------------------------------------------
--  Procedure	: Get_Cust_Acct_From_Account_Num
--  Usage	: Used to get Party_id,Cust_account_id,last_update_date from
--		  hz_cust_accounts
--  Parameters	:
--	p_customer_account_number	IN	         VARCHAR2(30)	Required
--	x_party_id			OUT	 NOCOPY  NUMBER(15)
--	x_cust_account_id		OUT	 NOCOPY  NUMBER(15)
--	x_last_update_date		OUT	 NOCOPY  DATE
--
------------------------------------------------------------------------------

PROCEDURE Get_Cust_Acct_From_Account_Num
( p_cust_acct_number IN VARCHAR2,
  x_party_id OUT NOCOPY NUMBER,
  x_cust_account_id OUT NOCOPY NUMBER,
  x_last_update_date OUT NOCOPY DATE);

------------------------------------------------------------------------------
--  Procedure   : CSC_Customer_Lookup
--  Usage       : OTM will make a call to this API for customer lookup
--  Parameters  :
--      p_media_data                    IN OUT   NOCOPY  CCT_KEY_VALUE_LIST
--
------------------------------------------------------------------------------

PROCEDURE CSC_Customer_Lookup
( p_media_data IN OUT NOCOPY cct_keyvalue_varr);

------------------------------------------------------------------------------
--  Function    : Get_Party_Name_From_Party_id
--  Usage       : used to lookup customer name to pass over to softphone
--  Parameters  :
--      p_party_id                    IN  NOCOPY NUMBER
--
--  Returns     :
--      party_name varchar2(1996)
------------------------------------------------------------------------------

Function Get_Party_Name_From_Party_id
(p_party_id IN number)
Return varchar2;

END CSC_Routing_UTL;

 

/
