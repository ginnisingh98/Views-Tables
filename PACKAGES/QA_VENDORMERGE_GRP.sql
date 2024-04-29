--------------------------------------------------------
--  DDL for Package QA_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."QA_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: qavends.pls 120.0 2005/10/31 16:29:15 bso noship $ */

    --
    -- Vendor Merge.
    --
    -- Procedure name merge_vendor and all parameter namings
    -- are required standards as documented in Bug 4541483.
    -- Except the hard default values are hereby replaced with
    -- NULL to comply with performance standard.  NULL values
    -- function the same as the documented defaults.
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
        p_dup_party_site_id      IN            NUMBER);

END qa_VendorMerge_grp;

 

/
