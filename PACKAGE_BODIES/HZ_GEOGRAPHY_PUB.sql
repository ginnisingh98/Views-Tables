--------------------------------------------------------
--  DDL for Package Body HZ_GEOGRAPHY_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_GEOGRAPHY_PUB" AS
/*$Header: ARHGEOSB.pls 120.39 2007/11/15 01:47:12 nsinghai ship $ */

------------------------------------
-- declaration of private procedures
------------------------------------

PROCEDURE do_create_master_relation(
    p_master_relation_rec       IN         MASTER_RELATION_REC_TYPE,
    x_relationship_id           OUT NOCOPY NUMBER,
    x_return_status             IN OUT NOCOPY    VARCHAR2
    );

PROCEDURE denormalize_relation(
        p_geography_id     IN NUMBER,
        p_parent_geography_id IN NUMBER,
        p_geography_type   IN VARCHAR2,
        x_return_status    IN OUT NOCOPY VARCHAR2
        );

PROCEDURE remove_denorm(
       p_geography_id     IN NUMBER,
       p_geography_type   IN VARCHAR2
       );
PROCEDURE check_duplicate_name(
       p_parent_id       IN NUMBER,
       p_child_id        IN NUMBER,
       p_child_name      IN VARCHAR2,
       p_child_type      IN VARCHAR2,
       p_child_identifier_subtype IN VARCHAR2,
       p_child_language IN VARCHAR2,
       x_return_status   IN OUT NOCOPY VARCHAR2
       );
PROCEDURE check_duplicate_code(
       p_parent_id       IN NUMBER,
       p_child_id        IN NUMBER,
       p_child_code      IN VARCHAR2,
       p_child_type      IN VARCHAR2,
       p_child_identifier_subtype IN VARCHAR2,
       p_child_language IN VARCHAR2,
       x_return_status   IN OUT NOCOPY VARCHAR2
       );
-- Added by Nishant on 05-Oct-2005 for bug 3268961
FUNCTION multi_parent_update_val(
      l_geo_id           IN NUMBER,
	  l_element_col      IN VARCHAR2,
      l_element_col_type IN VARCHAR2 DEFAULT 'NAME'
	  ) RETURN VARCHAR2;

------------------------------
--global variables
------------------------------

 g_dup_checked    VARCHAR2(1) := 'N';

-------------------------------
-- body of private function
-------------------------------
  -----------------------------------------------------------------------------+
  -- This function takes in geography_id for and element_column and column_type
  -- as input, validates if for passed element column there are multiple parents
  -- or not, it there are, it returns null otherwise it will return element column
  -- name depending on passed element column type (ID, CODE, NAME)
  -- Created by Nishant Singhai for Bug 3268961. This function will help in
  -- indentifying if a particular column has to be updated or not in case of
  -- multiple parents
  -----------------------------------------------------------------------------+
  FUNCTION multi_parent_update_val (l_geo_id NUMBER,  l_element_col VARCHAR2,
                                    l_element_col_type VARCHAR2 DEFAULT 'NAME')
    RETURN VARCHAR2 IS
    l_return_value VARCHAR2(100);
    l_country_code VARCHAR2(10);
  BEGIN

   IF (l_geo_id IS NOT NULL) THEN
    SELECT country_code
    INTO   l_country_code
    FROM   hz_geographies
    WHERE  geography_id = l_geo_id;

	SELECT DECODE(l_element_col_type,'ID', geo_element_col||'_ID','CODE',
	       geo_element_col||'_CODE','NAME',geo_element_col,geo_element_col)
	INTO  l_return_value
	FROM (
	-- This select gives geography_element column name for those levels which
	-- are not multiple. For levels at which multiple parents exist, it returns null
	SELECT decode(no_of_parents, 1, DECODE(geo_temp.parent_object_type,'COUNTRY','GEOGRAPHY_ELEMENT1'
	       ,geo_struct.geography_element_column), NULL) geo_element_col, ROWNUM level_number,
	       geo_temp.parent_object_type geography_type
	FROM (
	     -- here grouping is based on number of parents at each level
	     SELECT COUNT(parent_object_type) no_of_parents , parent_object_type, level_number
	     FROM (
	           -- This query does the grouping based on parent id and geography type
	           -- Note : sysdate is not truncated in check because we want to not pick
	           -- up those records which are just now end dated (end dated in current flow)
	           SELECT  parent_id, parent_object_type, level_number
	           FROM   hz_hierarchy_nodes
	           WHERE  hierarchy_type = 'MASTER_REF'
	           AND    SYSDATE+0.0001 BETWEEN effective_start_date AND effective_end_date
	           AND    child_table_name = 'HZ_GEOGRAPHIES'
	           AND    NVL(status,'A') = 'A'
	           AND    child_id = l_geo_id
	           GROUP BY parent_id, parent_object_type, level_number
	         )
	    GROUP BY parent_object_type, level_number
	    ORDER BY level_number desc
	    ) geo_temp,
	      hz_geo_structure_levels geo_struct
	WHERE geo_temp.parent_object_type = DECODE(geo_temp.parent_object_type,
	                                          'COUNTRY',geo_struct.parent_geography_type,
											  geo_struct.geography_type)
	AND   country_code = l_country_code
	)
	WHERE geo_element_col = l_element_col;

    END IF;

    RETURN l_return_value;

  EXCEPTION WHEN OTHERS THEN
    RETURN NULL;
  END multi_parent_update_val;


-------------------------------
-- body of private procedures
-------------------------------

PROCEDURE denormalize_relation(
        p_geography_id     IN NUMBER,
        p_parent_geography_id IN NUMBER,
        p_geography_type   IN VARCHAR2,
        x_return_status    IN OUT NOCOPY VARCHAR2) IS

   CURSOR c_get_all_parents IS
      SELECT parent_id,parent_object_type
        FROM HZ_HIERARCHY_NODES
       WHERE child_id = p_geography_id
         AND child_object_type = p_geography_type
         AND child_table_name = 'HZ_GEOGRAPHIES'
         AND hierarchy_type = 'MASTER_REF'
   	     AND NVL(status,'A') = 'A'
         AND (effective_end_date IS NULL
          OR effective_end_date > sysdate
          )
          ORDER BY level_number;

    CURSOR c_get_country_details (l_country_code VARCHAR2) IS
    SELECT geography_id, geography_name, geography_code
    FROM   hz_geographies
    WHERE  geography_type = 'COUNTRY'
    AND    geography_use = 'MASTER_REF'
    AND    country_code  = l_country_code
    AND    SYSDATE BETWEEN START_DATE AND end_date;

     l_get_all_parents   c_get_all_parents%ROWTYPE;
     l_multiple_parent_flag VARCHAR2(1);
     l_geo_element_col      VARCHAR2(30);
     l_geography_name       VARCHAR2(360);
     l_geography_code       VARCHAR2(30);
     l_country_code         VARCHAR2(2);
     --l_denorm_stmnt         VARCHAR2(2000);
     l_geo_element_id_col   VARCHAR2(30);
     l_geo_element_code_col VARCHAR2(30);
     l_element_range        VARCHAR2(1);
     l_country_id           hz_geographies.geography_id%TYPE;
     l_country_name         hz_geographies.geography_name%TYPE;

     l_geo_element_col_temp VARCHAR2(30);

     BEGIN

    -- get country_code
    SELECT country_code INTO l_country_code
    FROM hz_geographies
    WHERE geography_id= p_parent_geography_id;

    l_element_range := 'T';

     OPEN c_get_all_parents;
         LOOP
           FETCH c_get_all_parents INTO l_get_all_parents;
           EXIT WHEN c_get_all_parents%NOTFOUND;

           BEGIN

             IF l_get_all_parents.parent_object_type <> 'COUNTRY' THEN
               -- get geography_element_column for this geography_type
               SELECT geography_element_column INTO l_geo_element_col
                 FROM HZ_GEO_STRUCTURE_LEVELS
                WHERE geography_type=l_get_all_parents.parent_object_type
                  AND country_code = l_country_code
                  AND rownum <2 ;

               --dbms_output.put_line('geo_element_col is '||l_geo_element_col);
               l_geo_element_id_col := l_geo_element_col||'_ID';
               l_geo_element_code_col := l_geo_element_col||'_CODE';

             ELSE
               l_geo_element_col := 'GEOGRAPHY_ELEMENT1';
               l_geo_element_code_col := 'GEOGRAPHY_ELEMENT1_CODE';
               l_geo_element_id_col := 'GEOGRAPHY_ELEMENT1_ID';
             END IF;

             -- Bug 6507596 : Added 'T' condition to reinitialize l_element_range for each loop execution.
             IF l_geo_element_col in ('GEOGRAPHY_ELEMENT1','GEOGRAPHY_ELEMENT2','GEOGRAPHY_ELEMENT3','GEOGRAPHY_ELEMENT4','GEOGRAPHY_ELEMENT5') THEN
               l_element_range := 'T';
             ELSE
               l_element_range := 'F';
             END IF;

           EXCEPTION WHEN NO_DATA_FOUND THEN
               FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_RECORD');
               FND_MESSAGE.SET_TOKEN('TOKEN1', 'geography_element_column');
               FND_MESSAGE.SET_TOKEN('TOKEN2', 'geography_type :'||l_get_all_parents.parent_object_type||', country_code :'||l_country_code);
               FND_MSG_PUB.ADD;
               x_return_status := fnd_api.g_ret_sts_error;
               RAISE FND_API.G_EXC_ERROR;
           END;

           -- get geography_name
           SELECT geography_name,geography_code INTO l_geography_name,l_geography_code
           FROM HZ_GEOGRAPHIES
           WHERE geography_id=l_get_all_parents.parent_id;

		   -- check if this is a multi parent column. If it is then multi_parent_update_val will return NULL
		   -- otherwise it will return back the column name.
		   l_geo_element_col_temp :=  multi_parent_update_val(p_geography_id,l_geo_element_col,'NAME');

           -- do update if it is not a multi parent case. So, do update only if l_geo_element_col_temp is not null
           IF (l_geo_element_col_temp IS NOT NULL) THEN

             -- added the if condition to eliminate denormalization of code if the GEOGRAPHY_ELEMENT column is beyond 5 (bug 3111794)
             IF l_element_range = 'T' THEN
                EXECUTE IMMEDIATE 'UPDATE HZ_GEOGRAPHIES SET '||l_geo_element_col||'= :l_geography_name '||
                  ','||l_geo_element_id_col||'= :l_parent_id '||
                  ','||l_geo_element_code_col||'= :l_geography_code '||
                  ', multiple_parent_flag = ''N'''||
                  ' where geography_id = :l_geography_id '
				  USING l_geography_name, l_get_all_parents.parent_id,l_geography_code,p_geography_id;

             ELSE
               EXECUTE IMMEDIATE 'UPDATE HZ_GEOGRAPHIES SET '||l_geo_element_col||'= :l_geography_name '||
                  ','||l_geo_element_id_col||'= :l_parent_id '||
                  ', multiple_parent_flag = ''N'''||
                  ' where geography_id = :l_geography_id '
				  USING l_geography_name, to_char(l_get_all_parents.parent_id), to_char(p_geography_id);

             END IF;
           ELSE  -- its a multi parent record (update the flag to 'Y')
              UPDATE HZ_GEOGRAPHIES
              SET    multiple_parent_flag = 'Y'
              WHERE  geography_id = p_geography_id
              AND    multiple_parent_flag <> 'Y';

           END IF;   -- end multi parent check

         END LOOP;
       --dbms_output.put_line('After the loop in denormalize_relation');
    CLOSE c_get_all_parents;

END denormalize_relation;

--removes de-normalization from the geography and its children in case of multiple parents for the geography
PROCEDURE remove_denorm(
  p_geography_id    IN NUMBER ,
  p_geography_type  IN VARCHAR2
  ) IS

  CURSOR c_get_all_children IS
    SELECT child_id,child_object_type
      FROM HZ_HIERARCHY_NODES
     WHERE parent_id=p_geography_id
       AND parent_object_type=p_geography_type
       AND parent_table_name = 'HZ_GEOGRAPHIES'
       AND hierarchy_type='MASTER_REF'
	   AND NVL(status,'A') = 'A'
       AND (effective_end_date IS NULL
        OR effective_end_date > sysdate);

   l_geo_element_col         VARCHAR2(30);
   l_common_parent_flag      VARCHAR2(1);
   l_common_type_flag        VARCHAR2(1);
   l_get_all_children        c_get_all_children%ROWTYPE;
   l_count                   NUMBER;
   l_parent_object_type      VARCHAR2(30);
   l_geo_element_col_id      VARCHAR2(30);
   l_geo_element_col_code    VARCHAR2(30);
   --l_stmnt                   VARCHAR2(1000);

   -- new variables for updating multi parent case
   l_geography_element2 VARCHAR2(100);
   l_geography_element3 VARCHAR2(100);
   l_geography_element4 VARCHAR2(100);
   l_geography_element5 VARCHAR2(100);
   l_geography_element6 VARCHAR2(100);
   l_geography_element7 VARCHAR2(100);
   l_geography_element8 VARCHAR2(100);
   l_geography_element9 VARCHAR2(100);
   l_geography_element10 VARCHAR2(100);
   l_geography_element2_id VARCHAR2(100);
   l_geography_element3_id VARCHAR2(100);
   l_geography_element4_id VARCHAR2(100);
   l_geography_element5_id VARCHAR2(100);
   l_geography_element6_id VARCHAR2(100);
   l_geography_element7_id VARCHAR2(100);
   l_geography_element8_id VARCHAR2(100);
   l_geography_element9_id VARCHAR2(100);
   l_geography_element10_id VARCHAR2(100);
   l_geography_element2_code VARCHAR2(100);
   l_geography_element3_code VARCHAR2(100);
   l_geography_element4_code VARCHAR2(100);
   l_geography_element5_code VARCHAR2(100);


   BEGIN

   --dbms_output.put_line('In remove denorm');

     -- check if all parents of geography_id are of same geography_type
     BEGIN

       SELECT distinct parent_object_type INTO l_parent_object_type
         FROM hz_hierarchy_nodes
        WHERE child_id = p_geography_id
          AND child_object_type=p_geography_type
          AND child_table_name = 'HZ_GEOGRAPHIES'
          AND hierarchy_type='MASTER_REF'
	      AND NVL(status,'A') = 'A'
          AND (effective_end_date IS NULL
              OR effective_end_date > sysdate)
          AND level_number = 1;

        l_common_type_flag := 'Y';

      EXCEPTION WHEN too_many_rows THEN
        l_common_type_flag := 'N';
      END;
       --dbms_output.put_line ('common_type_flag = '||l_common_type_flag);

    IF l_common_type_flag= 'Y' THEN

      BEGIN
       --get geography_element_column from structures
        SELECT distinct geography_element_column INTO l_geo_element_col
          FROM hz_geo_structure_levels
         WHERE geography_type = l_parent_object_type
           AND geography_id = (select geography_id from hz_geographies where country_code=
                              (select country_code from hz_geographies where geography_id=p_geography_id)
                                and geography_type = 'COUNTRY');  -- Bug4680789

		 l_geo_element_col_id := l_geo_element_col||'_id';
         l_geo_element_col_code := l_geo_element_col||'_CODE';

      EXCEPTION WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('TOKEN1', 'geography_element_column');
            FND_MESSAGE.SET_TOKEN('TOKEN2', 'geography_type :'||l_parent_object_type||'and for country_code of geography_id:'||p_geography_id);
            FND_MSG_PUB.ADD;

            RAISE FND_API.G_EXC_ERROR;
      END;
    END IF;
        --dbms_output.put_line ('geo_element_column is '||l_geo_element_col);

    -- check if all parents of geography_id have same parent
    SELECT count(distinct parent_id) INTO l_count
      FROM hz_hierarchy_nodes
     WHERE child_id in ( SELECT parent_id
                         FROM hz_hierarchy_nodes
                        WHERE child_id = p_geography_id
                         AND child_object_type = p_geography_type
           		         AND child_table_name = 'HZ_GEOGRAPHIES'
         		         AND hierarchy_type = 'MASTER_REF'
         		         AND NVL(status,'A') = 'A'
         		         AND (effective_end_date IS NULL
                              OR effective_end_date > sysdate)
         		         AND parent_id <> child_id
         		         AND level_number = 1)
       AND child_table_name = 'HZ_GEOGRAPHIES'
       AND hierarchy_type='MASTER_REF'
       AND (effective_end_date IS NULL
           OR effective_end_date > sysdate)
       AND parent_id <> child_id
       AND level_number = 1;

       --dbms_output.put_line('number of parents :'||to_char(l_count));
       IF l_count > 1 THEN
          l_common_parent_flag := 'N';
       ELSIF l_count = 1 THEN
          l_common_parent_flag := 'Y';
       END IF;

      -- remove the de-normalization  from the geography_id row and from all its children
      OPEN c_get_all_children;
      LOOP
      FETCH c_get_all_children INTO l_get_all_children;
      EXIT WHEN c_get_all_children%NOTFOUND;
        IF (l_common_type_flag ='N' or l_common_parent_flag = 'N') THEN
        -- nullify all the de-normalized columns
            -- Removed geography_element1 from update to NULL because any geography can not belong to
            -- multiple country, so, geography_element1 should not be set to null.
            -- Done for bug 3268961 on 04-Oct-2005
		  l_geography_element2 := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT2','NAME');
		  l_geography_element3 := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT3','NAME');
		  l_geography_element4 := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT4','NAME');
		  l_geography_element5 := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT5','NAME');
		  l_geography_element6 := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT6','NAME');
		  l_geography_element7 := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT7','NAME');
		  l_geography_element8 := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT8','NAME');
		  l_geography_element9 := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT9','NAME');
		  l_geography_element10 := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT10','NAME');
		  l_geography_element2_id := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT2','ID');
		  l_geography_element3_id := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT3','ID');
		  l_geography_element4_id := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT4','ID');
		  l_geography_element5_id := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT5','ID');
		  l_geography_element6_id := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT6','ID');
		  l_geography_element7_id := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT7','ID');
		  l_geography_element8_id := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT8','ID');
		  l_geography_element9_id := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT9','ID');
		  l_geography_element10_id := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT10','ID');
		  l_geography_element2_code := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT2','CODE');
		  l_geography_element3_code := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT3','CODE');
		  l_geography_element4_code := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT4','CODE');
		  l_geography_element5_code := multi_parent_update_val(l_get_all_children.child_id,'GEOGRAPHY_ELEMENT5','CODE');

           -- here assumption is record was created correctly. And we are only updating those fields which
           -- have multi parent to NULL.
           UPDATE HZ_GEOGRAPHIES
           -- SET multiple_parent_flag = decode(geography_id,p_geography_id,'Y',multiple_parent_flag),
           SET multiple_parent_flag = 'Y',
             -- geography_element1=NULL,
               geography_element2= DECODE(l_geography_element2,NULL,NULL,geography_element2),
               geography_element3= DECODE(l_geography_element3,NULL,NULL,geography_element3),
               geography_element4= DECODE(l_geography_element4,NULL,NULL,geography_element4),
               geography_element5= DECODE(l_geography_element5,NULL,NULL,geography_element5),
               geography_element6= DECODE(l_geography_element6,NULL,NULL,geography_element6),
               geography_element7= DECODE(l_geography_element7,NULL,NULL,geography_element7),
               geography_element8= DECODE(l_geography_element8,NULL,NULL,geography_element8),
               geography_element9= DECODE(l_geography_element9,NULL,NULL,geography_element9),
               geography_element10= DECODE(l_geography_element10,NULL,NULL,geography_element10),
             --  geography_element1_id=NULL,
               geography_element2_id= DECODE(l_geography_element2_id,NULL,NULL,geography_element2_id),
               geography_element3_id= DECODE(l_geography_element3_id,NULL,NULL,geography_element3_id),
               geography_element4_id= DECODE(l_geography_element4_id,NULL,NULL,geography_element4_id),
               geography_element5_id= DECODE(l_geography_element5_id,NULL,NULL,geography_element5_id),
               geography_element6_id= DECODE(l_geography_element6_id,NULL,NULL,geography_element6_id),
               geography_element7_id= DECODE(l_geography_element7_id,NULL,NULL,geography_element7_id),
               geography_element8_id= DECODE(l_geography_element8_id,NULL,NULL,geography_element8_id),
               geography_element9_id= DECODE(l_geography_element9_id,NULL,NULL,geography_element9_id),
               geography_element10_id= DECODE(l_geography_element10_id,NULL,NULL,geography_element10_id),
             --  geography_element1_code = NULL,
               geography_element2_code = DECODE(l_geography_element2_code,NULL,NULL,geography_element2_code),
               geography_element3_code = DECODE(l_geography_element3_code,NULL,NULL,geography_element3_code),
               geography_element4_code = DECODE(l_geography_element4_code,NULL,NULL,geography_element4_code),
               geography_element5_code = DECODE(l_geography_element5_code,NULL,NULL,geography_element5_code)
            WHERE geography_id=l_get_all_children.child_id;

         ELSE
          -- nullify the geography_element_column where the parent info of this geography_id is stored
            -- Removed geography_element1 from update to NULL because 1 geography can not belong to
            -- multiple country, so, geography_element1 should not be set to null.
            -- Done for bug 3268961 on 04-Oct-2005
            -- IF l_geo_element_col IN ('GEOGRAPHY_ELEMENT1','GEOGRAPHY_ELEMENT2','GEOGRAPHY_ELEMENT3','GEOGRAPHY_ELEMENT4','GEOGRAPHY_ELEMENT5') THEN
            IF l_geo_element_col IN ('GEOGRAPHY_ELEMENT2','GEOGRAPHY_ELEMENT3','GEOGRAPHY_ELEMENT4','GEOGRAPHY_ELEMENT5') THEN
              EXECUTE IMMEDIATE 'UPDATE hz_geographies SET multiple_parent_flag='||'''Y'''||','||l_geo_element_col||' = NULL,'||
                             l_geo_element_col_id||' = NULL,'||l_geo_element_col_code||'= NULL where geography_id = '||l_get_all_children.child_id;
            ELSIF l_geo_element_col IN ('GEOGRAPHY_ELEMENT6','GEOGRAPHY_ELEMENT7','GEOGRAPHY_ELEMENT8','GEOGRAPHY_ELEMENT9','GEOGRAPHY_ELEMENT10') THEN
              EXECUTE IMMEDIATE 'UPDATE hz_geographies SET multiple_parent_flag='||'''Y'''||','||l_geo_element_col||' = NULL,'||
                             l_geo_element_col_id||' = NULL where geography_id = '||l_get_all_children.child_id;
            END IF;
         END IF;
      END LOOP;
      CLOSE c_get_all_children;

 END remove_denorm;


 -- This procudure checks for the duplicate names for a child_id with in its parent
