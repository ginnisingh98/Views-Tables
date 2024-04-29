--------------------------------------------------------
--  DDL for Package Body FND_WF_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FND_WF_ENGINE" as
/* $Header: afwfengb.pls 120.1.12010000.2 2009/08/19 15:37:38 ctilley ship $ */




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
                      text_value   in varchar2,
                      number_value in number,
                      date_value   in date)
is
begin
   wf_engine.AddItemAttr(itemtype,
                         itemkey,
                         aname,
                         text_value,
                         number_value,
                         date_value);
end AddItemAttr;



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
                          avalue in varchar2)
is

begin
   wf_engine.SetItemAttrText(itemtype,
                             itemkey,
                             aname,
                             avalue);
end SetItemAttrText;

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
                            avalue in number)
is
begin
  wf_engine.SetItemAttrNumber(itemtype,
                              itemkey,
                              aname,
                              avalue);
end SetItemAttrNumber;

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
                          avalue in date)
is
begin
 wf_engine.SetItemAttrDate(itemtype,
                           itemkey,
                           aname,
                           avalue);

end SetItemAttrDate;

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
--
procedure SetItemAttrDocument(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2,
                              documentid in varchar2)
is
begin
   wf_engine.SetItemAttrDocument(itemtype,
                                 itemkey,
                                 aname,
                                 documentid);
end SetItemAttrDocument;


--
-- GetItemAttrInfo (PUBLIC)
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
                          format out NOCOPY varchar2)
is
begin
   wf_engine.GetItemAttrInfo(itemtype,
                             aname,
                             atype,
                             subtype,
                             format);
end GetItemAttrInfo;

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
return varchar2 is
  lvalue varchar2(4000);
begin
   lvalue := wf_engine.GetItemAttrText(itemtype,
                                       itemkey,
                                       aname);
   return lvalue;
end GetItemAttrText;

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
return number is
  lvalue number;
begin
  lvalue := wf_engine.GetItemAttrNumber(itemtype,
                                        itemkey,
                                        aname);
  return lvalue;
end GetItemAttrNumber;

--
-- GetItemAttrDate (PUBLIC)
--   Get the value of a date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Attribute Name
-- RETURNS:
--   Attribute value
--
function GetItemAttrDate (itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2)
return date is
  lvalue date;
begin
  lvalue := wf_engine.GetItemAttrDate(itemtype,
                                      itemkey,
                                      aname);
end GetItemAttrDate;

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
Function GetItemAttrDocument(itemtype in varchar2,
                             itemkey in varchar2,
                             aname in varchar2) RETURN VARCHAR2 IS

  lvalue varchar2(4000);
begin
  lvalue := wf_engine.GetItemAttrDocument(itemtype,
                                          itemkey,
                                          aname);
  return lvalue;
end GetItemAttrDocument;

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
--   subtype - 'SEND' or 'RESPOND'
--   format - Attribute format
--
procedure GetActivityAttrInfo(itemtype in varchar2,
                              itemkey in varchar2,
                              actid in number,
                              aname in varchar2,
                              atype out NOCOPY varchar2,
                              subtype out NOCOPY varchar2,
                              format out NOCOPY varchar2)
is
  actdate date;
begin
   wf_engine.GetActivityAttrInfo(itemtype,
                                 itemkey,
                                 actid,
                                 aname,
                                 atype,
                                 subtype,
                                 format);
end GetActivityAttrInfo;


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
return varchar2 is
  lvalue varchar2(4000);
begin
  lvalue := wf_engine.GetActivityAttrText(itemtype,
                                          itemkey,
                                          actid,
                                          aname);
  return lvalue;
end GetActivityAttrText;

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
return number is
  lvalue number;
begin
  lvalue := wf_engine.GetActivityAttrNumber(itemtype,
                                            itemkey,
                                            actid,
                                            aname);
  return lvalue;
end GetActivityAttrNumber;

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
return date is
  lvalue date;
begin
  lvalue := wf_engine.GetActivityAttrDate(itemtype,
                                          itemkey,
                                          actid,
                                          aname);
  return lvalue;
end GetActivityAttrDate;

--
-- Set_Item_Parent (PUBLIC)
-- *** OBSOLETE - Use SetItemParent instead ***
--
procedure Set_Item_Parent(itemtype in varchar2,
                          itemkey in varchar2,
                          parent_itemtype in varchar2,
                          parent_itemkey in varchar2,
                          parent_context in varchar2)
