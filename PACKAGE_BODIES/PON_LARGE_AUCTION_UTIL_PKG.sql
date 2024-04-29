--------------------------------------------------------
--  DDL for Package Body PON_LARGE_AUCTION_UTIL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_LARGE_AUCTION_UTIL_PKG" AS
-- $Header: PONLGUTB.pls 120.15.12010000.2 2014/09/04 13:19:12 spapana ship $

g_debug_mode    CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_module_prefix CONSTANT VARCHAR2(35) := 'pon.plsql.concRequestsPkg.';

-- ======================================================================
-- PROCEDURE:	DELETE_LINE_ATTACHMENTS	PRIVATE
--  PARAMETERS:
--	p_auc_header_id		IN auction header id of negotiation
--	p_bid_number		IN bid number to delete attachments on
--
--  COMMENT: Deletes line level attachments for a bid
-- ======================================================================
PROCEDURE delete_line_attachments
(
	p_auc_header_id		IN pon_bid_headers.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end			IN pon_bid_item_prices.line_number%TYPE
) IS

	-- Determine which lines have attachments
	CURSOR bid_lines_with_attachments IS
		SELECT DISTINCT ad.pk3_value
		FROM fnd_attached_documents ad
		WHERE ad.entity_name = 'PON_BID_ITEM_PRICES'
			AND ad.pk1_value = p_auc_header_id
			AND ad.pk2_value = p_bid_number
			AND ad.pk3_value IS NOT null
			AND to_number(ad.pk3_value) BETWEEN p_batch_start AND p_batch_end;
BEGIN

	-- Delete all line level attachments
	FOR line IN bid_lines_with_attachments LOOP
		FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
			(x_entity_name => 'PON_BID_ITEM_PRICES',
			x_pk1_value => p_auc_header_id,
			x_pk2_value => p_bid_number,
			x_pk3_value => line.pk3_value,
			x_delete_document_flag => 'Y');
	END LOOP;

END delete_line_attachments;
-- ======================================================================
-- PROCEDURE:	DELETE_BID_PAYMENT_ATTACHMENTS	PRIVATE
--  PARAMETERS:
--	p_bid_number		IN bid number to delete attachments on
--
--  COMMENT: Deletes payment level attachments for a bid
-- ======================================================================
PROCEDURE delete_bid_payment_attachments
(
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_batch_start		IN pon_bid_item_prices.line_number%TYPE,
	p_batch_end			IN pon_bid_item_prices.line_number%TYPE
) IS

l_module_name VARCHAR2 (30);

	CURSOR bid_payments_with_attachments IS
		SELECT  pay.bid_payment_id, pay.bid_number, pay.bid_line_number
		FROM fnd_attached_documents ad,
		pon_bid_payments_shipments pay
		WHERE ad.entity_name = 'PON_BID_PAYMENTS_SHIPMENTS'
			AND ad.pk1_value = pay.bid_number
			AND ad.pk2_value = pay.bid_line_number
			AND ad.pk3_value = pay.bid_payment_id
			AND pay.bid_number = p_bid_number
			AND pay.bid_line_number BETWEEN p_batch_start AND p_batch_end;
BEGIN
    l_module_name := 'Delete_bid_Payment_Attachments';

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
   FND_LOG.string (log_level => FND_LOG.level_procedure,
   module => g_module_prefix || l_module_name,
   message => 'Entered procedure = ' || l_module_name);
  END IF;
	-- Delete all attachments for the bid payments
  FOR payment IN bid_payments_with_attachments LOOP
        IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string (log_level => FND_LOG.level_procedure,
         module => g_module_prefix || l_module_name,
	 message => 'Deleting fnd attachments for bid payment id ' ||payment.bid_payment_id||'='|| l_module_name);
        END IF;


	FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
		(x_entity_name => 'PON_BID_PAYMENTS_SHIPMENTS',
		x_pk1_value => payment.bid_number,
		x_pk2_value => payment.bid_line_number,
		x_pk3_value => payment.bid_payment_id,
		x_delete_document_flag => 'Y');
   END LOOP;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
   FND_LOG.string (log_level => FND_LOG.level_procedure,
   module => g_module_prefix || l_module_name,
   message => 'After Call FND_ATTACHED_DOCUMENTS2_PKG.DELETE_ATTACHMENTS = ' || l_module_name);
  END IF;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
   FND_LOG.string (log_level => FND_LOG.level_procedure,
   module => g_module_prefix || l_module_name,
   message => 'Leaving procedure = ' || l_module_name);
  END IF;

