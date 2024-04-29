--------------------------------------------------------
--  DDL for Package WF_ENGINE_BULK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ENGINE_BULK" AUTHID CURRENT_USER as
/* $Header: wfengblks.pls 120.7 2006/10/04 21:38:40 dlam noship $ */
/*#
 * Provides APIs that can be called by an application program
 * to launch multiple work items at once in bulk and to set
 * values for item attributes in bulk across multiple work
 * items.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Engine Bulk Processing
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@wfebulk See the related online help
 */
--
-- Constant values
--

debug boolean := FALSE;    -- Run engine in debug or normal mode

-- Standard date format string.  Used to convert dates to strings
-- when returning date values as activity function results.
date_format varchar2(30) := 'YYYY/MM/DD HH24:MI:SS';

-- Itemkey List
type itemkeytabtype is table of varchar2(240) index by binary_integer;

-- UserKey List
Type UserKeyTabType is table of varchar2(240) index by binary_integer;

--OwnerRole List
Type OwnerRoleTabType is table of varchar2(320) index by binary_integer;


-- commit for every n iterations
commit_frequency     number       := 500;

-- Table of Failed Items
g_FailedItems WF_ENGINE_BULK.ItemKeyTabType;

-- Table of Successful Items
g_SuccessItems  WF_ENGINE_BULK.ItemKeyTabType;
--
-- Table of failed attributes
g_FailedAttributes wf_engine.nametabtyp;


