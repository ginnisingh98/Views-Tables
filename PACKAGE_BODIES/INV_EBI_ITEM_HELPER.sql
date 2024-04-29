--------------------------------------------------------
--  DDL for Package Body INV_EBI_ITEM_HELPER
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EBI_ITEM_HELPER" AS
/* $Header: INVEIHITB.pls 120.35.12010000.23 2009/09/16 06:51:59 prcheru ship $ */
/************************************************************************************
--      API name        : populate_err_msg
--      Type            : Public
--      Function        :
--      This API is used to retrieve the err message.
--
************************************************************************************/
PROCEDURE populate_err_msg(p_orgid               IN            NUMBER
                          ,p_invid               IN            NUMBER
                          ,p_org_code            IN            VARCHAR2
                          ,p_item_name           IN            VARCHAR2
                          ,p_part_err_msg        IN            VARCHAR2
                          ,x_err_msg             IN OUT NOCOPY VARCHAR2
                           )
IS
 l_ovrflw_msg              VARCHAR2(1):='N';
 l_part_item_msg           VARCHAR2(32000);
 l_part_org_msg            VARCHAR2(32000);
 l_part_msgtxt             VARCHAR2(32000);
 BEGIN
  IF  (p_item_name IS NOT NULL)  THEN
    l_part_item_msg :=  ' Item Name: '|| p_item_name ;
  ELSIF (p_item_name IS NULL AND p_invid IS NOT NULL) THEN
    l_part_item_msg :=  ' Item Id: '|| p_invid ;
  END IF;
  IF (p_org_code IS NOT NULL) THEN
    l_part_org_msg   := ' Org Code: ' || p_org_code ;
  ELSIF (p_org_code IS NULL AND p_orgid IS NOT NULL) THEN
    l_part_org_msg   := ' Org Id: ' || p_orgId ;
  END IF;
  l_part_msgtxt :=  l_part_org_msg || l_part_item_msg || ' Err Msg: ' || p_part_err_msg ;
  IF (x_err_msg IS NULL) THEN
    x_err_msg := l_part_msgtxt;
  ELSE
    IF (LENGTH(x_err_msg ||l_part_msgtxt) < 31000) THEN
      x_err_msg := x_err_msg ||' , ' || l_part_msgtxt;
    ELSE
      l_ovrflw_msg := 'Y';
    END IF;
  END IF;
  IF (l_ovrflw_msg = 'Y') AND SUBSTR(x_err_msg,length(x_err_msg)-2) <> '...' THEN
    x_err_msg := x_err_msg || '...';
  END IF;
 EXCEPTION
   WHEN OTHERS THEN
     NULL;
END populate_err_msg;
/************************************************************************************
  --      API name        : id_col_value
  --      Type            : Public
  --      Function        :
  ************************************************************************************/
FUNCTION id_col_value(
    p_col_name                   IN     VARCHAR2
   ,p_pk_col_name_val_pairs      IN      INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl
) RETURN VARCHAR2 IS
l_pkval varchar2(150);
BEGIN
  IF ( (p_pk_col_name_val_pairs IS NOT NULL AND p_pk_col_name_val_pairs.COUNT >0)
    AND p_col_name IS NOT NULL) THEN
    FOR i IN 1..p_pk_col_name_val_pairs.COUNT
    LOOP
      IF LOWER(p_col_name) = LOWER(p_pk_col_name_val_pairs(i).name)
      THEN
        l_pkval := p_pk_col_name_val_pairs(i).value;
        EXIT;
      END IF;
    END LOOP;
  END IF;
  RETURN l_pkval;
EXCEPTION WHEN OTHERS THEN
  RETURN NULL;
END id_col_value;
/************************************************************************************
  --      API name        : value_to_id
  --      Type            : Public
  --      Function        :
  ************************************************************************************/
FUNCTION value_to_id(
     p_pk_col_name_val_pairs  IN   INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl
    ,p_entity_name            IN   VARCHAR2
  ) RETURN NUMBER IS
  l_table_name            VARCHAR2(30);
  l_col_name              VARCHAR2(30);
  l_sql                   VARCHAR2(32000);
  l_id                    NUMBER;
  l_pk1                   VARCHAR2(150);
  l_pk2                   VARCHAR2(150);
BEGIN
  IF ( p_entity_name is NOT NULL )
  THEN
    CASE p_entity_name
      WHEN G_TEMPLATE THEN
        l_pk1 := ID_COL_VALUE('template_name',p_pk_col_name_val_pairs);
        SELECT template_id INTO l_id  FROM mtl_item_templates
        WHERE template_name =l_pk1;
      WHEN G_INVENTORY_ITEM THEN
        l_pk1 := ID_COL_VALUE('concatenated_segments',p_pk_col_name_val_pairs);
        l_pk2 := ID_COL_VALUE('organization_id',p_pk_col_name_val_pairs);
        SELECT inventory_item_id INTO l_id  FROM mtl_system_items_kfv
        WHERE concatenated_segments = l_pk1
        AND organization_id =  l_pk2;
      WHEN G_ORGANIZATION THEN
        l_pk1 := ID_COL_VALUE('organization_code',p_pk_col_name_val_pairs);
        SELECT organization_id INTO l_id  FROM mtl_parameters
        WHERE organization_code = l_pk1;
      WHEN G_ITEM_CATALOG_GROUP THEN
        l_pk1 := ID_COL_VALUE('concatenated_segments',p_pk_col_name_val_pairs);
        SELECT item_catalog_group_id INTO l_id  FROM mtl_item_catalog_groups_kfv
        WHERE concatenated_segments = l_pk1;
      WHEN G_LIFECYCLE THEN
        l_pk1 :=  ID_COL_VALUE('name',p_pk_col_name_val_pairs);
        SELECT proj_element_id INTO l_id  FROM pa_ego_lifecycles_v
        WHERE name = l_pk1;
      WHEN G_CURRENT_PHASE THEN
        l_pk1 :=  ID_COL_VALUE('name',p_pk_col_name_val_pairs);
        l_pk2 := ID_COL_VALUE('parent_structure_id',p_pk_col_name_val_pairs);
        SELECT proj_element_id INTO l_id  from pa_ego_phases_v
        WHERE name = l_pk1
        AND parent_structure_id = l_pk2;
      WHEN G_REVISION THEN
        l_pk1 := ID_COL_VALUE('organization_id',p_pk_col_name_val_pairs);
        l_pk2 := ID_COL_VALUE('inventory_item_id',p_pk_col_name_val_pairs);
        SELECT revision_id INTO l_id  from mtl_item_rev_highdate_v MIRVH
        WHERE organization_id = l_pk1
        AND  inventory_item_id = l_pk2
        AND MIRVH.EFFECTIVITY_DATE < SYSDATE
        AND decode(MIRVH.HIGH_DATE,SYSDATE,SYSDATE+1) > SYSDATE;
      WHEN G_HAZARD_CLASS THEN
        l_pk1 := ID_COL_VALUE('hazard_class',p_pk_col_name_val_pairs);
        SELECT hazard_class_id INTO l_id  from po_hazard_classes_vl
        WHERE hazard_class = l_pk1;
      WHEN G_ASSET_CATEGORY THEN
        l_pk1 := ID_COL_VALUE('concatenated_segments',p_pk_col_name_val_pairs);
        SELECT category_id INTO l_id  FROM fa_categories_b_kfv
        WHERE concatenated_segments = l_pk1;
      WHEN G_MANUFACTURER THEN
        l_pk1 := ID_COL_VALUE('manufacturer_name',p_pk_col_name_val_pairs);
        SELECT manufacturer_id INTO l_id  FROM mtl_manufacturers
        WHERE manufacturer_name = l_pk1;
      WHEN G_CATEGORY_SET THEN
         l_pk1 := ID_COL_VALUE('category_set_name',p_pk_col_name_val_pairs);
        SELECT category_set_id INTO l_id  FROM mtl_category_sets_vl
        WHERE category_set_name = l_pk1;
      WHEN G_CATEGORY THEN
        l_pk1 := ID_COL_VALUE('concatenated_segments',p_pk_col_name_val_pairs);
        SELECT category_id INTO l_id FROM mtl_categories_kfv
        WHERE concatenated_segments = l_pk1;
    END CASE;
  END IF;
    RETURN l_id;
EXCEPTION
  WHEN OTHERS THEN
    RETURN NULL;
END value_to_id;
 /************************************************************************************
    --      API name        : id_to_value
    --      Type            : Public
    --      Function        : returns the code equivalent of a given id
   ************************************************************************************/
  FUNCTION id_to_value(
      p_pk_col_name_val_pairs  IN   INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl
     ,p_entity_name            IN   VARCHAR2
   ) RETURN VARCHAR2 IS
   l_table_name            VARCHAR2(30);
   l_col_name              VARCHAR2(30);
   l_sql                   VARCHAR2(32000);
   l_code                  VARCHAR2(100);
   l_pk1                   VARCHAR2(150);
   l_pk2                   VARCHAR2(150);
  BEGIN
    IF ( p_entity_name is NOT NULL )
    THEN
    CASE p_entity_name
      WHEN G_TEMPLATE THEN
        l_pk1 := ID_COL_VALUE('template_id',p_pk_col_name_val_pairs);
        SELECT template_name  INTO l_code
        FROM mtl_item_templates_vl
        WHERE  template_id = l_pk1;
      WHEN G_ORGANIZATION THEN
        l_pk1 := ID_COL_VALUE('organization_id',p_pk_col_name_val_pairs);
        SELECT organization_code INTO l_code
        FROM mtl_parameters
        WHERE organization_id = l_pk1;
      WHEN G_ITEM_CATALOG_GROUP THEN
        l_pk1 := ID_COL_VALUE('item_catalog_group_id',p_pk_col_name_val_pairs);
        SELECT concatenated_segments  INTO l_code
        FROM mtl_item_catalog_groups_kfv
        WHERE item_catalog_group_id = l_pk1;
      WHEN G_LIFECYCLE THEN
       l_pk1 := ID_COL_VALUE('proj_element_id',p_pk_col_name_val_pairs);
        SELECT name INTO l_code
        FROM pa_ego_lifecycles_v
        WHERE proj_element_id = l_pk1;
      WHEN G_CURRENT_PHASE THEN
         l_pk1 := ID_COL_VALUE('proj_element_id',p_pk_col_name_val_pairs);
        SELECT phase_code  INTO l_code
        FROM pa_ego_phases_v
        WHERE proj_element_id = l_pk1;
      WHEN G_REVISION THEN
         l_pk1 := ID_COL_VALUE('revision_id',p_pk_col_name_val_pairs);
        SELECT revision_label INTO l_code
        FROM mtl_item_revisions_vl
        WHERE  revision_id = l_pk1;
      WHEN G_HAZARD_CLASS THEN
        l_pk1 := ID_COL_VALUE('hazard_class_id',p_pk_col_name_val_pairs);
        SELECT hazard_class  INTO l_code
        FROM po_hazard_classes_vl
        WHERE hazard_class_id = l_pk1;
      WHEN G_ASSET_CATEGORY THEN
         l_pk1 := ID_COL_VALUE('category_id',p_pk_col_name_val_pairs);
        SELECT concatenated_segments  INTO l_code
        FROM fa_categories_b_kfv
        WHERE category_id = l_pk1 ;
      WHEN G_MANUFACTURER THEN
        l_pk1 := ID_COL_VALUE('manufacturer_id',p_pk_col_name_val_pairs);
        SELECT manufacturer_name INTO l_code
        FROM mtl_manufacturers
        WHERE manufacturer_id = l_pk1;
      WHEN G_CATEGORY_SET THEN
        l_pk1 := ID_COL_VALUE('cat_set_id',p_pk_col_name_val_pairs);
        SELECT category_set_name INTO l_code
        FROM mtl_category_sets_vl
        WHERE CATEGORY_SET_ID  = l_pk1;
      WHEN G_CATEGORY THEN
        l_pk1 := ID_COL_VALUE('cat_id',p_pk_col_name_val_pairs);
        SELECT concatenated_segments INTO l_code
        FROM mtl_categories_kfv
        WHERE CATEGORY_ID =l_pk1;
      WHEN G_INVENTORY_ITEM THEN
        l_pk1 := ID_COL_VALUE('organization_id',p_pk_col_name_val_pairs);
        l_pk2 := ID_COL_VALUE('inventory_item_id',p_pk_col_name_val_pairs);
        SELECT concatenated_segments INTO l_code
        FROM mtl_system_items_b_kfv
        WHERE organization_id = l_pk1
        AND inventory_item_id = l_pk2;
    END CASE;
    END IF;
    RETURN l_code;
  EXCEPTION
       WHEN OTHERS THEN
         RETURN NULL;
 END id_to_value;

 /************************************************************************************
  --      API name        : populate_item_ids
  --      Type            : Public
  --      Function        :
 ***********************************************************************************/

  PROCEDURE populate_item_ids(
    p_item  IN  inv_ebi_item_obj
   ,x_out   OUT NOCOPY inv_ebi_item_output_obj
   ,x_item  OUT NOCOPY inv_ebi_item_obj
  ) IS
    l_pk_col_name_val_pairs   INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
    l_output_status           inv_ebi_output_status;
  BEGIN
    x_item  := p_item;
    l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
    x_out           := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);
    l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
    IF ( (p_item.main_obj_type.organization_id IS NULL OR p_item.main_obj_type.organization_id = fnd_api.g_miss_num)
       AND p_item.main_obj_type.organization_code IS NOT NULL ) THEN
      l_pk_col_name_val_pairs.EXTEND(1);
      l_pk_col_name_val_pairs(1).name  := 'organization_code';
      l_pk_col_name_val_pairs(1).value := p_Item.main_obj_type.organization_code;
      x_item.main_obj_type.organization_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                                 p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                ,p_entity_name            => INV_EBI_ITEM_HELPER.G_ORGANIZATION
                                               );
      l_pk_col_name_val_pairs.TRIM(1);
        IF (x_item.main_obj_type.organization_id IS NULL) THEN
          FND_MESSAGE.set_name('INV','INV_EBI_ORG_CODE_INVALID');
          FND_MESSAGE.set_token('COL_VALUE', p_Item.main_obj_type.organization_code);
          FND_MSG_PUB.add;
          RAISE FND_API.g_exc_error;
        END IF;
    END IF;
    IF ( (p_item.main_obj_type.inventory_item_id IS NULL OR  p_item.main_obj_type.inventory_item_id= fnd_api.g_miss_num)
       AND p_item.main_obj_type.item_number IS NOT NULL ) THEN
      l_pk_col_name_val_pairs.EXTEND(2);
      l_pk_col_name_val_pairs(1).name  := 'concatenated_segments';
      l_pk_col_name_val_pairs(1).value := p_item.main_obj_type.item_number;
      l_pk_col_name_val_pairs(2).name  := 'organization_id';
      l_pk_col_name_val_pairs(2).value := x_item.main_obj_type.organization_id;
      x_item.main_obj_type.inventory_item_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                                   p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                  ,p_entity_name            => INV_EBI_ITEM_HELPER.G_INVENTORY_ITEM
                                                 );
      l_pk_col_name_val_pairs.TRIM(2);
    END IF;
    IF ( (p_item.main_obj_type.template_id IS NULL OR p_item.main_obj_type.template_id =fnd_api.g_miss_num)
       AND p_item.main_obj_type.template_name IS NOT NULL AND p_item.main_obj_type.template_name <> fnd_api.g_miss_char) THEN
      l_pk_col_name_val_pairs.EXTEND(1);
      l_pk_col_name_val_pairs(1).name  := 'template_name';
      l_pk_col_name_val_pairs(1).value := p_item.main_obj_type.template_name;
      x_item.main_obj_type.template_id := INV_EBI_ITEM_HELPER.value_to_id(
                                             p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                            ,p_entity_name            => INV_EBI_ITEM_HELPER.G_TEMPLATE
                                          );
      l_pk_col_name_val_pairs.TRIM(1);

      IF (x_item.main_obj_type.template_id IS NULL) THEN
        FND_MESSAGE.set_name('INV','INV_TEMPLATE_ERROR');
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
      END IF;
    END IF;
    IF (p_item.org_id_obj_type IS NOT NULL AND p_item.org_id_obj_type.COUNT > 0 ) THEN
      FOR i IN 1..p_item.org_id_obj_type.COUNT LOOP
        IF (p_item.org_id_obj_type(i).org_id IS  NULL AND p_item.org_id_obj_type(i).org_code IS NOT NULL) THEN
          l_pk_col_name_val_pairs.EXTEND(1);
          l_pk_col_name_val_pairs(1).name  := 'organization_code';
          l_pk_col_name_val_pairs(1).value := p_item.org_id_obj_type(i).org_code;
          x_item.org_id_obj_type(i).org_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                                 p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                ,p_entity_name            => INV_EBI_ITEM_HELPER.G_ORGANIZATION
                                               );
          l_pk_col_name_val_pairs.TRIM(1);
          IF (x_item.org_id_obj_type(i).org_id IS NULL) THEN
            FND_MESSAGE.set_name('INV','INV_EBI_ORG_CODE_INVALID');
            FND_MESSAGE.set_token('COL_VALUE', p_item.org_id_obj_type(i).org_code);
            FND_MSG_PUB.add;
            RAISE FND_API.g_exc_error;
          END IF;
        END IF;
      END LOOP;
    END IF;
    IF ( (p_item.main_obj_type.item_catalog_group_id IS NULL OR p_item.main_obj_type.item_catalog_group_id=fnd_api.g_miss_num)
       AND p_item.main_obj_type.item_catalog_group_code IS NOT NULL
       AND p_item.main_obj_type.item_catalog_group_code <> fnd_api.g_miss_char) THEN
      l_pk_col_name_val_pairs.EXTEND(1);
      l_pk_col_name_val_pairs(1).name  := 'concatenated_segments';
      l_pk_col_name_val_pairs(1).value := p_item.main_obj_type.item_catalog_group_code;
      x_item.main_obj_type.item_catalog_group_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                                       p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                      ,p_entity_name            => INV_EBI_ITEM_HELPER.G_ITEM_CATALOG_GROUP
                                                     );
      l_pk_col_name_val_pairs.TRIM(1);
        IF (x_item.main_obj_type.item_catalog_group_id IS NULL ) THEN
               FND_MESSAGE.set_name('INV','INV_EBI_ITEM_INVALID');
               FND_MESSAGE.set_token('COL_VALUE',p_item.main_obj_type.item_catalog_group_code);
               FND_MSG_PUB.add;
               RAISE FND_API.g_exc_error;
        END IF;
    END IF;
    IF ( (p_item.main_obj_type.lifecycle_id IS NULL OR p_item.main_obj_type.lifecycle_id =fnd_api.g_miss_num)
       AND p_item.main_obj_type.lifecycle_name IS NOT NULL) THEN
      l_pk_col_name_val_pairs.EXTEND(1);
      l_pk_col_name_val_pairs(1).name  := 'name';
      l_pk_col_name_val_pairs(1).value := p_item.main_obj_type.lifecycle_name;
      x_item.main_obj_type.lifecycle_id  := INV_EBI_ITEM_HELPER.value_to_id (
                                              p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                             ,p_entity_name            => INV_EBI_ITEM_HELPER.G_LIFECYCLE
                                            );
      l_pk_col_name_val_pairs.TRIM(1);
    END IF;
    IF ( (p_item.main_obj_type.current_phase_id IS NULL  OR p_item.main_obj_type.current_phase_id=fnd_api.g_miss_num)
      AND (p_item.main_obj_type.current_phase_name IS NOT NULL AND x_item.main_obj_type.lifecycle_id is NOT NULL)) THEN
      l_pk_col_name_val_pairs.EXTEND(2);
      l_pk_col_name_val_pairs(1).name  := 'name';
      l_pk_col_name_val_pairs(1).value := p_item.main_obj_type.current_phase_name;
      l_pk_col_name_val_pairs(2).name  := 'parent_structure_id';
      l_pk_col_name_val_pairs(2).value := x_item.main_obj_type.lifecycle_id ;
      x_item.main_obj_type.current_phase_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                                  p_pk_col_name_val_pairs => l_pk_col_name_val_pairs
                                                 ,p_entity_name           => INV_EBI_ITEM_HELPER.G_CURRENT_PHASE
                                                );
      l_pk_col_name_val_pairs.TRIM(2);
    END IF;
    IF ( (p_item.main_obj_type.revision_id IS NULL OR p_item.main_obj_type.revision_id= fnd_api.g_miss_num)
     AND (x_item.main_obj_type.organization_id IS NOT NULL AND x_item.main_obj_type.inventory_item_id IS NOT NULL)
       ) THEN
      l_pk_col_name_val_pairs.EXTEND(2);
      l_pk_col_name_val_pairs(1).name  := 'organization_id';
      l_pk_col_name_val_pairs(1).value := p_item.main_obj_type.organization_id;
      l_pk_col_name_val_pairs(2).name  := 'inventory_item_id';
      l_pk_col_name_val_pairs(2).value := x_item.main_obj_type.inventory_item_id;
      x_item.main_obj_type.revision_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                             p_pk_col_name_val_pairs => l_pk_col_name_val_pairs
                                            ,p_entity_name           => INV_EBI_ITEM_HELPER.G_REVISION
                                           );
      l_pk_col_name_val_pairs.TRIM(2);
   END IF;
    IF ( (p_item.purchasing_obj_type.hazard_class_id IS NULL  OR p_item.purchasing_obj_type.hazard_class_id = fnd_api.g_miss_num)
      AND p_item.purchasing_obj_type.hazard_class_code IS NOT NULL) THEN
      l_pk_col_name_val_pairs.EXTEND(1);
      l_pk_col_name_val_pairs(1).name  := 'hazard_class';
      l_pk_col_name_val_pairs(1).value := p_item.purchasing_obj_type.hazard_class_code ;
      x_item.purchasing_obj_type.hazard_class_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                                 p_pk_col_name_val_pairs => l_pk_col_name_val_pairs
                                                ,p_entity_name           => INV_EBI_ITEM_HELPER.G_HAZARD_CLASS
                                               );
      l_pk_col_name_val_pairs.TRIM(1);
    END IF;
    IF ( (p_item.purchasing_obj_type.asset_category_id IS NULL OR p_item.purchasing_obj_type.asset_category_id =fnd_api.g_miss_num)
       AND p_item.purchasing_obj_type.asset_category_code IS NOT NULL ) THEN
      l_pk_col_name_val_pairs.EXTEND(1);
      l_pk_col_name_val_pairs(1).name  := 'concatenated_segments';
      l_pk_col_name_val_pairs(1).value := p_item.purchasing_obj_type.asset_category_code;
      x_item.purchasing_obj_type.asset_category_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                                         p_pk_col_name_val_pairs => l_pk_col_name_val_pairs
                                                        ,p_entity_name           => INV_EBI_ITEM_HELPER.G_ASSET_CATEGORY
                                                     );
      l_pk_col_name_val_pairs.TRIM(1);
    END IF;
    IF ( (p_item.bom_obj_type.base_item_id IS NULL OR p_item.bom_obj_type.base_item_id= fnd_api.g_miss_num)
      AND p_item.bom_obj_type.base_item_number IS NOT NULL )THEN
      l_pk_col_name_val_pairs.EXTEND(2);
      l_pk_col_name_val_pairs(1).name  := 'concatenated_segments';
      l_pk_col_name_val_pairs(1).value := p_item.bom_obj_type.base_item_number;
      l_pk_col_name_val_pairs(2).name  := 'organization_id';
      l_pk_col_name_val_pairs(2).value := p_item.main_obj_type.organization_id;
      x_item.bom_obj_type.base_item_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                              p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                             ,p_entity_name            => INV_EBI_ITEM_HELPER.G_INVENTORY_ITEM
                                           );
      l_pk_col_name_val_pairs.TRIM(2);
    END IF;
    IF ( p_item.part_num_obj_tbl_type IS NOT NULL AND p_item.part_num_obj_tbl_type.COUNT > 0 ) THEN
      FOR i in 1..p_item.part_num_obj_tbl_type.COUNT LOOP
        IF ((p_item.part_num_obj_tbl_type(i).manufacturer_id IS NULL OR p_item.part_num_obj_tbl_type(i).manufacturer_id = fnd_api.g_miss_num)
        AND (p_item.part_num_obj_tbl_type(i).manufacturer_name IS NOT NULL OR p_item.part_num_obj_tbl_type(i).manufacturer_name <> fnd_api.g_miss_char))THEN
          l_pk_col_name_val_pairs.EXTEND(1);
          l_pk_col_name_val_pairs(1).name  := 'manufacturer_name';
          l_pk_col_name_val_pairs(1).value := p_item.part_num_obj_tbl_type(i).manufacturer_name;
          x_item.part_num_obj_tbl_type(i).manufacturer_id  := INV_EBI_ITEM_HELPER.value_to_id (
                                                                p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                               ,p_entity_name            => INV_EBI_ITEM_HELPER.G_MANUFACTURER
                                                              );
          l_pk_col_name_val_pairs.TRIM(1);
        END IF;
      END LOOP;
    END IF;
    IF ( p_item.category_id_obj_tbl_type IS NOT NULL AND p_item.category_id_obj_tbl_type.COUNT > 0) THEN
      FOR i IN 1..p_item.category_id_obj_tbl_type.COUNT LOOP
        IF ((p_item.category_id_obj_tbl_type(i).cat_set_id IS NULL OR p_item.category_id_obj_tbl_type(i).cat_set_id = fnd_api.g_miss_num)
        AND (p_item.category_id_obj_tbl_type(i).cat_set_name IS NOT NULL OR p_item.category_id_obj_tbl_type(i).cat_set_name <> fnd_api.g_miss_char) ) THEN
          l_pk_col_name_val_pairs.EXTEND(1);
          l_pk_col_name_val_pairs(1).name  := 'category_set_name';
          l_pk_col_name_val_pairs(1).value := p_item.category_id_obj_tbl_type(i).cat_set_name;
          x_item.category_id_obj_tbl_type(i).cat_set_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                                              p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                             ,p_entity_name            => INV_EBI_ITEM_HELPER.G_CATEGORY_SET
                                                             );
          l_pk_col_name_val_pairs.TRIM(1);
        END IF;
        IF ( (p_item.category_id_obj_tbl_type(i).cat_id IS NULL OR p_item.category_id_obj_tbl_type(i).cat_id =fnd_api.g_miss_num)
        AND ( p_item.category_id_obj_tbl_type(i).cat_name IS NOT NULL OR p_item.category_id_obj_tbl_type(i).cat_name <> fnd_api.g_miss_char)) THEN
          l_pk_col_name_val_pairs.EXTEND(1);
          l_pk_col_name_val_pairs(1).name  := 'concatenated_segments';
          l_pk_col_name_val_pairs(1).value := p_item.category_id_obj_tbl_type(i).cat_name;
          x_item.category_id_obj_tbl_type(i).cat_id  := INV_EBI_ITEM_HELPER.value_to_id (
                                                          p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                         ,p_entity_name            => INV_EBI_ITEM_HELPER.G_CATEGORY
                                                        );
          l_pk_col_name_val_pairs.TRIM(1);
        END IF;
      END LOOP;
    END IF;
    IF ( (p_item.main_obj_type.rev_lifecycle_id IS NULL OR p_item.main_obj_type.rev_lifecycle_id= fnd_api.g_miss_num)
       AND p_item.main_obj_type.rev_lifecycle_name IS NOT NULL) THEN
      l_pk_col_name_val_pairs.EXTEND(1);
      l_pk_col_name_val_pairs(1).name  := 'name';
      l_pk_col_name_val_pairs(1).value := p_item.main_obj_type.rev_lifecycle_name;
      x_item.main_obj_type.rev_lifecycle_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                                 p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                ,p_entity_name            => INV_EBI_ITEM_HELPER.G_LIFECYCLE
                                               );
       l_pk_col_name_val_pairs.TRIM(1);
   END IF;
   IF ( (p_item.main_obj_type.rev_current_phase_id IS NULL OR p_item.main_obj_type.rev_current_phase_id= fnd_api.g_miss_num)
     AND (p_item.main_obj_type.rev_current_phase_name IS NOT NULL  AND  x_item.main_obj_type.rev_lifecycle_id IS NOT NULL )
       )  THEN
      l_pk_col_name_val_pairs.EXTEND(2);
      l_pk_col_name_val_pairs(1).name  := 'name';
      l_pk_col_name_val_pairs(1).value := p_item.main_obj_type.rev_current_phase_name;
       l_pk_col_name_val_pairs(2).name  := 'parent_structure_id';
      l_pk_col_name_val_pairs(2).value :=  x_item.main_obj_type.rev_lifecycle_id;
      x_item.main_obj_type.rev_current_phase_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                                     p_pk_col_name_val_pairs   => l_pk_col_name_val_pairs
                                                    ,p_entity_name             => INV_EBI_ITEM_HELPER.G_CURRENT_PHASE
                                                   );
      l_pk_col_name_val_pairs.TRIM(2);
   END IF;
 EXCEPTION
 WHEN FND_API.g_exc_error THEN
     x_out.output_status.return_status :=  FND_API.g_ret_sts_error;
     IF(x_out.output_status.msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count   => x_out.output_status.msg_count
        ,p_data    => x_out.output_status.msg_data
       );
     END IF;
 WHEN OTHERS THEN
   x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
   IF (x_out.output_status.msg_data IS NOT NULL) THEN
     x_out.output_status.msg_data  :=  x_out.output_status.msg_data||' -> INV_EBI_ITEM_PUB.populate_item_ids ';
   ELSE
     x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_ITEM_PUB.populate_item_ids ';
   END IF;
 END populate_item_ids;
 /************************************************************************************
 --      API name        : get_default_master_org
 --      Type            : Public
 --      Function        :
 ************************************************************************************/
 FUNCTION get_default_master_org(
   p_config  IN inv_ebi_name_value_tbl
  ) RETURN NUMBER IS
   l_master_org             NUMBER;
   l_master_org_count       NUMBER;
   l_default_master_org_id  NUMBER;
   l_master_org_code        VARCHAR2(3);
   CURSOR c_master_org IS
     SELECT master_organization_id
     FROM mtl_parameters
     WHERE organization_id = master_organization_id;
 BEGIN
   OPEN c_master_org;
   LOOP
     FETCH c_master_org INTO l_master_org;
     IF (c_master_org%ROWCOUNT > 1) THEN
       l_master_org_code := INV_EBI_UTIL.get_config_param_value(
                                  p_config_tbl         =>  p_config
                                 ,p_config_param_name  => 'Default_Master_Organization_For_Item'
                                );
       l_master_org  :=  get_organization_id(
                           p_organization_code  =>  l_master_org_code
                         );
       EXIT;
     END IF;
   END LOOP;
   CLOSE c_master_org;
   RETURN l_master_org;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
END get_default_master_org;
/************************************************************************************
 --     API name        : initialize_item
 --     Type            : Private
 --     Function        :
 --     This API is used to
 --
************************************************************************************/
PROCEDURE initialize_item(
 x_item                 IN OUT NOCOPY inv_ebi_item_obj
)
IS
BEGIN
IF (x_item.physical_obj_type IS NULL) THEN
  x_item.physical_obj_type := inv_ebi_item_physical_obj(
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num
  );
END IF;
IF (x_item.inventory_obj_type IS NULL) THEN
  x_item.inventory_obj_type := inv_ebi_item_inventory_obj(
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num
  );
END IF;
IF (x_item.purchasing_obj_type IS NULL) THEN
  x_item.purchasing_obj_type := inv_ebi_item_purchasing_obj(
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num
  );
END IF;
IF (x_item.receiving_obj_type IS NULL) THEN
  x_item.receiving_obj_type := inv_ebi_item_receiving_obj(
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char
  );
END IF;
IF (x_item.gplanning_obj_type IS NULL) THEN
  x_item.gplanning_obj_type := inv_ebi_item_gplanning_obj(
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num
  );
END IF;
IF (x_item.mrp_obj_type IS NULL) THEN
  x_item.mrp_obj_type := inv_ebi_item_mrp_obj(
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num
  );
END IF;
IF (x_item.order_obj_type IS NULL) THEN
  x_item.order_obj_type := inv_ebi_item_order_obj(
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char
  );
END IF;
IF (x_item.service_obj_type IS NULL) THEN
  x_item.service_obj_type := inv_ebi_item_service_obj(
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char
  );
END IF;
IF (x_item.bom_obj_type IS NULL) THEN
  x_item.bom_obj_type := inv_ebi_item_bom_obj(
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char
  );
END IF;
IF (x_item.costing_obj_type IS NULL) THEN
  x_item.costing_obj_type := inv_ebi_item_costing_obj(
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num
  );
END IF;
IF (x_item.lead_time_obj_type IS NULL) THEN
  x_item.lead_time_obj_type := inv_ebi_item_lead_time_obj(
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num
  );