END delete_bid_payment_attachments;

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
) IS
	l_max_line_number	pon_bid_item_prices.line_number%TYPE;
	l_batch_start		pon_bid_item_prices.line_number%TYPE;
	l_batch_end			pon_bid_item_prices.line_number%TYPE;
BEGIN

	-- START BATCHING

	-- Determine the maximum line number for the negotiation
	SELECT ah.max_internal_line_num
	INTO l_max_line_number
	FROM pon_auction_headers_all ah
	WHERE ah.auction_header_id = p_auc_header_id;

	-- Define the initial batch range (line numbers are indexed from 1)
	l_batch_start := 1;
	IF (l_max_line_number < PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE) THEN
		l_batch_end := l_max_line_number;
	ELSE
		l_batch_end := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
	END IF;

	-- Delete header attributes here
	DELETE FROM pon_bid_attribute_values
	WHERE bid_number = p_bid_number
	AND line_number = -1;

	WHILE (l_batch_start <= l_max_line_number) LOOP

		-- Delete price differentials
		DELETE FROM pon_bid_price_differentials
		WHERE bid_number = p_bid_number
			AND line_number BETWEEN l_batch_start AND l_batch_end;

		-- Delete attributes
		DELETE FROM pon_bid_attribute_values
		WHERE bid_number = p_bid_number
			AND line_number BETWEEN l_batch_start AND l_batch_end;

		-- Delete price elements
		DELETE FROM pon_bid_price_elements
		WHERE bid_number = p_bid_number
			AND line_number BETWEEN l_batch_start AND l_batch_end;

		-- Delete shipments
		DELETE FROM pon_bid_shipments
		WHERE bid_number = p_bid_number
			AND line_number BETWEEN l_batch_start AND l_batch_end;

		-- Delete payment  attachments
		delete_bid_payment_attachments
			( p_bid_number,
			l_batch_start,
			l_batch_end);

		-- Delete Payments
		DELETE FROM pon_bid_payments_shipments
		WHERE bid_number = p_bid_number
			AND bid_line_number BETWEEN l_batch_start AND l_batch_end;

		-- Delete line attachments
		delete_line_attachments
			(p_auc_header_id,
			p_bid_number,
			l_batch_start,
			l_batch_end);

		-- Delete lines
		DELETE FROM pon_bid_item_prices
		WHERE bid_number = p_bid_number
			AND line_number BETWEEN l_batch_start AND l_batch_end;

		-- If there is more than one batch, then commit the batch
        -- or else let the calling program commit the batch
        IF (l_batch_end < l_max_line_number) THEN
             commit;
        END IF;

		-- Find the new batch range
		l_batch_start := l_batch_end + 1;
		IF (l_batch_end + PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE > l_max_line_number) THEN
			l_batch_end := l_max_line_number;
		ELSE
			l_batch_end := l_batch_end + PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
		END IF;

	END LOOP;

	-- END BATCHING

	-- Header and header attachments taken care of in middle tier

END delete_bid;

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
) IS
	l_request_id		fnd_concurrent_requests.request_id%TYPE;
	l_success			BOOLEAN;
BEGIN

	l_request_id := p_request_id;

	-- Call FND_CONCURRENT API to get concurrent request status
	l_success := FND_CONCURRENT.GET_REQUEST_STATUS(request_id => l_request_id,
		phase => x_phase, status => x_status, dev_phase => x_devphase,
		dev_status => x_devstatus, message => x_message);

	-- Check if call was unsuccessful
	IF (NOT l_success) THEN
		IF (g_debug_mode = 'Y'
			AND FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
			    FND_LOG.string(log_level => FND_LOG.level_statement,
		                   module    => g_module_prefix || 'get_request_info',
		                   message   => x_message);
		END IF;

		x_phase := null;
		x_status := null;
	END IF;

EXCEPTION
	WHEN OTHERS THEN
		IF (g_debug_mode = 'Y'
			AND FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
			    FND_LOG.string(log_level => FND_LOG.level_statement,
		                   module    => g_module_prefix || 'get_request_info',
		                   message   => SQLERRM);
		END IF;

		x_phase := null;
		x_status := null;

END get_request_info;

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
) RETURN VARCHAR2 IS
	l_has_errors		VARCHAR2(1);
BEGIN

	SELECT 'Y'
	INTO l_has_errors
	FROM pon_interface_errors
	WHERE request_id = p_request_id
		AND rownum = 1;

	RETURN l_has_errors;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 'N';

END request_has_errors;

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
) RETURN NUMBER IS
	l_error_count		NUMBER;
