--------------------------------------------------------
--  DDL for Package PON_CONTERMS_UTL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_CONTERMS_UTL_PVT" AUTHID CURRENT_USER as
/* $Header: PONCTDPS.pls 120.1.12010000.2 2009/01/05 05:50:47 amundhra ship $ */

-- package name for logging
g_pkg_name CONSTANT VARCHAR2(30) := 'PON_CONTERMS_UTL_PVT';

-- constants for contracts doc types
AUCTION 		CONSTANT  varchar2(30) := 'AUCTION';
REQUEST_FOR_QUOTE 	CONSTANT  varchar2(30) := 'RFQ';
REQUEST_FOR_INFORMATION CONSTANT  varchar2(30) := 'RFI';
BID                     CONSTANT  varchar2(30) := 'AUCTION_RESPONSE';
QUOTE                   CONSTANT  varchar2(30) := 'RFQ_RESPONSE';
RESPONSE                CONSTANT  varchar2(30) := 'RFI_RESPONSE';

-- corresponding constants for the Sourcing doc types
SRC_AUCTION 		CONSTANT  varchar2(30) := 'BUYER_AUCTION';
SRC_REQUEST_FOR_QUOTE 	CONSTANT  varchar2(30) := 'REQUEST_FOR_QUOTE';
SRC_REQUEST_FOR_INFORMATION CONSTANT  varchar2(30) := 'REQUEST_FOR_INFORMATION';

FUNCTION is_contracts_installed RETURN VARCHAR2;

FUNCTION get_response_doc_type(p_doc_type_id IN NUMBER) RETURN VARCHAR2;

FUNCTION get_negotiation_doc_type(p_doc_type_id IN NUMBER) RETURN VARCHAR2;

FUNCTION is_deviations_enabled( p_document_type IN VARCHAR2,  p_document_id IN NUMBER ) RETURN VARCHAR2;

FUNCTION get_concatenated_address(
	p_location_id	IN NUMBER
) RETURN VARCHAR2;

PROCEDURE get_auction_header_id(
	p_contracts_doctype	IN VARCHAR2,
	p_contracts_doc_id	IN NUMBER,
	x_auction_header_id	OUT NOCOPY pon_auction_headers_all.auction_header_id%type,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_msg_data		OUT NOCOPY VARCHAR2,
	x_msg_count		OUT NOCOPY NUMBER
);

PROCEDURE activateDeliverables (
	p_auction_id     IN NUMBER,
	p_new_bid_number IN NUMBER,
	p_old_bid_number IN NUMBER,
	x_result         OUT NOCOPY VARCHAR2,
	x_error_code     OUT NOCOPY VARCHAR2,
	x_error_message  OUT NOCOPY VARCHAR2
);


PROCEDURE updateDeliverables (
  p_auction_header_id    IN  NUMBER,
  p_doc_type_id          IN  NUMBER,
  p_close_bidding_date   IN  DATE,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2
);

PROCEDURE cancelDeliverables(
  p_auction_header_id    IN  NUMBER,
  p_doc_type_id          IN  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2
                            ) ;
  PROCEDURE Delete_Doc (
  p_auction_header_id    IN  NUMBER,
  p_doc_type_id          IN  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2
                     );

PROCEDURE resolveDeliverables (
  p_auction_header_id    IN  NUMBER,
  x_msg_data             OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2
                              )
;

PROCEDURE copyResponseDoc (
	p_source_bid_number  	IN 	NUMBER,
	p_target_bid_number	IN 	NUMBER
);


PROCEDURE disqualifyDeliverables (
	p_bid_number	IN 	NUMBER
);

PROCEDURE disableDeliverables(
  p_auction_number    IN  NUMBER,
  p_doc_type_id          IN  NUMBER,
   x_msg_data             OUT NOCOPY  VARCHAR2,
  x_msg_count            OUT NOCOPY  NUMBER,
  x_return_status        OUT NOCOPY  VARCHAR2

                              )
;

FUNCTION contract_terms_exist(p_doc_type IN VARCHAR2,
                              p_doc_id   IN NUMBER) RETURN VARCHAR2;

PROCEDURE is_article_attached(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
);

PROCEDURE is_article_amended(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
);

PROCEDURE is_template_expired(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
);

PROCEDURE is_standard_contract(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
);

PROCEDURE is_deliverable_attached(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
);

PROCEDURE is_deliverable_amended(
  itemtype 	in varchar2,
  itemkey	in varchar2,
  actid		in number,
  uncmode	in varchar2,
  resultout	out NOCOPY varchar2
);

PROCEDURE updateDelivOnVendorMerge
(   p_from_vendor_id IN         NUMBER,
    p_from_site_id   IN         NUMBER,
    p_to_vendor_id   IN         NUMBER,
    p_to_site_id     IN         NUMBER,
    x_msg_data       OUT NOCOPY VARCHAR2,
    x_msg_count      OUT NOCOPY NUMBER,
    x_return_status  OUT NOCOPY VARCHAR2
);


PROCEDURE updateDelivOnAmendment (
  p_auction_header_id_orig    	IN  NUMBER,
  p_auction_header_id_prev     	IN  NUMBER,
  p_doc_type_id		 	IN  NUMBER,
  p_close_bidding_date   	IN  DATE,
  x_result	             	OUT NOCOPY  VARCHAR2,
  x_error_code            	OUT NOCOPY  VARCHAR2,
  x_error_message        	OUT NOCOPY  VARCHAR2
  );

FUNCTION isAttachedDocument(
  p_document_type IN VARCHAR2,
  p_document_id   IN NUMBER)
     RETURN VARCHAR2;

FUNCTION isDocumentMergeable(
  p_document_type  IN VARCHAR2,
  p_document_id    IN NUMBER)
  RETURN VARCHAR2;

FUNCTION attachedDocumentExists (
  p_document_type IN VARCHAR2,
  p_document_id   IN NUMBER)
  RETURN NUMBER;

FUNCTION GET_LEGAL_ENTITY_ID (
  p_org_id 	IN  NUMBER)
  RETURN NUMBER;

FUNCTION GET_LEGAL_ENTITY_NAME(
  p_org_id      IN  NUMBER)
  RETURN VARCHAR2;


END PON_CONTERMS_UTL_PVT;

/
