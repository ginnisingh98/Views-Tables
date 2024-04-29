--------------------------------------------------------
--  DDL for Package Body PO_CHARGES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PO_CHARGES_GRP" AS
/* $Header: POXGFSCB.pls 120.16.12010000.13 2013/10/03 11:40:50 inagdeo ship $*/

-- package globals
G_PKG_NAME    CONSTANT VARCHAR2(30) := 'PO_CHARGES_GRP';
G_LOG_MODULE  CONSTANT VARCHAR2(40) := 'po.plsql.' || G_PKG_NAME;
G_CONC_LOG             VARCHAR2(32767);

g_asn_debug VARCHAR2(1) := asn_debug.is_debug_on;  -- Bug 9152790: rcv debug enhancement
g_fte_cost_factor_details pon_price_element_types_vl%ROWTYPE:= pon_cf_type_grp.get_cost_factor_details('ORACLE_FTE_COST');
g_dummy_rci_tbl RCV_CHARGES_GRP.charge_interface_table_type;
g_charge_numbers NUMBER;

-- Private support procedures

-- wrapper for asn_debug
PROCEDURE string
( log_level   IN number
, module      IN varchar2
, message     IN varchar2
) IS
BEGIN
    -- add to fnd_log_messages
    asn_debug.put_line(module||': '||message,log_level);
END string;

-- helper function for testing if a line has been rated in FTE
FUNCTION shipment_line_fte_rated(p_shipment_line_id NUMBER) RETURN BOOLEAN IS
    l_count NUMBER;
BEGIN
    SELECT count(*)
      INTO l_count
      FROM po_rcv_charges
     WHERE shipment_line_id = p_shipment_line_id
       AND cost_factor_id = -20;

    IF l_count < 1 THEN
        RETURN FALSE;
    ELSE
        RETURN TRUE;
    END IF;
END shipment_line_fte_rated;

-- Public Procedures