BEGIN

	SELECT count(request_id)
	INTO l_error_count
	FROM pon_interface_errors
	WHERE request_id = p_request_id;

	RETURN l_error_count;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 0;

END request_error_count;

-- ======================================================================
-- FUNCTION:  GET_REQUEST_INTERNAL_STATUS	PUBLIC
--  PARAMETERS:
--  p_request_id 		IN	The request id to check status of
--
--	RETURN: VARCHAR2 Internal status for concurrent request

--  COMMENT: Returns and internal status for the concurrent request
--			that can be used for comparisons
-- ======================================================================
FUNCTION get_request_internal_status
(
	p_request_id		IN fnd_concurrent_requests.request_id%TYPE
) RETURN VARCHAR2 IS
	l_phase				VARCHAR2(80);
	l_status			VARCHAR2(80);
	l_devphase			VARCHAR2(30);
	l_devstatus			VARCHAR2(30);
	l_message			VARCHAR2(240);
BEGIN

	get_request_info(p_request_id => p_request_id,
					x_phase => l_phase,
					x_status => l_status,
					x_devphase => l_devphase,
					x_devstatus => l_devstatus,
					x_message => l_message);

	IF (l_devphase IS null) THEN
		RETURN 'INVALID';
	END IF;

	IF (l_devphase = 'COMPLETE') THEN
		IF (request_has_errors(p_request_id => p_request_id) = 'Y') THEN
			l_devstatus := 'ERROR';
		END IF;

		RETURN l_devstatus;
	ELSE
		RETURN l_devphase;
	END IF;

END get_request_internal_status;

-- ======================================================================
-- FUNCTION:  GET_REQUEST_DISPLAY_STATUS	PUBLIC
--  PARAMETERS:
--  p_request_id 		IN	The request id to check status of
--
--	RETURN: VARCHAR2 Displayable status for concurrent request

--  COMMENT: Returns a displayable status for the concurrent request
-- ======================================================================
FUNCTION get_request_display_status
(
	p_request_id		IN fnd_concurrent_requests.request_id%TYPE
) RETURN VARCHAR2 IS
	l_phase				VARCHAR2(80);
	l_status			VARCHAR2(80);
	l_devphase			VARCHAR2(30);
	l_devstatus			VARCHAR2(30);
	l_message			VARCHAR2(240);
BEGIN

	get_request_info(p_request_id => p_request_id,
					x_phase => l_phase,
					x_status => l_status,
					x_devphase => l_devphase,
					x_devstatus => l_devstatus,
					x_message => l_message);

	IF (l_devphase = 'COMPLETE') THEN

		IF (request_has_errors(p_request_id => p_request_id) = 'Y') THEN
			l_status := fnd_message.get_string('PON', 'PON_AUCTS_ERROR');
		ELSIF (l_devstatus = 'NORMAL') THEN
			l_status := fnd_message.get_string('PON', 'PON_REQUEST_NORMAL');
		ELSIF (l_devstatus = 'WARNING') THEN
			l_status := fnd_message.get_string('PON', 'PON_REQUEST_WARNINGS');
		END IF;

		RETURN l_status;
	ELSE
		RETURN l_phase;
	END IF;

END get_request_display_status;

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
) RETURN VARCHAR2 IS
	l_request_id		pon_auction_headers_all.request_id%TYPE;
BEGIN

	SELECT request_id
	INTO l_request_id
	FROM pon_auction_headers_all
	WHERE auction_header_id = p_auc_header_id;

	IF (l_request_id IS null) THEN
		RETURN 'N';
	ELSIF (get_request_internal_status(p_request_id => l_request_id)
		IN ('PENDING', 'RUNNING', 'INACTIVE')) THEN
		RETURN 'Y';
	ELSE
		RETURN 'N';
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 'N';

