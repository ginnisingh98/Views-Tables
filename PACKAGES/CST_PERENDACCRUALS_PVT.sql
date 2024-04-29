--------------------------------------------------------
--  DDL for Package CST_PERENDACCRUALS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CST_PERENDACCRUALS_PVT" AUTHID CURRENT_USER AS
/* $Header: CSTVPEAS.pls 120.5.12010000.1 2008/07/24 17:26:04 appldev ship $ */

-----------------------------------------------------------------------------
-- Defining global variables for the calling api.
-----------------------------------------------------------------------------
G_RECEIPT_ACCRUAL_PER_END           CONSTANT NUMBER := 1;
G_UNINVOICED_RECEIPT_REPORT         CONSTANT NUMBER := 2;

-- Global variables to track the quantities for each distribution. Using global
-- variables, since the API is being called by PAC Period end process also.
g_shipment_net_qty_received                  NUMBER;
g_shipment_net_qty_delivered                 NUMBER;
g_dist_net_qty_delivered                     NUMBER;
g_distribution_id                            NUMBER;
g_shipment_id                                NUMBER;
g_nqr                                        NUMBER;
g_nqd                                        NUMBER;

-----------------------------------------------------------------------------
-- PL/SQL table types for accrual info to be inserted in temp table
-----------------------------------------------------------------------------
TYPE acr_dist_id_tbl_type          IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_shipment_id_tbl_type      IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_category_id_tbl_type      IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_match_option_tbl_type     IS TABLE OF VARCHAR2(1)   INDEX BY BINARY_INTEGER;
TYPE acr_qty_received_tbl_type     IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_qty_billed_tbl_type       IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_accrual_qty_tbl_type      IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_encum_qty_tbl_type        IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_unit_price_tbl_type       IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_accrual_amount_tbl_type   IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_encum_amount_tbl_type     IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_cur_code_tbl_type         IS TABLE OF VARCHAR2(15)  INDEX BY BINARY_INTEGER;
TYPE acr_cur_conv_type_tbl_type    IS TABLE OF VARCHAR2(30)  INDEX BY BINARY_INTEGER;
TYPE acr_cur_conv_rate_tbl_type    IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
TYPE acr_cur_conv_date_tbl_type    IS TABLE OF DATE          INDEX BY BINARY_INTEGER;

