--------------------------------------------------------
--  DDL for Package Body PJM_COMMITMENT_UTILS
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."PJM_COMMITMENT_UTILS" AS
/* $Header: PJMCMTUB.pls 120.1 2006/07/10 23:13:51 yliou noship $ */

FUNCTION REQ_Type
( X_Org_Id   IN NUMBER
, X_Subtype  IN VARCHAR2
) return VARCHAR2 IS

L_Type_Name VARCHAR2(80);

BEGIN

    SELECT T.TYPE_NAME into L_Type_Name
    from PO_DOCUMENT_TYPES_ALL_TL T
    WHERE T.LANGUAGE = userenv('LANG')
      and T.DOCUMENT_TYPE_CODE = 'REQUISITION'
      AND T.DOCUMENT_SUBTYPE  = X_Subtype
      and NVL(T.org_id, -99) = NVL(X_Org_Id, -99);

  RETURN ( L_Type_Name );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END REQ_Type;


FUNCTION BOM_RESOURCE
( X_resource_id IN NUMBER
) return VARCHAR2 IS

L_Resource_Code VARCHAR2(10);

BEGIN

  select resource_code into L_Resource_Code
  from bom_resources
  where resource_id = X_resource_id;

  RETURN ( L_Resource_Code );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END BOM_RESOURCE;


FUNCTION Item_Number
( X_Item_Id         IN NUMBER
, X_Organization_Id IN NUMBER
) return VARCHAR2 IS

L_Item_Number VARCHAR2(40);

BEGIN

  SELECT segment1 into L_Item_Number
  from mtl_system_items_b
  where inventory_item_id = X_Item_Id
  and organization_id = X_Organization_Id;

  RETURN ( L_Item_Number );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Item_Number;


FUNCTION PO_EXP_ORG
( X_org    IN NUMBER
, X_entity IN NUMBER
, X_seq    IN NUMBER
, X_dest   IN VARCHAR2
) return NUMBER IS

L_Exp_Org NUMBER;

BEGIN

  IF (X_dest = 'INVENTORY') THEN
    L_Exp_Org := X_org;
  ELSIF (X_dest = 'SHOP FLOOR') THEN
    select BD.PA_EXPENDITURE_ORG_ID into L_Exp_Org
    from WIP_OPERATIONS   WO
       , BOM_DEPARTMENTS  BD
    where WO.ORGANIZATION_ID = X_org
      AND WO.WIP_ENTITY_ID = X_entity
      AND WO.OPERATION_SEQ_NUM = X_seq
      AND BD.DEPARTMENT_ID = WO.DEPARTMENT_ID;
  END IF;

  RETURN ( L_Exp_Org );

END PO_EXP_ORG;


FUNCTION PO_EXP_TYPE
( X_org     IN NUMBER
, X_project IN NUMBER
, X_item    IN NUMBER
, X_res     IN NUMBER
, X_dest    IN VARCHAR2
) return VARCHAR2 IS

L_Exp_Type VARCHAR2(30);

BEGIN

  IF (X_dest = 'INVENTORY') THEN
    L_Exp_Type := MTL_EXPENDITURE_TYPE(X_org, X_item);
  ELSIF (X_dest = 'SHOP FLOOR') THEN
    L_Exp_Type := OSP_EXPENDITURE_TYPE(X_org, X_project, X_res);
  END IF;

  RETURN ( L_Exp_Type );

END PO_EXP_TYPE;


FUNCTION PO_TASK_ID
( X_org     IN NUMBER
, X_project IN NUMBER
, X_dest    IN VARCHAR2
, X_item    IN NUMBER
, X_subinv  IN VARCHAR2
, X_task    IN NUMBER
, X_entity  IN NUMBER
, X_seq     IN NUMBER
) return NUMBER IS

L_Task_Id NUMBER;
L_op      NUMBER;
L_item    NUMBER;
L_entity  NUMBER;
L_dep     NUMBER;

BEGIN

