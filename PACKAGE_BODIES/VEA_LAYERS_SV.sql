--------------------------------------------------------
--  DDL for Package Body VEA_LAYERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_LAYERS_SV" as
/* $Header: VEAVALAB.pls 115.15 2004/07/27 00:09:55 rvishnuv ship $      */
--{
    /*======================  vea_layers_sv  =========================*/
    /*========================================================================
       PURPOSE:  Table handler package for table VEA_LAYERS

       NOTES:                To run the script:

                             sql> start VEAVALAB.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM
                             Modified  M NARAYAN      06/06/00 10:00 AM

                             Added the following procedures for enhancement for
                             detecting and processing layer conflicts:

                             getParameterIntValue
                             saveBranchToGlobal
                             saveBranchCriteria
                             findParameterValue
                             findBranchParameters
                             findParameterCombination
                             checkOverlapExists
                             switchLayerPositions
                             checkConflictingLayers
                             saveConflictDetails
                             processConflictingLayers

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_LAYERS_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME: getParameterIntValue

       PURPOSE: Finds the internal value of a parameter using its id.

    ========================================================================*/
    PROCEDURE
      getParameterIntValue
        (
          p_layer_provider_code    IN vea_layers.layer_provider_code%TYPE,
          p_layer_header_id        IN vea_layers.layer_header_id%TYPE,
          p_tps_parameter_id       IN vea_layers.tps_parameter1_id%TYPE,
          p_tps_parameter_value    IN vea_layers.tps_parameter1_value%TYPE,
          p_tps_parameter_int_value IN OUT NOCOPY  ece_xref_data.xref_int_value%TYPE,
          p_tps_parameter_name      IN OUT NOCOPY  vea_parameters.name%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'getParameterIntValue';
        l_location            VARCHAR2(32767);
	--
	--
        CURSOR parameter_cur
               ( p_layer_provider_code  IN vea_layers.layer_provider_code%TYPE,
                 p_layer_header_id  IN vea_layers.layer_header_id%TYPE,
                 p_tps_parameter_id  IN vea_layers.tps_parameter1_id%TYPE)
        IS
          SELECT PA.name
          FROM   vea_parameters PA,
                 vea_program_units PU,
                 vea_layer_headers LH
          WHERE  PA.parameter_id        = p_tps_parameter_id
          AND    LH.layer_provider_code = p_layer_provider_code
          AND    LH.layer_header_id     = p_layer_header_id
          AND    PU.program_unit_id     = LH.tps_program_unit_id
          AND    PU.layer_provider_code = LH.tps_program_unit_lp_code
          AND    PA.program_unit_id     = PU.program_unit_id
          AND    PA.layer_provider_code = PU.layer_provider_code;
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
        --
        FOR parameter_rec IN parameter_cur
                               (
                                 p_layer_provider_code => p_layer_provider_code,
                                 p_layer_header_id     => p_layer_header_id,
                                 p_tps_parameter_id    => p_tps_parameter_id
                               )
        LOOP
        --{
            l_location := '0010';
            --
	    --
            p_tps_parameter_name := parameter_rec.name;
            p_tps_parameter_int_value :=
                VEA_TPA_UTIL_PVT.Convert_from_ext_to_int(
                                              p_layer_provider_code,
                                              parameter_rec.name,
                                              p_tps_parameter_value);
            --
	    --
            IF p_tps_parameter_int_value IS NOT NULL
            THEN
            --{
                RETURN;
            --}
            END IF;
        --}
        END LOOP;
        RETURN;
    --}
    EXCEPTION
    --{
	WHEN FND_API.G_EXC_ERROR
	THEN
	--{
	    RAISE;
	--}
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END getParameterIntValue;
    --
    --
    /*========================================================================

       PROCEDURE NAME: saveBranchToGlobal

       PURPOSE: This saves the branch criteria names and values to a
                PL/SQL table.

    ========================================================================*/
    PROCEDURE
      saveBranchToGlobal(
               p_layer_provider_code       IN vea_parameters.layer_provider_code%TYPE,
               p_layer_header_id           IN vea_layers.layer_header_id%TYPE,
               p_layer_id                  IN vea_layers.layer_id%TYPE,
               p_sequence_number           IN vea_layers.sequence_number%TYPE,
               p_tps_parameter1_name       IN vea_parameters.name%TYPE,
               p_tps_parameter1_int_value  IN ece_xref_data.xref_int_value%TYPE,
               p_tps_parameter2_name       IN vea_parameters.name%TYPE,
               p_tps_parameter2_int_value  IN ece_xref_data.xref_int_value%TYPE,
               p_tps_parameter3_name       IN vea_parameters.name%TYPE,
               p_tps_parameter3_int_value  IN ece_xref_data.xref_int_value%TYPE,
               p_tps_parameter4_name       IN vea_parameters.name%TYPE,
               p_tps_parameter4_int_value  IN ece_xref_data.xref_int_value%TYPE,
               p_tps_parameter5_name       IN vea_parameters.name%TYPE,
               p_tps_parameter5_int_value  IN ece_xref_data.xref_int_value%TYPE,
               p_tps_parameter6_name       IN vea_parameters.name%TYPE,
               p_tps_parameter6_int_value  IN ece_xref_data.xref_int_value%TYPE,
               p_tps_parameter7_name       IN vea_parameters.name%TYPE,
               p_tps_parameter7_int_value  IN ece_xref_data.xref_int_value%TYPE,
               p_tps_parameter8_name       IN vea_parameters.name%TYPE,
               p_tps_parameter8_int_value  IN ece_xref_data.xref_int_value%TYPE,
               p_tps_parameter9_name       IN vea_parameters.name%TYPE,
               p_tps_parameter9_int_value  IN ece_xref_data.xref_int_value%TYPE,
               p_tps_parameter10_name      IN vea_parameters.name%TYPE,
               p_tps_parameter10_int_value IN ece_xref_data.xref_int_value%TYPE)
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'saveBranchToGlobal';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_index BINARY_INTEGER;
	--
	--
    BEGIN
    --{
        IF g_layer_branch_tbl.COUNT > 0 THEN
            l_index := g_layer_branch_tbl.LAST + 1;
        ELSE
            l_index := 1;
        END IF;
        --
        --
        g_layer_branch_tbl(l_index).layer_provider_code  := p_layer_provider_code;
        g_layer_branch_tbl(l_index).layer_header_id      := p_layer_header_id;
        g_layer_branch_tbl(l_index).layer_id             := p_layer_id;
        g_layer_branch_tbl(l_index).sequence_number      := p_sequence_number;
        --
        --
        IF p_tps_parameter1_name IS NOT NULL
        THEN
        --{
            g_layer_branch_tbl(l_index).tps_parameter1_name  := p_tps_parameter1_name;
            g_layer_branch_tbl(l_index).tps_parameter1_value := p_tps_parameter1_int_value;
        --}
        END IF;
        --
        --
        IF p_tps_parameter2_name IS NOT NULL
        THEN
        --{
            g_layer_branch_tbl(l_index).tps_parameter2_name  := p_tps_parameter2_name;
            g_layer_branch_tbl(l_index).tps_parameter2_value := p_tps_parameter2_int_value;
        --}
        END IF;
        --
        --
        IF p_tps_parameter3_name IS NOT NULL
        THEN
        --{
            g_layer_branch_tbl(l_index).tps_parameter3_name  := p_tps_parameter3_name;
            g_layer_branch_tbl(l_index).tps_parameter3_value := p_tps_parameter3_int_value;
        --}
        END IF;
        --
        --
        IF p_tps_parameter4_name IS NOT NULL
        THEN
        --{
            g_layer_branch_tbl(l_index).tps_parameter4_name  := p_tps_parameter4_name;
            g_layer_branch_tbl(l_index).tps_parameter4_value := p_tps_parameter4_int_value;
        --}
        END IF;
        --
        --
        IF p_tps_parameter5_name IS NOT NULL
        THEN
        --{
            g_layer_branch_tbl(l_index).tps_parameter5_name  := p_tps_parameter5_name;
            g_layer_branch_tbl(l_index).tps_parameter5_value := p_tps_parameter5_int_value;
        --}
        END IF;
        --
        --
        IF p_tps_parameter6_name IS NOT NULL
        THEN
        --{
            g_layer_branch_tbl(l_index).tps_parameter6_name  := p_tps_parameter6_name;
            g_layer_branch_tbl(l_index).tps_parameter6_value := p_tps_parameter6_int_value;
        --}
        END IF;
        --
        --
        IF p_tps_parameter7_name IS NOT NULL
        THEN
        --{
            g_layer_branch_tbl(l_index).tps_parameter7_name  := p_tps_parameter7_name;
            g_layer_branch_tbl(l_index).tps_parameter7_value := p_tps_parameter7_int_value;
        --}
        END IF;
        --
        --
        IF p_tps_parameter8_name IS NOT NULL
        THEN
        --{
            g_layer_branch_tbl(l_index).tps_parameter8_name  := p_tps_parameter8_name;
            g_layer_branch_tbl(l_index).tps_parameter8_value := p_tps_parameter8_int_value;
        --}
        END IF;
        --
        --
        IF p_tps_parameter9_name IS NOT NULL
        THEN
        --{
            g_layer_branch_tbl(l_index).tps_parameter9_name  := p_tps_parameter9_name;
            g_layer_branch_tbl(l_index).tps_parameter9_value := p_tps_parameter9_int_value;
        --}
        END IF;
        --
        --
        IF p_tps_parameter10_name IS NOT NULL
        THEN
        --{
            g_layer_branch_tbl(l_index).tps_parameter10_name  := p_tps_parameter10_name;
            g_layer_branch_tbl(l_index).tps_parameter10_value := p_tps_parameter10_int_value;
        --}
        END IF;
        --
        --
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
           --NULL;
    --}
    END  saveBranchToGlobal;
    --
    --
    /*========================================================================

       PROCEDURE NAME: saveBranchCriteria

       PURPOSE: This finds the internal values of each of the parameters used
                and then saves the values to the global table.

    ========================================================================*/
    PROCEDURE
      saveBranchCriteria (
          p_layer_provider_code    IN vea_layers.layer_provider_code%TYPE,
          p_layer_id               IN vea_layers.layer_id%TYPE,
          p_layer_header_id        IN vea_layers.layer_header_id%TYPE,
          p_sequence_number        IN vea_layers.sequence_number%TYPE,
          p_active_flag            IN vea_layers.active_flag%TYPE,
          p_tps_parameter1_id      IN vea_layers.tps_parameter1_id%TYPE,
          p_tps_parameter1_value   IN vea_layers.tps_parameter1_value%TYPE,
          p_tps_parameter2_id      IN vea_layers.tps_parameter2_id%TYPE,
          p_tps_parameter2_value   IN vea_layers.tps_parameter2_value%TYPE,
          p_tps_parameter3_id      IN vea_layers.tps_parameter3_id%TYPE,
          p_tps_parameter3_value   IN vea_layers.tps_parameter3_value%TYPE,
          p_tps_parameter4_id      IN vea_layers.tps_parameter4_id%TYPE,
          p_tps_parameter4_value   IN vea_layers.tps_parameter4_value%TYPE,
          p_tps_parameter5_id      IN vea_layers.tps_parameter5_id%TYPE,
          p_tps_parameter5_value   IN vea_layers.tps_parameter5_value%TYPE,
          p_tps_parameter6_id      IN vea_layers.tps_parameter6_id%TYPE,
          p_tps_parameter6_value   IN vea_layers.tps_parameter6_value%TYPE,
          p_tps_parameter7_id      IN vea_layers.tps_parameter7_id%TYPE,
          p_tps_parameter7_value   IN vea_layers.tps_parameter7_value%TYPE,
          p_tps_parameter8_id      IN vea_layers.tps_parameter8_id%TYPE,
          p_tps_parameter8_value   IN vea_layers.tps_parameter8_value%TYPE,
          p_tps_parameter9_id      IN vea_layers.tps_parameter9_id%TYPE,
          p_tps_parameter9_value   IN vea_layers.tps_parameter9_value%TYPE,
          p_tps_parameter10_id     IN vea_layers.tps_parameter10_id%TYPE,
          p_tps_parameter10_value  IN vea_layers.tps_parameter10_value%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'saveBranchCriteria';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_tps_parameter1_int_value      ece_xref_data.xref_int_value%TYPE;
        l_tps_parameter2_int_value      ece_xref_data.xref_int_value%TYPE;
        l_tps_parameter3_int_value      ece_xref_data.xref_int_value%TYPE;
        l_tps_parameter4_int_value      ece_xref_data.xref_int_value%TYPE;
        l_tps_parameter5_int_value      ece_xref_data.xref_int_value%TYPE;
        l_tps_parameter6_int_value      ece_xref_data.xref_int_value%TYPE;
        l_tps_parameter7_int_value      ece_xref_data.xref_int_value%TYPE;
        l_tps_parameter8_int_value      ece_xref_data.xref_int_value%TYPE;
        l_tps_parameter9_int_value      ece_xref_data.xref_int_value%TYPE;
        l_tps_parameter10_int_value     ece_xref_data.xref_int_value%TYPE;
        l_tps_parameter1_name           vea_parameters.name%TYPE;
        l_tps_parameter2_name           vea_parameters.name%TYPE;
        l_tps_parameter3_name           vea_parameters.name%TYPE;
        l_tps_parameter4_name           vea_parameters.name%TYPE;
        l_tps_parameter5_name           vea_parameters.name%TYPE;
        l_tps_parameter6_name           vea_parameters.name%TYPE;
        l_tps_parameter7_name           vea_parameters.name%TYPE;
        l_tps_parameter8_name           vea_parameters.name%TYPE;
        l_tps_parameter9_name           vea_parameters.name%TYPE;
        l_tps_parameter10_name          vea_parameters.name%TYPE;
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
        --
        --
        getParameterIntValue(p_layer_provider_code, p_layer_header_id,
                             p_tps_parameter1_id,   p_tps_parameter1_value,
                             l_tps_parameter1_int_value, l_tps_parameter1_name );
        --
	--
        getParameterIntValue(p_layer_provider_code, p_layer_header_id,
                             p_tps_parameter2_id,   p_tps_parameter2_value,
                             l_tps_parameter2_int_value, l_tps_parameter2_name );
        --
	--
        getParameterIntValue(p_layer_provider_code, p_layer_header_id,
                             p_tps_parameter3_id,   p_tps_parameter3_value,
                             l_tps_parameter3_int_value, l_tps_parameter3_name );
        --
	--
        getParameterIntValue(p_layer_provider_code, p_layer_header_id,
                             p_tps_parameter4_id,   p_tps_parameter4_value,
                             l_tps_parameter4_int_value, l_tps_parameter4_name );
        --
	--
        getParameterIntValue(p_layer_provider_code, p_layer_header_id,
                             p_tps_parameter5_id,   p_tps_parameter5_value,
                             l_tps_parameter5_int_value, l_tps_parameter5_name );
        --
	--
        getParameterIntValue(p_layer_provider_code, p_layer_header_id,
                             p_tps_parameter6_id,   p_tps_parameter6_value,
                             l_tps_parameter6_int_value, l_tps_parameter6_name );
        --
	--
        getParameterIntValue(p_layer_provider_code, p_layer_header_id,
                             p_tps_parameter7_id,   p_tps_parameter7_value,
                             l_tps_parameter7_int_value, l_tps_parameter7_name );
        --
	--
        getParameterIntValue(p_layer_provider_code, p_layer_header_id,
                             p_tps_parameter8_id,   p_tps_parameter8_value,
                             l_tps_parameter8_int_value, l_tps_parameter8_name );
        --
	--
        getParameterIntValue(p_layer_provider_code, p_layer_header_id,
                             p_tps_parameter9_id,   p_tps_parameter9_value,
                             l_tps_parameter9_int_value, l_tps_parameter9_name );
        --
	--
        getParameterIntValue(p_layer_provider_code, p_layer_header_id,
                             p_tps_parameter10_id,  p_tps_parameter10_value,
                             l_tps_parameter10_int_value, l_tps_parameter10_name );
        --
	--
        saveBranchToGlobal( p_layer_provider_code, p_layer_header_id,
                             p_layer_id, p_sequence_number,
                             l_tps_parameter1_name, l_tps_parameter1_int_value,
                             l_tps_parameter2_name, l_tps_parameter2_int_value,
                             l_tps_parameter3_name, l_tps_parameter3_int_value,
                             l_tps_parameter4_name, l_tps_parameter4_int_value,
                             l_tps_parameter5_name, l_tps_parameter5_int_value,
                             l_tps_parameter6_name, l_tps_parameter6_int_value,
                             l_tps_parameter7_name, l_tps_parameter7_int_value,
                             l_tps_parameter8_name, l_tps_parameter8_int_value,
                             l_tps_parameter9_name, l_tps_parameter9_int_value,
                             l_tps_parameter10_name,l_tps_parameter10_int_value);
        --
	--
    --}
    EXCEPTION
    --{
	WHEN FND_API.G_EXC_ERROR
	THEN
	--{
	    RAISE;
	--}
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END saveBranchCriteria;
    --
    --
    /*========================================================================

       PROCEDURE NAME: findParameterValue

       PURPOSE: This finds the value of a particular branch criteria
                from the global table.

    ========================================================================*/
    FUNCTION
      findParameterValue(
               p_global_tbl_position   IN NUMBER,
               p_parameter_type        IN VARCHAR2 )
    RETURN ece_xref_data.xref_int_value%TYPE
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'findParameterValue';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
    BEGIN
    --{
        --
        --
        IF g_layer_branch_tbl(p_global_tbl_position).tps_parameter1_name
                                                    = p_parameter_type
        THEN
            --
            --
            RETURN(g_layer_branch_tbl(p_global_tbl_position).tps_parameter1_value);
            --
            --



        ELSIF g_layer_branch_tbl(p_global_tbl_position).tps_parameter2_name
                                                    = p_parameter_type
        THEN
            --
            --

            RETURN(g_layer_branch_tbl(p_global_tbl_position).tps_parameter2_value);
            --
            --
        ELSIF g_layer_branch_tbl(p_global_tbl_position).tps_parameter3_name
                                                    = p_parameter_type
        THEN
            --
            --
            RETURN(g_layer_branch_tbl(p_global_tbl_position).tps_parameter3_value);
            --
            --
        ELSIF g_layer_branch_tbl(p_global_tbl_position).tps_parameter4_name
                                                    = p_parameter_type
        THEN
            --
            --
            RETURN(g_layer_branch_tbl(p_global_tbl_position).tps_parameter4_value);
            --
            --
        ELSIF g_layer_branch_tbl(p_global_tbl_position).tps_parameter5_name
                                                    = p_parameter_type
        THEN
            --
            --
            RETURN(g_layer_branch_tbl(p_global_tbl_position).tps_parameter5_value);
            --
            --
        ELSIF g_layer_branch_tbl(p_global_tbl_position).tps_parameter6_name
                                                    = p_parameter_type
        THEN
            --
            --
            RETURN(g_layer_branch_tbl(p_global_tbl_position).tps_parameter6_value);
            --
            --
        ELSIF g_layer_branch_tbl(p_global_tbl_position).tps_parameter7_name
                                                    = p_parameter_type
        THEN
            --
            --
            RETURN(g_layer_branch_tbl(p_global_tbl_position).tps_parameter7_value);
            --
            --
        ELSIF g_layer_branch_tbl(p_global_tbl_position).tps_parameter8_name
                                                    = p_parameter_type
        THEN
            --
            --
            RETURN(g_layer_branch_tbl(p_global_tbl_position).tps_parameter8_value);
            --
            --
        ELSIF g_layer_branch_tbl(p_global_tbl_position).tps_parameter9_name
                                                    = p_parameter_type
        THEN
            --
            --
            RETURN(g_layer_branch_tbl(p_global_tbl_position).tps_parameter9_value);
            --
            --
        ELSIF g_layer_branch_tbl(p_global_tbl_position).tps_parameter10_name
                                                    = p_parameter_type
        THEN
            --
            --
            RETURN(g_layer_branch_tbl(p_global_tbl_position).tps_parameter10_value);
            --
            --
        END IF;
        --
        --
        RETURN('PARAMETER NOT FOUND!!!!!');
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
           --NULL;
    --}
    END  findParameterValue;
    --
    --
    /*========================================================================

       PROCEDURE NAME: findBranchParameters

       PURPOSE: This finds the value of each of the five possible branch
                criteria used in the layer. It also calculates the priority of
                the branch based on the combination of the criteria used.

    ========================================================================*/
    PROCEDURE
      findBranchParameters(
               p_global_tbl_position   IN NUMBER,
               p_branch_param_rec      IN OUT NOCOPY  g_parameter_value_rec_type)
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'findBranchParameters';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_layer_count NUMBER;
        l_execution_priority NUMBER := 0;
	--
	--
    BEGIN
    --{
        l_layer_count := g_layer_branch_tbl.COUNT;
        --
        --
        p_branch_param_rec.TPGC_value := findParameterValue(p_global_tbl_position, k_TPGC);
        p_branch_param_rec.CUST_value := findParameterValue(p_global_tbl_position, k_CUST);
        p_branch_param_rec.SHIP_value := findParameterValue(p_global_tbl_position, k_SHIP);
        p_branch_param_rec.BILL_value := findParameterValue(p_global_tbl_position, k_BILL);
        p_branch_param_rec.ISHP_value := findParameterValue(p_global_tbl_position, k_ISHP);
        --
        --
        IF p_branch_param_rec.TPGC_value IS NOT NULL THEN
            --
            --
            l_execution_priority := l_execution_priority + k_TPGC_PL;
            --
            --
        END IF;
        --
        --
        IF p_branch_param_rec.CUST_value IS NOT NULL THEN
            --
            --
            l_execution_priority := l_execution_priority + k_CUST_PL;
            --
            --
        END IF;
        --
        --
        IF p_branch_param_rec.SHIP_value IS NOT NULL THEN
            --
            --
            l_execution_priority := l_execution_priority + k_SHIP_PL;
            --
            --
        END IF;
        --
        --
        IF p_branch_param_rec.BILL_value IS NOT NULL THEN
            --
            --
            l_execution_priority := l_execution_priority + k_BILL_PL;
            --
            --
        END IF;
        --
        --
        IF p_branch_param_rec.ISHP_value IS NOT NULL THEN
            --
            --
            l_execution_priority := l_execution_priority + k_ISHP_PL;
            --
            --
        END IF;
        --
        --
        p_branch_param_rec.execution_priority := l_execution_priority;
        --
        --
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN

           RAISE;
           --NULL;
    --}
    END  findBranchParameters;
    --
    --
    /*========================================================================

       PROCEDURE NAME: findParameterCombination

       PURPOSE: This finds which of the five criteria have been used in the
                branching condition.

    ========================================================================*/
    PROCEDURE
      findParameterCombination(
               p_execution_priority     IN NUMBER,
               p_param_combination_rec  IN OUT NOCOPY  g_param_combination_rec_type)
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'findParameterCombination';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_execution_priority NUMBER;
	--
	--
    BEGIN
    --{
        l_execution_priority := p_execution_priority;
        --
        --
        IF (l_execution_priority - k_ISHP_PL) >= 0 THEN
            --
            --
            p_param_combination_rec.usedISHP := TRUE;
            l_execution_priority := l_execution_priority - k_ISHP_PL;
            --
            --
        END IF;
        --
        --
        IF (l_execution_priority - k_BILL_PL) >= 0 THEN
            --
            --
            p_param_combination_rec.usedBILL := TRUE;
            l_execution_priority := l_execution_priority - k_BILL_PL;
            --
            --
        END IF;
        --
        --
        IF (l_execution_priority - k_SHIP_PL) >= 0 THEN
            --
            --
            p_param_combination_rec.usedSHIP := TRUE;
            l_execution_priority := l_execution_priority - k_SHIP_PL;
            --
            --
        END IF;
        --
        --
        IF (l_execution_priority - k_CUST_PL) >= 0 THEN
            --
            --
            p_param_combination_rec.usedCUST := TRUE;
            l_execution_priority := l_execution_priority - k_CUST_PL;
            --
            --
        END IF;
        --
        --
        IF (l_execution_priority - k_TPGC_PL) >= 0 THEN
            --
            --
            p_param_combination_rec.usedTPGC := TRUE;
            l_execution_priority := l_execution_priority - k_TPGC_PL;
            --
            --
        END IF;
        --
        --
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
           --NULL;
    --}
    END  findParameterCombination;
    --
    --
    /*========================================================================

       PROCEDURE NAME: checkOverlapExists

       PURPOSE: This function checks whether the two branch parameter records
                have criteria that overlap. For all those conditions where the
                same criteria is used but with different value, we know that the
                during execution, only one condition will be satisfied.
                Overlap does not exist for such cases. In all other conditions
                where multiple conditions couls be true, we need to ensure
                that execution sequence is properly assigned based on
                priority. Hence we male a conservative assumption that an
                overlap exists for all other combination of conditions.

    ========================================================================*/
    FUNCTION
      checkOverlapExists(
               p_branch_curr_rec      IN g_parameter_value_rec_type,
               p_branch_cmpr_rec      IN g_parameter_value_rec_type)
    RETURN  BOOLEAN
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'checkOverlapExists';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_curr_index BINARY_INTEGER;
        l_cmpr_index BINARY_INTEGER;
        l_curr_execution_priority NUMBER;
        l_cmpr_execution_priority NUMBER;
        l_curr_param_combination_rec g_param_combination_rec_type;
        l_cmpr_param_combination_rec g_param_combination_rec_type;
	--
	--
    BEGIN
    --{
        l_curr_execution_priority := p_branch_curr_rec.execution_priority;
        l_cmpr_execution_priority := p_branch_cmpr_rec.execution_priority;
        --
        --
        findParameterCombination(l_curr_execution_priority, l_curr_param_combination_rec);
        findParameterCombination(l_cmpr_execution_priority, l_cmpr_param_combination_rec);
        --
        --
         IF (l_curr_param_combination_rec.usedTPGC) AND (l_cmpr_param_combination_rec.usedTPGC)
         THEN
             --
             --
             IF p_branch_curr_rec.TPGC_value <> p_branch_cmpr_rec.TPGC_value
             THEN
                 --
                 --
                 RETURN(FALSE);
                 --
                 --
             END IF;
             --
             --
         END IF;
        --
        --
         IF (l_curr_param_combination_rec.usedCUST) AND (l_cmpr_param_combination_rec.usedCUST)
         THEN
             --
             --
             IF p_branch_curr_rec.CUST_value <> p_branch_cmpr_rec.CUST_value
             THEN
                 --
                 --
                 RETURN(FALSE);
                 --
                 --
             END IF;
             --
             --
         END IF;
        --
        --
         IF (l_curr_param_combination_rec.usedSHIP) AND (l_cmpr_param_combination_rec.usedSHIP)
         THEN
             --
             --
             IF p_branch_curr_rec.SHIP_value <> p_branch_cmpr_rec.SHIP_value
             THEN
                 --
                 --
                 RETURN(FALSE);
                 --
                 --
             END IF;
             --
             --
         END IF;
        --
        --
         IF (l_curr_param_combination_rec.usedBILL) AND (l_cmpr_param_combination_rec.usedBILL)
         THEN
             --
             --
             IF p_branch_curr_rec.BILL_value <> p_branch_cmpr_rec.BILL_value
             THEN
                 --
                 --
                 RETURN(FALSE);
                 --
                 --
             END IF;
             --
             --
         END IF;
        --
        --
         IF (l_curr_param_combination_rec.usedISHP) AND (l_cmpr_param_combination_rec.usedISHP)
         THEN
             --
             --
             IF p_branch_curr_rec.ISHP_value <> p_branch_cmpr_rec.ISHP_value
             THEN
                 --
                 --
                 RETURN(FALSE);
                 --
                 --
             END IF;
             --
             --
         END IF;
        --
        --
        /* For all other conditions assume overlap exists */
        RETURN(TRUE);
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
            RAISE;
           --NULL;
    --}
    END  checkOverlapExists;
    --
    --
    /*========================================================================

       PROCEDURE NAME: switchLayerPositions

       PURPOSE: This switches the records between the two given positions
                in the global table. Used for the bubble sort process for
                assigning execution sequences.

    ========================================================================*/
    PROCEDURE
      switchLayerPositions(
               p_curr_tbl_position   IN NUMBER,
               p_cmpr_tbl_position   IN NUMBER )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'switchLayerPositions';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_curr_index BINARY_INTEGER;
        l_cmpr_index BINARY_INTEGER;
        l_temp_global_rec g_layer_branch_rec_type;
	--
	--
    BEGIN
    --{
        --
        --
        /* Save the second record in a temporary record  */
        l_temp_global_rec.layer_provider_code :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).layer_provider_code;
        l_temp_global_rec.layer_header_id :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).layer_header_id;
        l_temp_global_rec.layer_id :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).layer_id;
/*
        l_temp_global_rec.execution_sequence :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).execution_sequence;
*/
        l_temp_global_rec.active_flag :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).active_flag;
        l_temp_global_rec.tps_parameter1_name :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter1_name;
        l_temp_global_rec.tps_parameter1_value :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter1_value;
        l_temp_global_rec.tps_parameter2_name :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter2_name;
        l_temp_global_rec.tps_parameter2_value :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter2_value;
        l_temp_global_rec.tps_parameter3_name :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter3_name;
        l_temp_global_rec.tps_parameter3_value :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter3_value;
        l_temp_global_rec.tps_parameter4_name :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter4_name;
        l_temp_global_rec.tps_parameter4_value :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter4_value;
        l_temp_global_rec.tps_parameter5_name :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter5_name;
        l_temp_global_rec.tps_parameter5_value :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter5_value;
        l_temp_global_rec.tps_parameter6_name :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter6_name;
        l_temp_global_rec.tps_parameter6_value :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter6_value;
        l_temp_global_rec.tps_parameter7_name :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter7_name;
        l_temp_global_rec.tps_parameter7_value :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter7_value;
        l_temp_global_rec.tps_parameter8_name :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter8_name;
        l_temp_global_rec.tps_parameter8_value :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter8_value;
        l_temp_global_rec.tps_parameter9_name :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter9_name;
        l_temp_global_rec.tps_parameter9_value :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter9_value;
        l_temp_global_rec.tps_parameter10_name :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter10_name;
        l_temp_global_rec.tps_parameter10_value :=
                      g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter10_value;
        --
        --
        /* Copy the first record to the second record */
        g_layer_branch_tbl(p_cmpr_tbl_position).layer_provider_code :=
                      g_layer_branch_tbl(p_curr_tbl_position).layer_provider_code;
        g_layer_branch_tbl(p_cmpr_tbl_position).layer_header_id :=
                      g_layer_branch_tbl(p_curr_tbl_position).layer_header_id;
        g_layer_branch_tbl(p_cmpr_tbl_position).layer_id :=
                      g_layer_branch_tbl(p_curr_tbl_position).layer_id;
