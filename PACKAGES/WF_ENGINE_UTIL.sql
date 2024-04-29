--------------------------------------------------------
--  DDL for Package WF_ENGINE_UTIL
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ENGINE_UTIL" AUTHID CURRENT_USER as
/* $Header: wfengs.pls 120.6.12010000.3 2012/09/28 22:06:38 alsosa ship $ */
/*#
 * The Workflow Engine Utility APIs can be called by an application program or a
 * workflow function in the runtime phase to communicate with the engine
 * and to change the status of each of the activities. These APIs are defined
 * in a PL/SQL package called WF_ENGINE_UTIL.
 * @rep:scope private
 * @rep:product OWF
 * @rep:displayname Workflow Engine Utility APIs
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@eng_api See the related online help
 */

procedure ClearCache;

procedure AddProcessStack(
  itemtype in varchar2,
  itemkey in varchar2,
  act_itemtype in varchar2,
  act_name in varchar2,
  actid in number,
  rootflag in boolean default FALSE);

procedure RemoveProcessStack(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number);

function activity_parent_process(itemtype in varchar2,
                                 itemkey in varchar2,
                                 actid in number)
return number;

procedure complete_activity(itemtype in varchar2,
                            itemkey  in varchar2,
                            actid    in number,
                            result in varchar2,
                            runpntf in boolean default true);
--Bug 2259039
--Valid values for runmode are : 'START', 'ACTIVITY','EVENT'
procedure start_process_internal(
  itemtype in varchar2,
  itemkey  in varchar2,
  runmode in varchar2);


procedure process_activity(itemtype in varchar2,
                           itemkey  in varchar2,
                           actid    in number,
                           threshold in number,
                           activate in boolean default false);

procedure reset_activities(itemtype in varchar2,
                           itemkey  in varchar2,
                           actid    in number,
                           cancel   in boolean);

function reset_tree(itemtype in varchar2,
                    itemkey in varchar2,
                    rootid in number,
                    goalid in number,
                    actdate in date)
return boolean;

procedure move_to_history(itemtype in varchar2,
                          itemkey  in varchar2,
                          actid    in number);

procedure execute_activity(itemtype in varchar2,
                           itemkey  in varchar2,
                           actid    in number,
                           funmode  in varchar2);

procedure function_call(funname    in varchar2,
                        itemtype   in varchar2,
                        itemkey    in varchar2,
                        actid      in number,
                        funmode    in varchar2,
                        result     out NOCOPY varchar2);

function Execute_Selector_Function(
  itemtype in varchar2,
  itemkey in varchar2,
  runmode in varchar2)
return varchar2;

function get_root_process(itemtype in varchar2,
                          itemkey  in varchar2,
                          activity in varchar2 default '')
return varchar2;

procedure process_kill_childprocess(itemtype in varchar2,
                                    itemkey in varchar2);

procedure process_kill_children(itemtype in varchar2,
                                itemkey in varchar2,
                                processid in number);

procedure suspend_child_processes(itemtype in varchar2,
                                  itemkey in varchar2,
                                  processid in number);

procedure resume_child_processes(itemtype in varchar2,
                                 itemkey in varchar2,
                                 processid in number);

procedure notification(itemtype   in varchar2,
                       itemkey    in varchar2,
                       actid      in number,
                       funcmode   in varchar2,
                       result     out NOCOPY varchar2);

procedure notification_send(itemtype   in varchar2,
                       itemkey    in varchar2,
                       actid      in number,
                       msg        in varchar2,
                       msgtype    in varchar2,
                       prole      in varchar2,
                       expand_role in varchar2,
                       result     out NOCOPY varchar2);

procedure notification_copy (
          copy_nid in  number,
          old_itemkey in varchar2,
          new_itemkey in varchar2,
          nid in out NOCOPY number);

procedure notification_refresh
         (itemtype in varchar2,
          itemkey in varchar2);

procedure execute_error_process (itemtype  in varchar2,
                                 itemkey in varchar2,
                                 actid in number,
                                 result in varchar2);

procedure SetErrorItemAttr (error_type in varchar2,
                            error_key  in varchar2,
                            attrtype   in varchar2,
                            item_attr  in varchar2,
                            avalue     in varchar2);

procedure execute_post_ntf_function (itemtype in varchar2,
                                     itemkey in varchar2,
                                     actid in number,
                                     funmode in varchar2,
                                     pntfstatus out NOCOPY varchar2,
                                     pntfresult out NOCOPY varchar2);

procedure Execute_Notification_Callback(
  funcmode in varchar2,
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  ctx_nid in number,
  ctx_text in varchar2);

function Activity_Timeout(actid in number)
return varchar2;

procedure Event_Activity(
  itemtype   in varchar2,
  itemkey    in varchar2,
  actid      in number,
  funcmode   in varchar2,
  result     out NOCOPY varchar2);

end WF_ENGINE_UTIL;

/
