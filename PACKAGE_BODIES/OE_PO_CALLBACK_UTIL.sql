--------------------------------------------------------
--  DDL for Package Body OE_PO_CALLBACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_PO_CALLBACK_UTIL" As
/* $Header: OEXDPOCB.pls 115.0 99/07/26 11:07:23 porting shi $ */
--
-- The following are global variables.
--
--
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_PO_CALLBACK_UTIL';
--
 G_OE_SOURCE_CODE              Varchar2(25);
 G_DROP_SHIP_SOURCE_ID         Number;
 G_HEADER_ID                   Number;
 G_LINE_ID                     Number;
 G_ORG_ID                      Number;
 G_DESTINATION_ORGANIZATION_ID Number;
 G_REQUISITION_HEADER_ID       Number;
 G_REQUISITION_LINE_ID         Number;
 G_PO_HEADER_ID                Number;
 G_PO_LINE_ID                  Number;
--
-- Function to validate the existence of a drop ship source id. When PO
-- calls this call back, a drop ship source id has to exist. There can
-- be  duplicates on this source id if PO splits a requisition or a PO.
--
 Function Valid_Drop_Ship_Source_ID(P_Drop_Ship_Source_ID In Number)
		       Return Boolean Is
  Cursor L_Drop_Ship_Source_ID_Csr Is
  Select Count(*)
    From SO_DROP_SHIP_SOURCES
   Where Drop_Ship_Source_ID = P_Drop_Ship_Source_ID ;
--
   L_Drop_Ship_Source_Count Number(4);
 Begin
  Open L_Drop_Ship_Source_ID_Csr ;
  Fetch L_Drop_Ship_Source_ID_Csr Into L_Drop_Ship_Source_Count ;
  If L_Drop_Ship_Source_Count > 0 Then
   Return True;
  Else
   Return False;
  End If;
 End Valid_Drop_Ship_Source_ID;
--
 Procedure Insert_SO_Drop_Ship_Sources (P_Drop_Ship_Source_ID         In Number,
                                        P_Header_ID                   In Number,
                                        P_Line_ID                     In Number,
                                        P_Org_ID                      In Number,
                                        P_Destination_Organization_ID In Number,
                                        P_Requisition_Header_ID       In Number,
                                        P_Requisition_Line_ID         In Number,
                                        P_PO_Header_ID                In Number,
                                        P_PO_Line_ID                  In Number,
                                        P_Line_Location_ID            In Number,                                        P_PO_Release_ID               In Number
								   Default Null)
                                        IS
 Begin

   Insert Into SO_Drop_Ship_Sources
   (
    Drop_Ship_Source_ID,
    Header_ID,
    Line_ID,
    Org_ID,
    Destination_Organization_ID,
    Requisition_Header_ID,
    Requisition_Line_ID,
    PO_Header_ID,
    PO_Line_ID,
    Line_Location_ID,
    PO_Release_ID,
    Creation_Date,
    Created_By,
    Last_Update_Date,
    Last_Updated_By
   )
    Values
   (
    P_Drop_Ship_Source_ID,
    P_Header_ID,
    P_Line_ID,
    P_Org_ID,
    P_Destination_Organization_ID,
    P_Requisition_Header_ID,
    P_Requisition_Line_ID,
    P_PO_Header_ID,
    P_PO_Line_ID,
    P_Line_Location_ID,
    P_PO_Release_ID,
    Trunc(Sysdate),
    Nvl(To_Number(FND_PROFILE.VALUE('USER_ID')),-1),
    Trunc(Sysdate),
    Nvl(To_Number(FND_PROFILE.VALUE('USER_ID')),-1)
   );
End Insert_SO_Drop_Ship_Sources;
--
-- Update_Req_Info is an OE procedure that is called by Oracle Purchasing to
-- update requisition information for a drop shipped line. This procedure is
-- called in the  Requisition Import (ReqImport) process of Oracle Purchasing
--
Procedure Update_Req_Info(P_API_Version              In  Number,
			  P_Return_Status            Out Varchar2,
		          P_Msg_Count                Out Number,
			  P_MSG_Data                 Out Varchar2,
			  P_Interface_Source_Code    In  Varchar2,
                          P_Interface_Source_Line_ID In  Number,
                          P_Requisition_Header_ID    In  Number,
                          P_Requisition_Line_ID      In  Number) Is

 L_API_Name    Constant Varchar2(30) := 'UPDATE_REQ_INFO';
 L_API_Version Constant Number       := 1.0;
 L_SQLCODE Number;
 L_SQLERRM Varchar2(2000);

 Cursor L_SO_Drop_Ship_Source_CSR (P_Interface_Source_Line_ID In Number)Is
 Select Drop_Ship_Source_ID,
	Header_ID,
	Line_ID,
	Org_ID,
	Destination_Organization_ID,
        Requisition_Header_ID,
        Requisition_Line_ID,
        PO_Header_ID,
	PO_Line_ID
  From  SO_Drop_Ship_Sources
  Where Drop_Ship_source_ID = P_Interface_Source_Line_ID
  For Update of Requisition_Header_ID;