END is_auction_request_pending;

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
) RETURN VARCHAR2 IS
	l_request_id		pon_bid_headers.request_id%TYPE;
BEGIN

	SELECT request_id
	INTO l_request_id
	FROM pon_bid_headers
	WHERE bid_number = p_bid_number;

	IF (l_request_id IS null) THEN
		RETURN 'N';
	ELSIF (get_request_internal_status(p_request_id => l_request_id)
		IN ('PENDING', 'RUNNING', 'INACTIVE')) THEN
		RETURN 'Y';
	ELSE
		RETURN 'N';
	END IF;

EXCEPTION
	WHEN NO_DATA_FOUND THEN
		RETURN 'N';

END is_bid_request_pending;

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
) RETURN VARCHAR2 IS
	l_success			BOOLEAN;
	l_message			VARCHAR2(255);
BEGIN

	l_success := FND_CONCURRENT.CANCEL_REQUEST(request_id => p_request_id,
						   message => l_message);

	IF (l_success) THEN
		RETURN null;
	ELSE
		IF (g_debug_mode = 'Y'
			AND FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
			    FND_LOG.string(log_level => FND_LOG.level_statement,
		                   module    => g_module_prefix || 'cancel_concurrent_request',
		                   message   => l_message);
		END IF;
		RETURN l_message;
	END IF;

END cancel_concurrent_request;


-- ======================================================================
-- FUNCTION:  GET_DOCTYPE_SUFFIX	PUBLIC
--  PARAMETERS:
--  p_auction_id 		IN auction-number
--
--	RETURN: VARCHAR2
--
--  COMMENT:
--
-- ======================================================================

FUNCTION GET_DOCTYPE_SUFFIX(p_auction_id number) RETURN VARCHAR2 IS
l_suffix	varchar2(2);
BEGIN

  --SLM UI Enhancement
  IF PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auction_id) = 'Y' THEN

      l_suffix := PON_SLM_UTIL_PKG.SLM_MESSAGE_SUFFIX_UNDERSCORE;
  ELSE

	    SELECT  '_' || dt.message_suffix
	    INTO 	l_suffix
	    FROM 	pon_auc_doctypes dt,
		    pon_auction_headers_all ah
	    WHERE 	dt.doctype_id 	     = ah.doctype_id
	    AND	ah.auction_header_id = p_auction_id
	    AND	rownum =1;

  END IF;

	return l_suffix;

end GET_DOCTYPE_SUFFIX;


/* ======================================================================
 * PROCEDURE:  UPDATE_AUCTION_IMPORT_COLS	PUBLIC
 *  PARAMETERS:
 *  p_auction_id 		IN auction-number
 *  p_request_id
 *  p_requested_by
 *  p_import_file_name
 *  p_request_date
 *  p_last_update_date

 *
 *  COMMENT: THIS PROCEDURE SHOULD BE INVOKED WHEN A CONCURRENT REQUEST IS
 *	     SUCCESSFULLY TRIGERRED FOR IMPORTING A SPEADSHEET IN THE FOLLOWING
 *	     SCENARIOS -
 *		** CREATE A SUPER-LARGE NEGOTIATION VIA SPREADSHEET IMPORT
 *		** AWARD A SUPER-LARGE NEGOTIATION VIA SPREADSHEET IMPORT
 *
 * ====================================================================== */

PROCEDURE	UPDATE_AUCTION_IMPORT_COLS(P_AUCTION_ID		IN	NUMBER,
					   P_REQUEST_ID		IN	NUMBER,
					   P_REQUESTED_BY 	IN	NUMBER,
					   P_REQUEST_DATE 	IN	DATE,
					   P_IMPORT_FILE  	IN	VARCHAR2,
					   P_LAST_UPDATE_DATE	IN	DATE,
					   X_RESULT 		OUT NOCOPY  VARCHAR2,
					   X_ERROR_CODE		OUT NOCOPY  VARCHAR2,
					   X_ERROR_MESG		OUT NOCOPY  VARCHAR2)


IS

l_api_name 	  CONSTANT 	VARCHAR2(30) := 'UPDATE_AUCTION_IMPORT_COLS';
l_api_version     CONSTANT	NUMBER       := 1.0;
l_last_update_date	DATE;

