--------------------------------------------------------
--  DDL for Package OE_CUSTOMER_INFO_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CUSTOMER_INFO_PVT" AUTHID CURRENT_USER AS
/* $Header: OEXVCUSS.pls 120.0.12010000.2 2008/12/31 08:20:19 smanian noship $ */

G_SOLD_TO_CUSTOMER_ID NUMBER;
G_SOLD_TO_CONTACT_ID  NUMBER;

Procedure get_customer_info_ids
                         (
			  p_customer_info_tbl IN OUT NOCOPY OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE,
                          p_operation_code       IN VARCHAR2,
			  p_sold_to_customer_ref IN VARCHAR2,
			  p_ship_to_customer_ref IN VARCHAR2,
			  p_bill_to_customer_ref IN VARCHAR2,
			  p_deliver_to_customer_ref IN VARCHAR2,

			  p_ship_to_address_ref IN VARCHAR2,
			  p_bill_to_address_ref IN VARCHAR2,
			  p_deliver_to_address_ref IN VARCHAR2,
			  p_sold_to_address_ref    IN VARCHAR2,

			  p_sold_to_contact_ref IN VARCHAR2,
			  p_ship_to_contact_ref IN VARCHAR2,
			  p_bill_to_contact_ref IN VARCHAR2,
			  p_deliver_to_contact_ref IN VARCHAR2,

			  p_sold_to_customer_id IN NUMBER,
			  p_ship_to_customer_id IN NUMBER,
			  p_bill_to_customer_id IN NUMBER,
			  p_deliver_to_customer_id IN NUMBER,

			  p_ship_to_org_id IN NUMBER,
			  p_invoice_to_org_id IN NUMBER,
			  p_deliver_to_org_id IN NUMBER,
			  p_sold_to_site_use_id IN NUMBER,

			  p_sold_to_contact_id IN NUMBER,
			  p_ship_to_contact_id IN NUMBER,
			  p_invoice_to_contact_id IN NUMBER,
			  p_deliver_to_contact_id IN NUMBER,

			  x_sold_to_customer_id OUT NOCOPY  NUMBER,
			  x_ship_to_customer_id OUT NOCOPY  NUMBER,
			  x_bill_to_customer_id OUT NOCOPY  NUMBER,
			  x_deliver_to_customer_id OUT NOCOPY  NUMBER,

			  x_ship_to_org_id OUT NOCOPY  NUMBER,
			  x_invoice_to_org_id OUT NOCOPY  NUMBER,
			  x_deliver_to_org_id OUT NOCOPY  NUMBER,
			  x_sold_to_site_use_id OUT NOCOPY NUMBER,

			  x_sold_to_contact_id OUT NOCOPY  NUMBER,
			  x_ship_to_contact_id OUT NOCOPY  NUMBER,
			  x_invoice_to_contact_id OUT NOCOPY  NUMBER,
			  x_deliver_to_contact_id OUT NOCOPY  NUMBER,


			  x_return_status   OUT NOCOPY VARCHAR2,
			  x_msg_count       OUT NOCOPY NUMBER,
			  x_msg_data        OUT NOCOPY VARCHAR2
			  );


Procedure Create_account (p_header_customer_info_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE,
                          x_party_id        OUT NOCOPY NUMBER,
			  x_cust_account_id OUT NOCOPY NUMBER,
			  x_return_status   OUT NOCOPY VARCHAR2,
			  x_msg_count       OUT NOCOPY NUMBER,
			  x_msg_data        OUT NOCOPY VARCHAR2
			  );

Procedure Create_relationships (p_sold_to_customer_id IN NUMBER,
                                p_ship_to_customer_id NUMBER DEFAULT NULL,
                                p_bill_to_customer_id NUMBER DEFAULT NULL,
                                p_deliver_to_cust_id NUMBER DEFAULT NULL,
			        x_return_status   OUT NOCOPY VARCHAR2,
				x_msg_count       OUT NOCOPY NUMBER,
			        x_msg_data        OUT NOCOPY VARCHAR2
			  );