TYPE dist_nqd_tbl_type             IS TABLE OF NUMBER        INDEX BY BINARY_INTEGER;
g_dist_nqd_tbl                     dist_nqd_tbl_type;

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Create_PerEndAccruals
--   Type            : Private
--   Function        : Starting point for Period End Accrual program.
--                     The API creates period end accrual entries in the
--                     temporary table CST_PER_END_ACCRUALS_TEMP.
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version      NUMBER       Required
--     p_init_msg_list    VARCHAR2     Required
--     p_commit           VARCHAR2     Required
--     p_validation_level NUMBER       Required
--     p_min_accrual_amount NUMBER     Required
--                                     Minimum Accrual Amount
--     p_vendor_id        NUMBER       Optional         default NULL
--     p_vendor_from      VARCHAR2     Optional         default NULL
--                                     Vendor From
--     p_vendor_to        VARCHAR2     Optional         default NULL
--                                     Vendor to
--     p_category_id      NUMBER       Optional         default NULL
--                                     Category Id
--     p_category_from    VARCHAR2     Optional         default NULL
--                                     Category From
--     p_category_to      VARCHAR2     Optional         default NULL
--                                     Category to
--     p_end_date         DATE         Required
--                                     Period End date
--     p_accrued_receipt  VARCHAR2     Optional         default NULL
--                                     Accrued receipts, 'Y' or 'N'
--     p_online_accruals  VARCHAR2     Optional         default NULL
--                                     Include online accruals 'Y' or 'N'
--     p_online_accruals  VARCHAR2     Optional         default NULL
--                                     Include Closed POs 'Y' or 'N'
--
--                                     p_online_accruals, p_accrued_receipts and
--                                     p_online_accruals are used for Uninvoiced
--                                     Receipts Report, in other case this value
--                                     will be 'N'
--     p_calling_api      NUMBER       Optional
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--
--   Version : Current version       1.0
--
-- End of comments
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
    p_vendor_id                     IN      NUMBER   DEFAULT NULL,
    p_vendor_from                   IN      VARCHAR2 DEFAULT NULL,
    p_vendor_to                     IN      VARCHAR2 DEFAULT NULL,
    p_category_id                   IN      NUMBER   DEFAULT NULL,
    p_category_from                 IN      VARCHAR2 DEFAULT NULL,
    p_category_to                   IN      VARCHAR2 DEFAULT NULL,
    p_end_date                      IN      DATE,
    p_accrued_receipt               IN      VARCHAR2 DEFAULT NULL,
    p_online_accruals               IN      VARCHAR2 DEFAULT NULL,
    p_closed_pos                    IN      VARCHAR2 DEFAULT NULL,
    p_calling_api                   IN      NUMBER
);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Calculate_AccrualAmount
--   Type            : Private
--   Function        : The procedure calculates and returns the record for the
--                     CST_PER_END_ACCRUALS_TEMP
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version      NUMBER       Required
--     p_init_msg_list    VARCHAR2     Required
--     p_validation_level NUMBER       Required
--     p_service_flag     NUMBER       Required
--                                     1 for AMOUNT and 0 for QUANTITY
--                                     based
--     p_dist_qty         NUMBER       Required
--     p_shipment_qty     NUMBER       Required
--     p_end_date         DATE         Required
--     p_transaction_id   NUMBER       Optional         default NULL
--                                     rcv_transaction_id, in case this
--                                     is not NULL, all the calculations
--                                     to be done will be related to the
--                                     txn_id only.
--                                     The txn_id will be used for PAC period
--                                     end accrual procedure
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--     x_accrual_rec      CST_PER_END_ACCRUALS_TEMP%ROWTYPE
--
--   Version : Current version       1.0
--
-- End of comments
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
    p_transaction_id                IN      NUMBER DEFAULT NULL,

    x_accrual_rec                   IN OUT  NOCOPY CST_PER_END_ACCRUALS_TEMP%ROWTYPE
);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Calculate_AccrualAmount
--   Type            : Private
--   Function        : Procedure for PAC period end accrual process.
--                     The procedure will return accrual and encum quantities only
--                     This procedure will be used by the following programs:
--                      1. Periodic Period end accruals process
--                      2. Periodic Material and Receiving Distribution Report
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version      NUMBER       Required
--     p_init_msg_list    VARCHAR2     Required
--     p_validation_level NUMBER       Required
--     p_match_option     VARCHAR2     Required
--                                     'R' for match to receipt or
--                                     'P' for Match to PO
--     p_distribution_id  NUMBER       Required
--     p_shipment_id      NUMBER       Required
--     p_transaction_id   NUMBER       Required
--     p_service_flag     NUMBER       Required
--                                     1 for AMOUNT and 0 for QUANTITY
--                                     based
--     p_dist_qty         NUMBER       Required
--     p_shipment_qty     NUMBER       Required
--     p_end_date         DATE         Required
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--     x_accrual_qty      NUMBER
--     x_encum_qty        NUMBER
--
--   Version : Current version       1.0
--
-- End of comments
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
);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Get_RcvQuantity
--   Type            : Private
--   Function        : Returns the Net Quantity Received and net quantity
--                     delivered against a Shipment or against a Receipt
--
--                     net_qty_received = Quantity received
--                                       - return to vendor + corrections
--
--                     net_qty_delivered = Quantity delivered
--                                      - return to receiving + corrections
--
--                     The returned value will be in PO's UOM.
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version      NUMBER       Required
--     p_init_msg_list    VARCHAR2     Required
--     p_validation_level NUMBER       Required
--     p_line_location_id NUMBER       Optional         default NULL
--                                     Shipment id against which net quantity
--                                     received and delivered is to be calculated
--     p_rcv_shipment_id  NUMBER       Optional         default NULL
--                                     RCV Shipment id against which net quantity
--                                     received and delivered is to be calculated
--                                     in case of Match to Receipt cases
--     p_rcv_txn_id       NUMBER       Optional         default NULL
--                                     The txn_id will be used for PAC period
--                                     end accrual procedure
--     p_service_flag     NUMBER       Required
--     p_end_date         DATE         Required
--
--     Note: Both p_line_location_id and p_rcv_txn_id should not be NULL
--           at a time
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--     g_nqr              NUMBER
--     g_nqd              NUMBER
--     g_dist_nqd         NUMBER
--
--   Version : Current version       1.0
--
-- End of comments
-----------------------------------------------------------------------------
PROCEDURE Get_RcvQuantity
(
    p_api_version                   IN      NUMBER,
    p_init_msg_list                 IN      VARCHAR2,
    p_validation_level              IN      NUMBER,
    x_return_status                 OUT     NOCOPY VARCHAR2,
    x_msg_count                     OUT     NOCOPY NUMBER,
    x_msg_data                      OUT     NOCOPY VARCHAR2,

    p_line_location_id              IN      NUMBER DEFAULT NULL,
    p_rcv_shipment_id               IN      NUMBER DEFAULT NULL,
    p_rcv_txn_id                    IN      NUMBER DEFAULT NULL,
    p_service_flag                  IN      NUMBER,
    p_end_date                      IN      DATE
);

-----------------------------------------------------------------------------
-- Start of comments
--   API name        : Get_InvoiceQuantity
--   Type            : Private
--   Function        : Returns quantity invoiced against the distribution
--                     or the receipt.
--
--   Pre-reqs        : None.
--   Parameters      :
--   IN              :
--     p_api_version      NUMBER       Required
--     p_init_msg_list    VARCHAR2     Required
--     p_validation_level NUMBER       Required
--     p_match_option     VARCHAR2     Required
--                                     determines, whether to calculate quantity
--                                     invoiced against distribution or receive
--                                     transaction
--     p_dist_id          NUMBER       Required
--                                     Distribution_id against which net quantity
--                                     invoiced is to be calculated
--     p_rcv_txn_id       NUMBER       Optional         default NULL
--                                     The txn_id will be used for PAC period
--                                     end accrual procedure
--     p_service_flag     NUMBER       Required
--     p_end_date         DATE         Required
--
--   OUT             :
--     x_return_status    VARCHAR2
--     x_msg_count        NUMBER
--     x_msg_data         VARCHAR2
--     x_quantity_invoiced NUMBER
--
--   Version : Current version       1.0
--
-- End of comments
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
    p_rcv_txn_id                    IN      NUMBER DEFAULT NULL,
    p_service_flag                  IN      NUMBER,
    p_end_date                      IN      DATE,
    x_quantity_invoiced             OUT     NOCOPY NUMBER
);

END CST_PerEndAccruals_PVT;

/
