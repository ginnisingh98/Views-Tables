--------------------------------------------------------
--  DDL for Package Body OKE_DELIVERABLE_BILLING_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DELIVERABLE_BILLING_PVT" AS
/* $Header: OKEVDVBB.pls 120.6.12010000.3 2008/11/21 09:40:28 aveeraba ship $ */

--
-- Private Global Variables
--
 G_Pkg_Name       VARCHAR2(30) := 'OKE_DELIVERABLE_BILLING_PVT';
 g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_deliverable_billing_pvt.';

--
-- Private Global Cursors
--
-- Cursor to get Billing Information from deliverable
--
CURSOR BillInfo ( C_Event_ID  NUMBER ) IS
  SELECT b.billing_event_id
  ,      b.deliverable_id
  , 	 b.pa_event_id
  ,      b.bill_project_id
  ,      b.bill_task_id
  ,      b.bill_event_type
  ,      b.bill_event_date
  ,      b.bill_description
  ,      b.bill_unit_price
  ,      b.bill_quantity
  ,      d.uom_code
  ,      b.bill_currency_code
  ,      (b.bill_unit_price * b.bill_quantity)  bill_amount
  ,      b.revenue_amount
  ,      b.k_header_id
  ,      b.bill_line_id
  ,      b.bill_chg_req_id
  ,      b.bill_organization_id
  ,      b.bill_item_id
  ,      d.inventory_org_id
  ,      b.bill_fund_ref1
  ,      b.bill_fund_ref2
  ,      b.bill_fund_ref3
  ,      b.bill_bill_of_lading
  ,      b.bill_serial_num
  FROM   oke_k_deliverables_b d, oke_k_billing_events b
  WHERE  b.billing_event_id = C_Event_ID
  AND    d.deliverable_id = b.deliverable_id;

--
-- Cursor to get Event Number
--
CURSOR NextEventNum ( C_Proj_ID NUMBER , C_Task_ID NUMBER ) IS
  SELECT NVL(MAX(Event_Num) , 0) + 1
  FROM pa_events
  WHERE Project_ID = C_Proj_ID
  AND Nvl(Task_ID,-1)= NVL(C_Task_ID,-1);

--
-- Cursor to get Contract Number and Order Number
--
CURSOR ContractNum ( C_Header_ID NUMBER ) IS
  SELECT CH2.Contract_Number
  ,      DECODE( CH2.ID , CH.ID , NULL , CH.Contract_Number )
  FROM   okc_k_headers_b ch
  ,      okc_k_headers_b ch2
  ,      oke_k_headers   eh
  WHERE  ch.id = C_Header_ID
  AND    ch.id = eh.k_header_id
  AND    ch2.id = nvl( eh.boa_id , eh.k_header_id );

--
-- Cursor to get Contract Line Number
--
CURSOR LineNum ( C_Line_ID NUMBER ) IS
  SELECT Line_Number
  FROM   okc_k_lines_b
  WHERE  id = C_Line_ID;

--
-- Cursor to get Change Request Number
--
CURSOR ChgReqNum ( C_ChgReq_ID NUMBER ) IS
  SELECT Chg_Request_Num
  FROM   oke_chg_requests
  WHERE  chg_request_id = C_ChgReq_ID;

--
-- Private Procedures and Functions
--

--
-- Function to return event level of the current project
--
FUNCTION Event_Level
( P_Project_ID     IN     NUMBER
, P_Event_ID       IN     NUMBER
) RETURN VARCHAR2 IS

CURSOR c IS
  SELECT DECODE(task_id , NULL , 'PROJECT' , 'TASK')
  FROM   pa_events
  WHERE  project_id = P_Project_ID
  AND    event_id <> P_Event_ID;
Dummy  VARCHAR2(10) := NULL;

BEGIN
  OPEN c;
  FETCH c INTO Dummy;
  IF ( c%notfound ) THEN
    CLOSE c;
    RETURN ( 'ANY' );
  END IF;
  CLOSE c;
  RETURN ( Dummy );
END Event_Level;


--
-- Procedure to update event references in PA
--
PROCEDURE Update_Event_References
( P_Event_ID                   IN      NUMBER
, P_Contract_Num               IN      VARCHAR2
, P_Order_Num                  IN      VARCHAR2
, P_Line_Num                   IN      VARCHAR2
, P_Chg_Req_Num                IN      VARCHAR2
, P_Item_ID                    IN      NUMBER
, P_Org_ID                     IN      NUMBER
, P_Unit_Price                 IN      NUMBER
, P_UOM                        IN      VARCHAR2
, P_Bill_Quantity              IN      NUMBER
, P_Bill_Of_Lading             IN      VARCHAR2
, P_Serial_Num                 IN      VARCHAR2
, P_Fund_Ref1                  IN      VARCHAR2
, P_Fund_Ref2                  IN      VARCHAR2
, P_Fund_Ref3                  IN      VARCHAR2
) IS
l_api_name                   CONSTANT VARCHAR2(30) := ' Update_Event_References';
BEGIN

IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Updating event reference...');
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Event ID = ' || P_Event_ID);
END IF;
  UPDATE pa_events
  SET quantity_billed         = P_Bill_Quantity
  ,   uom_code                = P_UOM
  ,   inventory_org_id        = P_Org_ID
  ,   inventory_item_id       = P_Item_ID
  ,   unit_price              = P_Unit_Price
  ,   reference1              = P_Contract_Num
  ,   reference2              = P_Order_Num
  ,   reference3              = P_Line_Num
  ,   reference4              = P_Chg_Req_Num
  ,   reference5              = P_Fund_Ref1
  ,   reference6              = P_Fund_Ref2
  ,   reference7              = P_Fund_Ref3
  ,   reference8              = P_Bill_Of_Lading
  ,   reference9              = P_Serial_Num
  ,   reference10             = 'OKE'
  WHERE event_id = P_Event_ID;

END Update_Event_References;

--
-- Procedure to revert billed event in PA
--
PROCEDURE Revert_Billing_Event
( P_Event_ID                   IN      NUMBER
, P_Event_Date                 IN      DATE
) IS
l_api_name                   CONSTANT VARCHAR2(30) := 'Revert_Billing_Event';
  L_Event_ID       NUMBER;
  L_Event_Num      NUMBER;
  L_RowID          VARCHAR2(18);
  L_UserID         NUMBER := FND_GLOBAL.User_ID;
  L_LoginID        NUMBER := FND_GLOBAL.Login_ID;

  CURSOR EventInfo ( C_Event_ID  NUMBER ) IS
    SELECT project_id
    ,      task_id
    ,      organization_id
    ,      event_num
    ,      event_type
    ,      description
    ,      bill_amount
    ,      revenue_amount
    ,      quantity_billed
    ,      uom_code
    ,      inventory_org_id
    ,      inventory_item_id
    ,      unit_price
    ,      reference1
    ,      reference2
    ,      reference3
    ,      reference4
    ,      reference5
    ,      reference6
    ,      reference7
    ,      reference8
    ,      reference9
    ,      Bill_Trans_Currency_Code
    ,      Bill_Trans_Bill_Amount
    ,	   Bill_Trans_rev_Amount
    ,      Project_Currency_Code
    ,      Project_Rate_Type
    ,      Project_Rate_Date
    ,      Project_Exchange_Rate
    ,      Project_Inv_Rate_Date
    ,      Project_Inv_Exchange_Rate
    ,      Project_Bill_Amount
    ,      Project_Rev_Rate_Date
    ,      Project_Rev_Exchange_Rate
    ,      Project_Revenue_Amount
    ,      ProjFunc_Currency_Code
    ,      ProjFunc_Rate_Type
    ,      ProjFunc_Rate_Date
    ,      ProjFunc_Exchange_Rate
    ,      ProjFunc_Inv_Rate_Date
    ,      ProjFunc_Inv_Exchange_Rate
    ,      ProjFunc_Bill_Amount
    ,      ProjFunc_Rev_Rate_Date
    ,      Projfunc_Rev_Exchange_Rate
    ,      ProjFunc_Revenue_Amount
    ,      Funding_Rate_Type
    ,      Funding_Rate_Date
    ,      Funding_Exchange_Rate
    ,      Invproc_Currency_Code
    ,      Invproc_Rate_Type
    ,      Invproc_Rate_Date
    ,      Invproc_Exchange_Rate
    ,      Revproc_Currency_Code
    ,      Revproc_Rate_Type
    ,      Revproc_Rate_Date
    ,      Revproc_Exchange_Rate
    ,      Inv_Gen_Rejection_Code
    FROM   pa_events
    WHERE  event_id = C_Event_ID;
  EvInfoRec    EventInfo%rowtype;

  CURSOR EventID IS
    SELECT pa_events_s.nextval
    FROM   dual;

