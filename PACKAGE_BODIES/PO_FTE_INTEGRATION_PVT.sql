--------------------------------------------------------
--  DDL for Package Body PO_FTE_INTEGRATION_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_FTE_INTEGRATION_PVT" AS
/* $Header: POXVFTEB.pls 120.2 2005/10/20 00:58:12 kpsingh noship $ */

g_pkg_name  CONSTANT VARCHAR2(30) := 'PO_FTE_INTEGRATION_PVT';
c_log_head  CONSTANT VARCHAR2(50) := 'po.plsql.'|| g_pkg_name || '.';
g_fnd_debug VARCHAR2(1) := NVL(FND_PROFILE.VALUE('AFLOG_ENABLED'),'N');

-------------------------------------------------------------------------------
--Start of Comments
--Name: get_po_release_attributes
--Pre-reqs:
--  None.
--Modifies:
--  None.
--Locks:
--  None.
--Function:
--  Get attributes of Standard Purchase Order and Blanket Release for
--  Transportation delivery record.
--Parameters:
--IN:
--p_api_version
--  Specifies API version.
--p_line_location_id
--  Corresponding to po_line_location_id
--OUT:
--x_return_status
--  Indicates API return status as 'S', 'E' or 'U'.
--x_msg_count
--  Error messages number.
--x_msg_data
--  Error messages body.
--x_po_release_attributes
--Testing:
--  Call this API when only line_location_id exists.
--End of Comments
-------------------------------------------------------------------------------


PROCEDURE get_po_release_attributes(
    p_api_version            IN         NUMBER,
    x_return_status          OUT NOCOPY VARCHAR2,
    x_msg_count              OUT NOCOPY NUMBER,
    x_msg_data               OUT NOCOPY VARCHAR2,
    p_line_location_id       IN         NUMBER,
    x_po_releases_attributes OUT NOCOPY PO_FTE_INTEGRATION_GRP.po_release_rec_type
)
IS
l_api_name       CONSTANT VARCHAR2(100)   := 'get_po_release_attributes';
l_api_version    CONSTANT NUMBER          := 1.0;
l_progress       VARCHAR2(3)              := '001';