--
Begin
--
 SavePoint Update_Req_Info_GRP;
--
 IF Not FND_API.Compatible_API_Call (L_API_Version,
				     P_API_Version,
				     L_API_Name,
				     G_PKG_Name) Then
  Raise FND_API.G_EXC_UNEXPECTED_ERROR;
 End If;
--
 FND_PROFILE.Get('SO_SOURCE_CODE',G_OE_SOURCE_CODE); -- Returns OE's profile
                                                     -- value for SO_SOURCE_CODE
 If P_Interface_Source_Code = G_OE_Source_Code Then
  Null;
 Else -- Interface source code is not an OE interface source code
  P_Return_Status := FND_API.G_RET_STS_SUCCESS;
  Return;
 End If;
--
 If Valid_Drop_Ship_Source_Id(P_INTERFACE_SOURCE_LINE_ID) Then
  Null;
 Else -- The drop ship  source  ID does not exist. Serious Error!
  Rollback to Update_Req_INfo_GRP;
  P_Return_Status := FND_API.G_RET_STS_ERROR;
  Return;
 End If;
--
 Open  L_SO_Drop_Ship_Source_Csr(P_INTERFACE_SOURCE_LINE_ID);
 Fetch L_SO_Drop_Ship_Source_Csr Into  G_Drop_Ship_Source_ID,
	                               G_Header_ID,
	                               G_Line_ID,
	                               G_Org_ID,
	                               G_Destination_Organization_ID,
                                       G_Requisition_Header_ID,
                                       G_Requisition_Line_ID,
                                       G_PO_Header_ID,
	                               G_PO_Line_ID;
--
  If L_SO_Drop_Ship_Source_Csr%Found Then
   If G_Requisition_Header_ID Is Null Then -- Requisition being updated for the
				          -- first time
    Update SO_Drop_Ship_Sources
       Set Requisition_Header_ID = P_Requisition_Header_ID,
	   Requisition_LIne_ID   = P_Requisition_Line_ID,
	   Last_Update_Date      = Trunc(Sysdate),
	   Last_Updated_By       = Nvl(To_Number(FND_PROFILE.VALUE('USER_ID')),-1)
     Where Current of L_SO_Drop_Ship_SOurce_Csr;
   Else -- Another requisition for same order line.
    Insert_SO_Drop_Ship_Sources ( P_Drop_Ship_Source_ID => G_Drop_Ship_Source_ID,
                                 P_Header_ID           => G_Header_ID,
                                 P_Line_ID             => G_Line_ID,
                                 P_Org_ID              => G_Org_ID,
                                 P_Destination_Organization_ID =>
                                   G_Destination_Organization_ID,
                                 P_Requisition_Header_ID =>
                                   P_Requisition_Header_ID,
                                 P_Requisition_LIne_ID => P_Requisition_Line_ID,
                                 P_PO_Header_ID        => Null,
                                 P_PO_Line_ID          => Null,
                                 P_Line_Location_ID    => Null);
  End If;
 End If;
 Close L_SO_Drop_Ship_Source_Csr;
 P_Return_Status := FND_API.G_RET_STS_SUCCESS;
 Exception
  When Others Then
   Rollback to Update_Req_INfo_Grp;
   P_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) Then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_Name,L_API_Name);
   End If;
   FND_MSG_PUB.Count_And_Get (P_Count => P_MSG_Count,
	                      P_Data  => P_MSG_Data);
