--------------------------------------------------------
--  DDL for Package CN_COLUMN_MAPS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CN_COLUMN_MAPS_PVT" AUTHID CURRENT_USER AS
/* $Header: cnvcmaps.pls 120.3 2005/09/13 09:31:33 apink noship $ */

PROCEDURE insert_row
  (
   p_api_version            IN NUMBER,
   p_init_msg_list          IN VARCHAR2 := FND_API.G_FALSE,
   p_commit                 IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level       IN NUMBER   := FND_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_destination_column_id  IN NUMBER,
   p_table_map_id           IN NUMBER,
   p_expression             IN VARCHAR2,
   p_editable               IN VARCHAR2,
   p_modified               IN VARCHAR2,
   p_update_clause          IN VARCHAR2,
   p_calc_ext_table_id      IN NUMBER,
   p_org_id                 IN NUMBER,
   x_col_map_id          IN OUT NOCOPY NUMBER);


PROCEDURE update_row
  (
   p_api_version   	    IN NUMBER,
   p_init_msg_list          IN VARCHAR2  := FND_API.G_FALSE,
   p_commit                 IN VARCHAR2  := FND_API.G_FALSE,
   p_validation_level       IN NUMBER    := FND_API.G_VALID_LEVEL_FULL,
   x_return_status         OUT NOCOPY VARCHAR2,
   x_msg_count             OUT NOCOPY NUMBER,
   x_msg_data              OUT NOCOPY VARCHAR2,
   p_column_map_id          IN NUMBER,
   p_destination_column_id  IN NUMBER,
   p_table_map_id           IN NUMBER,
   p_expression             IN VARCHAR2,
   p_editable               IN VARCHAR2,
   p_modified               IN VARCHAR2,
   p_update_clause          IN VARCHAR2,
   p_calc_ext_table_id      IN NUMBER,
   p_object_version_number  IN OUT NOCOPY NUMBER,
   p_org_id                 IN NUMBER);

PROCEDURE delete_row
  (
   p_api_version       IN NUMBER,
   p_init_msg_list     IN VARCHAR2 := FND_API.G_FALSE,
   p_commit            IN VARCHAR2 := FND_API.G_FALSE,
   p_validation_level  IN NUMBER  := FND_API.G_VALID_LEVEL_FULL,
   x_return_status    OUT NOCOPY VARCHAR2,
   x_msg_count        OUT NOCOPY NUMBER,
   x_msg_data         OUT NOCOPY VARCHAR2,
   p_column_map_id     IN NUMBER,
   p_org_id            IN NUMBER);


END cn_column_maps_pvt;
 

/
