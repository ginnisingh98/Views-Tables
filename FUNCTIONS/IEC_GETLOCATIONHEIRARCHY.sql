--------------------------------------------------------
--  DDL for Function IEC_GETLOCATIONHEIRARCHY
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE FUNCTION "APPS"."IEC_GETLOCATIONHEIRARCHY" (p_loc_id IN NUMBER)
                  RETURN VARCHAR2
               IS
                  l_loc_name          VARCHAR2(500);
                  l_loc_type          VARCHAR2(500);
                  l_loc_id            NUMBER(15);
                  l_parent_loc_id     NUMBER(15);

                  l_heirarchy_str     VARCHAR2(4000);
               BEGIN

                  -- Get name for location of leaf node
                  SELECT LOCATION_AREA_NAME, PARENT_LOCATION_AREA_ID
                  INTO l_loc_name, l_parent_loc_id
                  FROM JTF_LOC_AREAS_VL
                  WHERE LOCATION_AREA_ID = p_loc_id;

                  l_heirarchy_str := l_loc_name;
                  l_loc_id := l_parent_loc_id;

                  WHILE l_loc_id IS NOT NULL LOOP
                     SELECT LOCATION_AREA_NAME, LOCATION_TYPE_CODE, PARENT_LOCATION_AREA_ID
                     INTO l_loc_name, l_loc_type, l_parent_loc_id
                     FROM JTF_LOC_AREAS_VL
                     WHERE LOCATION_AREA_ID = l_loc_id;

                     l_heirarchy_str := l_loc_name || '/' || l_heirarchy_str;
                     l_loc_id := l_parent_loc_id;

                     EXIT WHEN L_loc_type = 'AREA1';

                  END LOOP;
                  RETURN l_heirarchy_str;
               END;
 

/
