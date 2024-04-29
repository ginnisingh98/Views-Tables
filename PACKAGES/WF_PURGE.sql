--------------------------------------------------------
--  DDL for Package WF_PURGE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_PURGE" AUTHID CURRENT_USER as
/* $Header: wfprgs.pls 120.5.12010000.3 2013/02/01 17:37:03 alsosa ship $ */
/*#
 * Provides APIs to purge obsolete runtime data for
 * completed items and processes, design information
 * for obsolete activity versions that are no longer in
 * use, and expired users and roles. Periodically purging
 * obsolete data from your system increases performance.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Purge
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:category BUSINESS_ENTITY WF_NOTIFICATION
 * @rep:category BUSINESS_ENTITY WF_USER
 * @rep:ihelp FND/@wfpurge See the related online help
 */

--
-- Persistence Type Mode
-- Setting this variable to 'PERM' or 'TEMP' will affect the purging
-- routines to purge different persistence type objects.
--
persistence_type varchar2(8) := 'TEMP';

--
-- Commit Frequency: Default - commit every 500 records.
-- This variable can be changed as needed to control rollback segment
-- growth against performance.
--
commit_frequency number := 1000;

-- procedure Move_To_History
--   Move wf_item_activity_status rows for particular itemtype/key from
--   main table to history table.
-- IN:
--   itemtype - Item type to move, or null for all itemtypes
--   itemkey - Item key to move, or null for all itemkeys
--

-- Global tables accessed by ECX, WF Purge APIs
TYPE itemtypeTAB IS TABLE OF VARCHAR2(8) INDEX BY BINARY_INTEGER;
TYPE itemkeyTAB IS TABLE OF VARCHAR2(240) INDEX BY BINARY_INTEGER;
TYPE enddateTAB IS TABLE OF DATE INDEX BY BINARY_INTEGER;

l_itemtypeTAB itemtypeTAB;
l_itemkeyTAB  itemkeyTAB;
l_enddateTAB  enddateTAB;

procedure Move_To_History(
  itemtype in varchar2 default null,
  itemkey in varchar2 default null);

-- procedure Item_Activity_Statuses
--   Delete from wf_item_activity_statuses and wf_item_activity_statuses_h
--   where end_date before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--
procedure Item_Activity_Statuses(
  itemtype in varchar2 default null,
  itemkey in varchar2 default null,
  enddate in date default sysdate);

--
-- procedure Items
--   Delete items with end_time before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--   docommit- Do not commit if set to false
--   force - delete child records even if parent is not end dated
--   purgesigs- Do not delete digitally signed notifications if not set to 1
--
/*#
 * Deletes all runtime data associated with completed
 * items for the specified item type, item key, and
 * end date, including process status information and
 * notifications associated with those items.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param enddate End Date
 * @param docommit Commit Data
 * @param force Force Purge of Child Items
 * @param purgesigs Purge Digitally Signed Notifications
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Purge Items
 * @rep:ihelp FND/@wfpurge#a_items See the related online help
 */

procedure Items(
  itemtype in varchar2 default null,
  itemkey in varchar2 default null,
  enddate in date default sysdate,
  docommit in boolean default true,
  force in boolean default false,
  purgesigs in pls_integer default null);

--
-- procedure Activities
--   Delete old activity versions with end_time before argument,
--   and that are not referenced by an existing item.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   name - Activity to delete, or null for all activities
--   enddate - Date to obsolete to
-- NOTE:
--   It is recommended to purge Items before purging Activities to avoid
--   obsolete item references preventing obsolete activities from being
--   deleted.
--
/*#
 * Deletes obsolete versions of activities that
 * are associated with the specified item type,
 * have an end date earlier than or equal to the
 * specified end date, and are not referenced by
 * an existing item as either a process or activity.
 * @param itemtype Item Type
 * @param name Activity Internal Name
 * @param enddate End Date
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Purge Activity
 * @rep:ihelp FND/@wfpurge#a_act See the related online help
 */

procedure Activities(
  itemtype in varchar2 default null,
  name in varchar2 default null,
  enddate in date default sysdate);

--
-- procedure Notifications
--   Delete old notifications with end_time before argument,
--   and that are not referenced by an existing item.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   enddate - Date to obsolete to
--   docommit- Do not commit if set to false
--   purgesigs- Do not delete digitally signed notifications if not set to 1
-- NOTE:
--   It is recommended to purge Items before purging Notifications to avoid
--   obsolete item references preventing obsolete notifications from being
--   deleted.
--
/*#
 * Deletes obsolete notifications that are associated
 * with the specified item type, have an end date earlier
 * than or equal to the specified end date,and are not
 * referenced by an existing item.
 * @param itemtype Item Type
 * @param enddate End Date
 * @param docommit Commit Data
 * @param purgesigs Purge Digitally Signed Notifications
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Purge Notifications
 * @rep:ihelp FND/@wfpurge#a_notif See the related online help
 */

procedure Notifications(
  itemtype in varchar2 default null,
  enddate in date default sysdate,
  docommit in boolean default true,
  purgesigs in pls_integer default null);

--
-- procedure Item_Notifications
--   Delete notifications sent by a particular item with end_time
--   before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--   docommit- Do not commit if set to false
--
procedure Item_Notifications(
  itemtype in varchar2 default null,
  itemkey in varchar2 default null,
  enddate in date default sysdate,
  docommit in boolean default true);

