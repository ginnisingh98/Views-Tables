--------------------------------------------------------
--  DDL for Package ENI_ITEMS_STAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."ENI_ITEMS_STAR_PKG" AUTHID CURRENT_USER AS
/* $Header: ENIIDBCS.pls 120.1 2005/08/22 05:58:21 lparihar noship $  */

PROCEDURE CREATE_STAR_TABLE(errbuf OUT NOCOPY  varchar2,
                            retcode OUT NOCOPY  varchar2);

-- Insert new item

PROCEDURE Insert_Items_In_Star(p_api_version NUMBER,
                              p_init_msg_list VARCHAR2 := 'F',
                              p_inventory_item_id NUMBER,
                              p_organization_id NUMBER,
                              x_return_status OUT NOCOPY  VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              X_MSG_DATA OUT NOCOPY  VARCHAR2);

--Delete item

PROCEDURE Delete_Items_In_Star(p_api_version NUMBER,
                              p_init_msg_list VARCHAR2 := 'F',
                              p_inventory_item_id NUMBER,
                              p_organization_id NUMBER,
                              x_return_status OUT NOCOPY  VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              X_MSG_DATA OUT NOCOPY  VARCHAR2);

-- Update concatenated segments for an existing item

PROCEDURE Update_Items_In_Star(p_api_version NUMBER,
                              p_init_msg_list VARCHAR2 := 'F',
                              p_inventory_item_id NUMBER,
                              p_organization_id NUMBER,
                              x_return_status OUT NOCOPY  VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              X_MSG_DATA OUT NOCOPY  VARCHAR2);

-- Create or Change an category assignment

PROCEDURE Update_Categories(p_api_version NUMBER,
                              p_init_msg_list VARCHAR2 := 'F',
                              p_category_id NUMBER,
                              p_structure_id NUMBER,
                              x_return_status OUT NOCOPY  VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              X_MSG_DATA OUT NOCOPY  VARCHAR2);

-- UPdate or delete item-category assignment

PROCEDURE Sync_Category_Assignments(p_api_version NUMBER,
                                    p_init_msg_list VARCHAR2 := 'F',
                                    p_inventory_item_id NUMBER,
                                    p_organization_id NUMBER,
                                    x_return_status OUT NOCOPY  VARCHAR2,
                                    x_msg_count OUT NOCOPY  NUMBER,
                                    X_MSG_DATA OUT NOCOPY  VARCHAR2);

-- Inserts/updates item star table from item open interface

PROCEDURE Sync_Star_Items_From_IOI(p_api_version NUMBER,
                              p_init_msg_list VARCHAR2 := 'F',
                              p_set_process_id NUMBER,
                              x_return_status OUT NOCOPY  VARCHAR2,
                              x_msg_count OUT NOCOPY  NUMBER,
                              X_MSG_DATA OUT NOCOPY  VARCHAR2);

-- Inserts/Deletes item category assignment from star table from
-- Categories open interface

PROCEDURE Sync_Star_ItemCatg_From_COI(
                              p_api_version    IN NUMBER,
                              p_init_msg_list  IN VARCHAR2 := 'F',
                              p_set_process_id IN NUMBER,
                              x_return_status  OUT NOCOPY  VARCHAR2,
                              x_msg_count      OUT NOCOPY  NUMBER,
                              X_MSG_DATA       OUT NOCOPY  VARCHAR2);

End ENI_ITEMS_STAR_PKG;

 

/
