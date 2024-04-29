--------------------------------------------------------
--  DDL for Package FUN_INITIATOR_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FUN_INITIATOR_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: funwints.pls 120.3 2004/11/10 06:04:59 panaraya noship $ */

-- The record type for AR transfer

TYPE AR_interface_line IS RECORD(
     AMOUNT NUMBER,
     BATCH_SOURCE_NAME Varchar2(50),  -- <bug 3450031>
     CONVERSION_TYPE Varchar2(30),
     CURRENCY_CODE Varchar2(15),
     CUSTOMER_TRX_TYPE_ID Number,  --CUSTOMER_TRX_TYPE_ID
     DESCRIPTION Varchar2(240),
     GL_DATE Date,
     INTERFACE_LINE_ATTRIBUTE1 Varchar2(30),
     INTERFACE_LINE_ATTRIBUTE2 Varchar2(30),
     INTERFACE_LINE_ATTRIBUTE3 Varchar2(30),
     INTERFACE_LINE_CONTEXT Varchar2(30),   -- <bug 3450031>
     LINE_TYPE Varchar2(20) ,
     MEMO_LINE_ID Number,
     ORG_ID Number,
     ORIG_SYSTEM_BILL_ADDRESS_ID Number,
     ORIG_SYSTEM_BILL_CUSTOMER_ID Number,
     SET_OF_BOOKS_ID Number,
     TRX_DATE Date,
     UOM_NAME Varchar2(25)
     );

TYPE AR_interface_Dist_line IS RECORD(
     ACCOUNT_CLASS RA_CUST_TRX_LINE_GL_DIST_ALL.account_class%TYPE,
     -- <bug 3450031>
     AMOUNT NUMBER,
     percent RA_CUST_TRX_LINE_GL_DIST_ALL.percent%TYPE,  -- <bug 3450031>
     CODE_COMBINATION_ID Number,
     INTERFACE_LINE_ATTRIBUTE1 Varchar2(30),
     INTERFACE_LINE_ATTRIBUTE2 Varchar2(30),
     INTERFACE_LINE_ATTRIBUTE3 Varchar2(30),
     INTERFACE_LINE_CONTEXT Varchar2(30),  -- <bug 3450031>
     ORG_ID Number
     );



 -- Set workflow item attributes for the process

   PROCEDURE SET_ATTRIBUTES   (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT NOCOPY  VARCHAR2);


   -- Update transaction Status

  PROCEDURE UPDATE_STATUS     (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT  NOCOPY VARCHAR2);


 -- Transfer the transaction to AR interface tables

   PROCEDURE TRANSFER_AR      (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT NOCOPY  VARCHAR2);


 -- Check AR setup

   PROCEDURE CHECK_AR_SETUP   (itemtype           IN VARCHAR2,
                               itemkey            IN VARCHAR2,
                               actid              IN NUMBER,
                               funcmode           IN VARCHAR2,
                               resultout          OUT NOCOPY VARCHAR2);

  -- The function that subscribles to AR autoinvoice event:
  --    oracle.apps.ar.batch.AutoInvoice.run

   FUNCTION GET_INVOICE (p_subscription_guid IN RAW,
                         p_event             IN OUT NOCOPY WF_EVENT_T)
                         return Varchar2;


  -- This function generate the event key (random)

   FUNCTION GENERATE_KEY (p_batch_id in Number,
                          p_trx_id in  NUMBER)
                         return Varchar2;


    ---------------------------------------------------------------------------
    --Start of Comments
    --Function:
    --  After transactions are interfaced to AR and invoices have been created,
    --  FUN_TRX_HEADERS.ar_invoice_number will be updated with the corresonding
    --  AR_CUSTOMER_TRX_ALL.trx_number
    --End of Comments
    ---------------------------------------------------------------------------

    PROCEDURE update_trx_headers(p_request_id IN NUMBER);


    ---------------------------------------------------------------------------
    --Start of Comments
    --Function:
    --  After transactions are interfaced to AR and invoices have been created,
    --  it will get AR invoice number based on autoinvice conc. program
    --  request_id, and then FUN_TRX_HEADERS.ar_invoice_number will be updated
    --  with the corresonding AR invoice number
    --End of Comments
    ---------------------------------------------------------------------------

    PROCEDURE post_ar_invoice(
        itemtype    IN varchar2,
        itemkey     IN varchar2,
        actid       IN number,
        funcmode    IN varchar2,
        resultout   IN OUT NOCOPY varchar2);

END FUN_INITIATOR_WF_PKG;


 

/
