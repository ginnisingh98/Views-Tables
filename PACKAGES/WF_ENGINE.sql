--------------------------------------------------------
--  DDL for Package WF_ENGINE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_ENGINE" AUTHID CURRENT_USER as
/* $Header: wfengs.pls 120.6.12010000.3 2012/09/28 22:06:38 alsosa ship $ */
/*#
 * Provides APIs that can be called by an application program
 * or a workflow function in the runtime phase to communicate
 * with the Workflow Engine and to change the status of
 * workflow process activities.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Engine
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_ENGINE
 * @rep:ihelp FND/@eng_api See the related online help
 */
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

-- Bug 3065814
-- Global context variables for post-notification
context_user  varchar2(320);
context_user_comment VARCHAR2(4000);
context_recipient_role varchar2(320);
context_original_recipient varchar2(320);
context_from_role varchar2(320);
context_new_role   varchar2(320);
context_more_info_role  varchar2(320);
context_user_key varchar2(240);
context_proxy varchar2(320);

-- Bug 2156047
-- Global variables to store Notification id and
-- text information for Post Notification Function
g_nid number;          -- current notification id
g_text varchar2(2000); -- text information

-- Activity types
eng_process         varchar2(8) := 'PROCESS';  -- Process type activity
eng_function        varchar2(8) := 'FUNCTION'; -- Function type activity
eng_notification    varchar2(8) := 'NOTICE';   -- Notification type activity
-- eng_event           varchar2(8) := 'EVENT';    -- Event activity

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
eng_noskip          varchar2(30) := '#NOSKIP';    -- Skip not allowed

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

-- Schema attribute name
eng_schema          varchar2(320) := '#SCHEMA';  -- current schema name

-- Special activity attribute names
eng_priority         varchar2(30) := '#PRIORITY'; -- Priority override
eng_timeout_attr     varchar2(30) := '#TIMEOUT'; -- Priority override

-- Standard activity transitions
eng_trans_default    varchar2(30) := '*';
eng_trans_any        varchar2(30) := '#ANY';

-- commit for every n iterations
commit_frequency     number       := 500;

/**** #### Defined below *****/

-- Applications context flag
-- By default we want context to be preserved.
preserved_context    boolean      := TRUE;

 -- Execution Counter
 --
    ExecCounter number := 0;

--
-- Synch mode
--   NOTE: Synch mode is only to be used for in-line processes that are
--   run to completion and purged within one session.  Some process data
--   is never saved to the database, so the monitor, reports, any external
--   access to workflow tables, etc, will not work.
--
--   This mode is enabled by setting the user_key of the item to
--   wf_engine.eng_synch.
--
--   *** Do NOT enable this mode unless you are sure you understand
--   *** the implications!
--
synch_mode boolean := FALSE; -- *** OBSOLETE! DO NOT USE! ***

eng_synch varchar2(8) := '#SYNCH';

-- 16-DEC-03 shanjgik bug fix 2722369 Reassign modes added
eng_reassign varchar2(8) := 'REASSIGN';-- not exactly a mode, added just for completeness
eng_delegate varchar2(8) := 'DELEGATE';
eng_transfer varchar2(8) := 'TRANSFER';

type AttrRecTyp is record (
  name varchar2(30),
  text_value varchar2(4000),
  number_value number,
  date_value date);
type AttrArrayTyp is table of AttrRecTyp
index by binary_integer;

synch_attr_arr AttrArrayTyp;       -- Array of item attributes
synch_attr_count pls_integer := 0; -- Array size

type NameTabTyp is table of Wf_Item_Attribute_Values.NAME%TYPE
  index by binary_integer;
type TextTabTyp is table of Wf_Item_Attribute_Values.TEXT_VALUE%TYPE
  index by binary_integer;
type NumTabTyp is table of Wf_Item_Attribute_Values.NUMBER_VALUE%TYPE
  index by binary_integer;
type DateTabTyp is table of Wf_Item_Attribute_Values.DATE_VALUE%TYPE
  index by binary_integer;


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
/*#
 * Adds a new item type attribute variable to the process. Although most item
 * type attributes are defined at design time, you can create new attributes at
 * runtime for a specific process. You can optionally set a default text,
 * number, or date value for a new item type attribute when the attribute is
 * created.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name
 * @param text_value Text Attribute Value
 * @param number_value Number Attribute Value
 * @param date_value Date Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Item Attribute
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_addp See the related online help
 */
procedure AddItemAttr(itemtype in varchar2,
                      itemkey in varchar2,
                      aname in varchar2,
                      text_value   in varchar2 default null,
                      number_value in number   default null,
                      date_value   in date     default null);

