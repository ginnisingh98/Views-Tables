--------------------------------------------------------
--  DDL for Package Body QP_CATEGORY_MAPPING_RULE
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."QP_CATEGORY_MAPPING_RULE" AS
/* $Header: QPXPSICB.pls 120.7.12010000.3 2009/09/18 09:37:44 dnema ship $ */

FUNCTION Get_Item_Category (p_inventory_item_id IN NUMBER)
RETURN QP_Attr_Mapping_PUB.t_MultiRecord
IS

--TYPE t_cursor IS REF CURSOR;

x_category_ids       QP_Attr_Mapping_PUB.t_MultiRecord;

--8805312
l_int_category_ids       QP_Attr_Mapping_PUB.t_MultiRecord;

l_category_id        VARCHAR2(30);
v_count              NUMBER := 1;
--l_category_cursor    t_cursor;
l_appl_id            NUMBER;
l_category_set_id_7  NUMBER;
l_category_set_id_11 NUMBER;
l_hierarchy_enabled  VARCHAR2(1);
l_org_id             NUMBER;
l_ou_org_id NUMBER;
--
-- commented out for Product Hierarchy changes
/*
-- Changed cursor for 3125141
CURSOR l_category_cursor (org_id_in number,appl_id_in number) is
  SELECT a.category_id
  FROM mtl_item_categories a,
       mtl_categories_b b,
       mtl_default_category_sets c,
       mtl_category_sets_b d
  WHERE a.inventory_item_id = p_inventory_item_id
  AND a.organization_id = org_id_in
  AND a.category_id = b.category_id
  AND c.category_set_id = d.category_set_id
  AND c.functional_area_id = decode(appl_id_in,201,2,7)
  AND b.structure_id = d.structure_id;

CURSOR l_exploded_category_cursor (org_id_in number, appl_id_in number) is
    SELECT parent_id
    FROM   eni_denorm_hierarchies a,
           mtl_item_categories b,
           mtl_default_category_sets c
    WHERE  inventory_item_id = p_inventory_item_id and
           organization_id = org_id_in and
           a.object_type = 'CATEGORY_SET' and
           a.object_id = c.category_set_id and
           b.category_id = child_id and
           functional_area_id = decode(appl_id_in,201,2,7);
CURSOR l_exploded_category_cursor (org_id_in number, appl_id_in number,
                                   category_set_id_in number) is
    SELECT parent_id
    FROM   eni_denorm_hierarchies a,
           mtl_item_categories b,
           mtl_default_category_sets c
    WHERE  inventory_item_id = p_inventory_item_id and
           organization_id = org_id_in and
           b.category_set_id = category_set_id_in and
           a.object_type = 'CATEGORY_SET' and
           a.object_id = c.category_set_id and
           b.category_id = child_id and
           functional_area_id = decode(appl_id_in,201,2,11);
*/
  CURSOR l_category_cursor (org_id_in number,req_type_code_in VARCHAR2) is
  SELECT distinct /*+ ordered use_nl(b c d) */ a.category_id
  FROM mtl_item_categories a,
       mtl_categories_b b,
       mtl_default_category_sets c,
       mtl_category_sets_b d
  WHERE a.inventory_item_id = p_inventory_item_id
  AND a.organization_id = org_id_in
  AND a.category_id = b.category_id
  AND c.category_set_id = d.category_set_id
  AND b.structure_id = d.structure_id
  AND nvl(d.hierarchy_enabled,'N') = 'N'
  AND c.functional_area_id in (SELECT distinct FNAREA.FUNCTIONAL_AREA_ID
                               FROM QP_PTE_REQUEST_TYPES_B REQ,
                                    QP_PTE_SOURCE_SYSTEMS SOU,
                                    QP_SOURCESYSTEM_FNAREA_MAP FNAREA
                               WHERE REQ.REQUEST_TYPE_CODE = req_type_code_in and REQ.ENABLED_FLAG = 'Y' and
                                     REQ.PTE_CODE = SOU.PTE_CODE and SOU.ENABLED_FLAG = 'Y'and
                                     SOU.PTE_SOURCE_SYSTEM_ID = FNAREA.PTE_SOURCE_SYSTEM_ID and
                                     FNAREA.ENABLED_FLAG = 'Y');

