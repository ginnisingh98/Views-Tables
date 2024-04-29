--------------------------------------------------------
--  DDL for Package JTF_PERZ_QUERY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JTF_PERZ_QUERY_PUB" AUTHID CURRENT_USER AS
/* $Header: jtfzppqs.pls 120.2 2005/11/02 04:48:16 skothe ship $ */
-- Start of Comments
-- NAME
--   Jtf_Perz_Query_Pub
--
-- PURPOSE
--   Public API for saving, retrieving and updating personalized queries.
-- NOTES
--   This is a pulicly accessible pacakge.  It should be used by all
--   sources for saving, retrieving and updating personalized queries
--       within the personalization framework.
-- HISTORY
--   04/18/2000   SMATTEGU      Created
--
---- End of Comments
-- *****************************************************************************

-- Start of Comments
--
--      QUERY_PARAMETER_REC_TYPE Rec
--
--      This record is used to set the field/parameter map associated with a query.
--  If one is setting a query parameter record, the columns PARAMETER_NAME,
--      PARAMETER_TYPE and PARAMETER_VALUE are required.
--
-- End of Comments

TYPE QUERY_PARAMETER_REC_TYPE           IS RECORD
(
        QUERY_PARAM_ID                NUMBER          := Fnd_Api.G_MISS_NUM,
        QUERY_ID                        NUMBER          := Fnd_Api.G_MISS_NUM,
        PARAMETER_NAME                VARCHAR2(60)        := Fnd_Api.G_MISS_CHAR,
        PARAMETER_TYPE                VARCHAR2(30)        := Fnd_Api.G_MISS_CHAR,
        PARAMETER_VALUE        VARCHAR2(300)        := Fnd_Api.G_MISS_CHAR,
        PARAMETER_CONDITION        VARCHAR2(10)        := Fnd_Api.G_MISS_CHAR,
     PARAMETER_SEQUENCE NUMBER          := Fnd_Api.G_MISS_NUM
);

-- Start of Comments
-- QUERY_PARAMETER_TBL Table: QUERY_PARAMETER_TBL_TYPE
-- End of Comments

TYPE QUERY_PARAMETER_TBL_TYPE           IS TABLE OF QUERY_PARAMETER_REC_TYPE
                                INDEX BY BINARY_INTEGER;

-- G_MISS definition for table
G_MISS_QUERY_PARAMETER_TBL              QUERY_PARAMETER_TBL_TYPE;

-- *****************************************************************************
-- Start of Comments
-- QUERY_OUT_REC_TYPE
-- This record defines the out record for a get performed on the database.
-- The table of results returned from a Get_Perz_Query(..) will be a table of this
-- record type.
--
-- End of Comments
TYPE QUERY_OUT_REC_TYPE         IS RECORD
(
        QUERY_ID                        NUMBER              := NULL,
        PROFILE_ID                NUMBER              := NULL,
        APPLICATION_ID                NUMBER              := NULL,
        QUERY_NAME                VARCHAR2(100)        := NULL,
        QUERY_TYPE                VARCHAR2(100)        := NULL,
        QUERY_DESCRIPTION        VARCHAR2(240)        := NULL,
        QUERY_DATA_SOURCE        VARCHAR2(2000)        := NULL
);

-- Start of Comments
--      QUERY_OUT_TBL Table: QUERY_OUT_REC_TYPE
-- End of Comments

TYPE QUERY_OUT_TBL_TYPE         IS TABLE OF QUERY_OUT_REC_TYPE
                                INDEX BY BINARY_INTEGER;
-- *****************************************************************************
-- Start of Comments
-- QUERY_ORDER_BY_REC_TYPE
-- This record defines the order-by record for a get performed on the database.
-- The record stored tha parameter the query will be ordered by, ascending or
-- descending and the sequence if there are a number of order by parameters.
-- End of Comments


