--------------------------------------------------------
--  DDL for Package WF_ITEM
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ITEM" AUTHID CURRENT_USER as
/* $Header: wfengs.pls 120.6.12010000.3 2012/09/28 22:06:38 alsosa ship $ */
/*#
 * The Workflow Item APIs can be called by an application program or a workflow
 * function in the runtime phase to communicate with the engine and to change
 * the status of each of the activities. These APIs are defined in a PL/SQL
 * package called WF_ITEM.
 * @rep:scope private
 * @rep:product OWF
 * @rep:displayname Workflow Item APIs
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@eng_api See the related online help
 */

procedure ClearCache;

procedure Set_Item_Parent(itemtype in varchar2,
                          itemkey in varchar2,
                          parent_itemtype in varchar2,
                          parent_itemkey in varchar2,
                          parent_context in varchar2,
                          masterdetail   in boolean default NULL);

--
-- SetItemOwner (PRIVATE)
--   Set the owner of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   owner - Role designated as owner of the item
--
procedure SetItemOwner(
  itemtype in varchar2,
  itemkey in varchar2,
  owner in varchar2);

--
-- SetItemUserKey (PRIVATE)
--   Set the user key of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   userkey - User key to be set
--
procedure SetItemUserKey(
  itemtype in varchar2,
  itemkey in varchar2,
  userkey in varchar2);

--
-- GetItemUserKey (PRIVATE)
--   Get the user key of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
-- RETURNS
--   User key of the item
--
function GetItemUserKey(
  itemtype in varchar2,
  itemkey in varchar2)
return varchar2;

function Item_Exist(itemtype in varchar2,
                    itemkey  in varchar2)
return boolean;

procedure Root_Process(itemtype in varchar2,
                       itemkey   in varchar2,
                       wflow out NOCOPY varchar2,
                       version out NOCOPY number);

procedure Create_Item(
  itemtype in varchar2,
  itemkey  in varchar2,
  wflow    in varchar2,
  actdate  in date,
  user_key in varchar2 default null,
  owner_role in varchar2 default null);

function Active_Date(itemtype in varchar2,
                     itemkey in varchar2)
return date;

--Function Acquire_lock (PRIVATE)
--This function tries to lock the particular item (for the give
--itemtype/itemkey ) in the wf_items table. It returns true if the lock
--acquired else returns false.

function acquire_lock(itemtype in varchar2,
                     itemkey in varchar2,
                     raise_exception in boolean default false)
return boolean;

--
-- Attribute_On_Demand (PRIVATE)
--   Returns on demand status for the workitem
-- IN
--   itemtype - Item type
--   itemkey - Item key
-- Initialize cache if not already done then return c_ondemand;
--

function Attribute_On_Demand(
  itemtype in varchar2,
  itemkey in varchar2
) return boolean;

--
-- SetEndDate (Private)
--   Sets end_date and completes any coordinated counter processing.
-- IN
--   p_itemtype - process item type
--   p_itemkey - process item key
-- RETURNS
--  number
-- NOTE:
--   This function will return a status of one of the following:
--     0 - Item was found, active, and the end_date was set.
--     1 - The item was not found. (ERROR)

function SetEndDate(p_itemtype in varchar2,
                    p_itemkey in varchar2) return number;

end WF_ITEM;

/
