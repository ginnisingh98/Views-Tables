--------------------------------------------------------
--  DDL for Package VEA_LAYER_HEADERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_LAYER_HEADERS_SV" AUTHID CURRENT_USER as
/* $Header: VEAVALHS.pls 115.8 2004/07/27 00:07:48 rvishnuv ship $      */
--{
    /*======================  vea_layer_headers_sv  =========================*/
    /*========================================================================
       PURPOSE:

       NOTES:                To run the script:

                             sql> start VEAVALHS.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/
    --
    --
    g_program_unit_id NUMBER;
    g_tpa_program_unit_id NUMBER;
    g_tps_program_unit_id NUMBER;
    g_tps_program_unit_lp_code vea_layer_headers.layer_provider_code%TYPE;
    g_layer_header_id NUMBER;
    --
    --
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
          p_tp_layer_id               IN     vea_tp_layers.tp_layer_id%TYPE,
          p_application_short_name    IN     vea_packages.application_short_name%TYPE,
	  x_layer_header_count        OUT NOCOPY     NUMBER
        );
    --
    --
    PROCEDURE
      process
        (
          p_api_version               IN     NUMBER,
          p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                    IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level          IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status             OUT NOCOPY     VARCHAR2,
          x_msg_count                 OUT NOCOPY     NUMBER,
          x_msg_data                  OUT NOCOPY     VARCHAR2,
          x_id                        OUT NOCOPY     vea_layer_headers.layer_header_id%TYPE,
          p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
          p_program_unit_id           IN     vea_layer_headers.program_unit_id%TYPE,
          p_program_unit_lp_code      IN     vea_layer_headers.program_unit_lp_code%TYPE,
          p_tps_program_unit_id       IN     vea_layer_headers.tps_program_unit_id%TYPE,
          p_tps_program_unit_lp_code  IN     vea_layer_headers.tps_program_unit_lp_code%TYPE,
          p_condition_type            IN     vea_layer_headers.condition_type%TYPE,
          p_description               IN     vea_layer_headers.description%TYPE,
          p_id                        IN     vea_layer_headers.layer_header_id%TYPE   := NULL,
          p_package_name              IN     vea_packages.name%TYPE DEFAULT NULL,
          p_pkg_app_name              IN     vea_packages.application_short_name%TYPE DEFAULT NULL,
          p_pkg_cs_flag               IN     vea_packages.client_server_flag%TYPE DEFAULT NULL,
          p_program_unit_name         IN     vea_program_units.name%TYPE DEFAULT NULL,
          p_tps_package_name          IN     vea_packages.name%TYPE DEFAULT NULL,
          p_tps_program_unit_name     IN     vea_program_units.name%TYPE DEFAULT NULL,
          p_tpsPkg_app_name           IN     vea_packages.application_short_name%TYPE DEFAULT NULL,
          p_tpsPkg_cs_flag            IN     vea_packages.client_server_flag%TYPE DEFAULT NULL
        );
    --
    --
    --
    --
--}
END VEA_LAYER_HEADERS_SV;

 

/
