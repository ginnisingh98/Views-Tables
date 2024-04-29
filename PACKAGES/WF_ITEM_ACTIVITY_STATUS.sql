--------------------------------------------------------
--  DDL for Package WF_ITEM_ACTIVITY_STATUS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ITEM_ACTIVITY_STATUS" AUTHID CURRENT_USER as
/* $Header: wfengs.pls 120.6.12010000.3 2012/09/28 22:06:38 alsosa ship $ */
/*#
 * The Workflow Item Activity Status APIs can be called by an application program
 * or a workflow function in the runtime phase to communicate with the engine
 * and to change the status of each of the activities. These APIs are defined
 * in a PL/SQL package called WF_ITEM_ACTIVITY_STATUS.
 * @rep:scope private
 * @rep:product OWF
 * @rep:displayname Workflow Item Activity Status APIs
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@eng_api See the related online help
 */

procedure ClearCache;

procedure Update_Notification(itemtype in varchar2,
                              itemkey  in varchar2,
                              actid    in number,
                              notid    in number,
                              user     in varchar2);

procedure Root_Status(itemtype in varchar2,
                 itemkey  in varchar2,
                 status   out NOCOPY varchar2,
                 result   out NOCOPY varchar2);

procedure LastResult(
  itemtype in varchar2,
  itemkey in varchar2,
  actid out NOCOPY number,
  status out NOCOPY varchar2,
  result out NOCOPY varchar2);

procedure Status(itemtype in varchar2,
                 itemkey  in varchar2,
                 actid    in number,
                 status   out NOCOPY varchar2);

procedure Result(itemtype in varchar2,
                 itemkey  in varchar2,
                 actid    in number,
                 status   out NOCOPY varchar2,
                 result   out NOCOPY varchar2);

function Due_Date(
  itemtype in varchar2,
  itemkey  in varchar2,
  actid    in number)
return date;

procedure Notification_Status(itemtype in varchar2,
                              itemkey  in varchar2,
                              actid    in number,
                              notid    out NOCOPY number,
                              user     out NOCOPY varchar2);

procedure Error_Info(itemtype in varchar2,
                     itemkey  in varchar2,
                     actid    in number,
                     errname out NOCOPY varchar2,
                     errmsg out NOCOPY varchar2,
                     errstack out NOCOPY varchar2);

procedure Set_Error(itemtype in varchar2,
                    itemkey in varchar2,
                    actid in number,
                    errcode in varchar2,
                    error_process in boolean default FALSE);

procedure Delete_Status(itemtype in varchar2,
                        itemkey in varchar2,
                        actid in number);

procedure Create_Status(itemtype  in varchar2,
                        itemkey   in varchar2,
                        actid     in number,
                        status    in varchar2,
                        result    in varchar2,
                        beginning in date default null,
                        ending    in date default null,
                        suspended in boolean default FALSE,
                        newStatus in boolean default FALSE);


procedure Audit(itemtype  in varchar2,
                itemkey   in varchar2,
                actid     in number,
                action    in varchar2,
                performer in varchar2);

-- 3966635 Workflow Provisioning Project
-- Following added so as not to loose the changes required
-- procedure Update_Prov_Request(itemtype        in varchar2,
--                               itemkey         in varchar2,
--                               actid           in number,
--                               prov_request_id in number);
--
end WF_ITEM_ACTIVITY_STATUS;

/
