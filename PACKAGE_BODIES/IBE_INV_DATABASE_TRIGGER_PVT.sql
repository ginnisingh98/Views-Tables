--------------------------------------------------------
--  DDL for Package Body IBE_INV_DATABASE_TRIGGER_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."IBE_INV_DATABASE_TRIGGER_PVT" AS
/* $Header: IBEVIDTB.pls 115.8 2003/05/05 03:44:54 ljanakir ship $ */

PROCEDURE MTL_Categories_B_Deleted(
   p_old_category_id IN NUMBER
)
IS
BEGIN
   -- 1. Update the table IBE_DSP_OBJ_LGL_CTNT
   IBE_LogicalContent_GRP.Delete_Category(
         p_category_id => p_old_category_id);

   -- 2. Update the table IBE_DSP_TPL_CTG
   IBE_TPLCategory_GRP.Delete_Category(
         p_category_id => p_old_category_id);

   -- 3. Update the table IBE_CT_RELATION_RULES
   IBE_Prod_Relation_PVT.Category_Deleted(
         p_category_id => p_old_category_id);
END MTL_Categories_B_Deleted;


PROCEDURE MTL_Item_Categories_Inserted(
   p_new_inventory_item_id IN NUMBER,
   p_new_organization_id   IN NUMBER,
   p_new_category_set_id   IN NUMBER,
   p_new_category_id       IN NUMBER
)
IS
BEGIN
   -- 1. Update IBE_CT_RELATED_ITEMS table
   IBE_Prod_Relation_PVT.Item_Category_Inserted(
         p_category_id       => p_new_category_id      ,
         p_inventory_item_id => p_new_inventory_item_id ,
	    p_organization_id   => p_new_organization_id);  --Bug 2922902

   -- 2. Update IBE_CT_IMEDIA_SEARCH table
   IBE_Search_PVT.Item_Category_Inserted(
         new_category_id       => p_new_category_id      ,
         new_category_set_id   => p_new_category_set_id  ,
         new_inventory_item_id => p_new_inventory_item_id,
         new_organization_id   => p_new_organization_id  );
END MTL_Item_Categories_Inserted;


PROCEDURE MTL_Item_Categories_Deleted(
   p_old_inventory_item_id IN NUMBER,
   p_old_organization_id   IN NUMBER,
   p_old_category_set_id   IN NUMBER,
   p_old_category_id       IN NUMBER
)
IS
BEGIN
   -- 1. Update IBE_CT_IMEDIA_SEARCH table
   IBE_Prod_Relation_PVT.Item_Category_Deleted(
         p_category_id       => p_old_category_id      ,
         p_inventory_item_id => p_old_inventory_item_id,
	    p_organization_id   => p_old_organization_id); --Bug 2922902

   -- 2. Update IBE_CT_IMEDIA_SEARCH table
   IBE_Search_PVT.Item_Category_Deleted(
         old_category_id       => p_old_category_id      ,
         old_category_set_id   => p_old_category_set_id  ,
         old_inventory_item_id => p_old_inventory_item_id,
         old_organization_id   => p_old_organization_id   );
END MTL_Item_Categories_Deleted;


PROCEDURE MTL_Item_Categories_Updated(
   p_old_inventory_item_id IN NUMBER,
   p_old_organization_id   IN NUMBER,
   p_old_category_set_id   IN NUMBER,
   p_old_category_id       IN NUMBER,
   p_new_inventory_item_id IN NUMBER,
   p_new_organization_id   IN NUMBER,
   p_new_category_set_id   IN NUMBER,
   p_new_category_id       IN NUMBER
)
IS
BEGIN
   -- 1. Update IBE_CT_IMEDIA_SEARCH table
   IBE_Search_PVT.Item_Category_Updated(
         old_category_id       => p_old_category_id      ,
         old_category_set_id   => p_old_category_set_id  ,
         old_inventory_item_id => p_old_inventory_item_id,
         old_organization_id   => p_old_organization_id  ,
         new_category_id       => p_new_category_id      ,
         new_category_set_id   => p_new_category_set_id  ,
         new_inventory_item_id => p_new_inventory_item_id,
         new_organization_id   => p_new_organization_id  );
END MTL_Item_Categories_Updated;


