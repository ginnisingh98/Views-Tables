--------------------------------------------------------
--  DDL for Package Body WMS_ASSIGNMENT_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."WMS_ASSIGNMENT_PVT" AS
/* $Header: WMSVPPAB.pls 120.2 2005/08/29 23:04:01 abshukla noship $ */
--
-- File        : WMSVPPAB.pls
-- Content     : WMS_Assignment_PVT package body
-- Description : Private API functions and procedures needed for wms rules
--               engine strategy assignment implementation.
-- Notes       :
-- Modified    : 02/08/99 mzeckzer created
--
-- Package global to store package name
g_pkg_name CONSTANT VARCHAR2(30) := 'WMS_Assignment_PVT';
-- API name    : GetObjectValueName
-- Type        : Private
-- Function    : Returns the current name of the business object instance a
--               wms strategy is assigned to.
--               ( Needed for forms base views of strategy assignment forms )
-- Input Parameters:
--   p_object_type_code:  1 - system defined ; 2 - user defined
--   p_object_id       :  object identifier
--   p_pk1_value       :  primary key value 1
--   p_pk2_value       :  primary key value 2
--   p_pk3_value       :  primary key value 3
--   p_pk4_value       :  primary key value 4
--   p_pk5_value       :  primary key value 5
--
-- Notes       : Since it is not possible to use dynamic SQL within package
--               functions without violating the WNPS pragma, cursors are
--               hard coded instead of getting the actual SQL statement from
--               WMS_OBJECTS_B table ( analogous to LOV for insert in setup
--               form ) to be able to use function together with 'where' and
--               'order by' clauses in regular SQL.
-- Important:
--               EACH AND EVERY BUSINESS OBJECT IN WMS_OBJECTS_B ENABLED
--               TO TIE STRATEGIES TO IT MUST BE REPRESENTED WITHIN THIS
--               FUNCTION APROPRIATELY IN ORDER TO BE ABLE TO RE-QUERY SET UP
--               STRATEGY ASSIGNMENTS !
-- More:         The parama is no longer needed for Oracle 8i
FUNCTION GetObjectValueName
  ( p_object_type_code   IN NUMBER   DEFAULT g_miss_num
   ,p_object_id          IN NUMBER   DEFAULT g_miss_num
   ,p_pk1_value          IN VARCHAR2 DEFAULT g_miss_char
   ,p_pk2_value          IN VARCHAR2 DEFAULT NULL
   ,p_pk3_value          IN VARCHAR2 DEFAULT NULL
   ,p_pk4_value          IN VARCHAR2 DEFAULT NULL
   ,p_pk5_value          IN VARCHAR2 DEFAULT NULL
  ) RETURN VARCHAR2
  IS
     l_value_name        VARCHAR2(2000);
     --
     CURSOR obj3 IS                                 -- org / opposing org
	SELECT mp.organization_code
	  FROM mtl_parameters      mp
	  WHERE mp.organization_id =
	        fnd_number.canonical_to_number(p_pk1_value)
	  ;
     --
     CURSOR obj4 IS                                 -- item
	SELECT msik.concatenated_segments
	  FROM mtl_system_items_kfv   msik
	  WHERE msik.organization_id = fnd_number.canonical_to_number(p_pk1_value)
	  AND msik.inventory_item_id = fnd_number.canonical_to_number(p_pk2_value)
	  ;
     --
     CURSOR obj7 IS                                 -- sub
	SELECT msi.secondary_inventory_name
	  FROM mtl_secondary_inventories    msi
	  WHERE msi.organization_id  = fnd_number.canonical_to_number(p_pk1_value)
	  AND msi.secondary_inventory_name = p_pk2_value
	  ;
     --
     CURSOR obj9 IS                                 -- item-sub
	SELECT msik.concatenated_segments||' / '||msi.SECONDARY_INVENTORY_NAME
	  FROM mtl_system_items_kfv         msik
              ,mtl_secondary_inventories    msi
	  WHERE msi.organization_id   = msik.organization_id
	  AND msi.secondary_inventory_name = p_pk3_value
	  AND msik.organization_id    = fnd_number.canonical_to_number(p_pk1_value)
	  AND msik.inventory_item_id  = fnd_number.canonical_to_number(p_pk2_value)
	  ;
     --
     CURSOR obj11 IS                                -- txn source type
	SELECT mtst.transaction_source_type_name
	  FROM mtl_txn_source_types            mtst
	  WHERE mtst.transaction_source_type_id = fnd_number.canonical_to_number(p_pk1_value)
	  ;
     --
     CURSOR obj12 IS                                -- txn type
	SELECT mtt.transaction_type_name
	  FROM mtl_transaction_types   mtt
	  WHERE mtt.transaction_type_id = fnd_number.canonical_to_number(p_pk1_value)
	  ;
     --
     CURSOR obj13 IS                                -- source project
	SELECT ppa.segment1
	  FROM pa_projects_all ppa
	  WHERE ppa.project_id  = fnd_number.canonical_to_number(p_pk1_value)
	  ;
     --
     CURSOR obj14 IS                                -- source task
	SELECT ppa.segment1||' / '||pt.task_number
	  FROM pa_projects_all ppa
               ,pa_tasks       pt
	  where pt.task_id     = fnd_number.canonical_to_number(p_pk1_value)
	  and ppa.project_id   = pt.project_id
	  ;
     --
     CURSOR obj15 IS                                -- txn reason
	SELECT  mtr.reason_name
	  FROM  mtl_transaction_reasons  mtr
	  WHERE mtr.reason_id = fnd_number.canonical_to_number(p_pk1_value)
	  ;
     --
     CURSOR obj16 IS                                -- user
	SELECT fu.user_name
	  FROM fnd_user   fu
	  WHERE fu.user_id = fnd_number.canonical_to_number(p_pk1_value)
	  ;
     --
     CURSOR obj17 IS                                -- txn action
	SELECT ml.meaning
	  FROM mfg_lookups    ml
	  WHERE ml.lookup_type = 'MTL_TRANSACTION_ACTION'
	  AND ml.lookup_code = fnd_number.canonical_to_number(p_pk1_value)
	  ;
     --
     CURSOR obj19 IS                                -- opposing sub
	SELECT mp.organization_code||' / '||msi.secondary_inventory_name
	  FROM mtl_parameters     mp
              ,mtl_secondary_inventories   msi
	  WHERE msi.organization_id        = fnd_number.canonical_to_number(p_pk1_value)
	  AND msi.secondary_inventory_name = p_pk2_value
	  AND mp.organization_id           = msi.organization_id
	  ;
     --
     CURSOR obj21 IS                                -- uom
       SELECT muom.unit_of_measure_tl
	 FROM mtl_units_of_measure muom
	 WHERE muom.uom_code   = p_pk1_value
	 ;
     --
     CURSOR obj22 IS                                -- uom class
	SELECT muc.uom_class_tl
	  FROM mtl_uom_classes muc
	  WHERE muc.uom_class   = p_pk1_value
	  ;
     --
     CURSOR obj23 IS                                -- freight carrier
	SELECT ofv.freight_code_tl
	  FROM org_freight   ofv
	  WHERE ofv.organization_id = fnd_number.canonical_to_number(p_pk1_value)
	  AND ofv.freight_code    = p_pk2_value
	  ;
     --
     CURSOR obj52 IS                                -- cat set / cat
	SELECT mcs.category_set_name ||' / '||mck.concatenated_segments
	  FROM mtl_categories_kfv   mck
              ,mtl_category_sets_vl mcs
	 WHERE mcs.category_set_id = fnd_number.canonical_to_number(p_pk2_value)
	   AND mck.category_id     = fnd_number.canonical_to_number(p_pk3_value)
	  ;
     --
     CURSOR obj55 IS                                -- ABC group / class
	SELECT maag.assignment_group_name||' / '||mac.abc_class_name
	  FROM mtl_abc_classes           mac
	      ,mtl_abc_assignment_groups maag
	  WHERE mac.abc_class_id       = fnd_number.canonical_to_number(p_pk2_value)
	    AND maag.assignment_group_id = fnd_number.canonical_to_number(p_pk1_value)
	  ;
     --Bug4579790
     CURSOR obj30 IS		---Customer
	SELECT party.party_name --rc.customer_name
	  FROM hz_parties party
	      ,hz_cust_accounts cust_acct --ra_customers rc
	  WHERE party.party_id = fnd_number.canonical_to_number(p_pk1_value)
          AND   cust_acct.party_id = party.party_id;
     --
     CURSOR obj56 IS		---Item Type
	SELECT ml.meaning
	  FROM fnd_common_lookups ml
	  WHERE ml.lookup_type = 'ITEM_TYPE'
	  AND ml.lookup_code =  rtrim(ltrim(p_pk1_value));

     --
     CURSOR obj1005 IS		---Order Type
	SELECT ottv.name
	  FROM oe_transaction_types_vl ottv
	  WHERE ottv.transaction_type_id = fnd_number.canonical_to_number(p_pk1_value);

    CURSOR obj100 IS
       SELECT VENDOR_NAME
       FROM PO_VENDORS
       WHERE vendor_id = fnd_number.canonical_to_number(p_pk1_value);


