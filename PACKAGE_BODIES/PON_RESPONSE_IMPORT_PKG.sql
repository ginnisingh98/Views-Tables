--------------------------------------------------------
--  DDL for Package Body PON_RESPONSE_IMPORT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_RESPONSE_IMPORT_PKG" AS
--$Header: PONRIMPB.pls 120.37.12010000.5 2014/09/04 13:20:39 spapana ship $

g_exp_date				TIMESTAMP;
g_exp_days_offset		CONSTANT NUMBER := 7;

g_null_int				CONSTANT NUMBER	:= -9999;
g_error_int				CONSTANT NUMBER := -9998;
g_skip_int				CONSTANT NUMBER := -9997;
g_closed_int			CONSTANT NUMBER := -9996;

g_pb_required		CONSTANT NUMBER := 1;
g_pb_optional		CONSTANT NUMBER := 2;
g_pb_new			CONSTANT NUMBER := 3;
g_pb_delete			CONSTANT NUMBER := 4;
g_pb_optional_updated CONSTANT NUMBER := 5;

g_pt_indicator_pricebreak CONSTANT VARCHAR2(30) := 'PRICE_BREAKS';
g_pt_indicator_quantitybased CONSTANT VARCHAR2(30) := 'QUANTITY_BASED';
g_shipment_type_pricebreak CONSTANT VARCHAR2(30) := 'PRICE BREAK';
g_shipment_type_quantitybased CONSTANT VARCHAR2(30) := 'QUANTITY BASED';

-- constants for requirements/attributes XML upload

g_xml_decimal_separator_char CONSTANT VARCHAR2(1) := '.';

g_xml_number_mask 	CONSTANT VARCHAR2(255) := '9999999999999999999999999999999999999999999999D9999999999999999';

g_xml_char_no_prec_mask CONSTANT VARCHAR2(255) := 'FM999999999999999999999999999999999999999999999999999999999999999';
g_xml_char_prec_mask    CONSTANT VARCHAR2(255) := 'FM9999999999999999999999999999999999999999999999D9999999999999999';

g_xml_date_mask      CONSTANT VARCHAR2(25)  := 'yyyy-mm-dd';
g_xml_date_time_mask CONSTANT VARCHAR2(25)  := 'yyyy-mm-dd hh24:mi:ss';

g_pon_date_mask      CONSTANT VARCHAR2(25) := 'dd-mm-yyyy';
g_pon_date_time_mask CONSTANT VARCHAR2(25) := 'dd-mm-yyyy hh24:mi:ss';

g_attr_need_by_date_seq CONSTANT NUMBER := -10;

-- These will be used for debugging the code
g_fnd_debug             CONSTANT VARCHAR2(1)  := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');
g_pkg_name              CONSTANT VARCHAR2(30) := 'PON_RESPONSE_IMPORT_PKG';
g_module_prefix         CONSTANT VARCHAR2(50) := 'pon.plsql.' || g_pkg_name || '.';


PROCEDURE validate_xml_req_values
(
        p_auction_header_id     IN pon_bid_item_prices.auction_header_id%TYPE,
        p_bid_number            IN pon_bid_item_prices.bid_number%TYPE,
        p_user_id               IN pon_interface_errors.created_by%TYPE,
        p_suffix                IN VARCHAR2,
        p_batch_id              IN pon_interface_errors.batch_id%TYPE,
        p_request_id            IN pon_interface_errors.request_id%TYPE);


PROCEDURE validate_xml_attr_values
(
        p_auction_header_id     IN pon_bid_item_prices.auction_header_id%TYPE,
        p_bid_number            IN pon_bid_item_prices.bid_number%TYPE,
        p_user_id               IN pon_interface_errors.created_by%TYPE,
        p_suffix                IN VARCHAR2,
        p_batch_id              IN pon_interface_errors.batch_id%TYPE,
        p_request_id            IN pon_interface_errors.request_id%TYPE);



FUNCTION get_message_1_token
(
	p_message			IN VARCHAR2,
	p_token1_name		IN VARCHAR2,
	p_token1_value		IN VARCHAR2
) RETURN VARCHAR2 IS
BEGIN

	fnd_message.clear;
	fnd_message.set_name('PON', p_message);
	fnd_message.set_token(p_token1_name, p_token1_value);

	RETURN fnd_message.get;

END get_message_1_token;

PROCEDURE validate_close_bidding_date
(
	p_auc_header_id		IN pon_bid_item_prices_interface.auction_header_id%TYPE,
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_request_id		IN pon_bid_headers.request_id%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_suffix			IN VARCHAR2
) IS
	l_is_paused			VARCHAR2(1);
	l_paused_date		TIMESTAMP;
BEGIN

	-- PRECONDITIONS:
	-- line_number correctly set for lines

	SELECT nvl(ah.is_paused, 'N'), ah.last_pause_date
	INTO l_is_paused, l_paused_date
	FROM pon_auction_headers_all ah
	WHERE ah.auction_header_id = p_auc_header_id;

	-- Flag all lines with expired close bidding dates
	UPDATE pon_bid_item_prices_interface bli
	SET bli.line_number = g_closed_int
	WHERE bli.batch_id = p_batch_id
		AND bli.line_number <> g_error_int
		AND bli.line_number <> g_skip_int
		AND sysdate >
			(SELECT decode(l_is_paused, 'N', al.close_bidding_date,
						al.close_bidding_date + (sysdate - l_paused_date))
			FROM pon_auction_item_prices_all al
			WHERE al.auction_header_id = bli.auction_header_id
				AND al.line_number = bli.line_number);

	-- Report errors for all closed lines
	INSERT INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_id,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE)
	(SELECT
				'BIDBYSPREADSHEET',
				fnd_message.get_string('PON', 'PON_AUCTS_AUCTION_LINE' || p_suffix),
				p_batch_id,
				bli.interface_line_id,
				'PON_AUCTION_LINE_CLOSED' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				bli.document_disp_line_number,
				'TXT',
				bli.auction_header_id,
				bli.bid_number,
				bli.line_number,
				g_exp_date
	FROM pon_bid_item_prices_interface bli
	WHERE bli.batch_id = p_batch_id
		AND bli.line_number = g_closed_int);

END validate_close_bidding_date;

PROCEDURE determine_skipped_lines
(
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_full_qty			IN VARCHAR2
) IS
BEGIN

	-- PRECONDITIONS:
	-- line_number are set for lines; it need not be set for children

	-- Determine if any lines can be ignored
	UPDATE pon_bid_item_prices_interface bli
	SET bli.line_number = g_skip_int
	WHERE bli.batch_id = p_batch_id
		AND EXISTS
			(SELECT 'Y'
			FROM pon_auction_item_prices_all al, pon_bid_item_prices bl
			WHERE bl.bid_number = bli.bid_number
				AND bl.line_number = bli.line_number
				AND al.auction_header_id = bl.auction_header_id
				AND al.line_number = bl.line_number
				AND (
					-- GROUPs ignored
					al.group_type = 'GROUP'

					-- proxy lines ignored
					OR bl.copy_price_for_proxy_flag = 'Y'

					-- empty lines ignored
					OR (al.price_disabled_flag = 'Y'
						OR bli.bid_currency_price IS null)
						AND (al.quantity_disabled_flag = 'Y'
							OR bli.quantity IS null
							OR (p_full_qty = 'Y' OR al.group_type = 'LOT_LINE'
								OR al.order_type_lookup_code = 'AMOUNT'))
						AND bli.note_to_auction_owner IS null
						AND bli.attachment_desc IS null
						AND bli.attachment_url IS null
						AND bli.promised_date IS null
						AND bli.recoupment_rate_percent IS null
						AND bli.bid_curr_advance_amount IS null
						AND bli.bid_curr_max_retainage_amt IS null
						AND bli.retainage_rate_percent IS null
						AND bli.progress_pymt_rate_percent IS null
						-- No price elements
						AND(bl.display_price_factors_flag = 'N'
							OR NOT EXISTS
								(SELECT bpfi.price_element_type_id
								FROM pon_bid_price_elements_int bpfi
								WHERE bpfi.batch_id = bli.batch_id
								AND bpfi.interface_line_id = bli.interface_line_id
								AND bpfi.bid_currency_value IS NOT null))
						-- No price differentials
						AND (al.has_price_differentials_flag = 'N'
							OR NOT EXISTS
								(SELECT bpdi.sequence_number
								FROM pon_bid_price_differ_int bpdi
								WHERE bpdi.batch_id = bli.batch_id
									AND bpdi.auction_line_number = bli.line_number
									AND bpdi.multiplier IS NOT null))
						-- No attributes
						AND (al.has_attributes_flag = 'N'
							OR NOT EXISTS -- no attributes
								(SELECT bai.attribute_name
								FROM pon_bid_attr_values_interface bai
								WHERE bai.batch_id = bli.batch_id
									AND bai.interface_line_id = bli.interface_line_id
									AND bai.value IS NOT null))));

END determine_skipped_lines;

PROCEDURE remove_invalid_skipped_lines
(
	p_auc_header_id		IN pon_bid_item_prices_interface.auction_header_id%TYPE,
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_request_id		IN pon_bid_headers.request_id%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_full_qty			IN VARCHAR2,
	p_buyer_user		IN VARCHAR2,
	p_suffix			IN VARCHAR2
) IS
BEGIN

	-- 1. LINES

	-- document_disp_line_number in pon_bid_item_prices_interface is the
	-- line number specified in the spreadsheet. Since we do not lookup
	-- the internal line number in the middle tier any longer, we
	-- need to do that now and populate the children interface tables.
	-- NOTE: if the line has an invalid document number, line_number is
	-- set to g_error_int to indicate this
	UPDATE pon_bid_item_prices_interface bli
	SET bli.line_number =
			nvl((SELECT al.line_number
			FROM pon_auction_item_prices_all al
			WHERE al.auction_header_id = bli.auction_header_id
				AND al.document_disp_line_number = bli.document_disp_line_number),
			g_error_int)
	WHERE bli.batch_id = p_batch_id;

	-- Report errors for invalid lines (invalid document_disp_line_number's)
	INSERT INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE)
	(SELECT
				'BIDBYSPREADSHEET',
				fnd_message.get_string('PON', 'PON_AUCTS_AUCTION_LINE' || p_suffix),
				p_batch_id,
				bli.interface_line_id,
				'PON_AUC_INVALID_LINE_NUMBER' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				bli.document_disp_line_number,
				'TXT',
				bli.auction_header_id,
				bli.bid_number,
				g_exp_date
	FROM pon_bid_item_prices_interface bli
	WHERE bli.batch_id = p_batch_id
		AND bli.line_number = g_error_int);

	-- Determine if there are any lines to be skipped, mark them so.
	determine_skipped_lines(p_batch_id, p_full_qty);

	-- Mark closed lines as closed and report an error - only for suppliers
	IF (p_buyer_user = 'N') THEN
		validate_close_bidding_date
			(p_auc_header_id,
			p_batch_id,
			p_request_id,
			p_userid,
			p_suffix);
	END IF;

	-- 2. REMOVE INVALIDS FROM INTERFACE

	-- Remove all invalid lines, closed lines and lines to be skipped
	-- from the interface tables, along with their children
	-- flag 'N' indicates that only erroneous records are to be purged

	-- Delete from attributes interface table
	DELETE FROM pon_bid_attr_values_interface bai
	WHERE bai.batch_id = p_batch_id
		AND bai.interface_line_id in (
			select bli.interface_line_id
			from pon_bid_item_prices_interface bli
			where bli.batch_id = p_batch_id
			AND (bli.line_number = g_error_int
				OR bli.line_number = g_skip_int));

	-- Delete from price elements interface table
	DELETE FROM pon_bid_price_elements_int bpfi
	WHERE bpfi.batch_id = p_batch_id
		AND bpfi.interface_line_id in (
			select bli.interface_line_id
			from pon_bid_item_prices_interface bli
			where bli.batch_id = p_batch_id
			AND (bli.line_number = g_error_int
				OR bli.line_number = g_skip_int));

	-- Delete from price differentials interface table
	DELETE FROM pon_bid_price_differ_int bpdi
	WHERE bpdi.batch_id = p_batch_id
		AND bpdi.interface_line_id in (
			select bli.interface_line_id
			from pon_bid_item_prices_interface bli
			where bli.batch_id = p_batch_id
			AND (bli.line_number = g_error_int
				OR bli.line_number = g_skip_int));

	-- Delete from lines interface table

	DELETE FROM pon_bid_item_prices_interface bli
	WHERE bli.batch_id = p_batch_id
		AND (bli.line_number = g_error_int
			OR bli.line_number = g_skip_int);

	-- 3. ATTRIBUTES

	-- Update attributes' internal line numbers's
	-- NOTE: we also update line_number for those attributes with
	-- valid line_numbers
	UPDATE pon_bid_attr_values_interface bai
	SET bai.line_number =
			(SELECT bli.line_number
			FROM pon_bid_item_prices_interface bli
			WHERE bli.batch_id = bai.batch_id
				AND bli.interface_line_id = bai.interface_line_id)
	WHERE bai.batch_id = p_batch_id;

	-- 4. PRICE ELEMENTS/COST FACTORS

	-- Update price elements' internal line numbers's
	-- NOTE: we also update line_number for those price elements with
	-- valid line_numbers
	UPDATE pon_bid_price_elements_int bpfi
	SET bpfi.line_number =
			(SELECT bli.line_number
			FROM pon_bid_item_prices_interface bli
			WHERE bli.batch_id = bpfi.batch_id
				AND bli.interface_line_id = bpfi.interface_line_id)
	WHERE bpfi.batch_id = p_batch_id;

	-- 5. PRICE DIFFERENTIALS

	-- Update price differentials' internal line numbers's
	-- NOTE: we also update line_number for those price differentials with
	-- valid line_numbers
	UPDATE pon_bid_price_differ_int bpdi
	SET bpdi.auction_line_number =
			(SELECT bli.line_number
			FROM pon_bid_item_prices_interface bli
			WHERE bli.batch_id = bpdi.batch_id
				AND bli.interface_line_id = bpdi.interface_line_id)
	WHERE bpdi.batch_id = p_batch_id;

END remove_invalid_skipped_lines;