PROCEDURE Capture_QP_Charges
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_group_id           IN NUMBER
, p_request_id         IN NUMBER
) IS --{
    l_rsh_id_table        DBMS_SQL.number_table;
    l_charge_table        CHARGE_TABLE_TYPE;
    l_charge_alloc_table  CHARGE_ALLOCATION_TABLE_TYPE;
    l_cost_factor_details PON_PRICE_ELEMENT_TYPES_VL%ROWTYPE;
    k                     NUMBER;
BEGIN

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Entering Capture_QP_Charges() for group_id:' || p_group_id
                           || ' and request_id:'|| p_request_id);
    END IF;
    k := 1;
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Retrieve QP charges for PO receipts and import ASN

    SELECT shipment_header_id
    BULK COLLECT INTO l_rsh_id_table
    FROM   (-- po receipts
            SELECT rt.shipment_header_id
              FROM rcv_transactions rt,
                   rcv_parameters rp,
                   po_line_locations_all pll -- lcm changes
             WHERE rt.group_id = DECODE (p_group_id, 0, rt.group_id, p_group_id)
               AND rt.request_id = p_request_id
               AND rt.organization_id = rp.organization_id
               AND rt.transaction_type = 'RECEIVE'
               AND rt.source_document_code = 'PO'
               AND rp.advanced_pricing = 'Y'
               -- to exclude receipts agasint ASN
               AND (NOT EXISTS (SELECT 1 FROM po_rcv_charges prc
                            WHERE rt.shipment_header_id = prc.shipment_header_id))
               AND rt.po_line_location_id = pll.line_location_id
               AND nvl(pll.lcm_flag, 'N') = 'N'
            UNION
            -- import ASN
            SELECT rsh.shipment_header_id
              FROM rcv_shipment_headers rsh,
                   rcv_headers_interface rhi,
                   rcv_parameters rp
             WHERE rhi.group_id = DECODE(p_group_id, 0, rhi.group_id, p_group_id)
               AND rsh.shipment_num = rhi.shipment_num
               AND rsh.request_id = p_request_id
               AND rsh.receipt_source_code = 'VENDOR'
               AND rsh.ship_to_org_id = rp.organization_id
               AND rp.advanced_pricing = 'Y');

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Number of shipment headers retrieved for QP:' || l_rsh_id_table.count);
    END IF;

    IF l_rsh_id_table.count < 1 THEN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('No shipment found for QP charges -> Return.');
        END IF;
        RETURN;
    END IF;

    FOR i IN l_rsh_id_table.FIRST..l_rsh_id_table.LAST LOOP --{

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Inside QP rsh loop for rsh_id_tbl('||i||'): '|| l_rsh_id_table(i));
    END IF;

    DECLARE
        l_header_rec          PO_ADVANCED_PRICE_PVT.Header_Rec_Type;
        l_line_rec_table      PO_ADVANCED_PRICE_PVT.Line_Tbl_Type;
        l_freight_charge_tbl  PO_ADVANCED_PRICE_PVT.Freight_Charges_Rec_Tbl_Type;
        l_qp_cost_table       PO_ADVANCED_PRICE_PVT.Qp_Price_Result_Rec_Tbl_Type;
        l_rsh_id              RCV_SHIPMENT_HEADERS.shipment_header_id%type;
        l_rsl_id              RCV_SHIPMENT_LINES.shipment_line_id%type;
        l_currency_code       RCV_SHIPMENT_HEADERS.currency_code%type;

        l_line_quantities     DBMS_SQL.number_table;

        l_return_status       VARCHAR2(1);
        l_no_qp_charge        EXCEPTION;
        l_no_freight_charge   EXCEPTION;
        l_qp_api_exception    EXCEPTION;
        l_qp_charge_exception EXCEPTION;
        l_line_level_charge   VARCHAR2(1) := 'N';  --Bug 8551844
    BEGIN
        l_rsh_id := l_rsh_id_table(i);

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Populating l_header_rec');
        END IF;
        -- populate l_header_rec
        SELECT PO_MOAC_UTILS_PVT.get_current_org_id,
               NULL, --p_order_header_id
               vendor_id,
               vendor_site_id,
               creation_date,
               NULL, --order_type
               ship_to_location_id,
               ship_to_org_id,
               shipment_header_id,
               hazard_class,
               hazard_code,
               shipped_date,
               shipment_num,
               carrier_method,
               packaging_code,
               freight_carrier_code,
               freight_terms,
               currency_code,
               conversion_rate,
               conversion_rate_type,
               organization_id,
               expected_receipt_date
          INTO l_header_rec
          FROM rcv_shipment_headers
         WHERE shipment_header_id = l_rsh_id;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Populating l_line_rec');
        END IF;
        -- populate l_line_rec_table
        -- Passing Vendor_id and vendor_site_id so that line level modifiers with qualifiers will be applied.
        --Bug 8731760, Acquisiton costs are not correct when PO UOM is different from receipt UOM.
        --So,Passing the quantity to Pricing in PO UOM .
        SELECT NULL, --order_line_id
               NULL, --agreement_type
               NULL, --agreement_id
               NULL, --agreement_line_id
               pha.vendor_id, -- Bug 7186657
               pha.vendor_site_id, --Bug 7186657
               rsl.ship_to_location_id,
               NULL, --ship_to_org_id
               rsl.vendor_item_num,
               rsl.item_revision,
               rsl.item_id,
               NULL, --category_id
               pha.rate,
               pha.rate_type,
               pha.currency_code,
               plla.need_by_date, --need_by_date
               rsl.shipment_line_id,
               rsl.primary_unit_of_measure,
               rsl.to_organization_id,
               NVL(pla.unit_meas_lookup_code,plla.unit_meas_lookup_code),
               rsl.source_document_code,
               pla.unit_price,
               ROUND(decode(rsl.quantity_received, 0, rsl.quantity_shipped, rsl.quantity_received)*
 	            po_uom_s.po_uom_convert(rsl.unit_of_measure,NVL(pla.unit_meas_lookup_code,plla.unit_meas_lookup_code),nvl(rsl.item_id,0)),9),
               NULL, --order_type added for pricing enhancement
	       NULL, -- existing_line_flag <PDOI Enhancement Bug#17063664>
               NULL -- allow_price_override_flag <PDOI Enhancement Bug#17063664>
        BULK COLLECT INTO l_line_rec_table
          FROM rcv_shipment_lines rsl,
               po_lines_all pla,
               po_headers_all pha,
               po_line_locations_all plla
         WHERE rsl.po_line_id = pla.po_line_id
           AND rsl.po_header_id = pha.po_header_id
           ANd rsl.po_line_location_id = plla.line_location_id
           AND rsl.shipment_header_id = l_rsh_id
           AND nvl(plla.lcm_flag,'N') = 'N'; -- lcm changes

        -- lcm changes
        IF (l_line_rec_table.COUNT = 0) THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('No shipment line found for QP charges -> Return.');
            END IF;
          RETURN;
        END IF;


        -- Bug 4776006: Use the currency_code of the first receipt line
        -- if there is no currency defined on receipt header level.
        IF l_header_rec.currency_code IS NULL THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Use first receipt line currency_code: '
                                    || l_line_rec_table(1).currency_code);
            END IF;
            l_header_rec.currency_code := l_line_rec_table(1).currency_code;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Calling PO_ADVANCED_PRICE_PVT.get_advanced_price');
        END IF;

        --PO_LOG.enable_logging();

        PO_ADVANCED_PRICE_PVT.get_advanced_price(
              p_header_rec          => l_header_rec
             ,p_line_rec_tbl        => l_line_rec_table
             ,p_request_type        => 'PO'
             ,p_pricing_event       => 'PO_RECEIPT'
             ,p_has_header_pricing  => TRUE
             ,p_return_price_flag   => FALSE
             ,p_return_freight_flag => TRUE
             ,x_price_tbl           => l_qp_cost_table
             ,x_return_status       => l_return_status);

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('l_return_status: '|| l_return_status);
        END IF;

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE l_qp_api_exception;
        END IF;

        IF l_qp_cost_table.count < 1 THEN
             RAISE l_no_qp_charge;
        END IF;

        IF (g_asn_debug = 'Y') THEN
             asn_debug.put_line('Number of lines in l_qp_cost_table: ' ||l_qp_cost_table.count);
        END IF;

        l_currency_code := l_header_rec.currency_code;

        -- prepare the quantities for multiplying with freight charges
        FOR l in l_line_rec_table.FIRST..l_line_rec_table.LAST LOOP
            l_line_quantities(l_line_rec_table(l).shipment_line_id) := NVL(l_line_rec_table(l).quantity, 1);
        END LOOP;

        FOR j IN l_qp_cost_table.FIRST..l_qp_cost_table.LAST LOOP --{
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Retrieving freight charges from l_qp_cost_table('||j||').'
                                   ||' with line_id = '|| l_qp_cost_table(j).line_id);
            END IF;

            BEGIN --{ line loop block
                IF l_qp_cost_table(j).freight_charge_rec_tbl.COUNT < 1 THEN
                    RAISE l_no_freight_charge;
                END IF;

		        /* Bug 8551844: Checking if there are lines with shipment_header_id = shipment_line_id
 	            ** If yes, check then treat it as line level charge */
 	            Begin
 	                 SELECT 'Y'
 	                        INTO l_line_level_charge
 	                        FROM rcv_shipment_lines
 	                        WHERE shipment_header_id = l_rsh_id
 	                        AND   EXISTS (SELECT 1
 	                                      FROM   rcv_shipment_lines
 	                                      WHERE  shipment_header_id = l_rsh_id
 	                                      AND    shipment_line_id = shipment_header_id);

 	            Exception
 	            When Others then
 	               l_line_level_charge := 'N';
 	            End;
 	            /*
 	            ** Bug 8551844: Add codition l_qp_cost_table(j).base_unit_price IS NOT null here
 	            ** to identify if this is a line level charge or a header level. For line level
 	            ** l_qp_cost_table(j).base_unit_price should always be non-null value.
 	            */
                IF l_qp_cost_table(j).line_id <> l_rsh_id OR
 	            (l_qp_cost_table(j).line_id = l_rsh_id AND l_line_level_charge = 'Y'
 	            	AND l_qp_cost_table(j).base_unit_price IS NOT null ) THEN
                    l_rsl_id := l_qp_cost_table(j).line_id;
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('This is a line level charge.');
                    END IF;
                ELSE
                    l_rsl_id :=NULL;
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('This is a header level charge.');
                    END IF;
                END IF;

                l_freight_charge_tbl := l_qp_cost_table(j).freight_charge_rec_tbl;
                FOR n IN l_freight_charge_tbl.FIRST..l_freight_charge_tbl.LAST LOOP --{
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('Getting cost factor detail for cost_factor_id '
                                           ||l_freight_charge_tbl(n).charge_type_code);
                    END IF;
                    l_cost_factor_details :=
                        pon_cf_type_grp.get_cost_factor_details(TO_NUMBER(l_freight_charge_tbl(n).charge_type_code));

                    SELECT po_rcv_charges_s.NEXTVAL
                      INTO l_charge_table(k).charge_id
                      FROM dual;

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('charge_id: ' ||l_charge_table(k).charge_id);
                    END IF;

                    l_charge_table(k).creation_date := SYSDATE;
                    l_charge_table(k).created_by := FND_GLOBAL.user_id;
                    l_charge_table(k).last_update_date := SYSDATE;
                    l_charge_table(k).last_updated_by := FND_GLOBAL.user_id;

                    l_charge_table(k).shipment_header_id := l_rsh_id;
                    l_charge_table(k).shipment_line_id := l_rsl_id;
                    l_charge_table(k).currency_code := l_currency_code;

                    -- bug 4966430: multiply line level freight charge by quantity
                    IF l_qp_cost_table(j).line_id = l_rsl_id THEN
                        l_charge_table(k).estimated_amount := l_freight_charge_tbl(n).freight_charge * l_line_quantities(l_rsl_id);
                    ELSE
                        l_charge_table(k).estimated_amount := l_freight_charge_tbl(n).freight_charge;
                    END IF;

/* Bug#6821589:
   include_in_acquisition_cost is used by Costing team to determine whether they have to
   include that cost mentioned in po_rcv_charges as acquisition cost. As that value is not
   passed, 'Acquisition cost report' is not working properly.
   We need to stamp the cost_acquisition_code got from Cost factor setup table in
   po_rcv_charges.include_in_acquisition_cost
 * */

                    l_charge_table(k).cost_factor_id := l_cost_factor_details.price_element_type_id;
                    l_charge_table(k).allocation_method := l_cost_factor_details.allocation_basis;
                    l_charge_table(k).cost_component_class_id := l_cost_factor_details.cost_component_class_id;
                    l_charge_table(k).cost_analysis_code := l_cost_factor_details.cost_analysis_code;
                    l_charge_table(k).include_in_acquisition_cost := l_cost_factor_details.cost_acquisition_code;--Bug#6821589

                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('After populating charge_table(:' || k || ')');
                        asn_debug.put_line('shipment_header_id: ' || l_charge_table(k).shipment_header_id );
                        asn_debug.put_line('shipment_line_id: ' || l_charge_table(k).shipment_line_id );
                        asn_debug.put_line('estimated_amount: ' || l_charge_table(k).estimated_amount );
                        asn_debug.put_line('currency_code: ' || l_charge_table(k).currency_code );
                        asn_debug.put_line('cost_factor_id: ' || l_charge_table(k).cost_factor_id );
                        asn_debug.put_line('allocation_method: ' ||l_charge_table(k).allocation_method  );
                        asn_debug.put_line('cost_component_class_id: ' || l_charge_table(k).cost_component_class_id );
                        asn_debug.put_line('cost_analysis_code: ' || l_charge_table(k).cost_analysis_code );
                        asn_debug.put_line('include_in_acquisition_cost: ' || l_charge_table(k).include_in_acquisition_cost );--Bug#6821589
                    END IF;
                    k := k + 1; --increment k for every new charge record
                END LOOP; --} end of l_freight_charge_tbl loop
            EXCEPTION
                WHEN l_no_freight_charge THEN
                    IF (g_asn_debug = 'Y') THEN
                        asn_debug.put_line('No QP charge for the line : ' ||l_qp_cost_table(j).line_id);
                    END IF;
            END; --} end of line loop block
        END LOOP; --} end of qp_cost_table loop
    EXCEPTION
        WHEN l_no_qp_charge THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('No QP charge for shipment header:  ' ||l_rsh_id_table(i) );
            END IF;
        WHEN l_qp_api_exception THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('QP API returned error for shipment_id: ' ||l_rsh_id_table(i) );
            END IF;
        WHEN others THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_data := sqlerrm;
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Unexpected exception occured in QP loop: '|| x_msg_data);
            END IF;

    END;
    END LOOP; --} end of rsh_id_table loop

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Total number of QP charges retrieved: ' || l_charge_table.COUNT );
    END IF;

    -- Allocate all the QP charges
    -- QP charges can be header level or line level
    RCV_CHARGES_GRP.Allocate_charges(l_charge_table, l_charge_alloc_table, g_dummy_rci_tbl);

    -- bulk insert po_rcv_charges from the charge table
    FORALL i IN INDICES OF l_charge_table
        INSERT INTO po_rcv_charges
        VALUES l_charge_table(i);

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line(sql%rowcount || ' rows inserted into po_rcv_charges');
    END IF;

    -- bulk insert po_rcv_charge_allocations from the charge table
    FORALL i IN INDICES OF l_charge_alloc_table
        INSERT INTO po_rcv_charge_allocations
        VALUES l_charge_alloc_table(i);

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line(sql%rowcount || ' rows inserted into po_rcv_charge_allocations');
    END IF;

