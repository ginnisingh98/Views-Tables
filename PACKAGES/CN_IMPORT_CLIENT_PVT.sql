--------------------------------------------------------
--  DDL for Package CN_IMPORT_CLIENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_IMPORT_CLIENT_PVT" AUTHID CURRENT_USER AS
/*$Header: cnvimpcs.pls 115.3 2002/11/21 21:13:41 hlchen ship $*/

-- * ------------------------------------------------------------------+
--   Record Type Definition
-- * ------------------------------------------------------------------+

-- Start of comments
-- API Name       Insert_Data
-- Type           Private
-- Pre-reqs       None.
-- Function       Insert data into the table whose name is specified by the "p_table_name" parameter.
-- Parameters
--    IN          p_api_version            NUMBER               Required
--                p_init_msg_list          VARCHAR2             Optional
--                p_commit                 VARCHAR2             Optional
--                p_imp_header_id               IN    NUMBER,
--                p_import_type_code            IN    VARCHAR2,
--                p_table_name             VARCHAR2             Required
--                p_obj_version_num        NUMBER               Optional
--                p_col_names              char_data_set_type  Required
--                p_data                   char_data_set_type  Required
--                p_row_count              NUMBER               Required
--    OUT         x_return_status          VARCHAR2
--                x_msg_count              NUMBER
--                x_msg_data               VARCHAR2
-- Version        Current version: 1.0
--                Previous version: 1.0
--                Initial version: 1.0
-- End of comments
PROCEDURE Insert_Data (
   p_api_version                 IN    NUMBER,
   p_init_msg_list               IN    VARCHAR2 := FND_API.G_TRUE,
   p_commit                      IN    VARCHAR2 := FND_API.G_FALSE,
   p_imp_header_id               IN    NUMBER,
   p_import_type_code            IN    VARCHAR2,
   p_table_name                  IN    VARCHAR2,
   p_col_names                   IN    cn_import_pvt.char_data_set_type,
   p_data                        IN    cn_import_pvt.char_data_set_type,
   p_row_count                   IN    NUMBER,
   x_return_status               OUT NOCOPY   VARCHAR2,
   x_msg_count                   OUT NOCOPY   NUMBER,
   x_msg_data                    OUT NOCOPY   VARCHAR2
);
END CN_IMPORT_CLIENT_PVT;

 

/
