--------------------------------------------------------
--  DDL for Package Body OE_DROP_SHIP_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."OE_DROP_SHIP_GRP" As
/* $Header: OEXUDSHB.pls 120.2.12000000.2 2007/05/14 20:57:01 prpathak ship $ */
--
-- The following are global variables.
--
--
 G_PKG_NAME CONSTANT VARCHAR2(30) := 'OE_DROP_SHIP_GRP';
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

/*-----------------------------------------------------------------
FUNCTION:Valid_Drop_Ship_Source_ID
DESCRIPTION: Function to validate the existence of a drop ship source
             id. When PO calls this call back, a drop ship source id has
             to exist. There can be  duplicates on this source id if PO
             splits a requisition or a PO.
-----------------------------------------------------------------*/
Function Valid_Drop_Ship_Source_ID
(P_Drop_Ship_Source_ID In Number)
Return Boolean
IS
Cursor L_Drop_Ship_Source_ID_Csr Is
Select Count(*)
From OE_DROP_SHIP_SOURCES
Where Drop_Ship_Source_ID = P_Drop_Ship_Source_ID ;
--
L_Drop_Ship_Source_Count Number(4);

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
Begin

   Open L_Drop_Ship_Source_ID_Csr ;
   Fetch L_Drop_Ship_Source_ID_Csr Into L_Drop_Ship_Source_Count ;
   IF L_Drop_Ship_Source_Count > 0 Then
       Return True;
   ELSE
       Return False;
  End If;

END Valid_Drop_Ship_Source_ID;

/*-----------------------------------------------------------------
PROCEDURE :  Insert_OE_Drop_Ship_Source
DESCRIPTION:
-----------------------------------------------------------------*/

PROCEDURE Insert_OE_Drop_Ship_Sources
         (P_Drop_Ship_Source_ID         In Number,
          P_Header_ID                   In Number,
          P_Line_ID                     In Number,
          P_Org_ID                      In Number,
          P_Destination_Organization_ID In Number,
          P_Requisition_Header_ID       In Number,
          P_Requisition_Line_ID         In Number,
          P_PO_Header_ID                In Number,
          P_PO_Line_ID                  In Number,
          P_Line_Location_ID            In Number,                                        P_PO_Release_ID               In Number Default Null)
IS
--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

   Insert Into OE_Drop_Ship_Sources
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

End Insert_OE_Drop_Ship_Sources;

/*-----------------------------------------------------------------
PROCEDURE :  Update_Req_Info
DESCRIPTION: Update_Req_Info is an OE procedure that is called by
             Oracle Purchasing to update requisition information for
             a drop shipped line. This procedure is called in the
             Requisition Import (ReqImport) process of Oracle Purchasing
-----------------------------------------------------------------*/

PROCEDURE Update_Req_Info
              (P_API_Version              In  Number,
P_Return_Status out nocopy Varchar2,

P_Msg_Count out nocopy Number,

P_MSG_Data out nocopy Varchar2,

               P_Interface_Source_Code    In  Varchar2,
               P_Interface_Source_Line_ID In  Number,
               P_Requisition_Header_ID    In  Number,
               P_Requisition_Line_ID      In  Number)
IS

L_API_Name    Constant Varchar2(30) := 'UPDATE_REQ_INFO';
L_API_Version Constant Number       := 1.0;
L_SQLCODE Number;
L_SQLERRM Varchar2(2000);

Cursor L_OE_Drop_Ship_Source_CSR (P_Interface_Source_Line_ID In Number)Is
SELECT Drop_Ship_Source_ID,
       Header_ID,
       Line_ID,
       Org_ID,
       Destination_Organization_ID,
       Requisition_Header_ID,
       Requisition_Line_ID,
       PO_Header_ID,
       PO_Line_ID
FROM  OE_Drop_Ship_Sources
WHERE Drop_Ship_source_ID = P_Interface_Source_Line_ID
FOR UPDATE OF Requisition_Header_ID NOWAIT; -- bug 4503620

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    SavePoint Update_Req_Info_GRP;

    IF Not FND_API.Compatible_API_Call
                       (L_API_Version,
			P_API_Version,
			L_API_Name,
			G_PKG_Name)
    THEN
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    -- Returns OE's profile value for SO_SOURCE_CODE
    FND_PROFILE.Get('ONT_SOURCE_CODE',G_OE_SOURCE_CODE);

    IF P_Interface_Source_Code = G_OE_Source_Code THEN
       Null;
    ELSE -- Interface source code is not an OE interface source code
        P_Return_Status := FND_API.G_RET_STS_SUCCESS;
        Return;
    END IF;

    IF Valid_Drop_Ship_Source_Id(P_INTERFACE_SOURCE_LINE_ID) Then
       Null;
    ELSE -- The drop ship  source  ID does not exist. Serious Error!
      Rollback to Update_Req_INfo_GRP;
      P_Return_Status := FND_API.G_RET_STS_ERROR;
      Return;
    End If;