EXCEPTION
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := sqlerrm;
     IF (g_asn_debug = 'Y') THEN
         asn_debug.put_line('Unexpected exception occured in Capture_QP_Charges(): '|| x_msg_data);
     END IF;
END Capture_QP_Charges; --}

PROCEDURE Capture_FTE_Estimated_Charges
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_group_id           IN NUMBER
, p_request_id         IN NUMBER
) IS

    l_rsh_id_table         DBMS_SQL.number_table;
    l_fte_cost_table       FTE_PO_INTEGRATION_GRP.fte_receipt_lines_tab;
    l_charge_table         CHARGE_TABLE_TYPE;
    l_charge_alloc_table   CHARGE_ALLOCATION_TABLE_TYPE;
    l_cost_factor_details  PON_PRICE_ELEMENT_TYPES_VL%ROWTYPE;
    l_precision            NUMBER;
    j                      INTEGER;
    k                      NUMBER;

BEGIN

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Entering Capture_FTE_Estimated_Charges for group_id:' || p_group_id
                           || ' and request_id:'|| p_request_id);
    END IF;

    k := 1;

    x_return_status := FND_API.G_RET_STS_SUCCESS;

    SELECT DISTINCT shipment_header_id
    BULK COLLECT INTO l_rsh_id_table
    FROM rcv_transactions rt,
         rcv_parameters rp,
         po_line_locations_all pll -- lcm changes
    WHERE rt.group_id = decode(p_group_id, 0, rt.group_id, p_group_id)
      AND rt.request_id = p_request_id -- 0 for online mode
      AND rt.transaction_type = 'RECEIVE'
      AND rt.source_document_code = 'PO'
      AND rt.organization_id = rp.organization_id
      AND rp.transportation_execution = 'Y'
      AND rt.po_line_location_id = pll.line_location_id
      AND nvl(pll.lcm_flag, 'N') = 'N';

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Number of shipment headers retreived:' || l_rsh_id_table.COUNT);
    END IF;

    IF l_rsh_id_table.count < 1 THEN
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('No shipment found for FTE charges -> Return.');
        END IF;
        RETURN;
    END IF;

    FOR i IN 1..l_rsh_id_table.COUNT LOOP --{

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Inside FTE rsh loop for rsh_id_tbl('||i||'): '|| l_rsh_id_table(i));
    END IF;

    DECLARE
        l_return_status       VARCHAR2(1);
        l_msg_count           NUMBER;
        l_msg_data            VARCHAR2(2400);
        l_fte_exception       EXCEPTION;
        l_no_fte_charge       EXCEPTION;
    BEGIN

        FTE_PO_INTEGRATION_GRP.get_estimated_rates(
           p_init_msg_list => FND_API.G_FALSE,
           p_api_version_number => 1.0,
           x_msg_count => l_msg_count,
           x_msg_data => l_msg_data,
           x_return_status => l_return_status,
           p_shipment_header_id => l_rsh_id_table(i),
           x_receipt_lines_tab => l_fte_cost_table);

        IF l_return_status <> FND_API.G_RET_STS_SUCCESS THEN
           RAISE l_fte_exception;
        END IF;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Numbers of FTE charges fetched for this rsh: '|| l_fte_cost_table.count);
        END IF;

        IF l_fte_cost_table.count < 1 THEN
            RAISE l_no_fte_charge;
        END IF;

        -- l_fte_cost_table is indexed by rsl_id
        j:= l_fte_cost_table.FIRST;
        WHILE j IS NOT NULL
        LOOP --{
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Processing charge for shipment line: ' ||j);
            END IF;

             -- get the precision for rounding
             DECLARE
                 l_ext_precision NUMBER;
                 l_min_acct_unit NUMBER;
             BEGIN
                 FND_CURRENCY_CACHE.get_info( currency_code => l_fte_cost_table(j).currency_code
                                            , precision     => l_precision
                                            , ext_precision => l_ext_precision
                                            , min_acct_unit => l_min_acct_unit
                                            );
             END;

            IF shipment_line_fte_rated(j) THEN
                -- Update the existing charge with new estimated amount if
                -- the amount is differnt than that on the original charge.
                -- This handles partial receipt and add to receipt, where
                -- currency and vendor remains the same as previous receipt.

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('FTE charge exists for shipment_line: ' || j);
                END IF;

                UPDATE po_rcv_charges
                  SET  estimated_amount = ROUND(l_fte_cost_table(j).total_cost, l_precision)
                WHERE  shipment_line_id = j
                  AND  estimated_amount <> ROUND(l_fte_cost_table(j).total_cost, l_precision);

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('updated ' || sql%rowcount || ' row in po_rcv_charges');
                END IF;

                UPDATE po_rcv_charge_allocations
                  SET  estimated_amount = ROUND(l_fte_cost_table(j).total_cost, l_precision)
                WHERE  shipment_line_id = j
                  AND  estimated_amount <> ROUND(l_fte_cost_table(j).total_cost, l_precision);

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('updated ' || sql%rowcount || ' row in po_rcv_charge_allocations');
                END IF;
            ELSE
                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Populating charge_table (' || k ||')');
                END IF;

                SELECT po_rcv_charges_s.NEXTVAL
                  INTO l_charge_table(k).charge_id
                  FROM dual;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('charge_id: ' ||l_charge_table(k).charge_id);
                END IF;

                l_charge_table(k).creation_date := SYSDATE;
                l_charge_table(k).created_by := FND_GLOBAL.user_id;
                l_charge_table(k).last_update_date := SYSDATE;
                l_charge_table(k).last_updated_by := FND_GLOBAL.user_id;

                l_charge_table(k).shipment_header_id := l_rsh_id_table(i);
                l_charge_table(k).shipment_line_id := l_fte_cost_table(j).rcv_shipment_line_id;
                l_charge_table(k).currency_code := l_fte_cost_table(j).currency_code;
                l_charge_table(k).vendor_id := l_fte_cost_table(j).vendor_id;
                l_charge_table(k).vendor_site_id := l_fte_cost_table(j).vendor_site_id;
                l_charge_table(k).cost_factor_id := g_fte_cost_factor_details.price_element_type_id;
                l_charge_table(k).allocation_method := g_fte_cost_factor_details.allocation_basis;
                l_charge_table(k).cost_component_class_id := g_fte_cost_factor_details.cost_component_class_id;
                l_charge_table(k).cost_analysis_code := g_fte_cost_factor_details.cost_analysis_code;
                l_charge_table(k).include_in_acquisition_cost := g_fte_cost_factor_details.cost_acquisition_code;--Bug#6821589
                l_charge_table(k).estimated_amount := ROUND(l_fte_cost_table(j).total_cost, l_precision);

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('currency_precision: ' || l_precision);
                    asn_debug.put_line('shipment_header_id: ' || l_charge_table(k).shipment_header_id );
                    asn_debug.put_line('shipment_line_id: ' || l_charge_table(k).shipment_line_id );
                    asn_debug.put_line('estimated_amount: ' || l_charge_table(k).estimated_amount );
                    asn_debug.put_line('currency_code: ' || l_charge_table(k).currency_code );
                    asn_debug.put_line('vendor_id: ' || l_charge_table(k).vendor_id);
                    asn_debug.put_line('vendor_site_id: ' || l_charge_table(k).vendor_site_id);
                    asn_debug.put_line('cost_factor_id: ' || l_charge_table(k).cost_factor_id );
                    asn_debug.put_line('allocation_method: ' ||l_charge_table(k).allocation_method  );
                    asn_debug.put_line('cost_component_class_id: ' || l_charge_table(k).cost_component_class_id );
                    asn_debug.put_line('cost_analysis_code: ' || l_charge_table(k).cost_analysis_code );
                    asn_debug.put_line('include_in_acquisition_cost: ' || l_charge_table(k).include_in_acquisition_cost );--Bug#6821589
                END IF;

                IF (g_asn_debug = 'Y') THEN
                    asn_debug.put_line('Done populating charge_table (' || k || ')');
                END IF;

                k := k + 1;
            END IF;
            j := l_fte_cost_table.NEXT(j);
        END LOOP; --} end of fte_cost_table loop
    EXCEPTION
        WHEN l_no_fte_charge THEN
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('No FTE charges retreived for shipment_id: '||l_rsh_id_table(i));
            END IF;
        WHEN l_fte_exception THEN
            x_return_status := FND_API.G_RET_STS_ERROR;
            x_msg_data := l_msg_data;
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('FTE API failed for shipment_id: '||l_rsh_id_table(i)||'. msg_data: '|| l_msg_data );
            END IF;
        WHEN others THEN
            x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            x_msg_data := sqlerrm;
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Unexpected exception occured in FTE loop: '|| x_msg_data);
            END IF;
    END;
    END LOOP; --} end of rsh_id_table loop

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Total number of FTE charges retrieved: ' || l_charge_table.COUNT );
    END IF;

    -- Allocate all the FTE charges
    -- FTE charges are always line level charges
    RCV_CHARGES_GRP.Allocate_Charges(l_charge_table, l_charge_alloc_table, g_dummy_rci_tbl);

    -- bulk insert po_rcv_charges from the charge table
    FORALL i IN INDICES OF l_charge_table
        INSERT INTO po_rcv_charges
        VALUES l_charge_table(i);

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Done bulk insert into po_rcv_charges');
    END IF;

    -- bulk insert po_rcv_charge_allocations from the charge table
    FORALL i IN INDICES OF l_charge_alloc_table
        INSERT INTO po_rcv_charge_allocations
        VALUES l_charge_alloc_table(i);

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Done bulk insert into po_rcv_charge_allocations');
    END IF;

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Exit Capture_FTE_Estimated_Charges()');
    END IF;
