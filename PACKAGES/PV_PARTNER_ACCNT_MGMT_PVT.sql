--------------------------------------------------------
--  DDL for Package PV_PARTNER_ACCNT_MGMT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PV_PARTNER_ACCNT_MGMT_PVT" AUTHID CURRENT_USER as
/* $Header: pvxvpams.pls 120.1 2005/08/10 14:37:20 appldev ship $ */

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


PROCEDURE Get_Partner_Accnt_Id(
   p_Partner_Party_Id  IN  NUMBER,
   x_return_status OUT NOCOPY VARCHAR2,
   x_Cust_Acct_Id  OUT NOCOPY NUMBER
 );

/* R12 Changes
 * Added out parameter x_cust_acct_site_id which
 * will be passed to calls to get_cust_acct_roles
*/
 PROCEDURE  Get_acct_site_uses(
  p_party_site_id IN NUMBER,
  p_acct_site_type IN VARCHAR2,
  p_cust_account_id IN NUMBER,
  p_party_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_site_use_id OUT NOCOPY number,
  x_cust_acct_site_id OUT NOCOPY NUMBER
);

/* R12 Changes
 * p_cust_account_site_id is no longer null as we will start passing
 * this value in as per OM
 * Removed paramter p_acct_site_type
*/
PROCEDURE Get_cust_acct_roles(
  p_contact_party_id IN NUMBER,
  p_cust_account_site_id IN NUMBER,
  p_cust_account_id IN NUMBER,
  x_return_status OUT NOCOPY VARCHAR2,
  x_cust_account_role_id OUT NOCOPY number
);

PROCEDURE Create_Party_Site(
  p_api_version       IN  NUMBER,
  p_init_msg_list     IN  VARCHAR2  := FND_API.g_false,
  p_commit            IN  VARCHAR2  := FND_API.g_false,
  p_party_site_rec        IN      PARTY_SITE_REC_TYPE,
  x_return_status         OUT NOCOPY     VARCHAR2,
  x_party_site_id         OUT NOCOPY     NUMBER,
  x_msg_count             OUT NOCOPY     NUMBER,
  x_msg_data              OUT NOCOPY     VARCHAR2
);

END PV_PARTNER_ACCNT_MGMT_PVT;

 

/
