--------------------------------------------------------
--  DDL for Package FND_WF_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_WF_ENGINE" AUTHID CURRENT_USER as
/* $Header: afwfengs.pls 120.1.12010000.2 2009/08/19 15:36:09 ctilley ship $ */


--
-- Constant values
--
threshold number := 50;    -- Cost over which to defer activities
debug boolean := FALSE;    -- Run engine in debug or normal mode

-- Standard date format string.  Used to convert dates to strings
-- when returning date values as activity function results.
date_format varchar2(30) := 'YYYY/MM/DD HH24:MI:SS';

-- Set_Context context
--   Process for which set_context function has been called
setctx_itemtype varchar2(8) := '';  -- Current itemtype
setctx_itemkey varchar2(240) := ''; -- Current itemkey

-- Post-Notification Function Context areas
--   Used to pass information to callback functions
context_nid number := '';          -- Notification id (if applicable)
context_text varchar2(2000) := ''; -- Text information

-- Activity types
eng_process         varchar2(8) := 'PROCESS';  -- Process type activity
eng_function        varchar2(8) := 'FUNCTION'; -- Function type activity
eng_notification    varchar2(8) := 'NOTICE';   -- Notification type activity

-- Item activity statuses
eng_completed       varchar2(8) := 'COMPLETE'; -- Normal completion
eng_active          varchar2(8) := 'ACTIVE';   -- Activity running
eng_waiting         varchar2(8) := 'WAITING';  -- Activity waiting to run
eng_notified        varchar2(8) := 'NOTIFIED'; -- Notification open
eng_suspended       varchar2(8) := 'SUSPEND';  -- Activity suspended
eng_deferred        varchar2(8) := 'DEFERRED'; -- Activity deferred
eng_error           varchar2(8) := 'ERROR';    -- Completed with error

-- Standard activity result codes
eng_exception       varchar2(30) := '#EXCEPTION'; -- Unhandled exception
eng_timedout        varchar2(30) := '#TIMEOUT';   -- Activity timed out
eng_stuck           varchar2(30) := '#STUCK';     -- Stuck process
eng_force           varchar2(30) := '#FORCE';     -- Forced completion
eng_noresult        varchar2(30) := '#NORESULT';  -- No result for activity
eng_mail            varchar2(30) := '#MAIL';      -- Notification mail error
eng_null            varchar2(30) := '#NULL';      -- Noop result
eng_nomatch         varchar2(30) := '#NOMATCH';   -- Voting no winner
eng_tie             varchar2(30) := '#TIE';       -- Voting tie

-- Activity loop reset values
eng_reset           varchar2(8) := 'RESET';  -- Loop with cancelling
eng_ignore          varchar2(8) := 'IGNORE'; -- Do not reset activity
eng_loop            varchar2(8) := 'LOOP';   -- Loop without cancelling

-- Start/end activity flags
eng_start           varchar2(8) := 'START'; -- Start activity
eng_end             varchar2(8) := 'END';   -- End activity

-- Function activity modes
eng_run             varchar2(8) := 'RUN';      -- Run mode
eng_cancel          varchar2(8) := 'CANCEL';   -- Cancel mode
eng_timeout         varchar2(8) := 'TIMEOUT';  -- Timeout mode
eng_setctx          varchar2(8) := 'SET_CTX';  -- Selector set context mode
eng_testctx         varchar2(8) := 'TEST_CTX'; -- Selector test context mode

-- HandleError command modes
eng_retry           varchar2(8) := 'RETRY'; -- Retry errored activity
eng_skip            varchar2(8) := 'SKIP';  -- Skip errored activity

eng_wferror         varchar2(8) := 'WFERROR'; -- Error process itemtype

-- Monitor access key names
wfmon_mon_key       varchar2(30) := '.MONITOR_KEY'; -- Read-only monitor key
wfmon_acc_key       varchar2(30) := '.ADMIN_KEY';  -- Admin monitor key

-- Special activity attribute names
eng_priority         varchar2(30) := '#PRIORITY'; -- Priority override
eng_timeout_attr     varchar2(30) := '#TIMEOUT'; -- Priority override

