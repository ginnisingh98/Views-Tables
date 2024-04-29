--------------------------------------------------------
--  DDL for Package CSE_ASSET_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSE_ASSET_UTIL_PKG" AUTHID CURRENT_USER AS
-- $Header: CSEFAUTS.pls 120.5.12010000.1 2008/07/30 05:17:38 appldev ship $

G_FIFO_SEARCH     CONSTANT VARCHAR2(4) := 'FIFO';
G_LIFO_SEARCH     CONSTANT VARCHAR2(4) := 'LIFO';

G_SOURCE_MOVE_TYPE          CONSTANT VARCHAR2(15)  := 'SOURCE' ;
G_DESTINATION_MOVE_TYPE     CONSTANT VARCHAR2(15)  := 'DESTINATION' ;
G_NULL_MOVE_TYPE            CONSTANT VARCHAR2(15)  := NULL ;

G_RECEIPT_TXN_CLASS    CONSTANT VARCHAR2(20)  := 'RECEIPT';
G_MOVE_TXN_CLASS       CONSTANT VARCHAR2(20)  := 'MOVE';
G_MISC_MOVE_TXN_CLASS  CONSTANT VARCHAR2(20)  := 'MISC_MOVE';
G_MISC_RECPT_TXN_CLASS CONSTANT VARCHAR2(20)  := 'MISC RECEIPT';
G_IPV_TXN_CLASS       CONSTANT VARCHAR2(20)  := 'IPV';
G_FA_FEEDER_NAME      CONSTANT VARCHAR2(40):= 'ORACLE ENTERPRISE INSTALL BASE';
G_ADJUST_TXN_CLASS    CONSTANT VARCHAR2(20) := 'ADJUSTMENTS' ;
G_SPLIT_MERGE_FA_LINK_CLASS CONSTANT VARCHAR2(20):='SPLIT MERGE'; --bnarayan added for R12

G_MTL_INDICATOR       CONSTANT VARCHAR2(1) := 'Y' ;
G_NON_MTL_INDICATOR   CONSTANT VARCHAR2(1) := 'N' ;

TYPE inst_loc_rec IS RECORD
(
  instance_id               NUMBER ,
  transaction_id            NUMBER ,
  transaction_date          DATE ,
  location_type_code             VARCHAR2(30) ,
  inv_organization_id       NUMBER ,
  inv_subinventory_name         VARCHAR2(10) ,
  location_id               NUMBER
);

TYPE inst_txn_rec IS RECORD
(
  instance_id               NUMBER ,
  transaction_id            NUMBER ,
  transaction_date          DATE ,
  inv_organization_id       NUMBER ,
  inv_subinventory_name     VARCHAR2(10)
);

FUNCTION asset_description(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2) RETURN VARCHAR2;

