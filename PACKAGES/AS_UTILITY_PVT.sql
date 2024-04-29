--------------------------------------------------------
--  DDL for Package AS_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AS_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: asxvutls.pls 120.1 2005/07/07 23:49:25 appldev ship $ */

-- Start of Comments
--
-- NAME
--   AS_UTILITY_PVT
--
-- PURPOSE
--   This package is a public utility API developed from Sales Core group
--
--   Constants:

--    G_PVT
--    G_PUB
--    G_EXC_OTHERS
--    G_CREATE
--    G_UPDATE
--
--
--   Procedures:
--    Start_API
--    End_API
--    Handle_Exceptions
--    Translate_OrderBy
--    Get_Messages
--    Debug_Message
--    Set_Message
--    Gen_Flexfield_Where
--    Bind_Flexfield_Where
--
-- NOTES
--
--
-- HISTORY
--   08/11/99   AWU                  CREATED(as AS_UTILITY)
--   09/09/99   SOLIN                UPDATED(change to JTF_PLSQL_API)
--   11/12/02   AXAVIER              Bug#2659173 Changed the procedure Debug_Message.

--
--
-- End of Comments

--------------------------------------------------------------------
--
--                    PUBLIC CONSTANTS
--
--------------------------------------------------------------------


-- ************************************************************
-- The following constants are for exception handling routine
-- ************************************************************
--
-- Exceptions Handling Routine will do the following:
-- 1. Rollback to savepoint
-- 2. Handle expected, unexpected and other exceptions
-- 3. Add an error message to the API message list
-- 4. Return error status
--
-- The following is example of calling exception handling routines:
--
-- EXCEPTION
-- WHEN FND_API.G_EXC_ERROR THEN
--     AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
--                         P_API_NAME => L_API_NAME
--                       , P_PGK_NAME => G_PKG_NAME
--                       , P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_ERROR
--                       , P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
--                       , X_MSG_COUNT   => X_MSG_COUNT
--                       , X_MSG_DATA    => X_MSG_DATA
--                       , X_RETURN_STATUS => x_return_status
-- );

-- WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--     AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
--                         P_API_NAME => L_API_NAME
--                       , P_PGK_NAME => G_PKG_NAME
--                       , P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
--                       , P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
--                       , X_MSG_COUNT   => X_MSG_COUNT
--                       , X_MSG_DATA    => X_MSG_DATA
--                       , X_RETURN_STATUS => x_return_status
-- );

-- WHEN OTHERS THEN
--     AS_UTILITY_PVT.HANDLE_EXCEPTIONS(
--                         P_API_NAME => L_API_NAME
--                       , P_PGK_NAME => G_PKG_NAME
--                       , P_EXCEPTION_LEVEL => AS_UTILITY_PVT.G_EXC_OTHERS
--                       , P_PACKAGE_TYPE => AS_UTILITY_PVT.G_PVT
--                       , X_MSG_COUNT   => X_MSG_COUNT
--                       , X_MSG_DATA    => X_MSG_DATA
--                       , X_RETURN_STATUS => x_return_status
-- );

-- Global variables for package type, used in Handle_Exceptions
G_PVT  VARCHAR2(30) := '_PVT';
G_PUB  VARCHAR2(30) := '_PUB';

-- Global variable for others exception
G_EXC_OTHERS  NUMBER := 200;

-- ************************************************************
-- The following global variables is used in validation procedures
-- -> validation_mode
-- ************************************************************
G_CREATE  VARCHAR2(30) := 'CREATE';
G_UPDATE  VARCHAR2(30) := 'UPDATE';


--------------------------------------------------------------------
--
--                    PUBLIC DATATYPES
--
--------------------------------------------------------------------

--
-- Start of Comments
--
--     Order by record: util_order_by_rec_type
--
--    Notes:
--    1. col_choice is a two or three digit number.
--       First digit represents the priority for the order by column.
--       (If priority > 10, use 2 digits to represent it)
--       Second(or third) digit represents the descending or ascending
--       order for the query result. 1 for ascending and 0 for descending.
--    2. col_name is the order by column name.
--
-- End of Comments

TYPE util_order_by_rec_type IS RECORD
(
    col_choice NUMBER        := FND_API.G_MISS_NUM,
    col_name   VARCHAR2(30)  := FND_API.G_MISS_CHAR
);

G_MISS_UTIL_ORDER_BY_REC    util_order_by_rec_type;