Procedure Create_Addresses (
                            p_customer_info_tbl IN OUT NOCOPY OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE
			  , p_operation_code      IN VARCHAR2
			  , p_sold_to_customer_id IN NUMBER
			  , p_ship_to_customer_id IN NUMBER
			  , p_bill_to_customer_id IN NUMBER
			  , p_deliver_to_customer_id IN NUMBER
			  , p_customer_id       IN NUMBER
                          , p_address_rec_index  IN NUMBER
			  , p_address_usage      IN VARCHAR2
			  , x_ship_to_org_id  IN OUT NOCOPY NUMBER
			  , x_invoice_to_org_id IN OUT NOCOPY NUMBER
			  , x_deliver_to_org_id IN OUT NOCOPY NUMBER
			  , x_sold_to_site_use_id IN OUT NOCOPY NUMBER
  		          , x_return_status   OUT NOCOPY VARCHAR2
			  , x_msg_count       OUT NOCOPY NUMBER
			  , x_msg_data        OUT NOCOPY VARCHAR2
			  );

Procedure Create_Party_Site
		(  p_party_id IN NUMBER,
		   p_address_rec     IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE,
x_location_id OUT NOCOPY NUMBER,
x_party_site_id OUT NOCOPY NUMBER,
x_return_status OUT NOCOPY VARCHAR2,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2 );



PROCEDURE Create_Cust_Account_Site
		(  p_party_site_id IN NUMBER,
		   p_cust_account_id IN NUMBER,
		   p_address_rec     IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE,
x_cust_account_site_id OUT NOCOPY NUMBER,
x_return_status OUT NOCOPY VARCHAR2,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2 );

PROCEDURE Create_Acct_Site_Uses
(
p_cust_acct_site_id  IN NUMBER,
p_location_number    IN VARCHAR2,
p_site_use_code      IN VARCHAR2,
x_site_use_id OUT NOCOPY NUMBER,
x_return_status OUT NOCOPY VARCHAR2,
x_msg_count OUT NOCOPY NUMBER,
x_msg_data OUT NOCOPY VARCHAR2
);


Procedure Create_Contact (  p_customer_info_tbl IN OE_ORDER_PUB.CUSTOMER_INFO_TABLE_TYPE
			  , p_operation_code   IN VARCHAR2
			  , p_customer_id IN        NUMBER
                          , p_customer_rec_index IN NUMBER
			  , p_usage_code      IN VARCHAR2
			  , x_sold_to_contact_id IN OUT NOCOPY NUMBER
			  , x_ship_to_contact_id IN OUT NOCOPY NUMBER
			  , x_invoice_to_contact_id IN OUT NOCOPY NUMBER
			  , x_deliver_to_contact_id IN OUT NOCOPY NUMBER
  		          , x_return_status   OUT NOCOPY VARCHAR2
			  , x_msg_count       OUT NOCOPY NUMBER
			  , x_msg_data        OUT NOCOPY VARCHAR2
			  );

Function check_relation_exists (  p_customer_id IN NUMBER
				  ,p_rel_customer_id NUMBER ) RETURN BOOLEAN;

Procedure Check_Party_Site_Exists( p_party_id IN NUMBER,
                          	    p_address_rec     IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE,
				    x_party_site_id OUT NOCOPY NUMBER
				    );


Procedure Check_Cust_Site_Exists ( p_party_site_id IN NUMBER,
				   p_cust_account_id IN NUMBER,
				   x_cust_acct_site_id OUT NOCOPY NUMBER
				  );



Procedure Check_Customer_Fields (p_customer_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                 ,x_return_status OUT NOCOPY VARCHAR2 );
Procedure Validate_Customer_Fields (p_customer_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                   ,x_return_status OUT NOCOPY VARCHAR2 );

