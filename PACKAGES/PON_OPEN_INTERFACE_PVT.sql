--------------------------------------------------------
--  DDL for Package PON_OPEN_INTERFACE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_OPEN_INTERFACE_PVT" AUTHID CURRENT_USER AS
/* $Header: PON_OPEN_INTERFACE_PVT.pls 120.1.12010000.6 2015/07/08 09:42:07 vinnaray noship $ */

  g_fnd_debug          CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
  g_pkg_name           CONSTANT VARCHAR2(50) := 'PON_OPEN_INTERFACE_PVT';
  g_module_prefix      CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';
  g_interface_type     VARCHAR2(20)          := 'ITEMUPLOAD';
  g_auction_pbs_type   CONSTANT VARCHAR2(20) := 'AUCTION_PBS';
  g_null_int           CONSTANT NUMBER       := -9999;
  g_user_id            NUMBER;
  g_auction_attrs_type CONSTANT VARCHAR2(20) := 'AUCTION_ATTRS';
  g_update_action      CONSTANT VARCHAR2(20) := '#';
  g_add_action         CONSTANT VARCHAR2(20) := '+';
  g_curr_lang          VARCHAR2(10);
  g_login_id           NUMBER;
  g_trading_partner_id hz_parties.party_id%TYPE;
TYPE ATTRIBUTES_VALUES_VALIDATION
IS
  RECORD
  (
    l_BATCH_ID PON_AUC_ATTRIBUTES_INTERFACE.BATCH_ID%TYPE,
    l_INTERFACE_LINE_ID PON_AUC_ATTRIBUTES_INTERFACE.INTERFACE_LINE_ID%TYPE,
    l_AUCTION_HEADER_ID PON_AUC_ATTRIBUTES_INTERFACE.AUCTION_HEADER_ID%TYPE,
    l_AUCTION_LINE_NUMBER PON_AUC_ATTRIBUTES_INTERFACE.AUCTION_LINE_NUMBER%TYPE,
    l_SEQUENCE_NUMBER PON_AUC_ATTRIBUTES_INTERFACE.SEQUENCE_NUMBER%TYPE,
    l_ATTRIBUTE_NAME PON_AUC_ATTRIBUTES_INTERFACE.ATTRIBUTE_NAME%TYPE,
    l_DATATYPE PON_AUC_ATTRIBUTES_INTERFACE.DATATYPE%TYPE,
    l_RESPONSE_TYPE PON_AUC_ATTRIBUTES_INTERFACE.RESPONSE_TYPE%TYPE,
    l_RESPONSE_TYPE_NAME PON_AUC_ATTRIBUTES_INTERFACE.RESPONSE_TYPE_NAME%TYPE,
    l_MANDATORY_FLAG PON_AUC_ATTRIBUTES_INTERFACE.MANDATORY_FLAG%TYPE,
    l_DISPLAY_ONLY_FLAG PON_AUC_ATTRIBUTES_INTERFACE.DISPLAY_ONLY_FLAG%TYPE,
    l_DISPLAY_TARGET_FLAG PON_AUC_ATTRIBUTES_INTERFACE.DISPLAY_TARGET_FLAG%TYPE,
    l_VALUE PON_AUC_ATTRIBUTES_INTERFACE.VALUE%TYPE,
    l_GROUP_CODE PON_AUC_ATTRIBUTES_INTERFACE.GROUP_CODE%TYPE,
    l_GROUP_NAME PON_AUC_ATTRIBUTES_INTERFACE.GROUP_NAME%TYPE,
    l_SCORING_TYPE PON_AUC_ATTRIBUTES_INTERFACE.SCORING_TYPE%TYPE,
    l_ATTR_MAX_SCORE PON_AUC_ATTRIBUTES_INTERFACE.ATTR_MAX_SCORE%TYPE,
    l_WEIGHT PON_AUC_ATTRIBUTES_INTERFACE.WEIGHT%TYPE,
    l_INTERNAL_ATTR_FLAG PON_AUC_ATTRIBUTES_INTERFACE.INTERNAL_ATTR_FLAG%TYPE,
    l_SCORING_METHOD PON_AUC_ATTRIBUTES_INTERFACE.SCORING_METHOD%TYPE,
    l_KNOCKOUT_SCORE PON_AUC_ATTRIBUTES_INTERFACE.KNOCKOUT_SCORE%TYPE,
    l_ACTION PON_AUC_ATTRIBUTES_INTERFACE.ACTION%TYPE,
    l_ATTRIBUTE PON_AUC_ATTRIBUTES_INTERFACE.ATTRIBUTE%TYPE
);
TYPE ATTRIBUTE_SCORES
IS
  RECORD
  (
    l_interface_header_id PON_ATTRIBUTE_SCORES_INTERFACE.interface_header_id%TYPE,
    l_interface_line_id  PON_ATTRIBUTE_SCORES_INTERFACE.interface_line_id%TYPE,
    l_BATCH_ID PON_ATTRIBUTE_SCORES_INTERFACE.BATCH_ID%TYPE,
    l_AUCTION_HEADER_ID PON_ATTRIBUTE_SCORES_INTERFACE.AUCTION_HEADER_ID%TYPE ,
    l_LINE_NUMBER PON_ATTRIBUTE_SCORES_INTERFACE.LINE_NUMBER%TYPE ,
    l_ATTRIBUTE_SEQUENCE_NUMBER PON_ATTRIBUTE_SCORES_INTERFACE.ATTRIBUTE_SEQUENCE_NUMBER%TYPE ,
    l_VALUE PON_ATTRIBUTE_SCORES_INTERFACE.VALUE%TYPE ,
    l_FROM_RANGE PON_ATTRIBUTE_SCORES_INTERFACE.FROM_RANGE%TYPE ,
    l_TO_RANGE PON_ATTRIBUTE_SCORES_INTERFACE.TO_RANGE%TYPE,
    l_SCORE PON_ATTRIBUTE_SCORES_INTERFACE.SCORE%TYPE ,
    l_SEQUENCE_NUMBER PON_ATTRIBUTE_SCORES_INTERFACE.SEQUENCE_NUMBER%TYPE ,
    l_ACTION PON_ATTRIBUTE_SCORES_INTERFACE.ACTION%TYPE,
    l_CREATION_DATE PON_ATTRIBUTE_SCORES_INTERFACE.CREATION_DATE%TYPE,
    l_CREATED_BY PON_ATTRIBUTE_SCORES_INTERFACE.CREATED_BY%TYPE,
    l_LAST_UPDATE_DATE PON_ATTRIBUTE_SCORES_INTERFACE.LAST_UPDATE_DATE%TYPE,
    l_LAST_UPDATED_BY PON_ATTRIBUTE_SCORES_INTERFACE.LAST_UPDATED_BY%TYPE
    );

