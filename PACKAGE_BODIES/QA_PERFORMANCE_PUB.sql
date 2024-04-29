--------------------------------------------------------
--  DDL for Package Body QA_PERFORMANCE_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_PERFORMANCE_PUB" AS
/* $Header: qapindb.pls 120.0 2005/05/24 18:56:22 appldev noship $ */

    -- Global variables.
    g_pkg_name    CONSTANT VARCHAR2(30) := 'qa_performance_pub';

    PROCEDURE get_predicate(
        p_api_version               IN  NUMBER,
        p_init_msg_list             IN  VARCHAR2,
        p_char_id                   IN  NUMBER,
        p_alias                     IN  VARCHAR2,
        x_predicate                 OUT NOCOPY VARCHAR2,
        x_msg_count                 OUT NOCOPY NUMBER,
        x_msg_data                  OUT NOCOPY VARCHAR2,
        x_return_status             OUT NOCOPY VARCHAR2) IS

        l_api_name    CONSTANT VARCHAR2(30)   := 'get_predicate';
        l_api_version CONSTANT NUMBER         := 1.0;

    BEGIN

        -- Standard Start of API savepoint is not required as this
        -- API does not make any database changes. Its just queries
        -- for the predicate.

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_api_call(
                   l_api_version,
                   p_api_version,
                   l_api_name,
                   g_pkg_name) THEN
            RAISE fnd_api.g_exc_unexpected_error;
        END IF;

        -- Initialize message list if p_init_msg_list is set to TRUE.
        -- Even though we do not have any messages, the framework for
        -- Message support is provided.

        -- For GSCC std File.Sql.35, we have not initialized p_init_msg_list.
        -- So, check whether the value is NULL.

        IF fnd_api.to_boolean(NVL(p_init_msg_list, fnd_api.g_false)) THEN
            fnd_msg_pub.initialize;
        END IF;

        --  Initialize API return status to success
        x_return_status := fnd_api.g_ret_sts_success;

        /* Call the get_predicate procedure in qa_char_indexes_pkg */
        qa_char_indexes_pkg.get_predicate(
            p_char_id   => p_char_id,
            p_alias     => p_alias,
            x_predicate => x_predicate);


    EXCEPTION

        WHEN fnd_api.g_exc_error THEN
            x_return_status := fnd_api.g_ret_sts_error;
            fnd_msg_pub.count_and_get(
                p_count => x_msg_count,
                p_data  => x_msg_data
            );

        WHEN fnd_api.g_exc_unexpected_error THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            fnd_msg_pub.count_and_get(
                p_count => x_msg_count,
                p_data  => x_msg_data
            );

        WHEN OTHERS THEN
            x_return_status := fnd_api.g_ret_sts_unexp_error;
            IF fnd_msg_pub.check_msg_level(fnd_msg_pub.g_msg_lvl_unexp_error) THEN
                fnd_msg_pub.add_exc_msg(g_pkg_name, l_api_name);
            END IF;
            fnd_msg_pub.count_and_get(
                p_count => x_msg_count,
                p_data  => x_msg_data
            );

    END get_predicate;

END qa_performance_pub;

/
