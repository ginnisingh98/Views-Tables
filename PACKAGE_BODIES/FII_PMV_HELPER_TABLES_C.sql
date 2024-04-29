--------------------------------------------------------
--  DDL for Package Body FII_PMV_HELPER_TABLES_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_PMV_HELPER_TABLES_C" AS
/* $Header: FIIPMVHB.pls 120.1 2005/10/30 05:05:44 appldev noship $ */

	G_PROGRAM_MODE		 VARCHAR2(5);
	G_SUPPORTED_NODES        NUMBER;
	G_NODES			 NUMBER;
	G_OPTIMUM_NODES          NUMBER;
	G_FC_TOP_NODE_ID         NUMBER(15);
	G_CO_TOP_NODE_ID         NUMBER(15);
	G_CC_TOP_NODE_ID         NUMBER(15);
	G_UDD1_TOP_NODE_ID       NUMBER(15);
	G_FC_DBI_ENABLED_FLAG    VARCHAR2(1);
	G_CO_DBI_ENABLED_FLAG    VARCHAR2(1);
	G_CC_DBI_ENABLED_FLAG	 VARCHAR2(1);
	G_UDD1_DBI_ENABLED_FLAG  VARCHAR2(1);
	G_UNASSIGNED_ID		 NUMBER(15);
	g_keep_gain_flag         VARCHAR2(1)   := 'Y';
	G_PHASE                  VARCHAR2(120);
        g_schema_name            VARCHAR2(120)   := 'FII';
        g_retcode                VARCHAR2(20)    := NULL;
        g_debug_mode             VARCHAR2(1)
                     := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

        p_tab dim_nodes_tab;


 -- *******************************************************************
 -- FUNCTION  Dimension_name returns the Dimension name
 -- Parameter : Dimension Short Name
 -- *******************************************************************

 FUNCTION  Dimension_name (dim_short_name VARCHAR2) RETURN VARCHAR2 IS
    l_dimension_name	VARCHAR2(25) := NULL;

  BEGIN

   IF(dim_short_name = 'GL_FII_FIN_ITEM') THEN
	l_dimension_name := 'Financial Category';
   ELSIF (dim_short_name = 'FII_COMPANIES') THEN
        l_dimension_name := 'Company';
   ELSIF (dim_short_name = 'HRI_CL_ORGCC') THEN
        l_dimension_name := 'Cost Center';
   ELSIF (dim_short_name = 'FII_USER_DEFINED_1') THEN
        l_dimension_name := 'User Defined Dimension 1';
   END IF;

   return l_dimension_name;

  END Dimension_name;

