--------------------------------------------------------
--  DDL for Package Body PO_CORE_S2
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CORE_S2" AS
/* $Header: POXCOC2B.pls 120.5.12010000.2 2012/08/16 15:00:52 ksrimatk ship $*/


/*===========================================================================
 Private package variables
===========================================================================*/
-- Logging/debugging
g_pkg_name	CONSTANT 	VARCHAR2(30) := 'PO_CORE_S2';
g_log_head	CONSTANT	VARCHAR2(50) :=
				   'po.plsql.' || g_pkg_name || '.';
g_debug_stmt	BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp	BOOLEAN := PO_DEBUG.is_debug_unexp_on;




/*===========================================================================
  PROCEDURE NAME: GET_REQ_CURRENCY
===========================================================================*/
PROCEDURE GET_REQ_CURRENCY (x_object_id       IN NUMBER,
                            x_base_currency  OUT NOCOPY VARCHAR2 ,
                            p_org_id          IN NUMBER) IS --bug#5092574
  x_progress      VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;
    --bug#5092574 Use the doc_org_id to join with FSP to retrieve the
    --Req Currency
  SELECT GSB.currency_code
  INTO   x_base_currency
  FROM   FINANCIALS_SYSTEM_PARAMETERS FSP,
         GL_SETS_OF_BOOKS GSB
  WHERE  FSP.set_of_books_id = GSB.set_of_books_id
     AND FSP.ORG_ID=p_org_id;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END GET_REQ_CURRENCY;

/*===========================================================================
  PROCEDURE NAME: GET_CURRENCY_INFO
===========================================================================*/
PROCEDURE GET_CURRENCY_INFO (x_currency_code IN VARCHAR2,
                             x_precision    OUT NOCOPY NUMBER,
                             x_min_unit     OUT NOCOPY NUMBER ) is
  x_ext_precision NUMBER;
  x_progress      VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;

  fnd_currency.get_info(x_currency_code,
                        x_precision,
                        x_ext_precision,
                        x_min_unit );

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END GET_CURRENCY_INFO;
/*===========================================================================
  PROCEDURE NAME: GET_CURRENCY_INFO_DETAILS
===========================================================================*/
PROCEDURE GET_CURRENCY_INFO_DETAILS (p_currency_code IN VARCHAR2,
                             x_precision    OUT NOCOPY NUMBER,
                             x_ext_precision    OUT NOCOPY NUMBER,
                             x_min_unit     OUT NOCOPY NUMBER ) is

  x_progress      VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;

  fnd_currency.get_info(p_currency_code,
                        x_precision,
                        x_ext_precision,
                        x_min_unit );

  x_ext_precision := Nvl(x_ext_precision,Nvl(x_precision,5));
  IF x_min_unit IS NULL AND x_precision IS NULL THEN
    x_precision := 2;
  END IF;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END GET_CURRENCY_INFO_DETAILS;

