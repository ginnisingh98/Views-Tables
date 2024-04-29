--------------------------------------------------------
--  DDL for Package Body FII_LOB_MAINTAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_LOB_MAINTAIN_PKG" AS
/* $Header: FIILBCMB.pls 120.2 2006/02/06 20:16:04 vkazhipu noship $  */

        G_MASTER_VALUE_SET_ID  NUMBER(15)      := NULL;
        G_TOP_NODE_ID          NUMBER(15)      := NULL;
        G_TOP_NODE_VALUE       VARCHAR2(240)   := NULL;
        G_LOB_DBI50_SETUP      VARCHAR2(1)     := 'N';
        G_UNASSIGNED_LOB_ID    NUMBER(15);
        G_FII_INT_VALUE_SET_ID NUMBER(15);
        G_PHASE                VARCHAR2(120);
        G_DBI_ENABLED_FLAG     VARCHAR2(1);

        g_schema_name          VARCHAR2(120)   := 'FII';
        g_retcode              VARCHAR2(20)    := NULL;
        g_debug_mode           VARCHAR2(1)
                     := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

	g_index      NUMBER(10) :=0;
-- *****************************************************************
-- Check if a value set is table validated

  FUNCTION  Is_Table_Validated (X_Vs_Id	NUMBER) RETURN BOOLEAN IS
    l_tab_name	VARCHAR2(240) := NULL;

  BEGIN

    --FII_MESSAGE.Func_Ent (func_name => 'Is_Table_Validated');

    -- Execute statement to determine if the value set is table validated
    BEGIN

      SELECT fvt.application_table_name INTO  l_tab_name
      FROM   fnd_flex_validation_tables fvt,
             fnd_flex_value_sets fvs
      WHERE  fvs.flex_value_set_id = X_vs_id
      AND    fvs.validation_type = 'F'
      AND    fvt.flex_value_set_id = fvs.flex_value_set_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return FALSE;
    END;

    --FII_MESSAGE.Func_Succ (func_name => 'Is_Table_Validated');

    RETURN TRUE;

  EXCEPTION
    WHEN OTHERS THEN
       RETURN FALSE;

  END Is_Table_Validated;

-- *******************************************************************
--   Function Get_Value_Set_Name

  Function Get_Value_Set_Name (p_vs_id  NUMBER) RETURN VARCHAR2 IS
    l_vs_name varchar2(120);

  Begin

    -- if FIIDIM_Debug then
    --   FII_MESSAGE.Func_Ent (func_name => 'Get_Value_Set_Name');
    -- end if;

     select flex_value_set_name into l_vs_name
     from fnd_flex_value_sets
     where flex_value_set_id = p_vs_id;

    -- if FIIDIM_Debug then
    --   FII_MESSAGE.Func_Succ (func_name => 'Get_Value_Set_Name');
    -- end if;

     return l_vs_name;

  Exception
    when others then
        FII_UTIL.Write_Log (
               'Unexpected error when calling Get_Value_Set_Name...');
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,80));
	FII_UTIL.Write_Log ('Value Set ID: ' || p_vs_id);
        RAISE;

  End  Get_Value_Set_Name;

-- *******************************************************************
--   Function Get_Flex_Value

  Function Get_Flex_Value (p_flex_value_id  NUMBER) RETURN VARCHAR2 IS
    l_flex_value varchar2(120);

  Begin

    -- if FIIDIM_Debug then
    --   FII_MESSAGE.Func_Ent (func_name => 'Get_Flex_Value');
    -- end if;

     select flex_value into l_flex_value
     from fnd_flex_values
     where flex_value_id = p_flex_value_id;

    -- if FIIDIM_Debug then
    --   FII_MESSAGE.Func_Succ (func_name => 'Get_Flex_Value');
    -- end if;

     return l_flex_value;

  Exception
    when others then
        FII_UTIL.Write_Log (
               'Unexpected error when calling Get_Flex_Value...');
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,80));
	FII_UTIL.Write_Log ('Value ID: ' || p_flex_value_id);
        RAISE;

  End  Get_Flex_Value;

