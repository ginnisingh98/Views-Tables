--------------------------------------------------------
--  DDL for Package Body CST_PERENDACCRUALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CST_PERENDACCRUALS_PVT" AS
/* $Header: CSTVPEAB.pls 120.11.12010000.6 2010/01/29 01:31:13 jkwac ship $ */

-------------------------------------------------------------------------------
-- Period end accrual algorithm:
-------------------------------------------------------------------------------
-- For each eligible distribution, repeat steps 1 to 11
--  1. Shipment_qty              : quantity ordered - quantity cancelled
--  2. Shipment_net_qty_received : Net quantity received against the shipment
--  3. Shipment_net_qty_delivered: Net quantity delivered against all the
--                                 distributions for the shipment
--  4. Shipment_remaining_qty    : Net quantity to be delivered against all
--                                 the distributions in the shipment
--                               = p_shipment_qty - l_shipment_net_qty_delivered
--  5. Distribution_qty          : Quantity ordered - quantity cancelled
--  6. Dist_net_qty_delivered    : Net quantity delivered against the distribution
--  7. Dist_remaining_qty        : Net quantity to be delivered against the
--                                 distribution
--  8. Unit_price                : po_price + nr_tax
--
--  9. If (Match to PO)
--       a. qty_in_receiving     : Remaining quantity to deliver
--                = shipment_net_qty_received - shipment_net_qty_delivered
--       b. Prorate this remaining quantity (which has been received but not
--          been delivered) among the distribution
--            If distribution_remaining_qty  <= 0
--              allocated_qty = 0
--            Else
--                                                  dist_remaining_qty
--              allocated_qty = qty_in_receiving * ----------------------
--                                                  shipment_remaining_qty
--       c. Prorate the over receipt quantity based on quantity ordered
--       d. Quantity_received = dist_net_qty_delivered + allocated_qty
--                                                            + over_receipt
--       e. Quantity invoiced = Net qty invoiced against the Distribution
--       f. Accrual_amount
--            If qty_received <= quantity_invoiced
--              accrual_amount = 0
--            else
--              accrual_amount = (qty_received - quantity_invoiced) * unit_price
--
--  10. If (Match to Receipt)
--       For each RECEIVE or MATCH tarnsaction created against the Shipment,
--       repeat following :
--       a. Qty_received = Net quantity received against the receipt.
--       b. Qty_invoiced = Net quantity invoiced against the receipt *
--                                                  distribution_qty
--                                                 -------------------
--                                                    shipment_qty
--       c. Qty_delivered = Net quantity delivered against the distribution in
--                          the receive transaction.
--       d. Qty_in_receiving (Remaining quantity to deliver)
--                        = qty_received - qty_delivered
--       e. Prorate this remaining quantity (which has been received but not yet
--          delivered) among the distribution.
--            If distribution_remaining_qty  <= 0
--              allocated_qty = 0
--            Else
--                              distribution_remaining_qty
--              allocated_qty = --------------------------- * qty_in_receiving
--                               shipment_remaining_qty
--       f. Prorate the over receipt quantity based on quantity ordered
--       g. Quantity_received = dist_net_qty_delivered + allocated_qty
--                                                            + over_receipt
--       h. Accrual_amount
--            If qty_received <= quantity_invoiced
--               accrual_amount = 0
--            Else
--               accrual_amount = (qty_received - quantity_invoiced) * unit_price
--
--  11. Create accrual entries in CST_PER_END_ACCRUALS_TEMP
-------------------------------------------------------------------------------

G_PKG_NAME  CONSTANT VARCHAR2(30):='CST_PerEndAccruals_PVT';
G_LOG_LEVEL CONSTANT NUMBER  := FND_LOG.G_CURRENT_RUNTIME_LEVEL;



-----------------------------------------------------------------------------
-- PROCEDURE    :   Create_Per_End_Accruals
-- DESCRIPTION  :   Starting point for Period End Accrual program.
--                  The API creates period end accrual entries in the
--                  temporary table CST_PER_END_ACCRUALS_TEMP.
-----------------------------------------------------------------------------
PROCEDURE Create_PerEndAccruals
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_commit                        IN      VARCHAR2,
    p_validation_level              IN      NUMBER,
    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_min_accrual_amount            IN      NUMBER,
    p_vendor_id                     IN      NUMBER,
    p_vendor_from                   IN      VARCHAR2,
    p_vendor_to                     IN      VARCHAR2,
    p_category_id                   IN      NUMBER,
    p_category_from                 IN      VARCHAR2,
    p_category_to                   IN      VARCHAR2,
    p_end_date                      IN      DATE,
    p_accrued_receipt               IN      VARCHAR2,
    p_online_accruals               IN      VARCHAR2,
    p_closed_pos                    IN      VARCHAR2,
    p_calling_api                   IN      NUMBER
)

IS
    l_api_name    CONSTANT          VARCHAR2(30) :='Create_PerEndAccruals';
    l_api_version CONSTANT          NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    /* Log Severities*/
    /* 6- UNEXPECTED */
    /* 5- ERROR      */
    /* 4- EXCEPTION  */
    /* 3- EVENT      */
    /* 2- PROCEDURE  */
    /* 1- STATEMENT  */

    /* In general, we should use the following:
    G_LOG_LEVEL    CONSTANT NUMBER := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_errorLog     CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_ERROR >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_errorLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_eventLog     CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_EVENT >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_eventLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);
    */

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_accrual_rec                   CST_PER_END_ACCRUALS_TEMP%ROWTYPE;
    l_end_date                      DATE;
    l_stmt_num                      NUMBER;
    l_msg_data                      VARCHAR2(240);

    ------------------------------------------------------------------------
    -- Distribution Level Cursor
    --  The following conditions must be satisfied:
    --  1. Shipment must be on a STANDARD, BLANKET, or PLANNED PO header.
    --  2. If a vendor is specified, then the purchase order must be for
    --     that vendor.
    --  3. If an item category has been specified, then the PO line must be
    --     for that item category.
    --  4. The shipment type must not be of PREPAYMENT type
    --  5. Accrued flag should be Y or N depending upon the value of Accrued
    --     Receipt parameter.
    --  6. For Period End Accruals, the destination type for the distribution
    --     should be EXPENSE and should be either not closed or closed after
    --     the cut-off date.
    --  8. For online accruals, filter out the shipments where quantity_billed
    --     is equal to quantity_received. This will help in improving the
    --     performance of the process.
    --  9. If 'Include Closed POs' is yes, include all the closed POs. Else
    --     exclude the POs which are closed before the cut-oof date.
    --     This parameter is used by Uninvoiced Receipts Report.
    --  10.Must have a receipt against it with a transaction date less than
    --     the cutoff date.
    -------------------------------------------------------------------------
    CURSOR l_distribution_csr IS
        SELECT  /*+ LEADING (POLL) PUSH_SUBQ */
                pod.po_distribution_id              po_distribution_id,
                poll.line_location_id               line_location_id,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       0)                           service_flag,
                DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))
                                                    distribution_quantity,
                DECODE (poll.matching_basis,
                       'AMOUNT', pod.amount_ordered,
                        pod.quantity_ordered)       quantity_ordered,
                DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0))
                                                    shipment_quantity,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       NVL(poll.price_override, pol.unit_price))
                                                    po_price,
                NVL(poll.match_option,'P')          match_option,
                pol.category_id                     category_id,
                poh.currency_code                   currency_code,
                NVL(NVL(pod.rate,poh.rate),1)       currency_rate,
                poh.rate_type                       curr_conv_type,
                pod.rate_date                       currency_conv_date
        FROM    po_distributions pod,   -- Using single org view PO_DISTRIBUTIONS to support MOAC
                po_line_locations_all poll,
                po_lines_all pol,
                po_headers_all poh,
                po_vendors pov,
                mtl_categories_kfv mca,
                mtl_default_sets_view mds
        WHERE   pol.po_header_id = poh.po_header_id
        AND     poll.po_line_id = pol.po_line_id
        AND     pod.line_location_id = poll.line_location_id
        AND     poh.type_lookup_code IN ('STANDARD', 'BLANKET', 'PLANNED')
        AND     poh.vendor_id = pov.vendor_id
        AND     ((p_vendor_id IS NOT NULL AND pov.vendor_id = p_vendor_id)
                OR
                p_vendor_id IS NULL)
        AND     ((p_vendor_from IS NOT NULL AND pov.vendor_name >= p_vendor_from)
                OR
                p_vendor_from IS NULL)
        AND     ((p_vendor_to IS NOT NULL AND pov.vendor_name <= p_vendor_to)
                OR
                p_vendor_to IS NULL)
        AND     pol.category_id = mca.category_id
        AND     ((p_category_id IS NOT NULL AND mca.category_id = p_category_id)
                OR
                p_category_id IS NULL)
        AND     (p_category_from IS NULL
                OR
                (mca.concatenated_segments >= p_category_from AND p_category_from IS NOT NULL))
        AND     (p_category_to IS NULL
                OR
                (mca.concatenated_segments <= p_category_to AND p_category_to IS NOT NULL))
        AND     mds.structure_id = mca.structure_id
        AND     mds.functional_area_id = 2
        AND     poll.shipment_type <> 'PREPAYMENT'
        AND     (p_closed_pos = 'Y'
                OR
                (poll.closed_date IS NULL OR poll.closed_date > l_end_date))
        AND     ((NVL(poll.accrue_on_receipt_flag,'N') = 'N'
                AND pod.destination_type_code = 'EXPENSE'
                AND NVL(pod.accrued_flag, 'N') = NVL(p_accrued_receipt, 'N')
                )
                OR
                (p_online_accruals = 'Y'
                AND poll.accrue_on_receipt_flag = 'Y'
                AND DECODE(poll.matching_basis,
                           'AMOUNT', poll.amount_billed - poll.amount_received,
                           poll.quantity_billed - poll.quantity_received) <> 0
                ))
--{BUG#6366287: Only accrue if Ordered Quantity - Cancelled Quantity is > 0
        AND DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))  > 0
        AND DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0)) > 0
--}
        AND EXISTS
                (SELECT  /*+ PUSH_SUBQ NO_UNNEST */
                        'Get a receipt/match for this shipment'
                 FROM   rcv_transactions rvt
                 WHERE  rvt.po_line_location_id = poll.line_location_id
                 AND    rvt.transaction_type IN ('RECEIVE','MATCH')
                 AND    rvt.transaction_date <= l_end_date
                 )
		 ORDER by poll.line_location_id; /*Order by Clause added for bug 8675502*/