is
begin
   wf_engine.Set_Item_Parent(itemtype,
                             itemkey,
                             parent_itemtype,
                             parent_itemkey,
                             parent_context);
end Set_Item_Parent;

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
                        parent_context in varchar2)
is
begin
  wf_engine.SetItemParent(itemtype,
                          itemkey,
                          parent_itemtype,
                          parent_itemkey,
                          parent_context);
end SetItemParent;

procedure SetItemOwner(itemtype in varchar2,
                       itemkey in varchar2,
                       owner  in varchar2)
is
begin
  wf_engine.SetItemOwner(itemtype,
                         itemkey,
                         owner);
end;

--
-- GetItemUserKey (PUBLIC)
--   Get the user key of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
-- RETURNS
--   User key of the item
--
function GetItemUserKey(itemtype in varchar2,
                        itemkey in varchar2)
return varchar2 is
lvalue varchar2(4000);
begin
  lvalue := wf_engine.GetItemUserKey(itemtype,
                                     itemkey);
  return lvalue;
end GetItemUserKey;

--
-- SetItemUserKey (PUBLIC)
--   Set the user key of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   userkey - User key to be set
--
procedure SetItemUserKey(itemtype in varchar2,
                         itemkey in varchar2,
                         userkey in varchar2)
is
begin
  wf_engine.SetItemUserKey(itemtype,
                           itemkey,
                           userkey);
end SetItemUserKey;

--
-- GetActivityLabel (PUBLIC)
--  Get activity instance label given id, in a format
--  suitable for passing to other wf_engine apis.
-- IN
--   actid - activity instance id
-- RETURNS
--   <process_name>||':'||<instance_label>
--
function GetActivityLabel(actid in number)
return varchar2
is
  lvalue varchar2(62);
begin
  lvalue := wf_engine.GetActivityLabel(actid);
  return lvalue;
end GetActivityLabel;

--
-- CB (PUBLIC)
--   This is the callback function used by the notification system to
--   get and set process attributes, and mark a process complete.
--
--   The command may be one of:
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
             attr_name in varchar2,
             attr_type in varchar2,
             text_value in out NOCOPY varchar2,
             number_value in out NOCOPY number,
             date_value in out NOCOPY date)
is
begin
  wf_engine.CB(command,
               context,
               attr_name,
               attr_type,
               text_value,
               number_value,
               date_value);
end CB;

--
-- ProcessDeferred (PUBLIC)
--   Process all deferred activities
-- IN
--   itemtype - Item type to process.  If null process all item types.
--   minthreshold - Minimum cost activity to process. No minimum if null.
--   maxthreshold - Maximum cost activity to process. No maximum if null.
--
procedure ProcessDeferred(itemtype in varchar2,
                          minthreshold in number,
                          maxthreshold in number) is


begin
  wf_engine.ProcessDeferred(itemtype,
                            minthreshold,
                            maxthreshold);
end ProcessDeferred;

--
-- ProcessTimeout (PUBLIC)
--  Pick up one timed out activity and execute timeout transition.
-- IN
--  itemtype - Item type to process.  If null process all item types.
--
procedure ProcessTimeOut(itemtype in varchar2)
is
begin
  wf_engine.ProcessTimeOut(itemtype);
end ProcessTimeOut;

--
-- ProcessStuckProcess (PUBLIC)
--   Pick up one stuck process, mark error status, and execute error process.
-- IN
--   itemtype - Item type to process.  If null process all item types.
--
procedure ProcessStuckProcess(itemtype in varchar2)
is
begin
  wf_engine.ProcessStuckProcess(itemtype);
end ProcessStuckProcess;

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
procedure Background (itemtype         in varchar2,
                      minthreshold     in number,
                      maxthreshold     in number,
                      process_deferred in boolean,
                      process_timeout  in boolean)
is
begin
  wf_engine.Background(itemtype,
                       minthreshold,
                       maxthreshold,
                       process_deferred,
                       process_timeout);
end Background;

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
procedure BackgroundConcurrent (errbuf out NOCOPY varchar2,
                                retcode out NOCOPY varchar2,
                                itemtype in varchar2,
                                minthreshold in varchar2,
                                maxthreshold in varchar2,
                                process_deferred in varchar2,
                                process_timeout in varchar2)
is
begin
  wf_engine.BackgroundConcurrent(errbuf,
                                 retcode,
                                 itemtype,
                                 minthreshold,
                                 maxthreshold,
                                 process_deferred,
                                 process_timeout);
end BackgroundConcurrent;

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
                        process  in varchar2)
