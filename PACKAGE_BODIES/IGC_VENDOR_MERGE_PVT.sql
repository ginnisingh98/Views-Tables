--------------------------------------------------------
--  DDL for Package Body IGC_VENDOR_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IGC_VENDOR_MERGE_PVT" AS
   -- $Header: IGCSMRGB.pls 120.1.12000000.1 2007/08/20 12:17:43 mbremkum noship $
   --
   -- Global Variables
      g_org_id   NUMBER := to_number(fnd_profile.value('ORG_ID'));
      g_pkg_name CONSTANT VARCHAR2(30) := 'IGC_VENDOR_MERGE_PVT';
   --
   -- PUBLIC ROUTINES
   --
   --
   -- *************************************************************************
   -- Procedure : Merge_Vendor
   -- If CC is enabled,IGI_VENDOR_MERGE_GRP.merge_vendor will call this API.
   -- This API will update the igc_cc_headers table and the po_headers table
   -- It will update the PO headers table only for those records which are
   -- CC related.
   -- *************************************************************************

    PROCEDURE merge_vendor(p_api_version       IN  NUMBER
                           ,p_init_msg_list    IN  VARCHAR2 := FND_API.G_FALSE
                           ,p_commit           IN  VARCHAR2 := FND_API.G_FALSE
                           ,p_validation_level IN  NUMBER   := FND_API.G_VALID_LEVEL_FULL
                           ,x_return_status    OUT NOCOPY VARCHAR2
                           ,x_msg_count        OUT NOCOPY NUMBER
                           ,x_msg_data         OUT NOCOPY VARCHAR2
                           ,p_new_vendor_id      IN  NUMBER
                           ,p_new_vendor_site_id IN  NUMBER
                           ,p_old_vendor_id      IN  NUMBER
                           ,p_old_vendor_site_id IN  NUMBER)
   IS

   l_api_version   CONSTANT NUMBER       := 1.0;
   l_api_name      CONSTANT VARCHAR2(30) := 'VENDOR_MERGE';

   BEGIN

     -- Standard call to check for call compatibility
     IF (NOT FND_API.Compatible_API_Call(l_api_version
                                       ,p_api_version
                                       ,l_api_name
                                       ,G_PKG_NAME))
     THEN
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
     END IF;

     -- Check p_init_msg_list
     IF FND_API.to_Boolean(p_init_msg_list)
     THEN
        FND_MSG_PUB.initialize;
     END IF;

     -- Initialize API return status to success
     x_return_status := FND_API.G_RET_STS_SUCCESS;

     -- Update the PO headers table for the CC related rows.
     UPDATE po_headers
     SET    vendor_id         = p_new_vendor_id,
            vendor_site_id    = p_new_vendor_site_id,
            last_update_date  = SYSDATE,
            last_update_login = FND_GLOBAL.login_id,
            last_updated_by   = FND_GLOBAL.user_id
     WHERE  vendor_id         = p_old_vendor_id
     AND    vendor_site_id    = p_old_vendor_site_id
     AND    segment1          IN (SELECT cc_num
                                  FROM   igc_cc_headers
                                  WHERE  org_id            = g_org_id
                                  AND    vendor_id         = p_old_vendor_id
                                  AND    vendor_site_id    = p_old_vendor_site_id);

     UPDATE igc_cc_headers
     SET    vendor_id         = p_new_vendor_id,
            vendor_site_id    = p_new_vendor_site_id,
            last_update_date  = SYSDATE,
            last_update_login = FND_GLOBAL.login_id,
            last_updated_by   = FND_GLOBAL.user_id
     WHERE  vendor_id         = p_old_vendor_id
     AND    vendor_site_id    = p_old_vendor_site_id
     AND    org_id            = g_org_id;

     IF p_commit = FND_API.G_TRUE
     THEN
         COMMIT;
     END IF;

     FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                              p_data  => x_msg_data);

     EXCEPTION
     WHEN FND_API.G_EXC_UNEXPECTED_ERROR
     THEN
         x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
         FND_MSG_PUB.Count_And_Get(p_count => x_msg_count,
                                   p_data  => x_msg_data);

     WHEN OTHERS
     THEN
          x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
          IF FND_MSG_PUB.Check_Msg_Level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
          THEN
              FND_MSG_PUB.Add_Exc_Msg( G_PKG_NAME, l_api_name);
          END IF;

          FND_MSG_PUB.Count_And_Get( p_count  => x_msg_count,
                                     p_data   => x_msg_data);
     END merge_vendor;

END IGC_VENDOR_MERGE_PVT;


/
