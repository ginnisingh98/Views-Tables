--------------------------------------------------------
--  DDL for Package Body AHL_VENDORMERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."AHL_VENDORMERGE_GRP" AS
/* $Header: AHLGVDMB.pls 120.1 2005/09/23 17:00:28 jeli noship $ */

-- Start of comments
--    API name 	   :MERGE_VENDOR
--    Type	       :Group
--    Function	   :
--    Pre-reqs	   :None
--    Parameters   :
--	IN	   : p_api_version       IN   NUMBER	       Required
--		     p_init_msg_list	 IN   VARCHAR2         Optional
--				    Default = FND_API.G_FALSE
--		     p_commit	    	 IN   VARCHAR2	       Optional
--				    Default = FND_API.G_FALSE
--		     p_validation_level	 IN   NUMBER	       Optional
--				    Default = FND_API.G_VALID_LEVEL_FULL
--  p_vendor_id --> Represents Merge To Vendor
--  p_dup_vendor_id --> Represents Merge From Vendor
--  p_vendor_site_id --> Represents Merge To Vendor Site
--  p_dup_vendor_site_id --> Represents Merge From Vendor Site
--  p_party_id --> Represents Merge To Party
--  p_dup_party_id --> Represents Merge From Party
--  p_party_site_id --> Represents Merge To Party Site
--  p_dup_party_site_id --> Represents Merge From Party Site
--
--	OUT	   : x_return_status	 OUT    VARCHAR2(1)
--		     x_msg_count	 OUT	NUMBER
--		     x_msg_data		 OUT	VARCHAR2(2000)
--				.
--	Version	   : Current version	1.0
--			     Initial version 	1.0
--
--	Notes		: Note text
--      Status complete except for comments in the spec.
-- End of comments

G_PKG_NAME 	CONSTANT VARCHAR2(30):='AHL_VENDORMERGE_GRP';

PROCEDURE MERGE_VENDOR(
        p_api_version        IN   NUMBER,
	    p_init_msg_list      IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	    p_commit             IN   VARCHAR2 DEFAULT FND_API.G_FALSE,
	    p_validation_level   IN   NUMBER  := FND_API.G_VALID_LEVEL_FULL,
	    x_return_status      OUT  NOCOPY VARCHAR2,
	    x_msg_count          OUT  NOCOPY NUMBER,
	    x_msg_data           OUT  NOCOPY VARCHAR2,
	    p_vendor_id          IN   NUMBER,
	    p_vendor_site_id     IN   NUMBER,
	    p_dup_vendor_id      IN   NUMBER,
	    p_dup_vendor_site_id IN   NUMBER,
        p_party_id           IN   NUMBER,
        p_dup_party_id       IN   NUMBER,
        p_party_site_id      IN   NUMBER,
        p_dup_party_site_id  IN   NUMBER)
IS
        l_api_name	      CONSTANT VARCHAR2(30)	:= 'MERGE_VENDOR';
        l_api_version     CONSTANT NUMBER 	        := 1.0;
BEGIN
        --  Initialize API return status to success
        x_return_status := FND_API.G_RET_STS_SUCCESS;

        -- Check for call compatibility.
        IF NOT FND_API.Compatible_API_Call (l_api_version,
                                            p_api_version,
                                            l_api_name,
                                            G_PKG_NAME) THEN
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        -- Initialize API message list if necessary.
        -- Initialize message list if p_init_msg_list is set to TRUE.
        IF FND_API.to_Boolean( p_init_msg_list) THEN
          FND_MSG_PUB.initialize;
        END IF;

        -- OSP Order Table
        UPDATE ahl_osp_orders_b
           SET vendor_id = p_vendor_id,
               vendor_site_id = p_vendor_site_id,
               last_updated_by = FND_GLOBAL.user_id,
               last_update_date = SYSDATE
         WHERE vendor_id = p_dup_vendor_id
           AND vendor_site_id = p_dup_vendor_site_id;

        -- OSP Vendor Table
        UPDATE ahl_vendor_customer_rels
           SET vendor_site_id = p_vendor_site_id,
               last_updated_by = FND_GLOBAL.user_id,
               last_update_date = SYSDATE
         WHERE vendor_site_id = p_dup_vendor_site_id;

        -- DI Table
        UPDATE ahl_supplier_documents
           SET supplier_id = p_vendor_id,
               last_updated_by = FND_GLOBAL.user_id,
               last_update_date = SYSDATE
         WHERE supplier_id = p_dup_vendor_id;

         -- Parameter party_id and party_site_id are included, but not sure whether we need to
         -- update table ahl_vendor_customer_rels(vendor_site_id, customer_site_id).

	 -- Standard check of p_commit.
	 IF FND_API.To_Boolean(p_commit) THEN
	   COMMIT WORK;
	 END IF;

EXCEPTION
  WHEN OTHERS THEN
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR ;
    IF FND_MSG_PUB.check_msg_level(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR)
    THEN
      FND_MSG_PUB.add_exc_msg(
        p_pkg_name         => G_PKG_NAME,
        p_procedure_name   => l_api_name,
        p_error_text       => SUBSTRB(SQLERRM,1,240));
    END IF;
    FND_MSG_PUB.count_and_get(
      p_encoded  => FND_API.G_FALSE,
      p_count    => x_msg_count,
      p_data     => x_msg_data);

END MERGE_VENDOR;

END AHL_VENDORMERGE_GRP;

/