IF (X_task is not null) THEN L_Task_Id := X_task;
ELSE
  IF (X_dest = 'INVENTORY') THEN
    L_Task_Id := PJM_TASK_AUTO_ASSIGN.INV_TASK_WNPS
                       ( X_org
                       , X_project
                       , X_item
                       , NULL
                       , NULL
                       , X_subinv );
  ELSIF (X_dest = 'SHOP FLOOR') THEN
    select WO.STANDARD_OPERATION_ID
         , WDJ.WIP_ENTITY_ID
         , WDJ.PRIMARY_ITEM_ID
         , WO.DEPARTMENT_ID
    into L_op, L_entity, L_item, L_dep
    from WIP_DISCRETE_JOBS            WDJ
       , WIP_OPERATIONS               WO
       , BOM_DEPARTMENTS              BD
    where    WDJ.ORGANIZATION_ID = X_org
      AND    WDJ.WIP_ENTITY_ID = X_entity
      AND    WO.ORGANIZATION_ID = WDJ.ORGANIZATION_ID
      AND    WO.WIP_ENTITY_ID = WDJ.WIP_ENTITY_ID
      AND    WO.OPERATION_SEQ_NUM = X_seq
      AND    BD.DEPARTMENT_ID = WO.DEPARTMENT_ID;

    L_Task_Id := PJM_TASK_AUTO_ASSIGN.WIP_TASK_WNPS
                               ( X_org
                               , X_project
                               , L_op
                               , L_entity
                               , L_item
                               , L_dep );

  END IF; -- destination type

END IF;
RETURN ( L_Task_Id );

END PO_TASK_ID;


FUNCTION Uom_Conversion_Rate
( X_pollookup IN VARCHAR2
, X_dest      IN VARCHAR2
, X_item      IN NUMBER
, X_org       IN NUMBER
) return NUMBER IS

L_Uom_Conversion_Rate NUMBER;

BEGIN

  IF (X_dest = 'INVENTORY') THEN
    select DECODE( X_pollookup
                   , MSI.PRIMARY_UNIT_OF_MEASURE , 1
                   , INV_CONVERT.INV_UM_CONVERT
                     ( X_item, 5 , 1
                     , NULL , NULL
                     , X_pollookup
                     , MSI.PRIMARY_UNIT_OF_MEASURE ) )
    into L_Uom_Conversion_Rate
    from mtl_system_items_b MSI
    where MSI.ORGANIZATION_ID = X_org
      AND MSI.INVENTORY_ITEM_ID = X_item;

  ELSIF (X_dest = 'SHOP FLOOR') THEN
    L_Uom_Conversion_Rate := 1;
  END IF;

  RETURN ( L_Uom_Conversion_Rate );

END Uom_Conversion_Rate;


FUNCTION GET_UNIT
( X_pollookup IN VARCHAR2
, X_dest      IN VARCHAR2
, X_item      IN NUMBER
, X_org       IN NUMBER
) return VARCHAR2 IS

L_Unit VARCHAR2(25);

BEGIN

  IF (X_dest = 'INVENTORY') THEN

    select primary_unit_of_measure
    into L_Unit
    from mtl_system_items_b MSI
    where MSI.ORGANIZATION_ID = X_org
      AND MSI.INVENTORY_ITEM_ID = X_item;

  ELSIF (X_dest = 'SHOP FLOOR') THEN

    L_Unit := X_pollookup;

  END IF;

  RETURN ( L_Unit );

END GET_UNIT;


FUNCTION GET_UOM_CODE
( X_pollookup IN VARCHAR2
, X_dest      IN VARCHAR2
, X_item      IN NUMBER
, X_org       IN NUMBER
) return VARCHAR2 IS

L_Unit VARCHAR2(3);

BEGIN

  IF (X_dest = 'INVENTORY') THEN

    select primary_uom_code
    into L_Unit
    from mtl_system_items_b MSI
    where MSI.ORGANIZATION_ID = X_org
      AND MSI.INVENTORY_ITEM_ID = X_item;

  ELSIF (X_dest = 'SHOP FLOOR') THEN

    select uom_code into L_Unit
    from MTL_UNITS_OF_MEASURE_VL
    where unit_of_measure = X_pollookup;

  END IF;

  RETURN ( L_Unit );

