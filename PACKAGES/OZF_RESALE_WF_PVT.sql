--------------------------------------------------------
--  DDL for Package OZF_RESALE_WF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OZF_RESALE_WF_PVT" AUTHID CURRENT_USER AS
/* $Header: ozfvrwfs.pls 120.4 2005/09/15 00:29:25 appldev ship $ */

-- Package name     : OZF_RESALE_WF_PVT
-- Purpose          :
-- History          : CREATED       VANSUB      02-18-2004
--                  : MODIFICATIONS SLKRISHN    02-28-2004
-- NOTE             :
-- End of Comments

G_PKG_NAME                   CONSTANT VARCHAR2(30) := 'OZF_RESALE_WF_PVT';
G_FILE_NAME                  CONSTANT VARCHAR2(30) := 'ozfvrwfs.pls';

G_WF_ATTR_BATCH_ID           CONSTANT VARCHAR2(30) := 'OZF_RESALE_BATCH_ID';
G_WF_ATTR_BATCH_NUMBER       CONSTANT VARCHAR2(30) := 'OZF_BATCH_NUMBER';
G_WF_ATTR_ERROR_MESG         CONSTANT VARCHAR2(30) := 'OZF_ERROR_MESSAGE';
G_WF_ATTR_BATCH_TYPE         CONSTANT VARCHAR2(30) := 'OZF_RESALE_BATCH_TYPE';
G_WF_ATTR_BATCH_STATUS       CONSTANT VARCHAR2(30) := 'OZF_RESALE_BATCH_STATUS';
G_WF_ATTR_BATCH_CALLER       CONSTANT VARCHAR2(30) := 'OZF_RESALE_BATCH_CALLER';
G_WF_ATTR_WF_ADMINISTRATOR   CONSTANT VARCHAR2(30) := 'WF_ADMINISTRATOR';
G_WF_ATTR_BATCH_NUM_W_DATE   CONSTANT VARCHAR2(30) := 'OZF_BATCH_NUM_W_DATE';

G_WF_LKUP_CHARGEBACK         CONSTANT VARCHAR2(30) := 'CHARGEBACK';
G_WF_LKUP_SPECIALPRICE       CONSTANT VARCHAR2(30) := 'SHIP_DEBIT';
G_WF_LKUP_TRACING            CONSTANT VARCHAR2(30) := 'TRACING';

G_WF_LKUP_UI                 CONSTANT VARCHAR2(30) := 'UI';
G_WF_LKUP_WEBADI             CONSTANT VARCHAR2(30) := 'WEBADI';
G_WF_LKUP_XML                CONSTANT VARCHAR2(30) := 'XML';

G_WF_LKUP_PENDING_PAYMENT    CONSTANT VARCHAR2(30) := 'PENDING_PAYMENT';
G_WF_LKUP_PROCESSING         CONSTANT VARCHAR2(30) := 'PROCESSING';

G_WF_LKUP_ERROR              CONSTANT VARCHAR2(30) := 'ERROR';
G_WF_LKUP_SUCCESS            CONSTANT VARCHAR2(30) := 'SUCCESS';

CURSOR g_batch_type_csr (p_id NUMBER)IS
  SELECT batch_type
  FROM ozf_resale_batches_all
  WHERE resale_batch_id = p_id;


---------------------------------------------------------------------
-- PROCEDURE
--    Check_Duplicates
--
-- PURPOSE
--    This procedure checks whether there is any duplicated lines in
--    the batch.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Check_Duplicates(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Auto_Accrual_Flag
--
-- PURPOSE
--    This procedure returns values of auto_tp_accrual_flag from system parameter
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Auto_Accrual_Flag(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Batch_Caller
--
-- PURPOSE
--    This procedure returns the value of OZF_RESALE_BATCH_CALLER
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Batch_Caller(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Batch_Status
--
-- PURPOSE
--    This procedure returns the value of batch status
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Batch_Status (
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Get_Batch_Type
--
-- PURPOSE
--    This procedure returns the value of OZF_RESALE_BATCH_TYPE
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Get_Batch_Type(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Init_attributes
--
-- PURPOSE
--    This api will be initialize the attributes used IN the workflow
--
---------------------------------------------------------------------
PROCEDURE Init_Attributes(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   result                    OUT NOCOPY VARCHAR2
) ;

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment
--
-- PURPOSE
--    This procedure inities payment processing
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Initiate_Payment (
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment_chargeback
--
-- PURPOSE
--    This procedure inities payment processing for chargeback
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Initiate_Payment_Chargeback (
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment_SPP
--
-- PURPOSE
--    This procedure inities payment processing for special pricing
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Initiate_Payment_SPP(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Initiate_Payment_Tracing
--
-- PURPOSE
--    This procedure inities payment processing for tracing order
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE  Initiate_Payment_Tracing (
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Chargeback
--
-- PURPOSE
--    This procedure initiates processing of orders for chargeback
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Chargeback(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Resale
--
-- PURPOSE
--    This procedure initiates third party accrual process for resale data
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Resale(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Special_Pricing
--
-- PURPOSE
--    This procedure initiates processing of orders for Special_Pricing
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Special_Pricing(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Process_Tracing
--
-- PURPOSE
--    This procedure initiates processing of orders for tracing data.
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Process_Tracing(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Reset_Status
--
-- PURPOSE
--    This procedure is to reset the status of a batch in case of exceptions
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Reset_Status(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   result                    OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Set_Batch_Status
--
-- PURPOSE
--    This procedure set the batch status
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Set_Batch_Status(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Set_Payment_Pending
--
-- PURPOSE
--    This procedure set the batch status to Payment_Pending
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Set_Payment_Pending(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Set_Tolerance_Level
--
-- PURPOSE
--    This procedure set the batch status
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Set_Tolerance_Level(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Batch
--
-- PURPOSE
--    This procedure validates the batch details
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Validate_Batch(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Order
--
-- PURPOSE
--    This procedure contains order level validations
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Validate_Order(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Chargeback
--
-- PURPOSE
--    This procedure contains chargeback validations
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Validate_Chargeback (
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Special_Pricing
--
-- PURPOSE
--    This procedure contains Special Pricing data validations
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Validate_Special_Pricing(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Validate_Tracing
--
-- PURPOSE
--    This procedure contains tracing data validations
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Validate_Tracing(
   itemtype                  IN VARCHAR2,
   itemkey                   IN VARCHAR2,
   actid                     IN NUMBER,
   funcmode                  IN VARCHAR2,
   resultout                 IN OUT NOCOPY VARCHAR2
);


---------------------------------------------------------------------
-- PROCEDURE
--    Start_Data_Process
--
-- PURPOSE
--
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_Data_Process(
    p_resale_batch_id       IN  NUMBER
   ,p_caller_type           IN  VARCHAR2
);

---------------------------------------------------------------------
-- PROCEDURE
--    Start_Data_Process
--
-- PURPOSE
--
--
-- PARAMETERS
--
--
-- NOTES
---------------------------------------------------------------------
PROCEDURE Start_Batch_Payment(
    p_resale_batch_id       IN  NUMBER
   ,p_caller_type           IN  VARCHAR2
);


END OZF_RESALE_WF_PVT;

 

/
