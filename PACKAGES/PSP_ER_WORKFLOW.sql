--------------------------------------------------------
--  DDL for Package PSP_ER_WORKFLOW
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."PSP_ER_WORKFLOW" AUTHID CURRENT_USER as
/* $Header: PSPERWFS.pls 120.0.12010000.2 2008/08/05 10:13:05 ubhat ship $ */

 procedure start_initiator_wf( p_request_id in integer);


 procedure init_approvals(itemtype in  varchar2,
                          itemkey  in  varchar2,
                          actid    in  number,
                          funcmode in  varchar2,
                          result   out nocopy varchar2);

 procedure fatal_err_occured(itemtype in  varchar2,
                          itemkey  in  varchar2,
                          actid    in  number,
                          funcmode in  varchar2,
                          result   out nocopy varchar2);

 procedure purge_er(itemtype in  varchar2,
                   itemkey  in  varchar2,
                   actid    in  number,
                   funcmode in  varchar2,
                   result   out nocopy varchar2);

 procedure get_next_approver(itemtype in  varchar2,
                             itemkey  in  varchar2,
                             actid    in  number,
                             funcmode in  varchar2,
                             result   out nocopy varchar2);


 procedure process_rejections(itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2);

 procedure process_approvals(itemtype in  varchar2,
                             itemkey  in  varchar2,
                             actid    in  number,
                             funcmode in  varchar2,
                             result   out nocopy varchar2);

 procedure record_initiator_apprvl(itemtype in  varchar2,
                                   itemkey  in  varchar2,
                                   actid    in  number,
                                   funcmode in  varchar2,
                                   result   out nocopy varchar2);

 procedure record_initiator_rjct(itemtype in  varchar2,
                                 itemkey  in  varchar2,
                                 actid    in  number,
                                 funcmode in  varchar2,
                                 result   out nocopy varchar2);

 procedure approver_pdf_fail(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2);

 procedure initiator_response(itemtype in  varchar2,
                             itemkey  in  varchar2,
                             actid    in  number,
                             funcmode in  varchar2,
                             result   out nocopy varchar2);

 --- get and attach the same PDF for the next approver.
 procedure get_pdf_for_apprvr(itemtype in  varchar2,
                              itemkey  in  varchar2,
                              actid    in  number,
                              funcmode in  varchar2,
                              result   out nocopy varchar2);

 procedure gen_modified_pdf(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2);

  procedure pyugen_er_workflow(pactid in number);

 procedure update_receiver(itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2);
procedure update_approver(itemtype in  varchar2,
                            itemkey  in  varchar2,
                            actid    in  number,
                            funcmode in  varchar2,
                            result   out nocopy varchar2);

 procedure create_frp_role(itemtype in  varchar2,
                           itemkey  in  varchar2,
                           actid    in  number,
                           funcmode in  varchar2,
                           result   out nocopy varchar2);

 procedure pre_approved(itemtype in  varchar2,
                        itemkey  in  varchar2,
                        actid    in  number,
                        funcmode in  varchar2,
                        result   out nocopy varchar2);

 procedure update_initiator_message	(itemtype	IN  varchar2,
					itemkey		IN  varchar2,
					actid		IN  number,
					funcmode	IN  varchar2,
					result		OUT nocopy varchar2);

 procedure preview_er	(itemtype	IN  varchar2,
			itemkey		IN  varchar2,
			actid		IN  number,
			funcmode	IN  varchar2,
			result		OUT nocopy varchar2);

 procedure set_wf_admin(itemtype in  varchar2,
                        itemkey  in  varchar2,
                        actid    in  number,
                        funcmode in  varchar2,
                        result   out nocopy varchar2);


 procedure get_timeout_approver(itemtype in  varchar2,
                                itemkey  in  varchar2,
                                actid    in  number,
                                funcmode in  varchar2,

                               result   out nocopy varchar2);
 procedure approver_post_notify(itemtype in  varchar2,
                               itemkey  in  varchar2,
                               actid    in  number,
                               funcmode in  varchar2,
                               result   out nocopy varchar2);
 --Bug 7135471
 FUNCTION item_attribute_exists
                (p_item_type in wf_items.item_type%type,
                 p_item_key  in wf_item_activity_statuses.item_key%type,
                 p_name      in wf_item_attribute_values.name%type)
                 return boolean;

end;

/
