--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_VALUES_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_VALUES_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfrspcs.pls 120.0 2005/05/11 08:21:05 appldev ship $ */
/*#
 * This package contains procedures to maintain resource parameter
 * values
 * @rep:scope internal
 * @rep:product JTF
 * @rep:displayname Resource Values Package
 * @rep:category BUSINESS_ENTITY JTF_RS_RESOURCE
 */


   TYPE jtf_rs_values_user_hook is RECORD (
      resource_id             NUMBER,
      resource_param_id       NUMBER,
      resource_param_value_id NUMBER,
      value                   VARCHAR2(255),
      value_type              VARCHAR2(30)
   );

   p_rs_value_user_hook jtf_rs_values_user_hook;

   TYPE RS_PARAM_LIST_REC_TYPE IS RECORD
   (
    RESOURCE_PARAM_ID          NUMBER          := FND_API.G_MISS_NUM,
    MEANING                    VARCHAR2(80)    := FND_API.G_MISS_CHAR,
    TYPE                       VARCHAR2(30)    := FND_API.G_MISS_CHAR,
    DOMAIN_LOOKUP_TYPE         VARCHAR2(30)    := FND_API.G_MISS_CHAR
   );

   TYPE		RS_PARAM_LIST_TBL_TYPE  IS
               	TABLE OF RS_PARAM_LIST_REC_TYPE
              		INDEX BY BINARY_INTEGER;

   G_MISS_RS_PARAM_LIST_REC	RS_PARAM_LIST_REC_TYPE;
   G_MISS_RS_PARAM_LIST_TBL	RS_PARAM_LIST_TBL_TYPE;

/*#
 * Procedure to Create a resource parameter value
 * @param P_Api_Version API version number
 * @param P_Init_Msg_List Flag to start with clearing messages from database
 * @param P_Commit Flag to commit at the end of the procedure
 * @param P_resource_id Resource's internal unique ID
 * @param p_resource_param_id Internal unique ID for the resource parameter
 * @param p_value Value for the resource parameter
 * @param P_value_type Type for the value of the resource parameter
 * @param X_Return_Status Output parameter for return status
 * @param X_Msg_Count Output parameter for number of user messages from this procedure
 * @param X_Msg_Data Output parameter containing last user message from this procedure
 * @param X_resource_param_value_id Output parameter containing internal unique ID for the newly created resource parameter value
 * @rep:scope internal
 * @rep:displayname Create Resource Parameter Value
 */
PROCEDURE CREATE_RS_RESOURCE_VALUES(
      P_Api_Version         		IN   NUMBER,
      P_Init_Msg_List              	IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     	IN   VARCHAR2     := FND_API.G_FALSE,
      P_resource_id                	IN   NUMBER,
      p_resource_param_id	   	IN   NUMBER,
      p_value                      	IN   VARCHAR2,
      P_value_type                 	IN   VARCHAR2		DEFAULT NULL,
      X_Return_Status              	OUT NOCOPY VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY  NUMBER,
      X_Msg_Data                   	OUT NOCOPY VARCHAR2,
      X_resource_param_value_id    	OUT NOCOPY  NUMBER
   );


/*#
 * Update a resource parameter value
 * @param P_Api_Version API version number
 * @param P_Init_Msg_List Flag to start with clearing messages from database
 * @param P_Commit Flag to commit at the end of the procedure
 * @param p_resource_param_value_id internal unique ID for a resource parameter value
 * @param P_resource_id Resource's internal unique ID
 * @param p_resource_param_id unique internal ID for the resource parameter
 * @param p_value Value for the resource parameter
 * @param P_value_type Type for the value of the resource parameter
 * @param p_object_version_number Input/Output parameter for the object version number
 * @param X_Return_Status Output parameter for return status
 * @param X_Msg_Count Output parameter for number of user messages from this procedure
 * @param X_Msg_Data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Update Resource Parameter Value
 */
PROCEDURE UPDATE_RS_RESOURCE_VALUES(
      P_Api_Version	         	IN   	NUMBER,
      P_Init_Msg_List              	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     	IN   	VARCHAR2     := FND_API.G_FALSE,
      p_resource_param_value_id		IN   	NUMBER,
      p_resource_id			IN   	NUMBER,
      p_resource_param_id       	IN   	NUMBER,
      p_value      			IN   	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
      p_value_type          		IN   	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
      p_object_version_number           IN OUT NOCOPY  JTF_RS_RESOURCE_VALUES.OBJECT_VERSION_NUMBER%TYPE,
      X_Return_Status              	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY 	NUMBER,
      X_Msg_Data                   	OUT NOCOPY 	VARCHAR2
   );

/*#
 * Delete a resource parameter value
 * @param P_Api_Version API version number
 * @param P_Init_Msg_List Flag to start with clearing messages from database
 * @param P_Commit Flag to commit at the end of the procedure
 * @param p_resource_param_value_id internal unique ID a resource parameter value
 * @param p_object_version_number object version number of the resource parameter value record
 * @param X_Return_Status Output parameter for return status
 * @param X_Msg_Count Output parameter for number of user messages from this procedure
 * @param X_Msg_Data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Delete Resource Parameter Value
 */
