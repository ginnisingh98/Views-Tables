--------------------------------------------------------
--  DDL for Package PON_AUCTION_CREATE_PO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_AUCTION_CREATE_PO_PKG" AUTHID CURRENT_USER as
/* $Header: PONCRPOS.pls 120.6.12010000.2 2012/05/31 06:12:42 spapana ship $ */

TYPE SumOfReqLineAllocQuantities is TABLE OF NUMBER
     INDEX BY BINARY_INTEGER;

TYPE PDOIheader IS RECORD (
          auction_header_id 	pon_auction_headers_all.auction_header_id%TYPE,
          document_number 	pon_auction_headers_all.document_number%TYPE,
          org_id 		pon_auction_headers_all.org_id%TYPE,
          contract_type 	pon_auction_headers_all.contract_type%TYPE,
	  language_code	 	pon_auction_headers_all.language_code%TYPE,
          po_start_date 	pon_auction_headers_all.po_start_date%TYPE,
          po_end_date 		pon_auction_headers_all.po_end_date%TYPE,
          currency_code 	pon_auction_headers_all.currency_code%TYPE,
          fob_code 		pon_auction_headers_all.fob_code%TYPE,
          freight_terms_code 	pon_auction_headers_all.freight_terms_code%TYPE,
          carrier_code 		pon_auction_headers_all.carrier_code%TYPE,
          payment_terms_id 	pon_auction_headers_all.payment_terms_id%TYPE,
          ship_to_location_id 	pon_auction_headers_all.ship_to_location_id%TYPE,
          bill_to_location_id 	pon_auction_headers_all.bill_to_location_id%TYPE,
          auction_origination_code pon_auction_headers_all.auction_origination_code%TYPE,
          source_reqs_flag pon_auction_headers_all.source_reqs_flag%TYPE,
          bid_number pon_bid_headers.bid_number%TYPE,
          order_number pon_bid_headers.order_number%TYPE,
          vendor_id pon_bid_headers.vendor_id%TYPE,
          vendor_site_id pon_bid_headers.vendor_site_id%TYPE,
          vendor_contact_id pon_bid_headers.trading_partner_contact_id%TYPE,
          agent_id pon_bid_headers.agent_id%TYPE,
          global_agreement_flag pon_auction_headers_all.global_agreement_flag%TYPE,
          po_min_rel_amount pon_auction_headers_all.po_min_rel_amount%TYPE,
          po_agreed_amount pon_bid_headers.po_agreed_amount%TYPE,
          bid_currency_code pon_bid_headers.bid_currency_code%TYPE,
          rate_type 			pon_auction_headers_all.rate_type%TYPE,
          rate_date 			pon_auction_headers_all.rate_date%TYPE,
          rate_dsp 			pon_bid_headers.rate_dsp%TYPE,
          create_sourcing_rules 	pon_bid_headers.create_sourcing_rules%TYPE,
          update_sourcing_rules 	pon_bid_headers.update_sourcing_rules%TYPE,
          release_method 		pon_bid_headers.release_method%TYPE,
          initiate_approval 		pon_bid_headers.initiate_approval%TYPE,
          acceptance_required_flag  	pon_bid_headers.acceptance_required_flag%TYPE,
	  po_style_id 			pon_auction_headers_all.po_style_id%TYPE,
           progress_payment_type         pon_auction_headers_all.progress_payment_type%TYPE,
           supplier_enterable_pymt_flag  pon_auction_headers_all.supplier_enterable_pymt_flag%TYPE
);