BEGIN

  OPEN EventInfo ( P_Event_ID );
  FETCH EventInfo INTO EvInfoRec;
  CLOSE EventInfo;

  OPEN NextEventNum ( EvInfoRec.Project_ID
                    , EvInfoRec.Task_ID );
  FETCH NextEventNum INTO L_Event_Num;
  CLOSE NextEventNum;

  OPEN EventID;
  FETCH EventID INTO L_Event_ID;
  CLOSE EventID;

  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Reversal Event ID = ' || L_Event_ID);
         FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Reversal Event Num = ' || L_Event_Num);
  END IF;

  PA_EVENTS_PKG.Insert_Row
  ( X_ROWID                      => L_RowID
  , X_EVENT_ID                   => L_Event_ID
  , X_TASK_ID                    => EvInfoRec.Task_ID
  , X_EVENT_NUM                  => L_Event_Num
  , X_LAST_UPDATE_DATE           => sysdate
  , X_LAST_UPDATED_BY            => L_UserID
  , X_CREATION_DATE              => sysdate
  , X_CREATED_BY                 => L_UserID
  , X_LAST_UPDATE_LOGIN          => L_LoginID
  , X_EVENT_TYPE                 => EvInfoRec.Event_Type
  , X_DESCRIPTION                => EvInfoRec.Description
  , X_BILL_AMOUNT                => (-1) * EvInfoRec.Bill_Amount
  , X_REVENUE_AMOUNT             => (-1) * EvInfoRec.Revenue_Amount
  , X_REVENUE_DISTRIBUTED_FLAG   => 'N'
  , X_BILL_HOLD_FLAG             => 'N'
  , X_COMPLETION_DATE            => P_Event_Date
  , X_REV_DIST_REJECTION_CODE    => NULL
  , X_ATTRIBUTE_CATEGORY         => NULL
  , X_ATTRIBUTE1                 => NULL
  , X_ATTRIBUTE2                 => NULL
  , X_ATTRIBUTE3                 => NULL
  , X_ATTRIBUTE4                 => NULL
  , X_ATTRIBUTE5                 => NULL
  , X_ATTRIBUTE6                 => NULL
  , X_ATTRIBUTE7                 => NULL
  , X_ATTRIBUTE8                 => NULL
  , X_ATTRIBUTE9                 => NULL
  , X_ATTRIBUTE10                => NULL
  , X_PROJECT_ID                 => EvInfoRec.Project_ID
  , X_ORGANIZATION_ID            => EvInfoRec.Organization_ID
  , X_BILLING_ASSIGNMENT_ID      => NULL
  , X_EVENT_NUM_REVERSED         => EvInfoRec.Event_Num
  , X_CALLING_PLACE              => NULL
  , X_CALLING_PROCESS            => NULL
  , X_Bill_Trans_Currency_Code	 => EvInfoRec.Bill_Trans_Currency_Code
  , X_Bill_Trans_Bill_Amount 	 => EvInfoRec.Bill_Trans_Bill_Amount
  , X_Bill_Trans_rev_Amount	 => EvInfoRec.Bill_Trans_rev_Amount
  , X_Project_Currency_Code	 => EvInfoRec.Project_Currency_Code
  , X_Project_Rate_Type		 => EvInfoRec.Project_Rate_Type
  , X_Project_Rate_Date		 => EvInfoRec.Project_Rate_Date
  , X_Project_Exchange_Rate	 => EvInfoRec.Project_Exchange_Rate
  , X_Project_Inv_Rate_Date	 => EvInfoRec.Project_Inv_Rate_Date
  , X_Project_Inv_Exchange_Rate  => EvInfoRec.Project_Inv_Exchange_Rate
  , X_Project_Bill_Amount	 => EvInfoRec.Project_Bill_Amount
  , X_Project_Rev_Rate_Date	 => EvInfoRec.Project_Rev_Rate_Date
  , X_Project_Rev_Exchange_Rate	 => EvInfoRec.Project_Rev_Exchange_Rate
  , X_Project_Revenue_Amount 	 => EvInfoRec.Project_Revenue_Amount
  , X_ProjFunc_Currency_Code 	 => EvInfoRec.ProjFunc_Currency_Code
  , X_ProjFunc_Rate_Type	 => EvInfoRec.ProjFunc_Rate_Type
  , X_ProjFunc_Rate_Date	 => EvInfoRec.ProjFunc_Rate_Date
  , X_ProjFunc_Exchange_Rate 	 => EvInfoRec.ProjFunc_Exchange_Rate
  , X_ProjFunc_Inv_Rate_Date 	 => EvInfoRec.ProjFunc_Inv_Rate_Date
  , X_ProjFunc_Inv_Exchange_Rate => EvInfoRec.ProjFunc_Inv_Exchange_Rate
  , X_ProjFunc_Bill_Amount	 => EvInfoRec.ProjFunc_Bill_Amount
  , X_ProjFunc_Rev_Rate_Date 	 => EvInfoRec.ProjFunc_Rev_Rate_Date
  , X_Projfunc_Rev_Exchange_Rate => EvInfoRec.Projfunc_Rev_Exchange_Rate
  , X_ProjFunc_Revenue_Amount	 => EvInfoRec.ProjFunc_Revenue_Amount
  , X_Funding_Rate_Type		 => EvInfoRec.Funding_Rate_Type
  , X_Funding_Rate_Date		 => EvInfoRec.Funding_Rate_Date
  , X_Funding_Exchange_Rate	 => EvInfoRec.Funding_Exchange_Rate
  , X_Invproc_Currency_Code	 => EvInfoRec.Invproc_Currency_Code
  , X_Invproc_Rate_Type		 => EvInfoRec.Invproc_Rate_Type
  , X_Invproc_Rate_Date		 => EvInfoRec.Invproc_Rate_Date
  , X_Invproc_Exchange_Rate	 => EvInfoRec.Invproc_Exchange_Rate
  , X_Revproc_Currency_Code	 => EvInfoRec.Revproc_Currency_Code
  , X_Revproc_Rate_Type		 => EvInfoRec.Revproc_Rate_Type
  , X_Revproc_Rate_Date		 => EvInfoRec.Revproc_Rate_Date
  , X_Revproc_Exchange_Rate	 => EvInfoRec.Revproc_Exchange_Rate
  , X_Inv_Gen_Rejection_Code 	 => EvInfoRec.Inv_Gen_Rejection_Code
  , X_Product_code               => 'OKE'
  , X_Event_reference            => L_Event_ID
  );

  Update_Event_References
  ( P_Event_ID                   => L_Event_ID
  , P_Contract_Num               => EvInfoRec.reference1
  , P_Order_Num                  => EvInfoRec.reference2
  , P_Line_Num                   => EvInfoRec.reference3
  , P_Chg_Req_Num                => EvInfoRec.reference4
  , P_Item_ID                    => EvInfoRec.Inventory_Item_ID
  , P_Org_ID                     => EvInfoRec.Inventory_Org_ID
  , P_Unit_Price                 => EvInfoRec.Unit_Price
  , P_UOM                        => EvInfoRec.UOM_Code
  , P_Bill_Quantity              => (-1) * EvInfoRec.Quantity_Billed
  , P_Bill_Of_Lading             => EvInfoRec.reference8
  , P_Serial_Num                 => EvInfoRec.reference9
  , P_Fund_Ref1                  => EvInfoRec.reference5
  , P_Fund_Ref2                  => EvInfoRec.reference6
  , P_Fund_Ref3                  => EvInfoRec.reference7
  );

END Revert_Billing_Event;

--
-- Public Functions and Procedures
--

--
--  Name          : Create_Billing_Event
--  Pre-reqs      : None
--  Function      : This procedure creates a billing event in PA
--
--
--  Parameters    :
--  IN            : P_Commit
--                  P_Event_ID
--  OUT           : X_Event_ID
--                  X_Event_Num
--                  X_Return_Status
--                  X_Msg_Count
--                  X_Msg_Data
--
--  Returns       : None
--

PROCEDURE Create_Billing_Event
( P_Commit                     IN      VARCHAR2
, P_Event_ID                   IN      NUMBER
, X_Event_ID                   OUT     NOCOPY		NUMBER
, X_Event_Num                  OUT     NOCOPY           NUMBER
, X_Return_Status              OUT     NOCOPY           VARCHAR2
, X_Msg_Count                  OUT     NOCOPY           NUMBER
, X_Msg_Data                   OUT     NOCOPY           VARCHAR2
) IS

  BillInfoRec      BillInfo%rowtype;
  L_Event_ID       NUMBER;
  L_Contract_Num   VARCHAR2(120);
  L_Order_Num      VARCHAR2(120);
  L_Line_Num       VARCHAR2(150);
  L_ChgReq_Num     VARCHAR2(30);
  L_Result	   VARCHAR2(1);


  CURSOR C(P_ID NUMBER) IS
  SELECT 'X'FROM PA_EVENTS
  WHERE EVENT_ID = P_ID;

  L_Bill_Trans_Currency_Code        VARCHAR2(15);
  L_Bill_Trans_Bill_Amount          NUMBER;
  L_Bill_Trans_rev_Amount           NUMBER;
  L_Project_Currency_Code           VARCHAR2(15);
  L_Project_Rate_Type	            VARCHAR2(30);
  L_Project_Rate_Date	            DATE;
  L_Project_Exchange_Rate           NUMBER;
  L_Project_Inv_Rate_Date           DATE;
  L_Project_Inv_Exchange_Rate       NUMBER;
  L_Project_Bill_Amount	            NUMBER;
  L_Project_Rev_Rate_Date           DATE;
  L_Project_Rev_Exchange_Rate       NUMBER;
  L_Project_Revenue_Amount          NUMBER;
  L_ProjFunc_Currency_Code          VARCHAR2(15);
  L_ProjFunc_Rate_Type              VARCHAR2(30);
  L_ProjFunc_Rate_Date              DATE;
  L_ProjFunc_Exchange_Rate          NUMBER;
  L_ProjFunc_Inv_Rate_Date          DATE;
  L_ProjFunc_Inv_Exchange_Rate      NUMBER;
  L_ProjFunc_Bill_Amount            NUMBER;
  L_ProjFunc_Rev_Rate_Date          DATE;
  L_Projfunc_Rev_Exchange_Rate      NUMBER;
  L_ProjFunc_Revenue_Amount         NUMBER;
  L_Funding_Rate_Type               VARCHAR2(30);
  L_Funding_Rate_Date               DATE;
  L_Funding_Exchange_Rate           NUMBER;
  L_Invproc_Currency_Code           VARCHAR2(15);
  L_Invproc_Rate_Type               VARCHAR2(30);
  L_Invproc_Rate_Date               DATE;
  L_Invproc_Exchange_Rate           NUMBER;
  L_Revproc_Currency_Code           VARCHAR2(15);
  L_Revproc_Rate_Type               VARCHAR2(30);
  L_Revproc_Rate_Date               DATE;
  L_Revproc_Exchange_Rate           NUMBER;
  L_Inv_Gen_Rejection_Code          VARCHAR2(30);


