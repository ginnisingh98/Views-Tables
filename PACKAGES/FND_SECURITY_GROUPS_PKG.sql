--------------------------------------------------------
--  DDL for Package FND_SECURITY_GROUPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FND_SECURITY_GROUPS_PKG" AUTHID CURRENT_USER as
/* $Header: AFSCGRPS.pls 120.3 2006/02/13 01:50:20 stadepal ship $ */
/*#
* Table Handler to insert or update data in FND_SECURITY_GROUPS table.
* @rep:scope public
* @rep:product FND
* @rep:displayname Security Group
* @rep:lifecycle active
* @rep:compatibility S
* @rep:category BUSINESS_ENTITY FND_USER
*/


procedure INSERT_ROW (
  X_ROWID 		in out	nocopy VARCHAR2,
  X_SECURITY_GROUP_ID 	in	NUMBER,
  X_SECURITY_GROUP_KEY  in	VARCHAR2,
  X_SECURITY_GROUP_NAME	in 	VARCHAR2,
  X_DESCRIPTION 	in 	VARCHAR2,
  X_CREATION_DATE 	in 	DATE,
  X_CREATED_BY 		in 	NUMBER,
  X_LAST_UPDATE_DATE 	in 	DATE,
  X_LAST_UPDATED_BY 	in 	NUMBER,
  X_LAST_UPDATE_LOGIN 	in 	NUMBER);

procedure LOCK_ROW (
  X_SECURITY_GROUP_ID 	in 	NUMBER,
  X_SECURITY_GROUP_KEY 	in	VARCHAR2,
  X_SECURITY_GROUP_NAME in 	VARCHAR2,
  X_DESCRIPTION 	in	VARCHAR2);

    /*#
     * Updates Security Group data -- Security_Group_Name & Description and also
     * calls fnd_user_resp_groups_api.sync_roles_all_resps api if there's a
     * change in Security_Group_name to update the security group name in the
     * display name of all the roles for this security group key.
     * @param x_security_group_id Security Group Id, Primary Key of the table
     * @param x_security_group_key Security Group Key, Unique Key of the table
     * @param x_security_group_name Security Group Name
     * @param x_description Description
     * @param x_last_update_date Date on which record is updated
     * @param x_last_updated_by User_Id of the User that has updated the record
     * @param x_last_update_login Last Update Login
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Update Security Group
     * @rep:compatibility S
     */
procedure UPDATE_ROW (
  X_SECURITY_GROUP_ID	in 	NUMBER,
  X_SECURITY_GROUP_KEY 	in	VARCHAR2,
  X_SECURITY_GROUP_NAME in 	VARCHAR2,
  X_DESCRIPTION 	in 	VARCHAR2,
  X_LAST_UPDATE_DATE 	in 	DATE,
  X_LAST_UPDATED_BY 	in 	NUMBER,
  X_LAST_UPDATE_LOGIN 	in 	NUMBER);

procedure LOAD_ROW (
  X_SECURITY_GROUP_KEY	in 	VARCHAR2,
  X_OWNER               in	VARCHAR2,
  X_SECURITY_GROUP_NAME	in	VARCHAR2,
  X_DESCRIPTION		in	VARCHAR2);

procedure TRANSLATE_ROW (
  X_SECURITY_GROUP_KEY	in 	VARCHAR2,
  X_OWNER               in	VARCHAR2,
  X_SECURITY_GROUP_NAME	in	VARCHAR2,
  X_DESCRIPTION		in	VARCHAR2);

procedure DELETE_ROW (
  X_SECURITY_GROUP_ID 	in 	NUMBER);

procedure ADD_LANGUAGE;

-- Overloaded Routines!!

    /*#
     * Creates or updates Security Group data as appropriate.
     * @param x_security_group_key Security Group Key
     * @param x_owner Owner Name
     * @param x_security_group_name Security Group Name
     * @param x_description Description
     * @param x_custom_mode Custom Mode
     * @param x_last_update_date Insert/Update Date
     * @rep:scope public
     * @rep:lifecycle active
     * @rep:displayname Create/Update Security Group
     * @rep:compatibility S
     */
procedure LOAD_ROW (
  X_SECURITY_GROUP_KEY	in 	VARCHAR2,
  X_OWNER               in	VARCHAR2,
  X_SECURITY_GROUP_NAME	in	VARCHAR2,
  X_DESCRIPTION		in	VARCHAR2,
  X_CUSTOM_MODE         in 	VARCHAR2,
  X_LAST_UPDATE_DATE    in 	VARCHAR2);

procedure TRANSLATE_ROW (
  X_SECURITY_GROUP_KEY	in 	VARCHAR2,
  X_OWNER               in	VARCHAR2,
  X_SECURITY_GROUP_NAME	in	VARCHAR2,
  X_DESCRIPTION		in	VARCHAR2,
  X_CUSTOM_MODE         in 	VARCHAR2,
  X_LAST_UPDATE_DATE    in 	VARCHAR2);

end FND_SECURITY_GROUPS_PKG;

 

/