PROCEDURE DELETE_RS_RESOURCE_VALUES(
      P_Api_Version			IN   NUMBER,
      P_Init_Msg_List              	IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     	IN   VARCHAR2     := FND_API.G_FALSE,
      p_resource_param_value_id		IN   NUMBER,
      p_object_version_number           IN   JTF_RS_RESOURCE_VALUES.OBJECT_VERSION_NUMBER%TYPE,
      X_Return_Status              	OUT NOCOPY VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY NUMBER,
      X_Msg_Data                   	OUT NOCOPY VARCHAR2
   );

/*#
 * Delete all records of resource parameter values for a resource
 * @param P_Api_Version API version number
 * @param P_Init_Msg_List Flag to start with clearing messages from database
 * @param P_Commit Flag to commit at the end of the procedure
 * @param P_resource_id Resource's internal unique ID
 * @param X_Return_Status Output parameter for return status
 * @param X_Msg_Count Output parameter for number of user messages from this procedure
 * @param X_Msg_Data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Delete Resource Parameter Values Of A Resource
 */
PROCEDURE DELETE_ALL_RS_RESOURCE_VALUES(
      P_Api_Version	  		IN   NUMBER,
      P_Init_Msg_List              	IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     	IN   VARCHAR2     := FND_API.G_FALSE,
      p_resource_id                	IN   NUMBER,
      X_Return_Status              	OUT NOCOPY VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY NUMBER,
      X_Msg_Data                   	OUT NOCOPY VARCHAR2
   );

/*#
 * Get a value of a resource parameter for a resource.
 * @param P_Api_Version API version number
 * @param P_Init_Msg_List Flag to start with clearing messages from database
 * @param P_Commit Flag to commit at the end of the procedure
 * @param P_resource_id Resource's internal unique ID
 * @param P_value_type Type for the value of the resource parameter
 * @param p_resource_param_id unique internal ID for the resource parameter
 * @param x_resource_param_value_id Output parameter, to get the unique internal id for resource parameter value
 * @param x_value Output parameter, to get value for a resource parameter
 * @param X_Return_Status Output parameter for return status
 * @param X_Msg_Count Output parameter for number of user messages from this procedure
 * @param X_Msg_Data Output parameter containing last user message from this procedure
 * @rep:scope internal
 * @rep:displayname Get Resource Parameter Value
 */
PROCEDURE GET_RS_RESOURCE_VALUES(
      P_Api_Version	         	IN   NUMBER,
      P_Init_Msg_List              	IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                     	IN   VARCHAR2     := FND_API.G_FALSE,
      P_resource_id                	IN   NUMBER,
      P_value_type                	IN   VARCHAR2	  DEFAULT FND_API.G_MISS_CHAR,
      p_resource_param_id               IN   NUMBER,
      x_resource_param_value_id         OUT NOCOPY  NUMBER,
      x_value                   	OUT NOCOPY  VARCHAR2,
      X_Return_Status              	OUT NOCOPY  VARCHAR2,
      X_Msg_Count                  	OUT NOCOPY  NUMBER,
      X_Msg_Data                   	OUT NOCOPY  VARCHAR2
   );

/*#
 * Get a list of all resource parameters
 * @param P_Api_Version API version number
 * @param P_Init_Msg_List Flag to start with clearing messages from database
 * @param P_Commit Flag to commit at the end of the procedure
 * @param P_APPLICATION_ID Application ID
 * @param X_Return_Status Output parameter for return status
 * @param X_Msg_Count Output parameter for number of user messages from this procedure
 * @param X_Msg_Data Output parameter containing last user message from this procedure
 * @param X_RS_PARAM_Table Output parameter containing list of all parameters in a pl/sql table
 * @param X_No_Record Output parameter containing count of records in x_rs_param_table
 * @rep:scope internal
 * @rep:displayname Get Resource Parameter List
 */
PROCEDURE GET_RS_RESOURCE_PARAM_LIST(
      P_Api_Version	              	IN   NUMBER,
      P_Init_Msg_List                   IN   VARCHAR2     := FND_API.G_FALSE,
      P_Commit                          IN   VARCHAR2     := FND_API.G_FALSE,
      P_APPLICATION_ID                  IN   NUMBER,
      X_Return_Status                   OUT NOCOPY  VARCHAR2,
      X_Msg_Count                       OUT NOCOPY  NUMBER,
      X_Msg_Data                        OUT NOCOPY  VARCHAR2,
      X_RS_PARAM_Table                  OUT NOCOPY  RS_PARAM_LIST_TBL_TYPE,
      X_No_Record                       OUT NOCOPY  Number
   );

End JTF_RS_RESOURCE_VALUES_PUB;


 

/