END IF;
IF (x_item.wip_obj_type IS NULL) THEN
  x_item.wip_obj_type := inv_ebi_item_wip_obj(
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num
  );
END IF;
IF (x_item.invoice_obj_type IS NULL) THEN
  x_item.invoice_obj_type := inv_ebi_item_invoice_obj(
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num
  );
END IF;
IF (x_item.web_option_obj_type IS NULL) THEN
  x_item.web_option_obj_type := inv_ebi_item_web_option_obj(
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num
  );
END IF;
IF (x_item.asset_obj_type IS NULL) THEN
  x_item.asset_obj_type := inv_ebi_item_asset_obj(
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char
  );
END IF;
IF (x_item.deprecated_obj_type IS NULL) THEN
  x_item.deprecated_obj_type := inv_ebi_item_deprecated_obj(
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_date,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_date,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_num,
   fnd_api.g_miss_num,
   fnd_api.g_miss_char,
   fnd_api.g_miss_char
  );
END IF;
IF (x_item.process_manufacturing_obj IS NULL) THEN
  x_item.process_manufacturing_obj  :=  inv_ebi_item_processmfg_obj(
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_num,
    fnd_api.g_miss_char,
    fnd_api.g_miss_char
  );
 END IF;
END initialize_item;
 /************************************************************************************
 --      API name        : is_new_item_request_reqd
 --      Type            : Public
 --      Function        :
 ************************************************************************************/
 FUNCTION is_new_item_request_reqd(
   p_item_catalog_group_id  IN   NUMBER
 ) RETURN VARCHAR IS
   l_is_new_item_request_reqd   VARCHAR2(3);
 BEGIN
   IF (p_item_catalog_group_id IS NOT NULL AND p_item_catalog_group_id <> fnd_api.g_miss_num) THEN
     SELECT new_item_request_reqd INTO l_is_new_item_request_reqd
     FROM mtl_item_catalog_groups_vl
     WHERE item_catalog_group_id = p_item_catalog_group_id;
     IF(l_is_new_item_request_reqd = 'Y') THEN
       RETURN FND_API.g_true;
     ELSE
       RETURN FND_API.g_false;
     END IF;
   END IF;
 RETURN FND_API.g_false;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN FND_API.g_false;
 END is_new_item_request_reqd;
 /************************************************************************************
 --      API name        : get_organization_id
 --      Type            : Public
 --      Function        :
 ************************************************************************************/
FUNCTION get_organization_id ( p_organization_code  IN  VARCHAR2 ) RETURN NUMBER
IS
  l_org_id    NUMBER;
BEGIN
  SELECT  organization_id
  INTO    l_org_id
  FROM    mtl_parameters
  WHERE   organization_code = p_organization_code;
  RETURN l_org_id;
EXCEPTION
   WHEN OTHERS THEN
     RETURN NULL;
END Get_Organization_Id;
 /************************************************************************************
 --      API name        : get_inventory_item_id
 --      Type            : Public
 --      Function        :
 ************************************************************************************/
 FUNCTION get_inventory_item_id(
    p_organization_id   IN   NUMBER
   ,p_item_number       IN   VARCHAR2
 ) RETURN NUMBER IS
 l_inventory_item_id  NUMBER;
 BEGIN
   SELECT inventory_item_id INTO l_inventory_item_id
   FROM mtl_system_items_kfv
   WHERE concatenated_segments = p_item_number
   AND organization_id = p_organization_id;
   RETURN l_inventory_item_id;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN FND_API.g_miss_num;
 END get_inventory_item_id;
 /************************************************************************************
  -- API name : get_item_num
  -- Type : Private
  -- Function :
  -- This API is used to
  --
  ************************************************************************************/
FUNCTION get_item_num(
   p_segment1  IN VARCHAR2
  ,p_segment2  IN VARCHAR2
  ,p_segment3  IN VARCHAR2
  ,p_segment4  IN VARCHAR2
  ,p_segment5  IN VARCHAR2
  ,p_segment6  IN VARCHAR2
  ,p_segment7  IN VARCHAR2
  ,p_segment8  IN VARCHAR2
  ,p_segment9  IN VARCHAR2
  ,p_segment10 IN VARCHAR2
  ,p_segment11 IN VARCHAR2
  ,p_segment12 IN VARCHAR2
  ,p_segment13 IN VARCHAR2
  ,p_segment14 IN VARCHAR2
  ,p_segment15 IN VARCHAR2
  ,p_segment16 IN VARCHAR2
  ,p_segment17 IN VARCHAR2
  ,p_segment18 IN VARCHAR2
  ,p_segment19 IN VARCHAR2
  ,p_segment20 IN VARCHAR2
 ) RETURN VARCHAR2 IS
 l_item_number  VARCHAR2(2000);
 BEGIN
   SELECT DECODE(p_segment1,fnd_api.g_miss_char,'',NULL,'',p_segment1) ||
     DECODE(p_segment2,fnd_api.g_miss_char,'',NULL,'',p_segment2) ||
     DECODE(p_segment3,fnd_api.g_miss_char,'',NULL,'',p_segment3) ||
     DECODE(p_segment4,fnd_api.g_miss_char,'',NULL,'',p_segment4) ||
     DECODE(p_segment5,fnd_api.g_miss_char,'',NULL,'',p_segment5) ||
     DECODE(p_segment6,fnd_api.g_miss_char,'',NULL,'',p_segment6) ||
     DECODE(p_segment7,fnd_api.g_miss_char,'',NULL,'',p_segment7) ||
     DECODE(p_segment8,fnd_api.g_miss_char,'',NULL,'',p_segment8) ||
     DECODE(p_segment9,fnd_api.g_miss_char,'',NULL,'',p_segment9) ||
     DECODE(p_segment10,fnd_api.g_miss_char,'',NULL,'',p_segment10) ||
     DECODE(p_segment11,fnd_api.g_miss_char,'',NULL,'',p_segment11) ||
     DECODE(p_segment12,fnd_api.g_miss_char,'',NULL,'',p_segment12) ||
     DECODE(p_segment13,fnd_api.g_miss_char,'',NULL,'',p_segment13) ||
     DECODE(p_segment14,fnd_api.g_miss_char,'',NULL,'',p_segment14) ||
     DECODE(p_segment15,fnd_api.g_miss_char,'',NULL,'',p_segment15) ||
     DECODE(p_segment16,fnd_api.g_miss_char,'',NULL,'',p_segment16) ||
     DECODE(p_segment17,fnd_api.g_miss_char,'',NULL,'',p_segment17) ||
     DECODE(p_segment18,fnd_api.g_miss_char,'',NULL,'',p_segment18) ||
     DECODE(p_segment19,fnd_api.g_miss_char,'',NULL,'',p_segment19) ||
     DECODE(p_segment20,fnd_api.g_miss_char,'',NULL,'',p_segment20)
   INTO l_item_number
   FROM DUAL;
   RETURN l_item_number;
 EXCEPTION
   WHEN OTHERS THEN
      RETURN NULL;
 END get_item_num;
/************************************************************************************
--      API name        : is_item_engg
--      Type            : Public
--      Function        :
--
************************************************************************************/
FUNCTION is_engineering_item(
  p_organization_id    IN  NUMBER
 ,p_item_number        IN  VARCHAR2
) RETURN VARCHAR IS
   l_item_flag VARCHAR2(1);
BEGIN
  SELECT eng_item_flag INTO l_item_flag
  FROM mtl_system_items_kfv
  WHERE concatenated_segments = NVL(p_item_number,FND_API.G_MISS_CHAR)
  AND  organization_id =p_organization_id;
  IF(l_item_flag='Y') THEN
     RETURN FND_API.g_true;
  ELSE
     RETURN FND_API.g_false;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    RETURN FND_API.g_false;
END is_engineering_item;
/************************************************************************************
 --      API name        : is_item_exists
 --      Type            : Public
 --      Function        :
 --
 --Check if the concatenated segment numbers have to be unique or Is the
 --below condition sufficient
 --some information
 ************************************************************************************/
 FUNCTION is_item_exists (
   p_organization_id IN  NUMBER
  ,p_item_number     IN  VARCHAR2
 ) RETURN VARCHAR IS
   l_item_count NUMBER;
 BEGIN
   SELECT COUNT(1) INTO l_item_count
   FROM mtl_system_items_kfv
   WHERE concatenated_segments = p_item_number
   AND  organization_id = p_organization_id;
   IF(l_item_count=0) THEN
        RETURN FND_API.g_false;
   ELSE
        RETURN FND_API.g_true;
   END IF;
 EXCEPTION
   WHEN OTHERS THEN
     RETURN FND_API.g_false;
 END is_item_exists;

 /************************************************************************************
  --      API name        : is_revision_exists
  --      Type            : private
  --      Function        :
  --
  --Check if the revision is already created
  ************************************************************************************/

 FUNCTION is_revision_exists (
    p_organization_id       IN  NUMBER
   ,p_item_number           IN  VARCHAR2
   ,p_revision              IN  VARCHAR2
 ) RETURN VARCHAR IS

   l_count  NUMBER;
  BEGIN

    SELECT COUNT(1) INTO l_count
    FROM
      mtl_item_revisions_b mir ,
      mtl_system_items_kfv   msi
    WHERE
      msi.concatenated_segments = p_item_number  AND
      msi.organization_id = p_organization_id    AND
      msi.inventory_item_id = mir.inventory_item_id AND
      msi.organization_id = mir.organization_id AND
      mir.revision  = p_revision;

    IF(l_count=0) THEN
         RETURN FND_API.g_false;
    ELSE
         RETURN FND_API.g_true;
    END IF;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN FND_API.g_false;
 END is_revision_exists;


 /************************************************************************************
  --      API name        : get_desc_gen_method
  --      Type            : private
  --      Function        : Return description generation method of ICC
************************************************************************************/
FUNCTION get_desc_gen_method(p_item_catalog_group_id NUMBER)
RETURN VARCHAR2
IS
  l_parent_catalog_group_id NUMBER;
  t_parent_catalog_group_id NUMBER;
  l_item_desc_gen_method    VARCHAR2(2);
BEGIN
  SELECT item_desc_gen_method, parent_catalog_group_id
  INTO l_item_desc_gen_method, l_parent_catalog_group_id
  FROM MTL_ITEM_CATALOG_GROUPS_VL
  WHERE item_catalog_group_id = p_item_catalog_group_id;
  IF UPPER(l_item_desc_gen_method)='I' THEN
    WHILE UPPER(l_item_desc_gen_method) = 'I' LOOP
      SELECT item_desc_gen_method,
             parent_catalog_group_id
      INTO   l_item_desc_gen_method,
             t_parent_catalog_group_id
      FROM   mtl_item_catalog_groups_vl
      WHERE  item_catalog_group_id = l_parent_catalog_group_id;
      EXIT WHEN t_parent_catalog_group_id IS NULL;
      l_parent_catalog_group_id := t_parent_catalog_group_id;
    END LOOP;
  END IF;
  RETURN l_item_desc_gen_method;
  EXCEPTION
    WHEN OTHERS THEN
      RETURN NULL;
END;

