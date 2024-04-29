--------------------------------------------------------
--  DDL for Package GHR_WF_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_WF_PKG" AUTHID CURRENT_USER AS
/* $Header: ghwfpkg.pkh 120.0.12010000.2 2008/08/05 15:13:38 ubhat ship $ */
--
--
--
	procedure StartSF52Process(	p_pa_request_id in number,
						p_forward_to_name in varchar2,
				            p_error_msg in varchar2 default null
					  );
--
	procedure CompleteBlockingOfPArequest ( p_pa_request_id in Number,
    						          p_error_msg in varchar2 default null);
--
--
procedure CompleteBlockingOfFutureAction ( p_pa_request_id in Number,
						       p_action_taken in varchar2,
						       p_error_msg in varchar2 default null
							);
--
--
	procedure UpdateFinalFYIWFUsers(
					   itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2);
--
--
--
	procedure CheckIFSameFYIUsers(
					   itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2);
--
--
--
	procedure UpdateRHistoryProcess(
					   itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2);
--
--
	procedure FindDestination(
					itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out  nocopy varchar2 );
	procedure GetDestinationDetails (
					  p_pa_request_id  in NUMBER,
					  p_action_taken OUT nocopy varchar2,
                                p_user_name OUT nocopy varchar2,
					  p_groupbox_name OUT  nocopy varchar2
						  );
--
--
     function CheckItemAttribute
                ( p_name in   wf_item_attribute_values.name%TYPE,
                  p_itemtype  in varchar2,
  		      p_itemkey  	in varchar2
                )  return boolean;
--
--
	procedure SetDestinationDetails (
					  p_pa_request_id  in NUMBER,
					  p_subject OUT nocopy varchar2,
					  p_line1 OUT nocopy varchar2,
					  p_line2 OUT nocopy varchar2,
					  p_line3 OUT nocopy varchar2,
					  p_line4 OUT nocopy varchar2,
					  p_line5 OUT nocopy varchar2,
					  p_line6 OUT nocopy varchar2,
					  p_line7 OUT nocopy varchar2,
					  p_line8 OUT nocopy varchar2,
					  p_line9 OUT nocopy varchar2
					  );
--
PROCEDURE CheckIfPARWfEnd ( itemtype in varchar2,
				  itemkey  	 in varchar2,
				  actid	 in number,
				  funcmode	 in varchar2,
				  result	 in out nocopy varchar2);
--
procedure VerifyIfNtfyUpdHRUsr( itemtype        in varchar2,
                                itemkey         in varchar2,
                                actid           in number,
                                funcmode        in varchar2,
                                result  in out nocopy varchar2 );
--
procedure CheckIfNtfyUpdHRUsr(	itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	in out nocopy varchar2);
--
	procedure EndSF52Process(	itemtype	in varchar2,
				itemkey  	in varchar2,
				actid		in number,
				funcmode		in varchar2,
				result		in out nocopy varchar2	) ;

	procedure norout(
					   itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in out nocopy varchar2);
--
end ghr_wf_pkg;

/