TYPE neg_header_record IS RECORD
  (
  auction_header_id       pon_auction_Headers_all.auction_header_id%TYPE,
  document_number         pon_auction_headers_all.document_number%TYPE,
  auction_title           pon_auction_headers_all.auction_title%TYPE,
  description             pon_auction_headers_all.description%TYPE,
  auction_status          pon_auction_headers_all.auction_status%TYPE,
  auction_type            pon_auction_headers_all.auction_type%TYPE,
  contract_type           pon_auction_headers_all.contract_type%TYPE,
  trading_partner_name    pon_auction_headers_all.trading_partner_name%TYPE,
  trading_partner_id      pon_auction_headers_all.trading_partner_id%TYPE,
  trading_partner_contact_id pon_auction_headers_all.trading_partner_contact_id%TYPE,
  bid_visibility_code     pon_auction_headers_all.bid_visibility_code%TYPE,
  creation_date           pon_auction_headers_all.creation_date%TYPE,
  created_by              pon_auction_headers_all.created_by%TYPE,
  last_update_date        pon_auction_headers_all.last_update_date%TYPE,
  last_updated_by         pon_auction_headers_all.last_updated_by%TYPE,
  doctype_id              pon_auction_headers_all.doctype_id%TYPE,
  org_id                  pon_auction_headers_all.org_id%TYPE,
  buyer_id                pon_auction_headers_all.buyer_id%TYPE,
  approval_status 		          pon_auction_headers_all.approval_status%TYPE,
  global_agreement_flag 		    pon_auction_headers_all.global_agreement_flag%TYPE,
  style_id 		                  pon_auction_headers_all.style_id%TYPE,
  po_style_id 		              pon_auction_headers_all.po_style_id%TYPE,
  po_style_name                 pon_auction_headers_interface.po_style_name%TYPE,
  price_break_response 		      pon_auction_headers_all.price_break_response%TYPE,
  advance_negotiable_flag 		  pon_auction_headers_all.advance_negotiable_flag%TYPE,
  recoupment_negotiable_flag 		pon_auction_headers_all.recoupment_negotiable_flag%TYPE,
  progress_pymt_negotiable_flag pon_auction_headers_all.progress_pymt_negotiable_flag%TYPE,
  retainage_negotiable_flag 		pon_auction_headers_all.retainage_negotiable_flag%TYPE,
  max_retainage_negotiable_flag pon_auction_headers_all.max_retainage_negotiable_flag%TYPE,
  supplier_enterable_pymt_flag  pon_auction_headers_all.supplier_enterable_pymt_flag%TYPE,
  progress_payment_type 		    pon_auction_headers_all.progress_payment_type%TYPE,
  progress_payment_flag 		    po_doc_style_headers.progress_payment_flag%TYPE,
  line_attribute_enabled_flag 	pon_auction_headers_all.line_attribute_enabled_flag%TYPE,
  line_mas_enabled_flag 		    pon_auction_headers_all.line_mas_enabled_flag%TYPE,
  price_element_enabled_flag 		pon_auction_headers_all.price_element_enabled_flag%TYPE,
  rfi_line_enabled_flag 		    pon_auction_headers_all.rfi_line_enabled_flag%TYPE,
  lot_enabled_flag 		          pon_auction_headers_all.lot_enabled_flag%TYPE,
  group_enabled_flag 		        pon_auction_headers_all.group_enabled_flag%TYPE,
  large_neg_enabled_flag 		    pon_auction_headers_all.large_neg_enabled_flag%TYPE,
  hdr_attribute_enabled_flag 		pon_auction_headers_all.hdr_attribute_enabled_flag%TYPE,
  neg_team_enabled_flag 		    pon_auction_headers_all.neg_team_enabled_flag%TYPE,
  proxy_bidding_enabled_flag 		pon_auction_headers_all.proxy_bidding_enabled_flag%TYPE,
  power_bidding_enabled_flag 		pon_auction_headers_all.power_bidding_enabled_flag%TYPE,
  auto_extend_enabled_flag 		  pon_auction_headers_all.auto_extend_enabled_flag%TYPE,
  team_scoring_enabled_flag 		pon_auction_headers_all.team_scoring_enabled_flag%TYPE,
  price_tiers_indicator 		    pon_auction_headers_all.price_tiers_indicator%TYPE,
  qty_price_tiers_enabled_flag  pon_auction_headers_all.qty_price_tiers_enabled_flag%TYPE,
  ship_to_location_id 		      pon_auction_headers_all.ship_to_location_id%TYPE,
  bill_to_location_id 		      pon_auction_headers_all.bill_to_location_id%TYPE,
  ship_to_location_code 	      pon_auction_headers_interface.ship_to_location_code%TYPE,
  bill_to_location_code	        pon_auction_headers_interface.bill_to_location_code%TYPE,
  payment_terms_id 		          pon_auction_headers_all.payment_terms_id%TYPE,
  fob_code 		                  pon_auction_headers_all.fob_code%TYPE,
  freight_terms_code 		        pon_auction_headers_all.freight_terms_code%TYPE,
  rate_type 		                pon_auction_headers_all.rate_type%TYPE,
  currency_code 		            pon_auction_headers_all.currency_code%TYPE,
  security_level_code 		      pon_auction_headers_all.security_level_code%TYPE,
  po_start_date 		            pon_auction_headers_all.po_start_date%TYPE,
  po_end_date 		              pon_auction_headers_all.po_end_date%TYPE,
  open_auction_now_flag 		    pon_auction_headers_all.open_auction_now_flag%TYPE,
  open_bidding_date 		        pon_auction_headers_all.open_bidding_date%TYPE,
  close_bidding_date 		        pon_auction_headers_all.close_bidding_date%TYPE,
  publish_auction_now_flag 		  pon_auction_headers_all.publish_auction_now_flag%TYPE,
  --auction_published_flag        pon_auction_headers_interface.auction_published_flag%TYPE,
  view_by_date 		              pon_auction_headers_all.view_by_date%TYPE,
  note_to_bidders 		          pon_auction_headers_all.note_to_bidders%TYPE,
  show_bidder_notes 		        pon_auction_headers_all.show_bidder_notes%TYPE,
  bid_scope_code 		            pon_auction_headers_all.bid_scope_code%TYPE,
  bid_list_type 		            pon_auction_headers_all.bid_list_type%TYPE,
  bid_frequency_code 		        pon_auction_headers_all.bid_frequency_code%TYPE,
  bid_ranking 		              pon_auction_headers_all.bid_ranking%TYPE,
  rank_indicator 		            pon_auction_headers_all.rank_indicator%TYPE,
  full_quantity_bid_code 		    pon_auction_headers_all.full_quantity_bid_code%TYPE,
  multiple_rounds_flag 		      pon_auction_headers_all.multiple_rounds_flag%TYPE,
  manual_close_flag 		        pon_auction_headers_all.manual_close_flag%TYPE,
  manual_extend_flag 		        pon_auction_headers_all.manual_extend_flag%TYPE,
  award_approval_flag 		      pon_auction_headers_all.award_approval_flag%TYPE,
  auction_origination_code 		  pon_auction_headers_all.auction_origination_code%TYPE,
  pf_type_allowed 		          pon_auction_headers_all.pf_type_allowed%TYPE,
  hdr_attr_enable_weights 		  pon_auction_headers_all.hdr_attr_enable_weights%TYPE,
  trading_partner_contact_name 	pon_auction_headers_all.trading_partner_contact_name%TYPE,
  award_by_date 		            pon_auction_headers_all.award_by_date%TYPE,
  publish_date 		              pon_auction_headers_all.publish_date%TYPE,
  auto_extend_flag 		          pon_auction_headers_all.auto_extend_flag%TYPE,
  auto_extend_number 		        pon_auction_headers_all.auto_extend_number%TYPE,
  min_bid_decrement 		        pon_auction_headers_all.min_bid_decrement%TYPE,
  min_bid_change_type 		      pon_auction_headers_all.min_bid_change_type%TYPE,
  price_driven_auction_flag 		pon_auction_headers_all.price_driven_auction_flag%TYPE,
  carrier_code 		              pon_auction_headers_all.carrier_code%TYPE,
  rate_date 		                pon_auction_headers_all.rate_date%TYPE,
  auto_extend_all_lines_flag 		pon_auction_headers_all.auto_extend_all_lines_flag%TYPE,
  allow_other_bid_currency_flag pon_auction_headers_all.allow_other_bid_currency_flag%TYPE,
  shipping_terms_code 		      pon_auction_headers_all.shipping_terms_code%TYPE,
  auto_extend_duration 		      pon_auction_headers_all.auto_extend_duration%TYPE,
  proxy_bid_allowed_flag 		    pon_auction_headers_all.proxy_bid_allowed_flag%TYPE,
  publish_rates_to_bidders_flag pon_auction_headers_all.publish_rates_to_bidders_flag%TYPE,
  event_id 		                  pon_auction_headers_all.event_id%TYPE,
  event_title 		              pon_auction_headers_all.event_title%TYPE,
  sealed_auction_status 		    pon_auction_headers_all.sealed_auction_status%TYPE,
  number_price_decimals 		    pon_auction_headers_all.number_price_decimals%TYPE,
  auto_extend_type_flag 		    pon_auction_headers_all.auto_extend_type_flag%TYPE,
  max_responses 		            pon_auction_headers_all.max_responses%TYPE,
  response_allowed_flag 		    pon_auction_headers_all.response_allowed_flag%TYPE,
  contract_id 		              pon_auction_headers_all.contract_id%TYPE,
  contract_version_num 		      pon_auction_headers_all.contract_version_num%TYPE,
  show_bidder_scores 		        pon_auction_headers_all.show_bidder_scores%TYPE,
  po_min_rel_amount 		        pon_auction_headers_all.po_min_rel_amount%TYPE,
  po_agreed_amount 		          pon_auction_headers_all.po_agreed_amount%TYPE,
  hdr_attr_display_score 		    pon_auction_headers_all.hdr_attr_display_score%TYPE,
  hdr_attr_maximum_score 		    pon_auction_headers_all.hdr_attr_maximum_score%TYPE,
  int_attribute_category 		    pon_auction_headers_all.int_attribute_category%TYPE,
  int_attribute1 		            pon_auction_headers_all.int_attribute1%TYPE,
  int_attribute2 		            pon_auction_headers_all.int_attribute2%TYPE,
  int_attribute3 		            pon_auction_headers_all.int_attribute3%TYPE,
  int_attribute4 		            pon_auction_headers_all.int_attribute4%TYPE,
  int_attribute5 		            pon_auction_headers_all.int_attribute5%TYPE,
  int_attribute6 		            pon_auction_headers_all.int_attribute6%TYPE,
  int_attribute7 		            pon_auction_headers_all.int_attribute7%TYPE,
  int_attribute8 		            pon_auction_headers_all.int_attribute8%TYPE,
  int_attribute9 		            pon_auction_headers_all.int_attribute9%TYPE,
  int_attribute10 		          pon_auction_headers_all.int_attribute10%TYPE,
  int_attribute11 		          pon_auction_headers_all.int_attribute11%TYPE,
  int_attribute12  		          pon_auction_headers_all.int_attribute12%TYPE,
  int_attribute13  		          pon_auction_headers_all.int_attribute13%TYPE,
  int_attribute14  		          pon_auction_headers_all.int_attribute14%TYPE,
  int_attribute15 		          pon_auction_headers_all.int_attribute15%TYPE,
  ext_attribute_category 		    pon_auction_headers_all.ext_attribute_category%TYPE,
  ext_attribute1 		            pon_auction_headers_all.ext_attribute1%TYPE,
  ext_attribute2 		            pon_auction_headers_all.ext_attribute2%TYPE,
  ext_attribute3 		            pon_auction_headers_all.ext_attribute3%TYPE,
  ext_attribute4 		            pon_auction_headers_all.ext_attribute4%TYPE,
  ext_attribute5  		          pon_auction_headers_all.ext_attribute5%TYPE,
  ext_attribute6  		          pon_auction_headers_all.ext_attribute6%TYPE,
  ext_attribute7  		          pon_auction_headers_all.ext_attribute7%TYPE,
  ext_attribute8 		            pon_auction_headers_all.ext_attribute8%TYPE,
  ext_attribute9 		            pon_auction_headers_all.ext_attribute9%TYPE,
  ext_attribute10 		          pon_auction_headers_all.ext_attribute10%TYPE,
  ext_attribute11 		          pon_auction_headers_all.ext_attribute11%TYPE,
  ext_attribute12 		          pon_auction_headers_all.ext_attribute12%TYPE,
  ext_attribute13 		          pon_auction_headers_all.ext_attribute13%TYPE,
  ext_attribute14  		          pon_auction_headers_all.ext_attribute14%TYPE,
  ext_attribute15 		          pon_auction_headers_all.ext_attribute15%TYPE,
  abstract_details 		          pon_auction_headers_all.abstract_details%TYPE,
  supplier_view_type 		        pon_auction_headers_all.supplier_view_type%TYPE,
  project_id  		              pon_auction_headers_all.project_id%TYPE,
  has_scoring_teams_flag  		  pon_auction_headers_all.has_scoring_teams_flag%TYPE,
  bid_decrement_method 		      pon_auction_headers_all.bid_decrement_method%TYPE,
  display_best_price_blind_flag pon_auction_headers_all.display_best_price_blind_flag%TYPE,
  first_line_close_date  		    pon_auction_headers_all.first_line_close_date%TYPE,
  staggered_closing_interval  	pon_auction_headers_all.staggered_closing_interval%TYPE,
  enforce_prevrnd_bid_price_flag  pon_auction_headers_all.enforce_prevrnd_bid_price_flag%TYPE,
  auto_extend_min_trigger_rank  pon_auction_headers_all.auto_extend_min_trigger_rank%TYPE,
  two_part_flag  		            pon_auction_headers_all.two_part_flag%TYPE,
  supp_reg_qual_flag 		        pon_auction_headers_all.supp_reg_qual_flag%TYPE,
  supp_eval_flag 		            pon_auction_headers_all.supp_eval_flag%TYPE,
  hide_terms_flag 		          pon_auction_headers_all.hide_terms_flag%TYPE,
  hide_abstract_forms_flag 		  pon_auction_headers_all.hide_abstract_forms_flag%TYPE,
  hide_attachments_flag 		    pon_auction_headers_all.hide_attachments_flag%TYPE,
  internal_eval_flag 		        pon_auction_headers_all.internal_eval_flag%TYPE,
  hdr_supp_attr_enabled_flag 		pon_auction_headers_all.hdr_supp_attr_enabled_flag%TYPE,
  intgr_hdr_attr_flag 		      pon_auction_headers_all.intgr_hdr_attr_flag%TYPE,
  intgr_hdr_attach_flag 		    pon_auction_headers_all.intgr_hdr_attach_flag%TYPE,
  line_supp_attr_enabled_flag 	pon_auction_headers_all.line_supp_attr_enabled_flag%TYPE,
  item_supp_attr_enabled_flag 	pon_auction_headers_all.item_supp_attr_enabled_flag%TYPE,
  intgr_cat_line_attr_flag 		  pon_auction_headers_all.intgr_cat_line_attr_flag%TYPE,
  intgr_item_line_attr_flag 		pon_auction_headers_all.intgr_item_line_attr_flag%TYPE,
  intgr_cat_line_asl_flag 		  pon_auction_headers_all.intgr_cat_line_asl_flag%TYPE,
  internal_only_flag 		        pon_auction_headers_all.internal_only_flag%TYPE
  );

