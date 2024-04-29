--------------------------------------------------------
--  DDL for Package Body PON_NEGOTIATION_HELPER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PON_NEGOTIATION_HELPER_PVT" AS
/* $Header: PONNEGHB.pls 120.30.12010000.2 2009/11/19 01:17:27 huiwan ship $ */

g_module_prefix         CONSTANT VARCHAR2(50) := 'pon.plsql.PON_NEGOTIATION_HELPER_PVT.';

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
  x_min_disp_line_num OUT NOCOPY NUMBER
) IS
BEGIN

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SEARCH_MIN_DISP_LINE_NUM',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.GET_SEARCH_MIN_DISP_LINE_NUM '
                  || ', p_auction_header_id = ' || p_auction_header_id
                  || ', p_value = ' || p_value);
  END IF;

  --Retrieve the minimum disp_line_number of all the LOT/GROUP/LINES
  --that have SUB_LINE_SEQUENCE_NUMBER > p_value

  SELECT MIN(disp_line_number)
  INTO x_min_disp_line_num
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID = p_auction_header_id
  AND GROUP_TYPE IN ('LOT', 'GROUP', 'LINE')
  AND SUB_LINE_SEQUENCE_NUMBER > p_value;

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SEARCH_MIN_DISP_LINE_NUM',
      message  => 'Leaving PON_NEGOTIATION_HELPER_PVT.GET_SEARCH_MIN_DISP_LINE_NUM'
                  || 'x_min_disp_line_num = ' || x_min_disp_line_num);
  END IF;

END GET_SEARCH_MIN_DISP_LINE_NUM;

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

PROCEDURE GET_SEARCH_MAX_DISP_LINE_NUM (
  p_auction_header_id IN NUMBER,
  p_value IN NUMBER,
  x_max_disp_line_num OUT NOCOPY NUMBER
) IS

l_line_number PON_AUCTION_ITEM_PRICES_ALL.LINE_NUMBER%TYPE;
l_group_type PON_AUCTION_ITEM_PRICES_ALL.GROUP_TYPE%TYPE;
BEGIN

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SEARCH_MAX_DISP_LINE_NUM',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.GET_SEARCH_MAX_DISP_LINE_NUM '
                  || ', p_auction_header_id = ' || p_auction_header_id
                  || ', p_value = ' || p_value);
  END IF;

  --Retrieve the maximum disp_line_number of all the LOT/GROUP/LINES
  --that have SUB_LINE_SEQUENCE_NUMBER < p_value

  SELECT MAX(DISP_LINE_NUMBER)
  INTO x_max_disp_line_num
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID = p_auction_header_id
  AND GROUP_TYPE IN ('LOT', 'LINE', 'GROUP')
  AND SUB_LINE_SEQUENCE_NUMBER < p_value;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SEARCH_MAX_DISP_LINE_NUM',
      message  => 'After the first query x_max_disp_line_num = ' ||
                  x_max_disp_line_num);
  END IF;

  IF (x_max_disp_line_num IS NULL) THEN

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'GET_SEARCH_MAX_DISP_LINE_NUM',
        message  => 'There are no lines so returning null');
    END IF;

    RETURN;
  END IF;

  SELECT GROUP_TYPE, LINE_NUMBER
  INTO l_group_type, l_line_number
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID = p_auction_header_id
  AND DISP_LINE_NUMBER = x_max_disp_line_num;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SEARCH_MAX_DISP_LINE_NUM',
      message  => 'l_group_type = ' || l_group_type
                  || ', l_line_number = ' || l_line_number);
  END IF;

  --If the selected line is a LOT/GROUP then get the maximum
  --disp_line_number within that LOT/GROUP

  IF (l_group_type <> 'LINE') THEN
    SELECT NVL (MAX(DISP_LINE_NUMBER), x_max_disp_line_num)
    INTO x_max_disp_line_num
    FROM PON_AUCTION_ITEM_PRICES_ALL
    WHERE AUCTION_HEADER_ID = p_auction_header_id
    AND PARENT_LINE_NUMBER = l_line_number;
  END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SEARCH_MAX_DISP_LINE_NUM',
      message  => 'Leaving PON_NEGOTIATION_HELPER_PVT.GET_AUCTION_REQUEST_ID '
                  || ', x_max_disp_line_num = ' || x_max_disp_line_num);
  END IF;

END GET_SEARCH_MAX_DISP_LINE_NUM;

PROCEDURE GET_AUCTION_REQUEST_ID (
  p_auction_header_id IN NUMBER,
  x_request_id OUT NOCOPY NUMBER
) IS
BEGIN

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_AUCTION_REQUEST_ID',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.GET_AUCTION_REQUEST_ID '
                  || ', p_auction_header_id = ' || p_auction_header_id);
  END IF;

  SELECT REQUEST_ID
  INTO x_request_id
  FROM PON_AUCTION_HEADERS_ALL
  WHERE AUCTION_HEADER_ID = p_auction_header_id;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_AUCTION_REQUEST_ID',
      message  => 'Leaving PON_NEGOTIATION_HELPER_PVT.GET_AUCTION_REQUEST_ID '
                  || ', x_request_id = ' || x_request_id);
  END IF;

EXCEPTION WHEN NO_DATA_FOUND THEN
  x_request_id := NULL;

  IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_exception,
      module  =>  g_module_prefix || 'GET_AUCTION_REQUEST_ID',
      message  => 'Exception in PON_NEGOTIATION_HELPER_PVT.GET_AUCTION_REQUEST_ID '
                  || 'errnum = ' || SQLCODE || ', errmsg = ' || SUBSTR (SQLERRM, 1, 200));
  END IF;

END GET_AUCTION_REQUEST_ID;

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

PROCEDURE HAS_FIXED_AMT_OR_PER_UNIT_PE(
  p_auction_header_id IN NUMBER,
  x_has_fixed_amt_or_per_unit_pe OUT NOCOPY VARCHAR2,
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2
) IS

l_line_number NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  => g_module_prefix || 'HAS_FIXED_AMT_OR_PER_UNIT_PE',
      message => 'Entered procedure with p_auction_header_id = ' || p_auction_header_id);
  END IF;

  x_result := FND_API.G_RET_STS_SUCCESS;

  SELECT
    LINE_NUMBER
  INTO
    l_line_number
  FROM
    PON_PRICE_ELEMENTS
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id AND
    (PRICING_BASIS = 'FIXED_AMOUNT' OR PRICING_BASIS = 'PER_UNIT') AND
    ROWNUM = 1;

  x_has_fixed_amt_or_per_unit_pe := 'Y';

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  => g_module_prefix || 'HAS_FIXED_AMT_OR_PER_UNIT_PE',
      message => 'Returning x_has_fixed_amt_or_per_unit_pe = ' || x_has_fixed_amt_or_per_unit_pe);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN --{
    x_has_fixed_amt_or_per_unit_pe := 'N';

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module  => g_module_prefix || 'HAS_FIXED_AMT_OR_PER_UNIT_PE',
        message => 'Returning x_has_fixed_amt_or_per_unit_pe = ' || x_has_fixed_amt_or_per_unit_pe);
    END IF;

  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || 'HAS_FIXED_AMT_OR_PER_UNIT_PE',
        message => 'Exception occured while checking for fixed amount or per unit price elements'
            || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
    END IF;

END HAS_FIXED_AMT_OR_PER_UNIT_PE;

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

PROCEDURE HAS_GOODS_LINE_FIXED_AMOUNT_PE(
  p_auction_header_id IN NUMBER,
  x_has_goods_line_fixed_amt_pe OUT NOCOPY VARCHAR2,
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2
) IS

l_line_number NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  => g_module_prefix || 'HAS_GOODS_LINE_FIXED_AMOUNT_PE',
      message => 'Entered procedure with p_auction_header_id = ' || p_auction_header_id);
  END IF;

  x_result := FND_API.G_RET_STS_SUCCESS;

  SELECT
    PAIP.LINE_NUMBER
  INTO
    l_line_number
  FROM
    PON_AUCTION_ITEM_PRICES_ALL PAIP,
    PON_PRICE_ELEMENTS PPE
  WHERE
    PAIP.AUCTION_HEADER_ID = p_auction_header_id AND
    PPE.AUCTION_HEADER_ID = p_auction_header_id AND
    PAIP.LINE_NUMBER = PPE.LINE_NUMBER AND
    PAIP.PURCHASE_BASIS = 'GOODS' AND
    PPE.PRICING_BASIS = 'FIXED_AMOUNT' AND
    ROWNUM = 1;

  x_has_goods_line_fixed_amt_pe := 'Y';

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  => g_module_prefix || 'HAS_GOODS_LINE_FIXED_AMOUNT_PE',
      message => 'Returning x_has_goods_line_fixed_amt_pe = ' || x_has_goods_line_fixed_amt_pe);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN --{
    x_has_goods_line_fixed_amt_pe := 'N';

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module  => g_module_prefix || 'HAS_GOODS_LINE_FIXED_AMOUNT_PE',
        message => 'Returning x_has_goods_line_fixed_amt_pe = ' || x_has_goods_line_fixed_amt_pe);
    END IF;

  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || 'HAS_GOODS_LINE_FIXED_AMOUNT_PE',
        message => 'Exception occured while checking for goods lines with fixed amount price elements'
            || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
    END IF;

END HAS_GOODS_LINE_FIXED_AMOUNT_PE;

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

PROCEDURE GET_MAX_INTERNAL_AND_DOC_NUM (
  p_auction_header_id IN NUMBER,
  x_max_internal_line_num OUT NOCOPY NUMBER,
  x_max_document_line_num OUT NOCOPY NUMBER,
  x_max_disp_line_num OUT NOCOPY NUMBER,
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2
) IS

l_number_of_lines NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  => g_module_prefix || 'GET_MAX_INTERNAL_AND_DOC_NUM',
      message => 'Entered procedure with p_auction_header_id = ' || p_auction_header_id);
  END IF;

  x_result := FND_API.G_RET_STS_SUCCESS;


  --We are not performing an outer join between header and lines here as it might
  --be costly in case of a super large negotiation
  x_max_disp_line_num := 0;

  SELECT
    NVL (number_of_lines, 0),
    NVL (max_internal_line_num, 0),
    NVL (max_document_line_num, 0)
  INTO
    l_number_of_lines,
    x_max_internal_line_num,
    x_max_document_line_num
  FROM
    pon_auction_headers_all
  WHERE
    auction_header_id = p_auction_header_id;

  IF (l_number_of_lines > 0) THEN

    SELECT
      GREATEST (x_max_internal_line_num, NVL(MAX(items.line_number),0)),
      GREATEST (x_max_document_line_num, NVL(MAX(DECODE (items.group_type, 'LOT_LINE', 0, 'GROUP_LINE', 0, items.sub_line_sequence_number)),0)),
      NVL (MAX(items.disp_line_number), 0)
    INTO
      x_max_internal_line_num,
      x_max_document_line_num,
      x_max_disp_line_num
    FROM
      pon_auction_item_prices_all items
    WHERE
      items.auction_header_id = p_auction_header_id;

  END IF;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  => g_module_prefix || 'GET_MAX_INTERNAL_AND_DOC_NUM',
      message => 'Returning x_max_internal_line_num = ' || x_max_internal_line_num ||
                  ', x_max_document_line_num = ' || x_max_document_line_num ||
                  ', x_max_disp_line_num = ' || x_max_disp_line_num);
  END IF;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    x_max_disp_line_num := 0;
    x_max_document_line_num := 0;
    x_max_internal_line_num := 0;

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module  => g_module_prefix || 'GET_MAX_INTERNAL_AND_DOC_NUM',
        message => 'Returning x_max_internal_line_num = ' || x_max_internal_line_num ||
                    ', x_max_document_line_num = ' || x_max_document_line_num ||
                    ', x_max_disp_line_num = ' || x_max_disp_line_num);
    END IF;
  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || 'GET_MAX_INTERNAL_AND_DOC_NUM',
        message => 'Exception occured while getting the sequences'
            || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
    END IF;
END GET_MAX_INTERNAL_AND_DOC_NUM;

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

PROCEDURE GET_NUMBER_OF_LINES (
  p_auction_header_id IN NUMBER,
  x_number_of_lines OUT NOCOPY NUMBER,
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2
) IS
BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  => g_module_prefix || 'GET_NUMBER_OF_LINES',
      message => 'Entered procedure with p_auction_header_id = ' || p_auction_header_id);
  END IF;

  x_result := FND_API.G_RET_STS_SUCCESS;

  SELECT
    COUNT(LINE_NUMBER)
  INTO
    x_number_of_lines
  FROM
    PON_AUCTION_ITEM_PRICES_ALL
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id;

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  => g_module_prefix || 'GET_NUMBER_OF_LINES',
      message => 'Returning x_number_of_lines = ' || x_number_of_lines);
  END IF;

EXCEPTION WHEN OTHERS THEN
  x_result := FND_API.G_RET_STS_UNEXP_ERROR;
  x_error_code := SQLCODE;
  x_error_message := SUBSTR(SQLERRM, 1, 100);

  IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_exception,
      module  => g_module_prefix || 'GET_NUMBER_OF_LINES',
      message => 'Exception occured while getting the number of lines'
          || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
  END IF;

END GET_NUMBER_OF_LINES;

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

PROCEDURE HAS_ITEMS (
  p_auction_header_id IN NUMBER,
  x_has_items OUT NOCOPY VARCHAR2,
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2
) IS

l_line_number NUMBER;
BEGIN

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  => g_module_prefix || 'HAS_ITEMS',
      message => 'Entered procedure with p_auction_header_id = ' || p_auction_header_id);
  END IF;

  x_result := FND_API.G_RET_STS_SUCCESS;

  SELECT
    LINE_NUMBER
  INTO
    l_line_number
  FROM
    PON_AUCTION_ITEM_PRICES_ALL
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id AND
    ROWNUM = 1;

  x_has_items := 'Y';

  IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module  => g_module_prefix || 'HAS_ITEMS',
      message => 'Returning x_has_items = ' || x_has_items);
  END IF;
EXCEPTION
  WHEN NO_DATA_FOUND THEN --{

    x_has_items := 'N';

    IF (FND_LOG.LEVEL_STATEMENT >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module  => g_module_prefix || 'HAS_ITEMS',
        message => 'Returning x_has_items = ' || x_has_items);
    END IF;

  WHEN OTHERS THEN
    x_result := FND_API.G_RET_STS_UNEXP_ERROR;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.LEVEL_EXCEPTION >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module  => g_module_prefix || 'HAS_ITEMS',
        message => 'Exception occured while checking if items are present'
            || ' Error Number :' || SQLCODE || ' Exception Message :' || SUBSTR(SQLERRM, 1, 200) );
    END IF;
