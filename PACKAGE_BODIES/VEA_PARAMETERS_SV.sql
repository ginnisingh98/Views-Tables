--------------------------------------------------------
--  DDL for Package Body VEA_PARAMETERS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_PARAMETERS_SV" as
/* $Header: VEAVAPAB.pls 115.12 2004/07/27 02:42:20 rvishnuv ship $      */
--{
    /*======================  vea_parameters_sv  =========================*/
    /*========================================================================
       PURPOSE:  Table handler package for table VEA_PARAMETERS

       NOTES:                To run the script:

                             sql> start VEAVAPKB.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_PARAMETERS_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME: insert_row

       PURPOSE: Inserts a record into VEA_PARAMETERS table

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_layer_provider_code    IN     vea_parameters.layer_provider_code%TYPE,
          p_parameter_id           IN     vea_parameters.parameter_id%TYPE,
          p_program_unit_id        IN     vea_parameters.program_unit_id%TYPE,
          p_parameter_type         IN     vea_parameters.parameter_type%TYPE,
          p_parameter_seq          IN     vea_parameters.parameter_seq%TYPE,
          p_name                   IN     vea_parameters.name%TYPE,
          p_datatype               IN     vea_parameters.datatype%TYPE,
          p_default_value          IN     vea_parameters.default_value%TYPE,
          p_description            IN     vea_parameters.description%TYPE
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
	INSERT INTO vea_parameters
	  (
	    layer_provider_code, parameter_id,
	    program_unit_id, parameter_type,
	    name, parameter_seq,
	    datatype, default_value,
	    description,
	    created_by, creation_date,
	    last_updated_by, last_update_date,
	    last_update_login
	  )
	VALUES
	  (
	    p_layer_provider_code, p_parameter_id,
	    p_program_unit_id, p_parameter_type,
	    p_name, p_parameter_seq,
	    p_datatype, p_default_value,
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

       PURPOSE: Updates a record into VEA_PARAMETERS table

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_layer_provider_code    IN     vea_parameters.layer_provider_code%TYPE,
          p_parameter_id           IN     vea_parameters.parameter_id%TYPE,
          p_program_unit_id        IN     vea_parameters.program_unit_id%TYPE,
          p_parameter_type         IN     vea_parameters.parameter_type%TYPE,
          p_parameter_seq          IN     vea_parameters.parameter_seq%TYPE,
          p_name                   IN     vea_parameters.name%TYPE,
          p_datatype               IN     vea_parameters.datatype%TYPE,
          p_default_value          IN     vea_parameters.default_value%TYPE,
          p_description            IN     vea_parameters.description%TYPE
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
	UPDATE vea_parameters
	SET    program_unit_id              = p_program_unit_id,
	       parameter_type               = p_parameter_type,
	       parameter_seq                = p_parameter_seq,
	       name                         = p_name,
	       datatype                     = p_datatype,
	       default_value                = p_default_value,
	       description                  = p_description,
	       last_updated_by              = l_user_id,
	       last_update_date             = SYSDATE,
	       last_update_login            = l_login_id
	WHERE  layer_provider_code          = p_layer_provider_code
	AND    parameter_id                 = p_parameter_id;
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

       PURPOSE: Deletes all parameters for the specified program unit

    ========================================================================*/
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code         IN     vea_parameters.layer_provider_code%TYPE,
          p_program_unit_id             IN     vea_parameters.program_unit_id%TYPE
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
        DELETE vea_parameters
        WHERE  layer_provider_code          = p_layer_provider_code
        AND    program_unit_id              = p_program_unit_id;
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
    --
    /*========================================================================

       PROCEDURE NAME: getId

       PURPOSE:

    ========================================================================*/
    FUNCTION
      getId
        (
          p_layer_provider_code    IN     vea_parameters.layer_provider_code%TYPE,
          p_program_unit_id        IN  vea_parameters.program_unit_id%TYPE,
          p_name                   IN     vea_parameters.name%TYPE
        )
    RETURN NUMBER
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'getId';
        l_location            VARCHAR2(32767);
	--
	--
	CURSOR parameter_cur
		 (
                   p_layer_provider_code    IN  vea_parameters.layer_provider_code%TYPE,
                   p_program_unit_id        IN  vea_parameters.program_unit_id%TYPE,
                   p_name                   IN  vea_parameters.name%TYPE
		 )
	IS
	  SELECT parameter_id
	  FROM   vea_parameters
	  WHERE  layer_provider_code = p_layer_provider_code
	  AND    program_unit_id     = p_program_unit_id
	  AND    upper(name)         = upper(p_name);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR parameter_rec IN parameter_cur
			     (
                               p_layer_provider_code    => p_layer_provider_code,
                               p_program_unit_id        => p_program_unit_id,
                               p_name                   => p_name
			     )
	LOOP
	--{
	    l_location := '0020';
	    --
	    RETURN (parameter_rec.parameter_id);
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

       PROCEDURE NAME: process

       PURPOSE: Table hadndler API for VEA_PARAMETERS table.

		It inserts/updates a record in VEA_PARAMETERS table.

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
          x_id                     OUT NOCOPY     vea_parameters.parameter_id%TYPE,
          p_layer_provider_code    IN     vea_parameters.layer_provider_code%TYPE,
          p_program_unit_id        IN     vea_parameters.program_unit_id%TYPE,
          p_parameter_type         IN     vea_parameters.parameter_type%TYPE,
          p_parameter_seq          IN     vea_parameters.parameter_seq%TYPE,
          p_name                   IN     vea_parameters.name%TYPE,
          p_datatype               IN     vea_parameters.datatype%TYPE,
          p_default_value          IN     vea_parameters.default_value%TYPE,
          p_description            IN     vea_parameters.description%TYPE,
          p_id                     IN     vea_parameters.parameter_id%TYPE   := NULL,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE   := NULL
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
	l_parameter_id     vea_parameters.parameter_id%TYPE;
	l_program_unit_id     vea_program_units.program_unit_id%TYPE;
	l_tp_layer_id         vea_tp_layers.tp_layer_id%TYPE;
	--
	--
	CURSOR parameter_cur
		 (
                   p_layer_provider_code    IN  vea_parameters.layer_provider_code%TYPE,
                   p_parameter_id           IN  vea_parameters.parameter_id%TYPE,
                   p_program_unit_id        IN  vea_parameters.program_unit_id%TYPE,
                   p_name                   IN  vea_parameters.name%TYPE
		 )
	IS
	  SELECT parameter_id
	  FROM   vea_parameters
	  WHERE  layer_provider_code = p_layer_provider_code
	  AND    program_unit_id     = p_program_unit_id
	  AND    name                = p_name;
          -- Commented out this code because we no longer base our processing on the ids
          -- stored in the flat file.  We go by the names of the packages
          -- and derive the ids based on the names and use the derived ids
          -- in further processing.
          /*
	  AND    (
		   (
                         p_parameter_id IS NOT NULL
		     AND parameter_id = p_parameter_id
		   )
		   OR
		   (
                         p_parameter_id IS NULL
		     AND program_unit_id     = p_program_unit_id
	             AND    name                = p_name
		   )
		 );
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
        IF (VEA_TPA_UTIL_PVT.isLayerMergeOn) THEN
        --{
            l_program_unit_id := VEA_PROGRAM_UNITS_SV.g_program_unit_id;
            l_tp_layer_id := nvl(vea_packages_sv.g_tp_layer_id,p_tp_layer_id);
        --}
        ELSE
        --{
            l_program_unit_id := p_program_unit_id;
            l_tp_layer_id := p_tp_layer_id;
        --}
        END IF;
	--
	--
	l_location := '0035';
	--
	--
	IF vea_layer_licenses_sv.isLicensed
	     (
	       p_layer_provider_code => p_layer_provider_code,
	       p_tp_layer_id         => l_tp_layer_id
	     )
        THEN
	--{
	    --
	    --
	    l_location := '0040';
	    --
	    --
	    l_parameter_id := NULL;
	    --
	    --
	    l_parameter_id := getId
			         (
                                   p_layer_provider_code    => p_layer_provider_code,
                                   p_program_unit_id        => l_program_unit_id,
                                   p_name                   => p_name
			         );
	    --
	    --
	    l_location := '0060';
	    --
	    IF l_parameter_id IS NULL
	    THEN
	    --{
	        l_location := '0070';
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_layer_provider_code is ' || p_layer_provider_code);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_parameter_id is ' || l_parameter_id);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_program_unit_id is ' || l_program_unit_id);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_parameter_type is ' || p_parameter_type);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_parameter_seq is ' || p_parameter_seq);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_name is ' || p_name);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_datatype is ' || p_datatype);
	        --
	        --
	        IF p_layer_provider_code = vea_tpa_util_pvt.g_current_layer_provider_code
	        THEN
	            SELECT NVL( p_id, vea_parameters_s.NEXTVAL )
	            INTO   l_parameter_id
	            FROM   DUAL;
	        ELSE
	            SELECT vea_parameters_s.NEXTVAL
	            INTO   l_parameter_id
                    FROM DUAL;
	        END IF;
	        --
	        --
	        --
	        l_location := '0080';
	        --
	        insert_row
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_parameter_id                 => l_parameter_id,
	            p_program_unit_id              => l_program_unit_id,
	            p_parameter_type               => p_parameter_type,
	            p_parameter_seq                => p_parameter_seq,
	            p_name                         => p_name,
	            p_datatype                     => p_datatype,
	            p_default_value                => p_default_value,
	            p_description                  => p_description
	          );
	    --}
	    ELSE
	    --{
	        l_location := '0090';
	        --
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_layer_provider_code is ' || p_layer_provider_code);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_parameter_id is ' || l_parameter_id);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_program_unit_id is ' || l_program_unit_id);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_parameter_type is ' || p_parameter_type);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_parameter_seq is ' || p_parameter_seq);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_name is ' || p_name);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_datatype is ' || p_datatype);
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_default_value is ' || p_default_value);
	        update_row
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_parameter_id                 => l_parameter_id,
	            p_program_unit_id              => l_program_unit_id,
	            p_parameter_type               => p_parameter_type,
	            p_parameter_seq                => p_parameter_seq,
	            p_name                         => p_name,
	            p_datatype                     => p_datatype,
	            p_default_value                => p_default_value,
	            p_description                  => p_description
	          );
	    --}
	    END IF;
	    --
	    --
	    l_location := '0100';
	    --
	    x_id := l_parameter_id;
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
END VEA_PARAMETERS_SV;

/
