--------------------------------------------------------
--  DDL for Package Body AS_MULTI_CURRENCIES_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AS_MULTI_CURRENCIES_PKG" as
/* $Header: asxtmcpb.pls 120.2 2005/06/14 01:33:02 appldev  $ */
-- Start of Comments
-- Package name     : AS_MULTI_CURRENCIES_PKG
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments


G_PKG_NAME CONSTANT VARCHAR2(30):= 'AS_MULTI_CURRENCIES_PKG';
G_FILE_NAME CONSTANT VARCHAR2(12) := 'asxtmcpb.pls';

PROCEDURE Insert_Type_Mappings(
          p_TYPE_MAPPINGS_TBL  IN   TYPE_MAPPINGS_Tbl_Type
                                    DEFAULT G_MISS_TYPE_MAPPINGS_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Insert_Type_Mappings';
i                         NUMBER;
l_last                    NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.mcpk.Insert_Type_Mappings';
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT INSERT_TYPE_MAPPINGS_PUB;

   -- Debug Message
   IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       l_api_name || ' Start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   i := p_TYPE_MAPPINGS_TBL.first;
   l_last := p_TYPE_MAPPINGS_TBL.last;
   WHILE i <= l_last
   LOOP
       INSERT INTO AS_MC_TYPE_MAPPINGS(
               PERIOD_SET_NAME,
               PERIOD_TYPE,
               CONVERSION_TYPE,
               DESCRIPTION,
               UPDATEABLE_FLAG,
               DELETEABLE_FLAG,
               LAST_UPDATE_DATE,
               LAST_UPDATED_BY,
               CREATION_DATE,
               CREATED_BY,
               LAST_UPDATE_LOGIN
               --,
               -- SECURITY_GROUP_ID
       ) VALUES (
               decode( p_TYPE_MAPPINGS_TBL(i).PERIOD_SET_NAME,
                       FND_API.G_MISS_CHAR, NULL,
                       p_TYPE_MAPPINGS_TBL(i).PERIOD_SET_NAME),
               decode( p_TYPE_MAPPINGS_TBL(i).PERIOD_TYPE,
                       FND_API.G_MISS_CHAR, NULL,
                       p_TYPE_MAPPINGS_TBL(i).PERIOD_TYPE),
               decode( p_TYPE_MAPPINGS_TBL(i).CONVERSION_TYPE,
                       FND_API.G_MISS_CHAR, NULL,
                       p_TYPE_MAPPINGS_TBL(i).CONVERSION_TYPE),
               decode( p_TYPE_MAPPINGS_TBL(i).DESCRIPTION,
                       FND_API.G_MISS_CHAR, NULL,
                       p_TYPE_MAPPINGS_TBL(i).DESCRIPTION),
               decode( p_TYPE_MAPPINGS_TBL(i).UPDATEABLE_FLAG,
                       FND_API.G_MISS_CHAR, NULL,
                       p_TYPE_MAPPINGS_TBL(i).UPDATEABLE_FLAG),
               decode( p_TYPE_MAPPINGS_TBL(i).DELETEABLE_FLAG,
                       FND_API.G_MISS_CHAR, NULL,
                       p_TYPE_MAPPINGS_TBL(i).DELETEABLE_FLAG),
               SYSDATE,
               FND_GLOBAL.USER_ID,
               SYSDATE,
               FND_GLOBAL.USER_ID,
               FND_GLOBAL.CONC_LOGIN_ID
               --,
               -- decode( p_TYPE_MAPPINGS_TBL(i).SECURITY_GROUP_ID,
               --        FND_API.G_MISS_NUM, NULL,
               --        p_TYPE_MAPPINGS_TBL(i).SECURITY_GROUP_ID)
                       );
    i := i + 1;
    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Insert_Type_Mappings;

PROCEDURE Update_Type_Mappings(
          p_TYPE_MAPPINGS_TBL  IN   TYPE_MAPPINGS_Tbl_Type
                                    DEFAULT G_MISS_TYPE_MAPPINGS_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_Type_Mappings';
i                         NUMBER;
l_last                    NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.mcpk.Update_Type_Mappings';
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_TYPE_MAPPINGS_PUB;

   -- Debug Message
   IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       l_api_name || ' Start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   i := p_TYPE_MAPPINGS_TBL.first;
   l_last := p_TYPE_MAPPINGS_TBL.last;

   WHILE i <= l_last
   LOOP
       IF l_debug THEN
        AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
           'i=' || i);
       END IF;
       UPDATE AS_MC_TYPE_MAPPINGS
       SET
           PERIOD_SET_NAME = decode( p_TYPE_MAPPINGS_TBL(i).PERIOD_SET_NAME,
               FND_API.G_MISS_CHAR, PERIOD_SET_NAME,
               p_TYPE_MAPPINGS_TBL(i).PERIOD_SET_NAME),
           PERIOD_TYPE = decode( p_TYPE_MAPPINGS_TBL(i).PERIOD_TYPE,
               FND_API.G_MISS_CHAR, PERIOD_TYPE,
               p_TYPE_MAPPINGS_TBL(i).PERIOD_TYPE),
           CONVERSION_TYPE = decode( p_TYPE_MAPPINGS_TBL(i).CONVERSION_TYPE,
               FND_API.G_MISS_CHAR, CONVERSION_TYPE,
               p_TYPE_MAPPINGS_TBL(i).CONVERSION_TYPE),
           DESCRIPTION = decode( p_TYPE_MAPPINGS_TBL(i).DESCRIPTION,
               FND_API.G_MISS_CHAR, DESCRIPTION,
               p_TYPE_MAPPINGS_TBL(i).DESCRIPTION),
           UPDATEABLE_FLAG = decode( p_TYPE_MAPPINGS_TBL(i).UPDATEABLE_FLAG,
               FND_API.G_MISS_CHAR, UPDATEABLE_FLAG,
               p_TYPE_MAPPINGS_TBL(i).UPDATEABLE_FLAG),
           DELETEABLE_FLAG = decode( p_TYPE_MAPPINGS_TBL(i).DELETEABLE_FLAG,
               FND_API.G_MISS_CHAR, DELETEABLE_FLAG,
               p_TYPE_MAPPINGS_TBL(i).DELETEABLE_FLAG),
           LAST_UPDATE_DATE = SYSDATE,
           LAST_UPDATED_BY = FND_GLOBAL.USER_ID,
           LAST_UPDATE_LOGIN = FND_GLOBAL.CONC_LOGIN_ID
           --,
           -- SECURITY_GROUP_ID = decode(
           --    p_TYPE_MAPPINGS_TBL(i).SECURITY_GROUP_ID,
           --    FND_API.G_MISS_NUM, SECURITY_GROUP_ID,
           --   p_TYPE_MAPPINGS_TBL(i).SECURITY_GROUP_ID)
       WHERE PERIOD_SET_NAME = p_TYPE_MAPPINGS_TBL(i).PERIOD_SET_NAME
       AND   PERIOD_TYPE = p_TYPE_MAPPINGS_TBL(i).PERIOD_TYPE;

       IF (SQL%NOTFOUND) THEN
           RAISE NO_DATA_FOUND;
       END IF;
       i := i + 1;
   END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Update_Type_Mappings;

PROCEDURE Delete_Type_Mappings(
          p_TYPE_MAPPINGS_TBL  IN   TYPE_MAPPINGS_Tbl_Type
                                    DEFAULT G_MISS_TYPE_MAPPINGS_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Type_Mappings';
i                         NUMBER;
l_last                    NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.mcpk.Delete_Type_Mappings';
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_TYPE_MAPPINGS_PUB;

   -- Debug Message
   IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       l_api_name || ' Start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   i := p_TYPE_MAPPINGS_TBL.first;
   l_last := p_TYPE_MAPPINGS_TBL.last;
   WHILE i <= l_last
   LOOP
       DELETE FROM AS_MC_TYPE_MAPPINGS
       WHERE PERIOD_SET_NAME = p_TYPE_MAPPINGS_TBL(i).PERIOD_SET_NAME
       AND   PERIOD_TYPE = p_TYPE_MAPPINGS_TBL(i).PERIOD_TYPE;

       IF (SQL%NOTFOUND) THEN
           RAISE NO_DATA_FOUND;
       END IF;
       i := i + 1;
   END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );

EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
END Delete_Type_Mappings;


PROCEDURE Insert_Period_Rates(
          p_PERIOD_RATES_TBL   IN   PERIOD_RATES_Tbl_Type
                                    DEFAULT G_MISS_PERIOD_RATES_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Insert_Period_Rates';
i                         NUMBER;
l_last                    NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.mcpk.Insert_Period_Rates';
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT INSERT_PERIOD_RATES_PUB;

   -- Debug Message
   IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       l_api_name || ' Start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   i := p_PERIOD_RATES_TBL.first;
   l_last := p_PERIOD_RATES_TBL.last;
   WHILE i <= l_last
   LOOP
       INSERT INTO GL_DAILY_RATES_INTERFACE(
           FROM_CURRENCY,
           TO_CURRENCY,
           FROM_CONVERSION_DATE,
           TO_CONVERSION_DATE,
           USER_CONVERSION_TYPE,
           CONVERSION_RATE,
           MODE_FLAG,
           INVERSE_CONVERSION_RATE
       ) VALUES (
               decode( p_PERIOD_RATES_TBL(i).FROM_CURRENCY,
                       FND_API.G_MISS_CHAR, NULL,
                       p_PERIOD_RATES_TBL(i).FROM_CURRENCY),
               decode( p_PERIOD_RATES_TBL(i).TO_CURRENCY,
                       FND_API.G_MISS_CHAR, NULL,
                       p_PERIOD_RATES_TBL(i).TO_CURRENCY),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_DATE,
                       FND_API.G_MISS_DATE, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_DATE),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_DATE,
                       FND_API.G_MISS_DATE, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_DATE),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_TYPE,
                       FND_API.G_MISS_CHAR, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_TYPE),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_RATE,
                       FND_API.G_MISS_NUM, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_RATE),
               'I',
               NULL);

    i := i + 1;
    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Insert_Period_Rates;



