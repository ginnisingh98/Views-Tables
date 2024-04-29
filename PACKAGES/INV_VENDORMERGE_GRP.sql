--------------------------------------------------------
--  DDL for Package INV_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: INVTCASS.pls 120.1 2006/03/15 11:35:02 kgnanamu noship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : INVTCASS.pls                                               |
| Description  : This package contains functions called by                  |
|                Suppliers Merge program.                                   |
| Bug          : 4541401                                                    |
| Creator      : Karthik Gnanamurthy 03/15/2006                             |
+===========================================================================*/

PROCEDURE Merge_Vendor (
   p_api_version            IN            NUMBER,
   p_init_msg_list          IN            VARCHAR2 default FND_API.G_FALSE,
   p_commit                 IN            VARCHAR2 default FND_API.G_FALSE,
   p_validation_level       IN            NUMBER   default FND_API.G_VALID_LEVEL_FULL,
   p_return_status          OUT  NOCOPY   VARCHAR2,
   p_msg_count              OUT  NOCOPY   NUMBER,
   p_msg_data               OUT  NOCOPY   VARCHAR2,
   p_vendor_id              IN            NUMBER,
   p_dup_vendor_id          IN            NUMBER,
   p_vendor_site_id         IN            NUMBER,
   p_dup_vendor_site_id     IN            NUMBER,
   p_party_id               IN            NUMBER,
   p_dup_party_id           IN            NUMBER,
   p_party_site_id          IN            NUMBER,
   p_dup_party_site_id      IN            NUMBER);

END INV_VendorMerge_GRP;

 

/
