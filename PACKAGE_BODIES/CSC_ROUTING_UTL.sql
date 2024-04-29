--------------------------------------------------------
--  DDL for Package Body CSC_ROUTING_UTL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSC_ROUTING_UTL" AS
/* $Header: cscotmrb.pls 120.20 2006/11/02 18:59:49 hbchung ship $ */

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
		    p_ANI_CODE          IN  VARCHAR2,
		    p_country_code      OUT NOCOPY VARCHAR2,
		    p_area_code         OUT NOCOPY VARCHAR2,
		    p_phone_num         OUT NOCOPY VARCHAR2,
		    p_phone_ext         OUT NOCOPY VARCHAR2)
IS

BEGIN
   --
   --   this is a much more complex problem thatn is initially coded here.
   --   Once the contents of the IVR ANI is defined, thois code will
   --   have to be modified.
   --
   IF LENGTH(p_ANI_CODE) = 7 THEN
	  p_country_code := null;
	  p_area_code :=  null;
	  p_phone_num := p_ANI_CODE;
	  p_phone_ext := null;
   ELSIF LENGTH(p_ANI_CODE) = 10 THEN
	  p_country_code := null;
	  p_area_code := substr(p_ANI_CODE,1,3);
	  p_phone_num := substr(p_ANI_CODE,4,7);
	  p_phone_ext := null;
   ELSIF LENGTH(p_ANI_CODE) > 10 THEN
	  p_country_code := substr(p_ANI_CODE,1,3);
	  p_area_code := substr(p_ANI_CODE,4,3);
	  p_phone_num := substr(p_ANI_CODE,7,7);
	  p_phone_ext := null;
-- if none of the above pass everything in phone number field
   ELSE
	  p_country_code := null;
	  p_area_code := null;
	  p_phone_num := p_ANI_CODE;
	  p_phone_ext := null;
   END IF;

END decode_ANI;

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
( p_cust_acct_number	IN	VARCHAR2)
RETURN NUMBER IS

    p_party_id         NUMBER(15) := null;

    --
    -- get party ID given customer account number
    --
    CURSOR c_party_id (anum  VARCHAR2) IS
      SELECT party_id
      FROM   hz_cust_accounts
      WHERE  account_number = anum;
BEGIN

    OPEN c_party_id (p_cust_acct_number);
    FETCH c_party_id INTO p_party_id;
    IF c_party_id%NOTFOUND THEN
       CLOSE c_party_id;
       RETURN NULL;
    END IF;
    CLOSE c_party_id;
    RETURN to_number(p_party_id);

END Get_Customer_From_Account_Num;


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
FUNCTION Get_Customer_From_Contract_Num
( p_contract_number	IN	VARCHAR2)
RETURN NUMBER IS

    p_party_id	NUMBER(15);
    --
    -- get party ID given a contract number
    --
    /********
    CURSOR c_party_id IS
      SELECT customer_id
      FROM   ra_customer_trx_all
      WHERE  invoice_number = p_contract_number;
	 ***/

BEGIN

	/******
    OPEN c_party_id;
    FETCH c_party_id INTO p_party_id;
    IF c_party_id%NOTFOUND THEN
       CLOSE c_party_id;
       RETURN NULL;
    END IF;
    CLOSE c_party_id;
	****/

    RETURN p_party_id;

END Get_Customer_From_Contract_Num;

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
	Return Number IS

    p_party_id         NUMBER(15);

    --
    -- get party ID given site number
    --
    CURSOR c_party_id (snum  VARCHAR2) IS
      SELECT party_id
      FROM   hz_party_sites
      WHERE  party_site_number = snum;
BEGIN

    OPEN c_party_id (p_site_number);
    FETCH c_party_id INTO p_party_id;
    IF c_party_id%NOTFOUND THEN
       CLOSE c_party_id;
       RETURN NULL;
    END IF;
    CLOSE c_party_id;
    RETURN p_party_id;

END Get_Customer_From_Site_Num;

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
FUNCTION Get_Customer_From_Repair_Num
      ( p_repair_number	IN	VARCHAR2)
RETURN NUMBER
IS
    p_party_id	NUMBER(15);
    --
    -- get party ID given a repair number
    --
    CURSOR c_party_id (repnum  NUMBER) IS
      SELECT 	inc.customer_id
      FROM   	csd_repairs	rep,
			cs_incidents_v inc
      WHERE  	rep.repair_number = repnum
	   AND	rep.incident_id   = inc.incident_id;

BEGIN

    OPEN c_party_id (p_repair_number);
    FETCH c_party_id INTO p_party_id;
    IF c_party_id%NOTFOUND THEN
       CLOSE c_party_id;
       RETURN NULL;
    END IF;
    CLOSE c_party_id;

    RETURN p_party_id;

END Get_Customer_From_Repair_Num;

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
FUNCTION Get_Customer_From_Defect_Num
( p_defect_number	IN	VARCHAR2)
RETURN NUMBER IS

    p_party_id	NUMBER(15);
/*
    --
    -- get party ID given a defect number
    --
    CURSOR c_party_id (defnum   VARCHAR2) IS
      SELECT 	inc.incident_Id
      FROM   	css_def_defects_all_v	def,
			cs_incident_links	inl,
			cs_incidents_v		inc
      WHERE  	def.defect_number = defnum
	   AND	def.defect_id	   = inl.link_id
	   AND	inl.from_incident_id   = inc.incident_id;
*/

BEGIN

 /*   OPEN c_party_id (p_defect_number);
    FETCH c_party_id INTO p_party_id;
    IF c_party_id%NOTFOUND THEN
       CLOSE c_party_id;
       RETURN NULL;
    END IF;
    CLOSE c_party_id;
*/

    RETURN p_party_id;

END Get_Customer_From_Defect_Num;

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
RETURN NUMBER IS

    p_party_id         NUMBER(15);


    --
    -- get party ID given phone number, country code, area code and extension
    --
/* Enhancement: 1685717 Parties are queried by ordering last_update_date on               *//* hz_contact_points in descending order, so that active parties are selected first       */

/*
    CURSOR c_party_id (p_country  VARCHAR2,
				   p_area     VARCHAR2,
				   p_phone    VARCHAR2,
				   p_ext      VARCHAR2) IS
      SELECT party.party_id
      FROM   HZ_PARTIES			party,
		   hz_contact_points	cp
      WHERE  cp.phone_number = p_phone AND
		   cp.phone_country_code = p_country AND
             cp.phone_area_code = p_area       AND
             cp.phone_extension = p_ext 	 AND
		   cp.owner_table_name = 'HZ_PARTIES' AND
		   cp.owner_table_id   = party.party_id ;
*/

    CURSOR c_party_id (p_country  VARCHAR2,
				   p_area     VARCHAR2,
				   p_phone    VARCHAR2,
				   p_ext      VARCHAR2) IS
      SELECT cp.owner_table_id party_id
      FROM hz_contact_points cp
      WHERE  cp.phone_number = p_phone AND
		   cp.phone_country_code = p_country AND
             cp.phone_area_code = p_area       AND
             cp.phone_extension = p_ext 	 AND
		   cp.owner_table_name = 'HZ_PARTIES'
	 ORDER BY cp.last_update_date DESC;
    --
    -- get customer ID given phone number and extension
    --