END HAS_ITEMS;

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
  p_auction_header_id IN NUMBER
) IS

l_module_name VARCHAR2 (30);

l_max_line_number NUMBER;
l_batch_size NUMBER;

l_batch_start NUMBER;
l_batch_end NUMBER;

BEGIN

  l_module_name := 'remove_score';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name ||
                 'p_auction_header_id = ' || p_auction_header_id);
  END IF;

  SELECT MAX(LINE_NUMBER)
  INTO l_max_line_number
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID=p_auction_header_id;

  -- Get the batch size
  l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;

  -- Draft with no lines, or RFI,CPA with no lines we need to skip batching
  -- its build into the loop logic but just to be explicit about this condition

  IF (l_max_line_number > 0) THEN --{

    -- Define the initial batch range (line numbers are indexed from 1)
    l_batch_start := 1;

    IF (l_max_line_number <= l_batch_size) THEN
        l_batch_end := l_max_line_number;
    ELSE
        l_batch_end := l_batch_size;
    END IF;

    WHILE (l_batch_start <= l_max_line_number) LOOP

      -- Delete the entries from the attribute scores table for this auction
      DELETE FROM
        pon_attribute_scores
      WHERE
        auction_header_id = p_auction_header_id AND
        line_number >= l_batch_start AND
        line_number <= l_batch_end;

      -- Delete the special attributes (quantity and need by date)
      DELETE FROM
        pon_auction_attributes
      WHERE
        auction_header_id = p_auction_header_id AND
        sequence_number < 0 AND
        line_number >= l_batch_start AND
        line_number <= l_batch_end;

      -- Set the scoring type as null and the weight as null for all the attributes
      UPDATE
        pon_auction_attributes
      SET
        scoring_type = 'NONE',
        weight = 0,
        last_update_date = sysdate,
        last_updated_by = FND_GLOBAL.user_id
      WHERE
        auction_header_id = p_auction_header_id AND
        line_number >= l_batch_start AND
        line_number <= l_batch_end;
      -- Find the new batch range
      l_batch_start := l_batch_end + 1;
      IF (l_batch_end + l_batch_size > l_max_line_number) THEN
          l_batch_end := l_max_line_number;
      ELSE
          l_batch_end := l_batch_end + l_batch_size;
      END IF;

      -- Issue a commit to push in all changes
      COMMIT;
    END LOOP;

  END IF; --}

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;

END remove_score;

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
  x_has_price_elements OUT NOCOPY VARCHAR2
) IS

l_module_name VARCHAR2 (30);
BEGIN

  l_module_name := 'has_price_elements';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name ||
                 ' p_auction_header_id = ' || p_auction_header_id);
  END IF;

  BEGIN

    SELECT
      'Y'
    INTO
      x_has_price_elements
    FROM
      pon_price_elements
    WHERE
      auction_header_id = p_auction_header_id AND
      rownum = 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_has_price_elements := 'N';
  END;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name ||
                 ' x_has_price_elements = ' || x_has_price_elements);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;

END has_price_elements;

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
  x_has_supplier_price_elements OUT NOCOPY VARCHAR2
) IS

l_module_name VARCHAR2 (30);
BEGIN

  l_module_name := 'has_supplier_price_elements';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name ||
                 ' p_auction_header_id = ' || p_auction_header_id);
  END IF;

  BEGIN

    SELECT
      'Y'
    INTO
      x_has_supplier_price_elements
    FROM
      pon_price_elements
    WHERE
      auction_header_id = p_auction_header_id AND
      pf_type = 'SUPPLIER' AND
      rownum = 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_has_supplier_price_elements := 'N';
  END;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name ||
                 ' x_has_supplier_price_elements = ' || x_has_supplier_price_elements);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;

END has_supplier_price_elements;

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
  x_has_buyer_price_elements OUT NOCOPY VARCHAR2
) IS

l_module_name VARCHAR2 (30);
BEGIN

  l_module_name := 'has_buyer_price_elements';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name ||
                 ' p_auction_header_id = ' || p_auction_header_id);
  END IF;

  BEGIN

    SELECT
      'Y'
    INTO
      x_has_buyer_price_elements
    FROM
      pon_price_elements
    WHERE
      auction_header_id = p_auction_header_id AND
      pf_type = 'BUYER' AND
      rownum = 1;

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      x_has_buyer_price_elements := 'N';
  END;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name ||
                 ' x_has_buyer_price_elements = ' || x_has_buyer_price_elements);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;

END has_buyer_price_elements;

--The procedures for synchrinization of price factor values for large auction
--start here
/*====================================================================================
   PROCEDURE : SYNC_PF_VALUES_ITEM_PRICES
   DESCRIPTION: Procedure to synchronize the price factor values due to modification
                in the lines or their price factors
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. p_line_number - The line_number of that line which is, or the
                                  price factors of which, are modified.
                                  This parameter is not required in case a line is
                                  being deleted. This method can be called once
                                  after a set of lines have been deleted and it will do
                                  the sync for all.
               3. p_add_pf - 'Y' implies the new price factors have to be added
                                 else it is 'N'
               4. p_del_pf - 'Y' implies the deleted price factors have to be removed
                                 else it is 'N'
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
           x_error_message OUT NOCOPY VARCHAR2)
is
l_module_name VARCHAR2 (30);
BEGIN
        l_module_name := 'SYNC_PF_VALUES_ITEM_PRICES';
        x_result := FND_API.G_RET_STS_SUCCESS;
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module => g_module_prefix || l_module_name,
                message => 'Entered the procedure; p_auction_header_id : '||p_auction_header_id ||
                                                 ' p_line_number : '||p_line_number||
                                                 ' p_add_pf : '||p_add_pf||
                                                 ' p_del_pf : '||p_del_pf
                );
        END IF;

   if p_add_pf = 'Y' then

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string (log_level => FND_LOG.level_statement,
                        module => g_module_prefix || l_module_name,
                        message => 'Inserting newly added/modified price factors...'
                        );
                END IF;

                insert into PON_LARGE_NEG_PF_VALUES (auction_header_id,price_element_type_id,pricing_basis,
                                         supplier_seq_number,value,creation_date,created_by,last_update_date,last_updated_by,last_update_login)
                                         select distinct PPE.auction_header_id,PPE.price_element_type_id,PPE.pricing_basis,
                                         PBP.sequence,null,sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,fnd_global.login_id
                                         from
                                         PON_PRICE_ELEMENTS PPE, PON_BIDDING_PARTIES PBP
                                         where
                                         PPE.auction_header_id = p_auction_header_id and
                                         PBP.auction_header_id = p_auction_header_id and
                                         PPE.line_number = p_line_number and
                                         PPE.pf_type = 'BUYER' and
                                         not exists (
                                         select pf_values.price_element_type_id,pf_values.pricing_basis
                                         from
                                         PON_LARGE_NEG_PF_VALUES pf_values
                                         where auction_header_id = p_auction_header_id
                                         and PPE.price_element_type_id = pf_values.price_element_type_id
                                         and PPE.pricing_basis = pf_values.pricing_basis
                                         and rownum = 1);
   end if;

   if p_del_pf = 'Y' then

                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string (log_level => FND_LOG.level_statement,
                        module => g_module_prefix || l_module_name,
                        message => 'Removing the deleted/modified price factors...'
                        );
                END IF;

    delete from PON_LARGE_NEG_PF_VALUES pf_values
    where
    auction_header_id = p_auction_header_id and
                not exists (
                select PPE.price_element_type_id,PPE.pricing_basis
                from
                PON_PRICE_ELEMENTS PPE
                where auction_header_id = p_auction_header_id
                and PPE.price_element_type_id = pf_values.price_element_type_id
                and PPE.pricing_basis = pf_values.pricing_basis
                and PPE.pf_type = 'BUYER'
                and rownum = 1);

        end if;
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module => g_module_prefix || l_module_name,
                message => 'Returning from the procedure with status : '||x_result
                );
        END IF;

EXCEPTION
        WHEN OTHERS THEN
                x_result := FND_API.g_ret_sts_unexp_error;
                x_error_code := SQLCODE;
                x_error_message := SUBSTR(SQLERRM, 1, 100);

                IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string (log_level => FND_LOG.level_exception,
                        module => g_module_prefix || l_module_name,
                        message => 'Unexpected exception occured error_code = ' ||
                                  x_error_code || ', error_message = ' || x_error_message);
                END IF;

END SYNC_PF_VALUES_ITEM_PRICES;

/*====================================================================================
   PROCEDURE : SYNC_PF_VALUES_BIDDING_PARTIES
   DESCRIPTION: Procedure to synchronize the price factor values due to modification
                in the supplier invited
   PARAMETERS: 1. p_auction_header_id - The auction header id
               2. p_supplier_seq_num - The sequence_number of the supplier who
                                      is added
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
                x_error_message OUT NOCOPY VARCHAR2)
is
        l_supplier_seq_num  NUMBER := null;
        l_module_name VARCHAR2 (30);
        l_supplier_exists VARCHAR2(1);
BEGIN
        l_module_name := 'SYNC_PF_VALUES_BIDDING_PARTIES';
        x_result := FND_API.G_RET_STS_SUCCESS;
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module => g_module_prefix || l_module_name,
                message => 'Entered the procedure ; p_auction_header_id : '||p_auction_header_id ||
                                                 ' p_line_number : '||p_supplier_seq_num||
                                                 ' p_action : '||p_action
                );
        END IF;

   if p_action = 'ADD_SUPPLIER' then
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string (log_level => FND_LOG.level_statement,
                        module => g_module_prefix || l_module_name,
                        message => 'Adding price factors for the new supplier with sequence number: '||p_supplier_seq_num
                        );
                END IF;

                --Please be CAREFUL here
                --In auto create the rows in PON_LARGE_NEG_PF_VALUES will get inserted by
                --SYNC_PF_VALUES_ITEM_PRICES (via the beforeCommit of AuctionItemPricesAllVO
                --So check here if the rows for this supplier sequence number exist. If yes,
                --then return with Success. We can be sure that if a single record for the
                --supplier exists, then all the distinct price factor and pricing basis
                --combinations exist for that supplier
                BEGIN
                SELECT 'Y'
                INTO l_supplier_exists
                FROM pon_large_neg_pf_values
                WHERE auction_header_id = p_auction_header_id and supplier_seq_number = p_supplier_seq_num and rownum = 1;
                EXCEPTION
                when NO_DATA_FOUND then
                    l_supplier_exists := 'N';
                END;


                IF (l_supplier_exists = 'Y') THEN
                    RETURN;
                END IF;

                BEGIN
                        select supplier_seq_number into l_supplier_seq_num from PON_LARGE_NEG_PF_VALUES
                        where auction_header_id = p_auction_header_id
                        and rownum = 1;
                EXCEPTION
                        when NO_DATA_FOUND then
                                l_supplier_seq_num := null;
                END;

                 if l_supplier_seq_num >= 0 then

                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                                FND_LOG.string (log_level => FND_LOG.level_statement,
                                module => g_module_prefix || l_module_name,
                                message => 'adding the price factors with the help of PON_LARGE_NEG_PF_VALUES table'
                                );
                        END IF;

                         insert into PON_LARGE_NEG_PF_VALUES (auction_header_id,price_element_type_id,pricing_basis,
                                                 supplier_seq_number,value,creation_date,created_by,last_update_date,last_updated_by,last_update_login)
                                                 select auction_header_id,price_element_type_id,pricing_basis,
                                                 p_supplier_seq_num,null,sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,fnd_global.login_id
                                                 from
                                                 PON_LARGE_NEG_PF_VALUES
                                                 where
                                                 auction_header_id = p_auction_header_id and
                                                 supplier_seq_number = l_supplier_seq_num;
                 elsif l_supplier_seq_num is null then

                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                                FND_LOG.string (log_level => FND_LOG.level_statement,
                                module => g_module_prefix || l_module_name,
                                message => 'adding the price factors with the help of PON_PRICE_ELEMENTS'
                                );
                        END IF;

                         insert into PON_LARGE_NEG_PF_VALUES (auction_header_id,price_element_type_id,pricing_basis,
                                                 supplier_seq_number,value,creation_date,created_by,last_update_date,last_updated_by,last_update_login)
                                                 select distinct auction_header_id,price_element_type_id,pricing_basis,
                                                 p_supplier_seq_num,null,sysdate,fnd_global.user_id,sysdate,fnd_global.user_id,fnd_global.login_id
                                                 from
                                                 PON_PRICE_ELEMENTS
                                                 where
                                                 auction_header_id = p_auction_header_id and
                                                 pf_type = 'BUYER';

                 else
                        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                                FND_LOG.string (log_level => FND_LOG.level_statement,
                                module => g_module_prefix || l_module_name,
                                message => 'Addition of price factor values failed'
                                );
                        END IF;

                 end if;
   elsif p_action = 'DELETE_SUPPLIER' then
                IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                        FND_LOG.string (log_level => FND_LOG.level_statement,
                        module => g_module_prefix || l_module_name,
                        message => 'deleting price factors for the deleted supplier with sequence number: '||p_supplier_seq_num
                        );
                END IF;

     delete from PON_LARGE_NEG_PF_VALUES
     where
     auction_header_id = p_auction_header_id AND
     supplier_seq_number = p_supplier_seq_num;
   end if;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
                FND_LOG.string (log_level => FND_LOG.level_statement,
                module => g_module_prefix || l_module_name,
                message => 'Exitting with return status of  ' ||x_result
                );
        END IF;

        EXCEPTION
                when OTHERS then
                        x_error_code := SQLCODE;
                        x_error_message := substr(SQLERRM,1,200);
                        x_result := FND_API.G_RET_STS_UNEXP_ERROR;
                        IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
                                FND_LOG.string (log_level => FND_LOG.level_exception,
                                module => g_module_prefix || l_module_name,
                                message => 'Exception in processing auction ' || p_auction_header_id
                                );
                        END IF;

END SYNC_PF_VALUES_BIDDING_PARTIES;

--The procedures for synchrinization of price factor values for large auction
--end here

--Complex work
--This procedure will delete the attachments for all the payments for lines in range
PROCEDURE Delete_Payment_Attachments (
  p_auction_header_id IN NUMBER,
  p_curr_from_line_number IN NUMBER,
  p_curr_to_line_number IN NUMBER
) IS

l_module_name VARCHAR2 (30);

CURSOR delete_attachments IS
	SELECT distinct (TO_NUMBER(pk2_value)) line_number
        FROM   FND_ATTACHED_DOCUMENTS fnd
    WHERE
           fnd.pk1_value = p_auction_header_id
	 AND   fnd.pk2_value between  to_char(p_curr_from_line_number) and to_char(p_curr_to_line_number)
         AND   fnd.entity_name = 'PON_AUC_PAYMENTS_SHIPMENTS';
BEGIN

  l_module_name := 'Delete_Payment_Attachments';

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name);
  END IF;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'before Call FND_ATTACHED_DOCUMENTS2_PKG.DELETE_ATTACHMENTS = ' || l_module_name);
  END IF;

   -- delete attachments for the payments if any
    FOR delete_attachments_rec IN delete_attachments LOOP
      IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_procedure,
           module => g_module_prefix || l_module_name,
           message => 'Deleting fnd attachments for all the payments for line ' ||delete_attachments_rec.line_number||'='|| l_module_name);
       END IF;
      --delete the attachments for a payment
       FND_ATTACHED_DOCUMENTS2_PKG.DELETE_ATTACHMENTS
        (x_entity_name  => 'PON_AUC_PAYMENTS_SHIPMENTS',
         x_pk1_value => p_auction_header_id,
         x_pk2_value => delete_attachments_rec.line_number,
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

END Delete_Payment_Attachments;

/*======================================================================
   PROCEDURE : delete_all_lines
   PARAMETERS: 1. x_result - return status.
               2. x_error_code - error code
               3. x_error_message - The actual error message
               4. p_auction_header_id - The auction header id
   COMMENT   : This procedure deletes all the lines in the negotiation
               and also its children
======================================================================*/

