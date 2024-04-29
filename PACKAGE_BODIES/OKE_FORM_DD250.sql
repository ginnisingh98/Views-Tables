--------------------------------------------------------
--  DDL for Package Body OKE_FORM_DD250
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_FORM_DD250" AS
/* $Header: OKEMIRRB.pls 120.5 2005/07/14 16:07:55 ausmani noship $ */

--
-- Global Declarations
--
G_PKG_NAME     VARCHAR2(30) := 'OKE_FORM_DD250';
g_module          CONSTANT VARCHAR2(250) := 'oke.plsql.oke_form_dd20.';

--
-- Private Procedures and Functions
--

--
-- Raise Business Event to generate XML
--
PROCEDURE Raise_Business_Event
( P_Contract_Number      IN     VARCHAR2
, P_Order_Number         IN     VARCHAR2
, P_Shipment_Number      IN     VARCHAR2
, P_Form_Header_ID       IN     NUMBER
) IS

MapCode      VARCHAR2(30) := 'OKE_DD250_DLF10_OUT';
TxnType      VARCHAR2(30) := 'ECX';
EventName    VARCHAR2(80) := 'oracle.apps.oke.forms.DD250.Generate';

ParamList    wf_parameter_list_t := wf_parameter_list_t();
l_org_id             NUMBER; -- for MOAC

  cursor c_org is
    select authoring_org_id
    from oke_k_headers_v
    where k_header_id =P_form_Header_id;


BEGIN
  --
  -- Building Parameter List
  --
  OPEN c_org;
  FETCH c_org INTO l_org_id;
  CLOSE c_org;

  wf_event.AddParameterToList( p_name => 'ECX_MAP_CODE'
                             , p_value => MapCode
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_TRANSACTION_TYPE'
                             , p_value => TxnType
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_DOCUMENT_ID'
                             , p_value => P_Form_Header_ID
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_PARAMETER1'
                             , p_value => P_Contract_Number
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_PARAMETER2'
                             , p_value => P_Order_Number
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_PARAMETER3'
                             , p_value => P_Shipment_Number
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_PARAMETER4'
                             , p_value => to_char(sysdate , 'DDMONRRHH24MISS')
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ECX_PARAMETER5'
                             , p_value => FND_GLOBAL.User_Name
                             , p_parameterList => ParamList );

  wf_event.AddParameterToList( p_name => 'ORG_ID'
                             , p_value => l_org_ID
                             , p_parameterList => ParamList );


  IF ( NVL( FND_PROFILE.VALUE('AFLOG_ENABLED') , 'N' ) = 'Y' ) THEN
    wf_event.AddParameterToList( p_name => 'ECX_DEBUG_LEVEL'
                               , p_value => '3'
                               , p_parameterList => ParamList );
  END IF;

  --
  -- Raise Event
  --
  wf_event.Raise( p_event_name => EventName
                , p_event_key  => to_char(sysdate , 'YYYYMMDD HH24MISS')
                , p_parameters => ParamList );

  ParamList.DELETE;

EXCEPTION
  WHEN OTHERS THEN
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => 'RAISE_BUSINESS_EVENT' );
    END IF;
    Raise;

END Raise_Business_Event;


--
-- Assign Shipment Number based on DFARS
--
FUNCTION Shipment_Number
( P_K_Header_ID          IN     NUMBER
, P_Inv_Org_ID           IN     NUMBER
, P_Delivery_ID          IN     NUMBER
, P_Ship_From_Loc_ID     IN     NUMBER
) RETURN VARCHAR2 IS

ShipNumPfx    VARCHAR2(30);
LastShipNum   VARCHAR2(30);
NextShipNum   VARCHAR2(30);

CURSOR ShipNumPrefix IS
  SELECT rpad(Organization_Code , 3 , 'X')
  FROM   mtl_parameters
  WHERE  organization_id = P_Inv_Org_ID;

CURSOR ShipNum IS
  SELECT MAX(Form_Header_Number)
  FROM   oke_k_form_headers
  WHERE  k_header_id = P_K_Header_ID
  AND    print_form_code = 'DD250'
  AND    substr(form_header_number , 1 , 3 ) = ShipNumPfx;

BEGIN

  fnd_file.put_line(fnd_file.log , '... Assigning new shipment number');

  --
  -- Getting prefix from user extension.  If none, derive it from org
  --
  ShipNumPfx := OKE_FORM_DD250_EXT.Override_Shipment_Prefix
                ( P_K_Header_ID      => P_K_Header_ID
                , P_Delivery_ID      => P_Delivery_ID
                , P_Inv_Org_ID       => P_Inv_Org_ID
                , P_Ship_From_Loc_ID => P_Ship_From_Loc_ID );

  if ( ShipNumPfx is NULL ) then
    OPEN ShipNumPrefix;
    FETCH ShipNumPrefix INTO ShipNumPfx;
    CLOSE ShipNumPrefix;
  end if;

  fnd_file.put_line(fnd_file.log , 'Shipment Prefix = ' || ShipNumPfx);

  OPEN ShipNum;
  FETCH ShipNum INTO LastShipNum;
  CLOSE ShipNum;

  fnd_file.put_line(fnd_file.log , 'Last Shipment Num = ' || LastShipNum);

  IF ( LastShipNum IS NULL ) THEN
    --
    -- This is the first DD250 for this contract and org
    --
    NextShipNum := ShipNumPfx || '0001';

  ELSE
    --
    -- Need to create new number, increment numeric portion (char 4 to 7) by 1
    --
    NextShipNum := ShipNumPfx ||
                   lpad( to_number( substr( LastShipNum , 4 , 4 ) ) + 1
                       , 4 , '0' );

  END IF;

  fnd_file.put_line(fnd_file.log , 'Next Shipment Num = ' || NextShipNum);

  RETURN ( NextShipNum );

EXCEPTION
  WHEN OTHERS THEN
    Raise;
END Shipment_Number;


--
--  Name          : Create_DD250
--  Pre-reqs      : None
--  Function      : This procedure creates a copy of DD250
--
--
--  Parameters    :
--  IN            : P_COMMIT          VARCHAR2
--                  P_HEADER_REC      HDR_REC_TYPE
--                  P_LINE_TBL        LINE_TBL_TYPE
--  OUT           : X_RETURN_STATUS   VARCHAR2
--                  X_MSG_COUNT       NUMBER
--                  X_MSG_DATA        VARCHAR2
--
--  Returns       : None
--