--{Specialization of the cursor
        --
        -- No vendor provided and no category provided
        --
        CURSOR c_no_vendor_no_category
        IS
        SELECT  /*+ LEADING (POLL) PUSH_SUBQ */
                        pod.po_distribution_id              po_distribution_id,
                poll.line_location_id               line_location_id,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       0)                           service_flag,
                DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))
                                                    distribution_quantity,
                DECODE (poll.matching_basis,
                       'AMOUNT', pod.amount_ordered,
                        pod.quantity_ordered)       quantity_ordered,
                DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0))
                                                    shipment_quantity,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       NVL(poll.price_override, pol.unit_price))
                                                    po_price,
                NVL(poll.match_option,'P')          match_option,
                pol.category_id                     category_id,
                poh.currency_code                   currency_code,
                NVL(NVL(pod.rate,poh.rate),1)       currency_rate,
                poh.rate_type                       curr_conv_type,
                pod.rate_date                       currency_conv_date
        FROM    po_distributions      pod   -- Using single org view PO_DISTRIBUTIONS to support MOAC
               ,po_line_locations_all poll
               ,po_lines_all          pol
               ,po_headers_all        poh
        WHERE   pol.po_header_id     = poh.po_header_id
        AND     poll.po_line_id      = pol.po_line_id
        AND     pod.line_location_id = poll.line_location_id
        AND     poh.type_lookup_code IN ('STANDARD', 'BLANKET', 'PLANNED')
        AND     poll.shipment_type <> 'PREPAYMENT'
        AND     (p_closed_pos = 'Y'
                OR
                (poll.closed_date IS NULL OR poll.closed_date > l_end_date))
        AND     ((NVL(poll.accrue_on_receipt_flag,'N') = 'N'
                AND pod.destination_type_code = 'EXPENSE'
                AND NVL(pod.accrued_flag, 'N') = NVL(p_accrued_receipt, 'N')
                )
                OR
                (p_online_accruals = 'Y'
                AND poll.accrue_on_receipt_flag = 'Y'
                AND DECODE(poll.matching_basis,
                           'AMOUNT', poll.amount_billed - poll.amount_received,
                           poll.quantity_billed - poll.quantity_received) <> 0
                ))
        AND DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))  > 0
        AND DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0)) > 0
        AND EXISTS
                (SELECT  /*+ PUSH_SUBQ NO_UNNEST */
                        'Get a receipt/match for this shipment'
                 FROM   rcv_transactions rvt
                 WHERE  rvt.po_line_location_id = poll.line_location_id
                 AND    rvt.transaction_type IN ('RECEIVE','MATCH')
                 AND    rvt.transaction_date <= l_end_date
                 )
	ORDER by poll.line_location_id; /*Order by Clause added for bug 8675502*/






        --
        -- Vendor ID provided and no category provided
        --
        CURSOR c_vendor_id_no_category
        IS
        SELECT  /*+ LEADING (POLL) PUSH_SUBQ */
                pod.po_distribution_id              po_distribution_id,
                poll.line_location_id               line_location_id,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       0)                           service_flag,
                DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))
                                                    distribution_quantity,
                DECODE (poll.matching_basis,
                       'AMOUNT', pod.amount_ordered,
                        pod.quantity_ordered)       quantity_ordered,
                DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0))
                                                    shipment_quantity,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       NVL(poll.price_override, pol.unit_price))
                                                    po_price,
                NVL(poll.match_option,'P')          match_option,
                pol.category_id                     category_id,
                poh.currency_code                   currency_code,
                NVL(NVL(pod.rate,poh.rate),1)       currency_rate,
                poh.rate_type                       curr_conv_type,
                pod.rate_date                       currency_conv_date
        FROM    po_distributions      pod   -- Using single org view PO_DISTRIBUTIONS to support MOAC
               ,po_line_locations_all poll
               ,po_lines_all          pol
               ,po_headers_all        poh
               ,po_vendors            pov
        WHERE   pol.po_header_id     = poh.po_header_id
        AND     poll.po_line_id      = pol.po_line_id
        AND     pod.line_location_id = poll.line_location_id
        AND     poh.type_lookup_code IN ('STANDARD', 'BLANKET', 'PLANNED')
        AND     poh.vendor_id        = pov.vendor_id
        AND     pov.vendor_id        = p_vendor_id
        AND     poll.shipment_type <> 'PREPAYMENT'
        AND     (p_closed_pos = 'Y'
                OR
                (poll.closed_date IS NULL OR poll.closed_date > l_end_date))
        AND     ((NVL(poll.accrue_on_receipt_flag,'N') = 'N'
                AND pod.destination_type_code = 'EXPENSE'
                AND NVL(pod.accrued_flag, 'N') = NVL(p_accrued_receipt, 'N')
                )
                OR
                (p_online_accruals = 'Y'
                AND poll.accrue_on_receipt_flag = 'Y'
                AND DECODE(poll.matching_basis,
                           'AMOUNT', poll.amount_billed - poll.amount_received,
                           poll.quantity_billed - poll.quantity_received) <> 0
                ))
        AND DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))  > 0
        AND DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0)) > 0
        AND EXISTS
                (SELECT  /*+ PUSH_SUBQ NO_UNNEST */
                        'Get a receipt/match for this shipment'
                 FROM   rcv_transactions rvt
                 WHERE  rvt.po_line_location_id = poll.line_location_id
                 AND    rvt.transaction_type IN ('RECEIVE','MATCH')
                 AND    rvt.transaction_date <= l_end_date
                 )
		 ORDER by poll.line_location_id; /*Order by Clause added for bug 8675502*/




        --
        -- Vendor range provided and no category provided
        --
        CURSOR c_vendor_range_no_category
        IS
        SELECT  /*+ LEADING (POLL) PUSH_SUBQ */
                pod.po_distribution_id              po_distribution_id,
                poll.line_location_id               line_location_id,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       0)                           service_flag,
                DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))
                                                    distribution_quantity,
                DECODE (poll.matching_basis,
                       'AMOUNT', pod.amount_ordered,
                        pod.quantity_ordered)       quantity_ordered,
                DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0))
                                                    shipment_quantity,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       NVL(poll.price_override, pol.unit_price))
                                                    po_price,
                NVL(poll.match_option,'P')          match_option,
                pol.category_id                     category_id,
                poh.currency_code                   currency_code,
                NVL(NVL(pod.rate,poh.rate),1)       currency_rate,
                poh.rate_type                       curr_conv_type,
                pod.rate_date                       currency_conv_date
        FROM    po_distributions      pod   -- Using single org view PO_DISTRIBUTIONS to support MOAC
               ,po_line_locations_all poll
               ,po_lines_all          pol
               ,po_headers_all        poh
               ,po_vendors            pov
        WHERE   pol.po_header_id     = poh.po_header_id
        AND     poll.po_line_id      = pol.po_line_id
        AND     pod.line_location_id = poll.line_location_id
        AND     poh.type_lookup_code IN ('STANDARD', 'BLANKET', 'PLANNED')
        AND     poh.vendor_id        = pov.vendor_id
        AND     ((p_vendor_from IS NOT NULL AND pov.vendor_name >= p_vendor_from)
                OR
                p_vendor_from IS NULL)
        AND     ((p_vendor_to IS NOT NULL AND pov.vendor_name <= p_vendor_to)
                OR
                p_vendor_to IS NULL)
        AND     poll.shipment_type <> 'PREPAYMENT'
        AND     (p_closed_pos = 'Y'
                OR
                (poll.closed_date IS NULL OR poll.closed_date > l_end_date))
        AND     ((NVL(poll.accrue_on_receipt_flag,'N') = 'N'
                AND pod.destination_type_code = 'EXPENSE'
                AND NVL(pod.accrued_flag, 'N') = NVL(p_accrued_receipt, 'N')
                )
                OR
                (p_online_accruals = 'Y'
                AND poll.accrue_on_receipt_flag = 'Y'
                AND DECODE(poll.matching_basis,
                           'AMOUNT', poll.amount_billed - poll.amount_received,
                           poll.quantity_billed - poll.quantity_received) <> 0
                ))
        AND DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))  > 0
        AND DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0)) > 0
        AND EXISTS
                (SELECT  /*+ PUSH_SUBQ NO_UNNEST */
                        'Get a receipt/match for this shipment'
                 FROM   rcv_transactions rvt
                 WHERE  rvt.po_line_location_id = poll.line_location_id
                 AND    rvt.transaction_type IN ('RECEIVE','MATCH')
                 AND    rvt.transaction_date <= l_end_date
                 )
		 ORDER by poll.line_location_id; /*Order by Clause added for bug 8675502*/



        --
        -- No Vendor provided and category ID provided
        --
        CURSOR c_no_vendor_category_id
        IS
        SELECT  /*+ LEADING (POLL) PUSH_SUBQ */
                pod.po_distribution_id              po_distribution_id,
                poll.line_location_id               line_location_id,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       0)                           service_flag,
                DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))
                                                    distribution_quantity,
                DECODE (poll.matching_basis,
                       'AMOUNT', pod.amount_ordered,
                        pod.quantity_ordered)       quantity_ordered,
                DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0))
                                                    shipment_quantity,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       NVL(poll.price_override, pol.unit_price))
                                                    po_price,
                NVL(poll.match_option,'P')          match_option,
                pol.category_id                     category_id,
                poh.currency_code                   currency_code,
                NVL(NVL(pod.rate,poh.rate),1)       currency_rate,
                poh.rate_type                       curr_conv_type,
                pod.rate_date                       currency_conv_date
        FROM    po_distributions      pod   -- Using single org view PO_DISTRIBUTIONS to support MOAC
               ,po_line_locations_all poll
               ,po_lines_all          pol
               ,po_headers_all        poh
               ,mtl_categories_kfv    mca
               ,mtl_default_sets_view mds
        WHERE   pol.po_header_id     = poh.po_header_id
        AND     poll.po_line_id      = pol.po_line_id
        AND     pod.line_location_id = poll.line_location_id
        AND     poh.type_lookup_code IN ('STANDARD', 'BLANKET', 'PLANNED')
        AND     pol.category_id      = mca.category_id
        AND     mca.category_id      = p_category_id
        AND     mds.structure_id     = mca.structure_id
        AND     mds.functional_area_id = 2
        AND     poll.shipment_type   <> 'PREPAYMENT'
        AND     (p_closed_pos = 'Y'
                OR
                (poll.closed_date IS NULL OR poll.closed_date > l_end_date))
        AND     ((NVL(poll.accrue_on_receipt_flag,'N') = 'N'
                AND pod.destination_type_code = 'EXPENSE'
                AND NVL(pod.accrued_flag, 'N') = NVL(p_accrued_receipt, 'N')
                )
                OR
                (p_online_accruals = 'Y'
                AND poll.accrue_on_receipt_flag = 'Y'
                AND DECODE(poll.matching_basis,
                           'AMOUNT', poll.amount_billed - poll.amount_received,
                           poll.quantity_billed - poll.quantity_received) <> 0
                ))
        AND DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))  > 0
        AND DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0)) > 0
        AND EXISTS
                (SELECT  /*+ PUSH_SUBQ NO_UNNEST */
                        'Get a receipt/match for this shipment'
                 FROM   rcv_transactions rvt
                 WHERE  rvt.po_line_location_id = poll.line_location_id
                 AND    rvt.transaction_type IN ('RECEIVE','MATCH')
                 AND    rvt.transaction_date <= l_end_date
                 )
		 ORDER by poll.line_location_id; /*Order by Clause added for bug 8675502*/




        --
        -- No Vendor provided and category range provided
        --
        CURSOR c_no_vendor_category_range
        IS
        SELECT  /*+ LEADING (POLL) PUSH_SUBQ */
                pod.po_distribution_id              po_distribution_id,
                poll.line_location_id               line_location_id,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       0)                           service_flag,
                DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))
                                                    distribution_quantity,
                DECODE (poll.matching_basis,
                       'AMOUNT', pod.amount_ordered,
                        pod.quantity_ordered)       quantity_ordered,
                DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0))
                                                    shipment_quantity,
                DECODE(poll.matching_basis,
                       'AMOUNT',  1,
                       NVL(poll.price_override, pol.unit_price))
                                                    po_price,
                NVL(poll.match_option,'P')          match_option,
                pol.category_id                     category_id,
                poh.currency_code                   currency_code,
                NVL(NVL(pod.rate,poh.rate),1)       currency_rate,
                poh.rate_type                       curr_conv_type,
                pod.rate_date                       currency_conv_date
        FROM    po_distributions      pod   -- Using single org view PO_DISTRIBUTIONS to support MOAC
               ,po_line_locations_all poll
               ,po_lines_all          pol
               ,po_headers_all        poh
               ,mtl_categories_kfv    mca
               ,mtl_default_sets_view mds
        WHERE   pol.po_header_id     = poh.po_header_id
        AND     poll.po_line_id      = pol.po_line_id
        AND     pod.line_location_id = poll.line_location_id
        AND     poh.type_lookup_code IN ('STANDARD', 'BLANKET', 'PLANNED')
        AND     pol.category_id      = mca.category_id
        AND     (p_category_from IS NULL
                OR
                (mca.concatenated_segments >= p_category_from AND p_category_from IS NOT NULL))
        AND     (p_category_to IS NULL
                OR
                (mca.concatenated_segments <= p_category_to AND p_category_to IS NOT NULL))
        AND     mds.structure_id = mca.structure_id
        AND     mds.functional_area_id = 2
        AND     poll.shipment_type <> 'PREPAYMENT'
        AND     (p_closed_pos = 'Y'
                OR
                (poll.closed_date IS NULL OR poll.closed_date > l_end_date))
        AND     ((NVL(poll.accrue_on_receipt_flag,'N') = 'N'
                AND pod.destination_type_code = 'EXPENSE'
                AND NVL(pod.accrued_flag, 'N') = NVL(p_accrued_receipt, 'N')
                )
                OR
                (p_online_accruals = 'Y'
                AND poll.accrue_on_receipt_flag = 'Y'
                AND DECODE(poll.matching_basis,
                           'AMOUNT', poll.amount_billed - poll.amount_received,
                           poll.quantity_billed - poll.quantity_received) <> 0
                ))
        AND DECODE (poll.matching_basis,
                       'AMOUNT',  pod.amount_ordered - NVL(pod.amount_cancelled, 0),
                        pod.quantity_ordered - NVL(pod.quantity_cancelled, 0))  > 0
        AND DECODE(poll.matching_basis,
                       'AMOUNT',  poll.amount - NVL(poll.amount_cancelled, 0),
                       poll.quantity - NVL(poll.quantity_cancelled,0)) > 0
        AND EXISTS
                (SELECT  /*+ PUSH_SUBQ NO_UNNEST */
                        'Get a receipt/match for this shipment'
                 FROM   rcv_transactions rvt
                 WHERE  rvt.po_line_location_id = poll.line_location_id
                 AND    rvt.transaction_type IN ('RECEIVE','MATCH')
                 AND    rvt.transaction_date <= l_end_date
                 )
		 ORDER by poll.line_location_id ; /* Order by Clause added for bug 8675502*/












    -------------------------------------------------------------------------
    -- PL/SQL tables of accrual info to be inserted in
    -- CST_PER_END_ACCRUALS_TEMP table
    -------------------------------------------------------------------------
    l_acr_dist_id_tbl               ACR_DIST_ID_TBL_TYPE;
    l_acr_shipment_id_tbl           ACR_SHIPMENT_ID_TBL_TYPE;
    l_acr_category_id_tbl           ACR_CATEGORY_ID_TBL_TYPE;
    l_acr_match_option_tbl          ACR_MATCH_OPTION_TBL_TYPE;
    l_acr_qty_received_tbl          ACR_QTY_RECEIVED_TBL_TYPE;
    l_acr_qty_billed_tbl            ACR_QTY_BILLED_TBL_TYPE;
    l_acr_accrual_qty_tbl           ACR_ACCRUAL_QTY_TBL_TYPE;
    l_acr_encum_qty_tbl             ACR_ENCUM_QTY_TBL_TYPE;
    l_acr_unit_price_tbl            ACR_UNIT_PRICE_TBL_TYPE;
    l_acr_accrual_amount_tbl        ACR_ACCRUAL_AMOUNT_TBL_TYPE;
    l_acr_encum_amount_tbl          ACR_ENCUM_AMOUNT_TBL_TYPE;
    l_acr_cur_code_tbl              ACR_CUR_CODE_TBL_TYPE;
    l_acr_cur_conv_type_tbl         ACR_CUR_CONV_TYPE_TBL_TYPE;
    l_acr_cur_conv_rate_tbl         ACR_CUR_CONV_RATE_TBL_TYPE;
    l_acr_cur_conv_date_tbl         ACR_CUR_CONV_DATE_TBL_TYPE;
    l_ctr                           NUMBER;
    l_use                           VARCHAR2(30);
BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT   Create_PerEndAccruals_PVT;

    l_stmt_num := 0;

    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,'Create_PerEndAccruals << ');
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,' p_min_accrual_amount = '|| p_min_accrual_amount);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,' p_vendor_id          = '|| p_vendor_id);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,' p_vendor_to          = '|| p_vendor_to);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,' p_category_id        = '|| p_category_id);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,' p_category_from      = '|| p_category_from);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,' p_category_to        = '|| p_category_to);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,' p_end_date           = '|| p_end_date);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,' p_accrued_receipt    = '|| p_accrued_receipt);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,' p_online_accruals    = '|| p_online_accruals);
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,' p_calling_api        = '|| p_calling_api);
    END IF;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Initialize the period end date
    l_end_date := p_end_date + 0.99999;

    -- Loop for each distribution
    l_stmt_num := 50;

 --
 --{Specialization BUG#7296737
 --
   IF (l_pLog) THEN
      FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,'Determining the cursor');
   END IF;

   IF (p_vendor_id      IS NULL AND
       p_vendor_from    IS NULL AND
       p_vendor_to      IS NULL AND
       p_category_id    IS NULL AND
       p_category_from  IS NULL AND
       p_category_to    IS NULL)
   THEN
      l_use := 'c_no_vendor_no_category';

   ELSIF (  (p_vendor_id      IS NOT NULL OR
             p_vendor_from    IS NOT NULL OR
             p_vendor_to      IS NOT NULL   )  AND
             p_category_id    IS NULL AND
             p_category_from  IS NULL AND
             p_category_to    IS NULL)
   THEN
        IF p_vendor_id IS NOT NULL THEN
          l_use := 'c_vendor_id_no_category';
        ELSE
          l_use := 'c_vendor_range_no_category';
        END IF;

   ELSIF  (  p_vendor_id      IS NULL AND
             p_vendor_from    IS NULL AND
             p_vendor_to      IS NULL AND
           ( p_category_id    IS NOT NULL OR
             p_category_from  IS NOT NULL OR
             p_category_to    IS NOT NULL))
   THEN
       IF p_category_id    IS NOT NULL THEN
         l_use := 'c_no_vendor_category_id';
       ELSE
         l_use := 'c_no_vendor_category_range';
       END IF;

   ELSE
     -- General case
     l_use := 'l_distribution_csr';
   END IF;

   IF (l_pLog) THEN
     FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,'l_use :'||l_use);
   END IF;

   IF l_use = 'c_no_vendor_no_category' THEN

      FOR l_distribution_rec IN c_no_vendor_no_category LOOP
        l_accrual_rec.shipment_id               := l_distribution_rec.line_location_id;
        l_accrual_rec.distribution_id           := l_distribution_rec.po_distribution_id;
        l_accrual_rec.category_id               := l_distribution_rec.category_id;
        l_accrual_rec.match_option              := l_distribution_rec.match_option;
        l_accrual_rec.currency_code             := l_distribution_rec.currency_code;
        l_accrual_rec.currency_conversion_type  := l_distribution_rec.curr_conv_type;
        l_accrual_rec.currency_conversion_rate  := l_distribution_rec.currency_rate;
        l_accrual_rec.currency_conversion_date  := l_distribution_rec.currency_conv_date;

        l_stmt_num := 110;
        l_accrual_rec.unit_price := l_distribution_rec.po_price
                                    + po_tax_sv.get_tax( 'PO', l_distribution_rec.po_distribution_id)
                                                                / l_distribution_rec.quantity_ordered;
        l_stmt_num := 120;
        Calculate_AccrualAmount(
            p_api_version               => 1.0,
            p_init_msg_list             => FND_API.G_FALSE,
            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
            x_return_status             => l_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data,
            p_service_flag              => l_distribution_rec.service_flag,
            p_dist_qty                  => l_distribution_rec.distribution_quantity,
            p_shipment_qty              => l_distribution_rec.shipment_quantity,
            p_end_date                  => l_end_date,
            x_accrual_rec               => l_accrual_rec
            );
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Error Occured while calculating acrual amount against the Shipment id :' ||
                          TO_CHAR(l_distribution_rec.line_location_id) ||
                          ' ,Distribution Id :' || TO_CHAR(l_distribution_rec.po_distribution_id);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_stmt_num := 130;
        IF ((l_accrual_rec.quantity_received > l_accrual_rec.quantity_billed)
           OR
           (l_accrual_rec.quantity_received < l_accrual_rec.quantity_billed AND
           p_calling_api = G_UNINVOICED_RECEIPT_REPORT))
        THEN
            -- Get the position of the new row to be added
            l_ctr := l_acr_dist_id_tbl.COUNT + 1;

            l_acr_dist_id_tbl(l_ctr)       := l_accrual_rec.distribution_id;
            l_acr_shipment_id_tbl(l_ctr)   := l_accrual_rec.shipment_id;
            l_acr_category_id_tbl(l_ctr)   := l_accrual_rec.category_id;
            l_acr_match_option_tbl(l_ctr)  := l_accrual_rec.match_option;
            l_acr_qty_received_tbl(l_ctr)  := l_accrual_rec.quantity_received;
            l_acr_qty_billed_tbl(l_ctr)    := l_accrual_rec.quantity_billed;
            l_acr_accrual_qty_tbl(l_ctr)   := l_accrual_rec.accrual_quantity;
            l_acr_encum_qty_tbl(l_ctr)     := l_accrual_rec.encum_quantity;
            l_acr_unit_price_tbl(l_ctr)    := l_accrual_rec.unit_price;
            l_acr_accrual_amount_tbl(l_ctr):= l_accrual_rec.accrual_amount;
            l_acr_encum_amount_tbl(l_ctr)  := l_accrual_rec.encum_amount;
            l_acr_cur_code_tbl(l_ctr)      := l_accrual_rec.currency_code;
            l_acr_cur_conv_type_tbl(l_ctr) := l_accrual_rec.currency_conversion_type;
            l_acr_cur_conv_rate_tbl(l_ctr) := l_accrual_rec.currency_conversion_rate;
            l_acr_cur_conv_date_tbl(l_ctr) := l_accrual_rec.currency_conversion_date;

        END IF;

        IF (p_calling_api = G_RECEIPT_ACCRUAL_PER_END) THEN
            CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl(CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl.COUNT + 1)
                                                    := l_distribution_rec.po_distribution_id;
        END IF;

     END LOOP;  --end of c_no_vendor_no_category loop


   ELSIF l_use = 'c_vendor_id_no_category' THEN

    FOR l_distribution_rec IN c_vendor_id_no_category LOOP

        l_accrual_rec.shipment_id               := l_distribution_rec.line_location_id;
        l_accrual_rec.distribution_id           := l_distribution_rec.po_distribution_id;
        l_accrual_rec.category_id               := l_distribution_rec.category_id;
        l_accrual_rec.match_option              := l_distribution_rec.match_option;
        l_accrual_rec.currency_code             := l_distribution_rec.currency_code;
        l_accrual_rec.currency_conversion_type  := l_distribution_rec.curr_conv_type;
        l_accrual_rec.currency_conversion_rate  := l_distribution_rec.currency_rate;
        l_accrual_rec.currency_conversion_date  := l_distribution_rec.currency_conv_date;

        l_stmt_num := 110;
        l_accrual_rec.unit_price := l_distribution_rec.po_price
                                    + po_tax_sv.get_tax( 'PO', l_distribution_rec.po_distribution_id)
                                                                / l_distribution_rec.quantity_ordered;

        l_stmt_num := 120;
        Calculate_AccrualAmount(
            p_api_version               => 1.0,
            p_init_msg_list             => FND_API.G_FALSE,
            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
            x_return_status             => l_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data,
            p_service_flag              => l_distribution_rec.service_flag,
            p_dist_qty                  => l_distribution_rec.distribution_quantity,
            p_shipment_qty              => l_distribution_rec.shipment_quantity,
            p_end_date                  => l_end_date,
            x_accrual_rec               => l_accrual_rec
            );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Error Occured while calculating acrual amount against the Shipment id :' ||
                          TO_CHAR(l_distribution_rec.line_location_id) ||
                          ' ,Distribution Id :' || TO_CHAR(l_distribution_rec.po_distribution_id);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_stmt_num := 130;
        IF ((l_accrual_rec.quantity_received > l_accrual_rec.quantity_billed)
           OR
           (l_accrual_rec.quantity_received < l_accrual_rec.quantity_billed AND
           p_calling_api = G_UNINVOICED_RECEIPT_REPORT))
        THEN

            -- Get the position of the new row to be added
            l_ctr := l_acr_dist_id_tbl.COUNT + 1;

            l_acr_dist_id_tbl(l_ctr)       := l_accrual_rec.distribution_id;
            l_acr_shipment_id_tbl(l_ctr)   := l_accrual_rec.shipment_id;
            l_acr_category_id_tbl(l_ctr)   := l_accrual_rec.category_id;
            l_acr_match_option_tbl(l_ctr)  := l_accrual_rec.match_option;
            l_acr_qty_received_tbl(l_ctr)  := l_accrual_rec.quantity_received;
            l_acr_qty_billed_tbl(l_ctr)    := l_accrual_rec.quantity_billed;
            l_acr_accrual_qty_tbl(l_ctr)   := l_accrual_rec.accrual_quantity;
            l_acr_encum_qty_tbl(l_ctr)     := l_accrual_rec.encum_quantity;
            l_acr_unit_price_tbl(l_ctr)    := l_accrual_rec.unit_price;
            l_acr_accrual_amount_tbl(l_ctr):= l_accrual_rec.accrual_amount;
            l_acr_encum_amount_tbl(l_ctr)  := l_accrual_rec.encum_amount;
            l_acr_cur_code_tbl(l_ctr)      := l_accrual_rec.currency_code;
            l_acr_cur_conv_type_tbl(l_ctr) := l_accrual_rec.currency_conversion_type;
            l_acr_cur_conv_rate_tbl(l_ctr) := l_accrual_rec.currency_conversion_rate;
            l_acr_cur_conv_date_tbl(l_ctr) := l_accrual_rec.currency_conversion_date;

        END IF;

        IF (p_calling_api = G_RECEIPT_ACCRUAL_PER_END) THEN
            CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl(CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl.COUNT + 1)
                                                    := l_distribution_rec.po_distribution_id;
        END IF;

    END LOOP;  --end of c_vendor_id_no_category loop

  ELSIF l_use = 'c_vendor_range_no_category' THEN

    FOR l_distribution_rec IN c_vendor_range_no_category LOOP

        l_accrual_rec.shipment_id               := l_distribution_rec.line_location_id;
        l_accrual_rec.distribution_id           := l_distribution_rec.po_distribution_id;
        l_accrual_rec.category_id               := l_distribution_rec.category_id;
        l_accrual_rec.match_option              := l_distribution_rec.match_option;
        l_accrual_rec.currency_code             := l_distribution_rec.currency_code;
        l_accrual_rec.currency_conversion_type  := l_distribution_rec.curr_conv_type;
        l_accrual_rec.currency_conversion_rate  := l_distribution_rec.currency_rate;
        l_accrual_rec.currency_conversion_date  := l_distribution_rec.currency_conv_date;

        l_stmt_num := 110;
        l_accrual_rec.unit_price := l_distribution_rec.po_price
                                    + po_tax_sv.get_tax( 'PO', l_distribution_rec.po_distribution_id)
                                                                / l_distribution_rec.quantity_ordered;

        l_stmt_num := 120;
        Calculate_AccrualAmount(
            p_api_version               => 1.0,
            p_init_msg_list             => FND_API.G_FALSE,
            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
            x_return_status             => l_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data,
            p_service_flag              => l_distribution_rec.service_flag,
            p_dist_qty                  => l_distribution_rec.distribution_quantity,
            p_shipment_qty              => l_distribution_rec.shipment_quantity,
            p_end_date                  => l_end_date,
            x_accrual_rec               => l_accrual_rec
            );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Error Occured while calculating acrual amount against the Shipment id :' ||
                          TO_CHAR(l_distribution_rec.line_location_id) ||
                          ' ,Distribution Id :' || TO_CHAR(l_distribution_rec.po_distribution_id);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_stmt_num := 130;
        IF ((l_accrual_rec.quantity_received > l_accrual_rec.quantity_billed)
           OR
           (l_accrual_rec.quantity_received < l_accrual_rec.quantity_billed AND
           p_calling_api = G_UNINVOICED_RECEIPT_REPORT))
        THEN
            l_ctr := l_acr_dist_id_tbl.COUNT + 1;

            l_acr_dist_id_tbl(l_ctr)       := l_accrual_rec.distribution_id;
            l_acr_shipment_id_tbl(l_ctr)   := l_accrual_rec.shipment_id;
            l_acr_category_id_tbl(l_ctr)   := l_accrual_rec.category_id;
            l_acr_match_option_tbl(l_ctr)  := l_accrual_rec.match_option;
            l_acr_qty_received_tbl(l_ctr)  := l_accrual_rec.quantity_received;
            l_acr_qty_billed_tbl(l_ctr)    := l_accrual_rec.quantity_billed;
            l_acr_accrual_qty_tbl(l_ctr)   := l_accrual_rec.accrual_quantity;
            l_acr_encum_qty_tbl(l_ctr)     := l_accrual_rec.encum_quantity;
            l_acr_unit_price_tbl(l_ctr)    := l_accrual_rec.unit_price;
            l_acr_accrual_amount_tbl(l_ctr):= l_accrual_rec.accrual_amount;
            l_acr_encum_amount_tbl(l_ctr)  := l_accrual_rec.encum_amount;
            l_acr_cur_code_tbl(l_ctr)      := l_accrual_rec.currency_code;
            l_acr_cur_conv_type_tbl(l_ctr) := l_accrual_rec.currency_conversion_type;
            l_acr_cur_conv_rate_tbl(l_ctr) := l_accrual_rec.currency_conversion_rate;
            l_acr_cur_conv_date_tbl(l_ctr) := l_accrual_rec.currency_conversion_date;

        END IF;

        IF (p_calling_api = G_RECEIPT_ACCRUAL_PER_END) THEN
            CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl(CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl.COUNT + 1)
                                                    := l_distribution_rec.po_distribution_id;
        END IF;

    END LOOP;  --end of c_vendor_range_no_category loop

   ELSIF l_use = 'c_no_vendor_category_range' THEN

    FOR l_distribution_rec IN c_no_vendor_category_range LOOP

        l_accrual_rec.shipment_id               := l_distribution_rec.line_location_id;
        l_accrual_rec.distribution_id           := l_distribution_rec.po_distribution_id;
        l_accrual_rec.category_id               := l_distribution_rec.category_id;
        l_accrual_rec.match_option              := l_distribution_rec.match_option;
        l_accrual_rec.currency_code             := l_distribution_rec.currency_code;
        l_accrual_rec.currency_conversion_type  := l_distribution_rec.curr_conv_type;
        l_accrual_rec.currency_conversion_rate  := l_distribution_rec.currency_rate;
        l_accrual_rec.currency_conversion_date  := l_distribution_rec.currency_conv_date;

        l_stmt_num := 110;
        l_accrual_rec.unit_price := l_distribution_rec.po_price
                                    + po_tax_sv.get_tax( 'PO', l_distribution_rec.po_distribution_id)
                                                                / l_distribution_rec.quantity_ordered;
        l_stmt_num := 120;
        Calculate_AccrualAmount(
            p_api_version               => 1.0,
            p_init_msg_list             => FND_API.G_FALSE,
            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
            x_return_status             => l_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data,
            p_service_flag              => l_distribution_rec.service_flag,
            p_dist_qty                  => l_distribution_rec.distribution_quantity,
            p_shipment_qty              => l_distribution_rec.shipment_quantity,
            p_end_date                  => l_end_date,
            x_accrual_rec               => l_accrual_rec
            );

        -- If return status is not success, raise unexpected exception
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Error Occured while calculating acrual amount against the Shipment id :' ||
                          TO_CHAR(l_distribution_rec.line_location_id) ||
                          ' ,Distribution Id :' || TO_CHAR(l_distribution_rec.po_distribution_id);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_stmt_num := 130;
        IF ((l_accrual_rec.quantity_received > l_accrual_rec.quantity_billed)
           OR
           (l_accrual_rec.quantity_received < l_accrual_rec.quantity_billed AND
           p_calling_api = G_UNINVOICED_RECEIPT_REPORT))
        THEN
            l_ctr := l_acr_dist_id_tbl.COUNT + 1;

            l_acr_dist_id_tbl(l_ctr)       := l_accrual_rec.distribution_id;
            l_acr_shipment_id_tbl(l_ctr)   := l_accrual_rec.shipment_id;
            l_acr_category_id_tbl(l_ctr)   := l_accrual_rec.category_id;
            l_acr_match_option_tbl(l_ctr)  := l_accrual_rec.match_option;
            l_acr_qty_received_tbl(l_ctr)  := l_accrual_rec.quantity_received;
            l_acr_qty_billed_tbl(l_ctr)    := l_accrual_rec.quantity_billed;
            l_acr_accrual_qty_tbl(l_ctr)   := l_accrual_rec.accrual_quantity;
            l_acr_encum_qty_tbl(l_ctr)     := l_accrual_rec.encum_quantity;
            l_acr_unit_price_tbl(l_ctr)    := l_accrual_rec.unit_price;
            l_acr_accrual_amount_tbl(l_ctr):= l_accrual_rec.accrual_amount;
            l_acr_encum_amount_tbl(l_ctr)  := l_accrual_rec.encum_amount;
            l_acr_cur_code_tbl(l_ctr)      := l_accrual_rec.currency_code;
            l_acr_cur_conv_type_tbl(l_ctr) := l_accrual_rec.currency_conversion_type;
            l_acr_cur_conv_rate_tbl(l_ctr) := l_accrual_rec.currency_conversion_rate;
            l_acr_cur_conv_date_tbl(l_ctr) := l_accrual_rec.currency_conversion_date;

        END IF;

        IF (p_calling_api = G_RECEIPT_ACCRUAL_PER_END) THEN
            CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl(CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl.COUNT + 1)
                                                    := l_distribution_rec.po_distribution_id;
        END IF;

    END LOOP;  --end of c_no_vendor_category_range loop

  ELSIF l_use = 'c_no_vendor_category_id' THEN

     FOR l_distribution_rec IN c_no_vendor_category_id LOOP

        l_accrual_rec.shipment_id               := l_distribution_rec.line_location_id;
        l_accrual_rec.distribution_id           := l_distribution_rec.po_distribution_id;
        l_accrual_rec.category_id               := l_distribution_rec.category_id;
        l_accrual_rec.match_option              := l_distribution_rec.match_option;
        l_accrual_rec.currency_code             := l_distribution_rec.currency_code;
        l_accrual_rec.currency_conversion_type  := l_distribution_rec.curr_conv_type;
        l_accrual_rec.currency_conversion_rate  := l_distribution_rec.currency_rate;
        l_accrual_rec.currency_conversion_date  := l_distribution_rec.currency_conv_date;

        l_stmt_num := 110;
        l_accrual_rec.unit_price := l_distribution_rec.po_price
                                    + po_tax_sv.get_tax( 'PO', l_distribution_rec.po_distribution_id)
                                                                / l_distribution_rec.quantity_ordered;
        l_stmt_num := 120;
        Calculate_AccrualAmount(
            p_api_version               => 1.0,
            p_init_msg_list             => FND_API.G_FALSE,
            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
            x_return_status             => l_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data,
            p_service_flag              => l_distribution_rec.service_flag,
            p_dist_qty                  => l_distribution_rec.distribution_quantity,
            p_shipment_qty              => l_distribution_rec.shipment_quantity,
            p_end_date                  => l_end_date,
            x_accrual_rec               => l_accrual_rec
            );

        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Error Occured while calculating acrual amount against the Shipment id :' ||
                          TO_CHAR(l_distribution_rec.line_location_id) ||
                          ' ,Distribution Id :' || TO_CHAR(l_distribution_rec.po_distribution_id);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        l_stmt_num := 130;
        IF ((l_accrual_rec.quantity_received > l_accrual_rec.quantity_billed)
           OR
           (l_accrual_rec.quantity_received < l_accrual_rec.quantity_billed AND
           p_calling_api = G_UNINVOICED_RECEIPT_REPORT))
        THEN
            l_ctr := l_acr_dist_id_tbl.COUNT + 1;

            l_acr_dist_id_tbl(l_ctr)       := l_accrual_rec.distribution_id;
            l_acr_shipment_id_tbl(l_ctr)   := l_accrual_rec.shipment_id;
            l_acr_category_id_tbl(l_ctr)   := l_accrual_rec.category_id;
            l_acr_match_option_tbl(l_ctr)  := l_accrual_rec.match_option;
            l_acr_qty_received_tbl(l_ctr)  := l_accrual_rec.quantity_received;
            l_acr_qty_billed_tbl(l_ctr)    := l_accrual_rec.quantity_billed;
            l_acr_accrual_qty_tbl(l_ctr)   := l_accrual_rec.accrual_quantity;
            l_acr_encum_qty_tbl(l_ctr)     := l_accrual_rec.encum_quantity;
            l_acr_unit_price_tbl(l_ctr)    := l_accrual_rec.unit_price;
            l_acr_accrual_amount_tbl(l_ctr):= l_accrual_rec.accrual_amount;
            l_acr_encum_amount_tbl(l_ctr)  := l_accrual_rec.encum_amount;
            l_acr_cur_code_tbl(l_ctr)      := l_accrual_rec.currency_code;
            l_acr_cur_conv_type_tbl(l_ctr) := l_accrual_rec.currency_conversion_type;
            l_acr_cur_conv_rate_tbl(l_ctr) := l_accrual_rec.currency_conversion_rate;
            l_acr_cur_conv_date_tbl(l_ctr) := l_accrual_rec.currency_conversion_date;

        END IF;

        IF (p_calling_api = G_RECEIPT_ACCRUAL_PER_END) THEN
            CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl(CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl.COUNT + 1)
                                                    := l_distribution_rec.po_distribution_id;
        END IF;

    END LOOP;  --end of c_no_vendor_category_id loop

  ELSE

    FOR l_distribution_rec IN l_distribution_csr LOOP

        l_accrual_rec.shipment_id               := l_distribution_rec.line_location_id;
        l_accrual_rec.distribution_id           := l_distribution_rec.po_distribution_id;
        l_accrual_rec.category_id               := l_distribution_rec.category_id;
        l_accrual_rec.match_option              := l_distribution_rec.match_option;
        l_accrual_rec.currency_code             := l_distribution_rec.currency_code;
        l_accrual_rec.currency_conversion_type  := l_distribution_rec.curr_conv_type;
        l_accrual_rec.currency_conversion_rate  := l_distribution_rec.currency_rate;
        l_accrual_rec.currency_conversion_date  := l_distribution_rec.currency_conv_date;

        ---------------------------------------------------------------------
        -- Unit Price = po_price + tax
        -- Tax amount in pod is not recalculated in case of cancellation,
        -- so we do not consider cancelled qty while prorating dist tax.
        ---------------------------------------------------------------------
        l_stmt_num := 110;
        l_accrual_rec.unit_price := l_distribution_rec.po_price
                                    + po_tax_sv.get_tax( 'PO', l_distribution_rec.po_distribution_id)
                                                                / l_distribution_rec.quantity_ordered;

        ---------------------------------------------------------------------
        -- The procedure Calculate_AccrualAmount calculates the
        -- accrual_amount and encum_amount
        ---------------------------------------------------------------------
        l_stmt_num := 120;
        Calculate_AccrualAmount(
            p_api_version               => 1.0,
            p_init_msg_list             => FND_API.G_FALSE,
            p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
            x_return_status             => l_return_status,
            x_msg_count                 => x_msg_count,
            x_msg_data                  => x_msg_data,
            p_service_flag              => l_distribution_rec.service_flag,
            p_dist_qty                  => l_distribution_rec.distribution_quantity,
            p_shipment_qty              => l_distribution_rec.shipment_quantity,
            p_end_date                  => l_end_date,
            x_accrual_rec               => l_accrual_rec
            );

        -- If return status is not success, raise unexpected exception
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Error Occured while calculating acrual amount against the Shipment id :' ||
                          TO_CHAR(l_distribution_rec.line_location_id) ||
                          ' ,Distribution Id :' || TO_CHAR(l_distribution_rec.po_distribution_id);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        ---------------------------------------------------------------------
        -- We need only those accrual entries, for which:
        -- EITHER
        -- qty_received > qty_billed
        -- OR
        -- if qty_received < qty_billed and the process has been called by
        -- Uninvoiced Receipt Report (This case is used only for reporting
        -- over-invoicing)
        --
        -- Note: No need to consider the cases when qty_received = qty_billed
        ---------------------------------------------------------------------
        l_stmt_num := 130;
        IF ((l_accrual_rec.quantity_received > l_accrual_rec.quantity_billed)
           OR
           (l_accrual_rec.quantity_received < l_accrual_rec.quantity_billed AND
           p_calling_api = G_UNINVOICED_RECEIPT_REPORT))
        THEN

            -- Get the position of the new row to be added
            l_ctr := l_acr_dist_id_tbl.COUNT + 1;

            -----------------------------------------------------------------
            -- Add the record values to the PL/SQL tables
            -----------------------------------------------------------------
            l_acr_dist_id_tbl(l_ctr)       := l_accrual_rec.distribution_id;
            l_acr_shipment_id_tbl(l_ctr)   := l_accrual_rec.shipment_id;
            l_acr_category_id_tbl(l_ctr)   := l_accrual_rec.category_id;
            l_acr_match_option_tbl(l_ctr)  := l_accrual_rec.match_option;
            l_acr_qty_received_tbl(l_ctr)  := l_accrual_rec.quantity_received;
            l_acr_qty_billed_tbl(l_ctr)    := l_accrual_rec.quantity_billed;
            l_acr_accrual_qty_tbl(l_ctr)   := l_accrual_rec.accrual_quantity;
            l_acr_encum_qty_tbl(l_ctr)     := l_accrual_rec.encum_quantity;
            l_acr_unit_price_tbl(l_ctr)    := l_accrual_rec.unit_price;
            l_acr_accrual_amount_tbl(l_ctr):= l_accrual_rec.accrual_amount;
            l_acr_encum_amount_tbl(l_ctr)  := l_accrual_rec.encum_amount;
            l_acr_cur_code_tbl(l_ctr)      := l_accrual_rec.currency_code;
            l_acr_cur_conv_type_tbl(l_ctr) := l_accrual_rec.currency_conversion_type;
            l_acr_cur_conv_rate_tbl(l_ctr) := l_accrual_rec.currency_conversion_rate;
            l_acr_cur_conv_date_tbl(l_ctr) := l_accrual_rec.currency_conversion_date;

        END IF;

        ---------------------------------------------------------------------
        -- Add the distribution_id to the list of accrued distribution_id for
        -- Receipt Accrual-Period End Process
        ---------------------------------------------------------------------
        IF (p_calling_api = G_RECEIPT_ACCRUAL_PER_END) THEN
            CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl(CST_ReceiptAccrualPerEnd_PVT.g_accrued_dist_id_tbl.COUNT + 1)
                                                    := l_distribution_rec.po_distribution_id;
        END IF;

    END LOOP;  --end of l_distribution_rec loop

    END IF;

    -------------------------------------------------------------------------
    -- Bulk insert the data from PL/SQL tables to temp table
    -------------------------------------------------------------------------
    l_stmt_num := 140;
    FORALL l_ctr IN l_acr_dist_id_tbl.FIRST..l_acr_dist_id_tbl.LAST
        INSERT INTO cst_per_end_accruals_temp (
            shipment_id,
            distribution_id,
            category_id,
            match_option,
            quantity_received,
            quantity_billed,
            accrual_quantity,
            encum_quantity,
            unit_price,
            accrual_amount,
            encum_amount,
            currency_code,
            currency_conversion_type,
            currency_conversion_rate,
            currency_conversion_date
            )
        VALUES (
            l_acr_shipment_id_tbl(l_ctr),
            l_acr_dist_id_tbl(l_ctr),
            l_acr_category_id_tbl(l_ctr),
            l_acr_match_option_tbl(l_ctr),
            l_acr_qty_received_tbl(l_ctr),
            l_acr_qty_billed_tbl(l_ctr),
            l_acr_accrual_qty_tbl(l_ctr),
            l_acr_encum_qty_tbl(l_ctr),
            l_acr_unit_price_tbl(l_ctr),
            l_acr_accrual_amount_tbl(l_ctr),
            l_acr_encum_amount_tbl(l_ctr),
            l_acr_cur_code_tbl(l_ctr),
            l_acr_cur_conv_type_tbl(l_ctr),
            l_acr_cur_conv_rate_tbl(l_ctr),
            l_acr_cur_conv_date_tbl(l_ctr)
            );

    -------------------------------------------------------------------------
    -- Check for min_accrual_amount at shipment level.
    -- If accrual_amount for a shipment is less then min_accrual_amount, then
    -- delete the rows related to that shipment from the temporary table.
    -------------------------------------------------------------------------
    l_stmt_num := 150;
    DELETE FROM cst_per_end_accruals_temp
    WHERE   shipment_id IN (SELECT    shipment_id
                            FROM      cst_per_end_accruals_temp
                            GROUP BY  shipment_id
                            HAVING    SUM(accrual_amount) < NVL(p_min_accrual_amount, 0)
                            );

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(FND_LOG.LEVEL_PROCEDURE,l_module,'Create_PerEndAccruals >>');
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
            COMMIT WORK;
    END IF;

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO Create_PerEndAccruals_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_exceptionLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_EXCEPTION,
               l_module || '.' || l_stmt_num,
               l_msg_data
               );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
        ROLLBACK TO Create_PerEndAccruals_PVT;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        -- Unexpected level log message
        IF (l_uLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_UNEXPECTED,
               l_module || '.' || l_stmt_num,
               SQLERRM
               );
        END IF;

        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name,
                    '(' || TO_CHAR(l_stmt_num) || ') : ' || SUBSTRB (SQLERRM , 1 , 230)
            );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

