--------------------------------------------------------
--  DDL for Package Body INV_EBI_ITEM_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INV_EBI_ITEM_PUB" AS
/* $Header: INVEIPITB.pls 120.24.12010000.13 2009/07/23 09:19:03 prcheru ship $ */

/************************************************************************************
--      API name        : validate_item
--      Type            : Public
--      Function        :
--
************************************************************************************/
PROCEDURE validate_item (
    p_transaction_type  IN         VARCHAR2
   ,p_item              IN         inv_ebi_item_obj
   ,x_out               OUT NOCOPY inv_ebi_item_output_obj
) IS

  l_output_status               inv_ebi_output_status;

BEGIN
  l_output_status := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
  x_out           := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);
  FND_MSG_PUB.initialize;

  IF(p_transaction_type = INV_EBI_ITEM_PUB.g_otype_create) THEN
    IF(p_item.main_obj_type.organization_id IS NULL OR p_item.main_obj_type.organization_id = fnd_api.g_miss_num) THEN

      x_out.organization_id := INV_EBI_ITEM_HELPER.get_default_master_org(
                                             p_config  => p_item.name_value_tbl
                                           );

      IF x_out.organization_id IS NULL  THEN
        FND_MESSAGE.set_name('INV','INV_EBI_NO_DEFAULT_ORG');
        FND_MSG_PUB.add;
        RAISE FND_API.g_exc_error;

      END IF;

    END IF;
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
      x_out.output_status.msg_data  :=  x_out.output_status.msg_data||' -> INV_EBI_ITEM_PUB.validate_item ';
    ELSE
      x_out.output_status.msg_data  :=  SQLERRM||' INV_EBI_ITEM_PUB.validate_item ';
    END IF;
END validate_item;

/************************************************************************************
--      API name        : process_item
--      Type            : Public
--      Function        :
--
************************************************************************************/
PROCEDURE process_item(
  p_commit        IN  VARCHAR2
 ,p_operation     IN  VARCHAR2
 ,p_item          IN  inv_ebi_item_obj
 ,x_out           OUT NOCOPY inv_ebi_item_output_obj
)
IS
  l_item            inv_ebi_item_obj;
  l_output_status   inv_ebi_output_status;
  l_api_version     NUMBER:=1.0;
  l_out             inv_ebi_item_output_obj;
