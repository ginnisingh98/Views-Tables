--------------------------------------------------------
--  DDL for Package ASO_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ASO_UTILITY_PVT" AUTHID CURRENT_USER as
/* $Header: asovutls.pls 120.8 2006/09/21 18:18:34 skulkarn ship $ */
-- Start of Comments
--
-- NAME
--   ASO_UTILITY_PVT
--
-- PURPOSE
--   This package is a public utility API developed from Sales Core group
--
--   Constants:
--    G_VALID_LEVEL_ITEM
--    G_VALID_LEVEL_RECORD
--    G_VALID_LEVEL_INTER_RECORD
--    G_VALID_LEVEL_INTER_ENTITY
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
--    Debug_Message
--    Set_Message
--    Gen_Flexfield_Where
--    Bind_Flexfield_Where
--
-- NOTES
--
--
-- HISTORY
--
--
-- End of Comments

--------------------------------------------------------------------
--
--                    PUBLIC CONSTANTS
--
--------------------------------------------------------------------

-- ************************************************************
-- The following constants are for validation levels.
-- ************************************************************
--
-- There are four types of validation APIs need to be provided:
-- Item level validation, Record level validation, Inter-record
-- level validation and Inter-entity level validation.
--
-- 1. Item level validation:
-- Validation of an individual item needs to be checked.
-- 2. Record level validation:
-- Missing-field and cross-field dependencies should be checked
-- 3. Inter-record(table) level validation:
-- Cross-record dependencies should be checked
-- 4. Inter- entity(among different records) level validation:
-- For multi-instance child entities, cross entity validation
-- should be performed. The order of execution depends on business
-- logic.
--
-- Public APIs by definition have to perform FULL validation on all
-- data passed to them; Accordingly, there should be no validation
-- levels defined for public APIs. Private APIs should include
-- p_validation_level parameter. Therefore, private APIs have more
-- flexibility when it comes to validation.
--
-- When form interface calls APIs, it can call private APIs. it should
-- pass JTF_PL_SQL_API.G_VALID_LEVEL_XXX for parameter p_validation_level.
-- In our API coding, we need to handle those validation levels . Please
-- do the following check in your API:
--
-- IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_ITEM
-- THEN
-- 	Perform  item level validation;
-- END IF;
--
-- IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_FIELD)
-- THEN
--	Perform record level validation;
-- END IF;
--
-- IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_RECORD)
-- THEN
--	Perform inter-record level validation;
-- END IF;
--
-- IF (p_validation_level >= ASO_UTILITY_PVT.G_VALID_LEVEL_INTER_ENTITY)
-- THEN
--	Perform inter-entity level validation;
-- END IF;
--
-- If you pass in JTF_PL_SQL_API.G_VALID_LEVEL_INTER_FIELD for
-- p_validation_level, item level validation will be bypassed. Record
-- level validation, inter-record level validation and inter-entity
-- level validation will be executed. For item level validation, form
-- interface can either use LOV or validation procedures to validate
-- data. If pass in validation level is FULL, all of the validations
-- above will be executed automatically.  As for get_currentUser and
-- access check, we should do the following:
--
-- if (p_validation_level = FND_API.G_VALID_LEVEL_FULL)
-- then
--	Call get_currentUser;
--	Call has_xxxAccess;
-- end if;
-- Access API can be bypassed by Form since form will use business view
-- to handle access privilege check.
--

-- Perform item level validation only
G_VALID_LEVEL_ITEM CONSTANT NUMBER:= 90;

-- Perform record level(inter-field) validation only
G_VALID_LEVEL_RECORD CONSTANT NUMBER:= 80;

-- Perform inter-record level validation only
G_VALID_LEVEL_INTER_RECORD CONSTANT NUMBER:= 70;

-- Perform inter-entity level validation only
G_VALID_LEVEL_INTER_ENTITY CONSTANT NUMBER:= 60;


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
--     ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
--                         P_API_NAME => L_API_NAME
--                       , P_PGK_NAME => G_PKG_NAME
--                       , P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_ERROR
--                       , P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
--                       , X_MSG_COUNT   => X_MSG_COUNT
--                       , X_MSG_DATA    => X_MSG_DATA
--                       , X_RETURN_STATUS => x_return_status
-- );

-- WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
--     ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
--                         P_API_NAME => L_API_NAME
--                       , P_PGK_NAME => G_PKG_NAME
--                       , P_EXCEPTION_LEVEL  => FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR
--                       , P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
--                       , X_MSG_COUNT   => X_MSG_COUNT
--                       , X_MSG_DATA    => X_MSG_DATA
--                       , X_RETURN_STATUS => x_return_status
-- );

-- WHEN OTHERS THEN
--     ASO_UTILITY_PVT.HANDLE_EXCEPTIONS(
--                         P_API_NAME => L_API_NAME
--                       , P_PGK_NAME => G_PKG_NAME
--                       , P_EXCEPTION_LEVEL => ASO_UTILITY_PVT.G_EXC_OTHERS
--                       , P_PACKAGE_TYPE => ASO_UTILITY_PVT.G_PVT
--                       , X_MSG_COUNT   => X_MSG_COUNT
--                       , X_MSG_DATA    => X_MSG_DATA
--                       , X_RETURN_STATUS => x_return_status
-- );

-- Global variables for package type, used in Handle_Exceptions
G_PVT  VARCHAR2(30) := '_PVT';
G_INT  VARCHAR2(30) := '_INT';
G_PUB  VARCHAR2(30) := '_PUB';

-- Global variable for others exception
G_EXC_OTHERS  NUMBER := 100;

-- ************************************************************
-- The following global variables is used in validation procedures
-- -> validation_mode
-- ************************************************************
G_CREATE  VARCHAR2(30) := 'CREATE';
G_UPDATE  VARCHAR2(30) := 'UPDATE';

-- Change START
-- Release 12 MOAC Changes : Bug 4500739
-- Changes Done by : Girish
-- Comments : The following global variables are used in the functions for
-- retrieving the HR EIT data.

G_DEFAULT_ORDER_TYPE		VARCHAR2(100) := 'ORDER_TYPE';
G_DEFAULT_SALESREP		VARCHAR2(100) := 'SALESREP';
G_DEFAULT_SALES_GROUP		VARCHAR2(100) := 'SALES_GROUP';
G_DEFAULT_SALES_ROLE		VARCHAR2(100) := 'SALES_ROLE';
G_DEFAULT_CONTRACT_TEMPLATE	VARCHAR2(100) := 'CONTRACT_TEMPLATE';

-- Change END

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
--     Item property record: item_property_rec_type
--
--    Notes:
--     This record type is for record type for item level validation
--
-- End of Comments

TYPE item_property_rec_type IS RECORD
(
    column_name         VARCHAR2(30)   := FND_API.G_MISS_CHAR,
    required_flag       VARCHAR2(1)    := 'N', -- may be changed to FND_API.G_MISS_CHAR
    update_allowed_flag VARCHAR2(1)    := 'Y', -- may be changed to FND_API.G_MISS_CHAR
    default_char_val    VARCHAR2(320)  := FND_API.G_MISS_CHAR,
    default_num_val     NUMBER         := FND_API.G_MISS_NUM,
    default_date_val    DATE           := FND_API.G_MISS_DATE
);

G_MISS_ITEM_PROPERTY_REC    item_property_rec_type;

TYPE item_property_tbl_type IS TABLE OF item_property_rec_type
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

--
-- The following Table type is used by Query_pricing_line_rows.
-- This is used for collection parent service line id(s).
--

TYPE Index_Link_Tbl_Type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
G_MISS_Link_Tbl	 Index_Link_Tbl_Type;

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
--      OUT NOCOPY /* file.sql.39 change */             :
--            x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2(1)
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
    x_return_status         OUT NOCOPY /* file.sql.39 change */       VARCHAR2
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
--      OUT NOCOPY /* file.sql.39 change */             :
--            x_msg_count            OUT NOCOPY /* file.sql.39 change */     NUMBER,
--            x_msg_data             OUT NOCOPY /* file.sql.39 change */     VARCHAR2
--
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--
-- End of Comments