TYPE QUERY_ORDER_BY_REC_TYPE            IS RECORD
(       QUERY_ORDER_BY_ID        NUMBER := NULL,
        QUERY_ID                        NUMBER              := NULL,
        PARAMETER_NAME                VARCHAR2(60)        := NULL,
        ACND_DCND_FLAG                VARCHAR2(1)            := NULL,
        PARAMETER_SEQUENCE        NUMBER                := NULL
);

-- Start of Comments
--      QUERY_ORDER_BY_TBL Table: QUERY_ORDER_BY_REC_TYPE
-- End of Comments
TYPE QUERY_ORDER_BY_TBL_TYPE            IS TABLE OF QUERY_ORDER_BY_REC_TYPE
                                INDEX BY BINARY_INTEGER;

-- G_MISS definition for table

G_MISS_QUERY_ORDER_BY_TBL               QUERY_ORDER_BY_TBL_TYPE;

-- *****************************************************************************
-- Start of Comments
--
-- QUERY_RAW_SQL_REC_TYPE
--
-- This record defines the record for storing a raw SQL query.
--
-- End of Comments


TYPE QUERY_RAW_SQL_REC_TYPE             IS RECORD
(
        QUERY_RAW_SQL_ID        NUMBER                := NULL,
        QUERY_ID                        NUMBER              := NULL,
        SELECT_STRING                VARCHAR2(200)        := NULL,
        FROM_STRING                VARCHAR2(200)        := NULL,
        WHERE_STRING                    VARCHAR2(200)        := NULL,
        ORDER_BY_STRING        VARCHAR2(200)        := NULL,
        GROUP_BY_STRING        VARCHAR2(200)        := NULL,
        HAVING_STRING                VARCHAR2(200)        := NULL
);

G_MISS_QUERY_RAW_SQL_REC        QUERY_RAW_SQL_REC_TYPE;
-- *****************************************************************************-- *****************************************************************************-- START API SPECIFICATIONS
--
-- Start of Comments
--
--      API name         : Save_Perz_Query
--      Type                : Public
--      Function        : Create or update if exists, a personalized query and associated
--                                  field map with values.
--      Paramaeters        :
--      IN        :
--      p_api_version_number        IN NUMBER        Required
--      p_init_msg_list                IN VARCHAR2        Optional
--      p_commit                        IN VARCHAR2        Optional
--      p_application_id        IN NUMBER        Required
--      p_profile_id        IN NUMBER        Optional
--      p_profile_name      IN VARCHAR2        Optional
--      p_profile_type      IN VARCHAR2        Optional
--      p_profile_attrib    IN PERZ_PROFILE_PUB.PROFILE_ATTRIB_TBL_TYPE Optional
--
--      p_query_id                IN NUMBER        Optional
--      p_query_name        IN VARCHAR2        Required
--      p_query_type        IN VARCHAR2        Required
--      p_query_desc             IN VARCHAR2        Optional
--      p_query_data_source IN VARCHAR2,
--      p_query_param_tbl        IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
--      p_query_order_by_tbl         IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
--      p_query_raw_sql_rec        IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE
--
--      OUT :
--      x_query_id                   OUT NUMBER
--      x_return_status        OUT VARCHAR2
--      x_msg_count                OUT NUMBER
--      x_msg_data                OUT VARCHAR2
--      Version        :Current version        1.0
--              Initial version 1.0
--
--      Notes:
--
--
-- *****************************************************************************
-- USAGE NOTES :
--      1. This API creates or updates query in the personalization framework.
--      Of the input parameters p_profile_id (or the name of the profile p_profile_name
--      and its attributes p_Profile_Attrib) is a required field. The other required
--      fields are p_application_id (the application id of the caller) and p_query_name
--      which is This field has to be unique for that profile id and application id, or
--      the API will return an error. This field also has to be made of characters
--      with no spaces (underscores allowed).
--      2. The p_query_desc is the description (free text) of query being saved.
--      3. p_query_data_cource defines the name of the type of execution mechanism
--      to use for that query (like VIEW, PACKAGE, WEB etc.)
--      4.The p_query_param_tbl is the table that holds the parameters and values
--      associated with a query. The PARAMETER_NAME field holds the name/tag
--      associated with a query. The PARAMETER_TYPE field holds the value for this
--      query parameter. The PARAMETER_TYPE is used to store the type of parameter_value
--      value being stored (for and type conversion purposes). For example, one
--      could have a record like : [CUSTOMER_ID, 20, NUMBER]. this essentially
--      says that the query has a parameter called CUSTOMER_ID with value 235.