-- *******************************************************************
--   Initialize (Get the DBI Enabled flags for all the dimensions)
-- *******************************************************************

   PROCEDURE Initialize  IS
         l_dir        VARCHAR2(160);
	 l_ret_code   number;
	 l_nodes	NUMBER;
	  l_count       number := 4;
	  l_vset_id     number(15);
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
     FII_UTIL.initialize('FII_PMV_HELPER_TABLES_C.log',
                         'FII_PMV_HELPER_TABLES_C.out',l_dir,'FII_PMV_HELPER_TABLES_C');

     -- Obtain FII schema name
     g_schema_name := FII_UTIL.get_schema_name ('FII');

     -- Obtain user ID, login ID and initialize package variables
     g_phase := 'Obtain the User ID and Login ID';
     FII_USER_ID 	:= FND_GLOBAL.USER_ID;
     FII_LOGIN_ID	:= FND_GLOBAL.LOGIN_ID;

     -- If any of the above values is not set, error out
     IF (FII_User_Id is NULL OR FII_Login_Id is NULL) THEN
       FII_UTIL.Write_Log ('>>> Failed Intialization');
       RAISE PMVH_fatal_err;
     END IF;

     -- Determine if process will be run in debug mode
     IF (NVL(G_Debug_Mode, 'N') <> 'N') THEN
       FIIDIM_Debug := TRUE;
       FII_UTIL.Write_Log (' Debug On');
     ELSE
       FIIDIM_Debug := FALSE;
       FII_UTIL.Write_Log (' Debug Off');
     END IF;

     -- Turn trace on if process is run in debug mode
     IF (FIIDIM_Debug) THEN
       -- Program running in debug mode, turning trace on
       EXECUTE IMMEDIATE 'ALTER SESSION SET SQL_TRACE TRUE';
       FII_UTIL.Write_Log ('Initialize: Set Trace On');
     END IF;

     IF (FIIDIM_Debug) THEN
       FII_UTIL.Write_Log ('Initialize: Now start processing '|| 'Helper Table Population');
     End If;

     -- --------------------------------------------------------
     -- Find the unassigned ID
     -- --------------------------------------------------------

      g_phase := 'Find the shipped FII value set id and the unassigned value id';
      FII_GL_EXTRACTION_UTIL.get_unassigned_id(G_UNASSIGNED_ID, l_vset_id, l_ret_code);
      IF(l_ret_code = -1) THEN
        RAISE PMVH_fatal_err;
      END IF;

     -- --------------------------------------------------------
     -- Get the number of nodes which can be aggregated in
     -- each dimension
     -- --------------------------------------------------------
     g_phase := 'Get the profile value for the number of nodes in a dimension';
     BEGIN
        -- Bug 4300047. Default no of nodes to be aggregated
        -- should be 100.
        l_nodes := NVL(fnd_profile.value('FII_AGGREGATE_NODES'), 100);
     EXCEPTION
     WHEN value_error THEN
      FII_UTIL.Write_Log ('Value for profile FII: Nodes to be Aggregated is not set correctly.
			   Please enter a numeric value for the profile.');
      raise;
     END;
     G_SUPPORTED_NODES := POWER(l_nodes,4);

        IF (FIIDIM_Debug) THEN
	  FII_UTIL.Write_Log('Supported number of nodes : ' || G_SUPPORTED_NODES);
        END IF;

     -- --------------------------------------------------------
     -- Get the DBI enabled flag for all the dimensions which
     -- are to be aggregated
     -- We might consider building an api for this
     -- --------------------------------------------------------
         g_phase := 'Getting the DBI Enabled flag for all the dimensions';
          -- Get the enabled flag for FC
	  g_phase := 'Get the enabled flag for FC';

        BEGIN
	  SELECT   DBI_ENABLED_FLAG, DBI_HIER_TOP_NODE_ID
          INTO G_FC_DBI_ENABLED_FLAG, G_FC_TOP_NODE_ID
          FROM FII_FINANCIAL_DIMENSIONS
          WHERE DIMENSION_SHORT_NAME = 'GL_FII_FIN_ITEM';

	  IF(G_FC_DBI_ENABLED_FLAG = 'Y' and G_FC_TOP_NODE_ID is NULL) THEN
	   FII_MESSAGE.write_log (msg_name   => 'FII_TNODE_NOT_FOUND',
				   token_num  => 1,
				   t1         => 'DIM_NAME',
			           v1 	     => Dimension_name('GL_FII_FIN_ITEM'));
           FII_MESSAGE.write_output (msg_name   => 'FII_TNODE_NOT_FOUND',
				   token_num  => 1,
				   t1         => 'DIM_NAME',
			           v1 	     => Dimension_name('GL_FII_FIN_ITEM'));
	   raise PMVH_fatal_err;

          END IF;

	  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
		  FII_UTIL.Write_Log ('Set up for Financial Category not done');
                  G_FC_DBI_ENABLED_FLAG  := 'N';
         END;

          IF (G_FC_DBI_ENABLED_FLAG = 'N') THEN
           l_count := l_count - 1;
          END IF;

	   IF (FIIDIM_Debug) THEN
	    FII_UTIL.Write_Log('DBI Enabled flag for Financial Category : ' || G_FC_DBI_ENABLED_FLAG);
           END IF;

          g_phase := 'Get the enabled flag for Company';
          -- Get the enabled flag for Company
         BEGIN
	  SELECT   DBI_ENABLED_FLAG, DBI_HIER_TOP_NODE_ID
          INTO G_CO_DBI_ENABLED_FLAG, G_CO_TOP_NODE_ID
          FROM FII_FINANCIAL_DIMENSIONS
          WHERE DIMENSION_SHORT_NAME = 'FII_COMPANIES';

	  IF(G_CO_DBI_ENABLED_FLAG = 'Y' and G_CO_TOP_NODE_ID is NULL) THEN
	   FII_MESSAGE.write_log (msg_name   => 'FII_TNODE_NOT_FOUND',
				   token_num  => 1,
				   t1         => 'DIM_NAME',
			           v1 	     => Dimension_name('FII_COMPANIES'));
           FII_MESSAGE.write_output (msg_name   => 'FII_TNODE_NOT_FOUND',
				   token_num  => 1,
				   t1         => 'DIM_NAME',
			           v1 	     => Dimension_name('FII_COMPANIES'));
	   raise PMVH_fatal_err;

          END IF;

	  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
		  FII_UTIL.Write_Log ('Set up for Company not done');
                  G_CO_DBI_ENABLED_FLAG  := 'N';
         END;

	   IF (FIIDIM_Debug) THEN
	    FII_UTIL.Write_Log('DBI Enabled flag for Company : ' || G_CO_DBI_ENABLED_FLAG);
           END IF;

          IF(G_CO_DBI_ENABLED_FLAG = 'N') THEN
           l_count := l_count - 1;
	   l_bool_ret := FND_CONCURRENT.Set_Completion_Status(
				status  => 'WARNING',
				message => 'Company Dimension is not enabled.'
		);
          END IF;

          g_phase := 'Get the enabled flag for CC';
          -- Get the enabled flag for CC
        BEGIN
	  SELECT   DBI_ENABLED_FLAG, DBI_HIER_TOP_NODE_ID
          INTO G_CC_DBI_ENABLED_FLAG, G_CC_TOP_NODE_ID
          FROM FII_FINANCIAL_DIMENSIONS
          WHERE DIMENSION_SHORT_NAME = 'HRI_CL_ORGCC';

	  IF(G_CC_DBI_ENABLED_FLAG = 'Y' and G_CC_TOP_NODE_ID is NULL) THEN
	   FII_MESSAGE.write_log (msg_name   => 'FII_TNODE_NOT_FOUND',
				   token_num  => 1,
				   t1         => 'DIM_NAME',
			           v1 	     => Dimension_name('HRI_CL_ORGCC'));
           FII_MESSAGE.write_output (msg_name   => 'FII_TNODE_NOT_FOUND',
				   token_num  => 1,
				   t1         => 'DIM_NAME',
			           v1 	     => Dimension_name('HRI_CL_ORGCC'));
	   raise PMVH_fatal_err;

          END IF;

	  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
		  FII_UTIL.Write_Log ('Set up for Cost Center not done');
                  G_CC_DBI_ENABLED_FLAG  := 'N';
         END;

	   IF (FIIDIM_Debug) THEN
	    FII_UTIL.Write_Log('DBI Enabled flag for Cost Center : ' || G_CC_DBI_ENABLED_FLAG);
           END IF;

          IF(G_CC_DBI_ENABLED_FLAG = 'N') THEN
           l_count := l_count - 1;
	   l_bool_ret := FND_CONCURRENT.Set_Completion_Status(
				status  => 'WARNING',
				message => 'Cost Center Dimension is not enabled.'
		);
          END IF;

          g_phase := 'Get the enabled flag for udd1';
          -- Get the enabled flag for UDD1

        BEGIN
	  SELECT   DBI_ENABLED_FLAG, DBI_HIER_TOP_NODE_ID
          INTO G_UDD1_DBI_ENABLED_FLAG, G_UDD1_TOP_NODE_ID
          FROM FII_FINANCIAL_DIMENSIONS
          WHERE DIMENSION_SHORT_NAME = 'FII_USER_DEFINED_1';

	  IF(G_UDD1_DBI_ENABLED_FLAG = 'Y' and G_UDD1_TOP_NODE_ID is NULL) THEN
	   FII_MESSAGE.write_log (msg_name   => 'FII_TNODE_NOT_FOUND',
				   token_num  => 1,
				   t1         => 'DIM_NAME',
			           v1 	     => Dimension_name('FII_USER_DEFINED_1'));
           FII_MESSAGE.write_output (msg_name   => 'FII_TNODE_NOT_FOUND',
				   token_num  => 1,
				   t1         => 'DIM_NAME',
			           v1 	     => Dimension_name('FII_USER_DEFINED_1'));
	   raise PMVH_fatal_err;

          END IF;

	  EXCEPTION
                  WHEN NO_DATA_FOUND THEN
		  FII_UTIL.Write_Log ('Set up for User Defined Dimension1 not done');
                  G_UDD1_DBI_ENABLED_FLAG  := 'N';
         END;

          IF(G_UDD1_DBI_ENABLED_FLAG = 'N') THEN
           l_count := l_count - 1;
          END IF;

	   IF (FIIDIM_Debug) THEN
	    FII_UTIL.Write_Log('DBI Enabled flag for User Defined Dimension1 : ' || G_UDD1_DBI_ENABLED_FLAG);
           END IF;

         -- Calculate the initial no of nodes allowed to be aggregated
	 -- in each dimension
	 g_phase := 'Setting the initial number of nodes which can be aggregated for each dimension';
         IF(l_count <> 0) THEN

	  G_NODES := ROUND(POWER(G_SUPPORTED_NODES, 1/l_count));

         END IF;

	   IF (FIIDIM_Debug) THEN
	    FII_UTIL.Write_Log('Number of Nodes supported to be aggregated for each dimension ' || G_NODES);
           END IF;

   Exception
     When PMVH_fatal_err then
       FII_UTIL.Write_Log ('FII_PMV_HELPER_TABLES_C.Initialize : '|| 'User defined error');
       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name => 'FII_PMV_HELPER_TABLES_C.Initialize');
       raise;

     When others then
        FND_CONCURRENT.Af_Rollback;
        FII_UTIL.Write_Log ('Unexpected error when calling Initialize...');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
        RAISE;

   END Initialize;


   -- **************************************************************************************
   -- Populate_Temp procedure ( Populates FII_AGGRT_NODE_GT table with the records from all
   -- the dimensions) This would store the information about the number of children of the
   -- parent and the dimension name for an id.
   -- **************************************************************************************

   Procedure populate_temp IS
   BEGIN

       IF (FIIDIM_Debug) THEN
        FII_MESSAGE.Func_Ent ('FII_PMV_HELPER_TABLES_C.populate_temp');
       END IF;

      g_phase := 'Populate FII_AGGRT_NODE_GT';
      -- For FC Dimension
      If (G_FC_DBI_ENABLED_FLAG = 'Y') THEN
       g_phase :='Populate FII_AGGRT_NODE_GT for Financial Category dimension';
        INSERT INTO FII_AGGRT_NODE_GT (
                            id,
                            no_of_children,
                            dim_short_name)

        select
               NEXT_LEVEL_FIN_CAT_ID,
               subtree_freq,
               'GL_FII_FIN_ITEM'
        from FII_FIN_ITEM_LEAF_HIERS,
             (select h.PARENT_FIN_CAT_ID root_id,
                     count(*) subtree_freq
               from FII_FIN_ITEM_LEAF_HIERS h
               group by h.PARENT_FIN_CAT_ID) g
        where parent_fin_cat_id = g.root_id
        and (PARENT_FIN_CAT_ID <> NEXT_LEVEL_FIN_CAT_ID
         Or NEXT_LEVEL_FIN_CAT_ID = G_FC_TOP_NODE_ID )
        group by PARENT_FIN_CAT_ID,
                 NEXT_LEVEL_FIN_CAT_ID,
                 subtree_freq ;

        IF (FIIDIM_Debug) THEN
	 FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_AGGRT_NODE_GT');
        END IF;

	-- This is done to treat the top node differently
	UPDATE FII_AGGRT_NODE_GT
	SET no_of_children = no_of_children + 1
	WHERE id = G_FC_TOP_NODE_ID ;

	IF (FIIDIM_Debug) THEN
	 FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_AGGRT_NODE_GT');
        END IF;

      ELSE
       -- Populate the unassigned node in case the dimension is disabled
       -- This should never be the case as FC is a mandatory dimension
       g_phase := 'Populate the unassigned node in case the dimension is disabled';
         INSERT INTO FII_AGGRT_NODE_GT (
                            id,
                            no_of_children,
                            dim_short_name)
         VALUES(G_UNASSIGNED_ID, 1, 'GL_FII_FIN_ITEM');

	  IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_AGGRT_NODE_GT');
          END IF;
      END IF;

      -- For Company Dimension
      If (G_CO_DBI_ENABLED_FLAG = 'Y') THEN
       g_phase :='Populate FII_AGGRT_NODE_GT for Company dimension';
        INSERT INTO FII_AGGRT_NODE_GT (
                            id,
                            no_of_children,
                            dim_short_name)

        select
               NEXT_LEVEL_COMPANY_ID,
               subtree_freq,
               'FII_COMPANIES'
        from fii_COMPANY_hierarchies,
             (select h.PARENT_COMPANY_ID root_id,
                     count(*) subtree_freq
               from fii_COMPANY_hierarchies h
               group by h.PARENT_COMPANY_ID) g
        where parent_COMPANY_id = g.root_id
        and PARENT_COMPANY_ID <> NEXT_LEVEL_COMPANY_ID
        group by PARENT_COMPANY_ID,
                 NEXT_LEVEL_COMPANY_ID,
                 subtree_freq ;

        IF (FIIDIM_Debug) THEN
	 FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_AGGRT_NODE_GT');
        END IF;

	-- This is done to treat the top node differently
	 UPDATE FII_AGGRT_NODE_GT
	 SET no_of_children = no_of_children + 1
	 WHERE id = G_CO_TOP_NODE_ID ;

	IF (FIIDIM_Debug) THEN
	 FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_AGGRT_NODE_GT');
        END IF;

     ELSE
       -- Populate the unassigned node in case the dimension is disabled
       g_phase := 'Populate the unassigned node in case the dimension is disabled';
         INSERT INTO FII_AGGRT_NODE_GT (
                            id,
                            no_of_children,
                            dim_short_name)
         VALUES(G_UNASSIGNED_ID, 1, 'FII_COMPANIES');

	  IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_AGGRT_NODE_GT');
          END IF;

      END IF;

      -- For Cost Center
      If (G_CC_DBI_ENABLED_FLAG = 'Y') THEN
        g_phase :='Populate FII_AGGRT_NODE_GT for Cost Center dimension';
        INSERT INTO FII_AGGRT_NODE_GT (
                            id,
                            no_of_children,
                            dim_short_name)

        select
               NEXT_LEVEL_CC_ID,
               subtree_freq,
               'HRI_CL_ORGCC'
        from fii_COST_CTR_hierarchies,
             (select h.PARENT_CC_ID root_id,
                     count(*) subtree_freq
               from fii_COST_CTR_hierarchies h
               group by h.PARENT_CC_ID) g
        where parent_CC_id = g.root_id
        and PARENT_CC_ID <> NEXT_LEVEL_CC_ID
        group by PARENT_CC_ID,
                 NEXT_LEVEL_CC_ID,
                 subtree_freq ;

        IF (FIIDIM_Debug) THEN
	 FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_AGGRT_NODE_GT');
        END IF;

	-- This is done to treat the top node differently
	 UPDATE FII_AGGRT_NODE_GT
	 SET no_of_children = no_of_children + 1
	 WHERE id = G_CC_TOP_NODE_ID ;

	IF (FIIDIM_Debug) THEN
	 FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_AGGRT_NODE_GT');
        END IF;

      ELSE

       -- Populate the unassigned node in case the dimension is disabled
       g_phase := 'Populate the unassigned node in case the dimension is disabled';

         INSERT INTO FII_AGGRT_NODE_GT (
                            id,
                            no_of_children,
                            dim_short_name)
         VALUES(G_UNASSIGNED_ID, 1, 'HRI_CL_ORGCC');

	  IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_AGGRT_NODE_GT');
          END IF;

     END IF;

     -- For UDD1
     If (G_UDD1_DBI_ENABLED_FLAG = 'Y') THEN
      g_phase :='Populate FII_AGGRT_NODE_GT for User Defined dimension1';
       INSERT INTO FII_AGGRT_NODE_GT (
                            id,
                            no_of_children,
                            dim_short_name)

        select NEXT_LEVEL_VALUE_ID,
               subtree_freq,
               'FII_USER_DEFINED_1'
        from fii_UDD1_hierarchies,
             (select h.PARENT_VALUE_ID root_id,
                     count(*) subtree_freq
               from fii_UDD1_hierarchies h
               group by h.PARENT_VALUE_ID) g
        where parent_VALUE_id = g.root_id
        and PARENT_VALUE_ID <> NEXT_LEVEL_VALUE_ID
        group by PARENT_VALUE_ID,
                 NEXT_LEVEL_VALUE_ID,
                 subtree_freq ;

        IF (FIIDIM_Debug) THEN
	 FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_AGGRT_NODE_GT');
        END IF;

	-- This is done to treat the top node differently
	 UPDATE FII_AGGRT_NODE_GT
	 SET no_of_children = no_of_children + 1
	 WHERE id = G_UDD1_TOP_NODE_ID ;

	IF (FIIDIM_Debug) THEN
	 FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_AGGRT_NODE_GT');
        END IF;

      ELSE

       -- Populate the unassigned node in case the dimension is disabled
       g_phase := 'Populate the unassigned node in case the dimension is disabled';

         INSERT INTO FII_AGGRT_NODE_GT (
                            id,
                            no_of_children,
                            dim_short_name)
         VALUES(G_UNASSIGNED_ID, 1, 'FII_USER_DEFINED_1');

	  IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_AGGRT_NODE_GT');
          END IF;

     END IF;

      IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Succ ('FII_PMV_HELPER_TABLES_C.populate_temp');
      END IF;
     --FND_CONCURRENT.Af_Commit;

     EXCEPTION
     When others then
        FND_CONCURRENT.Af_Rollback;
        FII_UTIL.Write_Log ('Unexpected error when calling populate_temp...');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
	raise;

   END populate_temp;

