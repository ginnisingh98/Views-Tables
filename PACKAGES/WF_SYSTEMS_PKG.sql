--------------------------------------------------------
--  DDL for Package WF_SYSTEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_SYSTEMS_PKG" AUTHID CURRENT_USER as
/* $Header: WFEVSYSS.pls 120.2 2005/11/30 05:18:11 vshanmug ship $ */
/*#
 * Provides APIs to communicate system definitions to and from the
 * WF_SYSTEMS table.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow System
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 * @rep:ihelp FND/@besrepapis See the related online help
 */

-----------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID        in out nocopy varchar2,
  X_GUID         in     raw,
  X_NAME         in     varchar2,
  X_MASTER_GUID  in     raw,
  X_DISPLAY_NAME in     varchar2,
  X_DESCRIPTION  in     varchar2
);
-----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_GUID         in raw,
  X_NAME         in varchar2,
  X_MASTER_GUID  in raw,
  X_DISPLAY_NAME in varchar2,
  X_DESCRIPTION  in varchar2
);
-----------------------------------------------------------------------------
procedure DELETE_ROW (
  X_GUID         in raw
);
-----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_GUID         in raw,
  X_NAME         in varchar2,
  X_MASTER_GUID  in raw,
  X_DISPLAY_NAME in varchar2,
  X_DESCRIPTION  in varchar2
);
-----------------------------------------------------------------------------
/*#
 * Generates an XML message containing the complete information from the
 * WF_SYSTEMS table for the specified system definition.
 * @param x_guid System GUID
 * @return System XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate System Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evsysgen See the related online help
 */
function GENERATE (
  X_GUID         in raw
) return varchar2;
-----------------------------------------------------------------------------
/*#
 * Receives an XML message containing the complete information for a
 * system definition and loads the information into the WF_SYSTEMS table.
 * @param x_message System XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Receive System Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evsysrec See the related online help
 */
procedure RECEIVE (
  X_MESSAGE      in varchar2
);
-----------------------------------------------------------------------------
end WF_SYSTEMS_PKG;

 

/