PROCEDURE Update_Period_Rates(
          p_PERIOD_RATES_TBL   IN   PERIOD_RATES_Tbl_Type
                                    DEFAULT G_MISS_PERIOD_RATES_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Update_Period_Rates';
i                         NUMBER;
l_last                    NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.mcpk.Update_Period_Rates';
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT UPDATE_PERIOD_RATES_PUB;

   -- Debug Message
   IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       l_api_name || ' Start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   i := p_PERIOD_RATES_TBL.first;
   l_last := p_PERIOD_RATES_TBL.last;
   WHILE i <= l_last
   LOOP
       INSERT INTO GL_DAILY_RATES_INTERFACE(
           FROM_CURRENCY,
           TO_CURRENCY,
           FROM_CONVERSION_DATE,
           TO_CONVERSION_DATE,
           USER_CONVERSION_TYPE,
           CONVERSION_RATE,
           MODE_FLAG,
           INVERSE_CONVERSION_RATE
       ) VALUES (
               decode( p_PERIOD_RATES_TBL(i).FROM_CURRENCY,
                       FND_API.G_MISS_CHAR, NULL,
                       p_PERIOD_RATES_TBL(i).FROM_CURRENCY),
               decode( p_PERIOD_RATES_TBL(i).TO_CURRENCY,
                       FND_API.G_MISS_CHAR, NULL,
                       p_PERIOD_RATES_TBL(i).TO_CURRENCY),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_DATE,
                       FND_API.G_MISS_DATE, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_DATE),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_DATE,
                       FND_API.G_MISS_DATE, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_DATE),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_TYPE,
                       FND_API.G_MISS_CHAR, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_TYPE),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_RATE,
                       FND_API.G_MISS_NUM, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_RATE),
               'I',
               NULL);

    i := i + 1;
    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Update_Period_Rates;



