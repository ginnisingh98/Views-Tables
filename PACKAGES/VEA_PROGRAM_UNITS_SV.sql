--------------------------------------------------------
--  DDL for Package VEA_PROGRAM_UNITS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_PROGRAM_UNITS_SV" AUTHID CURRENT_USER as
/* $Header: VEAVAPUS.pls 115.9 2004/07/27 00:07:28 rvishnuv ship $      */
--{
    /*======================  vea_program_units_sv  =========================*/
    /*========================================================================
       PURPOSE:

       NOTES:                To run the script:

                             sql> start VEAVAPKS.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/
    --
    --
    --
    --
    g_program_unit_id   NUMBER;
    --
    --
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code    IN     vea_layers.layer_provider_code%TYPE,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE,
          p_package_id             IN     vea_packages.package_id%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
	  x_program_unit_count     OUT NOCOPY     NUMBER,
	  x_tps_program_unit_count OUT NOCOPY     NUMBER
        );
    --
    --
    /*========================================================================

       PROCEDURE NAME: deleteUnreferencedProgramUnits

       PURPOSE:

    ========================================================================*/
    PROCEDURE
      deleteUnreferencedProgramUnits
        (
          p_layer_provider_code     IN     vea_program_units.layer_provider_code%TYPE,
          p_program_unit_id         IN     vea_program_units.program_unit_id%TYPE,
          p_tpa_program_unit_id     IN     vea_program_units.tpa_program_unit_id%TYPE
        );

    FUNCTION
      getId
        (
          p_layer_provider_code    IN     vea_program_units.layer_provider_code%TYPE,
          p_package_id             IN     vea_program_units.package_id%TYPE,
          p_name                   IN     vea_program_units.name%TYPE
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
          x_id                     OUT NOCOPY     vea_program_units.program_unit_id%TYPE,
          p_layer_provider_code    IN     vea_program_units.layer_provider_code%TYPE,
          p_package_id             IN     vea_program_units.program_unit_id%TYPE,
          p_program_unit_type      IN     vea_program_units.program_unit_type%TYPE,
          p_public_flag            IN     vea_program_units.public_flag%TYPE,
          p_customizable_flag      IN     vea_program_units.customizable_flag%TYPE,
          p_tps_flag               IN     vea_program_units.tps_flag%TYPE,
          p_name                   IN     vea_program_units.name%TYPE,
          p_label                  IN     vea_program_units.label%TYPE,
          p_return_type            IN     vea_program_units.return_type%TYPE,
          p_tpa_program_unit_id    IN     vea_program_units.tpa_program_unit_id%TYPE,
          p_description            IN     vea_program_units.description%TYPE,
          p_id                     IN     vea_program_units.program_unit_id%TYPE   := NULL,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE   := NULL
        );
    --
    --
    --
    --
--}
END VEA_PROGRAM_UNITS_SV;

 

/
