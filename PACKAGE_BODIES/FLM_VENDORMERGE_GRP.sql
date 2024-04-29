--------------------------------------------------------
--  DDL for Package Body FLM_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FLM_VENDORMERGE_GRP" AS
/* $Header: FLMTCAB.pls 120.0 2005/10/19 16:45:21 asuherma noship $ */
/*==========================================================================+
|   Copyright (c) 1997 Oracle Corporation Redwood Shores, California, USA   |
|                          All rights reserved.                             |
+===========================================================================+
|                                                                           |
| File Name    : FLMMMMCB.pls                                               |
| Description  : This package contains functions called by                  |
|                Suppliers Merge program.                                   |
| Coders       : Adrian Suherman        08/11/2005                          |
+===========================================================================*/

   G_PKG_NAME              CONSTANT VARCHAR2(30) := 'FLM_VendorMerge_GRP';

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
      p_dup_party_site_id      IN            NUMBER) IS

      l_api_version                 CONSTANT NUMBER := 1.0;
      l_api_name                    CONSTANT VARCHAR2(30) := 'Merge_Vendor';

   BEGIN

      if not FND_API.Compatible_API_Call
        (       l_api_version,
                p_api_version,
                l_api_name,
                G_PKG_NAME)
      then
         raise FND_API.G_EXC_UNEXPECTED_ERROR;
      end if;

      p_return_status := fnd_api.g_ret_sts_success;

      update flm_kanban_summary
      set supplier_id = p_vendor_id
      where supplier_id = p_dup_vendor_id;

      update flm_kanban_summary
      set supplier_site_id = p_vendor_site_id
      where supplier_site_id = p_dup_vendor_site_id;

      --  Get message count and data
      FND_MSG_PUB.Count_And_Get
      (   p_count   => p_msg_count,
          p_data    => p_msg_data
      );

      if (p_commit = FND_API.G_TRUE) then
         commit;
      end if;

   EXCEPTION
      WHEN OTHERS THEN
         fnd_message.set_name('AR', 'HZ_MERGE_SQL_ERROR');
         fnd_message.set_token('ERROR', sqlerrm);
         fnd_msg_pub.add;
         p_return_status := fnd_api.g_ret_sts_unexp_error;

   END Merge_Vendor;

END FLM_VendorMerge_GRP;

/
