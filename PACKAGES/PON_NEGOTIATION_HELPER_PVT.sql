--------------------------------------------------------
--  DDL for Package PON_NEGOTIATION_HELPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PON_NEGOTIATION_HELPER_PVT" AUTHID CURRENT_USER AS
/* $Header: PONNEGHS.pls 120.11 2007/06/01 13:31:48 pchintap ship $ */

/*======================================================================
   PROCEDURE : get_search_min_disp_line_num
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. p_value - The value entered by the user for search
               3. x_min_disp_line_num - Out parameter to indicate at which
                  line to start displaying
   COMMENT   : This procedure is invoked when the user searches on the
               lines region with line number as the search criteria
               and greater than as the search condition.
               Given the value entered by the user (p_value) this
               procedure will return the disp_line_number above which
               all lines should be shown.
======================================================================*/

PROCEDURE get_search_min_disp_line_num (
  p_auction_header_id IN NUMBER,
  p_value IN NUMBER,
  x_min_disp_line_num OUT NOCOPY NUMBER);

/*======================================================================
   PROCEDURE : get_search_max_disp_line_num
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. p_value - The value entered by the user for search
               3. x_max_disp_line_num - Out parameter to indicate at which
                  line to stop displaying
   COMMENT   : This procedure is invoked when the user searches on the
               lines region with line number as the search criteria
               and less than as the search condition.
               Given the value entered by the user (p_value) this
               procedure will return the disp_line_number below which
               all lines should be shown.
======================================================================*/

PROCEDURE get_search_max_disp_line_num (
  p_auction_header_id IN NUMBER,
  p_value IN NUMBER,
  x_max_disp_line_num OUT NOCOPY NUMBER);

/*======================================================================
   PROCEDURE : get_auction_request_id
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. x_request_id - The reuqest id on the auction.
   COMMENT   : This procedure will return the value present in the
               REQUEST_ID column of PON_AUCTION_HEADERS_ALL table
======================================================================*/

PROCEDURE get_auction_request_id (
  p_auction_header_id IN NUMBER,
  x_request_id OUT NOCOPY NUMBER);

/*======================================================================
   PROCEDURE : has_fixed_amt_or_per_unit_pe
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. x_has_fixed_amt_or_per_unit_pe - return value - Y if there
                  are fixed amount or per unit price elements else N.
               3. x_result - return status.
               4. x_error_code - error code
               5. x_error_message - The actual error message
   COMMENT   :  This procedure will return Y if there are any
               fixed amount or per unit price elements
======================================================================*/

PROCEDURE has_fixed_amt_or_per_unit_pe(
  p_auction_header_id IN NUMBER,
  x_has_fixed_amt_or_per_unit_pe OUT NOCOPY VARCHAR2,
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2);

/*======================================================================
   PROCEDURE : has_goods_line_fixed_amount_pe
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. x_has_goods_line_fixed_amount_pe - return value - Y if there
                  are goods lines with fixed amt price elements
               3. x_result - return status.
               4. x_error_code - error code
               5. x_error_message - The actual error message
   COMMENT   : This procedure will return Y if there are any goods lines
               with fixed amount price elements
======================================================================*/

PROCEDURE has_goods_line_fixed_amount_pe(
  p_auction_header_id IN NUMBER,
  x_has_goods_line_fixed_amt_pe OUT NOCOPY VARCHAR2,
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2);

/*======================================================================
   PROCEDURE : has_items
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. x_has_items - return value Y if there
                  items else N.
               3. x_result - return status.
               4. x_error_code - error code
               5. x_error_message - The actual error message
   COMMENT   : This method returns Y if there are any items present
               in the negotiation. else it will return N
======================================================================*/

PROCEDURE has_items (
  p_auction_header_id IN NUMBER,
  x_has_items OUT NOCOPY VARCHAR2,
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2);

/*======================================================================
   PROCEDURE : get_number_of_lines
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. x_number_of_lines - Return value containing
                  the number of lines.
               3. x_result - return status.
               4. x_error_code - error code
               5. x_error_message - The actual error message
   COMMENT   : This procedure will return the number of lines in the
               negotiation.
======================================================================*/

PROCEDURE get_number_of_lines (
  p_auction_header_id IN NUMBER,
  x_number_of_lines OUT NOCOPY NUMBER,
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2);

/*======================================================================
   PROCEDURE : get_max_internal_and_doc_line_num
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. x_max_internal_line_num - The maximum internal line
                  number in all the rounds
               3. x_max_document_line_num - The maximum subline sequence
                  number in all the rounds
               4. x_result - return status.
               5. x_error_code - error code
               6. x_error_message - The actual error message
   COMMENT   : This procedure will return the maximum value of the
               LINE_NUMBER and SUB_LINE_SEQUENCE_NUMBER columns in all
               the rounds
======================================================================*/