--
-- AddItemAttrTextArray (PUBLIC)
--   Add an array of new unvalidated run-time item attributes of type text.
-- IN:
--   itemtype - item type
--   itemkey - item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
-- NOTE:
--   The new attributes have no type associated.  Get/set usages of these
--   attributes must insure type consistency.
--
/*#
 * Adds an array of new text item type attributes to the process. Although
 * most item type attributes are defined at design time, you can create new
 * attributes at runtime for a specific process. Use this API rather than the
 * AddItemAttr API for improved performance when you need to add large numbers
 * of text item type attributes at once.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name Array
 * @param avalue Attribute Value Array
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Text Item Attribute Value Array
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_aiaa See the related online help
 */
procedure AddItemAttrTextArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.TextTabTyp);

--
-- AddItemAttrNumberArray (PUBLIC)
--   Add an array of new unvalidated run-time item attributes of type number.
-- IN:
--   itemtype - item type
--   itemkey - item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
-- NOTE:
--   The new attributes have no type associated.  Get/set usages of these
--   attributes must insure type consistency.
--
/*#
 * Adds an array of new number item type attributes to the process. Although
 * most item type attributes are defined at design time, you can create new
 * attributes at runtime for a specific process. Use this API rather than the
 * AddItemAttr API for improved performance when you need to add large numbers
 * of number item type attributes at once.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name Array
 * @param avalue Attribute Value Array
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Number Item Attribute Value Array
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_aiaa See the related online help
 */
procedure AddItemAttrNumberArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.NumTabTyp);

--
-- AddItemAttrDateArray (PUBLIC)
--   Add an array of new unvalidated run-time item attributes of type date.
-- IN:
--   itemtype - item type
--   itemkey - item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
-- NOTE:
--   The new attributes have no type associated.  Get/set usages of these
--   attributes must insure type consistency.
--
/*#
 * Adds an array of new date item type attributes to the process. Although
 * most item type attributes are defined at design time, you can create new
 * attributes at runtime for a specific process. Use this API rather than the
 * AddItemAttr API for improved performance when you need to add large numbers
 * of date item type attributes at once.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name Array
 * @param avalue Attribute Value Array
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Add Date Item Attribute Value Array
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_aiaa See the related online help
 */
procedure AddItemAttrDateArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.DateTabTyp);

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
/*#
 * Sets the value of a text item type attribute in a process. You can
 * also use this API for attributes of type role, form, URL, lookup, or
 * document.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name
 * @param avalue Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Text Item Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_setp See the related online help
 */
procedure SetItemAttrText(itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          avalue in varchar2);

--
-- SetItemAttrText2 (PRIVATE)
--   Set the value of a text item attribute.
--   If the attribute is a NUMBER or DATE type, then translate the
--   text-string value to a number/date using attribute format.
--   For all other types, store the value directly.
-- IN:
--   p_itemtype - Item type
--   p_itemkey - Item key
--   p_aname - Attribute Name
--   p_avalue - New value for attribute
-- RETURNS:
--   boolean
--
function SetItemAttrText2(p_itemtype in varchar2,
                          p_itemkey in varchar2,
                          p_aname in varchar2,
                          p_avalue in varchar2) return boolean;

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
/*#
 * Sets the value of a number item type attribute in a process.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name
 * @param avalue Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Number Item Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_setp See the related online help
 */
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
/*#
 * Sets the value of a date item type attribute in a process.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name
 * @param avalue Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Date Item Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_setp See the related online help
 */
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
/*#
 * Sets the value of an item attribute of type document, to a document
 * identifier.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name
 * @param documentid Document ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Document Item Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_siad See the related online help
 */
procedure SetItemAttrDocument(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2,
                              documentid in varchar2);

--
-- SetItemAttrTextArray (PUBLIC)
--   Set the values of an array of text item attribute.
--   Unlike SetItemAttrText(), it stores the values directly.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Names
--   avalue - Array of New values for attribute
--
/*#
 * Sets the values of an array of item type attributes in a process. Use the
 * SetItemAttrTextArray API rather than the SetItemAttrText API for improved
 * performance when you need to set the values of large numbers of item type
 * attributes at once.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name Array
 * @param avalue Attribute Value Array
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Item Attribute Text Array
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_siaa See the related online help
 */
procedure SetItemAttrTextArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.TextTabTyp);

--
-- SetItemAttrNumberArray (PUBLIC)
--   Set the value of an array of number item attribute.
--   Attribute must be a NUMBER-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Names
--   avalue - Array of new value for attribute
--
/*#
 * Sets the values of an array of item type attributes in a process. Use the
 * SetItemAttrNumberArray API rather than the SetItemAttrNumber API for improved
 * performance when you need to set the values of large numbers of item type
 * attributes at once.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name Array
 * @param avalue Attribute Value Array
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Item Attribute Number Array
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_siaa See the related online help
 */