PROCEDURE validate_attribute_datatypes
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_suffix			IN VARCHAR2,
	p_batch_id			IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
) IS
	TYPE intLineTab IS TABLE of pon_bid_attr_values_interface.interface_line_id%TYPE;
	TYPE lineNumberTab IS TABLE of pon_bid_attr_values_interface.line_number%TYPE;
	TYPE attrNameTab IS TABLE of pon_bid_attr_values_interface.attribute_name%TYPE;
	TYPE datatypeTab IS TABLE of pon_bid_attr_values_interface.datatype%TYPE;
	TYPE valueTab IS TABLE of pon_bid_attr_values_interface.value%TYPE;
	TYPE docLineNumTab IS TABLE of pon_auction_item_prices_all.document_disp_line_number%TYPE;

	l_int_lines 		intLineTab;
	l_line_numbers 		lineNumberTab;
	l_attr_names 		attrNameTab;
	l_datatypes			datatypeTab;
	l_values			valueTab;
	l_disp_line_numbers docLineNumTab;

	l_num_errors		NUMBER;
	l_index				NUMBER;

        l_date_format VARCHAR2(15);
        l_numeric_characters VARCHAR2(22);
        l_decimal_separator_character VARCHAR2(1);
        l_grouping_separator_character VARCHAR2(1);

        l_module CONSTANT VARCHAR2(32) := 'validate_attribute_datatypes';

        l_has_profile_value_numeric VARCHAR2(1) := 'N';
BEGIN


	IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
			          FND_LOG.string(log_level => FND_LOG.level_procedure,
					 module    =>  g_module_prefix || l_module,
					 message   => 'BEGIN validate_attribute_datatypes  procedure '||' p_auc_header_id=' || p_auc_header_id || ' p_bid_number=' || p_bid_number || ' p_userid=' || p_userid|| ' p_suffix=' || p_suffix|| ' p_batch_id=' || p_batch_id);
        END if;

	-- Bulk collect all the interface attributes
	SELECT
		bai.interface_line_id,
		bai.line_number,
		bai.attribute_name,
		bai.datatype,
		bai.value,
		al.document_disp_line_number
	BULK COLLECT INTO
		l_int_lines,
		l_line_numbers,
		l_attr_names,
		l_datatypes,
		l_values,
		l_disp_line_numbers
	FROM pon_bid_attr_values_interface bai,
		pon_auction_item_prices_all al
	WHERE bai.batch_id = p_batch_id
		AND al.auction_header_id = bai.auction_header_id
		AND al.line_number = bai.line_number;

	-- Mark every attribute as invalid
	-- The following statement will re-validate each attribute
	UPDATE pon_bid_attr_values_interface bai
		SET bai.line_number = g_error_int
	WHERE bai.batch_id = p_batch_id;

        l_date_format := fnd_profile.value('ICX_DATE_FORMAT_MASK');
        l_numeric_characters := fnd_profile.value('ICX_NUMERIC_CHARACTERS');
        l_decimal_separator_character := SUBSTR(l_numeric_characters, 1, 1);
        l_grouping_separator_character := SUBSTR(l_numeric_characters, 2, 1);

        IF(l_numeric_characters IS NOT NULL) THEN
    	    l_has_profile_value_numeric := 'Y';
        END IF;
	IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
		          FND_LOG.string(log_level => FND_LOG.level_procedure,
				 module    =>  g_module_prefix || l_module,
				 message   => 'l_has_profile_value_numeric='|| l_has_profile_value_numeric|| ' g_error_int='||g_error_int||
                                              ' l_numeric_characters=' || l_numeric_characters || ' l_decimal_separator_character=' ||
                                              l_decimal_separator_character || ' l_grouping_separator_character=' || l_grouping_separator_character);
        END if;

	-- Attempt the datatype conversions
	FORALL i IN l_int_lines.FIRST..l_int_lines.LAST SAVE EXCEPTIONS
		UPDATE pon_bid_attr_values_interface bai
			SET bai.value = decode(l_datatypes(i),
				'TXT', l_values(i),
                                'NUM', to_char(decode (l_has_profile_value_numeric, 'Y', to_number(replace(l_values(i), l_grouping_separator_character),
                                              'FM9999999999999999999999999999999999999999999999D9999999999999999',
                                              'NLS_NUMERIC_CHARACTERS=''' || l_numeric_characters || ''''),
                                               decode(instr(l_values(i), l_decimal_separator_character),
                                                      0,
                                                      'FM999999999999999999999999999999999999999999999999999999999999999',
                                                      'FM9999999999999999999999999999999999999999999999D9999999999999999'),
                                               'NLS_NUMERIC_CHARACTERS=''.,''',  'N',  FND_NUMBER.canonical_to_number(l_values(i)))),
				'DAT', to_char(to_date(l_values(i), l_date_format), 'DD-MM-RRRR'),
				'URL', l_values(i)),
				bai.line_number = l_line_numbers(i)
		WHERE bai.batch_id = p_batch_id
			AND bai.interface_line_id = l_int_lines(i)
			AND bai.attribute_name = l_attr_names(i);


      IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
				          FND_LOG.string(log_level => FND_LOG.level_procedure,
		                         module    =>  g_module_prefix || l_module,
		                         message   => 'IN validate_attribute_datatypes after FORALL');
      END if;



	-- NOTE: calling procedure should purge invalid attributes

EXCEPTION

	-- FIX THIS - should this be OTHERS?
	WHEN OTHERS THEN
		l_num_errors := SQL%BULK_EXCEPTIONS.COUNT;

		-- Insert errors for each erroneous attribute
		FOR i IN 1..l_num_errors LOOP

			l_index := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;

			IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
				  FND_LOG.string(log_level => FND_LOG.level_procedure,
				 module    =>  g_module_prefix || l_module,
				 message   => 'IN EXCEPTION BLOCK  p_suffix='|| p_suffix ||' l_int_lines(l_index)=' || l_int_lines(l_index) ||
                                              ' l_values(l_index)=' || l_values(l_index)  || ' l_line_numbers(l_index)=' || l_line_numbers(l_index) ||
                                              ' l_attr_names(l_index)=' || l_attr_names(l_index) || 'Error: ' || i ||
                                              ' Array Index: ' || SQL%BULK_EXCEPTIONS(i).error_index ||
                                              ' Message: ' || SQLERRM(-SQL%BULK_EXCEPTIONS(i).ERROR_CODE));
        		END if;

			INSERT INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE)
			VALUES
				('BIDBYSPREADSHEET',
				fnd_message.get_string('PON', 'PON_AUCTS_BID_VALUE' || p_suffix),
				'PON_BID_ATTR_VALUES',
				p_batch_id,
				l_int_lines(l_index),
				'PON_AUC_ATTR_INVALID_TARGET' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				l_values(l_index),
				'TXT',
				p_auc_header_id,
				p_bid_number,
				l_line_numbers(l_index),
				g_exp_date,
				'LINENUMBER',
				l_disp_line_numbers(l_index),
				'ATTRIBUTENAME',
				l_attr_names(l_index));

			END LOOP;


			IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
										          FND_LOG.string(log_level => FND_LOG.level_procedure,
								                         module    =>  g_module_prefix || l_module,
								                         message   => 'END validate_attribute_datatypes');
        		END if;

END validate_attribute_datatypes;

PROCEDURE validate_children
(
	p_auc_header_id		IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_request_id		IN pon_bid_headers.request_id%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	p_has_pe			IN VARCHAR2,
	p_suffix			IN VARCHAR2
) IS
  --added by Allen Yang for Surrogate Bid 2008/10/27
  --------------------------------------------------
  l_two_part_flag           pon_auction_headers_all.two_part_flag%type;
  l_surrogate_bid_flag      pon_bid_headers.surrog_bid_flag%type;
  l_tech_evaluation_status  pon_auction_headers_all.technical_evaluation_status%type;
  --------------------------------------------------
BEGIN
  --added by Allen Yang for Surrogate Bid 2008/10/27
  --------------------------------------------------
  SELECT
    paha.two_part_flag,
		paha.technical_evaluation_status,
		pbh.surrog_bid_flag
	INTO
    l_two_part_flag,
		l_tech_evaluation_status,
		l_surrogate_bid_flag
	FROM pon_bid_headers pbh, pon_auction_headers_all paha
	WHERE pbh.bid_number = p_bid_number
		AND paha.auction_header_id = pbh.auction_header_id;
  --------------------------------------------------

	-- Since children are uploaded by name and not internal keys
	-- the first step is to determine if the children are valid
	-- by looking up the internal keys.

	-- 1. ATTRIBUTES

	-- Determine if there are any invalid attributes.
	-- line_number is assigned a sentinel indicating an error
	-- instead of attribute_name since attribute_name is a string.
	UPDATE pon_bid_attr_values_interface bai
	SET bai.line_number =
			nvl((SELECT ba.line_number
			FROM pon_bid_attribute_values ba
			WHERE ba.bid_number = bai.bid_number
				AND ba.line_number = bai.line_number
				AND ba.attribute_name = bai.attribute_name), g_error_int),
		bai.datatype =
			nvl((SELECT ba.datatype
			FROM pon_bid_attribute_values ba
			WHERE ba.bid_number = bai.bid_number
				AND ba.line_number = bai.line_number
				AND ba.attribute_name = bai.attribute_name), 'N/A'),
                bai.sequence_number =
			nvl((SELECT ba.sequence_number
			FROM pon_bid_attribute_values ba
			WHERE ba.bid_number = bai.bid_number
				AND ba.line_number = bai.line_number
				AND ba.attribute_name = bai.attribute_name), g_error_int)


	WHERE bai.batch_id = p_batch_id;

        --bug 5166407: ignore the display only attributes
        DELETE FROM pon_bid_attr_values_interface bai
               WHERE bai.batch_id = p_batch_id
                     AND (bai.bid_number, bai.line_number, bai.sequence_number) in
                        (
                        select bh.bid_number, bh.line_number, aa.sequence_number
                        from pon_auction_attributes aa
                             , pon_bid_item_prices bh
                        where  bh.bid_number = bai.bid_number
                               and bh.line_number = bai.line_number
                               and aa.auction_header_id = bh.auction_header_id
                                  and aa.line_number = bh.line_number
                                  and aa.sequence_number = bai.sequence_number
                                  and aa.display_only_flag = 'Y'
                        );

	-- Report errors for invalid attributes (invalid attr_name)
	INSERT INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE)
	(SELECT
				'BIDBYSPREADSHEET',
				get_message_1_token('PON_AUC_ATTRIBUTE_ATTRNAME',
					'ATTRNAME', bai.attribute_name),
				p_batch_id,
				bai.interface_line_id,
				'PON_INVALID_ATTR_NAME' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				bai.attribute_name,
				'TXT',
				bai.auction_header_id,
				bai.bid_number,
				bai.line_number,
				g_exp_date
	FROM pon_bid_attr_values_interface bai
	WHERE bai.batch_id = p_batch_id
		AND bai.line_number = g_error_int);

	-- Remove all invalid attributes before validating datatypes

	-- Delete from attributes interface table
        DELETE FROM pon_bid_attr_values_interface bai
        WHERE bai.batch_id = p_batch_id
                AND bai.line_number = g_error_int;

	-- Validate attributes' datatypes
	validate_attribute_datatypes
		(p_auc_header_id,
		p_bid_number,
		p_userid,
		p_suffix,
		p_batch_id,
		p_request_id);

	-- Delete from attributes interface table
        DELETE FROM pon_bid_attr_values_interface bai
        WHERE bai.batch_id = p_batch_id
                AND bai.line_number = g_error_int;

	-- 2. PRICE ELEMENTS/COST FACTORS

	-- Update price_element_type_id since the user specifies price
	-- elements by name and not price_element_type_id
	UPDATE pon_bid_price_elements_int bpfi
	SET bpfi.price_element_type_id =
		nvl((SELECT pft.price_element_type_id
		FROM pon_price_element_types_tl pft
		WHERE pft.name = bpfi.price_element_name
			AND pft.language = userenv('LANG')), g_error_int)
	WHERE bpfi.batch_id = p_batch_id;

	-- Report an error if not all SUPPLIER pf's on a line were found
	-- Error is reported per line. Price factor errors reported below.
	-- NOTE: this error check is performed before that for BUYER pf's

  -- modified by Allen Yang for Surrogate Bid 2008/10/27
  ------------------------------------------------------
  --IF (p_has_pe = 'Y') THEN
  IF (p_has_pe = 'Y' AND NOT (l_two_part_flag = 'Y' AND l_tech_evaluation_status = 'NOT_COMPLETED' AND l_surrogate_bid_flag = 'Y')) THEN
  ------------------------------------------------------
	INSERT INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE)
	(SELECT
				'BIDBYSPREADSHEET',
				fnd_message.get_string('PON', 'PON_AUC_PRICE_ELEMENT'),
				p_batch_id,
				bli.interface_line_id,
				'PON_AUC_NOT_ALL_BID_PE',
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				'TXT',
				bli.auction_header_id,
				bli.bid_number,
				bli.line_number,
				g_exp_date
	FROM pon_bid_item_prices_interface bli,
             pon_bid_item_prices bip
	WHERE bli.batch_id = p_batch_id
                AND bli.bid_number = bip.bid_number
                AND bli.line_number = bip.line_number
                AND bip.display_price_factors_flag = 'Y'
		AND EXISTS
			(SELECT bpfi.price_element_name
			FROM pon_bid_price_elements_int bpfi, pon_price_elements apf
			WHERE apf.auction_header_id = p_auc_header_id
				AND apf.line_number = bli.line_number
				AND apf.pf_type = 'SUPPLIER'
				AND bpfi.batch_id (+) = bli.batch_id
				AND bpfi.line_number (+) = apf.line_number
				AND bpfi.price_element_type_id (+) = apf.price_element_type_id
				AND bpfi.price_element_type_id IS null
				AND rownum = 1));

	END IF;

	-- BUYER price factors are not allowed to be uploaded
	UPDATE pon_bid_price_elements_int bpfi
	SET bpfi.price_element_type_id = g_error_int
	WHERE bpfi.batch_id = p_batch_id
		AND bpfi.price_element_type_id <> g_error_int
		AND 'BUYER' =
			(SELECT apf.pf_type
			FROM pon_price_elements apf
			WHERE apf.auction_header_id = bpfi.auction_header_id
				AND apf.line_number = bpfi.line_number
				AND apf.price_element_type_id = bpfi.price_element_type_id);

	-- Report errors for invalid price elements
	-- (invalid price_element_name or BUYER price factor)
	INSERT INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE)
	(SELECT
				'BIDBYSPREADSHEET',
				get_message_1_token('PON_AUC_PRICE_ELEMENT_PENAME',
					'PENAME', bpfi.price_element_name),
				p_batch_id,
				bpfi.interface_line_id,
				'PON_AUC_INVALID_PRICE_NAME' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				bpfi.price_element_name,
				'TXT',
				bpfi.auction_header_id,
				bpfi.bid_number,
				bpfi.line_number,
				g_exp_date
	FROM pon_bid_price_elements_int bpfi
	WHERE bpfi.batch_id = p_batch_id
		AND bpfi.price_element_type_id = g_error_int);

	-- Delete from price elements interface table
        DELETE FROM pon_bid_price_elements_int bpfi
        WHERE bpfi.batch_id = p_batch_id
                AND bpfi.price_element_type_id = g_error_int;


	-- 3. PRICE DIFFERENTIALS

	-- Update sequence_number since it is internal and user specifies
	-- price differentials by price differential name
	-- price differentials on lines with differential_response_type
	-- as DISPLAY_ONLY are marked as skipped so they will get purged
	UPDATE pon_bid_price_differ_int bpdi
	SET bpdi.sequence_number =
		nvl((SELECT decode(al.differential_response_type, 'DISPLAY_ONLY',
						g_skip_int, bpd.price_differential_number)
		FROM pon_bid_price_differentials bpd, po_price_diff_lookups_v pdl,
			pon_auction_item_prices_all al
		WHERE pdl.price_differential_dsp = bpdi.price_type
			AND bpd.bid_number = bpdi.bid_number
			AND bpd.line_number = bpdi.auction_line_number
			AND bpd.price_type = pdl.price_differential_type
			AND al.auction_header_id = bpd.auction_header_id
                        AND al.line_number = bpd.line_number
                        AND al.price_diff_shipment_number = bpd.shipment_number), g_error_int)
	WHERE bpdi.batch_id = p_batch_id;

	-- Report errors for invalid price differentials (invalid price_type)
	INSERT INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE)
	(SELECT
				'BIDBYSPREADSHEET',
				get_message_1_token('PON_PRICE_DIFF_TYPE_NAME',
					'PDNAME', bpdi.price_type),
				p_batch_id,
				bpdi.interface_line_id,
				'PON_INVALID_PRICE_DIFF_TYPE' || p_suffix,
				p_userid,
				sysdate,
				p_userid,
				sysdate,
				p_request_id,
				bpdi.price_type,
				'TXT',
				bpdi.auction_header_id,
				bpdi.bid_number,
				bpdi.auction_line_number,
				g_exp_date
	FROM pon_bid_price_differ_int bpdi
	WHERE bpdi.batch_id = p_batch_id
		AND bpdi.sequence_number = g_error_int);

	-- Delete from price differentials interface table
        DELETE FROM pon_bid_price_differ_int bpdi
        WHERE bpdi.batch_id = p_batch_id
		AND bpdi.sequence_number = g_error_int;