PROCEDURE get_max_internal_and_doc_num (
  p_auction_header_id IN NUMBER,
  x_max_internal_line_num OUT NOCOPY NUMBER,
  x_max_document_line_num OUT NOCOPY NUMBER,
  x_max_disp_line_num OUT NOCOPY NUMBER,
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2);

/*======================================================================
   PROCEDURE : remove_score
   PARAMETERS: 1. x_result - return status.
               2. x_error_code - error code
               3. x_error_message - The actual error message
               4. p_auction_header_id - The auction header id
   COMMENT   : This procedure will remove the scoring information from
               the given negotiation.
======================================================================*/

PROCEDURE remove_score (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER);

/*======================================================================
   PROCEDURE : has_price_elements
   PARAMETERS: 1. x_result - return status.
               2. x_error_code - error code
               3. x_error_message - The actual error message
               4. p_auction_header_id - The auction header id
   COMMENT   : This procedure will return Y if there are price elements
               on the negotiation else it will return N
======================================================================*/

PROCEDURE has_price_elements (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  x_has_price_elements OUT NOCOPY VARCHAR2);

/*======================================================================
   PROCEDURE : has_supplier_price_elements
   PARAMETERS: 1. x_result - return status.
               2. x_error_code - error code
               3. x_error_message - The actual error message
               4. p_auction_header_id - The auction header id
   COMMENT   : This procedure will return Y if there are supplier price
               elements on the negotiation else it will return N
======================================================================*/

PROCEDURE has_supplier_price_elements (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  x_has_supplier_price_elements OUT NOCOPY VARCHAR2);

/*======================================================================
   PROCEDURE : has_buyer_price_elements
   PARAMETERS: 1. x_result - return status.
               2. x_error_code - error code
               3. x_error_message - The actual error message
               4. p_auction_header_id - The auction header id
   COMMENT   : This procedure will return Y if there are buyer price
               elements on the negotiation else it will return N
======================================================================*/

PROCEDURE has_buyer_price_elements (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  x_has_buyer_price_elements OUT NOCOPY VARCHAR2);

/*====================================================================================
   PROCEDURE : SYNC_PF_VALUES_BIDDING_PARTIES
   DESCRIPTION: Procedure to synchronize the price factor values due to modification
                in the supplier invited
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. p_line_number - The line_number of that line which is, or the
                                  price factors of which, are modified
               3. p_action - The task to be performed. The possible values it takes is
                            ADD_SUPPLIER => Add price factor values for a new supplier
                            DELETE_SUPPLIER => Delete the price factor values for a supplier
                                                who is deleted
               4. x_result - return status.
               5. x_error_code - error code
               6. x_error_message - The actual error message
  COMMENT    : This procedure will synchronise the price factor
               values when a supplier is added/deleted
====================================================================================*/

PROCEDURE SYNC_PF_VALUES_BIDDING_PARTIES(
                p_auction_header_id IN NUMBER,
                p_supplier_seq_num IN NUMBER,
                p_action IN VARCHAR2,
                x_result OUT NOCOPY  VARCHAR2,
                x_error_code OUT NOCOPY VARCHAR2,
                x_error_message OUT NOCOPY VARCHAR2);

/*====================================================================================
   PROCEDURE : SYNC_PF_VALUES_ITEM_PRICES
   DESCRIPTION: Procedure to synchronize the price factor values due to modification
                in the lines or their price factors
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. p_line_number - The line_number of that line which is, or the
                                  price factors of which, are modified
               3. p_add_pf - 'T' implies the new price factors have to be added
               4. p_del_pf - 'T' implies the deleted price factors have to be removed
               5. x_result - return status.
               6. x_error_code - error code
               7. x_error_message - The actual error message
  COMMENT    : This procedure will synchronise the price factor
               values table when the price factors of a line is added/deleted/modified
====================================================================================*/

PROCEDURE SYNC_PF_VALUES_ITEM_PRICES(
           p_auction_header_id IN NUMBER,
           p_line_number IN NUMBER,
           p_add_pf IN VARCHAR2,
           p_del_pf IN VARCHAR2,
           x_result OUT NOCOPY  VARCHAR2,
           x_error_code OUT NOCOPY VARCHAR2,
           x_error_message OUT NOCOPY VARCHAR2);

/*======================================================================
   PROCEDURE : delete_all_lines
   PARAMETERS: 1. x_result - return status.
               2. x_error_code - error code
               3. x_error_message - The actual error message
               4. p_auction_header_id - The auction header id
   COMMENT   : This procedure delete all the lines in the negotiation
               and also its children
======================================================================*/

PROCEDURE delete_all_lines (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER);