TYPE util_order_by_tbl_type IS TABLE OF     util_order_by_rec_type
                            INDEX BY BINARY_INTEGER;


-- Start of Comments
--
--     Flexfield where record: flex_where_rec_type
--
--    Notes: 1. name is the column name in where clause. Its format is
--		table_alias.column_name.
--	     2. value is the search criteria for the column
--
-- End of Comments

TYPE flex_where_rec_type      IS RECORD
(
    name      VARCHAR2(30)   := FND_API.G_MISS_CHAR,
    value     VARCHAR2(150)  := FND_API.G_MISS_CHAR
);

TYPE flex_where_tbl_type IS TABLE OF flex_where_rec_type
                         INDEX BY BINARY_INTEGER;


--------------------------------------------------------------------
--
--                    PUBLIC APIS
--
--------------------------------------------------------------------

-- Start of Comments
--
--      API name        : Start_API
--      Type            : Public
--      Function        : Prolog before API starts
--                        1. Set saveporint
--                        2. Check version number
--                        3. Initialize message list
--                        4. Invoke callout procedure
--
--
--      Parameters      :
--      IN              :
--            p_api_name              IN      VARCHAR2,
--            p_pkg_name              IN      VARCHAR2,
--            p_init_msg_list         IN      VARCHAR2,
--            p_l_api_version         IN      NUMBER,
--            p_api_version           IN      NUMBER,
--            p_api_type              IN      VARCHAR2,
--      OUT             :
--            x_return_status         OUT     NOCOPY      VARCHAR2(1)
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--
-- End of Comments

PROCEDURE Start_API(
    p_api_name              IN      VARCHAR2,
    p_pkg_name              IN      VARCHAR2,
    p_init_msg_list         IN      VARCHAR2,
    p_l_api_version         IN      NUMBER,
    p_api_version           IN      NUMBER,
    p_api_type              IN      VARCHAR2,
    x_return_status         OUT     NOCOPY       VARCHAR2
);


-- Start of Comments
--
--      API name        : End_API
--      Type            : Public
--      Function        : Epilog of API
--                        1. Check whether it needs commit or not
--                        2. Get message count
--                        3. Invoke callout procedure
--
--
--      Parameters      :
--      IN              : none.
--      OUT             :
--            x_msg_count            OUT     NUMBER,
--            x_msg_data             OUT     VARCHAR2
--
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--
-- End of Comments

PROCEDURE End_API(
    x_msg_count             OUT     NOCOPY       NUMBER,
    x_msg_data              OUT     NOCOPY       VARCHAR2
);



-- Start of Comments
--
--      API name        : Handle_Exceptions
--      Type            : Public
--      Function        : Exception handling routine
--                        1. Called by Call_Exception_Handlers
--                        2. Handle exception according to different
--                           p_exception_level
--
--
--      Parameters      :
--      IN              :
--            p_api_name              IN      VARCHAR2
--            p_pkg_name              IN      VARCHAR2
--            p_exception_level       IN      NUMBER
--            p_package_type          IN      VARCHAR2
--            x_msg_count             IN      NUMBER
--            x_msg_data              IN      VARCHAR2
--      OUT             :
--
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
-- End of Comments
PROCEDURE Handle_Exceptions(
                P_API_NAME        IN  VARCHAR2,
                P_PKG_NAME        IN  VARCHAR2,
                P_EXCEPTION_LEVEL IN  NUMBER   := FND_API.G_MISS_NUM,
                P_SQLCODE         IN  NUMBER   DEFAULT NULL,
                P_SQLERRM         IN  VARCHAR2 DEFAULT NULL,
                P_PACKAGE_TYPE    IN  VARCHAR2,
                P_ROLLBACK_FLAG   IN  VARCHAR2 := 'Y',
                X_MSG_COUNT       OUT     NOCOPY   NUMBER,
                X_MSG_DATA        OUT     NOCOPY   VARCHAR2,
                X_RETURN_STATUS   OUT     NOCOPY   VARCHAR2
);
PROCEDURE Handle_Exceptions(
                P_MODULE          IN  VARCHAR2,
                P_API_NAME        IN  VARCHAR2,
                P_PKG_NAME        IN  VARCHAR2,
                P_EXCEPTION_LEVEL IN  NUMBER   := FND_API.G_MISS_NUM,
                P_SQLCODE         IN  NUMBER   DEFAULT NULL,
                P_SQLERRM         IN  VARCHAR2 DEFAULT NULL,
                P_PACKAGE_TYPE    IN  VARCHAR2,
                P_ROLLBACK_FLAG   IN  VARCHAR2 := 'Y',
                X_MSG_COUNT       OUT     NOCOPY   NUMBER,
                X_MSG_DATA        OUT     NOCOPY   VARCHAR2,
                X_RETURN_STATUS   OUT     NOCOPY   VARCHAR2
);