-- *************************************************************************************
-- This is the calculate_sort_nodes procedure. This is to sort the dimensions based on
-- the number of nodes in the dimension
-- *************************************************************************************

   Procedure calculate_sort_nodes IS

         -- cursor to get the number of nodes in a dimension
	 CURSOR dim_no_of_nodes is
         select max (no_of_children) no_of_children, dim_short_name
         from fii_aggrt_node_gt
         group by dim_short_name
         ORDER BY no_of_children;

         I number :=1;

   BEGIN

    IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Ent ('FII_PMV_HELPER_TABLES_C.calculate_sort_nodes');
    END IF;

    For dim_no_of_nodes_rec in dim_no_of_nodes
    LOOP

     IF(dim_no_of_nodes_rec.no_of_children >1) THEN
      ---------------------------------------------------------------------------
      -- In case the number of children is 1 then there is a single node
      -- in the hierarchy which is unassigned node
      -- We subtract 1 because we had added 1 to treat the top node differently
      -- in populate_temp. In case of dimension being disabled it is not added
      -- so it should not be subtracted also.
      ---------------------------------------------------------------------------

      p_tab(I).number_of_nodes := dim_no_of_nodes_rec.no_of_children - 1;
     ELSE
      p_tab(I).number_of_nodes := dim_no_of_nodes_rec.no_of_children;
     END IF;

     p_tab(I).dim_short_name := dim_no_of_nodes_rec.dim_short_name;
     p_tab(I).gain := 1;
	-- The no of nodes here includes unassigned node as well except in FC
         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Dimension : ' || Dimension_name(p_tab(I).dim_short_name) || ' has : ' || p_tab(I).number_of_nodes ||' Nodes.');
         END IF;

     I := I +1;
    END LOOP;

    IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Succ ('FII_PMV_HELPER_TABLES_C.calculate_sort_nodes');
    END IF;

   END calculate_sort_nodes;

