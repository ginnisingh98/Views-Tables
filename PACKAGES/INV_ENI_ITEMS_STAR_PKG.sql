--------------------------------------------------------
--  DDL for Package INV_ENI_ITEMS_STAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ENI_ITEMS_STAR_PKG" AUTHID CURRENT_USER AS
/* $Header: INVENICS.pls 120.1 2005/08/04 06:22:07 lparihar noship $  */

-- Create or update an item-category assignment

PROCEDURE Sync_Category_Assignments(
                  p_api_version       IN         NUMBER
                 ,p_init_msg_list     IN         VARCHAR2 := 'F'
                 ,p_inventory_item_id IN         NUMBER
                 ,p_organization_id   IN         NUMBER
		 ,p_category_set_id   IN         NUMBER
		 ,p_old_category_id   IN         NUMBER
		 ,p_new_category_id   IN         NUMBER
                 ,x_return_status     OUT NOCOPY VARCHAR2
                 ,x_msg_count         OUT NOCOPY NUMBER
                 ,x_msg_data          OUT NOCOPY VARCHAR2);

PROCEDURE Update_ENI_Staging_Table(
                  p_mode_flag         IN         VARCHAR2
                 ,p_category_set_id   IN         NUMBER
                 ,p_category_id       IN         NUMBER
                 ,p_language_code     IN         VARCHAR2
                 ,x_return_status     OUT NOCOPY VARCHAR2
                 ,x_msg_count         OUT NOCOPY NUMBER
                 ,x_msg_data          OUT NOCOPY VARCHAR2);

PROCEDURE SYNC_STAR_ITEMS_FROM_IOI(
                  p_api_version       IN         NUMBER
                 ,p_init_msg_list     IN         VARCHAR2 := 'F'
                 ,p_set_process_id    IN         NUMBER
                 ,x_return_status     OUT NOCOPY VARCHAR2
                 ,x_msg_count         OUT NOCOPY NUMBER
                 ,x_msg_data          OUT NOCOPY VARCHAR2);

PROCEDURE Sync_Star_ItemCatg_From_COI(
                  p_api_version       IN         NUMBER
                 ,p_init_msg_list     IN         VARCHAR2 := 'F'
                 ,p_set_process_id    IN         NUMBER
                 ,x_return_status     OUT NOCOPY VARCHAR2
                 ,x_msg_count         OUT NOCOPY NUMBER
                 ,x_msg_data          OUT NOCOPY VARCHAR2);

End INV_ENI_ITEMS_STAR_PKG;

 

/
