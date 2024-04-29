--------------------------------------------------------
--  DDL for Package FLM_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."FLM_VENDORMERGE_GRP" AUTHID CURRENT_USER AS
/* $Header: FLMTCAS.pls 120.0 2005/10/19 16:45:03 asuherma noship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : FLMTCAS.pls                                                |
| Description  : This package contains functions called by                  |
|                Suppliers Merge program.                                   |
| Coders       : Adrian Suherman 	08/11/2005                          |
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

END FLM_VendorMerge_GRP;

 

/
