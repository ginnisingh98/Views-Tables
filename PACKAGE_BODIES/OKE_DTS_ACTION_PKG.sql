--------------------------------------------------------
--  DDL for Package Body OKE_DTS_ACTION_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OKE_DTS_ACTION_PKG" As
/* $Header: OKEDACTB.pls 120.1.12010000.2 2009/03/16 05:38:54 serukull ship $ */
  g_Counter Number := 0;
  Function Get_Org(P_Direction Varchar2
		, P_Ship_From_Org_Id Number
		, P_Ship_To_Org_Id Number) Return Number Is


  Begin

    If P_Direction = 'IN' Then
      Return P_Ship_To_Org_Id;
    Else
      Return P_Ship_From_Org_Id;
    End if;

  End Get_Org;


  Function Check_Operation_Allowed(P_Sts_Code Varchar2, P_Opn_Code Varchar2) Return Boolean Is


    Cursor Opn_C(P_Sts_Code Varchar2, P_Opn_Code Varchar2) Is
    Select Allowed_YN
    From okc_assents
    Where Sts_Code = P_Sts_Code
    And Opn_Code = P_Opn_Code;

    L_Result Varchar2(1);

  Begin


    Open Opn_C(P_Sts_Code, P_Opn_Code);
    Fetch Opn_C Into L_Result;
    Close Opn_C;



    If L_Result = 'Y' Then
      Return True;
    Else
      Return False;
    End If;

  End Check_Operation_Allowed;

  Function Check_Dependencies(P_Deliverable_Id Number) Return Boolean Is

    Cursor Dependency_C(P_Deliverable_Id Number) Is
    Select 'x'
    From dual
    Where exists( Select 1
		  From oke_dependencies
	          Where Dependent_Id = P_Deliverable_Id);

    L_Result Varchar2(1);

  Begin

    If P_Deliverable_Id Is Not Null Then
      Open Dependency_C(P_Deliverable_Id);
      Fetch Dependency_C Into L_Result;
      Close Dependency_C;

      If L_Result = 'x' Then
	Return False;
      Else
	Return True;
      End If;

    Else

      Return True;

    End If;

  End Check_Dependencies;

  Function Check_Item_Valid(P_Inventory_Org_Id Number
			, P_Item_Id Number) Return Boolean Is

    Cursor Item_C(P_Inventory_Org_Id Number
		, P_Item_Id Number) Is

    Select 'x'
    From oke_system_items_v
    Where Organization_Id = P_Inventory_Org_Id
    And Inventory_Item_Id = P_Item_Id;

    L_Result Varchar2(1);

  Begin

    If P_Inventory_Org_Id Is Not Null And P_Item_Id Is Not Null Then
      Open Item_C(P_Inventory_Org_Id, P_Item_Id);
      fetch Item_C Into L_Result;
      Close Item_C;

      If L_Result = 'x' Then
	Return True;
      Else
	Return False;
      End If;
    Else
      Return True;
    End If;

  End Check_Item_Valid;

  Function Get_Location(P_Buy_Or_Sell Varchar2
			, P_Direction Varchar2
			, P_Id Number) Return Varchar2 Is

    Cursor Location_C1(P_Id Number) Is
    Select Name
    From okx_locations_v
    Where Id1 = P_Id;

    Cursor Location_C2(P_Id Number) Is
    Select Name
    From okx_vendor_sites_v
    Where Id1 = P_Id;

    Cursor Location_C3(P_Id Number) Is
    Select Name
    From oke_cust_site_uses_v
    Where Id1 = P_Id;

    L_Location Varchar2(80);

  Begin

    If P_Direction = 'IN' Then
      Open Location_C1(P_Id);
      Fetch Location_C1 Into L_Location;
      Close Location_C1;

    Else
      If P_Buy_Or_Sell = 'B' Then
	Open Location_C2(P_Id);
	Fetch Location_C2 Into L_Location;
        Close Location_C2;

      Else

	Open Location_C3(P_Id);
	Fetch Location_C3 Into L_Location;
	Close Location_C3;
      End If;
    End If;

    Return L_Location;

  End Get_Location;




  Procedure Initiate_Actions(P_Action Varchar2
			, P_Action_Level Number  -- 1 Header, 2 Line, 3 Deliverable
			, P_Header_Id Number
			, P_Line_Id Number
			, P_Deliverable_Id Number
			, X_Return_Status OUT NOCOPY Varchar2
			, X_Msg_Data OUT NOCOPY Varchar2
			, X_Msg_Count OUT NOCOPY Number) Is


    L_Ship_To_Location_Id Number;
    L_Ship_To_Location Varchar2(80);
    L_WorkDate Date;
    L_Id Number;
    L_Po_Id Number;
    L_Delivery_Id Number;

    L_Msg_Count Number;
    L_Msg_Data Varchar2(2000);
    L_Item Varchar2(240);
    L_Org Varchar2(240);
    L_Contract_Number Varchar2(450);
    L_Inventory_Org_Id Number;
    L_Header_Id Number;
    L_Line_Number Varchar2(450);
    L_Return_Status Varchar2(1) := Oke_Api.G_Ret_Sts_Success;
    Debug_Counter Number := 0;
    Counter Number := 0;

    Cursor MDS_C1(P_Id Number) Is
    Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, I.Description Item_Description
	, D.Item_Id
	, I.Name Item
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
    From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
    Where D.K_Header_Id = P_Id
    And B.Id = D.K_Header_Id
    And H.K_Header_Id = B.Id
    And D.Project_Id = P.Project_Id(+)
    And D.Task_Id = T.Task_Id(+)
    And D.Item_Id = I.Id1
    And D.Inventory_Org_Id = I.Id2
    And D.K_Line_Id = S.Id
    And D.Create_Demand = 'Y'