EXCEPTION
  WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      x_msg_data := sqlerrm;
      IF (g_asn_debug = 'Y') THEN
          asn_debug.put_line('Unexpected exception occured in Capture_FTE_Estimated_Charges(): ' || x_msg_data);
      END IF;
END Capture_FTE_Estimated_Charges;

-- capture the actual freight charge for each shipment_line upon bill approval
PROCEDURE Capture_FTE_Actual_Charges
( p_api_version           IN NUMBER
, p_init_msg_list         IN VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_fte_actual_charge     IN PO_RCV_CHARGES%ROWTYPE
) IS

l_new_fte_charge           VARCHAR2(1) := 'Y';
l_shipment_line_id         NUMBER;
l_fte_actual_charges       CHARGE_TABLE_TYPE;
l_fte_actual_charge_allocs CHARGE_ALLOCATION_TABLE_TYPE;
l_invalid_shipment         EXCEPTION;

BEGIN
    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Entering Capture_FTE_Actual_Charges()');
    END IF;

    SAVEPOINT PO_FTE_ACTUAL;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list )
    THEN
       FND_MSG_PUB.initialize;
    END IF;

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Initialized FND message');
    END IF;

    x_return_status         := FND_API.G_RET_STS_SUCCESS;
    x_msg_count             := 0;
    x_msg_data              := '';

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Data passed in by FTE');
        asn_debug.put_line('shipment_line_id: ' || p_fte_actual_charge.shipment_line_id );
        asn_debug.put_line('actual_amount: ' || p_fte_actual_charge.actual_amount );
        asn_debug.put_line('currency_code: ' || p_fte_actual_charge.currency_code );
        asn_debug.put_line('vendor_id: ' || p_fte_actual_charge.vendor_id);
        asn_debug.put_line('vendor_site_id: ' || p_fte_actual_charge.vendor_site_id);
        asn_debug.put_line('cost_factor_id: ' || g_fte_cost_factor_details.price_element_type_id);
    END IF;

    -- The actual charge is a previously FTE-estimated charge if:
    -- shipment_line_id matches an existing FTE charge

    SELECT decode(count(*), 0, 'Y', 'N')
      INTO l_new_fte_charge
      FROM po_rcv_charges
     WHERE shipment_line_id = p_fte_actual_charge.shipment_line_id
       AND cost_factor_id = g_fte_cost_factor_details.price_element_type_id
       -- if vendor_id/vendor_site_id is null, consider as an existing
       -- charge if cost type and rsl is matched.
       AND NVL(vendor_id, p_fte_actual_charge.vendor_id)
                     = p_fte_actual_charge.vendor_id
       AND NVL(vendor_site_id, p_fte_actual_charge.vendor_site_id)
                     = p_fte_actual_charge.vendor_site_id;


    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('New FTE Charge? : ' || l_new_fte_charge);
    END IF;

    -- For existing FTE charges, update the charge with the actual cost.
    IF l_new_fte_charge = 'N' THEN

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Updating PO_RCV_CHARGES with actual amount: '
                             || p_fte_actual_charge.actual_amount);
        END IF;

        UPDATE po_rcv_charges
           SET actual_amount = p_fte_actual_charge.actual_amount
             , vendor_id = NVL(vendor_id, p_fte_actual_charge.vendor_id)
             , vendor_site_id =  NVL(vendor_site_id, p_fte_actual_charge.vendor_site_id)
         WHERE shipment_line_id = p_fte_actual_charge.shipment_line_id;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Updating PO_RCV_CHARGE_ALLOCATIONS with actual amount'||
                                p_fte_actual_charge.actual_amount);
        END IF;

        UPDATE po_rcv_charge_allocations
           SET actual_amount = p_fte_actual_charge.actual_amount
         WHERE shipment_line_id = p_fte_actual_charge.shipment_line_id;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Done updating actual amounts for existing charge');
        END IF;
    -- For new charges, populate new rows in po_rcv_charges and po_rcv_charge_allocations.
    ELSE
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('This is a new charge');
        END IF;

        l_fte_actual_charges(1) := p_fte_actual_charge;

        SELECT po_rcv_charges_s.nextval
          INTO l_fte_actual_charges(1).charge_id
          FROM dual;

        SELECT shipment_header_id
          INTO l_fte_actual_charges(1).shipment_header_id
          FROM rcv_shipment_lines
         WHERE shipment_line_id = l_fte_actual_charges(1).shipment_line_id;

        IF l_fte_actual_charges(1).shipment_header_id IS NULL THEN
            RAISE l_invalid_shipment;
        END IF;

        l_fte_actual_charges(1).creation_date := SYSDATE;
        l_fte_actual_charges(1).created_by := FND_GLOBAL.user_id;
        l_fte_actual_charges(1).last_update_date := SYSDATE;
        l_fte_actual_charges(1).last_updated_by := FND_GLOBAL.user_id;

        l_fte_actual_charges(1).cost_factor_id := g_fte_cost_factor_details.price_element_type_id;
        l_fte_actual_charges(1).allocation_method := g_fte_cost_factor_details.allocation_basis;
        l_fte_actual_charges(1).cost_component_class_id := g_fte_cost_factor_details.cost_component_class_id;
        l_fte_actual_charges(1).cost_analysis_code := g_fte_cost_factor_details.cost_analysis_code;
        l_fte_actual_charges(1).include_in_acquisition_cost := g_fte_cost_factor_details.cost_acquisition_code;--Bug#6821589

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('shipment_header_id: ' || l_fte_actual_charges(1).shipment_header_id );
            asn_debug.put_line('shipment_line_id: ' || l_fte_actual_charges(1).shipment_line_id );
            asn_debug.put_line('actual_amount: ' || l_fte_actual_charges(1).actual_amount );
            asn_debug.put_line('currency_code: ' || l_fte_actual_charges(1).currency_code );
            asn_debug.put_line('vendor_id: ' || l_fte_actual_charges(1).vendor_id);
            asn_debug.put_line('vendor_site_id: ' || l_fte_actual_charges(1).vendor_site_id);
            asn_debug.put_line('cost_factor_id: ' || l_fte_actual_charges(1).cost_factor_id );
            asn_debug.put_line('allocation_method: ' ||l_fte_actual_charges(1).allocation_method  );
            asn_debug.put_line('cost_component_class_id: ' || l_fte_actual_charges(1).cost_component_class_id );
            asn_debug.put_line('cost_analysis_code: ' || l_fte_actual_charges(1).cost_analysis_code );
            asn_debug.put_line('include_in_acquisition_cost: ' || l_fte_actual_charges(1).include_in_acquisition_cost );--Bug#6821589
        END IF;

        RCV_CHARGES_GRP.Allocate_charges(l_fte_actual_charges, l_fte_actual_charge_allocs, g_dummy_rci_tbl);

        -- Using charge table insetead of po_rcv_charge rowtype because GSCC doesn't
        -- like insert without column list unless for bulk insert
        FORALL i in 1..l_fte_actual_charges.COUNT
        INSERT INTO po_rcv_charges
        VALUES l_fte_actual_charges(i);

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Done bulk insert into po_rcv_charges');
        END IF;

        -- bulk insert po_rcv_charge_allocations from the charge table
        FORALL i IN 1..l_fte_actual_charge_allocs.COUNT
            INSERT INTO po_rcv_charge_allocations
            VALUES l_fte_actual_charge_allocs(i);

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Done bulk insert into po_rcv_charge_allocations');
        END IF;

    END IF;

    FND_MSG_PUB.Count_And_Get
       (
        p_count  => x_msg_count,
        p_data  =>  x_msg_data,
        p_encoded => FND_API.G_FALSE
       );