/*======================================================================
   PROCEDURE : delete_single_line
   PARAMETERS: 1. x_result - return status.
               2. x_error_code - error code
               3. x_error_message - The actual error message
               4. p_auction_header_id - The auction header id
               5. p_line_number - The line to be deleted
               6. p_group_type - The group type of the line to be
                  deleted.
               7. p_origination_code - The origination code for this line
               8. p_org_id - The org id for this line
               9. p_parent_line_number - The parent line number for
                   this line
               10. p_sub_line_sequence_number - The sub line sequence
                   number for this line
   COMMENT   : This procedure will delete the given line. If it is a lot
               or a group then all the lot line and group lines will
         also be deleted.
======================================================================*/

PROCEDURE delete_single_line (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_line_number IN NUMBER,
  p_group_type IN VARCHAR2,
  p_origination_code IN VARCHAR2,
  p_org_id IN NUMBER,
  p_parent_line_number IN NUMBER,
  p_sub_line_sequence_number IN NUMBER,
  x_number_of_lines_deleted IN OUT NOCOPY NUMBER);

/*======================================================================
   PROCEDURE : RENUMBER_LINES
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. p_min_disp_line_number_parent - The disp line number
                  of the minimum LINE/GROUP/LOT from where to correct
                  the sequences
               3. p_min_disp_line_number_child - The disp line number of
                  the minimum LOT_LINE/GROUP_LINE from where to correct
                  the sequences.
               4. p_min_child_parent_line_num - The parent line number
                  of the line given in step 3.
	       5. x_last_line_number - The sub_line_sequence of the last
	          row that is a lot/line/group.
   COMMENT   : This procedure will correct the sequence numbers -
               SUB_LINE_SEQUENCE_NUMBER, DISP_LINE_NUMBER and
               DOCUMENT_DISP_LINE_NUMBER
======================================================================*/

PROCEDURE RENUMBER_LINES (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  p_min_disp_line_number_parent IN NUMBER,
  p_min_disp_line_number_child IN NUMBER,
  p_min_child_parent_line_num IN NUMBER,
  x_last_line_number OUT NOCOPY NUMBER);

  /*======================================================================
   PROCEDURE : Delete_Payment_Attachments
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. p_curr_from_line_number - The starting line number- Needed in batching
               3. p_curr_to_line_number - The max line number- needed for batching

   COMMENT   : This procedure will delete the attachments for all the payments for lines in range
======================================================================*/
PROCEDURE Delete_Payment_Attachments (
  p_auction_header_id IN NUMBER,
  p_curr_from_line_number IN NUMBER,
  p_curr_to_line_number IN NUMBER
);


/*======================================================================
   PROCEDURE : get_srch_max_disp_line_numbers
   PARAMETERS: 1. p_curr_auction_header_id - The current auction header id
               2. p_prev_auction_header_id - The previous auction header id
               3. p_value - The value entered by the user for search
               4. x_curr_max_disp_line_num - Out parameter to indicate at which
                  line to stop displaying
               5. x_prev_max_disp_line_num - Out parameter to indicate at which
                  line to stop displaying
   COMMENT   : This procedure is invoked when the user searches on the
               lines region with line number as the search criteria
               and less than as the search condition.
               Given the value entered by the user (p_value) this
               procedure will return the disp_line_number below which
               all lines should be shown.
======================================================================*/

PROCEDURE get_srch_max_disp_line_numbers (
  p_curr_auction_header_id IN NUMBER,
  p_prev_auction_header_id IN NUMBER,
  p_value IN NUMBER,
  x_curr_max_disp_line_num OUT NOCOPY NUMBER,
  x_prev_max_disp_line_num OUT NOCOPY NUMBER
);


/*======================================================================
   PROCEDURE : get_srch_min_disp_line_numbers
   PARAMETERS: 1. p_curr_auction_header_id - The current auction header id
               2. p_prev_auction_header_id - The previous auction header id
               3. p_value - The value entered by the user for search
               4. x_curr_min_disp_line_num - Out parameter to indicate at which
                  line to start displaying for current auction
               5. x_prev_min_disp_line_num - Out parameter to indicate at which
                  line to start displaying for previous auction
   COMMENT   : This procedure is invoked when the user searches on the
               lines region with line number as the search criteria
               and greater than as the search condition.
               Given the value entered by the user (p_value) this
               procedure will return the disp_line_number above which
               all lines should be shown.
======================================================================*/

PROCEDURE get_srch_min_disp_line_numbers(
  p_curr_auction_header_id IN NUMBER,
  p_prev_auction_header_id IN NUMBER,
  p_value IN NUMBER,
  x_curr_min_disp_line_num OUT NOCOPY NUMBER,
  x_prev_min_disp_line_num OUT NOCOPY NUMBER
);


