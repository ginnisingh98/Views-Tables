--------------------------------------------------------
--  DDL for Package JTF_CTM_UTILITY_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_CTM_UTILITY_PVT" AUTHID CURRENT_USER AS
/* $Header: jtfvutls.pls 115.4 2000/04/24 19:29:48 pkm ship      $ */
-- Start of Comments
--
-- NAME
--   JTF_CTM_UTILITY_PVT
--
-- PURPOSE
--   This package is a private utility API for JTF Core Territory Management
--
--   Procedures:
--    translate_orderBy
--    get_messages
--    print
--    handle_exceptions
--
-- NOTES
--   This package is for private use only
--
--
-- HISTORY
--   08/16/99   JDOCHERT                Created
--   11/10/99   VNEDUNGA                Fixed problem with NUMBER
--                                      to VARCHAR2 convertion
--   04/19/00   VNEDUNGA                Adding get_message procedure
--
--
-- End of Comments


-- Intermediate validation levels

-- Perform item level validation only
G_VALID_LEVEL_ITEM CONSTANT NUMBER:= 90;

-- Perform record level(inter-field) validation only
G_VALID_LEVEL_RECORD CONSTANT NUMBER:= 80;

-- Perform inter-record level validation only
G_VALID_LEVEL_INTER_RECORD CONSTANT NUMBER:= 70;

-- Perform inter-entity level validation only
G_VALID_LEVEL_INTER_ENTITY CONSTANT NUMBER:= 60;


-- Global variables for package type

G_PVT  VARCHAR2(30) := '_PVT';
G_PUB  VARCHAR2(30) := '_PUB';

-- Global variable for others exception

G_EXC_OTHERS  VARCHAR2(30) := 'OTHERS';

-- The following global variables is used in validation procedures -> validation_mode
G_CREATE  VARCHAR2(30) := 'CREATE';
G_UPDATE  VARCHAR2(30) := 'UPDATE';

--     ***********************
--       Composite Types
--     ***********************

-- Start of Comments
--
--     Order by record: util_order_by_rec_type
--
--    parameters:
--
--    required:
--
--    defaults: None
--
--    Notes: 1.    col_choice is a two or three digit number.
--        First digit represents the priority for the order by column.
--        (If priority > 10, use 2 digits to represent it)
--        Second(or third) digit represents the descending or ascending order for the query
--        result. 1 for ascending and 0 for descending.
--           2.    col_name is the order by column name.
--
-- End of Comments

TYPE util_order_by_rec_type IS RECORD
    (
        col_choice      NUMBER          := FND_API.G_MISS_NUM,
        col_name        VARCHAR2(30)    := FND_API.G_MISS_CHAR
    );

TYPE util_order_by_tbl_type       IS TABLE OF     util_order_by_rec_type
                                        INDEX BY BINARY_INTEGER;

G_MISS_UTIL_ORDER_BY_REC              util_order_by_rec_type;

G_MISS_UTIL_ORDER_BY_TBL              util_order_by_tbl_type;

-- Start of Comments
--
--    utl_string_tbl:  This will be used to return a list of string
--                     values after input string in split
--
--    parameters:
--
--    required:
--
--    defaults: None
--
--    Notes:
--
-- End of Comments

TYPE util_string_Tbl_Type  IS TABLE OF  VARCHAR2(70)  INDEX BY BINARY_INTEGER;


TYPE util_View_Columns_Rec_type IS RECORD
    (
        Table_Name      VARCHAR2(70)          := FND_API.G_MISS_CHAR,
        Table_Alias     VARCHAR2(70)          := FND_API.G_MISS_CHAR,
        col_alias       VARCHAR2(70)          := FND_API.G_MISS_CHAR,
        col_name        VARCHAR2(70)          := FND_API.G_MISS_CHAR
    );

TYPE util_View_Columns_Tbl_type       IS TABLE OF util_View_Columns_Rec_type
                                         INDEX BY BINARY_INTEGER;


TYPE util_View_From_Rec_type IS RECORD
    (
        Table_Name      VARCHAR2(70)          := FND_API.G_MISS_CHAR,
        Table_Alias     VARCHAR2(70)          := FND_API.G_MISS_CHAR
    );

TYPE util_View_From_Tbl_type          IS TABLE OF util_View_From_Rec_type
                                         INDEX BY BINARY_INTEGER;