/*
    CURSOR c_party_id_w_area_code (p_phone  VARCHAR2, p_ext  VARCHAR2) IS
      SELECT party.party_id
      FROM   HZ_PARTIES			party,
		   hz_contact_points	cp
      WHERE  cp.phone_number = p_phone AND
             cp.phone_extension = p_ext 	 AND
		   cp.owner_table_name = 'HZ_PARTIES' AND
		   cp.owner_table_id   = party.party_id ;
*/

    CURSOR c_party_id_w_area_code (p_phone  VARCHAR2, p_ext  VARCHAR2) IS
      SELECT cp.owner_table_id  party_id
	 FROM   hz_contact_points	cp
      WHERE  cp.phone_number = p_phone AND
             cp.phone_extension = p_ext 	 AND
		   cp.owner_table_name = 'HZ_PARTIES'
	 ORDER BY cp.last_update_date DESC;

    --
    -- get customer ID given phone number and area code
    --
/*
    CURSOR c_party_id_w_ctry_code (p_area  VARCHAR2, p_phone  VARCHAR2) IS
      SELECT party.party_id
      FROM   HZ_PARTIES			party,
		   hz_contact_points	cp
      WHERE  cp.phone_number = p_phone AND
             cp.phone_area_code = p_area       AND
		   cp.owner_table_name = 'HZ_PARTIES' AND
		   cp.owner_table_id   = party.party_id ;
 */
    CURSOR c_party_id_w_ctry_code (p_area  VARCHAR2, p_phone  VARCHAR2) IS
      SELECT cp.owner_table_id party_id
      FROM   hz_contact_points	cp
      WHERE  cp.phone_number = p_phone AND
             cp.phone_area_code = p_area       AND
		   cp.owner_table_name = 'HZ_PARTIES'
	 ORDER BY cp.last_update_date DESC;
    --
    -- get customer ID given phone number, area code and country code
    --
/*
    CURSOR c_party_id_w_extension (p_country  VARCHAR2,
							p_area     VARCHAR2,
							p_phone    VARCHAR2) IS
      SELECT party.party_id
      FROM   HZ_PARTIES			party,
		   hz_contact_points	cp
      WHERE  cp.phone_number = p_phone AND
             cp.phone_area_code = p_area       AND
             cp.phone_country_code = p_country AND
		   cp.owner_table_name = 'HZ_PARTIES' AND
		   cp.owner_table_id   = party.party_id;
*/

    CURSOR c_party_id_w_extension (p_country  VARCHAR2,
							p_area     VARCHAR2,
							p_phone    VARCHAR2) IS
      SELECT cp.owner_table_id party_id
	 FROM   hz_contact_points	cp
      WHERE  cp.phone_number = p_phone AND
             cp.phone_area_code = p_area       AND
             cp.phone_country_code = p_country AND
		   cp.owner_table_name = 'HZ_PARTIES'
      ORDER BY cp.last_update_date DESC;
    --
    -- get customer ID given phone number only
    --
/*
    CURSOR c_party_id_w_all (p_phone  VARCHAR2) IS
      SELECT party.party_id
      FROM   HZ_PARTIES			party,
		   hz_contact_points	cp
      WHERE  cp.phone_number = p_phone AND
		   cp.owner_table_name = 'HZ_PARTIES' AND
		   cp.owner_table_id   = party.party_id ;
*/

    CURSOR c_party_id_w_all (p_phone  VARCHAR2) IS
      SELECT cp.owner_table_id party_id
	 FROM   hz_contact_points	cp
      WHERE  cp.phone_number = p_phone AND
		   cp.owner_table_name = 'HZ_PARTIES'
      ORDER BY cp.last_update_date DESC;

BEGIN

    IF p_country_code IS NOT NULL AND
		 p_area_code IS NOT NULL AND
		 p_extension IS NOT NULL THEN
      OPEN c_party_id(p_country_code, p_area_code, p_phone_number, p_extension);
      FETCH c_party_id INTO p_party_id;
      IF c_party_id%NOTFOUND THEN
         CLOSE c_party_id;
         RETURN NULL;
      END IF;
      CLOSE c_party_id;
      RETURN to_number(p_party_id);
    END IF;

    IF p_country_code IS NULL AND p_area_code IS NULL AND p_extension IS NOT NULL THEN
      OPEN c_party_id_w_area_code(p_phone_number, p_extension);
      FETCH c_party_id_w_area_code INTO p_party_id;
      IF c_party_id_w_area_code%NOTFOUND THEN
         CLOSE c_party_id_w_area_code;
         RETURN NULL;
      END IF;
      CLOSE c_party_id_w_area_code;
      RETURN to_number(p_party_id);
    END IF;

    IF p_country_code IS NULL AND p_area_code IS NOT NULL AND
		p_extension IS NULL THEN
      OPEN c_party_id_w_ctry_code(p_area_code, p_phone_number);
      FETCH c_party_id_w_ctry_code INTO p_party_id;
      IF c_party_id_w_ctry_code%NOTFOUND THEN
         CLOSE c_party_id_w_ctry_code;
         RETURN NULL;
      END IF;
      CLOSE c_party_id_w_ctry_code;
      RETURN to_number(p_party_id);
    END IF;

    IF p_country_code IS NOT NULL AND p_area_code IS NOT NULL
		 AND p_extension IS NULL THEN
      OPEN c_party_id_w_extension(p_country_code, p_area_code, p_phone_number);
      FETCH c_party_id_w_extension INTO p_party_id;
      IF c_party_id_w_extension%NOTFOUND THEN
         CLOSE c_party_id_w_extension;
         RETURN NULL;
      END IF;
      CLOSE c_party_id_w_extension;
      RETURN to_number(p_party_id);
    END IF;

    IF p_area_code IS NULL AND p_extension IS NULL
		AND p_country_code IS NULL THEN
      OPEN c_party_id_w_all(p_phone_number);
      FETCH c_party_id_w_all INTO p_party_id;
      IF c_party_id_w_all%NOTFOUND THEN
         CLOSE c_party_id_w_all;
         RETURN NULL;
      END IF;
      CLOSE c_party_id_w_all;
      RETURN to_number(p_party_id);
    END IF;

END Get_Customer_From_ANI;

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


FUNCTION Get_Customer_From_CustomerNum
( p_party_number	IN	VARCHAR2)
RETURN NUMBER IS

    --p_party_id         ra_customers.customer_id%type;
    p_party_id           number;

    --
    -- get party ID gievn customer number
    --
    CURSOR c_party_id (pnum  VARCHAR2) IS
      SELECT party_id
      FROM   hz_parties
      WHERE  party_number = pnum;
BEGIN

    OPEN c_party_id(p_party_number);
    FETCH c_party_id INTO p_party_id;
    IF c_party_id%NOTFOUND THEN
       CLOSE c_party_id;
       RETURN NULL;
    END IF;
    CLOSE c_party_id;
    RETURN to_number(p_party_id);

