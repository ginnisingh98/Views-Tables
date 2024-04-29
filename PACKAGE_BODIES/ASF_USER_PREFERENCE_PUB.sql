--------------------------------------------------------
--  DDL for Package Body ASF_USER_PREFERENCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASF_USER_PREFERENCE_PUB" AS
/* $Header: asfuprfb.pls 115.4 2003/02/14 09:17:00 vjayamoh ship $ */
-- Start of Comments
-- Package name     : ASF_USER_PREFERENCE_PUB
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments
G_PKG_NAME CONSTANT VARCHAR2(30):= 'ASF_USER_PREFERENCE_PUB';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asfuprfb.pls';

G_OWNER_TABLE_NAME  CONSTANT  VARCHAR2(30) :=  'HZ_PARTIES';

-- Start of Comments
--
--    API name    : Create_Preference
--    Type        : Public.
--
-- End of Comments
PROCEDURE CREATE_PREFERENCE(
    p_user_preference_rec           IN    USER_PREFERENCE_REC_TYPE := G_MISS_USER_PREFERENCE_REC,
    x_return_status                OUT NOCOPY    VARCHAR2,
    x_msg_count	                   OUT NOCOPY    NUMBER,
    x_msg_data	                   OUT NOCOPY    VARCHAR2)
 IS