--      5. The p_query_order_by_tbl will hold the order by sequence, parameter
--      order by direction (ACND_DCND_FLAG) details for a given query.
--      6. If the query to store is a select statement, then p_query_raw_sql_rec
--      will hold all the necessary details of the select statement.
--      7. The main out parameter for this API is x_return_status which returns
--      FND_API.G_RETURN_SUCCESS when the API completes successfully
--      FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--      FND_API.G_RETURN_ERROR when the API hits an error

-- *****************************************************************************

PROCEDURE Save_Perz_Query
(       p_api_version_number        IN NUMBER,
        p_init_msg_list                IN VARCHAR2         := Fnd_Api.G_FALSE,
        p_commit                                IN VARCHAR2        := Fnd_Api.G_FALSE,

        p_application_id                IN NUMBER,
        p_profile_id                IN NUMBER,
        p_profile_name              IN VARCHAR2,
        p_profile_type              IN VARCHAR2,
        p_Profile_Attrib            IN Jtf_Perz_Profile_Pub.PROFILE_ATTRIB_TBL_TYPE
                        := Jtf_Perz_Profile_Pub.G_MISS_PROFILE_ATTRIB_TBL,

        p_query_id                        IN NUMBER,
        p_query_name                 IN VARCHAR2,
        p_query_type                        IN VARCHAR2,
        p_query_desc                        IN VARCHAR2,
        p_query_data_source          IN VARCHAR2,

        p_query_param_tbl                IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
                        := Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
        p_query_order_by_tbl         IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
                        := Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
        p_query_raw_sql_rec         IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE
                        := Jtf_Perz_Query_Pub.G_MISS_QUERY_RAW_SQL_REC         ,

        x_query_id                           OUT NOCOPY /* file.sql.39 change */        NUMBER,
        x_return_status                OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
        x_msg_count                        OUT NOCOPY /* file.sql.39 change */        NUMBER,
        x_msg_data                        OUT NOCOPY /* file.sql.39 change */        VARCHAR2

);

-- *****************************************************************************
-- Start of Comments
--
--      API name         : Create_Perz_Query
--      Type                : Public
--      Function        : Create Query and associated field map with values
--
--      Paramaeters        :
--      IN                :
--      p_api_version_number        IN NUMBER         Required
--   p_init_msg_list            IN VARCHAR2        Optional
--      p_commit                                IN VARCHAR2        Optional
--
--      p_application_id                IN NUMBER                Required
--      p_profile_id                IN NUMBER                Optional
--      p_profile_name              IN VARCHAR2        Optional
--
--      p_query_id                IN NUMBER                 Optional
--      p_query_name         IN VARCHAR2                Required
--      p_query_type         IN VARCHAR2                Optional
--      p_query_desc                 IN VARCHAR2                Optional
--      p_query_data_source        IN VARCHAR2                Optional
--
--      p_query_param_tbl         IN JTF_PERZ_QUERY_PUB.QUERY_PARAMETER_TBL_TYPE
--                       := JTF_PERZ_QUERY_PUB.G_MISS_QUERY_PARAMETER_TBL,
--    p_query_order_by_tbl IN JTF_PERZ_QUERY_PUB.QUERY_ORDER_BY_TBL_TYPE
--                              := JTF_PERZ_QUERY_PUB.G_MISS_QUERY_ORDER_BY_TBL,
--    p_query_raw_sql_rec        IN JTF_PERZ_QUERY_PUB.QUERY_RAW_SQL_REC_TYPE
--