BEGIN

	x_result := FND_API.g_ret_sts_success;

	IF (g_debug_mode = 'Y'
		AND FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
			FND_LOG.string(log_level => FND_LOG.level_statement,
		                   module    => l_api_name,
		                   message   => 'BEGIN ::' || p_auction_id || ':::'
						|| p_request_id || ':::' || p_requested_by || ':::'
						|| p_request_date || ':::' || p_import_file || ':::'
						|| p_last_update_date);
	END IF;


	IF( IS_AUCTION_NOT_UPDATED( p_auction_id , p_last_update_date)) THEN

		UPDATE 	PON_AUCTION_HEADERS_ALL
		SET
			REQUEST_ID	= p_request_id,
			REQUESTED_BY	= p_requested_by,
			REQUEST_DATE	= p_request_date,
			IMPORT_FILE_NAME= p_import_file,
			LAST_UPDATE_DATE= sysdate
		WHERE
			AUCTION_HEADER_ID= p_auction_id;

	ELSE

		X_RESULT 	:= FND_API.G_RET_STS_ERROR;
		X_ERROR_CODE 	:= 'PON_AUCTION_UPDATED_ALREADY';
		X_ERROR_MESG 	:= 'Auction ' ||p_auction_id  ||' has been updated in another session ' ;

		RETURN;


	END IF;

	IF (g_debug_mode = 'Y'
		AND FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
			FND_LOG.string(log_level => FND_LOG.level_statement,
		                   module    => l_api_name,
		                   message   => 'END ::' || p_auction_id || ':::'
						|| p_request_id || ':::' || p_requested_by || ':::'
						|| p_request_date || ':::' || p_import_file || ':::'
						|| p_last_update_date);
	END IF;



EXCEPTION

	WHEN OTHERS THEN
		IF (g_debug_mode = 'Y'
			AND FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
				FND_LOG.string(log_level => FND_LOG.level_statement,
			                   module    => l_api_name,
			                   message   => 'EXCEPTION ::' || p_auction_id || ':::'
						|| p_request_id || ':::' || p_requested_by
					    || ':::' || p_request_date || ':::' || p_import_file || ':::'
					    || p_last_update_date);
		END IF;

		X_RESULT 	:= FND_API.G_RET_STS_ERROR;
		X_ERROR_CODE 	:= 'UPDATE_AUCTION_IMPORT_COLS_FAILED_COMPLETELY - ' || SQLCODE;
		X_ERROR_MESG 	:= 'Unable to do anything with this auction '
				|| p_auction_id || ' '
				|| SUBSTR(SQLERRM, 1, 100);


END UPDATE_AUCTION_IMPORT_COLS;

-- ======================================================================
-- PROCEDURE:  IS_AUCTION_NOT_UPDATED	PUBLIC
--  PARAMETERS:
--
--	RETURN: BOOLEAN
--
--  COMMENT:
--
-- ======================================================================

FUNCTION IS_AUCTION_NOT_UPDATED (p_auction_header_id 	IN	NUMBER,
				 p_last_update_date 	IN	DATE)
RETURN BOOLEAN IS

l_current_update_date 	DATE;
l_return_value 		BOOLEAN;

BEGIN

	-- we are being optimistic here, the name of the function is negative though
	-- more often than not, we shud return true

	l_return_value := TRUE;

    	SELECT 	last_update_date
	INTO 	l_current_update_date
    	FROM 	pon_auction_headers_all
	WHERE 	auction_header_id = p_auction_header_id;

	IF (l_current_update_date = p_last_update_date) THEN
	   l_return_value := TRUE;
	ELSE
	   l_return_value := FALSE;
	END IF;

	return l_return_value;

END  IS_AUCTION_NOT_UPDATED;

-- ======================================================================
-- PROCEDURE:  PURGE_INTERFACE_ERRORS_CP   PUBLIC
-- PARAMETERS:
--
-- RETURN:     ERRBUF - CONTAINS POSSIBLE ERROR MESSAGES
--             RETCODE - RETURN CODE. 0 INDICATES SUCCESS
--
-- COMMENT: PURGE RECORDS FROM INTERFACE ERROR TABLE IF THE EXPIRATION_DATE
--          IS OLDER THAN THE CURRENT DATE
--
-- ======================================================================
PROCEDURE purge_interface_errors_cp
          (errbuf OUT NOCOPY VARCHAR2,
           retcode OUT NOCOPY VARCHAR2)
IS

BEGIN

    retcode := '0';
    errbuf := '';

    BEGIN

      /*
	Delete all the errors in the interface table that have
 	expiration date marked as less than the current date

	*/
      delete from pon_interface_errors
      where trunc(expiration_date) <= trunc(sysdate);

	/*

	Delete all the rows in the summary table used to store
	auto-award recommendation - mapping to auctions that haven't
	been updated in the past seven days (this is just a catch-all
	to avoid this temporary table from growing too much)

	please refer to bug 4947500 for further details

	*/

      delete from pon_auction_summary
      where auction_id in (select auction_header_id
			   from pon_auction_headers_all
			   where last_update_date < sysdate - 7);

      retCode := '0';
      errbuf := 'PURGE_INTERFACE_ERRORS_CP exited successfully';

    EXCEPTION
      WHEN OTHERS THEN
        retCode := '2';
        errbuf := 'PURGE_INTERFACE_ERRORS_CP exited with errors:' || SQLERRM;
    END;

    COMMIT;

END purge_interface_errors_cp;



-- ======================================================================
-- PROCEDURE:  is_super_large_neg / is_large_neg
-- PARAMETERS: p_auction_header_id
--
-- RETURN:     BOOLEAN
--
-- COMMENT: returns TRUE/FALSE depending on whether the negotiation is large/
--          super-large
-- ======================================================================

FUNCTION is_super_large_neg(p_auction_header_id IN NUMBER)
    RETURN BOOLEAN
IS
    v_num_lines NUMBER;
    v_tpid NUMBER;
    v_threshold NUMBER;

BEGIN

    SELECT number_of_lines, trading_partner_id
    INTO v_num_lines, v_tpid
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auction_header_id;

    BEGIN
        SELECT to_number(preference_value)
        INTO v_threshold
        FROM PON_PARTY_PREFERENCES
        WHERE party_id = v_tpid
          AND app_short_name= 'PON'
          AND preference_name='CONCURRENT_PROCESS_LINE_START';
    EXCEPTION
       WHEN NO_DATA_FOUND THEN
         --This is the default value. Data will not be
         --found when the application is run for the first time.
         v_threshold := g_default_lines_threshold;
    END;

    IF (v_num_lines > v_threshold) THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

    RETURN FALSE;

END is_super_large_neg;


FUNCTION is_large_neg(p_auction_header_id IN NUMBER)
    RETURN BOOLEAN
IS
    v_large_neg_flag VARCHAR2(1);

BEGIN

    SELECT large_neg_enabled_flag
    INTO v_large_neg_flag
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auction_header_id;

    IF (v_large_neg_flag = 'Y') THEN
        RETURN TRUE;
    ELSE
        RETURN FALSE;
    END IF;

    RETURN FALSE;

END is_large_neg;

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
) RETURN VARCHAR2
IS
    v_complete_flag VARCHAR2(1) := 'N';
BEGIN

    SELECT nvl(complete_flag,'Y')
    INTO v_complete_flag
    FROM pon_auction_headers_all
    WHERE auction_header_id = p_auc_header_id;

    RETURN v_complete_flag;

END IS_AUCTION_COMPLETE;

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
) RETURN VARCHAR2
IS
    v_request_complete VARCHAR2(1) := 'Y';
    l_request_id NUMBER;
  	l_phase				VARCHAR2(80);
	l_status			VARCHAR2(80);
	l_devphase			VARCHAR2(30);
	l_devstatus			VARCHAR2(30);
	l_message			VARCHAR2(240);
    l_success           BOOLEAN;

BEGIN
     SELECT REQUEST_ID INTO l_request_id
     FROM PON_AUCTION_HEADERS_ALL
     WHERE AUCTION_HEADER_ID = p_auc_header_id;

     IF (l_request_id IS NULL) THEN
        v_request_complete := 'Y';
     ELSE
        l_success := FND_CONCURRENT.GET_REQUEST_STATUS (
                       REQUEST_ID => l_request_id,
                       APPL_SHORTNAME => 'PON',
                       PROGRAM => NULL,
                       PHASE => l_phase,
                       STATUS => l_status,
                       DEV_PHASE => l_devphase,
                       DEV_STATUS => l_devstatus,
                       MESSAGE => l_message);

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,

      module  =>  g_module_prefix || 'IS_REQUEST_COMPLETE',

      message  => 'l_request_id : '|| l_request_id ||
		  'l_phase : '||l_phase ||
		  'l_status : '||l_status ||
		  'l_devphase : '||l_devphase ||
		  'l_devstatus : '||l_devstatus ||
		  'l_message : '||l_message);
  END IF;

        IF (NOT l_success) THEN
            v_request_complete := 'Y';
        ELSE
            IF (l_devphase = 'RUNNING' OR l_devphase = 'COMPLETE') THEN
                v_request_complete := 'Y';
            ELSE
                v_request_complete := 'N';
            END IF;
        END IF;
    END IF;


  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,

      module  =>  g_module_prefix || 'IS_REQUEST_COMPLETE',

      message  => 'returning '|| v_request_complete);
  END IF;


    return v_request_complete;