END validate_children;

PROCEDURE default_from_auction
(
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_auc_header_id		IN pon_bid_item_prices_interface.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_full_qty			IN VARCHAR2,
	p_blanket			IN VARCHAR2,
	p_auc_closed		IN VARCHAR2
) IS
BEGIN

	-- If it is a super large negotiation, then proxy is not allowed
	IF (pon_large_auction_util_pkg.is_super_large_neg(p_auc_header_id)) THEN

		UPDATE pon_bid_item_prices_interface
		SET bid_currency_limit_price = null
		WHERE batch_id = p_batch_id;

	END IF;

	-- Default some values in the interface table for each line
	MERGE INTO pon_bid_item_prices_interface bli
	USING
		(SELECT bl.bid_number,
			bl.line_number,
			bl.display_price_factors_flag,
			bl.copy_price_for_proxy_flag,
			al.quantity,
			al.quantity_disabled_flag,
			al.price_disabled_flag,
			al.group_type,
			al.order_type_lookup_code
		FROM pon_bid_item_prices bl, pon_auction_item_prices_all al
		WHERE bl.bid_number = p_bid_number
			AND al.auction_header_id = bl.auction_header_id
			AND al.line_number = bl.line_number) lines
	ON (bli.bid_number = lines.bid_number
		AND bli.line_number = lines.line_number)
	WHEN MATCHED THEN
		UPDATE SET
			-- price does not apply if item has price factors
			-- or if price is disabled
			bli.bid_currency_price =
				decode(lines.display_price_factors_flag, 'Y', null,
					decode(lines.price_disabled_flag, 'Y', null,
						bli.bid_currency_price)),

			-- quantity := auction quantity if full qty reqd, LOT_LINE
			-- or AMOUNT/FIXED PRICE line (1/null)
			-- NOTE: quantity := null if blanket
			bli.quantity =
				decode(p_blanket, 'Y', null,
					decode(lines.quantity_disabled_flag, 'Y', null,
						decode(p_full_qty, 'Y', lines.quantity,
							decode(lines.group_type, 'LOT_LINE', lines.quantity,
								decode(lines.order_type_lookup_code,
									'AMOUNT', lines.quantity,
									'FIXED PRICE', lines.quantity, bli.quantity))))),

			-- null proxy fields for lot lines or if the auction is closed
			-- proxy fields also do not apply if the line has price factors
			-- and if an active proxy already exists
			bli.bid_currency_limit_price =
				decode(lines.group_type, 'LOT_LINE', null,
					decode(p_auc_closed, 'Y', null,
						decode(lines.display_price_factors_flag, 'Y', null,
							decode(lines.copy_price_for_proxy_flag, 'Y', null,
								bli.bid_currency_limit_price))));

END default_from_auction;

PROCEDURE copy_interface_to_txn_tables
(
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_auction_header_id IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_userid			IN pon_bid_item_prices.last_updated_by%TYPE,
	p_hdr_disp_pf		IN VARCHAR2,
	p_blanket			IN VARCHAR2,
	p_mas				IN VARCHAR2,
	p_progress_payment_type	IN VARCHAR2,
    p_spreadsheet_type         IN VARCHAR2,
	p_bid_currency_precision IN pon_bid_headers.number_price_decimals%TYPE,
        p_price_tiers_indicator IN pon_auction_headers_all.PRICE_TIERS_INDICATOR%type
) IS
l_module CONSTANT VARCHAR2(32) := 'copy_interface_to_txn_tables';
l_result VARCHAR2(1);
l_error_code VARCHAR2(200);
l_error_message VARCHAR2(2000);

