--------------------------------------------------------
--  DDL for Package Body PO_COMPLEX_WORK_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COMPLEX_WORK_PVT" AS
-- $Header: PO_COMPLEX_WORK_PVT.plb 120.3 2005/09/18 22:48:34 spangulu noship $

------------------------------------------------------------------------------
--Start of Comments
--Name: get_payment_style_settings
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure returns all important flags related to complex
--  work procurement that can be derived from a style.
--Parameters:
--IN:
--  p_style_id
--    ID of the style to get the complex work flags for.
--OUT:
--  x_complex_work_flag
--    'Y': Any document with this style uses progress payments.
--    'N': Any document with this style cannot use progress payments.
--  x_financing_payments_flag
--    'Y': All user entered payitems for a document with this style
--         are financing (prepayment) pay items.
--    'N': All user entered payitems for a document with this style
--         are actual (standard) pay items.
--  x_retainage_allowed_flag
--    'Y': Retainage terms can be specified as part of the document.
--    'N': Retainage terms cannot be specified in the document.
--  x_advance_allowed_flag
--    'Y': An advance amount can be specified at the line level.
--    'N': Advance amounts cannot be specified.
--  x_milestone_allowed_flag
--    'Y': Complex work POs with this style can contain pay items of type MILESTONE.
--    'N': Complex work POs with this style cannot contain pay items of type MILESTONE.
--  x_lumpsum_allowed_flag
--    'Y': Complex work POs with this style can contain pay items of type LUMPSUM.
--    'N': Complex work POs with this style cannot contain pay items of type LUMPSUM.
--  x_rate_allowed_flag
--    'Y': Complex work POs with this style can contain pay items of type RATE.
--    'N': Complex work POs with this style cannot contain pay items of type RATE.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_payment_style_settings(
  p_style_id                 IN          NUMBER
, x_complex_work_flag        OUT NOCOPY  VARCHAR2
, x_financing_payments_flag  OUT NOCOPY  VARCHAR2
, x_retainage_allowed_flag   OUT NOCOPY  VARCHAR2
, x_advance_allowed_flag     OUT NOCOPY  VARCHAR2
, x_milestone_allowed_flag   OUT NOCOPY  VARCHAR2
, x_lumpsum_allowed_flag     OUT NOCOPY  VARCHAR2
, x_rate_allowed_flag        OUT NOCOPY  VARCHAR2
)
IS

  d_progress     NUMBER;
  d_module       VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_PVT.get_payment_style_settings';

  l_style_name           PO_DOC_STYLE_HEADERS.style_name%TYPE;
  l_style_desc           PO_DOC_STYLE_HEADERS.style_description%TYPE;
  l_style_type           PO_DOC_STYLE_HEADERS.style_type%TYPE;
  l_status               PO_DOC_STYLE_HEADERS.status%TYPE;
  l_price_breaks_flag    PO_DOC_STYLE_HEADERS.price_breaks_flag%TYPE;
  l_price_diffs_flag     PO_DOC_STYLE_HEADERS.price_differentials_flag%TYPE;
  l_line_type_allowed    PO_DOC_STYLE_HEADERS.line_type_allowed%TYPE;

  TYPE t_payment_type_tbl IS TABLE OF PO_STYLE_ENABLED_PAY_ITEMS.pay_item_type%TYPE;
  l_payment_types_tbl    t_payment_type_tbl;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_style_id', p_style_id);
  END IF;

  d_progress := 10;

  PO_DOC_STYLE_GRP.get_document_style_settings(
    p_api_version              => 1.0
  , p_style_id                 => p_style_id
  , x_style_name               => l_style_name
  , x_style_description        => l_style_desc
  , x_style_type               => l_style_type
  , x_status                   => l_status
  , x_advances_flag            => x_advance_allowed_flag
  , x_retainage_flag           => x_retainage_allowed_flag
  , x_price_breaks_flag        => l_price_breaks_flag
  , x_price_differentials_flag => l_price_diffs_flag
  , x_progress_payment_flag    => x_complex_work_flag
  , x_contract_financing_flag  => x_financing_payments_flag
  , x_line_type_allowed        => l_line_type_allowed
  );

  d_progress := 20;

  x_advance_allowed_flag := NVL(x_advance_allowed_flag, 'N');
  x_retainage_allowed_flag := NVL(x_retainage_allowed_flag, 'N');
  x_complex_work_flag := NVL(x_complex_work_flag, 'N');
  x_financing_payments_flag := NVL(x_financing_payments_flag, 'N');

  d_progress := 30;

  SELECT psepi.pay_item_type
  BULK COLLECT INTO l_payment_types_tbl
  FROM po_style_enabled_pay_items psepi
  WHERE psepi.style_id = p_style_id;

  d_progress := 40;

  x_milestone_allowed_flag := 'N';
  x_lumpsum_allowed_flag := 'N';
  x_rate_allowed_flag := 'N';

  d_progress := 50;

  FOR i IN 1..l_payment_types_tbl.COUNT
  LOOP

    IF (l_payment_types_tbl(i) = g_payment_type_MILESTONE) THEN

      x_milestone_allowed_flag := 'Y';

    ELSIF (l_payment_types_tbl(i) = g_payment_type_LUMPSUM) THEN

      x_lumpsum_allowed_flag := 'Y';

    ELSIF (l_payment_types_tbl(i) = g_payment_type_RATE) THEN

      x_rate_allowed_flag := 'Y';

    END IF;

  END LOOP;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_complex_work_flag', x_complex_work_flag);
    PO_LOG.proc_end(d_module, 'x_financing_payments_flag', x_financing_payments_flag);
    PO_LOG.proc_end(d_module, 'x_retainage_allowed_flag', x_retainage_allowed_flag);
    PO_LOG.proc_end(d_module, 'x_advance_allowed_flag', x_advance_allowed_flag);
    PO_LOG.proc_end(d_module, 'x_milestone_allowed_flag', x_milestone_allowed_flag);
    PO_LOG.proc_end(d_module, 'x_lumpsum_allowed_flag', x_lumpsum_allowed_flag);
    PO_LOG.proc_end(d_module, 'x_rate_allowed_flag', x_rate_allowed_flag);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    RAISE;
