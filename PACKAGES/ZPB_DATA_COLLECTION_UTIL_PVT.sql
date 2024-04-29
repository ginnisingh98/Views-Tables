--------------------------------------------------------
--  DDL for Package ZPB_DATA_COLLECTION_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ZPB_DATA_COLLECTION_UTIL_PVT" AUTHID CURRENT_USER AS
/* $Header: ZPBVDCUS.pls 120.0.12010.2 2005/12/23 06:05:27 appldev noship $ */


   PROCEDURE DISTRIBUTE_TEMPLATE(IN_TEMPLATE_ID IN NUMBER,
                                 IN_FROM_USER_ID IN NUMBER,
                                 IN_TO_USER_ID IN NUMBER,
                                 IN_MOVE_DATA_FLAG IN VARCHAR2,
                                 IN_MOVE_TARGET_FLAG IN VARCHAR2,
                                 IN_STRUCT_OR_DATA IN VARCHAR2);

   PROCEDURE UPDATE_AW_DATA(IN_QDRS IN VARCHAR2);
   PROCEDURE COMMIT_AW_DATA;

   PROCEDURE get_dc_owners (p_object_id         IN  NUMBER,
                            p_user_id           IN  NUMBER,
                            p_query_type        IN  VARCHAR2,
                            p_api_version       IN  NUMBER,
                            p_init_msg_list     IN  VARCHAR2 := FND_API.G_FALSE,
                            p_commit            IN  VARCHAR2 := FND_API.G_FALSE,
                            p_validation_level  IN  NUMBER := FND_API.G_VALID_LEVEL_FULL,
                            x_owner_list        OUT NOCOPY CLOB,
                            x_return_status     OUT NOCOPY varchar2,
                            x_msg_count         OUT NOCOPY number,
                            x_msg_data          OUT NOCOPY varchar2);

END ZPB_DATA_COLLECTION_UTIL_PVT;


 

/
