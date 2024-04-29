--------------------------------------------------------
--  DDL for Package PO_CHARGES_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_CHARGES_GRP" AUTHID CURRENT_USER AS
/* $Header: POXGFSCS.pls 120.4.12010000.4 2013/09/12 06:18:12 wayin ship $ */

TYPE charge_table_type IS TABLE OF po_rcv_charges%ROWTYPE INDEX BY PLS_INTEGER;
TYPE charge_allocation_table_type IS TABLE OF po_rcv_charge_allocations%ROWTYPE INDEX BY PLS_INTEGER;

--
--    API name    : capture_QP_charges
--    Type        : Group
--    Function    : Populate charge tables with QP estimated charges
--    Pre-reqs    :
--    Parameters  :
--    IN          :
--    OUT         :
--    Version     : Initial version     1.0
--    Notes       : Note text
--
PROCEDURE Capture_QP_Charges
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_group_id           IN NUMBER
, p_request_id         IN NUMBER
);

--
--    API name    : capture_FTE_charges
--    Type        : Group
--    Function    : Populate charge tables with FTE estimated charges
--    Pre-reqs    :
--    Parameters  :
--    IN          :
--    OUT         :
--    Version     : Initial version     1.0
--    Notes       : Note text
--
PROCEDURE Capture_FTE_Estimated_Charges
( p_api_version        IN NUMBER
, p_init_msg_list      IN VARCHAR2
, x_return_status      OUT NOCOPY VARCHAR2
, x_msg_count          OUT NOCOPY NUMBER
, x_msg_data           OUT NOCOPY VARCHAR2
, p_group_id           IN NUMBER
, p_request_id         IN NUMBER
);

--
--    API name    : Record_FTE_Actual_Charges
--    Type        : Group
--    Function    : Populate charge tables with FTE actual charges
--    Pre-reqs    :
--    Parameters  :
--    IN          :
--    OUT         :
--    Version     : Initial version     1.0
--    Notes       : Note text

PROCEDURE Capture_FTE_Actual_Charges
( p_api_version           IN NUMBER
, p_init_msg_list         IN VARCHAR2
, x_return_status         OUT NOCOPY VARCHAR2
, x_msg_count             OUT NOCOPY NUMBER
, x_msg_data              OUT NOCOPY VARCHAR2
, p_fte_actual_charge     IN po_rcv_charges%rowtype
);

--    API name    : Extract_AP_Actual_Charges
--    Type        : Group
--    Function    : Capture the actual charges from AP system
--    Pre-reqs    :
--    Parameters  :
--    IN          :
--    OUT         :
--    Version     : Initial version     1.0
--    Notes       : Concurrent program

PROCEDURE Extract_AP_Actual_Charges
( errbuf               OUT NOCOPY VARCHAR2
, retcode              OUT NOCOPY VARCHAR2
);


cursor ap_po_charge_distributions_csr is
SELECT decode(ail_charge_lines.line_type_lookup_code, 'MISCELLANEOUS', 'ORACLE_AP_MISC',
                       'FREIGHT', 'ORACLE_AP_FREIGHT') cost_factor_code
	     ,nvl(ail_charge_lines.cost_factor_id,0) cost_factor_id
             , nvl(aid_charge.amount,0) amount
             , rsl.shipment_header_id shipment_header_id
             , rsl.shipment_line_id shipment_line_id
             , ai_non_fte_invoices.vendor_id vendor_id
             , ai_non_fte_invoices.vendor_site_id vendor_site_id
             , aid_charge.invoice_distribution_id invoice_distribution_id
             , ai_non_fte_invoices.invoice_currency_code currency_code
             , 0 rec_tax
             , 0 nonrec_tax
             , ap_invoices_utility_pkg.get_approval_status(ai_non_fte_invoices.invoice_id,
                                                           ai_non_fte_invoices.invoice_amount,
                                                           ai_non_fte_invoices.payment_status_flag,
                                                           ai_non_fte_invoices.invoice_type_lookup_code) invoice_status
FROM   ap_invoice_distributions_all aid_charge,
       ap_invoice_distributions_all aid_matched_items,
       ap_invoice_lines_all ail_charge_lines,
       ap_invoices_all ai_non_fte_invoices,
       po_distributions_all pod,
       po_line_locations_all poll,
       rcv_shipment_lines rsl
