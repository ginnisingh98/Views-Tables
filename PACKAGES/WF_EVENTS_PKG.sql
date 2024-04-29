--------------------------------------------------------
--  DDL for Package WF_EVENTS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."WF_EVENTS_PKG" AUTHID CURRENT_USER as
/* $Header: WFEVEVTS.pls 120.2 2008/01/10 19:29:23 vshanmug ship $ */
/*#
 * Provides APIs to communicate event definitions to and from the
 * WF_EVENTS table.
 * @rep:scope public
 * @rep:product OWF
 * @rep:displayname Workflow Event
 * @rep:lifecycle active
 * @rep:compatibility S
 * @rep:category BUSINESS_ENTITY WF_EVENT
 * @rep:ihelp FND/@besrepapis See the related online help
 */

g_seeduser varchar2(320) := 'DATAMERGE';
g_Mode varchar2(8) := null;

procedure setMode;

procedure FWKsetMode;

procedure LoadersetMode(x_mode in varchar2);

function is_product_licensed( X_OWNER_TAG in varchar2)
return varchar2;

function is_update_allowed(X_CUSTOM_LEVEL_NEW in varchar2,
			   X_CUSTOM_LEVEL_OLD in varchar2) return varchar2;

procedure INSERT_ROW (
  X_ROWID              in out nocopy varchar2,
  X_GUID               in     raw,
  X_NAME               in     varchar2,
  X_TYPE               in     varchar2,
  X_STATUS             in     varchar2,
  X_GENERATE_FUNCTION  in     varchar2,
  X_OWNER_NAME         in     varchar2,
  X_OWNER_TAG          in     varchar2,
  X_DISPLAY_NAME       in     varchar2,
  X_DESCRIPTION        in     varchar2,
  X_CUSTOMIZATION_LEVEL in    varchar2 default 'L',
  X_LICENSED_FLAG      in     varchar2 default 'Y',
  X_JAVA_GENERATE_FUNC in     varchar2 default null,
  X_IREP_ANNOTATION    in     varchar2 default null
);
-----------------------------------------------------------------------------
procedure UPDATE_ROW (
  X_GUID               in  raw,
  X_NAME               in  varchar2,
  X_TYPE               in  varchar2,
  X_STATUS             in  varchar2,
  X_GENERATE_FUNCTION  in  varchar2,
  X_OWNER_NAME         in  varchar2,
  X_OWNER_TAG          in  varchar2,
  X_DISPLAY_NAME       in  varchar2,
  X_DESCRIPTION        in  varchar2,
  X_CUSTOMIZATION_LEVEL in varchar2 default 'L',
  X_LICENSED_FLAG      in  varchar2 default 'Y',
  X_JAVA_GENERATE_FUNC in  varchar2 default null,
  X_IREP_ANNOTATION    in  varchar2 default null
);
-----------------------------------------------------------------------------
procedure DELETE_ROW (
  X_GUID               in  raw
);
-----------------------------------------------------------------------------
procedure LOAD_ROW (
  X_GUID               in  raw,
  X_NAME               in  varchar2,
  X_TYPE               in  varchar2,
  X_STATUS             in  varchar2,
  X_GENERATE_FUNCTION  in  varchar2,
  X_OWNER_NAME         in  varchar2,
  X_OWNER_TAG          in  varchar2,
  X_DISPLAY_NAME       in  varchar2,
  X_DESCRIPTION        in  varchar2,
  X_CUSTOMIZATION_LEVEL in varchar2 default 'L',
  X_LICENSED_FLAG      in  varchar2 default 'Y',
  X_JAVA_GENERATE_FUNC in  varchar2 default null,
  X_IREP_ANNOTATION    in  varchar2 default null
);
-----------------------------------------------------------------------------
procedure ADD_LANGUAGE;
-----------------------------------------------------------------------------
/*#
 * Generates an XML message containing the complete information from the
 * WF_EVENTS table for the specified event definition.
 * @param x_guid Event GUID
 * @return Event XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Generate Event Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evtgen See the related online help
 */
function GENERATE (
  X_GUID               in raw
) return varchar2;
-----------------------------------------------------------------------------
/*#
 * Receives an XML message containing the complete information for an event
 * definition and loads the information into the WF_EVENTS table.
 * @param x_message Event XML Message
 * @rep:scope public
 * @rep:lifecycle active
 * @rep:displayname Receive Event Message
 * @rep:compatibility S
 * @rep:ihelp FND/@besrepapis#a_evtrec See the related online help
 */
procedure RECEIVE (
  X_MESSAGE            in varchar2
);
-----------------------------------------------------------------------------
end WF_EVENTS_PKG;

/