PROCEDURE Delete_Period_Rates(
          p_PERIOD_RATES_TBL   IN   PERIOD_RATES_Tbl_Type
                                    DEFAULT G_MISS_PERIOD_RATES_TBL,
          X_Return_Status      OUT NOCOPY /* file.sql.39 change */  VARCHAR2,
          X_Msg_Count          OUT NOCOPY /* file.sql.39 change */  NUMBER,
          X_Msg_Data           OUT NOCOPY /* file.sql.39 change */  VARCHAR2)
IS
l_api_name                CONSTANT VARCHAR2(30) := 'Delete_Period_Rates';
i                         NUMBER;
l_last                    NUMBER;
l_debug BOOLEAN := FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW);
l_module CONSTANT VARCHAR2(255) := 'as.plsql.mcpk.Delete_Period_Rates';
BEGIN
   -- Standard Start of API savepoint
   SAVEPOINT DELETE_PERIOD_RATES_PUB;

   -- Debug Message
   IF l_debug THEN
    AS_UTILITY_PVT.Debug_Message(l_module, FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
       l_api_name || ' Start');
   END IF;

   -- Initialize API return status to SUCCESS
   x_return_status := FND_API.G_RET_STS_SUCCESS;

   i := p_PERIOD_RATES_TBL.first;
   l_last := p_PERIOD_RATES_TBL.last;
   WHILE i <= l_last
   LOOP
       INSERT INTO GL_DAILY_RATES_INTERFACE(
           FROM_CURRENCY,
           TO_CURRENCY,
           FROM_CONVERSION_DATE,
           TO_CONVERSION_DATE,
           USER_CONVERSION_TYPE,
           CONVERSION_RATE,
           MODE_FLAG,
           INVERSE_CONVERSION_RATE
       ) VALUES (
               decode( p_PERIOD_RATES_TBL(i).FROM_CURRENCY,
                       FND_API.G_MISS_CHAR, NULL,
                       p_PERIOD_RATES_TBL(i).FROM_CURRENCY),
               decode( p_PERIOD_RATES_TBL(i).TO_CURRENCY,
                       FND_API.G_MISS_CHAR, NULL,
                       p_PERIOD_RATES_TBL(i).TO_CURRENCY),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_DATE,
                       FND_API.G_MISS_DATE, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_DATE),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_DATE,
                       FND_API.G_MISS_DATE, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_DATE),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_TYPE,
                       FND_API.G_MISS_CHAR, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_TYPE),
               decode( p_PERIOD_RATES_TBL(i).CONVERSION_RATE,
                       FND_API.G_MISS_NUM, NULL,
                       p_PERIOD_RATES_TBL(i).CONVERSION_RATE),
               'D',
               NULL);
    i := i + 1;
    END LOOP;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get
    (  p_count          =>   x_msg_count,
       p_data           =>   x_msg_data
    );
EXCEPTION
          WHEN FND_API.G_EXC_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);

          WHEN OTHERS THEN
              AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
                   P_MODULE => l_module
                  ,P_API_NAME => L_API_NAME
                  ,P_PKG_NAME => G_PKG_NAME
                  ,P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
                  ,P_SQLCODE => SQLCODE
                  ,P_SQLERRM => SQLERRM
                  ,P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PUB
                  ,X_MSG_COUNT => X_MSG_COUNT
                  ,X_MSG_DATA => X_MSG_DATA
                  ,X_RETURN_STATUS => X_RETURN_STATUS);
End Delete_Period_Rates;

End AS_MULTI_CURRENCIES_PKG;

/