--
-- CreateProcess (PUBLIC)
--   Create a new runtime process for a given list of itemkeys
--  (for an application itemtype).
-- IN
--   itemtype - A valid item type
--   itemkeys  - A list of itemkeys  generated from the application
--               object's primary key.
--   process  - A valid root process for this item type
--              (or null to use the item's selector function)
--  user_keys - A list of userkeys bearing one to one
--              correspondence with the itek ley list
-- owner_roles - A list of ownerroles bearing one-to-one
--               correspondence with the item key list
-- parent_item_type -  Optional Parent work item
-- parent_item_key  -  Optional parent item key
-- parent_context   -  Context info about parent
-- masterDetail     -  Master Detail Co-ordination

/*#
 * Creates multiple new runtime process instances of the specified
 * item type at once, based on the specified array of workflow
 * item keys. You can optionally specify one existing work item as
 * the parent for all the new work items. You cannot use this API
 * to create forced synchronous processes.
 * @param itemtype Item Type
 * @param itemkeys Array of Item Keys
 * @param process Process Name
 * @param user_keys Array of User Keys
 * @param owner_roles Array of Owner Roles
 * @param parent_itemtype Parent Item Type
 * @param parent_itemkey Parent Item Key
 * @param parent_context Parent Context Information
 * @param masterdetail Master Detail Coordination
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Processes in Bulk
 * @rep:compatibility S
 * @rep:ihelp FND/@a_cpbulk See the related online help
 */
procedure CreateProcess(itemtype in varchar2,
                        itemkeys  in wf_engine_bulk.itemkeytabtype,
                        process  in varchar2,
                        user_keys in wf_engine_bulk.userkeytabtype,
                        owner_roles in wf_engine_bulk.ownerroletabtype,
                        parent_itemtype in varchar2 default null,
                        parent_itemkey in varchar2  default null,
                        parent_context in varchar2  default null,
                        masterdetail   in boolean default null);

--
-- StartProcess (PUBLIC)
--   Begins execution of the process.It identifies the start activities
--   for the run-time process and launches them in bulk for all the item keys
--   in the list, under the given itemtype.
-- IN
--   itemtype - A valid item type
--   itemkeys  - A list of itemkeys generated from the application object's
--               primary key.
--
/*#
 * Begins execution of multiple new runtime process instances at
 * once, identified by the specified item type and array of
 * workflow item keys. The Workflow Engine locates the activity
 * marked as a Start activity in the process definition and then
 * defers that activity for each of the new work items. You must
 * call either WF_ENGINE.CreateProcess() or
 * WF_ENGINE_BULK.CreateProcess() to define the item type and item
 * keys before calling WF_ENGINE_BULK.StartProcess(). You cannot use
 * this API to start forced synchronous processes.
 * @param itemtype Item Type
 * @param itemkeys Array of Item Keys
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Start Processes in Bulk
 * @rep:compatibility S
 * @rep:ihelp FND/@a_spbulk See the related online help
 */
procedure StartProcess(itemtype in varchar2,
                       itemkeys  in wf_engine_bulk.itemkeytabtype);


-- FastForward (PUBLIC)
--
--This API starts a specific activity for a list of items. This activity
--must be marked as start, but does not need to be an activity without
--any in transition.This API would fast forward the launch process by
--bulk-creating the items, bulk initializing item attributes and bulk
--starting a specified start activity within the process across all the
--itemkeys.The activity must be a direct child of the root process specified.

-- IN
--   itemtype      - A valid item type
--   itemkeys      - A list of itemkeys generated from the application object's
--                   primary key.
--   process       - The process to be started
--   activity      - The label of the specific activity within the process to be started.
--   activityStatus - The status of the activity.This should be restricted to 'NOTIFIED'
--                     and 'DEFERRED' only.
/*#
 * Creates multiple new runtime process instances of the
 * specified item type at once, based on the specified array of
 * workflow item keys, and begins execution of the new work items
 * at the specified activity. You can optionally specify one
 * existing work item as the parent for all the new work items.
 * The activity at which execution begins must be marked as a Start
 * activity. However, it can have incoming transitions. The activity
 * must be a direct child of the process in which execution of the
 * work item begins. It cannot be part of a subprocess. The Workflow
 * Engine first calls WF_ENGINE_BULK.CreateProcess() to create the
 * new work items and then sets the Start activity for each work
 * item to the specified status, either 'DEFERRED' or 'NOTIFIED'.
 * You cannot use WF_ENGINE_BULK.FastForward() to start forced
 * synchronous processes.
 * @param itemtype Item Type
 * @param itemkeys Array of Item Keys
 * @param process Process Name
 * @param activity Activity Node Label
 * @param activityStatus Activity Status to Set
 * @param parent_itemtype Parent Item Type
 * @param parent_itemkey Parent Item Key
 * @param parent_context Parent Context Information
 * @param masterdetail Master Detail Coordination
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Fast Forward Processes in Bulk
 * @rep:compatibility S
 * @rep:ihelp FND/@a_ffbulk See the related online help
 */
procedure FastForward(itemtype in varchar2,
                      itemkeys  in wf_engine_bulk.itemkeytabtype,
                      process in varchar2,
                      activity in varchar2,
                      activityStatus in varchar2 default null,
                      parent_itemtype in varchar2 default null,
                      parent_itemkey in varchar2  default null,
                      parent_context in varchar2  default null,
                      masterdetail   in boolean default null);

-- SetItemAttrText (PUBLIC)
--   Set the values of an array of text item attribute.
--   Unlike SetItemAttrText(), it stores the values directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
--
/*#
 * Sets the values of an array of item type attributes of type
 * text in multiple work items, identified by the specified item
 * type and array of item keys. You can also use this API to set
 * attributes of type role, form, URL, lookup, or document. This
 * API sets the value of one item type attribute in each work
 * item. Consequently, the array of item keys must correspond on
 * a one-to-one basis with the array of item type attribute names
 * and with the array of item type attribute values.
 * @param itemtype Item Type
 * @param itemkeys Array of Item Keys
 * @param anames Array of Attribute Names
 * @param avalues Array of Attribute Values
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Text Item Attribute Values in Bulk
 * @rep:compatibility S
 * @rep:ihelp FND/@a_siatbulk See the related online help
*/
procedure SetItemAttrText(
  itemtype in varchar2,
  itemkeys  in Wf_Engine_Bulk.ItemKeyTabType,
  anames   in Wf_Engine.NameTabTyp,
  avalues  in Wf_Engine.TextTabTyp);

-- SetItemAttrNumber (PUBLIC)
--   Set the values of an array of number item attribute.
--   Unlike SetItemAttrText(), it stores the values directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
--
/*#
 * Sets the values of an array of item type attributes of type
 * number in multiple work items, identified by the specified
 * item type and array of item keys. This API sets the value of
 * one item type attribute in each work item. Consequently, the
 * array of item keys must correspond on a one-to-one basis with
 * array of item keys must correspond on a one-to-one basis with
 * the array of item type attribute names and with the array of
 * item type attribute values.
 * @param itemtype Item Type
 * @param itemkeys Array of Item Keys
 * @param anames Array of Attribute Names
 * @param avalues Array of Attribute Values
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Number Item Attribute Values in Bulk
 * @rep:compatibility S
 * @rep:ihelp FND/@a_sianbulk See the related online help
*/
procedure SetItemAttrNumber(
  itemtype in varchar2,
  itemkeys  in Wf_Engine_Bulk.ItemKeyTabType,
  anames   in Wf_Engine.NameTabTyp,
  avalues  in Wf_Engine.NumTabTyp);

-- SetItemAttrDate (PUBLIC)
--   Set the values of an array of date item attribute.
--   Unlike SetItemAttrText(), it stores the values directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
--
/*#
 * Sets the values of an array of item type attributes of type
 * date in multiple work items, identified by the specified
 * item type and array of item keys. This API sets the value of
 * one item type attribute in each work item. Consequently, the
 * array of item keys must correspond on a one-to-one basis with
 * the array of item type attribute names and with the array of
 * item type attribute values.
 * @param itemtype Item Type
 * @param itemkeys Array of Item Keys
 * @param anames Array of Attribute Name
 * @param avalues Array of Attribute Values
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Date Item Attribute Values in Bulk
 * @rep:compatibility S
 * @rep:ihelp FND/@a_siadbulk See the related online help
*/
procedure SetItemAttrDate(
  itemtype in varchar2,
  itemkeys  in Wf_Engine_Bulk.ItemKeyTabType,
  anames   in Wf_Engine.NameTabTyp,
  avalues  in Wf_Engine.DateTabTyp);

end WF_ENGINE_BULK;
 

/
