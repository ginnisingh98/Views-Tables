--------------------------------------------------------
--  DDL for Package Body FII_FIN_CAT_MAINTAIN_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_FIN_CAT_MAINTAIN_PKG" AS
/* $Header: FIIFICMB.pls 120.7 2006/09/26 12:42:43 arcdixit ship $  */

        G_MASTER_VALUE_SET_ID  NUMBER(15)      := NULL;
        G_TOP_NODE_ID          NUMBER(15)      := NULL;
        G_TOP_NODE_VALUE       VARCHAR2(240)   := NULL;
       -- G_INCL_LEAF_NODES      VARCHAR2(1);
        G_DBI_ENABLED_FLAG     VARCHAR2(1);

        g_phase                VARCHAR2(120);
        g_schema_name          VARCHAR2(120)   := 'FII';
        g_retcode              VARCHAR2(20)    := NULL;
        g_debug_mode           VARCHAR2(1)
                      := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');
	g_index      NUMBER(10) :=0;
	g_dimension_name VARCHAR2(30) := 'GL_FII_FIN_ITEM';
-- *****************************************************************
-- Check if a value set is table validated

  FUNCTION  Is_Table_Validated (X_Vs_Id NUMBER) RETURN BOOLEAN IS
    l_tab_name	VARCHAR2(240) := NULL;

  BEGIN

    --if FIIDIM_Debug then
    --  FII_MESSAGE.Func_Ent	(func_name => 'Is_Table_Validated');
    --end if;

    -- Execute statement to determine if the value set is table validated
    BEGIN

      SELECT fvt.application_table_name  INTO  l_tab_name
      FROM   fnd_flex_validation_tables fvt,
             fnd_flex_value_sets fvs
      WHERE  fvs.flex_value_set_id = X_vs_id
      AND    fvs.validation_type = 'F'
      AND    fvt.flex_value_set_id = fvs.flex_value_set_id;
    EXCEPTION
      WHEN NO_DATA_FOUND THEN
        return FALSE;
    END;

    --if FIIDIM_Debug then
    --  FII_MESSAGE.Func_Succ (func_name => 'Is_Table_Validated');
    --end if;

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
        FII_UTIL.Write_Log(
               'Unexpected error when calling Get_Value_Set_Name...');
	FII_UTIL.WRITE_LOG ( 'Error Message: '|| substr(sqlerrm,1,80));
	FII_UTIL.WRITE_LOG ( 'Value Set ID: ' || p_vs_id);
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
--   Lock down value set for processing

  PROCEDURE lock_flex_value_set (fvsid NUMBER) is
    lkname   varchar2(128);
    lkhandle varchar2(128);
    rs_mode  constant integer := 5;
    timout   constant integer := 2;  -- 2 secs timeout
    expiration_secs constant integer := 864000;
    lkresult integer;
  begin
    -- generate the name for the user-defined lock
    lkname := 'FND_FLEX_AHE_VS_' || to_char(fvsid);

    -- get Oracle-assigned lock handle
    dbms_lock.allocate_unique( lkname, lkhandle, expiration_secs );

    -- request a lock in the ROW SHARE mode
    lkresult := dbms_lock.request( lkhandle, rs_mode, timout, TRUE );

    if ( lkresult = 0 ) then
      -- locking was successful
      return;
    elsif ( lkresult = 1 ) then
      -- Dimension Hierarchy Manager is locking out value set
      FII_UTIL.Write_Log( 'DHM is locking out value set: ' || fvsid);
      app_exception.raise_exception;
    else
      FII_UTIL.Write_Log( 'Error when locking out value set: ' || fvsid);
      app_exception.raise_exception;
    end if;

  END lock_flex_value_set;

-- *******************************************************************
--   Initialize (get the master value set and the top node)

   PROCEDURE Initialize  IS

     l_dir        VARCHAR2(160);
	 l_check	  NUMBER;
	 l_bool_ret   BOOLEAN;

   BEGIN

     ----------------------------------------------
     -- Do set up for log file
     ----------------------------------------------

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
     FII_UTIL.initialize('FII_FIN_CAT_MAINTAIN_PKG.log',
                         'FII_FIN_CAT_MAINTAIN_PKG.out',l_dir, 'FII_FIN_CAT_MAINTAIN_PKG');

	 -- --------------------------------------------------------
	 -- Check source ledger setup for DBI
	 -- --------------------------------------------------------
     l_check := FII_EXCEPTION_CHECK_PKG.check_slg_setup;

     if l_check <> 0 then
		FII_UTIL.write_log(' No source ledger setup for DBI');
        RAISE FINDIM_fatal_err;
     end if;

     -- --------------------------------------------------------
     -- Detect unmapped local value set
     -- --------------------------------------------------------
     l_check :=
		FII_EXCEPTION_CHECK_PKG.detect_unmapped_local_vs(g_dimension_name);

     if l_check > 0 then
        l_bool_ret := FND_CONCURRENT.Set_Completion_Status(
                                status  => 'WARNING',
                                message => 'Detected unmapped local value set.'
		);
     elsif l_check < 0 then
        RAISE FINDIM_fatal_err;
     end if;

     -- Obtain FII schema name
     g_schema_name := FII_UTIL.get_schema_name ('FII');

     -- Obtain user ID, login ID and initialize package variables
     FII_USER_ID 	:= FND_GLOBAL.USER_ID;
     FII_LOGIN_ID	:= FND_GLOBAL.LOGIN_ID;

     -- If any of the above values is not set, error out
     IF (FII_User_Id is NULL OR 	FII_Login_Id is NULL) THEN
       -- Fail to initialize
       FII_UTIL.Write_Log(' Fail Intialization');
       RAISE FINDIM_fatal_err;
     END IF;

     -- Determine if process will be run in debug mode
     IF (NVL(G_Debug_Mode, 'N') <> 'N') THEN
       FIIDIM_Debug := TRUE;
       FII_UTIL.Write_Log('Debug On');
     ELSE
       FIIDIM_Debug := FALSE;
       FII_UTIL.Write_Log('Debug Off');
     END IF;

     -- Turn trace on if process is run in debug mode
     IF (FIIDIM_Debug) THEN
       -- Program running in debug mode, turning trace on
       EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';
       FII_UTIL.Write_Log('Initialize: Set Trace On');
     END IF;

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Initialize: Now start processing '||
                  'Financial Category Dimension');
     End If;

     --Get the master value set and top node for Financial Category
     Begin
       -- Bug 4152798. Removed literal
       SELECT MASTER_VALUE_SET_ID, DBI_HIER_TOP_NODE, DBI_HIER_TOP_NODE_ID,
               DBI_ENABLED_FLAG
         INTO G_MASTER_VALUE_SET_ID, G_TOP_NODE_VALUE, G_TOP_NODE_ID,
              G_DBI_ENABLED_FLAG
         FROM FII_FINANCIAL_DIMENSIONS
        WHERE DIMENSION_SHORT_NAME = g_dimension_name;

       IF G_MASTER_VALUE_SET_ID is NULL THEN
         FII_MESSAGE.write_log (msg_name   => 'FII_MSTR_VSET_NOT_FOUND',
				   token_num  => 0);
         FII_MESSAGE.write_output (msg_name   => 'FII_MSTR_VSET_NOT_FOUND',
				   token_num  => 0);
         RAISE FINDIM_fatal_err;
       ELSIF G_TOP_NODE_ID is NULL OR G_TOP_NODE_VALUE is NULL THEN
         FII_MESSAGE.write_log (msg_name   => 'FII_MSTR_TNODE_NOT_FOUND',
				   token_num  => 0);
         FII_MESSAGE.write_output (msg_name   => 'FII_MSTR_TNODE_NOT_FOUND',
				   token_num  => 0);
         RAISE FINDIM_fatal_err;
       END IF;

     Exception
       When NO_DATA_FOUND Then
         FII_MESSAGE.write_log (msg_name   => 'FII_MSTR_VSET_NOT_FOUND',
				   token_num  => 0);
         FII_MESSAGE.write_output (msg_name   => 'FII_MSTR_VSET_NOT_FOUND',
				   token_num  => 0);
         RAISE FINDIM_fatal_err;
       When TOO_MANY_ROWS Then
         FII_UTIL.Write_Log ('More than one master value set found for Financial Category Dimension');
         RAISE FINDIM_fatal_err;
       When OTHERS Then
         FII_UTIL.Write_Log ('Unexpected error when getting master value set for Financial Category Dimension');
	 FII_UTIL.WRITE_LOG ('Error Message: '|| substr(sqlerrm,1,180));
         RAISE FINDIM_fatal_err;
     End;

     IF (FIIDIM_Debug) THEN
       FII_UTIL.Write_Log('Financial Category Master Value Set Id: '
                             || G_MASTER_VALUE_SET_ID);
       FII_UTIL.Write_Log('Financial Category Master Value Set Name: '
                             || Get_Value_Set_Name(G_MASTER_VALUE_SET_ID));
       FII_UTIL.Write_Log('       and Financial Category Top Node: '
                             || G_TOP_NODE_VALUE);
     END IF;

     -- Check if the master value set is a table validated set.
      If  Is_Table_Validated (G_MASTER_VALUE_SET_ID) Then
        FII_MESSAGE.write_log (msg_name   => 'FII_TBL_VALIDATED_VSET',
                 	          token_num  => 1,
                                  t1         => 'VS_NAME',
			          v1 	     => Get_Value_Set_Name (G_MASTER_VALUE_SET_ID));
        FII_MESSAGE.write_output (msg_name   => 'FII_TBL_VALIDATED_VSET',
                 	          token_num  => 1,
                                  t1         => 'VS_NAME',
			          v1 	     => Get_Value_Set_Name (G_MASTER_VALUE_SET_ID));
	RAISE FINDIM_fatal_err;
      End If;


     --If the FC dimension is not enabled, raise an exception
     IF G_DBI_ENABLED_FLAG <> 'Y' then
          RAISE FINDIM_NOT_ENABLED;
     END IF;

   Exception

     When FINDIM_NOT_ENABLED then
       FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
       --Let the main program to handle this
       raise;

     When FINDIM_fatal_err then
       FII_UTIL.Write_Log('FII_FIN_CAT_MAINTAIN_PKG.Initialize : '||
                         'User defined error');
       FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
       -- Rollback
       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.Initialize');
       raise;

     When others then
        FII_UTIL.Write_Log(
               'Unexpected error when calling Initialize...');
	FII_UTIL.WRITE_LOG ( 'Error Message: '|| substr(sqlerrm,1,180));
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        RAISE;

   END Initialize;


