--------------------------------------------------------
--  DDL for Package VEA_LAYER_LICENSES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_LAYER_LICENSES_SV" AUTHID CURRENT_USER as
/* $Header: VEAVALLS.pls 115.7 2003/04/28 17:49:51 heali ship $      */
--{
    /*======================  vea_layer_licenses_sv  =========================*/
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
    FUNCTION
      isLicensed
        (
          p_layer_provider_code        IN     vea_layer_licenses.layer_provider_code%TYPE,
          p_tp_layer_id                IN     vea_layer_licenses.tp_layer_id%TYPE
        )
    RETURN BOOLEAN;
    --
    --
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code        IN     vea_layer_licenses.layer_provider_code%TYPE,
          p_tp_layer_id                IN     vea_layer_licenses.tp_layer_id%TYPE
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
          p_layer_provider_code        IN     vea_layer_licenses.layer_provider_code%TYPE,
          p_customer_name              IN     vea_layer_licenses.customer_name%TYPE,
          p_description                IN     vea_layer_licenses.description%TYPE,
          p_tp_layer_id                IN     vea_layer_licenses.tp_layer_id%TYPE
        );
    --
    --
    --
    --
--}
END VEA_LAYER_LICENSES_SV;

 

/
