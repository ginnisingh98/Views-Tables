--------------------------------------------------------
--  DDL for Package PO_INVOICE_HOLD_CHECK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PO_INVOICE_HOLD_CHECK" AUTHID CURRENT_USER AS
        /* $Header: PO_INVOICE_HOLD_CHECK.pls 120.0.12010000.7 2009/08/04 09:39:39 ppadilam noship $ */
        /*#
        * Provide the information regarding Pay When Paid term to the caller.
        * This information would help in holding the related invoices.
        *
        * rep:scope public
        * rep:product PO
        * rep:displayname PO Payment Hold Check
        */

        /*#
        *   Description required
        * IN PARAMETERS
        *
        * param p_api_version p_api_version : Null not allowed. Value should match the
        * current version of the API (currently 1.0). Used by the API to
        * determine compatibility of API and calling program.
        * rep:paraminfo  {rep:required}
        *
        * param P_PO_HEADER_ID : po_header_id against which the invoice is being validated.
        * rep:paraminfo  {rep:required}
        * param P_INVOICE_ID : invoice_id that is being validated.
        * rep:paraminfo  {rep:required}
        *
        * OUT PARAMETERS
        *
        * param x_return_status
        * FND_API.G_RET_STS_SUCCESS if API succeeds
        * FND_API.G_RET_STS_ERROR if API fails
        * FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
        * rep:paraminfo  {rep:required}
        *
        * param x_msg_count
        * rep:paraminfo  {rep:required}
        *
        * param x_msg_data
        * rep:paraminfo  {rep:required}
        *
        * IN OUT PARAMETERS
        *
        * param x_pay_when_paid
        * Return 'Y' when the pay when paid on the PO is 'Yes', else return 'N'.
        * rep:paraminfo  {rep:required}
        *
        * rep:displayname PO Payment Hold Check
        *
        * rep:category BUSINESS_ENTITY PO_STANDARD_PURCHASE_ORDER
        *
        */
PROCEDURE PAY_WHEN_PAID(P_API_VERSION  IN NUMBER,
                        P_PO_HEADER_ID IN NUMBER,
                        P_INVOICE_ID IN NUMBER,
                        X_RETURN_STATUS OUT NOCOPY    VARCHAR2,
                        X_MSG_COUNT OUT NOCOPY        NUMBER,
                        X_MSG_DATA OUT NOCOPY         VARCHAR2,
                        X_PAY_WHEN_PAID IN OUT NOCOPY VARCHAR2);
        /*#
        *   Description required
        * IN PARAMETERS
        *
        * param p_api_version p_api_version : Null not allowed. Value should match the
        * current version of the API (currently 1.0). Used by the API to
        * determine compatibility of API and calling program.
        * rep:paraminfo  {rep:required}
        *
        * param P_PO_HEADER_ID : po_header_id against which the invoice is being validated.
        * rep:paraminfo  {rep:required}
        *
        * param P_INVOICE_ID : invoice_id that is being validated.
        * rep:paraminfo  {rep:required}
        *
        *
        * OUT PARAMETERS
        *
        * param x_return_status
        * FND_API.G_RET_STS_SUCCESS if API succeeds
        * FND_API.G_RET_STS_ERROR if API fails
        * FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
        * rep:paraminfo  {rep:required}
        *
        * param x_msg_count
        * rep:paraminfo  {rep:required}
        *
        * param x_msg_data
        * rep:paraminfo  {rep:required}
        *
        * IN OUT PARAMETERS
        *
        * param X_HOLD_REQUIRED
        * Return 'Y' when any attached contract deliverables are overdue, else 'N'.
        * rep:paraminfo  {rep:required}
        *
        * rep:displayname PO Payment Hold Check
        *
        * rep:category BUSINESS_ENTITY PO_STANDARD_PURCHASE_ORDER
        *
        */
PROCEDURE DELIVERABLE_OVERDUE_CHECK(P_API_VERSION  IN NUMBER,
                                    P_PO_HEADER_ID IN NUMBER,
                                    P_INVOICE_ID IN NUMBER,
                                    X_RETURN_STATUS OUT NOCOPY    VARCHAR2,
                                    X_MSG_COUNT OUT NOCOPY        NUMBER,
                                    X_MSG_DATA OUT NOCOPY         VARCHAR2,
                                    X_HOLD_REQUIRED IN OUT NOCOPY VARCHAR2);

 --------------------------------------------------------------------------------
  --Start of Comments
  --Name: DELIVERABLE_HOLD_CONTROL
  --Pre-reqs:
  --  None.
  --Modifies:
  --  None.
  --Locks:
  --  None.
  --Procedure:
  --  This procedure returns information about whether the 'Initiate Payment Holds'
  --  region should be rendered for the deliverables on a given Standard PO.
  --  It is called from Contracts at the time of rendering the Create/Update Deliverables Pg.
  --Parameters:
  --IN:
  --p_api_version
  --  Version number of API that caller expects. It
  --  should match the l_api_version defined in the
  --  procedure (expected value : 1.0)
  --p_po_header_id
  --  The header id of the Purchase Order.

  -- OUT PARAMETERS
  -- x_return_status
  --   FND_API.G_RET_STS_SUCCESS if API succeeds
  --   FND_API.G_RET_STS_ERROR if API fails
  --   FND_API.G_RET_STS_UNEXP_ERROR if unexpected error occurs
  -- x_msg_count
  -- x_msg_data
  --
  -- IN OUT PARAMETERS
  -- X_RENDER_DELIVERABLE_HOLD
  -- Return 'Y' when the Deliverable Hold Flag on the PO Style is 'Y' or pay when paid on the PO is 'Yes', else return 'N'.
  --End of Comments

 PROCEDURE DELIVERABLE_HOLD_CONTROL
       (P_API_VERSION    IN NUMBER,
        P_PO_HEADER_ID   IN NUMBER,
        X_RETURN_STATUS  OUT NOCOPY VARCHAR2,
        X_MSG_COUNT      OUT NOCOPY NUMBER,
        X_MSG_DATA       OUT NOCOPY VARCHAR2,
        X_RENDER_DELIVERABLE_HOLD  IN OUT NOCOPY VARCHAR2);

END PO_INVOICE_HOLD_CHECK;

/
