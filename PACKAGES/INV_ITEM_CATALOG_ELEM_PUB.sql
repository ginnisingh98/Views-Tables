--------------------------------------------------------
--  DDL for Package INV_ITEM_CATALOG_ELEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE "APPS"."INV_ITEM_CATALOG_ELEM_PUB" AUTHID CURRENT_USER AS
/* $Header: INVCEOIS.pls 115.0 2003/12/08 09:55:50 rvuppala noship $ */

------------------------------ Global variables -------------------------------

g_xset_id         NUMBER  :=  fnd_api.g_MISS_NUM;
g_user_id         NUMBER  :=  -1;
g_login_id        NUMBER  :=  -1;
g_prog_appid      NUMBER  :=  -1;
g_prog_id         NUMBER  :=  -1;
g_request_id      NUMBER  :=  -1;

-- Validation level

g_VALIDATE_NONE     CONSTANT  NUMBER  :=  0;
g_VALIDATE_RULES    CONSTANT  NUMBER  :=  10;
g_VALIDATE_IDS      CONSTANT  NUMBER  :=  20;
g_VALIDATE_VALUES   CONSTANT  NUMBER  :=  30;
g_VALIDATE_ALL      CONSTANT  NUMBER  :=  100;
g_VALIDATE_LEVEL_FULL  CONSTANT  NUMBER  :=  100;

-------------------------- Global type declarations --------------------------
TYPE ITEM_DESC_ELEMENT IS RECORD
     (
       ELEMENT_NAME         VARCHAR2(30)
      ,ELEMENT_VALUE        VARCHAR2(30)
      ,DESCRIPTION_DEFAULT  VARCHAR2(1)
     );

TYPE ITEM_DESC_ELEMENT_TABLE IS TABLE OF ITEM_DESC_ELEMENT
                            INDEX BY BINARY_INTEGER;

------------------------ process_Item_Catalog_element_records ---------------------

PROCEDURE Process_item_descr_elements
     (
        p_api_version        IN   NUMBER
     ,  p_init_msg_list      IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
     ,  p_commit_flag        IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
     ,  p_validation_level   IN   NUMBER    DEFAULT  INV_ITEM_CATALOG_ELEM_PUB.g_VALIDATE_ALL
     ,  p_inventory_item_id  IN   NUMBER    DEFAULT  -999
     ,  p_item_number        IN   VARCHAR2  DEFAULT  NULL
     ,  p_item_desc_element_table IN ITEM_DESC_ELEMENT_TABLE
     ,  x_generated_descr    OUT NOCOPY VARCHAR2
     ,  x_return_status      OUT NOCOPY VARCHAR2
     ,  x_msg_count          OUT NOCOPY NUMBER
     ,  x_msg_data           OUT NOCOPY VARCHAR2
     );

------------------------ process_Item_Catalog_element_Interface_records --------------

PROCEDURE process_Item_Catalog_grp_recs
(
   ERRBUF              OUT  NOCOPY VARCHAR2
,  RETCODE             OUT  NOCOPY NUMBER
,  p_rec_set_id        IN   NUMBER
,  p_upload_rec_flag   IN   NUMBER    DEFAULT  1
,  p_delete_rec_flag   IN   NUMBER    DEFAULT  1
,  p_commit_flag       IN   NUMBER    DEFAULT  1
,  p_prog_appid        IN   NUMBER    DEFAULT  NULL
,  p_prog_id           IN   NUMBER    DEFAULT  NULL
,  p_request_id        IN   NUMBER    DEFAULT  NULL
,  p_user_id           IN   NUMBER    DEFAULT  NULL
,  p_login_id          IN   NUMBER    DEFAULT  NULL
);


------------------------------ delete_OI_records ------------------------------

PROCEDURE delete_OI_records
(
   p_commit         IN   VARCHAR2  DEFAULT  fnd_api.g_FALSE
,  p_rec_set_id     IN   NUMBER
,  x_return_status  OUT  NOCOPY VARCHAR2
);


END INV_ITEM_CATALOG_ELEM_PUB;

 

/
