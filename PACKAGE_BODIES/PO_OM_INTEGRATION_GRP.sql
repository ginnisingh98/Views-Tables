--------------------------------------------------------
--  DDL for Package Body PO_OM_INTEGRATION_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_OM_INTEGRATION_GRP" AS
/* $Header: POXGOMIB.pls 120.5.12010000.3 2010/02/25 12:29:57 srpothul ship $*/

--CONSTANTS

G_PKG_NAME CONSTANT varchar2(30) := 'PO_OM_INTEGRATION_GRP';

c_log_head    CONSTANT VARCHAR2(50) := 'po.plsql.'|| G_PKG_NAME || '.';

-- Read the profile option that enables/disables the debug log
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

g_debug_stmt  CONSTANT BOOLEAN := PO_DEBUG.is_debug_stmt_on;
g_debug_unexp CONSTANT BOOLEAN := PO_DEBUG.is_debug_unexp_on;

-- START Forward declarations for package private procedures:
PROCEDURE call_po_change_api (
  p_chg           IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
);
-- END Forward declarations for package private procedures

-------------------------------------------------------------------------------
--Start of Comments
--Name: update_req_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Validate and Update Requisition and Purchase Order/Release. This procedure
--  is called by OM to synchroize key attribute values on Sales Order with the
--  corresponding Drop Ship Purchasing Documents.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_req_header_id
--  Specifies Requisition Header ID.
--  The Req HeaderId/LineId identify the drop ship requisition line of
--  the backing sales order line
--p_req_line_id
--  Specifies Requisition Line ID.
--  The Req HeaderId/LineId identify the drop ship requisition line of
--  the backing sales order line
--p_po_header_id := NULL
--  Specifies Purchase Order Header ID.
--  The PO HeaderId/LineId/LineLocationId identify the drop ship PO Shipment of
--  the backing sales order line
--p_po_release_id := NULL
--  Specifies Purchase Order Release ID.
--  The PO ReleaseId/LineId/LineLocationId identify the drop ship
--  Release Shipment of the backing sales order line
--p_po_line_id := NULL
--  Specifies Purchase Order Line ID.
--  The PO LineId/LineLocationId together with a PO HeaderId or ReleaseId
--  identify the drop ship PO/Release Shipment of the backing sales order line
--p_po_line_location_id := NULL
--  Specifies Purchase Order Shipment ID.
--  The PO LineId/LineLocationId together with a PO HeaderId or ReleaseId
--  identify the drop ship PO/Release Shipment of the backing sales order line
--p_quantity := NULL
--  The new quantity value to update on Requisition Line and PO/Release Shipment
--  When quantity changes on SO Line, both p_quantity and p_secondary_quantity
--  should be passed in with latest values on SO line.
--p_secondary_quantity := NULL
--  The new secondary quantity value to update on Requisition Line
--  and PO/Release Shipment. This should be passed only when quantity changes
--  on SO. This should NOT be passed if sec qty changes but no change to qty
--p_need_by_date := NULL
--  The new need by date value to update on Requisition Line and
--  PO/Release Shipment. This field is called Schedule Date on SO Line.
--p_ship_to_location_id := NULL
--  The new Ship To Location to update on Requisition Line and PO/Release Shipment
--p_sales_order_update_date := NULL
--  The new sales order update date to update on PO/Release Shipment.
--  When any of the referenced data elements on SO change, this pararameter is
--  sent in with value of SYSDATE.
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  Number of Error messages
--x_msg_data
--  Error messages body
--Notes:
--  Requisition and/or PO can be in a different Operating Unit from the current one
--Testing:
--  Call the API when only Requisition Exist, PO/Release Exist
--    and for all the combinations of attributes.
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE update_req_po
(
    p_api_version           IN NUMBER,
    p_req_header_id         IN PO_TBL_NUMBER,
    p_req_line_id           IN PO_TBL_NUMBER,
    p_po_header_id          IN PO_TBL_NUMBER := NULL,
    p_po_release_id         IN PO_TBL_NUMBER := NULL,
    p_po_line_id            IN PO_TBL_NUMBER := NULL,
    p_po_line_location_id   IN PO_TBL_NUMBER := NULL,
    p_quantity              IN PO_TBL_NUMBER := NULL,
    p_secondary_quantity    IN PO_TBL_NUMBER := NULL,
    p_need_by_date          IN PO_TBL_DATE := NULL,
    p_ship_to_location_id   IN PO_TBL_NUMBER := NULL,
    p_sales_order_update_date IN PO_TBL_DATE := NULL,
    p_preferred_grade	    IN PO_TBL_VARCHAR240 := NULL, --<INVCONV R12>
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
l_api_name    CONSTANT VARCHAR(30) := 'UPDATE_REQ_PO';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';
l_log_head CONSTANT VARCHAR2(100) := c_log_head || '.' || l_api_name;

-- Bug 3292895 START
TYPE indexed_tbl_number IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

l_processed_pos         INDEXED_TBL_NUMBER;
l_processed_releases    INDEXED_TBL_NUMBER;
l_processed_reqs        INDEXED_TBL_NUMBER;

l_cur_po_header_id      PO_HEADERS_ALL.po_header_id%TYPE;
l_cur_po_release_id     PO_RELEASES_ALL.po_release_id%TYPE;
l_cur_req_header_id     PO_REQUISITION_HEADERS_ALL.requisition_header_id%TYPE;
l_start_index           NUMBER;

l_po_changes            PO_CHANGES_REC_TYPE;
l_errors                PO_API_ERRORS_REC_TYPE;
l_req_changes           PO_REQ_CHANGES_REC_TYPE;
-- Bug 3292895 END

l_quantity_ordered      PO_TBL_NUMBER := p_quantity;

l_original_org_id     NUMBER  := PO_MOAC_UTILS_PVT.get_current_org_id ;  -- <R12 MOAC> added
l_document_org_id       PO_HEADERS.ORG_ID%TYPE;
l_count                 NUMBER;

-- Bug# 8970502 : Added the following variables

 l_request_unit_of_measure PO_REQUISITION_LINES_ALL.UNIT_MEAS_LOOKUP_CODE%TYPE;
 l_request_secondary_uom PO_REQUISITION_LINES_ALL.SECONDARY_UNIT_OF_MEASURE%TYPE;

--Bug# 4640038 Start, Added the following variable

l_po_request_unit_of_measure PO_LINES_ALL.UNIT_MEAS_LOOKUP_CODE%TYPE;
l_po_request_secondary_uom   PO_LINES_ALL.SECONDARY_UOM%TYPE;
l_so_request_unit_of_measure mtl_units_of_measure.UNIT_OF_MEASURE_TL%TYPE;
l_so_request_secondary_uom   mtl_units_of_measure.UNIT_OF_MEASURE_TL%TYPE;
l_uom_conversion_rate NUMBER := 1;
l_suom_conversion_rate NUMBER := 1;
l_secondary_quantity_ordered  PO_TBL_NUMBER := p_secondary_quantity;
l_item_id po_lines.item_id%TYPE;

--Bug# 4640038 End

-- Bug 3639067
l_drop_ship_flag        PO_LINE_LOCATIONS_ALL.drop_ship_flag%TYPE;

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

-- Standard call to check for call compatibility
l_progress := '010';
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

SAVEPOINT PO_OM_GRP_UPDATE_REQ_PO_SP;

-- Bug 3292895 START
-- Rewrote the grouping logic for PO shipments / requistion lines so that
-- it does not use nested tables, which are not supported in Oracle 8i.

-- Group the changes to various PO Shipments by po_header_id/po_release_id
-- and call the PO Change API for each PO/release.
l_progress := '020';

LOOP
  l_cur_po_header_id := NULL;
  l_cur_po_release_id := NULL;

  -- Find the next PO or release to process.
  l_progress := '030';
  FOR i IN 1..p_po_header_id.count LOOP

    IF (p_po_release_id(i) IS NOT NULL)
       AND (NOT l_processed_releases.EXISTS(p_po_release_id(i))) THEN
      -- We found a release that has not been processed yet.
      l_cur_po_release_id := p_po_release_id(i);
      l_processed_releases(l_cur_po_release_id) := 1; -- Mark it as processed.
      -- Bug 3691067. For a release, mark its BPA also as processed because
      --    changes to the Sales Order should only be reflected in the Release
      --    not its corresponding Blanket
      l_processed_pos(p_po_header_id(i)) := 1;
      l_start_index := i;
      EXIT;
    END IF;

    IF (p_po_header_id(i) IS NOT NULL)
       AND (NOT l_processed_pos.EXISTS(p_po_header_id(i))) THEN
      -- We found a PO that has not been processed yet.
      l_cur_po_header_id := p_po_header_id(i);
      l_processed_pos(l_cur_po_header_id) := 1; -- Mark it as processed.
      l_start_index := i;
      EXIT;
    END IF;

  END LOOP; -- 1..p_po_header_id.count

  -- Exit the loop once all POs/releases have been processed.
  EXIT WHEN ((l_cur_po_header_id IS NULL) AND (l_cur_po_release_id IS NULL));

  -- Create a change object for the PO/release.
  l_progress := '040';
  l_po_changes := PO_CHANGES_REC_TYPE.create_object (
                    p_po_header_id => l_cur_po_header_id,
                    p_po_release_id => l_cur_po_release_id );

  -- Add the shipment changes for this PO/release to the change object.
  l_progress := '050';
  FOR i IN l_start_index..p_po_header_id.count LOOP
    IF ((l_cur_po_header_id IS NOT NULL)
        AND (l_cur_po_header_id = p_po_header_id(i))) OR
       ((l_cur_po_release_id IS NOT NULL)
        AND (l_cur_po_release_id = p_po_release_id(i))) THEN

      -- Bug 3639067 START
      -- Only synchronize if the shipment is flagged as drop ship.
      -- (Pre-11.5.10 drop shipments may still have drop_ship_flag of NULL
      -- if the upgrade script poxupgds.sql found discrepancies between the
      -- sales order, requisition, and PO. In this case, we should not
      -- automatically synchronize SO changes to the req/PO.)
      SELECT drop_ship_flag
      INTO l_drop_ship_flag
      FROM po_line_locations_all
      WHERE line_location_id = p_po_line_location_id(i);

      IF (l_drop_ship_flag = 'Y') THEN

        --Bug 3256289: Pass ReqLine's UOM, SecondaryUOM to Change PO API as request UOMs
        -- Bug# 4640038, Now getting the uom from
        -- Drop ship sales order line and convering the quantity
        -- to the PO UOM.

      Begin

       l_progress := '052';

        -- Bug# 4640038, Get the uom and secondary uom of sales order line
        --bug5606683 changed the following sql select clause to get the UOM instead of
        -- their translated value.
       SELECT puom.unit_of_measure,
              suom.unit_of_measure
         INTO l_so_request_unit_of_measure,
              l_so_request_secondary_uom
         FROM oe_order_lines_all ol,
              oe_drop_ship_sources ds,
              mtl_units_of_measure puom,
              mtl_units_of_measure suom
        WHERE ol.line_id=ds.line_id
          AND ds.line_location_id= p_po_line_location_id(i)
        and ol.order_quantity_uom= puom.uom_code
        and ol.ordered_quantity_uom2=suom.uom_code(+);

      Exception

        When OTHERS then

          IF (g_debug_stmt) THEN
              PO_DEBUG.debug_stmt (
              p_log_head => l_log_head,
              p_token    => l_progress,
              p_message  => 'Exception while retrieving drop ship row :' || p_po_line_location_id(i) );
          END IF;

      End;


      IF (g_debug_stmt) THEN
          PO_DEBUG.debug_stmt (
          p_log_head => l_log_head,
          p_token    => l_progress,
          p_message  => 'Sales Order uom :' ||l_so_request_unit_of_measure||', Secondary UOM :'||l_so_request_secondary_uom);
      END IF;

       l_progress := '054';

        -- Bug# 4640038, Get the uom and secondary uom of PO line

       Select item_id ,
              unit_meas_lookup_code ,
              secondary_uom
        INTO l_item_id,
             l_po_request_unit_of_measure,
             l_po_request_secondary_uom
        from po_lines_all
       WHERE po_line_id = p_po_line_id(i);

      IF (g_debug_stmt) THEN
          PO_DEBUG.debug_stmt (
          p_log_head => l_log_head,
          p_token    => l_progress,
          p_message  => 'PO uom :' ||l_po_request_unit_of_measure||', Secondary UOM :'||l_po_request_secondary_uom);

      END IF;

      -- Bug# 4640038, Get the conversion rate of uom from SO to PO
      l_progress := '056';
      IF l_po_request_unit_of_measure IS NOT NULL AND
         l_so_request_unit_of_measure IS NOT NULL THEN
         IF  l_po_request_unit_of_measure <> l_so_request_unit_of_measure then
            l_uom_conversion_rate := nvl(po_uom_s.po_uom_convert(
                               l_so_request_unit_of_measure,
                               l_po_request_unit_of_measure,
                               l_item_id),1);
            IF (g_debug_stmt) THEN
               PO_DEBUG.debug_stmt (
                p_log_head => l_log_head,
                p_token    => l_progress,
                p_message  => 'PO UOM conversion rate :' ||to_char(l_uom_conversion_rate));
            END IF;
         END IF;
      END IF;

      -- Bug# 4640038, Get the conversion rate of secondary uom from SO to PO
      l_progress := '058';
      IF l_po_request_secondary_uom is not NULL AND
         l_so_request_secondary_uom is not NULL THEN
         IF l_po_request_secondary_uom <> l_so_request_secondary_uom THEN
            l_suom_conversion_rate := nvl(po_uom_s.po_uom_convert(
                               l_so_request_secondary_uom,
                               l_po_request_secondary_uom,
                               l_item_id),1);
            IF (g_debug_stmt) THEN
               PO_DEBUG.debug_stmt (
                p_log_head => l_log_head,
                p_token    => l_progress,
                p_message  => 'PO Secondary UOM conversion rate :' ||to_char(l_suom_conversion_rate));
            END IF;
         END IF;
      END IF;

        /*

        Bug# 4640038, Commented out this code
        The Requisition could be in a different uom that the sales order
        When changing the quantity iof the SO we need to pass the quantity
        converted to the PO UOM as the PO ans SO can be in different UOM.
        We will convert the SO quantity to the PO Quantity and pass it
        to the change order api.


        SELECT unit_meas_lookup_code, secondary_unit_of_measure
        INTO l_request_unit_of_measure, l_request_secondary_uom
        FROM po_requisition_lines_all
        WHERE requisition_line_id = p_req_line_id(i);

       */

	--Bug 3239540: OM passes p_quantity as the new open, undelivered
        --quantity. We need to add the quantity delivered:
        --  new quantity ordered = new undelivered quantity + quantity delivered
        -- Bug# 4640038 Added the conversion rate calculation below

        IF (p_quantity(i) IS NULL) THEN
          l_quantity_ordered(i) := NULL;

        ELSE

	  SELECT round((p_quantity(i) * l_uom_conversion_rate),5) + nvl(sum(nvl(quantity_delivered, 0)), 0)
          INTO l_quantity_ordered(i)
          FROM po_distributions_all
          WHERE line_location_id = p_po_line_location_id(i);

        END IF;

        -- Bug# 4640038 Added the conversion rate calculation below

        IF (p_secondary_quantity(i) IS NULL) THEN
          l_secondary_quantity_ordered(i) := NULL;
        ELSE

         SELECT round((p_secondary_quantity(i) * l_suom_conversion_rate),5) + NVL(SUM(NVL(secondary_quantity_received,0)),0)
                 INTO l_secondary_quantity_ordered(i)
          FROM   po_line_locations_all
          WHERE  line_location_id = p_po_line_location_id(i);
        END IF;


        -- Add this shipment change to the PO change object.
        l_po_changes.shipment_changes.add_change (
            p_po_line_location_id     => p_po_line_location_id(i),
            p_quantity                => l_quantity_ordered(i),
            p_request_unit_of_measure => l_po_request_unit_of_measure,
            p_secondary_quantity      => p_secondary_quantity(i),
            p_request_secondary_uom   => l_po_request_secondary_uom,
            p_need_by_date            => p_need_by_date(i),
            p_ship_to_location_id     => p_ship_to_location_id(i),
            p_preferred_grade	      => p_preferred_grade(i),   --<INVCONV R12>
            p_sales_order_update_date => p_sales_order_update_date(i) );

      -- Bug 3639067 START
      ELSE -- l_drop_ship_flag is not Y
        IF (g_debug_stmt) THEN
          PO_DEBUG.debug_stmt (
            p_log_head => l_log_head,
            p_token    => l_progress,
            p_message  => 'Skip this PO shipment - drop_ship_flag is not Y: '
                          || p_po_line_location_id(i) );
        END IF;
      END IF; -- l_drop_ship_flag
      -- Bug 3639067 END

    END IF;
  END LOOP; -- l_start_index..p_po_header_id.count

  -- Update the PO/Release by calling the PO Change API.
  -- Bug 3248723 START
  l_progress := '060';
  IF (l_po_changes.shipment_changes.get_count > 0) THEN -- Bug 3639067
    call_po_change_api ( p_chg => l_po_changes,
                         x_return_status => x_return_status );
  END IF; -- Bug 3639067
  -- Bug 3248723 END

  IF (x_return_status = FND_API.G_RET_STS_ERROR) THEN
      RAISE FND_API.g_exc_error;
  ELSIF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE FND_API.g_exc_unexpected_error;
  END IF;

END LOOP;

-- Group the changes to various requisition lines by requisition_header_id
-- and call the Req Change API for each requisition.
l_progress := '200';

LOOP
  l_cur_req_header_id := NULL;

  -- Find the next requisition to process.
  l_progress := '210';
  FOR i IN 1..p_req_header_id.count LOOP

    IF (p_req_header_id(i) IS NOT NULL)
       AND (NOT l_processed_reqs.EXISTS(p_req_header_id(i))) THEN
      -- We found a requisition that has not been processed yet.
      l_cur_req_header_id := p_req_header_id(i);
      l_processed_reqs(l_cur_req_header_id) := 1; -- Mark it as processed.
      l_start_index := i;
      EXIT;
    END IF;

  END LOOP; -- 1..p_req_header_id.count

  -- Exit the loop once all requisitions have been processed.
  EXIT WHEN (l_cur_req_header_id IS NULL);

  -- Create a change object for the requisition.
  l_progress := '220';
  -- Bug 3331194 Set unit_price, etc. to PO_TBL_NUMBER() instead of NULL.
  l_req_changes := PO_REQ_CHANGES_REC_TYPE (
                     req_header_id => l_cur_req_header_id,
                     line_changes =>
                       PO_REQ_LINES_REC_TYPE (
                         req_line_id => PO_TBL_NUMBER(),
                         unit_price => PO_TBL_NUMBER(),
                         currency_unit_price => PO_TBL_NUMBER(),
                         quantity => PO_TBL_NUMBER(),
                         secondary_quantity => PO_TBL_NUMBER(),
                         -- preferred_grade    => PO_TBL_VARCHAR240(), --<INVCONV R12>
                         need_by_date => PO_TBL_DATE(),
                         deliver_to_location_id => PO_TBL_NUMBER(),
                         assignment_start_date => PO_TBL_DATE(),
                         assignment_end_date => PO_TBL_DATE(),
                         amount => PO_TBL_NUMBER() ),
                     distribution_changes => null );

  -- Add the line changes for this requisition to the change object.
  l_progress := '230';
  FOR i IN l_start_index..p_req_header_id.count LOOP
    IF (l_cur_req_header_id = p_req_header_id(i)) THEN

      -- Bug 3639067 START
      -- Only synchronize if the line is flagged as drop ship.
      SELECT drop_ship_flag
      INTO l_drop_ship_flag
      FROM po_requisition_lines_all
      WHERE requisition_line_id = p_req_line_id(i);

      IF (l_drop_ship_flag = 'Y') THEN
      -- Bug 3639067 END

                  -- Bug8970502 Start

-- Bug#8970502, Now getting the uom from
-- Drop ship sales order line and convering the quantity
-- to the Req UOM.
Begin
l_progress := '052';

-- Bug#8970502, Get the uom and secondary uom of sales order line
SELECT puom.unit_of_measure,
suom.unit_of_measure
INTO l_so_request_unit_of_measure,
l_so_request_secondary_uom
FROM oe_order_lines_all ol,
oe_drop_ship_sources ds,
mtl_units_of_measure puom,
mtl_units_of_measure suom
WHERE ol.line_id=ds.line_id
AND ds.requisition_line_id= p_req_line_id(i)
and ol.order_quantity_uom= puom.uom_code
and ol.ordered_quantity_uom2=suom.uom_code(+);
Exception
When OTHERS then
IF (g_debug_stmt) THEN
PO_DEBUG.debug_stmt (
p_log_head => l_log_head,
p_token => l_progress,
p_message => 'Exception while retrieving drop ship row :' || p_req_line_id(i)
);
END IF;
End;

IF (g_debug_stmt) THEN
PO_DEBUG.debug_stmt (
p_log_head => l_log_head,
p_token => l_progress,
p_message => 'Sales Order uom :' ||l_so_request_unit_of_measure||', Secondary UOM
:'||l_so_request_secondary_uom);
END IF;

l_progress := '054';
-- Bug#8970502, Get the uom and secondary uom of Req.
Select item_id ,
unit_meas_lookup_code ,
secondary_unit_of_measure
INTO l_item_id,
l_request_unit_of_measure,
l_request_secondary_uom
from po_requisition_lines_all
WHERE requisition_line_id = p_req_line_id(i);

IF (g_debug_stmt) THEN
PO_DEBUG.debug_stmt (
p_log_head => l_log_head,
p_token => l_progress,
p_message => 'Req uom :' ||l_request_unit_of_measure||', Secondary UOM :'||
l_request_secondary_uom);
END IF;


-- Bug#8970502 , Get the conversion rate of uom from SO to Req
l_progress := '056';
IF l_request_unit_of_measure IS NOT NULL AND
l_request_unit_of_measure IS NOT NULL THEN
IF l_request_unit_of_measure <> l_so_request_unit_of_measure then
l_uom_conversion_rate := nvl(po_uom_s.po_uom_convert(
l_so_request_unit_of_measure,
l_request_unit_of_measure,
l_item_id),1);
IF (g_debug_stmt) THEN
PO_DEBUG.debug_stmt (
p_log_head => l_log_head,
p_token => l_progress,
p_message => ' Primary UOM conversion rate From Sales Order to req :' ||to_char(
l_uom_conversion_rate));
END IF;
END IF;
END IF;

-- Bug#8970502, Get the conversion rate of secondary uom from SO to Req
l_progress := '058';
IF l_request_secondary_uom is not NULL AND
l_so_request_secondary_uom is not NULL THEN
IF l_request_secondary_uom <> l_so_request_secondary_uom THEN
l_suom_conversion_rate := nvl(po_uom_s.po_uom_convert(
l_so_request_secondary_uom,
l_request_secondary_uom,
l_item_id),1);
IF (g_debug_stmt) THEN
PO_DEBUG.debug_stmt (
p_log_head => l_log_head,
p_token => l_progress,
p_message => 'Secondary UOM conversion rate From Sales Order to req :' ||
to_char(
l_suom_conversion_rate));
END IF;
END IF;
END IF;

-- Bug#8970502 Added the conversion rate calculation below
IF (p_quantity(i) IS NULL) THEN
l_quantity_ordered(i) := NULL;
ELSE
SELECT round((p_quantity(i) * l_uom_conversion_rate),5) + nvl(sum(nvl(
quantity_delivered, 0)), 0)
INTO l_quantity_ordered(i)
FROM po_requisition_lines_all
WHERE requisition_line_id = p_req_line_id(i);
END IF;

-- Bug#8970502 Added the conversion rate calculation below
IF (p_secondary_quantity(i) IS NULL) THEN
l_secondary_quantity_ordered(i) := NULL;
ELSE
SELECT round((p_secondary_quantity(i) * l_suom_conversion_rate),5) + NVL(SUM(NVL(
secondary_quantity_received,0)),0)
INTO l_secondary_quantity_ordered(i)
FROM po_requisition_lines_all
WHERE requisition_line_id = p_req_line_id(i);
END IF;

-- Bug8970502 End



        l_req_changes.line_changes.req_line_id.extend(1);
        l_count := l_req_changes.line_changes.req_line_id.count;
        l_req_changes.line_changes.req_line_id(l_count) := p_req_line_id(i);

        l_req_changes.line_changes.unit_price.extend(1);
        l_req_changes.line_changes.currency_unit_price.extend(1);

        l_req_changes.line_changes.quantity.extend(1);
        l_req_changes.line_changes.quantity(l_count) := l_quantity_ordered(i);

        l_req_changes.line_changes.secondary_quantity.extend(1);
        l_req_changes.line_changes.secondary_quantity(l_count)
          := p_secondary_quantity(i);

        l_req_changes.line_changes.need_by_date.extend(1);
        l_req_changes.line_changes.need_by_date(l_count)
          := p_need_by_date(i);

        l_req_changes.line_changes.deliver_to_location_id.extend(1);
        l_req_changes.line_changes.deliver_to_location_id(l_count)
          := p_ship_to_location_id(i);

        l_req_changes.line_changes.assignment_start_date.extend(1);
        l_req_changes.line_changes.assignment_end_date.extend(1);
        l_req_changes.line_changes.amount.extend(1);

      -- Bug 3639067 START
      ELSE -- l_drop_ship_flag is not Y
        IF (g_debug_stmt) THEN
          PO_DEBUG.debug_stmt (
            p_log_head => l_log_head,
            p_token    => l_progress,
            p_message  => 'Skip this req line - drop_ship_flag is not Y: '
                          || p_req_line_id(i) );
        END IF;
      END IF; -- l_drop_ship_flag
      -- Bug 3639067 END

    END IF;
  END LOOP; -- l_start_index..p_req_header_id.count

  -- Update the Requisition by calling the Update Requisition API.
  l_progress := '240';

  IF (l_req_changes.line_changes.req_line_id.count > 0) THEN -- Bug 3639067

    -- Retrieve the document's operating unit.
    SELECT org_id
    INTO l_document_org_id
    FROM po_requisition_headers_all
    WHERE requisition_header_id = l_cur_req_header_id;

    -- Set Org Context to that of Document
    PO_MOAC_UTILS_PVT.set_org_context(l_document_org_id) ;         -- <R12 MOAC>

    l_progress := '250';
    PO_REQ_DOCUMENT_UPDATE_GRP.update_requisition (
      p_api_version => 1.0,
      p_req_changes => l_req_changes,
      p_update_source => 'OM',
      x_return_status => x_return_status,
      x_msg_count  => x_msg_count,
      x_msg_data  => x_msg_data );

    IF (x_return_status = FND_API.g_ret_sts_error) THEN
        RAISE FND_API.g_exc_error;
    ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
        RAISE FND_API.g_exc_unexpected_error;
    END IF;

  END IF; -- l_req_changes... - Bug 3639067

END LOOP;
-- Bug 3292895 END

l_progress := '900';
-- Set the org context back to the original operating unit.
PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;       -- <R12 MOAC>

x_return_status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO PO_OM_GRP_UPDATE_REQ_PO_SP;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Set the org context back to the original operating unit.
        PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;     -- <R12 MOAC>
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO PO_OM_GRP_UPDATE_REQ_PO_SP;
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Set the org context back to the original operating unit.
        PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;   -- <R12 MOAC>
    WHEN OTHERS THEN
        ROLLBACK TO PO_OM_GRP_UPDATE_REQ_PO_SP;
        PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                      p_proc_name => l_api_name,
                                      p_progress => l_progress );
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Set the org context back to the original operating unit.
        PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;   -- <R12 MOAC>

END update_req_po;

-------------------------------------------------------------------------------
--Start of Comments
--Name: cancel_req_po
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Validate and Cancel Requisition and Purchase Order/Release. This procedure
--  is called by OM when a Drop Ship SO Line is cancelled or deleted.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_req_header_id
--  Specifies Requisition Header ID.
--  The Req HeaderId/LineId identify the drop ship requisition line of
--  the backing sales order line
--p_req_line_id
--  Specifies Requisition Line ID.
--  The Req HeaderId/LineId identify the drop ship requisition line of
--  the backing sales order line
--p_po_header_id := NULL
--  Specifies Purchase Order Header ID.
--  The PO HeaderId/LineId/LineLocationId identify the drop ship PO Shipment of
--  the backing sales order line
--p_po_release_id := NULL
--  Specifies Purchase Order Header ID.
--  The PO ReleaseId/LineId/LineLocationId identify the drop ship
--  Release Shipment of the backing sales order line
--p_po_line_id := NULL
--  Specifies Purchase Order Line ID.
--  The PO LineId/LineLocationId together with a PO HeaderId or ReleaseId
--  identify the drop ship PO/Release Shipment of the backing sales order line
--p_po_line_location_id := NULL
--  Specifies Purchase Order Shipment ID.
--  The PO LineId/LineLocationId together with a PO HeaderId or ReleaseId
--  identify the drop ship PO/Release Shipment of the backing sales order line
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  Number of Error messages
--x_msg_data
--  Error messages body
--Notes:
--  Requisition and/or PO can be in a different Operating Unit from the current one
--Testing:
--  Call the API when only Requisition Exist, and when PO/Release also Exist
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE cancel_req_po
(
    p_api_version           IN NUMBER,
    p_req_header_id         IN PO_TBL_NUMBER,
    p_req_line_id           IN PO_TBL_NUMBER,
    p_po_header_id          IN PO_TBL_NUMBER := NULL,
    p_po_release_id         IN PO_TBL_NUMBER := NULL,
    p_po_line_id            IN PO_TBL_NUMBER := NULL,
    p_po_line_location_id   IN PO_TBL_NUMBER := NULL,
    x_return_status         OUT NOCOPY  VARCHAR2,
    x_msg_count             OUT NOCOPY  NUMBER,
    x_msg_data              OUT NOCOPY  VARCHAR2
)
IS
l_api_name    CONSTANT VARCHAR(30) := 'CANCEL_REQ_PO';
l_api_version CONSTANT NUMBER := 1.0;
l_progress    VARCHAR2(3) := '000';
l_log_head CONSTANT VARCHAR2(100) := c_log_head || '.' || l_api_name;

l_doc_type PO_DOCUMENT_TYPES.DOCUMENT_TYPE_CODE%TYPE;
l_doc_subtype PO_DOCUMENT_TYPES.DOCUMENT_SUBTYPE%TYPE;

-- Bug 3248723 START
l_original_org_id     NUMBER  := PO_MOAC_UTILS_PVT.get_current_org_id ;     -- <R12 MOAC>
l_approved_date         PO_LINE_LOCATIONS_ALL.approved_date%TYPE;
l_chg                   PO_CHANGES_REC_TYPE;
-- Bug 3248723 END
l_document_org_id       PO_HEADERS.ORG_ID%TYPE; -- Bug 3362534

-- Bug 3639067 START
l_drop_ship_flag        PO_LINE_LOCATIONS_ALL.drop_ship_flag%TYPE;
l_session_gt_key        PO_SESSION_GT.key%TYPE;
l_req_header_id         PO_TBL_NUMBER;
l_req_line_id           PO_TBL_NUMBER;
-- Bug 3639067 END

BEGIN

IF g_fnd_debug = 'Y' THEN
    IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
      FND_LOG.string(FND_LOG.LEVEL_STATEMENT, c_log_head || '.'||l_api_name||'.'
          || l_progress, 'Entering Procedure '||l_api_name);
    END IF;
END IF;

-- Standard call to check for call compatibility
l_progress := '010';
IF NOT FND_API.Compatible_API_Call(l_api_version, p_api_version, l_api_name, G_PKG_NAME) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END IF;

-- Cancel PO/Release Shipments
l_progress := '020';
FOR i IN 1..p_po_header_id.count LOOP

  IF p_po_header_id(i) IS NOT NULL OR p_po_release_id(i) IS NOT NULL THEN
  --If PO is NOT null, that means PO is created, not just req

    IF p_po_release_id(i) IS NOT NULL THEN
        SELECT RELEASE_TYPE,
               org_id -- Bug 3362534
        INTO l_doc_subtype,
             l_document_org_id
        from  PO_RELEASES_ALL
        WHERE po_release_id = p_po_release_id(i);
        l_doc_type := 'RELEASE';
    ELSE
        SELECT TYPE_LOOKUP_CODE,
               org_id -- Bug 3362534
        INTO l_doc_subtype,
             l_document_org_id
        from  PO_HEADERS_ALL
        WHERE po_header_id = p_po_header_id(i);
        l_doc_type := 'PO';
    END IF;

    -- Bug 3248723 START
    -- If the shipment has not been approved before, call the PO Change API
    -- to delete it. Otherwise, call the PO Control API to cancel it.

    l_progress := '025';
    SELECT approved_date,
           drop_ship_flag -- Bug 3639067
    INTO l_approved_date,
         l_drop_ship_flag
    FROM po_line_locations_all
    WHERE line_location_id = p_po_line_location_id(i);

    -- Bug 3639067 START
    -- Only synchronize if the shipment is flagged as drop ship.
    IF (l_drop_ship_flag = 'Y') THEN
    -- Bug 3639067 END

      IF (l_approved_date IS NULL) THEN -- Delete the shipment.
        l_progress := '030';
        -- Create a change object with a request to delete the shipment.
        l_chg := PO_CHANGES_REC_TYPE.create_object (
                   p_po_header_id => p_po_header_id(i),
                   p_po_release_id => p_po_release_id(i) );
        l_chg.shipment_changes.add_change (
          p_po_line_location_id => p_po_line_location_id(i),
          p_delete_record => PO_DOCUMENT_UPDATE_GRP.G_PARAMETER_YES );

        -- Call the PO Change API to delete the shipment.
        call_po_change_api ( p_chg => l_chg,
                             x_return_status => x_return_status );
      ELSE -- Cancel the shipment.
      -- Bug 3248723 END
        l_progress := '035';

        -- Bug 3362534 Set the org context to the operating unit of the document.
        PO_MOAC_UTILS_PVT.set_org_context(l_document_org_id) ;          -- <R12 MOAC>

        PO_Document_Control_GRP.control_document
               (p_api_version      => 1.0,
                p_init_msg_list    => FND_API.G_FALSE,
                p_commit           => FND_API.G_FALSE,
                x_return_status    => x_return_status,
                p_doc_type         => l_doc_type,
                p_doc_subtype      => l_doc_subtype,
                p_doc_id           => p_po_header_id(i),
                p_doc_num          => null,
                p_release_id       => p_po_release_id(i),
                p_release_num      => null,
                p_doc_line_id      => p_po_line_id(i),
                p_doc_line_num     => null,
                p_doc_line_loc_id  => p_po_line_location_id(i),
                p_doc_shipment_num => null,
                p_source           => 'OM',
                p_action           => 'CANCEL',
                p_action_date      => SYSDATE,
                p_cancel_reason    => 'Order Management',
                p_cancel_reqs_flag => 'Y', --Bug 7666230
                p_print_flag       => 'N',
                p_note_to_vendor   => null);
      END IF; -- l_approved_date

      IF (x_return_status = FND_API.g_ret_sts_error) THEN
          RAISE FND_API.g_exc_error;
      ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
          RAISE FND_API.g_exc_unexpected_error;
      END IF;

    -- Bug 3639067 START
    ELSE -- l_drop_ship_flag is not Y
      IF (g_debug_stmt) THEN
        PO_DEBUG.debug_stmt (
          p_log_head => l_log_head,
          p_token    => l_progress,
          p_message  => 'Skip this PO shipment - drop_ship_flag is not Y: '
                        || p_po_line_location_id(i) );
      END IF;
    END IF; -- l_drop_ship_flag
    -- Bug 3639067 END

  END IF; --End of IF p_po_header_id(i) IS NOT NULL ...

END LOOP;

-- Cancel Req Lines
l_progress := '040';

-- Bug 3639067 START
-- Only synchronize the lines that are flagged as drop ship.
-- To do this, we filter p_req_line_id, p_req_header_id to construct
-- new tables l_req_line_id, l_req_header_id that contain only the req lines
-- with drop_ship_flag = 'Y'.

-- SQL What: Retrieve a key to identify our records in PO_SESSION_GT.
SELECT PO_SESSION_GT_S.nextval
INTO l_session_gt_key
FROM dual;

----------------------------------------------------------------
-- PO_SESSION_GT column mapping
--
-- num1   requisition_line_id
-- num2   requisition_header_id
----------------------------------------------------------------

-- SQL What: Insert into PO_SESSION_GT the IDs of the req lines that have
-- drop_ship_flag = 'Y'
FORALL i IN 1..p_req_line_id.COUNT
  INSERT INTO po_session_gt
  (key, num1, num2)
  SELECT l_session_gt_key, PRL.requisition_line_id, PRL.requisition_header_id
  FROM po_requisition_lines_all PRL
  WHERE PRL.requisition_line_id = p_req_line_id(i)
  AND PRL.drop_ship_flag = 'Y';

-- SQL What: Select the req line and header IDs from PO_SESSION_GT into
-- the PL/SQL tables l_req_line_id and l_req_header_id.
SELECT GT.num1, GT.num2
BULK COLLECT INTO l_req_line_id, l_req_header_id
FROM po_session_gt GT
WHERE key = l_session_gt_key;

IF (g_debug_stmt) THEN
  PO_DEBUG.debug_var (
    p_log_head => l_log_head,
    p_progress => l_progress,
    p_name => 'l_req_header_id',
    p_value => l_req_header_id
  );

  PO_DEBUG.debug_var (
    p_log_head => l_log_head,
    p_progress => l_progress,
    p_name => 'l_req_line_id',
    p_value => l_req_line_id
  );

  IF (p_req_line_id.COUNT > l_req_line_id.COUNT) THEN
    PO_DEBUG.debug_stmt (
      p_log_head => l_log_head,
      p_token    => l_progress,
      p_message  => 'Skipped '||(p_req_line_id.COUNT - l_req_line_id.COUNT)
                    ||' req lines whose drop_ship_flag is not Y' );
  END IF;
END IF;

IF (l_req_header_id.COUNT > 0) THEN
-- Bug 3639067 END

  PO_REQ_DOCUMENT_CANCEL_GRP.cancel_requisition
      (p_api_version      => 1.0,
      p_req_header_id    => l_req_header_id, -- Bug 3639067
      p_req_line_id      => l_req_line_id, -- Bug 3639067
      p_cancel_date => SYSDATE,
      p_cancel_reason => 'Order Management',
      p_source => 'OM',
      x_return_status  => x_return_status,
      x_msg_count  => x_msg_count,
      x_msg_data  => x_msg_data);

  IF (x_return_status = FND_API.g_ret_sts_error) THEN
      RAISE FND_API.g_exc_error;
  ELSIF (x_return_status = FND_API.g_ret_sts_unexp_error) THEN
      RAISE FND_API.g_exc_unexpected_error;
  END IF;

END IF; -- l_req_header_id - Bug 3639067

l_progress := '050';

x_return_status := FND_API.G_RET_STS_SUCCESS;

-- Set the org context back to the original operating unit.
PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;   -- <R12 MOAC>

EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_ERROR;
        -- Set the org context back to the original operating unit.
        PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;       -- <R12 MOAC>
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Set the org context back to the original operating unit.
        PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;        -- <R12 MOAC>
    WHEN OTHERS THEN
        PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                      p_proc_name => l_api_name,
                                      p_progress => l_progress );
        FND_MSG_PUB.Count_And_Get(p_count => x_msg_count, p_data => x_msg_data);
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        -- Set the org context back to the original operating unit.
        PO_MOAC_UTILS_PVT.set_org_context(l_original_org_id) ;       -- <R12 MOAC>

