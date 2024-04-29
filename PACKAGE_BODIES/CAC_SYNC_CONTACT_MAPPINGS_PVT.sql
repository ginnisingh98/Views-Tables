--------------------------------------------------------
--  DDL for Package Body CAC_SYNC_CONTACT_MAPPINGS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SYNC_CONTACT_MAPPINGS_PVT" AS
/* $Header: cacvscvb.pls 120.1 2005/07/02 02:20:59 appldev noship $ */

    g_pkg_name        CONSTANT VARCHAR2(30) := 'CAC_SYNC_CONTACT_MAPPINGS_PVT';

    PROCEDURE CREATE_CONTACT_MAPPING
    ( p_api_version             IN  NUMBER
    , p_init_msg_list           IN  VARCHAR2
    , p_commit                  IN  VARCHAR2
    , p_sync_contact_mapping_id IN  NUMBER
    , p_contact_party_id        IN  NUMBER
    , p_org_party_id            IN  NUMBER
    , p_person_party_id         IN  NUMBER
    , p_party_site_id           IN  NUMBER
    , p_work_contact_point_id   IN  NUMBER
    , p_home_contact_point_id   IN  NUMBER
    , p_fax_contact_point_id    IN  NUMBER
    , p_cell_contact_point_id   IN  NUMBER
    , p_pager_contact_point_id  IN  NUMBER
    , p_email_contact_point_id  IN  NUMBER
    , p_last_sync_date          IN  DATE
    , x_sync_contact_mapping_id OUT NOCOPY NUMBER
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    )
    IS
        l_rowid ROWID;
        l_api_version    CONSTANT NUMBER   := 1.0;
        l_api_name       CONSTANT VARCHAR2(30) := 'CREATE_CONTACT_MAPPING';

        CURSOR c_mapping IS
        SELECT sync_contact_mapping_id
             , org_party_id
             , person_party_id
             , party_site_id
             , work_contact_point_id
             , home_contact_point_id
             , fax_contact_point_id
             , cell_contact_point_id
             , pager_contact_point_id
             , email_contact_point_id
          FROM cac_sync_contact_mappings
         WHERE contact_party_id = p_contact_party_id;

        rec_mapping c_mapping%ROWTYPE;
    BEGIN
        SAVEPOINT create_contact_mapping_sv;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF p_init_msg_list IS NULL OR
           fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -- Check if the given contact_party_id exists
        OPEN c_mapping;
        FETCH c_mapping INTO rec_mapping;

        IF c_mapping%FOUND THEN
            CLOSE c_mapping;

            UPDATE_CONTACT_MAPPING
            ( p_api_version             => p_api_version
            , p_init_msg_list           => p_init_msg_list
            , p_commit                  => p_commit
            , p_sync_contact_mapping_id => rec_mapping.sync_contact_mapping_id
            , p_contact_party_id        => p_contact_party_id
            , p_org_party_id            => p_org_party_id
            , p_person_party_id         => p_person_party_id
            , p_party_site_id           => p_party_site_id
            , p_work_contact_point_id   => p_work_contact_point_id
            , p_home_contact_point_id   => p_home_contact_point_id
            , p_fax_contact_point_id    => p_fax_contact_point_id
            , p_cell_contact_point_id   => p_cell_contact_point_id
            , p_pager_contact_point_id  => p_pager_contact_point_id
            , p_email_contact_point_id  => p_email_contact_point_id
            , p_last_sync_date          => p_last_sync_date
            , x_return_status           => x_return_status
            , x_msg_count               => x_msg_count
            , x_msg_data                => x_msg_data
            );

            IF fnd_api.to_boolean(p_commit)
            THEN
                COMMIT WORK;
            END IF;

            fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

            RETURN;
        END IF;
        CLOSE c_mapping;

        IF p_sync_contact_mapping_id IS NULL
        THEN
            SELECT cac_sync_contact_mappings_s.nextval
              INTO x_sync_contact_mapping_id
              FROM DUAL;
        ELSE
            x_sync_contact_mapping_id := p_sync_contact_mapping_id;
        END IF;

        cac_sync_contact_mappings_pkg.insert_row
        ( x_rowid                   => l_rowid
        , x_sync_contact_mapping_id => p_sync_contact_mapping_id
        , x_contact_party_id        => p_contact_party_id
        , x_org_party_id            => p_org_party_id
        , x_person_party_id         => p_person_party_id
        , x_party_site_id           => p_party_site_id
        , x_work_contact_point_id   => p_work_contact_point_id
        , x_home_contact_point_id   => p_home_contact_point_id
        , x_fax_contact_point_id    => p_fax_contact_point_id
        , x_cell_contact_point_id   => p_cell_contact_point_id
        , x_pager_contact_point_id  => p_pager_contact_point_id
        , x_email_contact_point_id  => p_email_contact_point_id
        , x_created_by              => fnd_global.user_id
        , x_creation_date           => NVL(p_last_sync_date,SYSDATE)
        , x_last_updated_by         => fnd_global.user_id
        , x_last_update_date        => NVL(p_last_sync_date,SYSDATE)
        , x_last_update_login       => fnd_global.login_id
        );

        IF fnd_api.to_boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO create_contact_mapping_sv;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
            IF c_mapping%ISOPEN THEN
                CLOSE c_mapping;
            END IF;

        WHEN OTHERS THEN
            ROLLBACK TO create_contact_mapping_sv;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
            IF c_mapping%ISOPEN THEN
                CLOSE c_mapping;
            END IF;
    END CREATE_CONTACT_MAPPING;

    PROCEDURE UPDATE_CONTACT_MAPPING
    ( p_api_version             IN  NUMBER
    , p_init_msg_list           IN  VARCHAR2
    , p_commit                  IN  VARCHAR2
    , p_sync_contact_mapping_id IN  NUMBER
    , p_contact_party_id        IN  NUMBER
    , p_org_party_id            IN  NUMBER
    , p_person_party_id         IN  NUMBER
    , p_party_site_id           IN  NUMBER
    , p_work_contact_point_id   IN  NUMBER
    , p_home_contact_point_id   IN  NUMBER
    , p_fax_contact_point_id    IN  NUMBER
    , p_cell_contact_point_id   IN  NUMBER
    , p_pager_contact_point_id  IN  NUMBER
    , p_email_contact_point_id  IN  NUMBER
    , p_last_sync_date          IN  DATE
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    )
    IS
        l_rowid ROWID;
        l_api_version    CONSTANT NUMBER   := 1.0;
        l_api_name       CONSTANT VARCHAR2(30) := 'UDPATE_CONTACT_MAPPING';

        CURSOR c_mapping IS
        SELECT NULL
          FROM cac_sync_contact_mappings
         WHERE sync_contact_mapping_id = p_sync_contact_mapping_id;

        rec_mapping c_mapping%ROWTYPE;
    BEGIN
        SAVEPOINT update_contact_mapping_sv;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF p_init_msg_list IS NULL OR
           fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        OPEN c_mapping;
        FETCH c_mapping INTO rec_mapping;

        IF c_mapping%NOTFOUND THEN
            CLOSE c_mapping;

            fnd_message.set_name ('JTF', 'CAC_SYNC_CONTACT_MAPPING_NF');
            fnd_msg_pub.add;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;
        CLOSE c_mapping;

        cac_sync_contact_mappings_pkg.update_row
        ( x_sync_contact_mapping_id => p_sync_contact_mapping_id
        , x_contact_party_id        => p_contact_party_id
        , x_org_party_id            => p_org_party_id
        , x_person_party_id         => p_person_party_id
        , x_party_site_id           => p_party_site_id
        , x_work_contact_point_id   => p_work_contact_point_id
        , x_home_contact_point_id   => p_home_contact_point_id
        , x_fax_contact_point_id    => p_fax_contact_point_id
        , x_cell_contact_point_id   => p_cell_contact_point_id
        , x_pager_contact_point_id  => p_pager_contact_point_id
        , x_email_contact_point_id  => p_email_contact_point_id
        , x_last_updated_by         => fnd_global.user_id
        , x_last_update_date        => NVL(p_last_sync_date,SYSDATE)
        , x_last_update_login       => fnd_global.login_id
        );

        IF fnd_api.to_boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO update_contact_mapping_sv;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
            IF c_mapping%ISOPEN THEN
                CLOSE c_mapping;
            END IF;

        WHEN OTHERS THEN
            ROLLBACK TO update_contact_mapping_sv;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END UPDATE_CONTACT_MAPPING;


    PROCEDURE DELETE_CONTACT_MAPPING
    ( p_api_version             IN  NUMBER
    , p_init_msg_list           IN  VARCHAR2
    , p_commit                  IN  VARCHAR2
    , p_sync_contact_mapping_id IN  NUMBER
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data               OUT NOCOPY VARCHAR2
    )
    IS
        l_rowid ROWID;
        l_api_version    CONSTANT NUMBER   := 1.0;
        l_api_name       CONSTANT VARCHAR2(30) := 'DELETE_CONTACT_MAPPING';
    BEGIN
        SAVEPOINT delete_contact_mapping_sv;

        x_return_status := fnd_api.g_ret_sts_success;

        IF NOT fnd_api.compatible_api_call (l_api_version, p_api_version, l_api_name, g_pkg_name)
        THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        IF p_init_msg_list IS NULL OR
           fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        cac_sync_contact_mappings_pkg.delete_row
        (x_sync_contact_mapping_id => p_sync_contact_mapping_id);

        IF fnd_api.to_boolean(p_commit)
        THEN
            COMMIT WORK;
        END IF;

        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO delete_contact_mapping_sv;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

        WHEN OTHERS THEN
            ROLLBACK TO delete_contact_mapping_sv;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
    END DELETE_CONTACT_MAPPING;


END CAC_SYNC_CONTACT_MAPPINGS_PVT;

/