procedure SetItemAttrNumberArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.NumTabTyp);

--
-- SetItemAttrDateArray (PUBLIC)
--   Set the value of an array of date item attribute.
--   Attribute must be a DATE-type attribute.
-- IN:
--   itemtype - Item type
--   itemkey - Item key
--   aname - Array of Name
--   avalue - Array of new value for attribute
--
/*#
 * Sets the values of an array of item type attributes in a process. Use the
 * SetItemAttrDateArray API rather than the SetItemAttrDate API for improved
 * performance when you need to set the values of large numbers of item type
 * attributes at once.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name Array
 * @param avalue Attribute Value Array
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Item Attribute Date Array
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_siaa See the related online help
 */
procedure SetItemAttrDateArray(
  itemtype in varchar2,
  itemkey  in varchar2,
  aname    in Wf_Engine.NameTabTyp,
  avalue   in Wf_Engine.DateTabTyp);

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
/*#
 * Returns information about an item type attribute, such as its type and format,
 * if any is specified. Currently, subtype information is not available for item
 * type attributes
 * @param itemtype Item Type
 * @param aname Attribute Name
 * @param atype Attribute Type
 * @param subtype Attribute Subtype
 * @param format Attribute Format
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Item Attribute Information
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getiainfo See the related online help
 */
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
/*#
 * Returns the value of a text item type attribute in a process. You can
 * also use this API for attributes of type role, form, URL, lookup, or
 * document.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name
 * @param ignore_notfound Ignore if Not Found
 * @return Text Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Text Item Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getp See the related online help
 */
function GetItemAttrText(itemtype in varchar2,
                         itemkey in varchar2,
                         aname in varchar2,
                         ignore_notfound in boolean default FALSE)
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
/*#
 * Returns the value of an item type number attribute in a process.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name
 * @param ignore_notfound Ignore if Not Found
 * @return Number Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Number Item Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getp See the related online help
 */
function GetItemAttrNumber(itemtype in varchar2,
                           itemkey in varchar2,
                           aname in varchar2,
                           ignore_notfound in boolean default FALSE)
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
/*#
 * Returns the value of an item type date attribute in a process.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name
 * @param ignore_notfound Ignore if Not Found
 * @return Date Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Date Item Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getp See the related online help
 */
function GetItemAttrDate (itemtype in varchar2,
                          itemkey in varchar2,
                          aname in varchar2,
                          ignore_notfound in boolean default FALSE)
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
/*#
 * Returns the document identifier for a DM document-type item attribute.
 * The document identifier is a concatenated string of the following values:
 * DM:<nodeid>:<documentid>:<version>
 * <nodeid> is the node ID assigned to the document management system node as
 * defined in the Document Management Nodes web page. <documentid> is the
 * document ID of the document, as assigned by the document management system
 * where the document resides. <version> is the version of the document. If a
 * version is not specified, the latest version is assumed.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name
 * @param ignore_notfound Ignore if Not Found
 * @return Document ID
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Document Item Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_giad See the related online help
 */
Function GetItemAttrDocument(itemtype in varchar2,
                              itemkey in varchar2,
                              aname in varchar2,
                              ignore_notfound in boolean default FALSE)
RETURN VARCHAR2;


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
/*#
 * Returns information about an activity attribute, such as its type and format,
 * if any is specified. This procedure currently does not return any subtype
 * information for activity attributes.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @param aname Attribute Name
 * @param atype Attribute Type
 * @param subtype Attribute Subtype
 * @param format Attribute Format
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Activity Attribute Information
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getaainfo See the related online help
 */
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
/*#
 * Returns the value of a text activity attribute in a process. You can
 * also use this API for attributes of type role, form, URL, lookup,
 * attribute, or document.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @param aname Attribute Name
 * @param ignore_notfound Ignore if not found
 * @return Text Activity Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Text Activity Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getaa See the related online help
 */
function GetActivityAttrText(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2,
                             ignore_notfound in boolean default FALSE)
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
/*#
 * Returns the value of a number activity attribute in a process.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @param aname Attribute Name
 * @param ignore_notfound Ignore if not found
 * @return Number Activity Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Number Activity Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getaa See the related online help
 */
function GetActivityAttrNumber(itemtype in varchar2,
                               itemkey in varchar2,
                               actid in number,
                               aname in varchar2,
                               ignore_notfound in boolean default FALSE)
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
/*#
 * Returns the value of a date activity attribute in a process.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @param aname Attribute Name
 * @param ignore_notfound Ignore if not found
 * @return Date Activity Attribute Value
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Date Activity Attribute Value
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getaa See the related online help
 */
