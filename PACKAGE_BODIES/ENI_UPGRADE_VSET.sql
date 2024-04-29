--------------------------------------------------------
--  DDL for Package Body ENI_UPGRADE_VSET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_UPGRADE_VSET" AS
/* $Header: ENIVSTUB.pls 120.0 2005/05/26 19:34:16 appldev noship $  */

g_catset_id     NUMBER;
g_struct_id     NUMBER;
g_value_set_id  NUMBER;
g_default_cat_id NUMBER;

FUNCTION ENI_VALIDATE_SETUP return NUMBER IS

  l_cnt          NUMBER;
  l_report_error NUMBER;
  l_catg         VARCHAR2(40);

  -- this cursor selects all records with more than one parent
  -- in the value set hierarchy
  CURSOR C_DUP IS
    SELECT CHILD_CODE, COUNT(PARENT_CODE) COUNT
    FROM ENI_VSET_HRCHY_TEMP
    WHERE HRCHY_FLAG = 'Y'
    GROUP BY CHILD_CODE
    HAVING COUNT(PARENT_CODE) > 1;

  -- Cursor that selects all parent categories having item assignments

  CURSOR c_parent_item_assgn(g_struct_id NUMBER, g_catset_id NUMBER) IS
    SELECT B.SEGMENT1, COUNT(INVENTORY_ITEM_ID) NUMBER_ITEMS
    FROM MTL_ITEM_CATEGORIES A, MTL_CATEGORIES_B B, ENI_VSET_HRCHY_TEMP C
    WHERE A.CATEGORY_SET_ID = g_catset_id
      AND A.CATEGORY_ID = b.category_id
      AND B.STRUCTURE_ID = g_struct_id
      AND B.SEGMENT1 = C.PARENT_CODE
      AND C.HRCHY_FLAG = 'Y'
    GROUP BY B.SEGMENT1;

 -- Cursor that selects all nodes in the value set whose corresponding
 -- categories do not exist

  CURSOR c_new_nodes(g_struct_id NUMBER) IS
    SELECT CHILD_CODE FROM ENI_VSET_HRCHY_TEMP
    WHERE HRCHY_FLAG = 'Y'
    MINUS
    SELECT SEGMENT1 FROM MTL_CATEGORIES_B
    WHERE STRUCTURE_ID = g_struct_id;

