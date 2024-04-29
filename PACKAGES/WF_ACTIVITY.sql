--------------------------------------------------------
--  DDL for Package WF_ACTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ACTIVITY" AUTHID CURRENT_USER as
/* $Header: wfengs.pls 120.6.12010000.3 2012/09/28 22:06:38 alsosa ship $ */
/*#
 * The Workflow Activity APIs can be called by an application program or a
 * workflow function in the runtime phase to communicate with the engine
 * and to change the status of each of the activities. These APIs are defined
 * in a PL/SQL package called WF_ACTIVITY.
 * @rep:scope private
 * @rep:product OWF
 * @rep:displayname Workflow Activity APIs
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@eng_api See the related online help
 */

procedure ClearCache;

function Instance_Type(actid in number,
                       actdate in date)
return varchar2;

function Type(itemtype in varchar2,
              activity in varchar2,
              actdate in date)
return varchar2;

procedure Info(actid in number,
               actdate in date,
               rerun out NOCOPY varchar2,
               type  out NOCOPY varchar2,
               cost  out NOCOPY number,
               function_type out NOCOPY varchar2);

function Ending(actid in number,
                actdate in date)
return boolean;

procedure Error_Process(actid in number,
                        actdate in date,
                        errortype in out NOCOPY varchar2,
                        errorprocess in out NOCOPY varchar2);

function Activity_Function(itemtype in varchar2,
                           itemkey in varchar2,
                           actid in number)
return varchar2;

function Activity_Function_Type(itemtype in varchar2,
                           itemkey in varchar2,
                           actid in number)
return varchar2;

procedure Notification_Info(itemtype in varchar2,
                            itemkey in varchar2,
                            actid in number,
                            message out NOCOPY varchar2,
                            msgtype out NOCOPY varchar2,
                            expand_role out NOCOPY varchar2);

procedure Event_Info(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  event_name out NOCOPY varchar2,
  direction out NOCOPY varchar2);

function Perform_Role(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number)
return varchar2;

function Version(itemtype in varchar2,
                 activity in varchar2,
                 actdate in date)
return number;

end WF_ACTIVITY;

/