function GetActivityAttrDate(itemtype in varchar2,
                             itemkey in varchar2,
                             actid in number,
                             aname in varchar2,
                             ignore_notfound in boolean default FALSE)
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
/*#
 * Defines the parent/child relationship for a master process and a detail
 * process. This API must be called by any detail process spawned from a
 * master process to define the parent/child relationship between the two
 * processes. You make a call to this API after you call the CreateProcess
 * API, but before you call the StartProcess API for the detail process.
 * @param itemtype Child Item Type
 * @param itemkey Child Item Key
 * @param parent_itemtype Parent Item Type
 * @param parent_itemkey Parent Item Key
 * @param parent_context Parent Context
 * @param masterdetail Master Detail Coordination
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Item Parent
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#parent See the related online help
 */
procedure SetItemParent(itemtype in varchar2,
  itemkey in varchar2,
  parent_itemtype in varchar2,
  parent_itemkey in varchar2,
  parent_context in varchar2,
  masterdetail   in boolean default NULL);

--
-- SetItemOwner (PUBLIC)
--   Set the owner of an item
-- IN
--   itemtype - Item type
--   itemkey - Item key
--   owner - Role designated as owner of the item
--
/*#
 * Sets the owner of existing items. The owner must be a valid role. Typically,
 * the role that initiates a transaction is assigned as the process owner, so
 * that any participant in that role can find and view the status of that
 * process instance in the Workflow Monitor.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param owner Item Owner Role
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Item Owner
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#itown See the related online help
 */
procedure SetItemOwner(
  itemtype in varchar2,
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
/*#
 * Returns the user-friendly key assigned to an item in a process, identified by
 * an item type and item key. The user key is a user-friendly identifier to
 * locate items in the Workflow Monitor and other user interface components of
 * Oracle Workflow.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @return Item User Key
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Item User Key
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getikey See the related online help
 */
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
/*#
 * Sets a user-friendly identifier for an item in a process, which is initially
 * identified by an item type and item key. The user key is intended to be a
 * user-friendly identifier to locate items in the Workflow Monitor and other
 * user interface components of Oracle Workflow.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param userkey User Key
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Set Item User Key
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_setikey See the related online help
 */
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
/*#
 * Returns the instance label of an activity, given the internal activity
 * instance ID. The label returned has the following format, which is
 * suitable for passing to other Workflow Engine APIs, such as
 * CompleteActivity and HandleError, that accept activity labels as
 * arguments:
 *  <br> &lt;process_name&gt;:&lt;instance_label&gt;
 * @param actid Activity ID
 * @return Activity Label
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Activity Label
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getlabel See the related online help
 */
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

-- Bug 2376033
--  Call back function with additional input parameter to get
--  value for an event attribute
-- IN
--   event_value - Event Attribute value for 'SET'
-- OUT
--   event_value - Event Attribute value for 'GET'

procedure CB(command in varchar2,
             context in varchar2,
             attr_name in varchar2 default null,
             attr_type in varchar2 default null,
             text_value in out NOCOPY varchar2,
             number_value in out NOCOPY number,
             date_value in out NOCOPY date,
             event_value in out nocopy wf_event_t);

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
--   process_timeout - Handle timeout process errors
--   process_stuck - Handle stuck process errors
--
/*#
 * Runs a background engine for processing deferred activities, timed out
 * activities, and stuck processes using the parameters specified. The
 * background engine executes all activities that satisfy the given arguments
 * at the time that the background engine is invoked. This procedure does not
 * remain running long term, so you must restart this procedure periodically.
 * Any activities that are newly deferred or timed out or processes that become
 * stuck after the current background engine starts are processed by the next
 * background engine that is invoked. You may run a script called wfbkgchk.sql
 * to get a list of the activities waiting to be processed by the next
 * background engine run.
 * @param itemtype Item Type
 * @param minthreshold Minimum Threshold
 * @param maxthreshold Maximum Threshold
 * @param process_deferred Process Deferred Activities
 * @param process_timeout Process Timeout Activities
 * @param process_stuck Process Stuck Activities
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Workflow Background Engine
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_bckgr See the related online help
 */
procedure Background (itemtype         in varchar2 default '',
                      minthreshold     in number default null,
                      maxthreshold     in number default null,
                      process_deferred in boolean default TRUE,
                      process_timeout  in boolean default TRUE,
                      process_stuck    in boolean default FALSE);

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
--   process_stuck - Handle stuck process errors
--
procedure BackgroundConcurrent (
    errbuf out NOCOPY varchar2,
    retcode out NOCOPY varchar2,
    itemtype in varchar2 default '',
    minthreshold in varchar2 default '',
    maxthreshold in varchar2 default '',
    process_deferred in varchar2 default 'Y',
    process_timeout in varchar2 default 'Y',
    process_stuck in varchar2 default 'N');

--
-- CreateProcess (PUBLIC)
--   Create a new runtime process (for an application item).
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--   process  - A valid root process for this item type
--              (or null to use the item's selector function)
--   user_key - Optional parameter to avoid having to call SetItemUserKey later.
--   owner_role - Optional paramer to avoid having to call SetItemOwner later.
--
/*#
 * Creates a new runtime process for an application item. For example, a
 * Requisition item type may have a Requisition Approval Process as a top level
 * process. When a particular requisition is created, an application calls
 * CreateProcess to set up the information needed to start the defined process.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param process Process Name
 * @param user_key User Key
 * @param owner_role Item Owner Role
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Runtime Process
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_createp See the related online help
 */
procedure CreateProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2 default '',
                        user_key in varchar2 default null,
                        owner_role in varchar2 default null);

--
-- StartProcess (PUBLIC)
--   Begins execution of the process. The process will be identified by the
--   itemtype and itemkey.  The engine locates the starting activities
--   of the root process and executes them.
-- IN
--   itemtype - A valid item type
--   itemkey  - A string generated from the application object's primary key.
--
/*#
 * Begins execution of the specified process. The engine locates the activity
 * marked as START and then executes it. CreateProcess() must first be called
 * to define the itemtype and itemkey before calling StartProcess().
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Start Process
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_startp See the related online help
 */
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
/*#
 * Launches a specified process by creating the new runtime process and beginning
 * its execution. This is a wrapper that combines CreateProcess and StartProcess.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param process Process Name
 * @param userkey User Key
 * @param owner Item Owner Role
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Launch Process
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_launchp See the related online help
 */
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
/*#
 * Suspends process execution so that no new transitions occur. Outstanding
 * notifications can complete by calling CompleteActivity(), but the workflow
 * does not transition to the next activity. Restart suspended processes by
 * calling ResumeProcess().
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param process Process Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Suspend Process
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_suspnp See the related online help
 */
procedure SuspendProcess(itemtype in varchar2,
                         itemkey  in varchar2,
                         process  in varchar2 default '');


--
-- SuspendAll (PUBLIC)) --</rwunderl:1833759>
--   Suspends all processes for a given itemType.
-- IN
--   itemtype - A valid itemType
--   process
--