-- Standard activity transitions
eng_trans_default    varchar2(30) := '*';
eng_trans_any        varchar2(30) := '#ANY';

-- Applications context flag
-- By default we want context to be preserved.
preserved_context    boolean      := TRUE;

--
-- Synch mode
--   NOTE: Synch mode is only to be used for in-line processes that are
--   run to completion and purged within one session.  Some process data
--   is never saved to the database, so the monitor, reports, any external
--   access to workflow tables, etc, will not work.
--
--   This mode is enabled by setting the user_key of the item to
--   FND_WF_ENGINE.eng_synch.
--
--   *** Do NOT enable this mode unless you are sure you understand
--   *** the implications!
--
synch_mode boolean := FALSE; -- *** OBSOLETE! DO NOT USE! ***

eng_synch varchar2(8) := '#SYNCH';




--
-- AddItemAttr (PUBLIC)
--   Add a new unvalidated run-time item attribute.
-- IN:
--   itemtype - item type
--   itemkey - item key
--   aname - attribute name
--   text_value   - add text value to it if provided.
--   number_value - add number value to it if provided.
--   date_value   - add date value to it if provided.
-- NOTE:
--   The new attribute has no type associated.  Get/set usages of the
--   attribute must insure type consistency.
--
procedure AddItemAttr(itemtype in varchar2,
                      itemkey in varchar2,
                      aname in varchar2,
                      text_value   in varchar2 default null,
                      number_value in number   default null,
                      date_value   in date     default null);


--
-- SetItemAttrText (PUBLIC)
--   Set the value of a text item attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   text-string value to a number/date using attribute format.
--   For all other types, store the value directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetItemAttrText(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in varchar2);

--
-- SetItemAttrNumber (PUBLIC)
--   Set the value of a number item attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetItemAttrNumber(itemtype in varchar2,
                            itemkey in varchar2,
                            aname in varchar2,
                            avalue in number);

--
-- SetItemAttrDate (PUBLIC)
--   Set the value of a date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetItemAttrDate(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in date);

--
-- SetItemAttrDocument (PUBLIC)
--   Set the value of a document item attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
--   documentid - Document Identifier - full concatenated document attribute
--                strings:
--                nodeid:libraryid:documentid:version:document_name
--
procedure SetItemAttrDocument(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2,
                              documentid in varchar2);


--
-- Getitemattrinfo (PUBLIC)
--   Get type information about a item attribute.
-- IN:
--   itemtype - Item type
--   aname - Attribute name
-- OUT:
--   atype  - Attribute type
--   subtype - 'SEND' or 'RESPOND'
--   format - Attribute format
--
procedure GetItemAttrInfo(itemtype in varchar2,
                          aname in varchar2,
                          atype out NOCOPY varchar2,
                          subtype out NOCOPY varchar2,
                          format out NOCOPY varchar2);

--
-- GetItemAttrText (PUBLIC)
--   Get the value of a text item attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   number/date value to a text-string representation using attrbute format.
--   For all other types, get the value directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetItemAttrText(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2)
return varchar2;

--
-- GetItemAttrNumber (PUBLIC)
--   Get the value of a number item attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetItemAttrNumber(itemtype in varchar2,
                           itemkey in varchar2,
                           aname in varchar2)
return number;

--
-- GetItemAttrDate (PUBLIC)
--   Get the value of a date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   nid - Item id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetItemAttrDate (itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2)
return date;

--
-- GetItemAttrDocument (PUBLIC)
--   Get the value of a document item attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
-- RETURNS:
--   documentid - Document Identifier - full concatenated document attribute
--                strings:
--                nodeid:libraryid:documentid:version:document_name
--
--
--
Function GetItemAttrDocument(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2) RETURN VARCHAR2;


--
-- GetActivityAttrInfo (PUBLIC)
--   Get type information about an activity attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute name
-- OUT:
--   atype  - Attribute type
--   subtype - 'SEND' or 'RESPOND',
--   format - Attribute format
--
procedure GetActivityAttrInfo(itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              aname in varchar2,
                              atype out NOCOPY varchar2,
                              subtype out NOCOPY varchar2,
                              format out NOCOPY varchar2);