END IS_REQUEST_COMPLETE;

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
) IS
	l_conterms_exist_flag varchar2(1) := 'N';
	l_return_status         VARCHAR2(20) := FND_API.G_RET_STS_SUCCESS;

	PON_FAIL_CALL_DEL_DOC  EXCEPTION;
BEGIN
    -- Initialize API return status to SUCCESS
    x_return_status := FND_API.G_RET_STS_SUCCESS;

	-- Delete related records from tables for this bid
	pon_large_auction_util_pkg.delete_bid( p_auc_header_id, p_bid_number);


	-- Delete contract terms
	select conterms_exist_flag into l_conterms_exist_flag
		   from pon_auction_headers_all
  	   	   where auction_header_id = p_auc_header_id;

    if ( ( PON_CONTERMS_UTL_GRP.is_contracts_installed()= FND_API.G_TRUE ) and
	   	 l_conterms_exist_flag = 'Y' ) then

	   OKC_TERMS_UTIL_GRP.delete_doc (
		p_api_version => 1.0,
		p_init_msg_list => FND_API.G_FALSE,
		p_commit => FND_API.G_FALSE,
                x_return_status       => l_return_status,
                x_msg_count           => x_msg_count,
                x_msg_data            => x_msg_data,
		p_validate_commit => null,
		p_validation_string => null,
		p_doc_type => P_doc_type,
		p_doc_id => p_bid_number );

        if (l_return_status <> FND_API.G_RET_STS_SUCCESS) then
           raise PON_FAIL_CALL_DEL_DOC;
        end if;
	end if;

	-- Delete bid header attachment
	PON_LARGE_AUCTION_UTIL_PKG.delete_bid_header_attachment
	(
	 p_auc_header_id => p_auc_header_id,
	 p_bid_number => p_bid_number
	);

	-- Delete bid header
	delete from pon_bid_headers where bid_number = p_bid_number;