Procedure SuspendAll (p_itemType in varchar2,
                      p_process in varchar2 default NULL);

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
--   verify_lock - TRUE if the item should be locked before processing it
--   cascade  - TRUE is you want to cascade purge all master-child
--              relations associated with this item
--
/*#
 * Aborts process execution and cancels outstanding notifications. The process
 * status is considered COMPLETE, with a result specified by the <code>result</code>
 * argument. Also, any outstanding notifications or subprocesses are set to a status of
 * COMPLETE with a result of force, regardless of the <code>result</code> argument.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param process Process Name
 * @param result Status of Aborted Process
 * @param verify_lock Lock Item Before Processing (TRUE/FALSE)
 * @param cascade Abort Associated Child Processes (TRUE/FALSE)
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Abort Process
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.wf.engine.abort
 * @rep:ihelp FND/@eng_api#a_abortp See the related online help
 */
procedure AbortProcess(itemtype in varchar2,
                       itemkey  in varchar2,
                       process  in varchar2 default '',
                       result   in varchar2 default wf_engine.eng_force,
		       verify_lock in boolean default FALSE,
		       cascade  in boolean default FALSE);

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
/*#
 * Returns a suspended process to normal execution status. Any activities that
 * were transitioned to while the process was suspended are now executed.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param process Process Name
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Resume Process
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_resump See the related online help
 */
procedure ResumeProcess(itemtype in varchar2,
                        itemkey  in varchar2,
                        process  in varchar2 default '');


--
-- ResumeAll (PUBLIC) --</rwunderl:1833759>
--   Resumes all processes for a given itemType.
-- IN
--   itemtype - A valid itemType
--   process
--
Procedure ResumeAll (p_itemType in varchar2,
                     p_process  in varchar2 default NULL);


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
/*#
 * Forks a runtime process by creating a new process that is a copy of the
 * original. After calling CreateForkProcess(), you can call APIs such as
 * SetItemOwner(), SetItemUserKey(), or the SetItemAttribute APIs to reset
 * any item properties or modify any item attributes that you want for the
 * new process. Then you must call StartForkProcess() to start the new process.
 * @param copy_itemtype Original Item Type
 * @param copy_itemkey Original Item Key
 * @param new_itemkey New Item Key
 * @param same_version Same version as original item
 * @param masterdetail Master-Detail Process
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Create Fork Process
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_crfork See the related online help
 */
Procedure CreateForkProcess (
     copy_itemtype  in varchar2,
     copy_itemkey   in varchar2,
     new_itemkey    in varchar2,
     same_version   in boolean default TRUE,
     masterdetail   in boolean default NULL);