-- bug 8805312
-- Changed cursor definition
 /*   CURSOR l_exploded_category_cursor (org_id_in number, req_type_code_in VARCHAR2) is
    SELECT distinct /*+ ORDERED USE_NL(c d b a) */ /*a.parent_id
    FROM   mtl_default_category_sets c,
           mtl_category_sets_b d,
           mtl_item_categories b,
           eni_denorm_hierarchies a
    WHERE  b.inventory_item_id = p_inventory_item_id and
           b.organization_id = org_id_in and
           b.category_set_id = c.category_set_id and
           a.object_type = 'CATEGORY_SET' and
           c.category_set_id = d.category_set_id and
           d.hierarchy_enabled = 'Y' and
           a.object_id = c.category_set_id and
           b.category_id = a.child_id and
           c.functional_area_id in (SELECT /*+ ORDERED USE_NL(REQ SOU FNAREA)*//*
                               distinct FNAREA.FUNCTIONAL_AREA_ID
                               FROM QP_PTE_REQUEST_TYPES_B REQ,
                                    QP_PTE_SOURCE_SYSTEMS SOU,
                                    QP_SOURCESYSTEM_FNAREA_MAP FNAREA
                               WHERE REQ.REQUEST_TYPE_CODE = req_type_code_in
                               and REQ.ENABLED_FLAG = 'Y'
                               and REQ.PTE_CODE = SOU.PTE_CODE
                               and SOU.ENABLED_FLAG = 'Y'
                               and SOU.PTE_SOURCE_SYSTEM_ID =
                                       FNAREA.PTE_SOURCE_SYSTEM_ID
                               and FNAREA.ENABLED_FLAG = 'Y');*/

CURSOR l_exploded_category_cursor (org_id_in number, req_type_code_in VARCHAR2) is
select /*+ leading(x,A) no_merge(x) use_nl_with_index(a ENI_DENORM_HIERARCHIES_N2) */ A.PARENT_ID --bug 8924817
from (select /*+ ordered use_nl(req sou fnarea c d b) */ distinct b.category_id,
b.category_set_id
   from     QP_PTE_REQUEST_TYPES_B REQ,
       QP_PTE_SOURCE_SYSTEMS SOU,
       QP_SOURCESYSTEM_FNAREA_MAP FNAREA,
       MTL_DEFAULT_CATEGORY_SETS C,
          mtl_category_sets_b d,
       mtl_item_categories b
   WHERE REQ.REQUEST_TYPE_CODE = req_type_code_in AND
       REQ.ENABLED_FLAG = 'Y' AND
       REQ.PTE_CODE = SOU.PTE_CODE AND
       SOU.ENABLED_FLAG = 'Y' AND
       SOU.PTE_SOURCE_SYSTEM_ID = FNAREA.PTE_SOURCE_SYSTEM_ID AND
       FNAREA.ENABLED_FLAG = 'Y' AND
       FNAREA.FUNCTIONAL_AREA_ID = C.FUNCTIONAL_AREA_ID and
          d.category_set_id = c.category_set_id and
          d.hierarchy_enabled = 'Y' and
       b.inventory_item_id = p_inventory_item_id and
       b.organization_id = org_id_in and
       b.category_set_id = d.category_set_id) x,
   ENI_DENORM_HIERARCHIES A
WHERE A.OBJECT_TYPE = 'CATEGORY_SET' AND
A.OBJECT_ID = x.CATEGORY_SET_ID AND
a.child_id = x.category_id ;



BEGIN

    l_appl_id := FND_GLOBAL.RESP_APPL_ID;

    IF QP_ATTR_MAPPING_PUB.G_REQ_TYPE_CODE = 'ONT' THEN
       --passing null org_id to OE_Sys_Parameters for moac so that it will return MASTER_ORGANIZATION_ID
       --for the org_context set -- build_contexts API or calling app would have set 'single' org context
       --added for moac to call oe_sys_params only when org_id is not null
       l_ou_org_id := QP_UTIL.get_org_id;
       IF l_ou_org_id IS NOT NULL THEN
         l_org_id := OE_Sys_Parameters.Value('MASTER_ORGANIZATION_ID', l_ou_org_id);
       ELSE -- get master org from QP profile value
         l_org_id := FND_PROFILE.Value('QP_ORGANIZATION_ID');
       END IF;
    ELSE
       l_org_id := FND_PROFILE.Value('QP_ORGANIZATION_ID');
    END IF;