-- *******************************************************************
--   Initialize (get the master value set and the top node)

   PROCEDURE Initialize  IS

     l_count      NUMBER(15) := 0;
     l_dir        VARCHAR2(160);
	 l_check      NUMBER;
	 l_bool_ret   BOOLEAN;

   BEGIN

     g_phase := 'Do set up for log file';
     ----------------------------------------------
     -- Do set up for log file
     ----------------------------------------------

     l_dir := fnd_profile.value('BIS_DEBUG_LOG_DIRECTORY');
     ------------------------------------------------------
     -- Set default directory in case if the profile option
     -- BIS_DEBUG_LOG_DIRECTORY is not set up
     ------------------------------------------------------
     if l_dir is NULL then
       l_dir := FII_UTIL.get_utl_file_dir;
     end if;

     ----------------------------------------------------------------
     -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
     -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
     -- the log files and output files are written to
     ----------------------------------------------------------------
     FII_UTIL.initialize('FII_LOB_MAINTAIN_PKG.log',
                         'FII_LOB_MAINTAIN_PKG.out',l_dir, 'FII_LOB_MAINTAIN_PKG');

     -- --------------------------------------------------------
     -- Check source ledger setup for DBI
     -- --------------------------------------------------------
     g_phase := 'Check source ledger setup for DBI';

     l_check := FII_EXCEPTION_CHECK_PKG.check_slg_setup;

     if l_check <> 0 then
        FII_UTIL.write_log('>>> No source ledger setup for DBI');
        RAISE LOBDIM_fatal_err;
     end if;

     -- --------------------------------------------------------
     -- Detect unmapped local value set
     -- --------------------------------------------------------
     g_phase := 'Detect unmapped local value set';

     l_check := FII_EXCEPTION_CHECK_PKG.detect_unmapped_local_vs('FII_LOB');

     if l_check > 0 then
        l_bool_ret := FND_CONCURRENT.Set_Completion_Status(
				status  => 'WARNING',
				message => 'Detected unmapped local value set.'
		);
     elsif l_check < 0 then
        RAISE LOBDIM_fatal_err;
     end if;

     g_phase := 'Obtain FII schema name and other info';

     -- Obtain FII schema name
     g_schema_name := FII_UTIL.get_schema_name ('FII');

     -- Obtain user ID, login ID and initialize package variables
     FII_USER_ID 	:= FND_GLOBAL.USER_ID;
     FII_LOGIN_ID	:= FND_GLOBAL.LOGIN_ID;

     -- If any of the above values is not set, error out
     IF (FII_User_Id is NULL OR FII_Login_Id is NULL) THEN
       FII_UTIL.Write_Log ('>>> Failed Intialization');
       RAISE LOBDIM_fatal_err;
     END IF;

     -- Determine if process will be run in debug mode
     IF (NVL(G_Debug_Mode, 'N') <> 'N') THEN
       FIIDIM_Debug := TRUE;
       FII_UTIL.Write_Log ('Debug On');
     ELSE
       FIIDIM_Debug := FALSE;
       FII_UTIL.Write_Log ('Debug Off');
     END IF;

     -- Turn trace on if process is run in debug mode
     IF (FIIDIM_Debug) THEN
       -- Program running in debug mode, turning trace on
       EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';
       FII_UTIL.Write_Log ('Initialize: Set Trace On');
     END IF;

     IF (FIIDIM_Debug) THEN
       FII_UTIL.Write_Log ('Initialize: Now start processing '|| 'LOB dimension');
     End If;

     -- Check if we should use old DBI 5.0 LOB model
     --changed by vkazhipu for bug 4992496 related to performance tuning
     begin
      -- SELECT count(*) INTO l_count
      -- FROM fii_lob_assignments;
      select 1 into l_count from fii_lob_assignments where rownum=1;
     exception
       when others then
            l_count := 0;
     end;

     if l_count > 0 then
       G_LOB_DBI50_SETUP := 'Y';
       FII_UTIL.Write_Log ('Use DBI 5.0 LOB assignment: Master Value Set Only');
     end if;
     ------------------------------------------------

     -- --------------------------------------------------------
     -- Find the unassigned LOB ID
     -- --------------------------------------------------------

     g_phase := 'Find the shipped FII value set id';
     select FLEX_VALUE_SET_ID into G_FII_INT_VALUE_SET_ID
     from fnd_flex_value_sets
     where flex_value_set_name = 'Financials Intelligence Internal Value Set';

     g_phase := 'Find the unassigned LOB ID from value set: '||G_FII_INT_VALUE_SET_ID;
     select flex_value_id  into G_UNASSIGNED_LOB_ID
     from fnd_flex_values
     where flex_value_set_id = G_FII_INT_VALUE_SET_ID
       and flex_value = 'UNASSIGNED';

     -- --------------------------------------------------------
     -- Get the master value set and top node for LOB
     -- --------------------------------------------------------

     g_phase := 'Get the master value set and top node for LOB';
     Begin

        SELECT MASTER_VALUE_SET_ID, DBI_HIER_TOP_NODE,
               DBI_HIER_TOP_NODE_ID,
               DBI_ENABLED_FLAG
          INTO G_MASTER_VALUE_SET_ID, G_TOP_NODE_VALUE,
               G_TOP_NODE_ID, G_DBI_ENABLED_FLAG
          FROM FII_FINANCIAL_DIMENSIONS
         WHERE DIMENSION_SHORT_NAME = 'FII_LOB';

        --If the LOB dimension is not enabled, raise an exception.
        --Note that we will insert 'UNASSIGNED' to the dimension
        IF NVL(G_DBI_ENABLED_FLAG, 'N') <> 'Y' then
          RAISE LOBDIM_NOT_ENABLED;
        END IF;

        --If the master value is not set up, raise an exception
        IF G_MASTER_VALUE_SET_ID is NULL THEN
          FII_MESSAGE.write_log (msg_name   => 'FII_MSTR_VSET_NOT_FOUND',
	                            token_num  => 0);
          FII_MESSAGE.write_output (msg_name   => 'FII_MSTR_VSET_NOT_FOUND',
	                            token_num  => 0);
          RAISE LOBDIM_fatal_err;
        --If the top node is not set up, raise an exception
        ELSIF G_TOP_NODE_ID is NULL OR G_TOP_NODE_VALUE is NULL THEN
          FII_MESSAGE.write_log (msg_name   => 'FII_MSTR_TNODE_NOT_FOUND',
	                            token_num  => 0);
          FII_MESSAGE.write_output (msg_name   => 'FII_MSTR_TNODE_NOT_FOUND',
	                            token_num  => 0);
          RAISE LOBDIM_fatal_err;
        END IF;

      Exception
        When NO_DATA_FOUND Then
          FII_MESSAGE.write_log (msg_name   => 'FII_MSTR_VSET_NOT_FOUND',
	                            token_num  => 0);
          FII_MESSAGE.write_output (msg_name   => 'FII_MSTR_VSET_NOT_FOUND',
	                            token_num  => 0);
          RAISE LOBDIM_fatal_err;
        When TOO_MANY_ROWS Then
          FII_UTIL.Write_Log ('More than one master value set found for LOB Dimension');
          RAISE LOBDIM_fatal_err;
        When LOBDIM_NOT_ENABLED then
           raise;
        When LOBDIM_fatal_err then
           raise;
        When OTHERS Then
          FII_UTIL.Write_Log ('Unexpected error when getting master value set for LOB Dimension');
	  FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
          RAISE LOBDIM_fatal_err;
     End;

     IF (FIIDIM_Debug) THEN
       FII_UTIL.Write_Log ('LOB Master Value Set ID: '|| G_MASTER_VALUE_SET_ID);
       FII_UTIL.Write_Log ('LOB Master Value Set: '||
                         Get_Value_Set_Name (G_MASTER_VALUE_SET_ID));
       FII_UTIL.Write_Log ('       and LOB Top Node: '|| G_TOP_NODE_VALUE);
     END IF;


     -- Check if the master value set is a table validated set.
     g_phase := 'Check if the master value set is a table validated set';

      If  Is_Table_Validated (G_MASTER_VALUE_SET_ID) Then
        FII_MESSAGE.write_log (msg_name   => 'FII_TBL_VALIDATED_VSET',
                 	          token_num  => 1,
                                  t1         => 'VS_NAME',
			          v1 	     => Get_Value_Set_Name (G_MASTER_VALUE_SET_ID));
        FII_MESSAGE.write_output (msg_name   => 'FII_TBL_VALIDATED_VSET',
                 	          token_num  => 1,
                                  t1         => 'VS_NAME',
			          v1 	     => Get_Value_Set_Name (G_MASTER_VALUE_SET_ID));
	RAISE LOBDIM_fatal_err;
      End If;

     -- --------------------------------------------------------
     --Need to lock all related value sets here (???)
     -- --------------------------------------------------------

   Exception

     When LOBDIM_NOT_ENABLED then
       FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
       --Let the main program handle this
       raise;

     When LOBDIM_fatal_err then
       FII_UTIL.Write_Log ('FII_LOB_MAINTAIN_PKG.Initialize : '|| 'User defined error');
       FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name => 'FII_LOB_MAINTAIN_PKG.Initialize');
       raise;

     When others then
        FII_UTIL.Write_Log ('Unexpected error when calling Initialize...');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
        RAISE;

   END Initialize;