--
-- StartForkProcess (PUBLIC)
--   Start a process that has been forked. Depending on the way this was forked,
--   this will execute startprocess if its to start with the latest version or
--   it copies the forked process activty by activity.
-- IN
--   itemtype  - Item type
--   itemkey   - item key to start
--
/*#
 * Begins execution of the new forked process that you specify. Before you call
 * StartForkProcess(), you must first call CreateForkProcess() to create the
 * new process. You can modify the item attributes of the new process before
 * calling StartForkProcess().
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Start Fork Process
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_stfork See the related online help
 */
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
/*#
 * Determines if the specified activity can currently be performed on the
 * process item and raises an exception if it cannot.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param activity Activity Label to Begin
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Begin Activity
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_beginp See the related online help
 */
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
/*#
 * Notifies the Workflow Engine that the specified activity has been completed
 * for a particular item. This procedure can be called either to indicate a
 * completed activity with an optional result or to create and start an item.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param activity Activity Label to Complete
 * @param result Result
 * @param raise_engine_exception Raise Exception for Engine Issues
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Complete Activity
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#comact See the related online help
 */
procedure CompleteActivity(itemtype in varchar2,
                           itemkey  in varchar2,
                           activity in varchar2,
                           result   in varchar2,
                           raise_engine_exception in boolean default FALSE);

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
/*#
 * Notifies the Workflow Engine that the specified activity has been completed
 * for a particular item. This procedure requires that the activity currently
 * has a status of 'Notified'. An optional activity completion result can also
 * be passed. The result can determine what transition the process takes next.
 * This API is similar to CompleteActivity() except that this API identifies the
 * activity to be completed by the activity's internal name, while
 * CompleteActivity() identifies the activity by the activity node label name.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param activity Activity Label to Complete
 * @param result Result
 * @param raise_engine_exception Raise Exception for Engine Issues
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Complete Activity Internal Name
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#comactin See the related online help
 */
procedure CompleteActivityInternalName(
  itemtype in varchar2,
  itemkey  in varchar2,
  activity in varchar2,
  result   in varchar2,
  raise_engine_exception in boolean default FALSE);

--
-- AssignActivity (PUBLIC)
--   Assigns or re-assigns the user who will perform an activity. It may be
--   called before the activity has been enabled(transitioned to). If a user
--   is assigned to an activity that already has an outstanding notification,
--   that notification will be canceled and a new notification will be
--   generated for the new user.
-- IN
--   itemtype     - A valid item type
--   itemkey      - A string generated from the application object's primary key.
--   activity     - Activity to assign, specified in the form
--                  [<parent process_name>:]<process instance_label>
--   performer    - User who will perform this activity.
--   reassignType - DELEGATE, TRANSFER or null
--   ntfComments  - Comments while reassigning
/*#
 * Assigns or reassigns an activity to another performer. This procedure may be
 * called before the activity is transitioned to. For example, a function
 * activity earlier in the process may determine the performer of a later
 * activity. If a new user is assigned to a notification activity that already
 * has an outstanding notification, the outstanding notification is canceled and
 * a new notification is generated for the new user by calling
 * WF_Notification.Transfer.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param activity Activity Label
 * @param performer Performer Role
 * @param reassignType For Internal Use Only
 * @param ntfComments For Internal Use Only
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Assign Performer to Activity
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_assigp See the related online help
 */
procedure AssignActivity(itemtype in varchar2,
                         itemkey  in varchar2,
                         activity in varchar2,
                         performer in varchar2,
                         reassignType in varchar2 default null,
                         ntfComments in varchar2 default null);

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
/*#
 * Handles any process activity that has encountered an error, when
 * called from an activity in an ERROR process. You can also call this procedure
 * for any arbitrary activity in a process, to rollback part of your process to
 * that activity. The activity that you call this procedure with can have any
 * status and does not need to have been executed. The activity can also be in a
 * subprocess. If the activity node label is not unique within the process you
 * may precede the activity node label name with the internal name of its parent
 * process.
 * For example, <parent_process_internal_name>:<label_name>.
 * This procedure clears the activity specified and all activities following it
 * that have already been transitioned to by reexecuting each activity in
 * 'Cancel' mode. For an activity in the 'Error' state, there are no other
 * executed activities following it, so the procedure simply clears the errored
 * activity. Once the activities are cleared, this procedure resets any parent
 * processes of the specified activity to a status of 'Active', if they are not
 * already active. The procedure then handles the specified activity based on
 * the command you provide: SKIP or RETRY.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param activity Activity Label to Handle
 * @param command Command (SKIP or RETRY)
 * @param result Result
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Handle Error
 * @rep:compatibility S
 * @rep:businessevent oracle.apps.wf.engine.skip
 * @rep:businessevent oracle.apps.wf.engine.retry
 * @rep:ihelp FND/@eng_api#a_handp See the related online help
 */
