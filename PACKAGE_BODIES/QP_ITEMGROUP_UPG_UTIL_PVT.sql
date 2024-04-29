--------------------------------------------------------
--  DDL for Package Body QP_ITEMGROUP_UPG_UTIL_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_ITEMGROUP_UPG_UTIL_PVT" AS
/* $Header: QPXVUIGB.pls 120.0 2005/06/01 23:58:01 appldev noship $ */

err_msg   VARCHAR2(240);

PROCEDURE Upgrade_Item_Groups IS

l_control_level    NUMBER := 2;

l_new_structure_id    NUMBER := 0;

l_new_category_id  NUMBER := 0;
l_new_category_set_id NUMBER := 0;
l_enabled_flag     VARCHAR2(1) := 'Y';
l_organization_id  VARCHAR2(10);
l_description      VARCHAR2(50) := 'Category to Upgrade Item Groups';
l_user_id          NUMBER;

l_new_structure    FND_FLEX_KEY_API.structure_type;
l_new_segment      FND_FLEX_KEY_API.segment_type;
l_flexfield        FND_FLEX_KEY_API.flexfield_type;
l_structure        FND_FLEX_KEY_API.structure_type;

err_num         NUMBER := 0;
err_msg         VARCHAR2(240) := '';

CURSOR oe_item_groups_cur
IS
  SELECT *
  FROM   oe_item_groups;

CURSOR oe_item_group_lines_cur (p_group_id   NUMBER)
IS
  SELECT *
  FROM   oe_item_group_lines
  WHERE  group_id = p_group_id;

BEGIN

  FND_FLEX_KEY_API.set_session_mode('customer_data');

  --Find the Item Categories flexfield
  l_flexfield := FND_FLEX_KEY_API.find_flexfield(appl_short_name => 'INV',
						  flex_code => 'MCAT');


  -- Find the structure if it already exists.
  BEGIN
  l_structure := FND_FLEX_KEY_API.find_structure(flexfield => l_flexfield,
					    structure_code => 'PRICELIST_ITEM_CATEGORIES');
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
	 NULL;
  END;

  --If structure already exists, i.e. upgrade has been run before
  IF l_structure.structure_number IS NOT NULL THEN

     BEGIN

     --Get the structure_id corresponding to this structure
     SELECT id_flex_num
     INTO   l_new_structure_id
     FROM   fnd_id_flex_structures
     WHERE  id_flex_code = 'MCAT'
     AND    id_flex_structure_code = 'PRICELIST_ITEM_CATEGORIES';

     EXCEPTION
	  WHEN OTHERS THEN
	    err_msg := substr(sqlerrm, 1, 240);
         rollback;
         QP_UTIL.Log_Error(
         p_id1 => 'Structure Id '||to_char(l_new_structure_id),
         p_error_type => 'ITEM_GROUP',
         p_error_desc => err_msg,
         p_error_module => 'Upgrade_Item_Groups');
         raise;
	END;

  ELSE --If structure does not exist i.e.upgrade script not run before

    --Create new Structure for the Item Categories FlexField
    l_new_structure := FND_FLEX_KEY_API.new_structure(flexfield => l_flexfield,
						   structure_code => 'PRICELIST_ITEM_CATEGORIES',
						   structure_title => 'PriceList Item Categories',
						   description =>'Item Categories for PriceLists',
						   view_name => '',
						   freeze_flag => 'Y',
						   enabled_flag => 'Y',
						   segment_separator => '.',
						   cross_val_flag => 'N',
						   freeze_rollup_flag => 'N',
						   dynamic_insert_flag => 'N',
						   shorthand_enabled_flag => 'N',
						   shorthand_prompt => '',
						   shorthand_length => 0
						   );

    --Add the newly created structure to the Item Categories flexfield
    FND_FLEX_KEY_API.add_structure(flexfield => l_flexfield,
						   structure => l_new_structure);

    --Create a new dummy segment for the new structure
    l_new_segment := FND_FLEX_KEY_API.new_segment(flexfield => l_flexfield,
						   structure => l_new_structure,
						   segment_name => 'Dummy',
						   description => 'Dummy',
						   column_name => 'SEGMENT1',
						   segment_number => 1,
						   enabled_flag => 'Y',
						   displayed_flag => 'Y',
						   indexed_flag => 'Y',
						   value_set => '',
						   default_type => '',
						   default_value => '',
						   required_flag => 'N',
						   security_flag => 'N',
						   range_code => '',
						   display_size => 10,
						   description_size => 30,
						   concat_size => 30,
						   lov_prompt => 'Dummy',
						   window_prompt => 'Dummy');

    --Add the newly created dummy segment to the new structure
    FND_FLEX_KEY_API.add_segment(flexfield => l_flexfield,
						   structure => l_new_structure,
						   segment => l_new_segment);

    --Fetch Structure id of newly created Structure;
    BEGIN

    SELECT id_flex_num
    INTO   l_new_structure_id
    FROM   fnd_id_flex_structures
    WHERE  id_flex_code = 'MCAT'
    AND    id_flex_structure_code = 'PRICELIST_ITEM_CATEGORIES';

    EXCEPTION
      WHEN OTHERS THEN
	   err_msg := substr(sqlerrm, 1, 240);
        rollback;
        QP_UTIL.Log_Error(
        p_id1 => 'Structure Id '||to_char(l_new_structure_id),
        p_error_type => 'ITEM_GROUP',
        p_error_desc => err_msg,
        p_error_module => 'Upgrade_Item_Groups');
        raise;
    END;

  END IF; --structure doesn't exist, upgrade not run before

  --Get the organization_id
  l_organization_id := QP_UTIL.Get_Item_Validation_Org;

  --Get the User_id
  l_user_id := FND_GLOBAL.USER_ID;

  SELECT mtl_categories_s.nextval
  INTO   l_new_category_id
  FROM   dual;

  BEGIN
    INSERT INTO mtl_categories_b
    (
     category_id,
     structure_id,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
--   description,
     summary_flag,
     enabled_flag,
     segment1
    )
    SELECT
     l_new_category_id,
     l_new_structure_id,
     sysdate,
     l_user_id,
     sysdate,
     l_user_id,