--

    OPEN L_OE_Drop_Ship_Source_Csr(P_INTERFACE_SOURCE_LINE_ID);
    FETCH L_OE_Drop_Ship_Source_Csr
    INTO  G_DROP_SHIP_SOURCE_ID,
          G_HEADER_ID,
          G_LINE_ID,
          G_ORG_ID,
          G_DESTINATION_ORGANIZATION_ID,
          G_REQUISITION_HEADER_ID,
          G_REQUISITION_LINE_ID,
          G_PO_HEADER_ID,
          G_PO_LINE_ID;

    IF L_OE_Drop_Ship_Source_Csr%Found THEN
        IF G_Requisition_Header_ID Is Null THEN
        -- Requisition being updated for the first time

            UPDATE OE_Drop_Ship_Sources
            SET Requisition_Header_ID = P_Requisition_Header_ID,
	           Requisition_LIne_ID   = P_Requisition_Line_ID,
	           Last_Update_Date      = Trunc(Sysdate),
	           Last_Updated_By       = Nvl(To_Number(FND_PROFILE.VALUE
                                                       ('USER_ID')),-1)
           WHERE Current of L_OE_Drop_Ship_Source_Csr;

       ELSE
          -- Another requisition for same order line.
           Insert_OE_Drop_Ship_Sources
               (P_Drop_Ship_Source_ID => G_Drop_Ship_Source_ID,
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
       END IF;
    END IF;
    CLOSE L_OE_Drop_Ship_Source_Csr;
    p_return_status := FND_API.G_RET_STS_SUCCESS;
EXCEPTION
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN -- bug 4503620
       Rollback to Update_Req_Info_Grp;
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('OEXUDSHB.pls:Update_Req_Info- unable to lock the line',1);
       END IF;
       fnd_message.set_name('ONT', 'OE_LINE_LOCKED');
       -- msg not added in OE as the msg ctx is not set
       P_Msg_Data := FND_MESSAGE.GET;
       P_Msg_Count := 1;
       p_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
       Rollback to Update_Req_Info_Grp;
       p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          OE_MSG_PUB.Add_Exc_Msg(G_PKG_Name,L_API_Name);
       END IF;
       OE_MSG_PUB.Count_And_Get (P_Count => P_MSG_Count,
   	                          P_Data  => P_MSG_Data);
END Update_Req_Info;


/*-----------------------------------------------------------------
PROCEDURE :  Update_All_Reqs_In_Process
DESCRIPTION: Update_All_Reqs_In_Process is an OE procedure that is
             called by Oracle Purchasing to update requisition
             information for a drop shipped line.  This procedure is
             called in the Requisition Import (ReqImport) process of
             Oracle Purchasing.
-----------------------------------------------------------------*/

PROCEDURE Update_All_Reqs_In_Process
(P_API_Version             In  Number,
P_Return_Status out nocopy Varchar2,

P_Msg_Count out nocopy Number,

P_MSG_Data out nocopy Varchar2,

P_Requisition_Header_ID    In  Number,
P_Request_Id               In  Number,
P_Process_Flag             In  Varchar2)
IS
L_API_Name                 Constant Varchar2(30)
							:= 'UPDATE_ALL_REQS_IN_PROCESS';
L_API_Version              Constant Number  := 1.0;
L_Interface_Source_Code    Varchar2(25);
L_Interface_Source_Line_Id Number;
L_Requisition_Header_Id    Number;
L_Requisition_Line_Id      Number;
L_Return_Status            Varchar2(1);
L_Msg_Count                Number;
L_MSG_Data                 Varchar2(1000);

CURSOR L_PO_Req_Interface_CSR Is
SELECT Interface_Source_Code,Interface_source_line_id,
        requisition_header_id,requisition_line_id
FROM po_requisitions_interface
WHERE requisition_header_id = P_Requisition_Header_ID
      AND process_flag      = P_Process_Flag
      AND request_id        = P_Request_Id;
      --
      l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
      --
BEGIN

  SAVEPOINT UPDATE_ALL_REQS_IN_PROCESS;

  IF Not FND_API.Compatible_API_Call (L_API_Version,
				     P_API_Version,
				     L_API_Name,
				     G_PKG_Name)
  THEN
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
  END IF;

  OPEN L_PO_Req_Interface_CSR;
  LOOP
     FETCH L_PO_Req_Interface_CSR Into L_Interface_Source_Code,
     				    L_Interface_Source_Line_Id,
   				    L_Requisition_Header_Id,
   				    L_Requisition_Line_Id;
     IF L_PO_Req_Interface_CSR%NotFound THEN
        p_return_status := FND_API.G_RET_STS_SUCCESS;
        EXIT;
     END IF;

     Update_Req_Info(1.0,
                     L_Return_Status,
                     L_Msg_Count,
                     L_MSG_Data,
                     L_Interface_Source_Code,
                     L_Interface_Source_Line_ID,
                     L_Requisition_Header_ID,
                     L_Requisition_Line_ID);

     p_return_status := l_Return_Status ;

     IF l_return_Status = FND_API.G_RET_STS_SUCCESS THEN
        Null;
     ELSE
       CLOSE L_PO_Req_Interface_CSR;
       EXIT;
     END IF;

  END LOOP;

  CLOSE L_PO_Req_Interface_CSR;

EXCEPTION

   WHEN OTHERS THEN
      ROLLBACK TO UPDATE_ALL_REQS_IN_PROCESS;
      p_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
      IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
      THEN
       OE_MSG_PUB.Add_Exc_Msg(G_PKG_Name,L_API_Name);
      END IF;
      OE_MSG_PUB.Count_And_Get (P_Count => P_MSG_Count,
                                 P_Data  => P_MSG_Data);
END Update_All_Reqs_In_Process;

/*-----------------------------------------------------------------
PROCEDURE :  Update_PO_Info
DESCRIPTION: Update_PO_Info is an OE procedure that is called by
             Oracle Purchasing to update purchase order information
             for a drop shipped line. This procedure is called in the
             Auto create process of Oracle Purchasing
-----------------------------------------------------------------*/

PROCEDURE Update_PO_Info (P_API_Version          In  Number,
P_Return_Status out nocopy Varchar2,

P_Msg_Count out nocopy Number,

P_MSG_Data out nocopy Varchar2,

                          P_Req_Header_ID        In  Number,
                          P_Req_Line_ID          In  Number,
                          P_PO_Header_Id         In  Number,
                          P_PO_Line_Id           In  Number,
                          P_Line_Location_ID     In  Number,
                          P_PO_Release_ID        In  Number Default Null)
IS

L_API_Name    Constant Varchar2(30) := 'UPDATE_PO_INFO';
L_API_Version Constant Number       := 1.0;

Cursor L_OE_Drop_Ship_Source_CSR (P_Req_Line_ID In Number,
				  P_Req_Header_Id In Number)
IS SELECT Drop_Ship_Source_ID,
	  Header_ID,
	  Line_ID,
	  Org_ID,
	  Destination_Organization_ID,
          Requisition_Header_ID,
          Requisition_Line_ID,
          PO_Header_ID,
	  PO_Line_ID
   FROM  OE_Drop_Ship_Sources
   WHERE Requisition_Line_ID   = P_Req_Line_ID
   AND Requisition_Header_ID = P_Req_Header_ID
   FOR Update of PO_Header_ID NOWAIT; -- bug 4503620

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN

    SavePoint Update_PO_Info_GRP;
    IF Not FND_API.Compatible_API_Call (L_API_Version,
				     P_API_Version,
				     L_API_Name,
				     G_PKG_Name)
    THEN
       Raise FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;
--
    OPEN  L_OE_Drop_Ship_SOurce_Csr(P_REQ_LINE_ID,P_REQ_HEADER_ID);
    FETCH L_OE_Drop_Ship_Source_Csr Into G_Drop_Ship_Source_ID,
	                               G_Header_ID,
	                               G_Line_ID,
	                               G_Org_ID,
	                               G_Destination_ORganization_ID,
                                       G_Requisition_Header_ID,
                                       G_Requisition_Line_ID,
                                       G_PO_Header_ID,
	                               G_PO_Line_ID;
    IF L_OE_Drop_Ship_Source_CSR%Found THEN
         -- P_Req_Line_Id Is a drop ship line id
         IF G_Requisition_Header_ID IS NOT NULL
            And G_PO_Header_ID IS NULL THEN
               -- PO being updated for the first time

               Update OE_Drop_Ship_Sources
               SET PO_Header_ID     = P_PO_Header_ID,
	           PO_Line_ID       = P_PO_Line_ID,
	           Line_Location_ID = P_Line_Location_ID,
	           PO_Release_ID    = Nvl(P_PO_Release_Id,PO_Release_ID),
	           Last_Update_Date = Trunc(Sysdate),
	           Last_Updated_By  = Nvl(To_Number(FND_PROFILE.VALUE('USER_ID')),-1)
               WHERE Current of L_OE_Drop_Ship_Source_Csr;
         ELSE -- Another PO for same order line.
              Insert_OE_Drop_Ship_Sources
                (P_Drop_Ship_Source_ID => G_Drop_Ship_Source_ID,
                 P_Header_ID           => G_Header_ID,
                 P_Line_ID             => G_Line_ID,
                 P_Org_ID              => G_Org_ID,
                 P_Destination_Organization_ID => G_Destination_Organization_ID,
                 P_Requisition_Header_ID => G_Requisition_Header_ID,
                 P_Requisition_Line_ID => G_Requisition_Line_ID,
                 P_PO_Header_ID        => P_PO_Header_ID,
                 P_PO_Line_ID          => P_PO_Line_ID,
                 P_Line_Location_ID    => P_Line_Location_ID,
		 P_PO_Release_Id       => P_PO_Release_ID);
        END IF;
    END IF;
    CLOSE L_OE_Drop_Ship_Source_Csr;
    P_Return_Status := FND_API.G_RET_STS_SUCCESS;

EXCEPTION
  WHEN APP_EXCEPTIONS.RECORD_LOCK_EXCEPTION THEN -- bug 4503620
       Rollback to Update_PO_Info_GRP;
       IF l_debug_level  > 0 THEN
         oe_debug_pub.add('OEXUDSHB.pls:Update_PO_Info-unable to lock the line',1);
       END IF;
       fnd_message.set_name('ONT', 'OE_LINE_LOCKED');
       -- msg not added in OE as the msg ctx is not set
       P_Msg_Data := FND_MESSAGE.GET;
       P_Msg_Count := 1;
       p_return_status := FND_API.G_RET_STS_ERROR;

  WHEN OTHERS THEN
       ROLLBACK TO Update_PO_Info_GRP;
       P_Return_Status := FND_API.G_RET_STS_UNEXP_ERROR;
       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          OE_MSG_PUB.Add_Exc_Msg(G_PKG_Name,L_API_Name);
       END IF;
       OE_MSG_PUB.Count_And_Get (P_Count => P_MSG_Count,
  	                          P_Data  => P_MSG_Data);
END Update_PO_Info;
--

/*-----------------------------------------------------------------
PROCEDURE :  Req_Line_Is_Drop_Ship
DESCRIPTION:
-----------------------------------------------------------------*/
Function Req_Line_Is_Drop_Ship(P_Req_Line_Id              In  Number)
RETURN NUMBER
IS

 L_Line_id Number;
 CURSOR L_Drop_Ship_Csr IS
 SELECT Line_Id
 FROM OE_Drop_Ship_Sources
 WHERE Requisition_Line_ID = P_Req_Line_ID;

--
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
--
BEGIN
  OPEN L_Drop_Ship_Csr;
  FETCH L_Drop_Ship_Csr Into L_Line_Id;

  IF L_Drop_Ship_Csr%NotFound THEN
     -- Req Line Id is not a "drop Ship" Req
     CLOSE L_Drop_Ship_Csr;
     RETURN NULL;
  ELSE
    -- Req Line Id is a "drop Ship" Req
    CLOSE L_Drop_Ship_Csr;
    RETURN L_Line_Id;
  END IF;
END Req_Line_Is_Drop_Ship;

--
/*-----------------------------------------------------------------
PROCEDURE :  PO_Line_Location_Is_Drop_Ship
DESCRIPTION:
-----------------------------------------------------------------*/
Function PO_Line_Location_Is_Drop_Ship(P_PO_Line_Location_Id In Number)
RETURN Number
IS
 L_Line_Id Number;
 Cursor L_Drop_Ship_Csr Is
 SELECT Line_Id
 FROM OE_Drop_Ship_Sources
 WHERE Line_Location_Id = P_PO_Line_Location_ID;
 --
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 --
BEGIN
 OPEN L_Drop_Ship_Csr;

 FETCH L_Drop_Ship_Csr Into L_Line_Id;

 IF L_Drop_Ship_Csr%NotFound THEN
    -- PO Line Location Id is not a "drop Ship" Line location
    CLOSE L_Drop_Ship_Csr;
    RETURN Null;
 ELSE
    -- PO Line Location Id is a "drop Ship" Line Location
    CLOSE L_Drop_Ship_Csr;
    RETURN L_Line_Id;
 END IF;

END PO_Line_Location_Is_Drop_Ship;

/*--------------------------------------------------
Procedure   : Update_Drop_Ship_Links
Description : This procedure will be called by PO
in the case of supplier initiated PO cancellation.
This will update line in oe dropship sources
with new requistion id.
----------------------------------------------------*/

Procedure Update_Drop_Ship_Links
( p_api_version          IN             NUMBER
 ,p_po_header_id         IN             NUMBER
 ,p_po_line_id           IN             NUMBER
 ,p_po_line_location_id  IN             NUMBER
 ,p_po_release_id        IN             NUMBER
 ,p_new_req_hdr_id       IN             NUMBER
 ,p_new_req_line_id      IN             NUMBER
 ,x_msg_data             OUT NOCOPY     VARCHAR2
 ,x_msg_count            OUT NOCOPY     NUMBER
 ,x_return_status        OUT NOCOPY     VARCHAR2
)
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_line_id              NUMBER;
l_header_id            NUMBER;
l_org_id               NUMBER;
l_num_lines            NUMBER;

BEGIN

  x_return_status   :=      FND_API.G_RET_STS_SUCCESS;

  SAVEPOINT Update_Drop_Ship_Links_GRP;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Entering Update_Drop_Ship_Links...',1);
  END IF;

  Get_Drop_Ship_Line_ids
              ( p_po_header_id         =>     p_po_header_id
               ,p_po_line_id           =>     p_po_line_id
               ,p_po_line_location_id  =>     p_po_line_location_id
               ,p_po_release_id        =>     p_po_release_id
               ,x_num_lines            =>     l_num_lines
               ,x_line_id              =>     l_line_id
               ,x_header_id            =>     l_header_id
               ,x_org_id               =>     l_org_id
              );

  IF p_new_req_hdr_id IS NOT NULL THEN

     UPDATE oe_drop_ship_sources
        SET requisition_header_id = p_new_req_hdr_id,
            requisition_line_id   = p_new_req_line_id,
            po_header_id          = NULL,
            po_line_id            = NULL,
            po_release_id         = NULL,
            line_location_id      = NULL,
            last_update_date      = Trunc(Sysdate),
            last_updated_by       = NVL(To_Number(FND_PROFILE.VALUE('USER_ID')),-1),
            last_update_login     = NVL(To_Number(FND_PROFILE.VALUE('USER_ID')),-1)
      WHERE line_id   = l_line_id
        AND header_id = l_header_id;

      IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('Updated the Drop Ship Links...',1);
      END IF;

  END IF;

 IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.Add('Exiting  Update_Drop_Ship_Links...',1);
 END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN

       IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('No DAta Found in Update_Drop_Ship_Links...',1);
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       ROLLBACK TO Update_Drop_Ship_Links;


  WHEN OTHERS THEN

       ROLLBACK TO Update_Drop_Ship_Links;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
       THEN
          OE_MSG_PUB.Add_Exc_Msg(
                 G_PKG_Name,
                 'Update_Drop_Ship_Links');
       END IF;

       OE_MSG_PUB.Count_And_Get (p_Count => x_msg_count,
                                 p_Data  => x_msg_data);
END Update_Drop_Ship_Links;

/*--------------------------------------------------
Function    : Is_Receipt_For_Drop_Ship
Description : This Procedure will called by Inventory.
This will check whether the receipt is for a dropship
order or not.
---------------------------------------------------*/

Function Is_Receipt_For_Drop_Ship
( p_rcv_transaction_id     IN             NUMBER
)RETURN BOOLEAN
IS
l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
l_line_id              NUMBER;
BEGIN

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Entering Is_Receipt_For_Drop_Ship...'||
                                               p_rcv_transaction_id,1);
  END IF;

  SELECT ol.line_id
   INTO  l_line_id
   FROM  oe_order_lines_all  ol,
         oe_drop_ship_sources   od,
         rcv_transactions       rt
   WHERE ol.line_id          = od.line_id
     AND ol.source_type_code = 'EXTERNAL'
     AND od.po_header_id     = rt.po_header_id
     AND od.po_line_id       = rt.po_line_id
     AND od.line_location_id = rt.po_line_location_id
     AND rt.transaction_id   = p_rcv_transaction_id
     AND ROWNUM = 1;

  RETURN TRUE;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Exiting Is_Receipt_For_Drop_Ship...',1);
  END IF;

