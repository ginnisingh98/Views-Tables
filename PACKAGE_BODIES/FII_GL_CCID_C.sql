--------------------------------------------------------
--  DDL for Package Body FII_GL_CCID_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_GL_CCID_C" AS
/* $Header: FIIGLCCB.pls 120.52 2006/03/27 19:15:22 juding noship $ */

  g_debug_flag Varchar2(1) := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

	g_retcode              	VARCHAR2(20) := NULL;
	g_fii_schema           	VARCHAR2(30);
	g_worker_num           	NUMBER;
	g_phase                	VARCHAR2(300);
	g_prod_cat_set_id       NUMBER := -999;
	g_mtc_structure_id     	NUMBER;
        g_mtc_value_set_id      NUMBER;
        g_mtc_column_name       VARCHAR2(30) := NULL;
	g_fii_user_id          	NUMBER;
	g_fii_login_id		NUMBER;
        g_current_language      VARCHAR2(30);
        g_max_ccid              NUMBER;
 	g_new_max_ccid          NUMBER;
        g_mode                  VARCHAR2(1);
	g_log_item		VARCHAR2(50);
	g_dimension_name	VARCHAR2(30);

	G_LOGIN_INFO_NOT_AVABLE   EXCEPTION;
	G_DUPLICATE_PROD_ASGN     EXCEPTION;
	G_NO_PROD_SEG_DEFINED 	  EXCEPTION;
        G_INVALID_PROD_CODE_EXIST EXCEPTION;
        G_NEW_PROD_CAT_FOUND      EXCEPTION;
	G_NO_SLG_SETUP	EXCEPTION;
	G_NO_UNASSIGNED_ID	EXCEPTION;
	G_PROD_CAT_ENABLED_FLAG   VARCHAR2(1) := 'N';
	G_UD1_ENABLED		  VARCHAR2(1) := 'N';
	G_UD2_ENABLED		  VARCHAR2(1) := 'N';
	G_UNASSIGNED_ID		  NUMBER(15);

-- ---------------------------------------------------------------
-- Private procedures and Functions;
-- ---------------------------------------------------------------

-- ---------------------------------------------------------------
-- PROCEDURE INIT_DBI_CHANGE_LOG
-- ---------------------------------------------------------------

PROCEDURE INIT_DBI_CHANGE_LOG IS
BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.INIT_DBI_CHANGE_LOG');
   End if;

   If g_debug_flag = 'Y' then
       FII_UTIL.Write_Log('Inserting DBI log items into FII_CHANGE_LOG');
   End if;
   ---------------------------------------------
   -- Populate FII_CHANGE_LOG with inital set up
   -- entries if it hasn't been set up already
   ---------------------------------------------
   INSERT INTO FII_CHANGE_LOG (
          log_item,
      	  item_value,
 	  creation_date,
	  created_by,
    	  last_update_date,
	  last_update_login,
	  last_updated_by)
   SELECT
          DECODE(glrm.multiplier,
    		  1, 'AR_RESUMMARIZE',
 	 	  2, 'GL_RESUMMARIZE',
                  3, 'AP_RESUMMARIZE',
                  4, 'MAX_CCID',
                  5, 'CCID_RELOAD',
                  6, 'PROD_CAT_SET_ID',
                  7, 'GL_PROD_CHANGE',
                  8, 'AR_PROD_CHANGE'),
 		  DECODE(glrm.multiplier,
            		1, 'N',
            		2, 'N',
                        3, 'N',
                        4, '0',
                        5, 'N',
                        6, G_PROD_CAT_SET_ID,
                        7, 'N',
                        8, 'N'),
              sysdate,
	      g_fii_user_id,
              sysdate,
	      g_fii_login_id,
	      g_fii_user_id
 	 FROM  GL_ROW_MULTIPLIERS glrm
 	 WHERE glrm.multiplier between 1 and 8
 	 AND 	 NOT EXISTS
 		 (SELECT 1
 		  FROM   FII_CHANGE_LOG
 		  WHERE  log_item = DECODE(glrm.multiplier,
 				 1, 'AR_RESUMMARIZE',
 				 2, 'GL_RESUMMARIZE',
                                 3, 'AP_RESUMMARIZE',
                                 4, 'MAX_CCID',
                                 5, 'CCID_RELOAD',
                                 6, 'PROD_CAT_SET_ID',
                                 7, 'GL_PROD_CHANGE',
                                 8, 'AR_PROD_CHANGE'));

        If g_debug_flag = 'Y' then
	  FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' log items into FII_CHANGE_LOG');
        End if;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.INIT_DBI_CHANGE_LOG');
   End if;

