--------------------------------------------------------
--  DDL for Package PO_PRICE_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_PRICE_HELPER" AUTHID CURRENT_USER AS
-- $Header: PO_PRICE_HELPER.pls 120.0.12010000.8 2014/07/17 10:42:47 yuandli ship $

---------------------------------------------------------------
-- Global constants and types.
---------------------------------------------------------------

-- <Bug#17063664  : PDOI source document reference ER>
-- Type for requisition pricing attributes.
type req_price_attributes is record
(
  po_line_id_tbl     PO_TBL_NUMBER
, req_line_id_tbl    PO_TBL_NUMBER
, po_org_id_tbl      PO_TBL_NUMBER
, po_currency_tbl    PO_TBL_VARCHAR30
, po_rate_tbl        PO_TBL_NUMBER
, po_rate_type_tbl   PO_TBL_VARCHAR30
, po_rate_date_tbl   PO_TBL_DATE
, po_sob_id_tbl      PO_TBL_NUMBER

, req_sob_id_tbl     PO_TBL_NUMBER
, req_order_type_tbl PO_TBL_VARCHAR30
, req_quantity_tbl   PO_TBL_NUMBER
, req_unit_price_tbl PO_TBL_NUMBER
, req_base_price_tbl PO_TBL_NUMBER
, req_curr_price_tbl PO_TBL_NUMBER
, req_currency_tbl   PO_TBL_VARCHAR30
, req_ou_curr_tbl    PO_TBL_VARCHAR30

, return_status_tbl  PO_TBL_VARCHAR30
, return_mssg_tbl    PO_TBL_VARCHAR30

, rec_count          NUMBER
);