BEGIN
  -- This Part of the Code to set the Apps Context BUG 8712091
 /* IF p_item.name_value_tbl IS NOT NULL AND p_item.name_value_tbl.COUNT>0
  THEN
    INV_EBI_UTIL.set_apps_context(p_item.name_value_tbl);
  END IF;
  */
  SAVEPOINT inv_ebi_process_item_save_pnt;
  ERROR_HANDLER.initialize;
  FND_MSG_PUB.initialize;

  l_output_status  := inv_ebi_output_status(fnd_api.g_ret_sts_success,NULL,NULL,NULL);
  x_out            := inv_ebi_item_output_obj(NULL,NULL,NULL,NULL,l_output_status,NULL,NULL,NULL,NULL,NULL,NULL);
  INV_EBI_UTIL.SETUP();  --- one time for each process.

  INV_EBI_UTIL.debug_line('STEP: 10 '||'START INSIDE  INV_EBI_ITEM_PUB.process_item '||
                          'ORGANIZATION CODE: '||p_item.main_obj_type.organization_code||
                          'Item Number: '||p_item.main_obj_type.item_number
                          );
  INV_EBI_UTIL.debug_line( ' **************** Apps Context Details ****************' );
  INV_EBI_UTIL.debug_line(' User Id: ' || FND_GLOBAL.USER_ID || '; Responsibility Application id: ' ||
                           FND_GLOBAL.RESP_APPL_ID || '; Responsibility Id: ' || FND_GLOBAL.RESP_ID ||
                         '; Security Group id: '|| FND_GLOBAL.SECURITY_GROUP_ID ||'; User Lang: '|| USERENV('LANG') );
  INV_EBI_UTIL.debug_line( ' ****************  End of Apps Context ****************' );

  INV_EBI_UTIL.debug_line('STEP: 20 '||'START CALLING INV_EBI_ITEM_HELPER.populate_item_ids ');
  INV_EBI_ITEM_HELPER.populate_item_ids(
     p_item  =>  p_item
    ,x_out   =>  x_out
    ,x_item  =>  l_item
  );
  INV_EBI_UTIL.debug_line('STEP: 30 '||'END CALLING INV_EBI_ITEM_HELPER.populate_item_ids ');

  IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
    RAISE  FND_API.g_exc_unexpected_error;
  END IF;

 INV_EBI_UTIL.debug_line('STEP: 40 '||'START CALLING validate_item ');
  validate_item (
     p_transaction_type  =>  p_operation
    ,p_item              =>  l_item
    ,x_out               =>  x_out
  );
 INV_EBI_UTIL.debug_line('STEP: 50 '||'END CALLING validate_item ');

  IF (x_out.output_status.return_status <> FND_API.g_ret_sts_success) THEN
     RAISE  FND_API.g_exc_unexpected_error;
  END IF;

  IF(l_item.main_obj_type.organization_id IS NULL OR l_item.main_obj_type.organization_id = FND_API.g_miss_num) THEN
    l_item.main_obj_type.organization_id := x_out.organization_id;
  END IF;

  IF (l_item.main_obj_type.effectivity_date IS NULL  OR
    l_item.main_obj_type.effectivity_date = fnd_api.g_miss_date OR
    l_item.main_obj_type.effectivity_date <= sysdate ) THEN
    l_item.main_obj_type.effectivity_date := sysdate+(2/(60*60*24));
  END IF;

  --To create Production item
  INV_EBI_UTIL.debug_line('STEP: 60 '||'START CALLING INV_EBI_ITEM_HELPER.sync_item ');

  INV_EBI_ITEM_HELPER.sync_item (
     p_commit     => FND_API.g_false
    ,p_operation  => p_operation
    ,p_item       => l_item
    ,x_out        => l_out
  );

  INV_EBI_UTIL.debug_line('STEP: 70 '||'END CALLING INV_EBI_ITEM_HELPER.sync_item ');
  IF (l_out.output_status.return_status <> fnd_api.g_ret_sts_success) THEN
    x_out.output_status.msg_data := l_out.output_status.msg_data;
    RAISE  fnd_api.g_exc_unexpected_error;
  END IF;

  x_out.inventory_item_id    :=  l_out.inventory_item_id;
  x_out.organization_id      :=  l_out.organization_id;
  x_out.organization_code    :=  l_out.organization_code;
  x_out.item_number          :=  l_out.item_number;
  x_out.category_output      :=  l_out.category_output;
  x_out.operating_unit       :=  l_out.operating_unit;
  x_out.operating_unit_id    :=  l_out.operating_unit_id;
  x_out.description          :=  l_out.description;

  -- To process Udas
  IF (INV_EBI_UTIL.is_pim_installed AND l_item.main_obj_type.item_catalog_group_id IS NOT NULL ) THEN
    IF (l_item.uda_type IS NOT  NULL AND l_item.uda_type.attribute_group_tbl.COUNT > 0) THEN
      INV_EBI_ITEM_HELPER.process_item_uda(
        p_api_version           =>  l_api_version
       ,p_inventory_item_id     =>  x_out.inventory_item_id
       ,p_organization_id       =>  x_out.organization_id
       ,p_item_catalog_group_id =>  l_item.main_obj_type.item_catalog_group_id
       ,p_revision_id           =>  l_item.main_obj_type.revision_id
       ,p_revision_code         =>  l_item.main_obj_type.revision_code
       ,p_uda_input_obj         =>  l_item.uda_type
       ,p_commit                =>  fnd_api.g_false
       ,x_uda_output_obj        =>  l_out
     );
    END IF;
  END IF;

  IF (l_out.output_status.return_status <> fnd_api.g_ret_sts_success) THEN
    RAISE  FND_API.g_exc_unexpected_error;
  END IF;

  x_out.uda_output  :=  l_out.uda_output;

  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;
  INV_EBI_UTIL.debug_line('STEP: 80 '||'END INSIDE INV_EBI_ITEM_HELPER.process_item '||
                          'ORGANIZATION CODE: '||p_item.main_obj_type.organization_code||
                          'Item Number: '||p_item.main_obj_type.item_number
                          );
  INV_EBI_UTIL.wrapup;
  EXCEPTION
    WHEN FND_API.g_exc_error THEN
      ROLLBACK TO inv_ebi_process_item_save_pnt;
      x_out.output_status.return_status :=  FND_API.g_ret_sts_error;
      IF(x_out.output_status.msg_data IS NULL) THEN
        FND_MSG_PUB.count_and_get(
          p_encoded => FND_API.g_false
         ,p_count   => x_out.output_status.msg_count
         ,p_data    => x_out.output_status.msg_data
       );
    END IF;
    WHEN FND_API.g_exc_unexpected_error THEN
      ROLLBACK TO inv_ebi_process_item_save_pnt;
      x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
      x_out.output_status.error_table  := INV_EBI_UTIL.get_error_table();
      IF (x_out.output_status.error_table IS NOT NULL AND x_out.output_status.error_table.COUNT > 0) THEN
        x_out.output_status.msg_data := INV_EBI_UTIL.get_error_table_msgtxt(x_out.output_status.error_table);
      IF(x_out.output_status.msg_data IS NULL) THEN
            FND_MSG_PUB.count_and_get(
              p_encoded => FND_API.g_false
             ,p_count   => x_out.output_status.msg_count
             ,p_data    => x_out.output_status.msg_data
           );
    END IF;
      END IF;
   WHEN OTHERS THEN
      ROLLBACK TO inv_ebi_process_item_save_pnt;
      x_out.output_status.return_status := FND_API.g_ret_sts_unexp_error;
      IF (x_out.output_status.msg_data IS NOT NULL) THEN
        x_out.output_status.msg_data  :=  x_out.output_status.msg_data ||' -> INV_EBI_ITEM_PUB.process_item ';
      ELSE
        x_out.output_status.msg_data :=  SQLERRM ||' INV_EBI_ITEM_PUB.process_item ';
      END IF;
