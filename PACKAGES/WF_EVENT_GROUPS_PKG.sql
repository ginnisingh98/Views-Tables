--------------------------------------------------------
--  DDL for Package WF_EVENT_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_EVENT_GROUPS_PKG" AUTHID CURRENT_USER as
/* $Header: WFEVGRPS.pls 120.2 2005/10/19 05:27:57 vshanmug ship $ */
/*#
 * Provides APIs to communicate event group member definitions to and
 * from the WF_EVENT_GROUPS table.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Event Group Member
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 * @rep:ihelp FND/@besrepapis See the related online help
 */
-----------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID           in out nocopy  varchar2,
  X_GROUP_GUID      in      raw,
  X_MEMBER_GUID     in      raw
);
-----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_GROUP_GUID      in      raw,
  X_MEMBER_GUID     in      raw
);
-----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_GROUP_GUID      in      raw,
  X_MEMBER_GUID     in      raw
);
-----------------------------------------------------------------------------
procedure DELETE_ROW (
  X_GROUP_GUID  in  raw,
  X_MEMBER_GUID in  raw
);
-----------------------------------------------------------------------------
/*#
 * Generates an XML message containing the complete information from the
 * WF_EVENT_GROUPS table for the specified event group member definition.
 * @param x_group_guid Event Group GUID
 * @param x_member_guid Member Event GUID
 * @return Event Group XML Message
 * @rep:scope public
 * @rep:lifecycle deprecated
 * @rep:displayname Generate Event Group Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evgpgen See the related online help
 */
function GENERATE (
  X_GROUP_GUID  in  raw,
  X_MEMBER_GUID in  raw
) return varchar2;
-----------------------------------------------------------------------------
/*#
 * Receives an XML message containing the complete information for an event
 * group member definition and loads the information into the WF_EVENT_GROUPS
 * table.
 * @param x_message Event Group XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Receive Event Group Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evgprec See the related online help
 */
procedure RECEIVE (
  X_MESSAGE     in varchar2
);
-----------------------------------------------------------------------------
/*#
 * Receives an XML message containing the complete information for an event
 * group member definition and loads the information into the WF_EVENT_GROUPS
 * table
 * @param x_message Event Group XML Message
 * @param x_error   Returns Error Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Receive Event Group Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evgprec See the related online help
 */
procedure RECEIVE2 (
  X_MESSAGE     in varchar2,
  X_ERROR       out nocopy varchar2
);
-----------------------------------------------------------------------------
/*#
 * Generates an XML message containing the complete information from the
 * WF_EVENT_GROUPS table for the specified event group member definition.
 * @param x_group_name Event Group Name
 * @param x_member_name Member Event Name
 * @return Event Group XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Event Group Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evgpgen See the related online help
 */
function GENERATE2(
  X_GROUP_NAME  in  varchar2,
  X_MEMBER_NAME in  varchar2
) return varchar2;
-----------------------------------------------------------------------------
end WF_EVENT_GROUPS_PKG;

 

/
