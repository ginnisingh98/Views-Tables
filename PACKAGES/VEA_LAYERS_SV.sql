--------------------------------------------------------
--  DDL for Package VEA_LAYERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."VEA_LAYERS_SV" AUTHID CURRENT_USER as
/* $Header: VEAVALAS.pls 115.9 2004/07/27 00:06:34 rvishnuv ship $      */
--{
    /*======================  vea_layers_sv  =========================*/
    /*========================================================================
       PURPOSE:

       NOTES:                To run the script:

                             sql> start VEAVALHS.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/
    --
    --
    TYPE g_param_combination_rec_type
    IS RECORD
     (
       usedTPGC            BOOLEAN,
       usedCUST            BOOLEAN,
       usedSHIP            BOOLEAN,
       usedBILL            BOOLEAN,
       usedISHP            BOOLEAN
     );
    --
    --
    TYPE g_parameter_value_rec_type
    IS RECORD
     (
       TPGC_value            ece_xref_data.xref_int_value%TYPE,
       CUST_value            ece_xref_data.xref_int_value%TYPE,
       SHIP_value            ece_xref_data.xref_int_value%TYPE,
       BILL_value            ece_xref_data.xref_int_value%TYPE,
       ISHP_value            ece_xref_data.xref_int_value%TYPE,
       execution_priority    NUMBER
     );
    --
    --
    TYPE g_parameter_tbl_type
    IS   TABLE OF g_parameter_value_rec_type
    INDEX BY BINARY_INTEGER;
    --
    --
    TYPE g_layer_branch_rec_type
    IS RECORD
     (
       program_unit_id       vea_program_units.program_unit_id%TYPE,
       program_unit_name     vea_program_units.name%TYPE,
       layer_provider_code   vea_layers.layer_provider_code%TYPE,
       layer_header_id       vea_layers.layer_header_id%TYPE,
       layer_id              vea_layers.layer_id%TYPE,
       sequence_number       vea_layers.sequence_number%TYPE,
       execution_sequence    vea_layers.execution_sequence%TYPE,
       active_flag           vea_layers.active_flag%TYPE,
       tps_parameter1_name    vea_parameters.name%TYPE,
       tps_parameter1_value   ece_xref_data.xref_int_value%TYPE,
       tps_parameter2_name    vea_parameters.name%TYPE,
       tps_parameter2_value   ece_xref_data.xref_int_value%TYPE,
       tps_parameter3_name    vea_parameters.name%TYPE,
       tps_parameter3_value   ece_xref_data.xref_int_value%TYPE,
       tps_parameter4_name    vea_parameters.name%TYPE,
       tps_parameter4_value   ece_xref_data.xref_int_value%TYPE,
       tps_parameter5_name    vea_parameters.name%TYPE,
       tps_parameter5_value   ece_xref_data.xref_int_value%TYPE,
       tps_parameter6_name    vea_parameters.name%TYPE,
       tps_parameter6_value   ece_xref_data.xref_int_value%TYPE,
       tps_parameter7_name    vea_parameters.name%TYPE,
       tps_parameter7_value   ece_xref_data.xref_int_value%TYPE,
       tps_parameter8_name    vea_parameters.name%TYPE,
       tps_parameter8_value   ece_xref_data.xref_int_value%TYPE,
       tps_parameter9_name    vea_parameters.name%TYPE,
       tps_parameter9_value   ece_xref_data.xref_int_value%TYPE,
       tps_parameter10_name   vea_parameters.name%TYPE,
       tps_parameter10_value  ece_xref_data.xref_int_value%TYPE
     );
    --
    --
    TYPE g_layer_branch_tbl_type
    IS   TABLE OF g_layer_branch_rec_type
    INDEX BY BINARY_INTEGER;
    --
    --
    g_layer_branch_tbl g_layer_branch_tbl_type;
    --
    --
    TYPE g_layer_active_rec_type
    IS RECORD
     (
       program_unit_id       vea_program_units.program_unit_id%TYPE,
       program_unit_lp_code  vea_program_units.layer_provider_code%TYPE,
       tp_layer_id           vea_tp_layers.tp_layer_id%TYPE,
       tp_layer_name         vea_tp_layers.name%TYPE,
       active_flag           vea_layers.active_flag%TYPE
     );
    --
    --
    TYPE g_layer_active_tbl_type
    IS   TABLE OF g_layer_active_rec_type
    INDEX BY BINARY_INTEGER;
    --
    --
    g_layer_active_tbl g_layer_active_tbl_type;
    --
    --
    k_TPGC            CONSTANT VARCHAR2(30) := 'x_tp_group_code';
    k_CUST            CONSTANT VARCHAR2(30) := 'x_customer_number';
    k_SHIP            CONSTANT VARCHAR2(30) := 'x_ship_to_ece_locn_code';
    k_BILL            CONSTANT VARCHAR2(30) := 'x_bill_to_ece_locn_code';
    k_ISHP            CONSTANT VARCHAR2(30) := 'x_inter_ship_to_ece_locn_code';
    --
    --
    k_TPGC_PL         CONSTANT NUMBER := 2;
    k_CUST_PL         CONSTANT NUMBER := 4;
    k_SHIP_PL         CONSTANT NUMBER := 8;
    k_BILL_PL         CONSTANT NUMBER := 16;
    k_ISHP_PL         CONSTANT NUMBER := 32;
    --
    --
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
          p_tp_layer_id           IN     vea_tp_layers.tp_layer_id%TYPE,
	  x_layer_count           OUT NOCOPY     NUMBER
        );
    --
    --
    PROCEDURE
      processConflictingLayers
        (
          p_tp_layer_id		IN     vea_tp_layers.tp_layer_id%TYPE DEFAULT NULL,
          p_layer_provider_code	IN     vea_layers.layer_provider_code%TYPE DEFAULT NULL
        );
    --
    --
    PROCEDURE
      populateLayerActiveTable
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE
        );
    --
    --
    PROCEDURE
      process
        (
          p_api_version           IN     NUMBER,
          p_init_msg_list         IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level      IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status         OUT NOCOPY     VARCHAR2,
          x_msg_count             OUT NOCOPY     NUMBER,
          x_msg_data              OUT NOCOPY     VARCHAR2,
          x_id                    OUT NOCOPY     vea_layers.layer_id%TYPE,
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
          p_new_program_unit_id   IN     vea_layers.new_program_unit_id%TYPE,
          p_program_unit_lp_code  IN     vea_layers.program_unit_lp_code%TYPE,
          p_sequence_number       IN     vea_layers.sequence_number%TYPE,
          p_description           IN     vea_layers.description%TYPE,
	  p_tps_parameter1_id     IN     vea_layers.tps_parameter1_id%TYPE,
	  p_tps_parameter1_value  IN     vea_layers.tps_parameter1_value%TYPE,
	  p_tps_parameter2_id     IN     vea_layers.tps_parameter2_id%TYPE DEFAULT NULL,
	  p_tps_parameter2_value  IN     vea_layers.tps_parameter2_value%TYPE DEFAULT NULL,
	  p_tps_parameter3_id     IN     vea_layers.tps_parameter3_id%TYPE DEFAULT NULL,
	  p_tps_parameter3_value  IN     vea_layers.tps_parameter3_value%TYPE DEFAULT NULL,
	  p_tps_parameter4_id     IN     vea_layers.tps_parameter4_id%TYPE DEFAULT NULL,
	  p_tps_parameter4_value  IN     vea_layers.tps_parameter4_value%TYPE DEFAULT NULL,
	  p_tps_parameter5_id     IN     vea_layers.tps_parameter5_id%TYPE DEFAULT NULL,
	  p_tps_parameter5_value  IN     vea_layers.tps_parameter5_value%TYPE DEFAULT NULL,
	  p_tps_parameter6_id     IN     vea_layers.tps_parameter6_id%TYPE DEFAULT NULL,
	  p_tps_parameter6_value  IN     vea_layers.tps_parameter6_value%TYPE DEFAULT NULL,
	  p_tps_parameter7_id     IN     vea_layers.tps_parameter7_id%TYPE DEFAULT NULL,
	  p_tps_parameter7_value  IN     vea_layers.tps_parameter7_value%TYPE DEFAULT NULL,
	  p_tps_parameter8_id     IN     vea_layers.tps_parameter8_id%TYPE DEFAULT NULL,
	  p_tps_parameter8_value  IN     vea_layers.tps_parameter8_value%TYPE DEFAULT NULL,
	  p_tps_parameter9_id     IN     vea_layers.tps_parameter9_id%TYPE DEFAULT NULL,
	  p_tps_parameter9_value  IN     vea_layers.tps_parameter9_value%TYPE DEFAULT NULL,
	  p_tps_parameter10_id    IN     vea_layers.tps_parameter10_id%TYPE DEFAULT NULL,
	  p_tps_parameter10_value IN     vea_layers.tps_parameter10_value%TYPE DEFAULT NULL,
          p_id                    IN     vea_layers.layer_id%TYPE   := NULL,
          p_tp_layer_id           IN     vea_tp_layers.tp_layer_id%TYPE   := NULL,
          p_tp_layer_name         IN     vea_tp_layers.name%TYPE DEFAULT NULL,
	  p_tps_parameter1_name   IN     vea_parameters.name%TYPE DEFAULT NULL,
	  p_tps_parameter2_name   IN     vea_parameters.name%TYPE DEFAULT NULL,
	  p_tps_parameter3_name   IN     vea_parameters.name%TYPE DEFAULT NULL,
	  p_tps_parameter4_name   IN     vea_parameters.name%TYPE DEFAULT NULL,
	  p_tps_parameter5_name   IN     vea_parameters.name%TYPE DEFAULT NULL,
	  p_tps_parameter6_name   IN     vea_parameters.name%TYPE DEFAULT NULL,
	  p_tps_parameter7_name   IN     vea_parameters.name%TYPE DEFAULT NULL,
	  p_tps_parameter8_name   IN     vea_parameters.name%TYPE DEFAULT NULL,
	  p_tps_parameter9_name   IN     vea_parameters.name%TYPE DEFAULT NULL,
	  p_tps_parameter10_name  IN     vea_parameters.name%TYPE DEFAULT NULL
        );
    --
    --
PROCEDURE  checkConflictingLayers(
               p_package_name          IN vea_packages.name%TYPE,
               p_program_unit_name     IN vea_program_units.name%TYPE);

    --
    --
--}
END VEA_LAYERS_SV;

 

/
