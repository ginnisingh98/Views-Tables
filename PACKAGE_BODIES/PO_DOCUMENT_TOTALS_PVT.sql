--------------------------------------------------------
--  DDL for Package Body PO_DOCUMENT_TOTALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_DOCUMENT_TOTALS_PVT" AS
-- $Header: PO_DOCUMENT_TOTALS_PVT.plb 120.11.12010000.7 2014/08/22 02:49:35 yuandli ship $
-------------------------------------------------------------------------------
-- Package private constants
-------------------------------------------------------------------------------
-- Debug constants
D_PACKAGE_BASE CONSTANT VARCHAR2(50) :=
  PO_LOG.get_package_base('PO_DOCUMENT_TOTALS_PVT');

-- Shipment type constants
C_ship_type_STANDARD		CONSTANT
   PO_LINE_LOCATIONS_ALL.shipment_type%TYPE
   := PO_CORE_S.g_ship_type_STANDARD;
C_ship_type_PLANNED		CONSTANT
   PO_LINE_LOCATIONS_ALL.shipment_type%TYPE
   := PO_CORE_S.g_ship_type_PLANNED;
C_ship_type_SCHEDULED		CONSTANT
   PO_LINE_LOCATIONS_ALL.shipment_type%TYPE
   := PO_CORE_S.g_ship_type_SCHEDULED;
C_ship_type_BLANKET		CONSTANT
   PO_LINE_LOCATIONS_ALL.shipment_type%TYPE
   := PO_CORE_S.g_ship_type_BLANKET;
C_ship_type_PREPAYMENT		CONSTANT
   PO_LINE_LOCATIONS_ALL.shipment_type%TYPE
   := PO_CORE_S.g_ship_type_PREPAYMENT;

-- Payment type constants
C_payment_type_MILESTONE        CONSTANT
   PO_LINE_LOCATIONS_ALL.payment_type%TYPE
   := PO_CORE_S.g_payment_type_MILESTONE;

C_payment_type_RATE             CONSTANT
   PO_LINE_LOCATIONS_ALL.payment_type%TYPE
   := PO_CORE_S.g_payment_type_RATE;

C_payment_type_LUMPSUM          CONSTANT
   PO_LINE_LOCATIONS_ALL.payment_type%TYPE
   := PO_CORE_S.g_payment_type_LUMPSUM;

-------------------------------------------------------------------------------
-- Spec definitions for private procedures
-------------------------------------------------------------------------------
PROCEDURE do_org_currency_setups(
  p_doc_level IN VARCHAR2
, p_doc_level_id IN NUMBER
, x_currency_precision OUT NOCOPY NUMBER
, x_min_acct_unit OUT NOCOPY NUMBER
);


--TODO: obsolete the following signatures below once impacts to all
--callers of the get_order_totals have been handled:
-- * get_totals
-- * populate_temp_table
-- * prepare_temp_table_data
-- * calculate_totals
-- * clear_temp_table
PROCEDURE get_totals(
  p_doc_type                     IN VARCHAR2,
  p_doc_subtype                  IN VARCHAR2,
  p_doc_level                    IN VARCHAR2,
  p_doc_level_id                 IN NUMBER,
  p_data_source                  IN VARCHAR2,
  p_doc_revision_num             IN NUMBER,
  x_quantity_total               OUT NOCOPY NUMBER,
  x_amount_total                 OUT NOCOPY NUMBER,
  x_quantity_delivered           OUT NOCOPY NUMBER,
  x_amount_delivered             OUT NOCOPY NUMBER,
  x_quantity_received            OUT NOCOPY NUMBER,
  x_amount_received              OUT NOCOPY NUMBER,
  x_quantity_shipped             OUT NOCOPY NUMBER,
  x_amount_shipped               OUT NOCOPY NUMBER,
  x_quantity_billed              OUT NOCOPY NUMBER,
  x_amount_billed                OUT NOCOPY NUMBER,
  x_quantity_financed            OUT NOCOPY NUMBER,
  x_amount_financed              OUT NOCOPY NUMBER,
  x_quantity_recouped            OUT NOCOPY NUMBER,
  x_amount_recouped              OUT NOCOPY NUMBER,
  x_retainage_withheld_amount    OUT NOCOPY NUMBER,
  x_retainage_released_amount    OUT NOCOPY NUMBER
);


PROCEDURE populate_temp_table(
  p_doc_type IN VARCHAR2,
  p_doc_level IN VARCHAR2,
  p_doc_level_id IN NUMBER,
  p_data_source IN VARCHAR2,
  p_doc_revision_num IN NUMBER,
  x_temp_table_key OUT NOCOPY NUMBER,
  x_count OUT NOCOPY NUMBER
);


PROCEDURE prepare_temp_table_data(
  p_temp_table_key  IN  NUMBER,
  p_document_id  IN  NUMBER
);

PROCEDURE calculate_totals(
  p_temp_table_key               IN  NUMBER,
  p_document_id                  IN  NUMBER,
  p_doc_level                    IN  VARCHAR2,
  x_quantity_total               OUT NOCOPY NUMBER,
  x_amount_total                 OUT NOCOPY NUMBER,
  x_quantity_delivered           OUT NOCOPY NUMBER,
  x_amount_delivered             OUT NOCOPY NUMBER,
  x_quantity_received            OUT NOCOPY NUMBER,
  x_amount_received              OUT NOCOPY NUMBER,
  x_quantity_shipped             OUT NOCOPY NUMBER,
  x_amount_shipped               OUT NOCOPY NUMBER,
  x_quantity_billed              OUT NOCOPY NUMBER,
  x_amount_billed                OUT NOCOPY NUMBER,
  x_quantity_financed            OUT NOCOPY NUMBER,
  x_amount_financed              OUT NOCOPY NUMBER,
  x_quantity_recouped            OUT NOCOPY NUMBER,
  x_amount_recouped              OUT NOCOPY NUMBER,
  x_retainage_withheld_amount    OUT NOCOPY NUMBER,
  x_retainage_released_amount    OUT NOCOPY NUMBER
);

PROCEDURE clear_temp_table(
  p_temp_table_key IN NUMBER
);



-------------------------------------------------------------------------------
-- Procedure body definitions
-------------------------------------------------------------------------------