BEGIN

  -- Check for multiple parent

  FND_FILE.PUT_LINE(FND_FILE.LOG, '');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Checking if any nodes have multiple parents');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '----------------------------------------- ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR : CATEGORIES WITH MULTIPLE PARENTS');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '----------------------------------------- ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Code');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------');

  l_cnt := 0;

  FOR i IN C_DUP LOOP
    FND_FILE.PUT_LINE(FND_FILE.LOG, i.child_code);
    l_cnt := 1;
  END LOOP;
  IF l_cnt = 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,' --- None --- ');
  ELSE
    l_report_error := 1;
  END IF;

  -- Check for item assignments

  l_cnt := 0;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Checking for any parent nodes having item assignments');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------ ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR : PARENT CATEGORIES WITH ITEM ASSIGNMENTS');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------ ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Code ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------- ');

  FOR i in c_parent_item_assgn(g_struct_id, g_catset_id) LOOP
    FND_FILE.PUT_LINE(FND_FILE.LOG, i.segment1);
    l_cnt := 1;
  END LOOP;
  IF l_cnt = 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,' --- None --- ');
  ELSE
    l_report_error := 1;
  END IF;

  -- Report any categories which is a parent node in the value set
  -- hierarchy but is also a default category of the default category
  -- set. This will not be allowed:

  FND_FILE.PUT_LINE(FND_FILE.LOG, '');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Checking if default category lies outside the hierarchy');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------ ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR : DEFAULT CATEGORY IS NOT UNDER THE TOP NODE');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'IN THE VALUE SET, IT WILL BE PLACED AS AS INDEPENDENT');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'TOP LEVEL CATEGORY');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------ ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Code ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------- ');

  BEGIN
    SELECT A.segment1 INTO l_catg
    FROM mtl_categories_B A,
         mtl_category_sets_b B    -- ,ENI_VSET_HRCHY_TEMP C
    WHERE A.category_id = B.default_category_id
      AND A.structure_id = B.structure_id
      AND B.CATEGORY_SET_ID = g_catset_id
      AND NOT EXISTS (SELECT child_code FROM eni_vset_hrchy_temp
                       WHERE child_code = a.segment1
                         AND hrchy_flag = 'Y');

    FND_FILE.PUT_LINE(FND_FILE.LOG, l_catg);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' --- None --- ');
  END;


  FND_FILE.PUT_LINE(FND_FILE.LOG, '');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Checking if any parent node is specified as default category');

  FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------ ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR : DEFAULT CATEGORY CANNOT BE CONVERTED TO A PARENT ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------ ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Code ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------- ');

  BEGIN
    SELECT a.segment1 INTO l_catg
    FROM mtl_categories_b a,
         mtl_category_sets_b b, eni_vset_hrchy_temp c
    WHERE a.category_id = b.default_category_id
      AND a.structure_id = b.structure_id
      AND b.category_set_id = g_catset_id
      AND a.segment1 = c.parent_code
      AND c.hrchy_flag = 'Y'
      AND ROWNUM = 1;

    FND_FILE.PUT_LINE(FND_FILE.LOG, l_catg);

  EXCEPTION
    WHEN NO_DATA_FOUND THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' --- None --- ');
  END;

  -- Report any categories that is new in the value set and should be
  -- created
  l_cnt := 0;
  FND_FILE.PUT_LINE(FND_FILE.LOG, '');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Checking for new nodes in the value set hierarchy');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------------------------------ ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: NEW NODES IN THE VALUE SET THAT DO NOT HAVE CORRESPONDING CATEGORIES');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------------------------------ ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Flex Values');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------- ');

  FOR i in c_new_nodes(g_struct_id) LOOP
    FND_FILE.PUT_LINE(FND_FILE.LOG, i.child_code);
    l_cnt := 1;
  END LOOP;

  IF l_cnt = 0 THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,' --- None --- ');
  ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Please run concurrent program: Create item categories from value set to create categories for the new nodes');
    l_report_error := 1;
  END IF;

  RETURN l_report_error;
END ENI_VALIDATE_SETUP;