PROCEDURE delete_all_lines (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER
) IS

--Cursor to find out lines that have attachments
CURSOR lines_with_attachements IS
  SELECT
    DISTINCT (TO_NUMBER(pk2_value)) line_number
  FROM
    fnd_attached_documents
  WHERE
    entity_name = 'PON_AUCTION_ITEM_PRICES_ALL' AND
    pk1_value = to_char(p_auction_header_id) AND
    pk2_value IS NOT NULL;

--Cursor to find out lines that have backing requisitions
CURSOR lines_with_backing_requisition (t_auction_header_id NUMBER) IS
  SELECT
    line_number, org_id
  FROM
    pon_auction_item_prices_all
  WHERE
    auction_header_id = t_auction_header_id AND
    requisition_number IS NOT NULL;

l_module_name VARCHAR2 (30);
l_line_number NUMBER;

l_max_line_number NUMBER;
l_batch_size NUMBER;

l_batch_start NUMBER;
l_batch_end NUMBER;

-- Auction Header Information
l_bid_ranking PON_AUCTION_HEADERS_ALL.BID_RANKING%TYPE;
l_line_attribute_enabled_flag PON_AUCTION_HEADERS_ALL.LINE_ATTRIBUTE_ENABLED_FLAG%TYPE;
l_doctype_group_name PON_AUC_DOCTYPES.DOCTYPE_GROUP_NAME%TYPE;
l_rfi_line_enabled_flag PON_AUCTION_HEADERS_ALL.RFI_LINE_ENABLED_FLAG%TYPE;
l_pf_type_allowed PON_AUCTION_HEADERS_ALL.PF_TYPE_ALLOWED%TYPE;
l_contract_type PON_AUCTION_HEADERS_ALL.CONTRACT_TYPE%TYPE;
l_global_agreement_flag PON_AUCTION_HEADERS_ALL.GLOBAL_AGREEMENT_FLAG%TYPE;
l_large_neg_enabled_flag PON_AUCTION_HEADERS_ALL.LARGE_NEG_ENABLED_FLAG%TYPE;
l_auction_origination_code PON_AUCTION_HEADERS_ALL.AUCTION_ORIGINATION_CODE%TYPE;
l_progress_payment_type PON_AUCTION_HEADERS_ALL.PROGRESS_PAYMENT_TYPE%TYPE;
l_price_tiers_indicator PON_AUCTION_HEADERS_ALL.PRICE_TIERS_INDICATOR%TYPE;

BEGIN

  l_module_name := 'delete_all_lines';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name ||
                 ' p_auction_header_id = ' || p_auction_header_id);
  END IF;

  -- Collect auction information that is needed
  -- This information is being collected from the database instead
  -- of relying on the middle tier data as it is possible that the
  -- user has change the attribute but not yet saved it. Eg: User
  -- has changed from Price Only to MAS but not saved, so surely
  -- now there are no scores on the auction. The middle tier data
  -- now has MAS but the saved db data has Price Only which is
  -- what we look at.
  -- Reason we are having this outside the check l_max_line_number > 0
  -- is that we need the auction_origination_code before deleting
  -- references to requisitions
  SELECT
    paha.bid_ranking,
    paha.line_attribute_enabled_flag,
    pad.doctype_group_name,
    paha.rfi_line_enabled_flag,
    paha.pf_type_allowed,
    paha.contract_type,
    paha.global_agreement_flag,
    paha.large_neg_enabled_flag,
    paha.auction_origination_code,
    paha.progress_payment_type,
    paha.price_tiers_indicator
  INTO
    l_bid_ranking,
    l_line_attribute_enabled_flag,
    l_doctype_group_name,
    l_rfi_line_enabled_flag,
    l_pf_type_allowed,
    l_contract_type,
    l_global_agreement_flag,
    l_large_neg_enabled_flag,
    l_auction_origination_code,
    l_progress_payment_type,
    l_price_tiers_indicator
  FROM
    pon_auction_headers_all paha,
    pon_auc_doctypes pad
  WHERE
    paha.auction_header_id = p_auction_header_id AND
    paha.doctype_id = pad.doctype_id;

  SELECT NVL (MAX (line_number), 0)
  INTO l_max_line_number
  FROM pon_auction_item_prices_all
  where auction_header_id = p_auction_header_id;

  -- Get the batch size
  l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;

  -- Call the delete only if the origination code of the auction is
  -- REQUISITION
  IF (l_auction_origination_code = 'REQUISITION') THEN

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Found that this auction is from a requisition');
    END IF;

    --Delete Backing requisition references
    FOR backing_req_line IN lines_with_backing_requisition (p_auction_header_id) LOOP

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'Deleting backing req references for line = ' || backing_req_line.line_number);
      END IF;

      PON_AUCTION_PKG.delete_negotiation_line_ref(
        x_negotiation_id => p_auction_header_id,
        x_negotiation_line_num => backing_req_line.line_number,
        x_org_id => backing_req_line.org_id,
        x_error_code => x_error_code);

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'Deletion of req reference done, x_error_code = ' || x_error_code);
      END IF;

      IF (x_error_code <> 'SUCCESS') THEN
        x_result := FND_API.g_ret_sts_unexp_error;
        RETURN;
      END IF;
    END LOOP;
  END IF;

  --Delete Attachments
  FOR attachment_line IN lines_with_attachements LOOP

    FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments (
      x_entity_name =>'PON_AUCTION_ITEM_PRICES_ALL',
      x_pk1_value => p_auction_header_id,
      x_pk2_value => attachment_line.line_number,
      x_pk3_value => NULL,
      x_pk4_value => NULL,
      x_pk5_value => NULL);

  END LOOP;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_statement,
      module => g_module_prefix || l_module_name,
      message => 'Attachments deletion complete');
  END IF;

  -- Draft with no lines, or RFI,CPA with no lines we need to skip batching
  -- its build into the loop logic but just to be explicit about this condition

  IF (l_max_line_number > 0) THEN

    -- Define the initial batch range (line numbers are indexed from 1)
    l_batch_start := 1;

    IF (l_max_line_number <l_batch_size) THEN
        l_batch_end := l_max_line_number;
    ELSE
        l_batch_end := l_batch_size;
    END IF;

    WHILE (l_batch_start <= l_max_line_number) LOOP

    IF ('STANDARD' = l_contract_type AND l_progress_payment_type <> 'NONE') THEN
      --complex work-delete fnd_attachments for payments
      IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_procedure,
          module => g_module_prefix || l_module_name,
          message => 'Before call Delete_Payment_Attachments = ' || l_module_name);
       END IF;

      Delete_Payment_Attachments(
          p_auction_header_id => p_auction_header_id,
          p_curr_from_line_number => l_batch_start,
          p_curr_to_line_number => l_batch_end);

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'Payments Attachments deletion complete');
      END IF;

      --complex work -delete payments
      DELETE FROM
        pon_auc_payments_shipments
      WHERE
        auction_header_id = p_auction_header_id AND
        line_number >= l_batch_start AND
        line_number <= l_batch_end;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'Payments deletion complete');
      END IF;
    END IF; --if complex work
      -- Call the delete scores only if negotiation has
      -- BID_RANKING as 'MULTI_ATTRIBUTE_SCORING'
      IF (l_bid_ranking = 'MULTI_ATTRIBUTE_SCORING') THEN

        -- Delete the entries for attribute scores. To
        -- avoid deleting the attributes corresponding
        -- to the header the condition LINE_NUMBER <> -1
        -- is added
        -- Above condition is built into the batching
        -- condition as we start from 1
        DELETE FROM
          pon_attribute_scores
        WHERE
          auction_header_id = p_auction_header_id AND
          line_number >= l_batch_start AND
          line_number <= l_batch_end;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'Scores deletion complete');
        END IF;

      END IF;

      -- Call the delete attributes only if the negotiation has
      -- LINE_ATTRIBUTE_ENABLED_FLAG set to Y
      IF (NVL (l_line_attribute_enabled_flag, 'Y') = 'Y' AND
          (l_doctype_group_name <> PON_CONTERMS_UTL_PVT.SRC_REQUEST_FOR_INFORMATION OR
           NVL (l_rfi_line_enabled_flag, 'Y') = 'Y')) THEN

        -- Delete the entries for attributes. To
        -- avoid deleting the attributes corresponding
        -- to the header the condition LINE_NUMBER <> -1
        -- is added
        -- Above condition is built into the batching
        -- condition as we start from 1
        DELETE FROM
          pon_auction_attributes
        WHERE
          auction_header_id = p_auction_header_id AND
          line_number >= l_batch_start AND
          line_number <= l_batch_end;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'Attributes deletion complete');
        END IF;
      END IF;

      -- Call the delete price elements only if
      -- PF_TYPE_ALLOWED is set to other than NONE
      IF (l_pf_type_allowed <> 'NONE') THEN --{

        -- Delete the price elements
        DELETE FROM
          pon_price_elements
        WHERE
          auction_header_id = p_auction_header_id AND
          line_number >= l_batch_start AND
          line_number <= l_batch_end;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'PF deletion complete');
        END IF;

        -- Delete the supplier pf values
        DELETE FROM
          pon_pf_supplier_values
        WHERE
          auction_header_id = p_auction_header_id AND
          line_number >= l_batch_start AND
          line_number <= l_batch_end;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'PF Supplier values deletion complete');
        END IF;

      END IF; --}

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'price_tiers_indicator for auction ' || p_auction_header_id || ' is ' || l_price_tiers_indicator);
      END IF;

      -- Call the delete shipments only if price tiers indicator is not 'NONE'

      IF ( NVl(l_price_tiers_indicator, 'NONE') <> 'NONE') THEN

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'Price tiers indicator is not none , so need to delete Price tiers.');
        END IF;

        -- Delete the price breaks/shipments
        DELETE FROM
          pon_auction_shipments_all
        WHERE
          auction_header_id = p_auction_header_id AND
          line_number >= l_batch_start AND
          line_number <= l_batch_end;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'shipments deletion complete');
        END IF;

      END IF;

      -- Call the delete price differentials only if this is an RFI
      -- or this is a global agreement
      IF (l_doctype_group_name <> PON_CONTERMS_UTL_PVT.SRC_REQUEST_FOR_INFORMATION OR
          NVL (l_global_agreement_flag, 'Y') = 'Y') THEN
        -- Delete the price differentials
        DELETE FROM
          pon_price_differentials
        WHERE
          auction_header_id = p_auction_header_id AND
          line_number >= l_batch_start AND
          line_number <= l_batch_end;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'PD deletion complete');
        END IF;
      END IF;

      -- Call party line exclusion deletion only if this is
      -- not a large negotiation
      IF (nvl (l_large_neg_enabled_flag, 'N') = 'N') THEN

        -- Delete the party line exclusions
        DELETE FROM
          pon_party_line_exclusions
        WHERE
          auction_header_id = p_auction_header_id AND
          line_number >= l_batch_start AND
          line_number <= l_batch_end;

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'party exclusions deletion complete');
        END IF;

      END IF;

      /* Begin Supplier Management: Mapping */
      IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
        DELETE FROM pon_auction_attr_mapping_b
        WHERE       auction_header_id = p_auction_header_id
        AND         line_number >= l_batch_start
        AND         line_number <= l_batch_end
        AND         mapping_type IN ('ITEM_LINE', 'CAT_LINE');
      END IF;
      /* End Supplier Management: Mapping */
      -- Delete the entries for lines
      DELETE FROM
        pon_auction_item_prices_all
      WHERE
        auction_header_id = p_auction_header_id AND
        line_number >= l_batch_start AND
        line_number <= l_batch_end;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'Lines deletion complete');
      END IF;

      -- Find the new batch range
      l_batch_start := l_batch_end + 1;
      IF (l_batch_end + l_batch_size > l_max_line_number) THEN
          l_batch_end := l_max_line_number;
      ELSE
          l_batch_end := l_batch_end + l_batch_size;
      END IF;

      -- Issue a commit to push in all changes
      COMMIT;
    END LOOP;

  END IF;

  -- Call delete from pon_large_neg_pf_values only if this is
  -- a large negotiation
  IF (l_large_neg_enabled_flag = 'Y') THEN

    -- Delete the large neg pf values
    DELETE FROM
      pon_large_neg_pf_values
    WHERE
      auction_header_id = p_auction_header_id;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Large neg pf values deletion complete');
    END IF;

  END IF;

  -- Call update on pon_bidding_parties only if this is
  -- not a large negotiation
  IF (nvl (l_large_neg_enabled_flag, 'N') = 'N') THEN

    --Need to update pon_bidding_parties about the access_type
    --Any supplier who was restricted on the deleted lines
    --should now have access_type set to FULL
    UPDATE
      pon_bidding_parties
    SET
      access_type = 'FULL'
    WHERE
      auction_header_id = p_auction_header_id AND
      access_type = 'RESTRICTED' AND
      (trading_partner_id, vendor_site_id) NOT IN
      (SELECT trading_partner_id, vendor_site_id
       FROM pon_party_line_exclusions
       WHERE auction_header_id = p_auction_header_id);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Updating bidding parties done');
    END IF;

  END IF;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;
