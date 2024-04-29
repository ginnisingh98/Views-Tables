--------------------------------------------------------
--  DDL for Package AMS_RUNTIME_PROD_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_RUNTIME_PROD_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvrpds.pls 115.9 2003/12/10 13:24:19 sikalyan ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AMS_RUNTIME_PROD_PVT';
G_MAX_NO_PRODS  NUMBER   := 0;

TYPE prod_cursor is REF CURSOR;

PROCEDURE getRelatedItems(
   p_api_version_number      IN         NUMBER                      ,
   p_init_msg_list    IN         VARCHAR2  := FND_API.G_FALSE,
   p_application_id   IN         NUMBER                      ,
   p_prod_lst         IN         JTF_NUMBER_TABLE            ,
   p_rel_type_code    IN         VARCHAR2                    ,
   p_org_id           IN         NUMBER                      ,
   p_max_ret_num      IN         NUMBER    := NULL           ,
   p_order_by_clause  IN         VARCHAR2  := NULL           ,
   x_items_tbl        OUT NOCOPY JTF_Number_Table            ,
   x_return_status    OUT NOCOPY VARCHAR2                    ,
   x_msg_count        OUT NOCOPY NUMBER                      ,
   x_msg_data         OUT NOCOPY VARCHAR2
);


PROCEDURE getRelatedItems(
   p_api_version_number      IN         NUMBER                      ,
   p_init_msg_list    IN         VARCHAR2  := FND_API.G_FALSE,
   p_application_id   IN         NUMBER                      ,
   p_msite_id         IN         NUMBER                      ,
   p_top_section_id   IN         NUMBER                      ,
   p_incl_section     IN         VARCHAR2  := NULL ,
   p_prod_lst         IN         JTF_NUMBER_TABLE            ,
   p_rel_type_code    IN         VARCHAR2                    ,
   p_org_id           IN         NUMBER                      ,
   p_max_ret_num      IN         NUMBER    := NULL           ,
   p_order_by_clause  IN         VARCHAR2  := NULL           ,
   x_items_tbl        OUT NOCOPY JTF_Number_Table            ,
   x_return_status    OUT NOCOPY VARCHAR2                    ,
   x_msg_count        OUT NOCOPY NUMBER                      ,
   x_msg_data         OUT NOCOPY VARCHAR2
);


PROCEDURE getFilteredProdsFromList
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
 	 p_cust_account_id	IN    NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN 	  VARCHAR2 := NULL,
         p_prod_lst             IN    JTF_NUMBER_TABLE,
         p_msite_id             IN    NUMBER := NULL,
         p_top_section_id       IN    NUMBER := NULL,
         p_org_id               IN    NUMBER,
         p_bus_prior            IN    VARCHAR2 := NULL,
         p_bus_prior_order      IN    VARCHAR2 := NULL,
         p_filter_ref_code      IN    VARCHAR2 := NULL,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER := NULL,
         x_prod_lst             OUT NOCOPY JTF_Number_Table,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2
        );

PROCEDURE getRelProdsForQuoteAndCust
        (p_api_version_number   IN   NUMBER,
         p_init_msg_list        IN   VARCHAR2,
         p_application_id       IN   NUMBER,
         p_party_id             IN   NUMBER,
   	   p_cust_account_id	IN   NUMBER := FND_API.G_MISS_NUM,
	   p_currency_code	IN   VARCHAR2 := NULL,
         p_quote_id             IN   NUMBER,
         p_msite_id             IN   NUMBER,
         p_top_section_id       IN   NUMBER,
         p_org_id               IN   NUMBER,
         p_rel_type_code        IN   VARCHAR2,
         p_bus_prior            IN   VARCHAR2,
         p_bus_prior_order      IN   VARCHAR2,
         p_filter_ref_code      IN   VARCHAR2,
         p_price_list_id        IN   NUMBER := NULL,
         p_max_ret_num          IN   NUMBER := NULL,
         x_prod_lst             OUT  NOCOPY JTF_NUMBER_TABLE,
         x_return_status        OUT  NOCOPY VARCHAR2,
         x_msg_count            OUT  NOCOPY NUMBER,
         x_msg_data             OUT  NOCOPY VARCHAR2
        );

