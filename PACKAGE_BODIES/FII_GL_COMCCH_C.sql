--------------------------------------------------------
--  DDL for Package Body FII_GL_COMCCH_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_COMCCH_C" AS
/* $Header: FIIGLH1B.pls 120.3 2006/02/21 22:07:30 juding noship $ */

        g_debug_flag Varchar2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

	g_retcode              	VARCHAR2(20) := NULL;
	g_fii_schema           	VARCHAR2(30);
	g_worker_num           	NUMBER;
	g_phase                	VARCHAR2(300);
        g_mode                  VARCHAR2(1) := NULL;
	g_fii_user_id          	NUMBER;
	g_fii_login_id		NUMBER;
        g_current_language      VARCHAR2(30);
 	G_TABLE_NOT_EXIST      	EXCEPTION;
 	PRAGMA EXCEPTION_INIT(G_TABLE_NOT_EXIST, -942);
  	G_LOGIN_INFO_NOT_AVABLE EXCEPTION;
	G_DUPLICATE_PROD_ASGN 	EXCEPTION;
	G_NO_PROD_SEG_DEFINED 	EXCEPTION;
        G_INVALID_PROD_CODE_EXIST EXCEPTION;
        G_UNASSIGNED_LOB_ID     NUMBER(15);
        G_AGGREGATION_LEVELS    NUMBER(15) := NVL(fnd_profile.value('FII_MGR_LEVEL'), 999);
        G_DBI50_FOR_LOB         BOOLEAN := FALSE;

-- ---------------------------------------------------------------
-- Private procedures and Functions
-- ---------------------------------------------------------------

-----------------------------------------------------------------
-- PROCEDURE PRINT_DUP_ORG_IN_TEMP
--
-- It will print out all (company, cost_center) with multiple orgs
-- in table FII_COM_CC_MAPPINGS_GT, it's called as EXCEPTION happens.
-- This will help detect a data issue in bug 3122222
-----------------------------------------------------------------
PROCEDURE PRINT_DUP_ORG_IN_TEMP IS

  l_count   NUMBER(15) :=0;

  Cursor c_duplicate_org is
         select  count(*) cnt,
                 company_id,
                 cost_center_id
           from  FII_COM_CC_MAPPINGS_GT
          where  company_cost_center_org_id <> -1
       group by  company_id, cost_center_id
         having  count(*) > 1;

  Cursor c_list_dup_org (p_com_id number, p_cc_id number) is
        select com.flex_value company,
               cc.flex_value  cost_center,
               org.name       organization,
               org.organization_id  org_id
         from FII_COM_CC_MAPPINGS_GT    gt,
              hr_all_organization_units org,
              fnd_flex_values           com,
              fnd_flex_values           cc
        where gt.company_id     = p_com_id
          and gt.cost_center_id = p_cc_id
          and gt.company_cost_center_org_id = org.organization_id
          and gt.company_id     = com.flex_value_id
          and gt.cost_center_id = cc.flex_value_id;

