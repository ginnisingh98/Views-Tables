--------------------------------------------------------
--  DDL for Package Body INV_ENI_ITEMS_STAR_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_ENI_ITEMS_STAR_PKG" AS
/* $Header: INVENICB.pls 120.4 2005/11/07 02:19:23 lparihar noship $  */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'INV_ENI_ITEMS_STAR_PKG';


--**********************************************************************
-- Maintains STAR table when changes are detected on MTL_ITEM_CATEGORIES
--**********************************************************************

PROCEDURE Sync_Category_Assignments(
                  p_api_version       IN         NUMBER
                 ,p_init_msg_list     IN         VARCHAR2
                 ,p_inventory_item_id IN         NUMBER
                 ,p_organization_id   IN         NUMBER
		 ,p_category_set_id   IN         NUMBER
		 ,p_old_category_id   IN         NUMBER
		 ,p_new_category_id   IN         NUMBER
                 ,x_return_status     OUT NOCOPY VARCHAR2
                 ,x_msg_count         OUT NOCOPY NUMBER
                 ,x_msg_data          OUT NOCOPY VARCHAR2) IS
BEGIN

   IF (INV_ITEM_UTIL.Object_Exists
         (p_object_type  => 'PACKAGE',
          p_object_name  => 'ENI_ITEMS_STAR_PKG') = 'Y')
   THEN

      EXECUTE IMMEDIATE
      ' BEGIN                                                '||
      '    ENI_ITEMS_STAR_PKG.Sync_Category_Assignments(     '||
      '       p_api_version         => :p_api_version        '||
      '    ,  p_init_msg_list       => :p_init_msg_list      '||
      '    ,  p_inventory_item_id   => :p_Inventory_Item_ID  '||
      '    ,  p_organization_id     => :p_Organization_ID    '||
      '    ,  x_return_status       => :x_return_status      '||
      '    ,  x_msg_count           => :x_msg_count          '||
      '    ,  x_msg_data            => :x_msg_data   );      '||
      ' END;'
      USING IN  p_api_version,
            IN  p_init_msg_list,
            IN  p_inventory_item_id,
            IN  p_organization_id,
            OUT x_return_status,
            OUT x_msg_count,
            OUT x_msg_data;

   END IF;

   IF ((INV_ITEM_UTIL.Object_Exists
         (p_object_type  => 'PACKAGE',
          p_object_name  => 'ENI_UPD_ASSGN') = 'Y')
	AND x_return_status ='S' )
   THEN
      EXECUTE IMMEDIATE
      ' BEGIN                                            '||
      '    ENI_UPD_ASSGN.UPDATE_ASSGN_FLAG(              '||
      '       p_new_category_id   => :p_new_category_id  '||
      '    ,  p_old_category_id   => :p_old_category_id  '||
      '    ,  x_return_status     => :x_return_status    '||
      '    ,  x_msg_count         => :x_msg_count        '||
      '    ,  x_msg_data          => :x_msg_data   );    '||
      ' END;'
      USING IN  p_new_category_id,
            IN  p_old_category_id,
            OUT x_return_status,
            OUT x_msg_count,
            OUT x_msg_data;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
END;

PROCEDURE Update_ENI_Staging_Table(
                  p_mode_flag         IN         VARCHAR2
                 ,p_category_set_id   IN         NUMBER
                 ,p_category_id       IN         NUMBER
                 ,p_language_code     IN         VARCHAR2
                 ,x_return_status     OUT NOCOPY VARCHAR2
                 ,x_msg_count         OUT NOCOPY NUMBER
                 ,x_msg_data          OUT NOCOPY VARCHAR2) IS
  ----------------------------------------------------------------------
  -- Start of comments
  --
  -- Procedure name  : Update_ENI_Staging_Table
  -- Type            : Public
  -- Pre-reqs        : None
  -- Requirement     : Bug 3134279 (11.5.10 Requirement)
  -- Functionality   : To insert data into eni_denorm_hrchy_stg so that
  --                   DBI team can use the same for denormalization
  -- Notes           :
  --
  -- History         :
  --    09-SEP-2003     Sridhar R       Creation
  --
  -- END OF comments
  ----------------------------------------------------------------------

  l_object_type  CONSTANT VARCHAR2(20) := 'CATEGORY_SET';
