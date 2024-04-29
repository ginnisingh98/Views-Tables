--------------------------------------------------------
--  DDL for Package Body FII_CC_MGR_SUP_C
--------------------------------------------------------

  CREATE OR REPLACE EDITIONABLE PACKAGE BODY "APPS"."FII_CC_MGR_SUP_C" AS
/*$Header: FIICMSCB.pls 115.12 2004/05/21 21:05:56 juding noship $*/

 g_phase                  VARCHAR2 (240);
 g_fii_schema             VARCHAR2 (120);
 g_fii_user_id	          NUMBER(15);
 g_fii_login_id           NUMBER(15);
 G_LOGIN_INFO_NOT_AVABLE  EXCEPTION;

 G_AGGREGATION_LEVELS     NUMBER(15) :=
          NVL(fnd_profile.value('FII_MGR_LEVEL'), 999);

 g_debug_flag             VARCHAR2(1) :=
          nvl(fnd_profile.value('FII_DEBUG_MODE'), 'N');

 -----------------------------------------------------------------------
 -- PROCEDURE TRUNCATE_TABLE
 -----------------------------------------------------------------------
 PROCEDURE TRUNCATE_TABLE (p_table_name in varchar2) is
    l_stmt varchar2(240);

 Begin

    l_stmt:='truncate table '||g_fii_schema||'.'|| p_table_name;

    if g_debug_flag = 'Y' then
		FII_UTIL.put_line('');
		FII_UTIL.put_line(l_stmt);
    end if;

    execute immediate l_stmt;

 Exception
   WHEN OTHERS THEN
     FII_UTIL.put_line('
       Error in Procedure: TRUNCATE_TABLE
       Message: '||sqlerrm);
     RAISE;
 End truncate_Table;


 -----------------------------------------------------------------------
 -- PROCEDURE INIT
 -----------------------------------------------------------------------
 PROCEDURE INIT is
     l_status		VARCHAR2(30);
     l_industry		VARCHAR2(30);
     l_dir              VARCHAR2(160);

 BEGIN

     if g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_CC_MGR_SUP_C.FII_CC_MGR_SUP_C.INIT');
     end if;

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
       l_dir := FII_UTIL.get_utl_file_dir ;
     end if;

     ----------------------------------------------------------------
     -- FII_UTIL.initialize will get profile options FII_DEBUG_MODE
     -- and BIS_DEBUG_LOG_DIRECTORY and set up the directory where
     -- the log files and output files are written to
     ----------------------------------------------------------------
     FII_UTIL.initialize ('FII_CC_MGR_SUP_C.log',
                          'FII_CC_MGR_SUP_C.out',l_dir, 'FII_GL_COMCCH_C');

     ----------------------------------------------------------
     -- Find the schema owner of FII
     ----------------------------------------------------------
     g_fii_schema := FII_UTIL.get_schema_name ('FII');

     g_fii_user_id  := FND_GLOBAL.User_Id;
     g_fii_login_id := FND_GLOBAL.Login_Id;
     IF (g_fii_user_id IS NULL OR g_fii_login_id IS NULL) THEN
                RAISE G_LOGIN_INFO_NOT_AVABLE;
     END IF;

     if g_debug_flag = 'Y' then
		 FII_UTIL.put_line('User ID: ' || g_fii_user_id ||
                        ' Login ID: ' || g_fii_login_id);
     end if;

     if g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_CC_MGR_SUP_C.FII_CC_MGR_SUP_C.INIT');
     end if;

 EXCEPTION
   WHEN G_LOGIN_INFO_NOT_AVABLE THEN
     FII_UTIL.put_line('Can not get User ID and Login ID, program exit');
     FII_MESSAGE.Func_Fail('FII_CC_MGR_SUP_C.FII_CC_MGR_SUP_C.INIT');
     raise;

   WHEN OTHERS THEN
     FII_UTIL.put_line('
           Error in Procedure: INIT
           Phase: '||g_phase||'
           Message: '||sqlerrm);
     FII_MESSAGE.Func_Fail('FII_CC_MGR_SUP_C.FII_CC_MGR_SUP_C.INIT');
  	   raise;
 END Init;

--**********************************************************************
-- Populate the TMP table: FII_CC_MGR_HIER_GT

 PROCEDURE Populate_HIER_TMP IS

  l_status   VARCHAR2(1);

 BEGIN

     if g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_CC_MGR_SUP_C.Populate_HIER_TMP');
     end if;

    g_phase := 'Initialize setups';
    ------------------------------------------------
    -- Initialize setups
    ------------------------------------------------
     INIT;

    g_phase := 'Populate table FII_CCC_MGR_GT to replace HRI_CS_PER_ORGCC_CT';

     FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR (l_status);

    IF l_status = -1 then
      FII_UTIL.put_line('Error in FII_GL_EXTRACTION_UTIL.LOAD_CCC_MGR ...');
      FII_UTIL.put_line('Table FII_CCC_MGR_GT is not populated');
      raise NO_DATA_FOUND;
    END IF;

    --First, join the fii_ccc_mgr_gt table with hri_cs_suph to
    --get a distinct list of managers who have cost center responsibility
    --(i.e. own a cost center or have a subordinate who does).
    --Insert these records into global temporary table FII_PERSON_ID_TMP

     g_phase := 'Insert into table FII_PERSON_ID_TMP';

      INSERT into FII_PERSON_ID_TMP (person_id)
        select /*+ leading(ct) full(ct) index(suph HRI_CS_SUPH_N4) use_nl(ct suph) */
               distinct  suph.sup_person_id
        from fii_ccc_mgr_gt              ct,
             hri_cs_suph                 suph,
             per_assignment_status_types ast
        where ct.manager = suph.sub_person_id
        and sysdate between suph.effective_start_date
                        and suph.effective_end_date
        and suph.sup_assignment_status_type_id = ast.assignment_status_type_id
        and ast.per_system_status IN ('ACTIVE_ASSIGN', 'SUSP_ASSIGN');

     if g_debug_flag = 'Y' then
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_PERSON_ID_TMP');
     end if;

    ----------------------------------------------------------
    --Begin to populate the table FII_CC_MGR_HIER_GT
    ----------------------------------------------------------
    FII_UTIL.start_timer;
     g_phase := 'Truncate table FII_CC_MGR_HIER_GT';

     TRUNCATE_TABLE ('FII_CC_MGR_HIER_GT');

     g_phase := 'Insert into table FII_CC_MGR_HIER_GT';

    --We populate aggregation_flag to 'N' if child_level is greater
    --than the profile option for aggregation level

        INSERT INTO FII_CC_MGR_HIER_GT
            (MGR_ID,
             MGR_LEVEL,
             DIRECT_ID,
             DIRECT_LEVEL,
             EMP_ID,
             EMP_LEVEL,
             NEXT_LEVEL_IS_LEAF,
             IS_LEAF_FLAG,
             AGGREGATION_FLAG)
         select
             sup.sup_person_id                       mgr_id,
             sup.sup_level                           mgr_level,
             sup.SUB_PERSON_ID                       direct_id,
             sup.sub_level                           drect_level,
             sub.sub_person_id                       emp_id,
             sub.sub_level                           emp_level,
             'N'                                     next_level_is_leaf,
             'N'                                     is_leaf_flag,
           decode(SIGN(sub.sub_level-G_AGGREGATION_LEVELS),1,'N','Y') aggregation_flag
         from hri_cs_suph      sup,
              hri_cs_suph      sub
         where sup.sub_relative_level <= 1
         and  (sup.sub_relative_level = 1 OR sup.sup_level = 1)
         and   sup.sup_invalid_flag_code = 'N'
         and   sup.sub_invalid_flag_code = 'N'
         and   sup.sub_primary_asg_flag_code = 'Y'
         and   sysdate between sup.effective_start_date and sup.effective_end_date
         and   sup.sub_person_id = sub.sup_person_id
         and   sub.sup_invalid_flag_code = 'N'
         and   sub.sub_invalid_flag_code = 'N'
         and   sub.sub_primary_asg_flag_code = 'Y'
         and   sysdate between sub.effective_start_date and sub.effective_end_date
         and   sub.sub_person_id in (select person_id from FII_PERSON_ID_TMP);

     ---------------------------------------------------------------

     if g_debug_flag = 'Y' then
		 FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT ||
                         ' rows of data into FII_CC_MGR_HIER_GT table');
     end if;

     --Set mgr_id to -999 and mgr_level to 0 for records of
     --    mgr_level = 1 and direct_level = 1
     g_phase := 'Update MGR_ID and MGR_LEVEL for records of top person';

       Update FII_CC_MGR_HIER_GT
         Set  mgr_id = -999,
              mgr_level = 0
       Where mgr_level = 1
         and direct_level = 1;

     if g_debug_flag = 'Y' then
	FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_CC_MGR_HIER_GT');
     end if;

     --Insert all self records (using mgr_id = -999)
     g_phase := 'Insert all self records';

       Insert into FII_CC_MGR_HIER_GT
            (MGR_ID,
             MGR_LEVEL,
             DIRECT_ID,
             DIRECT_LEVEL,
             EMP_ID,
             EMP_LEVEL,
             NEXT_LEVEL_IS_LEAF,
             IS_LEAF_FLAG,
             AGGREGATION_FLAG)
         select
             EMP_ID,
             EMP_LEVEL,
             EMP_ID,
             EMP_LEVEL,
             EMP_ID,
             EMP_LEVEL,
             'N',
             'N',
             AGGREGATION_FLAG
         from   FII_CC_MGR_HIER_GT
         where  mgr_id = -999;

     if g_debug_flag = 'Y' then
	FII_UTIL.Write_Log('Inserted ' || SQL%ROWCOUNT || ' rows into FII_CC_MGR_HIER_GT');
     end if;

     --Update the column next_level_is_leaf
     g_phase := 'Update column next_level_is_leaf...';

       Update FII_CC_MGR_HIER_GT tab1
          Set tab1.next_level_is_leaf = 'Y'
        Where tab1.direct_id = tab1.emp_id
          AND tab1.aggregation_flag = 'Y'
          AND 1 = (select count(*)
                     from FII_CC_MGR_HIER_GT tab2
                    where tab2.mgr_id = tab1.direct_id
                      and tab2.aggregation_flag = 'Y');

     if g_debug_flag = 'Y' then
	FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_CC_MGR_HIER_GT');
     end if;

     --Update the column is_leaf_flag
     g_phase := 'Update column is_leaf_flag...';

       Update FII_CC_MGR_HIER_GT
         Set  is_leaf_flag = 'Y'
       Where mgr_id = direct_id
         and direct_id = emp_id
         and next_level_is_leaf = 'Y';

     if g_debug_flag = 'Y' then
	FII_UTIL.Write_Log('Updated ' || SQL%ROWCOUNT || ' rows in FII_CC_MGR_HIER_GT');
     end if;

     FII_UTIL.stop_timer;

     if g_debug_flag = 'Y' then
     	FII_UTIL.print_timer('Duration');
     end if;

     if g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_CC_MGR_SUP_C.Populate_HIER_TMP');
     end if;

 Exception

   WHEN OTHERS Then
     FII_UTIL.put_line('Error in phase ' || g_phase ||
                         ' of running FII_CC_MGR_SUP_C.Populate_HIER_TMP; '
                         || 'Message: ' || sqlerrm);
     ROLLBACK;
     FII_MESSAGE.Func_Fail('FII_CC_MGR_SUP_C.Populate_HIER_TMP');
     raise;

 END Populate_HIER_TMP;

--**********************************************************************
-- Incremental Update

 PROCEDURE Incre_Update (errbuf          IN OUT NOCOPY VARCHAR2,
                         retcode         IN OUT NOCOPY VARCHAR2) IS

 BEGIN

     if g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_CC_MGR_SUP_C.Incre_Update');
     end if;

    ----------------------------------------------------------
    --call to populate the table FII_CC_MGR_HIER_GT
    ----------------------------------------------------------
    g_phase := 'call to populate the table FII_CC_MGR_HIER_GT';

      Populate_HIER_TMP;

    ----------------------------------------------------------
    --Begin to update the table FII_CC_MGR_HIERARCHIES
    --by diff FII_CC_MGR_HIER_GT and FII_CC_MGR_HIERARCHIES
    --for incremental update
    ----------------------------------------------------------

    FII_UTIL.start_timer;

    g_phase := 'DELETE FROM FII_CC_MGR_HIERARCHIES';

      DELETE FROM FII_CC_MGR_HIERARCHIES
      WHERE (mgr_id, mgr_level, direct_id, direct_level,
             emp_id, emp_level, next_level_is_leaf, is_leaf_flag) IN
     (SELECT mgr_id, mgr_level, direct_id, direct_level,
             emp_id, emp_level, next_level_is_leaf, is_leaf_flag
	FROM FII_CC_MGR_HIERARCHIES
      MINUS
      SELECT mgr_id, mgr_level, direct_id, direct_level,
             emp_id, emp_level, next_level_is_leaf, is_leaf_flag
        FROM FII_CC_MGR_HIER_GT
       WHERE aggregation_flag = 'Y');

     if g_debug_flag = 'Y' then
	FII_UTIL.Write_Log('Deleted ' || SQL%ROWCOUNT || ' rows from FII_CC_MGR_HIERARCHIES');
     end if;

    g_phase := 'INSERT INTO FII_CC_MGR_HIERARCHIES';

      INSERT INTO FII_CC_MGR_HIERARCHIES
       (mgr_id,
        mgr_level,
        direct_id,
        direct_level,
        emp_id,
        emp_level,
        next_level_is_leaf,
        is_leaf_flag,
        creation_date,
        created_by,
        last_update_date,
        last_updated_by,
        last_update_login)
      (SELECT mgr_id,
              mgr_level,
              direct_id,
              direct_level,
              emp_id,
              emp_level,
              next_level_is_leaf,
              is_leaf_flag,
	      SYSDATE,
	      G_FII_USER_ID,
	      SYSDATE,
	      G_FII_USER_ID,
	      G_FII_LOGIN_ID
       FROM  FII_CC_MGR_HIER_GT
       WHERE aggregation_flag = 'Y'
       MINUS
       SELECT mgr_id,
              mgr_level,
              direct_id,
              direct_level,
              emp_id,
              emp_level,
              next_level_is_leaf,
              is_leaf_flag,
	      SYSDATE,
	      G_FII_USER_ID,
	      SYSDATE,
	      G_FII_USER_ID,
	      G_FII_LOGIN_ID
       FROM  FII_CC_MGR_HIERARCHIES);

     ---------------------------------------------------------------

     if g_debug_flag = 'Y' then
		 FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT ||
                         ' rows of data into FII_CC_MGR_HIERARCHIES table');
     end if;

     --Call FND_STATS to collect statistics after re-populating the tables.

       g_phase := 'gather_table_stats for FII_CC_MGR_HIERARCHIES';
       FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'FII_CC_MGR_HIERARCHIES');

       g_phase := 'gather_table_stats for MLOG$_FII_CC_MGR_HIERARCHI';
       FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'MLOG$_FII_CC_MGR_HIERARCHI');

      FND_CONCURRENT.Af_Commit;

     FII_UTIL.stop_timer;

     if g_debug_flag = 'Y' then
     	FII_UTIL.print_timer('Duration');
     end if;

     if g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_CC_MGR_SUP_C.Incre_Update');
     end if;

    ----------------------------------------------------------------

 Exception

   WHEN OTHERS Then
     errbuf  := SQLERRM;
     retcode := SQLCODE;
     FII_UTIL.put_line('
        Error in phase ' || g_phase || ' of running FII_CC_MGR_SUP_C.Incre_Update; '
                         || 'Message: ' || sqlerrm);
     ROLLBACK;
     FII_MESSAGE.Func_Fail('FII_CC_MGR_SUP_C.Incre_Update');
     raise;

 END Incre_Update;


