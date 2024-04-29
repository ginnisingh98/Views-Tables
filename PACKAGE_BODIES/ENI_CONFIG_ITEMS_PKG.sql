--------------------------------------------------------
--  DDL for Package Body ENI_CONFIG_ITEMS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_CONFIG_ITEMS_PKG" AS
/* $Header: ENICTOIB.pls 115.3 2004/05/26 09:10:43 pthambu noship $  */

G_PKG_NAME CONSTANT VARCHAR2(30) := 'ENI_CONFIG_ITEMS_PKG';

PROCEDURE Create_config_items( p_api_version NUMBER,
                               p_init_msg_list VARCHAR2 := 'F',
                               p_star_record CTO_ENI_WRAPPER.star_rec_type,
                               x_return_status OUT NOCOPY VARCHAR2,
                               x_msg_count OUT NOCOPY NUMBER,
                               x_msg_data OUT NOCOPY VARCHAR2)

IS

  l_inv_category_set number := null;
  l_vbh_category_set number := null;
  l_inventory_item_id NUMBER;

  cursor c_catg_set is
   Select category_set_id, functional_area_id
     from mtl_default_category_sets
    where functional_area_id in(1,11);

BEGIN

   l_inventory_item_id := p_star_record.inventory_item_id;

   FOR i in c_catg_set LOOP

       IF i.functional_area_id = 1 THEN
          l_inv_category_set := i.category_set_id;
       END IF;

       IF i.functional_area_id = 11 THEN
          l_vbh_category_set := i.category_set_id;
       END IF;

   END LOOP;

   INSERT INTO eni_oltp_item_star(
           id,
           value,
           inventory_item_id,
           organization_id,
           inv_category_id,
           inv_category_set_id,
           inv_concat_seg,
           vbh_category_id,
           vbh_category_set_id,
           vbh_concat_seg,
           master_id,
           creation_date,
           last_update_date,
           item_catalog_group_id,
	   primary_uom_code
         )
    SELECT
        mti.inventory_item_id || '-' || mti.organization_id id,
        mti.concatenated_segments || ' (' || mtp.organization_code || ')' value,
        mti.inventory_item_id inventory_item_id,
        mti.organization_id organization_id,
        nvl(mic.category_id,-1) inv_category_id,
        nvl(mic.category_Set_id,l_inv_category_set) inv_category_Set_id,
        nvl(kfv.concatenated_segments,'Unassigned') inv_concat_seg,
        nvl(mic1.category_id, -1) vbh_category_id,
        nvl(mic1.category_set_id, l_vbh_category_set) vbh_category_set_id,
        nvl(kfv1.concatenated_segments, 'Unassigned') vbh_concat_seg,
        decode(mti.organization_id,mtp.master_organization_id,null,mti.inventory_item_id || '-' || mtp.master_organization_id)
	master_id,
        mti.creation_date creation_date,
        mti.last_update_date last_update_date,
        nvl(mti.item_catalog_group_id,-1) item_catalog_group_id,
        mti.primary_uom_code
   FROM mtl_system_items_b_kfv mti,
        mtl_parameters mtp,
        mtl_item_categories mic ,
        mtl_item_categories mic1 ,
        mtl_categories_b_kfv kfv ,
        mtl_categories_b_kfv kfv1
  WHERE mtp.organization_id=mti.organization_id
    AND mti.inventory_item_id = l_inventory_item_id
    AND mic.organization_id(+) = mti.organization_id
    AND mic.inventory_item_id(+) = mti.inventory_item_id
    AND mic.category_id  = kfv.category_id (+)
        and mic.category_set_id(+) = l_inv_category_set
        AND mic1.organization_id(+) = mti.organization_id
        AND mic1.inventory_item_id(+) = mti.inventory_item_id
        AND mic1.category_id  = kfv1.category_id (+)
        AND mic1.category_set_id(+) = l_vbh_category_set
    AND NOT EXISTS(SELECT null FROM eni_oltp_item_star
                    WHERE inventory_item_id = l_inventory_item_id
                      AND organization_id = mti.organization_id);

    X_RETURN_STATUS := 'S';

EXCEPTION
  WHEN OTHERS THEN
     X_RETURN_STATUS := 'U';
     IF FND_MSG_PUB.CHECK_MSG_LEVEL(FND_MSG_PUB.G_MSG_LVL_UNEXP_ERROR) THEN
        FND_MSG_PUB.ADD_EXC_MSG(g_pkg_name, 'CREATE_CONFIG_ITEMS', SQLERRM);
     END IF;
     FND_MSG_PUB.COUNT_AND_GET(P_COUNT => X_MSG_COUNT, P_DATA => X_MSG_DATA);

END Create_config_items;


End ENI_CONFIG_ITEMS_PKG;

/
