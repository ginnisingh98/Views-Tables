--------------------------------------------------------
--  DDL for Package AP_FUNDS_CONTROL_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AP_FUNDS_CONTROL_PKG" AUTHID CURRENT_USER AS
/* $Header: aprfunds.pls 120.11.12010000.2 2009/08/05 21:23:44 serabell ship $ */


/*=============================================================================
 | Global variable Spec
 *===========================================================================*/
    g_debug_mode                     VARCHAR2(1):= 'N';

    --Invoice Lines: Distributions, Added the Index by binary integer clause
    TYPE Key_Value_Tab_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    TYPE Funds_Dist_Tab_Type IS TABLE OF PSA_AP_BC_PVT.Funds_Dist_Rec
        INDEX BY BINARY_INTEGER;


/*=============================================================================
 |Public Procedure Specification
 *===========================================================================*/

PROCEDURE Funds_Reserve(
              p_calling_mode          IN            VARCHAR2 DEFAULT 'APPROVE',
              p_invoice_id            IN            NUMBER,
              p_set_of_books_id       IN            NUMBER,
              p_base_currency_code    IN            VARCHAR2,
              p_conc_flag             IN            VARCHAR2,
              p_system_user           IN            NUMBER,
              p_holds                 IN OUT NOCOPY AP_APPROVAL_PKG.HOLDSARRAY,
              p_hold_count            IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_release_count         IN OUT NOCOPY AP_APPROVAL_PKG.COUNTARRAY,
              p_funds_return_code     OUT NOCOPY    VARCHAR2,
              p_calling_sequence      IN            VARCHAR2);

--ETAX: Validation
PROCEDURE GET_ERV_CCID(
              p_sys_xrate_gain_ccid       IN            NUMBER,
              p_sys_xrate_loss_ccid       IN            NUMBER,
              p_dist_ccid                 IN            NUMBER,
              p_variance_ccid             IN            NUMBER,
              p_destination_type          IN            VARCHAR2,
              p_inv_distribution_id       IN            NUMBER,
              p_related_id                IN            NUMBER,
              p_erv                       IN            NUMBER,
              p_erv_ccid                  IN OUT NOCOPY NUMBER,
              p_calling_sequence          IN            VARCHAR2);

--procedure added for bug 8733916

PROCEDURE Encum_Unprocessed_Events_Del
(
  p_invoice_id IN NUMBER,
  p_calling_sequence IN VARCHAR2 DEFAULT NULL
);


PROCEDURE Calc_QV(
              p_invoice_id          IN            NUMBER,
              p_po_dist_id          IN            NUMBER,
              p_inv_currency_code   IN            VARCHAR2,
              p_base_currency_code  IN            VARCHAR2,
              p_po_price            IN            NUMBER,
              p_po_qty              IN            NUMBER,
              p_match_option        IN            VARCHAR2,
              p_po_uom              IN            VARCHAR2,
              p_item_id             IN            NUMBER,
              p_qv                  IN OUT NOCOPY NUMBER,
              p_bqv                 IN OUT NOCOPY NUMBER,
              p_update_line_num     IN OUT NOCOPY NUMBER,
              p_update_dist_num     IN OUT NOCOPY NUMBER,
              p_calling_sequence    IN            VARCHAR2);

PROCEDURE Calc_AV(
              p_invoice_id          IN            NUMBER,
              p_po_dist_id          IN            NUMBER,
              p_inv_currency_code   IN            VARCHAR2,
              p_base_currency_code  IN            VARCHAR2,
              p_po_amt              IN            NUMBER,
              p_av                  IN OUT NOCOPY NUMBER,
              p_bav                 IN OUT NOCOPY NUMBER,
              p_update_line_num     IN OUT NOCOPY NUMBER,
              p_update_dist_num     IN OUT NOCOPY NUMBER,
              p_calling_sequence    IN            VARCHAR2);

PROCEDURE Funds_Check(
              p_invoice_id           IN            NUMBER,
              p_inv_line_num         IN            NUMBER,
              p_dist_line_num        IN            NUMBER,
              p_return_message_name  IN OUT NOCOPY VARCHAR2,
              p_calling_sequence     IN            VARCHAR2);

FUNCTION Funds_Check_Processor (
              P_Invoice_Id  IN NUMBER,
              P_Invoice_Line_Number IN NUMBER,
              p_dist_line_num  IN NUMBER,
              P_Invoice_Needs_Validation IN VARCHAR2,
              P_Error_Code OUT NOCOPY VARCHAR2,
              P_Token1     OUT NOCOPY NUMBER,
              P_Calling_Sequence IN VARCHAR2) RETURN BOOLEAN;

END AP_FUNDS_CONTROL_PKG;

/
