--------------------------------------------------------
--  DDL for Package Body CSD_REFURBISH_IRO_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSD_REFURBISH_IRO_GRP" AS
/* $Header: csdrirob.pls 120.6 2008/03/14 01:06:27 takwong ship $ */

-- ---------------------------------------------------------
-- Define global variables
-- ---------------------------------------------------------

G_PKG_NAME  CONSTANT VARCHAR2(30) := 'CSD_Refurbish_IRO_GRP';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'csdrirob.pls';

/*--------------------------------------------------------------------*/
/* PROCEDURE Name : Get_PartySiteID                                   */
/* 	 x_return_status       	  Standard OUT param                    */
/*    x_msg_data                Standard OUT param                    */
/*    x_msg_count               Standard OUT param                    */
/*    p_site_use_type       	  Site Use Type Like To_Ship or To_Bill */
/*	 p_cust_site_use_id    	  Customer Site USe Id value            */
/* 	 x_party_site_use_id   	  Party Site Use Id OUT value           */
/* Description  : Takes Customer site use Id and site use type        */
/*                variables as input and returns corresponding        */
/*                party site use id , party Id and party site use id  */
/*--------------------------------------------------------------------*/
/*--------------------------------------------------------------------*/
/* Note : this procedure is also used by Vivek's API, since this      */
/*        is commonly used, it will be better if it is moved to       */
/*        csd_process_utils package. Discuss with Vivek               */
/*--------------------------------------------------------------------*/

Procedure Get_PartySiteId
  	(
 	 x_return_status        Out  NOCOPY   Varchar2,
	 x_msg_Data		    Out  NoCopy   Varchar2 ,
      x_msg_Count            Out  NoCopy   Number,
      p_site_use_type        In            Varchar2,
 	 p_cust_site_use_id     In            Number ,
      x_party_id             OUT  NOCOPY   Number,
      x_party_site_id        OUT  NOCOPY   Number,
      x_party_site_use_id    Out  NOCOPY   Number ) IS

     -- Define local variables
     l_party_site_id       	Number;
   	l_party_site_use_id   	Number;
     l_party_id               Number ;

     -- Define Constants for debug level variables
    C_Procedure_Level         Constant Number        := Fnd_Log.Level_Procedure ;
    C_Exception_Level         Constant Number        := Fnd_Log.Level_Exception ;
    C_Statement_Level         Constant Number        := Fnd_Log.Level_Statement ;
    C_Debug_Level             Constant Number        := Fnd_Log.G_Current_Runtime_Level ;
    C_Module                  Constant Varchar2(240) := 'csd.plsql.CSD_Refurbish_IRO_GRP.Get_PartySiteID' ;

    C_API_Name                Constant Varchar2(30)  := 'Get_PartySiteID';
    C_Site_Status_Active      Constant Varchar2(1)   := 'A' ;
 Begin
    If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
       Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || 'Begin','Begining of procedure : Get_PartySiteID ');
    End If;

    --- Check if required input parameters are NULL
    If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
       Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.In_Parameter_Validation',
          'Checking if required input parameter cust_Site_Use_id is Null');
    End If;
    -- Check the required parameter(p_Cust_Site_Use_Id)
    CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value    => p_Cust_Site_Use_Id,
         p_param_name     => 'Cust_Site_Use_Id',
         p_api_name       => C_API_Name);

    If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
       Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.In_Parameter_Validation',
          'Checking if required input parameter Site_Use_Type is Null');
    End If;

    -- Check the required parameter(p_Site_Use_Type)
    CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value    => p_Site_Use_Type,
         p_param_name     => 'Site_Use_Type',
         p_api_name       => C_API_Name);

    Begin
       Select hcas.party_site_id
       Into   x_party_site_id
       From   hz_cust_acct_sites_all hcas,
              hz_cust_site_uses_all hcsu
       Where  hcas.cust_acct_site_id = hcsu.cust_acct_site_id
       And   hcsu.site_use_id       = p_cust_site_use_id ;
    Exception
       When No_Data_found then
          Fnd_Message.Set_Name('CSD', 'CSD_PARTY_SITE_NOT_FOUND');
          Fnd_Message.Set_Token('CUST_ACCT_SITE_ID', p_cust_site_use_id);
          Fnd_Msg_Pub.Add;
          If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
             Fnd_Log.String(Fnd_Log.Level_Statement,C_Module , ' Party site id not found for customer acct site use id ' || p_cust_site_use_id  );
          End If;
          Raise  FND_API.G_EXC_ERROR ;
    End;
    If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
       Fnd_Log.String(Fnd_Log.Level_Statement,C_Module , ' Party site id found for customer acct site use id ' || p_cust_site_use_id  );
    End If;
    If x_party_site_id is not null Then
       Begin
          Select hpsu.party_site_use_id,
		     hps.party_id
	      Into x_party_site_use_id,
		     x_party_id
		  From  Hz_Party_Sites hps,
             Hz_Party_Site_uses hpsu,
             Hz_Locations hl
          Where hps.party_site_id = x_party_site_id
          And  hpsu.site_use_type = p_site_use_type
          And  hps.status = C_Site_Status_Active
          And  hps.location_id = hl.location_id
          And  hps.party_site_id = hpsu.party_site_id;
          If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
             Fnd_Log.String(Fnd_Log.Level_Statement,C_Module , ' Party id is found for party site id ' || x_party_site_id );
          End If;
       Exception
          When No_Data_found then
             Fnd_Message.Set_Name('CSD','CSD_PARTY_SITE_USE_NOT_FOUND');
             Fnd_Message.Set_Token('PARTY_SITE_ID',l_Party_Site_Id);
             Fnd_Msg_Pub.Add;
             If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
                Fnd_Log.String(Fnd_Log.Level_Statement,C_Module , ' Party id is not found for party site id ' || x_party_site_id );
             End If;
             Raise  FND_API.G_EXC_ERROR ;
          When Too_Many_Rows Then
             Fnd_Message.Set_Name('CSD','CSD_TOO_MANY_PARTY_LOCATIONS');
             Fnd_Message.Set_Token('PARTY_SITE_ID',l_Party_Site_Id);
             Fnd_Message.Set_Token('SITE_USE_TYPE',p_Site_Use_Type);
             Fnd_Msg_Pub.Add;
             If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
                Fnd_Log.String(Fnd_Log.Level_Statement,C_Module , ' Too many Party site use id are found for party site id ' || x_party_site_id );
             End If;
             Raise  Fnd_Api.G_Exc_Error ;
       End;
    End If;
    If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
       Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || 'End','End of procedure : Get_PartySiteID was successful ');
    End If;
 Exception
    When Fnd_Api.G_Exc_Error Then
       x_return_status := Fnd_Api.G_Ret_Sts_Error ;

       --- Standard call to get message count and if  count is  greater then 1, get message info
       FND_MSG_PUB.Count_And_Get
          (p_count  =>  x_msg_count,
           p_data   =>  x_msg_data );
    When Others Then
       x_return_status := Fnd_Api.G_Ret_Sts_Unexp_Error ;
       If Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level  Then
          Fnd_Log.String(Fnd_Log.Level_Exception,C_Module , x_msg_data );
       End If;
       IF FND_MSG_PUB.Check_Msg_Level
		(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
 	  THEN
          FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,c_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
          p_data   => x_msg_data );
       If Fnd_Log.Level_Exception >= Fnd_Log.G_Current_Runtime_Level  Then
          Fnd_Log.String(Fnd_Log.Level_Exception,C_Module , x_msg_data );
       End If;
  End Get_PartySiteId;