END delete_all_lines;

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
  x_result OUT NOCOPY VARCHAR2, --1
  x_error_code OUT NOCOPY VARCHAR2, --2
  x_error_message OUT NOCOPY VARCHAR2, --3
  p_auction_header_id IN NUMBER, --4
  p_line_number IN NUMBER, --5
  p_group_type IN VARCHAR2, --6
  p_origination_code IN VARCHAR2, --7
  p_org_id IN NUMBER, --8
  p_parent_line_number IN NUMBER, --9
  p_sub_line_sequence_number IN NUMBER, --10
  x_number_of_lines_deleted IN OUT NOCOPY NUMBER --11
) IS

l_module_name VARCHAR2 (30);

l_header_max_document_line_num NUMBER;
l_line_number NUMBER;

-- Auction Header Information
l_bid_ranking PON_AUCTION_HEADERS_ALL.BID_RANKING%TYPE;
l_line_attribute_enabled_flag PON_AUCTION_HEADERS_ALL.LINE_ATTRIBUTE_ENABLED_FLAG%TYPE;
l_doctype_group_name PON_AUC_DOCTYPES.DOCTYPE_GROUP_NAME%TYPE;
l_rfi_line_enabled_flag PON_AUCTION_HEADERS_ALL.RFI_LINE_ENABLED_FLAG%TYPE;
l_pf_type_allowed PON_AUCTION_HEADERS_ALL.PF_TYPE_ALLOWED%TYPE;
l_contract_type PON_AUCTION_HEADERS_ALL.CONTRACT_TYPE%TYPE;
l_global_agreement_flag PON_AUCTION_HEADERS_ALL.GLOBAL_AGREEMENT_FLAG%TYPE;
l_large_neg_enabled_flag PON_AUCTION_HEADERS_ALL.LARGE_NEG_ENABLED_FLAG%TYPE;
l_auction_origination_code PON_AUCTION_HEADERS_ALL.AUCTION_ORIGINATION_CODE%TYPE;
l_amendment_number PON_AUCTION_HEADERS_ALL.AMENDMENT_NUMBER%TYPE;
l_auction_round_number PON_AUCTION_HEADERS_ALL.AUCTION_ROUND_NUMBER%TYPE;
l_is_multi_round VARCHAR2(2);
l_is_amendment VARCHAR2(2);
l_progress_payment_type PON_AUCTION_HEADERS_ALL.PROGRESS_PAYMENT_TYPE%TYPE;
l_price_tiers_indicator PON_AUCTION_HEADERS_ALL.PRICE_TIERS_INDICATOR%TYPE;

-- Cursor to find out lines that have attachments
-- within a lot/group
CURSOR lines_with_attachements IS
  SELECT
    DISTINCT (TO_NUMBER(fad.pk2_value)) line_number
  FROM
    fnd_attached_documents fad,
		pon_auction_item_prices_all paip
  WHERE
    fad.entity_name = 'PON_AUCTION_ITEM_PRICES_ALL' AND
    fad.pk1_value = TO_CHAR(p_auction_header_id) AND
    paip.auction_header_id = p_auction_header_id AND
    fad.pk2_value = paip.line_number AND
		(paip.line_number = p_line_number OR paip.parent_line_number = p_line_number);

-- Cursor to find out lines that have backing requisitions
-- within a lot/group
CURSOR lines_with_backing_requisition IS
  SELECT
    line_number, org_id
  FROM
    pon_auction_item_prices_all
  WHERE
    auction_header_id = p_auction_header_id AND
		(line_number = p_line_number OR parent_line_number = p_line_number) AND
    requisition_number IS NOT NULL;


--cursor to delete payment attachemnts for whole lot or group
CURSOR delete_payments_attachments IS
  SELECT
    DISTINCT (TO_NUMBER(fad.pk2_value)) line_number
  FROM
    fnd_attached_documents fad,
		pon_auction_item_prices_all paip
  WHERE
    fad.entity_name = 'PON_AUC_PAYMENTS_SHIPMENTS' AND
    fad.pk1_value = TO_CHAR(p_auction_header_id) AND
    paip.auction_header_id = p_auction_header_id AND
    fad.pk2_value = paip.line_number AND
		(paip.line_number = p_line_number OR paip.parent_line_number = p_line_number);

BEGIN

  l_module_name := 'delete_single_line';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name ||
                 ', p_auction_header_id = ' || p_auction_header_id ||
                 ', p_line_number = ' || p_line_number ||
                 ', p_group_type = ' || p_group_type ||
                 ', p_origination_code = ' || p_origination_code ||
                 ', p_org_id = ' || p_org_id ||
                 ', p_parent_line_number = ' || p_parent_line_number ||
                 ', p_sub_line_sequence_number = ' || p_sub_line_sequence_number);
  END IF;

  -- Collect auction information that is needed
  -- This information is being collected from the database instead
  -- of relying on the middle tier data as it is possible that the
  -- user has change the attribute but not yet saved it. Eg: User
  -- has changed from Price Only to MAS but not saved, so surely
  -- now there are no scores on the auction. The middle tier data
  -- now has MAS but the saved db data has Price Only which is
  -- what we look at.
  -- Reason we are having this outside the check l_max_line_number > 0
  -- is that we need the auction_origination_code before deleting
  -- references to requisitions
  SELECT
    paha.bid_ranking,
    paha.line_attribute_enabled_flag,
    pad.doctype_group_name,
    paha.rfi_line_enabled_flag,
    paha.pf_type_allowed,
    paha.contract_type,
    paha.global_agreement_flag,
    paha.large_neg_enabled_flag,
    paha.auction_origination_code,
    paha.amendment_number,
    paha.auction_round_number,
    paha.progress_payment_type,
    paha.price_tiers_indicator
  INTO
    l_bid_ranking,
    l_line_attribute_enabled_flag,
    l_doctype_group_name,
    l_rfi_line_enabled_flag,
    l_pf_type_allowed,
    l_contract_type,
    l_global_agreement_flag,
    l_large_neg_enabled_flag,
    l_auction_origination_code,
    l_amendment_number,
    l_auction_round_number,
    l_progress_payment_type,
    l_price_tiers_indicator
  FROM
    pon_auction_headers_all paha,
    pon_auc_doctypes pad
  WHERE
    paha.auction_header_id = p_auction_header_id AND
    paha.doctype_id = pad.doctype_id;

  -- If this is a line/lot_line or a group_line then need to simply
  -- remove the entries corresponding to this one line
  IF (p_group_type IN ('LINE', 'LOT_LINE', 'GROUP_LINE')) THEN -- {

    SELECT
      max_document_line_num
    INTO
      l_header_max_document_line_num
    FROM
      pon_auction_headers_all
    WHERE
      auction_header_id = p_auction_header_id;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'The selected row is of type LINE/LOT_LINE/GROUP_LINE');
    END IF;

    BEGIN

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'Checking if the line still exists');
      END IF;

      --Checking if the line still exists in the database
      --We are doing this because the user might have selected a LOT and its
      --LOT_LINE for deletion and the LOT_LINE has already been deleted as
      --part of the LOT deletion. Simply return with number of lines deleted
      --set to zero

      SELECT
        line_number
      INTO
        l_line_number
      FROM
        pon_auction_item_prices_all
      WHERE
        auction_header_id = p_auction_header_id and
        line_number = p_line_number;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'Line exists');
      END IF;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        x_number_of_lines_deleted := 0;
        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'Line no longer exists');
        END IF;
        RETURN;
    END;

    DELETE FROM
      pon_attribute_scores
    WHERE
      auction_header_id = p_auction_header_id AND
      line_number = p_line_number;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the entry in pon_attribute_scores');
    END IF;

    DELETE FROM
      pon_auction_attributes
    WHERE
      auction_header_id = p_auction_header_id and
      line_number = p_line_number;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Entry in pon_auction_attributes deleted');
    END IF;

    DELETE FROM
      pon_pf_supplier_values
    WHERE
      auction_header_id = p_auction_header_id AND
      line_number = p_line_number;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the entry in pon_pf_supplier_values');
    END IF;

    DELETE FROM
      pon_price_elements
    WHERE
      auction_header_id = p_auction_header_id AND
      line_number = p_line_number;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the entry in pon_price_elements');
    END IF;

    DELETE FROM
      pon_price_differentials
    WHERE
      auction_header_id = p_auction_header_id AND
      line_number = p_line_number;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the entry in pon_price_differentials');
    END IF;

    DELETE FROM
      pon_auction_shipments_all
    WHERE
      auction_header_id = p_auction_header_id AND
      line_number = p_line_number;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the entry in pon_auction_shipments_all');
    END IF;

    IF ( 'STANDARD' = l_contract_type AND 'NONE' <> l_progress_payment_type) --{
    THEN

       IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string (log_level => FND_LOG.level_statement,
           module => g_module_prefix || l_module_name,
           message => 'Delete attachments for  pon_auc_payments_shipments');
       END IF;

       --delete payment attachments

      Delete_Payment_Attachments(
          p_auction_header_id => p_auction_header_id,
          p_curr_from_line_number => p_line_number,
          p_curr_to_line_number => p_line_number);


       IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string (log_level => FND_LOG.level_statement,
           module => g_module_prefix || l_module_name,
           message => 'Deleted the attachments for  pon_auc_payments_shipments');
       END IF;

      DELETE FROM
        pon_auc_payments_shipments
      WHERE
        auction_header_id = p_auction_header_id AND
        line_number = p_line_number;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the entry in pon_auc_payments_shipments');
      END IF;
    END IF;--if neg has payments }

    DELETE FROM
      pon_party_line_exclusions
    WHERE
      auction_header_id = p_auction_header_id AND
      line_number = p_line_number;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the entry in PON_PARTY_LINE_EXCLUSIONS');
    END IF;

    /* Begin Supplier Management: Mapping */
    IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
      DELETE FROM pon_auction_attr_mapping_b
      WHERE       auction_header_id = p_auction_header_id
      AND         line_number = p_line_number
      AND         mapping_type IN ('ITEM_LINE', 'CAT_LINE');
    END IF;
    /* End Supplier Management: Mapping */
    DELETE FROM
      pon_auction_item_prices_all
    WHERE
      auction_header_id = p_auction_header_id AND
      line_number = p_line_number;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the entry in pon_auction_headers_all');
    END IF;

    /*
     * The sync procedure should be called after the line deletion
     * It should also be called only for large negotiations
     **/

    IF (l_large_neg_enabled_flag = 'Y') THEN
      sync_pf_values_item_prices (
        p_auction_header_id => p_auction_header_id,
        p_line_number => p_line_number,
        p_add_pf => 'N',
        p_del_pf => 'Y',
        x_result => x_result,
        x_error_code => x_error_code,
        x_error_message => x_error_message);

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'Sync pf values procedure called. x_result = ' || x_result ||
                     ', x_error_code = ' || x_error_code ||
                     ', x_error_message = ' || x_error_message);
      END IF;

      IF (x_result <> FND_API.g_ret_sts_success) THEN
        RETURN;
      END IF;

    END IF;

    FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments (
      x_entity_name =>  'PON_AUCTION_ITEM_PRICES_ALL',
      x_pk1_value => p_auction_header_id,
      x_pk2_value => p_line_number);

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the line attachments');
    END IF;

    IF (p_origination_code = 'REQUISITION') THEN
      PON_AUCTION_PKG.delete_negotiation_line_ref(
        x_negotiation_id => p_auction_header_id,
        x_negotiation_line_num => p_line_number,
        x_org_id => p_org_id,
        x_error_code => x_error_code);

        IF (x_error_code <> 'SUCCESS') THEN
          x_result := FND_API.g_ret_sts_unexp_error;
          RETURN;
        END IF;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the line backing requisitions if any');
    END IF;

    -- In case this is an amendment and we are deleting a LOT_LINE/GROUP_LINE
    -- then on the parent line need to set the MODIFIED_FLAG, MODIFIED_DATE and
    -- LAST_AMENDMENT_UPDATE if the line is coming from the previous ROUND
    IF (p_group_type IN ('LOT_LINE', 'GROUP_LINE') AND
          l_amendment_number > 0 AND
          p_sub_line_sequence_number <= l_header_max_document_line_num) THEN
      UPDATE
        pon_auction_item_prices_all
      SET
        modified_flag = 'Y',
        modified_date = sysdate,
        last_amendment_update = l_amendment_number
     WHERE
        auction_header_id = p_auction_header_id AND
        line_number = p_parent_line_number;
    END IF;

    -- In case this is a multi round then on the parent line need to set the MODIFIED_FLAG, MODIFIED fields
    IF (p_group_type IN ('LOT_LINE', 'GROUP_LINE') AND
          l_auction_round_number > 1 AND
          p_sub_line_sequence_number <= l_header_max_document_line_num) THEN
      UPDATE
        PON_AUCTION_ITEM_PRICES_ALL
      SET
        MODIFIED_FLAG = 'Y',
        MODIFIED_DATE = SYSDATE
     WHERE
        AUCTION_HEADER_ID = p_auction_header_id AND
        LINE_NUMBER = p_parent_line_number;
    END IF;

    --The number of lines deleted is only 1 in this case
    x_number_of_lines_deleted := 1;

  ELSE --} { This is the case for LOT or GROUP

    -- Keep track of how many lines are being deleted
    SELECT
      count(line_number)
    INTO
      x_number_of_lines_deleted
    FROM
      pon_auction_item_prices_all
    WHERE
      auction_header_id = p_auction_header_id AND
      (line_number = p_line_number OR parent_line_number = p_line_number);

    -- Call deletion of attributes only if line_attribute_enabled_flag is Y
    IF (NVL (l_line_attribute_enabled_flag, 'Y') = 'Y') THEN --{

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'line attributes are enabled. l_line_attribute_enabled_flag = ' || l_line_attribute_enabled_flag);
      END IF;

      -- Call deletion of scores only if this is an MAS
      IF (l_bid_ranking = 'MULTI_ATTRIBUTE_SCORING') THEN --{

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'This is an MAS auction so need to delete scores');
        END IF;

        -- Delete the scores that belong to this lot/group
        -- and also its children
        DELETE FROM
          pon_attribute_scores pas
        WHERE
          pas.auction_header_id = p_auction_header_id AND
          (
            pas.line_number = p_line_number OR
            EXISTS
              (
                SELECT
                  paip.line_number
                FROM
                  pon_auction_item_prices_all paip
                WHERE
                  paip.parent_line_number = p_line_number AND
                  paip.auction_header_id = p_auction_header_id AND
                  paip.line_number = pas.line_number
              )
           );

       END IF; --}

      -- Delete the attributes that belong to this lot/group
      -- and also its children
      DELETE FROM
        pon_auction_attributes paa
      WHERE
        paa.auction_header_id = p_auction_header_id AND
        (
          paa.line_number = p_line_number OR
          EXISTS
            (
              SELECT
                paip.line_number
              FROM
                pon_auction_item_prices_all paip
              WHERE
                paip.parent_line_number = p_line_number AND
                paip.auction_header_id = p_auction_header_id AND
                paip.line_number = paa.line_number
            )
         );

     END IF; --}

    -- Call the deletion of pf supplier values and price elements
    -- only if the pf_type_allowed is not NONE

    IF (l_pf_type_allowed <> 'NONE') THEN --{

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'There are price factors. l_pf_type_allowed = ' || l_pf_type_allowed);
      END IF;

      -- Delete the pf supplier values that belong to this
      -- lot/group and also its children
      DELETE FROM
        pon_pf_supplier_values ppsv
      WHERE
        ppsv.auction_header_id = p_auction_header_id AND
        (
          ppsv.line_number = p_line_number OR
          EXISTS
            (
              SELECT
                paip.line_number
              FROM
                pon_auction_item_prices_all paip
              WHERE
                paip.parent_line_number = p_line_number AND
                paip.auction_header_id = p_auction_header_id AND
                paip.line_number = ppsv.line_number
            )
         );

      -- Delete the cost factors that belong to this
      -- lot/group and also its children
      DELETE FROM
        pon_price_elements ppe
      WHERE
        ppe.auction_header_id = p_auction_header_id AND
        (
          ppe.line_number = p_line_number OR
          EXISTS
            (
              SELECT
                paip.line_number
              FROM
                pon_auction_item_prices_all paip
              WHERE
                paip.parent_line_number = p_line_number AND
                paip.auction_header_id = p_auction_header_id AND
                paip.line_number = ppe.line_number
            )
         );

     END IF; --}

    IF ( 'STANDARD' = l_contract_type AND 'NONE' <> l_progress_payment_type)
    THEN

       IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string (log_level => FND_LOG.level_statement,
           module => g_module_prefix || l_module_name,
           message => 'Delete attachments for  pon_auc_payments_shipments');
       END IF;

       --delete payment attachments
    FOR delete_attachments_rec IN delete_payments_attachments LOOP
      IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_procedure,
           module => g_module_prefix || l_module_name,
           message => 'Deleting fnd attachments for payments for line number ' ||delete_attachments_rec.line_number||'='|| l_module_name);
       END IF;
      --delete the attachments for a payment
       FND_ATTACHED_DOCUMENTS2_PKG.DELETE_ATTACHMENTS
        (x_entity_name  => 'PON_AUC_PAYMENTS_SHIPMENTS',
         x_pk1_value => p_auction_header_id,
         x_pk2_value => delete_attachments_rec.line_number,
	 x_delete_document_flag => 'Y');
    END LOOP;

       IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
         FND_LOG.string (log_level => FND_LOG.level_statement,
           module => g_module_prefix || l_module_name,
           message => 'Deleted the attachments for  pon_auc_payments_shipments');
       END IF;

       DELETE FROM
      pon_auc_payments_shipments paps
       WHERE
        paps.auction_header_id = p_auction_header_id AND (
        paps.line_number = p_line_number OR
	EXISTS
	(
	 SELECT
	 paip.line_number
	 FROM
	 pon_auction_item_prices_all paip
	 WHERE
	   paip.parent_line_number = p_line_number AND
           paip.auction_header_id = p_auction_header_id AND
	   paip.line_number = paps.line_number
	)
      );

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleted the entry in pon_auc_payments_shipments');
      END IF;
    END IF;--if neg has payments

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'price_tiers_indicator for auction ' || p_auction_header_id || ' is ' || l_price_tiers_indicator);
    END IF;


    -- Call the delete shipments only if price tiers indicator is not 'NONE'

    IF ( NVl(l_price_tiers_indicator, 'NONE') <> 'NONE') THEN --{

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'Price tiers indicator is not none , so need to delete Price tiers.');
      END IF;

      -- Delete the price breaks that belong to this
      -- lot/group and also its children
      DELETE FROM
        pon_auction_shipments_all pasa
      WHERE
        pasa.auction_header_id = p_auction_header_id AND
        (
          pasa.line_number = p_line_number OR
          EXISTS
            (
              SELECT
                paip.line_number
              FROM
                pon_auction_item_prices_all paip
              WHERE
                paip.parent_line_number = p_line_number AND
                paip.auction_header_id = p_auction_header_id AND
                paip.line_number = pasa.line_number
            )
         );

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN --{
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'shipments deletion complete');
        END IF; --}

    END IF;--}

    -- Call delete on price differentials only if this is a global agreement or
    -- this is an RFI
    IF (l_doctype_group_name = PON_CONTERMS_UTL_PVT.SRC_REQUEST_FOR_INFORMATION OR
      nvl (l_global_agreement_flag, 'Y') = 'Y') THEN --{

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'This is an RFI or Global Agreement. Need to delete price diffs.');
      END IF;

      -- Delete the price differentials that belong to this
      -- lot/group and also its children
      DELETE FROM
        pon_price_differentials ppd
      WHERE
        ppd.auction_header_id = p_auction_header_id AND
        (
          ppd.line_number = p_line_number OR
          EXISTS
            (
              SELECT
                paip.line_number
              FROM
                pon_auction_item_prices_all paip
              WHERE
                paip.parent_line_number = p_line_number AND
                paip.auction_header_id = p_auction_header_id AND
                paip.line_number = ppd.line_number
            )
        );

    END IF; --}

    -- Call delete on party line exclusions only if this is not a large negotiation
    IF (nvl (l_large_neg_enabled_flag, 'N') = 'N') THEN --{
      -- Delete the exclusions that belong to this
      -- lot/group and also its children

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'This is not large so deleting the exclusion entries.');
      END IF;

      DELETE FROM
        pon_party_line_exclusions pple
      WHERE
        pple.auction_header_id = p_auction_header_id AND
        (
          pple.line_number = p_line_number OR
          EXISTS
            (
              SELECT
                paip.line_number
              FROM
                pon_auction_item_prices_all paip
              WHERE
                paip.parent_line_number = p_line_number AND
                paip.auction_header_id = p_auction_header_id AND
                paip.line_number = pple.line_number
            )
       );
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleting attachments.');
    END IF;

    --Delete Attachments
    FOR attachment_line IN lines_with_attachements LOOP

      FND_ATTACHED_DOCUMENTS2_PKG.delete_attachments (
        x_entity_name =>'PON_AUCTION_ITEM_PRICES_ALL',
        x_pk1_value => p_auction_header_id,
        x_pk2_value => attachment_line.line_number,
        x_pk3_value => NULL,
        x_pk4_value => NULL,
        x_pk5_value => NULL);

    END LOOP;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleting backing requisition line references.');
    END IF;

    -- Call delete references to backing reqs only if the auction origination
    -- code is REQUISITION
    IF (l_auction_origination_code = 'REQUISITION') THEN

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'This auction comes from a requisition.');
      END IF;

      -- Delete references to the backing req
      FOR backing_req_line IN lines_with_backing_requisition LOOP

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'Deleting backing reqs for line_number = ' || backing_req_line.line_number);
        END IF;

        PON_AUCTION_PKG.delete_negotiation_line_ref(
          x_negotiation_id => p_auction_header_id,
          x_negotiation_line_num => backing_req_line.line_number,
          x_org_id => backing_req_line.org_id,
          x_error_code => x_error_code);

        IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'Done deleting reference. x_error_code = ' || x_error_code);
        END IF;

        IF (x_error_code <> 'SUCCESS') THEN
          x_result := FND_API.g_ret_sts_unexp_error;
          RETURN;
        END IF;

      END LOOP;

    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_statement,
        module => g_module_prefix || l_module_name,
        message => 'Deleting the lines');
    END IF;

    /* Begin Supplier Management: Mapping */
    IF (FND_PROFILE.VALUE('POS_SM_ENABLE_SPM_EXTENSION') = 'Y') THEN
      DELETE FROM pon_auction_attr_mapping_b
      WHERE       auction_header_id = p_auction_header_id
      AND         (line_number = p_line_number OR
                   ( line_number IN ( SELECT line_number
                                      FROM   pon_auction_item_prices_all
                                      WHERE  auction_header_id = p_auction_header_id
                                      AND    parent_line_number = p_line_number) ) )
      AND         mapping_type IN ('ITEM_LINE', 'CAT_LINE');
    END IF;
    /* End Supplier Management: Mapping */
    -- Finally delete the lines
    DELETE FROM
      pon_auction_item_prices_all
    WHERE
      auction_header_id = p_auction_header_id AND
      (line_number = p_line_number OR parent_line_number = p_line_number);

    /*
     * The sync procedure should be called after the line deletion
     * It should also be called only for large negotiations
     **/

    IF (l_large_neg_enabled_flag = 'Y') THEN
      sync_pf_values_item_prices (
        p_auction_header_id => p_auction_header_id,
        p_line_number => null,
        p_add_pf => 'N',
        p_del_pf => 'Y',
        x_result => x_result,
        x_error_code => x_error_code,
        x_error_message => x_error_message);

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'Sync pf values procedure called. x_result = ' || x_result ||
                     ', x_error_code = ' || x_error_code ||
                     ', x_error_message = ' || x_error_message);
      END IF;

      IF (x_result <> FND_API.g_ret_sts_success) THEN
        RETURN;
      END IF;
    END IF;

  END IF; --}

  -- Need to update pon_bidding_parties about the access_type
  -- Any supplier who was restricted on the deleted lines
  -- should now have access_type set to FULL
  UPDATE
    pon_bidding_parties
  SET
    access_type = 'FULL'
  WHERE
    auction_header_id = p_auction_header_id AND
    access_type = 'RESTRICTED' AND
    (trading_partner_id, vendor_site_id) NOT IN
    (SELECT distinct trading_partner_id, vendor_site_id
     FROM pon_party_line_exclusions
     WHERE auction_header_id = p_auction_header_id);

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;

