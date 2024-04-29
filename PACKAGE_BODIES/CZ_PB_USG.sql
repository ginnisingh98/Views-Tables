--------------------------------------------------------
--  DDL for Package Body CZ_PB_USG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."CZ_PB_USG" AS
/*	$Header: czpbusgb.pls 120.2 2006/04/25 03:45:18 kdande ship $	*/

FUNCTION INVERT_MAP(usage_map IN VARCHAR2)
RETURN VARCHAR2
IS LANGUAGE JAVA
NAME 'oracle.apps.cz.utilities.EffectivityUtilities.invertMap (java.lang.String)
return java.lang.String';

FUNCTION MAP_LESS_USAGE_ID(usage_id	IN NUMBER, usage_map IN VARCHAR2 )
RETURN VARCHAR2
AS LANGUAGE JAVA NAME 'oracle.apps.cz.utilities.EffectivityUtilities.mapLessUsageId(int, java.lang.String)
return java.lang.String';

PROCEDURE REMOVE_USAGE_ID(usage_id IN NUMBER, usage_map IN OUT NOCOPY VARCHAR2) AS
BEGIN
  usage_map := MAP_LESS_USAGE_ID(usage_id, usage_map);
END REMOVE_USAGE_ID;

FUNCTION MAP_PLUS_USAGE_ID(usage_id IN NUMBER, usage_map IN	VARCHAR2 )
RETURN VARCHAR2
AS LANGUAGE JAVA NAME 'oracle.apps.cz.utilities.EffectivityUtilities.mapPlusUsageId(int, java.lang.String)
return java.lang.String';

PROCEDURE ADD_USAGE_ID(usage_id IN	NUMBER, usage_map	IN OUT NOCOPY VARCHAR2)
AS
BEGIN
  usage_map := MAP_PLUS_USAGE_ID(usage_id, usage_map);
END ADD_USAGE_ID;

FUNCTION MAP_HAS_USAGE_ID(usage_id	IN	NUMBER, usage_map	IN	VARCHAR2)
RETURN NUMBER
AS LANGUAGE JAVA NAME 'oracle.apps.cz.utilities.EffectivityUtilities.mapHasUsageId(int, java.lang.String)
return int';

FUNCTION MAP_HAS_USAGE_NAME(usage_name IN	VARCHAR2,usage_map IN VARCHAR2)
RETURN NUMBER
IS
usageId	NUMBER;
answer	NUMBER;
BEGIN
  SELECT model_usage_id INTO usageId
    FROM  cz_model_usages
  WHERE name = usage_name;
  answer := MAP_HAS_USAGE_ID(usageId, usage_map);
  RETURN answer;
EXCEPTION
WHEN NO_DATA_FOUND THEN
	RETURN -1; -- The named usage dosen't exist
END MAP_HAS_USAGE_NAME;

FUNCTION MAP_LESS_USAGE_NAME(usage_name IN VARCHAR2,usage_map IN VARCHAR2)
RETURN VARCHAR2
AS
usageId	NUMBER;
outMap	VARCHAR2(16);
BEGIN
  SELECT model_usage_id INTO usageId
    FROM  cz_model_usages
  WHERE name = usage_name;
  outMap := MAP_LESS_USAGE_ID(usageId, usage_map);
  RETURN outMap;
EXCEPTION
-- Return '-1' if the named usage dosen't exist
  WHEN NO_DATA_FOUND THEN RETURN '-1';
END MAP_LESS_USAGE_NAME;


PROCEDURE REMOVE_USAGE_NAME(usage_name	IN	VARCHAR2,usage_map IN OUT NOCOPY VARCHAR2)
AS
tmp_map VARCHAR2(16);
BEGIN
  tmp_map := MAP_LESS_USAGE_NAME(usage_name, usage_map);
  IF tmp_map <> '-1' THEN
    usage_map := tmp_map;
  ELSE
    RAISE_APPLICATION_ERROR (-20001,
      'Usage does not exist');
  END IF;
END REMOVE_USAGE_NAME;


FUNCTION MAP_PLUS_USAGE_NAME(usage_name IN VARCHAR2,usage_map IN	VARCHAR2)
RETURN VARCHAR2
AS
usageId	NUMBER;
outMap	VARCHAR2(16);
BEGIN
  SELECT model_usage_id INTO usageId
    FROM  cz_model_usages
  WHERE name = usage_name;
  outMap := MAP_PLUS_USAGE_ID(usageId, usage_map);
  RETURN outMap;
EXCEPTION
-- Return '-1' if the named usage dosen't exist
  WHEN NO_DATA_FOUND THEN RETURN '-1';
END MAP_PLUS_USAGE_NAME;


PROCEDURE ADD_USAGE_BY_NAME(usage_name	IN	VARCHAR2,
                            usage_map	IN   OUT NOCOPY VARCHAR2
	        	   ) AS
tmp_map VARCHAR2(16);
BEGIN
  tmp_map := MAP_PLUS_USAGE_NAME(usage_name, usage_map);
  IF tmp_map <> '-1' THEN
    usage_map := tmp_map;
  ELSE
    RAISE_APPLICATION_ERROR (-20001,
      'Usage does not exist');
  END IF;
END ADD_USAGE_BY_NAME;