-- Start of Comments
--
--      API name        : translate_orderBy
--      Type            : Public
--      Function        : translate order by choice numbers and columns into
--                        a order by string with the order of column names and
--                        descending or ascending request.
--
--
--      Parameters      :
--      IN              :
--            p_api_version_number    IN      NUMBER,
--            p_init_msg_list         IN      VARCHAR2
--            p_validation_level      IN      NUMBER
--      OUT             :
--            x_return_status         OUT     NOCOPY       VARCHAR2(1)
--            x_msg_count             OUT     NOCOPY       NUMBER
--            x_msg_data              OUT     NOCOPY       VARCHAR2(2000)
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--
-- End of Comments

PROCEDURE Translate_OrderBy(
    p_api_version_number     IN      NUMBER,
    p_init_msg_list          IN      VARCHAR2
                  := FND_API.G_FALSE,
    p_validation_level       IN      NUMBER
                  := FND_API.G_VALID_LEVEL_FULL,
    p_order_by_tbl           IN     UTIL_ORDER_BY_TBL_TYPE,
    x_order_by_clause        OUT     NOCOPY       VARCHAR2,
    x_return_status          OUT     NOCOPY       VARCHAR2,
    x_msg_count              OUT     NOCOPY       NUMBER,
    x_msg_data               OUT     NOCOPY       VARCHAR2
);


-- Start of Comments
--
--      API name        : Get_Messages
--      Type            : Public
--      Function        : Get messages from message dictionary
--
--
--      Parameters      :
--      IN              :
--            p_message_count         IN      NUMBER,
--      OUT             :
--            x_msgs                  OUT     VARCHAR2
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--
-- End of Comments
PROCEDURE Get_Messages(
    p_message_count     IN     NUMBER,
    x_msgs              OUT     NOCOPY      VARCHAR2
);


-- Start of Comments
--
-- Message levels:
--
-- The pre-defined debug message levels are defined in FND_MSG_PUB
-- package as follows:
--     G_MSG_LVL_DEBUG_HIGH    CONSTANT NUMBER := 30;
--     G_MSG_LVL_DEBUG_MEDIUM  CONSTANT NUMBER := 20;
--     G_MSG_LVL_DEBUG_LOW     CONSTANT NUMBER := 10;
-- The usage for the above mentioned debug levels:
-- High:
--     Procedure and function call signatures, and major events like
--     choosing one of two or more processing methods.
-- Medium:
--     Dynamic SQL statements, SQL bind variables and intermediate
--     level events like results of calculations or important flags.
-- Low:
--     Variables inside loops, all decisions, and all intermediate
--     results.
--
-- The pre-defined exception message levels in FND_MSG_PUB package
-- are as follows:
--     G_MSG_LVL_UNEXP_ERROR   CONSTANT NUMBER := 60;
--     G_MSG_LVL_ERROR         CONSTANT NUMBER := 50;
--     G_MSG_LVL_SUCCESS       CONSTANT NUMBER := 40;
-- Their usage are as their names implied.
--
-- If you'd like to get message from message table, the sample code is below.
-- l_count    NUMBER;
-- l_msg_data VARCHAR2(2000);
--
-- l_count := FND_MSG_PUB.Count_Msg;
-- FOR l_index IN 1..l_count LOOP
--     l_msg_data := FND_MSG_PUB.Get(
--         p_msg_index   =>  l_index,
--         p_encoded     =>  FND_API.G_TRUE);
--     dbms_output.put_line(l_msg_data);
-- END LOOP;
--
-- End of Comments