--      OUT :
--              x_query_id                   OUT NUMBER
--              x_return_status        OUT VARCHAR2
--              x_msg_count                OUT NUMBER
--              x_msg_data                OUT VARCHAR2
--
--
--      Version        :        Current version        1.0
--                       Initial version         1.0
--
--      Notes:


-- *****************************************************************************
--
-- USAGE NOTES :
--
--      1. This API creates a query in the personalization framework.
--      Of the input parameters p_profile_id (or the name of the profile p_profile_name)
--      is a required field. The other required fields are p_application_id (the
--      application id of the caller) and p_query_name which is This field has to be
--      unique for that profile id and application id, or the API will return an error.
--  This field also has to be made of characters with no spaces (underscores allowed).
--
--      2. The p_query_desc is the description (free text) of query being saved.
--
--      3. p_query_data_cource defines the name of the type of execution mechanism
--      to use for that query (like VIEW, PACKAGE, WEB etc.)
--
--      4.The p_query_param_tbl is the table that holds the parameters and values
--      associated with a query. The PARAMETER_NAME field holds the name/tag
--      associated with a query. The PARAMETER_TYPE field holds the value for this
--      query parameter. The PARAMETER_TYPE is used to store the type of parameter_value
--      value being stored (for and type conversion purposes). For example, one
--      could have a record like : [CUSTOMER_ID, 20, NUMBER]. this essentially
--      says that the query has a parameter called CUSTOMER_ID with value 235.
--
--      5. The p_query_order_by_tbl will hold the order by sequence, parameter
--      order by direction (ACND_DCND_FLAG) details for a given query.
--
--      6. If the query to store is a select statement, then p_query_raw_sql_rec
--      will hold all the necessary details of the select statement.
--
--      7. The API returns x_query_id the ID of the query that has been stored in the
--      framework.
--
--      8. The other out parameter for this API is x_return_status which returns
--      FND_API.G_RETURN_SUCCESS when the API completes successfully
--      FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--      FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************

PROCEDURE Create_Perz_Query
(       p_api_version_number        IN NUMBER,
        p_init_msg_list                IN VARCHAR2         := Fnd_Api.G_FALSE,
        p_commit                                IN VARCHAR2        := Fnd_Api.G_FALSE,

        p_application_id        IN NUMBER,
        p_profile_id                IN NUMBER,
        p_profile_name                IN VARCHAR2,

        p_query_id                IN NUMBER,
        p_query_name                IN VARCHAR2,
        p_query_type                IN VARCHAR2,
        p_query_desc                IN VARCHAR2,
        p_query_data_source        IN VARCHAR2,

        p_query_param_tbl        IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
                        := Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
        p_query_order_by_tbl         IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
                        := Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
        p_query_raw_sql_rec         IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE
                        := Jtf_Perz_Query_Pub.G_MISS_QUERY_RAW_SQL_REC         ,

        x_query_id          OUT NOCOPY /* file.sql.39 change */ NUMBER,
        x_return_status        OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
        x_msg_count                OUT NOCOPY /* file.sql.39 change */        NUMBER,
        x_msg_data                OUT NOCOPY /* file.sql.39 change */        VARCHAR2
);
-- *****************************************************************************

-- Start of Comments
--
--      API name         : Get_Perz_Query
--      Type                : Public
--      Function        : Get personalized query from query store
--
--      Paramaeters        :
--      IN        :
--      p_api_version_number        IN NUMBER         Required
--   p_init_msg_list            IN VARCHAR2        Optional
--
--      p_application_id                IN NUMBER        Required
--      p_profile_id                IN NUMBER        Optional
--      p_profile_name              IN VARCHAR2        Optional
--
--      p_query_id                        IN NUMBER        Optional
--      p_query_name                 IN VARCHAR2        Optional
--      p_query_type                 IN VARCHAR2        Optional

