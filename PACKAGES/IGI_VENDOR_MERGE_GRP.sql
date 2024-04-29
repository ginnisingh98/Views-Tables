--------------------------------------------------------
--  DDL for Package IGI_VENDOR_MERGE_GRP
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGI_VENDOR_MERGE_GRP" AUTHID CURRENT_USER AS
   -- $Header: igismrgs.pls 120.3 2007/06/22 10:13:34 smannava ship $
   --
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
                           ,p_old_vendor_site_id IN  NUMBER);
END IGI_VENDOR_MERGE_GRP;


/
