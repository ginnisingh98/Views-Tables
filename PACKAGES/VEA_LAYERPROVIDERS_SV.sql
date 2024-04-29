--------------------------------------------------------
--  DDL for Package VEA_LAYERPROVIDERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_LAYERPROVIDERS_SV" AUTHID CURRENT_USER as
/* $Header: VEAVALPS.pls 115.4 2002/12/12 02:20:41 heali noship $      */
--{
    /*========================  vea_layerproviders_sv  =======================*/
    /*========================================================================
       PURPOSE:

       NOTES:                To run the script:

                             sql> start VEAVALPS.pls

       HISTORY
                             Created   MOHANA NARAYAN 06/05/2000 10:00 AM

    =========================================================================*/
    --
    --
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE DEFAULT NULL
        );
    --
    --
    PROCEDURE
      insert_row
        (
          p_layer_provider_id      IN     vea_layer_providers.layer_provider_id%TYPE,
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE,
          p_description            IN     vea_layer_providers.description%TYPE
        );
    --
    --
    PROCEDURE
      update_row
        (
          p_layer_provider_id    IN     vea_layer_providers.layer_provider_id%TYPE,
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE,
          p_description            IN     vea_layer_providers.description%TYPE
        );
    --
    --
    PROCEDURE
      validate
        (
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE
        );
    --
    --
    PROCEDURE
      validateUniqueCodes
        (
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE
        );
    --
    --
    FUNCTION
      getLayerProviderCode
        (
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE
        )  RETURN VARCHAR2;
    --
    --
    FUNCTION
      getLayerProviderName
        (
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE
        )  RETURN VARCHAR2;
    --
    --
    PROCEDURE
      process
        (
          p_api_version            IN	  NUMBER,
          p_init_msg_list	   IN	  VARCHAR2 := FND_API.G_FALSE,
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level	   IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status	   OUT NOCOPY 	  VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE,
          p_description            IN     vea_layer_providers.description%TYPE
        );
    --
    --
    --
    --
--}
END VEA_LAYERPROVIDERS_SV;

 

/