PROCEDURE MTL_System_Items_B_Deleted(
   p_old_inventory_item_id IN NUMBER,
   p_old_organization_id   IN NUMBER
)
IS
BEGIN
   -- 1. Update IBE_CT_RELATED_ITEMS table
   IBE_Prod_Relation_PVT.Item_Deleted(
         p_inventory_item_id => p_old_inventory_item_id,
         p_organization_id   => p_old_organization_id  );

   -- 2. Update section-items tables
   IBE_DSP_Section_Item_PVT.Delete_Section_Items_For_Item(
         p_inventory_item_id => p_old_inventory_item_id,
         p_organization_id   => p_old_organization_id  );

   -- 3. Update IBE_CT_IMEDIA_SEARCH table
   IBE_Search_PVT.Item_Deleted(
         old_inventory_item_id => p_old_inventory_item_id,
         old_organization_id   => p_old_organization_id  );

   -- 4. Update IBE_DSP_OBJ_LGL_CTNT table
   IBE_LogicalContent_GRP.Delete_Item(
         p_item_id => p_old_inventory_item_id);

END MTL_System_Items_B_Deleted;


PROCEDURE MTL_System_Items_B_Updated(
   p_old_inventory_item_id IN NUMBER,
   p_old_organization_id   IN NUMBER,
   p_old_web_status        IN VARCHAR2,
   p_new_web_status        IN VARCHAR2
 )
IS
BEGIN

   IF (p_old_web_status <> 'DISABLED' AND p_old_web_status IS NOT NULL) AND
      (p_new_web_status = 'DISABLED' OR p_new_web_status IS NULL) THEN
      -- 1. Update IBE_CT_RELATED_ITEMS table
      IBE_Prod_Relation_PVT.Item_Deleted(
            p_inventory_item_id => p_old_inventory_item_id,
            p_organization_id   => p_old_organization_id  );

      -- 2. Update section-items tables
      IBE_DSP_Section_Item_PVT.Delete_Section_Items_For_Item(
            p_inventory_item_id => p_old_inventory_item_id,
            p_organization_id   => p_old_organization_id  );
   END IF;

   -- 3. Update search table
   IBE_Search_PVT.Item_Updated(
         old_inventory_item_id => p_old_inventory_item_id,
         old_organization_id   => p_old_organization_id ,
         old_web_status        => p_old_web_status,
         new_web_status        => p_new_web_status
                              );


END MTL_System_Items_B_Updated;


PROCEDURE MTL_System_Items_TL_Inserted(
   p_new_inventory_item_id IN NUMBER  ,
   p_new_organization_id   IN NUMBER  ,
   p_new_language          IN VARCHAR2,
   p_new_description       IN VARCHAR2,
   p_new_long_description  IN VARCHAR2
)
IS
BEGIN
   -- 1. Update IBE_CT_IMEDIA_SEARCH table
   IBE_Search_PVT.ItemTL_Inserted(
         new_inventory_item_id => p_new_inventory_item_id,
         new_organization_id   => p_new_organization_id  ,
         new_language          => p_new_language         ,
         new_description       => p_new_description      ,
         new_long_description  => p_new_long_description );
END MTL_System_Items_TL_Inserted;


PROCEDURE MTL_System_Items_TL_Deleted(
   p_old_inventory_item_id IN NUMBER  ,
   p_old_organization_id   IN NUMBER  ,
   p_old_language          IN VARCHAR2
)
IS
BEGIN
   -- 1. Update IBE_CT_IMEDIA_SEARCH table
   IBE_Search_PVT.ItemTL_Deleted(
         old_inventory_item_id => p_old_inventory_item_id,
         old_organization_id   => p_old_organization_id  ,
         old_language          => p_old_language         );
END MTL_System_Items_TL_Deleted;


PROCEDURE MTL_System_Items_TL_Updated(
   p_old_inventory_item_id IN NUMBER  ,
   p_old_organization_id   IN NUMBER  ,
   p_old_language          IN VARCHAR2,
   p_old_description       IN VARCHAR2,
   p_old_long_description  IN VARCHAR2,
   p_new_language          IN VARCHAR2,
   p_new_description       IN VARCHAR2,
   p_new_long_description  IN VARCHAR2
)
IS
BEGIN
   -- 1. Update IBE_CT_IMEDIA_SEARCH table
   IBE_Search_PVT.ItemTL_Updated(
         old_inventory_item_id => p_old_inventory_item_id,
         old_organization_id   => p_old_organization_id  ,
         old_language          => p_old_language         ,
         new_language          => p_new_language         ,
         new_description       => p_new_description      ,
         new_long_description  => p_new_long_description );
END MTL_System_Items_TL_Updated;

END IBE_INV_Database_Trigger_PVT;

/
