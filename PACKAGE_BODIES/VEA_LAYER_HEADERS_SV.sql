--------------------------------------------------------
--  DDL for Package Body VEA_LAYER_HEADERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_LAYER_HEADERS_SV" as
/* $Header: VEAVALHB.pls 115.13 2004/07/27 00:52:27 rvishnuv ship $      */
--{
    /*======================  vea_layer_headers_sv  =========================*/
    /*========================================================================
       PURPOSE:  Table handler package for table VEA_LAYER_HEADERS

       NOTES:                To run the script:

                             sql> start VEAVALHB.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_LAYER_HEADERS_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME: insert_row

       PURPOSE: Inserts a record into VEA_LAYER_HEADERS table

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
          p_layer_header_id           IN     vea_layer_headers.layer_header_id%TYPE,
          p_program_unit_id           IN     vea_layer_headers.program_unit_id%TYPE,
          p_program_unit_lp_code      IN     vea_layer_headers.program_unit_lp_code%TYPE,
          p_tps_program_unit_id       IN     vea_layer_headers.tps_program_unit_id%TYPE,
          p_tps_program_unit_lp_code  IN     vea_layer_headers.tps_program_unit_lp_code%TYPE,
          p_condition_type            IN     vea_layer_headers.condition_type%TYPE,
          p_description               IN     vea_layer_headers.description%TYPE
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
        INSERT INTO vea_layer_headers
          (
            layer_provider_code, layer_header_id,
            program_unit_id, program_unit_lp_code,
            tps_program_unit_id, tps_program_unit_lp_code,
	    condition_type,
            description,
            created_by, creation_date,
            last_updated_by, last_update_date,
            last_update_login
          )
        VALUES
          (
            p_layer_provider_code, p_layer_header_id,
            p_program_unit_id, p_program_unit_lp_code,
            p_tps_program_unit_id, p_tps_program_unit_lp_code,
	    p_condition_type,
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

       PURPOSE: Updates a record into VEA_LAYER_HEADERS table

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
          p_layer_header_id           IN     vea_layer_headers.layer_header_id%TYPE,
          p_program_unit_id           IN     vea_layer_headers.program_unit_id%TYPE,
          p_program_unit_lp_code      IN     vea_layer_headers.program_unit_lp_code%TYPE,
          p_tps_program_unit_id       IN     vea_layer_headers.tps_program_unit_id%TYPE,
          p_tps_program_unit_lp_code  IN     vea_layer_headers.tps_program_unit_lp_code%TYPE,
          p_condition_type            IN     vea_layer_headers.condition_type%TYPE,
          p_description               IN     vea_layer_headers.description%TYPE,
          p_old_layer_header_id       IN     vea_layer_headers.layer_header_id%TYPE
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
	IF p_condition_type IS NULL
	THEN
	--{
	    l_location := '0020';
	    --
            vea_parameter_mappings_sv.delete_rows
	      (
                p_layer_provider_code        => p_layer_provider_code,
                p_layer_header_id            => p_old_layer_header_id
	      );
	    --
	    --
	    IF p_old_layer_header_id <> p_layer_header_id
	    THEN
	    --{
	        l_location := '0020';
	        --
		UPDATE vea_layers
		SET    layer_header_id = p_layer_header_id
                WHERE  p_layer_provider_code  = p_layer_provider_code
                AND    p_layer_header_id      = p_old_layer_header_id;
	    --}
	    END IF;
	    --
	    --
	/*
            vea_layers_sv.delete_rows
	      (
                p_layer_provider_code        => p_layer_provider_code,
                p_layer_header_id            => p_layer_header_id
	      );
	    --
	    --
         */
	    /*
            insert_row
              (
                p_layer_provider_code        => p_layer_provider_code,
                p_layer_header_id            => p_layer_header_id,
                p_program_unit_id            => p_program_unit_id,
                p_program_unit_lp_code       => p_program_unit_lp_code,
                p_tps_program_unit_id        => p_tps_program_unit_id,
                p_tps_program_unit_lp_code   => p_tps_program_unit_lp_code,
                p_condition_type             => p_condition_type,
                p_description                => p_description
	      );
	      */
	--}
	END IF;
	--
	--
	l_location := '0030';
	--
            UPDATE vea_layer_headers
            SET
                   tps_program_unit_id          = p_tps_program_unit_id,
                   tps_program_unit_lp_code     = p_tps_program_unit_lp_code,
                   program_unit_id              = p_program_unit_id,
                   program_unit_lp_code         = p_program_unit_lp_code,
		   condition_type               = p_condition_type,
                   description                  = p_description,
                   last_updated_by              = l_user_id,
                   last_update_date             = SYSDATE,
                   last_update_login            = l_login_id
            WHERE  layer_provider_code          = p_layer_provider_code
            --AND    program_unit_id              = p_program_unit_id
            --AND    program_unit_lp_code         = p_program_unit_lp_code
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
    END update_row;
    --
    --
    /*========================================================================

       PROCEDURE NAME: delete_rows

       PURPOSE: Queries all records which has at least one layer corresponding
		to the specified TP Layer

		For each layer header,
		  - delete layer header ( and all parameter mappings for it )
		    if
		     - it has at least one layer which contains customizations
		       for any of the customizable program units within the
		       specified application.

    ========================================================================*/
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
          p_tp_layer_id               IN     vea_tp_layers.tp_layer_id%TYPE,
          p_application_short_name    IN     vea_packages.application_short_name%TYPE,
	  x_layer_header_count        OUT NOCOPY     NUMBER
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'delete_rows';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
	CURSOR layer_header_cur
                 (
                   p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
                   p_tp_layer_id               IN     vea_tp_layers.tp_layer_id%TYPE
                 )
	IS
	  SELECT distinct layer_header_id
	  FROM   vea_layers_v
	  WHERE  layer_provider_code     = p_layer_provider_code
	  AND    tp_layer_id             = p_tp_layer_id;
	--
	--
	CURSOR application_cur
                 (
                   p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
                   p_layer_header_id           IN     vea_layer_headers.layer_header_id%TYPE,
                   p_application_short_name    IN     vea_packages.application_short_name%TYPE
                 )
	IS
	  SELECT 'x'
	  FROM   vea_layer_headers LH,
		 vea_program_units PU,
		 vea_packages PK
	  WHERE  LH.layer_provider_code     = p_layer_provider_code
	  AND    LH.layer_header_id         = p_layer_header_id
	  AND    PU.program_unit_id         = LH.program_unit_id
	  AND    PU.layer_provider_code     = LH.program_unit_lp_code
	  AND    PK.layer_provider_code     = PU.layer_provider_code
	  AND    PK.package_id              = PU.package_id
	  AND    PK.tpa_flag                = 'Y'
	  AND    PU.tpa_program_unit_id     IS NOT NULL
	  AND    PK.application_short_name  = NVL(p_application_short_name,PK.application_short_name);
	--
	--
	l_layer_count          NUMBER;
	l_layer_header_count   NUMBER;
	l_count                NUMBER;
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	l_layer_header_count := 0;
	--
	--
	l_location := '0020';
	--
	FOR layer_header_rec IN layer_header_cur
			   (
			     p_layer_provider_code    => p_layer_provider_code,
			     p_tp_layer_id            => p_tp_layer_id
			   )
	LOOP
	--{
	    l_location := '0030';
	    --
	    l_count := 0;
	    --
	    --
	    l_location := '0040';
	    --
	    FOR application_rec IN application_cur
			             (
			               p_layer_provider_code    => p_layer_provider_code,
			               p_layer_header_id        => layer_header_rec.layer_header_id,
				       p_application_short_name => p_application_short_name
			             )
	    LOOP
	    --{
	        l_location := '0050';
	        --
		l_count := l_count + 1;
	    --}
	    END LOOP;
	    --
	    --
	    l_location := '0060';
	    --
	    IF l_count = 0
	    THEN
	    --{
	        l_location := '0070';
	        --
	        l_layer_header_count := l_layer_header_count + 1;
	    --}
	    ELSE
	    --{
	        l_location := '0080';
	        --
	        vea_layers_sv.delete_rows
	          (
		    p_layer_provider_code => p_layer_provider_code,
		    p_layer_header_id     => layer_header_rec.layer_header_id,
		    p_tp_layer_id         => p_tp_layer_id,
		    x_layer_count         => l_layer_count
	          );
	        --
	        --
	        l_location := '0090';
	        --
	        IF l_layer_count = 0
	        THEN
	        --{
	            l_location := '0100';
	            --
                    vea_parameter_mappings_sv.delete_rows
	              (
                        p_layer_provider_code        => p_layer_provider_code,
                        p_layer_header_id            => layer_header_rec.layer_header_id
	              );
	            --
	            --
	            l_location := '0110';
	            --
	            DELETE vea_layer_headers
	            WHERE  layer_provider_code = p_layer_provider_code
	            AND    layer_header_id     = layer_header_rec.layer_header_id;
	        --}
	        END IF;
	    --}
	    END IF;
	--}
	END LOOP;
	--
	--
	l_location := '0120';
	--
	x_layer_header_count := NVL(l_layer_header_count,0);
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

       PURPOSE: Table hadndler API for VEA_LAYER_HEADERS table.

		It inserts/updates a record in VEA_LAYER_HEADERS table.

    ========================================================================*/
    PROCEDURE
      process
        (
          p_api_version               IN     NUMBER,
          p_init_msg_list             IN     VARCHAR2 := FND_API.G_FALSE,
          p_commit                    IN     VARCHAR2 := FND_API.G_FALSE,
          p_validation_level          IN     NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status             OUT NOCOPY     VARCHAR2,
          x_msg_count                 OUT NOCOPY     NUMBER,
          x_msg_data                  OUT NOCOPY     VARCHAR2,
          x_id                        OUT NOCOPY     vea_layer_headers.layer_header_id%TYPE,
          p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
          p_program_unit_id           IN     vea_layer_headers.program_unit_id%TYPE,
          p_program_unit_lp_code      IN     vea_layer_headers.program_unit_lp_code%TYPE,
          p_tps_program_unit_id       IN     vea_layer_headers.tps_program_unit_id%TYPE,
          p_tps_program_unit_lp_code  IN     vea_layer_headers.tps_program_unit_lp_code%TYPE,
          p_condition_type            IN     vea_layer_headers.condition_type%TYPE,
          p_description               IN     vea_layer_headers.description%TYPE,
          p_id                        IN     vea_layer_headers.layer_header_id%TYPE   := NULL,
          p_package_name              IN     vea_packages.name%TYPE,
          p_pkg_app_name              IN     vea_packages.application_short_name%TYPE,
          p_pkg_cs_flag               IN     vea_packages.client_server_flag%TYPE,
          p_program_unit_name         IN     vea_program_units.name%TYPE,
          p_tps_package_name          IN     vea_packages.name%TYPE,
          p_tps_program_unit_name     IN     vea_program_units.name%TYPE,
          p_tpsPkg_app_name           IN     vea_packages.application_short_name%TYPE,
          p_tpsPkg_cs_flag            IN     vea_packages.client_server_flag%TYPE
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
        l_layer_header_id     vea_layer_headers.layer_header_id%TYPE;
        l_program_unit_id     vea_program_units.program_unit_id%TYPE;
        l_tpa_program_unit_id vea_program_units.program_unit_id%TYPE;
        l_tps_program_unit_id vea_program_units.program_unit_id%TYPE;
        l_package_id          vea_program_units.package_id%TYPE;
        l_tps_package_id      vea_program_units.package_id%TYPE;
        --
        --
	CURSOR bl_pu_csr (p_pu_id IN NUMBER,p_lpc IN VARCHAR2)
	is
	  select tpa_program_unit_id
	  from vea_program_units
	  where program_unit_id = p_pu_id
	  and layer_provideR_code = p_lpc;

       CURSOR layer_header_cur
                 (
                   p_layer_provider_code       IN  vea_layer_headers.layer_provider_code%TYPE,
                   p_program_unit_id           IN  vea_layer_headers.program_unit_id%TYPE,
                   p_program_unit_lp_code      IN  vea_layer_headers.program_unit_lp_code%TYPE,
                  p_condition_type            IN     vea_layer_headers.condition_type%TYPE
                 )
       IS
         SELECT layer_header_id
         FROM   vea_layer_headers
         WHERE  layer_provider_code     = p_layer_provider_code
         AND    program_unit_id         = p_program_unit_id
         AND    program_unit_lp_code    = p_program_unit_lp_code
         AND    NVL(condition_type,'!') = NVL(p_condition_type,'!');
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
	l_location := '0030';
	--
        IF p_package_name             IS NULL
        OR p_pkg_app_name             IS NULL
        OR p_pkg_cs_flag              IS NULL
        OR p_program_unit_name        IS NULL
        OR p_tps_package_name         IS NULL
        OR p_tps_program_unit_name    IS NULL
        OR p_tpsPkg_app_name          IS NULL
        OR p_tpsPkg_cs_flag           IS NULL
	THEN
            vea_tpa_util_pvt.add_message_and_raise
            (
                p_error_name => 'VEA_INCOMPATIBLE_LAYER_FILE'
            );
	END IF;
        --
	--
	l_location := '0040';
	--
        l_layer_header_id := NULL;
	--
        l_program_unit_id := p_program_unit_id;
        l_tps_program_unit_id := p_tps_program_unit_id;
        --
        --
	l_location := '0050';
	--
	l_package_id := vea_packages_sv.getId
			         (
                                   p_layer_provider_code    => p_program_unit_lp_code,
                                   p_application_short_name => p_pkg_app_name,
                                   p_client_server_flag     => p_pkg_cs_flag,
                                   p_name                   => p_package_name
			         );
	--
	l_location := '0060';
	--
	--
	l_program_unit_id := vea_program_units_sv.getId
			         (
                                   p_layer_provider_code    => p_program_unit_lp_code,
                                   p_package_id             => l_package_id,
                                   p_name                   => p_program_unit_name
			         );
        --
        --
	g_program_unit_id := l_program_unit_id;
        --
	l_location := '0065';
	--
	g_tpa_program_unit_id := null;
	FOR bl_pu_rec IN bl_pu_csr(l_program_unit_id, p_program_unit_lp_code)
	LOOP
	   g_tpa_program_unit_id := bl_pu_rec.tpa_program_unit_id;
	END LOOP;
        --
	l_location := '0070';
	--
	l_tps_package_id := vea_packages_sv.getId
			         (
                                   p_layer_provider_code    => p_tps_program_unit_lp_code,
                                   p_application_short_name => p_tpsPkg_app_name,
                                   p_client_server_flag     => p_tpsPkg_cs_flag,
                                   p_name                   => p_tps_package_name
			         );
	--
	l_location := '0080';
	--
	--
	l_tps_program_unit_id := vea_program_units_sv.getId
			         (
                                   p_layer_provider_code    => p_tps_program_unit_lp_code,
                                   p_package_id             => l_tps_package_id,
                                   p_name                   => p_tps_program_unit_name
			         );
	--
	--
	g_tps_program_unit_id := l_tps_program_unit_id;
	g_tps_program_unit_lp_code      := p_tps_program_unit_lp_code;
        --
	l_location := '0090';
	--
        FOR layer_header_rec IN layer_header_cur
                                  (
                                    p_layer_provider_code   => p_layer_provider_code,
                                    p_program_unit_id       => l_program_unit_id,
                                    p_program_unit_lp_code  => p_program_unit_lp_code,
                                    p_condition_type        => p_condition_type
                                  )
        LOOP
        --{
	    l_location := '0100';
	    --
            l_layer_header_id := layer_header_rec.layer_header_id;
        --}
        END LOOP;
        --
        --
	l_location := '0110';
	--
        IF l_layer_header_id IS NULL
        THEN
        --{
	    l_location := '0120';
	    --
	    --
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_layer_provider_code is ' || p_layer_provider_code);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' g_current_layer_provider_code is ' || vea_tpa_util_pvt.g_current_layer_provider_code);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_program_unit_id is ' || l_program_unit_id);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_program_unit_lp_code is ' || p_program_unit_lp_code);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_tps_program_unit_id is ' || l_tps_program_unit_id);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_tps_program_unit_lp_code is ' || p_tps_program_unit_lp_code);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_program_unit_name is ' || p_program_unit_name);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_tps_program_unit_name is ' || p_tps_program_unit_name);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_tps_package_id is ' || l_tps_package_id);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_tps_package_name is ' || p_tps_package_name);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_tpsPkg_cs_flag is ' || p_tpsPkg_cs_flag);
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_tpsPkg_app_name is ' || p_tpsPkg_app_name);
	    IF p_layer_provider_code = vea_tpa_util_pvt.g_current_layer_provider_code
	    THEN
                SELECT NVL( p_id, vea_layer_headers_s.NEXTVAL )
                INTO   l_layer_header_id
                FROM   DUAL;
	    ELSE
                SELECT vea_layer_headers_s.NEXTVAL
                INTO   l_layer_header_id
                FROM   DUAL;
	    END IF;
	    --
            --
	    l_location := '0130';
            --
	    g_layer_header_id := l_layer_header_id;
            --
	    l_location := '0140';
	    --
            insert_row
              (
                p_layer_provider_code        => p_layer_provider_code,
                p_layer_header_id            => l_layer_header_id,
                p_program_unit_id            => l_program_unit_id,
                p_program_unit_lp_code       => p_program_unit_lp_code,
                p_tps_program_unit_id        => l_tps_program_unit_id,
                p_tps_program_unit_lp_code   => p_tps_program_unit_lp_code,
                p_condition_type             => p_condition_type,
                p_description                => p_description
              );
        --}
        ELSE
        --{
	    l_location := '0150';
            --
	    g_layer_header_id := l_layer_header_id;
            --
	    l_location := '0160';
	    --
            update_row
              (
                p_layer_provider_code        => p_layer_provider_code,
                p_layer_header_id            => l_layer_header_id,
                p_program_unit_id            => l_program_unit_id,
                p_program_unit_lp_code       => p_program_unit_lp_code,
                p_tps_program_unit_id        => l_tps_program_unit_id,
                p_tps_program_unit_lp_code   => p_tps_program_unit_lp_code,
                p_condition_type             => p_condition_type,
                p_description                => p_description,
                p_old_layer_header_id        => l_layer_header_id
              );
        --}
        END IF;
        --
        --
	l_location := '0170';
	--
        x_id := l_layer_header_id;
        --
        --
        --} API Body
        --
        --
        -- Standard  API Footer
        --
	l_location := '0180';
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
END VEA_LAYER_HEADERS_SV;

/