END cancel_req_po;

-- Bug 3248723 START
-------------------------------------------------------------------------------
--Start of Comments
--Name: call_po_change_api
--Pre-reqs:
--  None.
--Modifies:
--  the org context
--Locks:
--  None.
--Function:
--  Switches the org context to the document's operating unit and calls the
--  PO Change API to apply the requested changes.
--Parameters:
--IN:
--p_chg
--  Object with the requested changes
--OUT:
--x_return_status
--  Indicates procedure return status.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE call_po_change_api (
  p_chg           IN OUT NOCOPY PO_CHANGES_REC_TYPE,
  x_return_status OUT NOCOPY VARCHAR2
) IS
  l_proc_name CONSTANT VARCHAR2(30) := 'call_po_change_api';

  l_progress              VARCHAR2(3) := '000';
  l_authorization_status  PO_HEADERS.AUTHORIZATION_STATUS%TYPE;
  l_document_org_id       PO_HEADERS.ORG_ID%TYPE;
  l_run_submission_checks VARCHAR2(1);
  l_launch_approvals_flag VARCHAR2(1);
  l_errors                PO_API_ERRORS_REC_TYPE;
BEGIN
  -- Retrieve the document's operating unit.
  IF p_chg.po_release_id IS NOT NULL THEN
    SELECT org_id, authorization_status
    INTO l_document_org_id, l_authorization_status
    FROM po_releases_all
    WHERE po_release_id = p_chg.po_release_id;
  ELSE -- PO
    SELECT org_id, authorization_status
    INTO l_document_org_id, l_authorization_status
    FROM po_headers_all
    WHERE po_header_id = p_chg.po_header_id;
  END IF;

  l_progress := '010';

  -- Set Org Context to that of Document
  PO_MOAC_UTILS_PVT.set_org_context(l_document_org_id) ;     -- <R12 MOAC>

  -- If the PO was in Approved status before the change, then perform
  -- submission checks and launch the PO Approval workflow to re-approve
  -- the PO after making the changes.
  IF l_authorization_status = 'APPROVED' THEN
    l_run_submission_checks := FND_API.G_TRUE;
    l_launch_approvals_flag := FND_API.G_TRUE;
  ELSE
    l_run_submission_checks := FND_API.G_FALSE;
    l_launch_approvals_flag := FND_API.G_FALSE;
  END IF;

  l_progress := '020';
  PO_DOCUMENT_UPDATE_GRP.update_document (
    p_api_version              => 1.0,
    p_init_msg_list            => FND_API.G_FALSE,
    x_return_status            => x_return_status,
    p_changes                  => p_chg,
    p_run_submission_checks    => l_run_submission_checks,
    p_launch_approvals_flag    => l_launch_approvals_flag,
    p_buyer_id                 => null,
    p_update_source            => PO_DOCUMENT_UPDATE_GRP.G_UPDATE_SOURCE_OM,
    p_override_date            => null,
    x_api_errors               => l_errors,
    p_approval_background_flag => PO_DOCUMENT_UPDATE_GRP.G_PARAMETER_NO
  );

  l_progress := '030';
  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      -- If non success status, transfer l_errors to FND Message Stack
      FOR j IN 1..l_errors.message_text.count LOOP
        FND_MESSAGE.set_name('PO', 'PO_WRAPPER_MESSAGE');
        FND_MESSAGE.set_token('MESSAGE', l_errors.message_text(j));
        FND_MSG_PUB.Add;
      END LOOP;
  END IF;

