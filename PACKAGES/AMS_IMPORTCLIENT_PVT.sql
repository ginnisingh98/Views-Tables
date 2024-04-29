--------------------------------------------------------
--  DDL for Package AMS_IMPORTCLIENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_IMPORTCLIENT_PVT" AUTHID CURRENT_USER AS
/*$Header: amsvmics.pls 115.8 2003/05/15 22:34:25 huili ship $*/

--
-- Start of comments.
--
-- NAME
--   AMS_ImportClient_PVT
--
-- PURPOSE
--   The package provides APIs for importing data.
--
--   Procedures:
--   Insert_Import_Data
--   Insert_Generic_Data
--   Load_Lead_Data_To_Interface
--
-- NOTES
--
--
-- HISTORY
-- 04/10/2001   huili        Created
-- 04/26/2001   huili        Change nested table type using JTF table
-- 05/13/2001   huili        Added the "Insert_Lead_Data" module
--
-- End of comments.
--
--
-- Start type definition
--
--
-- Corresponding type def for the PL/SQL data type "JTF_VARCHAR2_TABLE_2000"
-- since Rosetta does not support nested tables.
--
TYPE char_data_set_type_w IS
  TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

--
-- Corresponding type def for the PL/SQL data type "JTF_NUMBER_TABLE"
-- since Rosetta does not support nested tables.
--
TYPE num_data_set_type_w IS
  TABLE OF NUMBER INDEX BY BINARY_INTEGER;

--
-- Types for bulk collect data from the "AMS_LEAD_MAPPING_V" into "as_import_interface" table
--
TYPE varchar2_2000_set_type IS
	TABLE OF VARCHAR2(2000) INDEX BY BINARY_INTEGER;

TYPE varchar2_4000_set_type IS
	TABLE OF VARCHAR2(4000) INDEX BY BINARY_INTEGER;

TYPE varchar2_150_set_type IS
	TABLE OF VARCHAR2(150) INDEX BY BINARY_INTEGER;


PROCEDURE Write_Message (
   x_return_status   OUT NOCOPY VARCHAR2,
   p_log_used_by_id  IN  VARCHAR2,
   p_msg_data        IN  VARCHAR2,
   p_msg_type         IN  VARCHAR2
);


-- Start of comments
-- API Name       Mark_Insert_Lead_Errors
-- Type           Private
-- Pre-reqs       None.
-- Function       Mark lead errors to the "ams_imp_source_lines"
--                table and insert errors into the
--                "ams_list_import_errors" table.
-- Parameters
--    IN
--                p_import_list_header_id  NUMBER               Required
--    OUT         x_return_status          VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Mark_Insert_Lead_Errors (
	p_import_list_header_id       IN    NUMBER,
	x_return_status               OUT NOCOPY   VARCHAR2
);

-- Start of comments
-- API Name       Load_Lead_Data_To_Interface
-- Type           Private
-- Pre-reqs       None.
-- Function       Load data from the "AMS_LEAD_MAPPING_V" to the "as_import_interface".
-- Parameters
--    IN
--                p_import_list_header_id  NUMBER               Required
--    OUT         x_return_status          VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Load_Lead_Data_To_Interface (
	p_import_list_header_id       IN    NUMBER,
	x_return_status               OUT NOCOPY   VARCHAR2
);


-- Start of comments
-- API Name       Insert_Lead_Data
-- Type           Private
-- Pre-reqs       None.
-- Function       Insert data into the "AMS_IMP_SOURCE_LINES" table.
-- Parameters
--    IN          p_api_version            NUMBER               Required
--                p_init_msg_list          VARCHAR2             Optional
--                                                              Default := FND_API.G_TRUE
--                p_commit                 VARCHAR2             Optional
--                p_import_list_header_id  NUMBER               Required
--                p_data                   char_data_set_type_w Required
--                p_row_count              NUMBER               Required
--    OUT         x_return_status          VARCHAR2
--                x_msg_count              NUMBER
--                x_msg_data               VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Insert_Lead_Data (
  p_api_version                 IN    NUMBER,
  p_init_msg_list               IN    VARCHAR2 := FND_API.G_TRUE,
  p_commit                      IN    VARCHAR2 := FND_API.G_TRUE,
  p_import_list_header_id       IN    NUMBER,
  p_data                        IN    char_data_set_type_w,
  p_error_rows                  IN    num_data_set_type_w,
  p_row_count                   IN    NUMBER,
  x_return_status               OUT NOCOPY   VARCHAR2,
  x_msg_count                   OUT NOCOPY   NUMBER,
  x_msg_data                    OUT NOCOPY   VARCHAR2
);



-- Start of comments
-- API Name       Insert_List_Data
-- Type           Private
-- Pre-reqs       None.
-- Function       Insert data into the "AMS_IMP_SOURCE_LINES" table.
-- Parameters
--    IN          p_api_version            NUMBER               Required
--                p_init_msg_list          VARCHAR2             Optional
--                                                                Default := FND_API.G_FALSE
--                p_commit                 VARCHAR2             Optional
--                p_import_list_header_id  NUMBER               Required
--                p_data                   char_data_set_type_w Required
--                p_row_count              NUMBER               Required
--    OUT         x_return_status          VARCHAR2
--                x_msg_count              NUMBER
--                x_msg_data               VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Insert_List_Data (
   p_api_version                 IN    NUMBER,
   p_init_msg_list               IN    VARCHAR2 := FND_API.G_TRUE,
   p_commit                      IN    VARCHAR2 := FND_API.G_TRUE,
   p_import_list_header_id       IN    NUMBER,
   p_data                        IN    char_data_set_type_w,
   p_row_count                   IN    NUMBER,
	p_error_rows                  IN    num_data_set_type_w,
   x_return_status               OUT NOCOPY   VARCHAR2,
   x_msg_count                   OUT NOCOPY   NUMBER,
   x_msg_data                    OUT NOCOPY   VARCHAR2
);


END AMS_ImportClient_PVT;

 

/