END GET_UOM_CODE;


FUNCTION GET_UOM_TL
( X_pollookup IN VARCHAR2
, X_dest      IN VARCHAR2
, X_item      IN NUMBER
, X_org       IN NUMBER
) return VARCHAR2 IS

L_Unit VARCHAR2(25);

BEGIN

  IF (X_dest = 'INVENTORY') THEN

    select UOM.UNIT_OF_MEASURE_TL
    into L_Unit
    from mtl_system_items_b MSI,
         mtl_units_of_measure_vl UOM
    where MSI.ORGANIZATION_ID = X_org
      AND MSI.INVENTORY_ITEM_ID = X_item
      AND UOM.UOM_CODE = MSI.PRIMARY_UOM_CODE;

  ELSIF (X_dest = 'SHOP FLOOR') THEN

    select UNIT_OF_MEASURE_TL into L_Unit
    from MTL_UNITS_OF_MEASURE_VL
    where unit_of_measure = X_pollookup;

  END IF;

  RETURN ( L_Unit );

END GET_UOM_TL;


FUNCTION Vendor_Name
( X_Vendor_Id  IN NUMBER
) return VARCHAR2 IS

L_Vendor_Name VARCHAR2(360);

BEGIN

  SELECT vendor_name into L_Vendor_Name
  from po_vendors
  where vendor_id = X_Vendor_id;

  RETURN ( L_Vendor_Name );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END Vendor_Name;


FUNCTION People_Name
( X_Person_Id IN NUMBER
) return VARCHAR2 IS

L_Full_Name VARCHAR2(240);

BEGIN

  SELECT full_name into L_Full_Name
  from PER_ALL_PEOPLE_F
  where person_id = X_Person_Id
  AND   TRUNC(SYSDATE) BETWEEN NVL(EFFECTIVE_START_DATE, SYSDATE - 1)
  AND   NVL(EFFECTIVE_END_DATE, SYSDATE + 1);

  RETURN ( L_Full_Name );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END People_Name;


FUNCTION PO_Type
( X_Org_Id   IN NUMBER
, X_Subtype  IN VARCHAR2
) return VARCHAR2 IS

L_Type_Name VARCHAR2(80);

BEGIN

    SELECT T.TYPE_NAME into L_Type_Name
    from PO_DOCUMENT_TYPES_ALL_TL T
    WHERE T.LANGUAGE = userenv('LANG')
      and T.DOCUMENT_TYPE_CODE IN ('PO', 'PA')
      AND T.DOCUMENT_SUBTYPE  = X_Subtype
      and NVL(T.org_id, -99) = NVL(X_Org_Id, -99);

  RETURN ( L_Type_Name );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END PO_Type;


FUNCTION PO_PROJECT_ID
( X_Org_ID         IN    NUMBER
, X_Project_ID     IN    NUMBER
) RETURN NUMBER IS

L_PO_Project NUMBER;

BEGIN

  if (X_Project_ID is not null) then
    L_PO_Project := X_Project_ID;
  else
    select common_project_id into L_PO_Project
    from pjm_org_parameters
    where organization_id = X_Org_ID;
  end if;

  RETURN ( L_PO_Project );

EXCEPTION
WHEN OTHERS THEN
  RETURN ( NULL );

END PO_PROJECT_ID;


FUNCTION MTL_EXPENDITURE_TYPE
( X_Org_ID         IN    NUMBER
, X_Item_ID        IN    NUMBER
) RETURN VARCHAR2 IS

L_Exp_Type  VARCHAR2(30);

CURSOR c_org IS
  SELECT br.expenditure_type
  FROM   bom_resources          br
  ,      cst_item_cost_details  cicd
  ,      mtl_parameters         mp
  WHERE  mp.organization_id = X_Org_ID
  AND    cicd.organization_id (+) = mp.organization_id
  AND    cicd.inventory_item_id (+) = X_Item_ID
  AND    cicd.cost_type_id (+) = mp.primary_cost_method
  AND    cicd.cost_element_id (+) = 1
  AND    br.resource_id = nvl( cicd.resource_id , mp.default_material_cost_id )
  AND    br.organization_id = mp.organization_id
  ORDER BY br.resource_id;

