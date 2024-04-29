--------------------------------------------------------
--  DDL for Package OE_PO_CALLBACK_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."OE_PO_CALLBACK_UTIL" AUTHID CURRENT_USER As
/* $Header: OEXDPOCS.pls 115.0 99/07/26 11:07:30 porting shi $ */

Procedure Update_Req_Info(P_API_Version              In  Number,
                          P_Return_Status            Out Varchar2,
                          P_Msg_Count                Out Number,
                          P_MSG_Data                 Out Varchar2,
                          P_Interface_Source_Code    In  Varchar2,
                          P_Interface_Source_Line_ID In  Number,
                          P_Requisition_Header_ID    In  Number,
                          P_Requisition_Line_ID      In  Number);

Procedure Insert_SO_Drop_Ship_Sources
( P_Drop_Ship_Source_ID         In Number
, P_Header_ID                   In Number
, P_Line_ID                     In Number
, P_Org_ID                      In Number
, P_Destination_Organization_ID In Number
, P_Requisition_Header_ID       In Number
, P_Requisition_Line_ID         In Number
, P_PO_Header_ID                In Number
, P_PO_Line_ID                  In Number
, P_Line_Location_ID            In Number
, P_PO_Release_ID               In Number Default Null);

-- Update_All_Reqs_In_Process is an OE procedure that is called by
-- Oracle Purchasing to update requisition information for a drop shipped line.
-- This procedure is called in the Requisition Import (ReqImport) process of
-- Oracle Purchasing.

Procedure Update_All_Reqs_In_Process
( P_API_Version              In  Number
, P_Return_Status            Out Varchar2
, P_Msg_Count                Out Number
, P_MSG_Data                 Out Varchar2
, P_Requisition_Header_ID    In Number
, P_Request_Id               In Number
, P_Process_Flag             In Varchar2);

-- Update_PO_Info is an OE procedure that is called by Oracle Purchasing to
-- update purchase order information for a drop shipped line. This procedure
-- is called in the Auto create process of Oracle Purchasing

Procedure Update_PO_Info
( P_API_Version          In  Number
, P_Return_Status        Out Varchar2
, P_Msg_Count            Out Number
, P_MSG_Data             Out Varchar2
, P_Req_Header_ID        In  Number
, P_Req_Line_ID          In  Number
, P_PO_Header_Id         In  Number
, P_PO_Line_Id           In  Number
, P_Line_Location_ID     In  Number
, P_PO_Release_ID        In  Number Default Null);

Function Valid_Drop_Ship_Source_ID
(P_Drop_Ship_Source_ID In Number)
Return Boolean;

Function Req_Line_Is_Drop_Ship
(P_Req_Line_Id              In  Number)
Return Number;

Function PO_Line_Location_Is_Drop_Ship
(P_PO_Line_Location_Id In  Number)
Return Number;

End OE_PO_CALLBACK_UTIL;

 

/
