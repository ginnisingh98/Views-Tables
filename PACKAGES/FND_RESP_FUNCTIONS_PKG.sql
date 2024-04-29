--------------------------------------------------------
--  DDL for Package FND_RESP_FUNCTIONS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_RESP_FUNCTIONS_PKG" AUTHID CURRENT_USER as
 /* $Header: AFSCRFNS.pls 120.1 2005/07/02 03:09:19 appldev ship $ */
/*#
* Table Handler to insert or update data in FND_RESP_FUNCTIONS table.
* @rep:scope public
* @rep:product FND
* @rep:displayname Responsibility Function
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_FUNC_SECURITY
* @rep:ihelp FND/@o_funcsec#o_funcsec See the related online help
*/


procedure INSERT_ROW (
  X_ROWID 		in out 	nocopy VARCHAR2,
  X_APPLICATION_ID 	in	NUMBER,
  X_RESPONSIBILITY_ID	in	NUMBER,
  X_ACTION_ID 		in 	NUMBER,
  X_RULE_TYPE 		in	VARCHAR2,
  X_CREATED_BY          in      NUMBER,
  X_CREATION_DATE       in      DATE,
  X_LAST_UPDATED_BY     in      NUMBER,
  X_LAST_UPDATE_DATE    in      DATE,
  X_LAST_UPDATE_LOGIN   in      NUMBER );

procedure LOCK_ROW (
  X_APPLICATION_ID	in	NUMBER,
  X_RESPONSIBILITY_ID 	in	NUMBER,
  X_ACTION_ID 		in	NUMBER,
  X_RULE_TYPE 		in	VARCHAR2 );

procedure UPDATE_ROW (
  X_APPLICATION_ID 	in	NUMBER,
  X_RESPONSIBILITY_ID 	in	NUMBER,
  X_ACTION_ID 		in 	NUMBER,
  X_RULE_TYPE 		in	VARCHAR2,
  X_LAST_UPDATED_BY     in      NUMBER,
  X_LAST_UPDATE_DATE    in      DATE,
  X_LAST_UPDATE_LOGIN   in      NUMBER );

procedure DELETE_ROW (
  X_APPLICATION_ID 	in	NUMBER,
  X_RESPONSIBILITY_ID 	in	NUMBER,
  X_RULE_TYPE    	in	VARCHAR2,
  X_ACTION_ID 		in	NUMBER );

procedure LOAD_ROW (
  X_APP_SHORT_NAME      in	VARCHAR2,
  X_RESP_KEY		in	VARCHAR2,
  X_RULE_TYPE		in	VARCHAR2,
  X_ACTION		in	VARCHAR2,
  X_OWNER               in      VARCHAR2 );

--Overloaded !!
    /*#
     * Creates or updates data in FND_RESP_FUNCTIONS as
     * appropriate.
     * @param x_app_short_name Application Short Name
     * @param x_resp_key Responsibility Key
     * @param x_rule_type Rule Type
     * @param x_action Action
     * @param x_owner Owner Name
     * @param x_custom_mode Custom Mode
     * @param x_last_update_date Insert/Update Date
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Create/Update Responsibility Function
     * @rep:compatibility S
     * @rep:ihelp FND/@dev_p_funcworks#dev_p_funcworks See the related online help
     */
procedure LOAD_ROW (
  X_APP_SHORT_NAME      in	VARCHAR2,
  X_RESP_KEY		in	VARCHAR2,
  X_RULE_TYPE		in	VARCHAR2,
  X_ACTION		in	VARCHAR2,
  X_OWNER               in      VARCHAR2,
  X_CUSTOM_MODE         in 	VARCHAR2,
  X_LAST_UPDATE_DATE    in 	VARCHAR2);


end FND_RESP_FUNCTIONS_PKG;

 

/