--bug 8320909 start
   And Not Exists
 	     (SELECT Schedule_quantity
 	     FROM mrp_schedule_dates
 	     WHERE Mps_Transaction_ID =D. Mps_Transaction_Id
 	     AND Schedule_Level = 2
 	     AND Supply_Demand_Type = 1
 	     AND Schedule_quantity=0);
--bug 8320909 end
    Cursor MDS_C2(P_Id Number) Is
    Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, I.Description Item_Description
	, D.Item_Id
	, I.Name Item
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
    From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
    Where D.K_Line_Id = P_Id
    And B.Id = D.K_Header_Id
    And H.K_Header_Id = B.Id
    And D.Project_Id = P.Project_Id(+)
    And D.Task_Id = T.Task_Id(+)
    And D.Item_Id = I.Id1
    And D.Inventory_Org_Id = I.Id2
    And D.K_Line_Id = S.Id
    And D.Create_Demand = 'Y'
--bug 8320909 start
And Not Exists
 	     (SELECT Schedule_quantity
 	     FROM mrp_schedule_dates
 	     WHERE Mps_Transaction_ID =D. Mps_Transaction_Id
 	     AND Schedule_Level = 2
 	     AND Supply_Demand_Type = 1
 	     AND Schedule_quantity=0);
--bug 8320909 end
    Cursor MDS_C3(P_Id Number) Is
    Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, I.Description Item_Description
	, D.Item_Id
	, I.Name Item
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
    From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
    Where D.Deliverable_Id = P_Id
    And B.Id = D.K_Header_Id
    And H.K_Header_Id = B.Id
    And D.Project_Id = P.Project_Id(+)
    And D.Task_Id = T.Task_Id(+)
    And D.Item_Id = I.Id1
    And D.Inventory_Org_Id = I.Id2
    And D.K_Line_Id = S.Id
    And D.Create_Demand = 'Y';

    Cursor PO_C1(P_Id Number) Is
    Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, D.Item_Id
	, Decode(D.Item_Id, Null, Null, I.Name) Item
	, Decode(D.Item_Id, Null, Null, I.Description) Item_Description
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
    From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
    Where D.K_Header_Id = P_Id
    And B.Id = D.K_Header_Id
    And H.K_Header_Id = B.Id
    And D.Project_Id = P.Project_Id(+)
    And D.Task_Id = T.Task_Id(+)
    And D.Item_Id = I.Id1(+)
    And D.Inventory_Org_Id = I.Id2(+)
    And D.K_Line_Id = S.Id
    And D.Ready_To_Procure = 'Y'
    And ( D.Po_Ref_1 Is Null
    Or Exists ( Select 'X' From po_requisitions_interface_all p
		    Where P.Oke_Contract_Deliverable_ID = D.Deliverable_ID
		    And Nvl(P.Process_Flag, 'S') = 'ERROR'
		    And Nvl(P.Batch_ID, 0) = Nvl(D.Po_Ref_1, 0)));

    Cursor PO_C2(P_Id Number) Is
    Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, D.Item_Id
	, Decode(D.Item_Id, Null, Null, I.Name) Item
	, Decode(D.Item_Id, Null, Null, I.Description) Item_Description
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
    From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
    Where D.K_Line_Id = P_Id
    And B.Id = D.K_Header_Id
    And H.K_Header_Id = B.Id
    And D.Project_Id = P.Project_Id(+)
    And D.Task_Id = T.Task_Id(+)
    And D.Item_Id = I.Id1(+)
    And D.Inventory_Org_Id = I.Id2(+)
    And D.K_Line_Id = S.Id
    And D.Ready_To_Procure = 'Y'
    And ( D.Po_Ref_1 Is Null
    Or Exists ( Select 'X' From po_requisitions_interface_all p
		    Where P.Oke_Contract_Deliverable_ID = D.Deliverable_ID
		    And Nvl(P.Process_Flag, 'S') = 'ERROR'
		    And Nvl(P.Batch_ID, 0) = Nvl(D.Po_Ref_1, 0)));

    Cursor PO_C3(P_Id Number) Is
    Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, D.Item_Id
	, Decode(D.Item_Id, Null, Null, I.Name) Item
	, Decode(D.Item_Id, Null, Null, I.Description) Item_Description
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
    From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
    Where D.Deliverable_Id = P_Id
    And B.Id = D.K_Header_Id
    And H.K_Header_Id = B.Id
    And D.Project_Id = P.Project_Id(+)
    And D.Task_Id = T.Task_Id(+)
    And D.Item_Id = I.Id1(+)
    And D.Inventory_Org_Id = I.Id2(+)
    And D.K_Line_Id = S.Id
    And D.Ready_To_Procure = 'Y';

    Cursor Wsh_C1(P_Id Number) Is
    Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, D.Item_Id
	, Decode(D.Item_Id, Null, Null, I.Name) Item
	, Decode(D.Item_Id, Null, Null, I.Description) Item_Description
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
    From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
    Where D.K_Header_Id = P_Id
    And B.Id = D.K_Header_Id
    And H.K_Header_Id = B.Id
    And D.Project_Id = P.Project_Id(+)
    And D.Task_Id = T.Task_Id(+)
    And D.Item_Id = I.Id1(+)
    And D.Inventory_Org_Id = I.Id2(+)
    And D.K_Line_Id = S.Id
    And D.Available_For_Ship_Flag = 'Y'
    And D.Shipping_Request_Id Is Null;

    Cursor Wsh_C2(P_Id Number) Is
    Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, D.Item_Id
	, Decode(D.Item_Id, Null, Null, I.Name) Item
	, Decode(D.Item_Id, Null, Null, I.Description) Item_Description
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
    From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
    Where D.K_Line_Id = P_Id
    And B.Id = D.K_Header_Id
    And H.K_Header_Id = B.Id
    And D.Project_Id = P.Project_Id(+)
    And D.Task_Id = T.Task_Id(+)
    And D.Item_Id = I.Id1(+)
    And D.Inventory_Org_Id = I.Id2(+)
    And D.K_Line_Id = S.Id
    And D.Available_For_Ship_Flag = 'Y'
    And D.Shipping_Request_Id Is Null;

    Cursor Wsh_C3(P_Id Number) Is
    Select B.Contract_Number
	, B.Currency_Code
	, B.Buy_Or_Sell
	, H.Country_Of_Origin_Code
	, Deliverable_Id
	, Deliverable_Num
	, D.Inspection_Req_Flag
	, D.Item_Id
	, Decode(D.Item_Id, Null, Null, I.Name) Item
	, Decode(D.Item_Id, Null, Null, I.Description) Item_Description
	, D.Inventory_Org_Id
	, D.Project_Id
	, P.Segment1 Project_Number
	, D.Quantity
	, D.Expected_Shipment_Date
	, D.Ndb_Schedule_Designator
	, D.ship_to_location_id
	, D.Task_Id
	, T.Task_Number
	, S.Sts_Code
	, D.Unit_Number
	, D.Uom_Code
	, D.Dependency_Flag
	, D.K_Line_Id
	, D.Mps_Transaction_Id
	, D.Ship_From_Org_Id
	, D.Ship_To_Org_Id
	, D.Direction
    From oke_k_deliverables_b d
	, pa_projects_all p
	, pa_tasks t
	, oke_system_items_v i
	, oke_k_headers h
	, okc_k_headers_b b
	, okc_k_lines_b s
    Where D.Deliverable_Id = P_Id
    And B.Id = D.K_Header_Id
    And H.K_Header_Id = B.Id
    And D.Project_Id = P.Project_Id(+)
    And D.Task_Id = T.Task_Id(+)
    And D.Item_Id = I.Id1(+)
    And D.Inventory_Org_Id = I.Id2(+)
    And D.K_Line_Id = S.Id
    And D.Available_For_Ship_Flag = 'Y';

    Cursor Org_C(P_Id Number) Is
    Select Name
    From hr_all_organization_units
    Where Organization_Id = P_Id;

    Cursor Line_C(P_Id Number) Is
    Select Line_Number
    From okc_k_lines_b
    Where Id = P_Id;


  Begin



    If P_Action = 'PLAN' Then

      If P_Action_Level = 1 Then

        For Mds_Rec In Mds_C1(P_Header_Id) Loop
	  L_Inventory_Org_Id := Get_Org(Mds_Rec.Direction
					, Mds_Rec.Ship_From_Org_Id
					, Mds_Rec.Ship_To_Org_Id);

	  If Check_Operation_Allowed(Mds_Rec.Sts_Code
					, 'INITIATE_DELV') Then

	    If Check_Item_Valid(L_Inventory_Org_Id
				, Mds_Rec.Item_Id) Then

	      If Check_Dependencies(Mds_Rec.Deliverable_Id) Then

		Open Line_C(Mds_Rec.K_Line_Id);
		Fetch Line_C Into L_Line_Number;
		Close Line_C;

		Open Org_C(L_Inventory_Org_Id);
		Fetch Org_C Into L_Org;
		Close Org_C;

		L_Ship_To_Location := Get_Location(Mds_Rec.Buy_Or_Sell
						, Mds_Rec.Direction
						, Mds_Rec.Ship_To_Location_Id);

		Counter := Counter + 1;

     		OKE_DTS_INTEGRATION_PKG.Launch_Process(
	    	   	P_Action			=> P_Action,
  		     	P_Api_Version			=> 1,
			P_country_of_origin_code 	=> Mds_Rec.country_of_origin_code,
			P_Currency_Code			=> Mds_Rec.currency_code,
			P_Deliverable_Id		=> Mds_Rec.deliverable_id,
			P_Deliverable_Num		=> Mds_Rec.deliverable_num,
			P_Init_Msg_List			=> 'T',
			P_Inspection_Reqed		=> Mds_Rec.inspection_req_flag,
			P_Item_Description		=> Mds_Rec.item_description,
			P_Item_Id			=> Mds_Rec.item_id,
			P_Item_Num			=> Mds_Rec.item,
			P_K_Header_Id			=> P_Header_Id,
	   		P_K_Number			=> Mds_Rec.contract_number,
			P_Line_Number			=> l_line_number,
			P_Mps_Transaction_Id		=> Mds_Rec.mps_transaction_id,
			P_Organization			=> l_org,
			P_Organization_Id		=> l_inventory_org_id,
			P_Project_Id			=> Mds_Rec.project_id,
			P_Project_Num			=> Mds_Rec.project_number,
			P_Quantity			=> Mds_Rec.quantity,
			P_Schedule_Date			=> Mds_Rec.expected_shipment_date,
			P_Schedule_Designator		=> Mds_Rec.ndb_schedule_designator,
			P_Ship_To_Location		=> l_ship_to_location,
			P_Task_Id			=> Mds_Rec.task_id,
			P_Task_Num			=> Mds_Rec.task_number,
			P_Unit_Number			=> Mds_Rec.unit_number,
			P_Uom_Code			=> Mds_Rec.uom_code,
			P_Work_Date			=> l_workdate);

	      End If;  	-- Dependency Check
            End if; 	-- Item Check
          End If; 	-- Operation Check

        Debug_Counter := Debug_Counter + 1;



     	End Loop;	-- Record Loop For Header

      ELSIF P_Action_Level = 2 Then


	For Mds_Rec In Mds_C2(P_Line_Id) Loop

	  L_Inventory_Org_Id := Get_Org(Mds_Rec.Direction
					, Mds_Rec.Ship_From_Org_Id
					, Mds_Rec.Ship_To_Org_Id);

	  If Check_Operation_Allowed(Mds_Rec.Sts_Code
					, 'INITIATE_DELV') Then

	    If Check_Item_Valid(L_Inventory_Org_Id
				, Mds_Rec.Item_Id) Then

	      If Check_Dependencies(Mds_Rec.Deliverable_Id) Then

		Open Line_C(Mds_Rec.K_Line_Id);
		Fetch Line_C Into L_Line_Number;
		Close Line_C;

		Open Org_C(L_Inventory_Org_Id);
		Fetch Org_C Into L_Org;
		Close Org_C;

		L_Ship_To_Location := Get_Location(Mds_Rec.Buy_Or_Sell
						, Mds_Rec.Direction
						, Mds_Rec.Ship_To_Location_Id);
		Counter := Counter + 1;

     		OKE_DTS_INTEGRATION_PKG.Launch_Process(
	    	   	P_Action			=> P_Action,
  		     	P_Api_Version			=> 1,
			P_country_of_origin_code 	=> Mds_Rec.country_of_origin_code,
			P_Currency_Code			=> Mds_Rec.currency_code,
			P_Deliverable_Id		=> Mds_Rec.deliverable_id,
			P_Deliverable_Num		=> Mds_Rec.deliverable_num,
			P_Init_Msg_List			=> 'T',
			P_Inspection_Reqed		=> Mds_Rec.inspection_req_flag,
			P_Item_Description		=> Mds_Rec.item_description,
			P_Item_Id			=> Mds_Rec.item_id,
			P_Item_Num			=> Mds_Rec.item,
			P_K_Header_Id			=> P_Header_Id,
	   		P_K_Number			=> Mds_Rec.contract_number,
			P_Line_Number			=> l_line_number,
			P_Mps_Transaction_Id		=> Mds_Rec.mps_transaction_id,
			P_Organization			=> l_org,
			P_Organization_Id		=> l_inventory_org_id,
			P_Project_Id			=> Mds_Rec.project_id,
			P_Project_Num			=> Mds_Rec.project_number,
			P_Quantity			=> Mds_Rec.quantity,
			P_Schedule_Date			=> Mds_Rec.expected_shipment_date,
			P_Schedule_Designator		=> Mds_Rec.ndb_schedule_designator,
			P_Ship_To_Location		=> l_ship_to_location,
			P_Task_Id			=> Mds_Rec.task_id,
			P_Task_Num			=> Mds_Rec.task_number,
			P_Unit_Number			=> Mds_Rec.unit_number,
			P_Uom_Code			=> Mds_Rec.uom_code,
			P_Work_Date			=> l_workdate);

	      End If;  	-- Dependency Check
            End if; 	-- Item Check
          End If; 	-- Operation Check

  	  Debug_Counter := Debug_Counter + 1;

     	End Loop;	-- Record Loop For MDS Line

      ELSIF P_Action_Level = 3 Then

	For Mds_Rec In Mds_C3(P_Deliverable_Id) Loop
	  L_Inventory_Org_Id := Get_Org(Mds_Rec.Direction
					, Mds_Rec.Ship_From_Org_Id
					, Mds_Rec.Ship_To_Org_Id);

	  If Check_Operation_Allowed(Mds_Rec.Sts_Code
					, 'INITIATE_DELV') Then

	    If Check_Item_Valid(L_Inventory_Org_Id
				, Mds_Rec.Item_Id) Then

	      If Check_Dependencies(Mds_Rec.Deliverable_Id) Then

		Open Line_C(Mds_Rec.K_Line_Id);
		Fetch Line_C Into L_Line_Number;
		Close Line_C;

		Open Org_C(L_Inventory_Org_Id);
		Fetch Org_C Into L_Org;
		Close Org_C;

		L_Ship_To_Location := Get_Location(Mds_Rec.Buy_Or_Sell
						, Mds_Rec.Direction
						, Mds_Rec.Ship_To_Location_Id);

		Counter := Counter + 1;
     		OKE_DTS_INTEGRATION_PKG.Launch_Process(
	    	   	P_Action			=> P_Action,
  		     	P_Api_Version			=> 1,
			P_country_of_origin_code 	=> Mds_Rec.country_of_origin_code,
			P_Currency_Code			=> Mds_Rec.currency_code,
			P_Deliverable_Id		=> Mds_Rec.deliverable_id,
			P_Deliverable_Num		=> Mds_Rec.deliverable_num,
			P_Init_Msg_List			=> 'T',
			P_Inspection_Reqed		=> Mds_Rec.inspection_req_flag,
			P_Item_Description		=> Mds_Rec.item_description,
			P_Item_Id			=> Mds_Rec.item_id,
			P_Item_Num			=> Mds_Rec.item,
			P_K_Header_Id			=> P_Header_Id,
	   		P_K_Number			=> Mds_Rec.contract_number,
			P_Line_Number			=> l_line_number,
			P_Mps_Transaction_Id		=> Mds_Rec.mps_transaction_id,
			P_Organization			=> l_org,
			P_Organization_Id		=> l_inventory_org_id,
			P_Project_Id			=> Mds_Rec.project_id,
			P_Project_Num			=> Mds_Rec.project_number,
			P_Quantity			=> Mds_Rec.quantity,
			P_Schedule_Date			=> Mds_Rec.expected_shipment_date,
			P_Schedule_Designator		=> Mds_Rec.ndb_schedule_designator,
			P_Ship_To_Location		=> l_ship_to_location,
			P_Task_Id			=> Mds_Rec.task_id,
			P_Task_Num			=> Mds_Rec.task_number,
			P_Unit_Number			=> Mds_Rec.unit_number,
			P_Uom_Code			=> Mds_Rec.uom_code,
			P_Work_Date			=> l_workdate);

	      End If;  	-- Dependency Check
            End if; 	-- Item Check
          End If; 	-- Operation Check
     	End Loop;	-- Record Loop For MDS Deliverable
      End If;		-- End Level If

    Elsif P_Action = 'SHIP' Then


      If P_Action_Level = 1 Then


        For Wsh_Rec In Wsh_C1(P_Header_Id) Loop
	  L_Inventory_Org_Id := Get_Org(Wsh_Rec.Direction
					, Wsh_Rec.Ship_From_Org_Id
					, Wsh_Rec.Ship_To_Org_Id);

	  If Check_Operation_Allowed(Wsh_Rec.Sts_Code
					, 'INITIATE_DELV') Then

	    If Check_Item_Valid(L_Inventory_Org_Id
				, Wsh_Rec.Item_Id) Then

	      If Check_Dependencies(Wsh_Rec.Deliverable_Id) Then

		Open Line_C(Wsh_Rec.K_Line_Id);
		Fetch Line_C Into L_Line_Number;
		Close Line_C;

		Open Org_C(L_Inventory_Org_Id);
		Fetch Org_C Into L_Org;
		Close Org_C;

		L_Ship_To_Location := Get_Location(Wsh_Rec.Buy_Or_Sell
						, Wsh_Rec.Direction
						, Wsh_Rec.Ship_To_Location_Id);
		Counter := Counter + 1;

     		OKE_DTS_INTEGRATION_PKG.Launch_Process(
	    	   	P_Action			=> P_Action,
  		     	P_Api_Version			=> 1,
			P_country_of_origin_code 	=> Wsh_Rec.country_of_origin_code,
			P_Currency_Code			=> Wsh_Rec.currency_code,
			P_Deliverable_Id		=> Wsh_Rec.deliverable_id,
			P_Deliverable_Num		=> Wsh_Rec.deliverable_num,
			P_Init_Msg_List			=> 'T',
			P_Inspection_Reqed		=> Wsh_Rec.inspection_req_flag,
			P_Item_Description		=> Wsh_Rec.item_description,
			P_Item_Id			=> Wsh_Rec.item_id,
			P_Item_Num			=> Wsh_Rec.item,
			P_K_Header_Id			=> P_Header_Id,
	   		P_K_Number			=> Wsh_Rec.contract_number,
			P_Line_Number			=> l_line_number,
			P_Mps_Transaction_Id		=> Wsh_Rec.mps_transaction_id,
			P_Organization			=> l_org,
			P_Organization_Id		=> l_inventory_org_id,
			P_Project_Id			=> Wsh_Rec.project_id,
			P_Project_Num			=> Wsh_Rec.project_number,
			P_Quantity			=> Wsh_Rec.quantity,
			P_Schedule_Date			=> Wsh_Rec.expected_shipment_date,
			P_Schedule_Designator		=> Wsh_Rec.ndb_schedule_designator,
			P_Ship_To_Location		=> l_ship_to_location,
			P_Task_Id			=> Wsh_Rec.task_id,
			P_Task_Num			=> Wsh_Rec.task_number,
			P_Unit_Number			=> Wsh_Rec.unit_number,
			P_Uom_Code			=> Wsh_Rec.uom_code,
			P_Work_Date			=> l_workdate);

	      End If;  	-- Dependency Check
            End if; 	-- Item Check
          End If; 	-- Operation Check

          Debug_Counter := Debug_Counter + 1;

     	End Loop;	-- Record Loop For Header


      ELSIF P_Action_Level = 2 Then


	For Wsh_Rec In Wsh_C2(P_Line_Id) Loop
	  L_Inventory_Org_Id := Get_Org(Wsh_Rec.Direction
					, Wsh_Rec.Ship_From_Org_Id
					, Wsh_Rec.Ship_To_Org_Id);

	  If Check_Operation_Allowed(Wsh_Rec.Sts_Code
					, 'INITIATE_DELV') Then

	    If Check_Item_Valid(L_Inventory_Org_Id
				, Wsh_Rec.Item_Id) Then

	      If Check_Dependencies(Wsh_Rec.Deliverable_Id) Then

		Open Line_C(Wsh_Rec.K_Line_Id);
		Fetch Line_C Into L_Line_Number;
		Close Line_C;

		Open Org_C(L_Inventory_Org_Id);
		Fetch Org_C Into L_Org;
		Close Org_C;

		L_Ship_To_Location := Get_Location(Wsh_Rec.Buy_Or_Sell
						, Wsh_Rec.Direction
						, Wsh_Rec.Ship_To_Location_Id);
		Counter := Counter + 1;

     		OKE_DTS_INTEGRATION_PKG.Launch_Process(
	    	   	P_Action			=> P_Action,
  		     	P_Api_Version			=> 1,
			P_country_of_origin_code 	=> Wsh_Rec.country_of_origin_code,
			P_Currency_Code			=> Wsh_Rec.currency_code,
			P_Deliverable_Id		=> Wsh_Rec.deliverable_id,
			P_Deliverable_Num		=> Wsh_Rec.deliverable_num,
			P_Init_Msg_List			=> 'T',
			P_Inspection_Reqed		=> Wsh_Rec.inspection_req_flag,
			P_Item_Description		=> Wsh_Rec.item_description,
			P_Item_Id			=> Wsh_Rec.item_id,
			P_Item_Num			=> Wsh_Rec.item,
			P_K_Header_Id			=> P_Header_Id,
	   		P_K_Number			=> Wsh_Rec.contract_number,
			P_Line_Number			=> l_line_number,
			P_Mps_Transaction_Id		=> Wsh_Rec.mps_transaction_id,
			P_Organization			=> l_org,
			P_Organization_Id		=> l_inventory_org_id,
			P_Project_Id			=> Wsh_Rec.project_id,
			P_Project_Num			=> Wsh_Rec.project_number,
			P_Quantity			=> Wsh_Rec.quantity,
			P_Schedule_Date			=> Wsh_Rec.expected_shipment_date,
			P_Schedule_Designator		=> Wsh_Rec.ndb_schedule_designator,
			P_Ship_To_Location		=> l_ship_to_location,
			P_Task_Id			=> Wsh_Rec.task_id,
			P_Task_Num			=> Wsh_Rec.task_number,
			P_Unit_Number			=> Wsh_Rec.unit_number,
			P_Uom_Code			=> Wsh_Rec.uom_code,
			P_Work_Date			=> l_workdate);

	      End If;  	-- Dependency Check
            End if; 	-- Item Check
          End If; 	-- Operation Check

	  Debug_Counter := Debug_Counter + 1;

     	End Loop;	-- Record Loop For MDS Line


      ELSIF P_Action_Level = 3 Then


	For Wsh_Rec In Wsh_C3(P_Deliverable_Id) Loop
	  L_Inventory_Org_Id := Get_Org(Wsh_Rec.Direction
					, Wsh_Rec.Ship_From_Org_Id
					, Wsh_Rec.Ship_To_Org_Id);


	  If Check_Operation_Allowed(Wsh_Rec.Sts_Code
					, 'INITIATE_DELV') Then

	    If Check_Item_Valid(L_Inventory_Org_Id
				, Wsh_Rec.Item_Id) Then


	      If Check_Dependencies(Wsh_Rec.Deliverable_Id) Then


		Open Line_C(Wsh_Rec.K_Line_Id);
		Fetch Line_C Into L_Line_Number;
		Close Line_C;

		Open Org_C(L_Inventory_Org_Id);
		Fetch Org_C Into L_Org;
		Close Org_C;

		L_Ship_To_Location := Get_Location(Wsh_Rec.Buy_Or_Sell
						, Wsh_Rec.Direction
						, Wsh_Rec.Ship_To_Location_Id);
		Counter := Counter + 1;

     		OKE_DTS_INTEGRATION_PKG.Launch_Process(
	    	   	P_Action			=> P_Action,
  		     	P_Api_Version			=> 1,
			P_country_of_origin_code 	=> Wsh_Rec.country_of_origin_code,
			P_Currency_Code			=> Wsh_Rec.currency_code,
			P_Deliverable_Id		=> Wsh_Rec.deliverable_id,
			P_Deliverable_Num		=> Wsh_Rec.deliverable_num,
			P_Init_Msg_List			=> 'T',
			P_Inspection_Reqed		=> Wsh_Rec.inspection_req_flag,
			P_Item_Description		=> Wsh_Rec.item_description,
			P_Item_Id			=> Wsh_Rec.item_id,
			P_Item_Num			=> Wsh_Rec.item,
			P_K_Header_Id			=> P_Header_Id,
	   		P_K_Number			=> Wsh_Rec.contract_number,
			P_Line_Number			=> l_line_number,
			P_Mps_Transaction_Id		=> Wsh_Rec.mps_transaction_id,
			P_Organization			=> l_org,
			P_Organization_Id		=> l_inventory_org_id,
			P_Project_Id			=> Wsh_Rec.project_id,
			P_Project_Num			=> Wsh_Rec.project_number,
			P_Quantity			=> Wsh_Rec.quantity,
			P_Schedule_Date			=> Wsh_Rec.expected_shipment_date,
			P_Schedule_Designator		=> Wsh_Rec.ndb_schedule_designator,
			P_Ship_To_Location		=> l_ship_to_location,
			P_Task_Id			=> Wsh_Rec.task_id,
			P_Task_Num			=> Wsh_Rec.task_number,
			P_Unit_Number			=> Wsh_Rec.unit_number,
			P_Uom_Code			=> Wsh_Rec.uom_code,
			P_Work_Date			=> l_workdate);

	      End If;  	-- Dependency Check
            End if; 	-- Item Check
          End If; 	-- Operation Check
     	End Loop;	-- Record Loop For MDS Deliverable
      End If;		-- End Level If

    Elsif P_Action = 'REQ' Then


      If P_Action_Level = 1 Then

        For Po_Rec In Po_C1(P_Header_Id) Loop
	  L_Inventory_Org_Id := Get_Org(Po_Rec.Direction
					, Po_Rec.Ship_From_Org_Id
					, Po_Rec.Ship_To_Org_Id);

	  If Check_Operation_Allowed(Po_Rec.Sts_Code
					, 'INITIATE_DELV') Then

	    If Check_Item_Valid(L_Inventory_Org_Id
				, Po_Rec.Item_Id) Then

	      If Check_Dependencies(Po_Rec.Deliverable_Id) Then

		Open Line_C(Po_Rec.K_Line_Id);
		Fetch Line_C Into L_Line_Number;
		Close Line_C;

		Open Org_C(L_Inventory_Org_Id);
		Fetch Org_C Into L_Org;
		Close Org_C;

		L_Ship_To_Location := Get_Location(Po_Rec.Buy_Or_Sell
						, Po_Rec.Direction
						, Po_Rec.Ship_To_Location_Id);
		Counter := Counter + 1;

     		OKE_DTS_INTEGRATION_PKG.Launch_Process(
	    	   	P_Action			=> P_Action,
  		     	P_Api_Version			=> 1,
			P_country_of_origin_code 	=> Po_Rec.country_of_origin_code,
			P_Currency_Code			=> Po_Rec.currency_code,
			P_Deliverable_Id		=> Po_Rec.deliverable_id,
			P_Deliverable_Num		=> Po_Rec.deliverable_num,
			P_Init_Msg_List			=> 'T',
			P_Inspection_Reqed		=> Po_Rec.inspection_req_flag,
			P_Item_Description		=> Po_Rec.item_description,
			P_Item_Id			=> Po_Rec.item_id,
			P_Item_Num			=> Po_Rec.item,
			P_K_Header_Id			=> P_Header_Id,
	   		P_K_Number			=> Po_Rec.contract_number,
			P_Line_Number			=> l_line_number,
			P_Mps_Transaction_Id		=> Po_Rec.mps_transaction_id,
			P_Organization			=> l_org,
			P_Organization_Id		=> l_inventory_org_id,
			P_Project_Id			=> Po_Rec.project_id,
			P_Project_Num			=> Po_Rec.project_number,
			P_Quantity			=> Po_Rec.quantity,
			P_Schedule_Date			=> Po_Rec.expected_shipment_date,
			P_Schedule_Designator		=> Po_Rec.ndb_schedule_designator,
			P_Ship_To_Location		=> l_ship_to_location,
			P_Task_Id			=> Po_Rec.task_id,
			P_Task_Num			=> Po_Rec.task_number,
			P_Unit_Number			=> Po_Rec.unit_number,
			P_Uom_Code			=> Po_Rec.uom_code,
			P_Work_Date			=> l_workdate);

	      End If;  	-- Dependency Check
            End if; 	-- Item Check
          End If; 	-- Operation Check

	  Debug_Counter := Debug_Counter + 1;

     	End Loop;	-- Record Loop For Header


      ELSIF P_Action_Level = 2 Then

	For Po_Rec In Po_C2(P_Line_Id) Loop
	  L_Inventory_Org_Id := Get_Org(Po_Rec.Direction
					, Po_Rec.Ship_From_Org_Id
					, Po_Rec.Ship_To_Org_Id);



	  If Check_Operation_Allowed(Po_Rec.Sts_Code
					, 'INITIATE_DELV') Then

	    If Check_Item_Valid(L_Inventory_Org_Id
				, Po_Rec.Item_Id) Then

	      If Check_Dependencies(Po_Rec.Deliverable_Id) Then

		Open Line_C(Po_Rec.K_Line_Id);
		Fetch Line_C Into L_Line_Number;
		Close Line_C;

		Open Org_C(L_Inventory_Org_Id);
		Fetch Org_C Into L_Org;
		Close Org_C;

		L_Ship_To_Location := Get_Location(Po_Rec.Buy_Or_Sell
						, Po_Rec.Direction
						, Po_Rec.Ship_To_Location_Id);
		Counter := Counter + 1;

     		OKE_DTS_INTEGRATION_PKG.Launch_Process(
	    	   	P_Action			=> P_Action,
  		     	P_Api_Version			=> 1,
			P_country_of_origin_code 	=> Po_Rec.country_of_origin_code,
			P_Currency_Code			=> Po_Rec.currency_code,
			P_Deliverable_Id		=> Po_Rec.deliverable_id,
			P_Deliverable_Num		=> Po_Rec.deliverable_num,
			P_Init_Msg_List			=> 'T',
			P_Inspection_Reqed		=> Po_Rec.inspection_req_flag,
			P_Item_Description		=> Po_Rec.item_description,
			P_Item_Id			=> Po_Rec.item_id,
			P_Item_Num			=> Po_Rec.item,
			P_K_Header_Id			=> P_Header_Id,
	   		P_K_Number			=> Po_Rec.contract_number,
			P_Line_Number			=> l_line_number,
			P_Mps_Transaction_Id		=> Po_Rec.mps_transaction_id,
			P_Organization			=> l_org,
			P_Organization_Id		=> l_inventory_org_id,
			P_Project_Id			=> Po_Rec.project_id,
			P_Project_Num			=> Po_Rec.project_number,
			P_Quantity			=> Po_Rec.quantity,
			P_Schedule_Date			=> Po_Rec.expected_shipment_date,
			P_Schedule_Designator		=> Po_Rec.ndb_schedule_designator,
			P_Ship_To_Location		=> l_ship_to_location,
			P_Task_Id			=> Po_Rec.task_id,
			P_Task_Num			=> Po_Rec.task_number,
			P_Unit_Number			=> Po_Rec.unit_number,
			P_Uom_Code			=> Po_Rec.uom_code,
			P_Work_Date			=> l_workdate);

	      End If;  	-- Dependency Check
            End if; 	-- Item Check
          End If; 	-- Operation Check

	  Debug_Counter := Debug_Counter + 1;

     	End Loop;	-- Record Loop For MDS Line


      ELSIF P_Action_Level = 3 Then


	For Po_Rec In Po_C3(P_Deliverable_Id) Loop
	  L_Inventory_Org_Id := Get_Org(Po_Rec.Direction
					, Po_Rec.Ship_From_Org_Id
					, Po_Rec.Ship_To_Org_Id);

	  If Check_Operation_Allowed(Po_Rec.Sts_Code
					, 'INITIATE_DELV') Then

	    If Check_Item_Valid(L_Inventory_Org_Id
				, Po_Rec.Item_Id) Then

	      If Check_Dependencies(Po_Rec.Deliverable_Id) Then

		Open Line_C(Po_Rec.K_Line_Id);
		Fetch Line_C Into L_Line_Number;
		Close Line_C;

		Open Org_C(L_Inventory_Org_Id);
		Fetch Org_C Into L_Org;
		Close Org_C;

		L_Ship_To_Location := Get_Location(Po_Rec.Buy_Or_Sell
						, Po_Rec.Direction
						, Po_Rec.Ship_To_Location_Id);
		Counter := Counter + 1;


     		OKE_DTS_INTEGRATION_PKG.Launch_Process(
	    	   	P_Action			=> P_Action,
  		     	P_Api_Version			=> 1,
			P_country_of_origin_code 	=> Po_Rec.country_of_origin_code,
			P_Currency_Code			=> Po_Rec.currency_code,
			P_Deliverable_Id		=> Po_Rec.deliverable_id,
			P_Deliverable_Num		=> Po_Rec.deliverable_num,
			P_Init_Msg_List			=> 'T',
			P_Inspection_Reqed		=> Po_Rec.inspection_req_flag,
			P_Item_Description		=> Po_Rec.item_description,
			P_Item_Id			=> Po_Rec.item_id,
			P_Item_Num			=> Po_Rec.item,
			P_K_Header_Id			=> P_Header_Id,
	   		P_K_Number			=> Po_Rec.contract_number,
			P_Line_Number			=> l_line_number,
			P_Mps_Transaction_Id		=> Po_Rec.mps_transaction_id,
			P_Organization			=> l_org,
			P_Organization_Id		=> l_inventory_org_id,
			P_Project_Id			=> Po_Rec.project_id,
			P_Project_Num			=> Po_Rec.project_number,
			P_Quantity			=> Po_Rec.quantity,
			P_Schedule_Date			=> Po_Rec.expected_shipment_date,
			P_Schedule_Designator		=> Po_Rec.ndb_schedule_designator,
			P_Ship_To_Location		=> l_ship_to_location,
			P_Task_Id			=> Po_Rec.task_id,
			P_Task_Num			=> Po_Rec.task_number,
			P_Unit_Number			=> Po_Rec.unit_number,
			P_Uom_Code			=> Po_Rec.uom_code,
			P_Work_Date			=> l_workdate);

	      End If;  	-- Dependency Check
            End if; 	-- Item Check
          End If; 	-- Operation Check
     	End Loop;	-- Record Loop For MDS Deliverable
      End If;		-- End Level If

    End If;		-- End Action Type If




  --
  -- No error handling added yet
  --
  X_Return_Status := oke_api.g_ret_sts_success;

    g_Counter := Counter;

  End Initiate_Actions;

  PROCEDURE Initiate_Actions_CP(
        ERRBUF            OUT NOCOPY    VARCHAR2
      , RETCODE           OUT NOCOPY    NUMBER
      , P_Action          VARCHAR2
			, P_Action_Level    NUMBER  -- 1 Header, 2 Line, 3 Deliverable
			, P_HEADER_ID       NUMBER
			, P_LINE_ID         NUMBER
			, P_DELIVERABLE_ID  NUMBER
  ) IS
			l_Return_Status VARCHAR2(1);
			l_Msg_Count NUMBER;
   BEGIN
    g_Counter := 0;
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Initiate_Actions_CP: Started at '||TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS') );
    Initiate_Actions(P_Action => p_action
			, P_Action_Level => P_Action_Level
			, P_Header_Id => P_Header_Id
			, P_Line_Id => P_Line_Id
			, P_Deliverable_Id => P_Deliverable_Id
			, X_Return_Status => l_Return_Status
			, X_Msg_Data => ERRBUF
			, X_Msg_Count => l_Msg_Count
    );
    FND_FILE.PUT_LINE( FND_FILE.LOG, 'Initiate_Actions_CP: Ended at '||TO_CHAR(SYSDATE,'YYYYMMDD HH24:MI:SS')||' with status='||l_Return_Status );
    IF l_Return_Status = oke_api.g_ret_sts_success THEN
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'WF processes started for '||g_Counter||' deliverables.' );
      ERRBUF := NULL;
      RETCODE := 0;
     ELSE
      FND_FILE.PUT_LINE( FND_FILE.LOG, 'Error: '||ERRBUF );
      RETCODE := 2;
    END IF;
  EXCEPTION
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE( FND_FILE.LOG, sqlerrm );
    ERRBUF := sqlerrm;
    RETCODE := 2;
  END Initiate_Actions_CP;

End;





/
