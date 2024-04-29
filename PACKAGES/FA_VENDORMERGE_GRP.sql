--------------------------------------------------------
--  DDL for Package FA_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FA_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: FAPVDMGS.pls 120.0.12010000.2 2009/07/19 12:53:49 glchen ship $   */

PROCEDURE Merge_Vendor(
              p_api_version        IN            NUMBER
            , p_init_msg_list      IN            VARCHAR2 default FND_API.G_FALSE
            , p_commit             IN            VARCHAR2 default FND_API.G_FALSE
            , p_validation_level   IN            NUMBER   default FND_API.G_VALID_LEVEL_FULL
            , x_return_status         OUT NOCOPY VARCHAR2
            , x_msg_count             OUT NOCOPY NUMBER
            , x_msg_data              OUT NOCOPY VARCHAR2
            , p_vendor_id          IN            NUMBER
            , p_dup_vendor_id      IN            NUMBER
            , p_vendor_site_id     IN            NUMBER
            , p_dup_vendor_site_id IN            NUMBER
            , p_party_id           IN            NUMBER
            , p_dup_party_id       IN            NUMBER
            , p_party_site_id      IN            NUMBER
            , p_dup_party_site_id  IN            NUMBER
            , p_segment1           IN            VARCHAR2
            , p_dup_segment1       IN            VARCHAR2
            , p_vendor_name        IN            VARCHAR2 default NULL
);

END FA_VENDORMERGE_GRP;

/
