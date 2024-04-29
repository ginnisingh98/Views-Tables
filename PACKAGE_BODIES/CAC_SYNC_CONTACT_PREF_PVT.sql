--------------------------------------------------------
--  DDL for Package Body CAC_SYNC_CONTACT_PREF_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CAC_SYNC_CONTACT_PREF_PVT" AS
/* $Header: cacvscpb.pls 120.1 2005/07/02 02:20:29 appldev noship $ */

    PROCEDURE CREATE_CONTACT_PREFERENCE
    ( p_init_msg_list           IN  VARCHAR2
    , p_party_id                IN  NUMBER
    , p_category                IN  VARCHAR2
    , p_preference_code         IN  VARCHAR2
    , p_module                  IN  VARCHAR2
    , p_value_number            IN  NUMBER
    , p_last_sync_date          IN  DATE
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    )
    IS
        CURSOR c_preference IS
        SELECT party_preference_id
          FROM hz_party_preferences
         WHERE party_id = p_party_id
           AND category = p_category
           AND value_number = p_value_number
           AND preference_code = p_preference_code
           AND module = p_module;

        rec_preference c_preference%ROWTYPE;
        l_object_version_number NUMBER;
    BEGIN
        SAVEPOINT create_contact_preference_sv;

        x_return_status := fnd_api.g_ret_sts_success;

        IF p_init_msg_list IS NULL OR
           fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        -- Check if the given contact_party_id exists
        OPEN c_preference;
        FETCH c_preference INTO rec_preference;

        IF c_preference%NOTFOUND THEN

            CLOSE c_preference;

            hz_preference_pub.add
            ( p_party_id              => p_party_id
            , p_category              => p_category
            , p_preference_code       => p_preference_code
            , p_value_number          => p_value_number
            , p_module                => p_module
            , x_return_status         => x_return_status
            , x_msg_count             => x_msg_count
            , x_msg_data              => x_msg_data
            , x_object_version_number => l_object_version_number
            );

            IF NOT (x_return_status = fnd_api.g_ret_sts_success)
            THEN
                x_return_status := fnd_api.g_ret_sts_unexp_error;
                RAISE fnd_api.g_exc_unexpected_error;
            END IF;

        ELSE
            CLOSE c_preference;
        END IF;


        -- Correct last_update_date
        IF p_last_sync_date IS NOT NULL THEN
            UPDATE hz_party_preferences
               SET last_update_date = p_last_sync_date
             WHERE party_id = p_party_id
               AND category = p_category
               AND preference_code = p_preference_code
               AND module = p_module
               AND value_number = p_value_number;
        END IF;

        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO create_contact_preference_sv;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
            IF c_preference%ISOPEN THEN
                CLOSE c_preference;
            END IF;

        WHEN OTHERS THEN
            ROLLBACK TO create_contact_preference_sv;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);
            IF c_preference%ISOPEN THEN
                CLOSE c_preference;
            END IF;
    END CREATE_CONTACT_PREFERENCE;

    PROCEDURE DELETE_CONTACT_PREFERENCE
    ( p_init_msg_list           IN  VARCHAR2 DEFAULT NULL
    , p_party_id                IN  NUMBER
    , p_category                IN  VARCHAR2
    , p_preference_code         IN  VARCHAR2
    , p_value_number            IN  NUMBER
    , p_object_version_number   IN  NUMBER
    , x_return_status           OUT NOCOPY VARCHAR2
    , x_msg_count               OUT NOCOPY NUMBER
    , x_msg_data                OUT NOCOPY VARCHAR2
    )
    IS
    BEGIN
        SAVEPOINT delete_contact_preference_sv;

        x_return_status := fnd_api.g_ret_sts_success;

        IF p_init_msg_list IS NULL OR
           fnd_api.to_boolean (p_init_msg_list)
        THEN
            fnd_msg_pub.initialize;
        END IF;

        hz_preference_pub.remove
        ( p_party_id              => p_party_id
        , p_category              => p_category
        , p_preference_code       => p_preference_code
        , p_value_number          => p_value_number
        , p_object_version_number => p_object_version_number
        , x_return_status         => x_return_status
        , x_msg_count             => x_msg_count
        , x_msg_data              => x_msg_data
        );

        IF NOT (x_return_status = fnd_api.g_ret_sts_success)
        THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        fnd_msg_pub.count_and_get(p_count => x_msg_count, p_data => x_msg_data);

    EXCEPTION
        WHEN fnd_api.g_exc_unexpected_error THEN
            ROLLBACK TO delete_contact_preference_sv;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

        WHEN OTHERS THEN
            ROLLBACK TO delete_contact_preference_sv;
            fnd_message.set_name ('JTF', 'JTF_TASK_UNKNOWN_ERROR');
            fnd_message.set_token ('P_TEXT', SQLCODE || SQLERRM);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get (p_count => x_msg_count, p_data => x_msg_data);

    END DELETE_CONTACT_PREFERENCE;

END CAC_SYNC_CONTACT_PREF_PVT;

/
