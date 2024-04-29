--------------------------------------------------------
--  DDL for Package Body INV_EBI_CHANGE_ORDER_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EBI_CHANGE_ORDER_PUB" AS
/* $Header: INVEIPCOB.pls 120.34.12010000.22 2009/09/14 07:13:29 smukka ship $ */
 /************************************************************************************
 --     API name        : populate_item_attributes
 --     Type            : Private
 --     Function        :
 --     This API is used to
 --
 ************************************************************************************/
 PROCEDURE populate_item_attributes(
    p_change_order_obj    IN          inv_ebi_change_order_obj
   ,p_revised_item        IN          inv_ebi_revised_item_obj
   ,x_item                OUT NOCOPY  inv_ebi_item_obj
   ,x_out                 OUT NOCOPY  inv_ebi_item_output_obj
 ) IS
   l_pk_col_name_val_pairs       INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
   l_main_item_obj               inv_ebi_item_main_obj;
   l_output_status               inv_ebi_output_status;
 BEGIN
   l_output_status    := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out              := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);
   IF(p_revised_item.item IS NOT NULL ) THEN
     x_item := p_revised_item.item;
   ELSE
     l_main_item_obj := inv_ebi_item_main_obj(fnd_api.g_miss_num,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_num,
                                              fnd_api.g_miss_char,fnd_api.g_miss_num,
                                              fnd_api.g_miss_num,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_num,
                                              fnd_api.g_miss_num,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_num,
                                              fnd_api.g_miss_num,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_date,
                                              fnd_api.g_miss_date,fnd_api.g_miss_date,
                                              fnd_api.g_miss_num,fnd_api.g_miss_date,
                                              fnd_api.g_miss_num,fnd_api.g_miss_num,
                                              fnd_api.g_miss_num,fnd_api.g_miss_num,
                                              fnd_api.g_miss_num,fnd_api.g_miss_date,
                                              fnd_api.g_miss_num,fnd_api.g_miss_char,
                                              fnd_api.g_miss_num,fnd_api.g_miss_char,
                                              fnd_api.g_miss_num,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_date,fnd_api.g_miss_num,
                                              fnd_api.g_miss_char,fnd_api.g_miss_num,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_num,fnd_api.g_miss_char,
                                              fnd_api.g_miss_num,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char,fnd_api.g_miss_char,
                                              fnd_api.g_miss_char);
     x_item:=inv_ebi_Item_Obj(l_main_item_obj,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,
                              NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
   END IF;
   IF(x_item.main_obj_type.item_number IS NULL OR x_item.main_obj_type.item_number = fnd_api.g_miss_char )THEN
    x_item.main_obj_type.item_number :=  p_revised_item.revised_item_name;
   END IF;
   IF(x_item.main_obj_type.organization_id IS NULL OR x_item.main_obj_type.organization_id = fnd_api.g_miss_num )THEN
     IF((p_change_order_obj.organization_id IS NULL
     OR p_change_order_obj.organization_id = fnd_api.g_miss_num)
     AND (p_change_order_obj.organization_code IS NOT NULL
     OR  p_change_order_obj.organization_code <> fnd_api.g_miss_char)) THEN
        l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
        l_pk_col_name_val_pairs.EXTEND(1);
        l_pk_col_name_val_pairs(1).name       := 'organization_code';
        l_pk_col_name_val_pairs(1).value      := p_change_order_obj.organization_code;
        x_item.main_obj_type.organization_id  := INV_EBI_ITEM_HELPER.value_to_id(
                                p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                               ,p_entity_name            => INV_EBI_ITEM_HELPER.G_ORGANIZATION
                              );
        l_pk_col_name_val_pairs.TRIM(1);
        IF (x_item.main_obj_type.organization_id IS NULL) THEN
         FND_MESSAGE.set_name('INV','INV_EBI_ORG_CODE_INVALID');
         FND_MESSAGE.set_token('COL_VALUE', p_change_order_obj.organization_code);
         FND_MSG_PUB.add;
         RAISE FND_API.G_EXC_ERROR;
        END IF;
     ELSE
       x_item.main_obj_type.organization_id :=  p_change_order_obj.organization_id;
     END IF;
   END IF;

   IF(x_item.main_obj_type.init_msg_list IS NULL OR x_item.main_obj_type.init_msg_list = fnd_api.g_miss_char )THEN
     x_item.main_obj_type.init_msg_list :=  FND_API.G_TRUE;
   END IF;
 EXCEPTION
 WHEN FND_API.g_exc_error THEN
    x_out.output_status.return_status :=  FND_API.g_ret_sts_error;
    IF(x_out.output_status.msg_data IS NULL) THEN
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false
       ,p_count   => x_out.output_status.msg_count
       ,p_data    => x_out.output_status.msg_data
     );
    END IF;
   WHEN OTHERS THEN
     x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
     IF (x_out.output_status.msg_data IS NOT NULL) THEN
       x_out.output_status.msg_data  :=  x_out.output_status.msg_data ||' -> INV_EBI_CHANGE_ORDER_PUB.populate_item_attributes ';
     ELSE
       x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_CHANGE_ORDER_PUB.populate_item_attributes ';
    END IF;
END populate_item_attributes;

/************************************************************************************
 --     API name        : transfer_engg_item_mfg
 --     Type            : Private
 --     Function        :
 --     This API is used to
 --
 ************************************************************************************/
 PROCEDURE transfer_engg_item_mfg(
    p_item                   IN     inv_ebi_item_obj
   ,p_alt_bom_designator     IN     VARCHAR2
   ,x_out   OUT NOCOPY  inv_ebi_eco_output_obj
 ) IS
 l_item_approval_status        VARCHAR2(30);
 l_item_number                 VARCHAR2(2000);
 l_is_engineering_item         VARCHAR2(3);
 l_output_status               inv_ebi_output_status;
 l_designator_option           NUMBER;
 l_alt_bom_designator          VARCHAR2(10);
 l_inventory_item_id           NUMBER;
 l_pk_col_name_val_pairs       INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;

 BEGIN
   SAVEPOINT inv_ebi_engg_item_save_pnt;
   l_output_status    := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out              := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

   IF(p_item.main_obj_type.inventory_item_id IS NULL OR
      p_item.main_obj_type.inventory_item_id = fnd_api.g_miss_num) THEN

      l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
      l_pk_col_name_val_pairs.EXTEND(2);
      l_pk_col_name_val_pairs(1).name  := 'concatenated_segments';
      l_pk_col_name_val_pairs(1).value := p_item.main_obj_type.item_number;
      l_pk_col_name_val_pairs(2).name  := 'organization_id';
      l_pk_col_name_val_pairs(2).value := p_item.main_obj_type.organization_id;

      l_inventory_item_id  := INV_EBI_ITEM_HELPER.value_to_id(
               p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
              ,p_entity_name            => INV_EBI_ITEM_HELPER.G_INVENTORY_ITEM
             );
      l_pk_col_name_val_pairs.TRIM(2);
        IF (l_inventory_item_id IS NULL ) THEN
          FND_MESSAGE.set_name('INV','INV_EBI_ITEM_INVALID');
          FND_MESSAGE.set_token('COL_VALUE', p_item.main_obj_type.item_number);
          FND_MSG_PUB.add;
          RAISE FND_API.g_exc_unexpected_error;
        END IF;
   ELSE
      l_inventory_item_id  := p_item.main_obj_type.inventory_item_id;

   END IF;

   IF((l_inventory_item_id IS NOT NULL
   AND l_inventory_item_id <> fnd_api.g_miss_num)
   AND (p_item.main_obj_type.organization_id IS NOT NULL
   AND p_item.main_obj_type.organization_id <> fnd_api.g_miss_num)) THEN

     SELECT approval_status INTO l_item_approval_status
     FROM mtl_system_items_b
     WHERE inventory_item_id  = l_inventory_item_id
     AND organization_id      = p_item.main_obj_type.organization_id;

   END IF;

   /* Start of Bug 8299853 FDD says if CO item is not new and approval status of the item is not approved
      we should error out */

   IF(NVL(l_item_approval_status, 'A') <> 'A') THEN

     FND_MESSAGE.set_name('INV','INV_EBI_ITEM_NOT_APPROVED');
     FND_MESSAGE.set_token('ITEM', p_item.main_obj_type.item_number);
     FND_MSG_PUB.add;
     RAISE  FND_API.g_exc_error;

   ELSE  --End of Bug 8299853

     l_is_engineering_item :=  INV_EBI_ITEM_HELPER.is_engineering_item(
       p_organization_id  =>   p_item.main_obj_type.organization_id
      ,p_item_number      =>   p_item.main_obj_type.item_number
     );

     IF(l_is_engineering_item = FND_API.g_true
        AND p_item.bom_obj_type.eng_item_flag = 'N'
       ) THEN

       --Transfer Engg Item to Manufacturing
       -- If alt_bom_code is null then transfer all boms,if not transfer only that particular bom

       IF(p_alt_bom_designator IS NULL OR p_alt_bom_designator = fnd_api.g_miss_char ) THEN
         l_designator_option  := 1;
         l_alt_bom_designator := NULL;
       ELSE
         l_designator_option  := 3;
         l_alt_bom_designator := p_alt_bom_designator;
       END IF;

       ENG_BOM_RTG_TRANSFER_PKG.eng_bom_rtg_transfer(
         x_org_id             =>   p_item.main_obj_type.organization_id,
         x_eng_item_id        =>   l_inventory_item_id,
         x_mfg_item_id        =>   l_inventory_item_id,
         x_transfer_option    =>   1,
         x_designator_option  =>   l_designator_option,
         x_alt_bom_designator =>   l_alt_bom_designator,
         x_alt_rtg_designator =>   NULL,
         x_effectivity_date   =>   NULL,
         x_last_login_id      =>   p_item.main_obj_type.last_updated_by,
         x_bom_rev_starting   =>   NULL,
         x_rtg_rev_starting   =>   NULL,
         x_ecn_name           =>   NULL,
         x_item_code          =>   1, --to transfer item to Mfg
         x_bom_code           =>   1, --to transfer Bom to Mfg
         x_rtg_code           =>   2,
         x_mfg_description    =>   p_item.main_obj_type.description,
         x_segment1           =>   p_item.main_obj_type.segment1,
         x_segment2           =>   p_item.main_obj_type.segment2,
         x_segment3           =>   p_item.main_obj_type.segment3,
         x_segment4           =>   p_item.main_obj_type.segment4,
         x_segment5           =>   p_item.main_obj_type.segment5,
         x_segment6           =>   p_item.main_obj_type.segment6,
         x_segment7           =>   p_item.main_obj_type.segment7,
         x_segment8           =>   p_item.main_obj_type.segment8,
         x_segment9           =>   p_item.main_obj_type.segment9,
         x_segment10          =>   p_item.main_obj_type.segment10,
         x_segment11          =>   p_item.main_obj_type.segment11,
         x_segment12          =>   p_item.main_obj_type.segment12,
         x_segment13          =>   p_item.main_obj_type.segment13,
         x_segment14          =>   p_item.main_obj_type.segment14,
         x_segment15          =>   p_item.main_obj_type.segment15,
         x_segment16          =>   p_item.main_obj_type.segment16,
         x_segment17          =>   p_item.main_obj_type.segment17,
         x_segment18          =>   p_item.main_obj_type.segment18,
         x_segment19          =>   p_item.main_obj_type.segment19,
         x_segment20          =>   p_item.main_obj_type.segment20,
         x_implemented_only   =>   NULL,
         x_commit             =>   FALSE
        );
      END IF;

    END IF;

  EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO inv_ebi_engg_item_save_pnt;
    x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
    IF(x_out.output_status.msg_data IS NULL) THEN
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false
       ,p_count   => x_out.output_status.msg_count
       ,p_data    => x_out.output_status.msg_data
     );
    END IF;
  WHEN FND_API.g_exc_error THEN
      ROLLBACK TO inv_ebi_engg_item_save_pnt;
      x_out.output_status.return_status :=  FND_API.g_ret_sts_error;
      IF(x_out.output_status.msg_data IS NULL) THEN
        FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_out.output_status.msg_count
         ,p_data    => x_out.output_status.msg_data
       );
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO inv_ebi_engg_item_save_pnt;
    x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
    IF (x_out.output_status.msg_data IS NOT NULL) THEN
      x_out.output_status.msg_data  :=  x_out.output_status.msg_data ||' -> INV_EBI_CHANGE_ORDER_PUB.transfer_engg_item_manufacturing ';
    ELSE
      x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_CHANGE_ORDER_PUB.transfer_engg_item_manufacturing ';
    END IF;
  END transfer_engg_item_mfg;

/************************************************************************************
 --     API name        : validate_component_items
 --     Type            : Private
 --     Function        :
 --     This API is used to
 --     Changed API Signature and Name Bug 8397083
 ************************************************************************************/

PROCEDURE validate_component_items(
   p_organization_code        IN  VARCHAR2
  ,p_component_item_tbl       IN  inv_ebi_rev_comp_tbl
  ,x_out                      OUT NOCOPY   inv_ebi_eco_output_obj
) IS
 l_is_master_org             VARCHAR2(3);
 l_organization_id           NUMBER;
 l_component_item_name       VARCHAR2(240);
 l_is_component_item_exists  VARCHAR2(3);
 l_pk_col_name_val_pairs     INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
 l_output_status             inv_ebi_output_status;
BEGIN
  l_output_status    := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
  x_out              := inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);
  l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
  l_pk_col_name_val_pairs.EXTEND(1);
  l_pk_col_name_val_pairs(1).name  := 'organization_code';
  l_pk_col_name_val_pairs(1).value := p_organization_code;
  l_organization_id  := INV_EBI_ITEM_HELPER.value_to_id(
                          p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                         ,p_entity_name            => INV_EBI_ITEM_HELPER.G_ORGANIZATION
                        );
  IF (l_organization_id IS NULL) THEN
    FND_MESSAGE.set_name('INV','INV_EBI_ORG_CODE_INVALID');
    FND_MESSAGE.set_token('COL_VALUE',p_organization_code);
    FND_MSG_PUB.add;
    RAISE FND_API.g_exc_error;
  END IF;
  l_is_master_org := INV_EBI_UTIL.is_master_org(l_organization_id);
  IF(p_component_item_tbl IS NOT NULL AND p_component_item_tbl.COUNT > 0) THEN
    FOR i IN 1.. p_component_item_tbl.COUNT LOOP
      IF(p_component_item_tbl(i).transaction_type  = INV_EBI_ITEM_PUB.g_otype_create ) THEN
        l_component_item_name := p_component_item_tbl(i).component_item_name;
        l_is_component_item_exists := INV_EBI_ITEM_HELPER.is_item_exists(
                                       p_organization_id  => l_organization_id
                                      ,p_item_number      => l_component_item_name
                                      );
        IF(l_is_master_org = fnd_api.g_true AND l_is_component_item_exists = fnd_api.g_false) THEN
          FND_MESSAGE.set_name('INV','INV_EBI_ITEM_NO_MASTER_ORG');
          FND_MESSAGE.set_token('COMP_ITEM', l_component_item_name);
          FND_MSG_PUB.add;
          RAISE  FND_API.g_exc_error;
        END IF;
      END IF;
    END LOOP;
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_error THEN
    x_out.output_status.return_status :=  FND_API.g_ret_sts_error;
    IF(x_out.output_status.msg_data IS NULL) THEN
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false
       ,p_count   => x_out.output_status.msg_count
       ,p_data    => x_out.output_status.msg_data
     );
    END IF;
  WHEN OTHERS THEN
    x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
    IF (x_out.output_status.msg_data IS NOT NULL) THEN
      x_out.output_status.msg_data  :=  x_out.output_status.msg_data ||' -> INV_EBI_CHANGE_ORDER_PUB.validate_component_items ';
    ELSE
      x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_CHANGE_ORDER_PUB.validate_component_items ';
    END IF;
