--------------------------------------------------------
--  DDL for Package VEA_VERSIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_VERSIONS_SV" AUTHID CURRENT_USER as
/* $Header: VEAVAVRS.pls 115.2 2002/12/12 17:47:55 heali noship $      */
--{
    /*======================  vea_versions_sv  =========================*/
    /*========================================================================
       PURPOSE:

       NOTES:                To run the script:

                             sql> start VEAVALHS.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/
    --
    --
    --
    --
    PROCEDURE
      process
        (
          p_api_version                IN     NUMBER,
          p_init_msg_list              IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                     IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level           IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status              OUT NOCOPY     VARCHAR2,
          x_msg_count                  OUT NOCOPY     NUMBER,
          x_msg_data                   OUT NOCOPY     VARCHAR2,
          p_release_id                 IN     vea_versions.release_id%TYPE,
          p_version_id                 IN     vea_versions.version_id%TYPE,
          p_layer_provider_code        IN     vea_versions.layer_provider_code%TYPE,
          p_version_number             IN     vea_versions.version_number%TYPE,
          p_description                IN     vea_versions.description%TYPE
        );
    --
    --
    --
    --
--}
END VEA_VERSIONS_SV;

 

/
