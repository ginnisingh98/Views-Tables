--------------------------------------------------------
--  DDL for Package EAM_ASSET_ATTR_IMPORT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."EAM_ASSET_ATTR_IMPORT_PVT" AUTHID CURRENT_USER AS
/* $Header: EAMVAAIS.pls 115.4 2002/11/20 19:02:13 aan ship $*/


   -- Start of comments
   -- API name : import_asset_attribute_values
   -- Type     : Private
   -- Function :
   -- Pre-reqs : None.
   -- Parameters  :
   -- IN       p_api_version      IN NUMBER   Required
   --          p_init_msg_list    IN VARCHAR2 Optional  Default = FND_API.G_FALSE
   --          p_commit           IN VARCHAR2 Optional  Default = FND_API.G_FALSE
   --          p_validation_level IN NUMBER   Optional  Default = FND_API.G_VALID_LEVEL_FULL
   --
   --
   --          p_interface_header_id        IN      NUMBER Required,
   --          p_purge_option     IN VARCHAR2 Optional  Default = FND_API.G_FALSE
   --
   -- OUT      x_return_status   OUT   VARCHAR2(1)
   --          x_msg_count       OUT   NUMBER
   --          x_msg_data        OUT   VARCHAR2(2000)
   --
   --          x_sql_stmt        OUT     VARCHAR2



   -- Version  Initial version    1.0
   --
   -- Notes    : This API Build the dynamic SQL to CREATE / UPDATE extensible attribute values
   --            for an asset number.
   --
   -- End of comments


PROCEDURE import_asset_attr_values
    (
    p_api_version               IN      NUMBER,
    p_init_msg_list             IN      VARCHAR2 := fnd_api.g_false,
    p_commit                    IN      VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN      NUMBER   := fnd_api.g_valid_level_full,
    p_interface_header_id	IN	NUMBER,
    p_import_mode		IN	NUMBER,
    p_purge_option              IN      VARCHAR2 := fnd_api.g_false,
    x_return_status             OUT NOCOPY     VARCHAR2,
    x_msg_count                 OUT NOCOPY     NUMBER,
    x_msg_data                  OUT NOCOPY     VARCHAR2
    );


END EAM_ASSET_ATTR_IMPORT_PVT;

 

/
