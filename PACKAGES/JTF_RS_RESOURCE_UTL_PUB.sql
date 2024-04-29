--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_UTL_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_UTL_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrspns.pls 120.0 2005/05/11 08:21:18 appldev ship $ */
/*#
 * Resource Utility API
 * This API contains the some common procedures and functions
 * that is called from other Resource Manager APIs.
 * @rep:scope private
 * @rep:product JTF
 * @rep:displayname Resource Utility API
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
*/

  /*****************************************************************************************
   ******************************************************************************************/
/*#
 * End date Resource API
 * This procedure allows the user to end date a resource.
 * This will also end date the corresponding records from Salesreps and role relations tables, if any.
 * Even if the API name says end_date_employee, it is for end dating all type of resources.
 * @param P_API_VERSION API version
 * @param P_INIT_MSG_LIST Initialization of the message list
 * @param P_COMMIT Commit
 * @param P_RESOURCE_ID resource identifier
 * @param P_END_DATE_ACTIVE Date on which the resource is no longer active.
 * @param X_OBJECT_VER_NUMBER The object version number of the resource derives from the jtf_rs_resource_extns table.
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname End date Resource API
*/
PROCEDURE  end_date_employee
  (P_API_VERSION           IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID          IN   NUMBER,
   P_END_DATE_ACTIVE      IN   DATE,
   X_OBJECT_VER_NUMBER    IN OUT NOCOPY  NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2  ) ;

/*#
 * Add Message API
 * This procedure allows the user to add a message to the message stack.
 * This also accepts upto 2 tokens and corresponding values.
 * @param P_API_VERSION API version
 * @param P_MESSAGE_CODE Message Code
 * @param P_TOKEN1_NAME First Token Name
 * @param P_TOKEN1_VALUE First Token Value
 * @param P_TOKEN2_NAME Second Token Name
 * @param P_TOKEN2_VALUE Second Token Value
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname Add Message API
*/
PROCEDURE  add_message
  (P_API_VERSION           IN   NUMBER,
   P_MESSAGE_CODE          IN   VARCHAR2,
   P_TOKEN1_NAME           IN   VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
   P_TOKEN1_VALUE          IN   VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
   P_TOKEN2_NAME           IN   VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
   P_TOKEN2_VALUE          IN   VARCHAR2  DEFAULT FND_API.G_MISS_CHAR,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2
   ) ;

  /* Function to check if user has update access */

/*#
 * Validate Resource Update Access
 * Function to check if user has resource update access
 * @param p_resource_id Resource Id
 * @param p_resource_user_id User Id for the Resource
 * @return Update Access
 * @rep:scope private
 * @rep:displayname Validate Resource Update Access
*/
   Function    Validate_Update_Access( p_resource_id           number,
  			               p_resource_user_id      number default null
				     ) Return varchar2 ;

/*#
 * Validate Group Update Access
 * Function to check if logged in user has access to Update Group Membership/Hierarchy
 * @param p_group_id Group Id
 * @return Update Access
 * @rep:scope private
 * @rep:displayname Validate Group Update Access
*/
   Function    Group_Update_Access( p_group_id   IN  number default null) Return varchar2 ;

/*#
 * Validate Role Update Access
 * Function to check if logged in user has access to Update the roles
 * @return Update Access
 * @rep:scope private
 * @rep:displayname Validate Role Update Access
*/
   FUNCTION    Role_Update_Access RETURN VARCHAR2;

/*#
 * Validate if the user is HR manager
 * Function to check if user is HR manager for the resource.
 * @param p_resource_id Resource Id
 * @return Is HR Manager
 * @rep:scope private
 * @rep:displayname Validate if the user is HR manager
*/
   Function    Is_HR_Manager( p_resource_id           number)
   Return varchar2;

/*#
 * End date Group API
 * This procedure allows the user to end date group, all the group member roles and group relations for a group.
 * @param P_API_VERSION API version
 * @param P_INIT_MSG_LIST Initialization of the message list
 * @param P_COMMIT Commit
 * @param P_GROUP_ID Group identifier
 * @param P_END_DATE_ACTIVE Date on which the group is no longer active.
 * @param X_OBJECT_VER_NUMBER The object version number of the group derives from the jtf_rs_groups_b table.
 * @param X_RETURN_STATUS Output parameter for return status
 * @param X_MSG_COUNT Output parameter for number of user messages from this procedure
 * @param X_MSG_DATA Output parameter containing last user message from this procedure
 * @rep:scope private
 * @rep:lifecycle active
 * @rep:displayname End date Group API
*/
PROCEDURE  end_date_group
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_GROUP_ID             IN   NUMBER,
   P_END_DATE_ACTIVE      IN   DATE,
   X_OBJECT_VER_NUMBER    IN OUT NOCOPY  NUMBER,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2  ) ;

/* returns 'Y' for Yes and 'N' for No */
FUNCTION TAX_VENDOR_EXTENSION return VARCHAR2;
/* returns 'Y' for Yes and 'N' for No */
FUNCTION IS_GEOCODE_VALID(p_geocode IN VARCHAR2) return VARCHAR2;
/* returns 'Y' for Yes and 'N' for No */
FUNCTION IS_CITY_LIMIT_VALID(p_city_limit IN VARCHAR2) return VARCHAR2;

end jtf_rs_resource_utl_pub;

 

/