--      OUT :
--
--      x_query_id                OUT NUMBER,
--      x_query_name                OUT VARCHAR2,
--      x_query_type                OUT VARCHAR2,
--      x_query_desc                   OUT VARCHAR2,

--      x_query_param_tbl         OUT Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE,
--      x_query_order_by_tbl        OUT Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE,
--      x_query_raw_sql_rec        OUT Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE,

--      x_return_status                OUT VARCHAR2
--      x_msg_count                OUT NUMBER
--      x_msg_data                OUT VARCHAR2
--
--      Version        :Current version        1.0
--              Initial version         1.0
--
--      Notes:        Sending in IDs will greatly improve performance.
--
-- *****************************************************************************
--
-- USAGE NOTES :
--
--      1. This API gets/queries a personalized query from the personalization framework.
--      Of the input parameters p_profile_id (or the name of the profile p_profile_name)
--      the application id (p_application_id) and the name of the query p_query_name are
--      required fields. Sending in the queryid (p_query_id) will improve performance.
--
--      2. The x_query_param_tbl holds the output set from the query parameters.
--
--      3. The x_query_order_by_tbl holds the output set from Order by details for
--      the query
--
--      4. The x_query_raw_sql_rec will hold the output set from select query details
--      for the query
--
--      5. query_id, description and query_data_source are also returned.
--
--      6. The other out parameters for this API is x_return_status which returns
--      FND_API.G_RETURN_SUCCESS when the API completes successfully
--      FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--      FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************
PROCEDURE Get_Perz_Query
(       p_api_version_number        IN NUMBER,
        p_init_msg_list                IN VARCHAR2         := Fnd_Api.G_FALSE,

        p_application_id        IN NUMBER,
        p_profile_id           IN NUMBER,
        p_profile_name         IN VARCHAR2,

        p_query_id             IN NUMBER,
        p_query_name           IN VARCHAR2,
        p_query_type         IN VARCHAR2,

        x_query_id             OUT NOCOPY /* file.sql.39 change */ NUMBER,
        x_query_name           OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
        x_query_type                OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
        x_query_desc                   OUT NOCOPY /* file.sql.39 change */ VARCHAR2,
        x_query_data_source    OUT NOCOPY /* file.sql.39 change */ VARCHAR2,

        x_query_param_tbl        OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE,
    x_query_order_by_tbl   OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE,
    x_query_raw_sql_rec    OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE,

        x_return_status                OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
        x_msg_count                OUT NOCOPY /* file.sql.39 change */        NUMBER,
        x_msg_data                OUT NOCOPY /* file.sql.39 change */        VARCHAR2
);
-- *****************************************************************************
--      API name         : Get_Perz_Query_Summary
--      Type                : Public
--      Function        : Get Only query header(s) from query store
--      Paramaeters        :
--      IN                :
--      p_api_version_number        IN NUMBER                 Required
--      p_init_msg_list                IN VARCHAR2                Optional
--
--      p_application_id        IN NUMBER                Required
--      p_profile_id        IN NUMBER                Optional
--      p_profile_name      IN VARCHAR2                Optional

--      p_query_id                IN NUMBER                Optional
--      p_query_name        IN VARCHAR2                Optional
--      p_query_type        IN VARCHAR2                Optional
--      OUT :
--      x_query_out_tbl        OUT         Jtf_Perz_Query_Pub.QUERY_OUT_TBL_TYPE
--      x_return_status        OUT         VARCHAR2
--      x_msg_count                OUT        NUMBER
--      x_msg_data                OUT       VARCHAR2

--      Version        :        Current version        1.0
--                               Initial version         1.0