END validate_component_items;

/************************************************************************************
 --     API name        : validate_item
 --     Type            : Private
 --     Function        :
 --     This API is used to
 --
 ************************************************************************************/
 PROCEDURE validate_item(
   p_item           IN           inv_ebi_item_obj
  ,x_out            OUT NOCOPY   inv_ebi_item_output_obj
)  IS

  l_output_status               inv_ebi_output_status;
  l_transaction_type            VARCHAR2(20);
  l_item_catalog_group_code     VARCHAR2(40);
  l_pk_col_name_val_pairs       INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
  l_item_output   inv_ebi_item_output_obj;

BEGIN
  l_output_status    := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
  x_out              := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);
  l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
  FND_MSG_PUB.initialize;

   IF(INV_EBI_ITEM_HELPER.is_item_exists (
          p_organization_id    =>   p_item.main_obj_type.organization_id
         ,p_item_number        =>   p_item.main_obj_type.item_number
        ) = FND_API.g_false ) THEN

   /* Start of Bug 8299853 FDD says if CO item is new ICC is configured for NIR then
      we should error out */

     IF(p_item.main_obj_type.organization_id IS NOT NULL  AND p_item.main_obj_type.organization_id <> FND_API.g_miss_num) THEN

       IF(INV_EBI_UTIL.is_master_org(
                                p_organization_id => p_item.main_obj_type.organization_id
                              ) = FND_API.g_true) THEN

         IF(  p_item.main_obj_type.item_catalog_group_id IS NOT NULL
             AND  p_item.main_obj_type.item_catalog_group_id <> fnd_api.g_miss_num) THEN

           IF(INV_EBI_ITEM_HELPER.is_new_item_request_reqd(
                 p_item_catalog_group_id =>  p_item.main_obj_type.item_catalog_group_id
                 ) = FND_API.g_true AND
                 p_item.bom_obj_type.eng_item_flag = 'N') THEN

             FND_MESSAGE.set_name('INV','INV_EBI_ICC_CONFG_FOR_NIR');

             IF ( p_item.main_obj_type.item_catalog_group_code IS  NULL
                  OR p_item.main_obj_type.item_catalog_group_code = fnd_api.g_miss_char)THEN

               l_pk_col_name_val_pairs.EXTEND(1);
               l_pk_col_name_val_pairs(1).name  := 'item_catalog_group_id';
               l_pk_col_name_val_pairs(1).value := p_item.main_obj_type.item_catalog_group_id;
               l_item_catalog_group_code := INV_EBI_ITEM_HELPER.id_to_value(
                                                p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                                               ,p_entity_name            => INV_EBI_ITEM_HELPER.G_ITEM_CATALOG_GROUP
                                              );
               l_pk_col_name_val_pairs.TRIM(1);

             ELSE

               l_item_catalog_group_code := p_item.main_obj_type.item_catalog_group_code;

             END IF;

             FND_MESSAGE.set_token('ITEM',p_item.main_obj_type.item_number);
             FND_MESSAGE.set_token('ITEM_CATALOG', l_item_catalog_group_code);
             FND_MSG_PUB.add;
             RAISE  FND_API.g_exc_error;

           END IF;
         END IF;
       END IF;
     END IF;  --End of Bug 8299853

     INV_EBI_ITEM_PUB.validate_item (
       p_transaction_type   =>  l_transaction_type
      ,p_item               =>  p_item
      ,x_out                =>  l_item_output
     ) ;
     IF(l_item_output.output_status.return_status <> FND_API.g_ret_sts_success) THEN
       RAISE FND_API.g_exc_unexpected_error;
     END IF;
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
    IF(x_out.output_status.msg_data IS NULL) THEN
      FND_MSG_PUB.count_and_get(
        p_encoded => FND_API.g_false
       ,p_count   => x_out.output_status.msg_count
       ,p_data    => x_out.output_status.msg_data
     );
    END IF;
    WHEN FND_API.g_exc_error THEN
        x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
        IF(x_out.output_status.msg_data IS NULL) THEN
          FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false
           ,p_count   => x_out.output_status.msg_count
           ,p_data    => x_out.output_status.msg_data
         );
    END IF;
  WHEN OTHERS THEN
    x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
    IF (x_out.output_status.msg_data IS NOT NULL) THEN
      x_out.output_status.msg_data  :=  x_out.output_status.msg_data ||' -> INV_EBI_CHANGE_ORDER_PUB.validate_eco ';
    ELSE
      x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_CHANGE_ORDER_PUB.validate_eco ';
    END IF;
END validate_item;
/************************************************************************************
  --     API name        : populate_revised_items_out
  --     Type            : Private
  --     Function        :
  --     This API is used to populate Revised item details after eco creation.
 ************************************************************************************/
PROCEDURE populate_revised_items_out
  (p_change_order             IN  inv_ebi_change_order_obj
  ,p_revised_item_type_tbl   IN  inv_ebi_revised_item_tbl
  ,x_revised_item_type_tbl   OUT NOCOPY inv_ebi_revitem_output_obj_tbl
  )IS
  l_organization_id     NUMBER;
  l_pk_col_name_val_pairs INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl;
  l_revised_item_type_tbl inv_ebi_revitem_output_obj_tbl;
  l_ouid  NUMBER;
  l_operating_unit VARCHAR2(240);