-- *******************************************************************
--   Populate the table FII_DIM_NORM_HIER_GT

   PROCEDURE Get_NORM_HIERARCHY_TMP  IS

    -- Bug 4152798. Removed literal
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
            where map.dimension_short_name   = g_dimension_name
              and map.chart_of_accounts_id   = sts.chart_of_accounts_id
              and sts.source_ledger_group_id = slg.source_ledger_group_id
              and slg.usage_code = 'DBI');

    l_vset_id  NUMBER(15);

   BEGIN

     IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Ent ('FII_FIN_CAT_MAINTAIN_PKG.Get_NORM_HIERARCHY_TMP');
     END IF;

     --First, copy table FII_DIM_NORM_HIERARCHY
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
     Where PARENT_FLEX_VALUE_SET_ID = G_MASTER_VALUE_SET_ID
     And   PARENT_FLEX_VALUE_SET_ID <> CHILD_FLEX_VALUE_SET_ID
     And   CHILD_FLEX_VALUE_SET_ID IN
          (select map.flex_value_set_id1
             from fii_dim_mapping_rules    map,
                  fii_slg_assignments      sts,
                  fii_source_ledger_groups slg
            where map.dimension_short_name   = g_dimension_name  -- Bug 4152798. Removed literal
              and map.chart_of_accounts_id   = sts.chart_of_accounts_id
              and sts.source_ledger_group_id = slg.source_ledger_group_id
              and slg.usage_code = 'DBI');

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_DIM_NORM_HIER_GT');
     END IF;

     --Insert records for the master value set
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
	RAISE FINDIM_fatal_err;
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

     --Call FND_STATS to collect statistics after populating the table
       g_phase := 'gather_table_stats for FII_DIM_NORM_HIER_GT';

       FND_STATS.gather_table_stats
  	       (ownname	=> g_schema_name,
	        tabname	=> 'FII_DIM_NORM_HIER_GT');

   Exception

     When FINDIM_fatal_err then
       FII_UTIL.Write_Log('FII_FIN_CAT_MAINTAIN_PKG.Get_NORM_HIERARCHY_TMP: '||
                         'User defined error');
       FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
       -- Rollback
       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.Get_NORM_HIERARCHY_TMP');
       raise;

     When others then
        FII_UTIL.Write_Log(
               'Unexpected error when calling Get_NORM_HIERARCHY_TMP.');
	FII_UTIL.WRITE_LOG ( 'Error Message: '|| substr(sqlerrm,1,180));
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        RAISE;

   END Get_NORM_HIERARCHY_TMP;


-- **************************************************************************
-- This procedure will check for child value multiple assignments
-- to different parents within FII_FIN_ITEM_HIER_GT (the TMP hierarchy table)

   PROCEDURE Detect_Diamond_Shape IS

   --The first cursor is to find all flex_value_id which has multiple parents;
   --we look at records such as (P1,A,A) and (P2,A,A)
     Cursor Dup_Assg_Cur IS
         SELECT count(parent_fin_cat_id) parents,
                child_fin_cat_id         flex_value_id
           FROM FII_FIN_ITEM_HIER_GT
          WHERE next_level_fin_cat_id = child_fin_cat_id
            AND parent_level          = next_level - 1
       GROUP BY child_fin_cat_id
         HAVING count(parent_fin_cat_id) > 1;

   --The second cursor is to print out the list of duplicate parents;
   --again, we get records such as (P1,A,A),(P2,A,A) to print out P1, P2 for A
     Cursor Dup_Assg_Parent_Cur (p_child_value_id NUMBER) IS
         SELECT parent_fin_cat_id,
                parent_flex_value_set_id,
                child_fin_cat_id,
                child_flex_value_set_id
           FROM  FII_FIN_ITEM_HIER_GT
          WHERE child_fin_cat_id = p_child_value_id
            AND next_level_fin_cat_id = child_fin_cat_id
            AND parent_level          = next_level - 1;

     l_count                NUMBER(15):=0;
     l_flex_value           VARCHAR2(120);
     l_vset_name            VARCHAR2(240);
     l_parent_flex_value    VARCHAR2(120);
     l_parent_vset_name     VARCHAR2(240);

   BEGIN

     IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Ent ('FII_FIN_CAT_MAINTAIN_PKG.Detect_Diamond_Shape');
     END IF;

     -- check all value sets: if there is a diamond in any of them
     --   (even values involved are not mapped for the dimension),
     --   report and raise an exception
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

        l_flex_value       := Get_Flex_Value (dup_asg_par_rec.child_fin_cat_id);
        l_vset_name        := Get_Value_Set_Name (dup_asg_par_rec.child_flex_value_set_id);
        l_parent_flex_value:= Get_Flex_Value (dup_asg_par_rec.parent_fin_cat_id);
        l_parent_vset_name := Get_Value_Set_Name (dup_asg_par_rec.parent_flex_value_set_id);

         FII_UTIL.Write_Output (
                           l_flex_value                           || '   '||
                           l_vset_name                            || '   '||
                           l_parent_flex_value                    || '   '||
                           l_parent_vset_name);

       END LOOP;

    END LOOP;

    IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Succ ('FII_FIN_CAT_MAINTAIN_PKG.Detect_Diamond_Shape');
    END IF;

    IF l_count > 0 THEN
      RAISE FINDIM_MULT_PAR_err;
    END IF;

   Exception

     When FINDIM_MULT_PAR_err then
       FII_UTIL.Write_Log ('FII_FIN_CAT_MAINTAIN_PKG.Detect_Diamond_Shape: '||
                         'diamond shape detected!');
       RAISE;

     When others then
        FII_UTIL.Write_Log  (
               'Unexpected error when calling Detect_Diamond_Shape.');
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        RAISE;

   END Detect_Diamond_Shape;

-- *******************************************************************

   PROCEDURE INSERT_IMM_CHILD_NODES
                    (p_vset_id NUMBER, p_root_node VARCHAR2) IS

     --Per suggestion from performance team, add a hint to the select
     --(it uses a new index FII_DIM_NORM_HIER_GT_N1)
     CURSOR direct_children_csr (p_parent_vs_id NUMBER, p_parent_node VARCHAR2) IS
       SELECT /*+ leading(ffvnh) index(ffvnh) */
              ffv.flex_value_id, ffv.flex_value, ffv.flex_value_set_id, attribute_sort_order   sort_order
       FROM   FII_DIM_NORM_HIER_GT ffvnh,
              fnd_flex_values ffv
       WHERE  ffvnh.child_flex_value_set_id = ffv.flex_value_set_id
       AND   (ffv.flex_value BETWEEN ffvnh.child_flex_value_low
                                 AND ffvnh.child_flex_value_high)
       AND   ((ffvnh.range_attribute = 'P' and ffv.summary_flag = 'Y') OR
              (ffvnh.range_attribute = 'C' and ffv.summary_flag = 'N'))
       AND   ffvnh.parent_flex_value        = p_parent_node
       AND   ffvnh.parent_flex_value_set_id = p_parent_vs_id;

     l_flex_value_id number(15);
     l_flex_value_set_id number(15);
     l_sort_order	NUMBER(15);
   BEGIN

    -- IF (FIIDIM_Debug) THEN
    -- FII_MESSAGE.Func_Ent ('FII_COM_MAINTAIN_PKG.INSERT_IMM_CHILD_NODES');
    -- END IF;

    select flex_value_id, attribute_sort_order  into l_flex_value_id, l_sort_order
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
                     NEXT_LEVEL_FLEX_VALUE_ID, SORT_ORDER)
               values
                   ( g_index,
                     l_flex_value_id,
                     l_flex_value_set_id,
                     l_flex_value_id, l_sort_order);

              update FII_DIM_HIER_HELP_GT
                  set NEXT_LEVEL_FLEX_VALUE_ID= l_flex_value_id,
                        SORT_ORDER= l_sort_order
                where IDX = g_index - 1;

     FOR direct_children_rec IN direct_children_csr(p_vset_id, p_root_node)
     LOOP

          /* Inserting record with all parents */
                      INSERT  INTO fii_fin_item_hier_gt (
                              parent_level,
                              parent_fin_cat_id,
                              child_fin_cat_id,
                              next_level,
                              child_level,
                              next_level_is_leaf,
                              is_leaf_flag,
                              parent_flex_value_Set_id,
                              child_flex_value_set_id,
                              next_level_fin_cat_id,
			      next_level_fin_cat_sort_order)
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
                                      pp.next_level_flex_value_id),
			       decode(pp.idx, g_index,
    			              direct_children_rec.sort_order,
    				      pp.sort_order)
                      FROM   FII_DIM_HIER_HELP_GT pp;

        --Recursive Call.
       INSERT_IMM_CHILD_NODES (direct_children_rec.flex_value_set_id,
                               direct_children_rec.flex_value);

     END LOOP;

            /* Deleting parent from the gt table */
            delete from FII_DIM_HIER_HELP_GT where idx = g_index;
            g_index := g_index - 1;

     FND_CONCURRENT.Af_Commit;

     EXCEPTION
       WHEN NO_DATA_FOUND Then
         FII_UTIL.WRITE_LOG ('Insert Immediate child: No Data Found');
         FII_MESSAGE.Func_Fail
	  (func_name =>
		'FII_DIMENSION_MAINTAIN_PKG.Fin_Insert_Imm_Child_Nodes');
         RAISE;

       WHEN OTHERS Then
         FII_UTIL.WRITE_LOG( substr(SQLERRM,1,180));
         FII_MESSAGE.Func_Fail
	  (func_name => 'FII_FIN_CAT_MAINTAIN_PKG.INSERT_IMM_CHILD_NODES');
         RAISE;

   END INSERT_IMM_CHILD_NODES;


