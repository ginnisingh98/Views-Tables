--------------------------------------------------------
--  DDL for Package IBE_CUSTOMER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_CUSTOMER_PVT" AUTHID CURRENT_USER as
/* $Header: IBEVACTS.pls 120.5 2005/11/18 18:18:27 mannamra ship $ */

  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'ibe_customer_pvt';

--  procedure set_bank_acct_end_date --This API has been removed mannamra: 10/07/2005


  procedure setOptInOutPreference(
    p_party_id          IN  NUMBER,
    p_preference        IN  VARCHAR2,
    p_init_msg_list     IN    VARCHAR2 := FND_API.G_TRUE,
    p_commit            IN    VARCHAR2 := FND_API.G_FALSE,
    p_api               IN   NUMBER,
    x_return_status      OUT NOCOPY  VARCHAR2,
    x_msg_count          OUT NOCOPY  NUMBER,
    x_msg_data           OUT NOCOPY  VARCHAR2
  );

-- function to Get Credit Card Type Given The Number

function Get_Credit_Card_Type(
     --fix 2861827
     --p_Credit_Card_Number NUMBER
     p_Credit_Card_Number VARCHAR2
) RETURN VARCHAR2;


-- Get the primary credit card info for a given party id for
-- an enabled credit card type.
-- If primary credit card does not exists then get the
-- credit card info of the first credit card.
-- If the credit card type is not enabled then don't return anything.

procedure get_default_credit_card_info(
    p_api_version            IN  NUMBER,
    p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
    p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
    p_cust_account_id        IN  NUMBER,
    p_party_id               IN  NUMBER,
    p_mini_site_id           IN  NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    x_cc_assignment_id        OUT NOCOPY NUMBER
                              );

-- This procedure updates the primary credit card id if it already exists,
-- it also sets the primary credit card id if it does not exists.

/*procedure set_primary_credit_card_id: mannamra: 11/14/2005 : Bug 4725304: This API has been modified to query
IBY schema*/


-- This procedure gets the primary credit card id if it already exists

procedure get_primary_credit_card_id(p_username         IN VARCHAR2,
                                     x_credit_card_id   OUT NOCOPY NUMBER);


-- This procedure creates a new credit card by calling
-- arp_bank_pkg.process_bank_account. It also sets the
-- new credit card id as primary credit card if a primary
-- credit card id does not exists.

/*procedure create_credit_card : mannamra: 11/14/2005 : Bug 4725304:  This API can be obsoleted because it is used to create a credit card in AP's
@ Bank Accouts' schema but going forward credit cards will be stored in
@ iPayment schema. IBE_PAYMENT_INT_PVT.saveCC() will be used to perform this
 operation.*/


end ibe_customer_pvt;

 

/
