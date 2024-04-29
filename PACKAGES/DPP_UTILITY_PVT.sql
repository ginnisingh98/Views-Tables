--------------------------------------------------------
--  DDL for Package DPP_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: dppvutls.pls 120.8.12010000.6 2010/04/23 08:29:17 anbbalas ship $ */

------------------------------------------------------------------------------
-- HISTORY
--    24-Aug-2007  JAJOSE     Creation

------------------------------------------------------------------------------
DPP_DEBUG_HIGH_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH);
DPP_DEBUG_LOW_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
DPP_DEBUG_MEDIUM_ON CONSTANT BOOLEAN := FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM);

resource_locked EXCEPTION;
pragma EXCEPTION_INIT(resource_locked, -54);

TYPE search_criteria_rec_type IS RECORD
(
search_criteria  VARCHAR2(50), -- contains criteria name
search_text   VARCHAR2(255)     -- contains criteria value
);
TYPE search_criteria_tbl_type IS TABLE OF search_criteria_rec_type INDEX BY BINARY_INTEGER;


TYPE vendor_rec_type IS RECORD
(
 vendor_id  NUMBER,
 vendor_number VARCHAR2(30),
 vendor_name VARCHAR2(240)
);

TYPE vendor_tbl_type IS TABLE OF vendor_rec_type INDEX BY BINARY_INTEGER;

TYPE vendor_site_rec_type IS RECORD
(
 vendor_id	NUMBER,
 vendor_site_id  NUMBER,
 vendor_site_code VARCHAR2(15),
 address_line1 VARCHAR2(240),
 address_line2 VARCHAR2(240),
 address_line3 VARCHAR2(240),
 city VARCHAR2(25),
 state VARCHAR2(150),
 zip VARCHAR2(20),
country VARCHAR2(25)
);

TYPE vendor_site_tbl_type IS TABLE OF vendor_site_rec_type INDEX BY BINARY_INTEGER;

TYPE vendor_contact_rec_type IS RECORD
(
 vendor_site_id  NUMBER,
 vendor_contact_id	NUMBER,
 contact_first_name VARCHAR2(15),
 contact_middle_name VARCHAR2(15),
 contact_last_name VARCHAR2(20),
 contact_phone              VARCHAR2(40),
 contact_email_address      VARCHAR2(2000),
 contact_fax                VARCHAR2(40)
);

TYPE vendor_contact_tbl_type IS TABLE OF vendor_contact_rec_type INDEX BY BINARY_INTEGER;

TYPE customer_rec_type IS RECORD
(
 customer_id  NUMBER,
 customer_number VARCHAR2(30),
 customer_name VARCHAR2(360)
);

TYPE customer_tbl_type IS TABLE OF customer_rec_type INDEX BY BINARY_INTEGER;

TYPE item_rec_type IS RECORD
(
 inventory_item_id  NUMBER,
 item_number VARCHAR2(240),
 DESCRIPTION  VARCHAR2(240)
);

TYPE item_tbl_type IS TABLE OF item_rec_type INDEX BY BINARY_INTEGER;
TYPE itemnum_rec_type IS RECORD
(
 inventory_item_id  NUMBER,
 item_number VARCHAR2(240),
 DESCRIPTION  VARCHAR2(240),
 vendor_part_no  VARCHAR2(240)
);

TYPE itemnum_tbl_type IS TABLE OF itemnum_rec_type INDEX BY BINARY_INTEGER;


TYPE warehouse_rec_type IS RECORD
(
    warehouse_id				NUMBER,
    warehouse_code			VARCHAR2(3),
    Warehouse_Name      VARCHAR2(240)
);

TYPE warehouse_tbl_type IS TABLE OF warehouse_rec_type INDEX BY BINARY_INTEGER;

TYPE dpp_inv_hdr_rec_type IS RECORD
(
  org_id	NUMBER,
  effective_start_date	DATE,
  effective_end_date	DATE,
  currency_code	VARCHAR2(15)
);