TYPE PDOIline IS RECORD (
          line_number pon_auction_item_prices_all.line_number%TYPE,
          line_type_id pon_auction_item_prices_all.line_type_id%TYPE,
          order_type_lookup_code pon_auction_item_prices_all.order_type_lookup_code%TYPE,
          line_origination_code pon_auction_item_prices_all.line_origination_code%TYPE,
          item_id pon_auction_item_prices_all.item_id%TYPE,
          item_revision pon_auction_item_prices_all.item_revision%TYPE,
          category_id pon_auction_item_prices_all.category_id%TYPE,
          item_description pon_auction_item_prices_all.item_description%TYPE,
          unit_of_measure mtl_units_of_measure.unit_of_measure%TYPE,
          ship_to_location_id pon_auction_item_prices_all.ship_to_location_id%TYPE,
          need_by_start_date pon_auction_item_prices_all.need_by_start_date%TYPE,
          award_quantity pon_bid_item_prices.award_quantity%TYPE,
          po_min_rel_amount pon_auction_item_prices_all.po_min_rel_amount%TYPE,
          has_price_elements_flag pon_auction_item_prices_all.has_price_elements_flag%TYPE,
          bid_currency_unit_price pon_bid_item_prices.bid_currency_unit_price%TYPE,
          promised_date pon_bid_item_prices.promised_date%TYPE,
          job_id pon_auction_item_prices_all.job_id%TYPE,
          po_agreed_amount pon_auction_item_prices_all.po_agreed_amount%TYPE,
          purchase_basis pon_auction_item_prices_all.purchase_basis%TYPE,
          bid_curr_advance_amount     pon_bid_item_prices.bid_curr_advance_amount%TYPE,
          recoupment_rate_percent     pon_bid_item_prices.recoupment_rate_percent%TYPE,
          progress_pymt_rate_percent  pon_bid_item_prices.progress_pymt_rate_percent%TYPE,
          retainage_rate_percent      pon_bid_item_prices.retainage_rate_percent%TYPE,
          bid_curr_max_retainage_amt  pon_bid_item_prices.bid_curr_max_retainage_amt%TYPE,
          has_bid_payments_flag       pon_bid_item_prices.has_bid_payments_flag%TYPE,
          award_shipment_number       pon_bid_item_prices.award_shipment_number%TYPE
  );

procedure AUTO_ALLOC_AND_SPLIT_REQ(p_auction_header_id           IN    NUMBER,       -- 1
                            p_user_name                   IN    VARCHAR2,     -- 2
                            p_user_id                     IN    NUMBER,       -- 3
                            p_formatted_name              IN    VARCHAR2,     -- 4
                            p_auction_title               IN    VARCHAR2,     -- 5
                            p_organization_name           IN    VARCHAR2,
			    p_resultout			  OUT NOCOPY VARCHAR2,
			    x_allocation_error		  OUT NOCOPY VARCHAR2,
			    x_line_number		  OUT NOCOPY NUMBER,
			    x_item_number		  OUT NOCOPY VARCHAR2,
			    x_item_description		  OUT NOCOPY VARCHAR2,
			    x_item_revision		  OUT NOCOPY VARCHAR2,
			    x_requisition_number	  OUT NOCOPY VARCHAR2,
			    x_job_name			  OUT NOCOPY VARCHAR2,
			    x_document_disp_line_number	  OUT NOCOPY VARCHAR2);


procedure ALLOC_ALL_UNALLOC_ITEMS(p_auction_header_id  IN NUMBER,
                                  p_allocation_result  OUT NOCOPY VARCHAR2,
                                  p_failure_reason     OUT NOCOPY VARCHAR2,
                                  p_item_line_number   OUT NOCOPY NUMBER,
                                  p_item_number        OUT NOCOPY VARCHAR2,
                                  p_item_description   OUT NOCOPY VARCHAR2,
                                  p_item_revision      OUT NOCOPY VARCHAR2,
                                  p_requisition_number OUT NOCOPY VARCHAR2,
                                  p_job_name           OUT NOCOPY VARCHAR2,
                                  p_document_disp_line_number OUT NOCOPY VARCHAR2);

PROCEDURE SPLIT_REQ_LINES(p_auction_header_id    IN NUMBER,
                          p_split_result         OUT NOCOPY VARCHAR2,
                          p_split_failure_reason OUT NOCOPY VARCHAR2,
			  p_item_line_number     OUT NOCOPY NUMBER,
                          p_item_number          OUT NOCOPY VARCHAR2,
                          p_item_description     OUT NOCOPY VARCHAR2,
                          p_item_revision        OUT NOCOPY VARCHAR2,
                          p_requisition_number   OUT NOCOPY VARCHAR2,
                          p_job_name             OUT NOCOPY VARCHAR2);

PROCEDURE Auto_Req_Allocation(p_auctionID     IN  NUMBER,
                              p_line_number   IN  NUMBER,
                              p_result        OUT NOCOPY VARCHAR2,
                              p_error_message OUT NOCOPY VARCHAR2);