TYPE org_default_data IS RECORD(
  org_id pon_auction_headers_all.org_id%TYPE,
  bill_to_location_id pon_auction_headers_all.bill_to_location_id%TYPE,
  ship_to_location_id pon_auction_headers_all.ship_to_location_id%TYPE,
  payment_terms_id pon_auction_headers_all.payment_terms_id%TYPE,
  fob_code pon_auction_headers_all.fob_code%TYPE,
  freight_terms_code pon_auction_headers_all.freight_terms_code%TYPE,
  rate_type pon_auction_headers_all.rate_type%TYPE,
  currency_code pon_auction_headers_all.currency_code%TYPE,
  security_level_code pon_auction_headers_all.security_level_code%TYPE
);

--g_interface_type     VARCHAR2(20)          := 'HEADERUPLOAD';


PROCEDURE create_header_attr_inter
  (
    p_commit        IN VARCHAR2,
    batchId         IN NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2);

PROCEDURE print_log
  ( p_module  IN VARCHAR2,
    p_message IN VARCHAR2);

PROCEDURE acceptance_values_insert
  (
    p_interface_attr_rec1  IN ATTRIBUTES_VALUES_VALIDATION,
    p_sequence_number_attr IN pon_attribute_scores_interface.ATTRIBUTE_SEQUENCE_NUMBER%TYPE,
    l_status               IN OUT NOCOPY VARCHAR2);