END Get_Customer_From_CustomerNum;

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
FUNCTION Get_Customer_From_InvoiceNum
( p_invoice_number	IN	VARCHAR2)
RETURN NUMBER IS

 p_ship_to_customer_id     ra_customer_trx_all.ship_to_customer_id%type;
 p_bill_to_customer_id     ra_customer_trx_all.bill_to_customer_id%type;

    --
    -- get customer ID given an invoice number
    --
    CURSOR c_customer_id (invnum  VARCHAR2) IS
      SELECT ship_to_customer_id, bill_to_customer_id
      FROM   ra_customer_trx_all
      WHERE  trx_number = invnum;

BEGIN

    OPEN c_customer_id(p_invoice_number);
    FETCH c_customer_id INTO p_ship_to_customer_id, p_bill_to_customer_id;
    IF c_customer_id%NOTFOUND THEN
       CLOSE c_customer_id;
       RETURN NULL;
    END IF;
    CLOSE c_customer_id;
    IF p_ship_to_customer_id IS NOT NULL THEN
       RETURN to_number(p_ship_to_customer_id);
    ELSE
       RETURN to_number(p_bill_to_customer_id);
    END IF;

END Get_Customer_From_InvoiceNum;

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

FUNCTION Get_Name_Of_Customer
( p_party_id		IN	NUMBER)
RETURN VARCHAR2 IS
    p_party_name         VARCHAR2(255);

    --
    -- get party name given a party ID
    --
    CURSOR c_party_name (pid  NUMBER) IS
      SELECT party_name
      FROM   hz_parties
      WHERE  party_id = pid;
BEGIN

    OPEN c_party_name(p_party_id);
    FETCH c_party_name INTO p_party_name;
    IF c_party_name%NOTFOUND THEN
       CLOSE c_party_name;
       RETURN NULL;
    END IF;
    CLOSE c_party_name;
    RETURN p_party_name;
END Get_Name_Of_Customer;

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

FUNCTION Get_Status_Of_Customer(p_party_id		IN	NUMBER)
RETURN VARCHAR2
IS
    p_customer_status         varchar2(1);

    --
    -- get customer status given a party ID
    --
    CURSOR c_customer_status (pid  NUMBER) IS
      SELECT status
      FROM   hz_parties
      WHERE  party_iD = pid;
BEGIN

    OPEN c_customer_status(p_party_id);
    FETCH c_customer_status INTO p_customer_status;
    IF c_customer_status%NOTFOUND THEN
       CLOSE c_customer_status;
       RETURN NULL;
    END IF;
    CLOSE c_customer_status;
    RETURN p_customer_status;
END Get_Status_Of_Customer;


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

FUNCTION Is_CP_Existent(p_customer_product_id	   IN	NUMBER)
RETURN BOOLEAN IS

    p_customer_pid   NUMBER(15);

    --
    -- check if the given customer product ID exists
    --
    CURSOR c_customer_product_id (prodid  NUMBER) IS
      SELECT customer_product_id
      FROM   cs_customer_products_all
      WHERE  customer_product_id = prodid;
BEGIN

    OPEN c_customer_product_id(p_customer_product_id);
    FETCH c_customer_product_id INTO p_customer_pid;
    IF c_customer_product_id%NOTFOUND THEN
       CLOSE c_customer_product_id;
       RETURN false;
    ELSE
       CLOSE c_customer_product_id;
       RETURN true;
    END IF;
END Is_CP_Existent;


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

FUNCTION Customer_ID_Exists(p_customer_id IN NUMBER) Return BOOLEAN IS

    p_party_id   NUMBER(15);

    --
    -- check if the given customer ID exists
    --
    CURSOR c_party_id (custid  NUMBER) IS
      SELECT party_id
      FROM   hz_parties
      WHERE  party_id = custid;
BEGIN

    OPEN c_party_id(p_customer_id);
    FETCH c_party_id INTO p_party_id;
    IF c_party_id%NOTFOUND THEN
       CLOSE c_party_id;
       RETURN false;
    ELSE
       CLOSE c_party_id;
       RETURN true;
    END IF;
END Customer_ID_Exists;


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

FUNCTION Get_CP_From_ReferenceNum(p_reference_number	IN	NUMBER)
RETURN NUMBER IS


    p_customer_product_id     cs_customer_products_all.customer_product_id%type;

    --
    -- get customer product ID given a reference number
    --
    CURSOR c_customer_product_id (refnum  NUMBER) IS
      SELECT customer_product_id
      FROM   cs_customer_products_all
      WHERE  reference_number = refnum;

BEGIN

    OPEN c_customer_product_id(p_reference_number);
    IF c_customer_product_id%NOTFOUND THEN
       CLOSE c_customer_product_id;
       RETURN NULL;
    END IF;
    FETCH c_customer_product_id INTO p_customer_product_id;
    CLOSE c_customer_product_id;
    RETURN to_number(p_customer_product_id);

END Get_CP_From_ReferenceNum;

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

FUNCTION Get_Product_From_ReferenceNum(p_reference_number	IN	NUMBER)
RETURN NUMBER IS
    p_inventory_item_id   cs_customer_products_all.inventory_item_id%type;

    --
    -- get inventory item ID given a reference number
    --
    CURSOR c_inventory_item_id (refnum  NUMBER) IS
      SELECT inventory_item_id
      FROM   cs_customer_products_all
      WHERE  reference_number = refnum;
BEGIN

    OPEN c_inventory_item_id(p_reference_number);
    IF c_inventory_item_id%NOTFOUND THEN
       CLOSE c_inventory_item_id;
       RETURN NULL;
    END IF;
    FETCH c_inventory_item_id INTO p_inventory_item_id;
    CLOSE c_inventory_item_id;
    RETURN to_number(p_inventory_item_id);
END Get_Product_From_ReferenceNum;


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
( p_inventory_item_id	IN	NUMBER,
  p_inventory_org_id	IN	NUMBER)
RETURN VARCHAR2 IS

    p_product_name   mtl_system_items.description%type;

    --
    -- get name given an inventory item ID and a inventory organization ID
    --
    CURSOR c_product_name (invid  NUMBER, orgid  NUMBER) IS
      SELECT description
      FROM   mtl_system_items
      WHERE  inventory_item_id = invid AND
             organization_id = orgid;
BEGIN

    OPEN c_product_name(p_inventory_item_id, p_inventory_org_id);
    IF c_product_name%NOTFOUND THEN
       CLOSE c_product_name;
       RETURN NULL;
    END IF;
    FETCH c_product_name INTO p_product_name;
    CLOSE c_product_name;
    RETURN p_product_name;

END Get_Name_Of_Product;

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
Return Number Is

    p_party_id         NUMBER(15);
/*
    CURSOR c_party_id (email  VARCHAR2) IS
      SELECT party_id
      FROM   JTF_CONTACT_POINTS_V
      WHERE  Upper(email_address) = Upper(email) ;
*/