END delete_single_line;

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
  x_last_line_number OUT NOCOPY NUMBER
) IS

l_new_disp_line_number         PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_sub_line_seq_number          PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_document_disp_line_number    PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_line_number                  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_parent_line_number           PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
l_parent_doc_disp_line_number  PON_NEG_COPY_DATATYPES_GRP.VARCHAR50_TYPE;
l_parent_max_sub_line_seq_num  PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;

l_max_sub_line_sequence_number NUMBER;
l_max_document_line_num        NUMBER;
l_current_parent_line_number   NUMBER;
l_current_max_sub_line_seq     NUMBER;
l_min_disp_line_number         NUMBER;

l_login_id                     NUMBER;
l_user_id                      NUMBER;
l_temp                         NUMBER;
l_module_name VARCHAR2 (30);

l_temp_char                    VARCHAR2(100);
BEGIN

  l_module_name := 'renumber_lines';
  x_result := FND_API.g_ret_sts_success;
  x_last_line_number := -1;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN

    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.RENUMBER_LINES'
                  || ', p_auction_header_id = ' || p_auction_header_id
                  || ', p_min_disp_line_number_parent = ' || p_min_disp_line_number_parent
                  || ', p_min_disp_line_number_child = ' || p_min_disp_line_number_child
                  || ', p_min_child_parent_line_num = ' || p_min_child_parent_line_num);
  END IF;

  --START: CORRECT_SUB_LINE_SEQUENCE_NUMBER {
  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'Selecting the maximum sub_line_sequence_number from the header');
  END IF;

  --GET THE MAX_DOCUMENT_LINE_NUM (This is the maximum sub_line_sequence_number
  --from the previous neg) FROM THE HEADER
  SELECT
    NVL(MAX_DOCUMENT_LINE_NUM,0)
  INTO
    l_max_document_line_num
  FROM
    PON_AUCTION_HEADERS_ALL
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'The maximum sub_line_sequence_number from the header = ' || l_max_document_line_num);
  END IF;

  --START: CORRECT FOR LINES, LOTS, GROUPS
  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'Retrieving the line_numbers into a table of numbers');
  END IF;

  --GET THE LINES, LOTS AND GROUPS FIRST
  SELECT
    LINE_NUMBER
  BULK COLLECT INTO
    l_line_number
  FROM
    PON_AUCTION_ITEM_PRICES_ALL
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id AND
    GROUP_TYPE IN ('LOT', 'GROUP', 'LINE') AND
    SUB_LINE_SEQUENCE_NUMBER > l_max_document_line_num AND
    DISP_LINE_NUMBER > p_min_disp_line_number_parent
  ORDER BY
    DISP_LINE_NUMBER;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'Number of lines collected = ' || l_line_number.COUNT);
  END IF;

  l_login_id := FND_GLOBAL.LOGIN_ID;
  l_user_id := FND_GLOBAL.USER_ID;

  --CHECK IF ANY LINES EXIST AFTER THE MIN DISP_LINE_NUMBER
  --IF NOT THEN NO NEED TO RENUMBER ANY PARENT TYPE LINES
  IF (l_line_number.COUNT > 0) THEN --{

    --GET THE GREATEST SUB_LINE_SEQUENCE_NUMBER WHOSE
    --DISP_LINE_NUMBER IS LESS THAN p_min_disp_line_number_parent

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'RENUMBER_LINES',
        message  => 'Getting the maximum sub_line_sequence_number from the items table');
    END IF;

    SELECT
      NVL (MAX (SUB_LINE_SEQUENCE_NUMBER), 0)
    INTO
      l_max_sub_line_sequence_number
    FROM
      PON_AUCTION_ITEM_PRICES_ALL
    WHERE
      AUCTION_HEADER_ID = p_auction_header_id AND
      DISP_LINE_NUMBER < p_min_disp_line_number_parent AND
      GROUP_TYPE IN ('LINE','LOT', 'GROUP');

    --IN GENERAL THE l_max_sub_line_sequence_number WILL BE GREATER
    --SO CHECK FOR THE RARER CONDITION

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'RENUMBER_LINES',
        message  => 'Checking where to start the sequencing');
    END IF;

    IF (l_max_sub_line_sequence_number < l_max_document_line_num) THEN

      l_max_sub_line_sequence_number := l_max_document_line_num;
    END IF;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'RENUMBER_LINES',
        message  => 'Sequencing will start at l_max_document_line_num = ' || l_max_document_line_num);
    END IF;

    --CORRECT THE SUB_LINE_SEQUENCE_NUMBER (Same as DOCUMENT_DISP_LINE_NUMBER)
    FOR x IN 1..l_line_number.COUNT
    LOOP

      l_max_sub_line_sequence_number := l_max_sub_line_sequence_number + 1;
      l_sub_line_seq_number (x) := l_max_sub_line_sequence_number;
      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'RENUMBER_LINES',
          message  => 'Calculating the sub_line_sequence_number for line_number (' || l_line_number(x) || ' as ' || l_sub_line_seq_number (x));
      END IF;
    END LOOP;

    --UPDATE THE LINES, LOTS AND GROUPS WITH THE NEW VALUES
    FORALL x in 1..l_line_number.COUNT
    UPDATE
      PON_AUCTION_ITEM_PRICES_ALL
    SET
      SUB_LINE_SEQUENCE_NUMBER = l_sub_line_seq_number (x),
      DOCUMENT_DISP_LINE_NUMBER = l_sub_line_seq_number (x),
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = l_login_id,
      LAST_UPDATED_BY = l_user_id
    WHERE
      AUCTION_HEADER_ID = p_auction_header_id AND
      LINE_NUMBER = l_line_number (x);

  END IF; --}

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'Starting correction of sub_line_sequence_number for lot_lines and group_lines');
  END IF;

  --START: CORRECT THE SUB_LINE_SEQUENCE NUMBER FOR LOT_LINES AND GROUP_LINES
  --GET THE LOT LINES AND GROUP LINES
  SELECT
    CHILDREN.LINE_NUMBER,
    NVL (PARENT.MAX_SUB_LINE_SEQUENCE_NUMBER, 0),
    CHILDREN.PARENT_LINE_NUMBER,
    PARENT.DOCUMENT_DISP_LINE_NUMBER
  BULK COLLECT INTO
    l_line_number,
    l_parent_max_sub_line_seq_num,
    l_parent_line_number,
    l_parent_doc_disp_line_number
  FROM
    PON_AUCTION_ITEM_PRICES_ALL CHILDREN,
    PON_AUCTION_ITEM_PRICES_ALL PARENT
  WHERE
    CHILDREN.AUCTION_HEADER_ID = p_auction_header_id AND
    PARENT.AUCTION_HEADER_ID = p_auction_header_id AND
    PARENT.LINE_NUMBER = CHILDREN.PARENT_LINE_NUMBER AND
    CHILDREN.GROUP_TYPE IN ('LOT_LINE', 'GROUP_LINE') AND
    CHILDREN.SUB_LINE_SEQUENCE_NUMBER > NVL(PARENT.MAX_SUB_LINE_SEQUENCE_NUMBER,0) AND
    (CHILDREN.DISP_LINE_NUMBER > p_min_disp_line_number_child  OR
    CHILDREN.DISP_LINE_NUMBER > p_min_disp_line_number_parent)
  ORDER BY
    CHILDREN.DISP_LINE_NUMBER;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN

    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'Number of lines to be corrected = ' || l_line_number.COUNT);
  END IF;

  IF (l_line_number.COUNT > 0) THEN --{

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'RENUMBER_LINES',
        message  => 'p_min_disp_line_number_child = ' || p_min_disp_line_number_child ||
                    ', p_min_disp_line_number_parent = ' || p_min_disp_line_number_parent);
    END IF;

    IF (p_min_disp_line_number_child <> 0 AND
         p_min_disp_line_number_child < nvl (p_min_disp_line_number_parent, p_min_disp_line_number_child + 1)) THEN -- {

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'RENUMBER_LINES',
          message  => 'The min disp line number child is not zero');
      END IF;

      SELECT
        NVL (MAX (SUB_LINE_SEQUENCE_NUMBER), 0)
      INTO
        l_current_max_sub_line_seq
      FROM
        PON_AUCTION_ITEM_PRICES_ALL
      WHERE
        AUCTION_HEADER_ID = p_auction_header_id AND
        PARENT_LINE_NUMBER = p_min_child_parent_line_num AND
        DISP_LINE_NUMBER < p_min_disp_line_number_child;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'RENUMBER_LINES',
          message  => 'l_current_max_sub_line_seq = ' || l_current_max_sub_line_seq ||
                      'l_parent_max_sub_line_seq_num(1) = ' || l_parent_max_sub_line_seq_num(1));
      END IF;

      l_current_parent_line_number := p_min_child_parent_line_num;

      IF (l_current_max_sub_line_seq < l_parent_max_sub_line_seq_num (1)) THEN
        l_current_max_sub_line_seq := l_parent_max_sub_line_seq_num (1);
      END IF;

    ELSE

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'RENUMBER_LINES',
          message  => 'is zero l_current_max_sub_line_seq = ' || l_current_max_sub_line_seq ||
                      'l_parent_max_sub_line_seq_num(1) = ' || l_parent_max_sub_line_seq_num(1));
      END IF;

      l_current_parent_line_number := l_parent_line_number (1);
      l_current_max_sub_line_seq := l_parent_max_sub_line_seq_num (1);
    END IF; -- }

    --CORRECT THE SUB_LINE_SEQUENCE_NUMBER AND DOCUMENT_DISP_LINE_NUMBER
    FOR x IN 1..l_line_number.COUNT
    LOOP

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'RENUMBER_LINES',
          message  => 'Determining the display for ' || l_line_number (x) ||
                      ', l_current_parent_line_number = ' || l_current_parent_line_number ||
                      ', l_parent_line_number (x) ' || l_parent_line_number(x));
      END IF;

      --WITHIN THE SAME PARENT
      IF (l_current_parent_line_number = l_parent_line_number(x)) THEN
        l_current_max_sub_line_seq := l_current_max_sub_line_seq + 1;

      --NEW PARENT
      ELSE
        l_current_max_sub_line_seq := l_parent_max_sub_line_seq_num (x) + 1;
        l_current_parent_line_number := l_parent_line_number(x);

      END IF;

      -- CORRECT THE SUB_LINE_SEQUENCE_NUMBER AND DOCUMENT_DISP_LINE_NUMBER
      l_sub_line_seq_number (x) := l_current_max_sub_line_seq;
      l_document_disp_line_number (x) := l_parent_doc_disp_line_number(x) || '.' || l_current_max_sub_line_seq;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'RENUMBER_LINES',
          message  => 'Determined ' ||
                      ', l_sub_line_seq_number(x) = ' || l_sub_line_seq_number (x)||
                      ', l_document_disp_line_number(x) ' || l_document_disp_line_number(x));
      END IF;
    END LOOP;

    --UPDATE THE LOT_LINES AND GROUP_LINES WITH THE NEW VALUES
    FORALL x in 1..l_line_number.COUNT
    UPDATE PON_AUCTION_ITEM_PRICES_ALL
    SET
      SUB_LINE_SEQUENCE_NUMBER = l_sub_line_seq_number (x),
      DOCUMENT_DISP_LINE_NUMBER = l_document_disp_line_number (x),
      LAST_UPDATE_DATE = SYSDATE,
      LAST_UPDATE_LOGIN = l_login_id,
      LAST_UPDATED_BY = l_user_id
    WHERE
      AUCTION_HEADER_ID = p_auction_header_id AND
      LINE_NUMBER = l_line_number (x);
  END IF; --}

  --END: CORRECTING SUB_LINE_SEQUENCE_NUMBER --}

  --START: CORRECT_DISP_LINE_NUMBER {
  --COLLECT THE LINE_NUMBER VALUES INTO AN
  --ARRAY ORDERED BY THE DISP_LINE_NUMBER

  IF (p_min_disp_line_number_child IS NULL) THEN
    l_min_disp_line_number := p_min_disp_line_number_parent;

  ELSIF (p_min_disp_line_number_parent IS NULL) THEN
    l_min_disp_line_number := p_min_disp_line_number_child;

  ELSIF (p_min_disp_line_number_child < p_min_disp_line_number_parent) THEN
    l_min_disp_line_number := p_min_disp_line_number_child;

  ELSE
    l_min_disp_line_number := p_min_disp_line_number_parent;

  END IF;

  SELECT
    LINE_NUMBER
  BULK COLLECT INTO
    l_line_number
  FROM
    PON_AUCTION_ITEM_PRICES_ALL
  WHERE
    AUCTION_HEADER_ID = p_auction_header_id AND
    DISP_LINE_NUMBER > l_min_disp_line_number
  ORDER BY
    DISP_LINE_NUMBER;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'Obtained ' ||  l_line_number.COUNT || ' lines to correct');
  END IF;

  --IF THERE ARE NO LINES BELOW THIS LINE
  --THEN NO RENUMBERING IS REQUIRED
  IF (l_line_number.COUNT = 0) THEN
    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'RENUMBER_LINES',
        message  => 'Returning without doing anything as there are no lines to renumber');
    END IF;

    SELECT
      MAX(sub_line_sequence_number)
    INTO
      l_temp_char
    FROM
      pon_auction_item_prices_all
    WHERE
      auction_header_id = p_auction_header_id and
      group_type IN ('LOT', 'LINE', 'GROUP');

    IF l_temp_char IS NULL THEN
      x_last_line_number := -1;
    ELSE
      x_last_line_number := to_number (l_temp_char);
    END IF;

    RETURN;
  END IF;

  --DETERMINE THE NEXT INTEGER TO START WITH
  l_temp := floor (l_min_disp_line_number);
  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'The new disp line number should start after ' || l_temp);
  END IF;

  --DETERMINE THE NEW DISP_LINE_NUMBER
  FOR y IN 1..l_line_number.COUNT --{
  LOOP

    l_new_disp_line_number (y) := y + l_temp;

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'RENUMBER_LINES',
        message  => 'Determined that ' || l_new_disp_line_number (y)
                    || ' is the new disp_line_number of ' || l_line_number (y));
    END IF;
  END LOOP; --}

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'Calling bulk update to set the new disp_line_number');
  END IF;

  --BULK UPDATE TO SET THE NEW DISP_LINE_NUMBER
  FORALL x IN 1..l_line_number.COUNT
  UPDATE PON_AUCTION_ITEM_PRICES_ALL
  SET DISP_LINE_NUMBER = l_new_disp_line_number (x)
  WHERE LINE_NUMBER = l_line_number(x)
  AND AUCTION_HEADER_ID = p_auction_header_id;

  --}END: CORRECT_DISP_LINE_NUMBER

  SELECT
    MAX(sub_line_sequence_number)
  INTO
    x_last_line_number
  FROM
    pon_auction_item_prices_all
  WHERE
    auction_header_id = p_auction_header_id and
    group_type IN ('LOT', 'LINE', 'GROUP');

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_procedure,
      module  =>  g_module_prefix || 'RENUMBER_LINES',
      message  => 'Leaving PON_NEGOTIATION_HELPER_PVT.RENUMBER_LINES');
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;