END process_item;

/************************************************************************************
--      API name        : get_item_balance
--      Type            : Public
--      Function        :
************************************************************************************/
PROCEDURE get_item_balance(
  p_items                       IN              inv_ebi_item_list
 ,x_item_balance_output         OUT NOCOPY      inv_ebi_item_bal_output_list
 ,x_return_status               OUT NOCOPY      VARCHAR2
 ,x_msg_count                   OUT NOCOPY      NUMBER
 ,x_msg_data                    OUT NOCOPY      VARCHAR2
)
IS
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(1000);
  l_items                       inv_ebi_item_list;
  l_item_balance_input          inv_ebi_item_bal_input_list;
  l_item_bal_input_tbl          inv_ebi_item_bal_input_tbl;
  l_item_bal_input_obj          inv_ebi_item_bal_input_obj;
  l_api_version                 NUMBER:=1.0;

BEGIN
  l_item_bal_input_tbl := inv_ebi_item_bal_input_tbl();

  l_items := p_items;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INV_EBI_UTIL.setup();

  INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_ITEM_PUB.get_item_balance');
  INV_EBI_UTIL.debug_line( ' **************** Apps Context Details ****************' );
  INV_EBI_UTIL.debug_line(' User Id: ' || FND_GLOBAL.USER_ID || '; Responsibility Application id: ' ||
                           FND_GLOBAL.RESP_APPL_ID || '; Responsibility Id: ' || FND_GLOBAL.RESP_ID ||
                         '; Security Group id: '|| FND_GLOBAL.SECURITY_GROUP_ID ||'; User Lang: '|| USERENV('LANG') );
  INV_EBI_UTIL.debug_line( ' ****************  End of Apps Context ****************' );