EXCEPTION
  WHEN OTHERS THEN
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_proc_name,
                                  p_progress => l_progress );
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END call_po_change_api;
-- Bug 3248723 END

-- <DOC PURGE FPJ START>

-------------------------------------------------------------------------------
--Start of Comments
--Name: purge
--Pre-reqs:
--  None.
--Modifies:
--  drop_ship_flag
--Locks:
--  None.
--Function:
--  Perform necessary action on PO side when a Sales Order is purged.
--  If the purged SO is a drop ship SO, the drop ship flag at PO shipment
--  needs to be updated to NULL.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_init_msg_list
--  Determines whether the message stacked can be initialized within the API
--p_commit
--  Determines whether the API will commit
--p_entity
--  Types of ids that are passing in. For now it has to be 'PO_LINE_LOCATIONS'
--p_entity_id_tbl
--  A table containing ids of the records to be updated. For now they must
--  be drop shipments on a PO.
--OUT:
--IN OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  Number of Error messages
--x_msg_data
--  Error messages body
--Notes:
--Testing:
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE Purge
( p_api_version          IN            NUMBER
 ,p_init_msg_list        IN            VARCHAR2
 ,p_commit               IN            VARCHAR2
 ,x_return_status        OUT NOCOPY    VARCHAR2
 ,x_msg_count            OUT NOCOPY    NUMBER
 ,x_msg_data             OUT NOCOPY    VARCHAR2
 ,p_entity               IN            VARCHAR2
 ,p_entity_id_tbl        IN            PO_TBL_NUMBER
)
IS
  l_api_name VARCHAR2(50) := 'Purge';
  l_api_version NUMBER := 1.0;
  l_progress VARCHAR2(3);
  l_log_head CONSTANT VARCHAR2(100) := c_log_head || '.' || l_api_name;

