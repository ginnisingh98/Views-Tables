--------------------------------------------------------
--  DDL for Package WIP_EAM_WRAPPROVAL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WIP_EAM_WRAPPROVAL_PVT" AUTHID CURRENT_USER AS
/*$Header: WIPVWRAS.pls 120.1 2005/06/15 17:10:31 appldev  $ */

PROCEDURE StartWRAProcess ( p_work_request_id   	in number,
                           p_asset_number       	in varchar2,
                           p_asset_group        	in number,
                           p_asset_location     	in number,
                           p_organization_id    	in number,
                           p_work_request_status_id     in number,
                           p_work_request_priority_id   in number,
                           p_work_request_owning_dept_id in number,
                           p_expected_resolution_date   in date,
                           p_work_request_type_id       in number,
                           p_maintenance_object_type	in number default 3,
                           p_maintenance_object_id	in number default null,
                           p_notes              	in varchar2,
                           p_notify_originator		in number default null,
                           p_resultout    		OUT NOCOPY varchar2,
                           p_error_message              OUT NOCOPY varchar2
                           ) ;


PROCEDURE Update_Status_Await_Wo( itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout out NOCOPY varchar2);

PROCEDURE Update_Status_Rejected( itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout out NOCOPY varchar2);

PROCEDURE Update_Status_Add( itemtype  in varchar2,
                      itemkey   in varchar2,
                      actid     in number,
                      funcmode  in varchar2,
                      resultout out NOCOPY varchar2) ;

procedure CHECK_NOTIFY_ORIGINATOR(
    itemtype  in varchar2,
    itemkey   in varchar2,
    actid     in number,
    funcmode  in varchar2,
    resultout in out NOCOPY varchar2);

procedure set_employee_name ( itemtype  in varchar2,
		      itemkey   in varchar2,
		      actid     in number,
		      funcmode  in varchar2,
		      p_user_name in varchar2);

END WIP_EAM_WRAPPROVAL_PVT ;

 

/
