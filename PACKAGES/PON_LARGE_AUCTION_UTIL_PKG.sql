--------------------------------------------------------
--  DDL for Package PON_LARGE_AUCTION_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_LARGE_AUCTION_UTIL_PKG" AUTHID CURRENT_USER AS
-- $Header: PONLGUTS.pls 120.6 2006/03/09 13:51:34 liangxia noship $

BATCH_SIZE CONSTANT NUMBER := 2500;

g_default_lines_threshold CONSTANT NUMBER := 500;

-- ======================================================================
-- PROCEDURE:	DELETE_BID	PUBLIC
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_bid_number		IN bid number to delete
--
--  COMMENT: Completely deletes a bid from the database
-- ======================================================================
PROCEDURE delete_bid
(
	p_auc_header_id		IN pon_bid_headers.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE
);

-- ======================================================================
-- PROCEDURE :  GET_REQUEST_INFO	PUBLIC
--  PARAMETERS:
--  p_request_id 		IN	The request id to check the status of
--  x_phase				OUT	Returned displayable phase
--  x_status			OUT Returned displayable status
--  x_devphase			OUT Returned developer phase
--  x_dev_status		OUT Returned developer status
--  x_message			OUT Returned message describing extraneous condition
--
--  COMMENT: Wrapper around call to FND_CONCURRENT.GET_REQUEST_STATUS
-- ======================================================================
PROCEDURE get_request_info
(
	p_request_id		IN fnd_concurrent_requests.request_id%TYPE,
	x_phase				OUT NOCOPY VARCHAR2,
	x_status			OUT NOCOPY VARCHAR2,
	x_devphase			OUT NOCOPY VARCHAR2,
	x_devstatus			OUT NOCOPY VARCHAR2,
	x_message			OUT NOCOPY VARCHAR2
);

-- ======================================================================
-- FUNCTION:  GET_REQUEST_INTERNAL_STATUS	PUBLIC
--  PARAMETERS:
--  p_request_id 		IN	The request id to check status of
--
--	RETURN: VARCHAR2 Internal status for concurrent request

--  COMMENT: Returns and internal status for the concurrent request
--			that can be used for comparisons
-- ======================================================================
FUNCTION get_request_display_status
(
	p_request_id		IN fnd_concurrent_requests.request_id%TYPE
) RETURN VARCHAR2;

-- ======================================================================
-- FUNCTION:  REQUEST_HAS_ERRORS	PUBLIC
--  PARAMETERS:
--  p_request_id 		IN	The request id to check errors for
--
--	RETURN: VARCHAR2 Y/N if the request had/didn't have validation errors

--  COMMENT: Determines if any validation errors associated with p_request_id
--			were inserted in pon_interface_errors
-- ======================================================================
FUNCTION request_has_errors
(
	p_request_id		IN pon_interface_errors.request_id%TYPE
) RETURN VARCHAR2;

-- ======================================================================
-- FUNCTION:  REQUEST_ERROR_COUNT	PUBLIC
--  PARAMETERS:
--  p_request_id 		IN	The request id to count errors for
--
--	RETURN: NUMBER the number of errors for the request

--  COMMENT: Counts the number of validation errors for a request
-- ======================================================================
FUNCTION request_error_count
(
	p_request_id		IN pon_interface_errors.request_id%TYPE
) RETURN NUMBER;

-- ======================================================================
-- FUNCTION:  GET_REQUEST_DISPLAY_STATUS	PUBLIC
--  PARAMETERS:
--  p_request_id 		IN	The request id to check status of
--
--	RETURN: VARCHAR2 Displayable status for concurrent request

--  COMMENT: Returns a displayable status for the concurrent request
-- ======================================================================
FUNCTION get_request_internal_status
(
	p_request_id		IN fnd_concurrent_requests.request_id%TYPE
) RETURN VARCHAR2;

-- ======================================================================
-- FUNCTION:  IS_AUCTION_REQUEST_PENDING	PUBLIC
--  PARAMETERS:
--  p_auc_header_id 	IN	Auction header id for which to check request status
--
--	RETURN: VARCHAR2 Y/N if the auction has a pending/completed request
--
--  COMMENT: Determines if a concurrent request associated with the
--			the auction is pending or completed
-- ======================================================================
FUNCTION is_auction_request_pending
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE
) RETURN VARCHAR2;