BEGIN

    l_progress := '000';

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (g_fnd_debug = 'Y') THEN
        PO_DEBUG.debug_begin
        ( p_log_head => l_log_head
        );
    END IF;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

       l_progress := '010';
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_entity_id_tbl IS NULL) THEN
        l_progress := '020';

        IF (g_fnd_debug = 'Y') THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_log_head,
              p_token    => l_progress,
              p_message  => 'entity_id_tbl is empty. quitting'
            );
        END IF;

        RETURN;
    END IF;

    IF (p_entity = 'PO_LINE_LOCATIONS') THEN
        l_progress := '030';

        IF (g_fnd_debug = 'Y') THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_log_head,
              p_token    => l_progress,
              p_message  => 'p_entity_id_tbl.COUNT=' ||
                            p_entity_id_tbl.COUNT
            );
        END IF;

        --SQL What: Set drop ship flag on the PO shipment to NULL when
        --          the assocaited SO is purged
        --SQL Why:  The association between SO and PO will be removed once
        --          the SO is purged.

        FORALL i IN 1..p_entity_id_tbl.COUNT
            UPDATE po_line_locations_all PLL
            SET    drop_ship_flag = ''
            WHERE  PLL.line_location_id = p_entity_id_tbl(i);

        IF (g_fnd_debug = 'Y') THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_log_head,
              p_token    => l_progress,
              p_message  => '# of updated rows: ' || SQL%ROWCOUNT
            );
        END IF;

    ELSE
        l_progress := '050';

        IF (g_fnd_debug = 'Y') THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_log_head,
              p_token    => l_progress,
              p_message  => 'Unknown entity: ' || p_entity
            );
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name        => g_pkg_name,
          p_procedure_name  => l_api_name || '.' || l_progress,
          p_error_text      => 'Unknown entity: ' || p_entity
        );

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    l_progress := '060';

    IF (FND_API.to_boolean(p_commit)) THEN

        l_progress := '070';
        COMMIT;

    END IF;

    IF (g_fnd_debug = 'Y') THEN
        PO_DEBUG.debug_end
        ( p_log_head => l_log_head
        );
    END IF;

EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name,
                                  p_progress => l_progress );
    FND_MSG_PUB.count_and_get
    ( p_encoded => 'F',
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END Purge;


-------------------------------------------------------------------------------
--Start of Comments
--Name: validate_purge
--Pre-reqs:
--  None.
--Modifies:
--  None
--Locks:
--  None.
--Function:
--  Given the drop shipment id of a PO, this procedure determines whether the
--  corresponing SO is purgable. This is called before a Sales Order is about
--  to be purged
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_init_msg_list
--  Determines whether the message stacked can be initialized within the API
--p_commit
--  Determines whether the API will commit
--p_entity
--  Types of ids that are passing in. For now it has to be 'PO_LINE_LOCATIONS'
--p_entity_id_tbl
--  A table containing ids of the records to checked. For now they must
--  be the PO shipments, with the corrsponding SO line that are about to be
--  purged
--IN OUT:
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  Number of Error messages
--x_msg_data
--  Error messages body
--x_purge_allowed_tbl
--  Returns 'Y' if the corresponding shipment in p_entity_id_tbl is in a state
--  where the corresponding SO is allowed to be purged. (and 'N' otherwise)
--  The number of entries returned in this structure should be the same as
--  that in p_entity_id_tbl. This API will always re-initialize this parameter
--Notes:
--Testing:
--End of Comments
-------------------------------------------------------------------------------

PROCEDURE Validate_Purge
( p_api_version          IN            NUMBER
 ,p_init_msg_list        IN            VARCHAR2
 ,p_commit               IN            VARCHAR2
 ,x_return_status        OUT NOCOPY    VARCHAR2
 ,x_msg_count            OUT NOCOPY    NUMBER
 ,x_msg_data             OUT NOCOPY    VARCHAR2
 ,p_entity               IN            VARCHAR2
 ,p_entity_id_tbl        IN            PO_TBL_NUMBER
 ,x_purge_allowed_tbl    OUT NOCOPY    PO_TBL_VARCHAR1
)
IS
  l_api_name VARCHAR2(50) := 'Validate_Purge';
  l_api_version NUMBER := 1.0;
  l_progress VARCHAR2(3);
  l_log_head CONSTANT VARCHAR2(100) := c_log_head || '.' || l_api_name;

  l_seq_id   NUMBER;

  l_order_tbl PO_TBL_NUMBER := PO_TBL_NUMBER();
BEGIN
    l_progress := '000';

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (g_fnd_debug = 'Y') THEN
        PO_DEBUG.debug_begin
        ( p_log_head => l_log_head
        );
    END IF;

    IF (FND_API.to_boolean(p_init_msg_list)) THEN
        FND_MSG_PUB.initialize;
    END IF;

    IF (NOT FND_API.Compatible_API_Call
            ( p_current_version_number => l_api_version,
              p_caller_version_number  => p_api_version,
              p_api_name               => l_api_name,
              p_pkg_name               => g_pkg_name
            )
       ) THEN

       l_progress := '010';
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    IF (p_entity_id_tbl IS NULL) THEN
        l_progress := '020';

        IF (g_fnd_debug = 'Y') THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_log_head,
              p_token    => l_progress,
              p_message  => 'entity_id_tbl is empty. quitting'
            );
        END IF;

        RETURN;
    END IF;

    l_order_tbl.extend(p_entity_id_tbl.COUNT);

    FOR i IN 1..l_order_tbl.COUNT LOOP
        l_order_tbl(i) := i;
    END LOOP;

    IF (g_fnd_debug = 'Y') THEN
        PO_DEBUG.debug_stmt
        ( p_log_head => l_log_head,
          p_token    => l_progress,
          p_message  => 'l_order_tbl.count= ' || l_order_tbl.COUNT
        );
    END IF;

    l_progress := '030';

    SELECT PO_SESSION_GT_S.nextval
    INTO   l_seq_id
    FROM   DUAL;

    IF (g_fnd_debug = 'Y') THEN
        PO_DEBUG.debug_stmt
        ( p_log_head => l_log_head,
          p_token    => l_progress,
          p_message  => 'seq_id = ' || l_seq_id
        );
    END IF;

    FORALL i IN 1..p_entity_id_tbl.COUNT
       INSERT INTO po_session_gt
       ( key,
         num1,
         num2 )
       VALUES
       ( l_seq_id,
         p_entity_id_tbl(i),
         l_order_tbl(i) );

    l_progress := '040';

    IF (p_entity = 'PO_LINE_LOCATIONS') THEN
        l_progress := '050';

        --SQL WHAT: Determine whether a SO can be purged or not by
        --          Checking the following things on the associated PO:
        --          Does PO still exist? - If No, then allow purge
        --          IS PO finally closed? - If Yes, then allow purge
        --          Is PO Cancelled? - If Yes, then allow purge
        --          Otherwise, disallow purge
        --SQL WHY:  SO should not be purged if the associated PO is not
        --          in an unmodifiable stage

        SELECT DECODE (PH.po_header_id,
                       NULL, 'Y',                      -- po is deleted
                       DECODE (PH.closed_code,
                               'FINALLY CLOSED', 'Y',  -- po is finally closed
                               DECODE (PH.cancel_flag,
                                       'Y', 'Y',       -- po is cancelled
                                       'N')))
        BULK COLLECT INTO x_purge_allowed_tbl
        FROM   po_session_gt PSG,
               po_headers_all PH,
               po_line_locations_all PLL
        WHERE  PSG.key = l_seq_id
        AND    PSG.num1 = PLL.line_location_id (+)
        AND    PLL.po_header_id = PH.po_header_id (+)
        ORDER BY PSG.num2 asc;

        IF (g_fnd_debug = 'Y') THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_log_head,
              p_token    => l_progress,
              p_message  => 'x_purge_allowed.COUNT = ' ||
                            x_purge_allowed_tbl.COUNT
            );
        END IF;

    ELSE
        l_progress := '060';

        IF (g_fnd_debug = 'Y') THEN
            PO_DEBUG.debug_stmt
            ( p_log_head => l_log_head,
              p_token    => l_progress,
              p_message  => 'Unknown entity: ' || p_entity
            );
        END IF;

        FND_MSG_PUB.add_exc_msg
        ( p_pkg_name        => g_pkg_name,
          p_procedure_name  => l_api_name || '.' || l_progress,
          p_error_text      => 'Unknown entity: ' || p_entity
        );

        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

    END IF;

    l_progress := '070';
    DELETE FROM po_session_gt WHERE key = l_seq_id;

    IF (FND_API.to_boolean(p_commit)) THEN

        l_progress := '080';
        COMMIT;

    END IF;

    IF (g_fnd_debug = 'Y') THEN
        PO_DEBUG.debug_end
        ( p_log_head => l_log_head
        );
    END IF;