END get_payment_style_settings;


------------------------------------------------------------------------------
--Start of Comments
--Name: is_complex_work_style
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function will determine whether a style indicates complex work.
--Parameters:
--IN:
--  p_style_id
--    ID of the style to get the complex work flags for.
--RETURNS:
--  TRUE: Any document with this style uses progress payments
--  FALSE: Any document with this style cannot use progress payments.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_complex_work_style(p_style_id IN NUMBER) RETURN BOOLEAN
IS

 d_module     VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_PVT.is_complex_work_style';
 d_progress   NUMBER;

 l_style_name           PO_DOC_STYLE_HEADERS.style_name%TYPE;
 l_style_desc           PO_DOC_STYLE_HEADERS.style_description%TYPE;
 l_style_type           PO_DOC_STYLE_HEADERS.style_type%TYPE;
 l_status               PO_DOC_STYLE_HEADERS.status%TYPE;
 l_advances_flag        PO_DOC_STYLE_HEADERS.advances_flag%TYPE;
 l_retainage_flag       PO_DOC_STYLE_HEADERS.retainage_flag%TYPE;
 l_price_breaks_flag    PO_DOC_STYLE_HEADERS.price_breaks_flag%TYPE;
 l_price_diffs_flag     PO_DOC_STYLE_HEADERS.price_differentials_flag%TYPE;
 l_complex_work_flag    PO_DOC_STYLE_HEADERS.progress_payment_flag%TYPE;
 l_financing_flag       PO_DOC_STYLE_HEADERS.contract_financing_flag%TYPE;
 l_line_type_allowed    PO_DOC_STYLE_HEADERS.line_type_allowed%TYPE;

 l_is_complex_style        BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_style_id', p_style_id);
  END IF;

  d_progress := 10;

  PO_DOC_STYLE_GRP.get_document_style_settings(
    p_api_version              => 1.0
  , p_style_id                 => p_style_id
  , x_style_name               => l_style_name
  , x_style_description        => l_style_desc
  , x_style_type               => l_style_type
  , x_status                   => l_status
  , x_advances_flag            => l_advances_flag
  , x_retainage_flag           => l_retainage_flag
  , x_price_breaks_flag        => l_price_breaks_flag
  , x_price_differentials_flag => l_price_diffs_flag
  , x_progress_payment_flag    => l_complex_work_flag
  , x_contract_financing_flag  => l_financing_flag
  , x_line_type_allowed        => l_line_type_allowed
  );

  d_progress := 20;

  IF (NVL(l_complex_work_flag, 'N') = 'Y')
  THEN
    l_is_complex_style := TRUE;
  ELSE
    l_is_complex_style := FALSE;
  END IF;

  d_progress := 30;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_is_complex_style);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN l_is_complex_style;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    RAISE;
END is_complex_work_style;