END RENUMBER_LINES;


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
) IS
BEGIN

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SRCH_MIN_DISP_LINE_NUMBERS',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.GET_SRCH_MIN_DISP_LINE_NUMBERS'
                  || ', p_curr_auction_header_id = ' || p_curr_auction_header_id
                  || ', p_prev_auction_header_id = ' || p_prev_auction_header_id
                  || ', p_value = ' || p_value);
  END IF;

  --Retrieve the minimum disp_line_number of all the LOT/GROUP/LINES
  --that have SUB_LINE_SEQUENCE_NUMBER > p_value

  SELECT MIN(disp_line_number)
  INTO x_curr_min_disp_line_num
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID = p_curr_auction_header_id
  AND GROUP_TYPE IN ('LOT', 'GROUP', 'LINE')
  AND SUB_LINE_SEQUENCE_NUMBER > p_value;

  SELECT MIN(disp_line_number)
  INTO x_prev_min_disp_line_num
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID = p_prev_auction_header_id
  AND GROUP_TYPE IN ('LOT', 'GROUP', 'LINE')
  AND SUB_LINE_SEQUENCE_NUMBER > p_value;

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SRCH_MIN_DISP_LINE_NUMBERS',
      message  => 'Leaving PON_NEGOTIATION_HELPER_PVT.GET_SRCH_MIN_DISP_LINE_NUMBERS'
                  || 'x_curr_min_disp_line_num = ' || x_curr_min_disp_line_num
                  || 'x_prev_min_disp_line_num = ' || x_prev_min_disp_line_num
                  );
  END IF;

END GET_SRCH_MIN_DISP_LINE_NUMBERS;

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
) IS

l_curr_line_number PON_AUCTION_ITEM_PRICES_ALL.LINE_NUMBER%TYPE;
l_curr_group_type PON_AUCTION_ITEM_PRICES_ALL.GROUP_TYPE%TYPE;
l_prev_line_number PON_AUCTION_ITEM_PRICES_ALL.LINE_NUMBER%TYPE;
l_prev_group_type PON_AUCTION_ITEM_PRICES_ALL.GROUP_TYPE%TYPE;