/* Enhancement: 1685717 Parties are queried by ordering last_update_date on               *//* hz_contact_points in descending order, so that active parties are selected first       */

	CURSOR c_party_id (email VARCHAR2) IS
		SELECT owner_table_id party_id
	 	FROM   hz_contact_points
		WHERE  owner_table_name = 'HZ_PARTIES'
		AND    contact_point_type = 'EMAIL'
		AND    UPPER(email_address) = UPPER(email)
	     ORDER BY last_update_date DESC;

BEGIN

    OPEN c_party_id(p_email_address);
    FETCH c_party_id INTO p_party_id;
    IF c_party_id%NOTFOUND THEN
       CLOSE c_party_id;
       RETURN NULL;
    END IF;
    CLOSE c_party_id;

    RETURN p_party_id;

END Get_Customer_From_Email;


--
------------------------------------------------------------------------------
--  Function	: Get_Customer_From_ContactNum
--  Usage	: Used to get the party ID from the Contact Number passed in the IVR parms
--  Description	: This function retrieves a party ID from the
--		  HZ_PARTIES table by traversing the relationships from HZ_ORG_CONTACTS
--          and HZ_RELATIONSHIPS.
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
Return Number IS

   CURSOR  cnum (connum  IN  VARCHAR2) IS
		 SELECT  p.party_id
		   FROM  hz_parties p,
			    hz_relationships r,
			    hz_org_contacts c
            WHERE  c.contact_number = connum
		    AND  c.party_relationship_id = r.relationship_id
		    AND  r.object_id = p.party_id
                    AND  r.subject_table_name = 'HZ_PARTIES'
                    AND  r.object_table_name = 'HZ_PARTIES'
                    AND  r.directional_flag = 'F';
   p_party_id         NUMBER := null;

BEGIN

    OPEN cnum (p_contact_number);
    FETCH cnum INTO p_party_id;
    IF cnum%NOTFOUND THEN
       CLOSE cnum;
       RETURN NULL;
    END IF;
    CLOSE cnum;

    RETURN p_party_id;

END   Get_Customer_From_ContactNum;

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
RETURN VARCHAR2
IS
  l_filtered_number     VARCHAR2(2000);
  l_ret_number  VARCHAR2(2000);
  l_changed_number  VARCHAR2(2000);

