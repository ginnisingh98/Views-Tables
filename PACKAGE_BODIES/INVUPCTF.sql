--------------------------------------------------------
--  DDL for Package Body INVUPCTF
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."INVUPCTF" as
/* $Header: INVUPCTB.pls 115.3 1999/11/24 00:04:32 pkm ship    $*/

PROCEDURE  UPDATE_CATALOG_STATUS_FLAG(
current_catalog_id          IN    NUMBER,
current_element_name        IN    VARCHAR2
)
IS

 el_value     VARCHAR2(30);

 CURSOR  get_iii_cursor IS
 select msi.inventory_item_id  III
 from   mtl_system_items_B  msi
 where  msi.item_catalog_group_id = current_catalog_id
   and  msi.catalog_status_flag <> 'N';

BEGIN

  FOR get_iii_cursor_row in get_iii_cursor LOOP

     el_value := NULL;

     SELECT ELEMENT_VALUE INTO el_value
       FROM MTL_DESCR_ELEMENT_VALUES MDEV
      WHERE MDEV.INVENTORY_ITEM_ID = get_iii_cursor_row.III
        AND MDEV.ELEMENT_NAME = current_element_name;

     IF el_value IS NULL THEN
         UPDATE MTL_SYSTEM_ITEMS_B  MSI
            SET MSI.CATALOG_STATUS_FLAG = 'N'
          WHERE MSI.INVENTORY_ITEM_ID = get_iii_cursor_row.III
            AND MSI.ITEM_CATALOG_GROUP_ID = current_catalog_id;
    END IF;

  END LOOP;

END  UPDATE_CATALOG_STATUS_FLAG;


PROCEDURE  UPDATE_CATSTAT_FLAG_NEW_DE(
current_catalog_id     IN    NUMBER)
IS
BEGIN
       UPDATE MTL_SYSTEM_ITEMS_B  MSI
          SET MSI.CATALOG_STATUS_FLAG = 'N'
         WHERE MSI.ITEM_CATALOG_GROUP_ID = current_catalog_id
           AND MSI.CATALOG_STATUS_FLAG <> 'N';

END UPDATE_CATSTAT_FLAG_NEW_DE;


FUNCTION Check_Reqd_Desc_Elems
(
   current_catalog_id	IN   NUMBER
,  current_inv_item_id	IN   NUMBER
)
RETURN  BOOLEAN
IS
  t_count   NUMBER;
BEGIN

  SELECT  count(*) INTO t_count
  FROM  DUAL
  WHERE  EXISTS
         ( SELECT null
           FROM  MTL_DESCRIPTIVE_ELEMENTS  E
               , MTL_DESCR_ELEMENT_VALUES  V
           WHERE  E.REQUIRED_ELEMENT_FLAG = 'Y'
             AND  E.ITEM_CATALOG_GROUP_ID = current_catalog_id
             AND  V.INVENTORY_ITEM_ID = current_inv_item_id
             AND  V.ELEMENT_NAME = E.ELEMENT_NAME
             AND  V.ELEMENT_VALUE IS NULL
         );

  RETURN (t_count = 0);

END Check_Reqd_Desc_Elems;


END INVUPCTF;

/
