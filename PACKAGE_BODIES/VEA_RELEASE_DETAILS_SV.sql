--------------------------------------------------------
--  DDL for Package Body VEA_RELEASE_DETAILS_SV
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."VEA_RELEASE_DETAILS_SV" as
/* $Header: VEAVARDB.pls 115.9 2004/07/27 00:08:16 rvishnuv ship $      */
--{
    /*======================  vea_release_details_sv  =========================*/
    /*========================================================================
       PURPOSE:

       NOTES:                To run the script:

                             sql> start VEAVALHB.pls

       HISTORY
                             Created   N PARIKH       09/09/99 10:00 AM

    =========================================================================*/

    G_PACKAGE_NAME   CONSTANT VARCHAR2(30) := 'VEA_RELEASE_DETAILS_SV';
    --
    --
    /*========================================================================

       PROCEDURE NAME:

       PURPOSE:

    ========================================================================*/
    PROCEDURE
      insert_row
        (
          p_layer_provider_code     IN     vea_release_details.layer_provider_code%TYPE,
          p_release_id              IN     vea_release_details.release_id%TYPE,
          p_file_name               IN     vea_release_details.file_name%TYPE,
          p_version_number          IN     vea_release_details.version_number%TYPE,
          p_application_short_name  IN     vea_release_details.application_short_name%TYPE,
          p_description             IN     vea_release_details.description%TYPE,
          p_aru_number              IN     vea_release_details.aru_number%TYPE,
          p_bug_number              IN     vea_release_details.bug_number%TYPE,
          p_tp_layer_id             IN     vea_release_details.tp_layer_id%TYPE,
          p_file_path               IN     vea_release_details.file_path%TYPE
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
        INSERT INTO vea_release_details
          (
            layer_provider_code, release_id,
            file_name, version_number,
            application_short_name,
            description,
	    aru_number, bug_number,
	    tp_layer_id, file_path,
            created_by, creation_date,
            last_updated_by, last_update_date,
            last_update_login
          )
        VALUES
          (
            p_layer_provider_code, p_release_id,
            p_file_name, p_version_number,
            p_application_short_name,
            p_description,
	    p_aru_number, p_bug_number,
	    p_tp_layer_id, p_file_path,
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

       PROCEDURE NAME:

       PURPOSE:

    ========================================================================*/
    PROCEDURE
      update_row
        (
          p_layer_provider_code     IN     vea_release_details.layer_provider_code%TYPE,
          p_release_id              IN     vea_release_details.release_id%TYPE,
          p_file_name               IN     vea_release_details.file_name%TYPE,
          p_version_number          IN     vea_release_details.version_number%TYPE,
          p_application_short_name  IN     vea_release_details.application_short_name%TYPE,
          p_description             IN     vea_release_details.description%TYPE,
          p_aru_number              IN     vea_release_details.aru_number%TYPE,
          p_bug_number              IN     vea_release_details.bug_number%TYPE,
          p_tp_layer_id             IN     vea_release_details.tp_layer_id%TYPE,
          p_file_path               IN     vea_release_details.file_path%TYPE
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
        UPDATE vea_release_details
        SET    version_number               = p_version_number,
               description                  = p_description,
               aru_number                   = p_aru_number,
               bug_number                   = p_bug_number,
               tp_layer_id                  = p_tp_layer_id,
               file_path                    = p_file_path,
               last_updated_by              = l_user_id,
               last_update_date             = SYSDATE,
               last_update_login            = l_login_id
        WHERE  layer_provider_code          = p_layer_provider_code
        AND    release_id                   = p_release_id
        AND    file_name                    = p_file_name
        AND    application_short_name       = p_application_short_name;
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

       PROCEDURE NAME:

       PURPOSE:

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
          p_layer_provider_code        IN     vea_release_details.layer_provider_code%TYPE,
          p_release_id                 IN     vea_release_details.release_id%TYPE,
          p_file_name                  IN     vea_release_details.file_name%TYPE,
          p_version_number             IN     vea_release_details.version_number%TYPE,
          p_application_short_name     IN     vea_release_details.application_short_name%TYPE,
          p_description                IN     vea_release_details.description%TYPE,
          p_aru_number                 IN     vea_release_details.aru_number%TYPE,
          p_bug_number                 IN     vea_release_details.bug_number%TYPE,
          p_tp_layer_id                IN     vea_release_details.tp_layer_id%TYPE,
          p_file_path                  IN     vea_release_details.file_path%TYPE
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
        l_layer_id     vea_layers.layer_id%TYPE;
        l_tp_layer_id     vea_tp_layers.tp_layer_id%TYPE;
        l_release_id      vea_release_details.release_id%TYPE;
        --
        --
        CURSOR layer_cur
                 (
                   p_layer_provider_code     IN  vea_release_details.layer_provider_code%TYPE,
                   p_release_id              IN  vea_release_details.release_id%TYPE,
                   p_file_name               IN  vea_release_details.file_name%TYPE,
                   p_application_short_name  IN  vea_release_details.application_short_name%TYPE,
                   p_tp_layer_id             IN  vea_tp_layers.tp_layer_id%TYPE
                 )
        IS
          SELECT 1 layer_id,
                 release_id
          FROM   vea_release_details
          WHERE  layer_provider_code     = p_layer_provider_code
          AND    release_id              = p_release_id
          --AND    tp_layer_id              = p_tp_layer_id
          AND    file_name               = p_file_name
          AND    application_short_name  = p_application_short_name;
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
        l_layer_id := NULL;
        l_release_id := p_release_id;
        g_release_id := p_release_id;
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
	l_location := '0040';
	--
        FOR layer_rec IN layer_cur
                                  (
                                    p_layer_provider_code     => p_layer_provider_code,
                                    p_release_id              => p_release_id,
                                    p_file_name               => p_file_name,
                                    p_application_short_name  => p_application_short_name,
                                    p_tp_layer_id             => l_tp_layer_id
                                  )
        LOOP
        --{
	    l_location := '0050';
	    --
            l_layer_id := layer_rec.layer_id;
            l_release_id := layer_rec.release_id;
            g_release_id := layer_rec.release_id;
        --}
        END LOOP;
        --
        --
	l_location := '0060';
	--
        IF l_layer_id IS NULL
        THEN
        --{
	    l_location := '0070';
	    --
            insert_row
              (
                p_layer_provider_code     => p_layer_provider_code,
                p_release_id              => l_release_id,
                p_file_name               => p_file_name,
                p_version_number          => p_version_number,
                p_application_short_name  => p_application_short_name,
                p_description             => p_description,
                p_aru_number              => p_aru_number,
                p_bug_number              => p_bug_number,
                p_tp_layer_id             => l_tp_layer_id,
                p_file_path               => p_file_path
              );
        --}
        ELSE
        --{
	    l_location := '0080';
	    --
            update_row
              (
                p_layer_provider_code     => p_layer_provider_code,
                p_release_id              => l_release_id,
                p_file_name               => p_file_name,
                p_version_number          => p_version_number,
                p_application_short_name  => p_application_short_name,
                p_description             => p_description,
                p_aru_number              => p_aru_number,
                p_bug_number              => p_bug_number,
                p_tp_layer_id             => l_tp_layer_id,
                p_file_path               => p_file_path
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
END VEA_RELEASE_DETAILS_SV;

/
