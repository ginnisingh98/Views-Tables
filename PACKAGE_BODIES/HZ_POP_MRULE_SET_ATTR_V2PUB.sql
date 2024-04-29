--------------------------------------------------------
--  DDL for Package Body HZ_POP_MRULE_SET_ATTR_V2PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."HZ_POP_MRULE_SET_ATTR_V2PUB" AS
/*$Header: ARHMSARB.pls 120.0 2005/05/25 21:08:26 achung noship $ */


/**
 * PROCEDURE POP_MRULE_SET_ATTRIBUTES
 *
 * DESCRIPTION
 *     This procedure populates all the primary and secondary attributes
 *     of a condition match rule into the set.
 *
 * EXTERNAL PROCEDURES/FUNCTIONS ACCESSED
 *
 * ARGUMENTS
 *   IN:
 *     p_mrule_set_id                 Match rule set id.
 *
 *   IN/OUT:
 *   p_mrule_set_id  IN NUMBER
 *   p_cond_mrule_id IN NUMBER
 *   OUT:
 *
 * NOTES
 *
 * MODIFICATION HISTORY
 *
 *
 *
 */
PROCEDURE update_prim_display_order(p_mrule_set_id IN NUMBER);
PROCEDURE update_sec_display_order(p_mrule_set_id  IN NUMBER);

PROCEDURE pop_mrule_set_attributes(p_mrule_set_id IN NUMBER)
 IS
 CURSOR c_insert_prim IS ( SELECT p.ATTRIBUTE_ID FROM
 			   (SELECT  unique p1.ATTRIBUTE_ID
                            FROM   HZ_MATCH_RULE_PRIMARY p1
		            WHERE  p1.match_rule_id in (Select unique condition_match_rule_id
			                               from hz_match_rule_conditions
			  	  		       where match_rule_set_id = p_mrule_set_id)
                            UNION
			    (SELECT unique  attribute_id
			     from hz_match_rule_conditions
			     where match_rule_set_id = p_mrule_set_id
			     and attribute_id is not null
			    )
		           ) p
                          WHERE NOT EXISTS (
			   SELECT  1
                           FROM   HZ_MATCH_RULE_PRIMARY p1
		           WHERE  p1.match_rule_id = p_mrule_set_id
			   AND    p1.ATTRIBUTE_ID = p.ATTRIBUTE_ID
			  )
			 );
CURSOR c_delete_prim IS  SELECT primary_attribute_id
			 FROM HZ_MATCH_RULE_PRIMARY
			 WHERE match_rule_id = p_mrule_set_id
			 AND ATTRIBUTE_ID IN (SELECT  unique p1.ATTRIBUTE_ID
					      FROM   HZ_MATCH_RULE_PRIMARY p1
					      WHERE  p1.match_rule_id = p_mrule_set_id
					      MINUS
					       (SELECT  unique p1.ATTRIBUTE_ID
					         FROM   HZ_MATCH_RULE_PRIMARY p1
					         WHERE  p1.match_rule_id in (Select unique condition_match_rule_id
					   			          from hz_match_rule_conditions
									  where match_rule_set_id = p_mrule_set_id)
					          UNION
						  (SELECT unique  attribute_id
						     from hz_match_rule_conditions
						     where match_rule_set_id = p_mrule_set_id
						     and attribute_id is not null
						  )
					       )
					      );
CURSOR c_insert_sec IS ( SELECT  s1.ATTRIBUTE_ID
                         FROM   HZ_MATCH_RULE_SECONDARY s1
		         WHERE  s1.match_rule_id in (Select unique condition_match_rule_id
			                               from hz_match_rule_conditions
				  		       where match_rule_set_id = p_mrule_set_id)
                          AND NOT EXISTS(SELECT 1 FROM HZ_MATCH_RULE_SECONDARY s2
				         WHERE  s2.match_rule_id = p_mrule_set_id
					 AND    s2.ATTRIBUTE_ID = s1.ATTRIBUTE_ID
					 )
			 );