EXCEPTION
    WHEN NO_DATA_FOUND THEN
       IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('No Data Found in Is_Receipt_For_Drop_Ship...',1);
       END IF;
       RETURN FALSE;
END Is_Receipt_For_Drop_Ship;

/*-----------------------------------------------------
Procedure   : Get_Drop_Ship_Line_ids
Description : This Procedure will be called from PO and
iSupplier and will return header id,line id and release id for
a given po or req. As Line Location id is unique according
to PO the po header join conditions are removed.

Added p_mode to address 3210977 and 3251580.

p_mode :
null : The api returns open unshipped order
       line associated with this po shipment.
1    : The api returns open unshipped order
       line associated with this po shipment.
       If there are no unshipped lines, and there
       is only one closed line, it will return that line.
       If there are more than one shipped lines, it will return
       -99 in the x_line_id parameter.x_header_id, x_org_id
       will have correct value.
2    : This means the requirement is to send the line
       associated with the p_rcv_transaction_id parameter.
       Refer bug 3251580.
-------------------------------------------------------*/
Procedure Get_Drop_Ship_Line_ids
( p_po_header_id        IN              NUMBER
, p_po_line_id          IN              NUMBER
, p_po_line_location_id IN              NUMBER
, p_po_release_id       IN              NUMBER
, p_mode           	IN	        NUMBER := null
, p_rcv_transaction_id  IN              NUMBER := null
, x_num_lines           OUT NOCOPY /* file.sql.39 change */             NUMBER
, x_line_id             OUT     NOCOPY  NUMBER
, x_header_id           OUT     NOCOPY  NUMBER
, x_org_id              OUT     NOCOPY  NUMBER
)