END Create_PerEndAccruals;

-----------------------------------------------------------------------------
-- PROCEDURE    : Calculate_AccrualAmount
-- DESCRIPTION  : The procedure calculates and returns the record for the
--                CST_PER_END_ACCRUALS_TEMP
-----------------------------------------------------------------------------
PROCEDURE Calculate_AccrualAmount
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,
    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_service_flag                  IN      NUMBER,
    p_dist_qty                      IN      NUMBER,
    p_shipment_qty                  IN      NUMBER,
    p_end_date                      IN      DATE,
    p_transaction_id                IN      NUMBER,

    x_accrual_rec                   IN OUT  NOCOPY CST_PER_END_ACCRUALS_TEMP%ROWTYPE
)

IS
    l_api_name    CONSTANT          VARCHAR2(30) :='Calculate_AccrualAmount';
    l_api_version CONSTANT          NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_stmt_num                      NUMBER;
    l_msg_data                      VARCHAR2(240);

    l_last_rcv_shipment_id          NUMBER;
    l_shipment_remaining_qty        NUMBER;
    l_dist_remaining_qty            NUMBER;
    l_allocated_qty                 NUMBER;
    l_txn_net_qty_received          NUMBER;
    l_txn_net_qty_delivered         NUMBER;
    l_qty_in_receiving              NUMBER;
    l_over_receipt_qty              NUMBER;
    l_dist_qty_delivered            NUMBER;
    l_sum_func_amount               NUMBER;
    l_sum_allocate_amount           NUMBER;

    l_net_qty_received              NUMBER;
    l_qty_received                  NUMBER;
    l_qty_invoiced                  NUMBER;

    -------------------------------------------------------------------------
    --  For match to Receipt cases, need to traverse all the receipts created
    --  against the po_shipment.
    -------------------------------------------------------------------------
    CURSOR l_transaction_csr IS
        SELECT  transaction_id,
                shipment_header_id,
                currency_code,
                NVL(currency_conversion_rate, 1) currency_conversion_rate,
                currency_conversion_date,
                currency_conversion_type
        FROM    rcv_transactions
        WHERE   po_line_location_id = x_accrual_rec.shipment_id
        AND     ((transaction_type = 'RECEIVE' AND parent_transaction_id = -1)
                OR
                (transaction_type = 'MATCH'))
        AND     transaction_date <= p_end_date
        AND     (p_transaction_id IS NULL
                OR
                (transaction_id = p_transaction_id AND p_transaction_id IS NOT NULL))
        ORDER BY shipment_header_id, transaction_date;

    CURSOR l_po_distributions_csr IS
        SELECT      po_distribution_id,
                    DECODE (p_service_flag,
                            1, amount_ordered - NVL(amount_cancelled, 0),
                            quantity_ordered - NVL(quantity_cancelled, 0)) distribution_quantity
        FROM        po_distributions_all
        WHERE       line_location_id = x_accrual_rec.shipment_id;