/************************************************************************************
--    API name        : process_item_pvt
--    Type            : Public
--    Function        :
--    This API is used to
--
************************************************************************************/
 PROCEDURE process_item_pvt(
   p_commit              IN  VARCHAR2 := FND_API.g_false
  ,p_operation           IN  VARCHAR2
  ,p_item                IN  inv_ebi_item_obj
  ,x_out                 OUT NOCOPY inv_ebi_item_output_obj
 )
 IS
   l_transaction_type          VARCHAR2(20);
   l_item_exits                VARCHAR2(3);
   l_item                      inv_ebi_item_obj;
   l_xref_id                   NUMBER;
   l_item_number               VARCHAR2(2000);
   l_description               VARCHAR2(240);
   l_item_desc_gen_method      VARCHAR2(3) := 'U';
   l_is_master_org             VARCHAR2(3) := 'N';
   l_is_new_item_request_reqd  VARCHAR2(3) := 'N';
   l_eng_item_flag             VARCHAR2(3);
   l_output_status             inv_ebi_output_status;
   l_count                     NUMBER := 0;
   l_master_org                NUMBER;
   l_pk_col_name_val_pairs     INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
   l_apply_template_update     VARCHAR2(2000);
   l_validate_revised_itm_rev  VARCHAR2(1);
   l_revised_item_exists       NUMBER := 0;
   l_effectivity_date          DATE;
   l_source_system_id          NUMBER;
   CURSOR c_item_description(
     p_item_number      IN  VARCHAR2
    ,p_organization_id  IN  NUMBER
   ) IS
    SELECT description
    FROM   mtl_system_items_kfv
    WHERE  concatenated_segments = p_item_number
    AND    organization_id  = p_organization_id;
 BEGIN
   SAVEPOINT inv_ebi_pvt_item_save_pnt;
   INV_EBI_UTIL.debug_line('STEP: 10 '||'START INSIDE INV_EBI_ITEM_HELPER.process_item_pvt ');
   l_item := p_item;
   l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out           := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);
   l_item_number   := l_item.main_obj_type.item_number;
   l_pk_col_name_val_pairs  :=    INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
   IF(l_item_number IS NULL OR l_item_number = fnd_api.g_miss_char) THEN
     l_item_number := get_item_num(
         p_segment1  => l_item.main_obj_type.segment1
        ,p_segment2  => l_item.main_obj_type.segment2
        ,p_segment3  => l_item.main_obj_type.segment3
        ,p_segment4  => l_item.main_obj_type.segment4
        ,p_segment5  => l_item.main_obj_type.segment5
        ,p_segment6  => l_item.main_obj_type.segment6
        ,p_segment7  => l_item.main_obj_type.segment7
        ,p_segment8  => l_item.main_obj_type.segment8
        ,p_segment9  => l_item.main_obj_type.segment9
        ,p_segment10 => l_item.main_obj_type.segment10
        ,p_segment11 => l_item.main_obj_type.segment11
        ,p_segment12 => l_item.main_obj_type.segment12
        ,p_segment13 => l_item.main_obj_type.segment13
        ,p_segment14 => l_item.main_obj_type.segment14
        ,p_segment15 => l_item.main_obj_type.segment15
        ,p_segment16 => l_item.main_obj_type.segment16
        ,p_segment17 => l_item.main_obj_type.segment17
        ,p_segment18 => l_item.main_obj_type.segment18
        ,p_segment19 => l_item.main_obj_type.segment19
        ,p_segment20 => l_item.main_obj_type.segment20
     );
   END IF;
   IF l_item_number IS NULL THEN
     FND_MESSAGE.set_name('INV','INV_EBI_ITEM_NUM_NULL');
     FND_MSG_PUB.add;
     RAISE FND_API.g_exc_error;
   END IF;
   IF p_operation = INV_EBI_ITEM_PUB.g_otype_sync THEN
     IF( is_item_exists (
           p_organization_id    =>   l_item.main_obj_type.organization_id
          ,p_item_number        =>   l_item_number
           ) = FND_API.g_true ) THEN
       l_transaction_type := INV_EBI_ITEM_PUB.g_otype_update;
     ELSE
       l_transaction_type               := INV_EBI_ITEM_PUB.g_otype_create;
       l_item.main_obj_type.item_number := l_item_number;
     END IF;
   ELSE
     l_transaction_type               := p_operation;
     l_item.main_obj_type.item_number := l_item_number;
   END IF;
   initialize_item(x_item => l_item);

   l_validate_revised_itm_rev := INV_EBI_UTIL.get_config_param_value(
                                   p_config_tbl         =>  l_item.name_value_tbl
                                  ,p_config_param_name  => 'VALIDATE_REVISED_ITEM_REVISION'
                                );
   IF (l_validate_revised_itm_rev = fnd_api.g_true ) AND (l_item.main_obj_type.revision_code IS NOT NULL)
      AND (l_item.main_obj_type.revision_code <> fnd_api.g_miss_char)
     AND ( is_item_exists (
           p_organization_id    =>   l_item.main_obj_type.organization_id
          ,p_item_number        =>   l_item_number
           ) = FND_API.g_true )
   THEN
     IF( l_item.main_obj_type.inventory_item_id IS NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(2);
        l_pk_col_name_val_pairs(1).name   := 'organization_id';
        l_pk_col_name_val_pairs(1).value  := l_item.main_obj_type.organization_id;
        l_pk_col_name_val_pairs(2).name   := 'concatenated_segments';
        l_pk_col_name_val_pairs(2).value  := l_item.main_obj_type.item_number;
        l_item.main_obj_type.inventory_item_id :=  INV_EBI_ITEM_HELPER.value_to_id (
                                                         p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                        ,p_entity_name=> INV_EBI_ITEM_HELPER.G_INVENTORY_ITEM
                                                 );
     END IF;

        SELECT COUNT(1) into l_revised_item_exists
        FROM mtl_item_revisions_b ir
        WHERE ir.inventory_item_id = l_item.main_obj_type.inventory_item_id
        AND ir.organization_id = l_item.main_obj_type.organization_id
        AND ir.revision = l_item.main_obj_type.revision_code
        AND(ir.effectivity_date IN
                           (SELECT first_value(ir2.effectivity_date) over(ORDER BY ir2.effectivity_date DESC)
                           FROM mtl_item_revisions_b ir2
                           WHERE ir2.organization_id = ir.organization_id
                           AND ir2.inventory_item_id = ir.inventory_item_id
                           AND ir2.effectivity_date <= sysdate
                           AND ir2.implementation_date IS NOT NULL)
        OR ir.effectivity_date > sysdate);
        IF l_revised_item_exists = 0 then
          FND_MESSAGE.set_name('INV','INV_EBI_INVALD_REV_CODE');
          FND_MESSAGE.set_token('ITEM_NUMBER', l_item_number);
          FND_MESSAGE.set_token('REVISION_CODE',l_item.main_obj_type.revision_code);
          FND_MESSAGE.set_token('ORG_CODE',l_item.main_obj_type.organization_code);
          FND_MSG_PUB.add;
          RAISE FND_API.g_exc_error;
        END IF;
   END IF;

   IF (l_item.main_obj_type.template_id IS NULL AND l_item.main_obj_type.template_name IS NULL AND
   l_item.main_obj_type.item_catalog_group_id IS NOT NULL AND l_item.main_obj_type.item_catalog_group_id <> fnd_api.g_miss_num) THEN
     SELECT default_template_id INTO l_item.main_obj_type.template_id
     FROM ego_catalog_groups_v T
     WHERE catalog_group_id = l_item.main_obj_type.item_catalog_group_id;
   END IF;

   IF ((l_item.main_obj_type.apply_template IS NULL OR l_item.main_obj_type.apply_template = fnd_api.g_miss_char) AND (l_item.main_obj_type.template_id IS NOT NULL OR l_item.main_obj_type.template_name IS NOT NULL)) THEN
     l_item.main_obj_type.apply_template :='ALL';
   END IF;

   IF(l_transaction_type = INV_EBI_ITEM_PUB.g_otype_create ) THEN

     IF(l_item.main_obj_type.description IS NULL OR l_item.main_obj_type.description = fnd_api.g_miss_char) THEN

       IF(l_item.main_obj_type.item_catalog_group_id IS NOT NULL AND l_item.main_obj_type.item_catalog_group_id <> fnd_api.g_miss_num) THEN
         l_item_desc_gen_method := get_desc_gen_method(l_item.main_obj_type.item_catalog_group_id);
       END IF;

       IF(l_item_desc_gen_method = 'U' OR l_item_desc_gen_method IS NULL OR l_item.main_obj_type.item_catalog_group_id IS NULL OR l_item.main_obj_type.item_catalog_group_id = fnd_api.g_miss_num) THEN
         l_is_master_org := INV_EBI_UTIL.is_master_org(l_item.main_obj_type.organization_id);

         IF(l_is_master_org = fnd_api.g_true) THEN
           l_item.main_obj_type.description := l_item_number;
         ELSE
           l_master_org := INV_EBI_UTIL.get_master_organization(
                                        p_organization_id =>  l_item.main_obj_type.organization_id
                              );
           OPEN c_item_description(
                   p_item_number       => l_item_number
                  ,p_organization_id   => l_master_org
           );
           FETCH c_item_description INTO l_description;

           IF(c_item_description%NOTFOUND) THEN
             FND_MESSAGE.set_name('INV','INV_EBI_ITEM_NO_MASTER_ORG');
             FND_MESSAGE.set_token('ITEM_NUMBER', l_item_number);
             FND_MSG_PUB.add;
             RAISE FND_API.g_exc_error;
           END IF;

           l_item.main_obj_type.description  := l_description;
           CLOSE c_item_description;

         END IF;

       END IF;
     END IF;

    /* Start of Bug 8299853 FDD says if NIR is required item should be created as eng_item and
       approval status as unapproved. If NIR is not required item gets created with approval status as NULL by default,which is considered
       as approved ,and we take care of creating it with eng_item_flag='N' if eng_item_flag is NULL.*/


     IF(is_new_item_request_reqd(
                p_item_catalog_group_id => l_item.main_obj_type.item_catalog_group_id
          ) = fnd_api.g_true ) THEN

       IF(l_item.bom_obj_type.eng_item_flag ='N' ) THEN

         FND_MESSAGE.set_name('INV','INV_EBI_ICC_CONFG_FOR_NIR');
         FND_MESSAGE.set_token('ITEM',l_item.main_obj_type.item_number);
         FND_MESSAGE.set_token('ITEM_CATALOG',  l_item.main_obj_type.item_catalog_group_code);
         FND_MSG_PUB.add;
         RAISE FND_API.g_exc_error;

       ELSIF(l_item.bom_obj_type.eng_item_flag = fnd_api.g_miss_char OR l_item.bom_obj_type.eng_item_flag IS NULL ) THEN

         l_item.bom_obj_type.eng_item_flag := 'Y';
         l_item.deprecated_obj_type.approval_status := 'N';

       ELSE

         l_item.deprecated_obj_type.approval_status := 'N';

       END IF;
     ELSE

       IF(l_item.bom_obj_type.eng_item_flag = fnd_api.g_miss_char OR l_item.bom_obj_type.eng_item_flag IS NULL ) THEN
          l_item.bom_obj_type.eng_item_flag := 'N';
       END IF;
     END IF;--End of Bug 8299853

   END IF;


   IF(l_transaction_type = INV_EBI_ITEM_PUB.g_otype_update ) THEN
     l_apply_template_update := INV_EBI_UTIL.get_config_param_value(
                                   p_config_tbl         =>  l_item.name_value_tbl
                                  ,p_config_param_name  => 'TEMPLATE_FOR_ITEM_UPDATE_ALLOWED'
                                );
     IF( UPPER(l_apply_template_update ) = fnd_api.g_false ) THEN
       l_item.main_obj_type.template_id  := fnd_api.g_miss_num;
       l_item.main_obj_type.template_name := fnd_api.g_miss_char;
     END IF;

     --Bug 7601514 :  To create new revision coming in while updating item only if incoming revision is not null
     IF(l_item.main_obj_type.revision_code IS NOT NULL AND l_item.main_obj_type.revision_code <> fnd_api.g_miss_char) THEN
       --Bug 7412466 : To create new revision coming in while updating item
       IF( is_revision_exists (p_organization_id    =>  l_item.main_obj_type.organization_id
                              ,p_item_number        =>  l_item.main_obj_type.item_number
                              ,p_revision           =>  l_item.main_obj_type.revision_code
                              ) =  FND_API.g_false )      THEN
         IF( l_item.main_obj_type.effectivity_date IS NULL OR
             l_item.main_obj_type.effectivity_date = fnd_api.g_miss_date ) THEN
             l_effectivity_date := SYSDATE;
         ELSE
           l_effectivity_date := l_item.main_obj_type.effectivity_date;
         END IF;
         EGO_ITEM_PUB.Process_Item_Revision(
            p_api_version              => 1.0
           ,p_init_msg_list            => FND_API.g_false
           ,p_commit                   => FND_API.g_false
           ,p_transaction_type         => INV_EBI_ITEM_PUB.g_otype_create
           ,p_inventory_item_id        => l_item.main_obj_type.inventory_item_id
           ,p_item_number              => l_item.main_obj_type.item_number
           ,p_organization_id          => l_item.main_obj_type.organization_id
           ,p_organization_code        => l_item.main_obj_type.organization_code
           ,p_revision                 => l_item.main_obj_type.revision_code
           ,p_description              => l_item.main_obj_type.revision_description
           ,p_effectivity_date         => l_effectivity_date
           ,p_revision_label           => l_item.main_obj_type.revision_label
           ,p_revision_reason          => l_item.main_obj_type.revision_reason  --This parameter is added in inv_ebi_item_main_obj
           ,p_lifecycle_id             => l_item.main_obj_type.rev_lifecycle_id
           ,p_current_phase_id         => l_item.main_obj_type.rev_current_phase_id
           ,p_template_id              => l_item.main_obj_type.template_id
           ,p_template_name            => l_item.main_obj_type.template_name
           ,p_attribute_category       => l_item.custom_obj_type.rev_attribute_category
           ,p_attribute1               => l_item.custom_obj_type.rev_attribute1
           ,p_attribute2               => l_item.custom_obj_type.rev_attribute2
           ,p_attribute3               => l_item.custom_obj_type.rev_attribute3
           ,p_attribute4               => l_item.custom_obj_type.rev_attribute4
           ,p_attribute5               => l_item.custom_obj_type.rev_attribute5
           ,p_attribute6               => l_item.custom_obj_type.rev_attribute6
           ,p_attribute7               => l_item.custom_obj_type.rev_attribute7
           ,p_attribute8               => l_item.custom_obj_type.rev_attribute8
           ,p_attribute9               => l_item.custom_obj_type.rev_attribute9
           ,p_attribute10              => l_item.custom_obj_type.rev_attribute10
           ,p_attribute11              => l_item.custom_obj_type.rev_attribute11
           ,p_attribute12              => l_item.custom_obj_type.rev_attribute12
           ,p_attribute13              => l_item.custom_obj_type.rev_attribute13
           ,p_attribute14              => l_item.custom_obj_type.rev_attribute14
           ,p_attribute15              => l_item.custom_obj_type.rev_attribute15
           ,x_return_status            => x_out.output_status.return_status
           ,x_msg_count                => x_out.output_status.msg_count
           ,x_msg_data                 => x_out.output_status.msg_data
           );
         IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
           RAISE  FND_API.g_exc_unexpected_error;
         END IF;
       END IF;  -- Bug 7412466
     END IF;    -- End of Bug 7601514
   END IF;

   INV_EBI_UTIL.debug_line('STEP: 20 '||'START CALLING EGO_ITEM_PUB.process_item ');
   EGO_ITEM_PUB.process_item(
      p_api_version                  =>   1.0
     ,p_init_msg_list                =>   l_item.main_obj_type.init_msg_list
     ,p_commit                       =>   FND_API.g_false
     ,p_transaction_type             =>   l_transaction_type
     ,p_language_code                =>   l_item.main_obj_type.language_code
     ,p_template_id                  =>   l_item.main_obj_type.template_id
     ,p_template_name                =>   l_item.main_obj_type.template_name
     ,p_copy_inventory_item_id       =>   l_item.main_obj_type.copy_inventory_item_id
     ,p_inventory_item_id            =>   l_item.main_obj_type.inventory_item_id
     ,p_organization_id              =>   l_item.main_obj_type.organization_id
     ,p_master_organization_id       =>   l_item.main_obj_type.master_organization_id
     ,p_description                  =>   l_item.main_obj_type.description
     ,p_long_description             =>   l_item.main_obj_type.long_description
     ,p_primary_uom_code             =>   l_item.main_obj_type.primary_uom_code
     ,p_primary_unit_of_measure      =>   l_item.main_obj_type.primary_unit_of_measure
     ,p_item_type                    =>   l_item.main_obj_type.item_type
     ,p_inventory_item_status_code   =>   l_item.main_obj_type.inventory_item_status_code
     ,p_allowed_units_lookup_code    =>   l_item.main_obj_type.allowed_units_lookup_code
     ,p_item_catalog_group_id        =>   l_item.main_obj_type.item_catalog_group_id
     ,p_catalog_status_flag          =>   l_item.deprecated_obj_type.catalog_status_flag
     ,p_inventory_item_flag          =>   l_item.inventory_obj_type.inventory_item_flag
     ,p_stock_enabled_flag           =>   l_item.inventory_obj_type.stock_enabled_flag
     ,p_mtl_transactions_enabled_fl  =>   l_item.inventory_obj_type.mtl_transactions_enabled_fl
     ,p_check_shortages_flag         =>   l_item.inventory_obj_type.check_shortages_flag
     ,p_revision_qty_control_code    =>   l_item.inventory_obj_type.revision_qty_control_code
     ,p_reservable_type              =>   l_item.inventory_obj_type.reservable_type
     ,p_shelf_life_code              =>   l_item.inventory_obj_type.shelf_life_code
     ,p_shelf_life_days              =>   l_item.inventory_obj_type.shelf_life_days
     ,p_cycle_count_enabled_flag     =>   l_item.inventory_obj_type.cycle_count_enabled_flag
     ,p_negative_measurement_error   =>   l_item.inventory_obj_type.negative_measurement_error
     ,p_positive_measurement_error   =>   l_item.inventory_obj_type.positive_measurement_error
     ,p_lot_control_code             =>   l_item.inventory_obj_type.lot_control_code
     ,p_auto_lot_alpha_prefix        =>   l_item.inventory_obj_type.auto_lot_alpha_prefix
     ,p_start_auto_lot_number        =>   l_item.inventory_obj_type.start_auto_lot_number
     ,p_serial_number_control_code   =>   l_item.inventory_obj_type.serial_number_control_code
     ,p_auto_serial_alpha_prefix     =>   l_item.inventory_obj_type.auto_serial_alpha_prefix
     ,p_start_auto_serial_number     =>   l_item.inventory_obj_type.start_auto_serial_number
     ,p_location_control_code        =>   l_item.inventory_obj_type.location_control_code
     ,p_restrict_subinventories_cod  =>   l_item.inventory_obj_type.restrict_subinventories_cod
     ,p_restrict_locators_code       =>   l_item.inventory_obj_type.restrict_locators_code
     ,p_bom_enabled_flag             =>   l_item.bom_obj_type.bom_enabled_flag
     ,p_bom_item_type                =>   l_item.bom_obj_type.bom_item_type
     ,p_base_item_id                 =>   l_item.bom_obj_type.base_item_id
     ,p_effectivity_control          =>   l_item.bom_obj_type.effectivity_control
     ,p_eng_item_flag                =>   l_item.bom_obj_type.eng_item_flag
     ,p_engineering_ecn_code         =>   l_item.deprecated_obj_type.engineering_ecn_code
     ,p_engineering_item_id          =>   l_item.deprecated_obj_type.engineering_item_id
     ,p_engineering_date             =>   l_item.deprecated_obj_type.engineering_date
     ,p_product_family_item_id       =>   l_item.deprecated_obj_type.product_family_item_id
     ,p_auto_created_config_flag     =>   l_item.bom_obj_type.auto_created_config_flag
     ,p_model_config_clause_name     =>   l_item.deprecated_obj_type.model_config_clause_name
     ,p_new_revision_code            =>   l_item.deprecated_obj_type.new_revision_code
     ,p_costing_enabled_flag         =>   l_item.costing_obj_type.costing_enabled_flag
     ,p_inventory_asset_flag         =>   l_item.costing_obj_type.inventory_asset_flag
     ,p_default_include_in_rollup_f  =>   l_item.costing_obj_type.default_include_in_rollup_f
     ,p_cost_of_sales_account        =>   l_item.costing_obj_type.cost_of_sales_account
     ,p_std_lot_size                 =>   l_item.costing_obj_type.std_lot_size
     ,p_purchasing_item_flag         =>   l_item.purchasing_obj_type.purchasing_item_flag
     ,p_purchasing_enabled_flag      =>   l_item.purchasing_obj_type.purchasing_enabled_flag
     ,p_must_use_approved_vendor_fl  =>   l_item.purchasing_obj_type.must_use_approved_vendor_fl
     ,p_allow_item_desc_update_flag  =>   l_item.purchasing_obj_type.allow_item_desc_update_flag
     ,p_rfq_required_flag            =>   l_item.purchasing_obj_type.rfq_required_flag
     ,p_outside_operation_flag       =>   l_item.purchasing_obj_type.outside_operation_flag
     ,p_outside_operation_uom_type   =>   l_item.purchasing_obj_type.outside_operation_uom_type
     ,p_taxable_flag                 =>   l_item.purchasing_obj_type.taxable_flag
     ,p_purchasing_tax_code          =>   l_item.purchasing_obj_type.purchasing_tax_code
     ,p_receipt_required_flag        =>   l_item.purchasing_obj_type.receipt_required_flag
     ,p_inspection_required_flag     =>   l_item.purchasing_obj_type.inspection_required_flag
     ,p_buyer_id                     =>   l_item.purchasing_obj_type.buyer_id
     ,p_unit_of_issue                =>   l_item.purchasing_obj_type.unit_of_issue
     ,p_receive_close_tolerance      =>   l_item.purchasing_obj_type.receive_close_tolerance
     ,p_invoice_close_tolerance      =>   l_item.purchasing_obj_type.invoice_close_tolerance
     ,p_un_number_id                 =>   l_item.purchasing_obj_type.un_number_id
     ,p_hazard_class_id              =>   l_item.purchasing_obj_type.hazard_class_id
     ,p_list_price_per_unit          =>   l_item.purchasing_obj_type.list_price_per_unit
     ,p_market_price                 =>   l_item.purchasing_obj_type.market_price
     ,p_price_tolerance_percent      =>   l_item.purchasing_obj_type.price_tolerance_percent
     ,p_rounding_factor              =>   l_item.purchasing_obj_type.rounding_factor
     ,p_encumbrance_account          =>   l_item.purchasing_obj_type.encumbrance_account
     ,p_expense_account              =>   l_item.purchasing_obj_type.expense_account
     ,p_expense_billable_flag        =>   l_item.deprecated_obj_type.expense_billable_flag
     ,p_asset_category_id            =>   l_item.purchasing_obj_type.asset_category_id
     ,p_receipt_days_exception_code  =>   l_item.receiving_obj_type.receipt_days_exception_code
     ,p_days_early_receipt_allowed   =>   l_item.receiving_obj_type.days_early_receipt_allowed
     ,p_days_late_receipt_allowed    =>   l_item.receiving_obj_type.days_late_receipt_allowed
     ,p_allow_substitute_receipts_f  =>   l_item.receiving_obj_type.allow_substitute_receipts_f
     ,p_allow_unordered_receipts_fl  =>   l_item.receiving_obj_type.allow_unordered_receipts_fl
     ,p_allow_express_delivery_flag  =>   l_item.receiving_obj_type.allow_express_delivery_flag
     ,p_qty_rcv_exception_code       =>   l_item.receiving_obj_type.qty_rcv_exception_code
     ,p_qty_rcv_tolerance            =>   l_item.receiving_obj_type.qty_rcv_tolerance
     ,p_receiving_routing_id         =>   l_item.receiving_obj_type.receiving_routing_id
     ,p_enforce_ship_to_location_c   =>   l_item.receiving_obj_type.enforce_ship_to_location_c
     ,p_weight_uom_code              =>   l_item.physical_obj_type.weight_uom_code
     ,p_unit_weight                  =>   l_item.physical_obj_type.unit_weight
     ,p_volume_uom_code              =>   l_item.physical_obj_type.volume_uom_code
     ,p_unit_volume                  =>   l_item.physical_obj_type.unit_volume
     ,p_container_item_flag          =>   l_item.physical_obj_type.container_item_flag
     ,p_vehicle_item_flag            =>   l_item.physical_obj_type.vehicle_item_flag
     ,p_container_type_code          =>   l_item.physical_obj_type.container_type_code
     ,p_internal_volume              =>   l_item.physical_obj_type.internal_volume
     ,p_maximum_load_weight          =>   l_item.physical_obj_type.maximum_load_weight
     ,p_minimum_fill_percent         =>   l_item.physical_obj_type.minimum_fill_percent
     ,p_inventory_planning_code      =>   l_item.gplanning_obj_type.inventory_planning_code
     ,p_planner_code                 =>   l_item.gplanning_obj_type.planner_code
     ,p_planning_make_buy_code       =>   l_item.gplanning_obj_type.planning_make_buy_code
     ,p_min_minmax_quantity          =>   l_item.gplanning_obj_type.min_minmax_quantity
     ,p_max_minmax_quantity          =>   l_item.gplanning_obj_type.max_minmax_quantity
     ,p_minimum_order_quantity       =>   l_item.gplanning_obj_type.minimum_order_quantity
     ,p_maximum_order_quantity       =>   l_item.gplanning_obj_type.maximum_order_quantity
     ,p_order_cost                   =>   l_item.gplanning_obj_type.order_cost
     ,p_carrying_cost                =>   l_item.gplanning_obj_type.carrying_cost
     ,p_source_type                  =>   l_item.gplanning_obj_type.source_type
     ,p_source_organization_id       =>   l_item.gplanning_obj_type.source_organization_id
     ,p_source_subinventory          =>   l_item.gplanning_obj_type.source_subinventory
     ,p_mrp_safety_stock_code        =>   l_item.gplanning_obj_type.mrp_safety_stock_code
     ,p_safety_stock_bucket_days     =>   l_item.gplanning_obj_type.safety_stock_bucket_days
     ,p_mrp_safety_stock_percent     =>   l_item.gplanning_obj_type.mrp_safety_stock_percent
     ,p_fixed_order_quantity         =>   l_item.gplanning_obj_type.fixed_order_quantity
     ,p_fixed_days_supply            =>   l_item.gplanning_obj_type.fixed_days_supply
     ,p_fixed_lot_multiplier         =>   l_item.gplanning_obj_type.fixed_lot_multiplier
     ,p_mrp_planning_code            =>   l_item.mrp_obj_type.mrp_planning_code
     ,p_ato_forecast_control         =>   l_item.mrp_obj_type.ato_forecast_control
     ,p_planning_exception_set       =>   l_item.mrp_obj_type.planning_exception_set
     ,p_end_assembly_pegging_flag    =>   l_item.mrp_obj_type.end_assembly_pegging_flag
     ,p_shrinkage_rate               =>   l_item.mrp_obj_type.shrinkage_rate
     ,p_rounding_control_type        =>   l_item.mrp_obj_type.rounding_control_type
     ,p_acceptable_early_days        =>   l_item.mrp_obj_type.acceptable_early_days
     ,p_repetitive_planning_flag     =>   l_item.mrp_obj_type.repetitive_planning_flag
     ,p_overrun_percentage           =>   l_item.mrp_obj_type.overrun_percentage
     ,p_acceptable_rate_increase     =>   l_item.mrp_obj_type.acceptable_rate_increase
     ,p_acceptable_rate_decrease     =>   l_item.mrp_obj_type.acceptable_rate_decrease
     ,p_mrp_calculate_atp_flag       =>   l_item.mrp_obj_type.mrp_calculate_atp_flag
     ,p_auto_reduce_mps              =>   l_item.mrp_obj_type.auto_reduce_mps
     ,p_planning_time_fence_code     =>   l_item.mrp_obj_type.planning_time_fence_code
     ,p_planning_time_fence_days     =>   l_item.mrp_obj_type.planning_time_fence_days
     ,p_demand_time_fence_code       =>   l_item.mrp_obj_type.demand_time_fence_code
     ,p_demand_time_fence_days       =>   l_item.mrp_obj_type.demand_time_fence_days
     ,p_release_time_fence_code      =>   l_item.mrp_obj_type.release_time_fence_code
     ,p_release_time_fence_days      =>   l_item.mrp_obj_type.release_time_fence_days
     ,p_preprocessing_lead_time      =>   l_item.lead_time_obj_type.preprocessing_lead_time
     ,p_full_lead_time               =>   l_item.lead_time_obj_type.full_lead_time
     ,p_postprocessing_lead_time     =>   l_item.lead_time_obj_type.postprocessing_lead_time
     ,p_fixed_lead_time              =>   l_item.lead_time_obj_type.fixed_lead_time
     ,p_variable_lead_time           =>   l_item.lead_time_obj_type.variable_lead_time
     ,p_cum_manufacturing_lead_time  =>   l_item.lead_time_obj_type.cum_manufacturing_lead_time
     ,p_cumulative_total_lead_time   =>   l_item.lead_time_obj_type.cumulative_total_lead_time
     ,p_lead_time_lot_size           =>   l_item.lead_time_obj_type.lead_time_lot_size
     ,p_build_in_wip_flag            =>   l_item.wip_obj_type.build_in_wip_flag
     ,p_wip_supply_type              =>   l_item.wip_obj_type.wip_supply_type
     ,p_wip_supply_subinventory      =>   l_item.wip_obj_type.wip_supply_subinventory
     ,p_wip_supply_locator_id        =>   l_item.wip_obj_type.wip_supply_locator_id
     ,p_overcompletion_tolerance_ty  =>   l_item.wip_obj_type.overcompletion_tolerance_ty
     ,p_overcompletion_tolerance_va  =>   l_item.wip_obj_type.overcompletion_tolerance_va
     ,p_customer_order_flag          =>   l_item.order_obj_type.customer_order_flag
     ,p_customer_order_enabled_flag  =>   l_item.order_obj_type.customer_order_enabled_flag
     ,p_shippable_item_flag          =>   l_item.order_obj_type.shippable_item_flag
     ,p_internal_order_flag          =>   l_item.order_obj_type.internal_order_flag
     ,p_internal_order_enabled_flag  =>   l_item.order_obj_type.internal_order_enabled_flag
     ,p_so_transactions_flag         =>   l_item.order_obj_type.so_transactions_flag
     ,p_pick_components_flag         =>   l_item.order_obj_type.pick_components_flag
     ,p_atp_flag                     =>   l_item.order_obj_type.atp_flag
     ,p_replenish_to_order_flag      =>   l_item.order_obj_type.replenish_to_order_flag
     ,p_atp_rule_id                  =>   l_item.order_obj_type.atp_rule_id
     ,p_atp_components_flag          =>   l_item.order_obj_type.atp_components_flag
     ,p_ship_model_complete_flag     =>   l_item.order_obj_type.ship_model_complete_flag
     ,p_picking_rule_id              =>   l_item.order_obj_type.picking_rule_id
     ,p_collateral_flag              =>   l_item.order_obj_type.collateral_flag
     ,p_default_shipping_org         =>   l_item.order_obj_type.default_shipping_org
     ,p_returnable_flag              =>   l_item.order_obj_type.returnable_flag
     ,p_return_inspection_requireme  =>   l_item.order_obj_type.return_inspection_requireme
     ,p_over_shipment_tolerance      =>   l_item.order_obj_type.over_shipment_tolerance
     ,p_under_shipment_tolerance     =>   l_item.order_obj_type.under_shipment_tolerance
     ,p_over_return_tolerance        =>   l_item.order_obj_type.over_return_tolerance
     ,p_under_return_tolerance       =>   l_item.order_obj_type.under_return_tolerance
     ,p_invoiceable_item_flag        =>   l_item.invoice_obj_type.invoiceable_item_flag
     ,p_invoice_enabled_flag         =>   l_item.invoice_obj_type.invoice_enabled_flag
     ,p_accounting_rule_id           =>   l_item.invoice_obj_type.accounting_rule_id
     ,p_invoicing_rule_id            =>   l_item.invoice_obj_type.invoicing_rule_id
     ,p_tax_code                     =>   l_item.invoice_obj_type.tax_code
     ,p_sales_account                =>   l_item.invoice_obj_type.sales_account
     ,p_payment_terms_id             =>   l_item.invoice_obj_type.payment_terms_id
     ,p_coverage_schedule_id         =>   l_item.service_obj_type.coverage_schedule_id
     ,p_service_duration             =>   l_item.service_obj_type.service_duration
     ,p_service_duration_period_cod  =>   l_item.service_obj_type.service_duration_period_cod
     ,p_serviceable_product_flag     =>   l_item.service_obj_type.serviceable_product_flag
     ,p_service_starting_delay       =>   l_item.service_obj_type.service_starting_delay
     ,p_material_billable_flag       =>   l_item.service_obj_type.material_billable_flag
     ,p_serviceable_component_flag   =>   l_item.deprecated_obj_type.serviceable_component_flag
     ,p_preventive_maintenance_flag  =>   l_item.deprecated_obj_type.preventive_maintenance_flag
     ,p_prorate_service_flag         =>   l_item.deprecated_obj_type.prorate_service_flag
     ,p_serviceable_item_class_id    =>   l_item.deprecated_obj_type.serviceable_item_class_id
     ,p_base_warranty_service_id     =>   l_item.deprecated_obj_type.base_warranty_service_id
     ,p_warranty_vendor_id           =>   l_item.deprecated_obj_type.warranty_vendor_id
     ,p_max_warranty_amount          =>   l_item.deprecated_obj_type.max_warranty_amount
     ,p_response_time_period_code    =>   l_item.deprecated_obj_type.response_time_period_code
     ,p_response_time_value          =>   l_item.deprecated_obj_type.response_time_value
     ,p_primary_specialist_id        =>   l_item.deprecated_obj_type.primary_specialist_id
     ,p_secondary_specialist_id      =>   l_item.deprecated_obj_type.secondary_specialist_id
     ,p_wh_update_date               =>   l_item.deprecated_obj_type.wh_update_date
     ,p_equipment_type               =>   l_item.physical_obj_type.equipment_type
     ,p_recovered_part_disp_code     =>   l_item.service_obj_type.recovered_part_disp_code
     ,p_defect_tracking_on_flag      =>   l_item.service_obj_type.defect_tracking_on_flag
     ,p_event_flag                   =>   l_item.physical_obj_type.event_flag
     ,p_electronic_flag              =>   l_item.physical_obj_type.electronic_flag
     ,p_downloadable_flag            =>   l_item.physical_obj_type.downloadable_flag
     ,p_vol_discount_exempt_flag     =>   l_item.deprecated_obj_type.vol_discount_exempt_flag
     ,p_coupon_exempt_flag           =>   l_item.deprecated_obj_type.coupon_exempt_flag
     ,p_comms_nl_trackable_flag      =>   l_item.service_obj_type.comms_nl_trackable_flag
     ,p_asset_creation_code          =>   l_item.service_obj_type.asset_creation_code
     ,p_comms_activation_reqd_flag   =>   l_item.deprecated_obj_type.comms_activation_reqd_flag
     ,p_orderable_on_web_flag        =>   l_item.web_option_obj_type.orderable_on_web_flag
     ,p_back_orderable_flag          =>   l_item.web_option_obj_type.back_orderable_flag
     ,p_web_status                   =>   l_item.web_option_obj_type.web_status
     ,p_indivisible_flag             =>   l_item.physical_obj_type.indivisible_flag
     ,p_dimension_uom_code           =>   l_item.physical_obj_type.dimension_uom_code
     ,p_unit_length                  =>   l_item.physical_obj_type.unit_length
     ,p_unit_width                   =>   l_item.physical_obj_type.unit_width
     ,p_unit_height                  =>   l_item.physical_obj_type.unit_height
     ,p_bulk_picked_flag             =>   l_item.inventory_obj_type.bulk_picked_flag
     ,p_lot_status_enabled           =>   l_item.inventory_obj_type.lot_status_enabled
     ,p_default_lot_status_id        =>   l_item.deprecated_obj_type.default_lot_status_id
     ,p_serial_status_enabled        =>   l_item.inventory_obj_type.serial_status_enabled
     ,p_default_serial_status_id     =>   l_item.deprecated_obj_type.default_serial_status_id
     ,p_lot_split_enabled            =>   l_item.inventory_obj_type.lot_split_enabled
     ,p_lot_merge_enabled            =>   l_item.inventory_obj_type.lot_merge_enabled
     ,p_inventory_carry_penalty      =>   l_item.wip_obj_type.inventory_carry_penalty
     ,p_operation_slack_penalty      =>   l_item.wip_obj_type.operation_slack_penalty
     ,p_financing_allowed_flag       =>   l_item.order_obj_type.financing_allowed_flag
     ,p_eam_item_type                =>   l_item.asset_obj_type.eam_item_type
     ,p_eam_activity_type_code       =>   l_item.asset_obj_type.eam_activity_type_code
     ,p_eam_activity_cause_code      =>   l_item.asset_obj_type.eam_activity_cause_code
     ,p_eam_act_notification_flag    =>   l_item.asset_obj_type.eam_act_notification_flag
     ,p_eam_act_shutdown_status      =>   l_item.asset_obj_type.eam_act_shutdown_status
     ,p_dual_uom_control             =>   l_item.deprecated_obj_type.dual_uom_control
     ,p_secondary_uom_code           =>   l_item.main_obj_type.secondary_uom_code
     ,p_dual_uom_deviation_high      =>   l_item.main_obj_type.dual_uom_deviation_high
     ,p_dual_uom_deviation_low       =>   l_item.main_obj_type.dual_uom_deviation_low
     ,p_contract_item_type_code      =>   l_item.asset_obj_type.contract_item_type_code
     ,p_subscription_depend_flag     =>   l_item.deprecated_obj_type.subscription_depend_flag
     ,p_serv_req_enabled_code        =>   l_item.asset_obj_type.serv_req_enabled_code
     ,p_serv_billing_enabled_flag    =>   l_item.asset_obj_type.serv_billing_enabled_flag
     ,p_serv_importance_level        =>   l_item.deprecated_obj_type.serv_importance_level
     ,p_planned_inv_point_flag       =>   l_item.mrp_obj_type.planned_inv_point_flag
     ,p_lot_translate_enabled        =>   l_item.inventory_obj_type.lot_translate_enabled
     ,p_default_so_source_type       =>   l_item.order_obj_type.default_so_source_type
     ,p_create_supply_flag           =>   l_item.mrp_obj_type.create_supply_flag
     ,p_substitution_window_code     =>   l_item.mrp_obj_type.substitution_window_code
     ,p_substitution_window_days     =>   l_item.mrp_obj_type.substitution_window_days
     ,p_ib_item_instance_class       =>   l_item.service_obj_type.ib_item_instance_class
     ,p_config_model_type            =>   l_item.bom_obj_type.config_model_type
     ,p_lot_substitution_enabled     =>   l_item.inventory_obj_type.lot_substitution_enabled
     ,p_minimum_license_quantity     =>   l_item.web_option_obj_type.minimum_license_quantity
     ,p_eam_activity_source_code     =>   l_item.asset_obj_type.eam_activity_source_code
     ,p_approval_status              =>   l_item.deprecated_obj_type.approval_status
     ,p_tracking_quantity_ind        =>   l_item.main_obj_type.tracking_quantity_ind
     ,p_ont_pricing_qty_source       =>   l_item.main_obj_type.ont_pricing_qty_source
     ,p_secondary_default_ind        =>   l_item.main_obj_type.secondary_default_ind
     ,p_option_specific_sourced      =>   l_item.deprecated_obj_type.option_specific_sourced
     ,p_vmi_minimum_units            =>   l_item.gplanning_obj_type.vmi_minimum_units
     ,p_vmi_minimum_days             =>   l_item.gplanning_obj_type.vmi_minimum_days
     ,p_vmi_maximum_units            =>   l_item.gplanning_obj_type.vmi_maximum_units
     ,p_vmi_maximum_days             =>   l_item.gplanning_obj_type.vmi_maximum_days
     ,p_vmi_fixed_order_quantity     =>   l_item.gplanning_obj_type.vmi_fixed_order_quantity
     ,p_so_authorization_flag        =>   l_item.gplanning_obj_type.so_authorization_flag
     ,p_consigned_flag               =>   l_item.gplanning_obj_type.consigned_flag
     ,p_asn_autoexpire_flag          =>   l_item.gplanning_obj_type.asn_autoexpire_flag
     ,p_vmi_forecast_type            =>   l_item.gplanning_obj_type.vmi_forecast_type
     ,p_forecast_horizon             =>   l_item.gplanning_obj_type.forecast_horizon
     ,p_exclude_from_budget_flag     =>   l_item.mrp_obj_type.exclude_from_budget_flag
     ,p_days_tgt_inv_supply          =>   l_item.mrp_obj_type.days_tgt_inv_supply
     ,p_days_tgt_inv_window          =>   l_item.mrp_obj_type.days_tgt_inv_window
     ,p_days_max_inv_supply          =>   l_item.mrp_obj_type.days_max_inv_supply
     ,p_days_max_inv_window          =>   l_item.mrp_obj_type.days_max_inv_window
     ,p_drp_planned_flag             =>   l_item.mrp_obj_type.drp_planned_flag
     ,p_critical_component_flag      =>   l_item.mrp_obj_type.critical_component_flag
     ,p_continous_transfer           =>   l_item.mrp_obj_type.continous_transfer
     ,p_convergence                  =>   l_item.mrp_obj_type.convergence
     ,p_divergence                   =>   l_item.mrp_obj_type.divergence
     ,p_config_orgs                  =>   l_item.bom_obj_type.config_orgs
     ,p_config_match                 =>   l_item.bom_obj_type.config_match
     ,p_item_number                  =>   l_item.main_obj_type.item_number
     ,p_segment1                     =>   l_item.main_obj_type.segment1
     ,p_segment2                     =>   l_item.main_obj_type.segment2
     ,p_segment3                     =>   l_item.main_obj_type.segment3
     ,p_segment4                     =>   l_item.main_obj_type.segment4
     ,p_segment5                     =>   l_item.main_obj_type.segment5
     ,p_segment6                     =>   l_item.main_obj_type.segment6
     ,p_segment7                     =>   l_item.main_obj_type.segment7
     ,p_segment8                     =>   l_item.main_obj_type.segment8
     ,p_segment9                     =>   l_item.main_obj_type.segment9
     ,p_segment10                    =>   l_item.main_obj_type.segment10
     ,p_segment11                    =>   l_item.main_obj_type.segment11
     ,p_segment12                    =>   l_item.main_obj_type.segment12
     ,p_segment13                    =>   l_item.main_obj_type.segment13
     ,p_segment14                    =>   l_item.main_obj_type.segment14
     ,p_segment15                    =>   l_item.main_obj_type.segment15
     ,p_segment16                    =>   l_item.main_obj_type.segment16
     ,p_segment17                    =>   l_item.main_obj_type.segment17
     ,p_segment18                    =>   l_item.main_obj_type.segment18
     ,p_segment19                    =>   l_item.main_obj_type.segment19
     ,p_segment20                    =>   l_item.main_obj_type.segment20
     ,p_summary_flag                 =>   l_item.main_obj_type.summary_flag
     ,p_enabled_flag                 =>   l_item.main_obj_type.enabled_flag
     ,p_start_date_active            =>   l_item.main_obj_type.start_date_active
     ,p_end_date_active              =>   l_item.main_obj_type.end_date_active
     ,p_attribute_category           =>   l_item.custom_obj_type.attribute_category
     ,p_attribute1                   =>   l_item.custom_obj_type.attribute1
     ,p_attribute2                   =>   l_item.custom_obj_type.attribute2
     ,p_attribute3                   =>   l_item.custom_obj_type.attribute3
     ,p_attribute4                   =>   l_item.custom_obj_type.attribute4
     ,p_attribute5                   =>   l_item.custom_obj_type.attribute5
     ,p_attribute6                   =>   l_item.custom_obj_type.attribute6
     ,p_attribute7                   =>   l_item.custom_obj_type.attribute7
     ,p_attribute8                   =>   l_item.custom_obj_type.attribute8
     ,p_attribute9                   =>   l_item.custom_obj_type.attribute9
     ,p_attribute10                  =>   l_item.custom_obj_type.attribute10
     ,p_attribute11                  =>   l_item.custom_obj_type.attribute11
     ,p_attribute12                  =>   l_item.custom_obj_type.attribute12
     ,p_attribute13                  =>   l_item.custom_obj_type.attribute13
     ,p_attribute14                  =>   l_item.custom_obj_type.attribute14
     ,p_attribute15                  =>   l_item.custom_obj_type.attribute15
     ,p_attribute16                  =>   l_item.custom_obj_type.attribute16
     ,p_attribute17                  =>   l_item.custom_obj_type.attribute17
     ,p_attribute18                  =>   l_item.custom_obj_type.attribute18
     ,p_attribute19                  =>   l_item.custom_obj_type.attribute19
     ,p_attribute20                  =>   l_item.custom_obj_type.attribute20
     ,p_attribute21                  =>   l_item.custom_obj_type.attribute21
     ,p_attribute22                  =>   l_item.custom_obj_type.attribute22
     ,p_attribute23                  =>   l_item.custom_obj_type.attribute23
     ,p_attribute24                  =>   l_item.custom_obj_type.attribute24
     ,p_attribute25                  =>   l_item.custom_obj_type.attribute25
     ,p_attribute26                  =>   l_item.custom_obj_type.attribute26
     ,p_attribute27                  =>   l_item.custom_obj_type.attribute27
     ,p_attribute28                  =>   l_item.custom_obj_type.attribute28
     ,p_attribute29                  =>   l_item.custom_obj_type.attribute29
     ,p_attribute30                  =>   l_item.custom_obj_type.attribute30
     ,p_global_attribute_category    =>   l_item.custom_obj_type.global_attribute_category
     ,p_global_attribute1            =>   l_item.custom_obj_type.global_attribute1
     ,p_global_attribute2            =>   l_item.custom_obj_type.global_attribute2
     ,p_global_attribute3            =>   l_item.custom_obj_type.global_attribute3
     ,p_global_attribute4            =>   l_item.custom_obj_type.global_attribute4
     ,p_global_attribute5            =>   l_item.custom_obj_type.global_attribute5
     ,p_global_attribute6            =>   l_item.custom_obj_type.global_attribute6
     ,p_global_attribute7            =>   l_item.custom_obj_type.global_attribute7
     ,p_global_attribute8            =>   l_item.custom_obj_type.global_attribute8
     ,p_global_attribute9            =>   l_item.custom_obj_type.global_attribute9
     ,p_global_attribute10           =>   l_item.custom_obj_type.global_attribute10
     ,p_creation_date                =>   l_item.main_obj_type.creation_date
     ,p_created_by                   =>   l_item.main_obj_type.created_by
     ,p_last_update_date             =>   l_item.main_obj_type.last_update_date
     ,p_last_updated_by              =>   l_item.main_obj_type.last_updated_by
     ,p_last_update_login            =>   l_item.main_obj_type.last_update_login
     ,p_request_id                   =>   l_item.main_obj_type.request_id
     ,p_program_application_id       =>   l_item.main_obj_type.program_application_id
     ,p_program_id                   =>   l_item.main_obj_type.program_id
     ,p_program_update_date          =>   l_item.main_obj_type.program_update_date
     ,p_lifecycle_id                 =>   l_item.main_obj_type.lifecycle_id
     ,p_current_phase_id             =>   l_item.main_obj_type.current_phase_id
     ,p_revision_id                  =>   l_item.main_obj_type.revision_id
     ,p_revision_code                =>   l_item.main_obj_type.revision_code
     ,p_revision_label               =>   l_item.main_obj_type.revision_label
     ,p_revision_description         =>   l_item.main_obj_type.revision_description
     ,p_effectivity_date             =>   l_item.main_obj_type.effectivity_date
     ,p_rev_lifecycle_id             =>   l_item.main_obj_type.rev_lifecycle_id
     ,p_rev_current_phase_id         =>   l_item.main_obj_type.rev_current_phase_id
     ,p_rev_attribute_category       =>   l_item.custom_obj_type.rev_attribute_category
     ,p_rev_attribute1               =>   l_item.custom_obj_type.rev_attribute1
     ,p_rev_attribute2               =>   l_item.custom_obj_type.rev_attribute2
     ,p_rev_attribute3               =>   l_item.custom_obj_type.rev_attribute3
     ,p_rev_attribute4               =>   l_item.custom_obj_type.rev_attribute4
     ,p_rev_attribute5               =>   l_item.custom_obj_type.rev_attribute5
     ,p_rev_attribute6               =>   l_item.custom_obj_type.rev_attribute6
     ,p_rev_attribute7               =>   l_item.custom_obj_type.rev_attribute7
     ,p_rev_attribute8               =>   l_item.custom_obj_type.rev_attribute8
     ,p_rev_attribute9               =>   l_item.custom_obj_type.rev_attribute9
     ,p_rev_attribute10              =>   l_item.custom_obj_type.rev_attribute10
     ,p_rev_attribute11              =>   l_item.custom_obj_type.rev_attribute11
     ,p_rev_attribute12              =>   l_item.custom_obj_type.rev_attribute12
     ,p_rev_attribute13              =>   l_item.custom_obj_type.rev_attribute13
     ,p_rev_attribute14              =>   l_item.custom_obj_type.rev_attribute14
     ,p_rev_attribute15              =>   l_item.custom_obj_type.rev_attribute15
     ,p_apply_template               =>   l_item.main_obj_type.apply_template
     ,p_object_version_number        =>   l_item.deprecated_obj_type.object_version_number
     ,p_process_control              =>   'PLM_UI:N'
     ,x_inventory_item_id            =>   x_out.inventory_item_id
     ,x_organization_id              =>   x_out.organization_id
     ,x_return_status                =>   x_out.output_status.return_status
     ,x_msg_count                    =>   x_out.output_status.msg_count
     ,x_msg_data                     =>   x_out.output_status.msg_data
     ,p_cas_number                   =>   l_item.process_manufacturing_obj.cas_number
     ,p_child_lot_flag               =>   l_item.inventory_obj_type.child_lot_flag
     ,p_child_lot_prefix             =>   l_item.inventory_obj_type.child_lot_prefix
     ,p_child_lot_starting_number    =>   l_item.inventory_obj_type.child_lot_starting_number
     ,p_child_lot_validation_flag    =>   l_item.inventory_obj_type.child_lot_validation_flag
     ,p_copy_lot_attribute_flag      =>   l_item.inventory_obj_type.copy_lot_attribute_flag
     ,p_default_grade                =>   l_item.inventory_obj_type.default_grade
     ,p_expiration_action_code       =>   l_item.inventory_obj_type.expiration_action_code
     ,p_expiration_action_interval   =>   l_item.inventory_obj_type.expiration_action_interval
     ,p_grade_control_flag           =>   l_item.inventory_obj_type.grade_control_flag
     ,p_hazardous_material_flag      =>   l_item.process_manufacturing_obj.hazardous_material_flag
     ,p_hold_days                    =>   l_item.inventory_obj_type.hold_days
     ,p_lot_divisible_flag           =>   l_item.inventory_obj_type.lot_divisible_flag
     ,p_maturity_days                =>   l_item.inventory_obj_type.maturity_days
     ,p_parent_child_generation_flag =>   l_item.inventory_obj_type.parent_child_generation_flag
     ,p_process_costing_enabled_flag =>   l_item.process_manufacturing_obj.process_costing_enabled_flag
     ,p_process_execution_enabled_fl =>   l_item.process_manufacturing_obj.process_execution_enabled_flag
     ,p_process_quality_enabled_flag =>   l_item.process_manufacturing_obj.process_quality_enabled_flag
     ,p_process_supply_locator_id    =>   l_item.process_manufacturing_obj.process_supply_locator_id
     ,p_process_supply_subinventory  =>   l_item.process_manufacturing_obj.process_supply_subinventory
     ,p_process_yield_locator_id     =>   l_item.process_manufacturing_obj.process_yield_locator_id
     ,p_process_yield_subinventory   =>   l_item.process_manufacturing_obj.process_yield_subinventory
     ,p_recipe_enabled_flag          =>   l_item.process_manufacturing_obj.recipe_enabled_flag
     ,p_retest_interval              =>   l_item.inventory_obj_type.retest_interval
     ,p_charge_periodicity_code      =>   l_item.order_obj_type.charge_periodicity_code
     ,p_repair_leadtime              =>   l_item.mrp_obj_type.repair_leadtime
     ,p_repair_yield                 =>   l_item.mrp_obj_type.repair_yield
     ,p_preposition_point            =>   l_item.mrp_obj_type.preposition_point
     ,p_repair_program               =>   l_item.mrp_obj_type.repair_program
     ,p_subcontracting_component     =>   l_item.gplanning_obj_type.subcontracting_component
     ,p_outsourced_assembly          =>   l_item.purchasing_obj_type.outsourced_assembly
   );
     INV_EBI_UTIL.debug_line('STEP: 30 '||'END CALLING EGO_ITEM_PUB.process_item ');
   IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
     RAISE  FND_API.g_exc_unexpected_error;
   END IF;
   l_pk_col_name_val_pairs.EXTEND(1);
   l_pk_col_name_val_pairs(1).name      := 'organization_id';
   l_pk_col_name_val_pairs(1).value     := l_item.main_obj_type.organization_id;
   x_out.organization_code  := id_to_value(
                                              p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                             ,p_entity_name            => G_ORGANIZATION
                                           );
   SELECT concatenated_segments,description
   INTO x_out.item_number,x_out.description
   FROM mtl_system_items_kfv
   WHERE organization_id = x_out.organization_id
   AND inventory_item_id = x_out.inventory_item_id;

   get_Operating_unit
   (p_oranization_id => x_out.organization_id
   ,x_operating_unit => x_out.operating_unit
   ,x_ouid           => x_out.operating_unit_id
   );

   BEGIN
     SELECT orig_system_id
       INTO l_source_system_id
       FROM HZ_ORIG_SYSTEMS_B
      WHERE orig_system = l_item.main_obj_type.cross_reference_type;
   EXCEPTION
     WHEN NO_DATA_FOUND THEN
       NULL;
   END;

   BEGIN
     SELECT COUNT(*)
       INTO l_count
       FROM MTL_CROSS_REFERENCES_B MCR
      WHERE MCR.CROSS_REFERENCE_TYPE = 'SS_ITEM_XREF'
        AND nvl(MCR.SOURCE_SYSTEM_ID,-99999) = nvl(l_source_system_id,-99999) --Bug 8704166
        AND MCR.CROSS_REFERENCE = l_item.main_obj_type.item_number
        AND MCR.INVENTORY_ITEM_ID = x_out.inventory_item_id
        AND MCR.END_DATE_ACTIVE IS NULL
         OR MCR.END_DATE_ACTIVE>SYSDATE;
   EXCEPTION
      WHEN NO_DATA_FOUND THEN
        l_count:=0;
   END;

   IF(l_transaction_type = INV_EBI_ITEM_PUB.g_otype_create) AND l_count=0 THEN
     MTL_CROSS_REFERENCES_PKG.insert_row(
     p_source_system_id          => l_source_system_id,
     p_start_date_active         => SYSDATE,
     p_end_date_active           => NULL,
     p_object_version_number     => NULL,
     p_uom_code                  => NULL,
     p_revision_id               => NULL,
     p_epc_gtin_serial           => NULL,
     p_inventory_item_id         => x_out.inventory_item_id,
     p_organization_id           => NULL,
     p_cross_reference_type      => 'SS_ITEM_XREF',
     p_cross_reference           => l_item.main_obj_type.item_number, -- p_source_system_reference,
     p_org_independent_flag      => 'Y',
     p_request_id                => NULL,
     p_attribute1                => NULL,
     p_attribute2                => NULL,
     p_attribute3                => NULL,
     p_attribute4                => NULL,
     p_attribute5                => NULL,
     p_attribute6                => NULL,
     p_attribute7                => NULL,
     p_attribute8                => NULL,
     p_attribute9                => NULL,
     p_attribute10               => NULL,
     p_attribute11               => NULL,
     p_attribute12               => NULL,
     p_attribute13               => NULL,
     p_attribute14               => NULL,
     p_attribute15               => NULL,
     p_attribute_category        => NULL,
     p_description               => l_item.main_obj_type.description,
     p_creation_date             => SYSDATE,
     p_created_by                => FND_GLOBAL.user_id,
     p_last_update_date          => SYSDATE,
     p_last_updated_by           => FND_GLOBAL.user_id,
     p_last_update_login         => FND_GLOBAL.login_id,
     p_program_application_id    => NULL,
     p_program_id                => NULL,
     p_program_update_date       => SYSDATE,
     x_cross_reference_id        => l_xref_id);
  END IF;
  IF FND_API.to_boolean( p_commit ) THEN
    COMMIT;
  END IF;
  INV_EBI_UTIL.debug_line('STEP: 40 '||'END INSIDE INV_EBI_ITEM_HELPER.process_item_pvt ');
 EXCEPTION
   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO inv_ebi_pvt_item_save_pnt;
     x_out.output_status.return_status :=  FND_API.g_ret_sts_error;
    IF(x_out.output_status.msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count   => x_out.output_status.msg_count
        ,p_data    => x_out.output_status.msg_data
     );
   END IF;
   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO inv_ebi_pvt_item_save_pnt;
     x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
    IF(x_out.output_status.msg_data IS NULL) THEN
       fnd_msg_pub.count_and_get(
         p_encoded => fnd_api.g_false
        ,p_count   => x_out.output_status.msg_count
        ,p_data    => x_out.output_status.msg_data
      );
   END IF;
   WHEN OTHERS THEN
     ROLLBACK TO inv_ebi_pvt_item_save_pnt;
     x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
     IF (x_out.output_status.msg_data IS NOT NULL) THEN
       x_out.output_status.msg_data      :=  x_out.output_status.msg_data ||' -> INV_EBI_ITEM_HELPER.process_item_pvt ';
     ELSE
       x_out.output_status.msg_data      :=  SQLERRM||' INV_EBI_ITEM_HELPER.process_item_pvt ';
     END IF;
 END process_item_pvt;
/************************************************************************************
 --      API name        : process_item_uda
 --      Type            : Public
 --      Function        :
 --
************************************************************************************/
 PROCEDURE process_item_uda (
    p_api_version            IN      NUMBER DEFAULT 1.0
   ,p_inventory_item_id      IN      NUMBER
   ,p_organization_id        IN      NUMBER
   ,p_item_catalog_group_id  IN      NUMBER   DEFAULT NULL
   ,p_revision_id            IN      NUMBER   DEFAULT NULL
   ,p_revision_code          IN      VARCHAR2 DEFAULT NULL
   ,p_uda_input_obj          IN      inv_ebi_uda_input_obj
   ,p_commit                 IN      VARCHAR2  := fnd_api.g_false
   ,x_uda_output_obj         OUT     NOCOPY  inv_ebi_item_output_obj
 )
 IS
   l_uda_out                inv_ebi_uda_output_obj;
   l_attributes_row_table   ego_user_attr_row_table;
   l_attributes_data_table  ego_user_attr_data_table;
   l_attributes_row_obj     ego_user_attr_row_obj;
   l_transaction_type       VARCHAR2(20);
   l_data_level             VARCHAR2(25);
   l_revision_id            NUMBER;
   l_output_status          inv_ebi_output_status;
 BEGIN
   SAVEPOINT inv_ebi_item_uda_save_pnt;
   l_uda_out         := inv_ebi_uda_output_obj(NULL,NULL);
   l_output_status   := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_uda_output_obj  := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,l_uda_out,NULL,NULL,NULL,NULL,NULL);
   INV_EBI_UTIL.transform_uda (
     p_uda_input_obj          => p_uda_input_obj
    ,x_attributes_row_table   => l_attributes_row_table
    ,x_attributes_data_table  => l_attributes_data_table
    ,x_return_status          => x_uda_output_obj.output_status.return_status
    ,x_msg_count              => x_uda_output_obj.output_status.msg_count
    ,x_msg_data               => x_uda_output_obj.output_status.msg_data
   );

   IF (x_uda_output_obj.output_status.return_status <> FND_API.g_ret_sts_success) THEN
     RAISE  FND_API.g_exc_unexpected_error;
   END IF;
   FOR i in 1..l_attributes_row_table.COUNT
   LOOP
     l_attributes_row_obj    :=  l_attributes_row_table(i);
     IF(l_attributes_row_table(i).attr_group_id IS NOT NULL AND p_item_catalog_group_id IS NOT NULL ) THEN
       SELECT data_level_int_name INTO l_data_level
       FROM ego_obj_attr_grp_assocs_v
       WHERE attr_group_id = l_attributes_row_table(i).attr_group_id
       AND classification_code = TO_CHAR(p_item_catalog_group_id);
     END IF;
     IF (l_data_level = INV_EBI_ITEM_PUB.g_data_level_item_rev ) THEN

       IF p_revision_code IS NOT NULL AND p_revision_code <> fnd_api.g_miss_char THEN
         SELECT revision_id INTO l_revision_id
         FROM mtl_item_revisions
         WHERE inventory_item_id = p_inventory_item_id
         AND organization_id = p_organization_id
         AND revision = p_revision_code;
       ELSE
         FND_MESSAGE.set_name('INV','INV_EBI_ITEM_REVISION_CODE_NULL');
         FND_MSG_PUB.add;
         RAISE  FND_API.g_exc_error;
       END IF;
     ELSE
       l_revision_id := l_attributes_row_obj.data_level_1;
     END IF;
     IF(l_attributes_row_table(i).transaction_type IS NULL) THEN
       l_transaction_type   :=  ego_user_attrs_data_pvt.g_sync_mode;
     ELSE
       l_transaction_type   :=  l_attributes_row_table(i).transaction_type;
     END IF;
     l_attributes_row_obj := EGO_USER_ATTRS_DATA_PUB.build_attr_group_row_object(
                              p_row_identifier      => i
                             ,p_attr_group_id       => l_attributes_row_obj.attr_group_id
                             ,p_attr_group_app_id   => l_attributes_row_obj.attr_group_app_id
                             ,p_attr_group_type     => l_attributes_row_obj.attr_group_type
                             ,p_attr_group_name     => l_attributes_row_obj.attr_group_name
                             ,p_data_level          => l_data_level
                             ,p_data_level_1        => l_revision_id
                             ,p_data_level_2        => l_attributes_row_obj.data_level_2
                             ,p_data_level_3        => l_attributes_row_obj.data_level_3
                             ,p_data_level_4        => l_attributes_row_obj.data_level_4
                             ,p_data_level_5        => l_attributes_row_obj.data_level_5
                             ,p_transaction_type    => l_transaction_type
                            );
     l_attributes_row_table(i)  := l_attributes_row_obj;
   END LOOP;
   EGO_ITEM_PUB.process_user_attrs_for_item(
     p_api_version               => p_api_version
    ,p_inventory_item_id         => p_inventory_item_id
    ,p_organization_id           => p_organization_id
    ,p_attributes_row_table      => l_attributes_row_table
    ,p_attributes_data_table     => l_attributes_data_table
    ,p_entity_id                 => p_uda_input_obj.entity_id
    ,p_entity_index              => p_uda_input_obj.entity_index
    ,p_entity_code               => p_uda_input_obj.entity_code
    ,p_debug_level               => p_uda_input_obj.debug_level
    ,p_init_error_handler        => p_uda_input_obj.init_error_handler
    ,p_write_to_concurrent_log   => p_uda_input_obj.write_to_concurrent_log
    ,p_init_fnd_msg_list         => p_uda_input_obj.init_fnd_msg_list
    ,p_log_errors                => p_uda_input_obj.log_errors
    ,p_add_errors_to_fnd_stack   => p_uda_input_obj.add_errors_to_fnd_stack
    ,p_commit                    => FND_API.g_false
    ,x_failed_row_id_list        => x_uda_output_obj.uda_output.failed_row_id_list
    ,x_return_status             => x_uda_output_obj.output_status.return_status
    ,x_errorcode                 => x_uda_output_obj.uda_output.errorcode
    ,x_msg_count                 => x_uda_output_obj.output_status.msg_count
    ,x_msg_data                  => x_uda_output_obj.output_status.msg_data
   );

   IF (x_uda_output_obj.output_status.return_status  <> FND_API.g_ret_sts_success) THEN
     RAISE  FND_API.g_exc_unexpected_error;
   END IF;
   IF FND_API.to_boolean(p_commit) THEN
     COMMIT;
   END IF;
 EXCEPTION
   WHEN FND_API.g_exc_error THEN
     ROLLBACK TO inv_ebi_item_uda_save_pnt;
     x_uda_output_obj.output_status.return_status :=  FND_API.g_ret_sts_error;
     IF(x_uda_output_obj.output_status.msg_data IS NULL) THEN
       FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_uda_output_obj.output_status.msg_count
        ,p_data    => x_uda_output_obj.output_status.msg_data
     );
    END IF;
   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO inv_ebi_item_uda_save_pnt;
     x_uda_output_obj.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
     IF(x_uda_output_obj.output_status.msg_data IS NULL) THEN
       FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count   => x_uda_output_obj.output_status.msg_count
        ,p_data    => x_uda_output_obj.output_status.msg_data
      );
     END IF;
   WHEN OTHERS THEN
     ROLLBACK TO inv_ebi_item_uda_save_pnt;
     x_uda_output_obj.output_status.return_status := FND_API.g_ret_sts_unexp_error;
     IF (x_uda_output_obj.output_status.msg_data IS NOT NULL) THEN
        x_uda_output_obj.output_status.msg_data  :=  x_uda_output_obj.output_status.msg_data ||' -> INV_EBI_ITEM_HELPER.process_item_uda ';
     ELSE
        x_uda_output_obj.output_status.msg_data  :=  SQLERRM||' at INV_EBI_ITEM_HELPER.process_item_uda ';
     END IF;
 END process_item_uda;
  /************************************************************************************
  --      API name        : process_org_id_assignments
  --      Type            : Public
  --      Function        :
  --  ************************************************************************************/
  PROCEDURE process_org_id_assignments(
    p_init_msg_list      IN          VARCHAR2
   ,p_commit             IN          VARCHAR2 := fnd_api.g_false
   ,p_inventory_item_id  IN          NUMBER
   ,p_item_number        IN          VARCHAR2
   ,p_org_id_tbl         IN          inv_ebi_org_tbl
   ,x_out                OUT NOCOPY  inv_ebi_item_output_obj
  )
  IS
    l_item_org_assignment_rec    ego_item_pub.item_org_assignment_rec_type;
    l_item_org_assignment_tbl    ego_item_pub.item_org_assignment_tbl_type;
    l_output_status              inv_ebi_output_status;
    l_api_version                NUMBER:=1.0;
    l_item_org_tbl_count         NUMBER := 1;
  BEGIN
    SAVEPOINT inv_ebi_org_id_save_pnt;
    INV_EBI_UTIL.debug_line('STEP: 10 '||'START INSIDE INV_EBI_ITEM_HELPER.process_org_id_assignments ');
    l_output_status  := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
    x_out            := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);
    IF p_org_id_tbl.COUNT > 0 THEN
      FOR i IN 1..p_org_id_tbl.COUNT LOOP
        l_item_org_assignment_rec.inventory_item_id := p_inventory_item_id;
        l_item_org_assignment_rec.item_number       := p_item_number;
        l_item_org_assignment_rec.organization_id   := p_org_id_tbl(i).org_id;
        l_item_org_assignment_tbl(i)                := l_item_org_assignment_rec;
      END LOOP;
      INV_EBI_UTIL.debug_line('STEP: 20 '||'START CALLING EGO_ITEM_PUB.process_item_org_assignments ');
      EGO_ITEM_PUB.process_item_org_assignments(
        p_api_version                  => l_api_version --don't pass as of now
       ,p_init_msg_list                => p_init_msg_list
       ,p_commit                       => FND_API.g_false
       ,p_item_org_assignment_tbl      => l_item_org_assignment_tbl
       ,x_return_status                => x_out.output_status.return_status
       ,x_msg_count                    => x_out.output_status.msg_count
      );
      INV_EBI_UTIL.debug_line('STEP: 30 '||'END CALLING EGO_ITEM_PUB.process_item_org_assignments ');
      IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
        RAISE  FND_API.g_exc_unexpected_error;
      END IF;
    END IF;
    IF FND_API.to_boolean( p_commit ) THEN
       COMMIT;
    END IF;
    INV_EBI_UTIL.debug_line('STEP: 40 '||'END INSIDE INV_EBI_ITEM_HELPER.process_org_id_assignments ');
  EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO inv_ebi_org_id_save_pnt;
      x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
      IF(x_out.output_status.msg_data IS NULL) THEN
        FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_out.output_status.msg_count
         ,p_data    => x_out.output_status.msg_data
        );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO inv_ebi_org_id_save_pnt;
      x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
      IF (x_out.output_status.msg_data IS NOT NULL) THEN
        x_out.output_status.msg_data  :=  x_out.output_status.msg_data||' -> INV_EBI_ITEM_HELPER.process_org_id_assignments ';
      ELSE
        x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_ITEM_HELPER.process_org_id_assignments ';
      END IF;
  END process_org_id_assignments;
  /************************************************************************************
  --      API name        : process_category_assignments
  --      Type            : Public
  --      Function        :
  --
  ************************************************************************************/
  PROCEDURE process_category_assignments(
    p_api_version         IN           NUMBER  DEFAULT 1.0
   ,p_init_msg_list       IN           VARCHAR2
   ,p_commit              IN           VARCHAR2 := fnd_api.g_false
   ,p_inventory_item_id   IN           NUMBER
   ,p_organization_id     IN           NUMBER
   ,p_category_id_tbl         IN       inv_ebi_category_obj_tbl_type
   ,x_out                 OUT NOCOPY   inv_ebi_item_output_obj
  )
  IS
    l_transaction_type  VARCHAR2(20):=ego_item_pub.g_ttype_create;
    l_category_output   inv_ebi_category_output_obj;
    l_output_status     inv_ebi_output_status;
  BEGIN
    SAVEPOINT inv_ebi_cat_id_save_pnt;
    INV_EBI_UTIL.debug_line('STEP: 10 '||'START INSIDE INV_EBI_ITEM_HELPER.process_category_assignments ');
    l_category_output :=  inv_ebi_category_output_obj(NULL);
    l_output_status  := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
    x_out            := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,l_category_output,NULL,NULL,NULL,NULL);
    INV_EBI_UTIL.debug_line('STEP: 20 '||'START CALLING EGO_ITEM_PUB.process_item_cat_assignment ');
      FOR i IN 1..p_category_id_tbl.COUNT LOOP
        EGO_ITEM_PUB.process_item_cat_assignment(
          p_api_version         => p_api_version
         ,p_init_msg_list       => p_init_msg_list
         ,p_commit              => FND_API.g_false
         ,p_category_id         => p_category_id_tbl(i).cat_id
         ,p_category_set_id     => p_category_id_tbl(i).cat_set_id
         ,p_inventory_item_id   => p_inventory_item_id
         ,p_organization_id     => p_organization_id
         ,p_transaction_type    => l_transaction_type
         ,x_return_status       => x_out.output_status.return_status
         ,x_errorcode           => x_out.category_output.error_code
         ,x_msg_count           => x_out.output_status.msg_count
         ,x_msg_data            => x_out.output_status.msg_data
        );
      END LOOP;
    INV_EBI_UTIL.debug_line('STEP: 30 '||'END CALLING EGO_ITEM_PUB.process_item_cat_assignment ');
      IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
        RAISE  FND_API.g_exc_unexpected_error;
      END IF;
    IF FND_API.to_boolean( p_commit ) THEN
      COMMIT;
    END IF;
    INV_EBI_UTIL.debug_line('STEP: 40 '||'END INSIDE INV_EBI_ITEM_HELPER.process_category_assignments ');
  EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO inv_ebi_cat_id_save_pnt;
      x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
      IF(x_out.output_status.msg_data IS NULL) THEN
        FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_out.output_status.msg_count
         ,p_data    => x_out.output_status.msg_data
        );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO inv_ebi_cat_id_save_pnt;
      x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
      IF (x_out.output_status.msg_data IS NOT NULL) THEN
        x_out.output_status.msg_data      :=  x_out.output_status.msg_data ||' -> INV_EBI_ITEM_HELPER.process_category_assignments ';
      ELSE
        x_out.output_status.msg_data      :=  SQLERRM||' INV_EBI_ITEM_HELPER.process_category_assignments ';
      END IF;
  END process_category_assignments;
   /************************************************************************************
   --     API name        : process_part_num_association
   --     Type            : Public
   --     Function        :
   --     This API is used to
   --
  ************************************************************************************/
   PROCEDURE process_part_num_association(
     p_commit                 IN   VARCHAR2 := fnd_api.g_false
    ,p_organization_id        IN   NUMBER
    ,p_inventory_item_id      IN   NUMBER
    ,p_mfg_part_obj           IN   inv_ebi_manufacturer_part_obj
    ,x_out                    OUT  NOCOPY inv_ebi_item_output_obj
  )
  IS
    l_count                      NUMBER := 0;
    l_rowid                      VARCHAR2(100);
    l_manufacturer_id            mtl_mfg_part_numbers.manufacturer_id%TYPE;
    l_mfg_part_num               mtl_mfg_part_numbers.mfg_part_num%TYPE;
    l_inventory_item_id          mtl_mfg_part_numbers.inventory_item_id%TYPE;
    l_organization_id            mtl_mfg_part_numbers.organization_id%TYPE;
    l_description                mtl_mfg_part_numbers.description%TYPE;
    l_attribute_category         mtl_mfg_part_numbers.attribute_category%TYPE;
    l_attribute1                 mtl_mfg_part_numbers.attribute1%TYPE;
    l_attribute2                 mtl_mfg_part_numbers.attribute2%TYPE;
    l_attribute3                 mtl_mfg_part_numbers.attribute3%TYPE;
    l_attribute4                 mtl_mfg_part_numbers.attribute4%TYPE;
    l_attribute5                 mtl_mfg_part_numbers.attribute5%TYPE;
    l_attribute6                 mtl_mfg_part_numbers.attribute6%TYPE;
    l_attribute7                 mtl_mfg_part_numbers.attribute7%TYPE;
    l_attribute8                 mtl_mfg_part_numbers.attribute8%TYPE;
    l_attribute9                 mtl_mfg_part_numbers.attribute9%TYPE;
    l_attribute10                mtl_mfg_part_numbers.attribute10%TYPE;
    l_attribute11                mtl_mfg_part_numbers.attribute11%TYPE;
    l_attribute12                mtl_mfg_part_numbers.attribute12%TYPE;
    l_attribute13                mtl_mfg_part_numbers.attribute13%TYPE;
    l_attribute14                mtl_mfg_part_numbers.attribute14%TYPE;
    l_attribute15                mtl_mfg_part_numbers.attribute15%TYPE;
    l_output_status              inv_ebi_output_status;
    CURSOR c_mfg_part_num(
              p_manufacturer_id    IN  NUMBER
             ,p_mfg_part_num       IN  VARCHAR2
             ,P_organization_id    IN  NUMBER
             ,p_inventory_item_id  IN  NUMBER
            ) IS
      SELECT
         rowid
        ,manufacturer_id
        ,mfg_part_num
        ,inventory_item_id
        ,organization_id
        ,description
        ,attribute_category
        ,attribute1
        ,attribute2
        ,attribute3
        ,attribute4
        ,attribute5
        ,attribute6
        ,attribute7
        ,attribute8
        ,attribute9
        ,attribute10
        ,attribute11
        ,attribute12
        ,attribute13
        ,attribute14
        ,attribute15
      FROM mtl_mfg_part_numbers
      WHERE manufacturer_id = p_manufacturer_id
      AND mfg_part_num = p_mfg_part_num
      AND organization_id = p_organization_id
      AND inventory_item_id = p_inventory_item_id;
  BEGIN
    SAVEPOINT inv_ebi_part_num_save_pnt;
    INV_EBI_UTIL.debug_line('STEP: 10 '||'START INSIDE INV_EBI_ITEM_HELPER.process_part_num_association ');
    l_output_status  := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
    x_out            := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);
    IF p_mfg_part_obj.mfg_part_num IS NOT NULL THEN
      OPEN c_mfg_part_num(
         p_manufacturer_id    =>  p_mfg_part_obj.manufacturer_id
        ,p_mfg_part_num       =>  p_mfg_part_obj.mfg_part_num
        ,P_organization_id    =>  p_organization_id
        ,p_inventory_item_id  =>  p_inventory_item_id
      );
      FETCH c_mfg_part_num INTO
         l_rowid
        ,l_manufacturer_id
        ,l_mfg_part_num
        ,l_inventory_item_id
        ,l_organization_id
        ,l_description
        ,l_attribute_category
        ,l_attribute1
        ,l_attribute2
        ,l_attribute3
        ,l_attribute4
        ,l_attribute5
        ,l_attribute6
        ,l_attribute7
        ,l_attribute8
        ,l_attribute9
        ,l_attribute10
        ,l_attribute11
        ,l_attribute12
        ,l_attribute13
        ,l_attribute14
        ,l_attribute15 ;
      IF (p_inventory_item_id <>  FND_API.G_MISS_NUM ) THEN
        l_inventory_item_id := p_inventory_item_id;
      END IF;
      IF (p_organization_id <>  FND_API.G_MISS_NUM ) THEN
         l_organization_id := p_organization_id;
      END IF;
      IF (p_mfg_part_obj.description <>  FND_API.G_MISS_CHAR) THEN
         l_description := p_mfg_part_obj.description;
      END IF;
      IF (p_mfg_part_obj.attribute_category <>  FND_API.G_MISS_CHAR) THEN
        l_attribute_category := p_mfg_part_obj.attribute_category;
      END IF;
      IF (p_mfg_part_obj.attribute1 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute1 := p_mfg_part_obj.attribute1;
      END IF;
      IF (p_mfg_part_obj.attribute2 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute2 := p_mfg_part_obj.attribute2;
      END IF;
      IF (p_mfg_part_obj.attribute3 <>  FND_API.G_MISS_CHAR ) THEN
          l_attribute3 := p_mfg_part_obj.attribute3;
      END IF;
      IF (p_mfg_part_obj.attribute4 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute4 := p_mfg_part_obj.attribute4;
      END IF;
      IF (p_mfg_part_obj.attribute5 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute5 := p_mfg_part_obj.attribute5;
      END IF;
      IF (p_mfg_part_obj.attribute6 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute6 := p_mfg_part_obj.attribute6;
      END IF;
      IF (p_mfg_part_obj.attribute7 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute7 := p_mfg_part_obj.attribute7;
      END IF;
      IF (p_mfg_part_obj.attribute8 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute8 := p_mfg_part_obj.attribute8;
      END IF;
      IF (p_mfg_part_obj.attribute9 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute9 := p_mfg_part_obj.attribute9;
      END IF;
      IF (p_mfg_part_obj.attribute10 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute10 := p_mfg_part_obj.attribute10;
      END IF;
      IF (p_mfg_part_obj.attribute11 <>  FND_API.G_MISS_CHAR) THEN
        l_attribute11 := p_mfg_part_obj.attribute11;
      END IF;
      IF (p_mfg_part_obj.attribute12 <>  FND_API.G_MISS_CHAR ) THEN
          l_attribute12 := p_mfg_part_obj.attribute12;
      END IF;
      IF (p_mfg_part_obj.attribute13 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute13 := p_mfg_part_obj.attribute13;
      END IF;
      IF (p_mfg_part_obj.attribute14 <>  FND_API.G_MISS_CHAR) THEN
          l_attribute14 := p_mfg_part_obj.attribute14;
      END IF;
      IF (p_mfg_part_obj.attribute15 <>  FND_API.G_MISS_CHAR) THEN
        l_attribute15 := p_mfg_part_obj.attribute15;
      END IF;

      IF UPPER(p_mfg_part_obj.transaction_type) = ENG_GLOBALS.G_OPR_CREATE THEN
      INV_EBI_UTIL.debug_line('STEP: 20 '||'START CALLING MTL_MFG_PART_NUMBERS_PKG.insert_row ');
        MTL_MFG_PART_NUMBERS_PKG.insert_row(
           x_rowid               =>        l_rowid
          ,x_manufacturer_id     =>        p_mfg_part_obj.manufacturer_id
          ,x_mfg_part_num        =>        p_mfg_part_obj.mfg_part_num
          ,x_inventory_item_id   =>        p_inventory_item_id
          ,x_last_update_date    =>        SYSDATE
          ,x_last_updated_by     =>        fnd_global.user_id
          ,x_creation_date       =>        SYSDATE
          ,x_created_by          =>        fnd_global.user_id
          ,x_last_update_login   =>        fnd_global.login_id
          ,x_organization_id     =>        p_organization_id
          ,x_description         =>        p_mfg_part_obj.description
          ,x_attribute_category  =>        p_mfg_part_obj.attribute_category
          ,x_attribute1          =>        p_mfg_part_obj.attribute1
          ,x_attribute2          =>        p_mfg_part_obj.attribute2
          ,x_attribute3          =>        p_mfg_part_obj.attribute3
          ,x_attribute4          =>        p_mfg_part_obj.attribute4
          ,x_attribute5          =>        p_mfg_part_obj.attribute5
          ,x_attribute6          =>        p_mfg_part_obj.attribute6
          ,x_attribute7          =>        p_mfg_part_obj.attribute7
          ,x_attribute8          =>        p_mfg_part_obj.attribute8
          ,x_attribute9          =>        p_mfg_part_obj.attribute9
          ,x_attribute10         =>        p_mfg_part_obj.attribute10
          ,x_attribute11         =>        p_mfg_part_obj.attribute11
          ,x_attribute12         =>        p_mfg_part_obj.attribute12
          ,x_attribute13         =>        p_mfg_part_obj.attribute13
          ,x_attribute14         =>        p_mfg_part_obj.attribute14
          ,x_attribute15         =>        p_mfg_part_obj.attribute15
         );
      INV_EBI_UTIL.debug_line('STEP: 30 '||'END CALLING MTL_MFG_PART_NUMBERS_PKG.insert_row ');
      ELSIF UPPER(p_mfg_part_obj.transaction_type) = ENG_GLOBALS.G_OPR_UPDATE  THEN
      INV_EBI_UTIL.debug_line('STEP: 40 '||'START CALLING MTL_MFG_PART_NUMBERS_PKG.update_row ');
        MTL_MFG_PART_NUMBERS_PKG.update_row(
           x_rowid               =>         l_rowid
          ,x_manufacturer_id     =>         l_manufacturer_id
          ,x_mfg_part_num        =>         l_mfg_part_num
          ,x_inventory_item_id   =>         l_inventory_item_id
          ,x_last_update_date    =>         SYSDATE
          ,x_last_updated_by     =>         fnd_global.user_id
          ,x_last_update_login   =>         fnd_global.login_id
          ,x_organization_id     =>         l_organization_id
          ,x_description         =>         l_description
          ,x_attribute_category  =>         l_attribute_category
          ,x_attribute1          =>         l_attribute1
          ,x_attribute2          =>         l_attribute2
          ,x_attribute3          =>         l_attribute3
          ,x_attribute4          =>         l_attribute4
          ,x_attribute5          =>         l_attribute5
          ,x_attribute6          =>         l_attribute6
          ,x_attribute7          =>         l_attribute7
          ,x_attribute8          =>         l_attribute8
          ,x_attribute9          =>         l_attribute9
          ,x_attribute10         =>         l_attribute10
          ,x_attribute11         =>         l_attribute11
          ,x_attribute12         =>         l_attribute12
          ,x_attribute13         =>         l_attribute13
          ,x_attribute14         =>         l_attribute14
          ,x_attribute15         =>         l_attribute15
        );
      INV_EBI_UTIL.debug_line('STEP: 50 '||'END CALLING MTL_MFG_PART_NUMBERS_PKG.update_row ');
      ELSIF UPPER(p_mfg_part_obj.transaction_type) = ENG_GLOBALS.G_OPR_DELETE THEN
      INV_EBI_UTIL.debug_line('STEP: 60 '||'START CALLING MTL_MFG_PART_NUMBERS_PKG.delete_row ');
        MTL_MFG_PART_NUMBERS_PKG.Delete_Row(l_Rowid);
      INV_EBI_UTIL.debug_line('STEP: 70 '||'END CALLING MTL_MFG_PART_NUMBERS_PKG.delete_row ');
      ELSIF (p_mfg_part_obj.transaction_type IS NULL) THEN
        IF (c_mfg_part_num%NOTFOUND) THEN
      INV_EBI_UTIL.debug_line('STEP: 80 '||'START CALLING Sync Mode MTL_MFG_PART_NUMBERS_PKG.insert_row ');
          MTL_MFG_PART_NUMBERS_PKG.insert_row(
             x_rowid               =>        l_rowid
            ,x_manufacturer_id     =>        p_mfg_part_obj.manufacturer_id
            ,x_mfg_part_num        =>        p_mfg_part_obj.mfg_part_num
            ,x_inventory_item_id   =>        p_inventory_item_id
            ,x_last_update_date    =>        SYSDATE
            ,x_last_updated_by     =>        fnd_global.user_id
            ,x_creation_date       =>        SYSDATE
            ,x_created_by          =>        fnd_global.user_id
            ,x_last_update_login   =>        fnd_global.login_id
            ,x_organization_id     =>        p_organization_id
            ,x_description         =>        p_mfg_part_obj.description
            ,x_attribute_category  =>        p_mfg_part_obj.attribute_category
            ,x_attribute1          =>        p_mfg_part_obj.attribute1
            ,x_attribute2          =>        p_mfg_part_obj.attribute2
            ,x_attribute3          =>        p_mfg_part_obj.attribute3
            ,x_attribute4          =>        p_mfg_part_obj.attribute4
            ,x_attribute5          =>        p_mfg_part_obj.attribute5
            ,x_attribute6          =>        p_mfg_part_obj.attribute6
            ,x_attribute7          =>        p_mfg_part_obj.attribute7
            ,x_attribute8          =>        p_mfg_part_obj.attribute8
            ,x_attribute9          =>        p_mfg_part_obj.attribute9
            ,x_attribute10         =>        p_mfg_part_obj.attribute10
            ,x_attribute11         =>        p_mfg_part_obj.attribute11
            ,x_attribute12         =>        p_mfg_part_obj.attribute12
            ,x_attribute13         =>        p_mfg_part_obj.attribute13
            ,x_attribute14         =>        p_mfg_part_obj.attribute14
            ,x_attribute15         =>        p_mfg_part_obj.attribute15
           );
        INV_EBI_UTIL.debug_line('STEP: 90 '||'END CALLING Sync Mode MTL_MFG_PART_NUMBERS_PKG.insert_row ');
        ELSE
        INV_EBI_UTIL.debug_line('STEP: 100 '||'START CALLING Sync Mode MTL_MFG_PART_NUMBERS_PKG.update_row ');
          MTL_MFG_PART_NUMBERS_PKG.update_row(
             x_rowid               =>         l_rowid
            ,x_manufacturer_id     =>         l_manufacturer_id
            ,x_mfg_part_num        =>         l_mfg_part_num
            ,x_inventory_item_id   =>         l_inventory_item_id
            ,x_last_update_date    =>         SYSDATE
            ,x_last_updated_by     =>         fnd_global.user_id
            ,x_last_update_login   =>         fnd_global.login_id
            ,x_organization_id     =>         l_organization_id
            ,x_description         =>         l_description
            ,x_attribute_category  =>         l_attribute_category
            ,x_attribute1          =>         l_attribute1
            ,x_attribute2          =>         l_attribute2
            ,x_attribute3          =>         l_attribute3
            ,x_attribute4          =>         l_attribute4
            ,x_attribute5          =>         l_attribute5
            ,x_attribute6          =>         l_attribute6
            ,x_attribute7          =>         l_attribute7
            ,x_attribute8          =>         l_attribute8
            ,x_attribute9          =>         l_attribute9
            ,x_attribute10         =>         l_attribute10
            ,x_attribute11         =>         l_attribute11
            ,x_attribute12         =>         l_attribute12
            ,x_attribute13         =>         l_attribute13
            ,x_attribute14         =>         l_attribute14
            ,x_attribute15         =>         l_attribute15
          );
        INV_EBI_UTIL.debug_line('STEP: 110 '||'END CALLING Sync Mode MTL_MFG_PART_NUMBERS_PKG.update_row ');
        END IF;
      END IF;
      CLOSE c_mfg_part_num;
    ELSE
      FND_MESSAGE.set_name('INV_EBI','INV_EBI_PART_NUM_NULL');
      FND_MESSAGE.set_token('PART_NUM', p_mfg_part_obj.mfg_part_num);
      FND_MSG_PUB.add;
      RAISE  FND_API.g_exc_error;
    END IF;
    IF FND_API.to_boolean( p_commit ) THEN
      COMMIT;
    END IF;
  INV_EBI_UTIL.debug_line('STEP: 120 '||'END INSIDE INV_EBI_ITEM_HELPER.process_part_num_association ');
  EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO inv_ebi_part_num_save_pnt;
      x_out.output_status.return_status :=  FND_API.g_ret_sts_error;
      IF(x_out.output_status.msg_data IS NULL) THEN
        FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_out.output_status.msg_count
         ,p_data    => x_out.output_status.msg_data
       );
      END IF;
    WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO inv_ebi_part_num_save_pnt;
      x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
      IF(x_out.output_status.msg_data IS NULL) THEN
        FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_out.output_status.msg_count
         ,p_data    => x_out.output_status.msg_data
        );
      END IF;
    WHEN OTHERS THEN
      ROLLBACK TO inv_ebi_part_num_save_pnt;
      x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
      IF (x_out.output_status.msg_data IS NOT NULL) THEN
        x_out.output_status.msg_data  :=  x_out.output_status.msg_data||' -> INV_EBI_ITEM_HELPER.process_part_num_association ';
      ELSE
        x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_ITEM_HELPER.process_part_num_association ';
      END IF;
  END process_part_num_association;

/************************************************************************************
--      API name        : sync_item
--      Type            : Public
--      Function        :
--
  --Should include API calls for Item alternative Catalog ,create Manufacture,Manufacture part
  --Template Ids??
  --Check if Organization Ids are there and how assignments to multiple orgs have to be handled
************************************************************************************/
Procedure sync_item (
  p_commit           IN  VARCHAR2 := FND_API.g_false
 ,p_operation        IN  VARCHAR2
 ,p_item             IN  inv_ebi_item_obj
 ,x_out              OUT NOCOPY inv_ebi_item_output_obj
) IS
  l_out                   inv_ebi_item_output_obj;
  l_api_version           NUMBER:=1.0;
  l_inventory_item_id     NUMBER;
  l_organization_id       NUMBER;
  l_organization_code     VARCHAR2(3);
  l_item_number           VARCHAR2(2000);
  l_output_status         inv_ebi_output_status;
  l_category_output       inv_ebi_category_output_obj;

  l_mfg_part_num_obj      inv_ebi_manufacturer_part_obj;
  l_master_org_id         NUMBER;
  l_manufacturer_count    NUMBER := 0;
  l_pk_col_name_val_pairs INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
  l_operating_unit       VARCHAR2(240);
  l_operating_unit_id    NUMBER;
  l_description          VARCHAR2(240);
BEGIN
  SAVEPOINT inv_ebi_sync_item_save_pnt;
  l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
  x_out           := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);
  l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();

  --Create or update item
  INV_EBI_UTIL.debug_line('STEP: 10 '||'START INSIDE INV_EBI_ITEM_HELPER.sync_item '||
                          'ORGANIZATION CODE: '||p_item.main_obj_type.organization_code||
                          'Item Number: '||p_item.main_obj_type.item_number
                          );
  INV_EBI_UTIL.debug_line('STEP: 20 '||'START CALLING INV_EBI_ITEM_HELPER.process_item_pvt ');
  process_item_pvt (
    p_item             =>  p_item
   ,p_operation        =>  p_operation
   ,p_commit           =>  FND_API.g_false
   ,x_out              =>  l_out
  );
  INV_EBI_UTIL.debug_line('STEP: 30 '||'END CALLING INV_EBI_ITEM_HELPER.process_item_pvt ');
  IF (l_out.output_status.return_status <> fnd_api.g_ret_sts_success) THEN
    x_out.output_status.msg_data := l_out.output_status.msg_data;
    RAISE  fnd_api.g_exc_unexpected_error;
  END IF;
  l_inventory_item_id  := l_out.inventory_item_id;
  l_organization_id    := l_out.organization_id;
  l_organization_code  := l_out.organization_code;
  l_item_number        := l_out.item_number;
  l_operating_unit     := l_out.operating_unit;
  l_operating_unit_id  := l_out.operating_unit_id;
  l_description        := l_out.description;

  --Assign item to all the orgs sent in the list.
  IF (p_item.org_id_obj_type IS NOT  NULL AND p_item.org_id_obj_type.COUNT > 0) THEN
    INV_EBI_UTIL.debug_line('STEP: 40 '||'START CALLING INV_EBI_ITEM_HELPER.process_org_id_assignments ');
    process_org_id_assignments(
      p_init_msg_list      =>  p_item.main_obj_type.init_msg_list
     ,p_commit             =>  fnd_api.g_false
     ,p_inventory_item_id  =>  l_inventory_item_id
     ,p_item_number        =>  p_item.main_obj_type.item_number
     ,p_org_id_tbl         =>  p_item.org_id_obj_type
     ,x_out                =>  l_out
     );
     INV_EBI_UTIL.debug_line('STEP: 40 '||'END CALLING INV_EBI_ITEM_HELPER.process_org_id_assignments ');
  END IF;
  IF (l_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
    x_out.output_status.msg_data := l_out.output_status.msg_data;
    RAISE  fnd_api.g_exc_unexpected_error;
  END IF;
  --Catalog Category assignment
  IF (p_item.category_id_obj_tbl_type IS NOT NULL AND p_item.category_id_obj_tbl_type.COUNT > 0) THEN
  INV_EBI_UTIL.debug_line('STEP: 50 '||'START CALLING INV_EBI_ITEM_HELPER.process_category_assignments ');
    process_category_assignments(
      p_api_version        =>  l_api_version
     ,p_init_msg_list      =>  p_item.main_obj_type.init_msg_list
     ,p_commit             =>  fnd_api.g_false
     ,p_inventory_item_id  =>  l_inventory_item_id
     ,p_organization_id    =>  p_item.main_obj_type.organization_id
     ,p_category_id_tbl    =>  p_item.category_id_obj_tbl_type
     ,x_out                =>  l_out
    );
  INV_EBI_UTIL.debug_line('STEP: 60 '||'END CALLING INV_EBI_ITEM_HELPER.process_category_assignments ');
 END IF;
 IF (l_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
   x_out.output_status.msg_data := l_out.output_status.msg_data;
   RAISE  fnd_api.g_exc_unexpected_error;
 END IF;
 l_category_output :=  inv_ebi_category_output_obj(l_out.category_output.error_code);
 l_master_org_id  := INV_EBI_UTIL.get_master_organization(
                        p_organization_id  => p_item.main_obj_type.organization_id
                     );

 --Manufacturer Part Num association needs to be done for master org only.
 IF(l_master_org_id = p_item.main_obj_type.organization_id) THEN
   IF (p_item.part_num_obj_tbl_type IS NOT NULL AND p_item.part_num_obj_tbl_type.COUNT > 0) THEN
     INV_EBI_UTIL.debug_line('STEP: 70 '||'START CALLING INV_EBI_ITEM_HELPER.process_part_num_association');
     FOR i IN p_item.part_num_obj_tbl_type.FIRST..p_item.part_num_obj_tbl_type.LAST
     LOOP
       l_mfg_part_num_obj := p_item.part_num_obj_tbl_type(i);
       IF(l_mfg_part_num_obj.manufacturer_id IS NOT NULL AND l_mfg_part_num_obj.manufacturer_id <> fnd_api.g_miss_num) THEN
       SELECT COUNT(1) INTO l_manufacturer_count
       FROM mtl_manufacturers
       WHERE manufacturer_id = l_mfg_part_num_obj.manufacturer_id;
       END IF;
       IF(l_manufacturer_count > 0 ) THEN
        process_part_num_association(
           p_commit                 =>  FND_API.g_false
          ,p_organization_id        =>  p_item.main_obj_type.organization_id
          ,p_inventory_item_id      =>  l_inventory_item_id
          ,p_mfg_part_obj           =>  l_mfg_part_num_obj
          ,x_out                    =>  l_out
         );
       ELSE

         --If manufcaturer does not exist raise exception
         FND_MESSAGE.set_name('INV','INV_EBI_MFG_NOT_EXIST');
         IF l_mfg_part_num_obj.manufacturer_name IS NULL THEN
           l_pk_col_name_val_pairs.EXTEND(1);
           l_pk_col_name_val_pairs(1).name  := 'manufacturer_id';
           l_pk_col_name_val_pairs(1).value := l_mfg_part_num_obj.manufacturer_id;
           l_mfg_part_num_obj.manufacturer_name := id_to_value(
                                                      p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                     ,p_entity_name            => G_MANUFACTURER
                                                    );
           l_pk_col_name_val_pairs.TRIM(1);
         END IF;
         FND_MESSAGE.set_token('MFG_NAME', l_mfg_part_num_obj.manufacturer_name);
         FND_MSG_PUB.add;
         RAISE  FND_API.g_exc_error;
       END IF;
       IF (l_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
          x_out.output_status.msg_data := l_out.output_status.msg_data ;
          RAISE  FND_API.g_exc_unexpected_error;
       END IF;
     END LOOP;
     INV_EBI_UTIL.debug_line('STEP: 80 '||'END CALLING INV_EBI_ITEM_HELPER.process_part_num_association');
    END IF;
  END IF;
   x_out  := inv_ebi_item_output_obj(l_inventory_item_id,l_organization_id,l_organization_code,l_item_number,l_out.output_status,NULL,l_category_output,NULL,l_operating_unit,l_operating_unit_id,l_description);

 IF fnd_api.to_boolean(p_commit) THEN
    COMMIT;
 END IF;
INV_EBI_UTIL.debug_line('STEP: 90 '||'END INSIDE INV_EBI_ITEM_HELPER.sync_item '||
                          'ORGANIZATION CODE: '||p_item.main_obj_type.organization_code||
                          'Item Number: '||p_item.main_obj_type.item_number
                          );
EXCEPTION
  WHEN FND_API.g_exc_error THEN
    ROLLBACK TO inv_ebi_sync_item_save_pnt;
    x_out.output_status.return_status :=  FND_API.g_ret_sts_error;
    IF(x_out.output_status.msg_data IS NULL) THEN
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false
       ,p_count   => x_out.output_status.msg_count
       ,p_data    => x_out.output_status.msg_data
     );
    END IF;
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO inv_ebi_sync_item_save_pnt;
    x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
    IF(x_out.output_status.msg_data IS NULL) THEN
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false
       ,p_count   => x_out.output_status.msg_count
       ,p_data    => x_out.output_status.msg_data
      );
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO inv_ebi_sync_item_save_pnt;
    x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
    IF (x_out.output_status.msg_data IS NOT NULL) THEN
      x_out.output_status.msg_data  :=  l_out.output_status.msg_data ||' -> INV_EBI_ITEM_HELPER.sync_item ';
    ELSE
      x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_ITEM_HELPER.sync_item ';
    END IF;
END sync_item;
/************************************************************************************
--      API name        : get_item_balance
--      Type            : Public
--      Function        :
************************************************************************************/
PROCEDURE get_item_balance(
    p_item_balance_input        IN              inv_ebi_item_bal_input_list
   ,x_item_balance_output       OUT NOCOPY      inv_ebi_item_bal_output_list
   ,x_return_status             OUT NOCOPY      VARCHAR2
   ,x_msg_count                 OUT NOCOPY      NUMBER
   ,x_msg_data                  OUT NOCOPY      VARCHAR2
  )
IS
  l_locator_id                  NUMBER;
  l_cur_index                   NUMBER;
  l_item_bal_output             inv_ebi_item_balance_obj;
  l_item_balance_loc_tbl        inv_ebi_item_bal_loc_tbl;
  l_item_balance_output_tbl     inv_ebi_item_bal_output_tbl;
  l_item_balance_loc_obj        inv_ebi_item_bal_loc_obj;
  l_item_balance_output_obj     inv_ebi_item_bal_output_obj;
  l_is_revision_control         BOOLEAN;
  l_is_lot_control              BOOLEAN;
  l_is_serial_control           BOOLEAN;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(1000);
  l_qty_on_hand                 NUMBER;
  l_res_qty_on_hand             NUMBER;
  l_qty_reserved                NUMBER;
  l_qty_suggested               NUMBER;
  l_avail_to_transact           NUMBER;
  l_avail_to_reserve            NUMBER;
  l_sec_qty_on_hand             NUMBER;
  l_sec_res_qty_on_hand         NUMBER;
  l_sec_qty_reserved            NUMBER;
  l_sec_qty_suggested           NUMBER;
  l_sec_avail_to_transact       NUMBER;
  l_sec_avail_to_reserve        NUMBER;
  l_organization_code           VARCHAR2(3000);
  l_item_name                   VARCHAR2(30);
  l_pk_col_name_val_pairs       INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
  CURSOR c_locator_id(p_inventory_item_id IN NUMBER, p_organization_id IN NUMBER,
                      p_revision IN VARCHAR2, p_subinventory_code IN VARCHAR2
                     )IS
  SELECT
    DISTINCT(locator_id)
  FROM
    mtl_onhand_locator_v
  WHERE
    locator_id IS NOT NULL AND
    inventory_item_id = p_inventory_item_id AND
    organization_id = p_organization_id AND
    (revision IS NOT NULL OR (revision = p_revision)) AND
    (subinventory_code IS NOT NULL OR (subinventory_code = p_subinventory_code));
BEGIN
  x_return_status := fnd_api.g_ret_sts_success;
  l_item_balance_output_tbl := inv_ebi_item_bal_output_tbl();
  Inv_Quantity_Tree_Pub.clear_quantity_cache;
  IF p_item_balance_input.item_input_table IS NOT NULL THEN
    FOR i IN p_item_balance_input.item_input_table.FIRST..p_item_balance_input.item_input_table.LAST LOOP
      BEGIN
        l_item_balance_output_tbl.EXTEND();
        IF p_item_balance_input.item_input_table(i).is_revision_control = FND_API.G_TRUE THEN
         l_is_revision_control := TRUE;
        ELSE
         l_is_revision_control := FALSE;
        END IF;
        IF p_item_balance_input.item_input_table(i).is_lot_control = FND_API.G_TRUE THEN
          l_is_lot_control := TRUE;
        ELSE
          l_is_lot_control := FALSE;
        END IF;
        IF p_item_balance_input.item_input_table(i).is_serial_control = FND_API.G_TRUE THEN
          l_is_serial_control := TRUE;
        ELSE
          l_is_serial_control := FALSE;
        END IF;
        INV_QUANTITY_TREE_PUB.query_quantities(
          p_api_version_number                  => p_item_balance_input.item_input_table(i).api_version_number
         ,p_init_msg_lst                        => p_item_balance_input.item_input_table(i).init_msg_lst
         ,p_organization_id                     => p_item_balance_input.item_input_table(i).organization_id
         ,p_inventory_item_id                   => p_item_balance_input.item_input_table(i).inventory_item_id
         ,p_tree_mode                           => p_item_balance_input.item_input_table(i).tree_mode
         ,p_is_revision_control                 => l_is_revision_control
         ,p_is_lot_control                      => l_is_lot_control
         ,p_is_serial_control                   => l_is_serial_control
         ,p_grade_code                          => p_item_balance_input.item_input_table(i).grade_code
         ,p_demand_source_type_id               => p_item_balance_input.item_input_table(i).demand_source_type_id
         ,p_demand_source_header_id             => p_item_balance_input.item_input_table(i).demand_source_header_id
         ,p_demand_source_line_id               => p_item_balance_input.item_input_table(i).demand_source_line_id
         ,p_demand_source_name                  => p_item_balance_input.item_input_table(i).demand_source_name
         ,p_lot_expiration_date                 => p_item_balance_input.item_input_table(i).lot_expiration_date
         ,p_revision                            => p_item_balance_input.item_input_table(i).revision
         ,p_lot_number                          => p_item_balance_input.item_input_table(i).lot_number
         ,p_subinventory_code                   => p_item_balance_input.item_input_table(i).subinventory_code
         ,p_locator_id                          => p_item_balance_input.item_input_table(i).locator_id
         ,p_onhand_source                       => p_item_balance_input.item_input_table(i).onhand_source
         ,p_transfer_subinventory_code          => p_item_balance_input.item_input_table(i).transfer_subinventory_code
         ,p_cost_group_id                       => p_item_balance_input.item_input_table(i).cost_group_id
         ,p_lpn_id                              => p_item_balance_input.item_input_table(i).lpn_id
         ,p_transfer_locator_id                 => p_item_balance_input.item_input_table(i).transfer_locator_id
         ,x_qoh                                 => l_qty_on_hand
         ,x_rqoh                                => l_res_qty_on_hand
         ,x_qr                                  => l_qty_reserved
         ,x_qs                                  => l_qty_suggested
         ,x_att                                 => l_avail_to_transact
         ,x_atr                                 => l_avail_to_reserve
         ,x_sqoh                                => l_sec_qty_on_hand
         ,x_srqoh                               => l_sec_res_qty_on_hand
         ,x_sqr                                 => l_sec_qty_reserved
         ,x_sqs                                 => l_sec_qty_suggested
         ,x_satt                                => l_sec_avail_to_transact
         ,x_satr                                => l_sec_avail_to_reserve
         ,x_return_status                       => l_return_status
         ,x_msg_count                           => l_msg_count
         ,x_msg_data                            => l_msg_data
        );
        l_item_bal_output := inv_ebi_item_balance_obj(
                               l_return_status
                              ,l_msg_count
                              ,l_msg_data
                              ,l_qty_on_hand
                              ,l_res_qty_on_hand
                              ,l_qty_reserved
                              ,l_qty_suggested
                              ,l_avail_to_transact
                              ,l_avail_to_reserve
                              ,l_sec_qty_on_hand
                              ,l_sec_res_qty_on_hand
                              ,l_sec_qty_reserved
                              ,l_sec_qty_suggested
                              ,l_sec_avail_to_transact
                              ,l_sec_avail_to_reserve
                             );
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'organization_id';
        l_pk_col_name_val_pairs(1).value  := p_item_balance_input.item_input_table(i).organization_id;
        l_organization_code  :=  INV_EBI_ITEM_HELPER.id_to_value (
                                                 p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                 ,p_entity_name=> G_ORGANIZATION
                                               );
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'organization_id';
        l_pk_col_name_val_pairs(1).value  := p_item_balance_input.item_input_table(i).organization_id;
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(2).name   := 'inventory_item_id';
        l_pk_col_name_val_pairs(2).value  := p_item_balance_input.item_input_table(i).inventory_item_id;
        l_item_name :=  INV_EBI_ITEM_HELPER.id_to_value(
                                      p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                      ,p_entity_name=> G_INVENTORY_ITEM
                                    );
        l_item_balance_output_obj := inv_ebi_item_bal_output_obj(
                                       p_item_balance_input.item_input_table(i).organization_id
                                      ,p_item_balance_input.item_input_table(i).inventory_item_id
                                      ,l_organization_code
                                      ,l_item_name
                                      ,p_item_balance_input.item_input_table(i).demand_source_type_id
                                      ,p_item_balance_input.item_input_table(i).demand_source_header_id
                                      ,p_item_balance_input.item_input_table(i).demand_source_line_id
                                      ,p_item_balance_input.item_input_table(i).revision
                                      ,p_item_balance_input.item_input_table(i).lot_number
                                      ,p_item_balance_input.item_input_table(i).subinventory_code
                                      ,p_item_balance_input.item_input_table(i).locator_id
                                      ,p_item_balance_input.item_input_table(i).onhand_source
                                      ,p_item_balance_input.item_input_table(i).transfer_subinventory_code
                                      ,p_item_balance_input.item_input_table(i).cost_group_id
                                      ,p_item_balance_input.item_input_table(i).lpn_id
                                      ,p_item_balance_input.item_input_table(i).transfer_locator_id
                                      ,l_item_bal_output
                                      ,NULL
                                      ,NULL
                                      ,NULL);
        l_item_balance_output_tbl(i) := l_item_balance_output_obj;
        IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          RAISE  FND_API.g_exc_unexpected_error;
        END IF;
        --If Locator Information is required then get the item balance based on location
        IF p_item_balance_input.item_input_table(i).is_loc_info_required = fnd_api.g_true THEN
          l_item_balance_loc_tbl :=inv_ebi_item_bal_loc_tbl();
          l_cur_index :=1;
          FOR cer IN c_locator_id(p_item_balance_input.item_input_table(i).inventory_item_id
                                 ,p_item_balance_input.item_input_table(i).organization_id
                                 ,p_item_balance_input.item_input_table(i).revision
                                 ,p_item_balance_input.item_input_table(i).subinventory_code)
          LOOP
            l_locator_id := cer.locator_id;
            l_item_balance_loc_tbl.extend();
            INV_Quantity_Tree_PUB.Query_Quantities(
              p_api_version_number                => p_item_balance_input.item_input_table(i).api_version_number
             ,p_init_msg_lst                      => p_item_balance_input.item_input_table(i).init_msg_lst
             ,p_organization_id                   => p_item_balance_input.item_input_table(i).organization_id
             ,p_inventory_item_id                 => p_item_balance_input.item_input_table(i).inventory_item_id
             ,p_tree_mode                         => p_item_balance_input.item_input_table(i).tree_mode
             ,p_is_revision_control               => l_is_revision_control
             ,p_is_lot_control                    => l_is_lot_control
             ,p_is_serial_control                 => l_is_serial_control
             ,p_grade_code                        => p_item_balance_input.item_input_table(i).grade_code
             ,p_demand_source_type_id             => p_item_balance_input.item_input_table(i).demand_source_type_id
             ,p_demand_source_header_id           => p_item_balance_input.item_input_table(i).demand_source_header_id
             ,p_demand_source_line_id             => p_item_balance_input.item_input_table(i).demand_source_line_id
             ,p_demand_source_name                => p_item_balance_input.item_input_table(i).demand_source_name
             ,p_lot_expiration_date               => p_item_balance_input.item_input_table(i).lot_expiration_date
             ,p_revision                          => p_item_balance_input.item_input_table(i).revision
             ,p_lot_number                        => p_item_balance_input.item_input_table(i).lot_number
             ,p_subinventory_code                 => p_item_balance_input.item_input_table(i).subinventory_code
             ,p_locator_id                        => l_locator_id
             ,p_onhand_source                     => p_item_balance_input.item_input_table(i).onhand_source
             ,p_transfer_subinventory_code        => p_item_balance_input.item_input_table(i).transfer_subinventory_code
             ,p_cost_group_id                     => p_item_balance_input.item_input_table(i).cost_group_id
             ,p_lpn_id                            => p_item_balance_input.item_input_table(i).lpn_id
             ,p_transfer_locator_id               => p_item_balance_input.item_input_table(i).transfer_locator_id
             ,x_qoh                               => l_qty_on_hand
             ,x_rqoh                              => l_res_qty_on_hand
             ,x_qr                                => l_qty_reserved
             ,x_qs                                => l_qty_suggested
             ,x_att                               => l_avail_to_transact
             ,x_atr                               => l_avail_to_reserve
             ,x_sqoh                              => l_sec_qty_on_hand
             ,x_srqoh                             => l_sec_res_qty_on_hand
             ,x_sqr                               => l_sec_qty_reserved
             ,x_sqs                               => l_sec_qty_suggested
             ,x_satt                              => l_sec_avail_to_transact
             ,x_satr                              => l_sec_avail_to_reserve
             ,x_return_status                     => l_return_status
             ,x_msg_count                         => l_msg_count
             ,x_msg_data                          => l_msg_data
            );
            IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
              RAISE  FND_API.g_exc_unexpected_error;
            END IF;
            l_item_bal_output := inv_ebi_item_balance_obj(
                                   l_return_status
                                  ,l_msg_count
                                  ,l_msg_data
                                  ,l_qty_on_hand
                                  ,l_res_qty_on_hand
                                  ,l_qty_reserved
                                  ,l_qty_suggested
                                  ,l_avail_to_transact
                                  ,l_avail_to_reserve
                                  ,l_sec_qty_on_hand
                                  ,l_sec_res_qty_on_hand
                                  ,l_sec_qty_reserved
                                  ,l_sec_qty_suggested
                                  ,l_sec_avail_to_transact
                                  ,l_sec_avail_to_reserve
                                 );
            l_item_balance_loc_obj := inv_ebi_item_bal_loc_obj(l_locator_id,l_item_bal_output);
            l_item_balance_loc_tbl(l_cur_index) := l_item_balance_loc_obj;
            l_cur_index := l_cur_index + 1;
          END LOOP;
        END IF; -- IF p_item_balance_input.item_input_table(i).is_loc_info_required is true
      l_item_balance_output_tbl(i).item_balance_loc_tbl := l_item_balance_loc_tbl;
      get_Operating_unit
        (p_oranization_id => p_item_balance_input.item_input_table(i).organization_id
        ,x_operating_unit => l_item_balance_output_tbl(i).operating_unit
        ,x_ouid      => l_item_balance_output_tbl(i).operating_unit_id
        );
      EXCEPTION
        WHEN FND_API.g_exc_unexpected_error THEN
          x_return_status := FND_API.g_ret_sts_error;
          IF l_msg_data IS NULL THEN
            FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false
             ,p_count => l_item_balance_output_tbl(i).item_balance_output.msg_count
             ,p_data => l_item_balance_output_tbl(i).item_balance_output.msg_data
            );
          END IF;
          populate_err_msg  (p_orgid           => p_item_balance_input.item_input_table(i).organization_id
                            ,p_invid           => p_item_balance_input.item_input_table(i).inventory_item_id
                            ,p_org_code        => l_organization_code
                            ,p_item_name       => l_item_name
                            ,p_part_err_msg    => l_item_balance_output_tbl(i).item_balance_output.msg_data
                            ,x_err_msg         => x_msg_data
                             );
          WHEN OTHERS THEN
            x_return_status := FND_API.g_ret_sts_error;
          populate_err_msg(p_orgid           => p_item_balance_input.item_input_table(i).organization_id
                          ,p_invid           => p_item_balance_input.item_input_table(i).inventory_item_id
                          ,p_org_code        => l_organization_code
                          ,p_item_name       => l_item_name
                          ,p_part_err_msg    => SQLERRM||'-> at inv_ebi_item_helper.get_item_balance'
                          ,x_err_msg         => x_msg_data
                          );
     END;

    END LOOP;
    x_item_balance_output :=inv_ebi_item_bal_output_list(l_item_balance_output_tbl);
  END IF; --p_item_balance_input IS NOT NULL
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_error;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data ||' -> at INV_EBI_ITEM_HELPER.get_item_balance';
    ELSE
      x_msg_data  :=  SQLERRM||' at INV_EBI_ITEM_HELPER.get_item_balance ';
    END IF;
END get_item_balance;
/************************************************************************************
--      API name        : validate_get_item_request
--      Type            : Public
--      Function        :
--      This API is used to validate the Item Request Inputs
--
************************************************************************************/
PROCEDURE validate_get_item_request(
  p_get_opr_attrs_rec  IN         inv_ebi_get_operational_attrs,
  x_status             OUT NOCOPY VARCHAR2,
  x_msg_count          OUT NOCOPY NUMBER,
  x_msg_data           OUT NOCOPY VARCHAR2
)
IS
BEGIN
  FND_MSG_PUB.initialize();
  IF((p_get_opr_attrs_rec.item_id IS NULL) AND
     (p_get_opr_attrs_rec.item_name IS NULL)) THEN
     FND_MESSAGE.set_name('INV','INV_EBI_NO_ITEM_ID_NAME');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSIF((p_get_opr_attrs_rec.organization_id IS NULL) AND
     (p_get_opr_attrs_rec.organization_code IS NULL))THEN
     FND_MESSAGE.set_name('INV','INV_EBI_NO_ORGID_ORGCODE');
     FND_MSG_PUB.add;
     RAISE FND_API.G_EXC_ERROR;
  ELSE
     x_status := FND_API.G_RET_STS_SUCCESS;
  END IF;
EXCEPTION
  WHEN FND_API.G_EXC_ERROR THEN
    x_status := FND_API.G_RET_STS_ERROR;
    FND_MSG_PUB.count_and_get(
      p_encoded => FND_API.g_false
      ,p_count   => x_msg_count
      ,p_data    => x_msg_data
    );
  WHEN OTHERS THEN
    x_status := FND_API.G_RET_STS_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
          x_msg_data   :=   x_msg_data||' -> INV_EBI_ITEM_HELPER.validate_get_item_request ';
    ELSE
          x_msg_data   :=   SQLERRM||' INV_EBI_ITEM_HELPER.validate_get_item_request ';
    END IF;
END validate_get_item_request;
/************************************************************************************
   --      API name        : get_uda_attributes
   --      Type            : Public
   --      Function        :
   --      Bug 7240247
 ************************************************************************************/

  PROCEDURE get_uda_attributes(
   p_classification_id  IN     NUMBER,
   p_attr_group_type    IN     VARCHAR2,
   p_application_id     IN     NUMBER,
   p_attr_grp_id_tbl    IN     FND_TABLE_OF_NUMBER,
   p_data_level         IN     VARCHAR2,
   p_revision_id        IN     NUMBER,
   p_object_name        IN     VARCHAR2,
   p_pk_data            IN     EGO_COL_NAME_VALUE_PAIR_ARRAY,
   x_uda_obj            OUT    NOCOPY inv_ebi_uda_input_obj,
   x_uda_output_obj     OUT    NOCOPY inv_ebi_eco_output_obj
 ) IS
 l_attr_grp_req_tbl        ego_attr_group_request_table;
 l_attr_grp_req_obj        ego_attr_group_request_obj;
 l_attr_grp                ego_user_attr_row_table;
 l_attr                    ego_user_attr_data_table;
 l_count                   NUMBER := 0;
 l_new_attr_in_tbl         VARCHAR2(1)    := fnd_api.g_false;
 l_uda_out                 inv_ebi_uda_output_obj;
 l_output_status           inv_ebi_output_status;
 l_attr_group_name         VARCHAR2(30);
 l_data_level              VARCHAR2(20) := NULL;
 l_data_level1             VARCHAR2(20) := NULL;

 CURSOR c_attr_cursor(
      p_classification_id     IN NUMBER,
      p_attr_group_type       IN VARCHAR2,
      p_application_id        IN NUMBER,
      p_attr_group_name       IN VARCHAR2,
      p_data_level_int_name   IN VARCHAR2
      ) IS
  SELECT
    att.attr_name,
    ass.attr_group_id,
    ass.data_level_int_name
  FROM
    ego_obj_attr_grp_assocs_v ass,
    ego_attrs_v att
  WHERE ass.classification_code = TO_CHAR(p_classification_id)
    AND ass.attr_group_type = att.attr_group_type
    AND att.attr_group_type = p_attr_group_type
    AND ass.application_id = att.application_id
    AND att.application_id = p_application_id
    AND ass.attr_group_name = att.attr_group_name
    AND att.attr_group_name = p_attr_group_name
    AND ass.data_level_int_name = p_data_level_int_name;

 BEGIN
   l_uda_out         := inv_ebi_uda_output_obj(NULL,NULL);
   l_output_status   := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_uda_output_obj  := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,l_uda_out);

   l_attr_grp_req_tbl := EGO_ATTR_GROUP_REQUEST_TABLE();

   l_count := 1;


   FOR i IN 1..p_attr_grp_id_tbl.COUNT LOOP

       IF(p_attr_group_type = INV_EBI_UTIL.G_EGO_ITEMMGMT_GROUP) THEN

          SELECT data_level_int_name INTO l_data_level
          FROM ego_obj_attr_grp_assocs_v
          WHERE attr_group_id = p_attr_grp_id_tbl(i)
          AND classification_code = TO_CHAR(p_classification_id);

       ELSE

         l_data_level := p_data_level;

       END IF;

       SELECT attr_group_name INTO l_attr_group_name
       FROM ego_obj_attr_grp_assocs_v
       WHERE
         attr_group_id = p_attr_grp_id_tbl(i) AND
         classification_code = TO_CHAR(p_classification_id) AND
         data_level_int_name = l_data_level;


     FOR attr_cursor IN c_attr_cursor(
                           p_classification_id    => p_classification_id ,
                           p_attr_group_type      => p_attr_group_type,
                           p_application_id       => p_application_id,
                           p_attr_group_name      => l_attr_group_name,
                           p_data_level_int_name  => l_data_level
                         )
     LOOP
       l_new_attr_in_tbl := FND_API.G_FALSE;

       IF(l_count <>1 ) THEN
         FOR ctr1 IN l_attr_grp_req_tbl.FIRST..l_attr_grp_req_tbl.LAST  LOOP
           IF (l_attr_grp_req_tbl(ctr1).attr_group_id = attr_cursor.attr_group_id AND
             l_attr_grp_req_tbl(ctr1).data_level = attr_cursor.data_level_int_name ) THEN
             l_attr_grp_req_tbl(ctr1).ATTR_NAME_LIST := l_attr_grp_req_tbl(ctr1).ATTR_NAME_LIST || ',' || attr_cursor.attr_name;
             l_new_attr_in_tbl := FND_API.G_TRUE;
           END IF;
         END LOOP;
       END IF;

       IF l_new_attr_in_tbl <> FND_API.G_TRUE THEN

         l_attr_grp_req_tbl.extend();

         IF(attr_cursor.data_level_int_name = INV_EBI_ITEM_PUB.g_data_level_item_rev) THEN
           l_data_level1 := p_revision_id;
         ELSE
           l_data_level1 := NULL;
         END IF;


         l_attr_grp_req_tbl(l_count) := EGO_ATTR_GROUP_REQUEST_OBJ(attr_cursor.attr_group_id
          ,NULL
          ,NULL
          ,NULL
          ,l_data_level
          ,l_data_level1
          ,NULL
          ,NULL
          ,NULL
          ,NULL
          ,attr_cursor.attr_name);

         l_count := l_count + 1;
       END IF;
     END LOOP;
  END LOOP;
  EGO_USER_ATTRS_DATA_PUB.Get_User_Attrs_Data(
     p_api_version                  =>  1.0
    ,p_object_name                  =>  p_object_name
    ,p_pk_column_name_value_pairs   =>  p_pk_data
    ,p_attr_group_request_table     =>  l_attr_grp_req_tbl
    ,x_attributes_row_table         =>  l_attr_grp
    ,x_attributes_data_table        =>  l_attr
    ,x_return_status                =>  x_uda_output_obj.output_status.return_status
    ,x_errorcode                    =>  x_uda_output_obj.uda_output.errorcode
    ,x_msg_count                    =>  x_uda_output_obj.output_status.msg_count
    ,x_msg_data                     =>  x_uda_output_obj.output_status.msg_data
  );

  IF(x_uda_output_obj.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;

  INV_EBI_UTIL.transform_attr_rowdata_uda(
     p_attributes_row_table    =>   l_attr_grp
    ,p_attributes_data_table   =>   l_attr
    ,x_uda_input_obj           =>   x_uda_obj
    ,x_return_status           =>   x_uda_output_obj.output_status.return_status
    ,x_msg_count               =>   x_uda_output_obj.output_status.msg_count
    ,x_msg_data                =>   x_uda_output_obj.output_status.msg_data

  );

  IF(x_uda_output_obj.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE FND_API.g_exc_unexpected_error;
  END IF;


  EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN

      x_uda_output_obj.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;

      IF(x_uda_output_obj.output_status.msg_data IS NULL) THEN
        fnd_msg_pub.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_uda_output_obj.output_status.msg_count
         ,p_data    => x_uda_output_obj.output_status.msg_data
       );
      END IF;

    WHEN OTHERS THEN

      x_uda_output_obj.output_status.return_status := FND_API.g_ret_sts_unexp_error;
      IF (x_uda_output_obj.output_status.msg_data IS NOT NULL) THEN
        x_uda_output_obj.output_status.msg_data      :=  x_uda_output_obj.output_status.msg_data||' ->INV_EBI_CHANGE_ORDER_HELPER.get_uda_attributes ';
      ELSE
        x_uda_output_obj.output_status.msg_data      :=  SQLERRM||'INV_EBI_CHANGE_ORDER_HELPER.get_uda_attributes ';
    END IF;
 END get_uda_attributes;


/************************************************************************************
--      API name        : get_item_uda
--      Type            : Private
--      Function        :
--      This API is used to retrieve the uda's of the requested Items.
--      Bug 7240247
************************************************************************************/

PROCEDURE get_item_uda(
  p_inventory_item_id         IN  NUMBER,
  p_organization_id           IN  NUMBER,
  p_item_classification_id    IN  NUMBER,
  p_revision_id               IN  NUMBER,
  x_item_uda                  OUT NOCOPY      inv_ebi_uda_input_obj,
  x_return_status             OUT NOCOPY      VARCHAR2,
  x_msg_count                 OUT NOCOPY      NUMBER,
  x_msg_data                  OUT NOCOPY      VARCHAR2
) IS

l_count                  NUMBER :=0;
l_item_uda_count         NUMBER :=0;
l_attr_group_count       NUMBER :=0;
l_application_id         NUMBER;
l_attr_group_id_tbl      FND_TABLE_OF_NUMBER;
l_pkdata                 EGO_COL_NAME_VALUE_PAIR_ARRAY;
l_uda_output_obj         inv_ebi_eco_output_obj;
l_output_status          inv_ebi_output_status;

CURSOR c_attr_group_id IS
  SELECT DISTINCT ems.attr_group_id
  FROM
    ego_mtl_sy_items_ext_vl ems,
    ego_obj_attr_grp_assocs_v ass
  WHERE
     ems.inventory_item_id      =  p_inventory_item_id AND
     ems.organization_id        =  p_organization_id AND
     ems.item_catalog_group_id  =  p_item_classification_id AND
     ems.attr_group_id          =  ass.attr_group_id;

BEGIN

  l_output_status   := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
  l_uda_output_obj  := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);


  IF( p_inventory_item_id IS NOT NULL AND
      p_organization_id IS NOT NULL AND
      p_item_classification_id IS NOT NULL) THEN

    SELECT COUNT(1) INTO l_count
    FROM mtl_system_items_b
    WHERE
      inventory_item_id      =  p_inventory_item_id AND
      organization_id        =  p_organization_id AND
      item_catalog_group_id  =  p_item_classification_id;

  END IF;

  IF(l_count > 0) THEN

    IF c_attr_group_id%ISOPEN THEN
      CLOSE c_attr_group_id;
    END IF;

    OPEN c_attr_group_id ;
      FETCH c_attr_group_id  BULK COLLECT INTO l_attr_group_id_tbl ;
    CLOSE c_attr_group_id;


    IF(l_attr_group_id_tbl IS NOT NULL AND l_attr_group_id_tbl.COUNT > 0) THEN

      l_pkdata := EGO_COL_NAME_VALUE_PAIR_ARRAY();
      l_pkdata.extend(2);
      l_pkdata(1) := EGO_COL_NAME_VALUE_PAIR_OBJ('INVENTORY_ITEM_ID',p_inventory_item_id);
      l_pkdata(2) := EGO_COL_NAME_VALUE_PAIR_OBJ('ORGANIZATION_ID',p_organization_id);

      l_application_id:= INV_EBI_UTIL.get_application_id(
                             p_application_short_name => 'EGO'
                         );

      IF(l_application_id IS NULL ) THEN

        FND_MESSAGE.set_name('INV','INV_EBI_APP_INVALID');
        FND_MESSAGE.set_token('COL_VALUE', 'EGO');
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;
      END IF;

      get_uda_attributes(
         p_classification_id  =>  p_item_classification_id,
         p_attr_group_type    =>  INV_EBI_UTIL.G_EGO_ITEMMGMT_GROUP,
         p_application_id     =>  l_application_id,
         p_attr_grp_id_tbl    =>  l_attr_group_id_tbl,
         p_data_level         =>  NULL,
         p_revision_id        =>  p_revision_id,
         p_object_name        =>  INV_EBI_UTIL.G_EGO_ITEM,
         p_pk_data            =>  l_pkdata,
         x_uda_obj            =>  x_item_uda,
         x_uda_output_obj     =>  l_uda_output_obj
      );

      IF(l_uda_output_obj.output_status.return_status  <> FND_API.G_RET_STS_SUCCESS) THEN
        x_msg_data      := l_uda_output_obj.output_status.msg_data ;
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;
  END IF;

  EXCEPTION
    WHEN FND_API.g_exc_unexpected_error THEN

      IF c_attr_group_id%ISOPEN THEN
        CLOSE c_attr_group_id;
      END IF;

      x_return_status :=  FND_API.g_ret_sts_unexp_error;
      IF(x_msg_data IS NULL) THEN
        fnd_msg_pub.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_msg_count
         ,p_data    => x_msg_data
       );
      END IF;
    WHEN OTHERS THEN

      IF c_attr_group_id%ISOPEN THEN
        CLOSE c_attr_group_id;
      END IF;

      x_return_status :=  FND_API.g_ret_sts_unexp_error;
      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data      :=  x_msg_data||' ->INV_EBI_ITEM_HELPER.get_item_uda ';
      ELSE
        x_msg_data      :=  SQLERRM||'INV_EBI_ITEM_HELPER.get_item_uda';
    END IF;
 END get_item_uda;
/************************************************************************************
--      API name        : get_item_attributes
--      Type            : Public
--      Function        :
--      This API is used to retrieve the operational attributes for the requested Items.
--
************************************************************************************/
PROCEDURE get_item_attributes(
  p_get_item_inp_obj       IN         inv_ebi_get_item_input,
  x_item_tbl_obj           OUT NOCOPY inv_ebi_item_attr_tbl_obj,
  x_return_status          OUT NOCOPY VARCHAR2,
  x_msg_count              OUT NOCOPY NUMBER,
  x_msg_data               OUT NOCOPY VARCHAR2
)
IS
  l_item_phy_obj            inv_ebi_item_physical_obj;
  l_item_inv_obj            inv_ebi_item_inventory_obj;
  l_item_pur_obj            inv_ebi_item_purchasing_obj;
  l_item_recving_obj        inv_ebi_item_receiving_obj;
  l_item_gplan_obj          inv_ebi_item_gplanning_obj;
  l_item_mrp_obj            inv_ebi_item_mrp_obj;
  l_item_order_obj          inv_ebi_item_order_obj;
  l_item_service_obj        inv_ebi_item_service_obj;
  l_item_bom_obj            inv_ebi_item_bom_obj;
  l_item_costing_obj        inv_ebi_item_costing_obj;
  l_item_lead_time_obj      inv_ebi_item_lead_time_obj;
  l_item_wip_obj            inv_ebi_item_wip_obj;
  l_item_invoice_obj        inv_ebi_item_invoice_obj;
  l_item_web_opiton         inv_ebi_item_web_option_obj;
  l_item_asset_obj          inv_ebi_item_asset_obj;
  l_item_process_obj        inv_ebi_item_processmfg_obj;
  l_item_mfr_part_obj       inv_ebi_manufacturer_part_obj;
  l_item_core_obj           inv_ebi_item_main_obj;
  l_item_custom_obj         inv_ebi_item_custom_obj;
  l_uda_obj                 inv_ebi_uda_input_obj;
  l_item_obj                inv_ebi_item_obj;
  l_getassetmgmtattrs       VARCHAR2(1)    := FND_API.G_FALSE;
  l_getbomattrs             VARCHAR2(1)    := FND_API.G_FALSE;
  l_getcostingattrs         VARCHAR2(1)    := FND_API.G_FALSE;
  l_getgeneralplanningattrs VARCHAR2(1)    := FND_API.G_FALSE;
  l_getinventoryattrs       VARCHAR2(1)    := FND_API.G_FALSE;
  l_getinvoicingattrs       VARCHAR2(1)    := FND_API.G_FALSE;
  l_getleadtimeattrs        VARCHAR2(1)    := FND_API.G_FALSE;
  l_getmpsmrpplanningattrs  VARCHAR2(1)    := FND_API.G_FALSE;
  l_getorderattrs           VARCHAR2(1)    := FND_API.G_FALSE;
  l_getphysicalattrs        VARCHAR2(1)    := FND_API.G_FALSE;
  l_getprocessattrs         VARCHAR2(1)    := FND_API.G_FALSE;
  l_getpurchasingattrs      VARCHAR2(1)    := FND_API.G_FALSE;
  l_getrecevingattrs        VARCHAR2(1)    := FND_API.G_FALSE;
  l_getserviceattrs         VARCHAR2(1)    := FND_API.G_FALSE;
  l_getweboptionattrs       VARCHAR2(1)    := FND_API.G_FALSE;
  l_getwipattrs             VARCHAR2(1)    := FND_API.G_FALSE;
  l_getitemoprattrs         VARCHAR2(1)    := FND_API.G_FALSE;
  l_org_id                  NUMBER;
  l_item_id                 NUMBER;
  l_msg_data                VARCHAR2(100);
  l_msg_count               NUMBER;
  l_item_attr_tbl           inv_ebi_item_attr_tbl;
  l_mfr_part_table          inv_ebi_mfg_part_obj_tbl_type;
  l_return_status           VARCHAR2(1);
  l_msg                     VARCHAR2(100);
  l_pk_col_name_val_pairs   INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
  ctr                       NUMBER;
  l_error_code              NUMBER;
  l_default_cost_group_id   VARCHAR2(2000)  :=NULL;
  l_default_cost_type_id    VARCHAR2(2000)  :=NULL;

  CURSOR c_mfr_part_cursor(p_item_id IN NUMBER,p_org_id IN NUMBER) IS
    SELECT
      manufacturer_id,mfg_part_num
    FROM mtl_mfg_part_numbers
    WHERE inventory_item_id = p_item_id AND organization_id=p_org_id;

BEGIN

  l_item_attr_tbl := inv_ebi_item_attr_tbl();
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  IF p_get_item_inp_obj.p_config_flags IS NULL THEN
    l_getitemoprattrs := FND_API.G_TRUE;
  ELSE
  FOR i IN p_get_item_inp_obj.p_config_flags.FIRST..p_get_item_inp_obj.p_config_flags.LAST
  LOOP
    CASE p_get_item_inp_obj.p_config_flags(i).param_name
      WHEN G_ASSET_MGMT_ATTRS THEN
        l_getassetmgmtattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_BOM_ATTRS THEN
        l_getbomattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_COSTING_ATTRS THEN
        l_getcostingattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_GPLAN_ATTRS THEN
        l_getgeneralplanningattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_INVENTORY_ATTRS THEN
        l_getinventoryattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_INVOICE_ATTRS THEN
        l_getinvoicingattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_LEAD_TIME_ATTRS  THEN
        l_getleadtimeattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_MPSMRP_ATTRS THEN
        l_getmpsmrpplanningattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_ORDER_ATTRS THEN
        l_getorderattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_PHYSICAL_ATTRS THEN
        l_getphysicalattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_PROCESS_ATTRS THEN
        l_getprocessattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_PURCHASING_ATTRS THEN
        l_getpurchasingattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_RECEVING_ATTRS THEN
        l_getrecevingattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_SERVICE_ATTRS  THEN
        l_getserviceattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_WEB_OPTION_ATTRS THEN
        l_getweboptionattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_WIP_ATTRS THEN
        l_getwipattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_ITEM_ATTRS  THEN
        l_getitemoprattrs := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_DEFAULT_COST_GROUP_ID THEN
        l_default_cost_group_id := p_get_item_inp_obj.p_config_flags(i).param_value;
      WHEN G_DEFAULT_COST_TYPE_ID THEN
        l_default_cost_type_id := p_get_item_inp_obj.p_config_flags(i).param_value;
      ELSE
        NULL;
    END CASE;
  END LOOP;
  END IF;
  FOR i IN p_get_item_inp_obj.p_get_opr_attrs_tbl_type.FIRST..p_get_item_inp_obj.p_get_opr_attrs_tbl_type.LAST
  LOOP
    BEGIN
      l_item_attr_tbl.extend();
      l_mfr_part_table := inv_ebi_mfg_part_obj_tbl_type();
      l_item_attr_tbl(i) := inv_ebi_get_item_output_obj(NULL,FND_API.G_RET_STS_SUCCESS,NULL,NULL);
      l_item_core_obj := inv_ebi_item_main_obj(
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL,NULL,
                                               NULL,NULL,NULL,NULL,NULL
                                               );
      l_item_custom_obj := inv_ebi_item_custom_obj(NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL,NULL,NULL,
                                                   NULL,NULL,NULL,NULL);


      l_item_phy_obj := inv_ebi_item_physical_obj(
                                             NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                                             );
      l_item_inv_obj := inv_ebi_item_inventory_obj(
                                             NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                                             );
      l_item_pur_obj := inv_ebi_item_purchasing_obj(
                                             NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                                             );
      l_item_recving_obj := inv_ebi_item_receiving_obj(
                                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                                             );
      l_item_gplan_obj := inv_ebi_item_gplanning_obj(
                                             NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL
                                             );
      l_item_mrp_obj :=         inv_ebi_item_mrp_obj(
                                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                             NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                                             );
      l_item_order_obj := inv_ebi_item_order_obj(
                                              NULL,NULL,NULL,NULL,NULL,NULL,
                                              NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                                              NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                                              );
      l_item_service_obj := inv_ebi_item_service_obj(
                                              NULL,NULL,NULL,NULL,NULL,NULL,
                                              NULL,NULL,NULL,NULL,NULL
                                              );
      l_item_bom_obj :=     inv_ebi_item_bom_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      l_item_costing_obj := inv_ebi_item_costing_obj(
                                              NULL,NULL,NULL,NULL,NULL,NULL
                                              );
      l_item_lead_time_obj := inv_ebi_item_lead_time_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      l_item_wip_obj := inv_ebi_item_wip_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      l_item_invoice_obj := inv_ebi_item_invoice_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      l_item_web_opiton := inv_ebi_item_web_option_obj(NULL,NULL,NULL,NULL);
      l_item_asset_obj := inv_ebi_item_asset_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      l_item_process_obj := inv_ebi_item_processmfg_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      l_uda_obj := inv_ebi_uda_input_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      validate_get_item_request(
        p_get_opr_attrs_rec => p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i)
        ,x_status => l_return_status
        ,x_msg_count => l_item_attr_tbl(i).msg_count
        ,x_msg_data => l_item_attr_tbl(i).msg_data
      );
      l_org_id := p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i).organization_id;
      l_item_id := p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i).item_id;
      IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      IF((l_org_id IS NULL) )THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'organization_code';
        l_pk_col_name_val_pairs(1).value  :=  p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i).organization_code;
        l_org_id  :=  INV_EBI_ITEM_HELPER.value_to_id (
                        p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                       ,p_entity_name=> INV_EBI_ITEM_HELPER.G_ORGANIZATION
                      );
        IF (l_org_id IS NULL) THEN
          FND_MESSAGE.set_name('INV','INV_EBI_ORG_CODE_INVALID');
          FND_MESSAGE.set_token('COL_VALUE', p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i).organization_code);
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      IF( l_item_id IS NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(2);
        l_pk_col_name_val_pairs(1).name   := 'organization_id';
        l_pk_col_name_val_pairs(1).value  := l_org_id;
        l_pk_col_name_val_pairs(2).name   := 'concatenated_segments';
        l_pk_col_name_val_pairs(2).value  := p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i).item_name;
        l_item_id :=  INV_EBI_ITEM_HELPER.value_to_id (
                        p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                       ,p_entity_name=> INV_EBI_ITEM_HELPER.G_INVENTORY_ITEM
                      );
        IF (l_item_id IS NULL ) THEN
               FND_MESSAGE.set_name('INV','INV_EBI_ITEM_INVALID');
               FND_MESSAGE.set_token('COL_VALUE', p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i).item_name);
               FND_MSG_PUB.add;
               RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;
      SELECT inventory_item_id
        ,organization_id
        ,description
        ,item_catalog_group_id
        ,end_date_active
        ,start_date_active
        ,primary_uom_code
        ,tracking_quantity_ind
        ,ont_pricing_qty_source
        ,secondary_uom_code
        ,secondary_default_ind
        ,dual_uom_deviation_high
        ,dual_uom_deviation_low
        ,allowed_units_lookup_code
        ,item_type
        ,description
        ,inventory_item_status_code
        ,primary_unit_of_measure
        ,lifecycle_id
        ,current_phase_id
        ,eam_item_type
        ,eam_activity_type_code
        ,eam_activity_cause_code
        ,eam_activity_source_code
        ,eam_act_notification_flag
        ,eam_act_shutdown_status
        ,bom_enabled_flag
        ,bom_item_type
        ,base_item_id
        ,auto_created_config_flag
        ,effectivity_control
        ,config_model_type
        ,config_orgs
        ,config_match
        ,eng_item_flag
        ,costing_enabled_flag
        ,inventory_asset_flag
        ,default_include_in_rollup_flag
        ,cost_of_sales_account
        ,std_lot_size
        ,inventory_planning_code
        ,planner_code
        ,planning_make_buy_code
        ,min_minmax_quantity
        ,max_minmax_quantity
        ,minimum_order_quantity
        ,maximum_order_quantity
        ,order_cost
        ,carrying_cost
        ,source_type
        ,source_organization_id
        ,source_subinventory
        ,mrp_safety_stock_code
        ,safety_stock_bucket_days
        ,mrp_safety_stock_percent
        ,fixed_order_quantity
        ,fixed_days_supply
        ,fixed_lot_multiplier
        ,vmi_minimum_units
        ,vmi_minimum_days
        ,vmi_maximum_units
        ,vmi_maximum_days
        ,vmi_fixed_order_quantity
        ,so_authorization_flag
        ,consigned_flag
        ,asn_autoexpire_flag
        ,vmi_forecast_type
        ,forecast_horizon
        ,inventory_item_flag
        ,stock_enabled_flag
        ,mtl_transactions_enabled_flag
        ,check_shortages_flag
        ,revision_qty_control_code
        ,reservable_type
        ,shelf_life_code
        ,shelf_life_days
        ,cycle_count_enabled_flag
        ,negative_measurement_error
        ,positive_measurement_error
        ,lot_control_code
        ,auto_lot_alpha_prefix
        ,start_auto_lot_number
        ,serial_number_control_code
        ,auto_serial_alpha_prefix
        ,start_auto_serial_number
        ,location_control_code
        ,restrict_subinventories_code
        ,restrict_locators_code
        ,bulk_picked_flag
        ,lot_status_enabled
        ,serial_status_enabled
        ,lot_split_enabled
        ,lot_merge_enabled
        ,lot_translate_enabled
        ,lot_substitution_enabled
        ,invoiceable_item_flag
        ,invoice_enabled_flag
        ,accounting_rule_id
        ,invoicing_rule_id
        ,tax_code
        ,sales_account
        ,payment_terms_id
        ,preprocessing_lead_time
        ,full_lead_time
        ,postprocessing_lead_time
        ,fixed_lead_time
        ,variable_lead_time
        ,cum_manufacturing_lead_time
        ,cumulative_total_lead_time
        ,lead_time_lot_size
        ,mrp_planning_code
        ,ato_forecast_control
        ,planning_exception_set
        ,end_assembly_pegging_flag
        ,shrinkage_rate
        ,rounding_control_type
        ,acceptable_early_days
        ,repetitive_planning_flag
        ,overrun_percentage
        ,acceptable_rate_increase
        ,acceptable_rate_decrease
        ,mrp_calculate_atp_flag
        ,auto_reduce_mps
        ,planning_time_fence_code
        ,planning_time_fence_days
        ,demand_time_fence_code
        ,demand_time_fence_days
        ,release_time_fence_code
        ,release_time_fence_days
        ,substitution_window_code
        ,substitution_window_days
        ,exclude_from_budget_flag
        ,days_tgt_inv_supply
        ,days_tgt_inv_window
        ,days_max_inv_supply
        ,days_max_inv_window
        ,drp_planned_flag
        ,critical_component_flag
        ,continous_transfer
        ,convergence
        ,divergence
        ,customer_order_flag
        ,customer_order_enabled_flag
        ,shippable_item_flag
        ,internal_order_flag
        ,internal_order_enabled_flag
        ,so_transactions_flag
        ,pick_components_flag
        ,atp_flag
        ,replenish_to_order_flag
        ,atp_rule_id
        ,atp_components_flag
        ,ship_model_complete_flag
        ,picking_rule_id
        ,collateral_flag
        ,default_shipping_org
        ,returnable_flag
        ,return_inspection_requirement
        ,over_shipment_tolerance
        ,under_shipment_tolerance
        ,over_return_tolerance
        ,under_return_tolerance
        ,financing_allowed_flag
        ,default_so_source_type
        ,weight_uom_code
        ,unit_weight
        ,volume_uom_code
        ,unit_volume
        ,container_item_flag
        ,vehicle_item_flag
        ,container_type_code
        ,internal_volume
        ,maximum_load_weight
        ,minimum_fill_percent
        ,equipment_type
        ,event_flag
        ,electronic_flag
        ,downloadable_flag
        ,indivisible_flag
        ,dimension_uom_code
        ,unit_length
        ,unit_width
        ,unit_height
        ,recipe_enabled_flag
        ,process_costing_enabled_flag
        ,process_quality_enabled_flag
        ,process_execution_enabled_flag
        ,process_supply_subinventory
        ,process_supply_locator_id
        ,process_yield_subinventory
        ,process_yield_locator_id
        ,hazardous_material_flag
        ,cas_number
        ,purchasing_item_flag
        ,purchasing_enabled_flag
        ,must_use_approved_vendor_flag
        ,allow_item_desc_update_flag
        ,rfq_required_flag
        ,outside_operation_flag
        ,outside_operation_uom_type
        ,taxable_flag
        ,purchasing_tax_code
        ,receipt_required_flag
        ,inspection_required_flag
        ,buyer_id
        ,unit_of_issue
        ,receive_close_tolerance
        ,invoice_close_tolerance
        ,un_number_id
        ,hazard_class_id
        ,list_price_per_unit
        ,market_price
        ,price_tolerance_percent
        ,rounding_factor
        ,encumbrance_account
        ,expense_account
        ,asset_category_id
        ,receipt_days_exception_code
        ,days_early_receipt_allowed
        ,days_late_receipt_allowed
        ,allow_substitute_receipts_flag
        ,allow_unordered_receipts_flag
        ,allow_express_delivery_flag
        ,qty_rcv_exception_code
        ,qty_rcv_tolerance
        ,receiving_routing_id
        ,enforce_ship_to_location_code
        ,coverage_schedule_id
        ,service_duration
        ,service_duration_period_code
        ,serviceable_product_flag
        ,service_starting_delay
        ,material_billable_flag
        ,recovered_part_disp_code
        ,defect_tracking_on_flag
        ,comms_nl_trackable_flag
        ,asset_creation_code
        ,ib_item_instance_class
        ,orderable_on_web_flag
        ,back_orderable_flag
        ,web_status
        ,minimum_license_quantity
        ,build_in_wip_flag
        ,wip_supply_type
        ,wip_supply_subinventory
        ,wip_supply_locator_id
        ,overcompletion_tolerance_type
        ,overcompletion_tolerance_value
        ,inventory_carry_penalty
        ,operation_slack_penalty
        ,ATTRIBUTE_CATEGORY
        ,ATTRIBUTE1
        ,ATTRIBUTE2
        ,ATTRIBUTE3
        ,ATTRIBUTE4
        ,ATTRIBUTE5
        ,ATTRIBUTE6
        ,ATTRIBUTE7
        ,ATTRIBUTE8
        ,ATTRIBUTE9
        ,ATTRIBUTE10
        ,ATTRIBUTE11
        ,ATTRIBUTE12
        ,ATTRIBUTE13
        ,ATTRIBUTE14
        ,ATTRIBUTE15
        ,ATTRIBUTE16
        ,ATTRIBUTE17
        ,ATTRIBUTE18
        ,ATTRIBUTE19
        ,ATTRIBUTE20
        ,ATTRIBUTE21
        ,ATTRIBUTE22
        ,ATTRIBUTE23
        ,ATTRIBUTE24
        ,ATTRIBUTE25
        ,ATTRIBUTE26
        ,ATTRIBUTE27
        ,ATTRIBUTE28
        ,ATTRIBUTE29
        ,ATTRIBUTE30
        ,GLOBAL_ATTRIBUTE_CATEGORY
        ,GLOBAL_ATTRIBUTE1
        ,GLOBAL_ATTRIBUTE2
        ,GLOBAL_ATTRIBUTE3
        ,GLOBAL_ATTRIBUTE4
        ,GLOBAL_ATTRIBUTE5
        ,GLOBAL_ATTRIBUTE6
        ,GLOBAL_ATTRIBUTE7
        ,GLOBAL_ATTRIBUTE8
        ,GLOBAL_ATTRIBUTE9
        ,GLOBAL_ATTRIBUTE10
        INTO l_item_core_obj.inventory_item_id
        ,l_item_core_obj.organization_id
        ,l_item_core_obj.description
        ,l_item_core_obj.item_catalog_group_id
        ,l_item_core_obj.end_date_active
        ,l_item_core_obj.start_date_active
        ,l_item_core_obj.primary_uom_code
        ,l_item_core_obj.tracking_quantity_ind
        ,l_item_core_obj.ont_pricing_qty_source
        ,l_item_core_obj.secondary_uom_code
        ,l_item_core_obj.secondary_default_ind
        ,l_item_core_obj.dual_uom_deviation_high
        ,l_item_core_obj.dual_uom_deviation_low
        ,l_item_core_obj.allowed_units_lookup_code
        ,l_item_core_obj.item_type
        ,l_item_core_obj.description
        ,l_item_core_obj.inventory_item_status_code
        ,l_item_core_obj.primary_unit_of_measure
        ,l_item_core_obj.lifecycle_id
        ,l_item_core_obj.current_phase_id
        ,l_item_asset_obj.eam_item_type
        ,l_item_asset_obj.eam_activity_type_code
        ,l_item_asset_obj.eam_activity_cause_code
        ,l_item_asset_obj.eam_activity_source_code
        ,l_item_asset_obj.eam_act_notification_flag
        ,l_item_asset_obj.eam_act_shutdown_status
        ,l_item_bom_obj.bom_enabled_flag
        ,l_item_bom_obj.bom_item_type
        ,l_item_bom_obj.base_item_id
        ,l_item_bom_obj.auto_created_config_flag
        ,l_item_bom_obj.effectivity_control
        ,l_item_bom_obj.config_model_type
        ,l_item_bom_obj.config_orgs
        ,l_item_bom_obj.config_match
        ,l_item_bom_obj.eng_item_flag
        ,l_item_costing_obj.costing_enabled_flag
        ,l_item_costing_obj.inventory_asset_flag
        ,l_item_costing_obj.default_include_in_rollup_f
        ,l_item_costing_obj.cost_of_sales_account
        ,l_item_costing_obj.std_lot_size
        ,l_item_gplan_obj.inventory_planning_code
        ,l_item_gplan_obj.planner_code
        ,l_item_gplan_obj.planning_make_buy_code
        ,l_item_gplan_obj.min_minmax_quantity
        ,l_item_gplan_obj.max_minmax_quantity
        ,l_item_gplan_obj.minimum_order_quantity
        ,l_item_gplan_obj.maximum_order_quantity
        ,l_item_gplan_obj.order_cost
        ,l_item_gplan_obj.carrying_cost
        ,l_item_gplan_obj.source_type
        ,l_item_gplan_obj.source_organization_id
        ,l_item_gplan_obj.source_subinventory
        ,l_item_gplan_obj.mrp_safety_stock_code
        ,l_item_gplan_obj.safety_stock_bucket_days
        ,l_item_gplan_obj.mrp_safety_stock_percent
        ,l_item_gplan_obj.fixed_order_quantity
        ,l_item_gplan_obj.fixed_days_supply
        ,l_item_gplan_obj.fixed_lot_multiplier
        ,l_item_gplan_obj.vmi_minimum_units
        ,l_item_gplan_obj.vmi_minimum_days
        ,l_item_gplan_obj.vmi_maximum_units
        ,l_item_gplan_obj.vmi_maximum_days
        ,l_item_gplan_obj.vmi_fixed_order_quantity
        ,l_item_gplan_obj.so_authorization_flag
        ,l_item_gplan_obj.consigned_flag
        ,l_item_gplan_obj.asn_autoexpire_flag
        ,l_item_gplan_obj.vmi_forecast_type
        ,l_item_gplan_obj.forecast_horizon
        ,l_item_inv_obj.inventory_item_flag
        ,l_item_inv_obj.stock_enabled_flag
        ,l_item_inv_obj.mtl_transactions_enabled_fl
        ,l_item_inv_obj.check_shortages_flag
        ,l_item_inv_obj.revision_qty_control_code
        ,l_item_inv_obj.reservable_type
        ,l_item_inv_obj.shelf_life_code
        ,l_item_inv_obj.shelf_life_days
        ,l_item_inv_obj.cycle_count_enabled_flag
        ,l_item_inv_obj.negative_measurement_error
        ,l_item_inv_obj.positive_measurement_error
        ,l_item_inv_obj.lot_control_code
        ,l_item_inv_obj.auto_lot_alpha_prefix
        ,l_item_inv_obj.start_auto_lot_number
        ,l_item_inv_obj.serial_number_control_code
        ,l_item_inv_obj.auto_serial_alpha_prefix
        ,l_item_inv_obj.start_auto_serial_number
        ,l_item_inv_obj.location_control_code
        ,l_item_inv_obj.restrict_subinventories_cod
        ,l_item_inv_obj.restrict_locators_code
        ,l_item_inv_obj.bulk_picked_flag
        ,l_item_inv_obj.lot_status_enabled
        ,l_item_inv_obj.serial_status_enabled
        ,l_item_inv_obj.lot_split_enabled
        ,l_item_inv_obj.lot_merge_enabled
        ,l_item_inv_obj.lot_translate_enabled
        ,l_item_inv_obj.lot_substitution_enabled
        ,l_item_invoice_obj.invoiceable_item_flag
        ,l_item_invoice_obj.invoice_enabled_flag
        ,l_item_invoice_obj.accounting_rule_id
        ,l_item_invoice_obj.invoicing_rule_id
        ,l_item_invoice_obj.tax_code
        ,l_item_invoice_obj.sales_account
        ,l_item_invoice_obj.payment_terms_id
        ,l_item_lead_time_obj.preprocessing_lead_time
        ,l_item_lead_time_obj.full_lead_time
        ,l_item_lead_time_obj.postprocessing_lead_time
        ,l_item_lead_time_obj.fixed_lead_time
        ,l_item_lead_time_obj.variable_lead_time
        ,l_item_lead_time_obj.cum_manufacturing_lead_time
        ,l_item_lead_time_obj.cumulative_total_lead_time
        ,l_item_lead_time_obj.lead_time_lot_size
        ,l_item_mrp_obj.mrp_planning_code
        ,l_item_mrp_obj.ato_forecast_control
        ,l_item_mrp_obj.planning_exception_set
        ,l_item_mrp_obj.end_assembly_pegging_flag
        ,l_item_mrp_obj.shrinkage_rate
        ,l_item_mrp_obj.rounding_control_type
        ,l_item_mrp_obj.acceptable_early_days
        ,l_item_mrp_obj.repetitive_planning_flag
        ,l_item_mrp_obj.overrun_percentage
        ,l_item_mrp_obj.acceptable_rate_increase
        ,l_item_mrp_obj.acceptable_rate_decrease
        ,l_item_mrp_obj.mrp_calculate_atp_flag
        ,l_item_mrp_obj.auto_reduce_mps
        ,l_item_mrp_obj.planning_time_fence_code
        ,l_item_mrp_obj.planning_time_fence_days
        ,l_item_mrp_obj.demand_time_fence_code
        ,l_item_mrp_obj.demand_time_fence_days
        ,l_item_mrp_obj.release_time_fence_code
        ,l_item_mrp_obj.release_time_fence_days
        ,l_item_mrp_obj.substitution_window_code
        ,l_item_mrp_obj.substitution_window_days
        ,l_item_mrp_obj.exclude_from_budget_flag
        ,l_item_mrp_obj.days_tgt_inv_supply
        ,l_item_mrp_obj.days_tgt_inv_window
        ,l_item_mrp_obj.days_max_inv_supply
        ,l_item_mrp_obj.days_max_inv_window
        ,l_item_mrp_obj.drp_planned_flag
        ,l_item_mrp_obj.critical_component_flag
        ,l_item_mrp_obj.continous_transfer
        ,l_item_mrp_obj.convergence
        ,l_item_mrp_obj.divergence
        ,l_item_order_obj.customer_order_flag
        ,l_item_order_obj.customer_order_enabled_flag
        ,l_item_order_obj.shippable_item_flag
        ,l_item_order_obj.internal_order_flag
        ,l_item_order_obj.internal_order_enabled_flag
        ,l_item_order_obj.so_transactions_flag
        ,l_item_order_obj.pick_components_flag
        ,l_item_order_obj.atp_flag
        ,l_item_order_obj.replenish_to_order_flag
        ,l_item_order_obj.atp_rule_id
        ,l_item_order_obj.atp_components_flag
        ,l_item_order_obj.ship_model_complete_flag
        ,l_item_order_obj.picking_rule_id
        ,l_item_order_obj.collateral_flag
        ,l_item_order_obj.default_shipping_org
        ,l_item_order_obj.returnable_flag
        ,l_item_order_obj.return_inspection_requireme
        ,l_item_order_obj.over_shipment_tolerance
        ,l_item_order_obj.under_shipment_tolerance
        ,l_item_order_obj.over_return_tolerance
        ,l_item_order_obj.under_return_tolerance
        ,l_item_order_obj.financing_allowed_flag
        ,l_item_order_obj.default_so_source_type
        ,l_item_phy_obj.weight_uom_code
        ,l_item_phy_obj.unit_weight
        ,l_item_phy_obj.volume_uom_code
        ,l_item_phy_obj.unit_volume
        ,l_item_phy_obj.container_item_flag
        ,l_item_phy_obj.vehicle_item_flag
        ,l_item_phy_obj.container_type_code
        ,l_item_phy_obj.internal_volume
        ,l_item_phy_obj.maximum_load_weight
        ,l_item_phy_obj.minimum_fill_percent
        ,l_item_phy_obj.equipment_type
        ,l_item_phy_obj.event_flag
        ,l_item_phy_obj.electronic_flag
        ,l_item_phy_obj.downloadable_flag
        ,l_item_phy_obj.indivisible_flag
        ,l_item_phy_obj.dimension_uom_code
        ,l_item_phy_obj.unit_length
        ,l_item_phy_obj.unit_width
        ,l_item_phy_obj.unit_height
        ,l_item_process_obj.recipe_enabled_flag
        ,l_item_process_obj.process_costing_enabled_flag
        ,l_item_process_obj.process_quality_enabled_flag
        ,l_item_process_obj.process_execution_enabled_flag
        ,l_item_process_obj.process_supply_subinventory
        ,l_item_process_obj.process_supply_locator_id
        ,l_item_process_obj.process_yield_subinventory
        ,l_item_process_obj.process_yield_locator_id
        ,l_item_process_obj.hazardous_material_flag
        ,l_item_process_obj.cas_number
        ,l_item_pur_obj.purchasing_item_flag
        ,l_item_pur_obj.purchasing_enabled_flag
        ,l_item_pur_obj.must_use_approved_vendor_fl
        ,l_item_pur_obj.allow_item_desc_update_flag
        ,l_item_pur_obj.rfq_required_flag
        ,l_item_pur_obj.outside_operation_flag
        ,l_item_pur_obj.outside_operation_uom_type
        ,l_item_pur_obj.taxable_flag
        ,l_item_pur_obj.purchasing_tax_code
        ,l_item_pur_obj.receipt_required_flag
        ,l_item_pur_obj.inspection_required_flag
        ,l_item_pur_obj.buyer_id
        ,l_item_pur_obj.unit_of_issue
        ,l_item_pur_obj.receive_close_tolerance
        ,l_item_pur_obj.invoice_close_tolerance
        ,l_item_pur_obj.un_number_id
        ,l_item_pur_obj.hazard_class_id
        ,l_item_pur_obj.list_price_per_unit
        ,l_item_pur_obj.market_price
        ,l_item_pur_obj.price_tolerance_percent
        ,l_item_pur_obj.rounding_factor
        ,l_item_pur_obj.encumbrance_account
        ,l_item_pur_obj.expense_account
        ,l_item_pur_obj.asset_category_id
        ,l_item_recving_obj.receipt_days_exception_code
        ,l_item_recving_obj.days_early_receipt_allowed
        ,l_item_recving_obj.days_late_receipt_allowed
        ,l_item_recving_obj.allow_substitute_receipts_f
        ,l_item_recving_obj.allow_unordered_receipts_fl
        ,l_item_recving_obj.allow_express_delivery_flag
        ,l_item_recving_obj.qty_rcv_exception_code
        ,l_item_recving_obj.qty_rcv_tolerance
        ,l_item_recving_obj.receiving_routing_id
        ,l_item_recving_obj.enforce_ship_to_location_c
        ,l_item_service_obj.coverage_schedule_id
        ,l_item_service_obj.service_duration
        ,l_item_service_obj.service_duration_period_cod
        ,l_item_service_obj.serviceable_product_flag
        ,l_item_service_obj.service_starting_delay
        ,l_item_service_obj.material_billable_flag
        ,l_item_service_obj.recovered_part_disp_code
        ,l_item_service_obj.defect_tracking_on_flag
        ,l_item_service_obj.comms_nl_trackable_flag
        ,l_item_service_obj.asset_creation_code
        ,l_item_service_obj.ib_item_instance_class
        ,l_item_web_opiton.orderable_on_web_flag
        ,l_item_web_opiton.back_orderable_flag
        ,l_item_web_opiton.web_status
        ,l_item_web_opiton.minimum_license_quantity
        ,l_item_wip_obj.build_in_wip_flag
        ,l_item_wip_obj.wip_supply_type
        ,l_item_wip_obj.wip_supply_subinventory
        ,l_item_wip_obj.wip_supply_locator_id
        ,l_item_wip_obj.overcompletion_tolerance_ty
        ,l_item_wip_obj.overcompletion_tolerance_va
        ,l_item_wip_obj.inventory_carry_penalty
        ,l_item_wip_obj.operation_slack_penalty
        ,l_item_custom_obj.ATTRIBUTE_CATEGORY
        ,l_item_custom_obj.ATTRIBUTE1
        ,l_item_custom_obj.ATTRIBUTE2
        ,l_item_custom_obj.ATTRIBUTE3
        ,l_item_custom_obj.ATTRIBUTE4
        ,l_item_custom_obj.ATTRIBUTE5
        ,l_item_custom_obj.ATTRIBUTE6
        ,l_item_custom_obj.ATTRIBUTE7
        ,l_item_custom_obj.ATTRIBUTE8
        ,l_item_custom_obj.ATTRIBUTE9
        ,l_item_custom_obj.ATTRIBUTE10
        ,l_item_custom_obj.ATTRIBUTE11
        ,l_item_custom_obj.ATTRIBUTE12
        ,l_item_custom_obj.ATTRIBUTE13
        ,l_item_custom_obj.ATTRIBUTE14
        ,l_item_custom_obj.ATTRIBUTE15
        ,l_item_custom_obj.ATTRIBUTE16
        ,l_item_custom_obj.ATTRIBUTE17
        ,l_item_custom_obj.ATTRIBUTE18
        ,l_item_custom_obj.ATTRIBUTE19
        ,l_item_custom_obj.ATTRIBUTE20
        ,l_item_custom_obj.ATTRIBUTE21
        ,l_item_custom_obj.ATTRIBUTE22
        ,l_item_custom_obj.ATTRIBUTE23
        ,l_item_custom_obj.ATTRIBUTE24
        ,l_item_custom_obj.ATTRIBUTE25
        ,l_item_custom_obj.ATTRIBUTE26
        ,l_item_custom_obj.ATTRIBUTE27
        ,l_item_custom_obj.ATTRIBUTE28
        ,l_item_custom_obj.ATTRIBUTE29
        ,l_item_custom_obj.ATTRIBUTE30
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE_CATEGORY
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE1
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE2
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE3
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE4
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE5
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE6
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE7
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE8
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE9
        ,l_item_custom_obj.GLOBAL_ATTRIBUTE10
      FROM  mtl_system_items_vl
      WHERE inventory_item_id=l_item_id AND organization_id=l_org_id;

   IF ( (l_item_core_obj.revision_id IS NULL OR l_item_core_obj.revision_id= fnd_api.g_miss_num)
         AND (l_org_id IS NOT NULL AND l_item_id IS NOT NULL)
       ) THEN
      l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
      l_pk_col_name_val_pairs.EXTEND(2);
      l_pk_col_name_val_pairs(1).name   := 'organization_id';
      l_pk_col_name_val_pairs(1).value  := l_org_id;
      l_pk_col_name_val_pairs(2).name   := 'inventory_item_id';
      l_pk_col_name_val_pairs(2).value  := l_item_id;
      l_item_core_obj.revision_id       := INV_EBI_ITEM_HELPER.value_to_id(
                                             p_pk_col_name_val_pairs => l_pk_col_name_val_pairs
                                            ,p_entity_name           => INV_EBI_ITEM_HELPER.G_REVISION
                                           );
      l_pk_col_name_val_pairs.TRIM(2);
   END IF;
      ctr := 1;
      FOR c IN c_mfr_part_cursor(l_item_id,l_org_id)
      LOOP
        l_item_mfr_part_obj := inv_ebi_manufacturer_part_obj(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                          ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
        l_mfr_part_table.extend();
        l_item_mfr_part_obj.manufacturer_id := c.manufacturer_id;
        l_item_mfr_part_obj.mfg_part_num := c.mfg_part_num;
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'manufacturer_id';
        l_pk_col_name_val_pairs(1).value  :=  l_item_mfr_part_obj.manufacturer_id;
        l_item_mfr_part_obj.manufacturer_name  :=  INV_EBI_ITEM_HELPER.id_to_value (
                                                       p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                      ,p_entity_name=> G_MANUFACTURER
                                                      );
        l_mfr_part_table(ctr) :=  l_item_mfr_part_obj;
        ctr := ctr + 1;
      END LOOP;

      IF (INV_EBI_UTIL.is_pim_installed) THEN -- Bug 8369900 To check is_pim_installed for reverse flow
      --Bug 7240247 To get Item udas
      get_item_uda(
        p_inventory_item_id         => l_item_core_obj.inventory_item_id,
        p_organization_id           => l_item_core_obj.organization_id,
        p_item_classification_id    => l_item_core_obj.item_catalog_group_id,
        p_revision_id               => l_item_core_obj.revision_id,
        x_item_uda                  => l_uda_obj,
        x_return_status             => l_return_status,
        x_msg_count                 => l_msg_count,
        x_msg_data                  => l_msg_data
        );
      IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        l_item_attr_tbl(i).msg_data := l_msg_data;
        RAISE FND_API.G_EXC_ERROR;
      END IF;
      END IF; --Bug 8369900 end

      --   To populate unit_cost of l_item_costing_obj
      l_item_costing_obj.unit_cost  :=  CST_COST_API.get_item_cost (
                                          p_api_version         => 1,
                                          p_inventory_item_id   => l_item_id,
                                          p_organization_id     => l_org_id,
                                          p_cost_group_id       => l_default_cost_group_id,
                                          p_cost_type_id        => l_default_cost_type_id
                                        );

      IF(l_item_core_obj.organization_id IS NOT NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'organization_id';
        l_pk_col_name_val_pairs(1).value  :=  l_item_core_obj.organization_id;
        l_item_core_obj.organization_code  :=  INV_EBI_ITEM_HELPER.id_to_value (
                                                 p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                 ,p_entity_name=> G_ORGANIZATION
                                               );
      END IF;

      IF(l_item_core_obj.template_id IS NOT NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'template_id';
        l_pk_col_name_val_pairs(1).value  :=  l_item_core_obj.template_id;
        l_item_core_obj.template_name  :=  INV_EBI_ITEM_HELPER.id_to_value(
                                             p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                             ,p_entity_name=> G_TEMPLATE
                                           );
      END IF;

      IF(l_item_core_obj.item_catalog_group_id IS NOT NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'item_catalog_group_id';
        l_pk_col_name_val_pairs(1).value  :=  l_item_core_obj.item_catalog_group_id;
        l_item_core_obj.item_catalog_group_code  :=  INV_EBI_ITEM_HELPER.id_to_value(
                                                       p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                       ,p_entity_name=> G_ITEM_CATALOG_GROUP
                                                     );
      END IF;

      IF(l_item_core_obj.lifecycle_id IS NOT NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'proj_element_id'; -- Column name not available project_element_id
        l_pk_col_name_val_pairs(1).value  := l_item_core_obj.lifecycle_id;
        l_item_core_obj.lifecycle_name  :=  INV_EBI_ITEM_HELPER.id_to_value(
                                              p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                              ,p_entity_name=> G_LIFECYCLE
                                            );
      END IF;
      IF(l_item_core_obj.current_phase_id IS NOT NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'proj_element_id';
        l_pk_col_name_val_pairs(1).value  :=  l_item_core_obj.current_phase_id;
        l_item_core_obj.current_phase_name :=  INV_EBI_ITEM_HELPER.id_to_value(
                                                 p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                 ,p_entity_name=> G_CURRENT_PHASE
                                               );
      END IF;
      IF  (l_item_core_obj.revision_id IS NOT NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'revision_id';
        l_pk_col_name_val_pairs(1).value  :=  l_item_core_obj.revision_id ;
        l_item_core_obj.revision_code     :=  INV_EBI_ITEM_HELPER.id_to_value(
                                                p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                ,p_entity_name=> G_REVISION
                                              );
      END IF;
      IF(l_item_pur_obj.hazard_class_id IS NOT NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'hazard_class_id';
        l_pk_col_name_val_pairs(1).value  :=  l_item_pur_obj.hazard_class_id;
        l_item_pur_obj.hazard_class_code  :=  INV_EBI_ITEM_HELPER.id_to_value(
                                                p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                ,p_entity_name=> G_HAZARD_CLASS
                                              );
      END IF;
      IF  (l_item_pur_obj.asset_category_id  IS NOT NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name   := 'category_id';
        l_pk_col_name_val_pairs(1).value  :=  l_item_pur_obj.asset_category_id ;
        l_item_pur_obj.asset_category_code  :=  INV_EBI_ITEM_HELPER.id_to_value(
                                                  p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                  ,p_entity_name=> G_ASSET_CATEGORY
                                                );
      END IF;
      IF  (l_item_bom_obj.base_item_id  IS NOT NULL) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(2);
        l_pk_col_name_val_pairs(1).name   := 'inventory_item_id';
        l_pk_col_name_val_pairs(1).value  :=  l_item_bom_obj.base_item_id;
        l_pk_col_name_val_pairs(2).name   := 'organization_id';
        l_pk_col_name_val_pairs(2).value  :=  l_item_core_obj.organization_id;
        l_item_bom_obj.base_item_number  :=  INV_EBI_ITEM_HELPER.id_to_value(
                                               p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                               ,p_entity_name=> G_INVENTORY_ITEM
                                             );
      END IF;
      -- gets the item number
      l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
      l_pk_col_name_val_pairs.EXTEND(1);
      l_pk_col_name_val_pairs(1).name   := 'organization_id';
      l_pk_col_name_val_pairs(1).value  := l_item_core_obj.organization_id;
      l_pk_col_name_val_pairs.EXTEND(1);
      l_pk_col_name_val_pairs(2).name   := 'inventory_item_id';
      l_pk_col_name_val_pairs(2).value  := l_item_core_obj.inventory_item_id;
      l_item_core_obj.item_name :=  INV_EBI_ITEM_HELPER.id_to_value(
                                      p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                      ,p_entity_name=> G_INVENTORY_ITEM
                                    );
      SELECT MASTER_ORGANIZATION_ID INTO l_item_core_obj.MASTER_ORGANIZATION_ID
      FROM mtl_parameters WHERE organization_id=l_org_id;
      -- converts the master org id to master org code
      l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
      l_pk_col_name_val_pairs.EXTEND(1);
      l_pk_col_name_val_pairs(1).name   := 'organization_id';
      l_pk_col_name_val_pairs(1).value  := l_item_core_obj.master_organization_id;
      l_item_core_obj.master_organization_code :=  INV_EBI_ITEM_HELPER.id_to_value(
                                                     p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                     ,p_entity_name=> INV_EBI_ITEM_HELPER.G_ORGANIZATION
                                                   );
      IF(NOT (l_getassetmgmtattrs = FND_API.G_TRUE) AND NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_asset_obj := NULL;
      END IF;
      IF(NOT(l_getbomattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_bom_obj := NULL;
      END IF;
      IF(NOT(l_getcostingattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_costing_obj := NULL;
      END IF;
      IF(NOT(l_getgeneralplanningattrs = FND_API.G_TRUE) AND NOT(l_getitemoprattrs = FND_API.G_TRUE ))THEN
        l_item_gplan_obj := NULL;
      END IF;
      IF(NOT(l_getinventoryattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_inv_obj := NULL;
      END IF;
      IF(NOT(l_getinvoicingattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_invoice_obj := NULL;
      END IF;
      IF(NOT(l_getleadtimeattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_lead_time_obj := NULL;
      END IF;
      IF(NOT(l_getmpsmrpplanningattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_mrp_obj := NULL;
      END IF;
      IF(NOT(l_getorderattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_order_obj := NULL;
      END IF;
      IF(NOT(l_getphysicalattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_phy_obj := NULL;
      END IF;
      IF(NOT(l_getprocessattrs=FND_API.G_TRUE) AND NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_process_obj := NULL;
      END IF;
      IF(NOT(l_getpurchasingattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE )) THEN
        l_item_pur_obj := NULL;
      END IF;
      IF(NOT(l_getrecevingattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE ))THEN
        l_item_recving_obj := NULL;
      END IF;
      IF(NOT(l_getserviceattrs = FND_API.G_TRUE) AND  NOT(l_getitemoprattrs = FND_API.G_TRUE ))THEN
        l_item_service_obj := NULL;
      END IF;
      IF(NOT(l_getweboptionattrs = FND_API.G_TRUE) AND NOT(l_getitemoprattrs = FND_API.G_TRUE ))THEN
        l_item_web_opiton := NULL;
      END IF;
      IF(NOT(l_getwipattrs = FND_API.G_TRUE) AND NOT(l_getitemoprattrs = FND_API.G_TRUE ))THEN
        l_item_wip_obj := NULL;
      END IF;
      l_item_obj := inv_ebi_item_obj(l_item_core_obj
                                          ,l_item_phy_obj
                                          ,l_item_inv_obj
                                          ,l_item_pur_obj
                                          ,l_item_recving_obj
                                          ,l_item_gplan_obj
                                          ,l_item_mrp_obj
                                          ,l_item_order_obj
                                          ,l_item_service_obj
                                          ,l_item_bom_obj
                                          ,l_item_costing_obj
                                          ,l_item_lead_time_obj
                                          ,l_item_wip_obj
                                          ,l_item_invoice_obj
                                          ,l_item_web_opiton
                                          ,l_item_asset_obj
                                          ,NULL
                                          ,l_item_process_obj
                                          ,l_item_custom_obj
                                          ,NULL
                                          ,NULL
                                          ,l_mfr_part_table
                                          ,l_uda_obj
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                          ,NULL
                                     );
        get_Operating_unit
        (p_oranization_id => l_org_id
        ,x_operating_unit => l_item_obj.operating_unit
        ,x_ouid      => l_item_obj.operating_unit_id
        );
      l_item_attr_tbl(i).item_obj := l_item_obj;
      EXCEPTION
       WHEN FND_API.G_EXC_ERROR THEN
         x_return_status := FND_API.G_RET_STS_ERROR;
         l_item_attr_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
         IF l_item_attr_tbl(i).msg_data IS NOT NULL THEN
           FND_MSG_PUB.count_and_get(
             p_encoded => FND_API.g_false
             ,p_count  => l_item_attr_tbl(i).msg_count
             ,p_data   => l_item_attr_tbl(i).msg_data
           );
         END IF;
         populate_err_msg(p_orgid           => l_org_id
                          ,p_invid          => l_item_id
                          ,p_org_code        => p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i).organization_code
                          ,p_item_name       => p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i).item_name
                          ,p_part_err_msg    => l_item_attr_tbl(i).msg_data
                          ,x_err_msg         => x_msg_data
                           );
       WHEN OTHERS THEN
         x_return_status  :=  FND_API.G_RET_STS_ERROR;
         l_item_attr_tbl(i).return_status := FND_API.G_RET_STS_ERROR;
        populate_err_msg(p_orgid            => l_org_id
                          ,p_invid          => l_item_id
                          ,p_org_code        => p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i).organization_code
                          ,p_item_name       => p_get_item_inp_obj.p_get_opr_attrs_tbl_type(i).item_name
                          ,p_part_err_msg    => SQLERRM||' -> at inv_ebi_item_helper.get_item_attributes'
                          ,x_err_msg         => x_msg_data
                           );
      END;
    END LOOP;
    x_item_tbl_obj:=inv_ebi_item_attr_tbl_obj(l_item_attr_tbl);
  EXCEPTION
    WHEN OTHERS THEN
      x_return_status := FND_API.G_RET_STS_ERROR;
      IF (x_msg_data IS NOT NULL) THEN
        x_msg_data  :=  x_msg_data ||' -> at INV_EBI_ITEM_HELPER.get_item_attributes';
      ELSE
        x_msg_data   :=   SQLERRM||' at INV_EBI_ITEM_HELPER.get_item_attributes';
      END IF;
END get_item_attributes;


/***************************************************************************************************
--      API name        : get_last_run_date
--      Type            : Private For Internal Use Only
--      Purpose         : To get the last run date of the concurrent program
*****************************************************************************************************/

FUNCTION  get_last_run_date( p_conc_prog_id  IN             NUMBER
                           ,p_appl_id        IN             NUMBER
                           ) RETURN DATE
IS
  l_date   DATE :=NULL;
  CURSOR c_last_sche_comp_date
  IS
  SELECT actual_start_date FROM (
    SELECT actual_start_date
    FROM fnd_concurrent_requests
    WHERE  program_application_id = p_appl_id
    AND    concurrent_program_id =  p_conc_prog_id
    AND    UPPER(phase_code) = 'C'
    AND    (root_request_id is not null OR resubmit_interval is not null)
    AND    actual_start_date is not null
    ORDER BY actual_start_date DESC)
  WHERE ROWNUM = 1;

  CURSOR c_last_comp_date
  IS
  SELECT actual_start_date INTO l_date FROM (
    SELECT actual_start_date
    FROM fnd_concurrent_requests
    WHERE  program_application_id = p_appl_id
    AND    concurrent_program_id =  p_conc_prog_id
    AND    UPPER(phase_code) = 'C'
    AND    actual_start_date is not null
    ORDER BY actual_start_date DESC)
  WHERE ROWNUM = 1;

BEGIN
  IF c_last_sche_comp_date%ISOPEN THEN
    CLOSE c_last_sche_comp_date;
  END IF;

  OPEN c_last_sche_comp_date;
  FETCH c_last_sche_comp_date into l_date;
  CLOSE c_last_sche_comp_date;

  IF l_date IS NULL THEN
    IF c_last_comp_date%ISOPEN THEN
      CLOSE c_last_comp_date;
    END IF;
    OPEN c_last_comp_date;
      FETCH c_last_comp_date into l_date;
    CLOSE c_last_comp_date;
  END IF;

  IF l_date IS NULL THEN
    l_date := SYSDATE-30;
  END IF;

  RETURN l_date;
EXCEPTION
  WHEN OTHERS THEN
    IF c_last_sche_comp_date%ISOPEN THEN
      CLOSE c_last_sche_comp_date;
    END IF;
    IF c_last_comp_date%ISOPEN THEN
      CLOSE c_last_comp_date;
    END IF;
END get_last_run_date;

/************************************************************************************
--      API name        : parse_input_String
--      Type            : Public
--      Function        : To parse the input string
************************************************************************************/

FUNCTION parse_input_string(
  p_input_string              IN        VARCHAR2
)
RETURN  FND_TABLE_OF_VARCHAR2_255
IS
  l_input_string           VARCHAR2(240);
  l_count                  NUMBER:=0;
  l_length                 NUMBER:=0;
  l_parsed_tbl             FND_TABLE_OF_VARCHAR2_255;
BEGIN
  l_input_string           := p_input_string;
  l_parsed_tbl             := FND_TABLE_OF_VARCHAR2_255();
  l_length := LENGTH(l_input_string);

  IF (SUBSTR(l_input_string,l_length-1) <> ';;') THEN
    l_input_string := l_input_string || ';;';
  END IF;

  WHILE INSTR(l_input_string,';;') > 0 LOOP
    l_parsed_tbl.EXTEND(1);
    l_count := l_count+1;
    l_parsed_tbl(l_count) := SUBSTR(l_input_string,1,INSTR(l_input_string,';;')-1) ;
    l_input_string            :=  SUBSTR(l_input_string,INSTR(l_input_string,';;')+2);
  END LOOP;

  RETURN l_parsed_tbl;
END parse_input_string;
/************************************************************************************
--      API name        : filter_items_based_on_org
--      Type            : Public
--      Function        : To filter items based on the given organization
************************************************************************************/

PROCEDURE filter_items_based_on_org(
  p_org_codes              IN         VARCHAR2
 ,p_item_tbl               IN         inv_ebi_get_opr_attrs_tbl
 ,x_item_tbl               OUT NOCOPY inv_ebi_get_opr_attrs_tbl
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2)
IS
  l_org_tbl                  FND_TABLE_OF_VARCHAR2_255;
  l_item_output_tbl          inv_ebi_get_opr_attrs_tbl;
  l_counter                  NUMBER:=0;
BEGIN
  x_return_status := FND_API.g_ret_sts_success;
  l_item_output_tbl       := inv_ebi_get_opr_attrs_tbl();

  IF p_org_codes IS NOT NULL THEN
    l_org_tbl := parse_input_string(p_org_codes);
  END IF;

  IF p_item_tbl IS NOT NULL AND p_item_tbl.COUNT>0 THEN
    FOR i in p_item_tbl.FIRST..p_item_tbl.LAST LOOP
      IF l_org_tbl IS NOT NULL AND l_org_tbl.COUNT>0 THEN
        FOR j in l_org_tbl.FIRST..l_org_tbl.LAST LOOP
          IF (p_item_tbl(i).organization_code = l_org_tbl(j)) THEN
            l_counter := l_counter + 1;
            l_item_output_tbl.EXTEND(1);
            l_item_output_tbl(l_counter) := p_item_tbl(i);
            EXIT;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END IF;

  x_item_tbl := l_item_output_tbl;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at INV_EBI_ITEM_HELPER.filter_items_based_on_org';
END filter_items_based_on_org;

/************************************************************************************
--      API name        : parse_and_get_item
--      Type            : Private For Internal Use Only
--      Function        : To parse the input string and get list of items
************************************************************************************/
PROCEDURE parse_and_get_item(
  p_item_names              IN        VARCHAR2
 ,p_org_codes               IN        VARCHAR2
 ,x_item_tbl               OUT NOCOPY inv_ebi_get_opr_attrs_tbl
 ,x_return_status          OUT NOCOPY VARCHAR2
 ,x_msg_count              OUT NOCOPY NUMBER
 ,x_msg_data               OUT NOCOPY VARCHAR2)
IS
  l_return_status            VARCHAR2(2);
  l_msg_data                 VARCHAR2(2000);
  l_count                    NUMBER:=0;
  l_counter                  NUMBER := 0;
  l_entity_exist             NUMBER :=0;
  l_entity_count             NUMBER :=0;
  l_org_id                   NUMBER;
  l_item_id                  NUMBER;
  l_item_output_tbl          inv_ebi_get_opr_attrs_tbl;
  l_item_obj                 inv_ebi_get_operational_attrs;
  l_item_tbl                 FND_TABLE_OF_VARCHAR2_255;
  l_org_tbl                  FND_TABLE_OF_VARCHAR2_255;
  l_valid_item_tbl           FND_TABLE_OF_VARCHAR2_255;
  l_valid_org_tbl            FND_TABLE_OF_VARCHAR2_255;
  l_pk_col_name_val_pairs    INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl ;
  CURSOR c_get_all_orgs(p_item_name VARCHAR2) IS
    SELECT msik.inventory_item_id,msik.organization_id,mp.organization_code
    FROM mtl_system_items_kfv msik,mtl_parameters  mp
    WHERE msik.concatenated_segments = p_item_name
    AND msik.organization_id = mp.organization_id;
BEGIN
  x_return_status := FND_API.g_ret_sts_success;
  l_item_output_tbl       := inv_ebi_get_opr_attrs_tbl();

  IF p_item_names IS NOT NULL THEN
    l_item_tbl := parse_input_string(p_item_names);
  END IF;

  IF p_org_codes IS NOT NULL THEN
    l_org_tbl := parse_input_string(p_org_codes);
  END IF;
  IF l_item_tbl IS NOT NULL AND l_item_tbl.COUNT > 0 THEN
    l_valid_item_tbl := FND_TABLE_OF_VARCHAR2_255();
    l_entity_count :=0;
    FOR i in l_item_tbl.FIRST..l_item_tbl.LAST LOOP
      BEGIN
        FND_MSG_PUB.initialize();
        SELECT COUNT(1) into l_entity_exist
        FROM mtl_system_items_kfv
        WHERE concatenated_segments = l_item_tbl(i);
        IF l_entity_exist>0 THEN
          l_entity_count := l_entity_count +1;
          l_valid_item_tbl.EXTEND();
          l_valid_item_tbl(l_entity_count) := l_item_tbl(i);
        ELSE
          FND_MESSAGE.set_name('INV','INV_EBI_ITEM_INVALID');
          FND_MESSAGE.set_token('COL_VALUE', l_item_tbl(i));
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error;
          FND_MSG_PUB.count_and_get( p_encoded => FND_API.g_false
                                     ,p_count   => x_msg_count
                                     ,p_data    => l_msg_data
                                   );
          x_msg_data :=  x_msg_data || l_msg_data ||' , ' ;
        WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_error;
          x_msg_data := SQLERRM ||' at INV_EBI_ITEM_HELPER.parse_and_get_item';
      END;
    END LOOP;
  END IF;
  IF l_org_tbl IS NOT NULL AND l_org_tbl.COUNT > 0 THEN
    l_valid_org_tbl := FND_TABLE_OF_VARCHAR2_255();
    l_entity_count :=0;
    FOR i in l_org_tbl.FIRST..l_org_tbl.LAST LOOP
      BEGIN
        FND_MSG_PUB.initialize();
        SELECT COUNT(1) into l_entity_exist
          FROM mtl_parameters
        WHERE organization_code = l_org_tbl(i);
        IF l_entity_exist>0 THEN
          l_entity_count := l_entity_count +1;
          l_valid_org_tbl.EXTEND();
          l_valid_org_tbl(l_entity_count) := l_org_tbl(i);
        ELSE
          FND_MESSAGE.set_name('INV','INV_EBI_ORG_CODE_INVALID');
          FND_MESSAGE.set_token('COL_VALUE', l_org_tbl(i));
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error;
          FND_MSG_PUB.count_and_get( p_encoded => FND_API.g_false
                                     ,p_count   => x_msg_count
                                     ,p_data    => l_msg_data
                                   );
          x_msg_data :=  x_msg_data || l_msg_data ||' , ' ;
        WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_error;
          x_msg_data := SQLERRM ||' at INV_EBI_ITEM_HELPER.parse_and_get_item';
      END;
    END LOOP;
  END IF;
  IF l_valid_item_tbl IS NOT NULL AND l_valid_item_tbl.COUNT > 0 THEN
    FOR i in l_valid_item_tbl.FIRST..l_valid_item_tbl.LAST LOOP
      BEGIN
        FND_MSG_PUB.initialize();
        l_count :=0;
        IF l_valid_org_tbl IS NOT NULL AND l_valid_org_tbl.COUNT > 0 THEN
          FOR j in l_valid_org_tbl.FIRST..l_valid_org_tbl.LAST LOOP
            l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
            l_pk_col_name_val_pairs.EXTEND();
            l_pk_col_name_val_pairs(1).name  := 'organization_code';
            l_pk_col_name_val_pairs(1).value := l_valid_org_tbl(j);
            l_org_id                         := INV_EBI_ITEM_HELPER.value_to_id( p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                                                 ,p_entity_name            => INV_EBI_ITEM_HELPER.G_ORGANIZATION
                                                                               );
            l_pk_col_name_val_pairs.TRIM(1);
            l_pk_col_name_val_pairs.EXTEND(2);
            l_pk_col_name_val_pairs(1).name  := 'concatenated_segments';
            l_pk_col_name_val_pairs(1).value := l_valid_item_tbl(i);
            l_pk_col_name_val_pairs(2).name  := 'organization_id';
            l_pk_col_name_val_pairs(2).value := l_org_id;
            l_item_id                        := INV_EBI_ITEM_HELPER.value_to_id( p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                                                                ,p_entity_name            => INV_EBI_ITEM_HELPER.G_INVENTORY_ITEM
                                                                                );
            l_pk_col_name_val_pairs.TRIM(2);

            IF l_item_id IS NOT NULL THEN
              l_counter := l_counter + 1;
              l_item_obj  :=  inv_ebi_get_operational_attrs( l_item_id, l_valid_item_tbl(i) , l_org_id, l_valid_org_tbl(j),NULL,NULL);
              l_item_output_tbl.EXTEND(1);
              l_item_output_tbl(l_counter) := l_item_obj;
              l_count := 1;
            END IF;

          END LOOP;
        ELSE
          FOR cur IN c_get_all_orgs(l_valid_item_tbl(i)) LOOP
            l_counter := l_counter + 1;
            l_item_obj  :=  inv_ebi_get_operational_attrs( cur.inventory_item_id, l_valid_item_tbl(i) , cur.organization_id, cur.organization_code,NULL,NULL);
            l_item_output_tbl.EXTEND(1);
            l_item_output_tbl(l_counter) := l_item_obj;
            l_count := 1;
          END LOOP;
        END IF;

        IF l_count = 0 THEN
          FND_MESSAGE.set_name('INV','INV_EBI_INVALID_USER_INPUT');
          FND_MESSAGE.set_token('USER_INPUT', l_valid_item_tbl(i));
          FND_MSG_PUB.add;
          RAISE FND_API.G_EXC_ERROR;
        END IF;
      EXCEPTION
        WHEN FND_API.G_EXC_ERROR THEN
          x_return_status := FND_API.g_ret_sts_error;
          FND_MSG_PUB.count_and_get( p_encoded => FND_API.g_false
                                  ,p_count   => x_msg_count
                                  ,p_data    => l_msg_data
                                 );
          x_msg_data := x_msg_data || l_msg_data  ;
        WHEN OTHERS THEN
          x_return_status := FND_API.g_ret_sts_unexp_error;
          x_msg_data := SQLERRM ||' at INV_EBI_ITEM_HELPER.parse_and_get_item';
      END;
    END LOOP;
  END IF;
  x_item_tbl := l_item_output_tbl;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at INV_EBI_ITEM_HELPER.parse_and_get_item';
END parse_and_get_item;

/************************************************************************************
--      API name        : parse_source_system_string
--      Type            : Public
--      Function        : To parse the input string
************************************************************************************/

FUNCTION parse_source_system_string(
  p_input_string              IN        VARCHAR2
)
RETURN  FND_TABLE_OF_VARCHAR2_255
IS
  l_cross_reference_type   VARCHAR2(32000);
  l_count                  NUMBER:=0;
  l_parsed_tbl             FND_TABLE_OF_VARCHAR2_255;
BEGIN
  l_cross_reference_type   := TRIM(',' FROM p_input_string);
  l_parsed_tbl             := FND_TABLE_OF_VARCHAR2_255();
  l_cross_reference_type   := l_cross_reference_type || ',';
  WHILE INSTR(l_cross_reference_type,',') > 0 LOOP
    l_parsed_tbl.EXTEND(1);
    l_count := l_count+1;
    l_parsed_tbl(l_count)  := SUBSTR(l_cross_reference_type,1,INSTR(l_cross_reference_type,',')-1) ;
    l_cross_reference_type := SUBSTR(l_cross_reference_type,INSTR(l_cross_reference_type,',')+1);
  END LOOP;
  RETURN l_parsed_tbl;
END parse_source_system_string;

/************************************************************************************
--      API name        : get_item_attributes_list
--      Type            : Public For Internal Use Only
--      Function        :
************************************************************************************/
PROCEDURE get_item_attributes_list(
  p_name_value_list         IN             inv_ebi_name_value_tbl
 ,p_prog_id                 IN             NUMBER
 ,p_appl_id                 IN             NUMBER
 ,p_cross_reference_type    IN             VARCHAR2
 ,x_items                  OUT NOCOPY      inv_ebi_get_opr_attrs_tbl
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
)
IS
  l_return_status            VARCHAR2(2);
  l_item_string              VARCHAR2(32000);
  l_org_string               VARCHAR2(32000);
  l_from_date                DATE := NULL;
  l_to_date                  DATE := NULL;
  l_from_date_str            VARCHAR2(30);
  l_to_date_str              VARCHAR2(30);
  l_last_x_hrs               NUMBER;
  l_item_org_output_tbl      inv_ebi_get_opr_attrs_tbl;
  l_item_tbl                 inv_ebi_get_opr_attrs_tbl;
  l_item_output_tbl          inv_ebi_get_opr_attrs_tbl;
  l_item_tbl_flst            inv_ebi_get_opr_attrs_tbl;
  l_msg_data                 VARCHAR2(2000);
  l_msg_count                NUMBER;
  l_parsed_tbl               FND_TABLE_OF_VARCHAR2_255;

  CURSOR c_get_item_list_pim IS
    SELECT inv_ebi_get_operational_attrs(item_pim.inventory_item_id,item_pim.concatenated_segments,item_pim.organization_id,item_pim.organization_code,NULL,NULL)
    FROM
      (SELECT mcr.inventory_item_id, msik.concatenated_segments, msi.organization_id, mp.organization_code
       FROM mtl_cross_references_b mcr, mtl_system_items_b msi, mtl_parameters mp, mtl_system_items_kfv msik, hz_orig_systems_b hz
       WHERE mcr.inventory_item_id = msi.inventory_item_id
     --AND mcr.organization_id = msi.organization_id   --8897962 mcr has organization_id value as null
       AND hz.orig_system IN (SELECT * FROM THE(SELECT CAST(l_parsed_tbl AS FND_TABLE_OF_VARCHAR2_255) FROM DUAL))
       AND hz.orig_system_id = mcr.source_system_id
       AND msi.organization_id = mp.organization_id
       AND msik.organization_id = msi.organization_id
       AND msik.inventory_item_id = msi.inventory_item_id
       AND msi.last_update_date <> msi.creation_date
       AND msi.last_update_date >= l_from_date
       AND msi.last_update_date <= l_to_date
       UNION
       SELECT cic.inventory_item_id, msik.concatenated_segments, cic.organization_id, mp.organization_code
       FROM   mtl_cross_references_b mcr, cst_item_costs cic,mtl_parameters mp, mtl_system_items_kfv msik, hz_orig_systems_b hz
       WHERE  mcr.inventory_item_id = cic.inventory_item_id
     --AND    mcr.organization_id = cic.organization_id
       AND    msik.organization_id = mp.organization_id
       AND    msik.organization_id = cic.organization_id
       AND    msik.inventory_item_id = cic.inventory_item_id
       AND    cic.last_update_date <> cic.creation_date
       AND    hz.orig_system IN (SELECT * FROM THE(SELECT CAST(l_parsed_tbl AS FND_TABLE_OF_VARCHAR2_255) FROM DUAL))
       AND    hz.orig_system_id = mcr.source_system_id
       AND    cic.last_update_date >= l_from_date
       AND    cic.last_update_date <= l_to_date
       UNION
       SELECT  cql.inventory_item_id, msik.concatenated_segments, cql.organization_id, mp.organization_code
       FROM    mtl_cross_references_b mcr, cst_quantity_layers cql, mtl_parameters mp, mtl_system_items_kfv msik, hz_orig_systems_b hz
       WHERE   mcr.inventory_item_id = cql.inventory_item_id
     --AND     mcr.organization_id = cql.organization_id
       AND     msik.organization_id = mp.organization_id
       AND     hz.orig_system IN (SELECT * FROM THE(SELECT CAST(l_parsed_tbl AS FND_TABLE_OF_VARCHAR2_255) FROM DUAL))
       AND     hz.orig_system_id = mcr.source_system_id
       AND     msik.organization_id = cql.organization_id
       AND     msik.inventory_item_id = cql.inventory_item_id
       AND     cql.last_update_date >= l_from_date
       AND     cql.last_update_date <= l_to_date) item_pim;

CURSOR c_get_item_list IS
    SELECT inv_ebi_get_operational_attrs(item_npim.inventory_item_id,item_npim.concatenated_segments,item_npim.organization_id,item_npim.organization_code,NULL,NULL)
    FROM
      (SELECT msi.inventory_item_id, msik.concatenated_segments, msi.organization_id, mp.organization_code
       FROM   mtl_system_items_b msi, mtl_parameters mp, mtl_system_items_kfv msik
       WHERE  msi.organization_id = mp.organization_id
       AND    msik.organization_id = msi.organization_id
       AND    msik.inventory_item_id = msi.inventory_item_id
       AND    msi.last_update_date <> msi.creation_date
       AND    msi.last_update_date >= l_from_date
       AND    msi.last_update_date <= l_to_date
       UNION
       SELECT cic.inventory_item_id,  msik.concatenated_segments, cic.organization_id, mp.organization_code
       FROM   cst_item_costs cic, mtl_parameters mp,  mtl_system_items_kfv msik
       WHERE  cic.organization_id = mp.organization_id
       AND    msik.organization_id = cic.organization_id
       AND    msik.inventory_item_id = cic.inventory_item_id
       AND    cic.last_update_date <> cic.creation_date
       AND    cic.last_update_date >= l_from_date
       AND    cic.last_update_date <= l_to_date
       UNION
       SELECT cql.inventory_item_id, msik.concatenated_segments, cql.organization_id, mp.organization_code
       FROM   cst_quantity_layers cql,mtl_parameters mp,  mtl_system_items_kfv msik
       WHERE  cql.organization_id=mp.organization_id
       AND    msik.organization_id = cql.organization_id
       AND    msik.inventory_item_id = cql.inventory_item_id
       AND    cql.last_update_date >= l_from_date
       AND    cql.last_update_date <= l_to_date
       ) item_npim;

  CURSOR c_get_item_flist IS
    SELECT inv_ebi_get_operational_attrs(item_flst.item_id,item_flst.item_name,item_flst.organization_id,item_flst.organization_code,NULL,NULL)
    FROM (
      SELECT a.item_id,a.item_name, a.organization_id,a.organization_code
      FROM THE (SELECT CAST( l_item_output_tbl as inv_ebi_get_opr_attrs_tbl)
                 FROM dual ) a
    INTERSECT
      SELECT b.item_id,b.item_name, b.organization_id,b.organization_code
      FROM THE (SELECT CAST( l_item_tbl as inv_ebi_get_opr_attrs_tbl)
                 FROM dual ) b
       ) item_flst;
BEGIN
  FND_MSG_PUB.initialize();
  x_return_status := FND_API.g_ret_sts_success;

  IF (p_cross_reference_type IS NOT NULL AND p_cross_reference_type <> FND_API.G_MISS_CHAR) THEN
    l_parsed_tbl := parse_source_system_string(p_cross_reference_type);
  END IF;

  --Getting the values for the parameters passed from CP
  IF (p_name_value_list IS NOT NULL AND  p_name_value_list.COUNT > 0) THEN
    l_item_string   := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'Item Name');
    l_org_string    := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'Organization Code');
    l_from_date_str := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'From Date');
    l_to_date_str   := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'To Date');
    l_last_x_hrs   := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'Updated in the last X Hrs');

    IF l_from_date_str IS NOT NULL THEN
      l_from_date   := TO_DATE(l_from_date_str,'YYYY/MM/DD HH24:MI:SS');
    END IF;

    IF l_to_date_str IS NOT NULL THEN
      l_to_date     := TO_DATE(l_to_date_str,'YYYY/MM/DD HH24:MI:SS');
    END IF;

    IF l_last_x_hrs IS NOT NULL THEN
      l_from_date   := SYSDATE-( l_last_x_hrs/24);
      l_to_date     := SYSDATE ;
    END IF;
  END IF;

  -- If all the parameter values are null then fetch items that got updated
  -- from the last successfull completiopn date of CP
  IF (l_item_string IS NULL AND l_from_date IS NULL AND l_to_date IS NULL AND l_last_x_hrs IS NULL) THEN
    l_from_date :=INV_EBI_ITEM_HELPER.get_last_run_date( p_conc_prog_id => p_prog_id
                                    ,p_appl_id      => p_appl_id
                                    );
    l_to_date := SYSDATE;
  END IF;

  IF l_from_date IS NOT NULL AND l_to_date IS NULL THEN
    l_to_date := SYSDATE;
  END IF;

  -- Get the valid combination of Items and Organizations
  IF ( l_item_string IS NOT NULL  ) THEN
    parse_and_get_item( p_item_names            => l_item_string
                       ,p_org_codes             => l_org_string
                       ,x_item_tbl              => l_item_output_tbl
                       ,x_return_status         => l_return_status
                       ,x_msg_count             => l_msg_count
                       ,x_msg_data              => l_msg_data);
  END IF;


  IF (l_return_status  <> FND_API.g_ret_sts_success) THEN
    x_return_status := l_return_status;
    IF  l_msg_data IS NOT NULL THEN
      x_msg_data := l_msg_data;
    END IF;
  END IF;

  x_items := l_item_output_tbl;

  -- Filtering the Items that got updated within the given dates
  IF (l_from_date IS NOT NULL AND l_to_date IS NOT NULL) THEN
    IF(INV_EBI_UTIL.is_pim_installed AND l_parsed_tbl IS NOT NULL AND l_parsed_tbl.COUNT>0) THEN
      --Fetched the data based on the source system reference
      IF (c_get_item_list_pim%ISOPEN) THEN
        CLOSE c_get_item_list_pim;
      END IF;
      OPEN  c_get_item_list_pim;
      FETCH c_get_item_list_pim BULK COLLECT INTO l_item_tbl;
      CLOSE c_get_item_list_pim;
    ELSE
     --Fetch all the records irrespective of source system reference
      IF (c_get_item_list%ISOPEN) THEN
        CLOSE c_get_item_list;
      END IF;
      OPEN  c_get_item_list;
      FETCH c_get_item_list BULK COLLECT INTO l_item_tbl;
      CLOSE c_get_item_list;
    END IF;

    IF (l_item_string IS NOT NULL) THEN
      IF (c_get_item_flist%ISOPEN) THEN
        CLOSE c_get_item_flist;
      END IF;
      OPEN c_get_item_flist;
      FETCH c_get_item_flist BULK COLLECT INTO l_item_tbl_flst;
      CLOSE c_get_item_flist;
      x_items := l_item_tbl_flst;
    -- Filtering the Items that got updated in the specified time in the given Orgs
    ELSIF (l_org_string IS NOT NULL) THEN
      filter_items_based_on_org( p_org_codes            => l_org_string
                                ,p_item_tbl             => l_item_tbl
                                ,x_item_tbl             => l_item_org_output_tbl
                                ,x_return_status        => l_return_status
                                ,x_msg_count            => l_msg_count
                                ,x_msg_data             => l_msg_data);
      IF (l_return_status  = FND_API.g_ret_sts_success) THEN
        x_items := l_item_org_output_tbl;
      ELSE
        x_return_status := l_return_status;
        IF  l_msg_data IS NOT NULL THEN
          x_msg_data := l_msg_data;
        END IF;
      END IF;
    ELSE
      x_items := l_item_tbl;
    END IF;
  END IF;
  IF  x_items is NOT NULL AND x_items.COUNT > 0 then
    FOR i IN 1..x_items.COUNT
    LOOP
      get_Operating_unit
        (p_oranization_id => x_items(i).organization_id
        ,x_operating_unit => x_items(i).operating_unit
        ,x_ouid           => x_items(i).operating_unit_id
        );
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at INV_EBI_ITEM_HELPER.get_item_attributes_list';
    IF (c_get_item_flist%ISOPEN) THEN
      CLOSE c_get_item_flist;
    END IF;
    IF (c_get_item_list%ISOPEN) THEN
      CLOSE c_get_item_list;
    END IF;
    IF (c_get_item_list_pim%ISOPEN) THEN
      CLOSE c_get_item_list_pim;
    END IF;
END get_item_attributes_list;

/************************************************************************************
--      API name        : get_item_balance_list
--      Type            : Public
--      Function        :
************************************************************************************/
PROCEDURE get_item_balance_list(
  p_name_value_list         IN             inv_ebi_name_value_tbl
 ,p_prog_id                 IN             NUMBER
 ,p_appl_id                 IN             NUMBER
 ,p_cross_reference_type    IN             VARCHAR2
 ,x_items                  OUT NOCOPY      inv_ebi_get_opr_attrs_tbl
 ,x_return_status          OUT NOCOPY      VARCHAR2
 ,x_msg_count              OUT NOCOPY      NUMBER
 ,x_msg_data               OUT NOCOPY      VARCHAR2
)
IS
  l_return_status            VARCHAR2(2);
  l_item_string              VARCHAR2(32000);
  l_org_string               VARCHAR2(32000);
  l_item_name                VARCHAR2(40);
  l_org_code                 VARCHAR2(40);
  l_from_date                DATE := NULL;
  l_to_date                  DATE := NULL;
  l_from_date_str            VARCHAR2(30);
  l_to_date_str              VARCHAR2(30);
  l_last_x_hrs               NUMBER;
  l_item_tbl                inv_ebi_get_opr_attrs_tbl;
  l_item_output_tbl         inv_ebi_get_opr_attrs_tbl;
  l_item_org_output_tbl     inv_ebi_get_opr_attrs_tbl;
  l_item_tbl_flst           inv_ebi_get_opr_attrs_tbl;
  l_msg_data                 VARCHAR2(2000);
  l_msg_count                NUMBER;
  l_parsed_tbl               FND_TABLE_OF_VARCHAR2_255;

  CURSOR c_get_bal_item_lst_pim IS  --8897962
    SELECT inv_ebi_get_operational_attrs(gibp.inventory_item_id,gibp.concatenated_segments, gibp.organization_id,gibp.organization_code,NULL,NULL)
    FROM (
      SELECT DISTINCT mcr.inventory_item_id,msik.concatenated_segments,moq.organization_id,mp.organization_code
      FROM   mtl_onhand_quantities_detail moq,mtl_cross_references_b mcr, mtl_parameters mp, mtl_system_items_kfv msik, hz_orig_systems_b hz
      WHERE  mcr.inventory_item_id = moq.inventory_item_id
    --AND    mcr.organization_id = moq.organization_id
      AND    moq.organization_id = mp.organization_id
      AND    msik.organization_id  = moq.organization_id
      AND    msik.inventory_item_id = moq.inventory_item_id
      AND    hz.orig_system IN (SELECT * FROM THE(SELECT CAST(l_parsed_tbl AS FND_TABLE_OF_VARCHAR2_255) FROM DUAL))
      AND    hz.orig_system_id = mcr.source_system_id
      AND    moq.last_update_date >= l_from_date
      AND    moq.last_update_date <= l_to_date) gibp;

  CURSOR c_get_bal_item_lst IS
    SELECT inv_ebi_get_operational_attrs(gib.inventory_item_id,gib.concatenated_segments, gib.organization_id,gib.organization_code,NULL,NULL)
    FROM (SELECT DISTINCT moq.inventory_item_id,msik.concatenated_segments,moq.organization_id,mp.organization_code
          FROM mtl_onhand_quantities_detail moq, mtl_parameters mp, mtl_system_items_kfv msik
          WHERE moq.organization_id = mp.organization_id
          AND   msik.organization_id  = moq.organization_id
          AND   msik.inventory_item_id = moq.inventory_item_id
          AND   moq.last_update_date >= l_from_date
          AND   moq.last_update_date <= l_to_date)  gib;

  CURSOR c_get_bal_item_flst IS
    SELECT inv_ebi_get_operational_attrs(gibf.item_id,gibf.item_name, gibf.organization_id,gibf.organization_code,NULL,NULL)
    FROM (
    SELECT a.item_id,a.item_name, a.organization_id,a.organization_code
    FROM THE (SELECT cast( l_item_output_tbl as inv_ebi_get_opr_attrs_tbl)
              FROM dual ) a
    INTERSECT
    SELECT b.item_id,b.item_name, b.organization_id,b.organization_code
    FROM THE (SELECT cast( l_item_tbl as inv_ebi_get_opr_attrs_tbl)
              FROM dual ) b ) gibf;

BEGIN
  FND_MSG_PUB.initialize();
  x_return_status := FND_API.g_ret_sts_success;

  IF (p_cross_reference_type IS NOT NULL AND p_cross_reference_type <> FND_API.G_MISS_CHAR) THEN
    l_parsed_tbl := parse_source_system_string(p_cross_reference_type);
  END IF;

  IF (p_name_value_list IS NOT NULL AND  p_name_value_list.COUNT > 0) THEN
    l_item_string   := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'Item Name');
    l_org_string    := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'Organization Code');
    l_from_date_str := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'From Date');
    l_to_date_str   := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'To Date');
    l_last_x_hrs    := INV_EBI_UTIL.get_config_param_value(p_name_value_list,'Updated in the last X Hrs');

    IF l_from_date_str IS NOT NULL THEN
      l_from_date   := TO_DATE(l_from_date_str,'YYYY/MM/DD HH24:MI:SS');
    END IF;

    IF l_to_date_str IS NOT NULL THEN
      l_to_date     := TO_DATE(l_to_date_str,'YYYY/MM/DD HH24:MI:SS');
    END IF;

    IF l_last_x_hrs IS NOT NULL THEN
      l_from_date   := SYSDATE-( l_last_x_hrs/24);
      l_to_date     := SYSDATE ;
    END IF;
  END IF;

  IF (l_item_string IS NULL AND l_from_date IS NULL AND l_to_date IS NULL AND l_last_x_hrs IS NULL) THEN
    l_from_date :=get_last_run_date( p_conc_prog_id => p_prog_id
                                    ,p_appl_id      => p_appl_id
                                    );
    l_to_date := SYSDATE;
  END IF;

  IF l_from_date IS NOT NULL AND l_to_date IS NULL THEN
    l_to_date := SYSDATE;
  END IF;

  IF ( l_item_string IS NOT NULL  ) THEN
    parse_and_get_item( p_item_names            => l_item_string
                       ,p_org_codes             => l_org_string
                       ,x_item_tbl              => l_item_output_tbl
                       ,x_return_status         => l_return_status
                       ,x_msg_count             => l_msg_count
                       ,x_msg_data              => l_msg_data);
  END IF;

  IF (l_return_status  <> FND_API.g_ret_sts_success) THEN
    x_return_status := l_return_status;
    IF  l_msg_data IS NOT NULL THEN
      x_msg_data := l_msg_data;
    END IF;
  END IF;

  x_items := l_item_output_tbl;

  IF (l_from_date IS NOT NULL AND l_to_date IS NOT NULL) THEN
    IF(INV_EBI_UTIL.is_pim_installed AND l_parsed_tbl IS NOT NULL AND l_parsed_tbl.COUNT>0) THEN
    --Fetched the data based on the source system reference
      IF (c_get_bal_item_lst_pim%ISOPEN) THEN
        CLOSE c_get_bal_item_lst_pim;
      END IF;
      OPEN  c_get_bal_item_lst_pim;
      FETCH c_get_bal_item_lst_pim BULK COLLECT INTO l_item_tbl;
      CLOSE c_get_bal_item_lst_pim;
    ELSE
      IF (c_get_bal_item_lst%ISOPEN) THEN
        CLOSE c_get_bal_item_lst;
      END IF;
      OPEN  c_get_bal_item_lst;
      FETCH c_get_bal_item_lst BULK COLLECT INTO l_item_tbl;
      CLOSE c_get_bal_item_lst;
    END IF;

    IF (l_item_string IS NOT NULL) THEN
      IF (c_get_bal_item_flst%ISOPEN) THEN
        CLOSE c_get_bal_item_flst;
      END IF;
      OPEN c_get_bal_item_flst;
      FETCH c_get_bal_item_flst BULK COLLECT INTO l_item_tbl_flst;
      CLOSE c_get_bal_item_flst;
      x_items := l_item_tbl_flst;
    ELSIF (l_org_string IS NOT NULL) THEN
      filter_items_based_on_org( p_org_codes            => l_org_string
                                ,p_item_tbl             => l_item_tbl
                                ,x_item_tbl             => l_item_org_output_tbl
                                ,x_return_status        => l_return_status
                                ,x_msg_count            => l_msg_count
                                ,x_msg_data             => l_msg_data);
      IF (l_return_status  = FND_API.g_ret_sts_success) THEN
        x_items := l_item_org_output_tbl;
      ELSE
        x_return_status := l_return_status;
        IF  x_msg_data IS NOT NULL THEN
          x_msg_data := x_msg_data || l_msg_data;
        ELSE
          x_msg_data := l_msg_data;
        END IF;
      END IF;
    ELSE
      x_items := l_item_tbl;
    END IF;
  END IF;
  -- for Operating unit Pouplation
  IF  x_items is NOT NULL AND x_items.COUNT > 0 then
    FOR i IN 1..x_items.COUNT
    LOOP
      get_Operating_unit
        (p_oranization_id => x_items(i).organization_id
        ,x_operating_unit => x_items(i).operating_unit
        ,x_ouid      => x_items(i).operating_unit_id
        );
    END LOOP;
  END IF;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at INV_EBI_ITEM_HELPER.get_item_balance_list';
    IF (c_get_bal_item_flst%ISOPEN) THEN
      CLOSE c_get_bal_item_flst;
    END IF;
    IF (c_get_bal_item_lst%ISOPEN) THEN
      CLOSE c_get_bal_item_lst;
    END IF;
    IF (c_get_bal_item_lst_pim%ISOPEN) THEN
      CLOSE c_get_bal_item_lst_pim;
    END IF;
END get_item_balance_list;
/************************************************************************************
--      API name        : get_Operating_unit
--      Type            : Public
--      Function        :
************************************************************************************/
PROCEDURE get_Operating_unit
   (p_oranization_id IN NUMBER
   ,x_operating_unit  OUT NOCOPY VARCHAR2
   ,x_ouid             OUT NOCOPY NUMBER
   )
IS
CURSOR c_operating_unit(cp_organization_id NUMBER)
  IS
  SELECT operating_unit,name
  FROM ORG_ORGANIZATION_DEFINITIONS orgdef,
     HR_OPERATING_UNITS hrou
  WHERE orgdef.organization_id = cp_organization_id
  AND   hrou.organization_id=orgdef.operating_unit;
BEGIN
  IF (c_operating_unit%ISOPEN) THEN
    CLOSE c_operating_unit;
  END IF;
  OPEN c_operating_unit(p_oranization_id);
  FETCH c_operating_unit into x_ouid,x_operating_unit;
  CLOSE c_operating_unit;
 EXCEPTION WHEN OTHERS
 THEN
  IF (c_operating_unit%ISOPEN) THEN
    CLOSE c_operating_unit;
  END IF;
END get_Operating_unit;

/************************************************************************************
--      API name        : set_server_time_zone
--      Type            : Public
--      Function        :
************************************************************************************/
PROCEDURE set_server_time_zone
IS
  l_server_tz  VARCHAR2(50);
  l_tzoffset   VARCHAR2(10);
BEGIN

  INV_EBI_ITEM_HELPER.G_TIME_ZONE_OFFSET := NULL;

  SELECT timezone_code
  INTO   l_server_tz
  FROM   fnd_timezones_b
  WHERE  upgrade_tz_id = fnd_profile.value('SERVER_TIMEZONE_ID')
  AND    UPPER(enabled_flag)='Y';

  SELECT TZ_OFFSET(l_server_tz)
  INTO   l_tzoffset
  FROM   DUAL;

  INV_EBI_ITEM_HELPER.G_TIME_ZONE_OFFSET := l_tzoffset;

EXCEPTION
  WHEN OTHERS THEN
    NULL;
END set_server_time_zone;
/************************************************************************************
--      API name        : convert_date_str
--      Type            : Public
--      Function        :
************************************************************************************/
FUNCTION convert_date_str(p_datetime IN DATE)
RETURN VARCHAR2
IS
  l_ret_tz     VARCHAR2(50);
BEGIN
  IF(p_datetime IS NOT NULL AND p_datetime<>FND_API.G_MISS_DATE) THEN
    l_ret_tz := SUBSTR(TO_CHAR(p_datetime,'YYYY-MM-DD"T"HH24:MI:SS')||INV_EBI_ITEM_HELPER.G_TIME_ZONE_OFFSET,1,25);
  END IF;
  RETURN l_ret_tz;
EXCEPTION
  WHEN OTHERS THEN
    NULL;
END convert_date_str;
END INV_EBI_ITEM_HELPER;

/
