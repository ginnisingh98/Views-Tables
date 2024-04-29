--------------------------------------------------------
--  DDL for Package JTF_RS_RES_AVAILABILITY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RES_AVAILABILITY_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrspzs.pls 120.0 2005/05/11 08:21:32 appldev ship $ */
/*#
 * Resource Availability create, update and delete API
 * This API contains the procedures to insert, update and delete resource availability record.
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Resource Availability API
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE_AVAILABILITY
*/
  /*****************************************************************************************
   This is a public API that user API will invoke.
   It provides procedures for managing seed data of jtf_rs_res_availability tables
   create, update and delete rows
   Its main procedures are as following:
   Create res_availability
   Update res_availability
   Delete res_availability
   Calls to these procedures will call procedures of jtf_rs_res_availability_pvt
   to do inserts, updates and deletes into tables.
   ******************************************************************************************/


  /* Procedure to create the resource availability
	based on input values passed by calling routines. */

/*#
 * Create Resource Availability API
 * This procedure allows the user to create resource availability record.
 * By default, all resource are availabile and if we create a availability record then, that resource is not avilable.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_resource_id Resource Identifier
 * @param p_available_flag Available Flag.
 * @param p_reason_code Reason Code
 * @param p_start_date Date on which the resource is not available.
 * @param p_end_date Date on which the resource is available.
 * @param p_mode_of_availability Mode of Availability
 * @param p_attribute1 Descriptive flexfield Segment 1
 * @param p_attribute2 Descriptive flexfield Segment 2
 * @param p_attribute3 Descriptive flexfield Segment 3
 * @param p_attribute4 Descriptive flexfield Segment 4
 * @param p_attribute5 Descriptive flexfield Segment 5
 * @param p_attribute6 Descriptive flexfield Segment 6
 * @param p_attribute7 Descriptive flexfield Segment 7
 * @param p_attribute8 Descriptive flexfield Segment 8
 * @param p_attribute9 Descriptive flexfield Segment 9
 * @param p_attribute10 Descriptive flexfield Segment 10
 * @param p_attribute11 Descriptive flexfield Segment 11
 * @param p_attribute12 Descriptive flexfield Segment 12
 * @param p_attribute13 Descriptive flexfield Segment 13
 * @param p_attribute14 Descriptive flexfield Segment 14
 * @param p_attribute15 Descriptive flexfield Segment 15
 * @param p_attribute_category Descriptive flexfield structure definition column
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @param x_availability_id Out parameter for resource availability Identifier
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Create Resource Availability API
*/
  PROCEDURE  create_res_availability
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_RESOURCE_ID          IN   JTF_RS_RES_AVAILABILITY.RESOURCE_ID%TYPE,
   P_AVAILABLE_FLAG       IN   JTF_RS_RES_AVAILABILITY.AVAILABLE_FLAG%TYPE,
   P_REASON_CODE          IN   JTF_RS_RES_AVAILABILITY.REASON_CODE%TYPE  DEFAULT  NULL,
   P_START_DATE           IN   JTF_RS_RES_AVAILABILITY.START_DATE%TYPE   DEFAULT  NULL,
   P_END_DATE             IN   JTF_RS_RES_AVAILABILITY.END_DATE%TYPE     DEFAULT  NULL,
   P_MODE_OF_AVAILABILITY IN   JTF_RS_RES_AVAILABILITY.MODE_OF_AVAILABILITY%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE1%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE2		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE2%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE3		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE3%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE4		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE4%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE5		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE5%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE6		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE6%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE7		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE7%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE8		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE8%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE9		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE9%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE10	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE10%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE11	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE11%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE12	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE12%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE13	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE13%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE14	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE14%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE15	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE15%TYPE   DEFAULT  NULL,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE_CATEGORY%TYPE   DEFAULT  NULL,
   X_RETURN_STATUS        OUT NOCOPY  VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY  NUMBER,
   X_MSG_DATA             OUT NOCOPY  VARCHAR2,
   X_AVAILABILITY_ID      OUT NOCOPY  JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE  );


  /* Procedure to update resource availability
	based on input values passed by calling routines. */