l_api_name             CONSTANT VARCHAR2(30) := 'Create_Billing_Event';
BEGIN
IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Creating Billing Event ...');
END IF;
  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT create_billing_event;

  --
  -- First fetch billing information from deliverable
  --
  OPEN BillInfo ( P_Event_ID );
  FETCH BillInfo INTO BillInfoRec;
  CLOSE BillInfo;

  --
  -- Next fetch various reference information
  --
  OPEN ContractNum ( BillInfoRec.K_Header_ID );
  FETCH ContractNum INTO L_Contract_Num , L_Order_Num;
  CLOSE ContractNum;

  OPEN LineNum ( BillInfoRec.Bill_Line_ID );
  FETCH LineNum INTO L_Line_Num;
  CLOSE LineNum;

  OPEN ChgReqNum ( BillInfoRec.Bill_Chg_Req_ID );
  FETCH ChgReqNum INTO L_ChgReq_Num;
  CLOSE ChgReqNum;

  --
  -- Validations
  --
  -- 1. Make sure billing event level is consistent with previous
  --    events
  --
  IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Check Previous Event Level');
  END IF;

  IF (   Event_Level( BillInfoRec.Bill_Project_ID
                    , BillInfoRec.Pa_Event_ID ) = 'PROJECT'
     AND BillInfoRec.Bill_Task_ID IS NOT NULL ) THEN
    FND_MESSAGE.set_name('PA' , 'PA_PR_EPR_EVENTS_AT_PROJ_LVL');
    FND_MSG_PUB.add;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
  END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Event Type = ' || BillInfoRec.Bill_Event_Type);
 END IF;

  IF ( BillInfoRec.Bill_Event_Type IS NULL ) THEN
    fnd_message.set_name('OKE' , 'OKE_API_MISSING_VALUE');
    fnd_message.set_token('VALUE' , 'BILL_EVENT_TYPE');
    FND_MSG_PUB.add;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
  END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Description = ' || BillInfoRec.Bill_Description);
 END IF;

  IF ( BillInfoRec.Bill_Description IS NULL ) THEN
    fnd_message.set_name('OKE' , 'OKE_API_MISSING_VALUE');
    fnd_message.set_token('VALUE' , 'BILL_DESCRIPTION');
    FND_MSG_PUB.add;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
  END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Bill Amount = ' || BillInfoRec.Bill_Amount);
 END IF;

  IF ( BillInfoRec.Bill_Amount IS NULL ) THEN
    fnd_message.set_name('OKE' , 'OKE_API_MISSING_VALUE');
    fnd_message.set_token('VALUE' , 'BILL_AMOUNT');
    FND_MSG_PUB.add;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
  END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Revenue Amount = ' || BillInfoRec.Revenue_Amount);
 END IF;

  IF ( BillInfoRec.Revenue_Amount IS NULL ) THEN
    fnd_message.set_name('OKE' , 'OKE_API_MISSING_VALUE');
    fnd_message.set_token('VALUE' , 'REVENUE_AMOUNT');
    FND_MSG_PUB.add;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
  END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Organization ID = ' || BillInfoRec.Bill_Organization_ID);
 END IF;
  IF ( BillInfoRec.Bill_Organization_ID IS NULL ) THEN
    fnd_message.set_name('OKE' , 'OKE_API_MISSING_VALUE');
    fnd_message.set_token('VALUE' , 'BILL_ORGANIZATION_ID');
    FND_MSG_PUB.add;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
  END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Project ID = ' || BillInfoRec.Bill_Project_ID);
 END IF;

  IF ( BillInfoRec.Bill_Project_ID IS NULL ) THEN
    fnd_message.set_name('OKE' , 'OKE_API_MISSING_VALUE');
    fnd_message.set_token('VALUE' , 'BILL_PROJECT_ID');
    FND_MSG_PUB.add;
    X_Return_Status := FND_API.G_RET_STS_ERROR;
  END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Task ID = ' || BillInfoRec.Bill_Task_ID);
 END IF;
  IF ( X_Return_Status <> FND_API.G_RET_STS_SUCCESS ) THEN
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  --
  -- Addtional check to ensure the record hasn't been deleted from PA
  --
  OPEN C(BillInfoRec.Pa_Event_ID);
  FETCH C INTO L_Result;
  CLOSE C;

  -- Get Mc columns
  Populate_Mc_Columns ( P_Event_ID => P_Event_ID
  , X_Bill_Trans_Currency_Code   => L_Bill_Trans_Currency_Code
  , X_Bill_Trans_Bill_Amount     => L_Bill_Trans_Bill_Amount
  , X_Bill_Trans_rev_Amount      => L_Bill_Trans_rev_Amount
  , X_Project_Currency_Code      => L_Project_Currency_Code
  , X_Project_Rate_Type          => L_Project_Rate_Type
  , X_Project_Rate_Date          => L_Project_Rate_Date
  , X_Project_Exchange_Rate      => L_Project_Exchange_Rate
  , X_Project_Inv_Rate_Date      => L_Project_Inv_Rate_Date
  , X_Project_Inv_Exchange_Rate  => L_Project_Inv_Exchange_Rate
  , X_Project_Bill_Amount        => L_Project_Bill_Amount
  , X_Project_Rev_Rate_Date      => L_Project_Rev_Rate_Date
  , X_Project_Rev_Exchange_Rate  => L_Project_Rev_Exchange_Rate
  , X_Project_Revenue_Amount     => L_Project_Revenue_Amount
  , X_ProjFunc_Currency_Code     => L_ProjFunc_Currency_Code
  , X_ProjFunc_Rate_Type         => L_ProjFunc_Rate_Type
  , X_ProjFunc_Rate_Date         => L_ProjFunc_Rate_Date
  , X_ProjFunc_Exchange_Rate     => L_ProjFunc_Exchange_Rate
  , X_ProjFunc_Inv_Rate_Date     => L_ProjFunc_Inv_Rate_Date
  , X_ProjFunc_Inv_Exchange_Rate => L_ProjFunc_Inv_Exchange_Rate
  , X_ProjFunc_Bill_Amount       => L_ProjFunc_Bill_Amount
  , X_ProjFunc_Rev_Rate_Date     => L_ProjFunc_Rev_Rate_Date
  , X_Projfunc_Rev_Exchange_Rate => L_Projfunc_Rev_Exchange_Rate
  , X_ProjFunc_Revenue_Amount    => L_ProjFunc_Revenue_Amount
  , X_Funding_Rate_Type          => L_Funding_Rate_Type
  , X_Funding_Rate_Date          => L_Funding_Rate_Date
  , X_Funding_Exchange_Rate      => L_Funding_Exchange_Rate
  , X_Invproc_Currency_Code      => L_Invproc_Currency_Code
  , X_Invproc_Rate_Type          => L_Invproc_Rate_Type
  , X_Invproc_Rate_Date          => L_Invproc_Rate_Date
  , X_Invproc_Exchange_Rate      => L_Invproc_Exchange_Rate
  , X_Revproc_Currency_Code      => L_Revproc_Currency_Code
  , X_Revproc_Rate_Type          => L_Revproc_Rate_Type
  , X_Revproc_Rate_Date          => L_Revproc_Rate_Date
  , X_Revproc_Exchange_Rate      => L_Revproc_Exchange_Rate
  , X_Inv_Gen_Rejection_Code     => L_Inv_Gen_Rejection_Code );


  IF ( BillInfoRec.Pa_Event_ID > 0 AND L_Result = 'X') THEN

    --
    -- PA Event has previously been created
    --
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Event Previously Created ...');
 END IF;

    Update_Billing_Event
    ( P_Commit                     => FND_API.G_FALSE
    , P_Deliverable_ID             => BillInfoRec.Deliverable_ID
    , P_Event_ID                   => BillInfoRec.Pa_Event_ID
    , P_Event_Type                 => BillInfoRec.Bill_Event_Type
    , P_Event_Date                 => BillInfoRec.Bill_Event_Date
    , P_Project_ID                 => BillInfoRec.Bill_Project_ID
    , P_Task_ID                    => BillInfoRec.Bill_Task_ID
    , P_Organization_ID            => BillInfoRec.Bill_Organization_ID
    , P_Description                => BillInfoRec.Bill_Description
    , P_Unit_Price                 => BillInfoRec.Bill_Unit_Price
    , P_Bill_Quantity              => BillInfoRec.Bill_Quantity
    , P_UOM_Code                   => BillInfoRec.UOM_Code
    , P_Bill_Amount                => BillInfoRec.Bill_Amount
    , P_Revenue_Amount             => BillInfoRec.Revenue_Amount
    , P_Item_ID                    => BillInfoRec.Bill_Item_ID
    , P_Inventory_Org_ID           => BillInfoRec.Inventory_Org_ID
    , P_Contract_Num               => L_Contract_Num
    , P_Order_Num                  => L_Order_Num
    , P_Line_Num                   => L_Line_Num
    , P_Chg_Request_Num            => L_ChgReq_Num
    , P_Bill_Of_Lading             => BillInfoRec.Bill_Bill_Of_Lading
    , P_Serial_Num                 => BillInfoRec.Bill_Serial_Num
    , P_Fund_Ref1                  => BillInfoRec.Bill_Fund_Ref1
    , P_Fund_Ref2                  => BillInfoRec.Bill_Fund_Ref2
    , P_Fund_Ref3                  => BillInfoRec.Bill_Fund_Ref3
    , P_Bill_Trans_Currency_Code   => L_Bill_Trans_Currency_Code
    , P_Bill_Trans_Bill_Amount 	   => L_Bill_Trans_Bill_Amount
    , P_Bill_Trans_rev_Amount	   => L_Bill_Trans_rev_Amount
    , P_Project_Currency_Code	   => L_Project_Currency_Code
    , P_Project_Rate_Type          => L_Project_Rate_Type
    , P_Project_Rate_Date          => L_Project_Rate_Date
    , P_Project_Exchange_Rate	   => L_Project_Exchange_Rate
    , P_Project_Inv_Rate_Date	   => L_Project_Inv_Rate_Date
    , P_Project_Inv_Exchange_Rate  => L_Project_Inv_Exchange_Rate
    , P_Project_Bill_Amount	   => L_Project_Bill_Amount
    , P_Project_Rev_Rate_Date	   => L_Project_Rev_Rate_Date
    , P_Project_Rev_Exchange_Rate  => L_Project_Rev_Exchange_Rate
    , P_Project_Revenue_Amount 	   => L_Project_Revenue_Amount
    , P_ProjFunc_Currency_Code 	   => L_ProjFunc_Currency_Code
    , P_ProjFunc_Rate_Type	   => L_ProjFunc_Rate_Type
    , P_ProjFunc_Rate_Date	   => L_ProjFunc_Rate_Date
    , P_ProjFunc_Exchange_Rate 	   => L_ProjFunc_Exchange_Rate
    , P_ProjFunc_Inv_Rate_Date 	   => L_ProjFunc_Inv_Rate_Date
    , P_ProjFunc_Inv_Exchange_Rate => L_ProjFunc_Inv_Exchange_Rate
    , P_ProjFunc_Bill_Amount	   => L_ProjFunc_Bill_Amount
    , P_ProjFunc_Rev_Rate_Date 	   => L_ProjFunc_Rev_Rate_Date
    , P_Projfunc_Rev_Exchange_Rate => L_Projfunc_Rev_Exchange_Rate
    , P_ProjFunc_Revenue_Amount	   => L_ProjFunc_Revenue_Amount
    , P_Funding_Rate_Type          => L_Funding_Rate_Type
    , P_Funding_Rate_Date          => L_Funding_Rate_Date
    , P_Funding_Exchange_Rate	   => L_Funding_Exchange_Rate
    , P_Invproc_Currency_Code	   => L_Invproc_Currency_Code
    , P_Invproc_Rate_Type          => L_Invproc_Rate_Type
    , P_Invproc_Rate_Date          => L_Invproc_Rate_Date
    , P_Invproc_Exchange_Rate	   => L_Invproc_Exchange_Rate
    , P_Revproc_Currency_Code	   => L_Revproc_Currency_Code
    , P_Revproc_Rate_Type          => L_Revproc_Rate_Type
    , P_Revproc_Rate_Date          => L_Revproc_Rate_Date
    , P_Revproc_Exchange_Rate	   => L_Revproc_Exchange_Rate
    , P_Inv_Gen_Rejection_Code 	   => L_Inv_Gen_Rejection_Code
    , X_Return_Status              => X_Return_Status
    , X_Msg_Count                  => X_Msg_Count
    , X_Msg_Data                   => X_Msg_Data
    );

    IF ( X_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( X_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Updating deliverable with event info ...');
 END IF;

    UPDATE oke_k_billing_events
    SET    initiated_flag = 'Y'
    WHERE  billing_event_id = P_Event_ID;



  ELSE
    --
    -- PA Event has not yet been created
    --
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Event Not Previously Created ...');
 END IF;
    Create_Billing_Event
    ( P_Commit                     => FND_API.G_FALSE
    , P_Event_Type                 => BillInfoRec.Bill_Event_Type
    , P_Event_Date                 => BillInfoRec.Bill_Event_Date
    , P_Project_ID                 => BillInfoRec.Bill_Project_ID
    , P_Task_ID                    => BillInfoRec.Bill_Task_ID
    , P_Organization_ID            => BillInfoRec.Bill_Organization_ID
    , P_Description                => BillInfoRec.Bill_Description
    , P_Unit_Price                 => BillInfoRec.Bill_Unit_Price
    , P_Bill_Quantity              => BillInfoRec.Bill_Quantity
    , P_UOM_Code                   => BillInfoRec.UOM_Code
    , P_Bill_Amount                => BillInfoRec.Bill_Amount
    , P_Revenue_Amount             => BillInfoRec.Revenue_Amount
    , P_Item_ID                    => BillInfoRec.Bill_Item_ID
    , P_Inventory_Org_ID           => BillInfoRec.Inventory_Org_ID
    , P_Contract_Num               => L_Contract_Num
    , P_Order_Num                  => L_Order_Num
    , P_Line_Num                   => L_Line_Num
    , P_Chg_Request_Num            => L_ChgReq_Num
    , P_Bill_Of_Lading             => BillInfoRec.Bill_Bill_Of_Lading
    , P_Serial_Num                 => BillInfoRec.Bill_Serial_Num
    , P_Fund_Ref1                  => BillInfoRec.Bill_Fund_Ref1
    , P_Fund_Ref2                  => BillInfoRec.Bill_Fund_Ref2
    , P_Fund_Ref3                  => BillInfoRec.Bill_Fund_Ref3
    , P_Event_Num_Reversed         => NULL
    , P_Bill_Trans_Currency_Code   => L_Bill_Trans_Currency_Code
    , P_Bill_Trans_Bill_Amount 	   => L_Bill_Trans_Bill_Amount
    , P_Bill_Trans_rev_Amount	   => L_Bill_Trans_rev_Amount
    , P_Project_Currency_Code	   => L_Project_Currency_Code
    , P_Project_Rate_Type          => L_Project_Rate_Type
    , P_Project_Rate_Date          => L_Project_Rate_Date
    , P_Project_Exchange_Rate	   => L_Project_Exchange_Rate
    , P_Project_Inv_Rate_Date	   => L_Project_Inv_Rate_Date
    , P_Project_Inv_Exchange_Rate  => L_Project_Inv_Exchange_Rate
    , P_Project_Bill_Amount	   => L_Project_Bill_Amount
    , P_Project_Rev_Rate_Date	   => L_Project_Rev_Rate_Date
    , P_Project_Rev_Exchange_Rate  => L_Project_Rev_Exchange_Rate
    , P_Project_Revenue_Amount 	   => L_Project_Revenue_Amount
    , P_ProjFunc_Currency_Code 	   => L_ProjFunc_Currency_Code
    , P_ProjFunc_Rate_Type	   => L_ProjFunc_Rate_Type
    , P_ProjFunc_Rate_Date	   => L_ProjFunc_Rate_Date
    , P_ProjFunc_Exchange_Rate 	   => L_ProjFunc_Exchange_Rate
    , P_ProjFunc_Inv_Rate_Date 	   => L_ProjFunc_Inv_Rate_Date
    , P_ProjFunc_Inv_Exchange_Rate => L_ProjFunc_Inv_Exchange_Rate
    , P_ProjFunc_Bill_Amount	   => L_ProjFunc_Bill_Amount
    , P_ProjFunc_Rev_Rate_Date 	   => L_ProjFunc_Rev_Rate_Date
    , P_Projfunc_Rev_Exchange_Rate => L_Projfunc_Rev_Exchange_Rate
    , P_ProjFunc_Revenue_Amount	   => L_ProjFunc_Revenue_Amount
    , P_Funding_Rate_Type          => L_Funding_Rate_Type
    , P_Funding_Rate_Date          => L_Funding_Rate_Date
    , P_Funding_Exchange_Rate	   => L_Funding_Exchange_Rate
    , P_Invproc_Currency_Code	   => L_Invproc_Currency_Code
    , P_Invproc_Rate_Type          => L_Invproc_Rate_Type
    , P_Invproc_Rate_Date          => L_Invproc_Rate_Date
    , P_Invproc_Exchange_Rate	   => L_Invproc_Exchange_Rate
    , P_Revproc_Currency_Code	   => L_Revproc_Currency_Code
    , P_Revproc_Rate_Type          => L_Revproc_Rate_Type
    , P_Revproc_Rate_Date          => L_Revproc_Rate_Date
    , P_Revproc_Exchange_Rate	   => L_Revproc_Exchange_Rate
    , P_Inv_Gen_Rejection_Code 	   => L_Inv_Gen_Rejection_Code
    , X_Event_ID                   => L_Event_ID
    , X_Event_Num                  => X_Event_Num
    , X_Return_Status              => X_Return_Status
    , X_Msg_Count                  => X_Msg_Count
    , X_Msg_Data                   => X_Msg_Data
    );

    IF ( X_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( X_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Updating deliverable with event info ...');
 END IF;

    UPDATE oke_k_billing_events
    SET    pa_event_id = L_Event_ID
          ,initiated_flag = 'Y'
    WHERE  billing_event_id = P_Event_ID;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Successful completion ...');
 END IF;
    X_Event_ID := L_Event_ID;

  END IF;

  --
  -- Standard commit check
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( P_Count => X_Msg_Count
                           , P_Data  => X_Msg_Data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO create_billing_event;
  X_Return_Status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get( P_Count => X_Msg_Count
                           , P_Data  => X_Msg_Data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO create_billing_event;
  X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get( P_Count => X_Msg_Count
                           , P_Data  => X_Msg_Data );

WHEN OTHERS THEN
  ROLLBACK TO create_billing_event;
  X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => G_Pkg_Name
    , p_procedure_name  => 'CREATE_BILLING_EVENT' );
  END IF;
  FND_MSG_PUB.Count_And_Get( P_Count => X_Msg_Count
                           , P_Data  => X_Msg_Data );
END Create_Billing_Event;


PROCEDURE Create_Billing_Event
( P_Commit                     IN      VARCHAR2
, P_Event_Type                 IN      VARCHAR2
, P_Event_Date                 IN      DATE
, P_Project_ID                 IN      NUMBER
, P_Task_ID                    IN      NUMBER
, P_Organization_ID            IN      NUMBER
, P_Description                IN      VARCHAR2
, P_Unit_Price                 IN      NUMBER
, P_Bill_Quantity              IN      NUMBER
, P_UOM_Code                   IN      VARCHAR2
, P_Bill_Amount                IN      NUMBER
, P_Revenue_Amount             IN      NUMBER
, P_Item_ID                    IN      NUMBER
, P_Inventory_Org_ID           IN      NUMBER
, P_Contract_Num               IN      VARCHAR2
, P_Order_Num                  IN      VARCHAR2
, P_Line_Num                   IN      VARCHAR2
, P_Chg_Request_Num            IN      VARCHAR2
, P_Bill_Of_Lading             IN      VARCHAR2
, P_Serial_Num                 IN      VARCHAR2
, P_Fund_Ref1                  IN      VARCHAR2
, P_Fund_Ref2                  IN      VARCHAR2
, P_Fund_Ref3                  IN      VARCHAR2
, P_Event_Num_Reversed         IN      NUMBER
, P_Bill_Trans_Currency_Code   IN      VARCHAR2 DEFAULT NULL
, P_Bill_Trans_Bill_Amount     IN      NUMBER   DEFAULT NULL
, P_Bill_Trans_rev_Amount      IN      NUMBER   DEFAULT NULL
, P_Project_Currency_Code      IN      VARCHAR2 DEFAULT NULL
, P_Project_Rate_Type          IN      VARCHAR2 DEFAULT NULL
, P_Project_Rate_Date          IN      DATE     DEFAULT NULL
, P_Project_Exchange_Rate      IN      NUMBER   DEFAULT NULL
, P_Project_Inv_Rate_Date      IN      DATE     DEFAULT NULL
, P_Project_Inv_Exchange_Rate  IN      NUMBER   DEFAULT NULL
, P_Project_Bill_Amount        IN      NUMBER   DEFAULT NULL
, P_Project_Rev_Rate_Date      IN      DATE     DEFAULT NULL
, P_Project_Rev_Exchange_Rate  IN      NUMBER   DEFAULT NULL
, P_Project_Revenue_Amount     IN      NUMBER   DEFAULT NULL
, P_ProjFunc_Currency_Code     IN      VARCHAR2 DEFAULT NULL
, P_ProjFunc_Rate_Type         IN      VARCHAR2 DEFAULT NULL
, P_ProjFunc_Rate_Date         IN      DATE     DEFAULT NULL
, P_ProjFunc_Exchange_Rate     IN      NUMBER   DEFAULT NULL
, P_ProjFunc_Inv_Rate_Date     IN      DATE     DEFAULT NULL
, P_ProjFunc_Inv_Exchange_Rate IN      NUMBER   DEFAULT NULL
, P_ProjFunc_Bill_Amount       IN      NUMBER   DEFAULT NULL
, P_ProjFunc_Rev_Rate_Date     IN      DATE     DEFAULT NULL
, P_Projfunc_Rev_Exchange_Rate IN      NUMBER   DEFAULT NULL
, P_ProjFunc_Revenue_Amount    IN      NUMBER   DEFAULT NULL
, P_Funding_Rate_Type          IN      VARCHAR2 DEFAULT NULL
, P_Funding_Rate_Date          IN      DATE     DEFAULT NULL
, P_Funding_Exchange_Rate      IN      NUMBER   DEFAULT NULL
, P_Invproc_Currency_Code      IN      VARCHAR2 DEFAULT NULL
, P_Invproc_Rate_Type          IN      VARCHAR2 DEFAULT NULL
, P_Invproc_Rate_Date          IN      DATE     DEFAULT NULL
, P_Invproc_Exchange_Rate      IN      NUMBER   DEFAULT NULL
, P_Revproc_Currency_Code      IN      VARCHAR2 DEFAULT NULL
, P_Revproc_Rate_Type          IN      VARCHAR2 DEFAULT NULL
, P_Revproc_Rate_Date          IN      DATE     DEFAULT NULL
, P_Revproc_Exchange_Rate      IN      NUMBER   DEFAULT NULL
, P_Inv_Gen_Rejection_Code     IN      VARCHAR2 DEFAULT NULL
, X_Event_ID                   OUT     NOCOPY           NUMBER
, X_Event_Num                  OUT     NOCOPY           NUMBER
, X_Return_Status              OUT     NOCOPY           VARCHAR2
, X_Msg_Count                  OUT     NOCOPY           NUMBER
, X_Msg_Data                   OUT     NOCOPY           VARCHAR2
) IS

  L_RowID          VARCHAR2(18);
  L_UserID         NUMBER := FND_GLOBAL.User_ID;
  L_LoginID        NUMBER := FND_GLOBAL.Login_ID;
  l_api_name      CONSTANT VARCHAR2(30) := 'Update_Billing_Event';
  CURSOR EventID IS
    SELECT pa_events_s.nextval
    FROM   dual;

BEGIN

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT create_billing_event_pvt;

  --
  -- Getting Event Num if not already specified
  --
  IF ( X_Event_Num IS NULL ) THEN
    OPEN NextEventNum ( P_Project_ID
                      , P_Task_ID );
    FETCH NextEventNum INTO X_Event_Num;
    CLOSE NextEventNum;
  END IF;

  OPEN EventID;
  FETCH EventID INTO X_Event_ID;
  CLOSE EventID;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Creating PA billing event ...');
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Event ID = ' || X_Event_ID);
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Event Num = ' || X_Event_Num);
 END IF;

  PA_EVENTS_PKG.Insert_Row
  ( X_ROWID                     => L_RowID
  , X_EVENT_ID                  => X_Event_ID
  , X_TASK_ID                   => P_Task_ID
  , X_EVENT_NUM                 => X_Event_Num
  , X_LAST_UPDATE_DATE          => sysdate
  , X_LAST_UPDATED_BY           => L_UserID
  , X_CREATION_DATE             => sysdate
  , X_CREATED_BY                => L_UserID
  , X_LAST_UPDATE_LOGIN         => L_LoginID
  , X_EVENT_TYPE                => P_Event_Type
  , X_DESCRIPTION               => P_Description
  , X_BILL_AMOUNT               => P_Bill_Amount
  , X_REVENUE_AMOUNT            => P_Revenue_Amount
  , X_REVENUE_DISTRIBUTED_FLAG  => 'N'
  , X_BILL_HOLD_FLAG            => 'N'
  , X_COMPLETION_DATE           => P_Event_Date
  , X_REV_DIST_REJECTION_CODE   => NULL
  , X_ATTRIBUTE_CATEGORY        => NULL
  , X_ATTRIBUTE1                => NULL
  , X_ATTRIBUTE2                => NULL
  , X_ATTRIBUTE3                => NULL
  , X_ATTRIBUTE4                => NULL
  , X_ATTRIBUTE5                => NULL
  , X_ATTRIBUTE6                => NULL
  , X_ATTRIBUTE7                => NULL
  , X_ATTRIBUTE8                => NULL
  , X_ATTRIBUTE9                => NULL
  , X_ATTRIBUTE10               => NULL
  , X_PROJECT_ID                => P_Project_ID
  , X_ORGANIZATION_ID           => P_Organization_ID
  , X_BILLING_ASSIGNMENT_ID     => NULL
  , X_EVENT_NUM_REVERSED        => P_Event_Num_Reversed
  , X_CALLING_PLACE             => NULL
  , X_CALLING_PROCESS           => NULL
  , X_Bill_Trans_Currency_Code	=> P_Bill_Trans_Currency_Code
  , X_Bill_Trans_Bill_Amount 	=> P_Bill_Trans_Bill_Amount
  , X_Bill_Trans_rev_Amount	=> P_Bill_Trans_rev_Amount
  , X_Project_Currency_Code	=> P_Project_Currency_Code
  , X_Project_Rate_Type		=> P_Project_Rate_Type
  , X_Project_Rate_Date		=> P_Project_Rate_Date
  , X_Project_Exchange_Rate	=> P_Project_Exchange_Rate
  , X_Project_Inv_Rate_Date	=> P_Project_Inv_Rate_Date
  , X_Project_Inv_Exchange_Rate => P_Project_Inv_Exchange_Rate
  , X_Project_Bill_Amount	=> P_Project_Bill_Amount
  , X_Project_Rev_Rate_Date	=> P_Project_Rev_Rate_Date
  , X_Project_Rev_Exchange_Rate	=> P_Project_Rev_Exchange_Rate
  , X_Project_Revenue_Amount 	=> P_Project_Revenue_Amount
  , X_ProjFunc_Currency_Code 	=> P_ProjFunc_Currency_Code
  , X_ProjFunc_Rate_Type	=> P_ProjFunc_Rate_Type
  , X_ProjFunc_Rate_Date	=> P_ProjFunc_Rate_Date
  , X_ProjFunc_Exchange_Rate 	=> P_ProjFunc_Exchange_Rate
  , X_ProjFunc_Inv_Rate_Date 	=> P_ProjFunc_Inv_Rate_Date
  , X_ProjFunc_Inv_Exchange_Rate => P_ProjFunc_Inv_Exchange_Rate
  , X_ProjFunc_Bill_Amount	=> P_ProjFunc_Bill_Amount
  , X_ProjFunc_Rev_Rate_Date 	=> P_ProjFunc_Rev_Rate_Date
  , X_Projfunc_Rev_Exchange_Rate => P_Projfunc_Rev_Exchange_Rate
  , X_ProjFunc_Revenue_Amount	=> P_ProjFunc_Revenue_Amount
  , X_Funding_Rate_Type		=> P_Funding_Rate_Type
  , X_Funding_Rate_Date		=> P_Funding_Rate_Date
  , X_Funding_Exchange_Rate	=> P_Funding_Exchange_Rate
  , X_Invproc_Currency_Code	=> P_Invproc_Currency_Code
  , X_Invproc_Rate_Type		=> P_Invproc_Rate_Type
  , X_Invproc_Rate_Date		=> P_Invproc_Rate_Date
  , X_Invproc_Exchange_Rate	=> P_Invproc_Exchange_Rate
  , X_Revproc_Currency_Code	=> P_Revproc_Currency_Code
  , X_Revproc_Rate_Type		=> P_Revproc_Rate_Type
  , X_Revproc_Rate_Date		=> P_Revproc_Rate_Date
  , X_Revproc_Exchange_Rate	=> P_Revproc_Exchange_Rate
  , X_Inv_Gen_Rejection_Code 	=> P_Inv_Gen_Rejection_Code
  , X_Product_Code              => 'OKE'
  , X_event_reference           => X_Event_Id
  );

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Updating additional billing info ...');
 END IF;
  Update_Event_References
  ( P_Event_ID                  => X_Event_ID
  , P_Contract_Num              => P_Contract_Num
  , P_Order_Num                 => P_Order_Num
  , P_Line_Num                  => P_Line_Num
  , P_Chg_Req_Num               => P_Chg_Request_Num
  , P_Item_ID                   => P_Item_ID
  , P_Org_ID                    => P_Inventory_Org_ID
  , P_Unit_Price                => P_Unit_Price
  , P_UOM                       => P_UOM_Code
  , P_Bill_Quantity             => P_Bill_Quantity
  , P_Bill_Of_Lading            => P_Bill_Of_Lading
  , P_Serial_Num                => P_Serial_Num
  , P_Fund_Ref1                 => P_Fund_Ref1
  , P_Fund_Ref2                 => P_Fund_Ref2
  , P_Fund_Ref3                 => P_Fund_Ref3
  );

  --
  -- Standard commit check
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( P_Count => X_Msg_Count
                           , P_Data  => X_Msg_Data );

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Billing event created ...');
 END IF;

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO create_billing_event_pvt;
  X_Return_Status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get( P_Count => X_Msg_Count
                           , P_Data  => X_Msg_Data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO create_billing_event_pvt;
  X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get( P_Count => X_Msg_Count
                           , P_Data  => X_Msg_Data );

WHEN OTHERS THEN
  ROLLBACK TO create_billing_event_pvt;
  X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => G_Pkg_Name
    , p_procedure_name  => 'CREATE_BILLING_EVENT' );
  END IF;
  FND_MSG_PUB.Count_And_Get( P_Count => X_Msg_Count
                           , P_Data  => X_Msg_Data );
END Create_Billing_Event;


PROCEDURE Update_Billing_Event
( P_Commit                     IN      VARCHAR2
, P_Deliverable_ID             IN      NUMBER
, P_Event_ID                   IN      NUMBER
, P_Event_Type                 IN      VARCHAR2
, P_Event_Date                 IN      DATE
, P_Project_ID                 IN      NUMBER
, P_Task_ID                    IN      NUMBER
, P_Organization_ID            IN      NUMBER
, P_Description                IN      VARCHAR2
, P_Unit_Price                 IN      NUMBER
, P_Bill_Quantity              IN      NUMBER
, P_UOM_Code                   IN      VARCHAR2
, P_Bill_Amount                IN      NUMBER
, P_Revenue_Amount             IN      NUMBER
, P_Item_ID                    IN      NUMBER
, P_Inventory_Org_ID           IN      NUMBER
, P_Contract_Num               IN      VARCHAR2
, P_Order_Num                  IN      VARCHAR2
, P_Line_Num                   IN      VARCHAR2
, P_Chg_Request_Num            IN      VARCHAR2
, P_Bill_Of_Lading             IN      VARCHAR2
, P_Serial_Num                 IN      VARCHAR2
, P_Fund_Ref1                  IN      VARCHAR2
, P_Fund_Ref2                  IN      VARCHAR2
, P_Fund_Ref3                  IN      VARCHAR2
, P_Bill_Trans_Currency_Code   IN      VARCHAR2 DEFAULT NULL
, P_Bill_Trans_Bill_Amount     IN      NUMBER   DEFAULT NULL
, P_Bill_Trans_rev_Amount      IN      NUMBER   DEFAULT NULL
, P_Project_Currency_Code      IN      VARCHAR2 DEFAULT NULL
, P_Project_Rate_Type          IN      VARCHAR2 DEFAULT NULL
, P_Project_Rate_Date          IN      DATE     DEFAULT NULL
, P_Project_Exchange_Rate      IN      NUMBER   DEFAULT NULL
, P_Project_Inv_Rate_Date      IN      DATE     DEFAULT NULL
, P_Project_Inv_Exchange_Rate  IN      NUMBER   DEFAULT NULL
, P_Project_Bill_Amount        IN      NUMBER   DEFAULT NULL
, P_Project_Rev_Rate_Date      IN      DATE     DEFAULT NULL
, P_Project_Rev_Exchange_Rate  IN      NUMBER   DEFAULT NULL
, P_Project_Revenue_Amount     IN      NUMBER   DEFAULT NULL
, P_ProjFunc_Currency_Code     IN      VARCHAR2 DEFAULT NULL
, P_ProjFunc_Rate_Type         IN      VARCHAR2 DEFAULT NULL
, P_ProjFunc_Rate_Date         IN      DATE     DEFAULT NULL
, P_ProjFunc_Exchange_Rate     IN      NUMBER   DEFAULT NULL
, P_ProjFunc_Inv_Rate_Date     IN      DATE     DEFAULT NULL
, P_ProjFunc_Inv_Exchange_Rate IN      NUMBER   DEFAULT NULL
, P_ProjFunc_Bill_Amount       IN      NUMBER   DEFAULT NULL
, P_ProjFunc_Rev_Rate_Date     IN      DATE     DEFAULT NULL
, P_Projfunc_Rev_Exchange_Rate IN      NUMBER   DEFAULT NULL
, P_ProjFunc_Revenue_Amount    IN      NUMBER   DEFAULT NULL
, P_Funding_Rate_Type          IN      VARCHAR2 DEFAULT NULL
, P_Funding_Rate_Date          IN      DATE     DEFAULT NULL
, P_Funding_Exchange_Rate      IN      NUMBER   DEFAULT NULL
, P_Invproc_Currency_Code      IN      VARCHAR2 DEFAULT NULL
, P_Invproc_Rate_Type          IN      VARCHAR2 DEFAULT NULL
, P_Invproc_Rate_Date          IN      DATE     DEFAULT NULL
, P_Invproc_Exchange_Rate      IN      NUMBER   DEFAULT NULL
, P_Revproc_Currency_Code      IN      VARCHAR2 DEFAULT NULL
, P_Revproc_Rate_Type          IN      VARCHAR2 DEFAULT NULL
, P_Revproc_Rate_Date          IN      DATE     DEFAULT NULL
, P_Revproc_Exchange_Rate      IN      NUMBER   DEFAULT NULL
, P_Inv_Gen_Rejection_Code     IN      VARCHAR2 DEFAULT NULL
, X_Return_Status              OUT     NOCOPY   VARCHAR2
, X_Msg_Count                  OUT     NOCOPY   NUMBER
, X_Msg_Data                   OUT     NOCOPY   VARCHAR2
) IS

  CURSOR EventNum IS
    SELECT event_num
    ,      project_id
    ,      revenue_distributed_flag
    ,      rowid
    ,      bill_amount
    FROM   pa_events
    WHERE  event_id = P_Event_ID;



  L_Event_ID       NUMBER;
  L_Event_Num      NUMBER;
  L_Project_ID     NUMBER;
  L_Rev_Dist       VARCHAR2(80);
  L_RowID          VARCHAR2(18);
  L_Bill_Amount    NUMBER;
  L_UserID         NUMBER := FND_GLOBAL.User_ID;
  L_LoginID        NUMBER := FND_GLOBAL.Login_ID;
  L_Result         VARCHAR2(1);
  l_api_name       CONSTANT VARCHAR2(30) := 'Update_Billing_Event';

BEGIN

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
   FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Updating Billing Event ...');
 END IF;

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  --
  -- Standard Start of API savepoint
  --
  SAVEPOINT update_billing_event_pvt;

  --
  -- Get Event Num
  --
  OPEN EventNum;
  FETCH EventNum INTO L_Event_Num , L_Project_ID,L_Rev_Dist , L_RowID,L_Bill_Amount;
  CLOSE EventNum;



  IF ( PA_EVENTS_PKG.Is_Event_Billed
       ( L_Project_ID
       , P_Task_ID
       , L_Event_Num
       , L_Bill_Amount ) = 'Y')THEN

    -- Event has already been billed, need to cancel previous entry
    -- and create a new one.
    --
 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Event already processed in PA:');
 END IF;

    --
    -- A Law  05/15/2001
    --
    -- Temporarily raised an exception when event has been processed.
    -- Current design logic does not work as a non-updateable event
    -- maybe revenue distributed but not billed.  In such scenario,
    -- The credit memo event will cause draft invoice creation to fail.
    --
    FND_MESSAGE.set_name('OKE' , 'OKE_BILL_EVENT_PROCESSED');
    FND_MESSAGE.set_token('EVENT' , L_Event_Num);
    FND_MSG_PUB.add;
    RAISE FND_API.G_EXC_ERROR;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Reversing billed entry ...');
 END IF;

    Revert_Billing_Event
    ( P_Event_ID                  => P_Event_ID
    , P_Event_Date                => P_Event_Date
    );

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Creating revised entry ...');
 END IF;

    Create_Billing_Event
    ( P_Commit                     => FND_API.G_FALSE
    , P_Event_Type                 => P_Event_Type
    , P_Event_Date                 => P_Event_Date
    , P_Project_ID                 => P_Project_ID
    , P_Task_ID                    => P_Task_ID
    , P_Organization_ID            => P_Organization_ID
    , P_Description                => P_Description
    , P_Unit_Price                 => P_Unit_Price
    , P_Bill_Quantity              => P_Bill_Quantity
    , P_UOM_Code                   => P_UOM_Code
    , P_Bill_Amount                => P_Bill_Amount
    , P_Revenue_Amount             => P_Revenue_Amount
    , P_Item_ID                    => P_Item_ID
    , P_Inventory_Org_ID           => P_Inventory_Org_ID
    , P_Contract_Num               => P_Contract_Num
    , P_Order_Num                  => P_Order_Num
    , P_Line_Num                   => P_Line_Num
    , P_Chg_Request_Num            => P_Chg_Request_Num
    , P_Bill_Of_Lading             => P_Bill_Of_Lading
    , P_Serial_Num                 => P_Serial_Num
    , P_Fund_Ref1                  => P_Fund_Ref1
    , P_Fund_Ref2                  => P_Fund_Ref2
    , P_Fund_Ref3                  => P_Fund_Ref3
    , P_Event_Num_Reversed         => NULL
    , P_Bill_Trans_Currency_Code   => P_Bill_Trans_Currency_Code
    , P_Bill_Trans_Bill_Amount     => P_Bill_Trans_Bill_Amount
    , P_Bill_Trans_rev_Amount      => P_Bill_Trans_rev_Amount
    , P_Project_Currency_Code      => P_Project_Currency_Code
    , P_Project_Rate_Type          => P_Project_Rate_Type
    , P_Project_Rate_Date          => P_Project_Rate_Date
    , P_Project_Exchange_Rate      => P_Project_Exchange_Rate
    , P_Project_Inv_Rate_Date      => P_Project_Inv_Rate_Date
    , P_Project_Inv_Exchange_Rate  => P_Project_Inv_Exchange_Rate
    , P_Project_Bill_Amount        => P_Project_Bill_Amount
    , P_Project_Rev_Rate_Date      => P_Project_Rev_Rate_Date
    , P_Project_Rev_Exchange_Rate  => P_Project_Rev_Exchange_Rate
    , P_Project_Revenue_Amount     => P_Project_Revenue_Amount
    , P_ProjFunc_Currency_Code     => P_ProjFunc_Currency_Code
    , P_ProjFunc_Rate_Type         => P_ProjFunc_Rate_Type
    , P_ProjFunc_Rate_Date         => P_ProjFunc_Rate_Date
    , P_ProjFunc_Exchange_Rate     => P_ProjFunc_Exchange_Rate
    , P_ProjFunc_Inv_Rate_Date     => P_ProjFunc_Inv_Rate_Date
    , P_ProjFunc_Inv_Exchange_Rate => P_ProjFunc_Inv_Exchange_Rate
    , P_ProjFunc_Bill_Amount       => P_ProjFunc_Bill_Amount
    , P_ProjFunc_Rev_Rate_Date     => P_ProjFunc_Rev_Rate_Date
    , P_Projfunc_Rev_Exchange_Rate => P_Projfunc_Rev_Exchange_Rate
    , P_ProjFunc_Revenue_Amount    => P_ProjFunc_Revenue_Amount
    , P_Funding_Rate_Type          => P_Funding_Rate_Type
    , P_Funding_Rate_Date          => P_Funding_Rate_Date
    , P_Funding_Exchange_Rate      => P_Funding_Exchange_Rate
    , P_Invproc_Currency_Code      => P_Invproc_Currency_Code
    , P_Invproc_Rate_Type          => P_Invproc_Rate_Type
    , P_Invproc_Rate_Date          => P_Invproc_Rate_Date
    , P_Invproc_Exchange_Rate      => P_Invproc_Exchange_Rate
    , P_Revproc_Currency_Code      => P_Revproc_Currency_Code
    , P_Revproc_Rate_Type          => P_Revproc_Rate_Type
    , P_Revproc_Rate_Date          => P_Revproc_Rate_Date
    , P_Revproc_Exchange_Rate      => P_Revproc_Exchange_Rate
    , P_Inv_Gen_Rejection_Code     => P_Inv_Gen_Rejection_Code
    , X_Event_ID                   => L_Event_ID
    , X_Event_Num                  => L_Event_Num
    , X_Return_Status              => X_Return_Status
    , X_Msg_Count                  => X_Msg_Count
    , X_Msg_Data                   => X_Msg_Data
    );

    IF ( X_Return_Status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF ( X_return_status = FND_API.G_RET_STS_ERROR ) THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    UPDATE oke_k_billing_events
    SET    pa_event_id = L_Event_ID
    WHERE  billing_event_id = P_Event_ID;

  ELSE


    -- Event has not been billed, only need to update event
    -- information
    --

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
    FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Event not yet processed in PA; update existing ...');
 END IF;


    UPDATE pa_events
    SET last_update_date           = sysdate
    ,   last_updated_by            = FND_GLOBAL.User_ID
    ,   last_update_login          = FND_GLOBAL.Login_ID
    ,   event_type                 = nvl( P_Event_Type , event_type )
    ,   description                = nvl( P_Description , description )
    ,   bill_amount                = nvl( P_Bill_Amount , bill_amount )
    ,   revenue_amount             = nvl( P_Revenue_Amount , revenue_amount )
    ,   completion_date            = nvl( P_Event_Date , completion_date )
    ,   project_id                 = nvl( P_Project_ID , project_id )
    ,   event_num                  = L_Event_Num
    ,   task_id                    = nvl( P_Task_ID , task_id )
    ,   quantity_billed            = P_Bill_Quantity
    ,   uom_code                   = P_UOM_Code
    ,   inventory_org_id           = P_Inventory_Org_ID
    ,   inventory_item_id          = P_Item_ID
    ,   unit_price                 = P_Unit_Price
    ,   reference1                 = P_Contract_Num
    ,   reference2                 = P_Order_Num
    ,   reference3                 = P_Line_Num
    ,   reference4                 = P_Chg_Request_Num
    ,   reference5                 = P_Fund_Ref1
    ,   reference6                 = P_Fund_Ref2
    ,   reference7                 = P_Fund_Ref3
    ,   reference8                 = P_Bill_Of_Lading
    ,   reference9                 = P_Serial_Num
    ,   reference10                = 'OKE'
    ,   organization_id	           = P_Organization_ID  /* jxtang for bug 2219338 */
    ,   Bill_Trans_Currency_Code   = P_Bill_Trans_Currency_Code
    ,   Bill_Trans_Bill_Amount     = P_Bill_Trans_Bill_Amount
    ,   Bill_Trans_rev_Amount      = P_Bill_Trans_rev_Amount
    ,   Project_Currency_Code      = P_Project_Currency_Code
    ,   Project_Rate_Type          = P_Project_Rate_Type
    ,   Project_Rate_Date          = P_Project_Rate_Date
    ,   Project_Exchange_Rate      = P_Project_Exchange_Rate
    ,   Project_Inv_Rate_Date      = P_Project_Inv_Rate_Date
    ,   Project_Inv_Exchange_Rate  = P_Project_Inv_Exchange_Rate
    ,   Project_Bill_Amount        = P_Project_Bill_Amount
    ,   Project_Rev_Rate_Date      = P_Project_Rev_Rate_Date
    ,   Project_Rev_Exchange_Rate  = P_Project_Rev_Exchange_Rate
    ,   Project_Revenue_Amount     = P_Project_Revenue_Amount
    ,   ProjFunc_Currency_Code     = P_ProjFunc_Currency_Code
    ,   ProjFunc_Rate_Type         = P_ProjFunc_Rate_Type
    ,   ProjFunc_Rate_Date         = P_ProjFunc_Rate_Date
    ,   ProjFunc_Exchange_Rate     = P_ProjFunc_Exchange_Rate
    ,   ProjFunc_Inv_Rate_Date     = P_ProjFunc_Inv_Rate_Date
    ,   ProjFunc_Inv_Exchange_Rate = P_ProjFunc_Inv_Exchange_Rate
    ,   ProjFunc_Bill_Amount       = P_ProjFunc_Bill_Amount
    ,   ProjFunc_Rev_Rate_Date     = P_ProjFunc_Rev_Rate_Date
    ,   Projfunc_Rev_Exchange_Rate = P_Projfunc_Rev_Exchange_Rate
    ,   ProjFunc_Revenue_Amount    = P_ProjFunc_Revenue_Amount
    ,   Funding_Rate_Type          = P_Funding_Rate_Type
    ,   Funding_Rate_Date          = P_Funding_Rate_Date
    ,   Funding_Exchange_Rate      = P_Funding_Exchange_Rate
    ,   Invproc_Currency_Code      = P_Invproc_Currency_Code
    ,   Invproc_Rate_Type          = P_Invproc_Rate_Type
    ,   Invproc_Rate_Date          = P_Invproc_Rate_Date
    ,   Invproc_Exchange_Rate      = P_Invproc_Exchange_Rate
    ,   Revproc_Currency_Code      = P_Revproc_Currency_Code
    ,   Revproc_Rate_Type          = P_Revproc_Rate_Type
    ,   Revproc_Rate_Date          = P_Revproc_Rate_Date
    ,   Revproc_Exchange_Rate      = P_Revproc_Exchange_Rate
    ,   Inv_Gen_Rejection_Code     = P_Inv_Gen_Rejection_Code
    WHERE event_id = P_Event_ID;

    Update_Event_References
    ( P_Event_ID                  => P_Event_ID
    , P_Contract_Num              => P_Contract_Num
    , P_Order_Num                 => P_Order_Num
    , P_Line_Num                  => P_Line_Num
    , P_Chg_Req_Num               => P_Chg_Request_Num
    , P_Item_ID                   => P_Item_ID
    , P_Org_ID                    => P_Inventory_Org_ID
    , P_Unit_Price                => P_Unit_Price
    , P_UOM                       => P_UOM_Code
    , P_Bill_Quantity             => P_Bill_Quantity
    , P_Bill_Of_Lading            => P_Bill_Of_Lading
    , P_Serial_Num                => P_Serial_Num
    , P_Fund_Ref1                 => P_Fund_Ref1
    , P_Fund_Ref2                 => P_Fund_Ref2
    , P_Fund_Ref3                 => P_Fund_Ref3
    );



  END IF;

  --
  -- Standard commit check
  --
  IF FND_API.To_Boolean( p_commit ) THEN
    COMMIT WORK;
  END IF;

  --
  -- Standard call to get message count and if count is 1, get message
  -- info
  --
  FND_MSG_PUB.Count_And_Get( P_Count => X_Msg_Count
                           , P_Data  => X_Msg_Data );

EXCEPTION
WHEN FND_API.G_EXC_ERROR THEN
  ROLLBACK TO update_billing_event_pvt;
  X_Return_Status := FND_API.G_RET_STS_ERROR;
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data );

WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  ROLLBACK TO update_billing_event_pvt;
  X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
  FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                           , p_data  => x_msg_data );

WHEN OTHERS THEN
  ROLLBACK TO update_billing_event_pvt;
  X_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => G_Pkg_Name
    , p_procedure_name  => 'UPDATE_BILLING_EVENT' );
  END IF;
END Update_Billing_Event;

PROCEDURE Insert_Billing_Info
( P_Deliverable_Id              IN      NUMBER
, P_Billing_Event_Id            IN      NUMBER
, P_Pa_Event_Id                 IN      NUMBER
, P_K_Header_Id                 IN      NUMBER
, P_K_Line_Id                   IN      NUMBER
, P_Bill_Event_Type             IN      VARCHAR2
, P_Bill_Event_Date             IN      DATE
, P_Bill_Item_Id                IN      NUMBER
, P_Bill_Line_Id                IN      NUMBER
, P_Bill_Chg_Req_Id             IN      NUMBER
, P_Bill_Project_Id             IN      NUMBER
, P_Bill_Task_Id                IN      NUMBER
, P_Bill_Organization_Id        IN      NUMBER
, P_Bill_Fund_Ref1              IN      VARCHAR2
, P_Bill_Fund_Ref2              IN      VARCHAR2
, P_Bill_Fund_Ref3              IN      VARCHAR2
, P_Bill_Bill_Of_Lading         IN      VARCHAR2
, P_Bill_Serial_Num             IN      VARCHAR2
, P_Bill_Currency_Code          IN      VARCHAR2
, P_Bill_Rate_Type              IN      VARCHAR2
, P_Bill_Rate_Date              IN      DATE
, P_Bill_Exchange_Rate          IN      NUMBER
, P_Bill_Description            IN      VARCHAR2
, P_Bill_Quantity               IN      NUMBER
, P_Bill_Unit_Price             IN      NUMBER
, P_Revenue_Amount              IN      NUMBER
, P_Created_By                  IN      NUMBER
, P_Creation_Date               IN      DATE
, P_LAST_UPDATED_BY             IN      NUMBER
, P_LAST_UPDATE_LOGIN           IN      NUMBER
, P_LAST_UPDATE_DATE            IN      DATE
) Is

Begin

  Insert Into oke_k_billing_events
  ( BILLING_EVENT_ID
  , PA_EVENT_ID
  , K_HEADER_ID
  , K_LINE_ID
  , DELIVERABLE_ID
  , BILL_EVENT_TYPE
  , BILL_EVENT_DATE
  , BILL_ITEM_ID
  , BILL_LINE_ID
  , BILL_CHG_REQ_ID
  , BILL_PROJECT_ID
  , BILL_TASK_ID
  , BILL_ORGANIZATION_ID
  , BILL_FUND_REF1
  , BILL_FUND_REF2
  , BILL_FUND_REF3
  , BILL_BILL_OF_LADING
  , BILL_SERIAL_NUM
  , BILL_CURRENCY_CODE
  , BILL_RATE_TYPE
  , BILL_RATE_DATE
  , BILL_EXCHANGE_RATE
  , BILL_DESCRIPTION
  , BILL_QUANTITY
  , BILL_UNIT_PRICE
  , REVENUE_AMOUNT
  , CREATED_BY
  , CREATION_DATE
  , LAST_UPDATED_BY
  , LAST_UPDATE_LOGIN
  , LAST_UPDATE_DATE
  , INITIATED_FLAG)
  VALUES
  ( P_BILLING_EVENT_ID
  , P_PA_EVENT_ID
  , P_K_HEADER_ID
  , P_K_LINE_ID
  , P_DELIVERABLE_ID
  , P_BILL_EVENT_TYPE
  , P_BILL_EVENT_DATE
  , P_BILL_ITEM_ID
  , P_BILL_LINE_ID
  , P_BILL_CHG_REQ_ID
  , P_BILL_PROJECT_ID
  , P_BILL_TASK_ID
  , P_BILL_ORGANIZATION_ID
  , P_BILL_FUND_REF1
  , P_BILL_FUND_REF2
  , P_BILL_FUND_REF3
  , P_BILL_BILL_OF_LADING
  , P_BILL_SERIAL_NUM
  , P_BILL_CURRENCY_CODE
  , P_BILL_RATE_TYPE
  , P_BILL_RATE_DATE
  , P_BILL_EXCHANGE_RATE
  , P_BILL_DESCRIPTION
  , P_BILL_QUANTITY
  , P_BILL_UNIT_PRICE
  , P_REVENUE_AMOUNT
  , P_CREATED_BY
  , P_CREATION_DATE
  , P_LAST_UPDATED_BY
  , P_LAST_UPDATE_LOGIN
  , P_LAST_UPDATE_DATE
  , 'N');

EXCEPTION
WHEN OTHERS THEN
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => G_Pkg_Name
    , p_procedure_name  => 'INSERT_BILLING_INFO' );
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

END INSERT_BILLING_INFO;




PROCEDURE Update_Billing_Info
( P_Deliverable_ID             IN      NUMBER
, P_Billing_Event_ID           IN      NUMBER
, P_Bill_Event_Type            IN      VARCHAR2
, P_Bill_Event_Date            IN      DATE
, P_Bill_Project_ID            IN      NUMBER
, P_Bill_Task_ID               IN      NUMBER
, P_Bill_Org_ID                IN      NUMBER
, P_Bill_Line_ID               IN      NUMBER
, P_Bill_Chg_Req_ID            IN      NUMBER
, P_Bill_Item_ID               IN      NUMBER
, P_Bill_Description           IN      VARCHAR2
, P_Bill_Unit_Price            IN      NUMBER
, P_Bill_Quantity              IN      NUMBER
, P_Bill_Currency_Code         IN      VARCHAR2
, P_Bill_Rate_Type             IN      VARCHAR2
, P_Bill_Rate_Date             IN      DATE
, P_Bill_Exchange_Rate         IN      NUMBER
, P_Revenue_Amount             IN      NUMBER
, P_Bill_Of_Lading             IN      VARCHAR2
, P_Bill_Serial_Num            IN      VARCHAR2
, P_Bill_Fund_Ref1             IN      VARCHAR2
, P_Bill_Fund_Ref2             IN      VARCHAR2
, P_Bill_Fund_Ref3             IN      VARCHAR2
, P_LAST_UPDATED_BY            IN      NUMBER
, P_LAST_UPDATE_LOGIN          IN      NUMBER
, P_LAST_UPDATE_DATE           IN      DATE
) IS
BEGIN

  UPDATE oke_k_billing_events
  SET bill_event_type       = P_Bill_Event_Type
  ,   bill_event_date       = P_Bill_Event_Date
/*   ,   billing_event_id      =
      DECODE( SIGN( nvl(billing_event_id,0) - P_Billing_Event_ID )
            , 1 , billing_event_id , P_Billing_Event_ID ) */
  ,   bill_project_id       = P_Bill_Project_ID
  ,   bill_task_id          = P_Bill_Task_ID
  ,   bill_organization_id  = P_Bill_Org_ID
  ,   bill_line_id          = P_Bill_Line_ID
  ,   bill_chg_req_id       = P_Bill_Chg_Req_ID
  ,   bill_item_id          = P_Bill_Item_ID
  ,   bill_description      = P_Bill_Description
--  ,   unit_price            = P_Unit_Price
  ,   bill_unit_price       = P_Bill_Unit_Price
  ,   bill_quantity         = P_Bill_Quantity
  ,   revenue_amount        = P_Revenue_Amount
  ,   bill_currency_code    = P_Bill_Currency_Code
  ,   bill_rate_type        = P_Bill_Rate_Type
  ,   bill_rate_date        = P_Bill_Rate_Date
  ,   bill_exchange_rate    = P_Bill_Exchange_Rate
  ,   bill_bill_of_lading   = P_Bill_Of_Lading
  ,   bill_serial_num       = P_Bill_Serial_Num
  ,   bill_fund_ref1        = P_Bill_Fund_Ref1
  ,   bill_fund_ref2        = P_Bill_Fund_Ref2
  ,   bill_fund_ref3        = P_Bill_Fund_Ref3
  ,   last_updated_by       = P_LAST_UPDATED_BY
  ,   last_update_login	    = P_LAST_UPDATE_LOGIN
  ,   last_update_date      = P_LAST_UPDATE_DATE
  ,   initiated_flag	    = 'N'
  WHERE billing_event_id = P_Billing_Event_ID;

EXCEPTION
WHEN OTHERS THEN
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => G_Pkg_Name
    , p_procedure_name  => 'UPDATE_BILLING_INFO' );
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Update_Billing_Info;

PROCEDURE Delete_Billing_Info (
  P_Billing_Event_ID           IN      NUMBER
) IS
  L_task_ID       NUMBER;
  L_Event_Num      NUMBER;
  l_pa_event_id    NUMBER;
  L_Project_ID     NUMBER;
  L_RowID          VARCHAR2(18);
  L_oke_RowID      ROWID;
  L_Bill_Amount    NUMBER;

  CURSOR EventNum IS
    SELECT event_num
    ,      project_id
    ,      task_id
    ,      rowid
    ,      bill_amount
    FROM   pa_events
    WHERE  event_id = l_pa_event_id;

 BEGIN

  SELECT pa_event_id, ROWID
    INTO l_pa_event_id, L_oke_RowID
    FROM oke_k_billing_events
    WHERE billing_event_id = P_Billing_Event_ID;

  IF l_pa_event_id IS NOT NULL THEN

    OPEN EventNum;
    FETCH EventNum INTO L_Event_Num, L_Project_ID, L_task_ID, L_RowID, L_Bill_Amount;
    CLOSE EventNum;

    IF L_RowID IS NOT NULL THEN

      IF ( PA_EVENTS_PKG.Is_Event_Billed
           ( L_Project_ID
           , L_Task_ID
           , L_Event_Num
           , L_Bill_Amount ) = 'Y')
       THEN
        FND_MESSAGE.set_name('OKE' , 'OKE_BILL_EVENT_PROCESSED');
        FND_MESSAGE.set_token('EVENT' , L_Event_Num);
        FND_MSG_PUB.add;
        RAISE FND_API.G_EXC_ERROR;
       ELSE
        PA_EVENTS_PKG.Delete_Row(X_Rowid => l_rowid);
      END IF;
    END IF;
  END IF;

  DELETE FROM oke_k_billing_events
      WHERE ROWID = L_oke_RowID;

EXCEPTION
 WHEN OTHERS THEN
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => G_Pkg_Name
    , p_procedure_name  => 'DELETE_BILLING_INFO' );
  END IF;
  RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