PROCEDURE START_PO_WORKFLOW(p_auction_header_id           IN    NUMBER,       -- 1
                            p_user_name                   IN    VARCHAR2,     -- 2
                            p_user_id                     IN    NUMBER,       -- 3
                            p_formatted_name              IN    VARCHAR2,     -- 4
                            p_auction_title               IN    VARCHAR2,     -- 5
                            p_organization_name           IN    VARCHAR2,
			    p_email_type		  IN    VARCHAR2,
			    p_itemkey			  IN    VARCHAR2,
			    x_allocation_error		  OUT NOCOPY VARCHAR2,
			    x_line_number		  OUT NOCOPY NUMBER,
			    x_item_number		  OUT NOCOPY VARCHAR2,
			    x_item_description		  OUT NOCOPY VARCHAR2,
			    x_item_revision		  OUT NOCOPY VARCHAR2,
			    x_requisition_number	  OUT NOCOPY VARCHAR2,
			    x_job_name			  OUT NOCOPY VARCHAR2,
			    x_document_disp_line_number	  OUT NOCOPY VARCHAR2);

PROCEDURE START_PO_CREATION(EFFBUF           OUT NOCOPY VARCHAR2, -- std. out param for concurrent program
          		    RETCODE          OUT NOCOPY VARCHAR2, -- std. out param for concurrent program
			    p_auction_header_id           IN    NUMBER,       -- 1
                            p_user_name                   IN    VARCHAR2,     -- 2
                            p_user_id                     IN    NUMBER,       -- 3
                            p_formatted_name              IN    VARCHAR2,     -- 4
                            p_auction_title               IN    VARCHAR2,     -- 5
                            p_organization_name           IN    VARCHAR2,    -- 6
			    p_resultout			  OUT NOCOPY VARCHAR2); -- 7

procedure GENERATE_POS(p_auction_header_id	IN    NUMBER,       -- 1
                            p_user_name		IN    VARCHAR2,     -- 2
                            p_user_id		IN    NUMBER,       -- 3
			    p_resultout		OUT NOCOPY VARCHAR2);


PROCEDURE CREATE_PO_STRUCTURE(p_auction_header_id           IN NUMBER,
                              p_bid_number                  IN NUMBER,
			      p_user_id			    IN NUMBER,
                              p_interface_header_id         OUT NOCOPY NUMBER,
                              p_pdoi_header                 OUT NOCOPY PDOIheader,
                              p_error_code                  OUT NOCOPY VARCHAR2,
                              p_error_message               OUT NOCOPY VARCHAR2);


PROCEDURE LAUNCH_PO_APPROVAL (p_po_header_id    IN 	NUMBER,
                              p_pdoi_header     IN 	PDOIheader,
			      p_user_id		IN 	NUMBER
);

PROCEDURE CHECK_PO_STATUS(itemtype               IN  VARCHAR2,
                          itemkey                IN  VARCHAR2,
                          actid                  IN  NUMBER,
                          uncmode                IN  VARCHAR2,
                          resultout              OUT NOCOPY VARCHAR2);


PROCEDURE GENERATE_PO_SUCCESS_EMAIL(document_id     IN VARCHAR2,
                                    display_type    IN VARCHAR2,
                                    document        IN OUT NOCOPY VARCHAR2,
                                    document_type   IN OUT NOCOPY VARCHAR2);

PROCEDURE GENERATE_PO_FAILURE_EMAIL(document_id     IN VARCHAR2,
                                    display_type    IN VARCHAR2,
                                    document        IN OUT NOCOPY VARCHAR2,
                                    document_type   IN OUT NOCOPY VARCHAR2);


procedure CHECK_PO_EMAIL_TYPE (itemtype               IN VARCHAR2,
                                    itemkey                IN VARCHAR2,
                                    actid                  IN NUMBER,
                                    uncmode                IN VARCHAR2,
                                    resultout              OUT NOCOPY VARCHAR2);

PROCEDURE INSERT_IP_DESCRIPTORS(p_auction_header_id      IN  NUMBER,
                                p_bid_number             IN  NUMBER,
                                p_interface_header_id    IN  NUMBER,
                                p_user_id                IN  NUMBER,
                                p_login_id               IN  NUMBER,
                                p_batch_start            IN  NUMBER,
                                p_batch_end              IN  NUMBER);

FUNCTION get_vendor_contact_id(
      p_trading_partner_contact_id IN NUMBER,
      p_vendor_site_id             IN NUMBER,
      p_vendor_id                  IN NUMBER)
    RETURN NUMBER;


END PON_AUCTION_CREATE_PO_PKG;

/
