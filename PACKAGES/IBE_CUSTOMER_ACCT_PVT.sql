--------------------------------------------------------
--  DDL for Package IBE_CUSTOMER_ACCT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_CUSTOMER_ACCT_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVCACS.pls 120.0.12010000.2 2014/12/16 08:42:34 kdosapat ship $ */


-- This API is to retrieve a valid InvoiceTo/ShipTo Party'siteId for
-- the logged in user.
-- It follows following Rules to fetch the valid value.
-- For instance to fetch invoiceTo partySiteId
-- a) check if the user has a Primary BillTo Address and return id
-- b) If the user does not have a Primary BillTo Address,
--    then get the first "non-primary" BillTo Address.
-- c_ If the user does not have valid "BillTo Address",
--     then get the first "valid" address (SHIP_TO or any other site-use-type)

 PROCEDURE GetPartySiteId(
                         p_api_version_number IN  NUMBER     := 1,
                         p_init_msg_list      IN  VARCHAR2   := FND_API.G_TRUE,
                         p_commit             IN  VARCHAR2   := FND_API.G_FALSE,
                         p_party_id           IN  NUMBER,
                         p_site_use_type      IN  VARCHAR2,
                         x_party_site_id      OUT NOCOPY NUMBER,
                         x_return_status      OUT NOCOPY VARCHAR2,
                         x_msg_count          OUT NOCOPY NUMBER,
                         x_msg_data           OUT NOCOPY VARCHAR2);

/*
 PROCEDURE Create_Party_Site_Use(
                         p_api_version_number   IN  NUMBER     := 1,
                         p_init_msg_list        IN  VARCHAR2   := FND_API.G_TRUE,
                         p_commit               IN  VARCHAR2   := FND_API.G_FALSE,
                         p_party_site_id        IN  NUMBER,
                         p_party_site_use_type  IN  VARCHAR2,
                         x_party_site_use_id    OUT NOCOPY NUMBER,
                         x_return_status        OUT NOCOPY VARCHAR2,
                         x_msg_count            OUT NOCOPY NUMBER,
                         x_msg_data             OUT NOCOPY VARCHAR2);
*/

 PROCEDURE create_cust_account_role(
                    p_api_version_number   IN  NUMBER     := 1,
                    p_init_msg_list        IN  VARCHAR2   := FND_API.G_TRUE,
                    p_commit               IN  VARCHAR2   := FND_API.G_FALSE,
                    p_party_id             IN  NUMBER,
                    p_cust_acct_id         IN  NUMBER,
                    p_cust_acct_site_id    IN  NUMBER,
                    p_role_type            IN  VARCHAR2,
                    x_cust_acct_role_id    OUT NOCOPY NUMBER,
                    x_return_status      OUT NOCOPY VARCHAR2,
                    x_msg_count          OUT NOCOPY NUMBER,
                    x_msg_data           OUT NOCOPY VARCHAR2);


 PROCEDURE Create_Cust_Acct_Site(
                       p_api_version_number IN  NUMBER     := 1
                      ,p_init_msg_list      IN  VARCHAR2   := FND_API.G_TRUE
                      ,p_commit             IN  VARCHAR2   := FND_API.G_FALSE
                      ,p_partysite_id       IN  NUMBER
                      ,p_custacct_id        IN  NUMBER
                      ,p_custacct_type      IN  VARCHAR2
                      ,x_custacct_site_id   OUT NOCOPY NUMBER
                      ,x_return_status      OUT NOCOPY VARCHAR2
                      ,x_msg_count          OUT NOCOPY NUMBER
                      ,x_msg_data           OUT NOCOPY VARCHAR2);



 PROCEDURE Create_Cust_Acct_Site_Use(
                              p_api_version_number   IN  NUMBER     := 1
                             ,p_init_msg_list        IN  VARCHAR2   := FND_API.G_TRUE
                             ,p_commit               IN  VARCHAR2   := FND_API.G_FALSE
                             ,p_cust_account_Id      IN  NUMBER
                             ,p_party_site_Id        IN  NUMBER
                             ,p_cust_acct_site_id    IN  NUMBER
                             ,p_acct_site_type       IN  VARCHAR2
                             ,x_cust_acct_site_id    OUT NOCOPY NUMBER
                             ,x_custacct_site_use_id OUT NOCOPY NUMBER
                             ,x_return_status        OUT NOCOPY VARCHAR2
                             ,x_msg_count            OUT NOCOPY NUMBER
                             ,x_msg_data             OUT NOCOPY VARCHAR2);


 -- This API returns the InvoiceToOrgId or ShipToOrgId
 -- for the Order.

 PROCEDURE  Get_Cust_Account_Site_Use(
                             p_api_version_number IN  NUMBER     := 1
                            ,p_init_msg_list      IN  VARCHAR2   := FND_API.G_TRUE
                            ,p_commit             IN  VARCHAR2   := FND_API.G_FALSE
                            ,p_cust_acct_id       IN  NUMBER
                            ,p_party_id           IN  NUMBER
                            ,p_siteuse_type       IN  VARCHAR2
                            ,p_partysite_id       IN  NUMBER      := FND_API.G_MISS_NUM
                            ,x_siteuse_id         OUT NOCOPY NUMBER
                            ,x_return_status      OUT NOCOPY VARCHAR2
                            ,x_msg_count          OUT NOCOPY NUMBER
                            ,x_msg_data           OUT NOCOPY VARCHAR2);