l_debug BOOLEAN;
l_api_name                CONSTANT VARCHAR2(30) := 'CREATE_PREFERENCE';
l_user_preference_rec     USER_PREFERENCE_REC_TYPE   := p_user_preference_rec;
l_warning_msg		      VARCHAR2(2000)     := '';
BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT CREATE_PREFERENCE_PUB;


      -- Debug Message
      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --		'Public API: ' || l_api_name || ' start');

      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --		'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
      IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(NULL,'Public API: ' || l_api_name || ' start');
         AS_UTILITY_PVT.Debug_Message(NULL,'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

   BEGIN
       INSERT INTO ASF_USER_PREFERENCE(
          preference_id,
          user_id,
          created_by,
          creation_date,
          last_updated_by,
          last_update_date,
          last_update_login,
          owner_table_name,
          owner_table_id,
          category,
          preference_code,
          preference_value,
          attribute_category,
          attribute1,
          attribute2,
          attribute3,
          attribute4,
          attribute5,
          attribute6,
          attribute7,
          attribute8,
          attribute9,
          attribute10,
          attribute11,
          attribute12,
          attribute13,
          attribute14,
          attribute15
          ) VALUES (
           ASF_USER_PREFERENCE_S.NEXTVAL,
           decode( l_user_preference_rec.user_id, FND_API.G_MISS_NUM, NULL, l_user_preference_rec.user_id),

           decode( l_user_preference_rec.created_by, FND_API.G_MISS_NUM, NULL, l_user_preference_rec.created_by),
           decode( l_user_preference_rec.creation_date, FND_API.G_MISS_DATE, TO_DATE(NULL), l_user_preference_rec.creation_date),
           decode( l_user_preference_rec.last_updated_by, FND_API.G_MISS_NUM, NULL, l_user_preference_rec.last_updated_by),
           decode( l_user_preference_rec.last_update_date, FND_API.G_MISS_DATE, TO_DATE(NULL), l_user_preference_rec.last_update_date),
           decode( l_user_preference_rec.last_update_login, FND_API.G_MISS_NUM, NULL, l_user_preference_rec.last_update_login),

           decode( l_user_preference_rec.owner_table_name, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.owner_table_name),
           decode( l_user_preference_rec.owner_table_id, FND_API.G_MISS_NUM, NULL, l_user_preference_rec.owner_table_id),
           decode( l_user_preference_rec.category, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.category),
           decode( l_user_preference_rec.preference_code, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.preference_code),
           decode( l_user_preference_rec.preference_value, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.preference_value),
           decode( l_user_preference_rec.attribute_category, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute_category),
           decode( l_user_preference_rec.attribute1, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute1),
           decode( l_user_preference_rec.attribute2, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute2),
           decode( l_user_preference_rec.attribute3, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute3),
           decode( l_user_preference_rec.attribute4, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute4),
           decode( l_user_preference_rec.attribute5, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute5),
           decode( l_user_preference_rec.attribute6, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute6),
           decode( l_user_preference_rec.attribute7, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute7),
           decode( l_user_preference_rec.attribute8, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute8),
           decode( l_user_preference_rec.attribute9, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute9),
           decode( l_user_preference_rec.attribute10, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute10),
           decode( l_user_preference_rec.attribute11, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute11),
           decode( l_user_preference_rec.attribute12, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute12),
           decode( l_user_preference_rec.attribute13, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute13),
           decode( l_user_preference_rec.attribute14, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute14),
           decode( l_user_preference_rec.attribute15, FND_API.G_MISS_CHAR, NULL, l_user_preference_rec.attribute15)
           );

       IF (SQL%NOTFOUND) THEN
            RAISE NO_DATA_FOUND;
--       ELSE
 --           COMMIT;
       END IF;
       EXCEPTION
       WHEN OTHERS THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
     END;

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	     l_warning_msg := X_Msg_Data;
      END IF;

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      -- Debug Message
      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --		'Public API: ' || l_api_name || ' end');

      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --		'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(NULL,'Public API: ' || l_api_name || ' end');
         AS_UTILITY_PVT.Debug_Message(NULL,'End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Standard call to get message count and if count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	     X_Msg_Data := l_warning_msg;
      END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

      WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

END CREATE_PREFERENCE;
PROCEDURE UPDATE_PREFERENCE(
    p_user_preference_rec           IN    USER_PREFERENCE_REC_TYPE := G_MISS_USER_PREFERENCE_REC,
    x_return_status                OUT NOCOPY    VARCHAR2,
    x_msg_count	                   OUT NOCOPY    NUMBER,
    x_msg_data	                   OUT NOCOPY    VARCHAR2)
IS
l_debug BOOLEAN;
l_api_name                CONSTANT VARCHAR2(30) := 'UPDATE_PREFERENCE';
l_user_preference_rec     USER_PREFERENCE_REC_TYPE   := p_user_preference_rec;
l_warning_msg		      VARCHAR2(2000)     := '';
l_preference_id           NUMBER    := 0;
BEGIN

      -- Standard Start of API savepoint
      SAVEPOINT UPDATE_PREFERENCE_PUB;


      -- Debug Message
      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --		'Public API: ' || l_api_name || ' start');

      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --              'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
      IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(NULL,'Public API: ' || l_api_name || ' start');
         AS_UTILITY_PVT.Debug_Message(NULL,'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;


     -- first to check if the passing preference_id is null
     -- if it is not null, will use it as the condition to update related record
     -- if it is null, will use other four conditions to locate
     -- the preference_id, if preference_id found, then use it
     -- to update the record, otherwise to create a new record

     --dbms_output.put_line('preference_id'|| ' ' || l_user_preference_rec.preference_id);
     IF NVL(l_user_preference_rec.preference_id,0) = 0 THEN
        --dbms_output.put_line('l_user_preference_rec.preference_id is null');
          BEGIN
             SELECT preference_id
             INTO l_preference_id
             FROM  ASF_USER_PREFERENCE
             WHERE USER_ID = l_user_preference_rec.user_id
               AND OWNER_TABLE_NAME = G_OWNER_TABLE_NAME
               AND PREFERENCE_CODE = l_user_preference_rec.preference_code
               AND OWNER_TABLE_ID= l_user_preference_rec.owner_table_id;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
               BEGIN
                   ASF_USER_PREFERENCE_PUB.CREATE_PREFERENCE(
      	               P_user_preference_rec  	  => l_user_preference_rec ,
      	               X_Return_Status              => x_return_status,
      	               X_Msg_Count                  => x_msg_count,
      	               X_Msg_Data                   => x_msg_data);

                   -- Debug Message
                   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                      AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
                      'Create_Preference fail');
                   END IF;
                   -- Check return status from the above procedure call
                   IF x_return_status = FND_API.G_RET_STS_ERROR THEN
                      RAISE FND_API.G_EXC_ERROR;
                   ELSIF x_return_status = FND_API.G_RET_STS_UNEXP_ERROR THEN
                      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
                   END IF;
               END;
          WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          END;
          IF l_preference_id <> 0 THEN
             BEGIN
                UPDATE ASF_USER_PREFERENCE
                SET
                  last_updated_by = decode( l_user_preference_rec.last_updated_by, FND_API.G_MISS_NUM, last_updated_by, l_user_preference_rec.last_updated_by),
                  last_update_date = decode( l_user_preference_rec.last_update_date, FND_API.G_MISS_DATE, SYSDATE, l_user_preference_rec.last_update_date),
                  last_update_login = decode( l_user_preference_rec.last_update_login, FND_API.G_MISS_NUM, last_update_login, l_user_preference_rec.last_update_login),
                  category = decode( l_user_preference_rec.category, FND_API.G_MISS_CHAR, category, l_user_preference_rec.category),
                  preference_code = decode( l_user_preference_rec.preference_code, FND_API.G_MISS_CHAR, preference_code, l_user_preference_rec.preference_code),
                  preference_value = decode( l_user_preference_rec.preference_value, FND_API.G_MISS_CHAR, preference_value, l_user_preference_rec.preference_value),
                  attribute_category = decode( l_user_preference_rec.attribute_category, FND_API.G_MISS_CHAR, attribute_category, l_user_preference_rec.attribute_category),
                  attribute1 = decode( l_user_preference_rec.attribute1, FND_API.G_MISS_CHAR, attribute1, l_user_preference_rec.attribute1),
                  attribute2 = decode( l_user_preference_rec.attribute2, FND_API.G_MISS_CHAR, attribute2, l_user_preference_rec.attribute2),
                  attribute3 = decode( l_user_preference_rec.attribute3, FND_API.G_MISS_CHAR, attribute3, l_user_preference_rec.attribute3),
                  attribute4 = decode( l_user_preference_rec.attribute4, FND_API.G_MISS_CHAR, attribute4, l_user_preference_rec.attribute4),
                  attribute5 = decode( l_user_preference_rec.attribute5, FND_API.G_MISS_CHAR, attribute5, l_user_preference_rec.attribute5),
                  attribute6 = decode( l_user_preference_rec.attribute6, FND_API.G_MISS_CHAR, attribute6, l_user_preference_rec.attribute6),
                  attribute7 = decode( l_user_preference_rec.attribute7, FND_API.G_MISS_CHAR, attribute7, l_user_preference_rec.attribute7),
                  attribute8 = decode( l_user_preference_rec.attribute8, FND_API.G_MISS_CHAR, attribute8, l_user_preference_rec.attribute8),
                  attribute9 = decode( l_user_preference_rec.attribute9, FND_API.G_MISS_CHAR, attribute9, l_user_preference_rec.attribute9),
                  attribute10 = decode( l_user_preference_rec.attribute10, FND_API.G_MISS_CHAR, attribute10, l_user_preference_rec.attribute10),
                  attribute11 = decode( l_user_preference_rec.attribute11, FND_API.G_MISS_CHAR, attribute11, l_user_preference_rec.attribute11),
                  attribute12 = decode( l_user_preference_rec.attribute12, FND_API.G_MISS_CHAR, attribute12, l_user_preference_rec.attribute12),
                  attribute13 = decode( l_user_preference_rec.attribute13, FND_API.G_MISS_CHAR, attribute13, l_user_preference_rec.attribute13),
                  attribute14 = decode( l_user_preference_rec.attribute14, FND_API.G_MISS_CHAR, attribute14, l_user_preference_rec.attribute14),
                  attribute15 = decode( l_user_preference_rec.attribute15, FND_API.G_MISS_CHAR, attribute15, l_user_preference_rec.attribute15)
                WHERE PREFERENCE_ID = l_preference_id;

               IF (SQL%NOTFOUND) THEN
                   RAISE NO_DATA_FOUND;
