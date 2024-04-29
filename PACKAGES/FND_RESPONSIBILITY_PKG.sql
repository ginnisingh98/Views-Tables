--------------------------------------------------------
--  DDL for Package FND_RESPONSIBILITY_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_RESPONSIBILITY_PKG" AUTHID CURRENT_USER as
/* $Header: AFSCRSPS.pls 120.3 2005/10/31 09:03:39 fskinner ship $ */
/*#
* Table Handler to insert or update data in FND_RESPONSIBILITY table.
* @rep:scope public
* @rep:product FND
* @rep:displayname Responsibility
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_RESPONSIBILITY
* @rep:ihelp FND/@o_funcsec#o_funcsec See the related online help
*/


procedure INSERT_ROW (
  X_ROWID			in out	nocopy VARCHAR2,
  X_RESPONSIBILITY_ID 		in	NUMBER,
  X_APPLICATION_ID 		in	NUMBER,
  X_WEB_HOST_NAME 		in	VARCHAR2,
  X_WEB_AGENT_NAME 		in	VARCHAR2,
  X_DATA_GROUP_APPLICATION_ID 	in	NUMBER,
  X_DATA_GROUP_ID 		in	NUMBER,
  X_MENU_ID 			in	NUMBER,
  X_START_DATE 			in	DATE,
  X_END_DATE 			in	DATE,
  X_GROUP_APPLICATION_ID 	in	NUMBER,
  X_REQUEST_GROUP_ID 		in	NUMBER,
  X_VERSION 			in	VARCHAR2,
  X_RESPONSIBILITY_KEY 		in	VARCHAR2,
  X_RESPONSIBILITY_NAME 	in	VARCHAR2,
  X_DESCRIPTION 		in	VARCHAR2,
  X_CREATION_DATE 		in	DATE,
  X_CREATED_BY 			in	NUMBER,
  X_LAST_UPDATE_DATE 		in	DATE,
  X_LAST_UPDATED_BY 		in	NUMBER,
  X_LAST_UPDATE_LOGIN		in	NUMBER);

procedure LOCK_ROW (
  X_RESPONSIBILITY_ID 		in	NUMBER,
  X_APPLICATION_ID 		in	NUMBER,
  X_WEB_HOST_NAME 		in	VARCHAR2,
  X_WEB_AGENT_NAME 		in	VARCHAR2,
  X_DATA_GROUP_APPLICATION_ID 	in	NUMBER,
  X_DATA_GROUP_ID 		in	NUMBER,
  X_MENU_ID 			in	NUMBER,
  X_START_DATE 			in	DATE,
  X_END_DATE 			in	DATE,
  X_GROUP_APPLICATION_ID 	in	NUMBER,
  X_REQUEST_GROUP_ID 		in	NUMBER,
  X_VERSION 			in	VARCHAR2,
  X_RESPONSIBILITY_KEY 		in	VARCHAR2,
  X_RESPONSIBILITY_NAME 	in	VARCHAR2,
  X_DESCRIPTION 		in	VARCHAR2 );

procedure UPDATE_ROW (
  X_RESPONSIBILITY_ID 		in	NUMBER,
  X_APPLICATION_ID 		in	NUMBER,
  X_WEB_HOST_NAME 		in	VARCHAR2,
  X_WEB_AGENT_NAME 		in	VARCHAR2,
  X_DATA_GROUP_APPLICATION_ID 	in	NUMBER,
  X_DATA_GROUP_ID 		in	NUMBER,
  X_MENU_ID 			in	NUMBER,
  X_START_DATE 			in	DATE,
  X_END_DATE 			in	DATE,
  X_GROUP_APPLICATION_ID 	in	NUMBER,
  X_REQUEST_GROUP_ID 		in	NUMBER,
  X_VERSION 			in	VARCHAR2,
  X_RESPONSIBILITY_KEY		in	VARCHAR2,
  X_RESPONSIBILITY_NAME 	in	VARCHAR2,
  X_DESCRIPTION 		in	VARCHAR2,
  X_LAST_UPDATE_DATE 		in	DATE,
  X_LAST_UPDATED_BY 		in	NUMBER,
  X_LAST_UPDATE_LOGIN		in	NUMBER );

procedure TRANSLATE_ROW (
  X_APP_SHORT_NAME		in	VARCHAR2,
  X_RESP_KEY			in	VARCHAR2,
  X_RESPONSIBILITY_NAME		in	VARCHAR2,
  X_DESCRIPTION                 in 	VARCHAR2,
  X_OWNER                       in	VARCHAR2);

procedure LOAD_ROW (
  X_APP_SHORT_NAME		in	VARCHAR2,
  X_RESP_KEY			in	VARCHAR2,
  X_RESPONSIBILITY_ID		in	VARCHAR2,
  X_RESPONSIBILITY_NAME		in	VARCHAR2,
  X_OWNER                       in	VARCHAR2,
  X_DATA_GROUP_APP_SHORT_NAME	in	VARCHAR2,
  X_DATA_GROUP_NAME		in	VARCHAR2,
  X_MENU_NAME			in	VARCHAR2,
  X_START_DATE			in	VARCHAR2,
  X_END_DATE			in	VARCHAR2,
  X_DESCRIPTION			in	VARCHAR2,
  X_GROUP_APP_SHORT_NAME	in	VARCHAR2,
  X_REQUEST_GROUP_NAME		in	VARCHAR2,
  X_VERSION			in	VARCHAR2,
  X_WEB_HOST_NAME		in	VARCHAR2,
  X_WEB_AGENT_NAME 		in	VARCHAR2 );

