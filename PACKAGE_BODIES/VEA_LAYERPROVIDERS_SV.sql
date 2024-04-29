--------------------------------------------------------
--  DDL for Package Body VEA_LAYERPROVIDERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_LAYERPROVIDERS_SV" as
/* $Header: VEAVALPB.pls 115.14 2003/12/02 01:31:08 rvishnuv noship $      */
--{
    /*========================  vea_layerproviders_sv  =============================*/
    /*========================================================================
       PURPOSE:  Table handler package for table VEA_LAYERPROVIDERS

       NOTES:                To run the script:

                             sql> start VEAVALPB.pls

       HISTORY
                             Created   MOHANA NARAYAN 06/05/2000 10:00 AM

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_LAYERPROVIDERS_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME: validateUniqueCodes

       PURPOSE: Validates a record of VEA_LAYERPROVIDER table

    ========================================================================*/
    PROCEDURE
      validateUniqueCodes
        (
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'validateUniqueCodes';
        l_location            VARCHAR2(32767);
	--
	--
	l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
	l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
       CURSOR layer_cur IS
	   --
	   SELECT layer_provider_code
	   FROM   vea_layer_providers
	   WHERE  layer_provider_code     = p_layer_provider_code;
	   --
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
	    --
	    vea_tpa_util_pvt.add_message_and_raise
	    (
	       p_error_name => 'VEA_LAYER_PROVIDER_CODE_EXIST',
	       p_token1     => 'LAYER_PROVIDER_NAME',
	       p_value1     => p_layer_provider_name
	    );
	--}
	END LOOP;
	--
	--
	l_location := '0030';
	--
	--}
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
    END validateUniqueCodes;
    --
    --
    /*========================================================================

       PROCEDURE NAME: validate

       PURPOSE: Validates a record of VEA_LAYERPROVIDER table

    ========================================================================*/
    PROCEDURE
      validate
        (
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE
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
       -- what does this do ??
	IF vea_tpa_util_pvt.validate
	AND NOT(vea_tpa_util_pvt.isLayerMergeOn)
	THEN

	 --{
	    l_location := '0020';
	    --
	    validateUniqueCodes
	      (
                p_layer_provider_code    => p_layer_provider_code,
                p_layer_provider_name    => p_layer_provider_name
	      );
	    --
	    --
	    l_location := '0030';
	    --
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

       PURPOSE: Inserts a record into VEA_LAYER_PROVIDER table

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_layer_provider_id      IN     vea_layer_providers.layer_provider_id%TYPE,
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE,
          p_description            IN     vea_layer_providers.description%TYPE
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
	--
	validateUniqueCodes
	(
            p_layer_provider_code    => p_layer_provider_code,
            p_layer_provider_name    => p_layer_provider_name
	);
	--
	--
	l_location := '0020';
	--
	--
	INSERT INTO vea_layer_providers
	  (
	    layer_provider_id,
	    layer_provider_code,
            layer_provider_name,
	    description,
	    created_by, creation_date,
	    last_updated_by, last_update_date,
	    last_update_login
	  )
	VALUES
	  (
	    p_layer_provider_id,
	    p_layer_provider_code,
	    p_layer_provider_name,
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

       PURPOSE: Updates a record into VEA_LAYER_PROVIDER table

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_layer_provider_id      IN     vea_layer_providers.layer_provider_id%TYPE,
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE,
          p_description            IN     vea_layer_providers.description%TYPE
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
	UPDATE vea_layer_providers
	SET    layer_provider_code          = p_layer_provider_code,
	       layer_provider_name          = p_layer_provider_name,
	       description                  = p_description,
	       last_updated_by              = l_user_id,
	       last_update_date             = SYSDATE,
	       last_update_login            = l_login_id
	WHERE  layer_provider_id            = p_layer_provider_id;
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

       PURPOSE: Deletes the layer provider from the VEA_LAYER_PROVIDER table
		if no layers have been developed using this layer provider code.

    ========================================================================*/
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE
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
	l_layer_count  NUMBER;
	--
	--
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
	--
	SELECT count(tp_layer_id)
        INTO l_layer_count
	FROM   vea_tp_layers
	WHERE  layer_provider_code     = p_layer_provider_code;
	--
	--
	l_location := '0030';
	--
	--
        IF l_layer_count = 0 THEN
	    --
	    --{
	        l_location := '0040';
	        --
                IF p_layer_provider_code <> 'ORCL' THEN
	           -- Bug No: 1387766 - rvishnuv
	           --{
	               DELETE vea_layer_providers
	               WHERE  layer_provider_code = p_layer_provider_code;
                    -- }
                END IF;
	        --
	        --
	        l_location := '0050';
	    --}
	    --
        ELSIF  NOT(vea_tpa_util_pvt.isLayerMergeOn) THEN
	    --
	    --{
	        l_location := '0060';
	        --
	        vea_tpa_util_pvt.add_message_and_raise
	          (
	            p_error_name => 'VEA_LAYER_EXISTS_FOR_PROVIDER',
	            p_token1     => 'LAYER_PROVIDER_NAME',
	            p_value1     => p_layer_provider_name
	           );
	    --}
        END IF;
	--
	--
	l_location := '0060';
	--
	--
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

       PROCEDURE NAME: getLayerProviderCode

       PURPOSE: Returns the layer developer's code given a name.

    ========================================================================*/
    FUNCTION
      getLayerProviderCode
        (
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE
        )
    RETURN VARCHAR2
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'getLayerProviderCode';
        l_location            VARCHAR2(32767);
	--
	--
	l_layer_provider_code vea_layer_providers.layer_provider_code%TYPE;
	--
	--
       CURSOR layer_cur IS
	   --
	   SELECT layer_provider_code
	   FROM   vea_layer_providers
	   WHERE  layer_provider_name     = p_layer_provider_name;
	   --
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
	    l_layer_provider_code := layer_rec.layer_provider_code;
	    --
	    l_location := '0030';
	    --
	    RETURN(l_layer_provider_code);
	--}
	END LOOP;
	--
	--
	l_location := '0040';
	--
	--
        /* No such layer provider name found */
	vea_tpa_util_pvt.add_message_and_raise
	      (
	        p_error_name => 'VEA_LAYER_NAME_NOTFOUND',
	        p_token1     => 'LAYER_PROVIDER_NAME',
	        p_value1     => p_layer_provider_name
	      );
	--
	--
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
    END getLayerProviderCode;
    --
    --
    /*========================================================================

       PROCEDURE NAME: getLayerProviderName

       PURPOSE: Returns the layer developer's name given a code.

    ========================================================================*/
    FUNCTION
      getLayerProviderName
        (
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE
        )
    RETURN VARCHAR2
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'getLayerProviderName';
        l_location            VARCHAR2(32767);
	--
	--
	l_layer_provider_name vea_layer_providers.layer_provider_name%TYPE;
	--
	--
       CURSOR layer_cur IS
	   --
	   SELECT layer_provider_name
	   FROM   vea_layer_providers
	   WHERE  layer_provider_code     = p_layer_provider_code;
	   --
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
	    l_layer_provider_name := layer_rec.layer_provider_name;
	    --
	    l_location := '0030';
	    --
	    RETURN(l_layer_provider_name);
	--}
	END LOOP;
	--
	--
	l_location := '0040';
	--
	--
        /* No such layer provider code found */
	vea_tpa_util_pvt.add_message_and_raise
	      (
	        p_error_name => 'VEA_LAYER_CODE_NOTFOUND',
	        p_token1     => 'LAYER_PROVIDER_CODE',
	        p_value1     => p_layer_provider_code
	      );
	--
	--
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
    END getLayerProviderName;
    --
    --
    /*========================================================================

       PROCEDURE NAME: process

       PURPOSE: Table hadndler API for VEA_LAYER_PROVIDER table.

		It inserts/updates a record in VEA_LAYER_PROVIDER table.

    ========================================================================*/
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
          p_layer_provider_code    IN     vea_layer_providers.layer_provider_code%TYPE,
          p_layer_provider_name    IN     vea_layer_providers.layer_provider_name%TYPE,
          p_description            IN     vea_layer_providers.description%TYPE
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
	l_insert              BOOLEAN := TRUE;
	l_layer_provider_name vea_layer_providers.layer_provider_name%TYPE;
	l_layer_provider_id   vea_layer_providers.layer_provider_id%TYPE;
	l_layer_provider_code vea_layer_providers.layer_provider_code%TYPE;
        l_layer_count         NUMBER   := 0;
	--
	--
       TYPE lp_rec_type IS
        RECORD
          (
            layer_provider_id   vea_layer_providers.layer_provider_id%TYPE,
            layer_provider_code   vea_layer_providers.layer_provider_code%TYPE,
            layer_provider_name vea_layer_providers.layer_provider_name%TYPE
          );
       --
       --
       TYPE layer_cur_type IS REF CURSOR ;
       --RETURN lp_rec_type;
       --
       --
       layer_cur layer_cur_type;
       layer_rec lp_rec_type;
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
	    l_location := '0035';
	    --
	    --
	    l_insert := TRUE;
	    --
	    --
	    l_location := '0040';
	    --
	    --
            IF (vea_tpa_util_pvt.isLayerMergeOn)
            THEN
              open layer_cur for
              'select layer_provider_id,
                     layer_provider_code, layer_provider_name
              from vea_layer_providers
              where layer_provider_code = :lp_code'
	      using p_layer_provider_code;
            ELSE
              open layer_cur for
              select layer_provider_id,
                     layer_provider_code, layer_provider_name
              from vea_layer_providers
              where layer_provider_code  is not null;
            END IF;

	    LOOP
	    --{
	        l_location := '0045';

                FETCH layer_cur INTO layer_rec;

                EXIT WHEN layer_cur%NOTFOUND;
	        --
	        --
	        l_insert := FALSE;
	        --
	        --
	        l_location := '0070';
	        --
	        --
	        validate
	          (
                    p_layer_provider_code    => p_layer_provider_code,
                    p_layer_provider_name    => p_layer_provider_name
	          );
	        --
	        --
	        l_location := '0090';
	        --
                SELECT count(tp_layer_id)
                INTO   l_layer_count
                FROM   vea_tp_layers
                WHERE  layer_provider_code = layer_rec.layer_provider_code;
	        --
	        --
	        l_location := '0100';
	        --
                -- Bug No: 1389096.
                --IF ( vea_tpa_util_pvt.isLayerMergeOn ) AND (l_layer_count = 0)
                IF ( vea_tpa_util_pvt.isLayerMergeOn )
                THEN
	        --{
                    update_row
                      (
                        p_layer_provider_id      => layer_rec.layer_provider_id,
                        p_layer_provider_code    => p_layer_provider_code,
                        p_layer_provider_name    => p_layer_provider_name,
                        p_description            => p_description
                      );
                ELSIF l_layer_count = 0
                THEN
                     update_row
                      (
                        p_layer_provider_id      => layer_rec.layer_provider_id,
                        p_layer_provider_code    => p_layer_provider_code,
                        p_layer_provider_name    => p_layer_provider_name,
                        p_description            => p_description
                      );
                     vea_tpa_util_pvt.update_lookup_values
                      (
                        p_lookup_type            => 'VEA_LAYER_PROVIDERS',
                        p_new_lookup_code        => p_layer_provider_code,
                        p_current_lookup_code    => layer_rec.layer_provider_code,
                        p_meaning                => p_layer_provider_name,
                        p_description            => p_layer_provider_name
                      );
                 ELSE
                      vea_tpa_util_pvt.add_message_and_raise
                       (
                         p_error_name => 'VEA_LAYER_EXISTS_FOR_PROVIDER',
                         p_token1     => 'LAYER_PROVIDER_NAME',
                         p_value1     => layer_rec.layer_provider_name
                       );
	            --}
                 END IF;

	    --}
	    END LOOP;

            close layer_cur;

	    IF l_insert = TRUE THEN
	    --{
	        l_location := '0110';
	        --
	        --
                SELECT vea_layer_providers_s.NEXTVAL
                INTO   l_layer_provider_id
                FROM   DUAL;
                --
                --
	        insert_row
	          (
                    p_layer_provider_id      => l_layer_provider_id,
                    p_layer_provider_code    => p_layer_provider_code,
                    p_layer_provider_name    => p_layer_provider_name,
                    p_description            => p_description
	          );
                IF NOT( vea_tpa_util_pvt.isLayerMergeOn )
                THEN
	        --{
                    vea_tpa_util_pvt.insert_lookup_values
                      (
                        p_lookup_type            => 'VEA_LAYER_PROVIDERS',
                        p_lookup_code            => p_layer_provider_code,
                        p_meaning                => p_layer_provider_name,
                        p_description            => p_layer_provider_name
                      );
                --}
                END IF;

	    --}
	    END IF;
	    --
	    --
	    l_location := '0120';
	    --
	    --
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
END VEA_LAYERPROVIDERS_SV;

/
