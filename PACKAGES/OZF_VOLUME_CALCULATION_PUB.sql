--------------------------------------------------------
--  DDL for Package OZF_VOLUME_CALCULATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_VOLUME_CALCULATION_PUB" AUTHID CURRENT_USER AS
/* $Header: ozfpvocs.pls 120.7.12010000.4 2010/10/15 08:48:34 nirprasa ship $ */
/*
TYPE volume_detail_rec_type IS RECORD
(
  offer_id            NUMBER
 ,qp_list_header_id   NUMBER
 ,distributor_acct_id NUMBER -- cust account id of distributor.
 ,cust_account_id     NUMBER
 ,bill_to             NUMBER -- bill to site use id
 ,ship_to             NUMBER -- ship to site use id
 ,inventory_item_id   NUMBER
 ,quantity            NUMBER
 ,price               NUMBER
 ,uom_code            VARCHAR2(3)
 ,currency_code       VARCHAR2(15)
 ,transaction_date    DATE
 ,order_line_id       NUMBER
);
TYPE volume_detail_tbl_type IS TABLE OF volume_detail_rec_type INDEX BY BINARY_INTEGER;
*/

-- 10/15/2010 nirprasa  fixed bug 9027785 - BENEFICIARY IS INCORRECT FOR RETURN ORDERS UNLESS THEY ARE REPRICED

FUNCTION get_numeric_attribute_value
(
  p_list_line_id         IN NUMBER
 ,p_list_line_no         IN VARCHAR2
 ,p_order_header_id      IN NUMBER
 ,p_order_line_id        IN NUMBER
 ,p_price_effective_date IN DATE
 ,p_req_line_attrs_tbl   IN qp_runtime_source.accum_req_line_attrs_tbl
 ,p_accum_rec            IN qp_runtime_source.accum_record_type
)
RETURN NUMBER;


PROCEDURE get_volume -- overload version 1, used by OM
(
   p_offer_id            IN  NUMBER
  ,p_cust_acct_id        IN  NUMBER
  ,p_bill_to             IN  NUMBER
  ,p_ship_to             IN  NUMBER
  ,p_group_no            IN  NUMBER
  ,p_vol_track_type      IN  VARCHAR2
  ,p_pbh_line_id         IN  NUMBER
  ,p_combine_schedule    IN  VARCHAR2
  ,x_acc_volume          OUT NOCOPY NUMBER
);

/*
PROCEDURE get_volume -- overload version 2, used by IDSM
(
   p_offer_id            IN  NUMBER
  ,p_cust_acct_id        IN  NUMBER
  ,p_bill_to             IN  NUMBER
  ,p_ship_to             IN  NUMBER
  ,p_distributor_acct_id IN  NUMBER
  ,p_group_no            IN  NUMBER
  ,p_vol_track_type      IN  VARCHAR2
  ,p_combine_schedule_yn IN  VARCHAR2
  ,p_pbh_line_id         IN  NUMBER
  ,p_prod_attr           IN  VARCHAR2
  ,p_attr_value          IN  VARCHAR2
  ,p_trx_date            IN  DATE
  ,x_acc_volume          OUT NOCOPY NUMBER
);
*/

PROCEDURE get_volume -- overload version 2, used by budget
(
   p_init_msg_list       IN  VARCHAR2
  ,p_api_version         IN  NUMBER
  ,p_commit              IN  VARCHAR2
  ,x_return_status       OUT NOCOPY VARCHAR2
  ,x_msg_count           OUT NOCOPY NUMBER
  ,x_msg_data            OUT NOCOPY VARCHAR2
  ,p_qp_list_header_id   IN  NUMBER
  ,p_order_line_id       IN  NUMBER
  ,p_source_code         IN  VARCHAR2 -- O for OM, R for IS
  ,p_trx_date            IN  DATE
  ,x_acc_volume          OUT NOCOPY NUMBER
);


PROCEDURE create_volume
(
   p_init_msg_list     IN  VARCHAR2
  ,p_api_version       IN  NUMBER
  ,p_commit            IN  VARCHAR2
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_volume_detail_rec IN  ozf_sales_transactions_pvt.sales_transaction_rec_type
  ,p_qp_list_header_id IN  NUMBER DEFAULT NULL
  ,x_apply_discount    OUT NOCOPY VARCHAR2
);


FUNCTION get_beneficiary
(
   p_offer_id        IN NUMBER
  ,p_order_line_id   IN NUMBER
)
RETURN NUMBER;


PROCEDURE update_tracking_line
(
   p_init_msg_list     IN  VARCHAR2
  ,p_api_version       IN  NUMBER
  ,p_commit            IN  VARCHAR2
  ,x_return_status     OUT NOCOPY VARCHAR2
  ,x_msg_count         OUT NOCOPY NUMBER
  ,x_msg_data          OUT NOCOPY VARCHAR2
  ,p_list_header_id    IN  NUMBER
  ,p_interface_line_id IN  NUMBER
  ,p_resale_line_id    IN  NUMBER
);
--------------------------
-- Used by Volume Tracking
-- Will return a value only if tracking by GROUP.
--------------------------
FUNCTION get_group_volume
(
p_offer_id        IN NUMBER
,p_group_number    IN NUMBER
,p_pbh_line_id     IN NUMBER
)
RETURN NUMBER;

FUNCTION get_product_volume
(
p_offer_id           IN NUMBER
,p_pbh_line_id        IN NUMBER
,p_cust_account_id    IN NUMBER
,p_bill_to_id         IN NUMBER
,p_ship_to_id         IN NUMBER
)
RETURN NUMBER;

FUNCTION get_actual_tier
(
p_offer_id        IN NUMBER
,p_inventory_item_id IN NUMBER
,p_pbh_line_id     IN NUMBER
,p_cust_account_id    IN NUMBER
,p_bill_to_id         IN NUMBER
,p_ship_to_id         IN NUMBER
)
RETURN VARCHAR2;

FUNCTION get_actual_discount
(
p_offer_id        IN NUMBER
,p_inventory_item_id IN NUMBER
,p_pbh_line_id     IN NUMBER
,p_cust_account_id    IN NUMBER
,p_bill_to_id         IN NUMBER
,p_ship_to_id         IN NUMBER
)
RETURN VARCHAR2;


FUNCTION get_preset_tier
(
p_offer_id        IN NUMBER
,p_pbh_line_id     IN NUMBER
,p_group_no        IN NUMBER
)
RETURN VARCHAR2;

FUNCTION get_preset_discount
(
p_offer_id        IN NUMBER
,p_pbh_line_id     IN NUMBER
,p_group_no        IN NUMBER
)
RETURN VARCHAR2;

FUNCTION get_payout_accrual
(
p_offer_id           IN NUMBER
,p_item_id            IN NUMBER
,p_cust_account_id    IN NUMBER
,p_bill_to_id         IN NUMBER
,p_ship_to_id         IN NUMBER
)
RETURN VARCHAR2;

FUNCTION get_approx_actual_accrual
(
p_offer_id           IN NUMBER
,p_pbh_line_id        IN NUMBER
,p_group_no           IN NUMBER
,p_item_id            IN NUMBER
,p_cust_account_id    IN NUMBER
,p_bill_to_id         IN NUMBER
,p_ship_to_id         IN NUMBER
)
RETURN VARCHAR2;

--nirprasa, added function for bug 9027785
FUNCTION copy_order_group_details
( p_from_order_line_id        IN NUMBER
 ,p_to_order_line_id    IN NUMBER
)
RETURN NUMBER;

END OZF_VOLUME_CALCULATION_PUB;

/