BEGIN
  OPEN c_org;
  FETCH c_org INTO L_Exp_Type;
  CLOSE c_org;
  RETURN ( L_Exp_Type );

EXCEPTION
WHEN OTHERS THEN
  IF ( c_org%isopen ) THEN
    CLOSE c_org;
  END IF;
  RETURN ( NULL );

END MTL_EXPENDITURE_TYPE;

FUNCTION RES_EXPENDITURE_TYPE
( X_Resource_ID    IN    NUMBER
) RETURN VARCHAR2 IS

CURSOR c_res IS
  SELECT expenditure_type
  FROM   bom_resources
  WHERE  resource_id = X_Resource_ID;

L_Exp_Type  VARCHAR2(30);

BEGIN

  OPEN c_res;
  FETCH c_res INTO L_Exp_Type;
  CLOSE C_res;
  RETURN ( L_Exp_Type );

EXCEPTION
WHEN OTHERS THEN
  IF ( c_res%isopen ) THEN
    CLOSE c_res;
  END IF;
  RETURN ( NULL );

END RES_EXPENDITURE_TYPE;

FUNCTION OSP_EXPENDITURE_TYPE
( X_Org_ID         IN    NUMBER
, X_Project_ID     IN    NUMBER
, X_Resource_ID    IN    NUMBER
) RETURN VARCHAR2 IS

CURSOR c_org IS
  SELECT dir_item_expenditure_type
  FROM   pjm_project_parameters
  WHERE  organization_id = X_Org_ID
  AND    project_id = X_Project_ID;

CURSOR c_res IS
  SELECT expenditure_type
  FROM   bom_resources
  WHERE  resource_id = X_Resource_ID;

L_Exp_Type  VARCHAR2(30);

BEGIN

  IF ( X_Resource_ID IS NULL ) THEN
    OPEN c_org;
    FETCH c_org INTO L_Exp_Type;
    CLOSE c_org;
  ELSE
    OPEN c_res;
    FETCH c_res INTO L_Exp_Type;
    CLOSE C_res;
  END IF;
  RETURN ( L_Exp_Type );

EXCEPTION
WHEN OTHERS THEN
  IF ( c_org%isopen ) THEN
    CLOSE c_org;
  ELSIF ( c_res%isopen ) THEN
    CLOSE c_res;
  END IF;
  RETURN ( NULL );

END OSP_EXPENDITURE_TYPE;

PROCEDURE CREATE_SYNONYMS IS

CURSOR c IS
  SELECT nvl(max(pp.project_reference_enabled) , 'N')
  ,      decode(max(pp.common_project_id) , NULL , 'N' , 'Y')
  FROM   pjm_org_parameters pp;

CURSOR c2 IS
  SELECT ou.Oracle_Username
  FROM   fnd_product_installations pi
  ,      fnd_oracle_userid ou
  WHERE  ou.Oracle_ID = pi.Oracle_ID
  AND    Application_ID = 0;