------------------------------------------------------------------------------
--Start of Comments
--Name: is_financing_payment_style
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function will determine whether a style indicates that payitems for
--  a document are of type financing (PREPAYMENT) as opposed to actuals (STANDARD).
--  Note: This function will not first check if a style is complex work enabled.
--Parameters:
--IN:
--  p_style_id
--    ID of the style to get the complex work flags for.
--RETURNS:
--  TRUE: Any document with this style uses financing progress payments.
--  FALSE: Any document with this style uses actuals progress payments.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_financing_payment_style(p_style_id IN NUMBER) RETURN BOOLEAN
IS

 d_module     VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_PVT.is_financing_payment_style';
 d_progress   NUMBER;

 l_style_name           PO_DOC_STYLE_HEADERS.style_name%TYPE;
 l_style_desc           PO_DOC_STYLE_HEADERS.style_description%TYPE;
 l_style_type           PO_DOC_STYLE_HEADERS.style_type%TYPE;
 l_status               PO_DOC_STYLE_HEADERS.status%TYPE;
 l_advances_flag        PO_DOC_STYLE_HEADERS.advances_flag%TYPE;
 l_retainage_flag       PO_DOC_STYLE_HEADERS.retainage_flag%TYPE;
 l_price_breaks_flag    PO_DOC_STYLE_HEADERS.price_breaks_flag%TYPE;
 l_price_diffs_flag     PO_DOC_STYLE_HEADERS.price_differentials_flag%TYPE;
 l_complex_work_flag    PO_DOC_STYLE_HEADERS.progress_payment_flag%TYPE;
 l_financing_flag       PO_DOC_STYLE_HEADERS.contract_financing_flag%TYPE;
 l_line_type_allowed    PO_DOC_STYLE_HEADERS.line_type_allowed%TYPE;

 l_is_financing_style   BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_style_id', p_style_id);
  END IF;

  d_progress := 10;

  PO_DOC_STYLE_GRP.get_document_style_settings(
    p_api_version              => 1.0
  , p_style_id                 => p_style_id
  , x_style_name               => l_style_name
  , x_style_description        => l_style_desc
  , x_style_type               => l_style_type
  , x_status                   => l_status
  , x_advances_flag            => l_advances_flag
  , x_retainage_flag           => l_retainage_flag
  , x_price_breaks_flag        => l_price_breaks_flag
  , x_price_differentials_flag => l_price_diffs_flag
  , x_progress_payment_flag    => l_complex_work_flag
  , x_contract_financing_flag  => l_financing_flag
  , x_line_type_allowed        => l_line_type_allowed
  );

  d_progress := 20;

  IF (NVL(l_financing_flag, 'N') = 'Y')
  THEN
    l_is_financing_style := TRUE;
  ELSE
    l_is_financing_style := FALSE;
  END IF;

  d_progress := 30;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_is_financing_style);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN l_is_financing_style;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    RAISE;
END is_financing_payment_style;


------------------------------------------------------------------------------
--Start of Comments
--Name: is_complex_work_po
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function will determine whether a PO is a complex work PO.
--Parameters:
--IN:
--  p_po_header_id
--    Header ID of the PO to check whether or not it's a complex work PO
--RETURNS:
--  TRUE: The PO is a complex work PO
--  FALSE: The PO is not a complex work PO
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_complex_work_po(p_po_header_id IN NUMBER) RETURN BOOLEAN
IS

 d_module     VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_PVT.is_complex_work_po';
 d_progress   NUMBER;

 l_style_id             PO_HEADERS_ALL.style_id%TYPE;
 l_is_complex_po        BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
  END IF;

  d_progress := 10;

  SELECT poh.style_id
  INTO l_style_id
  FROM po_headers_all poh
  WHERE poh.po_header_id = p_po_header_id;

  d_progress := 20;

  IF (l_style_id IS NOT NULL) THEN

    d_progress := 30;
    l_is_complex_po := is_complex_work_style(p_style_id => l_style_id);

  ELSE

    d_progress := 40;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Style is NULL!');
    END IF;

    l_is_complex_po := FALSE;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_is_complex_po);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN l_is_complex_po;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    RAISE;
END is_complex_work_po;