--      Notes:        Sending in IDs will greatly improve performance.
-- *****************************************************************************
--
-- USAGE NOTES :
--
--      1. This API gets/queries query headers/summaries from the personalization framework.
--      Of the input parameters p_profile_id (or the name of the profile p_profile_name)
--      the application id (p_application_id) and the name of the query p_query_name are
--      required fields. Sending in the queryid (p_query_id) will improve performance.
--
--      2. The x_query_out_tbl holds the output set from the query headers.
--
--      3. The other out parameters for this API is x_return_status which returns
--      FND_API.G_RETURN_SUCCESS when the API completes successfully
--      FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--      FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************
PROCEDURE Get_Perz_Query_Summary
(       p_api_version_number   IN NUMBER,
        p_init_msg_list                IN VARCHAR2         := Fnd_Api.G_FALSE,

        p_application_id        IN NUMBER,
        p_profile_id           IN NUMBER,
        p_profile_name         IN VARCHAR2,

        p_query_id             IN NUMBER,
        p_query_name           IN VARCHAR2,
        p_query_type         IN VARCHAR2,

    x_query_out_tbl        OUT NOCOPY /* file.sql.39 change */ Jtf_Perz_Query_Pub.QUERY_OUT_TBL_TYPE,

        x_return_status        OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
        x_msg_count                OUT NOCOPY /* file.sql.39 change */        NUMBER,
        x_msg_data                OUT NOCOPY /* file.sql.39 change */        VARCHAR2
);
-- *****************************************************************************-- Start of Comments
--
--      API name         : Update_Perz_Query
--      Type                : Public
--      Function        : Updates the personalized query header and associated field-map
--                                for a given query and profile.
--
--      Paramaeters        :
--      IN                :
--              p_api_version_number        IN NUMBER        Required
--              p_init_msg_list                IN VARCHAR2        Optional
--              p_commit                IN VARCHAR2        Optional
--
--              p_application_id        IN NUMBER        Required
--              p_profile_id                IN NUMBER        Required
--
--              p_query_id                   IN NUMBER        Optional
--              p_query_name                 IN VARCHAR2        Required
--              p_query_type         IN VARCHAR2                Optional
--              p_query_desc                IN VARCHAR2        Optional
--              p_query_data_source        IN VARCHAR2        Optional
--
--      p_query_param_tbl         IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
--                               := Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
--    p_query_order_by_tbl IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
--                              := Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
--    p_query_raw_sql_rec        IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE
--
--      OUT          :
--              x_query_id                   OUT         NUMBER
--              x_return_status                OUT         VARCHAR2
--              x_msg_count                OUT         NUMBER
--              x_msg_data                OUT       VARCHAR2
--
--      Version        :Current version        1.0
--              Initial version         1.0
--
--      Notes:
-- *****************************************************************************
--
-- USAGE NOTES :
--
--      1. This API updates query in the personalization framework.
--      Of the input parameters p_profile_id (or the name of the profile p_profile_name
--      and its attributes p_Profile_Attrib) is a required field. The other required
--      fields are p_application_id (the application id of the caller) and p_query_name
--      which is This field has to be unique for that profile id and application id, or
--      the API will return an error. This field also has to be made of characters
--      with no spaces (underscores allowed).
--
--      2. The p_query_desc is the description (free text) of query being saved.
--
--      3. p_query_data_cource defines the name of the type of execution mechanism
--      to use for that query (like VIEW, PACKAGE, WEB etc.)
--
--      4.The p_query_param_tbl is the table that holds the parameters and values
--      associated with a query. The PARAMETER_NAME field holds the name/tag
--      associated with a query. The PARAMETER_TYPE field holds the value for this
--      query parameter. The PARAMETER_TYPE is used to store the type of parameter_value
--      value being stored (for and type conversion purposes). For example, one
--      could have a record like : [CUSTOMER_ID, 20, NUMBER]. this essentially
--      says that the query has a parameter called CUSTOMER_ID with value 235.
--
--      5. The p_query_order_by_tbl will hold the order by sequence, parameter
--      order by direction (ACND_DCND_FLAG) details for a given query.
--
--      6. If the query to store is a select statement, then p_query_raw_sql_rec
--      will hold all the necessary details of the select statement.
--
--      7. The main out parameter for this API is x_return_status which returns
--      FND_API.G_RETURN_SUCCESS when the API completes successfully
--      FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--      FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************
PROCEDURE Update_Perz_Query
(       p_api_version_number        IN        NUMBER,
        p_init_msg_list                IN        VARCHAR2         := Fnd_Api.G_FALSE,
        p_commit                IN VARCHAR2                := Fnd_Api.G_FALSE,

        p_application_id        IN NUMBER,
        p_profile_id        IN NUMBER,

        p_query_id           IN NUMBER,
        p_query_name         IN VARCHAR2,
        p_query_type         IN VARCHAR2,
        p_query_desc                 IN VARCHAR2,
        p_query_data_source  IN VARCHAR2,

        p_query_param_tbl         IN Jtf_Perz_Query_Pub.QUERY_PARAMETER_TBL_TYPE
                                 := Jtf_Perz_Query_Pub.G_MISS_QUERY_PARAMETER_TBL,
    p_query_order_by_tbl IN Jtf_Perz_Query_Pub.QUERY_ORDER_BY_TBL_TYPE
                                := Jtf_Perz_Query_Pub.G_MISS_QUERY_ORDER_BY_TBL,
    p_query_raw_sql_rec  IN Jtf_Perz_Query_Pub.QUERY_RAW_SQL_REC_TYPE
                                := Jtf_Perz_Query_Pub.G_MISS_QUERY_RAW_SQL_REC         ,

        x_query_id          OUT NOCOPY /* file.sql.39 change */ NUMBER,
        x_return_status        OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
        x_msg_count                OUT NOCOPY /* file.sql.39 change */        NUMBER,
        x_msg_data                OUT NOCOPY /* file.sql.39 change */        VARCHAR2
);
-- *****************************************************************************-- Start of Comments
--
--      API name         : Delete_Perz_Query
--      Type                : Public
--      Function        : Deletes a personalized query in the personalization framework.
--
--      Paramaeters        :
--      IN        :
--              p_api_version_number        IN NUMBER        Required
--              p_init_msg_list                        IN VARCHAR2        Optional
--              p_commit                                IN VARCHAR2        Optional
--
--              p_application_id        IN NUMBER                Required
--              p_profile_id        IN NUMBER                Required
--              p_query_id           IN NUMBER                Required
--
--      OUT :
--              x_return_status                OUT      VARCHAR2
--              x_msg_count                OUT        NUMBER
--              x_msg_data                OUT        VARCHAR2
--
--      Version        :Current version        1.0
--              Initial version 1.0
--
--      Notes:
-- *****************************************************************************
--
-- USAGE NOTES :
--
--      1. This API deletes a personalized query from the personalization framework.
--      Of the input parameters p_profile_id (or the name of the profile p_profile_name)
--      the application id (p_application_id) and the query id p_query_id are
--      required fields.
--
--      2. The out parameter for this API is x_return_status which returns
--      FND_API.G_RETURN_SUCCESS when the API completes successfully
--      FND_API.G_RETURN_UNEXPECTED when the API reaches a unxpected state
--      FND_API.G_RETURN_ERROR when the API hits an error
--
-- *****************************************************************************
PROCEDURE Delete_Perz_Query
(       p_api_version_number        IN        NUMBER,
        p_init_msg_list                IN        VARCHAR2         := Fnd_Api.G_FALSE,
        p_commit                IN VARCHAR2                := Fnd_Api.G_FALSE,

        p_application_id        IN NUMBER,
        p_profile_id        IN NUMBER,
        p_query_id            IN NUMBER,

        x_return_status                OUT NOCOPY /* file.sql.39 change */        VARCHAR2,
        x_msg_count                OUT NOCOPY /* file.sql.39 change */        NUMBER,
        x_msg_data                OUT NOCOPY /* file.sql.39 change */        VARCHAR2
);

-- *****************************************************************************
-- *****************************************************************************
END  Jtf_Perz_Query_Pub;

 

/