--   l_description,
     'N',
     l_enabled_flag, -- whether segment combination is enabled
     'Item Category for Item Groups'
    FROM  dual
    WHERE NOT EXISTS (SELECT 'X'
				  FROM   mtl_categories_b b
				  WHERE  b.structure_id = l_new_structure_id
				  AND    b.segment1 = 'Item Category for Item Groups');

    INSERT INTO mtl_categories_tl
    (
     category_id,
     language,
     source_lang,
     description,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by
    )
    SELECT
     l_new_category_id,
     l.LANGUAGE_CODE,
     userenv('LANG'),
     l_description,
     sysdate,
     l_user_id,
     sysdate,
     l_user_id
    FROM FND_LANGUAGES l
    WHERE l.INSTALLED_FLAG in ('I', 'B')
    AND NOT EXISTS (SELECT 'X'
			     FROM mtl_categories_tl t
			     WHERE t.category_id = l_new_category_id
			     AND t.language = l.LANGUAGE_CODE)
    AND EXISTS (SELECT 'X'
			 FROM   mtl_categories_b b
			 WHERE  b.category_id = l_new_category_id);

  EXCEPTION
      WHEN OTHERS THEN
	   err_msg := substr(sqlerrm, 1, 240);
        rollback;
        QP_UTIL.Log_Error(
        p_id1 => 'Category Id '||to_char(l_new_category_id),
        p_id2 => 'Structure Id '||to_char(l_new_structure_id),
        p_error_type => 'ITEM_GROUP',
        p_error_desc => err_msg,
        p_error_module => 'Upgrade_Item_Groups');
        raise;
  END;

  commit;

  FOR l_oe_item_groups_rec IN oe_item_groups_cur
  LOOP

    SELECT mtl_category_sets_s.nextval
    INTO   l_new_category_set_id
    FROM   dual;

    BEGIN
    INSERT INTO mtl_category_sets_b
    (
     category_set_id,
--     category_set_name,
     structure_id,
     validate_flag,
     control_level,
--     description,
     last_update_date,
     last_updated_by,
     creation_date,
     created_by,
	mult_item_cat_assign_flag
    )
    SELECT
	l_new_category_set_id,
--     upper(l_oe_item_groups_rec.name) || '_CATEGORY_SET',
     l_new_structure_id,
     'N',
     l_control_level, --Control level is item_level