EXCEPTION

   WHEN OTHERS THEN
      rollback;
      g_retcode := -1;
      FII_UTIL.Write_Log('
Error occured in Procedure: INIT_DBI_CHANGE_LOG
Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_CCID_C.INIT_DBI_CHANGE_LOG');
      raise;

END INIT_DBI_CHANGE_LOG;

-------------------------------------------------------
-- FUNCTION GET_COA_NAME
-------------------------------------------------------
FUNCTION GET_COA_NAME (p_coa_id IN NUMBER) RETURN VARCHAR2 IS

	l_coa_name VARCHAR2(30);

BEGIN
   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.GET_COA_NAME');
   End if;

   g_phase := 'Getting user name for chart of account ID: ' || p_coa_id;

   SELECT DISTINCT id_flex_structure_name INTO l_coa_name
     FROM fnd_id_flex_structures_tl t
    WHERE application_id = 101
      AND id_flex_code = 'GL#'
      AND id_flex_num  = p_coa_id
      AND language     = g_current_language;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.GET_COA_NAME');
   End if;

   return l_coa_name;

EXCEPTION
   WHEN OTHERS THEN
     g_retcode := -1;
     FII_UTIL.Write_Log('
------------------------
Error in Function: GET_COA_NAME
Phase: '||g_phase||'
Message: '||sqlerrm);
     FII_MESSAGE.Func_Fail('FII_GL_CCID_C.GET_COA_NAME');
     raise;

END GET_COA_NAME;

---------------------------------------------------------------------
-- PROCEDURE GET_ACCT_SEGMENTS
---------------------------------------------------------------------
PROCEDURE GET_ACCT_SEGMENTS (p_coa_id      IN          NUMBER,
							 p_company_seg OUT  NOCOPY VARCHAR2,
                             p_cc_seg      OUT  NOCOPY VARCHAR2,
                             p_natural_seg OUT  NOCOPY VARCHAR2) IS

   v_coa_name VARCHAR2(30);

BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.GET_ACCT_SEGMENTS');
   End if;

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Getting Account segments column information for chart of account ID: '
                        || p_coa_id);
   End if;
   ----------------------------------------------------
   -- Given a chart of account ID, it will get:
   -- 1. Balancing segment
   -- 2. Accounting segment
   -- 3. Cost Center segment
   -- of the chart of acccounts
   -----------------------------------------------------
   SELECT fsav1.application_column_name,
		  fsav2.application_column_name,
          fsav3.application_column_name
   INTO   p_company_seg,
          p_cc_seg,
          p_natural_seg
   FROM  FND_SEGMENT_ATTRIBUTE_VALUES fsav1,
         FND_SEGMENT_ATTRIBUTE_VALUES fsav2,
         FND_SEGMENT_ATTRIBUTE_VALUES fsav3
   WHERE fsav1.application_id = 101
   AND   fsav1.id_flex_code = 'GL#'
   AND   fsav1.id_flex_num = p_coa_id
   AND   fsav1.segment_attribute_type = 'GL_BALANCING'
   AND   fsav1.attribute_value = 'Y'
   AND   fsav2.application_id = 101
   AND   fsav2.id_flex_code = 'GL#'
   AND   fsav2.id_flex_num = p_coa_id
   AND   fsav2.segment_attribute_type =  'FA_COST_CTR'
   AND   fsav2.attribute_value = 'Y'
   AND   fsav3.application_id = 101
   AND   fsav3.id_flex_code = 'GL#'
   AND   fsav3.id_flex_num = p_coa_id
   AND   fsav3.segment_attribute_type = 'GL_ACCOUNT'
   AND   fsav3.attribute_value = 'Y';

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.GET_ACCT_SEGMENTS');
   End if;

EXCEPTION
   WHEN NO_DATA_FOUND THEN
      -----------------------------------------------
      -- 1. Get user name of the chart of accounts
      -- 2. Print out translated messages to indicate
      --    that set up for chart of account is not
      --    complete
      -----------------------------------------------
		v_coa_name := GET_COA_NAME(p_coa_id);

		FII_MESSAGE.write_log(
			msg_name	=> 'FII_COA_SEG_NOT_FOUND',
			token_num	=> 1,
			t1		=> 'COA_NAME',
			v1		=> v_coa_name);

		FII_MESSAGE.write_output(
			msg_name	=> 'FII_COA_SEG_NOT_FOUND',
			token_num	=> 1,
			t1		=> 'COA_NAME',
			v1		=> v_coa_name);

		FII_MESSAGE.Func_Fail('FII_GL_CCID_C.GET_ACCT_SEGMENTS');

		RAISE;

	WHEN OTHERS THEN
   	    rollback;
   	    FII_UTIL.Write_Log('
----------------------------
Error occured in Procedure: GET_ACCT_SEGMENTS
Message: ' || sqlerrm);
		FII_MESSAGE.Func_Fail('FII_GL_CCID_C.GET_ACCT_SEGMENTS');
		RAISE;
END GET_ACCT_SEGMENTS;

-----------------------------------------------------------------------------
-- PROCEDURE POPULATE_SLG_TMP
-- This procedure populates the global temp table FII_CCID_SLG_GT
-----------------------------------------------------------------------------
 Procedure POPULATE_SLG_TMP IS

  l_coa_id       number(15);
  l_company_seg  varchar2(120);
  l_stmt         varchar2(1000);

  Cursor tmp_coa_list IS
    select distinct COA_ID
      from FII_CCID_SLG_GT
     where BAL_SEG_VALUE_ID = -1;

 Begin

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.POPULATE_SLG_TMP');
   End if;

   IF g_debug_flag = 'Y' then
     FII_UTIL.Write_Log('Insert to  FII_CCID_SLG_GT by select DISTINCT ');
   END IF;

   insert into FII_CCID_SLG_GT
     (COA_ID,
      BAL_SEG_VALUE,
      BAL_SEG_VALUE_ID)
    select DISTINCT
      sts.chart_of_accounts_id,
      sts.bal_seg_value,
      sts.bal_seg_value_id
    from  fii_slg_assignments      sts,
          fii_source_ledger_groups slg
    where slg.usage_code  = 'DBI'
      and slg.source_ledger_group_id = sts.source_ledger_group_id;

   If g_debug_flag = 'Y' then
     FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_CCID_SLG_GT');
   End if;

   IF g_debug_flag = 'Y' then
     FII_UTIL.Write_Log('Update FII_CCID_SLG_GT for BAL_SEG_VALUE_ID = -1 (insert all company values)');
   END IF;

   For l_coa_rec IN tmp_coa_list LOOP
     l_coa_id := l_coa_rec.COA_ID;

     delete from FII_CCID_SLG_GT where COA_ID = l_coa_id;

     SELECT application_column_name  INTO  l_company_seg
     FROM  FND_SEGMENT_ATTRIBUTE_VALUES
     WHERE application_id = 101
     AND   id_flex_code = 'GL#'
     AND   id_flex_num = l_coa_id
     AND   segment_attribute_type = 'GL_BALANCING'
     AND   attribute_value = 'Y';

     l_stmt := 'INSERT INTO FII_CCID_SLG_GT
         (COA_ID,
          BAL_SEG_VALUE,
          BAL_SEG_VALUE_ID)
        SELECT DISTINCT
          CHART_OF_ACCOUNTS_ID,
          ' || l_company_seg || ',
          -2
        FROM  GL_CODE_COMBINATIONS
        WHERE CHART_OF_ACCOUNTS_ID = ' || l_coa_id || '
          AND SUMMARY_FLAG = ''N''
          AND TEMPLATE_ID IS NULL ';

      If g_debug_flag = 'Y' then
         FII_UTIL.Write_Log(' ');
         FII_UTIL.Write_Log(l_stmt);
      End if;

      EXECUTE IMMEDIATE l_stmt;

      If g_debug_flag = 'Y' then
         FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_CCID_SLG_GT');
      End if;

   END LOOP;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.POPULATE_SLG_TMP');
   End if;

 Exception

     WHEN OTHERS THEN
       rollback;
       g_retcode := -1;
       FII_UTIL.Write_Log('
-----------------------------
Error occured in Procedure: POPULATE_SLG_TMP;
Message: ' || sqlerrm);
	FII_MESSAGE.Func_Fail('FII_GL_CCID_C.POPULATE_SLG_TMP');
	 raise;
 End POPULATE_SLG_TMP;

-----------------------------------------------------------------------------
-- PROCEDURE INSERT_INTO_CCID_DIM
-----------------------------------------------------------------------------
PROCEDURE INSERT_INTO_CCID_DIM (p_company_seg IN VARCHAR2,
                                p_cc_seg      IN VARCHAR2,
                                p_natural_seg IN VARCHAR2,
				p_ud1_seg     IN VARCHAR2,
                                p_ud2_seg     IN VARCHAR2) IS
 l_stmt VARCHAR2(10000);

BEGIN
   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.INSERT_INTO_CCID_DIM');
   End if;

   IF g_debug_flag = 'Y' then
     FII_UTIL.Write_Log('Inserting CCIDs in chart of accounts: ' ||
						p_company_seg || ' - ' ||
						p_cc_seg || ' - ' ||
						p_natural_seg || ' - ' ||
						p_ud1_seg || ' - ' ||
						p_ud2_seg);
   END IF;

   ---------------------------------------------
   -- Inserting records into GL CCID dimension
   -- Two new dimensions UD1 and UD2 have been added for Expense Analysis.
   -- Hence two new columns have been introduced in FII_GL_CCID_DIMENSIONS.
   ---------------------------------------------
	l_stmt := 'INSERT INTO FII_GL_CCID_DIMENSIONS (
 						code_combination_id,
						chart_of_accounts_id,
						company_id,
 	 					cost_center_id,
						natural_account_id,
						company_cost_center_org_id,
   					        creation_date,
						created_by,
						last_update_date,
						last_updated_by,
						last_update_login,
                                                user_dim1_id,
						user_dim2_id)
				SELECT /*+ ordered use_nl(seg1,seg2,seg3)
						   use_hash(glcc) */
                         glcc.code_combination_id,
                         glcc.chart_of_accounts_id,
						 flx1.flex_value_id,
                         flx2.flex_value_id,
                         flx3.flex_value_id,
                         NVL(glcc.company_cost_center_org_id, -1),
                         sysdate,
                         ' ||g_fii_user_id || ',
                         sysdate,
                         ' || g_fii_user_id || ',
                         ' || g_fii_login_id ;

	 -- UD1/UD2 to be populated only if it is enabled.
	-- In case UD1 or UD2 is disabled an unassigned id will be populated.

        IF(G_UD1_ENABLED = 'N'  OR  p_ud1_seg  is null) THEN
            l_stmt := l_stmt || ',' || G_UNASSIGNED_ID || ',';
	ELSE
            l_stmt := l_stmt || ',flx4.flex_value_id,';
        END IF;

        IF(G_UD2_ENABLED = 'N'  OR  p_ud2_seg  is null) THEN
            l_stmt := l_stmt || G_UNASSIGNED_ID ;
	ELSE
            l_stmt := l_stmt || 'flx5.flex_value_id';
        END IF;


  	l_stmt := l_stmt ||  ' FROM ( select coa_id, udd1_vset_id, udd2_vset_id
                                        from FII_ACCT_SEG_GT
				       where company_seg_name = ''' || p_company_seg || '''
				         and   costctr_seg_name = ''' || p_cc_seg      || '''
				         and   natural_seg_name = ''' || p_natural_seg || '''
					 and nvl(udd1_seg_name, 1) = nvl(''' || p_ud1_seg || ''',1)
                                         and nvl(udd2_seg_name, 1) =nvl(''' || p_ud2_seg || ''',1)
                     ) accts,
					  FII_CCID_SLG_GT      csg,
					  fnd_id_flex_segments seg1,
					  fnd_id_flex_segments seg2,
					  fnd_id_flex_segments seg3,
					  GL_CODE_COMBINATIONS glcc,
					  fnd_flex_values flx1,
					  fnd_flex_values flx2,
					  fnd_flex_values flx3 ';

         IF(G_UD1_ENABLED = 'Y'  AND  p_ud1_seg  is not  null) THEN

            l_stmt := l_stmt || ',fnd_flex_values flx4';

	 END IF;

         IF(G_UD2_ENABLED = 'Y' AND   p_ud2_seg  is not  null) THEN

             l_stmt := l_stmt || ',fnd_flex_values flx5';

         END IF;

 	      l_stmt := l_stmt || ' WHERE csg.coa_id = accts.coa_id
				AND   glcc.chart_of_accounts_id = csg.coa_id
				AND   glcc.' || p_company_seg || ' = csg.BAL_SEG_VALUE
				AND   glcc.code_combination_id > ' || g_max_ccid || '
				AND   glcc.summary_flag = ''N''
				AND   glcc.template_ID IS NULL

				AND   seg1.application_id = 101
				AND   seg1.id_flex_code   = ''GL#''
				AND   seg1.id_flex_num    = csg.coa_id
				AND   seg1.APPLICATION_COLUMN_NAME = ''' || p_company_seg || '''
				AND   flx1.flex_value_set_id = seg1.flex_value_set_id
				AND   glcc.' || p_company_seg || ' = flx1.FLEX_VALUE

				AND   seg2.application_id = 101
				AND   seg2.id_flex_code   = ''GL#''
				AND   seg2.id_flex_num = csg.coa_id
				AND   seg2.APPLICATION_COLUMN_NAME = ''' || p_cc_seg || '''
				AND   flx2.flex_value_set_id  = seg2.flex_value_set_id
				AND   glcc.' || p_cc_seg || ' = flx2.FLEX_VALUE

				AND   seg3.application_id = 101
				AND   seg3.id_flex_code   = ''GL#''
				AND   seg3.id_flex_num = csg.coa_id
				AND   seg3.APPLICATION_COLUMN_NAME = ''' ||p_natural_seg || '''
				AND   flx3.flex_value_set_id = seg3.flex_value_set_id
				AND   glcc.' || p_natural_seg || ' = flx3.FLEX_VALUE';

         IF(G_UD1_ENABLED = 'Y'  AND  p_ud1_seg  is not  null) THEN

              l_stmt := l_stmt || ' AND   flx4.flex_value_set_id = accts.udd1_vset_id
				AND   glcc.' || p_ud1_seg || ' = flx4.FLEX_VALUE';
	 END IF;

         IF(G_UD2_ENABLED = 'Y' AND   p_ud2_seg  is not  null) THEN

              l_stmt := l_stmt ||' AND   flx5.flex_value_set_id = accts.udd2_vset_id
				AND   glcc.' || p_ud2_seg || ' = flx5.FLEX_VALUE';
         END IF;


   If g_debug_flag = 'Y' then
     FII_UTIL.Write_Log(l_stmt);
     FII_UTIL.start_timer;
   End if;

   execute immediate l_stmt;

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' records into FII_GL_CCID_DIMENSIONS');
      FII_UTIL.stop_timer;
      FII_UTIL.print_timer('Duration');
      FII_UTIL.Write_Log('');
   End if;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.INSERT_INTO_CCID_DIM');
   End if;