is
begin
  wf_engine.CreateProcess(itemtype,
                          itemkey,
                          process);
end CreateProcess;

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
                       itemkey  in varchar2)
is
begin
  wf_engine.StartProcess(itemtype,
                         itemkey);
end StartProcess;

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
                        process  in varchar2,
                        userkey  in varchar2,
                        owner    in varchar2) is

begin
  wf_engine.LaunchProcess(itemtype,
                          itemkey,
                          process,
                          userkey,
                          owner);
end LaunchProcess;

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
                         process  in varchar2) is
begin
  wf_engine.SuspendProcess(itemtype,
                           itemkey,
                           process);
end SuspendProcess;

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
                       process  in varchar2,
                       result   in varchar2) is
begin
  wf_engine.AbortProcess(itemtype,
                         itemkey,
                         process,
                         result);
end AbortProcess;

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
                        process  in varchar2)
is
begin
  wf_engine.ResumeProcess(itemtype,
                          itemkey,
                          process);
end ResumeProcess;


Procedure CreateForkProcess (copy_itemtype  in varchar2,
                             copy_itemkey   in varchar2,
                             new_itemkey    in varchar2,
                             same_version   in boolean) is
begin
  wf_engine.CreateForkProcess(copy_itemtype,
                              copy_itemkey,
                              new_itemkey,
                              same_version);
end CreateForkProcess;



--
-- StartForkProcess (PUBLIC)
--   Start a process that has been forked. Depending on the way this was forked,


--   this will execute startprocess if its to start with the latest version or
--   it copies the forked process activty by activity.
-- IN
--   itemtype  - Item type
--   itemkey   - item key to start
--
procedure StartForkProcess(itemtype in  varchar2,
                           itemkey  in  varchar2) as
begin
  wf_engine.StartForkProcess(itemtype,
                             itemkey);
end StartForkProcess;


--
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
                        activity in varchar2)
is
begin
  wf_engine.BeginActivity(itemtype,
                          itemkey,
                          activity);
end BeginActivity;

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
                           result   in varchar2)
is
begin
  wf_engine.CompleteActivity(itemtype,
                             itemkey,
                             activity,
                             result);
end CompleteActivity;

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
procedure CompleteActivityInternalName(itemtype in varchar2,
                                       itemkey  in varchar2,
                                       activity in varchar2,
                                       result   in varchar2)
is
begin
  wf_engine.CompleteActivityInternalName(itemtype,
                                         itemkey,
                                         activity,
                                         result);
end CompleteActivityInternalName;

--
-- AssignActivity (PUBLIC)
--   Assigns or re-assigns the user who will perform an activity. It may be
--   called before the activity has been enabled(transitioned to). If a user
--   is assigned to an activity that already has an outstanding notification,
--   that notification will be forwarded to the new user.
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
                         performer in varchar2) is
begin
  wf_engine.AssignActivity(itemtype,
                           itemkey,
                           activity,
                           performer);
end AssignActivity;

--
-- HandleError (PUBLIC)
--   Reset the process thread to the given activity and begin execution
-- again from that point.  If command is:
--     SKIP - mark the activity complete with given result and continue
--     RETRY - re-execute the activity before continuing
-- IN
--   itemtype  - A valid item type.
--   itemkey   - The item key of the process.
--   activity  - Activity to reset, specified in the form
--               [<parent process_name>:]<process instance_label>
--   command   - SKIP or RETRY.
--   <result>  - Activity result for the 'SKIP' command.
--
procedure HandleError(itemtype in varchar2,
                      itemkey  in varchar2,
                      activity in varchar2,
                      command  in varchar2,
                      result   in varchar2)
is
begin
  wf_engine.HandleError(itemtype,
                        itemkey,
                        activity,
                        command,
                        result);
end HandleError;


--
-- ItemStatus (Public)
--   This is a public cover for WF_ITEM_ACTIVITY_STATUS.ROOT_STATUS
--   Returns the status and result for the root process of this item.
--   If the item does not exist an exceprion will be raised.
-- IN
--   itemtype - Activity item type.
--   itemkey  - The item key.
-- OUT
--   status   - Activity status for root process of this item
--   result   - Result code for root process of this item
--
procedure ItemStatus(itemtype in varchar2,
                     itemkey  in varchar2,
                     status   out NOCOPY varchar2,
                     result   out NOCOPY varchar2) is
begin
  wf_engine.ItemStatus(itemtype,
                       itemkey,
                       status,
                       result);