-- this function returns TRUE if the value of a foreign key is valid,
-- otherwise returns FALSE
FUNCTION fk_id_is_valid ( p_fk_value      IN NUMBER,
                          p_fk_col_name   IN VARCHAR2,
                          p_fk_table_name IN VARCHAR2 )
                        RETURN VARCHAR2;

-- this function returns TRUE if the lookup value of an item is valid,
-- otherwise returns FALSE
FUNCTION lookup_code_is_valid ( p_lookup_code        VARCHAR2,
                                p_lookup_type        VARCHAR2,
                                p_lookup_table_name  VARCHAR2)
                               RETURN VARCHAR2;



-- Start of Comments
--
--      API name        : translate_orderBy
--      Type            : Private
--      Function        : translate order by choice numbers and columns into
--              a order by string with the order of column names and
--              descending or ascending request.
--
--
--      Paramaeters     :
--      IN              :
--            p_api_version_number    IN      NUMBER,
--            p_init_msg_list         IN      VARCHAR2
--             p_validation_level     IN    NUMBER
--      OUT             :
--                      x_return_status         OUT     VARCHAR2(1)
--                      x_msg_count             OUT     NUMBER
--                      x_msg_data              OUT     VARCHAR2(2000)
--
--      Version :       Current version 1.0
--                              Initial Version
--                      Initial version         1.0
--
--
--
-- End of Comments

PROCEDURE Translate_OrderBy
( p_api_version        IN     NUMBER,
  p_init_msg_list      IN     VARCHAR2  := FND_API.G_FALSE,
  p_validation_level   IN     NUMBER    := FND_API.G_VALID_LEVEL_FULL,
  x_return_status      OUT    VARCHAR2,
  x_msg_count          OUT    NUMBER,
  x_msg_data           OUT    VARCHAR2,
  p_order_by_tbl       IN     util_order_by_tbl_type,
  x_order_by_clause    OUT    VARCHAR2 );


-- Start of Comments
--
--      API name        : Split
--      Type            : Private
--      Function        : Splits the incomming string as substrings based on
--                        the delimter
--
--
--      Paramaeters     :
--      IN              :
--            p_Input_String       IN     VARCHAR2
--            p_Delimiter          IN     VARCHAR2
--
--      OUT
--            x_return_status      OUT    VARCHAR2
--            x_String_Tbl         OUT    util_string_tbl_type
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--
--
-- End of Comments

PROCEDURE Split
( p_Input_String       IN     VARCHAR2,
  p_Delimiter          IN     VARCHAR2,
  x_return_status      OUT    VARCHAR2,
  x_String_Tbl         OUT    util_string_tbl_type);


-- Start of Comments
--
--      API name        : Format_View_Text
--      Type            : Private
--      Function        : Formats the view text as columns and tables
--
--
--      Paramaeters     :
--      IN              :
--            p_Input_String       IN     VARCHAR2
--
--      OUT
--            x_return_status      OUT    VARCHAR2
--            x_String_Tbl         OUT    util_string_tbl_type,
--            x_Where_Clause       OUT    VARCHAR2,
--            X_No_Of_Columns      OUT    NUMBER,
--            X_No_Of_Tables       OUT    NUMBER
--
--      Version :       Current version 1.0
--                      Initial version 1.0
--
--
--
-- End of Comments

PROCEDURE Format_View_Text
( p_View_Name          IN     VARCHAR2,
  x_return_status      OUT    VARCHAR2,
  x_view_Columns_Tbl   OUT    util_View_Columns_Tbl_type,
  x_view_From_Tbl      OUT    util_View_From_Tbl_type,
  X_Where_Clause       OUT    VARCHAR2,
  X_From_Clause        OUT    VARCHAR2,
  X_Select_Clause      OUT    VARCHAR2,
  X_No_Of_Columns      OUT    NUMBER,
  X_No_Of_Tables       OUT    NUMBER );

--
--      API name        : Get_Messages
--      Type            : Public
--      Function        : Get messages from message dictionary
--
--
--      Parameters      :
--      IN              :
--                        p_message_count IN      NUMBER,
--      OUT             :
--                        x_msgs          OUT     VARCHAR2
--
--      Version :         Current version 1.0
--                        Initial version 1.0
--
--
-- End of Comments
PROCEDURE Get_Messages(
    p_message_count     IN     NUMBER,
    x_msgs              OUT    VARCHAR2
);



END JTF_CTM_UTILITY_PVT;

 

/
