--------------------------------------------------------
--  DDL for Package VEA_RELEASE_DETAILS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_RELEASE_DETAILS_SV" AUTHID CURRENT_USER as
/* $Header: VEAVARDS.pls 115.8 2004/07/27 00:07:19 rvishnuv ship $      */
--{
    /*======================  vea_release_details_sv  =========================*/
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
    g_release_id                      vea_release_details.release_id%TYPE;
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
          p_layer_provider_code        IN     vea_release_details.layer_provider_code%TYPE,
          p_release_id                 IN     vea_release_details.release_id%TYPE,
          p_file_name                  IN     vea_release_details.file_name%TYPE,
          p_version_number             IN     vea_release_details.version_number%TYPE,
          p_application_short_name     IN     vea_release_details.application_short_name%TYPE,
          p_description                IN     vea_release_details.description%TYPE,
          p_aru_number                 IN     vea_release_details.aru_number%TYPE,
          p_bug_number                 IN     vea_release_details.bug_number%TYPE,
          p_tp_layer_id                IN     vea_release_details.tp_layer_id%TYPE,
          p_file_path                  IN     vea_release_details.file_path%TYPE
        );
    --
    --
    --
    --
--}
END VEA_RELEASE_DETAILS_SV;

 

/