-- *******************************************************************
--   Populate the table FII_DIM_NORM_HIER_GT

   PROCEDURE Get_NORM_HIERARCHY_TMP  IS

    Cursor all_local_value_sets IS
      select distinct child_flex_value_set_id
        from FII_DIM_NORM_HIERARCHY
       where parent_flex_value_set_id = G_MASTER_VALUE_SET_ID
         and parent_flex_value_set_id <> child_flex_value_set_id
         and child_flex_value_set_id IN
          (select map.flex_value_set_id1
             from fii_dim_mapping_rules    map,
                  fii_slg_assignments      sts,
                  fii_source_ledger_groups slg
            where map.dimension_short_name   = 'FII_LOB'
              and map.chart_of_accounts_id   = sts.chart_of_accounts_id
              and sts.source_ledger_group_id = slg.source_ledger_group_id
              and slg.usage_code = 'DBI');

     l_vset_id  NUMBER(15);

   BEGIN

     IF (FIIDIM_Debug) THEN
		 FII_MESSAGE.Func_Ent ('FII_LOB_MAINTAIN_PKG.Get_NORM_HIERARCHY_TMP');
     END IF;

     --First, insert records for the master value set
     g_phase := 'insert records for the master value set';

     Insert into FII_DIM_NORM_HIER_GT (
        PARENT_FLEX_VALUE_SET_ID,
        PARENT_FLEX_VALUE,
        RANGE_ATTRIBUTE,
        CHILD_FLEX_VALUE_SET_ID,
        CHILD_FLEX_VALUE_LOW,
        CHILD_FLEX_VALUE_HIGH)
     Select
        FLEX_VALUE_SET_ID,
        PARENT_FLEX_VALUE,
        RANGE_ATTRIBUTE,
        FLEX_VALUE_SET_ID,
        CHILD_FLEX_VALUE_LOW,
        CHILD_FLEX_VALUE_HIGH
     From  FND_FLEX_VALUE_NORM_HIERARCHY
     Where flex_value_set_id = G_MASTER_VALUE_SET_ID;

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_DIM_NORM_HIER_GT');
     END IF;

    -- For DBI 5.0 customers, use the master value set only
    -- For DBI 6.0, need to get all child value sets
    IF G_LOB_DBI50_SETUP <> 'Y' THEN

     --Copy table FII_DIM_NORM_HIERARCHY for parent-child valuesets relation
     g_phase := 'Copy FII_DIM_NORM_HIERARCHY for parent-child valuesets relation';

     Insert into FII_DIM_NORM_HIER_GT (
        PARENT_FLEX_VALUE_SET_ID,
        PARENT_FLEX_VALUE,
        RANGE_ATTRIBUTE,
        CHILD_FLEX_VALUE_SET_ID,
        CHILD_FLEX_VALUE_LOW,
        CHILD_FLEX_VALUE_HIGH)
     Select
        PARENT_FLEX_VALUE_SET_ID,
        PARENT_FLEX_VALUE,
        RANGE_ATTRIBUTE,
        CHILD_FLEX_VALUE_SET_ID,
        CHILD_FLEX_VALUE_LOW,
        CHILD_FLEX_VALUE_HIGH
     From FII_DIM_NORM_HIERARCHY
     Where PARENT_FLEX_VALUE_SET_ID <> CHILD_FLEX_VALUE_SET_ID
     AND PARENT_FLEX_VALUE_SET_ID = G_MASTER_VALUE_SET_ID -- Bug 4018002. Multiple dimensions may have same LVS.
     And   CHILD_FLEX_VALUE_SET_ID IN
          (select map.flex_value_set_id1
             from fii_dim_mapping_rules    map,
                  fii_slg_assignments      sts,
                  fii_source_ledger_groups slg
            where map.dimension_short_name   = 'FII_LOB'
              and map.chart_of_accounts_id   = sts.chart_of_accounts_id
              and sts.source_ledger_group_id = slg.source_ledger_group_id
              and slg.usage_code = 'DBI');

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_DIM_NORM_HIER_GT');
     END IF;

     --Insert records for all local (child) value sets
     g_phase := 'Insert records for all local (child) value sets';

     FOR vset_rec IN all_local_value_sets LOOP

      l_vset_id := vset_rec.child_flex_value_set_id;

      -- Check if the (child) value set is a table validated set.
      If  Is_Table_Validated (l_vset_id) Then
        FII_MESSAGE.write_log (msg_name   => 'FII_TBL_VALIDATED_VSET',
                 	          token_num  => 1,
                                  t1         => 'VS_NAME',
			          v1 	     => Get_Value_Set_Name (l_vset_id));
        FII_MESSAGE.write_output (msg_name   => 'FII_TBL_VALIDATED_VSET',
                 	          token_num  => 1,
                                  t1         => 'VS_NAME',
			          v1 	     => Get_Value_Set_Name (l_vset_id));
	RAISE LOBDIM_fatal_err;
      End If;

      g_phase := 'Insert records for local value set ' || l_vset_id;

      Insert into FII_DIM_NORM_HIER_GT (
         PARENT_FLEX_VALUE_SET_ID,
         PARENT_FLEX_VALUE,
         RANGE_ATTRIBUTE,
         CHILD_FLEX_VALUE_SET_ID,
         CHILD_FLEX_VALUE_LOW,
         CHILD_FLEX_VALUE_HIGH)
      Select
         FLEX_VALUE_SET_ID,
         PARENT_FLEX_VALUE,
         RANGE_ATTRIBUTE,
         FLEX_VALUE_SET_ID,
         CHILD_FLEX_VALUE_LOW,
         CHILD_FLEX_VALUE_HIGH
      From  FND_FLEX_VALUE_NORM_HIERARCHY
      Where flex_value_set_id = l_vset_id;

     END LOOP;

    END IF;

     IF (FIIDIM_Debug) THEN
		 FII_MESSAGE.Func_Succ ('FII_LOB_MAINTAIN_PKG.Get_NORM_HIERARCHY_TMP');
     END IF;

   Exception

     When LOBDIM_fatal_err then
       FII_UTIL.Write_Log ('FII_LOB_MAINTAIN_PKG.Get_NORM_HIERARCHY_TMP: '||
                         'User defined error');
       FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name => 'FII_LOB_MAINTAIN_PKG.Get_NORM_HIERARCHY_TMP');
       raise;

     When others then
        FII_UTIL.Write_Log ('Unexpected error when calling Get_NORM_HIERARCHY_TMP.');
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        RAISE;

   END Get_NORM_HIERARCHY_TMP;


-- **************************************************************************
-- This procedure will check for child value multiple assignments
-- to different parents within FII_LOB_HIER_GT (the TMP hierarchy table)

   PROCEDURE Detect_Diamond_Shape IS

   --The first cursor is to find all flex_value_id which has multiple parents;
   --we look at records such as (P1,A,A) and (P2,A,A)
     Cursor Dup_Assg_Cur IS
         SELECT count(parent_lob_id) parents,
                child_lob_id         flex_value_id
           FROM FII_LOB_HIER_GT
          WHERE next_level_lob_id = child_lob_id
            AND parent_level      = next_level - 1
       GROUP BY child_lob_id
         HAVING count(parent_lob_id) > 1;

   --The second cursor is to print out the list of duplicate parents;
   --again, we get records such as (P1,A,A),(P2,A,A) to print out P1, P2 for A
     Cursor Dup_Assg_Parent_Cur (p_child_value_id NUMBER) IS
         SELECT parent_lob_id,
                parent_flex_value_set_id,
                child_lob_id,
                child_flex_value_set_id
           FROM  FII_LOB_HIER_GT
          WHERE child_lob_id      = p_child_value_id
            AND next_level_lob_id = child_lob_id
            AND parent_level      = next_level - 1;

     l_count                NUMBER(15):=0;
     l_flex_value           VARCHAR2(120);
     l_vset_name            VARCHAR2(240);
     l_parent_flex_value    VARCHAR2(120);
     l_parent_vset_name     VARCHAR2(240);

   BEGIN

     IF (FIIDIM_Debug) THEN
		 FII_MESSAGE.Func_Ent ('FII_LOB_MAINTAIN_PKG.Detect_Diamond_Shape');
     END IF;

     -- check whole TMP hierarhy table: if there is a diamond
     -- report and raise an exception
     g_phase := 'check all value sets for diamonds';

     FOR dup_asg_rec IN Dup_Assg_Cur LOOP

       l_count := l_count + 1;
       if l_count = 1 then

         FII_MESSAGE.write_log(msg_name   => 'FII_DMND_SHAPE_VS_EXIST',
				   token_num  => 0);
         FII_MESSAGE.write_log(msg_name   => 'FII_REFER_TO_OUTPUT',
				   token_num  => 0);

         FII_MESSAGE.write_output (msg_name   => 'FII_DMND_SHAPE_VS_EXIST',
				   token_num  => 0);
         FII_MESSAGE.write_output (msg_name   => 'FII_DMND_SHAPE_VS_TAB',
				   token_num  => 0);

       end if;

       FOR dup_asg_par_rec IN Dup_Assg_Parent_Cur (dup_asg_rec.flex_value_id ) LOOP

        l_flex_value       := Get_Flex_Value (dup_asg_par_rec.child_lob_id);
        l_vset_name        := Get_Value_Set_Name (dup_asg_par_rec.child_flex_value_set_id);
        l_parent_flex_value:= Get_Flex_Value (dup_asg_par_rec.parent_lob_id);
        l_parent_vset_name := Get_Value_Set_Name (dup_asg_par_rec.parent_flex_value_set_id);

         FII_UTIL.Write_Output (
                           l_flex_value                           || '   '||
                           l_vset_name                            || '   '||
                           l_parent_flex_value                    || '   '||
                           l_parent_vset_name);

       END LOOP;

    END LOOP;

    IF (FIIDIM_Debug) THEN
		FII_MESSAGE.Func_Succ ('FII_LOB_MAINTAIN_PKG.Detect_Diamond_Shape');
    END IF;

    IF l_count > 0 THEN
      RAISE LOBDIM_MULT_PAR_err;
    END IF;

   Exception

     When LOBDIM_MULT_PAR_err then
       FII_UTIL.Write_Log ('FII_LOB_MAINTAIN_PKG.Detect_Diamond_Shape: '||
                         'diamond shape detected!');
       RAISE;

     When others then
        FII_UTIL.Write_Log ('Unexpected error when calling Detect_Diamond_Shape.');
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        RAISE;

   END Detect_Diamond_Shape;