END Delete_Billing_Info;

PROCEDURE Lock_Billing_Info
( P_Deliverable_ID             IN      NUMBER
, P_Billing_Event_ID           IN      NUMBER
, P_Bill_Event_Type            IN      VARCHAR2
, P_Bill_Event_Date            IN      DATE
, P_Bill_Project_ID            IN      NUMBER
, P_Bill_Task_ID               IN      NUMBER
, P_Bill_Org_ID                IN      NUMBER
, P_Bill_Line_ID               IN      NUMBER
, P_Bill_Chg_Req_ID            IN      NUMBER
, P_Bill_Item_ID               IN      NUMBER
, P_Bill_Description           IN      VARCHAR2
, P_Bill_Unit_Price            IN      NUMBER
, P_Bill_Quantity              IN      NUMBER
, P_Bill_Currency_Code         IN      VARCHAR2
, P_Bill_Rate_Type             IN      VARCHAR2
, P_Bill_Rate_Date             IN      DATE
, P_Bill_Exchange_Rate         IN      NUMBER
, P_Revenue_Amount             IN      NUMBER
, P_Bill_Of_Lading             IN      VARCHAR2
, P_Bill_Serial_Num            IN      VARCHAR2
, P_Bill_Fund_Ref1             IN      VARCHAR2
, P_Bill_Fund_Ref2             IN      VARCHAR2
, P_Bill_Fund_Ref3             IN      VARCHAR2
) IS