WHERE  aid_charge.charge_applicable_to_dist_id = aid_matched_items.invoice_distribution_id
AND    NVL(aid_charge.rcv_charge_addition_flag, 'N') = 'N'
--AND    nvl(aid_charge.posted_flag, 'N') = 'Y'
AND    aid_matched_items.po_distribution_id is not null
AND    aid_charge.invoice_id = ail_charge_lines.invoice_id
AND    aid_charge.invoice_line_number = ail_charge_lines.line_number
AND    ail_charge_lines.line_type_lookup_code IN ('FREIGHT','MISCELLANEOUS')
AND    ail_charge_lines.invoice_id = ai_non_fte_invoices.invoice_id
AND    ai_non_fte_invoices.source <> 'FTE'
AND    aid_matched_items.po_distribution_id = pod.po_distribution_id
and    poll.line_location_id= pod.line_location_id
and    poll.line_location_id= rsl.po_line_location_id --added for bug 5024597
and    ( rsl.quantity_received >= rsl.quantity_shipped OR
                 poll.quantity_received >= poll.quantity OR
                 rsl.amount_received >= rsl.amount OR
                 poll.amount_received >= poll.amount
                 )
           -- latest receipt for this PO
           AND rsl.shipment_line_id = ( SELECT MAX(rsl2.shipment_line_id)
                                          FROM rcv_shipment_lines rsl2
                                         WHERE rsl2.po_line_location_id = poll.line_location_id );

cursor ap_rcv_charge_distr_csr is
SELECT decode(ail_charge_lines.line_type_lookup_code, 'MISCELLANEOUS', 'ORACLE_AP_MISC',
                       'FREIGHT', 'ORACLE_AP_FREIGHT') cost_factor_code
	     ,nvl(ail_charge_lines.cost_factor_id,0) cost_factor_id
             , nvl(aid_charge.amount,0) amount
             , rsl.shipment_header_id shipment_header_id
             , rsl.shipment_line_id shipment_line_id
             , ai_non_fte_invoices.vendor_id vendor_id
             , ai_non_fte_invoices.vendor_site_id vendor_site_id
             , aid_charge.invoice_distribution_id invoice_distribution_id
             , ai_non_fte_invoices.invoice_currency_code currency_code
             , 0 rec_tax
             , 0 nonrec_tax
             , ap_invoices_utility_pkg.get_approval_status(ai_non_fte_invoices.invoice_id,
                                                           ai_non_fte_invoices.invoice_amount,
                                                           ai_non_fte_invoices.payment_status_flag,
                                                           ai_non_fte_invoices.invoice_type_lookup_code) invoice_status
FROM   ap_invoice_distributions_all aid_charge,
       ap_invoice_lines_all ail_charge_lines,
       ap_invoices_all ai_non_fte_invoices,
       rcv_transactions rt,
       rcv_shipment_lines rsl
WHERE  aid_charge.rcv_transaction_id is NOT NULL
AND    NVL(aid_charge.rcv_charge_addition_flag, 'N') = 'N'
--AND    nvl(aid_charge.posted_flag, 'N') = 'Y'
AND    aid_charge.invoice_id = ail_charge_lines.invoice_id
AND    aid_charge.invoice_line_number = ail_charge_lines.line_number
AND    ail_charge_lines.line_type_lookup_code IN ('FREIGHT','MISCELLANEOUS')
AND    ail_charge_lines.invoice_id = ai_non_fte_invoices.invoice_id
AND    ai_non_fte_invoices.source <> 'FTE'
AND    aid_charge.rcv_transaction_id = rt.transaction_id
AND     rt.shipment_line_id = rsl.shipment_line_id
AND     (rsl.quantity_received >= rsl.quantity_shipped or
         rsl.amount_received >= rsl.amount_shipped);

PROCEDURE Process_AP_Actual_Charges
(
        l_ap_charge_distribution IN OUT NOCOPY   po_charges_grp.ap_po_charge_distributions_csr%ROWTYPE,
        l_charge_table  IN OUT NOCOPY CHARGE_TABLE_TYPE,
        l_charge_alloc_table IN OUT NOCOPY  CHARGE_ALLOCATION_TABLE_TYPE,
        k  IN OUT NOCOPY number
);

END PO_CHARGES_GRP;

/