-- *******************************************************************

   PROCEDURE INSERT_IMM_CHILD_NODES
                    (p_vset_id NUMBER, p_root_node VARCHAR2) IS

     CURSOR direct_children_csr (p_parent_vs_id NUMBER, p_parent_node VARCHAR2) IS
       SELECT ffv.flex_value_id, ffv.flex_value, ffv.flex_value_set_id
       FROM   FII_DIM_NORM_HIER_GT ffvnh,
              fnd_flex_values      ffv
       WHERE  ffvnh.child_flex_value_set_id = ffv.flex_value_set_id
       AND   (ffv.flex_value BETWEEN ffvnh.child_flex_value_low
                                 AND ffvnh.child_flex_value_high)
       AND   ((ffvnh.range_attribute = 'P' and ffv.summary_flag = 'Y') OR
              (ffvnh.range_attribute = 'C' and ffv.summary_flag = 'N'))
       AND   ffvnh.parent_flex_value        = p_parent_node
       AND   ffvnh.parent_flex_value_set_id = p_parent_vs_id;

     l_flex_value_id number(15);
     l_flex_value_set_id number(15);

   BEGIN

     -- IF (FIIDIM_Debug) THEN
    -- FII_MESSAGE.Func_Ent ('FII_COM_MAINTAIN_PKG.INSERT_IMM_CHILD_NODES');
    -- END IF;

    select flex_value_id into l_flex_value_id
    from fnd_flex_values
    where flex_value_set_id = p_vset_id
    and flex_value = p_root_node;

    l_flex_value_set_id := p_vset_id;

           /* Inserting parent in a gt table: FII_DIM_HIER_HELP_GT */
               g_index := g_index + 1;
               insert into FII_DIM_HIER_HELP_GT
                   ( IDX,
                     FLEX_VALUE_ID,
                     FLEX_VALUE_SET_ID,
                     NEXT_LEVEL_FLEX_VALUE_ID)
               values
                   ( g_index,
                     l_flex_value_id,
                     l_flex_value_set_id,
                     l_flex_value_id);

               update FII_DIM_HIER_HELP_GT
                  set NEXT_LEVEL_FLEX_VALUE_ID = l_flex_value_id
                where IDX = g_index - 1;

     FOR direct_children_rec IN direct_children_csr(p_vset_id, p_root_node)
     LOOP

          /* Inserting record with all parents */
                      INSERT  INTO fii_lob_hier_gt (
                              parent_level,
                              parent_lob_id,
                              child_lob_id,
                              next_level,
                              child_level,
                              next_level_is_leaf,
                              is_leaf_flag,
                              parent_flex_value_Set_id,
                              child_flex_value_set_id,
                              next_level_lob_id)
                      SELECT   pp.idx,
                               pp.flex_value_id,
                               direct_children_rec.flex_value_id,
                               pp.idx + 1,
                               g_index + 1,
                               'N',
                               'N',
                               pp.flex_value_set_id,
                               direct_children_rec.flex_value_set_id,
                               decode(pp.idx, g_index,
                                      direct_children_rec.flex_value_id,
                                      pp.next_level_flex_value_id)
                      FROM   FII_DIM_HIER_HELP_GT pp;

        --Recursive Call.
       INSERT_IMM_CHILD_NODES (direct_children_rec.flex_value_set_id,
                               direct_children_rec.flex_value);

     END LOOP;

            /* Deleting parent from the gt table */
            delete from FII_DIM_HIER_HELP_GT where idx = g_index;
            g_index := g_index - 1;


     FND_CONCURRENT.Af_Commit;  --commit

     EXCEPTION
       WHEN NO_DATA_FOUND Then
         FII_UTIL.Write_Log ('Insert Immediate child: No Data Found');
         FII_MESSAGE.Func_Fail
	  (func_name => 'FII_LOB_MAINTAIN_PKG.Insert_Imm_Child_Nodes');
         RAISE;

       WHEN OTHERS Then
         FII_UTIL.Write_Log (substr(SQLERRM,1,180));
         FII_MESSAGE.Func_Fail
 	  (func_name => 'FII_LOB_MAINTAIN_PKG.INSERT_IMM_CHILD_NODES');
         RAISE;

   END INSERT_IMM_CHILD_NODES;