end ItemStatus;

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
function Activity_Exist_In_Process (p_item_type          in  varchar2,
                                    p_item_key           in  varchar2,
                                    p_activity_item_type in  varchar2,
                                    p_activity_name      in  varchar2)
return boolean
is
begin
  return (wf_engine.Activity_Exist_In_Process(p_item_type,
                                              p_item_key,
                                              p_activity_item_type,
                                              p_activity_name));
end Activity_Exist_In_Process;

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
function Activity_Exist (p_process_item_type  in  varchar2,
                         p_process_name       in  varchar2,
                         p_activity_item_type in  varchar2,
                         p_activity_name      in  varchar2,
                         active_date          in  date,
                         iteration            in  number)
return boolean
is
begin
  return (wf_engine.Activity_Exist(p_process_item_type,
                                   p_process_name,
                                   p_activity_item_type,
                                   p_activity_name,
                                   active_date,
                                   iteration));
end Activity_Exist;

--
-- user_synch
--   Wrapper for fnd_user_pkg.user_synch()
-- IN
--   p_user_name
--
procedure user_synch (p_user_name  in  varchar2)
is
begin
  fnd_user_pkg.user_synch(p_user_name);
end;

--
-- default_event_raise
--   Wrapper for wf_event.raise()
-- IN
--   p_event_name
--   p_event_key
--
procedure default_event_raise(p_event_name  in  varchar2,
                              p_event_key   in  varchar2)
is
begin
  wf_event.raise(p_event_name, p_event_key, null, null, null);
end;

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
                              p_start_date            in date,
                              p_expiration_date       in date)
is
begin

   --Bug 2880053
   --This API will just be a wrapper to propagate_user_role2
   --Call propagate_user_role2 with the new signature for
   --wf_local_synch.propagate_user_role2

   fnd_wf_engine.propagate_user_role2(p_user_orig_system,
                                     p_user_orig_system_id,
                                     p_role_orig_system,
                                     p_role_orig_system_id,
                                     p_start_date,
                                     p_expiration_date,
                                     TRUE);
end;

Function DisableOrLaunch(l_item_type in varchar2,
                         l_itemkey   in varchar2,
                         c_instid    in varchar2,
                         l_username  in varchar2,
                         l_name      in varchar2)
return number is
  disable_or_launch number;
  colon             pls_integer;

begin

  colon := instr(l_username, ':');
  if (colon = 0) then
     select count(1)
     into disable_or_launch
     from WF_ITEM_ACTIVITY_STATUSES WIAS,
          WF_NOTIFICATIONS WN,
          WF_NOTIFICATION_ATTRIBUTES NATTR
     where     WIAS.ITEM_TYPE = l_item_type
           and WIAS.ITEM_KEY  = l_itemkey
           and WIAS.PROCESS_ACTIVITY = c_instid
           and WIAS.NOTIFICATION_ID = WN.GROUP_ID
           and NATTR.NOTIFICATION_ID = WN.NOTIFICATION_ID
           and NATTR.NAME = l_name
           and WN.RECIPIENT_ROLE in
              (select WUR.ROLE_NAME
               from WF_USER_ROLES WUR
               where WUR.USER_NAME = l_username);
  else
     select count(1)
     into disable_or_launch
     from WF_ITEM_ACTIVITY_STATUSES WIAS,
          WF_NOTIFICATIONS WN,
          WF_NOTIFICATION_ATTRIBUTES NATTR
     where     WIAS.ITEM_TYPE = l_item_type
           and WIAS.ITEM_KEY  = l_itemkey
           and WIAS.PROCESS_ACTIVITY = c_instid
           and WIAS.NOTIFICATION_ID = WN.GROUP_ID
           and NATTR.NOTIFICATION_ID = WN.NOTIFICATION_ID
           and NATTR.NAME = l_name
           and WN.RECIPIENT_ROLE in
              (select WUR.ROLE_NAME
               from WF_USER_ROLES WUR
               where WUR.USER_ORIG_SYSTEM = substr(l_username, 1, colon-1)
               and WUR.USER_ORIG_SYSTEM_ID = substr(l_username, colon+1)
               and WUR.USER_NAME = l_username
               and WUR.USER_ORIG_SYSTEM not in
                     ('HZ_PARTY','CUST_CONT'));
  end if;

return disable_or_launch;
end;

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
                          avalue in varchar2) is

PRAGMA AUTONOMOUS_TRANSACTION;

begin
   SetItemAttrText(itemtype, itemkey, aname, avalue);
   commit;
