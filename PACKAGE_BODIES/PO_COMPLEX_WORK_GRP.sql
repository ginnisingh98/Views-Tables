--------------------------------------------------------
--  DDL for Package Body PO_COMPLEX_WORK_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_COMPLEX_WORK_GRP" AS
-- $Header: PO_COMPLEX_WORK_GRP.plb 120.0.12010000.2 2014/03/14 07:36:46 inagdeo ship $

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
--  p_api_version
--    Should be 1.0
--  p_style_id
--    ID of the style to get the complex work flags for.
--OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS: API completed successfully.
--    FND_API.G_RET_STS_UNEXP_ERROR: API was not successful; unexpected error.
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
  p_api_version              IN          NUMBER
, p_style_id                 IN          NUMBER
, x_return_status            OUT NOCOPY  VARCHAR2
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
  d_module       VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_GRP.get_payment_style_settings';

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_api_version', p_api_version);
    PO_LOG.proc_begin(d_module, 'p_style_id', p_style_id);
  END IF;

  d_progress := 10;

  PO_COMPLEX_WORK_PVT.get_payment_style_settings(
    p_style_id                 => p_style_id
  , x_complex_work_flag        => x_complex_work_flag
  , x_financing_payments_flag  => x_financing_payments_flag
  , x_retainage_allowed_flag   => x_retainage_allowed_flag
  , x_advance_allowed_flag     => x_advance_allowed_flag
  , x_milestone_allowed_flag   => x_milestone_allowed_flag
  , x_lumpsum_allowed_flag     => x_lumpsum_allowed_flag
  , x_rate_allowed_flag        => x_rate_allowed_flag
  );

  d_progress := 20;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
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
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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
--  This procedure reveals whether a style indicates complex work.
--Parameters:
--IN:
--  p_api_version
--    Should be 1.0
--  p_style_id
--    ID of the style to get the complex work flag for
--OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS: API completed successfully.
--    FND_API.G_RET_STS_UNEXP_ERROR: API was not successful; unexpected error.
--  x_is_complex_flag
--    'Y': Any document with this style uses progress payments
--    'N': Any document with this style cannot use progress payments.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_complex_work_style(
  p_api_version           IN NUMBER
, p_style_id              IN NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_is_complex_flag       OUT NOCOPY VARCHAR2
)
IS

 d_module     VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_GRP.is_complex_work_style';
 d_progress   NUMBER;

 l_is_complex_style        BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_api_version', p_api_version);
    PO_LOG.proc_begin(d_module, 'p_style_id', p_style_id);
  END IF;

  d_progress := 10;

  l_is_complex_style := PO_COMPLEX_WORK_PVT.is_complex_work_style(p_style_id);

  IF (l_is_complex_style) THEN
    x_is_complex_flag := 'Y';
  ELSE
    x_is_complex_flag := 'N';
  END IF;

  d_progress := 30;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_is_complex_flag', x_is_complex_flag);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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
--  This procedure reveals whether a style indicates to use financing pay items
--  or actuals pay items.
--Parameters:
--IN:
--  p_api_version
--    Should be 1.0
--  p_style_id
--    ID of the style to get the financing flag for
--OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS: API completed successfully.
--    FND_API.G_RET_STS_UNEXP_ERROR: API was not successful; unexpected error.
--  x_is_financing_flag
--    'Y': Any document with this style uses financing progress payments
--    'N': Any document with this style does not use financing progress
--         payments (other than advances).
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_financing_payment_style(
  p_api_version           IN NUMBER
, p_style_id              IN NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_is_financing_flag     OUT NOCOPY VARCHAR2
)
IS

 d_module     VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_GRP.is_financing_payment_style';
 d_progress   NUMBER;

 l_is_financing_style        BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_api_version', p_api_version);
    PO_LOG.proc_begin(d_module, 'p_style_id', p_style_id);
  END IF;

  d_progress := 10;

  l_is_financing_style :=
              PO_COMPLEX_WORK_PVT.is_financing_payment_style(p_style_id);

  IF (l_is_financing_style) THEN
    x_is_financing_flag := 'Y';
  ELSE
    x_is_financing_flag := 'N';
  END IF;

  d_progress := 30;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_is_financing_flag', x_is_financing_flag);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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