-- **************************************************************************
-- This procedure will populate the TMP hierarchy table

    PROCEDURE  Flatten_LOB_Dim_Hier (p_vset_id NUMBER, p_root_node VARCHAR2) IS


        l_flex_value      VARCHAR2(150);
        p_parent_id       NUMBER(15);

    BEGIN

      IF (FIIDIM_Debug) THEN
		  FII_MESSAGE.Func_Ent(func_name => 'FII_LOB_MAINTAIN_PKG.'||
								 'Flatten_LOB_Dim_Hier');
      END IF;

      g_phase := 'Truncate table FII_LOB_HIER_GT';
      FII_UTIL.truncate_table ('FII_LOB_HIER_GT', 'FII', g_retcode);

      -----------------------------------------------------------------

      LOBDIM_parent_node    := p_root_node;
      LOBDIM_parent_vset_id := p_vset_id;

      g_phase := 'Get p_parent_id from FND_FLEX_VALUES';

      SELECT flex_value_id INTO p_parent_id
        FROM FND_FLEX_VALUES
       WHERE flex_value_set_id = p_vset_id
         AND flex_value        = p_root_node;

      LOBDIM_parent_flex_id := p_parent_id;

      -- The following Insert statement inserts the top node self row and
      -- invokes Ins_Imm_Child_nodes routine to insert all top node mappings
      -- within the hierarchy.
      g_phase := 'invoke Ins_Imm_Child_nodes';

      INSERT_IMM_CHILD_NODES (p_vset_id, p_root_node);

        g_phase := 'insert all self nodes';

      insert into fii_lob_hier_gt (
                 parent_level,
                 parent_lob_id,
                 next_level,
                 next_level_lob_id,
                 child_level,
                 child_lob_id,
                 child_flex_value_set_id,
                 parent_flex_value_set_id,
                 next_level_is_leaf,
                 is_leaf_flag)
      select
		child_level,
		child_lob_id,
		child_level,
		child_lob_id,
		child_level,
		child_lob_id,
		child_flex_value_set_id,
		child_flex_value_set_id,
		'N',
		'N'
      from (select distinct child_lob_id,
                            child_level,
                            child_flex_value_set_id
              from fii_lob_hier_gt);

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into fii_lob_hier_gt');
     END IF;

    g_phase := 'Insert self node for the top node';

      INSERT INTO fii_LOB_hier_gt
               (parent_level,
                parent_lob_id,
                next_level,
		next_level_lob_id,
                child_level,
                child_lob_id,
                child_flex_value_set_id,
                  parent_flex_value_set_id,
                next_level_is_leaf,
                is_leaf_flag)
        VALUES
	       (1,
                G_TOP_NODE_ID,
                1,
		G_TOP_NODE_ID,
                1,
                G_TOP_NODE_ID,
                G_MASTER_VALUE_SET_ID,
                G_MASTER_VALUE_SET_ID,
                'N',
                'N');

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into fii_LOB_hier_gt');
     END IF;

      -- Insert a dummy super top node (-999) to the hierarchy table
      -- (the dummy value set id is -998)
      g_phase := 'Insert a dummy top node (-999) to the hierarchy table';

       INSERT INTO fii_lob_hier_gt
               (parent_level,
                parent_lob_id,
                next_level,
		next_level_lob_id,
                child_level,
                child_lob_id,
                child_flex_value_set_id,
                  parent_flex_value_set_id,
                next_level_is_leaf,
                is_leaf_flag)
        SELECT
          0,
          -999,
          1,
          G_TOP_NODE_ID,
          child_level,
          child_lob_id,
          child_flex_value_set_id,
            -998,
          'N',
          'N'
        FROM fii_lob_hier_gt
        WHERE next_level_lob_id = parent_lob_id
          AND next_level_lob_id = child_lob_id;

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into fii_lob_hier_gt');
     END IF;

       --Insert the UNASSIGNED to the hierarchy table.
       --Use G_TOP_NODE_ID (rather than -999, see bug 3541141) as the parent

       g_phase := 'Insert the UNASSIGNED to the hierarchy table';

        --bug 3541141: G_TOP_NODE_ID is the parent (to replace -999)
        --First one is (G_TOP_NODE_ID, UNASSIGNED, UNASSIGNED)
        INSERT INTO fii_lob_hier_gt
               (parent_level,
                parent_lob_id,
                next_level,
		next_level_lob_id,
                child_level,
                child_lob_id,
                child_flex_value_set_id,
                  parent_flex_value_set_id,
                next_level_is_leaf,
                is_leaf_flag)
         VALUES (
           1,
           G_TOP_NODE_ID,
           2,
           G_UNASSIGNED_LOB_ID,
           2,
           G_UNASSIGNED_LOB_ID,
           G_FII_INT_VALUE_SET_ID,
             G_MASTER_VALUE_SET_ID,
           'N',
           'N');

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into fii_lob_hier_gt');
     END IF;

       g_phase := 'Insert self node for UNASSIGNED to the hierarchy table';

        -- Another one is (UNASSIGNED, UNASSIGNED, UNASSIGNED)
        -- bug 3541141: level becomes 2
        INSERT INTO fii_lob_hier_gt
               (parent_level,
                parent_lob_id,
                next_level,
		next_level_lob_id,
                child_level,
                child_lob_id,
                child_flex_value_set_id,
                  parent_flex_value_set_id,
                next_level_is_leaf,
                is_leaf_flag)
         VALUES (
           2,
           G_UNASSIGNED_LOB_ID,
           2,
           G_UNASSIGNED_LOB_ID,
           2,
           G_UNASSIGNED_LOB_ID,
           G_FII_INT_VALUE_SET_ID,
             G_FII_INT_VALUE_SET_ID,
           'N',
           'N');

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into fii_lob_hier_gt');
     END IF;

      -- Added record (-999, TOP, UNASSIGNED) to the hierarchy
      -- after the fix for bug 3541141
       g_phase := 'Insert (-999, TOP, UNASSIGNED) to the hierarchy table';

        -- Another one is (-999, TOP, UNASSIGNED)
        INSERT INTO fii_lob_hier_gt
               (parent_level,
                parent_lob_id,
                next_level,
		next_level_lob_id,
                child_level,
                child_lob_id,
                child_flex_value_set_id,
                  parent_flex_value_set_id,
                next_level_is_leaf,
                is_leaf_flag)
         VALUES (
           0,
           -999,
           1,
           G_TOP_NODE_ID,
           2,
           G_UNASSIGNED_LOB_ID,
           G_FII_INT_VALUE_SET_ID,
             -998,
           'N',
           'N');

      IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into fii_lob_hier_gt');
      END IF;

      --====================================================================
      --Before we proceed to populate the final hierarchy table, we should
      --check if there are any diamond shapes in the TMP hierarchy table.
      --If so, we will report the problem, and error out the program

      -- The following block checks for child value multiple assignments
      -- to different parents within the value sets
      -- We use (just created) TMP table FII_LOB_HIER_GT for this purpose
      g_phase := 'Call Detect_Diamond_Shape';

         Detect_Diamond_Shape;

      --====================================================================
      --So far, there is no problem...

      --Update the column next_level_is_leaf
      --We look at those records (P,A,A) in which A is a leaf value
      g_phase := 'Update the column next_level_is_leaf';

        -------------------------------------------------------
        --Currently , there is no need to update this column for
        --the full hierarchy since it's not used anywhere
        -------------------------------------------------------
        --Update fii_lob_hier_gt  tab1
        --   Set next_level_is_leaf = 'Y'
        -- Where tab1.next_level_lob_id = tab1.child_lob_id
        --   AND 1 = (select count(*)
        --              from fii_lob_hier_gt tab2
        --             where tab2.parent_lob_id = tab1.next_level_lob_id);

        --Bug 3742786: Follow the performance enhancement in FC code.
        --
        --Update fii_lob_hier_gt tab1
        --   Set  next_level_is_leaf = 'Y'
        -- Where  tab1.next_level_lob_id = tab1.child_lob_id
        --   and  tab1.next_level_lob_id IN (
        --          select /*+ ordered */ tab3.next_level_lob_id
        --            from   fii_lob_hier_gt tab3,
        --                   fii_lob_hier_gt tab2
        --           where  tab2.parent_lob_id = tab3.parent_lob_id
        --             and  tab3.parent_lob_id = tab3.child_lob_id
        --        group by  tab3.next_level_lob_id
        --          having  count(*) = 1);

     --Update the column is_leaf_flag
     --We look at all records (A,A,A) in which A is a leaf value
      g_phase := 'Update the column is_leaf_flag';

        -------------------------------------------------------
        --Currently , there is no need to update this column for
        --the full hierarchy since it's not used anywhere
        -------------------------------------------------------
        --Update fii_lob_hier_gt
        --  Set  is_leaf_flag = 'Y'
        -- Where parent_lob_id = next_level_lob_id
        --   and next_level_lob_id = child_lob_id
        --   and next_level_is_leaf = 'Y';


      IF (FIIDIM_Debug) THEN
		  FII_MESSAGE.Func_Succ(func_name => 'FII_LOB_MAINTAIN_PKG.'||
								 'Flatten_LOB_Dim_Hier');
      END IF;

    EXCEPTION

      WHEN  NO_DATA_FOUND THEN
        FII_UTIL.Write_Log ('Flatten_LOB_Dim_Hier: No Data Found');
        FII_MESSAGE.Func_Fail(func_name => 'FII_LOB_MAINTAIN_PKG.'||
                             'Flatten_LOB_Dim_Hier');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        raise;

       WhEN LOBDIM_MULT_PAR_err THEN
         FII_UTIL.Write_Log ('Flatten_LOB_Dim_Hier: Diamond Shape Detected');
         FII_MESSAGE.Func_Fail (func_name =>
		'FII_DIMENSION_MAINTAIN_PKG.Flatten_LOB_Dim_Hier');
         FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
         raise;

      WHEN OTHERS THEN
        FII_UTIL.Write_Log ('Flatten_LOB_Dim_Hier: '|| substr(sqlerrm,1,180));
        FII_MESSAGE.Func_Fail(func_name => 'FII_LOB_MAINTAIN_PKG.'||
                             'Flatten_LOB_Dim_Hier');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        raise;

    END Flatten_LOB_Dim_Hier;