EXCEPTION
  WHEN PON_FAIL_CALL_DEL_DOC THEN
        x_return_status := FND_API.G_RET_STS_ERROR ;

		if FND_LOG.LEVEL_STATEMENT >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
            FND_LOG.STRING(FND_LOG.LEVEL_STATEMENT, 'PON.PLSQL.PON_LARGE_AUCTION_UTIL_PKG.delete_bid_from_header', 'PON_FAIL_CALL_DEL_DOC');
        end if;
  WHEN OTHERS THEN

       x_return_status := FND_API.G_RET_STS_ERROR;

       if FND_LOG.LEVEL_EXCEPTION >= FND_LOG.G_CURRENT_RUNTIME_LEVEL then
            FND_LOG.STRING(FND_LOG.LEVEL_EXCEPTION, 'PON.PLSQL.PON_LARGE_AUCTION_UTIL_PKG.delete_bid_from_header', 'Others:' || substr(1, 255, sqlerrm) );
        end if;
END delete_bid_by_header;

-- Delete bid header attachment
PROCEDURE delete_bid_header_attachment
(
	p_auc_header_id		IN pon_bid_headers.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE

) IS
BEGIN

	-- Delete bid header attachment
	FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments
			(x_entity_name => 'PON_BID_HEADERS',
			x_pk1_value => p_auc_header_id,
			x_pk2_value => p_bid_number,
			x_delete_document_flag => 'Y');

EXCEPTION
	WHEN OTHERS THEN
	 null;
END;

END PON_LARGE_AUCTION_UTIL_PKG;

/
