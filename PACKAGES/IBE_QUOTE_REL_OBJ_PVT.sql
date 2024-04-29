--------------------------------------------------------
--  DDL for Package IBE_QUOTE_REL_OBJ_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IBE_QUOTE_REL_OBJ_PVT" AUTHID CURRENT_USER AS
/* $Header: IBEVQROS.pls 115.1 2002/12/13 02:33:52 mannamra ship $ */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'IBE_Quote_Rel_Obj_Pvt';

PROCEDURE Create_Relationship(
   p_api_version            IN  NUMBER   := 1.0            ,
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status          OUT NOCOPY VARCHAR2                   ,
   x_msg_count              OUT NOCOPY NUMBER                     ,
   x_msg_data               OUT NOCOPY VARCHAR2                   ,
   p_quote_object_type_code IN  VARCHAR2                   ,
   p_quote_object_id        IN  NUMBER                     ,
   p_object_type_code       IN  VARCHAR2                   ,
   p_object_id              IN  NUMBER                     ,
   p_relationship_type_code IN  VARCHAR2                   ,
   p_one_to_one             IN  VARCHAR2                   ,
   p_for_all_versions       IN  VARCHAR2                   ,
   x_related_obj_id         OUT NOCOPY NUMBER
);


PROCEDURE Delete_Relationship(
   p_api_version            IN  NUMBER   := 1.0            ,
   p_init_msg_list          IN  VARCHAR2 := FND_API.G_TRUE ,
   p_commit                 IN  VARCHAR2 := FND_API.G_FALSE,
   x_return_status          OUT NOCOPY VARCHAR2                   ,
   x_msg_count              OUT NOCOPY NUMBER                     ,
   x_msg_data               OUT NOCOPY VARCHAR2                   ,
   p_quote_object_type_code IN  VARCHAR2                   ,
   p_quote_object_id        IN  NUMBER                     ,
   p_object_type_code       IN  VARCHAR2                   ,
   p_object_id              IN  NUMBER                     ,
   p_relationship_type_code IN  VARCHAR2                   ,
   p_for_all_versions       IN  VARCHAR2
);

END IBE_Quote_Rel_Obj_Pvt;

 

/