-- Start of Comments
--
--      API name        : Debug_Message
--      Type            : Public
--      Function        : Put a debug message into FND_MSG_PUB
--                        message table
--
--      Parameters      :
--      IN              :
--            p_msg_level    IN      NUMBER,
--            p_app_name     IN      VARCHAR2,
--            p_msg          IN      VARCHAR2
--      OUT             : none.
--
--
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes:
--      1. If you want to print a debug message, you should not use
--         dbms_output.put_line(), instead, you should call this Debug_Message
--         procedure. The parameter p_msg_level can be one of the following:
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_SUCCESS
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_ERROR
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_UNEXP_ERROR
--      2. The calling example is like this:
--         AS_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
--         'Forecast Id: '||to_char(l_forecast_rec.forecast_id));
--      3. This API is for printing debug message use. If you'd like to
--         put tokens into FND_MSG_PUB message table, please use
--         Set_Message API described below.
--
-- End of Comments
PROCEDURE Debug_Message(
    p_msg_level IN NUMBER,
--    p_app_name  IN VARCHAR2,
    p_msg       IN VARCHAR2
);
PROCEDURE Debug_Message(
    p_module    IN VARCHAR2,
    p_msg_level IN NUMBER,
    p_msg       IN VARCHAR2
);



-- Start of Comments
--
--   The following five overloading Set_Message APIs will put message
--   name and token(s) into FND_MSG_PUB message table. These overloading
--   APIs are transparent to developers. We provide these APIs with
--   different number of arguments because of performance consideration.
--   System loader has to allocate stack for arguments at run time. If
--   there is only one token, it will invoke the API which needs one
--   token only, and hence take less resource than API with two tokens.
--
-- End of Comments


-- Start of Comments
--
--      API name        : Set_Message
--      Type            : Public
--      Function        : Put 0 token into FND_MSG_PUB message table
--
--      Parameters      :
--      IN              :
--            p_msg_level     IN      NUMBER,
--            p_app_name      IN      VARCHAR2,
--            p_msg_name      IN      VARCHAR2
--      OUT             : none.
--
--
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes:
--      1. The parameter p_msg_level can be one of the following:
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_MEDIUM
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_HIGH
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_SUCCESS
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_ERROR
--            FND_MSG_PUB.G_MSG_LVL_DEBUG_UNEXP_ERROR
--      2. p_app_name is your short name of the application this message
--         is associated with.
--      3. p_msg_name is the message name that identifies your message.
--      4. p_token? specify the name of the token you want to substitute.
--      5. p_token?_value indicate your substitute text. You can include
--         as much substitute text as necessary for the message you call.
--      6. The number of token is restricted to be less than or equal to
--         the number of API name specifies.
--      7. The calling example is like this:
--         AS_UTILITY_PVT.Set_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS',
--         'MY_AP_MESSAGE', 'FILENAME', 'myfile.doc');
--         AS_UTILITY_PVT.Set_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS',
--         'MY_AP_MESSAGE', 'FILENAME', 'myfile.doc', 'USERNAME', username);
--
-- End of Comments

PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2
);
PROCEDURE Set_Message(
    p_module        IN      VARCHAR2,
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2
);

-- Start of Comments
--
--      API name        : Set_Message
--      Type            : Public
--      Function        : Put 1 token into FND_MSG_PUB message table
--
--      Parameters      :
--      IN              :
--            p_msg_level     IN      NUMBER,
--            p_app_name      IN      VARCHAR2,
--            p_msg_name      IN      VARCHAR2,
--            p_token1        IN      VARCHAR2,
--            p_token1_value  IN      VARCHAR2
--      OUT             : none.
--
--
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes:
--      See Set_Message()
--
-- End of Comments
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2
);
PROCEDURE Set_Message(
    p_module        IN      VARCHAR2,
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2
);



-- Start of Comments
--
--      API name        : Set_Message
--      Type            : Public
--      Function        : Put 2 tokens into FND_MSG_PUB message table
--
--      Parameters      :
--      IN              :
--            p_msg_level     IN      NUMBER,
--            p_app_name      IN      VARCHAR2,
--            p_msg_name      IN      VARCHAR2,
--            p_token1        IN      VARCHAR2,
--            p_token1_value  IN      VARCHAR2,
--            p_token2        IN      VARCHAR2,
--            p_token2_value  IN      VARCHAR2
--      OUT             : none.
--
--
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes:
--      See Set_Message()
--
-- End of Comments
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2
);
PROCEDURE Set_Message(
    p_module        IN      VARCHAR2,
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2
);



-- Start of Comments
--
--      API name        : Set_Message
--      Type            : Public
--      Function        : Put 3 tokens into FND_MSG_PUB message table
--
--      Parameters      :
--      IN              :
--            p_msg_level     IN      NUMBER,
--            p_app_name      IN      VARCHAR2,
--            p_msg_name      IN      VARCHAR2,
--            p_token1        IN      VARCHAR2,
--            p_token1_value  IN      VARCHAR2,
--            p_token2        IN      VARCHAR2,
--            p_token2_value  IN      VARCHAR2,
--            p_token3        IN      VARCHAR2,
--            p_token3_value  IN      VARCHAR2
--      OUT             : none.
--
--
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes:
--      See Set_Message()
--
-- End of Comments
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2
);
PROCEDURE Set_Message(
    p_module        IN      VARCHAR2,
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2
);