IF (l_items.item_table.COUNT > 0) THEN
  FOR i IN l_items.item_table.FIRST..l_items.item_table.LAST LOOP
    l_item_bal_input_tbl.extend();
    l_item_bal_input_obj := inv_ebi_item_bal_input_obj(
                              l_api_version
                             ,fnd_api.g_true
                             ,l_items.item_table(i).organization_id
                             ,l_items.item_table(i).inventory_item_id
                             ,inv_quantity_tree_pub.g_transaction_mode
                             ,NULL
                             ,NULL
                             ,NULL
                             ,NULL
                             ,-9999
                             ,-9999
                             ,-9999
                             ,NULL
                             ,NULL
                             ,NULL
                             ,NULL
                             ,NULL
                             ,NULL
                             ,inv_quantity_tree_pvt.g_all_subs
                             ,NULL
                             ,NULL
                             ,NULL
                             ,NULL
                             ,fnd_api.g_true
                            );
    l_item_bal_input_tbl(i) := l_item_bal_input_obj;
  END LOOP;

  l_item_balance_input := inv_ebi_item_bal_input_list(l_item_bal_input_tbl);


    INV_EBI_UTIL.debug_line('STEP: 20 START CALLING INV_EBI_ITEM_HELPER.get_item_balance');

  INV_EBI_ITEM_HELPER.get_item_balance(
    p_item_balance_input        => l_item_balance_input
   ,x_item_balance_output       => x_item_balance_output
   ,x_return_status             => x_return_status
   ,x_msg_count                 => x_msg_count
   ,x_msg_data                  => x_msg_data
  );

    INV_EBI_UTIL.debug_line('STEP: 30 END CALLING INV_EBI_ITEM_HELPER.get_item_balance');


  IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
    RAISE  FND_API.g_exc_unexpected_error;
  END IF;
END IF;

  INV_EBI_UTIL.debug_line('STEP: 40 END INSIDE INV_EBI_ITEM_PUB.get_item_balance');
  INV_EBI_UTIL.wrapup;

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_error;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data
      );
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at INV_EBI_ITEM_PUB.get_item_balance';
END get_item_balance;
/************************************************************************************
--      API name        : Convert_date_str
--      Type            : Public
--      Function        :
************************************************************************************/

PROCEDURE Convert_date_str(p_item_tbl_obj IN         inv_ebi_item_attr_tbl_obj
                          ,x_item_tbl_obj OUT NOCOPY inv_ebi_item_attr_tbl_obj)
