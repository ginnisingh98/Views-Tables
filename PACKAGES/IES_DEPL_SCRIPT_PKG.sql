--------------------------------------------------------
--  DDL for Package IES_DEPL_SCRIPT_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IES_DEPL_SCRIPT_PKG" AUTHID CURRENT_USER AS
/* $Header: ieslkdss.pls 115.4 2003/03/25 19:20:51 appldev noship $ */
   procedure lock_deployed_script
   (
      p_api_version                    IN     NUMBER,
      p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
      p_commit                         IN     VARCHAR2        := FND_API.G_TRUE,
      p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
      p_dscript_id                     IN     NUMBER,
      x_return_status                  OUT NOCOPY     VARCHAR2,
      x_msg_count                      OUT NOCOPY     NUMBER,
      x_msg_data                       OUT NOCOPY     VARCHAR2
   ); /* deprecated */

   procedure lock_deployed_script
   (
      p_api_version                    IN     NUMBER,
      p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
      p_commit                         IN     VARCHAR2        := FND_API.G_TRUE,
      p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
      p_dscript_id                     IN     NUMBER,
      x_dscript_id                     OUT NOCOPY     NUMBER,
      x_return_status                  OUT NOCOPY     VARCHAR2,
      x_msg_count                      OUT NOCOPY     NUMBER,
      x_msg_data                       OUT NOCOPY     VARCHAR2
   );

   procedure lock_deployed_script
   (
      p_api_version                    IN     NUMBER,
      p_init_msg_list                  IN     VARCHAR2        := FND_API.G_FALSE,
      p_commit                         IN     VARCHAR2        := FND_API.G_TRUE,
      p_validation_level               IN     NUMBER          := FND_API.G_VALID_LEVEL_FULL,
      p_dscript_name                   IN     VARCHAR2,
      p_dscript_language               IN     VARCHAR2,
      x_dscript_id                     OUT NOCOPY     NUMBER,
      x_return_status                  OUT NOCOPY     VARCHAR2,
      x_msg_count                      OUT NOCOPY     NUMBER,
      x_msg_data                       OUT NOCOPY     VARCHAR2
   );


END ies_depl_script_pkg;

 

/