EXCEPTION

   -------------------------------------------------------
   -- Do not need handle the case when company cost org ID
   -- is NULL.  For CCID which company cost org ID is NULL
   -- we will insert -1 into the company cost org ID field
   -- in FII_GL_CCID_DIMENSIONS table
   -------------------------------------------------------

   WHEN OTHERS THEN
 	    rollback;
	    g_retcode := -1;
 	    FII_UTIL.Write_Log('
-----------------------------
Error occured in Procedure: INSERT_INTO_CCID_DIM
Message: ' || sqlerrm);
	    FII_MESSAGE.Func_Fail('FII_GL_CCID_C.INSERT_INTO_CCID_DIM');
  	    raise;
END INSERT_INTO_CCID_DIM;

-----------------------------------------------------------------------------
-- PROCEDURE INSERT_INTO_CCID_DIM_INIT
-----------------------------------------------------------------------------
PROCEDURE INSERT_INTO_CCID_DIM_INIT (p_company_seg IN VARCHAR2,
                                     p_cc_seg      IN VARCHAR2,
                                     p_natural_seg IN VARCHAR2,
				     p_ud1_seg  IN VARCHAR2,
				     p_ud2_seg	IN VARCHAR2) IS

  l_stmt VARCHAR2(10000);

BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.INSERT_INTO_CCID_DIM_INIT');
   End if;

   IF g_debug_flag = 'Y' then
     FII_UTIL.Write_Log('Inserting CCIDs in chart of accounts: ' ||
						p_company_seg || ' - ' ||
						p_cc_seg || ' - ' ||
						p_natural_seg);
   END IF;

   ---------------------------------------------
   -- Inserting records into GL CCID dimension
   -- Two new dimensions UD1 and UD2 have been added for Expense Analysis.
   -- Hence two new columns have been introduced in FII_GL_CCID_DIMENSIONS.
   ---------------------------------------------
   l_stmt :=   'INSERT /*+ append parallel(fii) */ INTO
				FII_GL_CCID_DIMENSIONS fii (
 						code_combination_id,
						chart_of_accounts_id,
						company_id,
 	 					cost_center_id,
						natural_account_id,
						company_cost_center_org_id,
   				  	    creation_date,
						created_by,
						last_update_date,
						last_updated_by,
						last_update_login,
                        user_dim1_id, user_dim2_id)
				SELECT /*+ ordered use_nl(seg1,seg2,seg3)
						   use_hash(glcc) parallel(glcc) */
                         glcc.code_combination_id,
                         glcc.chart_of_accounts_id,
                         flx1.flex_value_id,
                         flx2.flex_value_id,
                         flx3.flex_value_id,
                         NVL(glcc.company_cost_center_org_id, -1),
                         sysdate,
                         ' ||g_fii_user_id || ',
                         sysdate,
                         ' || g_fii_user_id || ',
                         ' || g_fii_login_id || ',';
                         --to_number (NULL)

        IF(G_UD1_ENABLED = 'N'  OR  p_ud1_seg  is null) THEN
            l_stmt := l_stmt || G_UNASSIGNED_ID || ',' ;
	ELSE
            l_stmt := l_stmt || 'flx4.flex_value_id,';
        END IF;

        IF(G_UD2_ENABLED = 'N'  OR  p_ud2_seg  is null) THEN
            l_stmt := l_stmt  || G_UNASSIGNED_ID ;
	ELSE
            l_stmt := l_stmt  || 'flx5.flex_value_id';
        END IF;

  		  l_stmt := l_stmt ||  ' FROM ( select coa_id, udd1_vset_id, udd2_vset_id
                                                  from FII_ACCT_SEG_GT
					         where company_seg_name = ''' || p_company_seg || '''
					           and   costctr_seg_name = ''' || p_cc_seg      || '''
					           and   natural_seg_name = ''' || p_natural_seg || '''
					           and nvl(udd1_seg_name, 1) = nvl('''|| p_ud1_seg ||''',1)
                                                   and nvl(udd2_seg_name, 1) =nvl('''|| p_ud2_seg ||''',1)
                     ) accts,
					  FII_CCID_SLG_GT      csg,
					  fnd_id_flex_segments seg1,
					  fnd_id_flex_segments seg2,
					  fnd_id_flex_segments seg3,
					  GL_CODE_COMBINATIONS glcc,
					  fnd_flex_values flx1,
					  fnd_flex_values flx2,
					  fnd_flex_values flx3 ';

        -- UD1/UD2 to be populated only if it is enabled.
	-- In case UD1 or UD2 is disabled an unassigned id will be populated.

         IF(G_UD1_ENABLED = 'Y'  AND  p_ud1_seg  is not  null) THEN

            l_stmt := l_stmt || ',fnd_flex_values flx4';

	 END IF;

         IF(G_UD2_ENABLED = 'Y' AND   p_ud2_seg  is not  null) THEN

             l_stmt := l_stmt || ',fnd_flex_values flx5';

         END IF;
 	           l_stmt := l_stmt ||  ' WHERE csg.coa_id = accts.coa_id
				AND   glcc.chart_of_accounts_id = csg.coa_id
				AND   glcc.' || p_company_seg || ' = csg.BAL_SEG_VALUE
				AND   glcc.summary_flag = ''N''
				AND   glcc.template_ID IS NULL

				AND   seg1.application_id = 101
				AND   seg1.id_flex_code   = ''GL#''
				AND   seg1.id_flex_num = csg.coa_id
				AND   seg1.APPLICATION_COLUMN_NAME = ''' || p_company_seg || '''
				AND   flx1.flex_value_set_id = seg1.flex_value_set_id
				AND   glcc.' || p_company_seg || ' = flx1.FLEX_VALUE

				AND   seg2.application_id = 101
				AND   seg2.id_flex_code   = ''GL#''
				AND   seg2.id_flex_num = csg.coa_id
				AND   seg2.APPLICATION_COLUMN_NAME = ''' || p_cc_seg || '''
				AND   flx2.flex_value_set_id  = seg2.flex_value_set_id
				AND   glcc.' || p_cc_seg || ' = flx2.FLEX_VALUE

				AND   seg3.application_id = 101
				AND   seg3.id_flex_code   = ''GL#''
				AND   seg3.id_flex_num = csg.coa_id
				AND   seg3.APPLICATION_COLUMN_NAME = ''' ||p_natural_seg || '''
				AND   flx3.flex_value_set_id = seg3.flex_value_set_id
				AND   glcc.' || p_natural_seg || ' = flx3.FLEX_VALUE';

         IF(G_UD1_ENABLED = 'Y'  AND  p_ud1_seg  is not  null) THEN

              l_stmt := l_stmt ||' AND   flx4.flex_value_set_id = accts.udd1_vset_id
				AND   glcc.' || p_ud1_seg || ' = flx4.FLEX_VALUE';
	 END IF;

         IF(G_UD2_ENABLED = 'Y' AND   p_ud2_seg  is not  null) THEN

              l_stmt := l_stmt ||' AND   flx5.flex_value_set_id = accts.udd2_vset_id
				AND   glcc.' || p_ud2_seg || ' = flx5.FLEX_VALUE';
         END IF;

   If g_debug_flag = 'Y' then
     FII_UTIL.Write_Log(l_stmt);
     FII_UTIL.start_timer;
   End if;

   EXECUTE IMMEDIATE l_stmt;

   If g_debug_flag = 'Y' then
     FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' records into FII_GL_CCID_DIMENSIONS');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
     FII_UTIL.Write_Log('');
   End if;

   --need this to avoid ORA-12838: cannot read/modify an object after modifying it in parallel
   COMMIT;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.INSERT_INTO_CCID_DIM_INIT');
   End if;

