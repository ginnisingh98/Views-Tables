--------------------------------------------------------
--  DDL for Package Body ENI_PROD_VALUESET
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."ENI_PROD_VALUESET" AS
/* $Header: ENIVSTPB.pls 120.2 2006/03/16 06:36:17 pfarkade noship $  */

  g_catset_id        NUMBER;

PROCEDURE UPDATE_VALUESET_FROM_CATEGORY
    (errbuf OUT NOCOPY VARCHAR2, retcode OUT NOCOPY VARCHAR2) IS

  l_struct_id        NUMBER;  -- structure id of default category set associated with Product reporting functional area
  l_flex_val_set_id  NUMBER;  -- flex value set id, where hierarchy has to be loaded

  -- Cursor that creates the hierarchy with parent-child relationship
  CURSOR hierarchy IS
  SELECT
    V.CONCATENATED_SEGMENTS   PARENT_CODE,
    V1.CONCATENATED_SEGMENTS  CHILD_CODE,
    DECODE(F.SUMMARY_FLAG, 'Y', 'P', 'C') RANGE_ATTRIBUTE
  FROM MTL_CATEGORY_SET_VALID_CATS T, MTL_CATEGORIES_KFV V, MTL_CATEGORIES_KFV V1, FND_FLEX_VALUES F
  WHERE T.CATEGORY_SET_ID = g_catset_id
    AND T.CATEGORY_ID = V1.CATEGORY_ID
    AND T.PARENT_CATEGORY_ID = V.CATEGORY_ID
    AND V1.CONCATENATED_SEGMENTS = F.FLEX_VALUE
    AND F.FLEX_VALUE_SET_ID = l_flex_val_set_id
    AND NOT EXISTS (SELECT NULL FROM FND_FLEX_VALUE_NORM_HIERARCHY H
                    WHERE FLEX_VALUE_SET_ID = F.FLEX_VALUE_SET_ID
                      AND PARENT_FLEX_VALUE = V.CONCATENATED_SEGMENTS
            AND RANGE_ATTRIBUTE = DECODE(F.SUMMARY_FLAG, 'Y', 'P', 'C')
                    AND CHILD_FLEX_VALUE_LOW = V1.CONCATENATED_SEGMENTS
                 AND CHILD_FLEX_VALUE_HIGH = V1.CONCATENATED_SEGMENTS);

  -- Cursor that creates the hierarchy under the top node, if the
  -- top node is specifid in the UI
  CURSOR c_hierarchy_top_node(l_top_node VARCHAR2) IS
  select l_top_node parent_code,
         concatenated_segments child_code,
         decode(f.summary_flag,'Y','P','C') range_attribute
    from mtl_category_set_valid_cats a,
         mtl_categories_kfv b, fnd_flex_values f
   where parent_category_id is null
     and category_set_id = g_catset_id
     and a.category_id = b.category_id
     and b.structure_id = l_struct_id
     and b.concatenated_segments = f.flex_value
     and f.flex_value_set_id = l_flex_val_set_id
     and l_top_node is not null
     and not exists( select 'X' from fnd_flex_value_norm_hierarchy h
                      where flex_value_set_id = f.flex_value_set_id
                        and parent_flex_value = l_top_node
                and range_attribute= decode(f.summary_flag,'Y','P','C')
                 and child_flex_value_low = b.concatenated_segments
                 and child_flex_value_high = b.concatenated_segments);


  -- Cursor to check for loops in the hierarchy
  -- The following query has two parts.In the first part, it will
  -- retrieve all the categories that exist in valid cats.
  -- In the second part, it will start from the top node and
  -- traverse up the hierarchy and get all the parents, grandparents
  -- This is to ensure that a node doesn't get created in the
  -- value set with a circular reference

  CURSOR c_hierarchy_loop(l_top_node VARCHAR2) IS
  SELECT b.concatenated_segments nodes
    FROM mtl_category_set_valid_cats a, mtl_categories_kfv b
   WHERE a.category_set_id = g_catset_id
     AND a.category_id = b.category_id
     AND b.structure_id = l_struct_id
  INTERSECT
   SELECT child_code nodes
     FROM eni_vset_hrchy_temp
    WHERE hrchy_flag = 'P'
  --    AND parent_code is not null
    START with child_code = l_top_node
   CONNECT BY child_code = prior parent_code;


  TYPE ref_cursor IS REF CURSOR;
  new_values_cursor ref_cursor;
  existing_values_cursor ref_cursor;

  l_sql_stmt            VARCHAR2(32000);
  l_value_set_name      VARCHAR2(1000);
  l_msg                 VARCHAR2(2000);
  l_top_node		VARCHAR2(150);
  l_summary_flag        VARCHAR2(1);
  l_enabled_flag        VARCHAR2(1);

  l_flex_value_id       NUMBER;
  l_flex_value          FND_FLEX_VALUES.FLEX_VALUE%TYPE;
  l_new_enabled_flag    VARCHAR2(1);
  l_new_description     FND_FLEX_VALUES_TL.DESCRIPTION%TYPE;
  l_new_start_date      DATE;
  l_new_end_date        DATE;
  l_old_enabled_flag    VARCHAR2(1);
  l_old_start_date      DATE;
  l_old_end_date        DATE;
  l_old_summary_flag    VARCHAR2(1);
  l_old_description     FND_FLEX_VALUES_TL.DESCRIPTION%TYPE;
  l_new_summary_flag    VARCHAR2(1);
  l_schema VARCHAR2(10) := 'ENI';

  table_not_found       EXCEPTION;
  PRAGMA EXCEPTION_INIT(table_not_found, -00942);
  l_count               NUMBER := 0;
  l_compile             BOOLEAN := FALSE;

