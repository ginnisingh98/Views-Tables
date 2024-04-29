--------------------------------------------------------
--  DDL for Package AMS_LIST_SRC_MAPPING
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."AMS_LIST_SRC_MAPPING" AUTHID CURRENT_USER AS
/* $Header: amsvlsrs.pls 115.13 2002/11/12 23:41:08 jieli noship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'AMS_LIST_SRC_MAPPING ';

TYPE l_Tbl_Type IS TABLE OF varchar2(1000)
    INDEX BY BINARY_INTEGER;

PROCEDURE create_mapping(
   p_api_version           IN  NUMBER,
   p_init_msg_list         IN  VARCHAR2  := FND_API.g_false,
   p_commit                IN  VARCHAR2  := FND_API.g_false,
   p_validation_level      IN  NUMBER    := FND_API.g_valid_level_full,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_imp_list_header_id    in  NUMBER,
   p_source_name           in  varchar2,
   p_table_name            in  varchar2,
   p_list_src_fields       IN  l_Tbl_Type ,
   p_list_target_fields    IN  l_Tbl_Type ,
   px_src_type_id          in  OUT NOCOPY number
  --p_mapped_fields          in varchar2
);

END AMS_LIST_SRC_MAPPING ;

 

/