EXCEPTION

   WHEN OTHERS THEN
      FII_UTIL.TRUNCATE_TABLE('FII_GL_CCID_DIMENSIONS', g_fii_schema, g_retcode);
      g_retcode := -1;
      FII_UTIL.Write_Log('
-----------------------------
Error occured in Procedure: INSERT_INTO_CCID_DIM_INIT
Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_CCID_C.INSERT_INTO_CCID_DIM_INIT');
      raise;
END INSERT_INTO_CCID_DIM_INIT;

------------------------------------------------------------------
-- PROCEDURE RECORD_MAX_PROCESSED_CCID
------------------------------------------------------------------
PROCEDURE RECORD_MAX_PROCESSED_CCID IS

  l_tmp_max_ccid NUMBER;

BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.RECORD_MAX_PROCESSED_CCID');
   End if;

   g_phase := 'Updating max CCID processed';
   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('');
      FII_UTIL.Write_Log(g_phase);
      FII_UTIL.start_timer;
   End if;

   --------------------------------------------------------------
   -- Get the real max ccid that was inserted into CCID dimension
   -- the g_new_max_ccid recorded at the beginning of the program
   -- may not necessary be the largest CCID that was inserted.
   -- New ccids could have been created while the program is
   -- running. So record this max ccid from fii_gl_ccid_dimensions
   --
   -- Note that origianl g_new_max_ccid is from GL_CODE_COMBINATIONS,
   --------------------------------------------------------------

   g_phase := 'SELECT FROM fii_gl_ccid_dimensions';

   SELECT MAX(code_combination_id) INTO l_tmp_max_ccid
   FROM fii_gl_ccid_dimensions;

   -- we should pick the larger one for g_new_max_ccid
   -- between l_tmp_max_ccid and the original g_new_max_ccid
   if g_new_max_ccid < l_tmp_max_ccid then
     g_new_max_ccid := l_tmp_max_ccid;
   end if;

   g_phase := 'UPDATE fii_change_log';

   -- we also update PROD_CAT_SET_ID here
   UPDATE fii_change_log
   SET item_value        = decode (log_item, 'MAX_CCID', to_char(g_new_max_ccid),
                                             'PROD_CAT_SET_ID', g_prod_cat_set_id),
       last_update_date  = SYSDATE,
       last_update_login = g_fii_login_id,
       last_updated_by   = g_fii_user_id
   WHERE log_item = 'MAX_CCID'
   OR (log_item = 'PROD_CAT_SET_ID' and g_prod_cat_set_id is not null);

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in fii_change_log');
   End if;

   If g_debug_flag = 'Y' then
      FII_UTIL.stop_timer;
      FII_UTIL.print_timer('Duration');
      FII_UTIL.Write_Log('');
   End if;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.RECORD_MAX_PROCESSED_CCID');
   End if;

EXCEPTION
   WHEN OTHERS THEN
      rollback;
      g_retcode := -1;
      FII_UTIL.Write_Log('
-------------------------------------------
Error occured in Procedure: RECORD_MAX_PROCESSED_CCID
Phase: ' || g_phase || '
Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_CCID_C.RECORD_MAX_PROCESSED_CCID');
      raise;

END RECORD_MAX_PROCESSED_CCID;

------------------------------------------------------------------
-- FUNCTION NEW_CCID_IN_GL
------------------------------------------------------------------
FUNCTION NEW_CCID_IN_GL RETURN BOOLEAN IS
BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.NEW_CCID_IN_GL');
   End if;

   g_phase := 'Identifying Max CCID processed';
   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
      FII_UTIL.Write_Log('');
   End if;

   -- Bug 4152799.
   g_log_item := 'MAX_CCID';

   SELECT item_value INTO g_max_ccid
   FROM fii_change_log
   WHERE log_item = g_log_item;

   g_phase := 'Identifying current Max CCID in GL';
   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
      FII_UTIL.Write_Log('');
   End if;

   SELECT max(code_combination_id) INTO g_new_max_ccid
   FROM gl_code_combinations;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.NEW_CCID_IN_GL');
   End if;

	IF g_new_max_ccid > g_max_ccid THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;

EXCEPTION
   WHEN OTHERS THEN
      rollback;
      g_retcode := -1;
      FII_UTIL.Write_Log('
-------------------------------------------
Error occured in Function: NEW_CCID_IN_GL
Phase: ' || g_phase || '
Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_CCID_C.NEW_CCID_IN_GL');
      raise;
END NEW_CCID_IN_GL;

------------------------------------------------------------------
-- PROCEDURE PROCESS_NULL_CCC_ORG_ID
------------------------------------------------------------------
PROCEDURE PROCESS_NULL_CCC_ORG_ID IS

BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.PROCESS_NULL_CCC_ORG_ID');
   End if;

   --------------------------------------------------------------
   -- Updating CCID Dimension for CCIDs with NULL CCC ORG ID
   --------------------------------------------------------------
   g_phase := 'Updating CCID Dimension for CCIDs with NULL CCC ORG ID';
   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
      FII_UTIL.start_timer;
   End if;

   UPDATE fii_gl_ccid_dimensions dim
	SET dim.company_cost_center_org_id =
		(SELECT NVL(gcc.company_cost_center_org_id, -1)
	           FROM gl_code_combinations gcc
                  WHERE gcc.code_combination_id = dim.code_combination_id)
   WHERE dim.company_cost_center_org_id = -1;

   IF g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Assigned CCC ORG ID to ' || SQL%ROWCOUNT
                        || ' CCIDs in FII_GL_CCID_DIMENSIONS');
      FII_UTIL.stop_timer;
      FII_UTIL.print_timer('Duration');
   END IF;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.PROCESS_NULL_CCC_ORG_ID');
   End if;

EXCEPTION

  WHEN OTHERS THEN
	rollback;
	g_retcode := -1;
        FII_UTIL.Write_Log('
-----------------------------
Error occured in Procedure: PROCESS_NULL_CCC_ORG_ID
Phase: ' || g_phase || '
Message: ' || sqlerrm);
       FII_MESSAGE.Func_Fail('FII_GL_CCID_C.PROCESS_NULL_CCC_ORG_ID');
       RAISE;

END PROCESS_NULL_CCC_ORG_ID;


------------------------------------------------------------------
-- PROCEDURE INSERT_NEW_CCID
------------------------------------------------------------------
PROCEDURE INSERT_NEW_CCID IS

	CURSOR sss_list IS
	SELECT DISTINCT company_seg_name, costctr_seg_name,
	       natural_seg_name, udd1_seg_name, udd2_seg_name
	FROM FII_ACCT_SEG_GT;

BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.INSERT_NEW_CCID');
   End if;

	g_phase := 'Identifying Max CCID processed';
	If g_debug_flag = 'Y' then
		FII_UTIL.Write_Log(g_phase);
		FII_UTIL.Write_Log('');
	End if;

	-- Bug 4152799.
	g_log_item := 'MAX_CCID';

	SELECT item_value INTO g_max_ccid
	FROM fii_change_log
	WHERE log_item = g_log_item;

	g_phase := 'Identifying current Max CCID in GL';
	If g_debug_flag = 'Y' then
		FII_UTIL.Write_Log(g_phase);
		FII_UTIL.Write_Log('');
	End if;

	------------------------------------------------------
	-- g_mode = 'L' if program is run in Initial Load mode
	------------------------------------------------------
	IF (g_mode = 'L') then

      --Clean up the CCID dimension table

	  g_phase := 'TRUNCATE FII_GL_CCID_DIMENSIONS';

      FII_UTIL.TRUNCATE_TABLE('FII_GL_CCID_DIMENSIONS',g_fii_schema,g_retcode);

      --------------------------------------------------------------------------
      --Bug 3205051: we should not force re-summarization for CCID initial load
      -- This is wrong: Update FII_DIM_MAPPING_RULES to force
      --                using product assignments
      --*UPDATE fii_dim_mapping_rules
      --*   SET status_code = 'O',
      --*       last_update_date = sysdate,
      --*       last_update_login = g_fii_login_id,
      --*       last_updated_by = g_fii_user_id
      --* WHERE dimension_short_name = 'ENI_ITEM_VBH_CAT';
      --------------------------------------------------------------------------

      --Update FII_CHANGE_LOG to reset MAX_CCID

	  g_phase := 'UPDATE fii_change_log';

      -- Bug 4152799.

      UPDATE fii_change_log
      SET item_value = '0',
          last_update_date = sysdate,
          last_update_login = g_fii_login_id,
          last_updated_by = g_fii_user_id
      WHERE log_item = g_log_item;

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in fii_change_log');
   End if;

      g_max_ccid := 0;

	END IF;

	g_phase := 'SELECT FROM gl_code_combinations';

	SELECT max(code_combination_id) INTO g_new_max_ccid
	FROM gl_code_combinations;

	IF (g_new_max_ccid > g_max_ccid) THEN

		g_phase := 'Insert new CCIDs into FII_GL_CCID_DIMENSIONS table';
        If g_debug_flag = 'Y' then
      	   FII_UTIL.Write_Log(g_phase);
      	   FII_UTIL.Write_Log('');
        End if;

		------------------------------------------------------------------
		-- Using this SQL to get company segment, cost center segment
		-- and natural account segment for each chart of account.
		-- These information are needed to build the dynamic SQL
		-- in the INSERT_INTO_CCID API.
		-- For supporting UD1/UD2 dimensions as well segment names for
		-- these two dimensions are also populated. Also to avoid join
		-- with FII_DIM_MAPPING_RULES the value set id is also populated.
		------------------------------------------------------------------

		FII_UTIL.TRUNCATE_TABLE('FII_ACCT_SEG_GT', g_fii_schema, g_retcode);

	    g_phase := 'INSERT INTO FII_ACCT_SEG_GT';

		INSERT INTO FII_ACCT_SEG_GT(
			coa_id, company_seg_name, costctr_seg_name, natural_seg_name
		)
		SELECT coa_list.chart_of_accounts_id,
			   fsav1.application_column_name,
			   fsav2.application_column_name,
			   fsav3.application_column_name
		FROM ( SELECT DISTINCT sts.chart_of_accounts_id
			   FROM fii_slg_assignments sts,
					fii_source_ledger_groups slg
			   WHERE slg.usage_code = 'DBI'
			   AND slg.source_ledger_group_id = sts.source_ledger_group_id
			 ) coa_list,
			 FND_SEGMENT_ATTRIBUTE_VALUES fsav1,
			 FND_SEGMENT_ATTRIBUTE_VALUES fsav2,
			 FND_SEGMENT_ATTRIBUTE_VALUES fsav3
		WHERE fsav1.application_id = 101
		AND   fsav1.id_flex_code = 'GL#'
		AND   fsav1.id_flex_num = coa_list.chart_of_accounts_id
		AND   fsav1.segment_attribute_type = 'GL_BALANCING'
		AND   fsav1.attribute_value = 'Y'
		AND   fsav2.application_id = 101
		AND   fsav2.id_flex_code = 'GL#'
		AND   fsav2.id_flex_num = coa_list.chart_of_accounts_id
		AND   fsav2.segment_attribute_type =  'FA_COST_CTR'
		AND   fsav2.attribute_value = 'Y'
		AND   fsav3.application_id = 101
		AND   fsav3.id_flex_code = 'GL#'
		AND   fsav3.id_flex_num = coa_list.chart_of_accounts_id
		AND   fsav3.segment_attribute_type = 'GL_ACCOUNT'
		AND   fsav3.attribute_value = 'Y';

		If g_debug_flag = 'Y' then
		  FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_ACCT_SEG_GT');
		End if;

	--------------------------------------------------------------------------------
	-- For supporting UD1/UD2 dimensions as well segment names for
	-- these two dimensions are also populated. Also to avoid join
	-- with FII_DIM_MAPPING_RULES in INSERT_INTO_CCID_DIM_INIT/INSERT_INTO_CCID_DIM
	-- the value set id is also populated.
	--------------------------------------------------------------------------------

	IF(G_UD1_ENABLED = 'Y'  ) THEN
	   g_dimension_name := 'FII_USER_DEFINED_1';
           UPDATE FII_ACCT_SEG_GT tab1
           SET (udd1_seg_name, udd1_vset_id) = (select application_column_name1, flex_value_set_id1
                               from fii_dim_mapping_rules
                               where chart_of_accounts_id = tab1.coa_id
                               and dimension_short_name = g_dimension_name);
        END IF;

	If g_debug_flag = 'Y' then
		  FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_ACCT_SEG_GT');
	End if;

        IF(G_UD2_ENABLED = 'Y'  ) THEN
	   g_dimension_name := 'FII_USER_DEFINED_2';
           UPDATE FII_ACCT_SEG_GT tab1
           SET (udd2_seg_name, udd2_vset_id) = (select application_column_name1, flex_value_set_id1
                               from fii_dim_mapping_rules
                               where chart_of_accounts_id = tab1.coa_id
                               and dimension_short_name = g_dimension_name);
        END IF;

	If g_debug_flag = 'Y' then
		  FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_ACCT_SEG_GT');
	End if;

		----------------------------------------------------
		-- Looping through each group of COA_IDs in the
		-- FII_ACCT_SEG_GT table to process the CCIDs
		----------------------------------------------------

		FOR sss IN sss_list LOOP

			IF (g_mode = 'L') then

	            g_phase := 'Call INSERT_INTO_CCID_DIM_INIT';

				INSERT_INTO_CCID_DIM_INIT(
					sss.company_seg_name,
					sss.costctr_seg_name,
					sss.natural_seg_name,
					sss.udd1_seg_name,
                                        sss.udd2_seg_name);
			ELSE
	            g_phase := 'Call INSERT_INTO_CCID_DIM';

				INSERT_INTO_CCID_DIM(
					sss.company_seg_name,
					sss.costctr_seg_name,
					sss.natural_seg_name,
				        sss.udd1_seg_name,
					sss.udd2_seg_name);
			END IF;

		END LOOP;

    	------------------------------------------------------
    	-- Record the max CCID processed
    	------------------------------------------------------
	    g_phase := 'Call RECORD_MAX_PROCESSED_CCID';

		RECORD_MAX_PROCESSED_CCID;

	ELSE
	    If g_debug_flag = 'Y' then
		FII_UTIL.Write_Log('No new CCID in GL');
  	    End if;
	END IF;

	------------------------------------------------------
	-- Process CCIDs with NULL Company Cost Center Org ID
	-- Including old CCIDs which are already in CCID Dim.
	------------------------------------------------------
	-- Bug 4073775. Removed the call to PROCESS_NULL_CCC_ORG_ID.
	--IF (g_mode <> 'L') THEN

	--    g_phase := 'Call PROCESS_NULL_CCC_ORG_ID';

	--	PROCESS_NULL_CCC_ORG_ID;
	--END IF;

	--------------------------------------------------------
	-- Gather statistics for the use of cost-based optimizer
	--------------------------------------------------------
	--Will seed this in RSG
	-- FND_STATS.gather_table_stats
	--     (ownname        => g_fii_schema,
	--      tabname        => 'FII_GL_CCID_DIMENSIONS');

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.INSERT_NEW_CCID');
   End if;

EXCEPTION

  WHEN OTHERS THEN

    if g_mode = 'L' then

       --program is run in Initial Load mode, truncate the table and reset LOG

       FII_UTIL.TRUNCATE_TABLE('FII_GL_CCID_DIMENSIONS',g_fii_schema,g_retcode);

       -- Bug 4152799.
       g_log_item := 'MAX_CCID';

       UPDATE fii_change_log
          SET item_value = '0',
              last_update_date = sysdate,
              last_update_login = g_fii_login_id,
              last_updated_by = g_fii_user_id
        WHERE log_item = g_log_item;

       g_max_ccid := 0;

    end if;

    rollback;
    g_retcode := -1;
    FII_UTIL.Write_Log('
-----------------------------
Error occured in Procedure: INSERT_NEW_CCID
Phase: ' || g_phase || '
Message: ' || sqlerrm);
    FII_MESSAGE.Func_Fail('FII_GL_CCID_C.INSERT_NEW_CCID');
    raise;

END INSERT_NEW_CCID;

--------------------------------------------------------------
-- PROCEDURE USE_SEG
--------------------------------------------------------------
PROCEDURE USE_SEG (p_coa_id IN NUMBER, p_product_seg IN VARCHAR2) IS

	l_stmt VARCHAR2(5000);

BEGIN
   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.USE_SEG');
   End if;

    g_phase := 'Updating Product assignment using Segment';
    If g_debug_flag = 'Y' then
	FII_UTIL.Write_Log(g_phase);
    End if;
   -----------------------------------------------------
   -- Product segment of the CCID records the product
   -- reporting classification
   -----------------------------------------------------
   l_stmt := 'UPDATE fii_gl_ccid_dimensions glcc
                 SET (glcc.product_id, glcc.PROD_CATEGORY_ID) =
                          (SELECT flx1.flex_value_id, mtc.category_id
                             FROM gl_code_combinations glccd,
                                  mtl_categories       mtc,
                                  fnd_id_flex_segments seg1,
                                  fnd_flex_values      flx1
                            WHERE glccd.code_combination_id = glcc.code_combination_id
                              AND mtc.structure_id = ' || g_mtc_structure_id || '
                              AND mtc.' || g_mtc_column_name || ' = glccd.' || p_product_seg || '
                              AND seg1.application_id = 101
                              AND seg1.id_flex_code   = ''GL#''
                              AND seg1.id_flex_num = ' || p_coa_id || '
                              AND seg1.application_column_name = ''' || p_product_seg || '''
                              AND glccd.' || p_product_seg || ' = flx1.flex_value
                              AND flx1.flex_value_set_id = seg1.flex_value_set_id)
               WHERE glcc.chart_of_accounts_id = ' || p_coa_id;

    If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('');
	  FII_UTIL.Write_Log(l_stmt);
      FII_UTIL.start_timer;
    End if;

   EXECUTE IMMEDIATE l_stmt;

   If g_debug_flag = 'Y' then
     FII_UTIL.Write_Log('Updated Product Assignments for ' || SQL%ROWCOUNT
                        || ' records in FII_GL_CCID_DIMENSIONS');
     FII_UTIL.stop_timer;
     FII_UTIL.print_timer('Duration');
   End if;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.USE_SEG');
   End if;

EXCEPTION

   WHEN OTHERS THEN
       rollback;
       g_retcode := -1;
       FII_UTIL.Write_Log('
-------------------------------------------
Error occured in Procedure: USE_SEG
Phase: ' || g_phase || ' Message: ' || sqlerrm);
       FII_MESSAGE.Func_Fail('FII_GL_CCID_C.USE_SEG');
       raise;

END USE_SEG;

-----------------------------------------------------
-- PROCEDURE USE_RANGES
-----------------------------------------------------
PROCEDURE USE_RANGES(p_coa_id IN NUMBER, p_product_seg IN VARCHAR2) IS

	l_duplicate_asgn NUMBER := 0;
	l_stmt           VARCHAR2(8000);
        l_coa_name       VARCHAR2(30);
        l_ccid           NUMBER;
        l_cat_name       VARCHAR2(240);

 CURSOR c_dup_prod_asgn IS
     SELECT code_combination_id, count(*) cnt
     FROM   fii_gl_ccid_prod_int
   GROUP BY code_combination_id
     HAVING count(*) > 1;

 CURSOR c_dup_prod_cat (p_ccid NUMBER) IS
     SELECT cat.description cat_name
       FROM fii_gl_ccid_prod_int  int,
            mtl_categories        cat
      WHERE int.code_combination_id = p_ccid
        AND int.prod_category_id    = cat.category_id;

BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.USE_RANGES');
   End if;

   g_phase := 'Populating FII_GL_CCID_PROD_INT';
    If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
    End if;

   ---------------------------------------------------
   -- Product mapping information is actually stored
   -- in FII_PRODUCT_ASSIGNMENTS table.
   -- We will first store the CCID, product mapping
   -- info in FII_GL_CCID_PROD_INT
   ---------------------------------------------------
     l_stmt := 'INSERT INTO FII_GL_CCID_PROD_INT (
 	  code_combination_id,
          prod_category_id,
          last_update_date,
          last_updated_by,
          creation_date,
          created_by,
          last_update_login)
 	SELECT
          glcc.code_combination_id,
          fipa.prod_category_id,
          sysdate,
          ' ||g_fii_user_id || ',
          sysdate,
          ' || g_fii_user_id || ',
          ' || g_fii_login_id || '
        FROM   gl_code_combinations    glcc,
               fii_product_assignments fipa
        WHERE  glcc.chart_of_accounts_id = :p_coa_id
        AND    fipa.chart_of_accounts_id = glcc.chart_of_accounts_id
        AND    fipa.PROD_CATEGORY_SET_ID = :G_PROD_CAT_SET_ID
        AND    NVL(glcc.segment1,1) >= NVL(fipa.segment1_low, NVL(glcc.segment1,1))
        AND    NVL(glcc.segment1,1) <= NVL(fipa.segment1_high, NVL(glcc.segment1,1))
        AND    NVL(glcc.segment2,1) >= NVL(fipa.segment2_low, NVL(glcc.segment2,1))
        AND    NVL(glcc.segment2,1) <= NVL(fipa.segment2_high, NVL(glcc.segment2,1))
        AND    NVL(glcc.segment3,1) >= NVL(fipa.segment3_low, NVL(glcc.segment3,1))
        AND    NVL(glcc.segment3,1) <= NVL(fipa.segment3_high, NVL(glcc.segment3,1))
        AND    NVL(glcc.segment4,1) >= NVL(fipa.segment4_low, NVL(glcc.segment4,1))
        AND    NVL(glcc.segment4,1) <= NVL(fipa.segment4_high, NVL(glcc.segment4,1))
        AND    NVL(glcc.segment5,1) >= NVL(fipa.segment5_low, NVL(glcc.segment5,1))
        AND    NVL(glcc.segment5,1) <= NVL(fipa.segment5_high, NVL(glcc.segment5,1))
        AND    NVL(glcc.segment6,1) >= NVL(fipa.segment6_low, NVL(glcc.segment6,1))
        AND    NVL(glcc.segment6,1) <= NVL(fipa.segment6_high, NVL(glcc.segment6,1))
        AND    NVL(glcc.segment7,1) >= NVL(fipa.segment7_low, NVL(glcc.segment7,1))
        AND    NVL(glcc.segment7,1) <= NVL(fipa.segment7_high, NVL(glcc.segment7,1))
        AND    NVL(glcc.segment8,1) >= NVL(fipa.segment8_low, NVL(glcc.segment8,1))
        AND    NVL(glcc.segment8,1) <= NVL(fipa.segment8_high, NVL(glcc.segment8,1))
        AND    NVL(glcc.segment9,1) >= NVL(fipa.segment9_low, NVL(glcc.segment9,1))
        AND    NVL(glcc.segment9,1) <= NVL(fipa.segment9_high, NVL(glcc.segment9,1))
        AND    NVL(glcc.segment10,1) >= NVL(fipa.segment10_low, NVL(glcc.segment10,1))
        AND    NVL(glcc.segment10,1) <= NVL(fipa.segment10_high, NVL(glcc.segment10,1))
        AND    NVL(glcc.segment11,1) >= NVL(fipa.segment11_low, NVL(glcc.segment11,1))
        AND    NVL(glcc.segment11,1) <= NVL(fipa.segment11_high, NVL(glcc.segment11,1))
        AND    NVL(glcc.segment12,1) >= NVL(fipa.segment12_low, NVL(glcc.segment12,1))
        AND    NVL(glcc.segment12,1) <= NVL(fipa.segment12_high, NVL(glcc.segment12,1))
        AND    NVL(glcc.segment13,1) >= NVL(fipa.segment13_low, NVL(glcc.segment13,1))
        AND    NVL(glcc.segment13,1) <= NVL(fipa.segment13_high, NVL(glcc.segment13,1))
        AND    NVL(glcc.segment14,1) >= NVL(fipa.segment14_low, NVL(glcc.segment14,1))
        AND    NVL(glcc.segment14,1) <= NVL(fipa.segment14_high, NVL(glcc.segment14,1))
        AND    NVL(glcc.segment15,1) >= NVL(fipa.segment15_low, NVL(glcc.segment15,1))
        AND    NVL(glcc.segment15,1) <= NVL(fipa.segment15_high, NVL(glcc.segment15,1))
        AND    NVL(glcc.segment16,1) >= NVL(fipa.segment16_low, NVL(glcc.segment16,1))
        AND    NVL(glcc.segment16,1) <= NVL(fipa.segment16_high, NVL(glcc.segment16,1))
        AND    NVL(glcc.segment17,1) >= NVL(fipa.segment17_low, NVL(glcc.segment17,1))
        AND    NVL(glcc.segment17,1) <= NVL(fipa.segment17_high, NVL(glcc.segment17,1))
        AND    NVL(glcc.segment18,1) >= NVL(fipa.segment18_low, NVL(glcc.segment18,1))
        AND    NVL(glcc.segment18,1) <= NVL(fipa.segment18_high, NVL(glcc.segment18,1))
        AND    NVL(glcc.segment19,1) >= NVL(fipa.segment19_low, NVL(glcc.segment19,1))
        AND    NVL(glcc.segment19,1) <= NVL(fipa.segment19_high, NVL(glcc.segment19,1))
        AND    NVL(glcc.segment20,1) >= NVL(fipa.segment20_low, NVL(glcc.segment20,1))
        AND    NVL(glcc.segment20,1) <= NVL(fipa.segment20_high, NVL(glcc.segment20,1))
        AND    NVL(glcc.segment21,1) >= NVL(fipa.segment21_low, NVL(glcc.segment21,1))
        AND    NVL(glcc.segment21,1) <= NVL(fipa.segment21_high, NVL(glcc.segment21,1))
        AND    NVL(glcc.segment22,1) >= NVL(fipa.segment22_low, NVL(glcc.segment22,1))
        AND    NVL(glcc.segment22,1) <= NVL(fipa.segment22_high, NVL(glcc.segment22,1))
        AND    NVL(glcc.segment23,1) >= NVL(fipa.segment23_low, NVL(glcc.segment23,1))
        AND    NVL(glcc.segment23,1) <= NVL(fipa.segment23_high, NVL(glcc.segment23,1))
        AND    NVL(glcc.segment24,1) >= NVL(fipa.segment24_low, NVL(glcc.segment24,1))
        AND    NVL(glcc.segment24,1) <= NVL(fipa.segment24_high, NVL(glcc.segment24,1))
        AND    NVL(glcc.segment25,1) >= NVL(fipa.segment25_low, NVL(glcc.segment25,1))
        AND    NVL(glcc.segment25,1) <= NVL(fipa.segment25_high, NVL(glcc.segment25,1))
        AND    NVL(glcc.segment26,1) >= NVL(fipa.segment26_low, NVL(glcc.segment26,1))
        AND    NVL(glcc.segment26,1) <= NVL(fipa.segment26_high, NVL(glcc.segment26,1))
        AND    NVL(glcc.segment27,1) >= NVL(fipa.segment27_low, NVL(glcc.segment27,1))
        AND    NVL(glcc.segment27,1) <= NVL(fipa.segment27_high, NVL(glcc.segment27,1))
        AND    NVL(glcc.segment28,1) >= NVL(fipa.segment28_low, NVL(glcc.segment28,1))
        AND    NVL(glcc.segment28,1) <= NVL(fipa.segment28_high, NVL(glcc.segment28,1))
        AND    NVL(glcc.segment29,1) >= NVL(fipa.segment29_low, NVL(glcc.segment29,1))
        AND    NVL(glcc.segment29,1) <= NVL(fipa.segment29_high, NVL(glcc.segment29,1))
        AND    NVL(glcc.segment30,1) >= NVL(fipa.segment30_low, NVL(glcc.segment30,1))
        AND    NVL(glcc.segment30,1) <= NVL(fipa.segment30_high, NVL(glcc.segment30,1))';


    If g_debug_flag = 'Y' then
	  FII_UTIL.Write_Log(l_stmt);
      FII_UTIL.start_timer;
    End if;

    EXECUTE IMMEDIATE l_stmt using p_coa_id, G_PROD_CAT_SET_ID;

    If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Inserted Product Assignments for ' || SQL%ROWCOUNT
                        || ' records in FII_GL_CCID_PROD_INT');
      FII_UTIL.stop_timer;
      FII_UTIL.print_timer('Duration');
    End if;

    ------------------------------------------------------------------
    -- Checking if single CCID assigned to multiple product categories
    ------------------------------------------------------------------
    g_phase := 'Checking if single CCID assigned to multiple product categories';
     If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log(g_phase);
     End if;


     For rec_dup_prod_asgn IN c_dup_prod_asgn Loop

       l_ccid := rec_dup_prod_asgn.code_combination_id;
       l_duplicate_asgn := l_duplicate_asgn + 1;

       IF (l_duplicate_asgn = 1) THEN

         l_coa_name := GET_COA_NAME (p_coa_id);

     FII_MESSAGE.write_log(
             msg_name    => 'FII_DUPLICATE_PROD_ASGN',
             token_num   => 1,
             t1          => 'COA_NAME',
         v1          => l_coa_name);

     FII_MESSAGE.write_log(
             msg_name    => 'FII_REFER_TO_OUTPUT',
             token_num   => 0);

       ----------------------------------------------------
       -- Print out translated message to let user know
       -- there are CCIDs with multiple product assignments
       ----------------------------------------------------
 	 FII_MESSAGE.write_output(
             msg_name    => 'FII_DUPLICATE_PROD_ASGN',
             token_num   => 1,
    	     t1          => 'COA_NAME',
 	     v1	         => l_coa_name);

 	 FII_MESSAGE.write_output(
             msg_name    => 'FII_DUP_PROD_ASGN_RPT_HDR',
             token_num   => 0);

       END IF;

       -------------------------------------------------------------
       --Print out the list of ccid with multiple product categories
       -------------------------------------------------------------
       For rec_dup_prod_cat IN c_dup_prod_cat (l_ccid) Loop
          l_cat_name := rec_dup_prod_cat.cat_name;
          FII_UTIL.Write_Output (l_ccid || '     ' || l_cat_name);
       End Loop;

     End Loop;

     If l_duplicate_asgn > 0 Then
       RAISE G_DUPLICATE_PROD_ASGN;
     End If;


   -------------------------------------------------------------
   -- Updating FII_GL_CCID_DIMENSIONS with product assignments information
   -------------------------------------------------------------
	g_phase := 'Updating FII_GL_CCID_DIMENSIONS to fix product assignments';
        If g_debug_flag = 'Y' then
   	   FII_UTIL.Write_Log(g_phase);
	   FII_UTIL.start_timer;
        End if;

	UPDATE fii_gl_ccid_dimensions glcc
	   SET glcc.PROD_CATEGORY_ID =
		(SELECT NVL(int.prod_category_id, glcc.prod_category_id)
		   FROM fii_gl_ccid_prod_int int
		  WHERE int.code_combination_id = glcc.code_combination_id
                  AND   glcc.chart_of_accounts_id = p_coa_id)
         WHERE glcc.chart_of_accounts_id = p_coa_id;

    If g_debug_flag = 'Y' then
	FII_UTIL.Write_Log('Updated Product Assignments for ' || SQL%ROWCOUNT
                          || ' records in FII_GL_CCID_DIMENSIONS');
    FII_UTIL.stop_timer;
    FII_UTIL.print_timer('Duration');
    End if;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.USE_RANGES');
   End if;

EXCEPTION

   WHEN G_DUPLICATE_PROD_ASGN THEN
	rollback;
	g_retcode := -1;
	FII_MESSAGE.Func_Fail('FII_GL_CCID_C.USE_RANGES');
        raise;

  WHEN OTHERS THEN
        rollback;
        g_retcode := -1;
        FII_UTIL.Write_Log('
--------------------------------------
Error occured in Procedure: USE_RANGES
Phase: ' || g_phase || '
Message: ' || sqlerrm);
	FII_MESSAGE.Func_Fail('FII_GL_CCID_C.USE_RANGES');
        raise;

END USE_RANGES;

-------------------------------------------------------
-- FUNCTION INVALID_PROD_CODE_EXIST
-------------------------------------------------------
FUNCTION INVALID_PROD_CODE_EXIST RETURN BOOLEAN IS

  l_count   NUMBER := 0;

BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.INVALID_PROD_CODE_EXIST');
   End if;

    g_phase := 'Check for invalid product code in FII_GL_CCID_DIMENSIONS';

   ---------------------------------------------------------------------
   -- This function is called after the product id, product category
   -- mapping information has been entered into FII_GL_CCID_DIMENSIONS
   -- table.  At this point, if PRODUCT_ID is populated but the
   -- the product category is not populated, then that would mean the
   -- the product code is invalid.  Every product code should be
   -- mapped to a product category
   --
   -- Note that this has no effect for multiple segment mapping since
   -- product_id is alway NULL
   ---------------------------------------------------------------------
   begin
	SELECT 1 INTO l_count
	  FROM fii_gl_ccid_dimensions
 	 WHERE PRODUCT_ID IS NOT NULL
	   AND PROD_CATEGORY_ID IS NULL
       AND rownum = 1;
   exception
    when NO_DATA_FOUND then
         l_count := 0;
   end;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.INVALID_PROD_CODE_EXIST');
   End if;

	IF l_count > 0 THEN
		RETURN TRUE;
	ELSE
		RETURN FALSE;
	END IF;

EXCEPTION
    WHEN OTHERS THEN
      g_retcode := -1;
      FII_UTIL.Write_Log('
------------------------
Error in Function: INVALID_PROD_CODE_EXIST
Phase: '||g_phase||'
Message: '||sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_CCID_C.INVALID_PROD_CODE_EXIST');
      raise;

END INVALID_PROD_CODE_EXIST;

-------------------------------------------------------
-- PROCEDURE MAINTAIN_PROD_ASSGN
-------------------------------------------------------
PROCEDURE MAINTAIN_PROD_ASSGN IS

   -------------------------------------------------
   -- This cursor loops through charts of account
   -- which contains new CCIDs as well as charts of
   -- accounts containing CCIDs with updated product
   -- assignments.  The cursor are ordered by coa_id.
   --------------------------------------------------
   CURSOR coa_list IS
    select coa_id,
           prod_seg,
           assignment_type_code,
           fact_resummarization_needed
      from (
       SELECT DISTINCT
         map.chart_of_accounts_id                           coa_id,
         NVL(map.application_column_name1,'NO_PROD_COLUMN') prod_seg,
 	 map.mapping_type_code                              assignment_type_code,
         'FALSE'                                            fact_resummarization_needed
       FROM  fii_gl_ccid_dimensions gcc,
             fii_dim_mapping_rules  map
       WHERE gcc.chart_of_accounts_id = map.chart_of_accounts_id
         AND map.dimension_short_name = g_dimension_name
         AND gcc.code_combination_id > g_max_ccid
      UNION ALL
       SELECT chart_of_accounts_id                           coa_id,
              NVL(application_column_name1,'NO_PROD_COLUMN') prod_seg,
              mapping_type_code                              assignment_type_code,
              'TRUE'                                         fact_resummarization_needed
        FROM fii_dim_mapping_rules
       WHERE dimension_short_name = g_dimension_name
         AND status_code = 'O')
     order by 1;

    l_resummarization_needed VARCHAR2(10) := 'FALSE';

    l_prod_seg        VARCHAR2(30);
    l_assignment_code VARCHAR2(1);
    l_coa_name        VARCHAR2(30);

    l_previous_coa_id NUMBER := 0;
    l_current_coa_id  NUMBER := 0;

BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.MAINTAIN_PROD_ASSGN');
   End if;

   g_phase := 'Maintain Product Assignment for CCIDs';
   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
   End if;

   -- Bug 4152799
   g_dimension_name := 'ENI_ITEM_VBH_CAT';
   FOR coa_rec IN coa_list LOOP

      ------------------------------------------------------
      -- If product assignment for existing CCID has changed,
      -- then the base summary would need to be truncated and
      -- repopulated again
      -------------------------------------------------------
      IF (coa_rec.fact_resummarization_needed = 'TRUE') THEN
 	l_resummarization_needed := 'TRUE';
      END IF;

      -----------------------------------------------------
      --If the current COA_ID is the same as the previous
      --one, then we skip this one and go to the next COA
      -----------------------------------------------------
      l_current_coa_id := coa_rec.coa_id;
      IF (l_current_coa_id = l_previous_coa_id) THEN
 	GOTO end_loop;
      END IF;

      l_prod_seg        := coa_rec.prod_seg;
      l_assignment_code := coa_rec.assignment_type_code;
      l_current_coa_id  := coa_rec.coa_id;
      If g_debug_flag = 'Y' then
	FII_UTIL.Write_Log('Maintaining Product Assignment for Chart of Accounts ID: '
                          || coa_rec.coa_id);
      End if;

      ---------------------------------------------------
      -- Check if the assignment type is 'Single Segment'
      -- If assignment type is 'Single Segment', then the
      -- product segment column name need to be defined
      -- in FII_DIM_MAPPING_RULES table
      ---------------------------------------------------
      IF (l_prod_seg = 'NO_PROD_COLUMN' AND l_assignment_code = 'S') THEN

         ---------------------------------------------
         -- Get the user name of the chart of accounts
         ---------------------------------------------
	 l_coa_name := GET_COA_NAME(coa_rec.coa_id);

	 FII_MESSAGE.write_log(
	                msg_name    => 'FII_COA_PROD_UNASSIGN',
			token_num   => 1,
			t1          => 'COA_NAME',
			v1	    => l_coa_name);

         ------------------------------------------------
         -- Print out translated message to let user know
         -- certain chart of accounts does not have
         -- product assignment defined in
         -- FII_DIM_MAPPING_RULES table
         -------------------------------------------------
	 FII_MESSAGE.write_output(
	                msg_name    => 'FII_COA_PROD_UNASSIGN',
			token_num   => 1,
			t1          => 'COA_NAME',
			v1	    => l_coa_name);

      	raise G_NO_PROD_SEG_DEFINED;
      END IF;

      ------------------------------------------------------
      -- Depending on what the product assignment type is.
      -- If 'S', then product reporting classification
      -- information is stored in the product segment of
      -- the CCID.  If type is 'R', then product reporting
      -- classification information is stored in table
      -- FII_PRODUCT_ASSIGNMENTS
      ------------------------------------------------------
      IF (l_assignment_code = 'S') THEN
         if g_mtc_column_name is NULL then
            FII_UTIL.Write_Log('Error in MAINTAIN_PROD_ASSGN: null g_mtc_column_name');
            raise G_NO_PROD_SEG_DEFINED;
         end if;

	 USE_SEG (coa_rec.coa_id, coa_rec.prod_seg);

      ELSIF (l_assignment_code = 'R') THEN

	 USE_RANGES (coa_rec.coa_id, coa_rec.prod_seg);

      END IF;

      ----------------------------------------------------------------
      -- After product code and product category information
      -- have been inserted into FII_GL_CCID_DIMENSIONS table
      -- we will verify if there's any case of 'Invalid Product ID'.
      -- This situtation is when a CCID has 'product ID' populated,
      -- but there's no corresponding category ID.  All valid
      -- product ID should be mapped to a category
      -- This is for single segment case only.
      ----------------------------------------------------------------
	IF (l_assignment_code = 'S' and INVALID_PROD_CODE_EXIST) THEN

	  FII_MESSAGE.write_log(
			msg_name	=> 'FII_INVALID_PROD_CODE_EXIST',
			token_num	=> 0);

          --------------------------------------------------
          -- Let user know there are invalid product code.
          -- Program will exit with error status immediately
          --------------------------------------------------
	  FII_MESSAGE.write_output(
			msg_name	=> 'FII_INVALID_PROD_CODE_EXIST',
			token_num	=> 0);

	  RAISE G_INVALID_PROD_CODE_EXIST;
	END IF;

		<<end_loop>>
	l_previous_coa_id := l_current_coa_id;

    END LOOP;

    IF (l_resummarization_needed = 'TRUE') THEN

      g_phase:= 'Updating FII_CHANGE_LOG to indicate resummarization is needed';
	If g_debug_flag = 'Y' then
	     FII_UTIL.Write_Log(g_phase);
	End if;

--Bug 3234044: should not require AP Resummarization --> remove AP_RESUMMARIZE
--Bug 3401590: use 2 new log items for GL, AR reload (initial)
      UPDATE FII_CHANGE_LOG
         SET item_value = 'Y',
		     last_update_date  = SYSDATE,
		     last_update_login = g_fii_login_id,
		     last_updated_by   = g_fii_user_id
       WHERE log_item IN ('AR_PROD_CHANGE', 'GL_PROD_CHANGE');

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_CHANGE_LOG');
   End if;

      g_phase:= 'Updating FII_DIM_MAPPING_RULES to indicate product assignments are now current';
      If g_debug_flag = 'Y' then
	FII_UTIL.Write_Log(g_phase);
      End if;

       -- Bug 4152799
       g_dimension_name := 'ENI_ITEM_VBH_CAT';

      UPDATE fii_dim_mapping_rules
         SET status_code = 'C',
             last_update_date = sysdate,
             last_update_login = g_fii_login_id,
             last_updated_by = g_fii_user_id
       WHERE dimension_short_name = g_dimension_name
         AND status_code = 'O';

      If g_debug_flag = 'Y' then
        FII_UTIL.Write_Log ('Updated ' || SQL%ROWCOUNT || ' records in FII_DIM_MAPPING_RULES');
      End if;
    END IF;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.MAINTAIN_PROD_ASSGN');
   End if;

EXCEPTION

   WHEN G_NO_PROD_SEG_DEFINED THEN
      g_retcode := -1;
      ROLLBACK;
      FII_UTIL.Write_Log('
---------------------------------------
Error occured in Procedure: MAINTAIN_PROD_ASSGN -> NO_PROD_SEG_DEFINED
Phase: '||g_phase||'
Message: '||sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_CCID_C.MAINTAIN_PROD_ASSGN');
      raise;

   WHEN G_INVALID_PROD_CODE_EXIST THEN
      g_retcode := -1;
      ROLLBACK;
      FII_UTIL.Write_Log('
---------------------------------------
Error occured in Procedure: MAINTAIN_PROD_ASSGN -> INVALID_PROD_CODE_EXIST
Phase: '||g_phase||'
Message: '||sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_CCID_C.MAINTAIN_PROD_ASSGN');
      raise;

   WHEN OTHERS THEN
      g_retcode := -1;
      rollback;
      FII_UTIL.Write_Log('
---------------------------------------
Error occured in Procedure: MAINTAIN_PROD_ASSGN
Phase: '||g_phase||'
Message: '||sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_CCID_C.MAINTAIN_PROD_ASSGN');
      raise;

END MAINTAIN_PROD_ASSGN;


--------------------------------------------------------
-- PROCEDURE INITIALIZE
--------------------------------------------------------
PROCEDURE INITIALIZE is
     l_status		VARCHAR2(30);
     l_industry		VARCHAR2(30);
     l_stmt             VARCHAR2(50);
     l_dir              VARCHAR2(400);
     l_old_prod_cat     NUMBER(15);
	 l_check		NUMBER;
	 l_vset_id	NUMBER(15);
	 l_ret_code	NUMBER;
BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.INITIALIZE');
   End if;

   ----------------------------------------------
   -- Do set up for log file
   ----------------------------------------------
   g_phase := 'Set up for log file';
       If g_debug_flag = 'Y' then
          FII_UTIL.Write_Log(g_phase);
       End if;

   l_dir := fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY');
   ------------------------------------------------------
   -- Set default directory in case if the profile option
   -- BIS_DEBUG_LOG_DIRECTORY is not set up
   ------------------------------------------------------
   if l_dir is NULL then
     l_dir := FII_UTIL.get_utl_file_dir ;
   end if;

   ----------------------------------------------------------------
   -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
   -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
   -- the log files and output files are written to
   ----------------------------------------------------------------
   FII_UTIL.initialize('FII_GL_CCID.log','FII_GL_CCID.out',l_dir, 'FII_GL_CCID_C');

   -- --------------------------------------------------------
   -- Check source ledger setup for DBI
   -- --------------------------------------------------------
	g_phase := 'Check source ledger setup for DBI';
	if g_debug_flag = 'Y' then
		FII_UTIL.write_log(g_phase);
	end if;

	l_check := FII_EXCEPTION_CHECK_PKG.check_slg_setup;

	if l_check <> 0 then
		RAISE G_NO_SLG_SETUP;
	end if;

   -- --------------------------------------------------------
   -- Find out the user ID, login ID, and current language
   -- --------------------------------------------------------
   g_phase := 'Find User ID, Login ID, and Current Language';
       If g_debug_flag = 'Y' then
	  FII_UTIL.Write_Log(g_phase);
       End if;

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
       If g_debug_flag = 'Y' then
          FII_UTIL.Write_Log(g_phase);
       End if;

   IF(FND_INSTALLATION.GET_APP_INFO('FII', l_status, l_industry, g_fii_schema))
        THEN NULL;
   END IF;

   -- --------------------------------------------------------
   -- Set the G_PROD_CAT_ENABLED_FLAG for product Category
   -- dimension to check if product Category
   -- dimension is enabled for DBI or not.
   -- Bug 3679295
   -- --------------------------------------------------------

    g_phase := 'Checking if product Category is enabled or not';

    If g_debug_flag = 'Y' then
          FII_UTIL.Write_Log(g_phase);
    End if;
    BEGIN
           -- Bug 4152799.
           g_dimension_name := 'ENI_ITEM_VBH_CAT';
           SELECT dbi_enabled_flag into G_PROD_CAT_ENABLED_FLAG
           FROM FII_FINANCIAL_DIMENSIONS
           WHERE dimension_short_name = g_dimension_name;

    EXCEPTION
     WHEN NO_DATA_FOUND THEN
      -- If the Product Category set up is not done then set the flag to 'N'
      FII_UTIL.Write_Log ('Set up for product category not done');
      G_PROD_CAT_ENABLED_FLAG := 'N';
    END;

    If g_debug_flag = 'Y' then
          FII_UTIL.Write_Log('G_PROD_CAT_ENABLED_FLAG = '||G_PROD_CAT_ENABLED_FLAG);
    End if;

	IF G_PROD_CAT_ENABLED_FLAG = 'Y' THEN
	   ------------------------------------------------------------
	   -- Call ENI's API to get default category set ID associated
	   -- with the product reporting classification structure then
	   -- get the structure ID associated with the category set
	   ------------------------------------------------------------
	   g_phase := 'Getting category set ID associated with product reporting classification structure';
	       If g_debug_flag = 'Y' then
	         FII_UTIL.Write_Log(g_phase);
	       End if;

		   begin
	          G_PROD_CAT_SET_ID := ENI_DENORM_HRCHY.get_category_set_id;
		   exception
		     when others then
   	           If g_debug_flag = 'Y' then
                 FII_UTIL.Write_Log('Error occured while: '|| g_phase);
                 FII_UTIL.Write_Log('The product category dimension is not set up properly.');
       	       End if;
	       end;

		    g_phase := 'Getting structure ID associated with the category set';
		    If g_debug_flag = 'Y' then
	               FII_UTIL.Write_Log(g_phase);
	            End if;

		begin
		    SELECT structure_id INTO g_mtc_structure_id
	  	    FROM mtl_category_sets_vl
		    WHERE category_set_id = g_prod_cat_set_id;
		exception
		  when others then
   	        If g_debug_flag = 'Y' then
              FII_UTIL.Write_Log('Error occured while: '|| g_phase);
              FII_UTIL.Write_Log('The product category dimension is not set up properly.');
       	    End if;
	    end;

	        g_phase := 'Getting value set ID associated with the product structure';
		    If g_debug_flag = 'Y' then
	               FII_UTIL.Write_Log(g_phase);
	            End if;

			begin
		        g_mtc_value_set_id := ENI_VALUESET_CATEGORY.GET_FLEX_VALUE_SET_ID
	                                     (P_APPL_ID       => 401,
	                                      P_ID_FLEX_CODE  => 'MCAT',
	                                      P_VBH_CATSET_ID => g_prod_cat_set_id);
			exception
			when others then
   		        If g_debug_flag = 'Y' then
        	      FII_UTIL.Write_Log('Error occured while: '|| g_phase);
                  FII_UTIL.Write_Log('The product category dimension is not set up properly.');
       	    	End if;
		    end;


	        g_phase := 'Getting segment name in MTL_CATEGORIES associated with product structure';
		    If g_debug_flag = 'Y' then
	               FII_UTIL.Write_Log(g_phase);
	            End if;

	        begin
	          --ENI just reports on the first enabled segment that is
	          --associated with the structure. So we get segment name as:
	          SELECT application_column_name into g_mtc_column_name
	            FROM
	             (select application_column_name
	                from fnd_id_flex_segments
	               where application_id    = 401
	                 and id_flex_code      = 'MCAT'
	                 and id_flex_num       = g_mtc_structure_id
	                 and flex_value_set_id = g_mtc_value_set_id
	                 and enabled_flag = 'Y'
	              order by to_number(substr(application_column_name, 8, 2)) ASC)
	          WHERE rownum = 1;
	        exception
	          when others then
	            FII_UTIL.Write_Log ('g_mtc_column_name is NULL');
	            g_mtc_column_name := NULL;
		    end;

	   ----------------------------------------------------------------------
	   --If the program is run in Incremental mode, check the last
	   --processed product category in FII_CHANGE_LOG with the current
	   --one G_PROD_CAT_SET_ID from ENI. If they are not same, error out
	   --with message asking user to either run the program in Initial mode;
	   --or revert the Product Catalog to the old one.
	   ----------------------------------------------------------------------
	   g_phase := 'Checking product category for incremental update...';
		If g_debug_flag = 'Y' then
		   FII_UTIL.Write_Log(g_phase);
		End if;

	   If g_mode <> 'L' then
	     begin

	       	-- Bug 4152799.
	        g_log_item := 'PROD_CAT_SET_ID';

	        SELECT item_value INTO l_old_prod_cat
	          FROM fii_change_log
	         WHERE log_item =  g_log_item;
	     exception
	        when others then
	          l_old_prod_cat := NULL;
	     end;
	     if l_old_prod_cat is not NULL and l_old_prod_cat <> G_PROD_CAT_SET_ID then
	       FII_MESSAGE.write_log(
	               msg_name    => 'FII_NEW_PROD_CAT_FOUND',
	               token_num   => 0);
	       FII_MESSAGE.write_output(
	               msg_name    => 'FII_NEW_PROD_CAT_FOUND',
	               token_num   => 0);
	       raise G_NEW_PROD_CAT_FOUND;
	     end if;
	   End If;

	END IF;

   -- ----------------------------------------------------------------
   -- Get the UNASSIGNED ID using the api in gl extraction util package
   -- -----------------------------------------------------------------
     g_phase := 'Find the shipped FII value set id';
        If g_debug_flag = 'Y' then
	   FII_UTIL.Write_Log(g_phase);
	End if;
     FII_GL_EXTRACTION_UTIL.get_unassigned_id(G_UNASSIGNED_ID, l_vset_id, l_ret_code);

      IF(l_ret_code = -1) THEN
        RAISE G_NO_UNASSIGNED_ID;
      END IF;

   -- --------------------------------------------------------
   -- Get the enabled flag for UDD1 and UDD2
   -- --------------------------------------------------------
    g_phase := 'Get the DBI Enabled flag for UDD1';
        If g_debug_flag = 'Y' then
	   FII_UTIL.Write_Log(g_phase);
	End if;
    BEGIN
     -- Bug 4152799.
     g_dimension_name := 'FII_USER_DEFINED_1';
     SELECT DBI_ENABLED_FLAG
          INTO G_UD1_ENABLED
          FROM FII_FINANCIAL_DIMENSIONS
         WHERE DIMENSION_SHORT_NAME = g_dimension_name;

     EXCEPTION
     WHEN NO_DATA_FOUND THEN
      -- If the User Defined Dimension1 set up is not done then set the flag to 'N'
      FII_UTIL.Write_Log ('Set up for User Defined Dimension1 not done');
      G_UD1_ENABLED := 'N';
    END;

     g_phase := 'Get the DBI Enabled flag for UDD2';

        If g_debug_flag = 'Y' then
	   FII_UTIL.Write_Log(g_phase);
	End if;

    BEGIN
     -- Bug 4152799.
     g_dimension_name := 'FII_USER_DEFINED_2';
     SELECT DBI_ENABLED_FLAG
          INTO G_UD2_ENABLED
          FROM FII_FINANCIAL_DIMENSIONS
         WHERE DIMENSION_SHORT_NAME = g_dimension_name;
     EXCEPTION
     WHEN NO_DATA_FOUND THEN
      -- If the User Defined Dimension2 set up is not done then set the flag to 'N'
      FII_UTIL.Write_Log ('Set up for User Defined Dimension2 not done');
      G_UD2_ENABLED := 'N';
    END;

    If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.INITIALIZE');
    End if;

EXCEPTION

  WHEN G_NO_SLG_SETUP THEN
	FII_UTIL.write_log ('No source ledger setup for DBI');
	g_retcode := -1;
	FII_MESSAGE.Func_Fail('FII_GL_CCID_C.INITIALIZE');
	raise;

  WHEN G_NO_UNASSIGNED_ID THEN
	FII_UTIL.write_log ('No UNASSIGNED ID');
	g_retcode := -1;
	FII_MESSAGE.Func_Fail('FII_GL_CCID_C.INITIALIZE');
	raise;

  WHEN G_LOGIN_INFO_NOT_AVABLE THEN
	FII_UTIL.Write_Log ('Can not get User ID and Login ID, program exit');
	g_retcode := -1;
	FII_MESSAGE.Func_Fail('FII_GL_CCID_C.INITIALIZE');
	raise;

  WHEN G_NEW_PROD_CAT_FOUND THEN
        FII_UTIL.Write_Log ('>>New product catalog is detected for incremental update');
        g_retcode := -1;
	FII_MESSAGE.Func_Fail('FII_GL_CCID_C.INITIALIZE');
        raise;

  WHEN OTHERS THEN
    	g_retcode := -1;
        FII_UTIL.Write_Log('
------------------------
Error in Procedure: INITIALIZE
Phase: '||g_phase||'
Message: '||sqlerrm);
	FII_MESSAGE.Func_Fail('FII_GL_CCID_C.INITIALIZE');
        raise;

END INITIALIZE;

-----------------------------------------------------------------
-- PROCEDURE DETECT_RELOAD
-----------------------------------------------------------------
PROCEDURE DETECT_RELOAD IS

  l_reload VARCHAR2(1);

BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.DETECT_RELOAD');
   End if;

   g_phase := 'Detect if reload is necessary';
   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log(g_phase);
   End if;

   -- Bug 4152799.
   g_log_item := 'CCID_RELOAD';
   SELECT item_value INTO l_reload
     FROM fii_change_log
    WHERE log_item = g_log_item;

    IF (l_reload = 'Y') THEN

      g_phase := 'Truncate CCID dimension';
      If g_debug_flag = 'Y' then
           FII_UTIL.Write_Log(g_phase);
      End if;

      FII_UTIL.TRUNCATE_TABLE ('FII_GL_CCID_DIMENSIONS', g_fii_schema, g_retcode);

      -------------------------------------------------------------------
      --Bug 3401590: should not update FII_DIM_MAPPING_RULES here
      --
      --**Update FII_DIM_MAPPING_RULES to force using product assignments
      --UPDATE fii_dim_mapping_rules
      --   SET status_code = 'O',
      --       last_update_date = sysdate,
      --       last_update_login = g_fii_login_id,
      --       last_updated_by = g_fii_user_id
      -- WHERE dimension_short_name = 'ENI_ITEM_VBH_CAT';
      -------------------------------------------------------------------

      g_phase := 'Reset max CCID processed to 0';
      If g_debug_flag = 'Y' then
	      FII_UTIL.Write_Log(g_phase);
      End if;

      -- Bug 4152799.
      g_log_item := 'MAX_CCID';

      UPDATE fii_change_log
      SET item_value = '0',
          last_update_date = sysdate,
          last_update_login = g_fii_login_id,
          last_updated_by = g_fii_user_id
      WHERE log_item = g_log_item;

      IF g_debug_flag = 'Y' THEN
         FII_UTIL.Write_Log(SQL%ROWCOUNT || ' record got updated');
      END IF;

      g_phase := 'Reset CCID_RELOAD to N';
      If g_debug_flag = 'Y' then
           FII_UTIL.Write_Log(g_phase);
      End if;

      -- Bug 4152799.
      g_log_item := 'CCID_RELOAD';

      UPDATE fii_change_log
      SET item_value = 'N',
          last_update_date = sysdate,
          last_update_login = g_fii_login_id,
          last_updated_by = g_fii_user_id
      WHERE log_item = g_log_item;

      IF g_debug_flag = 'Y' THEN
	FII_UTIL.Write_Log(SQL%ROWCOUNT || ' record got updated');
      END IF;

    ELSE
      If g_debug_flag = 'Y' then
	 FII_UTIL.Write_Log('No reload is necessary');
      End if;
    END IF;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.DETECT_RELOAD');
   End if;

EXCEPTION
   WHEN OTHERS THEN
      g_retcode := -1;
      FII_UTIL.Write_Log('
-----------------------------
Error occured in Procedure: DETECT_RELOAD
Phase: ' || g_phase || '
Message: ' || sqlerrm);
      FII_MESSAGE.Func_Fail('FII_GL_CCID_C.DETECT_RELOAD');
      raise;
END DETECT_RELOAD;

-----------------------------------------------------------------
-- PROCEDURE MAIN
-----------------------------------------------------------------
PROCEDURE Main (errbuf             IN OUT  NOCOPY VARCHAR2 ,
                retcode            IN OUT  NOCOPY VARCHAR2,
                pmode              IN   VARCHAR2) IS

  ret_val     BOOLEAN := FALSE;

BEGIN

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_GL_CCID_C.Main');
   End if;

    errbuf := NULL;
    retcode := 0;
    g_retcode := 0;
    g_mode := pmode;

    if (g_mode = 'L') then

    g_phase := 'alter session enable';

	execute immediate 'alter session enable parallel dml';
	execute immediate 'alter session enable parallel query';
    end if;

    ---------------------------------------------------
    -- Initialize all global variables from profile
    -- options and other resources
    ---------------------------------------------------
    g_phase := 'Call INITIALIZE';

    INITIALIZE;

    ---------------------------------------------------
    -- Clean up temporary tables used by the program
    ---------------------------------------------------
    FII_UTIL.TRUNCATE_TABLE ('FII_GL_CCID_PROD_INT', g_fii_schema, g_retcode);

    ---------------------------------------------------
    -- Inserting the basic items into FII_CHANGE_LOG if
    -- they have not been inserted
    ---------------------------------------------------
    g_phase := 'Call INIT_DBI_CHANGE_LOG';

    INIT_DBI_CHANGE_LOG;

    ---------------------------------------------------
    -- Populate the global temp table FII_CCID_SLG_GT
    ---------------------------------------------------
    g_phase := 'Call POPULATE_SLG_TMP';

    POPULATE_SLG_TMP;

    ---------------------------------------------------
    -- Check if program is called in Initial mode
    ---------------------------------------------------
    if (g_mode = 'L') then

      NULL;

    ELSE

    ----------------------------------------------------
    -- Detect if there's changes in fii_slg_assignments
    -- table.  If yes, then truncate CCID dimension and
    -- reset the max CCID processed to 0
    -----------------------------------------------------
      g_phase := 'Call DETECT_RELOAD';

      DETECT_RELOAD;

    END IF;

    ----------------------------------------------------
    -- Find out what are the new CCIDs to process and
    -- insert these new CCIDs into FII_GL_CCID_DIMENSIONS
    -- table
    -----------------------------------------------------
    g_phase := 'Call INSERT_NEW_CCID';

    INSERT_NEW_CCID;

    ----------------------------------------------------
    -- Update FII_GL_CCID_DIMENSIONS table with Product
    -- assignment information for each CCID
    ----------------------------------------------------
    g_phase := 'Call MAINTAIN_PROD_ASSGN';

    --Bug 3679295. Check if the Product Category Dimension is enabled or not.
    IF (G_PROD_CAT_ENABLED_FLAG = 'Y') THEN
         MAINTAIN_PROD_ASSGN;
    END IF;

        -----------------------------------------------------
    -- Enh 3985835. Callout to FII_CCID_CALLOUT.UPDATE_FC
    -----------------------------------------------------
    g_phase := 'Call FII_CCID_CALLOUT.UPDATE_FC';
    FII_CCID_CALLOUT.UPDATE_FC(g_max_ccid, g_new_max_ccid);

    ----------------------------------------------------
    -- Set CCID_RELOAD flag to 'N' after an initial load
    -- Bug 3401590
    ----------------------------------------------------
    if (g_mode = 'L') then
      g_phase := 'UPDATE fii_change_log';

      -- Bug 4152799.
      g_log_item := 'CCID_RELOAD';

      UPDATE fii_change_log
      SET item_value = 'N',
          last_update_date = sysdate,
          last_update_login = g_fii_login_id,
          last_updated_by = g_fii_user_id
      WHERE log_item = g_log_item
        AND item_value = 'Y';

   If g_debug_flag = 'Y' then
      FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in fii_change_log');
   End if;

    end if;

    ---------------------------------------------------
    -- Clean up temporary tables before exit
    ---------------------------------------------------
    g_phase := 'TRUNCATE FII_GL_CCID_PROD_INT';

    FII_UTIL.TRUNCATE_TABLE ('FII_GL_CCID_PROD_INT', g_fii_schema, g_retcode);

    ------------------------------------------------------
    -- We have finished the data processing for CCID table
    -- it is a logical point to commit.
    ------------------------------------------------------
	COMMIT;

    if (g_mode = 'L') then

    g_phase := 'alter session disable';

	execute immediate 'alter session disable parallel dml';
	execute immediate 'alter session disable parallel query';
    end if;

	retcode := g_retcode;

   If g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_GL_CCID_C.Main');
   End if;

EXCEPTION
  WHEN OTHERS THEN
	rollback;

        FII_UTIL.Write_Log('
-----------------------------
Error occured in Procedure: MAIN
Phase: ' || g_phase || '
Message: ' || sqlerrm);

	FII_MESSAGE.Func_Fail('FII_GL_CCID_C.Main');

	retcode := g_retcode;
        ret_val := FND_CONCURRENT.Set_Completion_Status
                        (status  => 'ERROR', message => substr(sqlerrm,1,180));
END MAIN;

END FII_GL_CCID_C;

/