-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountOrdered
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Based on given doc level and id, calculates the total amount ordered
-- for that entity
-- The API supports only Standard POs (both non-CWP and CWP)
--Parameters:
--IN:
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type for which to calculate totals
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountOrdered(
  p_doc_level IN VARCHAR2
, p_doc_level_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountOrdered');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_precision  GL_CURRENCIES.precision%TYPE;
  l_mau  GL_CURRENCIES.minimum_accountable_unit%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_doc_level',p_doc_level);
  PO_LOG.proc_begin(d_mod,'p_doc_level_id',p_doc_level_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

do_org_currency_setups(
  p_doc_level => p_doc_level
, p_doc_level_id => p_doc_level_id
, x_currency_precision => l_precision
, x_min_acct_unit => l_mau
);

d_position := 10;
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'l_precision:',l_precision);
  PO_LOG.stmt(d_mod,d_position,'l_mau:',l_mau);
END IF;

IF p_doc_level = g_doc_level_HEADER THEN

  IF p_data_source = g_data_source_TRANSACTION THEN

    d_position := 20;

    SELECT SUM(
           DECODE(POL.matching_basis
                  , 'AMOUNT', pol.amount
                  , --QUANTITY
                    nvl2(l_mau
                        , round(pol.quantity*pol.unit_price/l_mau) * l_mau
                        , round((pol.quantity*pol.unit_price),l_precision)) ))  -- Bug# 5378134
    INTO l_return_val
    FROM po_lines_all pol
    WHERE pol.po_header_id = p_doc_level_id
    ;

  ELSIF p_data_source = g_data_source_ARCHIVE THEN

    d_position := 30;

    SELECT SUM(
           DECODE(POL.matching_basis
                  , 'AMOUNT', pol.amount
                  , --QUANTITY
                    nvl2(l_mau
                        , round(pol.quantity*pol.unit_price/l_mau) * l_mau
                        , round((pol.quantity*pol.unit_price),l_precision)) )) -- Bug# 5378134
    INTO l_return_val
    FROM po_lines_archive_all pol
    WHERE pol.po_header_id = p_doc_level_id
    AND (  (p_doc_revision_num IS NULL and pol.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND POL.revision_num =
              (SELECT max(POL2.revision_num)
               FROM po_lines_archive_all pol2
               WHERE pol2.po_line_id = pol.po_line_id
               AND pol2.revision_num <= p_doc_revision_num)
            )
        )
    ;

  ELSE

    d_position := 40;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
    END IF;

  END IF; --p_data_source check

ELSIF p_doc_level = g_doc_level_LINE THEN

  IF p_data_source = g_data_source_TRANSACTION THEN

    d_position := 50;

    SELECT DECODE(POL.matching_basis
                  , 'AMOUNT', pol.amount
                  , --QUANTITY
                    nvl2(l_mau
                        , round(pol.quantity*pol.unit_price/l_mau) * l_mau
                        , round((pol.quantity*pol.unit_price),l_precision)) ) -- Bug# 5378134
    INTO l_return_val
    FROM po_lines_all pol
    WHERE pol.po_line_id = p_doc_level_id
    ;

  ELSIF p_data_source = g_data_source_ARCHIVE THEN

    d_position := 60;

    SELECT DECODE(POL.matching_basis
                  , 'AMOUNT', pol.amount
                  , --QUANTITY
                    nvl2(l_mau
                        , round(pol.quantity*pol.unit_price/l_mau) * l_mau
                        , round((pol.quantity*pol.unit_price),l_precision)) ) -- Bug# 5378134
    INTO l_return_val
    FROM po_lines_archive_all pol
    WHERE pol.po_line_id = p_doc_level_id
    AND (  (p_doc_revision_num IS NULL and pol.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND POL.revision_num =
              (SELECT max(POL2.revision_num)
               FROM po_lines_archive_all pol2
               WHERE pol2.po_line_id = pol.po_line_id
               AND pol2.revision_num <= p_doc_revision_num)
            )
        )
    ;

  ELSE

    d_position := 70;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
    END IF;

  END IF; --p_data_source check

ELSIF p_doc_level = g_doc_level_SHIPMENT THEN

  IF p_data_source = g_data_source_TRANSACTION THEN

    d_position := 80;

    SELECT DECODE(POLL.matching_basis
                  , 'AMOUNT', poll.amount - nvl(poll.amount_cancelled,0)
                  , --QUANTITY
                    nvl2(l_mau
                        , round((poll.quantity-nvl(poll.quantity_cancelled,0))
                                *poll.price_override/l_mau) * l_mau
                        , round(((poll.quantity-nvl(poll.quantity_cancelled,0))
                                *poll.price_override),l_precision) )) -- Bug# 5378134
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.line_location_id = p_doc_level_id
    ;

  ELSIF p_data_source = g_data_source_ARCHIVE THEN

    d_position := 90;

    SELECT DECODE(POLL.matching_basis
                  , 'AMOUNT', poll.amount - nvl(poll.amount_cancelled,0)
                  , --QUANTITY
                    nvl2(l_mau
                        , round((poll.quantity-nvl(poll.quantity_cancelled,0))
                                *poll.price_override/l_mau) * l_mau
                        , round(((poll.quantity-nvl(poll.quantity_cancelled,0))
                                *poll.price_override),l_precision) )) -- Bug# 5378134
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.line_location_id = p_doc_level_id
    AND (  (p_doc_revision_num IS NULL and poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND POLL.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;

  ELSE

    d_position := 100;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
    END IF;

  END IF; --p_data_source check

ELSIF p_doc_level = g_doc_level_DISTRIBUTION THEN

  IF p_data_source = g_data_source_TRANSACTION THEN

    d_position := 110;

    SELECT DECODE(POLL.matching_basis
                  , 'AMOUNT', pod.amount_ordered - nvl(pod.amount_cancelled,0)
                  , --QUANTITY
                    nvl2(l_mau
                        , round((pod.quantity_ordered-nvl(pod.quantity_cancelled,0))
                                *poll.price_override/l_mau) * l_mau
                        , round(((pod.quantity_ordered-nvl(pod.quantity_cancelled,0))
                                *poll.price_override),l_precision) )) -- Bug# 5378134
    INTO l_return_val
    FROM po_line_locations_all poll
       , po_distributions_all pod
    WHERE pod.po_distribution_id = p_doc_level_id
    AND poll.line_location_id = pod.line_location_id
    ;

  ELSIF p_data_source = g_data_source_ARCHIVE THEN

    d_position := 120;

    SELECT DECODE(POLL.matching_basis
                  , 'AMOUNT', pod.amount_ordered - nvl(pod.amount_cancelled,0)
                  , --QUANTITY
                    nvl2(l_mau
                        , round((pod.quantity_ordered-nvl(pod.quantity_cancelled,0))
                                *poll.price_override/l_mau) * l_mau
                        , round(((pod.quantity_ordered-nvl(pod.quantity_cancelled,0))
                                *poll.price_override),l_precision) )) -- Bug# 5378134
    INTO l_return_val
    FROM po_line_locations_archive_all poll
       , po_distributions_archive_all pod
    WHERE pod.po_distribution_id = p_doc_level_id
    AND poll.line_location_id = pod.line_location_id
    AND (  (p_doc_revision_num IS NULL
            AND pod.latest_external_flag = 'Y'
            AND poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND POD.revision_num =
              (SELECT max(POD2.revision_num)
               FROM po_distributions_archive_all pod2
               WHERE pod2.po_distribution_id = pod.po_distribution_id
               AND pod2.revision_num <= p_doc_revision_num)
            AND POLL.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;

  ELSE

    d_position := 130;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
    END IF;

  END IF; --p_data_source check

ELSE

  d_position := 140;
  IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_mod,d_position,'Invalid doc level: ', p_doc_level);
  END IF;

END IF;  --p_doc_level check

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountOrdered;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountApprovedForLine
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the Approved Amount for a given PO Line.
-- For a Complex Work PO, Approved Amount is the amount of work
-- confirmed against the UI-visible Pay Items of the line.
-- For a non-Complex Work PO, Approved Amount is always 0.
-- The API supports only Standard PO document types.
--Parameters:
--IN:
--p_line_id
--  The ID of the line for which to calculate the approved amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountApprovedForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountApprovedForLine');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_precision  GL_CURRENCIES.precision%TYPE;
  l_mau  GL_CURRENCIES.minimum_accountable_unit%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id',p_line_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

do_org_currency_setups(
  p_doc_level => g_doc_level_LINE
, p_doc_level_id => p_line_id
, x_currency_precision => l_precision
, x_min_acct_unit => l_mau
);

d_position := 5;
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'l_precision:',l_precision);
  PO_LOG.stmt(d_mod,d_position,'l_mau:',l_mau);
END IF;

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 10;

  BEGIN
    SELECT SUM(
           DECODE(poll.matching_basis
                  , 'AMOUNT', poll.amount_received
                  , --QUANTITY
                    nvl2(l_mau
                        , round(poll.quantity_received*poll.price_override/l_mau) * l_mau
                        , round((poll.quantity_received*poll.price_override),l_precision)) ))   --Bug5391045
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_line_id = p_line_id
    AND nvl(poll.payment_type, 'NULL') IN ('RATE', 'LUMPSUM', 'MILESTONE')                --Bug5391045
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 20;

  BEGIN
    SELECT SUM(
           DECODE(poll.matching_basis
                  , 'AMOUNT', poll.amount_received
                  , --QUANTITY
                    nvl2(l_mau
                        , round(poll.quantity_received*poll.price_override/l_mau) * l_mau
                        , round((poll.quantity_received*poll.price_override),l_precision)) ))     --Bug5391045
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.po_line_id = p_line_id
    AND nvl(poll.payment_type, 'NULL') IN ('RATE', 'LUMPSUM', 'MILESTONE')             --Bug5391045
    AND (  (p_doc_revision_num IS NULL and poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 30;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountApprovedForLine;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountApprovedForHeader
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the Approved Amount for a given PO Header.
-- For a Complex Work PO, Approved Amount is the amount of work
-- confirmed against the UI-visible Pay Items of the PO lines.
-- For a non-Complex Work PO, Approved Amount is always 0.
-- The API supports only Standard PO document types.
--Parameters:
--IN:
--p_line_id
--  The ID of the SPO Header for which to calculate the approved amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountApprovedForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountApprovedForHeader');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_precision  GL_CURRENCIES.precision%TYPE;
  l_mau  GL_CURRENCIES.minimum_accountable_unit%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id',p_header_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

do_org_currency_setups(
  p_doc_level => g_doc_level_HEADER
, p_doc_level_id => p_header_id
, x_currency_precision => l_precision
, x_min_acct_unit => l_mau
);

d_position := 5;
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'l_precision:',l_precision);
  PO_LOG.stmt(d_mod,d_position,'l_mau:',l_mau);
END IF;

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 10;

  BEGIN
    SELECT SUM(
           DECODE(poll.matching_basis
                  , 'AMOUNT', poll.amount_received
                  , --QUANTITY
                    nvl2(l_mau
                        , round(poll.quantity_received*poll.price_override/l_mau) * l_mau
                        , round((poll.quantity_received*poll.price_override),l_precision)) ))    --Bug5391045
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_header_id = p_header_id
    AND nvl(poll.payment_type, 'NULL') IN ('RATE', 'LUMPSUM', 'MILESTONE')            --Bug5391045
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 20;

  BEGIN
    SELECT SUM(
           DECODE(poll.matching_basis
                  , 'AMOUNT', poll.amount_received
                  , --QUANTITY
                    nvl2(l_mau
                        , round(poll.quantity_received*poll.price_override/l_mau) * l_mau
                        , round((poll.quantity_received*poll.price_override),l_precision)) ))    --Bug5391045
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.po_header_id = p_header_id
    AND nvl(poll.payment_type, 'NULL') IN ('RATE', 'LUMPSUM', 'MILESTONE')          --Bug5391045
    AND (  (p_doc_revision_num IS NULL and poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 30;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountApprovedForHeader;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountDeliveredForLine
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the Delivered Amount for a given PO Line.
-- For a Financing Complex Work PO, the Delivered Amount
--   is the amount of work confirmed against the final delivery
--   of the item.
-- For a non-CWP PO or an Actuals CWP PO, the Delivered Amount
--   is the amount of work confirmed against all the STANDARD
--   type shipments/pay items.
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_line_id
--  The ID of the line for which to calculate the delivered amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountDeliveredForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountDeliveredForLine');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_precision  GL_CURRENCIES.precision%TYPE;
  l_mau  GL_CURRENCIES.minimum_accountable_unit%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id',p_line_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

do_org_currency_setups(
  p_doc_level => g_doc_level_LINE
, p_doc_level_id => p_line_id
, x_currency_precision => l_precision
, x_min_acct_unit => l_mau
);

d_position := 5;
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'l_precision:',l_precision);
  PO_LOG.stmt(d_mod,d_position,'l_mau:',l_mau);
END IF;

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 10;

  BEGIN
    SELECT SUM(
           DECODE(poll.matching_basis
                  , 'AMOUNT', pod.amount_delivered
                  , --QUANTITY
                    nvl2(l_mau
                        , round(pod.quantity_delivered*poll.price_override/l_mau) * l_mau
                        , round((pod.quantity_delivered*poll.price_override),l_precision)) ))   --Bug5391045
    INTO l_return_val
    FROM po_line_locations_all poll
       , po_distributions_all pod
    WHERE poll.po_line_id = p_line_id
    AND pod.line_location_id = poll.line_location_id
    AND pod.distribution_type = 'STANDARD'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No distributions exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 20;

  BEGIN
    SELECT SUM(
           DECODE(poll.matching_basis
                  , 'AMOUNT', pod.amount_delivered
                  , --QUANTITY
                    nvl2(l_mau
                        , round(pod.quantity_delivered*poll.price_override/l_mau) * l_mau
                        , round((pod.quantity_delivered*poll.price_override),l_precision)) ))   --Bug5391045
    INTO l_return_val
    FROM po_line_locations_archive_all poll
       , po_distributions_archive_all pod
    WHERE poll.po_line_id = p_line_id
    AND pod.line_location_id = poll.line_location_id
    AND pod.distribution_type = 'STANDARD'
    AND (  (p_doc_revision_num IS NULL
            AND poll.latest_external_flag = 'Y'
            AND pod.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            AND pod.revision_num =
              (SELECT max(POD2.revision_num)
               FROM po_distributions_archive_all pod2
               WHERE pod2.po_distribution_id = pod.po_distribution_id
               AND pod2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No distributions exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 30;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountDeliveredForLine;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountDeliveredForHeader
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the Delivered Amount for a given PO Header.
-- For a Financing Complex Work PO, the Delivered Amount
--   is the amount of work confirmed against the final delivery
--   of the items.
-- For a non-CWP PO or an Actuals CWP PO, the Delivered Amount
--   is the amount of work confirmed against all the STANDARD
--   type shipments/pay items.
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_header_id
--  The ID of the header for which to calculate the delivered amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountDeliveredForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountDeliveredForHeader');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_precision  GL_CURRENCIES.precision%TYPE;
  l_mau  GL_CURRENCIES.minimum_accountable_unit%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id',p_header_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

do_org_currency_setups(
  p_doc_level => g_doc_level_HEADER
, p_doc_level_id => p_header_id
, x_currency_precision => l_precision
, x_min_acct_unit => l_mau
);

d_position := 5;
IF PO_LOG.d_stmt THEN
  PO_LOG.stmt(d_mod,d_position,'l_precision:',l_precision);
  PO_LOG.stmt(d_mod,d_position,'l_mau:',l_mau);
END IF;

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 10;

  BEGIN
    SELECT SUM(
           DECODE(poll.matching_basis
                  , 'AMOUNT', pod.amount_delivered
                  , --QUANTITY
                    nvl2(l_mau
                        , round(pod.quantity_delivered*poll.price_override/l_mau) * l_mau
                        , round((pod.quantity_delivered*poll.price_override),l_precision)) ))    --Bug5391045
    INTO l_return_val
    FROM po_line_locations_all poll
       , po_distributions_all pod
    WHERE poll.po_header_id = p_header_id
    AND pod.line_location_id = poll.line_location_id
    AND pod.distribution_type = 'STANDARD'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No distributions exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 20;

  BEGIN
    SELECT SUM(
           DECODE(poll.matching_basis
                  , 'AMOUNT', pod.amount_delivered
                  , --QUANTITY
                    nvl2(l_mau
                        , round(pod.quantity_delivered*poll.price_override/l_mau) * l_mau
                        , round((pod.quantity_delivered*poll.price_override),l_precision)) ))   --Bug5391045
    INTO l_return_val
    FROM po_line_locations_archive_all poll
       , po_distributions_archive_all pod
    WHERE poll.po_header_id = p_header_id
    AND pod.line_location_id = poll.line_location_id
    AND pod.distribution_type = 'STANDARD'
    AND (  (p_doc_revision_num IS NULL
            AND poll.latest_external_flag = 'Y'
            AND pod.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            AND pod.revision_num =
              (SELECT max(POD2.revision_num)
               FROM po_distributions_archive_all pod2
               WHERE pod2.po_distribution_id = pod.po_distribution_id
               AND pod2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No distributions exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 30;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountDeliveredForHeader;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountBilledForLine
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the Billed Amount for a given PO Line.
--   Billed Amount is calculated based on the Standard Invoices
--   against the PO Line.  Prepayment Invoices are not included
--   in the Billed Amount.
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_line_id
--  The ID of the line for which to calculate the billed amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountBilledForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountBilledForLine');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_org_id PO_LINES_ALL.org_id%type;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id',p_line_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

  d_position := 10;

  SELECT pol.org_id
  INTO l_org_id
  FROM po_lines_all pol
  WHERE pol.po_line_id = p_line_id;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_org_id:',l_org_id);
  END IF;

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 30;

  BEGIN
    SELECT SUM(nvl(amount_billed,0))
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_line_id = p_line_id
    AND poll.shipment_type = 'STANDARD'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 40;

  BEGIN
    SELECT SUM(nvl(amount_billed,0))
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.po_line_id = p_line_id
    AND poll.shipment_type='STANDARD'
    AND (  (p_doc_revision_num IS NULL AND poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 50;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountBilledForLine;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountBilledForHeader
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the Billed Amount for a given PO Header.
--   Billed Amount is calculated based on the Standard Invoices
--   against the PO Line.  Prepayment Invoices are not included
--   in the Billed Amount.
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_header_id
--  The ID of the header for which to calculate the billed amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountBilledForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountBilledForHeader');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_org_id PO_HEADERS_ALL.org_id%type;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id',p_header_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

  d_position := 10;

  SELECT poh.org_id
  INTO l_org_id
  FROM po_headers_all poh
  WHERE poh.po_header_id = p_header_id
  ;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_org_id:',l_org_id);
  END IF;

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 30;

  BEGIN
    SELECT SUM(nvl(amount_billed,0))
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_header_id = p_header_id
    AND poll.shipment_type = 'STANDARD'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 40;

  BEGIN
    SELECT SUM(nvl(amount_billed,0))
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.po_header_id = p_header_id
    AND poll.shipment_type='STANDARD'
    AND (  (p_doc_revision_num IS NULL AND poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 50;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountBilledForHeader;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountFinancedForLine
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the Financed Amount for a given PO Line.
--   Financed Amount is calculated based on the Prepayment Invoices
--   against the PO Line.  Standard Invoices are not included
--   in the Financed Amount.
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_line_id
--  The ID of the line for which to calculate the financed amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountFinancedForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountFinancedForLine');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_org_id PO_LINES_ALL.org_id%type;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id',p_line_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

  d_position := 10;

  SELECT pol.org_id
  INTO l_org_id
  FROM po_lines_all pol
  WHERE pol.po_line_id = p_line_id;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_org_id:',l_org_id);
  END IF;

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 30;

  BEGIN
    SELECT SUM(nvl(amount_financed,0))
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_line_id = p_line_id
    AND poll.shipment_type = 'PREPAYMENT'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 40;

  BEGIN
    SELECT SUM(nvl(amount_financed,0))
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.po_line_id = p_line_id
    AND poll.shipment_type='PREPAYMENT'
    AND (  (p_doc_revision_num IS NULL AND poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 50;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountFinancedForLine;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountFinancedForHeader
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the Financed Amount for a given PO Header.
--   Financed Amount is calculated based on the Prepayment Invoices
--   against the PO Header.  Standard Invoices are not included
--   in the Financed Amount.
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_header_id
--  The ID of the header for which to calculate the financed amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountFinancedForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountFinancedForHeader');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_org_id PO_HEADERS_ALL.org_id%type;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id',p_header_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

  d_position := 10;

  SELECT poh.org_id
  INTO l_org_id
  FROM po_headers_all poh
  WHERE poh.po_header_id = p_header_id
  ;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_org_id:',l_org_id);
  END IF;

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 30;

  BEGIN
    SELECT SUM(nvl(amount_financed,0))
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_header_id = p_header_id
    AND poll.shipment_type = 'PREPAYMENT'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 40;

  BEGIN
    SELECT SUM(nvl(amount_financed,0))
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.po_header_id = p_header_id
    AND poll.shipment_type='PREPAYMENT'
    AND (  (p_doc_revision_num IS NULL AND poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 50;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountFinancedForHeader;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountRecoupedForLine
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the Recouped Amount for a given PO Line.
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_line_id
--  The ID of the line for which to calculate the recouped amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountRecoupedForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountRecoupedForLine');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_org_id PO_LINES_ALL.org_id%type;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id',p_line_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

  d_position := 10;

  SELECT pol.org_id
  INTO l_org_id
  FROM po_lines_all pol
  WHERE pol.po_line_id = p_line_id;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_org_id:',l_org_id);
  END IF;

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 10;

  BEGIN
    SELECT SUM(nvl(amount_recouped,0))
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_line_id = p_line_id
    AND poll.shipment_type = 'PREPAYMENT'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 20;

  BEGIN
    SELECT SUM(nvl(amount_recouped,0))
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.po_line_id = p_line_id
    AND poll.shipment_type='PREPAYMENT'
    AND (  (p_doc_revision_num IS NULL AND poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 30;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountRecoupedForLine;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountRecoupedForHeader
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the Recouped Amount for a given PO Header.
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_line_id
--  The ID of the header for which to calculate the recouped amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountRecoupedForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountRecoupedForHeader');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_org_id PO_HEADERS_ALL.org_id%type;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id',p_header_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

  d_position := 10;

  SELECT poh.org_id
  INTO l_org_id
  FROM po_headers_all poh
  WHERE poh.po_header_id = p_header_id
  ;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_org_id:',l_org_id);
  END IF;

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 30;

  BEGIN
    SELECT SUM(nvl(amount_recouped,0))
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_header_id = p_header_id
    AND poll.shipment_type = 'PREPAYMENT'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 40;

  BEGIN
    SELECT SUM(nvl(amount_recouped,0))
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.po_header_id = p_header_id
    AND poll.shipment_type='PREPAYMENT'
    AND (  (p_doc_revision_num IS NULL AND poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 50;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountRecoupedForHeader;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountRetainedForLine
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the current Retained Amount for a given PO Line.
--   Retained Amt = Retainge Withheld Amt - Retainage Released Amt
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_line_id
--  The ID of the line for which to calculate the retained amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountRetainedForLine(
  p_line_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountRetainedForLine');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_org_id PO_LINES_ALL.org_id%type;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id',p_line_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

  d_position := 10;

  SELECT pol.org_id
  INTO l_org_id
  FROM po_lines_all pol
  WHERE pol.po_line_id = p_line_id;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_org_id:',l_org_id);
  END IF;

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 30;

  BEGIN
    SELECT SUM(nvl(retainage_withheld_amount,0)
               - nvl(retainage_released_amount,0))
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_line_id = p_line_id
    AND poll.shipment_type = 'STANDARD'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 40;

  BEGIN
    SELECT SUM(nvl(retainage_withheld_amount,0)
               - nvl(retainage_released_amount,0))
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.po_line_id = p_line_id
    AND poll.shipment_type='STANDARD'
    AND (  (p_doc_revision_num IS NULL AND poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 50;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountRetainedForLine;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getAmountRetainedForHeader
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the current Retained Amount for a given PO Header.
--   Retained Amt = Retainge Withheld Amt - Retainage Released Amt
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_header_id
--  The ID of the header for which to calculate the retained amount
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  This is a DEFAULT NULL paramter
--  It is ignored if p_data_source is TRANSACTION
--  If p_data_source is ARCHIVE, then
--    The revision number of the header in the archive table.
--    If this parameter is passed as null, the latest version in the
--    archive table is assumed.
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getAmountRetainedForHeader(
  p_header_id IN NUMBER
, p_data_source IN VARCHAR2
, p_doc_revision_num IN NUMBER  --default null
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getAmountRetainedForHeader');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_org_id PO_HEADERS_ALL.org_id%type;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_header_id',p_header_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

  d_position := 10;

  SELECT poh.org_id
  INTO l_org_id
  FROM po_headers_all poh
  WHERE poh.po_header_id = p_header_id
  ;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_org_id:',l_org_id);
  END IF;

  PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 30;

  BEGIN
    SELECT SUM(nvl(retainage_withheld_amount,0)
               - nvl(retainage_released_amount,0))
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_header_id = p_header_id
    AND poll.shipment_type = 'STANDARD'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 40;

  BEGIN
    SELECT SUM(nvl(retainage_withheld_amount,0)
               - nvl(retainage_released_amount,0))
    INTO l_return_val
    FROM po_line_locations_archive_all poll
    WHERE poll.po_header_id = p_header_id
    AND poll.shipment_type='STANDARD'
    AND (  (p_doc_revision_num IS NULL AND poll.latest_external_flag = 'Y')
        OR (p_doc_revision_num IS NOT NULL
            AND poll.revision_num =
              (SELECT max(POLL2.revision_num)
               FROM po_line_locations_archive_all poll2
               WHERE poll2.line_location_id = poll.line_location_id
               AND poll2.revision_num <= p_doc_revision_num)
            )
        )
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE

  d_position := 50;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getAmountRetainedForHeader;






-------------------------------------------------------------------------------
--Start of Comments
--Name: getLineLocAmountForLine
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the total amount of the saved line locs for a line
-- This API supports both Quantity-based and Amount-based lines
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_line_id
--  The ID of the line for which to calculate the line loc total amount
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getLineLocAmountForLine(
  p_line_id IN NUMBER
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getLineLocAmountForLine');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_header_id PO_HEADERS_ALL.po_header_id%TYPE;
  l_is_complex_work_po BOOLEAN := FALSE;
  l_precision  GL_CURRENCIES.precision%TYPE;
  l_mau  GL_CURRENCIES.minimum_accountable_unit%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id',p_line_id);
END IF;

  do_org_currency_setups(
    p_doc_level => g_doc_level_LINE
  , p_doc_level_id => p_line_id
  , x_currency_precision => l_precision
  , x_min_acct_unit => l_mau
  );

  d_position := 5;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_precision:',l_precision);
    PO_LOG.stmt(d_mod,d_position,'l_mau:',l_mau);
  END IF;

  d_position := 10;

  BEGIN
    SELECT SUM(
           DECODE(poll.matching_basis
                  , 'AMOUNT', poll.amount-nvl(poll.amount_cancelled,0)
                  , --QUANTITY
                    nvl2(l_mau
                        , round((poll.quantity-nvl(poll.quantity_cancelled,0))
                                *poll.price_override/l_mau) * l_mau
                        , round(((poll.quantity-nvl(poll.quantity_cancelled,0))
                                *poll.price_override),l_precision) ) ))             --Bug5391045
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_line_id = p_line_id
    AND poll.shipment_type = 'STANDARD'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

  d_position := 20;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getLineLocAmountForLine;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getDistQuantityForLineLoc
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the total quantity of the saved distributions of a line loc
-- This API is only intended for QUANTITY-BASED LINE LOCS
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_line_loc_id
--  The ID of the line loc for which to calculate the dist total quantity
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getDistQuantityForLineLoc(
  p_line_loc_id IN NUMBER
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getDistQuantityForLineLoc');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id',p_line_loc_id);
END IF;

  d_position := 10;

  BEGIN
    SELECT SUM(pod.quantity_ordered)
    INTO l_return_val
    FROM po_distributions_all pod
    WHERE pod.line_location_id = p_line_loc_id
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No distributions exist');
      END IF;
      l_return_val := 0;
  END;

  d_position := 20;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getDistQuantityForLineLoc;



-------------------------------------------------------------------------------
--Start of Comments
--Name: getDistAmountForLineLoc
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the total amount of the saved distributions of a line loc
-- This API is only intended for AMOUNT-BASED LINE LOCS
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_line_loc_id
--  The ID of the line loc for which to calculate the dist total amount
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getDistAmountForLineLoc(
  p_line_loc_id IN NUMBER
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getDistAmountForLineLoc');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_loc_id',p_line_loc_id);
END IF;

  d_position := 10;

  BEGIN
    SELECT SUM(pod.amount_ordered)
    INTO l_return_val
    FROM po_distributions_all pod
    WHERE pod.line_location_id = p_line_loc_id
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No distributions exist');
      END IF;
      l_return_val := 0;
  END;

  d_position := 20;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getDistAmountForLineLoc;



-------------------------------------------------------------------------------
--Start of Comments
--Name: do_org_currency_setups
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Sets the org context to the document's org, if the org context was
-- not already set by the caller
-- Retrieves the currency information (min accting unit, currency
-- precision) for the document's currency.
--Parameters:
--IN:
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--p_doc_level_id
--  Id of the doc level type for which to calculate totals
--OUT:
--x_currency_precision
--  The currency precision of the document's currency
--x_min_acct_unit
--  The minimum accountable unit for the document's currency
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE do_org_currency_setups(
  p_doc_level IN VARCHAR2
, p_doc_level_id IN NUMBER
, x_currency_precision OUT NOCOPY NUMBER
, x_min_acct_unit OUT NOCOPY NUMBER
) IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'do_org_currency_setups');
  d_position NUMBER := 0;
  l_header_id PO_HEADERS_ALL.po_header_id%type;
  l_org_id PO_HEADERS_ALL.org_id%type;
  l_po_currency PO_HEADERS_ALL.currency_code%type;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_doc_level',p_doc_level);
  PO_LOG.proc_begin(d_mod,'p_doc_level_id',p_doc_level_id);
END IF;

  d_position := 10;

  IF p_doc_level = g_doc_level_HEADER THEN

    d_position := 20;
    l_header_id := p_doc_level_id;

  ELSIF p_doc_level = g_doc_level_LINE THEN

    d_position := 30;
    SELECT pol.po_header_id
    INTO l_header_id
    FROM po_lines_all pol
    WHERE pol.po_line_id = p_doc_level_id;

  ELSIF p_doc_level = g_doc_level_SHIPMENT THEN

    d_position := 40;
    SELECT poll.po_header_id
    INTO l_header_id
    FROM po_line_locations_all poll
    WHERE poll.line_location_id = p_doc_level_id;

  ELSIF p_doc_level = g_doc_level_DISTRIBUTION THEN

    d_position := 50;
    SELECT pod.po_header_id
    INTO l_header_id
    FROM po_distributions_all pod
    WHERE pod.po_distribution_id = p_doc_level_id;

  END IF;

  d_position := 60;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_header_id:',l_header_id);
  END IF;

  SELECT poh.currency_code, poh.org_id
  INTO l_po_currency, l_org_id
  FROM po_headers_all poh
  WHERE poh.po_header_id = l_header_id
  ;

  d_position := 70;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_po_currency:',l_po_currency);
    PO_LOG.stmt(d_mod,d_position,'l_org_id:',l_org_id);
  END IF;

  d_position := 80;
  PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

  d_position := 90;
  PO_CORE_S2.get_currency_info(
    x_currency_code => l_po_currency    --IN
  , x_precision => x_currency_precision  --OUT
  , x_min_unit => x_min_acct_unit        --OUT
  );

  d_position := 100;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_currency_precision:',x_currency_precision);
  PO_LOG.proc_end(d_mod,'x_min_acct_unit:', x_min_acct_unit);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END do_org_currency_setups;







--TODO: obsolete the following method bodies below once impacts to all
--callers of the get_order_totals have been handled:
-- * get_order_totals
-- * get_order_totals_from_archive
-- * get_totals
-- * populate_temp_table
-- * prepare_temp_table_data
-- * calculate_totals
-- * clear_temp_table


-------------------------------------------------------------------------------
--Start of Comments
--Name: get_order_totals
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Calculates various totals (qty ordered, billed etc) for POs or Releases
--  based on the given document level.  The result is always returned in the
--  document currency (foreign currency) not the OU functional currency.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    PO
--    RELEASE
--p_doc_subtype
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    STANDARD
--    PLANNED
--    BLANKET
--    SCHEDULED
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type for which to calculate totals
--OUT:

--x_quantity_total
--  The total active (uncancelled) quantity ordered for the document level
--x_amount_total
--  The total active (uncancelled) amount ordered for the document level
--x_quantity_delivered
--  The total quantity delivered for the document level
--x_amount_delivered
--  The total amount delivered for the document level
--x_quantity_received
--  The total quantity received for the document level.
--  Always zero if the document level is 'DISTRIBUTION'
--x_amount_received
--  The total amount received for the document level
--  Always zero if the document level is 'DISTRIBUTION'
--x_quantity_shipped
--  The total quantity shipped for the document level.
--  Always zero if the document level is 'DISTRIBUTION'
--x_amount_shipped
--  The total amount shipped for the document level
--  Always zero if the document level is 'DISTRIBUTION'
--x_quantity_billed
--  The total quantity billed for the document level
--x_amount_billed
--  The total amount billed for the document level
--x_quantity_financed
--  The total quantity financed for the document level
--x_amount_financed
--  The total amount financed for the document level
--x_quantity_recouped
--  The total quantity recouped for the document level
--x_amount_recouped
--  The total amount recouped for the document level
--x_retainage_withheld_amount
--  The total retainage withheld for the document level
--x_retainage_released_amount
--  The total retainage released for the document level
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_order_totals(
  p_doc_type                     IN VARCHAR2,
  p_doc_subtype                  IN VARCHAR2,
  p_doc_level                    IN VARCHAR2,
  p_doc_level_id                 IN NUMBER,
  x_quantity_total               OUT NOCOPY NUMBER,
  x_amount_total                 OUT NOCOPY NUMBER,
  x_quantity_delivered           OUT NOCOPY NUMBER,
  x_amount_delivered             OUT NOCOPY NUMBER,
  x_quantity_received            OUT NOCOPY NUMBER,
  x_amount_received              OUT NOCOPY NUMBER,
  x_quantity_shipped             OUT NOCOPY NUMBER,
  x_amount_shipped               OUT NOCOPY NUMBER,
  x_quantity_billed              OUT NOCOPY NUMBER,
  x_amount_billed                OUT NOCOPY NUMBER,
  x_quantity_financed            OUT NOCOPY NUMBER,
  x_amount_financed              OUT NOCOPY NUMBER,
  x_quantity_recouped            OUT NOCOPY NUMBER,
  x_amount_recouped              OUT NOCOPY NUMBER,
  x_retainage_withheld_amount    OUT NOCOPY NUMBER,
  x_retainage_released_amount    OUT NOCOPY NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_order_totals');
  d_position NUMBER := 0;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
  PO_LOG.proc_begin(d_mod,'p_doc_subtype',p_doc_subtype);
  PO_LOG.proc_begin(d_mod,'p_doc_level',p_doc_level);
  PO_LOG.proc_begin(d_mod,'p_doc_level_id',p_doc_level_id);
END IF;

  -- Logic: call the PVT signature get_totals

  d_position := 10;

  get_totals(
    p_doc_type => p_doc_type,
    p_doc_subtype => p_doc_subtype,
    p_doc_level => p_doc_level,
    p_doc_level_id => p_doc_level_id,
    p_data_source => g_data_source_TRANSACTION,
    p_doc_revision_num => NULL,
    x_quantity_total => x_quantity_total,
    x_amount_total => x_amount_total,
    x_quantity_delivered => x_quantity_delivered,
    x_amount_delivered => x_amount_delivered,
    x_quantity_received => x_quantity_received,
    x_amount_received => x_amount_received,
    x_quantity_shipped => x_quantity_shipped,
    x_amount_shipped => x_amount_shipped,
    x_quantity_billed => x_quantity_billed,
    x_amount_billed => x_amount_billed,
    x_quantity_financed => x_quantity_financed,
    x_amount_financed => x_amount_financed,
    x_quantity_recouped => x_quantity_recouped,
    x_amount_recouped => x_amount_recouped,
    x_retainage_withheld_amount => x_retainage_withheld_amount,
    x_retainage_released_amount => x_retainage_released_amount
  );

  d_position := 20;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_quantity_total',x_quantity_total);
  PO_LOG.proc_end(d_mod,'x_amount_total', x_amount_total);
  PO_LOG.proc_end(d_mod,'x_quantity_delivered', x_quantity_delivered);
  PO_LOG.proc_end(d_mod,'x_amount_delivered', x_amount_delivered);
  PO_LOG.proc_end(d_mod,'x_quantity_received', x_quantity_received);
  PO_LOG.proc_end(d_mod,'x_amount_received', x_amount_received);
  PO_LOG.proc_end(d_mod,'x_quantity_shipped', x_quantity_shipped);
  PO_LOG.proc_end(d_mod,'x_amount_shipped', x_amount_shipped);
  PO_LOG.proc_end(d_mod,'x_quantity_billed', x_quantity_billed);
  PO_LOG.proc_end(d_mod,'x_amount_billed', x_amount_billed);
  PO_LOG.proc_end(d_mod,'x_quantity_financed', x_quantity_financed);
  PO_LOG.proc_end(d_mod,'x_amount_financed', x_amount_financed);
  PO_LOG.proc_end(d_mod,'x_quantity_recouped', x_quantity_recouped);
  PO_LOG.proc_end(d_mod,'x_amount_recouped', x_amount_recouped);
  PO_LOG.proc_end(d_mod,'x_retainage_withheld_amount', x_retainage_withheld_amount);
  PO_LOG.proc_end(d_mod,'x_retainage_released_amount', x_retainage_released_amount);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END get_order_totals;


-------------------------------------------------------------------------------
--Start of Comments
--Name: get_order_totals_from_archive
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Calculates various totals (qty ordered, billed etc) for an archived
--  version of a PO or Release based on the given document level and the
--  revision number of the header.  The result is always returned in the
--  document currency (foreign currency) not the OU functional currency.
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    PO
--    RELEASE
--p_doc_subtype
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    STANDARD
--    PLANNED
--    BLANKET
--    SCHEDULED
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type for which to calculate totals
--p_doc_revision_num
--  The revision number of the header in the archive table.
--  If this parameter is passed as null, the latest version in the table
--  is assumed
--OUT:
--x_quantity_total
--  The total active (uncancelled) quantity ordered for the document level
--x_amount_total
--  The total active (uncancelled) amount ordered for the document level
--x_quantity_delivered
--  The total quantity delivered for the document level
--x_amount_delivered
--  The total amount delivered for the document level
--x_quantity_received
--  The total quantity received for the document level.
--  Always zero if the document level is 'DISTRIBUTION'
--x_amount_received
--  The total amount received for the document level
--  Always zero if the document level is 'DISTRIBUTION'
--x_quantity_shipped
--  The total quantity shipped for the document level.
--  Always zero if the document level is 'DISTRIBUTION'
--x_amount_shipped
--  The total amount shipped for the document level
--  Always zero if the document level is 'DISTRIBUTION'
--x_quantity_billed
--  The total quantity billed for the document level
--x_amount_billed
--  The total amount billed for the document level
--x_quantity_financed
--  The total quantity financed for the document level
--x_amount_financed
--  The total amount financed for the document level
--x_quantity_recouped
--  The total quantity recouped for the document level
--x_amount_recouped
--  The total amount recouped for the document level
--x_retainage_withheld_amount
--  The total retainage withheld for the document level
--x_retainage_released_amount
--  The total retainage released for the document level
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_order_totals_from_archive(
  p_doc_type                     IN VARCHAR2,
  p_doc_subtype                  IN VARCHAR2,
  p_doc_level                    IN VARCHAR2,
  p_doc_level_id                 IN NUMBER,
  p_doc_revision_num             IN NUMBER,
  x_quantity_total               OUT NOCOPY NUMBER,
  x_amount_total                 OUT NOCOPY NUMBER,
  x_quantity_delivered           OUT NOCOPY NUMBER,
  x_amount_delivered             OUT NOCOPY NUMBER,
  x_quantity_received            OUT NOCOPY NUMBER,
  x_amount_received              OUT NOCOPY NUMBER,
  x_quantity_shipped             OUT NOCOPY NUMBER,
  x_amount_shipped               OUT NOCOPY NUMBER,
  x_quantity_billed              OUT NOCOPY NUMBER,
  x_amount_billed                OUT NOCOPY NUMBER,
  x_quantity_financed            OUT NOCOPY NUMBER,
  x_amount_financed              OUT NOCOPY NUMBER,
  x_quantity_recouped            OUT NOCOPY NUMBER,
  x_amount_recouped              OUT NOCOPY NUMBER,
  x_retainage_withheld_amount    OUT NOCOPY NUMBER,
  x_retainage_released_amount    OUT NOCOPY NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_order_totals_from_archive');
  d_position NUMBER := 0;

  l_doc_currency_code     GL_CURRENCIES.currency_code%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
  PO_LOG.proc_begin(d_mod,'p_doc_subtype',p_doc_subtype);
  PO_LOG.proc_begin(d_mod,'p_doc_level',p_doc_level);
  PO_LOG.proc_begin(d_mod,'p_doc_level_id',p_doc_level_id);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

  -- Logic: call the PVT signature get_totals

  d_position := 10;

  get_totals(
    p_doc_type => p_doc_type,
    p_doc_subtype => p_doc_subtype,
    p_doc_level => p_doc_level,
    p_doc_level_id => p_doc_level_id,
    p_data_source => g_data_source_ARCHIVE,
    p_doc_revision_num => p_doc_revision_num,
    x_quantity_total => x_quantity_total,
    x_amount_total => x_amount_total,
    x_quantity_delivered => x_quantity_delivered,
    x_amount_delivered => x_amount_delivered,
    x_quantity_received => x_quantity_received,
    x_amount_received => x_amount_received,
    x_quantity_shipped => x_quantity_shipped,
    x_amount_shipped => x_amount_shipped,
    x_quantity_billed => x_quantity_billed,
    x_amount_billed => x_amount_billed,
    x_quantity_financed => x_quantity_financed,
    x_amount_financed => x_amount_financed,
    x_quantity_recouped => x_quantity_recouped,
    x_amount_recouped => x_amount_recouped,
    x_retainage_withheld_amount => x_retainage_withheld_amount,
    x_retainage_released_amount => x_retainage_released_amount
  );

  d_position := 20;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_quantity_total',x_quantity_total);
  PO_LOG.proc_end(d_mod,'x_amount_total', x_amount_total);
  PO_LOG.proc_end(d_mod,'x_quantity_delivered', x_quantity_delivered);
  PO_LOG.proc_end(d_mod,'x_amount_delivered', x_amount_delivered);
  PO_LOG.proc_end(d_mod,'x_quantity_received', x_quantity_received);
  PO_LOG.proc_end(d_mod,'x_amount_received', x_amount_received);
  PO_LOG.proc_end(d_mod,'x_quantity_shipped', x_quantity_shipped);
  PO_LOG.proc_end(d_mod,'x_amount_shipped', x_amount_shipped);
  PO_LOG.proc_end(d_mod,'x_quantity_billed', x_quantity_billed);
  PO_LOG.proc_end(d_mod,'x_amount_billed', x_amount_billed);
  PO_LOG.proc_end(d_mod,'x_quantity_financed', x_quantity_financed);
  PO_LOG.proc_end(d_mod,'x_amount_financed', x_amount_financed);
  PO_LOG.proc_end(d_mod,'x_quantity_recouped', x_quantity_recouped);
  PO_LOG.proc_end(d_mod,'x_amount_recouped', x_amount_recouped);
  PO_LOG.proc_end(d_mod,'x_retainage_withheld_amount', x_retainage_withheld_amount);
  PO_LOG.proc_end(d_mod,'x_retainage_released_amount', x_retainage_released_amount);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END get_order_totals_from_archive;



-------------------------------------------------------------------------------
--Start of Comments
--Name: get_totals
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- Main PVT API for Totals logic.  Acts as a switchboard to call the
-- various subprocedures to populate the GTT and perform the calculations
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    PO
--    RELEASE
--p_doc_subtype
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    STANDARD
--    PLANNED
--    BLANKET
--    SCHEDULED
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_data_source
--  Use C_data_source_<> constants
--    C_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    C_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  The revision number of the header in the archive table.
--  If this parameter is passed as null, the latest version in the table
--  is assumed
--p_doc_level_id
--  Id of the doc level type for which to calculate totals
--OUT:
--x_quantity_total
--  The total active (uncancelled) quantity ordered for the document level
--x_amount_total
--  The total active (uncancelled) amount ordered for the document level
--x_quantity_delivered
--  The total quantity delivered for the document level
--x_amount_delivered
--  The total amount delivered for the document level
--x_quantity_received
--  The total quantity received for the document level.
--  Always zero if the document level is 'DISTRIBUTION'
--x_amount_received
--  The total amount received for the document level
--  Always zero if the document level is 'DISTRIBUTION'
--x_quantity_shipped
--  The total quantity shipped for the document level.
--  Always zero if the document level is 'DISTRIBUTION'
--x_amount_shipped
--  The total amount shipped for the document level
--  Always zero if the document level is 'DISTRIBUTION'
--x_quantity_billed
--  The total quantity billed for the document level
--x_amount_billed
--  The total amount billed for the document level
--x_quantity_financed
--  The total quantity financed for the document level
--x_amount_financed
--  The total amount financed for the document level
--x_quantity_recouped
--  The total quantity recouped for the document level
--x_amount_recouped
--  The total amount recouped for the document level
--x_retainage_withheld_amount
--  The total retainage withheld for the document level
--x_retainage_released_amount
--  The total retainage released for the document level
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_totals(
  p_doc_type                     IN VARCHAR2,
  p_doc_subtype                  IN VARCHAR2,
  p_doc_level                    IN VARCHAR2,
  p_doc_level_id                 IN NUMBER,
  p_data_source                  IN VARCHAR2,
  p_doc_revision_num             IN NUMBER,
  x_quantity_total               OUT NOCOPY NUMBER,
  x_amount_total                 OUT NOCOPY NUMBER,
  x_quantity_delivered           OUT NOCOPY NUMBER,
  x_amount_delivered             OUT NOCOPY NUMBER,
  x_quantity_received            OUT NOCOPY NUMBER,
  x_amount_received              OUT NOCOPY NUMBER,
  x_quantity_shipped             OUT NOCOPY NUMBER,
  x_amount_shipped               OUT NOCOPY NUMBER,
  x_quantity_billed              OUT NOCOPY NUMBER,
  x_amount_billed                OUT NOCOPY NUMBER,
  x_quantity_financed            OUT NOCOPY NUMBER,
  x_amount_financed              OUT NOCOPY NUMBER,
  x_quantity_recouped            OUT NOCOPY NUMBER,
  x_amount_recouped              OUT NOCOPY NUMBER,
  x_retainage_withheld_amount    OUT NOCOPY NUMBER,
  x_retainage_released_amount    OUT NOCOPY NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'get_order_totals');
  d_position NUMBER := 0;

  l_org_id HR_ALL_ORGANIZATION_UNITS.organization_id%type;
  l_distribution_id_tbl        po_tbl_number;
  l_document_id                NUMBER;
  l_document_id_tbl            po_tbl_number;
  l_temp_table_key             PO_DOCUMENT_TOTALS_GT.key%TYPE;
  l_base_currency_code         GL_CURRENCIES.currency_code%TYPE;
  l_doc_currency_code          GL_CURRENCIES.currency_code%TYPE;
  l_temp_table_row_count       NUMBER;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
  PO_LOG.proc_begin(d_mod,'p_doc_subtype',p_doc_subtype);
  PO_LOG.proc_begin(d_mod,'p_doc_level',p_doc_level);
  PO_LOG.proc_begin(d_mod,'p_doc_level_id',p_doc_level_id);
  PO_LOG.proc_begin(d_mod,'p_data_source',p_data_source);
  PO_LOG.proc_begin(d_mod,'p_doc_revision_num',p_doc_revision_num);
END IF;

  -- Logic:
  -- Based on doc type and doc level, get the list of distribution ids
  -- Based on the distribution ids, populate the GTT with qty, price etc
  -- Do intermediate calculations as necessary
  -- Calculate the totals based off of the temp table data

  -- Bug 5124868: enhanced the doc totals API to set the org context
  -- if not already set.
  l_org_id := PO_MOAC_UTILS_PVT.get_entity_org_id(
                p_doc_type
              , p_doc_level
              , p_doc_level_id);
  PO_MOAC_UTILS_PVT.set_org_context(l_org_id);

  d_position := 5;

  populate_temp_table(
    p_doc_type => p_doc_type,
    p_doc_level => p_doc_level,
    p_doc_level_id => p_doc_level_id,
    p_data_source => p_data_source,
    p_doc_revision_num => p_doc_revision_num,
    x_temp_table_key => l_temp_table_key,
    x_count => l_temp_table_row_count
  );

  d_position := 10;

  IF (l_temp_table_row_count > 0) THEN

    -- Get the PO Header ID (or Release ID in BRel/SRel case)
    -- based on the passed in doc level ID
    PO_CORE_S.get_document_ids(
      p_doc_type => p_doc_type,
      p_doc_level => p_doc_level,
      p_doc_level_id_tbl  => po_tbl_number(p_doc_level_id),
      x_doc_id_tbl => l_document_id_tbl
    );

    d_position := 20;

    -- There should only be 1 row in the returned table, since this
    -- API is called for a single document at a time
    l_document_id := l_document_id_tbl(1);

    d_position := 30;

    prepare_temp_table_data(
      p_temp_table_key => l_temp_table_key,
      p_document_id => l_document_id
    );

    d_position := 40;

    calculate_totals(
      p_temp_table_key => l_temp_table_key,
      p_document_id => l_document_id,
      p_doc_level => p_doc_level,
      x_quantity_total => x_quantity_total,
      x_amount_total => x_amount_total,
      x_quantity_delivered => x_quantity_delivered,
      x_amount_delivered => x_amount_delivered,
      x_quantity_received => x_quantity_received,
      x_amount_received => x_amount_received,
      x_quantity_shipped => x_quantity_shipped,
      x_amount_shipped => x_amount_shipped,
      x_quantity_billed => x_quantity_billed,
      x_amount_billed => x_amount_billed,
      x_quantity_financed => x_quantity_financed,
      x_amount_financed => x_amount_financed,
      x_quantity_recouped => x_quantity_recouped,
      x_amount_recouped => x_amount_recouped,
      x_retainage_withheld_amount => x_retainage_withheld_amount,
      x_retainage_released_amount => x_retainage_released_amount
    );

    d_position := 50;

  ELSE

    -- Temp Table Row Count is 0.
    -- This can happen for unsaved documents which have no lines yet
    x_quantity_total := 0; x_amount_total := 0;
    x_quantity_delivered := 0; x_amount_delivered := 0;
    x_quantity_received := 0; x_amount_received := 0;
    x_quantity_shipped := 0; x_amount_shipped := 0;
    x_quantity_billed := 0; x_amount_billed := 0;
    x_quantity_financed := 0; x_amount_financed := 0;
    x_quantity_recouped := 0; x_amount_recouped := 0;
    x_retainage_withheld_amount := 0; x_retainage_released_amount := 0;

  END IF;

  -- Delete our data from the temp table
  clear_temp_table(
    p_temp_table_key => l_temp_table_key
  );

  d_position := 60;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_quantity_total',x_quantity_total);
  PO_LOG.proc_end(d_mod,'x_amount_total', x_amount_total);
  PO_LOG.proc_end(d_mod,'x_quantity_delivered', x_quantity_delivered);
  PO_LOG.proc_end(d_mod,'x_amount_delivered', x_amount_delivered);
  PO_LOG.proc_end(d_mod,'x_quantity_received', x_quantity_received);
  PO_LOG.proc_end(d_mod,'x_amount_received', x_amount_received);
  PO_LOG.proc_end(d_mod,'x_quantity_shipped', x_quantity_shipped);
  PO_LOG.proc_end(d_mod,'x_amount_shipped', x_amount_shipped);
  PO_LOG.proc_end(d_mod,'x_quantity_billed', x_quantity_billed);
  PO_LOG.proc_end(d_mod,'x_amount_billed', x_amount_billed);
  PO_LOG.proc_end(d_mod,'x_quantity_financed', x_quantity_financed);
  PO_LOG.proc_end(d_mod,'x_amount_financed', x_amount_financed);
  PO_LOG.proc_end(d_mod,'x_quantity_recouped', x_quantity_recouped);
  PO_LOG.proc_end(d_mod,'x_amount_recouped', x_amount_recouped);
  PO_LOG.proc_end(d_mod,'x_retainage_withheld_amount', x_retainage_withheld_amount);
  PO_LOG.proc_end(d_mod,'x_retainage_released_amount', x_retainage_released_amount);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;

END get_totals;



-------------------------------------------------------------------------------
--Start of Comments
--Name: populate_temp_table
--Pre-reqs:
--  None.
--Modifies:
--  PO_DOCUMENT_TOTALS_GT
--Locks:
--  None.
--Function:
-- Based on given doc type and doc level, get the list of distribution ids.
-- Based on the distribution ids, populate the GTT with all relevant columns
-- (e.g. qty, price) needed to perform the calculations
--Parameters:
--IN:
--p_doc_type
--  Document type.  Use the g_doc_type_<> variables, where <> is:
--    PO
--    RELEASE
--p_doc_level
--  The type of ids that are being passed.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--p_doc_level_id
--  Id of the doc level type for which to calculate totals
--p_data_source
--  Use g_data_source_<> constants
--    g_data_source_TRANSACTION: calculate totals based off of
--      data values in the main txn tables
--    g_data_source_ARCHIVE: calculate totals based off of
--      data values in the archive tables
--p_doc_revision_num
--  The revision number of the header in the archive table.
--  If this parameter is passed as null, the latest version in the table
--  is assumed
--OUT:
--x_temp_table_key
--  The unique key value that identifies all rows inserted into
--  PO_DOCUMENT_TOTALS_GT for this transaction
--x_count
--  The number of rows inserted into the temp table
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE populate_temp_table(
  p_doc_type IN VARCHAR2,
  p_doc_level IN VARCHAR2,
  p_doc_level_id IN NUMBER,
  p_data_source IN VARCHAR2,
  p_doc_revision_num IN NUMBER,
  x_temp_table_key OUT NOCOPY NUMBER,
  x_count OUT NOCOPY NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'populate_temp_table');
  d_position NUMBER := 0;

  l_distribution_id_tbl      PO_TBL_NUMBER;
  l_distribution_rev_num_tbl   po_tbl_number;
  l_temp_table_key           PO_DOCUMENT_TOTALS_GT.key%TYPE;
  l_distribution_type_filter PO_DISTRIBUTIONS_ALL.distribution_type%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_doc_type',p_doc_type);
  PO_LOG.proc_begin(d_mod,'p_doc_level',p_doc_level);
  PO_LOG.proc_begin(d_mod,'p_doc_level_id',p_doc_level_id);
END IF;

d_position := 5;

-- Select the unique key to identify GTT rows for this trxn
SELECT PO_DOCUMENT_TOTALS_GT_S.nextval INTO l_temp_table_key from dual;

IF p_data_source = g_data_source_TRANSACTION THEN

  d_position := 10;

  -- Get the IDs of the distributions from the trxn tables.
  -- We will get the qty/amt data to sum up based on dist data.
  PO_CORE_S.get_distribution_ids(
    p_doc_type => p_doc_type,
    p_doc_level => p_doc_level,
    p_doc_level_id_tbl  => po_tbl_number(p_doc_level_id),
    x_distribution_id_tbl => l_distribution_id_tbl
  );

  d_position := 20;

  -- SQL WHAT: Insert relevant data for calculations into the temp table,
  -- rolling distribution data up into line location subtotals. This is done
  -- to accomodate the fact that some totals fields (e.g. received/shipped)
  -- only live at the line location level.  If the caller passed in the
  -- p_doc_level for totals as DISTRIBUTION, then set these line location
  -- fields to zero.
  -- SQL WHERE: All distributions under the given document level
  FORALL i IN 1 .. l_distribution_id_tbl.COUNT
  INSERT INTO PO_DOCUMENT_TOTALS_GT
  (
    key,
    line_location_id,
    amount_based_flag,
    shipment_type,
    payment_type,
    price,
    quantity_total,
    quantity_billed,
    quantity_delivered,
    quantity_financed,
    quantity_recouped,
    quantity_received,
    quantity_shipped,
    amount_total,
    amount_billed,
    amount_delivered,
    amount_financed,
    amount_recouped,
    amount_received,
    amount_shipped,
    retainage_withheld_amount,
    retainage_released_amount
  )
  SELECT
    l_temp_table_key,
    POLL.line_location_id,
    DECODE(POLL.value_basis,
          'FIXED PRICE', 'Y',
          'RATE', 'Y',
          'N') amount_based_flag,
    POLL.shipment_type,
    POLL.payment_type,
    POLL.price_override,
    SUM( (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0)) ),
    SUM( nvl(POD.quantity_billed,0) ),
    SUM( nvl(POD.quantity_delivered,0) ),
    SUM( nvl(POD.quantity_financed,0) ),
    SUM( nvl(POD.quantity_recouped,0) ),
    DECODE(p_doc_level, g_doc_level_DISTRIBUTION, 0, POLL.quantity_received),
    DECODE(p_doc_level, g_doc_level_DISTRIBUTION, 0, POLL.quantity_shipped),
    SUM( (nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0)) ),
    SUM( nvl(POD.amount_billed,0) ),
    SUM( nvl(POD.amount_delivered,0) ),
    SUM( nvl(POD.amount_financed,0) ),
    SUM( nvl(POD.amount_recouped,0) ),
    DECODE(p_doc_level, g_doc_level_DISTRIBUTION, 0, POLL.amount_received),
    DECODE(p_doc_level, g_doc_level_DISTRIBUTION, 0, POLL.amount_shipped),
    SUM( nvl(POD.retainage_withheld_amount,0) ),
    SUM( nvl(POD.retainage_released_amount,0) )
  FROM
    PO_LINE_LOCATIONS_ALL POLL,
    PO_DISTRIBUTIONS_ALL POD
  WHERE POD.po_distribution_id = l_distribution_id_tbl(i)
  AND POD.line_location_id = POLL.line_location_id
  GROUP BY POLL.line_location_id, POLL.value_basis, POLL.shipment_type,
  POLL.payment_type, POLL.price_override, POLL.quantity_received, POLL.quantity_shipped,
  POLL.amount_received, POLL.amount_shipped
  ;

  x_count := nvl(SQL%ROWCOUNT, 0);

  d_position := 30;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Inserted data - rowcount:',x_count);
  END IF;

ELSIF p_data_source = g_data_source_ARCHIVE THEN

  d_position := 40;

  -- Get the IDs of the distributions from the archive tables.
  -- We will get the qty/amt data to sum up based on dist data.
  PO_CORE_S.get_dist_ids_from_archive(
    p_doc_type => p_doc_type,
    p_doc_level => p_doc_level,
    p_doc_level_id_tbl  => po_tbl_number(p_doc_level_id),
    p_doc_revision_num  => p_doc_revision_num,
    x_distribution_id_tbl => l_distribution_id_tbl,
    x_distribution_rev_num_tbl => l_distribution_rev_num_tbl
  );

  d_position := 50;

  -- SQL WHAT: Insert relevant data for calculations into the temp table,
  -- rolling distribution data up into line location subtotals. This is done
  -- to accomodate the fact that some totals fields (e.g. received/shipped)
  -- only live at the line location level.  If the caller passed in the
  -- p_doc_level for totals as DISTRIBUTION, then set these line location
  -- fields to zero.
  -- SQL WHERE: All distributions under the given document level
  FORALL i IN 1 .. l_distribution_id_tbl.COUNT
  INSERT INTO PO_DOCUMENT_TOTALS_GT
  (
    key,
    line_location_id,
    amount_based_flag,
    shipment_type,
    payment_type,
    price,
    quantity_total,
    quantity_billed,
    quantity_delivered,
    quantity_financed,
    quantity_recouped,
    quantity_received,
    quantity_shipped,
    amount_total,
    amount_billed,
    amount_delivered,
    amount_financed,
    amount_recouped,
    amount_received,
    amount_shipped,
    retainage_withheld_amount,
    retainage_released_amount
  )
  SELECT
    l_temp_table_key,
    POLL.line_location_id,
    DECODE(POLL.value_basis,
          'FIXED PRICE', 'Y',
          'RATE', 'Y',
          'N') amount_based_flag,
    POLL.shipment_type,
    POLL.payment_type,
    POLL.price_override,
    SUM( (nvl(POD.quantity_ordered,0) - nvl(POD.quantity_cancelled,0)) ),
    SUM( nvl(POD.quantity_billed,0) ),
    SUM( nvl(POD.quantity_delivered,0) ),
    SUM( nvl(POD.quantity_financed,0) ),
    SUM( nvl(POD.quantity_recouped,0) ),
    DECODE(p_doc_level, g_doc_level_DISTRIBUTION, 0, POLL.quantity_received),
    DECODE(p_doc_level, g_doc_level_DISTRIBUTION, 0, POLL.quantity_shipped),
    SUM( (nvl(POD.amount_ordered,0) - nvl(POD.amount_cancelled,0)) ),
    SUM( nvl(POD.amount_billed,0) ),
    SUM( nvl(POD.amount_delivered,0) ),
    SUM( nvl(POD.amount_financed,0) ),
    SUM( nvl(POD.amount_recouped,0) ),
    DECODE(p_doc_level, g_doc_level_DISTRIBUTION, 0, POLL.amount_received),
    DECODE(p_doc_level, g_doc_level_DISTRIBUTION, 0, POLL.amount_shipped),
    SUM( nvl(POD.retainage_withheld_amount,0) ),
    SUM( nvl(POD.retainage_released_amount,0) )
  FROM
    PO_LINE_LOCATIONS_ARCHIVE_ALL POLL,
    PO_DISTRIBUTIONS_ARCHIVE_ALL POD
  WHERE POD.po_distribution_id = l_distribution_id_tbl(i)
  AND POD.revision_num = l_distribution_rev_num_tbl(i)
  AND POD.line_location_id = POLL.line_location_id
  AND (  (p_doc_revision_num IS NULL AND POLL.latest_external_flag = 'Y')
      OR (p_doc_revision_num IS NOT NULL
          AND POLL.revision_num =
             (SELECT max(POLL2.revision_num)
              FROM PO_LINE_LOCATIONS_ARCHIVE_ALL POLL2
              WHERE POLL2.line_location_id = POLL.line_location_id
              AND POLL2.revision_num <= p_doc_revision_num)
          )
      )
  GROUP BY POLL.line_location_id, POLL.value_basis, POLL.shipment_type,
    POLL.payment_type, POLL.price_override, POLL.quantity_received,
    POLL.quantity_shipped, POLL.amount_received, POLL.amount_shipped
  ;

  x_count := nvl(SQL%ROWCOUNT, 0);

  d_position := 60;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Inserted data - rowcount:',x_count);
  END IF;

ELSE

  d_position := 70;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Invalid data source: ', p_data_source);
  END IF;

END IF;

x_temp_table_key := l_temp_table_key;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_temp_table_key',x_count);
  PO_LOG.proc_end(d_mod,'x_temp_table_key',x_temp_table_key);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END populate_temp_table;


-------------------------------------------------------------------------------
--Start of Comments
--Name: prepare_temp_table_data
--Pre-reqs:
--  PO_DOCUMENT_TOTALS_GT must be populated appropriately.
--Modifies:
--  PO_DOCUMENT_TOTALS_GT
--Locks:
--  None.
--Function:
-- Performs intermediate calculations on input data to the GTT.
--  * Calculates amount_total for quantity lines
--  * Performs rounding on the calculated amount_total
--Parameters:
--IN:
--p_temp_table_key
--  The unique key value that identifies all rows in PO_DOCUMENT_TOTALS_GT
--  related to this transaction
--p_document_id
--  The po_header_id for POs; the po_release_id for Releases
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE prepare_temp_table_data(
  p_temp_table_key  IN  NUMBER,
  p_document_id  IN  NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'prepare_temp_table_data');
  d_position NUMBER := 0;

  l_base_currency_code       GL_CURRENCIES.currency_code%TYPE;
  l_doc_currency_code        GL_CURRENCIES.currency_code%TYPE;
  l_precision                GL_CURRENCIES.precision%TYPE;
  l_mau                      GL_CURRENCIES.minimum_accountable_unit%TYPE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_temp_table_key',p_temp_table_key);
  PO_LOG.proc_begin(d_mod,'p_document_id',p_document_id);
END IF;

  -- The results will be in PO currency (foreign currency).
  -- arusingh <Complex Work R12 TODO>:refactor API to handle release_id case
  PO_CORE_S2.get_po_currency(
    x_object_id => p_document_id,            --in param
    x_base_currency => l_base_currency_code, --out param
    x_po_currency => l_doc_currency_code     --out param
  );

  d_position := 10;

  -- Retrieve the foreign currency precision/mau for rounding
  PO_CORE_S2.get_currency_info(
    x_currency_code => l_doc_currency_code, --in param
    x_precision => l_precision, --out param
    x_min_unit => l_mau  --out param
  );

  d_position := 20;

  --SQL What: Calculate the amount columns for quantity based rows
  --SQL Where: Quantity-based rows
  UPDATE PO_DOCUMENT_TOTALS_GT GTT
  SET
    GTT.amount_total = (GTT.quantity_total * GTT.price)
  , GTT.amount_billed = (GTT.quantity_billed * GTT.price)
  , GTT.amount_delivered = (GTT.quantity_delivered * GTT.price)
  , GTT.amount_financed = (GTT.quantity_financed * GTT.price)
  , GTT.amount_recouped = (GTT.quantity_recouped * GTT.price)
  , GTT.amount_received = (GTT.quantity_received * GTT.price)
  , GTT.amount_shipped  = (GTT.quantity_shipped * GTT.price)
  WHERE amount_based_flag = 'N'
  ;

  d_position := 30;

  --SQL What: Round the calculated amounts to correct precision
  --SQL Where: Quantity-based rows
  UPDATE PO_DOCUMENT_TOTALS_GT GTT
  SET
    GTT.amount_total = nvl2(l_mau
                           , round(amount_total/l_mau) * l_mau
                           , round(amount_total, l_precision))
  , GTT.amount_billed = nvl2(l_mau
                            , round(amount_billed/l_mau) * l_mau
                            , round(amount_billed, l_precision))
  , GTT.amount_delivered = nvl2(l_mau
                               , round(amount_delivered/l_mau) * l_mau
                               , round(amount_delivered, l_precision))
  , GTT.amount_financed = nvl2(l_mau
                              , round(amount_financed/l_mau) * l_mau
                              , round(amount_financed, l_precision))
  , GTT.amount_recouped = nvl2(l_mau
                              , round(amount_recouped/l_mau) * l_mau
                              , round(amount_recouped, l_precision))
  , GTT.amount_received = nvl2(l_mau
                              , round(amount_received/l_mau) * l_mau
                              , round(amount_received, l_precision))
  , GTT.amount_shipped = nvl2(l_mau
                             , round(amount_shipped/l_mau) * l_mau
                             , round(amount_shipped, l_precision))
  WHERE GTT.amount_based_flag = 'N'
  ;

  d_position := 40;

  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Updated amts - rowcount:',SQL%ROWCOUNT);
    PO_LOG.proc_end(d_mod);
  END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END prepare_temp_table_data;



-------------------------------------------------------------------------------
--Start of Comments
--Name: calculate_totals
--Pre-reqs:
--  PO_DOCUMENT_TOTALS_GT must be populated appropriately
--Modifies:
--  None.
--Locks:
--  None.
--Function:
-- Based on the values in the temp table, calculates totals for various
-- columns (total order, billed, etc.).  Handles normal and Complex Work cases.
--Parameters:
--IN:
--p_temp_table_key
--  The unique key value that identifies all rows in PO_DOCUMENT_TOTALS_GT
--  related to this transaction
--p_document_id
--  The po_header_id for POs; the po_release_id for Releases
--p_doc_level
--  The level for which calculations are being done.  Use g_doc_level_<>
--    HEADER
--    LINE
--    SHIPMENT
--    DISTRIBUTION
--OUT:
--x_quantity_total
--  The total active (uncancelled) quantity ordered for the document level
--x_amount_total
--  The total active (uncancelled) amount ordered for the document level
--x_quantity_delivered
--  The total quantity delivered for the document level
--x_amount_delivered
--  The total amount delivered for the document level
--x_quantity_received
--  The total quantity received for the document level.
--  Always zero if the document level is 'DISTRIBUTION'
--x_amount_received
--  The total amount received for the document level
--  Always zero if the document level is 'DISTRIBUTION'
--x_quantity_shipped
--  The total quantity shipped for the document level.
--  Always zero if the document level is 'DISTRIBUTION'
--x_amount_shipped
--  The total amount shipped for the document level
--  Always zero if the document level is 'DISTRIBUTION'
--x_quantity_billed
--  The total quantity billed for the document level
--x_amount_billed
--  The total amount billed for the document level
--x_quantity_financed
--  The total quantity financed for the document level
--x_amount_financed
--  The total amount financed for the document level
--x_quantity_recouped
--  The total quantity recouped for the document level
--x_amount_recouped
--  The total amount recouped for the document level
--x_retainage_withheld_amount
--  The total retainage withheld for the document level
--x_retainage_released_amount
--  The total retainage released for the document level
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE calculate_totals(
  p_temp_table_key               IN  NUMBER,
  p_document_id                  IN  NUMBER,
  p_doc_level                    IN  VARCHAR2,
  x_quantity_total               OUT NOCOPY NUMBER,
  x_amount_total                 OUT NOCOPY NUMBER,
  x_quantity_delivered           OUT NOCOPY NUMBER,
  x_amount_delivered             OUT NOCOPY NUMBER,
  x_quantity_received            OUT NOCOPY NUMBER,
  x_amount_received              OUT NOCOPY NUMBER,
  x_quantity_shipped             OUT NOCOPY NUMBER,
  x_amount_shipped               OUT NOCOPY NUMBER,
  x_quantity_billed              OUT NOCOPY NUMBER,
  x_amount_billed                OUT NOCOPY NUMBER,
  x_quantity_financed            OUT NOCOPY NUMBER,
  x_amount_financed              OUT NOCOPY NUMBER,
  x_quantity_recouped            OUT NOCOPY NUMBER,
  x_amount_recouped              OUT NOCOPY NUMBER,
  x_retainage_withheld_amount    OUT NOCOPY NUMBER,
  x_retainage_released_amount    OUT NOCOPY NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'calculate_totals');
  d_position NUMBER := 0;

  l_quantity_total_actuals NUMBER :=0;
  l_quantity_total_financing NUMBER := 0;
  l_quantity_delivered_actuals NUMBER :=0;
  l_quantity_delivered_financing NUMBER := 0;
  l_quantity_received_actuals NUMBER := 0;
  l_quantity_received_financing NUMBER := 0;
  l_quantity_shipped_actuals NUMBER := 0;
  l_quantity_shipped_financing NUMBER := 0;
  l_quantity_billed NUMBER := 0;
  l_quantity_financed NUMBER := 0;
  l_quantity_recouped NUMBER := 0;
  l_amount_total_actuals NUMBER := 0;
  l_amount_total_financing NUMBER := 0;
  l_amount_delivered_actuals NUMBER := 0;
  l_amount_delivered_financing NUMBER := 0;
  l_amount_received_actuals NUMBER := 0;
  l_amount_received_financing NUMBER := 0;
  l_amount_shipped_actuals NUMBER := 0;
  l_amount_shipped_financing NUMBER := 0;
  l_amount_billed NUMBER := 0;
  l_amount_financed NUMBER := 0;
  l_amount_recouped NUMBER := 0;
  l_retainage_withheld_amount NUMBER := 0;
  l_retainage_released_amount NUMBER := 0;
  l_is_complex_work_po BOOLEAN := FALSE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_temp_table_key',p_temp_table_key);
  PO_LOG.proc_begin(d_mod,'p_document_id',p_document_id);
  PO_LOG.proc_begin(d_mod,'p_doc_level',p_doc_level);
END IF;

  l_is_complex_work_po :=
    PO_COMPLEX_WORK_PVT.is_complex_work_po(p_document_id);

  d_position := 10;

  -- This method will sum the various columns.  Note that we need to store
  -- separate sums for actuals vs. financing for the received, shipped and
  -- delivered columns.  This is because RCV reuses the same columns for both
  -- financing and actual line locations.  We do not need to do this for
  -- billed and financed, because AP will only use the billed column for
  -- actuals and the financed column for financing.  And since retainage only
  -- applies to actual line locations, it does not make sense to store a
  -- separate variable for retainage on financing line locations.

  -- First, do the calculations for the amount rows, as this calculation
  -- is the same for all cases

  -- SQL WHAT: Sum up the amount columns.
  -- SQL WHERE: All rows in the GTT for this trxn
  SELECT
    SUM(CASE WHEN GTT.shipment_type <> C_ship_type_PREPAYMENT
             THEN amount_total ELSE 0 END) amount_total_actuals,
    SUM(CASE WHEN GTT.shipment_type = C_ship_type_PREPAYMENT
             THEN amount_total ELSE 0 END) amount_total_financing,
    SUM(CASE WHEN GTT.shipment_type <> C_ship_type_PREPAYMENT
             THEN amount_delivered ELSE 0 END) amount_delivered_actuals,
    SUM(CASE WHEN GTT.shipment_type = C_ship_type_PREPAYMENT
             THEN amount_delivered ELSE 0 END) amount_delivered_financing,
    SUM(CASE WHEN GTT.shipment_type <> C_ship_type_PREPAYMENT
             THEN amount_received ELSE 0 END) amount_received_actuals,
    SUM(CASE WHEN GTT.shipment_type = C_ship_type_PREPAYMENT
             THEN amount_received ELSE 0 END) amount_received_financing,
    SUM(CASE WHEN GTT.shipment_type <> C_ship_type_PREPAYMENT
             THEN amount_shipped ELSE 0 END) amount_shipped_actuals,
    SUM(CASE WHEN GTT.shipment_type = C_ship_type_PREPAYMENT
             THEN amount_shipped ELSE 0 END) amount_shipped_financing,
    SUM(amount_billed),
    SUM(amount_financed),
    SUM(amount_recouped),
    SUM(retainage_withheld_amount),
    SUM(retainage_released_amount)
  INTO
    l_amount_total_actuals,
    l_amount_total_financing,
    l_amount_delivered_actuals,
    l_amount_delivered_financing,
    l_amount_received_actuals,
    l_amount_received_financing,
    l_amount_shipped_actuals,
    l_amount_shipped_financing,
    l_amount_billed,
    l_amount_financed,
    l_amount_recouped,
    l_retainage_withheld_amount,
    l_retainage_released_amount
  FROM PO_DOCUMENT_TOTALS_GT GTT
  WHERE key = p_temp_table_key
  ;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Amount totals - rowcount:',SQL%ROWCOUNT);
  END IF;

  -- Next, do the calculations for the quantity rows, which is broken into
  -- 2 cases: a summation case and a max-value case

  IF (NOT l_is_complex_work_po) THEN
    -- Normal Shipments (non-Complex Work) case

    d_position := 30;

    -- SQL WHAT: Sums up the quantity columns for normal shipments
    -- SQL WHERE: All qty-based GTT rows for this trxn
    SELECT
      SUM(quantity_total),
      SUM(quantity_delivered),
      SUM(quantity_received),
      SUM(quantity_shipped),
      SUM(quantity_billed),
      SUM(quantity_financed),
      SUM(quantity_recouped)
    INTO
      l_quantity_total_actuals,
      l_quantity_delivered_actuals,
      l_quantity_received_actuals,
      l_quantity_shipped_actuals,
      l_quantity_billed,
      l_quantity_financed,
      l_quantity_recouped
    FROM PO_DOCUMENT_TOTALS_GT GTT
    WHERE GTT.key = p_temp_table_key
    AND GTT.amount_based_flag = 'N'
    AND nvl(GTT.payment_type, 'NULL') <> C_payment_type_RATE
    ;

   d_position := 40;
   IF PO_LOG.d_stmt THEN
     PO_LOG.stmt(d_mod,d_position,'Sum Qty totals - rowcount:',SQL%ROWCOUNT);
   END IF;

  ELSE
    -- Qty Milestone Pay Items case for Header, Line, Line Loc level totals

    d_position := 40;

    -- SQL WHAT: For Complex Work Qty-based lines, the total is based on
    -- the max received, billed etc against the individual Milestone pay items
    -- SQL WHERE: All qty-based GTT rows for this trxn
    SELECT
      MAX(GTTSUM.qty_total_actuals),
      MAX(GTTSUM.qty_total_financing),
      MAX(GTTSUM.qty_delivered_actuals),
      MAX(GTTSUM.qty_delivered_financing),
      MAX(GTTSUM.qty_received_actuals),
      MAX(GTTSUM.qty_received_financing),
      MAX(GTTSUM.qty_shipped_actuals),
      MAX(GTTSUM.qty_shipped_financing),
      MAX(GTTSUM.qty_billed),
      MAX(GTTSUM.qty_financed),
      MAX(GTTSUM.qty_recouped)
    INTO
      l_quantity_total_actuals,
      l_quantity_total_financing,
      l_quantity_delivered_actuals,
      l_quantity_delivered_financing,
      l_quantity_received_actuals,
      l_quantity_received_financing,
      l_quantity_shipped_actuals,
      l_quantity_shipped_financing,
      l_quantity_billed,
      l_quantity_financed,
      l_quantity_recouped
    FROM
    ( SELECT
        GTT.line_location_id,
        SUM(CASE
              WHEN GTT.shipment_type <> C_ship_type_PREPAYMENT
              THEN GTT.quantity_total ELSE 0 END) qty_total_actuals,
        SUM(CASE
              WHEN GTT.shipment_type = C_ship_type_PREPAYMENT
              THEN GTT.quantity_total ELSE 0 END) qty_total_financing,
        SUM(CASE
              WHEN GTT.shipment_type <> C_ship_type_PREPAYMENT
              THEN GTT.quantity_delivered ELSE 0 END) qty_delivered_actuals,
        SUM(CASE
              WHEN GTT.shipment_type = C_ship_type_PREPAYMENT
              THEN GTT.quantity_delivered ELSE 0 END) qty_delivered_financing,
        SUM(CASE
              WHEN GTT.shipment_type <> C_ship_type_PREPAYMENT
              THEN GTT.quantity_received ELSE 0 END) qty_received_actuals,
        SUM(CASE
              WHEN GTT.shipment_type = C_ship_type_PREPAYMENT
              THEN GTT.quantity_received ELSE 0 END) qty_received_financing,
        SUM(CASE
              WHEN GTT.shipment_type <> C_ship_type_PREPAYMENT
              THEN GTT.quantity_shipped ELSE 0 END) qty_shipped_actuals,
        SUM(CASE
              WHEN GTT.shipment_type = C_ship_type_PREPAYMENT
              THEN GTT.quantity_shipped ELSE 0 END) qty_shipped_financing,
        SUM(GTT.quantity_billed) qty_billed,
        SUM(GTT.quantity_financed) qty_financed,
        SUM(GTT.quantity_recouped) qty_recouped
      FROM PO_DOCUMENT_TOTALS_GT GTT
      WHERE GTT.key = p_temp_table_key
      AND GTT.amount_based_flag = 'N'
      AND nvl(GTT.payment_type, 'NULL') = C_payment_type_MILESTONE
      GROUP BY GTT.line_location_id
    ) GTTSUM
    ;

    d_position := 50;
    IF PO_LOG.d_stmt THEN
      PO_LOG.stmt(d_mod,d_position,'Max Qty totals - rowcount:',SQL%ROWCOUNT);
    END IF;

  END IF;

  -- Assign return values.  Always return the actuals result value if both
  -- actuals and financing values exist.
  x_quantity_total :=
    CASE WHEN (l_quantity_total_actuals > 0) THEN l_quantity_total_actuals
    ELSE l_quantity_total_financing END;

  x_amount_total :=
    CASE WHEN (l_amount_total_actuals > 0) THEN l_amount_total_actuals
    ELSE l_amount_total_financing END;

  x_quantity_delivered :=
    CASE WHEN (l_quantity_delivered_actuals > 0) THEN l_quantity_delivered_actuals
    ELSE l_quantity_delivered_financing END;

  x_amount_delivered :=
   CASE WHEN (l_amount_delivered_actuals > 0) THEN l_amount_delivered_actuals
    ELSE l_amount_delivered_financing END;

  x_quantity_received :=
    CASE WHEN (l_quantity_received_actuals > 0) THEN l_quantity_received_actuals
    ELSE l_quantity_received_financing END;

  x_amount_received :=
   CASE WHEN (l_amount_received_actuals > 0) THEN l_amount_received_actuals
    ELSE l_amount_received_financing END;

  x_quantity_shipped :=
    CASE WHEN (l_quantity_shipped_actuals > 0) THEN l_quantity_shipped_actuals
    ELSE l_quantity_shipped_financing END;

  x_amount_shipped :=
   CASE WHEN (l_amount_shipped_actuals > 0) THEN l_amount_shipped_actuals
    ELSE l_amount_shipped_financing END;

  x_quantity_billed := l_quantity_billed;
  x_amount_billed := l_amount_billed;
  x_quantity_financed := l_quantity_financed;
  x_amount_financed := l_amount_financed;
  x_quantity_recouped := l_quantity_recouped;
  x_amount_recouped := l_amount_recouped;
  x_retainage_withheld_amount := l_retainage_withheld_amount;
  x_retainage_released_amount := l_retainage_released_amount;


IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod,'x_quantity_total',x_quantity_total);
  PO_LOG.proc_end(d_mod,'x_amount_total', x_amount_total);
  PO_LOG.proc_end(d_mod,'x_quantity_delivered', x_quantity_delivered);
  PO_LOG.proc_end(d_mod,'x_amount_delivered', x_amount_delivered);
  PO_LOG.proc_end(d_mod,'x_quantity_received', x_quantity_received);
  PO_LOG.proc_end(d_mod,'x_amount_received', x_amount_received);
  PO_LOG.proc_end(d_mod,'x_quantity_shipped', x_quantity_shipped);
  PO_LOG.proc_end(d_mod,'x_amount_shipped', x_amount_shipped);
  PO_LOG.proc_end(d_mod,'x_quantity_billed', x_quantity_billed);
  PO_LOG.proc_end(d_mod,'x_amount_billed', x_amount_billed);
  PO_LOG.proc_end(d_mod,'x_quantity_financed', x_quantity_financed);
  PO_LOG.proc_end(d_mod,'x_amount_financed', x_amount_financed);
  PO_LOG.proc_end(d_mod,'x_quantity_recouped', x_quantity_recouped);
  PO_LOG.proc_end(d_mod,'x_amount_recouped', x_amount_recouped);
  PO_LOG.proc_end(d_mod,'x_retainage_withheld_amount', x_retainage_withheld_amount);
  PO_LOG.proc_end(d_mod,'x_retainage_released_amount', x_retainage_released_amount);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END calculate_totals;


-------------------------------------------------------------------------------
--Start of Comments
--Name: clear_temp_table
--Pre-reqs:
--  None.
--Modifies:
--  PO_DOCUMENT_TOTALS_GT
--Locks:
--  None.
--Function:
-- Deletes data from the temp table for this transaction
--Parameters:
--IN:
--p_temp_table_key
--  The unique key value that identifies all rows in PO_DOCUMENT_TOTALS_GT
--  related to this transaction
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE clear_temp_table(
  p_temp_table_key IN NUMBER
)
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'clear_temp_table');
  d_position NUMBER := 0;

BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_temp_table_key',p_temp_table_key);
END IF;

  d_position := 10;

  -- SQL WHAT: Clear the temp table
  -- SQL WHERE: All data for this transaction
  DELETE FROM PO_DOCUMENT_TOTALS_GT
  WHERE key = p_temp_table_key
  ;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'Deleted data - rowcount:',SQL%ROWCOUNT);
  END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod);
END IF;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END clear_temp_table;

--Bug 19389097:
-------------------------------------------------------------------------------
--Start of Comments
--Name: getTotalShipQuantityForLine
--Pre-reqs:
--  None
--Modifies:
--  None
--Locks:
--  None
--Function:
-- Calculates the total ship quantity of the saved line locs for a line
-- This API is only intended for QUANTITY-BASED LINES
--   For normal SPOs, this is the sum of the shipment ship quantities
--   For CWPOs, quantity-based lines have milestone pay items which all
--   have the same quantity as the line, so the line quantity is returned
-- The API supports only the SPO document type.
--Parameters:
--IN:
--p_line_id
--  The ID of the line for which to calculate the line loc total quantity
--Testing:
--
--End of Comments
-------------------------------------------------------------------------------
FUNCTION getTotalShipQuantityForLine(
  p_line_id IN NUMBER
) RETURN NUMBER
IS
  d_mod CONSTANT VARCHAR2(100) :=
    PO_LOG.get_subprogram_base(D_PACKAGE_BASE,'getTotalShipQuantityForLine');
  d_position NUMBER := 0;
  l_return_val NUMBER := 0;
  l_header_id PO_HEADERS_ALL.po_header_id%TYPE;
  l_is_complex_work_po BOOLEAN := FALSE;
BEGIN

IF PO_LOG.d_proc THEN
  PO_LOG.proc_begin(d_mod,'p_line_id',p_line_id);
END IF;

  d_position := 10;

  SELECT pol.po_header_id
  INTO l_header_id
  FROM po_lines_all pol
  WHERE pol.po_line_id = p_line_id
  ;

  d_position := 20;
  IF PO_LOG.d_stmt THEN
    PO_LOG.stmt(d_mod,d_position,'l_header_id:',l_header_id);
  END IF;

  l_is_complex_work_po
    := PO_COMPLEX_WORK_PVT.is_complex_work_po(l_header_id);

IF (NOT l_is_complex_work_po) THEN
  --Non Complex Work case

  d_position := 30;

  BEGIN
    SELECT nvl(SUM(poll.quantity),0) - nvl(sum(poll.quantity_cancelled),0)
    INTO l_return_val
    FROM po_line_locations_all poll
    WHERE poll.po_line_id = p_line_id
    AND poll.shipment_type = 'STANDARD'
    ;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      IF PO_LOG.d_stmt THEN
        PO_LOG.stmt(d_mod,d_position,'No line locations exist');
      END IF;
      l_return_val := 0;
  END;

ELSE
  --Complex Work case
  --For Qty-based Complex Work lines, all Milestone
  --Pay Items have the same quantity as the line

  d_position := 40;

  SELECT nvl(pol.quantity, 0)
  INTO l_return_val
  FROM po_lines_all pol
  WHERE pol.po_line_id = p_line_id
  ;

END IF;

IF l_return_val < 0 THEN
   l_return_val :=0;
END IF;

IF PO_LOG.d_proc THEN
  PO_LOG.proc_end(d_mod, 'l_return_val', l_return_val);
END IF;

RETURN l_return_val;

EXCEPTION
WHEN OTHERS THEN
  IF PO_LOG.d_exc THEN
    PO_LOG.exc(d_mod,d_position,NULL);
  END IF;
  RAISE;
END getTotalShipQuantityForLine;

END PO_DOCUMENT_TOTALS_PVT;

/