PROCEDURE End_API(
    x_msg_count             OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data              OUT NOCOPY /* file.sql.39 change */       VARCHAR2
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
--      OUT NOCOPY /* file.sql.39 change */             :
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
                P_SQLCODE         IN  NUMBER   := NULL,
                P_SQLERRM         IN  VARCHAR2 := NULL,
                P_PACKAGE_TYPE    IN  VARCHAR2,
                X_MSG_COUNT       OUT NOCOPY /* file.sql.39 change */   NUMBER,
                X_MSG_DATA        OUT NOCOPY /* file.sql.39 change */   VARCHAR2,
                X_RETURN_STATUS   OUT NOCOPY /* file.sql.39 change */   VARCHAR2
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
--      OUT NOCOPY /* file.sql.39 change */             :
--            x_return_status         OUT NOCOPY /* file.sql.39 change */     VARCHAR2(1)
--            x_msg_count             OUT NOCOPY /* file.sql.39 change */     NUMBER
--            x_msg_data              OUT NOCOPY /* file.sql.39 change */     VARCHAR2(2000)
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
    x_order_by_clause        OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_return_status          OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count              OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data               OUT NOCOPY /* file.sql.39 change */       VARCHAR2
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
--      OUT NOCOPY /* file.sql.39 change */             : none.
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
--         ASO_UTILITY_PVT.Debug_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW,
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



-- Start of Comments
--
--   The following four overloading Set_Message APIs will put message
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
--      Function        : Put 1 message into FND_MSG_PUB message table
--
--      Parameters      :
--      IN              :
--            p_msg_level     IN      NUMBER,
--            p_msg_name      IN      VARCHAR2,
--            p_token1        IN      VARCHAR2,
--            p_token1_value  IN      VARCHAR2
--      OUT NOCOPY /* file.sql.39 change */             : none.
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
--         ASO_UTILITY_PVT.Set_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS',
--         'MY_AP_MESSAGE', 'FILENAME', 'myfile.doc');
--         ASO_UTILITY_PVT.Set_Message(FND_MSG_PUB.G_MSG_LVL_DEBUG_LOW, 'AS',
--         'MY_AP_MESSAGE', 'FILENAME', 'myfile.doc', 'USERNAME', username);
--
-- End of Comments
PROCEDURE Set_Message(
    p_msg_level     IN      NUMBER,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2,
    p_token1_value  IN      VARCHAR2
);



-- Start of Comments
--
--      API name        : Set_Message
--      Type            : Public
--      Function        : Put 2 messages into FND_MSG_PUB message table
--
--      Parameters      :
--      IN              :
--            p_msg_level     IN      NUMBER,
--            p_app_name      IN      VARCHAR2,
--            p_msg_name      IN      VARCHAR2,
--            p_token1        IN      VARCHAR2,
--            p_token1_value  IN      VARCHAR2
--            p_token2        IN      VARCHAR2,
--            p_token2_value  IN      VARCHAR2
--      OUT NOCOPY /* file.sql.39 change */             : none.
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
    p_app_name      IN      VARCHAR2,
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
--      Function        : Put 3 messags into FND_MSG_PUB message table
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
--      OUT NOCOPY /* file.sql.39 change */             : none.
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
    p_app_name      IN      VARCHAR2,
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
--      Function        : Put 7 messages into FND_MSG_PUB message table
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
--      OUT NOCOPY /* file.sql.39 change */             : none.
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
    p_app_name      IN      VARCHAR2,
    p_msg_name      IN      VARCHAR2,
    p_token1        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token1_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token2        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token2_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token3        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token3_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token4        IN      VARCHAR2 := FND_API.G_MISS_CHAR,
    p_token4_value  IN      VARCHAR2 := FND_API.G_MISS_CHAR,
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
--      OUT NOCOPY /* file.sql.39 change */             :
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
    p_flex_where_tbl_type   IN   ASO_UTILITY_PVT.flex_where_tbl_type,
    x_flex_where_clause     OUT NOCOPY /* file.sql.39 change */    VARCHAR2
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
--      OUT NOCOPY /* file.sql.39 change */             : none.
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--      Notes:
--
-- End of Comments