End Update_Req_Info;
--
--
-- Update_All_Reqs_In_Process is an OE procedure that is called by
-- Oracle Purchasing to update requisition information for a drop shipped line.
-- This procedure is called in the Requisition Import (ReqImport) process of
-- Oracle Purchasing.
Procedure Update_All_Reqs_In_Process(P_API_Version              In  Number,
			             P_Return_Status            Out Varchar2,
		                     P_Msg_Count                Out Number,
			             P_MSG_Data                 Out Varchar2,
				     P_Requisition_Header_ID    In Number,
                                     P_Request_Id               In Number,
				     P_Process_Flag             In Varchar2) Is

 L_API_Name    Constant Varchar2(30) := 'UPDATE_ALL_REQS_IN_PROCESS';
 L_API_Version Constant Number       := 1.0;

 L_Interface_Source_Code    Varchar2(25);
 L_Interface_Source_Line_Id Number;
 L_Requisition_Header_Id    Number;
 L_Requisition_Line_Id      Number;

 L_Return_Status            Varchar2(1);
 L_Msg_Count                Number;
 L_MSG_Data                 Varchar2(1000);

 Cursor L_PO_Req_Interface_CSR Is
 Select Interface_Source_COde,Interface_source_line_id,
        requisition_header_id,requisition_line_id
   from po_requisitions_interface
  WHERE requisition_header_id = P_Requisition_Header_ID
    AND process_flag          = P_Process_Flag
    AND request_id            = P_Request_Id;
Begin
--
 SavePoint UPDATE_ALL_REQS_IN_PROCESS;
--
 IF Not FND_API.Compatible_API_Call (L_API_Version,
				     P_API_Version,
				     L_API_Name,
				     G_PKG_Name) Then
  Raise FND_API.G_EXC_UNEXPECTED_ERROR;
 End If;
--
 Open L_PO_Req_Interface_CSR;
 Loop
  Fetch L_PO_Req_Interface_CSR Into L_Interface_Source_Code,
  				    L_Interface_Source_Line_Id,
				    L_Requisition_Header_Id,
				    L_Requisition_Line_Id;
  If L_PO_Req_Interface_CSR%NotFound Then
   P_Return_Status := FND_API.G_RET_STS_SUCCESS;
   Exit;
  End If;

  Update_Req_Info(1.0,
 	          L_Return_Status,
                  L_Msg_Count,
		  L_MSG_Data,
		  L_Interface_Source_Code,
                  L_Interface_Source_Line_ID,
                  L_Requisition_Header_ID,
                  L_Requisition_Line_ID);
  P_Return_Status := L_Return_Status ;
  If L_Return_Status = FND_API.G_RET_STS_SUCCESS Then
   Null;
  Else
   Close L_PO_Req_Interface_CSR;
   Exit;
 End If;
 End Loop;
 Close L_PO_Req_Interface_CSR;

 Exception
  When Others Then
   Rollback to UPDATE_ALL_REQS_IN_PROCESS;
   P_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) Then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_Name,L_API_Name);
   End If;
   FND_MSG_PUB.Count_And_Get (P_Count => P_MSG_Count,
	                      P_Data  => P_MSG_Data);
End Update_All_Reqs_In_Process;

--
-- Update_PO_Info is an OE procedure that is called by Oracle Purchasing to
-- update purchase order information for a drop shipped line. This procedure
-- is called in the Auto create process of Oracle Purchasing
Procedure Update_PO_Info     ( P_API_Version              In  Number,
			       P_Return_Status            Out Varchar2,
                               P_Msg_Count                Out Number,
			       P_MSG_Data                 Out Varchar2,
                               P_Req_Header_ID 	          In  Number,
                               P_Req_Line_ID 	          In  Number,
                               P_PO_Header_Id             In  Number,
                               P_PO_Line_Id               In  Number,
                               P_Line_Location_ID         In  Number,
			       P_PO_Release_ID            In  Number
							  Default Null) Is

 L_API_Name    Constant Varchar2(30) := 'UPDATE_PO_INFO';
 L_API_Version Constant Number       := 1.0;

 Cursor L_SO_Drop_Ship_Source_CSR (P_Req_Line_ID In Number,
				   P_Req_Header_Id In Number)Is
 Select Drop_Ship_Source_ID,
	Header_ID,
	Line_ID,
	Org_ID,
	Destination_Organization_ID,
        Requisition_Header_ID,
        Requisition_Line_ID,
        PO_Header_ID,
	PO_Line_ID
  From  SO_Drop_Ship_Sources
  Where Requisition_Line_ID   = P_Req_Line_ID
    And Requisition_Header_ID = P_Req_Header_ID
  For Update of PO_Header_ID;
Begin
 SavePoint Update_PO_Info_GRP;
 IF Not FND_API.Compatible_API_Call (L_API_Version,
				     P_API_Version,
				     L_API_Name,
				     G_PKG_Name) THen
  Raise FND_API.G_EXC_UNEXPECTED_ERROR;
 End If;
