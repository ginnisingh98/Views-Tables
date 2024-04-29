--------------------------------------------------------
--  DDL for Package Body FII_COM_CC_DIM_MAPS_PKG
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_COM_CC_DIM_MAPS_PKG" AS
/* $Header: FIICCMPB.pls 120.1 2005/10/30 05:05:42 appldev noship $ */

        G_UNASSIGNED_ID        NUMBER(15);
	G_CO_MAP_SEG	       VARCHAR2(30);
	G_CC_MAP_SEG	       VARCHAR2(30);
        g_phase                VARCHAR2(120);
        g_schema_name          VARCHAR2(120)   := 'FII';
        g_retcode              VARCHAR2(20)    := NULL;
        g_debug_mode           VARCHAR2(1)
                     := NVL(FND_PROFILE.value('FII_DEBUG_MODE'), 'N');

-- *******************************************************************
-- Initialize (Get the unassigned ID and the segments to which
-- Company and Cost Center Dimension is attached)

   PROCEDURE Initialize  IS

         l_dir        VARCHAR2(160);
	 l_vset_id	NUMBER(15);
	 l_ret_code	NUMBER;

   BEGIN

     ------------------------------
     -- Do the set up for log file
     ------------------------------
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
     FII_UTIL.initialize('FII_COM_CC_DIM_MAPS_PKG.log',
                         'FII_COM_CC_DIM_MAPS_PKG.out',l_dir,'FII_COM_CC_DIM_MAPS_PKG');


     -- Obtain FII schema name
     g_schema_name := FII_UTIL.get_schema_name ('FII');

     -- Obtain user ID, login ID and initialize package variables
     FII_USER_ID 	:= FND_GLOBAL.USER_ID;
     FII_LOGIN_ID	:= FND_GLOBAL.LOGIN_ID;

     -- If any of the above values is not set, error out
     IF (FII_User_Id is NULL OR FII_Login_Id is NULL) THEN
       FII_UTIL.Write_Log ('>>> Failed Intialization');
       RAISE COMCCDIM_fatal_err;
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
       FII_UTIL.Write_Log ('Initialize: Now start processing '|| 'Company Cost Center Mapping');
     End If;

     -- --------------------------------------------------------
     -- Find the unassigned ID for company and cost center
     -- --------------------------------------------------------
          g_phase := 'Find the shipped FII value set id and the unassigned value id';
          -- This is to be replaced by a call to the api in FII_GL_EXTRACTION_UTIL package
          FII_GL_EXTRACTION_UTIL.get_unassigned_id(G_UNASSIGNED_ID, l_vset_id, l_ret_code);
          IF(l_ret_code = -1) THEN
           RAISE COMCCDIM_fatal_err;
          END IF;
     -- ---------------------------------------------------------------------------
     -- Get the segment to which the dimension is mapped for company and cost center
     -- ----------------------------------------------------------------------------

             g_phase := 'Find the segments to which Company and Cost Center are mapped' ;

             BEGIN
		SELECT BALANCING_OR_COST_CENTER
		INTO G_CO_MAP_SEG
		FROM FII_FINANCIAL_DIMENSIONS
		WHERE DIMENSION_SHORT_NAME = 'FII_COMPANIES';

		EXCEPTION
                  WHEN NO_DATA_FOUND THEN
		  FII_UTIL.Write_Log ('Set up for Company not done');
                  G_CO_MAP_SEG  := NULL;
              END;

             BEGIN
		SELECT BALANCING_OR_COST_CENTER
		INTO G_CC_MAP_SEG
		FROM FII_FINANCIAL_DIMENSIONS
		WHERE DIMENSION_SHORT_NAME = 'HRI_CL_ORGCC';

		EXCEPTION
                  WHEN NO_DATA_FOUND THEN
		  FII_UTIL.Write_Log ('Set up for Cost Center not done');
                  G_CC_MAP_SEG  := NULL;
              END;

     IF (FIIDIM_Debug) THEN
       FII_UTIL.Write_Log ('COST CENTER is Mapped to segment : '|| G_CC_MAP_SEG );
       FII_UTIL.Write_Log ('COMPANY is Mapped to segment : '|| G_CO_MAP_SEG);
     END IF;



   Exception

     When COMCCDIM_fatal_err then
       FII_UTIL.Write_Log ('FII_COM_CC_DIM_MAPS_PKG.Initialize : '|| 'User defined error');
        FII_UTIL.Write_Log ('G_PHASE : ' || g_phase);
       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name => 'FII_COM_CC_DIM_MAPS_PKG.Initialize');
       raise;

     When others then
        FII_UTIL.Write_Log ('Unexpected error when calling Initialize...');
        FII_UTIL.Write_Log ( 'G_PHASE: ' || g_phase);
	FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
        RAISE;

   END Initialize;

   -- *******************************************************************
   -- Populate_com_cc_Maps (Populate the Global temporary table )
   -- Insert G_UNASSIGNED_ID as the parent if the company/ cost center
   -- id is not present in the dimension

   PROCEDURE Populate_com_cc_Maps IS
	BEGIN
		IF (FIIDIM_Debug) THEN
 		 FII_MESSAGE.Func_Ent(func_name => 'FII_COM_CC_DIM_MAPS_PKG.Populate_com_cc_Maps');
                END IF;

		-- Insert records in the com cc mappings GI table
		g_phase := 'Insert into FII_COM_CC_DIM_MAP_GT';

		------------------------------------------------------------------------------
		-- There is a possibility of having Company_id and cost_center_id
		-- in FII_GL_CCID_DIMENSIONS which might not be present in the
		-- corresponding Dimension hierarchy (it might now be mapped)
		-- To populate those id's also in FII_COM_CC_DIM_MAPS_GT
		-- outer join is used.
		-- Also since both Company and Cost Center Dimension can be mapped
		-- to either Balancing / Cost Center Segment so we need to identify
		-- that the dimension is mapped to which segment. If the Dimension
		-- mapped to Balancing Segment then the Company_id from FII_GL_CCID_DIMENSIONS
		-- or FII_BUDGET_BASE should be mapped to the dimension table
		-- and if the dimension is mapped to Cost Center Segment then
		-- Cost_Center_id From FII_GL_CCID_DIMENSIONS and FII_BUDGET_BASE
		-- should be mapped to the dimension table. Decode is used for this purpose
		--------------------------------------------------------------------------------

		INSERT INTO FII_COM_CC_DIM_MAPS_GT (PARENT_COMPANY_DIM_ID,
                                   CHILD_COMPANY_ID,
                                   PARENT_COST_CENTER_DIM_ID,
                                   CHILD_COST_CENTER_ID)
	         SELECT
	                h1.parent_company_id,
                        g.company_id,
                        h2.parent_cc_id,
                        g.cost_center_id
                 FROM
	             (select distinct COMPANY_ID, COST_CENTER_ID
                      from FII_GL_CCID_DIMENSIONS
                      UNION
                      select distinct COMPANY_ID, COST_CENTER_ID
                      from FII_BUDGET_BASE
		      )g,

                      (SELECT fh.parent_COMPANY_id, fh.child_COMPANY_id
                       FROM FII_FULL_COMPANY_HIERS fh
                       WHERE fh.parent_company_id IN
                          (SELECT ph.parent_COMPANY_id
                           FROM FII_COMPANY_HIERARCHIES ph
                           WHERE ph.is_leaf_flag = 'Y')) h1,
                     (SELECT fh.parent_cc_id, fh.child_cc_id
                      FROM FII_FULL_COST_CTR_HIERS fh
                      WHERE fh.parent_cc_id IN
                        (SELECT ph.parent_cc_id
                         FROM FII_COST_CTR_HIERARCHIES ph
                         WHERE ph.is_leaf_flag = 'Y')) h2
                WHERE DECODE(G_CO_MAP_SEG,
                             'BALANCING', g.COMPANY_ID,
                             'COST CENTER', g.cost_center_id, G_UNASSIGNED_ID) =
                                    h1.child_company_id
                AND DECODE(G_CC_MAP_SEG,
                           'BALANCING', g.COMPANY_ID,
                           'COST CENTER', g.cost_center_id, G_UNASSIGNED_ID) =
                                         h2.child_cc_id ;
		-- Removed outer join as we dont want unassigned as a parent
	     IF (FIIDIM_Debug) THEN
		FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows from FII_COM_CC_DIM_MAP_GT');
		FII_MESSAGE.Func_Succ(func_name => 'FII_COM_CC_DIM_MAPS_PKG.Populate_com_cc_Maps');
	     END IF;

        Exception

        When others then
         FII_UTIL.Write_Log ('Unexpected error when calling Populate_com_cc_Maps...');
         FII_UTIL.Write_Log ( 'G_PHASE: ' || g_phase);
	 FII_UTIL.Write_Log ('Error Message: '|| substr(sqlerrm,1,180));
         RAISE;

   END Populate_com_cc_Maps;