-- **************************************************************************
-- This procedure will populate the TMP hierarchy table

    PROCEDURE  Flatten_Fin_Dim_Hier (p_vset_id NUMBER, p_root_node VARCHAR2) IS


        l_flex_value      VARCHAR2(150);
        p_parent_id       NUMBER(15);

    BEGIN

      IF (FIIDIM_Debug) THEN
	      FII_MESSAGE.Func_Ent(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
				     'Flatten_Fin_Dim_Hier');
      END IF;

      g_phase := 'Truncate table FII_FIN_ITEM_HIER_GT';
      FII_UTIL.truncate_table ('FII_FIN_ITEM_HIER_GT', 'FII', g_retcode);

     -----------------------------------------------------------------

      FINDIM_parent_node    := p_root_node;
      FINDIM_parent_vset_id := p_vset_id;

      g_phase := 'Get p_parent_id from FND_FLEX_VALUES';

      SELECT flex_value_id INTO p_parent_id
        FROM FND_FLEX_VALUES
       WHERE flex_value_set_id = p_vset_id
         AND flex_value        = p_root_node;

      FINDIM_parent_flex_id := p_parent_id;

      -- The following Insert statement inserts the top node self row and
      -- invokes Ins_Imm_Child_nodes routine to insert all top node mappings
      -- with in the hierarchy.
      g_phase := 'invoke Ins_Imm_Child_nodes';

      INSERT_IMM_CHILD_NODES (p_vset_id, p_root_node);

      g_phase := 'insert all self nodes';

      insert into fii_fin_item_hier_gt (
                 parent_level,
                 parent_fin_cat_id,
                 next_level,
                 next_level_fin_cat_id,
                 child_level,
                 child_fin_cat_id,
                 child_flex_value_set_id,
                   parent_flex_value_set_id,
                 next_level_is_leaf,
                 is_leaf_flag)
    select
		child_level,
		child_fin_cat_id,
		child_level,
		child_fin_cat_id,
		child_level,
		child_fin_cat_id,
		child_flex_value_set_id,
		child_flex_value_set_id,
		'N',
		'N'
    from (select distinct child_fin_cat_id,child_level,child_flex_value_set_id from fii_fin_item_hier_gt);

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into fii_fin_item_hier_gt');
     END IF;

    g_phase := 'Insert self node for the top node';

    INSERT INTO fii_fin_item_hier_gt
               (parent_level,
                parent_fin_cat_id,
                next_level,
		next_level_fin_cat_id,
                child_level,
                child_fin_cat_id,
                child_flex_value_set_id,
                  parent_flex_value_set_id,
                next_level_is_leaf,
                is_leaf_flag)
        VALUES
	       (1,
                p_parent_id,
                1,
		p_parent_id,
                1,
                p_parent_id,
                p_vset_id,
                FINDIM_parent_vset_id,
                'N',
                'N');

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into fii_fin_item_hier_gt');
     END IF;


      --Call FND_STATS to collect statistics after populating the table
       g_phase := 'gather_table_stats for FII_FIN_ITEM_HIER_GT';

       FND_STATS.gather_table_stats
  	       (ownname	=> g_schema_name,
	        tabname	=> 'FII_FIN_ITEM_HIER_GT');

      --====================================================================
      --Before we proceed to populate the final hierarchy table, we should
      --check if there are any diamond shapes in the TMP hierarchy table.
      --If so, we will report the problem, and error out the program

      -- The following block checks for child value multiple assignments
      -- to different parents within the value sets
      -- We use (just created) TMP table FII_FIN_ITEM_HIER_GT for this purpose
      g_phase := 'Call Detect_Diamond_Shape';

         Detect_Diamond_Shape;

      --====================================================================

      --So far, there is no problem...

      --Update the column next_level_is_leaf
      --We look at those records (P,A,A) in which A is a leaf value
     -- g_phase := 'Update the column next_level_is_leaf';

        --Per suggestion from performance team,
        --rewrite the update statement
          --Update fii_fin_item_hier_gt  tab1
          --   Set next_level_is_leaf = 'Y'
          -- Where tab1.next_level_fin_cat_id = tab1.child_fin_cat_id
          --   And 1 = (select count(*)
          --              from fii_fin_item_hier_gt tab2
          --             where tab2.parent_fin_cat_id = tab1.next_level_fin_cat_id);


        -------------------------------------------------------
        --Currently , there is no need to update this column for
        --the full hierarchy since it's not used anywhere
        -------------------------------------------------------

        --  Note that we use self record (A,A,A) for tab3 here!
        --Update fii_fin_item_hier_gt  tab1
        --   Set  next_level_is_leaf = 'Y'
        -- Where  tab1.next_level_fin_cat_id = tab1.child_fin_cat_id
        --   and  tab1.next_level_fin_cat_id IN (
        --          select /*+ ordered */ tab3.next_level_fin_cat_id
        --            from   fii_fin_item_hier_gt tab3,
        --                   fii_fin_item_hier_gt tab2
        --           where  tab2.parent_fin_cat_id = tab3.parent_fin_cat_id
        --             and  tab3.parent_fin_cat_id = tab3.child_fin_cat_id
        --        group by  tab3.next_level_fin_cat_id
        --          having  count(*) = 1);


     --Update the column is_leaf_flag
     --We look at all records (A,A,A) in which A is a leaf value
    -- g_phase := 'Update the column is_leaf_flag';

       -------------------------------------------------------
       --Currently , there is no need to update this column for
       --the full hierarchy since it's not used anywhere
       -------------------------------------------------------
       --Update fii_fin_item_hier_gt
       --  Set  is_leaf_flag = 'Y'
       --Where parent_fin_cat_id = next_level_fin_cat_id
       --  and next_level_fin_cat_id = child_fin_cat_id
       --  and next_level_is_leaf = 'Y';


     IF (FIIDIM_Debug) THEN
	      FII_MESSAGE.Func_Succ(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
				     'Flatten_Fin_Dim_Hier');
     END IF;

    EXCEPTION

      WHEN  NO_DATA_FOUND THEN
        FII_UTIL.Write_Log('Flatten_Fin_Dim_Hier: No Data Found');
        FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Flatten_Fin_Dim_Hier');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        raise;

       WhEN FINDIM_MULT_PAR_err THEN
         FII_UTIL.WRITE_LOG ('Flatten_Fin_Dim_Hier: Diamond Shape Detected');
         FII_MESSAGE.Func_Fail (func_name =>
		'FII_DIMENSION_MAINTAIN_PKG.Flatten_Fin_Dim_Hier');
         FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
         raise;

      WHEN OTHERS THEN
        FII_UTIL.Write_Log('Flatten_Fin_Dim_Hier: '|| substr(sqlerrm,1,180));
        FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Flatten_Fin_Dim_Hier');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        raise;

    END Flatten_Fin_Dim_Hier;

   -- **************************************************************************
   -- Update next_level_is_leaf and is_leaf_flag in FII_FIN_ITEM_HIER_GT

   PROCEDURE Update_GT  IS

   Begin

    IF (FIIDIM_Debug) THEN
     FII_MESSAGE.Func_Ent(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Update_GT');
    END IF;

    --Update the columns next_level_is_leaf, is_leaf_flag
    --for the latest FII_FIN_ITEM_HIER_GT
    g_phase := 'Update next_level_is_leaf, is_leaf_flag';

      --Update the column next_level_is_leaf
      --We look at those records (P,A,A) in which A is a leaf value

      --Note that we use self record (A,A,A) for tab3 here!
        Update fii_fin_item_hier_gt  tab1
           Set  next_level_is_leaf = 'Y'
         Where  tab1.next_level_fin_cat_id = tab1.child_fin_cat_id
           and  tab1.next_level_fin_cat_id IN (
                  select /*+ ordered */ tab3.next_level_fin_cat_id
                    from   fii_fin_item_hier_gt tab3,
                           fii_fin_item_hier_gt tab2
                   where  tab2.parent_fin_cat_id = tab3.parent_fin_cat_id
                     and  tab3.parent_fin_cat_id = tab3.child_fin_cat_id
                group by  tab3.next_level_fin_cat_id
                  having  count(*) = 1);

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in fii_fin_item_hier_gt');
     END IF;

      g_phase := 'Update is_leaf_flag';

      --Update the column is_leaf_flag
      --We look at all records (A,A,A) in which A is a leaf value
      Update fii_fin_item_hier_gt
        Set  is_leaf_flag = 'Y'
      Where parent_fin_cat_id = next_level_fin_cat_id
        and next_level_fin_cat_id = child_fin_cat_id
        and next_level_is_leaf = 'Y';

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in fii_fin_item_hier_gt');
     END IF;

      IF (FIIDIM_Debug) THEN
	      FII_MESSAGE.Func_Succ(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Update_GT');
      END IF;

    EXCEPTION

      WHEN OTHERS THEN
        FII_UTIL.Write_Log ('Update_GT -> phase: '|| g_phase);
        FII_UTIL.Write_Log ('Update_GT: '|| substr(sqlerrm,1,180));
        FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Update_GT');
        raise;

    END Update_GT;


--**********************************************************************************************
    PROCEDURE Get_level_populated  IS

      -- For BI - 2006
      CURSOR pre_dep_cur IS SELECT * FROM
      (   -- normalized parent-child relationship (one-level)
       select parent_fin_cat_id        pid
            , child_fin_cat_id         cid
            , child_level              clv
            , child_flex_value_set_id  cvs
            , is_leaf_flag             clf
       from fii_fin_item_hier_gt
       where parent_level + 1 = child_level
       --and child_flex_value_set_id = G_MASTER_VALUE_SET_ID
       union all
       select null, G_TOP_NODE_ID, 1, G_MASTER_VALUE_SET_ID, 'N'
       from dual
      )
      START WITH pid is NULL
      CONNECT BY pid = PRIOR cid
      ORDER siblings BY cid;

	-- For BI - 2006
	TYPE stack_type IS VARRAY( 128 ) OF pre_dep_cur%ROWTYPE;

        r_stack stack_type := stack_type(); -- the stack
        c_top number; -- index of the top element of the stack (child level)

        n_top number; -- next level (parent level is p_top defined in the body)
        --p_top1 number;
    BEGIN
       r_stack.extend( 128 );

	----------------------------------------------------------------------
	-- We want to update the newly introduced level columns for BI - 2006
	----------------------------------------------------------------------
         FOR pre_dep_rec IN pre_dep_cur LOOP
            -- put (pop/push) the new child value on the stack
	    c_top := pre_dep_rec.clv;
            r_stack( c_top ) := pre_dep_rec;
            -- loop through the stack for all the parents
          FOR p_top IN 1..c_top LOOP
           -- figure out the next level
           IF p_top = c_top THEN
               n_top := p_top;
           ELSE
               n_top := p_top + 1;
           END IF;

	   FII_UTIL.Write_Log('Updating for parent and child : ' || r_stack( p_top ).cid || ' and ' || r_stack( c_top ).cid );

	    update fii_fin_item_hier_gt
	    set  LEVEL2_fin_cat_ID =  r_stack( least( p_top + 1, c_top) ).cid
               , LEVEL3_fin_cat_ID = r_stack( least( p_top + 2, c_top ) ).cid
               , LEVEL4_fin_cat_ID = r_stack( least( p_top + 3, c_top ) ).cid
               , LEVEL5_fin_cat_ID = r_stack( least( p_top + 4, c_top ) ).cid
	    where parent_fin_cat_id = r_stack( p_top ).cid
	    and   child_fin_cat_id = r_stack( c_top ).cid;

          END LOOP;

         END LOOP;

    END Get_level_populated;

-- **************************************************************************
-- Delete the LVS records from FII_FIN_ITEM_HIER_GT table

   PROCEDURE Delete_LVS_Records  IS

   Begin

    IF (FIIDIM_Debug) THEN
     FII_MESSAGE.Func_Ent(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Delete_LVS_Records');
    END IF;

    --Delete from FII_FIN_ITEM_HIER_GT for child value set not equal to
    --the master value set
    g_phase := 'Delete FII_FIN_ITEM_HIER_GT ';

     Delete from  FII_FIN_ITEM_HIER_GT
      Where child_flex_value_set_id <> G_MASTER_VALUE_SET_ID;


     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows in fii_fin_item_hier_gt');
     END IF;

    Get_level_populated ;

     --Update FII_FIN_ITEM_HIER_GT for pruned hierarchy table for Expense Analysis
     g_phase := 'Update FII_FIN_ITEM_HIER_GT for pruned hierarchy table';

      Update_Gt;

      IF (FIIDIM_Debug) THEN
	      FII_MESSAGE.Func_Succ(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Delete_LVS_Records');
      END IF;


    EXCEPTION

      WHEN OTHERS THEN
        FII_UTIL.Write_Log ('Delete_LVS_Records -> phase: '|| g_phase);
        FII_UTIL.Write_Log ('Delete_LVS_Records: '|| substr(sqlerrm,1,180));
        FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Delete_LVS_Records');
        raise;

    END Delete_LVS_Records;


-- **************************************************************************
-- Populate FII_FIN_CAT_MAPPINGS_GT Table for FIN_CAT_MAPPINGS

   PROCEDURE Get_FC_Mapping_GT  IS

   Begin

   IF (FIIDIM_Debug) THEN
     FII_MESSAGE.Func_Ent(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Get_FC_Mapping_GT');
   END IF;

     --First, populate FII_FIN_CAT_MAPPINGS_GT with the truncated portion
     --of the financial category hierarchy.
     --Note this already includes all self leaf records
     g_phase := 'populate FII_FIN_CAT_MAPPINGS_GT with truncated portion';

     INSERT INTO FII_FIN_CAT_MAPPINGS_GT
          (parent_fin_cat_id,
           child_fin_cat_id)
      SELECT fh.parent_fin_cat_id,
             fh.child_fin_cat_id
        FROM FII_FULL_FIN_ITEM_HIERS fh
       WHERE fh.parent_fin_cat_id IN
           (SELECT ph.parent_fin_cat_id
              FROM FII_FIN_ITEM_HIERARCHIES ph
             WHERE ph.is_leaf_flag = 'Y');

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_CAT_MAPPINGS_GT');
     END IF;

     --Then, insert self-mapping records for all nodes in pruned hierarchy
     --FII_FIN_ITEM_HIERARCHIES. Note we should exclude all self leaf
     --records since they are inserted in the previous step.
     g_phase := 'insert self-mapping records for all nodes in pruned hierarchy';

	INSERT INTO FII_FIN_CAT_MAPPINGS_GT
 	   (parent_fin_cat_id,
            child_fin_cat_id)
 	 SELECT parent_fin_cat_id,
                child_fin_cat_id
 	   FROM FII_FIN_ITEM_HIERARCHIES
 	  WHERE child_flex_value_set_id = G_MASTER_VALUE_SET_ID
 	    AND parent_fin_cat_id = child_fin_cat_id
            AND is_leaf_flag = 'N';

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_CAT_MAPPINGS_GT');
     END IF;

      --Call FND_STATS to collect statistics after populating the table
      g_phase := 'gather_table_stats for FII_FIN_CAT_MAPPINGS_GT';

       FND_STATS.gather_table_stats
  	       (ownname	=> g_schema_name,
	        tabname	=> 'FII_FIN_CAT_MAPPINGS_GT');

     IF (FIIDIM_Debug) THEN
	      FII_MESSAGE.Func_Succ(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.Get_FC_Mapping_GT');
     END IF;

    EXCEPTION

      WHEN OTHERS THEN
        FII_UTIL.Write_Log ('Get_FC_Mapping_GT -> phase: '|| g_phase);
        FII_UTIL.Write_Log ('Get_FC_Mapping_GT: '|| substr(sqlerrm,1,180));
        FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Get_FC_Mapping_GT');
        raise;

    END Get_FC_Mapping_GT;

-- **************************************************************************
-- This procedure will check FC Type assignment using 2 Business Rules:
--    1. A node can not be assigned both Revenue (R)
--         and another expense (i.e. OE, TE, PE)
--    2. A node can not be assigned both Revenue (R)
--         and Cost of Good Sold (CGS)
-- A new business rule for DR is checked:
--    3. Financial categories assigned type DR cannot have any other type
--       assigned.

   PROCEDURE Check_rules_denorm IS

     -- Bug 4152798. Removed literal and introduced a parameter.
     Cursor rev_nodes_cur (p_cat_type VARCHAR2) IS
       select FIN_CATEGORY_ID
         from FII_FC_TYPE_ASSGNS_GT
        where FIN_CAT_TYPE_CODE = p_cat_type;

     Cursor Invalid_Asg_Cur (p_rev_cat_id NUMBER) IS
         select FIN_CATEGORY_ID, FIN_CAT_TYPE_CODE
           from FII_FC_TYPE_ASSGNS_GT
          where FIN_CATEGORY_ID = p_rev_cat_id
            and FIN_CAT_TYPE_CODE in ('OE', 'TE', 'PE', 'CGS');

    -- Bug 4152798. Removed the cursor as this cursor and rev_nodes_cur cursor
    -- are same after removal of the literal.
     -- 2 cursors to check business rule for DR
     --    Cursor def_rev_nodes_cur IS
     --    select FIN_CATEGORY_ID
     --    from FII_FC_TYPE_ASSGNS_GT
     --    where FIN_CAT_TYPE_CODE = 'DR';

     Cursor Conflict_Asg_Cur (p_rev_cat_id NUMBER, p_cat_type VARCHAR2) IS
         select FIN_CATEGORY_ID, FIN_CAT_TYPE_CODE
           from FII_FC_TYPE_ASSGNS_GT
          where FIN_CATEGORY_ID = p_rev_cat_id
            and FIN_CAT_TYPE_CODE <> p_cat_type;

     l_rev_cat_id NUMBER(15);
     l_cat_value  VARCHAR2(60);
     l_count      NUMBER(15):=0;
     l_count_2    NUMBER(15):=0;

    Begin

     IF (FIIDIM_Debug) THEN
	      FII_MESSAGE.Func_Ent (func_name =>
                   'FII_FIN_CAT_MAINTAIN_PKG.check_rules_denorm');
     END IF;

     g_phase := 'check rules for Revenue';

      For rev_node_rec IN rev_nodes_cur('R') LOOP
        l_rev_cat_id := rev_node_rec.FIN_CATEGORY_ID;

        For bad_asg_rec IN Invalid_Asg_Cur (l_rev_cat_id) LOOP
          l_count := l_count + 1;
          if l_count = 1 then

            FII_MESSAGE.write_log(msg_name   => 'FII_INVALID_FCT_ASGN',
	                          token_num  => 0);
            FII_MESSAGE.write_log(msg_name   => 'FII_REFER_TO_OUTPUT',
                                  token_num  => 0);

            FII_MESSAGE.write_output (msg_name   => 'FII_INVALID_FCT_ASGN',
	                              token_num  => 0);
            FII_MESSAGE.write_output (msg_name   => 'FII_INVALID_FCT_TAB',
	                              token_num  => 0);

          end if;

          --bug 3263273: should print out flex value
          l_cat_value := Get_Flex_Value (bad_asg_rec.FIN_CATEGORY_ID);

          FII_UTIL.Write_Output (l_cat_value || ' ,     ' ||
                                          bad_asg_rec.FIN_CAT_TYPE_CODE);
        End Loop;

      END LOOP;

      -- check business rule for DR

     g_phase := 'check rules for Deferred Revenue';

      For def_rev_node_rec IN rev_nodes_cur('DR') LOOP
        l_rev_cat_id := def_rev_node_rec.FIN_CATEGORY_ID;

        For bad_asg_rec IN Conflict_Asg_Cur (l_rev_cat_id, 'DR') LOOP
          l_count_2 := l_count_2 + 1;
          if l_count_2 = 1 then

            FII_MESSAGE.write_log(msg_name   => 'FII_CONFLICT_DR_ASGN',
	                          token_num  => 0);
            FII_MESSAGE.write_log(msg_name   => 'FII_REFER_TO_OUTPUT',
                                  token_num  => 0);

            FII_MESSAGE.write_output (msg_name   => 'FII_CONFLICT_DR_ASGN',
	                              token_num  => 0);
            FII_MESSAGE.write_output (msg_name   => 'FII_CONFLICT_DR_TAB',
	                              token_num  => 0);

          end if;

          l_cat_value := Get_Flex_Value (bad_asg_rec.FIN_CATEGORY_ID);

          FII_UTIL.Write_Output (l_cat_value || ' ,     ' ||
                                          bad_asg_rec.FIN_CAT_TYPE_CODE);
        End Loop;

      END LOOP;

      IF ( l_count > 0 OR l_count_2 > 0 ) then
          RAISE FINDIM_Invalid_FC_ASG_err;
      END IF;

   Exception

     When FINDIM_Invalid_FC_ASG_err then
       FII_UTIL.Write_Log('FII_FIN_CAT_MAINTAIN_PKG.check_rules_denorm: '||
                         'invalid FC Type assignment detected!');
       raise;

     When others then
        FII_UTIL.Write_Log(
               'Unexpected error check_rules_denorm');
	FII_UTIL.WRITE_LOG ( 'Error Message: '|| substr(sqlerrm,1,180));
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        RAISE;

   END  Check_rules_denorm;


-- **************************************************************************
-- Populate the table FII_FIN_CAT_TYPE_ASSGNS from FII_FC_TYPE_NORM_ASSIGN
-- by traveraling the dimension hierarchy table

   Procedure Populate_FCT_denorm (p_initial_load VARCHAR2) IS

      l_sql_rowcount number;

    Begin

      IF (FIIDIM_Debug) THEN
	      FII_MESSAGE.Func_Ent(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.Populate_FTC_denorm');
      END IF;

      --clean up the denorm TMP table
      g_phase := 'Truncate FII_FC_TYPE_ASSGNS_GT';

      FII_UTIL.truncate_table ('FII_FC_TYPE_ASSGNS_GT', 'FII', g_retcode);

      --First, insert records into the denorm TMP table
      --Note that we need to use DISTINCT here since both parent-child
      --can be assigned to same type in FII_FC_TYPE_NORM_ASSIGN
      g_phase := 'insert records into the denorm TMP table';

        Insert into FII_FC_TYPE_ASSGNS_GT
                 (fin_cat_type_code,
                  fin_category_id,
                  top_node_flag)
         select distinct
                  fcn.fin_cat_type_code,
                  hier.child_fin_cat_id,
                  'N'
           from FII_FC_TYPE_NORM_ASSIGN  fcn,
                FII_FULL_FIN_ITEM_HIERS  hier
          where fcn.fin_category_id = hier.parent_fin_cat_id;

     l_sql_rowcount := SQL%ROWCOUNT;

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || l_sql_rowcount || ' rows into FII_FC_TYPE_ASSGNS_GT');
     END IF;

      --Check if there is any Financial Category type assignment in the system
      g_phase := 'Check if there is any Financial Category type assignment';

      if l_sql_rowcount = 0 then
        FII_UTIL.truncate_table ('FII_FIN_CAT_TYPE_ASSGNS', 'FII', g_retcode);
        raise FINDIM_NO_FC_TYPE_ASGN;
      end if;

      --Insert a new internal type (EXP) that contains a distinct list
      --of accounts from the 4 expense categories (TE, OE, PE, CGS)
      --...................................................................
      --BACKGROUND FOR THIS CHANGE: we validate that none of the accounts
      --tagged as Revenue (R) can be tagged with a different type,
      --so that list is unique. We can however have multiple assignments for
      --for a single node between the expense categories (TE, CGS, OE, PE).
      --So we create this new internal type (EXP) that contains a distinct
      --list of accounts from these 4 expense categories.
      --The MVs will now join to this table and pick data for types R and EXP.
      --We would not need to add a col for sign since we know R is +ve and
      --EXP is -ve. This should resolve duplication as well as eliminate data
      --for other account type.
      --....................................................................

        g_phase := 'Insert a new internal type (EXP)';

        Insert into FII_FC_TYPE_ASSGNS_GT
                 (fin_cat_type_code,
                  fin_category_id,
                  top_node_flag)
         select distinct
                  'EXP',
                  fct.fin_category_id,
                  'N'
           from FII_FC_TYPE_ASSGNS_GT fct
          where fct.fin_cat_type_code IN ('OE', 'TE', 'PE', 'CGS');

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FC_TYPE_ASSGNS_GT');
     END IF;

      --Call FND_STATS to collect statistics after populating the table
       g_phase := 'gather_table_stats for FII_FC_TYPE_ASSGNS_GT';

       FND_STATS.gather_table_stats
  	       (ownname	=> g_schema_name,
	        tabname	=> 'FII_FC_TYPE_ASSGNS_GT');

      --Now to update the column TOP_NODE_FLAG
      --For a node with certain fin cat type, look at all nodes in the
      --hierarchy that have the node as the child. If there is only one
      --(i.e. the self node), then this node with the fin cat type is
      --the top node.
      g_phase := 'update the column TOP_NODE_FLAG';

        --Per suggestion from performance team,
        --rewrite the update statement
          --UPDATE  FII_FC_TYPE_ASSGNS_GT tab1
          --   SET  tab1.TOP_NODE_FLAG = 'Y'
          -- WHERE  1 = (select count(*)
          --              from FII_FC_TYPE_ASSGNS_GT   tab2,
          --                   FII_FULL_FIN_ITEM_HIERS hier
          --             where tab2.fin_cat_type_code = tab1.fin_cat_type_code
          --               and hier.child_fin_cat_id  = tab1.fin_category_id
          --               and hier.parent_fin_cat_id = tab2.fin_category_id );

          UPDATE FII_FC_TYPE_ASSGNS_GT tab1
          SET    tab1.TOP_NODE_FLAG = 'Y'
          WHERE  (tab1.fin_cat_type_code,tab1.fin_category_id) IN
                     (select /*+ ordered parallel(hier) */
                             tab3.fin_cat_type_code,tab3.fin_category_id
                        from FII_FC_TYPE_ASSGNS_GT   tab3,
                             FII_FULL_FIN_ITEM_HIERS hier,
                             FII_FC_TYPE_ASSGNS_GT   tab2
                       where tab2.fin_cat_type_code = tab3.fin_cat_type_code
                         and hier.child_fin_cat_id  = tab3.fin_category_id
                         and hier.parent_fin_cat_id = tab2.fin_category_id
                       group by tab3.fin_cat_type_code,
                                tab3.fin_category_id
                      having count(*) = 1);

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_FC_TYPE_ASSGNS_GT');
     END IF;

     --Validate the denorm table by 2 business rules
     g_phase := 'Validate the denorm table by 2 business rules';

       Check_rules_denorm;

     -- Write the TMP table to the final denorm table based on the load mode
     g_phase := 'Write TMP table to final denorm table based on load mode';

      IF p_initial_load = 'Y' THEN  --initial load

        g_phase := 'truncate FII_FIN_CAT_TYPE_ASSGNS';

        FII_UTIL.truncate_table ('FII_FIN_CAT_TYPE_ASSGNS', 'FII', g_retcode);

        g_phase := 'INSERT INTO FII_FIN_CAT_TYPE_ASSGNS';

        INSERT  /*+ APPEND */ INTO FII_FIN_CAT_TYPE_ASSGNS
                 (fin_cat_type_code,
                  fin_category_id,
                  top_node_flag,
                  creation_date,
                  created_by,
                  last_update_date,
                  last_updated_by,
                  last_update_login)
           SELECT  fin_cat_type_code,
                   fin_category_id,
                   top_node_flag,
                   SYSDATE,
                   FII_USER_ID,
                   SYSDATE,
                   FII_USER_ID,
                   FII_LOGIN_ID
             FROM  FII_FC_TYPE_ASSGNS_GT;

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_CAT_TYPE_ASSGNS');
     END IF;

      ELSE   --incremental update

        g_phase := 'DELETE FROM FII_FIN_CAT_TYPE_ASSGNS';

        DELETE FROM FII_FIN_CAT_TYPE_ASSGNS
          WHERE (fin_cat_type_code, fin_category_id, top_node_flag) IN
          (SELECT fin_cat_type_code, fin_category_id, top_node_flag
	   FROM FII_FIN_CAT_TYPE_ASSGNS
	   MINUS
	   SELECT fin_cat_type_code, fin_category_id, top_node_flag
	   FROM FII_FC_TYPE_ASSGNS_GT);

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows from FII_FIN_CAT_TYPE_ASSGNS');
     END IF;

        g_phase := 'Insert into FII_FIN_CAT_TYPE_ASSGNS';

        Insert into FII_FIN_CAT_TYPE_ASSGNS(
          fin_cat_type_code,
          fin_category_id,
          top_node_flag,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login)
         (SELECT
            fin_cat_type_code,
            fin_category_id,
            top_node_flag,
	    SYSDATE,
	    FII_USER_ID,
	    SYSDATE,
	    FII_USER_ID,
	    FII_LOGIN_ID
          FROM FII_FC_TYPE_ASSGNS_GT
          MINUS
          SELECT
             fin_cat_type_code,
             fin_category_id,
             top_node_flag,
	     SYSDATE,
	     FII_USER_ID,
	     SYSDATE,
	     FII_USER_ID,
	     FII_LOGIN_ID
         FROM FII_FIN_CAT_TYPE_ASSGNS);

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_CAT_TYPE_ASSGNS');
     END IF;

       END IF;
     -----------------------------------------

     --Call FND_STATS to collect statistics after re-populating the tables.
       g_phase := 'gather_table_stats for FII_FIN_CAT_TYPE_ASSGNS';

       FND_STATS.gather_table_stats
  	       (ownname	=> g_schema_name,
	        tabname	=> 'FII_FIN_CAT_TYPE_ASSGNS');

      IF p_initial_load = 'Y' THEN

       g_phase := 'gather_table_stats for MLOG$_FII_FIN_CAT_TYPE_ASS';

       FND_STATS.gather_table_stats
  	       (ownname	=> g_schema_name,
	        tabname	=> 'MLOG$_FII_FIN_CAT_TYPE_ASS');
      END IF;

      IF (FIIDIM_Debug) THEN
	      FII_MESSAGE.Func_Succ(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                                         'Populate_FCT_denorm');
      END IF;

    EXCEPTION

      WHEN NO_DATA_FOUND THEN
        FII_UTIL.Write_Log('Populate_FCT_denorm : No Data Found');
        FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                                           'Populate_FCT_denorm');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        raise;

      WHEN FINDIM_NO_FC_TYPE_ASGN THEN
        FII_MESSAGE.write_log(   msg_name   => 'FII_NO_FC_TYPE_ASGN',
                                 token_num  => 0);
        FII_MESSAGE.write_output(msg_name   => 'FII_NO_FC_TYPE_ASGN',
                                 token_num  => 0);
        FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                                           'Populate_FCT_denorm');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        raise;

      WHEN OTHERS THEN
        FII_UTIL.Write_Log('Populate_FCT_denorm: '|| substr(sqlerrm,1,180));
        FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                                           'Populate_FCT_denorm');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
        raise;

   END Populate_FCT_denorm;

-- **************************************************************************
-- If the FIN ITEM dimension is not enabled, truncate the tables and exit.
--

   PROCEDURE Handle_Unenabled_DIM IS

   Begin

    IF (FIIDIM_Debug) THEN
     FII_MESSAGE.Func_Ent(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Handle_Unenabled_DIM');
    END IF;

     FII_UTIL.truncate_table ('FII_FULL_FIN_ITEM_HIERS',  'FII', g_retcode);
     FII_UTIL.truncate_table ('FII_FIN_ITEM_HIERARCHIES', 'FII', g_retcode);
     FII_UTIL.truncate_table ('FII_FIN_CAT_MAPPINGS',     'FII', g_retcode);
     FII_UTIL.truncate_table ('FII_FIN_CAT_TYPE_ASSGNS',  'FII', g_retcode);
     FII_UTIL.truncate_table ('FII_FIN_ITEM_LEAF_HIERS',  'FII', g_retcode);
     FII_UTIL.truncate_table ('FII_FIN_CAT_LEAF_MAPS',    'FII', g_retcode);

    IF (FIIDIM_Debug) THEN
     FII_MESSAGE.Func_Succ(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                             'Handle_Unenabled_DIM');
    END IF;

    EXCEPTION

      WHEN OTHERS THEN
        FII_UTIL.Write_Log ('Handle_Unenabled_DIM: '|| substr(sqlerrm,1,180));
        FII_MESSAGE.Func_Fail(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.'||
                               'Handle_Unenabled_DIM');
        raise;

    END Handle_Unenabled_DIM;

-- **************************************************************************
-- This is the main procedure of FC dimension program (initial populate).

   PROCEDURE Init_Load (errbuf		OUT NOCOPY VARCHAR2,
	 	        retcode		OUT NOCOPY VARCHAR2) IS

    ret_val             BOOLEAN := FALSE;

  BEGIN

    IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Ent(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.Init_Load');
    END IF;

    --First do the initialization

    g_phase := 'Call Initialize';

      Initialize;


    --Secondly populate the table FII_DIM_NORM_HIER_GT

    g_phase := 'Call Get_NORM_HIERARCHY_TMP';

      Get_NORM_HIERARCHY_TMP;


    --Call the Flatten financial item dimension hierarchy routine to
    --insert all mappings.

    g_phase := 'Call Flatten_Fin_Dim_Hier';

     Flatten_Fin_Dim_Hier (G_MASTER_VALUE_SET_ID, G_TOP_NODE_VALUE);

    --Copy TMP hierarchy table to the final dimension table
    g_phase := 'Copy TMP hierarchy table to the final full dimension table';

    FII_UTIL.truncate_table ('FII_FULL_FIN_ITEM_HIERS', 'FII', g_retcode);

     INSERT  /*+ APPEND */ INTO FII_FULL_FIN_ITEM_HIERS (
        parent_level,
        parent_fin_cat_id,
        next_level,
        next_level_fin_cat_id,
        next_level_is_leaf,
        is_leaf_flag,
        child_level,
        child_fin_cat_id,
        parent_flex_value_set_id,
        child_flex_value_set_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
     SELECT
       	parent_level,
      	parent_fin_cat_id,
        next_level,
	next_level_fin_cat_id,
        next_level_is_leaf,
        is_leaf_flag,
	child_level,
	child_fin_cat_id,
        parent_flex_value_set_id,
        child_flex_value_set_id,
	SYSDATE,
	FII_USER_ID,
	SYSDATE,
	FII_USER_ID,
	FII_LOGIN_ID
     FROM  FII_FIN_ITEM_HIER_GT;

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FULL_FIN_ITEM_HIERS');
     END IF;

     commit;

    --Call FND_STATS to collect statistics after re-populating the tables.
    --for the full table since it will be used in the program later

    g_phase := 'gather_table_stats for FII_FULL_FIN_ITEM_HIERS';

     FND_STATS.gather_table_stats
    	(ownname	=> g_schema_name,
    	 tabname	=> 'FII_FULL_FIN_ITEM_HIERS');

    --==============================================================--

    --Delete LVS records from FII_FIN_ITEM_HIER_GT for pruned hierarchy table for Expense Analysis
    g_phase := 'Delete LVS records from FII_FIN_ITEM_HIER_GT for pruned hierarchy table for Expense Analysis';

     Delete_LVS_Records;

     --Copy TMP hierarchy table to the final dimension table for Expense Analysis
     g_phase := 'Copy TMP hierarchy table to the final dimension table for Expense Analysis';

     FII_UTIL.truncate_table ('FII_FIN_ITEM_LEAF_HIERS', 'FII', g_retcode);

    INSERT  /*+ APPEND */ INTO FII_FIN_ITEM_LEAF_HIERS (
        parent_level,
        parent_fin_cat_id,
        next_level,
        next_level_fin_cat_id,
        next_level_is_leaf_flag,
        is_leaf_flag,
        child_level,
        child_fin_cat_id,
        parent_flex_value_set_id,
        child_flex_value_set_id,
	next_level_fin_cat_sort_order,
	aggregate_next_level_flag,
	LEVEL2_fin_cat_ID,
        LEVEL3_fin_cat_ID,
        LEVEL4_fin_cat_ID,
        LEVEL5_fin_cat_ID,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
	is_to_be_rolled_up_flag)
     SELECT
       	parent_level,
      	parent_fin_cat_id,
        next_level,
	next_level_fin_cat_id,
        next_level_is_leaf,
        is_leaf_flag,
	child_level,
	child_fin_cat_id,
        parent_flex_value_set_id,
        child_flex_value_set_id,
	next_level_fin_cat_sort_order,
	'N',
	LEVEL2_fin_cat_ID,
        LEVEL3_fin_cat_ID,
        LEVEL4_fin_cat_ID,
        LEVEL5_fin_cat_ID,
	SYSDATE,
	FII_USER_ID,
	SYSDATE,
	FII_USER_ID,
	FII_LOGIN_ID,
	'N'
     FROM  FII_FIN_ITEM_HIER_GT;

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_LEAF_HIERS');
     END IF;

     commit;

       -- Since leaf nodes are always included we copy FII_FIN_ITEM_HIER_GT to FII_FIN_ITEM_HIERARCHIES
       --Copy FII_FIN_ITEM_HIER_GT hierarchy table to the final dimension table for DBI6.0
       g_phase := 'Copy FII_FIN_ITEM_HIER_GT hierarchy table to the final full dimension table for DBI 6.0';

       FII_UTIL.truncate_table ('FII_FIN_ITEM_HIERARCHIES', 'FII', g_retcode);

       INSERT  /*+ APPEND */ INTO FII_FIN_ITEM_HIERARCHIES (
        parent_level,
        parent_fin_cat_id,
        next_level,
        next_level_fin_cat_id,
        next_level_is_leaf,
        is_leaf_flag,
        child_level,
        child_fin_cat_id,
        parent_flex_value_set_id,
        child_flex_value_set_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
     SELECT
       	parent_level,
      	parent_fin_cat_id,
        next_level,
	next_level_fin_cat_id,
        next_level_is_leaf,
        is_leaf_flag,
	child_level,
	child_fin_cat_id,
        parent_flex_value_set_id,
        child_flex_value_set_id,
	SYSDATE,
	FII_USER_ID,
	SYSDATE,
	FII_USER_ID,
	FII_LOGIN_ID
     FROM  FII_FIN_ITEM_HIER_GT;

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_HIERARCHIES');
     END IF;

     -- We have added an update statement on FII_FIN_ITEM_LEAF_HIERS. Hence, moved gathering statistics
     -- for FII_FIN_ITEM_LEAF_HIERS table and its mlog at the end of procedure.

    --Call FND_STATS to collect statistics after re-populating the tables.
    --Will seed this in RSG
    -- FND_STATS.gather_table_stats
    --   (ownname	=> g_schema_name,
    --    tabname	=> 'FII_FIN_ITEM_HIERARCHIES');

      --to avoid ORA-12838: cannot read/modify an object after modifying
      --it in parallel (due to the hint APPEND)
      commit;

    --================================================================--
    --Populate FII_FIN_CAT_MAPPINGS table
    g_phase := 'Populate FII_FIN_CAT_MAPPINGS_GT table';

         Get_FC_Mapping_GT;

         --Copy FII_FIN_CAT_MAPPINGS_GT to FII_FIN_CAT_LEAF_MAPS
         g_phase := 'Copy TMP FC Mapping table to the FC Mapping Table';

         FII_UTIL.truncate_table ('FII_FIN_CAT_LEAF_MAPS', 'FII', g_retcode);

        INSERT  /*+ APPEND */ INTO FII_FIN_CAT_LEAF_MAPS (
          parent_fin_cat_id,
          child_fin_cat_id,
          creation_date,
          created_by,
          last_update_date,
          last_updated_by,
          last_update_login)
        SELECT
           parent_fin_cat_id,
	   child_fin_cat_id,
	   SYSDATE,
	   FII_USER_ID,
	   SYSDATE,
	   FII_USER_ID,
	   FII_LOGIN_ID
        FROM  FII_FIN_CAT_MAPPINGS_GT;

         IF (FIIDIM_Debug) THEN
          FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_CAT_LEAF_MAPS');
         END IF;

    --Copy FII_FIN_CAT_MAPPINGS_GT to FII_FIN_CAT_MAPPINGS
    g_phase := 'Copy TMP FC Mapping table to the FC Mapping Table';

     FII_UTIL.truncate_table ('FII_FIN_CAT_MAPPINGS', 'FII', g_retcode);

     INSERT  /*+ APPEND */ INTO FII_FIN_CAT_MAPPINGS (
        parent_fin_cat_id,
        child_fin_cat_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
     SELECT
      	parent_fin_cat_id,
	child_fin_cat_id,
	SYSDATE,
	FII_USER_ID,
	SYSDATE,
	FII_USER_ID,
	FII_LOGIN_ID
     FROM  FII_FIN_CAT_MAPPINGS_GT;

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_CAT_MAPPINGS');
     END IF;

    --Call FND_STATS to collect statistics after re-populating the table.

     g_phase := 'gather_table_stats FII_FIN_CAT_MAPPINGS';

     FND_STATS.gather_table_stats
        (ownname	=> g_schema_name,
         tabname	=> 'FII_FIN_CAT_MAPPINGS');

     g_phase := 'gather_table_stats MLOG$_FII_FIN_CAT_MAPPINGS';

     FND_STATS.gather_table_stats
        (ownname	=> g_schema_name,
         tabname	=> 'MLOG$_FII_FIN_CAT_MAPPINGS');

     g_phase := 'gather_table_stats FII_FIN_CAT_LEAF_MAPS';

     FND_STATS.gather_table_stats
        (ownname	=> g_schema_name,
         tabname	=> 'FII_FIN_CAT_LEAF_MAPS');

     g_phase := 'gather_table_stats  MLOG$_FII_FIN_CAT_LEAF_MAP';

     FND_STATS.gather_table_stats
        (ownname	=> g_schema_name,
         tabname	=> 'MLOG$_FII_FIN_CAT_LEAF_MAP');

    --=====================================================================

    --Call to populate the FC Type denorm table
    g_phase := 'Call to populate the FC Type denorm table';

      Populate_FCT_denorm (p_initial_load => 'Y');

    g_phase := 'Update is_to_be_rolled_up_flag flag';

     UPDATE	FII_FIN_ITEM_LEAF_HIERS
     SET	is_to_be_rolled_up_flag = 'Y'
     WHERE	next_level_fin_cat_id in (	SELECT	fin_category_id
					FROM	fii_fin_cat_type_assgns
					WHERE	top_node_flag = 'Y' and
						fin_cat_type_code in ('R','EXP')
				     )
		OR parent_fin_cat_id in   (	SELECT	fin_category_id
					FROM	fii_fin_cat_type_assgns
					WHERE	top_node_flag = 'Y' and
						fin_cat_type_code in ('R','EXP')
				     );

	g_phase := 'Update top_node_fin_cat_type flag for OE';

        -- Updating the records for Category type OE. We give precedence to OE over TE.
	UPDATE fii_fin_item_leaf_hiers
	SET top_node_fin_cat_type = 'OE'
	WHERE next_level_fin_cat_id in (SELECT fin_category_id FROM   fii_fin_cat_type_assgns
	WHERE	top_node_flag = 'Y' AND fin_cat_type_code = 'OE')
	AND next_level_fin_cat_id <> parent_fin_cat_id;

	g_phase := 'Update top_node_fin_cat_type flag for CGS';

        -- Updating the records for Category type OE. We give precedence to CGS over TE
	-- OE and CGS cannot be assigned to the same node so we need not worry about checking
        UPDATE fii_fin_item_leaf_hiers
	SET top_node_fin_cat_type = 'CGS'
	where next_level_fin_cat_id in (SELECT fin_category_id FROM  fii_fin_cat_type_assgns
	WHERE	top_node_flag = 'Y' AND fin_cat_type_code = 'CGS')
	and next_level_fin_cat_id <> parent_fin_cat_id;

        g_phase := 'Update top_node_fin_cat_type flag for other category types';

        -- Updating the records for rest of the Category type.
	UPDATE fii_fin_item_leaf_hiers fin
	SET top_node_fin_cat_type = (SELECT fin_cat_type_code FROM fii_fin_cat_type_assgns
                             WHERE fin_category_id = fin.next_level_fin_cat_id and fin_cat_type_code in ( 'R','TE'))
	WHERE (fin.next_level_fin_cat_id in (SELECT fin_category_id FROM fii_fin_cat_type_assgns
                                     WHERE	top_node_flag = 'Y' AND fin_cat_type_code in ( 'R','TE'))
	AND fin.next_level_fin_cat_id not in (SELECT fin_category_id FROM  fii_fin_cat_type_assgns
                                      WHERE	top_node_flag = 'Y' AND fin_cat_type_code in ('OE', 'CGS')))
	AND next_level_fin_cat_id <> parent_fin_cat_id;



     -- Call FND_STATS to collect statistics of the table.
     g_phase := 'gather_table_stats FII_FIN_ITEM_LEAF_HIERS';

     FND_STATS.gather_table_stats
        (ownname	=> g_schema_name,
         tabname	=> 'FII_FIN_ITEM_LEAF_HIERS');

     g_phase := 'gather_table_stats MLOG$_FII_FIN_ITEM_LEAF_HI';
     FND_STATS.gather_table_stats
        (ownname	=> g_schema_name,
         tabname	=> 'MLOG$_FII_FIN_ITEM_LEAF_HI');

	 commit;  --FND_CONCURRENT.Af_Commit;

    IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Succ(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.Init_Load');
    END IF;

    -- ret_val := FND_CONCURRENT.Set_Completion_Status
    --		        (status	 => 'NORMAL', message => NULL);

    -- Exception handling
  EXCEPTION

    WHEN FINDIM_fatal_err THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log('FII_FIN_CAT_MAINTAIN_PKG.Init_Load: '||
                        'User defined error');
      -- Rollback
      rollback;  --FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_FIN_CAT_MAINTAIN_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN FINDIM_MULT_PAR_err THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log('FII_FIN_CAT_MAINTAIN_PKG.Init_Load: '||
                        'Diamond Shape Detected');
      -- Rollback
      rollback;  --FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_FIN_CAT_MAINTAIN_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN FINDIM_Invalid_FC_ASG_err then
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log('FII_FIN_CAT_MAINTAIN_PKG.Init_Load: '||
                         'Invalid FC Type Assignment Detected');
      -- Rollback
      rollback;  --FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_FIN_CAT_MAINTAIN_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN FINDIM_NOT_ENABLED THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log ('>>> Financial Categories Dimension Not Enabled...');

      Handle_Unenabled_DIM;

      retcode := sqlcode;
      -- ret_val := FND_CONCURRENT.Set_Completion_Status
      -- 		        (status	 => 'NORMAL', message => NULL);

    WHEN FINDIM_NO_FC_TYPE_ASGN THEN
        FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
        FII_UTIL.Write_Log('No Financial Category Type assignment is done.');
        -- Rollback
        rollback;  --FND_CONCURRENT.Af_Rollback;
        FII_MESSAGE.Func_Fail(func_name	=> 'FII_FIN_CAT_MAINTAIN_PKG.Init_Load');
        retcode := sqlcode;
        ret_val := FND_CONCURRENT.Set_Completion_Status
   		        (status	 => 'ERROR',
                 message => 'No Financial Category Type assignment is done.');

    WHEN OTHERS THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log(
          'Other error in FII_FIN_CAT_MAINTAIN_PKG.Init_Load: ' || substr(sqlerrm,1,180));
      -- Rollback
      rollback;  --FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_FIN_CAT_MAINTAIN_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => NULL);

   END Init_Load;


-- *****************************************************************
-- This is the main procedure of FC dimension program (incremental update).

   PROCEDURE Incre_Update (errbuf		OUT NOCOPY VARCHAR2,
	 	           retcode		OUT NOCOPY VARCHAR2) IS

     ret_val             BOOLEAN := FALSE;

   BEGIN

    IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Ent(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.Incre_Load');
    END IF;

    --First do the initialization

    g_phase := 'Call Initialize';


      Initialize;

    --Secondly populate the table FII_DIM_NORM_HIER_GT

    g_phase := 'Call Get_NORM_HIERARCHY_TMP';

      Get_NORM_HIERARCHY_TMP;

    --Call the Flatten financial item dimension hierarchy routine to
    --insert all mappings.

    g_phase := 'Call Flatten_Fin_Dim_Hier';

     Flatten_Fin_Dim_Hier (G_MASTER_VALUE_SET_ID, G_TOP_NODE_VALUE);

     --Copy TMP hierarchy table to the final dimension table
     g_phase := 'Copy TMP hierarchy table to the final full dimension table';

     --FII_FULL_FIN_ITEM_HIERS does not require an incremental refresh.
     FII_UTIL.truncate_table ('FII_FULL_FIN_ITEM_HIERS', 'FII', g_retcode);

     INSERT  /*+ APPEND */ INTO FII_FULL_FIN_ITEM_HIERS (
        parent_level,
        parent_fin_cat_id,
        next_level,
        next_level_fin_cat_id,
        next_level_is_leaf,
        is_leaf_flag,
        child_level,
        child_fin_cat_id,
        parent_flex_value_set_id,
        child_flex_value_set_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
     SELECT
       	parent_level,
      	parent_fin_cat_id,
        next_level,
	next_level_fin_cat_id,
        next_level_is_leaf,
        is_leaf_flag,
	child_level,
	child_fin_cat_id,
        parent_flex_value_set_id,
        child_flex_value_set_id,
	SYSDATE,
	FII_USER_ID,
	SYSDATE,
	FII_USER_ID,
	FII_LOGIN_ID
     FROM  FII_FIN_ITEM_HIER_GT;

     commit;

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FULL_FIN_ITEM_HIERS');
     END IF;

     --Call FND_STATS to collect statistics after re-populating the tables.
     --for the full table since it will be used later in the program

     g_phase := 'gather_table_stats for FII_FULL_FIN_ITEM_HIERS';

       FND_STATS.gather_table_stats
     	      (ownname	=> g_schema_name,
               tabname	=> 'FII_FULL_FIN_ITEM_HIERS');

    --==============================================================--

    --Delete LVS records from FII_FIN_ITEM_HIER_GT for pruned hierarchy table for Expense Analysis
    g_phase := 'Delete LVS records from FII_FIN_ITEM_HIER_GT for pruned hierarchy table for Expense Analysis';

     Delete_LVS_Records;

    --Copy FII_FIN_ITEM_HIER_GT to the final (pruned) dimension table for Expense Analysis

     -- Incremental Dimension Maintence
     -- All data is now in the temporary table FII_FIN_ITEM_HIER_GT,
     -- we need to maintain the permanent table FII_FIN_ITEM__LEAF_HIERS
     -- by diffing the 2 tables.
     -- The maintenance is done by 2 statements, one INSERT and one DELETE.

     g_phase := 'DELETE FROM FII_FIN_ITEM_LEAF_HIERS';

      DELETE FROM FII_FIN_ITEM_LEAF_HIERS
      WHERE
	(parent_level, parent_fin_cat_id, next_level, next_level_fin_cat_id,
         next_level_is_leaf_flag, is_leaf_flag, child_level, child_fin_cat_id,
           parent_flex_value_set_id, child_flex_value_set_id,
	   NVL(next_level_fin_cat_sort_order, -92883),
		  LEVEL2_fin_cat_ID,
		  LEVEL3_fin_cat_ID,
		  LEVEL4_fin_cat_ID,
		  LEVEL5_fin_cat_ID) IN
        (SELECT parent_level, parent_fin_cat_id, next_level, next_level_fin_cat_id,
                next_level_is_leaf_flag, is_leaf_flag, child_level, child_fin_cat_id,
                parent_flex_value_set_id, child_flex_value_set_id,
		NVL(next_level_fin_cat_sort_order, -92883),
			LEVEL2_fin_cat_ID,
		        LEVEL3_fin_cat_ID,
		        LEVEL4_fin_cat_ID,
		        LEVEL5_fin_cat_ID
	 FROM FII_FIN_ITEM_LEAF_HIERS
	 MINUS
	 SELECT parent_level, parent_fin_cat_id, next_level, next_level_fin_cat_id,
                next_level_is_leaf, is_leaf_flag, child_level, child_fin_cat_id,
                parent_flex_value_set_id, child_flex_value_set_id,
		NVL(next_level_fin_cat_sort_order, -92883),
		LEVEL2_fin_cat_ID,
		LEVEL3_fin_cat_ID,
	        LEVEL4_fin_cat_ID,
		LEVEL5_fin_cat_ID
	 FROM FII_FIN_ITEM_HIER_GT);

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows from FII_FIN_ITEM_LEAF_HIERS');
     END IF;

    g_phase := 'Insert into FII_FIN_ITEM_LEAF_HIERS';

      Insert into FII_FIN_ITEM_LEAF_HIERS (
        parent_level,
        parent_fin_cat_id,
        next_level,
        next_level_fin_cat_id,
        next_level_is_leaf_flag,
        is_leaf_flag,
        child_level,
        child_fin_cat_id,
          parent_flex_value_set_id,
          child_flex_value_set_id,
	  next_level_fin_cat_sort_order,
	  aggregate_next_level_flag,
	LEVEL2_fin_cat_ID,
        LEVEL3_fin_cat_ID,
        LEVEL4_fin_cat_ID,
        LEVEL5_fin_cat_ID,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login,
	is_to_be_rolled_up_flag)
       (SELECT 	parent_level,
 	      	parent_fin_cat_id,
                next_level,
		next_level_fin_cat_id,
                next_level_is_leaf,
                is_leaf_flag,
		child_level,
		child_fin_cat_id,
                  parent_flex_value_set_id,
                  child_flex_value_set_id,
		  next_level_fin_cat_sort_order,
		  'N',
		LEVEL2_fin_cat_ID,
		LEVEL3_fin_cat_ID,
	        LEVEL4_fin_cat_ID,
		LEVEL5_fin_cat_ID,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID,
		'N'
        FROM 	FII_FIN_ITEM_HIER_GT
        MINUS
        SELECT 	parent_level,
 	      	parent_fin_cat_id,
                next_level,
		next_level_fin_cat_id,
                next_level_is_leaf_flag,
                is_leaf_flag,
		child_level,
		child_fin_cat_id,
                  parent_flex_value_set_id,
                  child_flex_value_set_id,
		  next_level_fin_cat_sort_order,
		  'N',
		LEVEL2_fin_cat_ID,
	        LEVEL3_fin_cat_ID,
		LEVEL4_fin_cat_ID,
	        LEVEL5_fin_cat_ID,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID,
		'N'
       FROM 	FII_FIN_ITEM_LEAF_HIERS);

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_LEAF_HIERS');
     END IF;

     --Copy FII_FIN_ITEM_HIER_GT to the final (pruned) dimension table for DBI6.0

     -- Incremental Dimension Maintence
     -- All data is now in the temporary table FII_FIN_ITEM_LEAF_HIERS,
     -- we need to maintain the permanent table FII_FIN_ITEM_HIERARCHIES
     -- by diffing the 2 tables.
     -- The maintenance is done by 2 statements, one INSERT and one DELETE.

      g_phase := 'DELETE FROM FII_FIN_ITEM_HIERARCHIES';

      DELETE FROM FII_FIN_ITEM_HIERARCHIES
      WHERE
	(parent_level, parent_fin_cat_id, next_level, next_level_fin_cat_id,
         next_level_is_leaf, is_leaf_flag, child_level, child_fin_cat_id,
           parent_flex_value_set_id, child_flex_value_set_id) IN
        (SELECT parent_level, parent_fin_cat_id, next_level, next_level_fin_cat_id,
                next_level_is_leaf, is_leaf_flag, child_level, child_fin_cat_id,
                parent_flex_value_set_id, child_flex_value_set_id
	 FROM FII_FIN_ITEM_HIERARCHIES
	 MINUS
	 SELECT parent_level, parent_fin_cat_id, next_level, next_level_fin_cat_id,
                next_level_is_leaf, is_leaf_flag, child_level, child_fin_cat_id,
                parent_flex_value_set_id, child_flex_value_set_id
	 FROM FII_FIN_ITEM_HIER_GT);

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows from FII_FIN_ITEM_HIERARCHIES');
     END IF;

    g_phase := 'Insert into FII_FIN_ITEM_HIERARCHIES';

      Insert into FII_FIN_ITEM_HIERARCHIES (
        parent_level,
        parent_fin_cat_id,
        next_level,
        next_level_fin_cat_id,
        next_level_is_leaf,
        is_leaf_flag,
        child_level,
        child_fin_cat_id,
          parent_flex_value_set_id,
          child_flex_value_set_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
       (SELECT 	parent_level,
 	      	parent_fin_cat_id,
                next_level,
		next_level_fin_cat_id,
                next_level_is_leaf,
                is_leaf_flag,
		child_level,
		child_fin_cat_id,
                  parent_flex_value_set_id,
                  child_flex_value_set_id,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
        FROM 	FII_FIN_ITEM_HIER_GT
        MINUS
        SELECT 	parent_level,
 	      	parent_fin_cat_id,
                next_level,
		next_level_fin_cat_id,
                next_level_is_leaf,
                is_leaf_flag,
		child_level,
		child_fin_cat_id,
                  parent_flex_value_set_id,
                  child_flex_value_set_id,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
       FROM 	FII_FIN_ITEM_HIERARCHIES);

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_HIERARCHIES');
     END IF;

	-- We have added an update statement on FII_FIN_ITEM_LEAF_HIERS. Hence, moved gathering statistics
        -- for FII_FIN_ITEM_LEAF_HIERS table at the end of procedure.

     --Call FND_STATS to collect statistics after re-populating the tables.
     --Will seed this in RSG
     --  FND_STATS.gather_table_stats
     --       (ownname	=> g_schema_name,
     --        tabname	=> 'FII_FIN_ITEM_HIERARCHIES');

    --================================================================--
    --Populate FII_FIN_CAT_MAPPINGS table
    g_phase := 'Populate FII_FIN_CAT_MAPPINGS_GT table';

         Get_FC_Mapping_GT;

         --Copy FII_FIN_CAT_MAPPINGS_GT to FII_FIN_CAT_LEAF_MAPS
         g_phase := 'DELETE FROM FII_FIN_CAT_LEAF_MAPS';

      DELETE FROM FII_FIN_CAT_LEAF_MAPS
      WHERE
	(parent_fin_cat_id, child_fin_cat_id) IN
        (SELECT parent_fin_cat_id, child_fin_cat_id
	 FROM FII_FIN_CAT_LEAF_MAPS
	 MINUS
	 SELECT parent_fin_cat_id, child_fin_cat_id
	 FROM FII_FIN_CAT_MAPPINGS_GT);

     IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows from FII_FIN_CAT_LEAF_MAPS');
     END IF;

       g_phase := 'Insert into FII_FIN_CAT_LEAF_MAPS';

      Insert into FII_FIN_CAT_LEAF_MAPS (
        parent_fin_cat_id,
        child_fin_cat_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
       (SELECT 	parent_fin_cat_id,
		child_fin_cat_id,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
        FROM 	FII_FIN_CAT_MAPPINGS_GT
        MINUS
        SELECT 	parent_fin_cat_id,
		child_fin_cat_id,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
        FROM 	FII_FIN_CAT_LEAF_MAPS);

      IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_CAT_LEAF_MAPS');
      END IF;

     --Copy FII_FIN_CAT_MAPPINGS_GT to FII_FIN_CAT_MAPPINGS

     g_phase := 'DELETE FROM FII_FIN_CAT_MAPPINGS';

      DELETE FROM FII_FIN_CAT_MAPPINGS
      WHERE
	(parent_fin_cat_id, child_fin_cat_id) IN
        (SELECT parent_fin_cat_id, child_fin_cat_id
	 FROM FII_FIN_CAT_MAPPINGS
	 MINUS
	 SELECT parent_fin_cat_id, child_fin_cat_id
	 FROM FII_FIN_CAT_MAPPINGS_GT);

      IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows from FII_FIN_CAT_MAPPINGS');
      END IF;

     g_phase := 'Insert into FII_FIN_CAT_MAPPINGS';

      Insert into FII_FIN_CAT_MAPPINGS (
        parent_fin_cat_id,
        child_fin_cat_id,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
       (SELECT 	parent_fin_cat_id,
		child_fin_cat_id,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
        FROM 	FII_FIN_CAT_MAPPINGS_GT
        MINUS
        SELECT 	parent_fin_cat_id,
		child_fin_cat_id,
		SYSDATE,
		FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
        FROM 	FII_FIN_CAT_MAPPINGS);

       IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FIN_CAT_MAPPINGS');
       END IF;

     --Call FND_STATS to collect statistics after re-populating the table.

     g_phase := 'gather_table_stats for FII_FIN_CAT_MAPPINGS';

      FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
          tabname	=> 'FII_FIN_CAT_MAPPINGS');

     -- Bug 4200473. Not to analyze MLOG in incremental run.
     -- As per performance teams suggestions.

     -- g_phase := 'gather_table_stats for MLOG$_FII_FIN_CAT_MAPPINGS';

      -- FND_STATS.gather_table_stats
      -- (ownname	=> g_schema_name,
      --    tabname	=> 'MLOG$_FII_FIN_CAT_MAPPINGS');


     --Call FND_STATS to collect statistics after re-populating the table.

     g_phase := 'gather_table_stats for FII_FIN_CAT_LEAF_MAPS';

      FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
          tabname	=> 'FII_FIN_CAT_LEAF_MAPS');

     -- Bug 4200473. Not to analyze MLOG in incremental run.
     -- As per performance teams suggestions.

     -- g_phase := 'gather_table_stats for MLOG$_FII_FIN_CAT_LEAF_MAP';

      -- FND_STATS.gather_table_stats
      --   (ownname	=> g_schema_name,
      --    tabname	=> 'MLOG$_FII_FIN_CAT_LEAF_MAP');

     --=====================================================================

     --Call to populate the FC Type denorm table
     g_phase := 'Call to populate the FC Type denorm table';

       Populate_FCT_denorm (p_initial_load => 'N');

       g_phase := 'Update is_to_be_rolled_up_flag flag ';

        UPDATE FII_FIN_ITEM_LEAF_HIERS
	SET is_to_be_rolled_up_flag = 'Y'
	WHERE (next_level_fin_cat_id in (  SELECT fin_category_id
					  FROM	 fii_fin_cat_type_assgns
					  WHERE	 top_node_flag = 'Y' and
						 fin_cat_type_code in ('R','EXP')
				        )
	   OR parent_fin_cat_id in   (	  SELECT fin_category_id
					  FROM	 fii_fin_cat_type_assgns
					  WHERE	 top_node_flag = 'Y' and
						 fin_cat_type_code in ('R','EXP')
				     ))
         AND is_to_be_rolled_up_flag <> 'Y' ;

       IF (FIIDIM_Debug) THEN
        FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_LEAF_HIERS');
       END IF;

	g_phase := 'Update top_node_fin_cat_type flag for OE';

        -- Updating the records for Category type OE. We give precedence to OE over TE.
	UPDATE fii_fin_item_leaf_hiers
	SET top_node_fin_cat_type = 'OE'
	WHERE next_level_fin_cat_id IN (SELECT fin_category_id FROM   fii_fin_cat_type_assgns
	WHERE	top_node_flag = 'Y' AND fin_cat_type_code = 'OE')
	AND next_level_fin_cat_id <> parent_fin_cat_id
	AND (top_node_fin_cat_type <> 'OE' OR top_node_fin_cat_type is null);

	IF (FIIDIM_Debug) THEN
         FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_LEAF_HIERS');
        END IF;

	g_phase := 'Update top_node_fin_cat_type flag for CGS';

        -- Updating the records for Category type OE. We give precedence to CGS over TE
	-- OE and CGS cannot be assigned to the same node so we need not worry about checking
        UPDATE fii_fin_item_leaf_hiers
	SET top_node_fin_cat_type = 'CGS'
	where next_level_fin_cat_id IN (SELECT fin_category_id FROM  fii_fin_cat_type_assgns
	WHERE	top_node_flag = 'Y' AND fin_cat_type_code = 'CGS')
	AND next_level_fin_cat_id <> parent_fin_cat_id
	AND (top_node_fin_cat_type <> 'CGS' OR top_node_fin_cat_type is null);

	IF (FIIDIM_Debug) THEN
         FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_LEAF_HIERS');
        END IF;

        g_phase := 'Update top_node_fin_cat_type flag for other category types';

        -- Updating the records for rest of the Category type.
	UPDATE fii_fin_item_leaf_hiers fin
	SET top_node_fin_cat_type = (SELECT fin_cat_type_code FROM fii_fin_cat_type_assgns
                             WHERE fin_category_id = fin.next_level_fin_cat_id and fin_cat_type_code in ( 'R','TE'))
	WHERE (fin.next_level_fin_cat_id in (SELECT fin_category_id FROM fii_fin_cat_type_assgns
                                     WHERE	top_node_flag = 'Y' AND fin_cat_type_code in ( 'R','TE'))
	AND fin.next_level_fin_cat_id not in (SELECT fin_category_id FROM  fii_fin_cat_type_assgns
                                      WHERE	top_node_flag = 'Y' AND fin_cat_type_code in ('OE', 'CGS')))
	AND next_level_fin_cat_id <> parent_fin_cat_id
	AND (top_node_fin_cat_type <> (SELECT fin_cat_type_code FROM fii_fin_cat_type_assgns
                             WHERE fin_category_id = fin.next_level_fin_cat_id and fin_cat_type_code in ( 'R','TE'))
			     OR top_node_fin_cat_type is null);


	-- This update statement is added for the nodes for which there is no category assigned now, but they had one before
	-- This is a valid case
	UPDATE fii_fin_item_leaf_hiers fin
	set top_node_fin_cat_type = NULL
	where next_level_fin_cat_id in (SELECT next_level_fin_cat_id from fii_fin_item_leaf_hiers
					WHERE top_node_fin_cat_type is not null
					MINUS
	                                SELECT fin_category_id FROM fii_fin_cat_type_assgns
                                        WHERE	top_node_flag = 'Y' AND fin_cat_type_code in ( 'R','TE', 'OE', 'CGS')
					)
	AND next_level_fin_cat_id <> parent_fin_cat_id;

        IF (FIIDIM_Debug) THEN
         FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_LEAF_HIERS');
        END IF;

      -- Call FND_STATS to collect statistics of the table.
     g_phase := 'gather_table_stats FII_FIN_ITEM_LEAF_HIERS';

     FND_STATS.gather_table_stats
        (ownname	=> g_schema_name,
         tabname	=> 'FII_FIN_ITEM_LEAF_HIERS');

     -- Bug 4200473. Not to analyze MLOG in incremental run.
     -- As per performance teams suggestions.

     -- g_phase := 'gather_table_stats MLOG$_FII_FIN_ITEM_LEAF_HI';
     -- FND_STATS.gather_table_stats
     --   (ownname	=> g_schema_name,
     --    tabname	=> 'MLOG$_FII_FIN_ITEM_LEAF_HI');

	commit;  --FND_CONCURRENT.Af_Commit;

    IF (FIIDIM_Debug) THEN
     FII_MESSAGE.Func_Succ(func_name => 'FII_FIN_CAT_MAINTAIN_PKG.Incre_Load');
    END IF;

    -- ret_val := FND_CONCURRENT.Set_Completion_Status
    --		        (status	 => 'NORMAL', message => NULL);

     -- Exception handling
   EXCEPTION
     WHEN FINDIM_fatal_err THEN
       FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
       FII_UTIL.Write_Log('FII_FIN_CAT_MAINTAIN_PKG.Incre_Update'||
                         'User defined error');
       -- Rollback
       rollback;  --FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name	=> 'FII_FIN_CAT_MAINTAIN_PKG.Incre_Update');
       retcode := sqlcode;
       ret_val := FND_CONCURRENT.Set_Completion_Status
	        	(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN FINDIM_MULT_PAR_err THEN
      FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
      FII_UTIL.Write_Log('FII_FIN_CAT_MAINTAIN_PKG.Incre_Update: '||
                        'Diamond Shape Detected');
      -- Rollback
      rollback;  --FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_FIN_CAT_MAINTAIN_PKG.Incre_Update');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

     WHEN FINDIM_Invalid_FC_ASG_err then
      FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
      FII_UTIL.Write_Log('FII_FIN_CAT_MAINTAIN_PKG.Incre_Update: '||
                        'Invalid FC Type Assignment Detected');
      -- Rollback
      rollback;  --FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_FIN_CAT_MAINTAIN_PKG.Incre_Update');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

     WHEN FINDIM_NO_FC_TYPE_ASGN THEN
        FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
        FII_UTIL.Write_Log('No Financial Category Type assignment is done.');
        -- Rollback
        rollback;  --FND_CONCURRENT.Af_Rollback;
        FII_MESSAGE.Func_Fail(func_name	=> 'FII_FIN_CAT_MAINTAIN_PKG.Incre_Update');
        retcode := sqlcode;
        ret_val := FND_CONCURRENT.Set_Completion_Status
   		        (status	 => 'ERROR',
                 message => 'No Financial Category Type assignment is done.');

     WHEN FINDIM_NOT_ENABLED THEN
       FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
       FII_UTIL.Write_Log ('>>> Financial Categories Dimension Not Enabled...');

       Handle_Unenabled_DIM;

       retcode := sqlcode;
       -- ret_val := FND_CONCURRENT.Set_Completion_Status
       --		        (status	 => 'NORMAL', message => NULL);

     WHEN OTHERS THEN
       FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
       FII_UTIL.Write_Log(
          'Other error in FII_FIN_CAT_MAINTAIN_PKG.Incre_Update: ' || substr(sqlerrm,1,180));
       -- Rollback
       rollback;  --FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name	=> 'II_FIN_CAT_MAINTAIN_PKG.Incre_Update');
       retcode := sqlcode;
       ret_val := FND_CONCURRENT.Set_Completion_Status
	        	(status	 => 'ERROR', message => substr(sqlerrm,1,180));

   END Incre_Update;

END FII_FIN_CAT_MAINTAIN_PKG;

/