PROCEDURE check_duplicate_name(
   p_parent_id    IN NUMBER,
   p_child_id     IN NUMBER,
   p_child_name   IN VARCHAR2,
   p_child_type   IN VARCHAR2,
   p_child_identifier_subtype IN VARCHAR2,
   p_child_language IN VARCHAR2,
   x_return_status  IN OUT NOCOPY VARCHAR2
     ) IS

   l_count      NUMBER;

   BEGIN

   -- check if the name is duplicated with in the parent of p_child_id
   -- Added Subtype and language check for bug 4703418 on 28-Nov-2005 (Nishant)
   SELECT count(*) INTO l_count
     FROM hz_geography_identifiers
    WHERE identifier_type='NAME'
      AND identifier_subtype = p_child_identifier_subtype
      AND language_code = p_child_language
      AND UPPER(identifier_value) = UPPER(p_child_name)
      AND geography_id IN (SELECT object_id
                             FROM hz_relationships
                            WHERE subject_id = p_parent_id
                              AND object_type = p_child_type
                              AND status = 'A'
                              AND relationship_type = 'MASTER_REF');

    IF l_count > 0 THEN

       FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUPLICATE_VALUE');
       FND_MESSAGE.SET_TOKEN('IDENT_TYPE', 'NAME');
       FND_MESSAGE.SET_TOKEN('VALUE', p_child_name);
       FND_MESSAGE.SET_TOKEN('GEO_ID', p_child_id);
       FND_MESSAGE.SET_TOKEN('PARENT_GEO_ID', p_parent_id);
       FND_MSG_PUB.ADD;
       x_return_status := fnd_api.g_ret_sts_error;

     END IF;

END check_duplicate_name;

 -- This procudure checks for the duplicate code for a child_id with in its parent
PROCEDURE check_duplicate_code(
   p_parent_id    IN NUMBER,
   p_child_id     IN NUMBER,
   p_child_code   IN VARCHAR2,
   p_child_type   IN VARCHAR2,
   p_child_identifier_subtype IN VARCHAR2,
   p_child_language IN VARCHAR2,
   x_return_status  IN OUT NOCOPY VARCHAR2
     ) IS

   l_count      NUMBER;

   BEGIN

   -- check if the name is duplicated with in the parent of p_child_id
   -- Added Subtype and language check for bug 4703418 on 28-Nov-2005 (Nishant)
   SELECT count(*) INTO l_count
     FROM hz_geography_identifiers
    WHERE identifier_type='CODE'
      AND identifier_subtype = p_child_identifier_subtype
      AND language_code = p_child_language
      AND identifier_value = UPPER(p_child_code)
      AND geography_id IN (SELECT object_id
                             FROM hz_relationships
                            WHERE subject_id = p_parent_id
                              AND object_type = p_child_type
                              AND status = 'A'
                              AND relationship_type = 'MASTER_REF');

    IF l_count > 0 THEN

       FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUPLICATE_VALUE');
       FND_MESSAGE.SET_TOKEN('IDENT_TYPE', 'CODE');
       FND_MESSAGE.SET_TOKEN('VALUE', p_child_code);
       FND_MESSAGE.SET_TOKEN('GEO_ID', p_child_id);
       FND_MESSAGE.SET_TOKEN('PARENT_GEO_ID', p_parent_id);
       FND_MSG_PUB.ADD;
       x_return_status := fnd_api.g_ret_sts_error;

     END IF;

END check_duplicate_code;






/*===========================================================================+
 | PROCEDURE
 |
 |
 | DESCRIPTION
 |              Creates a relation between master geographies
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |                    p_master_relation_rec
 |              OUT:
 |                    x_relationship_id
 |                    x_return_status
 |
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |          11-22-02            o Rekha Nalluri created.
 |          07-04-07            o Neeraj Shinde. Bug#5393825
 |
 +===========================================================================*/