/*#
 * Update Resource Availability API
 * This procedure allows the user to update resource availability record.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_availability_id Availability Identifier
 * @param p_resource_id Resource Identifier
 * @param p_available_flag Available Flag.
 * @param p_reason_code Reason Code
 * @param p_start_date Date on which the resource is not available.
 * @param p_end_date Date on which the resource is available.
 * @param p_mode_of_availability Mode of Availability
 * @param p_object_version_num The object version number of the resource avilability derives from the jtf_rs_res_availability table.
 * @param p_attribute1 Descriptive flexfield Segment 1
 * @param p_attribute2 Descriptive flexfield Segment 2
 * @param p_attribute3 Descriptive flexfield Segment 3
 * @param p_attribute4 Descriptive flexfield Segment 4
 * @param p_attribute5 Descriptive flexfield Segment 5
 * @param p_attribute6 Descriptive flexfield Segment 6
 * @param p_attribute7 Descriptive flexfield Segment 7
 * @param p_attribute8 Descriptive flexfield Segment 8
 * @param p_attribute9 Descriptive flexfield Segment 9
 * @param p_attribute10 Descriptive flexfield Segment 10
 * @param p_attribute11 Descriptive flexfield Segment 11
 * @param p_attribute12 Descriptive flexfield Segment 12
 * @param p_attribute13 Descriptive flexfield Segment 13
 * @param p_attribute14 Descriptive flexfield Segment 14
 * @param p_attribute15 Descriptive flexfield Segment 15
 * @param p_attribute_category Descriptive flexfield structure definition column
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Update Resource Availability API
*/
  PROCEDURE  update_res_availability
  (P_API_VERSION          IN   NUMBER,
   P_INIT_MSG_LIST        IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN   VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_AVAILABILITY_ID      IN   JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE,
   P_RESOURCE_ID          IN   JTF_RS_RES_AVAILABILITY.RESOURCE_ID%TYPE   DEFAULT  FND_API.G_MISS_NUM,
   P_AVAILABLE_FLAG       IN   JTF_RS_RES_AVAILABILITY.AVAILABLE_FLAG%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_REASON_CODE          IN   JTF_RS_RES_AVAILABILITY.REASON_CODE%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_START_DATE           IN   JTF_RS_RES_AVAILABILITY.START_DATE%TYPE   DEFAULT  FND_API.G_MISS_DATE,
   P_END_DATE             IN   JTF_RS_RES_AVAILABILITY.END_DATE%TYPE     DEFAULT  FND_API.G_MISS_DATE,
   P_MODE_OF_AVAILABILITY IN   JTF_RS_RES_AVAILABILITY.MODE_OF_AVAILABILITY%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_OBJECT_VERSION_NUM   IN OUT NOCOPY JTF_RS_RES_AVAILABILITY.OBJECT_VERSION_NUMBER%TYPE,
   P_ATTRIBUTE1		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE1%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE2		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE2%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE3		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE3%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE4		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE4%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE5		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE5%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE6		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE6%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE7		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE7%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE8		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE8%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE9		  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE9%TYPE  DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE10	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE10%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE11	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE11%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE12	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE12%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE13	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE13%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE14	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE14%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE15	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE15%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   P_ATTRIBUTE_CATEGORY	  IN   JTF_RS_RES_AVAILABILITY.ATTRIBUTE_CATEGORY%TYPE DEFAULT  FND_API.G_MISS_CHAR,
   X_RETURN_STATUS       OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT           OUT NOCOPY    NUMBER,
   X_MSG_DATA            OUT NOCOPY    VARCHAR2
  );


  /* Procedure to delete the resource availability */

/*#
 * Delete Resource Availability API
 * This procedure allows the user to delete resource availability record.
 * By default, all resource are availabile and if we delete a availability record then, that resource is avilable.
 * @param p_api_version API version
 * @param p_init_msg_list Initialization of the message list
 * @param p_commit Commit
 * @param p_availability_id Availability Identifier
 * @param p_object_version_num The object version number of the resource avilability derives from the jtf_rs_res_availability table.
 * @param x_return_status Output parameter for return status
 * @param x_msg_count Output parameter for number of user messages from this procedure
 * @param x_msg_data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:lifecycle active
 * @rep:displayname Delete Resource Availability API
*/
  PROCEDURE  delete_res_availability
  (P_API_VERSION          IN     NUMBER,
   P_INIT_MSG_LIST        IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_COMMIT               IN     VARCHAR2   DEFAULT  FND_API.G_FALSE,
   P_AVAILABILITY_ID      IN     JTF_RS_RES_AVAILABILITY.AVAILABILITY_ID%TYPE,
   P_OBJECT_VERSION_NUM   IN     JTF_RS_RES_AVAILABILITY.OBJECT_VERSION_NUMBER%TYPE,
   X_RETURN_STATUS        OUT NOCOPY    VARCHAR2,
   X_MSG_COUNT            OUT NOCOPY    NUMBER,
   X_MSG_DATA             OUT NOCOPY    VARCHAR2
  );

END JTF_RS_RES_AVAILABILITY_PUB;

 

/
