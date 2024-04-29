--------------------------------------------------------
--  DDL for Package JTF_RS_RESOURCE_VALUES_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_RS_RESOURCE_VALUES_PVT" AUTHID CURRENT_USER AS
   /* $Header: jtfrsvcs.pls 120.0 2005/05/11 08:22:54 appldev ship $ */

   PROCEDURE CREATE_RS_RESOURCE_VALUES(
      P_Api_Version	        IN	NUMBER,
      P_Init_Msg_List		IN	VARCHAR2        DEFAULT FND_API.G_FALSE,
      P_Commit                  IN   	VARCHAR2        DEFAULT FND_API.G_FALSE,
      P_resource_id            	IN   	NUMBER,
      p_resource_param_id       IN      NUMBER,
      p_value                 	IN   	VARCHAR2,
      P_value_type           	IN   	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE1		IN	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE2              IN	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE3              IN	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE4              IN  	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE5              IN   	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE6              IN  	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE7              IN  	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE8              IN   	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE9              IN    	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE10             IN    	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE11             IN    	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE12             IN   	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE13             IN  	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE14             IN    	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE15             IN    	VARCHAR2	DEFAULT NULL,
      P_ATTRIBUTE_CATEGORY      IN  	VARCHAR2	DEFAULT NULL,
      X_Return_Status         	OUT NOCOPY  	VARCHAR2,
      X_Msg_Count           	OUT NOCOPY 	NUMBER,
      X_Msg_Data             	OUT NOCOPY 	VARCHAR2,
      X_resource_param_value_id	OUT NOCOPY 	NUMBER
   );


   PROCEDURE UPDATE_RS_RESOURCE_VALUES(
      P_Api_Version	        IN   	NUMBER,
      P_Init_Msg_List         	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit                  IN   	VARCHAR2     := FND_API.G_FALSE,
      p_resource_param_value_id IN   	NUMBER,
      p_value      		IN   	VARCHAR2	DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE1              IN	VARCHAR2        DEFAULT	FND_API.G_MISS_CHAR,
      P_ATTRIBUTE2              IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE3              IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE4              IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE5              IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE6              IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE7              IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE8              IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE9              IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE10             IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE11             IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE12             IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE13             IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE14             IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE15             IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      P_ATTRIBUTE_CATEGORY      IN      VARCHAR2        DEFAULT FND_API.G_MISS_CHAR,
      p_object_version_number   IN OUT NOCOPY  JTF_RS_RESOURCE_VALUES.OBJECT_VERSION_NUMBER%TYPE,
      X_Return_Status           OUT NOCOPY  	VARCHAR2,
      X_Msg_Count             	OUT NOCOPY 	NUMBER,
      X_Msg_Data              	OUT NOCOPY 	VARCHAR2
   );

   PROCEDURE DELETE_RS_RESOURCE_VALUES(
      P_Api_Version		IN   	NUMBER,
      P_Init_Msg_List          	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit                 	IN   	VARCHAR2     := FND_API.G_FALSE,
      p_resource_param_value_id	IN   	NUMBER,
      p_object_version_number   IN      JTF_RS_RESOURCE_VALUES.OBJECT_VERSION_NUMBER%TYPE,
      X_Return_Status          	OUT NOCOPY  	VARCHAR2,
      X_Msg_Count             	OUT NOCOPY 	NUMBER,
      X_Msg_Data              	OUT NOCOPY 	VARCHAR2
   );

   PROCEDURE DELETE_ALL_RS_RESOURCE_VALUES(
      P_Api_Version	  	IN   	NUMBER,
      P_Init_Msg_List         	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit                	IN   	VARCHAR2     := FND_API.G_FALSE,
      p_resource_id          	IN   	NUMBER,
      X_Return_Status        	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count            	OUT NOCOPY 	NUMBER,
      X_Msg_Data             	OUT NOCOPY 	VARCHAR2
   );

   PROCEDURE GET_RS_RESOURCE_VALUES(
      P_Api_Version	      	IN   	NUMBER,
      P_Init_Msg_List        	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit               	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_resource_id          	IN   	NUMBER,
      P_value_type           	IN   	VARCHAR2     DEFAULT FND_API.G_MISS_CHAR,
      p_resource_param_id    	IN   	NUMBER,
      x_resource_param_value_id	OUT NOCOPY 	NUMBER,
      x_value                   OUT NOCOPY  	VARCHAR2,
      X_Return_Status        	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count            	OUT NOCOPY 	NUMBER,
      X_Msg_Data             	OUT NOCOPY 	VARCHAR2
   );

   PROCEDURE GET_RS_RESOURCE_PARAM_LIST(
      P_Api_Version        	IN   	NUMBER,
      P_Init_Msg_List          	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_Commit             	IN   	VARCHAR2     := FND_API.G_FALSE,
      P_APPLICATION_ID   	IN   	NUMBER,
      X_Return_Status      	OUT NOCOPY 	VARCHAR2,
      X_Msg_Count           	OUT NOCOPY 	NUMBER,
      X_Msg_Data           	OUT NOCOPY 	VARCHAR2,
      X_RS_PARAM_Table    	OUT NOCOPY JTF_RS_RESOURCE_VALUES_PUB.RS_PARAM_LIST_TBL_TYPE,
      X_No_Record           	OUT NOCOPY 	NUMBER
   );

End JTF_RS_RESOURCE_VALUES_PVT;

 

/
