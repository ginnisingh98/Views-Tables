--------------------------------------------------------
--  DDL for Package CN_TABLE_MAPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_TABLE_MAPS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvtmaps.pls 120.4 2005/09/03 02:53:44 apink noship $ */

TYPE table_map_rec_type IS RECORD
  (
   TABLE_MAP_ID               NUMBER   := cn_api.G_MISS_NUM,
   MAPPING_TYPE               VARCHAR2(4) := cn_api.G_MISS_CHAR,
   SOURCE_TABLE_ID            NUMBER   := cn_api.G_MISS_NUM,
   DESTINATION_TABLE_ID       NUMBER   := cn_api.G_MISS_NUM,
   MODULE_ID                  NUMBER   := cn_api.G_MISS_NUM,
   LAST_UPDATE_DATE           DATE     := cn_api.G_MISS_DATE,
   LAST_UPDATED_BY            NUMBER   := cn_api.G_MISS_NUM,
   CREATION_DATE              DATE     := cn_api.G_MISS_DATE,
   CREATED_BY                 NUMBER   := cn_api.G_MISS_NUM,
   LAST_UPDATE_LOGIN          NUMBER   := cn_api.G_MISS_NUM,
   ORG_ID                     NUMBER   := cn_api.G_MISS_NUM,
   SOURCE_TBL_PKCOL_ID        NUMBER   := cn_api.G_MISS_NUM,
   DELETE_FLAG                VARCHAR2(1) := cn_api.G_MISS_CHAR,
   SOURCE_HDR_TBL_PKCOL_ID    NUMBER   := cn_api.G_MISS_NUM,
   SOURCE_TBL_HDR_FKCOL_ID    NUMBER   := cn_api.G_MISS_NUM,
   NOTIFY_WHERE               VARCHAR2(1900) := cn_api.G_MISS_CHAR,
   COLLECT_WHERE              VARCHAR2(1900) := cn_api.G_MISS_CHAR
  );



-- Start of comments
-- API name    : Create_Map
-- Type        : Private
-- Pre-reqs    : None
-- Function    : Procedure to create a new Table Map (Collections data Source)
--               and all of the objects that are associated with it.
-- Parameters  :
-- IN          :  p_api_version       NUMBER      Required
--                p_init_msg_list     VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_commit            VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_validation_level  NUMBER      Optional
--                  Default = FND_API.G_VALID_LEVEL_FULL
-- OUT         :  x_return_status     VARCHAR2(1)
--                x_msg_count         NUMBER
--                x_msg_data          VARCHAR2(2000)
-- IN          :  p_source_name       VARCHAR2    Required
--                - name of Data Source, e.g. 'Legacy'
-- IN OUT      :  p_table_map_rec     p_table_map_rec%ROWTYPE      Required
--                - details of Data Source. These attributes
--                  must be populated:
--                    Source_Table_Id, Destination_table_Id
--                    Mapping_Type
--
-- Version :  Current version   1.0
--            Previous version  1.0
--            Initial version   1.0
--
-- Notes :
--
-- End of comments


PROCEDURE Create_Map (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_source_name       IN  VARCHAR2 ,
   p_table_map_rec     IN OUT NOCOPY table_map_rec_type,
   x_event_id_out      OUT NOCOPY NUMBER);

-- Start of comments
-- API name    : Delete_Map
-- Type        : Private
-- Pre-reqs    : None
-- Function    : Procedure to delete Table Map (Collections data Source)
--               and all of the objects that are associated with it.
-- Parameters  :
-- IN          :  p_api_version       NUMBER      Required
--                p_init_msg_list     VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_commit            VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_validation_level  NUMBER      Optional
--                  Default = FND_API.G_VALID_LEVEL_FULL
-- OUT         :  x_return_status     VARCHAR2(1)
--                x_msg_count         NUMBER
--                x_msg_data          VARCHAR2(2000)
-- IN          :  p_table_map_id      NUMBER      Required
--
--
-- End of comments
PROCEDURE Delete_Map (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_table_map_id      IN NUMBER,
   p_org_id            IN NUMBER);

PROCEDURE Update_Map
     (
      p_api_version   	      IN      NUMBER,
      p_init_msg_list         IN      VARCHAR2 	:= FND_API.G_FALSE,
      p_commit                IN      VARCHAR2  := FND_API.G_FALSE,
      p_validation_level      IN      NUMBER 	:= FND_API.G_VALID_LEVEL_FULL,
      x_return_status         OUT NOCOPY     VARCHAR2,
      x_msg_count             OUT NOCOPY     NUMBER,
      x_msg_data              OUT NOCOPY     VARCHAR2,
      p_table_map_id              IN  NUMBER,
      p_mapping_type              IN  VARCHAR2,
      p_module_id                 IN  NUMBER,
      p_source_table_id           IN  NUMBER,
      p_source_tbl_pkcol_id       IN  NUMBER,
      p_destination_table_id      IN  NUMBER,
      p_source_hdr_tbl_pkcol_id   IN  NUMBER,
      p_source_tbl_hdr_fkcol_id   IN  NUMBER,
      p_notify_where              IN  VARCHAR2,
      p_collect_where             IN  VARCHAR2,
      p_delete_flag               IN  VARCHAR2,
      p_event_id                  IN  NUMBER,
      p_event_name                IN  VARCHAR2,
      p_object_version_number     IN OUT NOCOPY NUMBER,
      x_org_id                    IN  NUMBER
      );