BEGIN

    l_stmt_num := 0;

    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_PROCEDURE,
            l_module || '.begin',
            'Calculate_AccrualAmount <<' ||
            'p_service_flag = '     || p_service_flag   ||','||
            'p_dist_qty = '         || p_dist_qty       ||','||
            'p_shipment_qty = '     || p_shipment_qty   ||','||
            'p_end_date = '         || p_end_date       ||','||
            'p_transaction_id = '   || p_transaction_id ||','||
            'Shipment Id = '        || x_accrual_rec.shipment_id     || ', ' ||
            'Distribution Id = '    || x_accrual_rec.distribution_id || ', ' ||
            'Match Option = '       || x_accrual_rec.match_option
            );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Inintialize the variables
    x_accrual_rec.quantity_received:= 0;
    x_accrual_rec.quantity_billed  := 0;
    x_accrual_rec.accrual_quantity := 0;
    x_accrual_rec.accrual_amount   := 0;

    l_stmt_num := 60;
    -- Checking values so that there will not be any division by zero cases later
    IF (p_shipment_qty <= 0 OR p_dist_qty <= 0) THEN
        FND_MSG_PUB.Add_Exc_Msg (
            G_PKG_NAME,
            l_api_name,
            'Shipment Id :' || x_accrual_rec.shipment_id || ',' ||
            'Distribution Id :' || x_accrual_rec.distribution_id || ',' ||
            'Ordered quantity less than or equal to zero'
            );
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -------------------------------------------------------------------------
    -- If Match to PO cases
    -------------------------------------------------------------------------
    IF (x_accrual_rec.match_option = 'P') THEN
        IF (l_pLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_PROCEDURE,
	    l_module||',',
             ' g_shipment_id is '||g_shipment_id
            );
       END IF;

        -------------------------------------------------------------------------
        -- Get net_qty_received and net_qty_delivered against the PO shipment
        -- and net_qty_delivered against the distribution.
        -------------------------------------------------------------------------
        IF (x_accrual_rec.shipment_id <> NVL(g_shipment_id, -999)) THEN
            g_shipment_id := x_accrual_rec.shipment_id;

	    IF (l_pLog) THEN
             FND_LOG.STRING(
            FND_LOG.LEVEL_PROCEDURE,
	    l_module||',',
             ' g_shipment_id is '||g_shipment_id
            );
            END IF;

            -- clear and initialize the pl/sql table for dist_delivered_quantity
            g_dist_nqd_tbl.DELETE;
            FOR l_po_distributions IN l_po_distributions_csr LOOP
               g_dist_nqd_tbl(l_po_distributions.po_distribution_id) := 0;
            END LOOP;

            l_stmt_num := 100;
            Get_RcvQuantity (
                p_api_version           => 1.0,
                p_init_msg_list         => FND_API.G_FALSE,
                p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
                x_return_status         => l_return_status,
                x_msg_count             => x_msg_count,
                x_msg_data              => x_msg_data,
                p_line_location_id      => x_accrual_rec.shipment_id,
                p_service_flag          => p_service_flag,
                p_end_date              => p_end_date
            );
            -- If return status is not success, raise unexpected exception
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                l_msg_data := 'Failed calculating quantity_received and quantity_delivered against the Shipment id :' ||
                              TO_CHAR(x_accrual_rec.shipment_id);
                RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
            END IF;
        END IF;

        g_shipment_net_qty_received := g_nqr;

	IF (l_pLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_PROCEDURE,
	    l_module||',',
             ' g_shipment_net_qty_received is '||g_nqr
            );
        END IF;

        g_shipment_net_qty_delivered:= g_nqd;

	IF (l_pLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_PROCEDURE,
	    l_module||',',
             ' g_shipment_net_qty_delivered is '||g_nqd
            );
        END IF;

        g_dist_net_qty_delivered    := g_dist_nqd_tbl(x_accrual_rec.distribution_id);
	IF (l_pLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_PROCEDURE,
	    l_module||',',
             ' g_dist_net_qty_delivered is '||g_dist_nqd_tbl(x_accrual_rec.distribution_id)

            );
        END IF;


        -- Expected quantity yet to delivered at shipment level,
        -- i.e., sum(dist_quantity_ordered - dist_qty_delivered)
        l_shipment_remaining_qty := p_shipment_qty;
        FOR l_po_distributions IN l_po_distributions_csr LOOP
          IF (l_pLog) THEN
	  FND_LOG.STRING(
            FND_LOG.LEVEL_PROCEDURE,
	    l_module||',',
             ' l_po_distributions.po_distribution_id is '||l_po_distributions.po_distribution_id ||','||
	     'g_dist_nqd_tbl(l_po_distributions.po_distribution_id) qty is '|| g_dist_nqd_tbl(l_po_distributions.po_distribution_id)
            );
           END IF;

           IF (l_po_distributions.distribution_quantity > g_dist_nqd_tbl(l_po_distributions.po_distribution_id)) THEN
              IF (l_pLog) THEN
		FND_LOG.STRING(
		FND_LOG.LEVEL_PROCEDURE,
		l_module||',',
		' Inside if'
		);
	      END IF;

              l_shipment_remaining_qty := l_shipment_remaining_qty - g_dist_nqd_tbl(l_po_distributions.po_distribution_id);

           ELSE
	      IF (l_pLog) THEN
		FND_LOG.STRING(
		FND_LOG.LEVEL_PROCEDURE,
		l_module||',',
		' Inside else'
		);
	      END IF;
              l_shipment_remaining_qty := l_shipment_remaining_qty - l_po_distributions.distribution_quantity;
           END IF;
        END LOOP;

        -- Remaining (or expected) quantity to be delivered against this distributions
        -- dist_quantity_ordered - dist_quantity_delivered
        l_dist_remaining_qty := p_dist_qty - g_dist_net_qty_delivered;

	 IF (l_pLog) THEN
		FND_LOG.STRING(
		FND_LOG.LEVEL_PROCEDURE,
		l_module||',',
		'  l_dist_remaining_qty is  '|| l_dist_remaining_qty
		);
	      END IF;
        IF (l_dist_remaining_qty < 0) THEN
           l_dist_remaining_qty := 0;
        END IF;

        -- Quantity received, but not yet delivered
        l_qty_in_receiving := g_shipment_net_qty_received - g_shipment_net_qty_delivered;

        ---------------------------------------------------------------------
        -- Check for over receipts
        ---------------------------------------------------------------------
        IF (g_shipment_net_qty_received > p_shipment_qty) THEN
            l_over_receipt_qty := g_shipment_net_qty_received
                                    - (l_shipment_remaining_qty + g_shipment_net_qty_delivered);
            IF (l_over_receipt_qty < 0) THEN
                l_over_receipt_qty := 0;
            END IF;
            -- If over receipt quantity has been fully or partially delivered
            IF (l_qty_in_receiving <= l_over_receipt_qty) THEN
                l_over_receipt_qty := l_qty_in_receiving;
                l_qty_in_receiving := 0;

            -- If over receipt quantity has not yet been delivered
            ELSE
                l_qty_in_receiving := l_qty_in_receiving - l_over_receipt_qty;
            END IF;
        ELSE
            l_over_receipt_qty := 0;
        END IF;

        ---------------------------------------------------------------------
        -- Prorate the remaining quantity (which has been received but not
        -- been delivered) among the distribution
        ---------------------------------------------------------------------
        l_stmt_num := 110;
        IF (l_shipment_remaining_qty <= 0) THEN
            l_allocated_qty := 0;
        ELSE
            l_allocated_qty := l_qty_in_receiving *
                                    l_dist_remaining_qty / l_shipment_remaining_qty;
        END IF;

        ---------------------------------------------------------------------
        -- Prorate the over receipt quantity among the distributions
        -- based on the quantity ordered
        ---------------------------------------------------------------------
        l_stmt_num := 120;
        IF (l_over_receipt_qty > 0) THEN
            l_allocated_qty := l_allocated_qty + l_over_receipt_qty *
                                                    p_dist_qty / p_shipment_qty;
        END IF;

        ---------------------------------------------------------------------
        -- Total received quantity against the distribution
        --                      = Quantity delivered + allocated quantity
        ---------------------------------------------------------------------
        l_net_qty_received := g_dist_net_qty_delivered + l_allocated_qty;

        ---------------------------------------------------------------------
        -- Get quantity invoiced against the distribution
        ---------------------------------------------------------------------
        l_stmt_num := 130;
        Get_InvoiceQuantity (
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => l_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_match_option          => x_accrual_rec.match_option,
            p_dist_id               => x_accrual_rec.distribution_id,
            p_service_flag          => p_service_flag,
            p_end_date              => p_end_date,
            x_quantity_invoiced     => l_qty_invoiced
        );
        -- If return status is not success, raise unexpected exception
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Failed calculating Net quantity Invoiced against the Distribution id :'
                          || TO_CHAR(x_accrual_rec.distribution_id);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        x_accrual_rec.quantity_received   := l_net_qty_received;
        x_accrual_rec.quantity_billed     := l_qty_invoiced;

    END IF;

    -------------------------------------------------------------------------
    -- Match to Receipt cases
    -------------------------------------------------------------------------
    -- For PAC Period end accrual calculation
    -- If rcv_transaction_id is not null, calculate the qty_received and
    -- qty_delivered against the rcv_transaction_id for both Match to PO and
    -- match to Receipt cases.
    -- In this case the l_transaction_csr loop will run only once for the
    -- given rcv_transaction_id.
    -------------------------------------------------------------------------
    IF (x_accrual_rec.match_option = 'R' OR p_transaction_id IS NOT NULL) THEN

        -- Inintialize the variables
        IF (x_accrual_rec.distribution_id <> NVL(g_distribution_id, -999)) THEN
            g_shipment_net_qty_received    := 0;
            g_shipment_net_qty_delivered   := 0;
            g_dist_net_qty_delivered       := 0;
            g_distribution_id              := x_accrual_rec.distribution_id;

        END IF;
        l_qty_received                     := 0;
        l_sum_func_amount                  := 0;
        l_sum_allocate_amount              := 0;
        l_last_rcv_shipment_id             := -999;

        /* Bug 8675502
	Re-Initializing global variable  g_shipment_id
	*/
	g_shipment_id := x_accrual_rec.shipment_id;

	l_stmt_num := 150;

        l_shipment_remaining_qty := p_shipment_qty;
        -- Loop for each transactions
        FOR l_transaction_rec IN l_transaction_csr LOOP

            -- Check if the receipt has already been traversed.
            IF (l_transaction_rec.shipment_header_id <> l_last_rcv_shipment_id) THEN

                l_last_rcv_shipment_id := l_transaction_rec.shipment_header_id ;

                -- clear the pl/sql table for distribution_delivered_quantity
                g_dist_nqd_tbl.DELETE;
                FOR l_po_distributions IN l_po_distributions_csr LOOP
                   g_dist_nqd_tbl(l_po_distributions.po_distribution_id) := 0;
                END LOOP;

                -----------------------------------------------------------------
                -- get net_quantity_received and net_quantity_delivered against
                -- the receipt
                -----------------------------------------------------------------
                l_stmt_num := 160;
                Get_RcvQuantity (
                    p_api_version               => 1.0,
                    p_init_msg_list             => FND_API.G_FALSE,
                    p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
                    x_return_status             => l_return_status,
                    x_msg_count                 => x_msg_count,
                    x_msg_data                  => x_msg_data,
                    p_line_location_id          => x_accrual_rec.shipment_id,
                    p_rcv_shipment_id           => l_transaction_rec.shipment_header_id,
                    p_rcv_txn_id                => p_transaction_id,
                    p_service_flag              => p_service_flag,
                    p_end_date                  => p_end_date
                );
                -- If return status is not success, raise unexpected exception
                IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
                    l_msg_data := 'Failed calculating Net quantity received against the Transaction id :'
                                  || TO_CHAR(l_transaction_rec.transaction_id);
                    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                END IF;

                l_txn_net_qty_received := g_nqr;
                l_txn_net_qty_delivered:= g_nqd;
                l_dist_qty_delivered   := g_dist_nqd_tbl(x_accrual_rec.distribution_id);

                g_shipment_net_qty_received := g_shipment_net_qty_received + l_txn_net_qty_received;
                g_shipment_net_qty_delivered:= g_shipment_net_qty_delivered + l_txn_net_qty_delivered;
                g_dist_net_qty_delivered    := g_dist_net_qty_delivered + l_dist_qty_delivered;

                FOR l_po_distributions IN l_po_distributions_csr LOOP
                   IF (l_po_distributions.distribution_quantity > g_dist_nqd_tbl(l_po_distributions.po_distribution_id)) THEN
                      l_shipment_remaining_qty := l_shipment_remaining_qty - g_dist_nqd_tbl(l_po_distributions.po_distribution_id);
                   ELSE
                      l_shipment_remaining_qty := l_shipment_remaining_qty - l_po_distributions.distribution_quantity;
                   END IF;
                END LOOP;

                -----------------------------------------------------------------
                -- Total received quantity against the distribution
                --                      = Quantity delivered + allocated quantity
                -----------------------------------------------------------------
                l_txn_net_qty_received := l_dist_qty_delivered;
                l_qty_received         := l_qty_received + l_txn_net_qty_received;

                x_accrual_rec.currency_code             := l_transaction_rec.currency_code;
                x_accrual_rec.currency_conversion_type  := l_transaction_rec.currency_conversion_type;
                x_accrual_rec.currency_conversion_rate  := l_transaction_rec.currency_conversion_rate;

                -----------------------------------------------------------------
                -- Calculate sum of accrual amount in functional currency, this would
                -- be used to calculate Currency_conversion_rate for match to receipt cases
                -----------------------------------------------------------------
                l_sum_func_amount := l_sum_func_amount
                                     + l_txn_net_qty_received * l_transaction_rec.currency_conversion_rate;
                l_sum_allocate_amount := l_sum_allocate_amount +
                (g_nqr - g_nqd) * l_transaction_rec.currency_conversion_rate;

                -- Get the latest conversion_date
                IF (x_accrual_rec.currency_conversion_date IS NULL
                   OR x_accrual_rec.currency_conversion_date < l_transaction_rec.currency_conversion_date) THEN
                    x_accrual_rec.currency_conversion_date  := l_transaction_rec.currency_conversion_date;
                END IF;

            END IF;
        END LOOP;

        -----------------------------------------------------------------
        -- Get quantity invoiced against the rcv transaction
        -----------------------------------------------------------------
        l_stmt_num := 200;
        Get_InvoiceQuantity (
            p_api_version           => 1.0,
            p_init_msg_list         => FND_API.G_FALSE,
            p_validation_level      => FND_API.G_VALID_LEVEL_FULL,
            x_return_status         => l_return_status,
            x_msg_count             => x_msg_count,
            x_msg_data              => x_msg_data,
            p_match_option          => x_accrual_rec.match_option,
            p_dist_id               => x_accrual_rec.distribution_id,
            p_rcv_txn_id            => p_transaction_id,
            p_service_flag          => p_service_flag,
            p_end_date              => p_end_date,
            x_quantity_invoiced     => l_qty_invoiced
        );
        -- If return status is not success, raise unexpected exception
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
            l_msg_data := 'Failed calculating quantity invoiced against the distribution id :'
                          || TO_CHAR(x_accrual_rec.distribution_id);
            RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        x_accrual_rec.quantity_billed   := l_qty_invoiced;


        -- Remaining (or expected) quantity to be delivered against this distributions
	l_dist_remaining_qty := p_dist_qty - g_dist_net_qty_delivered;
	IF (l_dist_remaining_qty < 0) THEN
		l_dist_remaining_qty := 0;
	END IF;

        -- Quantity received, but not yet delivered
        l_qty_in_receiving := g_shipment_net_qty_received - g_shipment_net_qty_delivered;

        ---------------------------------------------------------------------
        -- Check for over receipts
        ---------------------------------------------------------------------
        IF (g_shipment_net_qty_received > p_shipment_qty) THEN
            l_over_receipt_qty := g_shipment_net_qty_received
                                    - (l_shipment_remaining_qty + g_shipment_net_qty_delivered);
            IF (l_over_receipt_qty < 0) THEN
                l_over_receipt_qty := 0;
            END IF;
            -- If over receipt quantity has been fully or partially delivered
            IF (l_qty_in_receiving <= l_over_receipt_qty) THEN
                l_over_receipt_qty := l_qty_in_receiving;
                l_qty_in_receiving := 0;

            -- If over receipt quantity has not yet been delivered
            ELSE
                l_qty_in_receiving := l_qty_in_receiving - l_over_receipt_qty;
            END IF;
        ELSE
            l_over_receipt_qty := 0;
        END IF;

        ---------------------------------------------------------------------
        -- Prorate the remaining quantity (which has been received but not
        -- been delivered) among the distribution
        ---------------------------------------------------------------------
        l_stmt_num := 221;
        IF (l_shipment_remaining_qty <= 0) THEN
            l_allocated_qty := 0;
        ELSE
            l_allocated_qty := l_qty_in_receiving *
                                    l_dist_remaining_qty / l_shipment_remaining_qty;
        END IF;

        ---------------------------------------------------------------------
        -- Prorate the over receipt quantity among the distributions
        -- based on the quantity ordered
        ---------------------------------------------------------------------
        l_stmt_num := 222;
        IF (l_over_receipt_qty > 0) THEN
            l_allocated_qty := l_allocated_qty + l_over_receipt_qty *
                                                    p_dist_qty / p_shipment_qty;
        END IF;

        ---------------------------------------------------------------------
        -- Total received quantity against the distribution
        --                      = Quantity delivered + allocated quantity
        ---------------------------------------------------------------------
        l_qty_received := l_qty_received + l_allocated_qty;


        x_accrual_rec.quantity_received := l_qty_received;

        ---------------------------------------------------------------------
        -- Currency_conversion_rate for match to receipt cases is weighted
        -- average of the currency_conversion_rate for all the txns
        ---------------------------------------------------------------------
        l_stmt_num := 223;
        IF (l_allocated_qty > 0) THEN
            x_accrual_rec.currency_conversion_rate  := (l_sum_func_amount +
            (l_sum_allocate_amount / (g_shipment_net_qty_received - g_shipment_net_qty_delivered) * l_allocated_qty) ) / l_qty_received;
        ELSIF (l_qty_received > 0) THEN
            x_accrual_rec.currency_conversion_rate  := l_sum_func_amount / l_qty_received;
        END IF;

        IF (x_accrual_rec.currency_conversion_rate IS NULL
           OR x_accrual_rec.currency_conversion_rate <= 0) THEN
           x_accrual_rec.currency_conversion_rate := 1;
        END IF;

    END IF;

    l_stmt_num := 230;
    -----------------------------------------------------------------
    -- Calculate the accrual amount
    -----------------------------------------------------------------
    IF (x_accrual_rec.quantity_received <= x_accrual_rec.quantity_billed) THEN
        x_accrual_rec.accrual_quantity := 0;
    ELSE
        x_accrual_rec.accrual_quantity := x_accrual_rec.quantity_received - x_accrual_rec.quantity_billed;
    END IF;

    x_accrual_rec.accrual_amount := x_accrual_rec.accrual_quantity * x_accrual_rec.unit_price;

    -------------------------------------------------------------------------
    -- Calculate the encumbrance amount
    -- We should only encumber upto quantity ordered. If quantity received is
    -- greater than quantity ordered, we should not encumber for the excess.
    -------------------------------------------------------------------------
    IF (x_accrual_rec.quantity_received <= p_dist_qty) THEN
        x_accrual_rec.encum_quantity := x_accrual_rec.accrual_quantity;
    ELSE
        x_accrual_rec.encum_quantity := x_accrual_rec.accrual_quantity
                                        - (x_accrual_rec.quantity_received - p_dist_qty);
    END IF;
    x_accrual_rec.encum_amount := x_accrual_rec.encum_quantity * x_accrual_rec.unit_price;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Calculate_AccrualAmount >> ' ||
               'quantity_received = '  || x_accrual_rec.quantity_received  ||','||
               'quantity_billed = '    || x_accrual_rec.quantity_billed    ||','||
               'accrual_quantity = '   || x_accrual_rec.accrual_quantity   ||','||
               'encum_quantity = '     || x_accrual_rec.encum_quantity     ||','||
               'accrual_amount = '     || x_accrual_rec.accrual_amount     ||','||
               'encum_amount = '       || x_accrual_rec.encum_amount
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_exceptionLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_EXCEPTION,
               l_module || '.' || l_stmt_num,
               l_msg_data
               );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF (l_uLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_UNEXPECTED,
               l_module || '.' || l_stmt_num,
               SQLERRM
               );
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name,
                    '(' || TO_CHAR(l_stmt_num) || ') : ' || SUBSTRB (SQLERRM , 1 , 230)
            );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