BEGIN
    -- validate input parameters
    IF p_object_type_code IS NULL
      OR p_object_type_code = g_miss_num
      OR p_object_id        IS NULL
      OR p_object_id        = g_miss_num
      OR p_pk1_value        IS NULL
      OR p_pk1_value        = g_miss_char
    THEN
      RETURN 'Insufficient parameters passed to '||
             'WMS_Assignment_PVT.GetObjectValueName' ;
    END IF;
    --
    -- function works for system-defined business objects only
    IF p_object_type_code <> 1 THEN
      RETURN NULL ;
    END IF;
    --
    IF p_object_id =  0 THEN
      l_value_name := NULL;
      --
     ELSIF p_object_id in (3,18) THEN
       OPEN obj3;
       FETCH obj3 INTO l_value_name;
       IF obj3%notfound THEN
	  l_value_name := NULL;
       END IF;
       CLOSE obj3;
     ELSIF p_object_id =  4 THEN
       OPEN obj4;
       FETCH obj4 INTO l_value_name;
       IF obj4%notfound THEN
	  l_value_name := NULL ;
       END IF;
       CLOSE obj4;
     ELSIF p_object_id =  7 THEN
      OPEN obj7;
      FETCH obj7 INTO l_value_name;
      IF obj7%notfound THEN
        l_value_name := NULL ;
      END IF;
      CLOSE obj7;
     ELSIF p_object_id =  9 THEN
      OPEN obj9;
      FETCH obj9 INTO l_value_name;
      IF obj9%notfound THEN
        l_value_name := NULL ;
      END IF;
      CLOSE obj9;
     ELSIF p_object_id = 11 THEN
      OPEN obj11;
      FETCH obj11 INTO l_value_name;
      IF obj11%notfound THEN
        l_value_name := NULL ;
      END IF;
      CLOSE obj11;
     ELSIF p_object_id = 12 THEN
      OPEN obj12;
      FETCH obj12 INTO l_value_name;
      IF obj12%notfound THEN
        l_value_name := NULL ;
      END IF;
      CLOSE obj12;
     ELSIF p_object_id = 13 THEN
       OPEN obj13;
       FETCH obj13 INTO l_value_name;
       IF obj13%notfound THEN
	  l_value_name := NULL ;
       END IF;
       CLOSE obj13;
     ELSIF p_object_id = 14 THEN
       OPEN obj14;
       FETCH obj14 INTO l_value_name;
       IF obj14%notfound THEN
        l_value_name := NULL;
       END IF;
       CLOSE obj14;
    ELSIF p_object_id = 15 THEN
       OPEN obj15;
       FETCH obj15 INTO l_value_name;
       IF obj15%notfound THEN
	  l_value_name := NULL;
       END IF;
       CLOSE obj15;
    ELSIF p_object_id = 16 THEN
       OPEN obj16;
      FETCH obj16 INTO l_value_name;
      IF obj16%notfound THEN
        l_value_name := NULL;
      END IF;
      CLOSE obj16;
     ELSIF p_object_id = 17 THEN
       OPEN obj17;
       FETCH obj17 INTO l_value_name;
       IF obj17%notfound THEN
	  l_value_name := NULL;
       END IF;
       CLOSE obj17;
     ELSIF p_object_id = 19 THEN
      OPEN obj19;
      FETCH obj19 INTO l_value_name;
      IF obj19%notfound THEN
        l_value_name := NULL;
      END IF;
      CLOSE obj19;
     ELSIF p_object_id = 21 THEN
       OPEN obj21;
       FETCH obj21 INTO l_value_name;
       IF obj21%notfound THEN
	  l_value_name := NULL;
       END IF;
       CLOSE obj21;
     ELSIF p_object_id = 22 THEN
       OPEN obj22;
       FETCH obj22 INTO l_value_name;
       IF obj22%notfound THEN
	  l_value_name := NULL;
       END IF;
       CLOSE obj22;
     ELSIF p_object_id = 23 THEN
       OPEN obj23;
       FETCH obj23 INTO l_value_name;
       IF obj23%notfound THEN
	  l_value_name := NULL;
       END IF;
      CLOSE obj23;
     ELSIF p_object_id = 52 THEN
       OPEN obj52;
       FETCH obj52 INTO l_value_name;
       IF obj52%notfound THEN
	  l_value_name := NULL;
       END IF;
       CLOSE obj52;
     ELSIF p_object_id = 55 THEN
       OPEN obj55;
       FETCH obj55 INTO l_value_name;
       IF obj55%notfound THEN
	  l_value_name := NULL;
       END IF;
       CLOSE obj55;
     ELSIF p_object_id = 30 THEN
	OPEN obj30;
	FETCH obj30 INTO l_value_name;
	IF obj30%notfound THEN
	  l_value_name := NULL;
        END IF;
	CLOSE obj30;
     ELSIF p_object_id = 56 THEN
	OPEN obj56;
	FETCH obj56 INTO l_value_name;
	IF obj56%notfound THEN
	  l_value_name := NULL;
        END IF;
	CLOSE obj56;
     ELSIF p_object_id = 1005 THEN
	OPEN obj1005;
	FETCH obj1005 INTO l_value_name;
	IF obj1005%notfound THEN
	  l_value_name := NULL;
        END IF;
	CLOSE obj1005;

     ELSIF p_object_id = 100 THEN
	OPEN obj100;
	FETCH obj100 INTO l_value_name;
	IF obj100%notfound THEN
	  l_value_name := NULL;
        END IF;
	CLOSE obj100;

    ELSE
      l_value_name := 'Missing code section for this object in '||
                      'WMS_Assignment_PVT.GetObjectValueName';
    END IF;
    RETURN l_value_name ;