PROCEDURE do_create_master_relation(
    p_master_relation_rec       IN         MASTER_RELATION_REC_TYPE,
    x_relationship_id           OUT    NOCOPY    NUMBER,
    x_return_status             IN OUT NOCOPY       VARCHAR2
    ) IS

    l_relationship_rec          HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
    l_status                    VARCHAR2(1);
    l_parent_count              NUMBER;
    x_msg_count                 NUMBER;
    x_msg_data                  VARCHAR2(2000);
    l_geography_name            VARCHAR2(360);
    l_parent_geography_name     VARCHAR2(360);
    l_geography_type            VARCHAR2(30);
    l_geography_code            VARCHAR2(30);
    l_multiple_parent_flag      VARCHAR2(1);
    l_parent_geography_type     VARCHAR2(30);
    l_geo_element_col           VARCHAR2(30);
    x_party_id                  NUMBER;
    x_party_number              NUMBER;
    l_country_code              VARCHAR2(2);
    l_count                     NUMBER;

    --Parameters introduced for Bug#5393825 (Neeraj Shinde)
    l_identifier_subtype        VARCHAR2(30);
    l_language_code             VARCHAR2(4);


   BEGIN
   --dbms_output.put_line('before validate relation');
    -- validate master relation record for create
    HZ_GEOGRAPHY_VALIDATE_PVT.validate_master_relation(
      p_master_relation_rec          =>  p_master_relation_rec,
      p_create_update_flag           =>  'C',
      x_return_status                =>  x_return_status
      );

     --dbms_output.put_line('After validate relation '||x_return_status);
       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;


      -- get geography types for geography_id and parent_geography_id

     /*l_geography_type := HZ_GEOGRAPHY_VALIDATE_PVT.get_geography_type(p_geography_id =>p_master_relation_rec.geography_id,
                                                                      x_return_status => x_return_status);

     --dbms_output.put_line('geography_type in do_create_master_relation:'||l_geography_type);
      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;*/

     l_parent_geography_type := HZ_GEOGRAPHY_VALIDATE_PVT.get_geography_type(p_geography_id => p_master_relation_rec.parent_geography_id,
                                                                       x_return_status => x_return_status);

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     BEGIN
     -- check for the duplicate name/code with in the parent geography
     SELECT geography_name,geography_code,geography_type INTO
            l_geography_name,l_geography_code,l_geography_type
       FROM hz_geographies
      WHERE geography_id = p_master_relation_rec.geography_id;

  /*  -- Removed check for duplicate Name/Code on 05-Dec-2005 (Nishant) for bug 4703418
      -- This check is already done when identifier is created down the flow during
      -- identifier creation.*/

  /*  -- Introduced the validations to avoid child geographies with same name/code within
      -- a parent geography.
      -- Start of added section (Neeraj Shinde Bug# 5393825)    */

      IF l_geography_name IS NOT NULL THEN
      /*check_duplicate_name(p_parent_id => p_master_relation_rec.parent_geography_id,
                             p_child_id => p_master_relation_rec.geography_id,
                             p_child_name => l_geography_name,
                             p_child_type => l_geography_type,
                             x_return_status => x_return_status
                             ); */
       BEGIN
          SELECT identifier_subtype,language_code INTO
                 l_identifier_subtype,l_language_code
            FROM hz_geography_identifiers
           WHERE geography_id = p_master_relation_rec.geography_id
             AND identifier_type = 'NAME'
             AND primary_flag = 'Y'
             AND geography_use = 'MASTER_REF';

          check_duplicate_name(p_parent_id => p_master_relation_rec.parent_geography_id,
	                       p_child_id  => p_master_relation_rec.geography_id,
	                       p_child_name=> l_geography_name,
	                       p_child_type => l_geography_type,
	                       p_child_identifier_subtype => l_identifier_subtype,
	                       p_child_language =>  l_language_code,
	                       x_return_status => x_return_status
                              );
       EXCEPTION
         WHEN no_data_found THEN
         -- The geography identifiers are not yet created
            NULL;
       END;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
         RAISE FND_API.G_EXC_ERROR;
       END IF;
     END IF;

     IF l_geography_code IS NOT NULL THEN
     /*
      check_duplicate_code(p_parent_id => p_master_relation_rec.parent_geography_id,
                             p_child_id => p_master_relation_rec.geography_id,
                             p_child_code => l_geography_code,
                             p_child_type => l_geography_type,
                             x_return_status => x_return_status
                             ); */
       BEGIN
         SELECT identifier_subtype,language_code INTO
                l_identifier_subtype,l_language_code
           FROM hz_geography_identifiers
          WHERE geography_id = p_master_relation_rec.geography_id
            AND identifier_type = 'CODE'
            AND primary_flag = 'Y'
            AND geography_use = 'MASTER_REF';

         check_duplicate_code(p_parent_id => p_master_relation_rec.parent_geography_id,
                              p_child_id  => p_master_relation_rec.geography_id,
                              p_child_code => l_geography_code,
                              p_child_type => l_geography_type,
                              p_child_identifier_subtype => l_identifier_subtype,
                              p_child_language =>  l_language_code,
                              x_return_status => x_return_status
                             );
       EXCEPTION
          WHEN no_data_found THEN
          -- The geography identifiers are not yet created.
             NULL;
       END;

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
       END IF;
    END IF;

    -- End of added section (Neeraj Shinde Bug# 5393825)

   EXCEPTION when no_data_found THEN
          fnd_message.set_name('AR', 'HZ_GEO_NO_RECORD');
          fnd_message.set_token('TOKEN1','Geography record');
          fnd_message.set_token('TOKEN2','geography_id '||p_master_relation_rec.geography_id);
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
    END;
         -- a geography can not have two countries as its parents
     IF l_parent_geography_type = 'COUNTRY' THEN

       SELECT count(*) INTO l_count FROM HZ_HIERARCHY_NODES
        WHERE hierarchy_type='MASTER_REF'
          AND child_id=p_master_relation_rec.geography_id
          AND parent_object_type='COUNTRY'
          AND NVL(status,'A') = 'A'
          AND level_number = 1;

          IF l_count > 0 THEN
            fnd_message.set_name('AR', 'HZ_GEO_MULTIPLE_COUNTRIES');
          fnd_message.set_token('GEO_ID', p_master_relation_rec.geography_id);
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
     END IF;


    -- construct the relationship_rec
    l_relationship_rec.subject_id := p_master_relation_rec.parent_geography_id;
    l_relationship_rec.subject_type := l_parent_geography_type;
    l_relationship_rec.subject_table_name :='HZ_GEOGRAPHIES';
    l_relationship_rec.object_id := p_master_relation_rec.geography_id;
    l_relationship_rec.object_type :=l_geography_type;
    l_relationship_rec.object_table_name := 'HZ_GEOGRAPHIES';
    l_relationship_rec.relationship_code  := 'PARENT_OF';
    l_relationship_rec.relationship_type  := 'MASTER_REF';
    l_relationship_rec.start_date := p_master_relation_rec.start_date;
    l_relationship_rec.end_date := p_master_relation_rec.end_date;
    l_relationship_rec.status   := 'A';
    l_relationship_rec.created_by_module := p_master_relation_rec.created_by_module;
    l_relationship_rec.application_id    := p_master_relation_rec.application_id;

    --dbms_output.put_line('After constructing the master relation record');

    -- call to relationship API to create a relationship
   HZ_RELATIONSHIP_V2PUB.create_relationship(
    p_init_msg_list             => 'F',
    p_relationship_rec          => l_relationship_rec,
    x_relationship_id           => x_relationship_id,
    x_party_id                  => x_party_id,
    x_party_number              => x_party_number,
    x_return_status             => x_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data,
    p_create_org_contact        => 'N'
       );
   --dbms_output.put_line('x_return_status is '||x_return_status);
   --dbms_output.put_line('relationship_id is '||x_relationship_id);

        ----dbms_output.put_line('parent_id is '||to_char(l_parent_count));

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    ----dbms_output.put_line('relationship_id is '||to_char(x_relationship_id));

   -- check whether this geography_id has multiple parents
     SELECT count(subject_id) INTO l_parent_count
       FROM HZ_RELATIONSHIPS
      WHERE object_id = p_master_relation_rec.geography_id
        AND object_type=l_geography_type
        AND object_table_name='HZ_GEOGRAPHIES'
        AND subject_table_name = 'HZ_GEOGRAPHIES'
        AND relationship_type='MASTER_REF'
        AND relationship_code = 'PARENT_OF'
        AND status = 'A'
        AND rownum <3;


      -- in case of single parent , denormalize the relationship in HZ_GEOGRAPHIES for this geography_id
      IF l_parent_count = 1 THEN

      --dbms_output.put_line ('before denormalize relation');
      denormalize_relation(
        p_geography_id     => p_master_relation_rec.geography_id,
        p_parent_geography_id => p_master_relation_rec.parent_geography_id,
        p_geography_type   => l_geography_type,
        x_return_status    => x_return_status
        );
        --dbms_output.put_line ('after denormalize relation');


       ELSIF l_parent_count > 1 THEN

         --dbms_output.put_line ('before call to remove denormalize');
        -- In case of multiple parents see if the multiple parents have same parent.If yes,remove denormalization
        -- of the immediate parent information(in that particular geo_element column)for this geography and for all its
        -- children. If no,then nullify the de-normalization in all the geo_element columns for this geography and for
        -- all its children.

        remove_denorm(
         p_geography_id  => p_master_relation_rec.geography_id,
         p_geography_type => l_geography_type
         );

        END IF;

 END do_create_master_relation;

 /*===========================================================================+
 | PROCEDURE
 |
 |
 | DESCRIPTION
 |              Updates a relation between master geographies
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |                    p_master_relation_rec
 |                    p_object_version_number
 |              OUT:
 |
 |                    x_return_status
 |
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |          11-22-02            o Rekha Nalluri created.
 |
 +===========================================================================*/

 PROCEDURE do_update_relationship(
        p_relationship_id               IN NUMBER,
        p_status                        IN VARCHAR2,
        p_object_version_number         IN OUT NOCOPY NUMBER,
        x_return_status                 IN OUT NOCOPY VARCHAR2
       ) IS

       l_relationship_rec               HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
       x_msg_count                      NUMBER;
       x_msg_data                       VARCHAR2(2000);
       l_party_object_version_number     NUMBER := NULL;
       l_parent_count                    NUMBER;
       l_geography_type                  VARCHAR2(30);
       l_update_flag                     VARCHAR2(1);
       l_denorm_flag                     VARCHAR2(1);
       l_geography_id                    NUMBER;
       l_parent_geography_id             NUMBER;
       l_end_date                        DATE;
       l_count                           NUMBER;
       l_relationship_type               VARCHAR2(30);
       --p_subject_flag                    VARCHAR2(1);
       CURSOR c_get_all_children IS
         SELECT child_id, child_object_type
           FROM hz_hierarchy_nodes
          WHERE hierarchy_type='MASTER_REF'
            AND parent_id=l_geography_id
            AND child_table_name = 'HZ_GEOGRAPHIES'
            AND NVL(status,'A') = 'A'
            AND (effective_end_date IS NULL
            OR effective_end_date > sysdate)
            AND (level_number = 1
             OR parent_id = child_id);
      l_get_all_children        c_get_all_children%ROWTYPE;
      l_remove_denorm_flag      VARCHAR2(1);
  BEGIN

     hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'U',
          p_column                 => 'object_version_number',
          p_column_value           => p_object_version_number,
          x_return_status          => x_return_status
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;

       BEGIN
       -- validate relationship_id
      SELECT subject_id,object_id,relationship_type into l_parent_geography_id,l_geography_id,l_relationship_type
      FROM hz_relationships
     WHERE relationship_id = p_relationship_id
       AND relationship_code = 'PARENT_OF';

      EXCEPTION WHEN NO_DATA_FOUND  THEN
         fnd_message.set_name('AR', 'HZ_GEO_NO_RECORD');
          fnd_message.set_token('token1', 'relationship');
          fnd_message.set_token('token1', 'relationship_id '||p_relationship_id);
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
         END;

      --dbms_output.put_line('after master relation validation');

    IF p_status = 'I' THEN
     l_end_date := sysdate;
     ELSIF p_status = 'A' THEN
     l_end_date := to_date('31-12-4712','DD-MM-YYYY');
    END IF;


     ----dbms_output.put_line('l_end_date is '|| to_char(l_end_date));
    l_geography_type := HZ_GEOGRAPHY_VALIDATE_PVT.get_geography_type(
                          p_geography_id    => l_geography_id,
                          x_return_status => x_return_status);

    ----dbms_output.put_line('after getting geography type '||l_geography_type);
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

   -- construct the relationship record for update
    l_relationship_rec.relationship_id := p_relationship_id;
    l_relationship_rec.start_date := NULL;
    l_relationship_rec.end_date := l_end_date;
    l_relationship_rec.status := p_status;
    l_relationship_rec.created_by_module := NULL;
    l_relationship_rec.application_id := NULL;

     IF l_relationship_type <> 'MASTER_REF' THEN
      HZ_RELATIONSHIP_V2PUB.update_relationship(
    p_init_msg_list               =>'F',
    p_relationship_rec            =>     l_relationship_rec,
    p_object_version_number       =>     p_object_version_number,
    p_party_object_version_number =>     l_party_object_version_number,
    x_return_status               =>     x_return_status,
    x_msg_count                   =>     x_msg_count,
    x_msg_data                    =>     x_msg_data
);

  ELSE


     BEGIN
      -- check whether there exists atleast one parent for this child before end dating this relation
     SELECT count(subject_id) INTO l_parent_count
       FROM HZ_RELATIONSHIPS
      WHERE object_id = l_geography_id
        AND object_type=l_geography_type
        AND object_table_name='HZ_GEOGRAPHIES'
        AND subject_table_name = 'HZ_GEOGRAPHIES'
        AND relationship_type='MASTER_REF'
        AND relationship_code = 'PARENT_OF'
        AND status = 'A';

        --dbms_output.put_line('l_parent_count '|| to_char(l_parent_count));
     EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_NO_RECORD' );
         FND_MESSAGE.SET_TOKEN( 'TOKEN1', 'Relationship');
         FND_MESSAGE.SET_TOKEN( 'TOKEN2', 'object_id '||l_geography_id||',object_type '||l_geography_type||' and relationship_type MASTER_REF');
         FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
        END;


      -- if there exists only one parent then do not update
      IF (l_parent_count = 1 AND p_status = 'I')  THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_SINGLE_PARENT' );
         FND_MESSAGE.SET_TOKEN( 'REL_ID', p_relationship_id);
         FND_MESSAGE.SET_TOKEN( 'GEO_ID', l_geography_id);
         FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
         --l_update_flag := 'N';
      END IF;
        ----dbms_output.put_line ('parent_count '||to_char(l_parent_count));
        IF (l_parent_count = 2 AND p_status= 'I') THEN
        l_update_flag := 'Y';
         l_denorm_flag := 'Y';
         ELSIF (l_parent_count = 1 AND p_status = 'A') THEN
          l_update_flag := 'Y';
          l_remove_denorm_flag := 'Y';
        ELSIF l_parent_count > 2  THEN
           l_update_flag := 'Y';
           --l_remove_denorm_flag := 'Y';
           END IF;
       ----dbms_output.put_line('l_update_flag '||l_update_flag);

  IF l_update_flag = 'Y' THEN
    -- call relationship API for update
    HZ_RELATIONSHIP_V2PUB.update_relationship(
    p_init_msg_list               =>'F',
    p_relationship_rec            =>     l_relationship_rec,
    p_object_version_number       =>     p_object_version_number,
    p_party_object_version_number =>     l_party_object_version_number,
    x_return_status               =>     x_return_status,
    x_msg_count                   =>     x_msg_count,
    x_msg_data                    =>     x_msg_data
);

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
  END IF;


  IF l_denorm_flag = 'Y' THEN

  -- means there is only one parent left. So set the multiple_parent_flag to 'N' for the geography_id and
  -- de-normalize this relation in HZ_GEOGRAPHIES for the geography_id and for all its children.

    UPDATE hz_geographies
       SET multiple_parent_flag = 'N'
     WHERE geography_id = l_geography_id;

    OPEN c_get_all_children;
     LOOP
     FETCH c_get_all_children into l_get_all_children;
     EXIT WHEN c_get_all_children%NOTFOUND;

        -- call the procedure to denormalize
        denormalize_relation(
        p_geography_id     => l_get_all_children.child_id,
        p_parent_geography_id => l_geography_id,
        p_geography_type => l_get_all_children.child_object_type,
        x_return_status => x_return_status
        );

      -- de-normalize the relation in the children of geography_id too

      END LOOP;
        CLOSE c_get_all_children;
     END IF;

     IF l_remove_denorm_flag = 'Y' THEN
     -- set the multiple parent flag for this geography_id to 'Y'
     UPDATE hz_geographies
        SET multiple_parent_flag = 'Y'
      WHERE geography_id = l_geography_id;

       remove_denorm(
         p_geography_id  => l_geography_id,
         p_geography_type => l_geography_type);
      END IF;
   END IF;
END do_update_relationship;

 /*===========================================================================+
 | PROCEDURE
 |              3
 |
 | DESCRIPTION
 |              Creates a Geography Identifier
 |
 | SCOPE - PRIVATE
 |
 | EXETERNAL PROCEDURES/FUNCTIONS ACCESSED
 |
 | ARGUMENTS  : IN:
 |
 |                    p_geo_identifier_rec
 |              OUT:
 |                    x_return_status
 |
 |          IN/ OUT:
 |
 | RETURNS    : NONE
 |
 | NOTES
 |
 | MODIFICATION HISTORY
 |          12-03-02            o Rekha Nalluri created.
 |          07-25-05            o Idris Ali    Bug 4493925: language code is
 |                                  assinged a default value when it has a null value
 +===========================================================================*/

 PROCEDURE do_create_geo_identifier(
   p_geo_identifier_rec      IN  GEO_IDENTIFIER_REC_TYPE,
   x_return_status           IN OUT NOCOPY VARCHAR2
   ) IS

    l_rowid		VARCHAR2(64);
    l_geography_use     VARCHAR2(30);
    l_geography_type    VARCHAR2(30);
    l_geography_id      NUMBER;
    l_identifier_value  VARCHAR2(360);
    l_geo_element_col   VARCHAR2(30);
    l_country_code      VARCHAR2(2);
    l_count             NUMBER;
    --l_stmnt             VARCHAR2(1000);
    l_geo_element_code  VARCHAR2(30);
    l_identifier_subtype VARCHAR2(30);
    l_geo_element_id     VARCHAR2(30);
    l_language_code      VARCHAR2(4);
    CURSOR c_get_all_parents IS
     SELECT subject_id
       FROM hz_relationships
      WHERE object_id = p_geo_identifier_rec.geography_id
        AND relationship_type = 'MASTER_REF'
        AND status = 'A';
     l_get_all_parents     c_get_all_parents%ROWTYPE;

    BEGIN

      l_geography_id := p_geo_identifier_rec.geography_id;

	  IF p_geo_identifier_rec.identifier_type = 'CODE' THEN
        l_identifier_value := UPPER(p_geo_identifier_rec.identifier_value);
      ELSE
        l_identifier_value := p_geo_identifier_rec.identifier_value;
      END IF;

      -- Bug 4493925: default language_code in case of NULL

      IF p_geo_identifier_rec.language_code IS NULL THEN
        l_language_code := userenv('LANG');
      ELSE
        l_language_code := p_geo_identifier_rec.language_code;
      END IF;

      -- Bug 4493925: default language_code in case of NULL

      -- construct the statement to de-normalize the identifier wherever it is used in hz_geographies

      l_identifier_subtype := p_geo_identifier_rec.identifier_subtype;
      --dbms_output.put_line ('Before validate geo identifier');


      -- validate geography identifier record for create
      HZ_GEOGRAPHY_VALIDATE_PVT.validate_geo_identifier(
      p_geo_identifier_rec     => p_geo_identifier_rec,
      p_create_update_flag     => 'C',
      x_return_status          => x_return_status
      );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- check for the duplicate name and code


     -- get geography_type and geography_use
     BEGIN

       SELECT geography_use,geography_type INTO l_geography_use,l_geography_type
         FROM HZ_GEOGRAPHIES
        WHERE geography_id = p_geo_identifier_rec.geography_id;

     EXCEPTION when no_data_found THEN
          fnd_message.set_name('AR', 'HZ_GEO_NO_RECORD');
          fnd_message.set_token('TOKEN1','Geography record');
          fnd_message.set_token('TOKEN2','geography_id '||p_geo_identifier_rec.geography_id);
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
     END;

     IF l_geography_use = 'MASTER_REF' THEN
      IF l_geography_type <> 'COUNTRY' THEN
      -- check for the duplicate name/code with in the parents of the geography
      OPEN c_get_all_parents;
      LOOP
        FETCH c_get_all_parents INTO l_get_all_parents;
        EXIT WHEN c_get_all_parents%NOTFOUND;
        IF p_geo_identifier_rec.identifier_type = 'NAME' THEN
          check_duplicate_name(p_parent_id => l_get_all_parents.subject_id,
                               p_child_id  => p_geo_identifier_rec.geography_id,
                               p_child_name=> p_geo_identifier_rec.identifier_value,
                               p_child_type => l_geography_type,
                               p_child_identifier_subtype => l_identifier_subtype,
                               p_child_language =>  l_language_code,
                               x_return_status => x_return_status
                               );
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
              EXIT;
            END IF;
         ELSIF  p_geo_identifier_rec.identifier_type = 'CODE' THEN
          check_duplicate_code(p_parent_id => l_get_all_parents.subject_id,
                               p_child_id  => p_geo_identifier_rec.geography_id,
                               p_child_code => p_geo_identifier_rec.identifier_value,
                               p_child_type => l_geography_type,
                               p_child_identifier_subtype => l_identifier_subtype,
                               p_child_language =>  l_language_code,
                               x_return_status => x_return_status
                               );

            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
              EXIT;
            END IF;
         END IF;
       END LOOP;
       CLOSE c_get_all_parents;
      ELSE
      -- Bug 5411429 : check for the duplicate name/code for Country geographies.
           SELECT count(*) INTO l_count
            FROM  hz_geography_identifiers
            WHERE  identifier_type = p_geo_identifier_rec.identifier_type
            AND  identifier_subtype = l_identifier_subtype
            AND  language_code = p_geo_identifier_rec.language_code
            AND  UPPER(identifier_value) = UPPER(p_geo_identifier_rec.identifier_value)
            AND  geography_type = 'COUNTRY';

           IF l_count > 0 THEN
             FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_COUNTRY_IDEN');
             FND_MESSAGE.SET_TOKEN('IDEN_VAL', p_geo_identifier_rec.identifier_value);
             FND_MSG_PUB.ADD;
            x_return_status := fnd_api.g_ret_sts_error;
            RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;

      END IF;

      -- Primary name should be of subtype 'STANDARD_NAME'
       IF (p_geo_identifier_rec.identifier_type = 'NAME' AND p_geo_identifier_rec.primary_flag = 'Y') THEN
        IF p_geo_identifier_rec.identifier_subtype <> 'STANDARD_NAME' THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_INVALID_SUBTYPE' );
         FND_MESSAGE.SET_TOKEN( 'SUBTYPE', p_geo_identifier_rec.identifier_subtype);
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
        END IF;
      END IF;

      -- If this is the first row for the language_code for type NAME then if it is of subtype other than STANDAR_NAME,
	  -- , make it as STANDARD_NAME

      IF (p_geo_identifier_rec.identifier_type = 'NAME' AND p_geo_identifier_rec.identifier_subtype <> 'STANDARD_NAME') THEN

       SELECT count(*) INTO l_count from
              hz_geography_identifiers
          WHERE geography_id = p_geo_identifier_rec.geography_id
            AND language_code = l_language_code;

        IF l_count = 0 THEN
         l_identifier_subtype:= 'STANDARD_NAME';
        END IF;
      END IF;

      IF p_geo_identifier_rec.primary_flag = 'Y' THEN
        IF (p_geo_identifier_rec.identifier_type='NAME' AND p_geo_identifier_rec.identifier_subtype = 'STANDARD_NAME') THEN
          -- check if there exists a STANDARD_NAME + Primary Flag = Y
          SELECT count(*) INTO l_count
            FROM hz_geography_identifiers
           WHERE geography_id = p_geo_identifier_rec.geography_id
             AND identifier_type = 'NAME'
             AND identifier_subtype = 'STANDARD_NAME'
             AND primary_flag = 'Y'
             AND language_code = l_language_code;

          IF l_count > 0 THEN
           -- update STANDARD_NAME+Y to STANDARD_NAME+N
           UPDATE hz_geography_identifiers
              SET primary_flag = 'N'
            WHERE geography_id = p_geo_identifier_rec.geography_id
              AND identifier_type = 'NAME'
              AND identifier_subtype = 'STANDARD_NAME'
              AND primary_flag = 'Y'
              AND language_code = l_language_code;
          END IF;

         l_identifier_subtype := 'STANDARD_NAME';
       END IF;

       --check if there exists a primary row already for this geography_id
       SELECT count(*) INTO l_count
         FROM HZ_GEOGRAPHY_IDENTIFIERS
        WHERE geography_id = p_geo_identifier_rec.geography_id
          AND identifier_type = p_geo_identifier_rec.identifier_type
          AND primary_flag='Y';

        IF l_count > 0 THEN
          -- set the primary_flag of the existing primary identifier to 'N'
          UPDATE hz_geography_identifiers
             SET primary_flag = 'N'
           WHERE geography_id=p_geo_identifier_rec.geography_id
             AND identifier_type = p_geo_identifier_rec.identifier_type
             AND primary_flag = 'Y';

        END IF;
      END IF;

      ----dbms_output.put_line('before identifier insert');

     -- call table handler to insert the row in hz_geography_identifiers

   HZ_GEOGRAPHY_IDENTIFIERS_PKG.insert_row(
    x_rowid                                 =>  l_rowid,
    x_geography_id                          =>  p_geo_identifier_rec.geography_id,
    x_identifier_subtype                    =>  l_identifier_subtype,
    x_identifier_value                      =>  l_identifier_value,
    x_geo_data_provider                     =>  p_geo_identifier_rec.geo_data_provider,
    x_object_version_number                 =>  1,
    x_identifier_type                       =>  p_geo_identifier_rec.identifier_type,
    x_primary_flag                          =>  p_geo_identifier_rec.primary_flag,
    x_language_code                         =>  UPPER(l_language_code),
    x_geography_use                         =>  l_geography_use,
    x_geography_type                        =>  UPPER(l_geography_type),
    x_created_by_module                     =>  p_geo_identifier_rec.created_by_module,
    x_application_id                        =>  p_geo_identifier_rec.application_id,
    x_program_login_id                      => NULL
        );

    ----dbms_output.put_line('after identifier insert');

    IF (l_geography_type <> 'COUNTRY' AND l_geography_use = 'MASTER_REF') THEN
    BEGIN
     --get geography_element_column,country_code from hz_geo_structure_levels for this geography_id
     --dbms_output.put_line('before getting geo_element_column l_geography_id '||l_geography_id);

     SELECT distinct geography_element_column,country_code
     INTO l_geo_element_col,l_country_code
      FROM HZ_GEO_STRUCTURE_LEVELS
     WHERE geography_id = (SELECT geography_id FROM
                           HZ_GEOGRAPHIES WHERE COUNTRY_CODE=(SELECT country_code from hz_geographies
                                                                 WHERE geography_id = l_geography_id)
                                            AND geography_type='COUNTRY')
       AND geography_type = l_geography_type;
        l_geo_element_code := l_geo_element_col||'_CODE';
        l_geo_element_id := l_geo_element_col||'_ID';
      --dbms_output.put_line('after getting geo_element_column'||l_geo_element_col);
     EXCEPTION
        WHEN NO_DATA_FOUND THEN
         --dbms_output.put_line('in the error');
            FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_RECORD');
            FND_MESSAGE.SET_TOKEN('TOKEN1', 'geography structure level');
       FND_MESSAGE.SET_TOKEN('TOKEN2', 'geography_id: '||to_char(l_count)||',country_code: '||l_country_code||',geography_type: '||l_geography_type);
       FND_MSG_PUB.ADD;
          x_return_status := FND_API.G_RET_STS_ERROR;
     END;
   END IF;


    -- denormalize the primary identifier in HZ_GEOGRAPHIES for identifier_type='NAME' and 'CODE'
    -- for this geography_id
    IF p_geo_identifier_rec.primary_flag = 'Y' THEN
    IF p_geo_identifier_rec.identifier_type='CODE' THEN
--  Bug 4591502 : ISSUE # 17
--  Do not denormalize identfier code in country_code
/*    IF l_geography_type = 'COUNTRY' THEN
    UPDATE HZ_GEOGRAPHIES
       SET geography_code = p_geo_identifier_rec.identifier_value,
           country_code = p_geo_identifier_rec.identifier_value
     WHERE geography_id = p_geo_identifier_rec.geography_id;

     ELSE
*/
      UPDATE HZ_GEOGRAPHIES
--  Bug 4579868 : ISSUE # 11
--  denormalize upper code and not identifier_value directly
--       SET geography_code = p_geo_identifier_rec.identifier_value
       SET geography_code = l_identifier_value
     WHERE geography_id = p_geo_identifier_rec.geography_id;
--     END IF;

     IF l_geo_element_col IS NOT NULL THEN
     ----dbms_output.put_line('after update, before de-normaloizing code');
     IF l_geo_element_col IN ('GEOGRAPHY_ELEMENT1','GEOGRAPHY_ELEMENT2','GEOGRAPHY_ELEMENT3','GEOGRAPHY_ELEMENT4','GEOGRAPHY_ELEMENT5') THEN
     EXECUTE IMMEDIATE 'UPDATE HZ_GEOGRAPHIES SET '||l_geo_element_code||'= :l_identifier_value '||
                 ' WHERE country_code= :l_country_code '||
                 ' AND '||l_geo_element_id||'= :l_geography_id '
				 USING l_identifier_value, l_country_code, l_geography_id;

     END IF;

     --dbms_output.put_line('After first execute');

     END IF;
      END IF;
   -- END IF;
    ----dbms_output.put_line('l_stmnt is '||l_stmnt);
    ----dbms_output.put_line('after de-normaloizing code');
    IF  p_geo_identifier_rec.identifier_type='NAME' THEN
     UPDATE HZ_GEOGRAPHIES
        SET geography_name = p_geo_identifier_rec.identifier_value
      WHERE geography_id = p_geo_identifier_rec.geography_id;
      IF l_geo_element_col IS NOT NULL THEN
      EXECUTE IMMEDIATE 'UPDATE HZ_GEOGRAPHIES SET '||l_geo_element_col||'= :l_identifier_value '||
                 ' WHERE country_code= :l_country_code '||
                 ' AND '||l_geo_element_id||'= :l_geography_id '
				 USING l_identifier_value, l_country_code, l_geography_id;

      END IF;
      --dbms_output.put_line('After second execute');
    END IF;
    ----dbms_output.put_line('after de-normaloizing name');
    END IF;


 END do_create_geo_identifier;


 -- update geography identifier procedure
 PROCEDURE do_update_geo_identifier(
        p_geo_identifier_rec            IN GEO_IDENTIFIER_REC_TYPE,
        p_object_version_number         IN OUT NOCOPY NUMBER,
        x_cp_request_id                 OUT    NOCOPY   NUMBER,
        x_return_status                 IN OUT NOCOPY VARCHAR2
       )IS

       l_count         NUMBER;
       l_rowid         VARCHAR2(64);
       l_geography_use VARCHAR2(30);
       l_geography_type VARCHAR2(30);
       l_geo_element_col VARCHAR2(30);
       l_country_code  VARCHAR2(2);
      -- l_stmnt         VARCHAR2(1000);
       l_geo_element_code VARCHAR2(30);
       l_geo_element_id   VARCHAR2(30);
       l_old_primary_flag VARCHAR2(1);
       l_geo_identifier_subtype VARCHAR2(30);
       l_object_version_number  NUMBER;

       l_new_geo_subtype VARCHAR2(30);
       l_new_geo_value   VARCHAR2(360);
       l_subtype_updated VARCHAR2(1);
       l_name_updated    VARCHAR2(1);

       CURSOR c_get_all_parents IS
        SELECT subject_id
        FROM   hz_relationships
        WHERE  object_id = p_geo_identifier_rec.geography_id
          AND  object_table_name = 'HZ_GEOGRAPHIES'
          AND  relationship_type = 'MASTER_REF'
          AND  status = 'A';

       l_get_all_parents     c_get_all_parents%ROWTYPE;

   BEGIN

       l_geo_identifier_subtype := p_geo_identifier_rec.identifier_subtype;

       HZ_GEOGRAPHY_VALIDATE_PVT.validate_geo_identifier(
         p_geo_identifier_rec    => p_geo_identifier_rec,
         p_create_update_flag     => 'U',
         x_return_status         => x_return_status
         );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'U',
          p_column                 => 'object_version_number',
          p_column_value           => p_object_version_number,
          x_return_status          => x_return_status
          );
         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
            RAISE FND_API.G_EXC_ERROR;
         END IF;

         BEGIN

	       SELECT rowid,geography_type,geography_use,primary_flag,object_version_number
	       INTO l_rowid,l_geography_type,l_geography_use,l_old_primary_flag,l_object_version_number
	       FROM hz_geography_identifiers
	       WHERE geography_id = p_geo_identifier_rec.geography_id
	         AND identifier_type = p_geo_identifier_rec.identifier_type
	         AND identifier_subtype = p_geo_identifier_rec.identifier_subtype
	         AND identifier_value = p_geo_identifier_rec.identifier_value
	         AND language_code = p_geo_identifier_rec.language_code
	         FOR UPDATE of geography_id NOWAIT;

  	       --validate object_version_number
	       IF l_object_version_number <> p_object_version_number THEN
	            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
	            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_geography_identifiers');
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
	        ELSE
	         p_object_version_number := l_object_version_number + 1;
	       END IF;

 	     EXCEPTION WHEN NO_DATA_FOUND THEN
	            FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_NO_RECORD' );
	            FND_MESSAGE.SET_TOKEN('TOKEN1', 'geography_identifier');
	            FND_MESSAGE.SET_TOKEN('TOKEN2', 'geography_id: '||p_geo_identifier_rec.geography_id||', identifier_type: '||
	                                    p_geo_identifier_rec.identifier_type||', identifier_subtype: '||p_geo_identifier_rec.identifier_subtype||', identifier_value: '||
	                                    p_geo_identifier_rec.identifier_value||', language_code: '||p_geo_identifier_rec.language_code);
	            FND_MSG_PUB.ADD;
	            RAISE FND_API.G_EXC_ERROR;
        END;

       -- Validate new subtype. Update only if valid and geo type is CODE.
       IF (p_geo_identifier_rec.identifier_type = 'CODE') THEN
         l_new_geo_subtype        := p_geo_identifier_rec.new_identifier_subtype;
         -- validate new subtype
         IF (l_new_geo_subtype IS NOT NULL) THEN
             HZ_UTILITY_V2PUB.validate_lookup(
             p_column           => 'geography_code_type',
             p_lookup_type      => 'HZ_GEO_IDENTIFIER_SUBTYPE',
             p_column_value     => l_new_geo_subtype,
             x_return_status    => x_return_status
            );
           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
              RAISE FND_API.G_EXC_ERROR;
           END IF;
           l_subtype_updated := 'Y';
		 ELSE -- new geo subtype is null (i.e. no need to update), use the old subtype
		   l_new_geo_subtype :=  l_geo_identifier_subtype;
		   l_subtype_updated := 'N';
         END IF;
       ELSE -- if idenifier type is NAME (only 1 subtype 'STANDARD_NAME' is allowed)
         l_new_geo_subtype        := p_geo_identifier_rec.new_identifier_subtype;
         -- validate new subtype
         IF (l_new_geo_subtype IS NOT NULL) THEN
           IF (p_geo_identifier_rec.new_identifier_subtype <> 'STANDARD_NAME') THEN
              FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_INVALID_LOOKUP' );
              FND_MESSAGE.SET_TOKEN( 'COLUMN', 'identifier_subtype' );
              FND_MESSAGE.SET_TOKEN( 'LOOKUP_TYPE', 'HZ_GEO_IDENTIFIER_SUBTYPE' );
              FND_MSG_PUB.ADD;
              x_return_status := FND_API.G_RET_STS_ERROR;
           END IF;
           l_subtype_updated := 'Y';
	     ELSE -- new geo subtype is null (i.e. no need to update), use the old subtype
		   l_new_geo_subtype :=  l_geo_identifier_subtype;
		   l_subtype_updated := 'N';
	     END IF;
       END IF;

       -- Validate new identifier value (it will be NULL if it is not to be updated)
       IF (p_geo_identifier_rec.new_identifier_value IS NOT NULL) THEN
	     IF p_geo_identifier_rec.identifier_type = 'CODE' THEN
           l_new_geo_value := UPPER(p_geo_identifier_rec.new_identifier_value);
         ELSE
           l_new_geo_value := p_geo_identifier_rec.new_identifier_value;
         END IF;
         l_name_updated := 'Y';
       ELSE -- not to be updated, so retain the old value
         l_new_geo_value := p_geo_identifier_rec.identifier_value;
         l_name_updated := 'N';
       END IF;

       -- check if name is duplicate within its parents
        IF (l_name_updated = 'Y') THEN
	  	   IF l_geography_use = 'MASTER_REF' THEN
                    IF l_geography_type <> 'COUNTRY' THEN
	        -- check for the duplicate name/code with in the parents of the geography
	        OPEN c_get_all_parents;
	        LOOP
	          FETCH c_get_all_parents INTO l_get_all_parents;
	          EXIT WHEN c_get_all_parents%NOTFOUND;
	          IF p_geo_identifier_rec.identifier_type = 'NAME' THEN
			   -- check if the name is duplicated with in the parent of p_child_id
               -- Added Subtype and language check for bug 4703418 on 28-Nov-2005 (Nishant)
			   SELECT count(*) INTO l_count
			     FROM hz_geography_identifiers
			    WHERE identifier_type='NAME'
			      AND identifier_subtype = l_new_geo_subtype
			      AND language_code = p_geo_identifier_rec.language_code
			      AND UPPER(identifier_value) = UPPER(l_new_geo_value)
			      AND geography_id IN (SELECT object_id
			                             FROM hz_relationships
			                            WHERE subject_id = l_get_all_parents.subject_id
			                              AND object_type = l_geography_type
			                              AND status = 'A'
			                              AND relationship_type = 'MASTER_REF')
				  AND ROWID <> l_rowid ;

			    IF l_count > 0 THEN

			       FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUPLICATE_VALUE');
			       FND_MESSAGE.SET_TOKEN('IDENT_TYPE', 'NAME');
			       FND_MESSAGE.SET_TOKEN('VALUE', l_new_geo_value);
			       FND_MESSAGE.SET_TOKEN('GEO_ID', p_geo_identifier_rec.geography_id);
			       FND_MESSAGE.SET_TOKEN('PARENT_GEO_ID', l_get_all_parents.subject_id);
			       FND_MSG_PUB.ADD;
			       x_return_status := fnd_api.g_ret_sts_error;
	               RAISE FND_API.G_EXC_ERROR;
	               EXIT;
 	            END IF;
	          ELSIF  p_geo_identifier_rec.identifier_type = 'CODE' THEN
			    -- check if the name is duplicated with in the parent of p_child_id
			    -- Added Subtype and language check for bug 4703418 on 28-Nov-2005 (Nishant)
			    SELECT count(*) INTO l_count
			     FROM hz_geography_identifiers
			    WHERE identifier_type='CODE'
			      AND identifier_subtype = l_new_geo_subtype
			      AND language_code = p_geo_identifier_rec.language_code
			      AND identifier_value = UPPER(l_new_geo_value)
			      AND geography_id IN (SELECT object_id
			                             FROM hz_relationships
			                            WHERE subject_id = l_get_all_parents.subject_id
			                              AND object_type = l_geography_type
			                              AND status = 'A'
			                              AND relationship_type = 'MASTER_REF')
				  AND ROWID <> l_rowid ;

			    IF l_count > 0 THEN

			       FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUPLICATE_VALUE');
			       FND_MESSAGE.SET_TOKEN('IDENT_TYPE', 'CODE');
			       FND_MESSAGE.SET_TOKEN('VALUE', l_new_geo_value);
			       FND_MESSAGE.SET_TOKEN('GEO_ID', p_geo_identifier_rec.geography_id);
			       FND_MESSAGE.SET_TOKEN('PARENT_GEO_ID', l_get_all_parents.subject_id);
			       FND_MSG_PUB.ADD;
			       x_return_status := fnd_api.g_ret_sts_error;
	               RAISE FND_API.G_EXC_ERROR;
	               EXIT;
	            END IF;
	          END IF;
	         END LOOP;
	        CLOSE c_get_all_parents;
               ELSE
        -- Bug 5411429 : check for the duplicate name/code for Country geographies.
                 SELECT count(*) INTO l_count
                  FROM  hz_geography_identifiers
                 WHERE  identifier_type = p_geo_identifier_rec.identifier_type
                   AND  identifier_subtype = l_new_geo_subtype
                   AND  language_code = p_geo_identifier_rec.language_code
                   AND  UPPER(identifier_value) = UPPER(l_new_geo_value)
                   AND  geography_type = 'COUNTRY'
                   AND  rowid <> l_rowid;

                   IF l_count > 0 THEN
                           FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_DUP_COUNTRY_IDEN');
                           FND_MESSAGE.SET_TOKEN('IDEN_VAL', l_new_geo_value);
                           FND_MSG_PUB.ADD;
                           x_return_status := fnd_api.g_ret_sts_error;
                       RAISE FND_API.G_EXC_ERROR;
                   END IF;

               END IF;

	      END IF;
       END IF;

       --do not allow the updation of primary_flag from 'Y' to 'N'
       IF (l_old_primary_flag = 'Y' AND p_geo_identifier_rec.primary_flag = 'N') THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_NONUPDATEABLE_COLUMN' );
         FND_MESSAGE.SET_TOKEN( 'COLUMN', 'primary_flag from Y to N');
         FND_MSG_PUB.ADD;
         x_return_status := FND_API.G_RET_STS_ERROR;
         RAISE FND_API.G_EXC_ERROR;
       END IF;

      -- for updating primary_flag from 'N' to 'Y'
      IF (l_old_primary_flag = 'N' AND p_geo_identifier_rec.primary_flag = 'Y') THEN

	      --check if there exists a primary row already for this geography_id
	      SELECT count(*) INTO l_count
	        FROM HZ_GEOGRAPHY_IDENTIFIERS
	       WHERE geography_id = p_geo_identifier_rec.geography_id
	         AND identifier_type = p_geo_identifier_rec.identifier_type
	         AND primary_flag='Y'
			 AND language_code = p_geo_identifier_rec.language_code;

	        -- --dbms_output.put_line ( 'l_count for primary row '||to_char(l_count));
	        IF l_count > 0 THEN
	          -- set the primary_flag of the existing primary identifier to 'N'
	          UPDATE hz_geography_identifiers
	             SET primary_flag = 'N'
	           WHERE geography_id=p_geo_identifier_rec.geography_id
	             AND identifier_type = p_geo_identifier_rec.identifier_type
	             AND primary_flag = 'Y'
				 AND language_code = p_geo_identifier_rec.language_code;
	        -- --dbms_output.put_line ( 'After update of primary from Y to N');
	        END IF;
      END IF;

     hz_geography_identifiers_pkg.update_row(
	    x_rowid                          => l_rowid,
	    x_geography_id                   => p_geo_identifier_rec.geography_id,
	    x_identifier_subtype             => l_new_geo_subtype,
	    x_identifier_value               => l_new_geo_value,
	    x_geo_data_provider              => p_geo_identifier_rec.geo_data_provider,
	    x_object_version_number          => p_object_version_number,
	    x_identifier_type                => p_geo_identifier_rec.identifier_type,
	    x_primary_flag                   => p_geo_identifier_rec.primary_flag,
	    x_language_code                  => p_geo_identifier_rec.language_code,
	    x_geography_use                  => NULL,
	    x_geography_type                 => NULL,
	    x_created_by_module              => NULL,
	    x_application_id                 => NULL,
	    x_program_login_id               => NULL);

   -- Kick off conc prog if primary flag is Y and name or code has been updated
   -- It will call procedure HZ_GEOGRAPHIES_PKG.update_geo_element_cp
   IF ((l_geography_use = 'MASTER_REF') AND
       ((l_old_primary_flag = 'N' AND p_geo_identifier_rec.primary_flag = 'Y') OR
        ((l_old_primary_flag = 'Y' AND p_geo_identifier_rec.primary_flag = 'Y') AND
         (l_name_updated = 'Y'))
       )
      )
   THEN
     x_cp_request_id :=   fnd_request.submit_request(
                                      application => 'AR',
                                      program     => 'ARHGEOEU',
                                      argument1   => p_geo_identifier_rec.geography_id,
                                      argument2   => p_geo_identifier_rec.identifier_type,
									  argument3   => l_new_geo_value);
   ELSIF ((l_geography_use = 'TAX') AND
          ((l_old_primary_flag = 'N' AND p_geo_identifier_rec.primary_flag = 'Y') OR
           ((l_old_primary_flag = 'Y' AND p_geo_identifier_rec.primary_flag = 'Y') AND
            (l_name_updated = 'Y'))
          )
         )
    THEN
      -- (For TAX, Logic added by Nishant on 27-Oct-2005 for Bug 4578867)
      -- FOR geography_use = 'TAX' we dont have any hierarchy (structure),
      -- so coulmns geography_element1,geography_element1_name,geography_element1_code...
      -- are all null.and the only columns which need to be modified in hz_geographies
      -- are geography_name and geography_code

      IF p_geo_identifier_rec.identifier_type = 'CODE' THEN
        UPDATE HZ_GEOGRAPHIES
           SET geography_code = l_new_geo_value
         WHERE geography_id = p_geo_identifier_rec.geography_id
		   AND geography_use = l_geography_use;
      END IF;

      IF  p_geo_identifier_rec.identifier_type = 'NAME' THEN
        UPDATE HZ_GEOGRAPHIES
           SET geography_name = l_new_geo_value
         WHERE geography_id = p_geo_identifier_rec.geography_id
		   AND geography_use = l_geography_use;
      END IF;
   END IF;

 END do_update_geo_identifier;

   -- delete geography identifier
   PROCEDURE do_delete_geo_identifier(
        p_geography_id                 IN NUMBER,
        p_identifier_type              IN VARCHAR2,
        p_identifier_subtype           IN VARCHAR2,
        p_identifier_value             IN VARCHAR2,
        p_language_code                IN VARCHAR2,
        x_return_status                IN OUT NOCOPY VARCHAR2
       ) IS

       l_primary_flag         VARCHAR2(1);
       l_count                NUMBER;
       l_delete_flag          VARCHAR2(1);

       BEGIN

        l_delete_flag := 'Y';

        -- primary identifier can not be deleted
        SELECT primary_flag INTO l_primary_flag
          FROM hz_geography_identifiers
         WHERE geography_id = p_geography_id
           AND identifier_type = p_identifier_type
           AND identifier_subtype = p_identifier_subtype
           AND identifier_value = p_identifier_value
           AND language_code = p_language_code;

           IF l_primary_flag = 'Y' THEN
            l_delete_flag := 'N';
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_NONDELETEABLE' );
            FND_MSG_PUB.ADD;
            x_return_status := FND_API.G_RET_STS_ERROR;
             RAISE FND_API.G_EXC_ERROR;
           END IF;

           -- If a STANDARD_NAME is being deleted , if there exists another name mark it as STANDARD and delete
           -- this row else if another name doesn't exist then delete the row.
           IF (p_identifier_type = 'NAME' AND p_identifier_subtype = 'STANDARD_NAME') THEN
             select count(*) INTO l_count
               from hz_geography_identifiers
              where geography_id = p_geography_id
                AND language_code = p_language_code
                AND identifier_type = 'NAME'
                ;
             IF l_count > 1 THEN
                 -- update an identifier to STANDARD
                 UPDATE hz_geography_identifiers
                    SET identifier_subtype = 'STANDARD_NAME'
                  WHERE geography_id = p_geography_id
                    AND identifier_type= p_identifier_type
                    AND identifier_subtype <> p_identifier_subtype
                    AND identifier_value <> p_identifier_value
                    AND language_code = p_language_code
                    AND rownum < 2;
                 l_delete_flag := 'Y';
               ELSE
                 l_delete_flag := 'Y';
              END IF;
             END IF;

            IF l_delete_flag = 'Y' THEN
           HZ_GEOGRAPHY_IDENTIFIERS_PKG.delete_row(
               x_geography_id                => p_geography_id,
    	       x_identifier_subtype          => p_identifier_subtype,
               x_identifier_value            => p_identifier_value,
               x_language_code               => p_language_code,
               x_identifier_type             => p_identifier_type
               );
            END IF;

          EXCEPTION WHEN NO_DATA_FOUND THEN
            FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_NO_RECORD' );
            FND_MESSAGE.SET_TOKEN('TOKEN1', 'geography_identifier');
            FND_MESSAGE.SET_TOKEN('TOKEN2', 'geography_id: '||p_geography_id||', identifier_type: '||
                                    p_identifier_type||', identifier_subtype: '||p_identifier_subtype||', identifier_value: '||
                                    p_identifier_value||', language_code: '||p_language_code);
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;