--  This procedure reveals whether a PO is a complex work PO.
--Parameters:
--IN:
--  p_api_version
--    Should be 1.0
--  p_po_header_id
--    Header ID of the PO to check whether or not it's a complex work PO
-- 18396405: SERVICES PROCUREMENT - OTHER PRODUCTS RELATED CHANGES
-- New parameters required by Receiving team.
-- Receiving has dual maintainence between 12.1 and 12.2
-- We will just add but not process additional parameters.
-- p_po_line_id
-- p_item_id
-- p_item_desc
-- p_po_line_location_id
--OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS: API completed successfully.
--    FND_API.G_RET_STS_UNEXP_ERROR: API was not successful; unexpected error.
--  x_is_complex_flag
--    'Y': This PO uses progress payments
--    'N': This PO cannot use progress payments
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_complex_work_po(
  p_api_version           IN NUMBER
, p_po_header_id          IN NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_is_complex_flag       OUT NOCOPY VARCHAR2
, p_po_line_id            IN NUMBER DEFAULT NULL
, p_item_id               IN NUMBER DEFAULT NULL
, p_item_desc             IN VARCHAR2 DEFAULT NULL
, p_po_line_location_id   IN NUMBER DEFAULT NULL
)
IS

 d_module     VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_GRP.is_complex_work_po';
 d_progress   NUMBER;

 l_is_complex_po        BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_api_version', p_api_version);
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
    PO_LOG.proc_begin(d_module, 'p_po_line_id', p_po_line_id);
    PO_LOG.proc_begin(d_module, 'p_item_id', p_item_id);
    PO_LOG.proc_begin(d_module, 'p_item_desc', p_item_desc);
    PO_LOG.proc_begin(d_module, 'p_po_line_location_id', p_po_line_location_id);
  END IF;

  d_progress := 10;

  l_is_complex_po := PO_COMPLEX_WORK_PVT.is_complex_work_po(p_po_header_id);

  IF (l_is_complex_po) THEN
    x_is_complex_flag := 'Y';
  ELSE
    x_is_complex_flag := 'N';
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_is_complex_flag', x_is_complex_flag);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
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
--  This procedure reveals whether a PO uses financing or actuals pay items.
--Parameters:
--IN:
--  p_api_version
--    Should be 1.0
--  p_po_header_id
--    Header ID of the PO to check whether or not PO uses financing pay items
--OUT:
--  x_return_status
--    FND_API.G_RET_STS_SUCCESS: API completed successfully.
--    FND_API.G_RET_STS_UNEXP_ERROR: API was not successful; unexpected error.
--  x_is_complex_flag
--    'Y': This PO uses financing pay items
--    'N': This PO does not use financing pay items, other than for advances
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE is_financing_po(
  p_api_version           IN NUMBER
, p_po_header_id          IN NUMBER
, x_return_status         OUT NOCOPY VARCHAR2
, x_is_financing_flag     OUT NOCOPY VARCHAR2
)
IS

 d_module     VARCHAR2(70) := 'po.plsql.PO_COMPLEX_WORK_GRP.is_financing_po';
 d_progress   NUMBER;

 l_is_financing_po        BOOLEAN;

BEGIN

  d_progress := 0;
  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_begin(d_module);
    PO_LOG.proc_begin(d_module, 'p_api_version', p_api_version);
    PO_LOG.proc_begin(d_module, 'p_po_header_id', p_po_header_id);
  END IF;

  d_progress := 10;

  l_is_financing_po := PO_COMPLEX_WORK_PVT.is_financing_po(p_po_header_id);

  IF (l_is_financing_po) THEN
    x_is_financing_flag := 'Y';
  ELSE
    x_is_financing_flag := 'N';
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;

  IF (PO_LOG.d_proc) THEN
    PO_LOG.proc_end(d_module, 'x_return_status', x_return_status);
    PO_LOG.proc_end(d_module, 'x_is_financing_flag', x_is_financing_flag);
    PO_LOG.proc_end(d_module);
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    IF (PO_LOG.d_exc) THEN
      PO_LOG.exc(d_module, d_progress, SQLCODE || SQLERRM);
      PO_LOG.proc_end(d_module);
    END IF;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END is_financing_po;


END PO_COMPLEX_WORK_GRP;

/
