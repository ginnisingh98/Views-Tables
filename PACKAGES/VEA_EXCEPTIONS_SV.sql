--------------------------------------------------------
--  DDL for Package VEA_EXCEPTIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_EXCEPTIONS_SV" AUTHID CURRENT_USER as
/* $Header: VEAVAEXS.pls 115.3 2002/12/12 02:33:47 heali noship $      */
--{
    /*======================  vea_EXCEPTIONS_sv  =========================*/
    /*========================================================================
       PURPOSE:

       NOTES:                To run the script:

                             sql> start VEAVAPKS.pls

       HISTORY
                             Created   BMUNAGAL       04/13/2000

    =========================================================================*/
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
          x_id                     OUT NOCOPY     vea_EXCEPTIONS.exception_id%TYPE,
          p_release_id             IN VEA_EXCEPTIONS.release_id%TYPE,
          p_layer_provider_code    IN VEA_EXCEPTIONS.layer_provider_code%TYPE,
          p_message_name           IN VEA_EXCEPTIONS.message_name%TYPE,
          p_exception_level        IN VEA_EXCEPTIONS.exception_level%TYPE,
          p_message_text           IN VEA_EXCEPTIONS.message_text%TYPE,
          p_description            IN VEA_EXCEPTIONS.description%TYPE,
          p_id                     IN VEA_EXCEPTIONS.exception_id%TYPE := NULL
        );
    --
    --
--}
END VEA_EXCEPTIONS_SV;

 

/