BEGIN
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Start of Loading Product Catalog Hierarchy into Value set');
  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Getting associated Structure...');

  BEGIN

    g_catset_id := ENI_DENORM_HRCHY.get_category_set_id;

    SELECT STRUCTURE_ID INTO l_struct_id
    FROM MTL_CATEGORY_SETS_B
    WHERE CATEGORY_SET_ID = g_catset_id;
  EXCEPTION
    WHEN NO_DATA_FOUND THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Product Catalog Not Found');
    errbuf := 'ERROR: Product Catalog Not Found';
    retcode := 2;
    RAISE;
  END;

  -- CHeck if structure has only one segment enabled
  BEGIN
    Select segment_num into l_count
      from fnd_id_flex_segments
     where id_flex_num = l_struct_id
       and enabled_flag = 'Y';

   EXCEPTION
     WHEN TOO_MANY_ROWS THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG, 'ERROR: Structure of default category set can have only one segment enabled. More than one segment is not supported');
       errbuf := 'ERROR: Structure of default category set can have only one segment enabled. More than one segment is not supported';
       retcode := 2;
       RAISE;
     WHEN NO_DATA_FOUND THEN
        null;
   END;

  -- Get top node --

  BEGIN

     -- Selecting the flex_value_set_name from the flex_value_set_id.
     -- Flex value set name is needed to pass as a parameter while
     -- calling the FND packages

     select a.flex_value_set_id, a.top_node, b.flex_value_set_name
       INTO l_flex_val_set_id, l_top_node, l_value_set_name
       FROM ego_financial_reporting_agv a, fnd_flex_value_sets b
      WHERE a.category_set_id = g_catset_id
        AND a.flex_value_set_id = b.flex_value_set_id
        AND rownum = 1;

     if l_top_node is not null then
        BEGIN

           -- Ego view only stores the flex_value_id of the top node.
           -- Getting the top node name from  the id

           SELECT flex_value INTO l_top_node
             FROM fnd_flex_values
            WHERE flex_value_set_id = l_flex_val_set_id
              AND flex_value_id = l_top_node;

         EXCEPTION
           WHEN NO_DATA_FOUND THEN
             errbuf := 'Please enter a value set before running this program';
             retcode := 2;
             RAISE_APPLICATION_ERROR(-20009, 'ERROR: Value set cannot be null');

         END;

     end if;

  EXCEPTION
     WHEN NO_DATA_FOUND THEN
        errbuf := 'Please enter a value set before running this program';
        retcode := 2;
        RAISE_APPLICATION_ERROR(-20009, 'ERROR: Value set cannot be null');
  END;


  -- Storing into the temporary table. This is done so that start-with
  -- connect-by clause can be used when a top node is selected in the UI.
  -- When the top node is selected we should only propagate the catalog
  -- hierarchy to under the top node

  -- The hrchy_flag is set to "P" which related to "propagation"
  -- Once we figure out if the top node is selected or not, the flag
  -- is set to "Y". All transactions following that would look at
  -- hrchy_flag = "Y"

  EXECUTE IMMEDIATE 'TRUNCATE TABLE ' || l_schema || '.ENI_VSET_HRCHY_TEMP';

  INSERT INTO ENI_VSET_HRCHY_TEMP(
          CHILD_CODE,
          PARENT_CODE,
          SUMMARY_FLAG,
          child_value_id,
          ENABLED_FLAG,
          START_DATE_ACTIVE,
          END_DATE_ACTIVE,
          HRCHY_FLAG)
     SELECT
          a.FLEX_VALUE         CHILD_CODE,
          PARENT_FLEX_VALUE  PARENT_CODE,
          a.SUMMARY_FLAG,
          b.flex_value_id,
          b.ENABLED_FLAG,
          b.START_DATE_ACTIVE,
          b.END_DATE_ACTIVE,
          'P'
      FROM FND_FLEX_VALUE_CHILDREN_V a, fnd_flex_values b
     WHERE a.FLEX_VALUE_SET_ID = l_flex_val_set_id
       and a.flex_value_set_id = b.flex_value_set_id
       and a.flex_value = b.flex_value
     UNION
     SELECT FLEX_VALUE,
            null,
            SUMMARY_FLAG,
            flex_value_id,
            ENABLED_FLAG,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            'P'
       FROM FND_FLEX_VALUES A
      WHERE flex_value_set_id = l_flex_val_set_id
        AND not exists (Select flex_value
                          from fnd_flex_value_children_v
                         where flex_value_set_id = a.flex_value_set_id
                           and flex_value = a.flex_value);

      commit;

 l_count := 0;
 if l_top_node is not null then

   -- First check if the hierarchy will create a loop in the
   -- value set

   FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'ERROR: The following nodes already exist as parent of the top node in the value set.');
      FND_FILE.PUT_LINE(FND_FILE.LOG,'These nodes cannot be created as child of the top node');
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'FLEX VALUES ');
      FND_FILE.PUT_LINE(FND_FILE.LOG, '------------');

   FOR i IN c_hierarchy_loop(l_top_node) LOOP
       FND_FILE.PUT_LINE(FND_FILE.LOG, i.nodes);
       l_count := 1;
   END LOOP;

   IF l_count = 0 THEN
       FND_FILE.PUT_LINE(FND_FILE.LOG,'-- None --');
   ELSE
       errbuf := 'ERROR: Circular reference in the value set is not allowed';
       retcode := 2;
       RAISE_APPLICATION_ERROR(-20009, 'ERROR: Data error');
   END IF;


   -- populating the hierarchy from only the top node down
   -- into the temp table

     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Populating hierarchy in temp table under the top node');

     INSERT INTO ENI_VSET_HRCHY_TEMP (
            CHILD_CODE,
            PARENT_CODE,
            SUMMARY_FLAG,
            CHILD_VALUE_ID,
            ENABLED_FLAG,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            HRCHY_FLAG)
     SELECT CHILD_CODE,
            PARENT_CODE,
            summary_flag,
            child_value_id,
            ENABLED_FLAG,
            START_DATE_ACTIVE,
            END_DATE_ACTIVE,
            'Y'
       FROM ENI_VSET_HRCHY_TEMP H
    CONNECT BY PRIOR CHILD_CODE = PARENT_CODE
      START WITH CHILD_CODE = l_top_node;

   else


    -- if top node is not null, change the hrchy_flag to "Y"
    -- this is so that with or without the top node, we can look
    -- at the same where clause

     UPDATE eni_vset_hrchy_temp
        SET hrchy_flag = 'Y'
      WHERE hrchy_flag = 'P';
  end if;


    -- the following nodes do not exist in the hierarchy, so will be
    -- inserted into the value set

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'NEW NODES: New values that will be inserted into the value set');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'FLEX VALUES ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '------------');


  l_sql_stmt := '
                SELECT
                  V.CONCATENATED_SEGMENTS ,
                  V.ENABLED_FLAG,
                  T.DESCRIPTION,
                  V.START_DATE_ACTIVE,
                  V.DISABLE_DATE,
                  NVL((SELECT ''Y'' FROM MTL_CATEGORY_SET_VALID_CATS C
                       WHERE C.CATEGORY_SET_ID = H.CATEGORY_SET_ID
                         AND C.PARENT_CATEGORY_ID = V.CATEGORY_ID
                         AND ROWNUM = 1), ''N'') SUMMARY_FLAG
                FROM MTL_CATEGORIES_KFV V,
                     MTL_CATEGORIES_TL T,
                     MTL_CATEGORY_SET_VALID_CATS H
                WHERE V.STRUCTURE_ID = :l_struct_id
                  AND V.CATEGORY_ID = T.CATEGORY_ID
                  AND T.LANGUAGE = USERENV(''LANG'')
                  AND V.CATEGORY_ID = H.CATEGORY_ID
                  AND H.CATEGORY_SET_ID = :g_catset_id
                  AND NOT EXISTS
                    (SELECT NULL FROM FND_FLEX_VALUES F
                      WHERE F.FLEX_VALUE = V.CONCATENATED_SEGMENTS
                        AND F.FLEX_VALUE_SET_ID = :l_flex_val_set_id)';


   l_count := 0;
   FND_FILE.PUT_LINE(FND_FILE.LOG, ' Opening Cursor to Insert new values');
   -- INSERTING NEW VALUES INTO FND_FLEX_VALUES TABLE
  OPEN new_values_cursor FOR l_sql_stmt USING l_struct_id, g_catset_id, l_flex_val_set_id;

  LOOP
    FETCH new_values_cursor INTO
        l_flex_value,
        l_new_enabled_flag,
        l_new_description,
        l_new_start_date,
        l_new_end_date,
        l_new_summary_flag;

    EXIT WHEN new_values_cursor%NOTFOUND;

    BEGIN
      FND_FLEX_VAL_API.CREATE_INDEPENDENT_VSET_VALUE
       (p_flex_value_set_name => l_value_set_name,
        p_flex_value          => l_flex_value,
        p_description         => l_new_description,
        p_enabled_flag        => l_new_enabled_flag,
        p_summary_flag        => l_new_summary_flag,
        p_start_date_active   => l_new_start_date,
        p_end_date_active     => l_new_end_date,
        p_hierarchy_level     => NULL,
        x_storage_value       => l_msg);

      l_count := 1;
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg) ;

    EXCEPTION WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error while Inserting '||l_flex_value||', '||l_msg);
      errbuf :=  'Error while Inserting '||l_flex_value||', '||l_msg;
      retcode := 2;
      RAISE;
    END;

  END LOOP;

  IF l_count = 0 then
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' -- none --');
  END IF;

  IF new_values_cursor%ISOPEN THEN
    CLOSE new_values_cursor;
  END IF;


  -- The following nodes already exist in the value set and will
  -- be updated


  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'UPDATED NODES: Updating Existing Values');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'FLEX VALUES ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '------------');


  l_sql_stmt := '
                SELECT
                  X.CHILD_VALUE_ID,
                  X.CHILD_CODE,
                  X.NEW_ENABLED_FLAG,
                  X.NEW_DESCRIPTION,
                  X.NEW_START_DATE,
                  X.NEW_END_DATE,
                  X.NEW_SUMMARY_FLAG
                FROM
                (
                  SELECT
                    F.FLEX_VALUE_ID CHILD_VALUE_ID,
                    F.FLEX_VALUE CHILD_CODE,
                    T.DESCRIPTION              NEW_DESCRIPTION,
                   NVL((SELECT V.ENABLED_FLAG FROM MTL_CATEGORY_SET_VALID_CATS C
                            WHERE C.CATEGORY_SET_ID = H.CATEGORY_SET_ID
                            AND C.CATEGORY_ID = V.CATEGORY_ID
                            AND ROWNUM = 1),''N'')  NEW_ENABLED_FLAG,
		    V.START_DATE_ACTIVE        NEW_START_DATE,
                    V.DISABLE_DATE             NEW_END_DATE,
                    F.ENABLED_FLAG             OLD_ENABLED_FLAG,
                    F.START_DATE_ACTIVE        OLD_START_DATE,
                    F.END_DATE_ACTIVE          OLD_END_DATE,
                    F.SUMMARY_FLAG             OLD_SUMMARY_FLAG,
                    FT.DESCRIPTION             OLD_DESCRIPTION,
                   NVL((SELECT ''Y'' FROM MTL_CATEGORY_SET_VALID_CATS C
                         WHERE C.CATEGORY_SET_ID = H.CATEGORY_SET_ID
                           AND C.PARENT_CATEGORY_ID = V.CATEGORY_ID
                           AND ROWNUM = 1), ''N'') NEW_SUMMARY_FLAG
                  FROM MTL_CATEGORIES_KFV V, MTL_CATEGORIES_TL T,
                       FND_FLEX_VALUES F,
                       FND_FLEX_VALUES_TL FT,
                       MTL_CATEGORY_SET_VALID_CATS H
                  WHERE V.STRUCTURE_ID = :l_struct_id
                    AND V.CATEGORY_ID = T.CATEGORY_ID
                    AND T.LANGUAGE = USERENV(''LANG'')
                    AND F.flex_value= V.CONCATENATED_SEGMENTS
                    AND F.flex_value_set_id = :l_flex_val_set_id
                    AND F.flex_VALUE_ID = FT.FLEX_VALUE_ID
                    AND FT.LANGUAGE = USERENV(''LANG'')
                    AND V.CATEGORY_ID = H.CATEGORY_ID(+)
                    AND H.CATEGORY_SET_ID(+) = :g_catset_id) X
   WHERE X.NEW_ENABLED_FLAG <> X.OLD_ENABLED_FLAG
   OR X.NEW_SUMMARY_FLAG <> X.OLD_SUMMARY_FLAG
   OR NVL(X.NEW_DESCRIPTION, ''XX'') <> NVL(X.OLD_DESCRIPTION, ''XX'')
   OR NVL(X.NEW_START_DATE, SYSDATE) <> NVL(X.OLD_START_DATE, SYSDATE)
   OR NVL(X.NEW_END_DATE, SYSDATE) <> NVL(X.OLD_END_DATE, SYSDATE)';


  -- UPDATING EXISTING VALUES IF CHANGED

  OPEN existing_values_cursor FOR l_sql_stmt USING  l_struct_id, l_flex_val_set_id, g_catset_id;

  LOOP
    FETCH existing_values_cursor INTO
        l_flex_value_id,
        l_flex_value,
        l_new_enabled_flag,
        l_new_description,
        l_new_start_date,
        l_new_end_date,
        l_new_summary_flag;

    EXIT WHEN existing_values_cursor%NOTFOUND;

   BEGIN

      -- The FND API does not update a value when "null" is passed
      -- as a value to any of the parameters. When it sees "null"
      --, the parameter is simply ignored and the column doesn't get
      -- updated. If you want to update a column to a null value,
      -- you will need to pass the global constants that they provide
      -- Hence this if-then clause...

      IF l_new_enabled_flag IS NULL THEN
         l_new_enabled_flag := fnd_flex_val_api.g_null_varchar2;
      END IF;

      IF l_new_description IS NULL THEN
         l_new_description := fnd_flex_val_api.g_null_varchar2;
      END IF;

      IF l_new_start_date IS NULL THEN
         l_new_start_date := fnd_flex_val_api.g_null_date;
      END IF;

      IF l_new_end_date IS NULL or l_new_end_date = '' THEN
         l_new_end_date := fnd_flex_val_api.g_null_date;
      END IF;

      IF l_new_summary_flag IS NULL THEN
         l_new_summary_flag := fnd_flex_val_api.g_null_varchar2;
      END IF;


      FND_FLEX_VAL_API.UPDATE_INDEPENDENT_VSET_VALUE
        (p_flex_value_set_name => l_value_set_name,
         p_flex_value => l_flex_value,
         p_description => l_new_description,
         p_enabled_flag => l_new_enabled_flag,
         p_start_date_active => l_new_start_date,
         p_end_date_active => l_new_end_date,
         p_summary_flag => l_new_summary_flag,
         x_storage_value => l_msg);

      l_count := 1;
      FND_FILE.PUT_LINE(FND_FILE.LOG, l_msg);

    EXCEPTION WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error while updating '||l_flex_value||', '||l_msg);
      errbuf :=  'Error while updating '||l_flex_value||', '||l_msg;
      retcode := 2;
      RAISE;
    END;
  END LOOP;

  IF l_count = 0 then
      FND_FILE.PUT_LINE(FND_FILE.LOG, ' -- none --');
  END IF;

  IF existing_values_cursor%ISOPEN THEN
    CLOSE existing_values_cursor;
  END IF;

  IF l_top_node IS NOT NULL THEN

    -- If top node is not null, insert the catalog under the hierarchy

    -- Check if the top node entered is a child node. If it is a
    -- child node, then first make the node a parent node in the
    -- value set

    Select summary_flag, enabled_flag
      into l_summary_flag, l_enabled_flag
      from fnd_flex_values
     where flex_value = l_top_node
     and flex_value_set_id = l_flex_val_set_id;         --Bug 5087675
     --  and rownum = 1;                                --Bug 5087675

     If l_summary_flag = 'N' OR l_enabled_flag = 'N' then

       begin
         FND_FLEX_VAL_API.UPDATE_INDEPENDENT_VSET_VALUE
          (p_flex_value_set_name => l_value_set_name,
           p_flex_value => l_top_node,
           p_summary_flag => 'Y',
           p_enabled_flag => 'Y',
           x_storage_value => l_msg);

        exception when others then
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error while updating '||l_top_node||', '||l_msg);
          errbuf :=  'Error while Inserting '||l_flex_value||', '||l_msg;
          retcode := 2;
          RAISE;

      end;
     end if;

    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creating Hierarchy: Direct children of the top node ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parent Code    Child Code ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, '-----------    ------------ ');

     -- Inserting new nodes under the top node specified in the UI
     FOR i in c_hierarchy_top_node(l_top_node) loop
       BEGIN
          FND_FLEX_VAL_API.CREATE_VALUE_HIERARCHY(
            p_flex_value_set_name   => l_value_set_name,
            p_parent_flex_value     => i.PARENT_CODE,
            p_range_attribute       => i.RANGE_ATTRIBUTE,
            p_child_flex_value_low  => i.CHILD_CODE,
            p_child_flex_value_high => i.CHILD_CODE);

          l_count := l_count + 1;
          FND_FILE.PUT_LINE(FND_FILE.LOG, i.parent_code || ' ' || i.child_code);

          l_compile := TRUE;

       EXCEPTION WHEN OTHERS THEN
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error while creating hierarchy under the top node '||i.parent_code||', '||l_msg);
          errbuf :=   'Error while creating hierarchy under the top node '||i.parent_code||', '||l_msg;
          retcode := 2;
          RAISE;
       END;
     END LOOP;

   END IF; -- if top node is not null



  -- INSERTING THE REST OF THE HIERARCHY

  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Creating Hierarchy: All the nodes ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Parent Code    Child Code ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, '-----------    ------------ ');
  l_count := 0;

  FOR i IN hierarchy LOOP
    BEGIN
      FND_FLEX_VAL_API.CREATE_VALUE_HIERARCHY(
        p_flex_value_set_name   => l_value_set_name,
        p_parent_flex_value     => i.PARENT_CODE,
        p_range_attribute       => i.RANGE_ATTRIBUTE,
        p_child_flex_value_low  => i.CHILD_CODE,
        p_child_flex_value_high => i.CHILD_CODE);

      l_count := l_count + 1;
      FND_FILE.PUT_LINE(FND_FILE.LOG, i.parent_code || ' '|| i.child_code);

      l_compile := TRUE;
    EXCEPTION WHEN OTHERS THEN
        FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error while creating hierarchy for child '||i.CHILD_CODE);
        errbuf :=  'Error while creating hierarchy for child '||i.CHILD_CODE;
       retcode := 2;
      RAISE;
    END;
  END LOOP;



  -- DELETING NODES WHICH ARE NOT IN HIERARCHY. This is only applicable
  -- when the top node is specified. In other cases the other nodes
  -- will remain as is.

  l_count := 0;