IS
BEGIN

  IF p_item_tbl_obj IS NOT NULL THEN
    x_item_tbl_obj := p_item_tbl_obj;
  END IF;

  IF p_item_tbl_obj.ITEM_ATTR_TBL IS NOT NULL AND p_item_tbl_obj.ITEM_ATTR_TBL.COUNT>0 THEN
    FOR i IN p_item_tbl_obj.ITEM_ATTR_TBL.FIRST..p_item_tbl_obj.ITEM_ATTR_TBL.LAST LOOP
      ------------------------------------------------------------------
      -- To Convert Date Fields in main_obj_type (INV_EBI_ITEM_MAIN_OBJ)
      ------------------------------------------------------------------
      x_item_tbl_obj.item_attr_tbl(i).item_obj.main_obj_type.start_date_active_str :=
      INV_EBI_ITEM_HELPER.convert_date_str(p_item_tbl_obj.item_attr_tbl(i).item_obj.main_obj_type.start_date_active);
      x_item_tbl_obj.item_attr_tbl(i).item_obj.main_obj_type.end_date_active_str :=
      INV_EBI_ITEM_HELPER.convert_date_str(p_item_tbl_obj.item_attr_tbl(i).item_obj.main_obj_type.end_date_active);
      x_item_tbl_obj.item_attr_tbl(i).item_obj.main_obj_type.creation_date_str:=
      INV_EBI_ITEM_HELPER.convert_date_str(p_item_tbl_obj.item_attr_tbl(i).item_obj.main_obj_type.creation_date);
      x_item_tbl_obj.item_attr_tbl(i).item_obj.main_obj_type.last_update_date_str :=
      INV_EBI_ITEM_HELPER.convert_date_str(p_item_tbl_obj.item_attr_tbl(i).item_obj.main_obj_type.last_update_date_str);
      x_item_tbl_obj.item_attr_tbl(i).item_obj.main_obj_type.program_update_date_str:=
      INV_EBI_ITEM_HELPER.convert_date_str(p_item_tbl_obj.item_attr_tbl(i).item_obj.main_obj_type.program_update_date);

      --------------------------------------------------------------------------------
      -- To Convert Date Fields in deprecated_obj_type (INV_EBI_ITEM_DEPRECATED_OBJ)
      --------------------------------------------------------------------------------
      IF(p_item_tbl_obj.item_attr_tbl(i).item_obj.deprecated_obj_type IS NOT NULL) THEN
        x_item_tbl_obj.item_attr_tbl(i).item_obj.deprecated_obj_type.engineering_date_str :=
        INV_EBI_ITEM_HELPER.convert_date_str(p_item_tbl_obj.item_attr_tbl(i).item_obj.deprecated_obj_type.engineering_date);
        x_item_tbl_obj.item_attr_tbl(i).item_obj.deprecated_obj_type.wh_update_date :=
        INV_EBI_ITEM_HELPER.convert_date_str(p_item_tbl_obj.item_attr_tbl(i).item_obj.deprecated_obj_type.wh_update_date);
      END IF;

      --------------------------------------------------------------------------------
      -- To Convert Date Fields in attribute_group_tbl(INV_EBI_UDA_ATTR_GRP_TBL)
      --------------------------------------------------------------------------------

      IF(p_item_tbl_obj.item_attr_tbl(i).item_obj.uda_type.attribute_group_tbl IS NOT NULL AND
         p_item_tbl_obj.item_attr_tbl(i).item_obj.uda_type.attribute_group_tbl.COUNT>0) THEN
        FOR j IN p_item_tbl_obj.item_attr_tbl(i).item_obj.uda_type.attribute_group_tbl.FIRST..
          p_item_tbl_obj.item_attr_tbl(i).item_obj.uda_type.attribute_group_tbl.LAST LOOP
          IF(p_item_tbl_obj.item_attr_tbl(i).item_obj.uda_type.attribute_group_tbl(j).attributes_tbl IS NOT NULL
            AND p_item_tbl_obj.item_attr_tbl(i).item_obj.uda_type.attribute_group_tbl(j).attributes_tbl.COUNT>0) THEN
            FOR k IN p_item_tbl_obj.item_attr_tbl(i).item_obj.uda_type.attribute_group_tbl(j).attributes_tbl.FIRST..
              p_item_tbl_obj.item_attr_tbl(i).item_obj.uda_type.attribute_group_tbl(j).attributes_tbl.LAST LOOP
              x_item_tbl_obj.item_attr_tbl(i).item_obj.uda_type.attribute_group_tbl(j).attributes_tbl(k).attr_value_date_str :=
              INV_EBI_ITEM_HELPER.convert_date_str(p_item_tbl_obj.item_attr_tbl(i).item_obj.uda_type.attribute_group_tbl(j).attributes_tbl(k).attr_value_date);
            END LOOP;
          END IF;
        END LOOP;
      END IF;
   END LOOP;
  END IF;
  EXCEPTION
    WHEN OTHERS THEN
      x_item_tbl_obj := p_item_tbl_obj;
END Convert_date_str;


/************************************************************************************
--      API name        : get_item_attributes
--      Type            : Public
--      Function        :
************************************************************************************/

