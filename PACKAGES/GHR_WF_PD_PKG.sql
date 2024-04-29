--------------------------------------------------------
--  DDL for Package GHR_WF_PD_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."GHR_WF_PD_PKG" AUTHID CURRENT_USER AS
/* $Header: ghwfpd.pkh 115.4 2003/12/19 05:24:32 vnarasim ship $ */
--
--
--
	procedure StartPDProcess
			(
			  p_position_description_id in number,
                    p_item_key in varchar2,
		 	  p_forward_to_name in varchar2
			 );
--
--
PROCEDURE UpdateRHistoryProcess(           itemtype	in varchar2,
					   itemkey      in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in OUT NOCOPY varchar2);
--
--
procedure FindDestination( 	        itemtype	in varchar2,
					itemkey  	in varchar2,
					actid		in number,
					funcmode	in varchar2,
					result	        in OUT NOCOPY varchar2);
--
--
PROCEDURE GetDestinationDetails (
					  p_position_description_id  in NUMBER,
					  p_action_taken OUT NOCOPY varchar2,
                                          p_user_name OUT NOCOPY varchar2,
					  p_groupbox_name OUT NOCOPY varchar2
					  );
--
--
PROCEDURE SetDestinationDetails (
					  p_position_description_id  in NUMBER,
					  p_from_name OUT NOCOPY VARCHAR2,
					  p_category OUT NOCOPY varchar2,
					  p_occupational_code OUT NOCOPY varchar2,
					  p_grade_level OUT NOCOPY varchar2,
					  p_official_title OUT NOCOPY varchar2,
                                p_current_status OUT NOCOPY varchar2,
                                p_pay_plan OUT NOCOPY varchar2,
                                p_routing_group OUT NOCOPY varchar2,
                                p_date_inititated OUT NOCOPY varchar2,
                                p_date_received OUT NOCOPY varchar2
					  );
--
procedure CompleteBlockingOfPD ( p_position_description_id in Number);
--
--
PROCEDURE get_routing_group_details (
                                    p_user_name          IN     fnd_user.user_name%TYPE
                                   ,p_position_description_id IN
                                      ghr_position_descriptions.position_description_id%TYPE
                                   ,p_routing_group_id   IN OUT NOCOPY NUMBER
                                   ,p_initiator_flag     IN OUT NOCOPY VARCHAR2
                                   ,p_requester_flag     IN OUT NOCOPY VARCHAR2
                                   ,p_authorizer_flag    IN OUT NOCOPY VARCHAR2
                                   ,p_personnelist_flag  IN OUT NOCOPY VARCHAR2
                                   ,p_approver_flag      IN OUT NOCOPY VARCHAR2
                                   ,p_reviewer_flag      IN OUT NOCOPY VARCHAR2);
--
--
function item_attribute_exists
  (p_item_type in wf_items.item_type%type
  ,p_item_key  in wf_items.item_key%type
  ,p_name      in wf_item_attributes_tl.name%type)
  return boolean;
--
--
PROCEDURE CheckIfPDWfEnd ( itemtype	in varchar2,
					   itemkey  in varchar2,
					   actid	in number,
					   funcmode	in varchar2,
					   result	in OUT NOCOPY varchar2);
--
PROCEDURE EndPDProcess( itemtype	in varchar2,
				  itemkey  	in varchar2,
				  actid	in number,
				  funcmode	in varchar2,
				  result	in OUT NOCOPY varchar2);
--
end ghr_wf_pd_pkg;


 

/