IS
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
BEGIN

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Entering Get_Drop_Ship_Line_ids...' || p_mode,1);
  END IF;

  -- Check for Open Lines and Not Shipped Yet Lines

  IF p_mode is NULL OR
     p_mode = 1 THEN

    BEGIN
      SELECT oel.line_id,
             oel.header_id,
             oel.org_id
      INTO   x_line_id,
             x_header_id,
             x_org_id
      FROM   oe_drop_ship_sources ds,
             oe_order_lines_all oel
      WHERE  line_location_id       = p_po_line_location_id
      AND    oel.line_id            = ds.line_id
      AND    oel.header_id          = ds.header_id
      AND    nvl(oel.open_flag,'Y') = 'Y'
      AND    oel.shipped_quantity is NULL;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN

        IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('no open order line', 5);
        END IF;

        IF p_mode is NULL THEN

          IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('No Data Found first sql', 2);
          END IF;

          x_line_id      := NULL;
          x_header_id    := NULL;
          x_org_id       := NULL;

        ELSE

          BEGIN
            SELECT oel.line_id,
                   oel.header_id,
                   oel.org_id
            INTO   x_line_id,
                   x_header_id,
                   x_org_id
            FROM   oe_drop_ship_sources ds,
                   oe_order_lines_all oel
            WHERE  line_location_id       = p_po_line_location_id
            AND    oel.line_id            = ds.line_id
            AND    oel.header_id          = ds.header_id;

            IF l_debug_level > 0 THEN
              OE_DEBUG_PUB.Add('line found now '|| x_line_id, 2);
            END IF;

          EXCEPTION

            WHEN TOO_MANY_ROWS THEN

              IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('multiple receipts ', 2);
              END IF;
              x_line_id      := -99;

              SELECT oel.header_id,
                     oel.org_id
              INTO   x_header_id,
                     x_org_id
              FROM   oe_drop_ship_sources ds,
                     oe_order_lines_all oel
              WHERE  line_location_id = p_po_line_location_id
              AND    oel.line_id      = ds.line_id
              AND    oel.header_id    = ds.header_id
              AND    rownum           = 1;

            WHEN OTHERS THEN
              IF l_debug_level > 0 THEN
                OE_DEBUG_PUB.Add('sql error * '|| sqlerrm, 2);
              END IF;
              RAISE;
          END;

        END IF; -- if p_mode is null within no_data_found
    END;

  ELSIF p_mode = 2 THEN

    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('rcv txn id '|| p_rcv_transaction_id, 2);
    END IF;

    SELECT MAX(OL.line_id)
    INTO   x_line_id
    FROM   oe_order_lines_all   OL,
           oe_drop_ship_sources OD,
           rcv_transactions     RT
    WHERE  OL.line_id          = OD.line_id
    AND    OL.source_type_code = 'EXTERNAL'
    AND    OD.po_header_id     = RT.po_header_id
    AND    OD.po_line_id       = RT.po_line_id
    AND    OD.line_location_id = RT.po_line_location_id
    AND    RT.transaction_id   = p_rcv_transaction_id
    AND    OL.shipped_quantity is NOT NULL;

    x_header_id    := NULL;
    x_org_id       := NULL;

  END IF; -- if p_mode

  SELECT count(*)
  INTO   x_num_lines
  FROM   oe_drop_ship_sources ds,
         oe_order_lines_all oel
  WHERE  line_location_id  = p_po_line_location_id
  AND    oel.line_id       = ds.line_id
  AND    oel.header_id     = ds.header_id;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Exiting  Get_Drop_Ship_Line_ids...'||x_num_lines,1);
  END IF;

EXCEPTION

  WHEN NO_DATA_FOUND THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('No Data Found in Get_Drop_Ship_Line_ids', 2);
     END IF;
     x_num_lines    := NULL;
     x_line_id      := NULL;
     x_header_id    := NULL;
     x_org_id       := NULL;

WHEN TOO_MANY_ROWS THEN
     IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add('Too Many Rows in Get_Drop_Ship_Line_ids', 2);
     END IF;

     RAISE;

  WHEN OTHERS THEN

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
        'Get_Drop_Ship_Line_ids');
    END IF;

    RAISE;

END Get_Drop_Ship_Line_ids;