--
-- GetActivityAttrText (PUBLIC)
--   Get the value of a text item attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   number/date value to a text-string representation using attrbute format.
--   For all other types, get the value directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetActivityAttrText(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2)
return varchar2;

--
-- GetActivityAttrNumber (PUBLIC)
--   Get the value of a number item attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetActivityAttrNumber(itemtype in varchar2,
                               itemkey in varchar2,
                               actid in number,
                               aname in varchar2)
return number;

--
-- GetActivityAttrDate (PUBLIC)
--   Get the value of a date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   actid - Process activity id
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetActivityAttrDate(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2)
return date;

--
-- Set_Item_Parent (PUBLIC)
-- *** OBSOLETE - Use SetItemParent instead ***
--
procedure Set_Item_Parent(itemtype in varchar2,
  itemkey in varchar2,
  parent_itemtype in varchar2,
  parent_itemkey in varchar2,
  parent_context in varchar2);

--
-- SetItemParent (PUBLIC)
--   Set the parent info of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   parent_itemtype - Itemtype of parent
--   parent_itemkey - Itemkey of parent
--   parent_context - Context info about parent
--
procedure SetItemParent(itemtype in varchar2,
  itemkey in varchar2,
  parent_itemtype in varchar2,
  parent_itemkey in varchar2,
  parent_context in varchar2);

--
-- SetItemOwner (PUBLIC)
--   Set the owner of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   owner - Role designated as owner of the item
--
procedure SetItemOwner(itemtype in varchar2,
                       itemkey in varchar2,
                       owner in varchar2);

--
-- GetItemUserKey (PUBLIC)
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

--
-- SetItemUserKey (PUBLIC)
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
-- GetActivityLabel (PUBLIC)
--  Get activity instance label given id, in a format
--  suitable for passing to other wf_engine apis.
-- IN
--   actid - activity instance id
-- RETURNS
--   <process_name>||':'||<instance_label>
--
function GetActivityLabel(
  actid in number)
return varchar2;

--
-- CB (PUBLIC)
--   This is the callback function used by the notification system to
--   get and set process attributes, and mark a process complete.
--
--   The command may be one of 'GET', 'SET', 'COMPLETE', or 'ERROR'.
--     GET - Get the value of an attribute
--     SET - Set the value of an attribute
--     COMPLETE - Mark the activity as complete
--     ERROR - Mark the activity as error status
--     TESTCTX - Test current context via selector function
--     FORWARD - Execute notification function for FORWARD
--     TRANSFER - Execute notification function for TRANSFER
--     RESPOND - Execute notification function for RESPOND
--
--   The context is in the format <itemtype>:<itemkey>:<activityid>.
--
--   The text_value/number_value/date_value fields are mutually exclusive.
--   It is assumed that only one will be used, depending on the value of
--   the attr_type argument ('VARCHAR2', 'NUMBER', or 'DATE').
--
-- IN:
--   command - Action requested.  Must be one of 'GET', 'SET', or 'COMPLETE'.
--   context - Context data in the form '<item_type>:<item_key>:<activity>'
--   attr_name - Attribute name to set/get for 'GET' or 'SET'
--   attr_type - Attribute type for 'SET'
--   text_value - Text Attribute value for 'SET'
--   number_value - Number Attribute value for 'SET'
--   date_value - Date Attribute value for 'SET'
-- OUT:
--   text_value - Text Attribute value for 'GET'
--   number_value - Number Attribute value for 'GET'
--   date_value - Date Attribute value for 'GET'
--
procedure CB(command in varchar2,
             context in varchar2,
             attr_name in varchar2 default null,
             attr_type in varchar2 default null,
             text_value in out NOCOPY varchar2,
             number_value in out NOCOPY number,
             date_value in out NOCOPY date);