-- **************************************************************************
-- Populate column next_level_lob_sort_order for pruned hierarchy FII_LOB_HIER_GT
-- by looking at column HIERARCHY_LEVEL of FND_FLEX_VALUES for the master value set.
-- This is for Oracle IT only currently.

   PROCEDURE Get_Sort_Order IS

   BEGIN

    IF (FIIDIM_Debug) THEN
		 FII_MESSAGE.Func_Ent(func_name => 'FII_LOB_MAINTAIN_PKG.'||'Get_Sort_Order');
    END IF;

     g_phase := 'Update next_level_lob_sort_order for fii_lob_hier_gt ';

      update fii_lob_hier_gt h
         set h.next_level_lob_sort_order =
          (select decode(TRANSLATE(HIERARCHY_LEVEL, 'A0123456789', 'A'), NULL,
                         to_number(HIERARCHY_LEVEL), to_number(NULL))
             from fnd_flex_values ffv
            where ffv.flex_value_set_id = G_MASTER_VALUE_SET_ID
              and ffv.flex_value_id = h.next_level_lob_id);

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in fii_lob_hier_gt');
     END IF;

    IF (FIIDIM_Debug) THEN
		  FII_MESSAGE.Func_Succ(func_name=>'FII_LOB_MAINTAIN_PKG.'||'Get_Sort_Order');
    END IF;

    EXCEPTION

      WHEN OTHERS THEN
        FII_UTIL.Write_Log ('Get_Sort_Order -> phase: '|| g_phase);
        FII_UTIL.Write_Log ('Get_Sort_Order: '|| substr(sqlerrm,1,180));
        FII_MESSAGE.Func_Fail(func_name => 'FII_LOB_MAINTAIN_PKG.'||'Get_Sort_Order');
        raise;

    END Get_Sort_Order;


-- **************************************************************************
-- Populate the pruned LOB hierarchy FII_LOB_HIERARCHIES by deleting from
-- FII_LOB_HIER_GT (full version) the values from Local Value sets

   PROCEDURE Get_Pruned_LOB_GT  IS

   Begin

    IF (FIIDIM_Debug) THEN
		 FII_MESSAGE.Func_Ent(func_name => 'FII_LOB_MAINTAIN_PKG.'||
								 'Get_Pruned_LOB_GT');
    END IF;

    --Delete from FII_LOB_HIER_GT for child value set not equal to
    --the master value set and not equal to the UNASSIGNED value set.
    g_phase := 'Delete FII_LOB_HIER_GT #1';

     Delete from  FII_LOB_HIER_GT
      Where child_flex_value_set_id <> G_MASTER_VALUE_SET_ID
        And child_flex_value_set_id <> G_FII_INT_VALUE_SET_ID;

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows from FII_LOB_HIER_GT');
     END IF;

    -- Bug 4299543. Leaf nodes will always be included in the pruned hierarchy from
    -- Expense Analysis onwards.

    --Finally, update the columns next_level_is_leaf, is_leaf_flag again
    --for the latest FII_LOB_HIER_GT
    g_phase := 'Update next_level_is_leaf';

        --Update the column next_level_is_leaf
        --We look at those records (P,A,A) in which A is a leaf value
        --Update fii_lob_hier_gt  tab1
        --   Set next_level_is_leaf = 'Y'
        -- Where tab1.next_level_lob_id = tab1.child_lob_id
        --   AND 1 = (select count(*)
        --              from fii_lob_hier_gt tab2
        --             where tab2.parent_lob_id = tab1.next_level_lob_id);

        --Bug 3742786: Follow the performance enhancement in FC code.
        --
        Update fii_lob_hier_gt tab1
           Set  next_level_is_leaf = 'Y'
         Where  tab1.next_level_lob_id = tab1.child_lob_id
           and  tab1.next_level_lob_id IN (
                  select /*+ ordered */ tab3.next_level_lob_id
                    from   fii_lob_hier_gt tab3,
                           fii_lob_hier_gt tab2
                   where  tab2.parent_lob_id = tab3.parent_lob_id
                     and  tab3.parent_lob_id = tab3.child_lob_id
                group by  tab3.next_level_lob_id
                  having  count(*) = 1);

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in fii_lob_hier_gt');
     END IF;

    g_phase := 'Update is_leaf_flag';

        --Update the column is_leaf_flag
        --We look at all records (A,A,A) in which A is a leaf value
        Update fii_lob_hier_gt
          Set  is_leaf_flag = 'Y'
        Where parent_lob_id = next_level_lob_id
          and next_level_lob_id = child_lob_id
          and next_level_is_leaf = 'Y';

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in fii_lob_hier_gt');
     END IF;

      --------------------------------------------------------------
      --Populate column next_level_lob_sort_order (bug 3608355)
      If NVL(FND_PROFILE.value('FII_SORT_ORDER_IT'), 'N') = 'Y' then
          g_phase := 'Call Get_Sort_Order';
          Get_Sort_Order;
      End if;
      --------------------------------------------------------------

    IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Succ(func_name => 'FII_LOB_MAINTAIN_PKG.'||
                             'Get_Pruned_LOB_GT');
    END IF;

    EXCEPTION

      WHEN OTHERS THEN
        FII_UTIL.Write_Log ('Get_Pruned_LOB_GT -> phase: '|| g_phase);
        FII_UTIL.Write_Log ('Get_Pruned_LOB_GT: '|| substr(sqlerrm,1,180));
        FII_MESSAGE.Func_Fail(func_name => 'FII_LOB_MAINTAIN_PKG.'||
                             'Get_Pruned_LOB_GT');
        raise;

    END Get_Pruned_LOB_GT;

-- **************************************************************************
-- Insert UNASSIGNED to the dimension tables (both full and pruned version)
--

   PROCEDURE Handle_Unenabled_DIM IS

   Begin

    IF (FIIDIM_Debug) THEN
		 FII_MESSAGE.Func_Ent(func_name => 'FII_LOB_MAINTAIN_PKG.'||
								 'Handle_Unenabled_DIM');
    END IF;

    g_phase := 'Truncate tables';

     FII_UTIL.truncate_table ('FII_FULL_LOB_HIERS',  'FII', g_retcode);
     FII_UTIL.truncate_table ('FII_LOB_HIERARCHIES', 'FII', g_retcode);

    g_phase := 'INSERT INTO FII_FULL_LOB_HIERS';

     INSERT INTO FII_FULL_LOB_HIERS
               (parent_level,
                parent_lob_id,
                next_level,
		next_level_lob_id,
                child_level,
                child_lob_id,
                child_flex_value_set_id,
                parent_flex_value_set_id,
                next_level_is_leaf,
                is_leaf_flag,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login)
         VALUES (
           1,
           G_UNASSIGNED_LOB_ID,
           1,
           G_UNASSIGNED_LOB_ID,
           1,
           G_UNASSIGNED_LOB_ID,
           G_FII_INT_VALUE_SET_ID,
           G_FII_INT_VALUE_SET_ID,
           'Y',
           'Y',
  	  SYSDATE,
	  FII_USER_ID,
	  SYSDATE,
	  FII_USER_ID,
	  FII_LOGIN_ID);

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FULL_LOB_HIERS');
     END IF;

    g_phase := 'INSERT INTO FII_LOB_HIERARCHIES';

     INSERT INTO FII_LOB_HIERARCHIES
               (parent_level,
                parent_lob_id,
                next_level,
		next_level_lob_id,
                child_level,
                child_lob_id,
                child_flex_value_set_id,
                parent_flex_value_set_id,
                next_level_is_leaf,
                is_leaf_flag,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login)
         VALUES (
           1,
           G_UNASSIGNED_LOB_ID,
           1,
           G_UNASSIGNED_LOB_ID,
           1,
           G_UNASSIGNED_LOB_ID,
           G_FII_INT_VALUE_SET_ID,
           G_FII_INT_VALUE_SET_ID,
           'Y',
           'Y',
  	  SYSDATE,
	  FII_USER_ID,
	  SYSDATE,
	  FII_USER_ID,
	  FII_LOGIN_ID);

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_LOB_HIERARCHIES');
     END IF;

        commit;

    IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Succ(func_name => 'FII_LOB_MAINTAIN_PKG.'||
                             'Handle_Unenabled_DIM');
    END IF;

    EXCEPTION

      WHEN OTHERS THEN
        FII_UTIL.Write_Log ('Handle_Unenabled_DIM -> phase: '|| g_phase);
        FII_UTIL.Write_Log ('Handle_Unenabled_DIM: '|| substr(sqlerrm,1,180));
        FII_MESSAGE.Func_Fail(func_name => 'FII_LOB_MAINTAIN_PKG.'||
                               'Handle_Unenabled_DIM');
        raise;

    END Handle_Unenabled_DIM;