END Calculate_AccrualAmount;

-----------------------------------------------------------------------------
-- PROCEDURE    : Calculate_AccrualAmount
-- DESCRIPTION  : Procedure for PAC period end accrual process.
--                The procedure will return accrual and encum quantities only
-----------------------------------------------------------------------------
PROCEDURE Calculate_AccrualAmount
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,
    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_match_option                  IN      VARCHAR2,
    p_distribution_id               IN      NUMBER,
    p_shipment_id                   IN      NUMBER,
    p_transaction_id                IN      NUMBER,
    p_service_flag                  IN      NUMBER,
    p_dist_qty                      IN      NUMBER,
    p_shipment_qty                  IN      NUMBER,
    p_end_date                      IN      DATE,

    x_accrual_qty                   OUT     NOCOPY NUMBER,
    x_encum_qty                     OUT     NOCOPY NUMBER
)

IS
    l_api_name    CONSTANT          VARCHAR2(30) :='Calculate_AccrualAmount';
    l_api_version CONSTANT          NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_exceptionLog CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_EXCEPTION >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_exceptionLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_stmt_num                      NUMBER;
    l_msg_data                      VARCHAR2(240);
    l_accrual_rec                   CST_PER_END_ACCRUALS_TEMP%ROWTYPE;

BEGIN

    l_stmt_num := 0;

    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
        FND_LOG.STRING(
            FND_LOG.LEVEL_PROCEDURE,
            l_module || '.begin',
            'Calculate_AccrualAmount <<' ||
            'p_match_option = '     || p_match_option    ||','||
            'p_distribution_id = '  || p_distribution_id ||','||
            'p_shipment_id = '      || p_shipment_id     ||','||
            'p_transaction_id = '   || p_transaction_id  ||','||
            'p_service_flag = '     || p_service_flag    ||','||
            'p_dist_qty = '         || p_dist_qty        ||','||
            'p_shipment_qty = '     || p_shipment_qty    ||','||
            'p_end_date  = '        || p_end_date
            );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Prepairing accrual record to call the Calculate_AccrualAmount procedure
    l_accrual_rec.shipment_id     := p_shipment_id;
    l_accrual_rec.distribution_id := p_distribution_id;
    l_accrual_rec.match_option    := p_match_option;

    -- For PAC only accrual quantity will be returned, accrual amount will be
    -- calculated in the calling API itself
    l_accrual_rec.unit_price      := 1;

    -----------------------------------------------------------------
    -- The procedure Calculate_AccrualAmount calculates the
    -- accrual_amount and encum_amount
    -----------------------------------------------------------------
    l_stmt_num := 10;
    Calculate_AccrualAmount(
        p_api_version               => 1.0,
        p_init_msg_list             => FND_API.G_FALSE,
        p_validation_level          => FND_API.G_VALID_LEVEL_FULL,
        x_return_status             => l_return_status,
        x_msg_count                 => x_msg_count,
        x_msg_data                  => x_msg_data,
        p_service_flag              => p_service_flag,
        p_dist_qty                  => p_dist_qty,
        p_shipment_qty              => p_shipment_qty,
        p_end_date                  => p_end_date,
        p_transaction_id            => p_transaction_id,
        x_accrual_rec               => l_accrual_rec
        );
    -- If return status is not success, raise unexpected exception
    IF (l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
        l_msg_data := 'Failed calculating aacrual amount against the Shipment id :' ||
                      TO_CHAR(p_shipment_id);
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Assign the values returned
    x_accrual_qty       := l_accrual_rec.accrual_quantity;
    x_encum_qty         := l_accrual_rec.encum_quantity;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Calculate_AccrualAmount >>' ||
               'x_accrual_qty = '  || x_accrual_qty ||','||
               'x_encum_qty  = '   || x_encum_qty
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        IF (l_exceptionLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_EXCEPTION,
               l_module || '.' || l_stmt_num,
               l_msg_data
               );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF (l_uLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_UNEXPECTED,
               l_module || '.' || l_stmt_num,
               SQLERRM
               );
        END IF;

        IF FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name,
                    '(' || TO_CHAR(l_stmt_num) || ') : ' || SUBSTRB (SQLERRM , 1 , 230)
            );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