--  if l_top_node is not null then

     FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
     FND_FILE.PUT_LINE(FND_FILE.LOG, 'Removing hierarchy relationship for nodes that do not exist under the top node');

      -- This will delete all the other children that no longer has any parent-child relationship under the top node
      -- This delete SQL has two parts:
      -- The first part of the union selects the existing parent-child
      -- relationship from the value set hierarchy. If top node is specified
      -- it will only select the hierarchy under the top node.
      -- The second part of the union selects all the parent-child relationship
      -- from the catalog hierarchy
      -- The minus will eliminate all the records that are present in the
      -- value set hierarchy but no longer exists in the catalog hierarchy

     --   Changed the first part of the select statement to remove the child flex
     --    ranges defined in hierarchy

     /* ** Performance fix - see Bug 4960193 ** */
     delete from fnd_flex_value_norm_hierarchy hrchy
       where flex_value_set_id = l_flex_val_set_id
	and exists (
		select null
		from fnd_flex_values b
		where hrchy.flex_value_set_id = b.flex_value_set_id
		and hrchy.parent_flex_value = b.flex_value
		and b.enabled_flag = 'Y')
	and (parent_flex_value,
              child_flex_value_low,
              child_flex_value_high,
              range_attribute)
        not in (
             select nvl(a.concatenated_segments,l_top_node),
                    b.concatenated_segments,
                    b.concatenated_segments,
                    NVL((select 'P' from mtl_category_set_valid_cats v
		          where v.category_set_id = c.category_set_id
		            and v.parent_category_id = b.category_id
                            and rownum = 1), 'C')
                    -- decode(b.summary_flag,'Y','P','C')
               from mtl_categories_kfv a,
                    mtl_categories_kfv b,
                    mtl_category_set_valid_cats c
              where a.structure_id(+) = l_struct_id
                and b.structure_id = l_struct_id
                and c.category_set_id = g_catset_id
                and c.parent_category_id = a.category_id(+)
                and c.category_id = b.category_id
		);

     l_count := SQL%ROWCOUNT;