BEGIN
  l_pk_col_name_val_pairs := INV_EBI_ITEM_HELPER.inv_ebi_name_value_pair_tbl();
  l_revised_item_type_tbl := inv_ebi_revitem_output_obj_tbl();
  l_pk_col_name_val_pairs.EXTEND(1);
  l_pk_col_name_val_pairs(1).name  := 'organization_code';
  l_pk_col_name_val_pairs(1).value := p_change_order.organization_code;

  l_organization_id  := INV_EBI_ITEM_HELPER.value_to_id(
                         p_pk_col_name_val_pairs  => l_pk_col_name_val_pairs
                        ,p_entity_name            => INV_EBI_ITEM_HELPER.G_ORGANIZATION
                         );
  l_pk_col_name_val_pairs.TRIM(1);

 INV_EBI_ITEM_HELPER.get_Operating_unit
   (p_oranization_id => l_organization_id
   ,x_operating_unit => l_operating_unit
   ,x_ouid           => l_ouid
   );
  IF(p_revised_item_type_tbl IS NOT NULL AND p_revised_item_type_tbl.COUNT > 0) THEN
    FOR i IN 1..p_revised_item_type_tbl.COUNT
    LOOP
      l_revised_item_type_tbl.extend();
      l_revised_item_type_tbl(i) := INV_EBI_REVITEM_OUTPUT_OBJ(NULL,NULL);
      l_revised_item_type_tbl(i).revised_item := INV_EBI_ITEM_OUTPUT_OBJ(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
      l_revised_item_type_tbl(i).revised_item.ORGANIZATION_CODE := p_change_order.organization_code ;
      l_revised_item_type_tbl(i).revised_item.ORGANIZATION_ID   := l_organization_id;
      l_revised_item_type_tbl(i).revised_item.ITEM_NUMBER             := p_revised_item_type_tbl(i).revised_item_name;
      l_revised_item_type_tbl(i).revised_item.INVENTORY_ITEM_ID :=  INV_EBI_ITEM_HELPER.get_inventory_item_id
                                                                            ( p_organization_id => l_organization_id
                                                                             ,p_item_number     => p_revised_item_type_tbl(i).revised_item_name);
      l_revised_item_type_tbl(i).revised_item.operating_unit := l_operating_unit;
      l_revised_item_type_tbl(i).revised_item.operating_unit_id := l_ouid;
      l_revised_item_type_tbl(i).rev_component :=INV_EBI_COMP_OUTPUT_OBJ_TBL();
      IF(p_revised_item_type_tbl(i).component_item_tbl IS NOT NULL AND p_revised_item_type_tbl(i).component_item_tbl.COUNT > 0) THEN
        FOR j IN 1..p_revised_item_type_tbl(i).component_item_tbl.COUNT
        LOOP
          l_revised_item_type_tbl(i).rev_component.extend();
          l_revised_item_type_tbl(i).rev_component(j) := INV_EBI_COMP_OUTPUT_OBJ(NULL,NULL);
          l_revised_item_type_tbl(i).rev_component(j).component := INV_EBI_ITEM_OUTPUT_OBJ(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
          l_revised_item_type_tbl(i).rev_component(j).component.ORGANIZATION_CODE := p_change_order.organization_code ;
          l_revised_item_type_tbl(i).rev_component(j).component.ORGANIZATION_ID   := l_organization_id;
          l_revised_item_type_tbl(i).rev_component(j).component.ITEM_NUMBER         := p_revised_item_type_tbl(i).component_item_tbl(j).component_item_name;
          l_revised_item_type_tbl(i).rev_component(j).component.INVENTORY_ITEM_ID := INV_EBI_ITEM_HELPER.get_inventory_item_id
                                                                                        ( p_organization_id => l_organization_id
                                                                                         ,p_item_number     => p_revised_item_type_tbl(i).component_item_tbl(j).component_item_name);
      l_revised_item_type_tbl(i).rev_component(j).component.operating_unit := l_operating_unit;
      l_revised_item_type_tbl(i).rev_component(j).component.operating_unit_id := l_ouid;
          l_revised_item_type_tbl(i).rev_component(j).subcomponent := INV_EBI_ITEM_OUTPUT_TBL();

          IF(p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl IS NOT NULL AND p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl.COUNT > 0) THEN
            FOR k IN 1..p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl.COUNT
            LOOP
              l_revised_item_type_tbl(i).rev_component(j).subcomponent.extend();
              l_revised_item_type_tbl(i).rev_component(j).subcomponent(k) :=INV_EBI_ITEM_OUTPUT_OBJ(NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL);
              l_revised_item_type_tbl(i).rev_component(j).subcomponent(k).ORGANIZATION_CODE := p_change_order.organization_code ;
              l_revised_item_type_tbl(i).rev_component(j).subcomponent(k).ORGANIZATION_ID   := l_organization_id;
              l_revised_item_type_tbl(i).rev_component(j).subcomponent(k).ITEM_NUMBER         := p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).substitute_component_name;
              l_revised_item_type_tbl(i).rev_component(j).subcomponent(k).INVENTORY_ITEM_ID :=INV_EBI_ITEM_HELPER.get_inventory_item_id
                                                                                                ( p_organization_id => l_organization_id
                                                                                                 ,p_item_number     => p_revised_item_type_tbl(i).component_item_tbl(j).substitute_component_tbl(k).substitute_component_name);
              l_revised_item_type_tbl(i).rev_component(j).subcomponent(k).operating_unit := l_operating_unit;
              l_revised_item_type_tbl(i).rev_component(j).subcomponent(k).operating_unit_id := l_ouid;
            END LOOP;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END IF;
  x_revised_item_type_tbl := l_revised_item_type_tbl;
END populate_revised_items_out;

/************************************************************************************
 --     API name        : get_eco
 --     Type            : Public
 --     Function        :
 --     This API is used to retrieve all the change order attributes
************************************************************************************/
PROCEDURE get_eco (
    p_change_id                 IN              NUMBER
   ,p_last_update_status        IN              VARCHAR2
   ,p_revised_item_sequence_id  IN              NUMBER
   ,p_name_val_list             IN              inv_ebi_name_value_list
   ,x_eco_obj                   OUT NOCOPY      inv_ebi_eco_obj
   ,x_return_status             OUT NOCOPY      VARCHAR2
   ,x_msg_count                 OUT NOCOPY      NUMBER
   ,x_msg_data                  OUT NOCOPY      VARCHAR2
  )
IS
  l_eco_obj                     inv_ebi_eco_obj;
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(1000);
  l_eco_change_order_obj        inv_ebi_change_order_obj;
  l_revised_item_tbl            inv_ebi_revised_item_tbl;
  l_revised_item_obj            inv_ebi_revised_item_obj;
  l_only_status_info            VARCHAR2(1):= fnd_api.g_false;
BEGIN
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_eco_change_order_obj := inv_ebi_change_order_obj(
                              NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                             ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                             ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                             ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                             ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                             ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                             ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                            );
  l_revised_item_tbl := inv_ebi_revised_item_tbl();
  l_revised_item_obj := inv_ebi_revised_item_obj(
                          NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                         ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                         ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                         ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                         ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                         ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                         ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                         ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                         ,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL,NULL
                         ,NULL,NULL,NULL,NULL
                        );

  INV_EBI_CHANGE_ORDER_HELPER.get_eco (
    p_change_id                 => p_change_id
   ,p_last_update_status        => p_last_update_status
   ,p_revised_item_sequence_id  => p_revised_item_sequence_id
   ,p_name_val_list             => p_name_val_list
   ,x_eco_obj                   => l_eco_obj
   ,x_return_status             => l_return_status
   ,x_msg_count                 => l_msg_count
   ,x_msg_data                  => l_msg_data
  );
  IF(l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.g_exc_unexpected_error;
  END IF;
  IF p_name_val_list.name_value_table IS NOT NULL THEN
    FOR i in p_name_val_list.name_value_table.FIRST..p_name_val_list.name_value_table.LAST LOOP
      IF UPPER(p_name_val_list.name_value_table(i).param_name) = G_ONLY_STATUS_INFO THEN
        l_only_status_info := p_name_val_list.name_value_table(i).param_value;
      END IF;
    END LOOP;
  END IF;
  IF l_only_status_info = fnd_api.g_true THEN
    l_eco_change_order_obj.status_name := l_eco_obj.eco_change_order_type.status_name;
    l_eco_change_order_obj.implementation_date := l_eco_obj.eco_change_order_type.implementation_date;
    l_eco_change_order_obj.cancellation_date := l_eco_obj.eco_change_order_type.cancellation_date;
    FOR i in l_eco_obj.eco_revised_item_type.FIRST..l_eco_obj.eco_revised_item_type.LAST LOOP
      l_revised_item_tbl.extend();
      l_revised_item_obj.status_name := l_eco_obj.eco_revised_item_type(i).status_name;
      l_revised_item_obj.new_effective_date := l_eco_obj.eco_revised_item_type(i).new_effective_date;
      l_revised_item_tbl(i) := l_revised_item_obj;
    END LOOP;
    x_eco_obj := inv_ebi_eco_obj(l_eco_change_order_obj,NULL,l_revised_item_tbl,NULL);
  ELSE
    x_eco_obj := l_eco_obj;
  END IF;
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
      x_return_status :=  FND_API.g_ret_sts_error;
      IF(x_msg_data IS NULL) THEN
        FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count => x_msg_count
         ,p_data => x_msg_data
        );
      END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_error;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data ||' -> at inv_ebi_change_order_pub.get_eco';
    ELSE
      x_msg_data  :=  SQLERRM||' at inv_ebi_change_order_pub.get_eco ';
    END IF;
END get_eco;

/************************************************************************************
 --     API name        : Convert_date_str_eco
 --     Type            : Public
 --     Function        :
 --
************************************************************************************/

PROCEDURE Convert_date_str_eco(p_eco_lst_obj IN         inv_ebi_eco_out_obj_tbl
                              ,x_eco_lst_obj OUT NOCOPY inv_ebi_eco_out_obj_tbl)
IS
BEGIN

  x_eco_lst_obj := inv_ebi_eco_out_obj_tbl();

  IF(p_eco_lst_obj IS NOT NULL  AND p_eco_lst_obj.COUNT>0) THEN
    x_eco_lst_obj.EXTEND(p_eco_lst_obj.COUNT);
    x_eco_lst_obj := p_eco_lst_obj;
  END IF;

  IF p_eco_lst_obj IS NOT NULL AND p_eco_lst_obj.COUNT>0 THEN
    FOR i IN p_eco_lst_obj.FIRST..p_eco_lst_obj.LAST LOOP
    ------------------------------------------------------------------------------
    -- To Convert Date Fields in eco_change_order_type (INV_EBI_CHANGE_ORDER_OBJ)
    ------------------------------------------------------------------------------
      x_eco_lst_obj(i).eco_attr.eco_change_order_type.approval_date_str :=
      INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_change_order_type.approval_date);

      x_eco_lst_obj(i).eco_attr.eco_change_order_type.approval_request_date_str :=
      INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_change_order_type.approval_request_date);

      x_eco_lst_obj(i).eco_attr.eco_change_order_type.need_by_date_str :=
      INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_change_order_type.need_by_date);

      x_eco_lst_obj(i).eco_attr.eco_change_order_type.implementation_date_str :=
      INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_change_order_type.implementation_date);

      x_eco_lst_obj(i).eco_attr.eco_change_order_type.cancellation_date_str :=
      INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_change_order_type.cancellation_date);
      ------------------------------------------------------------------------------
      -- To Convert Date Fields in eco_change_order_type (INV_EBI_UDA_ATTR_OBJ)
      ------------------------------------------------------------------------------

      IF(p_eco_lst_obj(i).eco_attr.eco_change_order_type.change_order_uda.attribute_group_tbl IS NOT NULL AND
        p_eco_lst_obj(i).eco_attr.eco_change_order_type.change_order_uda.attribute_group_tbl.COUNT>0) THEN
        FOR j IN p_eco_lst_obj(i).eco_attr.eco_change_order_type.change_order_uda.attribute_group_tbl.FIRST..
          p_eco_lst_obj(i).eco_attr.eco_change_order_type.change_order_uda.attribute_group_tbl.LAST LOOP
          IF(p_eco_lst_obj(i).eco_attr.eco_change_order_type.change_order_uda.attribute_group_tbl(j).attributes_tbl IS NOT NULL
            AND p_eco_lst_obj(i).eco_attr.eco_change_order_type.change_order_uda.attribute_group_tbl(j).attributes_tbl.COUNT>0) THEN
            FOR k IN p_eco_lst_obj(i).eco_attr.eco_change_order_type.change_order_uda.attribute_group_tbl(j).attributes_tbl.FIRST..
              p_eco_lst_obj(i).eco_attr.eco_change_order_type.change_order_uda.attribute_group_tbl(j).attributes_tbl.LAST LOOP
              x_eco_lst_obj(i).eco_attr.eco_change_order_type.change_order_uda.attribute_group_tbl(j).attributes_tbl(k).attr_value_date_str :=
              INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_change_order_type.change_order_uda.attribute_group_tbl(j).attributes_tbl(k).attr_value_date);
            END LOOP;
          END IF;
        END LOOP;
      END IF;

      ----------------------------------------------------------------------------
      -- To Convert Date Fields in eco_revised_item_type(INV_EBI_REVISED_ITEM_TBL)
      ----------------------------------------------------------------------------
        IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type IS NOT NULL AND p_eco_lst_obj(i).eco_attr.eco_revised_item_type.COUNT>0) THEN
          FOR j IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type.FIRST..p_eco_lst_obj(i).eco_attr.eco_revised_item_type.LAST LOOP
            x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).start_effective_date_str :=
            INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).start_effective_date);

            x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).new_effective_date_str :=
            INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).new_effective_date);

            x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).earliest_effective_date_str :=
            INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).earliest_effective_date);

             x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).selection_date_str :=
            INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).selection_date);


          -------------------------------------------------------
          -- Converting Dates For ORIGNAL_BOM_REFERENCE
          -------------------------------------------------------

            IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).orignal_bom_reference IS NOT NULL) THEN
              x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).orignal_bom_reference.as_of_date_str :=
              INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).orignal_bom_reference.as_of_date);
            END IF;


          -------------------------------------------------------
          -- Converting Dates For ITEM_REVISION_UDA
          -------------------------------------------------------

            IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item_revision_uda IS NOT NULL) THEN
              IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item_revision_uda.attribute_group_tbl IS NOT NULL AND
                p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item_revision_uda.attribute_group_tbl.COUNT >0) THEN
                FOR k IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item_revision_uda.attribute_group_tbl.FIRST..
                  p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item_revision_uda.attribute_group_tbl.LAST LOOP
                  IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item_revision_uda.attribute_group_tbl(k).attributes_tbl IS NOT NULL) THEN
                    FOR l IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item_revision_uda.attribute_group_tbl(k).attributes_tbl.FIRST..
                      p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item_revision_uda.attribute_group_tbl(k).attributes_tbl.LAST LOOP
                      x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item_revision_uda.attribute_group_tbl(k).attributes_tbl(l).attr_value_date_str :=
                      INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item_revision_uda.attribute_group_tbl(k).attributes_tbl(l).attr_value_date);
                    END LOOP;
                  END IF;
                END LOOP;
              END IF;
            END IF;

         ----------------------------------------------------------------------------------------------------------------
         -- Converting Dates For INV_EBI_ITEM_OBJ(inv_ebi_item_obj)
         ----------------------------------------------------------------------------------------------------------------


           IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type IS NOT NULL) THEN

             x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.start_date_active_str :=
             INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.start_date_active);

             x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.end_date_active_str :=
             INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.end_date_active);

             x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.creation_date_str :=
             INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.creation_date);

             x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.last_update_date_str :=
             INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.last_update_date);

             x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.program_update_date_str :=
             INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.program_update_date);

             x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.effectivity_date_str :=
             INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.main_obj_type.effectivity_date);

           END IF;

         ------------------------------------------------------
         -- Converting Dates For INV_EBI_ITEM_DEPRECATED_OBJ
         ------------------------------------------------------

           IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.deprecated_obj_type IS NOT NULL) THEN

             x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.deprecated_obj_type.engineering_date_str :=
             INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.deprecated_obj_type.engineering_date);

             x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.deprecated_obj_type.wh_update_date_str :=
             INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.deprecated_obj_type.wh_update_date_str);

           END IF;

        --------------------------------------------------------
        -- Converting Dates For  INV_EBI_UDA_INPUT_OBJ
        --------------------------------------------------------

          IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.uda_type.attribute_group_tbl IS NOT NULL AND
            p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.uda_type.attribute_group_tbl.COUNT>0) THEN
            FOR k IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.uda_type.attribute_group_tbl.FIRST..
              p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.uda_type.attribute_group_tbl.LAST LOOP
              IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.uda_type.attribute_group_tbl(k).attributes_tbl IS NOT NULL AND
                p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.uda_type.attribute_group_tbl(k).attributes_tbl.COUNT>0) THEN
                FOR l IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.uda_type.attribute_group_tbl(k).attributes_tbl.FIRST..
                  p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.uda_type.attribute_group_tbl(k).attributes_tbl.LAST LOOP
                  x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.uda_type.attribute_group_tbl(k).attributes_tbl(l).attr_value_date_str :=
                  INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).item.uda_type.attribute_group_tbl(k).attributes_tbl(l).attr_value_date);
                END LOOP;
              END IF;
            END LOOP;
          END IF;


        ------------------------------------------------------------------------------
        -- Converting Dates For structure_header (INV_EBI_STRUCTURE_HEADER_OBJ)
        ------------------------------------------------------------------------------

          IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).structure_header.structure_header_uda.attribute_group_tbl IS NOT NULL AND
            p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).structure_header.structure_header_uda.attribute_group_tbl.COUNT>0) THEN
            FOR k IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).structure_header.structure_header_uda.attribute_group_tbl.FIRST..
              p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).structure_header.structure_header_uda.attribute_group_tbl.LAST LOOP
              IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).structure_header.structure_header_uda.attribute_group_tbl(k).attributes_tbl IS NOT NULL AND
                p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).structure_header.structure_header_uda.attribute_group_tbl(k).attributes_tbl.COUNT>0) THEN
                FOR l IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).structure_header.structure_header_uda.attribute_group_tbl(k).attributes_tbl.FIRST..
                  p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).structure_header.structure_header_uda.attribute_group_tbl(k).attributes_tbl.LAST LOOP
                  x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).structure_header.structure_header_uda.attribute_group_tbl(k).attributes_tbl(l).attr_value_date_str :=
                  INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).structure_header.structure_header_uda.attribute_group_tbl(k).attributes_tbl(l).attr_value_date);
                END LOOP;
              END IF;
            END LOOP;
          END IF;

        --------------------------------------------------------------------------------
        -- Converting Dates For component_item_tbl (INV_EBI_REV_COMP_TBL)
        --------------------------------------------------------------------------------

          IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl IS NOT NULL AND
            p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl.COUNT>0 ) THEN
            FOR k IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl.FIRST..
              p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl.LAST LOOP

              x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).start_effective_date_str :=
              INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).start_effective_date);

              x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).new_effectivity_date_str :=
              INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).new_effectivity_date);

              x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).disable_date_str :=
              INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).disable_date);

              x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).old_effectivity_date_str :=
              INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).old_effectivity_date);

        --------------------------------------------------------------------------
        -- Converting Dates For substitute_component_tbl( INV_EBI_SUB_COMP_TBL )
        --------------------------------------------------------------------------

              IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).substitute_component_tbl IS NOT NULL AND
                p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).substitute_component_tbl.COUNT>0) THEN
                FOR l IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).substitute_component_tbl.FIRST..
                  p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).substitute_component_tbl.LAST LOOP
                  x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).substitute_component_tbl(l).start_effective_date_str :=
                  INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).substitute_component_tbl(l).start_effective_date);
                END LOOP;
              END IF;

        ----------------------------------------------------------------------------
        -- Converting Dates for reference_designator_tbl( INV_EBI_REF_DESG_TBL )
        ----------------------------------------------------------------------------

              IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).reference_designator_tbl IS NOT NULL AND
                p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).reference_designator_tbl.COUNT>0) THEN
                FOR l IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).reference_designator_tbl.FIRST..
                  p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).reference_designator_tbl.LAST LOOP
                  x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).reference_designator_tbl(l).start_effective_date_str :=
                  INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).reference_designator_tbl(l).start_effective_date);
                END LOOP;
              END IF;

        ----------------------------------------------------------------------------
        -- Converting Dates for component_revision_uda ( INV_EBI_UDA_INPUT_OBJ )
        ----------------------------------------------------------------------------

              IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).component_revision_uda.attribute_group_tbl IS NOT NULL AND
                p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).component_revision_uda.attribute_group_tbl.COUNT>0) THEN
                FOR l IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).component_revision_uda.attribute_group_tbl.FIRST..
                  p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).component_revision_uda.attribute_group_tbl.LAST LOOP
                  IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).component_revision_uda.attribute_group_tbl(l).attributes_tbl IS NOT NULL AND
                    p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).component_revision_uda.attribute_group_tbl(l).attributes_tbl.COUNT>0) THEN
                    FOR m IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).component_revision_uda.attribute_group_tbl(l).attributes_tbl.FIRST..
                      p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).component_revision_uda.attribute_group_tbl(l).attributes_tbl.LAST LOOP
                      x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).component_revision_uda.attribute_group_tbl(l).attributes_tbl(m).attr_value_date_str :=
                      INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).component_item_tbl(k).component_revision_uda.attribute_group_tbl(l).attributes_tbl(m).attr_value_date);
                    END LOOP;
                  END IF;
                END LOOP;
              END IF;

       --------------------------------------------------------------------------------
       -- Converting Dates For revision_operation_tbl ( INV_EBI_REV_OP_TBL )
       --------------------------------------------------------------------------------

              IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_operation_tbl IS NOT NULL AND
                p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_operation_tbl.COUNT>0) THEN
                FOR k IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_operation_tbl.FIRST..
                  p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_operation_tbl.LAST LOOP

                  x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_operation_tbl(k).start_effective_date_str :=
                  INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_operation_tbl(k).start_effective_date);

                  x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_operation_tbl(k).old_start_effective_number_str :=
                  INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_operation_tbl(k).old_start_effective_number);

                  x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_operation_tbl(k).disable_number_str :=
                  INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_operation_tbl(k).disable_number);
                END LOOP;
              END IF;

       ----------------------------------------------------------------------------------
       -- Converting Dates For revision_op_resource_tbl (INV_EBI_REV_OP_RES_TBL)
       ----------------------------------------------------------------------------------

              IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_op_resource_tbl IS NOT NULL AND
                p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_op_resource_tbl.COUNT>0) THEN
                FOR k IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_op_resource_tbl.FIRST..
                  p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_op_resource_tbl.LAST LOOP
                  x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_op_resource_tbl(k).op_start_effective_date_str :=
                  INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_op_resource_tbl(k).op_start_effective_date);
                END LOOP;
              END IF;

       ----------------------------------------------------------------------------------------------------------------
       -- Converting Dates For revision_sub_resource_tbl (INV_EBI_REV_SUB_RES_TBL)
       ----------------------------------------------------------------------------------------------------------------

              IF(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_sub_resource_tbl IS NOT NULL AND
                p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_sub_resource_tbl.COUNT>0) THEN
                FOR k IN p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_sub_resource_tbl.FIRST..
                  p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_sub_resource_tbl.LAST LOOP
                  x_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_sub_resource_tbl(k).op_start_effective_date_str :=
                  INV_EBI_ITEM_HELPER.convert_date_str(p_eco_lst_obj(i).eco_attr.eco_revised_item_type(j).revision_sub_resource_tbl(k).op_start_effective_date);
                END LOOP;
              END IF;
            END LOOP;
          END IF;
        END LOOP;
      END IF;
    END LOOP;
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_eco_lst_obj := p_eco_lst_obj;
END  Convert_date_str_eco;

/************************************************************************************
 --     API name        : get_eco_list_attr
 --     Type            : Public
 --     Function        : This API to retrive change order for multiple change id
 --
************************************************************************************/
PROCEDURE get_eco_list_attr(
  p_change_lst                 IN              inv_ebi_change_id_obj_tbl
  ,p_name_val_list             IN              inv_ebi_name_value_list
  ,x_eco_lst_obj               OUT NOCOPY      inv_ebi_eco_out_obj_tbl
  ,x_return_status             OUT NOCOPY      VARCHAR2
  ,x_msg_count                 OUT NOCOPY      NUMBER
  ,x_msg_data                  OUT NOCOPY      VARCHAR2
  )
IS
 l_msg_data                    VARCHAR2(32000);
  l_return_status               VARCHAR2(1);
  l_ovrflw_msg                  VARCHAR2(1):='N';
  l_count                       NUMBER := 0;
  l_part_msgtxt                 VARCHAR2(32000);
  l_name_val_list               inv_ebi_name_value_list;
  l_eco_obj                     inv_ebi_eco_obj;
  l_eco_obj_tbl                 inv_ebi_eco_out_obj_tbl;
  l_eco_lst_obj                 inv_ebi_eco_out_obj;
  l_mult_org_chg_id_temp        inv_ebi_change_id_obj_tbl;
  l_mult_org_chg_id_tbl         inv_ebi_change_id_obj_tbl;
  l_eco_output_tbl_lst          inv_ebi_change_id_obj_tbl;