-- **************************************************************************
-- This is the main procedure of COMPANY COST CENTER Mapping Table population
-- program (initial populate).

   PROCEDURE Init_Load (errbuf		OUT NOCOPY VARCHAR2,
	 	        retcode		OUT NOCOPY VARCHAR2) IS
    ret_val             BOOLEAN := FALSE;

  BEGIN

     IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Ent(func_name => 'FII_COM_CC_DIM_MAPS_PKG.Init_Load');
     END IF;

     --First do the initialization
     g_phase := 'Calling intialize procedure';

      Initialize;

     -- Populate the com cc dim maps GT.
     g_phase := 'Populate FII_COM_CC_DIM_MAPS_GT';

     Populate_com_cc_Maps;
     -- Populate by selecting from the mappings table

     -- Now all the mappings are populated in the GT table.
     -- Copy data from GT table to Mappings table
     g_phase := 'Copy from FII_COM_CC_DIM_MAP_GT to FII_COM_CC_DIM_MAPS';

     FII_UTIL.truncate_table ('FII_COM_CC_DIM_MAPS', 'FII', g_retcode);

      Insert into /*+ APPEND */ FII_COM_CC_DIM_MAPS (
         PARENT_COMPANY_DIM_ID,
         CHILD_COMPANY_ID,
         PARENT_COST_CENTER_DIM_ID,
         CHILD_COST_CENTER_ID,
         creation_date,
         created_by,
         last_update_date,
         last_updated_by,
         last_update_login)
       SELECT
            PARENT_COMPANY_DIM_ID,
            CHILD_COMPANY_ID,
            PARENT_COST_CENTER_DIM_ID,
            CHILD_COST_CENTER_ID,
	    SYSDATE,
            FII_USER_ID,
	    SYSDATE,
	    FII_USER_ID,
	    FII_LOGIN_ID
        FROM FII_COM_CC_DIM_MAPS_GT;

	IF (FIIDIM_Debug) THEN
		FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows from FII_COM_CC_DIM_MAPS');
	END IF;


     FND_CONCURRENT.Af_Commit;

     --Call FND_STATS to collect statistics after populating the tables.
     -- This will be in RSG data.
      g_phase := 'gather_table_stats for FII_COM_CC_DIM_MAPS';

       FND_STATS.gather_table_stats
            (ownname	=> g_schema_name,
             tabname	=> 'FII_COM_CC_DIM_MAPS');

      g_phase := 'gather_table_stats for MLOG$_FII_COM_CC_DIM_MAPS';

       FND_STATS.gather_table_stats
         (ownname	=> g_schema_name,
         tabname	=> 'MLOG$_FII_COM_CC_DIM_MAPS');

     --=====================================================================

     IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Succ(func_name => 'FII_COM_CC_DIM_MAPS_PKG.Init_Load');
     END IF;

    -- Exception handling

  EXCEPTION

    WHEN COMCCDIM_fatal_err THEN

      FII_UTIL.Write_Log ('FII_COM_CC_DIM_MAPS_PKG.Init_Load: '||
                        'User defined error');
      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_COM_CC_DIM_MAPS_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

    WHEN OTHERS THEN
      FII_UTIL.Write_Log ('Init_Load -> phase: '|| g_phase);
      FII_UTIL.Write_Log (
          'Other error in FII_CC_MAINTAIN_PKG.Init_Load: ' || substr(sqlerrm,1,180));
      FND_CONCURRENT.Af_Rollback;
      FII_MESSAGE.Func_Fail(func_name	=> 'FII_COM_CC_DIM_MAPS_PKG.Init_Load');
      retcode := sqlcode;
      ret_val := FND_CONCURRENT.Set_Completion_Status
		(status	 => 'ERROR', message => substr(sqlerrm,1,180));

   END Init_Load;


