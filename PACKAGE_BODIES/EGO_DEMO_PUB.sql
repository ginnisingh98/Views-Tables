--------------------------------------------------------
--  DDL for Package Body EGO_DEMO_PUB
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EGO_DEMO_PUB" AS
/*$Header: EGODEMOB.pls 120.1 2007/05/09 15:03:40 dsakalle noship $ */
----------------------------------------------------------------------------
-- A.Calculate_Grade
----------------------------------------------------------------------------
FUNCTION  Calculate_Grade (
                  p_component_risk IN NUMBER
                , p_lead_time      IN NUMBER
                , p_cost           IN NUMBER
                , p_supplier_risk  IN NUMBER
                )
RETURN NUMBER
IS

 p_grade NUMBER :=10;

BEGIN

 if(p_cost > 0) then
  if (p_cost > 10 and p_cost <= 20) then
    p_grade := p_grade - 1.15;
  elsif (p_cost > 20 and p_cost <= 50) then
    p_grade := p_grade - 2.38;
  else
    p_grade := p_grade - 3.01;
  end if;
 end if;

 if (p_component_risk > 0) then
  if (p_component_risk > 1 AND p_component_risk <= 3) then
    p_grade := p_grade - .95;
  elsif (p_component_risk > 3 and p_component_risk <= 5) then
    p_grade := p_grade - 1.07;
  else
    p_grade := p_grade - 1.93;
  end if;
 end if;

 if (p_lead_time > 0 ) then
  if (p_lead_time > 10  AND p_lead_time <= 20) then
    p_grade := p_grade - .55;
  elsif (p_lead_time > 20 and p_lead_time <= 45) then
    p_grade := p_grade - 1.35;
  else
    p_grade := p_grade - 2.06;
  end if;
 end if;

 if (p_supplier_risk > 0)  then
  if (p_supplier_risk > 1  AND p_supplier_risk <= 2) then
    p_grade := p_grade - .70;
  elsif (p_supplier_risk > 2 and p_supplier_risk <= 5) then
    p_grade := p_grade - 1.14;
  else
    p_grade := p_grade - 2.01;
  end if;
 end if;
 p_grade := round(p_grade);
 return p_grade;
EXCEPTION
WHEN OTHERS THEN
NULL;

  END Calculate_Grade;

----------------------------------------------------------------------------

---Generate_Item_Number

----------------------------------------------------------------------------

FUNCTION  Generate_Item_Number (
                  p_Section_Code   IN VARCHAR2
                , p_Model_Code     IN VARCHAR2
                , p_Prototype_Code IN VARCHAR2
                )
RETURN VARCHAR2
IS

 l_item_number VARCHAR2(30) := '';
 l_item_squence VARCHAR2(30) := '';

BEGIN

   SELECT EGO_DEMO_ITEM_NUMBER_S.NEXTVAL
   INTO l_item_squence
   FROM DUAL;

l_item_number := p_Section_Code || l_item_squence || ' ' || p_Model_Code || p_Prototype_Code || ' ' || '0000';

return l_item_number;

EXCEPTION
WHEN OTHERS THEN
NULL;

END Generate_Item_Number;

----------------------------------------------------------------------------

---Generate_Item_Desc

----------------------------------------------------------------------------

FUNCTION  Generate_Item_Desc (
                  p_Section_Code   IN VARCHAR2
                , p_Model_Code     IN VARCHAR2
                , p_Product_Line   IN VARCHAR2
                )
RETURN VARCHAR2
IS

 l_item_desc VARCHAR2(30) := '';


BEGIN

l_item_desc := p_Product_Line || '.' || p_Model_Code || '.' || p_Section_Code;

return l_item_desc;

EXCEPTION
WHEN OTHERS THEN
NULL;

END Generate_Item_Desc;


----------------------------------------------------------------------------

PROCEDURE  Calculate_Weightage (
                  p_param1         IN VARCHAR2
                , p_param2         IN VARCHAR2
                , p_param3         IN VARCHAR2
                , p_result1        IN OUT NOCOPY NUMBER
                , p_result2        IN OUT NOCOPY NUMBER
                , p_result3        IN OUT NOCOPY NUMBER
                )
IS
  p_param1_num  NUMBER :=0;
  p_param2_num  NUMBER :=0;
  p_param3_num  NUMBER :=0;

BEGIN

 if(p_param1 = 'High') then
    p_param1_num := 3;
 elsif (p_param1 = 'Medium') then
    p_param1_num := 2;
 elsif(p_param1 = 'Low') then
    p_param1_num := 1;
 end if;

  if(p_param2 = 'High') then
            p_param2_num := 3;
         elsif (p_param2 = 'Medium') then
            p_param2_num := 2;
         elsif(p_param2 = 'Low') then
    p_param2_num := 1;
 end if;

 if(p_param3 = 'High') then
    p_param3_num := 3;
 elsif (p_param3 = 'Medium') then
    p_param3_num := 2;
 elsif(p_param3 = 'Low') then
    p_param3_num := 1;
 end if;

 p_result1 := round((0.5*p_param1_num + 0.25*p_param2_num + 0.25*p_param3_num),2);
 p_result2 := round((0.25*p_param1_num + 0.5*p_param2_num + 0.25*p_param3_num),2);
 p_result3 := round((0.25*p_param1_num + 0.25*p_param2_num + 0.5*p_param3_num),2);