-- *************************************************************************************
-- This is the update_hierarchy procedure. This procedure updates the
-- next_level_aggregate_flag for the first two levels for UD1, CC, Company and FC.
-- *************************************************************************************

   Procedure update_hierarchy(p_dim_short_name varchar2) IS
    l_max_level number;
   BEGIN

   IF (FIIDIM_Debug) THEN
    FII_MESSAGE.Func_Ent ('FII_PMV_HELPER_TABLES_C.update_hierarchy');
   END IF;

    -- The first two levels should always be set to aggregated
    -- This is to improve the performance of the reports.

    IF (p_dim_short_name = 'GL_FII_FIN_ITEM') THEN
     -- For FC

     -- Bug 4235853. Treat FC differently since in security api there is an assumption that the level
     -- just below the top node of any category (Expense/Revenue) will be aggregated so
     -- we need to take care that the level just below the top nodes is aggregated for FC.

     g_phase := 'Get the lowest level at which the top node is defined for Revenue';
        select max(child_level) into l_max_level
        from fii_fin_cat_type_assgns, fii_fin_item_leaf_hiers
	where top_node_flag = 'Y'
	and fin_category_id = child_fin_Cat_id
	and parent_level = child_level
	and fin_cat_type_code = 'R';

     -- Updating the first two levels in FC. Also aggregate
     -- atleast one level below the top nodes in FC. The top nodes here would refer to the
     -- top nodes of Revenue/Expenses.

      g_phase := 'Updating the aggregate_next_level flag for Revenue';
      update fii_fin_item_leaf_hiers f
      set aggregate_next_level_flag = 'Y'
      where aggregate_next_level_flag <> 'Y'
      and (next_level in (1,2)
      or (next_level <= l_max_level + 1
          and f.next_level_fin_cat_id in (select fin_category_id
	                                  from fii_fin_cat_type_assgns
					  where fin_cat_type_code = 'R')));

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_LEAF_HIERS');
         END IF;

     g_phase := 'Get the lowest level at which the top node is defined for Expense';
        select max(child_level) into l_max_level
        from fii_fin_cat_type_assgns, fii_fin_item_leaf_hiers
	where top_node_flag = 'Y'
	and fin_category_id = child_fin_Cat_id
	and parent_level = child_level
	and fin_cat_type_code = 'EXP';

      g_phase := 'Updating the aggregate_next_level flag for Expense';
      update fii_fin_item_leaf_hiers f
      set aggregate_next_level_flag = 'Y'
      where aggregate_next_level_flag <> 'Y'
      and (f.next_level <= l_max_level + 1
          and f.next_level_fin_cat_id in (select fin_category_id
	                                  from fii_fin_cat_type_assgns
					  where fin_cat_type_code = 'EXP'));

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_LEAF_HIERS');
         END IF;

      g_phase := 'Updating the FC pmv helper table for the newly aggregated nodes';
      update fii_fc_pmv_agrt_nodes f
      set aggregated_flag = (select aggregate_next_level_flag
                                        from fii_fin_item_leaf_hiers
                                       where next_level_fin_cat_id = f.fin_category_id
				       and parent_level = next_level)
      where aggregated_flag <> (select aggregate_next_level_flag
                                        from fii_fin_item_leaf_hiers
                                       where next_level_fin_cat_id = f.fin_category_id
				       and parent_level = next_level);

	IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_FC_PMV_AGRT_NODES');
        END IF;

       g_phase := 'gather_table_stats for FII_FIN_ITEM_LEAF_HIERS';
       FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
          tabname	=> 'FII_FIN_ITEM_LEAF_HIERS');

     -- Bug 4200473. Not to analyze MLOG in incremental run.
     -- As per performance teams suggestions.

     -- g_phase := 'gather_table_stats MLOG$_FII_FIN_ITEM_LEAF_HI';
     -- FND_STATS.gather_table_stats
     --   (ownname	=> g_schema_name,
     --    tabname	=> 'MLOG$_FII_FIN_ITEM_LEAF_HI');

    ELSIF (p_dim_short_name = 'HRI_CL_ORGCC') THEN
     -- For CC
     g_phase := 'Updating the aggregate_next_level flag for first two levels in CC';
     update fii_cost_ctr_hierarchies f
     set aggregate_next_level_flag = 'Y'
      where aggregate_next_level_flag <> 'Y'
      and next_level in (1,2);


         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_COST_CTR_HIERARCHIES');
         END IF;

      g_phase := 'Updating the Cost Center pmv helper table for the newly aggregated nodes';
      update fii_cc_pmv_agrt_nodes f
      set aggregated_flag = (select aggregate_next_level_flag
                                        from fii_cost_ctr_hierarchies
                                       where next_level_cc_id = f.cost_center_id
				       and parent_level = next_level)
      where aggregated_flag <> (select aggregate_next_level_flag
                                        from fii_cost_ctr_hierarchies
                                       where next_level_cc_id = f.cost_center_id
				       and parent_level = next_level);

	IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_CC_PMV_AGRT_NODES');
        END IF;

       g_phase := 'gather_table_stats for FII_COST_CTR_HIERARCHIES';
       FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
          tabname	=> 'FII_COST_CTR_HIERARCHIES');

     -- Bug 4200473. Not to analyze MLOG in incremental run.
     -- As per performance teams suggestions.

       --g_phase := 'gather_table_stats for MLOG$_FII_COST_CTR_HIERARC';
       --FND_STATS.gather_table_stats
  	--       (ownname	=> g_schema_name,
	--        tabname	=> 'MLOG$_FII_COST_CTR_HIERARC');

    ELSIF (p_dim_short_name = 'FII_COMPANIES') THEN
     -- For Company
     g_phase := 'Updating the aggregate_next_level flag for first two levels in Company';
     update fii_company_hierarchies f
     set aggregate_next_level_flag = 'Y'
      where aggregate_next_level_flag <> 'Y'
      and next_level in (1,2);

	 IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_COMPANY_HIERARCHIES');
         END IF;

      g_phase := 'Updating the Company pmv helper table for the newly aggregated nodes';
      update fii_com_pmv_agrt_nodes f
      set aggregated_flag = (select aggregate_next_level_flag
                                        from fii_company_hierarchies
                                       where next_level_company_id = f.company_id
				       and parent_level = next_level)
      where aggregated_flag <> (select aggregate_next_level_flag
                                        from fii_company_hierarchies
                                       where next_level_company_id = f.company_id
				       and parent_level = next_level);

	IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_COM_PMV_AGRT_NODES');
        END IF;

       g_phase := 'gather_table_stats for FII_COMPANY_HIERARCHIES';
       FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
          tabname	=> 'FII_COMPANY_HIERARCHIES');

     -- Bug 4200473. Not to analyze MLOG in incremental run.
     -- As per performance teams suggestions.

       -- g_phase := 'gather_table_stats for MLOG$_FII_COMPANY_HIERARCH';
       -- FND_STATS.gather_table_stats
  	--        (ownname	=> g_schema_name,
	--        tabname	=> 'MLOG$_FII_COMPANY_HIERARCH');

    ELSIF (p_dim_short_name = 'FII_USER_DEFINED_1') THEN
     -- For UD1
     g_phase := 'Updating the aggregate_next_level flag for first two levels in UD1';
     update fii_udd1_hierarchies f
     set aggregate_next_level_flag = 'Y'
      where aggregate_next_level_flag <> 'Y'
      and next_level in (1,2);

	 IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_UDD1_HIERARCHIES');
         END IF;

      g_phase := 'Updating the User Defined Dimension 1 pmv helper table for the newly aggregated nodes';
      update fii_udd1_pmv_agrt_nodes f
      set aggregated_flag = (select aggregate_next_level_flag
                                        from fii_udd1_hierarchies
                                       where next_level_value_id = f.udd1_value_id
				       and parent_level = next_level)
      where aggregated_flag <> (select aggregate_next_level_flag
                                        from fii_udd1_hierarchies
                                       where next_level_value_id = f.udd1_value_id
				       and parent_level = next_level);

	IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_UDD1_PMV_AGRT_NODES');
        END IF;

       g_phase := 'gather_table_stats for FII_UDD1_HIERARCHIES';
       FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
          tabname	=> 'FII_UDD1_HIERARCHIES');

     -- Bug 4200473. Not to analyze MLOG in incremental run.
     -- As per performance teams suggestions.

      -- g_phase := 'gather_table_stats for MLOG$_FII_UDD1_HIERARCHIES';
      -- FND_STATS.gather_table_stats
  	--       (ownname	=> g_schema_name,
	--        tabname	=> 'MLOG$_FII_UDD1_HIERARCHIES');

    END IF;

    IF (FIIDIM_Debug) THEN
     FII_MESSAGE.Func_Succ ('FII_PMV_HELPER_TABLES_C.update_hierarchy');
    END IF;

   END update_hierarchy;