BEGIN

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SRCH_MAX_DISP_LINE_NUMBERS',
      message  => 'Entering PON_NEGOTIATION_HELPER_PVT.GET_SRCH_MAX_DISP_LINE_NUMBERS '
                  || ', p_curr_auction_header_id = ' || p_curr_auction_header_id
                  || ', p_prev_auction_header_id = ' || p_prev_auction_header_id
                  || ', p_value = ' || p_value);
  END IF;

  --Retrieve the maximum disp_line_number of all the LOT/GROUP/LINES
  --that have SUB_LINE_SEQUENCE_NUMBER < p_value

  SELECT MAX(DISP_LINE_NUMBER)
  INTO x_curr_max_disp_line_num
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID = p_curr_auction_header_id
  AND GROUP_TYPE IN ('LOT', 'LINE', 'GROUP')
  AND SUB_LINE_SEQUENCE_NUMBER < p_value;

  SELECT MAX(DISP_LINE_NUMBER)
  INTO x_prev_max_disp_line_num
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID = p_prev_auction_header_id
  AND GROUP_TYPE IN ('LOT', 'LINE', 'GROUP')
  AND SUB_LINE_SEQUENCE_NUMBER < p_value;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SRCH_MAX_DISP_LINE_NUMBERS',
      message  => 'After the first query x_curr_max_disp_line_num = ' ||
                  x_curr_max_disp_line_num || ' and x_prev_max_disp_line_num = ' || x_prev_max_disp_line_num);
  END IF;

  IF (x_curr_max_disp_line_num IS NULL AND x_prev_max_disp_line_num IS NULL) THEN

    IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || 'GET_SRCH_MAX_DISP_LINE_NUMBERS',
        message  => 'There are no lines in both the auctions so returning null');
    END IF;

    RETURN;
  END IF;

  SELECT GROUP_TYPE, LINE_NUMBER
  INTO l_curr_group_type, l_curr_line_number
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID = p_curr_auction_header_id
  AND DISP_LINE_NUMBER = x_curr_max_disp_line_num;

  SELECT GROUP_TYPE, LINE_NUMBER
  INTO l_prev_group_type, l_prev_line_number
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID = p_prev_auction_header_id
  AND DISP_LINE_NUMBER = x_prev_max_disp_line_num;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SEARCH_MAX_DISP_LINE_NUM',
      message  => 'l_curr_group_type = ' || l_curr_group_type
                  || ', l_curr_line_number = ' || l_curr_line_number
                  ||'l_prev_group_type = ' || l_prev_group_type
                  || ', l_prev_line_number = ' || l_prev_line_number
                  );
  END IF;

  --If the selected line is a LOT/GROUP then get the maximum
  --disp_line_number within that LOT/GROUP

  IF (l_curr_group_type <> 'LINE') THEN
    SELECT NVL (MAX(DISP_LINE_NUMBER), x_curr_max_disp_line_num)
    INTO x_curr_max_disp_line_num
    FROM PON_AUCTION_ITEM_PRICES_ALL
    WHERE AUCTION_HEADER_ID = p_curr_auction_header_id
    AND PARENT_LINE_NUMBER = l_curr_line_number;
  END IF;

  IF (l_prev_group_type <> 'LINE') THEN
    SELECT NVL (MAX(DISP_LINE_NUMBER), x_prev_max_disp_line_num)
    INTO x_prev_max_disp_line_num
    FROM PON_AUCTION_ITEM_PRICES_ALL
    WHERE AUCTION_HEADER_ID = p_prev_auction_header_id
    AND PARENT_LINE_NUMBER = l_prev_line_number;
  END IF;

  IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SEARCH_MAX_DISP_LINE_NUM',
      message  => 'Leaving PON_NEGOTIATION_HELPER_PVT.GET_AUCTION_REQUEST_ID '
                  || ', x_curr_max_disp_line_num = ' || x_curr_max_disp_line_num
                  || ', x_prev_max_disp_line_num = ' || x_prev_max_disp_line_num);
  END IF;

END GET_SRCH_MAX_DISP_LINE_NUMBERS;


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
  p_auction_header_id IN NUMBER
) IS


l_module_name VARCHAR2 (30);
l_discussion_id  PON_DISCUSSIONS.DISCUSSION_ID%TYPE;


BEGIN

  l_module_name := 'DELETE_DISCUSSIONS';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Entered procedure = ' || l_module_name ||
                 ' p_auction_header_id = ' || p_auction_header_id);
  END IF;

  BEGIN
    SELECT discussion_id
    INTO l_discussion_id
    FROM pon_discussions
    WHERE pk1_value  = p_auction_header_id;

    EXCEPTION WHEN NO_DATA_FOUND THEN
      RETURN;
  END;

  --delete from PON_TE_RECIPIENTS
      DELETE FROM
        PON_TE_RECIPIENTS
      WHERE
        ENTRY_ID IN ( SELECT ENTRY_ID
	              FROM PON_THREAD_ENTRIES
	              WHERE DISCUSSION_ID = l_discussion_id);

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'PON_TE_RECIPIENTS records deleted');
      END IF;

  --delete from PON_TE_VIEW_AUDIT
      DELETE FROM
        PON_TE_VIEW_AUDIT
      WHERE
        ENTRY_ID IN ( SELECT ENTRY_ID
	              FROM PON_THREAD_ENTRIES
	              WHERE DISCUSSION_ID = l_discussion_id);

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string (log_level => FND_LOG.level_statement,
          module => g_module_prefix || l_module_name,
          message => 'PON_TE_VIEW_AUDIT records deleted');
      END IF;

      DELETE FROM
          PON_THREAD_ENTRIES
      WHERE
          DISCUSSION_ID = l_discussion_id;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'PON_THREAD_ENTRIES  records deleted');
      END IF;

      DELETE FROM
          PON_THREADS
      WHERE
          DISCUSSION_ID = l_discussion_id;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'PON_THREADS  records deleted');
      END IF;

      DELETE FROM
          PON_DISCUSSIONS
      WHERE
          DISCUSSION_ID = l_discussion_id;

      IF (FND_LOG.level_statement >= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string (log_level => FND_LOG.level_statement,
            module => g_module_prefix || l_module_name,
            message => 'PON_DISCUSSIONS  records deleted');
      END IF;

  IF (FND_LOG.level_procedure >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string (log_level => FND_LOG.level_procedure,
      module => g_module_prefix || l_module_name,
      message => 'Leaving procedure = ' || l_module_name);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

    IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string (log_level => FND_LOG.level_exception,
        module => g_module_prefix || l_module_name,
        message => 'Unexpected exception occured error_code = ' ||
                  x_error_code || ', error_message = ' || x_error_message);
    END IF;
END DELETE_DISCUSSIONS;

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
  x_last_line_close_date out nocopy date
  )
	is
	   l_line_number                    PON_NEG_COPY_DATATYPES_GRP.NUMBER_TYPE;
	   l_close_date                     PON_NEG_COPY_DATATYPES_GRP.SIMPLE_DATE_TYPE;
	   l_group_type                     PON_NEG_COPY_DATATYPES_GRP.VARCHAR100_TYPE;
	   l_batch_start NUMBER ;
	   l_batch_end NUMBER ;
	   l_batch_size NUMBER ;
	   l_max_line_number NUMBER;
	   l_curr_close_date DATE;
	   l_stag_interval NUMBER;

	BEGIN
        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
            message  => 'Entered PON_NEGOTIATION_HELPER_PVT.UPDATE_LINES_CLOSE_DATES'
                        || ', p_auction_header_id = ' || p_auction_header_id
                        || ', p_first_line_close_date = ' || p_first_line_close_date
                        || ', p_staggered_closing_interval = ' || p_staggered_closing_interval
                        || ', p_start_disp_line_number = ' || p_start_disp_line_number
            );
        END IF;

        x_result := FND_API.G_RET_STS_UNEXP_ERROR;

	      SELECT max(disp_line_number)
	      INTO l_max_line_number
	      FROM pon_auction_item_prices_all WHERE auction_header_id = p_auction_header_id;

        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
          message  => 'l_max_line_number : ' || l_max_line_number
          );
        END IF;

       IF (l_max_line_number) > 0 then --{

          IF (p_start_disp_line_number > l_max_line_number) THEN --{

            IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
              message  => 'p_start_disp_line_number > l_max_line_number; so returning'
              );
            END IF;

            select nvl (max(close_bidding_date), p_first_line_close_date)
            into x_last_line_close_date
            from pon_auction_item_prices_all
            where auction_header_id = p_auction_header_id;

            return;
          END IF; --}

          l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;
          l_stag_interval := p_staggered_closing_interval/1440;

          select nvl (max(close_bidding_date), (p_first_line_close_date - l_stag_interval))
          into l_curr_close_date
          from pon_auction_item_prices_all
          where auction_header_id = p_auction_header_id
          and disp_line_number < p_start_disp_line_number;

          --we offset the current close date back by the staggered interval
          --so that the close date of the first line/lot/group is set the the
          --first line close date in the loop

          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
            message  => 'l_batch_size : ' || l_batch_size
                      ||'; l_stag_interval : ' || l_stag_interval
                      ||'; l_curr_close_date : ' || to_char (l_curr_close_date, 'dd-mon-yyyy hh24:mi:ss')
            );
          END IF;

          -- Define the initial batch range (line numbers are indexed from 1)
          l_batch_start := p_start_disp_line_number;

          IF (l_max_line_number <l_batch_size) THEN
             l_batch_end := l_max_line_number;
          ELSE
          -- The batch end has to take into account the batch start too
          --So we need to translate the batch end based on batch start
             l_batch_end := l_batch_start + l_batch_size - 1;
          END IF;

          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
            message  => 'Finished setting the batching loop limits; l_batch_start : '||l_batch_start
            ||'; l_batch_end : ' || l_batch_end
            );
          END IF;

          WHILE (l_batch_start <= l_max_line_number)
          LOOP

              IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
              FND_LOG.string(log_level => FND_LOG.level_statement,
                module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
                message  => 'Processing the batch from l_batch_start : ' || l_batch_start
                            ||' to l_batch_end : ' || l_batch_end || ' ;  bulk collecting the records now'
                );
              END IF;

              select line_number, close_bidding_date, group_type
              bulk collect into
               l_line_number, l_close_date, l_group_type
              from pon_auction_item_prices_all
              WHERE auction_header_id = p_auction_header_id
              AND disp_line_number >= l_batch_start
              AND disp_line_number <= l_batch_end
              order by disp_line_number;

              IF l_line_number.COUNT <> 0 THEN

                IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(log_level => FND_LOG.level_statement,
                      module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
                      message  => 'setting up the close dates array'
                      );
                END IF;

                FOR x IN 1..l_line_number.COUNT
                LOOP
                 IF l_group_type(x) IN ('LINE','LOT','GROUP') THEN
                    l_curr_close_date := l_curr_close_date + l_stag_interval;
                 END IF;
                 l_close_date(x) := l_curr_close_date;
                END LOOP;

                x_last_line_close_date := l_close_date(l_line_number.COUNT);

                IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(log_level => FND_LOG.level_statement,
                      module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
                      message  => 'Last close date for this batch is x_last_line_close_date : '  || to_char (x_last_line_close_date, 'dd-mon-yyyy hh24:mi:ss')
                                   ||'; now bulk updating the PON_AUCTION_ITEM_PRICES_ALL'
                      );
                END IF;

                FORALL x IN 1..l_line_number.COUNT
                 UPDATE PON_AUCTION_ITEM_PRICES_ALL
                  set close_bidding_date = l_close_date(x)
                 WHERE auction_header_id = p_auction_header_id
                 AND line_number = l_line_number(x);

                IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(log_level => FND_LOG.level_statement,
                      module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
                      message  => 'Committing the batch now'
                      );
                END IF;

                COMMIT;

                IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(log_level => FND_LOG.level_statement,
                      module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
                      message  => 'Updating the batch limits for next iteration'
                      );
                END IF;

                l_batch_start := l_batch_end + 1;

                IF (l_batch_end + l_batch_size > l_max_line_number) THEN
                    l_batch_end := l_max_line_number;
                ELSE
                    l_batch_end := l_batch_end + l_batch_size;
                END IF;

                IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                    FND_LOG.string(log_level => FND_LOG.level_statement,
                      module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
                      message  => 'New limits are l_batch_start : ' || l_batch_start
                                 || '; l_batch_end : ' || l_batch_end
                      );
                END IF;

              END IF;

            END LOOP;

          ELSE
            x_last_line_close_date := p_first_line_close_date;
          END IF; --}
          x_result := FND_API.G_RET_STS_SUCCESS;

          IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
            FND_LOG.string(log_level => FND_LOG.level_statement,
              module  =>  g_module_prefix || 'UPDATE_STAG_LINES_CLOSE_DATES',
              message  => 'Exitting the method with '
                          || 'x_last_line_close_date : '||x_last_line_close_date
                          || '; x_result : '||x_result
                          || '; x_error_code : '||x_error_code
                          || '; x_error_message : '||x_error_message
              );
          END IF;
	END;


/*======================================================================
 * FUNCTION :  COUNT_LINES_LOTS_GROUPS    PUBLIC
 * PARAMETERS:
 *     p_auction_header_id         IN      header id of the auction
 *
 * COMMENT   : returns the count of LINES, LOTS and GROUPS in the
 *  negotiation
 *======================================================================*/

FUNCTION COUNT_LINES_LOTS_GROUPS (p_auction_header_id  IN NUMBER) RETURN NUMBER
IS
l_lines_lots_groups_count NUMBER := -1;
BEGIN

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'COUNT_LINES_LOTS_GROUPS',
      message  => 'Entered the procedure COUNT_LINES_LOTS_GROUPS; p_auction_header_id : ' || p_auction_header_id );
  END IF;


  SELECT Count(1) into l_lines_lots_groups_count
  FROM pon_auction_item_prices_all
  WHERE group_type IN ('LINE', 'LOT', 'GROUP')
        AND auction_header_id = p_auction_header_id;

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_SEARCH_MIN_DISP_LINE_NUM',
      message  => 'Exitting the procedure COUNT_LINES_LOTS_GROUPS; l_lines_lots_groups_count : ' || l_lines_lots_groups_count );
  END IF;

  RETURN l_lines_lots_groups_count;

END;


/*======================================================================
 * FUNCTION :  GET_PO_AUTHORIZATION_STATUS    PUBLIC
 * PARAMETERS:
 * p_document_id          IN      po header id
 * p_document_type        IN      the PO document type ('PO'/'PA')
 * p_document_subtype     IN      PO subdoctype id
 *
 * COMMENT   : returns the authorization status of PO
 *
 *======================================================================*/

FUNCTION GET_PO_AUTHORIZATION_STATUS (
  p_document_id          IN      VARCHAR2 ,
  p_document_type        IN      VARCHAR2 ,
  p_document_subtype     IN      VARCHAR2
) RETURN VARCHAR2
IS
v_return_status VARCHAR2(1);
v_po_auth_status PO_LOOKUP_CODES.displayed_field%TYPE;
BEGIN

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_PO_AUTHORIZATION_STATUS',
      message  => 'Entered the procedure GET_PO_AUTHORIZATION_STATUS; p_document_id : ' || p_document_id
                    || '; p_document_type : ' || p_document_type
                    || '; p_document_subtype : ' || p_document_subtype);
  END IF;

  -- The below if block is for safety and gracefule behaviour of the function
  -- The p_document_id cannot be null
  -- If the p_document_type is null, it means it's an RFI for whihc a PO cannot be created
  -- in this case we return null as the status of the PO

  IF (p_document_id is null OR --This case cannot happen
  p_document_type is null -- this means it's an RFI
  ) THEN
      IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'GET_PO_AUTHORIZATION_STATUS',
          message  => 'Returning null because either p_document_id or p_document_type is null');
      END IF;
      return null;
  END IF;

  PO_CORE_S.get_document_status(
       p_document_id          => p_document_id,
       p_document_type        => p_document_type,
       p_document_subtype     => p_document_subtype,
       x_return_status        => v_return_status,
       x_document_status      => v_po_auth_status
  );

  IF ( v_return_status <> 'S' ) THEN
      IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
        FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || 'GET_PO_AUTHORIZATION_STATUS',
          message  => 'Returning null because either x_return_status : ' || v_return_status);
      END IF;
      return null;
  END IF;

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_PO_AUTHORIZATION_STATUS',
      message  => 'Exitting the procedure GET_PO_AUTHORIZATION_STATUS; v_return_status : ' || v_return_status
                   || '; v_po_auth_status : ' || v_po_auth_status);
  END IF;

  RETURN v_po_auth_status;

