--------------------------------------------------------
--  DDL for Package Body ICX_CAT_POPULATE_STATUS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ICX_CAT_POPULATE_STATUS_PVT" AS
/* $Header: ICXVPPSB.pls 120.6.12010000.4 2013/09/17 09:03:24 yyoliu ship $*/

FUNCTION getCategoryStatus
(       p_end_date_active               IN              DATE            ,
        p_disable_date                  IN              DATE            ,
        p_system_date                   IN              DATE
)
  RETURN NUMBER
IS
  l_ret_status  PLS_INTEGER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_ret_status := INVALID_FOR_POPULATE;

  l_err_loc := 200;

  IF (p_system_date < p_end_date_active AND
      p_system_date < p_disable_date)
  THEN
    l_err_loc := 300;
    l_ret_status := VALID_FOR_POPULATE;
  END IF;

  l_err_loc := 400;

  RETURN l_ret_status;
EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 500;
    RETURN l_ret_status;
END getCategoryStatus;

FUNCTION getBPALineStatus
(       p_BPA_line_status_rec           IN              g_BPA_line_status_rec_type
)
  RETURN NUMBER
IS
  l_ret_status               PLS_INTEGER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_ret_status := INVALID_FOR_POPULATE;

  l_err_loc := 200;


-- bug 17164050 begin
  IF ((p_BPA_line_status_rec.approved_date        IS NOT NULL                            OR
      (p_BPA_line_status_rec.approved_date        IS NULL                               AND
      p_BPA_line_status_rec.authorization_status='PRE-APPROVED'                         AND
      p_BPA_line_status_rec.acceptance_flag='S'))                                       AND
-- bug 17164050 end
      p_BPA_line_status_rec.authorization_status NOT IN ('REJECTED', 'INCOMPLETE')      AND
      p_BPA_line_status_rec.frozen_flag          = 'N'                                  AND
      p_BPA_line_status_rec.hdr_cancel_flag      = 'N'                                  AND
      p_BPA_line_status_rec.line_cancel_flag     = 'N'                                  AND
      p_BPA_line_status_rec.hdr_closed_code      NOT IN ('CLOSED', 'FINALLY CLOSED')    AND
      p_BPA_line_status_rec.line_closed_code     NOT IN ('CLOSED', 'FINALLY CLOSED')    AND
      p_BPA_line_status_rec.end_date             >= p_BPA_line_status_rec.system_date   AND
      p_BPA_line_status_rec.expiration_date      >= p_BPA_line_status_rec.system_date )
  THEN
    l_err_loc := 300;
    l_ret_status := VALID_FOR_POPULATE;
  END IF;

  l_err_loc := 400;

  RETURN l_ret_status;
EXCEPTION
  WHEN OTHERS THEN
    l_err_loc := 500;
    RETURN l_ret_status;
END getBPALineStatus;

FUNCTION getQuoteLineStatus
(       p_po_line_id                    IN              NUMBER
)
  RETURN NUMBER
IS
  l_ret_status               PLS_INTEGER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_ret_status := INVALID_FOR_POPULATE;

  l_err_loc := 200;

  /* Comments on the Quotation Line status
  1. status_lookup_code = 'A'
  -- Checks if the quotation status is 'Active'.
  -- Quotations can be created in the following status from the form:
  -- In Process  => I
  -- Closed      => C
  -- Active      => A
  2. ph.quotation_class_code = 'CATALOG'
  -- Check if the quotation type is 'Catalog Quotation' / 'Standard Quotation'.
  -- Following types of Quotations can be created from the form:
  -- Bid Quotation      => BID
  -- Catalog Quotation  => CATALOG
  -- Standard Quotation => CATALOG
  3. Just check for the end date in po_line_locations_all.  Start_date will be checked by the search code
  4. pqa.approval_type IN ('ALL ORDERS','REQUISITIONS') changed to pqa.approval_type IS NOT NULL to accomodate the SIC rules
  5. Just check for the end date in po_quotation_approvals_all.  Start_date will be checked by the search code
  6. Just check for the end date in po_headers_all.  Start_date will be checked by the search code
  */

  SELECT VALID_FOR_POPULATE
  INTO l_ret_status
  FROM po_headers_all ph,
       po_lines_all pl
  WHERE pl.po_line_id = p_po_line_id
  AND ph.po_header_id = pl.po_header_id
  AND ph.type_lookup_code = 'QUOTATION'
  AND ph.status_lookup_code = 'A'
  AND ph.quotation_class_code = 'CATALOG'
  AND (NVL(ph.approval_required_flag,'N') = 'N' OR
       (ph.approval_required_flag ='Y' AND
        EXISTS (SELECT 'current approved effective price break'
                FROM po_line_locations_all pll,
                     po_quotation_approvals_all pqa
                  WHERE pl.po_line_id = pll.po_line_id
                  AND SYSDATE <= NVL(pll.end_date, SYSDATE+1)
                  AND pqa.line_location_id = pll.line_location_id
                  AND pqa.approval_type IN ('ALL ORDERS','REQUISITIONS')
                  AND SYSDATE <= NVL(pqa.end_date_active, SYSDATE+1) )))
  AND TRUNC(SYSDATE) <= NVL(TRUNC(ph.end_date), TRUNC(SYSDATE + 1));

  l_err_loc := 300;

  RETURN l_ret_status;
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    l_err_loc := 400;
    RETURN l_ret_status;