--   end if; -- if l_top_node is not null
   FND_FILE.PUT_LINE(FND_FILE.LOG, 'Number of records deleted: '||l_count);

   IF l_count > 0 THEN
      l_compile := TRUE;
   END IF;

  IF l_compile THEN
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'Compiling Value set Hierarchy...');

    FND_GLOBAL.APPS_INITIALIZE(user_id      => 0,
                               resp_id      => 20420,
                               resp_appl_id => 1);


    -- Catch the exception if the compiler fails to compile
    BEGIN

      FND_FLEX_VAL_API.SUBMIT_VSET_HIERARCHY_COMPILER
        (p_flex_value_set_name   => l_value_set_name,
         x_request_id            => l_msg);

      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Submitted request '||l_msg);
    EXCEPTION
       WHEN OTHERS THEN
          l_msg := l_msg || ' ' || dbms_utility.format_error_stack();
          FND_FILE.PUT_LINE(FND_FILE.LOG, 'Submitted request '||l_msg);
          RAISE;
    END;

  ELSE
    FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
    FND_FILE.PUT_LINE(FND_FILE.LOG, 'No changes detected in Hierarchy');
  END IF;

  FND_FILE.PUT_LINE(FND_FILE.LOG, ' ');
  FND_FILE.PUT_LINE(FND_FILE.LOG, 'Successfully completed loading Product Catalog Hierarchy to Value Set');

EXCEPTION
   WHEN  NO_DATA_FOUND THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG, 'Error: No Data Found. Transaction will be rolled back');
      errbuf := 'No data found ' || sqlerrm;
      retcode := 2;
      ROLLBACK;
      RAISE;
   WHEN OTHERS THEN
      FND_FILE.PUT_LINE(FND_FILE.LOG,'Error: ' || sqlerrm || ' .Transaction will be rolled back');
      errbuf := 'Error :' || sqlerrm;
      retcode := 2;
      ROLLBACK;
      RAISE;
END UPDATE_VALUESET_FROM_CATEGORY;

END ENI_PROD_VALUESET;

/