-- commented out for product hierarchy
/*
    begin
      --
      select category_set_id
      into l_category_set_id_11
      from mtl_default_category_sets
      where functional_area_id = 11 and
            rownum < 2;
      --
      --if l_category_set_id_7 = l_category_set_id_11 then
        select hierarchy_enabled
        into l_hierarchy_enabled
        from mtl_category_sets_b
        where category_set_id = l_category_set_id_11 and
              hierarchy_enabled = 'Y';
        --
        OPEN l_exploded_category_cursor(l_org_id,l_appl_id,
                                        l_category_set_id_11);
        LOOP
      	  FETCH l_exploded_category_cursor INTO l_category_id;
	  EXIT WHEN l_exploded_category_cursor%NOTFOUND;

	  x_category_ids(v_count) := l_category_id;
          v_count := v_count + 1;
        END LOOP;
        CLOSE l_exploded_category_cursor;
      --else
        OPEN l_category_cursor(l_org_id,l_appl_id);
        LOOP
	  FETCH l_category_cursor INTO l_category_id;
	  EXIT WHEN l_category_cursor%NOTFOUND;

	  x_category_ids(v_count) := l_category_id;
          v_count := v_count + 1;
        END LOOP;
        CLOSE l_category_cursor;
      --end if;
    exception
      when others then
        OPEN l_category_cursor(l_org_id,l_appl_id);
        LOOP
	  FETCH l_category_cursor INTO l_category_id;
	  EXIT WHEN l_category_cursor%NOTFOUND;

	  x_category_ids(v_count) := l_category_id;
          v_count := v_count + 1;
        END LOOP;
        CLOSE l_category_cursor;
    end;
*/
-- new changes for product heirarchy starts here
	If qp_util.get_qp_status <>'I' THEN -- Basic pricing
	  OPEN l_category_cursor(l_org_id,QP_ATTR_MAPPING_PUB.G_REQ_TYPE_CODE);
        LOOP
          FETCH l_category_cursor INTO l_category_id;
          EXIT WHEN l_category_cursor%NOTFOUND;

          x_category_ids(v_count) := l_category_id;
          v_count := v_count + 1;
        END LOOP;
        CLOSE l_category_cursor;

	ELSE -- Advanced pricing has product heirarchy feature
        OPEN l_exploded_category_cursor(l_org_id, QP_ATTR_MAPPING_PUB.G_REQ_TYPE_CODE);
        LOOP

	--bug 8805312
	-- Commented code to do bulk collect instead of individual fetches.
          /*FETCH l_exploded_category_cursor INTO l_category_id;
          EXIT WHEN l_exploded_category_cursor%NOTFOUND;

          x_category_ids(v_count) := l_category_id;
          v_count := v_count + 1;*/

          l_int_category_ids.delete;
	  FETCH l_exploded_category_cursor BULK COLLECT INTO l_int_category_ids
	  LIMIT 1000;

	  EXIT WHEN l_int_category_ids.Count = 0;

          FOR i IN l_int_category_ids.first..l_int_category_ids.last
	  LOOP
	    x_category_ids(v_count) := l_int_category_ids(i);
            v_count := v_count + 1;
	  END LOOP;

         --end

        END LOOP;
        CLOSE l_exploded_category_cursor;
        OPEN l_category_cursor(l_org_id,QP_ATTR_MAPPING_PUB.G_REQ_TYPE_CODE);
        LOOP

	--bug 8805312
	-- Commented code to do bulk collect instead of individual fetches.
         /* FETCH l_category_cursor INTO l_category_id;
          EXIT WHEN l_category_cursor%NOTFOUND;

          x_category_ids(v_count) := l_category_id;
          v_count := v_count + 1;*/

	  l_int_category_ids.delete;

	  FETCH l_category_cursor BULK COLLECT INTO l_int_category_ids
	  LIMIT 1000;

	  EXIT WHEN l_int_category_ids.Count = 0;

          FOR i IN l_int_category_ids.first..l_int_category_ids.last
	  LOOP
	    x_category_ids(v_count) := l_int_category_ids(i);
            v_count := v_count + 1;
	  END LOOP;

          --end

        END LOOP;
        CLOSE l_category_cursor;
    	END IF; -- end advacned pricing
    RETURN x_category_ids;

END Get_Item_Category;