BEGIN

	-- Update lines table with values in the interface table
	MERGE INTO pon_bid_item_prices bl
	USING
		(SELECT
			pbip.bid_number,
			pbip.line_number,
			pbip.batch_id,
			pbip.interface_line_id,
			pbip.quantity,
			pbip.bid_currency_price,
			pbip.note_to_auction_owner,
			pbip.promised_date,
			pbip.bid_currency_limit_price,
			pbip.po_bid_min_rel_amount,
			pbip.bid_curr_advance_amount,
			pbip.recoupment_rate_percent,
			pbip.progress_pymt_rate_percent,
			pbip.retainage_rate_percent,
			pbip.bid_curr_max_retainage_amt,
			pah.progress_pymt_negotiable_flag,
			pah.advance_negotiable_flag,
			pah.retainage_negotiable_flag,
			pah.max_retainage_negotiable_flag,
			pah.recoupment_negotiable_flag,
			pbip.worksheet_name,
			pbip.worksheet_sequence_number
		FROM pon_bid_item_prices_interface pbip,
		     pon_auction_headers_all pah
		WHERE batch_id = p_batch_id
		AND  pah.auction_header_id = pbip.auction_header_id) bli
	ON (bl.bid_number = bli.bid_number
		AND bl.line_number = bli.line_number)
	WHEN MATCHED THEN
		UPDATE SET
			bl.batch_id			= bli.batch_id,
			bl.interface_line_id		= bli.interface_line_id,
			bl.quantity 			= bli.quantity,
			-- NOTE: we copy into bid_currency_unit_price, NOT bid_currency_price
			-- Later, the bid_currency_unit_price column is used to calculate
			-- the other price columns since bid_currency_price doesn't always
			-- have the same meaning for different price factors views
			bl.bid_currency_unit_price 	= bli.bid_currency_price,
			bl.note_to_auction_owner 	= bli.note_to_auction_owner,
			bl.promised_date 		= bli.promised_date,
			bl.bid_currency_limit_price 	= bli.bid_currency_limit_price,
			bl.po_bid_min_rel_amount 	= bli.po_bid_min_rel_amount,
			bl.bid_curr_advance_amount 	= DECODE(bli.advance_negotiable_flag,'Y',bli.bid_curr_advance_amount,bl.bid_curr_advance_amount),
			bl.recoupment_rate_percent 	= DECODE(bli.recoupment_negotiable_flag,'Y',bli.recoupment_rate_percent,bl.recoupment_rate_percent),
			bl.progress_pymt_rate_percent 	= DECODE(bli.progress_pymt_negotiable_flag,'Y',bli.progress_pymt_rate_percent,bl.progress_pymt_rate_percent),
			bl.retainage_rate_percent 	= DECODE(bli.retainage_negotiable_flag,'Y',bli.retainage_rate_percent,bl.retainage_rate_percent),
			bl.bid_curr_max_retainage_amt 	= DECODE(bli.max_retainage_negotiable_flag,'Y',bli.bid_curr_max_retainage_amt,bl.bid_curr_max_retainage_amt),
			bl.last_update_date		= sysdate,
			bl.last_updated_by		= p_userid,
			bl.worksheet_name		= decode(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_xml_upload_mode, bli.worksheet_name,to_char(null)),
			bl.worksheet_sequence_number	= decode(p_spreadsheet_type, PON_BID_VALIDATIONS_PKG.g_xml_upload_mode, bli.worksheet_sequence_number,to_number(null));

		-- When a GROUP's child recieved a bid, we mark that group as part of the batch
	UPDATE pon_bid_item_prices bl
	SET batch_id = p_batch_id
	WHERE bl.bid_number = p_bid_number
		AND (SELECT al.group_type
			FROM pon_auction_item_prices_all al
			WHERE al.auction_header_id = bl.auction_header_id
				AND al.line_number = bl.line_number) = 'GROUP'
		AND EXISTS
			(SELECT bl2.line_number
			FROM pon_bid_item_prices bl2, pon_auction_item_prices_all al2
			WHERE bl2.bid_number = p_bid_number
				AND al2.auction_header_id = bl2.auction_header_id
				AND al2.line_number = bl2.line_number
				AND al2.parent_line_number = bl.line_number
				AND bl2.batch_id = p_batch_id);

	-- Update requirements/attributes table from interface
	MERGE INTO pon_bid_attribute_values ba
	USING
		(SELECT
                        auction_header_id,
			bid_number,
			line_number,
                        batch_id,
                        interface_line_id,
			sequence_number,
			value,
                        worksheet_name,
                        worksheet_sequence_number
		FROM pon_bid_attr_values_interface
		WHERE auction_header_id = p_auction_header_id
                  AND bid_number = p_bid_number
                  AND batch_id = p_batch_id) bai
	ON (ba.auction_header_id = bai.auction_header_id
            AND ba.bid_number = bai.bid_number
	    AND ba.line_number = bai.line_number
	    AND ba.sequence_number= bai.sequence_number)
	WHEN MATCHED THEN
		UPDATE SET
                        ba.batch_id = bai.batch_id,
                        ba.interface_line_id = bai.interface_line_id,
			ba.value = bai.value,
                        ba.worksheet_name = bai.worksheet_name,
                        ba.worksheet_sequence_number = bai.worksheet_sequence_number,
			ba.last_update_date = sysdate,
			ba.last_updated_by = p_userid;

	-- For MAS, quantity or promised date are scored, they need to
	-- be updated in the bid attributes transaction table
	IF (p_mas = 'Y' and p_spreadsheet_type = PON_BID_VALIDATIONS_PKG.g_txt_upload_mode) THEN
		-- Update promised_date
		UPDATE pon_bid_attribute_values ba
			SET value =
				nvl((SELECT to_char(bl.promised_date, 'dd-mm-yyyy hh24:mi:ss')
				FROM pon_bid_item_prices bl, pon_auction_item_prices_all al
				WHERE bl.bid_number = ba.bid_number
					AND bl.line_number = ba.line_number
					AND al.auction_header_id = bl.auction_header_id
					AND al.line_number = bl.line_number
					AND al.is_need_by_date_scored = 'Y'), ba.value)
		WHERE ba.bid_number = p_bid_number
			AND ba.sequence_number = -10;

		-- Update quantity
		UPDATE pon_bid_attribute_values ba
			SET value =
				nvl((SELECT to_char(bl.quantity)
				FROM pon_bid_item_prices bl, pon_auction_item_prices_all al
				WHERE bl.bid_number = ba.bid_number
					AND bl.line_number = ba.line_number
					AND al.auction_header_id = bl.auction_header_id
					AND al.line_number = bl.line_number
					AND al.is_quantity_scored = 'Y'), ba.value)
		WHERE ba.bid_number = p_bid_number
			AND ba.sequence_number = -20;

	END IF;

	-- IMPLEMENT: step 4(C) from DLD

	-- Copy price factors only if they exist
	IF (p_hdr_disp_pf = 'Y') THEN

		-- Update price elements transaction table from interface table
                -- only set bid currency value. The auction currency value
                -- will be recalculated later in
                -- recalculate_auc_curr_prices
		MERGE INTO pon_bid_price_elements bpf
		USING
			(SELECT
				batch_id,
				bid_number,
				line_number,
				price_element_type_id,
				bid_currency_value,
				interface_line_id
			FROM pon_bid_price_elements_int
			WHERE batch_id = p_batch_id
			AND   auction_header_id = p_auction_header_id
			AND   bid_number  = p_bid_number) bpfi
		ON (bpf.bid_number = bpfi.bid_number
		AND bpf.line_number = bpfi.line_number
		AND bpf.price_element_type_id = bpfi.price_element_type_id)
		WHEN MATCHED THEN
			UPDATE SET
				bpf.batch_id = bpfi.batch_id,
				bpf.bid_currency_value = bpfi.bid_currency_value,
				bpf.last_update_date = sysdate,
				bpf.last_updated_by = p_userid,
				bpf.interface_line_id = bpfi.interface_line_id;

		-- Sync bid_currency_unit_price from price factors to lines table
		UPDATE pon_bid_item_prices bl
			SET bl.bid_currency_unit_price =
				(SELECT bpf.bid_currency_value
				FROM pon_bid_price_elements bpf
				WHERE bpf.bid_number = bl.bid_number
					AND bpf.line_number = bl.line_number
					AND bpf.price_element_type_id = -10)
		WHERE bl.bid_number = p_bid_number
		AND bl.display_price_factors_flag = 'Y'
		AND bl.batch_id = p_batch_id;

	END IF;

	IF (p_blanket = 'Y') THEN

	  IF p_spreadsheet_type = PON_BID_VALIDATIONS_PKG.g_xml_upload_mode THEN
	   -- Copy over all Line level price differentials to transaction table
	   MERGE INTO pon_bid_price_differentials bpd
			USING
				(SELECT
					bid_number,
					auction_line_number,
					auction_shipment_number,
					sequence_number,
                    interface_line_id,
					multiplier
				FROM pon_bid_price_differ_int
				WHERE batch_id = p_batch_id
					  and auction_shipment_number = -1) bpdi
		ON (bpd.bid_number = bpdi.bid_number
			AND bpd.line_number = bpdi.auction_line_number
			AND bpd.shipment_number = bpdi.auction_shipment_number
			AND bpd.price_differential_number = bpdi.sequence_number)
		WHEN MATCHED THEN
			UPDATE SET
				bpd.multiplier = bpdi.multiplier,
                bpd.interface_line_id = bpdi.interface_line_id,
				bpd.last_update_date = sysdate,
				bpd.last_updated_by = p_userid;

		--copy over price break level price differentials to transaction table
                --only copy when this is price break
            IF (p_price_tiers_indicator = g_pt_indicator_pricebreak) THEN

		MERGE INTO pon_bid_price_differentials bpd
			USING
				( select bpdi.bid_number,
				bpdi.auction_line_number,
				bsh.shipment_number,
				bpdi.sequence_number,
                bpdi.interface_line_id ,
				bpdi.multiplier
				from pon_bid_price_differ_int bpdi,
				pon_bid_shipments bsh
				where bpdi.batch_id = p_batch_id
			        and bpdi.auction_header_id = bsh.auction_header_id
                                and bpdi.bid_number = bsh.bid_number
				and bpdi.auction_line_number = bsh.line_number
				and bpdi.auction_shipment_number = bsh.auction_shipment_number
				and bpdi.auction_shipment_number <> -1 ) bpdi2
		ON (bpd.bid_number = bpdi2.bid_number
			AND bpd.line_number = bpdi2.auction_line_number
			AND bpd.shipment_number = bpdi2.shipment_number
			AND bpd.price_differential_number = bpdi2.sequence_number)
		WHEN MATCHED THEN
			UPDATE SET
                bpd.interface_line_id = bpdi2.interface_line_id,
				bpd.multiplier = bpdi2.multiplier,
				bpd.last_update_date = sysdate,
				bpd.last_updated_by = p_userid;

		--Process Price Break, this method does followings:
		-- 1. Update existing Price Breaks from Interface table to Transaction table
		-- 2. Insert new Price Break to Transaction table
		-- 3. Delete Price Breaks from Transaction table for those that are intended to be deleted
		-- 4. Update Price Breaks from Buyer defined to Supplier owned for those that has structure changes
		-- 5. Delete Price Differential associated with the deleted or structure changed Price Breaks
		copy_shipment_interface_to_txn(
			p_batch_id=>p_batch_id,
			p_bid_number=>p_bid_number,
			p_userid	=>p_userid,
    		p_bid_currency_precision=> p_bid_currency_precision,
                        p_shipment_type => g_shipment_type_pricebreak
			);
             END IF;-- end of IF (p_price_tiers_indicator = g_pt_indicator_pricebreak)
	   ELSE
		                MERGE INTO pon_bid_price_differentials bpd
                        USING
                                (SELECT
                                        bid_number,
                                        auction_line_number,
                                        sequence_number,
                                        multiplier
                                FROM pon_bid_price_differ_int
                                WHERE batch_id = p_batch_id) bpdi
                ON (bpd.bid_number = bpdi.bid_number
                        AND bpd.line_number = bpdi.auction_line_number
                        AND bpd.shipment_number = -1
                        AND bpd.price_differential_number = bpdi.sequence_number)
                WHEN MATCHED THEN
                        UPDATE SET
                                bpd.multiplier = bpdi.multiplier,
                                bpd.last_update_date = sysdate,
                                bpd.last_updated_by = p_userid;
          END IF;


	END IF;

        IF  (p_price_tiers_indicator = g_pt_indicator_quantitybased and p_spreadsheet_type = PON_BID_VALIDATIONS_PKG.g_xml_upload_mode) THEN
	   copy_shipment_interface_to_txn(
			p_batch_id=>p_batch_id,
			p_bid_number=>p_bid_number,
			p_userid	=>p_userid,
    		        p_bid_currency_precision=> p_bid_currency_precision,
                       p_shipment_type => g_shipment_type_quantitybased
			);
        END IF;

    IF p_spreadsheet_type = PON_BID_VALIDATIONS_PKG.g_xml_upload_mode THEN
    --Update bid header table with Xml Spreadsheet header info
      BEGIN
        UPDATE PON_BID_HEADERS pbh
           SET (pbh.SURROG_BID_RECEIPT_DATE,
                pbh.BIDDERS_BID_NUMBER,
                pbh.BID_EXPIRATION_DATE,
                pbh.NOTE_TO_AUCTION_OWNER,
                pbh.MIN_BID_CHANGE) =
             (SELECT decode(pbh.surrog_bid_flag, 'N', pbh.SURROG_BID_RECEIPT_DATE, pbhi.SURROG_BID_RECEIPT_DATE),
                     pbhi.BIDDERS_BID_NUMBER,
                     pbhi.BID_EXPIRATION_DATE,
                     pbhi.NOTE_TO_AUCTION_OWNER,
                     pbhi.MIN_BID_CHANGE
	  	        FROM PON_BID_HEADERS_INTERFACE pbhi
	  	       WHERE batch_id = p_batch_id)
        WHERE pbh.bid_number = p_bid_number;

        --Delete from header interface
        DELETE FROM PON_BID_HEADERS_INTERFACE WHERE batch_id = p_batch_id;

        -- Copy payments to transaction tables
        IF p_progress_payment_type <> 'NONE' THEN
          PON_VALIDATE_PAYMENTS_INT.COPY_PAYMENTS_FROM_INT_TO_TXN(p_batch_id,
		                                                          PON_BID_VALIDATIONS_PKG.g_xml_upload_mode,
																  p_bid_number,
																  p_auction_header_id,
																  l_result,
																  l_error_code,
																  l_error_message);
        END IF;

      EXCEPTION
      WHEN OTHERS THEN
        IF (g_fnd_debug = 'Y' and FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string(log_level => FND_LOG.level_procedure,
                         module    =>  g_module_prefix || l_module,
                         message   => ' Error Code=' || SQLCODE || ' SQLERRM=' || SQLERRM);
        END if;
      END;
    END IF;


	-- Remove all records for the current batch from the interface table
	DELETE FROM pon_bid_item_prices_interface bli
        WHERE bli.batch_id = p_batch_id;

	DELETE FROM pon_bid_attr_values_interface bai
        WHERE bai.batch_id = p_batch_id;

	DELETE FROM pon_bid_price_elements_int bpfi
        WHERE bpfi.batch_id = p_batch_id;

	DELETE FROM pon_bid_price_differ_int bpdi
        WHERE bpdi.batch_id = p_batch_id;

    DELETE FROM pon_bid_shipments_int bshi
	    WHERE bshi.batch_id = p_batch_id;

END copy_interface_to_txn_tables;

PROCEDURE create_url_attachments
(
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_auc_header_id		IN pon_bid_headers.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_userid			IN pon_bid_headers.created_by%TYPE
) IS
	l_seq_num			NUMBER;
        l_target_category FND_DOCUMENT_CATEGORIES.NAME%type := pon_auction_pkg.g_supplier_attachment; -- target attachment category, default 'FromSupplier'
        l_two_part_flag   PON_AUCTION_HEADERS_ALL.TWO_PART_FLAG%type := 'N';

	CURSOR attachment_lines IS
		SELECT bli.attachment_url,
			bli.attachment_desc,
			bli.line_number
		FROM pon_bid_item_prices_interface bli
		WHERE bli.batch_id = p_batch_id
			AND bli.attachment_desc IS NOT null
			AND bli.attachment_url IS NOT null;
BEGIN
        -- get two_part_flag for RFQ
        select nvl(two_part_flag, 'N')
        into l_two_part_flag
        from pon_auction_headers_all
        where auction_header_id = p_auc_header_id;

        -- change target attachment category for two-part RFQ.
        IF l_two_part_flag = 'Y' THEN -- {
                -- change to From Supplier: Technical
                l_target_category := pon_auction_pkg.g_technical_attachment;
        END IF; -- }

        IF (g_fnd_debug = 'Y' and FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN -- {
          FND_LOG.string(log_level => FND_LOG.level_statement,
                         module    =>  g_module_prefix || 'create_url_attachments',
                         message   => 'l_two_part_flag: ' || l_two_part_flag || '; l_target_category: ' || l_target_category);
        END IF; -- }

	-- Call our API to create a long text attachment
	FOR line IN attachment_lines LOOP

		SELECT nvl(max(seq_num), 0) + 1
		INTO l_seq_num
		FROM fnd_attached_documents
		WHERE entity_name = 'PON_BID_ITEM_PRICES'
			AND pk1_value = p_auc_header_id
			AND pk2_value = p_bid_number
			AND pk3_value = line.line_number;

		PON_OA_UTIL_PKG.create_url_attachment
			(l_seq_num,
	        l_target_category,
	        line.attachment_desc,
	        5,
	        line.attachment_url,
	        'PON_BID_ITEM_PRICES',
	        p_auc_header_id,
	        p_bid_number,
	        line.line_number,
	        null,
	        null);
	END LOOP;

END create_url_attachments;

PROCEDURE process_spreadsheet_data
(
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_request_id		IN pon_bid_headers.request_id%TYPE,
	p_userid			IN pon_interface_errors.created_by%TYPE,
	x_return_status		OUT NOCOPY VARCHAR2,
	x_return_code		OUT NOCOPY VARCHAR2
) IS
	l_auc_header_id		pon_auction_headers_all.auction_header_id%TYPE;

	l_header_disp_pf	VARCHAR2(1);
	l_blanket			VARCHAR2(1);
	l_mas				VARCHAR2(1);
	l_full_qty			VARCHAR2(1);
	l_auc_closed		VARCHAR2(1);
	l_buyer_user		VARCHAR2(1);
	l_supplier_user		VARCHAR2(1);
	l_has_pe			VARCHAR2(1);

	l_suffix			VARCHAR2(2);
    l_progress_payment_type	pon_auction_headers_all.progress_payment_type%TYPE;
	l_price_precision pon_bid_headers.number_price_decimals%TYPE;
BEGIN

	-- Determine some negotiation flags
	SELECT sysdate + g_exp_days_offset,
		ah.auction_header_id,
		bh.display_price_factors_flag,
		decode(ah.contract_type, 'BLANKET', 'Y', 'CONTRACT', 'Y', 'N'),
		decode(ah.bid_ranking, 'MULTI_ATTRIBUTE_SCORING', 'Y', 'N'),
		decode(ah.full_quantity_bid_code, 'FULL_QTY_BIDS_REQD', 'Y', 'N'),
		decode(ah.auction_status, 'AUCTION_CLOSED', 'Y', 'N'),
		bh.surrog_bid_flag,
		decode(bh.surrog_bid_flag, 'Y', 'N', 'Y'),
		nvl(ah.has_price_elements, 'N'),
		ah.progress_payment_type,
		bh.number_price_decimals
	INTO g_exp_date,
		l_auc_header_id,
		l_header_disp_pf,
		l_blanket,
		l_mas,
		l_full_qty,
		l_auc_closed,
		l_buyer_user,
		l_supplier_user,
		l_has_pe,
		l_progress_payment_type,
		l_price_precision
	FROM pon_bid_headers bh, pon_auction_headers_all ah
	WHERE bh.bid_number = p_bid_number
		AND ah.auction_header_id = bh.auction_header_id;

	l_suffix := PON_LARGE_AUCTION_UTIL_PKG.get_doctype_suffix(l_auc_header_id);

	-- Determine if there are any invalid lines or lines to be skipped
	remove_invalid_skipped_lines
		(l_auc_header_id,
		p_batch_id,
		p_request_id,
		p_userid,
		l_full_qty,
		l_buyer_user,
		l_suffix);

	-- Validate line children
	validate_children
		(l_auc_header_id,
		p_bid_number,
		p_batch_id,
		p_request_id,
		p_userid,
		l_has_pe,
		l_suffix);

	-- Default certain fields from the auction side
	default_from_auction
		(p_batch_id,
		l_auc_header_id,
		p_bid_number,
		l_full_qty,
		l_blanket,
		l_auc_closed);

	-- For all the valid lines, create the URL attachments
	-- This will be rolled back in the middle tier if necessary
	-- Ensure that fnd doesn't add a commit in here
	create_url_attachments
		(p_batch_id,
		l_auc_header_id,
		p_bid_number,
		p_userid);

	-- Push the data to the transaction tables so we can validate it
	copy_interface_to_txn_tables
		(p_batch_id,
		l_auc_header_id,
		p_bid_number,
		p_userid,
		l_header_disp_pf,
		l_blanket,
		l_mas,
		l_progress_payment_type,
		'TXT',
		l_price_precision,
                 --p_price_tiers_indicator in copy_interface_to_txn_tables() only used for xml upload mode, so it doesn't matter what this value is.
                '');

	-- Update auction currency columns for the current batch
	PON_RESPONSE_PVT.recalculate_auc_curr_prices(p_bid_number, 'N', p_batch_id);

	-- Update group amounts for the current batch
	-- NOTE: group amount is only calculated at the time of publish
	-- PON_RESPONSE_PVT.calculate_group_amounts(p_bid_number, l_supplier_user, 'N', p_batch_id);

	-- Validate the data once it has been copied to the transaction tables
	PON_BID_VALIDATIONS_PKG.validate_spreadsheet_upload
		(l_auc_header_id,
		p_bid_number,
		'BIDBYSPREADSHEET',
                PON_BID_VALIDATIONS_PKG.g_txt_upload_mode,
		p_userid,
		p_batch_id,
		p_request_id,
		x_return_status,
		x_return_code);

END process_spreadsheet_data;

/*
   To validate Xml spreadsheet header entity
*/

PROCEDURE VALIDATE_HEADER
(
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_auction_header_id IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_request_id		IN pon_bid_item_prices.request_id%TYPE,
    p_user_id           IN pon_interface_errors.created_by%TYPE
) IS

l_loginid NUMBER;
l_interface_type pon_interface_errors.interface_type%TYPE;
l_lines_worksheet_sequence NUMBER;
l_header_worksheet_sequence NUMBER;
l_suffix VARCHAR2(2);
BEGIN

l_loginid := fnd_global.login_id;
l_interface_type := 'BIDBYSPREADSHEET';
l_header_worksheet_sequence := 1;
l_lines_worksheet_sequence := 2;

l_suffix := PON_LARGE_AUCTION_UTIL_PKG.get_doctype_suffix(p_auction_header_id);

INSERT ALL
--1
WHEN s_min_bid_change IS NOT NULL
AND s_min_bid_change_type <> 'PERCENTAGE'
AND PON_BID_VALIDATIONS_PKG.validate_price_precision(
			s_min_bid_change, s_bid_price_precision) = 'F' THEN
 INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				REQUEST_ID,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE,
               	WORKSHEET_NAME,
               	WORKSHEET_SEQUENCE_NUMBER
                )
VALUES
               (
				l_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_MIN_BID_DEC' ||l_suffix),
				p_batch_id,
				s_proxy_bid_row,
				'PON_AUC_MINDEC_INVALID_PREC' || l_suffix,
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
                l_loginid,
				p_request_id,
				s_min_bid_change,
				'NUM',
				s_auction_header_id,
				s_bid_number,
				g_exp_date,
				s_lines_worksheet_name,
				l_lines_worksheet_sequence
               )
--2
WHEN s_min_bid_change IS NOT NULL
AND s_min_bid_change <= 0 THEN
 INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				REQUEST_ID,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE,
               	WORKSHEET_NAME,
               	WORKSHEET_SEQUENCE_NUMBER
                )
