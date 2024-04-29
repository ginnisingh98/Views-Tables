--------------------------------------------------------
--  DDL for Package WF_AGENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_AGENTS_PKG" AUTHID CURRENT_USER as
/* $Header: WFEVAGTS.pls 120.1 2005/07/02 03:13:57 appldev ship $ */
/*#
 * Provides APIs to communicate agent definitions to and from the
 * WF_AGENTS table.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Agent
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 * @rep:ihelp FND/@besrepapis See the related online help
 */
-----------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID           in out nocopy  varchar2,
  X_GUID            in      raw,
  X_NAME            in      varchar2,
  X_SYSTEM_GUID     in      raw,
  X_PROTOCOL        in      varchar2,
  X_ADDRESS         in      varchar2,
  X_QUEUE_HANDLER   in      varchar2,
  X_QUEUE_NAME      in      varchar2,
  X_DIRECTION       in      varchar2,
  X_STATUS          in      varchar2,
  X_DISPLAY_NAME    in      varchar2,
  X_DESCRIPTION     in      varchar2,
  X_TYPE            in      varchar2 default 'AGENT',
  X_JAVA_QUEUE_HANDLER in   varchar2 default null
);
-----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_GUID            in      raw,
  X_NAME            in      varchar2,
  X_SYSTEM_GUID     in      raw,
  X_PROTOCOL        in      varchar2,
  X_ADDRESS         in      varchar2,
  X_QUEUE_HANDLER   in      varchar2,
  X_QUEUE_NAME      in      varchar2,
  X_DIRECTION       in      varchar2,
  X_STATUS          in      varchar2,
  X_DISPLAY_NAME    in      varchar2,
  X_DESCRIPTION     in      varchar2,
  X_TYPE            in      varchar2 default null,
  X_JAVA_QUEUE_HANDLER in   varchar2 default null
);
-----------------------------------------------------------------------------
procedure DELETE_ROW (
  X_GUID            in      raw
);
-----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_GUID            in      raw,
  X_NAME            in      varchar2,
  X_SYSTEM_GUID     in      raw,
  X_PROTOCOL        in      varchar2,
  X_ADDRESS         in      varchar2,
  X_QUEUE_HANDLER   in      varchar2,
  X_QUEUE_NAME      in      varchar2,
  X_DIRECTION       in      varchar2,
  X_STATUS          in      varchar2,
  X_DISPLAY_NAME    in      varchar2,
  X_DESCRIPTION     in      varchar2,
  X_TYPE            in      varchar2 default 'AGENT',
  X_JAVA_QUEUE_HANDLER in   varchar2 default null
);
-----------------------------------------------------------------------------
/*#
 * Generates an XML message containing the complete information from the
 * WF_AGENTS table for the specified agent definition.
 * @param x_guid Agent GUID
 * @return Agent XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Agent Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evagtgen See the related online help
 */
function GENERATE (
  X_GUID         in raw
) return varchar2;
-----------------------------------------------------------------------------
/*#
 * Receives an XML message containing the complete information for an agent
 * definition and loads the information into the WF_AGENTS table.
 * @param x_message Agent XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Receive Agent Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evagtrec See the related online help
 */
procedure RECEIVE (
  X_MESSAGE      in varchar2
);
-----------------------------------------------------------------------------
end WF_AGENTS_PKG;

 

/