--
-- ProcessDeferred (PUBLIC)
--   Process one deferred activity.
-- IN
--   itemtype - Item type to process.  If null process all item types.
--   minthreshold - Minimum cost activity to process. No minimum if null.
--   maxthreshold - Maximum cost activity to process. No maximum if null.
--
procedure ProcessDeferred(itemtype in varchar2 default null,
                          minthreshold in number default null,
                          maxthreshold in number default null);

--
-- ProcessTimeout (PUBLIC)
--  Pick up one timed out activity and execute timeout transition.
-- IN
--  itemtype - Item type to process.  If null process all item types.
--
procedure ProcessTimeOut( itemtype in varchar2 default null );

--
-- ProcessStuckProcess (PUBLIC)
--   Pick up one stuck process, mark error status, and execute error process.
-- IN
--   itemtype - Item type to process.  If null process all item types.
--
procedure ProcessStuckProcess(itemtype in varchar2 default null);

--
-- Background (PUBLIC)
--  Process all current deferred and/or timeout activities within
--  threshold limits.
-- IN
--   itemtype - Item type to process.  If null process all item types.
--   minthreshold - Minimum cost activity to process. No minimum if null.
--   maxthreshold - Maximum cost activity to process. No maximum if null.
--   process_deferred - Run deferred or waiting processes
--   process_timeout - Handle timeout and stuck process errors
--
procedure Background (itemtype         in varchar2 default '',
                      minthreshold     in number default null,
                      maxthreshold     in number default null,
                      process_deferred in boolean default TRUE,
                      process_timeout  in boolean default TRUE);

--
-- BackgroundConcurrent (PUBLIC)
--  Run background process for deferred and/or timeout activities
--  from Concurrent Manager.
--  This is a cover of Background() with different argument types to
--  be used by the Concurrent Manager.
-- IN
--   errbuf - CPM error message
--   retcode - CPM return code (0 = success, 1 = warning, 2 = error)
--   itemtype - Item type to process.  If null process all item types.
--   minthreshold - Minimum cost activity to process. No minimum if null.
--   maxthreshold - Maximum cost activity to process. No maximum if null.
--   process_deferred - Run deferred or waiting processes
--   process_timeout - Handle timeout errors
--
procedure BackgroundConcurrent (
    errbuf out NOCOPY varchar2,
    retcode out NOCOPY varchar2,
    itemtype in varchar2 default '',
    minthreshold in varchar2 default '',
    maxthreshold in varchar2 default '',
    process_deferred in varchar2 default 'Y',
    process_timeout in varchar2 default 'Y');

--
-- CreateProcess (PUBLIC)
--   Create a new runtime process (for an application item).
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--   process  - A valid root process for this item type
--              (or null to use the item's selector function)
--
procedure CreateProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2 default '');

--
-- StartProcess (PUBLIC)
--   Begins execution of the process. The process will be identified by the
--   itemtype and itemkey.  The engine locates the starting activities
--   of the root process and executes them.
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--
procedure StartProcess(itemtype in varchar2,
                       itemkey  in varchar2);


--
-- LaunchProcess (PUBLIC)
--   Launch a process both creates and starts it.
--   This is a wrapper for friendlier UI
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--   process  - A valid root process for this item type
--              (or null to use the item's selector function)
--   userkey - User key to be set
--   owner - Role designated as owner of the item
--
procedure LaunchProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2 default '',
                        userkey  in varchar2 default '',
                        owner    in varchar2 default '');



--
-- SuspendProcess (PUBLIC)
--   Suspends process execution, meaning no new transitions will occur.
--   Outstanding notifications will be allowed to complete, but they will not
--   cause activity transitions. If the process argument is null, the root
--   process for the item is suspended, otherwise the named process is
--   suspended.
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--   process  - Process to suspend, specified in the form
--              [<parent process_name>:]<process instance_label>
--              If null suspend the root process.
--
procedure SuspendProcess(itemtype in varchar2,
                         itemkey  in varchar2,
                         process  in varchar2 default '');

