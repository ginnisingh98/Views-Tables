--------------------------------------------------------
--  DDL for Package Body QA_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QA_VENDORMERGE_GRP" AS
/* $Header: qavendb.pls 120.0 2005/10/31 16:29:31 bso noship $ */


    g_pkg_name CONSTANT VARCHAR2(30) := 'QA_VENDORMERGE_GRP';


        --
        -- Helper procedure to perform the actual updates to the
        -- qa_results table.
        --
        PROCEDURE update_qa_results(
            p_from_vendor_id NUMBER,
            p_to_vendor_id NUMBER) IS

        BEGIN
            --
            -- Quality only stores vendor ID, not vendor site, nor party
            -- therefore updating vendor ID only.  This UPDATE statement
            -- is potentially long running.  The customer is advised to
            -- create a custom index on QA_RESULTS.VENDOR_ID to make it
            -- more performing if this operation is run frequently.
            --

            UPDATE qa_results
            SET    vendor_id = p_to_vendor_id
            WHERE  vendor_id = p_from_vendor_id;

        END update_qa_results;


    --
    -- Vendor Merge.
    --
    --   See Bug 4541483
    --   bso Mon Oct 31 15:48:05 PST 2005
    --
    PROCEDURE merge_vendor(
        p_api_version            IN            NUMBER,
        p_init_msg_list          IN            VARCHAR2 default NULL,
        p_commit                 IN            VARCHAR2 default NULL,
        p_validation_level       IN            NUMBER   default NULL,
        p_return_status          OUT  NOCOPY   VARCHAR2,
        p_msg_count              OUT  NOCOPY   NUMBER,
        p_msg_data               OUT  NOCOPY   VARCHAR2,
        p_vendor_id              IN            NUMBER,
        p_dup_vendor_id          IN            NUMBER,
        p_vendor_site_id         IN            NUMBER,
        p_dup_vendor_site_id     IN            NUMBER,
        p_party_id               IN            NUMBER,
        P_dup_party_id           IN            NUMBER,
        p_party_site_id          IN            NUMBER,
        p_dup_party_site_id      IN            NUMBER) IS

        l_api_name      CONSTANT VARCHAR2(30)   := 'MERGE_VENDOR';
        l_api_version   CONSTANT NUMBER         := 1.0;

    BEGIN

        -- Standard Start of API savepoint
        SAVEPOINT qa_VendorMerge_grp;

        -- Standard call to check for call compatibility.
        IF NOT fnd_api.compatible_API_call(l_api_version, nvl(p_api_version,
            1.0), l_api_name, g_pkg_name) THEN
            RAISE fnd_api.G_EXC_UNEXPECTED_ERROR;
        END IF;

        --
        -- Standard call to reset message stack if needed.
        -- NULL is intentionally treated as false by this statement.
        --
        IF p_init_msg_list = fnd_api.G_TRUE THEN
            fnd_msg_pub.initialize;
        END IF;

        -- Perform actual update to database table.
        update_qa_results(
            p_from_vendor_id => p_dup_vendor_id,
            p_to_vendor_id => p_vendor_id);

        -- NULL is intentionally treated as false by this statement.
        IF p_commit = fnd_api.G_TRUE THEN
            COMMIT;
        END IF;

        p_return_status := fnd_api.G_RET_STS_SUCCESS;

    EXCEPTION
        WHEN fnd_api.G_EXC_ERROR THEN
            ROLLBACK TO qa_VendorMerge_grp;
            p_return_status := fnd_api.G_RET_STS_ERROR;
            fnd_msg_pub.count_and_get(
                p_count => p_msg_count,
                p_data  => p_msg_data);

        WHEN fnd_api.G_EXC_UNEXPECTED_ERROR THEN
            ROLLBACK TO qa_VendorMerge_grp;
            p_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
            fnd_msg_pub.count_and_get(
                p_count => p_msg_count,
                p_data  => p_msg_data);

        WHEN OTHERS THEN
            ROLLBACK TO qa_VendorMerge_grp;
            p_return_status := fnd_api.G_RET_STS_UNEXP_ERROR;
            fnd_msg_pub.count_and_get(
                p_count => p_msg_count,
                p_data  => p_msg_data);

            IF (fnd_msg_pub.check_msg_level(
                fnd_msg_pub.G_MSG_LVL_UNEXP_ERROR)) THEN
                fnd_msg_pub.add_exc_msg(
                    p_pkg_name       => g_pkg_name,
                    p_procedure_name => l_api_name,
                    p_error_text     => substr(SQLERRM, 1, 240));
            END IF;

    END merge_vendor;

END qa_VendorMerge_grp;

/
