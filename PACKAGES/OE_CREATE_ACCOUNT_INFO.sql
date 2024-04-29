--------------------------------------------------------
--  DDL for Package OE_CREATE_ACCOUNT_INFO
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_CREATE_ACCOUNT_INFO" AUTHID CURRENT_USER AS
/* $Header: OEXCACTS.pls 120.2 2006/07/21 13:47:21 mbhoumik noship $ */


--  API Operation control flags.
TYPE Control_Rec_Type IS RECORD
(
  p_allow_account_creation  varchar2(20):='CHECK'--ALL,SITE_AND_CONTACT,NONE,
                                                 --CHECK and NULL
 ,p_init_msg_list   boolean := FALSE
 ,p_commit          BOOLEAN := TRUE
 ,p_multiple_account_is_error BOOLEAN :=TRUE
 ,p_multiple_contact_is_error BOOLEAN :=TRUE
 --Created_by_Module for creating tca entities
 --IT should be ONT_<STARTUP_MODE>_AUTOMATIC_ACCOUNT
 ,p_created_by_module varchar2(150)
-- This is applicable to contact. If the search contact
-- fails then we need to still continue and find the site
 ,p_continue_processing_on_error boolean := FALSE
-- control parameters.When we call this api again due to lov or ..
-- we do not want to check the previous entities again
 ,p_process_customer boolean := TRUE
 ,p_process_contact  boolean := TRUE
-- This is to return without processing if no accounts found and there
-- is no site information for the party. In this scenario for telesales
-- we will take the user to the add customer form
 ,p_return_if_only_party boolean :=TRUE

-- this determines if we need to give higher preceden to primary party sites
-- compared to the address actually passed. This is done for Contact Center
-- integration
 ,p_fetch_primary_party_sites boolean :=FALSE

-- This flag is to ignore Value To Id process in AAC. The default value is TRUE
-- so that the process order will always do it. We should not do this for
-- Telesales and Teleservice integration
 ,p_do_value_to_id boolean :=TRUE

-- This flag is done for the Contact Center Integration.
-- The processing returns from the AAC if the Customer is found and when cust
-- is NOT Created. This is to facilitate the scenario where we need to call
-- defaulting after an account is identified if we need to give higher
-- precedence to defaulting over the address passed
 ,p_return_if_customer_found boolean :=FALSE

);

--  Variable representing missing control record.
G_MISS_CONTROL_REC            Control_Rec_Type;

TYPE party_customer_rec IS RECORD
(
 p_party_id number := null -- can be customer or contacts party_id
,p_party_number varchar2(30) := null
,p_cust_account_id  number := null
,p_cust_account_number  varchar2(30) := null

-- only contact attributes
,p_org_contact_id number := null
,p_cust_account_role_id number := null

-- value columns for value-to-id conversion
,p_party_name varchar(360)
,p_contact_name varchar(383)


-- this determines if the account is created in AAC or found an existing account
,p_account_created_or_found varchar2(50) := 'FOUND'

);

-- Variable Representing missing party_customer_Rec
G_MISS_PARTY_CUSTOMER_REC party_customer_rec;


TYPE site_rec IS RECORD
(
-- site_use_code is mandatory even if party_site_use_id is passed
-- as STMTS party_site_use can still become an account site of bill,ship,deliver
 p_site_use_code varchar2(30) := null
,p_party_site_id number := null
,p_party_site_use_id number := null
,p_site_use_id number
,p_cust_acct_site_id number
,p_create_primary_acct_site_use boolean
,p_process_site  boolean := TRUE

--Site Customer Information
,p_party_id number := null -- customer party_id
,p_party_number varchar2(30) := null
,p_cust_account_id  number := null
,p_cust_account_number  varchar2(30) := null

-- contact attributes
,p_org_contact_id number := null
,p_cust_account_role_id number := null
,p_create_responsibility boolean := FALSE
,p_assign_contact_to_site boolean:=FALSE

-- value columns for value-to-id conversion
,p_party_name varchar2(360)
,p_contact_name varchar2(383)

-- value columns for site_use
,p_site_address1          VARCHAR2(240)
,p_site_address2          VARCHAR2(240)
,p_site_address3          VARCHAR2(240)
,p_site_address4          VARCHAR2(240)
,p_site_org               VARCHAR2(240)
,p_site_city              VARCHAR2(240)
,p_site_state             VARCHAR2(240)
,p_site_postal_code       VARCHAR2(240)
,p_site_country           VARCHAR2(240)
,p_site_customer_id       number
 );