/*-----------------------------------------------------
Procedure   :  Get_Order_Line_Status
Description :
This procedure will be used by PO to validate supplier
initiated changes to PO from iSupplier portal.
Enter PO form to validate changes to PO attributes
e.g. need by date
PO receiving API at the time of receipt + delivery.
OM receiving API at the time of drop ship receipt
to fail receipt when order line is fulfilled.
------------------------------------------------------*/

Procedure Get_Order_Line_Status
(p_api_version          IN              NUMBER
,p_po_header_id         IN              NUMBER
,p_po_line_id           IN              NUMBER
,p_po_line_location_id  IN              NUMBER
,p_po_release_id        IN              NUMBER
,p_mode                 IN              NUMBER
,x_updatable_flag       OUT     NOCOPY  VARCHAR2
,x_on_hold              OUT     NOCOPY  VARCHAR2
,x_order_line_status    OUT     NOCOPY  NUMBER
,x_msg_data             OUT     NOCOPY  VARCHAR2
,x_msg_count            OUT     NOCOPY  NUMBER
,x_return_status        OUT     NOCOPY  VARCHAR2
)
IS
 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 l_line_id              NUMBER;
 l_header_id            NUMBER;
 l_org_id               NUMBER;
 l_num_lines            NUMBER;
BEGIN

  x_return_status   :=      FND_API.G_RET_STS_SUCCESS;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Entering Get_Order_Line_Status...',1);
  END IF;

  Get_Drop_Ship_Line_ids
              ( p_po_header_id         =>     p_po_header_id
               ,p_po_line_id           =>     p_po_line_id
               ,p_po_line_location_id  =>     p_po_line_location_id
               ,p_po_release_id        =>     p_po_release_id
               ,x_num_lines            =>     l_num_lines
               ,x_line_id              =>     l_line_id
               ,x_header_id            =>     l_header_id
               ,x_org_id               =>     l_org_id
              );

  IF p_mode =  0 THEN

     IF l_line_id is NOT NULL THEN

        x_updatable_flag :=  'Y';

     ELSE

        x_updatable_flag :=  'N';

     END IF;

  END IF;

  x_on_hold              :=   NULL;
  x_order_line_status    :=   NULL;

  IF l_debug_level > 0 THEN
     OE_DEBUG_PUB.Add('Exiting  Get_Order_Line_Status...',1);
  END IF;

EXCEPTION

   WHEN NO_DATA_FOUND THEN

       IF l_debug_level > 0 THEN
          OE_DEBUG_PUB.Add('No DAta Found in Update_Drop_Ship_Links...',1);
       END IF;

       x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

       ROLLBACK TO Update_Drop_Ship_Links;

  WHEN OTHERS THEN

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg
      (   G_PKG_NAME,
        'Get_Order_Line_Status');
    END IF;

END Get_Order_Line_Status;

/*-----------------------------------------------------
Procedure   :  Get_Order_Line_Info
Description :
This procedure will be used by PO to get addition
so that they can obtain additionla information about
sales order line. This info will be used such taht,

buyers can see the Sales Order Line details in the new
Drop Ship tab that will be added to the Shipments
Block of both the Enter PO Form and Enter Releases Form.


All the data elements necessary for the fulfillment
of a Drop Ship Line will be sent to the end Suppliers.


-------------------------------------------------------*/

PROCEDURE Get_Order_Line_Info
( p_api_version          IN  NUMBER
 ,p_po_header_id         IN  NUMBER
 ,p_po_line_id           IN  NUMBER
 ,p_po_line_location_id  IN  NUMBER
 ,p_po_release_id        IN  NUMBER
 ,p_mode                 IN  NUMBER
 ,x_order_line_info_rec  OUT NOCOPY  Order_Line_Info_Rec_Type
 ,x_msg_data             OUT NOCOPY  VARCHAR2
 ,x_msg_count            OUT NOCOPY  NUMBER
 ,x_return_status        OUT NOCOPY  VARCHAR2)
