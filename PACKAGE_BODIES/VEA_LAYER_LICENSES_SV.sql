--------------------------------------------------------
--  DDL for Package Body VEA_LAYER_LICENSES_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_LAYER_LICENSES_SV" as
/* $Header: VEAVALLB.pls 115.9 2004/07/27 00:08:01 rvishnuv ship $      */
--{
    /*======================  vea_layer_licenses_sv  =========================*/
    /*========================================================================
       PURPOSE:  Table handler package for table VEA_LAYER_LICENSES

       NOTES:                To run the script:

                             sql> start VEAVALHB.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_LAYER_LICENSES_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME: insert_row

       PURPOSE: Inserts a record into VEA_LAYER_LICENSES table

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_layer_provider_code        IN     vea_layer_licenses.layer_provider_code%TYPE,
          p_customer_name              IN     vea_layer_licenses.customer_name%TYPE,
          p_description                IN     vea_layer_licenses.description%TYPE,
          p_tp_layer_id                IN     vea_layer_licenses.tp_layer_id%TYPE
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
        INSERT INTO vea_layer_licenses
          (
            layer_provider_code,
            customer_name,
            description,
	    tp_layer_id,
            created_by, creation_date,
            last_updated_by, last_update_date,
            last_update_login
          )
        VALUES
          (
            p_layer_provider_code,
            p_customer_name,
            p_description,
	    p_tp_layer_id,
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

       PURPOSE: Updates a record into VEA_LAYER_LICENSES table

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_layer_provider_code        IN     vea_layer_licenses.layer_provider_code%TYPE,
          p_customer_name              IN     vea_layer_licenses.customer_name%TYPE,
          p_description                IN     vea_layer_licenses.description%TYPE,
          p_tp_layer_id                IN     vea_layer_licenses.tp_layer_id%TYPE
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
        UPDATE vea_layer_licenses
        SET    description                  = p_description,
               last_updated_by              = l_user_id,
               last_update_date             = SYSDATE,
               last_update_login            = l_login_id
        WHERE  layer_provider_code          = p_layer_provider_code
        AND    tp_layer_id                  = p_tp_layer_id
        AND    customer_name                = p_customer_name;
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

       PROCEDURE NAME: isLayerLicensed

       PURPOSE: Returns True, if layer is licensed to the customer.

    ========================================================================*/
    FUNCTION
      isLicensed
        (
          p_layer_provider_code        IN     vea_layer_licenses.layer_provider_code%TYPE,
          p_tp_layer_id                IN     vea_layer_licenses.tp_layer_id%TYPE
        )
    RETURN BOOLEAN
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'isLicensed';
        l_location            VARCHAR2(32767);
	--
	--
        l_user_id       NUMBER := vea_tpa_util_pvt.get_user_id;
        l_login_id      NUMBER := vea_tpa_util_pvt.get_login_id;
	--
	--
	CURSOR layer_license_cur
		 (
                   p_layer_provider_code IN  vea_layer_licenses.layer_provider_code%TYPE,
                   p_tp_layer_id         IN  vea_layer_licenses.tp_layer_id%TYPE
		 )
	IS
	  SELECT 'x'
	  FROM   vea_layer_licenses
	  WHERE  layer_provider_code = p_layer_provider_code
	  AND    tp_layer_id         = p_tp_layer_id;
	--
	--
	l_count       NUMBER;
    --}
    BEGIN
    --{
	l_location := '0010';
	--
	IF p_tp_layer_id IS NULL
	THEN
	    RETURN(TRUE);
	END IF;
	--
	--
	l_location := '0015';
	--
	IF NOT( vea_tpa_util_pvt.isLayerMergeOn )
	THEN
	    RETURN(TRUE);
	END IF;
	--
	--
	l_location := '0016';
	--
	IF vea_tpa_util_pvt.get_curr_layer_provider_code = p_layer_provider_code
	THEN
	    RETURN(TRUE);
	END IF;
	--
	--
	l_location := '0017';
	--
	--IF vea_tpa_util_pvt.get_curr_layer_provider_code like 'CUST%'
	--THEN
	--{
	    l_location := '0020';
	    --
	    l_count := 0;
	    --
	    --
	    l_location := '0030';
	    --
	    FOR layer_license_rec IN layer_license_cur
				       (
				         p_layer_provider_code => p_layer_provider_code,
				         p_tp_layer_id         => p_tp_layer_id
				       )
	    LOOP
	    --{
	        l_location := '0040';
	        --
	        l_count := l_count + 1;
	    --}
	    END LOOP;
	    --
	    --
	    l_location := '0050';
	    --
	    IF l_count = 0
	    THEN
	    --{
	        l_location := '0060';
	        --
	        RETURN(FALSE);
	    --}
	    END IF;
	--}
	--END IF;
	--
	--
	l_location := '0070';
	--
	RETURN(TRUE);
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
    END isLicensed;
    --
    --
    /*========================================================================

       PROCEDURE NAME: delete_rows

       PURPOSE: Deletes all licenses for the specified TP Layer.

    ========================================================================*/
    PROCEDURE
      delete_rows
        (
          p_layer_provider_code        IN     vea_layer_licenses.layer_provider_code%TYPE,
          p_tp_layer_id                IN     vea_layer_licenses.tp_layer_id%TYPE
        )
    IS
    --{
        l_api_name            CONSTANT VARCHAR2(30) := 'delete_rows';
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
        DELETE vea_layer_licenses
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
    END delete_rows;
    --
    --
    /*========================================================================

       PROCEDURE NAME: process

       PURPOSE: Table hadndler API for VEA_LAYER_LICENSES table.

		It inserts/updates a record in VEA_LAYER_LICENSES table.

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
          p_layer_provider_code        IN     vea_layer_licenses.layer_provider_code%TYPE,
          p_customer_name              IN     vea_layer_licenses.customer_name%TYPE,
          p_description                IN     vea_layer_licenses.description%TYPE,
          p_tp_layer_id                IN     vea_layer_licenses.tp_layer_id%TYPE
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
        l_id                  vea_layers.layer_id%TYPE;
        l_tp_layer_id         vea_tp_layers.tp_layer_id%TYPE;
        --
        --
        CURSOR layer_cur
                 (
                   p_layer_provider_code          IN  vea_layer_licenses.layer_provider_code%TYPE,
                   p_customer_name                IN  vea_layer_licenses.customer_name%TYPE,
                   p_tp_layer_id                  IN  vea_layer_licenses.tp_layer_id%TYPE
                 )
        IS
          SELECT 1 id
          FROM   vea_layer_licenses
          WHERE  layer_provider_code       = p_layer_provider_code
          AND    tp_layer_id               = p_tp_layer_id
          AND    customer_name             = p_customer_name;
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
	l_location := '0025';
	--
        IF vea_tpa_util_pvt.get_curr_customer_name() = p_customer_name
	THEN
	--{
	    l_location := '0030';
	    --
            l_id := NULL;
	    --
            IF (VEA_TPA_UTIL_PVT.isLayerMergeOn) THEN
            --{
              l_tp_layer_id := nvl(vea_tp_layers_sv.g_tp_layer_id,p_tp_layer_id);
            --}
            ELSE
            --{
              l_tp_layer_id := p_tp_layer_id;
            --}
            END IF;
	    --
            --
            --
            --
	    l_location := '0040';
	    --
            FOR layer_rec IN layer_cur
                               (
                                 p_layer_provider_code => p_layer_provider_code,
                                 p_customer_name       => p_customer_name,
                                 p_tp_layer_id         => l_tp_layer_id
                               )
            LOOP
            --{
	        l_location := '0050';
	        --
                l_id := layer_rec.id;
            --}
            END LOOP;
            --
            --
	    l_location := '0060';
	    --
            IF l_id IS NULL
            THEN
            --{
	        l_location := '0070';
	        --
                insert_row
                  (
                    p_layer_provider_code       => p_layer_provider_code,
                    p_customer_name             => p_customer_name,
                    p_description               => p_description,
		    p_tp_layer_id               => l_tp_layer_id
                  );
            --}
            ELSE
            --{
	        l_location := '0080';
	        --
                update_row
                  (
                    p_layer_provider_code       => p_layer_provider_code,
                    p_customer_name             => p_customer_name,
                    p_description               => p_description,
		    p_tp_layer_id               => l_tp_layer_id
                  );
            --}
            END IF;
	--}
	END IF;
        --
        --
        --} API Body
        --
        --
        -- Standard  API Footer
        --
	l_location := '0090';
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
END VEA_LAYER_LICENSES_SV;

/