---------------------------------------------------------------
-- Public subprograms.
---------------------------------------------------------------

  PROCEDURE attempt_line_price_update(
                                      p_order_quantity IN NUMBER
                                      , p_ship_to_org IN NUMBER
                                      , p_ship_to_loc IN NUMBER
                                      , p_po_line_id IN NUMBER
                                      , p_need_by_date IN DATE
                                      , p_line_location_id IN NUMBER
                                      , p_contract_id IN NUMBER
                                      , p_org_id IN NUMBER
                                      , p_supplier_id IN NUMBER
                                      , p_supplier_site_id IN NUMBER
                                      , p_creation_date IN DATE
                                      , p_order_header_id IN NUMBER
                                      , p_order_line_id IN NUMBER
                                      , p_line_type_id IN NUMBER
                                      , p_item_revision IN VARCHAR2
                                      , p_item_id IN NUMBER
                                      , p_category_id IN NUMBER
                                      , p_supplier_item_num IN VARCHAR2
                                      , p_uom IN VARCHAR2
                                      , p_in_price IN NUMBER
                                      , p_currency_code IN VARCHAR2
                                      , p_price_break_lookup_code IN VARCHAR2
                                      --<Enhanced Pricing Start>
                                      , p_draft_id IN NUMBER DEFAULT NULL
                                      , p_src_flag IN VARCHAR2 DEFAULT NULL
                                      , p_doc_sub_type IN VARCHAR2 DEFAULT NULL
                                      --<Enhanced Pricing End>
				      -- <Bug : Encumbrance ER : 13503748: Parameter to identify if the amount on the distributions of the line has been changed
				      ,p_amount_changed_flag IN VARCHAR2 DEFAULT NULL
                                      , x_base_unit_price OUT NOCOPY NUMBER
                                      , x_price_break_id OUT NOCOPY NUMBER
                                      , x_price OUT NOCOPY NUMBER
                                      , x_return_status OUT NOCOPY VARCHAR2
                                      , x_from_advanced_pricing OUT NOCOPY VARCHAR2
                                      , x_system_allows_update OUT NOCOPY VARCHAR2
                                      );

  PROCEDURE attempt_man_mod_pricing(
                                   p_order_quantity IN NUMBER
                                   , p_ship_to_org IN NUMBER
                                   , p_ship_to_loc IN NUMBER
                                   , p_po_line_id IN NUMBER
                                   , p_need_by_date IN DATE
                                   , p_line_location_id IN NUMBER
                                   , p_contract_id IN NUMBER
                                   , p_org_id IN NUMBER
                                   , p_supplier_id IN NUMBER
                                   , p_supplier_site_id IN NUMBER
                                   , p_creation_date IN DATE
                                   , p_order_header_id IN NUMBER
                                   , p_order_line_id IN NUMBER
                                   , p_line_type_id IN NUMBER
                                   , p_item_revision IN VARCHAR2
                                   , p_item_id IN NUMBER
                                   , p_category_id IN NUMBER
                                   , p_supplier_item_num IN VARCHAR2
                                   , p_uom IN VARCHAR2
                                   , p_in_price IN NUMBER
                                   , p_currency_code IN VARCHAR2
                                   , p_price_break_lookup_code IN VARCHAR2
                                   --<Enhanced Pricing Start: Parameters to identify calls with or without source docuemnt and document type (standard or blanket)>
                                   , p_src_flag IN VARCHAR2 DEFAULT NULL
                                   , p_doc_sub_type IN VARCHAR2 DEFAULT NULL
                                   --<Enhanced Pricing End>
                                   , x_return_status OUT NOCOPY VARCHAR2
                                   , x_system_allows_update OUT NOCOPY VARCHAR2
                                   );

  PROCEDURE check_system_allows_update(
                                       p_po_line_id IN NUMBER
                                       , p_price_break_lookup_code IN VARCHAR2
				       -- <Bug : Encumbrance ER : 13503748: Parameter to identify if the amount on the distributions of the line has been changed
				       ,p_amount_changed_flag IN VARCHAR2   DEFAULT NULL
                                       , x_system_allows_update OUT NOCOPY VARCHAR2
                                       );

  PROCEDURE no_dists_reserved(
                              p_line_id_tbl IN PO_TBL_NUMBER
 		             -- <Bug : Encumbrance ER : 13503748: Parameter to identify if the amount on the distributions of the line has been changed
			      ,p_amt_changed_flag_tbl IN PO_TBL_VARCHAR1 DEFAULT NULL
                              , x_result_set_id IN OUT NOCOPY NUMBER
                              , x_result_type OUT NOCOPY VARCHAR2
                              );

  PROCEDURE accruals_allow_update(
                                  p_line_id_tbl IN PO_TBL_NUMBER
                                  , x_results IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
                                  , x_result_type OUT NOCOPY VARCHAR2
                                  );

  PROCEDURE no_timecards_exist(
                               p_line_id_tbl IN PO_TBL_NUMBER
                               , x_results IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
                               , x_result_type OUT NOCOPY VARCHAR2
                               );

  PROCEDURE no_pending_receipts(
                                p_line_id_tbl IN PO_TBL_NUMBER
                                , x_result_set_id IN OUT NOCOPY NUMBER
                                , x_result_type OUT NOCOPY VARCHAR2
                                );

  PROCEDURE retro_account_allows_update(
                                        p_line_id_tbl IN PO_TBL_NUMBER
                                        , p_price_break_lookup_code_tbl IN PO_TBL_VARCHAR30
                                        , x_results IN OUT NOCOPY PO_VALIDATION_RESULTS_TYPE
                                        , x_result_type OUT NOCOPY VARCHAR2
                                        );

  PROCEDURE warn_amt_based_notif_ctrls(
                                       p_line_id_tbl IN PO_TBL_NUMBER
                                       , x_result_set_id IN OUT NOCOPY NUMBER
                                       , x_result_type OUT NOCOPY VARCHAR2
                                       );
  --<Bug 18372756>:
   PROCEDURE check_unvalidated_debit_memo(
      p_line_id_tbl IN PO_TBL_NUMBER
    , x_result_set_id IN OUT NOCOPY NUMBER
    , x_result_type OUT NOCOPY VARCHAR2);

  -- <Bug#17063664  : PDOI source document reference ER>
  PROCEDURE get_line_price(  x_pricing_attributes_rec IN OUT NOCOPY PO_PDOI_TYPES.pricing_attributes_rec_type
                           , x_return_status          OUT NOCOPY    VARCHAR2
                          );


END PO_PRICE_HELPER;

/