EXCEPTION
WHEN OTHERS THEN
NULL;

END Calculate_Weightage;

----------------------------------------------------------------------------------
-- GenCapacitorItemDesc
----------------------------------------------------------------------------------
FUNCTION  GenCapacitorItemDesc (
                    p1 IN VARCHAR2
                  , p2 IN NUMBER
                  , p3 IN NUMBER
                  , p4 IN NUMBER
                  , p5 IN VARCHAR2
                  , p6 IN VARCHAR2
                  , p7 IN VARCHAR2
                  )
RETURN VARCHAR2
IS

l_ItemDesc VARCHAR2(300) := '' ; -- Description
l_Del  CONSTANT VARCHAR2(2) := ','; -- Deliminator

BEGIN

l_ItemDesc := 'Capacitor' || l_Del || p1 || l_Del || p2 ||'uF' || l_Del || p3 || 'V' || l_Del || p4 ||'%' || l_Del || p5 || l_Del || p6 || l_Del || p7;

RETURN l_ItemDesc ;

EXCEPTION
WHEN OTHERS THEN
NULL;

END GenCapacitorItemDesc;

-----------------------------------------------------------------------------------
-- ClassifyECO
-----------------------------------------------------------------------------------

PROCEDURE  ClassifyECO (
                 pA1 IN VARCHAR2
               , pB1 IN VARCHAR2
               , pB2 IN VARCHAR2
               , pB3 IN VARCHAR2
               , pChangeId IN NUMBER
               )
IS
  l_class_code          VARCHAR2(80);
  l_class_code_id       NUMBER;
BEGIN

IF(pA1 = 'N') THEN
   l_class_code := 'Class A';
ELSIF (pB1 = 'Y' OR pB2 = 'Y' OR pB3 = 'Y') THEN
   l_class_code := 'Class B';
ELSE
   l_class_code := 'Class C';
END IF;

SELECT classification_id
INTO l_class_code_id
FROM eng_change_classifications_vl
WHERE classification_name = l_class_code;

IF l_class_code_id is not null
THEN

  UPDATE eng_engineering_changes
  SET classification_id = l_class_code_id
  where change_id = pChangeId;

 commit;

END IF;

EXCEPTION
WHEN OTHERS THEN
NULL;

END ClassifyECO;

------------------------------------------------------------------------------

FUNCTION Gen_Item_Num_With_Key_Attrs( p_Section_Code          IN VARCHAR2
                                     ,p_Model_Code            IN VARCHAR2
                                     ,p_Prototype_Code        IN VARCHAR2
                                     ,p_col_name_value_array  IN EGO_COL_NAME_VALUE_PAIR_ARRAY
                                    )
RETURN VARCHAR2
IS
  l_item_number    VARCHAR2(300);
  l_item_squence   VARCHAR2(300);
  l_style_item_id  NUMBER;
  l_icc_id         NUMBER;
  l_item_type      VARCHAR2(1000);
  l_ego_col_name_value_pair_obj      EGO_COL_NAME_VALUE_PAIR_OBJ;
  l_style_item_num MTL_SYSTEM_ITEMS_KFV.CONCATENATED_SEGMENTS%TYPE;
BEGIN
  SELECT EGO_DEMO_ITEM_NUMBER_S.NEXTVAL
  INTO l_item_squence
  FROM DUAL;

  IF p_col_name_value_array IS NOT NULL THEN
    FOR l_row_table_index  IN p_col_name_value_array.first .. p_col_name_value_array.last
    LOOP
      l_ego_col_name_value_pair_obj :=  p_col_name_value_array(l_row_table_index);
      IF l_ego_col_name_value_pair_obj.NAME = 'STYLE_ITEM_ID' THEN
        l_style_item_id := l_ego_col_name_value_pair_obj.VALUE;
      ELSIF l_ego_col_name_value_pair_obj.NAME = 'ITEM_TYPE' THEN
        l_item_type := l_ego_col_name_value_pair_obj.VALUE;
      ELSIF l_ego_col_name_value_pair_obj.NAME = 'ITEM_CATALOG_GROUP_ID' THEN
        l_icc_id := l_ego_col_name_value_pair_obj.VALUE;
      END IF;
    END LOOP;
  END IF;

  IF l_style_item_id IS NOT NULL THEN
    BEGIN
      SELECT SUBSTR(CONCATENATED_SEGMENTS, 1, 20) INTO l_style_item_num
      FROM MTL_SYSTEM_ITEMS_KFV
      WHERE INVENTORY_ITEM_ID = l_style_item_id
        AND ROWNUM = 1;
    EXCEPTION WHEN OTHERS THEN
      l_style_item_num := 'EXCEPTION';
    END;
    l_item_number := l_style_item_num || '-' || l_item_squence;
  ELSE
    l_item_number := 'ICC-' || l_icc_id || '-ITYPE-' || l_item_type || '-' || l_item_squence;
  END IF;

  RETURN l_item_number;
EXCEPTION WHEN OTHERS THEN
  RETURN l_item_number;
END Gen_Item_Num_With_Key_Attrs;


END EGO_DEMO_PUB;

/
