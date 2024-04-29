--------------------------------------------------------
--  DDL for Package JTF_CUSTOMER_ACCOUNTS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CUSTOMER_ACCOUNTS_PVT" AUTHID CURRENT_USER as
/* $Header: JTFVACTS.pls 120.2 2005/08/31 05:53:53 snellepa ship $ */

  G_PKG_NAME      CONSTANT VARCHAR2(30) := 'jtf_cust_accounts_pvt';


  procedure create_account(
    p_api_version          IN    NUMBER,
    p_init_msg_list        IN    VARCHAR2,
    p_commit               IN    VARCHAR2,
    p_party_id             IN    NUMBER,
    p_account_number       IN    VARCHAR2,
    p_create_amt           IN    VARCHAR2,
    p_party_type           IN    VARCHAR2,
    x_return_status        OUT   NOCOPY VARCHAR2,
    x_msg_count            OUT   NOCOPY NUMBER,
    x_msg_data             OUT   NOCOPY VARCHAR2,
    x_cust_account_id      OUT   NOCOPY NUMBER,
    x_cust_account_number  OUT   NOCOPY VARCHAR2,
    x_party_id             OUT   NOCOPY NUMBER,
    x_party_number         OUT   NOCOPY VARCHAR2,
    x_profile_id           OUT   NOCOPY NUMBER,
    p_account_name         IN    VARCHAR2:=FND_API.G_MISS_CHAR
  );

end jtf_customer_accounts_pvt;

 

/
