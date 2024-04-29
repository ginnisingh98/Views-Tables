--------------------------------------------------------
--  DDL for Package HR_APPRAISAL_WORKFLOW_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPRAISAL_WORKFLOW_SS" AUTHID CURRENT_USER AS
/* $Header: hrapwfss.pkh 120.0.12010000.2 2009/02/23 14:04:27 psugumar ship $ */


procedure  create_hr_transaction
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
);
procedure  reset_main_appraiser
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
);
procedure  commit_transaction
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
);
procedure Notify(itemtype   in varchar2,
			  itemkey    in varchar2,
      		  actid      in number,
	 		  funcmode   in varchar2,
			  resultout  in out nocopy varchar2);
procedure notify_appraisee_or_appraiser(itemtype   in varchar2,
			  itemkey    in varchar2,
      		  actid      in number,
	 		  funcmode   in varchar2,
			  resultout  in out nocopy varchar2);
procedure reset_appr_ntf_status(itemtype   in varchar2,
			  itemkey    in varchar2,
      		  actid      in number,
	 		  funcmode   in varchar2,
			  resultout  in out nocopy varchar2);
procedure block(itemtype   in varchar2,
			  itemkey    in varchar2,
      		  actid      in number,
	 		  funcmode   in varchar2,
			  resultout  in out nocopy varchar2);
procedure find_next_participant(itemtype   in varchar2,
			  itemkey    in varchar2,
      		  actid      in number,
	 		  funcmode   in varchar2,
			  resultout  in out nocopy varchar2);
procedure branch_on_participant_type(itemtype   in varchar2,
			  itemkey    in varchar2,
      		  actid      in number,
	 		  funcmode   in varchar2,
			  resultout  in out nocopy varchar2);

procedure start_transaction
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2);

procedure participants_block
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2);
  procedure appraisee_or_appraiser_block
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2);
procedure approvals_block
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2);

procedure build_link(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2);
procedure getApprovalBlockId (p_itemType in VARCHAR2
                             ,p_itemKey    in VARCHAR2
                              ,p_blockId      OUT NOCOPY NUMBER);
PROCEDURE  set_appraisal_rfc_status
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
);
PROCEDURE  set_appraisal_reject_status
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
);
PROCEDURE  notify_appraisee_on_completion
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
);
procedure build_ma_compl_log_msg(document_id IN Varchar2,
                          display_type IN Varchar2,
                          document IN OUT NOCOPY varchar2,
                          document_type IN OUT NOCOPY Varchar2);

PROCEDURE  appraisee_feedback_allowed
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
);

PROCEDURE  appraisee_commit_aft_feedback
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
);

PROCEDURE  notify_appraisee
( p_itemtype in varchar2
, p_itemkey in varchar2
, p_actid in number
, p_funcmode in varchar2
, p_result  in out  nocopy varchar2
);

FUNCTION isAppraiser
  (
    p_notification_id in wf_notifications.item_key%type,
    p_loggedin_person_id in number
  ) RETURN varchar2;

end hr_appraisal_workflow_ss;   -- Package spec



/