CURSOR c IS
  SELECT bill_event_type
  ,      bill_event_date
  ,      billing_event_id
  , 	 pa_event_id
  , 	 k_header_id
  , 	 k_line_id
  , 	 deliverable_id
  ,      bill_project_id
  ,      bill_task_id
  ,      bill_organization_id
  ,      bill_line_id
  ,      bill_chg_req_id
  ,      bill_item_id
  ,      bill_description
  ,      bill_unit_price
  ,      bill_quantity
  ,      revenue_amount
  ,      bill_currency_code
  ,      bill_rate_type
  ,      bill_rate_date
  ,      bill_exchange_rate
  ,      bill_bill_of_lading
  ,      bill_serial_num
  ,      bill_fund_ref1
  ,      bill_fund_ref2
  ,      bill_fund_ref3
  FROM oke_k_billing_events
  WHERE billing_event_id = P_Billing_Event_ID
  FOR UPDATE OF Billing_Event_ID NOWAIT;

  RecInfo c%rowtype;

BEGIN

  OPEN c;
  FETCH c INTO RecInfo;
  IF ( c%notfound ) THEN
    CLOSE c;
    FND_MESSAGE.Set_Name('FND' , 'FORM_RECORD_DELETED');
    APP_EXCEPTION.Raise_Exception;
  END IF;
  CLOSE c;

  IF (    ((RecInfo.bill_event_type = P_Bill_Event_Type)
           OR ((RecInfo.bill_event_type is null) AND (P_Bill_Event_Type is null)))
      AND ((RecInfo.bill_event_date = P_Bill_Event_Date)
           OR ((RecInfo.bill_event_date is null) AND (P_Bill_Event_Date is null)))
      AND ((RecInfo.billing_event_id = P_Billing_Event_ID)
           OR ((RecInfo.billing_event_id is null) AND (P_Billing_Event_ID is null)))
      AND ((RecInfo.bill_project_id = P_Bill_Project_ID)
           OR ((RecInfo.bill_project_id is null) AND (P_Bill_Project_ID is null)))
      AND ((RecInfo.bill_task_id = P_Bill_Task_ID)
           OR ((RecInfo.bill_task_id is null) AND (P_Bill_Task_ID is null)))
      AND ((RecInfo.bill_organization_id = P_Bill_Org_ID)
           OR ((RecInfo.bill_organization_id is null) AND (P_Bill_Org_ID is null)))
      AND ((RecInfo.bill_line_id = P_Bill_Line_ID)
           OR ((RecInfo.bill_line_id is null) AND (P_Bill_Line_ID is null)))
      AND ((RecInfo.bill_chg_req_id = P_Bill_Chg_Req_ID)
           OR ((RecInfo.bill_chg_req_id is null) AND (P_Bill_Chg_Req_ID is null)))
      AND ((RecInfo.bill_item_id = P_Bill_Item_ID)
           OR ((RecInfo.bill_item_id is null) AND (P_Bill_Item_ID is null)))
      AND ((RecInfo.bill_description = P_Bill_Description)
           OR ((RecInfo.bill_description is null) AND (P_Bill_Description is null)))
--       AND ((RecInfo.unit_price = P_Unit_Price)
--            OR ((RecInfo.unit_price is null) AND (P_Unit_Price is null)))
      AND ((RecInfo.bill_unit_price = P_Bill_Unit_Price)
           OR ((RecInfo.bill_unit_price is null) AND (P_Bill_Unit_Price is null)))
      AND ((RecInfo.bill_quantity = P_Bill_Quantity)
           OR ((RecInfo.bill_quantity is null) AND (P_Bill_Quantity is null)))
      AND ((RecInfo.revenue_amount = P_Revenue_Amount)
           OR ((RecInfo.revenue_amount is null) AND (P_Revenue_Amount is null)))
      AND ((RecInfo.bill_currency_code = P_Bill_Currency_Code)
           OR ((RecInfo.bill_currency_code is null) AND (P_Bill_Currency_Code is null)))
      AND ((RecInfo.bill_rate_type = P_Bill_Rate_Type)
           OR ((RecInfo.bill_rate_type is null) AND (P_Bill_Rate_Type is null)))
      AND ((RecInfo.bill_rate_date = P_Bill_Rate_Date)
           OR ((RecInfo.bill_rate_date is null) AND (P_Bill_Rate_Date is null)))
      AND ((RecInfo.bill_exchange_rate = P_Bill_Exchange_Rate)
           OR ((RecInfo.bill_exchange_rate is null) AND (P_Bill_Exchange_Rate is null)))
      AND ((RecInfo.bill_bill_of_lading = P_Bill_Of_Lading)
           OR ((RecInfo.bill_bill_of_lading is null) AND (P_Bill_Of_Lading is null)))
      AND ((RecInfo.bill_serial_num = P_Bill_Serial_Num)
           OR ((RecInfo.bill_serial_num is null) AND (P_Bill_Serial_Num is null)))
      AND ((RecInfo.bill_fund_ref1 = P_Bill_Fund_Ref1)
           OR ((RecInfo.bill_fund_ref1 is null) AND (P_Bill_Fund_Ref1 is null)))
      AND ((RecInfo.bill_fund_ref2 = P_Bill_Fund_Ref2)
           OR ((RecInfo.bill_fund_ref2 is null) AND (P_Bill_Fund_Ref2 is null)))
      AND ((RecInfo.bill_fund_ref3 = P_Bill_Fund_Ref3)
           OR ((RecInfo.bill_fund_ref3 is null) AND (P_Bill_Fund_Ref3 is null)))
  ) THEN
    NULL;
  ELSE
    FND_MESSAGE.Set_NAme('FND' , 'FORM_RECORD_CHANGED');
    APP_EXCEPTION.Raise_Exception;
  END IF;

  RETURN;