CURSOR c_delete_sec IS  SELECT secondary_attribute_id
			 FROM HZ_MATCH_RULE_SECONDARY
			 WHERE match_rule_id = p_mrule_set_id
			 AND ATTRIBUTE_ID IN (SELECT  unique s1.ATTRIBUTE_ID
					      FROM   HZ_MATCH_RULE_SECONDARY s1
					      WHERE  s1.match_rule_id = p_mrule_set_id
					      MINUS
					      SELECT  unique s1.ATTRIBUTE_ID
					      FROM   HZ_MATCH_RULE_SECONDARY s1
					      WHERE  s1.match_rule_id in (Select unique condition_match_rule_id
							  	          from hz_match_rule_conditions
									  where match_rule_set_id = p_mrule_set_id)
					     );

TYPE t_attr_id_list IS TABLE OF NUMBER index by binary_integer;
v_attr_id_list t_attr_id_list;
x_primary_attribute_id NUMBER;
x_secondary_attribute_id NUMBER;
l_object_version_number NUMBER;

 BEGIN

  l_object_version_number :=1;

  /* Populate the primary attributes */

  OPEN c_insert_prim;
  FETCH c_insert_prim BULK COLLECT INTO v_attr_id_list;
  CLOSE c_insert_prim;

  IF v_attr_id_list.COUNT >0 THEN
    FOR i IN  v_attr_id_list.FIRST..v_attr_id_list.LAST
    LOOP
     HZ_MATCH_RULE_PRIMARY_PKG.INSERT_ROW(x_primary_attribute_id,               --px_PRIMARY_ATTRIBUTE_ID
			                  p_mrule_set_id,                       --p_MATCH_RULE_ID
					  v_attr_id_list(i),                    --p_ATTRIBUTE_ID
					  NULL,			                --p_ACTIVE_FLAG
					  NULL,			                --p_FILTER_FLAG
					  HZ_UTILITY_V2PUB.CREATED_BY,          --p_CREATED_BY
					  HZ_UTILITY_V2PUB.CREATION_DATE,       --p_CREATION_DATE
					  HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,   --p_LAST_UPDATE_LOGIN
					  HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,    --p_LAST_UPDATE_DATE
					  HZ_UTILITY_V2PUB.LAST_UPDATED_BY,     --p_LAST_UPDATED_BY
					  l_object_version_number               --p_OBJECT_VERSION_NUMBER
					  );
    x_primary_attribute_id := NULL;
    END LOOP;
  END IF;

  /* Delete the unnecessary primary attributes */

  OPEN c_delete_prim;
  FETCH c_delete_prim BULK COLLECT INTO v_attr_id_list;
  CLOSE c_delete_prim;

  IF v_attr_id_list.COUNT >0 THEN
    FORALL i IN  v_attr_id_list.FIRST..v_attr_id_list.LAST
     DELETE FROM HZ_MATCH_RULE_PRIMARY
     WHERE PRIMARY_ATTRIBUTE_ID = v_attr_id_list(i);
  END IF;
  /* Update the primary attributes display order */
  update_prim_display_order(p_mrule_set_id);

  /* Populate the secondary attributes */

  OPEN c_insert_sec;
  FETCH c_insert_sec BULK COLLECT INTO v_attr_id_list;
  CLOSE c_insert_sec;

  IF v_attr_id_list.COUNT >0 THEN
    FOR i IN v_attr_id_list.FIRST..v_attr_id_list.LAST
    LOOP
     HZ_MATCH_RULE_SECONDARY_PKG.INSERT_ROW(x_secondary_attribute_id,           --px_SECONDARY_ATTRIBUTE_ID
			                  p_mrule_set_id,                       --p_MATCH_RULE_ID
					  v_attr_id_list(i),                    --p_ATTRIBUTE_ID
					  0,			                --p_SCORE
					  NULL,			                --p_ACTIVE_FLAG
					  HZ_UTILITY_V2PUB.CREATED_BY,          --p_CREATED_BY
					  HZ_UTILITY_V2PUB.CREATION_DATE,       --p_CREATION_DATE
					  HZ_UTILITY_V2PUB.LAST_UPDATE_LOGIN,   --p_LAST_UPDATE_LOGIN
					  HZ_UTILITY_V2PUB.LAST_UPDATE_DATE,    --p_LAST_UPDATE_DATE
					  HZ_UTILITY_V2PUB.LAST_UPDATED_BY,     --p_LAST_UPDATED_BY
					  l_object_version_number               --p_OBJECT_VERSION_NUMBER
					  );
      x_secondary_attribute_id := NULL;
    END LOOP;
  END IF;

 /* Delete the unnecessary secondary attributes */

  OPEN c_delete_sec;
  FETCH c_delete_sec BULK COLLECT INTO v_attr_id_list;
  CLOSE c_delete_sec;

  IF v_attr_id_list.COUNT >0 THEN
    FORALL i IN v_attr_id_list.FIRST..v_attr_id_list.LAST
     DELETE FROM HZ_MATCH_RULE_SECONDARY
     WHERE SECONDARY_ATTRIBUTE_ID = v_attr_id_list(i);
  END IF;

 /* Update the secondary attributes display order */
  update_sec_display_order(p_mrule_set_id);

 END;