END Calculate_AccrualAmount;

-----------------------------------------------------------------------------
-- PROCEDURE    :   Get_RcvQuantity
-- DESCRIPTION  :   Returns the Net Quantity Received and net quantity
--                  delivered against a Shipment and distribution
--                  or against a Receipt
--
--                  net_qty_received = Quantity received
--                                    - return to vendor + corrections
--
--                  net_qty_delivered = Quantity delivered
--                                   - return to receiving + corrections
--
--                  The returned value will be in PO's UOM.
-----------------------------------------------------------------------------
PROCEDURE Get_RcvQuantity
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,
    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_line_location_id              IN      NUMBER,
    p_rcv_shipment_id               IN      NUMBER,
    p_rcv_txn_id                    IN      NUMBER,
    p_service_flag                  IN      NUMBER,
    p_end_date                      IN      DATE
)

IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Get_RcvQuantity';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_stmt_num                      NUMBER;
    l_parent_type                   VARCHAR2(25);
    qty_received                    NUMBER;
    qty_delivered                   NUMBER;

    -------------------------------------------------------------------------
    -- Cursor for calculating net quantity received and net quantity delivered
    -- against shipment
    -------------------------------------------------------------------------
    CURSOR l_shipment_csr IS
        SELECT      rt.transaction_id,
                    rt.po_line_location_id,
                    rt.po_distribution_id,
                    rt.transaction_type,
                    DECODE(p_service_flag,
                           1, rt.amount,
                           rt.source_doc_quantity) quantity,
                    rt.parent_transaction_id
        FROM        rcv_transactions rt
        WHERE       rt.transaction_date <= p_end_date
        START WITH  rt.po_line_location_id = p_line_location_id
               AND  ((rt.transaction_type = 'RECEIVE' AND rt.parent_transaction_id = -1)
                    OR
                    (rt.transaction_type = 'MATCH'))
        CONNECT BY  rt.parent_transaction_id = PRIOR rt.transaction_id
               AND  rt.po_line_location_id = PRIOR rt.po_line_location_id;

    -------------------------------------------------------------------------
    -- Cursor for calculating net quantity received and net quantity delivered
    -- against rcv transaction
    -------------------------------------------------------------------------
    CURSOR l_rcv_txn_csr IS
        SELECT      rt.transaction_id,
                    rt.po_line_location_id,
                    rt.po_distribution_id,
                    rt.transaction_type,
                    DECODE(p_service_flag,
                           1, rt.amount,
                           rt.source_doc_quantity) quantity,
                    rt.parent_transaction_id
        FROM        rcv_transactions rt
        WHERE       rt.transaction_date <= p_end_date
        START WITH  rt.shipment_header_id = p_rcv_shipment_id
               AND  rt.po_line_location_id = p_line_location_id
               AND  ((rt.transaction_type = 'RECEIVE' AND rt.parent_transaction_id = -1)
                    OR
                    (rt.transaction_type = 'MATCH'))
               AND  (p_rcv_txn_id IS NULL
                    OR
                    (rt.transaction_id = p_rcv_txn_id AND p_rcv_txn_id IS NOT NULL))
        CONNECT BY  rt.parent_transaction_id = PRIOR rt.transaction_id
               AND  rt.po_line_location_id = PRIOR rt.po_line_location_id;