PROCEDURE UPDATE_CATSET_FROM_VSET (
    errbuf            OUT NOCOPY VARCHAR2,
    retcode           OUT NOCOPY VARCHAR2,
    p_top_node        IN VARCHAR2,
    p_validation_mode IN VARCHAR2) IS

  l_cnt           NUMBER;
  l_error         BOOLEAN;
  l_insert        NUMBER;
  l_update        NUMBER;
  l_catg          NUMBER;
  l_catg_id       NUMBER;

  l_return_status  VARCHAR2(2000);
  l_errorcode      NUMBER;
  l_msg_count      NUMBER;
  l_msg_data       VARCHAR2(15000);
  l_msg_index_out  VARCHAR2(10000);
  l_data           VARCHAR2(10000);
  l_schema         VARCHAR2(10);

  -- Cursor that indicates all categories those are to be deleted
  -- from valid cats. These categories do not fall below the top node
  -- and do not have item assignments

  CURSOR c_out_hrchy(g_struct_id NUMBER, g_catset_id NUMBER) IS
  SELECT segment1, a.category_id, b.category_set_id
  FROM mtl_categories_b a, mtl_category_set_valid_cats b, mtl_category_sets_b c
  WHERE a.structure_id = g_struct_id
    AND b.category_set_id = g_catset_id
    AND a.category_id = b.category_id
    AND a.structure_id = c.structure_id
    AND b.category_set_id = c.category_set_id
    AND a.category_id <> c.default_category_id
    AND a.category_id NOT IN (SELECT category_id
                              FROM mtl_item_categories
                              WHERE category_id = a.category_id
                                AND category_set_id = b.category_set_id
                                AND ROWNUM = 1)
    AND NOT EXISTS(SELECT child_code FROM eni_vset_hrchy_temp
                   WHERE a.segment1 = child_code
                     AND hrchy_flag = 'Y'
                     AND child_code <> p_top_node);

  -- Cursor that indicates the categories that do not fall under the
  -- top node but has item assignments. These categories will
  -- remain as stray categories under the product catalog

  CURSOR c_stray_catg(g_struct_id NUMBER, g_catset_id NUMBER) IS
  SELECT segment1, a.category_id --, b.category_set_id
    FROM mtl_categories_b a
   WHERE structure_id = g_struct_id
     AND EXISTS (SELECT 'X' FROM mtl_item_categories b
                  WHERE a.category_id = b.category_id
                   AND b.category_set_id = g_catset_id)
     AND NOT EXISTS(SELECT child_code FROM eni_vset_hrchy_temp
                    WHERE A.segment1 = child_code
                      AND hrchy_flag = 'Y')
     AND p_validation_mode = 'Y';

  -- This Cursor will only run when validation mode = 'N'. This
  -- will update all nodes that have item assignments to a standalone
  -- node i.e. where parent_id is null. The last part of union all
  -- will select default_category if it doesnt have any item assignment
  -- Bug 3779274


  CURSOR c_item_assign(g_struct_id NUMBER, g_catset_id NUMBER) IS
   SELECT a.category_id, a.segment1, flag
     FROM (
           SELECT a.category_id, segment1, 1 flag -- create in valid cats
             FROM mtl_categories_b a
            WHERE a.structure_id = g_struct_id
              AND NOT EXISTS(
                    SELECT child_code FROM eni_vset_hrchy_temp
                    WHERE hrchy_flag = 'Y'
                      AND child_code = a.segment1)
                          AND NOT EXISTS(
                              SELECT category_id FROM mtl_category_set_valid_cats
                              WHERE a.category_id = category_id
                                AND category_set_id = g_catset_id)
            UNION ALL
            SELECT a.category_id, b.segment1, 2 flag  -- update in valid cats
              FROM mtl_category_set_valid_cats a, mtl_categories_b b
             WHERE a.category_set_id = g_catset_id
               AND a.category_id = b.category_id
               AND b.structure_id = g_struct_id
               -- AND NOT EXISTS(
               --    SELECT child_code FROM eni_vset_hrchy_temp
               --     WHERE hrchy_flag = 'Y'
               --       AND child_code = b.segment1)
            ) a
            WHERE EXISTS(
                SELECT category_id FROM mtl_item_categories b
                 WHERE a.category_id = b.category_id
                   AND b.category_set_id = g_catset_id)
     UNION ALL
         SELECT category_id, segment1,2 flag
         FROM
         	mtl_categories_b
         WHERE
		category_id = g_default_cat_id
	 	AND NOT EXISTS (
			    SELECT b.category_id
			    FROM
		                mtl_item_categories b
		        WHERE b.category_id = g_default_cat_id
		        AND ROWNUM = 1
		 );

  -- SELECT SEGMENT1, A.CATEGORY_ID, B.CATEGORY_SET_ID
  --   FROM MTL_CATEGORIES_B A, MTL_CATEGORY_SET_VALID_CATS B
  --  WHERE STRUCTURE_ID = g_struct_id
  --    AND B.CATEGORY_SET_ID = g_catset_id
  --    AND A.CATEGORY_ID = B.CATEGORY_ID
   --   AND A.CATEGORY_ID IN (SELECT CATEGORY_ID
   --                         FROM MTL_ITEM_CATEGORIES
   --                         WHERE CATEGORY_ID = A.CATEGORY_ID
   --                           AND CATEGORY_SET_ID = B.CATEGORY_SET_ID
   --                           AND ROWNUM = 1)
   --   AND p_validation_mode = 'N';

   CURSOR c_check_temp(segment VARCHAR2) IS
   SELECT 1 exist_flag FROM DUAL
    WHERE NOT EXISTS(SELECT child_code
                       FROM eni_vset_hrchy_temp
                      WHERE child_code = segment
                        AND hrchy_flag = 'Y'
                        AND rownum = 1)
      AND p_validation_mode = 'N';

  -- Cursor to select all the new nodes defined in the value set
  -- hierarchy (Insert into valid cats) + all the nodes that have
  -- been moved in the hierarchy (update in valid cats)

   CURSOR C_INS_UPD(l_catg number) IS
    SELECT
      v.category_id            VSET_CHILD_ID,
      v.segment1               VSET_CHILD_CODE,
      DECODE(v1.category_id,l_catg,NULL, v1.category_id)  VSET_PARENT_ID,
      h.category_id            CAT_CHILD_ID,
      h.parent_category_id     CAT_PARENT_ID,
      g_catset_id              CATEGORY_SET_ID
    FROM eni_vset_hrchy_temp f, mtl_categories_b v,
         mtl_categories_b v1, mtl_category_set_valid_cats h
    WHERE v.structure_id = g_struct_id
      AND v1.structure_id(+) = g_struct_id
      AND f.child_code = v.segment1
      AND f.parent_code = v1.segment1(+)
      AND f.hrchy_flag = 'Y'
      AND h.category_set_id(+) = g_catset_id
      AND h.category_id(+) = v.category_id
      AND V.segment1 <> p_top_node;