PROCEDURE check_range_overlap
  (
    p_attr_score_rec IN ATTRIBUTE_SCORES,
    p_datatype       IN pon_auc_attributes_interface.datatype%type,
    l_status         OUT NOCOPY VARCHAR2 ) ;

PROCEDURE create_neg_team
  (
    p_commit        IN VARCHAR2,
    batchId         IN NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2 );

PROCEDURE create_members_in_collteam
  (
    batchid            IN NUMBER,
    username              IN VARCHAR2,
    ispreparer            IN VARCHAR2, -- 'Y'/'N'
    menu_name             IN VARCHAR2, -- 'PON_SOURCING_EDITNEG'/'PON_SOURCING_VIEWNEG'/'PON_SOURCING_SCORENEG'
    approver_flag         IN VARCHAR2, -- 'Y'/'N'
    auction_header_id     IN NUMBER,
    task_name             IN VARCHAR2,
    target_date           IN DATE,
    manager_approver_flag IN VARCHAR2,
    x_return_status       IN OUT NOCOPY VARCHAR2 );

PROCEDURE insert_collabteam_member
  (
    auction_header_id IN NUMBER,
    user_id           IN NUMBER,
    user_name         IN VARCHAR2,
    menu_name         IN VARCHAR2,
    member_type       IN VARCHAR2,
    approver_flag     IN VARCHAR2,
    task_name         IN VARCHAR2,
    target_date       IN DATE,
    creation_date     IN DATE,
    created_by        IN NUMBER,
    last_update_date  IN DATE,
    last_updated_by   IN NUMBER);