TYPE dpp_inv_cov_rct_rec_type IS RECORD
(
    Date_Received           DATE,
    Onhand_quantity	        NUMBER
);

TYPE dpp_inv_cov_rct_tbl_type IS TABLE OF dpp_inv_cov_rct_rec_type INDEX BY BINARY_INTEGER;

TYPE dpp_inv_cov_wh_rec_type IS RECORD
(
    warehouse_id				NUMBER,
    Warehouse_Name           VARCHAR2(240),
    Covered_quantity	        NUMBER,
    rct_line_tbl             dpp_inv_cov_rct_tbl_type
);

TYPE dpp_inv_cov_wh_tbl_type IS TABLE OF dpp_inv_cov_wh_rec_type INDEX BY BINARY_INTEGER;

TYPE dpp_inv_cov_rec_type IS RECORD
(
    Transaction_Line_Id			NUMBER,
    Inventory_ITem_ID					NUMBER,
    UOM_Code									VARCHAR2(3),
    Onhand_Quantity           NUMBER,
    Covered_quantity	        NUMBER,
    wh_line_tbl             dpp_inv_cov_wh_tbl_type
);

TYPE dpp_inv_cov_tbl_type IS TABLE OF dpp_inv_cov_rec_type INDEX BY BINARY_INTEGER;

TYPE inventorydetails_rec_type IS RECORD
(
    Transaction_Line_Id			NUMBER,
    Inventory_Item_ID					NUMBER,
    UOM_Code									VARCHAR2(3),
    Onhand_Quantity           NUMBER,
    Covered_quantity	        NUMBER
);

TYPE inventorydetails_tbl_type IS TABLE OF inventorydetails_rec_type INDEX BY BINARY_INTEGER;

TYPE dpp_cust_inv_rec_type IS RECORD
(
    Customer_ID								NUMBER,
    Inventory_Item_ID					NUMBER,
    UOM_Code									VARCHAR2(3),
    Onhand_Quantity           NUMBER
);

TYPE dpp_cust_inv_tbl_type IS TABLE OF dpp_cust_inv_rec_type INDEX BY BINARY_INTEGER;

TYPE dpp_cust_price_rec_type IS RECORD
(
  Customer_ID	          NUMBER,
  Inventory_Item_ID	  NUMBER,
  UOM_Code		  VARCHAR2(15),
  Last_Price              NUMBER,
  invoice_currency_code    VARCHAR2(15),
  price_change            NUMBER,
  converted_price_change  NUMBER
);

TYPE dpp_cust_price_tbl_type IS TABLE OF dpp_cust_price_rec_type INDEX BY BINARY_INTEGER;

TYPE dpp_list_price_rec_type IS RECORD
(
    Inventory_Item_ID					NUMBER,
    List_Price						NUMBER
);

TYPE dpp_list_price_tbl_type IS TABLE OF dpp_list_price_rec_type INDEX BY BINARY_INTEGER;

PROCEDURE search_vendors(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_vendor_tbl OUT NOCOPY vendor_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   );

PROCEDURE search_vendor_sites(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_vendor_site_tbl OUT NOCOPY vendor_site_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   );

PROCEDURE search_vendor_contacts(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_vendor_contact_tbl OUT NOCOPY vendor_contact_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   );

PROCEDURE search_items(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_item_tbl OUT NOCOPY itemnum_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   );

PROCEDURE search_customer_items(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_item_tbl OUT NOCOPY item_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   );

PROCEDURE search_customer_items_all(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_item_tbl OUT NOCOPY item_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   );