END do_delete_geo_identifier;


 -- create Master Geography
 PROCEDURE do_create_master_geography(
        p_master_geography_rec      IN  MASTER_GEOGRAPHY_REC_TYPE,
        x_geography_id              OUT NOCOPY NUMBER,
        x_return_status             IN OUT NOCOPY VARCHAR2
       ) IS

       l_count                NUMBER;
       l_parent_geography_tbl  HZ_GEOGRAPHY_PUB.parent_geography_tbl_type;
       l_rowid                VARCHAR2(64);
       l_country_code         VARCHAR2(2);
       l_master_relation_rec  MASTER_RELATION_REC_TYPE;
       l_geo_identifier_rec   GEO_IDENTIFIER_REC_TYPE;
       l_child_geography_id   NUMBER;
       x_relationship_id      NUMBER;
       x_msg_count            NUMBER;
       x_msg_data             VARCHAR2(2000);
       l_last                 NUMBER;

       BEGIN

       --l_country_count := 0;
       l_parent_geography_tbl := p_master_geography_rec.parent_geography_id;


      -- dbms_output.put_line('In do_create_master_geography, before validate');
       -- validate master geography record
       HZ_GEOGRAPHY_VALIDATE_PVT.validate_master_geography(
         p_master_geography_rec   => p_master_geography_rec,
         p_create_update_flag     => 'C',
         x_return_status          => x_return_status
         );

    --dbms_output.put_line('In do_create_master_geography , after validate_master_geography '|| x_return_status);

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
      END IF;

      -- determine the country_code
      IF p_master_geography_rec.geography_type='COUNTRY' THEN
        l_country_code := p_master_geography_rec.geography_code;
      ELSE
        SELECT country_code INTO l_country_code
          FROM HZ_GEOGRAPHIES
         WHERE geography_id= l_parent_geography_tbl(1);
      END IF;

     --dbms_output.put_line('before insert_row');
    --insert row into HZ_GEOGRAPHIES
    HZ_GEOGRAPHIES_PKG.insert_row(
    x_rowid                                 => l_rowid,
    x_geography_id                          => x_geography_id,
    x_object_version_number                  => 1,
    x_geography_type                        => UPPER(p_master_geography_rec.geography_type),
    x_geography_name                        => p_master_geography_rec.geography_name,
    x_geography_use                         => 'MASTER_REF',
    x_geography_code                        => UPPER(p_master_geography_rec.geography_code),
    x_start_date                            => p_master_geography_rec.start_date,
    x_end_date                              => p_master_geography_rec.end_date,
    x_multiple_parent_flag                  => 'N',
    x_created_by_module                     => p_master_geography_rec.created_by_module,
    x_country_code                          => l_country_code,
    x_geography_element1                    => NULL,
    x_geography_element1_id                 => NULL,
    x_geography_element1_code               => NULL,
    x_geography_element2                    => NULL,
    x_geography_element2_id                 => NULL,
    x_geography_element2_code               => NULL,
    x_geography_element3                    => NULL,
    x_geography_element3_id                 => NULL,
    x_geography_element3_code               => NULL,
    x_geography_element4                    => NULL,
    x_geography_element4_id                 => NULL,
    x_geography_element4_code               => NULL,
    x_geography_element5                    => NULL,
    x_geography_element5_id                 => NULL,
    x_geography_element5_code               => NULL,
    x_geography_element6                    => NULL,
    x_geography_element6_id                 => NULL,
    x_geography_element7                    => NULL,
    x_geography_element7_id                 => NULL,
    x_geography_element8                    => NULL,
    x_geography_element8_id                 => NULL,
    x_geography_element9                    => NULL,
    x_geography_element9_id                 => NULL,
    x_geography_element10                   => NULL,
    x_geography_element10_id                => NULL,
    x_geometry                              => p_master_geography_rec.geometry,
    x_timezone_code                         => p_master_geography_rec.timezone_code,
    x_application_id                        => p_master_geography_rec.application_id,
    x_program_login_id                      => NULL,
    x_attribute_category                    => NULL,
    x_attribute1                            => NULL,
    x_attribute2                            => NULL,
    x_attribute3                            => NULL,
    x_attribute4                            => NULL,
    x_attribute5                            => NULL,
    x_attribute6                            => NULL,
    x_attribute7                            => NULL,
    x_attribute8                            => NULL,
    x_attribute9                            => NULL,
    x_attribute10                           => NULL,
    x_attribute11                           => NULL,
    x_attribute12                           => NULL,
    x_attribute13                           => NULL,
    x_attribute14                           => NULL,
    x_attribute15                           => NULL,
    x_attribute16                           => NULL,
    x_attribute17                           => NULL,
    x_attribute18                           => NULL,
    x_attribute19                           => NULL,
    x_attribute20                           => NULL
   );

     BEGIN

    l_last := l_parent_geography_tbl.last;
    IF l_last > 0 THEN
        FOR i in 1 .. l_last LOOP

    BEGIN

           IF l_parent_geography_tbl.exists(i) = TRUE THEN
           -- construct master relation record
           l_master_relation_rec.geography_id := x_geography_id;
           l_master_relation_rec.parent_geography_id := l_parent_geography_tbl(i);
           l_master_relation_rec.start_date := p_master_geography_rec.start_date;
           l_master_relation_rec.end_date := p_master_geography_rec.end_date;
           l_master_relation_rec.created_by_module := p_master_geography_rec.created_by_module;
           l_master_relation_rec.application_id := p_master_geography_rec.application_id;

           -- call relationship API to create relationship between geography_id and parent_geography_id
           create_master_relation(
           	p_init_msg_list             => 'F',
    		p_master_relation_rec       => l_master_relation_rec,
    		x_relationship_id           => x_relationship_id,
    		x_return_status             => x_return_status,
    		x_msg_count                 => x_msg_count,
    		x_msg_data                  => x_msg_data
    		);
         END IF;
          END;
            IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
            END IF;
           -- --dbms_output.put_line('after create_master_relation id is '|| to_char(x_relationship_id));
            END LOOP;
          END IF;
          END;


    -- create an identifier for this geography in HZ_GEOGRAPHY_IDENTIFIERS
          -- construct Identifier record for identifier_type 'NAME'/'CODE'
           l_geo_identifier_rec.geography_id := x_geography_id;
           l_geo_identifier_rec.identifier_subtype := 'STANDARD_NAME';
           l_geo_identifier_rec.identifier_value := p_master_geography_rec.geography_name;
           l_geo_identifier_rec.identifier_type := 'NAME';
           l_geo_identifier_rec.geo_data_provider := p_master_geography_rec.geo_data_provider;
           l_geo_identifier_rec.primary_flag := 'Y';
           l_geo_identifier_rec.language_code := p_master_geography_rec.language_code;
           l_geo_identifier_rec.created_by_module := p_master_geography_rec.created_by_module;
           l_geo_identifier_rec.application_id := p_master_geography_rec.application_id;


          -- call to create Identifier API
           create_geo_identifier(
              p_init_msg_list    	=> 'F',
    	      p_geo_identifier_rec      => l_geo_identifier_rec,
    	      x_return_status           => x_return_status,
    	      x_msg_count               => x_msg_count,
    	      x_msg_data                => x_msg_data
    	      );

    	     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
            END IF;
            --dbms_output.put_line('after creating name identifier');

           IF p_master_geography_rec.geography_code IS NOT NULL
