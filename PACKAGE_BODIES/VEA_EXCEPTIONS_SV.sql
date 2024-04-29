--------------------------------------------------------
--  DDL for Package Body VEA_EXCEPTIONS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_EXCEPTIONS_SV" as
/* $Header: VEAVAEXB.pls 115.4 2003/04/28 17:43:25 heali noship $      */
--{
    /*======================  vea_EXCEPTIONS_sv  =========================*/
    /*========================================================================
       PURPOSE:  Table handler package for table VEA_EXCEPTIONS

       NOTES:                To run the script:

                             sql> start VEAVAPKB.pls

       HISTORY
                             Created   BMUNAGAL       04/13/2000

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_EXCEPTIONS_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME: insert_row

       PURPOSE: Inserts a record into VEA_EXCEPTIONS table

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_exception_id           IN VEA_EXCEPTIONS.exception_id%TYPE,
          p_release_id             IN VEA_EXCEPTIONS.release_id%TYPE,
          p_layer_provider_code    IN VEA_EXCEPTIONS.layer_provider_code%TYPE,
          p_message_name           IN VEA_EXCEPTIONS.message_name%TYPE,
          p_exception_level        IN VEA_EXCEPTIONS.exception_level%TYPE,
          p_message_text           IN VEA_EXCEPTIONS.message_text%TYPE,
          p_description            IN VEA_EXCEPTIONS.description%TYPE
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
	INSERT INTO vea_EXCEPTIONS
	  (
            exception_id, release_id, layer_provider_code,
            message_name, exception_level,
            message_text, description,
	    created_by, creation_date,
	    last_updated_by, last_update_date,
	    last_update_login
	  )
	VALUES
	  (
            p_exception_id, p_release_id, p_layer_provider_code,
            p_message_name, p_exception_level,
            p_message_text, p_description,
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

       PURPOSE: Updates a record into VEA_EXCEPTIONS table

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_exception_id           IN VEA_EXCEPTIONS.exception_id%TYPE,
          p_release_id             IN VEA_EXCEPTIONS.release_id%TYPE,
          p_layer_provider_code    IN VEA_EXCEPTIONS.layer_provider_code%TYPE,
          p_message_name           IN VEA_EXCEPTIONS.message_name%TYPE,
          p_exception_level        IN VEA_EXCEPTIONS.exception_level%TYPE,
          p_message_text           IN VEA_EXCEPTIONS.message_text%TYPE,
          p_description            IN VEA_EXCEPTIONS.description%TYPE
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
	UPDATE vea_EXCEPTIONS
	SET    release_id                   = p_release_id,
               message_name                 = p_message_name,
               exception_level              = p_exception_level,
               message_text                 = p_message_text,
	       description                  = p_description,
	       last_updated_by              = l_user_id,
	       last_update_date             = SYSDATE,
	       last_update_login            = l_login_id
	WHERE  layer_provider_code          = p_layer_provider_code
	AND    exception_id                 = p_exception_id;
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

       PROCEDURE NAME: process

       PURPOSE: Table hadndler API for VEA_EXCEPTIONS table.

		It inserts/updates a record in VEA_EXCEPTIONS table.

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
          x_id                     OUT NOCOPY     vea_EXCEPTIONS.exception_id%TYPE,
          p_release_id             IN VEA_EXCEPTIONS.release_id%TYPE,
          p_layer_provider_code    IN VEA_EXCEPTIONS.layer_provider_code%TYPE,
          p_message_name           IN VEA_EXCEPTIONS.message_name%TYPE,
          p_exception_level        IN VEA_EXCEPTIONS.exception_level%TYPE,
          p_message_text           IN VEA_EXCEPTIONS.message_text%TYPE,
          p_description            IN VEA_EXCEPTIONS.description%TYPE,
          p_id                     IN VEA_EXCEPTIONS.exception_id%TYPE := NULL
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
	    --
	    x_id := p_id;
	    --

	    IF x_id IS NULL
	    THEN
	    --{
	        l_location := '0070';
	        --
	        SELECT NVL( x_id, vea_EXCEPTIONS_s.NEXTVAL )
	        INTO   x_id
	        FROM   DUAL;
	        --
	        --
	        l_location := '0090';
	        --

	        insert_row
	          (
                    p_exception_id                 => x_id,
                    p_release_id                   => p_release_id,
	            p_layer_provider_code          => p_layer_provider_code,
                    p_message_name                 => p_message_name,
                    p_exception_level              => p_exception_level,
                    p_message_text                 => p_message_text,
                    p_description                  => p_description
	          );
	    --}
	    ELSE
	    --{
	        l_location := '0100';
	        --

	        update_row
	          (
                    p_exception_id                 => x_id,
                    p_release_id                   => p_release_id,
	            p_layer_provider_code          => p_layer_provider_code,
                    p_message_name                 => p_message_name,
                    p_exception_level              => p_exception_level,
                    p_message_text                 => p_message_text,
                    p_description                  => p_description
	          );
	    --}
	    END IF;
	    --
	    --
	--} API Body
	--
	--
	-- Standard  API Footer
	--
	l_location := '0140';
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
END VEA_EXCEPTIONS_SV;

/