END Lock_Billing_Info;


PROCEDURE Populate_MC_Columns
( P_Event_ID                    IN      NUMBER
, x_Bill_Trans_Currency_Code    OUT     NOCOPY         VARCHAR2
, x_Bill_Trans_Bill_Amount      OUT     NOCOPY         NUMBER
, x_Bill_Trans_rev_Amount       OUT     NOCOPY         NUMBER
, x_Project_Currency_Code       OUT     NOCOPY         VARCHAR2
, x_Project_Rate_Type	        OUT     NOCOPY         VARCHAR2
, x_Project_Rate_Date	        OUT     NOCOPY         DATE
, x_Project_Exchange_Rate       OUT     NOCOPY         NUMBER
, x_Project_inv_Rate_Date       OUT     NOCOPY         DATE
, x_Project_Inv_Exchange_Rate   OUT     NOCOPY         NUMBER
, x_Project_Bill_Amount	        OUT     NOCOPY         NUMBER
, x_Project_Rev_Rate_Date       OUT     NOCOPY         DATE
, x_Project_Rev_Exchange_Rate   OUT     NOCOPY         NUMBER
, x_Project_Revenue_Amount      OUT     NOCOPY         NUMBER
, x_ProjFunc_Currency_Code 	OUT     NOCOPY         VARCHAR2
, x_ProjFunc_Rate_Type		OUT 	NOCOPY         VARCHAR2
, x_ProjFunc_Rate_Date		OUT     NOCOPY         DATE
, x_ProjFunc_Exchange_Rate 	OUT     NOCOPY         NUMBER
, x_ProjFunc_Inv_Rate_Date 	OUT     NOCOPY         DATE
, x_ProjFunc_Inv_Exchange_Rate	OUT     NOCOPY         NUMBER
, x_ProjFunc_Bill_Amount	OUT     NOCOPY         NUMBER
, x_ProjFunc_Rev_Rate_Date 	OUT     NOCOPY         DATE
, x_Projfunc_Rev_Exchange_Rate	OUT     NOCOPY         NUMBER
, x_ProjFunc_Revenue_Amount	OUT     NOCOPY         NUMBER
, x_Funding_Rate_Type		OUT     NOCOPY         VARCHAR2
, x_Funding_Rate_Date		OUT     NOCOPY         DATE
, x_Funding_Exchange_Rate	OUT     NOCOPY         NUMBER
, x_Invproc_Currency_Code	OUT     NOCOPY         VARCHAR2
, x_Invproc_Rate_Type		OUT     NOCOPY         VARCHAR2
, x_Invproc_Rate_Date		OUT     NOCOPY         DATE
, x_Invproc_Exchange_Rate	OUT     NOCOPY         NUMBER
, x_Revproc_Currency_Code	OUT     NOCOPY         VARCHAR2
, x_Revproc_Rate_Type		OUT     NOCOPY         VARCHAR2
, x_Revproc_Rate_Date		OUT     NOCOPY         DATE
, x_Revproc_Exchange_Rate	OUT     NOCOPY         NUMBER
, x_Inv_Gen_Rejection_Code 	OUT     NOCOPY         VARCHAR2  ) IS

   BillInfoRec BillInfo%rowtype;

   l_api_name       CONSTANT VARCHAR2(30) := 'Populate_MC_Columns';
   l_multi_currency_billing_flag     VARCHAR2(15);
   l_baseline_funding_flag           VARCHAR2(15);
   l_revproc_currency_code           VARCHAR2(15);
   l_invproc_currency_code           VARCHAR2(30);
   l_project_currency_code           VARCHAR2(15);
   l_project_bil_rate_date_code      VARCHAR2(30);
   l_project_bil_rate_type           VARCHAR2(30);
   l_project_bil_rate_date           DATE;
   l_project_bil_exchange_rate       NUMBER;
   l_projfunc_currency_code          VARCHAR2(15);
   l_projfunc_bil_rate_date_code     VARCHAR2(30);
   l_projfunc_bil_rate_type          VARCHAR2(30);
   l_invproc_currency_type           VARCHAR2(30);
   l_projfunc_bil_rate_date          DATE;
   l_projfunc_bil_exchange_rate      NUMBER;
   l_funding_rate_date_code          VARCHAR2(30);
   l_funding_rate_type               VARCHAR2(30);
   l_funding_rate_date               DATE;
   l_funding_exchange_rate           NUMBER;
   l_return_status                   VARCHAR2(30);
   l_msg_count                       NUMBER;
   l_msg_data                        VARCHAR2(30);

