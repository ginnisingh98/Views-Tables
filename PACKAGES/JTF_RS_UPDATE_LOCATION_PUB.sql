--------------------------------------------------------
--  DDL for Package JTF_RS_UPDATE_LOCATION_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_UPDATE_LOCATION_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrsugs.pls 120.0 2005/05/11 08:22:46 appldev ship $ */
/*#
 * Resource Location Update API
 * This API contains the procedure to update the Resource record with the location.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Resource Location Update API
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
*/

/*#
 * Update Resource Location API
 * This procedure allows the user to update a resource record with the location.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_location Resource Location
 * @param p_object_version_num The object version number of the resource derives from the jtf_rs_resource_extns table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Resource Location API
*/
  PROCEDURE  update_resource
  (P_API_VERSION             IN   NUMBER,
   P_INIT_MSG_LIST           IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT                  IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID             IN   JTF_RS_RESOURCE_EXTNS.RESOURCE_ID%TYPE,
   P_LOCATION                IN   MDSYS.SDO_GEOMETRY  ,
   P_OBJECT_VERSION_NUM      IN OUT NOCOPY  JTF_RS_RESOURCE_EXTNS.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS           OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT               OUT NOCOPY  NUMBER,
   X_MSG_DATA                OUT NOCOPY  VARCHAR2
  );


END jtf_rs_update_location_pub;

 

/
