--------------------------------------------------------
--  DDL for Package DPP_UIWRAPPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."DPP_UIWRAPPER_PVT" AUTHID CURRENT_USER as
/* $Header: dppvuiws.pls 120.11.12010000.6 2010/03/26 12:23:44 rvkondur ship $ */

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
 description  VARCHAR2(240),
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
  org_id								NUMBER,
  effective_start_date	DATE,
  effective_end_date		DATE,
  currency_code					VARCHAR2(15)
);

TYPE dpp_inv_cov_rct_rec_type IS RECORD
(
    Date_Received           DATE,
    Onhand_quantity	        NUMBER
);

TYPE dpp_inv_cov_rct_tbl_type IS TABLE OF dpp_inv_cov_rct_rec_type INDEX BY BINARY_INTEGER;

TYPE inventorydetails_rec_type IS RECORD
(
    Transaction_Line_Id				NUMBER,
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
    List_Price								NUMBER
);

TYPE dpp_list_price_tbl_type IS TABLE OF dpp_list_price_rec_type INDEX BY BINARY_INTEGER;

-- for AME
TYPE approval_rec_type IS RECORD (
    OBJECT_TYPE           VARCHAR2(30)
   ,OBJECT_ID             NUMBER
   ,STATUS_CODE           VARCHAR2(30)
   ,ACTION_CODE           VARCHAR2(30)
   ,ACTION_PERFORMED_BY   NUMBER    -- fnd user_id
);

TYPE approverRecord is record(
    user_id number,
    person_id number,
    first_name varchar2(150),
    last_name varchar2(150),
    api_insertion varchar2(1),
    authority varchar2(1),
    approval_status varchar2(50),
    approval_type_id number,
    group_or_chain_id number,
    occurrence number,
    source varchar2(500),
    approver_sequence number,
    approver_email varchar2(240),
    approver_group_name varchar2(50)
    );

TYPE approversTable IS TABLE OF approverRecord INDEX BY BINARY_INTEGER;

TYPE dpp_txn_hdr_rec_type IS RECORD
(
    Transaction_Header_ID   NUMBER,
    Transaction_number      VARCHAR2(240),
    Process_code            VARCHAR2(240),
    claim_id                NUMBER,
    claim_type_flag         VARCHAR2(30),
    claim_creation_source   VARCHAR2(20)
);


TYPE dpp_txn_line_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
---

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

--- for AME

PROCEDURE Get_AllApprovers(
    p_api_version       IN  NUMBER
   ,p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE
   ,p_validation_level  IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

   ,x_return_status     OUT NOCOPY VARCHAR2
   ,x_msg_data          OUT NOCOPY VARCHAR2
   ,x_msg_count         OUT NOCOPY NUMBER

   ,p_approval_rec        IN  approval_rec_type
   ,p_approversOut        OUT NOCOPY approversTable
);

PROCEDURE  Process_User_Action (
   p_api_version            IN  NUMBER
  ,p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE
  ,p_commit                 IN  VARCHAR2 := FND_API.G_FALSE
  ,p_validation_level       IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL

  ,x_return_status          OUT NOCOPY   VARCHAR2
  ,x_msg_data               OUT NOCOPY   VARCHAR2
  ,x_msg_count              OUT NOCOPY   NUMBER

  ,p_approval_rec           IN  approval_rec_type
  ,p_approver_id            IN  NUMBER
  ,x_final_approval_flag    OUT NOCOPY VARCHAR2
);

PROCEDURE Raise_Business_Event(
	 p_api_version   	 IN 	        NUMBER
  	,p_init_msg_list	 IN 	        VARCHAR2     := FND_API.G_FALSE
   	,p_commit	         IN 	        VARCHAR2     := FND_API.G_FALSE
   	,p_validation_level	 IN 	        NUMBER       := FND_API.G_VALID_LEVEL_FULL

   	,x_return_status	 OUT NOCOPY     VARCHAR2
        ,x_msg_count	         OUT NOCOPY     NUMBER
        ,x_msg_data	         OUT NOCOPY     VARCHAR2

   	,p_txn_hdr_rec           IN       dpp_txn_hdr_rec_type
        ,p_txn_line_id           IN       dpp_txn_line_tbl_type
     );
  PROCEDURE check_transaction(
   p_transaction_header_id     IN NUMBER
  ,p_status_change             IN VARCHAR2
  ,x_rec_count                 OUT NOCOPY NUMBER
  ,x_msg_data                  OUT NOCOPY VARCHAR2
  ,x_return_status             OUT NOCOPY VARCHAR2
  );
  PROCEDURE convert_currency(
   p_from_currency   IN       VARCHAR2
  ,p_to_currency     IN       VARCHAR2
  ,p_conv_type       IN       VARCHAR2 DEFAULT FND_API.G_MISS_CHAR
  ,p_conv_rate       IN       NUMBER   DEFAULT FND_API.G_MISS_NUM
  ,p_conv_date       IN       DATE     DEFAULT SYSDATE
  ,p_from_amount     IN       NUMBER
  ,x_return_status   OUT NOCOPY      VARCHAR2
  ,x_to_amount       OUT NOCOPY      NUMBER
  ,x_rate            OUT NOCOPY      NUMBER
  );
END DPP_UIWRAPPER_PVT;

/
