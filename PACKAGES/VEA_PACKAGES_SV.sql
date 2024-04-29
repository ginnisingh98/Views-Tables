--------------------------------------------------------
--  DDL for Package VEA_PACKAGES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_PACKAGES_SV" AUTHID CURRENT_USER as
/* $Header: VEAVAPKS.pls 115.13 2004/07/27 00:06:05 rvishnuv ship $      */
--{
    /*========================  vea_packages_sv  =============================*/
    /*========================================================================
       PURPOSE:

       NOTES:                To run the script:

                             sql> start VEAVAPKS.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/
    --
    --
    g_package_id   NUMBER;
    g_tp_layer_id   NUMBER;
    --
    --
    PROCEDURE
      deleteUnreferencedPackages;
    --
    --
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
          p_tp_layer_id               IN     vea_tp_layers.tp_layer_id%TYPE,
          p_application_short_name    IN     vea_packages.application_short_name%TYPE,
	  x_package_count             OUT NOCOPY     NUMBER
        );
    --
    --
    PROCEDURE
      updateVersionNumber
        (
          p_api_version            IN	  NUMBER,
          p_init_msg_list	   IN	  VARCHAR2 := FND_API.G_FALSE,
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level	   IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status	   OUT NOCOPY 	  VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_package_id             IN     vea_packages.package_id%TYPE,
	  x_version_number         OUT NOCOPY     VARCHAR2,
	  p_user_name		   IN	  VARCHAR2
        );
    --
    --
    PROCEDURE
      updateVersionNumber
        (
          p_api_version            IN	  NUMBER,
          p_init_msg_list	   IN	  VARCHAR2 := FND_API.G_FALSE,
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level	   IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status	   OUT NOCOPY 	  VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_specification_filename IN     vea_packages.specification_filename%TYPE,
	  x_version_number         OUT NOCOPY     VARCHAR2,
	  p_user_name		   IN	  VARCHAR2
        );
    --
    --
    FUNCTION
      getId
        (
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_client_server_flag     IN     vea_packages.client_server_flag%TYPE,
          p_name                   IN     vea_packages.name%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE
        )
    RETURN NUMBER;
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
          x_id                     OUT NOCOPY     vea_packages.package_id%TYPE,
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_client_server_flag     IN     vea_packages.client_server_flag%TYPE,
          p_generate_flag          IN     vea_packages.generate_flag%TYPE,
          p_tpa_flag               IN     vea_packages.tpa_flag%TYPE,
          p_name                   IN     vea_packages.name%TYPE,
          p_specification_filename IN     vea_packages.specification_filename%TYPE,
          p_body_filename          IN     vea_packages.body_filename%TYPE,
          p_label                  IN     vea_packages.label%TYPE,
          p_version_number         IN     vea_packages.version_number%TYPE,
          p_description            IN     vea_packages.description%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_tp_layer_id            IN     vea_packages.tp_layer_id%TYPE,
          p_id                     IN     vea_packages.package_id%TYPE   := NULL
        );
    --
    --
    --
    --
--}
END VEA_PACKAGES_SV;

 

/