BEGIN
    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string (
            log_level => FND_LOG.LEVEL_STATEMENT,
            module    => c_log_head || '.'||l_api_name||'.' || l_progress,
            message   => 'Check API Call Compatibility');
        END IF;
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call(
               p_current_version_number => l_api_version,
               p_caller_version_number  => p_api_version,
               p_api_name               => l_api_name,
               p_pkg_name               => g_pkg_name) THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    IF (g_fnd_debug = 'Y') THEN
        IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_STATEMENT) THEN
          FND_LOG.string (
            log_level => FND_LOG.LEVEL_STATEMENT,
            module    => c_log_head || '.'||l_api_name||'.' || l_progress,
            message   => 'Query to get x_po_releases_attributes');
        END IF;
    END IF;

    --SQL What: Querying data from Standard PO or Blanket Release based on
    --SQL       line_location_id
    --SQL Where: MUOM1.unit_of_measure(+) = POL.secondary_unit_of_measure
    --SQL        To get secondary_uom_code
    --SQL Why: Same as SQL What

    SELECT POR.po_release_id,
           POR.release_num,
           POR.revision_num,
          --bug 3633863: removed decode on release_id; always use header_id
           POH.po_header_id,
           POH.vendor_id,
           POH.vendor_site_id,
           POH.user_hold_flag,
           POH.freight_terms_lookup_code,
           POH.fob_lookup_code,
           POH.segment1,
           DECODE(POLL.po_release_id, NULL, 1, 2),
           PDT.type_name,
           POH.org_id,
           POH.currency_code,
           DECODE(POLL.po_release_id, NULL, POH.shipping_control,
                                            POR.shipping_control),
           POH.revision_num,
           POL.po_line_id,
           POL.item_id,
           POL.item_description,
           POL.hazard_class_id,
           POL.item_revision,
           POL.vendor_product_num,
           POL.line_num,
           DECODE(PLT.outside_operation_flag, 'Y', 'GB_OSP', 'GB'),
           POLL.country_of_origin_code,
           POLL.ship_to_location_id,
           POLL.qty_rcv_tolerance,
           POLL.receive_close_tolerance,
           POLL.quantity_shipped,
           POLL.need_by_date,
           POLL.promised_date,
           POLL.ship_to_organization_id,
           POLL.quantity,
           MUOM.uom_code,
           POLL.quantity_cancelled,
           POLL.price_override,
           POLL.preferred_grade,
           POLL.secondary_quantity,
           MUOM1.uom_code,
           POLL.secondary_quantity_cancelled,
           POLL.shipment_num,
           POLL.days_early_receipt_allowed,
           POLL.days_late_receipt_allowed,
           POLL.drop_ship_flag,
           POLL.qty_rcv_exception_code,
           POLL.closed_flag,
           POLL.closed_code,
           POLL.cancel_flag,
           POLL.receipt_days_exception_code,
           POLL.enforce_ship_to_location_code,
           POLL.sales_order_update_date,
           FRT.party_id
      INTO x_po_releases_attributes.source_blanket_reference_id,
           x_po_releases_attributes.source_blanket_reference_num,
           x_po_releases_attributes.release_revision,
           x_po_releases_attributes.header_id,
           x_po_releases_attributes.vendor_id,
           x_po_releases_attributes.ship_from_site_id,
           x_po_releases_attributes.hold_code,
           x_po_releases_attributes.freight_terms_code,
           x_po_releases_attributes.fob_point_code,
           x_po_releases_attributes.source_header_number,
           x_po_releases_attributes.source_header_type_id,
           x_po_releases_attributes.source_header_type_name,
           x_po_releases_attributes.org_id,
           x_po_releases_attributes.currency_code,
           x_po_releases_attributes.shipping_control,
           x_po_releases_attributes.po_revision,
           x_po_releases_attributes.line_id,
           x_po_releases_attributes.inventory_item_id,
           x_po_releases_attributes.item_description,
           x_po_releases_attributes.hazard_class_id,
           x_po_releases_attributes.revision,
           x_po_releases_attributes.supplier_item_num,
           x_po_releases_attributes.source_line_number,
           x_po_releases_attributes.source_line_type_code,
           x_po_releases_attributes.country_of_origin,
           x_po_releases_attributes.ship_to_location_id,
           x_po_releases_attributes.ship_tolerance_above,
           x_po_releases_attributes.ship_tolerance_below,
           x_po_releases_attributes.shipped_quantity,
           x_po_releases_attributes.request_date,
           x_po_releases_attributes.schedule_ship_date,
           x_po_releases_attributes.organization_id,
           x_po_releases_attributes.ordered_quantity,
           x_po_releases_attributes.order_quantity_uom,
           x_po_releases_attributes.cancelled_quantity,
           x_po_releases_attributes.unit_list_price,
           x_po_releases_attributes.preferred_grade,
           x_po_releases_attributes.ordered_quantity2,
           x_po_releases_attributes.ordered_quantity_uom2,
           x_po_releases_attributes.cancelled_quantity2,
           x_po_releases_attributes.po_shipment_line_number,
           x_po_releases_attributes.days_early_receipt_allowed,
           x_po_releases_attributes.days_late_receipt_allowed,
           x_po_releases_attributes.drop_ship_flag,
           x_po_releases_attributes.qty_rcv_exception_code,
           x_po_releases_attributes.closed_flag,
           x_po_releases_attributes.closed_code,
           x_po_releases_attributes.cancelled_flag,
           x_po_releases_attributes.receipt_days_exception_code,
           x_po_releases_attributes.enforce_ship_to_location_code,
           x_po_releases_attributes.shipping_details_updated_on,
           x_po_releases_attributes.carrier_id
      FROM PO_HEADERS_ALL           POH,
           PO_LINES_ALL             POL,
           PO_LINE_LOCATIONS_ALL    POLL,
           PO_RELEASES_ALL          POR,
           PO_LINE_TYPES_B          PLT,
           MTL_UNITS_OF_MEASURE     MUOM,
           MTL_UNITS_OF_MEASURE     MUOM1,
           ORG_FREIGHT_TL           FRT,
           PO_DOCUMENT_TYPES_ALL_TL PDT   -- Bug #4635593
     WHERE POLL.line_location_id = p_line_location_id
       AND PDT.document_type_code =
           DECODE(POLL.po_release_id, NULL, 'PO', 'PA')
       AND PDT.document_subtype
           = DECODE(POLL.po_release_id, NULL, POH.type_lookup_code,
                                              POR.release_type)
       AND POL.po_line_id = POLL.po_line_id
       AND POH.po_header_id = POL.po_header_id
       AND POR.po_release_id(+) = POLL.po_release_id
       AND FRT.freight_code (+) = POH.ship_via_lookup_code
       AND FRT.language (+) = USERENV('LANG')
       AND NVL(FRT.organization_id, POLL.ship_to_organization_id)
           = POLL.ship_to_organization_id
       AND POL.line_type_id = PLT.line_type_id
       AND MUOM.unit_of_measure = POL.unit_meas_lookup_code
       AND MUOM1.unit_of_measure(+) = POLL.secondary_unit_of_measure
       AND POH.ORG_ID = PDT.ORG_ID          -- Bug #4635593
       AND PDT.LANGUAGE = USERENV('LANG');  -- Bug #4635593

EXCEPTION
    WHEN OTHERS THEN
        IF (g_fnd_debug = 'Y') THEN
            IF (FND_LOG.G_CURRENT_RUNTIME_LEVEL <= FND_LOG.LEVEL_EXCEPTION) THEN
              FND_LOG.string( log_level => FND_LOG.LEVEL_EXCEPTION,
                            module    => c_log_head || '.'||l_api_name,
                            message   => 'unexpected error');
            END IF;
        END IF;
        FND_MSG_PUB.add_exc_msg ( G_PKG_NAME, l_api_name );
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
END get_po_release_attributes;

END PO_FTE_INTEGRATION_PVT;

/