-- Start of Comments
--
--      API name        : Set_Message
--      Type            : Public
--      Function        : Put 7 tokens into FND_MSG_PUB message table
--
--      Parameters      :
--      IN              :
--            p_msg_level     IN      NUMBER,
--            p_app_name      IN      VARCHAR2,
--            p_msg_name      IN      VARCHAR2,
--            p_token1        IN      VARCHAR2,
--            p_token1_value  IN      VARCHAR2,
--            p_token2        IN      VARCHAR2,
--            p_token2_value  IN      VARCHAR2,
--            p_token3        IN      VARCHAR2,
--            p_token3_value  IN      VARCHAR2,
--            p_token4        IN      VARCHAR2,
--            p_token4_value  IN      VARCHAR2,
--            p_token5        IN      VARCHAR2,
--            p_token5_value  IN      VARCHAR2,
--            p_token6        IN      VARCHAR2,
--            p_token6_value  IN      VARCHAR2,
--            p_token7        IN      VARCHAR2,
--            p_token7_value  IN      VARCHAR2
--      OUT             : none.
--
--
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes:
--      See Set_Message()
--
-- End of Comments
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
--    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2,
    p_token4        IN      VARCHAR2,
    p_token4_value  IN      VARCHAR2,
    p_token5        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token5_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token6        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token6_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token7        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token7_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR
);
PROCEDURE Set_Message(
    p_module        IN      VARCHAR2,
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2,
    p_token2        IN      VARCHAR2,
    p_token2_value  IN      VARCHAR2,
    p_token3        IN      VARCHAR2,
    p_token3_value  IN      VARCHAR2,
    p_token4        IN      VARCHAR2,
    p_token4_value  IN      VARCHAR2,
    p_token5        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token5_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token6        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token6_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token7        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token7_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR
);





-- Start of Comments
--
--      API Name        : Gen_Flexfield_Where
--      Type            : Public
--      Function        : common procedure for flexfield search with binding
--      Parameters      :
--      IN              :
--            p_flex_where_tbl_type    : column names and the search criteria
--                                       for those columns in where clause
--
--      OUT             :
--            x_flex_where_clause      : where clause based on flexfield, the
--                                       format of which like ' AND
--                                       table.column1 = :p_ofso_flex_var1 AND
--                                       table.column2 = :p_ofso_flex_var2 ....'
--
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes:
--
-- End of Comments

PROCEDURE Gen_Flexfield_Where(
    p_flex_where_tbl_type   IN   AS_UTILITY_PVT.flex_where_tbl_type,
    x_flex_where_clause     OUT     NOCOPY    VARCHAR2
);

-- Start of Comments
--
--      API Name        : Bind_Flexfield_Where
--      Type            : Public
--      Function        : common procedure for flexfield search with binding.
--                        Bind placeholders in the where clause generated by
--                        Gen_Flexfield_Where.
--      Parameters      :
--      IN              :
--            p_cursor_id              : identifier of the cursor for binding.
--            p_flex_where_tbl_type    : column names and the search criteria
--                                       for those columns in where clause
--
--      OUT             : none.
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes:
--
-- End of Comments

PROCEDURE Bind_Flexfield_Where(
    p_cursor_id              IN  NUMBER,
    p_flex_where_tbl_type    IN  AS_UTILITY_PVT.flex_where_tbl_type
);


PROCEDURE file_debug(line IN VARCHAR2);
PROCEDURE enable_file_debug(path_name IN VARCHAR2,
                            file_name IN VARCHAR2);

PROCEDURE disable_file_debug;

FUNCTION get_degree_parallelism RETURN NUMBER;

PROCEDURE capture_index_definitions(errbuf OUT     NOCOPY   VARCHAR2,
                                    retcode OUT     NOCOPY   VARCHAR2,
                                    p_table_name VARCHAR2,
                                    p_table_owner VARCHAR2);

PROCEDURE  execute_ind(errbuf OUT     NOCOPY   VARCHAR2,
                       retcode OUT     NOCOPY   VARCHAR2,
                       p_mode VARCHAR2,
                       p_table_name VARCHAR2,
                       p_table_owner VARCHAR2);

END AS_UTILITY_PVT;

 

/