TYPE customer_rec IS RECORD
(
 p_cust_account_id number
,p_customer_name varchar2(360)
,p_email_address varchar2(2000)
,p_gsa_indicator varchar2(1)
,p_account_number varchar2(30)
);


-- Table structure to store site attribues
TYPE customer_tbl IS TABLE OF Customer_rec
    INDEX BY BINARY_INTEGER;


-- Table structure to store site attribues
TYPE Site_tbl_type IS TABLE OF Site_rec
    INDEX BY BINARY_INTEGER;

--  Missing Site Table type
G_MISS_SITE_TBL	Site_tbl_type;

-- Table structure to store site attribues
TYPE Account_tbl IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;


-- Table structure to store site attribues
TYPE Contact_Tbl IS TABLE OF NUMBER
    INDEX BY BINARY_INTEGER;

--  Start of Comments
--  API name    Crate_Account_Layer
--  Type        Private
--  Function    Automatic creation of Account Layer from Party Layer
--
--  Pre-reqs
--
--  Parameters
--
--  Notes
--
--  End of Comments

PROCEDURE Create_Account_Layer(
 p_control_rec        IN  Control_Rec_Type := G_MISS_CONTROL_REC
,x_return_status      OUT NOCOPY VARCHAR2
,x_msg_count          OUT NOCOPY NUMBER
,x_msg_data           OUT NOCOPY VARCHAR2
,p_party_customer_rec IN OUT NOCOPY /* file.sql.39 change */ Party_customer_rec
,p_site_tbl     IN OUT NOCOPY /* file.sql.39 change */  site_tbl_type
,p_account_tbl        OUT  NOCOPY account_tbl
,p_contact_tbl        OUT  NOCOPY contact_tbl
);



PROCEDURE Check_and_Create_Account(
    p_party_id in number
   ,p_party_number in varchar2
   ,p_allow_account_creation in boolean
   ,p_multiple_account_is_error in boolean
   ,p_account_tbl out NOCOPY account_tbl
   ,p_out_org_contact_id out NOCOPY number
   ,p_out_cust_account_role_id out NOCOPY number
   ,x_return_status     OUT   NOCOPY   VARCHAR2
   ,x_msg_count         OUT NOCOPY     NUMBER
   ,x_msg_data          OUT NOCOPY     VARCHAR2
   ,p_site_tbl_count    IN number
   ,p_return_if_only_party in boolean
  );


  PROCEDURE Check_and_Create_Contact(
    p_party_id in number
   ,p_cust_account_id in number
   ,p_org_contact_id in number
   ,P_site_use_code in varchar2
   ,p_allow_contact_creation in boolean
   ,p_create_responsibility in boolean
   ,p_cust_account_role_id in out NOCOPY /* file.sql.39 change */ number
   ,p_cust_account_site_id in number
   ,p_assign_contact_to_site in boolean
   ,p_multiple_account_is_error in boolean
   ,p_multiple_contact_is_error in boolean
   ,p_contact_tbl out NOCOPY contact_tbl
   ,p_multiple_account out NOCOPY boolean
   ,x_return_status     OUT  NOCOPY    VARCHAR2
   ,x_msg_count         OUT  NOCOPY    NUMBER
   ,x_msg_data          OUT  NOCOPY    VARCHAR2
  );


PROCEDURE Check_and_Create_Sites (
				  p_party_id in number
				  ,p_cust_account_id in number
				  ,p_site_tbl in out NOCOPY /* file.sql.39 change */ site_tbl_Type
				  ,p_allow_site_creation in boolean
				  ,p_continue_on_error in boolean
				  -- this expects either party_site_use_id or site_use_code and party_site_id
				  ,x_return_status out NOCOPY varchar2
				  ,x_msg_data out NOCOPY varchar2
				  ,x_msg_count out NOCOPY varchar2
				  );

PROCEDURE set_debug_on ;

PROCEDURE if_multiple_accounts(
                                p_party_id in number
                               ,p_party_number varchar2
                               ,p_account_Tbl out NOCOPY account_tbl
                               ,x_return_status out NOCOPY varchar2
                               ,x_msg_data out NOCOPY varchar2
                               ,x_msg_count out NOCOPY number
                               );