IS
  l_line_id                NUMBER;
  l_header_id              NUMBER;
  l_org_id                 NUMBER;
  l_num_lines              NUMBER;
  l_ship_to_contact_id     NUMBER;
  l_deliver_to_contact_id  NUMBER;
  l_ship_to_org_id         NUMBER;
  l_deliver_to_org_id      NUMBER;
  l_sold_to_org_id         NUMBER;
  l_inventory_item_id      NUMBER;
  l_ordered_item_id        NUMBER;
  l_item_identifier_type   VARCHAR2(30);-- bug 4148163
  l_ordered_item           VARCHAR2(2000);
  l_orig_user_id           NUMBER;
  l_orig_resp_id           NUMBER;
  l_orig_resp_appl_id      NUMBER;
  l_address1               VARCHAR2(240); -- bug 4148163
  l_address2               VARCHAR2(240);
  l_address3               VARCHAR2(240); -- bug 4148163
  l_address4               VARCHAR2(240); -- bug 4148163
  l_city                   VARCHAR2(60);  -- bug 4148163
  l_state                  VARCHAR2(60);  -- bug 4148163
  l_zip                    VARCHAR2(60);  -- bug 4148163
  l_country                VARCHAR2(60);  -- bug 4148163
  l_shipping_method_code   VARCHAR2(30);
  --l_reset_context     NUMBER := 0; no more required after MOAC
  l_customer_number        VARCHAR2(30);   -- bug 4148163
  l_customer_id            NUMBER;         -- bug 4148163
  l_po_org_id              NUMBER;         -- bug 4148163
  l_temp1                  VARCHAR2(2000); -- bug 4148163
  l_temp2                  VARCHAR2(2000); -- bug 4148163
  -- MOAC
  l_access_mode            VARCHAR2(1);
  l_current_org_id         NUMBER;
  l_reset_policy           BOOLEAN;
  --
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  --
BEGIN
  IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.Add('Entering Get_Order_Line_Info '||p_mode,1);
  END IF;

  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_access_mode := mo_global.Get_access_mode; -- MOAC
  l_current_org_id := mo_global.get_current_org_id();

  Get_Drop_Ship_Line_ids
  ( p_po_header_id         =>  p_po_header_id
   ,p_po_line_id           =>  p_po_line_id
   ,p_po_line_location_id  =>  p_po_line_location_id
   ,p_po_release_id        =>  p_po_release_id
   ,p_mode                 =>  1
   ,x_num_lines            =>  l_num_lines
   ,x_line_id              =>  l_line_id
   ,x_header_id            =>  l_header_id
   ,x_org_id               =>  l_org_id);

  IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.Add('line_id '|| l_line_id || 'om org ' || l_org_id,3);
  END IF;

  IF l_line_id is NULL THEN
    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add
     ('no line for this po_location_id '|| p_po_line_location_id,3);
    END IF;
    RAISE FND_API.G_EXC_ERROR;
  END IF;

  SELECT org_id
  INTO   l_po_org_id  -- l_num_lines 4148163
  FROM   po_line_locations_all
  WHERE  line_location_id = p_po_line_location_id;

  IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.Add(' po org  '|| l_po_org_id, 5);
  END IF;

  IF  l_po_org_id <> l_org_id THEN
  -- MOAC
    Mo_Global.Set_Policy_Context (p_access_mode =>'S', p_org_id => l_org_id);
    l_reset_policy := TRUE;
  ELSE
    IF nvl(l_current_org_id,-99) <> l_org_id THEN
      Mo_Global.Set_Policy_Context (p_access_mode => 'S', p_org_id => l_org_id);
      l_reset_policy := TRUE;
    END IF;
  END IF;

   /* Commented for MOAC R12 project
    OE_ORDER_CONTEXT_GRP.Set_Created_By_Context
    ( p_header_id          =>  NULL
     ,p_line_id            =>  l_line_id
     ,x_orig_user_id       =>  l_orig_user_id
     ,x_orig_resp_id       =>  l_orig_resp_id
     ,x_orig_resp_appl_id  =>  l_orig_resp_appl_id
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data );

    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('context switched ' || x_return_status,3);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;

   IF  NVL(to_number(FND_GLOBAL.USER_ID),-1) = -1 OR
       NVL(to_number(FND_GLOBAL.RESP_ID),-1) = -1 OR
       NVL(to_number(FND_GLOBAL.RESP_APPL_ID),-1) =  -1 THEN

    OE_ORDER_CONTEXT_GRP.Set_Created_By_Context
    ( p_header_id          =>  NULL
     ,p_line_id            =>  l_line_id
     ,x_orig_user_id       =>  l_orig_user_id
     ,x_orig_resp_id       =>  l_orig_resp_id
     ,x_orig_resp_appl_id  =>  l_orig_resp_appl_id
     ,x_return_status      =>  x_return_status
     ,x_msg_count          =>  x_msg_count
     ,x_msg_data           =>  x_msg_data );

    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('context switched for no context' || x_return_status,3);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    l_reset_context := 1;

  END IF; */

  SELECT order_number
  INTO   x_order_line_info_rec.sales_order_number
  FROM   oe_order_headers_all --oe_order_headers --Changes for BUG#6032405
  WHERE  header_id = l_header_id;

  IF l_line_id = -99 THEN

    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add
      ('order number '|| x_order_line_info_rec.sales_order_number,3);
    END IF;
    RETURN;

  ELSE

    SELECT ship_to_contact_id,
           deliver_to_contact_id,
           ship_to_org_id,
           deliver_to_org_id,
           sold_to_org_id,
           shipping_method_code,
           shipping_instructions,
           packing_instructions,
           inventory_item_id,
           item_identifier_type,
           ordered_item,
           user_item_description,
           cust_po_number,
           customer_line_number,
           customer_shipment_number,
           DECODE(p_mode, 0, null, RTRIM(line_number || '.'
           || shipment_number || '.'
           || option_number || '.'
           || component_number || '.'
           || service_number, '.')),
           DECODE(p_mode, 0, null, ordered_quantity),
           DECODE(p_mode, 0, null, shipped_quantity),
           DECODE(p_mode, 0, null, ordered_quantity2), -- INVCONV
           DECODE(p_mode, 0, null, shipped_quantity2), -- INVCONV
           DECODE(p_mode, 0, null, oelup.meaning)
    INTO   l_ship_to_contact_id,
           l_deliver_to_contact_id,
           l_ship_to_org_id,
           l_deliver_to_org_id,
           l_sold_to_org_id,
           l_shipping_method_code,
           x_order_line_info_rec.shipping_instructions,
           x_order_line_info_rec.packing_instructions,
           l_inventory_item_id,
           l_item_identifier_type,
           l_ordered_item,
           x_order_line_info_rec.customer_product_description,
           x_order_line_info_rec.customer_po_number,
           x_order_line_info_rec.customer_po_line_number,
           x_order_line_info_rec.customer_po_shipment_number,
           x_order_line_info_rec.sales_order_line_number,
           x_order_line_info_rec.sales_order_line_ordered_qty,
           x_order_line_info_rec.sales_order_line_shipped_qty,
           x_order_line_info_rec.sales_order_line_ordered_qty2, -- INVCONV
           x_order_line_info_rec.sales_order_line_shipped_qty2, -- INVCONV

           x_order_line_info_rec.sales_order_line_status
    FROM   oe_order_lines_all oel, --oe_order_lines oel,   -- Changes for BUG#6032405
           oe_lookups oelup
    WHERE  line_id = l_line_id
    AND    oelup.lookup_code = oel.flow_status_code
    AND    oelup.lookup_type = 'LINE_FLOW_STATUS';

    IF l_debug_level > 0 THEN
      oe_debug_pub.add('from oe_order_lines '
      || x_order_line_info_rec.customer_product_description
      || l_shipping_method_code, 3);
    END IF;

    IF p_mode = 0 THEN -- do we need this??
      x_order_line_info_rec.sales_order_number := null;
    END IF;

  END IF;

  IF l_ship_to_org_id is NOT NULL THEN
    OE_Header_Util.Get_Customer_Details
    ( p_org_id           => l_ship_to_org_id
     ,p_site_use_code    => 'SHIP_TO'
     ,x_customer_name    => x_order_line_info_rec.ship_to_customer_name
     ,x_customer_number  => l_customer_number -- bug 4148163
     ,x_customer_id      => l_customer_id     -- bug 4148163
     ,x_location         => x_order_line_info_rec.ship_to_customer_location
     ,x_address1         => l_address1
     ,x_address2         => l_address2
     ,x_address3         => l_address3
     ,x_address4         => l_address4
     ,x_city             => l_city
     ,x_state            => l_state
     ,x_zip              => l_zip
     ,x_country          => l_country);

    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add
      ('got ship to ct name and location: '
        || x_order_line_info_rec.ship_to_customer_name || '-'
        || x_order_line_info_rec.ship_to_customer_location,5);
    END IF;
  END IF;

  IF l_ship_to_contact_id is NOT NULL THEN
    x_order_line_info_rec.ship_to_contact_name :=
    OE_Id_To_Value.Ship_To_Contact
    (p_ship_to_contact_id => l_ship_to_contact_id);
  END IF;


  IF  p_mode = 1 OR
      p_mode = 2 THEN
    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add
      ('sales order info: '
        || x_order_line_info_rec.sales_order_line_number || '-'
        || x_order_line_info_rec.sales_order_line_ordered_qty || '-'
        || x_order_line_info_rec.sales_order_line_shipped_qty || '-'
        || x_order_line_info_rec.sales_order_line_status || '-'
        || x_order_line_info_rec.sales_order_number,5);
    END IF;
  END IF;

  IF p_mode = 0 OR
     p_mode = 2 THEN

    IF l_ship_to_contact_id is NOT NULL THEN

      OE_Id_To_Value.Get_Contact_Details
      ( p_contact_id          => l_ship_to_contact_id
       ,x_contact_name        => l_temp1   -- l_address1 bug 4148163
       ,x_phone_line_type     => x_order_line_info_rec.ship_to_contact_fax
       ,x_phone_number        => x_order_line_info_rec.ship_to_contact_phone
       ,x_email_address       => x_order_line_info_rec.ship_to_contact_email);

      IF x_order_line_info_rec.ship_to_contact_fax = 'FAX' THEN
        x_order_line_info_rec.ship_to_contact_fax
            := x_order_line_info_rec.ship_to_contact_phone;
        x_order_line_info_rec.ship_to_contact_phone := null;
      END IF;

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add
        ('got ship to contact details: '
          || x_order_line_info_rec.ship_to_contact_name || '-'
          || x_order_line_info_rec.ship_to_contact_fax || '-'
          || x_order_line_info_rec.ship_to_contact_phone || '-'
          || x_order_line_info_rec.ship_to_contact_email,5);
      END IF;
    END IF;

    IF l_deliver_to_org_id is NOT NULL THEN
      OE_Header_Util.Get_Customer_Details
      ( p_org_id           => l_deliver_to_org_id
       ,p_site_use_code    => 'DELIVER_TO'
       ,x_customer_name    => x_order_line_info_rec.deliver_to_customer_name
       ,x_customer_number  => l_customer_number -- bug 4148163
       ,x_customer_id      => l_customer_id     -- bug 4148163
       ,x_location         => x_order_line_info_rec.deliver_to_customer_location
       ,x_address1         => l_address1
       ,x_address2         => l_address2
       ,x_address3         => l_address3
       ,x_address4         => l_address4
       ,x_city             => l_city
       ,x_state            => l_state
       ,x_zip              => l_zip
       ,x_country          => l_country);

      x_order_line_info_rec.deliver_to_customer_address :=
        l_address1 ||'@!!'|| l_address2 ||'@!!'|| l_address3 ||'@!!'||
        l_address4 ||'@!!'||
        l_city ||'@!!'|| l_state ||'@!!'|| l_zip ||'@!!'|| l_country;

      x_order_line_info_rec.deliver_to_customer_address1 := l_address1;
      x_order_line_info_rec.deliver_to_customer_address2 := l_address2;
      x_order_line_info_rec.deliver_to_customer_address3 := l_address3;
      x_order_line_info_rec.deliver_to_customer_address4 := l_address4;
      x_order_line_info_rec.deliver_to_customer_city     := l_city;
      x_order_line_info_rec.deliver_to_customer_state    := l_state;
      x_order_line_info_rec.deliver_to_customer_zip      := l_zip;
      x_order_line_info_rec.deliver_to_customer_country  := l_country;

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add
        ('got deliver to ct details: '
          || x_order_line_info_rec.deliver_to_customer_name || '-'
          || x_order_line_info_rec.deliver_to_customer_location || '-'
          || x_order_line_info_rec.deliver_to_customer_address || '-', 5);

      END IF;
    END IF;

    IF l_deliver_to_contact_id is NOT NULL THEN
      x_order_line_info_rec.deliver_to_contact_name :=
        OE_Id_To_Value.Deliver_To_Contact
        (p_deliver_to_contact_id => l_deliver_to_contact_id);

      OE_Id_To_Value.Get_Contact_Details
      ( p_contact_id          => l_deliver_to_contact_id
       ,x_contact_name        => l_temp1   -- bug 4148163
       ,x_phone_line_type     => x_order_line_info_rec.deliver_to_contact_fax
       ,x_phone_number        => x_order_line_info_rec.deliver_to_contact_phone
       ,x_email_address       => x_order_line_info_rec.deliver_to_contact_email);

      IF x_order_line_info_rec.deliver_to_contact_fax = 'FAX' THEN
        x_order_line_info_rec.deliver_to_contact_fax
            := x_order_line_info_rec.deliver_to_contact_phone;
        x_order_line_info_rec.deliver_to_contact_phone := null;
      END IF;

      IF l_debug_level > 0 THEN
        OE_DEBUG_PUB.Add
        ('got deliver to contact details: '
          || x_order_line_info_rec.deliver_to_contact_name || '-'
          || x_order_line_info_rec.deliver_to_contact_fax || '-'
          || x_order_line_info_rec.deliver_to_contact_phone || '-'
          || x_order_line_info_rec.deliver_to_contact_email,5);
      END IF;
    END IF;

    IF x_order_line_info_rec.customer_product_description is NULL THEN
      OE_Line_Util.Get_Item_Info
      ( p_item_identifier_type  => l_item_identifier_type
       ,p_inventory_item_id     => l_inventory_item_id
       ,p_ordered_item_id       => l_ordered_item_id
       ,p_sold_to_org_id        => l_sold_to_org_id
       ,p_ordered_item          => l_ordered_item
       ,x_ordered_item          => l_temp1    -- bug 4148163
       ,x_ordered_item_desc => x_order_line_info_rec.customer_product_description
       ,x_inventory_item        => l_temp2    -- bug 4148163
       ,x_return_status         => x_return_status
       ,x_msg_count             => x_msg_count
       ,x_msg_data              => x_msg_data);
    END IF;

    IF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    ELSIF x_return_status = FND_API.G_RET_STS_ERROR THEN
      RAISE FND_API.G_EXC_ERROR;
    END IF;

    IF l_shipping_method_code is NOT NULL THEN
      oe_debug_pub.add('here'|| l_shipping_method_code, 1);

      SELECT ship_method_meaning
      INTO   x_order_line_info_rec.shipping_method
      FROM   wsh_carrier_services wshca
      WHERE  SHIP_METHOD_CODE = l_shipping_method_code;

    END IF;

    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add
      ('got ct product and ship method: '
        || x_order_line_info_rec.customer_product_description || '-'
        || x_order_line_info_rec.shipping_method, 5);
    END IF;
  END IF; -- p_mode = 0 or 2

  IF l_reset_policy THEN -- MOAC
    Mo_Global.Set_Policy_Context (p_access_mode => l_access_mode,  p_org_id => l_current_org_id);
  END IF;
  /* commented for MOAC
  IF  l_po_org_id <> l_org_id OR
      l_reset_context = 1 THEN

    FND_GLOBAL.Apps_Initialize
    ( user_id      => l_orig_user_id
     ,resp_id      => l_orig_resp_id
     ,resp_appl_id => l_orig_resp_appl_id);

    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('context reset tp po org: ' ||  l_po_org_id,3);
    END IF;

    l_reset_context := 0;

  END IF;  */

  IF l_debug_level > 0 THEN
    OE_DEBUG_PUB.Add('Leaving Get_Order_Line_Info',1);
  END IF;

EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_return_status := FND_API.G_RET_STS_ERROR;

    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('error in Get_Order_Line_Info '||sqlerrm,1);
    END IF;

  WHEN others THEN

    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

    IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('error in Get_Order_Line_Info '||sqlerrm,1);
    END IF;

    IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      OE_MSG_PUB.Add_Exc_Msg(G_PKG_Name, 'Get_Order_Line_Info');
    END IF;

    OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
                              P_Data  => x_msg_Data);
END Get_Order_Line_Info;


/*-----------------------------------------------------
Procedure   :  Purge_Drop_Ship_PO_Links
Description :
This procedure will be used by PO at the time of
PO purge. OM will validate the order line status
and then null out the PO links from the
oe_drop_ship_sources table.
-------------------------------------------------------*/
Procedure Purge_Drop_Ship_PO_Links
( p_api_version          IN             NUMBER
 ,p_init_msg_list        IN             VARCHAR2
 ,p_commit               IN             VARCHAR2
 ,p_entity               IN             VARCHAR2
 ,p_entity_id_tbl        IN             PO_ENTITY_ID_TBL_TYPE
 ,x_msg_count            OUT    NOCOPY  NUMBER
 ,x_msg_data             OUT    NOCOPY  VARCHAR2
 ,x_return_status        OUT    NOCOPY  VARCHAR2
)
IS

 CURSOR c_dropship(cp_entity_id NUMBER) IS
 SELECT line_id
   FROM oe_drop_ship_sources
  WHERE (p_entity = 'PO_REQUISITION_HEADERS' AND
            requisition_header_id = cp_entity_id) OR
         (p_entity = 'PO_HEADERS' AND
             po_header_id = cp_entity_id)
  FOR UPDATE NOWAIT;

 l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
 I                      NUMBER := 1;
 l_line_id              NUMBER;

