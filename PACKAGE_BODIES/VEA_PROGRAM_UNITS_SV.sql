--------------------------------------------------------
--  DDL for Package Body VEA_PROGRAM_UNITS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_PROGRAM_UNITS_SV" as
/* $Header: VEAVAPUB.pls 115.14 2004/07/27 02:42:47 rvishnuv ship $      */
--{
    /*======================  vea_program_units_sv  =========================*/
    /*========================================================================
       PURPOSE:  Table handler package for table VEA_PROGRAM_UNITS

       NOTES:                To run the script:

                             sql> start VEAVAPKB.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_PROGRAM_UNITS_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME: insert_row

       PURPOSE: Inserts a record into VEA_PROGRAM_UNITS table

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_layer_provider_code    IN     vea_program_units.layer_provider_code%TYPE,
          p_program_unit_id        IN     vea_program_units.program_unit_id%TYPE,
          p_package_id             IN     vea_program_units.program_unit_id%TYPE,
          p_program_unit_type      IN     vea_program_units.program_unit_type%TYPE,
          p_public_flag            IN     vea_program_units.public_flag%TYPE,
          p_customizable_flag      IN     vea_program_units.customizable_flag%TYPE,
          p_tps_flag               IN     vea_program_units.tps_flag%TYPE,
          p_name                   IN     vea_program_units.name%TYPE,
          p_label                  IN     vea_program_units.label%TYPE,
          p_return_type            IN     vea_program_units.return_type%TYPE,
          p_tpa_program_unit_id    IN     vea_program_units.tpa_program_unit_id%TYPE,
          p_description            IN     vea_program_units.description%TYPE
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
	INSERT INTO vea_program_units
	  (
	    layer_provider_code, program_unit_id,
	    package_id, program_unit_type,
	    name, label,
	    public_flag, customizable_flag,
	    tps_flag,
	    return_type, tpa_program_unit_id,
	    description,
	    created_by, creation_date,
	    last_updated_by, last_update_date,
	    last_update_login
	  )
	VALUES
	  (
	    p_layer_provider_code, p_program_unit_id,
	    p_package_id, p_program_unit_type,
	    p_name, p_label,
	    p_public_flag, p_customizable_flag,
	    p_tps_flag,
	    p_return_type, p_tpa_program_unit_id,
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

       PURPOSE: Updates a record into VEA_PROGRAM_UNITS table

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_layer_provider_code    IN     vea_program_units.layer_provider_code%TYPE,
          p_program_unit_id        IN     vea_program_units.program_unit_id%TYPE,
          p_package_id             IN     vea_program_units.program_unit_id%TYPE,
          p_program_unit_type      IN     vea_program_units.program_unit_type%TYPE,
          p_public_flag            IN     vea_program_units.public_flag%TYPE,
          p_customizable_flag      IN     vea_program_units.customizable_flag%TYPE,
          p_tps_flag               IN     vea_program_units.tps_flag%TYPE,
          p_name                   IN     vea_program_units.name%TYPE,
          p_label                  IN     vea_program_units.label%TYPE,
          p_return_type            IN     vea_program_units.return_type%TYPE,
          p_tpa_program_unit_id    IN     vea_program_units.tpa_program_unit_id%TYPE,
          p_description            IN     vea_program_units.description%TYPE
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
	UPDATE vea_program_units
	SET    package_id                   = p_package_id,
	       program_unit_type            = p_program_unit_type,
	       name                         = p_name,
	       label                        = p_label,
	       public_flag                  = p_public_flag,
	       customizable_flag            = p_customizable_flag,
	       tps_flag                     = p_tps_flag,
	       return_type                  = p_return_type,
	       tpa_program_unit_id          = p_tpa_program_unit_id,
	       description                  = p_description,
	       last_updated_by              = l_user_id,
	       last_update_date             = SYSDATE,
	       last_update_login            = l_login_id
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
    END update_row;
    --
    --
    /*========================================================================

       PROCEDURE NAME: delete_row

       PURPOSE: Deletes all parameters of the specified program unit and
		program unit itself.

    ========================================================================*/
    PROCEDURE
      delete_row
        (
          p_layer_provider_code   IN     vea_layers.layer_provider_code%TYPE,
          p_program_unit_id       IN     vea_program_units.program_unit_id%TYPE
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
	vea_parameters_sv.delete_rows
	  (
            p_layer_provider_code  => p_layer_provider_code,
            p_program_unit_id      => p_program_unit_id
	  );
	--
	--
	l_location := '0020';
	--
        DELETE vea_program_units
        WHERE  layer_provider_code  = p_layer_provider_code
        AND    program_unit_id      = p_program_unit_id;
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

       PURPOSE: Deletes all packages developed by specified layer provider and
		used in the specified TP layer of any customizable program
		units of the specified application.

		It first queries all program units developed by specified layer
		provider and belonging to the specified package.

		For each program unit,
		  - it deletes the program units ( and their parameters ),
		    if
		     - it unit is not a TPS program unit
		       AND it is used in the specified TP layer in any
		       customizable program units of the specified application.
		     OR
		     - if it is a TPS program unit and not used anywhere.

    ========================================================================*/
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code    IN     vea_layers.layer_provider_code%TYPE,
          p_tp_layer_id            IN     vea_tp_layers.tp_layer_id%TYPE,
          p_package_id             IN     vea_packages.package_id%TYPE,
          p_application_short_name IN     vea_packages.application_short_name%TYPE,
	  x_program_unit_count     OUT NOCOPY     NUMBER,
	  x_tps_program_unit_count OUT NOCOPY     NUMBER
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'delete_rows';
        l_location            VARCHAR2(32767);
	--
	--
	CURSOR program_unit_cur
                 (
                   p_layer_provider_code  IN  vea_layers.layer_provider_code%TYPE,
                   p_package_id           IN  vea_packages.package_id%TYPE
                 )
        IS
          SELECT program_unit_id,
		 layer_provider_code,
		 tps_flag
          FROM   vea_program_units
          WHERE  layer_provider_code   = p_layer_provider_code
          AND    package_id            = p_package_id;
       --
       --
	CURSOR tps_cur
                 (
                   p_tps_program_unit_lp_code  IN  vea_layers.layer_provider_code%TYPE,
                   p_tps_program_unit_id       IN  vea_program_units.program_unit_id%TYPE
                 )
        IS
          SELECT 'x'
          FROM   vea_layer_headers
          WHERE  tps_program_unit_lp_code = p_tps_program_unit_lp_code
          AND    tps_program_unit_id      = p_tps_program_unit_id;
       --
       --
	CURSOR application_cur
                 (
                   p_layer_provider_code  IN  vea_layers.layer_provider_code%TYPE,
                   p_tp_layer_id          IN  vea_tp_layers.tp_layer_id%TYPE,
                   p_package_id           IN  vea_packages.package_id%TYPE,
                   p_program_unit_id      IN  vea_program_units.program_unit_id%TYPE
                 )
        IS
          SELECT PK.application_short_name
          FROM   vea_program_units LPU,
		 vea_layer_headers LH,
		 vea_packages PK,
		 vea_program_units PU,
		 vea_layers_v LA
          WHERE  LA.layer_provider_code    = p_layer_provider_code
	  AND    LA.tp_layer_id            = p_tp_layer_id
	  AND    LH.layer_provider_code    = LA.layer_provider_code
	  AND    LH.layer_header_id        = LA.layer_header_id
	  AND    PU.program_unit_id        = LH.program_unit_id
	  AND    PU.layer_provider_code    = LH.program_unit_lp_code
	  AND    PK.package_id             = PU.package_id
	  AND    PK.layer_provider_code    = PU.layer_provider_code
	  AND    PK.tpa_flag               = 'Y'
	  AND    PU.tpa_program_unit_id    IS NOT NULL
          AND    LPU.package_id            = p_package_id
	  AND    LPU.program_unit_id       = p_program_unit_id
	  AND    LPU.program_unit_id       = LA.new_program_unit_id
	  AND    LPU.layer_provider_code   = LA.program_unit_lp_code;
       --
       --
       l_program_unit_count     NUMBER := 0;
       l_tps_program_unit_count NUMBER := 0;
       l_layer_header_count     NUMBER := 0;
       l_count                  NUMBER := 0;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	l_program_unit_count     := 0;
	l_tps_program_unit_count := 0;
	l_layer_header_count     := 0;
	--
	--
	l_location := '0020';
	--
	FOR program_unit_rec IN program_unit_cur
			   (
			     p_layer_provider_code => p_layer_provider_code,
			     p_package_id          => p_package_id
			   )
	LOOP
	--{
	    l_location := '0030';
	    --
	    IF program_unit_rec.tps_flag = 'N'
	    THEN
	    --{
	        l_location := '0040';
	        --
		l_count := 0;
		--
		--
	        l_location := '0050';
	        --
		FOR application_rec IN application_cur
			   (
			     p_layer_provider_code => p_layer_provider_code,
			     p_tp_layer_id         => p_tp_layer_id,
			     p_package_id          => p_package_id,
			     p_program_unit_id     => program_unit_rec.program_unit_id
			   )
		LOOP
		--{
	            l_location := '0060';
	            --
		    IF application_rec.application_short_name
		       <>
		       NVL(
			    p_application_short_name,
			    application_rec.application_short_name
			  )
		    THEN
		    --{
	                l_location := '0070';
	                --
		        l_count := l_count + 1;
		    --}
		    END IF;
		--}
		END LOOP;
		--
		--
	        l_location := '0080';
	        --
		IF l_count = 0
		THEN
		--{
	            l_location := '0090';
	            --
	            delete_row
	              (
		        p_layer_provider_code => program_unit_rec.layer_provider_code,
		        p_program_unit_id     => program_unit_rec.program_unit_id
	              );
		--}
		ELSE
		--{
	            l_location := '0100';
	            --
		    l_program_unit_count := l_program_unit_count + 1;
		--}
		END IF;
	    --}
	    ELSE
	    --{
	        l_location := '0110';
	        --
		l_layer_header_count := 0;
		--
		--
	        l_location := '0120';
	        --
		FOR tps_rec IN tps_cur
				 (
				   p_tps_program_unit_lp_code => program_unit_rec.layer_provider_code,
				   p_tps_program_unit_id      => program_unit_rec.program_unit_id
				 )
		LOOP
		--{
	            l_location := '0130';
	            --
		    l_layer_header_count := l_layer_header_count + 1;
		--}
		END LOOP;
		--
		--
	        l_location := '0140';
	        --
		IF l_layer_header_count = 0
		THEN
		--{
	            l_location := '0150';
	            --
		    delete_row
	              (
		        p_layer_provider_code => program_unit_rec.layer_provider_code,
		        p_program_unit_id     => program_unit_rec.program_unit_id
	              );
		--}
		ELSE
		--{
	            l_location := '0160';
	            --
		    l_program_unit_count     := l_program_unit_count + 1;
		    l_tps_program_unit_count := l_tps_program_unit_count + 1;
		--}
		END IF;
	    --}
	    END IF;
	--}
	END LOOP;
	--
	--
	l_location := '0170';
	--
	x_program_unit_count     := NVL(l_program_unit_count,0);
	x_tps_program_unit_count := NVL(l_tps_program_unit_count,0);
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

       PROCEDURE NAME: getName

       PURPOSE:

    ========================================================================*/
    PROCEDURE
      getName
        (
          p_layer_provider_code    IN     vea_program_units.layer_provider_code%TYPE,
          p_program_unit_id        IN     vea_program_units.program_unit_id%TYPE,
          x_program_unit_name      OUT NOCOPY     vea_program_units.name%TYPE,
	  x_package_name           OUT NOCOPY     vea_packages.name%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'getName';
        l_location            VARCHAR2(32767);
	--
	--
	l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
	l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
	CURSOR program_unit_cur
	IS
	  SELECT PU.name program_unit_name,
		 PK.name package_name
          FROM   vea_program_units PU,
		 vea_packages PK
          WHERE  PU.layer_provider_code = p_layer_provider_code
	  AND    PU.program_unit_id     = p_program_unit_id
	  AND    PK.layer_provider_code = PU.layer_provider_code
	  AND    PK.package_id          = PU.package_id;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR program_unit_rec IN program_unit_cur
	LOOP
	--{
	    l_location := '0020';
	    --
	    x_program_unit_name := program_unit_rec.program_unit_name;
	    x_package_name      := program_unit_rec.package_name;
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
    END getName;
    --
    --
    /*========================================================================

       PROCEDURE NAME: validateMapping

       PURPOSE:

    ========================================================================*/
    PROCEDURE
      validateMapping
        (
          p_layer_provider_code     IN     vea_program_units.layer_provider_code%TYPE,
          p_program_unit_id         IN     vea_program_units.program_unit_id%TYPE,
          p_tpa_program_unit_id     IN     vea_program_units.tpa_program_unit_id%TYPE,
          p_old_tpa_program_unit_id IN     vea_program_units.tpa_program_unit_id%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'validateMapping';
        l_location            VARCHAR2(32767);
	--
	--
	l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
	l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
	l_program_unit_name     vea_program_units.name%TYPE;
	l_package_name          vea_packages.name%TYPE;
	l_pub_program_unit_name vea_program_units.name%TYPE;
	l_pub_package_name      vea_packages.name%TYPE;
	l_tpa_program_unit_name vea_program_units.name%TYPE;
	l_tpa_package_name      vea_packages.name%TYPE;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF  vea_tpa_util_pvt.validate
	AND NOT(vea_tpa_util_pvt.isLayerMergeOn)
	AND p_old_tpa_program_unit_id <> p_tpa_program_unit_id
	THEN
	--{
	    l_location := '0020';
	    --
	    getName
	      (
		p_layer_provider_code => p_layer_provider_code,
		p_program_unit_id     => p_program_unit_id,
		x_program_unit_name => l_tpa_program_unit_name,
		x_package_name      => l_tpa_package_name
	      );
	    --
	    --
	    l_location := '0020';
	    --
	    getName
	      (
		p_layer_provider_code => p_layer_provider_code,
		p_program_unit_id     => p_old_tpa_program_unit_id,
		x_program_unit_name => l_program_unit_name,
		x_package_name      => l_package_name
	      );
	    --
	    --
	    l_location := '0020';
	    --
	    getName
	      (
		p_layer_provider_code => p_layer_provider_code,
		p_program_unit_id     => p_tpa_program_unit_id,
		x_program_unit_name => l_pub_program_unit_name,
		x_package_name      => l_pub_package_name
	      );
	    --
	    --
	    l_location := '0020';
	    --
	    vea_tpa_util_pvt.add_message_and_raise
	      (
	        p_error_name => 'VEA_IMPORT_DUP_TPA_MAPPING',
	        p_token1     => 'TPA_PROGRAM_UNIT_NAME',
	        p_value1     => l_tpa_program_unit_name,
	        p_token2     => 'TPA_PACKAGE_NAME',
	        p_value2     => l_tpa_package_name,
	        p_token3     => 'PROGRAM_UNIT_NAME',
	        p_value3     => l_program_unit_name,
	        p_token4     => 'PACKAGE_NAME',
	        p_value4     => l_package_name,
	        p_token5     => 'PUB_PROGRAM_UNIT_NAME',
	        p_value5     => l_pub_program_unit_name,
	        p_token6     => 'PUB_PACKAGE_NAME',
	        p_value6     => l_pub_package_name
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
    END validateMapping;
    --
    --
    /*========================================================================

       PROCEDURE NAME: deleteUnreferencedProgramUnits

       PURPOSE:

    ========================================================================*/
    PROCEDURE
      deleteUnreferencedProgramUnits
        (
          p_layer_provider_code     IN     vea_program_units.layer_provider_code%TYPE,
          p_program_unit_id         IN     vea_program_units.program_unit_id%TYPE,
          p_tpa_program_unit_id     IN     vea_program_units.tpa_program_unit_id%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'deleteUnreferencedProgramUnits';
        l_location            VARCHAR2(32767);
	--
	--
	l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
	l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
	CURSOR program_unit_cur
	IS
	  SELECT program_unit_id
	  FROM   vea_program_units
	  WHERE  tpa_program_unit_id = p_tpa_program_unit_id
	  AND    layer_provider_code = p_layer_provider_code;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR program_unit_rec IN program_unit_cur
	LOOP
	--{
	    l_location := '0020';
	    --
	    IF program_unit_rec.program_unit_id <> p_program_unit_id
	    THEN
	    --{
	        l_location := '0030';
	        --
		delete_row
		  (
		    p_layer_provider_code => p_layer_provider_code,
		    p_program_unit_id     => program_unit_rec.program_unit_id
		  );
	    --}
	    END IF;
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
    END deleteUnreferencedProgramUnits;
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
          p_layer_provider_code    IN     vea_program_units.layer_provider_code%TYPE,
          p_package_id             IN     vea_program_units.package_id%TYPE,
          p_name                   IN     vea_program_units.name%TYPE
        )
    RETURN NUMBER
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'getId';
        l_location            VARCHAR2(32767);
	--
	--
	CURSOR program_unit_cur
		 (
                   p_layer_provider_code    IN     vea_program_units.layer_provider_code%TYPE,
                   p_package_id             IN     vea_program_units.package_id%TYPE,
                   p_name                   IN     vea_program_units.name%TYPE
		 )
	IS
	  SELECT program_unit_id
	  FROM   vea_program_units
	  WHERE  layer_provider_code = p_layer_provider_code
	  AND    package_id          = p_package_id
	  AND    UPPER(name)                = UPPER(p_name);
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	FOR program_unit_rec IN program_unit_cur
			     (
                               p_layer_provider_code    => p_layer_provider_code,
                               p_package_id              => p_package_id,
                               p_name                   => p_name
			     )
	LOOP
	--{
	    l_location := '0020';
	    --
	    RETURN (program_unit_rec.program_unit_id);
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

       PURPOSE: Table hadndler API for VEA_PROGRAM_UNITS table.

		It inserts/updates a record in VEA_PROGRAM_UNITS table.

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
          x_id                     OUT NOCOPY     vea_program_units.program_unit_id%TYPE,
          p_layer_provider_code    IN     vea_program_units.layer_provider_code%TYPE,
          p_package_id             IN     vea_program_units.program_unit_id%TYPE,
          p_program_unit_type      IN     vea_program_units.program_unit_type%TYPE,
          p_public_flag            IN     vea_program_units.public_flag%TYPE,
          p_customizable_flag      IN     vea_program_units.customizable_flag%TYPE,
          p_tps_flag               IN     vea_program_units.tps_flag%TYPE,
          p_name                   IN     vea_program_units.name%TYPE,
          p_label                  IN     vea_program_units.label%TYPE,
          p_return_type            IN     vea_program_units.return_type%TYPE,
          p_tpa_program_unit_id    IN     vea_program_units.tpa_program_unit_id%TYPE,
          p_description            IN     vea_program_units.description%TYPE,
          p_id                     IN     vea_program_units.program_unit_id%TYPE   := NULL,
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
	l_program_unit_id     vea_program_units.program_unit_id%TYPE;
	l_db_tpa_program_unit_id vea_program_units.tpa_program_unit_id%TYPE;
	l_tpa_program_unit_id vea_program_units.tpa_program_unit_id%TYPE;
	l_package_id          vea_packages.package_id%TYPE;
	l_tp_layer_id         vea_tp_layers.tp_layer_id%TYPE;
	--
	--
	CURSOR program_unit_cur
		 (
                   p_layer_provider_code    IN     vea_program_units.layer_provider_code%TYPE,
                   p_program_unit_id        IN     vea_program_units.program_unit_id%TYPE,
                   p_package_id             IN     vea_program_units.package_id%TYPE,
                   p_name                   IN     vea_program_units.name%TYPE
		 )
	IS
	  SELECT program_unit_id, tpa_program_unit_id
	  FROM   vea_program_units
	  WHERE  layer_provider_code = p_layer_provider_code
	  AND    package_id          = p_package_id
	  AND    UPPER(name)                = UPPER(p_name);
          -- Commented out this code because we no longer base our processing on the ids
          -- stored in the flat file.  We go by the names of the packages
          -- and derive the ids based on the names and use the derived ids
          -- in further processing.
          /*
	  AND    (
		   (
			  p_program_unit_id IS NOT NULL
	             AND  program_unit_id     = p_program_unit_id
		   )
		   OR
		   (
			  p_program_unit_id IS NULL
	             AND  package_id      = p_package_id
	             AND    name          = p_name
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
	g_program_unit_id     := p_id;
        l_tpa_program_unit_id := p_tpa_program_unit_id;
	--
	--
        IF (VEA_TPA_UTIL_PVT.isLayerMergeOn) THEN
        --{
            --FND_FILE.PUT_LINE ( FND_FILE.LOG, ' p_package_id ' || p_package_id);
            --l_package_id := nvl(vea_packages_sv.g_package_id,p_package_id);
	    l_location := '0040';
	    --
            l_package_id := vea_packages_sv.g_package_id;
            l_tp_layer_id := nvl(vea_packages_sv.g_tp_layer_id,p_tp_layer_id);
	    --
	    --
	    IF  p_tpa_program_unit_id IS NOT NULL
	    THEN
            --{
		BEGIN
	        l_location := '0050';
	        --
	        vea_tpa_util_pvt.get
	          (
	            p_key                => p_tpa_program_unit_id,
	            p_cache_tbl          => vea_tpa_util_pvt.g_PU_fileId_dbId_tbl,
	            p_cache_ext_tbl      => vea_tpa_util_pvt.g_PU_fileId_dbId_ext_tbl,
	            x_value              => l_tpa_program_unit_id
	          );
	        EXCEPTION
		   WHEN FND_API.G_EXC_ERROR THEN
		       l_tpa_program_unit_id := NULL;
		END;
            --}
	    END IF;
        --}
        ELSE
        --{
	    l_location := '0060';
	    --
            l_package_id := p_package_id;
            l_tp_layer_id := p_tp_layer_id;
        --}
        END IF;
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
	    l_program_unit_id     := NULL;
	    --l_tpa_program_unit_id := 0;
	    g_program_unit_id     := NULL;
	    --
	    --
	    l_location := '0090';
	    --
	    FOR program_unit_rec IN program_unit_cur
			         (
                                   p_layer_provider_code    => p_layer_provider_code,
                                   p_program_unit_id        => p_id,
                                   p_package_id             => l_package_id,
                                   p_name                   => p_name
			         )
	    LOOP
	    --{
	        l_location := '0100';
	        --
	        l_program_unit_id     := program_unit_rec.program_unit_id;
	        l_db_tpa_program_unit_id := program_unit_rec.tpa_program_unit_id;
	        g_program_unit_id     := program_unit_rec.program_unit_id;
	    --}
	    END LOOP;
	    --
	    --
	    l_location := '0110';
	    --
	    IF l_program_unit_id IS NULL
	    THEN
	    --{
	        l_location := '0120';
	        --
	        IF p_layer_provider_code = vea_tpa_util_pvt.g_current_layer_provider_code
	        THEN
	            SELECT NVL( p_id, vea_program_units_s.NEXTVAL )
	            INTO   l_program_unit_id
	            FROM   DUAL;
	        ELSE
	            SELECT vea_program_units_s.NEXTVAL
	            INTO   l_program_unit_id
	            FROM   DUAL;
	        END IF;
	        --
                --
	        l_location := '0130';
                --
	        IF p_tpa_program_unit_id IS NOT NULL
		AND l_tpa_program_unit_id IS NULL
	        THEN
	           vea_tpa_util_pvt.put
	             (
	               p_key                => l_program_unit_id,
	               p_value              => p_tpa_program_unit_id,
	               x_cache_tbl          => vea_tpa_util_pvt.g_pend_puId_tpaPUId_tbl,
	               x_cache_ext_tbl      => vea_tpa_util_pvt.g_pend_puId_tpaPUId_ext_tbl
	             );
	        END IF;
                --
	        --
	        l_location := '0140';
	        --
	        deleteUnreferencedProgramUnits
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_program_unit_id              => l_program_unit_id,
	            p_tpa_program_unit_id          => l_tpa_program_unit_id
	          );
	            --p_tpa_program_unit_id          => p_tpa_program_unit_id
	        --
	        --
	        l_location := '0150';
	        --
	        insert_row
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_program_unit_id              => l_program_unit_id,
	            p_package_id                   => l_package_id,
	            p_program_unit_type            => p_program_unit_type,
	            p_name                         => p_name,
	            p_label                        => p_label,
	            p_public_flag                  => p_public_flag,
	            p_customizable_flag            => p_customizable_flag,
	            p_tps_flag                     => p_tps_flag,
	            p_return_type                  => p_return_type,
	            p_tpa_program_unit_id          => l_tpa_program_unit_id,
	            --p_tpa_program_unit_id          => p_tpa_program_unit_id,
	            p_description                  => p_description
	          );
                -- This very important, otherwise insert on parameters will fail
	        g_program_unit_id     := l_program_unit_id;
	    --}
	    ELSE
	    --{
	        l_location := '0160';
                --
	        IF p_tpa_program_unit_id IS NOT NULL
		AND l_tpa_program_unit_id IS NULL
	        THEN
		    l_tpa_program_unit_id := l_db_tpa_program_unit_id;
	        END IF;
                --
	        --
	        l_location := '0161';
	        --
		IF  p_tpa_program_unit_id IS NOT NULL
		THEN
		--{
	            l_location := '0170';
	            --
		    validateMapping
		      (
			p_layer_provider_code     => p_layer_provider_code,
			p_program_unit_id         => l_program_unit_id,
	                p_tpa_program_unit_id     => l_tpa_program_unit_id,
		        --p_tpa_program_unit_id     => p_tpa_program_unit_id,
			p_old_tpa_program_unit_id  => l_db_tpa_program_unit_id
		      );
		--}
		END IF;
	        --
	        --
	        l_location := '0180';
	        --
	        update_row
	          (
	            p_layer_provider_code          => p_layer_provider_code,
	            p_program_unit_id              => l_program_unit_id,
	            p_package_id                   => l_package_id,
	            p_program_unit_type            => p_program_unit_type,
	            p_name                         => p_name,
	            p_label                        => p_label,
	            p_public_flag                  => p_public_flag,
	            p_customizable_flag            => p_customizable_flag,
	            p_tps_flag                     => p_tps_flag,
	            p_return_type                  => p_return_type,
	            p_tpa_program_unit_id          => l_tpa_program_unit_id,
	            --p_tpa_program_unit_id          => p_tpa_program_unit_id,
	            p_description                  => p_description
	          );
	    --}
	    END IF;
	    --
	    --
	    l_location := '0190';
	    --
	    x_id := l_program_unit_id;
            --
	    l_location := '0195';
	    --
            --
	    IF p_id IS NOT NULL
	    THEN
	        vea_tpa_util_pvt.put
	          (
	            p_key                => p_id,
	            p_value              => l_program_unit_id,
	            x_cache_tbl          => vea_tpa_util_pvt.g_PU_fileId_dbId_tbl,
	            x_cache_ext_tbl      => vea_tpa_util_pvt.g_PU_fileId_dbId_ext_tbl
	          );
	    END IF;
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
	l_location := '0200';
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
END VEA_PROGRAM_UNITS_SV;

/