VALUES
               (
				l_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_MIN_BID_DEC' ||l_suffix),
				p_batch_id,
				s_proxy_bid_row,
				'PON_AUC_MINDEC_POS' || l_suffix,
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
                l_loginid,
				p_request_id,
				s_min_bid_change,
				'NUM',
				s_auction_header_id,
				s_bid_number,
				g_exp_date,
				s_lines_worksheet_name,
				l_lines_worksheet_sequence
               )
--3
WHEN s_min_bid_change IS NOT NULL
AND s_min_bid_change < s_auc_min_bid_decrement THEN
 INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				REQUEST_ID,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE,
               	WORKSHEET_NAME,
               	WORKSHEET_SEQUENCE_NUMBER
                )
VALUES
               (
				l_interface_type,
				fnd_message.get_string('PON', 'PON_AUCTS_MIN_BID_DEC' ||l_suffix),
				p_batch_id,
				s_proxy_bid_row,
				'PON_AUCTS_MIN_DEC_LOWER' || l_suffix,
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
                l_loginid,
				p_request_id,
				s_min_bid_change,
				'NUM',
				s_auction_header_id,
				s_bid_number,
				g_exp_date,
				s_lines_worksheet_name,
				l_lines_worksheet_sequence
               )
--4
WHEN s_surrogate_bid_flag = 'Y'
AND s_response_recvd_time IS NULL THEN
 INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				REQUEST_ID,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE,
               	WORKSHEET_NAME,
               	WORKSHEET_SEQUENCE_NUMBER
                )
VALUES
               (
				l_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_SURROG_RECVD_TIME' ||l_suffix),
				p_batch_id,
				s_response_recvd_row,
				'PON_AUCTS_BAD_SURROG_1' || l_suffix,
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
                l_loginid,
				p_request_id,
				'',
				'TXT',
				s_auction_header_id,
				s_bid_number,
				g_exp_date,
				s_header_worksheet_name,
				l_header_worksheet_sequence
               )
--5
WHEN s_surrogate_bid_flag = 'Y'
AND s_response_recvd_time IS NOT NULL
AND ((s_response_recvd_time > sysdate)
OR (s_open_bidding_date IS NOT NULL AND s_response_recvd_time < s_open_bidding_date)
OR (s_response_recvd_time > s_close_bidding_date)) THEN
 INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				REQUEST_ID,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE,
               	WORKSHEET_NAME,
               	WORKSHEET_SEQUENCE_NUMBER
                )
VALUES
               (
				l_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_SURROG_RECVD_TIME' ||l_suffix),
				p_batch_id,
				s_response_recvd_row,
				'PON_AUCTS_BAD_SURROG_2' || l_suffix,
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
                l_loginid,
				p_request_id,
				s_response_recvd_time,
				'TIM',
				s_auction_header_id,
				s_bid_number,
				g_exp_date,
				s_header_worksheet_name,
				l_header_worksheet_sequence
               )
--6
WHEN s_surrogate_bid_flag = 'Y'
AND s_old_response_recvd_time IS NOT NULL
AND s_response_recvd_time IS NOT NULL
AND s_response_recvd_time < s_old_response_recvd_time THEN
 INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				REQUEST_ID,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE,
               	WORKSHEET_NAME,
               	WORKSHEET_SEQUENCE_NUMBER
                )
VALUES
               (
				l_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_SURROG_RECVD_TIME' ||l_suffix),
				p_batch_id,
				s_response_recvd_row,
				'PON_AUCTS_BAD_SURROG_3' || l_suffix,
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
                l_loginid,
				p_request_id,
				s_response_recvd_time,
				'TIM',
				s_auction_header_id,
				s_bid_number,
				g_exp_date,
				s_header_worksheet_name,
				l_header_worksheet_sequence
               )
--7
WHEN s_bid_valid_until IS NOT NULL
AND s_bid_valid_until < s_close_bidding_date THEN
 INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				LAST_UPDATE_LOGIN,
				REQUEST_ID,
				ERROR_VALUE_DATE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				EXPIRATION_DATE,
               	WORKSHEET_NAME,
               	WORKSHEET_SEQUENCE_NUMBER
                )
VALUES
               (
				l_interface_type,
				fnd_message.get_string('PON', 'PON_AUC_BID_VALID_UNTIL' ||l_suffix),
				p_batch_id,
				s_reference_number_row,
				'PON_AUCTS_BAD_BID_CLOSE' || l_suffix,
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
                l_loginid,
				p_request_id,
				s_bid_valid_until,
				'DAT',
				s_auction_header_id,
				s_bid_number,
				g_exp_date,
				s_header_worksheet_name,
				l_header_worksheet_sequence
               )
SELECT
    pbhi.auction_header_id s_auction_header_id,
	pbhi.bid_number s_bid_number,
	pbhi.BID_EXPIRATION_DATE s_bid_valid_until,
	pbhi.SURROG_BID_RECEIPT_DATE s_response_recvd_time,
	pbhi.MIN_BID_CHANGE s_min_bid_change,
	pbhi.PROXY_BID_ROW s_proxy_bid_row,
	pbhi.REFERENCE_NUMBER_ROW s_reference_number_row,
	(pbhi.REFERENCE_NUMBER_ROW -1) s_response_recvd_row,
	pbhi.HEADER_WORKSHEET_NAME s_header_worksheet_name,
	pbhi.LINES_WORKSHEET_NAME s_lines_worksheet_name,
	nvl(pah.min_bid_change_type,'AMOUNT') s_min_bid_change_type,
	pah.min_bid_decrement s_auc_min_bid_decrement,
	pah.open_bidding_date s_open_bidding_date,
	pah.close_bidding_date s_close_bidding_date,
	pbh.old_surrog_bid_receipt_date s_old_response_recvd_time,
	pbh.surrog_bid_flag s_surrogate_bid_flag,
	pbh.number_price_decimals s_bid_price_precision
FROM PON_BID_HEADERS_INTERFACE pbhi,
     PON_AUCTION_HEADERS_ALL pah,
     PON_BID_HEADERS pbh
WHERE pbhi.batch_id = p_batch_id
AND   pbhi.bid_number = p_bid_number
AND   pbh.bid_number = pbhi.bid_number
AND   pah.auction_header_id = pbh.auction_header_id;

END VALIDATE_HEADER;

PROCEDURE validate_xml_price_breaks
(
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_auction_header_id IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_request_id		IN pon_bid_item_prices.request_id%TYPE,
    p_user_id           IN pon_interface_errors.created_by%TYPE
)
IS
l_interface_type pon_interface_errors.interface_type%TYPE;

BEGIN
	l_interface_type := 'BIDBYSPREADSHEET';
	INSERT ALL

		-- Price Type can not be null. This secnario only possible for Xml Spreadsheet, which is not exist
		-- for online case.
		WHEN s_price_type is null THEN
			INTO pon_interface_errors
				(INTERFACE_TYPE,
				TABLE_NAME,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ENTITY_TYPE,
				ENTITY_ATTR_NAME,
				ERROR_VALUE_NUMBER,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				SHIPMENT_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER,
				ENTITY_MESSAGE_CODE)
			VALUES
				(l_interface_type,
				'PON_BID_SHIPMENTS',
				fnd_message.get_string('PON', 'PON_BID_PRICE_OR_DISCOUNT'),
				p_batch_id,
				s_interface_line_id,
				'PON_FIELD_MUST_BE_ENTERED',
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
				p_request_id,
				'BID_PBS',
				'PriceType',
				s_price_type,
				'TXT',
				p_auction_header_id,
				p_bid_number,
				s_line_number,
				s_shipment_number,
				g_exp_date,
				'LINENUMBER',
				s_document_disp_line_number,
				s_worksheet_name,
				s_worksheet_seq_num,
				s_entity_name)
	select bshi.price_type s_price_type,
		   bshi.line_number s_line_number,
		   bshi.bid_shipment_number s_shipment_number,
		   bshi.interface_line_id s_interface_line_id,
		   bipi.document_disp_line_number s_document_disp_line_number,
	   	   bipi.worksheet_name s_worksheet_name,
       	   bipi.worksheet_sequence_number s_worksheet_seq_num,
	   	   'PON_AUCTS_PRICE_BREAKS' s_entity_name
	from
		 pon_bid_item_prices_interface bipi,
		 pon_bid_shipments_int bshi
		 where bshi.batch_id = p_batch_id
		 	   and bshi.bid_number = p_bid_number
			   and bshi.action in (g_pb_required, g_pb_optional, g_pb_new)
			   and bshi.batch_id = bipi.batch_id
			   and bshi.bid_number = bipi.bid_number
			   and bshi.line_number = bipi.line_number;

END validate_xml_price_breaks;



PROCEDURE VALIDATE_XML
(
	p_batch_id		IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_auction_header_id 	IN pon_auction_headers_all.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
    	p_request_id        	IN pon_bid_headers.request_id%TYPE,
	p_user_id		IN pon_bid_item_prices.last_updated_by%TYPE,
        p_suffix                IN VARCHAR2,
	p_has_pe		IN pon_auction_item_prices_all.HAS_PRICE_ELEMENTS_FLAG%TYPE,
        l_attr_enabled_flag     IN pon_auction_headers_all.line_attribute_enabled_flag%TYPE,
        l_req_enabled_flag      IN pon_auction_headers_all.hdr_attribute_enabled_flag%TYPE,
        l_has_hdr_attr_flag     IN pon_auction_headers_all.has_hdr_attr_flag%TYPE,
	p_progress_payment_type IN pon_auction_headers_all.progress_payment_type%TYPE,
	p_blanket IN varchar2,
        p_price_tiers_indicator IN pon_auction_headers_all.PRICE_TIERS_INDICATOR%type
) IS
BEGIN

   --Validate header fields
   VALIDATE_HEADER(p_batch_id, p_auction_header_id, p_bid_number, p_request_id, p_user_id);

   IF (l_req_enabled_flag = 'Y' and l_has_hdr_attr_flag = 'Y') THEN

     -- Validate bid values against datatype
     validate_xml_req_values(p_auction_header_id, p_bid_number, p_user_id, p_suffix, p_batch_id, p_request_id);

   END IF;


   --Validate payments fields
   IF p_progress_payment_type <> 'NONE' THEN
     PON_VALIDATE_PAYMENTS_INT.VALIDATE_RESPONSE(PON_BID_VALIDATIONS_PKG.g_xml_upload_mode, p_batch_Id, p_bid_number, p_auction_header_id, p_request_id);
   END IF;

  IF (l_attr_enabled_flag = 'Y') THEN

    -- Validate bid values against datatype
    validate_xml_attr_values(p_auction_header_id, p_bid_number, p_user_id, p_suffix, p_batch_id, p_request_id);

  END IF;

  IF (p_blanket = 'Y' and p_price_tiers_indicator = g_pt_indicator_pricebreak) THEN
  	 validate_xml_price_breaks(p_batch_id, p_auction_header_id, p_bid_number, p_request_id, p_user_id);
  END IF;
  --Continue other entity validations if any

	/*
	-- commented out validation for supplier cost factors
	-- need to think further whether such a situation will arise
	-- in case of XML upload as the workbook will be locked
  	--1. validate price elements or cost factors
	-- Report an error if not all SUPPLIER pf's on a line were found
	-- Error is reported per line. Price factor errors reported below.
	-- NOTE: this error check is performed before that for BUYER pf's
	IF (p_has_pe = 'Y') THEN

		INSERT INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				WORKSHEET_NAME,
				WORKSHEET_SEQUENCE_NUMBER)
		(SELECT
				'BIDBYSPREADSHEET',
				fnd_message.get_string('PON', 'PON_AUC_PRICE_ELEMENT'),
				p_batch_id,
				bpei.interface_line_id,
				'PON_AUC_NOT_ALL_BID_PE',
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
				p_request_id,
				'TXT',
				bli.auction_header_id,
				bli.bid_number,
				bli.line_number,
				g_exp_date,
				bpei.worksheet_name,
				bpei.worksheet_sequence_number
		FROM pon_bid_item_prices_interface bli,
             	     pon_bid_item_prices bip,
		     pon_bid_price_elements_int bpei
		WHERE bli.batch_id 	= p_batch_id
                AND bli.bid_number 	= bip.bid_number
                AND bli.line_number 	= bip.line_number
                AND bip.display_price_factors_flag = 'Y'
		AND bpei.batch_id 	= bli.batch_id
		AND bpei.line_number 	= bli.line_number
		AND EXISTS
			(SELECT bpfi.price_element_type_id
			 FROM pon_bid_price_elements_int bpfi,
			      pon_price_elements apf
			 WHERE apf.auction_header_id 	= p_auction_header_id
			 AND apf.line_number 		= bli.line_number
			 AND apf.pf_type 		= 'SUPPLIER'
			 AND bpfi.batch_id (+) 		= bli.batch_id
			 AND bpfi.line_number (+) 	= apf.line_number
			 AND bpfi.price_element_type_id (+) = apf.price_element_type_id
			 AND rownum = 1));

	END IF;
	*/