PROCEDURE update_prim_display_order(p_mrule_set_id NUMBER)
IS
l_g_miss_num NUMBER;
TYPE t_prim_attr_list IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

v_attr_id_list    t_prim_attr_list;
v_attr_order_list t_prim_attr_list;

CURSOR c_prim_attr IS
	SELECT unique  attribute_id,0 display_order
	from hz_match_rule_conditions
	where match_rule_set_id = p_mrule_set_id
	and attribute_id is not null
	UNION
	SELECT  p1.ATTRIBUTE_ID,min(nvl(p1.display_order,l_g_miss_num)) display_order
	FROM    HZ_MATCH_RULE_PRIMARY p1
	WHERE  EXISTS  (Select 1
			from  hz_match_rule_conditions cond1
			where cond1.match_rule_set_id = p_mrule_set_id
			and   cond1.condition_match_rule_id = p1.match_rule_id
		       )
	AND NOT EXISTS (SELECT 1 from hz_match_rule_conditions cond2
			where cond2.match_rule_set_id = p_mrule_set_id
			and  cond2.attribute_id = p1.attribute_id
			)
	group by p1.ATTRIBUTE_ID;


BEGIN
 l_g_miss_num := FND_API.G_MISS_NUM;

 OPEN c_prim_attr;
 FETCH c_prim_attr BULK COLLECT INTO v_attr_id_list,v_attr_order_list;
 CLOSE c_prim_attr;
 FORALL i IN v_attr_id_list.FIRST..v_attr_id_list.LAST
  UPDATE HZ_MATCH_RULE_PRIMARY
  SET   DISPLAY_ORDER = decode(v_attr_order_list(i),l_g_miss_num,null,v_attr_order_list(i))
  WHERE match_rule_id = p_mrule_set_id
  AND   attribute_id = v_attr_id_list(i);

END;


PROCEDURE update_sec_display_order(p_mrule_set_id  IN NUMBER)
IS
l_g_miss_num NUMBER;
TYPE t_sec_attr_list IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
v_attr_id_list    t_sec_attr_list;
v_attr_order_list t_sec_attr_list;


CURSOR c_sec_attr IS
	SELECT s1.ATTRIBUTE_ID,min(nvl(s1.display_order,l_g_miss_num)) display_order
	FROM    HZ_MATCH_RULE_SECONDARY s1
	WHERE  EXISTS  (Select 1
			from  hz_match_rule_conditions cond1
			where cond1.match_rule_set_id = p_mrule_set_id
			and   cond1.condition_match_rule_id = s1.match_rule_id
		       )
	group by s1.ATTRIBUTE_ID;


BEGIN
 l_g_miss_num := FND_API.G_MISS_NUM;

 OPEN c_sec_attr;
 FETCH c_sec_attr BULK COLLECT INTO v_attr_id_list,v_attr_order_list;
 CLOSE c_sec_attr;

 FORALL i IN v_attr_id_list.FIRST..v_attr_id_list.LAST
  UPDATE HZ_MATCH_RULE_SECONDARY
  SET   DISPLAY_ORDER = decode(v_attr_order_list(i),l_g_miss_num,null,v_attr_order_list(i))
  WHERE match_rule_id = p_mrule_set_id
  AND   attribute_id  = v_attr_id_list(i);


END;


END HZ_POP_MRULE_SET_ATTR_V2PUB;


/
