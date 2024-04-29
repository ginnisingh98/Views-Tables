--------------------------------------------------------
--  DDL for Package JL_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."JL_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: jlzzpsms.pls 120.3 2006/03/13 19:34:44 dbetanco ship $ */

Procedure Merge_Vendor
               (p_api_version            IN            NUMBER
               ,p_init_msg_list          IN            VARCHAR2 default FND_API.G_FALSE
               ,p_commit                 IN            VARCHAR2 default FND_API.G_FALSE
               ,p_validation_level       IN            NUMBER   default FND_API.G_VALID_LEVEL_FULL
               ,p_return_status          OUT  NOCOPY   VARCHAR2
               ,p_msg_count              OUT  NOCOPY   NUMBER
               ,p_msg_data               OUT  NOCOPY   VARCHAR2
               ,p_vendor_id              IN            NUMBER --> Represents Merge To Vendor
               ,p_dup_vendor_id          IN            NUMBER --> Represents Merge From Vendor
               ,p_vendor_site_id         IN            NUMBER --> Represents Merge To Vendor Site
               ,p_dup_vendor_site_id     IN            NUMBER --> Represents Merge From Vendor Site
               ,p_party_id               IN            NUMBER --> Represents Merge To Party
               ,P_dup_party_id           IN            NUMBER --> Represents Merge From Party
               ,p_party_site_id          IN            NUMBER --> Represents Merge To Party Site
               ,p_dup_party_site_id      IN            NUMBER --> Represents Merge From Party Site
               );

END JL_VENDORMERGE_GRP;

 

/
