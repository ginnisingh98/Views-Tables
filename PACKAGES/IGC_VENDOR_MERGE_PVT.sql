--------------------------------------------------------
--  DDL for Package IGC_VENDOR_MERGE_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."IGC_VENDOR_MERGE_PVT" AUTHID CURRENT_USER AS
   -- $Header: IGCSMRGS.pls 120.1.12000000.1 2007/08/20 12:17:40 mbremkum noship $
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
END IGC_VENDOR_MERGE_PVT;


 

/