EXCEPTION
    WHEN l_invalid_shipment THEN
        x_msg_data := 'Invalid Shipment';
        x_return_status:= FND_API.G_RET_STS_ERROR;
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Invalid shipment.' );
        END IF;
    WHEN OTHERS THEN
        ROLLBACK TO PO_FTE_ACTUAL;
        x_msg_data := sqlerrm;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Unexpected error in Capture_FTE_Actual_Charges(), err_msg:'
                                || x_msg_data);
        END IF;
END Capture_FTE_Actual_Charges;


PROCEDURE Extract_AP_Actual_Charges
( errbuf               OUT NOCOPY VARCHAR2
, retcode              OUT NOCOPY VARCHAR2
)
IS
    l_charge_table        CHARGE_TABLE_TYPE;
    l_charge_alloc_table  CHARGE_ALLOCATION_TABLE_TYPE;
    k                     NUMBER;

BEGIN

    G_CONC_LOG := '';
    g_charge_numbers := 0;
    k := 1;

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Entering extract AP charges program.');
    END IF;


    FOR l_ap_po_charge_distribution in po_charges_grp.ap_po_charge_distributions_csr LOOP --{

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Inside the cursor loop.');
            asn_debug.put_line('Charge cursor has '||
			po_charges_grp.ap_po_charge_distributions_csr%rowcount||' rows.');
        END IF;

       /*Bug 17394705,we should exclude invoices of status not validated when extract AP invoice charges*/
        IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('Invoice status: '||l_ap_po_charge_distribution.invoice_status);
        END IF;
        IF l_ap_po_charge_distribution.invoice_status NOT IN ('UNAPPROVED','NEEDS REAPPROVAL','NEVER APPROVED') THEN
	Process_AP_Actual_Charges(l_ap_po_charge_distribution,l_charge_table,
					l_charge_alloc_table ,k);

	g_charge_numbers := g_charge_numbers + 1;
	      END IF;
    END LOOP; --}

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('After Loop ' || g_charge_numbers||
		' AP charges after l_ap_po_charge_distribution, '
		  ||l_charge_table.COUNT||' of them are new charges');
    END IF;


    FOR l_ap_rcv_charge_distribution in po_charges_grp.ap_rcv_charge_distr_csr LOOP --{

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Inside the cursor loop.');
            asn_debug.put_line('Charge cursor has '||
			po_charges_grp.ap_rcv_charge_distr_csr%rowcount||' rows.');
        END IF;

       /*Bug 17394705,we should exclude invoices of status not validated when extract AP invoice charges*/
        IF g_asn_debug = 'Y' THEN
            asn_debug.put_line('Invoice status: '||l_ap_rcv_charge_distribution.invoice_status);
        END IF;
        IF l_ap_rcv_charge_distribution.invoice_status NOT IN ('UNAPPROVED','NEEDS REAPPROVAL','NEVER APPROVED') THEN
	Process_AP_Actual_Charges(l_ap_rcv_charge_distribution,
				  l_charge_table,l_charge_alloc_table ,k);

	g_charge_numbers := g_charge_numbers + 1;
	      END IF;
    END LOOP; --}


    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('After Loop ' || g_charge_numbers||
		' AP charges after l_ap_rcv_charge_distribution, '
		  ||l_charge_table.COUNT||' of them are new charges');
    END IF;


    -- bulk insert po_rcv_charges from the charge table
    FORALL i IN 1..l_charge_table.COUNT
        INSERT INTO po_rcv_charges
        VALUES l_charge_table(i);

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Done bulk insert into po_rcv_charges');
    END IF;

    -- bulk insert po_rcv_charge_allocations from the charge table
    FORALL i IN 1..l_charge_alloc_table.COUNT
        INSERT INTO po_rcv_charge_allocations
        VALUES l_charge_alloc_table(i);

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Done bulk insert into po_rcv_charge_allocations');
    END IF;

    -- generate summary report
    G_CONC_LOG := G_CONC_LOG || 'Summary information: ' ||
		FND_GLOBAL.local_chr(10) ||
	 '    AP charge extracted:  ' || g_charge_numbers ||
	FND_GLOBAL.local_chr(10);

    -- send output to concurrent log
    errbuf := G_CONC_LOG;
    retcode := 0;

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('AP extracting completed');
    END IF;
