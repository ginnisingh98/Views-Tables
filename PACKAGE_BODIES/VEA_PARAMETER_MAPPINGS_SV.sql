--------------------------------------------------------
--  DDL for Package Body VEA_PARAMETER_MAPPINGS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_PARAMETER_MAPPINGS_SV" as
/* $Header: VEAVAPMB.pls 115.9 2004/07/27 00:52:54 rvishnuv ship $      */
--{
    /*======================  vea_parameter_mappings_sv  =========================*/
    /*========================================================================
       PURPOSE:  Table handler package for table VEA_PARAMETER_MAPPINGS

       NOTES:                To run the script:

                             sql> start VEAVALHB.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_PARAMETER_MAPPINGS_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME: insert_row

       PURPOSE: Inserts a record into VEA_PARAMETER_MAPPINGS table

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_layer_provider_code         IN     vea_parameter_mappings.layer_provider_code%TYPE,
          p_parameter_mapping_id        IN     vea_parameter_mappings.parameter_mapping_id%TYPE,
          p_layer_header_id             IN     vea_parameter_mappings.layer_header_id%TYPE,
          p_program_unit_parameter_id   IN     vea_parameter_mappings.program_unit_parameter_id%TYPE,
          p_program_unit_param_lp_code  IN     vea_parameter_mappings.program_unit_param_lp_code%TYPE,
          p_tps_parameter_id            IN     vea_parameter_mappings.tps_parameter_id%TYPE,
          p_tps_parameter_lp_code       IN     vea_parameter_mappings.tps_parameter_lp_code%TYPE,
          p_description                 IN     vea_parameter_mappings.description%TYPE
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
        INSERT INTO vea_parameter_mappings
          (
            layer_provider_code, parameter_mapping_id,
            layer_header_id,
            program_unit_parameter_id, program_unit_param_lp_code,
            tps_parameter_id, tps_parameter_lp_code,
            description,
            created_by, creation_date,
            last_updated_by, last_update_date,
            last_update_login
          )
        VALUES
          (
            p_layer_provider_code, p_parameter_mapping_id,
            p_layer_header_id,
            p_program_unit_parameter_id, p_program_unit_param_lp_code,
            p_tps_parameter_id, p_tps_parameter_lp_code,
            p_description,
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

       PURPOSE: Updates a record into VEA_PARAMETER_MAPPINGS table

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_layer_provider_code         IN     vea_parameter_mappings.layer_provider_code%TYPE,
          p_parameter_mapping_id        IN     vea_parameter_mappings.parameter_mapping_id%TYPE,
          p_layer_header_id             IN     vea_parameter_mappings.layer_header_id%TYPE,
          p_program_unit_parameter_id   IN     vea_parameter_mappings.program_unit_parameter_id%TYPE,
          p_program_unit_param_lp_code  IN     vea_parameter_mappings.program_unit_param_lp_code%TYPE,
          p_tps_parameter_id            IN     vea_parameter_mappings.tps_parameter_id%TYPE,
          p_tps_parameter_lp_code       IN     vea_parameter_mappings.tps_parameter_lp_code%TYPE,
          p_description                 IN     vea_parameter_mappings.description%TYPE
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
        UPDATE vea_parameter_mappings
        SET    program_unit_parameter_id    = p_program_unit_parameter_id,
               program_unit_param_lp_code   = p_program_unit_param_lp_code,
               layer_header_id              = p_layer_header_id,
               tps_parameter_id             = p_tps_parameter_id,
               tps_parameter_lp_code        = p_tps_parameter_lp_code,
               description                  = p_description,
               last_updated_by              = l_user_id,
               last_update_date             = SYSDATE,
               last_update_login            = l_login_id
        WHERE  layer_provider_code          = p_layer_provider_code
        AND    parameter_mapping_id         = p_parameter_mapping_id;
        --AND    layer_header_id              = p_layer_header_id
        --AND    tps_parameter_id             = p_tps_parameter_id
        --AND    tps_parameter_lp_code        = p_tps_parameter_lp_code;
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

       PROCEDURE NAME: delete_rows

       PURPOSE: Deletes all parameter mappings for the specified layer header.

    ========================================================================*/
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code         IN     vea_parameter_mappings.layer_provider_code%TYPE,
          p_layer_header_id             IN     vea_parameter_mappings.layer_header_id%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'delete_rows';
        l_location            VARCHAR2(32767);
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
        DELETE vea_parameter_mappings
        WHERE  layer_provider_code          = p_layer_provider_code
        AND    layer_header_id              = p_layer_header_id;
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

       PROCEDURE NAME: process

       PURPOSE: Table hadndler API for VEA_PARAMETER_MAPPINGS table.

		It inserts/updates a record in VEA_PARAMETER_MAPPINGS table.

    ========================================================================*/
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
          x_id                         OUT NOCOPY     vea_parameter_mappings.parameter_mapping_id%TYPE,
          p_layer_provider_code        IN     vea_parameter_mappings.layer_provider_code%TYPE,
          p_layer_header_id            IN     vea_parameter_mappings.layer_header_id%TYPE,
          p_tps_parameter_id           IN     vea_parameter_mappings.tps_parameter_id%TYPE,
          p_tps_parameter_lp_code      IN     vea_parameter_mappings.tps_parameter_lp_code%TYPE,
          p_program_unit_parameter_id  IN     vea_parameter_mappings.program_unit_parameter_id%TYPE,
          p_program_unit_param_lp_code IN     vea_parameter_mappings.program_unit_param_lp_code%TYPE,
          p_description                IN     vea_parameter_mappings.description%TYPE,
          p_id                         IN     vea_parameter_mappings.parameter_mapping_id%TYPE   := NULL,
          p_program_unit_parameter_name  IN    vea_parameters.name%TYPE,
          p_tps_parameter_name           IN    vea_parameters.name%TYPE

        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'process';
        l_api_version         CONSTANT NUMBER       := 1.0;
        l_api_type            CONSTANT VARCHAR2(3)  := vea_tpa_util_pvt.G_PUBLIC_API;
        --
        --
        l_location            VARCHAR2(32767);
        l_savepoint_name      VARCHAR2(30);
        l_parameter_mapping_id        vea_parameter_mappings.parameter_mapping_id%TYPE;
        l_program_unit_parameter_id   vea_parameter_mappings.program_unit_parameter_id%TYPE;
        l_tps_parameter_id            vea_parameter_mappings.tps_parameter_id%TYPE;
        l_layer_header_id             vea_parameter_mappings.layer_header_id%TYPE;
        --
        --
        CURSOR parameter_mapping_cur
                 (
                   p_layer_provider_code   IN  vea_parameter_mappings.layer_provider_code%TYPE,
                   p_parameter_mapping_id  IN  vea_parameter_mappings.parameter_mapping_id%TYPE,
                   p_layer_header_id       IN  vea_parameter_mappings.layer_header_id%TYPE,
                   p_tps_parameter_id      IN  vea_parameter_mappings.tps_parameter_id%TYPE,
                   p_tps_parameter_lp_code IN  vea_parameter_mappings.tps_parameter_lp_code%TYPE
                 )
        IS
          SELECT parameter_mapping_id
          FROM   vea_parameter_mappings
          WHERE  layer_provider_code          = p_layer_provider_code
          --AND    parameter_mapping_id         = p_parameter_mapping_id;
          --AND    parameter_mapping_id         = NVL(p_parameter_mapping_id,parameter_mapping_id)
          AND    layer_header_id              = p_layer_header_id
          AND    tps_parameter_id             = p_tps_parameter_id
          AND    tps_parameter_lp_code        = p_tps_parameter_lp_code;
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
	IF p_program_unit_parameter_name IS NULL
	OR p_tps_parameter_name          IS NULL
        THEN
            vea_tpa_util_pvt.add_message_and_raise
            (
                p_error_name => 'VEA_INCOMPATIBLE_LAYER_FILE'
            );
	END IF;
        --
	l_location := '0030';
	--
        l_parameter_mapping_id := NULL;
        l_program_unit_parameter_id   := p_program_unit_parameter_id;
        l_tps_parameter_id            := p_tps_parameter_id;
        l_layer_header_id             := vea_layer_headers_sv.g_layer_header_id;
        --
        --
	l_location := '0040';
	--
	l_program_unit_parameter_id := vea_parameters_sv.getId
	                                 (
                                           p_layer_provider_code  => p_program_unit_param_lp_code,
			                   p_program_unit_id      => vea_layer_headers_sv.g_tpa_program_unit_id,
			                   p_name                 => p_program_unit_parameter_name
			                 );
	--
	--
	l_location := '0050';
	--
	l_tps_parameter_id := vea_parameters_sv.getId
	                                 (
                                           p_layer_provider_code => p_tps_parameter_lp_code,
			                   p_program_unit_id     => vea_layer_headers_sv.g_tps_program_unit_id,
			                   p_name                => p_tps_parameter_name
			                 );
	--
	--
	l_location := '0060';
	--
        FOR parameter_mapping_rec IN parameter_mapping_cur
                                  (
                                    p_layer_provider_code           => p_layer_provider_code,
                                    p_parameter_mapping_id          => p_id,
                                    p_layer_header_id               => l_layer_header_id,
                                    p_tps_parameter_id              => l_tps_parameter_id,
                                    p_tps_parameter_lp_code         => p_tps_parameter_lp_code
                                  )
        LOOP
        --{
	    l_location := '0070';
	    --
            l_parameter_mapping_id        := parameter_mapping_rec.parameter_mapping_id;
        --}
        END LOOP;
        --
        --
	l_location := '0080';
	--
        IF l_parameter_mapping_id IS NULL
        THEN
        --{
	    l_location := '0090';
	    --
	    --
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_program_unit_param_lp_code is ' || p_program_unit_param_lp_code);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' vea_layer_headers_sv.g_tpa_program_unit_id is ' || vea_layer_headers_sv.g_tpa_program_unit_id);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' vea_layer_headers_sv.g_program_unit_id is ' || vea_layer_headers_sv.g_program_unit_id);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_program_unit_parameter_name is ' || p_program_unit_parameter_name);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_tps_parameter_id is ' || l_tps_parameter_id);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_layer_provider_code is ' || p_layer_provider_code);
	    IF p_layer_provider_code = vea_tpa_util_pvt.g_current_layer_provider_code
	    THEN
                SELECT NVL( p_id, vea_parameter_mappings_s.NEXTVAL )
                INTO   l_parameter_mapping_id
                FROM   DUAL;
	    ELSE
                SELECT vea_parameter_mappings_s.NEXTVAL
                INTO   l_parameter_mapping_id
                FROM   DUAL;
	    END IF;
	    --
            --
            --
	    l_location := '0100';
	    --
            insert_row
              (
                p_layer_provider_code        => p_layer_provider_code,
                p_parameter_mapping_id       => l_parameter_mapping_id,
                p_layer_header_id            => l_layer_header_id,
                p_program_unit_parameter_id  => l_program_unit_parameter_id,
                p_program_unit_param_lp_code => p_program_unit_param_lp_code,
                p_tps_parameter_id           => l_tps_parameter_id,
                p_tps_parameter_lp_code      => p_tps_parameter_lp_code,
                p_description                => p_description
              );
        --}
        ELSE
        --{
	    l_location := '0110';
	    --
            update_row
              (
                p_layer_provider_code        => p_layer_provider_code,
                p_parameter_mapping_id       => l_parameter_mapping_id,
                p_layer_header_id            => l_layer_header_id,
                p_program_unit_parameter_id  => l_program_unit_parameter_id,
                p_program_unit_param_lp_code => p_program_unit_param_lp_code,
                p_tps_parameter_id           => l_tps_parameter_id,
                p_tps_parameter_lp_code      => p_tps_parameter_lp_code,
                p_description                => p_description
              );
        --}
        END IF;
        --
        --
	l_location := '0120';
	--
        x_id := l_parameter_mapping_id;
        --
        --
        --} API Body
        --
        --
        -- Standard  API Footer
        --
	l_location := '0130';
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
END VEA_PARAMETER_MAPPINGS_SV;

/
