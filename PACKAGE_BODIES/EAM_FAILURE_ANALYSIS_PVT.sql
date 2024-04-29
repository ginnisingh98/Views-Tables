--------------------------------------------------------
--  DDL for Package Body EAM_FAILURE_ANALYSIS_PVT
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."EAM_FAILURE_ANALYSIS_PVT" AS
/* $Header: EAMVFALB.pls 120.6.12010000.3 2009/06/10 08:31:55 jgootyag ship $ */

g_module_name VARCHAR2(30);

Procedure GET_HISTORY_RECORDS_ADV
( P_WHERE_CLAUSE                IN  VARCHAR2,
  P_FROM_DATE_CLAUSE            IN  VARCHAR2,
  P_SELECTED_METER              IN  NUMBER,
  P_CURRENT_ORG_ID              IN  NUMBER,
  X_GROUP_ID                    OUT NOCOPY  NUMBER,
  x_return_status               OUT NOCOPY  VARCHAR2,
  x_msg_count                   OUT NOCOPY  NUMBER,
  x_msg_data                    OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class         OUT NOCOPY  VARCHAR2,
  x_unmatched_currency          OUT NOCOPY  VARCHAR2) IS

  sql_stmt           		VARCHAR2(4000);
  l_lookup_meaning   		VARCHAR2(30);
  c_ref_failures     		SYS_REFCURSOR;
  L_asset_failure_tbl   	EAM_FAILURE_ANALYSIS_PVT.eam_asset_failure_tbl_type;
  l_group_id        		NUMBER;
  l_ref_failures    		SYS_REFCURSOR;
  l_unmatched_uom_class   	VARCHAR2(1) := 'N';
  l_unmatched_currency    	VARCHAR2(1) := 'N';

BEGIN
  g_module_name :=  'GET_HISTORY_RECORDS_ADV';

  /*This is to rollback all transactions done w.r.t. EAM_FAILURE_HISTORY_TEMP in the current session */
  ROLLBACK;

  GET_FAILURE_METER_RECS_CURSOR(p_where_clause      => p_where_clause,
                                p_selected_meter    => p_selected_meter,
                                p_view_by           => 1,
                                p_from_date_clause  => p_from_date_clause,
                                x_ref_failures      => l_ref_failures);

   SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_GROUP_ID  FROM DUAL;

   LOOP
       FETCH l_REF_FAILURES BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;

          IF ( l_asset_failure_tbl.Count > 0 ) THEN

          --Currency Validations and UOM Validations are not needed in Failure History Page.
          /*      VALIDATE_RECORDS(p_asset_failure_tbl => l_asset_failure_tbl,
		                p_validate_meters       => 'N',
		                p_validate_currency     => 'Y',
		                p_current_org_id        => p_current_org_id,
                    		x_unmatched_uom_class   => l_unmatched_uom_class,
                    		x_unmatched_currency    => l_unmatched_currency);   */

                INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		                p_asset_failure_tbl  => l_asset_failure_tbl);

                --No need to calculate Repair Costs in Failure History Page.
                --COMPUTE_REPAIR_COSTS(l_group_id);

          END IF;
       EXIT WHEN l_REF_FAILURES%NOTFOUND;
   END LOOP;

   CLOSE l_REF_FAILURES;
   x_group_id := l_group_id;
   x_return_status := 'S';
   x_unmatched_uom_class := l_unmatched_uom_class;
   x_unmatched_currency  := l_unmatched_currency;
EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_msg_data := 'Error in '||g_module_name||':'||SQLERRM;
END GET_HISTORY_RECORDS_ADV;


Procedure GET_HISTORY_RECORDS_FA_ADV
( P_WHERE_CLAUSE                IN VARCHAR2,
  P_WHERE_CLAUSE_1		IN VARCHAR2,
  P_FROM_DATE_CLAUSE            IN VARCHAR2,
  P_SELECTED_METER              IN NUMBER,
  P_INCLUDE_CHILDREN            IN VARCHAR2,
  P_VIEW_BY                     IN VARCHAR2,
  P_COMPUTE_REPAIR_COSTS        IN VARCHAR2,
  P_CURRENT_ORG_ID              IN VARCHAR2,
  X_GROUP_ID                    OUT NOCOPY  NUMBER,
  x_return_status               OUT NOCOPY  VARCHAR2,
  x_msg_count                   OUT NOCOPY  NUMBER,
  x_msg_data                    OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class         OUT NOCOPY  VARCHAR2,
  x_unmatched_currency          OUT NOCOPY  VARCHAR2) IS

  c_ref_failures 		SYS_REFCURSOR;
  l_asset_failure_tbl 		eam_asset_failure_tbl_type;
  l_group_id 			NUMBER;
  l_current_org_id  		NUMBER;
  l_org2  			NUMBER;
  l_same_currency  		NUMBER;
  l_meter_uom1  		VARCHAR2(3);
  l_meter_uom2  		VARCHAR2(3);
  l_uom1_conv_rate  		NUMBER;
  l_uom2_conv_rate  		NUMBER;
  l_validate_meters  		VARCHAR2(1);
  l_validate_currency 		VARCHAR2(1);
  x_ref_failures  		SYS_REFCURSOR;
  l_unmatched_uom_class   	VARCHAR2(1) := 'N';
  l_unmatched_currency    	VARCHAR2(1) := 'N';
  l_return_status		VARCHAR2(1);
  l_msg_data			VARCHAR2(4000);
  l_where_clause_parent		VARCHAR2(8000);

BEGIN

    g_module_name :=  'GET_HISTORY_RECORDS_FA_ADV';
    l_return_status := 'S';
    /*This is to rollback all transactions (uncommited) done w.r.t. EAM_FAILURE_HISTORY_TEMP in the current session */
    ROLLBACK;

    l_current_org_id := p_current_org_id;

    IF (p_where_clause <> 'NULL' AND p_where_clause IS NOT NULL) then
      l_where_clause_parent :=  p_where_clause;
    ELSIF (p_where_clause_1 <> 'NULL' AND p_where_clause_1 IS NOT NULL) then
      l_where_clause_parent :=  p_where_clause_1;
    ELSE
      l_where_clause_parent :=  NULL;
    END IF;

  IF ( p_include_children = 'N' OR p_include_children IS NULL ) THEN

    If p_View_By = 2 /* 'ASSET_GROUP' */ OR p_View_By = 1 /* 'ASSET_NUMBER' */ THEN
    	GET_FAILURE_METER_RECS_CURSOR(l_where_clause_parent, p_selected_meter, p_from_date_clause, p_View_By, x_ref_failures);
    Else
        GET_FAILURE_RECS_CURSOR(l_where_clause_parent, p_from_date_clause, p_View_By, x_ref_failures);
    End if;

    IF p_view_by IN (1,3,4) THEN
          l_validate_meters := 'N';
          l_validate_currency  := 'Y';
    ELSIF  p_view_by = 2 THEN
          l_validate_meters := 'Y';
          l_validate_currency  := 'Y';
    END IF;

    l_validate_currency := p_compute_repair_costs;

     SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;

    LOOP
          FETCH x_ref_failures BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
              IF ( l_asset_failure_tbl.Count > 0 ) THEN

                  VALIDATE_RECORDS( p_asset_failure_tbl     => l_asset_failure_tbl,
                                    p_validate_meters       => l_validate_meters,
                                    p_validate_currency     => l_validate_currency,
                                    p_current_org_id        => l_current_org_id,
                                    x_unmatched_uom_class   => l_unmatched_uom_class,
                                    x_unmatched_currency    => l_unmatched_currency);



	                INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
				               p_asset_failure_tbl  => l_asset_failure_tbl);

                  IF p_compute_repair_costs = 'Y' THEN
	 	                  COMPUTE_REPAIR_COSTS(l_group_id);
	          END if;
              END IF;

          EXIT WHEN x_ref_failures%NOTFOUND;
    END LOOP;

    CLOSE x_ref_failures;
    x_group_id := l_group_id;

    ELSIF p_include_children = 'Y' THEN

        GET_CHILD_RECORDS_FA_ADV
        ( P_WHERE_CLAUSE          =>p_where_clause,
	  P_WHERE_CLAUSE_1	  =>p_where_clause_1,
          P_FROM_DATE_CLAUSE      =>p_from_date_clause,
          P_VIEW_BY	              =>p_view_by,
          P_COMPUTE_REPAIR_COSTS  =>p_compute_repair_costs,
          P_CURRENT_ORG_ID        =>l_current_org_id,
          x_group_id 	            =>l_group_id,
          x_return_status         =>l_return_status,
          x_msg_data              =>l_msg_data,
          x_unmatched_uom_class   =>l_unmatched_uom_class,
          x_unmatched_currency    =>l_unmatched_currency );

  END IF;
    x_return_status :=  l_return_status;
    x_group_id := l_group_id;
    x_unmatched_uom_class := l_unmatched_uom_class;
    x_unmatched_currency  := l_unmatched_currency;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_msg_data := 'Error in '||g_module_name||':'||SQLERRM;
END GET_HISTORY_RECORDS_FA_ADV;


PROCEDURE GET_FAILURE_METER_RECS_CURSOR
( P_WHERE_CLAUSE                IN  VARCHAR2,
  P_SELECTED_METER              IN  NUMBER,
  P_FROM_DATE_CLAUSE            IN  VARCHAR2,
  P_VIEW_BY                     IN  NUMBER,
  X_REF_FAILURES                OUT NOCOPY SYS_REFCURSOR) IS

  sql_stmt 			VARCHAR2(8000);

  l_selected_meter 		NUMBER;
  l_from_date_clause 		VARCHAR2(8000);
  l_where_clause 		VARCHAR2(8000);
  l_partition_by    VARCHAR2(50);
  l_first_tbf_calc_clause VARCHAR2(500);