EXCEPTION
   WHEN OTHERS THEN
    IF obj3%isopen THEN
      CLOSE obj3;
    END IF;
    IF obj4%isopen THEN
      CLOSE obj4;
    END IF;
    IF obj7%isopen THEN
      CLOSE obj7;
    END IF;
    IF obj9%isopen THEN
      CLOSE obj9;
    END IF;
    IF obj11%isopen THEN
      CLOSE obj11;
    END IF;
    IF obj12%isopen THEN
      CLOSE obj12;
    END IF;
    IF obj13%isopen THEN
      CLOSE obj13;
    END IF;
    IF obj14%isopen THEN
      CLOSE obj14;
    END IF;
    IF obj15%isopen THEN
      CLOSE obj15;
    END IF;
    IF obj16%isopen THEN
      CLOSE obj16;
    END IF;
    IF obj17%isopen THEN
      CLOSE obj17;
    END IF;
    IF obj19%isopen THEN
      CLOSE obj19;
    END IF;
    IF obj21%isopen THEN
      CLOSE obj21;
    END IF;
    IF obj22%isopen THEN
      CLOSE obj22;
    END IF;
    IF obj23%isopen THEN
      CLOSE obj23;
    END IF;
    IF obj52%isopen THEN
      CLOSE obj52;
    END IF;
    IF obj55%isopen THEN
      CLOSE obj55;
    END IF;
    IF obj1005%isopen THEN
      CLOSE obj1005;
    END IF;
    IF obj100%isopen THEN
      CLOSE obj100;
    END IF;
    RETURN 'Error in WMS_Assignment_PVT' ;
END GetObjectValueName;
END WMS_Assignment_PVT;

/
