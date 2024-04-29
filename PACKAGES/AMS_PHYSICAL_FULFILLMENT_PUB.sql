--------------------------------------------------------
--  DDL for Package AMS_PHYSICAL_FULFILLMENT_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_PHYSICAL_FULFILLMENT_PUB" AUTHID CURRENT_USER AS
 /* $Header: amsvfuls.pls 120.1 2005/08/11 11:49:18 appldev ship $ */
  TYPE order_header_rec_type IS RECORD
  (
      cust_party_id             NUMBER
    , cust_account_id           NUMBER
    , sold_to_contact_id        NUMBER
    , inv_party_id              NUMBER
    , inv_party_site_id         NUMBER
    , ship_party_site_id        NUMBER
    , quote_source_code         VARCHAR2(240)
    , marketing_source_code_id  NUMBER
    , order_type_id             NUMBER
    , employee_id               NUMBER
    , collateral_id             NUMBER
    , cover_letter_id           NUMBER
    , uom_code                  VARCHAR2(3)
    , line_category_code        VARCHAR2(30)
    , inv_organization_id       NUMBER
    , SHIP_FROM_ORG_ID          NUMBER
    , organization_id           NUMBER       --by: musman: MOAC uptake bug:4421261 Fix
    );


  TYPE order_line_rec_type IS RECORD
  (
      ship_party_id         NUMBER
     ,ship_party_site_id    NUMBER
     ,ship_method_code      VARCHAR2(30)
    , quantity              NUMBER
    , SHIP_FROM_ORG_ID          NUMBER
  );

 TYPE order_line_tbl_type IS TABLE OF order_line_rec_type
        INDEX BY BINARY_INTEGER;

 PROCEDURE  fulfill_collateral_request
  (
    p_init_msg_list         IN   VARCHAR2
   ,p_api_version           IN   NUMBER
   ,p_commit                IN   VARCHAR2
   ,x_return_status         OUT NOCOPY VARCHAR2
   ,x_msg_count             OUT NOCOPY NUMBER
   ,x_msg_data              OUT NOCOPY VARCHAR2
   ,p_order_header_rec      IN  ORDER_HEADER_REC_TYPE
   ,p_order_line_tbl        IN  ORDER_LINE_TBL_TYPE
   ,x_order_header_rec      OUT NOCOPY ASO_ORDER_INT.order_header_rec_type
  );
END AMS_physical_fulfillment_PUB;

 

/