END VALIDATE_XML;


--  Changes on determine skipped line.
-- 1) Change that is common for existing child entities: Joining key of interface_line_id should be changed to line ID
-- 2) New logic should be added for new entities like Price Break, Price Break Level PD, Payment etc,
PROCEDURE determine_xml_skipped_lines
(
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_full_qty			IN VARCHAR2
) IS
BEGIN

	-- PRECONDITIONS:
	-- line_number are set for lines; it need not be set for children

	-- Determine if any lines can be ignored
	UPDATE pon_bid_item_prices_interface bli
	SET bli.interface_line_id = g_skip_int
	WHERE bli.batch_id = p_batch_id
		AND EXISTS
			(SELECT 'Y'
			FROM pon_auction_item_prices_all al, pon_bid_item_prices bl
			WHERE bl.bid_number = bli.bid_number
				AND bl.line_number = bli.line_number
				AND al.auction_header_id = bl.auction_header_id
				AND al.line_number = bl.line_number
				AND (
					-- GROUPs ignored - do not skip a group
					-- al.group_type = 'GROUP'

					-- proxy lines ignored
					--OR
					bl.copy_price_for_proxy_flag = 'Y'

					-- empty lines ignored
					OR ( (al.price_disabled_flag = 'Y'
						OR bli.bid_currency_price IS null)
						AND (al.quantity_disabled_flag = 'Y'
						    OR bli.quantity IS null
						    OR (p_full_qty = 'Y' OR al.group_type = 'LOT_LINE'
							OR al.order_type_lookup_code = 'AMOUNT'))
						AND bli.note_to_auction_owner IS null
						AND bli.promised_date IS null
					-- If the values of these columns are NOT same as that in the transaction table
					-- (pon_bid_item_prices) then DO NOT skip.
					-- If the values are same as that in the transaction table then skip.
					-- You do not have to check about optional or required pay items.
					AND NVL(bli.recoupment_rate_percent, -9999) 	= NVL(bl.recoupment_rate_percent, -9999)
					AND NVL(bli.bid_curr_advance_amount, -9999)    	= NVL(bl.bid_curr_advance_amount, -9999)
					AND NVL(bli.bid_curr_max_retainage_amt, -9999) 	= NVL(bl.bid_curr_max_retainage_amt, -9999)
					AND NVL(bli.retainage_rate_percent, -9999) 	= NVL(bl.retainage_rate_percent,-9999)
					AND NVL(bli.progress_pymt_rate_percent, -9999) 	= NVL(bl.progress_pymt_rate_percent, -9999)

					-- No price elements
					AND(bl.display_price_factors_flag = 'N'
							OR NOT EXISTS
								(SELECT bpfi.price_element_type_id
								FROM pon_bid_price_elements_int bpfi
								WHERE bpfi.batch_id = bli.batch_id
								AND bpfi.line_number = bli.line_number
								AND bpfi.bid_currency_value IS NOT null))
						-- No line / Price Break level price differentials
						AND ( NOT EXISTS
								(SELECT bpdi.sequence_number
								FROM pon_bid_price_differ_int bpdi
								WHERE bpdi.batch_id = bli.batch_id
								and bpdi.auction_line_number = bli.line_number
									--and bpdi.shipment_number = -1
									AND bpdi.multiplier IS NOT null))
						-- No Price Breaks - tricky part.
						-- According to ECO:
						-- If there is no value enterred for Price/Discount, user is intended to delete this PB.
						-- This action will over write all other actions like update, Currently it is also decided that
						-- the new PB will also driven by this Price/Discount column, if no value entered for this field
						-- just consider intended to delete it, or do not insert it at all.
						-- Thus, when determine skipped line, do not consider those that are intended to be deleted.
                                                -- For Price Tier, only consider Price, Price Discount is always null.
						AND ( NOT EXISTS
							  	  (SELECT bshi.line_number
								  FROM pon_bid_shipments_int bshi
								  WHERE bshi.batch_id = bli.batch_id
								  and bshi.line_number = bli.line_number
								  and bshi.action in ( g_pb_required, g_pb_optional, g_pb_new )
								  and (bshi.bid_currency_unit_price IS NOT null
								      or bshi.price_discount IS NOT null )) )
						-- No attributes
						AND (al.has_attributes_flag = 'N'
							OR NOT EXISTS -- no attributes
								(SELECT bai.attribute_name
								FROM pon_bid_attr_values_interface bai
								WHERE bai.batch_id = bli.batch_id
								AND bai.line_number = bli.line_number
								AND bai.value IS NOT null))
						-- No payments
						AND (NOT EXISTS -- no payments
								(SELECT pbpi.interface_line_id
								FROM pon_bid_payments_interface pbpi
								WHERE pbpi.batch_id = bli.batch_id
								AND pbpi.document_disp_line_number = al.document_disp_line_number
								AND (pbpi.bid_currency_price IS NOT NULL
								OR pbpi.promised_date IS NOT NULL)
								))
                                )));

END determine_xml_skipped_lines;




PROCEDURE remove_xml_skipped_lines
(
	p_auc_header_id		IN pon_bid_item_prices_interface.auction_header_id%TYPE,
	p_batch_id		IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_request_id		IN pon_bid_headers.request_id%TYPE,
	p_userid		IN pon_interface_errors.created_by%TYPE,
	p_full_qty		IN VARCHAR2,
	p_buyer_user		IN VARCHAR2,
	p_suffix		IN VARCHAR2
) IS
BEGIN

	-- Determine if there are any lines to be skipped, mark them so.
	determine_xml_skipped_lines(p_batch_id, p_full_qty);

	-- Mark closed lines as closed and report an error - only for suppliers
	-- do not validate any closed lines as we skip such closed lines
	-- while downloading the XML itself
	-- IF (p_buyer_user = 'N') THEN
  	--	determine_xml_closed_lines(p_auc_header_id, p_batch_id, p_request_id, p_userid, p_suffix);
	-- end if;

	-- delete bid attribute values from interface tables
	DELETE FROM pon_bid_attr_values_interface bai
	WHERE bai.batch_id = p_batch_id
	AND bai.line_number in (
			select bli.line_number
			from pon_bid_item_prices_interface bli
			where bli.batch_id = p_batch_id
			AND bli.interface_line_id = g_skip_int);

	-- Delete from price elements interface table
	DELETE FROM pon_bid_price_elements_int bpfi
	WHERE bpfi.batch_id = p_batch_id
	AND bpfi.line_number in (
			select bli.line_number
			from pon_bid_item_prices_interface bli
			where bli.batch_id = p_batch_id
			AND bli.interface_line_id = g_skip_int);

	-- Delete from price differentials interface table
	DELETE FROM pon_bid_price_differ_int bpdi
	WHERE bpdi.batch_id = p_batch_id
		AND bpdi.auction_line_number in (
			select bli.line_number
			from pon_bid_item_prices_interface bli
			where bli.batch_id = p_batch_id
			AND bli.interface_line_id = g_skip_int);

	-- Delete from price breaks / price tiers interface table
	DELETE FROM pon_bid_shipments_int bshi
	WHERE bshi.batch_id = p_batch_id
		AND bshi.line_number in (
			select bli.line_number
			from pon_bid_item_prices_interface bli
			where bli.batch_id = p_batch_id
			AND  bli.interface_line_id = g_skip_int);

	-- Delete from payments interface table
	DELETE FROM pon_bid_payments_interface pbpi
	WHERE pbpi.batch_id = p_batch_id
		AND pbpi.document_disp_line_number in (
			select pai.document_disp_line_number
			from pon_bid_item_prices_interface bli,
                 pon_auction_item_prices_all pai
			where bli.batch_id = p_batch_id
			AND bli.interface_line_id = g_skip_int
            AND pai.auction_header_id = bli.auction_header_id
            AND pai.line_number = bli.line_number);

	-- Delete all bid lines from interface table
	DELETE FROM pon_bid_item_prices_interface bli
	WHERE bli.batch_id = p_batch_id
	AND bli.interface_line_id = g_skip_int;


END remove_xml_skipped_lines;

PROCEDURE validate_xml_req_values
(
	p_auction_header_id	IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_user_id		IN pon_interface_errors.created_by%TYPE,
	p_suffix		IN VARCHAR2,
	p_batch_id		IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
) IS
        -- Define table definitions
	TYPE lineNumberTable      IS TABLE of pon_auction_item_prices_all.line_number%TYPE;
	TYPE intLineTable         IS TABLE of pon_bid_attr_values_interface.interface_line_id%TYPE;
	TYPE attrNameTable        IS TABLE of pon_auction_attributes.attribute_name%TYPE;
	TYPE seqNumTable          IS TABLE of pon_auction_attributes.sequence_number%TYPE;
	TYPE datatypeTable        IS TABLE of pon_auction_attributes.datatype%TYPE;
	TYPE valueTable           IS TABLE of pon_bid_attr_values_interface.value%TYPE;
	TYPE worksheetTable       IS TABLE of pon_bid_attr_values_interface.worksheet_name%TYPE;
	TYPE worksheetSeqNumTable IS TABLE of pon_bid_attr_values_interface.worksheet_sequence_number%TYPE;

        -- Local table variables
        l_line_numbers          lineNumberTable;
	l_int_lines             intLineTable;
	l_attr_names 		attrNameTable;
	l_sequence_numbers	seqNumTable;
	l_datatypes		datatypeTable;
	l_values                valueTable;
	l_worksheet_names	worksheetTable;
	l_worksheet_seq_numbers	worksheetSeqNumTable;

        -- Person party id
        l_person_party_id fnd_user.person_party_id%TYPE;

        -- Timezone variables
	l_oex_timezone		VARCHAR2(80);
	l_timezone		VARCHAR2(80);
	l_is_valid_timezone	VARCHAR2(1);

        -- Error variables
	l_num_errors		NUMBER;
	l_index			NUMBER;



BEGIN

        select person_party_id
        into   l_person_party_id
        from   fnd_user
        where  user_id = p_user_id;

	-- Set timezone variables
	l_oex_timezone := PON_AUCTION_PKG.Get_Oex_Time_Zone;

	l_timezone := PON_AUCTION_PKG.Get_Time_Zone(l_person_party_id);
	if (l_timezone is null or l_timezone = '') then
 	  l_timezone := l_oex_timezone;
	end if;

	if (PON_OEX_TIMEZONE_PKG.valid_zone(l_timezone) = 1) then
	  l_is_valid_timezone := 'Y';
	else
	  l_is_valid_timezone := 'N';
	end if;

	-- Bulk collect all the interface requirements
	SELECT  paa.line_number,
		pbai.interface_line_id,
		paa.attribute_name,
                paa.sequence_number,
		paa.datatype,
		pbai.value,
		pbai.worksheet_name,
		pbai.worksheet_sequence_number
	BULK COLLECT INTO
		l_line_numbers,
		l_int_lines,
		l_attr_names,
                l_sequence_numbers,
		l_datatypes,
		l_values,
		l_worksheet_names,
		l_worksheet_seq_numbers
	FROM
                pon_bid_attr_values_interface pbai,
		pon_auction_attributes paa
	WHERE
		pbai.auction_header_id = p_auction_header_id
            AND pbai.bid_number = p_bid_number
            AND pbai.batch_id = p_batch_id
            AND pbai.line_number = -1
            AND pbai.auction_header_id = paa.auction_header_id
            AND pbai.line_number = paa.line_number
            AND pbai.sequence_number = paa.sequence_number;

	-- Attempt the datatype conversions
	FORALL i IN l_int_lines.FIRST..l_int_lines.LAST SAVE EXCEPTIONS
		UPDATE pon_bid_attr_values_interface pbai
			SET pbai.value = decode(l_datatypes(i),
				'TXT', l_values(i),
                                'NUM', to_char(to_number(l_values(i), g_xml_number_mask, 'NLS_NUMERIC_CHARACTERS=''.,'''),
                                               decode(to_number(l_values(i), g_xml_number_mask, 'NLS_NUMERIC_CHARACTERS=''.,''') - floor(to_number(l_values(i), g_xml_number_mask, 'NLS_NUMERIC_CHARACTERS=''.,''')),
                                                      0,
                                                      g_xml_char_no_prec_mask,
                                                      g_xml_char_prec_mask),
                                               'NLS_NUMERIC_CHARACTERS=''.,'''),
				'DAT', decode(l_sequence_numbers(i), g_attr_need_by_date_seq,
                                              to_char(decode(l_is_valid_timezone, 'Y',
                                                             PON_OEX_TIMEZONE_PKG.convert_time(to_date(l_values(i), g_xml_date_time_mask),
                                                                                               l_timezone, l_oex_timezone),
                                                             to_date(l_values(i), g_xml_date_time_mask)),
                                                      g_pon_date_time_mask),
                                              to_char(to_date(l_values(i), g_xml_date_mask), g_pon_date_mask)),
                               'URL', l_values(i))
		WHERE   pbai.auction_header_id = p_auction_header_id
                    AND pbai.bid_number = p_bid_number
                    AND pbai.batch_id = p_batch_id
                    AND pbai.line_number = l_line_numbers(i)
		    AND pbai.sequence_number = l_sequence_numbers(i);

	-- NOTE: calling procedure should purge invalid requirements

EXCEPTION

	WHEN OTHERS THEN
		l_num_errors := SQL%BULK_EXCEPTIONS.COUNT;

		-- Insert errors for each erroneous requirement
		FOR i IN 1..l_num_errors LOOP

			l_index := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;

			INSERT INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
                                WORKSHEET_NAME,
                                WORKSHEET_SEQUENCE_NUMBER,
                                ENTITY_MESSAGE_CODE)
			VALUES
				('BIDBYSPREADSHEET',
				fnd_message.get_string('PON', 'PON_AUCTS_BID_VALUE' || p_suffix),
				'PON_BID_ATTR_VALUES',
				p_batch_id,
				l_int_lines(l_index),
				'PON_AUCTS_ATTR_INVALID_VALUE' || p_suffix,
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
				p_request_id,
				l_values(l_index),
				'TXT',
				p_auction_header_id,
				p_bid_number,
				l_line_numbers(l_index),
				g_exp_date,
        l_worksheet_names(l_index),
        l_worksheet_seq_numbers(l_index),
        Decode(PON_SLM_UTIL_PKG.IS_SLM_DOCUMENT(p_auction_header_id), 'Y', 'PON_SLM_QUESTIONAIRE','PON_AUC_REQUIREMENTS'));  --SLM UI Enhancement

                        UPDATE
                                pon_bid_attr_values_interface pbai
                        SET
                                pbai.value = null
                        WHERE
                                pbai.auction_header_id = p_auction_header_id
                            AND pbai.bid_number = p_bid_number
                            AND pbai.batch_id = p_batch_id
                            AND pbai.line_number = l_line_numbers(l_index)
                            AND pbai.sequence_number = l_sequence_numbers(l_index);

			END LOOP;