PROCEDURE Bind_Flexfield_Where(
    p_cursor_id              IN  NUMBER,
    p_flex_where_tbl_type    IN  ASO_UTILITY_PVT.flex_where_tbl_type
);


PROCEDURE Get_Messages (p_message_count IN  NUMBER,
			x_msgs	 OUT NOCOPY /* file.sql.39 change */   VARCHAR2);

FUNCTION  Query_Header_Row (
    P_Qte_Header_Id		 IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.qte_header_rec_Type;

FUNCTION Query_Price_Adj_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Tbl_Type;

FUNCTION Query_Price_Adj_NonPRG_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Tbl_Type;

FUNCTION Query_Price_Adj_Attr_Rows (
    p_price_adj_tbl		IN  ASO_QUOTE_PUB.Price_Adj_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Attr_Tbl_Type;

FUNCTION Query_Payment_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Payment_Tbl_Type;

FUNCTION Query_Tax_Detail_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Shipment_Tbl		IN  ASO_QUOTE_PUB.Shipment_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Tax_Detail_Tbl_Type;

FUNCTION Query_Shipment_Row (
    P_Shipment_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Shipment_Rec_Type;

FUNCTION Query_Shipment_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Shipment_Tbl_Type;

FUNCTION Query_Line_Shipment_Row_atp (
       P_Qte_Header_Id      IN  NUMBER,
	  P_Qte_Line_Id        IN  NUMBER
    ) RETURN ASO_QUOTE_PUB.Shipment_Rec_Type;

FUNCTION Query_Freight_Charge_Rows (
    P_Shipment_Tbl		IN  ASO_QUOTE_PUB.Shipment_Tbl_Type
    ) RETURN ASO_QUOTE_PUB.Freight_Charge_Tbl_Type;

FUNCTION  Query_Sales_Credit_Row (
    P_Sales_Credit_Id		 IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.Sales_Credit_rec_Type;

FUNCTION  Query_Sales_Credit_Row (
    P_qte_header_Id		 IN   NUMBER,
    p_qte_line_id        IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.Sales_Credit_tbl_Type;
FUNCTION  Query_Quote_Party_Row (
    P_Qte_header_Id		 IN   NUMBER,
     p_qte_line_id        IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.QUOTE_PARTY_tbl_Type;
FUNCTION  Query_Quote_Party_Row (
    P_Quote_Party_Id		 IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.QUOTE_PARTY_rec_Type;

FUNCTION  Query_Qte_Line_Row (
    P_Qte_Line_Id		 IN   NUMBER
    ) RETURN ASO_QUOTE_PUB.qte_line_rec_Type;

FUNCTION Query_Qte_Line_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

FUNCTION Query_Qte_Line_Rows_Submit (
    P_Qte_Header_Id      IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

FUNCTION Query_Qte_Line_Rows_Sort (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

FUNCTION Query_Qte_Line_Rows_atp (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

FUNCTION Query_Pricing_Line_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_change_line_flag   IN  VARCHAR2 := FND_API.G_FALSE
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

FUNCTION Query_Pricing_Line_Row (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Tbl_Type;

FUNCTION Query_Line_Dtl_Rows (
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Qte_Line_Dtl_Tbl_Type;

FUNCTION Query_Line_Attribs_Ext_Rows(
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;

FUNCTION Query_Line_Attribs_header_Rows(
    P_Qte_header_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Line_Attribs_Ext_Tbl_Type;


FUNCTION Query_Price_Attr_Rows (
    P_Qte_Header_Id		IN  NUMBER := FND_API.G_MISS_NUM,
    P_Qte_Line_Id		IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Attributes_Tbl_Type;


FUNCTION Query_Price_Adj_Rltship_Rows (
    P_Price_Adjustment_Id	IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;


FUNCTION Query_Price_Adj_Rltn_Rows (
    P_Quote_Line_Id	          IN  NUMBER := FND_API.G_MISS_NUM
    ) RETURN ASO_QUOTE_PUB.Price_Adj_Rltship_Tbl_Type;


FUNCTION Get_Profile_Obsolete_Status (
    p_profile_name		IN  VARCHAR2,
    p_application_id	IN  NUMBER
    ) RETURN VARCHAR2;

FUNCTION  GET_Control_Rec  RETURN  ASO_QUOTE_PUB.Control_Rec_TYPE;
FUNCTION  GET_Qte_Header_Rec  RETURN  ASO_QUOTE_PUB.Qte_Header_Rec_TYPE;
FUNCTION  GET_Qte_Sort_Rec  RETURN  ASO_QUOTE_PUB.Qte_Sort_Rec_TYPE;
FUNCTION  GET_Qte_Line_Rec  RETURN  ASO_QUOTE_PUB.Qte_Line_Rec_TYPE;
FUNCTION  GET_Qte_Line_sort_Rec  RETURN  ASO_QUOTE_PUB.Qte_Line_sort_Rec_TYPE;
FUNCTION  GET_Qte_Line_Dtl_Rec  RETURN  ASO_QUOTE_PUB.Qte_Line_Dtl_Rec_TYPE;
FUNCTION  GET_Price_Attributes_Rec  RETURN  ASO_QUOTE_PUB.Price_Attributes_Rec_TYPE;
FUNCTION  GET_Price_Adj_Rec  RETURN  ASO_QUOTE_PUB.Price_Adj_Rec_TYPE;
FUNCTION  GET_PRICE_ADJ_ATTR_Rec  RETURN  ASO_QUOTE_PUB.PRICE_ADJ_ATTR_Rec_TYPE;
FUNCTION  GET_Price_Adj_Rltship_Rec  RETURN  ASO_QUOTE_PUB.Price_Adj_Rltship_Rec_TYPE;
FUNCTION  GET_Sales_Credit_Rec  RETURN  ASO_QUOTE_PUB.Sales_Credit_Rec_TYPE;
FUNCTION  GET_Payment_Rec  RETURN  ASO_QUOTE_PUB.Payment_Rec_TYPE;
FUNCTION  GET_Shipment_Rec  RETURN  ASO_QUOTE_PUB.Shipment_Rec_TYPE;
FUNCTION  GET_Freight_Charge_Rec  RETURN  ASO_QUOTE_PUB.Freight_Charge_Rec_TYPE;
FUNCTION  GET_Tax_Detail_Rec  RETURN  ASO_QUOTE_PUB.Tax_Detail_Rec_TYPE;
FUNCTION  GET_Tax_Control_Rec  RETURN  ASO_TAX_INT.Tax_control_rec_type ;
FUNCTION  GET_Header_Rltship_Rec  RETURN  ASO_QUOTE_PUB.Header_Rltship_Rec_TYPE;
FUNCTION  GET_Line_Rltship_Rec  RETURN  ASO_QUOTE_PUB.Line_Rltship_Rec_TYPE;
FUNCTION  GET_PARTY_RLTSHIP_Rec  RETURN  ASO_QUOTE_PUB.PARTY_RLTSHIP_Rec_TYPE;
FUNCTION  GET_Related_Object_Rec  RETURN  ASO_QUOTE_PUB.Related_Object_Rec_TYPE;
FUNCTION  GET_RELATED_OBJ_Rec      RETURN  ASO_QUOTE_PUB.RELATED_OBJ_Rec_TYPE;
FUNCTION  GET_Line_Attribs_Ext_Rec  RETURN ASO_QUOTE_PUB.Line_Attribs_Ext_Rec_TYPE;

FUNCTION  GET_Order_Header_Rec     RETURN  ASO_QUOTE_PUB.Order_Header_Rec_TYPE;
FUNCTION  GET_SUBMIT_CONTROL_REC	RETURN  ASO_QUOTE_PUB.Submit_Control_Rec_Type;
FUNCTION  GET_Sales_Alloc_Control_Rec	RETURN  ASO_QUOTE_PUB.Sales_Alloc_Control_Rec_Type;

FUNCTION  GET_Party_Rec		RETURN  ASO_PARTY_INT.Party_Rec_Type;
FUNCTION  GET_Location_Rec	RETURN  ASO_PARTY_INT.Location_Rec_Type;
FUNCTION  GET_Party_Site_Rec	RETURN  ASO_PARTY_INT.Party_Site_Rec_Type;
FUNCTION  GET_Org_Contact_Rec	RETURN  ASO_PARTY_INT.Org_Contact_Rec_Type;
FUNCTION  GET_Contact_Point_Rec		RETURN  ASO_PARTY_INT.Contact_Point_Rec_Type;
FUNCTION  GET_Out_Contact_Point_Rec	RETURN  ASO_PARTY_INT.Out_Contact_Point_Rec_Type;
FUNCTION  GET_Contact_Restriction_Rec	RETURN  ASO_PARTY_INT.Contact_Restrictions_Rec_Type;
 FUNCTION  GET_PRICING_CONTROL_REC		RETURN ASO_PRICING_INT.PRICING_CONTROL_REC_TYPE;
FUNCTION  GET_X_Order_Header_Rec 	     RETURN ASO_ORDER_INT.Order_Header_Rec_Type;
FUNCTION  GET_X_Order_Line_Rec  RETURN ASO_ORDER_INT.Order_Line_Rec_Type;
FUNCTION  GET_X_Control_Rec	  RETURN ASO_ORDER_INT.Control_Rec_Type;
FUNCTION GET_QTE_IN_REC         RETURN ASO_OPP_QTE_PUB.OPP_QTE_IN_REC_TYPE;
FUNCTION GET_QTE_OUT_REC        RETURN ASO_OPP_QTE_PUB.OPP_QTE_OUT_REC_TYPE;
FUNCTION GET_Qte_Access_Rec     RETURN ASO_SECURITY_INT.Qte_Access_Rec_Type;
FUNCTION GET_copy_qte_cntrl_Rec RETURN ASO_COPY_QUOTE_PUB.Copy_Quote_Control_Rec_Type;
FUNCTION GET_copy_qte_hdr_Rec   RETURN ASO_COPY_QUOTE_PUB.Copy_Quote_Header_Rec_Type;

FUNCTION  GET_Def_Control_Rec  RETURN  ASO_DEFAULTING_INT.Control_Rec_Type;
FUNCTION  GET_Header_Misc_Rec  RETURN  ASO_DEFAULTING_INT.Header_Misc_Rec_Type;
FUNCTION  GET_Line_Misc_Rec    RETURN  ASO_DEFAULTING_INT.Line_Misc_Rec_Type;
FUNCTION  GET_Attr_Codes_Tbl   RETURN  ASO_DEFAULTING_INT.ATTRIBUTE_CODES_TBL_TYPE;

FUNCTION Decode(l_base_date DATE, comp1 DATE, date1 DATE, date2 DATE)
	RETURN DATE;

-- Change START
-- Release 12 MOAC Changes : Bug 4500739
-- Changes Done by : Girish
-- Comments : The following functions are used for HR Extra Information Types

FUNCTION GET_DEFAULT_ORDER_TYPE RETURN VARCHAR2 ;
FUNCTION GET_DEFAULT_SALESREP RETURN VARCHAR2 ;
FUNCTION GET_DEFAULT_SALES_GROUP RETURN VARCHAR2 ;
FUNCTION GET_DEFAULT_SALES_ROLE RETURN VARCHAR2 ;
FUNCTION GET_DEFAULT_CONTRACT_TEMPLATE RETURN VARCHAR2 ;

FUNCTION get_ou_attribute_value(p_attribute IN VARCHAR2, p_organization_id IN NUMBER) RETURN VARCHAR2 ;
FUNCTION get_ou_attribute_value(p_attribute IN VARCHAR2) RETURN VARCHAR2;

-- Change END

-- Change START
-- Release 12
-- Changes Done by : Girish
-- Comments : Procedure to add entry in ASO_CHANGED_QUOTES

PROCEDURE UPDATE_CHANGED_QUOTES (p_quote_number	ASO_CHANGED_QUOTES.QUOTE_NUMBER%TYPE);

-- Change END

--Procedure added by Anoop Rajan on 30/09/2005 to print login details
PROCEDURE PRINT_LOGIN_INFO;

FUNCTION Tax_Rec_Exists( p_tax_rec IN ASO_QUOTE_PUB.Tax_Detail_Rec_Type ) RETURN BOOLEAN;

END ASO_UTILITY_PVT;


 

/
