--------------------------------------------------------
--  DDL for Package OZF_NET_ACCRUAL_ENGINE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_NET_ACCRUAL_ENGINE_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvnaes.pls 120.2 2006/08/03 12:27:46 mgudivak noship $ */
G_PKG_NAME CONSTANT VARCHAR2(30) := 'OZF_NET_ACCRUAL_ENGINE_PVT';

TYPE order_line_rec_type IS RECORD
(
   order_header_id NUMBER
  ,order_line_id   NUMBER
);

TYPE order_line_tbl_type IS TABLE OF order_line_rec_type INDEX BY BINARY_INTEGER;

TYPE order_rec IS RECORD
(
  header_id                 NUMBER,
  line_id                   NUMBER,
  actual_shipment_date      DATE,
  fulfillment_date          DATE,
  invoice_to_org_id         NUMBER,
  ship_to_org_id            NUMBER,
  sold_to_org_id            NUMBER,
  inventory_item_id         NUMBER,
  shipped_quantity          NUMBER,
  fulfilled_quantity        NUMBER,
  invoiced_quantity         NUMBER,
  pricing_quantity          NUMBER,
  pricing_quantity_uom      VARCHAR2(3),
  unit_selling_price        NUMBER,
  org_id                    NUMBER,
  conv_date                 DATE,
  transactional_curr_code   VARCHAR2(15) );

 TYPE t_order_line_tbl IS TABLE OF order_rec INDEX BY BINARY_INTEGER;

TYPE ar_trx_rec IS RECORD
(
  extended_amount           NUMBER,
  inventory_item_id         NUMBER,
  quantity_credited         NUMBER,
  quantity_invoiced         NUMBER,
  uom_code                  VARCHAR2(3),
  sold_to_customer_id       NUMBER,
  bill_to_site_use_id       NUMBER,
  ship_to_site_use_id       NUMBER,
  invoice_currency_code     VARCHAR2(15),
  customer_trx_id           NUMBER,
  complete_flag             VARCHAR2(1),
  conv_date                 DATE,
  customer_trx_line_id      NUMBER
);

TYPE t_ar_trx_line_tbl IS TABLE OF ar_trx_rec INDEX BY BINARY_INTEGER;
TYPE terr_countries_tbl IS TABLE OF VARCHAR2(30) INDEX BY BINARY_INTEGER;


PROCEDURE retroactive_offer_adj(
   p_api_version    IN  NUMBER
  ,p_init_msg_list  IN  VARCHAR2
  ,p_commit         IN  VARCHAR2
  ,x_return_status  OUT NOCOPY VARCHAR2
  ,x_msg_count      OUT NOCOPY NUMBER
  ,x_msg_data       OUT NOCOPY VARCHAR2
  ,p_offer_id       IN  NUMBER
  ,p_start_date     IN  DATE
  ,p_end_date       IN  DATE
  ,x_order_line_tbl OUT NOCOPY order_line_tbl_type);

PROCEDURE offer_adj_new_product(
   p_api_version    IN  NUMBER
  ,p_init_msg_list  IN  VARCHAR2
  ,p_commit         IN  VARCHAR2
  ,x_return_status  OUT NOCOPY VARCHAR2
  ,x_msg_count      OUT NOCOPY NUMBER
  ,x_msg_data       OUT NOCOPY VARCHAR2
  ,p_offer_id       IN  NUMBER
  ,p_product_id     IN  NUMBER
  ,p_start_date     IN  DATE
  ,p_end_date       IN  DATE
  ,x_order_line_tbl OUT NOCOPY order_line_tbl_type
);

PROCEDURE net_accrual_engine(
  ERRBUF          OUT NOCOPY VARCHAR2,
  RETCODE         OUT NOCOPY VARCHAR2,
  p_as_of_date    IN  VARCHAR2,
  p_offer_id      IN  NUMBER DEFAULT NULL);

END ozf_net_accrual_engine_pvt;

 

/