-- **************************************************************************
-- This is the main procedure of LOB dimension program (initial populate).

   PROCEDURE Init_Load (errbuf		OUT NOCOPY VARCHAR2,
	 	        retcode		OUT NOCOPY VARCHAR2) IS

    ret_val             BOOLEAN := FALSE;

  BEGIN

    IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Ent(func_name => 'FII_LOB_MAINTAIN_PKG.Init_Load');
    END IF;

    --First do the initialization

    g_phase := 'Call Initialize';

      Initialize;

    --Secondly populate the table FII_DIM_NORM_HIER_GT

    g_phase := 'Call Get_NORM_HIERARCHY_TMP';

      Get_NORM_HIERARCHY_TMP;

    --Call the Flatten LOB dimension hierarchy routine to insert all mappings.

    g_phase := 'Call Flatten_LOB_Dim_Hier';

      Flatten_LOB_Dim_Hier (G_MASTER_VALUE_SET_ID, G_TOP_NODE_VALUE);

    --==============================================================--

    --Copy TMP hierarchy table to the final dimension table
    g_phase := 'Copy TMP hierarchy table to the final full dimension table';

     FII_UTIL.truncate_table ('FII_FULL_LOB_HIERS', 'FII', g_retcode);

     INSERT  /*+ APPEND */ INTO FII_FULL_LOB_HIERS (
        parent_level,
        parent_lob_id,
        next_level,
        next_level_lob_id,
        next_level_is_leaf,
        is_leaf_flag,
        child_level,
        child_lob_id,
           parent_flex_value_set_id,
           child_flex_value_set_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
     SELECT
       	parent_level,
      	parent_lob_id,
        next_level,
	next_level_lob_id,
        next_level_is_leaf,
        is_leaf_flag,
	child_level,
	child_lob_id,
           parent_flex_value_set_id,
           child_flex_value_set_id,
	SYSDATE,
	FII_USER_ID,
	SYSDATE,
	FII_USER_ID,
	FII_LOGIN_ID
     FROM  FII_LOB_HIER_GT;

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FULL_LOB_HIERS');
     END IF;

    --Call FND_STATS to collect statistics after re-populating the tables.
    --for the full dimension table since it will be used later

    g_phase := 'gather_table_stats for FII_FULL_LOB_HIERS';

     FND_STATS.gather_table_stats
       (ownname	=> g_schema_name,
        tabname	=> 'FII_FULL_LOB_HIERS');

    --==============================================================--

    --Delete/Update FII_LOB_HIER_GT for pruned hierarchy table
    g_phase := 'Delete/Update FII_LOB_HIER_GT for pruned hierarchy table';

     Get_Pruned_LOB_GT;

    --Copy FII_LOB_HIER_GT to the final (pruned) dimension table
    g_phase := 'Copy TMP hierarchy table to the final pruned dimension table';

     FII_UTIL.truncate_table ('FII_LOB_HIERARCHIES', 'FII', g_retcode);

     INSERT  /*+ APPEND */ INTO FII_LOB_HIERARCHIES (
        parent_level,
        parent_lob_id,
        next_level,
        next_level_lob_id,
        next_level_is_leaf,
        is_leaf_flag,
        child_level,
        child_lob_id,
           parent_flex_value_set_id,
           child_flex_value_set_id,
             next_level_lob_sort_order,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
     SELECT
       	parent_level,
      	parent_lob_id,
        next_level,
	next_level_lob_id,
        next_level_is_leaf,
        is_leaf_flag,
	child_level,
	child_lob_id,
           parent_flex_value_set_id,
           child_flex_value_set_id,
             next_level_lob_sort_order,
	SYSDATE,
	FII_USER_ID,
	SYSDATE,
	FII_USER_ID,
	FII_LOGIN_ID
     FROM  FII_LOB_HIER_GT;

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_LOB_HIERARCHIES');
     END IF;

    --Call FND_STATS to collect statistics after re-populating the tables.
    --Will seed this in RSG
    -- FND_STATS.gather_table_stats
    --   (ownname	=> g_schema_name,
    --    tabname	=> 'FII_LOB_HIERARCHIES');

    --================================================================--

     FND_CONCURRENT.Af_Commit;

     IF (FIIDIM_Debug) THEN
		 FII_MESSAGE.Func_Succ(func_name => 'FII_LOB_MAINTAIN_PKG.Init_Load');
     END IF;

     -- ret_val := FND_CONCURRENT.Set_Completion_Status
     --		        (status	 => 'NORMAL', message => NULL);

    -- Exception handling

  EXCEPTION

    WHEN LOBDIM_fatal_err THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log ('FII_LOB_MAINTAIN_PKG.Init_Load: '||
                        'User defined error');
      -- Rollback
      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_LOB_MAINTAIN_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN LOBDIM_MULT_PAR_err THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log ('FII_LOB_MAINTAIN_PKG.Init_Load: '||
                          'Diamond Shape Detected');
      -- Rollback
      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_LOB_MAINTAIN_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN LOBDIM_NOT_ENABLED THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log ('>>> LOB Dimension Not Enabled...');

      Handle_Unenabled_DIM;

      retcode := sqlcode;
      -- ret_val := FND_CONCURRENT.Set_Completion_Status
      --		        (status	 => 'NORMAL', message => NULL);

    WHEN OTHERS THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log (
          'Other error in FII_LOB_MAINTAIN_PKG.Init_Load: ' || substr(sqlerrm,1,180));

      -- Rollback
      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'II_LOB_MAINTAIN_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

   END Init_Load;


-- *****************************************************************
-- This is the main procedure of LOB dimension program (incremental update).

   PROCEDURE Incre_Update (errbuf		OUT NOCOPY VARCHAR2,
	 	           retcode		OUT NOCOPY VARCHAR2) IS

     ret_val             BOOLEAN := FALSE;

   BEGIN

-----------------------------------------------------------------------------
--*bug 3520540: Call Initial Load here to replace Incremental Update;
--***           We should reverse this back when LOB is used in MVs later on.
   IF NOT ret_val THEN
     g_phase := 'Call Init_Load';
     Init_Load (errbuf, retcode);
     return;
   END IF;
-----------------------------------------------------------------------------

    IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Ent(func_name => 'FII_LOB_MAINTAIN_PKG.Incre_Load');
    END IF;

    --First do the initialization

     g_phase := 'Call Initialize';

      Initialize;

    --Secondly populate the table FII_DIM_NORM_HIER_GT

     g_phase := 'Call Get_NORM_HIERARCHY_TMP';

      Get_NORM_HIERARCHY_TMP;

    --Call the Flatten LOB dimension hierarchy routine to insert all mappings.

     g_phase := 'Call Flatten_LOB_Dim_Hier';

       Flatten_LOB_Dim_Hier (G_MASTER_VALUE_SET_ID, G_TOP_NODE_VALUE);

     -- Incremental Dimension Maintence
     -- All data is now in the temporary table FII_LOB_HIER_GT,
     -- we need to maintain the permanent table FII_FULL_LOB_HIERS
     -- by diffing the 2 tables.
     -- The maintenance is done by 2 statements, one INSERT and one DELETE.
     g_phase := 'Copy TMP hierarchy table to the final full dimension table';

     --IF (FIIDIM_Debug) THEN
     --   FII_UTIL.Write_Log ('Starting to delete from the final table by diffing');
     -- End If;

     g_phase := 'DELETE FROM FII_FULL_LOB_HIERS';

      DELETE FROM FII_FULL_LOB_HIERS
      WHERE
	(parent_level, parent_lob_id, next_level, next_level_lob_id,
         next_level_is_leaf, is_leaf_flag, child_level, child_lob_id,
           parent_flex_value_set_id, child_flex_value_set_id) IN
        (SELECT parent_level, parent_lob_id, next_level, next_level_lob_id,
                next_level_is_leaf, is_leaf_flag, child_level, child_lob_id,
                parent_flex_value_set_id, child_flex_value_set_id
	 FROM FII_FULL_LOB_HIERS
	 MINUS
	 SELECT parent_level, parent_lob_id, next_level, next_level_lob_id,
                next_level_is_leaf, is_leaf_flag, child_level, child_lob_id,
                parent_flex_value_set_id, child_flex_value_set_id
	 FROM FII_LOB_HIER_GT);

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows from FII_FULL_LOB_HIERS');
     END IF;

      --IF (FIIDIM_Debug) THEN
      --  FII_UTIL.Write_Log ('Starting to insert into the final table by diffing');
      --End If;

     g_phase := 'Insert into FII_FULL_LOB_HIERS';

      Insert into FII_FULL_LOB_HIERS (
        parent_level,
        parent_lob_id,
        next_level,
        next_level_lob_id,
        next_level_is_leaf,
        is_leaf_flag,
        child_level,
        child_lob_id,
          parent_flex_value_set_id,
          child_flex_value_set_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
       (SELECT 	parent_level,
 	      	parent_lob_id,
                next_level,
		next_level_lob_id,
                next_level_is_leaf,
                is_leaf_flag,
		child_level,
		child_lob_id,
                  parent_flex_value_set_id,
                  child_flex_value_set_id,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
        FROM 	FII_LOB_HIER_GT
        MINUS
        SELECT 	parent_level,
 	      	parent_lob_id,
                next_level,
		next_level_lob_id,
                next_level_is_leaf,
                is_leaf_flag,
		child_level,
		child_lob_id,
                  parent_flex_value_set_id,
                  child_flex_value_set_id,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
       FROM 	FII_FULL_LOB_HIERS);

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FULL_LOB_HIERS');
     END IF;

     --Call FND_STATS to collect statistics after re-populating the tables.
     --for the full dimension table since it will be used later

     g_phase := 'gather_table_stats for FII_FULL_LOB_HIERS';

       FND_STATS.gather_table_stats
            (ownname	=> g_schema_name,
             tabname	=> 'FII_FULL_LOB_HIERS');

    --==============================================================--

    --Delete/Update FII_LOB_HIER_GT for pruned hierarchy table
    g_phase := 'Delete/Update FII_LOB_HIER_GT for pruned hierarchy table';

     Get_Pruned_LOB_GT;

    --Copy FII_LOB_HIER_GT to the final (pruned) dimension table
    g_phase := 'Copy TMP hierarchy table to the final pruned dimension table';

     -- Incremental Dimension Maintence
     -- All data is now in the temporary table FII_LOB_HIER_GT,
     -- we need to maintain the permanent table FII_LOB_HIERARCHIES
     -- by diffing the 2 tables.
     -- The maintenance is done by 2 statements, one INSERT and one DELETE.

     g_phase := 'DELETE FROM FII_LOB_HIERARCHIES';

      --use NVL to handle possible NULL column
      DELETE FROM FII_LOB_HIERARCHIES
      WHERE
	(parent_level, parent_lob_id, next_level, next_level_lob_id,
         next_level_is_leaf, is_leaf_flag, child_level, child_lob_id,
           parent_flex_value_set_id, child_flex_value_set_id,
                   NVL(next_level_lob_sort_order, -92883)) IN
        (SELECT parent_level, parent_lob_id, next_level, next_level_lob_id,
                next_level_is_leaf, is_leaf_flag, child_level, child_lob_id,
                parent_flex_value_set_id, child_flex_value_set_id,
                   NVL(next_level_lob_sort_order, -92883)
	 FROM FII_LOB_HIERARCHIES
	 MINUS
	 SELECT parent_level, parent_lob_id, next_level, next_level_lob_id,
                next_level_is_leaf, is_leaf_flag, child_level, child_lob_id,
                parent_flex_value_set_id, child_flex_value_set_id,
                   NVL(next_level_lob_sort_order, -92883)
	 FROM FII_LOB_HIER_GT);

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows from FII_LOB_HIERARCHIES');
     END IF;

     g_phase := 'Insert into FII_LOB_HIERARCHIES';

      Insert into FII_LOB_HIERARCHIES (
        parent_level,
        parent_lob_id,
        next_level,
        next_level_lob_id,
        next_level_is_leaf,
        is_leaf_flag,
        child_level,
        child_lob_id,
          parent_flex_value_set_id,
          child_flex_value_set_id,
             next_level_lob_sort_order,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
       (SELECT 	parent_level,
 	      	parent_lob_id,
                next_level,
		next_level_lob_id,
                next_level_is_leaf,
                is_leaf_flag,
		child_level,
		child_lob_id,
                  parent_flex_value_set_id,
                  child_flex_value_set_id,
                     next_level_lob_sort_order,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
        FROM 	FII_LOB_HIER_GT
        MINUS
        SELECT 	parent_level,
 	      	parent_lob_id,
                next_level,
		next_level_lob_id,
                next_level_is_leaf,
                is_leaf_flag,
		child_level,
		child_lob_id,
                  parent_flex_value_set_id,
                  child_flex_value_set_id,
                     next_level_lob_sort_order,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
       FROM 	FII_LOB_HIERARCHIES);

     IF (FIIDIM_Debug) THEN
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_LOB_HIERARCHIES');
     END IF;

     --Call FND_STATS to collect statistics after re-populating the tables.
     --Will seed this in RSG
     --  FND_STATS.gather_table_stats
     --       (ownname	=> g_schema_name,
     --        tabname	=> 'FII_LOB_HIERARCHIES');

     --=============================================================--

       FND_CONCURRENT.Af_Commit;

    IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Succ(func_name => 'FII_LOB_MAINTAIN_PKG.Incre_Load');
    END IF;

       -- ret_val := FND_CONCURRENT.Set_Completion_Status
       --		        (status	 => 'COMPLETE', message => NULL);

   -- Exception handling

   EXCEPTION
     WHEN LOBDIM_fatal_err THEN
       FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
       FII_UTIL.Write_Log ('FII_LOB_MAINTAIN_PKG.Incre_Update'||
                         'User defined error');
       -- Rollback
       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name	=> 'FII_LOB_MAINTAIN_PKG.Incre_Update');
       retcode := sqlcode;
       ret_val := FND_CONCURRENT.Set_Completion_Status
	        	(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN LOBDIM_MULT_PAR_err THEN
      FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
      FII_UTIL.Write_Log ('FII_LOB_MAINTAIN_PKG.Incre_Update: '||
                        'Diamond Shape Detected');
      -- Rollback
      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_LOB_MAINTAIN_PKG.Incre_Update');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN LOBDIM_NOT_ENABLED THEN
      FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
      FII_UTIL.Write_Log ('>>> LOB Dimension Not Enabled...');

      Handle_Unenabled_DIM;

      retcode := sqlcode;
      -- ret_val := FND_CONCURRENT.Set_Completion_Status
      --		        (status	 => 'NORMAL', message => NULL);

     WHEN OTHERS THEN
       FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
       FII_UTIL.Write_Log (
          'Other error in FII_LOB_MAINTAIN_PKG.Incre_Update: ' || substr(sqlerrm,1,180));

       -- Rollback
       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name	=> 'II_LOB_MAINTAIN_PKG.Incre_Update');
       retcode := sqlcode;
       ret_val := FND_CONCURRENT.Set_Completion_Status
	        	(status	 => 'ERROR', message => substr(sqlerrm,1,180));

   END Incre_Update;

END FII_LOB_MAINTAIN_PKG;

/