PROCEDURE search_warehouses(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_warehouse_tbl OUT NOCOPY warehouse_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_CoveredInventory(
		p_hdr_rec		IN dpp_inv_hdr_rec_type
	 ,p_covered_inv_tbl	     IN OUT NOCOPY dpp_inv_cov_tbl_type
   ,x_return_status	     OUT 	NOCOPY  VARCHAR2
);

PROCEDURE Get_InventoryDetails(
		p_hdr_rec		IN dpp_inv_hdr_rec_type
	 ,p_inventorydetails_tbl	     IN OUT NOCOPY inventorydetails_tbl_type
	 ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status	     OUT 	  NOCOPY VARCHAR2
);

PROCEDURE Get_CustomerInventory(
		p_hdr_rec			IN dpp_inv_hdr_rec_type
	 ,p_cust_inv_tbl	     IN OUT NOCOPY dpp_cust_inv_tbl_type
	 ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status	     OUT 	  NOCOPY VARCHAR2
);

PROCEDURE search_customers(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_tbl OUT NOCOPY customer_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   );

PROCEDURE search_customers_all(
    p_search_criteria IN  search_criteria_tbl_type
   ,x_customer_tbl OUT NOCOPY customer_tbl_type
   ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status OUT NOCOPY VARCHAR2
   );

PROCEDURE Get_LastPrice(
		p_hdr_rec			IN dpp_inv_hdr_rec_type
	 ,p_cust_price_tbl	IN OUT NOCOPY dpp_cust_price_tbl_type
	 ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status	     OUT 	  NOCOPY VARCHAR2
);

PROCEDURE Get_ListPrice(
		p_hdr_rec			IN dpp_inv_hdr_rec_type
	 ,p_listprice_tbl	     IN OUT NOCOPY dpp_list_price_tbl_type
	 ,x_rec_count	OUT NOCOPY NUMBER
   ,x_return_status	     OUT NOCOPY	  VARCHAR2
);

PROCEDURE Get_Vendor(
	p_vendor_rec IN OUT NOCOPY vendor_rec_type
	,x_rec_count		OUT NOCOPY NUMBER
  ,x_return_status	OUT NOCOPY	  VARCHAR2
);

PROCEDURE Get_Vendor_Site(
	p_vendor_site_rec IN OUT NOCOPY vendor_site_rec_type
	,x_rec_count		OUT NOCOPY NUMBER
  ,x_return_status	OUT NOCOPY	  VARCHAR2
);

PROCEDURE Get_Vendor_Contact(
	 p_vendor_contact_rec IN OUT NOCOPY vendor_contact_rec_type
	,x_rec_count		OUT NOCOPY NUMBER
  ,x_return_status	OUT NOCOPY	  VARCHAR2
);

PROCEDURE Get_Warehouse(
	 p_warehouse_tbl	     	IN OUT NOCOPY warehouse_tbl_type
	 ,x_rec_count		OUT NOCOPY NUMBER
   	,x_return_status	OUT NOCOPY	  VARCHAR2
);

PROCEDURE Get_Customer(
	p_customer_tbl IN OUT NOCOPY customer_tbl_type
	 ,x_rec_count		OUT NOCOPY NUMBER
   	,x_return_status	OUT NOCOPY	  VARCHAR2
);

PROCEDURE Get_Product(
	 p_item_tbl	     	IN OUT NOCOPY item_tbl_type
 	,p_org_id    IN    NUMBER
	 ,x_rec_count		OUT NOCOPY NUMBER
   	,x_return_status	OUT NOCOPY	  VARCHAR2
);


--To be used incase we are storing the log messages in the fnd_log_messages table
--Currently all debug messages are going into the DPP_LOG_MESSAGES table

PROCEDURE debug_message (p_log_level      IN NUMBER DEFAULT FND_LOG.LEVEL_STATEMENT,
                         p_module_name    IN VARCHAR2,
                         p_text           IN VARCHAR2
);

/*
PROCEDURE debug_message(
									    p_message_text   IN  VARCHAR2,
									    p_message_level  IN  NUMBER := NULL
);
*/

PROCEDURE error_message(
   p_message_name VARCHAR2,
   p_token_name   VARCHAR2 := NULL,
   P_token_value  VARCHAR2 := NULL
);

PROCEDURE get_EmailAddress(
	 p_user_id IN NUMBER
	 ,x_email_address	OUT NOCOPY VARCHAR2
   ,x_return_status	OUT NOCOPY	  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_Currency
-- NOTE

-- HISTORY
--parameter p_from_currency      IN  VARCHAR2,
--   p_to_currency        IN  VARCHAR2,
--   p_conv_date          IN  DATE DEFAULT SYSDATE,
--   p_from_amount        IN  NUMBER,
--   x_to_amount          OUT NUMBER
--    If x_conversion_type = 'User', and the relationship between the
--    two currencies is not fixed, x_user_rate will be used as the
--    conversion rate to convert the amount
--    else no_user_rate is required
---------------------------------------------------------------------

PROCEDURE convert_currency(
   p_from_currency   IN       VARCHAR2
  ,p_to_currency     IN       VARCHAR2
  ,p_conv_type       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  ,p_conv_rate       IN       NUMBER   DEFAULT FND_API.G_MISS_NUM
  ,p_conv_date       IN       DATE     DEFAULT SYSDATE
  ,p_from_amount     IN       NUMBER
  ,x_return_status   OUT NOCOPY      VARCHAR2
  ,x_to_amount       OUT NOCOPY      NUMBER
  ,x_rate            OUT NOCOPY      NUMBER);

---------------------------------------------------------------------
-- PROCEDURE
--    Convert_functional_Curr
-- NOTE
-- This procedures takes in amount and converts it to the functional currency
--  and returns the converted amount,exchange_rate,set_of_book_id,
--  f-nctional_currency_code,exchange_rate_date

-- HISTORY

--parameter x_Amount1 IN OUT NUMBER -- reqd Parameter -- amount to be converted
--   x_TC_CURRENCY_CODE IN OUT VARCHAR2,
--   x_Set_of_books_id OUT NUMBER,
--   x_MRC_SOB_TYPE_CODE OUT NUMBER, 'P' and 'R'
--     We only do it for primary ('P' because we donot supprot MRC)
--   x_FC_CURRENCY_CODE OUT VARCHAR2,
--   x_EXCHANGE_RATE_TYPE OUT VARCHAR2,
--     comes from a DPP profile  or what ever is passed
--   x_EXCHANGE_RATE_DATE  OUT DATE,
--     could come from a DPP profile but right now is sysdate
--   x_EXCHANGE_RATE       OUT VARCHAR2,
--   x_return_status      OUT VARCHAR2
-- The following is the rule in the GL API
--    If x_conversion_type = 'User', and the relationship between the
--    two currencies is not fixed, x_user_rate will be used as the
--    conversion rate to convert the amount
--    else no_user_rate is required

---------------------------------------------------------------------


PROCEDURE calculate_functional_curr(
   p_from_amount          IN       NUMBER
  ,p_conv_date            IN       DATE DEFAULT SYSDATE
  ,p_tc_currency_code     IN       VARCHAR2
  ,p_org_id               IN       NUMBER DEFAULT NULL
  ,x_to_amount            OUT NOCOPY      NUMBER
  ,x_set_of_books_id      OUT NOCOPY      NUMBER
  ,x_mrc_sob_type_code    OUT NOCOPY      VARCHAR2
  ,x_fc_currency_code     OUT NOCOPY      VARCHAR2
  ,x_exchange_rate_type   IN OUT NOCOPY   VARCHAR2
  ,x_exchange_rate        IN OUT NOCOPY   NUMBER
  ,x_return_status        OUT NOCOPY      VARCHAR2);

PROCEDURE check_Transaction(
   p_transaction_header_id     IN NUMBER
  ,p_status_change             IN VARCHAR2
  ,x_rec_count                 OUT NOCOPY NUMBER
  ,x_msg_data                  OUT NOCOPY VARCHAR2
  ,x_return_status             OUT NOCOPY VARCHAR2);
END DPP_UTILITY_PVT;


/