FUNCTION check_uniqueness
    (
      p_user_id           IN NUMBER,
      p_auction_header_id IN NUMBER,
      ispreparer          IN VARCHAR2)
    RETURN BOOLEAN;

PROCEDURE invite_supplier
  (
    p_batch_id IN NUMBER,
    x_return_status IN OUT NOCOPY VARCHAR2
  );

PROCEDURE validate_invited_suppliers(p_batch_id IN NUMBER);

PROCEDURE create_lines_with_children
    (
      p_batch_id          IN NUMBER,
      p_auction_Header_id IN NUMBER,
      x_return_status     IN OUT NOCOPY VARCHAR2);


PROCEDURE add_price_breaks
    (
      p_batch_id          IN NUMBER ,
      p_auction_header_id IN NUMBER,
      x_result            IN OUT NOCOPY VARCHAR2,
      x_error_code        OUT NOCOPY VARCHAR2,
      x_error_message     OUT NOCOPY VARCHAR2 );

PROCEDURE VAL_PRICE_BREAKS
    (
      p_auction_header_id  IN NUMBER,
      p_close_bidding_date IN DATE,
      p_request_id         IN NUMBER,
      p_expiration_date    IN DATE,
      p_user_id            IN NUMBER,
      p_login_id           IN NUMBER,
      p_batch_id           IN NUMBER,
      p_precision          IN NUMBER,
      p_po_start_date      IN DATE,
      p_po_end_date        IN DATE );

