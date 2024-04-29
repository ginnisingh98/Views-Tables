--------------------------------------------------------
--  DDL for Package HR_APPROVAL_SS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."HR_APPROVAL_SS" AUTHID CURRENT_USER AS
/* $Header: hraprvlss.pkh 120.4.12010000.3 2009/08/11 10:36:45 ckondapi ship $ */


procedure getNextApproverRole(p_item_type    in varchar2,
                              p_item_key     in varchar2,
                              p_act_id       in number,
                              funmode     in varchar2,
                              result      out nocopy varchar2  );
procedure isFinalApprover( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );

procedure updateApproveStatus( p_item_type    in varchar2,
                               p_item_key     in varchar2,
                               p_act_id       in number,
                               funmode     in varchar2,
                               result      out nocopy varchar2     );

procedure approver_category( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );

procedure flagApproversAsNotified( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );
procedure updateNoResponseStatus( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );
procedure setRespondedUserContext( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );
procedure submit_for_approval( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );

procedure setSFLResponseContext( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );
procedure setRFCResponseContext( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );

procedure setApproverResponseContext( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );
 procedure processRFC( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2     );
function getRoleDisplayName(p_user_name  in varchar2,
                            p_orig_system  in varchar2,
                            p_orig_system_id  in number)  return varchar2;
 function isApproverEditAllowed(p_transaction_id number default null,
                               p_user_name  in varchar2,
                               p_orig_system  in varchar2,
                               p_orig_system_id  in number)  return varchar2;
 function getuserOrigSystem(p_user_name in fnd_user.user_name%type
                            ,p_notification_id in number default null)
                                    return wf_roles.parent_orig_system%type;

 function getUserOrigSystemId(p_user_name in fnd_user.user_name%type
                             ,p_notification_id in number default null)
                                    return wf_roles.orig_system_id%type;
 procedure handleRFCAction(p_approval_notification_id in wf_notifications.notification_id%type,
                          p_transaction_id in hr_api_transactions.transaction_id%type,
                          p_item_type in wf_items.item_type%type,
                          p_item_key  in wf_items.item_key%type,
                          p_rfcRoleName in wf_roles.name%type,
                          p_rfcUserOrigSystem in wf_roles.orig_system%type,
                          p_rfcUserOrigSystemId in wf_roles.orig_system_id%type,
                          p_rfc_comments in varchar2,
                          p_approverIndex in number
                          );
procedure handleRFCAction(p_approval_notification_id in wf_notifications.notification_id%type
                         );
procedure reInitPerformerRoles(p_notification_id in wf_notifications.notification_id%type,
                               p_transaction_id in hr_api_transactions.transaction_id%type,
                               p_item_type in wf_items.item_type%type,
                               p_item_key  in wf_items.item_key%type);

procedure approvals_block
  (itemtype     in     varchar2
  ,itemkey      in     varchar2
  ,actid        in     number
  ,funmode      in     varchar2
  ,result  in out  nocopy varchar2);

procedure create_item_attrib_if_notexist(itemtype in varchar2,
                      itemkey in varchar2,
                      aname in varchar2,
                      text_value   in varchar2,
                      number_value in number,
                      date_value   in date );

procedure startGenericApprovalProcess(p_transaction_id in number
                                     ,p_item_key  in out nocopy wf_items.item_key%type
                                     ,p_wf_ntf_sub_fnd_msg in fnd_new_messages.message_name%type
                                     ,p_relaunch_function hr_api_transactions.relaunch_function%type
                                     ,p_additional_wf_attributes in HR_WF_ATTR_TABLE
                                     ,p_status       out nocopy varchar2
                                     ,p_error_message out nocopy varchar2
                                     ,p_errstack     out nocopy varchar2
          );


procedure processApprovalSubmit(p_transaction_id in number,
                                p_approval_comments in varchar2);

function getinitApprovalBlockId(p_transaction_id in number) return number;

function getOAFPageActId(p_item_type in wf_items.item_type%type,
                         p_item_key in wf_items.item_key%type) return number;

procedure resetWfPageFlowState(p_transaction_id in number);

procedure checktransactionState(p_transaction_id       IN NUMBER);

function getApproverNtfId(p_transaction_id in number) return number;

procedure handleApprovalErrors(p_item_type in wf_items.item_type%type,
                         p_item_key in wf_items.item_key%type,
                         error_message_text in varchar2);

procedure updateRejectStatus( p_item_type    in varchar2,
                           p_item_key     in varchar2,
                           p_act_id       in number,
                           funmode     in varchar2,
                           result      out nocopy varchar2);

END HR_APPROVAL_SS;


/