------------------------------------------------------------------------------
--Start of Comments
--Name: is_financing_po
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function will determine whether a PO uses financing (PREPAYMENT) or
--  actuals (STANDARD) payitems.
--  Note: This function will not first check if the PO is a complex work PO.
--Parameters:
--IN:
--  p_po_header_id
--    Header ID of the PO to check financing vs. actuals for.
--RETURNS:
--  TRUE: The PO uses financing pay items
--  FALSE: The PO uses actuals pay items
--End of Comments
-------------------------------------------------------------------------------
FUNCTION is_financing_po(p_po_header_id IN NUMBER) RETURN BOOLEAN
IS

 d_module     VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_PVT.is_financing_po';
 d_progress   NUMBER;

 l_style_id             PO_HEADERS_ALL.style_id%TYPE;
 l_is_financing_po      BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
  END IF;

  d_progress := 10;

  SELECT poh.style_id
  INTO l_style_id
  FROM po_headers_all poh
  WHERE poh.po_header_id = p_po_header_id;

  d_progress := 20;

  IF (l_style_id IS NOT NULL) THEN

    d_progress := 30;
    l_is_financing_po := is_financing_payment_style(p_style_id => l_style_id);

  ELSE

    d_progress := 40;
    IF (PO_LOG.d_stmt) THEN
      PO_LOG.stmt(d_module, d_progress, 'Style is NULL!');
    END IF;

    l_is_financing_po := FALSE;

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_is_financing_po);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN l_is_financing_po;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    RAISE;
END is_financing_po;


------------------------------------------------------------------------------
--Start of Comments
--Name: get_default_payitem_info
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This procedure calculates the default payment_type, quantity, amount
--  and price from line information.  It relies on the style at the
--  header level to determine the default payment type.
--  This procedure returns values that can be used to default the first pay item
--  created for a line.
--Parameters:
--IN:
--  p_po_header_id
--    Header ID for the PO to get default payment information for
--    Style id should already be populated in the headers table
--  p_po_line_id
--    Line ID for the PO line that the payitem belongs to
--  p_line_value_basis
--    Value Basis (order_type_lookup_code) of the line that the
--    payitem belongs to.  This should be one of: 'FIXED PRICE', 'QUANTITY'
--  p_line_qty
--    Quantity at the line level
--  p_line_amt
--    Amount at the line level
--  p_price
--    Price at the line level
--OUT:
--  x_payment_type
--    Default payment type, as determined by the style settings
--    One of: g_payment_type_<>, where <> = MILESTONE, RATE, LUMPSUM
--  x_payitem_qty
--    Default quantity at the payitem level
--  x_payitem_amt
--    Default amount at the payitem level
--  x_payitem_price
--    Default price (price_override) at the payitem level
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_default_payitem_info(
  p_po_header_id          IN          NUMBER
, p_po_line_id            IN          NUMBER
, p_line_value_basis      IN          VARCHAR2
, p_line_matching_basis   IN          VARCHAR2
, p_line_qty              IN          NUMBER
, p_line_amt              IN          NUMBER
, p_line_price            IN          NUMBER
, x_payment_type          OUT NOCOPY  VARCHAR2
, x_payitem_qty           OUT NOCOPY  NUMBER
, x_payitem_amt           OUT NOCOPY  NUMBER
, x_payitem_price         OUT NOCOPY  NUMBER
)
IS

  d_module    VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_PVT.get_default_payitem_info';
  d_progress  NUMBER;

  l_style_id                PO_HEADERS.style_id%TYPE;
  l_is_complex_flag         VARCHAR2(1);
  l_is_financing_flag       VARCHAR2(1);
  l_retainage_flag          VARCHAR2(1);
  l_advance_flag            VARCHAR2(1);
  l_milestone_flag          VARCHAR2(1);
  l_lumpsum_flag            VARCHAR2(1);
  l_rate_flag               VARCHAR2(1);

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
    PO_LOG.proc_begin(d_module, 'p_po_line_id', p_po_line_id);
    PO_LOG.proc_begin(d_module, 'p_line_value_basis', p_line_value_basis);
    PO_LOG.proc_begin(d_module, 'p_line_matching_basis', p_line_matching_basis);
    PO_LOG.proc_begin(d_module, 'p_line_qty', p_line_qty);
    PO_LOG.proc_begin(d_module, 'p_line_amt', p_line_amt);
    PO_LOG.proc_begin(d_module, 'p_line_price', p_line_price);
  END IF;

  d_progress := 10;

  SELECT poh.style_id
  INTO l_style_id
  FROM po_headers_all poh
  WHERE poh.po_header_id = p_po_header_id;

  d_progress := 20;

  get_payment_style_settings(
    p_style_id                 => l_style_id
  , x_complex_work_flag        => l_is_complex_flag
  , x_financing_payments_flag  => l_is_financing_flag
  , x_retainage_allowed_flag   => l_retainage_flag
  , x_advance_allowed_flag     => l_advance_flag
  , x_milestone_allowed_flag   => l_milestone_flag
  , x_lumpsum_allowed_flag     => l_lumpsum_flag
  , x_rate_allowed_flag        => l_rate_flag
  );

  d_progress := 30;

  x_payment_type := NULL;
  x_payitem_qty := NULL;
  x_payitem_amt := NULL;
  x_payitem_price := NULL;

  d_progress := 40;

  IF (l_is_complex_flag = 'Y') THEN

    IF (p_line_value_basis = 'QUANTITY') THEN

      x_payment_type := g_payment_type_MILESTONE;
      x_payitem_price := p_line_price;
      x_payitem_qty := p_line_qty;

    ELSIF (p_line_value_basis = 'FIXED PRICE') THEN

      IF (l_lumpsum_flag = 'Y') THEN

        x_payment_type := g_payment_type_LUMPSUM;
        x_payitem_amt := p_line_amt;

      ELSIF (l_rate_flag = 'Y') THEN

        x_payment_type := g_payment_type_RATE;
        x_payitem_qty := 1;
        x_payitem_price := p_line_amt;

      ELSIF (l_milestone_flag = 'Y') THEN

        x_payment_type := g_payment_type_MILESTONE;
        x_payitem_amt := p_line_amt;

      END IF;  -- l_lumpsum_flag = 'Y'

    END IF;  -- p_line_value_basis = ...

  END IF;  -- if l_is_complex_flag = 'Y'

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_payment_type', x_payment_type);
    PO_LOG.proc_end(d_module, 'x_payitem_qty', x_payitem_qty);
    PO_LOG.proc_end(d_module, 'x_payitem_amt', x_payitem_amt);
    PO_LOG.proc_end(d_module, 'x_payitem_price', x_payitem_price);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    RAISE;