/*
        g_layer_branch_tbl(p_cmpr_tbl_position).execution_sequence :=
                      g_layer_branch_tbl(p_curr_tbl_position).execution_sequence;
*/
        g_layer_branch_tbl(p_cmpr_tbl_position).active_flag :=
                      g_layer_branch_tbl(p_curr_tbl_position).active_flag;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter1_name :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter1_name;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter1_value :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter1_value;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter2_name :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter2_name;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter2_value :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter2_value;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter3_name :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter3_name;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter3_value :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter3_value;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter4_name :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter4_name;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter4_value :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter4_value;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter5_name :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter5_name;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter5_value :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter5_value;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter6_name :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter6_name;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter6_value :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter6_value;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter7_name :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter7_name;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter7_value :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter7_value;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter8_name :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter8_name;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter8_value :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter8_value;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter9_name :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter9_name;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter9_value :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter9_value;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter10_name :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter10_name;
        g_layer_branch_tbl(p_cmpr_tbl_position).tps_parameter10_value :=
                      g_layer_branch_tbl(p_curr_tbl_position).tps_parameter10_value;
        --
        --
        /* Copy the temporary record to the first record */
        g_layer_branch_tbl(p_curr_tbl_position).layer_provider_code :=
                      l_temp_global_rec.layer_provider_code;
        g_layer_branch_tbl(p_curr_tbl_position).layer_header_id :=
                      l_temp_global_rec.layer_header_id;
        g_layer_branch_tbl(p_curr_tbl_position).layer_id :=
                      l_temp_global_rec.layer_id;
