--------------------------------------------------------
--  DDL for Package WSH_WF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WSH_WF" AUTHID CURRENT_USER as
/* $Header: WSHUTWFS.pls 115.2 2002/11/12 02:04:16 nparikh ship $ */

--
--Procedure:
--Parameters:
--Description:
--

PROCEDURE Start_Process(
		 p_source_header_id  in number,
		 p_source_code       in varchar2,
		 p_order_number      in number,
		 p_contact_type      in varchar2,
		 p_contact_name      in varchar2,
		 p_contact_id        in number,
		 p_contact_last_name in varchar2,
		 p_shipped_lines     in varchar2,
		 p_backordered_lines in varchar2,
		 p_ship_notif_date   in date,
		 p_bo_notif_date     in date,
		 p_workflow_process  in varchar2 default null,
		 p_item_type         in varchar2 default null) ;

PROCEDURE Order_Status(
           itemtype  in varchar2,
           itemkey   in varchar2,
           actid     in number,
           funcmode  in varchar2,
           resultout in out NOCOPY  varchar2);

PROCEDURE Shipped_Lines(
           document_id  in varchar2,
           display_type  in varchar2,
           document      in out NOCOPY  varchar2,
           document_type in out NOCOPY  varchar2);

PROCEDURE Backordered_Lines(
           document_id  in varchar2,
           display_type  in varchar2,
           document      in out NOCOPY  varchar2,
           document_type in out NOCOPY  varchar2);

PROCEDURE Order_fulfilled(
           itemtype  in varchar2,
           itemkey   in varchar2,
           actid     in number,
           funcmode  in varchar2,
           resultout in out NOCOPY  varchar2);

PROCEDURE Update_Workflow(
		 p_delivery_id in number);

PROCEDURE Check_Item_Instance(
		 p_source_header_id in number,
		 p_source_code      in varchar2,
		 p_contact_name     in varchar2,
		 p_result           out NOCOPY  boolean);

PROCEDURE Start_Workflow(
		 p_source_header_id in number,
		 p_source_code      in varchar2,
		 p_order_number     in number,
		 p_contact_type     in varchar2,
		 p_contact_id       in number,
		 p_result           out NOCOPY  BOOLEAN);

PROCEDURE Get_Wf_User(
		 p_contact_type in  varchar2,
           p_contact_id   in  number,
		 p_wf_contact_last_name out NOCOPY  varchar2,
           p_wf_contact_name   out NOCOPY  varchar2);

END WSH_WF;

 

/