--  Bug 4579847 : do not call for g_miss value for code
              and p_master_geography_rec.geography_code <> fnd_api.g_miss_char THEN

          -- create an identifier for this geography for identifier_type 'CODE'
           l_geo_identifier_rec.identifier_subtype := p_master_geography_rec.geography_code_type;
           l_geo_identifier_rec.identifier_value := UPPER(p_master_geography_rec.geography_code);
           l_geo_identifier_rec.identifier_type := 'CODE';

           --dbms_output.put_line('after constructing the code identifier record');
           -- call to create Identifier API
           create_geo_identifier(
              p_init_msg_list    	=> 'F',
    	      p_geo_identifier_rec      => l_geo_identifier_rec,
    	      x_return_status           => x_return_status,
    	      x_msg_count               => x_msg_count,
    	      x_msg_data                => x_msg_data
    	      );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
                  RAISE FND_API.G_EXC_ERROR;
           END IF;
          END IF;

END do_create_master_geography;


--Update master geography
PROCEDURE do_update_geography(
  	p_geography_id                 IN NUMBER,
        p_end_date                     IN DATE,
        p_geometry                     IN MDSYS.SDO_GEOMETRY,
        p_timezone_code                IN VARCHAR2,
        p_object_version_number        IN OUT NOCOPY NUMBER,
        x_return_status                IN OUT  NOCOPY VARCHAR2
        ) IS

      l_rowid                         VARCHAR2(64);
      x_msg_count                     NUMBER;
      x_msg_data                      VARCHAR2(2000);
      l_status                        VARCHAR2(1);
      l_start_date                    DATE;
      l_end_date                      DATE;
      l_geography_use                 VARCHAR2(30);
      l_count                         NUMBER;
      l_relationship_rec              HZ_RELATIONSHIP_V2PUB.RELATIONSHIP_REC_TYPE;
      CURSOR c_get_all_relationships IS
      SELECT  distinct relationship_id,object_version_number
        FROM HZ_RELATIONSHIPS
       WHERE (subject_id = p_geography_id
          OR object_id = p_geography_id)
         AND relationship_type= l_geography_use
         AND l_geography_use = 'MASTER_REF'  --Bug5265511
         AND status = 'A';                   --Bug5454824

   -- for l_geogrpahy_use = 'TAX' this cursor will read only Active records
   -- whose end_date is changed.
   -- but for l_geogrpahy_use = 'MASTER_REF' this will read inActive records also

      l_get_all_relationships       c_get_all_relationships%ROWTYPE;
      l_party_object_version_number  NUMBER := 1;
      l_object_version_number         NUMBER;

  BEGIN

     hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'U',
          p_column                 => 'object_version_number',
          p_column_value           => p_object_version_number,
          x_return_status          => x_return_status
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;

    BEGIN

         -- Initialize  start_date and end_date
     SELECT rowid,start_date,end_date,geography_use,object_version_number INTO l_rowid,l_start_date,l_end_date,
                       l_geography_use,l_object_version_number
       FROM HZ_GEOGRAPHIES
      WHERE geography_id=p_geography_id
       FOR UPDATE of geography_id NOWAIT;

      --validate object_version_number
      IF l_object_version_number <> p_object_version_number THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_geographies');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
         p_object_version_number := l_object_version_number + 1;
       END IF;

        EXCEPTION WHEN NO_DATA_FOUND THEN
        FND_MESSAGE.SET_NAME('AR', 'HZ_GEO_NO_RECORD');
        FND_MESSAGE.SET_TOKEN('TOKEN1','geography');
        FND_MESSAGE.SET_TOKEN('TOKEN2', 'geography_id '||p_geography_id);
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END;
     --dbms_output.put_line('start date and old end date and end date '||to_char(l_start_date,'dd-mon-yyyy')||'*'||to_char(l_end_date,'dd-mon-yyyy')||'*'||to_char(p_end_date,'dd-mon-yyyy')||'*');
     --dbms_output.put_line('After date validation '|| x_return_status);
     -- check whether end_date >= start_date
       HZ_UTILITY_V2PUB.validate_start_end_date(
           p_create_update_flag                    => 'U',
    	   p_start_date_column_name                => 'start_date',
           p_start_date                            => l_start_date,
           p_old_start_date                        => l_start_date,
           p_end_date_column_name                  => 'end_date',
           p_end_date                              => p_end_date,
           p_old_end_date                          => l_end_date,
           x_return_status                         => x_return_status
           );

           IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
           END IF;
         -- in case g_miss_date is passed for end_date, assign the default future date to end_date
         l_end_date := p_end_date;

         IF l_end_date = fnd_api.g_miss_date THEN
           l_end_date := to_date('31-12-4712','DD-MM-YYYY');
         END IF;

          -- dbms_output.put_line('timezone_code is '||p_timezone_code);
           -- validate timezone_code for FK to FND_TIMEZONES
   IF p_timezone_code IS NOT NULL THEN

      SELECT count(*) INTO l_count
        FROM FND_TIMEZONES_B
       WHERE timezone_code = p_timezone_code
        AND  rownum <2;

     IF l_count = 0 THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'timezone_code');
          fnd_message.set_token('COLUMN','timezone_code');
          fnd_message.set_token('TABLE','FND_TIMEZONES_B');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;
   END IF;
           --dbms_output.put_line('After date validation '|| x_return_status);

    --call table handler to update the geography
    HZ_GEOGRAPHIES_PKG.update_row(
    x_rowid                                 => l_rowid,
    x_geography_id                          => p_geography_id,
    x_object_version_number                 => p_object_version_number,
    x_geography_type                        => NULL,
    x_geography_name                        => NULL,
    x_geography_use                         => NULL,
    x_geography_code                        => NULL,
    x_start_date                            => NULL,
    x_end_date                              => l_end_date,
    x_multiple_parent_flag                  => NULL,
    x_created_by_module                     => NULL,
    x_country_code                          => NULL,
    x_geography_element1                    => NULL,
    x_geography_element1_id                 => NULL,
    x_geography_element1_code               => NULL,
    x_geography_element2                    => NULL,
    x_geography_element2_id                 => NULL,
    x_geography_element2_code               => NULL,
    x_geography_element3                    => NULL,
    x_geography_element3_id                 => NULL,
    x_geography_element3_code               => NULL,
    x_geography_element4                    => NULL,
    x_geography_element4_id                 => NULL,
    x_geography_element4_code               => NULL,
    x_geography_element5                    => NULL,
    x_geography_element5_id                 => NULL,
    x_geography_element5_code               => NULL,
    x_geography_element6                    => NULL,
    x_geography_element6_id                 => NULL,
    x_geography_element7                    => NULL,
    x_geography_element7_id                 => NULL,
    x_geography_element8                    => NULL,
    x_geography_element8_id                 => NULL,
    x_geography_element9                    => NULL,
    x_geography_element9_id                 => NULL,
    x_geography_element10                   => NULL,
    x_geography_element10_id                => NULL,
    x_geometry                              => p_geometry,
    x_timezone_code                         => p_timezone_code,
    x_application_id                        => NULL,
    x_program_login_id                      => NULL,
    x_attribute_category                    => NULL,
    x_attribute1                            => NULL,
    x_attribute2                            => NULL,
    x_attribute3                            => NULL,
    x_attribute4                            => NULL,
    x_attribute5                            => NULL,
    x_attribute6                            => NULL,
    x_attribute7                            => NULL,
    x_attribute8                            => NULL,
    x_attribute9                            => NULL,
    x_attribute10                           => NULL,
    x_attribute11                           => NULL,
    x_attribute12                           => NULL,
    x_attribute13                           => NULL,
    x_attribute14                           => NULL,
    x_attribute15                           => NULL,
    x_attribute16                           => NULL,
    x_attribute17                           => NULL,
    x_attribute18                           => NULL,
    x_attribute19                           => NULL,
    x_attribute20                           => NULL
    );


    IF l_end_date <= sysdate THEN
    l_status := 'I';
    ELSIF l_end_date > sysdate THEN
    l_status := 'A';
    ELSIF l_end_date = NULL THEN
    l_status :=NULL;
    END IF;

   -- construct the relationship record for update
    --l_relationship_rec.relationship_id := p_relationship_id;
    l_relationship_rec.start_date := NULL;
    l_relationship_rec.end_date := l_end_date;
    l_relationship_rec.status := l_status;
    l_relationship_rec.created_by_module := NULL;
    l_relationship_rec.application_id := NULL;

   -- update relationships with end_date wherever this geography_id is used

   OPEN c_get_all_relationships;
   LOOP
   FETCH c_get_all_relationships INTO l_get_all_relationships;
   EXIT WHEN c_get_all_relationships%NOTFOUND;

   l_relationship_rec.relationship_id := l_get_all_relationships.relationship_id;

   --l_relationship_rec.relationship_code := l_get_all_relationships.relationship_code;
        HZ_RELATIONSHIP_V2PUB.update_relationship(
    p_init_msg_list               =>     'F',
    p_relationship_rec            =>     l_relationship_rec,
    p_object_version_number       =>     l_get_all_relationships.object_version_number,
    p_party_object_version_number =>     l_party_object_version_number,
    x_return_status               =>     x_return_status,
    x_msg_count                   =>     x_msg_count,
    x_msg_data                    =>     x_msg_data
);

    /* update hz_relationships
         set status = l_status,
             end_date = p_end_date
       WHERE relationship_id=l_get_all_relationships.relationship_id;*/

       IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
               EXIT;
           END IF;


    END LOOP;
    CLOSE c_get_all_relationships;

    /* update hz_hierarchy_nodes
          set effective_end_date = p_end_date
        where hierarchy_type=l_geography_use
          and parent_id = p_geography_id
           or child_id = p_geography_id ; */