--**********************************************************************
-- Initial Load

 PROCEDURE Init_Load (errbuf          IN OUT NOCOPY VARCHAR2,
                      retcode         IN OUT NOCOPY VARCHAR2) IS

  l_status   VARCHAR2(1);

 BEGIN

     if g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Ent('FII_CC_MGR_SUP_C.Init_Load');
     end if;

    ----------------------------------------------------------
    --call to populate the table FII_CC_MGR_HIER_GT
    ----------------------------------------------------------
    g_phase := 'call to populate the table FII_CC_MGR_HIER_GT';

    Populate_HIER_TMP;

    g_phase := 'Truncate table FII_CC_MGR_HIERARCHIES';

    TRUNCATE_TABLE ('FII_CC_MGR_HIERARCHIES');

    g_phase := 'Insert into table FII_CC_MGR_HIERARCHIES';

        INSERT  /*+ APPEND */ INTO FII_CC_MGR_HIERARCHIES
            (MGR_ID,
             MGR_LEVEL,
             DIRECT_ID,
             DIRECT_LEVEL,
             EMP_ID,
             EMP_LEVEL,
             NEXT_LEVEL_IS_LEAF,
             IS_LEAF_FLAG,
              creation_date,
              created_by,
              last_update_date,
              last_updated_by,
              last_update_login)
         select
             MGR_ID,
             MGR_LEVEL,
             DIRECT_ID,
             DIRECT_LEVEL,
             EMP_ID,
             EMP_LEVEL,
             NEXT_LEVEL_IS_LEAF,
             IS_LEAF_FLAG,
	      SYSDATE,
	      G_FII_USER_ID,
	      SYSDATE,
	      G_FII_USER_ID,
	      G_FII_LOGIN_ID
         from
               FII_CC_MGR_HIER_GT
         where AGGREGATION_FLAG = 'Y';


     ---------------------------------------------------------------

     if g_debug_flag = 'Y' then
		 FII_UTIL.put_line('Inserted ' || SQL%ROWCOUNT ||
                         ' rows of data into FII_CC_MGR_HIERARCHIES table');
     end if;

     --Call FND_STATS to collect statistics after re-populating the tables.

       g_phase := 'gather_table_stats for FII_CC_MGR_HIERARCHIES';
       FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'FII_CC_MGR_HIERARCHIES');

       g_phase := 'gather_table_stats for MLOG$_FII_CC_MGR_HIERARCHI';
       FND_STATS.gather_table_stats
               (ownname => g_fii_schema,
                tabname => 'MLOG$_FII_CC_MGR_HIERARCHI');

      FND_CONCURRENT.Af_Commit;

     FII_UTIL.stop_timer;

     if g_debug_flag = 'Y' then
     	FII_UTIL.print_timer('Duration');
     end if;

     if g_debug_flag = 'Y' then
	FII_MESSAGE.Func_Succ('FII_CC_MGR_SUP_C.Init_Load');
     end if;

    ----------------------------------------------------------------

 Exception
   WHEN OTHERS THEN
     errbuf  := SQLERRM;
     retcode := SQLCODE;
     FII_UTIL.put_line('
        Error in phase ' || g_phase || ' of running FII_CC_MGR_SUP_C.Init_Load; '
                         || 'Message: ' || sqlerrm);
     ROLLBACK;
     FII_MESSAGE.Func_Fail('FII_CC_MGR_SUP_C.Init_Load');
     raise;

 END Init_Load;

END FII_CC_MGR_SUP_C;

/
