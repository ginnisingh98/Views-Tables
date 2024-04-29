--------------------------------------------------------
--  DDL for Package IBE_PROD_RELATION_RULE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_PROD_RELATION_RULE_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVCRRS.pls 120.0.12010000.2 2013/02/12 21:43:56 ytian ship $ */

G_PKG_NAME        CONSTANT VARCHAR2(30) := 'IBE_Prod_Relation_Rule_PVT';
L_ORGANIZATION_ID CONSTANT NUMBER       := FND_PROFILE.Value_Specific('IBE_ITEM_VALIDATION_ORGANIZATION', NULL, NULL, 671);
L_USER_ID         CONSTANT NUMBER       := FND_GLOBAL.User_ID;

FUNCTION check_map_rule_exists(
    p_relation_code           IN VARCHAR2,
    p_origin_object_type        IN VARCHAR2,
    p_origin_object_id           IN NUMBER,
    p_dest_object_type       IN VARCHAR2,
    p_dest_object_id     IN NUMBER) RETURN BOOLEAN;

PROCEDURE Insert_SQL_Rule(
   p_api_version   IN  NUMBER                     ,
   p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit        IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status OUT NOCOPY VARCHAR2                   ,
   x_msg_count     OUT NOCOPY NUMBER                     ,
   x_msg_data      OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code IN  VARCHAR2                   ,
   p_sql_statement IN  VARCHAR2
);


PROCEDURE Insert_Mapping_Rules(
   p_api_version            IN  NUMBER                     ,
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status          OUT NOCOPY VARCHAR2                   ,
   x_msg_count              OUT NOCOPY NUMBER                     ,
   x_msg_data               OUT NOCOPY VARCHAR2                   ,
   p_rel_type_code          IN  VARCHAR2                   ,
   p_origin_object_type_tbl IN  JTF_Varchar2_Table_100     ,
   p_dest_object_type_tbl   IN  JTF_Varchar2_Table_100     ,
   p_origin_object_id_tbl   IN  JTF_Number_Table           ,
   p_dest_object_id_tbl     IN  JTF_Number_Table           ,
   p_preview                IN  VARCHAR2 := FND_API.G_FALSE
);


PROCEDURE Update_Rule(
   p_api_version   IN  NUMBER                     ,
   p_init_msg_list IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit        IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status OUT NOCOPY VARCHAR2                   ,
   x_msg_count     OUT NOCOPY NUMBER                     ,
   x_msg_data      OUT NOCOPY VARCHAR2                   ,
   p_rel_rule_id   IN  NUMBER                     ,
   p_obj_ver_num   IN  NUMBER                     ,
   p_sql_statement IN  VARCHAR2 := NULL
);


PROCEDURE Delete_Rules(
   p_api_version     IN  NUMBER                     ,
   p_init_msg_list   IN  VARCHAR2 := FND_API.G_FALSE,
   p_commit          IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status   OUT NOCOPY VARCHAR2                   ,
   x_msg_count       OUT NOCOPY NUMBER                     ,
   x_msg_data        OUT NOCOPY VARCHAR2                   ,
   p_rel_rule_id_tbl IN  JTF_Varchar2_Table_100     ,
   p_obj_ver_num_tbl IN  JTF_Varchar2_Table_100
);


FUNCTION Get_Rule_Type(p_origin_object_type IN VARCHAR2,
                       p_dest_object_type   IN VARCHAR2)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(Get_Rule_Type, WNDS);


FUNCTION Get_Display_Name(p_object_type IN VARCHAR2,
                          p_object_id   IN NUMBER)
RETURN VARCHAR2;

PRAGMA RESTRICT_REFERENCES(Get_Display_Name, WNDS, WNPS);


FUNCTION Is_SQL_Valid(p_sql_stmt IN VARCHAR2)
RETURN BOOLEAN;




END IBE_Prod_Relation_Rule_PVT;

/
