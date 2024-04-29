--------------------------------------------------------
--  DDL for Package Body VEA_PACKAGES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_PACKAGES_SV" as
/* $Header: VEAVAPKB.pls 115.16 2004/07/27 00:09:19 rvishnuv ship $      */
--{
    /*========================  vea_packages_sv  =============================*/
    /*========================================================================
       PURPOSE:  Table handler package for table VEA_PACKAGES

       NOTES:                To run the script:

                             sql> start VEAVAPKB.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_PACKAGES_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME: validateNamingConventions

       PURPOSE: Validates naming conventions for package name and file name.

    ========================================================================*/
    PROCEDURE
      validateNamingConventions
        (
          p_client_server_flag     IN     vea_packages.client_server_flag%TYPE,
          p_name                   IN     vea_packages.name%TYPE,
          p_specification_filename IN     vea_packages.specification_filename%TYPE,
          p_body_filename          IN     vea_packages.body_filename%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'validateNamingConventions';
        l_location            VARCHAR2(32767);
	--
	--
	l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
	l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_curr_layer_provider_code    vea_packages.layer_provider_code%TYPE;
	l_prefix       VARCHAR2(32767);
	l_package_name_prefix         VARCHAR2(32767);
	l_file_name_prefix       VARCHAR2(32767);

	l_file_message_name       VARCHAR2(32767);
	l_package_message_name       VARCHAR2(32767);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	l_curr_layer_provider_code := vea_tpa_util_pvt.get_curr_layer_provider_code;
	--
	--
	l_location := '0020';
	--
	IF l_curr_layer_provider_code = vea_tpa_util_pvt.G_ORACLE
	THEN
	--{
	    l_location := '0030';
	    --
	    l_prefix := p_application_short_name;
	    --
	    --
	    l_location := '0040';
	    --
	    l_file_message_name := 'VEA_IMPORT_ORCL_FILE_NAME_STD';
	    --
	    --
	    l_location := '0050';
	    --
	    l_package_message_name := 'VEA_IMPORT_ORCL_PKG_NAME_STD';
	--}
	ELSE
	--{
	    l_location := '0060';
	    --
	    l_prefix := l_curr_layer_provider_code;
	    --
	    --
	    l_location := '0070';
	    --
	    l_file_message_name := 'VEA_IMPORT_LP_FILE_NAME_STD';
	    --
	    --
	    l_location := '0080';
	    --
	    l_package_message_name := 'VEA_IMPORT_LP_PKG_NAME_STD';
	--}
	END IF;
	--
	--
	l_location := '0090';
	--
	l_file_name_prefix := l_prefix
		              || vea_tpa_util_pvt.G_WILD_CARD;
	--
	--
	l_location := '0100';
	--
	l_package_name_prefix := l_prefix
		                 || '\'
		                 || vea_tpa_util_pvt.G_UNDERSCORE
		                 || vea_tpa_util_pvt.G_WILD_CARD;
	--
	--
	l_location := '0110';
	--
	IF p_name NOT LIKE l_package_name_prefix ESCAPE '\'
	THEN
	--{
	    l_location := '0120';
	    --
	    vea_tpa_util_pvt.add_message_and_raise
	      (
	        p_error_name => l_package_message_name,
	        p_token1     => 'PACKAGE_NAME',
	        p_value1     => p_name
	      );
	--}
	END IF;
	--
	--
	l_location := '0130';
	--
	IF p_specification_filename NOT LIKE l_file_name_prefix
	THEN
	--{
	    l_location := '0140';
	    --
	    vea_tpa_util_pvt.add_message_and_raise
	      (
	        p_error_name => l_file_message_name,
	        p_token1     => 'FILE_NAME',
	        p_value1     => p_specification_filename
	      );
	--}
	END IF;
	--
	--
	l_location := '0150';
	--
	IF  p_body_filename IS NOT NULL
	AND p_body_filename NOT LIKE l_file_name_prefix
	THEN
	--{
	    l_location := '0160';
	    --
	    vea_tpa_util_pvt.add_message_and_raise
	      (
	        p_error_name => l_file_message_name,
	        p_token1     => 'FILE_NAME',
	        p_value1     => p_body_filename
	      );
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
    END validateNamingConventions;
    --
    --
    /*========================================================================

       PROCEDURE NAME: validateUniqueServerFileNames

       PURPOSE: Validates a record of VEA_PACKAGES table

    ========================================================================*/
    PROCEDURE
      validateUniqueServerFileNames
        (
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_package_id             IN     vea_packages.package_id%TYPE,
          p_name                   IN     vea_packages.name%TYPE,
          p_specification_filename IN     vea_packages.specification_filename%TYPE,
          p_body_filename          IN     vea_packages.body_filename%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'validateUniqueServerFileNames';
        l_location            VARCHAR2(32767);
	--
	--
	l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
	l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
	CURSOR pkg_spec_file_cur
		 (
                   p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
                   p_specification_filename IN     vea_packages.specification_filename%TYPE
		 )
	IS
	  SELECT package_id, name
	  FROM   vea_packages
	  WHERE  specification_filename = p_specification_filename
	  AND    layer_provider_code    = p_layer_provider_code;
	--
	--
	CURSOR pkg_body_file_cur
		 (
                   p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
                   p_body_filename          IN     vea_packages.body_filename%TYPE
		 )
	IS
	  SELECT package_id, name
	  FROM   vea_packages
	  WHERE  body_filename = p_body_filename
	  AND    layer_provider_code    = p_layer_provider_code;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR pkg_spec_file_rec IN pkg_spec_file_cur
				   (
				     p_layer_provider_code    => p_layer_provider_code,
				     p_specification_filename => p_specification_filename
				   )
	LOOP
	--{
	    l_location := '0020';
	    --
	    IF pkg_spec_file_rec.package_id <> p_package_id
	    THEN
	    --{
	        l_location := '0030';
	        --
	        vea_tpa_util_pvt.add_message_and_raise
	          (
	            p_error_name => 'VEA_IMPORT_UNIQ_SPEC_FILE',
	            p_token1     => 'FILE_NAME',
	            p_value1     => p_specification_filename,
	            p_token2     => 'PACKAGE_NAME',
	            p_value2     => pkg_spec_file_rec.name,
	            p_token3     => 'SVR_PACKAGE_NAME',
	            p_value3     => p_name
	          );
	    --}
	    END IF;
	--}
	END LOOP;
	--
	--
	l_location := '0040';
	--
	IF p_body_filename IS NOT NULL
	THEN
	--{
	    l_location := '0050';
	    --
	    FOR pkg_body_file_rec IN pkg_body_file_cur
				       (
				         p_layer_provider_code => p_layer_provider_code,
				         p_body_filename       => p_body_filename
				       )
	    LOOP
	    --{
	        l_location := '0060';
	        --
	        IF pkg_body_file_rec.package_id <> p_package_id
	        THEN
	        --{
	            l_location := '0070';
	            --
	            vea_tpa_util_pvt.add_message_and_raise
	              (
	                p_error_name => 'VEA_IMPORT_UNIQ_BODY_FILE',
	                p_token1     => 'FILE_NAME',
	                p_value1     => p_body_filename,
	                p_token2     => 'PACKAGE_NAME',
	                p_value2     => pkg_body_file_rec.name,
	                p_token3     => 'SVR_PACKAGE_NAME',
	                p_value3     => p_name
	              );
	        --}
	        END IF;
	    --}
	    END LOOP;
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
    END validateUniqueServerFileNames;
    --
    --
    --
    /*========================================================================

       PROCEDURE NAME: validateUniqueClientFileNames

       PURPOSE: Validates a record of VEA_PACKAGES table

    ========================================================================*/
    PROCEDURE
      validateUniqueClientFileNames
        (
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_package_id             IN     vea_packages.package_id%TYPE,
          p_name                   IN     vea_packages.name%TYPE,
          p_specification_filename IN     vea_packages.specification_filename%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'validateUniqueClientFileNames';
        l_location            VARCHAR2(32767);
	--
	--
	l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
	l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
	CURSOR pkg_spec_file_cur
		 (
                   p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
                   p_specification_filename IN     vea_packages.specification_filename%TYPE
		 )
	IS
	  SELECT package_id, application_short_name
	  FROM   vea_packages
	  WHERE  specification_filename = p_specification_filename
	  AND    layer_provider_code    = p_layer_provider_code;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR pkg_spec_file_rec IN pkg_spec_file_cur
				   (
				     p_layer_provider_code    => p_layer_provider_code,
				     p_specification_filename => p_specification_filename
				   )
	LOOP
	--{
	    l_location := '0020';
	    --
	    IF pkg_spec_file_rec.package_id <> p_package_id
	    AND pkg_spec_file_rec.application_short_name <> p_application_short_name
	    THEN
	    --{
	        l_location := '0030';
	        --
	        vea_tpa_util_pvt.add_message_and_raise
	          (
	            p_error_name => 'VEA_IMPORT_UNIQ_CLIENT_FILE',
	            p_token1     => 'FILE_NAME',
	            p_value1     => p_specification_filename,
	            p_token2     => 'APP_SHORT_NAME',
	            p_value2     => pkg_spec_file_rec.application_short_name,
	            p_token3     => 'SVR_PACKAGE_NAME',
	            p_value3     => p_name
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
    END validateUniqueClientFileNames;
    --
    --
    /*========================================================================

       PROCEDURE NAME: validate

       PURPOSE: Validates a record of VEA_PACKAGES table

    ========================================================================*/
    PROCEDURE
      validate
        (
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_package_id             IN     vea_packages.package_id%TYPE,
          p_client_server_flag     IN     vea_packages.client_server_flag%TYPE,
          p_generate_flag          IN     vea_packages.generate_flag%TYPE,
          p_tpa_flag               IN     vea_packages.tpa_flag%TYPE,
          p_name                   IN     vea_packages.name%TYPE,
          p_specification_filename IN     vea_packages.specification_filename%TYPE,
          p_body_filename          IN     vea_packages.body_filename%TYPE,
          p_label                  IN     vea_packages.label%TYPE,
          p_version_number         IN     vea_packages.version_number%TYPE,
          p_description            IN     vea_packages.description%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_tp_layer_id            IN     vea_packages.tp_layer_id%TYPE
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
	AND NOT(vea_tpa_util_pvt.isLayerMergeOn)
	THEN
	--{
	    l_location := '0020';
	    --
	    validateNamingConventions
	      (
	        p_client_server_flag           => p_client_server_flag,
	        p_name                         => p_name,
	        p_specification_filename       => p_specification_filename,
	        p_body_filename                => p_body_filename,
	        p_application_short_name       => p_application_short_name
	      );
	    --
	    --
	    l_location := '0030';
	    --
	    IF p_client_server_flag = 'S'
	    THEN
	    --{
	        l_location := '0040';
	        --
		validateUniqueServerFileNames
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_package_id                   => p_package_id,
	            p_name                         => p_name,
	            p_specification_filename       => p_specification_filename,
	            p_body_filename                => p_body_filename
	          );
	    --}
	    ELSE
	    --{
	        l_location := '0050';
	        --
		validateUniqueClientFileNames
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_package_id                   => p_package_id,
	            p_name                         => p_name,
	            p_specification_filename       => p_specification_filename,
	            p_application_short_name       => p_application_short_name
	          );
	    --}
	    END IF;
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

       PURPOSE: Inserts a record into VEA_PACKAGES table

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_package_id             IN     vea_packages.package_id%TYPE,
          p_client_server_flag     IN     vea_packages.client_server_flag%TYPE,
          p_generate_flag          IN     vea_packages.generate_flag%TYPE,
          p_tpa_flag               IN     vea_packages.tpa_flag%TYPE,
          p_name                   IN     vea_packages.name%TYPE,
          p_specification_filename IN     vea_packages.specification_filename%TYPE,
          p_body_filename          IN     vea_packages.body_filename%TYPE,
          p_label                  IN     vea_packages.label%TYPE,
          p_version_number         IN     vea_packages.version_number%TYPE,
          p_description            IN     vea_packages.description%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_tp_layer_id            IN     vea_packages.tp_layer_id%TYPE
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
	INSERT INTO vea_packages
	  (
	    layer_provider_code, package_id,
	    client_server_flag,
	    name, label,
	    generate_flag, tpa_flag,
	    specification_filename, body_filename,
	    --version_number,
	    description,
	    application_short_name, tp_layer_id,
	    created_by, creation_date,
	    last_updated_by, last_update_date,
	    last_update_login
	  )
	VALUES
	  (
	    p_layer_provider_code, p_package_id,
	    p_client_server_flag,
	    UPPER(p_name), p_label,
	    p_generate_flag, p_tpa_flag,
	    p_specification_filename, p_body_filename,
	    --p_version_number,
	    p_description,
	    UPPER(p_application_short_name), p_tp_layer_id,
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

       PURPOSE: Updates a record into VEA_PACKAGES table

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_package_id             IN     vea_packages.package_id%TYPE,
          p_client_server_flag     IN     vea_packages.client_server_flag%TYPE,
          p_generate_flag          IN     vea_packages.generate_flag%TYPE,
          p_tpa_flag               IN     vea_packages.tpa_flag%TYPE,
          p_name                   IN     vea_packages.name%TYPE,
          p_specification_filename IN     vea_packages.specification_filename%TYPE,
          p_body_filename          IN     vea_packages.body_filename%TYPE,
          p_label                  IN     vea_packages.label%TYPE,
          p_version_number         IN     vea_packages.version_number%TYPE,
          p_description            IN     vea_packages.description%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_tp_layer_id            IN     vea_packages.tp_layer_id%TYPE
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
	UPDATE vea_packages
	SET    client_server_flag           = p_client_server_flag,
	       name                         = p_name,
	       label                        = p_label,
	       generate_flag                = p_generate_flag,
	       tpa_flag                     = p_tpa_flag,
	       specification_filename       = p_specification_filename,
	       body_filename                = p_body_filename,
	       --version_number               = p_version_number,
	       description                  = p_description,
	       application_short_name       = p_application_short_name,
	       tp_layer_id                  = p_tp_layer_id,
	       last_updated_by              = l_user_id,
	       last_update_date             = SYSDATE,
	       last_update_login            = l_login_id
	WHERE  layer_provider_code          = p_layer_provider_code
	AND    package_id                   = p_package_id;
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

       PROCEDURE NAME: deleteUnreferencedPackages

       PURPOSE: Deletes all TPA packages which do not have any program units.
    ========================================================================*/
    PROCEDURE
      deleteUnreferencedPackages
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'deleteUnreferencedPackages';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF vea_tpa_util_pvt.get_curr_layer_provider_code = vea_tpa_util_pvt.G_ORACLE
	THEN
	--{
	    delete vea_packages PK
	    where  tpa_flag = 'Y'
	    and    not exists ( select 1
				from   vea_program_units PU
				where  PU.layer_provider_code = PK.layer_provider_code
				AND    PU.package_id          = PK.package_id
			      );
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
    END deleteUnreferencedPackages;
    --
    --
    /*========================================================================

       PROCEDURE NAME: delete_rows

       PURPOSE: Deletes all packages developed by specified layer provider and
		used in the specified TP layer of any customizable program
		units of the specified application.

		It first queries all packages developed by specified layer
		provider and belonging to the specified TP Layer.

		For each package,
		  - it deletes all program units ( and their parameters ),
		    if
		     - it unit is not a TPS program unit
		       AND it is used in the specified TP layer in any
		       customizable program units of the specified application.
		     OR
		     - if it is a TPS program unit and not used anywhere.
		 - It deletes the package, if it has no more program units.
		 - It updates the TP_LAYER_ID to null, if it has only TPS
		   program units.
    ========================================================================*/
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
          p_tp_layer_id               IN     vea_tp_layers.tp_layer_id%TYPE,
          p_application_short_name    IN     vea_packages.application_short_name%TYPE,
	  x_package_count             OUT NOCOPY     NUMBER
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
	CURSOR package_cur
                 (
                   p_layer_provider_code       IN     vea_layer_headers.layer_provider_code%TYPE,
                   p_tp_layer_id               IN     vea_tp_layers.tp_layer_id%TYPE
                 )
	IS
	  SELECT package_id
	  FROM   vea_packages
	  WHERE  layer_provider_code     = p_layer_provider_code
	  AND    tp_layer_id             = p_tp_layer_id;
	--
	--
	l_program_unit_count          NUMBER;
	l_tps_program_unit_count      NUMBER;
	l_package_count               NUMBER;
	--
	--
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	l_package_count := 0;
	--
	--
	l_location := '0020';
	--
	FOR package_rec IN package_cur
			   (
			     p_layer_provider_code    => p_layer_provider_code,
			     p_tp_layer_id            => p_tp_layer_id
			   )
	LOOP
	--{
	    l_location := '0030';
	    --
	    vea_program_units_sv.delete_rows
	      (
		p_layer_provider_code    => p_layer_provider_code,
		p_tp_layer_id            => p_tp_layer_id,
		p_package_id             => package_rec.package_id,
		p_application_short_name => p_application_short_name,
		x_program_unit_count     => l_program_unit_count,
		x_tps_program_unit_count => l_tps_program_unit_count
	      );
	    --
	    --
	    l_location := '0040';
	    --
	    IF l_program_unit_count = 0
	    THEN
	    --{
	        l_location := '0050';
	        --
	        DELETE vea_packages
	        WHERE  layer_provider_code = p_layer_provider_code
	        AND    package_id          = package_rec.package_id;
	    --}
	    ELSE
	    --{
	        l_location := '0060';
	        --
		IF l_program_unit_count = l_tps_program_unit_count
		THEN
		--{
	            l_location := '0070';
	            --
	            UPDATE vea_packages
		    SET    tp_layer_id         = null
	            WHERE  layer_provider_code = p_layer_provider_code
	            AND    package_id          = package_rec.package_id;
		--}
		ELSE
		--{
                    l_package_count := l_package_count + 1;
		--}
		END IF;
	    --}
	    END IF;
	--}
	END LOOP;
	--
	--
	l_location := '0080';
	--
	x_package_count := NVL(l_package_count,0);
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

       PROCEDURE NAME: getVersionNumber

       PURPOSE: Increment the input version number by 1. Returns '115.0' if
		input version number is NULL.

    ========================================================================*/
    FUNCTION
      getVersionNumber
        (
	  p_version_number         IN     vea_packages.version_number%TYPE
        )
    RETURN VARCHAR2
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'getVersionNumber';
        l_location            VARCHAR2(32767);
	--
	--
	l_pos NUMBER;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF p_version_number is NULL
	THEN
	    RETURN('115.0');
	END IF;
	--
	--
	l_location := '0020';
	--
	l_pos := INSTR( p_version_number, '.' );
	--
	--
	l_location := '0030';
	--
	RETURN(
		SUBSTR(p_version_number,1,l_pos)
		|| ( SUBSTR(p_version_number,l_pos+1) + 1)
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
    END getVersionNumber;
    --
    --
    /*========================================================================

       PROCEDURE NAME: updateVersionNumber

       PURPOSE: Increments version number by 1 for the specified package.

    ========================================================================*/
    PROCEDURE
      updateVersionNumber
        (
          p_api_version            IN	  NUMBER,
          p_init_msg_list	   IN	  VARCHAR2 := FND_API.G_FALSE,
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level	   IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status	   OUT NOCOPY 	  VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_package_id             IN     vea_packages.package_id%TYPE,
	  x_version_number         OUT NOCOPY     VARCHAR2,
	  p_user_name		   IN	  VARCHAR2
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'updateVersionNumber';
        l_api_version         CONSTANT NUMBER       := 1.0;
        l_api_type            CONSTANT VARCHAR2(3)  := vea_tpa_util_pvt.G_PUBLIC_API;
	--
	--
        l_location            VARCHAR2(32767);
	l_savepoint_name      VARCHAR2(30);
	--
	--
        CURSOR pkg_cur
	IS
	  SELECT version_number, name
	  FROM   vea_packages
	  WHERE  layer_provider_code = p_layer_provider_code
	  AND    package_id          = p_package_id;
	--
	--
	l_version_number     vea_packages.version_number%TYPE;
	l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
	l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;

        l_version_text		VARCHAR2(200);

    --}
    BEGIN
    --{
	--
	-- Standard API Header
	--
	l_location := '0010';
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
	l_location := '0020';
	--
	FOR pkg_rec IN pkg_cur
	LOOP
	--{
	    l_location := '0030';
	    --
	    begin
	    	--
	    	select SUBSTRB(text, INSTRB(text, ' ',1,3) + 1 , INSTRB(text, ' ',1,4) - INSTRB(text, ' ',1,3))
	    	into l_version_text
	    	from all_source
	    	where name	= pkg_rec.name
	    	and type	='PACKAGE'
	    	and owner	= UPPER(p_user_name)
	    	and text	like '%$Head%';
	    	--
	    	pkg_rec.version_number := l_version_text;
	    	--
	    exception when others
	    then
	    	null;
	    --
	    end;
	    --
	    l_version_number := getVersionNumber(pkg_rec.version_number);
	    --
	    --
	    l_location := '0040';
	    --
	    UPDATE vea_packages
	    SET    version_number               = l_version_number,
	           last_updated_by              = l_user_id,
	           last_update_date             = SYSDATE,
	           last_update_login            = l_login_id
	    WHERE  layer_provider_code          = p_layer_provider_code
	    AND    package_id                   = p_package_id;
	--}
	END LOOP;
	--
	--
	l_location := '0050';
	--
	x_version_number := l_version_number;
	--
	--
	--} API Body
	--
	--
	-- Standard  API Footer
	--
	l_location := '0060';
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
    END updateVersionNumber;
    --
    --
    /*========================================================================

       PROCEDURE NAME: updateVersionNumber

       PURPOSE: Increments version number by 1 for all the packages in the
		specified client-side library file.

    ========================================================================*/
    PROCEDURE
      updateVersionNumber
        (
          p_api_version            IN	  NUMBER,
          p_init_msg_list	   IN	  VARCHAR2 := FND_API.G_FALSE,
          p_commit    		   IN  	  VARCHAR2 := FND_API.G_FALSE,
          p_validation_level	   IN  	  NUMBER   := FND_API.G_VALID_LEVEL_FULL,
          x_return_status	   OUT NOCOPY 	  VARCHAR2,
          x_msg_count	           OUT NOCOPY 	  NUMBER,
          x_msg_data		   OUT NOCOPY 	  VARCHAR2,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_specification_filename IN     vea_packages.specification_filename%TYPE,
	  x_version_number         OUT NOCOPY     VARCHAR2,
	  p_user_name		   IN	  VARCHAR2
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'updateVersionNumber';
        l_api_version         CONSTANT NUMBER       := 1.0;
        l_api_type            CONSTANT VARCHAR2(3)  := vea_tpa_util_pvt.G_PUBLIC_API;
	--
	--
        l_location            VARCHAR2(32767);
	l_savepoint_name      VARCHAR2(30);
	--
	--
        CURSOR pkg_cur
	IS
	  SELECT package_id,
		 layer_provider_code,
		 version_number,
		 name
	  FROM   vea_packages
	  WHERE specification_filename  = p_specification_filename;

	--
	--
	l_version_number     vea_packages.version_number%TYPE;
	l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
	l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
        l_version_text		VARCHAR2(200);
    --}
    BEGIN
    --{
	--
	-- Standard API Header
	--
	l_location := '0010';
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
	l_location := '0020';
	--
	FOR pkg_rec IN pkg_cur
	LOOP
	--{
	    l_location := '0030';
	    --
	    begin
	    	--
	    	select SUBSTRB(text, INSTRB(text, ' ',1,3) + 1 , INSTRB(text, ' ',1,4) - INSTRB(text, ' ',1,3))
	    	into l_version_text
	    	from all_source
	    	where name	= pkg_rec.name
	    	and type	='PACKAGE'
	    	and owner	= UPPER(p_user_name)
	    	and text	like '%$Head%';
	    	--
	    	pkg_rec.version_number := l_version_text;
	    	--
	    exception when others
	    then
	    	null;
	    --
	    end;
	    --
	    l_version_number := getVersionNumber(pkg_rec.version_number);
	    --
	    --
	    l_location := '0040';
	    --
	    UPDATE vea_packages
	    SET    version_number               = l_version_number,
	           last_updated_by              = l_user_id,
	           last_update_date             = SYSDATE,
	           last_update_login            = l_login_id
	    WHERE  layer_provider_code          = pkg_rec.layer_provider_code
	    AND    package_id                   = pkg_rec.package_id;
	--}
	END LOOP;
	--
	--
	l_location := '0050';
	--
	x_version_number := l_version_number;
	--
	--
	--} API Body
	--
	--
	-- Standard  API Footer
	--
	l_location := '0060';
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
    END updateVersionNumber;
    --
    --
    /*========================================================================

       PROCEDURE NAME: getId

       PURPOSE:

    ========================================================================*/
    FUNCTION
      getId
        (
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_client_server_flag     IN     vea_packages.client_server_flag%TYPE,
          p_name                   IN     vea_packages.name%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE
        )
    RETURN NUMBER
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'getId';
        l_location            VARCHAR2(32767);
	--
	--
	CURSOR package_cur
		 (
                   p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
                   p_application_short_name IN     vea_packages.application_short_name%TYPE,
                   p_client_server_flag     IN     vea_packages.client_server_flag%TYPE,
                   p_name                   IN     vea_packages.name%TYPE
		 )
	IS
	  SELECT package_id
	  FROM   vea_packages
	  WHERE  layer_provider_code     = p_layer_provider_code
	  AND    application_short_name  = p_application_short_name
	  AND    client_server_flag      = p_client_server_flag
	  AND    UPPER(name)                    = UPPER(p_name);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR package_rec IN package_cur
			     (
                               p_layer_provider_code    => p_layer_provider_code,
                               p_application_short_name => p_application_short_name,
                               p_client_server_flag     => p_client_server_flag,
                               p_name                   => p_name
			     )
	LOOP
	--{
	    l_location := '0020';
	    --
	    RETURN (package_rec.package_id);
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

       PURPOSE: Table hadndler API for VEA_PACKAGES table.

		It inserts/updates a record in VEA_PACKAGES table.

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
          x_id                     OUT NOCOPY     vea_packages.package_id%TYPE,
          p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
          p_client_server_flag     IN     vea_packages.client_server_flag%TYPE,
          p_generate_flag          IN     vea_packages.generate_flag%TYPE,
          p_tpa_flag               IN     vea_packages.tpa_flag%TYPE,
          p_name                   IN     vea_packages.name%TYPE,
          p_specification_filename IN     vea_packages.specification_filename%TYPE,
          p_body_filename          IN     vea_packages.body_filename%TYPE,
          p_label                  IN     vea_packages.label%TYPE,
          p_version_number         IN     vea_packages.version_number%TYPE,
          p_description            IN     vea_packages.description%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
          p_tp_layer_id            IN     vea_packages.tp_layer_id%TYPE,
          p_id                     IN     vea_packages.package_id%TYPE   := NULL
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
	l_package_id          vea_packages.package_id%TYPE;
	l_tp_layer_id         vea_tp_layers.tp_layer_id%TYPE;
	--
	--
	CURSOR package_cur
		 (
                   p_layer_provider_code    IN     vea_packages.layer_provider_code%TYPE,
                   --p_package_id             IN     vea_packages.package_id%TYPE,
                   p_application_short_name IN     vea_packages.application_short_name%TYPE,
                   p_client_server_flag     IN     vea_packages.client_server_flag%TYPE,
                   p_name                   IN     vea_packages.name%TYPE
		 )
	IS
	  SELECT package_id
	  FROM   vea_packages
	  WHERE  layer_provider_code     = p_layer_provider_code
	  AND    application_short_name  = p_application_short_name
	  AND    client_server_flag      = p_client_server_flag
	  AND    name                    = p_name;
          -- Commented out this code because we no longer base our processing on the ids
          -- stored in the flat file.  We go by the names of the packages
          -- and derive the ids based on the names and use the derived ids
          -- in further processing.
          /*
	  AND    (
		   (
		         p_package_id IS NOT NULL
		     AND package_id   = p_package_id
		   )
		   OR
		   (
		         p_package_id IS NULL
	             AND application_short_name  = p_application_short_name
	             AND client_server_flag      = p_client_server_flag
	             AND name                    = p_name
		   )
		 );
           */
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
	--g_package_id := p_id;
        l_tp_layer_id := p_tp_layer_id;
        g_tp_layer_id := NULL;
	--
        IF (VEA_TPA_UTIL_PVT.isLayerMergeOn)
	AND p_tp_layer_id IS NOT NULL
	THEN
        --{
	    vea_tpa_util_pvt.get
	      (
	        p_key                => p_tp_layer_id,
	        p_cache_tbl          => VEA_TPA_UTIL_PVT.g_tpLyr_fileId_dbId_tbl,
	        p_cache_ext_tbl      => VEA_TPA_UTIL_PVT.g_tpLyr_fileId_dbId_ext_tbl,
	        x_value              => l_tp_layer_id
	      );
        --}
        ELSE
        --{
            l_tp_layer_id := p_tp_layer_id;
        --}
        END IF;
	--
        g_tp_layer_id := l_tp_layer_id;
	--
	IF vea_layer_licenses_sv.isLicensed
	     (
	       p_layer_provider_code => p_layer_provider_code,
	       p_tp_layer_id         => l_tp_layer_id
	     )
        THEN
	--{
	    l_location := '0035';
	    --
	    l_package_id := NULL;
	    --
	    --
	    g_package_id := NULL;
	    --
	    --
	    l_location := '0040';
	    --
	    --
	    l_package_id := getId
			         (
                                   p_layer_provider_code    => p_layer_provider_code,
                                   --p_package_id             => p_id,
                                   p_application_short_name => p_application_short_name,
                                   p_client_server_flag     => p_client_server_flag,
                                   p_name                   => p_name
			         );
	    --
	    --
	    l_location := '0050';
	    --
	    g_package_id := l_package_id;
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_package_id is ' || l_package_id);
	    --
	    --
	    l_location := '0060';
	    --
	    IF l_package_id IS NULL
	    THEN
	    --{
	        l_location := '0070';
	        --
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' Inserting a row in vea_packages');
	        --
	        IF p_layer_provider_code = vea_tpa_util_pvt.g_current_layer_provider_code
	        THEN
	            SELECT NVL( p_id, vea_packages_s.NEXTVAL )
	            INTO   l_package_id
	            FROM   DUAL;
	        ELSE
	            SELECT vea_packages_s.NEXTVAL
	            INTO   l_package_id
	            FROM   DUAL;
	        END IF;
	        --
	        --
	        --
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_package_id ' || l_package_id);
	        l_location := '0080';
	        --
	        validate
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_package_id                   => l_package_id,
	            p_client_server_flag           => p_client_server_flag,
	            p_name                         => p_name,
	            p_label                        => p_label,
	            p_generate_flag                => p_generate_flag,
	            p_tpa_flag                     => p_tpa_flag,
	            p_specification_filename       => p_specification_filename,
	            p_body_filename                => p_body_filename,
	            p_version_number               => p_version_number,
	            p_description                  => p_description,
	            p_application_short_name       => p_application_short_name,
	            p_tp_layer_id                  => l_tp_layer_id
	          );
	        --
	        --
	        l_location := '0090';
	        --
	        insert_row
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_package_id                   => l_package_id,
	            p_client_server_flag           => p_client_server_flag,
	            p_name                         => p_name,
	            p_label                        => p_label,
	            p_generate_flag                => p_generate_flag,
	            p_tpa_flag                     => p_tpa_flag,
	            p_specification_filename       => p_specification_filename,
	            p_body_filename                => p_body_filename,
	            p_version_number               => p_version_number,
	            p_description                  => p_description,
	            p_application_short_name       => p_application_short_name,
	            p_tp_layer_id                  => l_tp_layer_id
	          );
                --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' l_package_id 2 =  ' || l_package_id);
                -- This very important, otherwise insert on program unit will fail
	        g_package_id := l_package_id;
	    --}
	    ELSE
	    --{
	        l_location := '0100';
	        --
	        validate
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_package_id                   => l_package_id,
	            p_client_server_flag           => p_client_server_flag,
	            p_name                         => p_name,
	            p_label                        => p_label,
	            p_generate_flag                => p_generate_flag,
	            p_tpa_flag                     => p_tpa_flag,
	            p_specification_filename       => p_specification_filename,
	            p_body_filename                => p_body_filename,
	            p_version_number               => p_version_number,
	            p_description                  => p_description,
	            p_application_short_name       => p_application_short_name,
	            p_tp_layer_id                  => l_tp_layer_id
	          );
	        --
	        --
	        l_location := '0110';
	        --
	        update_row
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_package_id                   => l_package_id,
	            p_client_server_flag           => p_client_server_flag,
	            p_name                         => p_name,
	            p_label                        => p_label,
	            p_generate_flag                => p_generate_flag,
	            p_tpa_flag                     => p_tpa_flag,
	            p_specification_filename       => p_specification_filename,
	            p_body_filename                => p_body_filename,
	            p_version_number               => p_version_number,
	            p_description                  => p_description,
	            p_application_short_name       => p_application_short_name,
	            p_tp_layer_id                  => l_tp_layer_id
	          );
	    --}
	    END IF;
	    --
	    --
	    l_location := '0120';
	    --
	    x_id := l_package_id;
	    --
	    --
	--}
	END IF;
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
END VEA_PACKAGES_SV;

/