EXCEPTION
    WHEN OTHERS THEN
        string( log_level => FND_LOG.LEVEL_UNEXPECTED
              , module => G_LOG_MODULE
              , message => 'Error in PO_CHARGES_GRP.Extract_AP_Actual_Charges: ' || SQLERRM
              );
        G_CONC_LOG := G_CONC_LOG || 'AP Charge Extraction failed'||  FND_GLOBAL.local_chr(10);
        errbuf := G_CONC_LOG;
        retcode := 2;
        CLOSE po_charges_grp.ap_po_charge_distributions_csr;
        CLOSE po_charges_grp.ap_rcv_charge_distr_csr;

END Extract_AP_Actual_Charges;

PROCEDURE Process_AP_Actual_Charges
(
        l_ap_charge_distribution IN OUT NOCOPY   po_charges_grp.ap_po_charge_distributions_csr%ROWTYPE,
        l_charge_table  IN OUT NOCOPY CHARGE_TABLE_TYPE,
        l_charge_alloc_table IN OUT NOCOPY  CHARGE_ALLOCATION_TABLE_TYPE,
        k  IN OUT NOCOPY number
)

IS

    l_charge_id po_rcv_charges.charge_id%TYPE;
    l_charge_allocation_id po_rcv_charge_allocations.charge_allocation_id%TYPE;
    l_cost_factor_details pon_price_element_types_vl%ROWTYPE;
    l_new_ap_charge VARCHAR2(1) := 'Y';

