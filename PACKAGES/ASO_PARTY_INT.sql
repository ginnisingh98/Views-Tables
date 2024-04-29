--------------------------------------------------------
--  DDL for Package ASO_PARTY_INT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_PARTY_INT" AUTHID CURRENT_USER as
/* $Header: asoiptys.pls 120.2.12010000.3 2010/07/23 05:57:57 vidsrini ship $ */
-- Start of Comments
-- Package name     : ASO_PARTY_INT
-- Purpose          :
--   This package contains specification of pl/sql records/tables and the
--   private APIs for validation in Order Capture.
--
--   Record Type:
--   Party_Rec_Type
--   Location_Rec_Type
--   Party_Site_Rec_Type
--   Org_Contact_Rec_Type
--
-- History          :

-- NOTE             :
-- Change History : Made by Suyog Kulkarni 10/15/2002
--Removed the following procedures as they are no longer being used:
--1) Create_Org_Contact
--2) Create_Contact_Points
--3)Create_Contact_Restriction
--4) Update_Party_Site
--5) update_Org_Contact
--6) Update_Contact_Points
--7) Update_Contact_Restriction
-- End of Comments


TYPE Party_Rec_Type IS RECORD
(
       PARTY_ID                        NUMBER := FND_API.G_MISS_NUM,
       PARTY_TYPE		       VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PARTY_NAME		       VARCHAR2(360) := FND_API.G_MISS_CHAR,
       CURR_FY_POTENTIAL_REVENUE       NUMBER := FND_API.G_MISS_NUM,
       NUM_OF_EMPLOYEES                NUMBER := FND_API.G_MISS_NUM,
       PERSON_TITLE                    VARCHAR2(60)  := FND_API.G_MISS_CHAR,
       PERSON_FIRST_NAME	       VARCHAR2(150) := FND_API.G_MISS_CHAR,
       PERSON_MIDDLE_NAME	       VARCHAR2(60) := FND_API.G_MISS_CHAR,
       PERSON_LAST_NAME                VARCHAR2(150) := FND_API.G_MISS_CHAR,
       PERSON_KNOWN_AS                 VARCHAR2(80) := FND_API.G_MISS_CHAR,
       DATE_OF_BIRTH                   DATE := FND_API.G_MISS_DATE,
       PERSONAL_INCOME                 NUMBER := FND_API.G_MISS_NUM,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
       TOTAL_NUM_OF_ORDERS             NUMBER := FND_API.G_MISS_NUM
);
G_Miss_Party_Rec	  Party_Rec_Type;


TYPE Location_Rec_Type IS RECORD
(
       LOCATION_ID		NUMBER := FND_API.G_MISS_NUM,
       ADDRESS1			VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ADDRESS2			VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ADDRESS3			VARCHAR2(240) := FND_API.G_MISS_CHAR,
       ADDRESS4			VARCHAR2(240) := FND_API.G_MISS_CHAR,
       COUNTRY_CODE		VARCHAR2(10) := FND_API.G_MISS_CHAR,
       COUNTRY			VARCHAR2(60) := FND_API.G_MISS_CHAR,
       CITY			VARCHAR2(60) := FND_API.G_MISS_CHAR,
       POSTAL_CODE		VARCHAR2(60) := FND_API.G_MISS_CHAR,
       STATE			VARCHAR2(60) := FND_API.G_MISS_CHAR,
       PROVINCE			VARCHAR2(60) := FND_API.G_MISS_CHAR,
       COUNTY			VARCHAR2(60) := FND_API.G_MISS_CHAR,
    LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE

);
G_MISS_Location_Rec	Location_Rec_Type;


TYPE Party_Site_Rec_Type IS RECORD
(
       party_site_use_id      NUMBER := FND_API.G_MISS_NUM,
       PARTY_SITE_ID		NUMBER := FND_API.G_MISS_NUM,
       PARTY_ID			NUMBER := FND_API.G_MISS_NUM,
       PARTY_SITE_USE_TYPE	VARCHAR2(60) := FND_API.G_MISS_CHAR,
       PRIMARY_FLAG             VARCHAR2(1) := FND_API.G_MISS_CHAR,
       LOCATION		        Location_Rec_Type := G_MISS_Location_Rec,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
	  party_site_last_update_Date DATE := FND_API.G_MISS_DATE

);
G_MISS_Party_Site_Rec	Party_Site_Rec_Type;

