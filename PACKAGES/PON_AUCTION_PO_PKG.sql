--------------------------------------------------------
--  DDL for Package PON_AUCTION_PO_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_AUCTION_PO_PKG" AUTHID CURRENT_USER as
/* $Header: PONAUPOS.pls 120.1.12010000.7 2012/06/29 09:23:37 spapana ship $ */


PROCEDURE GET_ATTACHMENT(pk1                IN NUMBER,
                         pk2                IN NUMBER,
                         pk3                IN NUMBER,
                         attachmentType     IN VARCHAR2,
                         attachmentDesc     OUT NOCOPY	VARCHAR2,
                         attachment         OUT NOCOPY	LONG,
                         error_code         OUT NOCOPY	VARCHAR2,
                         error_msg          OUT NOCOPY	VARCHAR2);

PROCEDURE GET_ATTRIBUTE_ATTACHMENT(p_auction_header_id    IN NUMBER,
                                   p_bid_number           IN NUMBER,
                                   p_line_number          IN NUMBER,
                                   p_attachmentDesc       OUT NOCOPY	VARCHAR2,
                                   p_attachment           OUT NOCOPY	LONG,
                                   p_error_code           OUT NOCOPY	VARCHAR2,
                                   p_error_msg            OUT NOCOPY	VARCHAR2);

PROCEDURE GET_HDR_ATTRIBUTE_ATTACHMENT(p_auction_header_id    IN NUMBER,
                                          p_bid_number           IN NUMBER,
                                          p_line_number          IN NUMBER,
                                          p_attachmentDesc       OUT NOCOPY	VARCHAR2,
                                          p_attachment           OUT NOCOPY	LONG,
                                          p_error_code           OUT NOCOPY	VARCHAR2,
                                          p_error_msg            OUT NOCOPY	VARCHAR2);
PROCEDURE GET_HDR_ATTRIBUTE_ATTACH_CLOB(p_auction_header_id    IN NUMBER,
                                          p_bid_number           IN NUMBER,
                                          p_line_number          IN NUMBER,
                                          p_attachmentDesc       OUT NOCOPY	VARCHAR2,
                                          p_attachment           OUT NOCOPY	CLOB,
                                          p_error_code           OUT NOCOPY	VARCHAR2,
                                          p_error_msg            OUT NOCOPY	VARCHAR2);

PROCEDURE GET_NOTE_TO_BUYER_ATTACHMENT(p_auction_header_id    IN NUMBER,
                                       p_bid_number           IN NUMBER,
                                       p_line_number          IN NUMBER,
                                       p_attachmentDesc       OUT NOCOPY	VARCHAR2,
                                       p_attachment           OUT NOCOPY	LONG,
                                       p_error_code           OUT NOCOPY	VARCHAR2,
                                       p_error_msg            OUT NOCOPY	VARCHAR2);

PROCEDURE GET_NOTE_TO_SUPP_ATTACHMENT(p_auction_header_id    IN NUMBER,
                                      p_line_number          IN NUMBER,
                                      p_attachmentDesc       OUT NOCOPY	VARCHAR2,
                                      p_attachment           OUT NOCOPY	LONG,
                                      p_error_code           OUT NOCOPY	VARCHAR2,
                                      p_error_msg            OUT NOCOPY	VARCHAR2,
				      p_line_or_header 	     IN  VARCHAR2);

PROCEDURE GET_TOTAL_COST_ATTACHMENT(p_auction_header_id    IN NUMBER,
                                    p_bid_number           IN NUMBER,
                                    p_line_number          IN NUMBER,
                                    p_attachmentDesc       OUT NOCOPY	VARCHAR2,
                                    p_attachment           OUT NOCOPY	LONG,
                                    p_error_code           OUT NOCOPY	VARCHAR2,
                                    p_error_msg            OUT NOCOPY	VARCHAR2);

PROCEDURE check_unique(org_id      IN NUMBER,
                       po_number   IN VARCHAR2,
                       status      OUT NOCOPY VARCHAR2);

/*-----------------------------------------------------------------
* check_unique: This procedure will check for the uniquesness of
* the po_number in pon_bid_headers table for a given org_id,po_number
* and bid_number.
*----------------------------------------------------------------*/

PROCEDURE check_unique(org_id      IN NUMBER,
                       po_number   IN VARCHAR2,
                       p_bid_number  IN NUMBER,
                       status      OUT NOCOPY VARCHAR2);

PROCEDURE GET_JOB_DETAILS_ATTACHMENT (p_auction_header_id IN NUMBER,
					    p_line_number IN NUMBER,
					    p_attachmentDesc OUT NOCOPY VARCHAR2,
					    p_attachment OUT NOCOPY LONG,
					    p_error_code OUT NOCOPY VARCHAR2,
					    p_error_msg OUT NOCOPY VARCHAR2);

--Complex work- This method creates fnd attachments out of Buyer notes on Payments
PROCEDURE GET_PAYMENT_NOTE_TO_SUPP (  p_auction_payment_id   IN NUMBER,
	                                      p_attachmentDesc       OUT NOCOPY		VARCHAR2,
	                                      p_attachment           OUT NOCOPY		LONG,
	                                      p_error_code           OUT NOCOPY		VARCHAR2,
	                                      p_error_msg            OUT NOCOPY		VARCHAR2);


END PON_AUCTION_PO_PKG;

/