--
-- AbortProcess (PUBLIC)
--   Abort process execution. Outstanding notifications are canceled. The
--   process is then considered complete, with a status specified by the
--   result argument.
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--   process  - Process to abort, specified in the form
--              [<parent process_name>:]<process instance_label>
--              If null abort the root process.
--   result   - Result to complete process with
--
procedure AbortProcess(itemtype in varchar2,
                       itemkey  in varchar2,
                       process  in varchar2 default '',
                       result   in varchar2 default '#FORCE');

--
-- ResumeProcess (PUBLIC)
--   Returns a process to normal execution status. Any transitions which
--   were deferred by SuspendProcess() will now be processed.
-- IN
--   itemtype   - A valid item type
--   itemkey    - A string generated from the application object's primary key.
--   process  - Process to resume, specified in the form
--              [<parent process_name>:]<process instance_label>
--              If null resume the root process.
--
procedure ResumeProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2 default '');


--
-- CreateForkProcess (PUBLIC)
--   Performs equivalent of createprocess but for a forked process
--   and copies all item attributes
--   If same version is false, this is same as CreateProcess but copies
--   item attributes as well.
-- IN
--   copy_itemtype  - Item type
--   copy_itemkey   - item key to copy (will be stored to an item attribute)
--   new_itemkey    - item key to create
--   same_version   - TRUE will use same version even if out of date.
--                    FALSE will use the active and current version
Procedure CreateForkProcess (
     copy_itemtype  in varchar2,
     copy_itemkey   in varchar2,
     new_itemkey      in varchar2,
     same_version      in boolean default TRUE);
--
-- StartForkProcess (PUBLIC)
--   Start a process that has been forked. Depending on the way this was forked,


--   this will execute startprocess if its to start with the latest version or
--   it copies the forked process activty by activity.
-- IN
--   itemtype  - Item type
--   itemkey   - item key to start
--
procedure StartForkProcess(
     itemtype        in  varchar2,
     itemkey         in  varchar2);
--
-- BeginActivity (PUBLIC)
--   Determines if the specified activity may currently be performed on the
--   work item. This is a test that the performer may proactively determine
--   that their intent to perform an activity on an item is, in fact, allowed.
-- IN
--   itemtype  - A valid item type
--   itemkey   - A string generated from the application object's primary key.
--   activity  - Completed activity, specified in the form
--               [<parent process_name>:]<process instance_label>
--
procedure BeginActivity(itemtype in varchar2,
                        itemkey  in varchar2,
                        activity in varchar2);

--
-- CompleteActivity (PUBLIC)
--   Notifies the workflow engine that an activity has been completed for a
--   particular process(item). This procedure can have one or more of the
--   following effects:
--   o Creates a new item. If the completed activity is the start of a process,
--     then a new item can be created by this call. If the completed activity
--     is not the start of a process, it would be an invalid activity error.
--   o Complete an activity with an optional result. This signals the
--     workflow engine that an asynchronous activity has been completed.
--     An optional activity completion result can also be passed.
-- IN
--   itemtype  - A valid item type
--   itemkey   - A string generated from the application object's primary key.
--   activity  - Completed activity, specified in the form
--               [<parent process_name>:]<process instance_label>
--   <result>  - An optional result.
--
procedure CompleteActivity(itemtype in varchar2,
                           itemkey  in varchar2,
                           activity in varchar2,
                           result   in varchar2);

--
-- CompleteActivityInternalName (PUBLIC)
--   Identical to CompleteActivity, except that the internal name of
--   completed activity is passed instead of the activity instance label.
-- NOTES:
-- 1. There must be exactly ONE instance of this activity with NOTIFIED
--    status.
-- 2. Using this api to start a new process is not supported.
-- 3. Synchronous processes are not supported in this api.
-- 4. This should only be used if for some reason the instance label is
--    not known.  CompleteActivity should be used if the instance
--    label is known.
-- IN
--   itemtype  - A valid item type
--   itemkey   - A string generated from the application object's primary key.
--   activity  - Internal name of completed activity, in the format
--               [<parent process_name>:]<process activity_name>
--   <result>  - An optional result.
--
procedure CompleteActivityInternalName(
  itemtype in varchar2,
  itemkey  in varchar2,
  activity in varchar2,
  result   in varchar2);

