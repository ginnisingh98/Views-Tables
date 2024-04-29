--------------------------------------------------------
--  DDL for Package EAM_ASSET_SEARCH_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_SEARCH_PVT" AUTHID CURRENT_USER as
/* $Header: EAMVASES.pls 115.5 2002/11/20 19:02:40 aan ship $ */


TYPE VARCHAR2_REC is record
(
    descr_flex_context_code         VARCHAR2(30),
    end_user_column_name            VARCHAR2(30),
    operator                        VARCHAR2(10),
    attribute_value                 VARCHAR2(150)
);
TYPE NUMBER_REC is record
(
    descr_flex_context_code         VARCHAR2(30),
    end_user_column_name            VARCHAR2(30),
    operator                        VARCHAR2(10),
    attribute_value                 NUMBER
);
TYPE DATE_REC is record
(
    descr_flex_context_code         VARCHAR2(30),
    end_user_column_name            VARCHAR2(30),
    operator                        VARCHAR2(10),
    attribute_value                 DATE
);

TYPE VARCHAR2_TBL_TYPE IS TABLE OF  VARCHAR2_REC
INDEX BY BINARY_INTEGER;

TYPE NUMBER_TBL_TYPE IS TABLE OF  NUMBER_REC
INDEX BY BINARY_INTEGER;

TYPE DATE_TBL_TYPE IS TABLE OF  DATE_REC
INDEX BY BINARY_INTEGER;

   -- Start of comments
   -- API name : BUILD_SEARCH_SQL
   -- Type     : Private
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version      IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2 Optional  Default = FND_API.G_FALSE
   --          p_commit           IN VARCHAR2 Optional  Default = FND_API.G_FALSE
   --          p_validation_level IN NUMBER   Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --
   --          p_application_id   IN NUMBER   Optional  Default = 401 (INV)
   --          p_descr_flexfield_name IN VARCHAR2 Opt   Default = 'MTL_EAM_ASSET_ATTR_VALUES'
   --          p_search_set_id    IN NUMBER
   --          p_where_clause     IN VARCHAR2
   --          p_purge_option     IN VARCHAR2 Optional  Default = FND_API.G_FALSE

   -- OUT      x_return_status   OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --
   --          x_sql_stmt        OUT     VARCHAR2



   -- Version  Initial version    1.0
   --
   -- Notes    : This API Build the dynamic SQL to retrieve the Asset Numbers based on
   --            extensible attributes criteria as identified by the search_set_id in
   --            mtl_eam_asset_search_temp table.
   --
   -- End of comments


PROCEDURE BUILD_SEARCH_SQL
    (
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN      NUMBER   := fnd_api.g_valid_level_full,
    p_application_id            IN      NUMBER   := 401,
    p_descr_flexfield_name      IN      VARCHAR2 := 'MTL_EAM_ASSET_ATTR_VALUES',
    p_search_set_id             IN      NUMBER,
    p_where_clause              IN      VARCHAR2 := NULL,
    p_purge_option              IN      VARCHAR2 := fnd_api.g_false,
    x_sql_stmt                  OUT NOCOPY     VARCHAR2,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
    );



   -- Start of comments
   -- API name :
   -- Type     : Private
   -- Function : GET_ATTRIBUTE_COLUMN_NAME
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN
   --          p_application_id         IN NUMBER   Optional  Default = 401 (INV)
   --          p_descr_flexfield_name   IN VARCHAR2 Opt   Default = 'MTL_EAM_ASSET_ATTR_VALUES'
   --          p_descr_flex_context_code IN VARCHAR2 Required
   --          p_end_user_column_name   IN VARCHAR2 Required
   --
   -- RETURNS  VARCHAR2

   --
   -- Notes    : This function returns the column name where a specific attribute value
   --            is stored in table MTL_EAM_ASSET_ATTR_VALUES based on flexfield metadata
   --
   -- End of comments

FUNCTION GET_ATTRIBUTE_COLUMN_NAME
    (
    p_application_id            IN      NUMBER   := 401,
    p_descr_flexfield_name      IN      VARCHAR2 := 'MTL_EAM_ASSET_ATTR_VALUES',
    p_descr_flex_context_code   IN      VARCHAR2,
    p_end_user_column_name      IN      VARCHAR2
    )
RETURN VARCHAR2;


END EAM_ASSET_SEARCH_PVT;


 

/