--     l_oe_item_groups_rec.description,
     l_oe_item_groups_rec.last_update_date,
     l_oe_item_groups_rec.last_updated_by,
     l_oe_item_groups_rec.creation_date,
     l_oe_item_groups_rec.created_by,
	'Y'
    FROM  dual
    WHERE NOT EXISTS (SELECT 'X'
				  FROM   mtl_category_sets_b b, mtl_category_sets_tl t
				  WHERE  b.category_set_id = t.category_set_id
				  AND    b.structure_id = l_new_structure_id
				  AND    t.category_set_name =
				  substr(upper(l_oe_item_groups_rec.name),1,15) || '_CATEGORY_SET');

    INSERT INTO mtl_category_sets_tl
    (
	category_set_id,
	language,
	source_lang,
	category_set_name,
	description,
	last_update_date,
	last_updated_by,
	creation_date,
	created_by
    )
    SELECT
	l_new_category_set_id,
	l.LANGUAGE_CODE,
	userenv('LANG'),
     substr(upper(l_oe_item_groups_rec.name),1,15) || '_CATEGORY_SET',
     substr(l_oe_item_groups_rec.description,1, 240),
     l_oe_item_groups_rec.last_update_date,
     l_oe_item_groups_rec.last_updated_by,
     l_oe_item_groups_rec.creation_date,
     l_oe_item_groups_rec.created_by
    FROM  FND_LANGUAGES l
    WHERE l.INSTALLED_FLAG IN ('I', 'B')
    AND NOT EXISTS (SELECT 'X'
				FROM   mtl_category_sets_tl t
				WHERE  t.category_set_id = l_new_category_set_id
				AND    t.language = l.LANGUAGE_CODE)
    AND EXISTS (SELECT 'X'
			 FROM   mtl_category_sets_b b
                WHERE  b.category_set_id = l_new_category_set_id);

    EXCEPTION
      WHEN OTHERS THEN
	   err_msg := substr(sqlerrm, 1, 240);
        rollback;
        QP_UTIL.Log_Error(
        p_id1 => 'Category Set Id '||to_char(l_new_category_set_id),
        p_id2 => 'Structure Id '||to_char(l_new_structure_id),
        p_error_type => 'ITEM_GROUP',
        p_error_desc => err_msg,
        p_error_module => 'Upgrade_Item_Groups');
	   raise;
    END;

    FOR l_oe_item_group_lines_rec IN oe_item_group_lines_cur
									  (l_oe_item_groups_rec.group_id)
    LOOP

    BEGIN
      INSERT INTO mtl_item_categories
      (
       inventory_item_id,
	  organization_id,
	  category_set_id,
	  category_id,
	  last_update_date,
	  last_updated_by,
	  creation_date,
	  created_by
      )
      SELECT
	  l_oe_item_group_lines_rec.inventory_item_id,
	  TO_NUMBER(l_organization_id),
	  l_new_category_set_id,
	  l_new_category_id,
	  l_oe_item_group_lines_rec.last_update_date,
	  l_oe_item_group_lines_rec.last_updated_by,
	  l_oe_item_group_lines_rec.creation_date,
	  l_oe_item_group_lines_rec.created_by
	 FROM  dual
	 WHERE EXISTS (SELECT 'X'
				FROM   mtl_categories_b b
				WHERE  b.category_id = l_new_category_id)
	 AND EXISTS (SELECT 'X'
			   FROM   mtl_category_sets_b s
			   WHERE  s.category_set_id = l_new_category_set_id);

    EXCEPTION
	 WHEN DUP_VAL_ON_INDEX OR NO_DATA_FOUND OR VALUE_ERROR THEN
	    err_msg := substr(sqlerrm, 1, 240);
         rollback;
         QP_UTIL.Log_Error(
         p_id1 => 'Group Id '||to_char(l_oe_item_group_lines_rec.group_id),
         p_id2 => 'Inventory Item Id '||to_char(l_oe_item_group_lines_rec.inventory_item_id),
         p_error_type => 'ITEM_GROUP',
         p_error_desc => err_msg,
         p_error_module => 'Upgrade_Item_Groups');

      WHEN OTHERS THEN
	    err_msg := substr(sqlerrm, 1, 240);
         rollback;
         QP_UTIL.Log_Error(
         p_id1 => 'Category Set Id '||to_char(l_new_category_set_id),
         p_id2 => 'Category Id '||to_char(l_new_category_id),
         p_error_type => 'ITEM_GROUP',
         p_error_desc => err_msg,
         p_error_module => 'Upgrade_Item_Groups');
	    raise;
    END;

    commit;

    END LOOP; /* Loop over records in oe_item_group_lines */

    commit;

  END LOOP; /* Loop over records in oe_item_groups */

EXCEPTION
  WHEN OTHERS THEN
			err_msg := substr(sqlerrm, 1, 240);
               IF err_msg IS NULL THEN
			   err_msg := substr(FND_FLEX_KEY_API.message, 1, 240);
			END IF;
			QP_UTIL.Log_Error(
               p_id1 => 'Category Set Id '||to_char(l_new_category_set_id),
               p_id2 => 'Category Id '||to_char(l_new_category_id),
               p_error_type => 'ITEM_GROUP',
               p_error_desc => err_msg,
               p_error_module => 'Upgrade_Item_Groups');
			raise;

END Upgrade_Item_Groups;
END QP_ITEMGROUP_UPG_UTIL_PVT;

/
