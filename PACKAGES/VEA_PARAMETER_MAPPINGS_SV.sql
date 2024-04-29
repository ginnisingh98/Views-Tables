--------------------------------------------------------
--  DDL for Package VEA_PARAMETER_MAPPINGS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_PARAMETER_MAPPINGS_SV" AUTHID CURRENT_USER as
/* $Header: VEAVAPMS.pls 115.7 2004/07/27 00:05:41 rvishnuv ship $      */
--{
    /*======================  vea_parameter_mappings_sv  =========================*/
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
      delete_rows
        (
          p_layer_provider_code         IN     vea_parameter_mappings.layer_provider_code%TYPE,
          p_layer_header_id             IN     vea_parameter_mappings.layer_header_id%TYPE
        );
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
          x_id                         OUT NOCOPY     vea_parameter_mappings.parameter_mapping_id%TYPE,
          p_layer_provider_code        IN     vea_parameter_mappings.layer_provider_code%TYPE,
          p_layer_header_id            IN     vea_parameter_mappings.layer_header_id%TYPE,
          p_tps_parameter_id           IN     vea_parameter_mappings.tps_parameter_id%TYPE,
          p_tps_parameter_lp_code      IN     vea_parameter_mappings.tps_parameter_lp_code%TYPE,
          p_program_unit_parameter_id  IN     vea_parameter_mappings.program_unit_parameter_id%TYPE,
          p_program_unit_param_lp_code IN     vea_parameter_mappings.program_unit_param_lp_code%TYPE,
          p_description                IN     vea_parameter_mappings.description%TYPE,
          p_id                         IN     vea_parameter_mappings.parameter_mapping_id%TYPE   := NULL,
          p_program_unit_parameter_name  IN    vea_parameters.name%TYPE DEFAULT NULL,
          p_tps_parameter_name           IN    vea_parameters.name%TYPE DEFAULT NULL
        );
    --
    --
    --
    --
--}
END VEA_PARAMETER_MAPPINGS_SV;

 

/