BEGIN

  OPEN BillInfo(P_Event_ID);
  FETCH BillInfo INTO BillInfoRec;
  CLOSE BillInfo;

  --
  -- populate currency information based on similar logic in the PA
  -- Events form
  --
  PA_MULTI_CURRENCY_BILLING.get_project_defaults
  ( P_project_id                  => BillInfoRec.Bill_Project_ID
  , X_multi_currency_billing_flag => l_multi_currency_billing_flag
  , X_baseline_funding_flag       => l_baseline_funding_flag
  , X_revproc_currency_code       => l_revproc_currency_code
  , X_invproc_currency_type       => l_invproc_currency_type
  , X_invproc_currency_code       => l_invproc_currency_code
  , X_project_currency_code       => l_project_currency_code
  , X_project_bil_rate_date_code  => l_project_bil_rate_date_code
  , X_project_bil_rate_type       => l_project_bil_rate_type
  , X_project_bil_rate_date       => l_project_bil_rate_date
  , X_project_bil_exchange_rate   => l_project_bil_exchange_rate
  , X_projfunc_currency_code      => l_projfunc_currency_code
  , X_projfunc_bil_rate_date_code => l_projfunc_bil_rate_date_code
  , X_projfunc_bil_rate_type      => l_projfunc_bil_rate_type
  , X_projfunc_bil_rate_date      => l_projfunc_bil_rate_date
  , X_projfunc_bil_exchange_rate  => l_projfunc_bil_exchange_rate
  , X_funding_rate_date_code      => l_funding_rate_date_code
  , X_funding_rate_type           => l_funding_rate_type
  , X_funding_rate_date           => l_funding_rate_date
  , X_funding_exchange_rate       => l_funding_exchange_rate
  , X_return_status               => l_return_status
  , X_msg_count                   => l_msg_count
  , X_msg_data                    => l_msg_data);

  IF ( l_return_status <> FND_API.G_RET_STS_SUCCESS ) THEN
    RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  x_Bill_Trans_Currency_Code    := BillInfoRec.bill_currency_code;
  x_Bill_Trans_Bill_Amount      := BillInfoRec.Bill_Amount;
  x_Bill_Trans_rev_Amount       := BillInfoRec.Revenue_Amount;


 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Project Currency = ' || l_project_currency_code);
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Project Rate Type = ' || l_project_bil_rate_type);
 END IF;
  x_Project_Currency_Code       := l_project_currency_code;
  IF ( BillInfoRec.Bill_Currency_Code <> l_project_currency_code ) THEN
    x_Project_Rate_Type         := l_project_bil_rate_type;
  END IF;
  x_Project_Rate_Date           := NULL;
  x_Project_Exchange_Rate       := NULL;
  x_Project_inv_Rate_Date       := NULL;
  x_Project_Inv_Exchange_Rate   := NULL;
  x_Project_Bill_Amount         := NULL;
  x_Project_Rev_Rate_Date       := NULL;
  x_Project_Rev_Exchange_Rate   := NULL;
  x_Project_Revenue_Amount      := NULL;


 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Project Func Currency = ' || l_projfunc_currency_code);
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Project Func Rate Type = ' || l_projfunc_bil_rate_type);
 END IF;
  x_ProjFunc_Currency_Code      := l_projfunc_currency_code;
  IF ( BillInfoRec.Bill_Currency_Code <> l_projfunc_currency_code ) THEN
    x_ProjFunc_Rate_Type        := l_projfunc_bil_rate_type;
  END IF;
  x_ProjFunc_Rate_Date          := NULL;
  x_ProjFunc_Exchange_Rate      := NULL;
  x_ProjFunc_Inv_Rate_Date      := NULL;
  x_ProjFunc_Inv_Exchange_Rate  := NULL;
  x_ProjFunc_Bill_Amount        := NULL;
  x_ProjFunc_Rev_Rate_Date      := NULL;
  x_Projfunc_Rev_Exchange_Rate  := NULL;
  x_ProjFunc_Revenue_Amount     := NULL;

  x_Funding_Rate_Type           := l_funding_rate_type;
  x_Funding_Rate_Date           := NULL;
  x_Funding_Exchange_Rate       := NULL;

  IF ( BillInfoRec.Bill_Currency_Code <> l_invproc_currency_code ) THEN
    IF ( l_invproc_currency_type = 'PROJECT_CURRENCY' ) THEN
      x_Invproc_Currency_Code   := l_invproc_currency_code;
      x_Invproc_Rate_Type       := l_project_bil_rate_type;
    ELSIF ( l_invproc_currency_type = 'PROJFUNC_CURRENCY' ) THEN
      x_Invproc_Currency_Code   := l_invproc_currency_code;
      x_Invproc_Rate_Type       := l_projfunc_bil_rate_type;
    ELSIF ( l_invproc_currency_type = 'FUNDING_CURRENCY' ) THEN
      x_Invproc_Currency_Code   := NULL;
      x_Invproc_Rate_Type       := l_funding_rate_type;
    END IF;
  ELSE
    x_Invproc_Currency_Code     := l_invproc_currency_code;
    x_Invproc_Rate_Type         := NULL;
  END IF;
  x_Invproc_Rate_Date           := NULL;
  x_Invproc_Exchange_Rate       := NULL;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Inv Proc Currency = ' || x_invproc_currency_code);
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Inv Proc Rate Type = ' || x_invproc_rate_type);
 END IF;
  x_Revproc_Currency_Code       := l_revproc_currency_code;
  x_Revproc_Rate_Type           := x_projfunc_rate_type;
  x_Revproc_Rate_Date           := NULL;
  x_Revproc_Exchange_Rate       := NULL;

 IF ( FND_LOG.LEVEL_PROCEDURE >= FND_LOG.G_CURRENT_RUNTIME_LEVEL) THEN
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Rev Proc Currency = ' || x_revproc_currency_code);
  FND_LOG.STRING( FND_LOG.LEVEL_PROCEDURE ,g_module||l_api_name,'Rev Proc Rate Type = ' || x_revproc_rate_type);
 END IF;
  x_Inv_Gen_Rejection_Code      := NULL;

EXCEPTION
WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => G_Pkg_Name
    , p_procedure_name  => 'POPULATE_MC_COLUMNS' );
  END IF;

WHEN OTHERS THEN
  IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
    FND_MSG_PUB.add_exc_msg
    ( p_pkg_name        => G_Pkg_Name
    , p_procedure_name  => 'POPULATE_MC_COLUMNS' );
  END IF;

END Populate_Mc_Columns;



END OKE_DELIVERABLE_BILLING_PVT;

/