/*-----------------------------------------------------------------------------------------*/
/*-- Create_InternalRO Procedure takes 4 input parameters p_Internal_SO_Header_Id_In,      */
/*-- p_Req_Header_Id_In,p_Internal_SO_Header_Id_Out, p_Req_Header_Id_Out and creates one   */
/*-- serive request and returns service request in x_Service_Request_Number out parameter. */
/*                                                                                         */
/*-- If procedure is not processed successfully then it returns error code and             */
/*-- message. In case procedure returns errors all database transactions are rolled        */
/*-- back. If item on internal sales order In is non serialized then one repair order      */
/*-- is created under above service request. If item is serialized then number of          */
/*-- repair orders will be as many as ordered quantity on internal sales order in.         */
/*-- THis procedure creates two product trxn lines for each repair order, one product      */
/*-- trxn line for internal SO Move In and another for internal SO Move out.               */
/*-- p_Internal_SO_Header_Id_In, p_Req_Header_Id_In,p_Internal_SO_Header_Id_Out,           */
/*-- p_Req_Header_Id_Out are required parameters.                                          */
/*-- Internal RO are always created under new SR.                                          */
/*-- If messgage count is greater then 1 then API does not return error message calling    */
/*-- program should handle getting all the error message from message stack.               */
/*-----------------------------------------------------------------------------------------*/
/*  Procedure Name : Create_InternalRO                                                     */
/*  P_api_version			     Standard In  param                                      */
/*  P_init_msg_list			     Standard In  param                                      */
/*  P_commit			          Standard In  param                                      */
/*  P_validation_level		     Standard In  param                                      */
/*  x_return_status	               Standard Out param                                      */
/*  x_msg_count	               Standard Out param                                      */
/*  x_msg_data	                    Standard Out param                                      */
/*  P_req_header_id_in		     Requisition Header Id for IO1 (Required)                */
/*  P_internal_SO_header_id_in	Internal SO header Id for IO1 (Required)                */
/*  P_req_header_id_out		     Requisition Header Id for IO2 (Required)                */
/*  P_internal_SO_header_id_out    Internal SO header Id for IO2 (Required)                */
/*  x_service_request_number	     Service Request Number OUT variable                     */
/*-----------------------------------------------------------------------------------------*/


 Procedure Create_InternalRO(
    P_api_version                In          Number,
    P_init_msg_list              In          Varchar2,
    P_commit                     In          Varchar2,
    P_validation_level           In          Number,
    x_return_status              Out NOCOPY  Varchar2,
    x_msg_count	             Out NOCOPY	Number,
    x_msg_data	                  Out NOCOPY	Varchar2,
    P_req_header_id_in           In          Number,
    P_ISO_header_id_in           In          Number,
    P_req_header_id_out		   In          Number,
    P_ISO_header_id_out          In          Number,
    x_service_request_number     Out NOCOPY	Varchar2,
    P_need_by_date               In         DATE)   --Enhancement:3391950
    IS
    -- Declare local record variables for SR, Notes, contacts and repair line records
    l_service_request_rec          CS_SERVICEREQUEST_PUB.service_request_rec_type;
    l_notes_table                  CS_ServiceRequest_PUB.notes_table;
    l_contacts_table               CS_ServiceRequest_PUB.contacts_table;
    l_rep_line_rec                 CSD_REPAIRS_PUB.Repln_Rec_Type;

    l_inc_type_id                  Varchar2(255) ; -- Changed from number to Varchar2
    l_inc_status_id                Varchar2(255) ; -- Changed from number to Varchar2
    l_inc_severity_id              Varchar2(255) ; -- Changed from number to Varchar2
    l_inc_urgency_id               Varchar2(255) ; -- Changed from number to Varchar2
    l_sr_owner_id                  Varchar2(255) ; -- Changed from number to Varchar2
    l_repair_type_id               Varchar2(255) ; -- Changed from number to Varchar2

    l_inc_work_summary             Varchar2(255) ;
    l_Product_Trxn_Id              Number ;
    ln_interaction_id              Number;
    ln_workflow_id                 Number;
    l_sr_count                     Number;
    l_count                        Number;
    l_ro_count                     Number;
    l_error_count                  Number;
    l_incident_id                  Number;
    l_incident_number              cs_incidents_all_b.Incident_Number%TYpe;
    l_approval_flag                Varchar2(1);
    l_repair_mode                  csd_repairs.repair_mode%Type;

    l_repair_number                csd_repairs.repair_number%Type;
    l_repair_line_id               csd_repairs.repair_line_id%Type;
    l_msg_count                    Number;
    l_msg_data                     Varchar2(2000);
    l_return_status                Varchar2(30);
    l_serialized_flag              Varchar2(1);
    l_customer_id                  NUMBER;
    l_caller_type                  Varchar2(80);

    l_ship_to_party_site_use_id    Number;
    l_ship_to_party_id             Number;
    l_ship_to_party_site_id        Number;

    l_bill_to_party_site_use_id    Number;
    l_bill_to_party_id             Number;
    l_bill_to_party_site_id        Number;

    l_rep_hist_id                  Number;
    l_instance_id                  Number;
    l_individual_owner             Number;
    l_group_owner                  Number ;
    l_individual_type              VARCHAR2(30) ;
    l_IS_Move_In_Item_Serialized   Varchar2(1) ;
    l_IS_Move_Out_Item_Serialized  Varchar2(1);
    l_Item_In                      Varchar2(255);
    l_Item_Out                     Varchar2(255) ;
    l_Repair_Type_Name             Varchar2(30) ;
    -- Bug# 4000602 saupadhy local variable to hold value for default repair order organization
    l_Default_RO_Org_ID            Number;

    --Define constants used in this procedure
    c_api_name                     Constant Varchar2(30)   := 'Create_InternalRO';
    c_api_version                  Constant Number         := 1.0;

    C_SR_SubType_INC               Constant Varchar2(30)   := 'INC';
    C_Yes                          Constant Varchar2(1)    := 'Y';
    C_NO                           Constant Varchar2(1)    := 'N';
    C_Status_Open                  Constant Varchar2(30)   := 'OPEN';
    C_Status_Open_Code             Constant Varchar2(30)   := 'O';
    C_Site_Use_Type_Bill_To        Constant Varchar2(30)   :=  'BILL_TO';
    C_Site_Use_Type_Ship_To        Constant Varchar2(30)   :=  'SHIP_TO';
    C_RO_Txn_Status_Booked         Constant Varchar2(30)   := 'OM_BOOKED';

    -- Constant to hold SR status column name
    C_Col_SR_Status                Constant Varchar2(30) := 'SR Status' ;
    -- Constant to hold SR Type Column name
    C_Col_SR_Type                  Constant Varchar2(30) := 'SR Type' ;
    -- Constant to hold SR Severity
    C_COl_SR_Severity              Constant Varchar2(30) := 'SR Severity' ;
    -- Constant to hold Repair Type
    C_Col_Repair_Type              Constant Varchar2(30) := 'Repair Type' ;

    -- Define local constants to map fnd log message priority
    C_Procedure_Level              Constant Number        := FND_LOG.LEVEL_PROCEDURE ;
    C_Statement_Level              Constant Number        := Fnd_Log.Level_Statement ;
    C_Exception_Level              Constant Number        := Fnd_Log.Level_Exception ;
    C_Error_Level                  Constant Number        := Fnd_Log.Level_Error;
    C_Debug_Level                  Constant Number        := FND_LOG.G_CURRENT_RUNTIME_LEVEL ;
    C_Module                       Constant Varchar2(240) := 'csd.plsql.CSD_Refurbish_IRO_GRP.Create_InternalRO' ;
    -- Define local constants to for action type and action code
    C_Action_Type_Move_In          Constant Varchar2(30) := 'MOVE_IN' ;
    C_Action_Type_Move_Out         Constant Varchar2(30) := 'MOVE_OUT' ;

    C_Action_Code_Usables          Constant Varchar2(30) := 'USABLES' ;
    C_Action_Code_Defectives       Constant Varchar2(30) := 'DEFECTIVES' ;
    C_PROD_TXN_STATUS_BOOKED       Constant Varchar2(30) := 'BOOKED' ;


    -- Cancelled_Flag column in oe_order_headers_all table can have values 'Y', 'N' or Null ,
    -- always consider 'N' or Null
    -- Open_flag column in oe_order_headers_all table can have values 'Y', 'N' , always consider 'Y'
    -- Booked_flag column in oe_order_headers_all table can have values 'Y', 'N', always consider 'Y'
    -- Cancelled_Flag column in oe_order_lines_all table can have values 'Y', 'N' or Null ,
    -- always consider 'N' or Null
    -- Open_flag column in oe_order_lines_all table can have values 'Y', 'N' , always consider 'Y'
    -- Booked_flag column in oe_order_lines_all table can have values 'Y', 'N', always consider 'Y'
    -- Party information, bill-to-address and ship-to-address are picked from ISO2 Bug # 3389067
    Cursor Get_SRandRO_from_IRandISO_IN (p_ISO_Header_Id_IN Number, p_Req_Header_Id_IN Number ) IS
       Select  oeh.order_number order_number,
          oeh.header_id  order_header_id,
          oeh.order_category_code,
          oeh.booked_flag,
          oeh.cust_po_number purchase_order_num,
          NVL(oel.price_list_id,oeh.price_list_id) price_list_id,
          oel.line_id ,
          oel.inventory_item_id,
          oel.line_type_id,
          oel.order_quantity_uom,
          prh.segment1 requisition_number ,
          prh.requisition_header_Id req_Header_Id,
          prl.line_num,
          prl.requisition_Line_Id req_Line_Id,
          prl.quantity requisition_quantity ,
          prl.destination_organization_id ,
          prl.destination_subinventory ,
          prl.source_organization_id ,
          prl.source_subinventory ,
          prl.quantity,
          oeh.transactional_curr_code currency_code,
          prl.item_revision,
          msi.serial_number_control_code,
          msi.concatenated_segments
       From   Oe_Order_Headers_All oeh,
          Oe_Order_Lines_all oel,
          po_requisition_headers_all prh,
          po_requisition_lines_all prl,
          mtl_system_items_kfv msi
       Where  oeh.header_id = p_ISO_Header_Id_IN
       And NVL(oeh.cancelled_flag,'N') = 'N'
       And oeh.open_flag = 'Y'
       And oeh.booked_flag = 'Y'
       And oel.header_id = oeh.header_id
       And oel.split_from_line_id is Null
       And NVL(oel.cancelled_flag,'N') = 'N'
       And oel.open_flag = 'Y'
       And oel.booked_flag = 'Y'
       And oel.inventory_item_id = msi.inventory_item_id
	  /*FP Fixed for bug#5368747
	    To get item attribute the join should be made with ship_from_org_id
	    from where the item will actually be shipped.
	  */
       /*And oel.sold_from_org_id  = msi.organization_id */
	    And oel.ship_from_org_id = msi.organization_id
       And prh.requisition_header_id = p_req_header_id_In
       And prh.requisition_header_id = prl.requisition_header_id
       And NVL(prl.cancel_flag,'N') = 'N'
       And prh.requisition_header_id = oeh.source_document_id
       And prl.requisition_line_id = oel.source_document_line_id
       And Not Exists
          ( Select 'Found Record'
            From csd_product_transactions
            Where req_header_id = p_req_header_id_In
		  AND   req_line_id > 0 )
       And Not Exists
          ( Select 'Found Record'
            From csd_product_transactions
            Where order_header_id = p_ISO_header_id_In
		  AND   order_line_id > 0 ) ;

    -- Party information, bill-to-address and shipp-to-address are picked from IO2 so
    -- they are added to IO2 Bug # 3389067
     Cursor Get_PrdTxn_from_IRandISO_OUT (p_ISO_Header_Id_Out Number, p_Req_Header_Id_Out Number ) IS
        Select  oeh.order_number order_number,
           oeh.header_id  order_header_id,
           oeh.order_category_code,
           oeh.booked_flag,
           NVL(oeh.invoice_to_org_id,oel.invoice_to_org_id) bill_to_site_use_id,
           NVL(oeh.ship_to_org_id,oel.ship_to_org_id) ship_to_site_use_id,
           oeh.sold_to_org_id cust_account_id,
           oel.line_id ,
           oel.line_number line_number,
           oel.inventory_item_id,
           oel.line_type_id,
           oel.order_quantity_uom,
           oel.ordered_quantity ,
           hp.party_type,
           hp.party_id,
           prh.segment1 requisition_number ,
           prl.line_num,
           prl.destination_organization_id ,
           prl.destination_subinventory ,
           prl.source_organization_id ,
           prl.source_subinventory ,
           prl.quantity,
           prl.Requisition_Header_Id Req_Header_ID,
           prl.Requisition_Line_ID Req_Line_Id,
           msi.serial_number_control_code,
           msi.concatenated_segments
        From   Oe_Order_Headers_All oeh,
           Oe_Order_Lines_all oel,
           hz_parties hp,
           hz_cust_accounts hca,
           po_requisition_headers_all prh,
           po_requisition_lines_all prl,
           mtl_system_items_kfv msi
        Where  oeh.header_id = p_ISO_Header_Id_Out
        And NVL(oeh.cancelled_flag,'N') = 'N'
        And oeh.open_flag = 'Y'
        And oeh.booked_flag = 'Y'
        And oel.header_id = oeh.header_id
        And Nvl(oel.cancelled_flag,'N') = 'N'
        And oel.open_flag = 'Y'
        And oel.booked_flag = 'Y'
        And oel.split_from_line_id is Null
        And oel.inventory_item_id = msi.inventory_item_id
       /*FP Fixed for bug#5368747
          To get item attribute the join should be made with ship_from_org_id
          from where the item will actually be shipped.
       */
        /*And oel.sold_from_org_id  = msi.organization_id*/
	     And oel.ship_from_org_id    = msi.organization_id
        And oeh.sold_to_org_id = hca.cust_account_id
        And hca.party_id       = hp.party_id
        And prh.requisition_header_id = p_req_header_id_Out
        And prh.requisition_header_id = prl.requisition_header_id
        And Nvl(prl.cancel_flag,'N') = 'N'
        And prh.requisition_header_id = oeh.source_document_id
        And prl.requisition_line_id = oel.source_document_line_id
       And Not Exists
          ( Select 'Found Record'
            From csd_product_transactions
            Where req_header_id = p_req_header_id_Out
		  AND   req_line_id > 0 )
       And Not Exists
          ( Select 'Found Record'
            From csd_product_transactions
            Where order_header_id = p_ISO_header_id_Out
		  AND   order_line_id > 0 ) ;

     -- Fix for bug#5839636
     -- Cursor to derive the (Repair) Inventory Org Id
     --
     Cursor get_req_org_id (p_requisition_header_id in number,
                            p_requisition_line_id in number) is
     Select destination_organization_id
     from po_requisition_lines_all
     where requisition_header_id = p_requisition_header_id
     and requisition_line_id = p_requisition_line_id;

     --- Define Record Types of Type Cursor Definitions
     l_IRandISO_In_Rec          Get_SRandRO_from_IRandISO_IN%ROWTYPE;
     l_IRandISO_Out_Rec         Get_PrdTxn_from_IRandISO_OUT%ROWTYPE;
     l_IRandISO_In_Rec2         Get_SRandRO_from_IRandISO_IN%ROWTYPE;
     l_IRandISO_Out_Rec2        Get_PrdTxn_from_IRandISO_OUT%ROWTYPE;
  Begin
     If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
        Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || 'Begin','Begining of procedure : Create_InternalRO ');
     End If;
     -- Standard Start of API savepoint
     Savepoint  Create_InternalRO;

     -- Standard call to check for call compatibility.
     If Not FND_API.Compatible_API_Call (c_api_version,
         p_api_version, c_api_name , G_PKG_NAME    )
     Then
        IF Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module||'.API_Version_Validation','API Version incompatibility');
        End If;
        Raise Fnd_Api.G_Exc_Unexpected_Error;
     End If;

     -- Initialize message list if p_init_msg_list is set to TRUE.
     If Fnd_Api.to_Boolean( p_init_msg_list ) Then
        Fnd_Msg_Pub.initialize;
     End If;

     -- Initialize API return status to success
     x_return_status := Fnd_Api.G_Ret_Sts_Success;

     --- Check if required input parameters are NULL
     If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
        FND_LOG.STRING(Fnd_Log.Level_Statement,C_Module || '.In_Parameter_Validation',
           'Checking if required input parameters are Null');
     End If;

     --- Check if required input parameters are NULL
     If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
        Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.In_Parameter_Validation',
           'Checking if required input parameter Req_Header_id_in is Null');
     End If;
     -- Check the required parameter(p_Req_Header_Id_In)
     CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value    => p_Req_Header_Id_In,
         p_param_name     => 'Req_Header_Id_In',
         p_api_name        => C_API_Name);

     If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
        Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.In_Parameter_Validation',
           'Checking if required input parameter Req_Header_id_Out is Null');
     End If;
     -- Check the required parameter(p_Req_Header_Id_Out)
     CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value    => p_Req_Header_Id_Out,
         p_param_name     => 'Req_Header_Id_Out',
         p_api_name        => C_API_Name);

     If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
        Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.In_Parameter_Validation',
           'Checking if required input parameter ISO_Header_Id_In is Null');
     End If;
     -- Check the required parameter(p_ISO_Header_Id_In)
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value    => p_ISO_Header_Id_In,
         p_param_name     => 'ISO_Header_Id_In',
         p_api_name        => C_API_Name);
     If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
        Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.In_Parameter_Validation',
           'Checking if required input parameter ISO_Header_Id_Out is Null');
     End If;
     -- Check the required parameter(p_ISO_Header_Id_Out)
       CSD_PROCESS_UTIL.Check_Reqd_Param
       ( p_param_value    => p_ISO_Header_Id_Out,
         p_param_name     => 'ISO_Header_Id_Out',
         p_api_name        => C_API_Name);

     --- IO1/IR1 and IO2/IR2 can not be same, validate.
     If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
        Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.Val_IR1_and_IR2_are_same',
           'Checking if parameters Req_Header_Id_In and Req_Header_Id_Out has same value');
     End If;
     -- Check if IR1 and IR2 are same
     If p_Req_Header_Id_In = P_Req_header_id_Out Then
        Fnd_Message.Set_Name('CSD','CSD_IR1_AND_IR2_SAME');
        Fnd_Message.Set_Token('Req_Header_Id',p_Req_Header_Id_In);
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.Val_IR1_and_IR2_are_same',
           'Input parameters Req_Header_Id_In and Req_Header_Id_Out has same value');
        End If;
        --- Message will say: Input parameter 'Requisition Header ID's  p_req_header_Id_In are same for in and out requistion records';
        x_return_status := FND_API.G_RET_STS_ERROR ;
        Raise FND_API.G_EXC_ERROR ;
     End IF;
     If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
        Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.Val_IO1_and_IO2_are_same',
           'Checking if parameters ISO_Header_Id_In and ISO_Header_Id_Out has same value');
     End If;
     -- Check if IO1 and IO2 are same.
     If P_ISO_header_id_in = P_ISO_header_id_Out Then
        Fnd_Message.Set_Name('CSD','CSD_IO1_AND_IO2_SAME');
        Fnd_Message.Set_Token('Order_Header_Id',p_ISO_Header_Id_In);
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.Val_IO1_and_IO2_are_same',
           'Input parameters ISO_Header_Id_In and ISO_Header_Id_Out has same value');
        End If;
        --- Message will say: Input parameter 'Internal Sales Order Header ID's  p_Order_header_Id_In are same for in and out internal SO records';
        x_return_status := FND_API.G_RET_STS_ERROR ;
        Raise FND_API.G_EXC_ERROR ;
     End If ;
     If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
        Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.SR_Record_Default_values',
           'Getting default values for SR record from profile options');
     End If;
	-- get SR Type Id value from profile, this is a required field if not set raise error message.
     FND_PROFILE.Get('CSD_IRO_DEFAULT_SR_TYPE',l_Inc_Type_Id);
     If ( l_inc_type_id Is NULL )  Then
        Fnd_Message.Set_Name('CSD','CSD_SR_REC_TYPE_REQ_COL_NULL');
        Fnd_Message.Set_Token('COLUMN_NAME',c_COl_SR_Type );
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.SR_Type_Validation','SR Type is Null') ;
        End If;
        --- Message will say:  'SR Type, required column for SR record Type is null';
        x_return_status := FND_API.G_RET_STS_ERROR ;
        Raise FND_API.G_EXC_ERROR ;
	Else
        If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.SR_Type_Validation','SR TYpe id is :' || l_Inc_Type_Id ) ;
        End If;
     End If;

     FND_PROFILE.Get('CSD_IRO_DEFAULT_SR_SEVERITY',l_Inc_Severity_Id);
	-- Check if SR Severity Id is NULL, If so raise error
     If (l_inc_severity_id Is NULL) Then
        Fnd_Message.Set_Name('CSD','CSD_SR_REC_TYPE_REQ_COL_NULL');
        Fnd_Message.Set_Token('COLUMN_NAME',C_Col_SR_Severity );
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.SR_Severity_Validation','SR Severity is null'  ) ;
        End If;
        --- Message will say:  'SR Severity, required column for SR record Type is null';
        x_return_status := FND_API.G_RET_STS_ERROR ;
        Raise FND_API.G_EXC_ERROR ;
	Else
        If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.SR_Serverity_Validation',
		 'SR Severity id is :' || l_Inc_Severity_Id ) ;
        End If;
     End If;

	-- DO not have to verify if value is null, as it is not a required column
     FND_PROFILE.Get('CSD_OM_DEFAULT_SR_URGENCY',l_Inc_Urgency_Id);
     --l_inc_work_summary :=  'Internal Refurbish repair orders from internal sales orders for product : ' ;
	-- Getting value from INC_DEFAULT_INCIDENT_OWNER since this profile is used to get value in UI
	-- also CSD_OM_DEFAULT_SR_OWNER is incorrectly defined.
	-- This is to fix bug 3395281 saupadhy
     --l_sr_owner_id := FND_PROFILE.value('CSD_OM_DEFAULT_SR_OWNER');
     FND_PROFILE.Get('INC_DEFAULT_INCIDENT_OWNER',l_Sr_Owner_Id);
     If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
        Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.SR_Owner_Id_value',
           'Default value for SR Owner Id is :' ||l_sr_owner_id );
     End If;
	--Bug# 4000602 saupadhy DBI changes 11/05/2004
	FND_PROFILE.GET('CSD_DEFAULT_REPAIR_ORG',l_Default_RO_Org_ID);

     FND_PROFILE.Get('CSD_IRO_REPAIR_TYPE',l_Repair_Type_Id);
     --- Check if Default values for RO exist
     If (l_Repair_Type_id Is Null) Then
        Fnd_Message.Set_Name('CSD','CSD_RO_REC_TYPE_REQ_COL_NULL');
        Fnd_Message.Set_Token('COLUMN_NAME',C_Col_Repair_Type );
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.Repair_Type_Validation','Repair Type is Null' ) ;
        End If;
        -- Message will say:  'Repair Type, required column for SR record Type is null';
        x_return_status := FND_API.G_RET_STS_ERROR ;
        Raise FND_API.G_EXC_ERROR ;
	Else
        If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.Repair_Type_Validation','Repair TYpe is :' ||
		    l_Repair_Type_Id ) ;
        End If;
     End If;
     Begin
        Select incident_status_id  Into l_inc_status_Id
        From cs_incident_statuses_vl
        Where incident_subtype = C_SR_SubType_INC
        And seeded_flag = C_YES
        And trunc(sysdate) between trunc(nvl(start_date_active,sysdate)) and trunc(nvl(end_date_active,sysdate))
        And status_code = C_Status_Open ;
        If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.SR_Status_Id_value',
           'Seeded SR status was found and its value is :' ||l_inc_status_Id );
        End If;
     Exception
        When No_Data_Found Then
           --l_inc_status_id    := FND_PROFILE.value('CSD_OM_DEFAULT_SR_STATUS');
           FND_PROFILE.Get('CSD_OM_DEFAULT_SR_STATUS',l_Inc_Status_Id);
           If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
              Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.SR_Status_Id_value',
              'Seeded SR status was not found, so getting value from profile option  and its value is :' ||l_inc_status_Id );
           End If;
     End;
     --- Check if any of the defaulted values for required columns of SR Record type has null value.
     If (l_inc_status_Id   Is NULL )  Then
        Fnd_Message.Set_Name('CSD','CSD_SR_REC_TYPE_REQ_COL_NULL');
        Fnd_Message.Set_Token('COLUMN_NAME',C_Col_SR_Status );
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.SR_Status_Validation','SR Status is NULL' ) ;
        End If;
        --- Message will say:  'SR Status, required column for SR record Type is null';
        x_return_status := FND_API.G_RET_STS_ERROR ;
        Raise FND_API.G_EXC_ERROR ;
	Else
        If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.SR_Status_Validation','SR Status was found' ) ;
        End If;
     End If;
     --- If Return status is error then raise exception and stop processing.
     If x_return_status = FND_API.G_RET_STS_ERROR Then
       If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
              Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.Repair_Status_Validation',
              'Return Status is :' || x_return_status );
       End If;
       Raise FND_API.G_EXC_ERROR ;
     End If;
     Begin
        Select repair_mode,Name
        into  l_repair_mode,l_Repair_Type_Name
        from  csd_repair_types_vl
        where repair_type_id = l_Repair_Type_Id ;
	   -- Check if Repair Mode is Null If Repair Mode is null then raise exception
	   If l_Repair_Mode Is Null Then
           Fnd_Message.Set_Name('CSD','CSD_REPAIR_MODE_IS_NULL');
           Fnd_Message.Set_Token('REPAIR_TYPE',l_Repair_Type_Name );
           Fnd_Msg_Pub.Add;
           If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
              Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.Repair_Type_Validation','Repair Mode is Null for repair type :' || l_Repair_Type_Name);
           End If;
		 X_Return_Status := Fnd_API.G_Ret_Sts_Error ;
           Raise FND_API.G_EXC_ERROR ;
	   End If;
	Exception
	   When No_Data_FOund Then
           Fnd_Message.Set_Name('CSD','CSD_INVALID_REPAIR_TYPE');
           Fnd_Msg_Pub.Add;
           If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
              Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.Repair_Type_Validation','Repair Type Id is invalid');
           End If;
		 X_Return_Status := Fnd_API.G_Ret_Sts_Error ;
           Raise FND_API.G_EXC_ERROR ;
     End ;
     If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
        Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.Repair_Mode_Value',
        'Return Mode is :' || l_repair_mode );
     End If;
     --- Open main cursor
     Open Get_SRandRO_from_IRandISO_In(p_ISO_Header_Id_in , p_Req_Header_Id_IN ) ;
     Fetch Get_SRandRO_from_IRandISO_In Into l_IRandISO_In_Rec ;
     If Get_SRandRO_from_IRandISO_In%ROWCOUNT = 0 Then
        --- Raise Exception and stop processing
        Fnd_Message.Set_Name('CSD','CSD_IR_IO_REC_NOT_FOUND');
        Fnd_Message.Set_Token('REQ_HDR_ID', p_Req_Header_Id_IN);
        Fnd_Message.Set_Token('SO_HDR_ID', P_ISO_header_id_in);
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.Records_Validation','no records are found for move in') ;
        End If;
        Close Get_SRandRO_from_IRandISO_In ;
        Raise FND_API.G_EXC_ERROR ;
     Elsif Get_SRandRO_from_IRandISO_In%ROWCOUNT > 1  Then
        --- Check if more then one records(IO1/IR1) are found in the cursor result set
        --- if so stop processing and raise error
        --- Raise Exception and stop processing
        Fnd_Message.Set_Name('CSD','CSD_IR_IO_MANY_REC_FOUND');
        Fnd_Message.Set_Token('REQ_HDR_ID', p_Req_Header_Id_IN);
        Fnd_Message.Set_Token('SO_HDR_ID', P_ISO_header_id_in);
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.Records_Validation','too many move in records are found' ) ;
        End If;
        Raise FND_API.G_EXC_ERROR ;
     End If;
     -- Get SR Work Summary information from message dictionary
     Fnd_Message.Set_Name('CSD','CSD_SR_WORK_SUMMARY');
     Fnd_Message.Set_Token('PRODUCT', l_IRandISO_In_Rec.Concatenated_Segments || ' ');
	l_Inc_Work_Summary := Fnd_Message.Get;
     -- Check if Move_In item is serial controlled or not
     If l_IRandISO_In_Rec.Serial_Number_Control_code = 1 Then
        l_IS_Move_In_Item_Serialized := 'N';
     Else
        l_IS_Move_In_Item_Serialized := 'Y' ;
     End If;
     -- Close main Cursor as the values are fetched into a record and there is no need to fetch again
     Close Get_SRandRO_from_IRandISO_In ;

     --- Open Second cursor to fetch IO2/IR2 records
     Open Get_PrdTxn_from_IRandISO_Out(p_ISO_Header_Id_Out , p_Req_Header_Id_Out ) ;
     Fetch Get_PrdTxn_from_IRandISO_Out Into l_IRandISO_Out_Rec ;
     If Get_PrdTxn_from_IRandISO_Out %ROWCOUNT = 0 Then
        --- Raise Exception and stop processing
        Fnd_Message.Set_Name('CSD','CSD_IR_IO_REC_NOT_FOUND');
        Fnd_Message.Set_Token('REQ_HDR_ID',p_Req_Header_Id_Out);
        Fnd_Message.Set_Token('SO_HDR_ID',p_ISO_Header_Id_Out);
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure, C_Module || '.Records_Validation','No move out records are found' ) ;
        End If;
        Close Get_PrdTxn_from_IRandISO_Out ;
        Raise FND_API.G_EXC_ERROR ;
     Elsif Get_PrdTxn_from_IRandISO_Out%ROWCOUNT > 1  Then
        --- Check if more then one records(IO2/IR2) are found in the cursor result set
        --- if so stop processing and raise error
        --- Raise Exception and stop processing
        Fnd_Message.Set_Name('CSD','CSD_IR_IO_MANY_REC_FOUND');
        Fnd_Message.Set_Token('REQ_HDR_ID', p_Req_Header_Id_Out);
        Fnd_Message.Set_Token('SO_HDR_ID', p_ISO_Header_Id_Out);
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.Records_Validation','Too many move out records are found' ) ;
        End If;
        Raise FND_API.G_EXC_ERROR ;
     End If;
     -- Check if Move_Out item is serial controlled or not
     If l_IRandISO_Out_Rec.Serial_Number_Control_code = 1 Then
        l_IS_Move_Out_Item_Serialized := 'N';
     Else
        l_IS_Move_Out_Item_Serialized := 'Y' ;
     End If;
     -- Close Second Cursor as the values are fetched into a record and there is no need to fetch again
     Close Get_PrdTxn_from_IRandISO_Out ;
     -- Check if Move_in and Move_Out Items serial number control code attributes are similar or not.
     If l_IS_Move_In_Item_Serialized <> l_IS_Move_Out_Item_Serialized Then
        --- Raise Exception and stop processing
	   l_Item_In  := l_IRandISO_In_Rec.Concatenated_Segments ;
	   l_Item_Out := l_IRandISO_Out_Rec.Concatenated_Segments ;
        Fnd_Message.Set_Name('CSD','CSD_SR_NUM_ATTR_DIFFER');
        Fnd_Message.Set_Token('ITEM_IN', l_Item_in);
        Fnd_Message.Set_Token('ITEM_OUT', l_Item_Out);
        Fnd_Msg_Pub.Add;
        If Fnd_Log.Level_Procedure >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Procedure,C_Module || '.Serial_Control_Validation','Serial number attributes are different for items on IO1 and IO2 lines' ) ;
        End If;
        Raise FND_API.G_EXC_ERROR ;
     End If;
     --Get the bill to site use Id
	-- Changed from In To Out since SR should be created for IO2 not for IO1
     Get_PartySiteId (
        p_site_use_type       =>  C_Site_Use_Type_Bill_To ,
        p_cust_site_use_id    =>  l_IRandISO_Out_Rec.bill_to_site_use_id,
        x_party_site_use_id   =>  l_bill_to_party_site_use_id ,
        x_party_id            =>  l_bill_to_party_id ,
	   x_party_site_id       =>  l_bill_to_party_site_id ,
	   x_return_status       =>  l_return_status ,
        x_msg_count           =>  l_msg_count,
        x_msg_data            =>  l_msg_data);

     If Not(l_return_status = FND_API.G_RET_STS_SUCCESS) Then
        If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Error,C_Module || '.Records_Validation',
           'Error while calling procedure : Get_PartySIteId for site use type Bill To');
        End If;
        -- Raise Exception and stop processing
        Raise FND_API.G_EXC_ERROR;
     Else
	   Null;
     End If;

     ---Get the ship to site use Id
	-- Changed from In To Out since SR should be created for IO2 not for IO1
     Get_PartySiteId (
        x_return_status       =>  l_return_status,
        x_msg_count           =>  l_msg_count,
        x_msg_data            =>  l_msg_data,
        p_site_use_type       =>  C_Site_Use_Type_Ship_To ,
        p_cust_site_use_id    =>  l_IRandISO_Out_Rec.ship_to_site_use_id,
        x_party_site_use_id   =>  l_ship_to_party_site_use_id,
        x_party_id            =>  l_ship_to_party_id ,
	   x_party_site_id       =>  l_ship_to_party_site_id  );

     If Not(x_return_status = FND_API.G_RET_STS_SUCCESS) Then
         If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Error,C_Module || '.Records_Validation',
           'Error while calling procedure : Get_PartySIteId for site use type Ship To');
         End If;
          -- Raise Exception and stop processing
         Raise FND_API.G_EXC_ERROR;
      Else
         If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
           Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.Records_Validation',
           'Error while calling procedure : Get_PartySIteId for site use type Ship To');
         End If;
      End If;
      -- Initialize the SR record values
      CS_SERVICEREQUEST_PUB.initialize_rec(l_service_request_rec);

      l_service_request_rec.request_date            := sysdate;
      l_service_request_rec.type_id                 := l_inc_type_id;
      l_service_request_rec.status_id               := l_inc_status_id;
      l_service_request_rec.severity_id             := l_inc_severity_id;
      l_service_request_rec.urgency_id              := l_inc_urgency_id;
      l_service_request_rec.owner_id                := l_sr_owner_id ;
      l_service_request_rec.summary                 := l_inc_work_summary;
      l_service_request_rec.caller_type             := l_IRandISO_Out_Rec.party_type;
      l_service_request_rec.customer_id             := l_IRandISO_Out_Rec.party_id;
      l_service_request_rec.inventory_item_id       := l_IRandISO_In_Rec.inventory_item_id;
      l_service_request_rec.inventory_org_id        := cs_std.get_item_valdn_orgzn_id;
      --l_service_request_rec.purchase_order_num     := C1.purchase_order_num;
      l_service_request_rec.bill_to_site_use_id     := l_bill_to_party_site_use_id;
      l_service_request_rec.bill_to_party_id        := l_bill_to_party_id;
      l_service_request_rec.bill_to_site_id         := l_bill_to_party_site_id;
      l_service_request_rec.ship_to_site_use_id     := l_ship_to_party_site_use_id;
      l_service_request_rec.ship_to_party_id        := l_ship_to_party_id;
      l_service_request_rec.ship_to_site_id         := l_ship_to_party_site_id;
      l_service_request_rec.account_id              := l_IRandISO_Out_Rec.cust_account_id;
      l_service_request_rec.cust_po_number          := l_IRandISO_In_Rec.purchase_order_num;
      l_service_request_rec.sr_creation_channel     := 'AUTOMATIC';  --- Since this SR is created by  API
      l_service_request_rec.publish_flag            := '';
      l_service_request_rec.verify_cp_flag          := 'N';
 	  l_Service_Request_Rec.inv_item_revision       := l_IRandISO_In_Rec.Item_Revision ;


      -- Not creating  contact for SR as it is optional
      -- Call to Service Request API
      CS_SERVICEREQUEST_PUB.Create_ServiceRequest(
          p_api_version              => 3.0,
          p_init_msg_list            => FND_API.G_TRUE,
          p_commit                   => FND_API.G_FALSE,
          x_return_status            => l_return_status,
          x_msg_count                => l_msg_count,
          x_msg_data                 => l_msg_data,
          p_resp_appl_id             => NULL,
          p_resp_id                  => NULL,
          p_user_id                  => fnd_global.user_id,
          p_login_id                 => fnd_global.conc_login_id,
          p_org_id                   => NULL,
          p_request_id               => NULL,
          p_request_number           => NULL,
          p_service_request_rec      => l_service_request_rec,
          p_notes                    => l_notes_table,
          p_contacts                 => l_contacts_table,
          p_auto_assign              => C_NO ,
          x_request_id               => l_incident_id,
          x_request_number           => l_incident_number,
          x_interaction_id           => ln_interaction_id,
          x_workflow_process_id      => ln_workflow_id,
          x_individual_owner         => l_individual_owner,
          x_group_owner              => l_group_owner,
          x_individual_type          => l_individual_type );

         x_Return_Status := l_Return_Status ;
         If Not(x_return_status = FND_API.G_RET_STS_SUCCESS) Then
             If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
                Fnd_Log.String(Fnd_Log.Level_Error,C_Module || '.Create_ServiceRequest',
               'Error : While calling procedure CS_SERVICEREQUEST_PUB.Create_ServiceRequest');
             End If;
             Raise  FND_API.G_EXC_ERROR ;
         Else
            If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
               Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.Create_ServiceRequest',
              'Sucsess : While calling procedure CS_SERVICEREQUEST_PUB.Create_ServiceRequest');
            End If;
         End If;
        --- Check if Item is serialized item
        Begin
           Select 'Y'
           into    l_serialized_flag
           from   mtl_system_items
           where  inventory_item_id  = l_IRandISO_In_Rec.inventory_item_id
           and    organization_id    = l_IRandISO_In_Rec.source_organization_id
           and    serial_number_control_code <> 1;
        Exception
           When No_Data_Found then
              l_serialized_flag := C_NO;
        End;
        ---- Assign values Repair Order Record
        l_rep_line_rec.Incident_Id        :=   l_incident_id    ;
        l_rep_line_rec.Inventory_Item_Id  :=   l_IRandISO_In_Rec.inventory_item_id;
        l_rep_line_rec.Unit_Of_Measure    :=   l_IRandISO_In_Rec.order_quantity_uom;
        l_rep_line_rec.Repair_Type_Id     :=   l_repair_type_id ;
        l_rep_line_rec.Repair_Mode        :=   l_repair_mode    ;
        l_rep_line_rec.Status             :=   C_Status_Open_Code  ;
        l_rep_line_rec.Status_Reason_Code :=   NULL;
        l_rep_line_rec.Date_Closed        :=   NULL;
        l_rep_line_rec.Approval_Required_Flag := C_NO;
        l_rep_line_rec.Approval_Status    :=   NULL;
        l_rep_line_rec.Quantity           :=   l_IRandISO_In_Rec.quantity ;
        l_rep_line_rec.Quantity_In_WIP    :=   NULL;
        l_rep_line_rec.Quantity_Rcvd      :=   NULL;
        l_rep_line_rec.Quantity_Shipped   :=   NULL;
        l_rep_line_rec.Repair_Group_Id    :=   NULL;
        l_rep_line_rec.RO_TXN_STATUS      :=   C_RO_Txn_Status_Booked ;
        l_rep_line_rec.Serial_Number      :=   NULL;
        l_rep_line_rec.Repair_Number      :=   NULL;
        l_rep_line_rec.PROMISE_DATE       :=   P_need_by_date;                --ER:3391950

	   l_Rep_Line_Rec.Item_Revision      := l_IRandISO_In_Rec.Item_Revision ;
        l_Rep_Line_Rec.Price_list_Header_Id       := l_IRandISO_In_Rec.Price_List_Id ;
        --  l_rep_line_rec.object_version_number   :=   NULL;
        l_rep_line_rec.currency_code := l_IRandISO_In_Rec.currency_code;
	   -- Check if ISO1 item and ISO2 items are same. If they are different
	   -- assign ISO2 item to supercession_inv_item_id
	   --bug# 4000602 saupadhy 11/05/2004 Pass Default Repair Org Id to Rep_Line_rec.
	   l_Rep_Line_Rec.Resource_Group     := l_Default_RO_Org_Id ;