--
  Open  L_SO_Drop_Ship_SOurce_Csr(P_REQ_LINE_ID,P_REQ_HEADER_ID);
  Fetch L_So_Drop_Ship_Source_Csr Into G_Drop_Ship_Source_ID,
	                               G_Header_ID,
	                               G_Line_ID,
	                               G_Org_ID,
	                               G_Destination_ORganization_ID,
                                       G_Requisition_Header_ID,
                                       G_Requisition_Line_ID,
                                       G_PO_Header_ID,
	                               G_PO_Line_ID;
  If L_SO_Drop_Ship_Source_CSR%Found Then -- P_Req_Line_Id Is a drop ship
					  -- line id
   If G_Requisition_Header_ID Is Not Null -- PO being updated for the
      And G_PO_Header_ID Is Null Then        -- first time
   Update SO_Drop_Ship_Sources
      Set PO_Header_ID     = P_PO_Header_ID,
	  PO_Line_ID       = P_PO_Line_ID,
	  Line_Location_ID = P_Line_Location_ID,
	  PO_Release_ID    = Nvl(P_PO_Release_Id,PO_Release_ID),
	  Last_Update_Date = Trunc(Sysdate),
	  Last_Updated_By  = Nvl(To_Number(FND_PROFILE.VALUE('USER_ID')),-1)
    Where Current of L_SO_Drop_Ship_Source_Csr;
   Else -- Another PO for same order line.
    Insert_SO_Drop_Ship_Sources (P_Drop_Ship_Source_ID => G_Drop_Ship_Source_ID,
                                 P_Header_ID           => G_Header_ID,
                                 P_Line_ID             => G_Line_ID,
                                 P_Org_ID              => G_Org_ID,
                                 P_Destination_Organization_ID =>
                                    G_Destination_Organization_ID,
                                 P_Requisition_Header_ID =>
                                    G_Requisition_Header_ID,
                                 P_Requisition_Line_ID => G_Requisition_Line_ID,
                                 P_PO_Header_ID        => P_PO_Header_ID,
                                 P_PO_Line_ID          => P_PO_Line_ID,
                                 P_Line_Location_ID    => P_Line_Location_ID,
				 P_PO_Release_Id       => P_PO_Release_ID);
   End If;
  End If;
  Close L_SO_Drop_Ship_Source_Csr;
  P_Return_Status := FND_API.G_RET_STS_SUCCESS;
 Exception
  When Others Then
   Rollback to Update_PO_Info_GRP;
   P_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
   IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) Then
    FND_MSG_PUB.Add_Exc_Msg(G_PKG_Name,L_API_Name);
   End If;
   FND_MSG_PUB.Count_And_Get (P_Count => P_MSG_Count,
	                      P_Data  => P_MSG_Data);
End Update_PO_Info;
--
Function Req_Line_Is_Drop_Ship(P_Req_Line_Id              In  Number)
			       Return Number Is
 L_Line_Id Number;
 Cursor L_Drop_Ship_Csr Is
 Select Line_Id
   From SO_Drop_Ship_Sources
  Where Requisition_Line_ID = P_Req_Line_ID;
Begin
 Open L_Drop_Ship_Csr;

 Fetch L_Drop_Ship_Csr Into L_Line_Id;

 If L_Drop_Ship_Csr%NotFound Then -- Req Line Id is not a "drop Ship" Req

  Close L_Drop_Ship_Csr;
  Return Null;

 Else -- Req Line Id is a "drop Ship" Req

  Close L_Drop_Ship_Csr;
  Return L_Line_Id;

 End If;

End Req_Line_Is_Drop_Ship;
--
Function PO_Line_Location_Is_Drop_Ship(P_PO_Line_Location_Id In Number)
			       Return Number Is
 L_Line_Id Number;
 Cursor L_Drop_Ship_Csr Is
 Select Line_Id
   From SO_Drop_Ship_Sources
  Where Line_Location_Id = P_PO_Line_Location_ID;
Begin
 Open L_Drop_Ship_Csr;

 Fetch L_Drop_Ship_Csr Into L_Line_Id;

 If L_Drop_Ship_Csr%NotFound Then -- PO Line Location Id is not a "drop Ship"
				  -- Line location

  Close L_Drop_Ship_Csr;
  Return Null;

 Else -- PO Line Location Id is a "drop Ship" Line Location

  Close L_Drop_Ship_Csr;
  Return L_Line_Id;

 End If;

End PO_Line_Location_Is_Drop_Ship;

End OE_PO_CALLBACK_UTIL;

/