procedure DELETE_ROW (
  X_RESPONSIBILITY_ID 		in	NUMBER,
  X_APPLICATION_ID 		in	NUMBER );

procedure ADD_LANGUAGE;

-- Overloaded !!
procedure TRANSLATE_ROW (
  X_APP_SHORT_NAME		in	VARCHAR2,
  X_RESP_KEY			in	VARCHAR2,
  X_RESPONSIBILITY_NAME		in	VARCHAR2,
  X_DESCRIPTION                 in 	VARCHAR2,
  X_OWNER                       in	VARCHAR2,
  X_CUSTOM_MODE                 in 	VARCHAR2,
  X_LAST_UPDATE_DATE            in 	VARCHAR2);

-- Overloaded!!
    /*#
     * Creates or updates User's Responsibility data as appropriate.
     * @param x_app_short_name Application Short Name
     * @param x_resp_key Responsibility Key
     * @param x_responsibility_id Responsibility ID
     * @param x_responsibility_name Responsibility Name
     * @param x_owner Owner Name
     * @param x_data_group_app_short_name Application Short Name attached with Data Group
     * @param x_data_group_name Data Group Name
     * @param x_menu_name Menu Name Assigned to Responsibility
     * @param x_start_date Responsibility Effective Start Date
     * @param x_end_date Responsibility Effective End Date
     * @param x_description Responsibility Description
     * @param x_group_app_short_name Application Short Name attached with Request Group
     * @param x_request_group_name Request Group Name
     * @param x_version Version
     * @param x_web_host_name Web Host Name
     * @param x_web_agent_name Web Agent Name
     * @param x_custom_mode Custom Mode
     * @param x_last_update_date Creation/Update Date
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Create/Update Responsibility
     * @rep:compatibility S
     * @rep:ihelp FND/@dev_p_funcworks#dev_p_funcworks See the related online help
     */
procedure LOAD_ROW (
  X_APP_SHORT_NAME		in	VARCHAR2,
  X_RESP_KEY			in	VARCHAR2,
  X_RESPONSIBILITY_ID		in	VARCHAR2,
  X_RESPONSIBILITY_NAME		in	VARCHAR2,
  X_OWNER                       in	VARCHAR2,
  X_DATA_GROUP_APP_SHORT_NAME	in	VARCHAR2,
  X_DATA_GROUP_NAME		in	VARCHAR2,
  X_MENU_NAME			in	VARCHAR2,
  X_START_DATE			in	VARCHAR2,
  X_END_DATE			in	VARCHAR2,
  X_DESCRIPTION			in	VARCHAR2,
  X_GROUP_APP_SHORT_NAME	in	VARCHAR2,
  X_REQUEST_GROUP_NAME		in	VARCHAR2,
  X_VERSION			in	VARCHAR2,
  X_WEB_HOST_NAME		in	VARCHAR2,
  X_WEB_AGENT_NAME 		in	VARCHAR2,
  X_CUSTOM_MODE                 in 	VARCHAR2,
  X_LAST_UPDATE_DATE            in 	VARCHAR2);

--------------------------------------------------------------------------
/*
** resp_synch - The centralized routine for communicating resp changes
**              with wf and entity mgr.
*/
PROCEDURE resp_synch(p_application_id    in number,
                     p_responsibility_id in number);
--------------------------------------------------------------------------

-- Overloaded!!
    /*#
     * Creates or updates User's Responsibility data as appropriate.
     * @param x_app_short_name Application Short Name
     * @param x_resp_key Responsibility Key
     * @param x_responsibility_name Responsibility Name
     * @param x_owner Owner Name
     * @param x_data_group_app_short_name Application Short Name attached with Data Group
     * @param x_data_group_name Data Group Name
     * @param x_menu_name Menu Name Assigned to Responsibility
     * @param x_start_date Responsibility Effective Start Date
     * @param x_end_date Responsibility Effective End Date
     * @param x_description Responsibility Description
     * @param x_group_app_short_name Application Short Name attached with Request Group
     * @param x_request_group_name Request Group Name
     * @param x_version Version
     * @param x_web_host_name Web Host Name
     * @param x_web_agent_name Web Agent Name
     * @param x_custom_mode Custom Mode
     * @param x_last_update_date Creation/Update Date
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Create/Update Responsibility
     * @rep:compatibility S
     * @rep:ihelp FND/@dev_p_funcworks#dev_p_funcworks See the related online help
     */
procedure LOAD_ROW (
  X_APP_SHORT_NAME              in      VARCHAR2,
  X_RESP_KEY                    in      VARCHAR2,
  X_RESPONSIBILITY_NAME         in      VARCHAR2,
  X_OWNER                       in      VARCHAR2,
  X_DATA_GROUP_APP_SHORT_NAME   in      VARCHAR2,
  X_DATA_GROUP_NAME             in      VARCHAR2,
  X_MENU_NAME                   in      VARCHAR2,
  X_START_DATE                  in      VARCHAR2,
  X_END_DATE                    in      VARCHAR2,
  X_DESCRIPTION                 in      VARCHAR2,
  X_GROUP_APP_SHORT_NAME        in      VARCHAR2,
  X_REQUEST_GROUP_NAME          in      VARCHAR2,
  X_VERSION                     in      VARCHAR2,
  X_WEB_HOST_NAME               in      VARCHAR2,
  X_WEB_AGENT_NAME              in      VARCHAR2,
  X_CUSTOM_MODE                 in      VARCHAR2,
  X_LAST_UPDATE_DATE            in      VARCHAR2);

end FND_RESPONSIBILITY_PKG;

 

/