PROCEDURE get_item_attributes(
  p_items                       IN              inv_ebi_item_list
 ,p_name_val_list               IN              inv_ebi_name_value_list
 ,x_item_tbl_obj                OUT NOCOPY      inv_ebi_item_attr_tbl_obj
 ,x_return_status               OUT NOCOPY      VARCHAR2
 ,x_msg_count                   OUT NOCOPY      NUMBER
 ,x_msg_data                    OUT NOCOPY      VARCHAR2
)
IS
  l_return_status               VARCHAR2(1);
  l_msg_count                   NUMBER;
  l_msg_data                    VARCHAR2(1000);
  l_items                       inv_ebi_item_list;
  l_get_item_inp_obj            inv_ebi_get_item_input;
  l_get_opr_attrs_tbl           inv_ebi_get_opr_attrs_tbl;
  l_get_opr_atts                inv_ebi_get_operational_attrs;
  l_inv_ebi_item_attr_tbl_obj   inv_ebi_item_attr_tbl_obj;
BEGIN

    -- This Part of Code to set the APPS Context --BUG 8712091
/*  IF p_name_val_list.name_value_table IS NOT NULL AND p_name_val_list.name_value_table.COUNT>0
  THEN
    INV_EBI_UTIL.set_apps_context(p_name_val_list.name_value_table);
  END IF;
  */
  l_get_opr_attrs_tbl := inv_ebi_get_opr_attrs_tbl();
  l_items := p_items;
  x_return_status := FND_API.G_RET_STS_SUCCESS;

  INV_EBI_ITEM_HELPER.set_server_time_zone;

  INV_EBI_UTIL.setup();

  INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_ITEM_PUB.get_item_attributes');

  INV_EBI_UTIL.debug_line( ' **************** Apps Context Details ****************' );
  INV_EBI_UTIL.debug_line(' User Id: ' || FND_GLOBAL.USER_ID || '; Responsibility Application id: ' ||
                           FND_GLOBAL.RESP_APPL_ID || '; Responsibility Id: ' || FND_GLOBAL.RESP_ID ||
                         '; Security Group id: '|| FND_GLOBAL.SECURITY_GROUP_ID ||'; User Lang: '|| USERENV('LANG') );
  INV_EBI_UTIL.debug_line( ' ****************  End of Apps Context ****************' );

  IF (l_items.item_table.COUNT > 0) THEN
    FOR i IN l_items.item_table.FIRST..l_items.item_table.LAST LOOP
      l_get_opr_attrs_tbl.extend();
      l_get_opr_atts := inv_ebi_get_operational_attrs(
                          l_items.item_table(i).inventory_item_id
                         ,NULL
                         ,l_items.item_table(i).organization_id
                         ,NULL
                         ,NULL
                         ,NULL
                          );

      l_get_opr_attrs_tbl(i) := l_get_opr_atts;
    END LOOP;

    l_get_item_inp_obj := inv_ebi_get_item_input(l_get_opr_attrs_tbl,p_name_val_list.name_value_table);



    INV_EBI_UTIL.debug_line('STEP: 20 START CALLING INV_EBI_ITEM_HELPER.get_item_attributes');

    INV_EBI_ITEM_HELPER.get_item_attributes(
      p_get_item_inp_obj          => l_get_item_inp_obj
     ,x_item_tbl_obj              => x_item_tbl_obj
     ,x_return_status             => x_return_status
     ,x_msg_count                 => x_msg_count
     ,x_msg_data                  => x_msg_data
    );

    INV_EBI_UTIL.debug_line('STEP: 30 END CALLING INV_EBI_ITEM_HELPER.get_item_attributes');

    IF (x_return_status <> FND_API.G_RET_STS_SUCCESS) THEN
      RAISE  FND_API.g_exc_unexpected_error;
    END IF;
  END IF;

  IF(x_item_tbl_obj.item_attr_tbl IS NOT NULL AND x_item_tbl_obj.item_attr_tbl.COUNT>0) THEN
    l_inv_ebi_item_attr_tbl_obj := inv_ebi_item_attr_tbl_obj(x_item_tbl_obj.item_attr_tbl);
  END IF;

 -- Bug# 8201401
 -- Call to wrapper API for converting all date fields to String
 IF l_inv_ebi_item_attr_tbl_obj IS NOT NULL THEN
   Convert_date_str(p_item_tbl_obj => l_inv_ebi_item_attr_tbl_obj
                   ,x_item_tbl_obj => x_item_tbl_obj);
 END IF;

 INV_EBI_UTIL.debug_line('STEP: 40 END INSIDE INV_EBI_ITEM_PUB.get_item_attributes');
 INV_EBI_UTIL.wrapup;

EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    x_return_status := FND_API.g_ret_sts_error;
    IF (x_msg_data IS NULL) THEN
      FND_MSG_PUB.count_and_get(
         p_encoded => FND_API.g_false
        ,p_count => x_msg_count
        ,p_data => x_msg_data);
    END IF;
  WHEN OTHERS THEN
    x_return_status := FND_API.g_ret_sts_unexp_error;
    x_msg_data := SQLERRM ||' at INV_EBI_ITEM_PUB.get_item_attributes';
END get_item_attributes;

/************************************************************************************
 --     API name        : process_item_list
 --     Type            : Public
 --     Function        :
 --     This API is used to process list of items
 --
 ************************************************************************************/
PROCEDURE process_item_list(
  p_commit        IN  VARCHAR2
 ,p_operation     IN  VARCHAR2
 ,p_item          IN  inv_ebi_item_obj_tbl
 ,x_out           OUT NOCOPY inv_ebi_item_output_obj_tbl
 ,x_return_status               OUT NOCOPY      VARCHAR2
 ,x_msg_count                   OUT NOCOPY      NUMBER
 ,x_msg_data                    OUT NOCOPY      VARCHAR2
)
IS
  l_inv_ebi_item_obj            inv_ebi_item_obj;
  l_inv_ebi_item_output_obj     inv_ebi_item_output_obj;

  l_part_err_msg           VARCHAR2(32000);
  l_org_code               VARCHAR2(3);
  l_is_master_org          VARCHAR2(1);
  l_item_number            VARCHAR2(2000);