-- This Procedure is to retrieve the cust_acct_role_id for a given user.
-- This valus would be invoice_to_contactid at oe_order_headers_all table.
-- If the invoice_to_org_id is retrieved from any of the valid line level values, then
-- invoice_to_contact_id would be maintained as null.

 PROCEDURE Get_Cust_Acct_Role(
                      p_api_version_number   IN  NUMBER     := 1
                     ,p_init_msg_list        IN  VARCHAR2   := FND_API.G_TRUE
                     ,p_commit               IN  VARCHAR2   := FND_API.G_FALSE
                     ,p_party_id             IN  NUMBER
                     ,p_acctsite_type        IN  VARCHAR2
                     ,p_sold_to_orgid        IN  NUMBER
                     ,p_custacct_siteuse_id  IN  NUMBER := FND_API.G_MISS_NUM
                     ,x_cust_acct_role_id    OUT NOCOPY NUMBER
                     ,x_return_status        OUT NOCOPY VARCHAR2
                     ,x_msg_count            OUT NOCOPY NUMBER
                     ,x_msg_data             OUT NOCOPY VARCHAR2);

 -- This API would give Customer, Contact details of an Order/Order Line.
 -- The InvocieToOrgId and InvoiceToContactId from
 -- oe_order_headers_all/ oe_order-lines_all would be the
 -- IN parameters for this API.

PROCEDURE GetCustomerAcctData(
                         p_api_version_number    IN  NUMBER   := 1
                        ,p_init_msg_list         IN  VARCHAR2 := FND_API.G_TRUE
                        ,p_commit                IN  VARCHAR2 := FND_API.G_FALSE
                        ,p_invoice_to_org_id     IN  NUMBER   := FND_API.G_MISS_NUM
                        ,p_invoice_to_contact_id IN  NUMBER   := FND_API.G_MISS_NUM
                        ,p_contact_party_id      IN  NUMBER   := FND_API.G_MISS_NUM
                        ,p_cust_account_id       IN  NUMBER   := FND_API.G_MISS_NUM
                        ,x_cust_account_id       OUT NOCOPY NUMBER
                        ,x_cust_party_name       OUT NOCOPY VARCHAR2
                        ,x_cust_party_id         OUT NOCOPY NUMBER
			,x_cust_party_type       OUT NOCOPY VARCHAR2
                        ,x_contact_party_id      OUT NOCOPY NUMBER
                        ,x_contact_party_name    OUT NOCOPY VARCHAR2
                        ,x_contact_phone         OUT NOCOPY VARCHAR2
                        ,x_contact_email         OUT NOCOPY VARCHAR2
                        ,x_party_site_id         OUT NOCOPY NUMBER
                        ,x_partysite_status      OUT NOCOPY VARCHAR2
                        ,x_return_status         OUT NOCOPY VARCHAR2
                        ,x_msg_count             OUT NOCOPY NUMBER
                        ,x_msg_data              OUT NOCOPY VARCHAR2);


END IBE_CUSTOMER_ACCT_PVT;

/
