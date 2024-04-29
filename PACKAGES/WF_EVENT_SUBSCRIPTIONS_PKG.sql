--------------------------------------------------------
--  DDL for Package WF_EVENT_SUBSCRIPTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_EVENT_SUBSCRIPTIONS_PKG" AUTHID CURRENT_USER as
/* $Header: WFEVSUBS.pls 120.1 2005/07/02 03:14:46 appldev ship $ */
/*#
 * Provides APIs to communicate event subscription definitions to and
 * from the WF_EVENT_SUBSCRIPTIONS table.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Event Subscription
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 * @rep:ihelp FND/@besrepapis See the related online help
 */

-----------------------------------------------------------------------------
procedure INSERT_ROW (
  X_ROWID              in out nocopy varchar2,
  X_GUID               in     raw,
  X_SYSTEM_GUID        in     raw,
  X_SOURCE_TYPE        in     varchar2,
  X_SOURCE_AGENT_GUID  in     raw,
  X_EVENT_FILTER_GUID  in     raw,
  X_PHASE              in     number,
  X_STATUS             in     varchar2,
  X_RULE_DATA          in     varchar2,
  X_OUT_AGENT_GUID     in     raw,
  X_TO_AGENT_GUID      in     raw,
  X_PRIORITY           in     number,
  X_RULE_FUNCTION      in     varchar2,
  X_WF_PROCESS_TYPE    in     varchar2,
  X_WF_PROCESS_NAME    in     varchar2,
  X_PARAMETERS         in     varchar2,
  X_OWNER_NAME         in     varchar2,
  X_OWNER_TAG          in     varchar2,
  X_CUSTOMIZATION_LEVEL in     varchar2,
  X_LICENSED_FLAG       in     varchar2 default 'N',
  X_DESCRIPTION        in     varchar2,
  X_EXPRESSION         in     varchar2 default null,
  X_ACTION_CODE        in     varchar2 default null,
  X_ON_ERROR_CODE      in     varchar2 default 'ABORT',
  X_JAVA_RULE_FUNC     in     varchar2 default null,
  X_MAP_CODE           in     varchar2 default null,
  X_STANDARD_CODE      in     varchar2 default null,
  X_STANDARD_TYPE      in     varchar2 default null
);
-----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_GUID               in     raw,
  X_SYSTEM_GUID        in     raw,
  X_SOURCE_TYPE        in     varchar2,
  X_SOURCE_AGENT_GUID  in     raw,
  X_EVENT_FILTER_GUID  in     raw,
  X_PHASE              in     number,
  X_STATUS             in     varchar2,
  X_RULE_DATA          in     varchar2,
  X_OUT_AGENT_GUID     in     raw,
  X_TO_AGENT_GUID      in     raw,
  X_PRIORITY           in     number,
  X_RULE_FUNCTION      in     varchar2,
  X_WF_PROCESS_TYPE    in     varchar2,
  X_WF_PROCESS_NAME    in     varchar2,
  X_PARAMETERS         in     varchar2,
  X_OWNER_NAME         in     varchar2,
  X_OWNER_TAG          in     varchar2,
  X_CUSTOMIZATION_LEVEL in     varchar2,
  X_LICENSED_FLAG       in     varchar2 default 'N',
  X_DESCRIPTION        in     varchar2,
  X_EXPRESSION         in     varchar2 default null,
  X_ACTION_CODE        in     varchar2 default null,
  X_ON_ERROR_CODE      in     varchar2 default 'ABORT',
  X_JAVA_RULE_FUNC     in     varchar2 default null,
  X_MAP_CODE           in     varchar2 default null,
  X_STANDARD_CODE      in     varchar2 default null,
  X_STANDARD_TYPE      in     varchar2 default null
);
-----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_GUID               in     raw,
  X_SYSTEM_GUID        in     raw,
  X_SOURCE_TYPE        in     varchar2,
  X_SOURCE_AGENT_GUID  in     raw,
  X_EVENT_FILTER_GUID  in     raw,
  X_PHASE              in     number,
  X_STATUS             in     varchar2,
  X_RULE_DATA          in     varchar2,
  X_OUT_AGENT_GUID     in     raw,
  X_TO_AGENT_GUID      in     raw,
  X_PRIORITY           in     number,
  X_RULE_FUNCTION      in     varchar2,
  X_WF_PROCESS_TYPE    in     varchar2,
  X_WF_PROCESS_NAME    in     varchar2,
  X_PARAMETERS         in     varchar2,
  X_OWNER_NAME         in     varchar2,
  X_OWNER_TAG          in     varchar2,
  X_CUSTOMIZATION_LEVEL in     varchar2,
  X_LICENSED_FLAG       in     varchar2 default 'N',
  X_DESCRIPTION        in     varchar2,
  X_EXPRESSION         in     varchar2 default null,
  X_ACTION_CODE        in     varchar2 default null,
  X_ON_ERROR_CODE      in     varchar2 default 'ABORT',
  X_JAVA_RULE_FUNC     in     varchar2 default null,
  X_MAP_CODE           in     varchar2 default null,
  X_STANDARD_CODE      in     varchar2 default null,
  X_STANDARD_TYPE      in     varchar2 default null
);
-----------------------------------------------------------------------------
procedure DELETE_ROW (
  X_GUID              in     raw
);
-----------------------------------------------------------------------------
procedure DELETE_SET (
  X_SYSTEM_GUID        in     raw       default null,
  X_SOURCE_TYPE        in     varchar2  default null,
  X_SOURCE_AGENT_GUID  in     raw       default null,
  X_EVENT_FILTER_GUID  in     raw       default null,
  X_PHASE              in     number    default null,
  X_STATUS             in     varchar2  default null,
  X_RULE_DATA          in     varchar2  default null,
  X_OUT_AGENT_GUID     in     raw       default null,
  X_TO_AGENT_GUID      in     raw       default null,
  X_PRIORITY           in     number    default null,
  X_RULE_FUNCTION      in     varchar2  default null,
  X_WF_PROCESS_TYPE    in     varchar2  default null,
  X_WF_PROCESS_NAME    in     varchar2  default null,
  X_PARAMETERS         in     varchar2  default null,
  X_OWNER_NAME         in     varchar2  default null,
  X_OWNER_TAG          in     varchar2  default null,
  X_DESCRIPTION        in     varchar2  default null,
  X_EXPRESSION         in     varchar2  default null,
  X_ACTION_CODE        in     varchar2 default null,
  X_ON_ERROR_CODE      in     varchar2 default 'ABORT',
  X_JAVA_RULE_FUNC     in     varchar2 default null,
  X_MAP_CODE           in     varchar2 default null,
  X_STANDARD_CODE      in     varchar2 default null,
  X_STANDARD_TYPE      in     varchar2 default null
);
-----------------------------------------------------------------------------
/*#
 * Generates an XML message containing the complete information from the
 * WF_EVENT_SUBSCRIPTIONS table for the specified event subscription definition.
 * @param x_guid Event Subscription GUID
 * @return Event Subscription XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Event Subscription Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evsubgen See the related online help
 */
function GENERATE (
  X_GUID         in raw
) return varchar2;
-----------------------------------------------------------------------------
/*#
 * Receives an XML message containing the complete information for an event
 * subscription definition and loads the information into the
 * WF_EVENT_SUBSCRIPTIONS table.
 * @param x_message Event Subscription XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Receive Event Subscription Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evsubrec See the related online help
 */
procedure RECEIVE (
  X_MESSAGE      in varchar2
);
-----------------------------------------------------------------------------
end WF_EVENT_SUBSCRIPTIONS_PKG;

 

/
