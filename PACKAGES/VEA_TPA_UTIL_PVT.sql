--------------------------------------------------------
--  DDL for Package VEA_TPA_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_TPA_UTIL_PVT" AUTHID CURRENT_USER as
/* $Header: VEATUTLS.pls 115.16 2004/07/27 00:07:38 rvishnuv ship $      */
--{
    /*========================  vea_tpa_util_pvt  ==========================*/
    /*========================================================================
       PURPOSE:

       NOTES:                To run the script:

                             sql> start VEATUTLS.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/

    G_PUBLIC_API           CONSTANT VARCHAR2(3) := 'PUB';
    G_PRIVATE_API          CONSTANT VARCHAR2(3) := 'PVT';
    G_GROUP_API            CONSTANT VARCHAR2(3) := 'GRP';
    --
    --
    G_ERROR                CONSTANT VARCHAR2(32767) := 'E';
    G_UNEXPECTED_ERROR     CONSTANT VARCHAR2(32767) := 'U';
    G_OTHER_ERROR          CONSTANT VARCHAR2(32767) := 'O';
    --
    --
    e_unexpected_error     EXCEPTION;
    --
    --
    G_ORACLE               CONSTANT VARCHAR2(32767) := 'ORCL';
    G_UNDERSCORE           CONSTANT VARCHAR2(32767) := '_';
    G_WILD_CARD            CONSTANT VARCHAR2(32767) := '%';
    C_INDEX_LIMIT          CONSTANT NUMBER          := 2147483648; -- power(2,31)
    --
    --
    TYPE g_programUnit_rec_type
    IS
    RECORD
      (
        program_unit_id      vea_program_units.program_unit_id%TYPE,
        start_position       NUMBER
      );
    --
    --
    TYPE g_programUnit_tbl_type
    IS
    TABLE OF g_programUnit_rec_type
    INDEX BY BINARY_INTEGER;
    --
    --
    TYPE g_layer_rec_type
    IS
    RECORD
      (
        layer_provider_code  vea_program_units.layer_provider_code%TYPE,
        layer_id             vea_layers.layer_id%TYPE,
        is_layer_active      BOOLEAN
      );
    --
    --
    TYPE g_layer_tbl_type
    IS
    TABLE OF g_layer_rec_type
    INDEX BY BINARY_INTEGER;
    --
    --
    g_programUnit_Tbl    g_programUnit_tbl_type;
    g_programUnitExt_Tbl g_programUnit_tbl_type;
    g_layer_Tbl          g_layer_tbl_type;
    --
    --
    TYPE g_code_conversion_rec_type
    IS
    RECORD
      (
        layer_provider_code  vea_program_units.layer_provider_code%TYPE,
        parameter_name       vea_parameters.name%TYPE,
        external_value       ece_xref_data.xref_ext_value1%TYPE,
        internal_value       ece_xref_data.xref_int_value%TYPE
      );
    --
    --
    TYPE g_code_conversion_tbl_type
    IS
    TABLE OF g_code_conversion_rec_type
    INDEX BY BINARY_INTEGER;
    --
    --
    TYPE g_branch_criteria_rec_type
    IS
    RECORD
      (
        layer_provider_code  vea_program_units.layer_provider_code%TYPE,
        parameter_name       vea_parameters.name%TYPE,
        external_value       ece_xref_data.xref_ext_value1%TYPE,
        internal_value       ece_xref_data.xref_int_value%TYPE
      );
    --
    --
    TYPE g_branch_criteria_tbl_type
    IS
    TABLE OF g_branch_criteria_rec_type
    INDEX BY BINARY_INTEGER;
    --
    --
    TYPE g_cache_rec_type
    IS
    RECORD
      (
        key       NUMBER,
        value     NUMBER
      );
    --
    --
    TYPE g_cache_tbl_type
    IS
    TABLE OF g_cache_rec_type
    INDEX BY BINARY_INTEGER;
    --
    --
    --C_INDEX_LIMIT CONSTANT NUMBER := 2147483648; -- power(2,31)
    --
    g_current_layer_provider_code       VARCHAR2(100);
    --
    g_tpLyr_fileId_dbId_tbl          g_cache_tbl_type;
    g_tpLyr_fileId_dbId_ext_tbl      g_cache_tbl_type;
    g_PU_fileId_dbId_tbl             g_cache_tbl_type;
    g_PU_fileId_dbId_ext_tbl         g_cache_tbl_type;
    g_pend_puId_tpaPUId_tbl          g_cache_tbl_type;
    g_pend_puId_tpaPUId_ext_tbl      g_cache_tbl_type;
    --
    --
    PROCEDURE add_message
      (
	p_error_name  IN      VARCHAR2,
	p_token1      IN      VARCHAR2 DEFAULT NULL,
	p_value1      IN      VARCHAR2 DEFAULT NULL,
	p_token2      IN      VARCHAR2 DEFAULT NULL,
	p_value2      IN      VARCHAR2 DEFAULT NULL,
	p_token3      IN      VARCHAR2 DEFAULT NULL,
	p_value3      IN      VARCHAR2 DEFAULT NULL,
	p_token4      IN      VARCHAR2 DEFAULT NULL,
	p_value4      IN      VARCHAR2 DEFAULT NULL,
	p_token5      IN      VARCHAR2 DEFAULT NULL,
	p_value5      IN      VARCHAR2 DEFAULT NULL,
	p_token6      IN      VARCHAR2 DEFAULT NULL,
	p_value6      IN      VARCHAR2 DEFAULT NULL,
	p_token7      IN      VARCHAR2 DEFAULT NULL,
	p_value7      IN      VARCHAR2 DEFAULT NULL,
	p_token8      IN      VARCHAR2 DEFAULT NULL,
	p_value8      IN      VARCHAR2 DEFAULT NULL
      );
    --
    --
    PROCEDURE add_message_and_raise
      (
	p_error_name  IN      VARCHAR2,
	p_token1      IN      VARCHAR2 DEFAULT NULL,
	p_value1      IN      VARCHAR2 DEFAULT NULL,
	p_token2      IN      VARCHAR2 DEFAULT NULL,
	p_value2      IN      VARCHAR2 DEFAULT NULL,
	p_token3      IN      VARCHAR2 DEFAULT NULL,
	p_value3      IN      VARCHAR2 DEFAULT NULL,
	p_token4      IN      VARCHAR2 DEFAULT NULL,
	p_value4      IN      VARCHAR2 DEFAULT NULL,
	p_token5      IN      VARCHAR2 DEFAULT NULL,
	p_value5      IN      VARCHAR2 DEFAULT NULL,
	p_token6      IN      VARCHAR2 DEFAULT NULL,
	p_value6      IN      VARCHAR2 DEFAULT NULL,
	p_token7      IN      VARCHAR2 DEFAULT NULL,
	p_value7      IN      VARCHAR2 DEFAULT NULL,
	p_token8      IN      VARCHAR2 DEFAULT NULL,
	p_value8      IN      VARCHAR2 DEFAULT NULL
      );
    --
    --
    PROCEDURE display_message
      (
	p_error_name  IN      VARCHAR2,
	p_token1      IN      VARCHAR2 DEFAULT NULL,
	p_value1      IN      VARCHAR2 DEFAULT NULL,
	p_token2      IN      VARCHAR2 DEFAULT NULL,
	p_value2      IN      VARCHAR2 DEFAULT NULL,
	p_token3      IN      VARCHAR2 DEFAULT NULL,
	p_value3      IN      VARCHAR2 DEFAULT NULL,
	p_token4      IN      VARCHAR2 DEFAULT NULL,
	p_value4      IN      VARCHAR2 DEFAULT NULL,
	p_token5      IN      VARCHAR2 DEFAULT NULL,
	p_value5      IN      VARCHAR2 DEFAULT NULL,
	p_token6      IN      VARCHAR2 DEFAULT NULL,
	p_value6      IN      VARCHAR2 DEFAULT NULL,
	p_token7      IN      VARCHAR2 DEFAULT NULL,
	p_value7      IN      VARCHAR2 DEFAULT NULL,
	p_token8      IN      VARCHAR2 DEFAULT NULL,
	p_value8      IN      VARCHAR2 DEFAULT NULL
      );
    --
    --
    PROCEDURE add_exc_message_and_raise
      (
	p_package_name           IN     VARCHAR2,
	p_api_name               IN     VARCHAR2,
	p_location               IN     VARCHAR2
      );
    --
    --
    PROCEDURE
      handle_error
	(
          p_error_type    	   IN  	  VARCHAR2,
          p_savepoint_name    	   IN  	  VARCHAR2,
	  p_package_name           IN     VARCHAR2,
	  p_api_name               IN     VARCHAR2,
	  p_location               IN     VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
	  x_api_return_status      OUT NOCOPY     VARCHAR2
	);
    --
    --
    PROCEDURE
      api_post_call
	(
          p_msg_count	           IN 	  NUMBER,
          p_msg_data		   IN 	  VARCHAR2,
	  p_api_return_status      IN     VARCHAR2
	);
    --
    --
    PROCEDURE
      api_header
	(
	  p_package_name            IN     VARCHAR2,
	  p_api_name                IN     VARCHAR2,
	  p_api_type                IN     VARCHAR2,
	  p_api_current_version     IN     NUMBER,
	  p_api_caller_version      IN     NUMBER,
          p_init_msg_list	    IN	   VARCHAR2 := FND_API.G_FALSE,
	  x_savepoint_name          OUT NOCOPY     VARCHAR2,
	  x_api_return_status       OUT NOCOPY     VARCHAR2
	);
    --
    --
    PROCEDURE
      api_footer
	(
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2
	);
    --
    --
    FUNCTION
      get_profile_value
        (
          p_profile_name           IN     VARCHAR2
        )
      RETURN VARCHAR2;

    --
    --
    FUNCTION
      get_curr_layer_provider_code
    RETURN VARCHAR2;
    --
    --
    FUNCTION
      get_curr_customer_name
    RETURN VARCHAR2;
    --
    --
    FUNCTION
      get_user_id
    RETURN NUMBER;
    --
    --
    FUNCTION
      get_login_id
    RETURN NUMBER;
    --
    --
    PROCEDURE
      get_constants
	(
          p_api_version            IN	  NUMBER,
          p_init_msg_list	   IN	  VARCHAR2 := FND_API.G_FALSE,
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level	   IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status	   OUT NOCOPY 	  VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
          x_true	           OUT NOCOPY 	  VARCHAR2,
          x_false                  OUT NOCOPY 	  VARCHAR2,
          x_valid_level_full       OUT NOCOPY 	  NUMBER,
          x_valid_level_none       OUT NOCOPY 	  NUMBER,
          x_success                OUT NOCOPY 	  VARCHAR2,
          x_error                  OUT NOCOPY 	  VARCHAR2,
          x_unexpected_error       OUT NOCOPY 	  VARCHAR2,
	  x_next                   OUT NOCOPY     NUMBER
	);
    --
    --
    PROCEDURE
      isVEAInstalled
	(
          p_api_version            IN	  NUMBER,
          p_init_msg_list	   IN	  VARCHAR2 := FND_API.G_FALSE,
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level	   IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status	   OUT NOCOPY 	  VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
	  x_vea_install_status     OUT NOCOPY     VARCHAR2
	);
    --
    --
    FUNCTION
      is_vea_installed
    RETURN BOOLEAN;
    --
    --
    PROCEDURE
      preProcess
        (
          p_api_version            IN     NUMBER,
          p_init_msg_list          IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                 IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level       IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status          OUT NOCOPY     VARCHAR2,
          x_msg_count              OUT NOCOPY     NUMBER,
          x_msg_data               OUT NOCOPY     VARCHAR2,
          p_layer_provider_code    IN     vea_layers.layer_provider_code%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE,
          p_tp_layer_name          IN     vea_tp_layers.name%TYPE
        );
    --
    --
    PROCEDURE
      postProcess
        (
          p_api_version            IN     NUMBER,
          p_init_msg_list          IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                 IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level       IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status          OUT NOCOPY     VARCHAR2,
          x_msg_count              OUT NOCOPY     NUMBER,
          x_msg_data               OUT NOCOPY     VARCHAR2,
          p_layer_provider_code    IN     vea_layers.layer_provider_code%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE,
          p_tp_layer_name          IN     vea_tp_layers.name%TYPE
        );
    --
    --
    FUNCTION
      isLayerMergeOn
    RETURN  BOOLEAN;
    --
    --
    PROCEDURE
      populateLayerActiveTable
	(
          p_layer_provider_code  IN      vea_program_units.layer_provider_code%TYPE,
          p_program_unit_id      IN      vea_program_units.program_unit_id%TYPE,
          x_layer_table          IN OUT NOCOPY   g_layer_tbl_type
	);
    --
    --
    FUNCTION
      isLayerActive
        (
          p_layer_table          IN   g_layer_tbl_type,
          p_layer_id             IN   vea_layers.layer_id%TYPE,
          p_layer_provider_code  IN   vea_program_units.layer_provider_code%TYPE
        )
    RETURN  BOOLEAN;
    --
    --
    PROCEDURE
      process_code_conversion
	(
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
	  p_tps_parameter_id      IN     vea_layers.tps_parameter1_id%TYPE,
	  p_tps_parameter_value   IN     vea_layers.tps_parameter1_value%TYPE
	);
    --
    --
    FUNCTION  convertBranchCriteria
    (
      p_layer_provider_code  IN      vea_program_units.layer_provider_code%TYPE,
      p_parameter_name       IN      vea_parameters.name%TYPE,
      p_external_value       IN      ece_xref_data.xref_ext_value1%TYPE,
      x_code_conversion_tbl  IN OUT NOCOPY   vea_tpa_util_pvt.g_code_conversion_tbl_type
    )
    RETURN  ece_xref_data.xref_int_value%TYPE;
    --
    --
    FUNCTION  Convert_from_ext_to_int
    (
      p_layer_provider_code  IN      vea_program_units.layer_provider_code%TYPE,
      p_parameter_name       IN      vea_parameters.name%TYPE,
      p_external_value       IN      ece_xref_data.xref_ext_value1%TYPE
    )
    RETURN  ece_xref_data.xref_int_value%TYPE;
    --
    --
    FUNCTION  Convert_from_int_to_ext
    (
      p_layer_provider_code  IN      vea_program_units.layer_provider_code%TYPE,
      p_parameter_name       IN      vea_parameters.name%TYPE,
      p_internal_value       IN      ece_xref_data.xref_int_value%TYPE
    )
    RETURN  ece_xref_data.xref_ext_value1%TYPE;
    --
    --
    PROCEDURE  debug
    (
      p_string  IN      VARCHAR2
    );
    --
    --
    FUNCTION  validate
    RETURN BOOLEAN;
    --
    --
    FUNCTION get_message_text
    (
        p_error_name  IN      VARCHAR2,
        p_token1      IN      VARCHAR2 DEFAULT NULL,
        p_value1      IN      VARCHAR2 DEFAULT NULL,
        p_token2      IN      VARCHAR2 DEFAULT NULL,
        p_value2      IN      VARCHAR2 DEFAULT NULL,
        p_token3      IN      VARCHAR2 DEFAULT NULL,
        p_value3      IN      VARCHAR2 DEFAULT NULL,
        p_token4      IN      VARCHAR2 DEFAULT NULL,
        p_value4      IN      VARCHAR2 DEFAULT NULL,
        p_token5      IN      VARCHAR2 DEFAULT NULL,
        p_value5      IN      VARCHAR2 DEFAULT NULL,
        p_token6      IN      VARCHAR2 DEFAULT NULL,
        p_value6      IN      VARCHAR2 DEFAULT NULL,
        p_token7      IN      VARCHAR2 DEFAULT NULL,
        p_value7      IN      VARCHAR2 DEFAULT NULL,
        p_token8      IN      VARCHAR2 DEFAULT NULL,
        p_value8      IN      VARCHAR2 DEFAULT NULL

   )
    RETURN VARCHAR2;
   --
   --
   PROCEDURE update_lookup_values
   (
        p_lookup_type         IN    fnd_lookup_values.lookup_type%TYPE,
        p_new_lookup_code     IN    fnd_lookup_values.lookup_code%TYPE,
        p_current_lookup_code IN    fnd_lookup_values.lookup_code%TYPE,
        p_meaning             IN    fnd_lookup_values.meaning%TYPE,
        p_description         IN    fnd_lookup_values.description%TYPE
   );
   --
   --
   PROCEDURE insert_lookup_values
   (
        p_lookup_type         IN    fnd_lookup_values.lookup_type%TYPE,
        p_lookup_code         IN    fnd_lookup_values.lookup_code%TYPE,
        p_meaning             IN    fnd_lookup_values.meaning%TYPE,
        p_description         IN    fnd_lookup_values.description%TYPE
   );
   --
   --
   PROCEDURE clearLayerActiveTable;
    /*========================================================================

       PROCEDURE NAME: put

    ========================================================================*/
    PROCEDURE
      put
        (
          p_key                IN            NUMBER,
          p_value              IN            NUMBER,
          x_cache_tbl          IN OUT NOCOPY g_cache_tbl_type,
          x_cache_ext_tbl      IN OUT NOCOPY g_cache_tbl_type
        );

    /*========================================================================

       PROCEDURE NAME: get

    ========================================================================*/
    PROCEDURE
      get
        (
          p_key                IN            NUMBER,
          p_cache_tbl          IN OUT NOCOPY g_cache_tbl_type,
          p_cache_ext_tbl      IN OUT NOCOPY g_cache_tbl_type,
          x_value              OUT    NOCOPY NUMBER
        );

--}

END VEA_TPA_UTIL_PVT;

 

/