procedure HandleError(itemtype in varchar2,
                      itemkey  in varchar2,
                      activity in varchar2,
                      command  in varchar2,
                      result   in varchar2 default '');

-- HandleErrorAll (PUBLIC)
--   Reset the process thread to the given item type and/or item key.
--   It only run in RETRY mode.
-- IN
--   itemtype  - A valid item type.
--   itemkey   - The item key of the process.
--   docommit  - True if you want a commit for every n iterations.
--               n is defined as wf_engine.commit_frequency
--
procedure HandleErrorAll(itemtype in varchar2,
                         itemkey  in varchar2 default null,
                         activity in varchar2 default null,
                         command  in varchar2 default null,
                         result   in varchar2 default '',
                         docommit in boolean  default true);

/*#
 * Returns the status and result for the root process of the specified item
 * instance. Possible values returned for the status are: ACTIVE, COMPLETE,
 * ERROR, or SUSPENDED. If the root process does not exist, then the item
 * key does not exist and will thus cause the procedure to raise an exception.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param status Status
 * @param result Result
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Item Status
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_is See the related online help
 */
procedure ItemStatus(itemtype in varchar2,
                     itemkey  in varchar2,
                     status   out NOCOPY varchar2,
                     result   out NOCOPY varchar2);

procedure ItemInfo(itemtype      in  varchar2,
                   itemkey       in  varchar2,
                   status        out NOCOPY varchar2,
                   result        out NOCOPY varchar2,
                   actid         out NOCOPY number,
                   errname       out NOCOPY varchar2,
                   errmsg        out NOCOPY varchar2,
                   errstack      out NOCOPY varchar2);


--
-- Activity_Exist_In_Process
--   ### OBSOLETE - Use FindActivity instead ###
--
function Activity_Exist_In_Process (
  p_item_type          in  varchar2,
  p_item_key           in  varchar2,
  p_activity_item_type in  varchar2 default null,
  p_activity_name      in  varchar2)
return boolean;

--
-- Activity_Exist
--   ### OBSOLETE - Use FindActivity instead ###
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
-- EVENT activity related constants/functions
--

-- Activity types
eng_event           varchar2(8) := 'EVENT';    -- Event activity

-- Event directions
eng_receive         varchar2(8) := 'RECEIVE'; -- Recieve incoming event
eng_raise           varchar2(8) := 'RAISE';    -- Generate new event
eng_send            varchar2(8) := 'SEND';    -- Transfer event

-- Event activity attribute names
eng_eventname       varchar2(30) := '#EVENTNAME';
eng_eventkey        varchar2(30) := '#EVENTKEY';
eng_eventmessage    varchar2(30) := '#EVENTMESSAGE';
eng_eventoutagent   varchar2(30) := '#EVENTOUTAGENT';
eng_eventtoagent    varchar2(30) := '#EVENTTOAGENT';
eng_defaultevent    varchar2(30) := '#EVENTMESSAGE2';

-- Send event activity attribute for OTA Callback
eng_block_mode      varchar2(30)  := '#BLOCK_MODE';
eng_cb_event_name   varchar2(240) := '#CB_EVENT_NAME';
eng_cb_event_key    varchar2(2000):= '#CB_EVENT_KEY';

--
-- GetItemAttrClob (PUBLIC)
--   Get display contents of item attribute as a clob
-- NOTE
--   Returns expanded content of attribute.
--   For DOCUMENT-type attributes, this will be the actual document
--   generated.  For all other types, this will be the displayed
--   value of the attribute.
--   Use GetItemAttrText to retrieve internal key.
-- IN
--   itemtype - item type
--   itemkey - item key
--   aname - item attribute name
-- RETURNS
--   Expanded content of item attribute as a clob
--
/*#
 * Returns the value of an item type attribute in a process as a character large
 * object (CLOB).
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param aname Attribute Name
 * @return Item Attribute Value as CLOB
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Item Attribute Value as CLOB
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_giac See the related online help
 */
function GetItemAttrClob(
  itemtype in varchar2,
  itemkey in varchar2,
  aname in varchar2)
return clob;

--
-- GetActivityAttrClob (PUBLIC)
--   Get display contents of activity attribute as a clob
-- NOTE
--   Returns expanded content of attribute.
--   For DOCUMENT-type attributes, this will be the actual document
--   generated.  For all other types, this will be the displayed
--   value of the attribute.
--   Use GetActivityAttrText to retrieve internal key.
-- IN
--   itemtype - item type
--   itemkey - item key
--   aname - activity attribute name
-- RETURNS
--   Expanded content of activity attribute as a clob
--
/*#
 * Returns the value of an activity attribute in a process as a character large
 * object (CLOB).
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param actid Activity ID
 * @param aname Attribute Name
 * @return Activity Attribute Value as CLOB
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Get Activity Attribute Value as CLOB
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_getaac See the related online help
 */