BEGIN

  l_filtered_number := translate(
    p_phone_number,
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz()- .+''~`\/@#$^&*_,|}{[]?<>=";:',
    '0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz');

  IF l_filtered_number IS NULL OR l_filtered_number='' THEN
    RETURN NULL;
  END IF;
  IF length(l_filtered_number) > 0 THEN
    FOR I IN REVERSE 1..length(l_filtered_number) LOOP
      l_ret_number := l_ret_number || substr(l_filtered_number,I,1);
    END LOOP;
    FOR I IN 1..length(l_ret_number) LOOP
        l_filtered_number := substr(l_ret_number,I,1);
        select decode(upper(l_filtered_number),'A','2','B','2','C','2',
                                          'D','3','E','3','F','3',
                                          'G','4','H','4','I','4',
                                          'J','5','K','5','L','5',
                                          'M','6','N','6','O','6',
                                          'P','7','Q','7','R','7','S','7',
                                          'T','8','U','8','V','8',
                                          'W','9','X','9','Y','9','Z','9',l_filtered_number) into l_filtered_number from dual;
        l_changed_number := l_changed_number||l_filtered_number;

    END LOOP;
    l_ret_number := l_changed_number;
  END IF;

  RETURN l_ret_number;
END reverse_number;



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
FUNCTION get_customer_from_reverse_ANI(p_rANI IN VARCHAR2,
                                       x_uwq_multi_record_match OUT NOCOPY VARCHAR2,
                                       x_phone_id OUT NOCOPY NUMBER )
RETURN NUMBER
IS
        l_phone_num 	VARCHAR2(30):=NULL;
        l_party_id  	NUMBER:=NULL;
        l_phone_id  	NUMBER:=NULL;
        l_rANI      	VARCHAR2(30):=NULL;
	l_stripped_rANI VARCHAR2(30):= NULL;
        n_use_exact_ani VARCHAR2(2);
--
        CURSOR transpose_phone_cur IS
                SELECT transposed_phone_number, owner_table_id, contact_point_id
                FROM hz_contact_points
                WHERE transposed_phone_number LIKE l_rANI
                AND owner_table_name = 'HZ_PARTIES'
                ORDER BY last_update_date DESC;

BEGIN
        IF p_rANI IS NULL THEN
           RETURN to_number(NULL);
        END IF;

        fnd_profile.get('CSC_CUSTOMER_FROM_EXACT_ANI',n_use_exact_ani);
        IF NVL(n_use_exact_ani,'Y') = 'Y' THEN
           l_rANI := p_rANI||'%';
           OPEN transpose_phone_cur;
           LOOP
             IF transpose_phone_cur%NOTFOUND THEN
                EXIT;
             END IF;
             FETCH transpose_phone_cur INTO l_phone_num, l_party_id, l_phone_id;
           END LOOP;
           IF transpose_phone_cur%ROWCOUNT > 1 THEN
              CLOSE transpose_phone_cur;
              x_uwq_multi_record_match := '"MULTIPLE_PHONE_NUMBERS"';
              x_phone_id := l_phone_id;
              RETURN to_number(NULL);
           END IF;
           CLOSE transpose_phone_cur;
           x_phone_id := l_phone_id;
           RETURN l_party_id;
        ELSE
           l_stripped_rANI := SUBSTR(p_rANI,1, LENGTH(p_rANI)-1);
	   l_rANI := l_stripped_rANI||'%';
           OPEN transpose_phone_cur;
           LOOP
             IF transpose_phone_cur%NOTFOUND THEN
                EXIT;
             END IF;
             FETCH transpose_phone_cur INTO l_phone_num, l_party_id, l_phone_id;
           END LOOP;
           IF transpose_phone_cur%ROWCOUNT > 1 THEN
              CLOSE transpose_phone_cur;
              x_uwq_multi_record_match := '"MULTIPLE_PHONE_NUMBERS" uwq_stripped_reverse_ani="'||l_stripped_rANI||'"';
              x_phone_id := l_phone_id;
              RETURN to_number(NULL);
           END IF;
           CLOSE transpose_phone_cur;
           x_phone_id := l_phone_id;
           RETURN l_party_id;
        END IF;
END;

--------------------------------------------------------------------------
--
------------------------------------------------------------------------------
--  Procedure	: Get_Cust_Acct_From_Account_Num
--  Usage	: Used to get Party_id,Cust_account_id,last_update_date from
--		  hz_cust_accounts
--  Parameters	:
--	p_customer_account_number	IN	VARCHAR2(30)	Required
--	x_party_id			OUT NOCOPY	NUMBER(15)
--	x_cust_account_id		OUT NOCOPY	NUMBER(15)
--	x_last_update_date		OUT NOCOPY	DATE
--
------------------------------------------------------------------------------

PROCEDURE Get_Cust_Acct_From_Account_Num
( p_cust_acct_number IN VARCHAR2,
  x_party_id OUT NOCOPY NUMBER,
  x_cust_account_id OUT NOCOPY NUMBER,
  x_last_update_date OUT NOCOPY DATE) IS

    CURSOR c_party_id (anum  VARCHAR2) IS
      SELECT party_id,cust_account_id,last_update_date
      FROM   hz_cust_accounts
      WHERE  account_number = anum;
BEGIN

    OPEN c_party_id (p_cust_acct_number);
    FETCH c_party_id INTO x_party_id,x_cust_account_id,x_last_update_date;
    CLOSE c_party_id;

END Get_Cust_Acct_From_Account_Num;

------------------------------------------------------------------------------
--  Function    : Get_Party_Name_From_Party_id
--  Usage       : used to lookup customer name to pass over to softphone
--  Parameters  :
--      p_party_id                    IN  NOCOPY NUMBER
--
--  Returns     :
--      party_name varchar2(1996)
------------------------------------------------------------------------------

FUNCTION Get_Party_Name_From_Party_id
(p_party_id IN number)
Return varchar2 IS

x_party_name varchar2(1996);

BEGIN
   IF p_party_id IS NOT NULL THEN
      BEGIN
         SELECT party_name
           INTO x_party_name
           FROM hz_parties
          WHERE party_id = p_party_id;
	 EXCEPTION WHEN NO_DATA_FOUND THEN
	    x_party_name := 'NOTFOUND';
	    return x_party_name;
	 END;
   END IF;

   return x_party_name;
END;

------------------------------------------------------------------------------
--  Procedure   : CSC_Customer_Lookup
--  Usage       : OTM will make a call to this API for customer lookup
--  Parameters  :
--      p_media_data                    IN OUT   NOCOPY  CCT_KEY_VALUE_LIST
--
------------------------------------------------------------------------------
PROCEDURE CSC_Customer_Lookup
( p_media_data IN OUT NOCOPY cct_keyvalue_varr) IS

   l_customer_num              varchar2(100);
   l_contact_num               varchar2(100);
   l_contract_num              varchar2(240);
   l_sr_num                    varchar2(240);
   l_order_num                 varchar2(240);
   l_invoice_num               varchar2(240);
   l_system                    varchar2(240);
   l_ssn                       varchar2(240);
   l_rma_num                   varchar2(240);
   l_system_name               varchar2(240);
   l_tag_num                   varchar2(240);
   l_country_code              varchar2(100);
   l_area_code                 varchar2(100);
   l_phone_num                 varchar2(100);
   l_complete_phone_num        varchar2(100);
   l_serial_num                varchar2(100);
   l_rma                       varchar2(100);
   l_ani                       varchar2(100);
   l_int_id                    varchar2(100);
   l_account_code              varchar2(100);
   l_screen_pop_action         varchar2(100);
   l_media_item_id             varchar2(100);
   l_dnis                      varchar2(100);
   l_event_name                varchar2(100);
   l_agent                     varchar2(100);
   l_media_type                varchar2(100);
   l_callID                    varchar2(100);
   l_sender_name               varchar2(100);
   l_cust_prod_id              varchar2(100);
   l_inv_item_id               varchar2(100);
   l_emp_id                    varchar2(100);
   l_lot_num                   varchar2(100);
   l_po_num                    varchar2(100);
   l_quote_num                 varchar2(100);
   l_instance_name             varchar2(100);
   l_workitemID                varchar2(100);
   x_exist_flag                varchar2(1);
   l_put_result                varchar2(256);
   l_phone_passed_flag         varchar2(1):='N';
   l_email_cust_id             number;
   l_rphone                    varchar2(1996);
   l_uwq_multi_record_match    varchar2(2000);
   l_phone_id                  number;
   l_customer_id               number;
   l_match                     varchar2(1):='0';
   l_cust_account_id           number;
   l_acct_last_update_date     date;
   l_hdr_info_tbl              CSC_SERVICE_KEY_PVT.HDR_info_tbl_type;

   --Variables used only for transfer/conference values
   l_xfer_action_id            NUMBER;
   l_xfer_interaction_id       NUMBER;
   l_xfer_service_key_name     VARCHAR2(40);
   l_xfer_service_key_value    VARCHAR2(240);
   l_xfer_call_reason          VARCHAR2(40);
   l_party_id                  NUMBER;
   l_xfer_cust_party_id        NUMBER;
   l_xfer_rel_party_id         NUMBER;
   l_xfer_per_party_id         NUMBER;
   l_xfer_cust_phone_id        NUMBER;
   l_xfer_cust_email_id        NUMBER;
   l_xfer_rel_phone_id         NUMBER;
   l_xfer_rel_email_id         NUMBER;
   l_xfer_cust_account_id      NUMBER;
   l_trans_conf_flag           VARCHAR2(1) := 'N';
   l_processed_flag            VARCHAR2(1) := 'Y';
   n_use_exact_ani             VARCHAR2(3) := 'Y';
   l_stripped_rANI             VARCHAR2(50):= null;

   l_instance_num              varchar2(100);
   l_customer_name             varchar2(1996);

   l_done_it                   varchar2(10);
BEGIN
   /*--New Flag to prevent this new lookup to be called again
   l_done_it      := cct_collection_util_pub.get(p_media_data, 'DONE_IT',x_exist_flag);

   IF nvl(l_done_it,'NO') = 'DONE' AND x_exist_flag = 'Y' THEN
      --Went thru the parsing already, no need to go again.
      RETURN;
   END IF;
   */

   l_xfer_action_id := cct_collection_util_pub.get(p_media_data, 'ActionID',x_exist_flag);
   IF l_xfer_action_id is not null AND x_exist_flag = 'Y' THEN
      l_trans_conf_flag := 'Y';
   END IF;
   l_xfer_interaction_id      := cct_collection_util_pub.get(p_media_data, 'INTERACTION_ID',x_exist_flag);
   l_xfer_service_key_name    := cct_collection_util_pub.get(p_media_data, 'SERVICE_KEY_NAME',x_exist_flag);
   l_xfer_service_key_value   := cct_collection_util_pub.get(p_media_data, 'SERVICE_KEY_VALUE',x_exist_flag);
   l_xfer_call_reason         := cct_collection_util_pub.get(p_media_data, 'CALL_REASON',x_exist_flag);
   l_xfer_cust_party_id       := cct_collection_util_pub.get(p_media_data, 'CUST_PARTY_ID',x_exist_flag);
   l_xfer_rel_party_id        := cct_collection_util_pub.get(p_media_data, 'REL_PARTY_ID',x_exist_flag);
   l_xfer_per_party_id        := cct_collection_util_pub.get(p_media_data, 'PER_PARTY_ID',x_exist_flag);
   l_xfer_cust_phone_id       := cct_collection_util_pub.get(p_media_data, 'CUST_PHONE_ID',x_exist_flag);
   l_xfer_cust_email_id       := cct_collection_util_pub.get(p_media_data, 'CUST_EMAIL_ID',x_exist_flag);
   l_xfer_rel_phone_id        := cct_collection_util_pub.get(p_media_data, 'REL_PHONE_ID',x_exist_flag);
   l_xfer_rel_email_id        := cct_collection_util_pub.get(p_media_data, 'REL_EMAIL_ID',x_exist_flag);
   l_xfer_cust_account_id     := cct_collection_util_pub.get(p_media_data, 'CUST_ACCOUNT_ID',x_exist_flag);
   l_party_id                 := cct_collection_util_pub.get(p_media_data, 'PARTY_ID',x_exist_flag);
   IF l_party_id is not null AND x_exist_flag = 'Y' THEN
      l_customer_id := l_party_id;
   END IF;

   l_customer_num             := cct_collection_util_pub.get(p_media_data, 'CustomerNum',x_exist_flag);
   l_contact_num              := cct_collection_util_pub.get(p_media_data, 'ContactNum', x_exist_flag);
   l_account_code             := cct_collection_util_pub.get(p_media_data, 'AccountCode', x_exist_flag);
   l_contract_num             := cct_collection_util_pub.get(p_media_data, 'ContractNum', x_exist_flag);
   l_invoice_num              := cct_collection_util_pub.get(p_media_data, 'InvoiceNum', x_exist_flag);
   l_order_num                := cct_collection_util_pub.get(p_media_data, 'OrderNum',  x_exist_flag);
   l_ssn                      := cct_collection_util_pub.get(p_media_data, 'SocialSecurityNumber', x_exist_flag);
   l_rma_num                  := cct_collection_util_pub.get(p_media_data, 'RMANum', x_exist_flag);
   l_serial_num               := cct_collection_util_pub.get(p_media_data, 'SerialNum', x_exist_flag);
   l_sr_num                   := cct_collection_util_pub.get(p_media_data, 'ServiceRequestNum', x_exist_flag);
   l_instance_name            := cct_collection_util_pub.get(p_media_data, 'InstanceName', x_exist_flag);
   l_instance_num             := cct_collection_util_pub.get(p_media_data, 'InstanceNum', x_exist_flag);
   l_tag_num                  := cct_collection_util_pub.get(p_media_data, 'TagNumber', x_exist_flag);
   l_system_name              := cct_collection_util_pub.get(p_media_data, 'SystemName', x_exist_flag);


   --Set service key name and value based on the hierarchy specified in SRD
   if l_customer_id is not null then
      --p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
      l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_customer_id);
      l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_customer_id);
      l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','PartyID');
      --this fix is for user who uses default or custom lookup, even when l_customer_id is not null
      --it will still check for service key value pairs
      if (l_sr_num is null) AND
         (l_instance_name is null) AND
         (l_instance_num is null) AND
         (l_serial_num is null) AND
         (l_tag_num is null) AND
         (l_system_name is null) AND
         (l_rma_num is null) AND
         (l_order_num is null) AND
         (l_ssn is null) AND
         (l_contract_num is null) AND
         (l_invoice_num is null) THEN
         l_match := 1;
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
    --     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');

         --Resolve party_name from party_id
         l_customer_name := get_party_name_from_party_id(l_customer_id);
	    IF l_customer_name <> 'NOTFOUND' THEN
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
	    END IF;
         RETURN;
      end if;
   end if;

   l_country_code             := cct_collection_util_pub.get(p_media_data, 'CountryCode', x_exist_flag);
   if x_exist_flag = 'Y'  then
      l_phone_passed_flag := 'Y';
   end if;
   l_area_code := cct_collection_util_pub.get(p_media_data, 'AreaCode', x_exist_flag);
   if x_exist_flag = 'Y' then
      l_phone_passed_flag := 'Y';
   end if;
   l_phone_num := cct_collection_util_pub.get(p_media_data, 'PhoneNumber', x_exist_flag);
   if x_exist_flag = 'Y' then
      l_phone_passed_flag := 'Y';
   end if;
   l_screen_pop_action        := cct_collection_util_pub.get(p_media_data, 'occtScreenPopAction', x_exist_flag);
   l_ani                      := cct_collection_util_pub.get(p_media_data, 'occtANI', x_exist_flag);
   l_media_item_id            := cct_collection_util_pub.get(p_media_data, 'occtMediaItemID', x_exist_flag);
   l_event_name               := cct_collection_util_pub.get(p_media_data, 'occtEventName', x_exist_flag);
   l_agent                    := cct_collection_util_pub.get(p_media_data, 'occtAgentID', x_exist_flag);
   l_dnis                     := cct_collection_util_pub.get(p_media_data, 'occtDNIS', x_exist_flag);
   l_workitemID               := cct_collection_util_pub.get(p_media_data, 'workItemID', x_exist_flag);
   l_media_type               := cct_collection_util_pub.get(p_media_data, 'occtMediaType', x_exist_flag);
   l_callID                   := cct_collection_util_pub.get(p_media_data, 'occtCallID', x_exist_flag);
   l_sender_name              := cct_collection_util_pub.get(p_media_data, 'oiemSenderName', x_exist_flag);
   if x_exist_flag = 'Y' and l_sender_name is not null then
      l_email_cust_id := csc_routing_utl.Get_Customer_from_Email(l_sender_name);
   end if;
   l_cust_prod_id             := cct_collection_util_pub.get(p_media_data, 'CustomerProductID', x_exist_flag);
   l_inv_item_id              := cct_collection_util_pub.get(p_media_data, 'InventoryItemID', x_exist_flag);
   l_emp_id                   := cct_collection_util_pub.get(p_media_data, 'employeeID', x_exist_flag);
   l_lot_num                  := cct_collection_util_pub.get(p_media_data, 'LotNum', x_exist_flag);
   l_po_num                   := cct_collection_util_pub.get(p_media_data, 'PurchaseOrderNum', x_exist_flag);
   l_quote_num                := cct_collection_util_pub.get(p_media_data, 'QuoteNum', x_exist_flag);


/*
      --First preference is given to user hook.
   IF JTF_USR_HKS.OK_TO_EXECUTE('CSC_UWQ_FORM_ROUTE', 'CSC_UWQ_FORM_OBJ', 'B', 'C') THEN
      l_customer_id := NULL;
      l_cust_account_id := NULL;
      l_phone_id := NULL;

      --calling R12 user hook signature
      CSC_UWQ_FORM_ROUTE_CUHK.CSC_UWQ_FORM_OBJ_PRE(p_media_data      => p_media_data,
                                                   x_party_id        => l_customer_id,
                                                   x_cust_account_id => l_cust_account_id,
                                                   x_phone_id        => l_phone_id);


      If l_customer_id is not null THEN
         --append l_customer_id back to p_media_data
         --p_action_param := p_action_param||'uwq_party_id="'||l_customer_id||'"';
      End if;
      If l_cust_account_id is not null Then
         --append l_cust_account_id back to p_media_data
         --p_action_param := p_action_param||'uwq_cust_account_id="'||l_cust_account_id ||'"';      End If;
      End if;
      If l_phone_id is not null Then
         --append l_phone_id back to p_media_data
         --p_action_param := p_action_param||'uwq_phone_id="'||l_phone_id ||'"';
      End If;
      RETURN;
   ELSE


      IF (l_trans_conf_flag = 'Y') THEN
      --This IF condition is added to fix bug 3773311. It is specific to xfr between
      --telesales and cc.
         IF (l_xfer_cust_party_id is not null) AND
            (l_xfer_rel_party_id is not null) AND
            (l_xfer_cust_party_id = l_xfer_rel_party_id) AND
            (l_xfer_cust_party_id <> nvl(l_xfer_per_party_id,-1)) THEN

            --since this is a xfr call from ebc, all search keys would needed to be initialized
            --to avoid any confusion.
            l_sr_num := null;
            l_instance_name := null;
            l_instance_num := null;
            l_serial_num := null;
            l_tag_num := null;
            l_system_name := null;
            l_rma_num := null;
            l_order_num := null;
            l_ssn := null;
            l_contract_num := null;
            l_invoice_num := null;

            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'FromEBC','Y');
            --foo needs to clear out uwq_service_key_name and value
         ELSE
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'FromEBC','N');
            --foo needs to append all the xfr params to p_action_param
         END IF;
      END IF;

*/

      --Service Key gets priority
      if l_sr_num is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','SR');

         --call anand lookup to search for sr num
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'SERVICE_REQUEST_NUMBER',
                                                p_skey_value =>  l_sr_num,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
         IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);

            IF l_hdr_info_tbl(1).rel_party_id is not null THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_rel_party_id',l_hdr_info_tbl(1).rel_party_id);

               l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).rel_party_id);
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
            END IF;

            IF l_hdr_info_tbl(1).cust_party_id is not null THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

               IF l_customer_name IS NULL THEN
                  l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
                  l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
               END IF;
            END IF;

            IF l_hdr_info_tbl(1).employee_id is not null THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'employeeID',l_hdr_info_tbl(1).employee_id);
            END IF;

            IF l_hdr_info_tbl(1).cust_phone_id is not null THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_cust_phone_id',l_hdr_info_tbl(1).cust_phone_id);
            END IF;

            IF l_hdr_info_tbl(1).account_id is not null THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_account_id',l_hdr_info_tbl(1).account_id);
            END IF;

            IF l_hdr_info_tbl(1).rel_phone_id is not null THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_rel_phone_id',l_hdr_info_tbl(1).rel_phone_id);
            END IF;

            IF l_hdr_info_tbl(1).per_party_id is not null THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_per_party_id',l_hdr_info_tbl(1).per_party_id);
            END IF;

            IF l_hdr_info_tbl(1).rel_email_id is not null THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_rel_email_id',l_hdr_info_tbl(1).rel_email_id);
            END IF;

            IF l_hdr_info_tbl(1).cust_email_id is not null THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_cust_email_id',l_hdr_info_tbl(1).cust_email_id);
            END IF;

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
            --remember to append the SR # to the p_action_str in foo
         END IF;
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
        -- l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
         RETURN;
      elsif l_emp_id is not null then
         l_match := '0';
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','Employee');
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'employeeID',l_emp_id);
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
       --  l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
         RETURN;
      elsif l_instance_name is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','InstanceName');

         --call anand lookup to search for instance name
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'INSTANCE_NAME',
                                                p_skey_value =>  l_instance_name,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
          IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

            --must check if account_id is null before setting.
            IF l_hdr_info_tbl(1).account_id IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_account_id',l_hdr_info_tbl(1).account_id);
		  END IF;

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
            --remember to append the instance name to the p_action_str in foo
         END IF;
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
          --  l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
      elsif l_instance_num is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','InstanceNum');

         --call anand lookup to search for instance num
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'INSTANCE_NUMBER',
                                                p_skey_value =>  l_instance_num,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
          IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

            --must check if account_id is null before setting.
	       IF l_hdr_info_tbl(1).account_id IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_account_id',l_hdr_info_tbl(1).account_id);
	       END IF;

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
         END IF;
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
           -- l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
      elsif l_serial_num is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','SerialNum');

         --call anand lookup to search for serial num
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'SERIAL_NUMBER',
                                                p_skey_value =>  l_serial_num,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
          IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

            --must check if account_id is null before setting.
		  IF l_hdr_info_tbl(1).account_id IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_account_id',l_hdr_info_tbl(1).account_id);
	       END IF;

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
            --remember to append the serial # to the p_action_str in foo
         END IF;
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
            --l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
      elsif l_tag_num is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','TagNum');

         --call anand lookup to search for tag num
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'EXTERNAL_REFERENCE',
                                                p_skey_value =>  l_tag_num,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
          IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

            --must check if account_id is null before setting.
	       IF l_hdr_info_tbl(1).account_id IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_account_id',l_hdr_info_tbl(1).account_id);
	       END IF;

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
            --remember to append the tag # to the p_action_str in foo
         END IF;
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
           -- l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
      elsif l_system_name is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','SystemName');

                           --call anand lookup to search for system name
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'SYSTEM_NUMBER',
                                                p_skey_value =>  l_system_name,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
          IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

            --must check if account_id is null before setting.
            IF l_hdr_info_tbl(1).account_id IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_account_id',l_hdr_info_tbl(1).account_id);
		  END IF;

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
            --remember to append the system # to the p_action_str in foo
         END IF;
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
         --   l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
      elsif l_rma_num is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','RMANum');

         --call anand lookup to search for rma num
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'RMA_NUMBER',
                                                p_skey_value =>  l_rma_num,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
          IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

            --must check if account_id is null before setting.
            IF l_hdr_info_tbl(1).account_id IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_account_id',l_hdr_info_tbl(1).account_id);
		  END IF;

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
            --remember to append the rma # to the p_action_str in foo
         END IF;
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
          --  l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
      elsif l_order_num is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','OrderNum');

         --call anand lookup to search for order num
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'ORDER_NUMBER',
                                                p_skey_value =>  l_order_num,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
          IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

            --must check if account_id is null before setting.
            IF l_hdr_info_tbl(1).account_id IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_account_id',l_hdr_info_tbl(1).account_id);
		  END IF;

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
            --remember to append the order # to the p_action_str in foo
         END IF;
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
          --  l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
      elsif l_ssn is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','SSN');

          --call anand lookup to search for ssn
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'SSN',
                                                p_skey_value =>  l_ssn,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
          IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
            --remember to append the ssn to the p_action_str in foo
         END IF;
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
         --   l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
      elsif l_contract_num is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','ContractNum');

         --call anand lookup to search for contract num
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'CONTRACT_NUMBER',
                                                p_skey_value =>  l_contract_num,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
          IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';

            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
            --remember to append the contract # to the p_action_str in foo
         END IF;
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
           -- l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
      elsif l_invoice_num is not null then
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','InvoiceNum');

         --call anand lookup to search for invoice num
         CSC_SERVICE_KEY_PVT.service_key_search(p_skey_name =>  'INVOICE_NUMBER',
                                                p_skey_value =>  l_invoice_num,
                                                x_hdr_info_tbl => l_hdr_info_tbl);
          IF (l_hdr_info_tbl.count = 0) THEN
            l_match := '0';
         ELSIF (l_hdr_info_tbl.count = 1) THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_hdr_info_tbl(1).cust_party_id);

            --must check if account_id is null before setting.
           IF l_hdr_info_tbl(1).account_id IS NOT NULL THEN
              l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'SKEY_account_id',l_hdr_info_tbl(1).account_id);
		 END IF;

            --bug 5640146
            --passing service_key_id
		  IF l_hdr_info_tbl(1).service_key_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'service_key_id',l_hdr_info_tbl(1).service_key_id);
		  END IF;

		  --passing org_id
		  IF l_hdr_info_tbl(1).org_id IS NOT NULL THEN
		     l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_skey_org_id',l_hdr_info_tbl(1).org_id);
		  END IF;
            --end of bug 5640146

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_hdr_info_tbl(1).cust_party_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         ELSE --(l_hdr_info_tbl.count > 1) THEN
            l_match := 'M';
            --remember to append the invoice # to the p_action_str in foo
         END IF;
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
         --   l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
      end if;

      --Customer Num LookUp
      If l_customer_num is not null THEN
         l_customer_id := null;
         l_customer_id := CSC_ROUTING_UTL.Get_Customer_From_CustomerNum(p_party_number => l_customer_num);
         IF l_customer_id IS NOT NULL THEN
           l_match := '1';
           l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','PartyID');

           --bug 5615536
           l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_customer_id);
           l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_customer_id);
		 --end of bug 5615536

           l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
           l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);

           --Resolve party_name from party_id
           l_customer_name := get_party_name_from_party_id(l_customer_id);
           l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
        --   l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
           RETURN;
         END IF;
      END IF;

      --AccountCode lookup
      IF l_account_code IS NOT NULL THEN
         l_customer_id := null;
         CSC_ROUTING_UTL.Get_Cust_Acct_From_Account_Num( p_cust_acct_number  => l_account_code,
                                                         x_party_id          => l_customer_id,
                                                         x_cust_account_id   => l_cust_account_id,
                                                         x_last_update_date  => l_acct_last_update_date);
         IF l_customer_id IS NOT NULL THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','AccountCode');
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_customer_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_customer_id);

            --must check if account_id is null before setting.
	       IF l_cust_account_id IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_cust_account_id',l_cust_account_id);
	       END IF;

            IF l_acct_last_update_date IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_last_update_date',l_acct_last_update_date);
	       END IF;

            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_customer_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         --   l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
         END IF;
      END IF;

      --Phone lookup
      IF l_phone_passed_flag = 'Y' THEN
         l_complete_phone_num := l_country_code || l_area_code || l_phone_num;
         IF l_complete_phone_num IS NOT NULL THEN
            l_customer_id := NULL;
            l_rphone := HZ_PHONE_NUMBER_PKG.transpose(l_complete_phone_num);
            l_customer_id := CSC_ROUTING_UTL.get_customer_from_reverse_ANI(l_rphone,
                                                                           l_uwq_multi_record_match,
                                                                           l_phone_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','CompletePhone');

            IF l_customer_id IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_customer_id);
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_customer_id);

               IF l_phone_id IS NOT NULL THEN
                  l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_phone_id',l_phone_id);
			END IF;

               --Resolve party_name from party_id
               l_customer_name := get_party_name_from_party_id(l_customer_id);
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);

               l_match := '1';
            ELSE
               IF l_uwq_multi_record_match is not null THEN
                  l_match := 'M';
                  l_uwq_multi_record_match := 'MULTIPLE_PHONE_NUMBERS';
                  fnd_profile.get('CSC_CUSTOMER_FROM_EXACT_ANI',n_use_exact_ani);
                  IF NVL(n_use_exact_ani,'Y') = 'N' THEN
                    l_stripped_rANI := SUBSTR(l_rphone,1, LENGTH(l_rphone)-1);
                    l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_stripped_reverse_ani',l_stripped_rANI);
                  END IF;
               ELSE
                  l_match := '1';
               END IF;
            END IF;

            IF l_uwq_multi_record_match IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_multi_record_match',l_uwq_multi_record_match);
	       END IF;

            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);

            IF l_rphone IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_reverse_ani',l_rphone);
		  END IF;

            IF l_complete_phone_num IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_complete_phone_num',l_complete_phone_num);
	       END IF;

            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
          --  l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
            RETURN;
         END IF;
      END IF;

      --Contact Num lookup
      IF l_contact_num IS NOT NULL THEN
         l_customer_id := null;
         l_customer_id := CSC_ROUTING_UTL.Get_Customer_From_CustomerNum( p_party_number   => l_contact_num);
         IF l_customer_id IS NOT NULL THEN
            l_match := '1';
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','PartyID');
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_customer_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_customer_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_customer_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
         --   l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');

            RETURN;
         END IF;
      END IF;


      --ANI lookup
      IF l_ani IS NOT NULL THEN
         --Note: standard REVERSE function cannot be used in PL-SQL as it is a reserved word in PL-SQL
         --to replace this function REVERSE_NUMBER function was created
         l_customer_id := NULL;
         l_rphone := HZ_PHONE_NUMBER_PKG.transpose(l_ani);
         l_customer_id := CSC_ROUTING_UTL.get_customer_from_reverse_ANI(l_rphone,
                                                                        l_uwq_multi_record_match,
                                                                        l_phone_id);
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'WhichIVR','ANI');

         IF l_customer_id is not null THEN --Exact Match
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_customer_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_customer_id);

            IF l_phone_id IS NOT NULL THEN
               l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_phone_id',l_phone_id);
		  END IF;

            --Resolve party_name from party_id
            l_customer_name := get_party_name_from_party_id(l_customer_id);
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerName',l_customer_name);
            l_match := '1';
         ELSE
            IF l_uwq_multi_record_match is not null THEN
               l_match := 'M';
               l_uwq_multi_record_match := 'MULTIPLE_PHONE_NUMBERS';
               fnd_profile.get('CSC_CUSTOMER_FROM_EXACT_ANI',n_use_exact_ani);

               IF NVL(n_use_exact_ani,'Y') = 'N' THEN
                 l_stripped_rANI := SUBSTR(l_rphone,1, LENGTH(l_rphone)-1);
                 l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_stripped_reverse_ani',l_stripped_rANI);
               END IF;
            ELSE
               l_match := '0';
            END IF;
         END IF;

         IF l_uwq_multi_record_match IS NOT NULL THEN
            l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_multi_record_match',l_uwq_multi_record_match);
	    END IF;

         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'uwq_reverse_ani',l_rphone);
         l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
      --   l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');
         RETURN;

      END IF;
EXCEPTION
   WHEN OTHERS THEN
      l_customer_id := null;
      l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'CustomerID',l_customer_id);
      l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'PARTY_ID',l_customer_id);
      l_match := '0';
      l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'MatchFlag',l_match);
      l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'ProcessedFlag',l_processed_flag);
    --  l_put_result := CCT_COLLECTION_UTIL_PUB.PUT(p_media_data,'DONE_IT','DONE');

END CSC_Customer_Lookup;

END CSC_Routing_UTL;


/
