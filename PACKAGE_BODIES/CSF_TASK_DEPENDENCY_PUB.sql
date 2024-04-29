--------------------------------------------------------
--  DDL for Package Body CSF_TASK_DEPENDENCY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CSF_TASK_DEPENDENCY_PUB" as
/* $Header: CSFPTKDB.pls 120.0 2005/05/25 11:21:18 appldev noship $ */

-- Start of Comments

-- Package name     : CSF_TASK_DEPENDENCY_PUB
-- Purpose          : This package is related to the task dependency.
-- History          : Created by sseshaiy on 26-aug-2004
-- NOTE             : This package do the operations on jtf_task_depends table

-- End of Comments

    g_pkg_name    CONSTANT VARCHAR2(30) := 'CSF_TASK_DEPENDENCY_PUB';

    PROCEDURE CREATE_TASK_DEPENDENCY_NV (
          p_api_version                IN           NUMBER
        , p_init_msg_list              IN           VARCHAR2  DEFAULT NULL
        , p_commit                     IN           VARCHAR2  DEFAULT NULL
        , p_validation_level           IN           VARCHAR2  DEFAULT NULL
        , p_task_id                    IN           NUMBER
        , p_dependent_on_task_id       IN           NUMBER
        , p_dependency_type_code       IN           VARCHAR2
        , x_dependency_id              OUT NOCOPY   NUMBER
        , x_return_status              OUT NOCOPY   VARCHAR2
        , x_msg_count                  OUT NOCOPY   NUMBER
        , x_msg_data                   OUT NOCOPY   VARCHAR2
        , p_attribute1                 IN           VARCHAR2 DEFAULT NULL
        , p_attribute2                 IN           VARCHAR2 DEFAULT NULL
        , p_attribute3                 IN           VARCHAR2 DEFAULT NULL
        , p_attribute4                 IN           VARCHAR2 DEFAULT NULL
        , p_attribute5                 IN           VARCHAR2 DEFAULT NULL
        , p_attribute6                 IN           VARCHAR2 DEFAULT NULL
        , p_attribute7                 IN           VARCHAR2 DEFAULT NULL
        , p_attribute8                 IN           VARCHAR2 DEFAULT NULL
        , p_attribute9                 IN           VARCHAR2 DEFAULT NULL
        , p_attribute10                IN           VARCHAR2 DEFAULT NULL
        , p_attribute11                IN           VARCHAR2 DEFAULT NULL
        , p_attribute12                IN           VARCHAR2 DEFAULT NULL
        , p_attribute13                IN           VARCHAR2 DEFAULT NULL
        , p_attribute14                IN           VARCHAR2 DEFAULT NULL
        , p_attribute15                IN           VARCHAR2 DEFAULT NULL
        , p_attribute_category         IN           VARCHAR2 DEFAULT NULL
    )
    IS
        l_api_version        CONSTANT NUMBER              := 1.0;
        l_api_name           CONSTANT VARCHAR2(30)        := 'CREATE_TASK_DEPENDENCY_NV';
    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT csf_create_task_dependency_pub;

        -- Standard call to check for call compatibility
        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        -- Calling jtf api to create dependency and validate flag will be set 'N' always
        jtf_task_dependency_pub.create_task_dependency (
             p_api_version              => p_api_version
           , p_init_msg_list            => p_init_msg_list
           , p_commit                   => p_commit
           , p_validation_level         => p_validation_level
           , p_task_id                  => p_task_id
           , p_dependent_on_task_id     => p_dependent_on_task_id
           , p_dependency_type_code     => p_dependency_type_code
           , p_validated_flag           => 'N'
           , p_template_flag            => 'N'
           , p_adjustment_time          => NULL
           , p_adjustment_time_uom      => NULL
           , x_dependency_id            => x_dependency_id
           , x_return_status            => x_return_status
           , x_msg_data                 => x_msg_data
           , x_msg_count                => x_msg_count
           , p_attribute1               => p_attribute1
           , p_attribute2               => p_attribute2
           , p_attribute3               => p_attribute3
           , p_attribute4               => p_attribute4
           , p_attribute5               => p_attribute5
           , p_attribute6               => p_attribute6
           , p_attribute7               => p_attribute7
           , p_attribute8               => p_attribute8
           , p_attribute9               => p_attribute9
           , p_attribute10              => p_attribute10
           , p_attribute11              => p_attribute11
           , p_attribute12              => p_attribute12
           , p_attribute13              => p_attribute13
           , p_attribute14              => p_attribute14
           , p_attribute15              => p_attribute15
           , p_attribute_category       => p_attribute_category
        );

        -- check return status
        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Standard check of p_commit
        IF fnd_api.to_boolean (p_commit)
        THEN

            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO csf_create_task_dependency_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO csf_create_task_dependency_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END CREATE_TASK_DEPENDENCY_NV;

   PROCEDURE LOCK_TASK_DEPENDENCY (
        p_api_version             IN            NUMBER
      , p_init_msg_list           IN            VARCHAR2 DEFAULT NULL
      , p_commit                  IN            VARCHAR2 DEFAULT NULL
      , p_dependency_id           IN            NUMBER
      , p_object_version_number   IN            NUMBER
      , x_return_status           OUT NOCOPY    VARCHAR2
      , x_msg_data                OUT NOCOPY    VARCHAR2
      , x_msg_count               OUT NOCOPY    NUMBER
   )
   IS
        l_api_version        CONSTANT NUMBER              := 1.0;
        l_api_name           CONSTANT VARCHAR2(30)        := 'LOCK_TASK_DEPENDENCY';
   BEGIN
        -- Standard start of API savepoint
        SAVEPOINT csf_lock_task_depends_pub;

        -- Standard call to check for call compatibility
        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        -- Calling jtf api to lock the row
        jtf_task_dependency_pub.lock_task_dependency(
              p_api_version            => p_api_version
            , p_init_msg_list          => p_init_msg_list
            , p_commit                 => p_commit
            , p_dependency_id          => p_dependency_id
            , p_object_version_number  => p_object_version_number
            , x_return_status          => x_return_status
            , x_msg_data               => x_msg_data
            , x_msg_count              => x_msg_count
          );

        -- check return status
        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO csf_lock_task_depends_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO csf_lock_task_depends_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END LOCK_TASK_DEPENDENCY;

    PROCEDURE  UPDATE_TASK_DEPENDENCY (
          p_api_version                IN                 NUMBER
        , p_init_msg_list              IN                 VARCHAR2 DEFAULT NULL
        , p_commit                     IN                 VARCHAR2 DEFAULT NULL
        , p_object_version_number      IN  OUT NOCOPY     NUMBER
        , p_dependency_id              IN                 NUMBER
        , p_task_id                    IN                 NUMBER   DEFAULT NULL
        , p_dependent_on_task_id       IN                 NUMBER   DEFAULT NULL
        , p_dependency_type_code       IN                 VARCHAR2 DEFAULT NULL
        , x_return_status              OUT     NOCOPY     VARCHAR2
        , x_msg_count                  OUT     NOCOPY     NUMBER
        , x_msg_data                   OUT     NOCOPY     VARCHAR2
        , p_attribute1                 IN                 VARCHAR2 DEFAULT NULL
        , p_attribute2                 IN                 VARCHAR2 DEFAULT NULL
        , p_attribute3                 IN                 VARCHAR2 DEFAULT NULL
        , p_attribute4                 IN                 VARCHAR2 DEFAULT NULL
        , p_attribute5                 IN                 VARCHAR2 DEFAULT NULL
        , p_attribute6                 IN                 VARCHAR2 DEFAULT NULL
        , p_attribute7                 IN                 VARCHAR2 DEFAULT NULL
        , p_attribute8                 IN                 VARCHAR2 DEFAULT NULL
        , p_attribute9                 IN                 VARCHAR2 DEFAULT NULL
        , p_attribute10                IN                 VARCHAR2 DEFAULT NULL
        , p_attribute11                IN                 VARCHAR2 DEFAULT NULL
        , p_attribute12                IN                 VARCHAR2 DEFAULT NULL
        , p_attribute13                IN                 VARCHAR2 DEFAULT NULL
        , p_attribute14                IN                 VARCHAR2 DEFAULT NULL
        , p_attribute15                IN                 VARCHAR2 DEFAULT NULL
        , p_attribute_category         IN                 VARCHAR2 DEFAULT NULL
    )
    IS
        l_api_version        CONSTANT NUMBER              := 1.0;
        l_api_name           CONSTANT VARCHAR2(30)        := 'UPDATE_TASK_DEPENDENCY';
    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT csf_update_task_dependency_pub;

        -- Standard call to check for call compatibility
        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        -- Calling jtf api to update dependency and validate flag will be set 'N' always
        jtf_task_dependency_pub.update_task_dependency (
              p_api_version              => p_api_version
            , p_init_msg_list            => p_init_msg_list
            , p_commit                   => p_commit
            , p_object_version_number    => p_object_version_number
            , p_dependency_id            => p_dependency_id
            , p_task_id                  => p_task_id
            , p_dependent_on_task_id     => p_dependent_on_task_id
            , p_dependency_type_code     => p_dependency_type_code
            , p_validated_flag           => 'N'
            , p_adjustment_time          => NULL
            , p_adjustment_time_uom      => NULL
            , x_return_status            => x_return_status
            , x_msg_data                 => x_msg_data
            , x_msg_count                => x_msg_count
            , p_attribute1               => p_attribute1
            , p_attribute2               => p_attribute2
            , p_attribute3               => p_attribute3
            , p_attribute4               => p_attribute4
            , p_attribute5               => p_attribute5
            , p_attribute6               => p_attribute6
            , p_attribute7               => p_attribute7
            , p_attribute8               => p_attribute8
            , p_attribute9               => p_attribute9
            , p_attribute10              => p_attribute10
            , p_attribute11              => p_attribute11
            , p_attribute12              => p_attribute12
            , p_attribute13              => p_attribute13
            , p_attribute14              => p_attribute14
            , p_attribute15              => p_attribute15
            , p_attribute_category       => p_attribute_category
        );

        -- check return status
        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

          -- Standard check of p_commit
        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO csf_update_task_dependency_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO csf_update_task_dependency_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END UPDATE_TASK_DEPENDENCY;

    PROCEDURE DELETE_TASK_DEPENDENCY (
          p_api_version             IN              NUMBER
        , p_init_msg_list           IN              VARCHAR2 DEFAULT NULL
        , p_commit                  IN              VARCHAR2 DEFAULT NULL
        , p_object_version_number   IN              NUMBER
        , p_dependency_id           IN              NUMBER
        , x_return_status           OUT NOCOPY      VARCHAR2
        , x_msg_count               OUT NOCOPY      NUMBER
        , x_msg_data                OUT NOCOPY      VARCHAR2
    )
    IS
        l_api_version        CONSTANT NUMBER              := 1.0;
        l_api_name           CONSTANT VARCHAR2(30)        := 'DELETE_TASK_DEPENDENCY';
    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT csf_delete_task_dependency_pub;

        -- Standard call to check for call compatibility
        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        -- Calling jtf api to delete dependency
        jtf_task_dependency_pub.delete_task_dependency (
                  p_api_version           => p_api_version
                , p_init_msg_list         => p_init_msg_list
                , p_commit                => p_commit
                , p_object_version_number => p_object_version_number
                , p_dependency_id         => p_dependency_id
                , x_return_status         => x_return_status
                , x_msg_count             => x_msg_count
                , x_msg_data              => x_msg_data
            );

        -- check return status
        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

          -- Standard check of p_commit
        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO csf_delete_task_dependency_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO csf_delete_task_dependency_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END  DELETE_TASK_DEPENDENCY;

    PROCEDURE CLEAR_TASK_DEPENDENCIES (
          p_api_version             IN              NUMBER
        , p_init_msg_list           IN              VARCHAR2 DEFAULT NULL
        , p_commit                  IN              VARCHAR2 DEFAULT NULL
        , p_task_id                 IN              NUMBER
        , x_return_status           OUT NOCOPY      VARCHAR2
        , x_msg_count               OUT NOCOPY      NUMBER
        , x_msg_data                OUT NOCOPY      VARCHAR2
    )
    IS
        l_api_version        CONSTANT NUMBER              := 1.0;
        l_api_name           CONSTANT VARCHAR2(30)        := 'CLEAR_TASK_DEPENDENCIES';

        CURSOR c_all_depends (p_task_id NUMBER)
        IS
            SELECT  dependency_id
                  , object_version_number
            FROM    jtf_task_depends
            WHERE   task_id = p_task_id
            UNION
            SELECT  dependency_id
                  , object_version_number
            FROM    jtf_task_depends
            WHERE   dependent_on_task_id = p_task_id;

         l_dependency_id                NUMBER;
         l_object_version_number        NUMBER;

    BEGIN
        -- Standard start of API savepoint
        SAVEPOINT csf_clear_task_dependency_pub;

        -- Standard call to check for call compatibility
        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE
        IF fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -- Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        OPEN c_all_depends (p_task_id);
        LOOP
            FETCH c_all_depends INTO l_dependency_id, l_object_version_number;
            EXIT WHEN c_all_depends%NOTFOUND;

            DELETE_TASK_DEPENDENCY(
                   p_api_version             => 1.0
                 , p_init_msg_list           => p_init_msg_list
                 , p_commit                  => p_commit
                 , p_object_version_number   => l_object_version_number
                 , p_dependency_id           => l_dependency_id
                 , x_return_status           => x_return_status
                 , x_msg_count               => x_msg_count
                 , x_msg_data                => x_msg_data
              );

        END LOOP;
        CLOSE c_all_depends;

        -- check return status
        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

          -- Standard check of p_commit
        IF fnd_api.to_boolean (p_commit)
        THEN
            COMMIT WORK;
        END IF;

        -- Standard call to get message count and if count is 1, get message info
        fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error
        THEN
            ROLLBACK TO csf_clear_task_dependency_pub;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
        WHEN OTHERS
        THEN
            ROLLBACK TO csf_clear_task_dependency_pub;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END  CLEAR_TASK_DEPENDENCIES;

END CSF_TASK_DEPENDENCY_PUB;


/