END do_update_geography;

/*-----------------------------------------------------------------------------+
  Procedure do_create_discrete_geography: Creates discrete geographies for geographies
  created through geography range. These discrete geographies are created only
  if postal_code_range_flag = Y in HZ_GEOGRAPHY_TYPE_B (for 'MASTER_REF'). This
  way postal code range will be converted to discrete geography.

  Created By Nishant Singhai 29-Aug-2005
             ER# 4539557 : CREATION OF DISCRETE VALUES FROM ZIP CODE RANGES
  Modified By Nishant Singhai 22-Sep-2005
             Bug# 4591075 : Commented out code as for now we will not be creating
                            discrete geography for postal code range. Retaining logic
                            for future use
------------------------------------------------------------------------------*/

  PROCEDURE do_create_discrete_geography (
        p_geography_range_rec           IN HZ_GEOGRAPHY_PUB.GEOGRAPHY_RANGE_REC_TYPE,
        x_return_status                 IN OUT NOCOPY VARCHAR2
       ) IS
  /*
      l_geography_range_rec     HZ_GEOGRAPHY_PUB.GEOGRAPHY_RANGE_REC_TYPE;

	  l_parent_geo_type          VARCHAR2(100);
	  l_country_code             VARCHAR2(100);
	  l_child_geo_type           VARCHAR2(100);
	  l_geo_range_from           NUMBER;
	  l_geo_range_to             NUMBER;
	  l_geography_id             NUMBER;
	  l_master_geography_rec     HZ_GEOGRAPHY_PUB.MASTER_GEOGRAPHY_REC_TYPE;
	  l_parent_geography_id_tbl  HZ_GEOGRAPHY_PUB.PARENT_GEOGRAPHY_TBL_TYPE;
	  l_msg_data                 VARCHAR2(10000);
	  l_msg_count                NUMBER;
	  l_count                    NUMBER;
   */
  BEGIN
   	  x_return_status        := FND_API.G_RET_STS_SUCCESS;
/*
      l_geography_range_rec  := p_geography_range_rec;
      l_geo_range_from := TO_NUMBER(l_geography_range_rec.geography_from);
      l_geo_range_to   := TO_NUMBER(l_geography_range_rec.geography_to);

      IF ((l_geo_range_from IS NOT NULL) AND (l_geo_range_to IS NOT NULL) AND
          (l_geo_range_from <= l_geo_range_to)) THEN
	      --  get geography type, country code for parent id
	      BEGIN
	        SELECT geography_type, country_code
	        INTO   l_parent_geo_type, l_country_code
	        FROM   hz_geographies
	        WHERE  geography_id = l_geography_range_rec.master_ref_geography_id
	  	    AND    geography_use = 'MASTER_REF'
		    AND    TRUNC(SYSDATE) BETWEEN START_DATE AND end_date
		    ;
	      EXCEPTION WHEN NO_DATA_FOUND THEN
	        NULL;
	      END;

	      IF (l_parent_geo_type IS NOT NULL) THEN
	        -- get child geo type for which geo range has to be created
	        BEGIN
	  	  	  SELECT st.geography_type
			  INTO   l_child_geo_type
			  FROM   hz_geo_structure_levels st
			        ,hz_geography_types_b tp
	 	   	  WHERE  st.country_code = l_country_code
			  AND    st.parent_geography_type = l_parent_geo_type
			  AND    st.geography_type = tp.geography_type
			  AND    tp.geography_use = 'MASTER_REF'
			  AND    tp.postal_code_range_flag = 'Y'
			  AND    tp.geography_use = 'MASTER_REF'
			  AND    ROWNUM < 2
			  ;
		    EXCEPTION WHEN OTHERS THEN
		      NULL;
		    END;

		    -- now create discrete geo
		    IF (l_child_geo_type IS NOT NULL) THEN

		        l_master_geography_rec.geography_type          := l_child_geo_type;
		        l_master_geography_rec.START_DATE              := l_geography_range_rec.start_date;
		        l_master_geography_rec.END_DATE                := l_geography_range_rec.end_date;
				l_parent_geography_id_tbl(1)                   := l_geography_range_rec.master_ref_geography_id;
				l_master_geography_rec.parent_geography_id     := l_parent_geography_id_tbl;
		        l_master_geography_rec.created_by_module       := l_geography_range_rec.created_by_module;
		        l_master_geography_rec.application_id          := l_geography_range_rec.application_id;

			    FOR i IN l_geo_range_from..l_geo_range_to LOOP
		            l_master_geography_rec.geography_name   := TO_CHAR(i);

		            -- check if this geography already exists for given parent
		            SELECT COUNT(*)
		            INTO   l_count
					FROM   hz_geography_identifiers id
					WHERE  UPPER(id.identifier_value) = l_master_geography_rec.geography_name
					AND    id.geography_use = 'MASTER_REF'
					AND    id.identifier_type = 'NAME'
					AND    id.identifier_subtype = 'STANDARD_NAME'
					AND    EXISTS ( SELECT '1'
					                FROM  hz_relationships rel
					                WHERE rel.subject_id = l_geography_range_rec.master_ref_geography_id
					                AND   rel.object_id = id.geography_id
					                AND   rel.object_type = l_master_geography_rec.geography_type
					                AND   rel.status = 'A'
					                AND   rel.relationship_type = 'MASTER_REF');

                    IF (l_count = 0) THEN
			            -- create geography
			            HZ_GEOGRAPHY_PUB.create_master_geography(
			                               p_init_msg_list        => FND_API.G_FALSE,
			                               p_master_geography_rec => l_master_geography_rec,
			                               x_geography_id         => l_geography_id,
			                               x_return_status        => x_return_status,
			                               x_msg_count            => l_msg_count,
			                               x_msg_data             => l_msg_data);

					    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
					      -- In case api throuws any exception, raise execution error
					      -- which will be cought by calling api.
                          RAISE FND_API.G_EXC_ERROR;
                        END IF;
					END IF;
                    --dbms_output.put_line('Create Master Geo For :'||l_master_geography_rec.geography_name||':GeoId:'||l_geography_id);
			    END LOOP;

	         ELSE
	           --dbms_output.put_line('Child Geo type was NULL... ');
	           NULL;
		     END IF;  --  End of child geo type not null check

	      ELSE
	        --dbms_output.put_line('Parent Geo Type was NULL... ');
	        NULL;
		  END IF; -- End of  parent_geo_type not null check

	  ELSE
	    --dbms_output.put_line('From and to ids are wrong... ');
	    NULL;
	  END IF;

    EXCEPTION
	  WHEN VALUE_ERROR THEN
	    -- when alphabet is passed in number field, we will get this error.
	    -- it would have been taken care of in create range api itself.
	    -- If not, we do not want to raise error, just don't create discrete
	    -- geographies.
	    -- dbms_output.put_line(SUBSTR('Number conversion error...'||SQLERRM,1,255));
	    NULL;
  */
  END do_create_discrete_geography;


 -- create geography range

PROCEDURE do_create_geography_range(
        p_geography_range_rec           IN GEOGRAPHY_RANGE_REC_TYPE,
        x_return_status                 IN OUT NOCOPY VARCHAR2
       ) IS

   l_zone_type       VARCHAR2(30);
   l_geography_use   VARCHAR2(30);
   l_rowid           ROWID;
   l_count           NUMBER;


   BEGIN



   -- check for the uniqueness
   /*SELECT count(*) INTO l_count from hz_geography_ranges
    WHERE geography_id =   p_geography_range_rec.zone_id
      AND geography_from = p_geography_range_rec.geography_from
      AND to_char(start_date,'DD-MON-YYYY') = to_char(p_geography_range_rec.start_date,'DD_MON-YYYY');

    IF l_count > 0 THEN
        FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_DUPLICATE_COLUMN' );
             FND_MESSAGE.SET_TOKEN( 'COLUMN','geography_id, geography_from, start_date');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
    END IF; */


    -- validate geography range
    HZ_GEOGRAPHY_VALIDATE_PVT.validate_geography_range(
      p_geography_range_rec        => p_geography_range_rec,
      p_create_update_flag         => 'C',
      x_return_status              => x_return_status
        );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- get the geography_type of the zone_id
   l_zone_type := hz_geography_validate_pvt.get_geography_type(p_geography_id => p_geography_range_rec.zone_id,
                                                               x_return_status => x_return_status);

    -- get geography use
    SELECT geography_use INTO l_geography_use
      FROM hz_geography_types_b
     WHERE geography_type=l_zone_type;

     hz_geography_ranges_pkg.insert_row (
    x_rowid                                 => l_rowid,
    x_geography_id                          => p_geography_range_rec.zone_id,
    x_geography_from                        => p_geography_range_rec.geography_from,
    x_start_date                            => p_geography_range_rec.start_date,
    x_object_version_number                 => 1,
    x_geography_to                          => p_geography_range_rec.geography_to,
    x_identifier_type                       => p_geography_range_rec.identifier_type,
    x_end_date                              => p_geography_range_rec.end_date,
--  Dhaval : Use queried geography_type
    x_geography_type                        => l_zone_type,
    x_geography_use                         => l_geography_use,
    x_master_ref_geography_id               => p_geography_range_rec.master_ref_geography_id,
    x_created_by_module                     => p_geography_range_rec.created_by_module,
    x_application_id                        => p_geography_range_rec.application_id,
    x_program_login_id                      => NULL
          );

    -- ER # 4539557 : Added call to create discrete geo for passed in geography
    -- range (Nishant Singhai on 30-Aug-2005)
    -- Bug 4591075 : Removing this call for now, as it is decided that we will
    -- not create discrete geographies from postal_code range (Nishant 22-Sep-2005)
    /*
    do_create_discrete_geography (p_geography_range_rec => p_geography_range_rec,
	                              x_return_status => x_return_status);
    */

END do_create_geography_range;

