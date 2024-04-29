--------------------------------------------------------
--  DDL for Package AMS_RUNTIME_CAMP_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_RUNTIME_CAMP_PVT" AUTHID CURRENT_USER AS
/* $Header: amsvrcas.pls 115.8 2004/07/12 09:23:44 vnuti ship $ */

G_PKG_NAME      CONSTANT VARCHAR2(30) := 'AMS_RUNTIME_CAMP_PVT';

TYPE camp_cursor is REF CURSOR;
TYPE num_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE off_rec_type IS RECORD
   (
      activity_offer_id		NUMBER,
      qp_list_header_id		NUMBER,
      camp_schedule_id	        NUMBER
   );
TYPE off_rec_type_tbl IS TABLE OF off_rec_type INDEX BY BINARY_INTEGER;

TYPE qp_rec_type IS RECORD
   (
      o_activity_offer_id		NUMBER,
      o_qp_list_header_id		NUMBER
   );
TYPE qp_rec_type_tbl IS TABLE OF qp_rec_type INDEX BY BINARY_INTEGER;


PROCEDURE getFilteredSchedulesFromList
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	   p_cust_account_id	  IN    NUMBER := FND_API.G_MISS_NUM,
         p_sched_lst            IN    JTF_NUMBER_TABLE,
         p_org_id               IN    NUMBER,
         p_bus_prior            IN    VARCHAR2 := NULL,
         p_bus_prior_order      IN    VARCHAR2 := NULL,
         p_filter_ref_code      IN    VARCHAR2 := NULL,
         p_max_ret_num          IN    NUMBER,
         x_sched_lst            OUT NOCOPY JTF_Number_Table,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2
        );

PROCEDURE getRelSchedulesForQuoteAndCust
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	   p_cust_account_id	  IN    NUMBER := FND_API.G_MISS_NUM,
	   p_currency_code	  IN 	  VARCHAR2 := NULL,
         p_quote_id             IN    NUMBER,
         p_msite_id             IN    NUMBER,
         p_top_section_id       IN    NUMBER,
         p_org_id               IN    NUMBER,
         p_rel_type_code        IN    VARCHAR2,
         p_bus_prior            IN    VARCHAR2,
         p_bus_prior_order      IN    VARCHAR2,
         p_filter_ref_code      IN    VARCHAR2,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER := NULL,
         x_sched_lst            OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        );

PROCEDURE getRelSchedulesForProdAndCust
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
         p_bus_prior            IN    VARCHAR2,
         p_bus_prior_order      IN    VARCHAR2,
         p_filter_ref_code      IN    VARCHAR2,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER := NULL,
         x_sched_lst            OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        );

PROCEDURE getFilteredOffersFromList
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	   p_cust_account_id	  IN    NUMBER := FND_API.G_MISS_NUM,
	   p_currency_code	  IN 	  VARCHAR2 := NULL,
         p_offer_lst            IN    JTF_NUMBER_TABLE,
         p_org_id               IN    NUMBER,
         p_bus_prior            IN    VARCHAR2 := NULL,
         p_bus_prior_order      IN    VARCHAR2 := NULL,
         p_filter_ref_code      IN    VARCHAR2 := NULL,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER,
         x_offer_lst            OUT NOCOPY JTF_Number_Table,
         x_return_status        OUT NOCOPY VARCHAR2,
         x_msg_count            OUT NOCOPY NUMBER,
         x_msg_data             OUT NOCOPY VARCHAR2
        );

PROCEDURE getRelOffersForQuoteAndCust
        (p_api_version_number   IN    NUMBER,
         p_init_msg_list        IN    VARCHAR2,
         p_application_id       IN    NUMBER,
         p_party_id             IN    NUMBER,
   	   p_cust_account_id	  IN    NUMBER := FND_API.G_MISS_NUM,
	   p_currency_code	  IN 	  VARCHAR2 := NULL,
         p_quote_id             IN    NUMBER,
         p_msite_id             IN    NUMBER,
         p_top_section_id       IN    NUMBER,
         p_org_id               IN    NUMBER,
         p_rel_type_code        IN    VARCHAR2,
         p_bus_prior            IN    VARCHAR2,
         p_bus_prior_order      IN    VARCHAR2,
         p_filter_ref_code      IN    VARCHAR2,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER := NULL,
         x_offer_lst            OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        );

PROCEDURE getRelOffersForProdAndCust
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
         p_bus_prior            IN    VARCHAR2,
         p_bus_prior_order      IN    VARCHAR2,
         p_filter_ref_code      IN    VARCHAR2,
         p_price_list_id        IN    NUMBER   := NULL,
         p_max_ret_num          IN    NUMBER := NULL,
         x_offer_lst            OUT NOCOPY   JTF_NUMBER_TABLE,
         x_return_status        OUT NOCOPY   VARCHAR2,
         x_msg_count            OUT NOCOPY   NUMBER,
         x_msg_data             OUT NOCOPY   VARCHAR2
        );


END AMS_RUNTIME_CAMP_PVT;

 

/