-- **************************************************************************************
-- This is the Update_pruned_table procedure. This procedure updates the pruned dimension
-- table for aggregate_next_level_flag
-- **************************************************************************************

   Procedure Update_pruned_table (p_dim_short_name varchar2) IS
    l_max_agrt_level number;
   BEGIN

    IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Ent ('FII_PMV_HELPER_TABLES_C.Update_pruned_table');
    END IF;

   -- For FC Dimension
   IF (p_dim_short_name = 'GL_FII_FIN_ITEM') THEN
    IF (G_PROGRAM_MODE = 'INCRE') THEN
     g_phase := 'In IF Update fii_fin_item_leaf_hiers and set the aggregate_next_level_flag';
      update FII_FIN_ITEM_LEAF_HIERS f
      set aggregate_next_level_flag = (select aggregated_flag
                                        from fii_fc_pmv_agrt_nodes
                                       where fin_category_id = f.next_level_fin_cat_id)
      where aggregate_next_level_flag <> (select aggregated_flag
                                           from fii_fc_pmv_agrt_nodes
                                          where fin_category_id = f.next_level_fin_cat_id);

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_LEAF_HIERS');
         END IF;

    ELSE
     g_phase := 'In ELSE Update FII_FIN_ITEM_LEAF_HIERS and set the aggregate_next_level_flag';
      update FII_FIN_ITEM_LEAF_HIERS f
      set aggregate_next_level_flag = (select aggregated_flag
                                       from fii_fc_pmv_agrt_nodes
                                       where fin_category_id = f.next_level_fin_cat_id);

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_FIN_ITEM_LEAF_HIERS');
         END IF;

    END IF;

    -- Bug 4235853
    --select max(next_level) into l_max_agrt_level
    --from fii_fin_item_leaf_hiers
    --where aggregate_next_level_flag = 'Y';

    -- For Company Dimension

   ELSIF (p_dim_short_name = 'FII_COMPANIES') THEN
    IF (G_PROGRAM_MODE = 'INCRE') THEN
     g_phase := 'In IF Update fii_company_hierarchies and set the aggregate_next_level_flag';
      update FII_COMPANY_HIERARCHIES f
      set aggregate_next_level_flag = (select aggregated_flag
                                        from fii_com_pmv_agrt_nodes
                                       where company_id = f.next_level_company_id)
      where aggregate_next_level_flag <> (select aggregated_flag
                                           from fii_com_pmv_agrt_nodes
                                          where company_id = f.next_level_company_id);

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_COMPANY_HIERARCHIES');
         END IF;

    ELSE
     g_phase := 'In ELSE Update fii_company_hierarchies and set the aggregate_next_level_flag';
      update fii_company_hierarchies f
     set aggregate_next_level_flag = (select aggregated_flag
                                       from  fii_com_pmv_agrt_nodes
                                      where company_id = f.next_level_company_id);

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_COMPANY_HIERARCHIES');
         END IF;

    END IF;

    select max(next_level) into l_max_agrt_level
    from fii_company_hierarchies
    where aggregate_next_level_flag = 'Y';

   -- For CC Dimension

   ELSIF (p_dim_short_name = 'HRI_CL_ORGCC') THEN
    IF (G_PROGRAM_MODE = 'INCRE') THEN
     g_phase := 'In IF Update fii_cost_ctr_hierarchies and set the aggregate_next_level_flag';
     update fii_cost_ctr_hierarchies f
     set aggregate_next_level_flag = (select aggregated_flag
                                        from fii_cc_pmv_agrt_nodes
                                       where cost_center_id = f.next_level_cc_id)
      where aggregate_next_level_flag <> (select aggregated_flag
                                           from fii_cc_pmv_agrt_nodes
                                          where cost_center_id = f.next_level_cc_id);

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_COST_CTR_HIERARCHIES');
         END IF;

    ELSE
     g_phase := 'In ELSE Update fii_cost_ctr_hierarchies and set the aggregate_next_level_flag';
     update fii_cost_ctr_hierarchies f
     set aggregate_next_level_flag = (select aggregated_flag
                                     from  fii_cc_pmv_agrt_nodes
                                     where cost_center_id = f.next_level_cc_id);

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_COST_CTR_HIERARCHIES');
         END IF;

    END IF;

    select max(next_level) into l_max_agrt_level
    from fii_cost_ctr_hierarchies
    where aggregate_next_level_flag = 'Y';

    -- For UDD1 Dimension

   ELSIF (p_dim_short_name = 'FII_USER_DEFINED_1') THEN
    IF (G_PROGRAM_MODE = 'INCRE') THEN
     g_phase := 'In IF Update fii_udd1_hierarchies and set the aggregate_next_level_flag';
     update fii_udd1_hierarchies f
     set aggregate_next_level_flag = (select aggregated_flag
                                        from fii_udd1_pmv_agrt_nodes
                                       where UDD1_VALUE_ID = f.next_level_value_id)
      where aggregate_next_level_flag <> (select aggregated_flag
                                           from fii_udd1_pmv_agrt_nodes
                                          where UDD1_VALUE_ID = f.next_level_value_id);

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_UDD1_HIERARCHIES');
         END IF;

    ELSE
     g_phase := 'In ELSE Update fii_udd1_hierarchies and set the aggregate_next_level_flag';
     update fii_udd1_hierarchies f
     set aggregate_next_level_flag = (select aggregated_flag
                                      from fii_udd1_pmv_agrt_nodes
                                      where UDD1_VALUE_ID = f.next_level_value_id);

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows into FII_UDD1_HIERARCHIES');
         END IF;

    END IF;

    select max(next_level) into l_max_agrt_level
    from fii_udd1_hierarchies
    where aggregate_next_level_flag = 'Y';

   END IF;

   -- Bug 4235853
   IF(p_dim_short_name = 'GL_FII_FIN_ITEM') THEN
     -- Treat FC differently since it can have top nodes at deeper levels as well
     -- This needs to be called always
     update_hierarchy(p_dim_short_name);
   ELSE
    IF(l_max_agrt_level < 2) THEN
      -- Call update_hierarchy to update the first two levels always
      -- if not already updated
      g_phase := 'Calling update_hierarchy';
      update_hierarchy(p_dim_short_name);
    END IF;
   END IF;

    IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Succ ('FII_PMV_HELPER_TABLES_C.Update_pruned_table');
    END IF;

    EXCEPTION
     When others then
        FND_CONCURRENT.Af_Rollback;
        FII_UTIL.Write_Log ('Unexpected error when calling Update_pruned_table...');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
	raise;

END Update_pruned_table;