/*
 * Commented out for bug 4753707
 *
FUNCTION Validate_UOM (p_org_id IN NUMBER,
                       p_category_id IN NUMBER,
                       p_product_uom_code IN VARCHAR2)
RETURN VARCHAR2
IS
  l_dummy_2 VARCHAR2(3);
  l_category_set_id NUMBER; -- 11i10 Product Catalog
BEGIN
  -- get category set ID for hierarchical categories (e.g., Product Catalog 11i10)
  select category_set_id
  into   l_category_set_id
  from   mtl_default_category_sets
  where  functional_area_id = 11 and rownum < 2;

/* this SQL produces cartesian joins
   rewriting to use base tables as part of SQL repository fix
  select distinct uom_code
  into   l_dummy_2
  from   mtl_item_uoms_view
  where  (organization_id = p_org_id or p_org_id is null)
  and    uom_code = p_product_uom_code
  and    inventory_item_id in
  ...
*--/
  select MTLUOM2.uom_code
  into   l_dummy_2
  from   MTL_SYSTEM_ITEMS_B MTLITM1,
         MTL_UNITS_OF_MEASURE_VL MTLUOM2,
         MTL_UOM_CONVERSIONS MTLUCV
  where  ((MTLITM1.ALLOWED_UNITS_LOOKUP_CODE IN (1,3)
           AND MTLUCV.INVENTORY_ITEM_ID = MTLITM1.INVENTORY_ITEM_ID
           OR ( MTLUCV.INVENTORY_ITEM_ID = 0
                AND MTLUOM2.BASE_UOM_FLAG = 'Y'
                AND MTLUOM2.UOM_CLASS = MTLUCV.UOM_CLASS
                AND MTLUCV.UOM_CLASS IN
                    ( SELECT MTLPRI1.UOM_CLASS
                      FROM MTL_UNITS_OF_MEASURE MTLPRI1
                      WHERE MTLPRI1.UOM_CODE = MTLITM1.PRIMARY_UOM_CODE) )
           OR (MTLUCV.INVENTORY_ITEM_ID = 0
               AND MTLUCV.UOM_CODE IN
                   (SELECT MTLUCC1.TO_UOM_CODE
                    FROM MTL_UOM_CLASS_CONVERSIONS MTLUCC1
                    WHERE MTLUCC1.INVENTORY_ITEM_ID = MTLITM1.INVENTORY_ITEM_ID
                    AND NVL(MTLUCC1.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE) ) ) )
          OR
          (MTLITM1.ALLOWED_UNITS_LOOKUP_CODE IN (2,3)
           AND MTLUCV.INVENTORY_ITEM_ID = 0
           AND ( MTLUCV.UOM_CLASS IN
                 (SELECT MTLUCC.TO_UOM_CLASS
                  FROM MTL_UOM_CLASS_CONVERSIONS MTLUCC
                  WHERE MTLUCC.INVENTORY_ITEM_ID = MTLITM1.INVENTORY_ITEM_ID
                  AND NVL(MTLUCC.DISABLE_DATE,TRUNC(SYSDATE)+1) > TRUNC(SYSDATE))
                  OR MTLUCV.UOM_CLASS =
                     (SELECT MTLPRI.UOM_CLASS
                      FROM MTL_UNITS_OF_MEASURE MTLPRI
                      WHERE MTLPRI.UOM_CODE = MTLITM1.PRIMARY_UOM_CODE)) ) )
  AND    NVL(MTLUCV.DISABLE_DATE, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
  AND    NVL(MTLUOM2.DISABLE_DATE, TRUNC(SYSDATE)+1) > TRUNC(SYSDATE)
  AND    MTLUOM2.UOM_CODE = MTLUCV.UOM_CODE
  AND    (MTLITM1.organization_id = p_org_id or p_org_id is null)
  AND    MTLUOM2.uom_code = p_product_uom_code
  AND    MTLUCV.inventory_item_id in
         (select inventory_item_id
          from mtl_item_categories
          where category_id = p_category_id
          and (organization_id = p_org_id or p_org_id is null)
          UNION
          -- for Product Catalog 11i10
          select inventory_item_id
          from   eni_denorm_hierarchies eni,
                 mtl_item_categories mtl,
                 mtl_default_category_sets sets
          where  mtl.category_set_id = eni.object_id
          and    mtl.category_set_id = l_category_set_id
          and    eni.object_type = 'CATEGORY_SET'
          and    eni.object_id = sets.category_set_id
          and    mtl.category_id = eni.child_id
          and    sets.functional_area_id = decode(FND_GLOBAL.RESP_APPL_ID, 201,
2, 11)
          and    (mtl.organization_id = p_org_id or p_org_id IS NULL)
          and    eni.parent_id = p_category_id)
  and    rownum=1;

  RETURN 'Y';
EXCEPTION
  WHEN NO_DATA_FOUND THEN
    RETURN 'N';
END Validate_UOM;
 *
 */

END QP_CATEGORY_MAPPING_RULE;

/