FUNCTION LIST_USAGES_IN_MAP_STRING(usage_map	IN	VARCHAR2)
RETURN VARCHAR2
AS LANGUAGE JAVA
NAME 'oracle.apps.cz.utilities.EffectivityUtilities.listUsagesInMap (java.lang.String)
return java.lang.String';


FUNCTION LIST_USAGES_IN_MAP(usage_map IN	VARCHAR2)
RETURN USAGE_NAME_LIST
AS
usages_list USAGE_NAME_LIST;
usages_string VARCHAR2(16400);
v_index NUMBER :=1;
BEGIN
  usages_string := LIST_USAGES_IN_MAP_STRING(usage_map);
  WHILE length(usages_string) >0 LOOP
    usages_list(v_index) := SUBSTR(usages_string, 1, INSTR(usages_string, '|') - 1);
    usages_string := SUBSTR(usages_string, INSTR(usages_string, '|') + 1);
    v_index := v_index+1;
  END LOOP;
  RETURN usages_list;
END LIST_USAGES_IN_MAP;
-----------
PROCEDURE DELETE_USAGE(usageId		IN	NUMBER,
		       	delete_status    IN OUT NOCOPY  VARCHAR2)
AS


TYPE t_indexes IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
TYPE t_mask	IS TABLE OF cz_ps_nodes.effective_usage_mask%TYPE INDEX BY BINARY_INTEGER;

v_nodes		t_indexes;
v_rules		t_indexes;
v_masks_nodes	t_mask;
v_masks_rules	t_mask;


v_new_mask	VARCHAR2(16);
v_last_old_mask	VARCHAR2(16);
v_first_index BINARY_INTEGER;

BEGIN
	v_nodes.DELETE;
	v_rules.DELETE;
	v_masks_nodes.DELETE;
	v_masks_rules.DELETE;


	BEGIN
		SELECT ps_node_id,
		       effective_usage_mask
		BULK
		COLLECT
		INTO	v_nodes,
			v_masks_nodes
		FROM cz_ps_nodes
		WHERE   effective_usage_mask NOT IN ('0', '0000000000000000')
		ORDER BY effective_usage_mask;
	EXCEPTION
	WHEN OTHERS THEN
	 NULL;
	END;

	BEGIN
		SELECT rule_id,
		       effective_usage_mask
		BULK
		COLLECT
		INTO	v_rules,
			v_masks_rules
		FROM cz_rules
		WHERE   effective_usage_mask NOT IN ('0', '0000000000000000')
		ORDER BY effective_usage_mask;
	EXCEPTION
	WHEN OTHERS THEN
	 NULL;
	END;


	BEGIN
		UPDATE cz_model_usages
		SET     in_use = 'X'
		WHERE model_usage_id = usageId;

  		DELETE FROM cz_publication_usages
    		WHERE usage_id = usageId;

		DELETE FROM cz_rp_entries
		WHERE object_type ='USG' and object_id = usageId;

		IF (v_nodes.COUNT > 0) THEN
			v_first_index := v_masks_nodes.FIRST;
			v_last_old_mask := v_masks_nodes(v_first_index);
			v_new_mask := MAP_LESS_USAGE_ID(usageId, v_masks_nodes(v_first_index));
			v_masks_nodes(v_first_index) := v_new_mask;

			FOR i IN v_masks_nodes.NEXT(v_first_index)..v_masks_nodes.LAST
			LOOP
			   IF v_masks_nodes(i) = v_last_old_mask THEN
				v_masks_nodes(i) := v_masks_nodes(i-1);
			   ELSE
				v_last_old_mask := v_masks_nodes(i);

			  	v_new_mask := MAP_LESS_USAGE_ID(usageId, v_masks_nodes(i));
			  	v_masks_nodes(i) := v_new_mask;
			   END IF;
			END LOOP;

			FORALL i IN v_nodes.FIRST..v_nodes.LAST
	 		 UPDATE cz_ps_nodes
	 		    SET effective_usage_mask = v_masks_nodes(i)
	 		 WHERE  ps_node_id = v_nodes(i);

		END IF;

		IF (v_rules.COUNT > 0) THEN
			v_first_index := v_masks_rules.FIRST;
			v_last_old_mask := v_masks_rules(v_first_index);
			v_new_mask := MAP_LESS_USAGE_ID(usageId, v_masks_rules(v_first_index));
			v_masks_rules(v_first_index) := v_new_mask;

			FOR i IN v_masks_rules.NEXT(v_first_index)..v_masks_rules.LAST
			LOOP
			   IF v_masks_rules(i) = v_last_old_mask THEN
				v_masks_rules(i) := v_masks_rules(i-1);
			   ELSE
				v_last_old_mask := v_masks_rules(i);

			  	v_new_mask := MAP_LESS_USAGE_ID(usageId, v_masks_rules(i));
			  	v_masks_rules(i) := v_new_mask;
			   END IF;
			END LOOP;

			FORALL i IN v_rules.FIRST..v_rules.LAST
	  		UPDATE cz_rules
	     		SET    effective_usage_mask = v_masks_rules(i)
	  		WHERE  rule_id = v_rules(i);
		END IF;
	EXCEPTION
	WHEN OTHERS THEN
	delete_status := '-1';
	END;

	IF SQLCODE = 0 THEN
  		delete_status := '0';
	END IF;


END DELETE_USAGE;

END;

/