PROCEDURE Create_DD250
( P_Commit               IN     VARCHAR2
, P_Hdr_Rec              IN     Hdr_Rec_Type
, P_Line_Tbl             IN     Line_Tbl_Type
, X_Msg_Count            OUT NOCOPY    NUMBER
, X_Msg_Data             OUT NOCOPY    VARCHAR2
, X_Return_Status        OUT NOCOPY    VARCHAR2
) IS

  l_hdr_rec       Hdr_Rec_Type;
  l_line_tbl      Line_Tbl_Type;

  pfh_rec         OKE_PRINT_FORM_PUB.PFH_Rec_Type;
  pfl_tbl         OKE_PRINT_FORM_PUB.PFL_Tbl_Type;
  i               NUMBER;

  CURSOR knum1
  ( C_K_Header_ID  NUMBER
  ) IS
    SELECT EK.K_Header_ID               Contract_Header_ID
    ,      CK2.Contract_Number          Contract_Number
    ,      DECODE( EK.BOA_ID ,
                   NULL , NULL ,
                   CK.Contract_Number ) Order_Number
    FROM   okc_k_headers_all_b     CK2
    ,      okc_k_headers_all_b     CK
    ,      oke_k_headers       EK
    WHERE  EK.K_Header_ID = C_K_Header_ID
    AND    CK.ID  = EK.K_Header_ID
    AND    CK2.ID = NVL(EK.BOA_ID , EK.K_Header_ID);

  CURSOR knum2
  ( C_K_Header      VARCHAR2
  , C_K_Type        VARCHAR2
  , C_Buy_Or_Sell   VARCHAR2
  ) IS
    SELECT EK.K_Header_ID               Contract_Header_ID
    ,      CK2.Contract_Number          Contract_Number
    ,      DECODE( EK.BOA_ID ,
                   NULL , NULL ,
                   CK.Contract_Number ) Order_Number
    FROM   okc_k_headers_all_b     CK2
    ,      okc_k_headers_all_b     CK
    ,      oke_k_headers       EK
    WHERE  EK.K_Number_Disp = C_K_Header
    AND    EK.K_Type_Code   = C_K_Type
    AND    CK.ID  = EK.K_Header_ID
    AND    CK.Buy_Or_Sell = C_Buy_Or_Sell
    AND    CK2.ID = NVL(EK.BOA_ID , EK.K_Header_ID);

  ContractNum    VARCHAR2(120);
  OrderNum       VARCHAR2(120);
  ContractHdrID  NUMBER;

  CURSOR ShipmentNum
  ( C_K_Header_ID   NUMBER
  , C_Shipment_Num  VARCHAR2
  ) IS
    SELECT Form_Header_ID
    FROM   oke_k_form_headers
    WHERE  k_header_id = C_K_Header_ID
    AND    print_form_code = 'DD250'
    AND    form_header_number = C_Shipment_Num;

  FormHdrID       NUMBER := NULL;

  progress        NUMBER;

BEGIN

    progress := 10;

    IF ( p_hdr_rec.Contract_Header_ID IS NOT NULL ) THEN

      OPEN knum1 ( p_hdr_rec.Contract_Header_ID );
      FETCH knum1 INTO ContractHdrID, ContractNum , OrderNum;
      CLOSE knum1;

    ELSE

      OPEN knum2 ( p_hdr_rec.Contract_Number
                 , p_hdr_rec.K_Type_Code
                 , p_hdr_rec.Buy_Or_Sell );
      FETCH knum2 INTO ContractHdrID, ContractNum , OrderNum;
      CLOSE knum2;

    END IF;

    --
    -- Calling User Extension to override any collected data
    --
    progress := 15;

    OKE_FORM_DD250_EXT.Override_Form_Data
    ( P_K_Header_ID  => ContractHdrID
    , P_Delivery_ID  => l_hdr_rec.Reference1
    , P_Hdr_Rec      => p_hdr_rec
    , P_Line_Tbl     => p_line_tbl
    , X_Hdr_Rec      => l_hdr_rec
    , X_Line_Tbl     => l_line_tbl
    );

    --
    -- Preparing Form Header Record
    --
    progress := 20;

    pfh_rec.Print_Form_Code    := 'DD250';
    pfh_rec.Form_Header_Number := l_hdr_rec.Shipment_Number;
    pfh_rec.Form_Date          := sysdate;
    pfh_rec.Contract_Header_ID := ContractHdrID;
    pfh_rec.status_code        := 'CREATED';
    pfh_rec.text01             := ContractNum;
    pfh_rec.text02             := OrderNum;
    pfh_rec.text03             := l_hdr_rec.Shipment_Number;
    pfh_rec.text04             := l_hdr_rec.Bill_Of_Lading;
    pfh_rec.text06             := l_hdr_rec.Discount_Terms;
    IF ( substr(l_hdr_rec.Acceptance_Point,1,1) IN ( 'S' , 'D' ) ) THEN
      pfh_rec.text07           := substr(l_hdr_rec.Acceptance_Point , 1 , 1);
    END IF;
    pfh_rec.text08             := l_hdr_rec.Contractor;
    pfh_rec.text09             := l_hdr_rec.Contractor_Code;
    pfh_rec.text10             := l_hdr_rec.Customer;
    pfh_rec.text11             := l_hdr_rec.Customer_Code;
    pfh_rec.text12             := l_hdr_rec.Ship_From;
    pfh_rec.text13             := l_hdr_rec.Ship_From_Code;
    IF ( substr(l_hdr_rec.FOB,1,1) IN ( 'S' , 'O' , 'D' ) ) THEN
      pfh_rec.text14           := substr(l_hdr_rec.FOB , 1 , 1);
    END IF;
    pfh_rec.text15             := l_hdr_rec.Paid_By;
    pfh_rec.text16             := l_hdr_rec.Paid_By_Code;
    pfh_rec.text17             := l_hdr_rec.Ship_To;
    pfh_rec.text18             := l_hdr_rec.Ship_To_Code;
    pfh_rec.text19             := l_hdr_rec.Mark_For;
    pfh_rec.text20             := l_hdr_rec.Mark_For_Code;
    -- Bug 3268438 - check if Acceptance Method is a valid value
    IF (l_hdr_rec.Acceptance_Method IN ('GOVTREP','FASTPAY','EDI','WAWF','COC','INTERNAL') ) THEN
      pfh_rec.text21             := l_hdr_rec.Acceptance_Method;
    END IF;
    IF ( substr(l_hdr_rec.Inspection_Point,1,1) IN ( 'S' , 'D' , 'N' ) ) THEN
      pfh_rec.text22           := substr(l_hdr_rec.Inspection_Point , 1 , 1);
    END IF;
    pfh_rec.text23             := l_hdr_rec.Weight_UOM_Code;
    pfh_rec.text24             := l_hdr_rec.Volume_UOM_Code;
    pfh_rec.text26             := l_hdr_rec.Ship_Method;
    pfh_rec.date01             := l_hdr_rec.Shipment_Date;
    pfh_rec.number01           := l_hdr_rec.Gross_Weight;
    pfh_rec.number02           := l_hdr_rec.Net_Weight;
    pfh_rec.number03           := l_hdr_rec.Volume;
    pfh_rec.number04           := NULL; /* Number of Containers */
    pfh_rec.Reference1         := l_hdr_rec.Reference1;
    pfh_rec.Reference2         := l_hdr_rec.Reference2;
    pfh_rec.Reference3         := l_hdr_rec.Reference3;
    pfh_rec.Reference4         := l_hdr_rec.Reference4;
    pfh_rec.Reference5         := l_hdr_rec.Reference5;

    i := l_line_tbl.FIRST;

    LOOP

      progress := 30;

      pfl_tbl(i).Form_Line_Number := i;
      pfl_tbl(i).text01           := l_line_tbl(i).Line_Number;
      pfl_tbl(i).text02           := l_line_tbl(i).Item_Number;
      pfl_tbl(i).text03           := l_line_tbl(i).UOM;
      pfl_tbl(i).text04           := l_line_tbl(i).Natl_Stock_Number;
      pfl_tbl(i).text05           := l_line_tbl(i).Item_Description;
      pfl_tbl(i).text06           := l_line_tbl(i).Line_Description;
      pfl_tbl(i).text07           := l_line_tbl(i).Line_Comments;
      pfl_tbl(i).number01         := l_line_tbl(i).Shipped_Quantity;
      pfl_tbl(i).number02         := l_line_tbl(i).Unit_Price;
      pfl_tbl(i).number03         := l_line_tbl(i).Amount;
      pfl_tbl(i).reference1       := l_line_tbl(i).Reference1;
      pfl_tbl(i).reference2       := l_line_tbl(i).Reference2;
      pfl_tbl(i).reference3       := l_line_tbl(i).Reference3;
      pfl_tbl(i).reference4       := l_line_tbl(i).Reference4;
      pfl_tbl(i).reference5       := l_line_tbl(i).Reference5;

      EXIT WHEN i = l_line_tbl.LAST;
      i := l_line_tbl.NEXT(i);

    END LOOP;

    progress := 40;

    --
    -- Check to see if DD250 record exists for this shipment
    --
    OPEN ShipmentNum( l_hdr_rec.Contract_Header_ID
                    , l_hdr_rec.Shipment_Number );
    FETCH ShipmentNum INTO FormHdrID;
    CLOSE ShipmentNum;

    IF ( FormHdrID IS NULL ) THEN
      --
      -- Form does not exist, create a new one
      --
      progress := 50;

      OKE_PRINT_FORM_PUB.Create_Print_Form
      ( p_api_version          => 1.0
      , p_commit               => FND_API.G_FALSE
      , p_init_msg_list        => FND_API.G_FALSE
      , x_msg_count            => X_Msg_Count
      , x_msg_data             => X_Msg_Data
      , x_return_status        => X_Return_Status
      , p_header_rec           => pfh_rec
      , p_line_tbl             => pfl_tbl
      , x_form_header_id       => FormHdrID
      );

      IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
	RAISE FND_API.G_EXC_ERROR;
      END IF;

    ELSE
      --
      -- Form exist, update it
      --
      progress := 60;

      pfh_rec.Form_Header_ID := FormHdrID;

      progress := 70;

      OKE_PRINT_FORM_PUB.Update_Print_Form
      ( p_api_version          => 1.0
      , p_commit               => FND_API.G_FALSE
      , p_init_msg_list        => FND_API.G_FALSE
      , x_msg_count            => X_Msg_Count
      , x_msg_data             => X_Msg_Data
      , x_return_status        => X_Return_Status
      , p_header_rec           => pfh_rec
      , p_line_tbl             => pfl_tbl
      );

      IF ( x_return_status = FND_API.G_RET_STS_UNEXP_ERROR ) THEN
	RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      ELSIF ( x_return_status = FND_API.G_RET_STS_ERROR ) THEN
	RAISE FND_API.G_EXC_ERROR;
      END IF;

    END IF;

    progress := 80;

    pfl_tbl.DELETE;

    progress := 90;

    Raise_Business_Event( P_Contract_Number => ContractNum
                        , P_Order_Number => OrderNum
                        , P_Shipment_Number => l_hdr_rec.Shipment_Number
                        , P_Form_Header_ID => FormHdrID
                        );

    fnd_file.put_line(fnd_file.log , '... Business Event raised');

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
      FND_MSG_PUB.add_exc_msg
                 ( p_pkg_name        => G_PKG_NAME
                 , p_procedure_name  => 'CREATE_DD250(' || progress || ')');
    END IF;
    FND_MSG_PUB.Count_And_Get( p_count => x_msg_count
                             , p_data  => x_msg_data );

