--------------------------------------------------------
--  DDL for Package Body ASO_IBY_FINANCE_CALLBACK
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ASO_IBY_FINANCE_CALLBACK" AS
/* $Header: asopibyb.pls 120.1 2005/06/29 12:36:47 appldev ship $ */
-- Start of Comments
-- Package name     : ASO_IBY_FINANCE_CALLBACK
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

  g_pkg_name           CONSTANT VARCHAR2 (30) := 'ASO_IBY_FINANCE_CALLBACK';
  g_file_name          CONSTANT VARCHAR2 (12) := 'asopibyb.pls';
  g_login_id                    NUMBER := fnd_global.conc_login_id;

  PROCEDURE update_status (
    p_api_version               IN       NUMBER,
    p_init_msg_list             IN       VARCHAR2 := fnd_api.g_false,
    p_commit                    IN       VARCHAR2 := fnd_api.g_false,
    p_validation_level          IN       NUMBER   := fnd_api.g_miss_num,
    p_tangible_id               IN       NUMBER,
    p_credit_app_id             IN       NUMBER,
    p_new_status_category       IN       VARCHAR2,
    p_new_status                IN       VARCHAR2,
    p_last_update_date          IN       DATE     := fnd_api.g_miss_date,
    x_return_status             OUT NOCOPY /* file.sql.39 change */       VARCHAR2,
    x_msg_count                 OUT NOCOPY /* file.sql.39 change */       NUMBER,
    x_msg_data                  OUT NOCOPY /* file.sql.39 change */       VARCHAR2
  ) IS
    l_api_version                 NUMBER := 1.0;
    l_api_name                    VARCHAR2 (50) := 'Update_Status';
  BEGIN
    -- Standard Start of API savepoint
    SAVEPOINT update_status_pub;

    -- Standard call to check for call compatibility.
    IF NOT fnd_api.compatible_api_call (
             l_api_version,
             p_api_version,
             l_api_name,
             g_pkg_name
           )
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    END IF;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF fnd_api.to_boolean (
         p_init_msg_list
       )
    THEN
      fnd_msg_pub.initialize;
    END IF;

    -- Initialize API return status to SUCCESS
    x_return_status  := fnd_api.g_ret_sts_success;
    --
    -- API body
    --

    -- initialize G_Debug_Flag
    ASO_DEBUG_PUB.G_Debug_Flag := nvl(fnd_profile.value('ASO_ENABLE_DEBUG'),'N');

    aso_iby_financing_pvt.update_status (
      p_api_version                => p_api_version,
      p_init_msg_list              => p_init_msg_list,
      p_commit                     => p_commit,
      p_validation_level           => p_validation_level,
      p_tangible_id                => p_tangible_id,
      p_credit_app_id              => p_credit_app_id,
      p_new_status_category        => p_new_status_category,
      p_new_status                 => p_new_status,
      p_last_update_date           => p_last_update_date,
      x_return_status              => x_return_status,
      x_msg_count                  => x_msg_count,
      x_msg_data                   => x_msg_data
    );
    IF ASO_DEBUG_PUB.G_Debug_Flag = 'Y' THEN
      aso_debug_pub.ADD (
        'Update_Status: after Update_Status return_status: '|| x_return_status,
        1,
        'Y'
      );
    END IF;

    IF (x_return_status = fnd_api.g_ret_sts_unexp_error)
    THEN
      RAISE fnd_api.g_exc_unexpected_error;
    ELSIF (x_return_status = fnd_api.g_ret_sts_error)
    THEN
      RAISE fnd_api.g_exc_error;
    END IF;

    --
    -- End of API body.
    --

    -- Standard check for p_commit
    IF fnd_api.to_boolean (
         p_commit
       )
    THEN
      COMMIT WORK;
    END IF;

    -- Debug Message
    aso_utility_pvt.debug_message (
      fnd_msg_pub.g_msg_lvl_debug_low,
      'Public API: ' || l_api_name || 'end'
    );
    -- Standard call to get message count and if count is 1, get message info.
    fnd_msg_pub.count_and_get (
      p_count                      => x_msg_count,
      p_data                       => x_msg_data
    );
  EXCEPTION
    WHEN fnd_api.g_exc_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_error,
        p_package_type               => aso_utility_pvt.g_pub,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN fnd_api.g_exc_unexpected_error
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => fnd_msg_pub.g_msg_lvl_unexp_error,
        p_package_type               => aso_utility_pvt.g_pub,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
    WHEN OTHERS
    THEN
      aso_utility_pvt.handle_exceptions (
        p_api_name                   => l_api_name,
        p_pkg_name                   => g_pkg_name,
        p_exception_level            => aso_utility_pvt.g_exc_others,
        p_package_type               => aso_utility_pvt.g_pub,
        x_msg_count                  => x_msg_count,
        x_msg_data                   => x_msg_data,
        x_return_status              => x_return_status
      );
  END update_status;
END aso_iby_finance_callback;

/