TYPE Org_Contact_Rec_Type IS RECORD
(
       CONTACT_ID		NUMBER := FND_API.G_MISS_NUM,
       CONTACT_TITLE            VARCHAR2(60) := FND_API.G_MISS_CHAR,
       CONTACT_FIRST_NAME	VARCHAR2(150) := FND_API.G_MISS_CHAR,
       CONTACT_MIDDLE_NAME      VARCHAR2(60) := FND_API.G_MISS_CHAR,
       CONTACT_LAST_NAME        VARCHAR2(150) := FND_API.G_MISS_CHAR,
       CONTACT_KNOWN_AS         VARCHAR2(80) := FND_API.G_MISS_CHAR,
       CONTACT_ROLE_TYPE	VARCHAR2(60) := FND_API.G_MISS_CHAR,
       job_title		VARCHAR2(100) :=FND_API.G_MISS_CHAR,
       job_title_code		VARCHAR2(30) := FND_API.G_MISS_CHAR,
       PARTY_SITE_ID		NUMBER := FND_API.G_MISS_NUM,
       SUBJECT_ID		NUMBER := FND_API.G_MISS_NUM,
       OBJECT_ID		NUMBER := FND_API.G_MISS_NUM,
	  LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE,
	  rel_last_update_Date       date := FND_API.G_MISS_DATE,
	  org_cont_last_update_Date  DATE := FND_API.G_MISS_DATE

);

TYPE Contact_Point_Rec_Type IS RECORD
(
        contact_point_id NUMBER := FND_API.G_MISS_NUM,
        telephone_type          VARCHAR2(30) := FND_API.G_MISS_CHAR,
        contact_point_type      VARCHAR2(30) := FND_API.G_MISS_CHAR,
        status                  VARCHAR2(10) := FND_API.G_MISS_CHAR,
        owner_table_name        VARCHAR2(200):= FND_API.G_MISS_CHAR,
	owner_table_id		NUMBER := FND_API.G_MISS_NUM,
	email_format		VARCHAR2(30) := FND_API.G_MISS_CHAR,
	email_address		VARCHAR2(2000) := FND_API.G_MISS_CHAR,
	phone_area_code		VARCHAR2(10) := FND_API.G_MISS_CHAR,
	phone_country_code	VARCHAR2(10) := FND_API.G_MISS_CHAR,
	phone_number		VARCHAR2(40) := FND_API.G_MISS_CHAR,
	phone_extension		VARCHAR2(20) := FND_API.G_MISS_CHAR,
        phone_line_type         VARCHAR2(80) := FND_API.G_MISS_CHAR,
	telex_number		VARCHAR2(50) := FND_API.G_MISS_CHAR,
     	url			VARCHAR2(2000) := FND_API.G_MISS_CHAR,
        primary_flag            VARCHAR2(10) := FND_API.G_MISS_CHAR,
        LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE

);

TYPE Out_Contact_Point_Rec_Type IS RECORD
(
	Contact_Point_Type	VARCHAR2(30),
	Contact_Point_Id	NUMBER,
        x_return_status         VARCHAR2(1)
);
TYPE   Out_Contact_Point_Tbl_Type     IS TABLE OF Out_Contact_Point_Rec_Type
                                    INDEX BY BINARY_INTEGER;

TYPE Contact_Restrictions_Rec_Type IS RECORD
(
       Party_Id                       NUMBER,
       Contact_Restriction_Id         NUMBER,
       Restriction_End_Date           DATE,
       Contact_Type                   VARCHAR2(30),
       Subject_Table                  VARCHAR2(30),
       Subject_ID                     NUMBER,
       LAST_UPDATE_DATE                DATE := FND_API.G_MISS_DATE

);

PROCEDURE Create_Party(
        p_party_rec             IN      PARTY_REC_TYPE,
        x_return_status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
        x_msg_count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
        x_party_id              OUT NOCOPY /* file.sql.39 change */   NUMBER);


PROCEDURE Create_Party_Site(
        p_party_site_rec        IN      PARTY_SITE_REC_TYPE,
        x_return_status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
        x_party_site_id         OUT NOCOPY /* file.sql.39 change */   NUMBER,
        x_msg_count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2);

PROCEDURE Update_Party(
        p_party_rec             IN      PARTY_REC_TYPE,
        x_return_status         OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
        x_msg_count             OUT NOCOPY /* file.sql.39 change */   NUMBER,
        x_msg_data              OUT NOCOPY /* file.sql.39 change */   VARCHAR2);


PROCEDURE Validate_CustAccount(
	p_init_msg_list		IN	VARCHAR2,
	p_party_id		IN	NUMBER,
	p_cust_account_id	IN	NUMBER,
	x_return_status	 OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
        x_msg_count	 OUT NOCOPY /* file.sql.39 change */   NUMBER,
        x_msg_data	 OUT NOCOPY /* file.sql.39 change */   VARCHAR2);

-- creates a customer account in hz_cust_accounts_all using a party id.
-- also uses the marketing source code id if passed.

PROCEDURE Create_Customer_Account(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
--  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,P_Qte_REC   IN ASO_QUOTE_PUB.Qte_Header_Rec_Type
  ,P_Account_number IN NUMBER := FND_API.G_MISS_NUM
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_acct_id           OUT NOCOPY /* file.sql.39 change */   NUMBER
    );


-- creates an account site
PROCEDURE Create_ACCT_SITE (
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
--  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,p_Cust_Account_Id NUMBER
  ,p_Party_Site_Id NUMBER
  ,p_Acct_site     VARCHAR2 := 'NONE'
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_customer_site_id  OUT NOCOPY /* file.sql.39 change */   NUMBER
   );