EXCEPTION
WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    PO_DEBUG.handle_unexp_error ( p_pkg_name => g_pkg_name,
                                  p_proc_name => l_api_name,
                                  p_progress => l_progress );
    FND_MSG_PUB.count_and_get
    ( p_encoded => 'F',
      p_count   => x_msg_count,
      p_data    => x_msg_data
    );

END Validate_Purge;

-- <DOC PURGE FPJ END>

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_drop_ship_details
--Pre-reqs:
--  none
--Modifies:
--  None.
--Locks:
--  None.
--Procedure:
--  Returns drop ship info for a given shipment
--Parameters:
--IN:
--p_api_version
--  Initial API version : Expected value is 1.0
--p_line_location_id
-- shipment identifier
--OUT:
--x_order_line_info_rec
--  Record containing the order line info
--x_msg_data
-- Message returned by the API
--x_msg_count
-- Number of error messages
--x_ret_status
--  (a) FND_API.G_RET_STS_SUCCESS - 'S' if successful
--  (b) FND_API.G_RET_STS_ERROR - 'E' if known error occurs
--  (c) FND_API.G_RET_STS_UNEXP_ERROR - 'U' if unexpected error occurs
--Testing:
--  None.
--End of Comments
-------------------------------------------------------------------------------
PROCEDURE get_drop_ship_details(p_api_version   IN NUMBER,
                         p_line_location_id     IN NUMBER,
                         x_customer_name        OUT NOCOPY VARCHAR2,
                         x_customer_contact OUT NOCOPY VARCHAR2,
                         x_shipping_method OUT NOCOPY VARCHAR2,
                         x_shipping_instructions OUT NOCOPY VARCHAR2,
                         x_packing_instructions OUT NOCOPY VARCHAR2,
                         x_so_num OUT NOCOPY VARCHAR2,
                         x_so_line_num OUT NOCOPY VARCHAR2,
                         x_so_status OUT NOCOPY VARCHAR2,
                         x_ordered_qty OUT NOCOPY NUMBER,
                         x_shipped_qty OUT NOCOPY NUMBER,
                         x_customer_po_number OUT NOCOPY VARCHAR2,
                         x_customer_po_line_num OUT NOCOPY VARCHAR2,
                         x_customer_po_shipment_num OUT NOCOPY VARCHAR2,
                         x_customer_item_desc   OUT NOCOPY VARCHAR2,
                         x_msg_data             OUT NOCOPY VARCHAR2,
                         x_msg_count            OUT NOCOPY NUMBER,
                         x_return_status        OUT NOCOPY VARCHAR2 ) IS