-- *************************************************************************************
-- This is the update_viewby_flag procedure. This procedure updates the for_viewby_flag
-- in the pmv helper tables of all the dimensions
-- *************************************************************************************

   Procedure update_viewby_flag (p_dim_short_name varchar2) IS
   BEGIN

     IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Ent ('FII_PMV_HELPER_TABLES_C.update_viewby_flag');
     END IF;

    -- For FC Dimension
    IF (p_dim_short_name = 'GL_FII_FIN_ITEM') THEN

     g_phase := 'Update FII_FC_PMV_AGRT_NODES for Financial Category';

     UPDATE FII_FC_PMV_AGRT_NODES
     set for_viewby_flag = 'Y'
     WHERE fin_category_id in ( select next_level_fin_cat_id
 				from FII_FIN_ITEM_LEAF_HIERS f1
                               where (f1.is_leaf_flag = 'Y' and f1.aggregate_next_level_flag = 'Y')
                               or exists ( select aggregate_next_level_flag
                                             from FII_FIN_ITEM_LEAF_HIERS f2
                                            where f1.next_level_fin_cat_id =  f2.parent_fin_cat_id
                                              and f2.aggregate_next_level_flag = 'Y'
                                              and f2.parent_fin_cat_id <> f2.next_level_fin_cat_id));
     IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_FC_PMV_AGRT_NODES');
     END IF;


    ELSIF (p_dim_short_name = 'FII_COMPANIES') THEN
     g_phase := 'Update FII_COM_PMV_AGRT_NODES for Company';

     UPDATE FII_COM_PMV_AGRT_NODES
     set for_viewby_flag = 'Y'
     WHERE company_id in ( select next_level_company_id
 					from FII_COMPANY_HIERARCHIES f1
                               where (f1.is_leaf_flag = 'Y' and f1.aggregate_next_level_flag = 'Y')
                               or exists ( select aggregate_next_level_flag
                                             from FII_COMPANY_HIERARCHIES f2
                                            where f1.next_level_company_id =  f2.parent_company_id
                                              and f2.aggregate_next_level_flag = 'Y'
                                              and f2.parent_company_id <> f2.next_level_company_id));

     IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_COM_PMV_AGRT_NODES');
     END IF;


    ELSIF (p_dim_short_name = 'HRI_CL_ORGCC') THEN
     g_phase := 'Update FII_CC_PMV_AGRT_NODES for Cost Center';

     UPDATE FII_CC_PMV_AGRT_NODES
     set for_viewby_flag = 'Y'
     WHERE cost_center_id in ( select next_level_cc_id
 				from FII_COST_CTR_HIERARCHIES f1
                               where (f1.is_leaf_flag = 'Y' and f1.aggregate_next_level_flag = 'Y')
                               or exists ( select aggregate_next_level_flag
                                             from FII_COST_CTR_HIERARCHIES f2
                                            where f1.next_level_cc_id =  f2.parent_cc_id
                                              and f2.aggregate_next_level_flag = 'Y'
                                              and f2.parent_cc_id <> f2.next_level_cc_id));

      IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_CC_PMV_AGRT_NODES');
     END IF;

    ELSIF (p_dim_short_name = 'FII_USER_DEFINED_1') THEN
     g_phase := 'Update FII_UDD1_PMV_AGRT_NODES for User Defined Dimension1';

     UPDATE FII_UDD1_PMV_AGRT_NODES
     set for_viewby_flag = 'Y'
     WHERE udd1_value_id in ( select next_level_value_id
 					from FII_UDD1_HIERARCHIES f1
                               where (f1.is_leaf_flag = 'Y' and f1.aggregate_next_level_flag = 'Y')
                               or exists ( select aggregate_next_level_flag
                                             from FII_UDD1_HIERARCHIES f2
                                            where f1.next_level_value_id =  f2.parent_value_id
                                              and f2.aggregate_next_level_flag = 'Y'
                                              and f2.parent_value_id <> f2.next_level_value_id));

     IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_UDD1_PMV_AGRT_NODES');
     END IF;

    END IF;

     IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Succ ('FII_PMV_HELPER_TABLES_C.update_viewby_flag');
     END IF;

   EXCEPTION
     When others then
        FND_CONCURRENT.Af_Rollback;
        FII_UTIL.Write_Log ('Unexpected error when calling update_viewby_flag...');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
	raise;

   END update_viewby_flag;


