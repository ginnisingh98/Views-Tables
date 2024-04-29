--------------------------------------------------------
--  DDL for Package WF_AGENT_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_AGENT_GROUPS_PKG" AUTHID CURRENT_USER as
/* $Header: WFEVAGPS.pls 120.1 2005/07/02 03:13:49 appldev ship $ */
/*#
 * Provides APIs to communicate agent group member definitions to and
 * from the WF_AGENT_GROUPS table.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Agent Group Member
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 * @rep:ihelp FND/@besrepapis See the related online help
 */

-----------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID           in out nocopy varchar2,
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
 * Generate Function is deprecated ,use Generate1 function.
 * Generates an XML message containing the complete information from the
 * WF_AGENT_GROUPS table for the specified agent group member definition.
 * @param x_group_guid Agent Group GUID
 * @param x_member_guid Member Agent GUID
 * @return Agent Group XML Message
 * @rep:scope public
 * @rep:lifecycle deprecated
 * @rep:displayname Generate Agent Group Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evagtgpgen See the related online help
 */
function GENERATE (
  X_GROUP_GUID  in  raw,
  X_MEMBER_GUID in  raw
) return varchar2;
-----------------------------------------------------------------------------
/*#
 * Receives an XML message containing the complete information for an agent
 * group member definition and loads the information into the WF_AGENT_GROUPS
 * table.
 * @param x_message Agent Group XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Receive Agent Group Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evagtgprec See the related online help
 */
procedure RECEIVE (
  X_MESSAGE     in varchar2
);
-----------------------------------------------------------------------------
/*#
 * Generates an XML message containing the complete information from the
 * WF_AGENT_GROUPS table for the specified agent group member definition.
 * @param x_group_guid Agent Group GUID
 * @param x_member_guid Member Agent GUID
 * @return Agent Group XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Agent Group Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evagtgpgen See the related online help
 */
function GENERATE1(
  X_GROUP_GUID  in  varchar2,
  X_MEMBER_GUID in  varchar2
) return varchar2;
-----------------------------------------------------------------------------
end WF_AGENT_GROUPS_PKG;

 

/