CURSOR c_get_multi_org_chg_id(p_chg_id NUMBER)
 IS
   SELECT inv_ebi_change_id_obj(geco.change_id,'N')
   FROM (SELECT eec1.change_id
         FROM eng_engineering_changes eec,eng_engineering_changes eec1
         where eec.change_id=p_chg_id
         and eec.change_notice=eec1.change_notice
         MINUS
         SELECT b.change_id
         FROM THE (SELECT CAST(p_change_lst as inv_ebi_change_id_obj_tbl)
                   FROM dual) b ) geco;

CURSOR c_get_final_eco_list  IS
      SELECT inv_ebi_change_id_obj(geco.change_id,geco.last_update_status)
      FROM (SELECT b.change_id,b.last_update_status
            FROM THE (SELECT CAST( p_change_lst as inv_ebi_change_id_obj_tbl)
                       FROM dual ) b
            UNION
            SELECT c.change_id,c.last_update_status
            FROM THE (SELECT CAST( l_mult_org_chg_id_tbl as inv_ebi_change_id_obj_tbl)
                     FROM dual ) c  ) geco;
BEGIN
  l_eco_obj_tbl   := inv_ebi_eco_out_obj_tbl();
  l_name_val_list := p_name_val_list;
 /* --BUG 8712091
  IF l_name_val_list.name_value_table IS NOT NULL AND l_name_val_list.name_value_table.COUNT>0
  THEN
    INV_EBI_UTIL.set_apps_context(l_name_val_list.name_value_table);
  END IF;
*/
  x_return_status := FND_API.G_RET_STS_SUCCESS;
  l_mult_org_chg_id_tbl := inv_ebi_change_id_obj_tbl();
  l_mult_org_chg_id_temp := inv_ebi_change_id_obj_tbl();

  INV_EBI_ITEM_HELPER.set_server_time_zone;

  INV_EBI_UTIL.setup();

  INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_CHANGE_ORDER_PUB.get_eco_list_attr');
  INV_EBI_UTIL.debug_line( ' **************** Apps Context Details ****************' );
  INV_EBI_UTIL.debug_line(' User Id: ' || FND_GLOBAL.USER_ID || '; Responsibility Application id: ' ||
                           FND_GLOBAL.RESP_APPL_ID || '; Responsibility Id: ' || FND_GLOBAL.RESP_ID ||
                         '; Security Group id: '|| FND_GLOBAL.SECURITY_GROUP_ID ||'; User Lang: '|| USERENV('LANG') );
  INV_EBI_UTIL.debug_line( ' ****************  End of Apps Context ****************' );

  IF p_change_lst IS NOT NULL AND p_change_lst.COUNT > 0 THEN
    FOR i in 1..p_change_lst.COUNT LOOP
      OPEN c_get_multi_org_chg_id(p_change_lst(i).change_id);
      FETCH c_get_multi_org_chg_id BULK COLLECT INTO l_mult_org_chg_id_temp;
      IF l_mult_org_chg_id_temp IS NOT NULL AND l_mult_org_chg_id_temp.COUNT>0 THEN
        l_mult_org_chg_id_tbl.EXTEND(l_mult_org_chg_id_temp.COUNT);
        l_mult_org_chg_id_tbl := l_mult_org_chg_id_temp;
      END IF;
      CLOSE c_get_multi_org_chg_id;
    END LOOP;
  END IF;

  IF c_get_final_eco_list%ISOPEN THEN
    CLOSE c_get_final_eco_list;
  END IF;
  OPEN c_get_final_eco_list;
  FETCH c_get_final_eco_list BULK COLLECT INTO l_eco_output_tbl_lst;
  CLOSE c_get_final_eco_list;
  IF (l_eco_output_tbl_lst IS NOT NULL) THEN
    INV_EBI_UTIL.debug_line('STEP: 20 START CALLING INV_EBI_CHANGE_ORDER_HELPER.get_eco ');
    FOR l_cnt_cid IN 1..l_eco_output_tbl_lst.COUNT LOOP
       INV_EBI_CHANGE_ORDER_HELPER.get_eco (
        p_change_id                  => l_eco_output_tbl_lst(l_cnt_cid).change_id
       ,p_last_update_status         => l_eco_output_tbl_lst(l_cnt_cid).last_update_status
       ,p_revised_item_sequence_id   => NULL
       ,p_name_val_list              => l_name_val_list
       ,x_eco_obj                    => l_eco_obj
       ,x_return_status              => l_return_status
       ,x_msg_count                  => l_count
       ,x_msg_data                   => l_msg_data
       );
      IF (l_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_return_status := FND_API.g_ret_sts_error;
        l_part_msgtxt := ' Change Id: '|| p_change_lst(l_cnt_cid).change_id||' Err Msg: '||l_msg_data ;
        IF (x_msg_data IS NOT NULL) THEN
          IF (LENGTH(x_msg_data||' , '||l_part_msgtxt) < 31000) THEN
            x_msg_data :=x_msg_data||' , '||l_part_msgtxt;
          ELSE
            l_ovrflw_msg :='Y';
            EXIT;
          END IF;
        ELSE
          x_msg_data := l_part_msgtxt;
        END IF;
      END IF;
      l_eco_lst_obj := inv_ebi_eco_out_obj(l_eco_obj,inv_ebi_output_status(l_return_status,l_count,l_msg_data,NULL));
      l_eco_obj_tbl.EXTEND();
      l_eco_obj_tbl(l_cnt_cid) := l_eco_lst_obj;
    END LOOP;
    IF (l_ovrflw_msg='Y') AND SUBSTR(x_msg_data,length(x_msg_data)-2) <> '...' THEN
      x_msg_data :=x_msg_data||' , '||'...';
    END IF;
    INV_EBI_UTIL.debug_line('STEP: 30 END CALLING INV_EBI_CHANGE_ORDER_HELPER.get_eco ');
  END IF;

  IF (l_eco_obj_tbl IS NOT NULL AND l_eco_obj_tbl.COUNT > 0) THEN
    x_eco_lst_obj := l_eco_obj_tbl;
    Convert_date_str_eco(p_eco_lst_obj => l_eco_obj_tbl
                        ,x_eco_lst_obj => x_eco_lst_obj);
  END IF;

  INV_EBI_UTIL.debug_line('STEP: 40 END INSIDE INV_EBI_CHANGE_ORDER_PUB.get_eco_list_attr');

  INV_EBI_UTIL.wrapup;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF (x_msg_data IS NOT NULL) THEN
      x_msg_data := x_msg_data ||' -> at INV_EBI_CHANGE_ORDER_PUB.get_eco_list_attr';
    ELSE
      x_msg_data  :=  SQLERRM||'  at INV_EBI_CHANGE_ORDER_PUB.get_eco_list_attr ';
    END IF;
END get_eco_list_attr;

/************************************************************************************
 --     API name        : process_change_order_items
 --     Type            : Private
 --     Procedure         :
 --     This API is used to create Items coming in the Change Order if item
 --     does not exist
 --     Added this API for Bug 8397083
 ************************************************************************************/

 PROCEDURE process_change_order_items(
   p_commit               IN  VARCHAR2 := FND_API.g_false
  ,p_eco_obj              IN  inv_ebi_eco_obj
  ,p_update_item_tbl      IN  inv_ebi_item_attr_tbl
  ,x_update_item_tbl      OUT NOCOPY  inv_ebi_item_attr_tbl
  ,x_out                  OUT NOCOPY  inv_ebi_item_output_obj
  ,x_eco_obj              OUT NOCOPY  inv_ebi_eco_obj
 ) IS

   l_item                      inv_ebi_item_obj;
   l_revised_item_tbl          inv_ebi_revised_item_tbl;
   l_eco_obj                   inv_ebi_eco_obj;
   l_master_org                NUMBER;
   l_inventory_item_id         NUMBER;
   l_current_revision          VARCHAR2(3);
   l_revision                  VARCHAR2(3);
   l_revision_set              BOOLEAN := FALSE;
   l_cnt_nmval                 NUMBER := 0;
   l_item_output_obj           inv_ebi_item_output_obj;
   l_eco_output_obj            inv_ebi_eco_output_obj;
   l_item_count                NUMBER :=0;
   l_update_item_count         NUMBER :=0;
   l_output_status             inv_ebi_output_status;

   CURSOR c_effectivity_date(
        p_organization_id IN NUMBER,
        p_inventory_item_id  IN NUMBER
     )
     IS
       SELECT revision
       FROM mtl_item_revisions_b
       WHERE
         organization_id    = p_organization_id AND
         inventory_item_id  = p_inventory_item_id;

 BEGIN
   SAVEPOINT inv_ebi_chg_items_save_pnt;
   FND_MSG_PUB.initialize;

   l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
   x_out           := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);

   INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_CHANGE_ORDER_PUB.process_change_order_items');

   x_update_item_tbl   :=     inv_ebi_item_attr_tbl();

   x_update_item_tbl   :=     p_update_item_tbl;

   l_eco_obj          :=      p_eco_obj;

   IF(l_eco_obj.eco_revised_item_type IS NOT NULL AND l_eco_obj.eco_change_order_type IS NOT NULL) THEN

     FOR i IN 1 .. l_eco_obj.eco_revised_item_type.COUNT
     LOOP

      --To populate item attributes from revised item values.

      populate_item_attributes(
        p_change_order_obj => l_eco_obj.eco_change_order_type
       ,p_revised_item     => l_eco_obj.eco_revised_item_type(i)
       ,x_item             => l_item
       ,x_out              => l_item_output_obj
      );

      IF (l_item_output_obj.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_out.output_status.msg_data   := l_item_output_obj.output_status.msg_data;
        x_out.output_status.msg_count  := l_item_output_obj.output_status.msg_count;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;

      END IF;

      INV_EBI_ITEM_HELPER.populate_item_ids(
        p_item  =>  l_item
       ,x_out   =>  l_item_output_obj
       ,x_item  =>  l_eco_obj.eco_revised_item_type(i).item
      );
      IF (l_item_output_obj.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_out.output_status.msg_data   := l_item_output_obj.output_status.msg_data;
        x_out.output_status.msg_count  := l_item_output_obj.output_status.msg_count;
        RAISE  FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      INV_EBI_UTIL.debug_line('STEP: 20 START CALLING INV_EBI_CHANGE_ORDER_PUB.validate_eco');

      validate_item(
        p_item   =>   l_item
       ,x_out    =>   l_item_output_obj
      );

      INV_EBI_UTIL.debug_line('STEP: 30 END CALLING INV_EBI_CHANGE_ORDER_PUB.validate_eco');

      IF (l_item_output_obj.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_out.output_status.msg_data   := l_item_output_obj.output_status.msg_data;
        x_out.output_status.msg_count  := l_item_output_obj.output_status.msg_count;
        RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
      END IF;


      l_eco_obj.eco_revised_item_type(i).item.NAME_VALUE_TBL := INV_EBI_NAME_VALUE_TBL();
      l_cnt_nmval := 0;

      IF l_eco_obj.NAME_VALUE_TBL IS NOT NULL AND l_eco_obj.NAME_VALUE_TBL.COUNT >0 THEN

        FOR x in 1..l_eco_obj.NAME_VALUE_TBL.COUNT
        LOOP

          IF l_eco_obj.NAME_VALUE_TBL(x).PARAM_NAME in ('VALIDATE_REVISED_ITEM_REVISION','TEMPLATE_FOR_ITEM_UPDATE_ALLOWED') THEN

            l_eco_obj.eco_revised_item_type(i).item.NAME_VALUE_TBL.extend();
            l_cnt_nmval := l_cnt_nmval+1;
            l_eco_obj.eco_revised_item_type(i).item.NAME_VALUE_TBL(l_cnt_nmval) :=  INV_EBI_NAME_VALUE_OBJ(l_eco_obj.NAME_VALUE_TBL(x).PARAM_NAME,l_eco_obj.NAME_VALUE_TBL(x).PARAM_VALUE);

          END IF;
        END LOOP;
      END IF;

      l_revision_set := FALSE;

      IF( INV_EBI_ITEM_HELPER.is_item_exists (
           p_organization_id    =>   l_eco_obj.eco_revised_item_type(i).item.main_obj_type.organization_id
          ,p_item_number        =>   l_eco_obj.eco_revised_item_type(i).item.main_obj_type.item_number
      ) = FND_API.g_false ) THEN

        /* Bug 7132835 After subsequent release of ecos in master org ,If Change order is released in Child Org
           then we should create initial rev,current rev of the item in master org through process_item API
           and incoming revision through process_eco API */

        IF(INV_EBI_CHANGE_ORDER_HELPER.is_child_org (
           p_organization_id  =>  l_eco_obj.eco_revised_item_type(i).item.main_obj_type.organization_id
         ) = fnd_api.g_true) THEN

          l_master_org := INV_EBI_UTIL.get_master_organization(
                             p_organization_id  => l_eco_obj.eco_revised_item_type(i).item.main_obj_type.organization_id
                          );

          l_inventory_item_id := INV_EBI_ITEM_HELPER.get_inventory_item_id (
                                   p_organization_id => l_master_org
                                  ,p_item_number     => l_eco_obj.eco_revised_item_type(i).item.main_obj_type.item_number
                                 );

          l_current_revision := INV_EBI_CHANGE_ORDER_HELPER.get_current_item_revision(
            p_inventory_item_id  => l_inventory_item_id,
            p_organization_id    => l_master_org,
            p_date               => sysdate
          );

          IF(l_current_revision = l_eco_obj.eco_revised_item_type(i).new_revised_item_revision ) THEN

            l_eco_obj.eco_revised_item_type(i).item.main_obj_type.revision_code := fnd_api.g_miss_char;

          ELSIF( l_current_revision <> l_eco_obj.eco_revised_item_type(i).new_revised_item_revision AND
                 l_current_revision <  l_eco_obj.eco_revised_item_type(i).new_revised_item_revision ) THEN

            l_eco_obj.eco_revised_item_type(i).item.main_obj_type.revision_code    := l_current_revision;

            --Bug 7132835 If 2 revisions are to be created then intial rev gets created with sysdate +1 ,to have effectivity_date of
            -- next rev greater than that of initial rev we added 0.5 sec

            l_eco_obj.eco_revised_item_type(i).item.main_obj_type.effectivity_date := sysdate+ 2/86400;
            l_revision_set := TRUE;

          END IF;
        END IF;

        --call Create New Production Item API .This will also process existing item information.

        INV_EBI_UTIL.debug_line('STEP: 40 START CALLING INV_EBI_ITEM_HELPER.sync_item');
        INV_EBI_ITEM_HELPER.sync_item(
          p_commit     =>  FND_API.g_false
         ,p_operation  =>  INV_EBI_ITEM_PUB.g_otype_create
         ,p_item       =>  l_eco_obj.eco_revised_item_type(i).item
         ,x_out        =>  l_item_output_obj
        );

        INV_EBI_UTIL.debug_line('STEP: 50 END CALLING INV_EBI_ITEM_HELPER.sync_item');

        l_item_count  := l_item_count + 1;

        IF (l_item_output_obj.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_out.output_status.msg_data   := l_item_output_obj.output_status.msg_data;
          x_out.output_status.msg_count  := l_item_output_obj.output_status.msg_count;
          RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
        END IF;

        IF(l_revision_set = TRUE ) THEN

          /* Bug 7132835 When we create 2 revison thru EGO_ITEM_PUB.process_item  API
             they are adding sysdate + 1 sec to initial rev and given rev gets created
             only if effectivty date being passed is greater than sysdate+1 sec.
             By this eco errors out as it does not have current implemnted rev for the
             revised item.So updating implementaion date and effectivity date of initial
             rev to sysdate.*/

          IF c_effectivity_date%ISOPEN THEN
            CLOSE c_effectivity_date;
          END IF;

          OPEN c_effectivity_date (
                  p_organization_id   => l_item_output_obj.organization_id,
                  p_inventory_item_id => l_item_output_obj.inventory_item_id
                                  );

          FETCH c_effectivity_date INTO l_revision;
          CLOSE c_effectivity_date;

          INV_EBI_UTIL.debug_line('STEP: 60 START update mtl_item_revisions_b');

          UPDATE mtl_item_revisions_b
          SET
            implementation_date =   sysdate,
            effectivity_date    =   sysdate,
            creation_date       =   sysdate,
            last_update_date    =   sysdate,
            last_updated_by     =   DECODE(last_updated_by, NULL, fnd_global.user_id,last_updated_by),
            created_by          =   DECODE(last_updated_by, NULL, fnd_global.user_id,last_updated_by)
          WHERE
            inventory_item_id = l_item_output_obj.inventory_item_id AND
            organization_id   = l_item_output_obj.organization_id AND
            revision          = l_revision;

          INV_EBI_UTIL.debug_line('STEP: 70 END update mtl_item_revisions_b');
        END IF;

      ELSE
        x_update_item_tbl.EXTEND(1);

        l_update_item_count  := x_update_item_tbl.COUNT;
        l_item_count         := l_item_count + 1;

        x_update_item_tbl(l_update_item_count) := INV_EBI_GET_ITEM_OUTPUT_OBJ(NULL,NULL,NULL,NULL);
        x_update_item_tbl(l_update_item_count).item_obj  :=  l_eco_obj.eco_revised_item_type(i).item;

        --Transfer Engg Item to Manufacturing
        INV_EBI_UTIL.debug_line('STEP: 80 START CALLING transfer_engg_item_mfg');
        transfer_engg_item_mfg(
          p_item                  => l_eco_obj.eco_revised_item_type(i).item
         ,p_alt_bom_designator    => l_eco_obj.eco_revised_item_type(i).alternate_bom_code
         ,x_out                   => l_eco_output_obj
        );

        INV_EBI_UTIL.debug_line('STEP: 90 END CALLING transfer_engg_item_mfg');

        IF (l_eco_output_obj.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
          x_out.output_status.msg_data   := l_item_output_obj.output_status.msg_data;
          x_out.output_status.msg_count  := l_item_output_obj.output_status.msg_count;
          RAISE fnd_api.g_exc_unexpected_error;
        END IF;

      END IF;
    END LOOP;
  END IF;
  x_eco_obj := l_eco_obj;
  IF FND_API.to_boolean(p_commit) THEN
   COMMIT;
  END IF;

  INV_EBI_UTIL.debug_line('STEP: 100 END INSIDE INV_EBI_CHANGE_ORDER_PUB.process_change_order_items');

 EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO inv_ebi_chg_items_save_pnt;

     IF c_effectivity_date%ISOPEN THEN
       CLOSE c_effectivity_date;
     END IF;

     x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;

     IF(x_out.output_status.msg_data IS NULL) THEN

       x_out.output_status.error_table     :=  INV_EBI_UTIL.get_error_table();

       IF (x_out.output_status.error_table IS NOT NULL AND x_out.output_status.error_table.COUNT > 0) THEN

         x_out.output_status.msg_data := INV_EBI_UTIL.get_error_table_msgtxt(x_out.output_status.error_table);

         IF(x_out.output_status.msg_data  IS NULL) THEN
           FND_MSG_PUB.count_and_get(
             p_encoded => FND_API.g_false
            ,p_count   => x_out.output_status.msg_data
            ,p_data    => x_out.output_status.msg_data
          );
         END IF;
       END IF;
     END IF;

   WHEN OTHERS THEN
     ROLLBACK TO inv_ebi_chg_items_save_pnt;

     IF c_effectivity_date%ISOPEN THEN
       CLOSE c_effectivity_date;
     END IF;

     x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
     x_out.output_status.error_table     :=  INV_EBI_UTIL.get_error_table();

      IF (x_out.output_status.error_table IS NOT NULL AND x_out.output_status.error_table.COUNT > 0) THEN
        x_out.output_status.msg_data := INV_EBI_UTIL.get_error_table_msgtxt(x_out.output_status.error_table);
      END IF;

      IF (x_out.output_status.msg_data IS NOT NULL) THEN
        x_out.output_status.msg_data  :=  x_out.output_status.msg_data||' -> INV_EBI_CHANGE_ORDER_PUB.process_change_order_items ';
      ELSE
        x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_CHANGE_ORDER_PUB.process_change_order_items ';
     END IF;

  END process_change_order_items;

/************************************************************************************
 --     API name        : process_update_items
 --     Type            : Private
 --     Function        :
 --     This API is used to update chnage order items
 --     Added this API for Bug 8397083
 ************************************************************************************/
 PROCEDURE process_update_items(
     p_commit             IN  VARCHAR2 := FND_API.g_false
    ,p_update_item_tbl    IN  inv_ebi_item_attr_tbl
    ,x_out                OUT NOCOPY  inv_ebi_item_output_obj
  ) IS

  l_output_status      inv_ebi_output_status;

BEGIN
  SAVEPOINT inv_ebi_proc_upd_item_save_pnt;
  FND_MSG_PUB.initialize;
  INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_CHANGE_ORDER_PUB.process_update_items');
  l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
  x_out           := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);

  IF(p_update_item_tbl IS NOT NULL AND p_update_item_tbl.COUNT > 0) THEN

    FOR i IN 1..p_update_item_tbl.COUNT LOOP
      INV_EBI_UTIL.debug_line('STEP: 20 START CALLING INV_EBI_ITEM_HELPER.sync_item for item updation ');
      INV_EBI_ITEM_HELPER.sync_item(
         p_commit     =>  FND_API.g_false
        ,p_operation  =>  INV_EBI_ITEM_PUB.g_otype_update
        ,p_item       =>  p_update_item_tbl(i).item_obj
        ,x_out        =>  x_out
      );
      INV_EBI_UTIL.debug_line('STEP: 30 AFTER CALLING INV_EBI_ITEM_HELPER.sync_item for item updation ');
      IF (x_out.output_status.return_status <> fnd_api.g_ret_sts_success) THEN
        x_out.item_number := p_update_item_tbl(i).item_obj.main_obj_type.item_number;
        x_out.organization_code := p_update_item_tbl(i).item_obj.main_obj_type.organization_code;


        RAISE fnd_api.g_exc_unexpected_error;
      END IF;
    END LOOP;
  END IF;
  INV_EBI_UTIL.debug_line('STEP: 40 END INSIDE INV_EBI_CHANGE_ORDER_PUB.process_update_items');
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO inv_ebi_proc_upd_item_save_pnt;
    x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
    IF(x_out.output_status.msg_data IS NULL) THEN

      x_out.output_status.error_table     :=  INV_EBI_UTIL.get_error_table();

      IF (x_out.output_status.error_table IS NOT NULL AND x_out.output_status.error_table.COUNT > 0) THEN

        x_out.output_status.msg_data := INV_EBI_UTIL.get_error_table_msgtxt(x_out.output_status.error_table);

        IF(x_out.output_status.msg_data  IS NULL) THEN
          FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false
           ,p_count   => x_out.output_status.msg_count
           ,p_data    => x_out.output_status.msg_data
         );
        END IF;
      END IF;
    END IF;

  WHEN OTHERS THEN
    ROLLBACK TO inv_ebi_proc_upd_item_save_pnt;
    x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;

    x_out.output_status.error_table   :=  INV_EBI_UTIL.get_error_table();

     IF (x_out.output_status.error_table IS NOT NULL AND x_out.output_status.error_table.COUNT > 0) THEN
       x_out.output_status.msg_data := INV_EBI_UTIL.get_error_table_msgtxt(x_out.output_status.error_table);
     END IF;

     IF (x_out.output_status.msg_data IS NOT NULL) THEN
       x_out.output_status.msg_data  :=  x_out.output_status.msg_data||' -> INV_EBI_CHANGE_ORDER_PUB.process_update_items ';
     ELSE
       x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_CHANGE_ORDER_PUB.process_update_items ';
    END IF;
END process_update_items;

/************************************************************************************
 --     API name        : process_bom
 --     Type            : Private
 --     Function        :
 --     This API is used create BOM
 --     Added this API for Bug 8397083
 ************************************************************************************/
 PROCEDURE process_bom(
   p_commit          IN  VARCHAR2 := FND_API.g_false
  ,p_eco_obj_list    IN  inv_ebi_eco_obj_tbl
  ,x_eco_obj_list    OUT NOCOPY  inv_ebi_eco_obj_tbl
  ,x_out             OUT NOCOPY  inv_ebi_eco_output_obj
 ) IS

   l_eco_obj                     inv_ebi_eco_obj;
   l_replicate_bom_item_obj      inv_ebi_revised_item_obj;
   l_common_assy_item_tbl        inv_ebi_revised_item_tbl;
   l_replicate_bom_tbl           inv_ebi_revised_item_tbl;
   l_common_assy_item_cnt        NUMBER := 0;
   l_common_org_tbl              FND_TABLE_OF_VARCHAR2_30;
   l_replicate_bom_org_tbl       FND_TABLE_OF_VARCHAR2_30;
   l_common_eco_tbl              FND_TABLE_OF_VARCHAR2_30;
   l_replicate_bom_eco_tbl       FND_TABLE_OF_VARCHAR2_30;
   l_replicate_bom_cnt           NUMBER := 0;
   l_common_bom_found            VARCHAR2(1);
   l_replicate_bom_found         VARCHAR2(1);
   l_output_status               inv_ebi_output_status;
   l_out                         inv_ebi_eco_output_obj;
   l_eco_idx                     NUMBER;
   l_item_idx                    NUMBER;
   l_name_value_tbl              inv_ebi_name_value_tbl;
   l_is_bom_exists               VARCHAR2(1);


 BEGIN
 SAVEPOINT inv_ebi_process_bom_save_pnt;

 FND_MSG_PUB.initialize;

 l_output_status    :=     inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
 x_out              :=     inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

 l_common_assy_item_tbl    :=  inv_ebi_revised_item_tbl();
 l_replicate_bom_tbl       :=  inv_ebi_revised_item_tbl();
 l_common_org_tbl          :=  FND_TABLE_OF_VARCHAR2_30();
 l_replicate_bom_org_tbl   :=  FND_TABLE_OF_VARCHAR2_30();
 l_common_eco_tbl          :=  FND_TABLE_OF_VARCHAR2_30();
 l_replicate_bom_eco_tbl   :=  FND_TABLE_OF_VARCHAR2_30();
 x_eco_obj_list            :=  inv_ebi_eco_obj_tbl();
 INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_CHANGE_ORDER_PUB.process_bom');
 IF(p_eco_obj_list IS NOT NULL AND p_eco_obj_list.COUNT > 0) THEN
   x_eco_obj_list.EXTEND(p_eco_obj_list.COUNT);

   FOR i in 1..p_eco_obj_list.count
   LOOP

     l_eco_obj         := p_eco_obj_list(i);
     x_eco_obj_list(i) := p_eco_obj_list(i);

     l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);

     IF( l_eco_obj.eco_revised_item_type IS NOT NULL AND
         l_eco_obj.eco_revised_item_type.COUNT > 0) THEN

       FOR j IN 1..l_eco_obj.eco_revised_item_type.COUNT LOOP

         l_common_bom_found    := FND_API.g_false;
         l_replicate_bom_found := FND_API.g_false;


         IF(l_eco_obj.eco_revised_item_type(j).structure_header IS NOT NULL) THEN
           IF(l_eco_obj.eco_revised_item_type(j).structure_header.common_assembly_item_name IS NOT NULL
              AND l_eco_obj.eco_revised_item_type(j).structure_header.common_assembly_item_name <> fnd_api.g_miss_char
              AND l_eco_obj.eco_revised_item_type(j).structure_header.common_organization_code IS NOT NULL
              AND l_eco_obj.eco_revised_item_type(j).structure_header.common_organization_code <> fnd_api.g_miss_char
             ) THEN
             INV_EBI_UTIL.debug_line('STEP: 20 Commoning Needed');
             l_common_assy_item_tbl.EXTEND(1);
             l_common_org_tbl.EXTEND(1);
             l_common_eco_tbl.EXTEND(1);
             l_common_assy_item_cnt := l_common_assy_item_cnt+1;
             l_common_assy_item_tbl(l_common_assy_item_cnt) := l_eco_obj.eco_revised_item_type(j);
             l_common_org_tbl(l_common_assy_item_cnt) := l_eco_obj.eco_change_order_type.organization_code;
             l_common_eco_tbl(l_common_assy_item_cnt) := l_eco_obj.eco_change_order_type.eco_name;
             l_common_bom_found := fnd_api.g_true;

           END IF;
         END IF;

         IF(l_eco_obj.eco_revised_item_type(j).orignal_bom_reference IS NOT NULL) THEN


           IF( l_eco_obj.eco_revised_item_type(j).orignal_bom_reference.item_name IS NOT NULL
              AND l_eco_obj.eco_revised_item_type(j).orignal_bom_reference.item_name <>  fnd_api.g_miss_char
              AND l_eco_obj.eco_revised_item_type(j).orignal_bom_reference.ORGANIZATION_CODE IS NOT NULL
              AND l_eco_obj.eco_revised_item_type(j).orignal_bom_reference.ORGANIZATION_CODE <>  fnd_api.g_miss_char
            ) THEN

              l_is_bom_exists   := INV_EBI_CHANGE_ORDER_HELPER.is_bom_exists(
                                      p_item_number         => l_eco_obj.eco_revised_item_type(j).revised_item_name,
                                      p_organization_code   => l_eco_obj.eco_change_order_type.organization_code,
                                      p_alternate_bom_code  => l_eco_obj.eco_revised_item_type(j).alternate_bom_code
                                   );

              IF(l_is_bom_exists = FND_API.g_false) THEN
                INV_EBI_UTIL.debug_line('STEP: 30 Replication Needed');
                l_replicate_bom_tbl.EXTEND(1);
                l_replicate_bom_org_tbl.EXTEND(1);
                l_replicate_bom_eco_tbl.EXTEND(1);
                l_replicate_bom_cnt := l_replicate_bom_cnt+1;

                l_replicate_bom_org_tbl(l_replicate_bom_cnt) := l_eco_obj.eco_change_order_type.organization_code;
                l_replicate_bom_eco_tbl(l_replicate_bom_cnt) := l_eco_obj.eco_change_order_type.eco_name;

                INV_EBI_UTIL.debug_line('STEP: 40  BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.transform_replicate_bom_info');
                INV_EBI_CHANGE_ORDER_HELPER.transform_replicate_bom_info(
                   p_eco_obj_list      => p_eco_obj_list
                  ,p_revised_item_obj  => l_eco_obj.eco_revised_item_type(j)
                  ,x_revised_item_obj  => l_eco_obj.eco_revised_item_type(j)
                  ,x_out               => l_out
                );
                INV_EBI_UTIL.debug_line('STEP: 50  AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.transform_replicate_bom_info');
                IF(l_out.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
                  x_out.change_notice            := l_eco_obj.eco_change_order_type.eco_name;
                  x_out.organization_code        := l_eco_obj.eco_change_order_type.organization_code;
                  x_out.output_status.msg_data   := l_out.output_status.msg_data;
                  x_out.output_status.msg_count  := l_out.output_status.msg_count;
                  RAISE FND_API.g_exc_unexpected_error;
                END IF;

                l_replicate_bom_tbl(l_replicate_bom_cnt) := l_eco_obj.eco_revised_item_type(j);
                l_replicate_bom_found := fnd_api.g_true;


             END IF;
           END IF;
         END IF;

         IF( l_common_bom_found = FND_API.g_false
             AND l_replicate_bom_found = FND_API.g_false
             AND l_eco_obj.eco_revised_item_type(j).structure_header IS NOT NULL) THEN

           INV_EBI_UTIL.debug_line('STEP: 60 BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_structure_header '
                                   || 'FOR Normal BOM ');
           INV_EBI_CHANGE_ORDER_HELPER.process_structure_header(
            p_commit               =>  FND_API.g_false
           ,p_organization_code    =>  l_eco_obj.eco_change_order_type.organization_code
           ,p_assembly_item_name   =>  l_eco_obj.eco_revised_item_type(j).revised_item_name
           ,p_alternate_bom_code   =>  l_eco_obj.eco_revised_item_type(j).alternate_bom_code
           ,p_structure_header     =>  l_eco_obj.eco_revised_item_type(j).structure_header
           ,p_component_item_tbl   =>  l_eco_obj.eco_revised_item_type(j).component_item_tbl -- Bug 7192021
           ,p_name_val_list        =>  inv_ebi_name_value_list(l_eco_obj.name_value_tbl)
           ,x_out                  =>  l_out
           );
           INV_EBI_UTIL.debug_line('STEP: 70 AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_structure_header '
                                   || 'FOR Normal BOM ');
           IF(l_out.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
             x_out.change_notice            := l_eco_obj.eco_change_order_type.eco_name;
             x_out.organization_code        := l_eco_obj.eco_change_order_type.organization_code;
             x_out.output_status.msg_data   := l_out.output_status.msg_data;
             x_out.output_status.msg_count  := l_out.output_status.msg_count;
             RAISE FND_API.g_exc_unexpected_error;
           END IF;

         END IF;
       END LOOP;
     END IF;
   END LOOP;
 END IF;

 IF(l_common_assy_item_tbl IS NOT NULL AND l_common_assy_item_tbl.COUNT > 0) THEN
   FOR l_common_assy_item_cnt IN 1..l_common_assy_item_tbl.COUNT LOOP
     FOR l_count IN 1..p_eco_obj_list.COUNT LOOP

       IF( p_eco_obj_list(l_count).eco_change_order_type.eco_name = l_common_eco_tbl(l_common_assy_item_cnt)
           AND p_eco_obj_list(l_count).eco_change_order_type.organization_code = l_common_org_tbl(l_common_assy_item_cnt)
          ) THEN
          l_name_value_tbl := p_eco_obj_list(l_count).name_value_tbl;

       END IF;

     END LOOP;
     INV_EBI_UTIL.debug_line('STEP: 80 BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_structure_header '
                                   || 'FOR COMMON BOM ');
     INV_EBI_CHANGE_ORDER_HELPER.process_structure_header(
         p_commit               =>  FND_API.g_false
        ,p_organization_code    =>  l_common_org_tbl(l_common_assy_item_cnt)
        ,p_assembly_item_name   =>  l_common_assy_item_tbl(l_common_assy_item_cnt).revised_item_name
        ,p_alternate_bom_code   =>  l_common_assy_item_tbl(l_common_assy_item_cnt).alternate_bom_code
        ,p_structure_header     =>  l_common_assy_item_tbl(l_common_assy_item_cnt).structure_header
        ,p_component_item_tbl   =>  l_common_assy_item_tbl(l_common_assy_item_cnt).component_item_tbl -- Bug 7192021
        ,p_name_val_list        =>  inv_ebi_name_value_list(l_name_value_tbl)
        ,x_out                  =>  l_out
     );
     INV_EBI_UTIL.debug_line('STEP: 90 AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_structure_header '
                                   || 'FOR COMMON BOM ');
     IF(l_out.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
       x_out.change_notice            := l_common_eco_tbl(l_common_assy_item_cnt);
       x_out.organization_code        := l_common_org_tbl(l_common_assy_item_cnt);
       x_out.output_status.msg_data   := l_out.output_status.msg_data;
       x_out.output_status.msg_count  := l_out.output_status.msg_count;

       RAISE FND_API.g_exc_unexpected_error;
     END IF;
   END LOOP;
 END IF;

 IF(l_replicate_bom_tbl IS NOT NULL AND l_replicate_bom_tbl.COUNT > 0) THEN

   FOR l_replicate_bom_cnt IN 1..l_replicate_bom_tbl.COUNT LOOP

     FOR l_count IN 1..p_eco_obj_list.COUNT LOOP

       IF( p_eco_obj_list(l_count).eco_change_order_type.eco_name = l_replicate_bom_eco_tbl(l_replicate_bom_cnt)
           AND p_eco_obj_list(l_count).eco_change_order_type.organization_code = l_replicate_bom_org_tbl(l_replicate_bom_cnt)
          ) THEN
          l_name_value_tbl := p_eco_obj_list(l_count).name_value_tbl;
          l_eco_idx  := l_count;
          FOR l_count1 IN 1..p_eco_obj_list(l_count).eco_revised_item_type.COUNT LOOP
            IF(p_eco_obj_list(l_count).eco_revised_item_type(l_count1).revised_item_name = l_replicate_bom_tbl(l_replicate_bom_cnt).revised_item_name) THEN
              l_item_idx := l_count1;
            END IF;
          END LOOP;
        END IF;
     END LOOP;

     INV_EBI_UTIL.debug_line('STEP: 90 BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_replicate_bom '
                                    || 'FOR REPLICATE BOM ');
     INV_EBI_CHANGE_ORDER_HELPER.process_replicate_bom(
      p_organization_code  => l_replicate_bom_org_tbl(l_replicate_bom_cnt)
     ,p_revised_item_obj   => l_replicate_bom_tbl(l_replicate_bom_cnt)
     ,p_name_value_tbl     => l_name_value_tbl
     ,x_revised_item_obj   => l_replicate_bom_item_obj
     ,x_out                => l_out
     );
     INV_EBI_UTIL.debug_line('STEP: 100 AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_replicate_bom '
                                    || 'FOR REPLICATE BOM ');

     x_eco_obj_list(l_eco_idx).eco_revised_item_type(l_item_idx)  := l_replicate_bom_item_obj;

     IF(l_out.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN

       x_out.change_notice            := l_replicate_bom_eco_tbl(l_replicate_bom_cnt);
       x_out.organization_code        := l_replicate_bom_org_tbl(l_replicate_bom_cnt);
       x_out.output_status.msg_data   := l_out.output_status.msg_data;
       x_out.output_status.msg_count  := l_out.output_status.msg_count;


       RAISE FND_API.g_exc_unexpected_error;
     END IF;

     IF(l_replicate_bom_tbl(l_replicate_bom_cnt).structure_header IS NOT NULL) THEN
       INV_EBI_UTIL.debug_line('STEP: 110 BEFORE CALLING INV_EBI_CHANGE_ORDER_HELPER.process_structure_header '
                                    || 'FOR REPLICATE BOM ');
       INV_EBI_CHANGE_ORDER_HELPER.process_structure_header(
        p_commit               =>  FND_API.g_false
       ,p_organization_code    =>  l_replicate_bom_org_tbl(l_replicate_bom_cnt)
       ,p_assembly_item_name   =>  l_replicate_bom_tbl(l_replicate_bom_cnt).revised_item_name
       ,p_alternate_bom_code   =>  l_replicate_bom_tbl(l_replicate_bom_cnt).alternate_bom_code
       ,p_structure_header     =>  l_replicate_bom_tbl(l_replicate_bom_cnt).structure_header
       ,p_component_item_tbl   =>  l_replicate_bom_tbl(l_replicate_bom_cnt).component_item_tbl -- Bug 7192021
       ,p_name_val_list        =>  inv_ebi_name_value_list(l_name_value_tbl)
       ,x_out                  =>  l_out
       );

       INV_EBI_UTIL.debug_line('STEP: 120 AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_structure_header '
                                   || 'FOR REPLICATE BOM ');

       IF(l_out.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN

         x_out.change_notice            := l_replicate_bom_eco_tbl(l_replicate_bom_cnt);
         x_out.organization_code        := l_replicate_bom_org_tbl(l_replicate_bom_cnt);
         x_out.output_status.msg_data   := l_out.output_status.msg_data;
         x_out.output_status.msg_count  := l_out.output_status.msg_count;

         RAISE FND_API.g_exc_unexpected_error;
       END IF;
     END IF;
   END LOOP;
 END IF;
 INV_EBI_UTIL.debug_line('STEP: 130 END OF INV_EBI_CHANGE_ORDER_PUB.process_bom');
 IF FND_API.to_boolean(p_commit) THEN
   COMMIT;
 END IF;

 EXCEPTION

 WHEN FND_API.g_exc_unexpected_error THEN
   ROLLBACK TO inv_ebi_process_bom_save_pnt;
   x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;

   IF(x_out.output_status.msg_data IS NULL) THEN

     x_out.output_status.error_table     :=  INV_EBI_UTIL.get_error_table();

     IF (x_out.output_status.error_table IS NOT NULL AND x_out.output_status.error_table.COUNT > 0) THEN

       x_out.output_status.msg_data := INV_EBI_UTIL.get_error_table_msgtxt(x_out.output_status.error_table);

       IF(x_out.output_status.msg_data  IS NULL) THEN
         FND_MSG_PUB.count_and_get(
           p_encoded => FND_API.g_false
          ,p_count   => x_out.output_status.msg_count
          ,p_data    => x_out.output_status.msg_data
        );
       END IF;

     END IF;
   END IF;

 WHEN OTHERS THEN
    ROLLBACK TO inv_ebi_process_bom_save_pnt;
    x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;

    x_out.output_status.error_table     :=  INV_EBI_UTIL.get_error_table();

    IF (x_out.output_status.error_table IS NOT NULL AND
        x_out.output_status.error_table.COUNT > 0) THEN

      x_out.output_status.msg_data := INV_EBI_UTIL.get_error_table_msgtxt(x_out.output_status.error_table);
    END IF;

    IF (x_out.output_status.msg_data IS NOT NULL) THEN
      x_out.output_status.msg_data  :=  x_out.output_status.msg_data||' -> INV_EBI_CHANGE_ORDER_PUB.process_bom ';
    ELSE
      x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_CHANGE_ORDER_PUB.process_bom ';
    END IF;

  END process_bom;

/************************************************************************************
 --     API name        : process_change_order
 --     Type            : Public
 --     Function        :
 --     This API is used to
 --     Changed this API for Bug 8397083
 ************************************************************************************/

PROCEDURE process_change_order(
  p_commit     IN  VARCHAR2 := FND_API.g_false
 ,p_eco_obj    IN  inv_ebi_eco_obj
 ,x_out        OUT NOCOPY inv_ebi_eco_output_obj
 ) IS

  l_change_id                   NUMBER;
  l_change_notice               VARCHAR2(10);
  l_organization_id             NUMBER;
  l_organization_code           VARCHAR2(3);
  l_output_status               inv_ebi_output_status;
  l_curr_status_code            NUMBER;
  l_status_code                 NUMBER;
  l_is_wf_Set                   BOOLEAN;
  l_revitem_output_tbl          inv_ebi_revitem_output_obj_tbl;
  l_revision                    VARCHAR2(3);
  l_change_type_code            NUMBER;
  l_status_name                 VARCHAR2(30);
  l_out                         inv_ebi_eco_output_obj;
  l_item_output                 inv_ebi_item_output_obj;
  l_uda_output                  inv_ebi_uda_output_obj;
  l_pkdata                      ego_col_name_value_pair_array;
  l_pkcode                      ego_col_name_value_pair_array;
  l_change_order_type_id        NUMBER;
  l_inventory_item_id           NUMBER;
  l_api_version                 NUMBER:=1.0;
  l_is_task_template_set        BOOLEAN := FALSE;
  BEGIN
    SAVEPOINT inv_ebi_chg_order_save_pnt;
    FND_MSG_PUB.initialize;

    INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_CHANGE_ORDER_PUB.process_change_order');
    l_uda_output       :=     inv_ebi_uda_output_obj(NULL,NULL);
    l_output_status    :=     inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
    x_out              :=     inv_ebi_eco_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL);

    l_revitem_output_tbl     := inv_ebi_revitem_output_obj_tbl();

    bom_globals.set_bo_identifier(bom_globals.g_eco_bo);

    INV_EBI_UTIL.debug_line('STEP: 20 START CALLING INV_EBI_CHANGE_ORDER_HELPER.process_eco');
    INV_EBI_CHANGE_ORDER_HELPER.process_eco(
      p_commit                   =>  FND_API.g_false
     ,p_change_order             =>  p_eco_obj.eco_change_order_type
     ,p_revision_type_tbl        =>  p_eco_obj.eco_revision_type
     ,p_revised_item_type_tbl    =>  p_eco_obj.eco_revised_item_type
     ,p_name_val_list            =>  inv_ebi_name_value_list(p_eco_obj.name_value_tbl)
     ,x_out                      =>  l_out
    );
    INV_EBI_UTIL.debug_line('STEP: 30 END CALLING INV_EBI_CHANGE_ORDER_HELPER.process_eco');
    IF (l_out.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      x_out.output_status.msg_data := l_out.output_status.msg_data;
      RAISE FND_API.G_EXC_UNEXPECTED_ERROR;
    END IF;

    l_change_id           :=  l_out.change_id;
    l_change_notice       :=  l_out.change_notice;
    l_organization_id     :=  l_out.organization_id;
    l_organization_code   :=  l_out.organization_code;

    l_is_wf_Set := INV_EBI_CHANGE_ORDER_HELPER.Check_Workflow_Process(p_change_order_type_id  => p_eco_obj.eco_change_order_type.change_type_id
                                                                     ,p_priority_code         => p_eco_obj.eco_change_order_type.priority_code
                                                                      );
    SELECT status_code
    INTO l_curr_status_code
    FROM eng_engineering_changes
    WHERE change_id = l_change_id;

    l_status_name := p_eco_obj.eco_change_order_type.status_name;

    IF( p_eco_obj.eco_change_order_type.status_code IS NOT NULL AND
        p_eco_obj.eco_change_order_type.status_code <> fnd_api.g_miss_num) THEN

       l_status_name := INV_EBI_CHANGE_ORDER_HELPER.get_eco_status_name(p_eco_obj.eco_change_order_type.status_code);

    END IF;

    IF (LOWER(l_status_name) = 'implemented' ) THEN
      SELECT status_code
      INTO   l_status_code
      FROM   eng_change_statuses_vl
      WHERE  LOWER(status_name) = 'scheduled';                                                -- Scheduled
    ELSE
      l_status_code := p_eco_obj.eco_change_order_type.status_code;
    END IF;

   /*Bug 7218542:If some task is associated at organization level for the change order type
    we cannot promote it to scheduled status.*/

    l_is_task_template_set := INV_EBI_CHANGE_ORDER_HELPER.is_task_template_set(
                                 p_change_order_type_id  => p_eco_obj.eco_change_order_type.change_type_id
                                ,p_organization_id       => l_organization_id
                                ,p_status_code           => l_status_code
                              );

    IF ( (NOT l_is_wf_Set) AND
         (NOT l_is_task_template_set) AND
         (l_status_code > l_curr_status_code) ) THEN
     --Bug 6833363

     INV_EBI_UTIL.debug_line('STEP: 40 START CALLING ENG_CHANGE_LIFECYCLE_UTIL.Change_Phase');
      ENG_CHANGE_LIFECYCLE_UTIL.Change_Phase(
        p_api_version               => 1.0
       ,p_commit                    => FND_API.g_false
       ,p_object_name               => 'ENG_CHANGE'
       ,p_change_id                 => l_change_id
       ,p_status_code               => l_status_code
       ,p_action_type               => ENG_CHANGE_LIFECYCLE_UTIL.G_ENG_PROMOTE -- promote/demote
       ,x_return_status             => l_out.output_status.return_status
       ,x_msg_count                 => l_out.output_status.msg_count
       ,x_msg_data                  => l_out.output_status.msg_data
     );
     INV_EBI_UTIL.debug_line('STEP: 50 END CALLING ENG_CHANGE_LIFECYCLE_UTIL.Change_Phase');
      IF (l_out.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
        x_out.output_status.msg_data := l_out.output_status.msg_data;
        RAISE FND_API.g_exc_unexpected_error;
      END IF;
    END IF;

    --Processing of Udas
    IF (INV_EBI_UTIL.is_pim_installed) THEN
      IF ((p_eco_obj.eco_change_order_type IS NOT NULL AND p_eco_obj.eco_change_order_type.change_order_uda IS NOT NULL)
      AND p_eco_obj.eco_change_order_type.change_order_uda.attribute_group_tbl.COUNT > 0) THEN
        IF ((p_eco_obj.eco_change_order_type.eco_name IS NOT NULL)
        AND (p_eco_obj.eco_change_order_type.organization_id IS NULL OR p_eco_obj.eco_change_order_type.organization_id =FND_API.g_miss_num)
        AND (p_eco_obj.eco_change_order_type.organization_code IS NOT NULL OR p_eco_obj.eco_change_order_type.organization_code <> FND_API.g_miss_char)) THEN

          SELECT change_order_type_id INTO l_change_order_type_id
          FROM eng_engineering_changes
          WHERE change_notice = p_eco_obj.eco_change_order_type.eco_name
          AND organization_id = l_organization_id;

        END IF;
        l_pkdata := ego_col_name_value_pair_array();
        l_pkdata.extend();
        l_pkdata(1) := ego_col_name_value_pair_obj('CHANGE_ID',l_change_id);
        l_pkcode := ego_col_name_value_pair_array();
        l_pkcode.extend();
        l_pkcode(1) := ego_col_name_value_pair_obj('CHANGE_TYPE_ID',l_change_order_type_id);

        --To process Change order header udas
        INV_EBI_UTIL.debug_line('STEP: 60 START CALLING INV_EBI_CHANGE_ORDER_HELPER.process_uda');
        INV_EBI_CHANGE_ORDER_HELPER.process_uda(
          p_uda_input_obj                  =>  p_eco_obj.eco_change_order_type.change_order_uda
         ,p_commit                         =>  fnd_api.g_false
         ,p_object_name                    =>  'ENG_CHANGE'
         ,p_data_level                     =>  'CHANGE_LEVEL'
         ,p_pk_column_name_value_pairs     =>  l_pkdata
         ,p_class_code_name_value_pairs    =>  l_pkcode
         ,x_uda_output_obj                 =>  l_out
         );
         INV_EBI_UTIL.debug_line('STEP: 70 AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_uda');
       END IF;
       IF(l_out.output_status.return_status <> FND_API.G_RET_STS_SUCCESS) THEN
         x_out.output_status.msg_data := l_out.output_status.msg_data;
         RAISE  fnd_api.g_exc_unexpected_error;
       END IF;

       l_uda_output := inv_ebi_uda_output_obj(l_out.uda_output.failed_row_id_list,l_out.uda_output.errorcode);

       IF(p_eco_obj.eco_revised_item_type IS NOT NULL AND p_eco_obj.eco_revised_item_type.COUNT > 0) THEN
         FOR i IN 1..p_eco_obj.eco_revised_item_type.COUNT
         LOOP

           IF ( p_eco_obj.eco_revised_item_type(i).item.uda_type IS NOT  NULL AND
                p_eco_obj.eco_revised_item_type(i).item.uda_type.attribute_group_tbl.COUNT > 0) THEN

             -- To process Revised Item udas

             l_inventory_item_id := INV_EBI_ITEM_HELPER.get_inventory_item_id (
                                       p_organization_id => l_organization_id
                                      ,p_item_number     => p_eco_obj.eco_revised_item_type(i).revised_item_name
                                   );
             INV_EBI_UTIL.debug_line('STEP: 80 START CALLING INV_EBI_ITEM_HELPER.process_item_uda');
             INV_EBI_ITEM_HELPER.process_item_uda(
               p_api_version           =>  l_api_version
              ,p_inventory_item_id     =>  l_inventory_item_id
              ,p_organization_id       =>  l_organization_id
              ,p_item_catalog_group_id =>  p_eco_obj.eco_revised_item_type(i).item.main_obj_type.item_catalog_group_id
              ,p_revision_id           =>  NULL
              ,p_revision_code         =>  p_eco_obj.eco_revised_item_type(i).new_revised_item_revision
              ,p_uda_input_obj         =>  p_eco_obj.eco_revised_item_type(i).item.uda_type
              ,p_commit                =>  fnd_api.g_false
              ,x_uda_output_obj        =>  l_item_output
             );
             INV_EBI_UTIL.debug_line('STEP: 90 AFTER CALLING INV_EBI_ITEM_HELPER.process_item_uda');
           END IF;

           IF (l_item_output.output_status.return_status <> FND_API.g_ret_sts_success) THEN
             x_out.output_status.return_status := l_item_output.output_status.msg_data;
             RAISE FND_API.g_exc_unexpected_error;
           END IF;

           l_uda_output := inv_ebi_uda_output_obj(l_item_output.uda_output.failed_row_id_list,l_item_output.uda_output.errorcode);
           -- To process Component level udas and structure header level udas
           INV_EBI_UTIL.debug_line('STEP: 90 START CALLING INV_EBI_CHANGE_ORDER_HELPER.process_change_order_uda');
           INV_EBI_CHANGE_ORDER_HELPER.process_change_order_uda(
             p_commit             => FND_API.g_false
            ,p_organization_code  => p_eco_obj.eco_change_order_type.organization_code
            ,p_eco_name           => p_eco_obj.eco_change_order_type.eco_name
            ,p_alternate_bom_code => p_eco_obj.eco_revised_item_type(i).alternate_bom_code
            ,p_revised_item_name  => p_eco_obj.eco_revised_item_type(i).revised_item_name
            ,p_component_tbl      => p_eco_obj.eco_revised_item_type(i).component_item_tbl
            ,p_structure_header   => p_eco_obj.eco_revised_item_type(i).structure_header
            ,x_out                => l_out
           );
           INV_EBI_UTIL.debug_line('STEP: 100 AFTER CALLING INV_EBI_CHANGE_ORDER_HELPER.process_change_order_uda');
           IF (l_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
             x_out.output_status.return_status := l_out.output_status.msg_data;
             RAISE FND_API.g_exc_unexpected_error;
           END IF;
         END LOOP;
       END IF;
       l_uda_output := inv_ebi_uda_output_obj(l_out.uda_output.failed_row_id_list,l_out.uda_output.errorcode);
    END IF;
    --End of Udas processing
    INV_EBI_UTIL.debug_line('STEP: 110 END Processing UDAS');
   x_out := inv_ebi_eco_output_obj( l_change_notice,l_change_id,l_organization_id,l_organization_code,
                                    l_out.output_status,NULL,l_uda_output);

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;
  INV_EBI_UTIL.debug_line('STEP: 120 END INSIDE INV_EBI_CHANGE_ORDER_PUB.process_change_order');
  EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO inv_ebi_chg_order_save_pnt;

    x_out.output_status.return_status :=  FND_API.g_ret_sts_unexp_error;
    IF(x_out.output_status.msg_data IS NULL) THEN
      x_out.output_status.error_table   :=  INV_EBI_UTIL.get_error_table();

      IF (x_out.output_status.error_table IS NOT NULL AND x_out.output_status.error_table.COUNT > 0) THEN
        x_out.output_status.msg_data := INV_EBI_UTIL.get_error_table_msgtxt(x_out.output_status.error_table);

        IF(x_out.output_status.msg_data  IS NULL) THEN
          FND_MSG_PUB.count_and_get(
            p_encoded => FND_API.g_false
           ,p_count   => x_out.output_status.msg_count
           ,p_data    => x_out.output_status.msg_data
         );
        END IF;

      END IF;
    END IF;
  WHEN OTHERS THEN
    ROLLBACK TO inv_ebi_chg_order_save_pnt;

    x_out.output_status.error_table   := INV_EBI_UTIL.get_error_table();
    x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;

    IF (x_out.output_status.error_table IS NOT NULL AND x_out.output_status.error_table.COUNT > 0) THEN
      x_out.output_status.msg_data := INV_EBI_UTIL.get_error_table_msgtxt(x_out.output_status.error_table);
    END IF;
    IF (x_out.output_status.msg_data IS NOT NULL) THEN
      x_out.output_status.msg_data  :=  x_out.output_status.msg_data||' -> INV_EBI_CHANGE_ORDER_PUB.process_change_order ';
    ELSE
      x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_CHANGE_ORDER_PUB.process_change_order ';
    END IF;

  END process_change_order;

/************************************************************************************
 --     API name        : process_change_order_list_core
 --     Type            : Public
 --     Function        :
 --     This API is used to get list of change orders
 --     Changed this API for Bug 8397083
 ************************************************************************************/

PROCEDURE process_change_order_list_core(
  p_commit          IN          VARCHAR2 := fnd_api.g_false
 ,p_eco_obj_list    IN          inv_ebi_eco_obj_tbl
 ,x_out             OUT NOCOPY  inv_ebi_eco_output_obj_tbl
 ,x_return_status   OUT NOCOPY  VARCHAR2
 ,x_msg_count       OUT NOCOPY  NUMBER
 ,x_msg_data        OUT NOCOPY  VARCHAR2
)
IS
  l_inv_ebi_eco_obj             inv_ebi_eco_obj;
  l_eco_obj                     inv_ebi_eco_obj;
  l_inv_ebi_eco_output_obj      inv_ebi_eco_output_obj;
  l_part_err_msg                VARCHAR2(32000);
  l_eco_name                    VARCHAR2(10);
  l_org_code                    VARCHAR2(3);
  l_is_master_org               VARCHAR2(1);
  l_updated_item_tbl            inv_ebi_item_attr_tbl;
  l_upd_item_tbl                inv_ebi_item_attr_tbl;
  l_assign_item_to_child_org    VARCHAR2(1):= fnd_api.g_false;
  l_item_output_obj             inv_ebi_item_output_obj;
  l_eco_obj_list                inv_ebi_eco_obj_tbl;
  l_eco_obj_tbl                 inv_ebi_eco_obj_tbl;
  l_upd_eco_name_tbl            FND_TABLE_OF_VARCHAR2_30;
  l_upd_eco_idx_tbl             FND_TABLE_OF_NUMBER;
  l_index                       NUMBER ;
  l_revitem_output_tbl          inv_ebi_revitem_output_obj_tbl;
  l_output_status               inv_ebi_output_status;
  l_count                       NUMBER;
  l_upd_item_cnt                NUMBER := 0;
  l_upd_child_item_cnt          NUMBER := 0;
  l_item_name                   mtl_system_items_kfv.concatenated_segments%TYPE;
  l_organization_code           mtl_parameters.organization_code%TYPE;

BEGIN
   -- This Part of Code to set the APPS Context  BUG 8712091
  /*  IF p_eco_obj_list IS NOT NULL AND p_eco_obj_list.COUNT>0 THEN
      FOR i IN p_eco_obj_list.FIRST..p_eco_obj_list.LAST
      LOOP
        IF p_eco_obj_list(i).NAME_VALUE_TBL IS NOT NULL AND p_eco_obj_list(i).NAME_VALUE_TBL.COUNT>0
        THEN
          INV_EBI_UTIL.set_apps_context(p_eco_obj_list(i).NAME_VALUE_TBL);
        END IF;
        EXIT;
      END LOOP;
    END IF;
*/

  SAVEPOINT inv_ebi_prc_chg_ord_save_pnt;
  ERROR_HANDLER.Initialize;
  FND_MSG_PUB.initialize;
  INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_CHANGE_ORDER_PUB.process_change_order_list');
  INV_EBI_UTIL.debug_line( ' **************** Apps Context Details ****************' );
  INV_EBI_UTIL.debug_line(' User Id: ' || FND_GLOBAL.USER_ID || '; Responsibility Application id: ' ||
                           FND_GLOBAL.RESP_APPL_ID || '; Responsibility Id: ' || FND_GLOBAL.RESP_ID ||
                         '; Security Group id: '|| FND_GLOBAL.SECURITY_GROUP_ID ||'; User Lang: '|| USERENV('LANG') );
  INV_EBI_UTIL.debug_line( ' ****************  End of Apps Context ****************' );

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  x_out := inv_ebi_eco_output_obj_tbl();
  l_revitem_output_tbl     :=  inv_ebi_revitem_output_obj_tbl();
  l_eco_obj_tbl            :=  inv_ebi_eco_obj_tbl();
  l_eco_obj_tbl            :=  p_eco_obj_list;

  IF (l_eco_obj_tbl IS NOT NULL AND  l_eco_obj_tbl.count > 0) THEN

    x_out.extend(l_eco_obj_tbl.count);

    l_upd_eco_name_tbl  := FND_TABLE_OF_VARCHAR2_30();
    l_upd_item_tbl      := inv_ebi_item_attr_tbl();
    l_updated_item_tbl  := inv_ebi_item_attr_tbl(); -- Bug 8830143
    l_upd_eco_idx_tbl   := FND_TABLE_OF_NUMBER();


    FOR i in 1..l_eco_obj_tbl.count
    LOOP
      l_inv_ebi_eco_obj := l_eco_obj_tbl(i);
      l_eco_name :=  l_eco_obj_tbl(i).eco_change_order_type.eco_name;
      l_org_code :=  l_eco_obj_tbl(i).eco_change_order_type.organization_code;

      l_is_master_org := INV_EBI_UTIL.is_master_org(l_org_code);

      IF( l_is_master_org = fnd_api.g_true ) THEN

        INV_EBI_UTIL.debug_line('STEP: 20 START CALLING INV_EBI_CHANGE_ORDER_PUB.process_change_order_items for Master ORG'||
                                 ' Organization Code: '||l_eco_obj_tbl(i).eco_change_order_type.organization_code||
                                 ' ECO Name: '||l_eco_obj_tbl(i).eco_change_order_type.eco_name);


        --To Create Items in Master Org
        INV_EBI_CHANGE_ORDER_PUB.process_change_order_items(
           p_commit                => p_commit
          ,p_eco_obj               => l_inv_ebi_eco_obj
          ,p_update_item_tbl       => l_upd_item_tbl
          ,x_update_item_tbl       => l_updated_item_tbl
          ,x_out                   => l_item_output_obj
          ,x_eco_obj               => l_eco_obj
        );

        IF l_item_output_obj.output_status.return_status <> FND_API.G_RET_STS_SUCCESS THEN
           x_out(i) :=  inv_ebi_eco_output_obj( l_eco_name,NULL,NULL,l_org_code,l_item_output_obj.output_status,NULL,NULL);
           RAISE  FND_API.g_exc_unexpected_error;
        END IF;

        l_eco_obj_tbl(i) :=  l_eco_obj;

        IF(l_updated_item_tbl IS NOT NULL AND l_updated_item_tbl.COUNT> 0) THEN

          FOR l_count IN 1..l_updated_item_tbl.COUNT LOOP

            l_upd_item_cnt := l_upd_item_cnt + 1;

            l_upd_eco_name_tbl.EXTEND(1);
            l_upd_eco_name_tbl(l_upd_item_cnt) := l_eco_name;

            l_upd_eco_idx_tbl.EXTEND(1);
            l_upd_eco_idx_tbl(l_upd_item_cnt) := i;

          END LOOP;
        END IF;

        INV_EBI_UTIL.debug_line('STEP: 30 END CALLING INV_EBI_CHANGE_ORDER_PUB.process_change_order_items for Master ORG'||
                               ' Organization Code: '||l_eco_obj_tbl(i).eco_change_order_type.organization_code||
                               ' ECO Name: '||l_eco_obj_tbl(i).eco_change_order_type.eco_name);

      END IF;
    END LOOP;

    FOR i in 1..l_eco_obj_tbl.count
    LOOP

      l_inv_ebi_eco_obj := l_eco_obj_tbl(i);
      l_eco_name :=  l_eco_obj_tbl(i).eco_change_order_type.eco_name;
      l_org_code :=  l_eco_obj_tbl(i).eco_change_order_type.organization_code;
      l_is_master_org := INV_EBI_UTIL.is_master_org(l_org_code);

      IF( l_is_master_org = fnd_api.g_false ) THEN

        INV_EBI_UTIL.debug_line('STEP: 40 START CALLING INV_EBI_CHANGE_ORDER_PUB.process_change_order_items for Child ORG'||
                               ' Organization Code: '||l_eco_obj_tbl(i).eco_change_order_type.organization_code||
                               ' ECO Name: '||l_eco_obj_tbl(i).eco_change_order_type.eco_name);

        --To Create Items in Child Org

        l_upd_item_tbl := l_updated_item_tbl;

        INV_EBI_CHANGE_ORDER_PUB.process_change_order_items(
           p_commit                => p_commit
          ,p_eco_obj               => l_inv_ebi_eco_obj
          ,p_update_item_tbl       => l_upd_item_tbl
          ,x_update_item_tbl       => l_updated_item_tbl
          ,x_out                   => l_item_output_obj
          ,x_eco_obj               => l_eco_obj
        );


        IF l_item_output_obj.output_status.return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_out(i)   :=  inv_ebi_eco_output_obj( l_eco_name,NULL,NULL,l_org_code,l_item_output_obj.output_status,NULL,NULL);
          RAISE  FND_API.g_exc_unexpected_error;
        END IF;

        l_eco_obj_tbl(i) :=  l_eco_obj;

        IF(l_updated_item_tbl IS NOT NULL AND l_updated_item_tbl.COUNT> 0) THEN

          FOR l_count IN 1..l_updated_item_tbl.COUNT LOOP

            l_upd_item_cnt := l_upd_item_cnt + 1;

            l_upd_eco_name_tbl.EXTEND(1);
            l_upd_eco_name_tbl(l_upd_item_cnt) := l_eco_name;

            l_upd_eco_idx_tbl.EXTEND(1);
            l_upd_eco_idx_tbl(l_upd_item_cnt) := i;


          END LOOP;

        END IF;

        INV_EBI_UTIL.debug_line('STEP: 50 END CALLING INV_EBI_CHANGE_ORDER_PUB.process_change_order_items for Child ORG'||
                               ' Organization Code: '||l_eco_obj_tbl(i).eco_change_order_type.organization_code||
                               ' ECO Name: '||l_eco_obj_tbl(i).eco_change_order_type.eco_name);


      END IF;
    END LOOP;

    IF l_inv_ebi_eco_obj.name_value_tbl IS NOT NULL THEN
      FOR i in l_inv_ebi_eco_obj.name_value_tbl.FIRST..l_inv_ebi_eco_obj.name_value_tbl.LAST LOOP
        IF (UPPER(l_inv_ebi_eco_obj.name_value_tbl(i).param_name) = INV_EBI_CHANGE_ORDER_HELPER.G_ASSIGN_ITEM_TO_CHILD_ORG) THEN
          l_assign_item_to_child_org := l_inv_ebi_eco_obj.name_value_tbl(i).param_value;
          INV_EBI_CHANGE_ORDER_HELPER.set_assign_item(
             p_assign_item => l_assign_item_to_child_org
          );
        END IF;
      END LOOP;
    END IF;

   INV_EBI_UTIL.debug_line('STEP 60: BEFORE CALLING INV_EBI_CHANGE_ORDER_PUB.process_bom');
   process_bom(
     p_commit        => p_commit
    ,p_eco_obj_list  => l_eco_obj_tbl
    ,x_eco_obj_list  => l_eco_obj_list
    ,x_out           => l_inv_ebi_eco_output_obj
   );

   INV_EBI_UTIL.debug_line('STEP 70: AFTER CALLING INV_EBI_CHANGE_ORDER_PUB.process_bom status is ' || l_inv_ebi_eco_output_obj.output_status.return_status);
   IF (l_inv_ebi_eco_output_obj.output_status.return_status <> FND_API.g_ret_sts_success )THEN
     l_eco_name :=  l_inv_ebi_eco_output_obj.change_notice;
     l_org_code :=  l_inv_ebi_eco_output_obj.organization_code;
     FOR i IN 1..l_eco_obj_tbl.COUNT LOOP

       IF( l_eco_obj_tbl(i).eco_change_order_type.eco_name = l_eco_name AND
           l_eco_obj_tbl(i).eco_change_order_type.organization_code = l_org_code ) THEN
          x_out(i)  := l_inv_ebi_eco_output_obj;
       END IF;

     END LOOP;
     RAISE  FND_API.g_exc_unexpected_error;
   END IF;

   FOR i in 1..l_eco_obj_list.COUNT
   LOOP
     l_inv_ebi_eco_obj := l_eco_obj_list(i);
     l_eco_name :=  l_eco_obj_list(i).eco_change_order_type.eco_name;
     l_org_code :=  l_eco_obj_list(i).eco_change_order_type.organization_code;
     INV_EBI_UTIL.debug_line('STEP 80:  BEFORE CALLING INV_EBI_CHANGE_ORDER_PUB.process_change_order');

     process_change_order(
        p_commit   => p_commit
       ,p_eco_obj  => l_inv_ebi_eco_obj
       ,x_out      => l_inv_ebi_eco_output_obj
     );
     INV_EBI_UTIL.debug_line('STEP 90:  AFTER CALLING INV_EBI_CHANGE_ORDER_PUB.process_change_order '|| l_inv_ebi_eco_output_obj.output_status.return_status);
     x_out(i)  :=  l_inv_ebi_eco_output_obj;

     IF x_out(i).output_status.return_status <> FND_API.G_RET_STS_SUCCESS THEN

       RAISE  FND_API.g_exc_unexpected_error;

     END IF;
   END LOOP;
 END IF;

 --Item updation to be done after change Order creation

 -- update items
 INV_EBI_UTIL.debug_line('STEP 100:BEFORE CALLING INV_EBI_CHANGE_ORDER_PUB.process_update_items ');
 process_update_items(
    p_commit           => p_commit
   ,p_update_item_tbl  => l_updated_item_tbl
   ,x_out              => l_item_output_obj
  );

 INV_EBI_UTIL.debug_line('STEP 110:AFTER CALLING INV_EBI_CHANGE_ORDER_PUB.process_update_items ');
 IF (l_item_output_obj.output_status.return_status <> fnd_api.g_ret_sts_success) THEN
   l_item_name  := l_item_output_obj.item_number;
   l_org_code   := l_item_output_obj.organization_code;

   FOR i IN 1..l_updated_item_tbl.COUNT LOOP
     IF( l_updated_item_tbl(i).item_obj.main_obj_type.item_number = l_item_name
         AND l_updated_item_tbl(i).item_obj.main_obj_type.organization_code = l_org_code) THEN

       l_eco_name        :=  l_upd_eco_name_tbl(i);
       l_output_status   :=  l_item_output_obj.output_status;
       l_index           :=  l_upd_eco_idx_tbl(i);
       x_out(l_index)    :=  inv_ebi_eco_output_obj( l_eco_name,NULL,NULL,l_org_code,l_output_status,NULL,NULL);

      END IF;
    END LOOP;
   RAISE fnd_api.g_exc_unexpected_error;
 END IF;

  INV_EBI_UTIL.debug_line('STEP: 60 START CALLING populate_revised_items_out');

  FOR i in 1..l_eco_obj_list.COUNT LOOP

     l_inv_ebi_eco_obj := l_eco_obj_list(i);
     populate_revised_items_out(
        p_change_order             =>  l_inv_ebi_eco_obj.eco_change_order_type
       ,p_revised_item_type_tbl    =>  l_inv_ebi_eco_obj.eco_revised_item_type
       ,x_revised_item_type_tbl    =>  l_revitem_output_tbl
     );
     x_out(i).item_output_tbl  := l_revitem_output_tbl;
  END LOOP;

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;

 INV_EBI_UTIL.debug_line('STEP: 60 END INSIDE INV_EBI_CHANGE_ORDER_PUB.process_change_order_list');

 EXCEPTION
   WHEN FND_API.g_exc_unexpected_error THEN
     ROLLBACK TO inv_ebi_prc_chg_ord_save_pnt;
     x_return_status := FND_API.G_RET_STS_ERROR;
     IF  (x_out IS NOT NULL AND x_out.COUNT > 0) THEN
       FOR i in 1..x_out.COUNT
       LOOP
         x_msg_count     := x_out(i).output_status.msg_count;
         IF x_out(i).output_status.msg_data IS NOT NULL THEN
           x_msg_data      := x_msg_data ||'Org Code: '||l_org_code||' ECO Name: '||l_eco_name || ' Err Msg: ' || x_out(i).output_status.msg_data;
         END IF;
       END LOOP;
     END IF;

   WHEN OTHERS THEN
     ROLLBACK TO inv_ebi_prc_chg_ord_save_pnt;
     x_out.EXTEND();
     x_out(1).output_status.return_status := FND_API.g_ret_sts_unexp_error;
     IF (x_out(1).output_status.msg_data IS NOT NULL) THEN
       x_out(1).output_status.msg_data  :=  x_out(1).output_status.msg_data||' -> INV_EBI_CHANGE_ORDER_PUB.process_change_order_list';
     ELSE
       x_out(1).output_status.msg_data  :=  SQLERRM|| 'INV_EBI_CHANGE_ORDER_PUB.process_change_order_list';
     END IF;
     x_return_status := FND_API.G_RET_STS_ERROR;
     x_msg_count     := x_out(1).output_status.msg_count;

     IF  (x_out IS NOT NULL AND x_out.COUNT > 0) THEN
       FOR i in 1..x_out.COUNT
       LOOP
         IF x_out(i).output_status.msg_data IS NOT NULL THEN
           x_msg_data  := x_msg_data||' Org Code: '||l_org_code||' ECO Name: '||l_eco_name || ' Err Msg: ' || x_out(i).output_status.msg_data;
         END IF;
      END LOOP;
    END IF;
END process_change_order_list_core;


/************************************************************************************
 --     API name        : process_change_order_list
 --     Type            : Public
 --     Function        :
 --     This API is used to process list of change orders
 --
 ************************************************************************************/

PROCEDURE process_change_order_list(
  p_commit          IN          VARCHAR2 := fnd_api.g_false
 ,p_eco_obj_list    IN          inv_ebi_eco_obj_tbl
 ,x_out             OUT NOCOPY  inv_ebi_eco_output_obj_tbl
 ,x_return_status   OUT NOCOPY  VARCHAR2
 ,x_msg_count       OUT NOCOPY  NUMBER
 ,x_msg_data        OUT NOCOPY  VARCHAR2
)
IS
  BEGIN
    SAVEPOINT inv_ebi_prc_chg_lst_save_pnt;
    ERROR_HANDLER.Initialize;
    FND_MSG_PUB.initialize;
    INV_EBI_UTIL.setup();
    INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_CHANGE_ORDER_PUB.process_change_order_list');
    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    IF (p_eco_obj_list IS NOT NULL AND  p_eco_obj_list.count > 0) THEN

      process_change_order_list_core( p_commit        =>  fnd_api.g_false
                               ,p_eco_obj_list   =>  p_eco_obj_list
                               ,x_out            =>  x_out
                               ,x_return_status  =>  x_return_status
                               ,x_msg_count      =>  x_msg_count
                               ,x_msg_data       =>  x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE  FND_API.g_exc_unexpected_error;
      END IF;
    END IF;

    INV_EBI_UTIL.debug_line('STEP: 20 END INSIDE INV_EBI_CHANGE_ORDER_PUB.process_change_order_list');
    INV_EBI_UTIL.wrapup;

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO inv_ebi_prc_chg_lst_save_pnt;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
    ROLLBACK TO inv_ebi_prc_chg_lst_save_pnt;
    x_return_status := FND_API.G_RET_STS_ERROR;
     IF x_msg_data IS NULL THEN
       x_msg_data  :=  SQLERRM|| 'INV_EBI_CHANGE_ORDER_PUB.process_change_order_list';
     END IF;
END process_change_order_list;
/************************************************************************************
 --     API name        : validate_change_order_list
 --     Type            : Public
 --     This API is used to validate change order list
 --
 ************************************************************************************/
PROCEDURE validate_change_order_list(
  p_commit          IN          VARCHAR2 := fnd_api.g_false
 ,p_eco_obj_list    IN          inv_ebi_eco_obj_tbl
 ,x_out             OUT NOCOPY  inv_ebi_eco_output_obj_tbl
 ,x_return_status   OUT NOCOPY  VARCHAR2
 ,x_msg_count       OUT NOCOPY  NUMBER
 ,x_msg_data        OUT NOCOPY  VARCHAR2
)
IS
  BEGIN
    --SAVEPOINT inv_ebi_val_chg_lst_save_pnt;
    ERROR_HANDLER.Initialize;
    FND_MSG_PUB.initialize;
    INV_EBI_UTIL.setup();
    INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_CHANGE_ORDER_PUB.validate_change_order_list');
    x_return_status := FND_API.G_RET_STS_SUCCESS ;

    IF (p_eco_obj_list IS NOT NULL AND  p_eco_obj_list.count > 0) THEN

      process_change_order_list_core( p_commit        =>  fnd_api.g_false
                               ,p_eco_obj_list   =>  p_eco_obj_list
                               ,x_out            =>  x_out
                               ,x_return_status  =>  x_return_status
                               ,x_msg_count      =>  x_msg_count
                               ,x_msg_data       =>  x_msg_data);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE  FND_API.g_exc_unexpected_error;
      END IF;
    END IF;

   -- ROLLBACK TO inv_ebi_val_chg_lst_save_pnt;
      ROLLBACK;
    INV_EBI_UTIL.debug_line('STEP: 20 END INSIDE INV_EBI_CHANGE_ORDER_PUB.validate_change_order_list');
    INV_EBI_UTIL.wrapup;

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    --ROLLBACK TO inv_ebi_val_chg_lst_save_pnt;
    ROLLBACK;
    x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
  WHEN OTHERS THEN
   -- ROLLBACK TO inv_ebi_val_chg_lst_save_pnt;
   ROLLBACK;
    x_return_status := FND_API.G_RET_STS_ERROR;
    IF x_msg_data IS NULL THEN
      x_msg_data  :=  SQLERRM|| 'INV_EBI_CHANGE_ORDER_PUB.validate_change_order_list';
    END IF;
END validate_change_order_list;

END INV_EBI_CHANGE_ORDER_PUB;

/
