--------------------------------------------------------
--  DDL for Package GHR_WF_WGI_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_WF_WGI_PKG" AUTHID CURRENT_USER AS
/* $Header: ghwfwgi.pkh 120.1 2005/07/01 12:44:24 vnarasim noship $ */
--
--
PROCEDURE StartWGIProcess
	(	p_pa_request_id	in number,
		p_full_name		in varchar2);
--
--
procedure FindDestination( itemtype		in varchar2
				  ,itemkey  	in varchar2
				  ,actid		in number
				  ,funcmode		in varchar2
				  ,result		in out nocopy  varchar2);
--
--
--
PROCEDURE GetRoutingGroupDetails (
					  p_groupbox_name		IN  varchar2,
					  p_groupbox_id		out nocopy  number,
					  p_routing_group_id	out nocopy  number,
					  p_groupbox_desc 	out nocopy  varchar2,
                                p_routing_group_name	out nocopy  varchar2,
                                p_routing_group_desc	out nocopy  varchar2
					  ) ;
--
--
function get_next_approver  ( p_person_id in per_people_f.person_id%type
		                  ,p_effective_date in ghr_pa_requests.effective_date%TYPE
					)
					return ghr_pa_routing_history.user_name%TYPE;
--
--
PROCEDURE Get_emp_personnel_groupbox ( p_position_id         IN number
						  ,p_effective_date      IN date
                               	  ,p_groupbox_name       out nocopy  varchar2
						  ,p_personnel_office_id out nocopy  ghr_pa_requests.personnel_office_id%TYPE
                                      ,p_gbx_user_id         out nocopy  ghr_pois.person_id%TYPE
						 );
--
--
PROCEDURE Get_par_details ( p_pa_request_id in number
				   ,p_person_id out nocopy  number
				   ,p_effective_date out nocopy  date
				   ,p_position_id out nocopy  number);
--
--
PROCEDURE PersonnelGrpBoxExists(	itemtype	in varchar2,
						itemkey  	in varchar2,
						actid		in number,
						funcmode	in varchar2,
						result	in out nocopy  varchar2
						);
--
--
Procedure CancelSF52Process(	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy  varchar2
					);
--
--
Procedure StartSF52Process(	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy  varchar2
					);
--
--
Function VerifyValidWFUser	(p_user_name	in	varchar2)
					return boolean;
--
--
PROCEDURE SetDestination(	 p_request_id		in	varchar2
					,p_person_id		in	varchar2
					,p_position_id		in	varchar2
					,p_effective_date 	in	date
					,p_office_symbol_name	out nocopy 	varchar2
					,p_line1			out nocopy    varchar2
					,p_line2			out nocopy    varchar2
					,p_line3			out nocopy    varchar2
					,p_line4			out nocopy    varchar2
					,p_line5			out nocopy    varchar2
					,p_line6			out nocopy    varchar2
					,p_line7			out nocopy    varchar2
                              ,p_routing_group        out nocopy    varchar2
                      	);
--
--
PROCEDURE UpdateRoutingHistory( itemtype	in varchar2,
					  itemkey  	in varchar2,
					  actid	in number,
					  funcmode	in varchar2,
					  result	in out nocopy  varchar2);
--
--
procedure approval_required( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy  varchar2	);
--
--
PROCEDURE CallUpdateToHR( itemtype	in varchar2,
				  itemkey  	in varchar2,
				  actid	in number,
				  funcmode	in varchar2,
				  result	in out nocopy  varchar2);
--
--
PROCEDURE EndWGIProcess(  itemtype	in varchar2
				 ,itemkey  	in varchar2
				 ,actid	in number
				 ,funcmode	in varchar2
				 ,result	in out nocopy  varchar2);
--
--
procedure update_sf52_action_taken(p_pa_request_id	in  ghr_pa_requests.pa_request_id%TYPE
					    ,p_routing_group_id in  ghr_pa_requests.routing_group_id%type
					    ,p_groupbox_id	in  ghr_pa_routing_history.groupbox_id%type
					    ,p_action_taken	in  ghr_pa_routing_history.action_taken%TYPE
                                  ,p_gbx_user_id      in ghr_pois.person_id%TYPE);
--
--
procedure perofc_approval_required ( 	itemtype	in varchar2,
							itemkey  	in varchar2,
							actid		in number,
							funcmode	in varchar2,
							result	in out nocopy  varchar2	);
--
--
procedure use_perofc_only ( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy  varchar2	);
--
--
procedure FindDestPerOfficeGbx( 	itemtype	in varchar2,
						itemkey  	in varchar2,
						actid		in number,
						funcmode	in varchar2,
						result	in out nocopy  varchar2	);
--
--
procedure update_sf52_for_wgi_denial ( itemtype	in varchar2,
						  itemkey  	in varchar2,
						  actid	in number,
						  funcmode	in varchar2,
						  result	in out nocopy  varchar2);
--
--
procedure CheckNtfyPOI ( 	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy  varchar2);
--
--
procedure populate_shadow		( itemtype	in varchar2,
						  itemkey  	in varchar2,
						  actid	in number,
						  funcmode	in varchar2,
						  result	in out nocopy  varchar2);
--
--
end ghr_wf_wgi_pkg;

 

/