-- ******************************************************************************************
-- This is the Populate_PMV_Helper_GT procedure. This procedure populates helper tables of
-- all the dimensions.
-- ******************************************************************************************
   PROCEDURE Populate_PMV_Helper_GT (p_dim_short_name varchar2,
                    p_number_of_nodes number, gain  out nocopy number) IS
   l_subtree_freq number;
   l_row_number number;
   l_nodes_aggregated number;
   l_bool varchar2(1) := 'N';

   BEGIN

    IF (FIIDIM_Debug) THEN
     FII_MESSAGE.Func_Ent ('FII_PMV_HELPER_TABLES_C.Populate_PMV_Helper_GT');
    END IF;

    l_nodes_aggregated := G_OPTIMUM_NODES;

    IF (p_number_of_nodes <= G_OPTIMUM_NODES) THEN
    -- In this case all the nodes will be aggregated
       -- For FC Dimension
       IF (p_dim_short_name = 'GL_FII_FIN_ITEM') THEN
         g_phase := 'Inserting into fii_fc_pmv_agrt_nodes for FC';
         Insert into fii_fc_pmv_agrt_nodes(FIN_CATEGORY_ID,
	                                for_viewby_flag,
                                        aggregated_flag,
				        LAST_UPDATE_DATE,
					LAST_UPDATED_BY,
					CREATION_DATE,
					CREATED_BY ,
					LAST_UPDATE_LOGIN)
        (select next_level_fin_cat_id, 'Y','Y',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
         from FII_FIN_ITEM_LEAF_HIERS
         where parent_level= next_level
         ) ;

         IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FC_PMV_AGRT_NODES');
         END IF;
       --For Company Dimension
       ELSIF (p_dim_short_name = 'FII_COMPANIES') THEN
         g_phase := 'Inserting into fii_com_pmv_agrt_nodes for Company';
         Insert into fii_com_pmv_agrt_nodes(COMPANY_ID,
	                        for_viewby_flag,
                                aggregated_flag,
			        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY ,
				CREATION_DATE ,
				CREATED_BY  ,
				LAST_UPDATE_LOGIN)
         (select next_level_company_id, 'Y','Y',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
          from fii_company_hierarchies
          where parent_level= next_level
          );

	  IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_COM_PMV_AGRT_NODES');
          END IF;

       --For CC Dimension
       ELSIF (p_dim_short_name = 'HRI_CL_ORGCC') THEN
         g_phase := 'Inserting into fii_cc_pmv_agrt_nodes for CC';
        Insert into fii_cc_pmv_agrt_nodes(COST_CENTER_ID,
                                for_viewby_flag,
                                aggregated_flag,
			        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_LOGIN)
         (select next_level_cc_id, 'Y','Y',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
          from fii_cost_ctr_hierarchies
          where parent_level= next_level
         )  ;

	 IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_CC_PMV_AGRT_NODES');
         END IF;

       --For UDD1
       ELSIF (p_dim_short_name = 'FII_USER_DEFINED_1') THEN
         g_phase := 'Inserting into fii_udd1_pmv_agrt_nodes for UDD1';
        Insert into fii_udd1_pmv_agrt_nodes(UDD1_VALUE_ID,
                                for_viewby_flag,
                                aggregated_flag,
			        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_LOGIN)
        (select next_level_value_id, 'Y','Y',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
         from fii_udd1_hierarchies
         where parent_level= next_level
        )  ;

	 IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_UDD1_PMV_AGRT_NODES');
         END IF;

       END IF;

    ELSE
    -- Insert the records which will be aggregated the pmv helper table
    g_phase := 'Getting the minimum frequency for which we want to aggregate';
    SELECT MIN (no_of_children), MAX (rn)
    INTO l_subtree_freq, l_row_number
    FROM (SELECT no_of_children,
             row_number() over (order by NO_OF_CHILDREN desc) rn
          FROM FII_AGGRT_NODE_GT
          WHERE dim_short_name = p_dim_short_name)
    WHERE   rn  < =  G_OPTIMUM_NODES;

   BEGIN
    -- Check if we need to add 1 to l_subtree_freq or not
    g_phase := 'Checking if we need to add 1 to the minimum frequency';
    SELECT 'Y' into l_bool
    FROM (SELECT no_of_children,
             row_number() over (order by NO_OF_CHILDREN desc) rn
          FROM FII_AGGRT_NODE_GT
          WHERE dim_short_name = p_dim_short_name)
     WHERE rn > l_row_number
     AND   no_of_children = l_subtree_freq
     AND rownum <2;

    EXCEPTION
    WHEN NO_DATA_FOUND THEN
     NULL;
    END;

     IF l_bool = 'Y' or l_subtree_freq = 0 THEN
       l_subtree_freq := l_subtree_freq + 1;
     END IF;

     IF (p_dim_short_name = 'GL_FII_FIN_ITEM') THEN

	g_phase := 'Inserting into fii_fc_pmv_agrt_nodes from fii_aggrt_node_gt';
	     Insert into FII_FC_PMV_AGRT_NODES(FIN_CATEGORY_ID,
                                   aggregated_flag,
                                   for_viewby_flag,
     	   		        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_LOGIN)

	      select ID, 'Y', 'N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	      FROM FII_AGGRT_NODE_GT
	      where dim_short_name = p_dim_short_name
	      AND no_of_children >= l_subtree_freq;

	      IF (FIIDIM_Debug) THEN
		   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FC_PMV_AGRT_NODES');
	      END IF;
     ELSIF (p_dim_short_name = 'FII_COMPANIES') THEN

	g_phase := 'Inserting into fii_com_pmv_agrt_nodes from fii_aggrt_node_gt';
	     Insert into FII_COM_PMV_AGRT_NODES(COMPANY_ID,
                                   aggregated_flag,
                                   for_viewby_flag,
     	   		        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_LOGIN)

	      select ID, 'Y', 'N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	      FROM FII_AGGRT_NODE_GT
	      where dim_short_name = p_dim_short_name
	      AND no_of_children >= l_subtree_freq;

	      IF (FIIDIM_Debug) THEN
		   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_COM_PMV_AGRT_NODES');
	      END IF;

     ELSIF (p_dim_short_name = 'HRI_CL_ORGCC') THEN

	g_phase := 'Inserting into fii_cc_pmv_agrt_nodes from fii_aggrt_node_gt';
	     Insert into FII_CC_PMV_AGRT_NODES(COST_CENTER_ID,
                                   aggregated_flag,
                                   for_viewby_flag,
     	   		        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_LOGIN)

	      select ID, 'Y', 'N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	      FROM FII_AGGRT_NODE_GT
	      where dim_short_name = p_dim_short_name
	      AND no_of_children >= l_subtree_freq;

	      IF (FIIDIM_Debug) THEN
		   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_CC_PMV_AGRT_NODES');
	      END IF;

     ELSIF (p_dim_short_name = 'FII_USER_DEFINED_1') THEN

	g_phase := 'Inserting into fii_udd1_pmv_agrt_nodes from fii_aggrt_node_gt';
	     Insert into FII_UDD1_PMV_AGRT_NODES(UDD1_VALUE_ID,
                                   aggregated_flag,
                                   for_viewby_flag,
     	   		        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_LOGIN)

	      select ID, 'Y', 'N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	      FROM FII_AGGRT_NODE_GT
	      where dim_short_name = p_dim_short_name
	      AND no_of_children >= l_subtree_freq;

	      IF (FIIDIM_Debug) THEN
		   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_UDD1_PMV_AGRT_NODES');
	      END IF;
     END IF;

    -- Insert the records which will not be aggregated
    -- For FC Dimension.

    IF (p_dim_short_name = 'GL_FII_FIN_ITEM') THEN
       g_phase := 'Inserting records which will not be aggregated into fii_fc_pmv_agrt_nodes for FC';
       Insert into fii_fc_pmv_agrt_nodes(FIN_CATEGORY_ID, for_viewby_flag,
                                aggregated_flag,
     	   		        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_LOGIN)
       (select next_level_fin_cat_id, 'N','N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
        from FII_FIN_ITEM_LEAF_HIERS
        where parent_level= next_level
        minus
        select fin_category_id, 'N', 'N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	from fii_fc_pmv_agrt_nodes);

	 IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_FC_PMV_AGRT_NODES');
         END IF;

    --For Company Dimension
    ELSIF (p_dim_short_name = 'FII_COMPANIES') THEN

        g_phase := 'Inserting records which will not be aggregated into fii_com_pmv_agrt_nodes for Company';
        Insert into fii_com_pmv_agrt_nodes(company_id, for_viewby_flag,
                                aggregated_flag,
     	   		        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_LOGIN)
        (select next_level_company_id, 'N','N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	 from fii_company_hierarchies
	 where parent_level= next_level
	 minus
	 select company_id, 'N', 'N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	from fii_com_pmv_agrt_nodes);

	 IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_COM_PMV_AGRT_NODES');
         END IF;

    --For CC Dimension
    ELSIF (p_dim_short_name = 'HRI_CL_ORGCC') THEN

        g_phase := 'Inserting records which will not be aggregated into fii_cc_pmv_agrt_nodes_gt for Cost Center';
	Insert into fii_cc_pmv_agrt_nodes(cost_center_id, for_viewby_flag,
                                aggregated_flag,
     	   		        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_LOGIN)
	(select next_level_cc_id, 'N','N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	 from fii_cost_ctr_hierarchies
	 where parent_level= next_level
	 minus
	 select cost_center_id, 'N', 'N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	from fii_cc_pmv_agrt_nodes)  ;

	 IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_CC_PMV_AGRT_NODES');
         END IF;

    --For UDD1
     ELSIF (p_dim_short_name = 'FII_USER_DEFINED_1') THEN

         g_phase := 'Inserting records which will not be aggregated into fii_udd1_pmv_agrt_nodes for UDD1';
	 Insert into fii_udd1_pmv_agrt_nodes(UDD1_VALUE_ID, for_viewby_flag,
                                aggregated_flag,
     	   		        LAST_UPDATE_DATE ,
				LAST_UPDATED_BY,
				CREATION_DATE,
				CREATED_BY,
				LAST_UPDATE_LOGIN)
	(select next_level_value_id, 'N','N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	from fii_udd1_hierarchies
	where parent_level= next_level
	minus
	select udd1_value_id, 'N', 'N',
	        SYSDATE,
	        FII_USER_ID,
		SYSDATE,
		FII_USER_ID,
		FII_LOGIN_ID
	from fii_udd1_pmv_agrt_nodes) ;

	 IF (FIIDIM_Debug) THEN
	   FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_UDD1_PMV_AGRT_NODES');
         END IF;

    END IF;

  END IF;

    g_phase := 'Update the Pruned hierarchy table of the dimension';
    Update_pruned_table(p_dim_short_name);

    g_phase := 'Update the viewby flag in the PMV Helper table of the dimension';
    -- Update for view by flag only if required
    IF (p_number_of_nodes > G_OPTIMUM_NODES) THEN
      update_viewby_flag(p_dim_short_name);
    END IF;

   --Finally calculate the gain for the larger dimensions
   g_phase := 'Calculate the gain if required for the next dimension';

     IF(G_KEEP_GAIN_FLAG='Y') THEN

      IF(p_dim_short_name = 'GL_FII_FIN_ITEM') THEN
       SELECT count(*) into l_nodes_aggregated
       FROM FII_FC_PMV_AGRT_NODES
       WHERE aggregated_flag = 'Y';
      ELSIF(p_dim_short_name = 'FII_COMPANIES') THEN
       SELECT count(*) into l_nodes_aggregated
       FROM FII_COM_PMV_AGRT_NODES
       WHERE aggregated_flag = 'Y';
      ELSIF(p_dim_short_name = 'HRI_CL_ORGCC') THEN
       SELECT count(*) into l_nodes_aggregated
       FROM FII_CC_PMV_AGRT_NODES
       WHERE aggregated_flag = 'Y';
      ELSIF(p_dim_short_name = 'FII_USER_DEFINED_1') THEN
       SELECT count(*) into l_nodes_aggregated
       FROM FII_UDD1_PMV_AGRT_NODES
       WHERE aggregated_flag = 'Y';
      END IF;

       -- this case won't arise but to avoid a zero divisor in the next step
       IF(l_nodes_aggregated = 0) THEN
        l_nodes_aggregated := 1;
       END IF;

       IF(l_nodes_aggregated > G_OPTIMUM_NODES) THEN
        -- This is because if the no of nodes to be aggregated is less then also
	-- we always aggregate 2 levels atleast. In such a case the no of
	-- nodes actually aggregated is large than the no to be aggregated
	-- and so G_OPTIMUM_NODES / l_nodes_aggregated would return 0 in that case
	-- which is not required as this would set the gain to be 0 for next dimensions.
        l_nodes_aggregated := G_OPTIMUM_NODES;
       END IF;

     END IF;

       gain := G_OPTIMUM_NODES / l_nodes_aggregated ;

      IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Succ ('FII_PMV_HELPER_TABLES_C.Populate_PMV_Helper_GT');
      END If;

    EXCEPTION
     When others then
        FND_CONCURRENT.Af_Rollback;
        FII_UTIL.Write_Log ('Unexpected error when calling Populate_PMV_Helper_GT...');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
	raise;

END Populate_PMV_Helper_GT;

-- *************************************************************************************
-- This is the truncate_helper_tables procedure. This is to truncate all the helper
-- tables.
-- *************************************************************************************

   Procedure truncate_helper_tables IS
    PMVH_lock_err        EXCEPTION;
   BEGIN

    IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Ent ('FII_PMV_HELPER_TABLES_C.truncate_helper_tables');
    END IF;

     g_phase := 'Truncate all the helper tables';
     FII_UTIL.truncate_table ('FII_FC_PMV_AGRT_NODES',  'FII', g_retcode);
     IF(g_retcode = '-1') THEN
      raise PMVH_lock_err;
     END IF;

     FII_UTIL.truncate_table ('FII_COM_PMV_AGRT_NODES', 'FII', g_retcode);
     IF(g_retcode = '-1') THEN
      raise PMVH_lock_err;
     END IF;

     FII_UTIL.truncate_table ('FII_CC_PMV_AGRT_NODES',  'FII', g_retcode);
     IF(g_retcode = '-1') THEN
      raise PMVH_lock_err;
     END IF;

     FII_UTIL.truncate_table ('FII_UDD1_PMV_AGRT_NODES','FII', g_retcode);
     IF(g_retcode = '-1') THEN
      raise PMVH_lock_err;
     END IF;

    IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Succ ('FII_PMV_HELPER_TABLES_C.truncate_helper_tables');
    END If;

    EXCEPTION
     WHEN PMVH_lock_err THEN
     FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
     FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
     FII_MESSAGE.Func_Fail(func_name => 'FII_PMV_HELPER_TABLES_C.'||
                               'truncate_helper_tables');
     raise;

    WHEN OTHERS THEN
     FII_UTIL.Write_Log ( 'G_PHASE: ' || G_PHASE);
     FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
     FII_MESSAGE.Func_Fail(func_name => 'FII_PMV_HELPER_TABLES_C.'||
                               'truncate_helper_tables');
     raise;

   END;

-- *************************************************************************************
-- This is the Dim_number_nodes procedure. This is to call the populate_pmv_helper_gt
-- procedure with the number of nodes in the dimension
-- *************************************************************************************

   Procedure Dim_number_nodes IS
   BEGIN

    IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Ent ('FII_PMV_HELPER_TABLES_C.Dim_number_nodes');
    END IF;

    -- First truncate all the helper tables.
    g_phase := 'Truncate all the helper tables';
    truncate_helper_tables;

    -- G_NODES is equal to the number of nodes calculated in
    -- initialize.

    -- For the smallest dimension
    g_phase := 'Processing for the smallest Dimension';
    G_OPTIMUM_NODES := G_NODES;

     IF (FIIDIM_Debug) THEN
	    FII_UTIL.Write_Log('No. of Nodes which can be aggregated in  ' || Dimension_name(p_tab(1).dim_short_name) || ' is : ' || G_OPTIMUM_NODES );
     END IF;

    If(p_tab(1).number_of_nodes< G_OPTIMUM_NODES) THEN
      g_keep_gain_flag := 'N';
      Populate_PMV_Helper_GT (p_tab(1).dim_short_name, p_tab(1).number_of_nodes,p_tab(1).gain);
      p_tab(1).gain := G_OPTIMUM_NODES / p_tab(1).number_of_nodes;
    ELSE
      g_keep_gain_flag := 'Y';
      Populate_PMV_Helper_GT (p_tab(1).dim_short_name,
                          p_tab(1).number_of_nodes,
                          p_tab(1).gain);
    End if;

     IF (FIIDIM_Debug) THEN
	    FII_UTIL.Write_Log('No. of Nodes which can be aggregated in  ' || Dimension_name(p_tab(2).dim_short_name) || ' is : ' || G_OPTIMUM_NODES );
     END IF;
     g_phase := 'Processing for the second smallest Dimension';
    -- For the second smallest dimension
    If(p_tab(2).number_of_nodes < G_OPTIMUM_NODES) THEN
      g_keep_gain_flag := 'N';
      Populate_PMV_Helper_GT (p_tab(2).dim_short_name,
                          p_tab(2).number_of_nodes,
                          p_tab(2).gain);

      p_tab(2).gain := G_OPTIMUM_NODES / p_tab(2).number_of_nodes;
    ELSE
      g_keep_gain_flag := 'Y';
      Populate_PMV_Helper_GT (p_tab(2).dim_short_name,
                          p_tab(2).number_of_nodes,
                          p_tab(2).gain);
    End if;

    -- For the second largest dimension
    g_phase := 'Processing for the second Largest Dimension';

    G_OPTIMUM_NODES := ROUND(G_NODES * p_tab(2).gain);

     IF (FIIDIM_Debug) THEN
	    FII_UTIL.Write_Log('No. of Nodes which can be aggregated in  ' || Dimension_name(p_tab(3).dim_short_name) || ' is : ' || G_OPTIMUM_NODES );
     END IF;

    If(p_tab(3).number_of_nodes < G_OPTIMUM_NODES) THEN
       g_keep_gain_flag := 'N';
       Populate_PMV_Helper_GT (p_tab(3).dim_short_name,
                          p_tab(3).number_of_nodes,
                          p_tab(3).gain);

       p_tab(3).gain := G_OPTIMUM_NODES / p_tab(3).number_of_nodes;
    ELSE
       g_keep_gain_flag := 'Y';
       Populate_PMV_Helper_GT (p_tab(3).dim_short_name,
                          p_tab(3).number_of_nodes,
                          p_tab(3).gain);
    End if;


    -- For the largest dimension
    g_phase := 'Processing for the largest Dimension';
    G_OPTIMUM_NODES := ROUND(G_NODES * p_tab(3).gain *p_tab(1).gain);

     IF (FIIDIM_Debug) THEN
	    FII_UTIL.Write_Log('No. of Nodes which can be aggregated in  ' || Dimension_name(p_tab(4).dim_short_name) || ' is : ' || G_OPTIMUM_NODES );
     END IF;

    If(p_tab(4).number_of_nodes < G_OPTIMUM_NODES) THEN
       g_keep_gain_flag := 'N';
       Populate_PMV_Helper_GT (p_tab(4).dim_short_name,
                          p_tab(4).number_of_nodes,
                          p_tab(4).gain);


    ELSE
       g_keep_gain_flag := 'Y';
       Populate_PMV_Helper_GT (p_tab(4).dim_short_name,
                          p_tab(4).number_of_nodes,
                          p_tab(4).gain);
    End if;

     IF (FIIDIM_Debug) THEN
       FII_MESSAGE.Func_Succ ('FII_PMV_HELPER_TABLES_C.Dim_number_nodes');
     END IF;

     EXCEPTION
     WHEN OTHERS THEN
      raise;

   END Dim_number_nodes;

-- *************************************************************************************
-- This is the main procedure of PMV Helper Table population program (initial populate).
-- *************************************************************************************

   PROCEDURE Load_Main (errbuf	OUT NOCOPY VARCHAR2,
	 	      retcode	OUT NOCOPY VARCHAR2,
		      p_load_mode  IN VARCHAR2) IS

    ret_val             BOOLEAN := FALSE;

  BEGIN

     IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Ent(func_name => 'FII_PMV_HELPER_TABLES_C.Load_Main');
     END IF;

      g_phase := 'Set the Load mode';
      G_PROGRAM_MODE := p_load_mode;

    --First do the initialization
      g_phase := 'Calling Initialize';
      Initialize;

    --Secondly populate the table FII_AGGRT_NODE_GT
      g_phase := 'Populate FII_AGGRT_NODE_GT table'  ;
      populate_temp;

    --Calling Calculate_Sort_Nodes
      g_phase := 'Calling Calculate_sort_nodes';
      calculate_sort_nodes;

      Dim_number_nodes;

      -- Gather table statistics
      -- This will be by seeding in RSG
      -- Need to remove this when RSG SEED data is done.
       FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
          tabname	=> 'FII_FC_PMV_AGRT_NODES');

      g_phase := 'gather_table_stats for FII_COM_PMV_AGRT_NODES';

       FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
          tabname	=> 'FII_COM_PMV_AGRT_NODES');

      g_phase := 'gather_table_stats for FII_CC_PMV_AGRT_NODES';

       FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
         tabname	=> 'FII_CC_PMV_AGRT_NODES');

      g_phase := 'gather_table_stats for FII_UDD1_PMV_AGRT_NODES';

       FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
          tabname	=> 'FII_UDD1_PMV_AGRT_NODES');

    --==============================================================--

     FND_CONCURRENT.Af_Commit;

    IF (FIIDIM_Debug) THEN
     FII_MESSAGE.Func_Succ(func_name => 'FII_PMV_HELPER_TABLES_C.Load_Main');
    END IF;

    -- Exception handling

  EXCEPTION

    WHEN PMVH_fatal_err THEN

      FII_UTIL.Write_Log ('FII_PMV_HELPER_TABLES_C.Load_Main: '||
                        'User defined error');

      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_PMV_HELPER_TABLES_C.Load_Main');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN OTHERS THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log (
          'Other error in FII_PMV_HELPER_TABLES_C.Load_Main: ' || substr(sqlerrm,1,180));

      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_PMV_HELPER_TABLES_C.Load_Main');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

   END Load_Main;

END FII_PMV_HELPER_TABLES_C;

/