PROCEDURE Create_ACCT_SITE_USES (
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
-- ,p_validation_level IN  NUMBER    := FND_API.g_valid_level_full
  ,P_Cust_Account_Id   IN  NUMBER
  ,P_Party_Site_Id     IN  NUMBER
  ,P_cust_acct_site_id IN  NUMBER    := NULL
  ,P_Acct_Site_type    IN  VARCHAR2  := 'NONE'
  ,x_cust_acct_site_id OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_site_use_id  OUT NOCOPY /* file.sql.39 change */   NUMBER
  );


PROCEDURE Create_Contact (
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
--  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,p_party_id            IN NUMBER  := NULL  -- this is the party id of the corresponding org contact
  ,p_Org_Contact_Id      IN  NUMBER
  ,p_Cust_account_id     IN  NUMBER
  ,p_Role_type           IN       VARCHAR2 := 'CONTACT'
  ,p_Begin_date          IN DATE := sysdate
   ,x_return_status     OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */  NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */  VARCHAR2
  ,x_cust_account_role_id OUT NOCOPY /* file.sql.39 change */  NUMBER
     );

PROCEDURE Create_ORG_CONTACT_ord (
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
--  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,p_party_id NUMBER
  ,p_header_Party_Id NUMBER  := NULL
  ,p_acct_id  NUMBER         := NULL
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_org_contact_id    OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_party_id          OUT NOCOPY /* file.sql.39 change */   NUMBER
     ) ;
PROCEDURE Create_Contact_Role ( p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
  ,p_party_id          IN NUMBER     := FND_API.G_MISS_NUM
  ,p_Cust_account_id     IN  NUMBER
  ,p_cust_account_site_id IN NUMBER  := FND_API.G_MISS_NUM
  ,p_Role_type           IN       VARCHAR2 := 'CONTACT'
  ,p_responsibility_type IN VARCHAR2 := FND_API.G_MISS_CHAR
  ,p_Begin_date          IN DATE := sysdate
  ,p_role_id            IN  NUMBER  :=  FND_API.G_MISS_NUM
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_cust_account_role_id OUT NOCOPY /* file.sql.39 change */   NUMBER
);

Procedure GET_ACCT_SITE_USES(
   p_api_version       IN  NUMBER
  ,p_init_msg_list     IN  VARCHAR2  := FND_API.g_false
  ,p_commit            IN  VARCHAR2  := FND_API.g_false
--  ,p_validation_level  IN  NUMBER    := FND_API.g_valid_level_full
  ,P_Cust_Account_Id IN NUMBER
  ,P_Party_Site_Id  IN NUMBER
  ,P_Acct_Site_type IN VARCHAR2 := 'NONE'
  ,x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER
  ,x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2
  ,x_site_use_id  OUT NOCOPY /* file.sql.39 change */   NUMBER
    );


PROCEDURE Create_Cust_Acct_Relationship(
    p_api_version       IN      NUMBER,
    p_init_msg_list     IN      VARCHAR2  := FND_API.g_false,
    p_commit            IN      VARCHAR2  := FND_API.g_false,
    p_sold_to_cust_account	IN NUMBER,
    p_related_cust_account	IN NUMBER,
    p_relationship_type		IN VARCHAR2,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2);
PROCEDURE update_Cust_Acct_Relationship(
    p_api_version       IN      NUMBER,
    p_init_msg_list     IN      VARCHAR2  := FND_API.g_false,
    p_commit            IN      VARCHAR2  := FND_API.g_false,
    p_sold_to_cust_account	IN NUMBER,
    p_related_cust_account	IN NUMBER,
    p_relationship_type		IN VARCHAR2,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2);


PROCEDURE Create_Customer_Account(
    p_api_version       IN      NUMBER,
    p_init_msg_list     IN      VARCHAR2  := FND_API.g_false,
    p_commit            IN      VARCHAR2  := FND_API.g_false,
    P_Party_id          IN      NUMBER,
    P_Account_number    IN      NUMBER := FND_API.G_MISS_NUM,
    x_return_status     OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count         OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data          OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_cust_acct_id      OUT NOCOPY /* file.sql.39 change */   NUMBER);


PROCEDURE Create_Party_Site_Use(
    p_api_version          IN   NUMBER,
    p_init_msg_list        IN   VARCHAR2  := FND_API.g_false,
    p_commit               IN   VARCHAR2  := FND_API.g_false,
	p_party_site_id	       IN	NUMBER,
    p_party_site_use_type  IN   VARCHAR2,
	x_party_site_use_id	   OUT NOCOPY /* file.sql.39 change */   NUMBER,
	x_return_status		   OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
    x_msg_count            OUT NOCOPY /* file.sql.39 change */   NUMBER,
    x_msg_data             OUT NOCOPY /* file.sql.39 change */   VARCHAR2);

End ASO_PARTY_INT;

/