pjm_implemented  VARCHAR2(1);
common_project   VARCHAR2(1);
applsys_schema   VARCHAR2(30);
synonym_changed  BOOLEAN := FALSE;

  PROCEDURE DO_CREATE_SYNONYM
  ( X_synonym_name IN  VARCHAR2
  , X_table_name   IN  VARCHAR2
  ) IS

  CURSOR s ( C_name VARCHAR2 ) IS
    SELECT table_name
    FROM   user_synonyms
    WHERE  synonym_name = C_name;

  sqlstmt          VARCHAR2(240);
  curr_table_name  VARCHAR2(30);
  create_flag      VARCHAR2(1);

  BEGIN
    --
    -- Check with existence of synonym first
    --
    OPEN s ( X_synonym_name );
    FETCH s INTO curr_table_name;
    IF ( s%notfound ) THEN
      --
      -- If synonym not found, we need to create it
      --
      CLOSE s;
      --
      -- Drop the view just in case
      --
      AD_DDL.DO_DDL( applsys_schema
                   , 'PJM'
                   , AD_DDL.DROP_VIEW
                   , 'DROP VIEW ' || X_synonym_name
                   , X_synonym_name );

      create_flag := 'Y';
    ELSE
      CLOSE s;
      IF ( curr_table_name <> X_table_name ) THEN
        --
        -- Synonym exists but points to a different object.  We need to drop
        -- the existing synonym first before recreating the new one
        --
        AD_DDL.DO_DDL( applsys_schema
                     , 'PJM'
                     , AD_DDL.DROP_SYNONYM
                     , 'DROP SYNONYM ' || X_synonym_name
                     , X_synonym_name );

        create_flag := 'Y';
      ELSE
        --
        -- Existing synonym is what we want, no need to do anything
        --
        create_flag := 'N';
      END IF;
    END IF;
    IF ( create_flag = 'Y' ) THEN
      sqlstmt := 'CREATE SYNONYM ' || X_synonym_name || ' FOR ' || X_table_name;
      AD_DDL.DO_DDL( applsys_schema
                   , 'PJM'
                   , AD_DDL.CREATE_SYNONYM
                   , sqlstmt
                   , X_synonym_name );
      synonym_changed := TRUE;
    END IF;
  END DO_CREATE_SYNONYM;

BEGIN
  --
  -- Retrieve the current PJM configuration
  --
  OPEN c;
  FETCH c INTO pjm_implemented , common_project;
  CLOSE c;

  --
  -- Getting the APPLSYS schema name
  --
  OPEN c2;
  FETCH c2 INTO applsys_schema;
  CLOSE c2;

  IF ( pjm_implemented = 'N' ) THEN
    --
    -- PJM has not been implemented, use the stub views for commitments
    --
    do_create_synonym( 'PJM_PO_COMMITMENTS_V' , 'PJM_PO_COMMITMENTS_STUB_V' );
    do_create_synonym( 'PJM_REQ_COMMITMENTS_V' , 'PJM_REQ_COMMITMENTS_STUB_V' );
    do_create_synonym( 'CST_PROJMFG_CMT_VIEW' , 'CST_PROJMFG_CMT_STUB_V' );
  ELSIF ( common_project = 'N' ) THEN
    --
    -- PJM has been implemented without common project, use the basic views for commitments
    --
    do_create_synonym( 'PJM_PO_COMMITMENTS_V' , 'PJM_PO_COMMITMENTS_BASIC_V' );
    do_create_synonym( 'PJM_REQ_COMMITMENTS_V' , 'PJM_REQ_COMMITMENTS_BASIC_V' );
    do_create_synonym( 'CST_PROJMFG_CMT_VIEW' , 'CST_PROJMFG_CMT_BASIC_V' );
  ELSE
    --
    -- PJM has been implemented with common project, use the advance views for commitments
    --
    do_create_synonym( 'PJM_PO_COMMITMENTS_V' , 'PJM_PO_COMMITMENTS_CMPRJ_V' );
    do_create_synonym( 'PJM_REQ_COMMITMENTS_V' , 'PJM_REQ_COMMITMENTS_CMPRJ_V' );
    do_create_synonym( 'CST_PROJMFG_CMT_VIEW' , 'CST_PROJMFG_CMT_BASIC_V' );
  END IF;

  IF ( synonym_changed ) THEN
    BEGIN
      --
      -- Recompile the PA commitment view just as a housekeeping step
      -- Do not worry about the outcome
      --
      AD_DDL.DO_DDL( applsys_schema
                   , 'PA'
                   , AD_DDL.ALTER_VIEW
                   , 'ALTER VIEW PA_COMMITMENT_TXNS_V COMPILE'
                   , 'PA_COMMITMENT_TXNS_V' );
    EXCEPTION
      WHEN OTHERS THEN
        NULL;
    END;
  END IF;

END CREATE_SYNONYMS;

END PJM_COMMITMENT_UTILS;

/