END getQuoteLineStatus;

FUNCTION getGlobalAgreementStatus
(       p_enabled_flag                  IN              VARCHAR2
)
  RETURN NUMBER
IS
  l_ret_status PLS_INTEGER;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_ret_status := VALID_FOR_POPULATE;

  l_err_loc := 200;

  IF NVL(p_enabled_flag, 'N') = 'N' THEN
    l_err_loc := 300;
    l_ret_status := GLOBAL_BLANKET_DISABLED;
  END IF;

  l_err_loc := 400;

  -- Following validations for master item
  -- in purchasing org, enabled org and owning org on a GBPA
  -- will be done by PO
  -- 1. purchasing_enabled_flag
  -- 2. outside_operation_flag
  -- 3. UOM code/UOM Class

  RETURN l_ret_status;
END getGlobalAgreementStatus;

FUNCTION getTemplateLineStatus
(       p_inactive_date                 IN              DATE            ,
        p_contract_line_id	        IN              NUMBER          ,
        p_BPA_line_status_rec           IN              g_BPA_line_status_rec_type
)
  RETURN NUMBER
IS
  l_ret_status          PLS_INTEGER;
  l_BPA_line_status_rec g_BPA_line_status_rec_type;
  l_err_loc PLS_INTEGER;
BEGIN
  l_err_loc := 100;
  l_ret_status := VALID_FOR_POPULATE;

  l_err_loc := 200;

  IF NVL(p_inactive_date, SYSDATE+1) <= SYSDATE THEN
    l_err_loc := 300;
    l_ret_status := INACTIVE_TEMPLATE;
  ELSE
    l_err_loc := 400;
    IF (p_contract_line_id IS NOT NULL AND
        p_contract_line_id <> NULL_NUMBER)
    THEN
      l_err_loc := 500;
      l_ret_status := getBPALineStatus(p_BPA_line_status_rec);
      IF l_ret_status = VALID_FOR_POPULATE THEN
        l_err_loc := 600;
        l_ret_status := VALID_FOR_POPULATE;
      ELSE
        l_err_loc := 700;
        l_ret_status := TEMPLATE_INVALID_BLANKET_LINE;
      END IF;
    END IF;
  END IF;

  l_err_loc := 800;

  RETURN l_ret_status;
END getTemplateLineStatus;

PROCEDURE getMasterItemStatusAndType
(       p_internal_order_enabled_flag   IN              VARCHAR2        ,
        p_outside_operation_flag        IN              VARCHAR2        ,
        p_item_price                    IN              NUMBER          ,
        p_item_status                   OUT NOCOPY      NUMBER          ,
        p_item_type                     OUT NOCOPY      VARCHAR2
)
IS
  l_err_loc             PLS_INTEGER;
  l_is_purchasable      BOOLEAN;
  l_is_internal         BOOLEAN;
BEGIN
  l_err_loc := 100;
  p_item_status := VALID_FOR_POPULATE;

  -- item price is null if purchasing_enabled_flag is not 'Y'. We check this in the cursor,
  -- so we do not need to check for the purchasing_enabled_flag here.
  IF (p_item_price IS NOT NULL AND
      NVL(p_outside_operation_flag, 'N') <> 'Y')
  THEN
    l_err_loc := 200;
    l_is_purchasable := TRUE;
  ELSE
    l_err_loc := 300;
    l_is_purchasable := FALSE;
  END IF;

  IF (NVL(p_internal_order_enabled_flag, 'N') = 'Y') THEN
    l_is_internal := TRUE;
  ELSE
    l_is_internal := FALSE;
  END IF;

  l_err_loc := 500;
  IF (l_is_purchasable AND l_is_internal) THEN
    p_item_type := ICX_CAT_UTIL_PVT.g_both_item_type;
  ELSE
    IF (l_is_purchasable) THEN
      p_item_type := ICX_CAT_UTIL_PVT.g_purchase_item_type;
    ELSIF (l_is_internal) THEN
      p_item_type := ICX_CAT_UTIL_PVT.g_internal_item_type;
    ELSE
      p_item_type := null;
      p_item_status := INVALID_FOR_POPULATE;
    END IF;
  END IF;

END getMasterItemStatusAndType;


END ICX_CAT_POPULATE_STATUS_PVT;

/
