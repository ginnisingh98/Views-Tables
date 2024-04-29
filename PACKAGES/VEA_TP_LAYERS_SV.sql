--------------------------------------------------------
--  DDL for Package VEA_TP_LAYERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_TP_LAYERS_SV" AUTHID CURRENT_USER as
/* $Header: VEAVATLS.pls 115.4 2004/07/27 00:06:51 rvishnuv ship $      */
--{
    /*======================  vea_tp_layers_sv  =========================*/
    /*========================================================================
       PURPOSE:

       NOTES:                To run the script:

                             sql> start VEAVATLS.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/
    --
    --
    --
    --
    g_tp_layer_id                   vea_tp_layers.tp_layer_id%TYPE;
    --
    --
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code       IN     vea_tp_layers.layer_provider_code%TYPE,
          p_tp_layer_id               IN     vea_tp_layers.tp_layer_id%TYPE,
          p_tp_layer_name             IN     vea_tp_layers.name%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE
        );
    --
    --
    PROCEDURE
      deleteUnlicensedLayers
        (
          p_layer_provider_code       IN     vea_tp_layers.layer_provider_code%TYPE
        );
    --
    --
    FUNCTION
      get_tp_layer_id
        (
          p_tp_layer_name               IN     vea_tp_layers.name%TYPE
        )
    RETURN vea_tp_layers.tp_layer_id%TYPE;
    --
    --
    /*========================================================================

       PROCEDURE NAME: getId

       PURPOSE: Returns TP Layer ID for the specifed TP Layer name

    ========================================================================*/
    FUNCTION
      getId
        (
          p_layer_provider_code         IN     vea_tp_layers.layer_provider_code%TYPE,
          p_tp_layer_name               IN     vea_tp_layers.name%TYPE
        )
    RETURN vea_tp_layers.tp_layer_id%TYPE;
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
          x_id                        OUT NOCOPY     vea_tp_layers.tp_layer_id%TYPE,
          p_layer_provider_code       IN     vea_tp_layers.layer_provider_code%TYPE,
          p_name                      IN     vea_tp_layers.name%TYPE,
          p_description               IN     vea_tp_layers.description%TYPE,
          p_active_flag               IN     vea_tp_layers.active_flag%TYPE,
          p_id                        IN     vea_tp_layers.tp_layer_id%TYPE   := NULL
        );
    --
    --
    --
    --
--}
END VEA_TP_LAYERS_SV;

 

/
