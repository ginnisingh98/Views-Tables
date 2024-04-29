--------------------------------------------------------
--  DDL for Package CSE_ASSET_CLIENT_EXT_STUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_ASSET_CLIENT_EXT_STUB" AUTHID CURRENT_USER AS
-- $Header: CSEFASTS.pls 120.2.12010000.1 2008/07/30 05:17:35 appldev ship $

PROCEDURE get_asset_name(
	p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
	x_asset_name            OUT NOCOPY       VARCHAR2,
	x_hook_used             OUT NOCOPY       NUMBER,
	x_error_msg             OUT NOCOPY       VARCHAR2);

PROCEDURE get_asset_description(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_description           OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_asset_category(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_book_type(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_date_place_in_service(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_in_service_date       OUT NOCOPY       DATE
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_asset_key(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_asset_key_ccid        OUT NOCOPY       NUMBER
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_asset_location(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_deprn_expense_ccid(
    p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_deprn_expense_ccid    OUT NOCOPY       NUMBER
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_search_method(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_search_method         OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_tag_number(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_tag_number            OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_model_number(
 p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_model_number          OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_manufacturer(
   p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_manufacturer_name     OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_employee(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_employee_id           OUT NOCOPY       NUMBER
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_payables_ccid(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_payables_ccid         OUT NOCOPY       NUMBER
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_txn_class_flag(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, p_txn_class             IN        VARCHAR2
, x_process_flag          OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PRAGMA RESTRICT_REFERENCES(get_txn_class_flag, WNDS);

PROCEDURE get_catchup_flag(
  p_asset_number          IN        VARCHAR2,
  p_instance_asset_id     IN        NUMBER,
  x_catchup_flag          OUT NOCOPY       VARCHAR2,
  x_hook_used             OUT NOCOPY       NUMBER,
  x_error_msg             OUT NOCOPY       VARCHAR2);

PROCEDURE get_inv_depr_acct(
  p_mtl_transaction_id    IN        NUMBER
, x_dummy_acct_id         OUT NOCOPY       NUMBER
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_inventory_item(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

PROCEDURE get_non_mtl_retire_flag(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
 p_asset_id              IN        NUMBER
, x_retire_flag           OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;
PRAGMA RESTRICT_REFERENCES(get_inventory_item, WNDS);

PROCEDURE get_product_code(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
 x_product_code          OUT NOCOPY       VARCHAR2
, x_hook_used             OUT NOCOPY       NUMBER
, x_error_msg             OUT NOCOPY       VARCHAR2) ;

END CSE_ASSET_CLIENT_EXT_STUB ;

/