BEGIN

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Entering Process AP charges program.');
    END IF;

	select sum(amount)
	into l_ap_charge_distribution.rec_tax
	from ap_invoice_distributions_all where
	line_type_lookup_code = 'TAX' and
	charge_applicable_to_dist_id = l_ap_charge_distribution.invoice_distribution_id;

	select sum(amount)
	into l_ap_charge_distribution.nonrec_tax
	from ap_invoice_distributions_all where
	line_type_lookup_code = 'NONREC_TAX' and
	charge_applicable_to_dist_id = l_ap_charge_distribution.invoice_distribution_id;


    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('costfactor id '||l_ap_charge_distribution.cost_factor_id);
    END IF;

	If (l_ap_charge_distribution.cost_factor_id = 0 ) then
		l_cost_factor_details := pon_cf_type_grp.get_cost_factor_details( l_ap_charge_distribution.cost_factor_code );
	else
		l_cost_factor_details := pon_cf_type_grp.get_cost_factor_details( l_ap_charge_distribution.cost_factor_id );
	end if;

    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('price_element_type_id id '||l_cost_factor_details.price_element_type_id);
    END IF;

        SELECT decode(count(*), 0, 'Y', 'N')
          INTO l_new_ap_charge
          FROM po_rcv_charges
         WHERE cost_factor_id = l_cost_factor_details.price_element_type_id
           AND shipment_header_id = l_ap_charge_distribution.shipment_header_id
           AND (l_ap_charge_distribution.shipment_line_id IS NULL OR
                shipment_line_id = l_ap_charge_distribution.shipment_line_id) --Bug 17465835
           AND NVL(vendor_id, l_ap_charge_distribution.vendor_id)
                   = l_ap_charge_distribution.vendor_id
           AND NVL(vendor_site_id, l_ap_charge_distribution.vendor_site_id)
                   = l_ap_charge_distribution.vendor_site_id;

        IF (g_asn_debug = 'Y') THEN
            asn_debug.put_line('Is it a new AP charge? : ' || l_new_ap_charge);
        END IF;

        IF l_new_ap_charge = 'N' THEN --{

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Updating charge amount for existing charge');
            END IF;

            UPDATE po_rcv_charges
               SET actual_amount = nvl(actual_amount, 0) + l_ap_charge_distribution.amount
                 , actual_tax = nvl(actual_tax, 0) +
                      l_ap_charge_distribution.rec_tax + l_ap_charge_distribution.nonrec_tax
                 , vendor_id = NVL(vendor_id, l_ap_charge_distribution.vendor_id)
                 , vendor_site_id =  NVL(vendor_site_id, l_ap_charge_distribution.vendor_site_id)
             WHERE cost_factor_id = l_cost_factor_details.price_element_type_id
	     AND shipment_line_id = l_ap_charge_distribution.shipment_line_id
	             AND rownum = 1 --Bug 17465835
         RETURNING charge_id INTO l_charge_id;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Updated PRC (charge_id=' || l_charge_id || ') with amount'||l_ap_charge_distribution.amount);
            END IF;

            UPDATE po_rcv_charge_allocations
               SET actual_amount = nvl(actual_amount,0) + l_ap_charge_distribution.amount
                 , act_recoverable_tax = l_ap_charge_distribution.rec_tax
                 , act_non_recoverable_tax = l_ap_charge_distribution.nonrec_tax
             WHERE shipment_line_id = l_ap_charge_distribution.shipment_line_id
               AND charge_id = l_charge_id;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Updated corresponding PRCA with amount '||l_ap_charge_distribution.amount);
            END IF;
        ELSE --}{
            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Populating charge_table (' || k ||') for a new charge');
            END IF;

            SELECT po_rcv_charges_s.NEXTVAL
              INTO l_charge_table(k).charge_id
              FROM dual;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('charge_id: ' ||l_charge_table(k).charge_id);
            END IF;

            l_charge_table(k).creation_date := SYSDATE;
            l_charge_table(k).created_by := FND_GLOBAL.user_id;
            l_charge_table(k).last_update_date := SYSDATE;
            l_charge_table(k).last_updated_by := FND_GLOBAL.user_id;

            l_charge_table(k).shipment_header_id := l_ap_charge_distribution.shipment_header_id;
            l_charge_table(k).shipment_line_id := l_ap_charge_distribution.shipment_line_id;
            l_charge_table(k).actual_amount := l_ap_charge_distribution.amount;
            l_charge_table(k).currency_code := l_ap_charge_distribution.currency_code;
            l_charge_table(k).vendor_id := l_ap_charge_distribution.vendor_id;
            l_charge_table(k).vendor_site_id := l_ap_charge_distribution.vendor_site_id;

            l_charge_table(k).cost_factor_id := l_cost_factor_details.price_element_type_id;
            l_charge_table(k).allocation_method := l_cost_factor_details.allocation_basis;
            l_charge_table(k).cost_component_class_id := l_cost_factor_details.cost_component_class_id;
            l_charge_table(k).cost_analysis_code := l_cost_factor_details.cost_analysis_code;
            l_charge_table(k).include_in_acquisition_cost := l_cost_factor_details.cost_acquisition_code;--Bug#6821589

            l_charge_table(k).actual_tax :=
                l_ap_charge_distribution.rec_tax + l_ap_charge_distribution.nonrec_tax;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('shipment_header_id: ' || l_charge_table(k).shipment_header_id );
                asn_debug.put_line('shipment_line_id: ' || l_charge_table(k).shipment_line_id );
                asn_debug.put_line('estimated_amount: ' || l_charge_table(k).estimated_amount );
                asn_debug.put_line('currency_code: ' || l_charge_table(k).currency_code );
                asn_debug.put_line('vendor_id: ' || l_charge_table(k).vendor_id);
                asn_debug.put_line('vendor_site_id: ' || l_charge_table(k).vendor_site_id);
                asn_debug.put_line('cost_factor_id: ' || l_charge_table(k).cost_factor_id );
                asn_debug.put_line('allocation_method: ' ||l_charge_table(k).allocation_method  );
                asn_debug.put_line('cost_component_class_id: ' || l_charge_table(k).cost_component_class_id );
                asn_debug.put_line('cost_analysis_code: ' || l_charge_table(k).cost_analysis_code );
                asn_debug.put_line('include_in_acquisition_cost: ' || l_charge_table(k).include_in_acquisition_cost );--Bug#6821589
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Done populating charge_table (' || k || ')');
            END IF;

            SELECT po_rcv_charge_allocations_s.NEXTVAL
              INTO l_charge_alloc_table(k).charge_allocation_id
              FROM dual;

            l_charge_alloc_table(k).creation_date := SYSDATE;
            l_charge_alloc_table(k).created_by := FND_GLOBAL.user_id;
            l_charge_alloc_table(k).last_update_date := SYSDATE;
            l_charge_alloc_table(k).last_updated_by := FND_GLOBAL.user_id;

            l_charge_alloc_table(k).charge_id := l_charge_table(k).charge_id;
            l_charge_alloc_table(k).shipment_line_id := l_charge_table(k).shipment_line_id;
            l_charge_alloc_table(k).actual_amount := l_charge_table(k).actual_amount;

            l_charge_alloc_table(k).act_recoverable_tax := l_ap_charge_distribution.rec_tax;
            l_charge_alloc_table(k).act_non_recoverable_tax := l_ap_charge_distribution.nonrec_tax;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('charge_allocation_id: ' || l_charge_alloc_table(k).charge_allocation_id);
                asn_debug.put_line('act_recoverable_tax: ' || l_charge_alloc_table(k).act_recoverable_tax);
                asn_debug.put_line('act_non_recoverable_tax: ' || l_charge_alloc_table(k).act_non_recoverable_tax);
            END IF;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Done populating charge_alloc_table (' || k || ')');
            END IF;

            k := k + 1;

            IF (g_asn_debug = 'Y') THEN
                asn_debug.put_line('Created new charge and allocation record for new charge');
            END IF;

        END IF; --}

        -- update APs flag
        UPDATE ap_invoice_distributions_all
           SET rcv_charge_addition_flag = 'Y'
         WHERE invoice_distribution_id = l_ap_charge_distribution.invoice_distribution_id;


    IF (g_asn_debug = 'Y') THEN
        asn_debug.put_line('Exit Process AP extracting completed');
    END IF;

EXCEPTION
    WHEN OTHERS THEN
        string( log_level => FND_LOG.LEVEL_UNEXPECTED
              , module => G_LOG_MODULE
              , message => 'Error in PO_CHARGES_GRP.Process_AP_Actual_Charges: ' || SQLERRM
              );

END Process_AP_Actual_Charges;

END PO_CHARGES_GRP;


/
