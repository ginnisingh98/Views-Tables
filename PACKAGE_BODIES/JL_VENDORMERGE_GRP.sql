--------------------------------------------------------
--  DDL for Package Body JL_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."JL_VENDORMERGE_GRP" AS
/* $Header: jlzzpsmb.pls 120.4 2006/04/11 21:12:46 dbetanco ship $ */

G_PKG_NAME                CONSTANT VARCHAR2(50) := 'JL_VENDORMERGE_GRP_PKG';
G_CURRENT_RUNTIME_LEVEL   CONSTANT NUMBER       := FND_LOG.G_CURRENT_RUNTIME_LEVEL;
G_LEVEL_UNEXPECTED        CONSTANT NUMBER       := FND_LOG.LEVEL_UNEXPECTED;
G_LEVEL_ERROR             CONSTANT NUMBER       := FND_LOG.LEVEL_ERROR;
G_LEVEL_EXCEPTION         CONSTANT NUMBER       := FND_LOG.LEVEL_EXCEPTION;
G_LEVEL_EVENT             CONSTANT NUMBER       := FND_LOG.LEVEL_EVENT;
G_LEVEL_PROCEDURE         CONSTANT NUMBER       := FND_LOG.LEVEL_PROCEDURE;
G_LEVEL_STATEMENT         CONSTANT NUMBER       := FND_LOG.LEVEL_STATEMENT;
G_MODULE_NAME             CONSTANT VARCHAR2(250) := 'ZX.PLSQL.JL_VENDORMERGE_GRP_PKG.';

/********************************************************************
 Prodeure: Merge_Vendor
 Objective: This package is called from AP - Supplier Merge Process
            Following procedure will update the vendor_id and
            vendor_site_id in JL tables.
 Parameters: p_vendor_id is supplier to
             p_dup_vendor_id supplier from

 *******************************************************************/

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
               ) IS

   l_api_name  CONSTANT VARCHAR2(50) := 'Merge_Vendor';
   l_api_version       CONSTANT  NUMBER := 1.0;

Begin

   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
      FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.BEGIN',G_PKG_NAME||': '||l_api_name||'()+');
   END IF;

    SAVEPOINT import_document_PVT;

    -- Standard call to check for call compatibility
    IF NOT FND_API.Compatible_API_Call(l_api_version,
                                       p_api_version,
                                       l_api_name,
                                       G_PKG_NAME
                                       ) THEN
       RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
   END IF;

   -- Initialize API message list if necessary.
   -- Initialize message list if p_init_msg_list is set to TRUE.
   IF FND_API.to_Boolean( p_init_msg_list) THEN
      FND_MSG_PUB.initialize;
   END IF;


   p_return_status := FND_API.G_RET_STS_SUCCESS;

   IF p_dup_vendor_id is not null and p_dup_vendor_site_id is null
      and p_vendor_id is not null Then

      SAVEPOINT jl_vendor_merge;

      -- Update JL_ZZ_AP_SUPP_AWT_TYPES - vendor_id
         Update JL_ZZ_AP_SUPP_AWT_TYPES
            set vendor_id = p_vendor_id
          where vendor_id = p_dup_vendor_id;

      -- Update JL_BR_AP_COLLECTION_DOCS_ALL - vendor_id
         Update JL_BR_AP_COLLECTION_DOCS_ALL
            set vendor_id = p_vendor_id
          where vendor_id = p_dup_vendor_id;

      -- Update JL_BR_AP_CONSOLID_INVOICES_ALL - vendor_id
         Update JL_BR_AP_CONSOLID_INVOICES_ALL
            set vendor_id = p_vendor_id
          where vendor_id = p_dup_vendor_id;

      -- Update JG_ZZ_ENTITY_ASSOC
         Update JG_ZZ_ENTITY_ASSOC
            set associated_entity_id = p_vendor_id
          where associated_entity_id = p_dup_vendor_id;

   ELSif p_dup_vendor_id is not null and p_dup_vendor_site_id is not null
         and p_vendor_id is not null and p_vendor_site_id is not null Then

        -- Update JL_BR_AP_COLLECTION_DOCS_ALL - vendor_id
           Update JL_BR_AP_COLLECTION_DOCS_ALL
              set vendor_id      = p_vendor_id,
                  vendor_site_id = p_vendor_site_id
            where vendor_id      = p_dup_vendor_id
              and vendor_site_id = p_dup_vendor_site_id;

        -- Update JL_BR_AP_CONSOLID_INVOICES_ALL - vendor_id
           Update JL_BR_AP_CONSOLID_INVOICES_ALL
              set vendor_id      = p_vendor_id,
                  vendor_site_id = p_vendor_site_id
            where vendor_id      = p_dup_vendor_id
              and vendor_site_id = p_dup_vendor_site_id;

   END IF;

   IF FND_API.To_Boolean( p_commit ) THEN
      COMMIT WORK;
   END IF;

   -- Standard check of p_commit.
   IF ( G_LEVEL_PROCEDURE >= G_CURRENT_RUNTIME_LEVEL) THEN
     FND_LOG.STRING(G_LEVEL_PROCEDURE,G_MODULE_NAME||l_api_name||'.END',G_PKG_NAME||': '||l_api_name||'()-');
   END IF;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
        NULL;
   WHEN OTHERS THEN
     p_return_status := FND_API.G_RET_STS_ERROR ;
     ROLLBACK TO jl_vendor_merge;
     FND_MESSAGE.SET_NAME('AR', 'HZ_MERGE_SQL_ERROR');
     FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
     FND_MSG_PUB.Add;
     /*---------------------------------------------------------+
      | FND_MSG_PUB.Count_And_Get used to get the count of mesg.|
      | in the message stack. If there is only one message in   |
      | the stack it retrieves this message                     |
      +---------------------------------------------------------*/
      FND_MSG_PUB.Count_And_Get(p_encoded => FND_API.G_FALSE,
                  p_count   =>      p_msg_count,
                  p_data    =>      p_msg_data
                  );
     --
     IF ( G_LEVEL_EXCEPTION >= G_CURRENT_RUNTIME_LEVEL) THEN
         FND_LOG.STRING(G_LEVEL_EXCEPTION,G_MODULE_NAME||l_api_name,SQLERRM);
     END IF;

END Merge_Vendor;

END JL_VENDORMERGE_GRP;

/