--
-- AssignActivity (PUBLIC)
--   Assigns or re-assigns the user who will perform an activity. It may be
--   called before the activity has been enabled(transitioned to). If a user
--   is assigned to an activity that already has an outstanding notification,
--   that notification will be canceled and a new notification will be
--   generated for the new user.
-- IN
--   itemtype  - A valid item type
--   itemkey   - A string generated from the application object's primary key.
--   activity  - Activity to assign, specified in the form
--               [<parent process_name>:]<process instance_label>
--   performer - User who will perform this activity.
--
procedure AssignActivity(itemtype in varchar2,
                         itemkey  in varchar2,
                         activity in varchar2,
                         performer in varchar2);

--
-- HandleError (PUBLIC)
--   Reset the process thread to given activity and begin execution
-- again from that point.  If command is:
--     SKIP - mark the activity complete with given result and continue
--     RETRY - re-execute the activity before continuing
-- IN
--   itemtype  - A valid item type.
--   itemkey   - The item key of the process.
--   activity  - Activity to reset, specified in the form
--               [<parent process_name>:]<process instance_label>
--   command   - SKIP or RETRY.
--   <result>  - Activity result for the "SKIP" command.
--
procedure HandleError(itemtype in varchar2,
                      itemkey  in varchar2,
                      activity in varchar2,
                      command  in varchar2,
                      result   in varchar2 default '');

procedure ItemStatus(itemtype in varchar2,
                     itemkey  in varchar2,
                     status   out NOCOPY varchar2,
                     result   out NOCOPY varchar2);

--
-- Activity_Exist_In_Process
--   Check if an activity exist in a process
-- IN
--   p_item_type
--   p_item_key
--   p_activity_item_type
--   p_anctivity_name
-- RET
--   TRUE if activity exist, FALSE otherwise
--
function Activity_Exist_In_Process (
  p_item_type          in  varchar2,
  p_item_key           in  varchar2,
  p_activity_item_type in  varchar2 default null,
  p_activity_name      in  varchar2)
return boolean;

--
-- Activity_Exist
--   Check if an activity exist in a process
-- IN
--   p_process_item_type
--   p_process_name
--   p_activity_item_type
--   p_anctivity_name
--   active_date
--   iteration  - maximum 8 level deep (0-7)
-- RET
--   TRUE if activity exist, FALSE otherwise
--
function Activity_Exist (
  p_process_item_type  in  varchar2,
  p_process_name       in  varchar2,
  p_activity_item_type in  varchar2 default null,
  p_activity_name      in  varchar2,
  active_date          in  date default sysdate,
  iteration            in  number default 0)
return boolean;

--
-- user_synch
--   Wrapper for fnd_user_pkg.user_synch()
-- IN
--   p_user_name
--
procedure user_synch (p_user_name  in  varchar2);

--
-- default_event_raise
--   Wrapper for wf_event.raise()
-- IN
--   p_event_name
--   p_event_key
--
procedure default_event_raise(p_event_name  in  varchar2,
                              p_event_key   in  varchar2);

--
-- propagate_user_role
--   Wrapper for wf_local_synch.propagate_user_role()
-- IN
--   p_user_orig_system
--   p_user_orig_system_id
--   p_role_orig_system
--   p_role_orig_system_id
--   p_start_date
--   p_expiration_date
--
procedure propagate_user_role(p_user_orig_system      in varchar2,
                              p_user_orig_system_id   in number,
                              p_role_orig_system      in varchar2,
                              p_role_orig_system_id   in number,
                              p_start_date            in date default null,
                              p_expiration_date       in date default null);

--
--
-- This function is called from the sign-on form FNDSCSGN.fmb
--
--
function DisableOrLaunch(l_item_type in varchar2,
                         l_itemkey   in varchar2,
                         c_instid    in varchar2,
                         l_username  in varchar2,
                         l_name      in varchar2)
return number;

