--------------------------------------------------------
--  DDL for Package Body ARP_TAX_STR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ARP_TAX_STR_PKG" AS
/* $Header: ARTXSTRB.pls 115.1 2002/08/30 00:54:28 cleyvaol ship $ */

g_segments_array_min       FND_FLEX_EXT.SegmentArray;
g_segments_array_max       FND_FLEX_EXT.SegmentArray;

TYPE ccid_inrange IS TABLE OF varchar2(1)
  INDEX BY BINARY_INTEGER;

g_ccid_inrange ccid_inrange;

/* =======================================================================|
 | PROCEDURE initialize
 |
 | DESCRIPTION
 |      Initilize the arrays to hold the segments of range of accounts
 |      given. This will be held by two array during the same session
 |      to do not recalculate them every time the function
 |      get_ccid_inrange_flag is called.
 |
 | PARAMETERS
 |      p_min_gl_flex  IN  VARCHAR2. String containg the min range of
 |                                   accounts given.
 |      p_max_gl_flex  IN  VARCHAR2. String containg the max range of
 |                                   accounts given.
 *========================================================================*/
PROCEDURE initialize(p_min_gl_flex VARCHAR2,
                     p_max_gl_flex VARCHAR2) IS

l_segments_delimiter VARCHAR2(1) := null;
l_number_segs        NUMBER;

BEGIN

  --
  -- GET THE DELIMITER
  --
  l_segments_delimiter := FND_FLEX_EXT.GET_DELIMITER('SQLGL','GL#',101);

  --
  -- OBTAIN THE ARRAYS WITH THE SEGMENTS FOR EACH STRING
  --
  l_number_segs := FND_FLEX_EXT.BREAKUP_SEGMENTS(p_min_gl_flex ,l_segments_delimiter,g_segments_array_min);
  l_number_segs := FND_FLEX_EXT.BREAKUP_SEGMENTS(p_max_gl_flex ,l_segments_delimiter,g_segments_array_max);

END initialize;

/* =======================================================================
 | FUNCTION get_credit_memo_trx_number
 |
 | DESCRIPTION
 |      Returns the transaction number for the credit memo.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_previous_customer_trx_id  IN  Transaction to wich the Credit
 |                                      Memo is refering.
 |
 *======================================================================*/
FUNCTION get_credit_memo_trx_number(p_previous_customer_trx_id  IN NUMBER)
          RETURN VARCHAR IS

l_trx_number ra_customer_trx_all.trx_number%TYPE := null;

BEGIN
  IF p_previous_customer_trx_id IS NOT NULL THEN
    BEGIN
      Select trx_number
      into   l_trx_number
      from   ra_customer_trx_all
      where  customer_trx_id = p_previous_customer_trx_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN TOO_MANY_ROWS THEN
        NULL;
      WHEN OTHERS THEN
        NULL;
    END;
  END IF;
  RETURN l_trx_number;
END get_credit_memo_trx_number;

/* ==========================================================================
 | FUNCTION get_credit_memo_trx_date
 |
 | DESCRIPTION
 |      Returns the transaction date for the credit memo.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_previous_customer_trx_id  IN  Transaction to wich the Credit Memo is
 |                               refering.
 *==========================================================================*/
FUNCTION  get_credit_memo_trx_date(p_previous_customer_trx_id  IN NUMBER ) RETURN DATE IS

l_trx_date ra_customer_trx_all.trx_date%TYPE := null;

BEGIN
  IF p_previous_customer_trx_id IS NOT NULL THEN
    BEGIN
      Select trx_date
      into   l_trx_date
      from   ra_customer_trx_all
      where  customer_trx_id = p_previous_customer_trx_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        NULL;
      WHEN TOO_MANY_ROWS THEN
        NULL;
      WHEN OTHERS THEN
        NULL;
    END;
  END IF;
  RETURN l_trx_date;
END get_credit_memo_trx_date;


/* =========================================================================
 | FUNCTION get_ccid_inrange_flag
 |
 | DESCRIPTION
 |      Returns the transaction date for the credit memo.
 |
 | SCOPE - PUBLIC
 |
 | PARAMETERS
 |      p_code_combination_id         IN Code Combination Id to identify if
 |                                       it is in the range of the segments
 |                                       given.
 |      p_array_min_gl_flex,
 |      p_array_max_gl_flex           IN Array of segments that define
 |                                       the range to evaluate for the CCID.
 *==========================================================================*/
FUNCTION  get_ccid_inrange_flag(p_code_combination_id   IN NUMBER
                                ) RETURN VARCHAR2 IS

l_segments_array     FND_FLEX_EXT.SegmentArray;
l_number_segs        NUMBER;
l_segments_found     BOOLEAN;

BEGIN
  IF NOT(g_ccid_inrange.EXISTS(p_code_combination_id)) THEN
    --
    -- GET THE ARRAY OF SEGMENTS OF THE CODE COMBINATION ID
    --

    l_segments_found :=FND_FLEX_EXT.GET_SEGMENTS('SQLGL','GL#',101,p_code_combination_id,l_number_segs,l_segments_array);
    g_ccid_inrange(p_code_combination_id) := 'N';

    --
    -- EVALUATE IF THE CCID IS IN THE SEGMENT RANGE GIVEN
    --
    FOR i in 1..l_number_segs LOOP
      IF l_segments_array(i) not between g_segments_array_min(i) and g_segments_array_max(i) THEN
        RETURN 'N';
      END IF;
    END LOOP;

    g_ccid_inrange(p_code_combination_id) := 'Y';
    RETURN 'Y';
  ELSE
    RETURN g_ccid_inrange(p_code_combination_id);
  END IF;

END get_ccid_inrange_flag;

END ARP_TAX_STR_PKG;

/