/*
        g_layer_branch_tbl(p_curr_tbl_position).execution_sequence :=
                      l_temp_global_rec.execution_sequence;
*/
        g_layer_branch_tbl(p_curr_tbl_position).active_flag :=
                      l_temp_global_rec.active_flag;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter1_name :=
                      l_temp_global_rec.tps_parameter1_name;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter1_value :=
                      l_temp_global_rec.tps_parameter1_value;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter2_name :=
                      l_temp_global_rec.tps_parameter2_name;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter2_value :=
                      l_temp_global_rec.tps_parameter2_value;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter3_name :=
                      l_temp_global_rec.tps_parameter3_name;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter3_value :=
                      l_temp_global_rec.tps_parameter3_value;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter4_name :=
                      l_temp_global_rec.tps_parameter4_name;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter4_value :=
                      l_temp_global_rec.tps_parameter4_value;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter5_name :=
                      l_temp_global_rec.tps_parameter5_name;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter5_value :=
                      l_temp_global_rec.tps_parameter5_value;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter6_name :=
                      l_temp_global_rec.tps_parameter6_name;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter6_value :=
                      l_temp_global_rec.tps_parameter6_value;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter7_name :=
                      l_temp_global_rec.tps_parameter7_name;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter7_value :=
                      l_temp_global_rec.tps_parameter7_value;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter8_name :=
                      l_temp_global_rec.tps_parameter8_name;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter8_value :=
                      l_temp_global_rec.tps_parameter8_value;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter9_name :=
                      l_temp_global_rec.tps_parameter9_name;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter9_value :=
                      l_temp_global_rec.tps_parameter9_value;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter10_name :=
                      l_temp_global_rec.tps_parameter10_name;
        g_layer_branch_tbl(p_curr_tbl_position).tps_parameter10_value :=
                      l_temp_global_rec.tps_parameter10_value;
        --
        --
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN

           RAISE;
           --NULL;
    --}
    END  switchLayerPositions;
    --
    --
    /*========================================================================

       PROCEDURE NAME: checkConflictingLayers

       PURPOSE: This checks whether the layers in the global table are
                conflicting layers, and if so assigns the appropriate execution
                sequence value and deactivates the conflicting layers.

    ========================================================================*/
    PROCEDURE
      checkConflictingLayers(
               p_package_name          IN vea_packages.name%TYPE,
               p_program_unit_name     IN vea_program_units.name%TYPE)
    IS
    --{
        temp  varchar2(200);
        l_api_name            CONSTANT VARCHAR2(30) := 'checkConflictingLayers';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_curr_index BINARY_INTEGER;
        l_cmpr_index BINARY_INTEGER;
        l_layer_count NUMBER := 0;
        l_execution_sequence NUMBER := 0;
        l_AnyConflictsDetected BOOLEAN := FALSE;
        l_SomeConflictsDetected BOOLEAN := FALSE;
	--
	--
        l_curr_branch_param_rec g_parameter_value_rec_type ;
        l_cmpr_branch_param_rec g_parameter_value_rec_type ;
	--
	--
    BEGIN
    --{
        l_layer_count := g_layer_branch_tbl.COUNT;
        --
        --
        FOR l_curr_index in 1..l_layer_count
        LOOP
        --{
            --
            --
            l_SomeConflictsDetected := FALSE;
            findBranchParameters(l_curr_index, l_curr_branch_param_rec);
            --
            --
            IF (g_layer_branch_tbl(l_curr_index).execution_sequence IS NULL)
            THEN
                l_execution_sequence := TRUNC(l_execution_sequence + 1);
            END IF;
            --
            --
            FOR l_cmpr_index in l_curr_index+1..l_layer_count
            LOOP
            --{
                --
                --
                findBranchParameters(l_cmpr_index, l_cmpr_branch_param_rec);
                --
                --
                IF (checkOverlapExists(l_curr_branch_param_rec, l_cmpr_branch_param_rec)) THEN
                --{
                    l_AnyConflictsDetected := TRUE;
                    l_SomeConflictsDetected := TRUE;


                    IF l_curr_branch_param_rec.execution_priority >=
                            l_cmpr_branch_param_rec.execution_priority THEN
                    --{
                        --
                        --
                        IF (g_layer_branch_tbl(l_curr_index).execution_sequence
                                IS NULL) THEN
                            l_execution_sequence := l_execution_sequence + 0.1;
                            g_layer_branch_tbl(l_curr_index).execution_sequence
                                                    := l_execution_sequence ;
                            g_layer_branch_tbl(l_curr_index).active_flag
                                                    := 'N' ;
                        END IF;
                        --
                        --
                        IF (g_layer_branch_tbl(l_cmpr_index).execution_sequence
                                IS NULL) THEN
                            l_execution_sequence := l_execution_sequence + 0.1;
                            g_layer_branch_tbl(l_cmpr_index).execution_sequence
                                                    := l_execution_sequence ;
                            g_layer_branch_tbl(l_cmpr_index).active_flag
                                                    := 'N' ;
                        END IF;
                    --}
                    ELSE
                    --{
                        --
                        --
                        switchLayerPositions(l_curr_index, l_cmpr_index);
                        findBranchParameters(l_curr_index, l_curr_branch_param_rec);
                        findBranchParameters(l_cmpr_index, l_cmpr_branch_param_rec);
                        --
                        IF (g_layer_branch_tbl(l_curr_index).execution_sequence
                                IS NULL) THEN
                            l_execution_sequence := l_execution_sequence + 0.1;
                            g_layer_branch_tbl(l_curr_index).execution_sequence
                                                    := l_execution_sequence ;
                            g_layer_branch_tbl(l_curr_index).active_flag
                                                    := 'N' ;
                        END IF;
                        --
                        --
                        IF (g_layer_branch_tbl(l_cmpr_index).execution_sequence
                                IS NULL) THEN
                            l_execution_sequence := l_execution_sequence + 0.1;
                            g_layer_branch_tbl(l_cmpr_index).execution_sequence
                                                    := l_execution_sequence ;
                            g_layer_branch_tbl(l_cmpr_index).active_flag
                                                    := 'N' ;
                        END IF;
                    --}
                    END IF;
                --}
                END IF;
            --}
            END LOOP;
            --
            IF NOT(l_SomeConflictsDetected) THEN
            --{
                --
                IF (g_layer_branch_tbl(l_curr_index).execution_sequence IS NULL) THEN
                    g_layer_branch_tbl(l_curr_index).execution_sequence
                                                    := l_execution_sequence ;
                    --
                END IF;
            --}
            END IF;
            --
        --}
        END LOOP;
        --
        --
	IF l_AnyConflictsDetected
	THEN
	--{
	    l_location := '0020';
	    --
	    vea_tpa_util_pvt.add_message
	    (
	        p_error_name => 'VEA_TP_LAYERS_CONFLICT',
	        p_token1     => 'PROGRAM_UNIT_NAME',
	        p_value1     => p_program_unit_name,
	        p_token2     => 'PACKAGE_NAME',
	        p_value2     => p_package_name
	    );
	    --
	END IF;
        --
        --
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
	   temp :=substr(sqlerrm,1,180);

           RAISE;
           --NULL;
    --}
    END  checkConflictingLayers;
    --
    --
    /*========================================================================

       PROCEDURE NAME: saveConflictDetails

       PURPOSE: This saves the execution sequence and the active flag details
                for each layer to the database.

    ========================================================================*/
    PROCEDURE
      saveConflictDetails (p_chkMultipleLayerProviders IN BOOLEAN)
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'saveConflictDetails';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_curr_index BINARY_INTEGER;
        l_cmpr_index BINARY_INTEGER;
        l_layer_count NUMBER := 0;
        l_layer_id vea_layers.layer_id%TYPE ;
	--
	--
	--
	--
    BEGIN
    --{
        l_layer_count := g_layer_branch_tbl.COUNT;
        --
        --
        FOR l_curr_index in 1..l_layer_count
        LOOP
        --{
            --
            --
            l_layer_id := g_layer_branch_tbl(l_curr_index).layer_id;

            IF ( p_chkMultipleLayerProviders ) THEN

                UPDATE VEA_LAYERS
                SET execution_sequence = g_layer_branch_tbl(l_curr_index).execution_sequence,
                    active_flag = nvl(g_layer_branch_tbl(l_curr_index).active_flag, active_flag)
                WHERE layer_id = l_layer_id
                AND layer_provider_code = g_layer_branch_tbl(l_curr_index).layer_provider_code;
                --
                --
            ELSE
                UPDATE VEA_LAYERS
                SET execution_sequence = g_layer_branch_tbl(l_curr_index).sequence_number
                WHERE layer_id = l_layer_id
                AND layer_provider_code = g_layer_branch_tbl(l_curr_index).layer_provider_code;
                --
                --
            END IF;
        --}
        END LOOP;
        --
        --
    --}
    EXCEPTION
    --{
        WHEN OTHERS THEN
           RAISE;
           --NULL;
    --}
    END  saveConflictDetails;
    --
    --
    /*========================================================================

       PROCEDURE NAME: processConflictingLayers

       PURPOSE: Called in the postProcess this procedure ensures that all
		conflicting layers are deactivated and the execution sequence
                is defaulted.

    ========================================================================*/
    PROCEDURE
      processConflictingLayers
        (
          p_tp_layer_id              IN     vea_tp_layers.tp_layer_id%TYPE ,
          p_layer_provider_code              IN     vea_layers.layer_provider_code%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'processConflictingLayers';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_program_unit_name	vea_program_units.name%TYPE;
        l_program_unit_id	vea_program_units.program_unit_id%TYPE;
        l_package_name		vea_packages.name%TYPE;
        l_package_id		vea_packages.package_id%TYPE;
        l_layer_provider_code	vea_packages.layer_provider_code%TYPE;
	--
	--
        l_lp_count                        NUMBER := 0;
        l_chkMultipleLayerProviders       BOOLEAN := FALSE;
	--
	--
	CURSOR program_unit_cur
	IS
	  SELECT distinct PU.name program_unit_name,
                 PU.program_unit_id ,
                 PK.name package_name ,
                 PK.package_id ,
                 PK.layer_provider_code
          FROM   vea_program_units PU,
		 vea_packages      PK,
                 vea_layer_headers LH,
                 vea_layers_v      LV
          WHERE  PU.tps_flag   = 'N'
	  AND    PU.layer_provider_code   = PK.layer_provider_code
	  AND    PU.package_id            = PK.package_id
	  AND    PU.layer_provider_code   = LH.program_unit_lp_code
          AND    PU.program_unit_id       = LH.program_unit_id
	  AND    LH.layer_provider_code   = LV.layer_provider_code
          AND    LH.layer_header_id       = LV.layer_header_id
          AND    LV.tp_layer_id           = NVL(p_tp_layer_id, LV.tp_layer_id)
          AND    LV.layer_provider_code   = p_layer_provider_code;
        --
        --
	/*CURSOR layer_cur
               ( p_program_unit_name  IN vea_program_units.name%TYPE,
                 p_package_name       IN vea_packages.name%TYPE)
	*/
	CURSOR layer_cur
               ( p_program_unit_id     IN vea_program_units.program_unit_id%TYPE,
                 p_package_id          IN vea_packages.package_id%TYPE,
                 p_layer_provider_code IN vea_packages.layer_provider_code%TYPE)
	IS
	  SELECT LA.sequence_number ,
	         LA.layer_provider_code,
		 LA.layer_id,
		 LA.layer_header_id,
		 LA.active_flag,
		 LA.tps_parameter1_id,
		 LA.tps_parameter1_value,
		 LA.tps_parameter2_id,
		 LA.tps_parameter2_value,
		 LA.tps_parameter3_id,
		 LA.tps_parameter3_value,
		 LA.tps_parameter4_id,
		 LA.tps_parameter4_value,
		 LA.tps_parameter5_id,
		 LA.tps_parameter5_value,
		 LA.tps_parameter6_id,
		 LA.tps_parameter6_value,
		 LA.tps_parameter7_id,
		 LA.tps_parameter7_value,
		 LA.tps_parameter8_id,
		 LA.tps_parameter8_value,
		 LA.tps_parameter9_id,
		 LA.tps_parameter9_value,
		 LA.tps_parameter10_id,
		 LA.tps_parameter10_value
          FROM   vea_layers        LA,
		 vea_layer_headers LH,
		 vea_program_units PU,
		 vea_packages      PK
          WHERE  PK.package_id		  = p_package_id
	  AND	 PK.layer_provider_code   = p_layer_provider_code
	  AND	 PK.package_id            = PU.package_id
	  AND    PK.layer_provider_code   = PU.layer_provider_code
	  AND    PU.program_unit_id       = p_program_unit_id
	  AND    PU.layer_provider_code   = LH.program_unit_lp_code
	  AND    PU.program_unit_id       = LH.program_unit_id
          AND    LH.layer_header_id       = LA.layer_header_id
          AND    LH.layer_provider_code   = LA.layer_provider_code
          ORDER BY LA.layer_provider_code, LA.sequence_number;


    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR program_unit_rec IN program_unit_cur
	LOOP
	--{
           g_layer_branch_tbl.DELETE;
           --
           l_program_unit_name		:= program_unit_rec.program_unit_name;
           l_program_unit_id		:= program_unit_rec.program_unit_id;
           l_package_name		:= program_unit_rec.package_name;
           l_package_id			:= program_unit_rec.package_id;
           l_layer_provider_code	:= program_unit_rec.layer_provider_code;

           l_lp_count := 0;
           l_chkMultipleLayerProviders := FALSE;

           SELECT count(distinct LA.layer_provider_code)
           INTO   l_lp_count
           FROM   vea_layers        LA,
                  vea_layer_headers LH,
                  vea_program_units PU,
                  vea_packages      PK
           WHERE  PK.package_id            = l_package_id
           AND    PK.layer_provider_code   = l_layer_provider_code
           AND    PK.package_id            = PU.package_id
           AND    PK.layer_provider_code   = PU.layer_provider_code
	   AND    PU.program_unit_id       = l_program_unit_id
           AND    PU.layer_provider_code   = LH.program_unit_lp_code
           AND    PU.program_unit_id       = LH.program_unit_id
           AND    LH.layer_header_id       = LA.layer_header_id
           AND    LH.layer_provider_code   = LA.layer_provider_code
           ORDER BY LA.layer_provider_code;

           IF l_lp_count > 1 THEN
              l_chkMultipleLayerProviders := TRUE;
           ELSE
              l_chkMultipleLayerProviders := FALSE;
           END IF;

	   FOR layer_rec IN layer_cur ( l_program_unit_id, l_package_id, l_layer_provider_code )
	   LOOP
	   --{
              saveBranchCriteria (
                p_layer_provider_code    => layer_rec.layer_provider_code,
                p_layer_id               => layer_rec.layer_id,
                p_layer_header_id        => layer_rec.layer_header_id,
                p_sequence_number        => layer_rec.sequence_number,
                p_active_flag            => layer_rec.active_flag,
                p_tps_parameter1_id      => layer_rec.tps_parameter1_id,
                p_tps_parameter1_value   => layer_rec.tps_parameter1_value,
                p_tps_parameter2_id      => layer_rec.tps_parameter2_id,
                p_tps_parameter2_value   => layer_rec.tps_parameter2_value,
                p_tps_parameter3_id      => layer_rec.tps_parameter3_id,
                p_tps_parameter3_value   => layer_rec.tps_parameter3_value,
                p_tps_parameter4_id      => layer_rec.tps_parameter4_id,
                p_tps_parameter4_value   => layer_rec.tps_parameter4_value,
                p_tps_parameter5_id      => layer_rec.tps_parameter5_id,
                p_tps_parameter5_value   => layer_rec.tps_parameter5_value,
                p_tps_parameter6_id      => layer_rec.tps_parameter6_id,
                p_tps_parameter6_value   => layer_rec.tps_parameter6_value,
                p_tps_parameter7_id      => layer_rec.tps_parameter7_id,
                p_tps_parameter7_value   => layer_rec.tps_parameter7_value,
                p_tps_parameter8_id      => layer_rec.tps_parameter8_id,
                p_tps_parameter8_value   => layer_rec.tps_parameter8_value,
                p_tps_parameter9_id      => layer_rec.tps_parameter9_id,
                p_tps_parameter9_value   => layer_rec.tps_parameter9_value,
                p_tps_parameter10_id     => layer_rec.tps_parameter10_id,
                p_tps_parameter10_value  => layer_rec.tps_parameter10_value
	      );
            --
            --
	    --}
	    END LOOP;
            --
            --
            IF l_chkMultipleLayerProviders THEN
                --
                --
                checkConflictingLayers(l_package_name, l_program_unit_name);
                --
                --
            END IF;
            --
            --
            saveConflictDetails(l_chkMultipleLayerProviders);
            --
            --
	--}
	END LOOP;
    --}
    EXCEPTION
    --{
	WHEN FND_API.G_EXC_ERROR
	THEN
	--{
	    RAISE;
	--}
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END processConflictingLayers;
    --
    --
    /*========================================================================

       PROCEDURE NAME: validateUniqueBranchSequence

       PURPOSE: Validates that all branches within a public program unit are
		assigned unique sequence numbers.

    ========================================================================*/
    PROCEDURE
      validateUniqueBranchSequence
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_id              IN     vea_layers.layer_id%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
          p_sequence_number       IN     vea_layers.sequence_number%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'validateUniqueBranchSequence';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
	CURSOR layer_cur
	IS
	  SELECT LA.layer_provider_code,
		 LA.layer_id,
		 PU.name program_unit_name,
		 PK.name package_name
          FROM   vea_layer_headers LH,
		 vea_program_units TPA,
		 vea_packages      PK,
		 vea_program_units PU,
		 vea_layers        LA,
		 vea_layer_headers LH1
          WHERE  LH.layer_provider_code   = p_layer_provider_code
          AND    LH.layer_header_id       = p_layer_header_id
	  AND    TPA.layer_provider_code  = LH.program_unit_lp_code
	  AND    TPA.program_unit_id      = LH.program_unit_id
	  AND    PU.layer_provider_code   = TPA.layer_provider_code
	  AND    PU.program_unit_id       = TPA.tpa_program_unit_id
	  AND    PK.layer_provider_code   = PU.layer_provider_code
	  AND    PK.package_id            = PU.package_id
	  AND    LH1.program_unit_id      = TPA.program_unit_id
	  AND    LH1.program_unit_lp_code = TPA.layer_provider_code
	  AND    LA.layer_provider_code   = LH1.layer_provider_code
	  AND    LA.layer_header_id       = LH1.layer_header_id
	  AND    LA.sequence_number       = p_sequence_number;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR layer_rec IN layer_cur
	LOOP
	--{
	    IF layer_rec.layer_provider_code <> p_layer_provider_code
	    OR layer_rec.layer_id            <> p_layer_id
	    THEN
	    --{
	        l_location := '0020';
	        --
	        vea_tpa_util_pvt.add_message_and_raise
	          (
	            p_error_name => 'VEA_LM_UNIQ_BRANCH_SEQ',
	            p_token1     => 'PROGRAM_UNIT_NAME',
	            p_value1     => layer_rec.program_unit_name,
	            p_token2     => 'PACKAGE_NAME',
	            p_value2     => layer_rec.package_name,
	            p_token3     => 'LAYER_PROVIDER_CODE',
	            p_value3     => layer_rec.layer_provider_code
	          );
	    --}
	    END IF;
	--}
	END LOOP;
    --}
    EXCEPTION
    --{
	WHEN FND_API.G_EXC_ERROR
	THEN
	--{
	    RAISE;
	--}
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END validateUniqueBranchSequence;
    --
    --
    /*========================================================================

       PROCEDURE NAME: validate

       PURPOSE: Validates a record in VEA_LAYERS table

    ========================================================================*/
    PROCEDURE
      validate
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_id              IN     vea_layers.layer_id%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
          p_new_program_unit_id   IN     vea_layers.new_program_unit_id%TYPE,
          p_program_unit_lp_code  IN     vea_layers.program_unit_lp_code%TYPE,
          p_sequence_number       IN     vea_layers.sequence_number%TYPE,
          p_description           IN     vea_layers.description%TYPE,
          p_active_flag           IN     vea_layers.active_flag%TYPE,
	  p_tps_parameter1_id     IN     vea_layers.tps_parameter1_id%TYPE,
	  p_tps_parameter1_value  IN     vea_layers.tps_parameter1_value%TYPE,
	  p_tps_parameter2_id     IN     vea_layers.tps_parameter2_id%TYPE,
	  p_tps_parameter2_value  IN     vea_layers.tps_parameter2_value%TYPE,
	  p_tps_parameter3_id     IN     vea_layers.tps_parameter3_id%TYPE,
	  p_tps_parameter3_value  IN     vea_layers.tps_parameter3_value%TYPE,
	  p_tps_parameter4_id     IN     vea_layers.tps_parameter4_id%TYPE,
	  p_tps_parameter4_value  IN     vea_layers.tps_parameter4_value%TYPE,
	  p_tps_parameter5_id     IN     vea_layers.tps_parameter5_id%TYPE,
	  p_tps_parameter5_value  IN     vea_layers.tps_parameter5_value%TYPE,
	  p_tps_parameter6_id     IN     vea_layers.tps_parameter6_id%TYPE,
	  p_tps_parameter6_value  IN     vea_layers.tps_parameter6_value%TYPE,
	  p_tps_parameter7_id     IN     vea_layers.tps_parameter7_id%TYPE,
	  p_tps_parameter7_value  IN     vea_layers.tps_parameter7_value%TYPE,
	  p_tps_parameter8_id     IN     vea_layers.tps_parameter8_id%TYPE,
	  p_tps_parameter8_value  IN     vea_layers.tps_parameter8_value%TYPE,
	  p_tps_parameter9_id     IN     vea_layers.tps_parameter9_id%TYPE,
	  p_tps_parameter9_value  IN     vea_layers.tps_parameter9_value%TYPE,
	  p_tps_parameter10_id    IN     vea_layers.tps_parameter10_id%TYPE,
	  p_tps_parameter10_value IN     vea_layers.tps_parameter10_value%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'validate';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF vea_tpa_util_pvt.validate
	THEN
	--{
	    l_location := '0020';
	    --
/*
	    validateUniqueBranchSequence
	      (
                p_layer_provider_code    => p_layer_provider_code,
                p_layer_id               => p_layer_id,
                p_layer_header_id        => p_layer_header_id,
                p_sequence_number        => p_sequence_number
	      );
*/
	--}
	END IF;
    --}
    EXCEPTION
    --{
	WHEN FND_API.G_EXC_ERROR
	THEN
	--{
	    RAISE;
	--}
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END validate;
    --
    --
    /*========================================================================

       PROCEDURE NAME: insert_row

       PURPOSE: Inserts a record into VEA_LAYERS table

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_id              IN     vea_layers.layer_id%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
          p_new_program_unit_id   IN     vea_layers.new_program_unit_id%TYPE,
          p_program_unit_lp_code  IN     vea_layers.program_unit_lp_code%TYPE,
          p_sequence_number       IN     vea_layers.sequence_number%TYPE,
          p_description           IN     vea_layers.description%TYPE,
          p_active_flag           IN     vea_layers.active_flag%TYPE,
	  p_tps_parameter1_id     IN     vea_layers.tps_parameter1_id%TYPE,
	  p_tps_parameter1_value  IN     vea_layers.tps_parameter1_value%TYPE,
	  p_tps_parameter2_id     IN     vea_layers.tps_parameter2_id%TYPE,
	  p_tps_parameter2_value  IN     vea_layers.tps_parameter2_value%TYPE,
	  p_tps_parameter3_id     IN     vea_layers.tps_parameter3_id%TYPE,
	  p_tps_parameter3_value  IN     vea_layers.tps_parameter3_value%TYPE,
	  p_tps_parameter4_id     IN     vea_layers.tps_parameter4_id%TYPE,
	  p_tps_parameter4_value  IN     vea_layers.tps_parameter4_value%TYPE,
	  p_tps_parameter5_id     IN     vea_layers.tps_parameter5_id%TYPE,
	  p_tps_parameter5_value  IN     vea_layers.tps_parameter5_value%TYPE,
	  p_tps_parameter6_id     IN     vea_layers.tps_parameter6_id%TYPE,
	  p_tps_parameter6_value  IN     vea_layers.tps_parameter6_value%TYPE,
	  p_tps_parameter7_id     IN     vea_layers.tps_parameter7_id%TYPE,
	  p_tps_parameter7_value  IN     vea_layers.tps_parameter7_value%TYPE,
	  p_tps_parameter8_id     IN     vea_layers.tps_parameter8_id%TYPE,
	  p_tps_parameter8_value  IN     vea_layers.tps_parameter8_value%TYPE,
	  p_tps_parameter9_id     IN     vea_layers.tps_parameter9_id%TYPE,
	  p_tps_parameter9_value  IN     vea_layers.tps_parameter9_value%TYPE,
	  p_tps_parameter10_id    IN     vea_layers.tps_parameter10_id%TYPE,
	  p_tps_parameter10_value IN     vea_layers.tps_parameter10_value%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'insert_row';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
        INSERT INTO vea_layers
          (
            layer_provider_code, layer_id,
            layer_header_id,
            new_program_unit_id, program_unit_lp_code,
            sequence_number,
            description,
	    active_flag,
	    tps_parameter1_id, tps_parameter1_value,
	    tps_parameter2_id, tps_parameter2_value,
	    tps_parameter3_id, tps_parameter3_value,
	    tps_parameter4_id, tps_parameter4_value,
	    tps_parameter5_id, tps_parameter5_value,
	    tps_parameter6_id, tps_parameter6_value,
	    tps_parameter7_id, tps_parameter7_value,
	    tps_parameter8_id, tps_parameter8_value,
	    tps_parameter9_id, tps_parameter9_value,
	    tps_parameter10_id, tps_parameter10_value,
            created_by, creation_date,
            last_updated_by, last_update_date,
            last_update_login
          )
        VALUES
          (
            p_layer_provider_code, p_layer_id,
            p_layer_header_id,
            p_new_program_unit_id, p_program_unit_lp_code,
            p_sequence_number,
            p_description,
	    p_active_flag,
	    p_tps_parameter1_id, p_tps_parameter1_value,
	    p_tps_parameter2_id, p_tps_parameter2_value,
	    p_tps_parameter3_id, p_tps_parameter3_value,
	    p_tps_parameter4_id, p_tps_parameter4_value,
	    p_tps_parameter5_id, p_tps_parameter5_value,
	    p_tps_parameter6_id, p_tps_parameter6_value,
	    p_tps_parameter7_id, p_tps_parameter7_value,
	    p_tps_parameter8_id, p_tps_parameter8_value,
	    p_tps_parameter9_id, p_tps_parameter9_value,
	    p_tps_parameter10_id, p_tps_parameter10_value,
            l_user_id, SYSDATE,
            l_user_id, SYSDATE,
            l_login_id
          );
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END insert_row;
    --
    --
    /*========================================================================

       PROCEDURE NAME: update_row

       PURPOSE: Updates a record into VEA_LAYERS table

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_id              IN     vea_layers.layer_id%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
          p_new_program_unit_id   IN     vea_layers.new_program_unit_id%TYPE,
          p_program_unit_lp_code  IN     vea_layers.program_unit_lp_code%TYPE,
          p_sequence_number       IN     vea_layers.sequence_number%TYPE,
          p_description           IN     vea_layers.description%TYPE,
          p_active_flag           IN     vea_layers.active_flag%TYPE,
	  p_tps_parameter1_id     IN     vea_layers.tps_parameter1_id%TYPE,
	  p_tps_parameter1_value  IN     vea_layers.tps_parameter1_value%TYPE,
	  p_tps_parameter2_id     IN     vea_layers.tps_parameter2_id%TYPE,
	  p_tps_parameter2_value  IN     vea_layers.tps_parameter2_value%TYPE,
	  p_tps_parameter3_id     IN     vea_layers.tps_parameter3_id%TYPE,
	  p_tps_parameter3_value  IN     vea_layers.tps_parameter3_value%TYPE,
	  p_tps_parameter4_id     IN     vea_layers.tps_parameter4_id%TYPE,
	  p_tps_parameter4_value  IN     vea_layers.tps_parameter4_value%TYPE,
	  p_tps_parameter5_id     IN     vea_layers.tps_parameter5_id%TYPE,
	  p_tps_parameter5_value  IN     vea_layers.tps_parameter5_value%TYPE,
	  p_tps_parameter6_id     IN     vea_layers.tps_parameter6_id%TYPE,
	  p_tps_parameter6_value  IN     vea_layers.tps_parameter6_value%TYPE,
	  p_tps_parameter7_id     IN     vea_layers.tps_parameter7_id%TYPE,
	  p_tps_parameter7_value  IN     vea_layers.tps_parameter7_value%TYPE,
	  p_tps_parameter8_id     IN     vea_layers.tps_parameter8_id%TYPE,
	  p_tps_parameter8_value  IN     vea_layers.tps_parameter8_value%TYPE,
	  p_tps_parameter9_id     IN     vea_layers.tps_parameter9_id%TYPE,
	  p_tps_parameter9_value  IN     vea_layers.tps_parameter9_value%TYPE,
	  p_tps_parameter10_id    IN     vea_layers.tps_parameter10_id%TYPE,
	  p_tps_parameter10_value IN     vea_layers.tps_parameter10_value%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'update_row';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
        UPDATE vea_layers
        SET    new_program_unit_id          = p_new_program_unit_id,
               program_unit_lp_code         = p_program_unit_lp_code,
               layer_header_id              = p_layer_header_id,
               sequence_number              = p_sequence_number,
               description                  = p_description,
	       active_flag                  = p_active_flag,
	       tps_parameter1_id            = p_tps_parameter1_id,
	       tps_parameter1_value         = p_tps_parameter1_value,
	       tps_parameter2_id            = p_tps_parameter2_id,
	       tps_parameter2_value         = p_tps_parameter2_value,
	       tps_parameter3_id            = p_tps_parameter3_id,
	       tps_parameter3_value         = p_tps_parameter3_value,
	       tps_parameter4_id            = p_tps_parameter4_id,
	       tps_parameter4_value         = p_tps_parameter4_value,
	       tps_parameter5_id            = p_tps_parameter5_id,
	       tps_parameter5_value         = p_tps_parameter5_value,
	       tps_parameter6_id            = p_tps_parameter6_id,
	       tps_parameter6_value         = p_tps_parameter6_value,
	       tps_parameter7_id            = p_tps_parameter7_id,
	       tps_parameter7_value         = p_tps_parameter7_value,
	       tps_parameter8_id            = p_tps_parameter8_id,
	       tps_parameter8_value         = p_tps_parameter8_value,
	       tps_parameter9_id            = p_tps_parameter9_id,
	       tps_parameter9_value         = p_tps_parameter9_value,
	       tps_parameter10_id           = p_tps_parameter10_id,
	       tps_parameter10_value        = p_tps_parameter10_value,
               last_updated_by              = l_user_id,
               last_update_date             = SYSDATE,
               last_update_login            = l_login_id
        WHERE  layer_provider_code          = p_layer_provider_code
        AND    layer_id                     = p_layer_id;
        --AND    layer_header_id              = p_layer_header_id;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END update_row;
    --
    --
    /*========================================================================

       PROCEDURE NAME: delete_row

       PURPOSE: Deletes the specified layer

    ========================================================================*/
    PROCEDURE
      delete_row
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_id              IN     vea_layers.layer_id%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'delete_row';
        l_location            VARCHAR2(32767);
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
        DELETE vea_layers
        WHERE  layer_provider_code          = p_layer_provider_code
        AND    layer_id                     = p_layer_id;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END delete_row;
    --
    --
    /*========================================================================

       PROCEDURE NAME: delete_rows

       PURPOSE: Deletes layers belonging to specified layer header and specified
		TP layer.

    ========================================================================*/
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
          p_tp_layer_id           IN     vea_tp_layers.tp_layer_id%TYPE,
	  x_layer_count           OUT NOCOPY     NUMBER
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'delete_rows';
        l_location            VARCHAR2(32767);
	--
	--
	CURSOR layer_cur
                 (
                   p_layer_provider_code  IN  vea_layers.layer_provider_code%TYPE,
                   p_layer_header_id      IN  vea_layers.layer_header_id%TYPE
                 )
        IS
          SELECT layer_id, tp_layer_id
          FROM   vea_layers_v
          WHERE  layer_provider_code   = p_layer_provider_code
          AND    layer_header_id       = p_layer_header_id;
       --
       --
       l_layer_count NUMBER := 0;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	l_layer_count := 0;
	--
	--
	l_location := '0020';
	--
	FOR layer_rec IN layer_cur
			   (
			     p_layer_provider_code => p_layer_provider_code,
			     p_layer_header_id     => p_layer_header_id
			   )
	LOOP
	--{
	    l_location := '0030';
	    --
	    IF layer_rec.tp_layer_id = p_tp_layer_id
	    THEN
	    --{
	        l_location := '0040';
	        --
	        delete_row
	          (
		    p_layer_provider_code => p_layer_provider_code,
		    p_layer_id            => layer_rec.layer_id
	          );
	    --}
	    ELSE
	    --{
	        l_location := '0050';
	        --
		l_layer_count := l_layer_count + 1;
	    --}
	    END IF;
	--}
	END LOOP;
	--
	--
	l_location := '0060';
	--
	x_layer_count := NVL(l_layer_count,0);
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END delete_rows;
    --
    --
    /*========================================================================

       PROCEDURE NAME: populateLayerActiveTable

       PURPOSE: Queries all layers developed by the specified layer provider
		code and stores them in a PL/SQL table (layer cache)

		This procedure is used at the beginning of layer merge to
		record active/inactive status of each layer.

		Later, as each layer is imported from the flat file, its
		active/inactive status is copied from layer cache to the
		flat file record and updated back into the database.

    ========================================================================*/
    PROCEDURE
      populateLayerActiveTable
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'populateLayerActiveTable';
        l_location            VARCHAR2(32767);
        --
        --
	CURSOR layer_cur
	IS
	  SELECT distinct
		 PU.program_unit_id,
		 PU.layer_provider_code,
		 LA.tp_layer_id,
		 LA.tp_layer_name,
		 LA.active_flag
          FROM   vea_layers_v LA,
		 vea_layer_headers LH,
		 vea_program_units PU
	  WHERE  LA.layer_provider_code = p_layer_provider_code
	  AND    LH.layer_provider_code = LA.layer_provider_code
	  AND    LH.layer_header_id     = LA.layer_header_id
	  AND    PU.layer_provider_code = LH.program_unit_lp_code
	  AND    PU.program_unit_id     = LH.program_unit_id
	  order by tp_layer_id;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	g_layer_active_tbl.DELETE;
	--
	--
	l_location := '0020';
	--
	FOR layer_rec IN layer_cur
	LOOP
	--{
	    l_location := '0030';
	    --
	    g_layer_active_tbl( g_layer_active_tbl.COUNT+1) := layer_rec;
	--}
	END LOOP;
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END populateLayerActiveTable;
    --
    --
    /*========================================================================

       PROCEDURE NAME: isLayerActive

       PURPOSE: Searches the layer cache and returns active/inactive status
		for the specified layer.

		If the specified layer is not found in the layer cache,
		it is considered as active.

    ========================================================================*/
    FUNCTION
      isLayerActive
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_tp_layer_id           IN     vea_tp_layers.tp_layer_id%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE
        )
    RETURN VARCHAR2
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'isLayerActive';
        l_location            VARCHAR2(32767);
	--
	--
	l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
	l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
	CURSOR layer_cur
	IS
	  SELECT TLA.tp_layer_id,
		 TLA.name tp_layer_name,
		 LH.program_unit_id,
		 LH.program_unit_lp_code
	  FROM   vea_layer_headers LH,
		 vea_tp_layers TLA
	  WHERE  LH.layer_provider_code   = p_layer_provider_code
	  AND    LH.layer_header_id       = p_layer_header_id
	  AND    TLA.layer_provider_code  = p_layer_provider_code
	  AND    TLA.tp_layer_id          = p_tp_layer_id
	  order by TLA.tp_layer_id;
	--
	--
	l_layer_active_rec g_layer_active_rec_type;
	--
	--
	l_index NUMBER;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR layer_rec IN layer_cur
	LOOP
	--{
	    l_location := '0020';
	    --
	    l_index := vea_layers_sv.g_layer_active_tbl.FIRST;
	    --
	    --
	    l_location := '0030';
	    --
	    WHILE l_index IS NOT NULL
	    LOOP
	    --{
	        l_location := '0040';
	        --
	        l_layer_active_rec := vea_layers_sv.g_layer_active_tbl(l_index);
	        --
	        --
	        l_location := '0050';
	        --
	        IF  l_layer_active_rec.program_unit_id = layer_rec.program_unit_id
	        AND l_layer_active_rec.program_unit_lp_code = layer_rec.program_unit_lp_code
		AND (
		        --l_layer_active_rec.tp_layer_id   = layer_rec.tp_layer_id
	             --OR
		     l_layer_active_rec.tp_layer_name = layer_rec.tp_layer_name
		    )
	        THEN
	        --{
	            l_location := '0030';
	            --
		    RETURN( l_layer_active_rec.active_flag );
	        --}
	        END IF;
	        --
	        --
	        l_location := '0060';
	        --
	        l_index := vea_layers_sv.g_layer_active_tbl.NEXT(l_index);
	    --}
	    END LOOP;
	--}
	END LOOP;
	--
	--
	l_location := '0070';
	--
	RETURN('Y');
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END isLayerActive;
    --
    --
    /*========================================================================

       PROCEDURE NAME: process_code_conversion

       PURPOSE: Processes branch criteria values for code conversion.

		For each branch criteria value,
		 - maps parameter name to the EDI code conversion category.
		 - inserts EDI code conversion category, if not existing.
		 - inserts/updates EDI code conversion value within the
		   category.

    ========================================================================*/
    PROCEDURE
      process_code_conversion
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_layer_header_id       IN     vea_layers.layer_header_id%TYPE,
	  p_tps_parameter1_id     IN     vea_layers.tps_parameter1_id%TYPE,
	  p_tps_parameter1_value  IN     vea_layers.tps_parameter1_value%TYPE,
	  p_tps_parameter2_id     IN     vea_layers.tps_parameter2_id%TYPE,
	  p_tps_parameter2_value  IN     vea_layers.tps_parameter2_value%TYPE,
	  p_tps_parameter3_id     IN     vea_layers.tps_parameter3_id%TYPE,
	  p_tps_parameter3_value  IN     vea_layers.tps_parameter3_value%TYPE,
	  p_tps_parameter4_id     IN     vea_layers.tps_parameter4_id%TYPE,
	  p_tps_parameter4_value  IN     vea_layers.tps_parameter4_value%TYPE,
	  p_tps_parameter5_id     IN     vea_layers.tps_parameter5_id%TYPE,
	  p_tps_parameter5_value  IN     vea_layers.tps_parameter5_value%TYPE,
	  p_tps_parameter6_id     IN     vea_layers.tps_parameter6_id%TYPE,
	  p_tps_parameter6_value  IN     vea_layers.tps_parameter6_value%TYPE,
	  p_tps_parameter7_id     IN     vea_layers.tps_parameter7_id%TYPE,
	  p_tps_parameter7_value  IN     vea_layers.tps_parameter7_value%TYPE,
	  p_tps_parameter8_id     IN     vea_layers.tps_parameter8_id%TYPE,
	  p_tps_parameter8_value  IN     vea_layers.tps_parameter8_value%TYPE,
	  p_tps_parameter9_id     IN     vea_layers.tps_parameter9_id%TYPE,
	  p_tps_parameter9_value  IN     vea_layers.tps_parameter9_value%TYPE,
	  p_tps_parameter10_id    IN     vea_layers.tps_parameter10_id%TYPE,
	  p_tps_parameter10_value IN     vea_layers.tps_parameter10_value%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'process_code_conversion';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
        vea_tpa_util_pvt.process_code_conversion
	  (
            p_layer_provider_code   => p_layer_provider_code,
            p_layer_header_id       => p_layer_header_id,
	    p_tps_parameter_id      => p_tps_parameter1_id,
	    p_tps_parameter_value   => p_tps_parameter1_value
	  );
	--
	--
	l_location := '0020';
	--
        vea_tpa_util_pvt.process_code_conversion
	  (
            p_layer_provider_code   => p_layer_provider_code,
            p_layer_header_id       => p_layer_header_id,
	    p_tps_parameter_id      => p_tps_parameter2_id,
	    p_tps_parameter_value   => p_tps_parameter2_value
	  );
	--
	--
	l_location := '0030';
	--
        vea_tpa_util_pvt.process_code_conversion
	  (
            p_layer_provider_code   => p_layer_provider_code,
            p_layer_header_id       => p_layer_header_id,
	    p_tps_parameter_id      => p_tps_parameter3_id,
	    p_tps_parameter_value   => p_tps_parameter3_value
	  );
	--
	--
	l_location := '0040';
	--
        vea_tpa_util_pvt.process_code_conversion
	  (
            p_layer_provider_code   => p_layer_provider_code,
            p_layer_header_id       => p_layer_header_id,
	    p_tps_parameter_id      => p_tps_parameter4_id,
	    p_tps_parameter_value   => p_tps_parameter4_value
	  );
	--
	--
	l_location := '0050';
	--
        vea_tpa_util_pvt.process_code_conversion
	  (
            p_layer_provider_code   => p_layer_provider_code,
            p_layer_header_id       => p_layer_header_id,
	    p_tps_parameter_id      => p_tps_parameter5_id,
	    p_tps_parameter_value   => p_tps_parameter5_value
	  );
	--
	--
	l_location := '0060';
	--
        vea_tpa_util_pvt.process_code_conversion
	  (
            p_layer_provider_code   => p_layer_provider_code,
            p_layer_header_id       => p_layer_header_id,
	    p_tps_parameter_id      => p_tps_parameter6_id,
	    p_tps_parameter_value   => p_tps_parameter6_value
	  );
	--
	--
	l_location := '0070';
	--
        vea_tpa_util_pvt.process_code_conversion
	  (
            p_layer_provider_code   => p_layer_provider_code,
            p_layer_header_id       => p_layer_header_id,
	    p_tps_parameter_id      => p_tps_parameter7_id,
	    p_tps_parameter_value   => p_tps_parameter7_value
	  );
	--
	--
	l_location := '0080';
	--
        vea_tpa_util_pvt.process_code_conversion
	  (
            p_layer_provider_code   => p_layer_provider_code,
            p_layer_header_id       => p_layer_header_id,
	    p_tps_parameter_id      => p_tps_parameter8_id,
	    p_tps_parameter_value   => p_tps_parameter8_value
	  );
	--
	--
	l_location := '0090';
	--
        vea_tpa_util_pvt.process_code_conversion
	  (
            p_layer_provider_code   => p_layer_provider_code,
            p_layer_header_id       => p_layer_header_id,
	    p_tps_parameter_id      => p_tps_parameter9_id,
	    p_tps_parameter_value   => p_tps_parameter9_value
	  );
	--
	--
	l_location := '0100';
	--
        vea_tpa_util_pvt.process_code_conversion
	  (
            p_layer_provider_code   => p_layer_provider_code,
            p_layer_header_id       => p_layer_header_id,
	    p_tps_parameter_id      => p_tps_parameter10_id,
	    p_tps_parameter_value   => p_tps_parameter10_value
	  );
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    vea_tpa_util_pvt.add_exc_message_and_raise
	      (
		p_package_name => G_PACKAGE_NAME,
		p_api_name     => l_api_name,
		p_location     => l_location
	      );
	--}
    --}
    END process_code_conversion;
    --
    --
    /*========================================================================

       PROCEDURE NAME: process

       PURPOSE: Table hadndler API for VEA_LAYERS table.

		It inserts/updates a record in VEA_LAYERS table.

    ========================================================================*/
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
	  p_tps_parameter2_id     IN     vea_layers.tps_parameter2_id%TYPE ,
	  p_tps_parameter2_value  IN     vea_layers.tps_parameter2_value%TYPE ,
	  p_tps_parameter3_id     IN     vea_layers.tps_parameter3_id%TYPE ,
	  p_tps_parameter3_value  IN     vea_layers.tps_parameter3_value%TYPE ,
	  p_tps_parameter4_id     IN     vea_layers.tps_parameter4_id%TYPE ,
	  p_tps_parameter4_value  IN     vea_layers.tps_parameter4_value%TYPE ,
	  p_tps_parameter5_id     IN     vea_layers.tps_parameter5_id%TYPE ,
	  p_tps_parameter5_value  IN     vea_layers.tps_parameter5_value%TYPE ,
	  p_tps_parameter6_id     IN     vea_layers.tps_parameter6_id%TYPE ,
	  p_tps_parameter6_value  IN     vea_layers.tps_parameter6_value%TYPE ,
	  p_tps_parameter7_id     IN     vea_layers.tps_parameter7_id%TYPE ,
	  p_tps_parameter7_value  IN     vea_layers.tps_parameter7_value%TYPE ,
	  p_tps_parameter8_id     IN     vea_layers.tps_parameter8_id%TYPE ,
	  p_tps_parameter8_value  IN     vea_layers.tps_parameter8_value%TYPE ,
	  p_tps_parameter9_id     IN     vea_layers.tps_parameter9_id%TYPE ,
	  p_tps_parameter9_value  IN     vea_layers.tps_parameter9_value%TYPE ,
	  p_tps_parameter10_id    IN     vea_layers.tps_parameter10_id%TYPE ,
	  p_tps_parameter10_value IN     vea_layers.tps_parameter10_value%TYPE ,
          p_id                    IN     vea_layers.layer_id%TYPE   := NULL,
          p_tp_layer_id           IN     vea_tp_layers.tp_layer_id%TYPE   := NULL,
          p_tp_layer_name         IN     vea_tp_layers.name%TYPE,
	  p_tps_parameter1_name   IN     vea_parameters.name%TYPE,
	  p_tps_parameter2_name   IN     vea_parameters.name%TYPE,
	  p_tps_parameter3_name   IN     vea_parameters.name%TYPE,
	  p_tps_parameter4_name   IN     vea_parameters.name%TYPE,
	  p_tps_parameter5_name   IN     vea_parameters.name%TYPE,
	  p_tps_parameter6_name   IN     vea_parameters.name%TYPE,
	  p_tps_parameter7_name   IN     vea_parameters.name%TYPE,
	  p_tps_parameter8_name   IN     vea_parameters.name%TYPE,
	  p_tps_parameter9_name   IN     vea_parameters.name%TYPE,
	  p_tps_parameter10_name  IN     vea_parameters.name%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'PROCESS';
        l_api_version         CONSTANT NUMBER       := 1.0;
        l_api_type            CONSTANT VARCHAR2(3)  := vea_tpa_util_pvt.G_PUBLIC_API;
        --
        --
        l_location            VARCHAR2(32767);
        l_savepoint_name      VARCHAR2(30);
        l_layer_id            vea_layers.layer_id%TYPE;
        l_active_flag         vea_layers.active_flag%TYPE;
        l_layer_header_id     vea_layers.layer_header_id%TYPE;
        l_tp_layer_id         vea_tp_layers.tp_layer_id%TYPE;
        l_new_program_unit_id vea_program_units.program_unit_id%TYPE;
        l_tps_parameter1_id   vea_layers.tps_parameter1_id%TYPE;
        l_tps_parameter2_id   vea_layers.tps_parameter2_id%TYPE;
        l_tps_parameter3_id   vea_layers.tps_parameter3_id%TYPE;
        l_tps_parameter4_id   vea_layers.tps_parameter4_id%TYPE;
        l_tps_parameter5_id   vea_layers.tps_parameter5_id%TYPE;
        l_tps_parameter6_id   vea_layers.tps_parameter6_id%TYPE;
        l_tps_parameter7_id   vea_layers.tps_parameter7_id%TYPE;
        l_tps_parameter8_id   vea_layers.tps_parameter8_id%TYPE;
        l_tps_parameter9_id   vea_layers.tps_parameter9_id%TYPE;
        l_tps_parameter10_id  vea_layers.tps_parameter10_id%TYPE;
        l_tps_program_unit_id vea_layer_headers.tps_program_unit_id%TYPE;
        l_tps_program_unit_lp_code vea_layer_headers.tps_program_unit_lp_code%TYPE;
        --
        --
        CURSOR layer_cur
                 (
                   p_layer_provider_code   IN  vea_layers.layer_provider_code%TYPE,
                   p_tp_layer_id           IN  vea_tp_layers.name%TYPE,
                   p_new_program_unit_id   IN  vea_program_units.name%TYPE
                 )
        IS
          SELECT LA.LAYER_ID LAYER_ID
          FROM   vea_layers LA,
                 VEA_TP_LAYERS TL,
                 VEA_PROGRAM_UNITS PU,
                 VEA_PACKAGES PK
          WHERE  TL.TP_LAYER_ID         = p_tp_layer_id
          AND    TL.TP_LAYER_ID         = PK.TP_LAYER_ID
          AND    TL.LAYER_PROVIDER_CODE = p_layer_provider_code
          AND    TL.LAYER_PROVIDER_CODE = PK.LAYER_PROVIDER_CODE
          AND    PK.PACKAGE_ID          = PU.PACKAGE_ID
          AND    PK.LAYER_PROVIDER_CODE = PU.LAYER_PROVIDER_CODE
          AND    PU.PROGRAM_UNIT_ID     = p_new_program_unit_id
          AND    PU.PROGRAM_UNIT_ID     = LA.NEW_PROGRAM_UNIT_ID
          AND    PU.LAYER_PROVIDER_CODE = LA.PROGRAM_UNIT_LP_CODE;

        /*
        CURSOR layer_cur
                 (
                   p_layer_provider_code  IN  vea_layers.layer_provider_code%TYPE,
                   p_layer_id             IN  vea_layers.layer_id%TYPE,
                   p_layer_header_id      IN  vea_layers.layer_header_id%TYPE
                 )
        IS
          SELECT layer_id
          FROM   vea_layers
          WHERE  layer_provider_code   = p_layer_provider_code
          AND    layer_id              = p_layer_id;
         */
          --AND    layer_header_id       = p_layer_header_id;
        --
        --
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF NOT( vea_tpa_util_pvt.is_vea_installed() )
	THEN
	   RETURN;
	END IF;
	--
	--
        -- Standard API Header
        --
	l_location := '0020';
	--
        vea_tpa_util_pvt.api_header
          (
            p_package_name                => G_PACKAGE_NAME,
            p_api_name                    => l_api_name,
            p_api_type                    => l_api_type,
            p_api_current_version         => l_api_version,
            p_api_caller_version          => p_api_version,
            p_init_msg_list               => p_init_msg_list,
            x_savepoint_name              => l_savepoint_name,
            x_api_return_status           => x_return_status
          );
        --
        --
        --{ API Body
        --
	l_location := '0025';
	--
	IF p_tp_layer_name IS NULL
	OR (
	         p_tps_parameter1_name IS NULL
	     AND p_tps_parameter1_value IS NOT NULL
	   )
	OR (
	         p_tps_parameter2_name IS NULL
	     AND p_tps_parameter2_value IS NOT NULL
	   )
	OR (
	         p_tps_parameter3_name IS NULL
	     AND p_tps_parameter3_value IS NOT NULL
	   )
	OR (
	         p_tps_parameter4_name IS NULL
	     AND p_tps_parameter4_value IS NOT NULL
	   )
	OR (
	         p_tps_parameter5_name IS NULL
	     AND p_tps_parameter5_value IS NOT NULL
	   )
	OR (
	         p_tps_parameter6_name IS NULL
	     AND p_tps_parameter6_value IS NOT NULL
	   )
	OR (
	         p_tps_parameter7_name IS NULL
	     AND p_tps_parameter7_value IS NOT NULL
	   )
	OR (
	         p_tps_parameter8_name IS NULL
	     AND p_tps_parameter8_value IS NOT NULL
	   )
	OR (
	         p_tps_parameter9_name IS NULL
	     AND p_tps_parameter9_value IS NOT NULL
	   )
	OR (
	         p_tps_parameter10_name IS NULL
	     AND p_tps_parameter10_value IS NOT NULL
	   )
	THEN
            vea_tpa_util_pvt.add_message_and_raise
            (
                p_error_name => 'VEA_INCOMPATIBLE_LAYER_FILE'
            );

	END IF;
	--
	--
	l_location := '0027';
	--
        l_layer_header_id     :=  vea_layer_headers_sv.g_layer_header_id;
        l_tp_layer_id         :=  p_tp_layer_id;
        l_new_program_unit_id :=  p_new_program_unit_id;
        l_tps_parameter1_id   :=  p_tps_parameter1_id;
        l_tps_parameter2_id   :=  p_tps_parameter2_id;
        l_tps_parameter3_id   :=  p_tps_parameter3_id;
        l_tps_parameter4_id   :=  p_tps_parameter4_id;
        l_tps_parameter5_id   :=  p_tps_parameter5_id;
        l_tps_parameter6_id   :=  p_tps_parameter6_id;
        l_tps_parameter7_id   :=  p_tps_parameter7_id;
        l_tps_parameter8_id   :=  p_tps_parameter8_id;
        l_tps_parameter9_id   :=  p_tps_parameter9_id;
        l_tps_parameter10_id  :=  p_tps_parameter10_id;
        --
        --
	l_location := '0030';
	--
	l_tp_layer_id := vea_tp_layers_sv.getId
	                   (
                             p_layer_provider_code   => p_layer_provider_code,
                             p_tp_layer_name         => p_tp_layer_name
			   );
        --
	l_location := '0040';
	--
	BEGIN
            vea_tpa_util_pvt.get
	      (
	        p_key                => p_new_program_unit_id,
	        p_cache_tbl          => vea_tpa_util_pvt.g_PU_fileId_dbId_tbl,
	        p_cache_ext_tbl      => vea_tpa_util_pvt.g_PU_fileId_dbId_ext_tbl,
	        x_value              => l_new_program_unit_id
	      );
	EXCEPTION
	   WHEN FND_API.G_EXC_ERROR THEN
	       l_new_program_unit_id := NULL;
	END;
        --
	l_location := '0050';
	--
            FOR layer_rec IN layer_cur
                                      (
                                        p_layer_provider_code   => p_layer_provider_code,
                                        p_tp_layer_id           => l_tp_layer_id,
                                        p_new_program_unit_id   => l_new_program_unit_id
                                      )
            LOOP
            --{
	        l_location := '0060';
	        --
                l_layer_id              := layer_rec.layer_id;
            --}
            END LOOP;
        --
	--
	l_location := '0070';
	--
	IF vea_layer_licenses_sv.isLicensed
	     (
	       p_layer_provider_code => p_layer_provider_code,
	       p_tp_layer_id         => l_tp_layer_id
	     )
        THEN
	--{
	    l_location := '0080';
	    --
	    l_active_flag := isLayerActive
			       (
                                 p_layer_provider_code => p_layer_provider_code,
                                 p_tp_layer_id         => l_tp_layer_id,
                                 p_layer_header_id     => l_layer_header_id
			       );
            --
            --
	    l_location := '0090';
	    --
	    IF l_active_flag = 'Y'
	    THEN
	    --{
	        l_location := '0100';
	        --
	        UPDATE vea_tp_layers
		SET    active_flag = 'Y'
		WHERE  layer_provider_code = p_layer_provider_code
		AND    tp_layer_id         = l_tp_layer_id;
	    --}
	    END IF;
            --
            --
	    l_location := '0110';
	    --
	    --
            IF (p_tps_parameter1_name IS NOT NULL)
            THEN
            --{
	        l_location := '0120';
	        --

                l_tps_parameter1_id := vea_parameters_sv.getId
                         (
                           p_layer_provider_code   => vea_layer_headers_sv.g_tps_program_unit_lp_code,
                           p_program_unit_id       => vea_layer_headers_sv.g_tps_program_unit_id,
                           p_name        => p_tps_parameter1_name
                         );
		--
		--
	        l_location := '0130';
	        --
	        IF l_tps_parameter1_id IS NULL
	        THEN
	           RAISE FND_API.G_EXC_ERROR;
	        END IF;
	    --}
	    END IF;
            --

	    --
	    --
            IF (p_tps_parameter2_name IS NOT NULL)
            THEN
            --{
	        l_location := '0140';
	        --
                l_tps_parameter2_id := vea_parameters_sv.getId
                         (
                           p_layer_provider_code   => vea_layer_headers_sv.g_tps_program_unit_lp_code,
                           p_program_unit_id       => vea_layer_headers_sv.g_tps_program_unit_id,
                           p_name        => p_tps_parameter2_name
                         );
		--
		--
	        l_location := '0150';
	        --
	        IF l_tps_parameter2_id IS NULL
	        THEN
	           RAISE FND_API.G_EXC_ERROR;
	        END IF;
	    --}
	    END IF;
            --
            --
	    --
            IF (p_tps_parameter3_name IS NOT NULL)
            THEN
            --{
	        l_location := '0160';
	        --
                l_tps_parameter3_id := vea_parameters_sv.getId
                         (
                           p_layer_provider_code   => vea_layer_headers_sv.g_tps_program_unit_lp_code,
                           p_program_unit_id       => vea_layer_headers_sv.g_tps_program_unit_id,
                           p_name        => p_tps_parameter3_name
                         );
		--
		--
	        l_location := '0170';
	        --
	        IF l_tps_parameter3_id IS NULL
	        THEN
	           RAISE FND_API.G_EXC_ERROR;
	        END IF;
	    --}
	    END IF;
	    --
	    --
            IF (p_tps_parameter4_name IS NOT NULL)
            THEN
            --{
	        l_location := '0180';
	        --
                l_tps_parameter4_id := vea_parameters_sv.getId
                         (
                           p_layer_provider_code   => vea_layer_headers_sv.g_tps_program_unit_lp_code,
                           p_program_unit_id       => vea_layer_headers_sv.g_tps_program_unit_id,
                           p_name        => p_tps_parameter4_name
                         );
		--
		--
	        l_location := '0190';
	        --
	        IF l_tps_parameter4_id IS NULL
	        THEN
	           RAISE FND_API.G_EXC_ERROR;
	        END IF;
	    --}
	    END IF;
	    --
	    --
            IF (p_tps_parameter5_name IS NOT NULL)
            THEN
            --{
	        l_location := '0200';
	        --
                l_tps_parameter5_id := vea_parameters_sv.getId
                         (
                           p_layer_provider_code   => vea_layer_headers_sv.g_tps_program_unit_lp_code,
                           p_program_unit_id       => vea_layer_headers_sv.g_tps_program_unit_id,
                           p_name        => p_tps_parameter5_name
                         );
		--
		--
	        l_location := '0210';
	        --
	        IF l_tps_parameter5_id IS NULL
	        THEN
	           RAISE FND_API.G_EXC_ERROR;
	        END IF;
	    --}
	    END IF;
	    --
	    --
            IF (p_tps_parameter6_name IS NOT NULL)
            THEN
            --{
	        l_location := '0220';
	        --
                l_tps_parameter6_id := vea_parameters_sv.getId
                         (
                           p_layer_provider_code   => vea_layer_headers_sv.g_tps_program_unit_lp_code,
                           p_program_unit_id       => vea_layer_headers_sv.g_tps_program_unit_id,
                           p_name        => p_tps_parameter6_name
                         );
		--
		--
	        l_location := '0230';
	        --
	        IF l_tps_parameter6_id IS NULL
	        THEN
	           RAISE FND_API.G_EXC_ERROR;
	        END IF;
	    --}
	    END IF;
	    --
	    --
            IF (p_tps_parameter7_name IS NOT NULL)
            THEN
            --{
	        l_location := '0240';
	        --
                l_tps_parameter7_id := vea_parameters_sv.getId
                         (
                           p_layer_provider_code   => vea_layer_headers_sv.g_tps_program_unit_lp_code,
                           p_program_unit_id       => vea_layer_headers_sv.g_tps_program_unit_id,
                           p_name        => p_tps_parameter7_name
                         );
		--
		--
	        l_location := '0250';
	        --
	        IF l_tps_parameter7_id IS NULL
	        THEN
	           RAISE FND_API.G_EXC_ERROR;
	        END IF;
	    --}
	    END IF;
	    --
	    --
            IF (p_tps_parameter8_name IS NOT NULL)
            THEN
            --{
	        l_location := '0260';
	        --
                l_tps_parameter8_id := vea_parameters_sv.getId
                         (
                           p_layer_provider_code   => vea_layer_headers_sv.g_tps_program_unit_lp_code,
                           p_program_unit_id       => vea_layer_headers_sv.g_tps_program_unit_id,
                           p_name        => p_tps_parameter8_name
                         );
		--
		--
	        l_location := '0270';
	        --
	        IF l_tps_parameter8_id IS NULL
	        THEN
	           RAISE FND_API.G_EXC_ERROR;
	        END IF;
	    --}
	    END IF;
	    --
	    --
            IF (p_tps_parameter9_name IS NOT NULL)
            THEN
            --{
	        l_location := '0280';
	        --
                l_tps_parameter9_id := vea_parameters_sv.getId
                         (
                           p_layer_provider_code   => vea_layer_headers_sv.g_tps_program_unit_lp_code,
                           p_program_unit_id       => vea_layer_headers_sv.g_tps_program_unit_id,
                           p_name        => p_tps_parameter9_name
                         );
		--
		--
	        l_location := '0290';
	        --
	        IF l_tps_parameter9_id IS NULL
	        THEN
	           RAISE FND_API.G_EXC_ERROR;
	        END IF;
	    --}
	    END IF;
	    --
	    --
            IF (p_tps_parameter10_name IS NOT NULL)
            THEN
            --{
	        l_location := '0300';
	        --
                l_tps_parameter10_id := vea_parameters_sv.getId
                         (
                           p_layer_provider_code   => vea_layer_headers_sv.g_tps_program_unit_lp_code,
                           p_program_unit_id       => vea_layer_headers_sv.g_tps_program_unit_id,
                           p_name        => p_tps_parameter10_name
                         );
		--
		--
	        l_location := '0310';
	        --
	        IF l_tps_parameter10_id IS NULL
	        THEN
	           RAISE FND_API.G_EXC_ERROR;
	        END IF;
	    --}
	    END IF;
	    --
	    --
            process_code_conversion
              (
                p_layer_provider_code    => p_layer_provider_code,
                p_layer_header_id        => l_layer_header_id,
		p_tps_parameter1_id      => l_tps_parameter1_id,
		p_tps_parameter1_value   => p_tps_parameter1_value,
		p_tps_parameter2_id      => l_tps_parameter2_id,
		p_tps_parameter2_value   => p_tps_parameter2_value,
		p_tps_parameter3_id      => l_tps_parameter3_id,
		p_tps_parameter3_value   => p_tps_parameter3_value,
		p_tps_parameter4_id      => l_tps_parameter4_id,
		p_tps_parameter4_value   => p_tps_parameter4_value,
		p_tps_parameter5_id      => l_tps_parameter5_id,
		p_tps_parameter5_value   => p_tps_parameter5_value,
		p_tps_parameter6_id      => l_tps_parameter6_id,
		p_tps_parameter6_value   => p_tps_parameter6_value,
		p_tps_parameter7_id      => l_tps_parameter7_id,
		p_tps_parameter7_value   => p_tps_parameter7_value,
		p_tps_parameter8_id      => l_tps_parameter8_id,
		p_tps_parameter8_value   => p_tps_parameter8_value,
		p_tps_parameter9_id      => l_tps_parameter9_id,
		p_tps_parameter9_value   => p_tps_parameter9_value,
		p_tps_parameter10_id     => l_tps_parameter10_id,
		p_tps_parameter10_value  => p_tps_parameter10_value
              );
	    --
	    --
	    l_location := '0320';
	    --
            /*
            l_layer_id := NULL;
            --
            --
	    l_location := '0330';
	    --
            FOR layer_rec IN layer_cur
                                      (
                                        p_layer_provider_code  => p_layer_provider_code,
                                        p_layer_id             => p_id,
                                        p_layer_header_id      => p_layer_header_id
                                      )
            LOOP
            --{
	        l_location := '0340';
	        --
                l_layer_id := layer_rec.layer_id;
            --}
            END LOOP;
            */
            --
            --
	    l_location := '0350';
	    --
            IF l_layer_id IS NULL
            THEN
            --{
	        l_location := '0360';
	        --
	        --
	        IF p_layer_provider_code = vea_tpa_util_pvt.g_current_layer_provider_code
	        THEN
                   SELECT NVL( p_id, vea_layers_s.NEXTVAL )
                   INTO   l_layer_id
                   FROM   DUAL;
	        ELSE
                   SELECT vea_layers_s.NEXTVAL
                   INTO   l_layer_id
                   FROM   DUAL;
	        END IF;
	        --
                --
                --
	        l_location := '0370';
	        --
                validate
                  (
                    p_layer_provider_code    => p_layer_provider_code,
                    p_layer_id               => l_layer_id,
                    p_layer_header_id        => l_layer_header_id,
                    p_new_program_unit_id    => l_new_program_unit_id,
                    p_program_unit_lp_code   => p_program_unit_lp_code,
                    p_sequence_number        => p_sequence_number,
                    p_description            => p_description,
                    p_active_flag            => l_active_flag,
		    p_tps_parameter1_id      => l_tps_parameter1_id,
		    p_tps_parameter1_value   => p_tps_parameter1_value,
		    p_tps_parameter2_id      => l_tps_parameter2_id,
		    p_tps_parameter2_value   => p_tps_parameter2_value,
		    p_tps_parameter3_id      => l_tps_parameter3_id,
		    p_tps_parameter3_value   => p_tps_parameter3_value,
		    p_tps_parameter4_id      => l_tps_parameter4_id,
		    p_tps_parameter4_value   => p_tps_parameter4_value,
		    p_tps_parameter5_id      => l_tps_parameter5_id,
		    p_tps_parameter5_value   => p_tps_parameter5_value,
		    p_tps_parameter6_id      => l_tps_parameter6_id,
		    p_tps_parameter6_value   => p_tps_parameter6_value,
		    p_tps_parameter7_id      => l_tps_parameter7_id,
		    p_tps_parameter7_value   => p_tps_parameter7_value,
		    p_tps_parameter8_id      => l_tps_parameter8_id,
		    p_tps_parameter8_value   => p_tps_parameter8_value,
		    p_tps_parameter9_id      => l_tps_parameter9_id,
		    p_tps_parameter9_value   => p_tps_parameter9_value,
		    p_tps_parameter10_id     => l_tps_parameter10_id,
		    p_tps_parameter10_value  => p_tps_parameter10_value
                  );
                --
                --
	        l_location := '0380';
	        --
                insert_row
                  (
                    p_layer_provider_code    => p_layer_provider_code,
                    p_layer_id               => l_layer_id,
                    p_layer_header_id        => l_layer_header_id,
                    p_new_program_unit_id    => l_new_program_unit_id,
                    p_program_unit_lp_code   => p_program_unit_lp_code,
                    p_sequence_number        => p_sequence_number,
                    p_description            => p_description,
                    p_active_flag            => l_active_flag,
		    p_tps_parameter1_id      => l_tps_parameter1_id,
		    p_tps_parameter1_value   => p_tps_parameter1_value,
		    p_tps_parameter2_id      => l_tps_parameter2_id,
		    p_tps_parameter2_value   => p_tps_parameter2_value,
		    p_tps_parameter3_id      => l_tps_parameter3_id,
		    p_tps_parameter3_value   => p_tps_parameter3_value,
		    p_tps_parameter4_id      => l_tps_parameter4_id,
		    p_tps_parameter4_value   => p_tps_parameter4_value,
		    p_tps_parameter5_id      => l_tps_parameter5_id,
		    p_tps_parameter5_value   => p_tps_parameter5_value,
		    p_tps_parameter6_id      => l_tps_parameter6_id,
		    p_tps_parameter6_value   => p_tps_parameter6_value,
		    p_tps_parameter7_id      => l_tps_parameter7_id,
		    p_tps_parameter7_value   => p_tps_parameter7_value,
		    p_tps_parameter8_id      => l_tps_parameter8_id,
		    p_tps_parameter8_value   => p_tps_parameter8_value,
		    p_tps_parameter9_id      => l_tps_parameter9_id,
		    p_tps_parameter9_value   => p_tps_parameter9_value,
		    p_tps_parameter10_id     => l_tps_parameter10_id,
		    p_tps_parameter10_value  => p_tps_parameter10_value
                  );
            --}
            ELSE
            --{
	        l_location := '0390';
	        --
                validate
                  (
                    p_layer_provider_code    => p_layer_provider_code,
                    p_layer_id               => l_layer_id,
                    p_layer_header_id        => l_layer_header_id,
                    p_new_program_unit_id    => l_new_program_unit_id,
                    p_program_unit_lp_code   => p_program_unit_lp_code,
                    p_sequence_number        => p_sequence_number,
                    p_description            => p_description,
                    p_active_flag            => l_active_flag,
		    p_tps_parameter1_id      => l_tps_parameter1_id,
		    p_tps_parameter1_value   => p_tps_parameter1_value,
		    p_tps_parameter2_id      => l_tps_parameter2_id,
		    p_tps_parameter2_value   => p_tps_parameter2_value,
		    p_tps_parameter3_id      => l_tps_parameter3_id,
		    p_tps_parameter3_value   => p_tps_parameter3_value,
		    p_tps_parameter4_id      => l_tps_parameter4_id,
		    p_tps_parameter4_value   => p_tps_parameter4_value,
		    p_tps_parameter5_id      => l_tps_parameter5_id,
		    p_tps_parameter5_value   => p_tps_parameter5_value,
		    p_tps_parameter6_id      => l_tps_parameter6_id,
		    p_tps_parameter6_value   => p_tps_parameter6_value,
		    p_tps_parameter7_id      => l_tps_parameter7_id,
		    p_tps_parameter7_value   => p_tps_parameter7_value,
		    p_tps_parameter8_id      => l_tps_parameter8_id,
		    p_tps_parameter8_value   => p_tps_parameter8_value,
		    p_tps_parameter9_id      => l_tps_parameter9_id,
		    p_tps_parameter9_value   => p_tps_parameter9_value,
		    p_tps_parameter10_id     => l_tps_parameter10_id,
		    p_tps_parameter10_value  => p_tps_parameter10_value
                  );
                --
                --
	        l_location := '0400';
	        --
                update_row
                  (
                    p_layer_provider_code    => p_layer_provider_code,
                    p_layer_id               => l_layer_id,
                    p_layer_header_id        => l_layer_header_id,
                    p_new_program_unit_id    => l_new_program_unit_id,
                    p_program_unit_lp_code   => p_program_unit_lp_code,
                    p_sequence_number        => p_sequence_number,
                    p_description            => p_description,
                    p_active_flag            => l_active_flag,
		    p_tps_parameter1_id      => l_tps_parameter1_id,
		    p_tps_parameter1_value   => p_tps_parameter1_value,
		    p_tps_parameter2_id      => l_tps_parameter2_id,
		    p_tps_parameter2_value   => p_tps_parameter2_value,
		    p_tps_parameter3_id      => l_tps_parameter3_id,
		    p_tps_parameter3_value   => p_tps_parameter3_value,
		    p_tps_parameter4_id      => l_tps_parameter4_id,
		    p_tps_parameter4_value   => p_tps_parameter4_value,
		    p_tps_parameter5_id      => l_tps_parameter5_id,
		    p_tps_parameter5_value   => p_tps_parameter5_value,
		    p_tps_parameter6_id      => l_tps_parameter6_id,
		    p_tps_parameter6_value   => p_tps_parameter6_value,
		    p_tps_parameter7_id      => l_tps_parameter7_id,
		    p_tps_parameter7_value   => p_tps_parameter7_value,
		    p_tps_parameter8_id      => l_tps_parameter8_id,
		    p_tps_parameter8_value   => p_tps_parameter8_value,
		    p_tps_parameter9_id      => l_tps_parameter9_id,
		    p_tps_parameter9_value   => p_tps_parameter9_value,
		    p_tps_parameter10_id     => l_tps_parameter10_id,
		    p_tps_parameter10_value  => p_tps_parameter10_value
                  );
            --}
            END IF;
            --
            --
	    l_location := '0410';
	    --
            x_id := l_layer_id;
	--}
	END IF;
	--
        --
        --
        --} API Body
        --
        --
        -- Standard  API Footer
        --
	l_location := '0420';
	--
        vea_tpa_util_pvt.api_footer
          (
            p_commit                      => p_commit,
            x_msg_count                   => x_msg_count,
            x_msg_data                    => x_msg_data
          );
    --}
    EXCEPTION
    --{
        WHEN FND_API.G_EXC_ERROR
        THEN
        --{
            --RAISE;
            vea_tpa_util_pvt.handle_error
              (
                p_error_type                  => vea_tpa_util_pvt.G_ERROR,
                p_savepoint_name              => l_savepoint_name,
                p_package_name                => G_PACKAGE_NAME,
                p_api_name                    => l_api_name,
	        p_location                    => l_location,
                x_msg_count                   => x_msg_count,
                x_msg_data                    => x_msg_data,
                x_api_return_status           => x_return_status
              );
        --}
        WHEN FND_API.G_EXC_UNEXPECTED_ERROR
        THEN
        --{
            --RAISE;
            vea_tpa_util_pvt.handle_error
              (
                p_error_type                  => vea_tpa_util_pvt.G_UNEXPECTED_ERROR,
                p_savepoint_name              => l_savepoint_name,
                p_package_name                => G_PACKAGE_NAME,
                p_api_name                    => l_api_name,
	        p_location                    => l_location,
                x_msg_count                   => x_msg_count,
                x_msg_data                    => x_msg_data,
                x_api_return_status           => x_return_status
              );
        --}
        WHEN OTHERS
        THEN
        --{
            --RAISE;
            vea_tpa_util_pvt.handle_error
              (
                p_error_type                  => vea_tpa_util_pvt.G_OTHER_ERROR,
                p_savepoint_name              => l_savepoint_name,
                p_package_name                => G_PACKAGE_NAME,
                p_api_name                    => l_api_name,
	        p_location                    => l_location,
                x_msg_count                   => x_msg_count,
                x_msg_data                    => x_msg_data,
                x_api_return_status           => x_return_status
              );
        --}
    --}
    END process;
--}
END VEA_LAYERS_SV;

/