END get_default_payitem_info;


------------------------------------------------------------------------------
--Start of Comments
--Name: get_advanace_amount
--Pre-reqs:
--  None
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  This function will return the advance amount of a line, as stored
--  within its advance payitem.
--Parameters:
--IN:
--  p_po_line_id
--    Line id of the line to get advance amount for.
--  p_doc_revision_num
--    If checking for archived advance amount, pass in the document's revision
--    number.  If checking main tables, pass NULL (default).
--  p_which_tables
--    Either 'MAIN' for current line or 'ARCHIVE' for line on archived doc.
--RETURNS:
--  Advance amount, or NULL if no advance payitem exists.
--End of Comments
-------------------------------------------------------------------------------
FUNCTION get_advance_amount(
  p_po_line_id               IN          NUMBER
, p_doc_revision_num         IN          NUMBER    DEFAULT NULL
, p_which_tables             IN          VARCHAR2  DEFAULT 'MAIN'
) RETURN NUMBER
IS

  d_module    VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_PVT.get_advance_amount';
  d_progress  NUMBER;

  l_advance_amount  PO_LINE_LOCATIONS_ALL.amount%TYPE;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_po_line_id', p_po_line_id);
    PO_LOG.proc_begin(d_module, 'p_doc_revision_num', p_doc_revision_num);
    PO_LOG.proc_begin(d_module, 'p_which_tables', p_which_tables);
  END IF;

  IF (p_which_tables = 'MAIN') THEN

    d_progress := 20;

    SELECT poll.amount
    INTO l_advance_amount
    FROM po_line_locations_all poll
    WHERE poll.po_line_id = p_po_line_id
      AND poll.payment_type = 'ADVANCE';

  ELSE

    d_progress := 30;

    SELECT polla.amount
    INTO l_advance_amount
    FROM po_line_locations_archive_all polla
    WHERE polla.po_line_id = p_po_line_id
      AND polla.revision_num =
            (
               SELECT MAX(polla2.revision_num)
               FROM po_line_locations_archive_all polla2
               WHERE polla2.line_location_id = polla.line_location_id
                 AND polla2.revision_num <= p_doc_revision_num
            )
      AND polla.payment_type = 'ADVANCE';

  END IF;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_return(d_module, l_advance_amount);
    PO_LOG.proc_end(d_module);
  END IF;

  RETURN l_advance_amount;

EXCEPTION
  WHEN NO_DATA_FOUND THEN
    IF (PO_LOG.d_proc) THEN
      PO_LOG.stmt(d_module, d_progress, 'No advance found.');
      PO_LOG.proc_return(d_module, 'NULL');
      PO_LOG.proc_end(d_module);
    END IF;
    RETURN NULL;
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    RAISE;
END get_advance_amount;

END PO_COMPLEX_WORK_PVT;

/