END Create_DD250;


--
--  Name          : Create_DD250_From_Delivery
--  Pre-reqs      : run as concurrent request
--  Function      : This procedure creates a copy of DD250 for a delivery
--
--
--  Parameters    :
--  IN            : P_DELIVERY_ID     NUMBER
--  OUT           : X_RETURN_STATUS   VARCHAR2
--                  X_MSG_COUNT       NUMBER
--                  X_MSG_DATA        VARCHAR2
--
--  Returns       : None
--

PROCEDURE Create_DD250_From_Delivery
( P_Delivery_ID          IN     NUMBER
, X_Msg_Count            OUT NOCOPY    NUMBER
, X_Msg_Data             OUT NOCOPY    VARCHAR2
, X_Return_Status        OUT NOCOPY    VARCHAR2
) IS

  CURSOR FrmHdr IS
    SELECT DISTINCT
           DTL.Source_Header_ID     K_Header_ID
    ,      DTL.Source_Line_ID       Deliverable_ID
    ,      DTL.Organization_ID      Inv_Org_ID
    ,      DTL.Ship_To_Location_ID  Ship_To_Loc
    ,      DTL.Ship_From_Location_ID Ship_From_Loc
    ,      DLV.FOB_Code             FOB_Code
    ,      DLV.Gross_Weight         Gross_Weight
    ,      DLV.Net_Weight           Net_Weight
    ,      DLV.Weight_UOM_Code      Weight_UOM_Code
    ,      DLV.Volume               Volume
    ,      DLV.Volume_UOM_Code      Volume_UOM_Code
    FROM   wsh_delivery_details     DTL
    ,      wsh_delivery_assignments_v ASGN
    ,      wsh_new_deliveries       DLV
    WHERE  DLV.delivery_id          = P_Delivery_ID
    AND    ASGN.delivery_id         = DLV.delivery_id
    AND    DTL.delivery_detail_id   = ASGN.delivery_detail_id
    AND    DTL.source_code          = 'OKE'
    ORDER BY 1, 2, 4;

  FrmHdrRec  FrmHdr%RowType;


  CURSOR FrmLine
  ( C_Delivery_ID   NUMBER
  , C_Inv_Org_ID    NUMBER
  , C_K_Hdr_ID      NUMBER
  , C_Ship_To       NUMBER
  ) IS
    SELECT DTL.Source_Line_ID       Deliverable_ID
    ,      DTL.Inventory_Item_ID    Item_ID
    ,      DTL.Item_Description     Item_Description
    ,      DTL.Shipped_Quantity     Shipped_Qty
    ,      DTL.Serial_Number        Serial_Num
    FROM   wsh_delivery_details     DTL
    ,      wsh_delivery_assignments_v ASGN
    WHERE  ASGN.delivery_id         = C_Delivery_ID
    AND    DTL.Organization_ID      = C_Inv_Org_ID
    AND    DTL.Source_Header_ID     = C_K_Hdr_ID
    -- AND DTL.Ship_To_Location_ID  = C_Ship_To
    AND    DTL.delivery_detail_id   = ASGN.delivery_detail_id
    AND    DTL.source_code          = 'OKE';

  CURSOR PrintForm
  ( C_K_Header_ID   NUMBER
  ) IS
    SELECT 1
    FROM   oke_k_print_forms
    WHERE  k_header_id = C_K_Header_ID
    AND    print_form_code = 'DD250';

  CURSOR ShipmentNum
  ( C_K_Header_ID     NUMBER
  , C_Delivery_ID     NUMBER
  , C_Inv_Org_ID      NUMBER
  ) IS
    SELECT Form_Header_Number
    FROM   oke_k_form_headers
    WHERE  k_header_id = C_K_Header_ID
    AND    print_form_code = 'DD250'
    AND    reference1  = C_Delivery_ID
    AND    reference2  = C_Inv_Org_ID;

  CURSOR LineInfo
  ( C_Deliverable_ID   NUMBER
  ) IS
    SELECT L.Line_Number            Line_Number
    ,      I.Item_Number            Item_Number
    ,      L.NSN_Number             Natl_Stock_Number
    ,      I.Description            Item_Description
    ,      L.Line_Description       Line_Description
    ,      L.Comments               Line_Comments
    ,      nvl( D.Unit_Price , L.Unit_Price )   Unit_Price
    ,      nvl( D.UOM_Code , L.UOM_Code )       UOM_Code
    FROM   oke_k_deliverables_b     D
    ,      oke_k_lines_v            L
    ,      mtl_item_flexfields      I
    WHERE  D.Deliverable_ID        = C_Deliverable_ID
    AND    L.K_Line_ID             = D.K_Line_ID
    AND    I.Organization_ID (+)   = D.Ship_From_Org_ID
    AND    I.Inventory_Item_ID (+) = D.Item_ID;

  LineInfoRec  LineInfo%rowtype;

  CURSOR BillLading IS
    SELECT WDI.Sequence_Number     BOL_Number
    -- ,      WDI.BOL_Issue_Office    BOL_Issue_Office
    -- ,      WDI.BOL_Issued_By       BOL_Issued_By
    -- ,      WDI.BOL_Date_Issued     BOL_Date_Issued
    FROM   wsh_document_instances  WDI
    ,      wsh_delivery_legs       WDL
    WHERE  WDL.Delivery_ID = P_Delivery_ID
    AND    WDI.Entity_ID   = WDL.Delivery_Leg_ID
    AND    WDI.Entity_Name = 'WSH_DELIVERY_LEGS'
    AND    WDI.Status     <> 'CANCELLED'
    ORDER BY WDL.Sequence_Number;

  BillLadingRec  BillLading%RowType;

  CURSOR OrgAddr ( C_Org_ID  NUMBER ) IS
    SELECT rpad(nvl(Org.Name,' ') , 80 , ' ') ||           /* Name */
           rpad(nvl(Loc.Address_Line_1,' ') , 80 , ' ') || /* Address1 */
           rpad(nvl(Loc.Address_Line_2,' ') , 80 , ' ') || /* Address2 */
           rpad(nvl(Loc.Address_Line_3,' ') , 80 , ' ') || /* Address3 */
           rpad(' ' , 80 , ' ') ||                         /* Address4 */
           rpad(nvl(Loc.Town_Or_City,' ') , 80 , ' ') ||   /* City */
           rpad(nvl(Loc.Region_1,' ') , 80 , ' ') ||       /* County? */
           rpad(nvl(Loc.Region_2,' ') , 80 , ' ') ||       /* State */
           rpad(nvl(Loc.Region_3,' ') , 80 , ' ') ||       /* Province? */
           rpad(nvl(Loc.Postal_Code,' ') , 80 , ' ') ||    /* Postal_Code */
           rpad(nvl(Loc.Country,' ') , 80 , ' ')           /* Country_Code */
           Address
    FROM   hr_locations Loc
    ,      hr_organization_units Org
    WHERE  Loc.Location_ID = Org.Location_ID
    AND    Org.Organization_ID = C_Org_ID;

  CURSOR PartyAddr ( C_Cust_Acct_ID  NUMBER ) IS
    SELECT rpad(nvl(p.Party_Name,' ') , 80 , ' ') ||   /* Name */
           rpad(nvl(p.Address1,' ') , 80 , ' ') ||     /* Address1 */
           rpad(nvl(p.Address2,' ') , 80 , ' ') ||     /* Address2 */
           rpad(nvl(p.Address3,' ') , 80 , ' ') ||     /* Address3 */
           rpad(nvl(p.Address4,' ') , 80 , ' ') ||     /* Address4 */
           rpad(nvl(p.City,' ') , 80 , ' ') ||         /* City */
           rpad(nvl(p.County,' ') , 80 , ' ') ||       /* County */
           rpad(nvl(p.State,' ') , 80 , ' ') ||        /* State */
           rpad(nvl(p.Province,' ') , 80 , ' ') ||     /* Province */
           rpad(nvl(p.Postal_Code,' ') , 80 , ' ') ||  /* Postal_Code */
           rpad(nvl(p.Country,' ') , 80 , ' ')         /* Country_Code */
           Address
    FROM   hz_cust_accounts c
    ,      hz_parties p
    WHERE  c.cust_account_id = C_Cust_Acct_ID
    AND    p.party_id = c.party_id;

  CURSOR CustSiteAddr ( C_Site_ID  NUMBER ) IS
    SELECT rpad(nvl(Party_Name,' ') , 80 , ' ') ||   /* Name */
           rpad(nvl(Address1,' ') , 80 , ' ') ||     /* Address1 */
           rpad(nvl(Address2,' ') , 80 , ' ') ||     /* Address2 */
           rpad(nvl(Address3,' ') , 80 , ' ') ||     /* Address3 */
           rpad(nvl(Address4,' ') , 80 , ' ') ||     /* Address4 */
           rpad(nvl(City,' ') , 80 , ' ') ||         /* City */
           rpad(nvl(County,' ') , 80 , ' ') ||       /* County */
           rpad(nvl(State,' ') , 80 , ' ') ||        /* State */
           rpad(nvl(Province,' ') , 80 , ' ') ||     /* Province */
           rpad(nvl(Postal_Code,' ') , 80 , ' ') ||  /* Postal_Code */
           rpad(nvl(Country,' ') , 80 , ' ')         /* Country_Code */
           Address
    ,      Location_ID
    ,      Site_Use_Code
    FROM   oke_cust_site_uses_v
    WHERE  ID1 = C_Site_ID;

  ContractorAddrRec   OrgAddr%RowType;
  AdminByAddrRec     CustSiteAddr%RowType;
  ShipFrmAddrRec      OrgAddr%RowType;
  ShipToAddrRec       CustSiteAddr%RowType;
  BillToAddrRec       CustSiteAddr%RowType;
  MarkForAddrRec      CustSiteAddr%RowType;

  CURSOR PartySite
  ( C_Deliverable_ID  NUMBER
  , C_Role_Code       VARCHAR2 ) IS
    SELECT pr.jtot_object1_code Object_Code
    ,      pr.object1_id1 ID1
    ,      pr.code
    ,      pr.facility
    FROM   okc_k_party_roles_b pr
    ,      oke_k_deliverables_b kd
    ,    ( select cle_id , cle_id_ascendant , level_sequence
           from okc_ancestrys
           union all
           select id , id , 99999 from okc_k_lines_b ) a
    WHERE  kd.deliverable_id = C_Deliverable_ID
    AND    pr.rle_code = C_Role_Code
    AND    pr.dnz_chr_id = kd.k_header_id
    AND    a.cle_id = kd.k_line_id
    AND  ( ( pr.cle_id IS NULL AND a.cle_id = a.cle_id_ascendant )
         OR pr.cle_id = a.cle_id_ascendant )
    ORDER BY DECODE(pr.cle_id , null , 0 , a.level_sequence) DESC;

  ContractorRec   PartySite%RowType;
  AdminByRec      PartySite%RowType;
  BillToRec       PartySite%RowType;
  MarkForRec      PartySite%RowType;

  CURSOR CageCode
  ( C_Deliverable_ID  NUMBER
  , C_Party_ID        VARCHAR2
  , C_Role_Code       VARCHAR2 ) IS
    SELECT pr.code
    FROM   okc_k_party_roles_b pr
    ,      oke_k_deliverables_b kd
    ,    ( select cle_id , cle_id_ascendant , level_sequence
           from okc_ancestrys
           union all
           select id , id , 99999 from okc_k_lines_b ) a
    WHERE  kd.deliverable_id = C_Deliverable_ID
    AND    pr.rle_code = C_Role_Code
    AND    pr.dnz_chr_id = kd.k_header_id
    AND    a.cle_id = kd.k_line_id
    AND    ( pr.cle_id IS NULL AND a.cle_id = a.cle_id_ascendant )
    AND    pr.object1_id1 = C_Party_ID
    ORDER BY DECODE(pr.cle_id , null , 0 , a.level_sequence) DESC;

  ContractorCode  CageCode%RowType;
  AdminByCode     CageCode%RowType;
  BillToCode      CageCode%RowType;
  MarkForCode     CageCode%RowType;


  CURSOR ShipSite
  ( C_Deliverable_ID  NUMBER
  , C_Role_Code       VARCHAR2
  , C_ID1             NUMBER ) IS
    SELECT pr.jtot_object1_code Object_Code
    ,      pr.object1_id1 ID1
    ,      pr.facility
    FROM   okc_k_party_roles_b pr
    ,      oke_k_deliverables_b kd
    ,    ( select cle_id , cle_id_ascendant , level_sequence
           from okc_ancestrys
           union all
           select id , id , 99999 from okc_k_lines_b ) a
    WHERE  kd.deliverable_id = C_Deliverable_ID
    AND    pr.rle_code = C_Role_Code
    AND    pr.object1_id1 = C_ID1
    AND    pr.dnz_chr_id = kd.k_header_id
    AND    a.cle_id = kd.k_line_id
    AND  ( ( pr.cle_id IS NULL AND a.cle_id = a.cle_id_ascendant )
         OR pr.cle_id = a.cle_id_ascendant )
    ORDER BY DECODE(pr.cle_id , null , 0 , a.level_sequence) DESC;

  ShipFromRec     ShipSite%RowType;
  ShipToRec       ShipSite%RowType;


  CURSOR ShipCode
  ( C_Deliverable_ID  NUMBER
  , C_Role_Code       VARCHAR2
  , C_ID1             NUMBER ) IS
    SELECT pr.code
    FROM   okc_k_party_roles_b pr
    ,      oke_k_deliverables_b kd
    ,    ( select cle_id , cle_id_ascendant , level_sequence
           from okc_ancestrys
           union all
           select id , id , 99999 from okc_k_lines_b ) a
    WHERE  kd.deliverable_id = C_Deliverable_ID
    AND    pr.rle_code = C_Role_Code
    AND    pr.object1_id1 = C_ID1
    AND    pr.dnz_chr_id = kd.k_header_id
    AND    a.cle_id = kd.k_line_id
    AND    pr.code is not null
    AND  ( ( pr.cle_id IS NULL AND a.cle_id = a.cle_id_ascendant )
         OR pr.cle_id = a.cle_id_ascendant )
    ORDER BY DECODE(pr.cle_id , null , 0 , a.level_sequence) DESC;

  ShipFromCode    ShipCode%RowType;
  ShipToCode      ShipCode%RowType;

  CURSOR TermValue
  ( C_Deliverable_ID  NUMBER
  , C_Term_Code       VARCHAR2 ) IS
    SELECT kt.term_value_pk1 Code
    ,      OKE_UTILS.Get_Term_Values
           ( kt.term_code , kt.term_value_pk1
           , kt.term_value_pk2 , 'MEANING' ) Name
    FROM   oke_k_terms kt
    ,      oke_k_deliverables_b kd
    ,    ( select cle_id , cle_id_ascendant , level_sequence
           from okc_ancestrys
           union all
           select id , id , 99999 from okc_k_lines_b ) a
    WHERE  kd.deliverable_id = C_Deliverable_ID
    AND    kt.term_code = C_Term_Code
    AND    kt.k_header_id = kd.k_header_id
    AND    a.cle_id = kd.k_line_id
    AND  ( ( kt.k_line_id IS NULL AND a.cle_id = a.cle_id_ascendant )
         OR kt.k_line_id = a.cle_id_ascendant )
    ORDER BY DECODE(kt.k_line_id , null , 0 , a.level_sequence) DESC;

  AccptMethodRec  TermValue%RowType;
  AccptPointRec   TermValue%RowType;
  InspPointRec    TermValue%RowType;
  ShipMethodRec   TermValue%RowType;
  DiscTermsRec    TermValue%RowType;

  CURSOR ShipFrom
  ( C_K_Header_ID    NUMBER
  , C_Ship_From_Org  NUMBER ) IS
  SELECT Code
  FROM   okc_k_party_roles_b
  WHERE  rle_code = 'SHIP_FROM'
  AND    jtot_object1_code = 'OKX_INVENTORY'
  AND    object1_id1 = C_Ship_From_Org
  AND    dnz_chr_id = C_K_Header_ID;

  --ShipFromCode    VARCHAR2(30);

  CURSOR ShipTo
  ( C_Ship_To_Loc  NUMBER ) IS
  SELECT ID1
  FROM   oke_cust_site_uses_v
  WHERE  location_id = C_Ship_To_Loc
  AND    site_use_code = 'SHIP_TO';

  ShipToLoc       ShipTo%RowType;

  hdr_rec         Hdr_Rec_Type;
  line_tbl        Line_Tbl_Type;
  FormHdrID       NUMBER;
  i               NUMBER;