-- Start of comments
-- API name    : Create_Table_Map_Object
-- Type        : Private
-- Pre-reqs    : None
-- Function    : Procedure to create a new Table Map Object. And example would be
--               a Parameter, for use in a Collections
--               Notification query. The parameter is created in CN_OBJECTS and
--               cross-referenced in CN_TABLE_MAP_OBJECTS
--              WARNING: only use this procedure to create a table map object that
--                       does not yet exist in CN_OBJECTS. If you are creating a
--                       table map object which references an existing object (for
--                       example an Extra Collection Table) then just use the
--                       cn_table_map_objects_pkg.insert_row procedure.
-- Parameters  :
-- IN          :  p_api_version       NUMBER      Required
--                p_init_msg_list     VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_commit            VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_validation_level  NUMBER      Optional
--                  Default = FND_API.G_VALID_LEVEL_FULL
-- OUT         :  x_return_status     VARCHAR2(1)
--                x_msg_count         NUMBER
--                x_msg_data          VARCHAR2(2000)
-- IN          :  p_table_map_id      NUMBER      Required
--                p_object_name       VARCHAR2    Required
--                - name of Object, e.g. 'p_param1'
--                p_object_value      VARCHAR2    Optional
--                - value of Object, e.g. 'my_value'
--                p_tm_object_type    VARCHAR2    Required
--                - object type, e.g. 'PARAM'
--                p_creation_date                 Required
--                p_created_by                    Required
-- OUT         :  p_table_map_object_id  OUT
--                p_object_id            OUT
--
-- End of comments
PROCEDURE Create_Table_Map_Object (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_table_map_id      IN  NUMBER,
   p_object_name       IN  VARCHAR2,
   p_object_value      IN  VARCHAR2 := NULL,
   p_tm_object_type    IN  VARCHAR2,
   p_creation_date     IN  DATE,
   p_created_by        IN  NUMBER,
   x_table_map_object_id  OUT NOCOPY  NUMBER,
   x_object_id            OUT NOCOPY  NUMBER,
   x_org_id            IN NUMBER);


-- Start of comments
-- API name    : Delete_Table_Map_Object
-- Type        : Private
-- Pre-reqs    : None
-- Function    : Procedure to delete a new Table Map Object.
--               The procedure will delete both the cross-reference in
--               CN_TABLE_MAP_OBJECTS and the object itself in CN_OBJECTS.
--              WARNING: Use this procedure for deleting objects like Notification
--                       Query Parameters. If you only want to delete the CN_TABLE_MAP_OBJECTS
--                       references to an object (for example an Extra Collection Table)
--                       then just use the cn_table_map_objects_pkg.delete_row procedure.
-- Parameters  :
-- IN          :  p_api_version       NUMBER      Required
--                p_init_msg_list     VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_commit            VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_validation_level  NUMBER      Optional
--                  Default = FND_API.G_VALID_LEVEL_FULL
-- OUT         :  x_return_status     VARCHAR2(1)
--                x_msg_count         NUMBER
--                x_msg_data          VARCHAR2(2000)
-- IN          :  p_table_map_object_id      NUMBER      Required
--
-- End of comments
PROCEDURE Delete_Table_Map_Object (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_table_map_object_id      IN  NUMBER,
   x_org_id IN NUMBER);


-- Start of comments
-- API name    : Get_SQL_Clauses
-- Type        : Private
-- Pre-reqs    : None
-- Function    : Procedure to derive the Notification and Collection
--               FROM and WHERE clauses for a data source, using the information
--               stored for that source in CN_TABLE_MAPS
-- Parameters  :
-- IN          :  p_api_version       IN NUMBER      Required
--                p_init_msg_list     IN VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_commit            IN VARCHAR2    Optional
--                  Default = FND_API.G_FALSE
--                p_validation_level  IN NUMBER      Optional
--                  Default = FND_API.G_VALID_LEVEL_FULL
-- OUT         :  x_return_status     OUT VARCHAR2(1)
--                x_msg_count         OUT NUMBER
--                x_msg_data          OUT VARCHAR2(2000)
-- IN          :  p_table_map_id      IN NUMBER      Required
-- OUT         :  x_notify_from       OUT VARCHAR2,
--                x_notify_where      OUT VARCHAR2,
--                x_collect_from      OUT VARCHAR2,
--                x_collect_where     OUT VARCHAR2);
--
-- End of comments
PROCEDURE Get_SQL_Clauses
(  p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN  NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status     OUT NOCOPY VARCHAR2,
   x_msg_count         OUT NOCOPY NUMBER,
   x_msg_data          OUT NOCOPY VARCHAR2,
   p_table_map_id      IN  NUMBER,
   x_notify_from       OUT NOCOPY VARCHAR2,
   x_notify_where      OUT NOCOPY VARCHAR2,
   x_collect_from      OUT NOCOPY VARCHAR2,
   x_collect_where     OUT NOCOPY VARCHAR2,
   p_org_id            IN  NUMBER);  -- Added For R12 MOAC


PROCEDURE Update_Table_Map_Objects
     (
      p_api_version   	            IN      NUMBER,
      p_init_msg_list               IN      VARCHAR2 	:= FND_API.G_FALSE,
      p_commit                      IN      VARCHAR2  := FND_API.G_FALSE,
      p_validation_level            IN  NUMBER 	:= FND_API.G_VALID_LEVEL_FULL,
      x_return_status               OUT NOCOPY     VARCHAR2,
      x_msg_count                   OUT NOCOPY     NUMBER,
      x_msg_data                    OUT NOCOPY     VARCHAR2,
      p_table_map_id                IN  NUMBER,
      p_delete_flag                 IN  VARCHAR2,
      p_object_name                 IN  VARCHAR2,
      p_object_id                   IN  NUMBER,
      p_object_value                IN  VARCHAR2,
      p_object_version_number       IN  OUT NOCOPY NUMBER,
      x_org_id                      IN  NUMBER);  -- Added For R12 MOAC

END cn_table_maps_pvt;


 

/