-- ======================================================================
-- FUNCTION:  IS_BID_REQUEST_PENDING	PUBLIC
--  PARAMETERS:
--  p_bid_number	 	IN	Bid number for which to check request status
--
--	RETURN: VARCHAR2 Y/N if the bid has a pending/completed request
--
--  COMMENT: Determines if a concurrent request associated with the
--			the bid is pending or completed
-- ======================================================================
FUNCTION is_bid_request_pending
(
	p_bid_number		IN pon_bid_headers.bid_number%TYPE
) RETURN VARCHAR2;

-- ======================================================================
-- FUNCTION:  CANCEL_CONCURRENT_REQUEST		PUBLIC
--  PARAMETERS:
--  p_request_id 		IN Request id to cancel
--
--	RETURN: VARCHAR2 null/error msg if successful/unsuccessful
--
--  COMMENT: Cancels concurrent request p_request_id using FND API:
--			FND_CONCURRENT.CANCEL_REQUEST
-- ======================================================================
FUNCTION cancel_concurrent_request
(
	p_request_id		IN fnd_concurrent_requests.request_id%TYPE
) RETURN VARCHAR2;



FUNCTION GET_DOCTYPE_SUFFIX(p_auction_id number) RETURN VARCHAR2;

FUNCTION IS_AUCTION_NOT_UPDATED (p_auction_header_id 	IN	NUMBER,
				 p_last_update_date 	IN	DATE) RETURN BOOLEAN;


PROCEDURE 	UPDATE_AUCTION_IMPORT_COLS(P_AUCTION_ID		IN	NUMBER,
					   P_REQUEST_ID		IN	NUMBER,
					   P_REQUESTED_BY 	IN	NUMBER,
					   P_REQUEST_DATE 	IN	DATE,
					   P_IMPORT_FILE  	IN	VARCHAR2,
					   P_LAST_UPDATE_DATE	IN	DATE,
					   X_RESULT 		OUT NOCOPY  VARCHAR2,
					   X_ERROR_CODE		OUT NOCOPY  VARCHAR2,
					   X_ERROR_MESG		OUT NOCOPY  VARCHAR2);

PROCEDURE purge_interface_errors_cp
          (errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY VARCHAR2);


FUNCTION is_super_large_neg(p_auction_header_id IN NUMBER) RETURN BOOLEAN;

FUNCTION is_large_neg(p_auction_header_id IN NUMBER) RETURN BOOLEAN;


-- ======================================================================
-- FUNCTION:  IS_AUCTION_COMPLETE	PUBLIC
--  PARAMETERS:
--  p_auc_header_id 	IN	Auction header id for which to check status
--
--	RETURN: VARCHAR2 Y/N if the auction is incomplete
--
--  COMMENT: Determines if an auction is complete or not
--			It checks the complete flag
-- ======================================================================
FUNCTION IS_AUCTION_COMPLETE
(
	p_auc_header_id		IN pon_auction_headers_all.auction_header_id%TYPE
) RETURN VARCHAR2;

-- ======================================================================
-- FUNCTION:  IS_REQUEST_COMPLETE       PUBLIC
--  PARAMETERS:
--  p_auc_header_id     IN      Auction header id for which to check request
--  status
--
--      RETURN: VARCHAR2 Y/N if the request for the auction is incomplete
--
--  COMMENT: Determines if the request for the auction
--           is completed or not
-- ======================================================================
FUNCTION IS_REQUEST_COMPLETE
(
        p_auc_header_id         IN pon_auction_headers_all.auction_header_id%TYPE
) RETURN VARCHAR2;

-- ======================================================================
-- PROCEDURE:	delete_bid_by_header
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_bid_number		IN bid number to delete
--  P_doc_type			 IN document type of negotiation
--
--  COMMENT: Completely deletes a bid from the database including bid_headers
-- This procedure is called from online to delete bid complete including
-- bid headers.
-- ======================================================================
PROCEDURE delete_bid_by_header
(
	p_auc_header_id		IN pon_bid_headers.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	P_doc_type		    IN varchar2,
	x_msg_count   		OUT  NOCOPY NUMBER,
    x_return_status  	OUT  NOCOPY VARCHAR2,
    x_msg_data   	    OUT  NOCOPY VARCHAR2
);

-- Delete bid header attachment
PROCEDURE delete_bid_header_attachment
(
	p_auc_header_id		IN pon_bid_headers.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE

);

END PON_LARGE_AUCTION_UTIL_PKG;

 

/