/*======================================================================
   PROCEDURE : DELETE_DISCUSSIONS
   PARAMETERS: 1. x_result - return status.
               2. x_error_code - error code
               3. x_error_message - The actual error message
               4. p_auction_header_id - The auction header id
   COMMENT   : This procedure deletes all the discussions  in the negotiation
               and also its children
======================================================================*/

PROCEDURE DELETE_DISCUSSIONS (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER);

/*======================================================================
   PROCEDURE : UPDATE_STAG_LINES_CLOSE_DATES
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. p_first_line_close_date - The staggered closing interval
               3. p_staggered_closing_interval - The auction header id
               4. x_last_line_close_date - The close date of the last line
               5. x_result - return status.
               6. x_error_code - error code
               7. x_error_message - The actual error message
   COMMENT   : This procedure updates the close dates of the lines when
               the draft negotiation is saved
======================================================================*/

	PROCEDURE UPDATE_STAG_LINES_CLOSE_DATES(
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
	p_auction_header_id in Number,
	p_first_line_close_date in date,
	p_staggered_closing_interval in number,
  p_start_disp_line_number in number,
  x_last_line_close_date out nocopy date);

/*======================================================================
 * FUNCTION :  COUNT_LINES_LOTS_GROUPS    PUBLIC
 * PARAMETERS:
 *    p_auction_header_id         IN      header id of the auction
 *
 * COMMENT   : returns the count of LINES, LOTS and GROUPS in the
 *  negotiation
 *======================================================================*/

FUNCTION COUNT_LINES_LOTS_GROUPS (p_auction_header_id  IN NUMBER) RETURN NUMBER;

/*======================================================================
 * FUNCTION :  GET_PO_AUTHORIZATION_STATUS    PUBLIC
 * PARAMETERS:
 * p_document_id          IN      po header id
 * p_document_type        IN      the PO document type ('PO'/'PA')
 * p_document_subtype     IN      PO subdoctype id (null)
 *
 * COMMENT   : returns the authorization status of PO
 *
 *======================================================================*/

FUNCTION GET_PO_AUTHORIZATION_STATUS (
  p_document_id          IN      VARCHAR2 ,
  p_document_type        IN      VARCHAR2 ,
  p_document_subtype     IN      VARCHAR2
) RETURN VARCHAR2;

/*======================================================================
 * PROCEDURE : HAS_PRICE_TIERS
 * PARAMETERS:  1. x_result - return status.
 *              2. x_error_code - error code
 *              3. x_error_message - The actual error message
 *              4. p_auction_header_id - The auction header id
 *   	        5. x_has_price_tiers - flag to indicate if negotiation has price tiers or not
 *  COMMENT   : It takes auction header id as the in parameter and returns Y if there is a line with price
 *              tier, for this auction,. If there is no such line it returns N.
 *======================================================================*/

PROCEDURE HAS_PRICE_TIERS (
	  x_result OUT NOCOPY VARCHAR2,
	  x_error_code OUT NOCOPY VARCHAR2,
	  x_error_message OUT NOCOPY VARCHAR2,
	  p_auction_header_id IN NUMBER,
	  x_has_price_tiers OUT NOCOPY VARCHAR2
	) ;

/*======================================================================
 * PROCEDURE : HANDLE_CHANGE_PRICE_TIERS
 * PARAMETERS:  1. x_result - return status.
 *              2. x_error_code - error code
 *              3. x_error_message - The actual error message
 *              4. p_auction_header_id - The auction header id
 *              5. p_delete_price_tiers -- Flag to indicate if price tiers to be removed or not
 * COMMENT   : This methods deletes all the lines in the DB table PON_AUCTION_SHIPMENTS_ALL,
 *	            for the given auction header id, sets the modify falg for new round and amendments
 *                 and sets the default price break settings.
 *======================================================================*/

PROCEDURE HANDLE_CHANGE_PRICE_TIERS (
	  x_result OUT NOCOPY VARCHAR2,
	  x_error_code OUT NOCOPY VARCHAR2,
	  x_error_message OUT NOCOPY VARCHAR2,
	  p_auction_header_id IN NUMBER,
          p_delete_price_tiers IN VARCHAR2
	);


--Bug 6074506
/*======================================================================
 * FUNCTION :  GET_ABBR_DOC_TYPE_GRP_NAME    PUBLIC
 * PARAMETERS:
 *    p_doctype_id         IN      document type id of the auction
 *
 * COMMENT   : returns the document froup name in English language
 *
 *======================================================================*/

FUNCTION GET_ABBR_DOC_TYPE_GRP_NAME (p_doctype_id  IN NUMBER) RETURN VARCHAR2;

END PON_NEGOTIATION_HELPER_PVT;

/
