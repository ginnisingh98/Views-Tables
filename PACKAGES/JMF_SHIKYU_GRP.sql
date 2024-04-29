--------------------------------------------------------
--  DDL for Package JMF_SHIKYU_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JMF_SHIKYU_GRP" AUTHID CURRENT_USER as
--$Header: JMFGSHKS.pls 120.3 2007/12/28 09:17:00 kdevadas ship $
--+===========================================================================+
--|                    Copyright (c) 2005 Oracle Corporation                  |
--|                       Redwood Shores, California, USA                     |
--|                            All rights reserved.                           |
--+===========================================================================+
--|                                                                           |
--|  FILENAME :            JMFGSHKS.pls                                       |
--|                                                                           |
--|  DESCRIPTION:          This is the group package for the Charge Based     |
--|                        SHIKYU project.  Other products such as CST,       |
--|                        RCV, PO and Financials Globalization will be       |
--|                        calling this package to support SHIKYU.            |
--|                                                                           |
--|  HISTORY:                                                                 |
--|   20-APR-2005          vchu  Created.                                     |
--|   19-Sep-2005          vchu  Added Is_AP_Inv_Shikyu_Nettable_Func.        |
--|   03-Oct-2007      kdevadas  12.1 Buy/Sell Subcontracting Changes         |
--|                              Reference - GBL_BuySell_TDD.doc              |
--|                              Reference - GBL_BuySell_FDD.doc              |
--|   27-DEC-2007      kdevadas  Bug: 6679369 - Get_shikyu_variance_account   |
--|                              modified to pass the subcontracting type     |
--|                              to Costing for OSA receipts in Std Cost orgs |
--+===========================================================================+

G_PKG_NAME CONSTANT VARCHAR2(30) := 'JMF_SHIKYU_GRP';

PROCEDURE Get_Shikyu_Variance_Account
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_po_shipment_id          IN  NUMBER
, x_variance_account        OUT NOCOPY NUMBER
, x_subcontracting_type     OUT NOCOPY NUMBER    -- Bug 6679369
);

PROCEDURE Get_Po_Shipment_Osa_Flag
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_po_shipment_id          IN  NUMBER
, x_osa_flag                OUT NOCOPY VARCHAR2
);

PROCEDURE Is_Tp_Organization
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN  NUMBER
, x_is_tp_org_flag          OUT NOCOPY VARCHAR2
);

PROCEDURE Is_AP_Invoice_Shikyu_Nettable
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_ap_invoice_id           IN  NUMBER
, x_nettable                OUT NOCOPY VARCHAR2
);

FUNCTION Is_AP_Inv_Shikyu_Nettable_Func
( p_ap_invoice_id            IN  NUMBER
)
RETURN VARCHAR2;

PROCEDURE Is_So_Line_Shikyu_Enabled
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_sales_order_line_id     IN  NUMBER
, x_is_enabled              OUT NOCOPY VARCHAR2
);

PROCEDURE Validate_Osa_Flag
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_inventory_item_id       IN  NUMBER
, p_vendor_id               IN  NUMBER
, p_vendor_site_id          IN  NUMBER
, p_ship_to_organization_id IN  NUMBER
, x_osa_flag                OUT NOCOPY VARCHAR2
);

PROCEDURE Get_Shikyu_Attributes
( p_api_version             IN  NUMBER
, p_init_msg_list           IN  VARCHAR2
, x_return_status           OUT NOCOPY VARCHAR2
, x_msg_count               OUT NOCOPY NUMBER
, x_msg_data                OUT NOCOPY VARCHAR2
, p_organization_id         IN  NUMBER
, p_item_id                 IN  NUMBER
, x_outsourced_assembly     OUT NOCOPY NUMBER
, x_subcontracting_component   OUT NOCOPY NUMBER
);

/* 12.1 Buy/Sell Subcontracting Changes */

FUNCTION Get_Subcontracting_TYpe
( p_oem_org_id IN NUMBER
, p_mp_org_id IN NUMBER	) RETURN VARCHAR2;


END JMF_SHIKYU_GRP;

/