BEGIN

  fnd_file.put_line(fnd_file.log , '... Begin DD250 generation');

  X_Return_Status := FND_API.G_RET_STS_SUCCESS;

  --
  -- First of all, fetch delivery level information
  --
  OPEN BillLading;
  FETCH BillLading INTO BillLadingRec;
  CLOSE BillLading;

  fnd_file.put_line(fnd_file.log , '... Fetching Bill of Lading information');

--  FOR FrmHdrRec IN FrmHdr LOOP

  OPEN FrmHdr;
  FETCH FrmHdr INTO FrmHdrRec;

  IF FrmHdr%NOTFOUND THEN
    fnd_file.put_line(fnd_file.log , 'No data found for DD250.');
    CLOSE FrmHdr;

  ELSE

    CLOSE FrmHdr;

    -- Lock the record, to preventing duplicate Shipment Number
    update oke_k_print_forms
    set last_update_date = sysdate
    WHERE  k_header_id = FrmHdrRec.K_Header_ID
    AND    print_form_code = 'DD250';

    --
    -- Check for previously created DD250 for the same delivery
    --
    fnd_file.put_line(fnd_file.log , '... Check for previously created DD250');

    hdr_rec.Shipment_Number := NULL;
    OPEN ShipmentNum( FrmHdrRec.K_Header_ID
                    , P_Delivery_ID
                    , FrmHdrRec.Inv_Org_ID );
    FETCH ShipmentNum INTO hdr_rec.Shipment_Number;
    CLOSE ShipmentNum;

    --
    -- If existing copy not found, assign new Shipment Number
    --
    IF ( hdr_rec.Shipment_Number IS NULL ) THEN
      hdr_rec.Shipment_Number := Shipment_Number
                                 ( FrmHdrRec.K_Header_ID
                                 , FrmHdrRec.Inv_Org_ID
                                 , P_Delivery_ID
                                 , FrmHdrRec.Ship_From_Loc );
    ELSE
      fnd_file.put_line(fnd_file.log , '... Shipment Number ' ||
                               hdr_rec.Shipment_Number || ' located');
    END IF;

    --
    -- Fetch Contract Parties Information
    --

    --
    -- First, fetch customer information
    --
    OPEN PartySite( FrmHdrRec.Deliverable_ID , 'ADMIN_BY' );
    FETCH PartySite INTO AdminByRec;
    CLOSE PartySite;

    IF (AdminByRec.Code IS NULL AND AdminByRec.ID1 IS NOT NULL) THEN
      OPEN CageCode( FrmHdrRec.Deliverable_ID , AdminByRec.ID1, 'ADMIN_BY');
      FETCH CageCode INTO AdminByCode;
      CLOSE CageCode;
      AdminByRec.Code := AdminByCode.Code;
    END IF;

    fnd_file.put_line(fnd_file.log , '... Fetching Admin By information');
    fnd_file.put_line(fnd_file.log , '==> ' || AdminByRec.Object_Code || ' / ' ||
                         AdminByRec.Code || ' / ' ||
                         AdminByRec.ID1);

    IF ( AdminByRec.Object_Code = 'OKE_CUST_KADMIN' ) THEN
      OPEN CustSiteAddr( AdminByRec.ID1 );
      FETCH CustSiteAddr INTO AdminByAddrRec;
      CLOSE CustSiteAddr;
      fnd_file.put_line(fnd_file.log , '==> ' || rtrim(substr(AdminByAddrRec.Address , 1 , 80)));
    END IF;

    --
    -- Fetch Contractor Information
    --
    OPEN PartySite( FrmHdrRec.Deliverable_ID , 'CONTRACTOR' );
    FETCH PartySite INTO ContractorRec;
    CLOSE PartySite;

    IF (ContractorRec.Code IS NULL AND ContractorRec.ID1 IS NOT NULL) THEN
      OPEN CageCode( FrmHdrRec.Deliverable_ID , ContractorRec.ID1, 'CONTRACTOR');
      FETCH CageCode INTO ContractorCode;
      CLOSE CageCode;
      ContractorRec.Code := ContractorCode.Code;
    END IF;

    fnd_file.put_line(fnd_file.log , '... Fetching contractor information');
    fnd_file.put_line(fnd_file.log , '==> ' || ContractorRec.Object_Code || ' / ' ||
                         ContractorRec.Code || ' / ' ||
                         ContractorRec.ID1);

    IF ( ContractorRec.Object_Code = 'OKX_OPERUNIT' OR ContractorRec.Object_Code = 'OKX_INVENTORY' ) THEN
      OPEN OrgAddr( ContractorRec.ID1 );
      FETCH OrgAddr INTO ContractorAddrRec;
      CLOSE OrgAddr;
      fnd_file.put_line(fnd_file.log , '==> ' || rtrim(substr(ContractorAddrRec.Address , 1 , 80)));
    END IF;

    --
    -- Ship From Organization
    --
    OPEN ShipSite( FrmHdrRec.Deliverable_ID , 'SHIP_FROM', FrmHdrRec.Inv_Org_ID );
    FETCH ShipSite INTO ShipFromRec;
    CLOSE ShipSite;

    OPEN ShipCode( FrmHdrRec.Deliverable_ID , 'SHIP_FROM', FrmHdrRec.Inv_Org_ID );
    FETCH ShipCode INTO ShipFromCode;
    CLOSE ShipCode;

    fnd_file.put_line(fnd_file.log , '... Fetching ship from information');
    fnd_file.put_line(fnd_file.log , '==> ' || ShipFromRec.Object_Code || ' / ' ||
                         ShipFromCode.Code || ' / ' ||
                         ShipFromRec.ID1 || ' / ' || FrmHdrRec.Inv_Org_ID );

    OPEN OrgAddr( FrmHdrRec.Inv_Org_ID );
    FETCH OrgAddr INTO ShipFrmAddrRec;
    CLOSE OrgAddr;
    fnd_file.put_line(fnd_file.log , '==> ' || rtrim(substr(ShipFrmAddrRec.Address , 1 , 80)));

    --
    -- Ship To Location
    --
    OPEN ShipTo ( FrmHdrRec.Ship_To_Loc );
    FETCH ShipTo INTO ShipToLoc;
    CLOSE ShipTo;

    OPEN ShipSite( FrmHdrRec.Deliverable_ID , 'SHIP_TO', ShipToLoc.ID1 );
    FETCH ShipSite INTO ShipToRec;
    CLOSE ShipSite;

    OPEN ShipCode( FrmHdrRec.Deliverable_ID , 'SHIP_TO', ShipToLoc.ID1 );
    FETCH ShipCode INTO ShipToCode;
    CLOSE ShipCode;

    fnd_file.put_line(fnd_file.log , '... Fetching ship to information');
    fnd_file.put_line(fnd_file.log , '==> ' || ShipToRec.Object_Code || ' / ' ||
                         ShipToCode.Code || ' / ' ||
                         ShipToRec.ID1);

    --
    -- We use the Ship To in the shipping request to derive the address
    -- We match the Ship To to Ship To role to get the DoDAAD code
    --
    IF ( ShipToLoc.ID1 IS NOT NULL ) THEN
      OPEN CustSiteAddr( ShipToLoc.ID1 );
      FETCH CustSiteAddr INTO ShipToAddrRec;
      CLOSE CustSiteAddr;
      fnd_file.put_line(fnd_file.log , '==> ' || rtrim(substr(ShipToAddrRec.Address , 1 , 80)));
    END IF;

    --
    -- Mark For Location
    --
    OPEN PartySite( FrmHdrRec.Deliverable_ID , 'MARK_FOR' );
    FETCH PartySite INTO MarkForRec;
    CLOSE PartySite;

    IF (MarkForRec.Code IS NULL AND MarkForRec.ID1 IS NOT NULL) THEN
      OPEN CageCode( FrmHdrRec.Deliverable_ID , MarkForRec.ID1, 'MARK_FOR');
      FETCH CageCode INTO MarkForCode;
      CLOSE CageCode;
      MarkForRec.Code := MarkForCode.Code;
    END IF;

    fnd_file.put_line(fnd_file.log , '... Fetching mark for information');
    fnd_file.put_line(fnd_file.log , '==> ' || MarkForRec.Object_Code || ' / ' ||
                         MarkForRec.Code || ' / ' ||
                         MarkForRec.ID1);

    IF ( MarkForRec.Object_Code = 'OKE_MARKFOR' ) THEN
      OPEN CustSiteAddr( MarkForRec.ID1 );
      FETCH CustSiteAddr INTO MarkForAddrRec;
      CLOSE CustSiteAddr;
      fnd_file.put_line(fnd_file.log , '==> ' || rtrim(substr(MarkForAddrRec.Address , 1 , 80)));
    END IF;

    --
    -- Bill To Location
    --
    OPEN PartySite( FrmHdrRec.Deliverable_ID , 'BILL_TO' );
    FETCH PartySite INTO BillToRec;
    CLOSE PartySite;

    IF (BillToRec.Code IS NULL AND BillToRec.ID1 IS NOT NULL) THEN
      OPEN CageCode( FrmHdrRec.Deliverable_ID , BillToRec.ID1, 'BILL_TO');
      FETCH CageCode INTO BillToCode;
      CLOSE CageCode;
      BillToRec.Code := BillToCode.Code;
    END IF;

    fnd_file.put_line(fnd_file.log , '... Fetching bill to information');
    fnd_file.put_line(fnd_file.log , '==> ' || BillToRec.Object_Code || ' / ' ||
                         BillToRec.Code || ' / ' ||
                         BillToRec.ID1);

    IF ( BillToRec.Object_Code = 'OKE_BILLTO' ) THEN
      OPEN CustSiteAddr( BillToRec.ID1 );
      FETCH CustSiteAddr INTO BillToAddrRec;
      CLOSE CustSiteAddr;
      fnd_file.put_line(fnd_file.log , '==> ' || rtrim(substr(BillToAddrRec.Address , 1 , 80)));
    END IF;

    --
    -- Fetching other Terms and Conditions
    --
    fnd_file.put_line(fnd_file.log , '... Fetching various terms');

    OPEN TermValue( FrmHdrRec.Deliverable_ID , 'ACCEPTANCE_METHOD' );
    FETCH TermValue INTO AccptMethodRec;
    CLOSE TermValue;

    fnd_file.put_line(fnd_file.log , 'Acceptance Method = ' || AccptMethodRec.Code);

    OPEN TermValue( FrmHdrRec.Deliverable_ID , 'ACCEPTANCE_POINT' );
    FETCH TermValue INTO AccptPointRec;
    CLOSE TermValue;

    fnd_file.put_line(fnd_file.log , 'Acceptance Point = ' || AccptPointRec.Code);

    OPEN TermValue( FrmHdrRec.Deliverable_ID , 'INSPECTION_POINT' );
    FETCH TermValue INTO InspPointRec;
    CLOSE TermValue;

    fnd_file.put_line(fnd_file.log , 'Inspection Point = ' || InspPointRec.Code);

    OPEN TermValue( FrmHdrRec.Deliverable_ID , 'OB_SHIP_METHOD' );
    FETCH TermValue INTO ShipMethodRec;
    CLOSE TermValue;

    fnd_file.put_line(fnd_file.log , 'Ship Method = ' || ShipMethodRec.Code);

    OPEN TermValue( FrmHdrRec.Deliverable_ID , 'RA_PAYMENT_TERMS' );
    FETCH TermValue INTO DiscTermsRec;
    CLOSE TermValue;

    fnd_file.put_line(fnd_file.log , 'Payment Terms = ' || DiscTermsRec.Name);

    --
    -- Preparing Form Header Record
    --
    hdr_rec.Contract_Header_ID    := FrmHdrRec.K_Header_ID;
    hdr_rec.Reference1            := P_Delivery_ID;
    hdr_rec.Reference2            := FrmHdrRec.Inv_Org_ID;
    hdr_rec.Reference3            := NULL /* FrmHdrRec.Deliverable_ID */;
    hdr_rec.Reference4            := NULL;
    hdr_rec.Reference5            := NULL;
    hdr_rec.Shipment_Date         := sysdate;
    hdr_rec.Bill_Of_Lading        := BillLadingRec.BOL_Number;
    hdr_rec.Ship_Method           := ShipMethodRec.Code;
    hdr_rec.Discount_Terms        := DiscTermsRec.Name;
    hdr_rec.Acceptance_Method     := AccptMethodRec.Code;
    hdr_rec.Acceptance_Point      := AccptPointRec.Code;
    hdr_rec.Inspection_Point      := InspPointRec.Code;
    hdr_rec.Customer              := AdminByAddrRec.Address;
    hdr_rec.Customer_Code         := AdminByRec.Code;
    hdr_rec.Contractor            := ContractorAddrRec.Address;
    hdr_rec.Contractor_Code       := ContractorRec.Code;
    hdr_rec.Ship_From             := ShipFrmAddrRec.Address;
    hdr_rec.Ship_From_Code        := ShipFromCode.Code;
    hdr_rec.FOB                   := FrmHdrRec.FOB_Code;
    hdr_rec.Paid_By               := BillToAddrRec.Address;
    hdr_rec.Paid_By_Code          := BillToRec.Code;
    hdr_rec.Ship_To               := ShipToAddrRec.Address;
    --
    -- Only use Code from Party information if it matches shipping information
    --
    -- IF ( ShipToRec.ID1 = ShipToLoc.ID1 AND
    --     ShipToRec.Object_Code = 'OKE_SHIPTO' ) THEN
    hdr_rec.Ship_To_Code        := ShipToCode.Code;
    -- END IF;
    hdr_rec.Mark_For              := MarkForAddrRec.Address;
    hdr_rec.Mark_For_Code         := MarkForRec.Code;
    hdr_rec.Gross_Weight          := FrmHdrRec.Gross_Weight;
    hdr_rec.Net_Weight            := FrmHdrRec.Net_Weight;
    hdr_rec.Weight_UOM_Code       := FrmHdrRec.Weight_UOM_Code;
    hdr_rec.Volume                := FrmHdrRec.Volume;
    hdr_rec.Volume_UOM_Code       := FrmHdrRec.Volume_UOM_Code;

    i := 0;

    fnd_file.put_line(fnd_file.log , fnd_global.newline || '... Processing Line Information');

    FOR FrmLineRec IN FrmLine ( P_Delivery_ID
                              , FrmHdrRec.Inv_Org_ID
                              , FrmHdrRec.K_Header_ID
                              , FrmHdrRec.Ship_To_Loc ) LOOP

      i := i + 1;

      OPEN LineInfo( FrmLineRec.Deliverable_ID );
      FETCH LineInfo INTO LineInfoRec;
      CLOSE LineInfo;

      fnd_file.put_line(fnd_file.log , 'CLIN  = ' || LineInfoRec.Line_Number);
      fnd_file.put_line(fnd_file.log , 'Desc  = ' || FrmLineRec.Item_Description);
      fnd_file.put_line(fnd_file.log , 'UOM   = ' || LineInfoRec.UOM_Code);
      fnd_file.put_line(fnd_file.log , 'Qty   = ' || FrmLineRec.Shipped_Qty);
      fnd_file.put_line(fnd_file.log , 'Price = ' || LineInfoRec.Unit_Price);

      line_tbl(i).Line_Number      := LineInfoRec.Line_Number;
      line_tbl(i).Item_Number      := LineInfoRec.Item_Number;
      line_tbl(i).Natl_Stock_Number := LineInfoRec.Natl_Stock_Number;
      line_tbl(i).Item_Description := LineInfoRec.Item_Description;
      line_tbl(i).Line_Description := LineInfoRec.Line_Description;
      line_tbl(i).Line_Comments    := LineInfoRec.Line_Comments;
      line_tbl(i).UOM              := LineInfoRec.UOM_Code;
      line_tbl(i).Shipped_Quantity := FrmLineRec.Shipped_Qty;
      line_tbl(i).Unit_Price       := LineInfoRec.Unit_Price;
      line_tbl(i).Amount           := LineInfoRec.Unit_Price *
                                           FrmLineRec.Shipped_Qty;
      line_tbl(i).Reference1 := FrmLineRec.Deliverable_ID;
      line_tbl(i).Reference2 := NULL;
      line_tbl(i).Reference3 := NULL;
      line_tbl(i).Reference4 := NULL;
      line_tbl(i).Reference5 := NULL;

    END LOOP;

    fnd_file.put_line(fnd_file.log , '... Inserting into OKE_K_FORM_HEADERS');

    Create_DD250
    (  P_Commit            => FND_API.G_FALSE
    ,  P_Hdr_Rec           => hdr_rec
    ,  P_Line_Tbl          => line_tbl
    ,  X_Msg_Count         => X_Msg_Count
    ,  X_Msg_Data          => X_Msg_Data
    ,  X_Return_Status     => X_Return_Status
    );