--
-- Total
--   Delete all obsolete runtime data with end_time before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--   docommit- Commit or no commit after each purge of entitiy
--   runtimeonly - Delete runtime data alone if set to true
--             else delete both design and runtime data
--   purgesigs- Do not delete digitally signed notifications if not set to 1
--
/*#
 * Deletes all runtime data associated with
 * completed items for the specified item type,
 * item key, and XML Gateway transaction type
 * and subtype,with an end date earlier than or
 * equal to the specified end date. By default,
 * the procedure also purges expired ad hoc users
 * and roles, obsolete activity versions, and obsolete
 * runtime data for notifications and XML Gateway
 * transactions that are not associated with a work item.
 * You can optionally restrict the procedure to purge
 * only runtime data associated with work items.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param enddate End Date
 * @param docommit Commit Data
 * @param runtimeonly Purge Work Item Data Only
 * @param purgesigs Purge Digitally Signed Notifications
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Total Purge
 * @rep:ihelp FND/@wfpurge#a_total See the related online help
 */

procedure Total(
  itemtype in varchar2 default null,
  itemkey in varchar2 default null,
  enddate in date default sysdate,
  docommit in boolean default true,
  runtimeonly  in boolean default null,
  purgesigs in pls_integer default null,
  purgeCacheData in boolean default false
);

-- procedure entity_changes
--   Purges data from table WF_ENTITY_CHANGES as per the AGE parameter passed
--   to concurrent program FNDWFPRG. Introduced as per bug 9394309
-- IN: enddate - anything before this date is to be removed
--
procedure entity_changes(p_enddate date);

--
-- TotalPERM
--   Delete all obsolete runtime data that is of persistence type 'PERM'
--   and with end_time before argument.
-- IN:
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   enddate - Date to obsolete to
--   docommit- Commit or no commit after each purge of entitiy
--   runtimeonly - Delete runtime data alone if set to true
--                 else delete both design and runtime data
--   purgesigs- Do not delete digitally signed notifications if not set to 1
--
--
/*#
 * Deletes all runtime data associated with
 * completed items for the specified item type
 * and item key that have a persistence type of
 * Permanent ('PERM') and an end date earlier
 * than or equal to the specified end date. By
 * default, the procedure also purges expired
 * ad hoc users and roles, obsolete activity versions,
 * and obsolete runtime data for notifications and XML
 * Gateway transactions that are not associated with
 * a work item. You can optionally restrict the procedure
 * to purge only runtime data associated with work items.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param enddate End Date
 * @param docommit Commit Data
 * @param runtimeonly Purge Work Item Data Only
 * @param purgesigs Purge Digitally Signed Notifications
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Total Purge
 * @rep:ihelp FND/@wfpurge#a_totprm See the related online help
 */

procedure TotalPERM(
  itemtype in varchar2 default null,
  itemkey in varchar2 default null,
  enddate in date default sysdate,
  docommit in boolean default true,
  runtimeonly in boolean default null,
  purgesigs in pls_integer default null);

--
-- TotalConcurrent
--   Concurrent Program version of Total
-- IN:
--   errbuf - CPM error message
--   retcode - CPM return code (0 = success, 1 = warning, 2 = error)
--   itemtype - Item type to delete, or null for all itemtypes
--   itemkey - Item key to delete, or null for all itemkeys
--   age - Minimum age of data to purge (in days)
--   x_persistence_type - Persistence Type to be purged: 'TEMP' or 'PERM'
--   purgesigs- Do not delete digitally signed notifications if not set to Y
--
procedure TotalConcurrent(
  errbuf out NOCOPY varchar2,
  retcode out NOCOPY varchar2,
  itemtype in varchar2 default null,
  itemkey in varchar2 default null,
  age in varchar2 default '0',
  x_persistence_type in varchar2 default 'TEMP',
  runtimeonly  in varchar2 default 'N',
  x_commit_frequency in number default 500,
  purgesigs in varchar2 default null,
  purgeCacheData in varchar2 default null
  );

--
-- Directory
--   Purge all WF_LOCAL_* tables based on expiration date
-- IN:
--   end_date - Date to purge to
--
/*#
 * Purges all users and roles in the Workflow
 * local directory service tables whose expiration
 * date is earlier than or equal to the specified
 * end date and that are not referenced in
 * any notification. If parameter autocommit is passed
 * the DML operations will be commited every certain
 * number fo rows.
 * @param end_date End Date
 * @param orig_system Originating System
 * @param autocommit Auto commit
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Purge Roles
 * @rep:ihelp FND/@wfpurge#a_prgdir See the related online help
 */

procedure Directory(
  end_date in date default sysdate,
  orig_system in varchar2 default null,
  autocommit in boolean default false);

--
-- AdHocDirectory
--   Purge all WF_LOCAL_* tables based on expiration date
--   Call procedure Directory instead
-- IN:
--   end_date - Date to purge to
--
procedure AdHocDirectory(
  end_date in date default sysdate);


 --
 -- GetPurgeableCount
 --   Returns the count of purgeable items for a specific itemType.
 -- IN:
 --   p_itemType  in VARCHAR2
 --
 function GetPurgeableCount (p_itemType in varchar2) return number;

 --
 -- AbortErrorProcess
 -- Abort the WFERROR process if activity is COMPLETE
 -- IN:
 -- itemtype - Item type to move, or null for all itemtypes
 --   itemkey - Item key to move, or null for all itemkeys
 procedure AbortErrorProcess(itemtype in varchar2 default null,
                            itemkey in varchar2 default null);



end WF_PURGE;

/