END validate_xml_req_values;



PROCEDURE validate_xml_attr_values
(
	p_auction_header_id	IN pon_bid_item_prices.auction_header_id%TYPE,
	p_bid_number		IN pon_bid_item_prices.bid_number%TYPE,
	p_user_id		IN pon_interface_errors.created_by%TYPE,
	p_suffix		IN VARCHAR2,
	p_batch_id		IN pon_interface_errors.batch_id%TYPE,
	p_request_id		IN pon_interface_errors.request_id%TYPE
) IS
        -- Define table definitions
	TYPE docDispLineNumTable  IS TABLE of pon_auction_item_prices_all.document_disp_line_number%TYPE;
	TYPE lineNumberTable      IS TABLE of pon_auction_item_prices_all.line_number%TYPE;
	TYPE intLineTable         IS TABLE of pon_bid_attr_values_interface.interface_line_id%TYPE;
	TYPE attrNameTable        IS TABLE of pon_auction_attributes.attribute_name%TYPE;
	TYPE seqNumTable          IS TABLE of pon_auction_attributes.sequence_number%TYPE;
	TYPE datatypeTable        IS TABLE of pon_auction_attributes.datatype%TYPE;
	TYPE valueTable           IS TABLE of pon_bid_attr_values_interface.value%TYPE;
	TYPE worksheetTable       IS TABLE of pon_bid_attr_values_interface.worksheet_name%TYPE;
	TYPE worksheetSeqNumTable IS TABLE of pon_bid_attr_values_interface.worksheet_sequence_number%TYPE;

        -- Local table variables
	l_disp_line_numbers     docDispLineNumTable;
	l_line_numbers 		lineNumberTable;
	l_int_lines             intLineTable;
	l_attr_names 		attrNameTable;
	l_sequence_numbers	seqNumTable;
	l_datatypes		datatypeTable;
	l_values                valueTable;
	l_worksheet_names	worksheetTable;
	l_worksheet_seq_numbers	worksheetSeqNumTable;

        -- Person party id
        l_person_party_id fnd_user.person_party_id%TYPE;

        -- Timezone variables
	l_oex_timezone		VARCHAR2(80);
	l_timezone		VARCHAR2(80);
	l_is_valid_timezone	VARCHAR2(1);

        -- Error variables
	l_num_errors		NUMBER;
	l_index			NUMBER;



BEGIN

        select person_party_id
        into   l_person_party_id
        from   fnd_user
        where  user_id = p_user_id;

	-- Set timezone variables
	l_oex_timezone := PON_AUCTION_PKG.Get_Oex_Time_Zone;

	l_timezone := PON_AUCTION_PKG.Get_Time_Zone(l_person_party_id);
	if (l_timezone is null or l_timezone = '') then
 	  l_timezone := l_oex_timezone;
	end if;

	if (PON_OEX_TIMEZONE_PKG.valid_zone(l_timezone) = 1) then
	  l_is_valid_timezone := 'Y';
	else
	  l_is_valid_timezone := 'N';
	end if;

	-- Bulk collect all the interface attributes
	SELECT
		paip.document_disp_line_number,
		paa.line_number,
		pbai.interface_line_id,
		paa.attribute_name,
                paa.sequence_number,
		paa.datatype,
		pbai.value,
		pbai.worksheet_name,
		pbai.worksheet_sequence_number
	BULK COLLECT INTO
		l_disp_line_numbers,
		l_line_numbers,
		l_int_lines,
		l_attr_names,
                l_sequence_numbers,
		l_datatypes,
		l_values,
		l_worksheet_names,
		l_worksheet_seq_numbers
	FROM
                pon_bid_attr_values_interface pbai,
		pon_auction_attributes paa,
		pon_auction_item_prices_all paip
	WHERE
		pbai.auction_header_id = p_auction_header_id
            AND pbai.bid_number = p_bid_number
            AND pbai.batch_id = p_batch_id
            AND pbai.line_number <> -1
            AND pbai.auction_header_id = paa.auction_header_id
            AND pbai.line_number = paa.line_number
            AND pbai.sequence_number = paa.sequence_number
	    AND paa.auction_header_id = paip.auction_header_id
	    AND paa.line_number = paip.line_number;

	-- Attempt the datatype conversions
	FORALL i IN l_int_lines.FIRST..l_int_lines.LAST SAVE EXCEPTIONS
		UPDATE pon_bid_attr_values_interface pbai
			SET pbai.value = decode(l_datatypes(i),
				'TXT', l_values(i),
                                'NUM', to_char(to_number(l_values(i), g_xml_number_mask, 'NLS_NUMERIC_CHARACTERS=''.,'''),
                                               decode(to_number(l_values(i), g_xml_number_mask, 'NLS_NUMERIC_CHARACTERS=''.,''') - floor(to_number(l_values(i), g_xml_number_mask, 'NLS_NUMERIC_CHARACTERS=''.,''')),
                                                      0,
                                                      g_xml_char_no_prec_mask,
                                                      g_xml_char_prec_mask),
                                               'NLS_NUMERIC_CHARACTERS=''.,'''),
				'DAT', decode(l_sequence_numbers(i), g_attr_need_by_date_seq,
                                              to_char(decode(l_is_valid_timezone, 'Y',
                                                             PON_OEX_TIMEZONE_PKG.convert_time(to_date(l_values(i), g_xml_date_time_mask),
                                                                                               l_timezone, l_oex_timezone),
                                                             to_date(l_values(i), g_xml_date_time_mask)),
                                                      g_pon_date_time_mask),
                                              to_char(to_date(l_values(i), g_xml_date_mask), g_pon_date_mask)),
                               'URL', l_values(i))
		WHERE   pbai.auction_header_id = p_auction_header_id
                    AND pbai.bid_number = p_bid_number
                    AND pbai.batch_id = p_batch_id
                    AND pbai.line_number = l_line_numbers(i)
                    AND pbai.sequence_number = l_sequence_numbers(i);

	-- NOTE: calling procedure should purge invalid attributes

EXCEPTION

	WHEN OTHERS THEN
		l_num_errors := SQL%BULK_EXCEPTIONS.COUNT;

		-- Insert errors for each erroneous attribute
		FOR i IN 1..l_num_errors LOOP

			l_index := SQL%BULK_EXCEPTIONS(i).ERROR_INDEX;

			INSERT INTO pon_interface_errors
				(INTERFACE_TYPE,
				COLUMN_NAME,
				TABLE_NAME,
				BATCH_ID,
				INTERFACE_LINE_ID,
				ERROR_MESSAGE_NAME,
				CREATED_BY,
				CREATION_DATE,
				LAST_UPDATED_BY,
				LAST_UPDATE_DATE,
				REQUEST_ID,
				ERROR_VALUE,
				ERROR_VALUE_DATATYPE,
				AUCTION_HEADER_ID,
				BID_NUMBER,
				LINE_NUMBER,
				EXPIRATION_DATE,
				TOKEN1_NAME,
				TOKEN1_VALUE,
				TOKEN2_NAME,
				TOKEN2_VALUE,
                                WORKSHEET_NAME,
                                WORKSHEET_SEQUENCE_NUMBER,
                                ENTITY_MESSAGE_CODE)
			VALUES
				('BIDBYSPREADSHEET',
				fnd_message.get_string('PON', 'PON_AUCTS_BID_VALUE' || p_suffix),
				'PON_BID_ATTR_VALUES',
				p_batch_id,
				l_int_lines(l_index),
				'PON_AUC_ATTR_INVALID_TARGET' || p_suffix,
				p_user_id,
				sysdate,
				p_user_id,
				sysdate,
				p_request_id,
				l_values(l_index),
				'TXT',
				p_auction_header_id,
				p_bid_number,
				l_line_numbers(l_index),
				g_exp_date,
				'LINENUMBER',
				l_disp_line_numbers(l_index),
				'ATTRIBUTENAME',
				l_attr_names(l_index),
                                l_worksheet_names(l_index),
                                l_worksheet_seq_numbers(l_index),
                                'PON_AUC_ATTRIBUTES');

			UPDATE
				pon_bid_attr_values_interface pbai
			SET
                                pbai.value = null
			WHERE
				pbai.auction_header_id = p_auction_header_id
			    AND pbai.bid_number = p_bid_number
			    AND pbai.batch_id = p_batch_id
			    AND pbai.line_number = l_line_numbers(l_index)
			    AND pbai.sequence_number = l_sequence_numbers(l_index);


			END LOOP;

END validate_xml_attr_values;




PROCEDURE copy_shipment_interface_to_txn
(
	p_batch_id			IN pon_bid_item_prices_interface.batch_id%TYPE,
	p_bid_number		IN pon_bid_headers.bid_number%TYPE,
	p_userid			IN pon_bid_item_prices.last_updated_by%TYPE,
    p_bid_currency_precision IN pon_bid_headers.number_price_decimals%TYPE,
        p_shipment_type               IN pon_bid_shipments.shipment_type%TYPE
)
is
l_module CONSTANT VARCHAR2(32) := 'copy_shipment_interface_to_txn';
l_line_number_col 			 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_shipment_number_col 		 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_auction_header_id_col 	 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_interface_line_id_col 	 PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_ship_to_organization_id_col PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_ship_to_location_id_col 	  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_quantity_col 				  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_price_type_col 			  PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_bid_currency_unit_price_col PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_price_discount_col		  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_effective_start_date_col 	  PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
l_effective_end_date_col	  PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;