END GET_PO_AUTHORIZATION_STATUS;

/*======================================================================
 * PROCEDURE : HAS_PRICE_TIERS
 * PARAMETERS:  1. x_result - return status.
 *              2. x_error_code - error code
 *              3. x_error_message - The actual error message
 *              4. p_auction_header_id - The auction header id
 *   	        5. x_has_price_tiers - flag to indicate if negotiation has price tiers or not
 * COMMENT : It takes auction header id as the in parameter and returns Y if there is a line with price
 *              tier, for this auction,. If there is no such line it returns N.
 *======================================================================*/

PROCEDURE HAS_PRICE_TIERS (
  x_result OUT NOCOPY VARCHAR2,
  x_error_code OUT NOCOPY VARCHAR2,
  x_error_message OUT NOCOPY VARCHAR2,
  p_auction_header_id IN NUMBER,
  x_has_price_tiers OUT NOCOPY VARCHAR2
) IS

l_module_name VARCHAR2 (30);

BEGIN

l_module_name := 'has_price_tiers';
x_result := FND_API.g_ret_sts_success;
x_has_price_tiers := 'Y';

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Entered the procedure HAS_PRICE_TIERS; p_auction_header_id : ' || p_auction_header_id);
  END IF;

  BEGIN
    --
    -- Check for the existence of a row in the shipments table, for
    -- the given auction header id
    --

    SELECT
      'Y'
    INTO
      x_has_price_tiers
    FROM
      pon_auction_shipments_all
    WHERE
      auction_header_id = p_auction_header_id AND
      rownum = 1;

    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
	 FND_LOG.string(log_level => FND_LOG.level_statement,
		module  =>  g_module_prefix || l_module_name,
		      message  => 'x_has_price_tiers' || x_has_price_tiers);
    END IF;

    EXCEPTION
      WHEN NO_DATA_FOUND THEN

      --
      --There are no shipments for the auction, so set the return value to N
      --

      x_has_price_tiers := 'N';
            IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
	  FND_LOG.string(log_level => FND_LOG.level_statement,
	      module  =>  g_module_prefix || 'HAS_PRICE_TIERS',
	      message  => 'No shipments for auction; x_has_price_tiers' || x_has_price_tiers);
     END IF;
  END;

EXCEPTION
  WHEN OTHERS THEN
    --
    --If there are any other exceptions in the code, report them to the caller
    --
    x_result := FND_API.g_ret_sts_unexp_error;
    x_error_code := SQLCODE;
    x_error_message := SUBSTR(SQLERRM, 1, 100);

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'HAS_PRICE_TIERS',
      message  => 'EXCEPTION ; x_error_code' || x_error_code  || ' and  x_error_message : ' || x_error_message);
  END IF;


  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Returning to the caller with x_has_price_tiers: '|| x_has_price_tiers );
  END IF;

END has_price_tiers;


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
 ) IS

l_module_name VARCHAR2 (30);
l_max_line_number NUMBER;
l_batch_size NUMBER;
l_batch_start NUMBER;
l_batch_end NUMBER;
l_parent_auc_max_line_number NUMBER;

l_prev_price_tiers_indicator PON_AUCTION_HEADERS_ALL.PRICE_TIERS_INDICATOR%TYPE;
l_amendment_number PON_AUCTION_HEADERS_ALL.AMENDMENT_NUMBER%TYPE;
l_round_number PON_AUCTION_HEADERS_ALL.AUCTION_ROUND_NUMBER%TYPE;


l_is_new_amendment BOOLEAN;
l_is_amendment BOOLEAN;
l_is_new_round BOOLEAN;

BEGIN

  l_module_name := 'handle_change_price_tiers';
  x_result := FND_API.g_ret_sts_success;

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Entered the procedure ; p_auction_header_id : ' || p_auction_header_id || ' ; p_delete_price_tiers : '|| p_delete_price_tiers);
  END IF;
   --
   -- retrieve the price tier indicator, amendment number , new round number for the auction
   --
  SELECT price_tiers_indicator,
         amendment_number,
         auction_round_number
  INTO l_prev_price_tiers_indicator,
       l_amendment_number,
       l_round_number
  FROM pon_auction_headers_all
  WHERE auction_header_id = p_auction_header_id;

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'l_prev_price_tiers_indicator : ' || l_prev_price_tiers_indicator);
  END IF;

  --
  -- retrieve the maximum line number present for the auction
  --
  SELECT MAX(LINE_NUMBER)
  INTO l_max_line_number
  FROM PON_AUCTION_ITEM_PRICES_ALL
  WHERE AUCTION_HEADER_ID=p_auction_header_id;

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'l_max_line_number : ' || l_max_line_number || '; l_amendment_number : ' || l_amendment_number
                  || ' ; l_round_number : ' || l_round_number);
  END IF;


  IF (p_delete_price_tiers = 'Y') THEN--{

      --
      --Check if the auction is an amendment or new round.
      --If yes, fetch the max line number of the previous round.
      --
      IF (l_amendment_number > 0) THEN

        --this is an amendment
        l_is_amendment := true;
        SELECT max_internal_line_num
        INTO l_parent_auc_max_line_number
        FROM pon_auction_headers_all
        WHERE auction_header_id =
            (SELECT auction_header_id_prev_amend
        FROM pon_auction_headers_all
        WHERE auction_header_id = p_auction_header_id);

        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || l_module_name,
            message  => 'Neg is Amendment ; l_parent_auc_max_line_number : '  || l_parent_auc_max_line_number);
        END IF;


      ELSIF (l_round_number > 1) THEN
        --this is an new round
        l_is_new_round := true;
        SELECT max_internal_line_num
        INTO l_parent_auc_max_line_number
        FROM pon_auction_headers_all
        WHERE auction_header_id =
           (SELECT auction_header_id_prev_round
            FROM pon_auction_headers_all
            WHERE auction_header_id = p_auction_header_id);

        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
          FND_LOG.string(log_level => FND_LOG.level_statement,
            module  =>  g_module_prefix || l_module_name,
            message  => 'This is new round ' || '; l_parent_auc_max_line_number : '|| l_parent_auc_max_line_number);
        END IF;

      END IF;
  END IF; --}

  -- Get the batch size
  l_batch_size := PON_LARGE_AUCTION_UTIL_PKG.BATCH_SIZE;

  -- Draft with no lines, or RFI,CPA with no lines we need to skip batching
  -- its build into the loop logic but just to be explicit about this condition

  IF (l_max_line_number > 0) THEN --{

    -- Define the initial batch range (line numbers are indexed from 1)
    l_batch_start := 1;

    IF (l_max_line_number <= l_batch_size) THEN
        l_batch_end := l_max_line_number;
    ELSE
        l_batch_end := l_batch_size;
    END IF;

    IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
      FND_LOG.string(log_level => FND_LOG.level_statement,
        module  =>  g_module_prefix || l_module_name,
        message  => 'l_batch_size : ' || l_batch_size || '; l_batch_end : '
                    || l_batch_end);
    END IF;

    WHILE (l_batch_start <= l_max_line_number) LOOP

        --
        --default the price break settings if price tiers indicator has been changed from price breaks
        --
        IF (l_prev_price_tiers_indicator = 'PRICE_BREAKS') THEN --{

            IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
              FND_LOG.string(log_level => FND_LOG.level_statement,
                    module  =>  g_module_prefix || l_module_name,
                    message  => 'Price tier indicator has chnaged from ' || l_prev_price_tiers_indicator ||' ; updating the pon_auction_item_prices_all, setting price_break_type to NONE and price_break_neg_flag to Y');
             END IF;

            UPDATE pon_auction_item_prices_all
            SET price_break_type = 'NONE',
                price_break_neg_flag = 'Y'
            WHERE auction_header_id = p_auction_header_id
                AND line_number >= l_batch_start
                AND line_number <= l_batch_end;

        END IF; --}

        IF (p_delete_price_tiers = 'Y') THEN--{
            --
            -- Delete the entries from the shipments table for this auction
            --
            IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                  FND_LOG.string(log_level => FND_LOG.level_statement,
                     module  =>  g_module_prefix || l_module_name,
                    message  => 'Deleting the entries from the shipments table for negotiation ' || p_auction_header_id
                            || ' and line_number between ' || l_batch_start ||' and ' || l_batch_end );
            END IF;

            DELETE FROM
                pon_auction_shipments_all
            WHERE
                auction_header_id = p_auction_header_id AND
                line_number >= l_batch_start AND
                line_number <= l_batch_end;

            --
            --Delete the child differentials for the above deleted shipments
            -- only if they are price breaks. We won't have differential children
            --for quantity based tiers
            --

            IF (l_prev_price_tiers_indicator = 'PRICE_BREAKS') THEN

                  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                  FND_LOG.string(log_level => FND_LOG.level_statement,
                    module  =>  g_module_prefix || l_module_name,
                    message  => 'Deleting the child differentials for negotiation ' || p_auction_header_id
                    || ' and line_number between ' || l_batch_start ||' and ' || l_batch_end );
                END IF;

                DELETE FROM
                    pon_price_differentials
                WHERE
                    auction_header_id = p_auction_header_id AND
                    shipment_number > -1 AND
                    line_number >= l_batch_start AND
                    line_number <= l_batch_end;

            END IF;

            --
            --Check if the auction is a new round or an amendment. in that case,
            --we need to mark all the lines with price tiers (having rows in
            --PON_AUCTION_SHIPMENTS_ALL table) from the previous/parent auction
            --as modified and set the flag has_price_tiers as 'N'.
            --
            IF (l_is_new_round OR l_is_new_amendment) THEN

                  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                      FND_LOG.string(log_level => FND_LOG.level_statement,
                    module  =>  g_module_prefix || l_module_name,
                    message  => 'Negotiation is  a new round or an amendment. Updating flags modified_flag and  has_quantity_tiers');
                  END IF;

                  --
                  --Only those lines which were present in previous round or previous
                  --amendment we need to set the modified_flag.
                  --

                  UPDATE pon_auction_item_prices_all
                  SET has_quantity_tiers = 'N',
                      has_shipments_flag = 'N',
                      modified_flag = decode(least(line_number,l_parent_auc_max_line_number),
                               line_number,'Y', modified_flag),
                      modified_date = SYSDATE
                  WHERE
                    auction_header_id = p_auction_header_id AND
                    (has_quantity_tiers = 'Y' OR has_shipments_flag = 'Y') AND
                    line_number >= l_batch_start AND
                    line_number <= l_batch_end;

            ELSE

              IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
                 FND_LOG.string(log_level => FND_LOG.level_statement,
                    module  =>  g_module_prefix || l_module_name,
                    message  => 'Negotiation is  a not new round or an amendment. Updating has_quantity_tiers flag');
              END IF;

              UPDATE pon_auction_item_prices_all
              SET has_quantity_tiers = 'N',
                  has_shipments_flag = 'N'
              WHERE
                 auction_header_id = p_auction_header_id AND
                (has_quantity_tiers = 'Y' OR has_shipments_flag = 'Y') AND
                 line_number >= l_batch_start AND
                 line_number <= l_batch_end;

            END IF; --new round or amendment

        END IF; --} --p_delete_price_tiers = 'Y'

        -- Find the new batch range
        l_batch_start := l_batch_end + 1;
        IF (l_batch_end + l_batch_size > l_max_line_number) THEN
           l_batch_end := l_max_line_number;
        ELSE
           l_batch_end := l_batch_end + l_batch_size;
        END IF;

        IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
               FND_LOG.string(log_level => FND_LOG.level_statement,
                 module  =>  g_module_prefix || l_module_name,
                 message  => 'New Batch  with l_batch_start' || l_batch_start  || ' and  l_batch_end : ' || l_batch_end);
        END IF;

        -- Issue a commit to push in all changes
        COMMIT;
    END LOOP;

  END IF; --}

  EXCEPTION
   WHEN OTHERS THEN
     x_result := FND_API.g_ret_sts_unexp_error;
     x_error_code := SQLCODE;
     x_error_message := SUBSTR(SQLERRM, 1, 100);

     IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
       FND_LOG.string(log_level => FND_LOG.level_statement,
          module  =>  g_module_prefix || l_module_name,
         message  => 'EXCEPTION ; x_error_code' || x_error_code  || ' and  x_error_message : ' || x_error_message);
     END IF;


  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || l_module_name,
      message  => 'Returning to the caller');
  END IF;
END HANDLE_CHANGE_PRICE_TIERS;

--Bug 6074506
/*======================================================================
 * FUNCTION :  GET_ABBR_DOC_TYPE_GRP_NAME    PUBLIC
 * PARAMETERS:
 *    p_doctype_id         IN      document type id of the auction
 *
 * COMMENT   : returns the document froup name in English language
 *
 *======================================================================*/

FUNCTION GET_ABBR_DOC_TYPE_GRP_NAME (p_doctype_id  IN NUMBER) RETURN VARCHAR2
IS
v_doctype_name pon_auc_doctypes_tl.name%TYPE;

BEGIN

  IF (FND_LOG.level_statement>= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_statement,
      module  =>  g_module_prefix || 'GET_ABBR_DOC_TYPE_GRP_NAME',
      message  => 'Entered the procedure GET_ABBR_DOC_TYPE_GRP_NAME; p_doctype_id : ' || p_doctype_id);
  END IF;

  SELECT name
  INTO
  v_doctype_name
  FROM
  pon_auc_doctypes_tl
  WHERE
  doctype_id = p_doctype_id and
  language = 'US';

  return v_doctype_name;

  EXCEPTION WHEN NO_DATA_FOUND THEN

  v_doctype_name := NULL;

  IF (FND_LOG.level_exception >= FND_LOG.g_current_runtime_level) THEN
    FND_LOG.string(log_level => FND_LOG.level_exception,
      module  =>  g_module_prefix || 'GET_ABBR_DOC_TYPE_GRP_NAME',
      message  => 'Exception in PON_NEGOTIATION_HELPER_PVT.GET_ABBR_DOC_TYPE_GRP_NAME '
                  || 'errnum = ' || SQLCODE || ', errmsg = ' || SUBSTR (SQLERRM, 1, 200));
  END IF;

  return v_doctype_name;

END GET_ABBR_DOC_TYPE_GRP_NAME;

END PON_NEGOTIATION_HELPER_PVT;

/