FUNCTION asset_category(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN NUMBER;

FUNCTION book_type(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN VARCHAR2;

FUNCTION date_place_in_service(
 p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN DATE;

FUNCTION asset_key(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN NUMBER;

 /*FUNCTION asset_location(
  p_transaction_id        IN        NUMBER,
  p_instance_id           IN        NUMBER,
  p_serial_move_type      IN        VARCHAR2 DEFAULT NULL,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN NUMBER ;*/

FUNCTION deprn_expense_ccid(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN NUMBER;

FUNCTION search_method(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN VARCHAR2;

FUNCTION payables_ccid(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN NUMBER;

FUNCTION tag_number(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN VARCHAR2;

FUNCTION model_number(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN VARCHAR2;

FUNCTION manufacturer(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN VARCHAR2;

FUNCTION employee(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN NUMBER;

PROCEDURE is_valid_to_process(
                  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
                  x_valid_to_process    OUT NOCOPY VARCHAR2,
                  x_return_status       OUT NOCOPY VARCHAR2,
                  x_error_msg           OUT NOCOPY VARCHAR2);


FUNCTION retire_non_mtl(
p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
  p_asset_id              IN        NUMBER,
  x_error_msg             OUT NOCOPY       VARCHAR2,
  x_return_status         OUT NOCOPY       VARCHAR2
) RETURN VARCHAR2 ;
---08/03
---This function signature is different from others as there is
---no inventory_item_id attribute on  csi_i_asset_txn_temp table
---as this was a desgin change.
FUNCTION inventory_item(
  p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec
) RETURN NUMBER;

PRAGMA RESTRICT_REFERENCES(inventory_item, WNDS);

PROCEDURE get_pending_retirements (
  p_asset_query_rec         IN OUT NOCOPY cse_datastructures_pub.asset_query_rec,
  p_distribution_tbl        IN OUT NOCOPY cse_datastructures_pub.distribution_tbl,
  x_return_status           OUT NOCOPY VARCHAR2,
  x_error_msg               OUT NOCOPY VARCHAR2);

PROCEDURE get_pending_adjustments
(p_asset_query_rec IN OUT NOCOPY cse_datastructures_pub.asset_query_rec,
x_return_status           OUT NOCOPY VARCHAR2,
x_error_msg               OUT NOCOPY VARCHAR2);

PROCEDURE insert_mass_add(
  p_api_version          IN          NUMBER
, p_commit               IN          VARCHAR2
, p_init_msg_list        IN          VARCHAR2
, p_mass_add_rec         IN OUT NOCOPY      fa_mass_additions%ROWTYPE
, x_return_status        OUT NOCOPY         VARCHAR2
, x_msg_count            OUT NOCOPY         NUMBER
, x_msg_data             OUT NOCOPY         VARCHAR2 );

FUNCTION get_item_cost
(       p_inventory_item_id   IN NUMBER,
        p_organization_id     IN NUMBER
) RETURN NUMBER ;




PROCEDURE get_fa_location(
                  p_inst_loc_rec        IN cse_asset_util_pkg.inst_loc_rec
                , x_asset_location_id   OUT NOCOPY NUMBER
                , x_return_status       OUT NOCOPY VARCHAR2
                , x_error_msg           OUT NOCOPY VARCHAR2) ;

PROCEDURE   get_unit_cost(
                  p_source_txn_type  IN VARCHAR2
                , p_source_txn_id    IN NUMBER
                , p_inventory_item_id IN NUMBER
                , p_organization_id   IN NUMBER
                , x_unit_cost        OUT NOCOPY NUMBER
                , x_error_msg        OUT NOCOPY VARCHAR2
                , x_return_status    OUT NOCOPY VARCHAR2) ;

PROCEDURE is_valid_to_retire (p_asset_id IN NUMBER
                             ,p_book_type_code  IN VARCHAR2
                             ,x_valid_to_retire_flag OUT NOCOPY VARCHAR2
                             ,x_error_msg        OUT NOCOPY VARCHAR2
                             ,x_return_status    OUT NOCOPY VARCHAR2);

PROCEDURE get_txn_class (p_asset_attrib_rec      IN OUT NOCOPY CSE_DATASTRUCTURES_PUB.asset_attrib_rec,
                         x_transaction_class        OUT NOCOPY VARCHAR2,
                         x_return_status    OUT NOCOPY VARCHAR2,
                         x_error_msg        OUT NOCOPY VARCHAR2) ;

  FUNCTION get_rcv_sub_ledger_id( p_rcv_transaction_id IN number) RETURN number;

  FUNCTION get_fa_period_name (
    p_book_type_code IN varchar2,
    p_dpis           IN date)
  RETURN varchar2;

  FUNCTION get_ap_sla_acct_id(
    p_invoice_id         IN number,
    p_invoice_dist_type  IN varchar2)
  RETURN number;

  PROCEDURE validate_ccid_required (x_asset_key_required out nocopy varchar2);

END cse_asset_util_pkg ;

/