l_counter 					  number;
l_curr_line_number 			  number;
BEGIN

	 --1.	Populate Bid_shipment_number in Price Break Interface table
	 -- Pupulate bid_shipment_number for those that were unknown ( fresh bid when there is no draft case ).
	 	update pon_bid_shipments_int bshi
		set bid_shipment_number =
	   		NVL( (select bsh.shipment_number
	   		 from pon_bid_shipments bsh
			 where bsh.bid_number = bshi.bid_number
			 and bsh.line_number = bshi.line_number
			 and bsh.auction_shipment_number = bshi.auction_shipment_number),
			 bid_shipment_number)
	   where bshi.batch_id = p_batch_id
	   and bshi.bid_number =p_bid_number
	   and bshi.action in ( g_pb_required, g_pb_optional, g_pb_delete);


	 --2.	Update Price Break / Price Tier Transaction based on bid_shipment_number
	 --Notes. The calculation between bid_currency_unit_price and Discount relies on the line's bid_currency_unit_price,
	 --thus this merge should happened after line entity has updated bid_currency_unit_price.
	 MERGE INTO pon_bid_shipments bsh
	 USING
		(SELECT
		    bsi.action,
			bsi.bid_number,
			bsi.auction_header_id,
			bsi.line_number,
			bsi.batch_id,
			bsi.interface_line_id,
			bsi.bid_shipment_number,
			bsi.auction_shipment_number,
			bsi.ship_to_organization_id,
			bsi.ship_to_location_id,
			bsi.quantity,
                        bsi.max_quantity,
			bsi.effective_start_date,
			bsi.effective_end_date,
			bsi.price_type,
			bsi.price_discount,
			bsi.bid_currency_unit_price,
			bip.bid_currency_unit_price item_price
		FROM pon_bid_shipments_int bsi,
		     pon_bid_item_prices bip
		WHERE  bsi.batch_id = p_batch_id
			  and bsi.bid_number = p_bid_number
			  and bsi.bid_number = bip.bid_number
			  and bsi.auction_header_id = bip.auction_header_id
			  and bsi.line_number = bip.line_number
			  and bsi.action in ( g_pb_required, g_pb_optional, g_pb_new)
		) bshi
		ON ( bsh.bid_number = bshi.bid_number
			and bsh.line_number = bshi.line_number
			and bsh.shipment_number = bshi.bid_shipment_number )
 WHEN MATCHED THEN
		UPDATE SET
			bsh.interface_line_id = bshi.interface_line_id,
			bsh.price_type = bshi.price_type,
			bsh.ship_to_organization_id = decode ( bshi.action, g_pb_required, bsh.ship_to_organization_id, --No changes for required PB
															   bshi.ship_to_organization_id),
		    bsh.ship_to_location_id = decode ( bshi.action, g_pb_required, bsh.ship_to_location_id, --No changes for Required PB
														   bshi.ship_to_location_id),
		    bsh.quantity = decode ( bshi.action, g_pb_required, bsh.quantity, -- No changes for Required PB
												bshi.quantity),
                    bsh.max_quantity = bshi.max_quantity,
		    bsh.effective_start_date = decode ( bshi.action, g_pb_required, bsh.effective_start_date, -- No changes for Required PB
														   bshi.effective_start_date),
		    bsh.effective_end_date = decode ( bshi.action, g_pb_required, bsh.effective_end_date, -- No changes for Required PB
														  bshi.effective_end_date),

			bsh.bid_currency_unit_price =
				  NVL2(bshi.item_price,
				  	  -- If item_price is not null,
    			      -- 	if it is PRICE_DISCOUNT type, caculate the bid_currency_unit
    				  -- 	price based on the item_price and price_discount
    				  -- 	and round it up based on bid currency precision.
    		          	decode(bshi.price_type,   'PRICE DISCOUNT',
                          			 		   	   nvl2(bshi.price_discount,
                          						   round(bshi.item_price*(1-bshi.price_discount/100),
												             P_bid_currency_precision),
                          					 	   null),
    					-- if it is PRICE type, copy bid_currency_unit_price
    					-- directly from interface table to transaction table
    					   				 		   'PRICE',
    											   bshi.bid_currency_unit_price,
												   null
							   ),
						-- if item_price is null,
				  		--		 if the price type is price_discount, then set bid_currency_unit_price as null
				  		--         else if the price type is price, then set price_discount as null
				  		--         else just copy as is. -- Notes, it is possible that hte price_type is null for Xml Spreadsheet.
    				    decode(bshi.price_type,'PRICE DISCOUNT',
											   null,
								              'PRICE',
											   bshi.bid_currency_unit_price,
											   null
 							  )
						),
			bsh.price_discount=
                          decode(p_shipment_type, g_shipment_type_quantitybased, null,
			    NVL2(bshi.item_price,
                    -- If item Price is not null
					--         if it is "DISCOUNT" type, copy discount from interface to transaction table
  				 	 decode(bshi.price_type, 'PRICE DISCOUNT',
  					 						bshi.price_discount,
  							    			-- if it is "PRICE" type, and
											--    item_Price != 0 and Bid_currency_unit_price < item_price
											--        sets the price discount to 1-(bid_currency_unit_price/item_price)
  							    		  	 'PRICE',
  					 		    		  	 nvl2(bshi.bid_currency_unit_price,
							       		  			case when ( bshi.bid_currency_unit_price>=bshi.item_price)
														 	  then null
								    				     when ( bshi.bid_currency_unit_price<>0)
														 	  then (1- bshi.bid_currency_unit_price/bshi.item_price)*100
								        			     else null
								   				    end,
  							   					    null
											 ),
  						  					 bshi.price_discount
						   ),
					-- If item_price is null, just copy discount as is, set Price as null.
    			    decode(bshi.price_type,'PRICE',
										  null,
										  'PRICE DISCOUNT',
										  bshi.price_discount,
										  null)
				    )
                        ),
			bsh.last_update_date = sysdate,
			bsh.last_updated_by = P_userid
	-- 3. Insert new rows if not match for new PBs
	WHEN NOT MATCHED THEN
	    	INSERT
		 (  bid_number,
		    line_number,
			shipment_number,
			auction_header_id,
			auction_line_number,
			auction_shipment_number,
			shipment_type,
			ship_to_organization_id,
			ship_to_location_id,
			quantity,
                        max_quantity,
			price_type,
			bid_currency_unit_price,
			price_discount,
			effective_start_date,
			effective_end_date,
			creation_date,
			created_by,
			last_update_date,
			last_updated_by,
			has_price_differentials_flag,
			interface_line_id )
			values
			(
			 p_bid_number,
			 bshi.line_number,
			 bshi.bid_shipment_number,
			 bshi.auction_header_id,
			 bshi.line_number,
			 null,  -- set auction_shipment_number as null since it is Supplier owned PB
			 p_shipment_type,
			 bshi.ship_to_organization_id,
			 bshi.ship_to_location_id,
			 bshi.quantity,
                         bshi.max_quantity,
			 bshi.price_type,
			 NVL2(bshi.item_price,
				  	  -- If item_price is not null,
    			      -- 	if it is PRICE_DISCOUNT type, caculate the bid_currency_unit
    				  -- 	price based on the item_price and price_discount
    				  -- 	and round it up based on bid currency precision.
    		          	decode(bshi.price_type,   'PRICE DISCOUNT',
                          			 		   	   nvl2(bshi.price_discount,
                          						   round(bshi.item_price*(1-bshi.price_discount/100),
												             P_bid_currency_precision),
                          					 	   null),
    					-- if it is PRICE type, copy bid_currency_unit_price
    					-- directly from interface table to transaction table
    					   				 		   'PRICE',
    											   bshi.bid_currency_unit_price,
												   null
							   ),
						-- if item_price is null,
				  		--		 if the price type is price_discount, then set bid_currency_unit_price as null
				  		--         else if the price type is price, then set price_discount as null
				  		--         else just copy as is. -- Notes, it is possible that hte price_type is null for Xml Spreadsheet.
    				    decode(bshi.price_type,'PRICE DISCOUNT',
											   null,
								              'PRICE',
											   bshi.bid_currency_unit_price,
											   null
 							  )
						),
                         decode(p_shipment_type, g_shipment_type_quantitybased, null,
			   NVL2(bshi.item_price,
                    -- If item Price is not null
					--         if it is "DISCOUNT" type, copy discount from interface to transaction table
  				 	 decode(bshi.price_type, 'PRICE DISCOUNT',
  					 						bshi.price_discount,
  							    			-- if it is "PRICE" type, and
											--    item_Price != 0 and Bid_currency_unit_price < item_price
											--        sets the price discount to 1-(bid_currency_unit_price/item_price)
  							    		  	 'PRICE',
  					 		    		  	 nvl2(bshi.bid_currency_unit_price,
							       		  			case when ( bshi.bid_currency_unit_price>=bshi.item_price)
														 	  then null
								    				     when ( bshi.bid_currency_unit_price<>0)
														 	  then (1- bshi.bid_currency_unit_price/bshi.item_price)*100
								        			     else null
								   				    end,
  							   					    null
											 ),
  						  					 bshi.price_discount
						   ),
					-- If item_price is null, just copy discount as is, set Price as null.
    			    decode(bshi.price_type,'PRICE',
										  null,
										  'PRICE DISCOUNT',
										  bshi.price_discount,
										  null)
			   )
                         ),
			 bshi.effective_start_date,
			 bshi.effective_end_date,
			 sysdate,
			 p_userId,
			 sysdate,
			 p_userId,
			 'N',
			 bshi.interface_line_id)
			 where
			   bshi.action = g_pb_new;


	--4.	Delete data from transaction table for those Price Breaks that are flagged to be deleted based on
		  delete from pon_bid_shipments bsh
		   where bsh.bid_number = p_bid_number
		   		and exists
		   		(
				 select 1
				 from pon_bid_shipments_int bsi
				 where bsi.batch_id= p_batch_id
						and bsi.bid_number = P_BID_NUMBER
						and bsi.action = g_pb_delete
						and bsi.bid_number = bsh.bid_number
						and bsi.line_number = bsh.line_number
						and bsi.bid_shipment_number = bsh.shipment_number
						and rownum = 1 );

       --Step 5 and 6 are only for price break.
       IF (p_shipment_type = g_shipment_type_pricebreak) THEN

	--5	Mark Supplier owned Price Break
	-- 5.1 Mark Supplier owned Price Break set auction_shipment_number="" and has_price_differentials_flag='N' by comparing the 5 columns in PON_BID_SHIPMENTS with PON_AUCTION_SHIPMENTS_ALL
	-- Notes, if need to use g_pb_optionals_updated flag to determine skipped line, move this part before determin_xml_skipped_line
	  update
	  pon_bid_shipments_int bsi
	  set bsi.action= g_pb_optional_updated
	  where bsi.batch_id = p_batch_id
	  and bsi.BID_NUMBER = p_bid_number
	  and bsi.action = g_pb_optional
	  and bsi.auction_shipment_number is not null
	  and  exists(
	  	   select 1
		   from
  	  	   pon_auction_shipments_all ash
  		   where
				 ash.auction_header_id = bsi.auction_header_id
				 and ash.line_number = bsi.line_number
				 and ash.shipment_number = bsi.auction_shipment_number
				 and ( nvl(ash.ship_to_organization_id, g_null_int) <> nvl(bsi.ship_to_organization_id, g_null_int)
		 	  	 	 or
			  		 nvl(ash.ship_to_location_id,g_null_int) <> nvl(bsi.ship_to_location_id,g_null_int)
			  		 or
			  		 nvl(ash.quantity,g_null_int) <> nvl(bsi.quantity,g_null_int)
			  		 or
			  		 nvl(ash.effective_start_date,sysdate) <> nvl(bsi.effective_start_date,sysdate)
			  		 or
			 		  nvl(ash.effective_end_date,sysdate) <> nvl(bsi.effective_end_date,sysdate)
					 )
				 and rownum = 1
			);

	-- 5.2  Update shipment transaction table for supplier owned shipments.
	 update
	 pon_bid_shipments bsh
	 set bsh.auction_shipment_number = null,
	 	 bsh.has_price_differentials_flag = 'N'
	 where bsh.bid_number = p_bid_number
	 	   and  exists
	 	   (	select 1
		  		from
  	 	  			pon_bid_shipments_int bshi
  		  	    where bshi.batch_id = p_batch_id
          			  and bshi.bid_number = p_bid_number
		  			  and bshi.action = g_pb_optional_updated
					  and bshi.auction_header_id = bsh.auction_header_id
					  and bshi.bid_number = bsh.bid_number
					  and bshi.line_number = bsh.line_number
					  and bshi.bid_shipment_number = bsh.shipment_number );

	  --6.	Remove Price Differentials from transaction table
	  --Remove Price Differentials from PON_BID_PRICE_DIFFERENTIALS which associated supplier owned Price Break
	  -- and deleted Price Break.
	  delete from pon_bid_price_differentials bsd
	  where
	  bsd.shipment_number<>-1
	  and bsd.bid_number=p_bid_number
	  and bsd.line_number in
	  	  (select bip.line_number
	  	  from pon_bid_item_prices bip
	  	  where bip.batch_id=p_batch_id
		  and bip.bid_number=p_bid_number
		  )
	  and
	  (bsd.bid_number, bsd.line_number, bsd.shipment_number)
	  not in
	  (
	    select bsh.bid_number, bsh.line_number, bsh.shipment_number
	  		 from pon_bid_shipments bsh,pon_bid_item_prices bip
	  		 where bip.batch_id = p_batch_id
	  		 	   and bip.bid_number = p_bid_number
	  			   and bip.bid_number = bsh.bid_number
	  			   and bip.line_number = bsh.line_number
	  			   and (bsh.auction_shipment_number is not null
	  			   and bsh.has_price_differentials_flag='Y')
	  );
       END IF; -- end of IF (p_shipment_type = g_shipment_type_pricebreak



END copy_shipment_interface_to_txn;


PROCEDURE process_xml_spreadsheet_data
(
        p_batch_id              IN pon_bid_item_prices_interface.batch_id%TYPE,
        p_bid_number            IN pon_bid_headers.bid_number%TYPE,
        p_request_id            IN pon_bid_headers.request_id%TYPE,
        p_user_id               IN pon_interface_errors.created_by%TYPE,
        x_return_status         OUT NOCOPY NUMBER,
        x_return_code           OUT NOCOPY VARCHAR2
) IS
	l_auc_header_id		pon_auction_headers_all.auction_header_id%TYPE;

	l_header_disp_pf	VARCHAR2(1);
	l_blanket		VARCHAR2(1);
	l_mas			VARCHAR2(1);
	l_full_qty		VARCHAR2(1);
	l_auc_closed		VARCHAR2(1);
	l_buyer_user		VARCHAR2(1);
	l_supplier_user		VARCHAR2(1);
	l_has_pe		VARCHAR2(1);
        l_attr_enabled_flag     VARCHAR2(1);
        l_req_enabled_flag      VARCHAR2(1);
        l_has_hdr_attr_flag     VARCHAR2(1);
	l_suffix		VARCHAR2(2);
    	l_progress_payment_type	pon_auction_headers_all.progress_payment_type%TYPE;
		l_price_precision pon_bid_headers.number_price_decimals%TYPE;
        l_price_tiers_indicator pon_auction_headers_all.PRICE_TIERS_INDICATOR%TYPE;
BEGIN

	SELECT sysdate + g_exp_days_offset,
		ah.auction_header_id,
		bh.display_price_factors_flag,
		decode(ah.contract_type, 'BLANKET', 'Y', 'CONTRACT', 'Y', 'N'),
		decode(ah.bid_ranking, 'MULTI_ATTRIBUTE_SCORING', 'Y', 'N'),
		decode(ah.full_quantity_bid_code, 'FULL_QTY_BIDS_REQD', 'Y', 'N'),
		decode(ah.auction_status, 'AUCTION_CLOSED', 'Y', 'N'),
                nvl(ah.line_attribute_enabled_flag, 'N'),
                nvl(ah.hdr_attribute_enabled_flag, 'N'),
                nvl(ah.has_hdr_attr_flag, 'N'),
		nvl(ah.progress_payment_type,'NONE'),
		bh.number_price_decimals,
		bh.surrog_bid_flag,
		decode(bh.surrog_bid_flag, 'Y', 'N', 'Y'),
		nvl(bh.display_price_factors_flag, 'N'),
                ah.PRICE_TIERS_INDICATOR
	INTO g_exp_date,
		l_auc_header_id,
		l_header_disp_pf,
		l_blanket,
		l_mas,
		l_full_qty,
		l_auc_closed,
                l_attr_enabled_flag,
                l_req_enabled_flag,
                l_has_hdr_attr_flag,
		l_progress_payment_type,
		l_price_precision,
		l_buyer_user,
		l_supplier_user,
		l_has_pe,
                l_price_tiers_indicator
	FROM pon_bid_headers bh, pon_auction_headers_all ah
	WHERE bh.bid_number = p_bid_number
		AND ah.auction_header_id = bh.auction_header_id;

        l_suffix := PON_LARGE_AUCTION_UTIL_PKG.get_doctype_suffix(l_auc_header_id);

	 -- Determine if there are any invalid lines or lines to be skipped
	remove_xml_skipped_lines
		(l_auc_header_id,
		p_batch_id,
		p_request_id,
		p_user_id,
		l_full_qty,
		l_buyer_user,
		l_suffix);

  	validate_xml(
       		p_batch_id,
       		l_auc_header_id,
    		p_bid_number,
    		p_request_id,
        	p_user_id,
                l_suffix,
    		l_has_pe,
                l_attr_enabled_flag,
                l_req_enabled_flag,
                l_has_hdr_attr_flag,
		l_progress_payment_type,
		l_blanket,
                l_price_tiers_indicator);


	-- Default certain fields from the auction side
	-- essentially nullify the price columns when not applicable -> this need not be done
	-- for XML as we will make all such fields read-only
	-- Note to Rohit: please verify
	default_from_auction
		(p_batch_id,
		l_auc_header_id,
		p_bid_number,
		l_full_qty,
		l_blanket,
		l_auc_closed);


	copy_interface_to_txn_tables
		(p_batch_id,
         l_auc_header_id,
		p_bid_number,
		p_user_id,
		l_header_disp_pf,
		l_blanket,
		l_mas,
		l_progress_payment_type,
		PON_BID_VALIDATIONS_PKG.g_xml_upload_mode,
		l_price_precision,
                l_price_tiers_indicator);


	-- Update auction currency columns for the current batch
	PON_RESPONSE_PVT.recalculate_auc_curr_prices(p_bid_number, 'N', p_batch_id);

	-- Update group amounts for the current batch
	-- NOTE: group amount is only calculated at the time of publish
	PON_RESPONSE_PVT.calculate_group_amounts(p_bid_number, l_supplier_user, 'N', p_batch_id);


        -- Validate the data once it has been copied to the transaction tables
        PON_BID_VALIDATIONS_PKG.validate_spreadsheet_upload
                (l_auc_header_id,
                p_bid_number,
                'BIDBYSPREADSHEET',
                PON_BID_VALIDATIONS_PKG.g_xml_upload_mode,
                p_user_id,
                p_batch_id,
                p_request_id,
                x_return_status,
                x_return_code);


END process_xml_spreadsheet_data;


END PON_RESPONSE_IMPORT_PKG;

/
