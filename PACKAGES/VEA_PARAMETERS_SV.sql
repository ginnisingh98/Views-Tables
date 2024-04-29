--------------------------------------------------------
--  DDL for Package VEA_PARAMETERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_PARAMETERS_SV" AUTHID CURRENT_USER as
/* $Header: VEAVAPAS.pls 115.9 2004/07/27 00:06:18 rvishnuv ship $      */
--{
    /*======================  vea_parameters_sv  =========================*/
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
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code         IN     vea_parameters.layer_provider_code%TYPE,
          p_program_unit_id             IN     vea_parameters.program_unit_id%TYPE
        );
    --
    --
    FUNCTION
      getId
        (
          p_layer_provider_code    IN     vea_parameters.layer_provider_code%TYPE,
          p_program_unit_id        IN  vea_parameters.program_unit_id%TYPE,
          p_name                   IN     vea_parameters.name%TYPE
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
          x_id                     OUT NOCOPY     vea_parameters.parameter_id%TYPE,
          p_layer_provider_code    IN     vea_parameters.layer_provider_code%TYPE,
          p_program_unit_id        IN     vea_parameters.program_unit_id%TYPE,
          p_parameter_type         IN     vea_parameters.parameter_type%TYPE,
          p_parameter_seq          IN     vea_parameters.parameter_seq%TYPE,
          p_name                   IN     vea_parameters.name%TYPE,
          p_datatype               IN     vea_parameters.datatype%TYPE,
          p_default_value          IN     vea_parameters.default_value%TYPE,
          p_description            IN     vea_parameters.description%TYPE,
          p_id                     IN     vea_parameters.parameter_id%TYPE   := NULL,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE   := NULL
        );
    --
    --
    --
    --
--}
END VEA_PARAMETERS_SV;

 

/