/*===========================================================================
  PROCEDURE NAME: GET_PO_CURRENCY
===========================================================================*/
PROCEDURE GET_PO_CURRENCY (x_object_id      IN NUMBER,
                           x_base_currency OUT NOCOPY VARCHAR2,
                           x_po_currency   OUT NOCOPY VARCHAR2) is
  x_progress      VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;

  SELECT GSB.currency_code,
         POH.currency_code
  INTO   x_base_currency,
         x_po_currency
  FROM   PO_HEADERS_ALL POH,    -- Bug 3012328 (Changed to all table so that this does not fail for GA's)
         FINANCIALS_SYSTEM_PARAMS_ALL FSP,  -- Bug 5221311 Changed to all table
         GL_SETS_OF_BOOKS GSB
  WHERE  POH.po_header_id    = x_object_id
  AND    FSP.set_of_books_id = GSB.set_of_books_id
  AND    FSP.org_id          = POH.org_id; --< R12 MOAC>

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END GET_PO_CURRENCY;

--<R12 MOAC START>
FUNCTION get_base_currency(p_org_id po_system_parameters_all.org_id%TYPE)
return VARCHAR2 IS
	x_currency_code           gl_sets_of_books.currency_code%TYPE;
BEGIN

     SELECT gsb.currency_code
     INTO   x_currency_code
     FROM   financials_system_params_all fsp,
            gl_sets_of_books gsb
     WHERE  fsp.set_of_books_id = gsb.set_of_books_id
       AND  fsp.org_id          = p_org_id;

     return(x_currency_code);

END get_base_currency;
--<R12 MOAC END>
/*===========================================================================

  PROCEDURE NAME:       get_base_currency

===========================================================================*/

FUNCTION get_base_currency return VARCHAR2 IS
	x_currency_code                   VARCHAR2(30):= '';
BEGIN

     SELECT GSB.currency_code
     INTO   x_currency_code
     FROM   FINANCIALS_SYSTEM_PARAMETERS FSP,
            GL_SETS_OF_BOOKS GSB
     WHERE  FSP.set_of_books_id = GSB.set_of_books_id;

    return(x_currency_code);

EXCEPTION
    WHEN OTHERS THEN
	RAISE;
END;

/*===========================================================================
  PROCEDURE NAME: GET_PO_CURRENCY_INFO
===========================================================================*/
PROCEDURE GET_PO_CURRENCY_INFO (p_po_header_id      IN NUMBER,
                                x_currency_code     OUT NOCOPY VARCHAR2,
                                x_curr_rate_type    OUT NOCOPY VARCHAR2,
                                x_curr_rate_date    OUT NOCOPY DATE,
                                x_currency_rate     OUT NOCOPY NUMBER) is
  x_progress      VARCHAR2(3) := NULL;
BEGIN
  x_progress := 10;

  IF p_po_header_id is null THEN
    Return;
  END IF;

  SELECT POH.currency_code,
         POH.rate_type,
         POH.rate_date,
         POH.rate
  INTO   x_currency_code,
         x_curr_rate_type,
         x_curr_rate_date,
         x_currency_rate
  FROM   PO_HEADERS_ALL POH
  WHERE  POH.po_header_id    = p_po_header_id;

  EXCEPTION
  WHEN OTHERS THEN
    RAISE;
END GET_PO_CURRENCY_INFO;


--<ENCUMBRANCE FPJ START>
--Added a centralized, bulk routine for currency conversion and rounding
-------------------------------------------------------------------------------
--Start of Comments
--Name: round_and_convert_currency
--Pre-reqs:
--
--Modifies:
--  PO_SESSION_GT
--Locks:
--  None.
--Function:
--  Performs bulk currency conversion and/or currency rounding
--  of the input amounts.
--Parameters:
--IN:
--p_unique_id_tbl  --added for bug 4878973
--  A unique identifier for each row in the passed in table.
--  This is used to ensure the output table ordering is the same
--  as the input table ordering.
--p_amount_in_tbl
--  A table of values that need to be converted/rounded
--p_exchange_rate_tbl
--  A table of numbers that contains the exchange rates if this
--  procedure is being used for currency conversion.
--  Note: even if not doing a currency conversion, this procedure
--  expects this tbl parameter to be the same length as input var
--  p_amount_in_tbl, though it may be filled with NULL values
--p_from_currency_precision_tbl
--  Precision defined for currency of the input amounts (in FND_CURRENCIES).
--  If both from_currency_precision and from_currency_mau are null, then
--  the from_currency is not rounded before conversion to to_currency
--p_to_currency_precision_tbl
--  Precision defined for desired output currency (in FND_CURRENCIES).
--  If both to_currency_precision and to_currency_mau are null, then
--  the to_currency is not rounded after conversion from from_currency.
--p_from_currency_mau_tbl
--  Minimum accountable unit defined for currency of the input amounts
--  (in FND_CURRENCIES).
--  If from_currency_mau is null, from_currency_precision is used.
--  If both from_currency_precision and from_currency_mau are null, then
--  the from_currency is not rounded before conversion to to_currency
--p_to_currency_mau_tbl
--  Minimum accountable unit defined for desired output currency
--  (in FND_CURRENCIES).
--  If to_currency_mau is null, to_currency_precision is used.
--  If both to_currency_precision and to_currency_mau are null, then
--  the to_currency is not rounded after conversion from from_currency.
--p_round_only_flag_tbl
--  If the flag value = 'Y', then skip the currency conversion,
--  but still round the amounts using the to_currency precision/mau.
--  If the flag value = 'N', then perform the currency conversion of amounts
--  using the exchange rate and from_currency precisions/mau,
--  and then round the converted amounts using the to_currency precision/mau.
--  Most callers will pass this as 'N'.
--OUT:
--x_return_status
--  APPS Standard parameter
--  Indicates whether this procedure completed successfully or not
--x_amount_out_tbl
--  A table containing the rounded/converted equivalent of p_amount_in_tbl
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE round_and_convert_currency(
   x_return_status                OUT    NOCOPY VARCHAR2
,  p_unique_id_tbl                IN     PO_TBL_NUMBER  --bug 4878973
,  p_amount_in_tbl                IN     PO_TBL_NUMBER
,  p_exchange_rate_tbl            IN     PO_TBL_NUMBER
,  p_from_currency_precision_tbl  IN     PO_TBL_NUMBER
,  p_from_currency_mau_tbl        IN     PO_TBL_NUMBER
,  p_to_currency_precision_tbl    IN     PO_TBL_NUMBER
,  p_to_currency_mau_tbl          IN     PO_TBL_NUMBER
,  p_round_only_flag_tbl          IN     PO_TBL_VARCHAR1  --bug 3568671
,  x_amount_out_tbl               OUT    NOCOPY PO_TBL_NUMBER
)
IS
   l_api_name  CONSTANT varchar2(40) := 'ROUND_AND_CONVERT_CURRENCY';
   l_log_head  CONSTANT varchar2(100) := g_log_head || l_api_name;
   l_progress  VARCHAR2(3) := '000';

   l_transaction_id NUMBER;

BEGIN

IF g_debug_stmt THEN
   PO_DEBUG.debug_begin(l_log_head);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_unique_id_tbl'
                      ,p_unique_id_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_amount_in_tbl'
                      ,p_amount_in_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_exchange_rate_tbl'
                      ,p_exchange_rate_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_from_currency_precision_tbl'
                      ,p_from_currency_precision_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_from_currency_mau_tbl'
                      ,p_from_currency_mau_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_to_currency_precision_tbl'
                      ,p_to_currency_precision_tbl);
   PO_DEBUG.debug_var(l_log_head,l_progress,'p_to_currency_mau_tbl'
                      ,p_to_currency_mau_tbl);
