--------------------------------------------------------
--  DDL for Package WF_PROCESS_ACTIVITY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_PROCESS_ACTIVITY" AUTHID CURRENT_USER as
/* $Header: wfengs.pls 120.6.12010000.3 2012/09/28 22:06:38 alsosa ship $ */
/*#
 * The Workflow Process Activity Status APIs can be called by an application program
 * or a workflow function in the runtime phase to communicate with the engine
 * and to change the status of each of the activities. These APIs are defined
 * in a PL/SQL package called WF_PROCESS_ACTIVITY.
 * @rep:scope private
 * @rep:product OWF
 * @rep:displayname Workflow Process Activity APIs
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@eng_api See the related online help
 */

procedure ClearCache;

function RootInstanceId(itemtype in varchar2,
                        itemkey in varchar2,
                        process  in varchar2)
return number;

procedure ActivityName(
  actid in number,
  act_itemtype out NOCOPY varchar2,
  act_name out NOCOPY varchar2);

function StartInstanceId(itemtype in varchar2,
                    process  in varchar2,
                    version in number,
                    activity in varchar2)
return number;

function ActiveInstanceId(itemtype in varchar2,
                    itemkey in varchar2,
                    activity in varchar2,
                    status in varchar2)
return number;

function IsChild(
  rootid in number,
  acttype in varchar2,
  actname in varchar2,
  actdate in date)
return boolean;

function FindActivity(parentid in number,
                      activity in varchar2,
                      actdate in date)
return number;

end WF_PROCESS_ACTIVITY;

/