l_api_name              CONSTANT VARCHAR2(30) := 'get_drop_ship_details';
l_api_version           CONSTANT NUMBER := 1.0;
l_order_line_info_rec   OE_DROP_SHIP_GRP.Order_Line_Info_Rec_Type;

BEGIN
 -- Initialise the return status
 x_return_status := FND_API.G_RET_STS_SUCCESS;

 -- check for API version
 IF ( NOT FND_API.compatible_api_call(l_api_version,p_api_version,l_api_name,G_PKG_NAME) )
 THEN
   x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
   return;
 END IF;

 -- Call the OM API to get the drop ship info
 OE_DROP_SHIP_GRP.get_order_line_info(
                           P_API_VERSION    => 1.0,
                           P_PO_HEADER_ID   => null,
                           P_PO_LINE_ID     => null,
                           P_PO_LINE_LOCATION_ID  => p_line_location_id,
                           P_PO_RELEASE_ID  => null,
                           P_MODE           => 2 ,
                           X_ORDER_LINE_INFO_REC  => l_order_line_info_rec,
                           X_MSG_DATA       => x_msg_data,
                           X_MSG_COUNT      => x_msg_count,
                           X_RETURN_STATUS  => x_return_status );

 IF  X_RETURN_STATUS = FND_API.G_RET_STS_SUCCESS THEN
   x_customer_name         := l_order_line_info_rec.SHIP_TO_CUSTOMER_NAME;
   x_customer_contact      := l_order_line_info_rec.SHIP_TO_CONTACT_NAME;
   x_shipping_method       := l_order_line_info_rec.SHIPPING_METHOD;
   x_shipping_instructions := l_order_line_info_rec.SHIPPING_INSTRUCTIONS;
   x_packing_instructions  := l_order_line_info_rec.PACKING_INSTRUCTIONS;
   x_so_num                := l_order_line_info_rec.SALES_ORDER_NUMBER;
   x_so_line_num           := l_order_line_info_rec.SALES_ORDER_LINE_NUMBER;
   x_so_status             := l_order_line_info_rec.SALES_ORDER_LINE_STATUS;
   x_ordered_qty           := l_order_line_info_rec.SALES_ORDER_LINE_ORDERED_QTY;
   x_shipped_qty           := l_order_line_info_rec.SALES_ORDER_LINE_SHIPPED_QTY;
   x_customer_item_desc    := l_order_line_info_rec.CUSTOMER_PRODUCT_DESCRIPTION;
   x_customer_po_number    := l_order_line_info_rec.CUSTOMER_PO_NUMBER;
   x_customer_po_line_num  := l_order_line_info_rec.CUSTOMER_PO_LINE_NUMBER;
   x_customer_po_shipment_num := l_order_line_info_rec.CUSTOMER_PO_SHIPMENT_NUMBER;
 END IF;

EXCEPTION
When Others then
     x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END;

END PO_OM_INTEGRATION_GRP;

/