function GetActivityAttrClob(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  aname in varchar2)
return clob;

--
-- SetItemAttrEvent
--   Set event-type item attribute
-- IN
--   itemtype - process item type
--   itemkey - process item key
--   name - attribute name
--   event - attribute value
--
procedure SetItemAttrEvent(
  itemtype in varchar2,
  itemkey in varchar2,
  name in varchar2,
  event in wf_event_t);

--
-- GetItemAttrEvent
--   Get event-type item attribute
-- IN
--   itemtype - process item type
--   itemkey - process item key
--   name - attribute name
-- RETURNS
--   Attribute value
--
function GetItemAttrEvent(
  itemtype in varchar2,
  itemkey in varchar2,
  name in varchar2)
return wf_event_t;

--
-- GetActivityAttrEvent
--   Get event-type activity attribute
-- IN
--   itemtype - process item type
--   itemkey - process item key
--   actid - current activity id
--   name - attribute name
-- RETURNS
--   Attribute value
--
function GetActivityAttrEvent(
  itemtype in varchar2,
  itemkey in varchar2,
  actid in number,
  name in varchar2)
return wf_event_t;

--
-- Event
--   Signal event to workflow process
-- IN
--   itemtype - Item type of process
--   itemkey - Item key of process
--   process_name - Process to start (only if process not already running)
--   event_message - Event message payload
--
/*#
 * Receives an event from the Business Event System into a workflow
 * process. If the specified item key already exists, the event is received into
 * that item. If the item key does not already exist, but the specified process
 * includes an eligible Receive event activity marked as a Start activity, the
 * Workflow Engine creates a new item running that process. Within the workflow
 * process that receives the event, the procedure searches for eligible Receive
 * event activities. An activity is only eligible to receive an event if its
 * event filter is either blank, set to an event group of which that event is a
 * member, or set to that particular event. Additionally, the activity must have
 * an appropriate status.
 * @param itemtype Item Type
 * @param itemkey Item Key
 * @param process_name Process Name
 * @param event_message Event Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Event
 * @rep:compatibility S
 * @rep:ihelp FND/@eng_api#a_engevent See the related online help
 */
procedure Event(
  itemtype in varchar2,
  itemkey in varchar2,
  process_name in varchar2 default null,
  event_message in wf_event_t);

--
-- Event2
--   Signal event to workflow process
-- IN
--   event_message - Event message payload
--
procedure Event2(
  event_message in wf_event_t);

--
-- AddToItemAttrNumber
--   Increments (or decrements) an numeric item attribute and returns the
--   new value.  If the item attribute does not exist, it returns null.
-- IN
--   p_itemtype - process item type
--   p_itemkey - process item key
--   p_aname - Item Attribute Name
--   p_name - attribute name
--   p_addend - Numeric value to be added to the item attribute.
--
-- RETURNS
--   Attribute value (NUMBER) or NULL if attribute does not exist.
--
function AddToItemAttrNumber(
  p_itemtype in varchar2,
  p_itemkey in varchar2,
  p_aname in varchar2,
  p_addend in number)
return number;

-- Bug 5903106
-- HandleErrorConcurrent
--   Concurrent Program API to handle any process activity that has
--   encountered an error. This Concurrent Program API is a wrapper
--   to HandleError and HandleErrorAll based on the parameter values
--   supplied.
-- IN
--   p_errbuf
--   p_retcode
--   p_itemtype   - Workflow Itemtype
--   p_itemkey    - Itemkey of the process
--   p_activity   - Workflow process activity label
--   p_start_date - Errored On or After date
--   p_end_date   - Errored On or Before date
--   p_max_retry  - Maximum retries allowed on an activity
--   p_docommit   - True if you want a commit for every n iterations.
--                  n is defined as wf_engine.commit_frequency
--
procedure HandleErrorConcurrent(p_errbuf    out nocopy varchar2,
                                p_retcode   out nocopy varchar2,
                                p_itemtype  in  varchar2,
                                p_itemkey   in  varchar2 default null,
                                p_process   in  varchar2 default null,
                                p_activity  in  varchar2 default null,
                                p_start_date in varchar2 default null,
                                p_end_date  in  varchar2 default null,
                                p_max_retry in  varchar2 default null,
                                p_docommit  in  varchar2 default null);
-- bug 6161171
procedure AbortProcess2(itemtype    in varchar2,
                        itemkey     in varchar2,
                        process     in varchar2       default '',
                        result      in varchar2       default wf_engine.eng_force,
                        verify_lock in binary_integer default 0,
                        cascade     in binary_integer default 0);


END WF_ENGINE;

/