--  END LOOP;

    fnd_file.put_line(fnd_file.log , 'DD250 created.');

  END IF;

END Create_DD250_From_Delivery;


--
--  Name          : Create_DD250_Conc
--  Pre-reqs      : run as concurrent request
--  Function      : This procedure creates a copy of DD250 for a delivery
--
--
--  Parameters    :
--  IN            : P_DELIVERY_ID     NUMBER
--  OUT           : ERRBUF            VARCHAR2
--                  RETCODE           NUMBER
--
--  Returns       : None
--

PROCEDURE Create_DD250_Conc
( ErrBuf                 OUT NOCOPY    VARCHAR2
, RetCode                OUT NOCOPY    NUMBER
, P_Delivery_ID          IN     NUMBER
, P_Unused01             IN     VARCHAR2
, P_Unused02             IN     VARCHAR2
, P_Unused03             IN     VARCHAR2
, P_Unused04             IN     VARCHAR2
, P_Unused05             IN     VARCHAR2
, P_Unused06             IN     VARCHAR2
, P_Unused07             IN     VARCHAR2
, P_Unused08             IN     VARCHAR2
, P_Unused09             IN     VARCHAR2
, P_Unused10             IN     VARCHAR2
, P_Unused11             IN     VARCHAR2
, P_Unused12             IN     VARCHAR2
, P_Unused13             IN     VARCHAR2
, P_Unused14             IN     VARCHAR2
, P_Unused15             IN     VARCHAR2
, P_Unused16             IN     VARCHAR2
, P_Unused17             IN     VARCHAR2
, P_Unused18             IN     VARCHAR2
, P_Unused19             IN     VARCHAR2
, P_Unused20             IN     VARCHAR2
, P_Unused21             IN     VARCHAR2
, P_Unused22             IN     VARCHAR2
, P_Unused23             IN     VARCHAR2
, P_Unused24             IN     VARCHAR2
, P_Unused25             IN     VARCHAR2
, P_Unused26             IN     VARCHAR2
, P_Unused27             IN     VARCHAR2
, P_Unused28             IN     VARCHAR2
, P_Unused29             IN     VARCHAR2
, P_Unused30             IN     VARCHAR2
, P_Unused31             IN     VARCHAR2
, P_Unused32             IN     VARCHAR2
, P_Unused33             IN     VARCHAR2
, P_Unused34             IN     VARCHAR2
, P_Unused35             IN     VARCHAR2
, P_Unused36             IN     VARCHAR2
, P_Unused37             IN     VARCHAR2
, P_Unused38             IN     VARCHAR2
, P_Unused39             IN     VARCHAR2
, P_Unused40             IN     VARCHAR2
, P_Unused41             IN     VARCHAR2
, P_Unused42             IN     VARCHAR2
, P_Unused43             IN     VARCHAR2
, P_Unused44             IN     VARCHAR2
, P_Unused45             IN     VARCHAR2
, P_Unused46             IN     VARCHAR2
, P_Unused47             IN     VARCHAR2
, P_Unused48             IN     VARCHAR2
, P_Unused49             IN     VARCHAR2
, P_Unused50             IN     VARCHAR2
, P_Unused51             IN     VARCHAR2
, P_Unused52             IN     VARCHAR2
, P_Unused53             IN     VARCHAR2
, P_Unused54             IN     VARCHAR2
, P_Unused55             IN     VARCHAR2
, P_Unused56             IN     VARCHAR2
, P_Unused57             IN     VARCHAR2
, P_Unused58             IN     VARCHAR2
, P_Unused59             IN     VARCHAR2
, P_Unused60             IN     VARCHAR2
, P_Unused61             IN     VARCHAR2
, P_Unused62             IN     VARCHAR2
, P_Unused63             IN     VARCHAR2
, P_Unused64             IN     VARCHAR2
, P_Unused65             IN     VARCHAR2
, P_Unused66             IN     VARCHAR2
, P_Unused67             IN     VARCHAR2
, P_Unused68             IN     VARCHAR2
, P_Unused69             IN     VARCHAR2
, P_Unused70             IN     VARCHAR2
, P_Unused71             IN     VARCHAR2
, P_Unused72             IN     VARCHAR2
, P_Unused73             IN     VARCHAR2
, P_Unused74             IN     VARCHAR2
, P_Unused75             IN     VARCHAR2
, P_Unused76             IN     VARCHAR2
, P_Unused77             IN     VARCHAR2
, P_Unused78             IN     VARCHAR2
, P_Unused79             IN     VARCHAR2
, P_Unused80             IN     VARCHAR2
, P_Unused81             IN     VARCHAR2
, P_Unused82             IN     VARCHAR2
, P_Unused83             IN     VARCHAR2
, P_Unused84             IN     VARCHAR2
, P_Unused85             IN     VARCHAR2
, P_Unused86             IN     VARCHAR2
, P_Unused87             IN     VARCHAR2
, P_Unused88             IN     VARCHAR2
, P_Unused89             IN     VARCHAR2
, P_Unused90             IN     VARCHAR2
, P_Unused91             IN     VARCHAR2
, P_Unused92             IN     VARCHAR2
, P_Unused93             IN     VARCHAR2
, P_Unused94             IN     VARCHAR2
, P_Unused95             IN     VARCHAR2
, P_Unused96             IN     VARCHAR2
, P_Unused97             IN     VARCHAR2
, P_Unused98             IN     VARCHAR2
, P_Unused99             IN     VARCHAR2
) IS

Error_Buf      VARCHAR2(2000);
Msg_Count      NUMBER;
Msg_Data       VARCHAR2(2000);
Return_Status  VARCHAR2(1);
i              INTEGER;

BEGIN

  Create_DD250_From_Delivery( P_Delivery_ID , Msg_Count , Msg_Data , Return_Status);

  IF ( Return_Status = FND_API.G_RET_STS_SUCCESS ) THEN
    RetCode := 0;
  ELSE

    RetCode := 2;

    for i in 1..Msg_Count loop
      Error_Buf := fnd_msg_pub.get( p_msg_index => i
                               , p_encoded => fnd_api.g_false );
      fnd_message.set_name('OKE' , 'OKE_API_ERROR_MULTI');
      fnd_message.set_token( 'CURR' , i);
      fnd_message.set_token( 'TOTAL' , Msg_Count);
      fnd_message.set_token( 'TEXT', Error_Buf );
      fnd_file.put_line( fnd_file.log , fnd_message.get );
    end loop;

  END IF;

EXCEPTION
WHEN OTHERS THEN
  RetCode := 2;
  Errbuf  := sqlerrm;

END Create_DD250_Conc;

END OKE_FORM_DD250;

/