Procedure Check_Duplicate_Customer (  p_customer_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
				    , p_type            IN VARCHAR2
                                    , x_customer_id  OUT NOCOPY VARCHAR2
				   );


Procedure Check_Address_Fields  (p_address_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                 ,x_return_status OUT NOCOPY VARCHAR2 );
Procedure Validate_Address_Fields (p_address_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                  ,x_return_status OUT NOCOPY VARCHAR2 );
Procedure Check_Duplicate_Address ( p_address_record   IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                  , p_sold_to_org_id   IN NUMBER
				  , p_site_customer_id IN NUMBER
				  , p_site_usage       IN VARCHAR2
				  , x_site_usage_id    OUT NOCOPY NUMBER
                                  );

Procedure Value_To_Id_Address    ( p_address_record   IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                  , p_sold_to_org_id   IN NUMBER
				  , p_site_customer_id IN NUMBER
				  , p_site_usage       IN VARCHAR2
				  , x_site_usage_id    OUT NOCOPY NUMBER
				 );
Procedure Value_To_Id_contact     ( p_contact_record   IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                  , p_customer_id   IN NUMBER
				  , p_site_usage_code       IN VARCHAR2
				  , p_site_usage_id    OUT NOCOPY NUMBER
				  , x_contact_id       OUT NOCOPY NUMBER
				 );

Procedure Check_Contact_Fields    (p_contact_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                   ,x_return_status OUT NOCOPY VARCHAR2 );
Procedure Validate_Contact_Fields (p_contact_record IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                                   ,x_return_status OUT NOCOPY VARCHAR2 );




Function IS_BOTH_ID_VAL_PASSED ( p_customer_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE)
RETURN BOOLEAN;

Function IS_BOTH_ID_VAL_PASSED ( p_address_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE)
RETURN BOOLEAN;

Function IS_BOTH_ID_VAL_PASSED ( p_contact_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE)
RETURN BOOLEAN;


FUNCTION Get_obj_version_number( p_location_id IN NUMBER DEFAULT NULL
			       , p_cust_account_id IN NUMBER DEFAULT NULL
			       , p_party_id IN NUMBER DEFAULT NULL ) RETURN NUMBER;

Procedure Update_Location (  p_address_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
                           , p_site_use_id IN NUMBER
			   , p_site_usage_code IN VARCHAR2
			   , x_return_status OUT NOCOPY VARCHAR2
			   , x_msg_count OUT NOCOPY NUMBER
			   , x_msg_data  OUT NOCOPY VARCHAR2
			   );


Procedure Update_Customer ( p_customer_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
	  		   , x_return_status OUT NOCOPY VARCHAR2 );

PROCEDURE Update_Contact  ( p_contact_rec IN OE_ORDER_PUB.CUSTOMER_INFO_REC_TYPE
			   , x_return_status  OUT NOCOPY VARCHAR2
			   , x_msg_count      OUT NOCOPY NUMBER
			   , x_msg_data       OUT NOCOPY VARCHAR2
			   );



FUNCTION IS_VALID_ID ( p_party_id IN NUMBER DEFAULT NULL ,
		       p_customer_id IN NUMBER DEFAULT NULL ) RETURN BOOLEAN ;

Function Get_Party_ID ( p_cust_acct_id IN NUMBER) RETURN NUMBER;

PROCEDURE Check_site_usage_exists ( p_cust_acct_site_id IN NUMBER
				    ,p_site_usage         IN VARCHAR2
				    ,x_site_use_id        OUT NOCOPY NUMBER);

FUNCTION Get_Party_Type ( p_party_id IN NUMBER )RETURN VARCHAR2;

Function Get_Location_id( p_cust_acct_site_id IN NUMBER DEFAULT NULL)
RETURN NUMBER;


Function Get_Location_id (  p_site_usage_code IN VARCHAR2 DEFAULT NULL
                          , p_site_use_id     IN NUMBER DEFAULT NULL)RETURN NUMBER;

END OE_CUSTOMER_INFO_PVT;

/