PROCEDURE getRelProdsForProdAndCust
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	 p_cust_account_id	IN NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN VARCHAR2 := NULL,
         p_prod_lst             IN   JTF_NUMBER_TABLE,
         p_msite_id             IN   NUMBER,
         p_top_section_id       IN   NUMBER,
         p_org_id               IN   NUMBER,
         p_rel_type_code        IN   VARCHAR2,
         p_bus_prior            IN   VARCHAR2,
         p_bus_prior_order      IN   VARCHAR2,
         p_filter_ref_code      IN   VARCHAR2,
         p_price_list_id        IN   NUMBER := NULL,
         p_max_ret_num          IN   NUMBER := NULL,
         x_prod_lst             OUT  NOCOPY JTF_NUMBER_TABLE,
         x_return_status        OUT  NOCOPY VARCHAR2,
         x_msg_count            OUT  NOCOPY NUMBER,
         x_msg_data             OUT  NOCOPY VARCHAR2
        );


PROCEDURE getPrioritizedProds
        (p_api_version_number IN    NUMBER,
         p_init_msg_list      IN    VARCHAR2,
         p_application_id     IN    NUMBER,
         p_party_id           IN    NUMBER,
   	 p_cust_account_id	IN NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN VARCHAR2 := NULL,
         p_prod_lst           IN JTF_NUMBER_TABLE,
         p_org_id             IN  NUMBER,
         p_bus_prior          IN  VARCHAR2,
         p_bus_prior_order    IN  VARCHAR2,
         p_price_list_id      IN  NUMBER   := NULL,
         p_max_ret_num        IN  NUMBER := NULL,
         x_prod_lst           OUT NOCOPY JTF_NUMBER_TABLE,
         x_return_status      OUT NOCOPY VARCHAR2,
         x_msg_count          OUT NOCOPY NUMBER,
         x_msg_data           OUT NOCOPY VARCHAR2
        );

  procedure loadItemDetails
	(p_api_version  IN  NUMBER,
         p_init_msg_list      	IN  VARCHAR2 := FND_API.G_FALSE,
         p_application_id       IN  NUMBER,
         p_party_id             IN  NUMBER,
       	 p_cust_account_id	IN  NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN  VARCHAR2 := NULL,
	 p_itmid_tbl 		IN  JTF_NUMBER_TABLE,
	 p_organization_id	IN  NUMBER,
	 p_category_set_id	IN  NUMBER,
	 p_retrieve_price	IN  VARCHAR2 := FND_API.G_FALSE,
	 p_price_list_id	IN  NUMBER := NULL,
	 p_price_request_type   IN  VARCHAR2 := NULL,
 	 p_price_event		IN  VARCHAR2 := NULL,
	 x_item_csr		OUT NOCOPY prod_cursor,
	 x_category_id_csr	OUT NOCOPY prod_cursor,
	 x_listprice_tbl	OUT nocopy JTF_NUMBER_TABLE,
	 x_bestprice_tbl	OUT nocopy JTF_NUMBER_TABLE,
	 x_price_status_code_tbl OUT nocopy JTF_VARCHAR2_TABLE_100,
	 x_price_status_text_tbl OUT nocopy JTF_VARCHAR2_TABLE_300,
	 x_price_return_status	OUT NOCOPY VARCHAR2,
	 x_price_return_status_text	OUT NOCOPY VARCHAR2,
     	 x_item_return_status  OUT NOCOPY VARCHAR2,
         x_msg_count OUT NOCOPY NUMBER,
         x_msg_data  OUT NOCOPY VARCHAR2
	);


PROCEDURE getRelProdsForProd
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	 p_cust_account_id	  IN    NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	  IN 	  VARCHAR2 := NULL,
         p_prod_lst             IN    JTF_NUMBER_TABLE,
         p_msite_id             IN    NUMBER,
         p_top_section_id       IN    NUMBER,
         p_org_id               IN    NUMBER,
         p_rel_type_code        IN    VARCHAR2,
         p_max_ret_num          IN    NUMBER := NULL,
         x_prod_lst             OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        );


PROCEDURE getRelProdsForCart
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	 p_cust_account_id	IN    NUMBER := FND_API.G_MISS_NUM,
	 p_currency_code	IN   VARCHAR2 := NULL,
         p_quote_id             IN    NUMBER,
         p_msite_id             IN    NUMBER,
         p_top_section_id       IN    NUMBER,
         p_org_id               IN    NUMBER,
         p_rel_type_code        IN    VARCHAR2,
         p_max_ret_num          IN    NUMBER := NULL,
         x_prod_lst             OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        );

END AMS_RUNTIME_PROD_PVT;

 

/