--               ELSE
--                  COMMIT;
               END IF;
            EXCEPTION
               WHEN OTHERS THEN
                    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
            END;
         END IF;
     ELSIF NVL(l_user_preference_rec.preference_id,0) > 0  THEN
        --dbms_output.put_line('l_user_preference_rec.preference_id is not null');
        BEGIN
        UPDATE ASF_USER_PREFERENCE
           SET
              last_updated_by = decode( l_user_preference_rec.last_updated_by, FND_API.G_MISS_NUM, last_updated_by, l_user_preference_rec.last_updated_by),
              last_update_date = decode( l_user_preference_rec.last_update_date, FND_API.G_MISS_DATE, SYSDATE, l_user_preference_rec.last_update_date),
              last_update_login = decode( l_user_preference_rec.last_update_login, FND_API.G_MISS_NUM, last_update_login, l_user_preference_rec.last_update_login),
              category = decode( l_user_preference_rec.category, FND_API.G_MISS_CHAR, category, l_user_preference_rec.category),
              preference_code = decode( l_user_preference_rec.preference_code, FND_API.G_MISS_CHAR, preference_code, l_user_preference_rec.preference_code),
              preference_value = decode( l_user_preference_rec.preference_value, FND_API.G_MISS_CHAR, preference_value, l_user_preference_rec.preference_value),
              attribute_category = decode( l_user_preference_rec.attribute_category, FND_API.G_MISS_CHAR, attribute_category, l_user_preference_rec.attribute_category),
              attribute1 = decode( l_user_preference_rec.attribute1, FND_API.G_MISS_CHAR, attribute1, l_user_preference_rec.attribute1),
              attribute2 = decode( l_user_preference_rec.attribute2, FND_API.G_MISS_CHAR, attribute2, l_user_preference_rec.attribute2),
              attribute3 = decode( l_user_preference_rec.attribute3, FND_API.G_MISS_CHAR, attribute3, l_user_preference_rec.attribute3),
              attribute4 = decode( l_user_preference_rec.attribute4, FND_API.G_MISS_CHAR, attribute4, l_user_preference_rec.attribute4),
              attribute5 = decode( l_user_preference_rec.attribute5, FND_API.G_MISS_CHAR, attribute5, l_user_preference_rec.attribute5),
              attribute6 = decode( l_user_preference_rec.attribute6, FND_API.G_MISS_CHAR, attribute6, l_user_preference_rec.attribute6),
              attribute7 = decode( l_user_preference_rec.attribute7, FND_API.G_MISS_CHAR, attribute7, l_user_preference_rec.attribute7),
              attribute8 = decode( l_user_preference_rec.attribute8, FND_API.G_MISS_CHAR, attribute8, l_user_preference_rec.attribute8),
              attribute9 = decode( l_user_preference_rec.attribute9, FND_API.G_MISS_CHAR, attribute9, l_user_preference_rec.attribute9),
              attribute10 = decode( l_user_preference_rec.attribute10, FND_API.G_MISS_CHAR, attribute10, l_user_preference_rec.attribute10),
              attribute11 = decode( l_user_preference_rec.attribute11, FND_API.G_MISS_CHAR, attribute11, l_user_preference_rec.attribute11),
              attribute12 = decode( l_user_preference_rec.attribute12, FND_API.G_MISS_CHAR, attribute12, l_user_preference_rec.attribute12),
              attribute13 = decode( l_user_preference_rec.attribute13, FND_API.G_MISS_CHAR, attribute13, l_user_preference_rec.attribute13),
              attribute14 = decode( l_user_preference_rec.attribute14, FND_API.G_MISS_CHAR, attribute14, l_user_preference_rec.attribute14),
              attribute15 = decode( l_user_preference_rec.attribute15, FND_API.G_MISS_CHAR, attribute15, l_user_preference_rec.attribute15)
           WHERE PREFERENCE_ID = l_user_preference_rec.preference_id;

           IF (SQL%NOTFOUND) THEN
               RAISE NO_DATA_FOUND;