-- update geography range
PROCEDURE do_update_geography_range(
        p_geography_id                  IN NUMBER,
        p_geography_from                IN VARCHAR2,
        p_start_date                    IN DATE,
        p_end_date                      IN DATE,
        p_object_version_number         IN OUT NOCOPY NUMBER,
        x_return_status                 IN OUT NOCOPY VARCHAR2
       ) IS

   l_rowid        ROWID;
   l_start_date   DATE;
   l_end_date     DATE;
   l_geography_range_rec    GEOGRAPHY_RANGE_REC_TYPE;
   l_object_version_number   NUMBER;

     BEGIN

     l_geography_range_rec.zone_id := p_geography_id;
     l_geography_range_rec.geography_from := p_geography_from;
     l_geography_range_rec.start_date := p_start_date;

     -- validate geography range for update
     HZ_GEOGRAPHY_VALIDATE_PVT.validate_geography_range(
        p_geography_range_rec => l_geography_range_rec,
        p_create_update_flag  => 'U',
        x_return_status       => x_return_status
        );

      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
     END IF;

        hz_utility_v2pub.validate_mandatory(
          p_create_update_flag     => 'U',
          p_column                 => 'object_version_number',
          p_column_value           => p_object_version_number,
          x_return_status          => x_return_status
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
        END IF;

     -- check if the row exists
     BEGIN

     SELECT rowid,start_date,end_date,object_version_number  INTO l_rowid,l_start_date,l_end_date,l_object_version_number
       FROM hz_geography_ranges
      WHERE geography_id = p_geography_id
        AND geography_from = p_geography_from
        AND start_date = p_start_date
        FOR UPDATE OF geography_id,geography_from,start_date NOWAIT;

      --validate object_version_number
      IF l_object_version_number <> p_object_version_number THEN
            FND_MESSAGE.SET_NAME('AR', 'HZ_API_RECORD_CHANGED');
            FND_MESSAGE.SET_TOKEN('TABLE', 'hz_geography_ranges');
            FND_MSG_PUB.ADD;
            RAISE FND_API.G_EXC_ERROR;
        ELSE
         p_object_version_number := l_object_version_number + 1;
       END IF;

     EXCEPTION WHEN NO_DATA_FOUND THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_NO_RECORD' );
         FND_MESSAGE.SET_TOKEN( 'TOKEN1', 'Geography Range');
         FND_MESSAGE.SET_TOKEN( 'TOKEN2', 'geography_id '||p_geography_id||', geography_from '||p_geography_from||', start_date '||p_start_date);
         FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;

     END;
        -- check if start_date <= end_date

       HZ_UTILITY_V2PUB.validate_start_end_date(
           p_create_update_flag                    => 'U',
           p_start_date_column_name                => 'start_date',
           p_start_date                            => p_start_date,
           p_old_start_date                        => l_start_date,
           p_end_date_column_name                  => 'end_date',
           p_end_date                              => p_end_date,
           p_old_end_date                          => l_end_date,
           x_return_status                         => x_return_status
           );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
          END IF;

        -- call table handler to update the row
        HZ_GEOGRAPHY_RANGES_PKG.update_row(
               	 x_rowid                         => l_rowid,
    		 x_geography_id                  => p_geography_id,
    		 x_geography_from                => p_geography_from,
    		 x_start_date                    => p_start_date,
   		 x_object_version_number         => p_object_version_number,
   		 x_geography_to                  => NULL,
   		 x_identifier_type               => NULL,
   		 x_end_date                      => p_end_date,
    		 x_geography_type                => NULL,
    		 x_geography_use                 => NULL,
    		 x_master_ref_geography_id       => NULL,
   		 x_created_by_module             => NULL,
   		 x_application_id                => NULL,
   		 x_program_login_id              => NULL
   		   		 );

END do_update_geography_range;

-- create zone relation

PROCEDURE do_create_zone_relation(
        p_geography_id               IN   NUMBER,
        p_zone_relation_tbl          IN   ZONE_RELATION_TBL_TYPE,
        p_created_by_module          IN   VARCHAR2,
        p_application_id	     IN   NUMBER,
        x_return_status              IN OUT NOCOPY VARCHAR2
       ) IS

       l_count                     NUMBER;
       --l_parent_geography_type     VARCHAR2(30);
       l_zone_type                 VARCHAR2(30);
       l_geography_use             VARCHAR2(30);
       l_zone_relation_rec         HZ_GEOGRAPHY_VALIDATE_PVT.zone_relation_rec_type;
       l_relationship_rec          HZ_RELATIONSHIP_V2PUB.relationship_rec_type;
       l_geography_range_rec       GEOGRAPHY_RANGE_REC_TYPE;
       l_incl_geo_type             VARCHAR2(30);
       x_relationship_id           NUMBER;
       x_party_id                  NUMBER;
       x_party_number              NUMBER;
       p_create_org_contact        VARCHAR2(1);
       x_msg_count                 NUMBER;
       x_msg_data                  VARCHAR2(2000);
       l_limited_by_geography_id   NUMBER;

       --  Added ro ER 4232852
       l_geo_rel_type_rec   HZ_GEOGRAPHY_STRUCTURE_PUB.GEO_REL_TYPE_REC_TYPE;
       x_relationship_type_id NUMBER;

       BEGIN


       l_zone_type := HZ_GEOGRAPHY_VALIDATE_PVT.get_geography_type(p_geography_id =>p_geography_id,
                                                                      x_return_status => x_return_status);


      IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
          RAISE FND_API.G_EXC_ERROR;
      END IF;

       SELECT geography_use,limited_by_geography_id INTO l_geography_use,l_limited_by_geography_id
         FROM hz_geography_types_b
        WHERE geography_type = l_zone_type;

       l_zone_relation_rec.geography_id := p_geography_id;

       FOR i in 1 .. p_zone_relation_tbl.count LOOP

       -- validate zone relation record
       l_zone_relation_rec.included_geography_id := p_zone_relation_tbl(i).included_geography_id;
       l_zone_relation_rec.start_date := p_zone_relation_tbl(i).start_date;
       l_zone_relation_rec.end_date := p_zone_relation_tbl(i).end_date;

       hz_geography_validate_pvt.validate_zone_relation(
         p_zone_relation_rec   => l_zone_relation_rec,
         p_create_update_flag  => 'C',
         x_return_status       => x_return_status
         );

         IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
               RAISE FND_API.G_EXC_ERROR;
               EXIT;
          END IF;

          --dbms_output.put_line('In loop after validate zone relaion '||x_return_status);

          --get geography_type of included_geography_id
      l_incl_geo_type := HZ_GEOGRAPHY_VALIDATE_PVT.get_geography_type(p_geography_id =>p_zone_relation_tbl(i).included_geography_id,
                                                                      x_return_status => x_return_status);

        IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
        EXIT;
      END IF;

     IF l_limited_by_geography_id IS NOT NULL THEN
      --included geography_id should have a relationship with limited_by_geography_id either at level >= 0
      BEGIN
            SELECT 1 INTO l_count
        FROM hz_hierarchy_nodes
       WHERE parent_id = l_limited_by_geography_id
         AND child_id  = p_zone_relation_tbl(i).included_geography_id
         AND hierarchy_type = 'MASTER_REF'
      	 AND NVL(status,'A') = 'A'
         AND (effective_end_date IS NULL
          OR effective_end_date > sysdate
          )
         AND rownum < 2;

         EXCEPTION WHEN NO_DATA_FOUND THEN
           FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_NO_RELATIONSHIP');
             FND_MESSAGE.SET_TOKEN( 'INCL_GEO_ID',p_zone_relation_tbl(i).included_geography_id);
             FND_MESSAGE.SET_TOKEN( 'LIM_GEO_ID', l_limited_by_geography_id );
             FND_MESSAGE.SET_TOKEN( 'ZONE_TYPE', l_zone_type);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
          END;
       END IF;

     -- Fix for ER 4232852
     IF l_limited_by_geography_id IS NULL THEN
-- check if there exists a relationship_type for this geography_type and
-- included_geography_type
        SELECT count(*) INTO l_COUNT
         FROM HZ_RELATIONSHIP_TYPES
        WHERE subject_type = l_zone_type
          AND object_type= l_incl_geo_type
          AND forward_rel_code = 'PARENT_OF'
          AND backward_rel_code = 'CHILD_OF'
          AND relationship_type = 'TAX';

        IF l_count = 0 THEN
-- create a relationship type with this geography type and included geography type
           l_geo_rel_type_rec.geography_type := l_incl_geo_type;
           l_geo_rel_type_rec.parent_geography_type := l_zone_type;
           l_geo_rel_type_rec.status := 'A';
           l_geo_rel_type_rec.created_by_module := p_created_by_module;
           l_geo_rel_type_rec.application_id := p_application_id;

          HZ_GEOGRAPHY_STRUCTURE_PUB.create_geo_rel_type(
          p_init_msg_list               =>  'F',
          p_geo_rel_type_rec              => l_geo_rel_type_rec,
          x_relationship_type_id          => x_relationship_type_id,
          x_return_status               => x_return_status,
          x_msg_count                   => x_msg_count,
          x_msg_data                     => x_msg_data
          );

          IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
             RAISE FND_API.G_EXC_ERROR;
          END IF;
       END IF;
     END IF;


        -- within a zone_type,zones can not have overlapping geographies
        -- Changed check from "subject_type =  l_zone_type" to "subject_id = p_geography_id"
        -- on 29-Aug-2005 by BAIANAND for Bug 3955631. This will relax the
        -- creation of geographies withing zone type. Now it can create multiple geographies
        -- within same zone type but not same zone.
        SELECT count(*) INTO l_count
          FROM hz_relationships
         WHERE relationship_type = l_geography_use
           -- AND subject_type =  l_zone_type
           AND subject_id = p_geography_id
           AND object_id = p_zone_relation_tbl(i).included_geography_id
           AND sysdate between start_date and nvl(end_date, sysdate + 1)
           AND status = 'A'
           AND rownum < 2;

           IF l_count > 0 THEN
             FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_OVERLAPPING_GEOGS' );
             FND_MESSAGE.SET_TOKEN( 'GEO_ID',p_zone_relation_tbl(i).included_geography_id );
             FND_MESSAGE.SET_TOKEN( 'ZONE_TYPE', l_zone_type);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
             EXIT;
           END IF;

         -- included_geography_id must be unique within a geography_id

         SELECT count(*) INTO l_count
           FROM hz_relationships
          WHERE relationship_type=l_geography_use
            AND subject_type=l_zone_type
            AND subject_id = p_geography_id
            AND object_id = p_zone_relation_tbl(i).included_geography_id
           AND sysdate between start_date and nvl(end_date, sysdate + 1)
           AND status = 'A'
            AND rownum <2;

          IF l_count > 0 THEN
             FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_DUPL_INCL_GEO_ID' );
             FND_MESSAGE.SET_TOKEN( 'GEO_ID',p_zone_relation_tbl(i).included_geography_id );
             FND_MESSAGE.SET_TOKEN( 'ZONE_ID', p_geography_id);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
             EXIT;
           END IF;

     -- call relationship API to create a relationship between geography_id and included_geography_id
    l_relationship_rec.subject_id := p_geography_id;
    l_relationship_rec.subject_type := l_zone_type;
    l_relationship_rec.subject_table_name :='HZ_GEOGRAPHIES';
    l_relationship_rec.object_id := p_zone_relation_tbl(i).included_geography_id;
    l_relationship_rec.object_type :=l_incl_geo_type;
    l_relationship_rec.object_table_name := 'HZ_GEOGRAPHIES';
    l_relationship_rec.relationship_code  := 'PARENT_OF';
    l_relationship_rec.relationship_type  := l_geography_use;
    l_relationship_rec.start_date := p_zone_relation_tbl(i).start_date;
    l_relationship_rec.end_date := p_zone_relation_tbl(i).end_date;
    l_relationship_rec.status   := 'A';
    l_relationship_rec.created_by_module := p_created_by_module;
    l_relationship_rec.application_id    := p_application_id;

        -- call to relationship API to create a relationship
   HZ_RELATIONSHIP_V2PUB.create_relationship(
    p_init_msg_list             => 'F',
    p_relationship_rec          => l_relationship_rec,
    x_relationship_id           => x_relationship_id,
    x_party_id                  => x_party_id,
    x_party_number              => x_party_number,
    x_return_status             => x_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data,
    p_create_org_contact        => 'N'
       );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
     --dbms_output.put_line('After call to create relationship API '|| x_return_status);
        RAISE FND_API.G_EXC_ERROR;
        EXIT;
     END IF;
      IF (p_zone_relation_tbl(i).geography_from IS NOT NULL AND
          p_zone_relation_tbl(i).geography_to IS NOT NULL AND
          p_zone_relation_tbl(i).geography_from <> fnd_api.g_miss_char AND
          p_zone_relation_tbl(i).geography_to <> fnd_api.g_miss_char) THEN
   --call create_geography_range API

    l_geography_range_rec.zone_id                  := p_geography_id;
    l_geography_range_rec.master_ref_geography_id  := p_zone_relation_tbl(i).included_geography_id;
    l_geography_range_rec.identifier_type          := p_zone_relation_tbl(i).identifier_type;
    l_geography_range_rec.geography_from           := p_zone_relation_tbl(i).geography_from;
    l_geography_range_rec.geography_to             := p_zone_relation_tbl(i).geography_to;
    l_geography_range_rec.geography_type           := p_zone_relation_tbl(i).geography_type;
    l_geography_range_rec.start_date               := p_zone_relation_tbl(i).start_date;
    l_geography_range_rec.end_date                 := p_zone_relation_tbl(i).end_date;
    l_geography_range_rec.created_by_module        := p_created_by_module;
    l_geography_range_rec.application_id	   := p_application_id;


    --dbms_output.put_line('before call to create geography range');

   create_geography_range(
    p_init_msg_list             => 'F',
    p_geography_range_rec       => l_geography_range_rec,
    x_return_status             => x_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                 => x_msg_data
    );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
        EXIT;
      END IF;
         END IF;
   END LOOP;

 END do_create_zone_relation;

 -- create zone

 PROCEDURE do_create_zone(
    p_zone_type                 IN         VARCHAR2,
    p_zone_name                 IN         VARCHAR2,
    p_zone_code                 IN         VARCHAR2,
    p_zone_code_type            IN         VARCHAR2,
    p_start_date                IN         DATE,
    p_end_date                  IN         DATE,
    p_geo_data_provider         IN         VARCHAR2,
    p_language_code             IN         VARCHAR2,
    p_zone_relation_tbl         IN         ZONE_RELATION_TBL_TYPE,
    p_geometry                  IN         MDSYS.SDO_GEOMETRY,
    p_timezone_code             IN         VARCHAR2,
    x_geography_id              OUT        NOCOPY  NUMBER,
    p_created_by_module         IN         VARCHAR2,
    p_application_id	        IN         NUMBER,
    x_return_status             OUT        NOCOPY     VARCHAR2
    ) IS

    l_count                 NUMBER;
    l_geo_identifier_rec    GEO_IDENTIFIER_REC_TYPE;
    l_geography_use         VARCHAR2(30);
    l_rowid                 ROWID;
    l_country_code          VARCHAR2(2);
    x_relationship_id       NUMBER;
    x_msg_count             NUMBER;
    x_msg_data              VARCHAR2(2000);
    l_language_code         VARCHAR2(4);
    l_end_date              DATE;
    l_limited_by_geography_id NUMBER;

    BEGIN

    l_end_date := to_date('31-12-4712','DD-MM-YYYY');
    -- validate for mandatory columns
     HZ_UTILITY_V2PUB.validate_mandatory (
    p_create_update_flag         =>'C',
    p_column                     => 'zone_type',
    p_column_value               => p_zone_type,
    p_restricted                 => 'N',
    x_return_status              => x_return_status
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

     HZ_UTILITY_V2PUB.validate_mandatory (
    p_create_update_flag         =>'C',
    p_column                     => 'zone_name',
    p_column_value               => p_zone_name,
    p_restricted                 => 'N',
    x_return_status              => x_return_status
    );

    IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    -- get geography_use
    BEGIN

    SELECT geography_use,limited_by_geography_id INTO l_geography_use,l_limited_by_geography_id
      FROM hz_geography_types_b
     WHERE geography_type = p_zone_type;

    EXCEPTION WHEN NO_DATA_FOUND THEN
            fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
            fnd_message.set_token('FK', 'geography_type');
            fnd_message.set_token('COLUMN','zone_type');
            fnd_message.set_token('TABLE','HZ_GEOGRAPHY_TYPES_B');
            fnd_msg_pub.add;
            RAISE FND_API.G_EXC_ERROR;
    END;

    -- zone_name must be unique with in a zone_type
    SELECT count(*) INTO l_count
      FROM hz_geographies
     WHERE geography_name = p_zone_name
       AND geography_type = p_zone_type
       AND rownum <2;

       IF l_count > 0 THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_DUPLICATE_COLUMN' );
             FND_MESSAGE.SET_TOKEN( 'COLUMN','zone name');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
       END IF;

       -- zone_code must be unique within a zone_type

       IF p_zone_code IS NOT NULL THEN
           SELECT count(*) INTO l_count
      FROM hz_geographies
     WHERE geography_code = upper(p_zone_code)
       AND geography_type = p_zone_type
       AND rownum <2;

       IF l_count > 0 THEN
         FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_DUPLICATE_COLUMN' );
             FND_MESSAGE.SET_TOKEN( 'COLUMN','zone code');
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
       END IF;
       END IF;

    -- zone_code_type is mandatory if zone_code is NOT NULL
   IF (p_zone_code IS NOT NULL AND p_zone_code_type IS NULL) THEN
       FND_MESSAGE.SET_NAME( 'AR', 'HZ_API_MISSING_COLUMN' );
        FND_MESSAGE.SET_TOKEN( 'COLUMN', 'zone_code_type' );
        FND_MSG_PUB.ADD;
        RAISE FND_API.G_EXC_ERROR;
    END IF;


       -- timezone_code must be FK to fnd_timezones_b
       IF p_timezone_code IS NOT NULL THEN
       SELECT count(*) INTO l_count
         FROM fnd_timezones_b
        WHERE timezone_code = p_timezone_code
         AND rownum <2;

         IF l_count = 0 THEN
          fnd_message.set_name('AR', 'HZ_API_INVALID_FK');
          fnd_message.set_token('FK', 'timezone_code');
          fnd_message.set_token('COLUMN','timezone_code');
          fnd_message.set_token('TABLE','FND_TIMEZONES_B');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
         END IF;
         END IF;

     -- there must be atleast one included geography for a zone
     IF  p_zone_relation_tbl.count = 0 THEN
          fnd_message.set_name('AR', 'HZ_GEO_NO_INCL_GEOGRAPHIES');
          fnd_msg_pub.add;
          RAISE FND_API.G_EXC_ERROR;
     END IF;

     -- get country code of one of the included_geography_id of this zone_type


      FOR i in 1 .. p_zone_relation_tbl.count LOOP
          IF p_zone_relation_tbl(i).included_geography_id IS NOT NULL THEN
     BEGIN

     SELECT country_code INTO l_country_code
       FROM hz_geographies
      WHERE geography_id = p_zone_relation_tbl(i).included_geography_id;
       IF l_country_code IS NOT NULL THEN
       EXIT;
       END IF;
         EXCEPTION WHEN NO_DATA_FOUND THEN
          FND_MESSAGE.SET_NAME( 'AR', 'HZ_GEO_NO_RECORD');
             FND_MESSAGE.SET_TOKEN( 'TOKEN1','country code');
             FND_MESSAGE.SET_TOKEN( 'TOKEN2', 'included_geography_id '||p_zone_relation_tbl(i).included_geography_id);
             FND_MSG_PUB.ADD;
             RAISE FND_API.G_EXC_ERROR;
             EXIT;
           END;
           END IF;
        END LOOP;


      -- call table handler to insert a row in hz_geographies

      HZ_GEOGRAPHIES_PKG.insert_row(
    x_rowid                              => l_rowid,
    x_geography_id                       => x_geography_id,
    x_object_version_number              => 1,
    x_geography_type                     => p_zone_type,
    x_geography_name                     => p_zone_name,
    x_geography_use                      => l_geography_use,
    x_geography_code                     => UPPER(p_zone_code),
    x_start_date                         => NVL(p_start_date,SYSDATE),
    x_end_date                           => NVL(p_end_date,l_end_date),
    x_multiple_parent_flag               => 'N',
    x_created_by_module                  => p_created_by_module,
    x_country_code                       => l_country_code,
    x_geography_element1                 => NULL,
    x_geography_element1_id              => NULL,
    x_geography_element1_code            => NULL,
    x_geography_element2                 => NULL,
    x_geography_element2_id              => NULL,
    x_geography_element2_code            => NULL,
    x_geography_element3                 => NULL,
    x_geography_element3_id              => NULL,
    x_geography_element3_code            => NULL,
    x_geography_element4                 => NULL,
    x_geography_element4_id              => NULL,
    x_geography_element4_code            => NULL,
    x_geography_element5                 => NULL,
    x_geography_element5_id              => NULL,
    x_geography_element5_code            => NULL,
    x_geography_element6                 => NULL,
    x_geography_element6_id              => NULL,
    x_geography_element7                 => NULL,
    x_geography_element7_id              => NULL,
    x_geography_element8                 => NULL,
    x_geography_element8_id              => NULL,
    x_geography_element9                 => NULL,
    x_geography_element9_id              => NULL,
    x_geography_element10                => NULL,
    x_geography_element10_id             => NULL,
    x_geometry                           => p_geometry,
    x_timezone_code                      => p_timezone_code,
    x_application_id                     => p_application_id,
    x_program_login_id                   => NULL,
    x_attribute_category                 => NULL,
    x_attribute1                         => NULL,
    x_attribute2                         => NULL,
    x_attribute3                         => NULL,
    x_attribute4                         => NULL,
    x_attribute5                         => NULL,
    x_attribute6                         => NULL,
    x_attribute7                         => NULL,
    x_attribute8                         => NULL,
    x_attribute9                         => NULL,
    x_attribute10                        => NULL,
    x_attribute11                        => NULL,
    x_attribute12                        => NULL,
    x_attribute13                        => NULL,
    x_attribute14                        => NULL,
    x_attribute15                        => NULL,
    x_attribute16                        => NULL,
    x_attribute17                        => NULL,
    x_attribute18                        => NULL,
    x_attribute19                        => NULL,
    x_attribute20                        => NULL
    );

    -- default language_code in case of NULL
    IF p_language_code IS NULL THEN
     SELECT userenv('LANG') INTO l_language_code FROM dual;
     ELSE
     l_language_code := p_language_code;
    END IF;


    -- construct identifier record
     l_geo_identifier_rec.geography_id		:= x_geography_id;
     l_geo_identifier_rec.identifier_subtype	:= 'STANDARD_NAME';
     l_geo_identifier_rec.identifier_value      := p_zone_name;
     l_geo_identifier_rec.identifier_type	:= 'NAME';
     l_geo_identifier_rec.geo_data_provider     := NVL(p_geo_data_provider,'USER_ENTERED');
     l_geo_identifier_rec.primary_flag		:= 'Y';
     l_geo_identifier_rec.language_code         := l_language_code;
     l_geo_identifier_rec.created_by_module     := p_created_by_module;
     l_geo_identifier_rec.application_id	:= p_application_id;


     -- call create identifier API

     create_geo_identifier(
    p_init_msg_list            => 'F',
    p_geo_identifier_rec       => l_geo_identifier_rec,
    x_return_status            => x_return_status,
    x_msg_count                => x_msg_count,
    x_msg_data                 => x_msg_data
     );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --dbms_output.put_line('After first identifier row '||x_return_status);

    IF p_zone_code IS NOT NULL
--  Bug 4579847 : do not call for g_miss value for code
       and p_zone_code <> fnd_api.g_miss_char THEN
    -- create identifier for zone code
     l_geo_identifier_rec.identifier_subtype	:= p_zone_code_type;
     l_geo_identifier_rec.identifier_value      := p_zone_code;
     l_geo_identifier_rec.identifier_type	:= 'CODE';

     create_geo_identifier(
    p_init_msg_list            => 'F',
    p_geo_identifier_rec       => l_geo_identifier_rec,
    x_return_status            => x_return_status,
    x_msg_count                => x_msg_count,
    x_msg_data                 => x_msg_data
     );

     IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;

    --dbms_output.put_line('After second identifier row '||x_return_status);
   END IF;

   -- call API to create zone relationship
      create_zone_relation(
    p_init_msg_list             => 'F',
    p_geography_id              => x_geography_id,
    p_zone_relation_tbl         => p_zone_relation_tbl,
    p_created_by_module         => p_created_by_module,
    p_application_id	        => p_application_id,
    x_return_status             => x_return_status,
    x_msg_count                 => x_msg_count,
    x_msg_data                  => x_msg_data
      );

   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
        RAISE FND_API.G_EXC_ERROR;
    END IF;
    --dbms_output.put_line('After insert zone relation '||x_return_status);

END do_create_zone;

----------------------------
-- body of public procedures
----------------------------

/**
 * PROCEDURE create_master_relation
 *
 * DESCRIPTION
 *     Creates Geography Relationships.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_master_relation_rec           Geography type record.
 *   IN/OUT:
 *   OUT:
 *     x_relationship_id              Returns relationship_id for the relationship created.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *   11-22-2002    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_master_relation (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_master_relation_rec       IN         MASTER_RELATION_REC_TYPE,
    x_relationship_id           OUT   NOCOPY     NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
) IS

 --l_master_relation_rec             MASTER_RELATION_REC_TYPE := p_master_relation_rec;

 BEGIN
 -- Standard start of API savepoint
    SAVEPOINT create_master_relation;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_master_relation(
        p_master_relation_rec           => p_master_relation_rec,
        x_relationship_id               => x_relationship_id,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   --g_dup_checked := 'N';
    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
         g_dup_checked := 'N';
        ROLLBACK TO create_master_relation;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        --g_dup_checked := 'N';
        ROLLBACK TO create_master_relation;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        --g_dup_checked := 'N';
        ROLLBACK TO create_master_relation;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END create_master_relation;

/**
 * PROCEDURE update_relationship
 *
 * DESCRIPTION
 *     Updates Geography Relationships.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_master_relation_rec          Geography type record.
 *     p_object_version_number        Object version number of the row
 *   IN/OUT:
 *   OUT:
 *
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     11-22-2002    Rekha Nalluri        o Created.
 *
 */

PROCEDURE update_relationship (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_relationship_id           IN         NUMBER,
    p_status                    IN         VARCHAR2,
    p_object_version_number     IN OUT  NOCOPY   NUMBER,
    x_return_status             OUT     NOCOPY   VARCHAR2,
    x_msg_count                 OUT     NOCOPY   NUMBER,
    x_msg_data                  OUT     NOCOPY   VARCHAR2
)IS

 BEGIN
 -- Standard start of API savepoint
    SAVEPOINT update_relationship;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_update_relationship(
        p_relationship_id              => p_relationship_id,
        p_status                        => p_status,
        p_object_version_number         => p_object_version_number,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_relationship;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_relationship;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_relationship;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END update_relationship;

/**
 * PROCEDURE create_geo_identifier
 *
 * DESCRIPTION
 *     Creates Geography Identifiers.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geo_identifier_rec           Geo_identifier type record.
 *   IN/OUT:
 *   OUT:
 *
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     12-03-2002    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_geo_identifier(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geo_identifier_rec        IN         GEO_IDENTIFIER_REC_TYPE,
    x_return_status             OUT    NOCOPY    VARCHAR2,
    x_msg_count                 OUT    NOCOPY    NUMBER,
    x_msg_data                  OUT    NOCOPY    VARCHAR2
) IS

     p_index_name     VARCHAR2(30);

BEGIN
 -- Standard start of API savepoint
    SAVEPOINT create_geo_identifier;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_create_geo_identifier(
        p_geo_identifier_rec            => p_geo_identifier_rec,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_geo_identifier;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_geo_identifier;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO create_geo_identifier;
        x_return_status := FND_API.G_RET_STS_ERROR;
        HZ_UTILITY_V2PUB.find_index_name(p_index_name);
        IF p_index_name = 'HZ_GEOGRAPHY_IDENTIFIERS_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'geography_id,identifier_type,identifier_subtype,identifier_value,language_code');
            FND_MSG_PUB.ADD;
          END IF;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_geo_identifier;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
 END create_geo_identifier;

 /**
 * PROCEDURE update_geo_identifier
 *
 * DESCRIPTION
 *     Creates Geography Identifiers.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geo_identifier_rec           Geo_identifier type record.
 *
 *   IN/OUT:
 *     p_object_version_number
 *   OUT:
 *
 *     x_cp_request_id                Concurrent Program Request Id, whenever CP
 *                                    to update denormalized data gets kicked off.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     12-03-2002    Rekha Nalluri        o Created.
 *     21-Oct-2005   Nishant          Added  x_cp_request_id OUT parameter
 *                                    for Bug 457886
 *
 */
PROCEDURE update_geo_identifier (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geo_identifier_rec        IN         GEO_IDENTIFIER_REC_TYPE,
    p_object_version_number     IN OUT NOCOPY    NUMBER,
    x_cp_request_id             OUT    NOCOPY   NUMBER,
    x_return_status             OUT    NOCOPY    VARCHAR2,
    x_msg_count                 OUT    NOCOPY    NUMBER,
    x_msg_data                  OUT    NOCOPY    VARCHAR2
)IS

   BEGIN

   -- Standard start of API savepoint
    SAVEPOINT update_geo_identifier;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_update_geo_identifier(
        p_geo_identifier_rec           =>  p_geo_identifier_rec,
        p_object_version_number         => p_object_version_number,
        x_cp_request_id                => x_cp_request_id,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_geo_identifier;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_geo_identifier;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_geo_identifier;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END update_geo_identifier;

/**
 * PROCEDURE delete_geo_identifier
 *
 * DESCRIPTION
 *     Deletes Geography Identifiers.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_id                 geography id
 *     p_identifier_type
 *     p_identifier_subtype
 *     p_identifier_value
 *
 *   OUT:
 *
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     01-02-2003    Rekha Nalluri        o Created.
 *
 */

 PROCEDURE delete_geo_identifier(
      p_init_msg_list           IN VARCHAR2 := FND_API.G_FALSE,
      p_geography_id		IN NUMBER,
      p_identifier_type	        IN VARCHAR2,
      p_identifier_subtype	IN VARCHAR2,
      p_identifier_value        IN VARCHAR2,
      p_language_code           IN VARCHAR2,
      x_return_status           OUT NOCOPY VARCHAR2,
      x_msg_count               OUT NOCOPY NUMBER,
      x_msg_data                OUT NOCOPY VARCHAR2
      ) IS
    BEGIN

   -- Standard start of API savepoint
    SAVEPOINT delete_geo_identifier;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_delete_geo_identifier(
        p_geography_id                  => p_geography_id,
        p_identifier_type               => p_identifier_type,
        p_identifier_subtype            => p_identifier_subtype,
        p_identifier_value              => p_identifier_value,
        p_language_code                 => p_language_code,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO delete_geo_identifier;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO delete_geo_identifier;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO delete_geo_identifier;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END delete_geo_identifier;


/**
 * PROCEDURE create_master_geography
 *
 * DESCRIPTION
 *     Creates Master Geography.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_master_geography_rec         Master Geography type record.
 *   IN/OUT:
 *   OUT:
 *
 *     x_geography_id                 Return ID of the geography being created.
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     12-03-2002    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_master_geography(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_master_geography_rec      IN         MASTER_GEOGRAPHY_REC_TYPE,
    x_geography_id              OUT   NOCOPY     NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
)IS

BEGIN
 -- Standard start of API savepoint
    SAVEPOINT create_master_geography;
    --dbms_output.put_line('In the beginning of create_master_geography');

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     --dbms_output.put_line('before do_create_master_geography');
    -- Call to business logic.
    do_create_master_geography(
        p_master_geography_rec           => p_master_geography_rec,
        x_geography_id                   => x_geography_id,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_master_geography;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_master_geography;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_master_geography;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END create_master_geography;

/**
 * PROCEDURE update_geography
 *
 * DESCRIPTION
 *     Updates Geography
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_master_geography_rec         Master Geography type record.
 *
 *   IN/OUT:
 *     p_object_version_number
 *   OUT:
 *
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     12-12-2002    Rekha Nalluri        o Created.
 *
 */
PROCEDURE update_geography (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_id              IN        NUMBER,
    p_end_date                  IN        DATE,
    p_geometry                  IN        MDSYS.SDO_GEOMETRY,
    p_timezone_code             IN        VARCHAR2,
    p_object_version_number     IN OUT  NOCOPY   NUMBER,
    x_return_status             OUT     NOCOPY   VARCHAR2,
    x_msg_count                 OUT     NOCOPY   NUMBER,
    x_msg_data                  OUT     NOCOPY   VARCHAR2
) IS

  BEGIN

   -- Standard start of API savepoint
    SAVEPOINT update_geography;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_update_geography(
        p_geography_id                  => p_geography_id,
        p_end_date                      => p_end_date,
        p_geometry                      => p_geometry,
        p_timezone_code                 => p_timezone_code,
        p_object_version_number         => p_object_version_number,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_geography;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_geography;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_geography;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END update_geography;

/**
 * PROCEDURE create_geography_range
 *
 * DESCRIPTION
 *     Creates Geography Range.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_range_rec          Geography range type record.
 *   IN/OUT:
 *   OUT:
 *
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     01-20-2003    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_geography_range(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_range_rec       IN         GEOGRAPHY_RANGE_REC_TYPE,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
      ) IS

      p_index_name            VARCHAR2(30);

  BEGIN
 -- Standard start of API savepoint
    SAVEPOINT create_geography_range;
    --dbms_output.put_line('In the beginning of create_master_geography');

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     --dbms_output.put_line('before do_create_geography_range');
    -- Call to business logic.
    do_create_geography_range(
        p_geography_range_rec           => p_geography_range_rec,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_geography_range;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_geography_range;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

   WHEN DUP_VAL_ON_INDEX THEN
        ROLLBACK TO create_geography_range;
        x_return_status := FND_API.G_RET_STS_ERROR;
        HZ_UTILITY_V2PUB.find_index_name(p_index_name);
        IF p_index_name = 'HZ_GEOGRAPHY_RANGES_U1' THEN
          FND_MESSAGE.SET_NAME('AR', 'HZ_API_DUPLICATE_COLUMN');
            FND_MESSAGE.SET_TOKEN('COLUMN', 'geography_id,geography_from and start_date');
            FND_MSG_PUB.ADD;
          END IF;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count        => x_msg_count,
                                p_data        => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_geography_range;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END create_geography_range;

/**
 * PROCEDURE update_geography_range
 *
 * DESCRIPTION
 *     Updates Geography range
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     geography_id
 *     geography_from
 *     start_date
 *     end_date
 *
 *   IN/OUT:
 *     p_object_version_number
 *   OUT:
 *
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     01-23-2003    Rekha Nalluri        o Created.
 *
 */
PROCEDURE update_geography_range (
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_id              IN        NUMBER,
    p_geography_from            IN        VARCHAR2,
    p_start_date                IN        DATE,
    p_end_date                  IN        DATE,
    p_object_version_number     IN OUT  NOCOPY   NUMBER,
    x_return_status             OUT     NOCOPY   VARCHAR2,
    x_msg_count                 OUT     NOCOPY   NUMBER,
    x_msg_data                  OUT     NOCOPY   VARCHAR2
) IS

BEGIN

   -- Standard start of API savepoint
    SAVEPOINT update_geography_range;

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

    -- Call to business logic.
    do_update_geography_range(
        p_geography_id                  => p_geography_id,
        p_geography_from                => p_geography_from,
        p_start_date                    => p_start_date,
        p_end_date                      => p_end_date,
        p_object_version_number         => p_object_version_number,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO update_geography_range;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO update_geography_range;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO update_geography_range;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END update_geography_range;

/**
 * PROCEDURE create_zone_relation
 *
 * DESCRIPTION
 *     Creates Zone Relation.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_geography_id
 *     p_zone_relation_tbl            Zone relation table of records.
 *   IN/OUT:
 *   OUT:
 *
 *     x_return_status                Return status after the call. The status can
 *                                    be FND_API.G_RET_STS_SUCCESS (success),
 *                                    FND_API.G_RET_STS_ERROR (error),
 *                                    FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *     x_msg_count                    Number of messages in message stack.
 *     x_msg_data                     Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     01-23-2003    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_zone_relation(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_geography_id              IN         NUMBER,
    p_zone_relation_tbl         IN         ZONE_RELATION_TBL_TYPE,
    p_created_by_module         IN         VARCHAR2,
    p_application_id	        IN         NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
      ) IS

  BEGIN
 -- Standard start of API savepoint
    SAVEPOINT create_zone_relation;
    --dbms_output.put_line('In the beginning of create_zone_relation');

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     --dbms_output.put_line('before do_create_zone_relation');
    -- Call to business logic.
    do_create_zone_relation(
        p_geography_id                  => p_geography_id,
        p_zone_relation_tbl             => p_zone_relation_tbl,
        p_created_by_module             => p_created_by_module,
        p_application_id	        => p_application_id,
        x_return_status                 => x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

   --dbms_output.put_line('after call to do_create '|| x_return_status);

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_zone_relation;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_zone_relation;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_zone_relation;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);

END create_zone_relation;


/**
 * PROCEDURE create_zone
 *
 * DESCRIPTION
 *     Creates Zone
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_init_msg_list                Initialize message stack if it is set to
 *                                    FND_API.G_TRUE. Default is FND_API.G_FALSE.
 *     p_zone_type
 *     p_zone_name
 *     p_zone_code
 *     p_start_date
 *     p_end_date
 *     p_geo_data_provider
 *     p_zone_relation_tbl           table of records to create relationships
 *     p_geometry
 *     p_timezone_code
 *     p_created_by_module
 *     p_application_id
 *     p_program_login_id
 *
 *     OUT:
 *      x_return_status
 *                                              Return status after the call. The status can
 *      					be FND_API.G_RET_STS_SUCCESS (success),
 *                                              FND_API.G_RET_STS_ERROR (error),
 *                                              FND_API.G_RET_STS_UNEXP_ERROR (unexpected error).
 *      x_msg_count                             Number of messages in message stack.
 *      x_msg_data                              Message text if x_msg_count is 1.
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *     01-24-2003    Rekha Nalluri        o Created.
 *
 */

PROCEDURE create_zone(
    p_init_msg_list             IN         VARCHAR2 := FND_API.G_FALSE,
    p_zone_type                 IN         VARCHAR2,
    p_zone_name                 IN         VARCHAR2,
    p_zone_code                 IN         VARCHAR2,
    p_zone_code_type            IN         VARCHAR2,
    p_start_date                IN         DATE,
    p_end_date                  IN         DATE,
    p_geo_data_provider         IN         VARCHAR2,
    p_language_code             IN         VARCHAR2,
    p_zone_relation_tbl         IN         ZONE_RELATION_TBL_TYPE,
    p_geometry                  IN         MDSYS.SDO_GEOMETRY,
    p_timezone_code             IN         VARCHAR2,
    x_geography_id              OUT  NOCOPY NUMBER,
    p_created_by_module         IN         VARCHAR2,
    p_application_id	        IN         NUMBER,
    x_return_status             OUT   NOCOPY     VARCHAR2,
    x_msg_count                 OUT   NOCOPY     NUMBER,
    x_msg_data                  OUT   NOCOPY     VARCHAR2
      ) IS

 BEGIN


 -- Standard start of API savepoint
    SAVEPOINT create_zone;
    --dbms_output.put_line('In the beginning of create_zone');

    -- Initialize message list if p_init_msg_list is set to TRUE.
    IF FND_API.to_Boolean(p_init_msg_list) THEN
        FND_MSG_PUB.initialize;
    END IF;

    -- Initialize API return status to success.
    x_return_status := FND_API.G_RET_STS_SUCCESS;

     --dbms_output.put_line('before do_create_zone');
    -- Call to business logic.
    do_create_zone (
        p_zone_type                 =>  p_zone_type,
        p_zone_name                 =>  p_zone_name,
        p_zone_code                 =>  p_zone_code,
        p_zone_code_type            =>  p_zone_code_type,
        p_start_date                =>  p_start_date,
        p_end_date                  =>  p_end_date,
        p_geo_data_provider         =>  p_geo_data_provider,
        p_language_code             =>  p_language_code,
        p_zone_relation_tbl         =>  p_zone_relation_tbl,
        p_geometry                  =>  p_geometry,
        p_timezone_code             =>  p_timezone_code,
        x_geography_id              =>  x_geography_id,
        p_created_by_module         =>  p_created_by_module,
        p_application_id	    =>  p_application_id,
        x_return_status             =>  x_return_status
       );

   --if validation failed at any point, then raise an exception to stop processing
   IF x_return_status <> FND_API.G_RET_STS_SUCCESS THEN
       RAISE FND_API.G_EXC_ERROR;
   END IF;

    -- Standard call to get message count and if count is 1, get message info.
    FND_MSG_PUB.Count_And_Get(
                p_encoded => FND_API.G_FALSE,
                p_count => x_msg_count,
                p_data  => x_msg_data);

   EXCEPTION
    WHEN FND_API.G_EXC_ERROR THEN
        ROLLBACK TO create_zone;
        x_return_status := FND_API.G_RET_STS_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);
    WHEN FND_API.G_EXC_UNEXPECTED_ERROR THEN
        ROLLBACK TO create_zone;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count => x_msg_count,
                                p_data  => x_msg_data);

    WHEN OTHERS THEN
        ROLLBACK TO create_zone;
        x_return_status := FND_API.G_RET_STS_UNEXP_ERROR;
        FND_MESSAGE.SET_NAME('AR', 'HZ_API_OTHERS_EXCEP');
        FND_MESSAGE.SET_TOKEN('ERROR' ,SQLERRM);
        FND_MSG_PUB.ADD;
        FND_MSG_PUB.Count_And_Get(
                                p_encoded => FND_API.G_FALSE,
                                p_count   => x_msg_count,
                                p_data    => x_msg_data);
 END create_zone;

END HZ_GEOGRAPHY_PUB;

/