/*
	   If l_IRandISO_In_Rec.Inventory_item_id <> l_IRandISO_Out_Rec.Inventory_Item_Id Then
	      l_Rep_Line_Rec.Supercession_Inv_Item_Id := l_IRandISO_Out_Rec.Inventory_Item_Id ;
	   Else
	      l_Rep_Line_Rec.Supercession_Inv_Item_Id := Null;

	   End If;
*/
       --bug#6692459 always stored the move out item_id to supercession_inv_item_id on csd_repairs table
       --always stored the move out quantity to the repair_yield_quantity on csd_repairs table
       l_Rep_Line_Rec.Supercession_Inv_Item_Id := l_IRandISO_Out_Rec.Inventory_Item_Id;
       l_Rep_Line_Rec.repair_yield_quantity    := l_IRandISO_Out_Rec.quantity;


        If l_Serialized_Flag = C_Yes Then

           l_rep_line_rec.Quantity           :=   1  ;

            ---Create RO as many as quantity column value
           For I in 1.. l_IRandISO_In_Rec.quantity  LOOP

              -- Fix for bug#5839636
              Open get_req_org_id (l_IRandISO_In_Rec.Req_Header_Id,
                                   l_IRandISO_In_Rec.Req_Line_Id);
              Fetch get_req_org_id INTO l_Rep_Line_Rec.inventory_org_id;
              Close get_req_org_id;

              csd_repairs_pvt.Create_Repair_Order(
                 P_Api_Version_Number     => 1.0 ,
                 P_Init_Msg_List          => FND_API.G_FALSE,
                 P_Commit                 => FND_API.G_FALSE,
                 p_validation_level       => FND_API.G_VALID_LEVEL_FULL,
                 p_REPAIR_LINE_ID         => NULL,
                 P_REPLN_Rec              => l_Rep_Line_Rec ,
                 X_REPAIR_LINE_ID         => l_Repair_Line_Id,
                 X_REPAIR_NUMBER          => l_Repair_Number,
                 X_Return_Status          => l_Return_Status,
                 X_Msg_Count              => l_Msg_Count,
                 X_Msg_Data               => l_Msg_Data  ) ;
              If l_Return_Status <> FND_API.G_RET_STS_SUCCESS Then
                 If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
                   Fnd_Log.String(Fnd_Log.Level_Error,C_Module || '.Create_Repair_Order',
                   'Error : While calling procedure CS_SERVICEREQUEST_PUB.Create_Repair_Order');
                 End If;
                 Raise FND_API.G_EXC_ERROR ;
              Else
                 If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
                   Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || '.Create_Repair_Order',
                   'Success : While calling procedure CS_SERVICEREQUEST_PUB.Create_Repair_Order');
                 End If;
              End If;
              -- Insert into Product Transactions table , Insert a row for Action Type Move-In
              l_Product_Trxn_Id := NULL ; -- This is just to make sure that new product trasaction id generated
              -- It is better to define a new procedure to handle insertions for internal repair orders in csd_process_pvt
              -- Then calling table handler directly in group API.
              csd_product_transactions_pkg.Insert_Row(
                 px_PRODUCT_TRANSACTION_ID     => l_Product_Trxn_Id, -- find out if this variable needs to be assigned a value
                 p_REPAIR_LINE_ID              => l_Repair_Line_Id ,
                 p_ESTIMATE_DETAIL_ID          => NULL,
                 p_ACTION_TYPE                 => C_ACTION_TYPE_MOVE_IN,
                 p_ACTION_CODE                 => C_ACTION_CODE_DEFECTIVES,
                 p_LOT_NUMBER                  => NULL,
                 p_SUB_INVENTORY               => l_IRandISO_In_Rec.Source_SubInventory,
                 p_INTERFACE_TO_OM_FLAG        => C_Yes,
                 p_BOOK_SALES_ORDER_FLAG       => C_Yes,
                 p_RELEASE_SALES_ORDER_FLAG    => NULL,
                 p_SHIP_SALES_ORDER_FLAG       => NULL,
                 p_PROD_TXN_STATUS             => C_PROD_TXN_STATUS_BOOKED ,
                 p_PROD_TXN_CODE               => NULL, -- Need to identify what value to be passed
                 p_LAST_UPDATE_DATE            => Sysdate ,
                 p_CREATION_DATE               => Sysdate,
                 p_LAST_UPDATED_BY             => Fnd_Global.User_Id,
                 p_CREATED_BY                  => Fnd_Global.User_Id,
                 p_LAST_UPDATE_LOGIN           => Fnd_Global.Login_Id,
                 p_ATTRIBUTE1                  => NULL ,
                 p_ATTRIBUTE2                  => NULL ,
                 p_ATTRIBUTE3                  => NULL ,
                 p_ATTRIBUTE4                  => NULL ,
                 p_ATTRIBUTE5                  => NULL ,
                 p_ATTRIBUTE6                  => NULL ,
                 p_ATTRIBUTE7                  => NULL ,
                 p_ATTRIBUTE8                  => NULL ,
                 p_ATTRIBUTE9                  => NULL ,
                 p_ATTRIBUTE10                 => NULL ,
                 p_ATTRIBUTE11                 => NULL ,
                 p_ATTRIBUTE12                 => NULL ,
                 p_ATTRIBUTE13                 => NULL ,
                 p_ATTRIBUTE14                 => NULL ,
                 p_ATTRIBUTE15                 => NULL ,
                 p_CONTEXT                     => NULL ,
                 p_OBJECT_VERSION_NUMBER       => 1,
                 p_Req_Header_Id               => l_IRandISO_In_Rec.Req_Header_Id,
                 p_Req_Line_Id                 => l_IRandISO_In_Rec.Req_Line_Id,
                 p_Order_Header_Id             => l_IRandISO_In_Rec.Order_Header_Id,
                 p_Order_Line_Id               => l_IRandISO_In_Rec.Line_Id ,
                 p_Prd_Txn_Qty_Received        => 0,
                 p_Prd_Txn_Qty_Shipped         => 0 ,
                 p_Source_Serial_Number        => NULL,
                 p_Source_Instance_Id          => Null,
                 p_Non_Source_Serial_Number    => NULL,
                 p_Non_Source_Instance_Id      => Null,
                 p_Sub_Inventory_Rcvd          => Null,
                 p_Lot_Number_Rcvd             => Null,
                 p_Locator_Id                  => Null,
                 p_picking_rule_id             => Null,
                 P_PROJECT_ID                  => Null,
                 P_TASK_ID                     => Null,
                 P_UNIT_NUMBER                 => Null);
                 -- Add for R12 pickrule id change.Vijay.

          -- Following code will not be raised but once I move above code to pvt file then this check will be required
          If l_Return_Status <> FND_API.G_RET_STS_SUCCESS Then
             If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
                Fnd_Log.String(Fnd_Log.Level_Error,C_Module || 'Create_InternalRO.Insert_Row',
                'Error : While calling procedure csd_product_transactions_pkg.Insert_Row for Defectives');
             End If;
             Raise FND_API.G_EXC_ERROR ;
          Else
              If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
                Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || 'Create_InternalRO.Insert_Row',
                'Success : While calling procedure csd_product_transactions_pkg.Insert_Row for Defectives');
              End If;
          End If;

              --- Insert into Product Transactions table , Insert a row for Action Type Move-Out
          l_Product_Trxn_Id := NULL ; -- This is just to make sure that new product trasaction id generated
          csd_product_transactions_pkg.Insert_Row(
             px_PRODUCT_TRANSACTION_ID   => l_Product_Trxn_Id,
             p_REPAIR_LINE_ID            =>   l_Repair_Line_Id ,
             p_ESTIMATE_DETAIL_ID        => NULL,
             p_ACTION_TYPE               => C_ACTION_TYPE_MOVE_OUT,
             p_ACTION_CODE               => C_ACTION_CODE_USABLES,
             p_LOT_NUMBER                => NULL,
             p_SUB_INVENTORY             => l_IRandISO_Out_Rec.Destination_SubInventory,
             p_INTERFACE_TO_OM_FLAG      => C_YEs,
             p_BOOK_SALES_ORDER_FLAG     =>  C_YEs,
             p_RELEASE_SALES_ORDER_FLAG  => NULL,
             p_SHIP_SALES_ORDER_FLAG     => NULL,
             p_PROD_TXN_STATUS           => C_PROD_TXN_STATUS_BOOKED,
             p_PROD_TXN_CODE             => NULL , -- Need to identify what value to be passed
             p_LAST_UPDATE_DATE          => Sysdate ,
             p_CREATION_DATE             => Sysdate,
             p_LAST_UPDATED_BY           => Fnd_Global.User_Id,
             p_CREATED_BY                => Fnd_Global.User_Id,
             p_LAST_UPDATE_LOGIN         => Fnd_Global.Login_Id,
             p_ATTRIBUTE1                => NULL ,
             p_ATTRIBUTE2                => NULL ,
             p_ATTRIBUTE3                => NULL ,
             p_ATTRIBUTE4                => NULL ,
             p_ATTRIBUTE5                => NULL ,
             p_ATTRIBUTE6                => NULL ,
             p_ATTRIBUTE7                => NULL ,
             p_ATTRIBUTE8                => NULL ,
             p_ATTRIBUTE9                => NULL ,
             p_ATTRIBUTE10               => NULL ,
             p_ATTRIBUTE11               => NULL ,
             p_ATTRIBUTE12               => NULL ,
             p_ATTRIBUTE13               => NULL ,
             p_ATTRIBUTE14               => NULL ,
             p_ATTRIBUTE15               => NULL ,
             p_CONTEXT                   => NULL ,
             p_OBJECT_VERSION_NUMBER     => 1,
             p_Req_Header_Id               => l_IRandISO_Out_Rec.Req_Header_Id,
             p_Req_Line_Id                 => l_IRandISO_Out_Rec.Req_Line_Id,
             p_Order_Header_Id             => l_IRandISO_Out_Rec.Order_Header_Id,
             p_Order_Line_Id               => l_IRandISO_Out_Rec.Line_Id ,
             p_Prd_Txn_Qty_Received        => NULL, -- changing it from 0
             p_Prd_Txn_Qty_Shipped         => 0 ,
             p_Source_Serial_Number        => NULL,
             p_Source_Instance_Id          => Null,
             p_Non_Source_Serial_Number    => NULL,
             p_Non_Source_Instance_Id      => Null,
             p_Sub_Inventory_Rcvd          => Null,
             p_Lot_Number_Rcvd             => Null,
             p_Locator_Id                  => Null,
             p_picking_rule_id             => Null,
             P_PROJECT_ID                  => Null,
             P_TASK_ID                     => Null,
             P_UNIT_NUMBER                 => Null);
             -- Add for R12 pickrule id change.Vijay.

          If l_Return_Status <> FND_API.G_RET_STS_SUCCESS Then
             If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
                Fnd_Log.String(Fnd_Log.Level_Error,C_Module || 'csd_product_transactions_pkg.Insert_Row',
                'Error : While calling procedure csd_product_transactions_pkg.Insert_Row for Defectives');
             End If;
             Raise FND_API.G_EXC_ERROR ;
          Else
             If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
                Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || 'Create_InternalRO.Insert_Row',
                'Success : While calling procedure csd_product_transactions_pkg.Insert_Row for Usables');
             End If;
          End If;

         End Loop ;
      Else

         l_rep_line_rec.Quantity    :=   l_IRandISO_In_Rec.quantity  ;

         -- Fix for bug#5839636
         Open get_req_org_id (l_IRandISO_In_Rec.Req_Header_Id,
                              l_IRandISO_In_Rec.Req_Line_Id);
         Fetch get_req_org_id INTO l_Rep_Line_Rec.inventory_org_id;
         Close get_req_org_id;

         ---Create Repair Order
         csd_repairs_pvt.Create_Repair_Order(
            P_Api_Version_Number     => 1.0 ,
            P_Init_Msg_List          => Fnd_Api.G_False,
            P_Commit                 => Fnd_Api.G_False,
            p_validation_level       => Fnd_Api.G_Valid_Level_Full,
            p_Repair_Line_ID         => NULL,
            P_Repln_Rec              => l_Rep_Line_Rec ,
            X_Repair_Line_ID         => l_Repair_Line_Id,
            X_Repair_Number          => l_Repair_Number,
            X_Return_Status          => l_Return_Status,
            X_Msg_Count              => l_Msg_Count,
            X_Msg_Data               =>  l_Msg_Data  ) ;
        If l_Return_Status <> FND_API.G_RET_STS_SUCCESS Then
           If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
              Fnd_Log.String(Fnd_Log.Level_Error,C_Module || 'Create_Repair_Order',
              'Error : While calling procedure csd_repairs_pvt.Create_Repair_Order ');
           End If;
           Raise FND_API.G_EXC_ERROR ;
        Else
           If Fnd_Log.Level_Statement >= Fnd_Log.G_Current_Runtime_Level  Then
              Fnd_Log.String(Fnd_Log.Level_Statement,C_Module || 'Create_Repair_Order',
              'Success : While calling procedure csd_repairs_pvt.Create_Repair_Order ');
           End If;
        End If;
        l_Product_Trxn_Id := NULL ; -- This is just to make sure that new product trasaction id generated
        -- Insert into Product Transactions table , Insert a row for Action Type Move-In
        csd_product_transactions_pkg.Insert_Row(
            px_PRODUCT_TRANSACTION_ID   => l_Product_Trxn_Id,
            p_REPAIR_LINE_ID            =>   l_Repair_Line_Id ,
            p_ESTIMATE_DETAIL_ID        => NULL,
            p_ACTION_TYPE               => C_ACTION_TYPE_MOVE_IN,
            p_ACTION_CODE               => C_ACTION_CODE_DEFECTIVES,
            p_LOT_NUMBER                => NULL,
            p_SUB_INVENTORY             => l_IRandISO_In_Rec.Source_SubInventory,
            p_INTERFACE_TO_OM_FLAG      => C_Yes,
            p_BOOK_SALES_ORDER_FLAG     => C_Yes,
            p_RELEASE_SALES_ORDER_FLAG  => NULL,
            p_SHIP_SALES_ORDER_FLAG     => NULL,
            p_PROD_TXN_STATUS           => C_PROD_TXN_STATUS_BOOKED,
            p_PROD_TXN_CODE             => NULL,-- Need to identify what value to be passed
            p_LAST_UPDATE_DATE          => Sysdate ,
            p_CREATION_DATE             => Sysdate,
            p_LAST_UPDATED_BY           => Fnd_Global.User_Id,
            p_CREATED_BY                => Fnd_Global.User_Id,
            p_LAST_UPDATE_LOGIN         => Fnd_Global.Login_Id,
            p_ATTRIBUTE1                => NULL ,
            p_ATTRIBUTE2                => NULL ,
            p_ATTRIBUTE3                => NULL ,
            p_ATTRIBUTE4                => NULL ,
            p_ATTRIBUTE5                => NULL ,
            p_ATTRIBUTE6                => NULL ,
            p_ATTRIBUTE7                => NULL ,
            p_ATTRIBUTE8                => NULL ,
            p_ATTRIBUTE9                => NULL ,
            p_ATTRIBUTE10               => NULL ,
            p_ATTRIBUTE11               => NULL ,
            p_ATTRIBUTE12               => NULL ,
            p_ATTRIBUTE13               => NULL ,
            p_ATTRIBUTE14               => NULL ,
            p_ATTRIBUTE15               => NULL ,
            p_CONTEXT                   => NULL ,
            p_OBJECT_VERSION_NUMBER     => 1,
            p_Req_Header_Id             => l_IRandISO_In_Rec.Req_Header_Id,
            p_Req_Line_Id               => l_IRandISO_In_Rec.Req_Line_Id,
            p_Order_Header_Id           => l_IRandISO_In_Rec.Order_Header_Id,
            p_Order_Line_Id             => l_IRandISO_In_Rec.Line_Id ,
            p_Prd_Txn_Qty_Received      => 0,
            p_Prd_Txn_Qty_Shipped       => 0 ,
            p_Source_Serial_Number      => NULL,
            p_Source_Instance_Id    => Null,
            p_Non_Source_Serial_Number  => NULL,
            p_Non_Source_Instance_Id => Null,
            p_Sub_Inventory_Rcvd        => Null,
            p_Lot_Number_Rcvd           => Null,
            p_Locator_Id                  => Null,
            p_picking_rule_id             => Null,
            P_PROJECT_ID                  => Null,
            P_TASK_ID                     => Null,
            P_UNIT_NUMBER                 => Null);
            -- Add for R12 pickrule id change.Vijay.

        If l_Return_Status <> FND_API.G_RET_STS_SUCCESS Then
           If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
              Fnd_Log.String(Fnd_Log.Level_Error,C_Module || 'csd_product_transactions_pkg.Insert_Row',
              'Error : While calling procedure csd_product_transactions_pkg.Insert_Row 2 for Defectives');
           End If;
           Raise FND_API.G_EXC_ERROR ;
        Else
           If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
              Fnd_Log.String(Fnd_Log.Level_Error,C_Module || 'csd_product_transactions_pkg.Insert_Row',
              'Success : While calling procedure csd_product_transactions_pkg.Insert_Row 2 for Defectives');
           End If;
        End If;

         -- Insert into Product Transactions table , Insert a row for Action Type Move-Out
        l_Product_Trxn_Id := NULL ; -- This is just to make sure that new product trasaction id generated
        csd_product_transactions_pkg.Insert_Row(
             px_PRODUCT_TRANSACTION_ID   => l_Product_Trxn_Id,
             p_REPAIR_LINE_ID            =>   l_Repair_Line_Id ,
             p_ESTIMATE_DETAIL_ID        => NULL,
             p_ACTION_TYPE               => C_ACTION_TYPE_MOVE_OUT,
             p_ACTION_CODE               => C_ACTION_CODE_USABLES,
             p_LOT_NUMBER                => NULL,
             p_SUB_INVENTORY             => l_IRandISO_Out_Rec.Destination_SubInventory,
             p_INTERFACE_TO_OM_FLAG      => C_Yes,
             p_BOOK_SALES_ORDER_FLAG     => C_Yes,
             p_RELEASE_SALES_ORDER_FLAG  => NULL,
             p_SHIP_SALES_ORDER_FLAG     => NULL,
             p_PROD_TXN_STATUS           => C_PROD_TXN_STATUS_BOOKED,
             p_PROD_TXN_CODE             => NULL , -- Need to identify what value to be passed
             p_LAST_UPDATE_DATE          => Sysdate ,
             p_CREATION_DATE             => Sysdate,
             p_LAST_UPDATED_BY           => Fnd_Global.User_Id,
             p_CREATED_BY                => Fnd_Global.User_Id,
             p_LAST_UPDATE_LOGIN         => Fnd_Global.Login_Id,
             p_ATTRIBUTE1                => NULL ,
             p_ATTRIBUTE2                => NULL ,
             p_ATTRIBUTE3                => NULL ,
             p_ATTRIBUTE4                => NULL ,
             p_ATTRIBUTE5                => NULL ,
             p_ATTRIBUTE6                => NULL ,
             p_ATTRIBUTE7                => NULL ,
             p_ATTRIBUTE8                => NULL ,
             p_ATTRIBUTE9                => NULL ,
             p_ATTRIBUTE10               => NULL ,
             p_ATTRIBUTE11               => NULL ,
             p_ATTRIBUTE12               => NULL ,
             p_ATTRIBUTE13               => NULL ,
             p_ATTRIBUTE14               => NULL ,
             p_ATTRIBUTE15               => NULL ,
             p_CONTEXT                   => NULL ,
             p_OBJECT_VERSION_NUMBER     => 1,
             p_Req_Header_Id               => l_IRandISO_Out_Rec.Req_Header_Id,
             p_Req_Line_Id                 => l_IRandISO_Out_Rec.Req_Line_Id,
             p_Order_Header_Id             => l_IRandISO_Out_Rec.Order_Header_Id,
             p_Order_Line_Id               => l_IRandISO_Out_Rec.Line_Id ,
             p_Prd_Txn_Qty_Received        => NULL, -- changing it from 0
             p_Prd_Txn_Qty_Shipped         => 0 ,
             p_Source_Serial_Number        => NULL,
             p_Source_Instance_Id          => Null,
             p_Non_Source_Serial_Number    => NULL,
             p_Non_Source_Instance_ID      => Null,
             p_Sub_Inventory_Rcvd          => Null,
             p_Lot_Number_Rcvd             => Null,
             p_Locator_Id                  => Null,
             p_picking_rule_id             => Null,
             P_PROJECT_ID                  => Null,
             P_TASK_ID                     => Null,
             P_UNIT_NUMBER                 => Null);
             -- Add for R12 pickrule id change.Vijay.

       If l_Return_Status <> FND_API.G_RET_STS_SUCCESS Then
           If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
              Fnd_Log.String(Fnd_Log.Level_Error,C_Module || 'csd_product_transactions_pkg.Insert_Row',
              'Error : While calling procedure csd_product_transactions_pkg.Insert_Row 2 for Usables');
           End If;
           Raise FND_API.G_EXC_ERROR ;
        Else
           If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
              Fnd_Log.String(Fnd_Log.Level_Error,C_Module || 'csd_product_transactions_pkg.Insert_Row',
              'Error : While calling procedure csd_product_transactions_pkg.Insert_Row 2 for Usables');
           End If;
        End If;


    End If;

    -- Standard check of p_commit.
    IF FND_API.To_Boolean( p_commit ) THEN
       COMMIT WORK;
    END IF;
    If Fnd_Log.Level_Error >= Fnd_Log.G_Current_Runtime_Level  Then
       Fnd_Log.String(Fnd_Log.Level_Error,C_Module || 'End',
       'End of procedure :  Create_InternalRO');
    End If;
Exception
   When FND_API.G_EXC_UNEXPECTED_ERROR Then
      -- If there is an error then rollback all database transactions for this API
      Rollback To Create_InternalRO;
      --- Standard call to get error messages if count is  Null
      FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data    =>  x_msg_data ) ;
      x_return_status := FND_API.G_RET_STS_ERROR ;

   When FND_API.G_EXC_ERROR Then
      -- If there is an error then rollback all database transactions for this API
      Rollback To Create_InternalRO;
      --- Standard call to get error messages if count is  Null
      FND_MSG_PUB.Count_And_Get
           (p_count  =>  x_msg_count,
            p_data   =>  x_msg_data );
      x_return_status := FND_API.G_RET_STS_ERROR ;

When Others Then
      -- If there is an error then rollback all database transactions for this API
      Rollback To Create_InternalRO;
      x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
      IF FND_MSG_PUB.Check_Msg_Level
		 (FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
 	  THEN
      	 FND_MSG_PUB.Add_Exc_Msg(G_PKG_NAME ,c_api_name );
	  END IF;
	  FND_MSG_PUB.Count_And_Get(p_count =>x_msg_count,
        p_data   => x_msg_data );

End Create_InternalRO ;

End CSD_Refurbish_IRO_GRP ;

/
