--------------------------------------------------------
--  DDL for Package ASF_USER_PREFERENCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASF_USER_PREFERENCE_PUB" AUTHID CURRENT_USER as
/* $Header: asfuprfs.pls 115.3 2003/01/21 22:31:13 hoyuan ship $ */
-- Start of Comments
--
-- NAME
--   ASF_USER_PREFERENCE_PUB
--
TYPE  user_preference_rec_type IS RECORD
 (PREFERENCE_ID NUMBER              := FND_API.G_MISS_NUM
 ,USER_ID NUMBER                    := FND_API.G_MISS_NUM
 ,CREATED_BY NUMBER                 := FND_API.G_MISS_NUM
 ,CREATION_DATE DATE                := FND_API.G_MISS_DATE
 ,LAST_UPDATED_BY NUMBER            := FND_API.G_MISS_NUM
 ,LAST_UPDATE_DATE DATE             := FND_API.G_MISS_DATE
 ,LAST_UPDATE_LOGIN NUMBER          := FND_API.G_MISS_NUM
 ,OWNER_TABLE_NAME VARCHAR2(30)     := FND_API.G_MISS_CHAR
 ,OWNER_TABLE_ID NUMBER             := FND_API.G_MISS_NUM
 ,CATEGORY VARCHAR2(30)             := FND_API.G_MISS_CHAR
 ,PREFERENCE_CODE VARCHAR2(30)      := FND_API.G_MISS_CHAR
 ,PREFERENCE_VALUE VARCHAR2(80)     := FND_API.G_MISS_CHAR
 ,ATTRIBUTE_CATEGORY VARCHAR2(30)   := FND_API.G_MISS_CHAR
 ,ATTRIBUTE1 VARCHAR2(150)          := FND_API.G_MISS_CHAR
 ,ATTRIBUTE2 VARCHAR2(150)          := FND_API.G_MISS_CHAR
 ,ATTRIBUTE3 VARCHAR2(150)          := FND_API.G_MISS_CHAR
 ,ATTRIBUTE4 VARCHAR2(150)          := FND_API.G_MISS_CHAR
 ,ATTRIBUTE5 VARCHAR2(150)          := FND_API.G_MISS_CHAR
 ,ATTRIBUTE6 VARCHAR2(150)          := FND_API.G_MISS_CHAR
 ,ATTRIBUTE7 VARCHAR2(150)          := FND_API.G_MISS_CHAR
 ,ATTRIBUTE8 VARCHAR2(150)          := FND_API.G_MISS_CHAR
 ,ATTRIBUTE9 VARCHAR2(150)          := FND_API.G_MISS_CHAR
 ,ATTRIBUTE10 VARCHAR2(150)         := FND_API.G_MISS_CHAR
 ,ATTRIBUTE11 VARCHAR2(150)         := FND_API.G_MISS_CHAR
 ,ATTRIBUTE12 VARCHAR2(150)         := FND_API.G_MISS_CHAR
 ,ATTRIBUTE13 VARCHAR2(150)         := FND_API.G_MISS_CHAR
 ,ATTRIBUTE14 VARCHAR2(150)         := FND_API.G_MISS_CHAR
 ,ATTRIBUTE15 VARCHAR2(150)         := FND_API.G_MISS_CHAR
 );

G_MISS_USER_PREFERENCE_REC		user_preference_rec_type;

-- Start of Comments
--
--    API name    : Create_Preference
--    Type        : Public.
--    Type        : Public.
--
--
-- Required:
--        last_update_date
--        last_updated_by
--        creation_date
--        created_by
--        last_update_login
--        owner_table_name
--        owner_table_id
--        preference_code
--        user_id
--
-- End of Comments

PROCEDURE CREATE_PREFERENCE
(   p_user_preference_rec           IN    USER_PREFERENCE_REC_TYPE := G_MISS_USER_PREFERENCE_REC,
    x_return_status                OUT NOCOPY    VARCHAR2,
    x_msg_count	                   OUT NOCOPY    NUMBER,
    x_msg_data	                   OUT NOCOPY    VARCHAR2
 );
-- Start of Comments
--
--    API name    : Update_Preference
--    Type        : Public.
--
--    Required:
--        last_update_date
--        last_updated_by
--        last_update_login
--        preference_id
--        owner_table_name
--        owner_table_id
--        preference_code
--        user_id
--
-- End of Comments

PROCEDURE UPDATE_PREFERENCE
(   p_user_preference_rec           IN    USER_PREFERENCE_REC_TYPE := G_MISS_USER_PREFERENCE_REC,
    x_return_status                OUT NOCOPY    VARCHAR2,
    x_msg_count	                   OUT NOCOPY    NUMBER,
    x_msg_data	                   OUT NOCOPY    VARCHAR2
 );

-- Start of Comments
--
--    API name    : Delete_Preference
--    Type        : Public.
--
--    Function    : Delete User Reference Record
--
-- End of Comments

PROCEDURE DELETE_PREFERENCE
(   p_user_preference_rec           IN    USER_PREFERENCE_REC_TYPE := G_MISS_USER_PREFERENCE_REC,
    x_return_status                OUT NOCOPY    VARCHAR2,
    x_msg_count	                   OUT NOCOPY    NUMBER,
    x_msg_data	                   OUT NOCOPY    VARCHAR2
 );

End ASF_USER_PREFERENCE_PUB;

 

/
