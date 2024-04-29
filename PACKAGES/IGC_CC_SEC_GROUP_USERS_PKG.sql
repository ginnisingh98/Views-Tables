--------------------------------------------------------
--  DDL for Package IGC_CC_SEC_GROUP_USERS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_CC_SEC_GROUP_USERS_PKG" AUTHID CURRENT_USER as
/* $Header: IGCCSCUS.pls 120.4.12000000.1 2007/08/20 12:14:48 mbremkum ship $ */

PROCEDURE Insert_Row(  p_api_version            IN      NUMBER,
  		    p_init_msg_list             IN      VARCHAR2 := FND_API.G_FALSE,
  		    p_commit                    IN      VARCHAR2 := FND_API.G_FALSE,
  		    p_validation_level          IN      NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  		    p_return_status             OUT NOCOPY     VARCHAR2,
  		    p_msg_count                 OUT NOCOPY     NUMBER,
  		    p_msg_data                  OUT NOCOPY     VARCHAR2,

		     P_ROWID 			IN OUT NOCOPY  VARCHAR2,
		     P_CC_GROUP_ID			NUMBER,
		     P_USER_ID				NUMBER,
		     P_CONTEXT				VARCHAR2,
		     P_ATTRIBUTE1			VARCHAR2,
		     P_ATTRIBUTE2 			VARCHAR2,
		     P_ATTRIBUTE3			VARCHAR2,
		     P_ATTRIBUTE4			VARCHAR2,
		     P_ATTRIBUTE5			VARCHAR2,
		     P_ATTRIBUTE6			VARCHAR2,
		     P_ATTRIBUTE7			VARCHAR2,
		     P_ATTRIBUTE8			VARCHAR2,
		     P_ATTRIBUTE9			VARCHAR2,
		     P_ATTRIBUTE10 			VARCHAR2,
		     P_ATTRIBUTE11 			VARCHAR2,
		     P_ATTRIBUTE12 			VARCHAR2,
		     P_ATTRIBUTE13 			VARCHAR2,
		     P_ATTRIBUTE14 			VARCHAR2,
		     P_ATTRIBUTE15 			VARCHAR2,
		     P_LAST_UPDATE_DATE			DATE,
		     P_LAST_UPDATED_BY			NUMBER,
		     P_CREATION_DATE			DATE,
		     P_CREATED_BY			NUMBER,
		     P_LAST_UPDATE_LOGIN		NUMBER
		    );

PROCEDURE Update_Row(  p_api_version           IN       NUMBER,
  		   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  		   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  		   p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  		   p_return_status             OUT NOCOPY      VARCHAR2,
  		   p_msg_count                 OUT NOCOPY      NUMBER,
  		   p_msg_data                  OUT NOCOPY      VARCHAR2,

		   P_ROWID			      VARCHAR2,
		   P_CC_GROUP_ID	              NUMBER,
		   P_USER_ID			      NUMBER,
		   P_CONTEXT		              VARCHAR2,
		   P_ATTRIBUTE1                       VARCHAR2,
		   P_ATTRIBUTE2                       VARCHAR2,
		   P_ATTRIBUTE3                       VARCHAR2,
                   P_ATTRIBUTE4                       VARCHAR2,
                   P_ATTRIBUTE5                       VARCHAR2,
                   P_ATTRIBUTE6                       VARCHAR2,
                   P_ATTRIBUTE7                       VARCHAR2,
                   P_ATTRIBUTE8                       VARCHAR2,
                   P_ATTRIBUTE9                       VARCHAR2,
                   P_ATTRIBUTE10                      VARCHAR2,
                   P_ATTRIBUTE11                      VARCHAR2,
                   P_ATTRIBUTE12                      VARCHAR2,
                   P_ATTRIBUTE13                      VARCHAR2,
                   P_ATTRIBUTE14                      VARCHAR2,
                   P_ATTRIBUTE15                      VARCHAR2,
                   P_LAST_UPDATE_DATE                 DATE,
		   P_LAST_UPDATED_BY	              NUMBER,
		   P_LAST_UPDATE_LOGIN		      NUMBER
		   );

PROCEDURE Lock_Row(  p_api_version             IN       NUMBER,
  		   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  		   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  		   p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  		   p_return_status             OUT NOCOPY      VARCHAR2,
  		   p_msg_count                 OUT NOCOPY      NUMBER,
  		   p_msg_data                  OUT NOCOPY      VARCHAR2,

		   P_ROWID			      VARCHAR2,
                   P_CC_GROUP_ID 	              NUMBER,
                   P_USER_ID  		              NUMBER,
                   P_CONTEXT	                      VARCHAR2,
                   P_ATTRIBUTE1                       VARCHAR2,
                   P_ATTRIBUTE2                       VARCHAR2,
                   P_ATTRIBUTE3                       VARCHAR2,
                   P_ATTRIBUTE4                       VARCHAR2,
                   P_ATTRIBUTE5                       VARCHAR2,
                   P_ATTRIBUTE6                       VARCHAR2,
                   P_ATTRIBUTE7                       VARCHAR2,
                   P_ATTRIBUTE8                       VARCHAR2,
                   P_ATTRIBUTE9                       VARCHAR2,
                   P_ATTRIBUTE10                      VARCHAR2,
                   P_ATTRIBUTE11                      VARCHAR2,
                   P_ATTRIBUTE12                      VARCHAR2,
                   P_ATTRIBUTE13                      VARCHAR2,
                   P_ATTRIBUTE14                      VARCHAR2,
                   P_ATTRIBUTE15                      VARCHAR2,
  		   p_row_locked              OUT NOCOPY      VARCHAR2
		  );

PROCEDURE Delete_Row(  p_api_version           IN       NUMBER,
  		   p_init_msg_list             IN       VARCHAR2 := FND_API.G_FALSE,
  		   p_commit                    IN       VARCHAR2 := FND_API.G_FALSE,
  		   p_validation_level          IN       NUMBER   := FND_API.G_VALID_LEVEL_FULL,
  		   p_return_status             OUT NOCOPY      VARCHAR2,
  		   p_msg_count                 OUT NOCOPY      NUMBER,
  		   p_msg_data                  OUT NOCOPY      VARCHAR2,

		   P_ROWID VARCHAR2) ;

-- END IGC_CC_SEC_GROUP_USERS_PKG;
END IGC_CC_SEC_GROUP_USERS_PKG;
 

/
