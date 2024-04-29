--------------------------------------------------------
--  DDL for Package CN_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMPORT_PVT" AUTHID CURRENT_USER AS
-- $Header: cnvimps.pls 120.2 2005/08/07 23:03:56 vensrini noship $

-- * ------------------------------------------------------------------+
--   Record Type Definition
-- * ------------------------------------------------------------------+
-- Corresponding type def for the PL/SQL data type "JTF_VARCHAR2_TABLE_1000"
-- since Rosetta does not support nested tables.
TYPE CHAR_DATA_SET_TYPE IS
  TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

--
-- Corresponding type def for the PL/SQL data type "JTF_NUMBER_TABLE"
-- since Rosetta does not support nested tables.
--
TYPE NUM_DATA_SET_TYPE IS
  TABLE OF NUMBER INDEX BY BINARY_INTEGER;

-- Start of comments
--    API name        : Import_Data
--    Type            : Private.
--    Function        : Main program to call all the concurrent programs
--                      to transfer data from datafile to stage table then to
--                      destination table
--    Pre-reqs        : None.
--    Version :         Current version       1.0
-- End of comments

PROCEDURE Import_Data
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_header_id           IN    NUMBER,
   p_user_id                 IN    NUMBER,  -- setting the session context.
   p_resp_id                 IN    NUMBER,  -- setting the session context.
   p_app_id                  IN    NUMBER,  -- setting the session context.
   p_control_file            IN    VARCHAR2,
   x_request_id              OUT NOCOPY   NUMBER,
   p_org_id		     IN NUMBER
   );

-- Start of comments
--    API name        : Export_Data
--    Type            : Private.
--    Function        : Main program to call all the concurrent programs
--                      to transfer data from destination file to stage table
--    Pre-reqs        : None.
--    Version :         Current version       1.0
-- End of comments
PROCEDURE Export_Data
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_header_id           IN    NUMBER,
   p_user_id                 IN    NUMBER,  -- setting the session context.
   p_resp_id                 IN    NUMBER,  -- setting the session context.
   p_app_id                  IN    NUMBER,  -- setting the session context.
   x_request_id              OUT NOCOPY   NUMBER,
   p_org_id		     IN NUMBER
   );

-- Start of comments
--    API name        : Client_Stage_data
--    Type            : Private.
--    Function        : Main program to call CN_IMPORT_CLIENT_PVT
--                      to transfer data from datafile to stage table
--    Pre-reqs        : None.
--    Version :         Current version       1.0
-- End of comments

PROCEDURE Client_Stage_Data
 ( p_api_version             IN     NUMBER  ,
   p_init_msg_list           IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_commit                  IN     VARCHAR2 := FND_API.G_FALSE     ,
   p_validation_level        IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status           OUT NOCOPY    VARCHAR2 ,
   x_msg_count               OUT NOCOPY    NUMBER ,
   x_msg_data                OUT NOCOPY    VARCHAR2 ,
   p_imp_header_id           IN     NUMBER,
   p_data                    IN     CHAR_DATA_SET_TYPE,
   p_row_count               IN     NUMBER,
   p_map_obj_ver             IN     NUMBER,
   p_org_id		     IN NUMBER
   );

-- --------------------------------------------------------+
-- This program invokes sql*loader from concurrent program
-- to populate the data from the data file to the OIC application.
-- --------------------------------------------------------+
PROCEDURE Server_Stage_Data
  (errbuf                     OUT NOCOPY   VARCHAR2,
   retcode                    OUT NOCOPY   NUMBER,
   p_imp_header_id            IN    NUMBER,
   p_control_file             IN    VARCHAR2,
   p_org_id		     IN NUMBER
   );

-- --------------------------------------------------------+
-- This program invokes concurrent program base on import type
-- to populate the data from the staging table into destination table
-- --------------------------------------------------------+
PROCEDURE Load_Data
  (errbuf                     OUT NOCOPY   VARCHAR2,
   retcode                    OUT NOCOPY   NUMBER,
   p_imp_header_id            IN    NUMBER,
   p_org_id		     IN NUMBER
   );

-- --------------------------------------------------------+
--  update_imp_headers
--
--  This procedure will update cn_imp_headers status,processed_row
--  and failed_row
-- --------------------------------------------------------+
PROCEDURE update_imp_headers
  (p_imp_header_id IN NUMBER,
   p_status_code IN VARCHAR2,
   p_staged_row  IN NUMBER := NULL ,
   p_processed_row  IN NUMBER := NULL ,
   p_failed_row  IN NUMBER := NULL );

-- --------------------------------------------------------+
--  update_imp_lines
--
--  This procedure will update cn_imp_lines status and error code
-- --------------------------------------------------------+
PROCEDURE update_imp_lines
  (p_imp_line_id IN NUMBER,
   p_status_code IN VARCHAR2,
   p_error_code  IN VARCHAR2,
   p_error_msg IN VARCHAR2 := NULL);

-- --------------------------------------------------------+
--  build_error_rec
--
-- This procedure will generate the list of source column headers for error
--   reporting. It will also generate a SQL statement which will be used to
--   retrieve target column values
-- --------------------------------------------------------+
PROCEDURE build_error_rec
  (p_imp_header_id IN NUMBER,
   x_header_list OUT NOCOPY VARCHAR2,
   x_sql_stmt OUT NOCOPY VARCHAR2 );

-- --------------------------------------------------------+
--  write_error_rec
--
-- This procedure will write the list of source column headers to process log
--  also retrieve the value of corresponding target columns and write to log
-- --------------------------------------------------------+
PROCEDURE write_error_rec
  (p_imp_header_id IN NUMBER,
   p_imp_line_id IN NUMBER,
   p_header_list IN VARCHAR2,
   p_sql_stmt IN VARCHAR2 );

END CN_IMPORT_PVT;

 

/