-- **************************************************************************
-- This is the main procedure of COMPANY COST CENTER Mapping Table population
-- program (incremental update).

   PROCEDURE Incre_Update (errbuf		OUT NOCOPY VARCHAR2,
	 	           retcode		OUT NOCOPY VARCHAR2) IS

      ret_val             BOOLEAN := FALSE;
      ret_code		 VARCHAR2(2):=0;
   BEGIN

     IF (FIIDIM_Debug) THEN
      FII_MESSAGE.Func_Ent(func_name => 'FII_COM_CC_DIM_MAPS_PKG.Incre_Update');
     END IF;

     --First do the initialization
     g_phase := 'Calling intialize procedure';

      Initialize;

     -- Populate the com cc dim maps GT table.
     g_phase := 'Populate FII_COM_CC_DIM_MAPS_GT';

     Populate_com_cc_Maps;

     -- -----------------------------------------------------
     -- Incremental maintainence of FII_COM_CC_DIM_MAPS
     -- This is done in 2 statements
     -- One Delete statement and one Insert statement
     -- Do a diff with the mappings table with the GT table
     -- ------------------------------------------------------

	-- Do a diff with the mappings table
	   DELETE FROM FII_COM_CC_DIM_MAPS
	   WHERE
		(PARENT_COMPANY_DIM_ID,
	         CHILD_COMPANY_ID,
	         PARENT_COST_CENTER_DIM_ID,
	         CHILD_COST_CENTER_ID)IN
	   (SELECT PARENT_COMPANY_DIM_ID,
                   CHILD_COMPANY_ID,
                   PARENT_COST_CENTER_DIM_ID,
                   CHILD_COST_CENTER_ID
  	   FROM FII_COM_CC_DIM_MAPS
	   MINUS
	   SELECT PARENT_COMPANY_DIM_ID,
                  CHILD_COMPANY_ID,
                  PARENT_COST_CENTER_DIM_ID,
                  CHILD_COST_CENTER_ID
	   FROM FII_COM_CC_DIM_MAPS_GT);


        IF (FIIDIM_Debug) THEN
		FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows from FII_COM_CC_DIM_MAPS');
	END IF;


	Insert into FII_COM_CC_DIM_MAPS (
	         PARENT_COMPANY_DIM_ID,
		 CHILD_COMPANY_ID,
		 PARENT_COST_CENTER_DIM_ID,
		 CHILD_COST_CENTER_ID,
		 creation_date,
		 created_by,
		 last_update_date,
		 last_updated_by,
		 last_update_login)
       (SELECT
            PARENT_COMPANY_DIM_ID,
            CHILD_COMPANY_ID,
            PARENT_COST_CENTER_DIM_ID,
            CHILD_COST_CENTER_ID,
	    SYSDATE,
      	    FII_USER_ID,
	    SYSDATE,
	    FII_USER_ID,
	    FII_LOGIN_ID
        FROM FII_COM_CC_DIM_MAPS_GT
        MINUS
        SELECT
            PARENT_COMPANY_DIM_ID,
            CHILD_COMPANY_ID,
            PARENT_COST_CENTER_DIM_ID,
            CHILD_COST_CENTER_ID,
	    SYSDATE,
	    FII_USER_ID,
	    SYSDATE,
	    FII_USER_ID,
	    FII_LOGIN_ID
       FROM FII_COM_CC_DIM_MAPS);

       IF (FIIDIM_Debug) THEN
		FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_COM_CC_DIM_MAPS');
	END IF;

       FND_CONCURRENT.Af_Commit;

     -- Call FND_STATS to collect statistics after populating the tables.
     -- This will be in RSG data.
      g_phase := 'gather_table_stats for FII_COM_CC_DIM_MAPS';

       FND_STATS.gather_table_stats
            (ownname	=> g_schema_name,
             tabname	=> 'FII_COM_CC_DIM_MAPS');

        -- Bug 4200473. Not to analyze MLOG in incremental run.
	-- As per performance teams suggestions.
       --g_phase := 'gather_table_stats for MLOG$_FII_COM_CC_DIM_MAPS';

       --FND_STATS.gather_table_stats
         --(ownname	=> g_schema_name,
         --tabname	=> 'MLOG$_FII_COM_CC_DIM_MAPS');

       IF (FIIDIM_Debug) THEN
        FII_MESSAGE.Func_Succ(func_name => 'FII_COM_CC_DIM_MAPS_PKG.Incre_Update');
       END IF;

   -- Exception handling

   EXCEPTION
     WHEN COMCCDIM_fatal_err THEN
       FII_UTIL.Write_Log ('FII_COM_CC_DIM_MAPS_PKG.Incre_Update'||
                         'User defined error');

       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name	=> 'FII_COM_CC_DIM_MAPS_PKG.Incre_Update');
       retcode := sqlcode;
       ret_val := FND_CONCURRENT.Set_Completion_Status
	        	(status	 => 'ERROR', message => substr(sqlerrm,1,180));

     WHEN OTHERS THEN
       FII_UTIL.Write_Log ('Incre_Update -> phase: '|| g_phase);
       FII_UTIL.Write_Log (
          'Other error in FII_COM_CC_DIM_MAPS_PKG.Incre_Update: ' || substr(sqlerrm,1,180));


       FND_CONCURRENT.Af_Rollback;
       FII_MESSAGE.Func_Fail(func_name	=> 'FII_COM_CC_DIM_MAPS_PKG.Incre_Update');
       retcode := sqlcode;
       ret_val := FND_CONCURRENT.Set_Completion_Status
	        	(status	 => 'ERROR', message => substr(sqlerrm,1,180));

   END Incre_Update;

END FII_COM_CC_DIM_MAPS_PKG ;

/