BEGIN

  IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Entering Purge_Drop_Ship_PO_Links...',1);
  END IF;

  x_return_status :=  FND_API.G_RET_STS_SUCCESS;

  FOR I in 1..p_entity_id_tbl.COUNT LOOP

      IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('Entity:'||p_entity,1);
         OE_DEBUG_PUB.Add('Entity ID :'||p_entity_id_tbl(I),1);
      END IF;

      IF p_entity = 'PO_REQUISITION_HEADERS' OR
                               p_entity = 'PO_HEADERS' THEN

         OPEN  c_dropship(p_entity_id_tbl(I));
         FETCH c_dropship INTO l_line_id;

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('After Locking : '||l_line_id, 2);
         END IF;
         CLOSE c_dropship;

         DELETE
         FROM oe_drop_ship_sources
         WHERE (p_entity = 'PO_REQUISITION_HEADERS' AND
                     requisition_header_id = p_entity_id_tbl(I)) OR
                (p_entity = 'PO_HEADERS' AND
                     po_header_id = p_entity_id_tbl(I));

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('After Deleting: '||l_line_id, 2);
         END IF;

      END IF;

   END LOOP;

   IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Exiting Purge_Drop_Ship_PO_Links...',1);
   END IF;


EXCEPTION

    WHEN OTHERS THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('UnExp Error in Purge_Drop_Ship_PO_Links...'||sqlerrm,4);
         END IF;

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
         OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Purge_Drop_Ship_PO_Links'
            );
         END IF;

         OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
                                   P_Data  => x_msg_Data);
END Purge_Drop_Ship_PO_Links;

/*-----------------------------------------------------
Procedure   : Purge_Drop_Ship_PO_Validation
Description :
This procedure will be used by PO at the time of
PO purge. OM will return validation status of each
document passed whether it can be purged or not. The
values will be Y or N. PO will pass entity as REQ or PO
and a table of entity id's
-------------------------------------------------------*/
Procedure Purge_Drop_Ship_PO_Validation
( p_api_version          IN             NUMBER
 ,p_init_msg_list        IN             VARCHAR2
 ,p_commit               IN             VARCHAR2
 ,p_entity               IN             VARCHAR2
 ,p_entity_id_tbl        IN             PO_ENTITY_ID_TBL_TYPE
 ,x_purge_allowed_tbl    OUT    NOCOPY  VAL_STATUS_TBL_TYPE
 ,x_msg_count            OUT    NOCOPY  NUMBER
 ,x_msg_data             OUT    NOCOPY  VARCHAR2
 ,x_return_status        OUT    NOCOPY  VARCHAR2
)
IS
  l_debug_level CONSTANT NUMBER := oe_debug_pub.g_debug_level;
  I                      NUMBER := 1;
  l_count                NUMBER := 0;

BEGIN

  IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Entering Purge_Drop_Ship_PO_Validation...',1);
  END IF;

  x_return_status       :=  FND_API.G_RET_STS_SUCCESS;
  x_purge_allowed_tbl   :=  VAL_STATUS_TBL_TYPE();

  x_purge_allowed_tbl.extend(p_entity_id_tbl.COUNT);

  FOR I in 1..p_entity_id_tbl.COUNT LOOP

      IF l_debug_level > 0 THEN
         OE_DEBUG_PUB.Add('Entity:'||p_entity,1);
         OE_DEBUG_PUB.Add('Entity ID :'||p_entity_id_tbl(I),1);
      END IF;

      IF p_entity = 'PO_REQUISITION_HEADERS' OR
                           p_entity = 'PO_HEADERS' THEN
           -- fix for performance bug 3631271 begins
           IF p_entity = 'PO_REQUSITION_HEADERS'
           THEN
              SELECT count(*)
                INTO l_count
                FROM oe_drop_ship_sources ds,
                     oe_order_lines_all l
               WHERE requisition_header_id = p_entity_id_tbl(I)
                 AND l.line_id        = ds.line_id
                 AND l.header_id      = ds.header_id
                 AND nvl(l.open_flag,'Y') = 'Y'
                 AND l.shipped_quantity is NULL;
           ELSE
              SELECT count(*)
                INTO l_count
                FROM oe_drop_ship_sources ds,
                     oe_order_lines_all l
               WHERE po_header_id = p_entity_id_tbl(I)
                 AND l.line_id        = ds.line_id
                 AND l.header_id      = ds.header_id
                 AND nvl(l.open_flag,'Y') = 'Y'
                 AND l.shipped_quantity is NULL;
           END IF;
           -- fix for performance bug 3631271 ends

            IF l_count > 0 THEN

               IF l_debug_level > 0 THEN
                  OE_DEBUG_PUB.Add('Line is Open :'||l_count);
               END IF;

               x_purge_allowed_tbl(I) := 'N';

            ELSE
               IF l_debug_level > 0 THEN
                  OE_DEBUG_PUB.Add('Line is Closed:'||l_count);
               END IF;

               x_purge_allowed_tbl(I) := 'Y';

            END IF;

     END IF;

  END LOOP;

  IF l_debug_level > 0 THEN
      OE_DEBUG_PUB.Add('Purge Table Count...'||x_purge_allowed_tbl.COUNT,1);
      OE_DEBUG_PUB.Add('Exiting Purge_Drop_Ship_PO_Validation...',1);
  END IF;

EXCEPTION

    WHEN OTHERS THEN

         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;

         IF l_debug_level > 0 THEN
            OE_DEBUG_PUB.Add('UnExp Error in Purge_Drop_Ship_PO_Validation...'||sqlerrm,4);
         END IF;

         IF OE_MSG_PUB.Check_Msg_Level(OE_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
         THEN
         OE_MSG_PUB.Add_Exc_Msg
           (G_PKG_NAME
            ,'Purge_Drop_Ship_PO_Validation'
            );
         END IF;

         OE_MSG_PUB.Count_And_Get (P_Count => x_msg_Count,
                                   P_Data  => x_msg_Data);

END Purge_Drop_Ship_PO_Validation;

END OE_DROP_SHIP_GRP;

/