BEGIN
  SAVEPOINT inv_ebi_prc_itm_list_save_pnt;
  ERROR_HANDLER.Initialize;
  FND_MSG_PUB.initialize;
  INV_EBI_UTIL.setup();

  INV_EBI_UTIL.debug_line('STEP: 10 START INSIDE INV_EBI_ITEM_PUB.process_item_list');

  INV_EBI_UTIL.debug_line( ' **************** Apps Context Details ****************' );
  INV_EBI_UTIL.debug_line(' User Id: ' || FND_GLOBAL.USER_ID || '; Responsibility Application id: ' ||
                          FND_GLOBAL.RESP_APPL_ID || '; Responsibility Id: ' || FND_GLOBAL.RESP_ID ||
                         '; Security Group id: '|| FND_GLOBAL.SECURITY_GROUP_ID ||'; User Lang: '|| USERENV('LANG') );
  INV_EBI_UTIL.debug_line( ' ****************  End of Apps Context ****************' );

  x_return_status := FND_API.G_RET_STS_SUCCESS ;
  x_out := inv_ebi_item_output_obj_tbl();
  IF (p_item IS NOT NULL AND  p_item.count > 0) THEN
    x_out.extend(p_item.count);
    FOR i in 1..p_item.count
    LOOP
      l_inv_ebi_item_obj := p_item(i);
       IF l_inv_ebi_item_obj.main_obj_type.organization_id IS NOT NULL THEN
         l_is_master_org := INV_EBI_UTIL.is_master_org(l_inv_ebi_item_obj.main_obj_type.organization_id);
       ELSE
         l_is_master_org := INV_EBI_UTIL.is_master_org(l_inv_ebi_item_obj.main_obj_type.organization_code);
       END IF;
        l_item_number := l_inv_ebi_item_obj.main_obj_type.item_number;
      IF(l_is_master_org = fnd_api.g_true ) THEN
        INV_EBI_UTIL.debug_line('STEP: 20 START CALLING INV_EBI_ITEM_PUB.process_item for ');
        INV_EBI_ITEM_PUB.process_item(
                            p_commit        =>  p_commit
                            ,p_operation    =>  p_operation
                            ,p_item         =>  l_inv_ebi_item_obj
                            ,x_out          =>  l_inv_ebi_item_output_obj
                                                );
        INV_EBI_UTIL.debug_line('STEP: 30 END CALLING INV_EBI_ITEM_PUB.process_item for ');

        x_out(i) := l_inv_ebi_item_output_obj;
        x_out(i).integration_id := l_inv_ebi_item_obj.integration_id;
        IF x_out(i).output_status.return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count     := x_out(i).output_status.msg_count;
          x_msg_data      := x_msg_data ||'Item Name :' || l_item_number || ' Err Msg: ' || x_out(i).output_status.msg_data;
          RAISE  FND_API.g_exc_unexpected_error;
        END IF;
      END IF;
    END LOOP;
  END IF;

  IF (p_item IS NOT NULL AND  p_item.count > 0) THEN
    FOR i in 1..p_item.count
    LOOP
      l_inv_ebi_item_obj := p_item(i);
       IF l_inv_ebi_item_obj.main_obj_type.organization_id IS NOT NULL THEN
         l_is_master_org := INV_EBI_UTIL.is_master_org(l_inv_ebi_item_obj.main_obj_type.organization_id);
       ELSE
        l_is_master_org := INV_EBI_UTIL.is_master_org(l_inv_ebi_item_obj.main_obj_type.organization_code);
       END IF;
      l_item_number := l_inv_ebi_item_obj.main_obj_type.item_number;
      IF(l_is_master_org = fnd_api.g_false ) THEN
        INV_EBI_UTIL.debug_line('STEP: 20 START CALLING INV_EBI_ITEM_PUB.process_item for ');
        INV_EBI_ITEM_PUB.process_item(
                            p_commit        =>  p_commit
                            ,p_operation    =>  p_operation
                            ,p_item         =>  l_inv_ebi_item_obj
                            ,x_out          =>  l_inv_ebi_item_output_obj
                         );
        INV_EBI_UTIL.debug_line('STEP: 30 END CALLING INV_EBI_ITEM_PUB.process_item for ');

        x_out(i) := l_inv_ebi_item_output_obj;
        x_out(i).integration_id := l_inv_ebi_item_obj.integration_id;
       IF x_out(i).output_status.return_status <> FND_API.G_RET_STS_SUCCESS THEN
          x_return_status := FND_API.G_RET_STS_ERROR;
          x_msg_count     := x_out(i).output_status.msg_count;
          x_msg_data      := x_msg_data ||'Item Name :' || l_item_number || ' Err Msg: ' || x_out(i).output_status.msg_data;
          RAISE  FND_API.g_exc_unexpected_error;
       END IF;
      END IF;
    END LOOP;
  END IF;
  IF FND_API.to_boolean(p_commit) THEN
    COMMIT;
  END IF;
INV_EBI_UTIL.debug_line('STEP: 40 END INSIDE INV_EBI_ITEM_PUB.process_item_list');
INV_EBI_UTIL.wrapup;
EXCEPTION
  WHEN FND_API.g_exc_unexpected_error THEN
    ROLLBACK TO inv_ebi_prc_itm_list_save_pnt;
  WHEN OTHERS THEN
    ROLLBACK TO inv_ebi_prc_itm_list_save_pnt;
    x_return_status := FND_API.G_RET_STS_ERROR;
    x_msg_data  :=  SQLERRM|| 'INV_EBI_ITEM_PUB.process_item_list';
END process_item_list;
END INV_EBI_ITEM_PUB;

/