BEGIN

  g_module_name :=  'GET_FAILURE_METER_RECS_CURSOR';

  IF P_SELECTED_METER IS NULL THEN
    l_selected_meter := 0;
  ELSE
    l_selected_meter := P_SELECTED_METER;
  END IF;

  IF (p_where_clause <> 'NULL' AND p_where_clause IS NOT NULL) THEN
     l_where_clause := p_where_clause;
  ELSE
     l_where_clause := NULL;
  END IF;

  IF (p_from_date_clause <> 'NULL' AND p_from_date_clause IS NOT NULL) THEN
     l_from_date_clause := p_from_date_clause;
  ELSE
     l_from_date_clause := NULL ;
  END IF;

  IF (p_view_by = 1) THEN
     l_partition_by := 'MAINTENANCE_OBJECT_ID';
     l_first_tbf_calc_clause := 'ASSET_CREATION_DATE';
  ELSIF (p_view_by = 2) THEN
     l_partition_by := 'MAINTAINED_GROUP_ID';
     l_first_tbf_calc_clause :=  '(SELECT MIN(CII1.CREATION_DATE)
                                  FROM  CSI_ITEM_INSTANCES CII1
                                  WHERE CII1.INVENTORY_ITEM_ID = MAINTAINED_GROUP_ID
                                  AND   CII1.LAST_VLD_ORGANIZATION_ID = ASSET_ORGANIZATION_ID)';
  END IF;

  sql_stmt := ' SELECT ASSET_TYPE,
  MAINTENANCE_OBJECT_ID,
  MAINTAINED_NUMBER,
  DESCRIPTIVE_TEXT,
  MAINTAINED_GROUP,
  MAINTAINED_GROUP_ID,
  WIP_ENTITY_ID,
  WIP_ENTITY_NAME,
  ORGANIZATION_ID,
  ORGANIZATION_CODE,
  ASSET_CATEGORY_ID,
  ASSET_CATEGORY,
  ASSET_LOCATION_ID,
  ASSET_LOCATION,
  OWNING_DEPARTMENT_ID,
  OWNING_DEPARTMENT,
  FAILURE_CODE,
  FAILURE_DESC,
  CAUSE_CODE,
  CAUSE_DESC,
  RESOLUTION_CODE,
  RESOLUTION_DESC,
  FAILURE_DATE,
  COMMENTS,
  DECODE( LAG(FAILURE_DATE,1,NULL) OVER ( PARTITION BY '||l_partition_by||' ORDER BY FAILURE_DATE),
  NULL, (FAILURE_DATE - '||l_first_tbf_calc_clause||' ),
  (FAILURE_DATE - ( LAG(FAILURE_DATE,1,NULL) OVER ( PARTITION BY '||l_partition_by||' ORDER BY FAILURE_DATE)) )) DAYS_BETWEEN_FAILURES,
 (DATE_COMPLETED - FAILURE_DATE )*24  TIME_TO_REPAIR,
  METER_ID,
  METER_NAME,
  METER_UOM,
  DECODE(METER_TYPE,2,CURRENT_READING,1,
    DECODE( LAG(CURRENT_READING,1,NULL) OVER ( PARTITION BY '||l_partition_by||' ORDER BY DATE_COMPLETED),
       NULL, CURRENT_READING,
    (CURRENT_READING - ( LAG(CURRENT_READING,1,NULL) OVER ( PARTITION BY '||l_partition_by||' ORDER BY DATE_COMPLETED))) ))  READING_BETWEEN_FAILURES,
 '||'''Y'''||' INCLUDE_FOR_READING_AGGR,
 '||'''Y'''||' INCLUDE_FOR_COST_AGGR
FROM (SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID)MAINTAINED_GROUP_ID,
    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
    WDJ.WIP_ENTITY_ID,
    WE.WIP_ENTITY_NAME,
    WDJ.ORGANIZATION_ID,
    OOD.ORGANIZATION_CODE,
    CII.CATEGORY_ID ASSET_CATEGORY_ID,
    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
    EAF.AREA_ID ASSET_LOCATION_ID,
    MEL.LOCATION_CODES ASSET_LOCATION,
    WDJ.OWNING_DEPARTMENT OWNING_DEPARTMENT_ID,
    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
    WDJ.DATE_COMPLETED,
    EAFC.FAILURE_CODE,
    EFC.DESCRIPTION FAILURE_DESC,
    EAFC.CAUSE_CODE,
    ECC.DESCRIPTION CAUSE_DESC,
    EAFC.RESOLUTION_CODE,
    ERC.DESCRIPTION RESOLUTION_DESC,
    EAF.FAILURE_DATE,
    EAFC.COMMENTS,
    METER.METER_ID,
	  METER.METER_NAME METER_NAME,
	  METER.METER_UOM METER_UOM,
	  METER.CURRENT_READING CURRENT_READING,
	  METER.CURRENT_READING_DATE CURRENT_READING_DATE,
    CII.LAST_VLD_ORGANIZATION_ID ASSET_ORGANIZATION_ID,
    METER.METER_TYPE,
    CII.CREATION_DATE ASSET_CREATION_DATE
  FROM WIP_DISCRETE_JOBS WDJ,
    WIP_ENTITIES WE,
    CSI_ITEM_INSTANCES CII,
    MTL_CATEGORIES_KFV MCKFV,
    MTL_SYSTEM_ITEMS_KFV MSIKFV,
    MTL_EAM_LOCATIONS MEL,
    BOM_DEPARTMENTS BD,
    EAM_ASSET_FAILURE_CODES EAFC,
    EAM_ASSET_FAILURES EAF,
    ORG_ORGANIZATION_DEFINITIONS OOD,
    EAM_FAILURE_CODES EFC,
    EAM_CAUSE_CODES ECC,
    EAM_RESOLUTION_CODES ERC,
                    (SELECT
                            ccb.counter_id METER_ID,
                            cctl.name METER_NAME,
                            ccb.uom_code METER_UOM,
                            CCA.SOURCE_OBJECT_ID  MAINTENANCE_OBJECT_ID,
                            CCR.COUNTER_READING CURRENT_READING,
                            CCR.VALUE_TIMESTAMP CURRENT_READING_DATE,
                            CCA.PRIMARY_FAILURE_FLAG,
                            decode(ct.transaction_type_id,92,ct.source_header_ref_id,to_number(null)) WIP_ENTITY_ID,
                            CCB.reading_type METER_TYPE
                    FROM csi_counters_b CCB,csi_counters_tl cctl, csi_counter_readings CCR, csi_counter_associations CCA, csi_transactions CT WHERE ccb.counter_id = cctl.counter_id
                        	and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1)
                        	and cctl.language = userenv('|| '''LANG'''|| ') and ccb.counter_type = '||'''REGULAR'''||'
                        	AND	CCB.COUNTER_ID = CCA.COUNTER_ID
                        	AND CCR.COUNTER_ID(+) = CCB.COUNTER_ID
                        	AND CCR.transaction_id = CT.transaction_id(+)
                        	and SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1) AND nvl(cca.end_date_active, SYSDATE+1)
                            AND CCA.PRIMARY_FAILURE_FLAG = '||'''Y'''||'
                        	AND CCB.EAM_REQUIRED_FLAG = '||'''Y'''||'
                            AND CCR.COUNTER_VALUE_ID IN
                            (
                            SELECT
                                METER_READING_ID
                            FROM
                                (
                                SELECT
                                    Max(EMR1.METER_READING_ID) METER_READING_ID
                                FROM EAM_METER_READINGS_V EMR1
                                GROUP BY EMR1.WIP_ENTITY_ID,
                                    EMR1.METER_ID
                                )
                            ))    METER
  WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
    AND WDJ.ORGANIZATION_ID = OOD.ORGANIZATION_ID
    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	  AND WDJ.STATUS_TYPE IN (4,5,12)
    AND	EAF.SOURCE_TYPE = 1
    AND	EAF.OBJECT_TYPE = 3
    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
    AND EAFC.FAILURE_CODE = EFC.FAILURE_CODE
    AND EAFC.CAUSE_CODE = ECC.CAUSE_CODE
    AND EAFC.RESOLUTION_CODE = ERC.RESOLUTION_CODE
    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
    AND	EAF.SOURCE_ID = METER.WIP_ENTITY_ID (+) )';

  OPEN X_REF_FAILURES FOR 'SELECT ASSET_TYPE,
  MAINTENANCE_OBJECT_ID,
  MAINTAINED_NUMBER,
  DESCRIPTIVE_TEXT,
  MAINTAINED_GROUP,
  MAINTAINED_GROUP_ID,
  WIP_ENTITY_ID,
  WIP_ENTITY_NAME,
  ORGANIZATION_ID,
  ORGANIZATION_CODE,
  ASSET_CATEGORY,
  ASSET_CATEGORY_ID,
  ASSET_LOCATION,
  OWNING_DEPARTMENT,
  FAILURE_CODE,
  CAUSE_CODE,
  RESOLUTION_CODE,
  FAILURE_DATE,
  COMMENTS,
  DAYS_BETWEEN_FAILURES,
  TIME_TO_REPAIR,
  METER_ID,
  METER_NAME,
  METER_UOM,
  READING_BETWEEN_FAILURES,
  INCLUDE_FOR_READING_AGGR,
  INCLUDE_FOR_COST_AGGR FROM ('||sql_stmt||l_where_clause||')'||l_from_date_clause||' ORDER BY MAINTAINED_GROUP_ID';

END  GET_FAILURE_METER_RECS_CURSOR;


Procedure GET_FAILURE_RECS_CURSOR
( P_WHERE_CLAUSE                IN  VARCHAR2,
  P_FROM_DATE_CLAUSE            IN  VARCHAR2,
  p_VIEW_BY                     IN  NUMBER,
  X_REF_FAILURES                OUT NOCOPY SYS_REFCURSOR) IS

    sql_stmt 		VARCHAR2(4000);
    l_from_date_clause 	VARCHAR2(8000);
    l_where_clause 	VARCHAR2(8000);
    l_partition_by    VARCHAR2(50);
BEGIN

  g_module_name :=  'GET_FAILURE_RECS_CURSOR';

  IF (p_where_clause <> 'NULL' AND p_where_clause IS NOT NULL) THEN
     l_where_clause := p_where_clause;
  ELSE
     l_where_clause := NULL;
  END IF;

  IF (p_from_date_clause <> 'NULL' AND p_from_date_clause IS NOT NULL) THEN
     l_from_date_clause := p_from_date_clause;
  ELSE
     l_from_date_clause := NULL;
  END IF;

  IF (p_view_by = 3) THEN
     l_partition_by := 'ASSET_CATEGORY_ID';
  ELSIF (p_view_by = 4) THEN
     l_partition_by := 'FAILURE_CODE';
  END IF;

  sql_stmt := 'SELECT ASSET_TYPE,
  MAINTENANCE_OBJECT_ID,
  MAINTAINED_NUMBER,
  DESCRIPTIVE_TEXT,
  MAINTAINED_GROUP,
  MAINTAINED_GROUP_ID,
  WIP_ENTITY_ID,
  WIP_ENTITY_NAME,
  ORGANIZATION_ID,
  ORGANIZATION_CODE,
  ASSET_CATEGORY_ID,
  ASSET_CATEGORY,
  ASSET_LOCATION_ID,
  ASSET_LOCATION,
  OWNING_DEPARTMENT_ID,
  OWNING_DEPARTMENT,
  FAILURE_CODE,
  FAILURE_DESC,
  CAUSE_CODE,
  CAUSE_DESC,
  RESOLUTION_CODE,
  RESOLUTION_DESC,
  FAILURE_DATE,
  COMMENTS,
  DECODE( LAG(FAILURE_DATE,1,NULL) OVER (PARTITION BY '||l_partition_by||' ORDER BY FAILURE_DATE),
    NULL, (FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                           FROM  CSI_ITEM_INSTANCES CII1
                           WHERE CII1.INVENTORY_ITEM_ID = MAINTAINED_GROUP_ID
                           AND   CII1.CURRENT_ORGANIZATION_ID = ASSET_ORGANIZATION_ID)),
    (FAILURE_DATE - ( LAG(FAILURE_DATE,1,NULL) OVER (PARTITION BY '||l_partition_by||' ORDER BY FAILURE_DATE )) )) DAYS_BETWEEN_FAILURES,
  (DATE_COMPLETED - FAILURE_DATE ) * 24  TIME_TO_REPAIR,
  NULL METER_ID,
  NULL METER_NAME,
  NULL METER_UOM,
  to_number(NULL) READING_BETWEEN_FAILURES,
  '||'''Y'''||' INCLUDE_FOR_READING_AGGR,
  '||'''Y'''||' INCLUDE_FOR_COST_AGGR
FROM (SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
    WDJ.WIP_ENTITY_ID,
    WE.WIP_ENTITY_NAME,
    WDJ.ORGANIZATION_ID,
    OOD.ORGANIZATION_CODE,
    CII.CATEGORY_ID ASSET_CATEGORY_ID,
    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
    EAF.AREA_ID ASSET_LOCATION_ID,
    MEL.LOCATION_CODES ASSET_LOCATION,
    EAF.DEPARTMENT_ID OWNING_DEPARTMENT_ID,
    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
    WDJ.DATE_COMPLETED,
    EAFC.FAILURE_CODE,
    EFC.DESCRIPTION FAILURE_DESC,
    EAFC.CAUSE_CODE,
    ECC.DESCRIPTION CAUSE_DESC,
    EAFC.RESOLUTION_CODE,
    ERC.DESCRIPTION RESOLUTION_DESC,
    EAF.FAILURE_DATE,
    EAFC.COMMENTS,
    CII.LAST_VLD_ORGANIZATION_ID ASSET_ORGANIZATION_ID
  FROM WIP_DISCRETE_JOBS WDJ,
    WIP_ENTITIES WE,
    CSI_ITEM_INSTANCES CII,
    MTL_CATEGORIES_KFV MCKFV,
    MTL_SYSTEM_ITEMS_KFV MSIKFV,
    MTL_EAM_LOCATIONS MEL,
    BOM_DEPARTMENTS BD,
    EAM_ASSET_FAILURE_CODES EAFC,
    EAM_ASSET_FAILURES EAF,
    ORG_ORGANIZATION_DEFINITIONS OOD,
    EAM_FAILURE_CODES EFC,
    EAM_CAUSE_CODES ECC,
    EAM_RESOLUTION_CODES ERC
  WHERE	WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
    AND	WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
    AND WDJ.ORGANIZATION_ID = OOD.ORGANIZATION_ID
    AND	WDJ.STATUS_TYPE IN (4,5,12)
    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
    AND	EAF.SOURCE_TYPE = 1
    AND	EAF.OBJECT_TYPE = 3
    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
    AND EAFC.FAILURE_CODE = EFC.FAILURE_CODE
    AND EAFC.CAUSE_CODE = ECC.CAUSE_CODE
    AND EAFC.RESOLUTION_CODE = ERC.RESOLUTION_CODE
    AND (EFC.EFFECTIVE_END_DATE IS NULL OR EFC.EFFECTIVE_END_DATE >= SYSDATE)
    AND (ECC.EFFECTIVE_END_DATE IS NULL OR ECC.EFFECTIVE_END_DATE >= SYSDATE)
    AND (ERC.EFFECTIVE_END_DATE IS NULL OR ERC.EFFECTIVE_END_DATE >= SYSDATE)
    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
    AND	EAF.MAINT_ORGANIZATION_ID = WDJ.ORGANIZATION_ID
    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
    AND	MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
    AND	BD.DEPARTMENT_ID (+)= EAF.DEPARTMENT_ID )';


  OPEN X_REF_FAILURES FOR 'SELECT ASSET_TYPE,
  MAINTENANCE_OBJECT_ID,
  MAINTAINED_NUMBER,
  DESCRIPTIVE_TEXT,
  MAINTAINED_GROUP,
  MAINTAINED_GROUP_ID,
  WIP_ENTITY_ID,
  WIP_ENTITY_NAME,
  ORGANIZATION_ID,
  ORGANIZATION_CODE,
  ASSET_CATEGORY,
  ASSET_CATEGORY_ID,
  ASSET_LOCATION,
  OWNING_DEPARTMENT,
  FAILURE_CODE,
  CAUSE_CODE,
  RESOLUTION_CODE,
  FAILURE_DATE,
  COMMENTS,
  DAYS_BETWEEN_FAILURES,
  TIME_TO_REPAIR,
  METER_ID,
  METER_NAME,
  METER_UOM,
  READING_BETWEEN_FAILURES,
  INCLUDE_FOR_READING_AGGR,
  INCLUDE_FOR_COST_AGGR FROM ('||SQL_STMT||l_where_clause||' ) '||l_from_date_clause;

END GET_FAILURE_RECS_CURSOR;


Procedure GET_HISTORY_RECORDS_SIMPLE
( P_GEN_OBJECT_ID               IN NUMBER,
  P_FROM_DATE                   IN DATE,
  P_TO_DATE                     IN DATE,
  P_SELECTED_METER              IN NUMBER,
  P_CURRENT_ORG_ID              IN NUMBER,
  X_GROUP_ID                    OUT NOCOPY  NUMBER,
  x_return_status               OUT NOCOPY  VARCHAR2,
  x_msg_count                   OUT NOCOPY  NUMBER,
  x_msg_data                    OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class         OUT NOCOPY  VARCHAR2,
  x_unmatched_currency          OUT NOCOPY  VARCHAR2) IS

  l_asset_failure_tbl    	EAM_FAILURE_ANALYSIS_PVT.eam_asset_failure_tbl_type;
  l_group_id        		NUMBER := 0;
  l_gen_object_id   		NUMBER;
  l_selected_meter		NUMBER;
  l_validate_meters 		VARCHAR2(1);
  l_validate_currency 		VARCHAR2(1);
  l_current_org_id  		NUMBER;
  l_unmatched_uom_class 	VARCHAR2(1) := 'N';
  l_unmatched_currency  	VARCHAR2(1) := 'N';
  l_from_date       		DATE;
  l_to_date         		DATE;

  CURSOR c_history_records_simple IS
            SELECT ASSET_TYPE,
            MAINTENANCE_OBJECT_ID,
            MAINTAINED_NUMBER,
            DESCRIPTIVE_TEXT,
            MAINTAINED_GROUP,
            MAINTAINED_GROUP_ID,
            WIP_ENTITY_ID,
            WIP_ENTITY_NAME,
            ORGANIZATION_ID,
            ORGANIZATION_CODE,
            ASSET_CATEGORY,
            ASSET_CATEGORY_ID,
            ASSET_LOCATION,
            OWNING_DEPARTMENT,
            FAILURE_CODE,
            CAUSE_CODE,
            RESOLUTION_CODE,
            FAILURE_DATE,
            COMMENTS,
            DAYS_BETWEEN_FAILURES,
            TIME_TO_REPAIR,
            METER_ID,
            METER_NAME,
            METER_UOM,
            READING_BETWEEN_FAILURES,
            INCLUDE_FOR_READING_AGGR,
            INCLUDE_FOR_COST_AGGR
        from
            (SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    EAF.AREA_ID ASSET_LOCATION_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    EAF.DEPARTMENT_ID OWNING_DEPARTMENT_ID,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  ),
                      NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                            ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR,
                    METER.PRIMARY_FAILURE_METER,
                    METER.METER_ID
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT
    ccb.counter_id METER_ID,
    cctl.name METER_NAME,
    ccb.uom_code METER_UOM,
    CCA.SOURCE_OBJECT_ID  MAINTENANCE_OBJECT_ID,
    CCR.COUNTER_READING CURRENT_READING,
    CCR.VALUE_TIMESTAMP CURRENT_READING_DATE,
    CCA.PRIMARY_FAILURE_FLAG PRIMARY_FAILURE_METER,
    decode(ct.transaction_type_id,92,ct.source_header_ref_id,to_number(null)) WIP_ENTITY_ID,
    CCB.reading_type METER_TYPE
FROM csi_counters_b CCB,csi_counters_tl cctl, csi_counter_readings CCR, csi_counter_associations CCA, csi_transactions CT
WHERE
	ccb.counter_id = cctl.counter_id
	and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1)
	and cctl.language = userenv('LANG') and ccb.counter_type = 'REGULAR'
	AND	CCB.COUNTER_ID = CCA.COUNTER_ID
	AND CCR.COUNTER_ID(+) = CCB.COUNTER_ID
	AND CCR.transaction_id = CT.transaction_id(+)
	and SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1) AND nvl(cca.end_date_active, SYSDATE+1)
    AND ( (l_selected_meter IS NULL 	AND CCA.PRIMARY_FAILURE_FLAG  = 'Y') OR
                          (l_selected_meter IS NOT NULL 	AND CCB.COUNTER_ID = l_selected_meter))
	AND CCB.EAM_REQUIRED_FLAG = 'Y'
    AND CCR.COUNTER_VALUE_ID IN
    (
    SELECT
        METER_READING_ID
    FROM
        (
        SELECT
            Max(EMR1.METER_READING_ID) METER_READING_ID
        FROM EAM_METER_READINGS_V EMR1
        GROUP BY EMR1.WIP_ENTITY_ID,
            EMR1.METER_ID
        )
    ))    METER
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND EAF.SOURCE_ID = METER.WIP_ENTITY_ID (+)
                    AND EAFC.FAILURE_CODE IS NOT NULL
                    AND EAFC.CAUSE_CODE IS NOT NULL
                    AND EAFC.RESOLUTION_CODE IS NOT NULL
                    AND EAF.FAILURE_DATE IS NOT NULL
                    AND EAF.OBJECT_ID = l_gen_object_id
                    AND (l_to_date IS NULL OR EAF.FAILURE_DATE <= l_to_date))
        WHERE (l_from_date IS NULL OR FAILURE_DATE >= l_from_date);

BEGIN
  g_module_name :=  'GET_HISTORY_RECORDS_SIMPLE';

  /*This is to rollback all transactions (uncommited) done w.r.t. EAM_FAILURE_HISTORY_TEMP in the current session */
  ROLLBACK;

  IF p_gen_object_id = 0 THEN
    l_gen_object_id := NULL;
  ELSE
    l_gen_object_id := p_gen_object_id;
  END IF;

  IF p_selected_meter = 0 THEN
    l_selected_meter := NULL;
  ELSE
    l_selected_meter	:= p_selected_meter;
  END IF;

  IF p_to_date = '' THEN
    l_to_date := NULL;
  ELSE
    l_to_date	:= p_to_date;
  END IF;

  IF p_from_date = '' THEN
    l_from_date := NULL;
  ELSE
    l_from_date	:= p_from_date;
  END IF;


  l_validate_meters := 'N';
  l_validate_currency := 'Y';
  l_current_org_id := p_current_org_id;

  OPEN c_history_records_simple;
  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
  LOOP
      FETCH c_history_records_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;

      IF ( l_asset_failure_tbl.Count > 0 ) THEN

      --Currency Validations and UOM Validations are not needed in Failure History Page.
      /*      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
                            p_validate_meters       => l_validate_meters,
                            p_validate_currency     => l_validate_currency,
                            p_current_org_id        => l_current_org_id,
                            x_unmatched_uom_class   => l_unmatched_uom_class,
                            x_unmatched_currency    => l_unmatched_currency); */



          INSERT_INTO_TEMP_TABLE(l_group_id, l_asset_failure_tbl);

          --No need to calculate Repair Costs in Failure History Page.
          --COMPUTE_REPAIR_COSTS(l_group_id);
      END IF;

      EXIT WHEN c_history_records_simple%NOTFOUND;
  END LOOP;

  CLOSE c_history_records_simple;

  x_group_id := l_group_id;
  x_return_status := 'S';
  x_unmatched_uom_class := l_unmatched_uom_class;
  x_unmatched_currency  := l_unmatched_currency;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_msg_data := 'Error in '||g_module_name||':'||SQLERRM;
END GET_HISTORY_RECORDS_SIMPLE;


Procedure GET_HISTORY_RECORDS_FA_SIMPLE
( P_GEN_OBJECT_ID         IN  NUMBER,
  P_MAINT_GROUP_ID        IN  NUMBER,
  P_CATEGORY_ID           IN  NUMBER,
  P_FAILURE_CODE          IN  VARCHAR2,
  P_FROM_DATE	          IN  DATE,
  P_TO_DATE               IN  DATE,
  P_INCLUDE_CHILDREN	  IN  VARCHAR2,
  P_VIEW_BY	          IN  VARCHAR2,
  P_COMPUTE_REPAIR_COSTS  IN  VARCHAR2,
  P_SELECTED_METER        IN  NUMBER,
  P_CURRENT_ORG_ID        IN  NUMBER,
  X_GROUP_ID 	          OUT	NOCOPY NUMBER,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_count             OUT NOCOPY  NUMBER,
  x_msg_data              OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class   OUT NOCOPY  VARCHAR2,
  x_unmatched_currency    OUT NOCOPY  VARCHAR2) IS

  l_asset_failure_tbl    EAM_FAILURE_ANALYSIS_PVT.eam_asset_failure_tbl_type;
  l_group_id        NUMBER;

 l_gen_object_id    number;
 l_maint_group_id   number;
 l_category_id      number;
 l_selected_meter   number;

 l_unmatched_uom_class VARCHAR2(1) := 'N';
 l_unmatched_currency  VARCHAR2(1) := 'N';
 l_validate_meters     VARCHAR2(1);
 l_validate_currency   VARCHAR2(1);

 l_msg_data VARCHAR2(500);
 l_return_status VARCHAR2(1) := 'S';

  CURSOR c_hist_recs_ac_simple IS
        SELECT ASSET_TYPE,
            MAINTENANCE_OBJECT_ID,
            MAINTAINED_NUMBER,
            DESCRIPTIVE_TEXT,
            MAINTAINED_GROUP,
            MAINTAINED_GROUP_ID,
            WIP_ENTITY_ID,
            WIP_ENTITY_NAME,
            ORGANIZATION_ID,
            ORGANIZATION_CODE,
            ASSET_CATEGORY,
            ASSET_CATEGORY_ID,
            ASSET_LOCATION,
            OWNING_DEPARTMENT,
            FAILURE_CODE,
            CAUSE_CODE,
            RESOLUTION_CODE,
            FAILURE_DATE,
            COMMENTS,
            DAYS_BETWEEN_FAILURES,
            TIME_TO_REPAIR,
            METER_ID,
            METER_NAME,
            METER_UOM,
            READING_BETWEEN_FAILURES,
            INCLUDE_FOR_READING_AGGR,
            INCLUDE_FOR_COST_AGGR
        from
            (SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    EAF.AREA_ID ASSET_LOCATION_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    EAF.DEPARTMENT_ID OWNING_DEPARTMENT_ID,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.INSTANCE_ID, CII.CATEGORY_ID ORDER BY EAF.FAILURE_DATE),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                            ( PARTITION BY CII.INSTANCE_ID, CII.CATEGORY_ID ORDER BY EAF.FAILURE_DATE)) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
	                  NULL METER_NAME,
	                  NULL METER_UOM,
                    NULL READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR,
                    NULL METER_ID
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAFC.FAILURE_CODE IS NOT NULL
                    AND EAFC.CAUSE_CODE IS NOT NULL
                    AND EAFC.RESOLUTION_CODE IS NOT NULL
                    AND EAF.FAILURE_DATE IS NOT NULL
                    AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
                    AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
                    AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                    AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
                    AND (p_to_date IS NULL OR EAF.FAILURE_DATE <= p_to_date))
        WHERE (p_from_date IS NULL OR FAILURE_DATE >= p_from_date) ;

  CURSOR c_hist_recs_fc_simple IS
        SELECT ASSET_TYPE,
            MAINTENANCE_OBJECT_ID,
            MAINTAINED_NUMBER,
            DESCRIPTIVE_TEXT,
            MAINTAINED_GROUP,
            MAINTAINED_GROUP_ID,
            WIP_ENTITY_ID,
            WIP_ENTITY_NAME,
            ORGANIZATION_ID,
            ORGANIZATION_CODE,
            ASSET_CATEGORY,
            ASSET_CATEGORY_ID,
            ASSET_LOCATION,
            OWNING_DEPARTMENT,
            FAILURE_CODE,
            CAUSE_CODE,
            RESOLUTION_CODE,
            FAILURE_DATE,
            COMMENTS,
            DAYS_BETWEEN_FAILURES,
            TIME_TO_REPAIR,
            METER_ID,
            METER_NAME,
            METER_UOM,
            READING_BETWEEN_FAILURES,
            INCLUDE_FOR_READING_AGGR,
            INCLUDE_FOR_COST_AGGR
        from
            (SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    EAF.AREA_ID ASSET_LOCATION_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    EAF.DEPARTMENT_ID OWNING_DEPARTMENT_ID,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.INSTANCE_ID, EAFC.FAILURE_CODE ORDER BY EAF.FAILURE_DATE),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                            ( PARTITION BY CII.INSTANCE_ID, EAFC.FAILURE_CODE ORDER BY EAF.FAILURE_DATE)) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
	                  NULL METER_NAME,
	                  NULL METER_UOM,
                    NULL READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR,
                    NULL METER_ID
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAFC.FAILURE_CODE IS NOT NULL
                    AND EAFC.CAUSE_CODE IS NOT NULL
                    AND EAFC.RESOLUTION_CODE IS NOT NULL
                    AND EAF.FAILURE_DATE IS NOT NULL
                    AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
                    AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
                    AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                    AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
                    AND (p_to_date IS NULL OR EAF.FAILURE_DATE <= p_to_date))
        WHERE (p_from_date IS NULL OR FAILURE_DATE >= p_from_date) ;

  CURSOR c_hist_meter_recs_an_simple IS
        SELECT ASSET_TYPE,
            MAINTENANCE_OBJECT_ID,
            MAINTAINED_NUMBER,
            DESCRIPTIVE_TEXT,
            MAINTAINED_GROUP,
            MAINTAINED_GROUP_ID,
            WIP_ENTITY_ID,
            WIP_ENTITY_NAME,
            ORGANIZATION_ID,
            ORGANIZATION_CODE,
            ASSET_CATEGORY,
            ASSET_CATEGORY_ID,
            ASSET_LOCATION,
            OWNING_DEPARTMENT,
            FAILURE_CODE,
            CAUSE_CODE,
            RESOLUTION_CODE,
            FAILURE_DATE,
            COMMENTS,
            DAYS_BETWEEN_FAILURES,
            TIME_TO_REPAIR,
            METER_ID,
            METER_NAME,
            METER_UOM,
            READING_BETWEEN_FAILURES,
            INCLUDE_FOR_READING_AGGR,
            INCLUDE_FOR_COST_AGGR
        from
            (SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    EAF.AREA_ID ASSET_LOCATION_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    EAF.DEPARTMENT_ID OWNING_DEPARTMENT_ID,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  ),
                      NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                            ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR,
                    METER.METER_ID,
                    METER.PRIMARY_FAILURE_METER
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT
                        ccb.counter_id METER_ID,
                        cctl.name METER_NAME,
                        ccb.uom_code METER_UOM,
                        CCA.SOURCE_OBJECT_ID  MAINTENANCE_OBJECT_ID,
                        CCR.COUNTER_READING CURRENT_READING,
                        CCR.VALUE_TIMESTAMP CURRENT_READING_DATE,
                        CCA.PRIMARY_FAILURE_FLAG PRIMARY_FAILURE_METER,
                        decode(ct.transaction_type_id,92,ct.source_header_ref_id,to_number(null)) WIP_ENTITY_ID,
                        CCB.reading_type METER_TYPE
                    FROM csi_counters_b CCB,csi_counters_tl cctl, csi_counter_readings CCR, csi_counter_associations CCA, csi_transactions CT
                    WHERE
                    	ccb.counter_id = cctl.counter_id
                    	and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1)
                    	and cctl.language = userenv('LANG') and ccb.counter_type = 'REGULAR'
                    	AND	CCB.COUNTER_ID = CCA.COUNTER_ID
                    	AND CCR.COUNTER_ID(+) = CCB.COUNTER_ID
                    	AND CCR.transaction_id = CT.transaction_id(+)
                    	and SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1) AND nvl(cca.end_date_active, SYSDATE+1)
                        AND ( (l_selected_meter IS NULL 	AND CCA.PRIMARY_FAILURE_FLAG  = 'Y') OR
                                              (l_selected_meter IS NOT NULL 	AND CCB.COUNTER_ID = l_selected_meter))
                    	AND CCB.EAM_REQUIRED_FLAG = 'Y'
                        AND CCR.COUNTER_VALUE_ID IN
                        (
                        SELECT
                            METER_READING_ID
                        FROM
                            (
                            SELECT
                                Max(EMR1.METER_READING_ID) METER_READING_ID
                            FROM EAM_METER_READINGS_V EMR1
                            GROUP BY EMR1.WIP_ENTITY_ID,
                                EMR1.METER_ID
                            )
                        ))    METER
                    WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
                    AND EAFC.FAILURE_CODE IS NOT NULL
                    AND EAFC.CAUSE_CODE IS NOT NULL
                    AND EAFC.RESOLUTION_CODE IS NOT NULL
                    AND EAF.FAILURE_DATE IS NOT NULL
                    AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
                    AND (l_maint_group_id IS NULL OR MSIKFV.INVENTORY_ITEM_ID = l_maint_group_id)
                    AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                    AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
                    AND (p_to_date IS NULL OR EAF.FAILURE_DATE <= p_to_date))
        WHERE (p_from_date IS NULL OR FAILURE_DATE >= p_from_date);

  CURSOR c_hist_meter_recs_ag_simple IS
        SELECT ASSET_TYPE,
            MAINTENANCE_OBJECT_ID,
            MAINTAINED_NUMBER,
            DESCRIPTIVE_TEXT,
            MAINTAINED_GROUP,
            MAINTAINED_GROUP_ID,
            WIP_ENTITY_ID,
            WIP_ENTITY_NAME,
            ORGANIZATION_ID,
            ORGANIZATION_CODE,
            ASSET_CATEGORY,
            ASSET_CATEGORY_ID,
            ASSET_LOCATION,
            OWNING_DEPARTMENT,
            FAILURE_CODE,
            CAUSE_CODE,
            RESOLUTION_CODE,
            FAILURE_DATE,
            COMMENTS,
            DAYS_BETWEEN_FAILURES,
            TIME_TO_REPAIR,
            METER_ID,
            METER_NAME,
            METER_UOM,
            READING_BETWEEN_FAILURES,
            INCLUDE_FOR_READING_AGGR,
            INCLUDE_FOR_COST_AGGR
        from
            (SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    EAF.AREA_ID ASSET_LOCATION_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    EAF.DEPARTMENT_ID OWNING_DEPARTMENT_ID,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.INSTANCE_ID, CII.INVENTORY_ITEM_ID ORDER BY EAF.FAILURE_DATE  ),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                            ( PARTITION BY CII.INSTANCE_ID, CII.INVENTORY_ITEM_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY  CII.INVENTORY_ITEM_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY  CII.INVENTORY_ITEM_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR,
                    METER.METER_ID,
                    METER.PRIMARY_FAILURE_METER
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT
    ccb.counter_id METER_ID,
    cctl.name METER_NAME,
    ccb.uom_code METER_UOM,
    CCA.SOURCE_OBJECT_ID  MAINTENANCE_OBJECT_ID,
    CCR.COUNTER_READING CURRENT_READING,
    CCR.VALUE_TIMESTAMP CURRENT_READING_DATE,
    CCA.PRIMARY_FAILURE_FLAG PRIMARY_FAILURE_METER,
    decode(ct.transaction_type_id,92,ct.source_header_ref_id,to_number(null)) WIP_ENTITY_ID,
    CCB.reading_type METER_TYPE
FROM csi_counters_b CCB,csi_counters_tl cctl, csi_counter_readings CCR, csi_counter_associations CCA, csi_transactions CT
WHERE
	ccb.counter_id = cctl.counter_id
	and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1)
	and cctl.language = userenv('LANG') and ccb.counter_type = 'REGULAR'
	AND	CCB.COUNTER_ID = CCA.COUNTER_ID
	AND CCR.COUNTER_ID(+) = CCB.COUNTER_ID
	AND CCR.transaction_id = CT.transaction_id(+)
	and SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1) AND nvl(cca.end_date_active, SYSDATE+1)
    AND ( (l_selected_meter IS NULL 	AND CCA.PRIMARY_FAILURE_FLAG  = 'Y') OR
                          (l_selected_meter IS NOT NULL 	AND CCB.COUNTER_ID = l_selected_meter))
	AND CCB.EAM_REQUIRED_FLAG = 'Y'
    AND CCR.COUNTER_VALUE_ID IN
    (
    SELECT
        METER_READING_ID
    FROM
        (
        SELECT
            Max(EMR1.METER_READING_ID) METER_READING_ID
        FROM EAM_METER_READINGS_V EMR1
        GROUP BY EMR1.WIP_ENTITY_ID,
            EMR1.METER_ID
        )
    ))    METER
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
                    AND EAFC.FAILURE_CODE IS NOT NULL
                    AND EAFC.CAUSE_CODE IS NOT NULL
                    AND EAFC.RESOLUTION_CODE IS NOT NULL
                    AND EAF.FAILURE_DATE IS NOT NULL
                    AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
                    AND (l_maint_group_id IS NULL OR MSIKFV.INVENTORY_ITEM_ID = l_maint_group_id)
                    AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                    AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
                    AND (p_to_date IS NULL OR EAF.FAILURE_DATE <= p_to_date))
        WHERE (p_from_date IS NULL OR FAILURE_DATE >= p_from_date)
        ORDER BY MAINTAINED_GROUP_ID;


BEGIN
          g_module_name := 'GET_HISTORY_RECORDS_FA_SIMPLE';
         /*This is to rollback all transactions (uncommited) done w.r.t. EAM_FAILURE_HISTORY_TEMP in the current session */
         ROLLBACK;
         IF p_gen_object_id = 0 THEN
              l_gen_object_id := NULL;
          ELSE
              l_gen_object_id := p_gen_object_id;
          END IF;

          IF p_maint_group_id = 0 THEN
              l_maint_group_id := NULL;
          ELSE
              l_maint_group_id := p_maint_group_id;
          END IF;

          IF p_category_id = 0 THEN
              l_category_id := NULL;
          ELSE
              l_category_id := p_category_id;
          END IF;

          IF p_selected_meter = 0 THEN
              l_selected_meter := NULL;
          ELSE
              l_selected_meter := p_selected_meter;
          END IF;

       IF (p_include_children = 'N' OR p_include_children IS NULL) THEN
          l_validate_currency  :=  p_compute_repair_costs;
          IF p_view_by IN (1,3,4) THEN
                l_validate_meters := 'N';
               -- l_validate_currency  := 'Y';
          ELSIF  p_view_by = 2 THEN
                l_validate_meters := 'Y';
               -- l_validate_currency  := 'Y';
          END IF;
          l_asset_failure_tbl.DELETE();

          IF p_view_by = 1 /* 'ASSET_NUMBER' */ THEN
              OPEN c_hist_meter_recs_an_simple;
			  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
              LOOP
                  FETCH c_hist_meter_recs_an_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
			                                p_validate_meters     => l_validate_meters,
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);



	              		INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		               		               p_asset_failure_tbl  => l_asset_failure_tbl);

                      		IF p_compute_repair_costs = 'Y' THEN
	 	      	 		    COMPUTE_REPAIR_COSTS(l_group_id);
	              		END if;
                    END IF;

                    EXIT WHEN c_hist_meter_recs_an_simple%NOTFOUND;
              END LOOP;

              CLOSE c_hist_meter_recs_an_simple;

          ELSIF p_view_by = 2 /* 'ASSET_GROUP' */ THEN
              OPEN c_hist_meter_recs_ag_simple;
			  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
              LOOP
                  FETCH c_hist_meter_recs_ag_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
			                                p_validate_meters     => l_validate_meters,
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);



	              		INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		               		               p_asset_failure_tbl  => l_asset_failure_tbl);

                      		IF p_compute_repair_costs = 'Y' THEN
	 	      	 		    COMPUTE_REPAIR_COSTS(l_group_id);
	              		END if;
                    END IF;

                    EXIT WHEN c_hist_meter_recs_ag_simple%NOTFOUND;
              END LOOP;

              CLOSE c_hist_meter_recs_ag_simple;

          ELSIF p_view_by = 3 /* 'ASSET_CATEGORY' */ THEN
              OPEN c_hist_recs_ac_simple;
			  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
              LOOP
                  FETCH c_hist_recs_ac_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
			                                p_validate_meters     => l_validate_meters,
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);


	              		INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		               		               p_asset_failure_tbl  => l_asset_failure_tbl);

                      		IF p_compute_repair_costs = 'Y' THEN
	 	      	 		    COMPUTE_REPAIR_COSTS(l_group_id);
	              		END if;
                    END IF;

                    EXIT WHEN c_hist_recs_ac_simple%NOTFOUND;
              END LOOP;

              CLOSE c_hist_recs_ac_simple;

          ELSIF p_view_by = 4 /* 'FAILURE_CODE' */ THEN
              OPEN c_hist_recs_fc_simple;
			  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;

              LOOP
                  FETCH c_hist_recs_fc_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
			                                p_validate_meters     => l_validate_meters,
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);


	              		INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		               		               p_asset_failure_tbl  => l_asset_failure_tbl);

                      		IF p_compute_repair_costs = 'Y' THEN
	 	      	 		    COMPUTE_REPAIR_COSTS(l_group_id);
	              		END if;
                    END IF;

                    EXIT WHEN c_hist_recs_fc_simple%NOTFOUND;
              END LOOP;

              CLOSE c_hist_recs_fc_simple;
           END IF;

          --Processing so far successful
        x_return_status := 'S';

        ElSIF p_include_children = 'Y' THEN
                GET_CHILD_RECORDS_FA_SIMPLE
                ( P_GEN_OBJECT_ID         =>l_gen_object_id,
                  P_MAINT_GROUP_ID        =>l_maint_group_id,
                  P_CATEGORY_ID           =>l_category_id,
                  P_FAILURE_CODE          =>p_failure_code,
                  P_FROM_DATE	            =>p_from_date,
                  P_TO_DATE               =>p_to_date,
                  P_VIEW_BY	              =>p_view_by,
                  P_COMPUTE_REPAIR_COSTS  =>p_compute_repair_costs,
                  P_CURRENT_ORG_ID        =>p_current_org_id,
                  x_GROUP_ID 	            =>l_group_id,
                  x_return_status         =>l_return_status,
                  x_msg_data              =>l_msg_data,
                  x_unmatched_uom_class   =>l_unmatched_uom_class,
                  x_unmatched_currency    =>l_unmatched_currency );
          END IF;
                x_return_status := l_return_status;

        x_msg_data := l_msg_data;
        x_group_id := l_group_id;

        x_unmatched_uom_class := l_unmatched_uom_class;
        x_unmatched_currency  := l_unmatched_currency;
EXCEPTION
  WHEN OTHERS THEN
         x_return_status := 'E';
         x_msg_data := 'Error in '||g_module_name||':'||SQLERRM;
END GET_HISTORY_RECORDS_FA_SIMPLE;


Procedure INSERT_INTO_TEMP_TABLE
( p_group_id            IN  NUMBER,
  P_ASSET_FAILURE_TBL	  IN  eam_asset_failure_tbl_type) IS
  l_asset_failure_tbl eam_asset_failure_tbl_type;
BEGIN
  g_module_name :=  'INSERT_INTO_TEMP_TABLE';
  l_asset_failure_tbl := p_asset_failure_tbl;

      FOR i in l_asset_failure_tbl.first .. l_asset_failure_tbl.last
      LOOP

        INSERT INTO EAM_FAILURE_HISTORY_TEMP
                        (GROUP_ID,
                        ASSET_TYPE,
                        MAINTENANCE_OBJECT_ID,
                        MAINTAINED_NUMBER,
                        DESCRIPTIVE_TEXT,
                        MAINTAINED_GROUP,
                        MAINTAINED_GROUP_ID ,
                        WIP_ENTITY_ID,
                        WIP_ENTITY_NAME,
			MAINT_ORGANIZATION_ID,
                        ORGANIZATION_CODE,
                        ASSET_CATEGORY,
                        ASSET_CATEGORY_ID,
                        ASSET_LOCATION,
                        OWNING_DEPARTMENT,
                        FAILURE_CODE,
                        CAUSE_CODE,
                        RESOLUTION_CODE,
                        FAILURE_DATE,
                        DAYS_BETWEEN_FAILURES,
                        TIME_TO_REPAIR,
                        COMMENTS,
                        METER_NAME,
                        METER_UOM,
		        READING_BETWEEN_FAILURES,
                        INCLUDE_FOR_READING_AGGR,
                        INCLUDE_FOR_COST_AGGR)
                values
                        (p_group_id,
                        l_asset_failure_tbl(i).ASSET_TYPE,
                        l_asset_failure_tbl(i).MAINTENANCE_OBJECT_ID,
                        l_asset_failure_tbl(i).MAINTAINED_NUMBER,
                        l_asset_failure_tbl(i).DESCRIPTIVE_TEXT,
                        l_asset_failure_tbl(i).MAINTAINED_GROUP,
                        l_asset_failure_tbl(i).MAINTAINED_GROUP_ID,
                        l_asset_failure_tbl(i).WIP_ENTITY_ID,
                        l_asset_failure_tbl(i).WIP_ENTITY_NAME,
			l_asset_failure_tbl(i).ORGANIZATION_ID,
                        l_asset_failure_tbl(i).ORGANIZATION_CODE,
                        l_asset_failure_tbl(i).ASSET_CATEGORY,
                        l_asset_failure_tbl(i).ASSET_CATEGORY_ID,
                        l_asset_failure_tbl(i).ASSET_LOCATION,
                        l_asset_failure_tbl(i).OWNING_DEPARTMENT,
                        l_asset_failure_tbl(i).FAILURE_CODE,
                        l_asset_failure_tbl(i).CAUSE_CODE,
                        l_asset_failure_tbl(i).RESOLUTION_CODE,
                        l_asset_failure_tbl(i).FAILURE_DATE,
                        l_asset_failure_tbl(i).DAYS_BETWEEN_FAILURES,
                        l_asset_failure_tbl(i).TIME_TO_REPAIR,
                        l_asset_failure_tbl(i).COMMENTS,
                        l_asset_failure_tbl(i).METER_NAME,
                        l_asset_failure_tbl(i).METER_UOM,
                        l_asset_failure_tbl(i).READING_BETWEEN_FAILURES,
                        l_asset_failure_tbl(i).INCLUDE_FOR_READING_AGGR,
                        l_asset_failure_tbl(i).INCLUDE_FOR_COST_AGGR);

        END LOOP;
END INSERT_INTO_TEMP_TABLE;

Procedure COMPUTE_REPAIR_COSTS
( P_GROUP_ID	     IN	  NUMBER) IS

    TYPE repair_cost_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;
    TYPE wip_entity_id_tbl_type IS TABLE OF NUMBER INDEX BY BINARY_INTEGER;

    p_repair_cost_tbl repair_cost_tbl_type;
    p_wip_entity_id_tbl wip_entity_id_tbl_type;

    CURSOR c_cost_calc is
      SELECT  SUM(WEPB.ACTUAL_MAT_COST+WEPB.ACTUAL_LAB_COST+WEPB.ACTUAL_EQP_COST) COST,
              WEPB.WIP_ENTITY_ID
	    FROM 	WIP_EAM_PERIOD_BALANCES WEPB, EAM_FAILURE_HISTORY_TEMP EFHT
      WHERE EFHT.GROUP_ID = p_group_id
      AND EFHT.MAINT_ORGANIZATION_ID = WEPB.ORGANIZATION_ID
      AND EFHT.WIP_ENTITY_ID = WEPB.WIP_ENTITY_ID
      AND EFHT.INCLUDE_FOR_COST_AGGR = 'Y'
      GROUP BY WEPB.WIP_ENTITY_ID;


BEGIN
      g_module_name :=  'COMPUTE_REPAIR_COSTS';

      OPEN c_cost_calc;
      LOOP
        FETCH c_cost_calc BULK COLLECT INTO	p_repair_cost_tbl, p_wip_entity_id_tbl LIMIT 500;

         IF ( p_wip_entity_id_tbl.Count > 0 ) THEN
            FORALL i IN p_wip_entity_id_tbl.first .. p_wip_entity_id_tbl.last
                UPDATE EAM_FAILURE_HISTORY_TEMP
                SET COST_TO_REPAIR = Nvl(P_repair_cost_tbl(i),0)
                WHERE WIP_ENTITY_ID = P_wip_entity_id_tbl(i)
                AND GROUP_ID = p_group_id
                AND INCLUDE_FOR_COST_AGGR = 'Y';
         END IF;
         EXIT WHEN c_cost_calc%NOTFOUND;
      END LOOP;
      CLOSE c_cost_calc;
END COMPUTE_REPAIR_COSTS;



PROCEDURE VALIDATE_RECORDS(P_ASSET_FAILURE_TBL    IN OUT NOCOPY EAM_ASSET_FAILURE_TBL_TYPE,
                           P_VALIDATE_METERS      VARCHAR2,
                           P_VALIDATE_CURRENCY    VARCHAR2,
                           P_CURRENT_ORG_ID       NUMBER,
                           x_unmatched_uom_class  OUT	NOCOPY VARCHAR2,
                           x_unmatched_currency   OUT	NOCOPY VARCHAR2) IS

  l_asset_failure_tbl EAM_ASSET_FAILURE_TBL_TYPE;
  l_same_prim_curr  NUMBER;
  l_uom1_conv_rate  NUMBER;
  l_uom2_conv_rate  NUMBER;
  l_meter_uom1      VARCHAR2(3);
  l_meter_uom2      VARCHAR2(3);
  l_primary_uom     VARCHAR2(3);
  l_org2            NUMBER;
BEGIN
   g_module_name :=  'VALIDATE_RECORDS';
   l_asset_failure_tbl := P_asset_failure_tbl;
   FOR i in l_asset_failure_tbl.first .. l_asset_failure_tbl.last
    loop
        if ( p_validate_currency = 'Y') then
                l_org2 :=  l_asset_failure_tbl(i).organization_id;

                if l_org2 <> p_current_org_id then

                  BEGIN
		    l_asset_failure_tbl(i).include_for_cost_aggr := 'Y';

                    select 1 into l_same_prim_curr
                    from cst_organization_definitions cod1, cst_organization_definitions cod2,
                          gl_sets_of_books gsob1, gl_sets_of_books gsob2
                    where cod1.organization_id = p_current_org_id
                    and cod2.organization_id = l_org2
                    and cod1.set_of_books_id = gsob1.set_of_books_id
                    and cod2.set_of_books_id = gsob2.set_of_books_id
                    and gsob1.currency_code = gsob2.currency_code;

                  EXCEPTION
                    WHEN No_Data_Found THEN
                      --warning:there are repair costs that are not included because they are not in the current maintenance organization's  currency.
                      x_unmatched_currency := 'Y';
                      l_asset_failure_tbl(i).include_for_cost_aggr := 'N';
                  END;
               end if;  --(l_org1 <> l_org2)
        end if; --p_compute_repair_costs = 'Y'

        If p_validate_meters  = 'Y' then
                --If i = l_asset_failure_tbl.first then
                IF ( ( i = l_asset_failure_tbl.FIRST) OR
                     ( l_asset_failure_tbl(i).maintained_group_id <> l_asset_failure_tbl(l_asset_failure_tbl.PRIOR(i)).maintained_group_id) ) then
                    l_meter_uom1 :=  l_asset_failure_tbl(i).meter_uom;
                else
                    l_meter_uom2 :=  l_asset_failure_tbl(i).meter_uom;

                    if l_meter_uom1 <> l_meter_uom2 then
                        begin
			    l_asset_failure_tbl(i).include_for_reading_aggr := 'Y';

                            select nvl(MUC1.CONVERSION_RATE,0) , nvl(MUC2.CONVERSION_RATE,0), MUOFVL.UOM_CODE
                            into l_uom1_conv_rate, l_uom2_conv_rate, l_primary_uom
                            from MTL_UOM_CONVERSIONS MUC1, MTL_UOM_CONVERSIONS MUC2, MTL_UNITS_OF_MEASURE_VL MUOFVL
                            where MUC1.UOM_CODE = l_meter_uom1
                            and MUC2.UOM_CODE = l_meter_uom2
                            AND NVL(MUC1.DISABLE_DATE, SYSDATE + 1) > SYSDATE
                            AND NVL(MUC2.DISABLE_DATE, SYSDATE + 1) > SYSDATE
                            AND MUC1.INVENTORY_ITEM_ID = 0
                            AND MUC2.INVENTORY_ITEM_ID = 0
                            AND MUC1.UOM_CLASS = MUC2.UOM_CLASS
                            AND MUOFVL.UOM_CLASS = MUC1.UOM_CLASS
                            AND MUOFVL.BASE_UOM_FLAG = 'Y'
                            AND NVL(MUOFVL.DISABLE_DATE, SYSDATE + 1) > SYSDATE;


                            l_asset_failure_tbl(i).meter_uom := l_primary_uom;
                            l_asset_failure_tbl(i).reading_between_failures :=
                              l_asset_failure_tbl(i).reading_between_failures * l_uom2_conv_rate ;

                            l_asset_failure_tbl(l_asset_failure_tbl.PRIOR(i)).meter_uom := l_primary_uom;
                            l_asset_failure_tbl(l_asset_failure_tbl.PRIOR(i)).reading_between_failures :=
                              l_asset_failure_tbl(l_asset_failure_tbl.PRIOR(i)).reading_between_failures * l_uom1_conv_rate ;

                        exception
                          when no_data_found then
                              --warning:there are meters which are not included because they are not in the same uom class.
                              x_unmatched_uom_class := 'Y';
                              l_asset_failure_tbl(i).include_for_reading_aggr := 'N';
                       end;
                    end if;  -- (l_meter_uom1 <> l_meter_uom2)
              end if;   -- (i = l_asset_failure_tbl.first)
        end if; -- (p_validate_meters  = 'Y')
    End loop;
    p_asset_failure_tbl := l_asset_failure_tbl;
END VALIDATE_RECORDS;

Procedure GET_CHILD_RECORDS_FA_SIMPLE
( P_GEN_OBJECT_ID         IN  NUMBER,
  P_MAINT_GROUP_ID        IN  NUMBER,
  P_CATEGORY_ID           IN  NUMBER,
  P_FAILURE_CODE          IN  VARCHAR2,
  P_FROM_DATE	          IN  DATE,
  P_TO_DATE               IN  DATE,
  P_VIEW_BY	          IN  VARCHAR2,
  P_COMPUTE_REPAIR_COSTS  IN  VARCHAR2,
  P_CURRENT_ORG_ID        IN  NUMBER,
  x_group_id 	            IN OUT NOCOPY NUMBER,
  x_return_status         OUT NOCOPY  VARCHAR2,
  x_msg_data              OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class   OUT NOCOPY  VARCHAR2,
  x_unmatched_currency    OUT NOCOPY  VARCHAR2) IS

  l_asset_failure_tbl    EAM_FAILURE_ANALYSIS_PVT.eam_asset_failure_tbl_type;
  l_group_id        NUMBER;

 l_gen_object_id    number;
 l_maint_group_id   number;
 l_category_id      number;

 l_unmatched_uom_class VARCHAR2(1) := 'N';
 l_unmatched_currency  VARCHAR2(1) := 'N';
 l_validate_meters     VARCHAR2(1);
 l_validate_currency   VARCHAR2(1);

 l_msg_data VARCHAR2(500);
 l_return_status VARCHAR2(1) := 'S';
/* [Parent + Child Failure WOs][When NONE of failure code/from date/to date have been entered as search criteria] - View By Asset Category */
  CURSOR c_recs_ac_simple IS
        SELECT /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.CATEGORY_ID ORDER BY EAF.FAILURE_DATE  ),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    NULL METER_ID,
	                  NULL METER_NAME,
	                  NULL METER_UOM,
                    NULL READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
		    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                            FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
									(
									SELECT OBJECT_ID   --This part will select all children assets
									FROM MTL_OBJECT_GENEALOGY
				                                        START WITH PARENT_OBJECT_ID IN
									(
									  SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
									  FROM MTL_SERIAL_NUMBERS MSN,
									  CSI_ITEM_INSTANCES CII
									  WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
			                                                  AND  CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
									  AND (l_gen_object_id IS NULL OR CII.INSTANCE_ID = l_gen_object_id)
									  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
									  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
									 )
									 CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID
									 )
                                          UNION
                                           SELECT  CII.INSTANCE_ID OBJECT_ID    --This part will select the parent assets
                                           FROM	CSI_ITEM_INSTANCES CII
					   WHERE (l_gen_object_id IS NULL OR CII.INSTANCE_ID = l_gen_object_id)
                                           AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
                                           AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                                           ) ;

 /* [Parent + Child Failure WOs][When NONE of failure code/from date/to date have been entered as search criteria and l_gen_object_id is not null] - View By Asset Category */
 CURSOR c_recs_ac_simple_1 IS
        SELECT /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.CATEGORY_ID ORDER BY EAF.FAILURE_DATE  ),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    NULL METER_ID,
	                  NULL METER_NAME,
	                  NULL METER_UOM,
                    NULL READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
		    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                            FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
									(
									SELECT OBJECT_ID   --This part will select all children assets
									FROM MTL_OBJECT_GENEALOGY
				                                        START WITH PARENT_OBJECT_ID IN
									(
									  SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
									  FROM MTL_SERIAL_NUMBERS MSN,
									  CSI_ITEM_INSTANCES CII
									  WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
			                                                  AND  CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
									  AND CII.INSTANCE_ID = l_gen_object_id
									  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
									  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
									 )
									 CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID
									 )
                                          UNION
                                           SELECT  CII.INSTANCE_ID OBJECT_ID    --This part will select the parent assets
                                           FROM	CSI_ITEM_INSTANCES CII
					   WHERE  CII.INSTANCE_ID = l_gen_object_id
                                           AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
                                           AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                                           ) ;


  /* [Parent + Child Failure WOs][When ANY of failure code/from date/to date have been entered as search criteria] - View By Asset Category */
  CURSOR c_recs_wo_ac_simple IS
        SELECT /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
		    MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    NVL(WDJ.ASSET_NUMBER, WDJ.REBUILD_SERIAL_NUMBER) MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.CATEGORY_ID ORDER BY EAF.FAILURE_DATE  ),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    NULL METER_ID,
	                  NULL METER_NAME,
	                  NULL METER_UOM,
                    NULL READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
		    CSI_ITEM_INSTANCES CII,
                    ORG_ORGANIZATION_DEFINITIONS OOD
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
		    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
		    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
		    AND (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
		    AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date)
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                           FROM CSI_ITEM_INSTANCES CII,
						 MTL_SERIAL_NUMBERS MSN
						 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
						 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
						 AND MSN.gen_object_id IN (
									 SELECT OBJECT_ID   --This part will select all children assets
									 FROM MTL_OBJECT_GENEALOGY
									 START WITH PARENT_OBJECT_ID IN
											( SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
											  FROM CSI_ITEM_INSTANCES  CII,
												EAM_ASSET_FAILURE_CODES EAFC,
												EAM_ASSET_FAILURES EAF,
												WIP_DISCRETE_JOBS WDJ,
												MTL_SERIAL_NUMBERS MSN
											WHERE	WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
											  AND	WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
											  AND	WDJ.STATUS_TYPE IN (4,5,12)
											  AND	EAF.SOURCE_TYPE = 1
											  AND	EAF.OBJECT_TYPE = 3
											  AND	EAF.OBJECT_ID = CII.INSTANCE_ID
											  AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
											  AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
											  AND   CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
											  AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
											  AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
											  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
											  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
											  AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
											  AND (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
											  AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date)
											  )
									 CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID
									 )

			         UNION
				 SELECT MAINTENANCE_OBJECT_ID FROM(
					    SELECT MAINTENANCE_OBJECT_ID FROM (
					    SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
					    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
					    NVL(WDJ.ASSET_NUMBER, WDJ.REBUILD_SERIAL_NUMBER) MAINTAINED_NUMBER,
					     CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
					    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
					    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
					    WDJ.WIP_ENTITY_ID,
					    WE.WIP_ENTITY_NAME,
					    WDJ.ORGANIZATION_ID,
					    OOD.ORGANIZATION_CODE,
					    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
					    CII.CATEGORY_ID ASSET_CATEGORY_ID,
					    MEL.LOCATION_CODES ASSET_LOCATION,
					    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
					    EAFC.FAILURE_CODE,
					    EAFC.CAUSE_CODE,
					    EAFC.RESOLUTION_CODE,
					    EAF.FAILURE_DATE,
					    EAFC.COMMENTS,
					    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.CATEGORY_ID ORDER BY EAF.FAILURE_DATE  ),
					      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
					      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
									FROM  CSI_ITEM_INSTANCES CII1
									WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
									AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
					      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
								   ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
					    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
					    NULL METER_ID,
						  NULL METER_NAME,
						  NULL METER_UOM,
					    NULL READING_BETWEEN_FAILURES,
					    'Y' INCLUDE_FOR_READING_AGGR,
					    'Y' INCLUDE_FOR_COST_AGGR
				      FROM  WIP_DISCRETE_JOBS WDJ,
					    WIP_ENTITIES WE,
					    MTL_CATEGORIES_KFV MCKFV,
					    MTL_SYSTEM_ITEMS_KFV MSIKFV,
					    MTL_EAM_LOCATIONS MEL,
					    BOM_DEPARTMENTS BD,
					    EAM_ASSET_FAILURE_CODES EAFC,
					    EAM_ASSET_FAILURES EAF,
					    ORG_ORGANIZATION_DEFINITIONS OOD,
					    CSI_ITEM_INSTANCES CII
				      WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
					    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
					    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
					    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
						  AND WDJ.STATUS_TYPE IN (4,5,12)
					    AND	EAF.SOURCE_TYPE = 1
					    AND	EAF.OBJECT_TYPE = 3
					    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
					    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
					    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
					    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
					    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
					    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
					    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
					    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
					    AND EAF.OBJECT_ID IN  (SELECT EAF.OBJECT_ID OBJECT_ID  --This part will select parent assets
								    FROM EAM_ASSET_FAILURE_CODES EAFC,
									 EAM_ASSET_FAILURES EAF,
									 WIP_DISCRETE_JOBS WDJ,
									 CSI_ITEM_INSTANCES CII
								    WHERE	WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
								    AND	WDJ.STATUS_TYPE IN (4,5,12)
								    AND	EAF.SOURCE_TYPE = 1
								    AND	EAF.OBJECT_TYPE = 3
								    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
								    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
								    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
								    AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
								    AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
								    AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
								    AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
								  )
					      )
				WHERE (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
				AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date) ) );

 /* [Parent + Child Failure WOs][When NONE of failure code/from date/to date have been entered as search criteria] - View By Failure Code */

  CURSOR c_recs_fc_simple IS
        SELECT /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAFC.FAILURE_CODE ORDER BY EAF.FAILURE_DATE  ),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    NULL METER_ID,
	                  NULL METER_NAME,
	                  NULL METER_UOM,
                    NULL READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	            AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                           FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
							   (SELECT OBJECT_ID   --This part will select all children assets
							    FROM MTL_OBJECT_GENEALOGY
							    START WITH PARENT_OBJECT_ID IN
									( SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
									  FROM MTL_SERIAL_NUMBERS MSN,
									  CSI_ITEM_INSTANCES CII
									  WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
			                                                  AND  CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
									  AND (l_gen_object_id IS NULL OR CII.INSTANCE_ID = l_gen_object_id)
									  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
									  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
									)
							    CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID
							    )
                                           UNION
                                            SELECT CII.INSTANCE_ID OBJECT_ID   --This part will select all parent assets
                                            FROM CSI_ITEM_INSTANCES CII
					    WHERE (l_gen_object_id IS NULL OR CII.INSTANCE_ID = l_gen_object_id)
                                            AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
                                            AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                                           ) ;
 /* [Parent + Child Failure WOs][When NONE of failure code/from date/to date have been entered as search criteria and l_gen_object_id is not null] - View By Failure Code */

  CURSOR c_recs_fc_simple_1 IS
        SELECT   /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAFC.FAILURE_CODE ORDER BY EAF.FAILURE_DATE  ),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    NULL METER_ID,
	                  NULL METER_NAME,
	                  NULL METER_UOM,
                    NULL READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	            AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                           FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
							   (SELECT OBJECT_ID   --This part will select all children assets
							    FROM MTL_OBJECT_GENEALOGY
							    START WITH PARENT_OBJECT_ID IN
									( SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
									  FROM MTL_SERIAL_NUMBERS MSN,
									  CSI_ITEM_INSTANCES CII
									  WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
			                                                  AND  CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
									  AND  CII.INSTANCE_ID = l_gen_object_id
									  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
									  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
									)
							    CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID
							    )
                                           UNION
                                            SELECT CII.INSTANCE_ID OBJECT_ID   --This part will select all parent assets
                                            FROM CSI_ITEM_INSTANCES CII
					    WHERE CII.INSTANCE_ID = l_gen_object_id
                                            AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
                                            AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                                           ) ;

  /* [Parent + Child Failure WOs][When ANY of failure code/from date/to date have been entered as search criteria] - View By Failure Code */
  CURSOR c_recs_wo_fc_simple IS
        SELECT /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    NVL(WDJ.ASSET_NUMBER, WDJ.REBUILD_SERIAL_NUMBER) MAINTAINED_NUMBER,
                     CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAFC.FAILURE_CODE ORDER BY EAF.FAILURE_DATE  ),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    NULL METER_ID,
	                  NULL METER_NAME,
	                  NULL METER_UOM,
                    NULL READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
		    CSI_ITEM_INSTANCES CII,
                    ORG_ORGANIZATION_DEFINITIONS OOD
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	            AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
		    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
		    AND (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
		    AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date)
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                            FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
							(SELECT OBJECT_ID   --This part will select all children assets
							    FROM MTL_OBJECT_GENEALOGY
							    START WITH PARENT_OBJECT_ID IN
								( SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
								  FROM EAM_ASSET_FAILURE_CODES EAFC,
									EAM_ASSET_FAILURES EAF,
									WIP_DISCRETE_JOBS WDJ,
									MTL_SERIAL_NUMBERS MSN,
									CSI_ITEM_INSTANCES CII
								  WHERE	WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
								  AND	WDJ.STATUS_TYPE IN (4,5,12)
								  AND	EAF.SOURCE_TYPE = 1
								  AND	EAF.OBJECT_TYPE = 3
								  AND	EAF.OBJECT_ID = CII.INSTANCE_ID
								  AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
								  AND	CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
								  AND	CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
								  AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
								  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
								  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
								  AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
								  AND (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
								  AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date)
							       )
							    CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID)

				 UNION
					 SELECT MAINTENANCE_OBJECT_ID FROM (
					    SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
					    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
					    NVL(WDJ.ASSET_NUMBER, WDJ.REBUILD_SERIAL_NUMBER) MAINTAINED_NUMBER,
					     CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
					    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
					    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
					    WDJ.WIP_ENTITY_ID,
					    WE.WIP_ENTITY_NAME,
					    WDJ.ORGANIZATION_ID,
					    OOD.ORGANIZATION_CODE,
					    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
					    CII.CATEGORY_ID ASSET_CATEGORY_ID,
					    MEL.LOCATION_CODES ASSET_LOCATION,
					    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
					    EAFC.FAILURE_CODE,
					    EAFC.CAUSE_CODE,
					    EAFC.RESOLUTION_CODE,
					    EAF.FAILURE_DATE,
					    EAFC.COMMENTS,
					    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAFC.FAILURE_CODE ORDER BY EAF.FAILURE_DATE  ),
					      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
					      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
									FROM  CSI_ITEM_INSTANCES CII1
									WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
									AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
					      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
								   ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
					    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
					    NULL METER_ID,
						  NULL METER_NAME,
						  NULL METER_UOM,
					    NULL READING_BETWEEN_FAILURES,
					    'Y' INCLUDE_FOR_READING_AGGR,
					    'Y' INCLUDE_FOR_COST_AGGR
				      FROM  WIP_DISCRETE_JOBS WDJ,
					    WIP_ENTITIES WE,
					    MTL_CATEGORIES_KFV MCKFV,
					    MTL_SYSTEM_ITEMS_KFV MSIKFV,
					    MTL_EAM_LOCATIONS MEL,
					    BOM_DEPARTMENTS BD,
					    EAM_ASSET_FAILURE_CODES EAFC,
					    EAM_ASSET_FAILURES EAF,
					    CSI_ITEM_INSTANCES CII,
					    ORG_ORGANIZATION_DEFINITIONS OOD
				      WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
					    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
					    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
					    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
						  AND WDJ.STATUS_TYPE IN (4,5,12)
					    AND	EAF.SOURCE_TYPE = 1
					    AND	EAF.OBJECT_TYPE = 3
					    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
					    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
					    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
					    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
					    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
					    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
					    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
					    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
					    AND EAF.OBJECT_ID IN  ( SELECT EAF.OBJECT_ID OBJECT_ID  --This part will select all parent assets
								    FROM EAM_ASSET_FAILURE_CODES EAFC,
									 EAM_ASSET_FAILURES EAF,
									 WIP_DISCRETE_JOBS WDJ,
									 CSI_ITEM_INSTANCES
								    WHERE	WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
								    AND	WDJ.STATUS_TYPE IN (4,5,12)
								    AND	EAF.SOURCE_TYPE = 1
								    AND	EAF.OBJECT_TYPE = 3
								    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
								    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
								    AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
								    AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
								    AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
								    AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
								  )
					    )
				WHERE (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
				AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date) );


  /* [Parent + Child Failure WOs][When NONE of failure code/from date/to date have been entered as search criteria] - View By Asset Number */

  CURSOR c_meter_recs_an_simple IS
        SELECT /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  ),
                      NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    METER.METER_ID,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT
    ccb.counter_id METER_ID,
    cctl.name METER_NAME,
    ccb.uom_code METER_UOM,
    CCA.SOURCE_OBJECT_ID  MAINTENANCE_OBJECT_ID,
    CCR.COUNTER_READING CURRENT_READING,
    CCR.VALUE_TIMESTAMP CURRENT_READING_DATE,
    CCA.PRIMARY_FAILURE_FLAG PRIMARY_FAILURE_METER,
    decode(ct.transaction_type_id,92,ct.source_header_ref_id,to_number(null)) WIP_ENTITY_ID,
    CCB.reading_type METER_TYPE
FROM csi_counters_b CCB,csi_counters_tl cctl, csi_counter_readings CCR, csi_counter_associations CCA, csi_transactions CT
WHERE
	ccb.counter_id = cctl.counter_id
	and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1)
	and cctl.language = userenv('LANG') and ccb.counter_type = 'REGULAR'
	AND	CCB.COUNTER_ID = CCA.COUNTER_ID
	AND CCR.COUNTER_ID(+) = CCB.COUNTER_ID
	AND CCR.transaction_id = CT.transaction_id(+)
	and SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1) AND nvl(cca.end_date_active, SYSDATE+1)
    AND CCA.PRIMARY_FAILURE_FLAG = 'Y'
	AND CCB.EAM_REQUIRED_FLAG = 'Y'
    AND CCR.COUNTER_VALUE_ID IN
    (
    SELECT
        METER_READING_ID
    FROM
        (
        SELECT
            Max(EMR1.METER_READING_ID) METER_READING_ID
        FROM EAM_METER_READINGS_V EMR1
        GROUP BY EMR1.WIP_ENTITY_ID,
            EMR1.METER_ID
        )
    ))    METER
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                            FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
								  (SELECT OBJECT_ID   --This part will select all children assets
								   FROM MTL_OBJECT_GENEALOGY
								   START WITH PARENT_OBJECT_ID IN
									( SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
									  FROM MTL_SERIAL_NUMBERS MSN,
									       CSI_ITEM_INSTANCES CII
									  WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
			                                                  AND  CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
									  AND (l_gen_object_id IS NULL OR CII.INSTANCE_ID = l_gen_object_id)
									  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
									  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
									 )
								       CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID
								      )
                    UNION
                    SELECT MAINTENANCE_OBJECT_ID FROM
		    (
		    SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    NVL(WDJ.ASSET_NUMBER, WDJ.REBUILD_SERIAL_NUMBER) MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
		    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  ),
                      NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    METER.METER_ID,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
		    CSI_ITEM_INSTANCES CII,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT EM.METER_ID,
                            EM.METER_NAME,
                            EM.METER_UOM,
                            EAM.MAINTENANCE_OBJECT_ID,
                            EMR.CURRENT_READING,
                            EMR.CURRENT_READING_DATE,
                            EAM.PRIMARY_FAILURE_METER,
                            EMR.WIP_ENTITY_ID,
                            EM.METER_TYPE
                    FROM  EAM_METERS EM,
	                        EAM_ASSET_METERS EAM,
	                        EAM_METER_READINGS EMR
                    WHERE EM.METER_ID = EAM.METER_ID
                    AND EMR.METER_ID = EAM.METER_ID
                    AND EM.REQUIRED_FLAG = 'Y'
                    --AND EAM.PRIMARY_FAILURE_METER  = 'Y'
                   -- AND ( (l_selected_meter IS NULL 	AND EAM.PRIMARY_FAILURE_METER  = 'Y') OR
                     --     (l_selected_meter IS NOT NULL 	AND EM.METER_ID = l_selected_meter))
                    AND EMR.METER_READING_ID IN
                              (SELECT METER_READING_ID FROM
                                       (SELECT Max(EMR1.METER_READING_ID) METER_READING_ID,EMR1.WIP_ENTITY_ID,EMR1.METER_ID
                                        FROM EAM_METER_READINGS EMR1
                                        GROUP BY EMR1.WIP_ENTITY_ID, EMR1.METER_ID )))    METER
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	            AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
                    AND EAF.OBJECT_ID IN  ( SELECT CII.INSTANCE_ID OBJECT_ID    --This part will select all parent assets
                                            FROM CSI_ITEM_INSTANCES CII
					    WHERE(l_gen_object_id IS NULL OR CII.INSTANCE_ID = l_gen_object_id)
                                            AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
                                            AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                                          )));
 /* [Parent + Child Failure WOs][When NONE of failure code/from date/to date have been entered as search criteria and l_gen_object_id is not null] - View By Asset Number */

  CURSOR c_meter_recs_an_simple_1 IS
        SELECT  /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  ),
                      NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    METER.METER_ID,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT
    ccb.counter_id METER_ID,
    cctl.name METER_NAME,
    ccb.uom_code METER_UOM,
    CCA.SOURCE_OBJECT_ID  MAINTENANCE_OBJECT_ID,
    CCR.COUNTER_READING CURRENT_READING,
    CCR.VALUE_TIMESTAMP CURRENT_READING_DATE,
    CCA.PRIMARY_FAILURE_FLAG PRIMARY_FAILURE_METER,
    decode(ct.transaction_type_id,92,ct.source_header_ref_id,to_number(null)) WIP_ENTITY_ID,
    CCB.reading_type METER_TYPE
FROM csi_counters_b CCB,csi_counters_tl cctl, csi_counter_readings CCR, csi_counter_associations CCA, csi_transactions CT
WHERE
	ccb.counter_id = cctl.counter_id
	and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1)
	and cctl.language = userenv('LANG') and ccb.counter_type = 'REGULAR'
	AND	CCB.COUNTER_ID = CCA.COUNTER_ID
	AND CCR.COUNTER_ID(+) = CCB.COUNTER_ID
	AND CCR.transaction_id = CT.transaction_id(+)
	and SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1) AND nvl(cca.end_date_active, SYSDATE+1)
    AND CCA.PRIMARY_FAILURE_FLAG = 'Y'
	AND CCB.EAM_REQUIRED_FLAG = 'Y'
    AND CCR.COUNTER_VALUE_ID IN
    (
    SELECT
        METER_READING_ID
    FROM
        (
        SELECT
            Max(EMR1.METER_READING_ID) METER_READING_ID
        FROM EAM_METER_READINGS_V EMR1
        GROUP BY EMR1.WIP_ENTITY_ID,
            EMR1.METER_ID
        )
    ))    METER
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                            FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
								  (SELECT OBJECT_ID   --This part will select all children assets
								   FROM MTL_OBJECT_GENEALOGY
								   START WITH PARENT_OBJECT_ID IN
									( SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
									  FROM MTL_SERIAL_NUMBERS MSN,
									       CSI_ITEM_INSTANCES CII
									  WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
			                                                  AND  CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
									  AND CII.INSTANCE_ID = l_gen_object_id
									  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
									  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
									 )
								       CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID
								      )
                    UNION
                    SELECT MAINTENANCE_OBJECT_ID FROM
		    (
		    SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    NVL(WDJ.ASSET_NUMBER, WDJ.REBUILD_SERIAL_NUMBER) MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
		    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  ),
                      NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    METER.METER_ID,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
		    CSI_ITEM_INSTANCES CII,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT EM.METER_ID,
                            EM.METER_NAME,
                            EM.METER_UOM,
                            EAM.MAINTENANCE_OBJECT_ID,
                            EMR.CURRENT_READING,
                            EMR.CURRENT_READING_DATE,
                            EAM.PRIMARY_FAILURE_METER,
                            EMR.WIP_ENTITY_ID,
                            EM.METER_TYPE
                    FROM  EAM_METERS EM,
	                        EAM_ASSET_METERS EAM,
	                        EAM_METER_READINGS EMR
                    WHERE EM.METER_ID = EAM.METER_ID
                    AND EMR.METER_ID = EAM.METER_ID
                    AND EM.REQUIRED_FLAG = 'Y'
                    --AND EAM.PRIMARY_FAILURE_METER  = 'Y'
                   -- AND ( (l_selected_meter IS NULL 	AND EAM.PRIMARY_FAILURE_METER  = 'Y') OR
                     --     (l_selected_meter IS NOT NULL 	AND EM.METER_ID = l_selected_meter))
                    AND EMR.METER_READING_ID IN
                              (SELECT METER_READING_ID FROM
                                       (SELECT Max(EMR1.METER_READING_ID) METER_READING_ID,EMR1.WIP_ENTITY_ID,EMR1.METER_ID
                                        FROM EAM_METER_READINGS EMR1
                                        GROUP BY EMR1.WIP_ENTITY_ID, EMR1.METER_ID )))    METER
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	            AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
                    AND EAF.OBJECT_ID IN  ( SELECT CII.INSTANCE_ID OBJECT_ID    --This part will select all parent assets
                                            FROM CSI_ITEM_INSTANCES CII
					    WHERE CII.INSTANCE_ID = l_gen_object_id
                                            AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
                                            AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                                          )));


  /* [Parent + Child Failure WOs][When ANY of failure code/from date/to date have been entered as search criteria] - View By Asset Number */
  CURSOR c_meter_recs_wo_an_simple IS
        SELECT /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  ),
                      NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    METER.METER_ID,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
		    CSI_ITEM_INSTANCES CII,
                    (SELECT EM.METER_ID,
                            EM.METER_NAME,
                            EM.METER_UOM,
                            EAM.MAINTENANCE_OBJECT_ID,
                            EMR.CURRENT_READING,
                            EMR.CURRENT_READING_DATE,
                            EAM.PRIMARY_FAILURE_METER,
                            EMR.WIP_ENTITY_ID,
                            EM.METER_TYPE

                    FROM  EAM_METERS EM,
			EAM_ASSET_METERS EAM,
			EAM_METER_READINGS EMR

                    WHERE EM.METER_ID = EAM.METER_ID
                    AND EMR.METER_ID = EAM.METER_ID
                    AND EM.REQUIRED_FLAG = 'Y'
                    --AND EAM.PRIMARY_FAILURE_METER  = 'Y'
                 --   AND ( (l_selected_meter IS NULL 	AND EAM.PRIMARY_FAILURE_METER  = 'Y') OR
                   --       (l_selected_meter IS NOT NULL 	AND EM.METER_ID = l_selected_meter))
                    AND EMR.METER_READING_ID IN
                              (SELECT METER_READING_ID FROM
                                       (SELECT Max(EMR1.METER_READING_ID) METER_READING_ID,EMR1.WIP_ENTITY_ID,EMR1.METER_ID
                                        FROM EAM_METER_READINGS EMR1
                                        GROUP BY EMR1.WIP_ENTITY_ID, EMR1.METER_ID )))    METER
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	            AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
		    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                   -- AND	MSN.GEN_OBJECT_ID = WDJ.MAINTENANCE_OBJECT_ID
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
		    AND (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
		    AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date)
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                            FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
						       (SELECT OBJECT_ID   --This part will select all children assets
							FROM MTL_OBJECT_GENEALOGY
							START WITH PARENT_OBJECT_ID IN
								( SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
								  FROM CSI_ITEM_INSTANCES CII,
									EAM_ASSET_FAILURE_CODES EAFC,
									EAM_ASSET_FAILURES EAF,
									WIP_DISCRETE_JOBS WDJ,
									MTL_SERIAL_NUMBERS MSN
								  WHERE	NVL(WDJ.STATUS_TYPE,4) IN (4,5,12)
								  AND	EAF.SOURCE_TYPE(+) = 1
								  AND	EAF.OBJECT_TYPE(+) = 3
								  AND	EAF.OBJECT_ID(+) = CII.INSTANCE_ID
								  AND	EAF.FAILURE_ID = EAFC.FAILURE_ID(+)
								  AND	CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
								  AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
								  AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
								  AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
								  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
								  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
								  AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
								  AND (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
								  AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date)
								  )
							CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID)

				 UNION
					SELECT MAINTENANCE_OBJECT_ID FROM (
						SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
						    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
						    NVL(WDJ.ASSET_NUMBER, WDJ.REBUILD_SERIAL_NUMBER) MAINTAINED_NUMBER,
						    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
						    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
						    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
						    WDJ.WIP_ENTITY_ID,
						    WE.WIP_ENTITY_NAME,
						    WDJ.ORGANIZATION_ID,
						    OOD.ORGANIZATION_CODE,
						    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
						    CII.CATEGORY_ID ASSET_CATEGORY_ID,
						    MEL.LOCATION_CODES ASSET_LOCATION,
						    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
						    EAFC.FAILURE_CODE,
						    EAFC.CAUSE_CODE,
						    EAFC.RESOLUTION_CODE,
						    EAF.FAILURE_DATE,
						    EAFC.COMMENTS,
						    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  ),
						      NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
						      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
									   ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
						    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
						    METER.METER_ID,
							  METER.METER_NAME METER_NAME,
							  METER.METER_UOM METER_UOM,
						    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
						     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
							NULL, METER.CURRENT_READING,
							(METER.CURRENT_READING -
							  (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
						    'Y' INCLUDE_FOR_READING_AGGR,
						    'Y' INCLUDE_FOR_COST_AGGR
					      FROM  WIP_DISCRETE_JOBS WDJ,
						    WIP_ENTITIES WE,
						    MTL_CATEGORIES_KFV MCKFV,
						    MTL_SYSTEM_ITEMS_KFV MSIKFV,
						    MTL_EAM_LOCATIONS MEL,
						    BOM_DEPARTMENTS BD,
						    EAM_ASSET_FAILURE_CODES EAFC,
						    EAM_ASSET_FAILURES EAF,
						    ORG_ORGANIZATION_DEFINITIONS OOD,
						    CSI_ITEM_INSTANCES CII,
						    (SELECT EM.METER_ID,
							    EM.METER_NAME,
							    EM.METER_UOM,
							    EAM.MAINTENANCE_OBJECT_ID,
							    EMR.CURRENT_READING,
							    EMR.CURRENT_READING_DATE,
							    EAM.PRIMARY_FAILURE_METER,
							    EMR.WIP_ENTITY_ID,
							    EM.METER_TYPE
						    FROM  EAM_METERS EM,
								EAM_ASSET_METERS EAM,
								EAM_METER_READINGS EMR
						    WHERE EM.METER_ID = EAM.METER_ID
						    AND EMR.METER_ID = EAM.METER_ID
						    AND EM.REQUIRED_FLAG = 'Y'
						    AND EAM.PRIMARY_FAILURE_METER  = 'Y'
						    AND EMR.METER_READING_ID IN
							      (SELECT METER_READING_ID FROM
								       (SELECT Max(EMR1.METER_READING_ID) METER_READING_ID,EMR1.WIP_ENTITY_ID,EMR1.METER_ID
									FROM EAM_METER_READINGS EMR1
									GROUP BY EMR1.WIP_ENTITY_ID, EMR1.METER_ID )))    METER
					      WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
						    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
						    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
						    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
							  AND WDJ.STATUS_TYPE IN (4,5,12)
						    AND	EAF.SOURCE_TYPE = 1
						    AND	EAF.OBJECT_TYPE = 3
						    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
						    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
						    --AND	MSN.GEN_OBJECT_ID = WDJ.MAINTENANCE_OBJECT_ID
						    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
						    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
						    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
						    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
						    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
						    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
						    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
						    AND EAF.OBJECT_ID IN  ( SELECT EAF.OBJECT_ID OBJECT_ID    --This part will select all parent assets
									    FROM EAM_ASSET_FAILURE_CODES EAFC,
										 EAM_ASSET_FAILURES EAF,
										 WIP_DISCRETE_JOBS WDJ,
										 CSI_ITEM_INSTANCES CII
									    WHERE	WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
									    AND	WDJ.STATUS_TYPE IN (4,5,12)
									    AND	EAF.SOURCE_TYPE = 1
									    AND	EAF.OBJECT_TYPE = 3
									    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
									    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
									    AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
									    AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
									    AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
									    AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
									  )
						    )
					  WHERE (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
					  AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date) );

  /* [Parent + Child Failure WOs][When NONE of failure code/from date/to date have been entered as search criteria] - View By Asset Group */

  CURSOR c_meter_recs_ag_simple IS
        SELECT /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.INVENTORY_ITEM_ID ORDER BY EAF.FAILURE_DATE  ),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    METER.METER_ID,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT
                                ccb.counter_id METER_ID,
                                cctl.name METER_NAME,
                                ccb.uom_code METER_UOM,
                                CCA.SOURCE_OBJECT_ID  MAINTENANCE_OBJECT_ID,
                                CCR.COUNTER_READING CURRENT_READING,
                                CCR.VALUE_TIMESTAMP CURRENT_READING_DATE,
                                CCA.PRIMARY_FAILURE_FLAG,
                                decode(ct.transaction_type_id,92,ct.source_header_ref_id,to_number(null)) WIP_ENTITY_ID,
                                CCB.reading_type METER_TYPE
                            FROM csi_counters_b CCB,csi_counters_tl cctl, csi_counter_readings CCR, csi_counter_associations CCA, csi_transactions CT
                            WHERE
                            	ccb.counter_id = cctl.counter_id
                            	and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1)
                            	and cctl.language = userenv('LANG') and ccb.counter_type = 'REGULAR'
                            	AND	CCB.COUNTER_ID = CCA.COUNTER_ID
                            	AND CCR.COUNTER_ID(+) = CCB.COUNTER_ID
                            	AND CCR.transaction_id = CT.transaction_id(+)
                            	and SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1) AND nvl(cca.end_date_active, SYSDATE+1)
                                AND CCA.PRIMARY_FAILURE_FLAG = 'Y'
                            	AND CCB.EAM_REQUIRED_FLAG = 'Y'
                                AND CCR.COUNTER_VALUE_ID IN
                                (
                                SELECT
                                    METER_READING_ID
                                FROM
                                    (
                                    SELECT
                                        Max(EMR1.METER_READING_ID) METER_READING_ID
                                    FROM EAM_METER_READINGS_V EMR1
                                    GROUP BY EMR1.WIP_ENTITY_ID,
                                        EMR1.METER_ID
                                    )
                                ))    METER
                    WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                            FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
					       (SELECT OBJECT_ID   --This part will select all children assets
						FROM MTL_OBJECT_GENEALOGY
						START WITH PARENT_OBJECT_ID IN
							( SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
							  FROM MTL_SERIAL_NUMBERS MSN,
							  CSI_ITEM_INSTANCES CII
							  WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
							  AND  CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
							  AND (l_gen_object_id IS NULL OR CII.INSTANCE_ID = l_gen_object_id)
							  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
							  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
							)
						CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID
						)
                                           UNION
                                            SELECT CII.INSTANCE_ID OBJECT_ID --This part will select all parent assets
                                            FROM CSI_ITEM_INSTANCES CII
					    WHERE (l_gen_object_id IS NULL OR CII.INSTANCE_ID = l_gen_object_id)
                                            AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
                                            AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                                            ) ;
/* [Parent + Child Failure WOs][When NONE of failure code/from date/to date have been entered as search criteria and l_gen_object_id is not null] - View By Asset Group */

  CURSOR c_meter_recs_ag_simple_1 IS
        SELECT /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.INVENTORY_ITEM_ID ORDER BY EAF.FAILURE_DATE  ),
                      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    METER.METER_ID,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT
                                ccb.counter_id METER_ID,
                                cctl.name METER_NAME,
                                ccb.uom_code METER_UOM,
                                CCA.SOURCE_OBJECT_ID  MAINTENANCE_OBJECT_ID,
                                CCR.COUNTER_READING CURRENT_READING,
                                CCR.VALUE_TIMESTAMP CURRENT_READING_DATE,
                                CCA.PRIMARY_FAILURE_FLAG,
                                decode(ct.transaction_type_id,92,ct.source_header_ref_id,to_number(null)) WIP_ENTITY_ID,
                                CCB.reading_type METER_TYPE
                            FROM csi_counters_b CCB,csi_counters_tl cctl, csi_counter_readings CCR, csi_counter_associations CCA, csi_transactions CT
                            WHERE
                            	ccb.counter_id = cctl.counter_id
                            	and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1)
                            	and cctl.language = userenv('LANG') and ccb.counter_type = 'REGULAR'
                            	AND	CCB.COUNTER_ID = CCA.COUNTER_ID
                            	AND CCR.COUNTER_ID(+) = CCB.COUNTER_ID
                            	AND CCR.transaction_id = CT.transaction_id(+)
                            	and SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1) AND nvl(cca.end_date_active, SYSDATE+1)
                                AND CCA.PRIMARY_FAILURE_FLAG = 'Y'
                            	AND CCB.EAM_REQUIRED_FLAG = 'Y'
                                AND CCR.COUNTER_VALUE_ID IN
                                (
                                SELECT
                                    METER_READING_ID
                                FROM
                                    (
                                    SELECT
                                        Max(EMR1.METER_READING_ID) METER_READING_ID
                                    FROM EAM_METER_READINGS_V EMR1
                                    GROUP BY EMR1.WIP_ENTITY_ID,
                                        EMR1.METER_ID
                                    )
                                ))    METER
                    WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                            FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
					       (SELECT OBJECT_ID   --This part will select all children assets
						FROM MTL_OBJECT_GENEALOGY
						START WITH PARENT_OBJECT_ID IN
							( SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
							  FROM MTL_SERIAL_NUMBERS MSN,
							  CSI_ITEM_INSTANCES CII
							  WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
							  AND  CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
							  AND CII.INSTANCE_ID = l_gen_object_id
							  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
							  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
							)
						CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID
						)
                                           UNION
                                            SELECT CII.INSTANCE_ID OBJECT_ID --This part will select all parent assets
                                            FROM CSI_ITEM_INSTANCES CII
					    WHERE CII.INSTANCE_ID = l_gen_object_id
                                            AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
                                            AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
                                            ) ;


  /* [Parent + Child Failure WOs][When ANY of failure code/from date/to date have been entered as search criteria] - View By Asset Group */
  CURSOR c_meter_recs_wo_ag_simple IS
        SELECT /*+ use_nl(EAF WDJ) index(WDJ WIP_DISCRETE_JOBS_U1) */
	            MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    NVL(WDJ.ASSET_NUMBER, WDJ.REBUILD_SERIAL_NUMBER) MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.INVENTORY_ITEM_ID ORDER BY EAF.FAILURE_DATE  ),
                      --NULL, (EAF.FAILURE_DATE - MSN.CREATION_DATE),
                      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                                                FROM  CSI_ITEM_INSTANCES CII1
                                                WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    METER.METER_ID,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    'Y' INCLUDE_FOR_READING_AGGR,
                    'Y' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
		    CSI_ITEM_INSTANCES CII,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT EM.METER_ID,
                            EM.METER_NAME,
                            EM.METER_UOM,
                            EAM.MAINTENANCE_OBJECT_ID,
                            EMR.CURRENT_READING,
                            EMR.CURRENT_READING_DATE,
                            EAM.PRIMARY_FAILURE_METER,
                            EMR.WIP_ENTITY_ID,
                            EM.METER_TYPE
                    FROM  EAM_METERS EM,
	                        EAM_ASSET_METERS EAM,
	                        EAM_METER_READINGS EMR
                    WHERE EM.METER_ID = EAM.METER_ID
                    AND EMR.METER_ID = EAM.METER_ID
                    AND EM.REQUIRED_FLAG = 'Y'
                    AND EAM.PRIMARY_FAILURE_METER  = 'Y'
                    AND EMR.METER_READING_ID IN
                              (SELECT METER_READING_ID FROM
                                       (SELECT Max(EMR1.METER_READING_ID) METER_READING_ID,EMR1.WIP_ENTITY_ID,EMR1.METER_ID
                                        FROM EAM_METER_READINGS EMR1
                                        GROUP BY EMR1.WIP_ENTITY_ID, EMR1.METER_ID )))    METER
              WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
		    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
		    AND (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
		    AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date)
                    AND EAF.OBJECT_ID IN  (SELECT CII.INSTANCE_ID
                                            FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.GEN_OBJECT_ID IN
						       (SELECT OBJECT_ID   --This part will select all children assets
							FROM MTL_OBJECT_GENEALOGY
							START WITH PARENT_OBJECT_ID IN
								( SELECT MSN.GEN_OBJECT_ID PARENT_OBJECT_ID
								  FROM CSI_ITEM_INSTANCES CII,
									EAM_ASSET_FAILURE_CODES EAFC,
									EAM_ASSET_FAILURES EAF,
									WIP_DISCRETE_JOBS WDJ,
									MTL_SERIAL_NUMBERS MSN
								  WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
								  AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
								  AND	WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
								  AND	WDJ.STATUS_TYPE IN (4,5,12)
								  AND	EAF.SOURCE_TYPE = 1
								  AND	EAF.OBJECT_TYPE = 3
								  AND	EAF.OBJECT_ID = CII.INSTANCE_ID
								  AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
								  AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
								  AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
								  AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
								  AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
								  AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
								  AND (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
								  AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date)
								 )
							CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID)
			UNION
				SELECT MAINTENANCE_OBJECT_ID FROM (
					SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
					    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
					    NVL(WDJ.ASSET_NUMBER, WDJ.REBUILD_SERIAL_NUMBER) MAINTAINED_NUMBER,
  				            CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
					    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
					    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
					    WDJ.WIP_ENTITY_ID,
					    WE.WIP_ENTITY_NAME,
					    WDJ.ORGANIZATION_ID,
					    OOD.ORGANIZATION_CODE,
					    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
					    CII.CATEGORY_ID ASSET_CATEGORY_ID,
					    MEL.LOCATION_CODES ASSET_LOCATION,
					    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
					    EAFC.FAILURE_CODE,
					    EAFC.CAUSE_CODE,
					    EAFC.RESOLUTION_CODE,
					    EAF.FAILURE_DATE,
					    EAFC.COMMENTS,
					    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY CII.INVENTORY_ITEM_ID ORDER BY EAF.FAILURE_DATE  ),
					      --NULL, (EAF.FAILURE_DATE - CII.CREATION_DATE),
					      NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
									FROM  CSI_ITEM_INSTANCES CII1
									WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
									AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
					      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
								   ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
					    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
					    METER.METER_ID,
						  METER.METER_NAME METER_NAME,
						  METER.METER_UOM METER_UOM,
					    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
					     DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
						NULL, METER.CURRENT_READING,
						(METER.CURRENT_READING -
						  (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
					    'Y' INCLUDE_FOR_READING_AGGR,
					    'Y' INCLUDE_FOR_COST_AGGR
				      FROM  WIP_DISCRETE_JOBS WDJ,
					    WIP_ENTITIES WE,
					    MTL_CATEGORIES_KFV MCKFV,
					    MTL_SYSTEM_ITEMS_KFV MSIKFV,
					    MTL_EAM_LOCATIONS MEL,
					    BOM_DEPARTMENTS BD,
					    EAM_ASSET_FAILURE_CODES EAFC,
					    EAM_ASSET_FAILURES EAF,
					    CSI_ITEM_INSTANCES CII,
					    ORG_ORGANIZATION_DEFINITIONS OOD,
					    (SELECT EM.METER_ID,
						    EM.METER_NAME,
						    EM.METER_UOM,
						    EAM.MAINTENANCE_OBJECT_ID,
						    EMR.CURRENT_READING,
						    EMR.CURRENT_READING_DATE,
						    EAM.PRIMARY_FAILURE_METER,
						    EMR.WIP_ENTITY_ID,
						    EM.METER_TYPE
					    FROM  EAM_METERS EM,
							EAM_ASSET_METERS EAM,
							EAM_METER_READINGS EMR
					    WHERE EM.METER_ID = EAM.METER_ID
					    AND EMR.METER_ID = EAM.METER_ID
					    AND EM.REQUIRED_FLAG = 'Y'
					    AND EAM.PRIMARY_FAILURE_METER  = 'Y'
					    AND EMR.METER_READING_ID IN
						      (SELECT METER_READING_ID FROM
							       (SELECT Max(EMR1.METER_READING_ID) METER_READING_ID,EMR1.WIP_ENTITY_ID,EMR1.METER_ID
								FROM EAM_METER_READINGS EMR1
								GROUP BY EMR1.WIP_ENTITY_ID, EMR1.METER_ID )))    METER
				      WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
					    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
					    AND WDJ.ORGANIZATION_ID + 0 = OOD.ORGANIZATION_ID
					    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
						  AND WDJ.STATUS_TYPE IN (4,5,12)
					    AND	EAF.SOURCE_TYPE = 1
					    AND	EAF.OBJECT_TYPE = 3
					    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
					    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
					    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
					    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
					    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
					    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
					    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
					    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
					    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
					    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
					    AND EAF.OBJECT_ID IN ( SELECT EAF.OBJECT_ID OBJECT_ID    --This part will select all parent assets
								   FROM EAM_ASSET_FAILURE_CODES EAFC,
									EAM_ASSET_FAILURES EAF,
									WIP_DISCRETE_JOBS WDJ,
									CSI_ITEM_INSTANCES CII
								   WHERE	WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
								   AND	WDJ.STATUS_TYPE IN (4,5,12)
								   AND	EAF.SOURCE_TYPE = 1
								   AND	EAF.OBJECT_TYPE = 3
								   AND	EAF.OBJECT_ID = CII.INSTANCE_ID
								   AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
								   AND (l_gen_object_id IS NULL OR EAF.OBJECT_ID = l_gen_object_id)
								   AND (l_maint_group_id IS NULL OR CII.INVENTORY_ITEM_ID = l_maint_group_id)
								   AND (l_category_id  IS NULL OR  CII.CATEGORY_ID = l_category_id)
								   AND (p_failure_code IS NULL OR EAFC.FAILURE_CODE = p_failure_code)
								)
					    )
				WHERE (p_to_date IS NULL OR FAILURE_DATE <= p_to_date)
				AND (p_from_date IS NULL OR FAILURE_DATE >= p_from_date) );



BEGIN
          g_module_name := 'GET_CHILD_RECORDS_FA_SIMPLE';
         /* Should not rollback, since the data of the parent asset numbers has to be retained */
         --ROLLBACK;

          IF p_gen_object_id = 0 THEN
              l_gen_object_id := NULL;
          ELSE
              l_gen_object_id := p_gen_object_id;
          END IF;

          IF p_maint_group_id = 0 THEN
              l_maint_group_id := NULL;
          ELSE
              l_maint_group_id := p_maint_group_id;
          END IF;

          IF p_category_id = 0 THEN
              l_category_id := NULL;
          ELSE
              l_category_id := p_category_id;
          END IF;

          IF p_view_by IN (1,3,4) THEN
                l_validate_meters := 'N';
          ELSIF  p_view_by = 2 THEN
                l_validate_meters := 'Y';
          END IF;

          l_validate_currency  := p_compute_repair_costs;
          l_group_id := x_group_id;
          l_asset_failure_tbl.DELETE;
        IF ( p_failure_code IS NULL AND p_to_date IS NULL AND p_from_date IS NULL) then
          IF p_view_by = 1 /* 'ASSET_NUMBER' */ THEN
	    IF p_gen_object_id = 0 THEN
              OPEN c_meter_recs_an_simple;
			  IF ( l_group_id IS NULL OR l_group_id = 0) then
	              		  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                    END IF;
              LOOP
                  FETCH c_meter_recs_an_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
			                                        p_validate_meters     => l_validate_meters,
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);



	              		INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		               		               p_asset_failure_tbl  => l_asset_failure_tbl);

                      		IF p_compute_repair_costs = 'Y' THEN
	 	      	 		COMPUTE_REPAIR_COSTS(l_group_id);
	              		END if;
                    END IF;

                    EXIT WHEN c_meter_recs_an_simple%NOTFOUND;
              END LOOP;
              CLOSE c_meter_recs_an_simple;
	    ELSE
              OPEN c_meter_recs_an_simple_1;
			  IF ( l_group_id IS NULL OR l_group_id = 0) then
	              		  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                    END IF;
              LOOP
                  FETCH c_meter_recs_an_simple_1 BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
			                                        p_validate_meters     => l_validate_meters,
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);



	              		INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		               		               p_asset_failure_tbl  => l_asset_failure_tbl);

                      		IF p_compute_repair_costs = 'Y' THEN
	 	      	 		COMPUTE_REPAIR_COSTS(l_group_id);
	              		END if;
                    END IF;

                    EXIT WHEN c_meter_recs_an_simple_1%NOTFOUND;
              END LOOP;
              CLOSE c_meter_recs_an_simple_1;
	     END IF;
          ELSIF p_view_by = 2 /* 'ASSET_GROUP' */  THEN
	    IF p_gen_object_id = 0 THEN
              OPEN c_meter_recs_ag_simple;
			  IF ( l_group_id IS NULL OR l_group_id = 0) then
	              		  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                    END IF;
              LOOP
                  FETCH c_meter_recs_ag_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
			                                        p_validate_meters     => l_validate_meters,
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);



	              		INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		               		               p_asset_failure_tbl  => l_asset_failure_tbl);

                      		IF p_compute_repair_costs = 'Y' THEN
	 	      	 		COMPUTE_REPAIR_COSTS(l_group_id);
	              		END if;
                    END IF;

                    EXIT WHEN c_meter_recs_ag_simple%NOTFOUND;
              END LOOP;

              CLOSE c_meter_recs_ag_simple;
            ELSE
	      OPEN c_meter_recs_ag_simple_1;
		  IF ( l_group_id IS NULL OR l_group_id = 0) then
	              		  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                    END IF;
              LOOP
	        FETCH c_meter_recs_ag_simple_1 BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
			                                        p_validate_meters     => l_validate_meters,
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);



	              		INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		               		               p_asset_failure_tbl  => l_asset_failure_tbl);

                      		IF p_compute_repair_costs = 'Y' THEN
	 	      	 		COMPUTE_REPAIR_COSTS(l_group_id);
	              		END if;
                    END IF;

                    EXIT WHEN c_meter_recs_ag_simple_1%NOTFOUND;
              END LOOP;

              CLOSE c_meter_recs_ag_simple_1;
	    END IF;
          ELSIF p_view_by = 3 /* Asset Category */ THEN
	     IF p_gen_object_id = 0 THEN
              OPEN c_recs_ac_simple;
			  IF ( l_group_id IS NULL OR l_group_id = 0) then
                              SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                          END IF;
              LOOP
                  FETCH c_recs_ac_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS(   p_asset_failure_tbl   => l_asset_failure_tbl,
			                                        p_validate_meters     => 'N',
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);


	                        INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
				                                        p_asset_failure_tbl  => l_asset_failure_tbl);

                          IF p_compute_repair_costs = 'Y' THEN
	 	                          COMPUTE_REPAIR_COSTS(l_group_id);
	                        END if;
                    END IF;

                    EXIT WHEN c_recs_ac_simple%NOTFOUND;
              END LOOP;
              CLOSE c_recs_ac_simple;
            ELSE
	      OPEN c_recs_ac_simple_1;
		  IF ( l_group_id IS NULL OR l_group_id = 0) then
                              SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                          END IF;
              LOOP
                  FETCH c_recs_ac_simple_1 BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS(   p_asset_failure_tbl   => l_asset_failure_tbl,
			                                        p_validate_meters     => 'N',
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);


	                        INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
				                                        p_asset_failure_tbl  => l_asset_failure_tbl);

                          IF p_compute_repair_costs = 'Y' THEN
	 	                          COMPUTE_REPAIR_COSTS(l_group_id);
	                        END if;
                    END IF;

                    EXIT WHEN c_recs_ac_simple_1%NOTFOUND;
              END LOOP;
              CLOSE c_recs_ac_simple_1;
	     END IF;
          ELSIF p_view_by = 4 /* Failure Code */ THEN
	     IF p_gen_object_id = 0 THEN
              OPEN c_recs_fc_simple;
			  IF ( l_group_id IS NULL OR l_group_id = 0) then
                              SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                          END IF;
              LOOP
                  FETCH c_recs_fc_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS(   p_asset_failure_tbl   => l_asset_failure_tbl,
			                                        p_validate_meters     => 'N',
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);


	                        INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
				                                        p_asset_failure_tbl  => l_asset_failure_tbl);

                          IF p_compute_repair_costs = 'Y' THEN
	 	                          COMPUTE_REPAIR_COSTS(l_group_id);
	                        END if;
                    END IF;

                    EXIT WHEN c_recs_fc_simple%NOTFOUND;
              END LOOP;

              CLOSE c_recs_fc_simple;
	    ELSE
	      OPEN c_recs_fc_simple_1;
		  IF ( l_group_id IS NULL OR l_group_id = 0) then
                              SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                          END IF;
              LOOP
                  FETCH c_recs_fc_simple_1 BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS(   p_asset_failure_tbl   => l_asset_failure_tbl,
			                                        p_validate_meters     => 'N',
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);


	                        INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
				                                        p_asset_failure_tbl  => l_asset_failure_tbl);

                          IF p_compute_repair_costs = 'Y' THEN
	 	                          COMPUTE_REPAIR_COSTS(l_group_id);
	                        END if;
                    END IF;

                    EXIT WHEN c_recs_fc_simple_1%NOTFOUND;
              END LOOP;

              CLOSE c_recs_fc_simple_1;
	     END IF;
          END IF;   --p_view_by
---
        ELSE   /*( p_failure_code IS NOT NULL OR p_to_date IS NOT NULL OR p_from_date IS NOT NULL)*/
          IF p_view_by = 1 /* 'ASSET_NUMBER' */ THEN
              OPEN c_meter_recs_wo_an_simple;
			  IF ( l_group_id IS NULL OR l_group_id = 0) then
	              		  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                    END IF;
              LOOP
                  FETCH c_meter_recs_wo_an_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
			                                        p_validate_meters     => l_validate_meters,
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);



	              		INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		               		                     p_asset_failure_tbl  => l_asset_failure_tbl);

                      		IF p_compute_repair_costs = 'Y' THEN
	 	      	 		COMPUTE_REPAIR_COSTS(l_group_id);
	              		END if;
                    END IF;

                    EXIT WHEN c_meter_recs_wo_an_simple%NOTFOUND;
              END LOOP;
              CLOSE c_meter_recs_wo_an_simple;

          ELSIF p_view_by = 2 /* 'ASSET_GROUP' */  THEN
              OPEN c_meter_recs_ag_simple;
			  IF ( l_group_id IS NULL OR l_group_id = 0) then
	              		  SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                    END IF;
              LOOP
                  FETCH c_meter_recs_ag_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS( p_asset_failure_tbl  => l_asset_failure_tbl,
			                                        p_validate_meters     => l_validate_meters,
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);



	              		INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
		               		               p_asset_failure_tbl  => l_asset_failure_tbl);

                      		IF p_compute_repair_costs = 'Y' THEN
	 	      	 		COMPUTE_REPAIR_COSTS(l_group_id);
	              		END if;
                    END IF;

                    EXIT WHEN c_meter_recs_ag_simple%NOTFOUND;
              END LOOP;

              CLOSE c_meter_recs_ag_simple;

          ELSIF p_view_by = 3 /* Asset Category */ THEN
              OPEN c_recs_ac_simple;
			  IF ( l_group_id IS NULL OR l_group_id = 0) then
                              SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                          END IF;
              LOOP
                  FETCH c_recs_ac_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS(   p_asset_failure_tbl   => l_asset_failure_tbl,
			                                        p_validate_meters     => 'N',
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);


	                        INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
				                                        p_asset_failure_tbl  => l_asset_failure_tbl);

                          IF p_compute_repair_costs = 'Y' THEN
	 	                          COMPUTE_REPAIR_COSTS(l_group_id);
	                        END if;
                    END IF;

                    EXIT WHEN c_recs_ac_simple%NOTFOUND;
              END LOOP;
              CLOSE c_recs_ac_simple;

          ELSIF p_view_by = 4 /* Failure Code */ THEN
              OPEN c_recs_fc_simple;
			  IF ( l_group_id IS NULL OR l_group_id = 0) then
                              SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                          END IF;
              LOOP
                  FETCH c_recs_fc_simple BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
                      IF ( l_asset_failure_tbl.Count > 0 ) THEN
	                	      VALIDATE_RECORDS(   p_asset_failure_tbl   => l_asset_failure_tbl,
			                                        p_validate_meters     => 'N',
                                          		p_validate_currency   => l_validate_currency,
                                          		p_current_org_id      => p_current_org_id,
                                          		x_unmatched_uom_class => l_unmatched_uom_class,
                                          		x_unmatched_currency  => l_unmatched_currency);


	                        INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
				                                        p_asset_failure_tbl  => l_asset_failure_tbl);

                          IF p_compute_repair_costs = 'Y' THEN
	 	                          COMPUTE_REPAIR_COSTS(l_group_id);
	                        END if;
                    END IF;

                    EXIT WHEN c_recs_fc_simple%NOTFOUND;
              END LOOP;

              CLOSE c_recs_fc_simple;
          END IF;   --p_view_by

        END IF; /*( p_failure_code IS NULL AND p_to_date IS NULL AND p_from_date IS NULL)*/



        x_return_status := 'S';

        x_msg_data := l_msg_data;
        x_group_id := l_group_id;

        x_unmatched_uom_class := l_unmatched_uom_class;
        x_unmatched_currency  := l_unmatched_currency;
EXCEPTION
  WHEN OTHERS THEN
         x_return_status := 'E';
         x_msg_data := 'Error in '||g_module_name||':'||SQLERRM;
END GET_CHILD_RECORDS_FA_SIMPLE;

Procedure GET_CHILD_RECORDS_FA_ADV
( P_WHERE_CLAUSE                IN VARCHAR2,
  p_where_clause_1		IN VARCHAR2,
  P_FROM_DATE_CLAUSE            IN VARCHAR2,
  P_VIEW_BY                     IN VARCHAR2,
  P_COMPUTE_REPAIR_COSTS        IN VARCHAR2,
  P_CURRENT_ORG_ID              IN NUMBER,
  x_group_id                    IN  OUT NOCOPY NUMBER,
  x_return_status               OUT NOCOPY  VARCHAR2,
  x_msg_data                    OUT NOCOPY  VARCHAR2,
  x_unmatched_uom_class         OUT NOCOPY  VARCHAR2,
  x_unmatched_currency          OUT NOCOPY  VARCHAR2) IS

  c_ref_failures 		SYS_REFCURSOR;
  l_asset_failure_tbl 		eam_asset_failure_tbl_type;
  l_group_id 			NUMBER;
  l_current_org_id  		NUMBER;
  l_org2  			NUMBER;
  l_same_currency  		NUMBER;
  l_meter_uom1  		VARCHAR2(3);
  l_meter_uom2  		VARCHAR2(3);
  l_uom1_conv_rate  		NUMBER;
  l_uom2_conv_rate  		NUMBER;
  l_validate_meters  		VARCHAR2(1);
  l_validate_currency 		VARCHAR2(1);
  x_ref_failures  		SYS_REFCURSOR;
  l_unmatched_uom_class   	VARCHAR2(1) := 'N';
  l_unmatched_currency    	VARCHAR2(1) := 'N';


BEGIN

    g_module_name :=  'GET_CHILD_RECORDS_FA_ADV';


    /* Should not rollback, since the data of the parent asset numbers has to be retained */
   ROLLBACK;


    l_current_org_id := p_current_org_id;

    If p_View_By = 2 /* 'ASSET_GROUP' */ OR p_View_By = 1 /* 'ASSET_NUMBER' */ THEN
    	  GET_CHILD_METER_RECS_CURSOR(p_where_clause,p_where_clause_1, p_from_date_clause, p_view_by, p_current_org_id, x_ref_failures);
    Else
        GET_CHILD_RECS_CURSOR(p_where_clause, p_where_clause_1,p_from_date_clause, p_view_by, p_current_org_id,x_ref_failures);
    End if;

    IF p_view_by IN (1,3,4) THEN
        l_validate_meters := 'N';
    ELSIF  p_view_by = 2 THEN
        l_validate_meters := 'Y';
    END IF;

    l_group_id := x_group_id;
    l_validate_currency := p_compute_repair_costs;
    IF ( l_group_id IS NULL OR l_group_id = 0) then
    	                SELECT EAM_FAILURE_HISTORY_TEMP_S.NEXTVAL INTO l_group_id  FROM DUAL;
                  END IF;

    LOOP
          FETCH x_ref_failures BULK COLLECT INTO l_asset_failure_tbl LIMIT 500;
              IF ( l_asset_failure_tbl.Count > 0 ) THEN


                  VALIDATE_RECORDS( p_asset_failure_tbl     => l_asset_failure_tbl,
                                    p_validate_meters       => l_validate_meters,
                                    p_validate_currency     => l_validate_currency,
                                    p_current_org_id        => l_current_org_id,
                                    x_unmatched_uom_class   => l_unmatched_uom_class,
                                    x_unmatched_currency    => l_unmatched_currency);



	                INSERT_INTO_TEMP_TABLE(p_group_id           => l_group_id,
                                           p_asset_failure_tbl  => l_asset_failure_tbl);

                  IF p_compute_repair_costs = 'Y' THEN
	 	                  COMPUTE_REPAIR_COSTS(l_group_id);
	          END if;
              END IF;

          EXIT WHEN x_ref_failures%NOTFOUND;
    END LOOP;

    CLOSE x_ref_failures;

    x_group_id := l_group_id;
    x_return_status := 'S';
    x_unmatched_uom_class := l_unmatched_uom_class;
    x_unmatched_currency  := l_unmatched_currency;

EXCEPTION
  WHEN OTHERS THEN
    x_return_status := 'E';
    x_msg_data := 'Error in '||g_module_name||':'||SQLERRM;
END GET_CHILD_RECORDS_FA_ADV;

PROCEDURE GET_CHILD_RECS_CURSOR
    ( p_where_clause      IN VARCHAR2,
      p_where_clause_1	  IN VARCHAR2,
      p_from_date_clause  IN VARCHAR2,
      p_view_by           IN VARCHAR2,
      p_org_id		  IN VARCHAR2,
      x_ref_failures      OUT NOCOPY SYS_REFCURSOR) IS

    l_sql_stmt1 		VARCHAR2(8000);
    l_from_date_clause 		VARCHAR2(8000);
    l_where_clause 		VARCHAR2(8000);
    l_where_clause_1		VARCHAR2(8000);
    l_org_id			VARCHAR2(50);
    l_partition_by		VARCHAR2(50);
    l_first_tbf_calc_clause	VARCHAR2(500);
    l_sql_stmt2			VARCHAR2(8000);
    l_sql_stmt3			VARCHAR2(8000);
    l_sql_stmt4			VARCHAR2(8000);
    l_sql_stmt5			VARCHAR2(8000);



BEGIN

  g_module_name :=  'GET_CHILD_RECS_CURSOR';

  IF (p_where_clause <> 'NULL' AND p_where_clause IS NOT NULL) THEN
     l_where_clause := p_where_clause;
  ELSE
     l_where_clause := NULL;
  END IF;

  IF (p_where_clause_1 <> 'NULL' AND p_where_clause_1 IS NOT NULL) THEN
     l_where_clause_1 := p_where_clause_1;
  ELSE
     l_where_clause_1 := NULL;
  END IF;

  IF (p_from_date_clause <> 'NULL' AND p_from_date_clause IS NOT NULL) THEN
     l_from_date_clause := p_from_date_clause;
  ELSE
     l_from_date_clause := NULL;
  END IF;

  IF p_view_by = 3 THEN
    l_partition_by :=  'CII.CATEGORY_ID';
  ELSIF p_view_by = 4 THEN
    l_partition_by := 'EAFC.FAILURE_CODE';
  END IF;
  IF (p_org_id <> 'NULL' AND p_org_id IS NOT NULL) THEN
     l_org_id := p_org_id;
  ELSE
     l_org_id := NULL;
  END IF;

  l_sql_stmt1 :=
 'SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
  EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
  CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
  CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
  MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
  NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
  WDJ.WIP_ENTITY_ID,
  WE.WIP_ENTITY_NAME,
  WDJ.ORGANIZATION_ID,
  OOD.ORGANIZATION_CODE,
  MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
  CII.CATEGORY_ID ASSET_CATEGORY_ID,
  MEL.LOCATION_CODES ASSET_LOCATION,
  BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
  EAFC.FAILURE_CODE,
  EAFC.CAUSE_CODE,
  EAFC.RESOLUTION_CODE,
  EAF.FAILURE_DATE,
  EAFC.COMMENTS,
  DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY '||l_partition_by||' ORDER BY EAF.FAILURE_DATE  ),
    NULL, (EAF.FAILURE_DATE - (SELECT MIN(CII1.CREATION_DATE)
                               FROM  CSI_ITEM_INSTANCES CII1
                               WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                               AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID) ),
    (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                          ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
  (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
  NULL METER_ID,
	NULL METER_NAME,
	NULL METER_UOM,
  NULL READING_BETWEEN_FAILURES,
  '||'''Y'''||' INCLUDE_FOR_READING_AGGR,
  '||'''Y'''||' INCLUDE_FOR_COST_AGGR ';

  l_sql_stmt2      :=   ' FROM  WIP_DISCRETE_JOBS WDJ,
  WIP_ENTITIES WE,
  CSI_ITEM_INSTANCES CII,
  MTL_CATEGORIES_KFV MCKFV,
  MTL_SYSTEM_ITEMS_KFV MSIKFV,
  MTL_EAM_LOCATIONS MEL,
  BOM_DEPARTMENTS BD,
  EAM_ASSET_FAILURE_CODES EAFC,
  EAM_ASSET_FAILURES EAF,
  ORG_ORGANIZATION_DEFINITIONS OOD
WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
  AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
  AND WDJ.ORGANIZATION_ID = OOD.ORGANIZATION_ID
  AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	AND WDJ.STATUS_TYPE IN (4,5,12)
  AND	EAF.SOURCE_TYPE = 1
  AND	EAF.OBJECT_TYPE = 3
  AND	EAF.OBJECT_ID = CII.INSTANCE_ID
  AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
  AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
  AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
  AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
  AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
  AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
  AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
  AND EAF.OBJECT_ID IN';

   l_sql_stmt3  :=  '(SELECT CII.INSTANCE_ID
			    FROM CSI_ITEM_INSTANCES CII,
				 MTL_SERIAL_NUMBERS MSN
				 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
				 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
				 AND MSN.GEN_OBJECT_ID IN
					 ( SELECT OBJECT_ID
					   FROM MTL_OBJECT_GENEALOGY
					   START WITH PARENT_OBJECT_ID IN
					   (SELECT  GEN_OBJECT_ID    PARENT_OBJECT_ID FROM ';
		      --when it IS required to have a parent failure wo, in order to select the children assets.

l_sql_stmt4      :=                              '(SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                                                    CII.INSTANCE_ID MAINTENANCE_OBJECT_ID,
						    MSN.GEN_OBJECT_ID GEN_OBJECT_ID,
                                                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                                                    CII.INSTANCE_DESCRIPTION,
                                                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                                                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                                                    MEL.LOCATION_CODES ASSET_LOCATION,
                                                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                                                    EAFC.FAILURE_CODE,
                                                    EFC.DESCRIPTION FAILURE_DESC,
                                                    EAFC.CAUSE_CODE,
                                                    ECC.DESCRIPTION CAUSE_DESC,
                                                    EAFC.RESOLUTION_CODE,
                                                    ERC.DESCRIPTION RESOLUTION_DESC,
                                                    EAF.FAILURE_DATE,
                                                    EAFC.COMMENTS
                                                 FROM WIP_DISCRETE_JOBS WDJ,
                                                    CSI_ITEM_INSTANCES CII,
                                                    MTL_CATEGORIES_KFV MCKFV,
                                                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                                                    MTL_EAM_LOCATIONS MEL,
                                                    BOM_DEPARTMENTS BD,
                                                    EAM_ASSET_FAILURE_CODES EAFC,
                                                    EAM_ASSET_FAILURES EAF,
                                                    EAM_FAILURE_CODES EFC,
                                                    EAM_CAUSE_CODES ECC,
						    MTL_SERIAL_NUMBERS MSN,
                                                    EAM_RESOLUTION_CODES ERC
                                                  WHERE	WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                                                    AND	WDJ.STATUS_TYPE IN (4,5,12)
                                                    AND	EAF.SOURCE_TYPE = 1
                                                    AND	EAF.OBJECT_TYPE = 3
                                                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                                                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                                                    AND EAFC.FAILURE_CODE = EFC.FAILURE_CODE
                                                    AND EAFC.CAUSE_CODE = ECC.CAUSE_CODE
                                                    AND EAFC.RESOLUTION_CODE = ERC.RESOLUTION_CODE
                                                    AND (EFC.EFFECTIVE_END_DATE IS NULL OR EFC.EFFECTIVE_END_DATE >= SYSDATE)
                                                    AND (ECC.EFFECTIVE_END_DATE IS NULL OR ECC.EFFECTIVE_END_DATE >= SYSDATE)
                                                    AND (ERC.EFFECTIVE_END_DATE IS NULL OR ERC.EFFECTIVE_END_DATE >= SYSDATE)
                                                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                                                    AND	EAF.MAINT_ORGANIZATION_ID = WDJ.ORGANIZATION_ID
                                                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                    AND	MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                                                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                                                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                                                    AND	BD.DEPARTMENT_ID (+)= EAF.DEPARTMENT_ID
						    AND CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                    AND CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER )';

	    --when it's NOT required to have a parent failure wo, in order to select the children assets.
    l_sql_stmt5 :=                                ' (SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
						      MSN.GEN_OBJECT_ID GEN_OBJECT_ID,
						      CII.INSTANCE_ID MAINTENANCE_OBJECT_ID ,
						      CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
						      CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
						      MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
						      MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
						      MEL.LOCATION_CODES ASSET_LOCATION,
						      BD.DEPARTMENT_CODE OWNING_DEPARTMENT
						    FROM MTL_SERIAL_NUMBERS MSN,
						      MTL_CATEGORIES_KFV MCKFV,
						      MTL_SYSTEM_ITEMS_KFV MSIKFV,
						      MTL_EAM_LOCATIONS MEL,
						      BOM_DEPARTMENTS BD,
						      CSI_ITEM_INSTANCES CII,
						      (SELECT * FROM EAM_ORG_MAINT_DEFAULTS WHERE ORGANIZATION_ID= '||l_org_id|| ' ) EOMD1 ' ||
						    ' WHERE	CII.INVENTORY_ITEM_ID = MSIKFV.INVENTORY_ITEM_ID
						      AND	CII.LAST_VLD_ORGANIZATION_ID = MSIKFV.ORGANIZATION_ID
						      AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
						      AND	MEL.LOCATION_ID (+) = EOMD1.AREA_ID
						      AND	BD.DEPARTMENT_ID (+)= EOMD1.OWNING_DEPARTMENT_ID
						      AND	MSIKFV.EAM_ITEM_TYPE IN (1,3)
						      AND	CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
						      AND	CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
						      AND	EOMD1.OBJECT_ID(+) = CII.INSTANCE_ID
						      AND	EOMD1.OBJECT_TYPE(+) = 50)';



      IF (l_where_clause IS NULL) THEN  --parents need NOT have a failure work order, to get children selected
      OPEN x_ref_failures FOR
            l_sql_stmt1||' '||l_sql_stmt2||' '||l_sql_stmt3||' '||l_sql_stmt5||' '||l_where_clause_1||' '||l_from_date_clause||') CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID )'||
            ' UNION '||
            ' SELECT MAINTENANCE_OBJECT_ID FROM ( '||l_sql_stmt1||' '||l_sql_stmt2||' (SELECT  MAINTENANCE_OBJECT_ID    PARENT_OBJECT_ID FROM '||l_sql_stmt5||' '||l_where_clause_1||' )) '||l_from_date_clause ||' )';

      ELSIF (l_where_clause_1 IS NULL) THEN  --parents need TO have atleast one failure work order, to get children selected
      OPEN x_ref_failures FOR
            l_sql_stmt1||' '||l_sql_stmt2||' '||l_sql_stmt3||' '||l_sql_stmt4||' '||l_where_clause||' '||l_from_date_clause||') CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID )'||
            ' UNION '||
            ' SELECT MAINTENANCE_OBJECT_ID FROM ( '||l_sql_stmt1||' '||l_sql_stmt2||' (SELECT  MAINTENANCE_OBJECT_ID    PARENT_OBJECT_ID FROM '||l_sql_stmt4||' '||l_where_clause||' )) '||l_from_date_clause ||' )';

      END IF;

/*  OPEN x_ref_failures FOR l_sql_stmt||' '||l_sql_stmt2||' '||l_sql_stmt3||' '||l_where_clause||' '||l_from_date_clause||') CONNECT BY PRIOR OBJECT_ID = PARENT_OBJECT_ID )';*/

END GET_CHILD_RECS_CURSOR;

PROCEDURE GET_CHILD_METER_RECS_CURSOR
( P_WHERE_CLAUSE                IN  VARCHAR2,
  P_WHERE_CLAUSE_1		IN  VARCHAR2,
  P_FROM_DATE_CLAUSE            IN  VARCHAR2,
  P_VIEW_BY                     IN  VARCHAR2,
  P_ORG_ID			IN  VARCHAR2,

  X_REF_FAILURES                OUT NOCOPY SYS_REFCURSOR) IS

  l_sql_stmt1 			VARCHAR2(8000);
  l_where_clause_1		VARCHAR2(8000);
  l_from_date_clause 		VARCHAR2(8000);
  l_where_clause 		VARCHAR2(8000);
  l_final_where_clause		VARCHAR2(8000);
  l_org_id			VARCHAR2(50);
  l_partition_by		VARCHAR2(50);
  l_first_tbf_calc_clause	VARCHAR2(500);
  l_sql_stmt2    		VARCHAR2(8000);
  l_sql_stmt3    		VARCHAR2(8000);
  l_sql_stmt4    		VARCHAR2(8000);
  l_sql_stmt5    		VARCHAR2(8000);
  l_final_sql_stmt		VARCHAR2(8000);


BEGIN

  g_module_name :=  'GET_CHILD_METER_RECS_CURSOR';

  IF (p_where_clause <> 'NULL' AND p_where_clause IS NOT NULL) THEN
     l_where_clause := p_where_clause;
  ELSE
     l_where_clause := NULL;
  END IF;

  IF (p_where_clause_1 <> 'NULL' AND p_where_clause_1 IS NOT NULL) THEN
     l_where_clause_1 := p_where_clause_1;
  ELSE
     l_where_clause_1 := NULL;
  END IF;

  IF (p_from_date_clause <> 'NULL' AND p_from_date_clause IS NOT NULL) THEN
     l_from_date_clause := p_from_date_clause;
  ELSE
     l_from_date_clause := NULL;
  END IF;

  IF p_view_by = 1 THEN
    l_partition_by :=  'EAF.OBJECT_ID';
    l_first_tbf_calc_clause := 'CII.CREATION_DATE';
  ELSIF p_view_by = 2 THEN
    l_partition_by := 'CII.INVENTORY_ITEM_ID';
    l_first_tbf_calc_clause := '(SELECT MIN(CII1.CREATION_DATE)
                                 FROM  CSI_ITEM_INSTANCES CII1
                                 WHERE CII1.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                 AND   CII1.LAST_VLD_ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID)';
  END IF;

    IF (p_org_id <> 'NULL' AND p_org_id IS NOT NULL) THEN
     l_org_id := p_org_id;
  ELSE
     l_org_id := NULL;
  END IF;
  l_sql_stmt1 := 'SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                    CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                    NVL(WDJ.ASSET_GROUP_ID, WDJ.REBUILD_ITEM_ID) MAINTAINED_GROUP_ID ,
                    WDJ.WIP_ENTITY_ID,
                    WE.WIP_ENTITY_NAME,
                    WDJ.ORGANIZATION_ID,
                    OOD.ORGANIZATION_CODE,
                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                    CII.CATEGORY_ID ASSET_CATEGORY_ID,
                    MEL.LOCATION_CODES ASSET_LOCATION,
                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                    EAFC.FAILURE_CODE,
                    EAFC.CAUSE_CODE,
                    EAFC.RESOLUTION_CODE,
                    EAF.FAILURE_DATE,
                    EAFC.COMMENTS,
                    DECODE( LAG(EAF.FAILURE_DATE,1,NULL) OVER ( PARTITION BY '||l_partition_by||' ORDER BY EAF.FAILURE_DATE  ),
                      NULL, (EAF.FAILURE_DATE - '||l_first_tbf_calc_clause||'),
                      (EAF.FAILURE_DATE - ( LAG(EAF.FAILURE_DATE,1,NULL) OVER
                                           ( PARTITION BY EAF.OBJECT_ID ORDER BY EAF.FAILURE_DATE  )) )) DAYS_BETWEEN_FAILURES,
                    (WDJ.DATE_COMPLETED - EAF.FAILURE_DATE )*24  TIME_TO_REPAIR,
                    METER.METER_ID,
	                  METER.METER_NAME METER_NAME,
	                  METER.METER_UOM METER_UOM,
                    DECODE(METER.METER_TYPE,2,METER.CURRENT_READING,1,
                      DECODE( LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ),
                        NULL, METER.CURRENT_READING,
                        (METER.CURRENT_READING -
                          (LAG(METER.CURRENT_READING,1,NULL) OVER ( PARTITION BY EAF.OBJECT_ID, METER.METER_ID ORDER BY WDJ.DATE_COMPLETED ))) ))  READING_BETWEEN_FAILURES,
                    '||'''Y'''||' INCLUDE_FOR_READING_AGGR,
                    '||'''Y'''||' INCLUDE_FOR_COST_AGGR
              FROM  WIP_DISCRETE_JOBS WDJ,
                    WIP_ENTITIES WE,
                    CSI_ITEM_INSTANCES CII,
                    MTL_CATEGORIES_KFV MCKFV,
                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                    MTL_EAM_LOCATIONS MEL,
                    BOM_DEPARTMENTS BD,
                    EAM_ASSET_FAILURE_CODES EAFC,
                    EAM_ASSET_FAILURES EAF,
                    ORG_ORGANIZATION_DEFINITIONS OOD,
                    (SELECT
                            ccb.counter_id METER_ID,
                            cctl.name METER_NAME,
                            ccb.uom_code METER_UOM,
                            CCA.SOURCE_OBJECT_ID  MAINTENANCE_OBJECT_ID,
                            CCR.COUNTER_READING CURRENT_READING,
                            CCR.VALUE_TIMESTAMP CURRENT_READING_DATE,
                            CCA.PRIMARY_FAILURE_FLAG,
                            decode(ct.transaction_type_id,92,ct.source_header_ref_id,to_number(null)) WIP_ENTITY_ID,
                            CCB.reading_type METER_TYPE
                    FROM csi_counters_b CCB,csi_counters_tl cctl, csi_counter_readings CCR, csi_counter_associations CCA, csi_transactions CT ';
l_sql_stmt2 :=    'WHERE ccb.counter_id = cctl.counter_id
                        	and SYSDATE BETWEEN nvl(ccb.start_date_active, SYSDATE-1) AND nvl(ccb.end_date_active, SYSDATE+1)
                        	and cctl.language = userenv('|| '''LANG'''|| ') and ccb.counter_type = '||'''REGULAR'''||'
                        	AND	CCB.COUNTER_ID = CCA.COUNTER_ID
                        	AND CCR.COUNTER_ID(+) = CCB.COUNTER_ID
                        	AND CCR.transaction_id = CT.transaction_id(+)
                        	and SYSDATE BETWEEN nvl(cca.start_date_active, SYSDATE-1) AND nvl(cca.end_date_active, SYSDATE+1)
                            AND CCA.PRIMARY_FAILURE_FLAG = '||'''Y'''||'
                        	AND CCB.EAM_REQUIRED_FLAG = '||'''Y'''||'
                            AND CCR.COUNTER_VALUE_ID IN
                            (
                            SELECT
                                METER_READING_ID
                            FROM
                                (
                                SELECT
                                    Max(EMR1.METER_READING_ID) METER_READING_ID
                                FROM EAM_METER_READINGS_V EMR1
                                GROUP BY EMR1.WIP_ENTITY_ID,
                                    EMR1.METER_ID
                                )
                            ))    METER
                  WHERE WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                    AND WDJ.ORGANIZATION_ID = EAF.MAINT_ORGANIZATION_ID
                    AND WDJ.ORGANIZATION_ID = OOD.ORGANIZATION_ID
                    AND	WDJ.WIP_ENTITY_ID = WE.WIP_ENTITY_ID
	                  AND WDJ.STATUS_TYPE IN (4,5,12)
                    AND	EAF.SOURCE_TYPE = 1
                    AND	EAF.OBJECT_TYPE = 3
                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
		    AND MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                    AND	BD.DEPARTMENT_ID (+) = EAF.DEPARTMENT_ID
                    AND EAF.OBJECT_ID = METER.MAINTENANCE_OBJECT_ID  (+)
                    AND METER.WIP_ENTITY_ID (+) = EAF.SOURCE_ID
                    AND EAF.OBJECT_ID IN ';
l_sql_stmt3     :=                         '( SELECT CII.INSTANCE_ID
						FROM CSI_ITEM_INSTANCES CII,
                                                 MTL_SERIAL_NUMBERS MSN
                                                 WHERE CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                 AND   CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
                                                 AND MSN.gen_object_id IN
							       (SELECT OBJECT_ID
								FROM MTL_OBJECT_GENEALOGY
								START WITH PARENT_OBJECT_ID IN
									(SELECT  GEN_OBJECT_ID    PARENT_OBJECT_ID FROM';
--when it IS required to have a parent failure wo, in order to select the children assets.

 l_sql_stmt4 :=    '(SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
                                                    EAF.OBJECT_ID MAINTENANCE_OBJECT_ID,
						    MSN.GEN_OBJECT_ID GEN_OBJECT_ID,
                                                    CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
                                                    CII.INSTANCE_DESCRIPTION,
                                                    MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
                                                    MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
                                                    MEL.LOCATION_CODES ASSET_LOCATION,
                                                    BD.DEPARTMENT_CODE OWNING_DEPARTMENT,
                                                    EAFC.FAILURE_CODE,
                                                    EFC.DESCRIPTION FAILURE_DESC,
                                                    EAFC.CAUSE_CODE,
                                                    ECC.DESCRIPTION CAUSE_DESC,
						    EAFC.RESOLUTION_CODE,
                                                    ERC.DESCRIPTION RESOLUTION_DESC,
                                                    EAF.FAILURE_DATE,
                                                    EAFC.COMMENTS

                                                 FROM WIP_DISCRETE_JOBS WDJ,
                                                    CSI_ITEM_INSTANCES CII,
                                                    MTL_CATEGORIES_KFV MCKFV,
                                                    MTL_SYSTEM_ITEMS_KFV MSIKFV,
                                                    MTL_EAM_LOCATIONS MEL,
                                                    BOM_DEPARTMENTS BD,
                                                    EAM_ASSET_FAILURE_CODES EAFC,
                                                    EAM_ASSET_FAILURES EAF,
                                                    EAM_FAILURE_CODES EFC,
                                                    EAM_CAUSE_CODES ECC,
                                                    EAM_RESOLUTION_CODES ERC,
						    MTL_SERIAL_NUMBERS MSN

						 WHERE	WDJ.WIP_ENTITY_ID = EAF.SOURCE_ID
                                                    AND	WDJ.STATUS_TYPE IN (4,5,12)
                                                    AND	EAF.SOURCE_TYPE = 1
                                                    AND	EAF.OBJECT_TYPE = 3
                                                    AND	EAF.OBJECT_ID = CII.INSTANCE_ID
                                                    AND	EAF.FAILURE_ID = EAFC.FAILURE_ID
                                                    AND EAFC.FAILURE_CODE = EFC.FAILURE_CODE
                                                    AND EAFC.CAUSE_CODE = ECC.CAUSE_CODE
                                                    AND EAFC.RESOLUTION_CODE = ERC.RESOLUTION_CODE
                                                    AND (EFC.EFFECTIVE_END_DATE IS NULL OR EFC.EFFECTIVE_END_DATE >= SYSDATE)
                                                    AND (ECC.EFFECTIVE_END_DATE IS NULL OR ECC.EFFECTIVE_END_DATE >= SYSDATE)
                                                    AND (ERC.EFFECTIVE_END_DATE IS NULL OR ERC.EFFECTIVE_END_DATE >= SYSDATE)
                                                    AND	CII.INSTANCE_ID = DECODE(WDJ.MAINTENANCE_OBJECT_TYPE,3,WDJ.MAINTENANCE_OBJECT_ID,NULL)
                                                    AND	MSIKFV.INVENTORY_ITEM_ID = CII.INVENTORY_ITEM_ID
                                                    AND	MSIKFV.ORGANIZATION_ID = CII.LAST_VLD_ORGANIZATION_ID
                                                    AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
                                                    AND	MEL.LOCATION_ID (+) = EAF.AREA_ID
                                                    AND	BD.DEPARTMENT_ID (+)= EAF.DEPARTMENT_ID
						    AND CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
                                                    AND CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER )';

    --when it's NOT required to have a parent failure wo, in order to select the children assets.
    l_sql_stmt5 :=
    '(SELECT MSIKFV.EAM_ITEM_TYPE ASSET_TYPE,
      MSN.GEN_OBJECT_ID GEN_OBJECT_ID,
      CII.INSTANCE_ID MAINTENANCE_OBJECT_ID ,
      CII.INSTANCE_NUMBER MAINTAINED_NUMBER,
      CII.INSTANCE_DESCRIPTION AS DESCRIPTIVE_TEXT,
      MSIKFV.CONCATENATED_SEGMENTS MAINTAINED_GROUP,
      MCKFV.CONCATENATED_SEGMENTS ASSET_CATEGORY,
      MEL.LOCATION_CODES ASSET_LOCATION,
      BD.DEPARTMENT_CODE OWNING_DEPARTMENT
    FROM MTL_SERIAL_NUMBERS MSN,
      MTL_CATEGORIES_KFV MCKFV,
      MTL_SYSTEM_ITEMS_KFV MSIKFV,
      MTL_EAM_LOCATIONS MEL,
      BOM_DEPARTMENTS BD,
      CSI_ITEM_INSTANCES CII,
      (SELECT * FROM EAM_ORG_MAINT_DEFAULTS WHERE ORGANIZATION_ID= '||l_org_id|| ' ) EOMD1 ' ||
    ' WHERE	CII.INVENTORY_ITEM_ID = MSIKFV.INVENTORY_ITEM_ID
      AND	CII.LAST_VLD_ORGANIZATION_ID = MSIKFV.ORGANIZATION_ID
      AND	MCKFV.CATEGORY_ID (+) = CII.CATEGORY_ID
      AND	MEL.LOCATION_ID (+) = EOMD1.AREA_ID
      AND	BD.DEPARTMENT_ID (+)= EOMD1.OWNING_DEPARTMENT_ID
      AND	MSIKFV.EAM_ITEM_TYPE IN (1,3)
      AND	CII.INVENTORY_ITEM_ID = MSN.INVENTORY_ITEM_ID
      AND	CII.SERIAL_NUMBER = MSN.SERIAL_NUMBER
      AND	EOMD1.OBJECT_ID(+) = CII.INSTANCE_ID
      AND	EOMD1.OBJECT_TYPE(+) = 50)';


      IF (l_where_clause IS NULL) THEN  --parents need NOT have a failure work order, to get children selected
     OPEN x_ref_failures FOR
           l_sql_stmt1||' '||l_sql_stmt2||' '||l_sql_stmt3||' '||l_sql_stmt5||' '||l_where_clause_1||' '||l_from_date_clause||') CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID )'||
            ' UNION '||
            ' SELECT MAINTENANCE_OBJECT_ID FROM ( '||l_sql_stmt1||' '||l_sql_stmt2||' (SELECT  MAINTENANCE_OBJECT_ID    PARENT_OBJECT_ID FROM '||l_sql_stmt5||' '||l_where_clause_1||' )) '||l_from_date_clause||' )';

      ELSIF (l_where_clause_1 IS NULL) THEN  --parents need TO have atleast one failure work order, to get children selected
      OPEN x_ref_failures FOR

            l_sql_stmt1||' '||l_sql_stmt2||' '||l_sql_stmt3||' '||l_sql_stmt4||' '||l_where_clause||' '||l_from_date_clause||') CONNECT BY NOCYCLE PRIOR OBJECT_ID = PARENT_OBJECT_ID )'||
            ' UNION '||
            ' SELECT MAINTENANCE_OBJECT_ID FROM ( '||l_sql_stmt1||' '||l_sql_stmt2||' (SELECT  MAINTENANCE_OBJECT_ID    PARENT_OBJECT_ID FROM '||l_sql_stmt4||' '||l_where_clause||' )) '||l_from_date_clause||' )';

      END IF;

       --OPEN x_ref_failures FOR l_sql_stmt||' '||l_sql_stmt2||' '||l_sql_stmt3||' '||l_where_clause||' '||l_from_date_clause||') CONNECT BY PRIOR OBJECT_ID = PARENT_OBJECT_ID)';

END  GET_CHILD_METER_RECS_CURSOR;

END EAM_FAILURE_ANALYSIS_PVT;


/