--
-- SetItemAttrTextAuto (PUBLIC)
--   Set the value of a text item attribute. - Autonomously. Needed for ERES
--   If the attribute is a NUMBER or DATE type, then translate the
--   text-string value to a number/date using attribute format.
--   For all other types, store the value directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
--   avalue - New value for attribute
--
procedure SetItemAttrTextAuto(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in varchar2);

--
-- AbortProcessAuto (PUBLIC)
--   Abort process execution. - Autonomously. Needed for ERES.
--   Outstanding notifications are canceled. The process is then considered
--   complete, with a status specified by the result argument.
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--   process  - Process to abort, specified in the form
--              [<parent process_name>:]<process instance_label>
--              If null abort the root process.
--   result   - Result to complete process with
--
procedure AbortProcessAuto(itemtype in varchar2,
                       itemkey  in varchar2,
                       process  in varchar2 default '',
                       result   in varchar2 default '#FORCE');

/*
** Wrapper to propaget_user_role this has the additional signature
** changes of wf_local_synch propagate_user_role
** propagate_user_role - Synchronizes the WF_LOCAL_USER_ROLES table and
**                       updates the entity mgr if appropriate
*/
PROCEDURE propagate_user_role2(p_user_orig_system      in varchar2,
                              p_user_orig_system_id   in number,
                              p_role_orig_system      in varchar2,
                              p_role_orig_system_id   in number,
                              p_start_date            in date default null,
                              p_expiration_date       in date default null,
                              p_overwrite             in boolean default FALSE,
                              p_raiseErrors           in boolean default FALSE);

--
-- event_raise_params
--   Wrapper for wf_event.raise() passing all parameters
-- IN
--   p_event_name
--   p_event_key
--
procedure event_raise_params(p_event_name  in  varchar2,
                             p_event_key   in  varchar2,
                p_event_data       in clob default NULL,
                p_parameter_name1  in varchar2 default NULL,
                p_parameter_value1 in varchar2 default null,
                p_parameter_name2  in varchar2 default NULL,
                p_parameter_value2 in varchar2 default NULL,
                p_parameter_name3  in varchar2 default NULL,
                p_parameter_value3 in varchar2 default NULL,
                p_parameter_name4  in varchar2 default NULL,
                p_parameter_value4 in varchar2 default NULL,
                p_parameter_name5  in varchar2 default NULL,
                p_parameter_value5 in varchar2 default NULL,
                p_parameter_name6  in varchar2 default NULL,
                p_parameter_value6 in varchar2 default NULL,
                p_parameter_name7  in varchar2 default NULL,
                p_parameter_value7 in varchar2 default NULL,
                p_parameter_name8  in varchar2 default NULL,
                p_parameter_value8 in varchar2 default NULL,
                p_parameter_name9  in varchar2 default NULL,
                p_parameter_value9 in varchar2 default NULL,
                p_parameter_name10  in varchar2 default NULL,
                p_parameter_value10 in varchar2 default NULL,
                p_parameter_name11  in varchar2 default NULL,
                p_parameter_value11 in varchar2 default NULL,
                p_parameter_name12  in varchar2 default NULL,
                p_parameter_value12 in varchar2 default NULL,
                p_parameter_name13  in varchar2 default NULL,
                p_parameter_value13 in varchar2 default NULL,
                p_parameter_name14  in varchar2 default NULL,
                p_parameter_value14 in varchar2 default NULL,
                p_parameter_name15  in varchar2 default NULL,
                p_parameter_value15 in varchar2 default NULL,
                p_parameter_name16  in varchar2 default NULL,
                p_parameter_value16 in varchar2 default NULL,
                p_parameter_name17  in varchar2 default NULL,
                p_parameter_value17 in varchar2 default NULL,
                p_parameter_name18  in varchar2 default NULL,
                p_parameter_value18 in varchar2 default NULL,
                p_parameter_name19  in varchar2 default NULL,
                p_parameter_value19 in varchar2 default NULL,
                p_parameter_name20  in varchar2 default NULL,
                p_parameter_value20 in varchar2 default NULL,
                p_send_date   in date);


END FND_WF_ENGINE;

/