BEGIN

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.PRINT_DUP_ORG_IN_TEMP');
     END IF;

   --The information is written to the log file only for debug purpose
   --called from an EXCEPTION section

   l_count := 0;
   FOR r_dup_org IN c_duplicate_org LOOP
     if l_count = 0 then
       fii_util.write_log('Printing out company cost_center with multiple orgs in table FII_COM_CC_MAPPINGS_GT');
       fii_util.write_log('');
       fii_util.write_log ('- Company (ID) --- Cost Center (ID) --- Organization (ID) -');
     end if;

     l_count := l_count + 1;
     FOR r_list_org IN c_list_dup_org (r_dup_org.company_id, r_dup_org.cost_center_id) LOOP
       fii_util.write_log (r_list_org.company     || ' (' || r_dup_org.company_id || ')     ' ||
                           r_list_org.cost_center || ' (' || r_dup_org.cost_center_id || ')     ' ||
                           r_list_org.organization|| ' (' || r_list_org.org_id || ')');
     END LOOP;
   END LOOP;

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.PRINT_DUP_ORG_IN_TEMP');
     END IF;

 EXCEPTION
    WHEN OTHERS THEN
      g_retcode := -1;
      fii_util.write_log('
-----------------------------
Error occured in Procedure: PRINT_DUP_ORG_IN_TEMP
Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.PRINT_DUP_ORG_IN_TEMP');
      raise;

END PRINT_DUP_ORG_IN_TEMP;


-----------------------------------------------------------------
-- PROCEDURE PRINT_DUP_MGR_IN_TEMP
--
-- It will print out all Person IDs with multiple managers at
-- the level G_AGGREGATION_LEVELS in table FII_CC_MGR_HIER_GT,
-- it's called as EXCEPTION happens.
-- This will help detect a data issue in HRI_CS_SUPH
-----------------------------------------------------------------
PROCEDURE PRINT_DUP_MGR_IN_TEMP IS

  l_count   NUMBER(15) :=0;

  Cursor c_duplicate_mgr is
        select emp_id, count(*)
          from FII_CC_MGR_HIER_GT
         where mgr_level = G_AGGREGATION_LEVELS
         group by emp_id
        having count(*) > 1;

  Cursor c_list_dup_mgr (p_emp_id number) is
        select mgr_id, emp_level
          from FII_CC_MGR_HIER_GT
         where mgr_level = G_AGGREGATION_LEVELS
           and emp_id    = p_emp_id;

BEGIN

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.PRINT_DUP_MGR_IN_TEMP');
     END IF;

   --The information is written to the log file only for debug purpose
   --called from an EXCEPTION section

   l_count := 0;
   FOR r_dup_mgr IN c_duplicate_mgr LOOP
     if l_count = 0 then
       fii_util.write_log('Printing out employee with multiple managers in table FII_CC_MGR_HIER_GT at level ' || G_AGGREGATION_LEVELS);
       fii_util.write_log('');
       fii_util.write_log ('- Employee ID --- Manager ID --- Employee Level -');
     end if;

     l_count := l_count + 1;
     FOR r_list_mgr IN c_list_dup_mgr (r_dup_mgr.emp_id) LOOP
       fii_util.write_log (r_dup_mgr.emp_id     || '            ' ||
                           r_list_mgr.mgr_id    || '            ' ||
                           r_list_mgr.emp_level);
     END LOOP;
   END LOOP;

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.PRINT_DUP_MGR_IN_TEMP');
     END IF;

 EXCEPTION
    WHEN OTHERS THEN
      g_retcode := -1;
      fii_util.write_log('
-----------------------------
Error occured in Procedure: PRINT_DUP_MGR_IN_TEMP
Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.PRINT_DUP_MGR_IN_TEMP');
      raise;

END PRINT_DUP_MGR_IN_TEMP;


-- ---------------------------------------------------------------
-- PROCEDURE INITIAL_LOAD
-- ---------------------------------------------------------------
PROCEDURE INITIAL_LOAD  is

BEGIN

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.INITIAL_LOAD');
     END IF;

   g_phase := 'Insert into FII_COM_CC_MAPPINGS by INITIAL_LOAD';

     INSERT /*+ append*/ INTO  FII_COM_CC_MAPPINGS
         (COMPANY_COST_CENTER_ORG_ID  ,
	  COST_CENTER_ID ,
	  COMPANY_ID ,
	  MANAGER_ID ,
          VALID_MGR_FLAG,
	  LOB_ID,
          PARENT_MANAGER_ID,
          PARENT_LOB_ID,
	  CREATION_DATE ,
	  CREATED_BY ,
	  LAST_UPDATE_DATE ,
	  LAST_UPDATED_BY ,
          LAST_UPDATE_LOGIN)
     SELECT DISTINCT
      dim.COMPANY_COST_CENTER_ORG_ID,
      dim.COST_CENTER_ID,
      dim.COMPANY_ID,
      nvl(ct.manager, -1),
      decode(ct.manager, NULL, 'N', 'Y'),
      G_UNASSIGNED_LOB_ID,
      nvl(ct.manager, -1),
      G_UNASSIGNED_LOB_ID,
      sysdate,
      g_fii_user_id,
      sysdate,
      g_fii_user_id,
      g_fii_login_id
     FROM FII_COM_CC_MAPPINGS_GT     dim,
          fii_ccc_mgr_gt             ct
     WHERE company_cost_center_org_id <> -1
       and dim.company_cost_center_org_id  = ct.CCC_ORG_ID (+);

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_COM_CC_MAPPINGS');
     END IF;

      COMMIT;

    --------------------------------------------------------
    -- Gather statistics for the use of cost-based optimizer
    --------------------------------------------------------
    --Will seed this in RSG
    --    FND_STATS.gather_table_stats
    --    (ownname        => g_fii_schema,
    --     tabname        => 'FII_COM_CC_MAPPINGS');

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.INITIAL_LOAD');
     END IF;

EXCEPTION
      WHEN OTHERS THEN
       FII_UTIL.TRUNCATE_TABLE('FII_COM_CC_MAPPINGS' , g_fii_schema, g_retcode);
       g_retcode := '-1';

       fii_util.write_log('
---------------------------------
Error in Procedure: INITIAL_LOAD
Message: '||sqlerrm);
       fii_util.write_log(g_phase);

       PRINT_DUP_ORG_IN_TEMP;

       FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.INITIAL_LOAD');

       RAISE;

END INITIAL_LOAD;

-- ---------------------------------------------------------------
-- PROCEDURE INCREMENTAL_LOAD
-- ---------------------------------------------------------------
PROCEDURE INCREMENTAL_LOAD  is

BEGIN

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.INCREMENTAL_LOAD');
     END IF;

   g_phase := 'Insert into FII_COM_CC_MAPPINGS1_GT by INCREMENTAL_LOAD';

     INSERT /*+ append*/ INTO  FII_COM_CC_MAPPINGS1_GT
       (  COMPANY_COST_CENTER_ORG_ID  ,
	  COST_CENTER_ID ,
	  COMPANY_ID ,
	  MANAGER_ID ,
          VALID_MGR_FLAG,
	  LOB_ID,
          PARENT_MANAGER_ID,
          PARENT_LOB_ID)
     SELECT DISTINCT
      dim.COMPANY_COST_CENTER_ORG_ID,
      dim.COST_CENTER_ID,
      dim.COMPANY_ID,
      nvl(ct.manager, -1),
      decode(ct.manager, NULL, 'N', 'Y'),
      G_UNASSIGNED_LOB_ID,
      nvl(ct.manager, -1),
      G_UNASSIGNED_LOB_ID
     FROM FII_COM_CC_MAPPINGS_GT   dim,
          fii_ccc_mgr_gt           ct
     WHERE dim.company_cost_center_org_id <> -1
       and dim.company_cost_center_org_id  = ct.CCC_ORG_ID (+);

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_COM_CC_MAPPINGS1_GT');
     END IF;

      COMMIT;

      --G_UNASSIGNED_LOB_ID here is the id of the unassigned LOB

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.INCREMENTAL_LOAD');
     END IF;

  EXCEPTION
      WHEN OTHERS THEN
       g_retcode := '-1';

       fii_util.write_log('
---------------------------------
Error in Procedure: INCREMENTAL_LOAD
Message: '||sqlerrm);
       fii_util.write_log(g_phase);

       PRINT_DUP_ORG_IN_TEMP;

       FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.INCREMENTAL_LOAD');

       RAISE;

END INCREMENTAL_LOAD;

-- ---------------------------------------------------------------
-- PROCEDURE INITIAL_LOAD_LOB
-- ---------------------------------------------------------------

PROCEDURE INITIAL_LOAD_LOB  is

BEGIN

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.INITIAL_LOAD_LOB');
     END IF;

    g_phase := 'Update LOB by INITIAL_LOAD_LOB';


    if G_DBI50_FOR_LOB then

       If g_debug_flag = 'Y' then
           fii_util.write_log('Update LOB_ID for DBI50');
       End if;

    --Update LOB if using old lob assignment (DEBUG: we use NVL ?)
    UPDATE FII_COM_CC_MAPPINGS dim
     SET dim.LOB_ID = NVL(
      (SELECT NVL(x.c, -1)
       FROM
        (SELECT  lob.LINE_OF_BUSINESS           a,
                 lob.COMPANY_COST_CENTER_ORG_ID b,
                 flex.FLEX_VALUE_ID             c
         FROM (SELECT findim.MASTER_VALUE_SET_ID  FLEX_VALUE_SET_ID
                 FROM FII_FINANCIAL_DIMENSIONS findim
                WHERE DIMENSION_SHORT_NAME = 'FII_LOB') vset,
              fii_lob_assignments   lob,
              fnd_flex_values       flex
         WHERE flex.FLEX_VALUE_SET_ID = vset.FLEX_VALUE_SET_ID
         AND   flex.flex_value = lob.LINE_OF_BUSINESS) x
       WHERE dim.COMPANY_COST_CENTER_ORG_ID <> -1
       AND  x.b = dim.COMPANY_COST_CENTER_ORG_ID), dim.LOB_ID)
     WHERE dim.lob_id  = G_UNASSIGNED_LOB_ID ;

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_COM_CC_MAPPINGS');
     END IF;

    else

       If g_debug_flag = 'Y' then
           fii_util.write_log('Update LOB_ID for DBI60 and above');
       End if;

    --Update LOB if using new lob assignment (DEBUG: we use NVL ?)
      --Bug 3243824: use        in ('GL_BALANCING', 'FA_COST_CTR')
      --             to replace <> 'GL_GLOBAL'

      --Bug 3407938: the lob_id should be in LOB dimension full hierarchy

    UPDATE FII_COM_CC_MAPPINGS dim
     SET dim.LOB_ID = NVL(
      (SELECT decode (lob.b, 'GL_BALANCING', dim.company_id, dim.cost_center_id)
       FROM   FII_COM_CC_MAPPINGS_GT dim1,
        (select map.chart_of_accounts_id    a,
                fsav.segment_attribute_type b
           from FND_SEGMENT_ATTRIBUTE_VALUES fsav,
                fii_dim_mapping_rules        map
          where fsav.application_id = 101
            and fsav.id_flex_code = 'GL#'
            and map.dimension_short_name = 'FII_LOB'
            and map.chart_of_accounts_id = fsav.id_flex_num
            and map.application_column_name1 = fsav.application_column_name
            and fsav.attribute_value = 'Y'
            and fsav.segment_attribute_type in ('GL_BALANCING', 'FA_COST_CTR')) lob
       WHERE  lob.a = dim1.COA_ID
       AND    dim.COMPANY_COST_CENTER_ORG_ID = dim1.COMPANY_COST_CENTER_ORG_ID
       AND    decode (lob.b, 'GL_BALANCING', dim.company_id, dim.cost_center_id) IN
                        (select flob.child_lob_id
                           from fii_full_lob_hiers flob
                          where flob.parent_lob_id = flob.child_lob_id)
      ), dim.LOB_ID)
     WHERE dim.lob_id  = G_UNASSIGNED_LOB_ID ;

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_COM_CC_MAPPINGS');
     END IF;

    end if;

    g_phase := 'Update parent_manager_id by INITIAL_LOAD_LOB';

    -- Update parent_manager_id
     Update FII_COM_CC_MAPPINGS dim
        Set dim.parent_manager_id =
          NVL((select mgr.mgr_id
                 from FII_CC_MGR_HIER_GT mgr
                where mgr.mgr_level = G_AGGREGATION_LEVELS
                  and mgr.emp_id    = dim.manager_id), dim.manager_id);

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_COM_CC_MAPPINGS');
     END IF;

    g_phase := 'Update parent_lob_id by INITIAL_LOAD_LOB';

    -- Update parent_lob_id, we pick the parent with max level
    -- (the nearest parent in pruned hierarchy)
     Update FII_COM_CC_MAPPINGS dim
        Set dim.parent_lob_id =
          NVL((select  v.parent_lob_id
                 from  (select flob.parent_lob_id, flob.child_lob_id, lob.child_level
                          from fii_full_lob_hiers  flob,
                               fii_lob_hierarchies lob
                         where lob.child_lob_id  = flob.parent_lob_id
                         order by lob.child_level DESC) v
                where v.child_lob_id = dim.lob_id
                  and rownum = 1), dim.lob_id);

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_COM_CC_MAPPINGS');
     END IF;

      COMMIT;

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.INITIAL_LOAD_LOB');
     END IF;

EXCEPTION
      WHEN OTHERS THEN
       FII_UTIL.TRUNCATE_TABLE('FII_COM_CC_MAPPINGS' , g_fii_schema, g_retcode);
       g_retcode := '-1';

       fii_util.write_log('
---------------------------------
Error in Procedure: INITIAL_LOAD_LOB
Message: '||sqlerrm);
       fii_util.write_log(g_phase);

       PRINT_DUP_MGR_IN_TEMP;

       FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.INITIAL_LOAD_LOB');

       RAISE;

END INITIAL_LOAD_LOB;


-- ---------------------------------------------------------------
-- PROCEDURE INCREMENTAL_LOAD_LOB_MERGE
-- ---------------------------------------------------------------

PROCEDURE INCREMENTAL_LOAD_LOB_MERGE  is

BEGIN

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.INCREMENTAL_LOAD_LOB_MERGE');
     END IF;

    g_phase := 'Update LOB by INCREMENTAL_LOAD_LOB_MERGE';

    if G_DBI50_FOR_LOB then
    --Update LOB if using old lob assignment (DEBUG: we use NVL ?)

       If g_debug_flag = 'Y' then
           fii_util.write_log('Update LOB_ID for DBI50');
       End if;

    UPDATE FII_COM_CC_MAPPINGS1_GT dim
     SET dim.LOB_ID = NVL(
      (SELECT NVL(x.c ,-1 )
       FROM
        (select  lob.LINE_OF_BUSINESS           a ,
                 lob.COMPANY_COST_CENTER_ORG_ID b ,
                 flex.FLEX_VALUE_ID             c
         from  (SELECT findim.MASTER_VALUE_SET_ID  FLEX_VALUE_SET_ID
                  FROM FII_FINANCIAL_DIMENSIONS findim
                 WHERE DIMENSION_SHORT_NAME = 'FII_LOB') vset ,
               fii_lob_assignments lob ,
               fnd_flex_values flex
         where   flex.FLEX_VALUE_SET_ID = vset.FLEX_VALUE_SET_ID
           and   flex.flex_value = lob.LINE_OF_BUSINESS) x
       WHERE dim.COMPANY_COST_CENTER_ORG_ID <> -1
       AND  x.b = dim.COMPANY_COST_CENTER_ORG_ID), dim.LOB_ID)
     WHERE dim.lob_id  = G_UNASSIGNED_LOB_ID ;

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_COM_CC_MAPPINGS1_GT');
     END IF;

    else

    --Update LOB if using new lob assignment  (DEBUG: we use NVL ?)
      --Bug 3243824: use        in ('GL_BALANCING', 'FA_COST_CTR')
      --             to replace <> 'GL_GLOBAL'

      --Bug 3407938: the lob_id should be in LOB dimension full hierarchy

       If g_debug_flag = 'Y' then
           fii_util.write_log('Update LOB_ID for DBI60 and above');
       End if;

     UPDATE FII_COM_CC_MAPPINGS1_GT dim
     SET dim.LOB_ID = NVL(
      (select decode (lob.b, 'GL_BALANCING', dim.company_id, dim.cost_center_id)
       from  FII_COM_CC_MAPPINGS_GT dim1,
            (select map.chart_of_accounts_id    a,
                    fsav.segment_attribute_type b
               from FND_SEGMENT_ATTRIBUTE_VALUES fsav,
                    fii_dim_mapping_rules map
              where fsav.application_id = 101
                and fsav.id_flex_code   = 'GL#'
                and map.dimension_short_name = 'FII_LOB'
                and map.chart_of_accounts_id = fsav.id_flex_num
                and map.application_column_name1 = fsav.application_column_name
                and fsav.attribute_value = 'Y'
                and fsav.segment_attribute_type in ('GL_BALANCING', 'FA_COST_CTR')) lob
       where lob.a = dim1.COA_ID
         and dim.COMPANY_COST_CENTER_ORG_ID = dim1.COMPANY_COST_CENTER_ORG_ID
         and decode (lob.b, 'GL_BALANCING', dim.company_id, dim.cost_center_id) IN
                       (select flob.child_lob_id
                          from fii_full_lob_hiers flob
                         where flob.parent_lob_id = flob.child_lob_id)
      ), dim.LOB_ID)
     WHERE dim.lob_id  = G_UNASSIGNED_LOB_ID ;

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_COM_CC_MAPPINGS1_GT');
     END IF;

    end if;

    g_phase := 'Update parent_manager_id by INCREMENTAL_LOAD_LOB_MERGE';

     -- Update parent_manager_id
      Update FII_COM_CC_MAPPINGS1_GT dim
         Set dim.parent_manager_id =
           NVL((select mgr.mgr_id
                  from FII_CC_MGR_HIER_GT mgr
                 where mgr.mgr_level = G_AGGREGATION_LEVELS
                   and mgr.emp_id    = dim.manager_id), dim.manager_id);

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_COM_CC_MAPPINGS1_GT');
     END IF;

    g_phase := 'Update parent_lob_id by INCREMENTAL_LOAD_LOB_MERGE';

     -- Update parent_lob_id, we pick the parent with max level
     -- (the nearest parent in pruned hierarchy)
      Update FII_COM_CC_MAPPINGS1_GT dim
        Set dim.parent_lob_id =
          NVL((select  v.parent_lob_id
                 from  (select flob.parent_lob_id, flob.child_lob_id, lob.child_level
                          from fii_full_lob_hiers  flob,
                               fii_lob_hierarchies lob
                         where lob.child_lob_id  = flob.parent_lob_id
                         order by lob.child_level DESC) v
                where v.child_lob_id = dim.lob_id
                  and rownum = 1), dim.lob_id);

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_COM_CC_MAPPINGS1_GT');
     END IF;

      --Incrementally populate fii_com_cc_mappings for both new and old lob assignments

    g_phase := 'MERGE into fii_com_cc_mappings by INCREMENTAL_LOAD_LOB_MERGE';

      MERGE into fii_com_cc_mappings mapp using
      (select COMPANY_COST_CENTER_ORG_ID  ,
	  COST_CENTER_ID ,
	  COMPANY_ID ,
	  MANAGER_ID ,
          VALID_MGR_FLAG ,
	  LOB_ID,
          PARENT_MANAGER_ID,
          PARENT_LOB_ID
       from FII_COM_CC_MAPPINGS1_GT
       minus
       select COMPANY_COST_CENTER_ORG_ID  ,
	  COST_CENTER_ID ,
	  COMPANY_ID ,
	  MANAGER_ID ,
          VALID_MGR_FLAG ,
	  LOB_ID,
          PARENT_MANAGER_ID,
          PARENT_LOB_ID
       from  FII_COM_CC_MAPPINGS
      )  mappt
       ON
      ( -- mapp.COST_CENTER_ID = mappt.COST_CENTER_ID and
        -- mapp.company_id = mappt.company_id
        mapp.COMPANY_COST_CENTER_ORG_ID = mappt.COMPANY_COST_CENTER_ORG_ID
      )
       when matched then
     update set
          -- mapp.COMPANY_COST_CENTER_ORG_ID = mappt.COMPANY_COST_CENTER_ORG_ID,
          mapp.COST_CENTER_ID = mappt.COST_CENTER_ID,
          mapp.company_id = mappt.company_id,
          mapp.MANAGER_ID     = mappt.MANAGER_ID ,
          mapp.VALID_MGR_FLAG = mappt.VALID_MGR_FLAG ,
	  mapp.LOB_ID         = mappt.LOB_ID,
          mapp.PARENT_MANAGER_ID = mappt.PARENT_MANAGER_ID,
          mapp.PARENT_LOB_ID     = mappt.PARENT_LOB_ID,
          mapp.LAST_UPDATE_DATE  = sysdate,
          mapp.LAST_UPDATED_BY   = g_fii_user_id,
          mapp.LAST_UPDATE_LOGIN = g_fii_login_id
      when not matched then
      insert (
          mapp.COMPANY_COST_CENTER_ORG_ID  ,
	  mapp.COST_CENTER_ID ,
	  mapp.COMPANY_ID ,
	  mapp.MANAGER_ID ,
          mapp.VALID_MGR_FLAG ,
	  mapp.LOB_ID,
          mapp.PARENT_MANAGER_ID,
          mapp.PARENT_LOB_ID,
	  mapp.CREATION_DATE ,
	  mapp.CREATED_BY ,
	  mapp.LAST_UPDATE_DATE ,
	  mapp.LAST_UPDATED_BY ,
          mapp.LAST_UPDATE_LOGIN)
      values
       (
          mappt.COMPANY_COST_CENTER_ORG_ID  ,
	  mappt.COST_CENTER_ID ,
	  mappt.COMPANY_ID ,
	  mappt.MANAGER_ID ,
          mappt.VALID_MGR_FLAG ,
	  mappt.LOB_ID,
          mappt.PARENT_MANAGER_ID,
          mappt.PARENT_LOB_ID,
      sysdate,
      g_fii_user_id,
      sysdate,
      g_fii_user_id,
      g_fii_login_id);

     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Merged ' || SQL%ROWCOUNT || ' rows into fii_com_cc_mappings');
     END IF;

      commit;

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.INCREMENTAL_LOAD_LOB_MERGE');
     END IF;

EXCEPTION
      WHEN OTHERS THEN
       rollback;
       g_retcode := -1;

       fii_util.write_log('
---------------------------------
Error in Procedure: INCREMENTAL_LOAD_LOB_MERGE
Message: '||sqlerrm);
       fii_util.write_log(g_phase);

       PRINT_DUP_ORG_IN_TEMP;

       PRINT_DUP_MGR_IN_TEMP;

       FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.INCREMENTAL_LOAD_LOB_MERGE');

       RAISE;

END INCREMENTAL_LOAD_LOB_MERGE;

--------------------------------------------------------
-- PROCEDURE INITIALIZE
--------------------------------------------------------
PROCEDURE INITIALIZE is
     l_status	    VARCHAR2(30);
     l_industry	    VARCHAR2(30);
     l_stmt         VARCHAR2(50);
     l_dir          VARCHAR2(400);
     l_vset_id      NUMBER(15);
     l_flag         NUMBER(15) := 0;
BEGIN

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.INITIALIZE');
     END IF;

   ----------------------------------------------
   -- Do set up for log file
   ----------------------------------------------
   g_phase := 'Set up for log file';

   l_dir := fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY');
   ------------------------------------------------------
   -- Set default directory in case if the profile option
   -- BIS_DEBUG_LOG_DIRECTORY is not set up
   ------------------------------------------------------
   if l_dir is NULL then
     l_dir := FII_UTIL.get_utl_file_dir;
   end if;

   ----------------------------------------------------------------
   -- FII_UTIL.initialize will get profile options FII_DEBUG_pmode
   -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
   -- the log files and output files are written to
   ----------------------------------------------------------------
   FII_UTIL.initialize('FII_GL_COMCCH_C.log','FII_GL_COMCCH_C.out',l_dir, 'FII_GL_COMCCH_C');

   -- --------------------------------------------------------
   -- Find out the user ID ,login ID, and current language
   -- --------------------------------------------------------
   g_phase := 'Find User ID ,Login ID, and Current Language';

	g_fii_user_id := FND_GLOBAL.User_Id;
	g_fii_login_id := FND_GLOBAL.Login_Id;
        g_current_language := FND_GLOBAL.current_language;

	IF (g_fii_user_id IS NULL OR g_fii_login_id IS NULL) THEN
		RAISE G_LOGIN_INFO_NOT_AVABLE;
	END IF;
   -- --------------------------------------------------------
   -- Find the schema owner
   -- --------------------------------------------------------
   g_phase := 'Find schema owner for FII';

   g_fii_schema := FII_UTIL.get_schema_name ('FII');


   -- --------------------------------------------------------
   -- Find the unassigned LOB ID
   -- --------------------------------------------------------

   g_phase := 'Find the shipped FII value set id';

   select FLEX_VALUE_SET_ID into l_vset_id
   from fnd_flex_value_sets
   where flex_value_set_name = 'Financials Intelligence Internal Value Set';

   g_phase := 'Find the unassigned LOB ID from this value set: ' || l_vset_id;

   select flex_value_id  into G_UNASSIGNED_LOB_ID
   from fnd_flex_values
   where flex_value_set_id = l_vset_id
     and flex_value = 'UNASSIGNED';


   -- Check if we should use old DBI 5.0 LOB model

   g_phase := 'Check if we should use old DBI 5.0 LOB model';

   begin
       SELECT 1 INTO l_flag
       FROM fii_lob_assignments
       where rownum = 1;
   exception
       when NO_DATA_FOUND then
            l_flag := 0;
   end;

       if l_flag = 0 then
          G_DBI50_FOR_LOB := FALSE;
       else
          G_DBI50_FOR_LOB := TRUE;
       end if;
   -----------------------------------------------

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.INITIALIZE');
     END IF;

EXCEPTION
    WHEN G_LOGIN_INFO_NOT_AVABLE THEN

	fii_util.write_log(g_phase);
	fii_util.write_log('
	  Can not get User ID and Login ID, program exit');

	g_retcode := -1;
	FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.INITIALIZE');
	raise;

    WHEN OTHERS THEN
    	g_retcode := -1;

     	fii_util.write_log('
------------------------
Error in Procedure: INIT
Phase: '||g_phase||'
Message: '||sqlerrm);

	FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.INITIALIZE');
	raise;

END INITIALIZE;

-----------------------------------------------------------------
-- PROCEDURE HANDLE_MISSING_COA
-- This procedure will update -1 of coa_id in FII_COM_CC_MAPPINGS_GT
-- to a real coa defined in FII_DIM_MAPPING_RULES
-----------------------------------------------------------------
Procedure HANDLE_MISSING_COA IS

  l_com_vs_id  number (15);
  l_cc_vs_id   number (15);
  l_coa_id     number (15);
  l_count      number (10) := 0;

  Cursor c_all_value_sets is
    select fv1.flex_value_set_id company_vs_id,
           fv2.flex_value_set_id cost_center_vs_id
      from FII_COM_CC_MAPPINGS_GT ccc,
           fnd_flex_values fv1,
           fnd_flex_values fv2
     where ccc.coa_id = -1
       and ccc.company_id     = fv1.flex_value_id
       and ccc.cost_center_id = fv2.flex_value_id
     for update of ccc.coa_id;

Begin

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.HANDLE_MISSING_COA');
     END IF;

   If g_debug_flag = 'Y' then
       fii_util.start_timer;
   End if;

  For r_value_sets IN c_all_value_sets Loop

    l_com_vs_id := r_value_sets.company_vs_id;
    l_cc_vs_id  := r_value_sets.cost_center_vs_id;

    begin

    --Use fnd_id_flex_segments to figure out all charts_of_accounts
    --related to both company/cost center value set IDs:
    --  if there is no chart_of_accounts found, no change to coa_id;
    --  if there are charts_of_accounts found, but none of them appears
    --     in the mapping rule table; no change to coa_id;
    --  if there are charts_of_accounts found, and some of them are in
    --     the mapping rule table; then use one of them to update coa_id
    --     coa_id in FII_COM_CC_MAPPINGS_GT

     select coa.coa_id into l_coa_id
     from
       (select ID_FLEX_NUM             coa_id
          from fnd_id_flex_segments
         where APPLICATION_ID = 101
           and ID_FLEX_CODE   = 'GL#'
           and FLEX_VALUE_SET_ID = l_com_vs_id
        intersect
        select ID_FLEX_NUM             coa_id
          from fnd_id_flex_segments
         where APPLICATION_ID = 101
           and ID_FLEX_CODE   = 'GL#'
           and FLEX_VALUE_SET_ID = l_cc_vs_id
        intersect
        select CHART_OF_ACCOUNTS_ID    coa_id
          from fii_dim_mapping_rules
         where DIMENSION_SHORT_NAME = 'FII_LOB') coa
      where rownum = 1;

      update FII_COM_CC_MAPPINGS_GT
         set coa_id = l_coa_id
      where current of c_all_value_sets;

      l_count := l_count + 1;

     exception
      when others then
        null;
     end;

  End Loop;

  if g_debug_flag = 'Y' then
    fii_util.put_line('Updated '||l_count||' rows with coa_id = -1 in FII_COM_CC_MAPPINGS_GT');
    fii_util.stop_timer;
    fii_util.print_timer('Duration');
   end if;

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.HANDLE_MISSING_COA');
     END IF;

Exception
  WHEN OTHERS Then
    FII_UTIL.put_line('Error in HANDLE_MISSING_COA; ' || 'Message: ' || sqlerrm);
    FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.HANDLE_MISSING_COA');
    raise;

End HANDLE_MISSING_COA;

-----------------------------------------------------------------
-- PROCEDURE POPULATE_COM_CCC_TEMP
-----------------------------------------------------------------
PROCEDURE POPULATE_COM_CCC_TEMP IS
  l_count   NUMBER(15) :=0;
  l_ret_val BOOLEAN    := FALSE;

  --this cursor prints out all (company, cost_center) with
  --multiple orgs in table fii_ccc_mgr_gt
  Cursor c_duplicate_org is
         select  count(*) cnt,
                 company_id,
                 cost_center_id
           from  fii_ccc_mgr_gt
          where company_id     is not null
            and cost_center_id is not null
       group by company_id, cost_center_id
         having count(*) > 1;

  --this cursor prints out all org for a given (company, cost_center)
  Cursor c_list_dup_org (p_com_id number, p_cc_id number) is
        select com.flex_value company,
               cc.flex_value  cost_center,
               org.name       organization
         from fii_ccc_mgr_gt            gt,
              hr_all_organization_units org,
              fnd_flex_values           com,
              fnd_flex_values           cc
        where gt.company_id     = p_com_id
          and gt.cost_center_id = p_cc_id
          and gt.ccc_org_id     = org.organization_id
          and gt.company_id     = com.flex_value_id
          and gt.cost_center_id = cc.flex_value_id;

BEGIN

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.POPULATE_COM_CCC_TEMP');
     END IF;

     g_phase := 'truncate table FII_COM_CC_MAPPINGS_GT';

     FII_UTIL.TRUNCATE_TABLE('FII_COM_CC_MAPPINGS_GT', g_fii_schema, g_retcode);

---------------------------------------------------------------------------------------
/* Bug 3700956: stop getting ccc org information from CCID

   --g_phase := 'Populate FII_COM_CC_MAPPINGS_GT from fii_gl_ccid_dimensions';

   --   INSERT INTO FII_COM_CC_MAPPINGS_GT
   --      (COMPANY_COST_CENTER_ORG_ID,
   --	    COST_CENTER_ID,
   --	    COMPANY_ID,
   --       COA_ID
   --      )
   --   SELECT DISTINCT
   --     NVL(dim.company_cost_center_org_id, -1),
   --     dim.cost_center_id,
   --     dim.company_id,
   --     dim.chart_of_accounts_id
   --   FROM fii_gl_ccid_dimensions dim;

   --  If g_debug_flag = 'Y' then
   --    FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_COM_CC_MAPPINGS_GT');
   --  END IF;

 End of Bug 3700956 */
---------------------------------------------------------------------------------------


   --------------------------------------------
   --Bug 3560006: Add ccc-org in FII_CCC_MGR_GT
   --             which are not in CCID
   --------------------------------------------

   -- First report bad ccc-org in FII_CCC_MGR_GT

   g_phase := 'report bad ccc-org in FII_CCC_MGR_GT';

   l_count := 0;
   FOR r_dup_org IN c_duplicate_org LOOP
     if l_count = 0 then

         FII_MESSAGE.write_log (msg_name   => 'FII_COM_CC_DUP_ORG',
                                   token_num  => 0);
         FII_MESSAGE.write_log (msg_name   => 'FII_REFER_TO_OUTPUT',
                                   token_num  => 0);

         FII_MESSAGE.write_output (msg_name   => 'FII_COM_CC_DUP_ORG',
                                   token_num  => 0);
         FII_MESSAGE.write_output (msg_name   => 'FII_COM_CC_ORG_LIST',
                                   token_num  => 0);

       -- set the concurrent program to warning status
       l_ret_val := FND_CONCURRENT.Set_Completion_Status
         (status  => 'WARNING',
          message => 'There are combinations of company, cost center with more than one organization assigned');
     end if;

     l_count := l_count + 1;
     FOR r_list_org IN c_list_dup_org (r_dup_org.company_id, r_dup_org.cost_center_id) LOOP
       FII_UTIL.Write_Output (
                               r_list_org.organization  || '          ' ||
                               r_list_org.company       || '          ' ||
                               r_list_org.cost_center );
     END LOOP;
   END LOOP;

   --reset l_count to 0
   l_count := 0;

   g_phase := 'Populate FII_COM_CC_MAPPINGS_GT from fii_ccc_mgr_gt';

   -- Insert all "good" (company, cost center, ccc org) from FII_CCC_MGR_GT
      INSERT INTO FII_COM_CC_MAPPINGS_GT
         (COMPANY_COST_CENTER_ORG_ID,
	  COMPANY_ID,
	  COST_CENTER_ID,
          COA_ID)
      select  NVL(max(ccc_org_id), -1),
              company_id,
              cost_center_id,
              -1
       from  fii_ccc_mgr_gt
       where company_id     is not null
         and cost_center_id is not null
       group by company_id, cost_center_id
       having count(*) = 1;

      If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_COM_CC_MAPPINGS_GT');
      END IF;

      -- Call HANDLE_MISSING_COA to update coa_id = -1 records.
      -- Do this only if using DBI 6.0 for LOB

      If NOT G_DBI50_FOR_LOB then

   	g_phase := 'Call HANDLE_MISSING_COA';

        HANDLE_MISSING_COA;

      End If;

     --------------------------------------------------------------------

      commit;

     --Report missing company cost center organizations
     --(i.e. company_cost_center_org_id = -1).
     --This should not happen after bug 3700956 fix!!!

     g_phase := 'Report missing company cost center organizations';

     begin
		 select 1 into l_count
		 from FII_COM_CC_MAPPINGS_GT
		 where company_cost_center_org_id = -1
		 and rownum = 1;
     exception
         when NO_DATA_FOUND then
              l_count := 0;
     end;

     if l_count > 0 then
        FII_MESSAGE.write_log (msg_name   => 'FII_MISSING_CCC_ORG_FOUND',
                               token_num  => 0);
        FII_MESSAGE.write_output (msg_name   => 'FII_MISSING_CCC_ORG_FOUND',
                                  token_num  => 0);
        l_ret_val := FND_CONCURRENT.Set_Completion_Status
             (status  => 'WARNING',
              message => 'There are null company cost center organizations in HR');
     end if;

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.POPULATE_COM_CCC_TEMP');
     END IF;

EXCEPTION
    WHEN OTHERS THEN
      g_retcode := -1;

      fii_util.write_log('
-----------------------------
Error occured in Procedure: POPULATE_COM_CCC_TEMP
Phase: ' || g_phase || '
Message: ' || sqlerrm);

      FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.POPULATE_COM_CCC_TEMP');
      raise;
END POPULATE_COM_CCC_TEMP;

-----------------------------------------------------------------
-- Procedure POPULATE_ORG_MGR_MAP
-- To populate table FII_ORG_MGR_MAPPINGS used by PMV
-----------------------------------------------------------------
PROCEDURE POPULATE_ORG_MGR_MAP IS

BEGIN

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.POPULATE_ORG_MGR_MAP');
     END IF;

 if g_debug_flag = 'Y' then
   fii_util.put_line('Populating FII_ORG_MGR_MAPPINGS table');
 end if;

 g_phase := 'truncate table FII_ORG_MGR_MAPPINGS';

 FII_UTIL.TRUNCATE_TABLE('FII_ORG_MGR_MAPPINGS', g_fii_schema, g_retcode);

 g_phase := 'insert into FII_ORG_MGR_MAPPINGS';

 --Bug 3750856: should use parent_manager_id when join to fii_com_cc_mappings
 INSERT /*+ APPEND */ INTO FII_ORG_MGR_MAPPINGS (
          manager_id,
          ccc_org_id,
	  CREATION_DATE ,
	  CREATED_BY ,
	  LAST_UPDATE_DATE ,
	  LAST_UPDATED_BY ,
          LAST_UPDATE_LOGIN)
  SELECT  x.mgr_id,
          company_cost_center_org_id,
           SYSDATE,
           g_fii_user_id,
           SYSDATE,
           g_fii_user_id,
           g_fii_login_id
    FROM  fii_com_cc_mappings,
          (SELECT DISTINCT emp_id,
                           mgr_id
             FROM fii_cc_mgr_hierarchies) x
   WHERE x.emp_id = parent_manager_id;

 if g_debug_flag = 'Y' then
   fii_util.put_line('Inserted '||SQL%ROWCOUNT||' rows to FII_ORG_MGR_MAPPINGS');
 end if;

 g_phase := 'gather_table_stats for FII_ORG_MGR_MAPPINGS';

 FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'FII_ORG_MGR_MAPPINGS');

 commit;

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.POPULATE_ORG_MGR_MAP');
     END IF;

EXCEPTION

 WHEN OTHERS THEN
  g_retcode := -1;

  FII_UTIL.put_line('
    ----------------------------
    Error in Function: POPULATE_ORG_MGR_MAP
    Message: '||sqlerrm);
  fii_util.write_log(g_phase);

  FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.POPULATE_ORG_MGR_MAP');

  RAISE;

END POPULATE_ORG_MGR_MAP;

-----------------------------------------------------------------
-- PROCEDURE MAIN_CCID
-----------------------------------------------------------------
PROCEDURE Main_CCID (pmode  IN   VARCHAR2) IS

  p_status  VARCHAR2(1) := NULL;
  l_count   NUMBER(15)  := 0;

BEGIN
     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.Main_CCID');
     END IF;

    g_mode := pmode;

    ---------------------------------------------------
    -- Initialize all global variables from profile
    -- options and other resources
    ---------------------------------------------------

    If g_debug_flag = 'Y' then
        fii_util.write_log('Calling INITIALIZE');
    End if;

    INITIALIZE;

    ----------------------------------------------------
    -- Populate CCC - Mgr mappings temp. table
    -----------------------------------------------------

    If g_debug_flag = 'Y' then
        fii_util.write_log('Calling LOAD_CCC_MGR');
    End if;

    FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR (p_status);

    IF p_status = -1 then
      fii_util.write_log('Error in FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR ...');
      fii_util.write_log('Table FII_CCC_MGR_GT is not populated');
      raise NO_DATA_FOUND;
    END IF;

    ----------------------------------------------------
    -- Check if FII_CC_MGR_HIER_GT is populated
    -- If not, call FII_CC_MGR_SUP_C.Populate_HIER_TMP
    ----------------------------------------------------

    If g_debug_flag = 'Y' then
        fii_util.write_log('Make sure FII_CC_MGR_HIER_GT is populated');
    End if;

    begin
		select 1 into l_count from FII_CC_MGR_HIER_GT
		where rownum = 1;
    exception
        when NO_DATA_FOUND then
             l_count := 0;
    end;

    if l_count = 0 then
       FII_CC_MGR_SUP_C.Populate_HIER_TMP;
    end if;

    ----------------------------------------------------
    -- Populate temp table with updated ccids
    ----------------------------------------------------

    If g_debug_flag = 'Y' then
        fii_util.write_log('Calling POPULATE_COM_CCC_TEMP');
    End if;

    POPULATE_COM_CCC_TEMP;

    ---------------------------------------------------
    -- pmode is 'L' for initial load and 'I' for incremental load
    ---------------------------------------------------
    IF (g_mode = 'L') THEN
    ------------------------------------------------------
    -- Populate fii_com_ccc_mappings in initial pmode
    ------------------------------------------------------
      FII_UTIL.TRUNCATE_TABLE('FII_COM_CC_MAPPINGS', g_fii_schema, g_retcode);

      If g_debug_flag = 'Y' then
        fii_util.write_log('Calling INITIAL_LOAD');
      End if;

      INITIAL_LOAD;

      If g_debug_flag = 'Y' then
        fii_util.write_log('Calling INITIAL_LOAD_LOB');
      End if;

      INITIAL_LOAD_LOB;

    ELSE
  	------------------------------------------------------
    -- Populate fii_com_ccc_mappings in incremental pmode
    ------------------------------------------------------

      If g_debug_flag = 'Y' then
        fii_util.write_log('Calling INCREMENTAL_LOAD');
      End if;

      INCREMENTAL_LOAD;

      If g_debug_flag = 'Y' then
        fii_util.write_log('Calling INCREMENTAL_LOAD_LOB_MERGE');
      End if;

      INCREMENTAL_LOAD_LOB_MERGE;

    END IF;

    COMMIT;

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.Main_CCID');
     END IF;

EXCEPTION
	WHEN OTHERS THEN
		FII_UTIL.put_line('
		    ----------------------------
		    Error in Function: MAIN_CCID
		    Message: '||sqlerrm);
                rollback;
		FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.Main_CCID');
                raise;
END MAIN_CCID;

-----------------------------------------------------------------
-- PROCEDURE MAIN
--
-- Populate two helper tables: FII_COM_CC_MAPPINGS and FII_CC_MGR_SUP
-----------------------------------------------------------------
PROCEDURE Main (errbuf             IN OUT  NOCOPY VARCHAR2,
                retcode            IN OUT  NOCOPY VARCHAR2,
                pmode              IN   VARCHAR2) IS

   l_ret_val             BOOLEAN := FALSE;
   l_count               NUMBER(15);

BEGIN
     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_COMCCH_C.Main');
     END IF;

    errbuf := NULL;
    retcode := 0;
    g_mode := pmode;

    -- First, populate FII_CC_MGR_SUP
    -- We will also populate FII_CC_MGR_HIER_GT
    g_phase := 'Calling the procedure in package FII_CC_MGR_SUP_C';

    if g_mode = 'L' then
      FII_CC_MGR_SUP_C.Init_Load    (errbuf, retcode);
    else
      FII_CC_MGR_SUP_C.Incre_Update (errbuf, retcode);
    end if;


    -- Then, populate FII_COM_CC_MAPPINGS
    g_phase := 'Populate FII_COM_CC_MAPPINGS';

      FII_GL_COMCCH_C.MAIN_CCID (g_mode);

    -- Call the procedure to populate table FII_ORG_MGR_MAPPINGS used in PMV
    g_phase := 'Populate FII_ORG_MGR_MAPPINGS';

      POPULATE_ORG_MGR_MAP;

    --Finally, check missing ccc mgr (i.e. CCC without MGR assigned)
    g_phase := 'Check missing ccc mgr...';

    l_count := FII_GL_EXTRACTION_UTIL.CHECK_MISSING_CCC_MGR;
    if l_count > 0 then
      l_ret_val := FND_CONCURRENT.Set_Completion_Status
         (status  => 'WARNING',
          message => 'Some company cost center organizations have no managers assigned to them.');
    end if;

     If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_COMCCH_C.Main');
     END IF;

EXCEPTION

  WHEN OTHERS THEN
    errbuf  := sqlerrm;
    retcode := sqlcode;
    FII_UTIL.Write_Log ('FII_GL_COMCCH_C.Main: error in phase '|| g_phase);
    FII_UTIL.Write_Log ( substr(sqlerrm,1,180) );
    l_ret_val := FND_CONCURRENT.Set_Completion_Status
                       (status  => 'ERROR', message => substr(sqlerrm,1,180));
    FII_MESSAGE.Func_Fail('FII_GL_COMCCH_C.Main');
    rollback;

END MAIN;

END FII_GL_COMCCH_C;

/
