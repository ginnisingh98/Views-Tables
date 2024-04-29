--------------------------------------------------------
--  DDL for Package Body VEA_TP_LAYERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_TP_LAYERS_SV" as
/* $Header: VEAVATLB.pls 115.5 2004/07/27 00:08:47 rvishnuv ship $      */
--{
    /*======================  vea_tp_layers_sv  =========================*/
    /*========================================================================
       PURPOSE:  Table handler package for table VEA_TP_LAYERS

       NOTES:                To run the script:

                             sql> start VEAVATLB.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_TP_LAYERS_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME: insert_row

       PURPOSE: Inserts a record into VEA_TP_LAYERS table

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_layer_provider_code   IN     vea_tp_layers.layer_provider_code%TYPE,
          p_tp_layer_id           IN     vea_tp_layers.tp_layer_id%TYPE,
          p_name                  IN     vea_tp_layers.name%TYPE,
          p_description           IN     vea_tp_layers.description%TYPE,
          p_active_flag           IN     vea_tp_layers.active_flag%TYPE
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
        INSERT INTO vea_tp_layers
          (
            layer_provider_code, tp_layer_id,
	    name,
            description,
	    active_flag,
            created_by, creation_date,
            last_updated_by, last_update_date,
            last_update_login
          )
        VALUES
          (
            p_layer_provider_code, p_tp_layer_id,
	    p_name,
            p_description,
	    'N',      --p_active_flag,
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

       PURPOSE: Updates a record into VEA_TP_LAYERS table

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_layer_provider_code       IN     vea_tp_layers.layer_provider_code%TYPE,
          p_tp_layer_id           IN     vea_tp_layers.tp_layer_id%TYPE,
          p_name                  IN     vea_tp_layers.name%TYPE,
          p_description           IN     vea_tp_layers.description%TYPE,
          p_active_flag           IN     vea_tp_layers.active_flag%TYPE
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
            UPDATE vea_tp_layers
            SET    name                         = p_name,
                   description                  = p_description,
		   active_flag                  = 'N', --p_active_flag,
                   last_updated_by              = l_user_id,
                   last_update_date             = SYSDATE,
                   last_update_login            = l_login_id
            WHERE  layer_provider_code          = p_layer_provider_code
	    AND    tp_layer_id                  = p_tp_layer_id;
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

       PURPOSE: Deletes the specified TP Layer

    ========================================================================*/
    PROCEDURE
      delete_row
        (
          p_layer_provider_code       IN     vea_tp_layers.layer_provider_code%TYPE,
          p_tp_layer_id               IN     vea_tp_layers.tp_layer_id%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'delete_row';
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
	/*
	vea_layer_licenses_sv.delete_rows
	  (
	    p_layer_provider_code => p_layer_provider_code,
	    p_tp_layer_id         => p_tp_layer_id
	  );
	--
	--
	l_location := '0020';
	*/
	--
	DELETE vea_tp_layers
	WHERE  layer_provider_code = p_layer_provider_code
	AND    tp_layer_id         = p_tp_layer_id;
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

       PROCEDURE NAME: get_tp_layer_id

       PURPOSE: Returns TP Layer ID for the specifed TP Layer name

    ========================================================================*/
    FUNCTION
      get_tp_layer_id
        (
          p_tp_layer_name               IN     vea_tp_layers.name%TYPE
        )
    RETURN vea_tp_layers.tp_layer_id%TYPE
    IS
    --{
	CURSOR tp_layer_cur
		 (
                   p_layer_provider_code   IN     vea_tp_layers.name%TYPE,
                   p_tp_layer_name         IN     vea_tp_layers.name%TYPE
		 )
	IS
	  SELECT tp_layer_id
	  FROM   vea_tp_layers
	  WHERE  name                = p_tp_layer_name
	  AND    layer_provider_code = p_layer_provider_code;
	--
	--
    --}
    BEGIN
    --{
	FOR tp_layer_rec IN tp_layer_cur
			      (
				p_layer_provider_code => vea_tpa_util_pvt.get_curr_layer_provider_code,
				p_tp_layer_name       => p_tp_layer_name
			      )
	LOOP
	--{
	    RETURN(tp_layer_rec.tp_layer_id);
	--}
	END LOOP;
	--
	--
	RETURN(NULL);
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    RAISE;
	--}
    --}
    END get_tp_layer_id;
    --
    --
    /*========================================================================

       PROCEDURE NAME: getId

       PURPOSE: Returns TP Layer ID for the specifed TP Layer name

    ========================================================================*/
    FUNCTION
      getId
        (
          p_layer_provider_code         IN     vea_tp_layers.layer_provider_code%TYPE,
          p_tp_layer_name               IN     vea_tp_layers.name%TYPE
        )
    RETURN vea_tp_layers.tp_layer_id%TYPE
    IS
    --{
	CURSOR tp_layer_cur
		 (
                   p_layer_provider_code   IN     vea_tp_layers.layer_provider_code%TYPE,
                   p_tp_layer_name         IN     vea_tp_layers.name%TYPE
		 )
	IS
	  SELECT tp_layer_id
	  FROM   vea_tp_layers
	  WHERE  name                = p_tp_layer_name
	  AND    layer_provider_code = p_layer_provider_code;
	--
	--
    --}
    BEGIN
    --{
	FOR tp_layer_rec IN tp_layer_cur
			      (
				p_layer_provider_code => p_layer_provider_code,
				p_tp_layer_name       => p_tp_layer_name
			      )
	LOOP
	--{
	    RETURN(tp_layer_rec.tp_layer_id);
	--}
	END LOOP;
	--
	--
	RETURN(NULL);
    --}
    EXCEPTION
    --{
	WHEN OTHERS
	THEN
	--{
	    RAISE;
	--}
    --}
    END getId;
    --
    --
    /*========================================================================

       PROCEDURE NAME: delete_rows

       PURPOSE: Removes all data belonging to the specified TP layer
		and containing customizations for the specified application

    ========================================================================*/
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code    IN     vea_tp_layers.layer_provider_code%TYPE,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'delete_rows';
        l_api_version         CONSTANT NUMBER       := 1.0;
        l_api_type            CONSTANT VARCHAR2(3)  := vea_tpa_util_pvt.G_PRIVATE_API;
	--
	--
        l_location            VARCHAR2(32767);
	--
	--
        l_tp_layer_id           vea_tp_layers.tp_layer_id%TYPE;
	l_layer_header_count    NUMBER;
	l_package_count         NUMBER;
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	l_tp_layer_id := p_tp_layer_id;
	--
	--
	l_location := '0020';
	--
	IF l_tp_layer_id IS NOT NULL
	THEN
	--{
	    l_location := '0030';
	    --
	    vea_layer_headers_sv.delete_rows
	      (
		p_layer_provider_code    => p_layer_provider_code,
		p_tp_layer_id            => l_tp_layer_id,
		p_application_short_name => p_application_short_name,
		x_layer_header_count     => l_layer_header_count
	      );
	    --
	    --
	    l_location := '0040';
	    --
	    vea_packages_sv.delete_rows
	      (
		p_layer_provider_code    => p_layer_provider_code,
		p_tp_layer_id            => l_tp_layer_id,
		p_application_short_name => p_application_short_name,
		x_package_count          => l_package_count
	      );
	    --
	    --
	    l_location := '0050';
	    --
	    vea_layer_licenses_sv.delete_rows
	      (
	        p_layer_provider_code => p_layer_provider_code,
	        p_tp_layer_id         => l_tp_layer_id
	      );
	    --
	    --
	    l_location := '0060';
	    --
	    IF  l_layer_header_count = 0
	    AND l_package_count = 0
	    THEN
	    --{
	        l_location := '0070';
	        --
	        delete_row
	          (
		    p_layer_provider_code => p_layer_provider_code,
		    p_tp_layer_id         => l_tp_layer_id
	          );
	    --}
	    END IF;
	--}
	END IF;
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

       PROCEDURE NAME: delete_rows

       PURPOSE: Removes all data belonging to the specified TP layer
		and containing customizations for the specified application

    ========================================================================*/
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code    IN     vea_tp_layers.layer_provider_code%TYPE,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE,
          p_tp_layer_name          IN     vea_tp_layers.name%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'delete_rows';
        l_api_version         CONSTANT NUMBER       := 1.0;
        l_api_type            CONSTANT VARCHAR2(3)  := vea_tpa_util_pvt.G_PUBLIC_API;
	--
	--
        l_location            VARCHAR2(32767);
	l_savepoint_name      VARCHAR2(30);
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
	CURSOR tp_layer_id_cur
                 (
                   p_layer_provider_code   IN     vea_tp_layers.layer_provider_code%TYPE,
                   p_tp_layer_id           IN     vea_tp_layers.tp_layer_id%TYPE
                 )
	IS
	  SELECT tp_layer_id
	  FROM   vea_tp_layers
	  WHERE  layer_provider_code     = p_layer_provider_code
	  AND    tp_layer_id             = p_tp_layer_id;
	--
	--
	CURSOR tp_layer_name_cur
                 (
                   p_layer_provider_code   IN     vea_tp_layers.layer_provider_code%TYPE,
                   p_tp_layer_name         IN     vea_tp_layers.name%TYPE
                 )
	IS
	  SELECT tp_layer_id
	  FROM   vea_tp_layers
	  WHERE  layer_provider_code     = p_layer_provider_code
	  AND    name                    = NVL(p_tp_layer_name,name);
	--
	--
        l_tp_layer_id           vea_tp_layers.tp_layer_id%TYPE;
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	l_tp_layer_id := NULL;
	--
	--
	l_location := '0020';
	--
	IF p_tp_layer_id IS NOT NULL
	THEN
	--{
	    l_location := '0030';
	    --
	    FOR tp_layer_id_rec IN tp_layer_id_cur
			       (
			         p_layer_provider_code  => p_layer_provider_code,
			         p_tp_layer_id          => p_tp_layer_id
			       )
	    LOOP
	    --{
	        l_location := '0040';
	        --
	        l_tp_layer_id := tp_layer_id_rec.tp_layer_id;
	        --
	        --
	        l_location := '0050';
	        --
		delete_rows
		  (
		    p_layer_provider_code    => p_layer_provider_code,
		    p_tp_layer_id            => l_tp_layer_id,
		    p_application_short_name => p_application_short_name
		  );
	    --}
	    END LOOP;
	--}
	END IF;
	--
	--
	l_location := '0060';
	--
	IF l_tp_layer_id IS NULL
	THEN
	--{
	    l_location := '0070';
	    --
	    FOR tp_layer_name_rec IN tp_layer_name_cur
			               (
			                 p_layer_provider_code  => p_layer_provider_code,
			                 p_tp_layer_name          => p_tp_layer_name
			               )
	    LOOP
	    --{
	        l_location := '0080';
	        --
	        l_tp_layer_id := tp_layer_name_rec.tp_layer_id;
	        --
	        --
	        l_location := '0090';
	        --
		delete_rows
		  (
		    p_layer_provider_code    => p_layer_provider_code,
		    p_tp_layer_id            => l_tp_layer_id,
		    p_application_short_name => p_application_short_name
		  );
	    --}
	    END LOOP;
	--}
	END IF;
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

       PROCEDURE NAME: deleteUnlicensedLayers

       PURPOSE: Deletes all TP layers which are not licensed to the current
		customer and which does not have any packages.

    ========================================================================*/
    PROCEDURE
      deleteUnlicensedLayers
        (
          p_layer_provider_code       IN     vea_tp_layers.layer_provider_code%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'deleteUnlicensedLayers';
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
	DELETE vea_tp_layers
	WHERE  layer_provider_code = p_layer_provider_code
	AND    tp_layer_id NOT IN (
			            SELECT tp_layer_id
			            FROM   vea_packages
	                            WHERE  layer_provider_code = p_layer_provider_code
				  )
	AND    tp_layer_id NOT IN (
			            SELECT tp_layer_id
			            FROM   vea_layer_licenses
	                            WHERE  layer_provider_code = p_layer_provider_code
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
    END deleteUnlicensedLayers;
    --
    --
    /*========================================================================

       PROCEDURE NAME: process

       PURPOSE: Table hadndler API for VEA_TP_LAYERS table.

		It inserts/updates a record in VEA_TP_LAYERS table.

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
          x_id                        OUT NOCOPY     vea_tp_layers.tp_layer_id%TYPE,
          p_layer_provider_code       IN     vea_tp_layers.layer_provider_code%TYPE,
          p_name                      IN     vea_tp_layers.name%TYPE,
          p_description               IN     vea_tp_layers.description%TYPE,
          p_active_flag               IN     vea_tp_layers.active_flag%TYPE,
          p_id                        IN     vea_tp_layers.tp_layer_id%TYPE   := NULL
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
        l_tp_layer_id     vea_tp_layers.tp_layer_id%TYPE;
        --
        --
        CURSOR tp_layer_cur
                 (
                   p_layer_provider_code   IN  vea_tp_layers.layer_provider_code%TYPE,
                   p_name                  IN  vea_tp_layers.name%TYPE
                 )
        IS
          SELECT tp_layer_id
          FROM   vea_tp_layers
          WHERE  layer_provider_code     = p_layer_provider_code
          AND    name                    = p_name;
        --
        --
        /*
        CURSOR tp_layer_cur
                 (
                   p_layer_provider_code   IN  vea_tp_layers.layer_provider_code%TYPE,
                   p_tp_layer_id           IN  vea_tp_layers.tp_layer_id%TYPE
                 )
        IS
          SELECT tp_layer_id
          FROM   vea_tp_layers
          WHERE  layer_provider_code     = p_layer_provider_code
          AND    tp_layer_id             = p_tp_layer_id;
        */
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
        --
	l_location := '0030';
	--
        l_tp_layer_id := NULL;
        g_tp_layer_id := NULL;
        --
        --
	l_location := '0040';
	--
        l_tp_layer_id :=       getId
                                 (
                                   p_layer_provider_code         => p_layer_provider_code,
                                   p_tp_layer_name               => p_name
                                 );
        --
        --
	l_location := '0050';
        --
        g_tp_layer_id := l_tp_layer_id;
        --
        --
	l_location := '0060';
	--
        IF l_tp_layer_id IS NULL
        THEN
        --{
	    l_location := '0070';
	    --
	    IF p_layer_provider_code = vea_tpa_util_pvt.g_current_layer_provider_code
	    THEN
                SELECT NVL( p_id, vea_tp_layers_s.NEXTVAL )
                INTO   l_tp_layer_id
                FROM   DUAL;
	    ELSE
                SELECT vea_tp_layers_s.NEXTVAL
                INTO   l_tp_layer_id
                FROM   DUAL;
	    END IF;
	    --
            --
	    l_location := '0080';
	    --
            insert_row
              (
                p_layer_provider_code        => p_layer_provider_code,
                p_tp_layer_id                => l_tp_layer_id,
                p_name                       => p_name,
                p_description                => p_description,
                p_active_flag                => p_active_flag
              );
            -- This is very important because, we base the insert/update of licenses
            --, release details and versions on this.
            g_tp_layer_id := l_tp_layer_id;
        --}
        ELSE
        --{
	    l_location := '0090';
	    --
            update_row
              (
                p_layer_provider_code        => p_layer_provider_code,
                p_tp_layer_id                => l_tp_layer_id,
                p_name                       => p_name,
                p_description                => p_description,
                p_active_flag                => p_active_flag
              );
        --}
        END IF;
        --
        --
	l_location := '0100';
	--
        x_id := l_tp_layer_id;
        --
        --
	l_location := '0110';
	--
        --
	IF p_id IS NOT NULL
	THEN
	    vea_tpa_util_pvt.put
	      (
	        p_key                => p_id,
	        p_value              => l_tp_layer_id,
	        x_cache_tbl          => vea_tpa_util_pvt.g_tpLyr_fileId_dbId_tbl,
	        x_cache_ext_tbl      => vea_tpa_util_pvt.g_tpLyr_fileId_dbId_ext_tbl
	      );
	END IF;
        --
        --} API Body
        --
        --
        -- Standard  API Footer
        --
	l_location := '0110';
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
END VEA_TP_LAYERS_SV;

/
