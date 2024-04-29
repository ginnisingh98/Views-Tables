--------------------------------------------------------
--  DDL for Package CSP_SUPERSESSIONS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."CSP_SUPERSESSIONS_PVT" AUTHID CURRENT_USER AS
/* $Header: cspgsups.pls 115.7 2002/11/26 06:54:41 hhaugeru noship $ */
-- Start of Comments
-- Package name     : CSP_SUPERSESSIONS_PVT
-- Purpose          :
-- History          :
-- NOTE             :
-- End of Comments

    TYPE number_arr  IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    PROCEDURE PROCESS_SUPERSESSIONS(errbuf OUT NOCOPY varchar2,
    				    retcode OUT NOCOPY number);
    PROCEDURE check_for_supersede_item(p_inventory_item_id IN NUMBER
                                  ,p_organization_id   IN NUMBER
                                  ,x_supersede_item    OUT NOCOPY NUMBER);
    PROCEDURE get_supersede_bilateral_items(p_inventory_item_id IN NUMBER
                                           ,p_organization_id   IN NUMBER
                                           ,x_supersede_items    OUT NOCOPY CSP_SUPERSESSIONS_PVT.number_arr);
   PROCEDURE get_top_supersede_item(p_item_id IN NUMBER
                                   ,p_org_id  IN NUMBER
                                   ,x_item_id OUT NOCOPY NUMBER);
  PROCEDURE get_replaced_items_list(p_inventory_item_id IN NUMBER
                                    ,p_organization_id   IN NUMBER
                                    ,x_replaced_item_list OUT NOCOPY VARCHAR2);
  PROCEDURE PROCESS_SUPERSESSIONS(p_level_id IN VARCHAR2
                                  ,p_commit   IN VARCHAR2 DEFAULT FND_API.G_FALSE
                                  ,x_return_status OUT NOCOPY VARCHAR2
                                  ,x_msg_data      OUT NOCOPY varchar2
                                  ,x_msg_count     OUT NOCOPY NUMBER);

  PROCEDURE  check_for_duplicate_parts(l_parts_list  IN      CSP_SCH_INT_PVT.CSP_PARTS_TBL_TYP1
                                       ,p_org_id     IN    NUMBER
                                       ,x_return_status OUT NOCOPY  varchar2
                                       ,x_message OUT NOCOPY varchar2
                                       ,x_msg_count OUT NOCOPY NUMBER);

END;

 

/