END IF;

x_return_status := FND_API.g_ret_sts_success;

SELECT PO_SESSION_GT_S.nextval
INTO l_transaction_id
FROM DUAL;

IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,
                      'l_transaction_id', l_transaction_id);
END IF;

l_progress := '010';

FORALL i in 1 .. p_amount_in_tbl.COUNT
   INSERT INTO PO_SESSION_GT TEMP
   (
      key
   ,  num1   --sequence number
   ,  num2   --input amount
   ,  num3   --exchange rate
   ,  num4   --from currency precision
   ,  num5   --from currency MAU
   ,  num6   --to currency precision
   ,  num7   --to currency MAU
   ,  char1  --round only flag (to skip currency convert)
   )
   VALUES
   (
      l_transaction_id
   ,  p_unique_id_tbl(i) --bug 4878973: use this instead of rownum
   ,  p_amount_in_tbl(i)
   ,  NVL(p_exchange_rate_tbl(i), 1)
   ,  p_from_currency_precision_tbl(i)
   ,  p_from_currency_mau_tbl(i)
   ,  p_to_currency_precision_tbl(i)
   ,  p_to_currency_mau_tbl(i)
   ,  NVL(p_round_only_flag_tbl(i), 'N')  --bug 3568671
   )
;

l_progress := '020';

-- First, do a currency conversion if necessary
-- bug 3578482: If both 'from currency' precision and MAU are null,
-- don't round the 'from currency' value in num2 before doing currency conversion.

UPDATE PO_SESSION_GT TEMP
SET TEMP.num2 =
(  DECODE( TEMP.num5

          -- if from MAU is null, use precision
          -- if precision null, don't round at all.
          , NULL, DECODE( temp.num4
                        , NULL, TEMP.num2
                        , round(TEMP.num2, TEMP.num4)
                  )

          -- if MAU not null, use MAU
          , (round (TEMP.num2 / TEMP.num5) * TEMP.num5)
   )
   * TEMP.num3  --exchange rate
)
WHERE TEMP.key = l_transaction_id
   --bug 3568671: do not do this first calculation if the caller
   --has specified to skip the currency conversion step
AND TEMP.char1 = 'N'
;

l_progress := '030';

-- Next, do the rounding using the new currency settings
-- bug 3578482: If both 'to currency' precision and MAU are null,
-- don't round the 'to currency' value in num2 to get num8.

UPDATE PO_SESSION_GT TEMP
SET TEMP.num8 = --output amount
(  DECODE( TEMP.num7

          -- if MAU is null, use precision
          -- if precision null, don't round at all
          , NULL, DECODE( temp.num6
                        , NULL, TEMP.num2
                        , round(TEMP.num2, TEMP.num6)
                  )

          -- if MAU not null, use MAU
          , (round (TEMP.num2 / TEMP.num7) * TEMP.num7)
   )
)
WHERE TEMP.key = l_transaction_id
;


IF g_debug_stmt THEN
   l_progress := '040';
   SELECT rowid BULK COLLECT INTO PO_DEBUG.g_rowid_tbl
   FROM PO_SESSION_GT WHERE key = l_transaction_id;

   PO_DEBUG.debug_table(l_log_head,l_progress,'PO_SESSION_GT',
                        PO_DEBUG.g_rowid_tbl,
                        po_tbl_varchar30('num1','num2','num3',
                                         'num4','num5','num6',
                                         'num7')
   );
END IF;

l_progress := '045';

-- Retrieve the final amount into the output table
SELECT TEMP.num8
BULK COLLECT INTO x_amount_out_tbl
FROM PO_SESSION_GT TEMP
WHERE TEMP.key = l_transaction_id
ORDER BY TEMP.num1;   --input and output tbls have same ordering

l_progress := '050';
IF g_debug_stmt THEN
   PO_DEBUG.debug_var(l_log_head,l_progress,'x_amount_out_tbl'
                      ,x_amount_out_tbl);
   PO_DEBUG.debug_end(l_log_head);
END IF;


EXCEPTION
   WHEN OTHERS THEN
      x_return_status := FND_API.g_ret_sts_unexp_error;

      --add a message to the stack and log a debug message
      po_message_s.sql_error(g_pkg_name, l_api_name,
                             l_progress, SQLCODE, SQLERRM);
      fnd_msg_pub.add;
      IF g_debug_unexp THEN
         PO_DEBUG.debug_exc(
            p_log_head => l_log_head
         ,  p_progress => l_progress
         );
      END IF;
END round_and_convert_currency;
--<ENCUMBRANCE FPJ END>


END PO_CORE_S2;

/
