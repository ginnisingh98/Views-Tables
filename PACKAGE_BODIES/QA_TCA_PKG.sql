--------------------------------------------------------
--  DDL for Package Body QA_TCA_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_TCA_PKG" AS
/* $Header: qatcab.pls 120.0 2005/05/24 17:58:39 appldev noship $ */


    PROCEDURE party_merge(
        p_entity_name          IN            VARCHAR2,
        p_from_id              IN            NUMBER,
        x_to_id                IN OUT NOCOPY NUMBER,
        p_from_fk_id           IN            NUMBER,
        p_to_fk_id             IN            NUMBER,
        p_parent_entity_name   IN            VARCHAR2,
        p_batch_id             IN            NUMBER,
        p_batch_party_id       IN            NUMBER,
        x_return_status        OUT NOCOPY    VARCHAR2) IS

        --
        -- This is Oracle Quality's party merge API provided to TCA.
        -- See Bug 3741531
        --
        -- p_entity_name should always be 'QA_RESULTS'.
        --
        -- p_from_id is NULL for a bulk party merge.
        --
        -- x_to_id is the new ID for merging purpose.  Since we are
        -- doing transfer, returning the same p_from_id.
        --
        -- p_from_fk_id is the party_id to be changed.
        --
        -- p_to_fk_id is the new party_id.
        --
        -- p_parent_entity_name should be 'HZ_PARTIES' since we are
        -- only have PARTY_ID as a foreign key.
        --
        -- p_batch_id is an internal TCA ID, unused in this procedure.
        --
        -- p_batch_party_id is an internal TCA ID, unused in this procedure.
        --
        -- x_return_status will be
        --    fnd_api.g_ret_sts_success if operation successfully completed.
        --    fnd_api.g_ret_sts_unexp_error if there is any exception.
        --

        CURSOR c IS
            SELECT qpc.plan_id
            FROM   qa_plan_chars qpc, qa_plans qp
            WHERE  qpc.plan_id = qp.plan_id AND
                   qpc.char_id = qa_ss_const.party_name AND
                   qp.organization_id <> 0;
        l_dummy NUMBER;

    BEGIN

        x_to_id := p_from_id;
        x_return_status := fnd_api.g_ret_sts_success;

        --
        -- We shall handle only HZ_PARTIES in QA_RESULTS.
        --
        IF p_entity_name = 'QA_RESULTS' AND
            p_parent_entity_name = 'HZ_PARTIES' AND
            p_from_fk_id <> p_to_fk_id THEN

            --
            -- This is an optimization to quickly return if there is
            -- no party element being used in any real collection plan.
            -- Since Party is a very obscure element, 99% of the time,
            -- this RETURN will be executed, guaranteeing good performance.
            --
            -- Should customer uses Party element and the quality result
            -- table is big, customer is adviced to create a custom index
            -- on qa_results.party_id.  This statement is also documented
            -- in TCA's party merge implementation guide.
            -- See bug 3741531 text.
            --
            OPEN c;
            FETCH c INTO l_dummy;
            IF c%notfound THEN
                CLOSE c;
                RETURN;
            END IF;
            CLOSE c;

            UPDATE qa_results qr
            SET    qr.party_id               = p_to_fk_id,
                   qr.last_update_date       = sysdate,
                   qr.qa_last_update_date    = sysdate,
                   qr.last_update_login      = hz_utility_pub.last_update_login,
                   qr.last_updated_by        = hz_utility_pub.user_id,
                   qr.qa_last_updated_by     = hz_utility_pub.user_id,
                   qr.request_id             = hz_utility_pub.request_id,
                   qr.program_application_id = hz_utility_pub.program_application_id,
                   qr.program_id             = hz_utility_pub.program_id,
                   qr.program_update_date    = sysdate
            WHERE  qr.party_id = p_from_fk_id;
        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            fnd_message.set_name('AR', 'HZ_MERGE_SQL_ERROR');
            fnd_message.set_token('ERROR', sqlerrm);
            fnd_msg_pub.add;
            x_return_status := fnd_api.g_ret_sts_unexp_error;

    END party_merge;


END qa_tca_pkg;

/