BEGIN

  l_error:= FALSE;
  l_schema := 'ENI';

  -- Validating structure
  l_error := ENI_VALUESET_CATEGORY.ENI_VALIDATE_STRUCTURE;

  IF l_error THEN
     errbuf:= 'ERROR: in structure/ segment validation';
     FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: in structure/ segment validation');
     retcode := 2;
     RAISE_APPLICATION_ERROR(-20009, 'ERROR: in structure/ segment validation');
  END IF;

  -- Get category set associated with the Product Functional Area
  g_catset_id := ENI_DENORM_HRCHY.GET_CATEGORY_SET_ID;

  -- Get the value set that is associated with the structure
  g_value_set_id := ENI_VALUESET_CATEGORY.GET_FLEX_VALUE_SET_ID('401','MCAT',g_catset_id);

  IF g_value_set_id IS NULL THEN
      errbuf := 'ERROR: There is no value set associated with the default category set structure. Aborting....';
      FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: There is no value set associated with the default category set structure. ');
      retcode := 2;
      RAISE_APPLICATION_ERROR(-20009, 'Error: No value set is associated with the structure');
  END IF;

  -- Get structure id for the default category set for Product FA

  SELECT STRUCTURE_ID,DEFAULT_CATEGORY_ID INTO g_struct_id,g_default_cat_id
  FROM MTL_CATEGORY_SETS_B
  WHERE CATEGORY_SET_ID = g_catset_id;

  -- Call Validate_structure from this procedure to do all the
  -- validations. If everything is alright then move ahead.

  -- populating the entire value set into the temp table
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Truncating the temp table ... ');
  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.ENI_VSET_HRCHY_TEMP';

  INSERT INTO ENI_VSET_HRCHY_TEMP(
    CHILD_CODE,
    PARENT_CODE,
    HRCHY_FLAG)
  SELECT
    FLEX_VALUE         CHILD_CODE,
    PARENT_FLEX_VALUE  PARENT_CODE,
    'N'
  FROM FND_FLEX_VALUE_CHILDREN_V
  WHERE FLEX_VALUE_SET_ID = g_value_set_id
    AND FLEX_VALUE <> p_top_node
  UNION ALL
  SELECT p_top_node, NULL, 'N' FROM DUAL;

   -- populating the hierarchy from only the top node down
   -- into the temp table

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Populating hierarchy in temp table under the top node');

  INSERT INTO ENI_VSET_HRCHY_TEMP (
    CHILD_CODE,
    PARENT_CODE,
    HRCHY_FLAG)
  SELECT CHILD_CODE, PARENT_CODE, 'Y'
  FROM ENI_VSET_HRCHY_TEMP H
  CONNECT BY PRIOR CHILD_CODE = PARENT_CODE
  START WITH CHILD_CODE = p_top_node;

  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Rows inserted: ' || sql%rowcount);

  COMMIT;

  IF p_validation_mode = 'Y' THEN

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Running in Validation Mode');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    -- Calling function to validate setup. Erroring out if any error
    -- is reported.
    l_cnt := ENI_VALIDATE_SETUP;

    -- Report any categories that will be removed from the category set
    -- as they do not exist in the value set hierarchy

    l_cnt := 0;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Checking for categories that do not exist in the value set hierarchy');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------------------------------ ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'INFORMATION: THE FOLLOWING CATEGORIES ARE NOT UNDER THE TOP NODE ');
    FND_FILE.PUT_LINE(FND_FILE.LOG,'IN THE VALUE SET AND HAVE NO ITEM ASSIGNMENTS, HENCE WILL BE REMOVED');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------------------------- ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Code ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------- ');

    FOR i in c_out_hrchy(g_struct_id, g_catset_id) LOOP
      FND_FILE.PUT_LINE(FND_FILE.LOG, i.SEGMENT1);
      l_cnt := 1;
    END LOOP;
    IF l_cnt = 0 THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,' --- None --- ');
    END IF;


    -- Report any categories that will be left in the valid cats table
    -- as stray categories. These categories have item assignments

    l_cnt := 0;
    FND_FILE.PUT_LINE(FND_FILE.LOG, '');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Checking for categories that do not exist in the value set hierarchy but has item assignments');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------------------------------ ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'INFORMATION: THE FOLLOWING CATEGORIES ARE NOT UNDER THE ');
  FND_FILE.PUT_LINE(FND_FILE.LOG,'TOP NODE IN THE VALUE SET BUT HAS ITEM ASSIGNMENTS.');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'HENCE WILL BE PLACED AS INDEPENDENT TOP LEVEL CATEGORIES');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------------------------------ ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Code ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------- ');

    FOR i in c_stray_catg(g_struct_id, g_catset_id) LOOP
      FND_FILE.PUT_LINE(FND_FILE.LOG, i.SEGMENT1);
      l_cnt := 1;
    END LOOP;
    IF l_cnt = 0 THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,' --- None --- ');
    END IF;

  ELSIF p_validation_mode = 'N' then

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Running in Upgrade Mode');
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');

    -- Calling function to validate hierarchy setup.
    -- Error out if setup fails

    l_cnt := ENI_VALIDATE_SETUP;

    IF l_cnt = 1 THEN
      errbuf := 'ERROR: Setup Error. Aborting....';
      retcode := 2;
      RAISE_APPLICATION_ERROR(-20009, 'Setup/ Data Error');
    END IF;


    -- Update all the nodes that do not belong in the hierarchy
    -- but has item assignments. These nodes will not be deleted
    -- but will be made as standalone nodes. To do this, the
    -- parent_id of the node will be set to null.
    -- If there are other categories that have item assignments
    -- as well but do not belong in mtl valid cats, then those
    -- categories will be created as a standalone node in the
    -- valid categories table
    FND_FILE.PUT_LINE(FND_FILE.LOG, '');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Checking for categories that do not exist in the value set hierarchy but has item assignments');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------------------------------ ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'INFORMATION: CATEGORIES NOT UNDER THE TOP NODE BUT HAS ITEM ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ASSIGNMENTS. WILL REMAIN AS INDEPENDENT TOP LEVEL CATEGORIES');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '------------------------------------------------------------------ ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Code ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------- ');

    FOR i IN c_item_assign(g_struct_id, g_catset_id) LOOP

      IF i.flag = 1 THEN

        INV_ITEM_CATEGORY_PVT.Create_Valid_Category(
          p_api_version        => 1,
          p_category_set_id    => g_catset_id,
          p_category_id        => i.category_id,
          p_parent_category_id => null,
          x_return_status      => l_return_status,
          x_errorcode          => l_errorcode,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data
        );

      ELSE

        INV_ITEM_CATEGORY_PVT.Update_Valid_Category(
        p_api_version        => 1,
        p_category_set_id    => g_catset_id,
        p_category_id        => i.category_id,
        p_parent_category_id => null,
        x_return_status      => l_return_status,
        x_errorcode          => l_errorcode,
        x_msg_count          => l_msg_count,
        x_msg_data           => l_msg_data
        );

      END IF;


      IF l_return_status <> 'S' THEN
        FND_MSG_PUB.Get(p_msg_index=>fnd_msg_pub.G_LAST, p_encoded=>FND_API.G_FALSE, p_msg_index_out=>l_msg_index_out, p_data=>l_data);
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error while updating category: '||to_char(i.category_id)||' from product hierarchy');
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: '||l_data);
        errbuf := 'Error :' || l_data;
        retcode := 2;
        goto end_block;
      ELSE

        -- The following loop will only execute when a node is
        -- has item assignments but is not in the hierarchy under
        -- the top node

         FOR j IN c_check_temp(i.segment1) LOOP
           FND_FILE.PUT_LINE(FND_FILE.LOG, i.SEGMENT1);
         END LOOP;

      END IF;
    END LOOP;

    l_cnt := 0;
    FOR i IN c_out_hrchy(g_struct_id, g_catset_id) LOOP

      if l_cnt = 0 then
         -- After the nodes with item assignments are updated as standalone
         -- the remaining nodes in the branch can be deleted (similar to the
         -- UI behaviour). Here we will delete records from product hierarchy,
         -- which are not a part of VB hierarchy, starting from the top node.

         FND_FILE.PUT_LINE(FND_FILE.LOG, '');
         FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------------------------');
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'DELETED CATEGORIES: Removing categories from the default category ');
         FND_FILE.PUT_LINE(FND_FILE.LOG, 'set, which no longer belongs under the top node');
         FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------------------------');

         FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Code');
         FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------');

         l_cnt := 1;
      END IF;

      -- The foll. SQL is written to prevent the Delete_valid_category
      -- API from failing. The way the Delete API works is, when a
      -- parent node is passed as a category id, it will delete itself
      -- and all its children under it. So, next time when we pass the
      -- children's category id, the API will fail since by then the
      -- child has already been deleted.

      SELECT COUNT(CATEGORY_ID) INTO l_catg
      FROM MTL_CATEGORY_SET_VALID_CATS
      WHERE CATEGORY_SET_ID = i.CATEGORY_SET_ID
        AND CATEGORY_ID = i.CATEGORY_ID;

      IF l_catg <> 0 THEN

        INV_ITEM_CATEGORY_PUB.Delete_Valid_Category(
          p_api_version        => 1,
          p_category_set_id    => i.category_set_id,
          p_category_id        => i.category_id,
          x_return_status      => l_return_status,
          x_errorcode          => l_errorcode,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data
        );

        IF l_return_status <> 'S' THEN
          FND_MSG_PUB.Get(p_msg_index=>fnd_msg_pub.G_LAST, p_encoded=>FND_API.G_FALSE, p_msg_index_out=>l_msg_index_out, p_data=>l_data);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error while deleting '||to_char(i.category_id)||' from product hierarchy');
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: '||l_data);
          errbuf := 'Error :' || l_data;
          retcode := 2;
          goto end_block;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, i.SEGMENT1);
        END IF;
      END IF;
    END LOOP;

    IF l_cnt = 0 THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, '--- None ---');
    END IF;

    -- inserting new categories, which do not exist
    -- under the default category set. The cursor would
    -- also update if the parent-child relationship in the
    -- hierarchy has changed

    l_insert := 0;
    l_update := 0;
    l_catg := 0;

    -- Getting the category id for the top node
    SELECT category_id INTO l_catg
      FROM mtl_categories_b
     WHERE structure_id = g_struct_id
       AND segment1 = p_top_node;

    FOR i IN C_INS_UPD(l_catg) LOOP

      -- if the top node is the parent, then update it will null
      -- This is based on the new requirement where the top node
      -- should not be brought into the hierarchy

      -- IF (i.vset_parent_id = l_catg) THEN
      --    l_catg_id := '';
      -- ELSE
      --    l_catg_id := i.vset_parent_id;
      -- END IF;

      IF i.cat_child_id IS NULL THEN
        IF l_insert = 0 THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, '');
          FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------------------------');
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'NEW CATEGORIES: Creating category under the default category set');
          FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------------------------');

          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Code');
          FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------');

          l_insert := 1;
        END IF;


        INV_ITEM_CATEGORY_PVT.Create_Valid_Category(
          p_api_version        => 1,
          p_category_set_id    => i.category_set_id,
          p_category_id        => i.vset_child_id,
          p_parent_category_id => i.vset_parent_id,
          x_return_status      => l_return_status,
          x_errorcode          => l_errorcode,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data
        );

        IF l_return_status <> 'S' THEN
          FND_MSG_PUB.Get(p_msg_index=>fnd_msg_pub.G_LAST, p_encoded=>FND_API.G_FALSE, p_msg_index_out=>l_msg_index_out, p_data=>l_data);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error while inserting '||i.vset_child_code||' into product hierarchy');
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: '||l_data);
          errbuf := 'ERROR :' || l_data;
          retcode := 2;
          goto end_block;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, i.vset_child_code);
        END IF;

      -- Will update the parent-child relationship in
      -- mtl_category_set_valid_cats table if such a change
      -- is detected
      ELSIF NVL(i.vset_parent_id, -1) <> NVL(i.cat_parent_id, -1) THEN
        IF l_update = 0 then
           FND_FILE.PUT_LINE(FND_FILE.LOG, '');
           FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------------------------');
           FND_FILE.PUT_LINE(FND_FILE.LOG, 'UPDATED CATEGORIES: Updating categories with the new parent-child relationship in the value set');
           FND_FILE.PUT_LINE(FND_FILE.LOG, '-------------------------------------------------------------------');

           FND_FILE.PUT_LINE(FND_FILE.LOG, 'Category Code');
           FND_FILE.PUT_LINE(FND_FILE.LOG, '--------------');

           l_update := 1;

        END IF;


        INV_ITEM_CATEGORY_PVT.Update_Valid_Category(
          p_api_version        => 1,
          p_category_set_id    => i.category_set_id,
          p_category_id        => i.vset_child_id,
          p_parent_category_id => i.vset_parent_id,
          x_return_status      => l_return_status,
          x_errorcode          => l_errorcode,
          x_msg_count          => l_msg_count,
          x_msg_data           => l_msg_data
        );

        IF l_return_status <> 'S' THEN
          FND_MSG_PUB.Get(p_msg_index=>fnd_msg_pub.G_LAST, p_encoded=>FND_API.G_FALSE, p_msg_index_out=>l_msg_index_out, p_data=>l_data);
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error while updating '||i.vset_child_code||' of product hierarchy');
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: '||l_data);
          errbuf := 'ERROR :' || l_data;
          retcode := 2;
          goto end_block;
        ELSE
          FND_FILE.PUT_LINE(FND_FILE.LOG, i.vset_child_code);
        END IF;

      END IF; -- IF i.cat_child_id IS NULL THEN
    END LOOP;

  END IF; -- IF Validation_mode = 'N' THEN

  <<end_block>>
  NULL;

EXCEPTION
  WHEN  NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: No Data Found. Transaction will be rolled back');
    errbuf := 'No data found ' || sqlerrm;
    retcode := 2;
    ROLLBACK;
    RAISE;
  WHEN OTHERS THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: ' || sqlerrm || '. Transaction will be rolled back');
    errbuf := 'Error :' || sqlerrm;
    retcode := 2;
    ROLLBACK;
    RAISE;
END;

END ENI_UPGRADE_VSET;

/