BEGIN
  IF (INV_ITEM_UTIL.Object_Exists
         (p_object_type => 'PACKAGE',
          p_object_name  => 'ENI_DENORM_HRCHY') = 'Y') THEN
    -- the package exists
      EXECUTE IMMEDIATE
       ' BEGIN                                             '||
       '    ENI_DENORM_HRCHY.Insert_Into_Staging (         '||
       '       p_object_type     => :b_object_type         '||
       '      ,p_object_id       => :b_caregory_set_id     '||
       '      ,p_child_id        => :b_category_id         '||
       '      ,p_parent_id       => NULL                   '||
       '      ,p_mode_flag       => :b_mode_flag           '||
       '      ,p_language_code   => :b_language_code       '||
       '      ,x_return_status   => :b_return_status       '||
       '      ,x_msg_count       => :b_msg_count           '||
       '      ,x_msg_data        => :b_msg_data   );       '||
       ' END;'
      USING IN  l_object_type,
            IN  p_category_set_id,
            IN  p_category_id,
            IN  p_mode_flag,
            IN  p_language_code,
            OUT x_return_status,
            OUT x_msg_count,
            OUT x_msg_data;
      IF (x_return_status <> 'S') THEN
        RETURN;
      END IF;
    END IF;  -- package exists

  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := 'U';
      -- Bug 4569555 RAISE;
END Update_ENI_Staging_Table;

PROCEDURE SYNC_STAR_ITEMS_FROM_IOI(
                  p_api_version       IN         NUMBER
                 ,p_init_msg_list     IN         VARCHAR2 := 'F'
                 ,p_set_process_id    IN         NUMBER
                 ,x_return_status     OUT NOCOPY VARCHAR2
                 ,x_msg_count         OUT NOCOPY NUMBER
                 ,x_msg_data          OUT NOCOPY VARCHAR2) IS
BEGIN

  IF (INV_ITEM_UTIL.Object_Exists
         (p_object_type => 'PACKAGE',
          p_object_name  => 'ENI_ITEMS_STAR_PKG') = 'Y') THEN
      -- the package exists
     EXECUTE IMMEDIATE
      ' BEGIN                                              '||
      '    ENI_ITEMS_STAR_PKG.Sync_Star_Items_From_IOI     '||
      '    (                                               '||
      '      p_api_version         =>  :p_api_version      '||
      '   ,  p_init_msg_list       =>  :p_init_msg_list    '||
      '   ,  p_set_process_id      =>  :p_set_process_id   '||
      '   ,  x_return_status       =>  :x_return_status    '||
      '   ,  x_msg_count           =>  :x_msg_count        '||
      '   ,  x_msg_data            =>  :x_msg_data         '||
      '   );                                               '||
      ' END;'
     USING IN  p_api_version,
           IN  p_init_msg_list,
           IN  p_set_process_id,
           OUT x_return_status,
           OUT x_msg_count,
           OUT x_msg_data;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
      -- Bug 4569555 RAISE;
END SYNC_STAR_ITEMS_FROM_IOI;

PROCEDURE Sync_Star_ItemCatg_From_COI(
                  p_api_version    IN  NUMBER
                 ,p_init_msg_list  IN  VARCHAR2 := 'F'
                 ,p_set_process_id IN  NUMBER
                 ,x_return_status  OUT NOCOPY  VARCHAR2
                 ,x_msg_count      OUT NOCOPY  NUMBER
                 ,x_msg_data       OUT NOCOPY  VARCHAR2) IS
BEGIN

  IF (INV_ITEM_UTIL.Object_Exists
         (p_object_type => 'PACKAGE',
          p_object_name  => 'ENI_ITEMS_STAR_PKG') = 'Y') THEN
      -- the package exists
     EXECUTE IMMEDIATE
      ' BEGIN                                              '||
      '    ENI_ITEMS_STAR_PKG.Sync_Star_ItemCatg_From_COI  '||
      '    (                                               '||
      '      p_api_version         =>  :p_api_version      '||
      '   ,  p_init_msg_list       =>  :p_init_msg_list    '||
      '   ,  p_set_process_id      =>  :p_set_process_id   '||
      '   ,  x_return_status       =>  :x_return_status    '||
      '   ,  x_msg_count           =>  :x_msg_count        '||
      '   ,  x_msg_data            =>  :x_msg_data         '||
      '   );                                               '||
      ' END;'
     USING IN  p_api_version,
           IN  p_init_msg_list,
           IN  p_set_process_id,
           OUT x_return_status,
           OUT x_msg_count,
           OUT x_msg_data;

   END IF;

EXCEPTION
   WHEN OTHERS THEN
      x_return_status := 'U';
      -- Bug 4569555 RAISE;
END Sync_Star_ItemCatg_From_COI;


End INV_ENI_ITEMS_STAR_PKG;

/