PROCEDURE Value_to_id(
		      p_party_customer_rec      IN OUT  NOCOPY Party_customer_rec
		      ,p_site_tbl               IN OUT  NOCOPY site_tbl_type
		      ,p_permission             IN         varchar2
		      ,x_return_status          OUT NOCOPY VARCHAR2
		      ,x_msg_count          OUT NOCOPY NUMBER
		      ,x_msg_data           OUT NOCOPY VARCHAR2
		      );

PROCEDURE find_sold_to_id(
			   p_party_id                IN OUT NOCOPY number
			  ,p_cust_account_id        in OUT NOCOPY number
			  ,p_party_name             IN     varchar2
			  ,p_cust_account_number    IN     varchar2
			  ,p_party_number           IN     varchar2
			  ,p_permission             IN     varchar2
			  ,p_site_use_id            IN OUT NOCOPY number
			  ,p_party_site_id          IN OUT NOCOPY number
			  ,p_party_site_use_id      IN OUT NOCOPY number
			  ,p_party_site_use_code    IN  varchar2 DEFAULT NULL
			  ,p_process_site           IN OUT NOCOPY boolean
			  ,x_return_status          OUT NOCOPY varchar2
			  );

procedure find_contact_id(
			  p_contact_id        IN OUT NOCOPY number
			  ,p_cust_contact_id  in out NOCOPY number
			  ,p_contact_name     IN varchar2
			  ,p_permission       in varchar2
			  ,p_sold_to_org_id   in number
			  ,p_site_use_id      in number
			  ,p_party_id         in number
			  ,p_site_use_code     in varchar2 default null
			  ,x_return_status    OUT NOCOPY VARCHAR2
			  );

procedure find_site_id(
		       p_site_use_id          IN OUT NOCOPY number
		       ,p_site_id             IN OUT NOCOPY number
		       ,p_account_site_use_id in out NOCOPY number
		       ,p_site_use_code       in varchar2
		       ,p_site_address1       in VARCHAR2
		       ,p_site_address2       in VARCHAR2
		       ,p_site_address3       in VARCHAR2
		       ,p_site_address4       in VARCHAR2
		       ,p_site_org            in VARCHAR2
		       ,p_site_city           in VARCHAR2
		       ,p_site_state          in VARCHAR2
		       ,p_site_postal_code    in VARCHAR2
		       ,p_site_country        in VARCHAR2
		       ,p_site_customer_id    in number
		       ,p_sold_to_org_id      in number
		       ,p_sold_to_party_id    IN number
		       ,p_party_id            IN out nocopy number
		       ,p_permission          in varchar2
		       ,x_return_status       OUT NOCOPY VARCHAR2
		       ,x_msg_data             out NOCOPY varchar2
		       ,x_msg_count            out NOCOPY varchar2
		       );

FUNCTION get_party_id(
		      p_party_name    in varchar2
		      ,p_party_number in varchar2
		      ,p_party_site_use_code in varchar2
		      ) return number;

FUNCTION get_party_contact_id(
			      p_contact_name    in varchar2
			      ,p_party_id       in number
			      ,p_sold_to_org_id in number
			      ) return number;

FUNCTION get_party_site_id(
			   p_site_address1      IN  VARCHAR2
			   ,p_site_address2     IN  VARCHAR2
			   ,p_site_address3     IN  VARCHAR2
			   ,p_site_address4     IN  VARCHAR2
			   ,p_site_location     IN  VARCHAR2
			   ,p_site_org          IN  VARCHAR2
			   ,p_sold_to_party_id  IN  number
			   ,p_site_city         IN  VARCHAR2
			   ,p_site_state        IN  VARCHAR2
			   ,p_site_postal_code  IN  VARCHAR2
			   ,p_site_country      IN  VARCHAR2
			   ,p_site_customer_id  IN  VARCHAR2
			   ,p_site_use_code     IN  VARCHAR2
			   ,p_party_id          IN  number
			   ) return number;

FUNCTION Sold_To_Org(
		     p_sold_to_org                   IN  VARCHAR2
		     ,   p_customer_number               IN  VARCHAR2
		     , p_site_use_code   IN VARCHAR2
		     ) RETURN NUMBER;

FUNCTION CUST_EXISTS(cust_id number) return Boolean;

END oe_create_account_info;


 

/