--           ELSE
--              COMMIT;
           END IF;
           EXCEPTION
           WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               --APP_EXCEPTION.RAISE_EXCEPTION;
         END;
      END IF;



      -- Debug Message
      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --				'Public API: ' || l_api_name || ' end');

      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(NULL,'Public API: ' || l_api_name || ' end');
         AS_UTILITY_PVT.Debug_Message(NULL,'End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Standard call to get message count and if count is 1, get message info.

      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

      IF x_return_status = FND_API.G_RET_STS_SUCCESS THEN
	     X_Msg_Data := l_warning_msg;
      END IF;

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


END UPDATE_PREFERENCE;
PROCEDURE DELETE_PREFERENCE(
    p_user_preference_rec           IN    USER_PREFERENCE_REC_TYPE := G_MISS_USER_PREFERENCE_REC,
    x_return_status                OUT NOCOPY    VARCHAR2,
    x_msg_count	                   OUT NOCOPY    NUMBER,
    x_msg_data	                   OUT NOCOPY    VARCHAR2)
IS
l_debug BOOLEAN;
l_api_name                CONSTANT VARCHAR2(30) := 'DELETE_PREFERENCE';
l_user_preference_rec     USER_PREFERENCE_REC_TYPE   := p_user_preference_rec;
l_warning_msg		      VARCHAR2(2000)     := '';
l_preference_id            NUMBER    := 0;
BEGIN
      -- Standard Start of API savepoint
      SAVEPOINT DELETE_PREFERENCE_PUB;

      -- Debug Message
      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --				'Public API: ' || l_api_name || ' start');

      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --				'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      l_debug := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
      IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(NULL,'Public API: ' || l_api_name || ' start');
         AS_UTILITY_PVT.Debug_Message(NULL,'Start time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Initialize API return status to SUCCESS
      x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- first to check if the passing preference_id is null
     -- if it is not null, will use it as the condition to delete related record
     -- if it is null, will use other four conditions to locate
     -- the preference_id, if preference_id found, then use it to delete the record

     --dbms_output.put_line('Testing Delete Procedure');
	--dbms_output.put_line('preference_id'|| ' ' || l_user_preference_rec.preference_id);

     IF NVL(l_user_preference_rec.preference_id,0) = 0 THEN
	  --dbms_output.put_line('l_user_preference_rec.preference_id is null');
          BEGIN
             SELECT preference_id
             INTO l_preference_id
             FROM  ASF_USER_PREFERENCE
             WHERE USER_ID = l_user_preference_rec.user_id
               AND OWNER_TABLE_NAME = G_OWNER_TABLE_NAME
               AND PREFERENCE_CODE = l_user_preference_rec.preference_code
               AND OWNER_TABLE_ID= l_user_preference_rec.owner_table_id;
          EXCEPTION
          WHEN NO_DATA_FOUND THEN
               l_preference_id := 0;
          WHEN OTHERS THEN
               x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
               --APP_EXCEPTION.RAISE_EXCEPTION;
          END;
          IF NVL(l_preference_id,0) <> 0 THEN
                DELETE FROM ASF_USER_PREFERENCE
                WHERE PREFERENCE_ID = l_preference_id;
               IF (SQL%NOTFOUND) THEN
                   RAISE NO_DATA_FOUND;
--               ELSE
--                   COMMIT;
               END IF;
          END IF;
     ELSIF NVL(l_user_preference_rec.preference_id,0) > 0  THEN
		 --dbms_output.put_line('l_user_preference_rec.preference_id is not null');
                DELETE FROM ASF_USER_PREFERENCE
                WHERE PREFERENCE_ID = l_user_preference_rec.preference_id;
               IF (SQL%NOTFOUND) THEN
                   RAISE NO_DATA_FOUND;
--               ELSE
--                   COMMIT;
               END IF;
     END IF;

      -- Check return status from the above procedure call
      IF x_return_status = FND_API.G_RET_STS_ERROR then
          raise FND_API.G_EXC_ERROR;
      elsif x_return_status = FND_API.G_RET_STS_UNEXP_ERROR then
          raise FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;

      -- Debug Message
      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --				'Public API: ' || l_api_name || ' end');

      --AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
      --				'End time:   ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));

      IF l_debug THEN
         AS_UTILITY_PVT.Debug_Message(NULL,'Public API: ' || l_api_name || ' end');
         AS_UTILITY_PVT.Debug_Message(NULL,'End time: ' || TO_CHAR(SYSDATE, 'HH24:MI:SSSSS'));
      END IF;

      -- Standard call to get message count and if count is 1, get message info.
      FND_MSG_PUB.Count_And_Get
      (  p_count          =>   x_msg_count,
         p_data           =>   x_msg_data
      );

EXCEPTION
     WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

     WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);


END DELETE_PREFERENCE;

End ASF_USER_PREFERENCE_PUB;

/