PROCEDURE VAL_ATTR_SCORES
    (
      p_auction_header_id IN NUMBER,
      p_request_id        IN NUMBER,
      p_expiration_date   IN DATE,
      p_user_id           IN NUMBER,
      p_login_id          IN NUMBER,
      p_batch_id          IN NUMBER );


PROCEDURE create_negotiations(
                              p_group_batch_id IN NUMBER,
                              x_return_status  IN OUT NOCOPY VARCHAR2,
                              x_msg_count      OUT NOCOPY NUMBER,
                              x_msg_data       OUT NOCOPY varchar2
                             );

PROCEDURE create_negotiation(
                              p_batch_id          IN NUMBER,
                              x_auction_header_id OUT NOCOPY NUMBER,
                              x_return_status     IN OUT NOCOPY VARCHAR2
                            );


PROCEDURE create_negotiation_header
(
  p_batch_id      IN NUMBER,
  x_return_status IN OUT NOCOPY VARCHAR2
);

PROCEDURE process_negotiation_header(
                                     p_batch_id          IN NUMBER,
                                     p_tp_id             IN NUMBER,
                                     x_auction_header_id OUT NOCOPY NUMBER,
                                     x_return_status     IN OUT NOCOPY VARCHAR2
                                    );

PROCEDURE validate_header(
  --c_inter_cursor_rec IN c_inter_header%ROWTYPE,
  p_batch_id IN NUMBER,
  p_tp_id    IN NUMBER,
  p_is_amendment IN VARCHAR2,
  p_src_auction_header_id IN NUMBER
);

PROCEDURE populate_neg_header_rec(p_batch_id IN NUMBER,
                                  p_is_amendment IN VARCHAR2,
                                  p_src_auction_header_id IN NUMBER);

PROCEDURE init_rule_based_header_data(p_is_amendment IN VARCHAR2,
                                      p_src_auction_Header_id IN NUMBER);

PROCEDURE insert_error (p_error_msg IN VARCHAR2 ,
                        p_batch_id IN NUMBER,
                        p_entity_type IN VARCHAR2,
                        p_auction_header_id IN NUMBER,
                        p_user_id IN NUMBER,
                        p_user_login IN number);

PROCEDURE line_sanity_validation(p_batch_id IN NUMBER );

END PON_OPEN_INTERFACE_PVT;

/