end;


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
                       result   in varchar2 default '#FORCE') is

PRAGMA AUTONOMOUS_TRANSACTION;

begin
   AbortProcess(itemtype, itemkey, process, result);
   commit;
end;

--Bug 2880053
--New API which matches the signature of wf_local_synch.propagate_user_role

PROCEDURE propagate_user_role2(p_user_orig_system      in varchar2,
                               p_user_orig_system_id   in number,
                               p_role_orig_system      in varchar2,
                               p_role_orig_system_id   in number,
                               p_start_date            in date,
                               p_expiration_date       in date,
                               p_overwrite             in boolean,
                               p_raiseErrors           in boolean)
is
begin
  execute immediate
  'begin wf_local_synch.propagate_user_role(:1, :2, :3, :4, :5, :6 , TRUE); end;'
      using p_user_orig_system,
            p_user_orig_system_id,
            p_role_orig_system,
            p_role_orig_system_id,
            p_start_date,
            p_expiration_date;

end;

--
-- event_raise_params
--   Wrapper for wf_event.raise() passing all parameters
-- IN
--   p_event_name
--   p_event_key
--   p_event_data
--   p_parameter - name value pairs 1-20
--   p_send_date
--
procedure event_raise_params(p_event_name  in  varchar2,
                             p_event_key   in  varchar2,
                p_event_data       in clob,
                p_parameter_name1  in varchar2,
                p_parameter_value1 in varchar2,
                p_parameter_name2  in varchar2,
                p_parameter_value2 in varchar2,
                p_parameter_name3  in varchar2,
                p_parameter_value3 in varchar2,
                p_parameter_name4  in varchar2,
                p_parameter_value4 in varchar2,
                p_parameter_name5  in varchar2,
                p_parameter_value5 in varchar2,
                p_parameter_name6  in varchar2,
                p_parameter_value6 in varchar2,
                p_parameter_name7  in varchar2,
                p_parameter_value7 in varchar2,
                p_parameter_name8  in varchar2,
                p_parameter_value8 in varchar2,
                p_parameter_name9  in varchar2,
                p_parameter_value9 in varchar2,
                p_parameter_name10  in varchar2,
                p_parameter_value10 in varchar2,
                p_parameter_name11  in varchar2,
                p_parameter_value11 in varchar2,
                p_parameter_name12  in varchar2,
                p_parameter_value12 in varchar2,
                p_parameter_name13  in varchar2,
                p_parameter_value13 in varchar2,
                p_parameter_name14  in varchar2,
                p_parameter_value14 in varchar2,
                p_parameter_name15  in varchar2,
                p_parameter_value15 in varchar2,
                p_parameter_name16  in varchar2,
                p_parameter_value16 in varchar2,
                p_parameter_name17  in varchar2,
                p_parameter_value17 in varchar2,
                p_parameter_name18  in varchar2,
                p_parameter_value18 in varchar2,
                p_parameter_name19  in varchar2,
                p_parameter_value19 in varchar2,
                p_parameter_name20  in varchar2,
                p_parameter_value20 in varchar2,
                p_send_date   in date)
is
begin
  wf_event.raise2(p_event_name,
                  p_event_key,
                  p_event_data,
                  p_parameter_name1,
                  p_parameter_value1,
                  p_parameter_name2,
                  p_parameter_value2,
                  p_parameter_name3,
                  p_parameter_value3,
                  p_parameter_name4,
                  p_parameter_value4,
                  p_parameter_name5,
                  p_parameter_value5,
                  p_parameter_name6,
                  p_parameter_value6,
                  p_parameter_name7,
                  p_parameter_value7,
                  p_parameter_name8,
                  p_parameter_value8,
                  p_parameter_name9,
                  p_parameter_value9,
                  p_parameter_name10,
                  p_parameter_value10,
                  p_parameter_name11,
                  p_parameter_value11,
                  p_parameter_name12,
                  p_parameter_value12,
                  p_parameter_name13,
                  p_parameter_value13,
                  p_parameter_name14,
                  p_parameter_value14,
                  p_parameter_name15,
                  p_parameter_value15,
                  p_parameter_name16,
                  p_parameter_value16,
                  p_parameter_name17,
                  p_parameter_value17,
                  p_parameter_name18,
                  p_parameter_value18,
                  p_parameter_name19,
                  p_parameter_value19,
                  p_parameter_name20,
                  p_parameter_value20,
                  p_send_date);
end;


end FND_WF_ENGINE;

/