BEGIN

    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Get_RcvQuantity << ' ||
               'p_line_location_id = '  || p_line_location_id ||','||
               'p_rcv_txn_id = '        || p_rcv_txn_id       ||','||
               'p_rcv_shipment_id = '   || p_rcv_shipment_id  ||','||
               'p_service_flag = '      || p_service_flag     ||','||
               'p_end_date = '          || p_end_date
               );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -- initialize the variables
    g_nqr := 0;
    g_nqd := 0;

    IF (p_rcv_shipment_id IS NULL) THEN

        -- For each child transaction loop
        l_stmt_num := 10;
        FOR l_shipment_rec IN l_shipment_csr LOOP

            qty_received := 0;
            qty_delivered := 0;

            -- If it is not RECEIVE or MATCH transaction
            IF (l_shipment_rec.transaction_type <> 'RECEIVE')
                AND (l_shipment_rec.transaction_type <> 'MATCH') THEN

                -- Get the parent transaction type
                l_stmt_num := 20;
                SELECT  rt.transaction_type
                INTO    l_parent_type
                FROM    rcv_transactions rt
                WHERE   rt.transaction_id = l_shipment_rec.parent_transaction_id;

            END IF;

            -----------------------------------------------------------------
            -- If it is the parent RECEIVE or MATCH transaction then add the
            -- quantity to x_nqr (net_quantity_received)
            -----------------------------------------------------------------
            l_stmt_num := 30;
            IF (l_shipment_rec.transaction_type = 'RECEIVE')
                OR (l_shipment_rec.transaction_type = 'MATCH') THEN

                qty_received := l_shipment_rec.quantity;

            ---------------------------------------------------------------------
            -- If it is the parent DELIVER transaction then add the quantity
            -- to x_nqd (net_quantity_delivered)
            ---------------------------------------------------------------------
            ELSIF (l_shipment_rec.transaction_type = 'DELIVER') THEN

                qty_delivered := l_shipment_rec.quantity;

            -----------------------------------------------------------------
            -- If the transaction is CORRECT :
            -- If parent is RECEIVE or MATCH transaction then add the corrected qty to x_nqr,
            -- If parent is RETURN TO VENDOR then subtract the corrected qty from x_nqr,
            -- If parent is DELIVER then add corrected qty to x_nqd,
            -- If parent is RETURN TO RECEIVING then subtract the corrected qty from x_nqd
            -----------------------------------------------------------------
            ELSIF (l_shipment_rec.transaction_type = 'CORRECT') THEN

                IF (l_parent_type = 'RECEIVE' OR l_parent_type = 'MATCH') THEN
                    qty_received := l_shipment_rec.quantity;

                ELSIF (l_parent_type = 'RETURN TO VENDOR') THEN
                    qty_received := -1 * l_shipment_rec.quantity;

                ELSIF (l_parent_type = 'DELIVER') THEN
                    qty_delivered := l_shipment_rec.quantity;

                ELSIF (l_parent_type = 'RETURN TO RECEIVING') THEN
                    qty_delivered := -1 * l_shipment_rec.quantity;

                END IF;

            -----------------------------------------------------------------
            -- If transaction is RETURN TO VENDOR transaction, then subtract
            -- returned qty from net_quantity_received
            -----------------------------------------------------------------
            ELSIF (l_shipment_rec.transaction_type = 'RETURN TO VENDOR') THEN
                qty_received := -1 * l_shipment_rec.quantity;

            -----------------------------------------------------------------
            -- If transaction is RETURN TO RECEIVING transaction, then subtract
            -- returned qty from net_quantity_delivered
            -----------------------------------------------------------------
            ELSIF (l_shipment_rec.transaction_type = 'RETURN TO RECEIVING') THEN
                qty_delivered := -1 * l_shipment_rec.quantity;

            END IF;

            -- Sum of net_quantity_received
            g_nqr := g_nqr + qty_received;

            -- Sum of net_quantity_delivered
            g_nqd := g_nqd + qty_delivered;

            -----------------------------------------------------------------
            -- Get net_quantity_delivered against each po_distributions
            -----------------------------------------------------------------
            IF (l_shipment_rec.po_distribution_id IS NOT NULL) THEN
                g_dist_nqd_tbl(l_shipment_rec.po_distribution_id)
                                        := g_dist_nqd_tbl(l_shipment_rec.po_distribution_id) + qty_delivered;
            END IF;
        END LOOP;

    ELSE

        -- For each child transaction loop
        l_stmt_num := 40;
        FOR l_txn_rec IN l_rcv_txn_csr LOOP

            qty_received := 0;
            qty_delivered := 0;

            -- If it is not RECEIVE or MATCH transaction
            IF (l_txn_rec.transaction_type <> 'RECEIVE')
                AND (l_txn_rec.transaction_type <> 'MATCH') THEN

                -- Get the parent transaction type
                l_stmt_num := 50;
                SELECT  rt.transaction_type
                INTO    l_parent_type
                FROM    rcv_transactions rt
                WHERE   rt.transaction_id = l_txn_rec.parent_transaction_id;

            END IF;

            -----------------------------------------------------------------
            -- If it is the parent RECEIVE or MATCH transaction then add the
            -- quantity to x_nqr (net_quantity_received)
            -----------------------------------------------------------------
            l_stmt_num := 60;
            IF (l_txn_rec.transaction_type = 'RECEIVE')
                OR (l_txn_rec.transaction_type = 'MATCH') THEN

                qty_received := l_txn_rec.quantity;

            ---------------------------------------------------------------------
            -- If it is the parent DELIVER transaction then add the quantity
            -- to x_nqd (net_quantity_delivered)
            ---------------------------------------------------------------------
            ELSIF (l_txn_rec.transaction_type = 'DELIVER') THEN

                qty_delivered := l_txn_rec.quantity;

            -----------------------------------------------------------------
            -- If the transaction is CORRECT :
            -- If parent is RECEIVE or MATCH transaction then add the corrected qty to x_nqr,
            -- If parent is RETURN TO VENDOR then subtract the corrected qty from x_nqr,
            -- If parent is DELIVER then add corrected qty to x_nqd,
            -- If parent is RETURN TO RECEIVING then subtract the corrected qty from x_nqd
            -----------------------------------------------------------------
            ELSIF (l_txn_rec.transaction_type = 'CORRECT') THEN

                IF (l_parent_type = 'RECEIVE' OR l_parent_type = 'MATCH') THEN
                    qty_received := l_txn_rec.quantity;

                ELSIF (l_parent_type = 'RETURN TO VENDOR') THEN
                    qty_received := -1 * l_txn_rec.quantity;

                ELSIF (l_parent_type = 'DELIVER') THEN
                    qty_delivered := l_txn_rec.quantity;

                ELSIF (l_parent_type = 'RETURN TO RECEIVING') THEN
                    qty_delivered := -1 * l_txn_rec.quantity;

                END IF;

            -----------------------------------------------------------------
            -- If transaction is RETURN TO VENDOR transaction, then subtract
            -- returned qty from net_quantity_received
            -----------------------------------------------------------------
            ELSIF (l_txn_rec.transaction_type = 'RETURN TO VENDOR') THEN
                qty_received := -1 * l_txn_rec.quantity;

            -----------------------------------------------------------------
            -- If transaction is RETURN TO RECEIVING transaction, then subtract
            -- returned qty from net_quantity_delivered
            -----------------------------------------------------------------
            ELSIF (l_txn_rec.transaction_type = 'RETURN TO RECEIVING') THEN
                qty_delivered := -1 * l_txn_rec.quantity;

            END IF;

            g_nqr := g_nqr + qty_received;
            g_nqd := g_nqd + qty_delivered;

            -----------------------------------------------------------------
            -- Get net_quantity_delivered against each po_distributions
            -----------------------------------------------------------------
            IF (l_txn_rec.po_distribution_id IS NOT NULL) THEN
                g_dist_nqd_tbl(l_txn_rec.po_distribution_id)
                                        := g_dist_nqd_tbl(l_txn_rec.po_distribution_id) + qty_delivered;

            END IF;

        END LOOP;

    END IF;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Get_RcvQuantity >> ' ||
               'g_nqr = '        || g_nqr      ||','||
               'g_nqd = '        || g_nqd
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF (l_uLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_UNEXPECTED,
               l_module || '.' || l_stmt_num,
               SQLERRM
               );
        END IF;

        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name,
                    '(' || TO_CHAR(l_stmt_num) || ') : ' || SUBSTRB (SQLERRM , 1 , 230)
            );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

END Get_RcvQuantity;

-----------------------------------------------------------------------------
-- PROCEDURE    :   Get_InvoiceQuantity
-- DESCRIPTION  :   Returns quantity invoiced against the distribution or
--                  the receipt.
-----------------------------------------------------------------------------
PROCEDURE Get_InvoiceQuantity
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,
    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_match_option                  IN      VARCHAR2,
    p_dist_id                       IN      NUMBER,
    p_rcv_txn_id                    IN      NUMBER,
    p_service_flag                  IN      NUMBER,
    p_end_date                      IN      DATE,
    x_quantity_invoiced             OUT     NOCOPY NUMBER
)

IS
    l_api_name     CONSTANT         VARCHAR2(30) :='Get_InvoiceQuantity';
    l_api_version  CONSTANT         NUMBER       := 1.0;
    l_return_status                 VARCHAR2(1);

    l_full_name    CONSTANT         VARCHAR2(60) := G_PKG_NAME || '.' || l_api_name;
    l_module       CONSTANT         VARCHAR2(60) := 'cst.plsql.'||l_full_name;

    l_uLog         CONSTANT BOOLEAN := FND_LOG.TEST(FND_LOG.LEVEL_UNEXPECTED, l_module) AND (FND_LOG.LEVEL_UNEXPECTED >= G_LOG_LEVEL);
    l_pLog         CONSTANT BOOLEAN := l_uLog AND (FND_LOG.LEVEL_PROCEDURE >= G_LOG_LEVEL);
    l_sLog         CONSTANT BOOLEAN := l_pLog AND (FND_LOG.LEVEL_STATEMENT >= G_LOG_LEVEL);

    l_quantity_invoiced             NUMBER;
    l_txn_to_po_rate                NUMBER;
    l_stmt_num                      NUMBER;

BEGIN

    l_stmt_num := 0;
    -- Procedure level log message for Entry point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.begin',
               'Get_InvoiceQuantity <<' ||
               'p_match_option = '  || p_match_option ||','||
               'p_dist_id = '       || p_dist_id      ||','||
               'p_rcv_txn_id = '    || p_rcv_txn_id   ||','||
               'p_service_flag = '  || p_service_flag ||','||
               'p_end_date = '      || p_end_date
               );
    END IF;

    -- Standard call to check for call compatibility.
    IF NOT FND_API.Compatible_API_Call ( l_api_version,
                                         p_api_version,
                                         l_api_name,
                                         G_PKG_NAME )
    THEN
           RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean( p_init_msg_list ) THEN
           FND_MSG_PUB.initialize;
    END IF;

    --  Initialize API return status to success
    x_return_status := FND_API.G_RET_STS_SUCCESS;
    l_return_status := FND_API.G_RET_STS_SUCCESS;

    -------------------------------------------------------------------------
    -- If Match option is Match to PO
    -------------------------------------------------------------------------
    l_stmt_num := 10;
    IF (p_match_option = 'P') THEN

        SELECT  NVL(DECODE(p_service_flag,
                           1, SUM(aida.amount),
                           SUM(aida.quantity_invoiced)),
                    0)
        INTO    l_quantity_invoiced
        FROM    ap_invoice_distributions_all aida,
                ap_invoices_all aia
        WHERE   aida.po_distribution_id = p_dist_id
        AND     aida.line_type_lookup_code NOT IN ('IPV', 'ERV', 'PREPAY')
        AND     aida.accounting_date <= p_end_date
        AND     aida.posted_flag = 'Y'
        AND     aia.invoice_id = aida.invoice_id
        AND     aia.invoice_type_lookup_code <> 'PREPAYMENT';

    -------------------------------------------------------------------------
    -- If Match option is Match to Receipt
    -------------------------------------------------------------------------
    l_stmt_num := 20;
    ELSIF (p_match_option = 'R') THEN

        SELECT  NVL(DECODE(p_service_flag,
                           1, SUM(aida.amount),
                           SUM(aida.quantity_invoiced
                                  * inv_convert.inv_um_convert(pol.item_id,
                                                               10,
                                                               NULL,
                                                               NULL,
                                                               NULL,
                                                               aida.matched_uom_lookup_code,
                                                               NVL(pol.unit_meas_lookup_code, poll.unit_meas_lookup_code)))),
                    0)
        INTO    l_quantity_invoiced
        FROM    ap_invoice_distributions_all aida,
                ap_invoices_all aia,
                po_lines_all pol,
                po_line_locations_all poll,
                po_distributions_all pod
        WHERE   aida.po_distribution_id = pod.po_distribution_id
        AND     (p_rcv_txn_id IS NULL OR aida.rcv_transaction_id = p_rcv_txn_id)
        AND     aida.line_type_lookup_code NOT IN ('IPV', 'ERV', 'PREPAY')
        AND     aida.accounting_date <= p_end_date
        AND     aia.invoice_id = aida.invoice_id
        AND     aia.invoice_type_lookup_code <> 'PREPAYMENT'
        AND     aida.posted_flag = 'Y'
        AND     pod.po_distribution_id = p_dist_id
        AND     pol.po_line_id = poll.po_line_id
        AND     poll.line_location_id = pod.line_location_id;

    END IF;

    -------------------------------------------------------------------------
    -- If the user is weird in his invoice reversals (dating them before the
    -- invoice itself and then accruing between them) it is possible for the
    -- quantity invoiced to be negative.  This would improperly increase the
    -- accrual amount.
    -------------------------------------------------------------------------
    IF (l_quantity_invoiced < 0) THEN
        l_quantity_invoiced := 0;
    END IF;

    x_quantity_invoiced := l_quantity_invoiced;

    -- Procedure level log message for exit point
    IF (l_pLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_PROCEDURE,
               l_module || '.end',
               'Get_InvoiceQuantity >> ' ||
               'x_quantity_invoiced = ' || x_quantity_invoiced
               );
    END IF;

    -- Get message count and if 1, return message data.
    FND_MSG_PUB.Count_And_Get
    (       p_count                 =>      x_msg_count,
            p_data                  =>      x_msg_data
    );

EXCEPTION

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN

        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

    WHEN OTHERS THEN
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

        IF (l_uLog) THEN
           FND_LOG.STRING(
               FND_LOG.LEVEL_UNEXPECTED,
               l_module || '.' || l_stmt_num,
               SQLERRM
               );
        END IF;

        IF      FND_MSG_PUB.Check_Msg_Level
                (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
        THEN
            FND_MSG_PUB.Add_Exc_Msg
            (       G_PKG_NAME,
                    l_api_name,
                    '(' || TO_CHAR(l_stmt_num) || ') : ' || SUBSTRB (SQLERRM , 1 , 230)
            );
        END IF;

        FND_MSG_PUB.Count_And_Get
        (       p_count                 =>      x_msg_count,
                p_data                  =>      x_msg_data
        );

END Get_InvoiceQuantity;

END CST_PerEndAccruals_PVT;  -- end package body

/
